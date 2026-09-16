# Feature Specification: Concisión en confluence-docs

**Feature Branch**: `003-concision-confluence-docs`

**Created**: 2026-09-14

**Status**: Draft

**Input**: User description: "Refinar la skill confluence-docs para que genere documentación concreta, concisa y directa, sin relleno ni contenido genérico, y para que el modo auditar sea capaz de fallar un documento relleno."

## Contexto

`confluence-docs` es la skill transversal de documentación de la base (portada en el feature 001). Hoy genera relleno y su modo auditar no lo detecta. El diagnóstico del 13-09-2026 usó ocho lectores, uno por archivo de la skill, con las reglas 00, 01 y 02 como vara, y una síntesis consolidada. Atribuye el relleno a tres presiones que ningún archivo desactiva, dos pisos que lo instruyen directo y una estructura desproporcionada:

| Causa | Evidencia |
| --- | --- |
| Secciones obligatorias sin salida al vacío | `templates.md` L38 y L54: "Todas las secciones son obligatorias"; regla 5 y `SKILL.md` L77 perdieron el "cuando corresponda" de la regla 02; solo bitácora y resumen tienen "se omite, no se rellena" |
| La regla 10 prohíbe inventar hechos, no tapar con genérico | "Se recomienda seguir buenas prácticas" no es un hecho falso; `SKILL.md` L80 admite "supuesto explícito" |
| Auditar es ciego al relleno | Sin regla contra preámbulos ni muletillas; solo las reglas 31 y 32 lo tocan, y la 32 es media/Juicio: un documento relleno sale `conforme`. El autochequeo de generar (L84) omite las reglas de prosa |
| Regla 26 exige mínimo dos oraciones por párrafo | El comando publica "párrafos de 1 oración" como cifra a bajar; `prose-with-seeded-flaws.md` siembra como defecto un dato completo en una oración |
| Regla 7 fuerza 3-5 viñetas en todo entregable de más de un párrafo | `rules.md` L21 y L163 |
| Regla 25 se dispara en toda doc-tecnica | Umbral ">~4 secciones" (`SKILL.md` L56) y la plantilla trae cinco; el callout duplica la sección 1 |
| Los ejemplos enseñan lo que las reglas no impiden | `compliant-adr.md` agrega "Próximos pasos" fuera de plantilla; `structured-doc.md` afirma cinco veces el mismo hecho e incumple R27 en 3 de 24 oraciones; los fixtures de prosa no están enlazados desde `SKILL.md`; `seeded-violations.md` promete una lista de sembradas que no existe |

Cifras verificadas con el comando de prosa de `rules.md` el 13-09-2026:

- `prose-with-seeded-flaws.md`: R26 dispara en 6 de 9 párrafos; su cabecera promete 1.
- `prose-conforming.md`: R26 dispara en 1 de 6; su cabecera promete cero.
- `structured-doc.md`: R27 dispara en 3 de 24 oraciones.

## Clarifications

### Session 2026-09-13

Cuatro decisiones de diseño tomadas por el dueño en ronda interactiva antes de la spec, sobre los puntos donde los lectores discreparon:

- Q: ¿Qué hace el generador con una sección obligatoria sin dato real? → A: Queda presente con una sola línea marcada (`Sin información registrada`, `Pendiente: <qué falta>`, `Sin pendientes`), nunca prosa. Aplica igual al cierre.
- Q: ¿Con qué mecanismo se detecta relleno de apertura y contenido genérico? → A: Regla 33 nueva (prosa, alta, Comando, lista cerrada de muletillas) más la regla 10 ampliada con criterio de Juicio para contenido genérico sin dato propio.
- Q: ¿Qué se hace con el piso de la regla 26? → A: Se quita. Un párrafo sostiene una idea y no pasa de cuatro oraciones; una idea no se fragmenta en párrafos de una oración.
- Q: ¿Puede el relleno bloquear el veredicto `conforme`? → A: Sí cuando lo detecta la regla 33 (comando) o la 10 ampliada (genérico); la 32 sigue media/Juicio y no bloquea sola.

