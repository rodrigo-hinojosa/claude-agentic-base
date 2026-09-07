---
name: jira-management
description: Administra el tablero Jira del proyecto en seis modos — redactar un ticket de gestión con plantilla estándar, crear y mover issues con gate de aprobación y resolución en vivo de campos y transiciones, editar campos de issues existentes con gate por operación, auditar issues indicados contra el estándar, y consultar el trabajo por estado o por label sin devolver vacíos falsos. Úsala para escribir, crear, mover, editar o consultar tickets del tablero del proyecto. Requiere configurar los parámetros por proyecto en su primera adopción.
argument-hint: [redacta|crea|mueve|edita|audita|consulta] + insumo (descripción del trabajo, clave de issue, estado destino, campo y valor, o label)
allowed-tools: Read, Grep, Glob, mcp__atlassian__getAccessibleAtlassianResources, mcp__atlassian__getVisibleJiraProjects, mcp__atlassian__getJiraProjectIssueTypesMetadata, mcp__atlassian__getJiraIssue, mcp__atlassian__searchJiraIssuesUsingJql, mcp__atlassian__getJiraIssueTypeMetaWithFields, mcp__atlassian__getTransitionsForJiraIssue, mcp__atlassian__createJiraIssue, mcp__atlassian__transitionJiraIssue, mcp__atlassian__editJiraIssue
---

Solicitud:

$ARGUMENTS

Lee primero la sección **Parámetros por proyecto**: esta skill es una plantilla estándar y no trae ningún tablero precargado. Antes de la primera operación en vivo, los parámetros deben estar resueltos; si alguno falta, decláralo y resuélvelo con el usuario en vez de asumir un valor.

## Parámetros por proyecto

| Parámetro | Valor | Cómo resolverlo |
|-----------|-------|-----------------|
| Sitio y `cloudId` de Atlassian | Se resuelve en runtime, no se persiste | `getAccessibleAtlassianResources` al inicio de la operación en vivo |
| Proyecto Jira (clave e id) | Pendiente de configurar | `getVisibleJiraProjects` y confirmación del usuario |
| Tipo de issue gestionado (nombre e **id**) | Pendiente de configurar | `getJiraProjectIssueTypesMetadata` sobre el proyecto elegido; fijar siempre por id, no por nombre |
| Estados del workflow (nombre e **id** de cada uno) | Pendiente de configurar | `getTransitionsForJiraIssue` sobre un issue del tipo gestionado, más partición por estado (ver `references/jql-traps.md`) |
| Label de gestión (si el proyecto la usa) | Pendiente de configurar | Decisión del proyecto; si se define, toda creación de esta skill la agrega |
| Campos obligatorios de creación | Se resuelven en vivo | `getJiraIssueTypeMetaWithFields` en cada creación; la configuración del proyecto puede cambiar |
| Assignee (si el tablero lo exige) | Pendiente de configurar | Preguntar al usuario o al catálogo del proyecto; esta skill no mantiene directorio propio |

Registra los valores resueltos en la configuración del proyecto derivado (por ejemplo, un catálogo del tablero versionado en su repo), no en esta plantilla.

**Acceso**: servidor MCP `atlassian` (OAuth por sesión). Si una operación en vivo falla por conector sin autorizar, permisos o error de herramienta, **detente, declara la falta de acceso y ofrece redactar sobre texto pegado** como alternativa que el usuario elige (la autorización se hace con `/mcp` en Claude Code); nunca infieras el estado del tablero ni degrades en silencio.

## 1. Determinar el modo

- "redacta/escribe una tarea/ticket para..." → **redactar** (modo por defecto).
- "crea la tarea en el tablero / créala en Jira" → **crear**.
- "mueve <CLAVE-XX> a <estado> / pásala a En progreso" → **mover**.
- "agrega la label X a <CLAVE-YY> / corrige la descripción de <CLAVE-YY>" → **editar**.
- "audita/revisa <CLAVE-XX> contra el estándar" → **auditar**.
- "qué hay en la label X / avance de <iniciativa>" → **consultar**.

Ante ambigüedad entre redactar y escribir en el tablero, **redacta**: crear y mover exigen petición explícita. Si el modo no se infiere con confianza, presenta 2-4 opciones con recomendación (regla de interacción); no asumas en silencio.

**Datos personales de terceros**: si el trabajo a redactar contiene datos de candidatos, entrevistas o evaluaciones (reclutamiento), declara que está **fuera de alcance** y explica el motivo; no lo produzcas. Esos issues se escriben a mano.

## 2. Modo REDACTAR (por defecto, no escribe)

Entrega un bloque listo para pegar con la plantilla estándar de trabajo de gestión. No escribe nada en Jira.

