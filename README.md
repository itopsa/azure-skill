# Azure Skill for AI Agents & GitHub Copilot

A token-efficient, CLI-driven, and progressive-disclosure Azure management skill for AI coding assistants (Antigravity, Gemini CLI, Claude, and GitHub Copilot) with full cross-platform support for Windows (PowerShell), macOS, Linux, and Azure DevOps (ADO) repositories.

---

## Quick Links

* 📘 **[Azure DevOps (ADO) Import & Setup Guide](./ADO_SETUP_GUIDE.md)** — Step-by-step instructions for importing this skill into a new ADO repository on Windows.
* 🛠️ **[Core Services Reference](./.agents/skills/azure/references/core-services.md)** — Compute, Storage, DB, and Network recipes.
* 🚀 **[IaC & Deployments](./.agents/skills/azure/references/iac-deployments.md)** — Bicep dry-runs (`what-if`) and `azd` workflows.
* 📊 **[Observability & Logs](./.agents/skills/azure/references/observability-logs.md)** — KQL queries, Log Analytics & App Insights.
* 🔐 **[Security & IAM](./.agents/skills/azure/references/security-iam.md)** — RBAC, Managed Identities & Key Vault.
* 🔄 **[Azure DevOps CLI](./.agents/skills/azure/references/azure-devops.md)** — Pipelines, Repos, PRs & Boards.

---

## Overview

Instead of loading heavy, token-expensive MCP servers (like Azure Resource Manager with 50+ tool schemas), this repository provides:

1. **Native CLI & IaC Direct Execution:** Uses the Azure CLI (`az`), Azure Developer CLI (`azd`), Bicep, and Azure DevOps CLI (`az devops`) directly for deterministic operations.
2. **Cross-Platform Ready:** Native **PowerShell** (`.ps1`) scripts for Windows environments alongside **Bash** (`.sh`) for macOS/Linux/WSL.
3. **Progressive Disclosure:** Only loads documentation and domain runbooks on-demand when relevant to the task.
4. **Safety & Guardrails:** Pre-flight checks (`az account show`), subscription validation, and mandatory dry-runs (`--what-if`) before applying infrastructure changes.
5. **Universal Compatibility:** Works seamlessly in **GitHub** and **Azure DevOps** repositories with **Antigravity / Gemini Agents** and **GitHub Copilot**.

---

## Directory Structure

```text
├── .agents/
│   └── skills/
│       └── azure/
│           ├── SKILL.md                 # Antigravity/Gemini Agent Skill Definition
│           ├── scripts/
│           │   ├── azure_preflight.ps1  # Windows PowerShell preflight validation
│           │   └── azure_preflight.sh   # macOS / Linux / Git Bash preflight validation
│           └── references/
│               ├── core-services.md     # Compute, Storage, DB, Network recipes
│               ├── iac-deployments.md   # Bicep, ARM what-if, and azd workflows
│               ├── observability-logs.md# KQL queries, Log Analytics & App Insights
│               ├── security-iam.md      # RBAC, Managed Identity, & Key Vault
│               └── azure-devops.md      # ADO Repos, PRs, Pipelines, and Boards
├── .github/
│   ├── copilot-instructions.md          # Repo-level Copilot guidelines (GitHub standard)
│   └── prompts/
│       └── azure-ops.prompt.md          # VS Code Copilot prompt template
├── .vscode/
│   ├── copilot-instructions.md          # Copilot guidelines (Azure DevOps / local standard)
│   └── settings.json                    # Workspace settings for Copilot Chat
├── ADO_SETUP_GUIDE.md                   # Step-by-step setup guide for Azure DevOps repos
└── README.md
```

---

## Usage

### 1. In a New Azure DevOps (ADO) Repository
See the complete **[Azure DevOps Setup Guide](./ADO_SETUP_GUIDE.md)** for one-liner PowerShell copy commands and team deployment steps.

### 2. With Antigravity / Gemini Agents
Drop the `.agents/skills/azure` directory into your project root or install globally in `~/.gemini/config/skills/azure`. The agent will automatically detect Azure tasks and activate the skill.

### 3. With GitHub Copilot (GitHub or Azure DevOps Repos)
* **Automatic:** Copilot in VS Code automatically reads `.vscode/copilot-instructions.md` and `.github/copilot-instructions.md` for all chats, inline edits, and PR reviews.
* **On-Demand in Chat:** Mention specific runbooks using `@workspace #file:.agents/skills/azure/references/observability-logs.md` or `#file:.agents/skills/azure/references/azure-devops.md`.
* **Prompt Template:** Use the Azure prompt template in `.github/prompts/azure-ops.prompt.md`.

---

## Pre-Flight Check

To verify your local Azure setup, CLI installation, ADO extension, and authenticated tenant/subscription:

* **On Windows (PowerShell):**
  ```powershell
  .\.agents\skills\azure\scripts\azure_preflight.ps1
  ```
* **On macOS / Linux / Git Bash:**
  ```bash
  ./.agents/skills/azure/scripts/azure_preflight.sh
  ```

---

## License

MIT
