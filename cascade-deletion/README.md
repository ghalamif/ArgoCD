<!-- Report note: describes cascade vs non-cascade deletion and finalizers. -->
# App Deletion Using ArgoCD:

Apps can be deleted with or without a cascade option. A cascade delete, deletes both the app and its resources, rather than only the app.

## Deletion Using argocd

To perform a non-cascade delete:
```bash
argocd app delete APPNAME --cascade=false
```
To perform a cascade delete:
```bash
argocd app delete APPNAME --cascade
```
or
```bash
argocd app delete APPNAME
```


About The Deletion Finalizer

```yaml
metadata:
  finalizers:
    # The default behaviour is foreground cascading      #   deletion you can add /background to the taile
    - resources-finalizer.argocd.argoproj.io
```
When deleting an Application with this finalizer, the Argo CD application controller will perform a cascading delete of the Application's resources.


## NOTE:

 **Common Problem:**

When the argocd app is on sync error: “source revision is not found” “source path is not found” … the finalizer will block deletion.
So basically, you cannot remove bad argocd app!

The solution

```bash
kubectl patch some-resource/some-name \
    --type json \
    --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'
```
