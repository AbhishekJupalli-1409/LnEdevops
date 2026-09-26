# Pipeline: todo list app

**File:** `pipelines/app-todolist-azure-pipelines.yml`

## Introduction

CI for the Flask **Todo List** app. Builds/pushes `todo-list-app` to ACR (often from the sample Flask repo’s `master` branch).

## Why we use it

Second user-facing app on the same cluster and ingress IP needs its own image lifecycle. Sharing one giant image with the employee app would couple unrelated release cycles.

## Real-life example

A second shop in the same mall manufactures its own products (Flask images) but shares the mall entrance (ingress) and warehouse company (ACR).

## Connections

```
Flask source --> pipeline --> ACR (todo-list-app)
  --> Flux Deployment todolist
        --> Service todolist-service
              --> Ingress paths /to-do and /static

Independent of ACI/Postgres (employee stack).
```

## In this project

Feeds `gitops/.../apps/todolist/*`.
