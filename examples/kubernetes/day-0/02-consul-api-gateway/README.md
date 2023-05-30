# Consul API Gateway

Makes use of the kubernetes Gateway API. Requires the corresponding 'GatewayClass' to be available.
This is managed by the Consul Helm installation.

```bash
kubectl --namespace consul-system apply --filename "00-consul-api-gateway/gateway.yaml" \ 
&& kubectl --namespace consul-system wait --for=condition=ready gateway/api-gateway --timeout=90s \
&& kubectl --namespace consul-system apply --filename "00-consul-api-gateway/consul-api.routes.yaml"
```