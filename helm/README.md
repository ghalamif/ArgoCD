# HELM!

## Prerequisites

The following prerequisites are required: 
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
``````

NOTICE: Do Not Forget To Update Repo!!!

```bash
$ helm repo update  
``````
## The Chart File Structure

A chart is organized as a collection of files inside of a directory. The directory name is the name of the chart (without versioning information). Thus, a chart describing WordPress would be stored in a wordpress/ directory.
```bash
wordpress/
  Chart.yaml          #A YAML file containing information about the chart
  LICENSE             #OPTIONAL: A plain text file containing the license for the chart
  README.md           #OPTIONAL: A human-readable README file
  values.yaml         #The default configuration values for this chart
  values.schema.json  #OPTIONAL: A JSON Schema for imposing a structure on the values.yaml file
  charts/             #A directory containing any charts upon which this chart depends.
  crds/               #Custom Resource Definitions
  templates/          #A directory of templates that, when combined with values,
                      #will generate valid Kubernetes manifest files.
  templates/NOTES.txt #OPTIONAL: A plain text file containing short usage notes


```

## The Chart.yaml File

The Chart.yaml file is required for a chart. It contains the following fields:
```yaml
apiVersion: The chart API version (required)
name: The name of the chart (required)
version: A SemVer 2 version (required)
kubeVersion: A SemVer range of compatible Kubernetes versions (optional)
description: A single-sentence description of this project (optional)
type: The type of the chart (optional)
keywords:
  - A list of keywords about this project (optional)
home: The URL of this projects home page (optional)
sources:
  - A list of URLs to source code for this project (optional)
dependencies: # A list of the chart requirements (optional)
  - name: The name of the chart (nginx)
    version: The version of the chart ("1.2.3")
    repository: (optional) The repository URL ("https://example.com/charts") or alias ("@repo-name")
    condition: (optional) A yaml path that resolves to a boolean, used for enabling/disabling charts (e.g. subchart1.enabled )
    tags: # (optional)
      - Tags can be used to group charts for enabling/disabling together
    import-values: # (optional)
      - ImportValues holds the mapping of source values to parent key to be imported. Each item can be a string or pair of child/parent sublist items.
    alias: (optional) Alias to be used for the chart. Useful when you have to add the same chart multiple times
maintainers: # (optional)
  - name: The maintainers name (required for each maintainer)
    email: The maintainers email (optional for each maintainer)
    url: A URL for the maintainer (optional for each maintainer)
icon: A URL to an SVG or PNG image to be used as an icon (optional).
appVersion: The version of the app that this contains (optional). Needn't be SemVer. Quotes recommended.
deprecated: Whether this chart is deprecated (optional, boolean)
annotations:
  example: A list of annotations keyed by name (optional).
```
## Declarative
First of all you have to create a HELM project by this command:

`helm create helmrollout`

You can install Helm charts through the UI, or in the declarative GitOps way.
Helm is only used to inflate charts with helm template. The lifecycle of the application is handled by Argo CD instead of Helm. Here is an example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sealed-secrets
  namespace: argocd
spec:
  project: default
  source:
    chart: sealed-secrets
    repoURL: https://bitnami-labs.github.io/sealed-secrets
    targetRevision: 1.16.1
    helm:
      releaseName: sealed-secrets
  destination:
    server: "https://kubernetes.default.svc"
    namespace: kubeseal


## OR


    source:
    repoURL: https://github.com/ghalamif/faps.git
    targetRevision: HEAD
    path: helm/helmrollout
    helm:
      #releaseName: sealed-secrets
      valueFiles:
        - values.yaml
  destination: 
    server: https://kubernetes.default.svc
    namespace: my-helm-app

  syncPolicy:
    syncOptions:
      - CreateNamespace=true

    automated:
      selfHeal: true
      prune: true
```
## Values Files¶

Helm has the ability to use a different, or even multiple "values.yaml" files to derive its parameters from. 
In the declarative syntax:
```yaml
source:
  helm:
    valueFiles:
    - values-production.yaml
```


## HOW To
## Quote Strings, Don't Quote Integers
When you are working with string data, you are always safer quoting the strings than leaving them as bare words:
```helm
name: {{ .Values.MyName | quote }}
````
## Using the 'include' Function
