# Install Helm Charts

* https://kubernetes.io/docs/reference/kubectl/
* https://kubernetes.io/docs/reference/kubectl/cheatsheet/

## Helm Installation
```powershell
# Add Chart
helm repo add traefik https://traefik.github.io/charts

# Deploy
helm -f values.yaml install traefik traefik/traefik
```
## Kustomize Helm Installation

  * "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"
  * "https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/"

```powershell
# Create resources
kubectl kustomize --enable-helm <DIR> | kubectl apply --filename -

# Cleanup resources
kubectl kustomize --enable-helm <DIR> | kubectl delete --filename -
```
