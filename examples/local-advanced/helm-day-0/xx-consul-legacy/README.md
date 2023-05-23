# HASHICORP CONSUL

  * https://developer.hashicorp.com/consul/docs/k8s/installation/install
  * https://github.com/hashicorp/consul-k8s/tree/main/charts/consul
  * https://developer.hashicorp.com/consul/docs/k8s/connect/ingress-controllers

## Deployment

```bash
# Deploy
kubectl kustomize --enable-helm consul/ | kubectl apply --filename -

# Destroy
kubectl kustomize --enable-helm consul/ | kubectl delete --filename -

# Port-Forward UI to localhost (TLS enabled)
kubectl port-forward svc/consul-ui 8443:443 -n consul
```

## ACL Bootstrap Token

```bash
# Retrieve & Decode using Linux Shell
kubectl -n consul get secret consul-bootstrap-acl-token --template="{{.data.token}}"|base64 -d
```

```powershell
# Retrieve & Decode using Windows PowerShell

# Multiple lines
$token = $(kubectl -n consul get secret consul-bootstrap-acl-token --template="{{.data.token}}")
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token))

# Single line
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($(kubectl -n consul get secret consul-bootstrap-acl-token --template="{{.data.token}}")))
```