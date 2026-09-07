> **Esto es un FIXTURE de prueba, no el catálogo de la skill.** Sus cinco filas son repositorios **sintéticos** que no existen en GitHub, no pertenecen a ningún proyecto real y no se clonan de ningún remoto real.
>
> **El catálogo de la skill es [`repositories.md`](../repositories.md)**, y es el único que resuelve una consulta. Este archivo existe para que los scripts de `scripts/` se puedan probar sin tocar los repositorios reales del catálogo del proyecto ni depender de que estén clonados.

# Catálogo de prueba — fixture de los scripts

| Campo | Valor |
| --- | --- |
| Naturaleza | Fixture de prueba |
| Qué NO es | El catálogo de la skill, ni una réplica suya, ni una fuente consultable |
| Repositorios reales que nombra | Ninguno |
| Marcador de la ruta | `__RAIZ__`, que la receta de §3 sustituye por la raíz de prueba real |
| Consumidores | `scripts/run-across-repos.sh` y los demás scripts de la skill |
| Procedencia | Réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`) |
| Traza | `specs/002-portar-agentes/` |

**Ningún dato de este archivo se cita como hecho del proyecto.** Las celdas `Componente`, `Stack`, `Propósito`, `Estado` y `Owner` están rellenas con texto inventado para que la tabla tenga la misma forma que la real; leerlas como información de un proyecto real sería un error.

> **La columna `Link` lleva el marcador `__RAIZ__` y no una ruta, y eso es deliberado.** Los verbos mutantes comprueban que el remoto del clon corresponda al `Link` del catálogo antes de tocar nada, de modo que un fixture con la celda rellena de prosa —el estado en que estuvo este archivo en el workspace de origen— deja `fetch` y `pull` imposibles de ejercitar.
>
> Una ruta absoluta tampoco sirve: este archivo se versiona, y la del scratchpad de una sesión no existe en ninguna otra máquina. El marcador resuelve las dos cosas: el artefacto queda independiente de la máquina, y la receta de §3 produce una copia utilizable donde corren las pruebas.

---

## 1. Los cinco repositorios sintéticos

| Repositorio | Componente | Clase (derivada) | Link | Stack | Propósito (origen: redactado) | Estado | Owner (puntero) | Notas | Procedencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fixture-repo-limpio | Fixture | desarrollo | file://__RAIZ__/origen/base.git | Ninguno | Clon al día y sin cambios locales | Activo | (sintético) | Estado esperado: `presente`, `limpio`, `al día` | `FIXTURE` |
| fixture-repo-atrasado | Fixture | desarrollo | file://__RAIZ__/origen/base.git | Ninguno | Clon con commits pendientes en el upstream | Activo | (sintético) | Estado esperado: `presente`, `limpio`, y `atrasado` recién después de un `fetch` (ver §4) | `FIXTURE` |
| fixture-repo-sucio | Fixture | desarrollo | file://__RAIZ__/origen/base.git | Ninguno | Clon con cambios sin guardar en archivos versionados | Activo | (sintético) | Estado esperado: `presente`, `con cambios sin guardar`; `pull` lo salta | `FIXTURE` |
| fixture-repo-vacio | Fixture | qa | file://__RAIZ__/origen/vacio.git | Ninguno | Clon sin ningún commit | Activo | (sintético) | Estado esperado: `presente`, `vacío`, `sin commits` | `FIXTURE` |
| fixture-repo-ausente | Fixture | qa | file://__RAIZ__/origen/base.git | Ninguno | Repositorio que nunca se crea en disco | Activo | (sintético) | Estado esperado: `ausente`; la corrida sale con código 2 | `FIXTURE` |

**La quinta fila existe para que el fixture tenga un ausente.** Sin ella no se puede probar que la columna `Presencia` distingue, ni que la corrida sale con código 2 cuando algo falta.

---

## 2. Cómo se apunta un script a este archivo

Dos cosas hay que redirigir a la vez: **qué catálogo se lee** y **dónde están los clones**. Redirigir solo una deja el script leyendo el fixture y buscando sus directorios entre los repositorios reales.

| Qué redirige | Opción de línea de comandos | Variable de entorno | Precedencia |
| --- | --- | --- | --- |
| El catálogo | `--catalog <ruta>` | `REPOS_CATALOG` | La opción precede a la variable; la variable precede al default |
| La raíz de clones | `--root <ruta>` | `REPOS_ROOT` | La opción precede a la variable; la variable precede al default |

Invocación completa, con la raíz de prueba en un directorio temporal:

```sh
.claude/skills/development-repositories/scripts/run-across-repos.sh status \
    --catalog .claude/skills/development-repositories/examples/test-catalog.md \
    --root "$RAIZ"
