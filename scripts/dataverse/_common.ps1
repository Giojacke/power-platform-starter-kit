#Requires -Version 7.0

<#
.SYNOPSIS
    Shared helpers for the scripts/dataverse/*.ps1 wrappers around pac CLI.
.DESCRIPTION
    Dot-source this file from each wrapper script:
        . "$PSScriptRoot/_common.ps1"
    Not meant to be run directly.
#>

function Assert-PacCliInstalled {
    [CmdletBinding()]
    param()
    if (-not (Get-Command pac -ErrorAction SilentlyContinue)) {
        throw "pac CLI not found on PATH. Install it first: https://learn.microsoft.com/power-platform/developer/cli/introduction"
    }
}

function Invoke-Pac {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Assert-PacCliInstalled
    & pac @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "pac $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}
