<!-- Report note: basic app deployment and service example. -->
# Basic App
This folder contains a simple Kubernetes Deployment and Service.
It is used as a small demo app for Argo CD sync.

## Project task
Deploy one nginx-based app and expose it with a Service.
This is the smallest example in the project.

## Setup
Requirements: a Kubernetes cluster and `kubectl`.

1) Create the namespace:
```bash
kubectl create namespace basic-app
```

2) Apply the Deployment and Service:
```bash
kubectl apply -n basic-app -f basic-app/deployment.yaml
kubectl apply -n basic-app -f basic-app/service.yaml
```

## Argo CD option
You can also apply the Argo CD Application from `application.yaml`
to let Argo CD manage this folder.
