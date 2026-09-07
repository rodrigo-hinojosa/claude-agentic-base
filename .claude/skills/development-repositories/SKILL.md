---
name: development-repositories
description: Autoridad del dominio de los repositorios de desarrollo y QA del proyecto, sobre un catálogo local versionado que no se deriva de la fuente de documentación en vivo. Cuatro modos — consulta qué repositorios existen y dónde vive cada spec, con la procedencia de cada dato y sin abrir la fuente; prepara y actualiza los clones locales con scripts propios de la skill; especifica un desarrollo creando su spec en el repositorio del componente y registrándola por puntero; y sincroniza contra la sección fuente del inventario para reportar divergencias sin aplicarlas. Úsala al preguntar qué repositorios tiene el proyecto, al dejar el espacio de trabajo local al día, o al abrir la spec de un desarrollo. No escribe código de producto, no crea ramas, no commitea y no publica hacia ningún remoto sin confirmación explícita. Requiere configurar los parámetros por proyecto en su primera adopción.
allowed-tools: Read, Grep, Bash, Write, Edit, mcp__atlassian__getConfluencePage, mcp__atlassian__searchConfluenceUsingCql
---

# development-repositories — los repositorios de desarrollo como dominio operable

> **Autoridad operativa** de los repositorios de desarrollo y QA del proyecto dentro de este repositorio. El conjunto vive en [`repositories.md`](repositories.md), que es una **réplica declarada** de la sección fuente del inventario de repositorios en la documentación del proyecto, con procedencia por dato. Cuál es esa sección fuente —espacio, página e ID— es parámetro por proyecto: `Pendiente de configurar`, y se registra en el propio catálogo.
>
> **Esta skill no escribe código de producto.** Prepara copias de trabajo, lee su estado y crea el archivo de spec de un desarrollo. Crear la rama y commitear pertenecen al agente `developer` (`.claude/agents/developer.md`), con su traza en la portación (`specs/002-portar-agentes/`).
>
> **Procedencia**: skill portada desde un workspace de origen y adaptada a plantilla; las decisiones de la portación están trazadas en `specs/002-portar-agentes/`. Las anécdotas de ese workspace que explican mecanismos vigentes se citan acá como "caso observado en el workspace de origen".

## Parámetros por proyecto

Antes del primer uso real, el proyecto que adopte esta skill debe fijar — todos `Pendiente de configurar` en la plantilla:

| Parámetro | Dónde se registra |
| --- | --- |
| La sección fuente del inventario (página, sección e ID en la documentación del proyecto) | [`repositories.md`](repositories.md) |
| Las filas del catálogo (repositorios del proyecto, con procedencia) | [`repositories.md`](repositories.md) |
| La raíz de clones y su variable de entorno (`REPOS_ROOT`) | [`layout.md`](layout.md) |
| El nombre del repositorio del workspace, que los scripts excluyen | [`layout.md`](layout.md) |
| El directorio de equipo contra el que resuelven los owners | La skill de dominio de equipo que el proyecto defina — `Pendiente de configurar` |
| El registro de decisiones del proyecto (para la pregunta por el repositorio oficial) | `Pendiente de configurar` por proyecto |

## 0. El catálogo es descriptivo, y no normativo

El catálogo registra **qué repositorios existen** hoy según la fuente. **No declara** cuál es el repositorio oficial del proyecto ni qué CI/CD rige. Si el proyecto tiene esa decisión abierta, el catálogo no la resuelve, y responder con la lista convertiría en estándar de facto algo que el proyecto mantiene en suspenso.

En el workspace de origen, la propia sección fuente lo decía de sí misma: *"Esta tabla es un inventario observado, no una declaración de oficialidad."* El criterio viaja con la plantilla aunque la frase sea de allá.

**Ante una pregunta por el repositorio oficial o por el CI/CD vigente, ningún modo responde con el catálogo.** La respuesta remite al registro de decisiones del proyecto (`Pendiente de configurar`); si la decisión no está tomada, se declara abierta con ese puntero.

## 1. Determinar el modo

| Modo | Qué hace | Toca la fuente en vivo |
| --- | --- | --- |
| **Consultar** | Responde sobre los repositorios, su procedencia, las divergencias registradas, el índice de specs y la convención local | No, nunca |
| **Preparar** | Deja los clones disponibles y al día, y reporta el estado real de cada uno | No |
| **Especificar** | Crea el archivo de spec de un desarrollo en el repositorio del componente y registra su puntero en el índice | No |
| **Sincronizar** | Contrasta el catálogo contra la sección fuente y reporta las diferencias sin aplicarlas | Sí, de solo lectura |

