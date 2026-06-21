---
description: Skill de proyecto de ejemplo. Reemplaza esta descripción por cuándo debe usarse; Claude la lee para decidir si autoinvocar el skill.
argument-hint: [argumento de ejemplo]
---

<!--
Plantilla de skill de proyecto. La invocación /<nombre> proviene del NOMBRE DEL DIRECTORIO
(este es skills/ejemplo-skill/ → /ejemplo-skill), no del frontmatter.
- `description`: cuándo conviene usar el skill (Claude lo usa para autoinvocar).
- `argument-hint`: se muestra en el autocompletado.
- Opcional `allowed-tools: Read, Grep, Glob`: pre-aprueba herramientas sin preguntar.
- Opcional `disable-model-invocation: true`: solo el usuario lo dispara (flujos con efecto).
- Puedes agrupar archivos de apoyo en esta carpeta y referenciarlos desde aquí.
Reemplaza el contenido y borra estos comentarios, o elimina la carpeta si no usas skills de proyecto.
-->

Realiza la tarea de ejemplo con la siguiente entrada:

$ARGUMENTS

Describe aquí, paso a paso, qué debe hacer Claude. Mantén el archivo conciso
(idealmente menos de 500 líneas), en español y sin emojis.
