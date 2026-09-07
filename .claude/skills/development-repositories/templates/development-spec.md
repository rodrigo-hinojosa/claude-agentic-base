# Plantilla — Spec de desarrollo

> **Este archivo no es una spec: es el molde de una.** La spec que produce **no vive en este
> workspace**, sino en el repositorio del componente al que pertenece el desarrollo. El workspace
> solo guarda su puntero, en [`spec-index.md`](../spec-index.md).

| Campo | Valor |
| --- | --- |
| Naturaleza | Plantilla que se copia y se rellena |
| Destino del archivo producido | Repositorio del componente |
| Procedencia | Réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`, ver `specs/002-portar-agentes/`) |

---

## 1. Dónde se guarda la spec producida

```text
<repo del componente>/specs/<CLAVE-XXX>-<slug>/spec.md
```

| Elemento | Regla |
| --- | --- |
| `<repo del componente>` | Un repositorio del catálogo [`repositories.md`](../repositories.md). El workspace nunca es destino |
| `<CLAVE-XXX>` | La clave **real** del issue en Jira |
| `<slug>` | Descriptivo, en minúsculas, con guiones, sin acentos ni espacios |

**Sin clave de Jira no se crea la spec.** La skill no inventa la clave ni la deduce de la anterior: el
tablero crece con trabajo ajeno a este proyecto, así que el número se lee, no se predice. Cuando la
clave falta, la skill declara el vacío y remite a `jira-management` para crear el issue primero.

---

## 2. Cómo leer la plantilla

El bloque de la sección 3 se copia entero al archivo nuevo. Dentro de él rigen dos convenciones, y
distinguirlas es lo que evita que una instrucción quede publicada como si fuera contenido.

| Marca | Qué es | Qué hacer con ella |
| --- | --- | --- |
| Texto entre `<` y `>` | Contenido a reemplazar | Sustituir por el valor real y **borrar los signos** |
| Línea que empieza con `Guía:` | Instrucción para quien rellena | **Borrarla** del archivo producido |
| Encabezado `##` o `###` | Estructura obligatoria | Conservar tal cual, incluido el orden |

**Un archivo que conserva una línea `Guía:` o un `<marcador>` está incompleto.** Revisarlo es trabajo de quien usa la plantilla: **ningún script de esta skill lo detecta**, y no existe verificador de plantilla. Decirlo importa, porque prometer un mecanismo que no existe es peor que no tenerlo.

---

## 3. La plantilla

```markdown
# <CLAVE-XXX> — <Título en infinitivo>

| Campo | Valor |
| --- | --- |
| Issue | [<CLAVE-XXX>](<URL del issue en Jira>) |
| Componente | <componente, tal como lo nombra el catálogo> |
| Repositorio | <nombre exacto del repositorio en GitHub> |
| Estado | <uno de: abierta, en curso, cerrada, cancelada> |
| Abierta | <DD-MM-YYYY> |

## Contexto

Guía: por qué existe este desarrollo. Qué problema o necesidad lo origina, y qué pasa si no se hace.
Guía: dos a cuatro párrafos. No repitas la descripción del issue: enlázala arriba.

<Contexto>

## Alcance

Guía: qué se va a construir o modificar, en términos verificables. Nombra componentes, endpoints,
Guía: pantallas o flujos concretos, no intenciones.

<Alcance>

### Fuera de alcance

Guía: qué queda explícitamente afuera, con su motivo cuando no sea evidente.
Guía: esta subsección no se omite. Un alcance sin frontera no es verificable.

<Fuera de alcance>

## Criterios de aceptación

Guía: lista numerada. Cada criterio dice qué se observa y cómo se comprueba, de modo que dos personas
Guía: distintas lleguen al mismo veredicto. Sin criterios testeables la spec no está completa.

1. <Criterio observable, con su forma de comprobación>
2. <Criterio observable, con su forma de comprobación>

## Notas técnicas

Guía: dependencias, riesgos, decisiones ya tomadas y enlaces a ADR o documentación.
Guía: lo que no se pudo confirmar va marcado con su nombre: Pendiente, Por confirmar.

<Notas técnicas>
```

---

## 4. Reglas que rigen el archivo producido

1. **Las cinco secciones son obligatorias y van en ese orden**: Contexto, Alcance, Fuera de alcance,
   Criterios de aceptación, Notas técnicas. "Fuera de alcance" es subsección de Alcance y **no se
   omite**, porque un alcance sin frontera no se puede verificar.

