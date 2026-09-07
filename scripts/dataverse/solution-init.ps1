#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Wraps `pac solution init` to scaffold a new Dataverse Solution project.
.DESCRIPTION
    Initializes the src/<Solución>/ folder from ADR-0001 with a new,
    unpacked Solution project. This only scaffolds the base project — the
    optional CanvasApps/ and Workflows/ subfolders described in ADR-0001 are
    not created by `pac solution init` itself (pac has no concept of which
    components a not-yet-built solution will contain); create those as
    plain empty folders based on which components the project has.
.PARAMETER PublisherName
    Name of the Dataverse solution publisher. Letters, digits, and
    underscore only; must start with a letter or underscore.
.PARAMETER PublisherPrefix
    Customization prefix for the publisher (2-8 alphanumeric characters,
    must start with a letter, cannot start with "mscrm").
    Cannot be changed after the Solution is created — see ADR-0001 and
    ADR-0002.
.PARAMETER OutputDirectory
    Directory to initialize the Solution project in. Defaults to the
    current directory.
.EXAMPLE
    ./solution-init.ps1 -PublisherName "Contoso" -PublisherPrefix "ctso" -OutputDirectory "./src/ContosoSolution"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PublisherName,

    [Parameter(Mandatory)]
    [string]$PublisherPrefix,

    [string]$OutputDirectory
)

. "$PSScriptRoot/_common.ps1"

Write-Warning "Publisher prefix '$PublisherPrefix' cannot be changed after the Solution is created. Confirm it's correct before continuing."

$pacArgs = @('solution', 'init', '--publisher-name', $PublisherName, '--publisher-prefix', $PublisherPrefix)

if ($OutputDirectory) {
    $pacArgs += @('--outputDirectory', $OutputDirectory)
}

Invoke-Pac @pacArgs
