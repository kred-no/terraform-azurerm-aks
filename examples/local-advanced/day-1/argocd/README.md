# ARGO-CD

## Commands

```bash
# Deploy
kubectl kustomize --enable-helm ./ | kubectl apply --filename -

# Retrieve initial password
kubectl -n argocd get secret argocd-initial-admin-secret --template="{{ .data.password | base64decode }}"

# Forward UI
kubectl -n argocd port-forward svc/v1-argocd-server 5080:80

# Destroy
kubectl kustomize --enable-helm ./ | kubectl apply --filename -
```
