# Feature Specification: Portar estándar agnóstico desde workspace CIAM

**Feature Branch**: `001-portar-skills-rules`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Portar al repo base agéntico (claude-agentic-base) el contenido agnóstico del workspace CIAM (df-ciam-workspace) para convertirlo en el estándar de mis proyectos personales: reglas depuradas de referencias Cencosud, skills confluence-docs / jira-management / visual-docs parametrizadas, conexión Atlassian personal vía MCP oficial, skill custom speckit-git-commit adaptada, y extracción de referencias genéricas (trampas de JQL, fixtures de prosa)."

## Contexto

El workspace corporativo `df-ciam-workspace` acumuló durante meses un método de trabajo maduro: 11 reglas de proyecto, skills de gestión documental (Confluence), gestión de tablero (Jira) y documentación visual, más un flujo SDD con spec-kit. Ese método es mayoritariamente agnóstico, pero está entretejido con referencias corporativas concentradas en tres vectores: el alias MCP `atlassian-cencosud`, un `cloudId` hardcodeado repetido en 6 archivos, y los datos del board 14186 / proyecto CIAM (ids de transiciones, labels, custom fields, claves de issue).

Este feature porta el método al repo base personal `claude-agentic-base`, que actúa como plantilla estándar para proyectos personales. Las decisiones de alcance ya fueron tomadas por el dueño del repo en ronda interactiva el 06-09-2026 (ver Assumptions).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reglas de trabajo depuradas y completas (Priority: P1)

Como dueño del repo base, al iniciar cualquier proyecto personal desde esta plantilla quiero contar con el set completo de reglas de trabajo evolucionadas en CIAM (fechas, prevención de alucinaciones, documentación, seguridad, flujo, ramas SDD, nomenclatura, continuidad, interacción, punteros vs. réplicas), sin ninguna referencia corporativa, renumeradas de forma consecutiva.

**Why this priority**: Las reglas son la base del estándar; todo lo demás (skills, flujo SDD) las referencia. Sin ellas, las skills portadas citarían reglas inexistentes.

**Independent Test**: Listar `.claude/rules/` y verificar numeración consecutiva sin huecos; grep de términos corporativos devuelve cero ocurrencias; cada regla nueva es legible y autocontenida.

**Acceptance Scenarios**:

1. **Given** el repo base con reglas 00-04 de primera generación, **When** se completa la portación, **Then** existen las reglas 00-09 en versión CIAM depurada (00-04 reemplazadas, 05 ramas-y-flujo-sdd, 06 nomenclatura-agentica, 07 continuidad-y-contexto, 08 interaccion-y-decisiones, 09 punteros-y-replicas) y no existe regla de Cencoflow.
2. **Given** las reglas portadas, **When** se busca `Cencosud`, `CIAM`, `Cencoflow`, `cencosud.atlassian.net` o claves `CIAM-\d+` en `.claude/rules/`, **Then** el resultado es cero ocurrencias.
3. **Given** la regla de nomenclatura agéntica, **When** se lee, **Then** el sufijo de proyecto aparece parametrizado como patrón (`<proyecto>`) y no como identificador corporativo, y los ejemplos e inventario de deuda del repo CIAM fueron reemplazados o eliminados.

---

### User Story 2 - Gestión documental y de tablero con Atlassian personal (Priority: P2)

Como dueño del repo base, quiero las skills `confluence-docs` y `jira-management` operativas contra mi cuenta Atlassian personal: generar/auditar/consultar/publicar documentación con gate de aprobación, y administrar tableros Jira con gate por operación, sin ningún dato del tenant corporativo.

**Why this priority**: Es el motivo declarado del feature ("dejar las skills como estándar para manejar mis proyectos personales" con "mi configuración personal de Atlassian"). Depende de que las reglas (US1) existan porque las skills las citan.

**Independent Test**: Invocar cada skill en modo consulta contra la cuenta personal y verificar que resuelve el sitio/cloudId en runtime sin valores precargados; revisar que los parámetros por proyecto están declarados como pendientes.

**Acceptance Scenarios**:

