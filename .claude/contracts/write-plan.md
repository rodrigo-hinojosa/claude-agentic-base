# Contrato del plan de escritura

Autoridad operativa del flujo de delegación entre los agentes productores de planes — `product-owner` y `developer` — y el ejecutor `atlassian-executor` (hijo). Este archivo es la fuente viva que los tres agentes citan en runtime; su diseño de portación vive en `specs/002-portar-agentes/` — divergir de aquel diseño en este contrato exige anotarlo en la spec de la feature correspondiente, no silenciarlo (regla 09, `.claude/rules/09-punteros-y-replicas.md`).

Procedencia: réplica declarada del contrato madurado en un workspace anterior, portada y parametrizada el 06-09-2026 (feature `002-portar-agentes`).

## Orden de secciones del documento del plan

Fijo, porque el hash de la marca depende de él:

1. Metadatos del plan (título, fecha, origen)
2. `## Precondiciones`
3. `## Operaciones`
4. La línea delimitadora literal `<!-- end-operations -->` — presente **desde el borrador**, nunca agregada al aprobar
5. `## Aprobación` — solo existe después del gate, insertada tras el delimitador

Con este orden, insertar la marca de aprobación nunca altera el contenido que el hash cubre.

## Estructura de las entidades

Este contrato es la **autoridad única** de estas cuatro entidades (consolidadas aquí en la portación; ver `specs/002-portar-agentes/data-model.md` para el diseño):

- **PlanDeEscritura**: el documento completo, con las secciones en el orden fijo de arriba. Estados: borrador → sellado (la sesión principal inserta la marca tras el gate) → ejecutado o rehusado.
- **Operacion**: unidad atómica de escritura — par sistema+herramienta del catálogo, más el payload completo y literal (título, descripción, campos, labels, assignee, cuerpo de página, versión esperada según aplique). Lo que no está en el payload no existe para el ejecutor.
- **MarcaDeAprobacion**: sección `## Aprobación` con cuatro campos obligatorios — `fecha`, `aprobacion` (cita de la aprobación del usuario), `alcance` (siempre total, `operaciones 1-N`), `hash` (SHA-256 de la sección de operaciones).
- **ReporteDeEjecucion**: resultado por operación — `ejecutada` con el dato real leído del sistema, `abortada` con motivo y estado observado, o `no ejecutada` (posterior a un aborto). Es el artefacto durable del flujo.

## Catálogo de operaciones por destino

Cerrado. Una operación cuyo par sistema+herramienta no está aquí se rehúsa, aunque el plan la traiga con marca de aprobación válida — el hijo reporta el motivo y no ejecuta.

Las filas son **plantilla**: los identificadores de tablero y sus invariantes son parámetros por proyecto (se configuran al adoptar la plantilla, junto con los parámetros de las skills citadas). Los mecanismos de cada fila no cambian.

| Sistema | Herramientas admitidas | Invariantes que el plan porta | Fuente citada |
| --- | --- | --- | --- |
| `board-gestion` (id: `Pendiente de configurar`) | `createJiraIssue`, `transitionJiraIssue`, `editJiraIssue` | Tipo de issue fijado **por id** (parámetro de `jira-management`); assignee con `accountId` resuelto según el procedimiento del proyecto; label de gestión del proyecto en todo issue nuevo, si el proyecto la define; estado origen esperado en toda transición | skill `jira-management`, secciones "Modo CREAR" y "Modo MOVER" — el gate que ahí se define no se replica acá, se cita |
| `board-secundario` (opcional; id: `Pendiente de configurar`) | `createJiraIssue`, `transitionJiraIssue` | Tipo de issue por id; pertenencia por la **épica ancla** del tablero, que **nunca** es destino de escritura; sin editar ni borrar | la skill de dominio que el proyecto defina para ese tablero |
| `confluence` | `createConfluencePage`, `updateConfluencePage`, invocadas siguiendo las instrucciones de `confluence-docs` (modo publicar) cargadas vía `Skill` — no por protocolo propio del hijo | Versión esperada de la página en toda actualización; espacio configurado del proyecto (parámetro de `confluence-docs`) | skill `confluence-docs`, modo publicar |

**Confluence se ejecuta invocando la skill, no reimplementando su protocolo.** Para el destino `confluence` el hijo invoca `confluence-docs` (modo publicar) en vez de llamar `createConfluencePage`/`updateConfluencePage` directamente — así el estándar de contenido y de verificación de versión que rige es siempre el de la skill, sin mantener dos descripciones que puedan divergir. La "aprobación explícita" que ese modo exige **ya está satisfecha** por la marca de este contrato: el usuario aprobó el contenido exacto al sellar el hash (verificado en el protocolo previo del hijo), así que el hijo no le pregunta de nuevo al invocar la skill — continúa directo al paso de reverificar versión y al de escribir. `confluence-docs` documenta esta misma equivalencia en su propio modo publicar.

## Marca de aprobación

- La escribe **la sesión principal**, nunca el padre ni el hijo, después de que el usuario aprueba el gate con el contenido exacto a la vista, y siempre después del delimitador de cierre de operaciones.
- Incluye el **SHA-256 de la sección de operaciones** al momento de aprobar. El hijo lo recomputa antes de ejecutar: si difiere, el plan cambió después de aprobarse y se rehúsa completo (estado `caducado`).
- El campo `alcance` es **siempre total** (todas las operaciones del plan): una corrección del usuario produce un plan nuevo, nunca una aprobación parcial. El campo se conserva como declaración redundante verificable: su conteo debe coincidir con las operaciones presentes.
- Comando de referencia, estable ante la inserción de la marca porque ambos bordes existen desde el borrador:

```bash
sed -n '/^## Operaciones$/,/^<!-- end-operations -->$/p' <plan.md> | shasum -a 256
```

- **Prueba de ida y vuelta verificada en este repositorio** (07-09-2026, `specs/002-portar-agentes/evidence.md`): hash antes de insertar la marca = hash después de insertarla; alterar una operación real sí cambia el hash.

## Frontera de resolución del hijo

| El hijo resuelve solo | El hijo aborta y reporta |
| --- | --- |
| Identificadores de transición vigentes hacia el estado destino aprobado | La transición al destino aprobado no existe desde el estado actual por ninguna ruta |
| La ruta de dos saltos hacia un destino aprobado (p. ej. Para hacer → En progreso → Realizado) | Transición condicional que no cumple su condición |
| Metadatos técnicos derivables del payload aprobado (ids de campo, formato de fecha del conector) | Campo obligatorio nuevo sin valor derivable del payload aprobado |
| — | Assignee rechazado por el board |
| — | Versión de página distinta de la esperada |
| — | Datos personales de terceros o secretos detectados en el plan (segunda barrera; la primera es que el padre no debe producirlos) |

Nunca inventa contenido: título, descripción, assignee, labels, estado destino y cuerpo de página son intocables.

## Reporte de ejecución

Por operación, con el dato real leído del sistema después de ejecutar: clave creada, estado final del issue tras la transición (leído con una consulta, no asumido del resultado de la herramienta), versión resultante de la página. Ejecución parcial: las operaciones posteriores a un aborto se listan como no ejecutadas. El reporte es el artefacto durable del flujo.

## Conducta ante conector caído o no autorizado

Tanto padre como hijo declaran la falta de acceso y se detienen. Ninguno infiere el estado del sistema remoto ni degrada en silencio.