**Son cuatro y no cinco.** Un modo `auditar` —contrastar lo que la fuente declara contra lo que el hosting de repositorios muestra— se retiró en el diseño de origen porque ninguna historia de usuario lo cubría; dárselo en la fase de tareas habría sido escribir spec al revés. Está **fuera del alcance de esta skill** y vuelve por su propia spec si algún proyecto lo necesita.

Si la petición no dice el modo, se resuelve por lo que se pide y se declara cuál se eligió antes de operar.

## 2. Qué aloja la skill, y por qué en archivos separados

| Archivo | Qué contiene | Caduca cuando |
| --- | --- | --- |
| [`repositories.md`](repositories.md) | El conjunto de repositorios, con procedencia por fila | Cambia la sección fuente |
| [`provenance.md`](provenance.md) | Qué relevamiento sostiene hoy cada campo | Se ejecuta un relevamiento nuevo |
| [`divergences.md`](divergences.md) | Diferencias entre catálogo y fuente. **Sin campo de resolución** | Alguien las resuelve fuera del archivo |
| [`spec-index.md`](spec-index.md) | Dónde vive cada spec de desarrollo, por puntero | Se abre, avanza o cierra un desarrollo |
| [`layout.md`](layout.md) | Vocabulario, disposición de los clones y códigos de salida | Casi nunca |

**Se separan por velocidad de caducidad, no por tema.** El criterio proviene de las skills de dominio del workspace de origen: un archivo único obligaría a revalidar todo el cuerpo en cada cambio y volvería indetectable qué quedó viejo.

A esos cinco se suman [`scripts/`](scripts/) —**ocho** archivos: el ejecutor, la preparación, los dos envoltorios, los dos detectores y las **dos bibliotecas compartidas**, `lib-repo-state.sh` (lectura de estado) y `lib-repo-set.sh` (catálogo, raíz y selección)—, [`templates/development-spec.md`](templates/development-spec.md) y [`examples/`](examples/), con **cuatro** archivos: dos salidas ilustrativas —consultar y sincronizar— y dos fixtures de prueba, el del catálogo para los scripts y el de la sección de la fuente para el parser de sincronizar. **Preparar y especificar no tienen ejemplo de salida**, y el vacío va dicho en vez de tapado: sus salidas se leen del `--help` de cada script y de la plantilla.

---

## 3. Modo CONSULTAR

Responde sobre el dominio **resolviendo contra los archivos de esta skill**, no contra la fuente en vivo ni contra el hosting de repositorios. Cubre el conjunto de repositorios, la procedencia de cualquier dato, las divergencias registradas, el índice de specs y la convención del espacio local.

### 3.1 Nunca abre la fuente en vivo, y esa es su razón de existir

**Ninguna consulta lee la fuente en vivo.** Que el conector esté caído, sin autorizar o lento no puede impedir saber qué repositorios tiene el proyecto: para eso el catálogo vive versionado en el repositorio.

La consulta **entrega siempre la procedencia** de lo que responde: qué relevamiento sostiene el dato y con qué fecha. Un dato sin procedencia es recordado, no verificable.

**Si un campo tiene sostén de segunda mano, se dice.** Caso observado en el workspace de origen: dos campos del catálogo se poblaron desde un registro local del contenido publicado y no desde una lectura de la página, y así quedó declarado. El detalle por campo vive en [`provenance.md`](provenance.md).

### 3.2 Ningún resultado vacío se presenta sin calificar

Una consulta que no devuelve filas declara **cuál de las dos cosas ocurrió**: ausencia real en el catálogo, o consulta que no se resolvió. Las dos producen la misma pantalla vacía y son indistinguibles por defecto.

El mismo cuidado rige sobre los ceros de los archivos. En una plantilla recién adoptada, `divergences.md` registra cero divergencias **porque nunca se corrió un contraste**, no porque catálogo y fuente coincidan. Una consulta que informe ese cero sin la calificación afirmaría algo que nadie comprobó.

### 3.3 La pregunta que el catálogo no responde