1. **Descripción**: cinco secciones H2 en orden fijo, con "Próximos pasos" siempre como checklist. **Declara la plantilla elegida y por qué**: si el proyecto documentó su propia plantilla observada, esa rige; esta es el estándar por defecto para trabajo de gestión.

   ```markdown
   ## Objetivo
   ## Contexto
   ## Alcance
   ## Entregable
   ## Próximos pasos
   - [ ] ...
   ```

2. **Título**: infinitivo español sin prefijo de clave (ej. "Revisar capacidades de la licencia de pruebas del proyecto"). Para series temáticas, forma nominal "Tema — Especificidad".
3. **Tipo**: el tipo gestionado configurado. Declara el tipo elegido y su razón, de modo que el usuario pueda corregirlo.
4. **Labels**: propón labels del catálogo en uso del proyecto. Si propones una label que no existe en ese catálogo, **decláralo explícitamente** como label nueva; no la introduzcas en silencio.
5. **Criterios de aceptación y estimación**: sigue la práctica documentada del tablero del proyecto. Si el proyecto no la documentó, omítelos en la plantilla de gestión y **declara** esa omisión, advirtiendo que el trabajo de desarrollo de producto suele exigir criterios de aceptación testeables según el DoD del proyecto.
6. Prosa en español (Chile); identificadores y comandos en inglés. Cero emojis. Nunca secretos ni datos personales.

**Ejemplo de referencia de este modo**: [`examples/task-compliant.md`](examples/task-compliant.md), con las cinco secciones en orden y datos sintéticos.

## 3. Modo CREAR (escritura al tablero, con gate)

Crea un issue real del tipo gestionado. Solo tras aprobación explícita.

1. **Acota al tipo gestionado**: si se pide crear otro tipo, declara que crear está acotado al tipo configurado y no lo hagas.
2. **Resuelve los campos en vivo** con `getJiraIssueTypeMetaWithFields` (proyecto y tipo configurados): obtén los campos obligatorios vigentes en vez de asumirlos.
3. **Fija el tipo por id**, no por nombre: pasa `issuetype` = `{"id": "<id configurado>"}`. Los nombres de tipo suelen ser ambiguos entre variantes ("Tarea", "Tarea Técnica", …) y la herramienta puede resolverlos a un tipo inválido.
4. **Label de gestión**: si el proyecto la definió, agrégala **siempre**, aunque la solicitud no la mencione. Se **suma** a las labels que la solicitud proponga; nunca las reemplaza ni las reordena, y aparece en el gate junto con las demás. Es una decisión del proyecto sobre su propio trabajo, no un requisito del tablero.
5. **Resuelve el assignee** según lo configurado: si el tablero exige assignee, pide el `accountId` al usuario o al catálogo del proyecto. Si el proyecto rechaza un accountId, prueba otro, declara el fallo y registra la evidencia en el catálogo del proyecto.
6. **Muestra el gate**: el contenido exacto (título, descripción con las cinco secciones, labels), el assignee y los campos con sus valores que se enviarán.
7. **Espera aprobación explícita**. Sin aprobación, no creas nada.
8. Crea con `createJiraIssue` e **informa la clave asignada**. Si la creación falla, reporta el error real; no asumas éxito.

## 4. Modo MOVER (transición de estado, con gate)

Mueve un issue del tipo gestionado por su workflow. Solo tras aprobación explícita.

1. **Acota al tipo gestionado**: verifica con `getJiraIssue` que el issue es del tipo configurado. Si es otro tipo, declara que mover está acotado y no lo hagas.
2. **Resuelve las transiciones en vivo** con `getTransitionsForJiraIssue`: no memorices identificadores. Ofrece solo las transiciones válidas desde el estado actual. La autoridad es la resolución en vivo, no el catálogo del proyecto.
3. **Muestra el gate**: estado actual, estado destino y la transición que usará.
4. **Espera aprobación explícita**. Sin aprobación, el estado no cambia.
5. Ejecuta con `transitionJiraIssue`. El resultado es **autoridad** sobre el éxito real: si falla (p. ej. una transición condicional que no cumple su condición), repórtalo; no asumas que quedó movido.

## 5. Modo AUDITAR (solo lectura)

Evalúa los issues que el usuario **indique explícitamente** contra el estándar del tablero del proyecto. El barrido masivo —por label o del tablero completo— está fuera de alcance.

