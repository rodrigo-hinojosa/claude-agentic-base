# Research: Portar estándar agnóstico desde workspace CIAM

**Fecha**: 2026-09-06
**Fuentes**: barrido de clasificación exhaustivo del repo origen (agente de exploración, sesión del 06-09-2026, lectura completa de rules, skills y `.specify/`), inspección directa de `.mcp.json` de ambos repos, `specify init --help` v0.13.0, ronda de decisiones interactiva con el dueño del repo.

Ninguna incógnita quedó abierta: no hay marcadores NEEDS CLARIFICATION en la spec.

## Decisiones

### D1. Spec-kit: init oficial v0.13.0 + skill custom de commit

- **Decision**: usar `specify init --here --integration claude --script sh` con el CLI oficial v0.13.0 (ya ejecutado en esta rama) y portar aparte la skill custom `speckit-git-commit` del repo origen.
- **Rationale**: el setup del repo origen quedó anclado a spec-kit 0.8.19.dev0 (versión dev no reproducible con el CLI actual); v0.13.0 instala la integración Claude como skills por defecto y añade `speckit-converge`. La única pieza custom con valor es la skill de commit disciplinado.
- **Alternatives considered**: copiar `.specify/` + skills speckit del repo origen (descartado: versión dev antigua, manifests con hashes que no cuadrarían, extensiones no soportadas por el CLI actual).

### D2. Nombres de skills sin sufijo de proyecto

- **Decision**: `confluence-docs`, `jira-management`, `visual-docs`.
- **Rationale**: el sufijo de proyecto (regla de nomenclatura CIAM) marca skills de UN proyecto; estas tres son el estándar transversal de la plantilla. Verificado en sesión: ningún nombre colisiona con skills globales del usuario (`documentar`, `resumen`, `ticket`, `bitacora`, `decision`) ni con skills de plugins instalados.
- **Alternatives considered**: sufijo `-base` (descartado: nombres más largos sin ganancia); mantener `-ciam` (descartado: arrastra identificador corporativo).

### D3. Reglas 00-04: reemplazo por versiones CIAM depuradas

- **Decision**: las reglas 00-04 actuales del repo base se reemplazan por las versiones del repo origen, depuradas de referencias corporativas.
- **Rationale**: son evoluciones directas de los mismos archivos (política de fechas en 00, delegación de plantillas en 02, cierre con cuatro declaraciones en 04); mantener dos generaciones crearía divergencia silenciosa.
- **Alternatives considered**: solo agregar reglas nuevas (descartado: convivencia de generaciones); fusión manual regla a regla (descartado: costo sin beneficio, las versiones CIAM son superset).

### D4. Atlassian: MCP oficial en `.mcp.json`, alias `atlassian`, cloudId en runtime

- **Decision**: entrada `atlassian` → `https://mcp.atlassian.com/v1/mcp/authv2` (HTTP, OAuth por sesión). Las skills referencian tools `mcp__atlassian__*` y resuelven cloudId/sitio en runtime vía `getAccessibleAtlassianResources`.
- **Rationale**: mismo mecanismo probado en el repo origen (el alias `atlassian-cencosud` apuntaba a este mismo endpoint oficial — solo el nombre era corporativo); funciona en cualquier sesión de Claude Code CLI con la cuenta que autorice el OAuth; nada sensible persiste en el repo.
- **Alternatives considered**: conector claude.ai Atlassian (descartado como primario: ata las skills a sesiones con conectores claude.ai); listar ambos prefijos en `allowed-tools` (descartado: permisos más anchos y ruido).

### D5. Entradas de ejemplo de `.mcp.json`: retirarlas

- **Decision**: eliminar `ejemplo-stdio` y `ejemplo-http` de `.mcp.json`; documentar el patrón de ejemplo en el README.
- **Rationale**: verificado en esta sesión que ambas fallan la conexión en cada arranque (`ENOTFOUND mcp.ejemplo.com`, `CONNECTION_CLOSED`), generando ruido de diagnóstico permanente. FR-005 permite conservarlas o retirarlas mientras no interfieran; interfieren.
- **Alternatives considered**: conservarlas comentadas (JSON no admite comentarios); conservarlas activas (descartado: error de conexión en cada sesión).

### D6. Regla de ejemplo del repo base: retirarla

- **Decision**: eliminar `.claude/rules/ejemplo-regla-por-ruta.md`.
- **Rationale**: era un placeholder didáctico de la plantilla vacía; con 10 reglas reales queda superado y rompería SC-002 (exactamente las reglas 00-09).

### D7. Ubicación de la referencia JQL extraída

- **Decision**: `.claude/skills/jira-management/referencias/jql-trampas.md`.
- **Rationale**: la referencia existe para que `jira-management` remita a ella (regla de punteros: un solo lugar); dentro de la skill viaja con ella al clonar la plantilla.
- **Alternatives considered**: `docs/` en la raíz (descartado: se separa de su único consumidor).

## Mapa de portación archivo por archivo

