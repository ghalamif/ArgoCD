# My Awesome Project

This is a brief description of my awesome project. It does amazing things!

## Installation

Requirements¶

Kubernetes cluster with argo-rollouts controller installed (see [install guide](https://argoproj.github.io/argo-rollouts/installation/#controller-installation))

kubectl with argo-rollouts plugin installed (see [install guide](https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation))


## Canary Deployment

### 1. Deploying a Rollout¶

First we deploy a Rollout resource and a Kubernetes Service targeting that Rollout. The example Rollout in this guide utilizes a canary update strategy which sends 20% of traffic to the canary, followed by a manual promotion, and finally gradual automated traffic increases for the remainder of the upgrade. This behavior is described in the following portion of the Rollout spec:
spec:

`  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {}
      - setWeight: 40
      - pause: {duration: 10}
      - setWeight: 60
      - pause: {duration: 10}
      - setWeight: 80
      - pause: {duration: 10}`

Once all steps are completed successfully, the new ReplicaSet is marked as the "stable" ReplicaSet. Whenever a rollout is aborted during an update, either automatically via a failed canary analysis, or manually by a user, the Rollout will fall back to the "stable" version.


