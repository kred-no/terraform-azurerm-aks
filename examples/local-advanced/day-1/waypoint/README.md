# HASHICORP WAYPOINT

## Commands
```bash
# Deploy
kubectl kustomize --enable-helm waypoint/ | kubectl apply --filename -

# Destroy
kubectl kustomize --enable-helm waypoint/ | kubectl delete --filename -

# Port-Forward UI to localhost (TLS)
kubectl port-forward svc/v1-waypoint-ui 9702:443 -n waypoint
```

## Server Token

```bash
# Retrieve & Decode using Linux Shell
kubectl -n waypoint get secret v1-waypoint-server-token --template="{{.data.token}}"|base64 -d
```

```powershell
# Retrieve & Decode using Windows PowerShell

# Multiple lines
$token = $(kubectl -n waypoint get secret v1-waypoint-server-token --template="{{.data.token}}")
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token))

# Single line
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($(kubectl -n waypoint get secret v1-waypoint-server-token --template="{{.data.token}}")))
```