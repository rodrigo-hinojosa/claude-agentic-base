# Implementation Plan: Portar agentes del workspace CIAM al estándar de la base

**Branch**: `002-portar-agentes` | **Date**: 2026-09-07 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-portar-agentes/spec.md`

## Summary

Portar los tres agentes del workspace CIAM en tres fases con entrega incremental: (1) el trío del patrón plan→gate→ejecución (`product-owner`, `atlassian-executor`, contract `write-plan` en el directorio nuevo `.claude/contracts/`, más la edición de equivalencia en `confluence-docs`); (2) el agente `developer` con su infraestructura completa (skill `development-repositories` de ~5.900 líneas parametrizada, contract `publish-authorization`, contratos de diseño adaptados en esta spec); (3) retiro de los cuatro agentes genéricos con reescritura de la delegación de la regla 04 y actualización del README. La transformación sigue el mapa producido por el workflow de clasificación (5 lectores, 06-09-2026) consolidado en `research.md`.

**Método de ejecución (clarificación 07-09-2026)**: cada fase recupera sus artefactos de la rama `backup/002-portar-agentes` —que conserva la portación completa de la primera corrida— y los **re-verifica contra los criterios de aceptación de su propia historia**, corrigiendo o re-derivando lo que falle. No se re-portan desde el workspace de origen. La verificación es la del quickstart y se ejecuta en esta corrida: barridos corporativos en cero, prueba de ida y vuelta del hash, verificación tipada de la autorización de publicación, `bash -n` más corrida funcional de los 8 scripts contra el fixture sintético, y resolución de todos los punteros (absolutos y relativos).

## Technical Context

**Language/Version**: Markdown (agentes, contracts, skill); Bash (8 scripts, ~4.800 líneas — el origen documenta ejecución vía `bash -c` por incompatibilidad zsh, restricción que se conserva); sin dependencias externas

**Primary Dependencies**: artefactos ya portados por el feature 001 (skills `jira-management`, `confluence-docs`, reglas 05/06/09, servidor MCP `atlassian` con tools 1:1 verificadas); `shasum`/`sed` del sistema para el mecanismo de hash

**Storage**: archivos versionados; sin base de datos

**Testing**: prueba de ida y vuelta del hash (`sed -n | shasum -a 256` sobre plan sintético); verificación tipada de `publish-authorization` con bloques sintéticos; `bash -n` por script **más corrida funcional** de `status`/`fetch`/`pull` contra el fixture sintético de la skill, comparando cada fila con lo que el fixture declara esperado (clarificación 07-09-2026); barridos grep del quickstart; enumeración de punteros citados y verificación de existencia, incluidos los enlaces markdown relativos

**Target Platform**: Claude Code CLI en macOS; plantilla clonable a proyectos personales

**Project Type**: plantilla de configuración agéntica (repo base)

**Performance Goals**: N/A (contenido estático y scripts de operación puntual)

**Constraints**: repo origen solo lectura; cero referencias corporativas fuera de `specs/` (FR-014); cero punteros a rutas del origen (regla 09); sin push/merge sin confirmación; las dos decisiones de alcance del dueño no se reabren

**Scale/Scope**: 3 agentes (~260 líneas), 2 contracts vivos (~135), 2 contratos de diseño (~130), 1 skill de ~5.900 líneas (8 scripts, 6 docs, 4 ejemplos, template, índice, catálogo), regla 04 y README editados, 4 agentes retirados

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.* Evaluado contra la constitución v1.0.0 (ratificada 2026-09-06).

| Principio | Evaluación | Resultado |
| --- | --- | --- |
| I. Verificación antes de afirmación | El mapa de transformaciones proviene de lectura completa de los 5 artefactos con verificación cruzada contra la base (workflow del 06-09-2026); los vacíos (catálogo de repos, tableros, roster) se declaran `Pendiente de configurar`, nunca se rellenan. **La recuperación desde el respaldo no exime de verificar**: cada artefacto recuperado se somete a las verificaciones de su historia en esta corrida, y la evidencia se produce aquí — citar las evidencias del respaldo sin re-ejecutarlas sería afirmar sin verificar | PASS |
| II. Referenciar, no duplicar | Los agentes citan contracts sin replicarlos; las entidades del plan se definen en el contract como su autoridad única (el origen las tenía como copia declarada de una spec; aquí se consolida la autoridad); las copias declaradas se re-anclan con fuente y fecha de portación. La reutilización de la rama de respaldo está declarada en la spec (Assumptions) y en este plan, con su fuente y su fecha | PASS |
| III. Trazabilidad SDD | Rama `002-portar-agentes`, flujo `specify` → `clarify` → `plan` → `tasks` → `implement` recorrido **con validación del dueño entre fases** (reinicio del 07-09-2026), sin commits a `main` | PASS |
| IV. Escritura con gate | Los artefactos portados son precisamente la implementación de este principio (gates, hash, catálogo cerrado, relectura post-escritura); ninguna operación de la portación escribe a sistemas compartidos | PASS |
| V. Plantilla agnóstica y parametrizada | Catálogo de repos vacío con procedimiento, filas plantilla en el catálogo de operaciones, nombres sin sufijo (precedente D2), barrido FR-014 como criterio de cierre | PASS |

**Nota al Principio II**: el agente `developer` citará contratos de diseño en `specs/002-portar-agentes/contracts/` — punteros a artefactos de esta misma feature que existirán antes que el agente (orden de tareas lo garantiza). Es el patrón del origen (autoridad de diseño en la spec, autoridad runtime en `.claude/contracts/`), conforme a la regla 09.

**Post-diseño (re-check, 07-09-2026)**: el diseño de Fase 1 no introduce violaciones; el único directorio nuevo (`.claude/contracts/`) está exigido por la spec (FR-003) y documentado en README (FR-013). Las tres clarificaciones se evaluaron contra los principios: la citación de agentes de la configuración personal en la regla 04 cumple el Principio II (es un puntero con procedencia declarada, no una promesa de la plantilla) y el V (la plantilla no promete lo que no versiona); el método de recuperación desde el respaldo cumple el I por la re-verificación obligatoria; la exigencia de corrida funcional sobre los scripts refuerza el Principio I al sustituir una verificación sintáctica por una de comportamiento.

## Project Structure

### Documentation (this feature)

```text
specs/002-portar-agentes/
├── spec.md              # Especificación (hecha)
├── plan.md              # Este archivo
├── research.md          # Fase 0: decisiones + mapa de transformaciones por artefacto
├── data-model.md        # Fase 1: entidades (plan, marca, autorización, catálogo, índice)
├── quickstart.md        # Fase 1: guía de validación end-to-end
├── contracts/
│   ├── interfaces.md    # Fase 1: contratos de frontmatter, directorio contracts/ y verificación
│   ├── developer-flow.md    # Implement (FR-010): contrato de diseño adaptado del origen
│   └── operation-report.md  # Implement (FR-010): contrato de diseño adaptado del origen
├── checklists/requirements.md  # Hecho
└── tasks.md             # Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
.claude/
├── agents/
│   ├── product-owner.md         # US1 ← product-owner-ciam parametrizado
│   ├── atlassian-executor.md    # US1 ← atlassian-executor-ciam parametrizado
│   └── developer.md             # US2 ← developer-ciam parametrizado
│   # Se retiran: arquitecto.md, documentador.md, revisor-codigo.md, revisor-proyecto.md (US3)
├── contracts/                   # Directorio NUEVO
│   ├── write-plan.md            # US1 ← contract parametrizado (entidades inlined)
│   └── publish-authorization.md # US2 ← contract parametrizado
├── skills/
│   ├── confluence-docs/SKILL.md # US1: edición de equivalencia en modo publicar
│   └── development-repositories/  # US2 ← development-repositories-ciam parametrizada
│       ├── SKILL.md
│       ├── layout.md, repositories.md (catálogo plantilla), spec-index.md (plantilla),
│       │   provenance.md, divergences.md
│       ├── templates/development-spec.md
│       ├── scripts/ (8 × .sh, parametrizados vía catálogo)
│       └── examples/ (4, neutralizados)
├── rules/04-flujo-y-metodo.md   # US3: sección de delegación reescrita + divergencia declarada
README.md                        # US3: sección de agentes + contracts
```

**Structure Decision**: se introduce `.claude/contracts/` como único directorio nuevo (autoridad runtime entre agentes, patrón del origen exigido por FR-003). La skill `development-repositories` conserva su estructura interna de origen — sus nombres ya cumplen la regla 06 (inglés) — con el catálogo y el índice convertidos en plantillas parametrizadas.

## Complexity Tracking

Sin violaciones de constitución. Dos riesgos de complejidad asumidos y declarados: (1) los 8 scripts bash suman ~4.800 líneas con acoplamiento potencial al layout multi-repo del origen — el tratamiento es parametrizar vía catálogo y declarar límites, no reescribir los scripts (FR-008); (2) el retiro de los genéricos hace divergir la regla 04 del set global del usuario — divergencia declarada conforme regla 09, decisión informada del dueño.