### Session 2026-09-14

- Q: Retirado el conteo de secciones, ¿cuál es el disparador de la regla 25? → A: La naturaleza declarada del entregable (plan, manual, spec larga, página SSOT de dominio, autoridad de datos que otros consumen) o la petición del usuario. Se retiran el conteo y "extenso" como criterio suelto; una doc-tecnica de un módulo nunca lo activa.
- Q: ¿Qué parte de la regla 33 mide el comando y qué queda a Juicio? → A: El comando cuenta solo la lista cerrada. La primera oración que repite el encabezado sin frase de la lista es criterio de Juicio declarado en la misma regla. La autodescripción del comando ("mide estructura, no términos literales") se reformula.
- Q: ¿Cómo se evidencian las pruebas de generación no deterministas (SC-001, SC-004)? → A: Una corrida por caso, con insumo sintético y salida persistidos en `specs/003-concision-confluence-docs/evidence/`; `quickstart.md` cita las cifras.
- Q: En un documento bajo la regla 25, ¿dónde va el bloque de viñetas de la regla 7? → A: Inmediatamente después del callout y antes de la sección 1, sin encabezado propio y sin repetir el propósito.
- Q: ¿Qué conjunto de líneas marcadas acepta el auditor? → A: El generador emite las tres formas canónicas; el auditor acepta además las marcas de la regla 01 (`Pendiente`, `Por completar`), con o sin detalle tras dos puntos o "de".

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Vacíos con línea marcada (Priority: P1)

Como dueño de la base, quiero que toda sección obligatoria sin dato real del proyecto quede presente con una sola línea marcada, nunca con prosa genérica. Aplica también al cierre. El vacío queda visible y accionable en vez de disimulado.

**Why this priority**: Es la causa más frecuente de relleno y la de daño más silencioso: una sección completada con genérico parece información. Cerrar la presión en su origen hace innecesaria buena parte de la detección posterior.

**Independent Test**: Generar una doc-tecnica y un ADR desde un insumo sintético sin decisiones ni pendientes. El resultado conserva cada sección obligatoria con una línea marcada y ninguna frase genérica.

**Acceptance Scenarios**:

1. **Given** un insumo sin decisiones ni supuestos, **When** se genera una doc-tecnica, **Then** la sección "Decisiones y supuestos" existe y contiene solo `Sin información registrada`, y "Referencias y pendientes" contiene solo `Sin pendientes` si no hay ninguno.
2. **Given** `templates.md`, **When** se lee la definición de doc-tecnica y ADR, **Then** declara que "obligatoria" significa presente y no llena, y remite a la línea marcada como única salida al vacío; el patrón "se omite, no se rellena" de bitácora y resumen se conserva sin cambios.
3. **Given** `rules.md`, **When** se leen las reglas 5 y 11, **Then** la 5 dice "cuando corresponda" y la 11 nombra la línea marcada para una sección obligatoria sin contenido.
4. **Given** `SKILL.md`, **When** se lee el modo generar, **Then** no admite completar un vacío con "supuesto explícito"; si el usuario pide inferir, el resultado se rotula `propuesta no validada`.
5. **Given** `templates.md` §2 "Decisiones y supuestos", **When** se lee, **Then** distingue los supuestos que trae la fuente de los que introduciría el redactor, y solo admite los primeros.
6. **Given** un ADR sin alternativas reales, **When** se genera, **Then** la skill declara que no es un ADR y ofrece el tipo más cercano; la línea marcada no convierte un no-ADR en ADR.

---

### User Story 2 - Detector de relleno (Priority: P2)

Como dueño de la base, quiero que la skill detecte relleno de apertura y contenido genérico con un mecanismo nombrado y verificable. Lo comprueba antes de entregar, y un documento relleno no puede salir `conforme` de una auditoría.

