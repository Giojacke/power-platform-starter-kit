# scripts/dataverse

`pac` CLI wrapper scripts for the Dataverse module. Planned scripts:

- **auth** — authenticate `pac` against the target environment
- **solution init** — create/unpack the base Solution folder structure
- **canvas pack/unpack** — wrap `pac canvas pack` / `pac canvas unpack` to
  generate and regenerate Canvas App source (`.pa.yaml`); used deliberately
  despite being marked deprecated by Microsoft, because it is the only
  programmable path for an AI agent to produce Canvas App source — see
  [ADR-0001](../../docs/adr/ADR-0001-estructura-modular-power-platform.md)
- **packaging** — pack the Solution for export/deployment

Currently empty — scripts will be added incrementally.
