<!-- Report note: explains Argo CD hooks and hook types. -->
# HOOKS

Hooks are ways to run scripts before, during, and after a Sync operation.
Hooks can also be run if a Sync operation fails at any point.
- Using a **PreSync** hook to perform a **database schema migration** before deploying a new version of the app.
- Using a **Sync** hook to orchestrate a complex deployment requiring more sophistication than the Kubernetes rolling update strategy.
- Using a **PostSync** hook to **run integration and health checks after a deployment**.
- Using a **SyncFail** hook to run clean-up or finalizer logic if a Sync operation fails. SyncFail hooks are only available starting in v1.2
Usage¶
Hooks are simply Kubernetes manifests tracked in the source repository of your Argo CD Application annotated with **argocd.argoproj.io/hook**, e.g.:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  generateName: schema-migrate-
  annotations:
    argocd.argoproj.io/hook: PreSync
```

## NOTE:
**Hooks can be any type of Kubernetes resource** kind, but tend to be **Pod, Job or Argo Workflows.** Multiple hooks can be specified as a comma separated list.

**Jobs** support the **ttlSecondsAfterFinished** field in the spec, which let their respective controllers **delete the Job after it completes**. **Argo Workflows** support a **ttlStrategyproperty** that also allow a Workflow to be cleaned up depending on the ttl strategy chosen.
In the context of **Kubernetes** and **Argo Workflows**, the **ttlSecondsAfterFinished** parameter is used to set a **time-to-live (TTL)** duration for a finished workflow. This parameter allows you to specify **the maximum amount of time, in seconds, that the workflow's resources (such as pods and associated objects**) should be retained after the workflow has completed.

can lead to Applications being **OutOfSync**. This is **because** Argo CD will detect a difference between the Job or Workflow defined in the git repository and what's on the cluster since the ttl properties cause deletion of the resource after completion.




## NOTE:
Using **deletion hooks** instead of the **ttl** approaches mentioned above will prevent Applications from having a status of **OutOfSync** even though the **Job or Workflow** was **deleted after completion**.


You can also have the **hooks be deleted** after a successful/unsuccessful run.
- **HookSucceeded** - The resource will be deleted after it has succeeded.
- **HookFailed** - The resource will be deleted if it has failed.
- **BeforeHookCreation** - The resource will be deleted before a new one is created (when a new sync is triggered).
