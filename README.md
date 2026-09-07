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
| `.claude/skills/` | Sí | Estándar transversal: `confluence-docs`, `jira-management`, `visual-docs`; utilitarias `/ticket`, `/resumen`, `/documentar`, `/bitacora`, `/decision`; motor SDD `speckit-*` más `speckit-git-commit`; y `ejemplo-skill` |
| `.claude/agents/` | Sí | Subagentes `revisor-codigo`, `documentador`, `arquitecto`, `revisor-proyecto` |
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
3. Edita o elimina los ejemplos: `skills/ejemplo-skill`, `agents/revisor-proyecto`, `output-styles/redaccion-producto`, `commands/README.md`, `workflows/README.md`.
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

Verifica dentro de una sesión de Claude Code:

- `/memory` → confirma que `.claude/CLAUDE.md` y las `rules/` se cargan.
- Escribe `/` → deberían aparecer `ticket`, `resumen`, `documentar`, `bitacora`, `decision`, `confluence-docs`, `jira-management`, `visual-docs` y las `speckit-*` (son skills).
- `/agents` → `revisor-codigo`, `documentador`, `arquitecto`, `revisor-proyecto`.
- `/config` → **Output style** → `Socio estratégico` y `Redacción de producto` seleccionables.

> Reinicia Claude Code tras copiar la carpeta para que detecte los directorios nuevos.

---

## Skills incluidas (comandos `/`)

La invocación `/<nombre>` proviene del nombre del directorio (`skills/ticket/` → `/ticket`).

### Estándar transversal

| Skill | Para qué |
| --- | --- |
| `/confluence-docs [modo + insumo]` | Estándar de documentación en cuatro modos: genera, audita, consulta y publica en Confluence con gate de aprobación. Trae catálogo de reglas (`rules.md`) y plantillas de entregable (`templates.md`) |
| `/jira-management [modo + insumo]` | Gestión del tablero Jira en seis modos: redactar, crear, mover, editar, auditar y consultar, con gate por operación de escritura y trampas de JQL documentadas (`references/jql-traps.md`) |
| `/visual-docs [tema + destino]` | Sitios HTML de revisión técnica navegables por `file://`, con sistema de diagramas y wireframes; incluye scripts y suite de tests propia |
| `/speckit-git-commit` | Commit disciplinado de la feature SDD activa: staging acotado, bloqueo en `main`, detención ante secretos, sin push |

Las skills de Atlassian usan el servidor `atlassian` de `.mcp.json` y declaran sus parámetros por proyecto como `Pendiente de configurar`.

### Utilitarias

| Skill | Para qué |
| --- | --- |
| `/ticket [descripción]` | Genera un ticket de Jira completo (título, contexto, criterios de aceptación, notas técnicas) |
| `/resumen [texto o tema]` | Resumen ejecutivo orientado a decisión |
| `/documentar [archivo/módulo/tema]` | Documentación técnica basada en el código real |
| `/bitacora [qué se hizo]` | Entrada de bitácora trazable (inyecta fecha y `git status`) |
| `/decision [decisión + contexto]` | Registro de decisión arquitectónica (ADR) |

### Flujo SDD (spec-kit)

El repo integra spec-kit v0.13.0 con sus skills `speckit-*`: `constitution`, `specify`, `clarify`, `plan`, `tasks`, `analyze`, `checklist`, `implement`, `converge`, `taskstoissues`. Cada feature nace con `/speckit-specify`, vive en su rama `<NNN-slug>` y queda trazada en `specs/<NNN-slug>/` (regla `05-ramas-y-flujo-sdd.md`).

## Subagentes incluidos

| Subagente | Para qué |
| --- | --- |
| `revisor-codigo` | Revisión de calidad y seguridad (solo lectura) |
| `documentador` | Genera o mejora documentación a partir del código |
| `arquitecto` | Análisis de diseño, trade-offs y ADR (solo lectura) |
| `revisor-proyecto` | Revisor de ejemplo de proyecto (solo lectura); ajústalo o elimínalo |

Invócalos por lenguaje natural ("usa el subagente revisor-codigo en los cambios recientes") o con `@`.

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
