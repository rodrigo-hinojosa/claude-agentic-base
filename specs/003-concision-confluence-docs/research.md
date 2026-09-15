# Research: Concisión en confluence-docs

Fase 0 del plan. Consolida el diagnóstico del 13-09-2026, las cifras recomputadas el 15-09-2026 y las diecisiete decisiones de diseño (nueve del dueño, ocho del plan). Cierra con el mapa de cambios por archivo y línea que `/speckit-tasks` convierte en tareas.

## 1. Diagnóstico consolidado (13-09-2026)

Ocho lectores en paralelo, uno por archivo de la skill, con las reglas 00, 01 y 02 como vara, y una síntesis. Cada causa cita archivo y línea del estado actual de la rama `main` (`560225a`).

| # | Causa raíz | Evidencia (archivo y línea) |
| --- | --- | --- |
| C1 | Secciones obligatorias sin salida al vacío | `templates.md` L38 y L54 "Todas las secciones son obligatorias"; regla 11 (`rules.md` L25) "secciones obligatorias presentes"; regla 5 (L19) y `SKILL.md` L77 sin el "cuando corresponda" de la regla 02; `SKILL.md` L55 distingue omitibles pero no dice qué hacer con una obligatoria sin dato; solo bitácora, resumen y Referencias de ADR tienen "se omite, no se rellena" |
| C2 | La regla 10 prohíbe inventar hechos, no tapar con genérico | Regla 10 (L24) "faltantes = pregunta abierta"; `SKILL.md` L80 admite "supuesto explícito"; `templates.md` L45 "qué se está suponiendo" sin distinguir supuestos de la fuente de los del redactor; `compliant-adr.md` L7 dueño como rol genérico |
| C3 | Auditar es ciego al relleno | `rules.md` sin regla contra preámbulos ni muletillas (grep de "relleno", "genérico" vacío); solo las reglas 31 y 32 lo tocan y la 32 es media/Juicio, así que no bloquea (`SKILL.md` L114); el autochequeo de generar (L84) verifica solo el bloque de prioridad alta; `templates.md` §8 L122 limita auditar a "faltantes o fuera de orden" |
| C4 | Regla 26 con piso de dos oraciones | Regla 26 (L47); el comando publica "R26 parrafos de 1 oracion" como cifra a bajar (L84, L87); `prose-with-seeded-flaws.md` L10 siembra como defecto un dato completo en una oración |
| C5 | Estructura pesada y viñetas desproporcionadas | Disparador ">~4 secciones" (`SKILL.md` L56, `rules.md` L116) que toda doc-tecnica cumple porque §2 trae cinco; callout (L59) y sección 1 (L76, `templates.md` §2) duplican la apertura; nota de mantención (L66) sin contenido definido; regla 7 (L21, L163) fuerza 3-5 viñetas en "cualquier entregable de más de un párrafo" |
| C6 | Los ejemplos enseñan lo que las reglas no impiden | `compliant-adr.md` L30-32 "Próximos pasos" fuera de §3, L28 Referencias cita la propia plantilla, L11 anticipa la Decisión; `structured-doc.md` afirma cinco veces que `rules.md` es SSOT (L3, L9-10, L34, L38, L74), R27 en 3 de 24, meta-comentario en L3, L13, L30, L42, omite "Decisiones y supuestos" y parte "Referencias y pendientes"; fixtures de prosa con autodescripción (L12, L23) y sin enlace desde `SKILL.md`; `seeded-violations.md` L7 promete una lista de sembradas que no existe |

Lo que los lectores marcaron como ya alineado está en la spec, sección "Lo que se conserva", y no se reescribe. Discreparon en tres puntos: vacío marcado u omitido, quitar el piso de la 26 o ampliar su excepción, y regla 33 con comando o criterio de Juicio. Los tres los resolvió el dueño el 13-09-2026 (D1-D4).

## 2. Cifras verificadas

