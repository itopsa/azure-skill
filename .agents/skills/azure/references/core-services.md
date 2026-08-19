# Azure Core Services CLI Reference

This reference covers the most common Azure CLI commands organized by domain service.

---

## 1. Resource Groups & Management

```bash
# List all resource groups
az group list -o table

# Create a resource group
az group create --name <rg-name> --location <region> --tags Environment=Dev Project=App

# Show details of a resource group
az group show --name <rg-name> -o json

# Delete a resource group (CAUTION: Destructive)
az group delete --name <rg-name> --no-wait --yes
```

---

## 2. Compute Services

### Azure Container Apps (ACA)
```bash
# List container app environments
az containerapp env list -o table

# List apps in a resource group
az containerapp list --resource-group <rg-name> -o table

# Show app logs in real time
az containerapp logs show --name <app-name> --resource-group <rg-name> --follow

# Deploy/update container image
az containerapp update \
  --name <app-name> \
  --resource-group <rg-name> \
  --image <acr-name>.azurecr.io/<image>:<tag>
```

### Azure Kubernetes Service (AKS)
```bash
# List AKS clusters
az aks list -o table

# Get AKS credentials for kubectl
az aks get-credentials --resource-group <rg-name> --name <cluster-name> --overwrite-existing

# Check cluster upgrade status
az aks get-upgrades --resource-group <rg-name> --name <cluster-name> -o table

# Scale node pool
az aks nodepool scale --resource-group <rg-name> --cluster-name <cluster-name> --name <nodepool-name> --node-count <count>
```

### Azure App Service & Functions
```bash
# List App Service web apps
az webapp list -o table

# Restart a web app
az webapp restart --name <app-name> --resource-group <rg-name>

# Stream live web app logs
az webapp log tail --name <app-name> --resource-group <rg-name>

# List Function Apps
az functionapp list -o table

# Get Function App app settings
az functionapp config appsettings list --name <app-name> --resource-group <rg-name> -o table
```

---

## 3. Storage & Data

### Azure Storage (Blob, File, Queue)
```bash
# List storage accounts
az storage account list -o table

# List containers in a storage account (using Azure AD auth)
az storage container list --account-name <storage-acct> --auth-mode login -o table

# Upload a file to blob storage
az storage blob upload \
  --account-name <storage-acct> \
  --container-name <container-name> \
  --name <blob-name> \
  --file <local-path> \
  --auth-mode login

# Download a blob
az storage blob download \
  --account-name <storage-acct> \
  --container-name <container-name> \
  --name <blob-name> \
  --file <destination-path> \
  --auth-mode login
```

### Azure Cosmos DB
```bash
# List Cosmos DB accounts
az cosmosdb list -o table

# List SQL databases in an account
az cosmosdb sql database list --account-name <account-name> --resource-group <rg-name> -o table

# Show connection strings (sensitive)
az cosmosdb keys list --name <account-name> --resource-group <rg-name> --type connection-strings -o json
```

### Azure Database for PostgreSQL (Flexible Server)
```bash
# List PostgreSQL servers
az postgres flexible-server list -o table

# Show server status and connection info
az postgres flexible-server show --name <server-name> --resource-group <rg-name> -o json

# Restart server
az postgres flexible-server restart --name <server-name> --resource-group <rg-name>
```

---

## 4. Networking

```bash
# List Virtual Networks (VNets)
az network vnet list -o table

# List Subnets in a VNet
az network vnet subnet list --resource-group <rg-name> --vnet-name <vnet-name> -o table

# List Network Security Groups (NSGs)
az network nsg list -o table

# List effective security rules for a network interface
az network nic list-effective-nsg --resource-group <rg-name> --name <nic-name> -o table

# Check private endpoints
az network private-endpoint list -o table
```

---

## 5. Generic Resource Queries (`az resource`)

When no dedicated command exists, use the generic resource engine:

```bash
# List all resources tagged with specific key/value
az resource list --tag "Environment=Production" -o table

# List resources by type (e.g. all Redis caches)
az resource list --resource-type "Microsoft.Cache/Redis" -o table

# Execute direct Azure REST API call
az rest --method get --url "https://management.azure.com/subscriptions/{subId}/providers/Microsoft.Compute/virtualMachines?api-version=2023-09-01"
```
