# Contratos de interfaz — Concisión en confluence-docs

Seis contratos que la implementación respeta y el quickstart verifica. El contrato 1 (comando de prosa) está en [prose-command.md](prose-command.md). Cada contrato nombra el archivo que es su autoridad en la skill; este documento diseña, no reemplaza.

## Contrato 2 — Línea marcada

**Autoridad**: `templates.md`, sección sin número "Secciones obligatorias y vacíos", ubicada después de "Procedencia" y antes de `## 1. Índice de tipos` (D13). `rules.md` (reglas 5, 10, 11) y `SKILL.md` (§3 paso 4) la citan por ese nombre; ninguno reproduce las formas.

La sección declara, como mínimo:

1. **Obligatoria significa presente, no llena.** Una sección obligatoria sin dato real del proyecto queda con una sola línea marcada, nunca con prosa.
2. **Formas canónicas que emite el generador**: `Sin información registrada` (no hay dato), `Pendiente: <qué falta>` (el dato existe y no está en la fuente), `Sin pendientes` (solo en el cierre).
3. **Familia que acepta el auditor**: las tres canónicas más las marcas de la regla 01, `Pendiente` y `Por completar`, con o sin detalle tras dos puntos o "de" (por ejemplo `Pendiente de configurar`).
4. **Invariantes**: una sola línea; es el único contenido de la sección; línea marcada más prosa se audita como prosa. Si el usuario pide inferir lo que falta, el resultado se rotula `propuesta no validada` y no sustituye a la línea marcada.
5. **Qué no hace**: no convierte un no-ADR en ADR (§3, "si no hubo alternativas reales, no es un ADR"); en bitácora y resumen, las secciones omitibles se omiten, no se marcan.

**Verificación**: `grep -c 'Secciones obligatorias y vacíos' templates.md rules.md SKILL.md` devuelve al menos 1 en cada archivo. `grep -c 'Sin información registrada' rules.md SKILL.md` devuelve 0: citan, no reproducen.

## Contrato 3 — Cabecera de fixture (clave de respuestas)

**Autoridad**: cada archivo de `examples/`. La cabecera es un comentario HTML al inicio del archivo; el comando la excluye (contrato 1, D10), así que puede nombrar frases de la lista cerrada. El cuerpo no lleva anotaciones sobre el propio ejemplo: lo que hoy está en callouts de envoltorio (`compliant-adr.md` L3, `structured-doc.md` L3) pasa a la cabecera.

Campos, en este orden:

| Campo | Obligatorio | Contenido |
| --- | --- | --- |
| Propósito y modo | Sí | Qué prueba y qué modo lo usa (`SKILL.md` §3 o §4) |
| Clase | Sí | `Conforme` o `Sembrado` |
| Alcance de reglas | Sí | Qué reglas cubre (por ejemplo "26 a 32; 33 en cero") |
| Desvíos o violaciones sembradas | Solo sembrado | Lista "con su regla": una entrada por desvío con regla, ubicación (sección o cita corta) y método (`Comando` o `Juicio`) |
| Naturaleza del fixture | Sí | "Es un fixture, no una transcripción: no tiene cifras de un día que caduquen" y qué es lo que sí caduca |
| Fecha de contraste | Sí | `Contrastado contra rules.md el YYYY-MM-DD` (la de esta feature) |
| Salida del comando | Sí | Las líneas literales del comando ampliado sobre el archivo, con la fecha de la corrida |
| Exención declarada | Solo si aplica | Qué patrón se exime y por qué (hoy: emojis en `seeded-violations.md`) |

**Reglas de la cabecera**:

- Para `prose-with-seeded-flaws.md`, la lista tiene exactamente siete entradas (R26 a R32); el desvío R26 es un párrafo de cinco o más oraciones y el comando lo publica una sola vez.
- Para `seeded-violations.md`, la lista nace de una auditoría persistida (D15) e incluye como mínimo: R1 (inglés en prosa), R2 (emoji en el título), R16 (secreto sintético), R27 (oración del roadmap), R33 (apertura "Este documento explica", Comando), R10 (afirmaciones sin dato del segundo párrafo, Juicio), R32 (cierre "En resumen", Juicio). Las demás entradas que la auditoría produzca se listan tal como salieron.
- Para los conformes, la cabecera declara "cero hallazgos" y cita la salida del comando que lo respalda.

