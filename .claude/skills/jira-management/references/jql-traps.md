# Trampas de consulta JQL en Jira Cloud

> **Fuente única (SSOT)** de las trampas de consulta que el modo consultar de `jira-management` debe conocer. Formas de consultar que devuelven un resultado **incorrecto** en cualquier instancia de Jira Cloud con nombres localizados. Cada una declara **cómo se manifiesta el fallo**, porque de eso depende que alguien pueda detectarlo.

## Procedencia

Réplica declarada, generalizada desde un catálogo relevado en un tablero real durante 2026 (caso ajeno citado; las claves y cifras de ese tablero no se portan). Los identificadores `TR-nn` se conservan porque otras skills los citan por número. **Las magnitudes concretas deben reobservarse en el tablero de cada proyecto**: lo portable es el mecanismo de cada trampa, no sus cifras.

## Taxonomía de manifestación

**La manifestación tiene tres formas, y la tercera es la peor:**

| Forma | Qué le pasa a quien la recibe | Por qué llega o no a un catálogo |
| --- | --- | --- |
| **Error** | Ve que algo falló | **Ruidosa.** Se corrige el día que aparece y rara vez necesita catálogo |
| **Vacío** | Ve un cero | Silenciosa. Pero **un cero al menos invita a dudar**: es raro, y alguien lo mira dos veces |
| **Resultado plausible** | Ve un número normal | Silenciosa **y convincente**. Un número bajo y coherente **no invita a nada** |

**Las siete trampas son silenciosas.** No es coincidencia: las ruidosas se corrigen solas el día que aparecen.

**Los identificadores `TR-nn` son correlativos y no se renumeran**, ni siquiera si una trampa se retira: las referencias cruzadas citan el número.

## Las trampas

### `TR-01` — El nombre de estado no se valida

- **Materia**: consultar issues por estado.
- **Qué falla**: `status = "<nombre localizado>"` (el nombre que la propia API devuelve en `status.name`) puede devolver `0` sin error, sin aviso y sin advertencia — indistinguible de "no hay trabajo en ese estado". Un nombre **inventado** devuelve exactamente lo mismo que un estado real vacío.
- **Forma correcta**: consultar por **id** (`status = <id>`), la única forma que no depende de acertar el nombre.
- **Consecuencias**:
  1. La consulta no valida el nombre: un cero nunca distingue por sí solo entre "no hay trabajo" y "la consulta no coincide con nada".
  2. "Usa el nombre en inglés" es insuficiente: los estados no traducidos funcionan con su nombre y los traducidos no, y **nada en la respuesta permite saber cuál es cuál**.
  3. El nombre que acepta la consulta no está en el issue: `status.name` trae el nombre traducido; el canónico aparece en `getTransitionsForJiraIssue`, o se evita consultando por id.

### `TR-02` — La categoría de estado agrupa cancelado con completado

- **Materia**: reportar avance.
- **Qué falla**: contar como trabajo terminado todo lo que cae en `statusCategory: done`. Los estados de cancelación suelen compartir esa categoría con los de completitud, y el conteo sale inflado sin ninguna señal.
- **Forma correcta**: contar el estado de completitud y el de cancelación **por separado y por id**; nunca sumarlos.

### `TR-03` — El operador `WAS` no valida el `accountId`

- **Materia**: averiguar si una cuenta es asignable en el proyecto, o si alguna vez tuvo issues asignados.
- **Qué falla**: `assignee WAS "<accountId>"` devuelve `0` sin error para tres situaciones categóricamente distintas: una cadena que ni siquiera es una cuenta, una cuenta que el proyecto rechaza como asignable, y una cuenta asignable que nunca se usó. Nada en la respuesta permite separarlas.
- **Forma correcta**: **no existe** consulta JQL que distinga los tres casos. La pregunta se cierra por vía externa: el endpoint `/user/assignable/search?project=<CLAVE>` en un navegador con sesión, o el selector de asignado de la interfaz.
- **Consecuencia operativa**: un `0` de este operador **no prueba nada** sobre la asignabilidad de una cuenta.

### `TR-04` — El campo de resolución no marca trabajo terminado

