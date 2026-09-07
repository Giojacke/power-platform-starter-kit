# pipelines

ALM pipeline templates. The two modules do not share a pipeline — they use
different tooling and deployment targets, so each gets its own template. See
[ADR-0001](../docs/adr/ADR-0001-estructura-modular-power-platform.md).

- **Dataverse module** — Azure DevOps Pipelines template using Power
  Platform Build Tools + `pac`, chosen as the primary ALM template for this
  module (Azure DevOps is used to track work items for the module's real
  reference project).
- **Power BI module** — deployment template for the Fabric/PBIP workflow.

Currently empty — pipeline templates will be added incrementally.
