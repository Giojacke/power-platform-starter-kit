---
name: power-platform-scaffold
description: Scaffolds a new Power Platform project (Dataverse module with a Solution, or a standalone no-Dataverse package, plus an optional independent Power BI/Fabric module) by running a one-question-at-a-time discovery interview and driving the pac CLI. Trigger when the user asks to set up, initialize, bootstrap, or scaffold a new Power Platform, Power Apps, Power Automate, or Dataverse project from scratch.
---

# Power Platform Scaffold

This skill runs the discovery interview that decides which project structure
to scaffold, per the architecture decided in
[ADR-0001](../docs/adr/ADR-0001-estructura-modular-power-platform.md) (module
split: Dataverse vs. Power BI/Fabric) and
[ADR-0002](../docs/adr/ADR-0002-bifurcacion-sin-dataverse.md) (branch: does
the environment have a Dataverse database or not). Read both ADRs before
using this skill if you haven't — they document the research behind every
question below, including the official sources.

**Most of this skill now executes something real.** The Dataverse
"with Solution" scripts (`auth-connect.ps1`, `solution-init.ps1`,
`canvas-unpack.ps1`, `canvas-pack.ps1`, `solution-package.ps1` — see
[scripts/dataverse/README.md](../scripts/dataverse/README.md)) and the
Power BI folder scaffold (`scripts/powerbi/pbip-folder-init.ps1` — see
[scripts/powerbi/README.md](../scripts/powerbi/README.md)) are implemented
and safe to call. Wherever this skill would invoke something that doesn't
exist yet, it leaves a `# TODO: ... (pending)` marker instead of pretending
to run it.

## Ground rules

- Ask the questions below **one at a time, in order, never all at once**.
  Wait for the answer before asking the next question.
- When a question has a consequence the user can't undo later (e.g. the
  publisher prefix), say so **before** asking, not after.
- Never claim `pac` can do something it can't. If a step has no CLI
  automation today, say so plainly and point to the manual UI step instead —
  see the "no Dataverse" path and the Power BI path below for two concrete
  examples of this rule.
- Nothing gets executed against a real environment without the explicit
  confirmation in step 9.

## The interview

### 1. Project name

Ask for the project name. This becomes `<NombreProyecto>` (Dataverse path)
or `<NombreApp>` (no-Dataverse path) in the folder structures from both
ADRs, and the name used in `CLAUDE.md` / `.mcp.json` / `README_SETUP.md` at
the root of the generated project.

It's also the default for two things asked later, unless the user gives a
different value when you reach them: the publisher name in question 3
(`pac solution init` requires one), and the Solution's own folder name
(`src/<Solución>/` in the tree below — `pac solution init` has no
"solution name" parameter of its own, it's just the `-OutputDirectory` you
choose).

### 2. Does the environment have — or will it have — a Dataverse database enabled?

This is a real branching question (ADR-0002), asked **before** the publisher
prefix and solution name, because those two questions stop applying if the
answer is "no."

