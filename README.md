# Azure Skill for AI Agents & GitHub Copilot

A token-efficient, CLI-driven, and progressive-disclosure Azure management skill for AI coding assistants (Antigravity, Gemini CLI, Claude, and GitHub Copilot).

---

## Overview

Instead of loading heavy, token-expensive MCP servers (like Azure Resource Manager with 50+ tool schemas), this repository provides:

1. **Native CLI & IaC Direct Execution:** Uses the Azure CLI (`az`), Azure Developer CLI (`azd`), and Bicep directly for deterministic operations.
2. **Progressive Disclosure:** Only loads documentation and domain runbooks on-demand when relevant to the task.
3. **Safety & Guardrails:** Pre-flight checks (`az account show`), subscription validation, and mandatory dry-runs (`--what-if`) before applying infrastructure changes.
4. **Dual Compatibility:** Works out-of-the-box with **Antigravity / Gemini Agents** (`.agents/skills/azure/`) and **GitHub Copilot** (`.github/copilot-instructions.md`).

---

## Directory Structure

```text
├── .agents/
│   └── skills/
│       └── azure/
│           ├── SKILL.md                 # Antigravity/Gemini Agent Skill Definition
│           ├── scripts/
│           │   └── azure_preflight.sh   # Environment, CLI, & auth validation script
│           └── references/
│               ├── core-services.md     # Compute, Storage, DB, Network recipes
│               ├── iac-deployments.md   # Bicep, ARM what-if, and azd workflows
│               ├── observability-logs.md# KQL queries, Log Analytics & App Insights
│               └── security-iam.md      # RBAC, Managed Identity, & Key Vault
├── .github/
│   ├── copilot-instructions.md          # Repo-level Copilot guidelines & rules
│   └── prompts/
│       └── azure-ops.prompt.md          # VS Code Copilot prompt template
├── .vscode/
│   └── settings.json                    # Workspace settings for Copilot Chat
└── README.md
```

---

## Usage

### 1. With Antigravity / Gemini Agents
Drop the `.agents/skills/azure` directory into your project root or install globally in `~/.gemini/config/skills/azure`. The agent will automatically detect Azure tasks and activate the skill.

### 2. With GitHub Copilot
* **Automatic:** Copilot automatically reads `.github/copilot-instructions.md` for all chats, inline edits, and PR reviews.
* **On-Demand in Chat:** Mention specific runbooks using `@workspace #file:.agents/skills/azure/references/observability-logs.md`.
* **Prompt Template:** Use the Azure prompt template in `.github/prompts/azure-ops.prompt.md`.

---

## Pre-Flight Check

To verify your local Azure setup, CLI installation, and authenticated tenant/subscription:

```bash
./.agents/skills/azure/scripts/azure_preflight.sh
```

---

## License

MIT
