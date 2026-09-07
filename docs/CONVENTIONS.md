# Conventions

This document will define the naming and workflow conventions used across
the templates and scripts in this repo. It is a placeholder — sections below
will be filled in as the corresponding module or tooling is built.

## Scripting language

All scripts under `scripts/` are written in **PowerShell 7+ (pwsh)**, not
bash, even though the `.gitignore` originally anticipated both. This is a
tooling convention, not an architecture decision — it doesn't get its own
ADR.

Why PowerShell 7+ specifically:

- `pac` CLI's own official examples (Microsoft Learn) are all shown in
  PowerShell — it's the natural fit for wrapping it.
- PowerShell 7+ (as opposed to legacy Windows PowerShell 5.1) is
  cross-platform: it runs on Windows, Linux, and macOS, so this choice
  doesn't lock contributors on other operating systems out of the repo,
  even though the author's own day-to-day workflow is Windows-based.

If a future module needs a script that doesn't make sense in PowerShell
(e.g. something that only exists as a shell one-liner in a platform-specific
tool's own docs), document the exception here when it happens — don't
silently mix scripting languages without a note.

## Script file naming

Scripts under `scripts/<module>/` follow a `<domain>-<verb>.ps1` kebab-case
pattern, where `<domain>` is the `pac` command group (or closest concept)
the script deals with and `<verb>` is what it does to it:

- `auth-connect.ps1`
- `solution-init.ps1`
- `solution-package.ps1`
- `canvas-unpack.ps1` / `canvas-pack.ps1`
- `pbip-folder-init.ps1`

`_common.ps1` (leading underscore) is the one exception: it's a shared,
dot-sourced helper file, not a script meant to be run directly, so it
doesn't need to fit the pattern.

## Why the Power BI module has no pac scripts

`scripts/powerbi/pbip-folder-init.ps1` is still a PowerShell script, but
unlike everything under `scripts/dataverse/`, it doesn't wrap a `pac`
command — because there isn't one to wrap. `pac` has no command that
generates a PBIP project; `<Report>.Report/` and `<Report>.SemanticModel/`
are created only by Power BI Desktop itself, via its "Power BI Project
(.pbip) save option" preview feature (see
[ADR-0001](adr/ADR-0001-estructura-modular-power-platform.md)). This script
only prepares the `analytics/` folder (the official PBIP `.gitignore`
entries plus instructions) — it can't do the save step for you, and doesn't
pretend to.

## Naming conventions

Pending — see [ADR-0001](adr/ADR-0001-estructura-modular-power-platform.md).
This section is about naming Dataverse solutions/components and generated
project folders; script file naming is already covered above.

## Publisher prefix

Decided: this repo's own examples and docs use a generic placeholder
rather than a real organization prefix, so they stay reusable by anyone
forking this repo. Each generated project picks its own real prefix via
question 3 of [SKILL.md](../skill/SKILL.md)'s interview — see ADR-0001 and
ADR-0002 for why that choice is irreversible once a Solution is created.

## ALM workflow — Dataverse module

Platform decided: the Dataverse module's primary ALM template targets
Azure DevOps Pipelines (with Power Platform Build Tools), since it's the
only path that supports full orchestration by script for this module — see
[ADR-0001](adr/ADR-0001-estructura-modular-power-platform.md). **Still
pending:** the actual `pipelines/dataverse-alm.yml` template file — see
[pipelines/README.md](../pipelines/README.md).

## ALM workflow — Power BI / Fabric module

Platform decided: this module uses PBIP + Fabric Git Integration, which is
unrelated to the Dataverse module's ALM tooling and shares no folders or
pipeline with it — see
[ADR-0001](adr/ADR-0001-estructura-modular-power-platform.md). **Still
pending:** the actual `pipelines/powerbi-fabric.yml` template file, and the
Fabric Git sync helper scripts mentioned in
[scripts/powerbi/README.md](../scripts/powerbi/README.md).
