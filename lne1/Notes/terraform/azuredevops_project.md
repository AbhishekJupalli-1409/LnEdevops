# azuredevops_project

## Introduction

An Azure DevOps **project** is a container for pipelines, repos, boards, artifacts, and service connections. (The **organization** itself cannot be created by the provider — you create that manually once.)

## Why we use it

Optional Terraform management (`manage_azure_devops`) makes the project reproducible: same name, visibility, and child connections/pipelines as code.

## Real-life example

Opening a **project office** in a company HQ building (the AzDO org). Inside that office you put crews (pipelines), phone lines (service connections), and a shared whiteboard (variable group).

## Connections in this project

```
azuredevops_project
  ├── service endpoints (ARM, ACR, GitHub)
  ├── variable group empapp-shared-vars
  └── build definitions --> YAML in pipelines/
```

## How Terraform creates it

Module `terraform/modules/azuredevops` (count-gated).

## In this project

Home for all seven YAML pipelines’ definitions when managed by Terraform.
