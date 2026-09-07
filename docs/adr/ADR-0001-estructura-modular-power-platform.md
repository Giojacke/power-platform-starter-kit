# ADR-0001: Estructura modular por tipo de proyecto Power Platform

**Estado:** Aceptado
**Fecha:** 2026-09-07
**Contexto del repo:** skill + plantillas para que una IA (o un desarrollador técnico) arme la estructura de un proyecto de Power Platform usando el CLI (`pac`)

---

## Contexto

Al diseñar el scaffolding surgió la pregunta de si el repo necesita **estructuras distintas** según el tipo de proyecto:

- Solo Canvas App (formularios y reglas de negocio en Power Fx)
- Solo Power Automate (automatización de procesos / integraciones, sin UI)
- Canvas App + Power Automate combinados (el caso real de trabajo: una Canvas App con integraciones de Automate, evolucionada por Historias de Usuario en Azure DevOps)
- Solo Power BI
- Power BI combinado con Canvas y/o Automate

Antes de fijar la carpeta `src/` del repo había que confirmar, con la documentación oficial vigente, si estos cinco casos son variaciones de una misma estructura o si necesitan árboles de carpetas separados.

## Investigación

**Canvas Apps y Power Automate viven en el mismo contenedor.** Según la documentación de ALM de Power Platform, una *Solución* de Dataverse empaqueta apps canvas, apps model-driven, flujos de Power Automate, tablas, roles de seguridad, conectores personalizados y web resources, todo bajo el mismo ciclo de exportación/empaquetado (`pac solution export/pack/unpack`). No hay una separación estructural entre "proyecto de canvas" y "proyecto de automate": son componentes opcionales de la misma solución. ([Application lifecycle management (ALM) basics with Power Platform - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/alm/basics-alm))

