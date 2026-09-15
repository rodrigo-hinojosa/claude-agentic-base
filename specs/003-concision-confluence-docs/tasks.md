# Tasks: Concisión en confluence-docs

**Input**: documentos de diseño de `/specs/003-concision-confluence-docs/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md) (§3 decisiones D1-D17, §4 mapa de cambios por línea), [data-model.md](data-model.md), [contracts/prose-command.md](contracts/prose-command.md) (contrato 1), [contracts/interfaces.md](contracts/interfaces.md) (contratos 2-7), [quickstart.md](quickstart.md)

**Naturaleza de las tareas**: edición en sitio de los tres archivos de la skill (`SKILL.md`, `rules.md`, `templates.md`) y de sus cinco ejemplos. Las líneas citadas corresponden al estado de `main` (`560225a`); tras la primera edición de un archivo se localizan por su texto, no por su número. Los ejemplos se corrigen por borrado (D17): no se agrega prosa salvo la línea marcada, el dato que una sección obligatoria exija o el desvío R26 sembrado.

**Gate del dueño**: al cerrar cada fase, la ejecución se detiene y reporta. La fase siguiente no comienza sin su instrucción.

**Tests**: la spec no pide TDD. Las verificaciones son las del [quickstart.md](quickstart.md), ejecutadas en las tareas de cierre de cada historia y registradas en `evidence/evidence.md`. Las corridas con el modelo (generar, auditar) se persisten según el contrato 7.

**Regla de autodetección** (edge case de la spec): ninguna tarea escribe en prosa de `rules.md`, `SKILL.md` o `templates.md` una frase de la lista cerrada del contrato 1 §3. Se describen por su función y se remite al comando.

## Phase 1: Setup

- [ ] T001 Verificar precondiciones en la raíz del repo: rama `003-concision-confluence-docs` activa, working tree con solo `.specify/feature.json` y `specs/003-concision-confluence-docs/` pendientes, `python3` disponible, y `git diff main --stat -- .claude/skills/confluence-docs/` vacío (la skill parte del estado de `main`)
- [ ] T002 Commit de diseño con mensaje `docs: especificar y planificar feature 003 concisión en confluence-docs`, staging acotado a `.specify/feature.json` y `specs/003-concision-confluence-docs/` (spec, checklist, plan, research, data-model, contracts, quickstart, tasks)

## Phase 2: Foundational

**Bloquea a las cinco historias**: todas registran su evidencia en el índice que esta fase crea.

- [ ] T003 Crear `specs/003-concision-confluence-docs/evidence/evidence.md` con la sección "Línea de partida (15-09-2026)": la tabla del contrato 1 §6 (salida del comando ampliado sobre los ocho archivos en `main`) y las cifras del comando vigente de research §2, más una sección vacía por historia (E1 a E5) y una de cierre (E6)

**Checkpoint**: índice de evidencia listo. Detenerse y reportar al dueño.

---

## Phase 3: User Story 1 — Vacíos con línea marcada (Priority: P1)

**Goal**: toda sección obligatoria sin dato real queda presente con una sola línea marcada, nunca con prosa; la línea marcada se define una vez en `templates.md` y las reglas la citan.

**Independent Test**: generar una doc-tecnica y un ADR desde insumos sintéticos sin decisiones ni pendientes; cada sección obligatoria conserva su línea marcada y el grep de frases genéricas (quickstart §8) da cero. Greps de quickstart §2 para FR-002, FR-003 y contrato 2.

- [ ] T004 [US1] Agregar en `.claude/skills/confluence-docs/templates.md` la sección sin número `## Secciones obligatorias y vacíos`, después de "Procedencia" y antes de `## 1. Índice de tipos`, con los cinco puntos del contrato 2: obligatoria significa presente y no llena; tres formas canónicas que emite el generador; familia que acepta el auditor (regla 01: `Pendiente`, `Por completar`, con o sin detalle); invariantes (una sola línea, único contenido, `propuesta no validada` si el usuario pide inferir); qué no hace (no convierte un no-ADR en ADR; bitácora y resumen omiten, no marcan)
- [ ] T005 [US1] En `.claude/skills/confluence-docs/templates.md`, reemplazar las dos frases "Todas las secciones son obligatorias." (§2 L38 y §3 L54) por una que remita a "Secciones obligatorias y vacíos" (presentes, no llenas; vacío con línea marcada), y registrar en §7 Correcciones la definición superada ("obligatoria" leída como "llena"), con fecha de esta feature y motivo
- [ ] T006 [US1] En `.claude/skills/confluence-docs/templates.md` §2 fila 4 "Decisiones y supuestos" (L45), distinguir los supuestos que trae la fuente de los que introduciría el redactor: solo los primeros entran; si la fuente no trae ninguno, línea marcada (FR-004)
- [ ] T007 [US1] En `.claude/skills/confluence-docs/rules.md`, reescribir la regla 5 (L19) con "cuando corresponda" y la salida al vacío del cierre, y la regla 11 (L25) con "secciones obligatorias presentes, con línea marcada si no hay dato real", ambas citando "Secciones obligatorias y vacíos" de `templates.md` sin reproducir las formas (FR-002, contrato 2)
- [ ] T008 [US1] En `.claude/skills/confluence-docs/SKILL.md` §3 paso 4 (L80), quitar "supuesto explícito": si falta un dato va la línea marcada (citar la sección de `templates.md`) o una pregunta abierta; la inferencia solo ocurre si el usuario la pide y se rotula `propuesta no validada` (FR-003)
- [ ] T009 [P] [US1] Escribir los insumos sintéticos `specs/003-concision-confluence-docs/evidence/input-doc-tecnica-small.md` (módulo pequeño con nombre inventado, comando de uso, sin decisiones ni pendientes, declarándolo al inicio) e `input-adr-no-cons.md` (decisión con dos alternativas reales y consecuencias positivas, sin contras ni referencias, declarándolo al inicio), según el contrato 7
- [ ] T010 [US1] Invocar `confluence-docs` en modo generar con cada insumo de T009 pidiendo materializar `specs/003-concision-confluence-docs/evidence/output-doc-tecnica-small.md` y `output-adr-no-cons.md`; verificar quickstart §8 sobre ambas salidas (grep genérico = 0; al menos una línea marcada; en el ADR, contras como `Pendiente: la fuente no registra contras` y sin `Referencias`), y anotar que la salida de doc-tecnica aún trae la estructura de la regla 25 porque US4 no se ha implementado
- [ ] T011 [US1] Ejecutar los greps de quickstart §2 que cubren FR-002, FR-003 y el contrato 2 ('supuesto explícito' = 0; regla 5 con 'cuando corresponda' = 1; 'Secciones obligatorias y vacíos' ≥ 1 en los tres archivos; 'Sin información registrada' = 0 en `rules.md` y `SKILL.md`), registrar E1 en `specs/003-concision-confluence-docs/evidence/evidence.md` con fecha, y commitear con mensaje `feat: vacíos con línea marcada en confluence-docs`, staging acotado a los tres archivos de la skill y a `evidence/`