Ante *"cuál es el repositorio oficial"* o *"qué CI/CD rige"*, el modo **no** enumera repositorios. Remite al registro de decisiones del proyecto (`Pendiente de configurar`), y si la decisión no está tomada, la declara abierta.

Vale también para sus variantes: cuál es el repositorio "principal", cuál el "correcto" para un componente nuevo, o qué pipeline "hay que usar". La forma de la pregunta cambia y la decisión abierta es la misma.

Ejemplos de salida de este modo, con las tres formas de consulta: [`examples/query-result.md`](examples/query-result.md).

---

## 4. Modo PREPARAR

Deja el espacio de trabajo local utilizable. Tiene **tres operaciones** y cada una tiene su script versionado dentro de la skill.

| Operación | Script | Qué hace |
| --- | --- | --- |
| Preparar | [`scripts/prepare-workspace.sh`](scripts/prepare-workspace.sh) | Clona los repositorios del catálogo que faltan en la raíz de clones |
| Actualizar | [`scripts/update-workspace.sh`](scripts/update-workspace.sh) | Avanza los clones limpios contra su upstream, y salta los demás nombrándolos |
| Estado | [`scripts/workspace-status.sh`](scripts/workspace-status.sh) | Lee presencia, rama, limpieza y situación respecto del remoto, sin operar nada |

Las dos últimas son **envoltorios de una línea** sobre [`scripts/run-across-repos.sh`](scripts/run-across-repos.sh), el ejecutor de verbos cerrados. Mantenerlas como implementaciones separadas dejaría dos lecturas del mismo estado divergiendo en silencio.

**Los verbos del ejecutor son cinco y forman un conjunto cerrado**: `status`, `fetch`, `pull`, `branch` y `log`. Ninguna palabra que aporte quien invoca llega a `git` como bandera, y `checkout` no existe porque su superficie de daño es la mayor del conjunto.

### 4.1 Lo que ninguna operación hace

**Ninguna borra clones, descarta cambios locales ni reescribe historia publicada.** No es una promesa de cuidado: está fuera del alcance de la skill, y si alguna vez hace falta, lo hace una persona sobre un repositorio concreto.

Un repositorio con cambios sin guardar **se salta y se nombra**, con su motivo en el reporte. Es la garantía central del modo, y el ejecutor la aplica antes de intentar cualquier avance.

`--prune` no se usa en el verbo `fetch`. Cuando el remoto ya borró una rama, ningún `fetch` posterior repone las referencias que `--prune` elimina, de modo que es pérdida sin retorno.

### 4.2 Publicar hacia el remoto exige confirmación por operación

**Ningún script hace `push` ni abre un pull request.** Publicar hacia el remoto requiere confirmación explícita del usuario **por operación**, y nunca ocurre como efecto colateral de preparar, actualizar o leer el estado.

"Por operación" significa una confirmación por cada publicación, no una autorización que quede abierta para la sesión. Una aprobación general sobre todos los repositorios del catálogo no es un gate.

### 4.3 Ruta ocupada y raíz mal apuntada detienen la corrida

**Si la ruta destino de un clon existe y no es ese clon, la preparación se detiene antes de crear nada** y nombra todas las colisiones de una vez. La raíz de clones es un directorio compartido que la skill no posee, donde ya vive el workspace.

**Si la raíz resuelta cae dentro del árbol del workspace, la operación se rechaza.** Vale tanto para el valor por defecto como para `REPOS_ROOT`, que es libre. La disposición, la resolución de la raíz y la derivación del directorio local están en [`layout.md`](layout.md) §2 a §6.

### 4.4 La configuración de git del repositorio gestionado se neutraliza en parte

Toda invocación pasa por `repo_git`, en [`scripts/lib-repo-state.sh`](scripts/lib-repo-state.sh), que llama a git así:

```sh
git -c core.fsmonitor= -c core.hooksPath=/dev/null -C "$dir" "$@"
```

**El motivo es que git ejecuta configuración del propio repositorio gestionado**: hooks en `pull`, `reference-transaction` en `fetch`, y `core.fsmonitor` en el mismo `git status --porcelain` que alimenta cada fila del reporte. Neutralizar hooks y fsmonitor es lo que se puede neutralizar sin romper la operación.

**La mitigación es parcial, y va declarada como tal.** No cubre `credential.helper`, `core.pager`, `diff.*.textconv` ni los filtros `clean` y `smudge`. Quien la lea como blindaje concluirá que la skill impide algo que no impide.

