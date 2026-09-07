> **Fuente única (SSOT) operativa** de los repositorios de desarrollo y QA del proyecto dentro de este repositorio. Réplica declarada de la sección correspondiente de la fuente externa del proyecto (`Pendiente de configurar`), con procedencia por dato, conforme a `.claude/rules/09-punteros-y-replicas.md`.
>
> **Es descriptivo, no normativo**: registra qué repositorios existen, no cuál es el repositorio oficial ni qué CI/CD rige. Si esa decisión sigue abierta en el proyecto, su puntero en la fuente externa se registra aquí: `Pendiente de configurar`.
>
> **Estado: plantilla sin poblar.** Este archivo es una réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`, ver `specs/002-portar-agentes/`). No contiene ninguna fila de datos del workspace de origen: la estructura, las reglas y las guardas se conservan; los datos los aporta cada proyecto al adoptar la skill (ver §9).

# Catálogo de repositorios de desarrollo

| Campo | Valor |
| --- | --- |
| Naturaleza | Cuerpo de datos versionado, réplica declarada — plantilla sin poblar |
| Fuente | `Pendiente de configurar` (sección e identificador de página de la fuente externa) |
| Relevamiento vigente | `Pendiente de configurar` (formato `R-YYYYMMDD`, detalle en [`provenance.md`](provenance.md)) |
| Escrito | `Pendiente de configurar` (se fija al poblar) |
| **Repositorios en el catálogo** | **0** (plantilla) |
| Filas de la tabla en la fuente | `Pendiente de configurar` (incluye las filas sin repositorio, ver §6.2) |
| Organización de GitHub | `Pendiente de configurar` |
| Contrato de forma | `Pendiente de configurar` — el proyecto que adopte la skill define su contrato; la procedencia del diseño de este catálogo vive en `specs/002-portar-agentes/` |

Recomputable:

```bash
# Repositorios en el catálogo
# Desde la raíz del repositorio. La ruta relativa importa: corrido desde otro
# directorio, `sed` no encuentra el archivo y el conteo sale 0.
sed -n '/^## 1\./,/^## 2\./p' \
  .claude/skills/development-repositories/repositories.md | grep -cE '^\| [a-z0-9]'
