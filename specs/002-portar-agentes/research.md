# Research: Portar agentes del workspace CIAM

**Fecha**: 2026-09-07 (decisiones D1-D7 del 06-09-2026; D8 y las correcciones de D2 y D6 del 07-09-2026)
**Fuentes**: workflow de clasificación `classify-ciam-agents` (5 lectores en paralelo, salida estructurada, 427k tokens, 06-09-2026 — cada lector leyó completo su artefacto de origen y verificó equivalencias contra la base); scouting de dimensionamiento de `development-repositories-ciam` (find + wc, misma fecha); dos rondas de decisiones interactivas con el dueño (alcance el 06-09-2026; método y criterios de aceptación el 07-09-2026, registradas en la sección Clarifications de la spec); inspección directa de `~/.claude-personal/agents/` y del CLAUDE.md global (07-09-2026).

Ninguna incógnita queda abierta; no hay marcadores NEEDS CLARIFICATION en la spec.

## Decisiones

### D1. Alcance completo: trío + developer + infraestructura

- **Decision**: portar los tres agentes, ambos contracts y la skill `development-repositories` completa.
- **Rationale**: decisión explícita del dueño en ronda interactiva, tomada contra la recomendación (que proponía solo el trío) y con el esfuerzo señalado. El dimensionamiento posterior precisó el tamaño real (~5.900 líneas, 8 scripts por ~4.800 líneas); no se reabrió la decisión y la spec la absorbe por fases con entrega incremental.
- **Alternatives considered**: solo trío (recomendada; descartada por el dueño); trío + publish-authorization latente (descartada: contract sin consumidor es un puntero colgante).

### D2. Retiro de los cuatro agentes genéricos

- **Decision**: retirar `arquitecto`, `documentador`, `revisor-codigo`, `revisor-proyecto`; reescribir la sección de delegación de la regla 04.
- **Rationale**: decisión explícita del dueño contra la recomendación (mantener 3 y retirar solo el de ejemplo), con la consecuencia asumida. Replica la evolución del propio workspace CIAM, que retiró sus genéricos al incorporar agentes de rol.
- **Alternatives considered**: mantener 3 + retirar `revisor-proyecto` (recomendada); mantener los 4.
- **Hallazgo verificado (07-09-2026)**: `arquitecto.md`, `documentador.md` y `revisor-codigo.md` **ya existen** en `~/.claude-personal/agents/` (comprobado con `ls`), y el CLAUDE.md global del usuario los nombra como subagentes disponibles (línea 39), igual que su regla 04 global (línea 47). Los del repositorio eran duplicados: retirarlos es **deduplicación**, no pérdida de capacidad — siguen operativos en cualquier proyecto vía la configuración personal. `revisor-proyecto` es la excepción: solo existe en el repositorio, y su retiro sí lo elimina de la configuración activa.
- **Consecuencia declarada, corregida por el hallazgo**: la divergencia entre la regla 04 del proyecto y la global es de **origen declarado**, no de contenido ni de capacidad. La regla del proyecto cita esos agentes como capacidad de la configuración personal de quien opera —un puntero con procedencia, conforme a la regla 09— en vez de omitirlos o de presentarlos como artefactos de la plantilla. La formulación anterior de esta decisión ("la regla 04 no nombra agentes retirados") quedó superada por la clarificación del 07-09-2026 y no se conserva.

### D3. Nombres sin sufijo (precedente D2 del feature 001)

- **Decision**: `product-owner`, `atlassian-executor`, `developer`; skill `development-repositories`; contracts conservan su nombre de origen (ya en inglés).
- **Rationale**: los artefactos entran al estándar transversal de la plantilla; cada agente de rol declara en su cuerpo el renombre `<rol>-<proyecto>` al adoptarse en un proyecto (regla 06).

### D4. `.claude/contracts/` como directorio nuevo de autoridad runtime

- **Decision**: crear `.claude/contracts/` con `write-plan.md` y `publish-authorization.md`; los contratos de diseño (`developer-flow`, `operation-report`) viven en `specs/002-portar-agentes/contracts/`.
- **Rationale**: patrón del origen: el contract vivo es autoridad en runtime y se cita desde los agentes; el diseño vive en la spec y toda divergencia se anota allí (regla 09).
- **Alternatives considered**: inlinear los contracts en los agentes (descartado: tres agentes replicarían el mismo protocolo y divergirían en silencio).

