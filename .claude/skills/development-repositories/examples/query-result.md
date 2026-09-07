# Ejemplo — salida del modo consultar

Este archivo muestra qué devuelve el modo consultar de la skill `development-repositories` ante tres preguntas distintas. Es material de referencia para quien implemente o revise el modo, no un registro de una corrida.

Lo que sigue es la **vista que devuelve el modo**, no el archivo [`repositories.md`](../repositories.md) completo.

**El catálogo tiene diez columnas y esta vista muestra seis.** Las cuatro que omite y por qué:

| Columna omitida | Por qué |
| --- | --- |
| `Link` | Se deriva del nombre: `https://github.com/<organizacion>/<repositorio>`. La organización del hosting es parámetro del proyecto: `Pendiente de configurar` |
| `Procedencia` | Es la misma para las ocho filas, y va una sola vez en el encabezado |
| `Owner` | No se pidió. Una consulta por owner sí lo trae |
| `Notas` | Vacía en siete de las ocho filas del ejemplo |

**`Propósito` sí va en la vista**: la consulta de conjunto responde con cinco campos — componente, clase, stack, propósito y estado. Caso observado en el workspace de origen: esta columna estuvo omitida del ejemplo durante un tiempo, y era una omisión silenciosa — una sesión que siguiera el ejemplo al pie producía una respuesta a la que le faltaba uno de los cinco campos esperados.

## Qué es real y qué está construido

| Elemento | Clase |
| --- | --- |
| El contenido del catálogo que se muestra | Sintético: construido para la portación; el catálogo real se releva en la primera adopción del proyecto (`Pendiente de configurar`) |
| El formato de los bloques de salida | Ilustrativo: ninguna de estas respuestas proviene de una corrida real |
| Las preguntas del usuario | Construidas para el ejemplo |

En el workspace de origen este ejemplo mostraba contenido real, verificado contra su fuente con relevamiento fechado. Al portar la skill, ese contenido se sustituyó por datos sintéticos; cuando el proyecto releve su catálogo, conviene regenerar este ejemplo con contenido real y su procedencia.

Distinguirlo importa porque el defecto que esta skill persigue es exactamente el contrario: presentar como hecho algo que nadie leyó.

---

## 1. Consulta de conjunto — qué repositorios hay

> **Pregunta:** ¿cuáles son los repositorios del proyecto y cuál es el de frontend?

El modo resuelve contra el catálogo del repositorio. **Cero llamadas a Confluence**: esa es su razón de existir.

```text
Vista del catálogo — 8 repositorios
Procedencia de todas las filas: R-20260101 (sección de repositorios de la fuente, versión 1, leída el 01-01-2026)

> Fuente única (SSOT) operativa de los repositorios de desarrollo y QA del proyecto
> dentro de este repositorio. Réplica declarada de la sección de repositorios del
> espacio de documentación del proyecto, con procedencia por dato.
>
> Es descriptivo, no normativo: registra qué repositorios existen, no cuál es el
> repositorio oficial ni qué CI/CD rige — esa decisión sigue abierta (ver la sección
> de decisiones abiertas de la fuente).

| Repositorio | Componente | Clase* | Stack | Propósito** | Estado |
| --- | --- | --- | --- | --- | --- |
| ejemplo-frontend | Frontend / Login UI | desarrollo | Web Application - ReactJS | Frontend web de login, registro y recuperación | Activo |
| ejemplo-backend | Backend / API | desarrollo | Api - Go | API que orquesta la integración con el proveedor de identidad y los servicios del proyecto | Activo |
| ejemplo-qa | QA automation | qa | Test Repo | Repositorio base de QA del proyecto | Activo |
| ejemplo-qa-performance-tests | QA automation | qa | Test Repo | Pruebas de rendimiento y carga | Activo |
| ejemplo-qa-e2e-app-tests | QA automation | qa | Test Repo | Pruebas E2E de la aplicación | Activo |
| ejemplo-qa-2e-web-tests | QA automation | qa | Test Repo | Pruebas E2E web | Activo |
| ejemplo-qa-api-tests | QA automation | qa | Test Repo | Pruebas de API | Activo |
| ejemplo-qa-contract-tests | QA automation | qa | Test Repo | Pruebas de contrato | Activo |

*  Clase es derivación del componente, no dato de la fuente.
** Propósito tiene origen `redactado`: lo escribió el equipo del proyecto para la página de documentación, y no proviene del sistema de origen de los demás datos.

Frontend: ejemplo-frontend.
```

