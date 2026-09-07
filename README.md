# power-platform-starter-kit

A generator repo: a skill plus templates that let an AI agent (or a technical
developer) scaffold Power Platform projects using the official CLI (`pac`).

**This repository is the tool, not the output.** It does not contain a Power
Platform project itself. It contains the templates, scripts, and skill
definition that, once used, *produce* the project structure described in
[`docs/adr/ADR-0001-estructura-modular-power-platform.md`](docs/adr/ADR-0001-estructura-modular-power-platform.md).

## Why this exists

Power Platform projects mix very different artifact types — Dataverse
solutions (Canvas Apps, Power Automate flows, tables) and Power BI/Fabric
reports — each with its own source format and ALM story. Setting up a new
project by hand means remembering the right folder layout, the right `pac`
commands, and the right pipeline template every time.

This repo turns that knowledge into a repeatable scaffold: a common skeleton
plus two independent, opt-in modules (Dataverse and Power BI/Fabric). See
ADR-0001 for the full research and reasoning behind that split.

## Two ways to use this repo

1. **Technical / direct mode** — a developer runs the scripts under
   [`scripts/`](scripts/) directly against the CLI (`pac`, Power BI Desktop)
   and copies the relevant templates from [`templates/`](templates/) by hand.
2. **AI-assisted mode** — an AI agent loads [`skill/SKILL.md`](skill/SKILL.md),
   runs its 9-question discovery interview one question at a time, and then
   drives the same scripts on the developer's behalf. The interview has two
   independent branching questions — does the environment have Dataverse
   enabled ([ADR-0002](docs/adr/ADR-0002-bifurcacion-sin-dataverse.md)), and
   does the project use Power BI
   ([ADR-0001](docs/adr/ADR-0001-estructura-modular-power-platform.md)) —
   plus follow-up questions (components, target environment, Azure DevOps
   tracking, ALM platform) and a final summary the user must confirm before
   anything runs against a real environment.

Both modes produce the same output: the module-based structure from
ADR-0001. Neither mode is a separate template — the modules and their
optional subfolders are the same regardless of who (or what) runs the setup.

## Repository structure

This is the structure of **this** generator repo. For the structure of the
*project* it produces, see ADR-0001.

```
power-platform-starter-kit/
├── README.md
├── LICENSE
├── .gitignore
│
├── docs/
│   ├── adr/
│   │   ├── ADR-0001-estructura-modular-power-platform.md
│   │   └── ADR-0002-bifurcacion-sin-dataverse.md
│   └── CONVENTIONS.md
│
├── templates/
│   ├── dataverse/        ← scaffolds for the Dataverse module (Canvas Apps,
│   │                        Power Automate, connection references) — planned,
│   │                        not written yet
│   └── powerbi/          ← scaffolds for the Power BI/Fabric module — planned,
│                            not written yet (pac can't generate PBIP anyway;
│                            see scripts/powerbi/ below)
│
├── scripts/
│   ├── dataverse/        ← implemented: pac CLI wrappers for auth, solution
│   │                        init, canvas pack/unpack, and solution packaging
│   └── powerbi/          ← implemented: prepares the analytics/ folder for a
│                            manual PBIP save in Power BI Desktop (no pac
│                            command exists for that step — see ADR-0001)
│
├── pipelines/            ← ALM pipeline templates: one for the Dataverse
│                            module, one for the Power BI module — planned,
│                            not written yet
│
└── skill/                ← SKILL.md: the 9-question discovery interview an
                             AI agent loads to run the scaffolding interactively
```

## Status

All three scaffolding modules have working scripts, tested locally:

- **Dataverse, with a Solution** — `scripts/dataverse/`: `auth-connect.ps1`,
  `solution-init.ps1`, `canvas-unpack.ps1`, `canvas-pack.ps1`,
  `solution-package.ps1`.
- **Dataverse, standalone (no Solution)** — reuses `canvas-unpack.ps1` /
  `canvas-pack.ps1` unchanged; Power Automate flows on this path have no
  `pac` equivalent and are documented as a manual step (see ADR-0002 and
  `SKILL.md`).
- **Power BI / Fabric** — `scripts/powerbi/pbip-folder-init.ps1` prepares
  `analytics/`; actually producing a PBIP project is a manual Power BI
  Desktop step, by design (see ADR-0001).

[`skill/SKILL.md`](skill/SKILL.md) wires all of the above into a single
discovery interview.

**Still missing**, tracked in each relevant folder's `README.md`:
`templates/` scaffolds (both modules), the `pipelines/` YAML templates for
either module, Fabric Git sync helper scripts, and writing collected answers
into a generated project's `.mcp.json`. None of these are silently assumed
to work — `SKILL.md` marks each with an explicit `# TODO`.

## License

[MIT](LICENSE)
