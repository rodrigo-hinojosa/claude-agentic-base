---
name: speckit-git-commit
description: Commitear los cambios de la feature SDD activa, con staging acotado a la feature y mensaje derivado de sus artefactos. No hace push ni abre PR.
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: claude-agentic-base
  source: workspace de origen, skill speckit-git-commit (adaptada 2026-09-06; procedencia completa en specs/001-portar-skills-rules/research.md)
---

# Commit de la feature activa

Crea un commit acotado a la feature SDD en curso. No hace `push` ni abre PR: eso requiere confirmación explícita del usuario en cada caso.

## 1. Resolver la feature activa

Ejecuta `.specify/scripts/bash/check-prerequisites.sh --json --paths-only` y toma `FEATURE_DIR` y `BRANCH`.

Si la rama es `main`, **detente**: las features SDD no se commitean en la línea base (ver `.claude/rules/05-ramas-y-flujo-sdd.md`). Informa y ofrece crear la rama `<NNN-slug>`.

## 2. Determinar qué entra

Stagea **solo** lo que pertenece a la feature:

- `specs/<NNN-slug>/` completo, salvo lo que el `.gitignore` excluya.
- Los archivos que la feature declara tocar. Léelos de la sección "Project Structure" o equivalente de su `plan.md`; si el plan no los enumera, dedúcelos de `tasks.md`.
- `.specify/feature.json` y `CLAUDE.md` cuando la feature los haya actualizado como punteros.

**Nunca** uses `git add -A` ni `git add .`.

## 3. Verificar antes de commitear

Muestra en la respuesta, y revisa:

- Qué queda **staged**, con su estado (`A`, `M`, `D`).
- Qué queda **fuera**, y por qué. Todo archivo sin trackear que no pertenezca a la feature debe quedar fuera y ser reportado, no incluido en silencio.

Detente y consulta al usuario si detectas:

- Archivos que coincidan con patrones de secretos (`.env*`, `*.pem`, `*.key`, `credentials`, `id_rsa`). **Nunca** los stagees, ni siquiera si el `.gitignore` los exceptúa: no puedes leer su contenido para verificar que son seguros.
- Archivos de otra feature (`specs/<otro-NNN>/`).
- Volcados o material de trabajo voluminoso que debería estar ignorado.

## 4. Redactar el mensaje

Formato del proyecto: `tipo: descripción` en español, imperativo, sin emojis ni atribución automática (ver `.claude/rules/00-lenguaje-y-formato.md` y las Convenciones de `.claude/CLAUDE.md`).

- **Asunto**: qué cambia, no qué feature es. `feat: eliminar las skills duplicadas` dice más que `feat: implementar feature 003`.
- **Cuerpo**: el porqué, la evidencia de validación con cifras concretas, y los riesgos o deuda asumidos. Extrae la evidencia del `quickstart.md` de la feature o del registro de tareas si existe; **no inventes cifras** que no estén en los artefactos.
- Menciona explícitamente lo que quedó fuera del commit cuando sea relevante para quien lo revise.

## 5. Commitear y reportar

Crea el commit y reporta hash, firma, y el recuento de archivos por tipo de cambio.

**No** propongas `git push` ni la apertura del PR como paso automático. Si el usuario los pide, son acciones separadas que requieren su confirmación explícita en ese momento.
