# Azure Skill for AI Agents & GitHub Copilot

A token-efficient, CLI-driven, and progressive-disclosure Azure management skill for AI coding assistants (Antigravity, Gemini CLI, Claude, and GitHub Copilot) with full support for GitHub and Azure DevOps (ADO) repositories.

---

## Overview

Instead of loading heavy, token-expensive MCP servers (like Azure Resource Manager with 50+ tool schemas), this repository provides:

1. **Native CLI & IaC Direct Execution:** Uses the Azure CLI (`az`), Azure Developer CLI (`azd`), Bicep, and Azure DevOps CLI (`az devops`) directly for deterministic operations.
2. **Progressive Disclosure:** Only loads documentation and domain runbooks on-demand when relevant to the task.
3. **Safety & Guardrails:** Pre-flight checks (`az account show`), subscription validation, and mandatory dry-runs (`--what-if`) before applying infrastructure changes.
4. **Universal Compatibility:** Works seamlessly in **GitHub** and **Azure DevOps** repositories with **Antigravity / Gemini Agents** and **GitHub Copilot**.

---

## Directory Structure

```text
├── .agents/
│   └── skills/
│       └── azure/
│           ├── SKILL.md                 # Antigravity/Gemini Agent Skill Definition
│           ├── scripts/
│           │   └── azure_preflight.sh   # Environment, CLI, ADO & auth validation script
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
└── README.md
```

---

## Usage

### 1. With Antigravity / Gemini Agents
Drop the `.agents/skills/azure` directory into your project root or install globally in `~/.gemini/config/skills/azure`. The agent will automatically detect Azure tasks and activate the skill.

### 2. With GitHub Copilot (GitHub or Azure DevOps Repos)
* **Automatic:** Copilot in VS Code automatically reads `.vscode/copilot-instructions.md` and `.github/copilot-instructions.md` for all chats, inline edits, and PR reviews.
* **On-Demand in Chat:** Mention specific runbooks using `@workspace #file:.agents/skills/azure/references/observability-logs.md` or `#file:.agents/skills/azure/references/azure-devops.md`.
* **Prompt Template:** Use the Azure prompt template in `.github/prompts/azure-ops.prompt.md`.

---

## Pre-Flight Check

To verify your local Azure setup, CLI installation, ADO extension, and authenticated tenant/subscription:

```bash
./.agents/skills/azure/scripts/azure_preflight.sh
```

---

## License

MIT