- **Materia**: contar el trabajo terminado del proyecto.
- **Qué falla**: `resolution IS NOT EMPTY` como marcador de completitud devuelve un **resultado plausible** — un número que se lee como dato, pero que depende de si los workflows del proyecto pueblan el campo al transicionar. En el tablero donde se observó, la consulta no solo subreportaba: la mayoría de lo que devolvía era trabajo **cancelado**, de modo que un reporte de productividad construido así medía cancelaciones y las presentaba como entregas.
- **Forma correcta**: contar **por estado y por id**, separando completado de cancelado (`TR-02`).
- **Notas**: `resolutiondate` no es alternativa — la prueba correcta de que ambos campos marcan el mismo conjunto son las dos diferencias (`resolution IS EMPTY AND resolutiondate IS NOT EMPTY` y su inversa, ambas en cero), no dos recuentos iguales. Si el campo se puebla o no suele depender del **tipo de issue** (cada tipo puede tener workflow y post-funciones distintas): verificarlo por tipo antes de confiar en él.

### `TR-05` — La categoría "Por hacer" absorbe el trabajo suspendido

- **Materia**: separar el trabajo no iniciado del trabajo detenido.
- **Qué falla**: leer `statusCategory: new` como "todavía no se empezó". Un estado de suspensión (Hold) puede tener categoría `new`, y un issue detenido por un bloqueo externo se cuenta como trabajo que nadie empezó — situaciones opuestas: una no arrancó, la otra arrancó y se trabó, y la segunda suele necesitar una decisión que la primera no.
- **Forma correcta**: contar los estados de suspensión **por separado y por id**.
- **La simetría es el hallazgo**: las tres categorías (`new`, `indeterminate`, `done`) pueden absorber estados de naturaleza distinta. Agrupar por categoría no es una simplificación: es una pérdida de información en las tres direcciones a la vez.

### `TR-06` — El nombre tampoco resuelve en resolución ni en categoría

- **Materia**: filtrar por valor de resolución o por categoría de estado.
- **Qué falla**: usar el nombre que la interfaz muestra (`resolution = "Listo"`, `statusCategory = "Listo"`) devuelve `0` sin error. **El cero no es un error de sintaxis**: JQL resuelve el nombre a *algún* valor de la instancia sin arrojar error — pero no al que el issue tiene. Falla resolviendo, no fallando.
- **Forma correcta**: por **id**, o por el **nombre canónico en inglés** (`resolution = "Done"`, `statusCategory = Done`).
- **Es `TR-01` sobre otros campos**: lo que `TR-01` documenta para el estado es cómo se comporta **todo campo con nombre localizado**.

### `TR-07` — Las transiciones no enumeran los estados

- **Materia**: averiguar qué estados existen en el proyecto.
- **Qué falla**: listar las transiciones (`includeUnavailableTransitions`) y tomar sus estados destino como el catálogo de estados devuelve una lista completa y coherente — y **falla en las dos direcciones**: puede **omitir** estados que existen y tienen issues, y puede **ofrecer** estados configurados que nadie usa. Cuántos enumera depende de cuántos issues se consulten, y no hay forma de saber cuándo se terminó.
- **Forma correcta**: **consultar la partición por estado**, estado por estado y por id, y verificar que suma el universo del proyecto. Sigue sin ser exhaustiva: un estado configurado sin issues es indetectable por este método, y se declara ese límite.

## La disciplina que detecta lo que nada más detecta

La trampa `TR-07` se descubrió **por aritmética**: una categoría sumaba más que sus estados conocidos, y la diferencia era un estado omitido. Ninguna consulta dio error, ninguna dio cero, ningún resultado se veía raro.

> **Cuadrar la partición contra el censo no es una formalidad de presentación: es el único detector que encuentra esta clase de fallo.** Toda consulta que particione el universo del proyecto (por estado, por categoría, por resolución) se publica cuadrada contra el total, y una suma que no cuadra se investiga antes de reportar.

## Referencias

- Modo consultar de la skill: [`../SKILL.md`](../SKILL.md) §6.
- Catálogo de estados del proyecto: parámetro por proyecto, `Pendiente de configurar` (ver `../SKILL.md`, Parámetros por proyecto).
