# Pipeline: ingress-nginx Helm

**File:** `pipelines/ingress-nginx-helm-azure-pipelines.yml`

## Brief introduction

Installs/upgrades **ingress-nginx** on private AKS using Helm and `helm/nginx-ingress-values.yaml`, then prints the public LoadBalancer IP.

## Why we create it

Apps need one public entry IP with path routing (`/emp`, `/to-do`). Helm is the supported way to install ingress-nginx; must run where the private API is reachable.

## How it works

- Pool: **`empapp-private-pool`** (agent VM in VNet)
- `helm upgrade --install` with project values (2 replicas, LoadBalancer, small resources)
- Outputs external IP for CORS / WHITELIST and for humans

## Use in this project

Creates the public front door; Ingress objects in GitOps then attach routes to it.

## Example to understand

Installing the mall’s main gate (ingress controller). GitOps later hangs store signs (`/emp`, `/to-do`) on that gate.
