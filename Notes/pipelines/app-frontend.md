# Pipeline: employee frontend

**File:** `pipelines/app-frontend-azure-pipelines.yml`

## Brief introduction

CI for the React employee frontend: build container image and push to ACR as `employee-app-frontend`.

## Why we create it

AKS (via Flux) pulls the frontend image from ACR. Without CI, image tags never update.

## How it works

- Pool: `ubuntu-latest`
- Builds from the frontend app repo/path (sample React app wiring)
- Pushes to ACR using the ACR service connection

## Use in this project

Supplies images referenced in `gitops/.../apps/frontend/deployment.yaml` (with `${ACR_LOGIN_SERVER}` substituted by Flux).

## Example to understand

Assembly line: source → Docker image → warehouse (ACR) → later delivered to AKS by Flux.