**`--dry-run` no es una inspección pasiva.** Suprime `fetch` y `merge`, y las columnas de estado se siguen leyendo con `git status`, que ejecuta configuración local igual que cualquier otra lectura.

### 4.5 Obligaciones del modo

1. **Todo campo del reporte se lee del repositorio real después de operar**, nunca del acuse del comando. Caso observado en el workspace de origen: un `fetch` que no trajo nada informaba que sí, y se corrigió comparando referencias antes y después.
2. **La ruta efectiva de la raíz se declara resuelta en el encabezado**, escrita como ruta y jamás como nombre de variable.
3. **Una falla se nombra por repositorio con su motivo**, y el conjunto no se declara completo si alguna operación falló.
4. **Un repositorio sin commits es `vacío`, no `limpio`.** Caso observado en el workspace de origen: varios repositorios figuraban activos en la fuente y estaban vacíos en el hosting.
5. **El workspace nunca es objetivo**, por tres motivos independientes: los scripts recorren el catálogo, el repositorio del workspace no es una fila del catálogo, y los scripts lo excluyen además por nombre (el nombre a excluir es parámetro por proyecto; ver [`layout.md`](layout.md)).

La forma completa del reporte —encabezado, columnas, vocabulario cerrado y cierre— la fijaba un contrato del workspace de origen que no viaja con la plantilla; en la base, la referencia operativa es la salida del propio script (`--help` incluido) y la procedencia de esa forma queda trazada en la portación (`specs/002-portar-agentes/`).

---

## 5. Modo ESPECIFICAR

Abre la spec de un desarrollo. **El artefacto vive en el repositorio del componente**, y el workspace guarda solo su puntero.

### 5.1 La clave de Jira se exige, no se inventa

**Sin clave de Jira no se crea la spec.** La skill la pide como entrada, no la deduce del último issue conocido ni la reemplaza por un identificador provisional.

El motivo está medido — caso observado en el workspace de origen: el tablero crecía con trabajo ajeno al proyecto, y la brecha entre dos features consecutivas varió entre 10 y 172 issues. El número se lee del tablero, no se predice.

**Cuando falta, el modo declara el vacío y remite a [`jira-management`](../jira-management/SKILL.md)** para crear el issue primero. Es una rigidez deliberada: una clave provisional deja punteros que después hay que migrar.

### 5.2 Dónde queda el artefacto y qué registra el índice

```text
<repo del componente>/specs/<CLAVE-XXX>-<slug>/spec.md
```

`<CLAVE-XXX>` es la clave real del issue en el tablero del proyecto (por ejemplo, `ABC-123`). El archivo se crea a partir de [`templates/development-spec.md`](templates/development-spec.md), con sus cinco secciones obligatorias en orden. El repositorio destino debe existir en [`repositories.md`](repositories.md); el workspace nunca es destino.

**La entrada del índice es puntero puro**: clave, slug, repositorio, rama, ruta, estado y las dos fechas. **Ninguna celda contiene contenido de la spec** —ni resumen, ni criterios, ni alcance—, porque un resumen es una réplica que caduca sin avisar.

### 5.3 La frontera del modo

**El modo crea el archivo de spec y nada más.** No crea la rama y no commitea. Esas dos acciones pertenecen al agente `developer` (`.claude/agents/developer.md`), con su traza en la portación (`specs/002-portar-agentes/`); escribir código de producto no pertenece a ninguno de los dos.

En el diseño de origen, una versión anterior del requerimiento concedía a este modo crear ramas y commitear, y ninguna tarea lo implementaba: el requerimiento se declaraba cubierto y no lo estaba. Se acotó en vez de completarse, para reducir la superficie de escritura sobre repositorios de otros equipos.

**La rama que registra la columna `Rama` del índice la crea quien va a trabajar el desarrollo.** El modo la recibe como dato y la anota; si todavía no existe, el puntero no resuelve y el detector lo dirá.

### 5.4 Estados del índice y sus cuatro transiciones

Los estados son cuatro: `abierta`, `en curso`, `cerrada` y `cancelada`. Registran el estado de **la spec como artefacto**, no el del issue en el tablero, que es autoridad de otra cosa.

```text
abierta ──→ en curso ──→ cerrada
   │            │
   └────────────┴──────→ cancelada
```