Comando de prosa vigente (`rules.md` L68-93), corrido el 15-09-2026 sobre la rama `main`. Salida literal del comando en la primera columna de cifras. La segunda columna excluye los párrafos de la cabecera HTML de cada fixture, que el comando vigente cuenta como prosa. Esa segunda base es la que usó la verificación del 13-09-2026 y la que la spec cita.

| Archivo | Métrica | Comando vigente | Sin cabecera HTML | Cabecera promete |
| --- | --- | --- | --- | --- |
| `prose-with-seeded-flaws.md` | R26 párrafos de 1 oración | 7 de 13 | 6 de 9 | 1 |
| `prose-with-seeded-flaws.md` | R26 párrafos de 5 o más | 1 de 13 | 1 de 9 | 0 |
| `prose-with-seeded-flaws.md` | R27, R28, R29 | 1 de 24; 2.6; 12.9 y 1 párrafo | igual | 1 por regla |
| `prose-conforming.md` | R26 párrafos de 1 oración | 1 de 8 | 1 de 6 | 0 |
| `prose-conforming.md` | R27, R28, R29 | 0; 0.0; 0.0 y 0 | igual | 0 |
| `structured-doc.md` | R27 oraciones de 30+ | 3 de 24 | sin cabecera HTML | no declara |
| `compliant-adr.md` | R26 párrafos de 1 oración | 2 de 6 | sin cabecera HTML | no declara |
| `seeded-violations.md` | R27 oraciones de 30+ | 1 de 17 | 1 de 13 | no declara |

Dos lecturas de esa tabla que entran al diseño:

- El párrafo de cinco o más oraciones de `prose-with-seeded-flaws.md` es el bloque "Desvios sembrados, con su regla" de la cabecera HTML, no prosa. Con la cabecera excluida, ningún fixture tiene hoy un párrafo de cinco o más: el desvío R26 nuevo hay que sembrarlo (D14).
- Un barrido con doce patrones candidatos de muletilla sobre la prosa de los ocho archivos, fuera de bloques de código y comentarios HTML, encontró exactamente dos coincidencias, ambas en `seeded-violations.md`: "Este documento explica" (L18) y "En resumen" (L33). Los archivos normativos de la skill están limpios hoy; la regla 33 no los detectará a sí mismos si su prosa no cambia (edge case "Autodetección").

## 3. Decisiones

Las D1 a D9 son del dueño y no se reabren; las D10 a D17 son del plan y se justifican aquí.

### D1. Vacío con línea marcada, nunca prosa (dueño, 13-09-2026)

- **Decisión**: una sección obligatoria sin dato real queda presente con una sola línea marcada; aplica al cierre.
- **Racional**: es lo que la regla 01 ya exige ("un vacío marcado es accionable"), es auditable por presencia, y `templates.md` §7 ya lo aplica sobre sí mismo ("Sin correcciones registradas a la fecha").
- **Alternativas**: omitir la sección (el auditor no distingue decisión de descuido); híbrido por tipo de sección (dos mecanismos donde uno basta).

### D2. Regla 33 (Comando) más regla 10 ampliada (Juicio) (dueño, 13-09-2026)

- **Decisión**: dos fenómenos con detectabilidad distinta reciben dos mecanismos. Muletillas de apertura y transición: regla 33, prosa, alta, Comando. Contenido válido para cualquier proyecto sin dato propio: criterio de Juicio dentro de la regla 10.
- **Racional**: las muletillas son enumerables y verificables por comando; el genérico no se detecta por regex y necesita lectura anclada a una regla que ya es alta.
- **Alternativas**: solo regla 33 (el genérico queda sin bloqueo); solo criterios de Juicio en 4 y 10 (la auditoría sigue sin detector verificable).

### D3. Regla 26 sin piso (dueño, 13-09-2026)

