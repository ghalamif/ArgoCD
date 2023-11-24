## Deployment Strategies

Here are 4 deployment strategies implementations offered by the Argo Rollouts:

### Rolling Update (Default Strategy)
A RollingUpdate slowly replaces the old version with the new version. As the new version comes up, the old version is scaled down in order to maintain the overall count of the application.

**Suitability for ML:** Rolling deployment can be suitable for ML pipelines with stateful components or when you want to update the model serving infrastructure incrementally without a complete stop-and-start.

### Recreate (Downtime)
A Recreate deployment deletes the old version of the application before bring up the new version.
This strategy ensures that **two versions of the application never run at the same time**, but there is **downtime** during the deployment.

**Suitability for ML:** Recreate deployment can be suitable for ML pipelines, especially when you need to make significant changes to the underlying infrastructure, dependencies, or data preprocessing steps. It provides a fresh start for the entire pipeline.

### Blue-Green
A Blue-Green deployment (sometimes referred to as a Red-Black) **has both the new and old version of the application** deployed at the same time. During this time, only the old version of the application will receive production traffic. This allows the developers to run tests against the new version before switching the live traffic to the new version.

**Suitability for ML:** Blue-Green deployment can be beneficial for ML pipelines when you want to ensure a seamless transition between model versions. You can train and deploy a new model in the "green" environment, test it thoroughly, and then switch traffic to the new model without downtime.
![picture from https://argoproj.github.io/argo-rollouts/concepts/ ](https://argoproj.github.io/argo-rollouts/concepts-assets/blue-green-deployments.png)

### Canary 
A Canary deployment exposes a subset of users to the new version of the application while serving the rest of the traffic to the old version. Once the new version is verified to be correct, the **new version can gradually replace the old version.** Ingress controllers and service meshes such as NGINX and Istio, enable more sophisticated traffic shaping patterns for canarying than what is natively available (e.g. achieving very fine-grained traffic splitting, or splitting based on HTTP headers).

**Suitability for ML:** Canary deployment is suitable for ML pipelines when you want to release a new model to a small subset of users first. It helps you observe the model's behavior in a real-world environment and gather feedback before deploying it more widely.
![picture from https://argoproj.github.io/argo-rollouts/concepts/ ](https://argoproj.github.io/argo-rollouts/concepts-assets/canary-deployments.png)

## UI Dashboard

The Argo Rollouts Kubectl plugin can serve a local** UI Dashboard** to visualize your Rollouts.

To start it, run `kubectl argo rollouts dashboard` in the namespace that contains your Rollouts.

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
This Rollout in this example did not utilize an ingress controller or service mesh provider to route traffic. Instead, it used **normal Kubernetes Service networking**(i.e. kube-proxy) to achieve an approximate canary weight, based on the closest ratio of new to old replica counts. As a result, this Rollout had a **limitation** in that it could only achieve a minimum canary weight of **20%** , by scaling 1 of 5 pods to run the new version.**In order to achieve much finer grained canaries, an ingress controller or service mesh is necessary.**
