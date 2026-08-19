# Azure IaC & Deployments Reference

This reference covers deploying and validating Infrastructure as Code using Bicep, ARM, and `azd` (Azure Developer CLI).

---

## 1. Bicep Operations

```bash
# Build/validate Bicep file to ARM template
az bicep build --file main.bicep

# Upgrade Bicep CLI
az bicep upgrade

# Decompile ARM template to Bicep
az bicep decompile --file template.json
```

---

## 2. Azure CLI Resource Group Deployments

### Pre-flight / Dry Run (What-If)
Always run a `what-if` before creating or updating infrastructure to inspect potential drifts or destructive changes:

```bash
az deployment group what-if \
  --resource-group <rg-name> \
  --template-file main.bicep \
  --parameters environment=prod location=eastus
```

### Deploying Templates
```bash
# Deploy with parameters file
az deployment group create \
  --resource-group <rg-name> \
  --name "deploy-$(date +%Y%m%d-%H%M)" \
  --template-file main.bicep \
  --parameters @main.parameters.json

# Check deployment status / history
az deployment group list --resource-group <rg-name> -o table

# Show deployment errors/operations
az deployment group operation list \
  --resource-group <rg-name> \
  --name <deployment-name> \
  --query "[?properties.provisioningState=='Failed'].properties.statusMessage" -o json
```

### Subscription-Level Deployments (Resource Groups, Policies)
```bash
az deployment sub create \
  --location eastus \
  --template-file sub.bicep \
  --parameters location=eastus
```

---

## 3. Azure Developer CLI (`azd`)

`azd` manages end-to-end cloud application lifecycles based on `azure.yaml`:

```bash
# Initialize a new azd project
azd init

# Authenticate azd session
azd auth login

# Check provisioning/deployment status
azd show

# Provision infrastructure (runs Bicep/Terraform)
azd provision

# Deploy application code
azd deploy

# End-to-end package, provision, and deploy
azd up

# Teardown / destroy resources created by azd
azd down --purge
```