**El formato fuente de las Canvas Apps es `.pa.yaml`, generado por comandos que Microsoft marca como "Preview (Deprecated)".** El comando vigente y con soporte activo es la nueva *Power Platform Git Integration*, nativa en make.powerapps.com, que sincroniza los componentes de solución directo desde el navegador sin pasar por el CLI. Sin embargo, esa integración nativa es una experiencia de UI para makers — no expone una API o comando que un agente de IA pueda invocar por script. Los comandos `pac canvas pack` / `pac canvas unpack`, aunque catalogados como deprecados a favor de la integración nativa, siguen siendo el único camino programable para que una IA genere o regenere el código fuente de una Canvas App. ([Microsoft Power Platform CLI canvas command group](https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/canvas); [Power Platform Git Integration overview](https://learn.microsoft.com/en-us/power-platform/alm/git-integration/overview))

**Power BI no es un componente de Solución de Dataverse.** Vive en workspaces de Power BI/Fabric y su control de versiones se resuelve con un mecanismo completamente distinto: el formato **PBIP** (Power BI Desktop Project, en preview en 2026), que genera una carpeta `<Reporte>.Report/` (JSON del reporte) y `<Reporte>.SemanticModel/` (modelo tabular en TMDL), versionadas vía *Fabric Git Integration* — no vía `pac` ni vía Azure DevOps pipelines de Power Platform. La única relación entre un proyecto Power BI y uno de Dataverse es a nivel de datos (el modelo semántico puede consumir tablas de Dataverse como fuente), nunca a nivel de carpetas o de pipeline de despliegue. ([Power BI Desktop projects (PBIP) - Microsoft Learn](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview))

**El ALM Accelerator para Power Platform está deprecado.** Microsoft ya no lo mantiene y recomienda en su lugar *Pipelines nativos de Power Platform* combinados con *Power Platform Build Tools* (Azure DevOps) o *GitHub Actions*, según el nivel de control granular que se necesite. Este repo apunta a ese segundo camino (Build Tools / GitHub Actions + `pac`), porque es el único que permite orquestación completa por script. ([ALM Accelerator for Power Platform (Deprecated) - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/guidance/alm-accelerator/overview))

## Decisión

No se crean cinco estructuras separadas. Se define un **esqueleto común** (el mismo para todo proyecto: `CLAUDE.md`, `.mcp.json`, `README_SETUP.md`, `.gitignore`, `.claude/`, `docs/`, `out/`) más **dos módulos independientes** que se activan según lo que responda el usuario en la entrevista de la skill:

| Módulo | Cubre | Herramienta de ALM | Se activa cuando el proyecto tiene... |
|---|---|---|---|
| **Dataverse** | Canvas Apps, Power Automate, tablas, roles, conectores — todo dentro de `src/<Solución>/` | `pac` CLI + Power Platform Build Tools / GitHub Actions | Canvas App sola, Automate solo, o ambos combinados (son el mismo módulo con carpetas opcionales) |
| **Power BI / Fabric** | Reportes y modelos semánticos, en una carpeta raíz paralela `analytics/<Reporte>.Report/` y `analytics/<Reporte>.SemanticModel/` | Fabric Git Integration / Fabric APIs | El proyecto incluye Power BI, solo o junto al módulo Dataverse |

Dentro del módulo Dataverse, "solo canvas", "solo automate" y "combinado" **no son variantes de estructura**: son el mismo árbol de carpetas con `CanvasApps/` y/o `Workflows/` presentes según aplique. La skill solo necesita preguntar qué componentes tiene el proyecto para decidir qué subcarpetas crear — no qué plantilla usar.

### Estructura de carpetas resultante

```
<NombreProyecto>/
├── CLAUDE.md
├── .mcp.json
├── README_SETUP.md
├── .gitignore
│
├── .claude/
│   ├── skills/
│   ├── settings.local.json
│   └── commands/
│
├── docs/
│   ├── adr/                          ← este archivo vive aquí (docs/adr/0001-...)
│   ├── diagramas/
│   └── <Proyecto>_Technical_Design_Document.md
│
├── src/                               ← MÓDULO DATAVERSE (opcional, activable)
│   └── <Solución>/
│       ├── CanvasApps/                ← presente solo si el proyecto tiene Canvas App
│       ├── Workflows/                 ← presente solo si el proyecto tiene Power Automate
│       ├── Entities/
│       ├── environmentvariabledefinitions/
│       ├── Roles/
│       └── Other/
│
├── analytics/                         ← MÓDULO POWER BI / FABRIC (opcional, activable, independiente)
│   └── <Reporte>.Report/
│   └── <Reporte>.SemanticModel/
│
├── pipelines/
│   ├── dataverse-alm.yml              ← pac + Build Tools, solo si el módulo Dataverse está activo
│   └── powerbi-fabric.yml             ← Fabric deployment, solo si el módulo Power BI está activo
│
└── out/                                ← artefactos regenerables (zips, snapshots por HU, logs)
```

El caso real de trabajo (Canvas App + integraciones de Automate, evolucionado por HU de Azure DevOps) corresponde al módulo Dataverse con ambas subcarpetas activas, y sigue siendo el ejemplo de referencia (`examples/`) del repo.

## Consecuencias

- La entrevista de la skill necesita una sola pregunta de bifurcación real: *"¿el proyecto usa Power BI?"* — el resto (canvas, automate, o ambos) se resuelve con preguntas de qué componentes tiene, no de qué plantilla cargar.
- El repo necesita dos pipelines de ejemplo, no uno: uno para el módulo Dataverse (`pac` + Build Tools/GitHub Actions) y otro para el módulo Power BI (Fabric), documentados por separado porque no comparten herramienta ni entorno de despliegue.
- Se documenta explícitamente por qué el repo usa `pac canvas pack/unpack` pese a estar marcados como deprecados: es una decisión deliberada para mantener el scaffolding automatizable por IA, no un descuido. Cualquier colaborador de la comunidad que lea el código debe encontrar esta razón aquí, no adivinarla.
- Cuando la integración nativa de Git en Power Platform exponga una vía programable (hoy no la tiene), esta decisión debe revisarse en una ADR nueva, no reescribiendo esta.

## Referencias

- [Application lifecycle management (ALM) basics with Power Platform - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/alm/basics-alm)
- [Solution concepts with Power Platform - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/alm/solution-concepts-alm)
- [Microsoft Power Platform CLI canvas command group - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/canvas)
- [Source code files for canvas apps (pa.yaml) - Power Apps | Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/power-apps-yaml)
- [Power Platform Git Integration overview - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/alm/git-integration/overview)
- [ALM Accelerator for Power Platform (Deprecated) - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/guidance/alm-accelerator/overview)
- [Power BI Desktop projects (PBIP) - Microsoft Learn](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview)
