#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Prepares the analytics/ folder for the Power BI/Fabric module (PBIP).
.DESCRIPTION
    This script does NOT wrap any pac command, and does NOT generate PBIP
    files. pac has no command for that — a PBIP project (<Report>.Report/ +
    <Report>.SemanticModel/) is only created by Power BI Desktop itself,
    when a report is saved with the "Power BI Project (.pbip) save option"
    preview feature enabled. See ADR-0001 and docs/CONVENTIONS.md for why
    this module has no pac automation.

    All this script does is prepare the ground: create the analytics/
    folder, drop the official PBIP .gitignore entries into it, and write a
    README.md with the manual steps to follow in Power BI Desktop. It never
    creates <Report>.Report/ or <Report>.SemanticModel/ itself — that part
    is Power BI Desktop's job, not this script's.
.PARAMETER Path
    Path to the analytics folder to prepare. Defaults to "analytics" (the
    name used in the ADR-0001 folder tree), relative to the current directory.
.PARAMETER Force
    Overwrite an existing .gitignore/README.md in the target folder instead
    of leaving them untouched.
.EXAMPLE
    ./pbip-folder-init.ps1
.EXAMPLE
    ./pbip-folder-init.ps1 -Path "./analytics" -Force
#>
[CmdletBinding()]
param(
    [string]$Path = "analytics",

    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
    Write-Host "Created $Path"
}

# Official PBIP .gitignore content, verbatim from Microsoft Learn:
# https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview
$gitignoreContent = @'
**/.pbi/localSettings.json
**/.pbi/cache.abf
'@

$gitignorePath = Join-Path $Path ".gitignore"
if ((Test-Path -LiteralPath $gitignorePath) -and -not $Force) {
    Write-Warning "$gitignorePath already exists - leaving it untouched. Pass -Force to overwrite."
} else {
    Set-Content -LiteralPath $gitignorePath -Value $gitignoreContent -NoNewline
    Write-Host "Wrote $gitignorePath"
}

$readmeContent = @'
# analytics/

This folder holds the Power BI/Fabric module of this project - see
ADR-0001 in the generator repo (power-platform-starter-kit) for why it's
independent from the Dataverse module: no shared folders, no shared
pipeline, and a different versioning mechanism (PBIP + Fabric Git
Integration instead of pac / Azure DevOps Power Platform pipelines).

## This folder was prepared for you, not generated for you

`pac` has no command to create a PBIP project. `<Report>.Report/` and
`<Report>.SemanticModel/` are created only by Power BI Desktop itself, when
you save a report as a **Power BI Project (PBIP)** - a preview feature.
There is no API for this step today, so it's manual. Here's how to do it:

## 1. Enable the PBIP preview feature (once per machine)

1. Open Power BI Desktop.
2. Go to **File > Options and settings > Options > Preview features**.
3. Check **Power BI Project (.pbip) save option**.
4. Restart Power BI Desktop if it asks you to.

## 2. Save your report into this folder

1. Open (or build) your report in Power BI Desktop.
2. **File > Save As**, choose **Power BI Project (\*.pbip)** as the file type.
3. Point the save location at this `analytics/` folder (or a subfolder of
   it, if this project will hold more than one report).
4. Save.

Power BI Desktop will create, right next to this README:

```
analytics/
|-- <YourReport>.Report/
|-- <YourReport>.SemanticModel/
|-- <YourReport>.pbip
`-- .gitignore   (already here - Power BI Desktop won't overwrite it)
```

## 3. Commit it

`<YourReport>.Report/` and `<YourReport>.SemanticModel/` are plain text
(JSON/TMDL) and safe to commit. The `.gitignore` already in this folder
excludes the two files Microsoft's own docs call out as local-only:
`**/.pbi/localSettings.json` (per-user, per-machine settings) and
`**/.pbi/cache.abf` (a local data cache) - neither belongs in source control.

## Does this depend on the Dataverse module?

No. Whether your semantic model needs its own data or only consumes tables
that already exist in Dataverse is a decision you make inside Power BI
Desktop when you build the model - it doesn't change anything about this
folder or these steps.
'@

$readmePath = Join-Path $Path "README.md"
if ((Test-Path -LiteralPath $readmePath) -and -not $Force) {
    Write-Warning "$readmePath already exists - leaving it untouched. Pass -Force to overwrite."
} else {
    Set-Content -LiteralPath $readmePath -Value $readmeContent -NoNewline
    Write-Host "Wrote $readmePath"
}
