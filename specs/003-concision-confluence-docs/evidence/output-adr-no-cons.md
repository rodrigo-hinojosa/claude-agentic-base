# ADR-E01: Deduplicar notificaciones de `notify-queue` por `job_id`

## Estado

Propuesta. Dueño: responsable del módulo `notify-queue` (rol sintético) | Fecha: 2026-09-15.

## Contexto

Un mismo job de importación puede reintentar y emitir el evento `import.finished` más de una vez. Sin deduplicación, el canal de notificaciones recibe mensajes repetidos por el mismo job.

## Decisión

`notify-queue` deduplica mensajes por `job_id`, guardando en memoria los últimos 500 ids procesados (fuente: `input-adr-no-cons.md`).

## Alternativas consideradas

- **Deduplicar por hash del contenido del mensaje**: descartada porque dos jobs distintos pueden generar el mismo texto de mensaje, y esa coincidencia perdería una notificación real.

## Consecuencias

Positivas: la comparación de `job_id` es barata y no depende del formato del mensaje. Negativas: Pendiente: la fuente no registra contras de la alternativa elegida.
