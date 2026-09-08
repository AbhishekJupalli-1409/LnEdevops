# Kustomize (apps)

**File:** `gitops/clusters/aks-centralindia/apps/kustomization.yaml`  
**Flux CR:** `apps-kustomization.yaml`

## Brief introduction

**Kustomize** composes plain YAML (resources list, patches, etc.) without templates. Flux natively understands Kustomize directories and its own `Kustomization` CRD.

## Why we create it

Keep app manifests as readable YAML and let one `kustomization.yaml` list them for Flux to apply as a unit.

## How it works here

- Native `apps/kustomization.yaml` lists namespace, frontend, todolist, ingress.
- Flux `Kustomization` named `apps` points at `./apps` and enables substitutions from `cluster-vars`.

## Example to understand

A packing list (“include these files”) plus a Flux supervisor that unpacks the box into the cluster every few minutes.
