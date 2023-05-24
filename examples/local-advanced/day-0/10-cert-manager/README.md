# CERT-MANAGER

Service for retrieving & managing valid certificates on demand.

## Documentation
  * https://cert-manager.io/docs/installation/helm/
  * https://artifacthub.io/packages/helm/cert-manager/cert-manager
  * https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml
  * https://github.com/jetstack/kustomize-cert-manager-demo.git

## Issues

  * kustomize & custom namespace: https://github.com/cert-manager/cert-manager/pull/3425#issuecomment-719690301

## Gateway API integration

  * [Consul](https://github.com/hashicorp/consul-api-gateway/blob/main/dev/docs/example-setup.md)
  * [Traefik](https://www.jetstack.io/blog/cert-manager-gateway-api-traefik-guide/)
  * [Istio](https://youtu.be/nJUzGJQR3tM)

## Commands

```bash
# Add CRDs (manually)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml

# Deploy
kubectl kustomize --enable-helm "02-cert-manager/" | kubectl apply --filename -

# Create cluster issuer (self-signed)
kubectl apply --filename "02-cert-manager/issuer-cluster-selfsigned.yaml"

# Create namespace issuer (signed by the selfsigned cluster-issuer)
kubectl apply --filename "02-cert-manager/issuer-signed.yaml"

# Destroy/Cleanup
kubectl kustomize --enable-helm "02-cert-manager/" | kubectl delete --filename -
kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
```

```bash
# Validate certificate from file
openssl x509 -in certificate.crt -text -noout

# Validate certificate from stdout
cat certificate.crt | openssl x509 -text -noout
```