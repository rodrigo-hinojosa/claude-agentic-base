# Evidencia de validación — feature 003

Registro de las corridas que verifican cada historia del feature 003, con fecha. No es un fixture: describe lo que se ejecutó, no promete cifras futuras. Autoridad de los criterios: [quickstart.md](../quickstart.md).

## Línea de partida (15-09-2026)

Comando ampliado (contrato 1) sobre el estado de `main` en `560225a`, antes de cualquier edición de esta feature. Fuente: `contracts/prose-command.md` §6, verificado con la implementación de referencia.

| Archivo | R26 5+ | R27 | R28 | R29 guiones / párrafos | R33 |
| --- | --- | --- | --- | --- | --- |
| `examples/prose-conforming.md` | 0 de 6 | 0 de 13 | 0.0 | 0.0 / 0 | 0 |
| `examples/prose-with-seeded-flaws.md` | 0 de 9 | 1 de 12 | 4.7 | 18.6 / 1 | 0 |
| `examples/structured-doc.md` | 0 de 15 | 3 de 24 | 0.0 | 0.0 / 0 | 0 |
| `examples/compliant-adr.md` | 0 de 6 | 0 de 11 | 0.0 | 6.3 / 0 | 0 |
| `examples/seeded-violations.md` | 0 de 5 | 1 de 8 | 0.0 | 0.0 / 0 | 1 (L18) |
| `rules.md` | 3 de 15 | 4 de 51 | 0.0 | 9.0 / 1 | 0 |
| `SKILL.md` | 3 de 30 | 8 de 88 | 0.7 | 8.2 / 1 | 0 |
| `templates.md` | 0 de 20 | 0 de 21 | 0.0 | 3.4 / 0 | 0 |

Cifras del comando vigente (previo a la ampliación), corridas el 15-09-2026, de `research.md` §2:

| Archivo | Métrica | Comando vigente | Sin cabecera HTML | Cabecera promete |
| --- | --- | --- | --- | --- |
| `prose-with-seeded-flaws.md` | R26 párrafos de 1 oración | 7 de 13 | 6 de 9 | 1 |
| `prose-with-seeded-flaws.md` | R26 párrafos de 5 o más | 1 de 13 | 1 de 9 | 0 |
| `prose-conforming.md` | R26 párrafos de 1 oración | 1 de 8 | 1 de 6 | 0 |
| `structured-doc.md` | R27 oraciones de 30+ | 3 de 24 | sin cabecera HTML | no declara |
| `compliant-adr.md` | R26 párrafos de 1 oración | 2 de 6 | sin cabecera HTML | no declara |
| `seeded-violations.md` | R27 oraciones de 30+ | 1 de 17 | 1 de 13 | no declara |

## E1 — User Story 1 (Vacíos con línea marcada)

**Fecha**: 15-09-2026. **Tareas**: T004-T011.

**Ediciones**: sección "Secciones obligatorias y vacíos" nueva en `templates.md` (formas canónicas, familia aceptada por el auditor, invariantes); §2 y §3 remiten a ella en vez de "todas obligatorias" a secas; §2 fila 4 distingue supuestos de la fuente de los del redactor; §7 con dos correcciones registradas (la de esta historia y la de US4, adelantada porque ambas van en la misma tabla). Regla 5 y 11 de `rules.md` citan la línea marcada. `SKILL.md` §3 paso 4 sin "supuesto explícito".

**Generaciones persistidas** (contrato 7): `input-doc-tecnica-small.md` / `output-doc-tecnica-small.md` (módulo `notify-queue`, sin decisiones ni pendientes) e `input-adr-no-cons.md` / `output-adr-no-cons.md` (decisión con dos alternativas, sin contras ni referencias). Invocadas vía `Skill(confluence-docs)`.

**Resultados**:

| Verificación | Esperado | Obtenido |
| --- | --- | --- |
| Grep genérico (§8) sobre ambas salidas | 0 y 0 | 0 y 0 |
| Línea marcada presente sobre ambas salidas | ≥ 1 y ≥ 1 | 2 (doc-tecnica: "Sin información registrada", "Sin pendientes") y 1 (ADR: "Pendiente: la fuente no registra contras", embebida en "Negativas: ...") |
| `supuesto explícito` en `SKILL.md` | 0 | 0 |
| Regla 5 con "cuando corresponda" | 1 | 1 |
| "Secciones obligatorias y vacíos" en los tres archivos | ≥ 1 c/u | `SKILL.md` 1, `rules.md` 2, `templates.md` 5 |
| "Sin información registrada" en `rules.md`/`SKILL.md` | 0 y 0 | 0 y 0 |
| R33 (comando ampliado, adelantado desde US2 solo para esta verificación) sobre ambas salidas | 0 y 0 | 0 y 0 |

