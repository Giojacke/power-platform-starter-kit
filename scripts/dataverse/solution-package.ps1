#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Wraps `pac solution pack` to build a solution.zip from an unpacked Solution folder.
.DESCRIPTION
    Packages the components under src/<Solución>/ (Entities, Roles,
    environmentvariabledefinitions, CanvasApps, Workflows, Other) into a
    deployable solution.zip, ready for `pac solution import` or a pipeline
    deployment step.
.PARAMETER SolutionFolder
    Path to the root of the unpacked Solution folder.
.PARAMETER ZipFile
    Path to write the resulting solution.zip to.
.PARAMETER PackageType
    Whether to package as Unmanaged, Managed, or Both. Defaults to pac's own
    default (Unmanaged) when omitted.
.EXAMPLE
    ./solution-package.ps1 -SolutionFolder "./src/ContosoSolution" -ZipFile "./out/ContosoSolution.zip" -PackageType Managed
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SolutionFolder,

    [Parameter(Mandatory)]
    [string]$ZipFile,

    [ValidateSet('Unmanaged', 'Managed', 'Both')]
    [string]$PackageType
)

. "$PSScriptRoot/_common.ps1"

$pacArgs = @('solution', 'pack', '--folder', $SolutionFolder, '--zipfile', $ZipFile)

if ($PackageType) {
    $pacArgs += @('--packagetype', $PackageType)
}

Invoke-Pac @pacArgs