- **Decisión**: "un párrafo sostiene una idea y no pasa de cuatro oraciones; una idea no se fragmenta en párrafos de una oración". El comando conserva la métrica de cinco o más y quita la de una.
- **Racional**: el piso es la única instrucción del catálogo que produce relleno de forma directa y contradice la regla 00 ("una idea por frase, sin relleno"); la fragmentación queda cubierta por la frase nueva y por la regla 31.
- **Alternativas**: ampliar la excepción a "dato de cierre" (conserva el incentivo); rellenar los fixtures con segundas oraciones (instruye lo contrario del objetivo).

### D4. El relleno bloquea cuando lo detecta la 33 o la 10 (dueño, 13-09-2026)

- **Decisión**: 33 nace alta; 10 sigue alta; 32 sigue media/Juicio y no bloquea sola.
- **Racional**: conserva el principio de `rules.md` L57 (los hallazgos de Juicio no pesan igual que los de comando) y aun así da a auditar capacidad de fallar un documento relleno.
- **Alternativas**: subir la 32 a alta (un remate detectado por juicio invalidaría un documento entero); veredicto intermedio "conforme con observaciones" (tercer estado que §4 no tiene).

### D5. Disparador de la regla 25 por naturaleza declarada (dueño, 14-09-2026)

- **Decisión**: la regla 25 se activa si el entregable es plan, manual, spec larga, página SSOT de dominio o autoridad de datos que otros consumen, o si el usuario lo pide. Se retiran el conteo de secciones y "extenso" como criterio suelto.
- **Racional**: un umbral por forma reproduce el fallo original (la plantilla lo cumple sola); la naturaleza del entregable es lo que justifica índice, metadatos y trazabilidad.
- **Alternativas**: umbral cuantitativo distinto (mismo riesgo, otra cifra); solo a petición (una página SSOT quedaría sin estructura si nadie la pide).

### D6. El comando cuenta solo la lista cerrada; la repetición del encabezado es Juicio (dueño, 14-09-2026)

- **Decisión**: la regla 33 es Comando para su lista cerrada, que vive en el bloque de código del comando. La primera oración que solo reformula el encabezado, sin frase de la lista, es hallazgo de la 33 marcado Juicio. La autodescripción del comando (`rules.md` L66) se reformula: mide estructura y una lista declarada, y no se detecta a sí mismo porque la lista está dentro del bloque que excluye.
- **Racional**: una heurística de solapamiento con el encabezado produce falsos positivos y una calibración más que mantener; la lista corta más el juicio cubren el caso sin ruido.
- **Alternativas**: heurística de palabras compartidas en el comando; mover la repetición del encabezado a la regla 31 (que hoy habla del párrafo anterior, no del título).

### D7. Evidencia de generación persistida en `evidence/` (dueño, 14-09-2026)

- **Decisión**: una corrida por caso; insumo sintético y salida generada se guardan bajo `specs/003-concision-confluence-docs/evidence/`; `quickstart.md` cita las cifras de grep y del comando sobre esa salida.
- **Racional**: la cifra se puede rehacer (Principio II); no contamina `examples/`, que es el set de enseñanza de la skill.
- **Alternativas**: solo cita en quickstart (cifra sin origen); fixtures nuevos en `examples/` (fuera de alcance y cada uno exigiría su conformidad).

### D8. Bloque de viñetas después del callout, antes de la sección 1 (dueño, 14-09-2026)

- **Decisión**: bajo la regla 25, el callout declara propósito y alcance; el bloque de 3-5 viñetas va inmediatamente después, sin encabezado propio, con conclusiones orientadas a decisión y sin repetir el propósito.
- **Racional**: dos piezas con dos funciones, sin duplicar; el callout de una página SSOT se mantiene corto.
- **Alternativas**: viñetas dentro del callout (mezcla alcance con conclusiones); sin viñetas bajo la 25 (un documento largo pierde el resumen ejecutivo que la regla 00 exige primero).

### D9. Línea marcada: tres formas canónicas al generar, familia de la regla 01 al auditar (dueño, 14-09-2026)

