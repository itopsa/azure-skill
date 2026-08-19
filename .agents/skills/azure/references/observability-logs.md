# Azure Observability & Logs Reference

This reference covers querying metrics, executing Kusto (KQL) queries against Log Analytics workspaces, reading Application Insights data, and streaming logs.

---

## 1. Log Analytics Workspace Queries (KQL)

```bash
# Get Workspace Customer ID (Workspace ID)
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group <rg-name> \
  --workspace-name <law-name> \
  --query customerId -o tsv)

# Run a KQL query against the workspace
az monitor log-analytics query \
  --workspace "$WORKSPACE_ID" \
  --analytics-query "AzureActivity | where TimeGenerated > ago(1h) | summarize count() by OperationNameValue | order by count_ desc" \
  -o table

# Query Container App logs
az monitor log-analytics query \
  --workspace "$WORKSPACE_ID" \
  --analytics-query "ContainerAppConsoleLogs_CL | where TimeGenerated > ago(30m) | project TimeGenerated, ContainerAppName_s, Log_s | order by TimeGenerated desc | take 50" \
  -o table
```

---

## 2. Resource Health & Diagnostics

```bash
# Check resource health
az resourcehealth check --resource-group <rg-name> --name <resource-name> --resource-type "Microsoft.Compute/virtualMachines"

# List diagnostic settings configured on a resource
az monitor diagnostic-settings list --resource <resource-id> -o table
```

---

## 3. Metrics & Alerts

```bash
# Query metric definitions available for a resource
az monitor metrics list-definitions --resource <resource-id> -o table

# Fetch specific metric time-series
az monitor metrics list \
  --resource <resource-id> \
  --metric "Percentage CPU" \
  --interval PT5M \
  --start-time 2026-08-19T00:00:00Z \
  -o table

# List active alerts fired
az monitor alert list --resource-group <rg-name> -o table
```

---

## 4. Live Log Streaming

```bash
# App Service live log stream
az webapp log tail --name <app-name> --resource-group <rg-name>

# Container App live console stream
az containerapp logs show --name <app-name> --resource-group <rg-name> --follow

# Function App live log stream
az functionapp log tail --name <function-name> --resource-group <rg-name>
```
