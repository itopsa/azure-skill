# Azure Skill — Azure DevOps (ADO) Setup & Import Guide

This guide walks you through importing and using this Azure Skill and its GitHub Copilot instructions in a new or existing **Azure DevOps (ADO)** Git repository.

---

## 1. Prerequisites (Windows Workstation)

Ensure the following tools are installed on your Windows machine:

* **Azure CLI**: `winget install Microsoft.AzureCLI`
* **Git for Windows**: `winget install Git.Git`
* **Visual Studio Code** with the **GitHub Copilot** and **GitHub Copilot Chat** extensions.
* *(Optional)* **Azure Developer CLI**: `winget install Microsoft.Azd`

---

## 2. Quick Import into a New ADO Repo (PowerShell)

Run the following commands in **PowerShell** from your cloned ADO repository root:

```powershell
# 1. Clone the skill repository to a temporary folder
git clone https://github.com/itopsa/azure-skill.git "$env:TEMP\azure-skill"

# 2. Copy the .agents and .vscode directories into your ADO repo
Copy-Item -Path "$env:TEMP\azure-skill\.agents" -Destination ".\" -Recurse -Force
Copy-Item -Path "$env:TEMP\azure-skill\.vscode" -Destination ".\" -Recurse -Force

# 3. (Optional) Copy .github if your team also uses GitHub
# Copy-Item -Path "$env:TEMP\azure-skill\.github" -Destination ".\" -Recurse -Force

# 4. Clean up temporary files
Remove-Item -Path "$env:TEMP\azure-skill" -Recurse -Force
```

---

## 3. Configure Azure & ADO Authentication

In PowerShell, authenticate your local environment:

```powershell
# Login to your Azure Tenant
az login

# Set your active subscription
az account set --subscription "<Your-Subscription-Name-or-ID>"

# Install the Azure DevOps CLI extension
az extension add --name azure-devops

# Set default ADO Organization and Project
az devops configure --defaults organization=https://dev.azure.com/<YourOrg> project=<YourProject>
```

---

## 4. Run the Pre-Flight Verification

Execute the PowerShell pre-flight script to verify your setup:

```powershell
# Bypass execution policy if restricted in current session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Run verification
.\.agents\skills\azure\scripts\azure_preflight.ps1
```

You should see green `[OK]` status checks for:
- [OK] Azure CLI
- [OK] Bicep
- [OK] Azure DevOps extension
- [OK] Active Subscription & Tenant ID

---

## 5. Commit and Push to Azure DevOps

Commit the skill and Copilot configuration to your ADO Git branch so the entire team can leverage it:

```powershell
git add .agents .vscode
git commit -m "chore: add Azure cloud skill and Copilot instructions"
git push origin main
```

---

## 6. How to Use in Daily Development

Open the project in VS Code:
```powershell
code .
```

### With GitHub Copilot in VS Code
Copilot automatically loads `.vscode/copilot-instructions.md` and references the skill runbooks.

* **List Resources**:  
  `@workspace list all Container Apps in resource group rg-app-prod`
* **Trigger ADO Pipelines**:  
  `@workspace run the build pipeline for the staging branch`
* **Create Pull Requests**:  
  `@workspace create an ADO pull request targeting main`
* **Log Queries (KQL)**:  
  `@workspace #file:.agents/skills/azure/references/observability-logs.md write a query for failed HTTP 5xx responses`
* **Infrastructure as Code (Bicep)**:  
  `@workspace #file:.agents/skills/azure/references/iac-deployments.md run a what-if analysis for main.bicep`

### With Antigravity / Gemini Coding Assistants
Antigravity automatically discovers `.agents/skills/azure/SKILL.md` from your repository root and activates domain runbooks progressively on demand.

---

## Troubleshooting & Tips

* **Script Execution Restricted**: If PowerShell blocks script execution, run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`.
* **Multiple Subscriptions**: Switch subscriptions at any time using `az account set --subscription "<Name-or-ID>"`.
* **Personal Access Tokens (PAT)**: If required in your corporate network, login to ADO via:  
  `echo "<PAT>" | az devops login --organization https://dev.azure.com/<YourOrg>`
