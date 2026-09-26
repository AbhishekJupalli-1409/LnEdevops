# azuredevops_serviceendpoint_github

## Introduction

Connects Azure DevOps to **GitHub** (commonly via PAT) so pipelines can checkout GitHub repos or automate GitHub-related steps.

## Why we use it

Sample apps and/or GitOps-related flows may live on GitHub. AzDO needs credentials to clone or interact without interactive login.

## Real-life example

A **library card** letting the CI clerk borrow source books from the GitHub library.

## Connections in this project

```
AzDO <--GitHub endpoint--> GitHub repos (app sources / platform repo)
Flux bootstrap also needs GitHub token (pipeline variable) to install GitOps sync
```

## How Terraform creates it

`azuredevops_serviceendpoint_github` with `auth_personal`.

## In this project

Source control bridge for pipelines that aren’t pure AzDO repos.
