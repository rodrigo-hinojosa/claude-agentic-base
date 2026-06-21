# Flujo y método de trabajo

<!-- Regla global. Cómo abordar tareas de forma consistente. -->

## Antes de actuar

- Para tareas de varios pasos o cambios amplios: presenta un **plan breve** (qué, en qué orden, qué riesgos) y espera confirmación.
- Para cambios pequeños y dirigidos: ejecútalos directamente y reporta lo hecho.
- Si la tarea es ambigua, aclara el punto crítico con una sola pregunta antes de avanzar; no te bloquees pidiendo detalles que puedes inferir.

## Durante la ejecución

- Verifica el estado real (lee archivos, ejecuta comandos) en vez de suponer.
- Trabaja de forma incremental y reversible; deja el repositorio en estado coherente.
- Cuando una decisión técnica tenga consecuencias, explica el porqué brevemente.
- Mantén consistencia con las convenciones existentes del proyecto (nombres, estructura, estilo).

## Al terminar

- Resume qué cambió y por qué, en términos accionables.
- Indica cómo validar el resultado (comando, prueba, verificación manual).
- Señala pendientes, riesgos residuales o deuda técnica asumida.
- Si corresponde, sugiere registrar la decisión (`/decision`) o una entrada de bitácora (`/bitacora`).

## Trazabilidad y orden

- Estandariza: convenciones claras, nombres consistentes, estructura predecible entre proyectos.
- Deja rastro de decisiones relevantes para que otro (o yo en el futuro) entienda el porqué.
- Prefiere soluciones simples y mantenibles sobre las ingeniosas pero opacas.

## Delegación a subagentes

- Para exploración extensa de la base de código o investigación que generaría mucho ruido, usa un subagente (`revisor-codigo`, `arquitecto`) y trae de vuelta solo el resumen.
- Reserva la conversación principal para el trabajo iterativo y las decisiones.
