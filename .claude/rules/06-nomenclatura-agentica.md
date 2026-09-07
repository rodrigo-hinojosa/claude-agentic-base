# Nomenclatura de agentes y skills

## Principio

El nombre de un artefacto agéntico —subagente en `.claude/agents/` o skill en `.claude/skills/`— debe permitir distinguir, sin abrir el archivo, de dónde proviene: si es parte del **estándar transversal** de esta plantilla, si es **propio de un proyecto** concreto, si viene de la configuración personal del usuario o si lo provee un plugin instalado.

- **Skills del estándar transversal** (las que esta plantilla trae y aplican a cualquier proyecto): nombre sin sufijo de proyecto. Ej.: `confluence-docs`, `jira-management`, `visual-docs`.
- **Artefactos propios de un proyecto** (creados para ese dominio y sin sentido fuera de él): llevan el identificador del proyecto como sufijo.

## Patrón para artefactos de proyecto

`<proyecto>` es el identificador corto del proyecto, en minúsculas (defínelo al iniciar el proyecto; `Pendiente de configurar` en esta plantilla).

| Tipo | Patrón | Ejemplo (proyecto `acme`) |
| --- | --- | --- |
| Agente de rol | `<rol>-<proyecto>` | `product-owner-acme` |
| Skill de dominio | `<herramienta>-<proyecto>-<uso>` | `jira-acme-qa` |
| Skill que cubre todo el dominio de una herramienta | `<herramienta>-<proyecto>` | `confluence-acme` |
| Skill sobre un dominio de datos, no sobre una herramienta | `<dominio>-<proyecto>` | `team-acme` |

Reglas de formación:

- Todo en minúsculas, palabras separadas por guion, sin acentos ni caracteres especiales.
- **El nombre va en inglés** (ver la sección siguiente).
- El segmento `<uso>` es **opcional** y se omite solo cuando la skill cubre íntegramente el dominio de esa herramienta. En cuanto exista una segunda skill sobre la misma herramienta, ambas deben llevar `<uso>` para diferenciarse.
- El nombre del directorio de la skill, el campo `name` de su frontmatter y el nombre con que se la invoca deben coincidir exactamente.
- Para agentes, `<rol>` es el nombre del rol tal como existe en el roster formal del proyecto, no una función técnica — **salvo la clase declarada de agente ejecutor** (ver más abajo), donde nombrar por función es correcto porque el agente no ocupa un rol de negocio.
- El identificador del proyecto va **al final**, no al inicio: `team-acme`, no `acme-team`. Es lo que hace que todos los artefactos del proyecto se agrupen y se lean igual.

## Idioma de los nombres

**Toda skill, agente o comando nuevo bajo `.claude/`, y los archivos internos de una skill, llevan su nombre en inglés.**

**La regla rige nombres, no contenido.** La prosa, la documentación y las especificaciones siguen en español, según la convención del proyecto. Un archivo `provenance.md` escrito íntegramente en español es conforme; uno llamado `procedencia.md` no lo es.

**Excepción declarada de esta plantilla**: los archivos de `.claude/rules/` conservan nombres en español (`00-lenguaje-y-formato.md`, …). Son réplica deliberada del set global del usuario, que ya está en español, y renombrarlos rompería esa correspondencia.

**Alcance acotado a `.claude/`.** Quedan fuera `specs/`, `.specify/` y la raíz del repositorio. Los slugs de feature los deriva el motor spec-kit de una descripción en español, y renombrarlos rompería la traza que enlaza rama, directorio y ticket.

## Por qué

- **Evita colisiones reales.** El entorno carga simultáneamente skills del proyecto, skills de la configuración personal del usuario y skills provistas por plugins. Sin distinción de origen, dos artefactos homónimos compiten por el mismo nombre de invocación.
- **Hace evidente el origen.** Ante un artefacto inesperado, el nombre indica si es del estándar, del proyecto o llegó por otra vía.
- **Fuerza la decisión de alcance al nombrar.** Elegir entre `<herramienta>-<proyecto>` y `<herramienta>-<proyecto>-<uso>` obliga a declarar si la skill cubre toda la herramienta o solo una parte, antes de escribirla.

## Excepciones

- **Motor spec-kit** (`speckit-*`): provienen de la herramienta y conservan su nombre original. Renombrarlas rompería el flujo SDD.
- **Skills externas al repositorio** (`/ticket`, `/resumen`, `/documentar`, `/bitacora`, `/decision`): no son del proyecto, no se versionan aquí y no se renombran. Ningún artefacto del repositorio debe **depender** de ellas para funcionar: pueden citarse como atajo, nunca como requisito.
- **Artefactos provistos por plugins**: su nombre lo fija el plugin.

## Clase declarada — agente ejecutor nombrado por función

El patrón `<rol>-<proyecto>` asume que todo agente ocupa un rol del roster del proyecto. Existe una clase distinta: el **agente ejecutor**, que no representa un rol de negocio sino una función de infraestructura — ejecutar operaciones ya aprobadas por otro agente o por el usuario, sin criterio propio sobre el contenido. Un agente ejecutor **se reconoce como tal** por convención: nombrado por función **y** declarando en su cuerpo que no ocupa un rol. Fuera de esa clase, un agente de rol nombrado por función técnica (`revisor`, `traductor`) es señal de que el artefacto no pertenece al proyecto.

## Verificación

Antes de crear un agente o una skill, comprobar:

- El nombre está **en inglés**, y el archivo o directorio está bajo `.claude/`.
- Si es artefacto de proyecto, contiene `<proyecto>` y lo lleva **al final**; si es del estándar transversal, no lleva sufijo.
- El nombre no colisiona con una skill personal, del motor spec-kit o de un plugin (revisar el listado de skills de la sesión antes de crear).
- Si es agente, el rol existe en el roster del proyecto; si no existe, se declara explícitamente en el cuerpo del agente.
- Si es skill y ya hay otra sobre la misma herramienta, ambas llevan su segmento `<uso>`.

El inventario de artefactos se rehace, no se recuerda:

```bash
find .claude/skills -mindepth 2 -maxdepth 2 ! -name 'SKILL.md' | grep -v speckit | sort
ls -1 .claude/agents/ .claude/skills/
```