**El callout viaja con la vista, con sus dos declaraciones.** La segunda no es adorno: sin ella, el catálogo resolvería de hecho una decisión que el proyecto tiene explícitamente abierta.

**El `Estado` de la tabla es el de la fuente**, no el del repositorio en el hosting de código. Caso observado en el workspace de origen: repositorios que figuraban `Activo` en la fuente estaban vacíos en el hosting al momento del relevamiento. El catálogo no resuelve esa contradicción y tampoco la esconde: la nombra donde corresponde.

**`ejemplo-qa-2e-web-tests` se muestra literal.** El nombre reproduce, con datos sintéticos, un caso observado en el workspace de origen: un repositorio cuyo nombre real contenía la errata `2e` en lugar de `e2e`. La regla es mostrarlo tal cual: corregirlo en la vista haría que el usuario copiara un nombre inexistente (ver [`repositories.md`](../repositories.md)).

---

## 2. Consulta que el catálogo no resuelve — el repositorio oficial y el CI/CD

> **Pregunta:** ¿cuál es el repositorio oficial del proyecto y qué CI/CD rige?

El modo **no responde con el catálogo**. Declara que es una decisión abierta del proyecto y entrega el puntero.

```text
Esta pregunta no la resuelve el catálogo.

Cuál es el repositorio de código oficial del proyecto y cuál su CI/CD es una
decisión abierta. La propia fuente lo declara: "Esta tabla es un inventario observado,
no una declaración de oficialidad."

Puntero del pendiente: la sección de decisiones abiertas del espacio de
documentación del proyecto (URL: Pendiente de configurar).

Lo que sí puedo responder es qué repositorios existen y qué componente atiende cada uno
(consulta de conjunto).
```

**Responder con la tabla convertiría en norma algo que el proyecto tiene en suspenso.** Ocho nombres presentados ante una pregunta por lo oficial se leen como la respuesta, aunque ninguna frase lo afirme. El criterio de falla de este modo es justamente que la skill nombre repositorios como si fueran el estándar.

---

## 3. Consulta sin resultados — el vacío se califica

Un resultado vacío nunca se entrega como un cero pelado. La respuesta declara **cuál de los dos casos es**, porque desde afuera se ven igual (regla del vacío calificado; la procedencia del diseño de esta skill queda trazada en `specs/002-portar-agentes/`).

### 3.1 Ausencia real en el catálogo

> **Pregunta:** ¿qué repositorio cubre el bridge de sincronización de clientes?

```text
Sin resultados — ausencia real en el catálogo.

"Bridge de sincronización de clientes" es una de las filas de la fuente que figuran
sin repositorio, en estado "Por definir". No es una fila que falte en el catálogo:
es un componente esperado que todavía no tiene repositorio.

El modo sincronizar vigila esas filas. El día que una reciba repositorio,
lo reporta como divergencia de presencia.
```

### 3.2 Consulta no resuelta

> **Pregunta:** ¿qué repositorios están en estado `Deprecado`?

```text
Sin resultados — consulta no resuelta.

El valor "Deprecado" no es uno de los estados presentes en el catálogo, así que este
cero no dice que no haya repositorios deprecados: dice que la consulta no encontró ese
valor. Los estados presentes hoy en las ocho filas son: Activo.

Reformula con un estado del catálogo, o pide la vista de conjunto.
```

**La diferencia entre 3.1 y 3.2 es la que hace útil el modo.** El primero afirma algo del catálogo; el segundo afirma algo de la consulta. Confundirlos produce un resultado plausible pero falso — exactamente la clase de defecto que esta skill existe para impedir.

---

## Referencias

- Catálogo consultado: [`repositories.md`](../repositories.md).
- Procedencia de los relevamientos: [`provenance.md`](../provenance.md).
- Contrato de forma del catálogo y regla del vacío calificado: procedencia del diseño trazada en `specs/002-portar-agentes/`.
- Este ejemplo es réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`); el contenido real del origen se sustituyó por datos sintéticos.
