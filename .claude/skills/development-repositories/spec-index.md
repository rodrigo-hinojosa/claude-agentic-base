> **Índice de punteros**, no de contenido. Cada entrada dice dónde vive una spec de
> desarrollo; el contenido vive en el repositorio del componente y **no se reproduce acá**.

# Índice de specs de desarrollo

| Campo | Valor |
| --- | --- |
| Naturaleza | Cuerpo de datos versionado, puntero puro |
| Qué registra | Dónde vive cada spec de desarrollo y en qué estado está como artefacto |
| Dónde vive el contenido | En el repositorio del componente, en la rama y ruta que indica cada fila |
| Escrito | 07-09-2026 — réplica declarada de la portación (feature `002-portar-agentes`) |
| **Entradas registradas** | **0** |
| Contrato de forma | La forma la fija este archivo; la procedencia del diseño queda trazada en `specs/002-portar-agentes/` |
| Verificador | [`scripts/check-spec-pointers.sh`](scripts/check-spec-pointers.sh), de ejecución manual |

Recomputable:

```bash
# Entradas registradas — <CLAVE> es la clave Jira del proyecto (Pendiente de configurar)
sed -n '/^## 1\./,/^## 2\./p' .claude/skills/development-repositories/spec-index.md | grep -cE '^\| \[?<CLAVE>-'
```

**El barrido se acota a la sección 1 a propósito.** Las secciones siguientes citan claves de ejemplo en prosa, y un `grep` sobre el archivo entero devolvería una cifra mayor que parecería correcta.

---

## 1. Entradas

| Clave | Slug | Repositorio | Rama | Ruta | Estado | Abierta | Actualizada |
| --- | --- | --- | --- | --- | --- | --- | --- |

**Sin entradas al 07-09-2026 porque la skill recién se porta a esta base**, no porque no se haya podido leer una fuente. La primera entrada la escribe el modo especificar cuando cree la spec de un desarrollo con clave de Jira ya emitida.

Un índice vacío por adopción reciente y un índice vacío por lectura fallida se ven igual en pantalla. Por eso el estado se califica acá y el verificador avisa por `stderr` cuando una corrida no verificó ninguna entrada.

---

## 2. Las ocho columnas

| Columna | Qué contiene | Forma |
| --- | --- | --- |
| Clave | Clave real del issue en Jira, enlazada al issue | `<CLAVE>-XXX` |
| Slug | Descriptor corto del desarrollo | Minúsculas, palabras separadas por guion |
| Repositorio | Nombre del repositorio del componente | Debe existir en [`repositories.md`](repositories.md) |
| Rama | Rama de ese repositorio donde vive la spec | Nombre de rama tal como existe en el repositorio |
| Ruta | Ubicación de la spec dentro de ese repositorio | Relativa a su raíz: `specs/<CLAVE>-XXX-<slug>/spec.md` |
| Estado | Estado de la spec como artefacto | `abierta` \| `en curso` \| `cerrada` \| `cancelada` |
| Abierta | Fecha en que se creó la entrada | `DD-MM-YYYY` |
| Actualizada | Fecha del último cambio a la fila | `DD-MM-YYYY` |

**La clave se lee del tablero, nunca se predice.** Un número de issue no se infiere del anterior, y una entrada con clave provisional apunta a un issue que puede no existir. Sin clave emitida no hay entrada: el vacío se declara y se remite a `jira-management`.

**`Repositorio` es un nombre del catálogo, no una URL.** El enlace de cada repositorio vive en `repositories.md` y acá se cita por nombre, para que una sola fila del catálogo siga siendo la autoridad de su ubicación.

---

## 3. Reglas del índice

