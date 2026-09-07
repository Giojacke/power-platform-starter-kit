# scripts/dataverse

`pac` CLI wrapper scripts for the Dataverse module, written in PowerShell 7+
(pwsh) — see [CONVENTIONS.md](../../docs/CONVENTIONS.md) for why. Each
script is a thin, honest wrapper: it validates that `pac` is installed,
forwards your parameters, and surfaces `pac`'s own exit code — it does not
hide or reinterpret what `pac` does.

Implemented so far (the "with Solution" path, ADR-0001 / ADR-0002):

- **`_common.ps1`** — shared helpers (`Assert-PacCliInstalled`, `Invoke-Pac`), dot-sourced by the scripts below, not run directly.
- **`auth-connect.ps1`** — wraps `pac auth create` (interactive, device code, or service principal).
- **`solution-init.ps1`** — wraps `pac solution init`; warns that the publisher prefix is irreversible.
- **`canvas-unpack.ps1`** / **`canvas-pack.ps1`** — wrap `pac canvas unpack` / `pac canvas pack`. Used deliberately despite being marked deprecated by Microsoft — see ADR-0001.
- **`solution-package.ps1`** — wraps `pac solution pack` to produce a deployable `solution.zip`.

Still pending: the standalone no-Dataverse path (ADR-0002) doesn't need new
scripts for its Canvas App source — `canvas-unpack.ps1` / `canvas-pack.ps1`
already work there unchanged, since they don't depend on Dataverse. Its
`Flows/` folder has no `pac` equivalent and is documented as a manual step
in [`SKILL.md`](../../skill/SKILL.md).
