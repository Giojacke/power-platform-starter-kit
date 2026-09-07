#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Wraps `pac canvas unpack` to extract a Canvas App .msapp into source files.
.DESCRIPTION
    `pac canvas pack`/`unpack` are marked deprecated by Microsoft in favor of
    the native Power Platform Git Integration — but that integration is a
    maker-portal UI experience with no scriptable API. These commands remain
    the only programmable path for an AI agent or CI pipeline to regenerate
    Canvas App source. See ADR-0001 for the full reasoning; this is a
    deliberate choice, not an oversight. This works the same whether or not
    the environment has Dataverse enabled — see ADR-0002.
.PARAMETER MsappPath
    Path to the .msapp file to unpack (exported from Power Apps Studio via
    File > Save as > This computer).
.PARAMETER SourcesPath
    Directory to extract sources into. Defaults to "<msapp name>_src".
.PARAMETER Overwrite
    Allow overwriting an existing sources directory.
.EXAMPLE
    ./canvas-unpack.ps1 -MsappPath "./out/MyApp.msapp" -SourcesPath "./src/ContosoSolution/CanvasApps/MyApp"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$MsappPath,

    [string]$SourcesPath,

    [switch]$Overwrite
)

. "$PSScriptRoot/_common.ps1"

$pacArgs = @('canvas', 'unpack', '--msapp', $MsappPath)

if ($SourcesPath) {
    $pacArgs += @('--sources', $SourcesPath)
}

if ($Overwrite) {
    $pacArgs += '--overwrite'
}

Invoke-Pac @pacArgs
