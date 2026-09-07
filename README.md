# Base agéntica para Claude Code — Rodrigo Hinojosa

Configuración reutilizable de Claude Code empaquetada como **una sola carpeta `.claude/`**: reglas de trabajo, skills, subagentes, output styles y plantillas. Copia `.claude/` (más dos dotfiles de raíz) en cualquier proyecto nuevo y arrancas con tus estándares. Alineada con la estructura oficial del directorio `.claude` (https://code.claude.com/docs/es/claude-directory).

> La base es **config de proyecto** (se versiona y se comparte con el equipo). Tu identidad personal (rol, stack, preferencias que aplican a todos tus proyectos) vive en `~/.claude/CLAUDE.md`, no aquí. Ver "Identidad personal" más abajo.

---

## Qué incluye

### `.claude/` (la base)

| Ruta | ¿Git? | Qué hace |
| --- | --- | --- |
| `.claude/CLAUDE.md` | Sí | Plantilla de contexto y estándares del proyecto (reemplaza los `[marcadores]`) |
| `.claude/settings.json` | Sí | Permisos del proyecto (allow/ask/deny), compartidos con el equipo |
| `.claude/settings.local.json.example` | Sí | Ejemplo de overrides personales (copiar a `settings.local.json`) |
| `.claude/rules/` | Sí | Diez reglas 00-09: lenguaje y formato, anti-alucinación, documentación y entregables, seguridad, flujo y método, ramas y flujo SDD, nomenclatura agéntica, continuidad y contexto, interacción y decisiones, punteros y réplicas |
| `.claude/skills/` | Sí | Estándar transversal: `confluence-docs`, `jira-management`, `visual-docs`, `development-repositories`; motor SDD `speckit-*` más `speckit-git-commit` |
| `.claude/agents/` | Sí | Los tres agentes de rol del patrón plan→gate→ejecución: `product-owner`, `developer`, `atlassian-executor` |
| `.claude/contracts/` | Sí | Autoridad runtime del patrón de escritura gobernada: `write-plan.md` (plan sellado por hash) y `publish-authorization.md` (autorización de push por rama) |
| `.claude/output-styles/` | Sí | Estilos `socio-estrategico` y `redaccion-producto` |
| `.claude/commands/` | Sí | README: formato de comandos heredado (se recomienda skills) |
| `.claude/workflows/` | Sí | README: cómo se generan y guardan los dynamic workflows |
| `.specify/` | Sí | Andamiaje de spec-kit v0.13.0 (templates, scripts, memoria de constitución) |
| `specs/` | Sí | Trazas SDD por feature (`<NNN-slug>/`: spec, plan, tasks, evidencia) |

### Raíz del repo (acompañan a `.claude/`)

| Ruta | ¿Git? | Qué hace |
| --- | --- | --- |
| `.mcp.json` | Sí | Servidores MCP del proyecto: trae `atlassian` (MCP oficial, OAuth por sesión). **Debe** ir en la raíz, no dentro de `.claude/` |
| `.worktreeinclude` | Sí | Archivos gitignored a copiar en cada worktree (**debe** ir en la raíz) |
| `.gitignore` | Sí | Exclusiones de Claude Code (`settings.local.json`, `agent-memory-local/`, `worktrees/`, etc.) |

---

## Instalación en un proyecto nuevo

En la raíz de un repo nuevo:

```bash
# Ajusta la ruta a donde dejaste esta base
BASE=~/ruta/a/claude-base-agentica

cp -R $BASE/.claude ./.claude
cp $BASE/.mcp.json $BASE/.worktreeinclude ./
# Combina las reglas de $BASE/.gitignore con tu .gitignore del repo.
# Opcional: crea tus overrides locales:
cp ./.claude/settings.local.json.example ./.claude/settings.local.json
```

Luego:

1. Edita `.claude/CLAUDE.md` y reemplaza los `[marcadores]`. O ejecuta `/init` para que Claude proponga un borrador a partir del código y refínalo.
2. Ajusta los permisos de `.claude/settings.json`: `allow`/`ask` traen ejemplos seguros de git (solo lectura) a ampliar según tu stack — usa formas exactas y evita comodines que permitan encadenar comandos; el bloque `deny` (lectura de secretos) es universal y conviene mantenerlo.
3. Edita o elimina los ejemplos: `output-styles/redaccion-producto`, `commands/README.md`, `workflows/README.md`.
4. Revisa `.mcp.json`: trae el servidor `atlassian` (MCP oficial de Atlassian, OAuth). Autorízalo con `/mcp` dentro de una sesión de Claude Code; el sitio y el `cloudId` se resuelven en runtime y nunca se escriben en el repo. Agrega otros servidores según tu stack, por ejemplo:

   ```json
   "mi-servidor-stdio": {
     "type": "stdio",
     "command": "npx",
     "args": ["-y", "@paquete/mcp-server@1.0.0"],
     "env": { "API_KEY": "${MI_API_KEY}" }
   }
   ```

5. Configura los parámetros por proyecto de las skills de Atlassian (sección "Parámetros por proyecto" en `confluence-docs/SKILL.md` y `jira-management/SKILL.md`): espacio de Confluence, proyecto y tablero de Jira, tipo de issue gestionado, labels. En la plantilla vienen como `Pendiente de configurar`.
6. Si vas a usar el patrón plan→gate→ejecución, completa la misma sección "Parámetros por proyecto" en `agents/product-owner.md` y `agents/developer.md` (tablero de gestión, tablero secundario opcional, espacio Confluence, página de roster), y las filas de tablero del catálogo de `.claude/contracts/write-plan.md`.
7. Si vas a usar `developer`, puebla el catálogo `skills/development-repositories/repositories.md` siguiendo su §9 (viene vacío, con procedimiento).

Verifica dentro de una sesión de Claude Code:

- `/memory` → confirma que `.claude/CLAUDE.md` y las `rules/` se cargan.
- Escribe `/` → deberían aparecer `confluence-docs`, `jira-management`, `visual-docs`, `development-repositories` y las `speckit-*` (son skills).
- `/agents` → `product-owner`, `developer`, `atlassian-executor`.
- `/config` → **Output style** → `Socio estratégico` y `Redacción de producto` seleccionables.

> Reinicia Claude Code tras copiar la carpeta para que detecte los directorios nuevos.

---

## Skills incluidas (comandos `/`)

La invocación `/<nombre>` proviene del nombre del directorio (`skills/visual-docs/` → `/visual-docs`).

### Estándar transversal

| Skill | Para qué |
| --- | --- |
| `/confluence-docs [modo + insumo]` | Estándar de documentación en cuatro modos: genera, audita, consulta y publica en Confluence con gate de aprobación. Trae catálogo de reglas (`rules.md`) y plantillas de entregable (`templates.md`) |
| `/jira-management [modo + insumo]` | Gestión del tablero Jira en seis modos: redactar, crear, mover, editar, auditar y consultar, con gate por operación de escritura y trampas de JQL documentadas (`references/jql-traps.md`) |
| `/visual-docs [tema + destino]` | Sitios HTML de revisión técnica navegables por `file://`, con sistema de diagramas y wireframes; incluye scripts y suite de tests propia |
| `/development-repositories [modo + insumo]` | Catálogo de repositorios de desarrollo y QA del proyecto, en cuatro modos: consultar (repositorios y specs abiertas), preparar/actualizar el workspace multi-repo local (8 scripts bash), especificar (abre la spec de un desarrollo) y sincronizar (divergencias contra la fuente, sin aplicarlas) |
| `/speckit-git-commit` | Commit disciplinado de la feature SDD activa: staging acotado, bloqueo en `main`, detención ante secretos, sin push |

Las skills de Atlassian usan el servidor `atlassian` de `.mcp.json` y declaran sus parámetros por proyecto como `Pendiente de configurar`.

Las skills utilitarias (`/ticket`, `/resumen`, `/documentar`, `/bitacora`, `/decision`) no viven en esta base: si existen en la configuración personal de quien trabaja, las reglas las citan solo como **atajo opcional** — su ausencia no exime de cumplir el formato de `confluence-docs/templates.md` y su presencia no lo reemplaza (regla `06-nomenclatura-agentica.md`, Excepciones).

### Flujo SDD (spec-kit)

El repo integra spec-kit v0.13.0 con sus skills `speckit-*`: `constitution`, `specify`, `clarify`, `plan`, `tasks`, `analyze`, `checklist`, `implement`, `converge`, `taskstoissues`. Cada feature nace con `/speckit-specify`, vive en su rama `<NNN-slug>` y queda trazada en `specs/<NNN-slug>/` (regla `05-ramas-y-flujo-sdd.md`).

## Subagentes incluidos

Esta plantilla versiona **tres agentes de rol**, el patrón de gobernanza plan→gate→ejecución para escritura delegada a Jira y Confluence:

| Agente | Rol | Para qué |
| --- | --- | --- |
| `product-owner` | Productor de planes | Revisa el tablero de gestión y la documentación de Confluence con criterio de producto; nunca escribe directo — produce un plan de escritura |
| `developer` | Productor de planes | Abre desarrollos de punta a punta (rama, spec, commit acotado, índice); gestiona su ciclo de vida; publica solo con autorización de publicación válida |
| `atlassian-executor` | Ejecutor | Ejecuta un plan ya sellado por hash contra el catálogo cerrado de `.claude/contracts/write-plan.md`; nunca decide contenido |

`product-owner` y `developer` no ocupan un rol de un roster propio: al adoptar la plantilla en un proyecto concreto se renombran a `<rol>-<proyecto>` y se reconcilian con el roster real (regla `06-nomenclatura-agentica.md`). Cada uno trae su sección "Parámetros por proyecto" con los valores `Pendiente de configurar`.

**Esta plantilla no versiona subagentes genéricos de exploración o revisión** (tipo `revisor-codigo`, `documentador`, `arquitecto`). Si tu configuración personal de Claude Code los provee (`~/.claude-personal/agents/` o equivalente), siguen disponibles en cualquier proyecto sin que este repositorio los duplique; la regla `04-flujo-y-metodo.md` los cita por esa procedencia, declarando que no son artefactos garantizados de la plantilla.

Invócalos por lenguaje natural ("usa el agente developer para abrir el desarrollo de ABC-123") o con `@`.

---

## Notas de diseño

- **Idioma:** fija `"language": "spanish"` en `~/.claude/settings.json` (tu config personal) para responder en español por defecto.
- **Sin emojis:** reforzado en las reglas y los output styles; los commits salen sin emojis ni atribución automática (`attribution` vacío en tu `settings.json` personal).
- **Anti-alucinación:** `rules/01-prevencion-alucinaciones.md` exige distinguir hecho de inferencia y citar fuentes.
- **Permisos en tres niveles:** lectura e inspección en `allow`; acciones con efecto (commit, push, install, rm) en `ask`; lectura de secretos y comandos peligrosos en `deny`. `deny` siempre gana.
- **Reglas duras vs. guía:** lo que debe bloquearse de verdad va en `settings.json` (`permissions.deny`) o en hooks; `CLAUDE.md` y las reglas son contexto que orienta, no una capa de cumplimiento forzado.
- **El output style es opcional:** actívalo con `/config` → **Output style** (la selección se guarda en `.claude/settings.local.json`), o con la clave `outputStyle` en `settings.json`. El comando suelto `/output-style` quedó obsoleto en v2.1.73 y se eliminó en v2.1.91.

## Memoria y archivos autogenerados

- **CLAUDE.md se concatena, no se anula.** El `~/.claude/CLAUDE.md` (personal) y el `.claude/CLAUDE.md` (proyecto) se cargan juntos; el de proyecto aparece después. En conflicto directo **no hay un ganador determinista**: evita reglas contradictorias entre ambos.
- **Auto memory (la escribe Claude).** Notas por proyecto en `~/.claude/projects/<proyecto>/memory/MEMORY.md` (primeras 200 líneas / 25KB). Local de la máquina, **no se versiona**, activa por defecto; se desactiva con `autoMemoryEnabled: false` o `/memory`.
- **Memoria de subagente (opt-in).** Un subagente solo persiste conocimiento si añades `memory: project | user | local` a su frontmatter (genera `agent-memory/`). La base la deja documentada pero **desactivada**.
- **No fabricar autogenerados.** `projects/`, `agent-memory/`, `~/.claude.json`, `themes/`, `keybindings.json` los crea Claude Code; no son archivos autorables de esta base.

## Identidad personal (no en la base)

Tu identidad personal de Claude Code (quién eres, tu stack, preferencias que aplican a **todos** tus proyectos) va en `~/.claude/CLAUDE.md`, no en una base de proyecto que se commitea por repo. No la incluyas en repos de equipo.

---

## Referencias oficiales

- Directorio `.claude`: https://code.claude.com/docs/es/claude-directory
- Memoria y reglas (`CLAUDE.md`, `rules/`): https://code.claude.com/docs/es/memory
- Skills y comandos: https://code.claude.com/docs/es/skills
- Subagentes: https://code.claude.com/docs/es/sub-agents
- Settings y permisos: https://code.claude.com/docs/es/settings
