# Procedencia — qué relevamiento sostiene hoy cada dato

> **Registro vigente.** Dice contra qué lectura se puede comprobar cada campo de [`repositories.md`](repositories.md). El registro **histórico** de cada relevamiento vive fechado en `specs/`, no acá: este archivo lo **cita**, no lo reproduce.

Sin procedencia, un dato no es verificable: es recordado.

| Campo | Valor |
| --- | --- |
| Relevamientos vigentes | **0** |
| Relevamientos registrados en total | **0** |
| Última lectura de la fuente | Sin lectura registrada |
| Repositorios en el catálogo | Pendiente de materializar |
| Fecha de materialización del catálogo | Pendiente |
| Campos con sostén por confirmar | **0** (ningún campo poblado aún) |

---

## Procedencia de esta skill

**Réplica declarada de la portación, 07-09-2026 (feature 002-portar-agentes).** Esta skill proviene de una skill homóloga madurada en un workspace anterior, portada a esta base por la feature registrada en [`specs/002-portar-agentes/`](../../../specs/002-portar-agentes/). De ese origen se conservan los **mecanismos** —el patrón de identificadores (sección 4), la obtención del sello de versión (sección 3), la declaración de sostén de segunda mano (sección 2), las clases de autoridad (sección 5) y el procedimiento de relevamiento (sección 6)—, no los **datos**: ningún relevamiento ni fila de catálogo del workspace de origen viajó con la portación. Este proyecto parte con la serie de relevamientos vacía.

Los casos del workspace de origen que se citan más abajo se conservan solo porque explican decisiones de diseño vigentes, y están reformulados sin identificadores de ese workspace.

---

## 1. Relevamientos vigentes

**No hay.** La serie de esta skill comienza con el primer relevamiento que se ejecute contra la fuente que el proyecto configure como origen del catálogo (`Pendiente de configurar` en `repositories.md`). Cuando exista, se registra en una tabla con estas columnas:

- **Identificador** — según el patrón de la sección 4.
- **Fuente** — página o documento leído, con su enlace.
- **Leído** — fecha de la lectura real.
- **Estado de la fuente al leerla** — sello de versión, obtenido como indica la sección 3.
- **Aporta** — qué campos del catálogo sostiene esa lectura.

**El estado de la fuente es lo que hace posible sincronizar.** Sin él, "no hay cambios" no se distingue de "no se comparó".

El registro completo de cada lectura —método, universo y límites— vive fechado en `specs/`, en los artefactos de la feature que la ejecute; la tabla de esta sección lo cita por identificador, no lo reproduce. Cuando exista un segundo relevamiento, el primero no se borra ni se reescribe: queda como registro de lo que se sabía entonces.

### Qué debe declarar cada relevamiento

Cada relevamiento declara **qué campos transcribe fila por fila y cuáles no**. Un campo que la lectura no transcribió no puede reclamar sostén de esa lectura, aunque la lectura haya ocurrido.

Caso observado en el workspace de origen: una lectura registró la composición de la tabla fuente y seis de sus campos, pero no transcribió otros dos fila por fila; tiempo después, nada en el repositorio permitía afirmar que esos dos campos siguieran vigentes, aunque la lectura constaba como hecha.

---

## 2. Qué sostiene hoy cada campo

**Nada, todavía.** El catálogo no se ha materializado y ningún relevamiento se ha ejecutado. La tabla existe desde ya porque es la que cada relevamiento nuevo actualiza (sección 6):

| Campo del catálogo | Qué lo sostiene hoy | Fecha del sostén |
| --- | --- | --- |
| `Repositorio` | Pendiente — sin relevamiento ejecutado | — |
| `Componente` | Pendiente — sin relevamiento ejecutado | — |
| `Stack` | Pendiente — sin relevamiento ejecutado | — |
| `Estado` | Pendiente — sin relevamiento ejecutado | — |
| `Owner` | Pendiente — se resolverá como puntero, no como valor (sección 5) | — |
| `Notas` | Pendiente — sin relevamiento ejecutado | — |
| `Link` | Pendiente — sin relevamiento ejecutado | — |
| `Propósito` | Pendiente — sin relevamiento ejecutado | — |
| `Clase` | Derivación de esta skill, no dato de fuente | — |
| `Procedencia` | Campo interno de este archivo | — |

### Sostén de segunda mano

Un campo del catálogo puede quedar poblado desde un **registro local** —el cuerpo que el propio proyecto escribió en la fuente— en vez de una lectura en vivo posterior. Eso es admisible solo si se declara: el campo queda marcado como **sostén por confirmar**, con la fecha y el registro que lo sostienen, y el contador de la cabecera lo refleja.

- No es un dato inventado ni un dato verificado: es un dato con sostén de segunda mano, y así queda escrito.
- El registro local no es una fuente alternativa que compita con la fuente configurada: es el cuerpo que se escribió en ella.
- **Qué lo confirma**: la primera corrida del modo sincronizar con el conector disponible. Si la fuente cambió después del registro local, la diferencia se reporta como divergencia; no se resuelve en silencio.

