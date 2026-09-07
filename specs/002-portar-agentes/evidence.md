# Evidencia de validación — feature 002

Registro fechado de las verificaciones ejecutadas **en este repositorio y en esta corrida**. Cada bloque cita el comando y su resultado real.

Dos reglas gobiernan este archivo:

- Nada se asume de corridas del workspace de origen (decisión D7 de [research.md](research.md)).
- Nada se cita de la corrida respaldada en `backup/002-portar-agentes`: los artefactos se recuperan de allí, pero su evidencia se produce ejecutando las verificaciones aquí (decisión D8). Un artefacto recuperado que falle su verificación se corrige o se re-deriva, y el hecho se declara.

## Estado

| Evidencia | Qué cubre | Fase | Estado |
| --- | --- | --- | --- |
| E1 | Ida y vuelta del hash de `write-plan` (quickstart §3) | US1 | Registrada |
| E2 | Verificación tipada de `publish-authorization` (quickstart §4) | US2 | Registrada |
| E3 | Scripts de `development-repositories`: sintaxis, barrido y corrida funcional (quickstart §5) | US2 | Registrada |
| E4 | Corrida completa del quickstart §1-§8 | Polish | Registrada |

Cada evidencia se registra al cerrar su fase, con la fecha y el comando que la produjo.

## E1. Ida y vuelta del hash de write-plan (US1, quickstart §3)

**Fecha**: 07-09-2026. **Material**: plan sintético con una operación (`board-gestion`/`createJiraIssue`, issue de ejemplo "Validar RUT en registro"), estructura conforme a `.claude/contracts/write-plan.md`, construido en el scratchpad de la sesión.

| Paso | Hash SHA-256 de la sección de operaciones |
| --- | --- |
| Borrador (antes de insertar la marca) | `4220f4d1ed91036f3e04897041c5bec5e879ce54e2e50969042fe33876ed1ebe` |
| Tras insertar la marca de aprobación | `4220f4d1ed91036f3e04897041c5bec5e879ce54e2e50969042fe33876ed1ebe` (idéntico) |
| Tras alterar el título de la operación | `d2bb962e803f2caeb2009e04933821f022c4d81338e7a072791a2ff326eb0037` (difiere) |

Comando: `sed -n '/^## Operaciones$/,/^<!-- end-operations -->$/p' <plan> | shasum -a 256`.

Complementario a la barrera del hash: quickstart §1 (dos barridos corporativos, `.claude/` y `README.md`) devolvió exit 1 en ambos; §2 confirmó `.claude/contracts/` con exactamente `write-plan.md` y los frontmatter de `product-owner`/`atlassian-executor` conformes al Contrato 1.

**Veredicto**: ida y vuelta OK — los dos comportamientos que el contract promete se observaron en esta corrida, no se citan de la anterior (D7/D8 de research.md).

**Nota de mantenimiento**: `write-plan.md` línea 53 cita la evidencia de la prueba anterior (06-09-2026). Al commitear US1 se actualiza esa cita a esta fecha y a estos hashes, para que el contract remita a la corrida que realmente lo verificó.

## E2. Verificación tipada de publish-authorization (US2 escenario 5, quickstart §4)

**Fecha**: 07-09-2026. **Material**: verificador sintético (`/private/tmp/.../scratchpad/verify-publish-auth.sh`) que aplica las verificaciones 1-6 del contract `.claude/contracts/publish-authorization.md` sobre bloques generados con `shasum -a 256` de la línea canónica `clave|repositorio|rama|fecha`. Las verificaciones 7-9 exigen estado git de una corrida real del agente y quedan fuera del alcance sintético — se declara, no se finge cobertura.

| Caso | Bloque | Clasificación esperada | Observada |
| --- | --- | --- | --- |
| A | Completo y consistente con la pieza operada | vigente (1-6 en verde) | vigente |
| B | Invocación sin bloque | `ausente` | `ausente` |
| C | Sin campo `fecha` | `malformada` (verificación 2) | `malformada` |
| D | Hash alterado en un carácter | `malformada` (verificación 3) | `malformada` |
| E | Hash internamente consistente, `rama` distinta de la operada | `no coincide` (verificación 5) | `no coincide` |
| F | "haz push de la rama" en prosa | `ausente` (sin forma ni hash) | `ausente` |

Veredicto: **6/6 casos clasifican con su nombre tipado**, en el orden del contract (la primera falla detiene y clasifica). Coincide con el vocabulario corregido en `data-model.md` (hash alterado = `malformada`, no `no coincide`).

## E3. Scripts de development-repositories (SC-004, quickstart §5)

**Fecha**: 07-09-2026.