Las transiciones admitidas son exactamente esas cuatro: `abierta` → `en curso`, `en curso` → `cerrada`, `abierta` → `cancelada` y `en curso` → `cancelada`. Cualquier otro movimiento no está previsto, y `cerrada` y `cancelada` son terminales.

**Una entrada cerrada o cancelada no se borra.** El índice es traza, y borrar una fila reescribe historia en vez de superarla. Reabrir un desarrollo exige una entrada nueva que cite la anterior por su clave.

**Si el repositorio sale del catálogo, la entrada se conserva y se marca**, con el sufijo que fija [`spec-index.md`](spec-index.md) §3. No desaparece en silencio.

### 5.5 Obligaciones del modo

1. **No se replica contenido de la spec en el workspace**, en ningún archivo y bajo ningún formato.
2. **Toda transición actualiza la columna `Actualizada`** en la misma edición.
3. **El estado de la tabla de la spec y el del índice deben coincidir.** Si divergen, manda el artefacto: el índice es el puntero.
4. **Un puntero que no resuelve se reporta, no se silencia.** Lo detecta [`scripts/check-spec-pointers.sh`](scripts/check-spec-pointers.sh), de ejecución manual, que distingue `puntero roto` de `no verificable` y de `rama ausente en el clon`.

---

## 6. Modo SINCRONIZAR

> **Las tablas de §6.2 y §6.3 son réplicas declaradas de la portación, 07-09-2026 (feature `002-portar-agentes`).** En el workspace de origen su autoridad era un contrato de reporte que no viaja con la plantilla; en la base, estas tablas **son** la autoridad de la forma del reporte.
>
> Se copian y no se citan porque son la instrucción operativa del modo, y quien lo ejecuta no debería tener que abrir otro archivo para saber cómo clasificar una fila. La regla 2 de `.claude/rules/09-punteros-y-replicas.md` admite la réplica **declarada**; lo que prohíbe es la encubierta.

Contrasta [`repositories.md`](repositories.md) contra la sección fuente y **reporta sin aplicar**. No escribe el catálogo, no escribe la fuente y no escribe [`divergences.md`](divergences.md).

### 6.1 Cómo lee la fuente

El cuerpo de la página se lee con `getConfluencePage`. **El número de versión se obtiene aparte**, con una consulta liviana que no trae el cuerpo:

```text
searchConfluenceUsingCql(cql="id = <ID de la página fuente>", expand="content.version")
```

El ID de la página fuente es parámetro por proyecto (`Pendiente de configurar`, registrado en [`repositories.md`](repositories.md)).

**Esa segunda consulta no es un lujo.** Medido en el workspace de origen: `getConfluencePage` con `contentFormat: markdown` no devuelve el número de versión: entrega un `lastModified` relativo que no sirve como sello estable para comparar dos lecturas.

### 6.2 Alcance de lectura: todas las filas de la fuente, por presencia en la fuente

**El recorrido cubre todas las filas de la tabla de la sección fuente**, incluidas las de componentes esperados que digan "Sin repositorio".

**La regla es por presencia en la fuente, nunca por correspondencia con el catálogo.** Formulado al revés —recorrer el catálogo y buscar cada fila en la fuente— el modo quedaría ciego justo al evento que existe para detectar: una fila nueva no tendría desde dónde salir a buscarse.

| En la fuente | En el catálogo | Resultado |
| --- | --- | --- |
| Con repositorio | Presente | Contraste campo a campo |
| Con repositorio | Ausente | Divergencia de presencia |
| Sin repositorio | Ausente | Correcto: no es un repositorio y no entra al catálogo |
| Ausente | Presente | Divergencia de presencia |

### 6.3 Los tres resultados, y por qué ninguno se confunde con otro

| Resultado | Cuándo | Cómo se escribe |
| --- | --- | --- |
| Sin divergencias | El contraste corrió completo y no halló diferencias | "Sin divergencias", con la versión leída |
| N divergencias | El contraste corrió y halló diferencias | Una fila por divergencia, con ambos valores |
| No se pudo contrastar | Conector caído, página inaccesible, o la tabla esperada no aparece | "No se pudo contrastar: `<motivo>`" |

**La versión de la página es obligatoria en los tres.** Sin ella, el reporte no dice contra qué se comparó y deja de ser verificable después.