- **Decisión**: el generador emite `Sin información registrada`, `Pendiente: <qué falta>` o `Sin pendientes`. El auditor acepta además `Pendiente` y `Por completar`, con o sin detalle tras dos puntos o "de" (`Pendiente de configurar`).
- **Racional**: converge hacia la vara (regla 01) y no falla documentos de este mismo repositorio que ya usan `Pendiente de configurar`.
- **Alternativas**: lista cerrada de tres (diverge de la regla 01 y marcaría como hallazgo marcas legítimas).

### D10. El comando excluye los comentarios HTML, conservando los números de línea (plan)

- **Decisión**: el comando ampliado reemplaza bloques de código y comentarios HTML por el mismo número de saltos de línea antes de medir. Así la cabecera de un fixture no cuenta como prosa y las ubicaciones que publica la regla 33 corresponden al archivo original.
- **Racional**: la cabecera es la clave de respuestas, no prosa (contrato 3). Sin esta exclusión, "cero hallazgos" en `prose-conforming.md` no es alcanzable por comando (§2: 1 de 8 viene de contar la cabecera como párrafo), y la lista de sembradas de `seeded-violations.md`, que cita las muletillas por su nombre, haría que el fixture se detectara a sí mismo por la cabecera.
- **Alternativas**: dejar el comando como está y descontar a mano (la cifra deja de ser recomputable); mover las cabeceras fuera del archivo (rompe el patrón de fixture autocontenido que el diagnóstico conserva).

### D11. Contenido de la lista cerrada: apertura y transición, sin cierres ni genérico (plan)

- **Decisión**: la lista cubre autodescripción del documento o de la sección y transiciones de anuncio; doce patrones, en [contracts/prose-command.md](contracts/prose-command.md). No incluye remates de cierre ("en resumen", "en conclusión"), que son la regla 32, ni frases de genérico ("buenas prácticas", "se recomienda"), que son la regla 10.
- **Racional**: cada frase de la lista debe pertenecer a una sola regla, o el auditor reportaría dos hallazgos por una oración. La lista corta evita que el detector grite siempre (edge case "Coincidencia legítima").
- **Alternativas**: lista amplia con conectores ("por otro lado", "asimismo"): falsos positivos en contrastes legítimos.

### D12. Bajo la regla 25, el callout materializa la sección 1 y la numeración arranca en Descripción (plan)

- **Decisión**: en un documento que activa la regla 25, la sección "Propósito y alcance" de `templates.md` §2 se materializa como el callout de apertura, antes de cualquier encabezado. Las secciones numeradas empiezan en `1. Descripción`. La tabla de trazabilidad inversa va en el bloque de apertura, después del índice, como la regla 25 ya lo prescribe para la pieza que abre el documento. `templates.md` §2 lo declara en una nota y §7 registra la definición superada.
- **Racional**: es la única forma de que el callout sea la única apertura (D8) sin que la sección 1 quede vacía o repetida, y de que `structured-doc.md` tenga exactamente las secciones de su plantilla (FR-014) sin una sección "Trazabilidad inversa" fuera de §2.
- **Alternativas**: conservar el encabezado "1. Propósito y alcance" con el callout como su contenido (contradice "callout antes de cualquier encabezado" de la regla 25); trazabilidad dentro de "Referencias y pendientes" (semántica invertida: son consumidores, no fuentes).

### D13. La línea marcada se define una vez, en `templates.md` (plan)

- **Decisión**: `templates.md` gana una sección sin número, "Secciones obligatorias y vacíos", antes de §1, que define qué significa obligatoria y el conjunto de líneas marcadas (D9). Las reglas 5, 10 y 11 de `rules.md` y el paso 4 del modo generar de `SKILL.md` la citan por nombre; ninguno reproduce la lista.
- **Racional**: Principio II. Una sección sin número no desplaza los punteros `§2`-`§8` que `SKILL.md`, la regla 02 y los ejemplos usan.
- **Alternativas**: definirla en `rules.md` (la estructura es autoridad de `templates.md`, según su propia tabla "Qué define y qué no").

