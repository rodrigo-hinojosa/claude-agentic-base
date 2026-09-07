# Convención del espacio de trabajo local

> **Es convención de entorno, no un cuerpo de datos.** Fija dónde vive cada clon, cómo se llama su directorio, qué vocabulario usa la skill para nombrar ambas cosas, y con qué códigos de salida hablan sus scripts. El conjunto de repositorios vive en [`repositories.md`](repositories.md); acá se lo **cita**, no se lo reproduce.
>
> **No lleva contrato de forma, y es decisión registrada.** La razón viene del workspace de origen y se porta con la decisión: los contratos existen para cuerpos de datos que otro artefacto consume, y este archivo no lo es. La procedencia queda trazada en `specs/002-portar-agentes/`.

| Campo | Valor |
| --- | --- |
| Naturaleza | Convención de entorno local |
| Velocidad de caducidad | Muy lenta |
| Autoridad de la disposición | Este archivo |
| Autoridad de los códigos de salida | Este archivo |
| Procedencia | Réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`) |

---

## 1. Vocabulario, fijado para toda la skill

Dos cosas distintas se llamaban igual en los artefactos previos del workspace de origen. La confusión no era retórica: una es este repositorio y la otra es el directorio que aloja código de producto.

| Término | Qué designa | Qué nunca designa |
| --- | --- | --- |
| **workspace** | El directorio de este repositorio (el clon de esta base agéntica), y solamente él | Cualquier otro directorio |
| **raíz de clones** | El directorio hermano que contiene los clones | Este repositorio |

**La raíz de clones nunca se llama "workspace".** La distinción importa porque el workspace queda **dentro** de la raíz de clones bajo la disposición vigente, de modo que un término ambiguo describiría al contenedor y al contenido con la misma palabra.

**Qué decían los artefactos anteriores.** En el workspace de origen, los artefactos de diseño usaban "workspace" tanto para el repositorio agéntico como para el conjunto de copias de trabajo, y los scripts `prepare-workspace.sh`, `update-workspace.sh` y `workspace-status.sh` conservan esa palabra en su nombre. Esos nombres no se cambian acá; lo que se fija es que su prosa y su salida hablen de **raíz de clones** cuando se refieran al directorio contenedor.

---

## 2. Disposición: los clones son hermanos del workspace

Los clones viven **en el mismo nivel** que el workspace, no dentro de él ni en un subdirectorio propio. Es una decisión revisada por instrucción del usuario en el workspace de origen y portada aquí como disposición vigente (procedencia: `specs/002-portar-agentes/`).

```text
<raíz-de-clones>/
├── <workspace>/           <- este repositorio; NUNCA es objetivo de la skill
├── ejemplo-frontend/
├── ejemplo-backend/
└── ejemplo-qa-tests/      <- los demás repositorios del catálogo
```

**El workspace no es objetivo de ninguna operación de la skill.** Lo garantizan dos hechos independientes: los scripts iteran el catálogo y no el directorio, y el workspace no está en la sección de [`repositories.md`](repositories.md) que forma ese catálogo. Los scripts lo excluyen además por nombre, porque una garantía que dependa solo de que la fuente nunca lo liste es más frágil de lo necesario.

---

## 3. Cómo se resuelve la raíz de clones

| Orden | Fuente del valor | Resultado |
| --- | --- | --- |
| 1 | Opción `--root <ruta>` de la línea de comandos | La ruta indicada |
| 2 | Variable de entorno `REPOS_ROOT`, si está definida y no vacía | La ruta que esa variable indica |
| 3 | Default | El directorio padre del workspace |

> **Caso observado en el workspace de origen**, conservado porque ilustra un mecanismo vigente: la opción `--root` faltó un tiempo en esta tabla, y tres scripts la citaban como si estuviera — `lib-repo-set.sh`, `check-workspace-dirs.sh` y `check-spec-pointers.sh` declaran en sus cabeceras la precedencia de tres niveles remitiendo a esta sección, que solo listaba dos. El puntero apuntaba bien a una sección incompleta, que es la falla ruidosa de la regla 09 (`.claude/rules/09-punteros-y-replicas.md`) y no la silenciosa: se detecta leyendo lo citado.

El catálogo se resuelve igual, con `--catalog <ruta>` y `REPOS_CATALOG`.

**La ruta efectiva se declara resuelta en cada reporte**, escrita como ruta y nunca como nombre de variable. Un reporte que no dice sobre qué directorio operó no es verificable. Esa exigencia proviene del contrato de reporte de estado de la skill; el documento del contrato está `Pendiente de portar` a esta base, y mientras tanto la exigencia rige tal como queda enunciada acá.

**Por qué variable de entorno y no ruta fija.** Una ruta absoluta del entorno de una persona vuelve la skill inoperante en cualquier otro clon del repositorio. Es un defecto ya observado y corregido en el workspace de origen (en la skill homóloga de `confluence-docs`), y no se reintroduce acá.

---

## 4. Derivación del directorio local

**El directorio local de un repositorio se llama exactamente como el repositorio, sin transformar.** No se acorta, no se traduce, no se le quita el prefijo común del proyecto y no se le cambia la separación de palabras.

Esta identidad es lo que permite que todos los scripts de la skill coincidan sobre dónde buscar cada clon. Sin ella, cada script tendría que replicar una regla de transformación, y dos réplicas de una regla divergen en silencio.

**`directorio_local` no es columna del catálogo.** Se calcula al operar, concatenando la raíz de clones resuelta con el nombre del repositorio. Registrarlo como dato sería guardar el resultado de un cálculo, que es la forma de réplica que la regla 09 del repositorio (`.claude/rules/09-punteros-y-replicas.md`) prohíbe.

Ejemplo de la derivación, con la raíz por defecto:

```text
raíz de clones resuelta:  /ruta/a/proyectos
repositorio:              ejemplo-backend
directorio local:         /ruta/a/proyectos/ejemplo-backend
```

**Una consecuencia deliberada** (caso observado en el workspace de origen): un repositorio cuyo nombre arrastraba un erratum se usó literal, erratum incluido. El catálogo transcribe cada nombre tal como existe en el hosting, y corregirlo acá produciría un directorio que ningún clon ocupa.

---

## 5. Por qué los clones no viven dentro del workspace

Tres razones, **cada una suficiente por sí sola**. Que sean independientes importa: si mañana una deja de aplicar, las otras dos siguen sosteniendo la disposición.

1. **`.gitignore` no excluye ningún directorio de clones**, verificado en esta base al portar (07-09-2026). Un clon dentro del árbol entraría al índice al primer `git add` amplio.
2. **El workspace aloja configuración agéntica y trazas SDD, no código de producto.** Es convención de esta plantilla.
3. **Anidar repositorios `git` dentro de otro produce confusiones reales de contexto**, con comandos que corren contra el repositorio equivocado sin error visible.

---

## 6. La raíz resuelta debe quedar fuera del árbol del workspace

**Antes de clonar nada, se comprueba que la raíz resuelta no esté contenida en el árbol del workspace.** Si lo está, la operación se detiene y lo declara. Vale tanto para el default como para un valor de `REPOS_ROOT`.

La comprobación existe porque `REPOS_ROOT` es libre y el default se calcula a partir de dónde está el workspace. Apuntar la raíz hacia adentro es un error fácil de cometer, y sin esta comprobación las tres razones de arriba quedarían sostenidas por una afirmación en prosa.

**La comprobación de ruta ocupada es distinta y también obligatoria.** La raíz de clones es un directorio compartido que la skill no posee, donde ya vive el workspace y donde puede haber cualquier otra cosa. Su tratamiento lo fija el contrato de reporte de estado (`Pendiente de portar` a esta base), no este archivo.

---

## 7. Códigos de salida, comunes a todos los scripts de la skill

| Código | Significado |
| --- | --- |
| `0` | La corrida completó y ningún repositorio quedó en error |
| `1` | Error de uso o de precondición: **nada se ejecutó** |
| `2` | La corrida completó y **al menos un repositorio terminó en `error: <motivo>`** |

Casos que producen `1`: falta un argumento, el verbo es desconocido, el catálogo es ilegible, `git` no está disponible, la raíz resuelta cae dentro del workspace, o un nombre pasado a `--only` no existe en el catálogo.

Reglas de salida que acompañan a la tabla:

- **`--help` y `-h` imprimen el uso a `stdout` y salen `0`.** Pedir ayuda nunca se confunde con equivocarse al invocar.
- **Los errores van a `stderr` con el prefijo literal `ERROR: `.**
- **Los avisos van a `stderr` con el prefijo literal `AVISO: ` y no alteran el código de salida.**

### El `2` es una extensión declarada, no una divergencia

La convención heredada es la de `.claude/skills/visual-docs/scripts/`, que usa **solo `0` y `1`**. Verificado sobre la copia portada en esta base (07-09-2026): `scaffold_docs.mjs` y `validate_docs.mjs` solo ejecutan `process.exit` con `0` o `1`.

El precedente no necesitaba un tercer código porque cada uno de sus scripts opera sobre un único destino. Los scripts de esta skill operan sobre un conjunto de repositorios, y el contrato de reporte prohíbe declarar completo un conjunto donde algo falló (el documento del contrato está `Pendiente de portar`; la prohibición rige acá mientras tanto).

Sin un código propio, "corrió con fallas parciales" y "corrió limpio" serían indistinguibles desde afuera, porque el `1` ya está tomado por el caso en que nada se ejecutó. Esa distinción le importa a quien encadene estos scripts sin leer su salida.

Dos diferencias más respecto del precedente, anotadas para que nadie las tome por herencia y verificadas sobre la copia portada en esta base. El prefijo de error no es uniforme **dentro de un mismo archivo** del precedente: `validate_docs.mjs` escribe `ERROR: ` en su línea 47 y `ERROR ` en su línea 171, y esta skill adopta la forma con dos puntos. El aviso del precedente dice `WARN` (línea 170), que es inglés dentro de un mensaje en español, y esta skill usa `AVISO: `.

---

## 8. Lectura del código de producto por el agente

Clonar un repositorio fuera del workspace no basta para que un agente pueda leerlo. La lectura se habilita declarando directorios de trabajo adicionales en `.claude/settings.json`, bajo la clave `permissions.additionalDirectories`.

**Se enumeran los repositorios uno por uno, no la raíz completa.** Conceder la raíz entera daría acceso al workspace por una segunda ruta, a repositorios que el proyecto haya declarado fuera de alcance si alguien los clona ahí, y a cualquier proyecto vecino futuro. El criterio es el principio de menor privilegio que fija `.claude/rules/03-seguridad-y-secretos.md`.

### Forma de las rutas

Hallazgo replicado del workspace de origen — réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`). La verificación original se hizo contra la documentación de Claude Code citada al pie de esta sección.