```

**La raíz de prueba no puede caer dentro del árbol del workspace.** El script lo comprueba antes de tocar nada y aborta con código 1 si la ruta resuelta está contenida en el repositorio workspace desde el que la skill opera. Es una guarda heredada del contrato de reporte del diseño de origen (procedencia: `specs/002-portar-agentes/`), y aplica igual a una corrida de prueba que a una real.

---

## 3. Cómo se arma la raíz de prueba

Los cuatro clones que este fixture espera encontrar se construyen locales, sin red. Cada uno sale de un repositorio origen también local, de modo que `fetch` y `pull` tengan un upstream real contra el que trabajar.

**El orden de los pasos importa y no es cosmético.** `fixture-repo-atrasado` se clona antes del segundo commit y los otros dos después: si se clonaran todos al principio, los tres quedarían atrasados y el fixture perdería su clon al día.

```sh
# La raíz de prueba vive en el scratchpad de la sesión, no en /tmp: las pruebas
# corren sobre repositorios efímeros de ese directorio, que está aislado del
# proyecto y se limpia solo. /tmp es compartido con el resto del sistema.
# (Decisión heredada del diseño de origen; procedencia: specs/002-portar-agentes/.)
RAIZ="${FIXTURE_ROOT:?define la raíz de prueba, dentro del scratchpad de la sesión}"
mkdir -p "$RAIZ/origen"

# Origen común, con un commit inicial.
git init -q --bare "$RAIZ/origen/base.git"
git clone -q "$RAIZ/origen/base.git" "$RAIZ/semilla"
: > "$RAIZ/semilla/archivo.txt"
git -C "$RAIZ/semilla" add archivo.txt
git -C "$RAIZ/semilla" -c user.email=fixture@local -c user.name=fixture commit -qm 'commit inicial'
git -C "$RAIZ/semilla" push -q origin HEAD

# fixture-repo-atrasado: se clona ACÁ, antes del segundo commit.
git clone -q "$RAIZ/origen/base.git" "$RAIZ/fixture-repo-atrasado"

# Segundo commit en el origen. Deja atrás al clon anterior y solo a él.
printf 'nuevo\n' > "$RAIZ/semilla/archivo.txt"
git -C "$RAIZ/semilla" add archivo.txt
git -C "$RAIZ/semilla" -c user.email=fixture@local -c user.name=fixture commit -qm 'commit posterior'
git -C "$RAIZ/semilla" push -q origin HEAD

# fixture-repo-limpio: clon al día, sin cambios locales.
git clone -q "$RAIZ/origen/base.git" "$RAIZ/fixture-repo-limpio"

# fixture-repo-sucio: al día, con un cambio sin guardar sobre un archivo versionado.
git clone -q "$RAIZ/origen/base.git" "$RAIZ/fixture-repo-sucio"
printf 'cambio local\n' > "$RAIZ/fixture-repo-sucio/archivo.txt"

# fixture-repo-vacio: CLON de un origen sin ningún commit. Se clona, no se
# inicializa: el caso real son repositorios que existen en GitHub, se clonan
# con normalidad y no tienen un solo commit — caso observado en el workspace
# de origen, donde varios repositorios del catálogo estaban así al momento
# del relevamiento. Un `git init` local produce un repositorio sin remotos,
# que es otra cosa y los verbos mutantes lo reportan como error en vez de
# como salto.
git init -q --bare "$RAIZ/origen/vacio.git"
git clone -q "$RAIZ/origen/vacio.git" "$RAIZ/fixture-repo-vacio"

# fixture-repo-ausente: no se crea. Ese es el punto.

# Copia utilizable del catálogo, con el marcador resuelto. Los scripts leen ESTA,
# no el archivo versionado: un catálogo con `__RAIZ__` sin sustituir hace que los
# verbos mutantes fallen con "el catálogo no trae un enlace utilizable".
sed "s#__RAIZ__#$RAIZ#g" \
    .claude/skills/development-repositories/examples/test-catalog.md \
    > "$RAIZ/catalogo-resuelto.md"
