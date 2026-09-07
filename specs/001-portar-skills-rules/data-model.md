# Data Model: Portar estándar agnóstico desde workspace CIAM

El "modelo de datos" de esta plantilla son artefactos de configuración versionados, no registros de una base. Se describen sus campos y reglas de validación porque las tareas y la verificación operan sobre ellos.

## Regla

Documento normativo en `.claude/rules/`.

| Campo | Definición | Validación |
|-------|------------|------------|
| Número de orden | Prefijo `NN-` del nombre de archivo | Consecutivo 00-09, sin huecos ni duplicados |
| Nombre | Slug en español tras el prefijo | Kebab-case, descriptivo |
| Contenido | Markdown normativo | Cero referencias corporativas; autocontenido o con punteros válidos a archivos existentes del repo |

**Relaciones**: la regla 02 remite por puntero a `confluence-docs/templates.md`; la regla 05 es citada por `speckit-git-commit`; la regla 09 (punteros) gobierna cómo se citan todas las demás.

## Skill

Paquete invocable en `.claude/skills/<nombre>/`.

| Campo | Definición | Validación |
|-------|------------|------------|
| `name` (frontmatter) | Identificador de la skill | Presente, igual al nombre del directorio, inglés, sin sufijo corporativo |
| `description` (frontmatter) | Cuándo debe usarse | Presente; sin remisiones a skills inexistentes en este repo |
| `allowed-tools` (frontmatter) | Tools que la skill puede usar | Solo prefijo `mcp__atlassian__` para Atlassian; sin prefijos corporativos |
| Archivos de apoyo | references, ejemplos, scripts, tests | Rutas internas apuntan al nombre nuevo; tests pasan |

**Estado**: una skill portada está `completa` cuando frontmatter, contenido y archivos de apoyo cumplen validación y el barrido corporativo da cero.

## Parámetro por proyecto

Valor que varía entre proyectos que clonen la plantilla.

| Campo | Definición | Validación |
|-------|------------|------------|
| Nombre | Qué representa (espacio Confluence, proyecto Jira, board, tipo de issue, transiciones, labels, campos) | Declarado en la sección de parámetros de la skill |
| Valor en plantilla | Literal `Pendiente de configurar` | Nunca un valor heredado del origen ni inventado |
| Procedimiento de resolución | Cómo obtener el valor en vivo (tool de descubrimiento) | Presente y ejecutable con el servidor `atlassian` autorizado |

**Transición de estado**: `Pendiente de configurar` → `configurado` ocurre en cada proyecto derivado, nunca en la plantilla.

## Conexión MCP

Entrada en `.mcp.json`.

| Campo | Definición | Validación |
|-------|------------|------------|
| Alias | `atlassian` | Sin marca corporativa |
| Tipo/URL | HTTP → endpoint oficial de Atlassian | Sin credenciales, tokens ni headers sensibles |
| Autenticación | OAuth por sesión (fuera del repo) | El repo no persiste ningún identificador de tenant |

## Referencia extraída

Conocimiento genérico destilado del repo origen.

| Instancia | Ubicación | Validación |
|-----------|-----------|------------|
| Trampas JQL (TR-01..TR-07 + taxonomía + disciplina de censo) | `jira-management/referencias/jql-trampas.md` | Formulación válida para cualquier Jira Cloud; cero claves, cifras o ids del tablero origen |
| Fixtures de prosa | `confluence-docs/ejemplos/prose-*.md` | Tema neutro; sin personas ni datos corporativos |
