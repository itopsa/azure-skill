# JetBrains TeamCity CLI & REST API Reference

This reference covers managing and automating JetBrains TeamCity builds, pipelines, logs, and artifacts through the TeamCity REST API with PowerShell or Bash (`curl`), or `tccli` when its installed version supports the needed command.

---

## 1. Authentication & Environment Setup

Create a **Personal Access Token (PAT)** in TeamCity (*Profile -> Access Tokens*).

Never provide a token in chat, source control, or command output. Set it directly in the terminal session or retrieve it from an approved secret store.

### PowerShell (Windows)
```powershell
$env:TEAMCITY_SERVER = "https://teamcity.yourcompany.com"
$env:TEAMCITY_TOKEN  = "<YOUR_PERSONAL_ACCESS_TOKEN>"

$HEADERS = @{
    "Authorization" = "Bearer $env:TEAMCITY_TOKEN"
    "Accept"        = "application/json"
}
```

### Verify the Connection
```powershell
$server = Invoke-RestMethod -Uri "$env:TEAMCITY_SERVER/app/rest/server" -Headers $HEADERS
$server | Select-Object version, buildNumber, startTime | Format-List
```

### Bash / Linux / macOS
```bash
export TEAMCITY_SERVER="https://teamcity.yourcompany.com"
export TEAMCITY_TOKEN="<YOUR_PERSONAL_ACCESS_TOKEN>"
```

---

## 2. Listing and Filtering Build Configurations

### List All Accessible Jobs
TeamCity paginates large inventories. Follow `nextHref` until all pages have been read:

```powershell
$fields = 'nextHref,buildType(id,name,paused,project(id,name))'
$path = '/app/rest/buildTypes?locator=count:1000&fields=' + [uri]::EscapeDataString($fields)
$jobs = @()

do {
    $response = Invoke-RestMethod -Uri "$env:TEAMCITY_SERVER$path" -Headers $HEADERS
    $jobs += @($response.buildType)
    $path = $response.nextHref
} while (-not [string]::IsNullOrEmpty($path))

$jobs |
    Sort-Object { $_.project.name }, name |
    Select-Object @{Name='Project'; Expression = { $_.project.name }}, name, id, paused |
    Format-Table -AutoSize
```

### Filter Jobs by Project or Job Name
After retrieving the inventory, filter by project name, project ID, or job name:

```powershell
$jobs |
    Where-Object {
        $_.project.name -like '*AppSettingsDemo*' -or
        $_.project.id -like '*AppSettingsDemo*' -or
        $_.name -like '*deploy*'
    } |
    Select-Object @{Name='Project'; Expression = { $_.project.name }}, name, id, paused |
    Format-Table -AutoSize
```

---

## 3. Optional TeamCity CLI (`tccli`)

Use `tccli` as a convenience layer only after confirming that the installed version exposes the commands required for the task. CLI command availability varies by version; use the REST API sections as the portable fallback.

```powershell
tccli --help
tccli build --help
```

When supported by the installed version, configure a profile and use it to query or run builds:

```bash
tccli configure --host https://teamcity.yourcompany.com --token <YOUR_TOKEN>
tccli build list
tccli build status <BuildId>
tccli build run --build-type <BuildTypeId> --branch main
```

Never paste a token into chat, source control, or build logs. Prefer a terminal prompt or an approved secret store when configuring the CLI.

---

## 4. Triggering Builds

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

## 5. Inspecting Build Status & Logs

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

## 6. Canceling / Stopping a Running Build

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

## 7. Artifact Management

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

## 8. Useful TeamCity Service Messages (for Build Scripts)

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
