# Azure DevOps (ADO) CLI Reference

This reference covers managing Azure DevOps organizations, projects, repositories, pull requests, pipelines, and work items using the Azure CLI `azure-devops` extension.

---

## 1. Setup & Authentication

```bash
# Install the Azure DevOps CLI extension
az extension add --name azure-devops

# Verify or upgrade extension
az extension update --name azure-devops

# Configure default Organization and Project (saves typing in subsequent commands)
az devops configure --defaults organization=https://dev.azure.com/<OrgName> project=<ProjectName>

# Authenticate with Personal Access Token (PAT) if not using interactive az login
echo "<PAT-TOKEN>" | az devops login --organization https://dev.azure.com/<OrgName>
```

---

## 2. Azure Repos & Pull Requests

```bash
# List all repositories in the project
az repos list -o table

# List active Pull Requests
az repos pr list -o table

# List PRs targeting a specific branch (e.g. main)
az repos pr list --target-branch main --status active -o table

# Create a new Pull Request
az repos pr create \
  --title "feat: infrastructure updates" \
  --description "Deploys updated Bicep modules and monitoring alerts." \
  --source-branch feature/new-infra \
  --target-branch main \
  --open

# Show details of a specific PR
az repos pr show --id <PR-ID> -o json

# Approve a Pull Request
az repos pr set-vote --id <PR-ID> --vote approve

# Complete / Merge a Pull Request (with squash merge and branch deletion)
az repos pr update --id <PR-ID> --status completed --squash true --delete-source-branch true
```

---

## 3. Azure Pipelines (CI/CD)

```bash
# List all build/release pipelines
az pipelines list -o table

# Run / trigger a pipeline
az pipelines run --name "<Pipeline-Name>" --branch main

# Run a pipeline with runtime variables
az pipelines run --name "<Pipeline-Name>" --variables Environment=Production DryRun=false

# List recent pipeline runs / builds
az pipelines runs list --pipeline-name "<Pipeline-Name>" --top 10 -o table

# Show detailed status and logs of a specific pipeline run
az pipelines runs show --id <Run-ID> -o json
```

---

## 4. Azure Boards (Work Items & Issues)

```bash
# List work items matching a WIQL query
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.WorkItemType] = 'Bug' AND [System.State] = 'Active'" -o table

# Create a new Work Item (Task, Bug, User Story)
az boards work-item create \
  --type "Task" \
  --title "Update Bicep template for Redis Cache" \
  --description "Upgrade sku from Basic to Standard" \
  --assigned-to "<user-email>" \
  -o json

# Show details of a work item
az boards work-item show --id <WorkItem-ID> -o json

# Update work item state (e.g. Active -> Resolved / Closed)
az boards work-item update --id <WorkItem-ID> --state "Resolved"
```

---

## 5. Azure Artifacts & Feeds

```bash
# List feeds in the organization
az artifacts feed list -o table

# List packages in a specific feed
az artifacts universal list --feed <feed-name> -o table
```
