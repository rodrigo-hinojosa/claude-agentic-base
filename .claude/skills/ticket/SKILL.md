---
description: Genera un ticket de Jira bien estructurado (título, contexto, descripción, criterios de aceptación, notas técnicas) a partir de una descripción libre. Úsalo cuando pida crear un ticket, una historia o una tarea.
argument-hint: [descripción del trabajo]
---

Genera un ticket de Jira a partir de esta descripción:

$ARGUMENTS

Devuelve el ticket en español, en formato Markdown listo para copiar, con esta estructura exacta:

## Título
Una línea, en imperativo, clara y accionable.

## Tipo
Story, Task, Bug, Spike o Subtask (elige el más adecuado y justifícalo en una frase).

## Contexto
Por qué existe este ticket. El problema o necesidad de fondo.

## Descripción
Qué hay que hacer, con el detalle suficiente para que alguien lo tome sin más contexto.

## Criterios de aceptación
Lista verificable de condiciones de "hecho". Cada criterio debe poder marcarse como cumplido o no de forma objetiva.

## Notas técnicas
Dependencias, riesgos, supuestos, enlaces o consideraciones de implementación. Omite la sección si no aplica.

## Estimación sugerida
Una estimación relativa (S/M/L o puntos) con una frase de justificación.

Reglas:
- No inventes requisitos que no se desprendan de la descripción. Si falta información crítica, lístala bajo "Preguntas abiertas" al final.
- Sin emojis. Tono profesional y conciso.
