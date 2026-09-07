# Implementation Plan: Portar estándar agnóstico desde workspace CIAM

**Branch**: `001-portar-skills-rules` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-portar-skills-rules/spec.md`

## Summary

Portar al repo base el método de trabajo madurado en `df-ciam-workspace`, separando el conocimiento agnóstico de los datos del tenant corporativo. La portación es una operación de transformación de archivos Markdown/JSON: reemplazo de reglas 00-04, alta de reglas 05-09, tres skills renombradas y parametrizadas (`confluence-docs`, `jira-management`, `visual-docs`), skill custom `speckit-git-commit` adaptada, conexión Atlassian personal vía MCP oficial en `.mcp.json`, y extracción de referencias genéricas (trampas JQL, fixtures de prosa). El repo origen es solo lectura. La verificación central es mecánica: barrido de términos corporativos con resultado cero fuera de `specs/`, y suite de tests de `visual-docs` en verde.

## Technical Context

**Language/Version**: Markdown (documentos normativos y skills), JavaScript/Node.js ≥18 sin dependencias externas (scripts y tests de `visual-docs`), Bash (scripts spec-kit), JSON (configuración)

**Primary Dependencies**: spec-kit v0.13.0 (ya instalado en esta rama); MCP oficial de Atlassian `https://mcp.atlassian.com/v1/mcp/authv2` (runtime, OAuth por sesión — no es dependencia de build)

**Storage**: archivos versionados en el repo; sin base de datos

**Testing**: suite Node de `visual-docs` (`node .claude/skills/visual-docs/tests/run-tests.mjs`); verificación por barrido (`grep -riE 'cencosud|ciam|cencoflow|e98853f7' .claude .mcp.json`); inspección de frontmatter de skills

**Target Platform**: Claude Code CLI en macOS (uso personal); la plantilla debe funcionar clonada en cualquier proyecto personal

**Project Type**: plantilla de configuración agéntica (repo base, sin código de aplicación)

**Performance Goals**: N/A (contenido estático)

**Constraints**: repo origen `df-ciam-workspace` en modo solo lectura; cero secretos y cero identificadores de tenant en el repo; cero referencias corporativas fuera de `specs/`; sin push ni merge sin confirmación del dueño

**Scale/Scope**: 10 reglas, 3 skills portadas (~60 archivos, la mayor parte en `visual-docs`), 1 skill speckit custom, 1 referencia extraída, 1 entrada MCP, actualización de README

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` es el template sin ratificar (recién instalado por spec-kit v0.13.0): no hay principios formales que evaluar, el gate pasa por vacuidad. Ratificar la constitución queda declarado fuera de alcance en la spec.

Actúan como constitución de facto las reglas globales del usuario (`~/.claude-personal/rules/`), y este plan las respeta explícitamente: no inventar (parámetros sin valor se marcan `Pendiente de configurar`, nunca se rellenan), cero secretos en el repo (OAuth en runtime, nada persistido), español con formato estándar, commits `tipo: descripción` sin atribución, y confirmación previa a acciones irreversibles.

**Post-diseño (re-check)**: el diseño de Fase 1 no introduce violaciones — no agrega proyectos, dependencias externas ni réplicas nuevas más allá de la réplica deliberada reglas-proyecto/reglas-globales ya justificada en la spec.

## Project Structure

### Documentation (this feature)

```text
specs/001-portar-skills-rules/
├── spec.md              # Especificación (hecha)
├── plan.md              # Este archivo
├── research.md          # Fase 0: decisiones + mapa de portación archivo por archivo
├── data-model.md        # Fase 1: entidades del dominio de la plantilla
├── quickstart.md        # Fase 1: guía de validación end-to-end
├── contracts/
│   └── interfaces.md    # Fase 1: contratos de skill, regla y conexión MCP
├── checklists/
│   └── requirements.md  # Checklist de calidad de la spec (hecho)
└── tasks.md             # Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
.claude/
├── rules/
│   ├── 00-lenguaje-y-formato.md         # Reemplazada (versión CIAM depurada)
│   ├── 01-prevencion-alucinaciones.md   # Reemplazada
│   ├── 02-documentacion-y-entregables.md# Reemplazada (puntero a templates de confluence-docs)
│   ├── 03-seguridad-y-secretos.md       # Reemplazada
│   ├── 04-flujo-y-metodo.md             # Reemplazada
│   ├── 05-ramas-y-flujo-sdd.md          # Nueva (parametrizada)
│   ├── 06-nomenclatura-agentica.md      # Nueva (sufijo <proyecto> parametrizado)
│   ├── 07-continuidad-y-contexto.md     # Nueva (desde 08-continuity-and-context)
│   ├── 08-interaccion-y-decisiones.md   # Nueva (desde 09-interaction-and-decisions)
│   └── 09-punteros-y-replicas.md        # Nueva (desde 10-pointers-and-replicas, sin evidencia local)
│   # ejemplo-regla-por-ruta.md se retira (superada por reglas reales)
├── skills/
│   ├── confluence-docs/                 # ← confluence-ciam parametrizada
│   │   ├── SKILL.md
│   │   ├── reglas.md
│   │   ├── templates.md
│   │   └── ejemplos/ (5 archivos, depurados)
│   ├── jira-management/                 # ← jira-ciam-management parametrizada
│   │   ├── SKILL.md
│   │   ├── referencias/jql-trampas.md   # Extracción genérica de TR-01..TR-07
│   │   └── ejemplos/ (2 fixtures neutros)
│   ├── visual-docs/                     # ← visual-docs-ciam renombrada
│   │   ├── SKILL.md
│   │   ├── references/ (5)
│   │   ├── scripts/ (2)
│   │   ├── assets/starter/ (6)
│   │   └── tests/ (suites + fixtures)
│   ├── speckit-git-commit/              # ← custom CIAM adaptada
│   │   └── SKILL.md
│   └── speckit-*/                       # v0.13.0 (ya instaladas en esta rama)
.mcp.json                                # + servidor "atlassian" (MCP oficial, OAuth)
.specify/                                # Andamiaje spec-kit v0.13.0 (ya en esta rama)
README.md                                # Inventario actualizado
```

**Structure Decision**: se conserva la estructura existente del repo base (`.claude/rules`, `.claude/skills`, configuración en raíz). No se crean directorios nuevos de primer nivel; la referencia JQL vive dentro de `jira-management/referencias/` para que viaje con la skill (regla de punteros: un solo lugar, la skill remite).

## Complexity Tracking

Sin violaciones de constitución que justificar. La única tensión registrada — réplica deliberada de reglas de proyecto frente a las globales del usuario — está justificada en la spec (Assumptions): la copia del proyecto viaja con la plantilla al clonar; la global no.
