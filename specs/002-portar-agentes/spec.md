# Feature Specification: Portar agentes del workspace CIAM al estándar de la base

**Feature Branch**: `002-portar-agentes`

**Created**: 2026-09-07

**Status**: Draft

**Input**: User description: "Portar al repo base los agentes del workspace CIAM adaptados al estándar personal, en fases: (1) el trío del patrón plan→gate→ejecución; (2) el agente developer completo con su infraestructura; (3) retiro de los cuatro agentes genéricos con reescritura de la delegación de la regla 04 y actualización del README."

## Contexto

El feature 001 dejó la base con las skills, reglas y conexión Atlassian del estándar personal, pero sin agentes de rol: los cuatro agentes actuales (`arquitecto`, `documentador`, `revisor-codigo`, `revisor-proyecto`) son utilidades genéricas de la plantilla original. El workspace CIAM maduró tres agentes con un patrón de gobernanza valioso — separación decidir/aprobar/ejecutar con planes sellados por hash — que este feature porta completo, junto con la infraestructura del agente desarrollador y el retiro de los genéricos.

La clasificación previa (workflow de 5 lectores, 06-09-2026, registrada en `research.md` de esta feature) estableció: `product-owner` y `atlassian-executor` son PARAMETRIZABLES con una sola dependencia dura faltante (el contract `write-plan`); `developer` es ESPECÍFICO y su portación completa exige además la skill de repositorios de desarrollo (~5.900 líneas, 8 scripts bash), el contract `publish-authorization`, el índice de specs y dos contratos de diseño. El dueño del repo eligió el alcance completo en ronda interactiva, con el esfuerzo señalado, y eligió también retirar los cuatro agentes genéricos asumiendo la reescritura de la regla 04 que eso implica.

## Clarifications

### Session 2026-09-07

- Q: Dado que `arquitecto`, `documentador` y `revisor-codigo` ya existen en `~/.claude-personal/agents/` y el CLAUDE.md global los nombra, ¿cómo debe quedar la delegación de la regla 04 tras retirarlos del repo? → A: Citarlos como capacidad de la configuración personal, no de la plantilla. El retiro es deduplicación, no pérdida de capacidad; `revisor-proyecto`, que solo existe en el repo, se retira y no se cita.
- Q: La rama `backup/002-portar-agentes` conserva los artefactos ya portados y verificados de la primera corrida. ¿Cómo se usa en la implementación? → A: Cada fase recupera del respaldo los archivos que le tocan y los re-verifica contra sus criterios de aceptación, corrigiendo lo que falle; no se re-portan desde el origen.
- Q: ¿Qué exige SC-004 para dar por buenos los 8 scripts de `development-repositories`? → A: Sintaxis (`bash -n`), barrido corporativo en cero y corrida funcional real contra el fixture sintético (`status`, `fetch`, `pull`) verificando que cada fila clasifique como el fixture declara.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Patrón plan→gate→ejecución operativo (Priority: P1)

Como dueño de la base, quiero el trío del patrón de escritura gobernada: un agente `product-owner` que revisa tableros y documentación con criterio de producto y **nunca escribe** (produce planes), el contract `write-plan` que fija la estructura del plan y su marca de aprobación sellada con hash, y un agente `atlassian-executor` que verifica el sello y ejecuta exactamente lo aprobado, releyendo el sistema después de cada operación.

**Why this priority**: Es el mecanismo de gobernanza central (Principio IV de la constitución: escritura con gate) y las tres piezas se necesitan mutuamente; el resto del feature se apoya en este patrón.

**Independent Test**: Con los tres artefactos portados, reproducir la prueba de ida y vuelta del hash del contract (sellar una sección de operaciones, verificarla, alterarla, verificar que el sello caduca) y comprobar que ningún artefacto contiene referencias corporativas.

**Acceptance Scenarios**:

1. **Given** la base sin `.claude/contracts/`, **When** se completa la fase, **Then** existen `.claude/agents/product-owner.md`, `.claude/agents/atlassian-executor.md` y `.claude/contracts/write-plan.md`, los tres con cero referencias corporativas y tools con prefijo `mcp__atlassian__`.
2. **Given** el agente `product-owner`, **When** se lee su frontmatter y cuerpo, **Then** declara solo herramientas de lectura más la escritura del archivo de plan, conserva los mecanismos de ceros calificados, formato de hallazgo, frontera de rol y gate absoluto, y sus parámetros por proyecto (tablero de gestión, tablero QA opcional, espacio Confluence, página de roster) figuran como `Pendiente de configurar`.
3. **Given** el agente `atlassian-executor`, **When** se lee, **Then** declara la clase de agente ejecutor conforme a la regla 06, conserva el protocolo ordenado de verificación (marca presente → bien formada → hash vigente → alcance total → catálogo por operación) y reporta cada operación con lectura real del sistema, nunca con el acuse de la herramienta.
4. **Given** el contract `write-plan`, **When** se ejecuta su comando de verificación de hash sobre un plan de prueba sintético, **Then** la prueba de ida y vuelta pasa (sellar → verificar OK → alterar → caducado) y queda citada como evidencia de esta feature.
5. **Given** la skill `confluence-docs`, **When** se lee su modo publicar, **Then** documenta la equivalencia entre un plan sellado con hash aprobado y la aprobación explícita que el modo exige (edición acompañante), sin que el contract y la skill se repliquen mutuamente.
6. **Given** el catálogo de operaciones del contract, **When** se lee, **Then** sus filas son plantilla con parámetros (`Pendiente de configurar` para tableros e invariantes del proyecto), citando a `jira-management` y `confluence-docs` como fuentes, y conserva como patrón la fila de "épica ancla que nunca es destino de escritura".

---

### User Story 2 - Agente developer con su infraestructura completa (Priority: P2)

Como dueño de la base, quiero el agente `developer` (abre desarrollos de punta a punta: rama, spec de desarrollo, commit acotado, registro en índice; publica solo con autorización estructurada) junto con toda su infraestructura: la skill `development-repositories` parametrizada (scripts de estado y preparación del workspace multi-repo, catálogo de repositorios, índice de specs, template de spec de desarrollo), el contract `publish-authorization`, y los contratos de diseño `developer-flow` y `operation-report` adaptados como artefactos de esta spec.

**Why this priority**: Decisión explícita del dueño (alcance completo pese al esfuerzo señalado). Depende de US1: el developer produce planes de escritura conforme al contract `write-plan` y los ejecuta `atlassian-executor`.

**Independent Test**: Los scripts de la skill corren contra un catálogo de prueba sintético sin errores de sintaxis ni rutas corporativas; la secuencia de nueve verificaciones de `publish-authorization` es reproducible con un bloque sintético; ningún artefacto contiene referencias corporativas ni punteros a rutas inexistentes.

**Acceptance Scenarios**:

1. **Given** la base tras la fase, **When** se lista `.claude/`, **Then** existen `agents/developer.md`, `skills/development-repositories/` (SKILL, scripts, templates, catálogo, índice) y `contracts/publish-authorization.md`, con cero referencias corporativas.
2. **Given** el catálogo de repositorios de la skill, **When** se lee, **Then** no contiene ningún repositorio real: es una estructura plantilla con entradas `Pendiente de configurar` y el procedimiento para poblarla por proyecto.
3. **Given** los 8 scripts de la skill, **When** se verifica su sintaxis y se corre el recorrido multi-repo contra el catálogo sintético de prueba, **Then** ninguno falla por sintaxis, ninguno contiene rutas o nombres del workspace de origen, y los estados reportados coinciden con los que el fixture declara esperados para cada verbo.
4. **Given** el agente `developer`, **When** se lee, **Then** sus punteros resuelven: contratos de diseño en `specs/002-portar-agentes/contracts/` (developer-flow, operation-report adaptados), contracts vivos en `.claude/contracts/`, reglas por su numeración de la base (la regla de punteros es la 09, no la 10), y skills por sus nombres portados.
5. **Given** el contract `publish-authorization`, **When** se reproduce su verificación con un bloque sintético, **Then** las nueve verificaciones ordenadas clasifican correctamente al menos los casos tipados: `ausente` (sin bloque, y petición en prosa), `malformada` (campo faltante, y hash alterado) y `no coincide` (campo consistente pero distinto de lo operado).
6. **Given** la tabla de restricciones del developer, **When** se lee, **Then** cada "nunca" declara su garantía (Permisos vs Proceso) según el patrón de la base.