**Why this priority**: Sin detector, la concisión depende de la buena voluntad del redactor y nadie puede fallar un documento relleno. Depende de US1 solo en que la regla 10 ampliada usa la línea marcada como salida.

**Independent Test**: Auditar `examples/seeded-violations.md` produce hallazgos de severidad alta por el preámbulo de apertura y por las afirmaciones sin dato, con veredicto `no-conforme`. Auditar `examples/prose-conforming.md` no produce ninguno de los dos.

**Acceptance Scenarios**:

1. **Given** `rules.md`, **When** se lee el catálogo de prosa, **Then** existe una regla 33 de prioridad alta y método Comando, con su lista cerrada de muletillas de apertura y transición declarada dentro del bloque de código del comando. El comando cuenta solo esa lista; la primera oración que repite el encabezado sin frase de la lista es criterio de Juicio declarado en la misma regla.
2. **Given** el comando de prosa ampliado, **When** se corre sobre `examples/seeded-violations.md`, **Then** reporta al menos una muletilla (la apertura "Este documento explica"); sobre `examples/prose-conforming.md` reporta cero.
3. **Given** la regla 10, **When** se lee, **Then** incluye un criterio de Juicio: una afirmación válida para cualquier proyecto, sin dato propio del documentado, es relleno y se sustituye por la línea marcada.
4. **Given** un documento con preámbulo de apertura y afirmaciones genéricas, **When** se audita, **Then** el reporte trae un hallazgo por la regla 33 y otro por la regla 10, ambos de severidad alta, y el veredicto es `no-conforme` aunque no haya otro hallazgo alto.
5. **Given** `SKILL.md`, **When** se lee el autochequeo del modo generar, **Then** nombra las reglas 26 a 33 y no solo el bloque de prioridad alta; cuando el documento se materializa en disco, corre el comando y cita sus cifras.
6. **Given** `templates.md` §8, **When** se lee la fila del modo auditar, **Then** dice que auditar detecta relleno además de secciones faltantes o fuera de orden.
7. **Given** la regla 32, **When** se lee, **Then** sigue con prioridad media y método Juicio: un remate de cierre solo no bloquea el veredicto.

---

### User Story 3 - Regla 26 sin piso (Priority: P3)

Como dueño de la base, quiero que un hecho que cabe en una oración no exija una segunda. Los fixtures de prosa deben ser coherentes con su clave de respuestas, para que la skill no instruya relleno ni calibre el auditor con datos falsos.

**Why this priority**: Es la única instrucción del catálogo que produce relleno de forma directa. Va después del detector porque su corrección re-clava los fixtures que el detector usa como oráculo.

**Independent Test**: Correr el comando de prosa sobre ambos fixtures. `prose-conforming.md` devuelve cero en toda métrica que su cabecera declara; `prose-with-seeded-flaws.md` devuelve exactamente un disparo por regla listada, sin disparos extra.

**Acceptance Scenarios**:

1. **Given** `rules.md`, **When** se lee la regla 26, **Then** dice que un párrafo sostiene una idea y no pasa de cuatro oraciones, y que una idea no se fragmenta en párrafos de una oración; no fija mínimo.
2. **Given** el comando de prosa, **When** se corre, **Then** no publica "párrafos de 1 oración" como cifra a bajar y conserva "párrafos de 5 o más".
3. **Given** `examples/prose-with-seeded-flaws.md`, **When** se lee su cabecera, **Then** el desvío sembrado de R26 es un párrafo de cinco o más oraciones, y el comando lo marca una sola vez.
4. **Given** ambos fixtures, **When** se leen sus cabeceras, **Then** citan la fecha de contraste de esta feature y las cifras que el comando produjo.

---

### User Story 4 - Estructura proporcionada (Priority: P4)

Como dueño de la base, quiero que la estructura documental pesada (callout, tabla de metadatos, índice, trazabilidad) se aplique solo a documentos que la justifican, con una sola apertura. El bloque de viñetas del resumen ejecutivo no se impone a cualquier entregable.

