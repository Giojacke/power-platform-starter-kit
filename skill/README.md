# skill

[`SKILL.md`](SKILL.md) is the discovery interview an AI agent runs to
scaffold a Power Platform project using the templates and scripts in this
repo.

The interview has two real branching questions, not one:

- **Does the environment have Dataverse enabled?** — [ADR-0002](../docs/adr/ADR-0002-bifurcacion-sin-dataverse.md).
  Drives whether the project gets a Solution (publisher prefix, Canvas
  App/Power Automate components) or the standalone no-Dataverse package
  structure.
- **Does the project use Power BI?** — [ADR-0001](../docs/adr/ADR-0001-estructura-modular-power-platform.md).
  Independent of the Dataverse branch; activates the `analytics/` module.

Everything else the interview asks (which components, which ALM platform,
Azure DevOps tracking) is a follow-up detail within one of those branches,
not a structural bifurcation itself.

The skill does not execute anything against `pac` yet — see
[`SKILL.md`](SKILL.md) for the `# TODO` markers left where
`scripts/dataverse/` and `scripts/powerbi/` will be wired in.
