# Install Helm Charts

* https://kubernetes.io/docs/reference/kubectl/
* https://kubernetes.io/docs/reference/kubectl/cheatsheet/

```bash
# Deploy Required Consul CRDs for Gateway API
kubectl apply --kustomize="github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.5.4"

# Deploy Prometheus Services
kubectl kustomize --enable-helm ./day-0/02-prometheus/ | kubectl -n prometheus-system apply --filename -

# Deploy Consul Services to 'consul-system' namespace
kubectl kustomize --enable-helm ./day-0/00-consul/overlays/v1.1.1 | kubectl -n consul-system apply --filename -
kubectl wait -n consul-system --for=condition=ready pod --selector=app=consul --timeout=90s

# Deploy Consul API Gateway (Wait for 'GatewayClass')
kubectl kustomize --enable-helm ./day-0/01-consul-api-gateway/overlays/v1.15.1 | kubectl -n consul-system apply --filename -

# Optional: Login to Consul UI
kubectl -n consul-system get secret consul-bootstrap-acl-token --template="{{ .data.token | base64decode }}"
kubectl -n consul-system port-forward svc/consul-ui 8501:443

# Deploy Example Gateway & Services
kubectl kustomize --enable-helm ./day-1/two-services/overlays/consul | kubectl -n default apply --filename -

# Cleanup All
kubectl kustomize --enable-helm ./day-1/two-services/overlays/consul | kubectl -n default delete --filename -
kubectl kustomize --enable-helm ./day-0/02-prometheus/ | kubectl -n prometheus-system delete --filename -
kubectl kustomize --enable-helm ./day-0/01-consul-api-gateway/overlays/v1.15.1 | kubectl -n consul-system delete --filename -
kubectl kustomize --enable-helm ./day-0/00-consul/overlays/v1.1.1 | kubectl -n consul-system delete --filename -
kubectl delete --kustomize="github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.5.4"
```

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
kubectl kustomize --enable-helm <DIR> | kubectl -n <NAMESPACE> apply --filename -

# Cleanup resources
kubectl kustomize --enable-helm <DIR> | kubectl -n <NAMESPACE> delete --filename -
```

## Debugging

```bash
# Create/Run interactive ephemeral container
kubectl run deleteme --rm -i --tty --image=alpine:latest --restart=Never -- ash
```