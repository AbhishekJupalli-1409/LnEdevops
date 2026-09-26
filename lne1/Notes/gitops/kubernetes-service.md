# Kubernetes Service

**Files:** `apps/frontend/service.yaml`, `apps/todolist/service.yaml`

## Introduction

A **Service** provides a stable virtual IP and DNS name (`frontend-service.apps.svc.cluster.local`) that load-balances to pods matching a selector. Pod IPs change; Service IPs/names do not.

These are **ClusterIP** (internal only). Public exposure is via Ingress + ingress-nginx LB, not by making these Services public.

## Why we use it

Ingress and other pods should not hardcode pod IPs. Services are the stable “reception desk numbers.”

## Real-life example

The store’s **switchboard extension**. Cashiers (pods) rotate; the published extension (Service) always rings someone on duty.

## Connections

```
Ingress path /emp    --> Service frontend-service:80 --> frontend pods
Ingress path /to-do  --> Service todolist-service:80 --> todolist pods (:5000)
Ingress path /static --> todolist-service (static assets)

Services do NOT talk to Postgres; only frontend may call ACI using env IP.
```

## In this project

Internal glue between Ingress and Deployments.
