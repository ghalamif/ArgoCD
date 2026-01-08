# ArgoCD Hooks Application

## Overview

This directory contains a complete Kubernetes application that demonstrates the use of **ArgoCD Hooks** for automated post-deployment notifications. The application showcases how to integrate lifecycle hooks into your GitOps workflow, enabling automated actions at specific points during the deployment process.

ArgoCD hooks are Kubernetes resources that are executed at specific points in the application lifecycle, such as before synchronization (PreSync), during synchronization (Sync), after synchronization (PostSync), or when synchronization fails (SyncFail). This implementation focuses on PostSync hooks to send notifications after successful deployment.

## Architecture Components

The application consists of five main components working together to demonstrate a complete deployment scenario with secrets management and automated notifications:

### 1. **Deployment** (`deployment.yaml`)
The core application deployment running NGINX web servers with sealed secret integration.

### 2. **Service** (`service.yaml`)
Network service exposing the application internally within the cluster.

### 3. **Sealed Secrets** (`sealed-secrets.yaml` and `sealed-secretss.yaml`)
Encrypted secret resources for secure token storage.

### 4. **PostSync Hook Job** (`job.yaml`)
An ArgoCD hook that executes after successful deployment to send Slack notifications.

---

## Detailed Component Analysis

### 1. Deployment Configuration (`deployment.yaml`)

**Purpose:** Deploys the main application as a stateless workload with 2 replicas.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argo-hooks-deployment
spec:
  replicas: 2
```

**Key Features:**

- **Replicas:** Runs 2 instances for high availability and load distribution
- **Container Image:** Uses `nginx:1.23.4` as the application server
- **Resource Limits:** 
  - Memory: 26Mi (optimal for lightweight nginx)
  - CPU: 5m (5 millicores for minimal resource consumption)
- **Secret Integration:** Injects the Slack API token from SealedSecret as an environment variable
  ```yaml
  env:
    - name: TOKEN
      valueFrom:
        secretKeyRef:
          name: secretss
          key: token
  ```
- **Port Configuration:** Exposes port 80 for HTTP traffic
- **Label Selector:** Uses `app: argo-hooks` for service discovery and pod selection

**Why This Configuration?**
- The deployment uses minimal resource limits to demonstrate efficient resource utilization
- Environment variable injection from secrets ensures secure credential management
- Multiple replicas provide fault tolerance during updates

---

### 2. Service Configuration (`service.yaml`)

**Purpose:** Provides stable network endpoint for accessing the deployed application within the cluster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: argo-hooks-service
spec:
  selector:
    app: argo-hooks
  ports:
    - port: 3200
      targetPort: 80
```

**Key Features:**

- **Service Type:** ClusterIP (default, commented LoadBalancer shows alternative option)
- **Port Mapping:** 
  - External port: 3200 (cluster-internal access point)
  - Target port: 80 (nginx container port)
- **Selector:** Routes traffic to pods with label `app: argo-hooks`
- **Commented Options:** LoadBalancer type and NodePort (30020) available for external access

**Why This Configuration?**
- ClusterIP provides internal-only access, suitable for applications not requiring external exposure
- Port 3200 demonstrates custom port mapping while nginx listens on standard port 80
- The commented LoadBalancer and NodePort options show deployment flexibility

---

### 3. Sealed Secrets (`sealed-secrets.yaml` and `sealed-secretss.yaml`)

**Purpose:** Securely store encrypted Slack API tokens that can be safely committed to Git repositories.

#### sealed-secrets.yaml
```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: secrets
  namespace: my-argo-hooks-app
```

#### sealed-secretss.yaml
```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: secretss  # Note: Different name (extra 's')
  namespace: my-argo-hooks-app
```

**Key Features:**

- **Encryption:** Uses Bitnami Sealed Secrets controller for asymmetric encryption
- **Namespace:** Both secrets belong to `my-argo-hooks-app` namespace
- **Encrypted Data:** Contains encrypted `token` field for Slack API authentication
- **Template Type:** Opaque secret type (generic key-value storage)
- **Dual Secrets:** Two separate sealed secrets (potentially for different environments or backup)

**How Sealed Secrets Work:**

1. The Sealed Secrets controller running in the cluster has a private key
2. Developers encrypt secrets using the controller's public key
3. Encrypted secrets can be safely stored in Git
4. Upon deployment, the controller decrypts them into standard Kubernetes Secrets
5. Applications (deployment and job) consume the decrypted secrets

**Why This Approach?**
- Enables GitOps workflow without exposing sensitive data
- Only the cluster with the private key can decrypt the secrets
- Provides audit trail for secret management through Git history
- The naming difference (`secrets` vs `secretss`) suggests the active secret is `secretss` which is referenced in both deployment and job