1. **Given** el repo base, **When** se lista `.claude/skills/`, **Then** existen `confluence-docs` y `jira-management` (nombres sin sufijo corporativo) con frontmatter válido que incluye campo `name` y `description`.
2. **Given** cualquier archivo de ambas skills, **When** se busca el cloudId corporativo (`e98853f7-4b51-4e56-972c-6060aab3fa3d`), ids de proyecto/board/transiciones (18698, 14186, 10670, ids 11-61), labels corporativas (`ciam-management`, `uroboros`) o el prefijo `mcp__atlassian-cencosud__`, **Then** el resultado es cero ocurrencias.
3. **Given** la skill `jira-management`, **When** se lee su sección de parámetros por proyecto (proyecto, board, tipo de issue, transiciones, labels, campos), **Then** cada parámetro está marcado como `Pendiente de configurar` con instrucción de cómo resolverlo en vivo, nunca con un valor inventado ni corporativo.
4. **Given** la configuración del repo, **When** se lee `.mcp.json`, **Then** existe un servidor `atlassian` apuntando al MCP oficial de Atlassian (OAuth) sin credenciales ni valores sensibles en el archivo.
5. **Given** una sesión con el servidor `atlassian` autorizado con la cuenta personal, **When** una skill necesita el cloudId, **Then** lo resuelve en runtime (vía descubrimiento de recursos accesibles) en lugar de leerlo de un valor persistido.
6. **Given** la mecánica de edición de Jira, **When** se lee la skill, **Then** conserva la secuencia leer → componer → escribir → releer y la advertencia de que la edición de labels reemplaza en lugar de agregar.

---

### User Story 3 - Documentación visual portable (Priority: P2)

Como dueño del repo base, quiero la skill `visual-docs` (sitios HTML de revisión técnica navegables por `file://`, con sistema de diagramas y wireframes) disponible como estándar, con sus scripts, referencias, starter y suite de tests funcionando tras el renombre.

**Why this priority**: Es el paquete más portable (cero acoplamiento corporativo en contenido) y entrega valor independiente de Atlassian; solo requiere renombre y ajuste de rutas internas.

**Independent Test**: Ejecutar la suite de tests de la skill renombrada y verificar que pasa completa.

**Acceptance Scenarios**:

1. **Given** el repo base, **When** se lista `.claude/skills/visual-docs/`, **Then** contiene SKILL.md, references, scripts, assets/starter y tests completos.
2. **Given** la suite de tests de la skill, **When** se ejecuta, **Then** pasa completa con las rutas actualizadas al nuevo nombre.
3. **Given** la description de la skill, **When** se lee, **Then** no remite a skills corporativas inexistentes en este repo.

---

### User Story 4 - Flujo de commit disciplinado y referencias extraídas (Priority: P3)

Como dueño del repo base, quiero la skill custom `speckit-git-commit` adaptada (staging acotado, bloqueo de commit en rama principal, detención ante patrones de secretos, sin push automático) y dos referencias genéricas extraídas del conocimiento CIAM: las trampas de consulta JQL en Jira Cloud (TR-01..TR-07) y los fixtures de evaluación de prosa.

**Why this priority**: Complementos de alto valor pero no bloqueantes; el estándar funciona sin ellos.

**Independent Test**: Invocar la skill de commit en la rama del feature y verificar staging acotado y formato de mensaje; leer las referencias extraídas y verificar que no contienen datos del tenant corporativo.

**Acceptance Scenarios**:

1. **Given** la skill `speckit-git-commit` portada, **When** se lee, **Then** sus rutas apuntan a archivos de este repo, prohíbe staging masivo, bloquea commit en rama principal y no propone push.
2. **Given** la referencia de trampas JQL, **When** se lee, **Then** describe las 7 trampas de forma genérica para cualquier Jira Cloud (estado localizado que no valida, categorías de estado que mezclan resoluciones, operadores que no validan identidad, resoluciones incompletas, absorción de estados en espera, transiciones que no enumeran estados) junto con la taxonomía de manifestación (error / vacío / resultado plausible) y la disciplina de cuadrar particiones contra censo, sin claves ni cifras del tablero corporativo.
3. **Given** los fixtures de prosa portados dentro de `confluence-docs`, **When** se leen, **Then** tratan temas neutros y el ejemplo conforme no contiene nombres de personas.

---

### Edge Cases

