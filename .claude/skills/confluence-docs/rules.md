# Reglas — Estándar de documentación

Catálogo operativo de la skill `confluence-docs`. Fuente única y versionada: no se deriva leyendo `.claude/rules/` ni la constitución en cada invocación. Procedencia: réplica declarada del estándar madurado en un workspace anterior, portada y depurada el 06-09-2026 (feature `001-portar-skills-rules`). Regenerar este archivo cuando cambien las reglas del repositorio o la constitución. Revisado el 15-09-2026 (feature `003-concision-confluence-docs`): reglas 5, 7, 10, 11, 25 y 26 reescritas; regla 33 agregada; comando de prosa ampliado.

## Cómo usar este archivo

- En modo **generar**: aplicar todas las reglas de prioridad `alta` sin excepción; las de `media` cuando el tipo de entregable las active (ver tabla de tipos en `SKILL.md`).
- En modo **auditar**: cada regla incumplida es un Hallazgo. Prioridad de la regla → severidad del hallazgo (alta→alta, media→media, baja→baja), salvo seguridad (regla 16), que siempre es severidad alta sin importar el contexto.
- En modo **consultar**: filtrar por categoría o tipo de entregable y devolver el subconjunto relevante.

## Reglas accionables (25)

| # | Regla | Categoría | Prioridad |
|---|-------|-----------|-----------|
| 1 | Prosa en español (Chile); código/identificadores/comandos/rutas en inglés | lenguaje-formato | alta |
| 2 | Cero emojis, siempre | lenguaje-formato | alta |
| 3 | Markdown escaneable: encabezados, listas, tablas, bloques de código con lenguaje declarado; nunca muros de texto | lenguaje-formato | alta |
| 4 | Apertura con propósito y alcance (1-2 frases); si es autoridad de un dato, callout "Fuente única (SSOT)" | estructura | alta |
| 5 | Cierre con próximos pasos, pendientes o referencias, cuando corresponda; si no hay ninguno, la sección de cierre queda con la línea marcada (`templates.md`, "Secciones obligatorias y vacíos") | estructura | alta |
| 6 | Temas con trade-offs: secuencia Contexto→Problema→Análisis→Opciones→Recomendación→Próximos pasos | estructura | alta |
| 7 | Resumen ejecutivo o conclusión primero; nunca enterrada. El bloque de 3-5 viñetas es del tipo resumen y de los documentos bajo la regla 25 (tras el callout, antes de la sección 1); los demás entregables abren con la conclusión en prosa | presentacion | alta |
| 8 | SSOT: no duplicar lo que vive en la fuente única del proyecto; enlazar + declarar el dato puntual consumido | ssot-trazabilidad | alta |
| 9 | Cita de fuente (archivo:línea, comando ejecutado, o URL de página SSOT) en toda afirmación no trivial | ssot-trazabilidad | alta |
| 10 | Distinguir hecho / inferencia / suposición; no inventar datos, APIs, rutas ni resultados; faltantes = línea marcada (`templates.md`, "Secciones obligatorias y vacíos") o pregunta abierta. Juicio: una afirmación válida para cualquier proyecto, sin dato propio del documentado, es relleno y se sustituye por la línea marcada | verificacion | alta |
| 11 | Plantilla fija por tipo de entregable; secciones obligatorias presentes, con línea marcada si no hay dato real (`templates.md`, "Secciones obligatorias y vacíos"); opcionales marcadas "omite si no aplica" | estructura | alta |
| 12 | Descripción de trabajo **fuera de Jira** (specs, actas, doc de tareas): título accionable, alcance y criterios de "hecho" verificables. Los tickets del tablero del proyecto NO se rigen por esta regla: son autoridad de la skill `jira-management`, con su propio estándar | tickets | alta |
| 13 | ADR: Contexto, Decisión, Alternativas reales, Consecuencias con contras, Estado (default Propuesta), dueño, fecha, ADR-NNN | adr-decisiones | alta |
| 14 | Commits: `tipo: descripción` en español imperativo, sin atribución ni emojis; si el proyecto usa Jira: issues `[<CLAVE>-XXX]`, ramas `tipo/<CLAVE>-XXX-desc` | commits-git | alta |
| 15 | Nunca push/merge/PR-merge sin confirmación explícita; confirmar antes de acciones destructivas o irreversibles | commits-git / seguridad | alta |
| 16 | Secretos y PII: nunca en código, docs ni ejemplos; solo datos sintéticos; en auditar SIEMPRE severidad alta | seguridad | alta |
| 17 | SDD: rama `<NNN-slug>` = `specs/<NNN-slug>`; flujo specify→clarify(obligatorio si toca decisión abierta)→plan→tasks→implement; Constitution Check tabulado PASS/N-A justificado | sdd-speckit | alta |
| 18 | Ambigüedad: marcar `NEEDS CLARIFICATION` + enlace al pendiente; lo resuelto se registra en "Clarifications" con fecha, pregunta, opciones, respuesta | sdd-speckit | alta |
| 19 | Escrituras a sistemas compartidos: auditoría read-only previa, gate de aprobación explícita, pre-flight de versión (abortar si cambió) | verificacion / seguridad | alta |
| 20 | Trazabilidad de cierre: decisión relevante = ADR reflejado en SSOT; cierre de feature/tarea = comentario en el ticket con qué se hizo | ssot-trazabilidad | media |
| 21 | Tablas markdown para mapeos, matrices, metadatos "Campo | Valor" y checklists de más de 3-4 ítems | presentacion | media |
| 22 | Adaptar registro y jerga a la audiencia; priorizar impacto sobre implementación para audiencias no técnicas | presentacion | media |
| 23 | Checklists de cierre: evidencia cuantitativa por ítem (cuántos casos, método); rechazar casillas sin sustento | verificacion | media |
| 24 | Decisión del usuario: 2-4 opciones mutuamente excluyentes con implicación y recomendación marcada; no preguntar lo que tiene default seguro | interaccion | alta |
| 25 | Se activa por la naturaleza del entregable (plan, manual, spec larga, página SSOT de dominio, autoridad de datos que otros consumen) o por petición del usuario, nunca por el número de secciones: callout de apertura como único elemento de propósito y alcance (SSOT si es autoridad de un dato: declara alcance y delega los subtemas ajenos por enlace, sin fórmulas de prohibición), seguido del bloque de viñetas de la regla 7 cuando aplique, más encabezados numerados en decimal (N, N.M, N.M.x). En la pieza que abre el documento: tabla de metadatos "Campo \| Valor", índice jerárquico (en bloques nombrados solo si la agrupación es grande) y, si otros documentos la consumen, tabla de trazabilidad inversa (Página \| ID \| Qué dato consume o rol del enlace \| Tipo de enlace: Consumo o Navegación) cerrada con nota de mantención de contenido definido, u omitida si no hay filas. NO aplica a ticket/bitácora/resumen/commit | estructura | alta (cuando aplica) |

