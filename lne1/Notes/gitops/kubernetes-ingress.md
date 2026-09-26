# Kubernetes Ingress

**File:** `apps/ingress/ingress.yaml`

## Introduction

An **Ingress** resource describes HTTP routing: host/path → backend Service. It is implemented by an Ingress **controller** (here ingress-nginx installed with Helm). One public IP can multiplex many apps by path or host.

## Why we use it

We want **one** public address for humans, with `/emp` and `/to-do` selecting apps. Separate public IPs per Service would cost more and confuse users.

## Real-life example

Mall **directory signs at a single entrance**:

- Electronics → `/emp`  
- Errands desk → `/to-do`  
- Shared brochure rack → `/static`  

The entrance hardware is ingress-nginx; the signs are this Ingress object.

## Connections

```
Internet --> LB IP (Helm ingress-nginx)
              --> Ingress apps-ingress rules
                    --> frontend-service / todolist-service
                          --> pods

Backend API is NOT an Ingress path; browsers talk to frontend,
frontend (server/browser calls as designed) uses private ACI.
CORS on ACI must allow origin http://<LB-IP> ...
```

## In this project

Applied by Flux after controller exists; order matters (Helm first, then Flux apps — or Flux retries until controller is ready).
