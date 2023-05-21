# Install Helm Charts

## Helm Installation
```powershell
# Add Chart
helm repo add traefik https://traefik.github.io/charts

# Deploy
helm -f values.yaml install traefik traefik/traefik
```
## Kustomize Helm Installation

  * "https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/"
  * "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"

```powershell
# Create resources
kubectl kustomize --enable-helm <DIR> | kubectl apply --filename -

# Cleanup resources
kubectl kustomize --enable-helm <DIR> | kubectl delete --filename -
```

## Port-Forward Dashboard
```powershell
# Access: http://127.0.0.1:9000/dashboard/
kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000
```

