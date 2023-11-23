# My Awesome Project

This is a brief description of my awesome project. It does amazing things!

## Installation

Requirements

Kubernetes cluster with argo-rollouts controller installed (see [install guide](https://argoproj.github.io/argo-rollouts/installation/#controller-installation))

kubectl with argo-rollouts plugin installed (see [install guide](https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation))


## Canary Deployment

### 1. Deploying a Rollout

First we deploy a Rollout resource and a Kubernetes Service targeting that Rollout. The example Rollout in this guide utilizes a canary update strategy which sends 20% of traffic to the canary, followed by a manual promotion, and finally gradual automated traffic increases for the remainder of the upgrade. This behavior is described in the following portion of the Rollout spec:

```yaml
  replicas: 5
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
```

To watch the rollout as it deploys, run the `get rollout --watch` command from plugin:

```bash
kubectl argo rollouts get rollout rollouts-demo --watch
```
### 2. Updating a Rollout

Next it is time to perform an update. Just as with Deployments, any change to the Pod template field (spec.template) results in a new version (i.e. ReplicaSet) to be deployed. 
**During a rollout update**, the controller will progress through the steps defined in the Rollout's update strategy. The example rollout sets a 20% traffic weight to the canary, and **pauses the rollout indefinitely until user action is taken to unpause/promote the rollout.** 
When the demo rollout reaches the **second step,** we can see from the plugin that the Rollout is in a **paused state** .

### 3. Promoting a Rollout

The rollout is now in a **paused state**. When a Rollout reaches a pause step with no duration, it will remain in a **paused state** indefinitely until it is resumed/promoted. **To manually promote a rollout to the next step,** run the promote command of the plugin:

```bash
kubectl argo rollouts get rollout rollouts-demo --watch
```
**Once all steps are completed successfully,** the new ReplicaSet is marked as the **"stable"** ReplicaSet. Whenever a rollout is aborted during an update, either automatically via a failed canary analysis, or manually by a user, the Rollout will fall back to the **"stable"** version.

In order to **make Rollout** considered Healthy again and not Degraded, it is necessary to change the desired state back to the previous, stable version. This typically involves running kubectl apply against the previous Rollout spec. In our case, we can simply re-run the set image command using the previous, "yellow" image.



### Summary
This Rollout in this example did not utilize an ingress controller or service mesh provider to route traffic. Instead, it used **normal Kubernetes Service networking **(i.e. kube-proxy) to achieve an approximate canary weight, based on the closest ratio of new to old replica counts. As a result, this Rollout had a ** limitation **in that it could only achieve a minimum canary weight of ** 20% **, by scaling 1 of 5 pods to run the new version. **In order to achieve much finer grained canaries, an ingress controller or service mesh is necessary. **