---

### 4. PostSync Hook Job (`job.yaml`)

**Purpose:** Automated Slack notification job that executes after successful ArgoCD synchronization.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  generateName: app-slack-notification-
  namespace: my-argo-hooks-app
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
```

**Key Features:**

**ArgoCD Hook Annotations:**
- `argocd.argoproj.io/hook: PostSync` - Executes after successful sync
- `argocd.argoproj.io/hook-delete-policy: HookSucceeded` - Auto-deletes after successful completion

**Job Configuration:**
- **GenerateName:** Creates unique job instances with prefix `app-slack-notification-`
- **RestartPolicy:** Never (one-time execution)
- **BackoffLimit:** 2 (allows up to 2 retry attempts on failure)

**Container Configuration:**
```yaml
containers:
- name: slack-notification
  image: nginx:1.23.4
  env:
    - name: TOKEN
      valueFrom:
        secretKeyRef:
          name: secretss
          key: token
```

**Notification Logic:**
```bash
command:
  - "sh"
  - "-c"
  - |
    echo $TOKEN
    curl -X POST \
    -H 'Authorization: Bearer $TOKEN' \
    -H 'Content-Type: application/json; charset=utf-8' \
    --data '{"channel":"#faps-channel","text":"it is synched"}' \
    https://slack.com/api/chat.postMessage
```

**How It Works:**

1. **Trigger:** ArgoCD executes this job after successfully syncing the application
2. **Authentication:** Retrieves Slack token from the `secretss` secret
3. **Notification:** Sends HTTP POST request to Slack API
   - **Endpoint:** `https://slack.com/api/chat.postMessage`
   - **Channel:** `#faps-channel`
   - **Message:** "it is synched"
   - **Authorization:** Bearer token from sealed secret
4. **Cleanup:** Job is automatically deleted after successful completion
5. **Retry Logic:** If the notification fails, the job retries up to 2 times

**Why This Implementation?**
- PostSync hook ensures notifications only occur after successful deployments
- Auto-deletion keeps the cluster clean and prevents job accumulation
- Retry mechanism handles transient network issues
- Using nginx image with curl demonstrates flexibility (production would use a dedicated notification image)
- The echo statement logs the token for debugging (should be removed in production for security)

---

## Application Workflow

### Complete Deployment Lifecycle

```
1. Git Push → ArgoCD Detects Changes
         ↓
2. ArgoCD Syncs Resources (PreSync hooks if any)
         ↓
3. Deployment & Service Created
         ↓
4. Sealed Secrets Decrypted → Kubernetes Secrets Created
         ↓
5. Pods Start with Injected Secrets
         ↓
6. PostSync Hook Job Triggered
         ↓
7. Slack Notification Sent
         ↓
8. Hook Job Auto-Deleted
         ↓
9. Application Running & Notification Delivered
```

### Resource Dependencies

```
sealed-secretss.yaml
         ↓ (provides token)
    +-----------+-----------+
    ↓                       ↓
deployment.yaml        job.yaml
    ↓                  (PostSync Hook)
service.yaml
```

---

## Deployment Instructions

### Prerequisites

1. **ArgoCD Installed:** ArgoCD must be running in your Kubernetes cluster
2. **Sealed Secrets Controller:** Install Bitnami Sealed Secrets controller
   ```bash
   kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
   ```
3. **Namespace:** Create the application namespace
   ```bash
   kubectl create namespace my-argo-hooks-app
   ```
4. **Slack Token:** Obtain a Slack Bot OAuth token with `chat:write` permission

### Setup Steps

#### 1. Create and Seal Your Slack Token

```bash
# Create a regular secret (not committed to Git)
kubectl create secret generic secretss \
  --from-literal=token=xoxb-your-actual-slack-token \
  --namespace=my-argo-hooks-app \
  --dry-run=client -o yaml > secret.yaml

# Seal the secret
kubeseal --format=yaml < secret.yaml > sealed-secretss.yaml

# Update the sealed-secretss.yaml in this directory with your sealed secret
# Delete the unencrypted secret.yaml file
rm secret.yaml
```

#### 2. Deploy via ArgoCD

Create an ArgoCD Application resource:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argo-hooks-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <your-repo-url>
    targetRevision: HEAD
    path: argo-hooks
  destination:
    server: https://kubernetes.default.svc
    namespace: my-argo-hooks-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

#### 3. Apply and Sync

```bash
# Apply the ArgoCD application
kubectl apply -f application.yaml

# Or sync via CLI
argocd app sync argo-hooks-app
```

### Verification