**Hallazgo de proceso**: el grep de línea marcada en `quickstart.md` §8 estaba anclado al inicio de línea (`^Pendiente:`). La sección "Consecuencias" del ADR mezcla un dato real (positivas) con un sub-ítem vacío (contras), y la línea marcada queda embebida como "Negativas: Pendiente: ..." en vez de ocupar toda la línea. Corregido: se quitó el anclaje `^` del grep en `quickstart.md` §8. No es una desviación del contrato 2 (que define la línea marcada para una sección *entera* sin dato), sino un caso no cubierto explícitamente: una sección con contenido mixto. El texto de la sección igual queda auditable por la presencia de la frase.

**Nota de alcance**: `output-doc-tecnica-small.md` todavía lleva callout, tabla de metadatos e índice (regla 25 sin editar hasta US4); se regenera en US4 (T029) para verificar la estructura proporcionada.

## E2 — User Story 2 (Detector de relleno)

**Fecha**: 15-09-2026. **Tareas**: T012-T019.

**Ediciones**: comando de prosa de `rules.md` reemplazado por la implementación de referencia del contrato 1 (excluye bloques de código y comentarios HTML conservando líneas, sin la métrica de párrafos de una oración, con conteo y ubicación de muletillas). Fila 33 nueva en la tabla de prosa (Comando para su lista cerrada, Juicio para la repetición del encabezado); regla 10 ampliada con el criterio de Juicio del genérico sin dato. `SKILL.md` §3 con autochequeo de las reglas 26-33 y cita de cifras al materializar en disco; §4 con hallazgos de relleno tipados y la marca "(Juicio)" extendida a la 33. `templates.md` §8 con la fila de auditar reescrita.

**Resultados del comando ampliado** (implementación real, extraída de `rules.md` y corrida sobre los ocho archivos):

| Archivo | R26 5+ | R27 | R28 | R29 párrafos 2+ | R33 |
| --- | --- | --- | --- | --- | --- |
| `examples/prose-conforming.md` | 0 | 0 | 0.0 | 0 | 0 |
| `examples/prose-with-seeded-flaws.md` | 0 | 1 | 4.7 | 1 | 0 |
| `examples/structured-doc.md` | 0 | 3 | 0.0 | 0 | 0 |
| `examples/compliant-adr.md` | 0 | 0 | 0.0 | 0 | 0 |
| `examples/seeded-violations.md` | 0 | 1 | 0.0 | 0 | 1 (L18) |
| `rules.md` | 5 | 6 | 0.0 | 1 | 0 |
| `SKILL.md` | 3 | 9 | 0.6 | 1 | 0 |
| `templates.md` | 0 | 1 | 0.0 | 0 | 0 |

Coincide con lo esperado en quickstart §3 y §4: R33 = 1 en `seeded-violations.md` (línea real, no la de la cabecera) y 0 en los otros siete. Autodetección confirmada: los tres archivos normativos dan R33 = 0.

**Auditorías persistidas**: [audit-seeded-violations.md](audit-seeded-violations.md) (`no-conforme`, 10 hallazgos, incluidos 33 alta y 10 ampliada alta) y [audit-prose-conforming.md](audit-prose-conforming.md) (`conforme`, 0 hallazgos). La de `seeded-violations.md` es parcial a propósito: no incluye el desvío de la regla 26 (piso) porque el comando ya no lo mide pero el texto de la regla aún no cambia hasta US3; se re-corre en T033 para fijar la clave definitiva de la cabecera.

**Greps de quickstart §2 (FR-005, FR-007)**: fila 33 = 1, encabezado "26-33" = 1, "parrafos de 1 oracion" = 0, "no términos literales" = 0. Todos conformes.

## E3 — User Story 3 (Regla 26 sin piso)

`Pendiente de registrar` tras ejecutar T020-T024.

## E4 — User Story 4 (Estructura proporcionada)

`Pendiente de registrar` tras ejecutar T025-T030.

## E5 — User Story 5 (Ejemplos que enseñan solo concisión)

`Pendiente de registrar` tras ejecutar T031-T036.

## E6 — Cierre (quickstart completo)

`Pendiente de registrar` tras ejecutar T037-T039.
