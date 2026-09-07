# Flujo y método de trabajo

<!-- Cómo abordar tareas de forma consistente. -->

## Antes de actuar

- Para tareas de varios pasos o cambios amplios: presenta un **plan breve** (qué, en qué orden, qué riesgos) y espera confirmación.
- Para cambios pequeños y dirigidos: ejecútalos directamente y reporta lo hecho.
- Si la tarea es ambigua, aclara el punto crítico con una sola pregunta antes de avanzar; no te bloquees pidiendo detalles que puedes inferir.

## Durante la ejecución

- Verifica el estado real (lee archivos, ejecuta comandos) en vez de suponer.
- Trabaja de forma incremental y reversible; deja el repositorio en estado coherente.
- Cuando una decisión técnica tenga consecuencias, explica el porqué brevemente.
- Mantén consistencia con las convenciones existentes del proyecto (nombres, estructura, estilo).

## Al terminar

- Resume qué cambió y por qué, en términos accionables.
- Indica cómo validar el resultado (comando, prueba, verificación manual).
- Señala pendientes, riesgos residuales o deuda técnica asumida.
- Si corresponde, sugiere registrar la decisión como ADR o dejar una entrada de bitácora; ambos formatos están en `02-documentacion-y-entregables.md`.
- Cierra declarando cuatro cosas: **qué cambió**, **cuándo cambió**, **por qué cambió** y **cuál es el siguiente paso**.

## Criterio proactivo

Señala de forma explícita, sin esperar a que se pregunte:

- **Riesgos** y consecuencias no evidentes de lo que se está haciendo.
- **Vacíos de información** que bloquean o debilitan el resultado.
- **Inconsistencias** entre fuentes, artefactos o decisiones previas.
- **Duplicidad**: el mismo dato viviendo en dos lugares que pueden divergir en silencio.
- **Tareas implícitas** que la petición supone pero no nombra.
- **Pasos que podrían olvidarse** al cerrar.

Detectar algo de esto y callarlo es peor que no detectarlo: deja el problema instalado y con apariencia de resuelto.

## Trazabilidad y orden

- Estandariza: convenciones claras, nombres consistentes, estructura predecible entre proyectos.
- Deja rastro de decisiones relevantes para que otro (o yo en el futuro) entienda el porqué.
- Prefiere soluciones simples y mantenibles sobre las ingeniosas pero opacas.

## Delegación a subagentes

- Para el patrón de gobernanza plan→gate→ejecución sobre Jira y Confluence, y para abrir o gestionar desarrollos de punta a punta, delega en los tres agentes de rol de esta plantilla: `product-owner`, `developer` y `atlassian-executor` (`.claude/agents/`). Su frontera de uso está en la `description` de cada uno; no la repliques acá.
- Para exploración extensa de la base de código, análisis de diseño o revisión de código que generaría mucho ruido en la conversación principal, usa un subagente genérico si tu configuración personal lo provee (por ejemplo `arquitecto` para análisis de diseño o `revisor-codigo` para revisión) y trae de vuelta solo el resumen. **Esta plantilla no versiona esos agentes**: si existen, vienen de la configuración personal de quien opera (`~/.claude-personal/agents/`), no de este repositorio — cítalos por esa procedencia, no como artefactos garantizados de la plantilla.
- Reserva la conversación principal para el trabajo iterativo y las decisiones.

**Divergencia declarada con el set global del usuario** (regla `09-punteros-y-replicas.md`): la regla 04 global del usuario nombra `revisor-codigo` y `arquitecto` como subagentes siempre disponibles, porque en su configuración personal lo están. Esta copia del proyecto los cita igual, pero aclarando que son capacidad externa y no parte de la plantilla — la divergencia es de **origen declarado, no de contenido ni de capacidad**: quien tenga esa configuración personal los sigue teniendo disponibles; quien clone esta plantilla sin ella, no. Un cuarto agente genérico que existía en versiones previas de este repositorio y no tiene equivalente en la configuración personal del usuario se retiró sin reemplazo (traza en `specs/002-portar-agentes/`).
