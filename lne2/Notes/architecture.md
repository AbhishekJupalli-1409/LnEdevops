# Architecture

Upstream sample: [dockersamples/example-voting-app](https://github.com/dockersamples/example-voting-app) (`master`).

The sample is three programs plus Redis and a database. This platform keeps that shape and swaps the sample's Postgres container for Azure Database for MySQL Flexible Server.

## What each program does

| App | Code | Port | What a request does |
|---|---|---|---|
| vote | `./vote` Flask + gunicorn | 80 | `GET /` shows Cats vs Dogs. `POST /` reads the form field `vote` (`a` or `b`) and `RPUSH`es JSON `{voter_id, vote}` onto the Redis list `votes`. The voter id is a cookie `voter_id`. |
| worker | `./worker` .NET | none | `LPOP`s `votes` and `INSERT`s into `votes(id, vote)`. A duplicate id becomes `UPDATE`. The worker creates the table. |
| result | `./result` Node | 80 | Every second `SELECT vote, COUNT(id) FROM votes GROUP BY vote` and pushes the totals to the browser over Socket.IO. |

The sample Docker Compose file points vote at hostname `redis` and worker/result at hostname `db` with user `postgres`. Those names are hard-coded, and the pages assume they are served at `/`. This platform does not copy the application into git. Each image pipeline clones the sample and applies a small patch before `docker build`, because the sample as published will not run on this platform:

- **MySQL, not Postgres.** The task asks for Azure Database for MySQL. The worker uses Npgsql and the result app uses the `pg` driver, both with a fixed connection string `postgres:postgres@db`. The patches switch those two programs to MySQL and read host, user, password, and database from environment variables. The password stays in Key Vault and is injected as a Kubernetes secret. It is not baked into the image.
- **Paths `/vote` and `/result`.** The vote form posts to `/`. The result page loads `/stylesheets/...` and opens Socket.IO at `/socket.io`. On one ingress IP those root paths collide. The vote patch posts to `/vote/`. The result patch loads assets and the socket under `/result`. Ingress then strips that prefix before the container sees the request.
- **Vote image target.** The sample Dockerfile's default stage for Compose is `dev`. The pipeline builds target `final`, which is gunicorn on port 80.

The patch files live in `patches/`. The script `scripts/patch-voting-app.sh` copies them into the clone. Paths in that script are from the repository root, which is this folder when you push it to Azure DevOps.

## Request path

```text
browser
  -> public IP of the ingress-nginx LoadBalancer (HTTP :80)
       /vote/   rewrite -> vote Service :80 -> vote pod
       /result/ rewrite -> result Service :80 -> result pod
       /static  (no rewrite) -> vote Service   (Flask CSS)
  vote pod --TCP 6379--> redis Service (ClusterIP, NetworkPolicy)
  worker pod --TCP 6379--> redis
  worker pod --TCP 3306--> MySQL private endpoint (10.20.2.0/24)
  result pod --TCP 3306--> MySQL private endpoint
```

Redis is the backend for the vote page. A NetworkPolicy on the Redis pods allows TCP 6379 only from pods labeled `app=vote` and `app=worker`. The worker has no Service and no ingress rule, so it is not reachable from the browser. Result does not open a connection to Redis. Result reads MySQL directly, which is how the upstream sample is written. MySQL Flexible Server is created without a delegated subnet, so Azure leaves public network access enabled. This stack adds no firewall rule, which means a login from the internet is refused. The private endpoint in `snet-pe` is the path AKS uses, and the private DNS zone `privatelink.mysql.database.azure.com` makes the server name resolve to that private IP inside the VNet.

Key Vault holds the MySQL password. The Flux pipeline (running on the private agent VM) reads that secret and creates the Kubernetes secret `voting-db`. The password is not written into git. Key Vault also has a private endpoint. Its public data plane stays enabled so the first Terraform apply, which runs on a Microsoft-hosted agent, can create the secrets. Workloads inside the cluster do not call Key Vault on the request path.

## Azure layout (Central India)

```text
subscription policies
  allowed locations: centralindia, southindia, westindia
  required tags: Department, Project Code
  deny a public IP on a NIC

rg-voteapp-centralindia
  vnet-voteapp-cin 10.20.0.0/16
    snet-aks   10.20.1.0/24   private AKS (API has no public IP)
    snet-pe    10.20.2.0/24   MySQL PE + Key Vault PE
    snet-agent 10.20.4.0/24   agent VM, no public IP, NAT gateway for outbound
  ACR Basic (no private endpoint on this SKU; AcrPull on the kubelet)
  AKS system pool Standard_D2s_v3, one node, Azure network policy
  MySQL Flexible Server B_Standard_B1ms, database "voting"
  Key Vault
  vm-voteapp-agent Standard_B2s_v2
```

The ingress LoadBalancer public IP is created by AKS in the `MC_` resource group when the Helm chart installs ingress-nginx. That public IP is not attached to a NIC, so the NIC policy does not block it. The AKS API server stays private. Pipelines that run `kubectl` or `helm` use the pool `voteapp-private-pool`. Image build uses `ubuntu-latest` because the agent VM does not run Docker.

Pod CIDR `10.244.0.0/16` and service CIDR `10.21.0.0/16` sit outside the VNet range so they do not overlap the subnets.

## Pipeline order

1. Bootstrap remote state (local Terraform, once).
2. Infra pipeline: policies, network, ACR, private AKS, MySQL + database, Key Vault, agent VM.
3. Image pipeline: clone, patch, push `vote`, `worker`, `result` to ACR.
4. Ingress pipeline on the private pool: Helm chart `ingress-nginx`.
5. Flux pipeline on the private pool: bootstrap, write `cluster-vars` and `voting-db`, reconcile `gitops/`.

Flux substitutes `${ACR_LOGIN_SERVER}`, `${MYSQL_HOST}`, `${MYSQL_USER}`, and `${MYSQL_DATABASE}` from the ConfigMap `cluster-vars` in `flux-system`. Those values are discovered with Azure CLI at pipeline time. They are not hard-coded in the YAML.
