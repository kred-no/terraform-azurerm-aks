# CERT-MANAGER

  * https://cert-manager.io/docs/installation/helm/
  * https://artifacthub.io/packages/helm/cert-manager/cert-manager
  * https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml

## Commands
```bash
# Deploy
kubectl kustomize --enable-helm cert-manager/ | kubectl apply --filename -

# Destroy
kubectl kustomize --enable-helm cert-manager/ | kubectl delete --filename -

# Port-Forward UI to localhost
#kubectl port-forward svc/v1-vault-ui 8200:8200 -n vault
```