1. **Ninguna celda contiene contenido de la spec** — ni resumen, ni criterios, ni alcance. Solo el puntero y su estado. Un resumen es una réplica que caduca en silencio.
2. **Una entrada `cerrada` o `cancelada` no se borra.** El índice es traza, y borrar una fila reescribe historia en vez de superarla.
3. **`cerrada` y `cancelada` son terminales.** Reabrir un desarrollo exige una entrada nueva que cite la anterior por su clave; no se revierte el estado de la fila existente.
4. **Si el repositorio sale del catálogo, la entrada se conserva y se marca.** No desaparece en silencio. La marca va en la celda **`Estado`**, como sufijo del valor: `cerrada — repositorio fuera del catálogo desde DD-MM-YYYY`. La forma la fija este archivo, porque el contrato exige marcar y no dice cómo.

   > **Caso observado en el workspace de origen: la marca iba en la celda `Repositorio`, y rompía el verificador que este mismo archivo declara en §5.** Un nombre con sufijo deja de ser utilizable como directorio: `check-spec-pointers.sh` lo clasificaba `entrada no válida` y la corrida quedaba en código 2 de forma permanente, con `0 de N entradas verificadas`. La regla prometía conservar la entrada y el mecanismo la invalidaba.
   >
   > Se movió a `Estado` en vez de enseñarle al verificador a recortar el sufijo: **un verificador no debería tener que conocer una convención de marcado de prosa para hacer su trabajo.** Y el sufijo cae sobre un estado terminal, que §5 no verifica, de modo que la entrada queda conservada, marcada y fuera del recorrido — que es lo que la regla quería decir.
5. **Un puntero que no resuelve es una falla que se reporta**, no un silencio. La detecta `check-spec-pointers.sh`, y el reporte la nombra `puntero roto`.
6. **El estado es el de la spec como artefacto, no el del issue en Jira.** El índice no espeja el tablero: son autoridades distintas, y confundirlas crearía una réplica del workflow que caducaría sola.

---

## 4. Transiciones de estado

```text
abierta ──→ en curso ──→ cerrada
   │            │
   └────────────┴──────→ cancelada
```

Las cuatro transiciones admitidas son `abierta` → `en curso`, `en curso` → `cerrada`, `abierta` → `cancelada` y `en curso` → `cancelada`. Cualquier otro movimiento entre estados no está previsto por este índice.

Toda transición actualiza la columna `Actualizada` en la misma edición. Una fila que cambia de estado sin mover esa fecha deja de decir cuándo pasó lo que declara.

---

## 5. Verificación

```bash
.claude/skills/development-repositories/scripts/check-spec-pointers.sh
```

El script recorre las entradas **no terminales** —estado `abierta` o `en curso`— y comprueba con `git cat-file -e refs/heads/<rama>:<ruta>` que la ruta registrada resuelva dentro de la rama registrada del clon local. No hace `checkout`, no toca el árbol de trabajo y no escribe nada. Las entradas `cerrada` y `cancelada` se conservan y no se verifican; el cierre del reporte declara cuántas se omitieron.

**Su ejecución es manual.** No hay integración continua ni gancho en este repositorio que lo dispare. Presentarlo como salvaguarda automática sería falso: protege solo cuando alguien lo corre.

**Límite declarado**: solo verifica repositorios **presentes localmente**. Un repositorio ausente produce `no verificable`, que **no** es lo mismo que `puntero roto` y no se reporta como tal. Un tercer caso, `rama ausente en el clon`, dice que al clon le falta la rama y tampoco es un puntero roto.

**Un cero de ese script no significa que los punteros estén sanos.** Significa que ninguno de los que se pudieron verificar estaba roto, y con los repositorios sin clonar la corrida sale `0` sin haber verificado nada. Por eso el reporte imprime siempre cuántas entradas verificó de cuántas.

El detalle completo de opciones, vocabulario de resultados y códigos de salida está en `check-spec-pointers.sh --help`; acá no se reproduce.

---

## 6. Qué no vive en este archivo

| Materia | Dónde vive |
| --- | --- |
| Contenido y formato de una spec de desarrollo | El repositorio del componente; el formato lo fija `templates/development-spec.md` |
| Enlace, stack, propósito, owner y estado de un repositorio | [`repositories.md`](repositories.md) |
| Estado del issue en el tablero de gestión | El tablero del proyecto (`Pendiente de configurar`), vía `jira-management` |
| Diferencias entre el catálogo y la fuente externa de documentación | [`divergences.md`](divergences.md) |