```bash
# Check deployment status
kubectl get deployments -n my-argo-hooks-app

# Check pods
kubectl get pods -n my-argo-hooks-app

# Check service
kubectl get svc -n my-argo-hooks-app

# Check if hook job was created and completed
kubectl get jobs -n my-argo-hooks-app

# Check ArgoCD application status
argocd app get argo-hooks-app

# Verify Slack channel for notification message
```

---

## Configuration Customization

### Modify Notification Channel

Edit `job.yaml` line 29:
```yaml
--data '{"channel":"#your-channel","text":"your message"}' \
```

### Change Deployment Replicas

Edit `deployment.yaml` line 6:
```yaml
replicas: 3  # Change to desired number
```

### Adjust Resource Limits

Edit `deployment.yaml` lines 24-27:
```yaml
resources:
  limits:
    memory: "128Mi"  # Increase if needed
    cpu: "100m"      # Increase if needed
```

### Enable External Access

Uncomment LoadBalancer in `service.yaml` lines 6 and 12:
```yaml
type: LoadBalancer
nodePort: 30020
```

---

## Security Considerations

### Current Implementation

- ✅ Secrets encrypted with Sealed Secrets
- ✅ Token injection via environment variables
- ⚠️ Token echoed to logs (debug purpose only)
- ⚠️ No RBAC policies defined

### Production Recommendations

1. **Remove Token Logging:** Delete line 25 in `job.yaml` (`echo $TOKEN`)
2. **Use Dedicated Image:** Replace nginx with a purpose-built notification image
3. **Network Policies:** Restrict pod-to-pod communication
4. **RBAC:** Implement role-based access control
5. **Secret Rotation:** Regularly rotate Slack tokens
6. **Monitor Hook Execution:** Set up alerts for hook failures

---

## Troubleshooting

### Job Fails to Send Notification

**Check job logs:**
```bash
kubectl logs -n my-argo-hooks-app -l job-name=app-slack-notification-<id>
```

**Common issues:**
- Invalid Slack token (check sealed secret decryption)
- Wrong channel name
- Missing Slack bot permissions
- Network connectivity issues

### Deployment Pods Not Starting

**Check pod events:**
```bash
kubectl describe pod <pod-name> -n my-argo-hooks-app
```

**Common issues:**
- Secret `secretss` not found (sealed secret not decrypted)
- Resource quota exceeded
- Image pull errors

### Hook Not Executing

**Verify ArgoCD sync:**
```bash
argocd app get argo-hooks-app --show-operation
```

**Common issues:**
- Sync failed before PostSync phase
- Hook annotation typo
- Namespace mismatch

---

## Advanced Usage

### Multiple Hook Types

You can add additional hooks for different lifecycle phases:

```yaml
# PreSync hook - runs before deployment
annotations:
  argocd.argoproj.io/hook: PreSync
  
# Sync hook - runs during deployment
annotations:
  argocd.argoproj.io/hook: Sync
  
# SyncFail hook - runs if sync fails
annotations:
  argocd.argoproj.io/hook: SyncFail
```

### Hook Deletion Policies

```yaml
# Keep hook resources after execution
argocd.argoproj.io/hook-delete-policy: Never

# Delete on success or failure
argocd.argoproj.io/hook-delete-policy: HookSucceeded, HookFailed

# Delete before new hook execution
argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
```

### Hook Execution Order

Use weight annotations to control execution sequence:

```yaml
annotations:
  argocd.argoproj.io/hook: PostSync
  argocd.argoproj.io/sync-wave: "1"  # Lower numbers execute first
```

---

## Learning Outcomes

This example demonstrates:

1. **GitOps Principles:** Declarative configuration with Git as source of truth
2. **Secrets Management:** Secure handling of sensitive data in GitOps workflows
3. **Lifecycle Hooks:** Automating tasks at specific deployment phases
4. **Resource Optimization:** Efficient resource allocation for microservices
5. **Service Discovery:** Kubernetes service and label-based routing
6. **Job Patterns:** One-time task execution with retry logic
7. **Integration Patterns:** External API integration from Kubernetes

---

## References

- [ArgoCD Hooks Documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/resource_hooks/)
- [Sealed Secrets GitHub](https://github.com/bitnami-labs/sealed-secrets)
- [Slack API Documentation](https://api.slack.com/methods/chat.postMessage)
- [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

---

## Contributing

This is a demonstration project for educational purposes. Improvements and suggestions are welcome:

- Enhance security practices
- Add additional hook examples
- Improve error handling
- Add monitoring and observability

---

## License

This project follows the main repository license.

---

**Author:** Fatemeh Ghalami  
**Institution:** Friedrich-Alexander-Universität Erlangen-Nürnberg (FAU)  
**Project:** MLOps with GitOps - ArgoCD Integration  
**Last Updated:** January 2026
