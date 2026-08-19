# Azure Security, IAM & Key Vault Reference

This reference covers Role-Based Access Control (RBAC), Managed Identities, and Azure Key Vault secrets/certificates/keys.

---

## 1. Role-Based Access Control (RBAC)

```bash
# List role assignments for a resource group
az role assignment list --resource-group <rg-name> -o table

# List role assignments for a specific user / service principal / SPN
az role assignment list --assignee <user-or-sp-email-or-id> --all -o table

# Assign a role to a principal (e.g. Reader, Contributor)
az role assignment create \
  --assignee <principal-id-or-email> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.Storage/storageAccounts/<acct-name>"

# Delete a role assignment
az role assignment delete \
  --assignee <principal-id-or-email> \
  --role "Contributor" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg-name>"
```

---

## 2. Managed Identities

```bash
# Assign system-assigned identity to a VM or App Service
az webapp identity assign --name <app-name> --resource-group <rg-name>

# Create a user-assigned managed identity
az identity create --name <identity-name> --resource-group <rg-name>

# Show client ID and principal ID of user-assigned identity
az identity show --name <identity-name> --resource-group <rg-name> --query "{clientId:clientId, principalId:principalId}" -o json
```

---

## 3. Azure Key Vault

```bash
# List Key Vaults
az keyvault list -o table

# List secret names in Key Vault
az keyvault secret list --vault-name <vault-name> --query "[].{name:name, enabled:attributes.enabled}" -o table

# Set a secret value
az keyvault secret set --vault-name <vault-name> --name <secret-name> --value <secret-value>

# Retrieve a secret value
az keyvault secret show --vault-name <vault-name> --name <secret-name> --query value -o tsv

# Grant current user or identity access policy (if using vault access policies)
az keyvault set-policy --name <vault-name> --upn <user-email> --secret-permissions get list set
```

---

## 4. Microsoft Entra ID (Azure AD) Quick Lookups

```bash
# Get current signed-in user object ID
az ad signed-in-user show --query id -o tsv

# Find service principal by app name
az ad sp list --display-name <sp-name> --query "[].{appId:appId, id:id, displayName:displayName}" -o json

# Find group by name
az ad group show --group "<group-name>" -o json
```
