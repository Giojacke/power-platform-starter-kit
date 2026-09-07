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
   [`scripts/`](scripts/) directly against the CLI (`pac`, Fabric tooling) and
   copies the relevant templates from [`templates/`](templates/) by hand.
2. **AI-assisted mode** — an AI agent loads the skill defined under
   [`skill/`](skill/), runs a short discovery interview (does the project use
   Power BI? does it have a Canvas App, a Power Automate flow, or both?), and
   then drives the same scripts and templates on the developer's behalf.

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
│   │   └── ADR-0001-estructura-modular-power-platform.md
│   └── CONVENTIONS.md
│
├── templates/
│   ├── dataverse/        ← scaffolds for the Dataverse module (Canvas Apps,
│   │                        Power Automate, connection references)
│   └── powerbi/          ← scaffolds for the Power BI/Fabric module (PBIP:
│                            .Report/, .SemanticModel/)
│
├── scripts/
│   ├── dataverse/        ← pac CLI wrapper scripts (auth, solution init,
│   │                        canvas pack/unpack, packaging)
│   └── powerbi/          ← Fabric/PBIP wrapper scripts
│
├── pipelines/            ← ALM pipeline templates: one for the Dataverse
│                            module, one for the Power BI module
│
└── skill/                ← the SKILL.md discovery interview an AI agent
                             loads to run the scaffolding interactively
```

## Status

Early scaffolding stage. Folder structure and placeholders are in place;
script and skill content is being filled in incrementally. See each folder's
`README.md` for what is planned there.

## License

[MIT](LICENSE)
