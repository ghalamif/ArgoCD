# ArgoCD

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. This project allows users to manage application deployments and configurations in a Kubernetes cluster using Git repositories as the source of truth.

## Features

- **GitOps Workflow:** Declaratively define and manage Kubernetes resources using Git.
- **Automated Sync:** Automatically synchronize the state of your applications in the cluster to match the configuration defined in Git.
- **Visual Dashboard:** Web-based UI for managing and visualizing application deployments.
- **Access Control:** Role-Based Access Control (RBAC) for secure and controlled operations.
- **Multi-Cluster Support:** Manage applications across multiple Kubernetes clusters.
- **Health Status & Monitoring:** Real-time status and health tracking for deployed applications.
- **Custom Resource Support:** Extensible to support custom Kubernetes resources and workflows.

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/ghalamif/ArgoCD.git
   ```
2. Follow the setup instructions in the repository to install ArgoCD and connect it to your Kubernetes cluster.

## Use Cases

- Continuous delivery for Kubernetes applications.
- Infrastructure as Code (IaC) deployments.
- Automated rollback and self-healing of applications.
- Secure and auditable change management.

## Documentation

For comprehensive documentation, please refer to the [official ArgoCD documentation](https://argo-cd.readthedocs.io/).

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for improvements, bug fixes, or feature requests.



# How To Install ArgoCD
## Requirements
Installed kubectl command-line tool.
Have a kubeconfig file (default location is ~/.kube/config).
### 1. Install Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
This will create a new namespace, argocd, where Argo CD services and application resources will live.

### 2. Download Argo CD CLI

Download the latest Argo CD version from https://github.com/argoproj/argo-cd/releases/latest. More detailed installation instructions can be found via the CLI installation documentation.

Also available in Mac, Linux and WSL Homebrew:


```bash
brew install argocd
```

### 3. Port Forwarding

Kubectl port-forwarding can be used to connect to the API server without exposing the service.

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
The API server can then be accessed using https://localhost:8080





