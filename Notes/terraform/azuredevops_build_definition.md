# azuredevops_build_definition

## Introduction

Registers an Azure Pipelines **pipeline** that points at a YAML file in a repository (path, branch, name).

## Why we use it

Infrastructure-as-code for CI itself: recreating the AzDO project also recreates pipeline entries pointing at `pipelines/*.yml`.

## Real-life example

Posting **job descriptions on the office wall**: “Infra Apply crew follows procedure binder page 12,” “Frontend Build crew follows page 20.” The YAML is the procedure; the build definition is the posting.

## Connections in this project

```
build_definition.app (for_each) --> frontend/backend/todolist YAMLs
build_definition.platform (for_each) --> infra, ingress, flux, aci YAMLs
  --> when run, they touch ACR / Azure / private AKS as documented in pipeline notes
```

## How Terraform creates it

`for_each` over maps of pipeline names → YAML paths in azuredevops module.

## In this project

Creates the clickable pipelines that drive the platform after Terraform infra exists.
