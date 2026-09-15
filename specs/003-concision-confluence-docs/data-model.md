# Data Model: Concisión en confluence-docs

Los "datos" de esta feature son las entidades del estándar de documentación que la skill aplica: reglas, plantillas, la línea marcada, el comando de medición, los fixtures que sirven de oráculo y lo que produce una auditoría. La autoridad de cada una vive en un archivo de la skill; aquí se describen para diseño y verificación, remitiendo sin replicar. Las interfaces exactas están en [contracts/](contracts/).

## Regla

Fila del catálogo `rules.md` (autoridad).

| Campo | Definición | Validación |
| --- | --- | --- |
| `número` | Identificador estable; los punteros de `SKILL.md`, `templates.md` y los ejemplos lo usan | Nunca se renumera; una regla nueva toma el siguiente número al final (33) |
| `texto` | Qué exige, en una o dos frases | Sin citar literalmente frases de la lista cerrada de la 33 (edge case "Autodetección") |
| `categoría` | Grupo de la tabla "Reglas por categoría" | La 33 es `prosa` |
| `prioridad` | `alta`, `media` o `baja`; en auditar es la severidad del hallazgo | La 33 nace `alta`; la 10 sigue `alta`; la 32 sigue `media` |
| `método` | Solo en reglas de prosa: `Comando` o `Juicio` | La 33 es `Comando` para su lista cerrada, con un criterio de Juicio declarado para la repetición del encabezado; la 26 sigue `Comando` |
| `cuándo` | Condición de activación, en "Reglas por categoría" | La 7 se acota al tipo resumen y a documentos bajo la 25; la 25 se activa por naturaleza declarada o petición |

**Transiciones en esta feature**: se reescriben la 5, 7, 10, 11, 25 y 26; se agrega la 33; el resto conserva su texto (verificable con `git diff main` sobre las filas 27-32, 4, 13, 23, 3, 21 y 6).

## Plantilla

Sección de `templates.md` por tipo de entregable (autoridad de estructura).

| Campo | Definición | Validación |
| --- | --- | --- |
| `tipo` | `doc-tecnica`, `adr`, `bitacora`, `resumen`; `sdd` y `ticket` se remiten | Sin cambios de índice: §1 a §8 conservan su número |
| `secciones` | Nombre, orden y si es obligatoria u omitible | `doc-tecnica` y `adr`: todas obligatorias; `bitacora` y `resumen`: con omitibles marcadas "se omite, no se rellena" |
| `semántica de obligatoria` | Presente, no llena: sin dato real, lleva la línea marcada | Definida una vez en la sección sin número "Secciones obligatorias y vacíos" |
| `nota bajo regla 25` | Solo `doc-tecnica`: la sección 1 se materializa como callout; la numeración arranca en Descripción | Contrato 5 |
| `correcciones` (§7) | Definición previa, motivo de superación, fecha | Una entrada por definición superada en esta feature |

## Línea marcada

La única salida admitida para una sección obligatoria sin dato real del proyecto. Definida en `templates.md`, sección "Secciones obligatorias y vacíos" (autoridad); `rules.md` (reglas 5, 10, 11) y `SKILL.md` (§3 paso 4) la citan.

| Forma | Quién la emite | Quién la acepta |
| --- | --- | --- |
| `Sin información registrada` | Generador (canónica) | Auditor |
| `Pendiente: <qué falta>` | Generador (canónica) | Auditor |
| `Sin pendientes` | Generador (canónica, solo cierre) | Auditor |
| `Pendiente`, `Pendiente de <qué>`, `Por completar`, `Por completar: <qué>` | Nadie en esta skill; provienen de la regla 01 y de documentos existentes | Auditor |

**Invariantes**: ocupa una sola línea; es la única línea de la sección; una sección con línea marcada más prosa es prosa (hallazgo de la regla 10 si es genérica). No convierte un no-ADR en ADR: sin alternativas reales, el tipo es otro (`templates.md` §3).

## Comando de prosa

Script Python embebido en `rules.md` (autoridad). Interfaz completa en [contracts/prose-command.md](contracts/prose-command.md).

