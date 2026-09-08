# Pipeline: ACI backend deploy / restart

**File:** `pipelines/aci-backend-deploy-azure-pipelines.yml`

## Brief introduction

Manual-oriented pipeline to restart or refresh the private ACI backend container group (e.g. after ingress IP is known for CORS/`WHITELIST_URLS`).

## Why we create it

Backend env often needs the **public ingress IP** which does not exist until Helm install finishes. Terraform alone cannot know that IP on first apply.

## How it works

- Pool: `ubuntu-latest` (Azure ARM API to restart ACI)
- Typically restarts the container group or updates config using Azure CLI

## Use in this project

Closes the loop: ingress IP → backend allow-list → browser can call API through the frontend.

## Example to understand

After the mall gate gets its street number, update the backend’s “allowed websites” list and reboot the API box.