**Checkpoint**: US1 entregable por sí sola. Detenerse y reportar al dueño.

---

## Phase 4: User Story 2 — Detector de relleno (Priority: P2)

**Goal**: la regla 33 (Comando, lista cerrada) y la regla 10 ampliada (Juicio) existen en `rules.md`; el comando ampliado cuenta muletillas y deja de publicar párrafos de una oración; generar autochequea las reglas 26 a 33; auditar detecta relleno y lo bloquea.

**Independent Test**: el comando ampliado sobre `examples/seeded-violations.md` reporta una muletilla en L18 y cero sobre `examples/prose-conforming.md` y sobre los tres archivos normativos (quickstart §3 y §4). Auditar `seeded-violations.md` produce hallazgos altos por la 33 y la 10 con veredicto `no-conforme`.

- [ ] T012 [US2] En `.claude/skills/confluence-docs/rules.md`, reemplazar el bloque de código del comando (L68-93) por la implementación de referencia del contrato 1 §5, reformular el párrafo "El comando, blindado" (L66) según D6 y D10 (mide estructura y una lista cerrada declarada; excluye bloques de código y comentarios HTML conservando líneas; no se detecta a sí mismo porque la lista vive en el bloque que excluye), y agregar en el párrafo de línea base (L98) que la 33 no lleva línea base: cada coincidencia es hallazgo salvo la excepción de contexto
- [ ] T013 [US2] En `.claude/skills/confluence-docs/rules.md`, cambiar el encabezado L41 a "Reglas de prosa (26-33)"; agregar la fila 33 al final de la tabla de prosa (la primera oración de una sección entra en materia: sin muletilla de apertura ni de transición, con lista cerrada en el comando, y sin repetir el encabezado; prosa; alta; Comando); agregar en L57 que la parte de encabezado de la 33 se marca Juicio; agregar en L59 la excepción de la 33 (frase de la lista que introduce un bloque de código o una tabla); agregar el bullet "33 — repetición del encabezado" en los criterios de Juicio (L61-64). Sin citar ninguna frase de la lista en prosa
- [ ] T014 [US2] En `.claude/skills/confluence-docs/rules.md`, ampliar la regla 10 (L24): "faltantes = línea marcada (`templates.md`, Secciones obligatorias y vacíos) o pregunta abierta", más el criterio de Juicio: una afirmación válida para cualquier proyecto, sin dato propio del documentado, es relleno y se sustituye por la línea marcada (FR-006)
- [ ] T015 [US2] En `.claude/skills/confluence-docs/SKILL.md` §3: agregar al paso 4 L80 que el genérico sin dato es relleno (regla 10); en L82 agregar "sin muletilla de apertura ni de transición" y cambiar el rango a "reglas 26-33"; reescribir el paso 6 (L84) como autochequeo del bloque de prioridad alta más las reglas 26 a 33, y, cuando el documento se materializa en disco, correr el comando de `rules.md` y citar sus cifras (FR-008)
- [ ] T016 [US2] En `.claude/skills/confluence-docs/SKILL.md` §4: agregar en el paso 2 los hallazgos de relleno del contrato 4 (33 por comando sobre archivo en disco, o aplicando por lectura la lista de `rules.md` sobre texto pegado; 10 ampliada por Juicio; correcciones sugeridas concretas) y en el paso 3 (L100) que la marca "(Juicio)" cubre también la parte de encabezado de la 33 (FR-009)
- [ ] T017 [US2] En `.claude/skills/confluence-docs/templates.md` §8 (L122), reescribir la fila auditar: detecta faltantes, fuera de orden y relleno; una sección obligatoria con prosa genérica en vez de línea marcada es hallazgo de la 10 (FR-009)
- [ ] T018 [US2] Correr el comando ampliado sobre los ocho archivos de `.claude/skills/confluence-docs/` (quickstart §3 y §4; esperado: R33 = 1 en `seeded-violations.md` L18 y 0 en los otros siete) y auditar con la skill `examples/seeded-violations.md` y `examples/prose-conforming.md`, guardando los reportes en `specs/003-concision-confluence-docs/evidence/audit-seeded-violations.md` y `audit-prose-conforming.md` (esperado: `no-conforme` con 33 y 10 altas; `conforme` con cero hallazgos de 33 y 10, anotando cualquier otro hallazgo que US5 corrija)
- [ ] T019 [US2] Ejecutar los greps de quickstart §2 que cubren FR-005 y FR-007 (fila 33 = 1; encabezado 26-33 = 1; 'parrafos de 1 oracion' = 0; 'no términos literales' = 0), registrar E2 en `specs/003-concision-confluence-docs/evidence/evidence.md`, y commitear con mensaje `feat: detector de relleno (regla 33 y regla 10 ampliada) en confluence-docs`

