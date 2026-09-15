# Bitácora — 2026-09-15

## Contexto

15-09-2026. Se trabajó sobre el pipeline de `notify-queue` para reducir mensajes perdidos por registros incompletos.

## Hecho

Se agregó el reintento de hasta tres veces antes de descartar un registro incompleto. Se probó con los jobs sintéticos `job-201`, `job-202` y `job-203`; los tres pasaron sin descartes.

## Pendientes

Agregar la alerta al equipo de datos cuando un lote se descarta por completo.