Origen: `/Users/rodrigo-hinojosa/Documents/Cencosud/Develop/CIAM/df-ciam-workspace` (solo lectura). Destino: raíz de este repo.

### Reglas (`.claude/rules/`)

| # | Origen | Destino | Transformación |
|---|--------|---------|----------------|
| 1 | `rules/00-lenguaje-y-formato.md` | `rules/00-lenguaje-y-formato.md` | Copia directa (verificar: cero referencias corporativas) |
| 2 | `rules/01-prevencion-alucinaciones.md` | `rules/01-prevencion-alucinaciones.md` | Copia directa |
| 3 | `rules/02-documentacion-y-entregables.md` | `rules/02-documentacion-y-entregables.md` | Quitar URL `cencosud.atlassian.net/...1570242594` (§ADR), quitar nota del board 14186, reapuntar el enlace de plantillas a `.claude/skills/confluence-docs/templates.md`, quitar anécdota fechada de plantillas ADR, remisión `jira-ciam-management` → `jira-management` |
| 4 | `rules/03-seguridad-y-secretos.md` | `rules/03-seguridad-y-secretos.md` | Copia directa |
| 5 | `rules/04-flujo-y-metodo.md` | `rules/04-flujo-y-metodo.md` | Sustituir ejemplo `product-owner-ciam` por subagente de este repo (`arquitecto`) |
| 6 | `rules/05-ramas-y-flujo-sdd.md` | `rules/05-ramas-y-flujo-sdd.md` | Parametrizar nomenclatura `[CIAM-XXX]`/`tipo/CIAM-XXX-*` al patrón `<CLAVE-XXX>` con nota de que aplica solo si el proyecto usa Jira; quitar "4.5 de Confluence"; quitar anécdotas fechadas del repo origen (push directos, prueba de protección); quitar ejemplo `specs/001-renumeracion-uroboros` |
| 7 | `rules/06-nomenclatura-agentica.md` | `rules/06-nomenclatura-agentica.md` | Sustituir `ciam` por parámetro `<proyecto>` en el patrón; reescribir tabla de ejemplos con nombres genéricos; eliminar URL del roster, inventario de deuda, rama congelada y features del repo origen; conservar: sufijo al final, inglés en `.claude/`, verificación anti-colisión |
| 8 | `rules/08-continuity-and-context.md` | `rules/07-continuidad-y-contexto.md` | Renumerar y renombrar a español; contenido tal cual |
| 9 | `rules/09-interaction-and-decisions.md` | `rules/08-interaccion-y-decisiones.md` | Renumerar y renombrar a español; contenido tal cual |
| 10 | `rules/10-pointers-and-replicas.md` | `rules/09-punteros-y-replicas.md` | Renumerar/renombrar; eliminar sección "La evidencia que la sostiene" y "Referencias" (evidencia local del repo origen); conservar principio, 5 reglas y procedimiento de verificación con su límite declarado |
| — | `rules/07-cencoflow.md` | — | **No se porta** (FR-002) |
| — | — | `rules/ejemplo-regla-por-ruta.md` | **Se elimina** (D6) |

### Skill `confluence-docs` (← `confluence-ciam`)

| Origen | Destino | Transformación |
|--------|---------|----------------|
| `SKILL.md` | `SKILL.md` | Agregar `name: confluence-docs` al frontmatter; eliminar cloudId hardcodeado → instrucción de resolver vía `getAccessibleAtlassianResources`; `allowed-tools` con prefijo `mcp__atlassian__` (mismas 6 tools + `getAccessibleAtlassianResources`); "espacio CIAM" → parámetro `Pendiente de configurar`; remisiones a `jira-ciam-management` → `jira-management`; eliminar referencias a `atlassian-executor-ciam`, contracts y regla de nomenclatura del origen; eliminar anécdota fechada del detector |
| `reglas.md` | `reglas.md` | Regla 14: `CIAM-XXX` → `<CLAVE-XXX>` condicionada a proyecto con Jira; regla 12: quitar excepción del tablero CIAM, remitir a `jira-management`; tabla de línea base de prosa → `Pendiente de recomputar` sobre el corpus del proyecto destino (conservar el método y el script); eliminar rutas `specs/002-*`, `specs/023-*` |
| `templates.md` | `templates.md` | Título sin "CIAM"; quitar filas de remisión al board 14186; conservar las 4 plantillas íntegras |
| `ejemplos/conforme.md` | `ejemplos/conforme.md` | Anonimizar dueño de la decisión (rol, no nombre de persona) |
| `ejemplos/con-violaciones.md` | `ejemplos/con-violaciones.md` | Copia directa (violaciones sembradas a propósito, sintéticas) |
| `ejemplos/estructurado.md` | `ejemplos/estructurado.md` | Limpiar rutas `specs/002-*` y autorreferencias al nombre origen |
| `ejemplos/prose-conforming.md`, `ejemplos/prose-with-seeded-flaws.md` | idem | Copia directa (tema neutro) |
| `template-history.md` | — | **No se porta** (memoria histórica del repo origen) |

### Skill `jira-management` (← `jira-ciam-management`)