## Contrato 4 — Hallazgo y veredicto en auditar

**Autoridad**: `SKILL.md` §4. El formato del reporte no cambia; cambia qué hallazgos existen y cómo se ubican.

| Caso | Regla en el reporte | Ubicación | Severidad | Corrección sugerida |
| --- | --- | --- | --- | --- |
| Muletilla de la lista | `33` | Línea que publica el comando (archivo en disco) o cita textual (texto pegado, aplicando la lista de `rules.md` por lectura) | alta | "Eliminar la frase y abrir con el dato" |
| Primera oración que repite el encabezado sin frase de la lista | `33 (Juicio)` | Sección y cita | alta | "Sustituir por el primer dato de la sección" |
| Afirmación válida para cualquier proyecto, sin dato propio | `10 (Juicio)` | Sección y cita | alta | "Sustituir por la línea marcada `<forma>`" o "citar el dato del proyecto" |
| Sección obligatoria rellena con prosa genérica | `10 (Juicio)` y, si además falta la marca, `11` | Sección | alta | "Dejar solo la línea marcada" |
| Remate de cierre | `32 (Juicio)` | Última oración de la sección | media | Sin cambio |

**Veredicto**: sin cambio de regla (`SKILL.md` L114): un hallazgo de severidad alta impide `conforme`. Consecuencia verificable: `seeded-violations.md` es `no-conforme` por la 33 y la 10 aunque se eximieran las demás; `prose-conforming.md`, `compliant-adr.md` y `structured-doc.md` producen cero hallazgos.

**Excepción de contexto**: una frase de la lista que introduce un bloque de código o una tabla no es hallazgo. El auditor la exime al juzgar, no al contar. Si decide reportarla como eximida, lo declara en la fila.

## Contrato 5 — Bloque de apertura bajo la regla 25 (doc-tecnica)

**Autoridad**: `rules.md` regla 25 y `SKILL.md` §3 paso 2, más la nota nueva de `templates.md` §2 (D12). Aplica solo cuando la regla 25 se activa (D5). Orden fijo:

| # | Pieza | Contenido | Prohibido |
| --- | --- | --- | --- |
| 1 | Callout `>` | Propósito y alcance en una o dos frases. Si es autoridad de un dato: `**Fuente única (SSOT)** de <tema>: <alcance>`, delegando por enlace los subtemas ajenos | Índice en prosa; fórmulas de prohibición; anotaciones sobre el ejemplo; repetir el hecho SSOT más adelante |
| 2 | Bloque de 3-5 viñetas | Conclusiones orientadas a decisión, sin encabezado propio (D8) | Repetir el propósito del callout; reformular el índice |
| 3 | Tabla `Campo \| Valor` | Metadatos del documento; fecha en ISO 8601 | Filas que repitan el callout salvo "Autoridad de" |
| 4 | Índice | Jerárquico, numeración decimal; bloques nombrados solo con muchas entradas | Comentario sobre por qué no se agrupa; "Rutas de lectura" |
| 5 | Trazabilidad inversa (si otros la consumen) | `Artefacto \| Qué dato consume o rol \| Tipo de enlace (Consumo / Navegación)`; nota de mantención con contenido definido: qué fila agregar y cuándo quitarla | Frase de cortesía; oración que repita una fila |
| 6 | Secciones numeradas | `## 1. Descripción`, `## 2. Uso y ejemplos`, `## 3. Decisiones y supuestos`, `## 4. Referencias y pendientes`; subsecciones `### N.M` | Un `## Propósito y alcance` (ya es el callout); secciones fuera de `templates.md` §2 |