**Why this priority**: Es relleno estructural instruido, no fallo del redactor. Es independiente de las historias anteriores.

**Independent Test**: Generar una doc-tecnica de un módulo pequeño: la salida abre en la sección 1 con una o dos frases, sin callout, metadatos ni índice. Generar una bitácora de tres párrafos: sin bloque de viñetas.

**Acceptance Scenarios**:

1. **Given** `SKILL.md`, **When** se lee el disparador de la regla 25, **Then** es la naturaleza declarada del entregable (plan, manual, spec larga, página SSOT de dominio, autoridad de datos que otros consumen) o la petición del usuario. No hay conteo de secciones ni "extenso" como criterio suelto; una doc-tecnica de un módulo con sus cinco secciones no lo activa.
2. **Given** un documento que sí activa la regla 25, **When** se genera, **Then** el callout es la única apertura de propósito y alcance, y la sección 1 no la repite. El bloque de viñetas de la regla 7 va inmediatamente después del callout y antes de la sección 1, sin encabezado propio y sin repetir el propósito.
3. **Given** la tabla de trazabilidad inversa, **When** se genera, **Then** su nota de mantención lleva contenido definido (qué fila agregar y cuándo quitarla) o se omite; nunca una frase de cortesía.
4. **Given** `rules.md`, **When** se lee la regla 7, **Then** el bloque de viñetas aplica al tipo resumen y a documentos bajo la regla 25; los demás entregables abren con la conclusión en prosa sin bloque de viñetas obligatorio.

---

### User Story 5 - Ejemplos que enseñan solo concisión (Priority: P5)

Como dueño de la base, quiero que cada ejemplo de la skill tenga exactamente las secciones de su plantilla y pase el comando de prosa. Cada uno debe estar enlazado desde el modo que lo usa. Así el generador imita concisión y el auditor tiene un oráculo completo.

**Why this priority**: Los ejemplos son lo que generar imita. Va al final porque cada ejemplo se re-verifica contra las reglas ya corregidas.

**Independent Test**: Auditar cada ejemplo conforme produce cero hallazgos; auditar `seeded-violations.md` produce exactamente la lista enumerada en su cabecera.

**Acceptance Scenarios**:

1. **Given** `examples/compliant-adr.md`, **When** se listan sus encabezados, **Then** coinciden con las secciones de `templates.md` §3, sin "Próximos pasos"; "Referencias" no cita la propia plantilla; el dueño es un nombre sintético y no un rol.
2. **Given** `examples/structured-doc.md`, **When** se listan sus encabezados, **Then** coinciden con `templates.md` §2, con "Decisiones y supuestos" presente y "Referencias y pendientes" unificada; el hecho "es fuente única" aparece a lo más dos veces; el comando reporta R27 igual a cero y cero muletillas; el cuerpo no contiene anotaciones sobre el propio ejemplo.
3. **Given** `examples/prose-conforming.md` y `examples/prose-with-seeded-flaws.md`, **When** se leen, **Then** el cuerpo no abre con una autodescripción del documento (la cabecera HTML ya la trae), y `SKILL.md` los enlaza desde §3 y §4.
4. **Given** `examples/seeded-violations.md`, **When** se lee su cabecera, **Then** contiene la lista enumerada de violaciones sembradas con su regla, incluidas las de relleno (33 por la apertura, 10 por las afirmaciones sin dato, 32 por el cierre "En resumen"), y auditar el archivo produce exactamente esa lista.

---

### Edge Cases