```

**A partir de acá, `--catalog` apunta a `$RAIZ/catalogo-resuelto.md`**, no al archivo de la skill. Es la única forma de ejercitar `fetch` y `pull`, que comprueban el remoto antes de operar.

**`$RAIZ/semilla` y `$RAIZ/origen` sobran en la raíz a propósito.** La raíz de clones es un directorio compartido que la skill no posee, y un fixture donde solo viven los directorios del catálogo probaría una condición más limpia que la real.

**El fixture es de un solo uso por verbo mutante.** Una corrida de `pull` deja a `fixture-repo-atrasado` al día, y la siguiente ya no prueba lo mismo. Para repetir la prueba se borra la raíz y se arma de nuevo.

---

## 4. Qué ejercita cada estado

| Fila | Qué prueba en `status` | Qué prueba en `pull` |
| --- | --- | --- |
| `fixture-repo-limpio` | Lectura completa de las cuatro columnas de estado: `presente`, `limpio`, `al día` | `sin cambios`: no hay avance rápido que hacer |
| `fixture-repo-atrasado` | Que la columna `Respecto del remoto` diga `al día` mientras nadie traiga referencias, y `atrasado` después de un `fetch` | `actualizado` por `merge --ff-only` tras el `fetch` |
| `fixture-repo-sucio` | Columna `Limpieza` en `con cambios sin guardar` | `saltado (cambios sin guardar)`, sin intentar nada; el contenido local queda intacto |
| `fixture-repo-vacio` | Que un clon sin commits sea `vacío` y no `limpio`, y que la rama se resuelva con `symbolic-ref` donde `rev-parse` falla con 128 | `saltado (sin upstream)`: hay remoto, y no hay rama que seguir |
| `fixture-repo-ausente` | Columna `Presencia` en `ausente` y código de salida 2 | Lo mismo |

**`fixture-repo-atrasado` dice `al día` en un `status` recién armado, y eso es correcto.** La columna compara contra la referencia remota que el clon tiene guardada, y esa referencia no se mueve sola: hasta que alguien traiga referencias, el clon no sabe que quedó atrás. Es la razón por la que `pull` hace `fetch` antes de evaluar, y no al revés.

**Los estados `divergente` y `solo sin seguimiento` no están en el fixture**, y esa ausencia se declara en vez de suponerse cubierta. Se construyen sobre la misma raíz:

```sh
# Divergente: un commit local sobre un clon que además quedó atrás.
printf 'local\n' > "$RAIZ/fixture-repo-atrasado/local.txt"
git -C "$RAIZ/fixture-repo-atrasado" add local.txt
git -C "$RAIZ/fixture-repo-atrasado" -c user.email=fixture@local -c user.name=fixture commit -qm 'local'

# Solo sin seguimiento: un archivo que git no versiona.
: > "$RAIZ/fixture-repo-limpio/suelto.txt"
```

Con esos dos, `pull` reporta `saltado (divergente)` y `saltado (sin seguimiento)`, y `pull --allow-untracked` cambia el segundo por `actualizado` o `sin cambios` según haya avance que hacer.

---

## 5. Cómo se ejercitan los dos avisos del parseo

Ninguno de los dos se dispara con el fixture tal como está, porque un fixture que avisa en cada corrida vuelve el aviso invisible.

**Aviso de fila perdida.** Agrega a la sección 1 una fila cuya primera celda no sea utilizable como nombre de directorio —por ejemplo, envuelta en tildes invertidas—. El script cuenta la fila en el total y no extrae su nombre, y declara la diferencia con `AVISO: descuadre de parseo del catálogo — filas de datos: N; nombres operables: M; exclusiones por nombre: E; fuera del recorrido: F`. Es un hallazgo del diseño de origen (procedencia: `specs/002-portar-agentes/`): si el total y los nombres salieran del mismo parseo, la fila perdida sería indetectable.

**Aviso de exclusión del workspace.** Agrega a la sección 1 una fila cuya primera celda sea el nombre del repositorio workspace desde el que la skill opera (en esta plantilla, `Pendiente de configurar`). El script la excluye por nombre y lo dice, sin operarla. La exclusión por nombre existe además de la ausencia del catálogo real, porque una garantía que dependiera solo de que la fuente nunca lo liste sería más frágil de lo necesario.

**Deja las dos filas fuera de la sección 1 cuando termines de probar.** Un fixture con ruido permanente deja de servir para distinguir una corrida sana de una con hallazgos.

---

## 6. Límites de este archivo

- **No es un catálogo y no se sincroniza con nada.** Ninguna corrida del modo sincronizar lo mira, y su columna `Procedencia` dice `FIXTURE` justamente para que no se confunda con un identificador de relevamiento.
- **No prueba la red.** Todos los remotos son locales, de modo que un `fetch` que falla por credenciales o por conectividad no se ejercita acá.
- **No cubre `prepare-workspace.sh` en su caso más delicado.** La ruta destino ocupada por algo que no es el clon esperado exige construir esa colisión a mano; el fixture no la trae armada.