Caso observado en el workspace de origen: dos campos poblados desde un registro local convivieron con una fuente que fue reestructurada dos veces después de ese registro. Lo desconocido no era si la fuente había cambiado —eso constaba en su historial de versiones—, sino si habían cambiado esas dos columnas en particular; solo la primera corrida de sincronizar podía resolverlo, y hasta entonces el límite quedó escrito, no disimulado.

---

## 3. De dónde sale el sello de versión

`estado_fuente` se puebla con el **número de versión** de la página. La ruta para obtenerlo no es la obvia, y por eso queda escrita.

**Medido en el workspace de origen**: `getConfluencePage` con `contentFormat: markdown` **no devuelve el número de versión**. Devuelve `lastModified` en forma relativa —del tipo `"ayer a las 11:42 p. m."`—, que no sirve como sello estable para comparar dos lecturas.

El número se obtiene con una segunda consulta, liviana porque no trae el cuerpo:

```text
searchConfluenceUsingCql(cql="id = <page-id>", expand="content.version")
```

**La garantía central de sincronizar depende de un dato que la vía declarada no entrega.** El reporte de sincronización declara ambas cosas: la versión leída y con qué consulta se obtuvo. Sin el sello, "no hay cambios" y "no se comparó" producen la misma salida.

Si la fuente que el proyecto configure no es una página de Confluence, el requisito se mantiene igual: toda fuente debe ofrecer un sello de estado comparable entre lecturas, y la consulta concreta para obtenerlo se documenta en esta sección al configurarla.

---

## 4. El identificador y su límite heredado

El patrón es `R-YYYYMMDD`, con la fecha de la **lectura real**. Fechar una lectura en un día en que no ocurrió es procedencia falsa, y una procedencia falsa es peor que ninguna, porque parece verificable. La formulación proviene de una skill hermana del workspace de origen, de donde esta skill hereda el patrón entero; se declara por eso y no se presenta como criterio propio.

**El patrón no admite dos relevamientos el mismo día.** Caso observado en el workspace de origen: el límite se desambiguó a mano con un sufijo de fuente y secuencia —identificadores de la forma `R-YYYYMMDD-<FUENTE>-<NN>` distinguen dos lecturas del mismo día sobre fuentes distintas—. Esta skill adopta el patrón **sin sufijo mientras no necesite dos relevamientos en la misma jornada**; el día que los necesite, esa forma es el precedente a seguir.

El patrón se adopta con el defecto incluido y declarado. Cambiarlo después de registrado el primer relevamiento tocaría la traza de todos los anteriores, así que cualquier corrección del patrón es una decisión transversal del repositorio, no un arreglo local de esta skill.

---

## 5. Clase de autoridad de cada campo

**Operativo** significa que este catálogo sostiene el valor y responde por él. **Citado** significa que el valor remite a otra fuente, que es su autoridad.

| Campo | Clase de autoridad | Autoridad |
| --- | --- | --- |
| `Repositorio` | Operativo | Este catálogo, sostenido por el relevamiento vigente (sección 1) |
| `Componente` | Operativo | Este catálogo, sostenido por el relevamiento vigente (sección 1) |
| `Clase` | Operativo, **derivado** | Esta skill. No es dato de la fuente y se marca como derivación en el catálogo |
| `Link` | Operativo | Este catálogo, sostenido por el relevamiento vigente; si se puebla desde un registro local, rige la sección 2 |
| `Stack` | Operativo | Este catálogo, sostenido por el relevamiento vigente (sección 1) |
| `Propósito` | Operativo | Este catálogo, sostenido por el relevamiento vigente; si se puebla desde un registro local, rige la sección 2 |
| `Estado` | Operativo | Este catálogo, sostenido por el relevamiento vigente (sección 1) |
| `Owner` | **Citado** | La skill de dominio de equipo que el proyecto defina (`Pendiente de configurar`). El catálogo guarda un puntero, nunca el nombre con sus atributos |
| `Notas` | Operativo | Este catálogo, sostenido por el relevamiento vigente (sección 1) |
| `Procedencia` | Operativo | Este archivo |

Mientras no exista relevamiento, "sostenido por el relevamiento vigente" resuelve a `Pendiente`: ningún campo Operativo tiene sostén hoy, y el catálogo no debe presentar filas como verificadas. La regla del repositorio sobre punteros y réplicas (`.claude/rules/09-punteros-y-replicas.md`) es la que sostiene la distinción Operativo/Citado.

---

## 6. Qué hacer cuando se ejecute un relevamiento nuevo

1. Se registra su histórico fechado en `specs/`, con su método, su universo y sus limitaciones.
2. Se agrega a la tabla de la sección 1 con su identificador y el estado de la fuente al leerla, obtenido por la consulta de la sección 3.
3. **El anterior no se borra ni se reescribe**: queda como registro de lo que se sabía entonces.
4. Los campos del catálogo que cambien de sostén actualizan su cita en las tablas de las secciones 2 y 5.
5. Si es el segundo del mismo día sobre la misma fuente, lleva sufijo de secuencia, por el límite de la sección 4.

Un relevamiento nuevo **no resuelve divergencias**. Si el catálogo y la fuente siguen discrepando, la diferencia queda registrada en [`divergences.md`](divergences.md), que no tiene campo de resolución.