| Aspecto | Hallazgo |
| --- | --- |
| Forma recomendada | Relativa |
| ¿Funciona una ruta relativa? | Sí |
| Base de resolución | El directorio desde el cual se ejecuta `claude`, es decir el directorio de trabajo primario de la sesión |
| Tipo de la clave | Arreglo de cadenas, con `uniqueItems: true` según el esquema declarado en `$schema` |

Ejemplo copiable, ilustrativo con dos entradas:

```json
{
  "permissions": {
    "additionalDirectories": [
      "../ejemplo-backend",
      "../another-sibling-repo"
    ]
  }
}
```

**La enumeración vigente vive en `.claude/settings.json`, y la lista de repositorios en [`repositories.md`](repositories.md).** Este archivo no reproduce ninguna de las dos: sería una tercera copia de la misma lista, y la que quedara sin mantener no avisaría.

### Límites de este hallazgo

Tres cosas quedaron **sin verificar** y no se presentan como hecho:

- Si funcionan formas alternativas como `...` o patrones glob.
- El comportamiento en integración continua, donde el directorio de trabajo puede no ser la raíz del repositorio.
- La interacción con variables de entorno como `CLAUDE_CONFIG_DIR`.

Fuentes consultadas: la documentación de Claude Code sobre [bases de código grandes](https://code.claude.com/docs/en/large-codebases#grant-access-across-packages-or-repositories) y sobre [directorios de trabajo](https://code.claude.com/docs/en/permissions#working-directories).

### Estado de la enumeración

`Pendiente de configurar` por proyecto. En esta base la clave no está poblada (verificado 07-09-2026: `.claude/settings.json` no contiene `additionalDirectories`). Al adoptar la skill en un proyecto, escribir una entrada por repositorio del catálogo, en forma relativa con prefijo `../`, cuidando que el archivo siga siendo JSON válido y que el nombre y el tipo de la clave sean los que declara el esquema de su `$schema`.

Queda una consecuencia de la base de resolución, anotada como inferencia y no como medición: si la sesión de Claude Code se lanza desde otro directorio, las rutas relativas resuelven contra esa otra base. Ese caso no se probó en el workspace de origen, y no se sabe si algún mensaje lo advierte.

### Costo de mantención que esta decisión asume

**La lista enumerada hay que mantenerla cuando el catálogo crezca, y nada la sincroniza sola.** Es una réplica del catálogo dentro de la configuración, admitida a cambio de no conceder de más.

**El modo de fallo es el peor de los posibles.** Cuando el catálogo suma un repositorio y la configuración queda corta, el agente informa que no encuentra un archivo que sí existe, y la causa no aparece por ninguna parte.

**La mitigación es `scripts/check-workspace-dirs.sh`**, el detector que compara el catálogo contra los directorios enumerados en `.claude/settings.json`. **Compara y no repone**: reponer sería ampliar permisos sin que una persona lo decida.

**Su ejecución es manual.** No hay integración continua ni gancho que lo dispare en este repositorio, y esa ausencia se declara acá en vez de suponerse cubierta. Es la misma forma de declaración que usa la regla 09 (`.claude/rules/09-punteros-y-replicas.md`) para su propio procedimiento de verificación.

---

## 9. Límites de este archivo

- **No declara cuál es el repositorio oficial del proyecto ni qué CI/CD rige.** Esa decisión es de cada proyecto que adopte la skill; su puntero: `Pendiente de configurar`.
- **No fija la navegación de terminal ni la configuración del editor.** Quedan fuera de alcance por pertenecer al entorno de cada persona, no por estar sin resolver (decisión de diseño portada; procedencia en `specs/002-portar-agentes/`).
- **No lista repositorios.** Cualquier nombre que aparezca arriba es un ejemplo sintético de derivación, no un extracto del catálogo.
