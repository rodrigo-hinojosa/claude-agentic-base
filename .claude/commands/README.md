# Comandos de proyecto (`.claude/commands/`)

Los comandos de un solo archivo (`commands/<nombre>.md`) crean `/<nombre>` igual que un skill y siguen **soportados**. Para flujos nuevos se recomienda usar **skills** (`.claude/skills/<nombre>/SKILL.md`), que además permiten agrupar archivos de apoyo y controlar la invocación.

- Mismo frontmatter que un skill (`description`, `argument-hint`, `allowed-tools`, etc.).
- Si un skill y un comando comparten nombre, **gana el skill**.

Esta carpeta queda como punto de extensión: crea aquí un `nombre.md` si prefieres el formato de archivo único, o usa `.claude/skills/` (recomendado). Borra esta carpeta si no la necesitas.
