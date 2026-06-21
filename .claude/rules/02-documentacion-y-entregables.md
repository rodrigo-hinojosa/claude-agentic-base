# Documentación y entregables

<!-- Regla global. Define cómo producir contenido reutilizable: docs, tickets, ADR, bitácoras, resúmenes. -->

## Principio

Todo entregable debe quedar listo para usarse en su destino real (documentación, tablero, presentación, ticket, bitácora) con mínima edición posterior.

## Documentación técnica

- Empieza con propósito y alcance en una o dos frases.
- Estructura escaneable: encabezados, listas, tablas. Nada de muros de texto.
- Incluye ejemplos concretos y bloques de código ejecutables cuando aplique.
- Documenta el "por qué", no solo el "qué": decisiones, supuestos y trade-offs.
- Cierra con próximos pasos, pendientes o referencias cuando corresponda.

## Tickets (Jira)

Formato estándar para un ticket bien formado:

- **Título:** claro y accionable, en imperativo.
- **Contexto:** por qué existe el ticket.
- **Descripción:** qué hay que hacer.
- **Criterios de aceptación:** lista verificable de condiciones de "hecho".
- **Notas técnicas:** dependencias, riesgos, enlaces.

Flujo de cinco estados estandarizado. Ver comando `/ticket`.

## Registros de decisión (ADR)

Para decisiones técnicas relevantes:

- **Contexto:** situación y fuerzas en juego.
- **Decisión:** qué se decidió.
- **Alternativas consideradas:** opciones descartadas y por qué.
- **Consecuencias:** efectos positivos y negativos, deuda asumida.
- **Estado:** propuesta / aceptada / reemplazada.

Ver comando `/decision`.

## Resúmenes ejecutivos

- Lo más importante primero, en tres a cinco viñetas.
- Orientado a decisión: qué se necesita saber y qué acción se espera.
- Sin jerga innecesaria para la audiencia objetivo.

Ver comando `/resumen`.

## Bitácoras

- Fecha, contexto breve, qué se hizo, qué se aprendió, pendientes.
- Trazable y consultable después. Ver comando `/bitacora`.
