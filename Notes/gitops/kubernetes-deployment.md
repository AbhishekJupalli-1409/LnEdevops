# Kubernetes Deployment

**Files:**

- `apps/frontend/deployment.yaml`
- `apps/todolist/deployment.yaml`

## Brief introduction

A **Deployment** declares desired pods (replicas, image, env) and a ReplicaSet controller keeps that many pods running.

## Why we create it

Run React frontend and Flask todolist with 2 replicas each for basic availability.

## How it is created (GitOps)

Flux applies YAML. Image uses substituted ACR server, e.g. `${ACR_LOGIN_SERVER}/employee-app-frontend:...`. Frontend env points API base URL at ACI private IP/port.

## Use in this project

| Deployment | App | Notes |
|------------|-----|-------|
| `frontend` | Employee React UI | Talks to private backend |
| `todolist` | Flask Todo List | Port 5000 in container |

## Example to understand

A job description: “Always keep 2 cashiers of type frontend.” If one leaves (pod crash), hire a replacement automatically.
