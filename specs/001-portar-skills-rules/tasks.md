# Tasks: Portar estándar agnóstico desde workspace CIAM

**Input**: Design documents from `/specs/001-portar-skills-rules/`
**Prerequisites**: plan.md, spec.md, research.md (mapa de portación), data-model.md, contracts/interfaces.md, quickstart.md

**Origen (solo lectura)**: `/Users/rodrigo-hinojosa/Documents/Cencosud/Develop/CIAM/df-ciam-workspace` — en adelante `$CIAM`.

**Tests**: la spec no pide TDD; la única suite es la de `visual-docs` (ya existente, debe pasar tras el renombre) más las verificaciones mecánicas del quickstart.

## Phase 1: Setup

- [X] T001 Verificar precondiciones: rama `001-portar-skills-rules` activa, `$CIAM` legible, `node --version` ≥ 18, `git status` sin cambios ajenos al feature

## Phase 2: Foundational

- [X] T002 Reescribir `.mcp.json`: eliminar `ejemplo-stdio` y `ejemplo-http`, agregar servidor `atlassian` exacto al Contrato 3 de `specs/001-portar-skills-rules/contracts/interfaces.md` (sin credenciales)

## Phase 3: User Story 1 — Reglas de trabajo depuradas y completas (P1)

**Goal**: `.claude/rules/` queda con exactamente las reglas 00-09 en versión CIAM depurada, sin referencias corporativas.

**Independent Test**: `ls -1 .claude/rules/` muestra los 10 archivos del Contrato 2; barrido corporativo sobre `.claude/rules/` devuelve cero.

- [X] T003 [P] [US1] Portar `$CIAM/.claude/rules/00-lenguaje-y-formato.md` → `.claude/rules/00-lenguaje-y-formato.md` (copia; verificar cero referencias corporativas)
- [X] T004 [P] [US1] Portar `$CIAM/.claude/rules/01-prevencion-alucinaciones.md` → `.claude/rules/01-prevencion-alucinaciones.md` (copia directa)
- [X] T005 [P] [US1] Portar `$CIAM/.claude/rules/02-documentacion-y-entregables.md` → `.claude/rules/02-documentacion-y-entregables.md` depurada según research.md (sin URL Confluence, sin board 14186, puntero a `.claude/skills/confluence-docs/templates.md`, remisión a `jira-management`)
- [X] T006 [P] [US1] Portar `$CIAM/.claude/rules/03-seguridad-y-secretos.md` → `.claude/rules/03-seguridad-y-secretos.md` (copia directa)
- [X] T007 [P] [US1] Portar `$CIAM/.claude/rules/04-flujo-y-metodo.md` → `.claude/rules/04-flujo-y-metodo.md` (ejemplo de subagente → `arquitecto`)
- [X] T008 [P] [US1] Portar `$CIAM/.claude/rules/05-ramas-y-flujo-sdd.md` → `.claude/rules/05-ramas-y-flujo-sdd.md` parametrizada (clave Jira `<CLAVE-XXX>` condicional, sin anécdotas ni ejemplos del repo origen)
- [X] T009 [P] [US1] Portar `$CIAM/.claude/rules/06-nomenclatura-agentica.md` → `.claude/rules/06-nomenclatura-agentica.md` parametrizada (`<proyecto>` en vez de `ciam`, ejemplos genéricos, sin roster ni deuda del origen; matiz de idioma según research.md hallazgo 5)
- [X] T010 [P] [US1] Portar `$CIAM/.claude/rules/08-continuity-and-context.md` → `.claude/rules/07-continuidad-y-contexto.md` (renumerar y renombrar; contenido tal cual)
- [X] T011 [P] [US1] Portar `$CIAM/.claude/rules/09-interaction-and-decisions.md` → `.claude/rules/08-interaccion-y-decisiones.md` (renumerar y renombrar; contenido tal cual)
- [X] T012 [P] [US1] Portar `$CIAM/.claude/rules/10-pointers-and-replicas.md` → `.claude/rules/09-punteros-y-replicas.md` (sin secciones de evidencia local ni referencias del origen)
- [X] T013 [US1] Eliminar `.claude/rules/ejemplo-regla-por-ruta.md`; verificar set exacto de 10 archivos y barrido corporativo cero sobre `.claude/rules/`; commit `feat: portar reglas 00-09 depuradas desde workspace CIAM`

