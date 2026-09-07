# Contratos de interfaz — feature 002

Contratos de verificación para tasks e implement. Los contratos de diseño del developer (`developer-flow.md`, `operation-report.md`) se producen durante implement en este mismo directorio (FR-010); este archivo fija las interfaces estructurales.

## Contrato 1: Frontmatter de agente

```yaml
---
name: <nombre-archivo>       # obligatorio, == basename sin .md, inglés, sin sufijo
description: <cuándo invocarlo>
tools: <allowlist>           # refleja la garantía de Permisos del cuerpo
model: <opus|sonnet>         # heredado del origen por rol
---
```

| Agente | model | Tools Atlassian (prefijo `mcp__atlassian__`) | Tools locales |
|--------|-------|---------------------------------------------|---------------|
| `product-owner` | opus | getJiraIssue, searchJiraIssuesUsingJql, getTransitionsForJiraIssue, getJiraIssueTypeMetaWithFields, getConfluencePage, getPagesInConfluenceSpace, searchConfluenceUsingCql | Read, Grep, Glob, Skill, Write |
| `atlassian-executor` | sonnet | createJiraIssue, editJiraIssue, transitionJiraIssue, createConfluencePage, updateConfluencePage, getJiraIssue, getTransitionsForJiraIssue, getJiraIssueTypeMetaWithFields, getConfluencePage | Read, Bash, Skill |
| `developer` | opus | getJiraIssue, searchJiraIssuesUsingJql, getTransitionsForJiraIssue, getJiraIssueTypeMetaWithFields, getConfluencePage, searchConfluenceUsingCql | Read, Grep, Glob, Bash, Write, Edit, Skill |

**Invariantes**: ningún agente productor (product-owner, developer) declara tools de escritura Atlassian ni la herramienta de lanzar subagentes; `mcpServers: [atlassian]` en los tres; cero prefijos `mcp__atlassian-cencosud__` o `mcp__claude_ai_Atlassian__`.

## Contrato 2: Directorio `.claude/contracts/`

```text
.claude/contracts/
  write-plan.md              # US1
  publish-authorization.md   # US2
```

**Invariantes**: exactamente esos dos archivos; cada uno con procedencia re-anclada a esta portación; cero referencias corporativas; sus comandos de verificación (hash) son ejecutables tal cual en macOS (`sed`, `shasum`).

## Contrato 3: Skill `development-repositories`

```text
.claude/skills/development-repositories/
  SKILL.md                   # name: development-repositories
  layout.md  repositories.md  spec-index.md  provenance.md  divergences.md
  templates/development-spec.md
  scripts/ (8 × .sh)
  examples/ (4 × .md)
```

**Invariantes**: `repositories.md` sin filas reales (plantilla + procedimiento); `spec-index.md` vacío con celda recomputable; los 8 scripts pasan `bash -n` **y la corrida funcional contra el fixture sintético** (`examples/test-catalog.md`, receta §3) reproduce los estados que ese fixture declara esperados por verbo; barrido corporativo cero en todo el árbol. Los nombres de variables de entorno (`REPOS_ROOT`, `REPOS_CATALOG`) son contrato entre los scripts y la documentación de la skill: deben coincidir en `SKILL.md`, `layout.md` y los 8 scripts.

## Contrato 4: Estado final de `.claude/agents/`

Exactamente 3 archivos: `product-owner.md`, `atlassian-executor.md`, `developer.md`. Los cuatro genéricos retirados del repositorio.

**Sobre sus nombres tras el retiro** (clarificación 07-09-2026): `revisor-proyecto` no aparece en ningún archivo fuera de `specs/`. `arquitecto`, `documentador` y `revisor-codigo` **pueden** aparecer en la regla 04 y el README, siempre que la mención declare su procedencia — la configuración personal de quien opera (`~/.claude-personal/agents/`), no la plantilla. Una mención sin esa procedencia es no conforme: prometería un artefacto que el repositorio no versiona.

## Contrato 5: Verificaciones ejecutables de cierre

```bash
# Barrido corporativo (FR-014)
grep -riE 'cencosud|cencoflow|atlassian-cencosud|e98853f7|14186|14516|14530|10670|ciam' .claude/ README.md
# Prueba de ida y vuelta del hash (FR-004): sellar → OK → alterar → caducado, sobre plan sintético
# Verificación tipada de la autorización (US2 escenario 5): bloques sintéticos → ausente / malformada / no coincide
# Sintaxis de los 8 scripts (SC-004)
for s in .claude/skills/development-repositories/scripts/*.sh; do bash -n "$s"; done
# Corrida funcional contra el fixture (SC-004): armar la raíz según examples/test-catalog.md §3 y correr
#   run-across-repos.sh status|fetch|pull --catalog <catalogo-resuelto> --root <raiz>
# Punteros (SC-005): rutas citadas por los 3 agentes y ambos contracts, más los enlaces markdown relativos
# revisor-proyecto retirado sin rastro (SC-006)
grep -rn 'revisor-proyecto' .claude/ README.md
```

Resultado esperado: barridos en cero (exit 1), hash round-trip con los dos veredictos correctos, casos de autorización clasificados con su nombre tipado, `bash -n` silencioso, corrida funcional coincidente con el fixture (incluido el código de salida 2 ante un repositorio ausente), punteros todos resueltos. Para `arquitecto`, `documentador` y `revisor-codigo` la verificación no es un grep en cero sino una revisión de que cada ocurrencia declare su procedencia (Contrato 4).
