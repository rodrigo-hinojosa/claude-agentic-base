# Documentación técnica — `notify-queue`

> Documenta el módulo `notify-queue`: qué hace, cómo se usa y qué decisiones quedan registradas sobre su diseño.

| Campo | Valor |
| --- | --- |
| Artefacto documentado | `notify_queue.py` (sintético) |
| Tipo | Documentación técnica |
| Última actualización | 2026-09-15 |
| Fuente | `specs/003-concision-confluence-docs/evidence/input-doc-tecnica-small.md` |

## Índice

- 1. Propósito y alcance
- 2. Descripción
- 3. Uso y ejemplos
- 4. Decisiones y supuestos
- 5. Referencias y pendientes

## 1. Propósito y alcance

Documenta el módulo `notify-queue`, que envía notificaciones cuando un job de importación termina.

## 2. Descripción

`notify-queue` recibe un evento `import.finished` con un `job_id` y un `status`. Si el `status` es `ok`, arma un mensaje corto y lo publica en el canal `#imports`. Si el `status` es `error`, publica el mismo mensaje en `#imports-errores` además de `#imports` (fuente: `input-doc-tecnica-small.md`).

## 3. Uso y ejemplos

Se invoca con `notify_queue.push(job_id, status)` desde el worker de importación, justo después de que el job termina.

```python
notify_queue.push(job_id="job-123", status="ok")
```

## 4. Decisiones y supuestos

Sin información registrada.

## 5. Referencias y pendientes

Sin pendientes.