- **Colisión de nombres**: `confluence-docs`, `jira-management` y `visual-docs` no deben colisionar con skills personales globales ni de plugins ya instalados; verificar antes de crear.
- **Réplica deliberada con configuración global**: las reglas de continuidad e interacción portadas al proyecto tienen equivalentes en la configuración global del usuario (`~/.claude-personal/rules/05` y `06`). Es el mismo patrón de réplica que ya existe para 00-04; la regla de punteros-y-réplicas portada debe reconocer esta convivencia (la copia del proyecto viaja con el repo; la global no).
- **Línea base de prosa no transferible**: el detector de prosa de `confluence-docs` depende de una línea base medida sobre el corpus CIAM; copiarla sería una réplica caduca. Debe quedar marcada como `Pendiente de recomputar` sobre el corpus del proyecto destino.
- **Parámetros sin valor aún**: el usuario todavía no define espacio Confluence ni proyecto Jira personales; las skills deben operar en modo consulta/descubrimiento y declarar el vacío, no rellenarlo.
- **Sesiones sin el servidor MCP autorizado**: si `atlassian` no está autorizado (OAuth pendiente), las skills deben indicar cómo autorizarlo en vez de fallar en silencio.
- **Historia previa del repo CIAM**: anécdotas fechadas y evidencia local del repo origen (relevamientos, pruebas de protección de rama) no se copian como historia propia; se eliminan o se reetiquetan como caso ajeno citado.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El repo base MUST contener las reglas 00-09 en `.claude/rules/`, numeradas consecutivas: 00 lenguaje-y-formato, 01 prevencion-alucinaciones, 02 documentacion-y-entregables, 03 seguridad-y-secretos, 04 flujo-y-metodo (versiones CIAM depuradas que reemplazan a las actuales), 05 ramas-y-flujo-sdd, 06 nomenclatura-agentica, 07 continuidad-y-contexto, 08 interaccion-y-decisiones, 09 punteros-y-replicas (nombres de archivo en español, consistentes con las existentes).
- **FR-002**: La regla de Cencoflow del repo origen MUST NOT portarse; ningún archivo portado puede referenciar Cencoflow, DoR/DoD corporativos ni URLs `cencosud.atlassian.net`.
- **FR-003**: Las skills MUST llamarse `confluence-docs`, `jira-management` y `visual-docs`, con frontmatter que incluya `name` y `description` (corrigiendo la ausencia de `name` en las skills origen).
- **FR-004**: Ningún archivo portado MUST contener el cloudId corporativo, ids de proyecto/board/tipo de issue/transiciones/custom fields del tenant Cencosud, labels corporativas, claves de issue `CIAM-*`, nombres de personas ni el prefijo de servidor `atlassian-cencosud`.
- **FR-005**: `.mcp.json` MUST declarar un servidor `atlassian` apuntando al MCP oficial de Atlassian con autenticación OAuth, sin credenciales en el archivo; las entradas de ejemplo (`ejemplo-stdio`, `ejemplo-http`) pueden conservarse o retirarse pero no interferir.
- **FR-006**: Las skills de Atlassian MUST referenciar las herramientas del servidor `atlassian` y resolver cloudId/sitio en runtime mediante descubrimiento de recursos accesibles; ningún identificador de tenant persiste en el repo.
- **FR-007**: `jira-management` MUST declarar sus parámetros por proyecto (proyecto, board, tipo de issue, transiciones, labels, campos de creación) como `Pendiente de configurar`, con el procedimiento para resolverlos en vivo, y MUST conservar la mecánica de seis modos con gate de aprobación por operación de escritura y la secuencia leer → componer → escribir → releer para ediciones.
- **FR-008**: `confluence-docs` MUST conservar los cuatro modos (generar, auditar, consultar, publicar) con gate de aprobación y pre-flight de versión; su catálogo de reglas se porta depurado, con la línea base de prosa marcada `Pendiente de recomputar` y las reglas atadas a claves de issue corporativas parametrizadas al patrón del proyecto destino.
- **FR-009**: Las plantillas de entregables (doc técnica, ADR, bitácora, resumen) MUST portarse dentro de `confluence-docs` y la regla 02 MUST remitir a ellas mediante puntero, no duplicarlas.
- **FR-010**: `visual-docs` MUST portarse completa (SKILL, references, scripts, starter, tests) y su suite de tests MUST pasar tras actualizar las rutas internas al nuevo nombre.
- **FR-011**: La skill `speckit-git-commit` MUST portarse adaptada a este repo: staging acotado a la feature activa, prohibición de staging masivo, bloqueo en rama principal, detención ante patrones de secretos, mensajes `tipo: descripción` en español, sin push ni PR automáticos.
- **FR-012**: MUST existir una referencia genérica de trampas de consulta JQL (las 7 trampas, taxonomía de manifestación y disciplina de verificación por censo) sin datos del tenant corporativo, ubicada donde `jira-management` pueda remitir a ella.
- **FR-013**: Los siguientes activos del repo origen MUST NOT portarse: censo del tablero (`estandar-tablero.md` salvo la extracción de FR-012), constitución CIAM, `template-history.md`, transcripciones de ejecuciones reales, skills `team-ciam`, `cencoflow-ciam`, `jira-ciam-qa`, `mosaic-*`, `bigquery-*`, `development-repositories-ciam` y agentes del repo origen.
- **FR-014**: El repo origen MUST tratarse como solo lectura; ninguna operación de este feature lo modifica.
- **FR-015**: El README del repo base MUST actualizarse para reflejar el inventario real de reglas y skills tras la portación.