**El tercer resultado jamás se presenta como el primero.** Un conector sin autorizar y un catálogo perfectamente al día producen la misma salida vacía, y solo se distinguen si el reporte declara cuál es. Ante falta de acceso, el modo declara la falta y se detiene.

### 6.4 La tabla se localiza por sus encabezados, no por su posición

**El parser ubica la tabla leyendo sus encabezados de columna.** Caso observado en el workspace de origen: la sección fuente se reestructuró al menos una vez entre dos versiones consecutivas de la página, y volverá a moverse.

Si los encabezados esperados no aparecen, el modo cae en el tercer resultado y lo dice con su motivo. Nunca emite divergencias derivadas de una tabla que no reconoció.

### 6.5 La divergencia de presencia y la regla del owner

**Una divergencia de presencia va con la celda `Repositorio` vacía y `Campo` con el valor `presencia`.** Es divergencia de conjunto —uno de más o uno de menos—, no de un repositorio que el catálogo ya tenga.

**Una diferencia de forma del nombre del owner no es divergencia.** Que la fuente escriba una forma abreviada del nombre y el directorio de equipo registre el nombre completo es la misma persona escrita de dos maneras. Reportarlo produciría una divergencia falsa en cada corrida sobre filas correctas.

**Sí es divergencia que la fuente nombre a alguien que no resuelve contra el directorio de equipo del proyecto** (la skill de dominio que el proyecto defina — `Pendiente de configurar`), y el catálogo no absorbe ese nombre. La regla completa de resolución está en [`repositories.md`](repositories.md) §3.1.

### 6.6 Contrastar, registrar y aplicar son tres actos distintos

| Acto | Quién | Qué toca | Gate |
| --- | --- | --- | --- |
| Contrastar | Este modo | Nada: emite el reporte | Ninguno, es lectura |
| Registrar | Operación aparte | [`divergences.md`](divergences.md) | Confirmación explícita |
| Aplicar | Operación aparte | [`repositories.md`](repositories.md) y [`provenance.md`](provenance.md) | Confirmación explícita, con relevamiento nuevo |

**El modo emite el reporte y se detiene.** Escribir la divergencia ya modifica el repositorio, y dejar escrito que catálogo y fuente difieren tampoco decide cuál de los dos gana.

La forma del reporte la fijan las tablas de §6.2 y §6.3; un ejemplo con divergencias sembradas está en [`examples/sync-report.md`](examples/sync-report.md).

**El parser se prueba contra [`examples/source-section-fixture.md`](examples/source-section-fixture.md)**, que reproduce la forma de la tabla de la sección fuente con una fila sembrada: un componente que en el fixture aparece **con repositorio** y en la fuente real no lo tiene. Existe porque la skill no escribe en la fuente, de modo que sembrar esa fila en la fuente es imposible por diseño, y sin el fixture el contraste del parser no sería ejecutable en pruebas.

> **El conector puede fallar de forma intermitente al invocarse desde un subagente.** Caso observado en el workspace de origen: tres fallas consecutivas y un éxito al día siguiente con la misma configuración, sin causa determinada. No se asume que funcionará ni que fallará: se verifica en cada uso, y de ahí el tercer resultado.

---

## 7. Reglas de operación de la propia skill

- **El catálogo es la autoridad operativa y no se deriva en vivo.** Ir a la fuente en cada consulta está prohibido; solo sincronizar la lee.
- **No decide divergencias.** Las presenta con ambos valores y su ubicación.
- **No aloja datos de personas.** El owner es un puntero al directorio de equipo que el proyecto defina (`Pendiente de configurar`), que es su autoridad única.
- **No crea tickets.** Eso pertenece a `jira-management`, con su propio gate.
- **No escribe en Confluence.** Producir o publicar documentación del proyecto pertenece a `confluence-docs`.
- **Ningún vacío se rellena con inferencia.** Se marca `Pendiente`, `Por confirmar` o `Sin información registrada`, con el nombre de lo que falta.
- **Sin emojis en ninguna salida**, y sin credenciales, tokens ni URLs autenticadas en ningún reporte.

---

## 8. Qué sostiene cada restricción

**Dos clases, y no valen lo mismo.** `Permisos` la sostiene el `allowed-tools` del frontmatter: se comprueba leyendo la lista y solo se rompe editándola. `Proceso` la sostiene una instrucción de este archivo: no se comprueba, y un prompt que la contradiga la rompe.

