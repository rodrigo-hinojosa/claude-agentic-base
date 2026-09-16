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

**Fecha**: 15-09-2026. **Tareas**: T020-T024.

**Ediciones**: regla 26 de `rules.md` sin piso ("un párrafo sostiene una idea y no pasa de cuatro oraciones; una idea no se fragmenta en párrafos de una oración"); se quita la excepción de la 26 en el bloque de excepciones (quedan la 28 y la 33). `SKILL.md` L82 ya decía "párrafo de una idea y hasta cuatro oraciones" desde T015 (US2), adelantado porque ambas ediciones caían en la misma línea.

**Re-clavado de fixtures**:

- `prose-with-seeded-flaws.md`: se fundió "El cache se limpia los domingos." en el párrafo de Contexto (ya no es un párrafo de una oración aislado). El desvío R26 nuevo se sembró en el párrafo del pipeline de Alcance: 5 oraciones, cada una con un dato distinto (fuentes, reintento, formato de salida, notificación, alerta), sin reformular entre sí, conservando la oración original de más de 30 palabras como primera oración (desvío R27, misma ubicación). Se quitó la autodescripción del cuerpo.
- `prose-conforming.md`: se quitó la autodescripción del cuerpo. Sin otros cambios de contenido.

**Comando ampliado sobre ambos, resultado final**:

| Archivo | R26 5+ | R27 | R28 | R29 guiones / párrafos | R33 |
| --- | --- | --- | --- | --- | --- |
| `prose-conforming.md` | 0 de 5 | 0 de 11 | 0.0 | 0.0 / 0 | 0 |
| `prose-with-seeded-flaws.md` | 1 de 7 | 1 de 14 | 4.0 | 15.8 / 1 | 0 |

Coincide con quickstart §3: el conforme en cero en toda métrica; el sembrado con exactamente un disparo por regla de comando (26, 27, 28, 29). Las cabeceras citan esta misma salida con fecha 15-09-2026. Los desvíos de Juicio (30, 31, 32) no cambiaron de ubicación y no requieren comando.

**Grep FR-010**: `'entre dos y cuatro'` en `rules.md` = 0. **Barrido corporativo** sobre ambos archivos: 0.

## E4 — User Story 4 (Estructura proporcionada)

**Fecha**: 15-09-2026. **Tareas**: T025-T030.

**Ediciones**: regla 25 de `rules.md` se activa por naturaleza declarada (plan, manual, spec larga, página SSOT de dominio, autoridad de datos que otros consumen) o petición del usuario; se retira "más de ~4 secciones" como disparador. El callout queda como única apertura de propósito y alcance; el bloque de viñetas de la regla 7 va inmediatamente después, sin encabezado propio; la nota de mantención de la trazabilidad inversa lleva contenido definido o se omite si nadie consume el dato todavía. Regla 7 acotada al tipo resumen y a documentos bajo la regla 25. `SKILL.md` §3 paso 2 espeja los mismos cambios y agrega la doc-tecnica de tema único a los tipos que no reciben la estructura. `templates.md` §2 declara que, bajo la regla 25, la sección 1 se materializa como el callout y la numeración arranca en "1. Descripción" (la corrección correspondiente ya había quedado registrada en §7 durante US1, T005).

**Generaciones regeneradas y nuevas** (contrato 7): `output-doc-tecnica-small.md` regenerado con el mismo insumo de US1 — ya no lleva callout, tabla de metadatos ni índice, porque un módulo de tema único no cumple el disparador. `input-bitacora-short.md` / `output-bitacora-short.md` nuevos (hechos de una jornada, sin aprendizajes): la sección "Aprendizajes" se omite (no se marca), y no hay bloque de viñetas de apertura.

**Resultados**:

| Verificación | Esperado | Obtenido |
| --- | --- | --- |
| Doc-tecnica sin callout/metadatos/índice | 0 líneas | 0 |
| Bitácora sin bloque de viñetas de apertura | 0 | 0 (única lista es "Pendientes", que es contenido, no resumen ejecutivo) |
| Grep genérico sobre ambas salidas | 0 y 0 | 0 y 0 |
| R33 (comando ampliado) sobre ambas salidas | 0 y 0 | 0 y 0 |
| `'~4 secciones'` en `SKILL.md` y `rules.md` | 0 y 0 | 0 y 0 |
| Regla 7 con "regla 25" | 1 | 1 |
| Barrido corporativo sobre archivos tocados y evidencia nueva | 0 | 0 |

**Nota de continuidad**: la doc-tecnica pequeña se generó dos veces en la feature (T010 con la estructura de la regla 25 vigente entonces, T029 sin ella). Ambas versiones quedan en el historial de commits; solo la de T029 permanece en `output-doc-tecnica-small.md`.

## E5 — User Story 5 (Ejemplos que enseñan solo concisión)

**Fecha**: 15-09-2026. **Tareas**: T031-T036.