## Reglas de prosa (26-33)

Gobiernan cómo se escribe, no qué secciones lleva un entregable ni en qué idioma —eso son las reglas 1 y 11—. **Ámbito**: aplican tanto a lo publicado en Confluence como a los artefactos del repositorio. **Vigencia**: prospectivas, rigen lo que se genera. Sobre lo ya escrito, el modo `auditar` reporta y no reescribe: reescribir prosa normativa existente no es verificable.

| # | Regla | Categoría | Prioridad | Método |
|---|-------|-----------|-----------|--------|
| 26 | Un párrafo sostiene una idea y no pasa de cuatro oraciones. Una idea no se fragmenta en párrafos de una oración | prosa | alta | Comando |
| 27 | Una oración no pasa de 30 palabras. Si pasa, se parte en dos | prosa | alta | Comando |
| 28 | La negrita marca un término que el documento define. No cubre una oración | prosa | alta | Comando |
| 29 | La aclaración que importa va en oración propia. El inciso con guion largo se reserva para el apunte breve, y nunca hay dos en un párrafo | prosa | media | Comando |
| 30 | Usa la palabra común cuando existe | prosa | alta | Juicio |
| 31 | Cada párrafo aporta información que el anterior no dio. Reformular lo ya dicho no es un párrafo nuevo | prosa | alta | Juicio |
| 32 | Una sección cierra con su último dato. No lleva frase de remate | prosa | media | Juicio |
| 33 | La primera oración de una sección entra en materia: sin muletilla de apertura ni de transición, con la lista cerrada del comando de más abajo, y sin repetir el encabezado | prosa | alta | Comando |