| Origen | Destino | Transformación |
|--------|---------|----------------|
| `SKILL.md` | `SKILL.md` | Reescritura parametrizada conservando la arquitectura: 6 modos (redactar, crear, mover, editar, auditar, consultar), gate de aprobación por operación de escritura, secuencia leer → componer → escribir → releer con la advertencia de que la edición de labels **reemplaza** (fallo silencioso y destructivo), tabla "qué sostiene cada restricción" (permisos vs. proceso). Eliminar: cloudId, proyecto 18698, board 14186, tipo 10670, ids de transición 11-61, labels `ciam-management`/`uroboros`, claves `CIAM-*`, dependencia de `team-ciam`, URL DoD. Agregar: `name: jira-management`; sección "Parámetros por proyecto" con cada valor `Pendiente de configurar` y su procedimiento de resolución en vivo (`getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`, `getTransitionsForJiraIssue`); prefijo `mcp__atlassian__` (7 tools + `getAccessibleAtlassianResources`, `getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`); puntero a `referencias/jql-trampas.md` |
| `estandar-tablero.md` §10 (TR-01..TR-07) | `referencias/jql-trampas.md` | Extracción genérica: las 7 trampas reformuladas para cualquier Jira Cloud, taxonomía de manifestación (error / vacío / resultado plausible), disciplina de cuadrar partición contra censo. Sin claves, cifras ni ids del tablero origen |
| `estandar-tablero.md` (resto) | — | **No se porta** (censo del tenant corporativo) |
| `ejemplos/tarea-conforme.md` | `ejemplos/tarea-conforme.md` | Labels neutras, tema neutro |
| `ejemplos/tarea-con-desvios.md` | `ejemplos/tarea-con-desvios.md` | Conservar el patrón adversarial (6+ desvíos sembrados); referencias `CIAM-99` → clave genérica |
| `ejemplos/consulta-por-estado.md` | — | **No se porta** (transcripción real contra el tenant) |

### Skill `visual-docs` (← `visual-docs-ciam`)

| Origen | Destino | Transformación |
|--------|---------|----------------|
| Paquete completo (SKILL.md, `references/` ×5, `scripts/` ×2, `assets/starter/` ×6, `tests/` completo) | `visual-docs/` mismo árbol | Copia + búsqueda-reemplazo de rutas `.claude/skills/visual-docs-ciam` → `.claude/skills/visual-docs`; en `tests/package-structure.test.mjs` quitar/ajustar la referencia a `specs/024-visual-docs-ciam`; SKILL.md: agregar `name: visual-docs`, description sin remisiones a skills corporativas. Contenido verificado sin referencias corporativas (grep del barrido: cero) |

**Validación**: `node .claude/skills/visual-docs/tests/run-tests.mjs` debe pasar completo (SC-004).

### Skill `speckit-git-commit` (← custom del repo origen)

| Origen | Destino | Transformación |
|--------|---------|----------------|
| `skills/speckit-git-commit/SKILL.md` | idem | Reapuntar referencias internas: regla de ramas → `.claude/rules/05-ramas-y-flujo-sdd.md` de este repo; quitar referencias a `CLAUDE.md` y `quickstart-evidencia.md` del origen o reapuntarlas a equivalentes locales. Conservar: staging acotado a la feature activa, prohibición `git add -A`/`git add .`, bloqueo en `main`, detención ante patrones de secretos, mensajes `tipo: descripción` en español, sin push/PR |

### Configuración y documentación

| Archivo | Transformación |
|---------|----------------|
| `.mcp.json` | Reemplazar entradas de ejemplo por `"atlassian": { "type": "http", "url": "https://mcp.atlassian.com/v1/mcp/authv2" }` (D4, D5) |
| `README.md` | Actualizar inventario de reglas (00-09), skills (5 propias + speckit), sección de conexión Atlassian (autorización OAuth vía `/mcp`), patrón de ejemplo MCP movido aquí desde `.mcp.json` |

## Hallazgos que condicionan la implementación

1. **Frontmatter incompleto en origen**: `confluence-ciam/SKILL.md` y `jira-ciam-management/SKILL.md` no tienen campo `name:`; se corrige al portar (FR-003).
2. **cloudId repetido en 6 archivos del origen**: el barrido final (SC-001) debe incluir el fragmento `e98853f7` explícitamente.
3. **Línea base de prosa no transferible**: el propio archivo origen advierte que debe recomputarse por corpus; copiar los números sería una réplica caduca (regla de punteros).
4. **La palabra "CIAM" dentro de specs/**: `specs/001-portar-skills-rules/` documenta la procedencia y queda exenta del barrido (SC-001). Ningún otro archivo del repo puede contenerla.
5. **Idioma de archivos en `.claude/`**: la regla de nomenclatura del origen pide inglés para identificadores de skills; los nombres elegidos (D2) cumplen. Las reglas conservan nombres de archivo en español por consistencia con las 00-04 ya existentes en este repo — la regla portada debe reflejar ese matiz (nomenclatura de skills en inglés; reglas en español como convención local de la plantilla).