### D5. Entidades del plan consolidadas en el contract

- **Decision**: las entidades (PlanDeEscritura, Operacion, MarcaDeAprobacion, ReporteDeEjecucion) se definen en `write-plan.md` como autoridad única; `data-model.md` de esta spec las describe y remite.
- **Rationale**: en el origen eran copia declarada desde la spec 025; portarlas como copia perpetuaría una réplica. Consolidar la autoridad en el contract cierra la deuda.

### D6. Scripts: parametrizar vía catálogo, no reescribir

- **Decision**: los 8 scripts se portan con edición mínima — toda configuración específica (nombres de repos, rutas del workspace) se lee del catálogo `repositories.md`, que en la plantilla queda vacío con procedimiento de poblado; acoplamientos no parametrizables se declaran como límite en la skill.
- **Rationale**: FR-008; reescribir ~4.800 líneas de bash probadas introduciría más riesgo del que elimina.
- **Verificación exigida (clarificación 07-09-2026)**: `bash -n` por script, barrido corporativo en cero, **y corrida funcional** de `status`, `fetch` y `pull` contra el fixture sintético que la propia skill trae (`examples/test-catalog.md`), comparando cada fila reportada con el estado que el fixture declara esperado. La sintaxis no prueba que el parseo del catálogo ni la lógica de estados sobrevivan a la parametrización; la corrida sí. El fixture se arma en el scratchpad de la sesión (nunca dentro del árbol del workspace, guarda que los propios scripts imponen) y es de un solo uso por verbo mutante.

### D7. Evidencias re-ejecutadas, nunca citadas del origen

- **Decision**: la prueba de ida y vuelta del hash (write-plan) y la verificación del bloque de autorización (publish-authorization) se re-ejecutan en la base con material sintético y se citan como evidencia de esta feature.
- **Rationale**: FR-004; citar la evidencia del workspace de origen sería un puntero a un identificador inexistente en este repo (regla 09).

### D8. Recuperación desde el respaldo con re-verificación por fase

- **Decision**: cada fase de implementación recupera sus artefactos de la rama `backup/002-portar-agentes` (punta `7f743f7`) con `git show`/`git checkout`, y los re-verifica contra los criterios de aceptación de su propia historia antes de commitear. No se re-portan desde el workspace de origen.
- **Rationale**: decisión del dueño en la ronda de clarificación (07-09-2026). Esa rama conserva la portación completa de la primera corrida del feature, que se ejecutó sin gates y por eso se reinició; el trabajo mecánico ya depurado (~5.900 líneas, con correcciones de identificadores y neutralizaciones aplicadas) no gana nada con re-derivarse, y re-derivarlo arriesga reintroducir defectos ya corregidos. Lo que el reinicio buscaba recuperar era la **validación del dueño por fase**, y eso se preserva íntegro: él revisa el resultado de cada historia antes de la siguiente.
- **Alternatives considered**: re-portar todo desde el origen (máxima independencia; descartada por costo alto sin ganancia de calidad, ya que la validación humana opera sobre el resultado y no sobre el proceso); híbrido por tipo de artefacto (descartada por introducir dos regímenes de verificación sin un criterio que los distinga).
- **Límite declarado**: la evidencia de esta corrida se produce **ejecutando** las verificaciones, nunca citando las del respaldo (coherente con D7). Un artefacto recuperado que no pase su verificación se corrige o se re-deriva, y el hecho se declara en la evidencia.

## Mapa de transformaciones por artefacto

Origen: `$CIAM = /Users/rodrigo-hinojosa/Documents/Cencosud/Develop/CIAM/df-ciam-workspace` (solo lectura). Las transformaciones provienen del workflow de clasificación; se listan las de efecto normativo (el detalle literal por línea quedó en la salida estructurada del workflow).

### `product-owner.md` (← `agents/product-owner-ciam.md`, 63 líneas, PARAMETRIZABLE)

