Auditoría de `.claude/skills/confluence-docs/examples/seeded-violations.md`, corrida el 15-09-2026 (tarea T018, US2). No es la clave definitiva de la cabecera del fixture: esa auditoría corre en T033, después de re-clavar la regla 26 (US3) y la regla 25/7 (US4), que aún no están implementadas en este checkpoint. Aquí solo se verifica que el detector de relleno (regla 33 y regla 10 ampliada) funciona.

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

**Nota sobre la regla 26**: el comando ya no publica "párrafos de 1 oración" (T012), pero el texto de la regla 26 conserva el piso "entre dos y cuatro oraciones" hasta T020 (US3). El párrafo L22 y el de "Conclusión" (L33) son de una sola oración; no se reportan aquí como hallazgo de comando, porque el instrumento que los mediría ya cambió y el criterio de la regla todavía no. Se resuelve en T024, cuando ambos coincidan.