---

### User Story 3 - Base sin agentes genéricos y referencias coherentes (Priority: P3)

Como dueño de la base, quiero retirar los cuatro agentes genéricos (`arquitecto`, `documentador`, `revisor-codigo`, `revisor-proyecto`) para que la plantilla quede solo con los agentes de rol portados, con la sección de delegación de la regla 04 reescrita y el README actualizado, sin dejar ninguna remisión rota y sin perder capacidad: tres de los cuatro siguen disponibles desde la configuración personal de quien opera, y la regla lo declara en vez de suponerlo.

**Why this priority**: Decisión explícita del dueño (contra recomendación, con la consecuencia asumida). Va al final porque el retiro solo es coherente cuando los agentes de rol ya existen.

**Independent Test**: `ls .claude/agents/` muestra exactamente los tres agentes de rol; ninguna mención de los retirados en `.claude/` ni en README los presenta como artefactos versionados de la plantilla (fuera de `specs/`), y toda mención admitida declara su procedencia externa.

**Acceptance Scenarios**:

1. **Given** la base tras la fase, **When** se lista `.claude/agents/`, **Then** contiene exactamente `product-owner.md`, `atlassian-executor.md` y `developer.md`.
2. **Given** la regla `04-flujo-y-metodo.md`, **When** se lee su sección de delegación, **Then** delega en los agentes de rol de la base y distingue el origen de cada capacidad citada: los de rol vienen de la plantilla, los genéricos de revisión y exploración vienen de la configuración personal de quien opera y no se versionan aquí; no cita `revisor-proyecto`, y la distinción queda declarada conforme a la regla 09.
3. **Given** el README, **When** se lee, **Then** su sección de agentes describe los tres agentes de rol, el patrón plan→gate→ejecución y el directorio `.claude/contracts/`, sin presentar los genéricos retirados como artefactos de la plantilla.
4. **Given** el retiro de `revisor-proyecto`, **When** se ejecuta la fase, **Then** queda declarado que ese agente no tiene equivalente en la configuración personal y que su retiro lo elimina de la configuración activa (recuperable solo desde el historial de git).

---

### Edge Cases

