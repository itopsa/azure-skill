# GitHub Copilot Instructions — Azure Cloud & Infrastructure

These instructions guide GitHub Copilot when assisting with Microsoft Azure architecture, Infrastructure as Code (Bicep/ARM), CLI scripting, operations, and troubleshooting in this repository.

---

## 1. Core Principles & Tooling

* **CLI & IaC First**: Always provide solutions using the **Azure CLI (`az`)**, **Azure Developer CLI (`azd`)**, or **Bicep** rather than manual Azure Portal clicks.
* **Token Efficiency & Progressive Detail**: Do not generate overly verbose explanations unless asked. Provide executable CLI commands, Bicep definitions, and KQL queries directly.
* **Skill Reference**: Detailed domain runbooks and command cheat sheets are maintained in:
  * [Core Services](file:///.agents/skills/azure/references/core-services.md) (Compute, Storage, DB, Network)
  * [IaC & Deployments](file:///.agents/skills/azure/references/iac-deployments.md) (Bicep, ARM, `azd`)
  * [Observability & Logs](file:///.agents/skills/azure/references/observability-logs.md) (KQL, Log Analytics, Metrics)
  * [Security & IAM](file:///.agents/skills/azure/references/security-iam.md) (RBAC, Key Vault, Identities)

---

## 2. Safety & Operational Guardrails

* **Pre-Flight Validation**:
  * Prior to modifying or querying Azure resources, recommend verifying the active subscription:
    ```bash
    az account show -o table
    ```
  * Or run the automated repository check:
    ```bash
    ./.agents/skills/azure/scripts/azure_preflight.sh
    ```
* **Dry Runs for Infrastructure**:
  * Always suggest running a `what-if` analysis before executing Bicep or ARM deployments:
    ```bash
    az deployment group what-if --resource-group <rg-name> --template-file <file.bicep>
    ```
* **Destructive Command Warnings**:
  * Clearly highlight destructive commands (such as `az group delete`, `az resource delete`, `az keyvault purge`, `azd down --purge`) with a warning to verify the target resource name and resource group before execution.

---

## 3. Azure CLI Output & Query Standards

* **Human Display**: Default to `--output table` (or `-o table`) when listing resources or status for human review.
* **Script / Programmatic Parsing**: Use `--output json` when extracting nested JSON structures.
* **Scalar Extraction**: Use `--output tsv` (or `-o tsv`) with `--query` when extracting IDs, connection strings, or single string tokens:
  ```bash
  az keyvault show --name <vault> --query "properties.vaultUri" -o tsv
  ```
* **JMESPath Filtering**: Prefer native Azure CLI filtering via `--query` rather than piping to `grep`, `awk`, or `jq`.

---

## 4. Azure Resource Naming & Tagging Standards

When authoring Bicep files or running resource creation scripts, apply standard organizational tags:
```bash
--tags Environment=<Dev|Staging|Prod> ManagedBy=Copilot Project=<ProjectName>
```

---

## 5. Quick Command Patterns

| Scenario | Command Pattern |
| :--- | :--- |
| **Switch Subscription** | `az account set --subscription "<Name-or-ID>"` |
| **List Resource Group Items** | `az resource list --resource-group <rg-name> -o table` |
| **Deploy Bicep Template** | `az deployment group create -g <rg-name> -f <file.bicep> --parameters @<params.json>` |
| **Stream Web App Logs** | `az webapp log tail -g <rg-name> -n <app-name>` |
| **Stream Container App Logs**| `az containerapp logs show -g <rg-name> -n <app-name> --follow` |
| **Query Log Analytics (KQL)**| `az monitor log-analytics query -w <workspace-id> -q "<kql-query>" -o table` |
| **Read Key Vault Secret** | `az keyvault secret show --vault-name <vault> -n <secret> --query value -o tsv` |