- **Sintaxis**: `bash -n` sobre los 8 scripts de `.claude/skills/development-repositories/scripts/` — 8/8 OK.
- **Barrido corporativo**: `grep -rliE 'df-ciam|ciam|cencosud|cencoflow|e98853f7'` sobre los 19 archivos de la skill — cero coincidencias.
- **Consistencia de identificadores**: `REPOS_ROOT`/`REPOS_CATALOG` con el mismo nombre en los scripts, `SKILL.md` y `layout.md`.
- **Corrida funcional contra catálogo sintético**: raíz de fixtures armada con la receta de `examples/test-catalog.md` §3, en el scratchpad de la sesión (fuera del árbol del workspace). `run-across-repos.sh` ejecutado con `--catalog` y `--root`:
  - `status`: las 5 filas clasifican exactamente como la tabla de §4 del fixture — limpio/`al día`, atrasado figura `al día` antes del fetch (correcto por diseño), sucio/`con cambios sin guardar`, vacío/`sin commits` con rama resuelta por `symbolic-ref`, ausente/`error: no está clonado` — y la corrida sale con **código 2**.
  - `fetch`: revela `atrasado` en `Respecto del remoto`; 4/5 operados.
  - `pull`: `actualizado` solo el atrasado (verificado: quedó en `commit posterior`), `saltado (cambios sin guardar)` el sucio con su contenido local intacto, `saltado (sin upstream)` el vacío, error el ausente; 2/5 operados.

Veredicto: **scripts operativos de punta a punta sobre el fixture**, resultados idénticos a los que el propio fixture declara esperados. Límites que el fixture declara fuera de su alcance (red, colisión de ruta destino en `prepare-workspace.sh`) siguen sin cubrir, y se declaran, no se disimulan.

## Punteros de US2 (quickstart §6)

**Fecha**: 07-09-2026. Dos barridos ejecutados sobre `developer.md`, ambos contracts vivos y `SKILL.md`: rutas citadas en prosa (enumeradas y verificadas con `test -e`) y enlaces markdown relativos (resueltos respecto del directorio de cada archivo, script en Python). Ambos en cero rotos.

## US3. Retiro de genéricos y coherencia (SC-006, quickstart §7)

**Fecha**: 07-09-2026. `.claude/agents/` contiene exactamente `product-owner.md`, `atlassian-executor.md`, `developer.md` (verificado con `ls`). Dos verificaciones distintas, según el vocabulario que la clarificación del 07-09-2026 fijó:

- `grep -rn 'revisor-proyecto' .claude/ README.md` → cero fuera de `specs/` (el nombre no tiene equivalente en la configuración personal del usuario y se retira sin dejar rastro fuera de la traza de esta feature).
- `grep -n 'arquitecto\|documentador\|revisor-codigo' .claude/rules/04-flujo-y-metodo.md README.md` → ambas ocurrencias declaran explícitamente que esos tres agentes provienen de la configuración personal de quien opera (`~/.claude-personal/agents/`, hallazgo verificado en la fase clarify) y no son artefactos de la plantilla.

Punteros markdown de `README.md` y `04-flujo-y-metodo.md`: todos resuelven.

Veredicto: SC-006 cumplido con el vocabulario corregido — la spec original (antes de la clarificación) pedía "grep cero" para los cuatro nombres; eso habría sido incorrecto para los tres que sí siguen disponibles.

## E4. Corrida completa del quickstart §1-§8 (Polish)

**Fecha**: 07-09-2026, sobre el estado final consolidado del repositorio (commit `4974d54` y siguientes de esta fase).

| Sección | Resultado |
| --- | --- |
| §1 Barrido corporativo | Dos `grep` sobre `.claude/` y `README.md` — exit 1 en ambos |
| §2 Estado de agentes y contracts | `.claude/agents/` = exactamente `product-owner.md`, `atlassian-executor.md`, `developer.md`; `.claude/contracts/` = exactamente `write-plan.md`, `publish-authorization.md`; los 3 frontmatter conformes al Contrato 1 |
| §3 Hash de write-plan | Sin cambios desde E1; la cita en `write-plan.md` línea 53 sigue apuntando a esta corrida (07-09-2026) |
| §4 Verificación tipada de publish-authorization | Sin cambios desde E2; verificador sintético sigue disponible y sus 6 casos siguen vigentes |
| §5 Scripts | `bash -n` 8/8 OK sobre el estado final; barrido corporativo limpio |
| §6 Punteros | Barrido ampliado a `README.md` y `04-flujo-y-metodo.md` además de agentes y contracts — todas las rutas resuelven |
| §7 Retiro de genéricos | `revisor-proyecto` cero fuera de `specs/`; 4 ocurrencias de los otros 3 (2 en cada archivo), todas con "configuración personal" en la misma frase |
| §8 Trazabilidad | 8 commits en `002-portar-agentes` desde el reinicio; `main` intacto en `d55dff8` (merge del feature 001) |

**Veredicto**: quickstart completo sin desviaciones. No se declaran hallazgos nuevos — el diseño (research.md D8) y las correcciones aplicadas durante clarify y plan sostuvieron su verificación hasta el cierre.

**Límites que siguen declarados y no se disimulan** (research.md, quickstart.md): la corrida funcional de los scripts no ejercita red ni la colisión de ruta destino de `prepare-workspace.sh`; las verificaciones 7-9 de `publish-authorization` (estado git de una corrida real) no se cubrieron con sintéticos; los acoplamientos no parametrizables de los scripts, si los hay, quedan documentados en la propia skill y no en esta evidencia.
