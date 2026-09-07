# ADR-0002: Bifurcación por disponibilidad de base de datos Dataverse

**Estado:** Aceptado
**Fecha:** 2026-09-07
**Relacionado con:** ADR-0001 (no la reemplaza, la extiende con un eje nuevo)

---

## Contexto

Al diseñar la entrevista de la skill surgió la pregunta: ¿qué pasa si el proyecto usa **SharePoint** (u otro conector) como backend de datos en vez de tablas de Dataverse? ADR-0001 ya resolvió que Canvas Apps y Power Automate combinan libremente dentro del módulo Dataverse — pero no distinguía si el *origen de datos* de la app cambia la estructura. La investigación mostró que el origen de datos (Dataverse vs. SharePoint vs. SQL, etc.) no es lo que determina la estructura: lo que la determina es si el **entorno tiene una base de datos de Dataverse habilitada o no**, independientemente de dónde vivan los datos de negocio.

## Investigación

**Una Canvas App conectada a SharePoint puede empaquetarse en una Solución sin problema, siempre que el entorno tenga Dataverse habilitado.** La Solución es el contenedor de ALM; el conector que use la app (SharePoint, SQL, Dataverse) es independiente de eso. Microsoft incluso está empujando a que canvas apps y flujos se agreguen a soluciones por defecto en cualquier entorno con Dataverse, sin importar su fuente de datos. ([Add canvas apps and cloud flows to solutions by default for a healthy ALM (preview) - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/alm/canvas-apps-solution-default))

**El problema real aparece cuando el entorno NO tiene base de datos de Dataverse en absoluto** — un escenario común quen proyectos que evitan Dataverse deliberadamente para no requerir licenciamiento premium, usando solo SharePoint u otros conectores estándar. La documentación oficial de Power Apps es explícita al respecto:

> "Canvas app packages don't support ALM and should only be used for basic import and export capabilities when Dataverse isn't accessible."

En ese escenario: no hay Soluciones (son un concepto de Dataverse), no hay `environmentvariabledefinitions/` ni `Roles/` (son componentes de Solución), no hay distinción managed/unmanaged, y cada flujo de Power Automate se exporta como su propio paquete independiente en vez de vivir dentro de un contenedor compartido. ([Overview of exporting and importing canvas apps - Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/export-import-app))

## Decisión

Se añade una pregunta de bifurcación **temprana** en la entrevista de la skill, antes incluso del publisher prefix y el nombre de la solución (porque esas preguntas dejan de aplicar si la respuesta es "no"):

> **¿El entorno tiene — o va a tener — base de datos de Dataverse habilitada?**

- **Sí →** camino ya descrito en ADR-0001: módulo Dataverse completo, con Solución, publisher prefix, `Entities/`, `Roles/`, `environmentvariabledefinitions/`, etc. El conector que use la app (Dataverse, SharePoint, SQL) no cambia nada de esto.
- **No →** nuevo sub-módulo "paquete standalone": sin Solución, sin publisher prefix, sin nombre de solución. Cada app y cada flujo se tratan como paquetes independientes.

### Estructura de carpetas para el camino sin Dataverse

```
src/
└── <NombreApp>/
    ├── App/                    ← fuente de la canvas app (.pa.yaml vía pac canvas unpack/pack — 
    │                              esto SÍ sigue funcionando igual, no depende de Dataverse)
    ├── Flows/
    │   ├── <NombreFlujo1>/     ← paquete de exportación individual de ese flujo
    │   └── <NombreFlujo2>/
    └── README.md               ← documenta la reconfiguración MANUAL entre entornos 
                                   (URLs, IDs de conexión) porque no existen environment 
                                   variables ni connection references de Solución en este camino
```

El eje de Power BI de ADR-0001 sigue siendo completamente independiente de esta decisión: un proyecto sin Dataverse puede igual tener el módulo Power BI/Fabric activo, y uno con Dataverse puede no tenerlo.

## Consecuencias

- La entrevista de la skill pasa a tener **dos preguntas de bifurcación real** (no una): "¿tiene Dataverse?" (este ADR) y "¿usa Power BI?" (ADR-0001). El resto de preguntas (qué componentes tiene, ALM platform, HU de Azure DevOps) se ajustan según la rama, pero no son bifurcaciones de estructura en sí mismas.
- El repo necesita una plantilla y unos scripts adicionales para el camino sin Dataverse (`templates/dataverse-standalone/` o similar), distintos de los de `templates/dataverse/` que asumen Solución.
- **Queda pendiente de investigar antes de escribir esos scripts:** si `pac` cli tiene un comando directo para exportar/importar un flujo de Power Automate de forma individual fuera de una solución, o si ese paso solo se puede hacer desde la UI/API de Power Automate. No se debe prometer automatización total en el `SKILL.md` hasta confirmar esto — mismo criterio de honestidad que se aplicó con Power BI/PBIP en ADR-0001.
- Este ADR no reemplaza ni reabre ADR-0001; lo complementa. Si en el futuro cambia el comportamiento de `pac` respecto a flujos sin solución, eso amerita un ADR-0003, no una edición de este archivo.

## Referencias

- [Add canvas apps and cloud flows to solutions by default for a healthy ALM (preview) - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/alm/canvas-apps-solution-default)
- [Overview of exporting and importing canvas apps - Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/export-import-app)
- [Microsoft Power Platform CLI canvas command group - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/canvas)
- [Microsoft Power Platform CLI solution command group - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution)
