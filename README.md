# How To Install ArgoCD
## Requirements
Installed kubectl command-line tool.
Have a kubeconfig file (default location is ~/.kube/config).
### 1. Install Argo CD¶

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