**Checkpoint**: US1 entregable por sí sola (las reglas citan `confluence-docs/templates.md`, que resuelve al cerrar US2; verificación final de punteros en T027).

## Phase 4: User Story 2 — Gestión documental y de tablero con Atlassian personal (P2)

**Goal**: `confluence-docs` y `jira-management` operativas con parámetros `Pendiente de configurar`, tools `mcp__atlassian__*` y cloudId resuelto en runtime.

**Independent Test**: greps de SC-005 en cero; frontmatter con `name`/`description`; sección de parámetros presente en ambas skills.

- [X] T014 [P] [US2] Portar `$CIAM/.claude/skills/confluence-ciam/SKILL.md` → `.claude/skills/confluence-docs/SKILL.md` según research.md (frontmatter con `name: confluence-docs`, allowed-tools `mcp__atlassian__*` del Contrato 1, cloudId en runtime, espacio como parámetro pendiente, sección Parámetros por proyecto del Contrato 4)
- [X] T015 [P] [US2] Portar `$CIAM/.claude/skills/confluence-ciam/reglas.md` → `.claude/skills/confluence-docs/reglas.md` (regla 14 parametrizada, regla 12 remite a `jira-management`, línea base de prosa `Pendiente de recomputar`, sin rutas del origen)
- [X] T016 [P] [US2] Portar `$CIAM/.claude/skills/confluence-ciam/templates.md` → `.claude/skills/confluence-docs/templates.md` (título neutro, sin filas de board; 4 plantillas íntegras)
- [X] T017 [P] [US2] Portar los 5 ejemplos de `$CIAM/.claude/skills/confluence-ciam/ejemplos/` → `.claude/skills/confluence-docs/ejemplos/` (anonimizar `conforme.md`, limpiar `estructurado.md`; `con-violaciones.md` y `prose-*.md` directos); **no** portar `template-history.md`
- [X] T018 [P] [US2] Reescribir `$CIAM/.claude/skills/jira-ciam-management/SKILL.md` → `.claude/skills/jira-management/SKILL.md` parametrizada según research.md (6 modos, gate por operación, secuencia leer→componer→escribir→releer con advertencia de labels, tabla permisos vs. proceso, sección Parámetros por proyecto con procedimientos de descubrimiento, tools del Contrato 1, puntero a `referencias/jql-trampas.md`)
- [X] T019 [P] [US2] Extraer §10 de `$CIAM/.claude/skills/jira-ciam-management/estandar-tablero.md` → `.claude/skills/jira-management/referencias/jql-trampas.md` (7 trampas genéricas, taxonomía error/vacío/plausible, disciplina de censo; sin claves ni cifras del origen)
- [X] T020 [P] [US2] Portar `tarea-conforme.md` y `tarea-con-desvios.md` de `$CIAM/.claude/skills/jira-ciam-management/ejemplos/` → `.claude/skills/jira-management/ejemplos/` (labels y claves neutras); **no** portar `consulta-por-estado.md`
- [X] T021 [US2] Verificar US2: greps de SC-005 y barrido corporativo cero sobre ambas skills, frontmatter válido; commit `feat: portar skills confluence-docs y jira-management parametrizadas`

**Checkpoint**: US2 probada en modo consulta requiere OAuth del dueño (SC-006, quickstart §6) — fuera de sesión.

