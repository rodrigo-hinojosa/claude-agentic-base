# Contratos de interfaz

Las interfaces que esta plantilla expone son las skills invocables, el set de reglas y la conexión MCP. Estos contratos son la referencia de verificación para tasks e implement.

## Contrato 1: Frontmatter de skill portada

Toda skill portada cumple:

```yaml
---
name: <nombre-directorio>          # obligatorio, inglés, kebab-case, == nombre del directorio
description: <cuándo usarla>       # obligatorio, sin remisiones a skills ausentes de este repo
argument-hint: <opcional>
allowed-tools: <lista>             # solo si la skill usa tools restringidas
---
```

Instancias y sus `allowed-tools` de Atlassian (prefijo `mcp__atlassian__`):

| Skill | Tools Atlassian |
|-------|-----------------|
| `confluence-docs` | `getAccessibleAtlassianResources`, `getConfluencePage`, `getConfluencePageDescendants`, `getConfluenceSpaces`, `searchConfluenceUsingCql`, `createConfluencePage`, `updateConfluencePage` |
| `jira-management` | `getAccessibleAtlassianResources`, `getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`, `getJiraIssue`, `searchJiraIssuesUsingJql`, `getJiraIssueTypeMetaWithFields`, `getTransitionsForJiraIssue`, `createJiraIssue`, `transitionJiraIssue`, `editJiraIssue` |
| `visual-docs` | (sin tools Atlassian) |
| `speckit-git-commit` | tools de git vía Bash |

**Invariante**: ninguna skill declara tools con prefijo `mcp__atlassian-cencosud__` ni `mcp__claude_ai_Atlassian__`.

## Contrato 2: Set de reglas

```text
.claude/rules/
  00-lenguaje-y-formato.md
  01-prevencion-alucinaciones.md
  02-documentacion-y-entregables.md
  03-seguridad-y-secretos.md
  04-flujo-y-metodo.md
  05-ramas-y-flujo-sdd.md
  06-nomenclatura-agentica.md
  07-continuidad-y-contexto.md
  08-interaccion-y-decisiones.md
  09-punteros-y-replicas.md
```

**Invariantes**: exactamente estos 10 archivos; numeración consecutiva; nombres en español; cero referencias corporativas; los punteros internos (regla 02 → templates de `confluence-docs`) resuelven a archivos existentes.

## Contrato 3: Conexión MCP Atlassian

Entrada exacta en `.mcp.json`:

```json
{
  "mcpServers": {
    "atlassian": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp/authv2"
    }
  }
}
```

**Invariantes**: sin credenciales, headers ni identificadores de tenant; la autorización es OAuth por sesión (`/mcp` en Claude Code); el cloudId se obtiene en runtime con `getAccessibleAtlassianResources` y no se persiste.

## Contrato 4: Parámetros por proyecto (sección obligatoria en skills de Atlassian)

Formato de la sección en `SKILL.md` de `confluence-docs` y `jira-management`:

```markdown
## Parámetros por proyecto

| Parámetro | Valor | Cómo resolverlo |
|-----------|-------|-----------------|
| <nombre>  | Pendiente de configurar | <tool y procedimiento de descubrimiento en vivo> |
```

**Invariantes**: todo valor es `Pendiente de configurar` en la plantilla; cada fila trae procedimiento ejecutable; cero valores del tenant origen.
