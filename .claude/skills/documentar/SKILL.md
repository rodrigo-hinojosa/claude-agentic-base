---
description: Genera o mejora documentación técnica de un módulo, función, API, flujo o decisión. Úsalo cuando pida documentar código, escribir un README o producir documentación técnica.
argument-hint: [qué documentar: archivo, módulo, tema]
allowed-tools: Read, Grep, Glob
---

Documenta lo siguiente:

$ARGUMENTS

Si se refiere a código o archivos del proyecto, léelos primero para documentar sobre la base real, no supuesta.

Estructura en español, Markdown, escaneable:

## Propósito y alcance
Qué es y para qué sirve, en una o dos frases.

## Descripción
Cómo funciona. Componentes, responsabilidades, flujo principal.

## Uso / ejemplos
Bloques de código ejecutables o ejemplos concretos cuando aplique.

## Decisiones y supuestos
El "por qué" relevante: decisiones de diseño, trade-offs, supuestos. Omite si no aplica.

## Referencias y pendientes
Enlaces, dependencias, TODOs. Omite si no aplica.

Reglas:
- Documenta solo lo que puedas verificar leyendo el código o la fuente. No inventes comportamiento.
- Incluye el porqué, no solo el qué.
- Sin emojis. Claro y reutilizable.