```

Sobre la plantilla sin poblar, el conteo debe salir **0**. Al poblar, reemplaza el patrón `'^\| [a-z0-9]'` por el prefijo real de los repositorios del proyecto (por ejemplo `'^\| <prefijo>-'`): anclar el conteo al prefijo evita que una celda con otra forma infle o desinfle la cifra.

**El barrido se acota a la sección 1 a propósito.** Otras secciones nombran repositorios en prosa o en ejemplos, y un `grep` sobre el archivo entero devolvería una cifra mayor que parecería correcta.

---

## 1. Los repositorios

`Pendiente de configurar` — cero filas. La tabla se puebla según el procedimiento de §9; la fila de ejemplo sintética vive allá, fuera del rango del conteo recomputable.

| Repositorio | Componente | Clase (derivada) | Link | Stack | Propósito (con marca de origen) | Estado | Owner (puntero) | Notas | Procedencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

**Las celdas `Notas` vacías se escriben vacías.** Un vacío no se completa con inferencia ni con buenas prácticas; lo fija `.claude/rules/01-prevencion-alucinaciones.md` ("los vacíos se nombran, no se tapan").

**El directorio local no es columna de esta tabla.** Se deriva del nombre del repositorio sin transformar, al operar, y su regla vive en [`layout.md`](layout.md) §4. Guardarlo acá crearía un segundo lugar donde el mismo dato puede divergir.

---

## 2. `Clase` es derivación, no dato de la fuente

La fuente externa no trae una columna de clase. El valor `desarrollo` o `qa` lo deriva este catálogo del componente de cada fila, y se marca como derivación para que nadie lo cite como afirmación de la fuente.

El mapeo componente → clase lo define cada proyecto al poblar. `Pendiente de configurar`:

| Componente en la fuente | Clase derivada |
| --- | --- |

Ejemplo sintético de mapeo (no es dato): un componente "Frontend / Login UI" o "Backend / API" derivaría `desarrollo`; un componente "QA automation" derivaría `qa`.

**Si la fuente cambia el componente de una fila, la clase cambia con él.** No es un campo editable por su cuenta, y sincronizar no lo compara contra la fuente porque allá no existe.

---

## 3. `Owner` es un puntero a la skill de personas del proyecto

La celda registra una referencia a la persona en la skill de dominio de personas que el proyecto defina (`Pendiente de configurar`), no su ficha. **Ningún atributo de persona entra a este catálogo**: los datos de contacto, los identificadores de cuenta y la posición organizacional viven en ese catálogo y solamente allá. Duplicarlos acá crearía una copia del roster que se desincroniza en silencio.

El nombre que aparece en la celda es la **llave de resolución**, no un dato copiado del roster. Se lee como "resuelve contra la skill de personas del proyecto", igual que un identificador de relevamiento se lee como "resuelve contra `provenance.md`".

> **Los tres atributos prohibidos se describen por su clase y no se nombran uno por uno, y no es descuido de redacción.** La verificación prevista es un `grep` de esas tres palabras exactas sobre este archivo, y espera cero resultados. Escribirlas acá haría que la prohibición se denunciara a sí misma, con un hallazgo indistinguible de un dato de persona filtrado. Es el mismo blindaje por clase que se observó en el workspace de origen, donde un detector se detectaba a sí mismo hasta que se redactó por clase.

### 3.1 Regla de resolución del nombre

1. La resolución es contra el directorio de la skill de personas del proyecto (`Pendiente de configurar`), **aceptando la forma abreviada** del nombre si ese directorio define una columna de nombre corto: esa forma es la que este catálogo usa.
2. **Una diferencia de forma del nombre no es divergencia de owner.** Que la fuente escriba el nombre en forma corta y el directorio en forma completa es la misma persona escrita de dos maneras.
3. **Sí es divergencia** que la fuente nombre a alguien que no resuelve a ninguna persona del directorio. Ese caso se registra en [`divergences.md`](divergences.md).
4. Si el owner entrante es una organización y no una persona, el puntero queda vacío y el valor se registra como texto con su marca de origen. La skill de personas es autoridad de personas, no de equipos.

**Sin la regla 2, sincronizar reportaría una divergencia de owner en cada corrida sobre filas correctas.** Ese es el resultado plausible y falso que el workspace de origen documentó como modo de fallo con nombre propio.

### 3.2 Verificación de resolución

`Pendiente de configurar` — se completa al poblar, contrastando cada nombre contra el directorio de la skill de personas del proyecto **antes** de escribir la tabla, y dejando registro con esta forma:

| Nombre en la celda | Resuelve en el directorio | Resultado |
| --- | --- | --- |

La verificación se hace contra el archivo del repositorio, no contra la fuente externa en vivo.

---

## 4. `Propósito` lleva marca de origen

Cuando el texto de `Propósito` no proviene literal de la fuente —porque la fuente trae vacía su columna de descripción y el texto lo redactó el equipo—, la fila conserva la marca de origen `redactado`.

**Perder esa marca convertiría una propuesta del equipo en un hecho.** Caso observado en el workspace de origen: la hoja de servicios de la que salía la tabla traía vacía la descripción en todas sus filas, y el texto publicado era redacción del equipo; la marca era lo único que lo distinguía de un dato de la fuente. La marca se evalúa fila por fila y no se generaliza: una fila puede traer descripción propia de la fuente, y entonces su origen es otro.

---

## 5. El nombre del repositorio no se corrige

El nombre de cada repositorio se transcribe **literal desde GitHub**, aunque parezca contener un error de tipeo. Caso observado en el workspace de origen: un repositorio cuyo nombre real en GitHub llevaba un literal aparentemente erróneo; "corregirlo" en el catálogo habría producido dos daños. El primero es que el catálogo dejaría de coincidir con el repositorio real, y todo clon derivado de él apuntaría a un nombre que no existe. El segundo es que una enmienda silenciosa borra la única señal de que la fuente y GitHub podrían discrepar.

**Si alguna vez el nombre de GitHub y el de la fuente difieren, eso es divergencia a reportar** en [`divergences.md`](divergences.md), nunca una edición de esta tabla. Una anotación de este tipo va en la celda `Notas`, marcada como "anotación de esta skill, no texto de la fuente".

---

## 6. Qué no entra a este catálogo

### 6.1 El repositorio workspace

El repositorio desde el que esta skill opera **no entra bajo ninguna circunstancia**, y el motivo es doble. No pertenece a la sección de la fuente que forma este catálogo, y es el punto de operación: nunca es objetivo de una operación de clonado, actualización o lectura de estado.

La exclusión está sostenida además por los scripts, que excluyen ese nombre de forma explícita ([`layout.md`](layout.md) §2). Una garantía que dependiera solo de que la fuente nunca lo liste sería más frágil de lo necesario.

### 6.2 Las filas sin repositorio

Si la tabla de la fuente trae filas que dicen "Sin repositorio", son componentes esperados, no repositorios: no se clonan, no se actualizan y no tienen nada que orquestar. Se registran acá con esta forma (`Pendiente de configurar` al poblar):

| Componente | Estado en la fuente | Owner en la fuente | Procedencia |
| --- | --- | --- | --- |

**Se listan acá para que su ausencia del catálogo no parezca un olvido.** Los owners de estas filas suelen ser organizaciones y no personas: en ese caso ninguno resuelve contra la skill de personas ni debe forzarse a hacerlo (§3.1, regla 4).

**El modo sincronizar sí mira estas filas.** El día que una reciba repositorio, eso es una divergencia de presencia, y detectarla exige recorrer la fuente entera y no solo las entradas de la sección 1.

---

## 7. Cómo se consulta y cómo se actualiza

**El catálogo no se deriva en vivo.** Consultar resuelve contra este archivo y no abre la fuente externa; solo el modo sincronizar lee la fuente, y reporta las diferencias sin aplicarlas. Incorporar un cambio es decisión de una persona.

**Un resultado vacío se califica siempre.** Una consulta que no devuelve filas dice si es ausencia real en el catálogo o una consulta que no se resolvió, porque las dos son indistinguibles por defecto.

---

## 8. Procedencia y divergencias

**El detalle del relevamiento vive en [`provenance.md`](provenance.md)**: identificador, fuente enlazada, fecha de lectura, sello de versión de la página y qué campos aporta cada lectura. Acá no se reproduce.

**Las diferencias entre catálogo y fuente viven en [`divergences.md`](divergences.md)**, con su identificador `DIV-nn` y sin campo de resolución. Registrar una diferencia y decidir qué hacer con ella son actos distintos.

---

## 9. Cómo se puebla por proyecto

Procedimiento derivado de la estructura del catálogo de origen. Cada paso deja rastro; ninguno se salta.

1. **Configurar la fuente.** Completar en la tabla de metadatos la fuente externa (sección e identificador de página), la organización de GitHub y el contrato de forma del proyecto. Mientras algo siga en `Pendiente de configurar`, el catálogo no se considera poblado.
2. **Relevar.** Leer la fuente, asignar un identificador `R-YYYYMMDD` y registrar el relevamiento en [`provenance.md`](provenance.md) con fecha de lectura y sello de versión.
3. **Poblar la sección 1.** Una fila por repositorio, con el nombre **literal de GitHub** (§5), su procedencia (`R-YYYYMMDD`) en cada fila, y las celdas sin dato **vacías** (§1). `Propósito` lleva su marca de origen cuando corresponda (§4).
4. **Definir el mapeo componente → clase** en §2. La clase no se edita por fila: se deriva.
5. **Resolver los owners** contra la skill de personas del proyecto y registrar la verificación en §3.2. Owners organizacionales quedan como texto con marca de origen, sin puntero (§3.1, regla 4).
6. **Registrar las filas sin repositorio** en §6.2, si la fuente las trae.
7. **Ajustar el conteo recomputable** al prefijo real de los repositorios, correr el comando desde la raíz y verificar que la cifra coincida con la celda **Repositorios en el catálogo**.
8. **Registrar divergencias** en [`divergences.md`](divergences.md) desde la primera corrida de sincronizar; la tabla nunca se enmienda en silencio.

Fila de ejemplo, **sintética y solo ilustrativa** — no es dato y no se copia al catálogo:

```markdown
| ejemplo-backend | Backend / API | desarrollo | https://github.com/<organizacion>/ejemplo-backend | Api - Go | API que orquesta la integración con el proveedor de identidad | Activo | <skill-de-personas> → Nombre Apellido | | R-YYYYMMDD |
```
