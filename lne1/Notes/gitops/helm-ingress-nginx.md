# Helm: ingress-nginx

**Values:** `helm/nginx-ingress-values.yaml`  
**Installed by:** private-pool pipeline `ingress-nginx-helm-azure-pipelines.yml`

## Introduction

**Helm** is the package manager for Kubernetes. A **chart** is a templated set of Kubernetes resources. The official **ingress-nginx** chart installs NGINX Ingress Controller pods plus a Service (here `LoadBalancer`) that receives a public IP on Azure.

This repo does **not** vendor a custom chart — only a **values** file that tunes replicas, resources, and service type.

## Why we use it

Without a controller, `kind: Ingress` objects do nothing. ingress-nginx is the common open-source choice and integrates with Azure LB out of the box via `type: LoadBalancer`.

## Real-life example

Ordering a **standard door system kit** from a vendor (chart) and filling a preference form (values.yaml): “two attendants (replicas), normal size motors (resources), street-facing entrance (LoadBalancer).” The private-pool pipeline is the on-site crew allowed into the locked building to install it.

## Connections

```
helm upgrade --install
  -f nginx-ingress-values.yaml
  --> controller Deployment in ingress-nginx namespace
  --> Service LoadBalancer --> Azure public IP
        --> reads Ingress apps-ingress (from Flux)
              --> routes /emp /to-do /static

Public IP --> CORS/WHITELIST for ACI backend
```

## In this project

Only Helm usage; apps themselves are raw YAML + Flux.
