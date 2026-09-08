# Pipeline: todo list app

**File:** `pipelines/app-todolist-azure-pipelines.yml`

## Brief introduction

CI for the Flask Todo List app: build and push `todo-list-app` to ACR (often from `master` in the Flask sample repo).

## Why we create it

Todolist Deployment on AKS needs fresh images in ACR for Flux to roll out.

## How it works

- Pool: `ubuntu-latest`
- Docker build/push to ACR

## Use in this project

Feeds `gitops/.../apps/todolist/deployment.yaml`.

## Example to understand

Second storefront app on the same mall (AKS) — own image, own path `/to-do`.