La forma de esta tabla proviene de las skills de dominio del workspace de origen; se replica la **forma**, no sus filas. Cada skill declara sus restricciones contra su propio allowlist.

| Restricción | Garantía | Detalle |
| --- | --- | --- |
| No consultar la fuente en modo consultar | **Proceso** | `getConfluencePage` y `searchConfluenceUsingCql` **están declaradas** porque sincronizar las necesita. Nada en el allowlist impide que consultar las invoque: lo sostienen esta instrucción y la procedencia que toda respuesta declara |
| No escribir en Confluence | **Permisos** | Ninguna herramienta de escritura de Confluence está declarada |
| No operar Jira | **Permisos** | Ninguna herramienta de Jira está declarada; crear tickets pertenece a `jira-management` |
| **No ejecutar operaciones destructivas sobre repositorios** | **Proceso** | `Bash` está declarada y no distingue subcomandos: nada técnico impide un `rm -rf` o un `git reset --hard`. Lo impiden los verbos cerrados de los scripts y esta instrucción |
| **No publicar hacia remotos sin confirmación** | **Proceso** | `git push` es alcanzable desde `Bash`. Lo sostiene el gate por operación de §4.2 |
| **No leer archivos de secretos de los repositorios gestionados** | **Proceso** | `Read` y `Bash` alcanzan cualquier archivo del disco. Lo sostienen esta instrucción y el bloque `deny` de `.claude/settings.json` para los patrones que ya cubre |

> **Criterio heredado del workspace de origen, y vale acá**: toda restricción de la forma *"el modo X no usa la herramienta Y", donde `Y` está declarada porque el modo `Z` la necesita*, es **necesariamente** de proceso. En el origen, la primera fila llegó a rotularse como respaldada por permisos y era falso — la columna `Detalle` decía la verdad y la que se lee al auditar es `Garantía`. El rótulo se corrigió; la lección viaja con la tabla.

### 8.1 Las tres restricciones centrales son de proceso, y el motivo tiene dos partes

**La primera parte es el allowlist.** `Bash` no tiene granularidad de subcomando: declararla habilita cualquier comando, y una skill que orquesta repositorios no puede prescindir de ella. La alternativa —no declarar `Bash` y describir los comandos para que los ejecute una persona— anula la función de la skill, y se descartó por eso.

**La segunda parte es git mismo, y se descubrió midiendo.** El borrador del ejecutor afirmaba que sostenía la prohibición de leer secretos "por construcción, porque solo interroga a git por metadatos". Es falso: el script no lee esos archivos, pero **git ejecuta configuración del propio repositorio gestionado**.

Ocurre en las tres operaciones, no solo en las mutantes: hooks en `pull`, `reference-transaction` en `fetch`, y `core.fsmonitor` en el `git status` que alimenta cada fila del reporte, **incluido `--dry-run`**.

**La neutralización de la sección 4.4 no cambia la clase de estas garantías.** Reduce la superficie y deja fuera `credential.helper`, `core.pager`, `diff.*.textconv` y los filtros `clean` y `smudge`.

### 8.2 El modelo de amenaza, dicho con precisión

**`git clone` no trae hooks ni configuración del remoto.** Esto no es "clonar un repositorio hostil y quedar comprometido": exige que algo ya haya escrito en el `.git/` local del clon.

Dicho eso, el workspace de origen fue objetivo de un ataque de supply chain, y `.git/` es exactamente donde esa clase de ataque persiste. Un abanico sancionado sobre un conjunto de repositorios es su multiplicador ideal.

La precisión importa para que el hallazgo sea utilizable. Sin ella se lee como una advertencia genérica que nadie sabe cómo accionar; con ella, la pregunta concreta es quién puede escribir en el `.git/` de esos clones.

### 8.3 Verificación de la superficie declarada

La comprobación tiene **dos mitades, y solo una es un comando**.

**Mitad mecánica** — que la línea declarada sea exactamente la esperada. Falla con código 1 si difiere:

```bash
esperado='allowed-tools: Read, Grep, Bash, Write, Edit, mcp__atlassian__getConfluencePage, mcp__atlassian__searchConfluenceUsingCql'
hallado=$(awk '/^---$/{n++; next} n==1 && /^allowed-tools:/' \
  .claude/skills/development-repositories/SKILL.md)
[ "$hallado" = "$esperado" ] || { echo "ERROR: allowed-tools difiere"; exit 1; }
```

