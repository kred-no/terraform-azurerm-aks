# terraform-azurerm-aks

Deploy an Azure Kubernetes Service solution (with private API), using Terraform

See 'examples' folder for working examples

## Documentation

* [Official 'Azure Kubernetes Service (AKS)' documentation](https://learn.microsoft.com/en-us/azure/aks/)

## Access Cluster (public)

```bash
# Install CLI binary (note: Azure AD + Azure RBAC requires 'kubelogin' as well)
az aks install-cli

# Get credentials
az aks get-credentials --resource-group "<ResourceGroup>" --name "<ClusterName>"

# List Nodes
kubectl get nodes

# List Pods in all Namespaces
kubectl get pods -A
```
