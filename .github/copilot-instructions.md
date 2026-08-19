# GitHub Copilot Instructions — Azure Cloud & CI/CD (ADO & TeamCity)

These instructions guide GitHub Copilot when assisting with Microsoft Azure architecture, Infrastructure as Code (Bicep/ARM), CLI scripting, operations, troubleshooting, Azure DevOps (ADO), and JetBrains TeamCity across Windows (PowerShell/CMD), macOS, and Linux.

---

## 1. Core Principles & Tooling

* **CLI & IaC First**: Always provide solutions using the **Azure CLI (`az`)**, **Bicep**, the **Azure DevOps CLI extension (`az devops`)**, or the **TeamCity REST API/CLI** rather than manual portal clicks.
* **Cross-Platform Compatibility**: Provide commands that work on the user's OS:
  * On **Windows**: Support PowerShell syntax and backslashes where appropriate (e.g. `.\.agents\skills\azure\scripts\azure_preflight.ps1`).
  * On **macOS/Linux**: Support POSIX/Bash syntax (`./.agents/skills/azure/scripts/azure_preflight.sh`).
* **Skill Runbooks**: Reference the domain recipes in `.agents/skills/azure/references/`:
  * [Core Services](../.agents/skills/azure/references/core-services.md) (Compute, Storage, DB, Network)
  * [IaC & Deployments](../.agents/skills/azure/references/iac-deployments.md) (Bicep, ARM)
  * [Observability & Logs](../.agents/skills/azure/references/observability-logs.md) (KQL, Log Analytics, Metrics)
  * [Security & IAM](../.agents/skills/azure/references/security-iam.md) (RBAC, Key Vault, Identities)
  * [Azure DevOps](../.agents/skills/azure/references/azure-devops.md) (ADO Repos, PRs, Pipelines, Boards)
  * [TeamCity](../.agents/skills/azure/references/teamcity.md) (TeamCity REST API, build triggers, artifact downloads)

---

## 2. Safety & Operational Guardrails

* **Pre-Flight Validation**: Always verify active subscription and tenant context:
  * PowerShell: `.\.agents\skills\azure\scripts\azure_preflight.ps1`
  * Bash: `./.agents/skills/azure/scripts/azure_preflight.sh`
  * Inline: `az account show -o table`
* **Dry Runs for Infrastructure**: Always use `az deployment group what-if` before applying Bicep or ARM templates.
* **Destructive Command Warnings**: Warn before executing any deletion or purge command (`az group delete`, `az resource delete`, `az keyvault purge`).

---

## 3. CLI Output & Query Standards

* **Human Display**: Use `--output table` (`-o table`) for listings and status summaries.
* **Script / Programmatic Parsing**: Use `--output json` when JSON payload manipulation is required.
* **Scalar Values**: Use `--output tsv` (`-o tsv`) with `--query` for single values (IDs, connection strings, keys).
* **JMESPath Filtering**: Use native `--query` filters instead of piping to grep/awk.

---

## 4. CI/CD Patterns (ADO & TeamCity)

* **ADO Pipelines**: `az pipelines run --name "<Pipeline-Name>" --branch main`
* **ADO Pull Requests**: `az repos pr list -o table` or `az repos pr create --target-branch main --open`
* **TeamCity Trigger**: Use PowerShell `Invoke-RestMethod` against `$env:TEAMCITY_SERVER/app/rest/buildQueue` with Bearer auth.
