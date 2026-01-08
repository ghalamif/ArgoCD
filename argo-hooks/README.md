<!-- Report note: Argo CD hooks demo with SealedSecret. -->
# Argo Hooks
This folder demonstrates Argo CD hooks and a SealedSecret for a token.

## Project task
- Deploy a small app.
- Run a PostSync Job after the app sync.
- Store the token in a SealedSecret so it is not plain text.

## Files
- `deployment.yaml`: app Deployment that reads a token from a Secret.
- `service.yaml`: Service that exposes the app.
- `job.yaml`: PostSync hook Job that uses the token.
- `sealed-secretss.yaml`: encrypted token data (used by the app and job).

## Setup
Requirements: a Kubernetes cluster, `kubectl`, Argo CD,
and the Sealed Secrets controller installed.

1) Create the namespace:
```bash
kubectl create namespace my-argo-hooks-app
```

2) Apply the SealedSecret (this creates a real Secret at runtime):
```bash
kubectl apply -n my-argo-hooks-app -f argo-hooks/sealed-secretss.yaml
```

3) Apply the Deployment and Service:
```bash
kubectl apply -n my-argo-hooks-app -f argo-hooks/deployment.yaml
kubectl apply -n my-argo-hooks-app -f argo-hooks/service.yaml
```

4) Sync with Argo CD so the hook Job runs:
```bash
kubectl apply -n argocd -f application.yaml
```

## Notes
If you want to change the token, re-seal it with `kubeseal`
and update `argo-hooks/sealed-secretss.yaml`.
