# Kustomize (apps)

**Native:** `apps/kustomization.yaml`  
**Flux CR:** `apps-kustomization.yaml`

## Introduction

**Kustomize** builds a set of Kubernetes YAML files from a `kustomization.yaml` list (and optional patches/overlays) without Go templates. Flux natively runs Kustomize builds and also has its own `Kustomization` custom resource to schedule those builds from git.

## Why we use it

Keeps app manifests as plain YAML (easy to read in PRs) while giving Flux one unit to reconcile. Substitutions (`cluster-vars`) inject environment-specific values without forking files per deployment.

## Real-life example

A **packing list** (“include these documents”) plus a supervisor (Flux Kustomization) who unpacks the box onto the correct floor every five minutes and fills in blanks from sticky notes (`cluster-vars`).

## Connections

```
apps/kustomization.yaml lists:
  - namespace.yaml
  - frontend/*.yaml
  - todolist/*.yaml
  - ingress/ingress.yaml

Flux Kustomization apps
  path: ./apps
  substituteFrom: cluster-vars
  --> renders final manifests --> apply to cluster
```

## In this project

Composition layer between git files and live AKS objects.