La sección "Propósito y alcance" de `templates.md` §2 se materializa como la pieza 1; por eso la numeración empieza en Descripción. `templates.md` §2 lo declara en una nota y §7 registra la definición superada.

## Contrato 6 — Encabezados de los ejemplos

Verificable con `grep '^## '` sobre cada archivo. Los títulos `#` quedan libres.

| Archivo | Encabezados `##` esperados, en orden | Notas |
| --- | --- | --- |
| `compliant-adr.md` | `Estado`, `Contexto`, `Decisión`, `Alternativas consideradas`, `Consecuencias`, `Referencias` | Sin `Próximos pasos`. `Referencias` presente porque hay una fuente real (`rules.md`); no cita `templates.md` §3. `Estado` con dueño como nombre sintético y fecha. L11 sin la oración que anticipa la Decisión |
| `structured-doc.md` | `1. Descripción`, `2. Uso y ejemplos`, `3. Decisiones y supuestos`, `4. Referencias y pendientes` | Bloque de apertura según contrato 5. El hecho "es fuente única" aparece a lo más dos veces (callout y fila de metadatos). "Decisiones y supuestos" con la decisión de derivar y no leer en vivo; "Referencias y pendientes" unifica lo que hoy son "Próximos pasos" y "Referencias", sin el pendiente duplicado. Un párrafo por modo en 2.x, sin apertura ni remate |
| `prose-conforming.md`, `prose-with-seeded-flaws.md` | Sin cambio de encabezados | El cuerpo abre en `## Contexto` directamente bajo el título: se elimina la línea de autodescripción (L12 y L23) |
| `seeded-violations.md` | Sin cambio | Solo cambia la cabecera (contrato 3) |

**Corrección por borrado** (D17): en los ejemplos no se agrega prosa nueva salvo la línea marcada, el dato que una sección obligatoria exija, o las oraciones del desvío R26 sembrado.

## Contrato 7 — Evidencia de generación y auditoría

**Autoridad**: `specs/003-concision-confluence-docs/evidence/` (FR-017, D7, D15). Nombres en inglés por coherencia con `evidence.md` del feature 002.

```text
evidence/
├── evidence.md                     # Índice: por corrida, fecha, modo, insumo, salida, cifras y veredicto
├── input-doc-tecnica-small.md      # Insumo: módulo pequeño, sin decisiones ni pendientes (SC-001, SC-004)
├── output-doc-tecnica-small.md     # Salida de generar, sin editar
├── input-adr-no-cons.md            # Insumo: decisión con alternativas reales, sin contras ni referencias (SC-001)
├── output-adr-no-cons.md           # Salida de generar, sin editar
├── input-bitacora-short.md         # Insumo: hechos de una jornada, tres párrafos (SC-004)
├── output-bitacora-short.md        # Salida de generar, sin editar
├── audit-seeded-violations.md      # Reporte de auditar (SC-002; clave de la cabecera, D15)
├── audit-prose-conforming.md       # Reporte de auditar (SC-002)
├── audit-compliant-adr.md          # Reporte de auditar (US5)
└── audit-structured-doc.md         # Reporte de auditar (US5)
```

**Reglas**:

- Cada insumo declara al inicio qué datos trae y cuáles no (por ejemplo "no hay decisiones registradas"), con nombres inventados y sin identificadores reales.
- La salida se guarda tal como la produjo la skill; los greps y el comando corren sobre ese archivo y `quickstart.md` cita el resultado con su origen.
- Una corrida por caso. `evidence.md` lo declara así: es evidencia de esa corrida, no prueba de determinismo.
- Resultados esperados por salida: `output-doc-tecnica-small.md` sin callout, tabla de metadatos ni índice; "Decisiones y supuestos" con `Sin información registrada`; "Referencias y pendientes" con `Sin pendientes` o la referencia real; grep genérico igual a cero. `output-adr-no-cons.md` con contras como `Pendiente: la fuente no registra contras` y sin `Referencias`. `output-bitacora-short.md` sin bloque de viñetas, con `Aprendizajes` omitida si el insumo no trae ninguno.
