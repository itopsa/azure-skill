<#
.SYNOPSIS
    Azure CLI & Environment Preflight Check for Windows / PowerShell
#>
$ErrorActionPreference = "Continue"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      Azure Environment Preflight         " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Check Azure CLI
$azCmd = Get-Command az -ErrorAction SilentlyContinue
if ($azCmd) {
    $azVerJson = az version --output json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
    $azVer = if ($azVerJson -and $azVerJson.'azure-cli') { $azVerJson.'azure-cli' } else { "detected" }
    Write-Host " [OK] Azure CLI is installed (version: $azVer)" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Azure CLI (az) is not installed." -ForegroundColor Red
    Write-Host "        Install via: winget install Microsoft.AzureCLI" -ForegroundColor Yellow
    exit 1
}

# 2. Check Bicep
$bicepCmd = Get-Command bicep -ErrorAction SilentlyContinue
if ($bicepCmd) {
    $bicepVer = (bicep --version 2>$null)
    Write-Host " [OK] Bicep CLI is installed ($bicepVer)" -ForegroundColor Green
} else {
    $null = az bicep version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " [OK] Bicep is available via 'az bicep'" -ForegroundColor Green
    } else {
        Write-Host " [INFO] Bicep CLI not found (install with 'az bicep install' if needed)." -ForegroundColor Gray
    }
}

# 3. Check Azure DevOps Extension
$extJson = az extension list --output json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
$hasAdo = $extJson | Where-Object { $_.name -eq "azure-devops" }
if ($hasAdo) {
    Write-Host " [OK] Azure DevOps extension ('azure-devops') is installed." -ForegroundColor Green
} else {
    Write-Host " [INFO] Azure DevOps extension not installed (install with 'az extension add --name azure-devops' if needed)." -ForegroundColor Gray
}

Write-Host "------------------------------------------" -ForegroundColor Cyan
Write-Host " Checking Azure Authentication Context..." -ForegroundColor Cyan

# 4. Check active account & subscription
$accountJson = az account show --output json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue

if (-not $accountJson) {
    Write-Host " [WARN] No active Azure session found." -ForegroundColor Yellow
    Write-Host "        Please run 'az login' to authenticate." -ForegroundColor Yellow
    exit 2
}

$subName = $accountJson.name
$subId = $accountJson.id
$tenantId = $accountJson.tenantId
$userName = if ($accountJson.user -and $accountJson.user.name) { $accountJson.user.name } else { "Unknown" }

Write-Host " [OK] Logged in as:        $userName" -ForegroundColor Green
Write-Host " [OK] Active Subscription: $subName ($subId)" -ForegroundColor Green
Write-Host " [OK] Tenant ID:            $tenantId" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Azure environment is ready for operations." -ForegroundColor Green
