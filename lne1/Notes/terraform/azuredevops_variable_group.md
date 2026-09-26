# azuredevops_variable_group

## Introduction

A **variable group** stores shared pipeline variables and secrets (ACR names, state storage account, PATs, etc.) reusable across many pipelines.

## Why we use it

Seven pipelines need the same settings. Duplicating values in each YAML causes drift and leaked secrets in PRs. One group (`empapp-shared-vars`) is the single place to update.

## Real-life example

A **shared whiteboard + locked drawer** in the project office: everyone reads the same ACR name; secrets sit in the locked drawer (secret variables).

## Connections in this project

```
empapp-shared-vars
  --> referenced by pipelines as: - group: empapp-shared-vars
  --> feeds terraform backend config names, tokens, ACR info, etc.
```

## How Terraform creates it

`azuredevops_variable_group.shared`.

## In this project

Operational config hub for CI/CD.