- **Autodetección**: la lista de muletillas vive dentro del bloque de código del comando, que el propio comando excluye al medir; la prosa de `rules.md` y `SKILL.md` no las cita literalmente. Si lo hiciera, la skill fallaría su propia auditoría.
- **Coincidencia legítima**: una frase de la lista puede ser apropiada en un contexto (una transición antes de un bloque de código). La regla 33 publica la cifra; el auditor aplica la excepción al juzgar cada hallazgo, no al contarlo, igual que las reglas 26 y 28. La lista se mantiene corta a propósito: un detector que grita siempre se ignora.
- **ADR sin alternativas reales**: la línea marcada no lo convierte en ADR; sigue rigiendo `templates.md` §3 ("si no hubo alternativas reales, no es un ADR").
- **Vacío total**: un insumo sin ningún dato produce el esqueleto con todas sus líneas marcadas y una declaración de insuficiencia; la skill no fabrica un documento para cumplir la plantilla.
- **Fragmentación tras quitar el piso**: una idea partida en párrafos de una oración la caza la regla 31 (reformulación) o la frase "no se fragmenta" de la nueva 26; el comando conserva la métrica de párrafos largos.
- **Los propios archivos de la skill bajo la regla 33**: `rules.md`, `SKILL.md` y `templates.md` deben pasar el comando ampliado o declarar su exención con motivo escrito, como hoy hace `seeded-violations.md` con los emojis.
- **Línea base de prosa**: quitar la métrica de párrafos de una oración cambia lo que el comando publica; la línea base sigue `Pendiente de recomputar` y se recomputa después de integrar esta feature, no dentro.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `templates.md` MUST declarar, para doc-tecnica y ADR, que una sección obligatoria significa presente y no llena, y que una sección sin dato real del proyecto queda con una sola línea marcada (`Sin información registrada`, `Pendiente: <qué falta>`, `Sin pendientes`); el patrón "se omite, no se rellena" de bitácora y resumen se conserva. El auditor acepta como línea marcada, además, las marcas de la regla 01 (`Pendiente`, `Por completar`), con o sin detalle tras dos puntos o "de".
- **FR-002**: La regla 5 de `rules.md` MUST recuperar la condición "cuando corresponda" de la regla 02, y la regla 11 MUST nombrar la línea marcada como única salida para una sección obligatoria sin contenido.
- **FR-003**: `SKILL.md` MUST dejar de admitir "supuesto explícito" como forma de completar un vacío; la inferencia solo ocurre si el usuario la pide y se rotula `propuesta no validada`.
- **FR-004**: `templates.md` §2 MUST distinguir los supuestos que trae la fuente de los que introduciría el redactor; solo los primeros entran a "Decisiones y supuestos".
- **FR-005**: `rules.md` MUST incorporar una regla 33 de prosa, prioridad alta, método Comando, con lista cerrada de muletillas de apertura y transición declarada dentro del bloque de código del comando. El comando cuenta solo esa lista; la primera oración que repite el encabezado sin frase de la lista es criterio de Juicio declarado en la misma regla. La regla se agrega al final del catálogo sin renumerar.
- **FR-006**: La regla 10 MUST ampliarse con un criterio de Juicio: una afirmación válida para cualquier proyecto, sin dato propio del documentado, es relleno y se sustituye por la línea marcada.
- **FR-007**: El comando de prosa de `rules.md` MUST reportar el conteo de la lista cerrada de la regla 33 y MUST dejar de publicar "párrafos de 1 oración"; conserva las demás métricas. Su autodescripción ("mide estructura, no términos literales") MUST reformularse: mide estructura y una lista cerrada declarada, y no se detecta a sí mismo porque la lista vive en el bloque de código que excluye.
- **FR-008**: El autochequeo del modo generar en `SKILL.md` MUST aplicar las reglas 26 a 33 antes de entregar, no solo el bloque de prioridad alta; cuando el documento se materializa en disco, MUST correr el comando y citar sus cifras.
- **FR-009**: El modo auditar MUST producir hallazgos por las reglas 33 y 10 ampliada, ambas de severidad alta; `templates.md` §8 MUST reflejar que auditar detecta relleno. La regla 32 conserva prioridad media y método Juicio.
- **FR-010**: La regla 26 MUST redactarse sin piso: un párrafo sostiene una idea y no pasa de cuatro oraciones; una idea no se fragmenta en párrafos de una oración.
- **FR-011**: `examples/prose-conforming.md` y `examples/prose-with-seeded-flaws.md` MUST quedar coherentes con su cabecera bajo la regla 26 nueva: el conforme con cero hallazgos reales, el sembrado con exactamente un disparo por regla listada; ambas cabeceras citan la fecha de contraste y las cifras del comando.
- **FR-012**: El disparador de la regla 25 en `SKILL.md` MUST ser la naturaleza declarada del entregable (plan, manual, spec larga, página SSOT de dominio, autoridad de datos que otros consumen) o la petición del usuario. Se retiran el conteo de secciones y "extenso" como criterio suelto; una doc-tecnica de un módulo con sus cinco secciones no lo activa. Cuando la regla aplica, el callout es la única apertura y la nota de mantención lleva contenido definido o se omite.
- **FR-013**: La regla 7 MUST acotar el bloque de 3-5 viñetas al tipo resumen y a documentos bajo la regla 25; los demás entregables cumplen "conclusión primero" en prosa. Bajo la regla 25, el bloque va inmediatamente después del callout y antes de la sección 1, sin encabezado propio y sin repetir el propósito.
- **FR-014**: `examples/compliant-adr.md` y `examples/structured-doc.md` MUST tener exactamente las secciones de su plantilla, pasar el comando de prosa con R27 igual a cero y cero muletillas, y no contener anotaciones sobre el propio ejemplo en el cuerpo; `structured-doc.md` MUST afirmar "es fuente única" a lo más dos veces.
- **FR-015**: Los fixtures de prosa MUST perder la autodescripción del cuerpo y MUST quedar enlazados desde `SKILL.md` §3 y §4; `examples/seeded-violations.md` MUST traer la lista enumerada de violaciones sembradas con su regla, incluidas las de relleno.
- **FR-016**: Ningún archivo tocado MUST contener referencias corporativas; cada fixture MUST pasar su propio comando antes del commit; los cambios MUST ser mínimos y locales, sin reescribir lo que la sección "Lo que se conserva" enumera.
- **FR-017**: Las pruebas de generación (SC-001 y SC-004) MUST persistir el insumo sintético y la salida generada bajo `specs/003-concision-confluence-docs/evidence/`, una corrida por caso; `quickstart.md` cita las cifras de grep y del comando sobre esa salida.

