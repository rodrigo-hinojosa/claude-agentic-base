---
description: Redacta un registro de decisión arquitectónica (ADR) a partir de una decisión técnica y su contexto. Úsalo cuando se tome una decisión relevante que convenga documentar.
argument-hint: [decisión y contexto]
---

Redacta un ADR (Architecture Decision Record) para esta decisión:

$ARGUMENTS

Formato en español, Markdown, listo para guardar como archivo en `docs/adr/`:

# ADR-NNN: [título de la decisión]

## Estado
Propuesta | Aceptada | Reemplazada | Obsoleta (elige; por defecto "Propuesta").

## Contexto
La situación y las fuerzas en juego: requisitos, restricciones, problema a resolver.

## Decisión
Qué se decidió, expresado de forma clara y afirmativa.

## Alternativas consideradas
Cada opción evaluada con sus pros y contras, y por qué se descartó.

## Consecuencias
Efectos positivos y negativos de la decisión. Deuda técnica o compromisos asumidos. Qué se vuelve más fácil y qué más difícil.

## Referencias
Enlaces, tickets, documentos relacionados. Omite si no aplica.

Reglas:
- Sé honesto con los trade-offs: una decisión sin contras está mal analizada.
- No inventes alternativas de relleno; incluye las realmente consideradas.
- Sin emojis. Preciso y trazable.
