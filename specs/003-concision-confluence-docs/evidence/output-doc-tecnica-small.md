# Documentación técnica — `notify-queue`

Documenta el módulo `notify-queue`, que envía notificaciones cuando un job de importación termina.

## Descripción

`notify-queue` recibe un evento `import.finished` con un `job_id` y un `status`. Si el `status` es `ok`, arma un mensaje corto y lo publica en el canal `#imports`. Si el `status` es `error`, publica el mismo mensaje en `#imports-errores` además de `#imports` (fuente: `input-doc-tecnica-small.md`).

## Uso y ejemplos

Se invoca con `notify_queue.push(job_id, status)` desde el worker de importación, justo después de que el job termina.

```python
notify_queue.push(job_id="job-123", status="ok")
```

## Decisiones y supuestos

Sin información registrada.

## Referencias y pendientes

Sin pendientes.
