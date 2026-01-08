<!-- Report note: short intro and setup steps for the Kustomize demo. -->
# Kustomize App
This folder shows how to use Kustomize to deploy the same app with different
settings for each environment.

## Project task
Use a single base Deployment and apply small changes with overlays:
- `base` has the main Deployment.
- `environments/staging` reuses the base with a staging namespace.
- `environments/production` adds a namespace and increases replicas.

## Setup
Requirements: a Kubernetes cluster and `kubectl`.

1) Apply the base (no overlay):
```bash
kubectl apply -k kustomize-app/base
```

2) Apply staging:
```bash
kubectl apply -k kustomize-app/environments/staging
```

3) Apply production:
```bash
kubectl apply -k kustomize-app/environments/production
```

## Useful commands
```bash
kubectl kustomize kustomize-app/environments/production
kubectl get deploy -n production
```