Las reglas 26 a 29 no llevan umbral de aprobación: publican su cifra y se comparan contra la línea base por tipo de documento (más abajo). Un umbral se cumple moviendo texto sin escribir mejor, no escribiendo mejor.

Las reglas 30 a 32 no tienen comando. Una regla sin comando publicado queda en método Juicio, cualquiera sea la intención de quien la escribe. Sus hallazgos van marcados como Juicio en la auditoría, para no pesar igual que los comprobados por comando. La 33 es Comando para su lista cerrada; la parte de "sin repetir el encabezado" queda marcada como Juicio, igual que 30-32.

**Dos excepciones que solo la lectura resuelve.** La 28 exime a la negrita larga cuando cubre un término que el propio documento define. La 33 exime la frase de la lista que introduce un bloque de código o una tabla: es transición legítima, no relleno. El comando produce la cifra; la excepción se aplica al juzgar cada hallazgo, no al contarlo.

**Criterio de las reglas de Juicio:**
- **30 — palabra común**: al leer, marcar todo término de registro alto que tenga un equivalente llano en español de Chile (`obliga` → exige; `gobierna` → manda, define; `delata` → muestra, avisa; `caducidad` → queda viejo; `sostiene` → respalda; `remite` → apunta a). No se cazan con un comando. El efecto viene de muchas palabras raras usadas dos o tres veces, no de una repetida.
- **31 — sin reformular**: comparar cada párrafo con el anterior. Si dice lo mismo con otras palabras, sin aportar un hecho, una cifra o una consecuencia nueva, es reformulación.
- **32 — cierre sin remate**: la última oración de una sección debe ser un dato, no una sentencia que interpreta lo ya dicho.
- **33 — repetición del encabezado**: si la primera oración de una sección no lleva ninguna frase de la lista cerrada pero solo repite las palabras del título sin agregar un dato, es relleno igual. Se juzga al leer, no lo cuenta el comando.

**El comando, blindado.** Mide estructura —longitud de oración y de párrafo, extensión de negrita, densidad de guion largo— y una lista cerrada y declarada de frases, no vocabulario libre. La lista vive dentro de su propio bloque de código, que el comando excluye al medir junto con los demás bloques y los comentarios HTML: por eso no se detecta a sí mismo.

```bash
f=<archivo a medir>
python3 - "$f" << 'PY'
import re, sys
raw = open(sys.argv[1], encoding="utf-8").read()
def _blank(m): return "\n" * m.group(0).count("\n")
t = re.sub(r"```.*?```", _blank, raw, flags=re.S)
t = re.sub(r"<!--.*?-->", _blank, t, flags=re.S)
def _estructural(b):
    if b.startswith(("#","|",">")): return True
    if re.match(r"^\d+\.\s", b): return True
    if re.match(r"^[-*+]\s", b): return True
    return False
p = [b.strip() for b in t.split("\n\n") if b.strip() and not _estructural(b.strip())]
blob = "\n\n".join(p); w = max(len(re.findall(r"\w+", blob)), 1) / 1000
def orac(b):
    c = re.sub(r"[`*_\[\]()]", "", b)
    return [s for s in re.split(r"(?<=[.!?])\s+", c) if re.findall(r"\w+", s)]