**Checkpoint**: US1 y US2 entregables. Detenerse y reportar al dueño.

---

## Phase 5: User Story 3 — Regla 26 sin piso (Priority: P3)

**Goal**: la regla 26 no fija mínimo; los dos fixtures de prosa son coherentes con su cabecera bajo la regla nueva y el comando ampliado.

**Independent Test**: comando ampliado sobre ambos fixtures (quickstart §3): `prose-conforming.md` cero en toda métrica declarada; `prose-with-seeded-flaws.md` exactamente un disparo por regla listada, con R26 = 1 párrafo de cinco o más.

- [ ] T020 [US3] En `.claude/skills/confluence-docs/rules.md`, reescribir la regla 26 (L47): "Un párrafo sostiene una idea y no pasa de cuatro oraciones. Una idea no se fragmenta en párrafos de una oración" (prosa, alta, Comando), y quitar de L59 la excepción de la 26 (quedan las de la 28 y la 33) (FR-010)
- [ ] T021 [US3] En `.claude/skills/confluence-docs/SKILL.md` L82, cambiar "párrafo de 2 a 4 oraciones" por "párrafo de una idea y hasta cuatro oraciones"
- [ ] T022 [P] [US3] Re-clavar `.claude/skills/confluence-docs/examples/prose-with-seeded-flaws.md`: fundir la oración suelta "El cache se limpia los domingos." en el párrafo de Contexto; sembrar el desvío R26 nuevo como un párrafo de cinco oraciones con un dato distinto cada una (para no activar la 31); quitar la línea de autodescripción del cuerpo (L23, US5 escenario 3, aquí para no re-clavar la cabecera dos veces); reescribir la cabecera según el contrato 3 con la lista de siete desvíos (regla, ubicación, método), fecha de contraste ISO 8601 y la salida literal del comando ampliado sobre el archivo final
- [ ] T023 [P] [US3] Re-clavar `.claude/skills/confluence-docs/examples/prose-conforming.md`: quitar la línea de autodescripción del cuerpo (L12); reescribir la cabecera según el contrato 3 (clase Conforme; alcance 26 a 32 y 33 en cero; "cero hallazgos"; fecha de contraste; salida literal del comando ampliado sobre el archivo final)
- [ ] T024 [US3] Correr el comando ampliado sobre los dos fixtures y contrastar con quickstart §3 (conforming: 0, 0, 0.0, 0, 0; seeded: R26 = 1, R27 = 1, R28 > 0.0, R29 párrafos = 1, R33 = 0), ejecutar los greps de quickstart §2 para FR-010 ('entre dos y cuatro' = 0), registrar E3 en `specs/003-concision-confluence-docs/evidence/evidence.md`, y commitear con mensaje `feat: regla 26 sin piso y fixtures de prosa re-clavados`