1. Lee cada issue con `getJiraIssue`.
2. Por cada desvío, registra un Hallazgo: **Regla/convención** incumplida, **Ubicación** (campo o sección), **Severidad**, **Corrección sugerida** concreta.
3. Desvíos típicos: descripción que replica el título; falta de una de las cinco secciones o secciones fuera de orden; "Próximos pasos" que no es checklist; ausencia de labels (el issue queda invisible a toda agrupación); título con prefijo de clave; criterios de aceptación o estimación contrarios a la práctica documentada del tablero.
4. Si el issue **no es del tipo gestionado**, audítalo contra el estándar transversal aplicable y **declara que su tipo está fuera del alcance gestionado** por esta skill.
5. Formato fijo:

   ```text
   Veredicto: conforme | no-conforme
   Resumen: N hallazgos (alta: X, media: Y, baja: Z)

   | Regla/convención | Ubicación | Severidad | Corrección sugerida |
   |------------------|-----------|-----------|----------------------|
   ```

   Un issue conforme produce 0 hallazgos. Con al menos un secreto o dato personal detectado, severidad alta y veredicto no-conforme.

**Ejemplo de referencia de este modo**: [`examples/task-with-deviations.md`](examples/task-with-deviations.md), con desvíos **sembrados y conocidos de antemano**, de modo que una auditoría que no los encuentre todos está fallando.

## 6. Modo CONSULTAR (solo lectura)

Reporta el trabajo del tablero. Lee antes [`references/jql-traps.md`](references/jql-traps.md) (trampas de consulta en Jira Cloud).

> **Un resultado vacío no es un dato hasta que se sabe por qué está vacío.** Es la regla que gobierna este modo entero: la consulta **no valida el nombre del estado**, de modo que un cero puede significar "no hay trabajo" o "la consulta no coincidió con nada", y por defecto son indistinguibles. Ver `TR-01`.

### 6.1 Antes de consultar

1. **Resuelve el estado desde el catálogo de estados del proyecto** (parámetro configurado), no desde el nombre que escribió quien pregunta ni desde el que devolvió una lectura previa. **Consulta por `id`**: `project = <CLAVE> AND status = <id>`. Es la única forma que no depende de acertar el nombre.
2. **Si el estado no está en ese catálogo, no lo consultes a ciegas**: declara que no está resuelto, explica por qué un cero sería ambiguo, y ofrece una alternativa (listar los estados en uso, o consultar por categoría con sus trampas declaradas).
3. **Agrupa por label** con `project = <CLAVE> AND labels = <label>` cuando el proyecto use labels como agrupador.

### 6.2 Al reportar

4. **Declara siempre la consulta exacta que ejecutaste.** No es adorno: es lo que permite a quien lee detectar un vacío falso sin repetir el trabajo.
5. **Cuenta los cancelados por separado de los realizados**; nunca los agrupes como completados. Ver `TR-02`.

### 6.3 Cuando el resultado es cero

**Prohibido presentarlo sin calificar.** Distingue los tres casos:

| Caso | Cómo se declara |
| --- | --- |
| **Ausencia real** | "Cero issues. La consulta se resolvió; el estado existe y está vacío", con la consulta ejecutada |
| **Consulta no resuelta** | "La consulta no pudo resolverse: `<motivo>`". **Nunca** se reporta como ausencia |
| **No distinguible** | Se declara la ambigüedad y qué haría falta para resolverla. **No se elige la lectura optimista** |

6. **Verificación cruzada**: si un cero **contradice** lo que el catálogo del proyecto dice del tablero, verifica por una segunda vía antes de reportar y declara ambos resultados. No es doble consulta general: aplica solo cuando hay contradicción visible.

## 7. Modo EDITAR (escritura sobre issues existentes, con gate)

Cambia campos de un issue que ya existe. Solo tras aprobación explícita, **una operación a la vez**.

### La secuencia tiene tres pasos y no uno

1. **Lee** el valor actual del campo con `getJiraIssue`.
2. **Compone** el valor nuevo a partir del actual. Para `labels`: las existentes **más** la nueva.
3. **Escribe** con `editJiraIssue`, y después **relee el issue** y reporta el resultado de esa relectura — **nunca el acuse de la escritura**.

> **Los pasos 1 y 2 existen porque la herramienta reemplaza, no agrega.** El parámetro de `editJiraIssue` se llama `fields` y significa *"fields to set"*: escribir `{"labels": ["x"]}` sobre un issue que tenía cuatro labels **lo deja con una**. El toolset no expone la operación atómica de Jira (`update: {labels: [{add: "x"}]}`), de modo que **no hay forma de agregar sin leer**.
>
> **El fallo es silencioso y destructivo a la vez.** La escritura acusa éxito, el issue **sí** queda con la label pedida, y una verificación que pregunte *"¿la tiene?"* responde que sí. **Lo que se perdió no aparece por ninguna parte, porque nadie está preguntando por lo que ya no está.**

### El gate

4. **Muestra**: qué issue, qué campo, **su valor actual** y **su valor nuevo**, completos y literales.
5. **El gate es por operación.** No existe aprobación por lote, ni por bloques, ni *"para las que faltan"*. Diez issues son diez gates.
6. **Sin aprobación explícita, no se escribe.**

