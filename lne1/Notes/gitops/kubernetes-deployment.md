# Kubernetes Deployment

**Files:** `apps/frontend/deployment.yaml`, `apps/todolist/deployment.yaml`

## Introduction

A **Deployment** declares a desired number of identical pods (replicas), the container image, ports, and environment variables. The controller creates a ReplicaSet and keeps pods healthy/replaced on failure.

## Why we use it

We need reliable web processes with more than one replica for basic resilience and rolling updates when the image tag changes.

## Real-life example

A job order: “Always keep **two cashiers** of type Frontend on shift.” If one goes on break (pod crash), hire a replacement automatically. Changing the uniform/version (image tag) triggers a controlled shift handover (rolling update).

## Connections

```
Deployment frontend
  image: ${ACR_LOGIN_SERVER}/employee-app-frontend:...
  env: API base URL --> http://BACKEND_PRIVATE_IP:BACKEND_PORT (ACI)
  <-- pulled via AcrPull
  --> selected by Service frontend-service
        --> Ingress /emp

Deployment todolist
  image: ${ACR_LOGIN_SERVER}/todo-list-app:...
  container port 5000
  --> Service todolist-service --> Ingress /to-do and /static
```

Substitutions come from Flux `cluster-vars`. Images come from app pipelines → ACR.

## In this project

Only these two app Deployments on AKS (plus system components from Helm/Flux).