**Checkpoint**: US1 a US3 entregables. Detenerse y reportar al dueño.

---

## Phase 6: User Story 4 — Estructura proporcionada (Priority: P4)

**Goal**: la regla 25 se activa por naturaleza declarada o petición, con el callout como única apertura y el bloque de viñetas después de él; la regla 7 acota las viñetas al tipo resumen y a documentos bajo la 25.

**Independent Test**: generar una doc-tecnica de un módulo pequeño produce una salida sin callout, metadatos ni índice, que abre en la sección 1 con una o dos frases; generar una bitácora de tres párrafos produce una salida sin bloque de viñetas (quickstart §8). Greps de quickstart §2 para FR-012 y FR-013.

- [ ] T025 [US4] En `.claude/skills/confluence-docs/rules.md`, reescribir la regla 25 (L39) y su "cuándo" (L116) según D5: se activa si el entregable es plan, manual, spec larga, página SSOT de dominio o autoridad de datos que otros consumen, o si el usuario lo pide; sin "más de ~4 secciones" ni "extenso" como criterio suelto; el callout es la única apertura de propósito y alcance; la nota de mantención lleva contenido definido (qué fila agregar y cuándo quitarla) o se omite. Reescribir la regla 7 (L21) y su "cuándo" (L163) según FR-013 y D8: bloque de 3-5 viñetas solo en el tipo resumen y en documentos bajo la 25, después del callout y antes de la sección 1; los demás entregables abren con la conclusión en prosa
- [ ] T026 [US4] En `.claude/skills/confluence-docs/SKILL.md` §3 paso 2 (L56-70): disparador según D5; el callout es la única apertura y el paso 4 (L76) remite a él cuando la 25 aplica; bloque de viñetas tras el callout (D8); nota de mantención con contenido definido u omitida (L66); en L70 incluir la doc-tecnica de un módulo o tema único entre lo que no recibe la estructura (FR-012)
- [ ] T027 [US4] En `.claude/skills/confluence-docs/templates.md` §2, agregar la nota del contrato 5: bajo la regla 25, la sección "Propósito y alcance" se materializa como el callout de apertura y la numeración decimal arranca en Descripción; registrar en §7 Correcciones la definición superada (sección 1 con encabezado propio bajo la 25), con fecha y motivo (D12)
- [ ] T028 [P] [US4] Escribir el insumo sintético `specs/003-concision-confluence-docs/evidence/input-bitacora-short.md` (hechos de una jornada, sin aprendizajes, con un pendiente), según el contrato 7
- [ ] T029 [US4] Invocar `confluence-docs` en modo generar con `input-doc-tecnica-small.md` (regenera `output-doc-tecnica-small.md`, que reemplaza la corrida de US1) y con `input-bitacora-short.md` (materializa `output-bitacora-short.md`), y verificar quickstart §8 sobre ambas: sin callout, tabla de metadatos ni índice en la doc-tecnica; grep genérico = 0 y línea marcada presente; sin bloque de viñetas en la bitácora y `Aprendizajes` omitida; R33 = 0 en ambas
- [ ] T030 [US4] Ejecutar los greps de quickstart §2 para FR-012 y FR-013 ('~4 secciones' = 0 en `SKILL.md` y `rules.md`; regla 7 con 'regla 25' = 1), registrar E4 en `specs/003-concision-confluence-docs/evidence/evidence.md`, y commitear con mensaje `feat: estructura documental proporcionada en confluence-docs`

