---
name: confluence-docs
description: Aplica el estándar de documentación personal sobre Confluence en vivo y sobre archivos del repo, en cuatro modos — genera un entregable conforme, audita uno existente contra el estándar, consulta qué reglas y plantilla aplican a un tipo, y publica (crea o actualiza) páginas del espacio configurado con gate de aprobación. Úsala para producir o validar doc técnica, ADR, bitácoras, resúmenes o artefactos SDD. El tipo ticket pertenece a la skill jira-management.
argument-hint: [genera|audita|consulta|publica] + tipo de entregable + insumo (tema, URL o id de página, ruta de archivo o texto)
allowed-tools: Read, Grep, Glob, Write, Edit, mcp__atlassian__getAccessibleAtlassianResources, mcp__atlassian__getConfluencePage, mcp__atlassian__getConfluencePageDescendants, mcp__atlassian__getConfluenceSpaces, mcp__atlassian__searchConfluenceUsingCql, mcp__atlassian__createConfluencePage, mcp__atlassian__updateConfluencePage
---

Solicitud:

$ARGUMENTS

Lee primero [`rules.md`](rules.md) (catálogo operativo, fuente única del estándar; no leas `.claude/rules/` ni la constitución en vivo).

## Parámetros por proyecto

| Parámetro | Valor | Cómo resolverlo |
|-----------|-------|-----------------|
| Sitio y `cloudId` de Atlassian | Se resuelve en runtime, no se persiste | `getAccessibleAtlassianResources` al inicio de la operación en vivo |
| Espacio de Confluence del proyecto | Pendiente de configurar | `getConfluenceSpaces` y confirmación del usuario; registrar la elección en la configuración del proyecto derivado, no en esta plantilla |

Contexto de acceso: Confluence en vivo se alcanza por el servidor MCP `atlassian` (OAuth por sesión). Si una operación en vivo falla por conector sin autorizar, permisos o error de herramienta, **detente y declara la falta de acceso** (la autorización se hace con `/mcp` en Claude Code). Ofrece operar sobre archivo o texto pegado como alternativa que el usuario elige; nunca infieras el contenido que no pudiste leer ni degrades en silencio.

## 1. Determinar el modo

Interpreta la solicitud para identificar **modo** (generar | auditar | consultar | publicar) y **tipo de entregable** (doc-tecnica | adr | bitacora | resumen | sdd).

- "genera/redacta/escribe un ADR/doc/..." → **generar**.
- "audita/revisa/valida esta página/archivo/texto contra el estándar" → **auditar**.
- "qué reglas/plantilla aplican a..." → **consultar**.
- "publica/crea/actualiza esta página en Confluence" → **publicar**.

Si el modo o el tipo no se infieren con confianza del texto, **no asumas**: presenta 2-4 opciones mutuamente excluyentes con tu recomendación marcada (regla 24).

Si se solicita un entregable de tipo **ticket**, declara que ese tipo pertenece a la skill `jira-management`, autoridad sobre el tablero del proyecto. Remite a ella; no produzcas el ticket aquí.

Si el tipo de entregable no está en el alcance (doc-tecnica, adr, bitacora, resumen, sdd), decláralo fuera de alcance. Ofrece el tipo más cercano en vez de forzar una plantilla ajena.

## 2. Tabla de tipos — plantilla que rige y frontera

| Tipo | Plantilla que rige | Qué lo distingue |
|------|--------------------|------------------|
| doc-tecnica | [`templates.md`](templates.md) §2 | Describe algo que existe y que otros van a usar |
| adr | [`templates.md`](templates.md) §3 | Registra una elección entre alternativas reales, con consecuencias |
| bitacora | [`templates.md`](templates.md) §4 | Registro fechado de trabajo hecho, para consultar después |
| resumen | [`templates.md`](templates.md) §5 | Orientado a que alguien decida, no a que entienda un sistema |
| sdd | `.specify/templates/` | Artefacto del flujo SDD; lo genera el motor spec-kit |
| ~~ticket~~ | `jira-management` | **Fuera de alcance de esta skill**: remitir a `jira-management`. |

**Las plantillas viven en el repositorio.** `confluence-docs` aplica la estructura que define [`templates.md`](templates.md) y le suma el estándar transversal de [`rules.md`](rules.md) —idioma, SSOT, cita de fuente, cierre—. Son dos capas complementarias: una dice qué secciones lleva el entregable, la otra qué exigencias caen sobre él.

