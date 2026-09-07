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

## Naming conventions

Pending — see [ADR-0001](adr/ADR-0001-estructura-modular-power-platform.md).

## Publisher prefix

Pending. Examples in this repo use a generic placeholder rather than a
real organization prefix, so they stay reusable by anyone forking this repo.

## ALM workflow — Dataverse module

Pending — see [ADR-0001](adr/ADR-0001-estructura-modular-power-platform.md).
The Dataverse module's primary ALM template targets Azure DevOps Pipelines
(with Power Platform Build Tools), since it is the only path that supports
full orchestration by script for this module.

## ALM workflow — Power BI / Fabric module

Pending — see [ADR-0001](adr/ADR-0001-estructura-modular-power-platform.md).
This module uses PBIP + Fabric Git Integration, which is unrelated to the
Dataverse module's ALM tooling and does not share folders or a pipeline with it.