todas = [s for b in p for s in orac(b)]
n5 = sum(1 for b in p if len(orac(b)) >= 5)
lar = sum(1 for s in todas if len(re.findall(r"\w+", s)) > 30)
MULETILLAS = [
    r"este documento (explica|describe|presenta|detalla|tiene como (objetivo|prop[oó]sito))",
    r"el presente documento",
    r"en este documento",
    r"el objetivo (de este|del presente) documento",
    r"esta secci[oó]n (describe|explica|presenta|detalla)",
    r"en esta secci[oó]n",
    r"a continuaci[oó]n,? se (describe|presenta|detalla|muestra|explica)",
    r"es importante (se[ñn]alar|destacar|mencionar|notar|recordar)",
    r"cabe (destacar|se[ñn]alar|mencionar|recordar)",
    r"vale la pena (mencionar|destacar|se[ñn]alar)",
    r"como (ya )?se (mencion[oó]|dijo|indic[oó]|se[ñn]al[oó])",
    r"en este sentido",
]
hits = [(i, m.group(0)) for i, line in enumerate(t.split("\n"), 1)
        for pat in MULETILLAS for m in re.finditer(pat, line, flags=re.I)]
print(f"R26 parrafos de 5 o mas    : {n5} de {len(p)} = {100*n5//max(len(p),1)}%")
print(f"R27 oraciones de 30+ pal   : {lar} de {len(todas)} = {100*lar//max(len(todas),1)}%")
print(f"R28 negrita larga /1000 pal: {len([m for m in re.findall(r'[*][*]([^*]+)[*][*]', blob) if len(m) >= 60])/w:.1f}")
print(f"R29 guiones inciso /1000   : {blob.count(chr(8212))/w:.1f}")
print(f"R29 parrafos con 2+ incisos: {sum(1 for b in p if b.count(chr(8212)) >= 3)}")
print(f"R33 muletillas (lista)     : {len(hits)}")
for ln, frase in hits:
    print(f"  L{ln}: {frase}")
