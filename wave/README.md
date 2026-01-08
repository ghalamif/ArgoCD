<!-- Report note: describes sync waves and ordering of resources. -->
# Sync Wave
Argo CD introduces the concept of a "sync wave" to regulate the sequence of resource synchronization (deployment) when performing an application sync operation. By default, Argo CD conducts asynchronous deployments, deploying all resources simultaneously, regardless of their order in the Git repository.

However, there are scenarios where controlling the order of resource deployment becomes crucial. For instance, you might need to ensure that a database is deployed and ready before deploying an application dependent on that database. This is where sync waves play a crucial role.

Each resource can be assigned a sync wave number through its annotation. Resources with lower sync wave numbers will deploy before those with higher sync wave numbers. Resources within the same sync wave are deployed concurrently. To illustrate, consider the following example:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-10"
  name: staging
```

In this case, the Namespace "staging" will deploy before other resources with sync wave numbers higher than -10. If no sync wave is assigned to a resource, it defaults to 0. The use of negative numbers ensures specific resources are deployed first.

The process of configuring a sync wave is straightforward; simply add the appropriate annotation in the manifest, as demonstrated in the example:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "3"
```

This annotation assigns a sync wave number of 3 to the respective resource.
