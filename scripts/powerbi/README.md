# scripts/powerbi

PowerShell 7+ scripts for the Power BI module — see
[CONVENTIONS.md](../../docs/CONVENTIONS.md) for the scripting-language
decision, and its "Why the Power BI module has no pac scripts" section for
why this folder doesn't wrap `pac` the way `scripts/dataverse/` does.

Implemented:

- **`pbip-folder-init.ps1`** — prepares `analytics/`: creates the folder,
  writes the official PBIP `.gitignore` (`**/.pbi/localSettings.json`,
  `**/.pbi/cache.abf`), and writes a `README.md` with the manual Power BI
  Desktop steps to actually produce `<Report>.Report/` and
  `<Report>.SemanticModel/`. It does not and cannot create those two
  folders itself — see [ADR-0001](../../docs/adr/ADR-0001-estructura-modular-power-platform.md).

Still pending: Fabric Git sync helpers, for once a PBIP project has been
saved and needs to be deployed to a Fabric workspace.