1. Renombrar archivo y `name:`; description sin proyecto/boards/espacio corporativos; remisiones `jira-ciam-management`→`jira-management`, `confluence-ciam`→`confluence-docs`; mención del ejecutor → `atlassian-executor` (existirá en la misma fase).
2. Tools: prefijo `mcp__atlassian-cencosud__` → `mcp__atlassian__` (7 tools, equivalencia 1:1 verificada); `mcpServers: [atlassian]`.
3. Agregar tabla "Parámetros por proyecto" (tablero de gestión, tablero QA opcional, espacio Confluence, página de roster — `Pendiente de configurar`; cloudId en runtime).
4. Roster: URL corporativa → parámetro; conservar el mecanismo (verificar en vivo antes de asumir lo registrado).
5. Eliminar el párrafo "Supersesión declarada" (historia interna del origen) y las menciones a `jira-ciam-qa`/`team-ciam`/`cencoflow-ciam` → nota parametrizada de skills de dominio adicionales del proyecto.
6. Re-anclar la copia declarada de principios del output-style a la fecha de portación (el archivo existe en la base en la misma ruta).
7. Conservar: `model: opus`, `color`, mecanismos completos (gate absoluto, plan como artefacto contractual, ceros calificados, formato de hallazgo, frontera de rol, conector caído, nomenclatura `write-plan-YYYYMMDD-HHMMSS.md`).
8. Declarar en el cuerpo el renombre `<rol>-<proyecto>` al adoptarse en un proyecto con roster.

### `atlassian-executor.md` (← `agents/atlassian-executor-ciam.md`, 57 líneas, PARAMETRIZABLE)

1. Renombrar archivo y `name:`; description remite al catálogo del contract en vez de boards concretos; `confluence-ciam`→`confluence-docs`; `product-owner-ciam` → referencia genérica al agente de rol productor.
2. Tools: prefijo → `mcp__atlassian__` (9 tools 1:1); `mcpServers: [atlassian]`.
3. Roster: URL corporativa → cita genérica + referencia explícita a la regla 06 de la base ("Clase declarada — agente ejecutor nombrado por función", ya existente).
4. "nunca product-owner-ciam directamente" → "nunca otro subagente directamente" (el argumento estructural se conserva).
5. Conservar: `model: sonnet`, protocolo ordenado de verificación (1-4 rehúsan el plan completo; 5 por operación), separación decidir/ejecutar, frontera de resolución, delegación a `confluence-docs` modo publicar, reporte con lectura real, segunda barrera de PII, least privilege.

### `.claude/contracts/write-plan.md` (← `contracts/write-plan.md`, 65 líneas, PARAMETRIZABLE)

1. Nombres de agentes → `product-owner` / `developer` (productores) y `atlassian-executor` (ejecutor); "regla 10" → regla 09 de la base.
2. Rutas de procedencia (`specs/025-*`, `specs/030-*`) → esta spec (`specs/002-portar-agentes/`); conservar la obligación de anotar divergencias diseño↔contrato.
3. Entidades del plan inlined como autoridad única (D5), sin fecha de copia del origen.
4. Catálogo: filas corporativas → filas plantilla (`board-<id>` `Pendiente de configurar`, tipo por id como parámetro de `jira-management`, label de gestión configurada, assignee del catálogo del proyecto); conservar como patrón la fila de épica ancla ("nunca destino de escritura, sin editar ni borrar") con placeholders.
5. Fuentes citadas → `jira-management` (modos CREAR/MOVER) y `confluence-docs` (modo publicar); "espacio CIAM" → espacio configurado.
6. Equivalencia de aprobación: conservar el mecanismo Y hacer la edición acompañante en `confluence-docs` (verificado que hoy no la documenta) — mismo commit/fase (FR-005).
7. Evidencia del hash: re-ejecutar la prueba de ida y vuelta en la base (D7) y citarla.

### `developer.md` (← `agents/developer-ciam.md`, 143 líneas, ESPECÍFICO → portable con D1)

1. Renombrar; description sin claves `CIAM-XXX` (patrón `<CLAVE>-XXX` de la regla 05, con semántica declarada para proyectos sin Jira); tools → prefijo `mcp__atlassian__` (6 tools); `mcpServers: [atlassian]`.
2. Punteros de skills: `development-repositories-ciam`→`development-repositories`, `jira-ciam-management`→`jira-management`, `confluence-ciam`→`confluence-docs`; `jira-ciam-qa`/`team-ciam`/`cencoflow-ciam` → vacíos declarados parametrizados.
3. Punteros de contratos: `specs/030-*/contracts/developer-flow.md` y `operation-report.md` → `specs/002-portar-agentes/contracts/`; `.claude/contracts/write-plan.md` y `publish-authorization.md` se conservan (existirán); FR/SC de la spec 030 → identificadores de esta spec o eliminación; "regla 10" → 09.
4. Ramas: `feat/CIAM-XXX-slug` → patrón de la regla 05 (`tipo/<CLAVE>-XXX-descripcion` en repos de producto); boards 14516/14530 y fechas de migración del origen se eliminan.
5. `spec-index.md` → plantilla vacía con celda recomputable, dentro de la skill.
6. Conservar: `model: opus`, tabla de restricciones Permisos vs Proceso, regla dura de relectura git, vocabularios cerrados de reporte, piezas independientes por componente, escalera de rama base, commit de una sola ruta, envoltorio `repo_git` con su justificación fechada re-anclada, copias declaradas del output-style re-ancladas.

