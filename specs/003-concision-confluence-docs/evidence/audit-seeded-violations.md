Auditoría definitiva de `.claude/skills/confluence-docs/examples/seeded-violations.md`, corrida el 15-09-2026 (tarea T033, US5), con las reglas 25, 26 y 33 ya en su forma final (post US2-US4). Reemplaza la auditoría parcial de T018 (US2), que dejaba fuera el desvío de la regla 26 porque el comando y el texto de la regla estaban desincronizados en ese checkpoint.

```text
Veredicto: no-conforme
Resumen: 10 hallazgos (alta: 9, media: 1, baja: 0)

| Regla | Ubicación | Severidad | Corrección sugerida |
|-------|-----------|-----------|----------------------|
| 16 | L27-28, bloque de código | alta | Quitar las credenciales de ejemplo; usar un placeholder sin formato de secreto real |
| 1 | L18, "It handles data aggregation and rendering" | alta | Traducir la oración al español |
| 2 | L16, título | alta | Quitar el emoji |
| 33 | L18, "Este documento explica" | alta | Eliminar la frase y abrir con el dato |
| 10 (Juicio) | L20, "El proyecto avanza según lo planeado... La API es rápida y el sistema es robusto" | alta | Sustituir por `Sin información registrada` o citar una métrica real del módulo |
| 4 | L18 | alta | Abrir con propósito y alcance en 1-2 frases, sin mezclar la descripción técnica ni la muletilla |
| 5 | Cierre del documento | alta | Agregar próximos pasos, pendientes o referencias; si no hay ninguno, dejar la línea marcada |
| 9 | L22, "según el business case original" | alta | Citar o enlazar el business case, o quitar la referencia |
| 27 | L22, oración del roadmap | alta | Partir la oración en dos |
| 32 (Juicio) | L33, "En resumen, el módulo cumple su objetivo..." | media | Cerrar con el último dato concreto, sin sentencia de remate |
```

**Regla 26**: sin hallazgo. Sin piso (US3), un hecho que cabe en una oración no exige una segunda; los párrafos de una oración de L22 y L33 no fragmentan una idea que debiera ir junta, así que no incumplen. **Regla 7**: sin hallazgo por ausencia de viñetas; este documento no es tipo resumen ni activa la regla 25, así que no las necesita.
