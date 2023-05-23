# HASHICORP VAULT

  * https://developer.hashicorp.com/vault/docs/platform/k8s/helm
  * https://github.com/hashicorp/vault-helm
  * https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-raft-deployment-guide

## Commands
```bash
# Deploy
kubectl kustomize --enable-helm vault/ | kubectl apply --filename -

# Destroy
kubectl kustomize --enable-helm vault/ | kubectl delete --filename -

# Port-Forward UI to localhost
kubectl port-forward svc/v1-vault-ui 8200:8200 -n vault

# Print cert-manager generated certificate
kubectl -n vault get secret vault-tls --template='{{index .data "tls.crt" }}'
```

