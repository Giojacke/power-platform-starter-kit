#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Wraps `pac auth create` to connect the Power Platform CLI to a Dataverse environment.
.DESCRIPTION
    Thin wrapper around `pac auth create`. Supports the normal interactive
    flow (with an optional device code for headless sessions) and the
    service principal flow used by CI/CD pipelines. It does not attempt to
    detect or reuse an existing auth profile — `pac auth list` / `pac auth
    select` are the CLI's own tools for that; run them directly if you
    manage multiple profiles.

    MFA, if your tenant requires it, happens in the interactive browser flow
    that `pac auth create` opens itself — this script cannot complete that
    on your behalf, and neither can an AI agent driving it. If you're
    running this from the discovery interview in ../../skill/SKILL.md, that
    interview pauses at this exact point and asks you to run this manually.
.PARAMETER EnvironmentUrl
    The Dataverse environment URL to connect to (e.g. https://contoso.crm.dynamics.com).
.PARAMETER Name
    Optional friendly name for the resulting auth profile.
.PARAMETER DeviceCode
    Use the device code flow instead of an interactive browser popup.
    Required in headless sessions (e.g. Codespaces, CI agents without a browser).
.PARAMETER ApplicationId
    Service principal application (client) ID. Requires -ClientSecret and -TenantId.
.PARAMETER ClientSecret
    Service principal client secret. Requires -ApplicationId and -TenantId.
.PARAMETER TenantId
    Microsoft Entra ID tenant ID. Requires -ApplicationId and -ClientSecret.
.EXAMPLE
    ./auth-connect.ps1 -EnvironmentUrl "https://contoso-dev.crm.dynamics.com" -Name "ContosoDev"
.EXAMPLE
    ./auth-connect.ps1 -EnvironmentUrl "https://contoso-dev.crm.dynamics.com" -ApplicationId $appId -ClientSecret $secret -TenantId $tenantId
#>
[CmdletBinding(DefaultParameterSetName = 'Interactive')]
param(
    [Parameter(Mandatory)]
    [string]$EnvironmentUrl,

    [string]$Name,

    [Parameter(ParameterSetName = 'Interactive')]
    [switch]$DeviceCode,

    [Parameter(Mandatory, ParameterSetName = 'ServicePrincipal')]
    [string]$ApplicationId,

    [Parameter(Mandatory, ParameterSetName = 'ServicePrincipal')]
    [string]$ClientSecret,

    [Parameter(Mandatory, ParameterSetName = 'ServicePrincipal')]
    [string]$TenantId
)

. "$PSScriptRoot/_common.ps1"

$pacArgs = @('auth', 'create', '--environment', $EnvironmentUrl)

if ($Name) {
    $pacArgs += @('--name', $Name)
}

if ($PSCmdlet.ParameterSetName -eq 'ServicePrincipal') {
    $pacArgs += @(
        '--applicationId', $ApplicationId,
        '--clientSecret', $ClientSecret,
        '--tenant', $TenantId
    )
} elseif ($DeviceCode) {
    $pacArgs += '--deviceCode'
}

Invoke-Pac @pacArgs
