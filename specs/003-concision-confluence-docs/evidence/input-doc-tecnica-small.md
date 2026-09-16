Insumo sintético para probar US1 (línea marcada) y US4 (estructura proporcionada). No trae decisiones, supuestos ni pendientes: es deliberado, para verificar que el generador deja esas secciones marcadas en vez de rellenarlas.

Módulo: `notify-queue`, una cola interna que envía notificaciones a un canal de mensajería cuando un job de importación termina.

Qué hace: recibe un evento `import.finished` con un `job_id` y un `status`. Si `status` es `ok`, arma un mensaje corto y lo publica en el canal `#imports`. Si `status` es `error`, publica el mismo mensaje en `#imports-errores` además de `#imports`.

Cómo se usa: se invoca con `notify_queue.push(job_id, status)` desde el worker de importación, después de que el job termina.

Fuente: código de `notify_queue.py` (archivo sintético, no existe en ningún repositorio real).
