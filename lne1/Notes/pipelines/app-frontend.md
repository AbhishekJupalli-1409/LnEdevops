# Pipeline: employee frontend

**File:** `pipelines/app-frontend-azure-pipelines.yml`

## Introduction

CI pipeline for the React **employee frontend**. It builds a container image and pushes it to ACR as something like `employee-app-frontend`.

Kubernetes does not build your React app; it only **runs** an image. This pipeline is the factory that produces that image.

## Why we use it

Every UI change must become an immutable image in ACR so Flux/AKS can roll out a known version. Building on developer laptops alone does not give a shared, tagged artifact history.

## Real-life example

A **bakery packaging line**: dough (source) → sealed packaged cake (image) → warehouse shelf (ACR) → later delivered to storefront shelves (AKS pods via Flux).

## Connections

```
GitHub/app source
  --> this pipeline (ubuntu-latest)
        --> docker build/push --> ACR
              --> Flux Deployment frontend references ${ACR_LOGIN_SERVER}/employee-app-frontend:...
                    --> AKS kubelet AcrPull pulls image
                          --> users hit /emp via ingress

Frontend pods still call ACI backend privately for API data.
```

Does **not** need private pool (no kubectl).

## In this project

Supplies images for `gitops/.../apps/frontend/deployment.yaml`.
