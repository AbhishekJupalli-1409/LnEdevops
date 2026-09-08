# Pipeline: ACI backend deploy / restart

**File:** `pipelines/aci-backend-deploy-azure-pipelines.yml`

## Introduction

Operational pipeline to **restart or refresh** the private ACI backend container group—commonly after the ingress public IP is known so CORS / `WHITELIST_URLS` can allow the real browser origin.

## Why we use it

Chicken-and-egg: Terraform creates ACI before Helm creates the public ingress IP. Browsers calling the API through the frontend origin need that IP allow-listed. This pipeline (or a second `terraform apply` with `frontend_origin`) closes the loop without redesigning networking.

Runs on `ubuntu-latest` because it uses **Azure ARM/CLI** against ACI, not kubectl.

## Real-life example

The mall finally gets its street number painted on the door. Back-office security updates the **visitor allow-list** (“accept browser calls from that street address”) and reboots the service window.

## Connections

```
ingress-nginx pipeline outputs EXTERNAL-IP
  --> set frontend_origin / WHITELIST
        --> this pipeline restarts/updates ACI
              --> browser at http://EXTERNAL-IP/emp can call API successfully

Also used when a new backend image was pushed to ACR and ACI should pull/restart.
```

## In this project

Final glue between public ingress identity and private API CORS policy. See runbook steps 3–4.