2. **Los criterios de aceptación son obligatorios y testeables.** Lo exige el Definition of Done del
   proyecto para el trabajo de desarrollo de producto (dónde vive ese documento: `Pendiente de
   configurar` por proyecto). **Es la diferencia con la plantilla del board de gestión**, que los
   omite por decisión declarada de `jira-management`: ahí el trabajo es de gestión y esta plantilla
   no aplica.

3. **La tabla de metadatos enlaza a Jira, no copia el issue.** Ni la descripción, ni el estado del
   tablero, ni los comentarios. Una copia del issue caduca en silencio la próxima vez que alguien lo
   edita; el enlace no.

4. **El campo `Estado` es el de la spec como artefacto, no el del issue.** `abierta`, `en curso`,
   `cerrada` y `cancelada` describen el documento. El tablero es otra autoridad y se consulta aparte.

5. **Ningún dato sensible.** Sin credenciales, tokens, tenants, URLs autenticadas ni datos de clientes
   reales. Los ejemplos son siempre sintéticos.

6. **Español para la prosa, inglés para identificadores, rutas y comandos.** Es la convención del
   proyecto y aplica también dentro de los repositorios de producto.

7. **Un vacío se escribe con su nombre.** `Pendiente`, `Por confirmar` o `Sin información registrada`
   valen más que un relleno plausible.

---

## 5. Relación con el índice del workspace

Cada spec producida tiene **una** entrada en [`spec-index.md`](../spec-index.md), que guarda su clave,
repositorio, rama, ruta y estado. La entrada es el puntero; este archivo es el contenido.

**Si el estado de la tabla de metadatos y el del índice divergen, manda la spec.** El índice apunta y
la spec contiene, así que el índice se corrige contra el archivo, nunca al revés.

---

## 6. Ejemplo relleno

**La clave `ABC-000` es sintética y se eligió para que no apunte a un issue real.** No se afirma acá cómo numera Jira: no se midió, y la propiedad que importa —que sea reconocible como ejemplo— no depende de eso. Los nombres de repositorio, rama, endpoint y
persona son igualmente ficticios, y el dominio del enlace a Jira también.

Archivo: `ejemplo-backend/specs/ABC-000-validar-rut-en-registro/spec.md`

```markdown
# ABC-000 — Validar el RUT en el registro de usuario

| Campo | Valor |
| --- | --- |
| Issue | [ABC-000](https://ejemplo.atlassian.net/browse/ABC-000) |
| Componente | Backend / API |
| Repositorio | ejemplo-backend |
| Estado | en curso |
| Abierta | 02-09-2026 |

## Contexto

El registro acepta hoy cualquier cadena en el campo de RUT y la persiste sin comprobar su dígito
verificador. Eso produce cuentas que no se pueden cruzar con el maestro de clientes, y el costo
aparece después, en la conciliación.

La validación no existe en ningún punto del flujo: ni en el frontend ni en la API. Corregirla solo en
el frontend dejaría abierta la ruta directa a la API.

## Alcance

Validar el formato y el dígito verificador del RUT en el endpoint de registro de la API, antes de
persistir. Rechazar la solicitud con un error de validación cuando no cumpla, sin crear la cuenta.

Normalizar el valor almacenado a un formato único, sin puntos y con el dígito verificador en
mayúscula.

### Fuera de alcance

La corrección de los RUT ya almacenados. Es una migración de datos con su propio riesgo y su propia
ventana de ejecución, y se especifica aparte.

La validación en el frontend. Se aborda en una spec del repositorio de la interfaz, y esta no depende
de ella.

## Criterios de aceptación

1. Un registro con RUT de dígito verificador incorrecto recibe un error de validación y **no** crea
   cuenta. Se comprueba con una prueba automatizada sobre el endpoint.
2. Un registro con RUT válido escrito con puntos y guion queda persistido en el formato normalizado.
   Se comprueba leyendo el registro creado en la prueba.
3. Ningún mensaje de error devuelve el RUT recibido. Se comprueba inspeccionando el cuerpo de la
   respuesta en las pruebas de rechazo.
4. La cobertura de las rutas nuevas queda incluida en la suite que corre el pipeline del repositorio.

## Notas técnicas

El módulo de validación queda en el paquete de dominio, sin dependencias del framework HTTP, para que
las pruebas no necesiten levantar el servidor.

Pendiente: confirmar con el equipo de datos qué formato espera el maestro de clientes. Mientras no se
confirme, la normalización se aísla en una sola función para poder cambiarla en un punto.
```