### D14. Los fixtures de prosa conservan el alcance 26-32; `seeded-violations.md` es el oráculo de la 33 y la 10 (plan)

- **Decisión**: `prose-conforming.md` y `prose-with-seeded-flaws.md` siguen cubriendo las reglas 26 a 32 y ambos reportan cero muletillas. El desvío R26 nuevo del sembrado es un párrafo de cinco oraciones, cada una con un dato distinto para no activar la 31; la oración suelta "El cache se limpia los domingos." se funde en el párrafo de Contexto. Los sembrados de relleno (33 por la apertura, 10 por las afirmaciones sin dato, 32 por el cierre) viven en `seeded-violations.md`, que ya los contiene y solo necesita etiquetarlos.
- **Racional**: la spec fija el alcance de los fixtures de prosa en 26-32 (Out of Scope) y exige que el conforme reporte cero en la 33 (US2 escenario 2); agregar un sembrado 33 al fixture de prosa sería alcance adicional sin causa raíz propia.
- **Alternativas**: sembrar una muletilla en `prose-with-seeded-flaws.md` (duplica el oráculo que `seeded-violations.md` ya da).

### D15. La clave de `seeded-violations.md` se clava con una corrida de auditoría persistida (plan)

- **Decisión**: la lista enumerada de la cabecera nace de una auditoría real del archivo durante implement, guardada en `evidence/audit-seeded-violations.md` con fecha. Las entradas que la spec exige (33, 10, 32, más 1, 2, 16 y 27 ya sembradas) son obligatorias; las demás que la auditoría produzca (por ejemplo 4, 5, 7, 9) se listan tal como salieron, con su método (Comando o Juicio).
- **Racional**: "auditar produce exactamente esa lista" (US5 escenario 4) solo es verificable si la lista se escribió a partir de una auditoría y no al revés; el método por entrada deja claro qué parte es determinista.
- **Alternativas**: listar solo las siete obligatorias (la primera auditoría completa contradiría la cabecera).

### D16. Procedencia declarada: revisión 003 en `rules.md` y `templates.md` (plan)

- **Decisión**: la nota de procedencia de cada archivo (`rules.md` L3, `templates.md` §Procedencia) gana una frase: revisado el DD-09-2026 por la feature 003, con la lista de reglas o secciones que cambiaron. Desde ese momento el archivo diverge del estándar de origen.
- **Racional**: regla 09: una réplica declarada que se edita deja de ser réplica y debe decirlo, con fecha.
- **Alternativas**: dejar la nota como está (réplica encubierta de un origen que ya no coincide).

### D17. Orden de implementación y corrección por borrado (plan)

- **Decisión**: se implementa en el orden de prioridad de la spec (US1 a US5), porque la 10 ampliada usa la línea marcada (US1), la 26 nueva re-clava los fixtures que la 33 usa como oráculo (US3 tras US2) y los ejemplos se re-verifican contra las reglas ya corregidas (US5 al final). En los ejemplos, la corrección es por borrado: se quitan secciones, repeticiones y anotaciones; no se agrega prosa nueva salvo la línea marcada o el dato que una sección obligatoria exija.
- **Racional**: cada historia deja la skill coherente por sí sola; el borrado es el cambio mínimo que la spec exige.
- **Alternativas**: reescribir los ejemplos de cero (más riesgo de introducir relleno nuevo y de perder lo que "keep" conserva).

## 4. Mapa de cambios por archivo

Línea citada sobre el estado de `main` (`560225a`). "Cambio" describe el resultado, no el texto final.