**Checkpoint**: US1 a US4 entregables. Detenerse y reportar al dueño.

---

## Phase 7: User Story 5 — Ejemplos que enseñan solo concisión (Priority: P5)

**Goal**: cada ejemplo tiene exactamente las secciones de su plantilla, pasa el comando ampliado, no lleva anotaciones en el cuerpo y está enlazado desde el modo que lo usa; `seeded-violations.md` trae su lista enumerada.

**Independent Test**: auditar cada ejemplo conforme produce cero hallazgos; auditar `seeded-violations.md` produce exactamente la lista de su cabecera (quickstart §7). Encabezados según quickstart §5; comando según §3.

- [ ] T031 [P] [US5] Corregir `.claude/skills/confluence-docs/examples/compliant-adr.md` según los contratos 3 y 6: mover el callout de envoltorio (L3) a una cabecera HTML con los campos del contrato 3; quitar la sección "Próximos pasos" (L30-32); en Referencias quitar la cita a `templates.md` §3 y conservar `rules.md`; dueño como nombre sintético con fecha; quitar de Contexto (L11) la oración que anticipa la Decisión; correr el comando ampliado y citar su salida en la cabecera (R27 = 0, R33 = 0)
- [ ] T032 [P] [US5] Reescribir `.claude/skills/confluence-docs/examples/structured-doc.md` según los contratos 3, 5 y 6: cabecera HTML con la anotación del ejemplo; callout de propósito y alcance con declaración SSOT y delegación por enlace, sin índice en prosa ni fórmula de prohibición; bloque de 3-5 viñetas; tabla de metadatos; índice de las secciones 1 a 4 con subsecciones, sin comentario sobre la agrupación ni "Rutas de lectura"; tabla de trazabilidad inversa con nota de mantención definida; secciones `## 1. Descripción` (con la estructura de `rules.md` en 1.x), `## 2. Uso y ejemplos` (un párrafo por modo en 2.x), `## 3. Decisiones y supuestos` (derivar y no leer en vivo), `## 4. Referencias y pendientes` (unificada, sin el pendiente duplicado); "25 reglas accionables más 8 de prosa"; el hecho "es fuente única" a lo más dos veces; sin meta-comentario; correr el comando ampliado y citar su salida (R27 = 0, R33 = 0)
- [ ] T033 [US5] Auditar con la skill `.claude/skills/confluence-docs/examples/seeded-violations.md` sobre el estado posterior a US2-US4 y guardar el reporte sin editar en `specs/003-concision-confluence-docs/evidence/audit-seeded-violations.md` (reemplaza la corrida de US2), para que la lista de la cabecera nazca de una auditoría real (D15)
- [ ] T034 [US5] Reescribir la cabecera de `.claude/skills/confluence-docs/examples/seeded-violations.md` según el contrato 3: lista "Violaciones sembradas, con su regla" con una entrada por hallazgo del reporte de T033 (regla, ubicación, método), incluyendo como mínimo R1, R2, R16, R27, R33 (apertura, Comando), R10 (afirmaciones sin dato, Juicio) y R32 (cierre, Juicio); conservar la exención de emojis; fecha de contraste; salida literal del comando ampliado (R33 = 1 en la línea de la apertura). El cuerpo no cambia
- [ ] T035 [US5] En `.claude/skills/confluence-docs/SKILL.md`, enlazar desde §3 (L86) `examples/prose-conforming.md` como modelo de prosa densa, y desde §4 (L116) `examples/prose-conforming.md` y `examples/prose-with-seeded-flaws.md` como fixtures del modo auditar, junto a `seeded-violations.md` (FR-015)
- [ ] T036 [US5] Auditar con la skill `examples/compliant-adr.md`, `examples/structured-doc.md` y `examples/prose-conforming.md` guardando `specs/003-concision-confluence-docs/evidence/audit-compliant-adr.md`, `audit-structured-doc.md` y `audit-prose-conforming.md` (reemplaza la corrida de US2; esperado: `conforme`, cero hallazgos); verificar quickstart §3 (comando sobre los cinco fixtures y cabeceras que citan su salida), §5 (encabezados, hecho SSOT ≤ 2, sin "Próximos pasos", sin `templates.md` en el ADR) y §2 para FR-015 ('prose-conforming' y 'prose-with-seeded-flaws' ≥ 1 en `SKILL.md`); registrar E5 en `evidence/evidence.md` y commitear con mensaje `feat: ejemplos de confluence-docs que enseñan solo concisión`