- **Scripts bash acoplados al layout multi-repo del origen**: los 8 scripts (~4.800 líneas) pueden asumir repos hermanos `df-*` o rutas del workspace CIAM; toda referencia se parametriza vía el catálogo, y lo que no sea parametrizable se documenta como límite declarado, no se disimula.
- **Punteros de agentes a contratos de diseño**: el patrón del origen hace que el agente cite contratos en `specs/<feature>/contracts/` como autoridad de diseño. Los adaptados viven en `specs/002-portar-agentes/contracts/`; ningún puntero puede citar rutas del workspace de origen (regla 09: un puntero cita un identificador que existe).
- **Divergencia regla 04 proyecto vs global**: la copia del proyecto divergirá del set global del usuario, que nombra `revisor-codigo` y `arquitecto` como subagentes disponibles. La divergencia es de **origen declarado**, no de contenido: esos agentes existen en la configuración personal (`~/.claude-personal/agents/`, verificado el 07-09-2026) y siguen operativos tras el retiro; lo que cambia es que la plantilla deja de versionar una copia propia. Se anota en la regla conforme a la regla 09, no se silencia.
- **`revisor-proyecto` sin equivalente global**: a diferencia de los otros tres, solo existe en el repositorio. Retirarlo lo elimina de la configuración activa; se declara al ejecutarlo en vez de presentarlo como una deduplicación más.
- **Equivalencia de aprobación en confluence-docs**: el contract afirma que la skill documenta la equivalencia hash-sellado ≈ aprobación explícita; hoy la base no la documenta. La edición acompañante debe hacerse en la misma fase que el contract, o el contract nacería citando algo inexistente.
- **spec-index dentro de la skill**: el índice de desarrollos vive dentro de `development-repositories` en el origen; se porta como plantilla vacía con su celda de recuento recomputable y el procedimiento de registro.
- **Agentes de rol en una plantilla sin roster**: `product-owner` y `developer` son roles sin roster en la base; cada agente declara que al adoptarse en un proyecto concreto se renombra a `<rol>-<proyecto>` y se reconcilia con el roster real (regla 06).
- **Fechas de copias declaradas del origen**: las copias declaradas (principios de output-style inlined, estándares citados) se re-anclan a la fecha de portación con su nueva fuente; las fechas históricas del workspace CIAM no se arrastran como historia propia.
- **Modelos por agente**: los frontmatter del origen fijan modelos por rol (analítico vs ejecutor); se conservan como están por ser genéricos de la plataforma.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La base MUST contener `.claude/agents/product-owner.md`: rol de lectura y propuesta con gate absoluto (nunca escribe en Jira/Confluence; toda escritura viaja como plan), tools de lectura Atlassian con prefijo `mcp__atlassian__` más la escritura del archivo de plan, y parámetros por proyecto `Pendiente de configurar` (tablero de gestión, tablero QA opcional, espacio Confluence, página de roster).
- **FR-002**: La base MUST contener `.claude/agents/atlassian-executor.md`: agente ejecutor nombrado por función con declaración de clase conforme a la regla 06, que solo ejecuta planes con marca de aprobación válida, verifica el hash antes de tocar cualquier sistema, rehúsa por protocolo ordenado, delega Confluence al modo publicar de `confluence-docs` y reporta con lectura real post-escritura.
- **FR-003**: La base MUST contener `.claude/contracts/write-plan.md` (directorio nuevo): orden fijo de secciones con delimitador de cierre, marca de aprobación con hash de la sección de operaciones sellada solo por la sesión principal, comando de verificación reproducible, catálogo cerrado de operaciones con filas plantilla parametrizadas, frontera de resolución del ejecutor y conducta ante conector caído. Las entidades del plan (plan, operación, marca, reporte) MUST quedar definidas en el contract o en los artefactos de esta spec, sin punteros al workspace de origen.
- **FR-004**: La prueba de ida y vuelta del hash del contract MUST re-ejecutarse en la base con un plan sintético y citarse como evidencia de esta feature; el contract no puede citar la evidencia del workspace de origen.
- **FR-005**: `confluence-docs` (modo publicar) MUST documentar la equivalencia entre un plan sellado aprobado y la aprobación explícita del gate, en la misma fase en que se porta el contract que la afirma.
- **FR-006**: La base MUST contener `.claude/agents/developer.md`: abre desarrollos (rama, spec de desarrollo desde issue/documentación/código, commit acotado a una sola ruta verificable, registro en el índice), gestiona el ciclo de vida de specs de desarrollo, publica solo con autorización de publicación válida, nunca escribe código de producto, nunca abre PR, y toda escritura a Jira/Confluence viaja como plan del contract `write-plan`.
- **FR-007**: La base MUST contener la skill `.claude/skills/development-repositories/` portada completa: SKILL.md, los 8 scripts, el template de spec de desarrollo, el índice de specs como plantilla vacía recomputable, y el catálogo de repositorios como estructura `Pendiente de configurar` sin ningún repositorio real del origen.
- **FR-008**: Los scripts de la skill MUST quedar libres de rutas, nombres de repos y supuestos del workspace de origen; toda configuración específica se lee del catálogo parametrizado. Un script cuyo acoplamiento no sea parametrizable declara su límite en la skill.
- **FR-009**: La base MUST contener `.claude/contracts/publish-authorization.md`: bloque de autorización por par (repositorio, rama) con hash de línea canónica, secuencia de nueve verificaciones ordenadas con vocabulario tipado de fallo, lista negativa explícita (sin PR, sin force, sin delete, sin rama por defecto), y declaración de que la garantía es de proceso.
- **FR-010**: Los contratos de diseño `developer-flow.md` y `operation-report.md` MUST adaptarse como artefactos en `specs/002-portar-agentes/contracts/`, y los punteros del agente `developer` MUST resolver a ellos y a los identificadores de esta spec (no a FR/SC de specs del origen).
- **FR-011**: Los cuatro agentes genéricos (`arquitecto`, `documentador`, `revisor-codigo`, `revisor-proyecto`) MUST retirarse de `.claude/agents/`. Tres de ellos (`arquitecto`, `documentador`, `revisor-codigo`) existen además en la configuración personal del usuario, de modo que su retiro del repositorio es **deduplicación** y no elimina la capacidad; `revisor-proyecto` solo existe en el repositorio y su retiro sí lo elimina de la configuración activa, lo que MUST declararse al ejecutarlo.
- **FR-012**: La sección "Delegación a subagentes" de `.claude/rules/04-flujo-y-metodo.md` MUST reescribirse para delegar en los agentes de rol de la base y MUST distinguir explícitamente su origen: los agentes de rol vienen de la plantilla (versionados en el repositorio) y los genéricos de exploración y revisión, si están disponibles, vienen de la configuración personal de quien opera, no de la plantilla. MUST declarar esa distinción de origen conforme a la regla 09 (una capacidad citada no versionada aquí es un puntero, no una promesa de la plantilla), y MUST NOT citar `revisor-proyecto`, que no existe en ninguno de los dos ámbitos tras el retiro.
- **FR-013**: El README MUST actualizarse: sección de agentes con los tres de rol y el patrón plan→gate→ejecución, mención del directorio `.claude/contracts/`, y retiro de las menciones a los genéricos como artefactos de la plantilla (incluidas la lista de verificación y los pasos de instalación); si los menciona, MUST ser como capacidad externa al repositorio, con esa procedencia declarada.
- **FR-014**: Ningún artefacto portado o editado MUST contener referencias corporativas (Cencosud, CIAM, Cencoflow, cloudId, boards 14186/14516/14530, ids 10670, labels corporativas, claves `CIAM-*`, épica CIAM-87, repos `df-*`, URLs de instancia, nombres de skills `-ciam`, rutas de specs del origen); `specs/` queda exenta por documentar la procedencia.
- **FR-015**: Los nombres siguen el precedente D2 del feature 001: sin sufijo de proyecto, en inglés bajo `.claude/`; cada agente de rol declara en su cuerpo el renombre `<rol>-<proyecto>` al adoptarse en un proyecto concreto.
- **FR-016**: El repo origen MUST tratarse como solo lectura, y las copias declaradas re-ancladas a la fecha y fuente de esta portación.