PY
```

El conteo de incisos de R29 es una aproximación declarada. Tres o más guiones largos en un párrafo indican al menos dos incisos, y un párrafo con dos incisos abiertos, sin cerrar, queda sin marcar. El límite se declara en vez de disimularse.

**Línea base por tipo de documento**: `Pendiente de recomputar` sobre el corpus del proyecto que use esta skill. La línea base del workspace de origen no se copia: un indicador de calidad de prosa envejece con cada edición del corpus que describe, y copiarla sería una réplica caduca desde el primer día. Procedimiento: correr el comando de arriba sobre los archivos de prosa del proyecto, agrupar por tipo (spec, plan, skill, catálogo, contexto) y registrar la tabla aquí con su fecha. Hasta entonces, las reglas 26-29 publican su cifra sin comparación. La 33 no lleva línea base: cada coincidencia de la lista cerrada es un hallazgo, salvo la excepción de contexto ya declarada.

## Reglas de prioridad alta — resumen para chequeo rápido (generar)

Bloque mínimo que TODO entregable generado debe cumplir, sin excepción: reglas 1, 2, 3, 4, 5, 8, 9, 10, 11, 16.

## Reglas por categoría (detalle y "cuándo aplica")

### lenguaje-formato
- **Regla 1** — cuándo: siempre que se mezcle prosa y artefactos técnicos.
- **Regla 2** — cuándo: siempre.
- **Regla 3** — cuándo: toda documentación, comando o plantilla.

### estructura
- **Regla 4** — cuándo: cualquier documento nuevo.
- **Regla 5** — cuándo: doc técnica, bitácora, resumen, análisis, decisión.
- **Regla 6** — cuándo: análisis con trade-offs.
- **Regla 11** — cuándo: al generar cualquier entregable.
- **Regla 25** — cuándo: la naturaleza del entregable lo pide (plan, manual, spec larga, página SSOT de dominio, autoridad de datos que otros consumen) o el usuario lo solicita. Nunca por el número de secciones de la plantilla: una doc-tecnica de tema único con sus cinco secciones no lo activa.

  **En toda pieza extensa** (documento único, o cada página de un árbol):
  - Callout de apertura como único elemento de propósito y alcance, antes de cualquier encabezado. Si la pieza es autoridad de un dato: `> **Fuente única (SSOT)** de <tema>: <alcance>`.
  - **Delegación, no prohibición**: el callout nombra el subtema cuya autoridad vive en otra parte y remite a ella por enlace. No se escriben fórmulas del tipo "no duplicar".
  - Si la regla 7 aplica (tipo resumen, o cualquier documento bajo esta regla), el bloque de 3-5 viñetas va inmediatamente después del callout, sin encabezado propio y sin repetir el propósito ya declarado.
  - Encabezados numerados en decimal (N, N.M, N.M.x), para referencia cruzada por número. En un árbol, la numeración hereda el prefijo de la pieza y no reinicia en 1 (una página 2.1 abre en 2.1.1); los anexos usan letra (A.1, A.2). La sección de propósito y alcance de la plantilla del tipo queda materializada por el callout: la numeración arranca en la sección siguiente.

  **En la pieza que abre el documento** (el documento único, o la raíz de un árbol):
  - Tabla de metadatos `Campo | Valor` al abrir. No se repite en las piezas internas.
  - Índice jerárquico con la numeración decimal. Agrupar en bloques nombrados (`Bloque A — ...`) solo cuando una parte reúne muchas entradas; con tres o cuatro no aporta.
  - Si otros documentos la consumen o la enlazan: tabla de trazabilidad inversa con columnas `Página | ID | Qué dato consume o rol del enlace | Tipo de enlace`, clasificando cada fila como *Consumo* (obliga a propagar el cambio) o *Navegación* (no obliga), cerrada por una nota de mantención con contenido definido (qué fila agregar y cuándo quitarla); si no hay filas que consumen el dato todavía, la tabla y su nota se omiten. El disparador es ser la pieza que otros referencian, no el mero hecho de declararse SSOT. En documentos de repo, `Página | ID` se sustituye por el identificador del artefacto (ruta del archivo o módulo); las columnas obligatorias son el dato consumido y el tipo de enlace.

  **Para árboles multi-página**: raíz que no reproduce contenido, solo enlaza; el contenido en las hojas, cada una fuente única de su tema.

  **No exigido**: rutas de lectura por intención o audiencia, ni leyenda de marcadores de certeza en cada pieza. Quedan a criterio del autor. **Excluye** tipos cortos de tema único (ticket, bitácora, resumen, commit).

### ssot-trazabilidad
- **Regla 8** — cuándo: al documentar datos ya definidos en la fuente única del proyecto.
- **Regla 9** — cuándo: afirmación normativa o no trivial.
- **Regla 20** — cuándo: al cerrar feature/tarea vinculada a ticket, o al registrar una decisión estructural.

### verificacion
- **Regla 10** — cuándo: cualquier respuesta técnica no trivial.
- **Regla 19** — cuándo: automatización que escribe a sistema compartido o de producción.
- **Regla 23** — cuándo: cierre de checklist post-implementación.

### adr-decisiones
- **Regla 13** — cuándo: decisión de arquitectura, herramienta o enfoque con consecuencias.

### tickets
- **Regla 12** — cuándo: redactar tareas o criterios de "hecho" en specs, actas o documentación. Los tickets del tablero del proyecto quedan fuera: los rige la skill `jira-management` con su propio estándar.

### commits-git
- **Regla 14** — cuándo: crear issue, rama o commit.
- **Regla 15** — cuándo: cualquier operación git que publique o integre.

### seguridad
- **Regla 16** — cuándo: siempre; en auditar, detección = severidad alta obligatoria, sin excepción de contexto.

### interaccion
- **Regla 24** — cuándo: bifurcación con trade-offs reales o alcance ambiguo.

### sdd-speckit
- **Regla 17** — cuándo: iniciar feature con `/speckit-specify`.
- **Regla 18** — cuándo: spec que toca punto no resuelto.

### presentacion
- **Regla 7** — cuándo: el tipo resumen, o cualquier documento bajo la regla 25. Los demás tipos cumplen "conclusión primero" abriendo con la conclusión en prosa, sin bloque de viñetas obligatorio.
- **Regla 21** — cuándo: mapeos, matrices, metadatos, checklists largos.
- **Regla 22** — cuándo: elegir tono según destinatario.
