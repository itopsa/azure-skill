---
name: azure
description: >-
  Manage, provision, inspect, deploy, and troubleshoot Microsoft Azure cloud resources and Azure DevOps (ADO) using the Azure CLI (az), Azure Developer CLI (azd), Bicep, and Azure REST APIs without requiring an external MCP server. Activate this skill whenever interacting with Azure subscriptions, resource groups, App Services, Container Apps, AKS, Functions, Storage, Cosmos DB, Key Vault, Monitor/Logs, IAM/RBAC, or Azure DevOps pipelines/repos.
---

# Azure Cloud Operations & Management Skill

This skill provides direct, token-efficient, and deterministic management of Microsoft Azure infrastructure, workloads, and Azure DevOps (ADO) using native command-line tools (`az`, `azd`, `bicep`, `az devops`) across Windows, macOS, and Linux.

---

## 1. Workflow Lifecycle & Pre-Flight

Before performing mutations or queries, always confirm environment readiness and active subscription context:

1. **Run Pre-Flight Check**:
   * **Windows (PowerShell)**:
     ```powershell
     .\.agents\skills\azure\scripts\azure_preflight.ps1
     ```
   * **macOS / Linux / Git Bash**:
     ```bash
     ./.agents/skills/azure/scripts/azure_preflight.sh
     ```
   * Or run the quick inline check:
     ```bash
     az account show --output table
     ```

2. **Switch / Select Target Subscription**:
   If the target subscription differs from the active default:
   ```bash
   # List available subscriptions
   az account list --output table

   # Set active subscription by name or ID
   az account set --subscription "<Subscription-Name-or-ID>"
   ```

3. **Check Target Location / Region Availability**:
   ```bash
   az account list-locations --query "[].{DisplayName:displayName, Name:name}" -o table
   ```

---

## 2. CLI Execution & Querying Best Practices

### Output Formatting
* **`-o table`**: Use when displaying human-readable summaries or lists to the user.
* **`-o json`**: Use when programmatically parsing complex nested structures or reading entire resource models.
* **`-o tsv`**: Use when extracting a single scalar string or token for use in variables (e.g. IDs, connection strings, keys).

### JMESPath Filtering (`--query`)
Avoid piping to `grep` or `awk` when `az` can filter natively at the source:

```bash
# Filter resources by prefix or type
az resource list --query "[?contains(name, 'prod')].{Name:name, Type:type, RG:resourceGroup}" -o table

# Extract a specific property value directly
az keyvault show --name <vault-name> --query "properties.vaultUri" -o tsv
```

---

## 3. Safety Guardrails & Operational Protocols

> [!IMPORTANT]
> Always verify the active subscription ID before executing any resource creation, modification, or deletion.

1. **Dry-Run Before Deploying Infrastructure**:
   Always run `what-if` analysis before executing Bicep or ARM deployments:
   ```bash
   az deployment group what-if --resource-group <rg-name> --template-file <file.bicep>
   ```

2. **Destructive Operations (Deletions / Purges)**:
   * **Explicit Confirmation**: Do not execute `az ... delete --yes` without verifying the resource group and resource name first.
   * **Soft-Delete Awareness**: Resources like Key Vaults, App Configuration, and Storage Accounts often have soft-delete enabled. When recreating, check for deleted/purged instances:
     ```bash
     az keyvault list-deleted -o table
     ```

3. **Tagging Standard**:
   Ensure newly provisioned resources include standard organizational tags:
   ```bash
   --tags Environment=<Dev|Staging|Prod> ManagedBy=Antigravity Project=<ProjectName>
   ```

---

## 4. Deep-Dive Domain References

For specific CLI commands, syntax recipes, and workflows by service category, consult the specialized reference guides:

* **[Core Services Reference](./references/core-services.md)**:
  * Resource Groups, Compute (Container Apps, AKS, App Service, Functions), Storage (Blobs, Files), Cosmos DB, PostgreSQL, VNets/NSGs.
* **[IaC & Deployments Reference](./references/iac-deployments.md)**:
  * Bicep compilation, ARM deployments, parameter files, `azd` (Azure Developer CLI) workflows.
* **[Observability & Diagnostics Reference](./references/observability-logs.md)**:
  * Log Analytics KQL queries, App Insights, Resource Health, metric definitions, and live log tailing (`webapp log tail`, `containerapp logs show`).
* **[Security & IAM Reference](./references/security-iam.md)**:
  * RBAC role assignments, System/User Managed Identities, Azure Key Vault secrets, Microsoft Entra ID lookups.
* **[Azure DevOps (ADO) Reference](./references/azure-devops.md)**:
  * Azure Repos, Pull Requests, Azure Pipelines CI/CD triggers, and Azure Boards work items via `az devops`.

---

## 5. Quick Command Cheatsheet

| Task | Command |
| :--- | :--- |
| **Check Active Account** | `az account show -o table` |
| **List Resource Groups** | `az group list -o table` |
| **List All Resources in RG** | `az resource list -g <rg-name> -o table` |
| **Bicep Dry Run** | `az deployment group what-if -g <rg-name> -f <file.bicep>` |
| **Stream App Logs** | `az webapp log tail -g <rg-name> -n <app-name>` |
| **Run KQL Log Query** | `az monitor log-analytics query -w <workspace-id> -q "<kql-query>" -o table` |
| **Get Key Vault Secret** | `az keyvault secret show --vault-name <vault> -n <secret> --query value -o tsv` |
| **List Role Assignments** | `az role assignment list -g <rg-name> -o table` |
| **Run ADO Pipeline** | `az pipelines run --name "<pipeline-name>" --branch main` |
| **List ADO Pull Requests** | `az repos pr list -o table` |
