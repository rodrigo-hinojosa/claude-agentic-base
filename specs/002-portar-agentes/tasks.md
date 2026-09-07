# Tasks: Portar agentes del workspace CIAM al estándar de la base

**Input**: documentos de diseño de `/specs/002-portar-agentes/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md) (D8: método de recuperación), [data-model.md](data-model.md), [contracts/interfaces.md](contracts/interfaces.md), [quickstart.md](quickstart.md)

**Origen de los artefactos**: rama `backup/002-portar-agentes` (punta `7f743f7`), que conserva la portación completa de la primera corrida. Se recupera con `git show backup/002-portar-agentes:<ruta> > <ruta>` o `git checkout backup/002-portar-agentes -- <ruta>`. El workspace de origen (`df-ciam-workspace`) queda como referencia de consulta, no como fuente de esta corrida.

**Dos naturalezas de tarea, y la distinción importa**:

- **Recuperar y verificar**: el artefacto existe en el respaldo. La tarea lo trae, lo contrasta con los criterios de su historia, y corrige o re-deriva lo que falle. Aplica a US1 y US2.
- **Escribir**: el artefacto no existe en el respaldo porque US3 nunca llegó a ejecutarse allí (verificado: `.claude/rules/04-flujo-y-metodo.md` y `README.md` son idénticos a `HEAD`). Se redacta en esta corrida, con el criterio de la clarificación del 07-09-2026 que el respaldo no tenía.

**Gate del dueño**: al cerrar cada fase, la ejecución se detiene y reporta. La fase siguiente no comienza sin su instrucción.

**Tests**: la spec no pide TDD. Las verificaciones son las del [quickstart.md](quickstart.md), ejecutadas en las tareas de cierre de cada historia y registradas en [evidence.md](evidence.md).

## Phase 1: Setup

- [X] T001 Verificar precondiciones en la raíz del repo: rama `002-portar-agentes` activa, `backup/002-portar-agentes` accesible (`git rev-parse`), working tree sin cambios ajenos a la feature, y disponibilidad de `shasum`, `sed` y `git`

## Phase 2: Foundational

**Bloquea a US1 y US2**: ambos contracts viven en el directorio que esta fase crea.

- [X] T002 Crear el directorio `.claude/contracts/` (nuevo en el repositorio, exigido por FR-003 y por el Contrato 2 de `specs/002-portar-agentes/contracts/interfaces.md`)

## Phase 3: User Story 1 — Patrón plan→gate→ejecución (P1)

**Goal**: el trío `product-owner` + `atlassian-executor` + `write-plan` operativo, con la equivalencia de aprobación documentada en `confluence-docs`.

**Independent Test**: quickstart §1 (barrido corporativo), §2 (estado de agentes y contracts) y §3 (ida y vuelta del hash). El patrón funciona sin el `developer`.

- [X] T003 [US1] Recuperar `.claude/contracts/write-plan.md` del respaldo y verificarlo contra los escenarios 1, 4 y 6 de US1: orden fijo de secciones con delimitador de cierre, marca de aprobación con hash de la sección de operaciones, comando de verificación reproducible en macOS, catálogo con filas plantilla `Pendiente de configurar`, patrón de épica ancla conservado, entidades del plan inlined como autoridad única (D5), y cero referencias corporativas
- [X] T004 [P] [US1] Recuperar `.claude/agents/product-owner.md` del respaldo y verificarlo contra el escenario 2 de US1 y el Contrato 1 de `specs/002-portar-agentes/contracts/interfaces.md`: `name` igual al archivo, 7 tools Atlassian de lectura con prefijo `mcp__atlassian__` más Read/Grep/Glob/Skill/Write, `model: opus`, tabla de parámetros por proyecto en `Pendiente de configurar`, gate absoluto y declaración de renombre `<rol>-<proyecto>`
- [X] T005 [P] [US1] Recuperar `.claude/agents/atlassian-executor.md` del respaldo y verificarlo contra el escenario 3 de US1: declaración de clase ejecutora conforme a `.claude/rules/06-nomenclatura-agentica.md`, 9 tools con prefijo `mcp__atlassian__`, `model: sonnet`, protocolo ordenado de verificación (marca presente → bien formada → hash vigente → alcance total → catálogo por operación) y reporte con lectura real post-escritura
- [X] T006 [P] [US1] Recuperar la edición de `.claude/skills/confluence-docs/SKILL.md` del respaldo (§6, modo publicar) y verificar el escenario 5 de US1: documenta la equivalencia entre plan sellado con hash aprobado y aprobación explícita del gate, citando `.claude/contracts/write-plan.md` sin replicarlo
- [X] T007 [US1] Ejecutar las verificaciones de US1 y registrar E1 en `specs/002-portar-agentes/evidence.md`: quickstart §1 (barridos en cero sobre los archivos tocados), §2 (frontmatter de los dos agentes y contenido de `.claude/contracts/`) y §3 (ida y vuelta del hash con plan sintético en el scratchpad — los tres hashes: borrador, tras la marca, tras alterar)
- [X] T008 [US1] Commit de US1 con mensaje `feat: portar patrón plan-gate-ejecución (product-owner, atlassian-executor, write-plan)`, staging acotado a los 4 archivos de la historia más `evidence.md`

**Checkpoint**: US1 entregable por sí sola. Detenerse y reportar al dueño.

## Phase 4: User Story 2 — Developer con su infraestructura (P2)

**Goal**: `developer`, skill `development-repositories` parametrizada, contract `publish-authorization` y los dos contratos de diseño adaptados.

**Independent Test**: quickstart §4 (verificación tipada de la autorización), §5 (scripts: sintaxis, barrido y corrida funcional) y §6 (punteros).

**Depende de US1**: el `developer` cita `write-plan.md` como autoridad de sus escrituras a Atlassian.

- [ ] T009 [US2] Recuperar los 19 archivos de `.claude/skills/development-repositories/` del respaldo (SKILL.md, layout.md, repositories.md, spec-index.md, provenance.md, divergences.md, templates/development-spec.md, 4 examples y 8 scripts) y verificar el escenario 2 de US2: `repositories.md` sin repositorios reales y `spec-index.md` como plantilla con celda recomputable
- [ ] T010 [P] [US2] Recuperar `.claude/contracts/publish-authorization.md` del respaldo y verificarlo contra el escenario 5 de US2: bloque de seis campos por par (repositorio, rama), hash de línea canónica `clave|repositorio|rama|fecha`, nueve verificaciones ordenadas con vocabulario tipado, lista negativa explícita y declaración de garantía de proceso
- [ ] T011 [P] [US2] Recuperar `specs/002-portar-agentes/contracts/developer-flow.md` y `specs/002-portar-agentes/contracts/operation-report.md` del respaldo y verificar que sus identificadores remiten a esta spec y no a la del workspace de origen (FR-010)
- [ ] T012 [US2] Recuperar `.claude/agents/developer.md` del respaldo y verificarlo contra los escenarios 4 y 6 de US2 y el Contrato 1: 6 tools Atlassian con prefijo `mcp__atlassian__` más Read/Grep/Glob/Bash/Write/Edit/Skill, `model: opus`, tabla de restricciones con su garantía declarada (Permisos vs Proceso) por cada "nunca", y punteros a `.claude/contracts/` y `specs/002-portar-agentes/contracts/`
- [ ] T013 [US2] Verificar sintaxis y consistencia de los scripts (quickstart §5, primera mitad): `bash -n` sobre los 8 archivos de `.claude/skills/development-repositories/scripts/`, barrido corporativo en cero sobre todo el árbol de la skill, y coincidencia de los nombres `REPOS_ROOT`/`REPOS_CATALOG` entre los scripts, `SKILL.md` y `layout.md`
- [ ] T014 [US2] Ejecutar la corrida funcional de los scripts (quickstart §5, segunda mitad): armar la raíz de fixtures en el scratchpad según `.claude/skills/development-repositories/examples/test-catalog.md` §3 y correr `run-across-repos.sh` en `status`, `fetch` y `pull`, contrastando cada fila y el código de salida con lo que el fixture declara esperado en su §4
- [ ] T015 [US2] Ejecutar la verificación tipada de `publish-authorization` (quickstart §4) con bloques sintéticos para los seis casos (A vigente, B ausente, C campo faltante, D hash alterado, E rama distinta, F prosa), comprobando que cada uno clasifica con el nombre que el contract le asigna
- [ ] T016 [US2] Verificar la resolución de punteros de US2 (quickstart §6, ambos barridos: rutas citadas en prosa y enlaces markdown relativos) sobre los tres agentes, los dos contracts y `SKILL.md`, revisando a ojo los falsos positivos que el barrido de enlaces declara
- [ ] T017 [US2] Registrar E2 y E3 en `specs/002-portar-agentes/evidence.md` con los resultados reales de T013-T016, y commitear US2 con mensaje `feat: portar developer con development-repositories y publish-authorization`

**Checkpoint**: US2 completa. Detenerse y reportar al dueño.

## Phase 5: User Story 3 — Retiro de genéricos y coherencia (P3)

**Goal**: la plantilla queda con los tres agentes de rol, y la regla 04 y el README declaran el origen de cada capacidad que citan.

**Independent Test**: quickstart §7.

**Naturaleza distinta**: estas tareas **escriben**, no recuperan. El respaldo no las contiene, y su criterio proviene de la clarificación del 07-09-2026 (los genéricos siguen vivos en la configuración personal; el retiro es deduplicación).

- [ ] T018 [US3] Eliminar de `.claude/agents/` los archivos `arquitecto.md`, `documentador.md`, `revisor-codigo.md` y `revisor-proyecto.md`, declarando en el reporte que los tres primeros permanecen disponibles desde `~/.claude-personal/agents/` y que `revisor-proyecto` no tiene equivalente y queda recuperable solo desde el historial de git (escenario 4 de US3)
- [ ] T019 [P] [US3] Reescribir la sección "Delegación a subagentes" de `.claude/rules/04-flujo-y-metodo.md` conforme a FR-012: delegar en los tres agentes de rol de la plantilla y citar los genéricos de revisión y exploración como capacidad de la configuración personal de quien opera, con esa procedencia declarada según `.claude/rules/09-punteros-y-replicas.md`; sin citar `revisor-proyecto`
- [ ] T020 [P] [US3] Actualizar `README.md` conforme a FR-013: sección de agentes con los tres de rol, el patrón plan→gate→ejecución y el directorio `.claude/contracts/`; tabla "Qué incluye", lista de verificación y pasos de instalación sin presentar los genéricos como artefactos de la plantilla
- [ ] T021 [US3] Verificar quickstart §7 y commitear US3 con mensaje `feat: retirar agentes genéricos y actualizar delegación`: `revisor-proyecto` en cero fuera de `specs/`, y cada ocurrencia de los otros tres acompañada de su procedencia declarada

**Checkpoint**: US3 completa. Detenerse y reportar al dueño.

## Phase 6: Polish y cierre

- [ ] T022 Ejecutar el quickstart completo (§1 a §8) sobre el estado final del repositorio y corregir las desviaciones que aparezcan, sin declarar como cubierto lo que quede fuera de alcance
- [ ] T023 Completar `specs/002-portar-agentes/evidence.md` con E4 (resultado de la corrida completa) y cerrar el estado de las cuatro evidencias
- [ ] T024 Actualizar la memoria de continuidad del proyecto (estado del feature 002) y commitear con mensaje `docs: evidencia de validación del feature 002`; reportar el cierre al dueño dejando push, PR y merge a su confirmación explícita (SC-007)

## Dependencies

- Phase 1 → Phase 2 → US1 → US2 → US3 → Polish
- **T002 bloquea T003 y T010**: ambos contracts necesitan el directorio.
- **Dentro de US1**: T003 precede a T004 y T005 (los agentes citan el contract). T004, T005 y T006 son paralelizables entre sí. T007 requiere T003-T006; T008 requiere T007.
- **Dentro de US2**: T009 precede a T012 y a T013-T014 (el agente cita la skill; los scripts viven en ella). T010 y T011 son paralelizables con T009. T012 requiere T009, T010 y T011. T013-T016 requieren sus artefactos; T017 requiere T013-T016.
- **US2 requiere US1**: el `developer` cita `write-plan.md`.
- **Dentro de US3**: T018 precede a T019 y T020 (la reescritura describe un estado que T018 produce). T019 y T020 son paralelizables. T021 requiere las tres.
- **US3 requiere US1 y US2**: el retiro solo es coherente cuando los tres agentes de rol ya existen.

## Parallel Execution Examples

- **US1**: T004 ∥ T005 ∥ T006, una vez cerrada T003.
- **US2**: T010 ∥ T011 ∥ T009 al abrir la fase; luego T013 ∥ T015 (tocan artefactos distintos) mientras T014 arma su fixture.
- **US3**: T019 ∥ T020, una vez ejecutada T018.

## Implementation Strategy

MVP = US1: el patrón de gobernanza completo y autónomo, entregable sin el resto.

Entrega incremental con un commit al cierre de cada historia, todos en la rama `002-portar-agentes`. Entre historias hay un gate del dueño: la ejecución reporta y espera.

Ningún push, PR ni merge ocurre sin su confirmación explícita (SC-007 y `.claude/rules/05-ramas-y-flujo-sdd.md`). La rama `backup/002-portar-agentes` permanece local como respaldo de la primera corrida y no se integra.