> **Desviación registrada (06-09-2026)**: los archivos internos de las skills se portaron con nombre en inglés — `rules.md`, `templates.md`, `examples/` (con `compliant-adr.md`, `seeded-violations.md`, `structured-doc.md`, `prose-*.md`, `task-compliant.md`, `task-with-deviations.md`) y `references/jql-traps.md` — en vez de los nombres en español que estas tareas anticipaban (`reglas.md`, `ejemplos/`, `referencias/jql-trampas.md`). Motivo: la regla `06-nomenclatura-agentica.md` portada en US1 exige inglés en archivos internos de skills, y el workspace origen tenía esos mismos nombres anotados como deuda; portarlos en español habría importado la deuda a sabiendas.

## Phase 5: User Story 3 — Documentación visual portable (P2)

**Goal**: `visual-docs` completa y su suite de tests en verde.

**Independent Test**: `node .claude/skills/visual-docs/tests/run-tests.mjs` pasa completo.

- [X] T022 [US3] Copiar el paquete completo `$CIAM/.claude/skills/visual-docs-ciam/` → `.claude/skills/visual-docs/` y actualizar rutas internas (`visual-docs-ciam` → `visual-docs`; referencia a `specs/024-visual-docs-ciam` en `tests/package-structure.test.mjs`)
- [X] T023 [US3] Ajustar `.claude/skills/visual-docs/SKILL.md`: frontmatter `name: visual-docs`, description sin remisiones a skills corporativas
- [X] T024 [US3] Ejecutar `node .claude/skills/visual-docs/tests/run-tests.mjs` y corregir hasta suite en verde; commit `feat: portar skill visual-docs con suite de tests`

## Phase 6: User Story 4 — Flujo de commit disciplinado y referencias extraídas (P3)

**Goal**: skill `speckit-git-commit` adaptada; referencias extraídas verificadas.

**Independent Test**: la skill referencia solo archivos de este repo; invocarla en la rama produce staging acotado.

- [X] T025 [US4] Portar `$CIAM/.claude/skills/speckit-git-commit/SKILL.md` → `.claude/skills/speckit-git-commit/SKILL.md` adaptada (rutas a `.claude/rules/05-ramas-y-flujo-sdd.md` local; sin referencias a artefactos del origen; conservar staging acotado, bloqueo en main, detención ante secretos, sin push)
- [X] T026 [US4] Verificar que `jql-trampas.md` y los fixtures de prosa no contienen datos del tenant (scenarios 2 y 3 de US4); commit `feat: portar speckit-git-commit adaptada`

## Phase 7: Polish & Cross-Cutting

- [X] T027 Actualizar `README.md`: inventario real de reglas y skills, sección de conexión Atlassian (OAuth vía `/mcp`), patrón de ejemplo MCP movido desde `.mcp.json`; verificar que los punteros entre reglas y skills resuelven (regla 02 → templates.md)
- [X] T028 Ejecutar quickstart completo (`specs/001-portar-skills-rules/quickstart.md` §1-§5 y §7); corregir cualquier desviación
- [X] T029 Commit final `docs: actualizar README e integrar configuración Atlassian` y reporte de cierre (SC-006 queda pendiente de OAuth del dueño)

## Dependencies

- Phase 1 → Phase 2 → (US1 ∥ US3) — US1 y US3 no comparten archivos
- US2 depende de US1 solo por punteros (regla 02 ↔ templates.md); puede ejecutarse en paralelo si T005 y T016 se coordinan
- US4 depende de US1 (T008: regla 05 debe existir para reapuntar la skill de commit) y de US2 (T026 verifica archivos creados en T017/T019)
- Polish depende de todas las historias

## Parallel Execution Examples

- US1: T003-T012 son paralelizables (archivos distintos); T013 cierra la fase
- US2: T014-T020 son paralelizables (archivos distintos); T021 cierra la fase
- US1 y US3 pueden correr en paralelo completo

## Implementation Strategy

MVP = US1 (las reglas son la base del estándar y valor autónomo). Entrega incremental por historia con commit al cierre de cada fase, todos en la rama `001-portar-skills-rules`. Sin push ni merge sin confirmación del dueño (SC-007).
