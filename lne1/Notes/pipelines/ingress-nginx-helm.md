# Pipeline: ingress-nginx Helm

**File:** `pipelines/ingress-nginx-helm-azure-pipelines.yml`  
**Values:** `helm/nginx-ingress-values.yaml`

## Introduction

Installs or upgrades the official **ingress-nginx** Helm chart onto private AKS, then prints the **public LoadBalancer EXTERNAL-IP**. That IP is the only public entry users need.

## Why we use it

Kubernetes Ingress objects are only wishes until a controller exists. Helm is the standard way to install ingress-nginx with durable values (replica count, resources, LB service).

Must use **`empapp-private-pool`** because Helm talks to the **private AKS API**.

## Real-life example

Installing the mall’s **main revolving door and directory board hardware**.

Until the door exists, hanging paper signs (`Ingress` YAML) does nothing. After install, the city assigns a street number (public LB IP). Later GitOps hangs the shop nameplates (`/emp`, `/to-do`) on that door.

## Connections

```
Agent VM (private pool)
  --> helm upgrade --install ingress-nginx -f helm/nginx-ingress-values.yaml
        --> controller pods + Service type LoadBalancer
              --> Azure allocates public IP
                    --> Users HTTPS to that IP
                    --> Ingress resource (from Flux) routes paths to Services

Outputs IP used for:
  - browser testing
  - frontend_origin / WHITELIST_URLS / CORS on ACI backend
```

## In this project

Creates the public front door; does not deploy apps (Flux does).