| # | Archivo | Ubicación | Cambio | US / FR |
| --- | --- | --- | --- | --- |
| 1 | `templates.md` | antes de §1 | Sección nueva sin número "Secciones obligatorias y vacíos": obligatoria = presente y no llena; tres formas canónicas al generar; familia aceptada al auditar | US1 / FR-001, D9, D13 |
| 2 | `templates.md` | L38, L54 | "Todas las secciones son obligatorias" pasa a citar la sección nueva ("presentes, no llenas; vacío con línea marcada") | US1 / FR-001 |
| 3 | `templates.md` | L45 (§2 fila 4) | "qué se está suponiendo" distingue supuestos que trae la fuente de los que introduciría el redactor; solo los primeros entran | US1 / FR-004 |
| 4 | `templates.md` | §7 Correcciones | Entradas con la definición previa y el motivo: obligatoria = llena; sección 1 con encabezado bajo la regla 25 | US1, US4 / D12, D16 |
| 5 | `templates.md` | §2 nota nueva | Bajo la regla 25, la sección 1 se materializa como callout y la numeración arranca en Descripción; bloque de apertura según contrato 5 | US4 / FR-012, D12 |
| 6 | `templates.md` | L122 (§8 auditar) | Auditar detecta faltantes, fuera de orden y relleno: sección obligatoria con prosa genérica en vez de línea marcada es hallazgo de la 10 | US2 / FR-009 |
| 7 | `templates.md` | §Procedencia | Frase de revisión 003 con fecha y secciones cambiadas | D16 |
| 8 | `rules.md` | L19 (regla 5) | "cuando corresponda; si no hay ninguno, la sección queda con la línea marcada de cierre" | US1 / FR-002 |
| 9 | `rules.md` | L25 (regla 11) | "secciones obligatorias presentes, con línea marcada si no hay dato real (templates.md, Secciones obligatorias y vacíos)" | US1 / FR-002 |
| 10 | `rules.md` | L24 (regla 10) | "faltantes = línea marcada o pregunta abierta"; criterio de Juicio: afirmación válida para cualquier proyecto sin dato propio es relleno y se sustituye por la línea marcada | US2 / FR-006 |
| 11 | `rules.md` | L41 | Encabezado "Reglas de prosa (26-33)" | US2 / FR-005 |
| 12 | `rules.md` | tabla de prosa, fila nueva | Regla 33: la primera oración de una sección entra en materia, sin muletilla de apertura ni de transición (lista cerrada en el comando) y sin repetir el encabezado; prosa; alta; Comando | US2 / FR-005 |
| 13 | `rules.md` | L47 (regla 26) | "Un párrafo sostiene una idea y no pasa de cuatro oraciones. Una idea no se fragmenta en párrafos de una oración" | US3 / FR-010 |
| 14 | `rules.md` | L57 | "Las reglas 30 a 32 no tienen comando" se mantiene; se agrega que la parte de encabezado de la 33 se marca Juicio | US2 / D6 |
| 15 | `rules.md` | L59 | "Dos excepciones" pasa a: la 28 exime la negrita larga que define un término; la 33 exime la frase de la lista que introduce un bloque de código o una tabla; la 26 ya no necesita excepción | US2, US3 / D6 |
| 16 | `rules.md` | L61-64 (criterios de Juicio) | Bullet nuevo "33 — repetición del encabezado" | US2 / D6 |
| 17 | `rules.md` | L66 | Autodescripción reformulada: mide estructura y una lista cerrada declarada; excluye bloques de código y comentarios HTML; no se detecta a sí mismo porque la lista vive en el bloque que excluye | US2 / FR-007, D6, D10 |
| 18 | `rules.md` | L68-93 (comando) | Comando ampliado según contrato 1: exclusión de comentarios HTML con líneas conservadas, sin métrica n1, con conteo y ubicación de muletillas | US2, US3 / FR-007, D10, D11 |
| 19 | `rules.md` | L98 (línea base) | Frase: la 33 no lleva línea base; cada coincidencia es hallazgo salvo la excepción de contexto | US2 |
| 20 | `rules.md` | L21 (regla 7) y L163 | Bloque de 3-5 viñetas solo en tipo resumen y documentos bajo la regla 25 (tras el callout, antes de la sección 1); los demás abren con la conclusión en prosa | US4 / FR-013, D8 |
| 21 | `rules.md` | L39 (regla 25) y L116 | Disparador por naturaleza declarada o petición; sin "más de ~4 secciones"; el callout es la única apertura; nota de mantención con contenido definido o se omite | US4 / FR-012, D5 |
| 22 | `rules.md` | L3 | Frase de revisión 003 con fecha y reglas cambiadas (5, 7, 10, 11, 25, 26, 33) | D16 |
| 23 | `SKILL.md` | L56 | Disparador de la regla 25 según D5; sin "más de ~4 secciones" | US4 / FR-012 |
| 24 | `SKILL.md` | L59 y L76 | Callout = única apertura de propósito y alcance; el paso 4 remite a él cuando la regla 25 aplica | US4 / FR-012 |
| 25 | `SKILL.md` | L66 | Nota de mantención con contenido definido (qué fila agregar y cuándo quitarla) o se omite | US4 / FR-012 |
| 26 | `SKILL.md` | L70 | "No apliques esta estructura a" incluye la doc-tecnica de un módulo o tema único | US4 / FR-012 |
| 27 | `SKILL.md` | L80 | Sin "supuesto explícito": línea marcada o pregunta abierta; inferencia solo a pedido y rotulada `propuesta no validada`; genérico sin dato es relleno (regla 10) | US1 / FR-003 |
| 28 | `SKILL.md` | L82 | "párrafo de una idea y hasta cuatro oraciones"; "sin muletilla de apertura ni de transición"; rango 26-33 | US2, US3 / FR-008 |
| 29 | `SKILL.md` | L84 (paso 6) | Autochequeo: bloque de prioridad alta más reglas 26 a 33; si el documento se materializa en disco, correr el comando y citar sus cifras | US2 / FR-008 |
| 30 | `SKILL.md` | L86 | Enlace a `prose-conforming.md` como modelo de prosa densa | US5 / FR-015 |
| 31 | `SKILL.md` | L95-100 (§4 pasos 2-3) | Hallazgos de relleno: 33 (comando sobre archivo en disco; lista de `rules.md` sobre texto pegado) y 10 ampliada; marca "(Juicio)" también para la parte de encabezado de la 33 | US2 / FR-009 |
| 32 | `SKILL.md` | L116 | Enlaces a `prose-conforming.md` y `prose-with-seeded-flaws.md` como fixtures del modo auditar | US5 / FR-015 |
| 33 | `examples/*` | cinco archivos | Según contratos 3 y 6: `compliant-adr.md` sin "Próximos pasos", Referencias sin la plantilla, dueño sintético, L11 sin anticipo; `structured-doc.md` bajo contrato 5 y 6; fixtures de prosa sin autodescripción y con cabecera re-clavada; `seeded-violations.md` con lista enumerada | US3, US5 / FR-011, FR-014, FR-015, D14, D15 |
| 34 | `evidence/` | directorio nuevo | Insumos, salidas, reportes de auditoría e índice `evidence.md`, según contrato 7 | FR-017 / D7 |

## 5. Riesgos

- **Autodetección**: si al redactar la regla 33 o el criterio de Juicio se cita una frase de la lista en prosa, `rules.md` falla su propio comando (SC-007). Mitigación: describir la lista por su función y remitir al bloque de código; el quickstart corre el comando sobre los tres archivos.
- **Re-clavado de fixtures**: cambiar el comando cambia las cifras de las cabeceras. Mitigación: el orden de tareas corre el comando ampliado sobre cada fixture y escribe la cabecera con esa salida, con fecha, antes del commit.
- **Reescritura de `structured-doc.md`**: riesgo de introducir relleno nuevo. Mitigación: contrato 5 y 6 fijan estructura y contenido mínimo; el comando y la auditoría lo verifican con R27 igual a cero y cero hallazgos.
- **Auditorías con el modelo**: los hallazgos de Juicio pueden variar entre corridas. Mitigación: la clave lista el método por entrada (D15) y la evidencia se declara como una corrida fechada.
