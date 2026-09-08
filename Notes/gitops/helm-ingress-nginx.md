# Helm: ingress-nginx

**Values file:** `helm/nginx-ingress-values.yaml`  
**Installed by:** `pipelines/ingress-nginx-helm-azure-pipelines.yml`

## Brief introduction

**Helm** installs charts (templated Kubernetes packages). The official **ingress-nginx** chart runs NGINX as an Ingress controller watching Ingress objects.

## Why we create / install it

Kubernetes needs a controller to implement `Ingress` resources. This chart gives a `LoadBalancer` Service → public IP for path routing.

## How it is used here

Values highlight:

- 2 controller replicas
- Service type `LoadBalancer`
- Small CPU/memory for cost
- Default IngressClass `nginx`

No custom chart lives in-repo — only values + pipeline `helm upgrade --install`.

## Example to understand

Helm chart = IKEA furniture kit for “ingress controller.” Values.yaml = your chosen size/color. Pipeline = assembly team with access to the private workshop (AKS API).