### Key Entities

- **Regla**: entrada del catálogo `rules.md` con número, categoría, prioridad y método (Comando o Juicio). La 33 es nueva (Comando para su lista cerrada, con un criterio de Juicio declarado para la repetición del encabezado); la 5, 7, 10, 11 y 26 cambian de redacción; el resto no se toca.
- **Plantilla**: definición de secciones por tipo en `templates.md`. Cambia la semántica de "obligatoria" (presente, no llena) y el ámbito de la regla 25.
- **Línea marcada**: la única salida admitida para una sección obligatoria sin dato real. El generador emite una de tres formas canónicas: `Sin información registrada`, `Pendiente: <qué falta>` o `Sin pendientes`. El auditor acepta además las marcas de la regla 01 (`Pendiente`, `Por completar`), con o sin detalle tras dos puntos o "de", como `Pendiente de configurar`. Auditable por presencia.
- **Comando de prosa**: script de `rules.md` que mide estructura; gana el conteo de su lista cerrada de muletillas y pierde la métrica de párrafos de una oración.
- **Fixture**: ejemplo de `examples/`, conforme (cero hallazgos) o sembrado (lista de desvíos en su cabecera, cada uno con su regla). Su cabecera es la clave de respuestas.
- **Veredicto**: `conforme` o `no-conforme`. Lo bloquea cualquier hallazgo de severidad alta; las reglas 33 y 10 ampliada son altas.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Generar una doc-tecnica y un ADR desde un insumo sintético sin decisiones ni pendientes produce cero frases genéricas (`grep -ciE 'buenas prácticas|se recomienda|se asume|es importante'` igual a cero sobre la salida) y cada sección obligatoria presente con su línea marcada. Insumo y salida quedan en `specs/003-concision-confluence-docs/evidence/` (FR-017).
- **SC-002**: Auditar `examples/seeded-violations.md` produce hallazgos de severidad alta por las reglas 33 y 10 y veredicto `no-conforme`; auditar `examples/prose-conforming.md` produce cero hallazgos.
- **SC-003**: El comando de prosa sobre `examples/prose-with-seeded-flaws.md` reporta exactamente un disparo por regla listada en su cabecera; sobre `examples/prose-conforming.md`, cero en toda métrica declarada.
- **SC-004**: Generar una doc-tecnica de un módulo pequeño produce una salida sin callout, tabla de metadatos ni índice; generar una bitácora de tres párrafos produce una salida sin bloque de viñetas. Insumo y salida quedan en `evidence/` (FR-017).
- **SC-005**: Los encabezados de `examples/compliant-adr.md` y `examples/structured-doc.md` coinciden uno a uno con las secciones de su plantilla; el comando reporta R27 igual a cero y cero muletillas en ambos.
- **SC-006**: `grep -c 'prose-conforming\|prose-with-seeded-flaws' SKILL.md` devuelve al menos dos; `grep -c 'supuesto explícito' SKILL.md` y `grep -c '~4 secciones' SKILL.md` devuelven cero.
- **SC-007**: `rules.md`, `SKILL.md` y `templates.md` pasan el comando ampliado con cero muletillas o declaran su exención con motivo escrito.
- **SC-008**: Barrido corporativo en cero sobre los archivos tocados; el feature queda trazado en `specs/003-concision-confluence-docs/` y en la rama del mismo nombre, sin commits directos a `main`.