**Mitad de lectura humana** — que cada herramienta declarada la use algún modo. Eso **no lo comprueba ningún comando**, porque exige leer los procedimientos. El barrido de abajo acota el trabajo, no lo reemplaza:

```bash
for h in Read Grep Bash Write Edit getConfluencePage searchConfluenceUsingCql; do
  printf '%-26s %s\n' "$h" \
    "$(grep -c "$h" .claude/skills/development-repositories/SKILL.md)"
done
```

Una herramienta con una sola aparición está nombrada **solo en el frontmatter**, y es candidata a superficie de más.

> **Caso observado en el workspace de origen**: una versión anterior de esta sección cerraba con el veredicto `Conforme` y un comando que no comprobaba nada — solo imprimía la línea, y salía 0 dijera lo que dijera. Era *un verificador se parece a un resultado limpio* dentro de la sección escrita para evitarlo. Al corregirlo, ese mismo barrido encontró que `Glob` estaba declarada y ningún modo la usaba: se retiró, y el allowlist quedó en **siete** herramientas.

---

## 9. Frontera — qué no hace la skill, y quién lo hace

| No hace | Quién lo hace |
| --- | --- |
| Escribir código de producto | Quien desarrolla el componente. El agente `developer` de esta base tampoco lo hace (`specs/002-portar-agentes/`, FR-006) |
| Crear la rama de un desarrollo y commitear | Una persona, o el agente `developer` (`.claude/agents/developer.md`) |
| `push` o abrir un pull request sin confirmación explícita por operación | Una persona, en el momento; el agente `developer` publica solo con una autorización conforme a `.claude/contracts/publish-authorization.md` |
| Borrar clones, descartar cambios, reescribir historia publicada | Nadie: está fuera de alcance por diseño |
| Crear o mover tickets en el tablero | `jira-management` |
| Producir o publicar documentación en Confluence | `confluence-docs` |
| Resolver los datos de una persona | El directorio de equipo que el proyecto defina (`Pendiente de configurar`), que es su autoridad única |
| Decidir cuál es el repositorio oficial ni qué CI/CD rige | El proyecto, en su registro de decisiones; mientras no esté tomada, es una decisión abierta |
| Resolver una divergencia entre catálogo y fuente | Una persona, tras leer el reporte |
| Auditar los repositorios contra el hosting | Fuera de alcance; vuelve por su propia spec |

**El agente `developer` llega a la base con la misma portación** (`specs/002-portar-agentes/`). La skill se diseñó para uso directo del equipo técnico y para quedar invocable por ese agente: modos explícitos, salidas estructuradas y fallas nombradas.

**Los repositorios que existan en el hosting y la sección fuente no liste quedan fuera de alcance.** El catálogo lo forma la lista de la fuente y solo esa; en el workspace de origen esa regla se fijó por decisión explícita del usuario ante un caso medido, y viaja con la plantilla.

---

## 10. Dónde vive cada cosa

Punteros, no copias. Ninguna de estas fuentes se reproduce en este archivo.

| Materia | Dónde vive |
| --- | --- |
| El conjunto de repositorios, con su procedencia por fila | [`repositories.md`](repositories.md) |
| Qué relevamiento sostiene cada campo, y el sello de la fuente | [`provenance.md`](provenance.md) |
| Diferencias entre catálogo y fuente, sin campo de resolución | [`divergences.md`](divergences.md) |
| Dónde vive cada spec de desarrollo y en qué estado está | [`spec-index.md`](spec-index.md) |
| Vocabulario, disposición de los clones, códigos de salida, lectura del agente | [`layout.md`](layout.md) |
| Opciones, verbos y límites de cada script | El propio script, con `--help` |
| Molde del artefacto de spec | [`templates/development-spec.md`](templates/development-spec.md) |
| Salidas ilustrativas de los modos | [`examples/`](examples/) |
| Forma del reporte de sincronizar | Las tablas de §6.2 y §6.3 de este archivo, réplica declarada de la portación |
| Decisiones de la portación y su procedencia | `specs/002-portar-agentes/` (spec, plan, research) |

Las decisiones de diseño del workspace de origen, con sus alternativas descartadas, quedaron en ese workspace y **no son alcanzables desde esta base**; lo que esta plantilla necesita de ellas está incorporado a este archivo o trazado en la portación.
