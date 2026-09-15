Insumo sintético para probar US4 (estructura proporcionada). Trae hechos de una sola jornada, sin aprendizajes que registrar: es deliberado, para verificar que el generador omite la sección "Aprendizajes" en vez de rellenarla, y que una bitácora corta no lleva bloque de viñetas de apertura.

Fecha: 2026-09-15.

Qué se hizo: se agregó el reintento de hasta tres veces al pipeline de `notify-queue` antes de descartar un registro incompleto. Se probó con tres jobs sintéticos (`job-201`, `job-202`, `job-203`); los tres pasaron sin descartes.

Nada que aprender de esta jornada: el cambio salió como se planeó, sin sorpresas.

Pendiente: agregar la alerta al equipo de datos cuando un lote se descarta por completo (todavía no implementada).