## Lo que se conserva

Sin cambios, para que la implementación no lo reescriba:

- Reglas 27, 28, 29, 30, 31 y 32 tal como están; reglas 4, 13, 23, 3, 21 y 6.
- El comando de prosa como mecanismo blindado, que excluye los bloques de código al medir; su autodescripción cambia según FR-007.
- "Un umbral se cumple moviendo texto sin escribir mejor" y el límite declarado del conteo de incisos.
- El patrón "se omite, no se rellena" de bitácora y resumen.
- "Delega, no prohíbas" y "no exijas rutas de lectura".
- "Un documento conforme produce 0 hallazgos" y la corrección "concreta y accionable, nunca vaga".
- La cabecera HTML de los fixtures, con fecha de contraste y exención declarada.
- Los modos publicar y consultar, íntegros.

## Assumptions

- Las cuatro decisiones de diseño (sección Clarifications) las tomó el dueño el 13-09-2026 sobre las recomendaciones presentadas; no se reabren.
- El diagnóstico del 13-09-2026 (ocho lectores más síntesis, con citas por línea) es el insumo del mapa de cambios y se consolida en `research.md` de esta feature en la fase plan.
- Las reglas 00, 01 y 02 de `.claude/rules/` son la vara; la skill converge hacia ellas y no al revés.
- Los fixtures son sintéticos; sus cifras no caducan porque no describen un día real.
- La regla 33 se agrega al final para no romper los punteros por número que `SKILL.md` y los ejemplos usan.

## Out of Scope

- Modificar las reglas 00, 01 y 02 del repositorio o su réplica global.
- Los modos publicar y consultar de `confluence-docs`, y la integración con Confluence en vivo.
- El tipo ticket y la skill `jira-management`.
- Automatizar el comando de prosa (hook, CI, pre-commit): la ejecución sigue manual y declarada.
- Recomputar la línea base de prosa: se hace después de integrar, no dentro.
- Renumerar o reordenar el catálogo de reglas.
- Crear un contraejemplo nuevo de ADR con relleno: `seeded-violations.md` ya cubre los tres patrones.
- Corregir referencias temporales relativas o falta de fuente en cifras de los fixtures de prosa: no son relleno y su alcance declarado es 26-32.
