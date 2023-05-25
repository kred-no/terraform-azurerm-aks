# Consul

  * Provides Service Mesh for securing, monitoring & routing network-traffic.
  * Provides "Gateway" into the kubernetes cluster (Consul API Gateway >> Kubernetes Gateway API).
  * Provides K/V store for centralized configuration-management.

## Kubernetes Gateway API with Consul

  * https://gateway-api.sigs.k8s.io/
  * https://developer.hashicorp.com/consul/docs/api-gateway
  * https://developer.hashicorp.com/consul/docs/api-gateway/install#installation
  * https://github.com/kubernetes-sigs/gateway-api

#### TUTORIAL

  * https://developer.hashicorp.com/consul/tutorials/kubernetes/kubernetes-api-gateway  
  * https://github.com/hashicorp-education/learn-consul-api-gateway


## Install required CRDs

```bash
# Consul API Gateway CRDs
kubectl apply --kustomize="github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.5.4"
kubectl delete --kustomize="github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.5.4"

# Standard channel
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.7.0/standard-install.yaml
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.7.0/standard-install.yaml

# Experimantal channel
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.7.0/experimental-install.yaml
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.7.0/experimental-install.yaml
```