> **El gate por operación no es celo procedimental: es lo único que queda.** Esta skill **no acota la edición por campo** —ver abajo—, de modo que el gate es la única cosa entre una solicitud y una descripción reescrita. Una aprobación que cubra cientos de operaciones lo convierte en una firma en blanco.

### Verificación de cada operación

7. **Verifica por conjunto, no por presencia.** El resultado debe ser **exactamente el conjunto previo más el cambio pedido**. Preguntar *"¿tiene la label?"* **no basta**: eso lo responde que sí un issue al que se le borraron las otras tres.
8. **Una escritura fallida se nombra por clave con su motivo.** No se reintenta en silencio ni se omite del recuento.
9. **Un conjunto no se declara completo si alguna operación falló.**

### Lo que este modo NO garantiza, y hay que leerlo antes de usarlo

- **No hay restricción por campo.** `editJiraIssue` permite escribir título, descripción, assignee, labels y cualquier otro campo editable. **La skill no lo impide y no dice que lo impida**: lo que separa agregar una label de reescribir una descripción es **el gate**, no los permisos.
- **Hay una ventana de carrera.** Entre el paso 1 y el paso 3, otra persona puede cambiar el mismo campo y ese cambio se pierde. `editJiraIssue` **no acepta número de versión**, de modo que **no existe bloqueo optimista**. Se acota releyendo justo antes de escribir; **no se elimina**.
- **El changelog es verificación posterior, no control previo.** `getJiraIssue` con `expand: changelog` permite demostrar **después** que el único campo tocado fue el pedido. **Demuestra que no se tocó otro campo; no impide tocarlo.**

### Cuándo no usar este modo

- **Reclutamiento**: los issues con datos de candidatos siguen fuera de alcance para producir o modificar **contenido**. Agregar una label a uno de ellos no lee ni escribe su título ni su descripción, y eso sí es admisible.
- **Borrar**: ninguna herramienta de borrado está declarada y eso no cambia.
- **Volumen alto sin necesidad de traza**: si el objetivo es solo aplicar un cambio masivo, **el bulk edit de la interfaz de Jira lo hace mejor y en una operación**. Lo que este modo aporta y aquel no es el gate, la relectura y el registro por issue.

## Reglas de operación de la propia skill

- **Least privilege**: la skill declara lectura, `createJiraIssue`, `transitionJiraIssue` y `editJiraIssue`. **No borra issues**: ninguna herramienta de borrado está declarada, y eso no cambia. Si se pide borrar, declara que está fuera de alcance y no lo hagas.
- **Escritura solo con gate**: crear, mover y editar muestran antes lo exacto que harán y esperan aprobación explícita. Sin aprobación, el tablero queda intacto. **En editar el gate es por operación**: ver §7.
- **Resolución en vivo**: campos de creación (`getJiraIssueTypeMetaWithFields`) y transiciones (`getTransitionsForJiraIssue`) se resuelven en el momento, no de memoria; la configuración del proyecto puede cambiar.
- **Acceso en vivo**: ante fallo de acceso, detente, declara la falta de acceso y ofrece redactar sobre texto pegado; nunca degradar en silencio.
- **Nunca** proponer `git push`/`merge` sin confirmación explícita.
- Nunca emitas secretos ni datos personales en ninguna salida. Sin emojis, en ningún modo.

### Qué sostiene cada restricción

| Restricción | Garantía |
| --- | --- |
| **Editar solo el campo aprobado en el gate** | **Proceso** — `editJiraIssue` **está** declarada y **no distingue campos**. Lo que impide tocar el equivocado es el gate de §7, no el allowlist |
| **No borrar issues** | **Permisos** — ninguna herramienta de borrado está declarada |
| No tocar Confluence | **Permisos** — **ninguna** herramienta de Confluence está declarada, ni de lectura ni de escritura |
| **No producir archivos** | **Permisos** — `Write` y `Edit` no están declaradas |
| Crear y mover solo con gate | **Proceso** — `createJiraIssue` y `transitionJiraIssue` **están** declaradas, porque operar el tablero es el trabajo de esta skill |
| Acotar crear y mover al tipo gestionado | **Proceso** — el allowlist no distingue tipos de issue |
| Resolver campos y transiciones en vivo | **Proceso** — nada impide responder de memoria salvo esta instrucción |

> **Las restricciones de proceso son las que más importa auditar**, porque son las que gobiernan la escritura. Lo que las sostiene es el gate y la resolución en vivo, no la lista de herramientas. Una garantía de permisos la sostiene el motor y no se puede incumplir; una de proceso la sostiene una instrucción de este archivo, y una instrucción se puede ignorar del mismo modo en que se puede saltar un gate. Al auditar esta skill hay que decirlo así, sin presentar las de proceso como garantías de permisos.