Esta skill **no depende de ningún artefacto externo al repositorio** para producir. Si existe un comando como `/documentar` o `/decision` en la configuración de quien trabaja, es un atajo opcional. Su ausencia no impide generar nada y su presencia no cambia el resultado.

## 3. Modo GENERAR

1. Selecciona el tipo (tabla §2) y **lee su plantilla en [`templates.md`](templates.md)**: secciones, orden y cuáles son omitibles.
2. **Evalúa la extensión y estructura (regla 25)**: si el entregable es un documento extenso o multi-tema (plan, manual, spec larga, página SSOT de dominio, más de ~4 secciones de nivel superior, o autoridad de datos que otros consumirán), aplica la estructura documental al redactar.

   Siempre, en toda pieza extensa:
   - Callout de apertura como primer elemento, antes de cualquier encabezado. Si es autoridad de un dato: `> **Fuente única (SSOT)** de <tema>: <alcance>`.
   - **Delega, no prohíbas**: nombra el subtema cuya autoridad vive en otra parte y remite a ella por enlace. No escribas fórmulas del tipo "no duplicar".
   - Encabezados numerados en decimal (N, N.M, N.M.x), para referencia cruzada por número. Si la pieza es parte de un árbol, la numeración hereda su prefijo y no reinicia en 1.

   Solo en la pieza que abre el documento (el documento único, o la raíz de un árbol):
   - Tabla de metadatos "Campo | Valor" al abrir. No la repitas en las piezas internas.
   - Índice jerárquico con esa numeración. Agrupa en bloques nombrados solo si una parte reúne muchas entradas; con tres o cuatro, no aporta.
   - Si otros documentos la consumen o la enlazan, tabla de trazabilidad inversa: `Página | ID | Qué dato consume o rol del enlace | Tipo de enlace` (*Consumo* obliga a propagar el cambio, *Navegación* no), cerrada con una nota de mantención. En documentos de repo, `Página | ID` se sustituye por la ruta del artefacto. El disparador es que otros la referencien, no que se declare SSOT.

   Para documentos multi-página: raíz que solo enlaza + contenido en las hijas por tema.

   No exijas rutas de lectura por intención ni leyenda de marcadores de certeza: son opcionales, a criterio del autor. **No** apliques esta estructura a tipos cortos de tema único (bitácora, resumen, commit).
3. Redacta el contenido con la plantilla del tipo, aplicando el bloque de reglas de prioridad alta (ver `rules.md` → "Reglas de prioridad alta — resumen") sin excepción, más las reglas `media`/condicionales que activen (tablas si hay datos estructurados, adaptar a audiencia si el destino no es técnico, etc.).
4. Reglas no negociables al redactar:
   - Prosa en español (Chile); código/identificadores/comandos en inglés (regla 1).
   - Cero emojis (regla 2).
   - Markdown escaneable: encabezados, listas, tablas, bloques de código con lenguaje (regla 3).
   - Abre con propósito/alcance (o callout SSOT si es autoridad de un dato) (regla 4).
   - Cierra con próximos pasos, pendientes o referencias (regla 5).
   - Si el insumo referencia un dato cuya fuente única es Confluence: **enlazar, no reproducir**, y declarar qué dato puntual se consume (regla 8).
   - Toda afirmación no trivial cita su fuente (archivo:línea, comando, o URL SSOT) (regla 9).
   - No inventes: si falta un dato, decláralo como pregunta abierta o supuesto explícito, nunca lo rellenes (regla 10).
   - Nunca emitas secretos, credenciales ni datos personales; ejemplos siempre sintéticos (regla 16).
   - Aplica las reglas de prosa (`rules.md` → "Reglas de prosa"): párrafo de 2 a 4 oraciones, oración de 30 palabras o menos, negrita solo para términos que el documento define, un inciso por párrafo, palabra común sobre la rebuscada, sin reformular el párrafo anterior, sin cierre sentencioso (reglas 26-32).
5. Entrega el documento en la respuesta, listo para pegar en su destino. **Escribe a disco (Write/Edit) o publica en Confluence solo si el usuario lo pide explícitamente**; si no lo pide, propones el contenido sin materializarlo. Publicar en Confluence se hace por el modo publicar (§6), con su gate.
6. Antes de entregar, verifica mentalmente contra el bloque de reglas de prioridad alta y, si aplicó la regla 25, contra la estructura documental (autochequeo, no un auditar formal).