**Checkpoint**: las cinco historias entregables. Detenerse y reportar al dueño.

---

## Phase 8: Polish y cierre

- [ ] T037 Declarar la revisión 003 en la nota de procedencia de `.claude/skills/confluence-docs/rules.md` (L3: fecha ISO y reglas cambiadas 5, 7, 10, 11, 25, 26, más la 33 agregada y el comando ampliado) y en la sección "Procedencia" de `.claude/skills/confluence-docs/templates.md` (fecha y secciones cambiadas: sección sin número nueva, §2, §3, §7, §8), según D16 y la regla 09
- [ ] T038 Ejecutar completo `specs/003-concision-confluence-docs/quickstart.md` (§1 a §10) sobre el estado final de `.claude/skills/confluence-docs/`: barrido corporativo, greps, comando sobre fixtures y archivos normativos (autodetección), encabezados, "Lo que se conserva" (`git diff main` sin cambios en las filas 27-32, 4, 13, 23, 3, 21 y 6), auditorías y generaciones persistidas, punteros; corregir toda desviación sin declarar cubierto lo que quede fuera de alcance
- [ ] T039 Completar `specs/003-concision-confluence-docs/evidence/evidence.md` con E6 (corrida completa del quickstart, fecha y resultado por bloque), actualizar la memoria de continuidad del proyecto con el estado del feature 003, commitear con mensaje `docs: evidencia de validación del feature 003`, y reportar el cierre al dueño dejando push, PR y merge a su confirmación explícita (SC-008)

---

## Dependencies

- **Setup → Foundational → US1 → US2 → US3 → US4 → US5 → Polish**, en ese orden (D17). Cada historia deja la skill coherente por sí sola y se detiene en su checkpoint.
- **US2 depende de US1**: la regla 10 ampliada cita la línea marcada que US1 define en `templates.md`.
- **US3 depende de US2**: re-clava los fixtures con el comando ampliado que US2 publica.
- **US4 es independiente de US2 y US3** en contenido, pero se ejecuta después para conservar el orden de prioridad y porque T029 regenera una salida de US1.
- **US5 depende de US2, US3 y US4**: cada ejemplo se verifica contra las reglas ya corregidas y el comando ampliado; la clave de `seeded-violations.md` nace de una auditoría con la 33 y la 10 vigentes.
- Dentro de una historia, las tareas sobre el mismo archivo son secuenciales; solo las marcadas `[P]` tocan archivos distintos sin dependencia pendiente.

## Parallel Execution Examples

- **US1**: T009 (insumos en `evidence/`) en paralelo con T004-T008 (edición de la skill).
- **US3**: T022 y T023 (los dos fixtures de prosa) en paralelo, después de T020.
- **US4**: T028 (insumo de bitácora) en paralelo con T025-T027.
- **US5**: T031 y T032 (los dos ejemplos conformes) en paralelo; T033-T034 (clave de `seeded-violations.md`) después de ellos o en paralelo, porque no comparten archivo.

## Implementation Strategy

- **MVP = US1**: cierra la presión de origen del relleno (secciones obligatorias sin salida al vacío) y es verificable con dos generaciones y cuatro greps. Entregable sola.
- **Incremental**: US2 agrega el detector (la skill ya puede fallar un documento relleno); US3 deja coherentes los fixtures; US4 quita el relleno estructural instruido; US5 alinea los ejemplos que generar imita. Cada una con su commit `feat:` y su evidencia.
- **Cierre**: procedencia declarada, quickstart completo, evidencia final y memoria; integración solo con confirmación del dueño.

## Notes

- Total: 39 tareas. Setup 2, Foundational 1, US1 8, US2 8, US3 5, US4 6, US5 6, Polish 3.
- Toda tarea que reescribe un fixture corre el comando ampliado sobre el archivo final y cita esa salida en la cabecera antes del commit (FR-016).
- Ninguna tarea toca `.claude/rules/`, los modos publicar y consultar de `SKILL.md`, `jira-management`, ni la línea base de prosa (`Pendiente de recomputar`).
- Las corridas con el modelo son evidencia de esa corrida, con fecha; no se presentan como prueba de determinismo (contrato 7).