| Campo | Definición | Cambio en esta feature |
| --- | --- | --- |
| `entrada` | Ruta de un archivo Markdown | Sin cambio |
| `exclusiones` | Bloques de código; comentarios HTML | Comentarios HTML se agregan (D10); ambas exclusiones conservan el conteo de líneas |
| `filtro estructural` | Encabezados, tablas, citas, listas y numeraciones no son párrafos | Sin cambio |
| `métricas` | R26 párrafos de 5 o más; R27 oraciones de 30+; R28 negrita larga; R29 guiones e incisos; R33 muletillas | Se quita "R26 párrafos de 1 oración"; se agrega R33 con ubicación por línea |
| `lista cerrada` | Doce patrones de apertura y transición, dentro del bloque de código | Nueva; vive solo ahí |
| `autodescripción` | Párrafo de `rules.md` L66 | Reformulada: mide estructura y una lista declarada |

**Invariante**: la prosa de `rules.md`, `SKILL.md` y `templates.md` reporta cero muletillas con este comando (SC-007).

## Fixture

Archivo de `examples/`. Su cabecera HTML es la clave de respuestas; su cuerpo, el material. Interfaz de cabecera en [contracts/interfaces.md](contracts/interfaces.md), contrato 3.

| Fixture | Clase | Alcance de reglas | Promesa de la cabecera |
| --- | --- | --- | --- |
| `prose-conforming.md` | Conforme | 26-32 (y 33 en cero) | Cero hallazgos reales; cifras del comando citadas con fecha |
| `prose-with-seeded-flaws.md` | Sembrado | 26-32 | Exactamente un desvío por regla, con ubicación; el de R26 es un párrafo de 5+ oraciones |
| `compliant-adr.md` | Conforme | Todas las aplicables a `adr` | Cero hallazgos; encabezados = `templates.md` §3 |
| `structured-doc.md` | Conforme, bajo regla 25 | Todas las aplicables a `doc-tecnica` extensa | Cero hallazgos; R27 = 0; bloque de apertura según contrato 5; encabezados = §2 según contrato 6 |
| `seeded-violations.md` | Sembrado | Transversales (tipo no reconocido) | Lista enumerada de violaciones con regla y método; la auditoría produce exactamente esa lista |

**Relación**: `SKILL.md` §3 enlaza los conformes que generar imita; §4 enlaza los cinco como material del modo auditar (FR-015).

## Hallazgo

Fila del reporte del modo auditar (`SKILL.md` §4, autoridad del formato).

| Campo | Definición | Validación |
| --- | --- | --- |
| `regla` | Número y nombre corto; sufijo "(Juicio)" cuando el método lo exige | Sufijo obligatorio en 30, 31, 32 y en la parte de encabezado de la 33 |
| `ubicación` | Sección, línea o cita textual | Para la 33 por comando: la línea que el comando publica |
| `severidad` | Prioridad de la regla; la 16 siempre alta | 33 y 10: alta |
| `corrección sugerida` | Concreta y accionable | Para la 10 ampliada: "sustituir por la línea marcada `<forma>`"; para la 33: "eliminar la frase y abrir con el dato" |

## Veredicto

`conforme` o `no-conforme`. Lo bloquea cualquier hallazgo de severidad alta. Consecuencia de D4: un preámbulo detectado por la 33 o una sección genérica detectada por la 10 bloquean; un remate de cierre (32, media, Juicio) no bloquea solo.

## Evidencia de generación

Artefactos de `specs/003-concision-confluence-docs/evidence/` (FR-017). Interfaz en contrato 7.

| Campo | Definición | Validación |
| --- | --- | --- |
| `insumo` | Texto sintético con el que se invoca generar o auditar | Sin identificadores reales; declara qué datos trae y cuáles no |
| `salida` | Lo que la skill produjo, sin editar | Es sobre lo que corren los greps y el comando |
| `fecha y modo` | Cuándo se corrió y en qué modo | En `evidence.md`, índice de la corrida |
| `cifras` | Salida del grep y del comando sobre `salida` | Citadas en `quickstart.md` con su origen |
