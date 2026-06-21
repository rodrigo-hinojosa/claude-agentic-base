---
description: Crea una entrada de bitácora trazable a partir de lo trabajado. Úsalo para registrar avances, aprendizajes y pendientes de una sesión o jornada.
argument-hint: [qué se hizo / contexto]
allowed-tools: Bash(date *), Bash(git status *)
---

Contexto de hoy: !`date +%Y-%m-%d`

Crea una entrada de bitácora a partir de esto:

$ARGUMENTS

Si la descripción es breve y hay cambios recientes en el repositorio, considéralos como insumo (resumen de cambios sin commitear):

!`git status --short 2>/dev/null`

Formato en español, Markdown, listo para pegar en una bitácora:

## [fecha] — [título breve]

**Contexto:** qué se estaba haciendo y por qué.

**Hecho:** acciones concretas realizadas, en viñetas.

**Aprendizajes:** hallazgos, decisiones, cosas que funcionaron o no. Omite si no aplica.

**Pendientes:** qué queda por hacer, en viñetas accionables.

Reglas:
- Conciso y trazable: que sea útil al consultarlo después.
- No inventes acciones que no se desprendan de la descripción o del estado del repo.
- Sin emojis.
