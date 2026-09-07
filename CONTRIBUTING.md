# Contributing

Thanks for considering a contribution to `power-platform-starter-kit`. This
is a generator repo — see the root [README](README.md) first if you
haven't: it produces Power Platform project scaffolds, it isn't one itself.

## Setting up your environment

You need two things on `PATH`:

- **Power Platform CLI (`pac`)** — install it via the .NET tool, the VS Code
  extension, or the Windows MSI (see Microsoft's
  [install guide](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction)).
  Verify with:
  ```
  pac --version
  ```
- **PowerShell 7+ (pwsh)** — every script in this repo targets it, not
  Windows PowerShell 5.1 or bash (see
  [docs/CONVENTIONS.md](docs/CONVENTIONS.md) for why). Verify with:
  ```
  pwsh -v
  ```

You don't need a real Dataverse environment or Power BI Desktop to
contribute to most of this repo — only to actually exercise
`auth-connect.ps1` / `solution-init.ps1` and similar against a live tenant,
or to follow through the manual steps `pbip-folder-init.ps1`'s generated
README documents.

## Testing a script before opening a PR

Run every script you touch against a scratch/temp directory — **never the
repo root**. Several scripts create real files and folders (a Solution
project, an `analytics/` folder, a `.msapp`). `.gitignore`'s `/analytics/`
and `/src/` entries exist as a safety net for exactly this mistake — they're
not a substitute for testing correctly in the first place.

```powershell
# Scratch-directory pattern
$testDir = Join-Path $env:TEMP "pp-scaffold-test-$(Get-Random)"
New-Item -ItemType Directory -Path $testDir | Out-Null
Push-Location $testDir
# ... run the script you're testing here ...
Pop-Location
Remove-Item -Recurse -Force $testDir
```

At minimum, before any PR that touches a `.ps1` file, parse-check it. This
catches syntax errors without needing `pac` installed or a real environment:

```powershell
$errors = $null; $tokens = $null
[System.Management.Automation.Language.Parser]::ParseFile("path/to/script.ps1", [ref]$tokens, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { $errors } else { "OK" }
```

If your script actually calls `pac` (or could), also run it for real against
a scratch directory and, where relevant, a non-production environment — the
parse-check only proves the syntax is valid, not that the script does what
it claims.

## Commit convention

- Commit messages: **Spanish**.
- Code and docs (README files, `CONVENTIONS.md`, `SKILL.md`, script
  comments/help): **English**. ADRs are the one exception — write new ones
  in Spanish, matching ADR-0001 and ADR-0002.
- **One commit per logical correction or change**, not everything batched
  into one. A PR that fixes a bug, adds a script, and updates a README is
  three commits, not one — see this repo's own history for examples of that
  split (e.g. the audit pass that preceded this file).

## Honesty checklist

Before you claim a script or an interview step in `SKILL.md` automates
something, check whether it actually does:

- If you add a script that wraps a real `pac` (or Fabric) command, say which
  command, and show it doing so — that's the whole point of a wrapper.
- If it doesn't — because no such command exists, or because a step is
  genuinely manual (a browser MFA flow, a Power BI Desktop save, a Power
  Automate UI export) — **say so explicitly**, and mark what's missing with
  a `# TODO: ... (pending)` comment instead of implying it already works.
- This isn't a style preference, it's a load-bearing precedent set by
  [ADR-0001](docs/adr/ADR-0001-estructura-modular-power-platform.md) (`pac`
  cannot generate PBIP files — that's a manual Power BI Desktop step) and
  [ADR-0002](docs/adr/ADR-0002-bifurcacion-sin-dataverse.md) (`pac` has no
  command for exporting/importing a Power Automate flow outside a Solution —
  that's a manual Power Automate UI step). A PR that overclaims automation
  will be asked to fix the claim before merge.

## Naming new scripts

Follow `<domain>-<verb>.ps1`, kebab-case — see
[docs/CONVENTIONS.md](docs/CONVENTIONS.md) ("Script file naming") for the
established examples (`solution-init.ps1`, `canvas-unpack.ps1`,
`pbip-folder-init.ps1`, ...). The one exception is a shared, dot-sourced
helper file like `_common.ps1` (leading underscore) — it isn't meant to be
run directly, so it doesn't need to fit the pattern.

## When to propose a new ADR

Most changes fit inside an existing module and don't need one — a new
script, a README fix, a bug fix in an existing wrapper.

Open a new ADR **before** writing any code when your change introduces a
real structural bifurcation — a new branch in the discovery interview that
changes what gets scaffolded, the way Power BI did in ADR-0001 or the
Dataverse yes/no split did in ADR-0002. A change that just adjusts something
inside an existing module isn't this — if you're unsure which one your
change is, say so in the PR description before writing an ADR.

When you do need one:

1. Add it as a new file: `docs/adr/000X-titulo.md` (next sequential number).
2. Follow the same section structure as ADR-0001 and ADR-0002: **Contexto /
   Investigación / Decisión / Consecuencias / Referencias**.
3. Write it in Spanish, matching the existing two.
4. Open the PR with the ADR first — the code that implements it comes after,
   once the decision itself is settled.
5. **Never edit an already-accepted ADR.** If a later change supersedes one,
   write a new ADR that says so (see ADR-0002's own "Consecuencias" section
   for an example of how it handles this for its own future revision).
