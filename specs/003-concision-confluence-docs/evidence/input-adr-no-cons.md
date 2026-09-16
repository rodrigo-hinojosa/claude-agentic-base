Insumo sintético para probar US1 (línea marcada). Trae una decisión con dos alternativas reales y sus consecuencias positivas, pero la fuente no registra contras ni documentos relacionados: es deliberado, para verificar que el generador deja esas secciones marcadas en vez de inventar contras o referencias.

Decisión: el equipo de la cola `notify-queue` (ver `input-doc-tecnica-small.md`) decidió usar un `job_id` como clave de deduplicación de mensajes, en vez de un hash del contenido del mensaje.

Contexto: un mismo job puede reintentar y emitir el evento `import.finished` más de una vez; sin deduplicación, el canal recibe mensajes repetidos.

Alternativa A (elegida): deduplicar por `job_id`, guardando en memoria los últimos 500 ids procesados.

Alternativa B (descartada): deduplicar por hash del contenido del mensaje, descartada porque dos jobs distintos pueden generar el mismo texto de mensaje y se perdería una notificación real.

Consecuencias positivas: la deduplicación es barata (una comparación de id) y no depende del formato del mensaje.

La fuente no registra contras de la alternativa elegida, ni documentos o tickets relacionados.

Dueño: responsable del módulo `notify-queue` (rol sintético). Fecha: 15-09-2026.
