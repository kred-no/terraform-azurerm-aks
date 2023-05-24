```bash
kubectl --namespace consul apply --filename "00-consul-gateway/consul-api.gateway.yaml" && \ 
kubectl --namespace consul wait --for=condition=ready gateway/api-gateway --timeout=90s && \
kubectl --namespace consul apply --filename "00-consul-gateway/consul-api.routes.yaml"
```