### Key Entities

- **Regla**: documento normativo en `.claude/rules/` con número de orden y nombre; define método de trabajo transversal.
- **Skill**: paquete en `.claude/skills/<nombre>/` con SKILL.md (frontmatter `name`, `description`, `allowed-tools`) y archivos de apoyo; define capacidad operativa invocable.
- **Parámetro por proyecto**: valor que varía entre proyectos (espacio Confluence, proyecto/board Jira, labels, transiciones); en la plantilla vive como `Pendiente de configurar` con procedimiento de resolución, nunca como valor heredado.
- **Conexión MCP**: entrada en `.mcp.json` que da acceso a un servicio externo; se autentica por OAuth en la sesión, sin material sensible en el repo.
- **Referencia extraída**: conocimiento genérico destilado de la experiencia del repo origen (trampas JQL, fixtures de prosa), separado de los datos que lo originaron.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: La búsqueda de términos corporativos (`Cencosud`, `CIAM`, `Cencoflow`, `cencosud.atlassian.net`, cloudId `e98853f7`, `atlassian-cencosud`) sobre `.claude/` y `.mcp.json` devuelve cero ocurrencias (la carpeta `specs/` queda exenta por documentar la procedencia).
- **SC-002**: `.claude/rules/` contiene exactamente las 10 reglas 00-09 previstas, sin huecos de numeración ni regla Cencoflow.
- **SC-003**: Las tres skills portadas existen con frontmatter válido (`name` + `description`) y ninguna colisiona con skills globales o de plugins de la sesión.
- **SC-004**: La suite de tests de `visual-docs` pasa completa en el primer intento post-renombre.
- **SC-005**: Todo parámetro por proyecto en las skills de Atlassian está marcado `Pendiente de configurar`; cero valores del tenant corporativo y cero valores inventados.
- **SC-006**: Una sesión nueva del repo puede autorizar el servidor `atlassian` por OAuth y ejecutar una consulta de descubrimiento (sitios/recursos accesibles) sin editar ningún archivo del repo.
- **SC-007**: El feature completo queda trazado por el flujo SDD del propio repo: spec, plan, tasks y commits en la rama `001-portar-skills-rules`, sin commits directos a `main`.

## Assumptions

- Las cuatro decisiones de alcance fueron tomadas por el dueño del repo en ronda interactiva el 06-09-2026: (1) spec-kit oficial v0.13.0 ya instalado en este repo + portar `speckit-git-commit` custom; (2) nombres de skills sin sufijo de proyecto; (3) reglas 00-04 se reemplazan por las versiones CIAM depuradas; (4) conexión Atlassian vía MCP oficial en `.mcp.json` con alias `atlassian`.
- El dueño del repo tiene o tendrá una cuenta Atlassian personal con acceso OAuth al MCP oficial; el sitio/cloudId concreto se resuelve en runtime y no es requisito para completar este feature (suposición no verificada en esta sesión).
- La convivencia de reglas de proyecto con sus equivalentes globales en `~/.claude-personal/rules/` es réplica deliberada y aceptada: la copia del proyecto viaja con la plantilla al clonar; la global no.
- La constitución del proyecto (`.specify/memory/constitution.md`) permanece como template vacío; llenarla queda fuera de alcance (pendiente opcional vía flujo de constitución).
- Los mensajes de commit siguen la convención del repo: `tipo: descripción` en español, sin atribución automática; no hay push ni merge sin confirmación explícita del dueño.
- El andamiaje de spec-kit instalado en esta rama forma parte del alcance del feature ("agregar spec-kit para trabajar en este repo") y se integra a `main` junto con la portación al mergear.

## Out of Scope

- Configurar valores personales concretos (espacio Confluence, proyecto/board Jira, labels): ocurre por proyecto, con las skills en modo descubrimiento.
- Portar agentes, contracts, workflows u output-styles del repo origen.
- Redactar la constitución del repo base.
- Publicar (push/merge) sin confirmación del dueño.
