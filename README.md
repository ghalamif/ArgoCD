# ArgoCD GitOps MLOps Demonstration Repository

## Report Overview
This repository documents a master's project at Friedrich-Alexander-Universitaet
Erlangen-Nuernberg (FAU) focused on improving MLOps with GitOps. The work
demonstrates how Argo CD can manage Kubernetes-native CI/CD/CT workflows for
machine learning applications through declarative configuration and automated
syncing.

The project emphasizes:
- GitOps-driven automation for deployment workflows
- Safe rollout strategies using Argo Rollouts
- Automated image updates with Argo CD Image Updater
- Observability and operational reliability practices

For background on Argo CD, see the official documentation:
https://argo-cd.readthedocs.io/

## How This Repository Works
The repository is organized as a set of focused demos. Each folder contains
Kubernetes manifests (and a local README) that illustrate a specific Argo CD
feature. The core GitOps flow is:

1) Argo CD watches the Git repository for changes.
2) The `application.yaml` file defines multiple Argo CD Application resources,
   one per demo folder.
3) Each Application declares the source path in Git and the destination
   namespace in the cluster.
4) Automated sync policies keep the cluster state aligned with Git, enabling
   self-heal and pruning when enabled.

Some demos reference a separate repository to isolate experiments such as
webhook hooks or image-updater flows; these links are called out in
`application.yaml`.

## Directory Structure
Top-level contents and their purpose:

- `application.yaml`: Argo CD Application definitions for the demo folders.
- `project-flow.sh`: Helper script for port-forwarding, logs, rollouts, and
  image-updater tasks.
- `Untitled Diagram.drawio`: Architecture or flow diagram used for reporting.
- `argo-hooks/`: Argo CD hook demo with a PostSync job and SealedSecret usage.
- `argo-image-updater/`: Argo CD Image Updater demo, including a Helm chart.
  - `argo-image-updater/image-updater/`: Helm chart sources (templates, values).
- `argo-rollout/`: Rollout strategy examples (rolling, recreate, blue-green,
  canary).
- `basic-app/`: Minimal Deployment and Service for a basic Argo CD sync demo.
- `cascade-deletion/`: Demonstrates cascade vs non-cascade deletion and
  finalizers.
- `helm-app/`: Helm-based app example for declarative GitOps with Argo CD.
  - `helm-app/helmrollout/`: Helm chart sources (templates, values).
- `kustomize-app/`: Kustomize base and environment overlays.
  - `kustomize-app/base/`: Base manifests.
  - `kustomize-app/environments/`: Staging and production overlays.
- `service-monitor/`: Prometheus ServiceMonitor example for Argo CD
  observability.
- `wave/`: Sync wave ordering example for resource sequencing.
- `web-hook/`: Hook type examples and hook cleanup patterns.

## Reproducibility Notes
To reproduce the demos in a cluster, Argo CD and the required controllers
(Argo Rollouts, Sealed Secrets, and optionally Prometheus) should be installed.
Each demo directory includes its own local README with setup steps and
requirements.