### `.claude/contracts/publish-authorization.md` (← `contracts/publish-authorization.md`, 71 líneas, PARAMETRIZABLE)

1. `developer-ciam` → `developer` (4 menciones); rutas de la spec 030 → esta spec; "regla 10" → 09; SC-003 de la 030 → criterio equivalente de esta spec.
2. Ejemplos: `CIAM-XXX` → `<CLAVE>-XXX`; `df-ciam-backend` → `<repositorio>`; `feat/CIAM-XXX-descripcion` → patrones de la regla 05.
3. `development-repositories-ciam` (envoltorio `repo_git`) → `development-repositories` (se porta en la misma fase, opción A del clasificador; no se pierde la neutralización de hooks).
4. Conservar: bloque delimitado con hash de línea canónica, campos dentro/fuera del hash, nueve verificaciones ordenadas con vocabulario tipado, anti-reutilización con residuo declarado, push sin force con relectura vía `ls-remote`, lista negativa, declaración de garantía de proceso.

### `development-repositories/` (← skill completa, ~5.900 líneas)

1. Renombrar directorio y `name:`; description sin `-ciam`.
2. `repositories.md` (catálogo): vaciar de repos reales `df-*` → estructura plantilla con columnas y procedimiento de poblado (`Pendiente de configurar`).
3. `spec-index.md`: plantilla vacía, celda de recuento recomputable, procedimiento de registro.
4. Scripts (8): barrido y sustitución de rutas/nombres del origen; configuración desde el catálogo (D6); `bash -n` + ejecución sintética donde aplique.
5. `layout.md`, `provenance.md`, `divergences.md`, `templates/development-spec.md`, `examples/` (4): depurar referencias corporativas; procedencia re-anclada como réplica declarada de esta portación; ejemplos neutralizados o marcados como sintéticos.
6. Pendiente de detalle en implement: estos archivos no fueron leídos por el workflow de clasificación (solo dimensionados); la tarea de portación incluye su lectura completa y la aplicación del mismo criterio de barrido — se declara para no fingir un mapa línea a línea que no existe.

### Regla 04 y README (US3)

1. Regla 04 §Delegación: delegar en los agentes de rol de la base (versionados en la plantilla) y citar `arquitecto`/`revisor-codigo` como capacidad de la **configuración personal de quien opera**, con esa procedencia declarada conforme a la regla 09; no citar `revisor-proyecto`, que no queda en ningún ámbito. La divergencia con el set global es de origen, no de contenido (D2, hallazgo del 07-09-2026).
2. README: sección de agentes (3 de rol + patrón plan→gate→ejecución + `.claude/contracts/`); lista de verificación e instalación sin presentar los genéricos como artefactos de la plantilla.

## Riesgos y límites declarados

- **Scripts no leídos línea a línea en investigación**: el mapa de la skill es de nivel archivo (D6, punto 6); la lectura completa ocurre en implement. Riesgo: acoplamientos no anticipados → se declaran como límites, no se disimulan.
- **Divergencia regla 04 global/proyecto**: permanente por diseño y declarada en la regla. Tras el hallazgo del 07-09-2026 se reduce a una diferencia de **origen** (la plantilla deja de versionar copias de agentes que la configuración personal ya provee), no de capacidad disponible. Riesgo residual: quien clone esta plantilla sin esa configuración personal no tendrá los genéricos citados — por eso la regla los cita declarando su procedencia, en vez de darlos por presentes.
- **`revisor-proyecto` sin equivalente**: su retiro lo elimina de la configuración activa; recuperable solo desde el historial de git. Se declara al ejecutar la fase.
- **Agentes de rol sin roster en plantilla**: mitigado con la declaración de renombre y reconciliación por proyecto (regla 06).
