# terraform-azurerm-aks

Deploy an Azure Kubernetes Service solution (with private API), using Terraform

## Access Cluster

```bash
# Get credentials
az aks get-credentials --resource-group "<ResourceGroup>" --name "<ClusterName>"

# List Nodes
kubectl get nodes

# List Pods in all Namespaces
kubectl get pods -A
```
