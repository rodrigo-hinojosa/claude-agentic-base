# Ejemplo — reporte del modo sincronizar

Este archivo muestra qué devuelve el modo sincronizar de la skill `development-repositories` en sus **tres resultados posibles**. Es material de referencia para quien implemente o revise el modo, no el registro de una corrida.

La forma de cada bloque la fija el contrato del modo sincronizar definido en el workspace de origen de esta skill; su portación a esta base quedó trazada en [`specs/002-portar-agentes/`](../../../../specs/002-portar-agentes/). Este ejemplo la instancia con datos sintéticos: la identidad de la página fuente va como placeholder (`<id-pagina>`) porque en esta plantilla está `Pendiente de configurar`.

## Todo el contenido de este ejemplo es sintético

**Ninguna de las dos diferencias que aparecen más abajo proviene de una fuente real.** En esta plantilla el catálogo `repositories.md` es una plantilla vacía, pendiente de poblarse al adoptar el proyecto, y no hay página fuente configurada: no existe un estado real contra el cual contrastar. En el workspace de origen este ejemplo distinguía entre el contenido real verificado del catálogo y las divergencias sembradas; aquí esa distinción se conserva como obligación —declarar qué es real y qué es sembrado—, aunque en esta base todo el contenido de los bloques sea construido.

Las divergencias se construyeron para mostrar la tabla poblada, que con un catálogo al día quedaría vacía. La versión `9` del encabezado del segundo bloque es parte de esa siembra.

| Elemento | Clase |
| --- | --- |
| El contenido del catálogo contra el que se contrasta | Sintético: en esta plantilla `repositories.md` está vacío, `Pendiente de configurar` |
| Las dos divergencias y la versión `9` de la fuente | **Sembradas** para el ejemplo |
| Las fechas, horas, nombres de repositorio y conteos de filas de los tres bloques | Construidos |
| El formato de los bloques | Ilustrativo: ninguna de estas corridas se ejecutó en esta base |

Distinguirlo importa porque el defecto que esta skill persigue es el contrario: presentar como hecho algo que nadie leyó.

---

## De dónde sale la versión del encabezado

Los tres bloques traen la **versión de la página leída**, porque es lo que permite a quien lee el reporte saber contra qué se comparó. Un encabezado sin versión real deja el reporte sin punto de comparación.

**La medición vive en [`provenance.md`](../provenance.md) §3 y acá se reproduce declarándolo** — réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`); la medición se hizo en el workspace de origen: `getConfluencePage` con `contentFormat: markdown` **no devuelve el número de versión** —entrega `lastModified` en forma relativa—, así que la versión se resuelve con una segunda consulta liviana que no trae el cuerpo:

```text
searchConfluenceUsingCql(cql = "id = <id-pagina>", expand = "content.version")
```

En el tercer resultado la versión también aparece, pero solo cuando esa segunda consulta sí respondió. Si lo que falló fue el acceso a la página entera, la línea `Fuente:` lo dice con `versión no resuelta` en vez de inventar un número.

---

## 1. Sin divergencias

El contraste corrió completo sobre las doce filas de la tabla y no halló diferencias.

```text
Sincronización — 07-09-2026 09:14
Fuente: página del catálogo en la fuente (id <id-pagina>), versión 8
Catálogo contrastado: repositories.md, relevamiento vigente R-20260907
Resultado: sin divergencias

El catálogo no fue modificado.
```

**Este resultado afirma algo**: que la lectura ocurrió y que el contraste no encontró diferencias. Por eso lleva versión: sin ella, no se distingue de una corrida que no leyó nada.

---

## 2. Dos divergencias

```text
Sincronización — 07-09-2026 09:14
Fuente: página del catálogo en la fuente (id <id-pagina>), versión 9
Catálogo contrastado: repositories.md, relevamiento vigente R-20260907
Resultado: 2 divergencias

| Repositorio           | Campo     | Valor en el catálogo | Valor en la fuente |
| --------------------- | --------- | -------------------- | ------------------ |
| ejemplo-backend-tests | Estado    | Activo               | En pausa           |
|                       | presencia | ausente              | ejemplo-validador  |

El catálogo no fue modificado.
```

**La primera fila es un contraste campo a campo**: el repositorio está en los dos lados y un campo difiere.

**La segunda fila es el evento que este modo existe para detectar.** Va con la celda `Repositorio` vacía y `Campo` en `presencia` porque es una divergencia de conjunto, no de un repositorio que el catálogo ya tenga: la fuente lista uno que el catálogo no conoce, y el nombre del repositorio nuevo se escribe en la columna de la fuente.

Ambos valores se escriben siempre, aunque uno sea `ausente`. Una celda en blanco no diría si el dato falta o si nadie lo miró.

**Por eso el parser recorre las doce filas de la tabla y no las ocho pobladas**, y por eso la regla es por presencia en la fuente, nunca por correspondencia con el catálogo. Formulada al revés, el modo sería ciego justo el día que un componente esperado que aún figura sin repositorio reciba el suyo (regla "Alcance de lectura" del contrato de origen; portación trazada en [`specs/002-portar-agentes/`](../../../../specs/002-portar-agentes/)).

---

## 3. No se pudo contrastar

```text
Sincronización — 07-09-2026 09:14
Fuente: página del catálogo en la fuente (id <id-pagina>), versión no resuelta
Catálogo contrastado: repositories.md, relevamiento vigente R-20260907
Resultado: no se pudo contrastar: conector atlassian sin autorizar

El catálogo no fue modificado.
```

**El tercer resultado nunca se presenta como el primero.** Un conector sin autorizar y un catálogo al día producen la misma salida vacía, y son indistinguibles salvo que la skill declare cuál es. Escribir "sin divergencias" cuando nadie leyó la fuente convierte una lectura fallida en una confirmación.

El motivo se escribe tal como se conoció, no interpretado. Tres motivos previstos:

| Motivo | Cómo se escribe |
| --- | --- |
| El conector no responde o no está autorizado | `no se pudo contrastar: conector atlassian sin autorizar` |
| La página no es accesible | `no se pudo contrastar: página <id-pagina> inaccesible` |
| La tabla esperada no aparece en la página | `no se pudo contrastar: tabla del catálogo no localizada por sus encabezados` |

El tercero no es hipotético: caso observado en el workspace de origen — la sección fuente ya se reestructuró una vez, y de ahí viene la regla de localizar la tabla por sus encabezados y no por su posición.

**Ante falta de acceso, el modo declara y se detiene.** No infiere el estado de la fuente ni reutiliza una lectura anterior.

---

## El cierre común a los tres

Los tres bloques terminan con la misma línea:

```text
El catálogo no fue modificado.
```

**El modo no escribe nada**: ni `repositories.md`, ni `provenance.md`, ni la página de Confluence. Incorporar una divergencia al catálogo es decisión de una persona, en una operación aparte, y esa operación actualiza además el relevamiento vigente que el encabezado cita.

Que la línea aparezca también en el bloque con divergencias es deliberado: es justo el caso en que alguien podría suponer que el reporte ya arregló lo que encontró.
