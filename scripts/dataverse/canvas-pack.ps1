#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Wraps `pac canvas pack` to build a .msapp file from unpacked Canvas App source.
.DESCRIPTION
    Counterpart to canvas-unpack.ps1 — see that script's notes on why the
    deprecated pack/unpack commands are still this repo's chosen path
    (ADR-0001). Works the same regardless of whether the environment has
    Dataverse enabled (ADR-0002).
.PARAMETER SourcesPath
    Directory containing the unpacked Canvas App source files.
.PARAMETER MsappPath
    Path to write the resulting .msapp file to.
.PARAMETER Overwrite
    Allow overwriting an existing .msapp file.
.EXAMPLE
    ./canvas-pack.ps1 -SourcesPath "./src/ContosoSolution/CanvasApps/MyApp" -MsappPath "./out/MyApp.msapp"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SourcesPath,

    [Parameter(Mandatory)]
    [string]$MsappPath,

    [switch]$Overwrite
)

. "$PSScriptRoot/_common.ps1"

$pacArgs = @('canvas', 'pack', '--sources', $SourcesPath, '--msapp', $MsappPath)

if ($Overwrite) {
    $pacArgs += '--overwrite'
}

Invoke-Pac @pacArgs
