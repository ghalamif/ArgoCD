content source: argocd image updater [Github](https://github.com/argoproj-labs/argocd-image-updater/tree/master/docs) page
# Argo Image Updater
![Blank document-4](https://github.com/ghalamif/ArgoCD/assets/9778511/e2625162-f95d-4013-9d52-2f510d048efb)
## Introduction

Argo CD Image Updater is a tool to automatically update the container images of Kubernetes workloads which are managed by Argo CD. In a nutshell, it will track image versions specified by annotations on the Argo CD Application resources and update them by setting parameter overrides using the Argo CD API.

Currently, it will only work with applications that are built using Kustomize or Helm tooling. Applications built from plain YAML or custom tools are not supported yet (and maybe never will).

# Update strategies

## Supported update strategies

An update strategy defines how Argo CD Image Updater will find new versions of
an image that is to be updated.

Argo CD Image Updater supports different update strategies for the images that
are configured to be tracked and updated.

You can configure the update strategy to be used for each image individually,
with the default being the `semver` strategy.

The following update strategies are currently supported:

* **semver** - Update to the latest version of an image considering semantic versioning constraints
* **latest/newest-build** - Update to the most recently built image found in a registry
* **digest - Update** to the latest version of a given version (tag), using the tag's SHA digest
* **name/alphabetical** - Sorts tags alphabetically and update to the one with the highest cardinality

**!!!warning** "Renamed image update strategies
    The `latest` strategy has been renamed to `newest-build`, and `name` strategy has been renamed to `alphabetical`. 
    Please switch to the new convention as support for the old naming convention will be removed in future releases.

# Update methods

## Overview

Argo CD Image Updater supports several methods to propagate new versions of the
images to Argo CD. These methods are also referred to as *write-back methods*.

Currently, the following methods are supported:

* **argocd**
  directly modifies the Argo CD *Application* resource, either using Kubernetes
  or via Argo CD API, depending on Argo CD Image Updater's configuration.

* **git**
  will create a Git commit in your Application's Git repository that holds the
  information about the image to update to.

Depending on the write back method, further configuration may be possible.

The write back method and its configuration is specified per Application.

## write-back method

When using the Argo CD API to write back changes, Argo CD Image Updater will
perform a similar action as `argocd app set --parameter ...` to instruct
Argo CD to re-render the manifests using those parameters.

This method is pseudo-persistent. If you delete the `Application` resource
from the cluster and re-create it, changes made by Image Updater will be gone.
The same is true if you manage your `Application` resources using Git, and
the version stored in Git is synced over the resource in the cluster. This
method is most suitable for Applications also created imperatively, i.e.
using the Web UI or CLI.

This method is the default and requires no further configuration.

## write-back method

!!!warning "Compatibility with Argo CD"
    The Git write-back method requires a feature in Argo CD that has been
    introduced with Argo CD v2.0. Git write-back will not work with earlier
    versions of Argo CD.

The `git` write-back method uses Git to permanently store its parameter
overrides along with the Application's resource manifests. This will enable
persistent storage of the parameters in Git.

By default, Argo CD Image Updater will store the parameter in a file named
`.argocd-source-<appName>.yaml` in the path used by the Application to source
its manifests from. This will allow Argo CD to pick up parameters in this
file, when rendering manifests for the Application named `<appName>`. Using
this approach will also minimize the possibility of merge conflicts, as long
as no other party in your CI will modify this file.
To use the Git write-back method, annotate your `Application` with the right
write-back method:

```yaml
argocd-image-updater.argoproj.io/write-back-method: git
```

## Allowing an image for update

The most simple form of specifying an image allowed to update would be the
following:

```yaml
argocd-image-updater.argoproj.io/image-list: nginx
```

The above example would specify to update the image `nginx` to it's most recent
version found in the container registry, without taking any version constraints
into consideration.

This is most likely not what you want, because you could pull in some breaking
changes when `nginx` releases a new major version and the image gets updated.
So you can give a version constraint along with the image specification:

```yaml
argocd-image-updater.argoproj.io/image-list: nginx:~1.26
```

The above example would allow the `nginx` image to be updated to any patch
version within the `1.26` minor release.

## Custom images with Kustomize 

In Kustomize, if you want to use an image from another registry or a completely
different image than what is specified in the manifests, you can give the image
specification as follows.

First of all, you will have to set up an `image_alias` for your image so you
are able to provide additional configuration for it:

```yaml
argocd-image-updater.argoproj.io/image-list: <image_alias>=<image_name>:<image_tag>
```

In this case, `image_name` should be the name of the image that you want to 
update to, rather than the currently running image.

To provide the original image name, you need to set the `kustomize.image-name`
annotation to the original image's name, as follows:

```yaml
argocd-image-updater.argoproj.io/<image_alias>.kustomize.image-name: <original_image_name>
```

Let's take Argo CD's Kustomize base as an example: The original image used by
Argo CD is `quay.io/argoproj/argocd`, pulled from Quay container registry. If
you want to follow the latest builds, as published on the GitHub registry, you
could override the image specification in Kustomize as follows:

```yaml
argocd-image-updater.argoproj.io/image-list: argocd=ghcr.io/argoproj/argocd
argocd-image-updater.argoproj.io/argocd.kustomize.image-name: quay.io/argoproj/argocd
```

Under the hood, this would be similar to the following kustomize command:

```shell
kustomize edit set image quay.io/argoproj/argocd=ghcr.io/argoproj/argocd
```

Finally, if you have not yet overridden the image name in your manifests (i.e.
there's no image `ghcr.io/argoproj/argocd` running in your application, you
may need to tell Image Updater to force the update despite no image is running:

```yaml
argocd-image-updater.argoproj.io/argocd.force-update: true
```
## Specifying Helm parameter names

In case of Helm applications which contain more than one image in the manifests
or use another set of parameters than `image.name` and `image.tag` to define
which image to render in the manifests, you need to set an `<image_alias>`
in the image specification to define an alias for that image, and then
use another set of annotations to specify the appropriate parameter names
that should get set if an image gets updated.

For example, if you have an image `quay.io/dexidp/dex` that is configured in
your helm chart using the `dex.image.name` and `dex.image.tag` Helm parameters,
you can set the following annotations on your `Application` resource so that
Argo CD Image Updater will know which Helm parameters to set:

```yaml
argocd-image-updater.argoproj.io/image-list: dex=quay.io/dexidp/dex
argocd-image-updater.argoproj.io/dex.helm.image-name: dex.image.name
argocd-image-updater.argoproj.io/dex.helm.image-tag: dex.image.tag

```

The general syntax for the two Helm-specific annotations is:

```yaml
argocd-image-updater.argoproj.io/<image_alias>.helm.image-name: <name of helm parameter to set for the image name>
argocd-image-updater.argoproj.io/<image_alias>.helm.image-tag: <name of helm parameter to set for the image tag>
```

If the chart uses a parameter for the canonical name of the image (i.e. image
name and tag combined), a third option can be used:

```yaml
argocd-image-updater.argoproj.io/<image_alias>.helm.image-spec: <name of helm parameter to set for the canonical name of image>
```

If the `<image_alias>.helm.image-spec` annotation is set, the two other
annotations `<image_alias>.helm.image-name` and `<image_alias>.helm.image-tag`
will be ignored.
