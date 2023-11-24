# My Awesome Project

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

Inside of this directory, Helm will expect a structure that matches this:
```

## HOW To
## Quote Strings, Don't Quote Integers
When you are working with string data, you are always safer quoting the strings than leaving them as bare words:
```helm
name: {{ .Values.MyName | quote }}
````
## Using the 'include' Function