### Key Entities

- **Agente de rol**: artefacto en `.claude/agents/` que encarna un rol (product-owner, developer) con frontera declarada; en la plantilla no ocupa roster y documenta su renombre por proyecto.
- **Agente ejecutor**: clase declarada de la regla 06; ejecuta operaciones aprobadas sin criterio propio sobre el contenido.
- **Contract**: documento en `.claude/contracts/` que es autoridad viva en runtime entre agentes; se cita, no se replica.
- **Plan de escritura**: artefacto que un agente de rol produce y la sesión principal sella; unidad de aprobación total (una corrección = un plan nuevo).
- **Autorización de publicación**: bloque sellado por par (repositorio, rama) que habilita un push único, sin force ni PR.
- **Catálogo de repositorios**: parámetro por proyecto de `development-repositories`; en la plantilla, estructura vacía con procedimiento de poblado.
- **Índice de specs de desarrollo**: registro plantilla con celda de recuento recomputable donde el developer anota cada desarrollo abierto.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El barrido corporativo (patrones de FR-014) sobre `.claude/` y README devuelve cero ocurrencias; `specs/` exenta.
- **SC-002**: `.claude/agents/` contiene exactamente 3 archivos: `product-owner.md`, `atlassian-executor.md`, `developer.md`, cada uno con frontmatter válido (`name` igual al archivo, `description`, tools con prefijo `mcp__atlassian__` donde aplique).
- **SC-003**: `.claude/contracts/` contiene exactamente `write-plan.md` y `publish-authorization.md`; la prueba de ida y vuelta del hash de `write-plan` pasa en la base y su evidencia queda citada en esta spec.
- **SC-004**: Los 8 scripts de `development-repositories` pasan `bash -n`, ninguno contiene referencias del barrido de FR-014, y la corrida funcional contra el fixture sintético de la skill clasifica cada fila como el propio fixture declara: `status` distingue las cuatro presencias y sale con código 2 ante un repositorio ausente, `fetch` revela el atrasado, y `pull` actualiza solo al atrasado dejando intactos el sucio (saltado por cambios sin guardar) y el vacío (saltado por falta de upstream). Lo que el fixture declara fuera de su alcance (red, colisión de ruta destino) queda como límite declarado, no como cobertura.
- **SC-005**: Todo puntero de los artefactos portados resuelve a un archivo existente del repo (verificable enumerando las rutas citadas); cero punteros a rutas del workspace de origen.
- **SC-006**: Fuera de `specs/`, ninguna mención de los agentes retirados los presenta como artefactos de la plantilla: `revisor-proyecto` no aparece en ningún archivo (grep cero), y toda ocurrencia de `arquitecto`, `documentador` o `revisor-codigo` está acompañada de su procedencia declarada (configuración personal de quien opera, no versionada en este repositorio).
- **SC-007**: El feature queda trazado por el flujo SDD en la rama `002-portar-agentes`, sin commits directos a `main`, con el Constitution Check del plan evaluado contra la constitución v1.0.0.

