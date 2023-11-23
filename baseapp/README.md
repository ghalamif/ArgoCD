# My Awesome Project

This is a brief description of my awesome project. It does amazing things!

## Installation

Requirements¶

Kubernetes cluster with argo-rollouts controller installed (see install guide)
kubectl with argo-rollouts plugin installed (see install guide)


## Canary Deployment
Once all steps are completed successfully, the new ReplicaSet is marked as the "stable" ReplicaSet. Whenever a rollout is aborted during an update, either automatically via a failed canary analysis, or manually by a user, the Rollout will fall back to the "stable" version.


