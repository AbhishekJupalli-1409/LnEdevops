# azuredevops_serviceendpoint_azurecr

## Introduction

Service connection specialized for **Azure Container Registry** so Docker tasks can log in and push/pull images.

## Why we use it

App CI pipelines need a reliable way to authenticate to ACR without baking admin passwords into scripts.

## Real-life example

Warehouse **shipping dock credentials** for the factory (CI) to drop off new product boxes (images).

## Connections in this project

```
app-frontend / app-backend / app-todolist pipelines
  --push--> ACR (via ACR service connection)
              --pull--> AKS / ACI (via AcrPull identities — separate from this endpoint)
```

## How Terraform creates it

`azuredevops_serviceendpoint_azurecr.acr`.

## In this project

CI push path into the image hub.
