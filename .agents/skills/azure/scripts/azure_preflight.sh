#!/usr/bin/env bash
# Azure CLI & Environment Preflight Check
set -eo pipefail

echo "=========================================="
echo "      Azure Environment Preflight         "
echo "=========================================="

# 1. Check Azure CLI
if command -v az >/dev/null 2>&1; then
    AZ_VERSION=$(az version --output json 2>/dev/null | grep '"azure-cli"' | head -1 | tr -d '", ' | cut -d: -f2 || echo "detected")
    echo " [OK] Azure CLI is installed (version: ${AZ_VERSION})"
else
    echo " [FAIL] Azure CLI (az) is not installed."
    echo "        Install via: brew install azure-cli (macOS) or https://aka.ms/installazurecliwindows"
    exit 1
fi

# 2. Check Bicep
if command -v bicep >/dev/null 2>&1; then
    BICEP_VERSION=$(bicep --version 2>/dev/null | awk '{print $4}' || echo "detected")
    echo " [OK] Bicep CLI is installed (version: ${BICEP_VERSION})"
elif az bicep version >/dev/null 2>&1; then
    echo " [OK] Bicep is available via 'az bicep'"
else
    echo " [INFO] Bicep CLI not found (install with 'az bicep install' if needed)."
fi

# 3. Check Azure DevOps Extension
if az extension list --output json 2>/dev/null | grep -q '"name": "azure-devops"'; then
    echo " [OK] Azure DevOps extension ('azure-devops') is installed."
else
    echo " [INFO] Azure DevOps extension not installed (install with 'az extension add --name azure-devops' if needed)."
fi

echo "------------------------------------------"
echo " Checking Azure Authentication Context..."

# 4. Check active account & subscription
ACCOUNT_INFO=$(az account show --output json 2>/dev/null || true)

if [ -z "$ACCOUNT_INFO" ] || [ "$ACCOUNT_INFO" = "{}" ]; then
    echo " [WARN] No active Azure session found."
    echo "        Please run 'az login' to authenticate."
    exit 2
fi

SUB_NAME=$(echo "$ACCOUNT_INFO" | grep -o '"name": "[^"]*"' | head -1 | cut -d'"' -f4)
SUB_ID=$(echo "$ACCOUNT_INFO" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
TENANT_ID=$(echo "$ACCOUNT_INFO" | grep -o '"tenantId": "[^"]*"' | head -1 | cut -d'"' -f4)
USER_NAME=$(echo "$ACCOUNT_INFO" | grep -A 2 '"user"' | grep -o '"name": "[^"]*"' | head -1 | cut -d'"' -f4)

echo " [OK] Logged in as:      ${USER_NAME:-Unknown}"
echo " [OK] Active Subscription: ${SUB_NAME} (${SUB_ID})"
echo " [OK] Tenant ID:          ${TENANT_ID}"
echo "=========================================="
echo "Azure environment is ready for operations."
