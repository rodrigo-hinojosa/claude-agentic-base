# Workflows de proyecto (`.claude/workflows/`)

Esta carpeta aloja **dynamic workflows** compartidos con el equipo: scripts `.js` que orquestan subagentes a escala. Se **versionan** y quedan disponibles para quien clone el repo.

Como los workflows los escribe Claude (su estructura interna no se autora a mano), esta carpeta no incluye `.js` de ejemplo. Para crear uno:

1. Pide un workflow en tu prompt (incluye `ultracode` o "usa un workflow").
2. Ejecuta `/workflows`, selecciona la ejecución, presiona `s` y, con `Tab`, elige guardar en `.claude/workflows/` (proyecto).
3. Se invoca como `/<nombre>`.

Precedencia: un workflow de proyecto gana sobre uno personal del mismo nombre; entre varios `.claude/workflows/` del repo, gana el más cercano al directorio de trabajo.

Borra esta carpeta si tu proyecto no usa workflows compartidos.