**Ejemplos de referencia de este modo**: [`examples/compliant-adr.md`](examples/compliant-adr.md) —un ADR conforme al estándar— y [`examples/structured-doc.md`](examples/structured-doc.md), que muestra la estructura documental de la regla 25 para documentos extensos. Ambos usan **datos sintéticos**.

## 4. Modo AUDITAR

**Entrada**: URL o id de una página del espacio configurado (léela en vivo con `getConfluencePage`), ruta de archivo del repo (léela con Read), o texto pegado en `$ARGUMENTS`.

Auditar es de **solo lectura**: nunca modifica la página ni el archivo. Si la página en vivo no es accesible, aplica el contexto de acceso (detener, declarar, ofrecer alternativa); no infieras su contenido.

1. Identifica el tipo de entregable si es reconocible (afecta qué reglas de tipo aplican, ej. regla 13 para ADR); si no es un tipo conocido, aplica solo las reglas transversales (lenguaje-formato, estructura, ssot-trazabilidad, verificacion, presentacion, seguridad).
2. Evalúa el documento regla por regla contra `rules.md`. Por cada incumplimiento, registra un Hallazgo con:
   - **Regla**: cuál (número y nombre corto).
   - **Ubicación**: sección, línea o cita textual del documento.
   - **Severidad**: la prioridad de la regla (alta/media/baja); **excepción**: cualquier secreto, credencial o dato personal/financiero detectado es **siempre severidad alta** (regla 16), sin importar el contexto.
   - **Corrección sugerida**: concreta y accionable, nunca vaga ("mejorar la redacción" no es válido; "mover la conclusión al primer párrafo" sí).
3. Si el hallazgo es de una regla de prosa con método **Juicio** (30, 31 o 32), agrega "(Juicio)" junto al número en la columna Regla. Distingue lo comprobado por comando de lo que exige lectura, para que no pesen igual.
4. No fabriques hallazgos: si una regla se cumple, no la reportes. Un documento ya conforme produce 0 hallazgos.
5. Devuelve el reporte en este formato fijo:

   ```text
   Veredicto: conforme | no-conforme
   Resumen: N hallazgos (alta: X, media: Y, baja: Z)

   | Regla | Ubicación | Severidad | Corrección sugerida |
   |-------|-----------|-----------|----------------------|
   | ...   | ...       | alta      | ...                  |
   ```

   Ordena los hallazgos por severidad (alta primero). Si hay 0 hallazgos, omite la tabla y confirma conformidad explícitamente.
6. **Regla dura**: si existe al menos un hallazgo de severidad alta (en particular cualquier secreto/PII), el veredicto **nunca** puede ser `conforme`.

**Ejemplo de referencia de este modo**: [`examples/seeded-violations.md`](examples/seeded-violations.md), con violaciones **sembradas a propósito** para comprobar que la auditoría las detecta. Su "secreto" es sintético.

## 5. Modo CONSULTAR

**Entrada**: un tipo de entregable (o una categoría de `rules.md`).

1. Toma la plantilla del tipo desde [`templates.md`](templates.md) (la tabla §2 dice qué sección le corresponde) y filtra `rules.md` por ese tipo o categoría (secciones "Reglas por categoría" para el detalle).
2. Devuelve: la **sección completa de `templates.md`** para ese tipo —secciones, orden, omitibles— más el subconjunto de reglas aplicables con su prioridad, y nada más. No generes ni audites un documento concreto en este modo.

## 6. Modo PUBLICAR (escritura a Confluence, con gate)

Escribe páginas del espacio configurado. Es el **único** modo que modifica Confluence, y siempre tras aprobación explícita. Generar y auditar nunca escriben.

**Actualizar una página existente**:

1. Lee la versión vigente con `getConfluencePage` (incluye su número de versión).
2. Muestra al usuario el **contenido exacto** que se va a escribir y la página destino.
3. Espera **aprobación explícita**. Sin aprobación, no escribes nada.
4. Justo antes de escribir, **verifica que la versión vigente sigue siendo la que leíste**. Si cambió, **aborta** y avisa: otra persona editó la página; no se sobrescribe su trabajo.
5. Escribe con `updateConfluencePage` e informa el resultado.

**Crear una página nueva**:

1. **Exige que el usuario declare la página padre**. Sin padre declarado, **no creas** la página ni infieres su ubicación: dónde cuelga en el árbol del espacio es una decisión de arquitectura documental del usuario, no de formato.
2. Muestra el contenido exacto y el padre declarado; espera aprobación explícita.
3. Crea con `createConfluencePage` bajo ese padre e informa el identificador asignado.

En ambos casos, el contenido a publicar cumple el estándar de `rules.md` como si se hubiera generado (§3), incluida la regla 25 cuando aplica.

**Qué cuenta como aprobación explícita.** No exige una pregunta nueva dentro de esta misma invocación: si quien te invoca —en particular el agente `atlassian-executor` ejecutando un plan conforme a [`.claude/contracts/write-plan.md`](../../contracts/write-plan.md)— ya trae el contenido exacto aprobado y sellado por hash, ese sello **es** la aprobación explícita; el usuario ya vio el contenido al sellarlo, y no hace falta preguntarle de nuevo (equivalencia que el contrato declara y esta skill reconoce). Lo único que no se admite, en ningún caso, es escribir sin que exista esa aprobación — preguntada en vivo por quien te invoque directamente, o ya sellada en un plan.

## Reglas de operación de la propia skill

- **Least privilege**: usa `Write`/`Edit` solo cuando el usuario pida materializar un archivo local; usa `createConfluencePage`/`updateConfluencePage` solo en modo publicar con gate. El resto de las operaciones son de solo lectura. La skill no declara herramientas de borrado de páginas.

### Qué sostiene cada restricción

| Restricción | Garantía |
| --- | --- |
| **No borrar páginas de Confluence** | **Permisos** — ninguna herramienta de borrado está declarada |
| No escribir en Jira | **Permisos** — ninguna herramienta de Jira está declarada |
| Usar `Write`/`Edit` solo a pedido | **Proceso** — **están** declaradas, porque materializar un archivo local es una operación legítima de esta skill |
| Publicar solo en modo publicar y con gate | **Proceso** — `createConfluencePage` y `updateConfluencePage` **están** declaradas, porque publicar es uno de los cuatro modos |
| No degradar en silencio ante fallo de acceso | **Proceso** — ninguna herramienta lo impediría |

> **Las dos últimas de proceso son las restricciones centrales de esta skill, y ninguna está respaldada por permisos.** Lo que las sostiene es el gate: cada escritura muestra antes lo exacto que hará y espera aprobación explícita. Al auditar esta skill hay que decirlo así, sin presentarlas como garantía de permisos.

- **Acceso en vivo**: ante fallo de acceso a Confluence, detente, declara la falta de acceso y ofrece operar sobre archivo o texto pegado; nunca degradar en silencio.
- **Nunca** proponer `git push`/`merge`/PR-merge sin confirmación explícita (regla 15), aunque el entregable generado sea sobre ese tema.
- Si el insumo exige una decisión de alcance (p. ej. qué tipo de entregable usar ante un caso límite, o dónde crear una página), preséntala como opciones con recomendación (regla 24) — no asumas en silencio.
- Sin emojis, en ningún modo, en ninguna salida de esta skill.

## Detector de dependencias externas

Comprueba que ningún artefacto de `.claude/` dependa de una skill que no vive en el repositorio. Recorre el directorio completo, no solo esta skill: la regla que hace cumplir —`06-nomenclatura-agentica.md`— rige para todo el repositorio.

```bash
grep -rnE '(^|[ `(])/(documentar|decision|bitacora|resumen|ticket)\b' .claude/ --include="*.md" \
  | grep -vi 'atajo'
```

**Resultado esperado: sin salida.** Cualquier línea que aparezca es un artefacto que invoca una skill externa sin declararla atajo opcional, y hay que corregirla.

**Qué NO marca, a propósito**: una barra usada como separador entre palabras (`tarea/ticket`). Tampoco los nombres de tipo de entregable sin barra (`` `bitacora` ``, `` `resumen` ``), ni las menciones que declaran el comando como atajo. Sin esas exclusiones, el comando produciría falsos positivos permanentes: un detector que grita siempre se ignora.

**Su ejecución es manual.** No existe en este repositorio ningún mecanismo que lo dispare solo: no hay CI propio ni hook de git que lo invoque. Presentarlo como salvaguarda automática sería falso — protege solo cuando alguien lo corre.
