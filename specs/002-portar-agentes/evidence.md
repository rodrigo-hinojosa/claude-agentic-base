# Evidencia de validación — feature 002

Registro fechado de las verificaciones ejecutadas **en este repositorio y en esta corrida**. Cada bloque cita el comando y su resultado real.

Dos reglas gobiernan este archivo:

- Nada se asume de corridas del workspace de origen (decisión D7 de [research.md](research.md)).
- Nada se cita de la corrida respaldada en `backup/002-portar-agentes`: los artefactos se recuperan de allí, pero su evidencia se produce ejecutando las verificaciones aquí (decisión D8). Un artefacto recuperado que falle su verificación se corrige o se re-deriva, y el hecho se declara.

## Estado

| Evidencia | Qué cubre | Fase | Estado |
| --- | --- | --- | --- |
| E1 | Ida y vuelta del hash de `write-plan` (quickstart §3) | US1 | Registrada |
| E2 | Verificación tipada de `publish-authorization` (quickstart §4) | US2 | Pendiente |
| E3 | Scripts de `development-repositories`: sintaxis, barrido y corrida funcional (quickstart §5) | US2 | Pendiente |
| E4 | Corrida completa del quickstart §1-§8 | Polish | Pendiente |

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