- **No** → skip questions 3 and 4 exactly as written below, and follow the
  **standalone package path** (see [No-Dataverse path](#no-dataverse-path)
  further down): no Solution, no publisher prefix, no solution name — each
  app and each flow is scaffolded as an independent package.
- **Yes** → continue normally with questions 3 and 4.

### 3. Publisher prefix *(Dataverse path only)*

Before asking, warn the user explicitly:

> The publisher prefix cannot be changed after the Solution is created. Pick
> it carefully now.

Then ask for the prefix (e.g. `contoso`). If the user has no preference,
suggest they still pick a real one for their org — this repo's own examples
use a generic placeholder precisely so nobody copies a throwaway value into
a real environment by accident.

`scripts/dataverse/solution-init.ps1` is implemented — call it once you also
have a publisher name (`pac solution init` requires both). Default the
publisher name to the project name from question 1 unless the user gives a
different one:

```
./scripts/dataverse/solution-init.ps1 -PublisherName <name> -PublisherPrefix <prefix> -OutputDirectory src/<Solución>
```

### 4. What components does the project have? *(Dataverse path only)*

Ask which of these the project has — multi-select, at least one required:

- Canvas App
- Power Automate (cloud flows)

Both are optional subfolders of the same Solution-based tree (`CanvasApps/`
and/or `Workflows/` under `src/<Solución>/`), not separate templates — see
ADR-0001. Selecting both is the reference case both ADRs use.

`pac solution init` has no notion of which components the solution will
hold, so create the selected subfolders as plain empty folders yourself
after running `solution-init.ps1`:

```
# Canvas App selected: mkdir src/<Solución>/CanvasApps (empty scaffold; populate later via canvas-unpack.ps1 once a .msapp exists)
# Power Automate selected: mkdir src/<Solución>/Workflows (empty scaffold; pac has no dedicated flow-scaffolding command)
```

### 5. Does the project use Power BI?

Independent branch from question 2 — see ADR-0001. A project can have
Dataverse, Power BI, both, or neither.

- **No** → skip to question 6.
- **Yes** → ask the follow-up: **does it need its own semantic model, or
  will it only consume data that already exists in Dataverse?**

  Be honest about what this skill can and cannot automate here:

  > `pac` does not generate PBIP files. A PBIP project (`<Report>.Report/` +
  > `<Report>.SemanticModel/`) is created by saving from Power BI Desktop
  > with the PBIP preview option enabled — there is no CLI command for it.
  > This skill only prepares the `analytics/` folder with the correct
  > `.gitignore` entries and a `README.md` with step-by-step instructions
  > for that manual save.

`scripts/powerbi/pbip-folder-init.ps1` is implemented — it creates
`analytics/`, writes the official PBIP `.gitignore`
(`**/.pbi/localSettings.json`, `**/.pbi/cache.abf`), and drops a
`README.md` with the exact Power BI Desktop steps. It does not create
`<Report>.Report/` or `<Report>.SemanticModel/` — nothing can, outside of
Power BI Desktop itself:

```
./scripts/powerbi/pbip-folder-init.ps1 -Path analytics
```

### 6. Which Power Platform environment will you connect to?

Ask for the environment URL. Call it a "Power Platform environment," not a
"Dataverse environment" — on the no-Dataverse path (question 2 = no) this
environment by definition has no Dataverse database, but `pac auth create`
still needs to target it (e.g. to work with the environment's Canvas Apps).

Then check whether an active `pac auth create` session already targets that
environment. **If there is no active session, PAUSE here.** Do not attempt
to simulate or fake authentication. Tell the user to run it themselves —
`scripts/dataverse/auth-connect.ps1` is implemented and wraps this, but it
still opens the same interactive/MFA browser flow, so the user has to be the
one running it, not this skill:

```
./scripts/dataverse/auth-connect.ps1 -EnvironmentUrl "<environment URL>"
```

This may require completing MFA in a browser window — something this skill
cannot do on the user's behalf. Wait for the user to confirm the profile is
active (`pac auth list` shows it) before continuing the interview.

### 7. Are you tracking work with Azure DevOps User Stories?

- **No** → skip to question 8.
- **Yes** → activate the `out/HU<id>_<etapa>_<fecha>` snapshot naming
  convention for this project, and ask for the Azure DevOps organization and
  project name so they can be recorded in the generated project's
  `.mcp.json`.

```
# TODO: write ado_organization / ado_project into the generated .mcp.json (pending)
```

### 8. Which ALM platform do you use to deploy across environments?

Offer exactly three options:

1. Azure DevOps Pipelines
2. GitHub Actions
3. "Just the local folder for now" (no pipeline scaffolded yet)

This selects which template under `pipelines/` gets copied into the
generated project for the **Dataverse module** (`dataverse-alm.yml`, per
ADR-0001) — or none, if option 3 is chosen. Neither `dataverse-alm.yml` nor
its GitHub Actions equivalent exist in this repo yet (see
[pipelines/README.md](../pipelines/README.md)), so this is unimplemented
regardless of which option is picked — don't claim otherwise:

```
# TODO: copy pipelines/dataverse-alm.yml (or the GitHub Actions equivalent) into the generated project (pending — template doesn't exist yet)
```

This question is about the **Dataverse module's** pipeline specifically.
It does not cover Power BI deployment — there is no
`pipelines/powerbi-fabric.yml` yet either, and none gets copied
automatically today even when the Power BI module is active:

```
# TODO: copy pipelines/powerbi-fabric.yml into the generated project when the Power BI module is active (pending — template doesn't exist yet)
```

On the no-Dataverse path (question 2 = no), option 1/2 don't have a
matching template at all — `dataverse-alm.yml` is a Solution deployment
pipeline (Power Platform Build Tools operate on Solutions), and this path
has no Solution. Until a standalone-specific pipeline template exists,
recommend option 3 for this path and say so plainly instead of implying
either platform choice already works here.

### 9. Summary and confirmation

Before running **any** `pac` command against the real environment, show a
summary of every answer collected above (name, Dataverse yes/no + publisher
prefix + components, Power BI yes/no + semantic model choice, environment
URL + auth profile status, Azure DevOps tracking + org/project, ALM
platform), and ask for **explicit confirmation** to proceed. Do not continue
past this point on an implicit "ok, continue" that isn't a direct
confirmation of this specific summary.

## No-Dataverse path

If question 2 was answered "no," the interview skips questions 3 and 4 as
written for the Dataverse path — but still ask, in plain conversation, which
of the two the project actually has (a Canvas App, Power Automate flows, or
both). ADR-0002's structure shows both `App/` and `Flows/` together because
that's its reference example, not because every standalone project has
both: only create the subfolder(s) for what the project actually has.

```
src/
└── <NombreApp>/
    ├── App/                    ← if there's a Canvas App: pac canvas unpack/pack
    │                              still works here, it doesn't depend on Dataverse
    ├── Flows/                  ← if there's Power Automate: one subfolder per flow,
    │   ├── <NombreFlujo1>/        named for whatever that flow actually is —
    │   └── <NombreFlujo2>/        <NombreFlujoN> is illustrative, not literal
    └── README.md               ← documents manual reconfiguration between
                                   environments (URLs, connection IDs)
```

Be honest about the Power Automate part of this path: **`pac` has no
command group for exporting or importing an individual cloud flow outside a
Solution.** The only Microsoft-supported flow lifecycle in `pac` is
solution-based (`pac solution export/import/pack/unpack`); it doesn't apply
here by definition, since this path has no Solution. Exporting/importing
each flow in `Flows/<NombreFlujoN>/` is a **manual step done from the Power
Automate UI** (export/import package). Do not tell the user this can be
scripted with `pac` — it can't, as of this skill's writing.

```
./scripts/dataverse/canvas-unpack.ps1 -MsappPath <path to .msapp> -SourcesPath src/<NombreApp>/App
# Flows/<NombreFlujoN>/ has no pac equivalent — document the manual UI export/import steps instead.
```

Question 5 (Power BI), 6 (environment/auth), 7 (Azure DevOps tracking), 8
(ALM platform), and 9 (summary/confirmation) still apply on this path
exactly as written above — none of them are Dataverse-specific.
