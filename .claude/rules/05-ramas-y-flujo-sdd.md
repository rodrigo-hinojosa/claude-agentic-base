# Ramas y flujo SDD con spec-kit

## Principio

El trabajo de cada feature SDD vive en su propia rama, no en `main`. `main` es la línea base compartida (andamiaje del proyecto y features ya integradas); las iniciativas se desarrollan aisladas y se integran vía Pull Request.

Donde el hosting lo permita, conviene respaldar esta convención con **protección técnica de `main`** (PR obligatorio, incluidas cuentas administradoras). La convención en prosa no basta por sí sola: quien opera suele tener permisos para saltársela sin querer.

**En un repositorio de una sola persona, exigir aprobación de terceros bloquea el merge indefinidamente**: el autor de un PR no puede contar como su propio aprobador (regla del sistema de reviews, no de la protección de rama). Lo razonable ahí es `required_approving_review_count: 0` — la protección garantiza que **exista un PR** visible y revisable, no que alguien más lo haya aprobado. Si el repo empieza a recibir cambios de otras personas, reevaluar ese valor.

## Regla de ramas

- Una rama por feature de spec-kit, nombrada `<NNN-slug>` coincidiendo con el directorio de la feature en `specs/` (ej. `specs/001-mi-feature/` → rama `001-mi-feature`), tal como la deriva el motor spec-kit.
- La rama se crea al iniciar la feature, antes del primer commit de `spec.md`. Si `/speckit-specify` se ejecutó sobre `main` sin rama, mover esos commits a una rama `<NNN-slug>` y devolver `main` a la línea base antes de continuar.
- **No existe la excepción de ir directo a `main`.** Toda corrección de andamiaje o gobernanza transversal (constitución, reglas, configuración de MCP, `.gitignore`) también nace en su propia rama y se integra por PR — lo único que la distingue de una feature SDD es que no necesita carpeta en `specs/` ni recorrer el flujo `/speckit-*` completo (ver "Trazabilidad end-to-end"). El nombre de esa rama es libre y descriptivo (ej. `chore/<slug>`), porque no hay `<NNN-slug>` con el que hacerlo coincidir.

## Trazabilidad end-to-end vía spec-kit (obligatoria)

- Toda tarea que **cree o modifique artefactos sustantivos del repo** —skills, features, código, plantillas, o documentación versionada de una feature— DEBE nacer de una spec y recorrer el flujo spec-kit completo: `/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`, quedando trazada en `specs/<NNN-slug>/`.
- **No se crean artefactos sustantivos ad-hoc**, fuera de ese flujo. La implementación no adelanta a la fase de tasks: `/speckit-implement` corre **después** de `/speckit-tasks`, nunca antes.
- Si una tarea de este tipo se empezó a implementar sin completar el flujo, se **retoma spec-kit y se cierra la traza** (generar `tasks.md`, reconciliar lo ya hecho contra las tareas, `/speckit-analyze`) **antes de integrar**.
- Excepción **de traza spec-kit, no de rama ni de PR**: las correcciones de andamiaje o gobernanza transversal ya descritas en "Regla de ramas" y los arreglos triviales (typos, formato) no necesitan `specs/<NNN-slug>/` ni el flujo `/speckit-*` completo. Son el marco del proceso, no el producto. **Sí necesitan rama y PR**, igual que cualquier otro cambio.

## Ejecución manual de cada fase (obligatoria)

Rige para todo trabajo que deba recorrer el flujo spec-kit según la sección anterior. Cada paso lo inicia el dueño del repositorio de forma deliberada: el agente ejecuta la fase invocada, se detiene y espera. Nunca recorre el flujo por su cuenta.

- **Qué inicia una fase**: solo el comando del paso escrito por el dueño (`/speckit-specify`, `/speckit-clarify`, `/speckit-plan`, `/speckit-tasks`, `/speckit-implement`). Una invocación ejecuta una sola fase. Lo mismo rige para los comandos auxiliares del motor: `/speckit-analyze`, `/speckit-checklist`, `/speckit-converge`, `/speckit-taskstoissues` y `/speckit-constitution`.
- **Un pedido en lenguaje natural no inicia una fase**: "ejecuta el plan" se responde con el comando que corresponde escribir. El agente no invoca esas skills por su cuenta, tampoco a través de la herramienta Skill.
- **Al cerrar una fase**, el agente reporta el resultado y nombra el comando siguiente, sin ejecutarlo. Una confirmación genérica ("ok", "sigue", "dale", "hazlo todo") no inicia ninguna fase.
- **Dentro de `/speckit-implement`**, el gate baja a cada fase de `tasks.md`: Setup y Foundational, cada historia de usuario, Polish. Al cerrar una (tareas marcadas, verificación y commit), el agente se detiene; la siguiente arranca con una nueva invocación de `/speckit-implement`.
- **Pedido de feature sin invocar el flujo**: si el dueño describe una feature, el agente no implementa ni inicia `/speckit-specify`. Propone la descripción para ese comando y espera que el dueño lo escriba.
- **Sin encadenamiento indirecto**: ninguna fase que el dueño no invocó se ejecuta a través de subagentes, workflows (`specify workflow run`, orquestación multi-agente) ni hooks de extensiones. Si un hook obligatorio de `.specify/extensions.yml` pide ejecutar otro comando del motor, se presenta como siguiente paso y no se ejecuta.
- **Cualquier modo de permisos**: la regla rige también en modo automático. Que el agente pueda actuar sin pedir permiso no lo autoriza a iniciar una fase.

La skill propia `speckit-git-commit` no es un comando del motor: commitea dentro de la fase en curso y sigue sujeta a la regla de integración.

## Nomenclatura asociada

- Commits: `tipo: descripción` en español (feat, fix, docs, refactor, chore, test), sin atribución automática.
- Si el proyecto gestiona su trabajo en Jira: issues `[<CLAVE>-XXX] Descripción`, y las ramas de trabajo de código de producto pueden usar `tipo/<CLAVE>-XXX-descripcion` según el estándar del repo de producto. En un workspace agéntico, las ramas de feature SDD usan `<NNN-slug>`.

## Integración

- No hacer `push` ni `merge` sin confirmación explícita. La protección técnica de `main` es un respaldo, no un reemplazo de ese criterio: sigue rigiendo sobre cuándo crear la rama, cuándo pushear y cuándo abrir el PR, y sobre todo cuándo mergear.
- La rama de feature (o de corrección) se integra a `main` por PR; el historial de la feature queda trazable en esa rama. Si el merge no exige aprobación de otra cuenta, la confirmación explícita del usuario en la conversación **es** el gate real — no hay un segundo control técnico detrás.

## Por qué

- Mantiene `main` siempre desplegable y revisable.
- Aísla el trabajo en curso y su historial, facilitando revisión y reversión por feature.
- El PR obligatorio da visibilidad y trazabilidad —queda registrado qué cambió, cuándo y por qué—, aunque no obligue una segunda mirada humana antes de mergear. Ese límite se declara, no se disimula.
- La ejecución manual por fase mantiene al dueño como gate de cada decisión del flujo: spec, plan, tareas y cada historia implementada. Una aprobación sobre una fase no autoriza las siguientes. La primera corrida del feature 002 encadenó fases sin esa validación y hubo que reiniciarla (`specs/002-portar-agentes/research.md`, D8).