**Ediciones**: `compliant-adr.md` reescrito bajo el contrato 6 — callout de envoltorio movido a la cabecera HTML, sin "Próximos pasos", Referencias sin citar `templates.md`, dueño con nombre sintético, sin la oración que anticipaba la Decisión. `structured-doc.md` reescrito bajo los contratos 5 y 6 — bloque de apertura completo (callout único, 3 viñetas, metadatos, índice, trazabilidad con nota de mantención definida), secciones 1 a 4 alineadas a `templates.md` §2, hecho SSOT una sola vez, sin meta-comentario. `seeded-violations.md`: cabecera con la lista enumerada de 10 violaciones (regla y método), ubicadas por cita en vez de número de línea para no acoplarse al tamaño de la propia cabecera; cuerpo sin cambios. `SKILL.md` §3 y §4 enlazan `prose-conforming.md` y `prose-with-seeded-flaws.md`.

**Un ajuste durante la implementación**: al escribir por primera vez las ubicaciones de la lista de `seeded-violations.md` con número de línea fijo, crecer la cabecera desplazó las líneas reales del cuerpo y la cita quedó desactualizada en el mismo commit. Se corrigió citando por texto o sección en vez de número de línea; solo la salida del comando (que sí es de la implementación real) cita una línea, y se recomputa si la cabecera vuelve a cambiar de tamaño.

**Comando ampliado sobre los cinco fixtures, resultado final**:

| Archivo | R26 5+ | R27 | R28 | R29 guiones / párrafos | R33 |
| --- | --- | --- | --- | --- | --- |
| `prose-conforming.md` | 0 | 0 | 0.0 | 0.0 / 0 | 0 |
| `prose-with-seeded-flaws.md` | 1 | 1 | 4.0 | 15.8 / 1 | 0 |
| `structured-doc.md` | 0 | 0 | 0.0 | 0.0 / 0 | 0 |
| `compliant-adr.md` | 0 | 0 | 0.0 | 0.0 / 0 | 0 |
| `seeded-violations.md` | 0 | 1 | 0.0 | 0.0 / 0 | 1 |

Coincide con lo que cada cabecera promete: dos conformes en cero, dos sembrados con exactamente sus desvíos declarados.

**Auditorías finales persistidas**: [audit-compliant-adr.md](audit-compliant-adr.md), [audit-structured-doc.md](audit-structured-doc.md) y [audit-prose-conforming.md](audit-prose-conforming.md) (las tres `conforme`, 0 hallazgos, reemplazando o confirmando corridas previas) y [audit-seeded-violations.md](audit-seeded-violations.md) (`no-conforme`, exactamente los 10 hallazgos de la cabecera, con la regla 26 ya sin discrepancia porque no tiene piso).

**Verificaciones de quickstart**: §2 FR-015 (ambos fixtures enlazados en `SKILL.md`, ≥1 cada uno); §5 (encabezados de ambos ejemplos conformes, hecho SSOT = 1, sin "Próximos pasos" ni cita a `templates.md` en el ADR); §6 "Lo que se conserva" (`git diff main` sobre las filas 27-32, 4, 13, 23, 3, 21, 6 de `rules.md`: sin salida, ninguna cambió). Barrido corporativo sobre toda la skill (`SKILL.md`, `rules.md`, `templates.md`, los cinco ejemplos): 0.

## E6 — Cierre (quickstart completo)

**Fecha**: 15-09-2026. **Tareas**: T037-T039.

**Procedencia declarada** (D16, regla 09): `rules.md` L3 y `templates.md` §Procedencia citan la revisión del 15-09-2026 (feature 003) con las reglas y secciones que cambiaron.

**Quickstart completo (§1 a §10), corrida final**:

| Bloque | Resultado |
| --- | --- |
| §1 Barrido corporativo | 0 en ambos patrones |
| §2 Greps de texto | Los 14 conformes |
| §3 Comando sobre los 8 archivos | Los tres normativos en R33 = 0; los cinco fixtures igual a su cabecera |
| §4 Autodetección | R33 = 0 en `rules.md`, `SKILL.md`, `templates.md` |
| §5 Encabezados de ejemplos | Ambos coinciden con su plantilla; SSOT = 1; sin "Próximos pasos" ni cita a `templates.md` en el ADR |
| §6 Lo que se conserva | `git diff main` sin cambios en las filas 27-32, 4, 13, 23, 3, 21, 6; frases ancla presentes (corregido un grep case-sensitive propio que daba falso negativo en "se omite si no") |
| §7 Auditorías persistidas | Las cuatro con el veredicto y los hallazgos esperados |
| §8 Generaciones persistidas | Las tres con línea marcada, sin genérico, sin R33 |
| §9 Punteros | Sin enlaces rotos; detector de dependencias externas sin salida |
| §10 Cierre | `evidence.md` completo (esta entrada); rama limpia salvo este cierre |

**Un hallazgo de proceso, sin impacto en el resultado**: el grep de "Lo que se conserva" para `se omite si no` no llevaba `-i` y no encontraba las tres ocurrencias reales (con mayúscula inicial de oración). Es un defecto del comando de verificación, no del contenido — `templates.md` conserva las tres frases intactas. Corregido en `quickstart.md` §6.

**Resumen de la feature**: 39 tareas completadas en 6 commits (`8dc8ec7` diseño, `52516bd` US1, `706c112` US2, `9d55f1a` US3, `4cc47b5` US4, `f66610a` US5, más este cierre). Las cinco historias de la spec están implementadas y verificadas con la skill real, no con aproximaciones. Pendiente fuera de esta feature: recomputar la línea base de prosa (`Pendiente de recomputar`, se hace después de integrar); protección técnica de `main` en GitHub.