## Assumptions

- Esta spec es reutilización declarada de la elaborada en la primera corrida del feature (06-09-2026, conservada en la rama `backup/002-portar-agentes`), recuperada el 07-09-2026 al reiniciar el flujo con validación del dueño fase por fase.
- **Método de implementación acordado (clarificación 07-09-2026)**: cada fase recupera del respaldo los artefactos que le corresponden y los **re-verifica contra sus propios criterios de aceptación**, corrigiendo lo que falle; no se re-portan desde el workspace de origen. La evidencia de esta corrida se produce ejecutando las verificaciones aquí, no citando las del respaldo: un artefacto recuperado que no pase su verificación se corrige o se re-deriva, y eso se declara.
- Las dos decisiones de alcance fueron tomadas por el dueño en ronda interactiva el 06-09-2026, ambas contra la recomendación presentada y con sus consecuencias señaladas: (1) portación completa incluido el developer y su infraestructura (~5.900 líneas adicionales, esfuerzo alto declarado); (2) retiro de los cuatro agentes genéricos, asumiendo la reescritura de la regla 04. Se registran como decisiones informadas del dueño.
- Los nombres sin sufijo siguen el precedente D2 del feature 001; no se reabre esa decisión.
- La clasificación de origen (workflow de 5 lectores, 427k tokens, 06-09-2026) es la fuente del mapa de transformaciones y se consolida en `research.md` de esta feature.
- Los modelos por agente del origen se conservan por ser identificadores genéricos de la plataforma, no datos corporativos.
- La constitución v1.0.0 rige el plan de esta feature (Principios II, III, IV y V aplican directamente).

## Out of Scope

- Portar las skills `team-ciam`, `jira-ciam-qa`, `cencoflow-ciam` (dependencias blandas que se parametrizan como vacíos declarados).
- Configurar valores reales de los parámetros por proyecto (catálogo de repositorios, tableros, espacios).
- Crear roster de roles para la plantilla.
- Push, PR o merge sin confirmación explícita del dueño.
