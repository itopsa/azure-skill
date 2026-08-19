# JetBrains TeamCity CLI & REST API Reference

This reference covers managing and automating JetBrains TeamCity builds, pipelines, logs, and artifacts using PowerShell, Bash (`curl`), and the TeamCity REST API.

---

## 1. Authentication & Environment Setup

Create a **Personal Access Token (PAT)** in TeamCity (*Profile -> Access Tokens*).

### PowerShell (Windows)
```powershell
$env:TEAMCITY_SERVER = "https://teamcity.yourcompany.com"
$env:TEAMCITY_TOKEN  = "<YOUR_PERSONAL_ACCESS_TOKEN>"

$HEADERS = @{
    "Authorization" = "Bearer $env:TEAMCITY_TOKEN"
    "Accept"        = "application/json"
}
```

### Bash / Linux / macOS
```bash
export TEAMCITY_SERVER="https://teamcity.yourcompany.com"
export TEAMCITY_TOKEN="<YOUR_PERSONAL_ACCESS_TOKEN>"
```

---

## 2. Triggering Builds

### Trigger Build via PowerShell
```powershell
$body = @{
    buildType  = @{ id = "YourProject_BuildTypeId" }
    branchName = "main"
    properties = @{
        property = @(
            @{ name = "env.DEPLOY_TARGET"; value = "Production" }
            @{ name = "env.DRY_RUN";       value = "false" }
        )
    }
} | ConvertTo-Json -Depth 5

$build = Invoke-RestMethod -Uri "$env:TEAMCITY_SERVER/app/rest/buildQueue" `
    -Method Post `
    -Headers $HEADERS `
    -ContentType "application/json" `
    -Body $body

Write-Host "Build queued successfully with ID: $($build.id)"
```

### Trigger Build via Bash (`curl`)
```bash
curl -s -X POST "$TEAMCITY_SERVER/app/rest/buildQueue" \
  -H "Authorization: Bearer $TEAMCITY_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "buildType": { "id": "YourProject_BuildTypeId" },
    "branchName": "main"
  }'
```

---

## 3. Inspecting Build Status & Logs

### Check Build Status (Running, Success, Failure)
```powershell
# Get status of a specific build ID
$build = Invoke-RestMethod -Uri "$env:TEAMCITY_SERVER/app/rest/builds/id:12345" -Headers $HEADERS

Write-Host "State:     $($build.state)"      # running, finished, queued
Write-Host "Status:    $($build.status)"     # SUCCESS, FAILURE, ERROR
Write-Host "Percentage: $($build.percentageComplete)%"
```

### List Recent 5 Builds for a Build Configuration
```powershell
$builds = Invoke-RestMethod -Uri "$env:TEAMCITY_SERVER/app/rest/builds?locator=buildType:YourProject_BuildTypeId,count:5" -Headers $HEADERS
$builds.build | Format-Table id, buildTypeId, number, status, state, branchName
```

### Download / View Raw Build Log
```powershell
# Fetch raw build log text
Invoke-RestMethod -Uri "$env:TEAMCITY_SERVER/downloadBuildLog.html?buildId=12345" -Headers $HEADERS
```

```bash
# Fetch raw build log via curl
curl -s -H "Authorization: Bearer $TEAMCITY_TOKEN" \
  "$TEAMCITY_SERVER/downloadBuildLog.html?buildId=12345"
```

---

## 4. Canceling / Stopping a Running Build

```powershell
$cancelBody = @{
    comment        = "Canceled via CLI script"
    readdIntoQueue = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri "$env:TEAMCITY_SERVER/app/rest/builds/id:12345" `
    -Method Post `
    -Headers $HEADERS `
    -ContentType "application/json" `
    -Body $cancelBody
```

---

## 5. Artifact Management

### List Artifacts for a Build
```powershell
$artifacts = Invoke-RestMethod -Uri "$env:TEAMCITY_SERVER/app/rest/builds/id:12345/artifacts/children" -Headers $HEADERS
$artifacts.file | Format-Table name, size, modificationTime
```

### Download Artifact File or Archive
```powershell
# Download single artifact file
Invoke-WebRequest -Uri "$env:TEAMCITY_SERVER/app/rest/builds/id:12345/artifacts/content/build-output.zip" `
    -Headers $HEADERS `
    -OutFile "build-output.zip"
```

---

## 6. Standalone CLI: `tccli`

If a dedicated CLI tool is preferred:

```bash
# Install tccli via Python
pip install tccli

# Configure host and token
tccli configure --host https://teamcity.yourcompany.com --token <YOUR_TOKEN>

# Run a build
tccli build run --build-type <BuildTypeId> --branch main

# Check status
tccli build status <BuildId>
```

---

## 7. Useful TeamCity Service Messages (for Build Scripts)

When authoring build scripts (PowerShell / Bash) that run inside TeamCity agents:

```bash
# Set build status description in UI
echo "##teamcity[buildStatus status='SUCCESS' text='All Bicep templates validated successfully']"

# Publish an artifact dynamically
echo "##teamcity[publishArtifacts 'dist/output.zip']"

# Set a build parameter / environment variable for downstream steps
echo "##teamcity[setParameter name='env.IMAGE_TAG' value='v1.2.0']"

# Report an error and fail the build
echo "##teamcity[message text='Deployment failed' status='ERROR']"
```
