# My Awesome Project

## Prerequisites

The following prerequisites are required.
Markup : 
* A Kubernetes cluster
* Deciding what security configurations to apply to your installation, if any
Installing and configuring Helm.
* Install Kubernetes or have access to a cluster

## Install Helm
For more details, or for other options, see the [installation guide](https://helm.sh/docs/intro/install/).

Initialize a Helm Chart Repository

Once you have Helm ready, you can add a chart repository. Check [Artifact Hub](https://artifacthub.io/packages/search?kind=0) for available Helm chart repositories.
```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
````

NOTICE: Do Not Forget To Update Repo!!!
```bash
$ helm repo update  
````
``