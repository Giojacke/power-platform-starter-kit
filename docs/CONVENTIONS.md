# Conventions

This document will define the naming and workflow conventions used across
the templates and scripts in this repo. It is a placeholder — sections below
will be filled in as the corresponding module or tooling is built.

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
