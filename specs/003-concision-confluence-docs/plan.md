# Implementation Plan: Concisión en confluence-docs

**Branch**: `003-concision-confluence-docs` | **Date**: 2026-09-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-concision-confluence-docs/spec.md`

## Summary

Refinar la skill `confluence-docs` para que genere documentación sin relleno y para que el modo auditar pueda fallar un documento relleno. Son ediciones locales sobre los tres archivos de la skill y sus cinco ejemplos, en cinco historias:

1. Vacíos con línea marcada en vez de prosa.
2. Detector de relleno: regla 33 (Comando, lista cerrada) y regla 10 ampliada (Juicio); autochequeo en generar y hallazgos bloqueantes en auditar.
3. Regla 26 sin piso y fixtures de prosa re-clavados.
4. Estructura documental proporcionada: disparador de la regla 25 por naturaleza, una sola apertura, viñetas acotadas.
5. Ejemplos que enseñan solo concisión.

El mapa de cambios por archivo y línea está en [research.md](research.md) §4. Las interfaces que la implementación respeta están en [contracts/](contracts/). Cubren el comando de prosa ampliado, la línea marcada, la cabecera de fixture como clave de respuestas, el bloque de apertura bajo la regla 25 y la evidencia. Las pruebas con el modelo (generar y auditar) se corren una vez por caso y se persisten en `evidence/` (FR-017).

## Technical Context

**Language/Version**: Markdown; Python 3 (stdlib `re`) embebido en el comando de prosa de `rules.md`, ejecutado con el `python3` del sistema

**Primary Dependencies**: ninguna externa. Vara de solo lectura: `.claude/rules/00-lenguaje-y-formato.md`, `01-prevencion-alucinaciones.md`, `02-documentacion-y-entregables.md`. Autoridad de estructura: `templates.md`; de reglas: `rules.md`

**Storage**: archivos versionados; sin base de datos

**Testing**: comando de prosa ampliado sobre fixtures y archivos de la skill. Greps con resultado esperado. Auditorías y generaciones con el modelo, una corrida por caso, persistidas en `evidence/`. Comparación de encabezados de ejemplos contra `templates.md`. Verificador de enlaces relativos, heredado del feature 002 con su falso positivo declarado

**Target Platform**: Claude Code CLI en macOS; plantilla clonable a otros proyectos

**Project Type**: plantilla de configuración agéntica (skill de documentación)

**Performance Goals**: N/A (archivos estáticos y un script de medición puntual)

**Constraints**: cambios mínimos y locales (FR-016). Cero referencias corporativas. No renumerar el catálogo: la 33 va al final. No tocar las reglas 00-02 ni los modos publicar y consultar. Cada fixture pasa su comando antes del commit. Lo listado en "Lo que se conserva" no se reescribe. Las nueve decisiones del dueño (13-09 y 14-09-2026) no se reabren

**Scale/Scope**: 3 archivos de skill (`SKILL.md` 181 líneas, `rules.md` 165, `templates.md` 124) y 5 ejemplos (239 líneas en total). Un directorio nuevo `evidence/` con unos 10 archivos. 34 puntos de cambio identificados por línea (research.md §4)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.* Evaluado contra la constitución v1.0.0 (ratificada 2026-09-06).

| Principio | Evaluación | Resultado |
| --- | --- | --- |
| I. Verificación antes de afirmación | El diagnóstico cita archivo y línea de cada causa; las cifras se recomputaron el 15-09-2026 con el comando vigente y se citan con la salida literal (research.md §2). La feature misma es la aplicación del principio al generador: un vacío queda con su nombre, nunca con genérico. Las pruebas con el modelo se declaran como una corrida persistida, no como prueba de determinismo | PASS |
| II. Referenciar, no duplicar | La línea marcada se define una sola vez en `templates.md` y `rules.md` y `SKILL.md` la citan (D13). La lista cerrada de muletillas vive en un solo lugar, el bloque de código del comando (D6). Las cabeceras de fixture citan la salida del comando con fecha. La divergencia de `rules.md` y `templates.md` respecto del estándar de origen se declara en su nota de procedencia (D16, regla 09) | PASS |
| III. Trazabilidad SDD | Rama `003-concision-confluence-docs`, flujo `specify` → `clarify` (5 preguntas, 14-09-2026) → `plan` → `tasks` → `implement`, con validación del dueño entre fases; sin commits a `main` | PASS |
| IV. Escritura con gate | Ninguna tarea escribe a Confluence ni a Jira; auditar es de solo lectura y sigue siéndolo; los modos publicar y consultar no se tocan. Las generaciones de prueba se materializan en `evidence/` a pedido explícito de esta feature, conforme a la regla de operación de la skill | PASS |
| V. Plantilla agnóstica y parametrizada | Ningún archivo tocado incorpora identificadores de tenant; los insumos sintéticos de `evidence/` usan nombres inventados; la skill conserva su nombre sin sufijo; el barrido corporativo es criterio de cierre (SC-008) | PASS |

**Post-diseño (re-check, 15-09-2026)**: el diseño de Fase 1 no introduce violaciones. Tres decisiones tomadas en el plan se evaluaron contra los principios:

- **D10**, el comando excluye comentarios HTML: cambio de una línea sobre un mecanismo conservado, declarado con su motivo en `rules.md`. Sin él, "cero hallazgos" no sería verificable por comando y el Principio I quedaría en juicio.
- **D12**, bajo la regla 25 el callout materializa la sección 1 y la numeración arranca en Descripción: se registra en `templates.md` §7 Correcciones para no reescribir historia.
- **D15**, la clave de `seeded-violations.md` se clava con una corrida de auditoría persistida: es evidencia con fecha, no promesa de reproducibilidad.

## Project Structure

### Documentation (this feature)

```text
specs/003-concision-confluence-docs/
├── spec.md                  # Especificación (hecha; clarify integrado el 14-09-2026)
├── plan.md                  # Este archivo
├── research.md              # Fase 0: diagnóstico consolidado, cifras, decisiones D1-D17, mapa de cambios
├── data-model.md            # Fase 1: entidades (regla, plantilla, línea marcada, comando, fixture, hallazgo, veredicto, evidencia)
├── quickstart.md            # Fase 1: guía de validación end-to-end con resultados esperados
├── contracts/
│   ├── prose-command.md     # Fase 1: interfaz del comando de prosa ampliado (entrada, exclusiones, métricas, lista cerrada, salida)
│   └── interfaces.md        # Fase 1: línea marcada, cabecera de fixture, hallazgo/veredicto, bloque de apertura R25, encabezados de ejemplos, evidencia
├── checklists/requirements.md   # Hecho (16/16)
├── evidence/                # Implement (FR-017): insumos sintéticos, salidas generadas, reportes de auditoría, evidence.md
└── tasks.md                 # Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
.claude/skills/confluence-docs/
├── SKILL.md            # US1: L80 (sin "supuesto explícito"); US2: §3.6 autochequeo 26-33 + comando, §4.2-3 relleno y marca Juicio de la 33,
│                       #      enlaces a los fixtures de prosa en §3 y §4; US4: §3.2 disparador de la 25, callout única apertura,
│                       #      nota de mantención definida u omitida, L70 exclusiones; L82 regla 26 sin piso y rango 26-33
├── rules.md            # US1: reglas 5 y 11; US2: regla 33 (fila + criterio Juicio), regla 10 ampliada, comando ampliado, L59 y L66
│                       #      reformulados, encabezado "Reglas de prosa (26-33)"; US3: regla 26 y métrica n1; US4: reglas 7 y 25,
│                       #      "cuándo" L116 y L163; L3 procedencia con la revisión 003
├── templates.md        # US1: sección nueva sin número "Secciones obligatorias y vacíos", §2/§3 "obligatoria = presente, no llena",
│                       #      §2 fila 4 supuestos de la fuente vs del redactor; US2: §8 fila auditar; US4: §2 nota de la sección 1
│                       #      bajo la regla 25; §7 Correcciones con las definiciones superadas
└── examples/
    ├── compliant-adr.md            # US5: sin "Próximos pasos", Referencias sin la propia plantilla, dueño sintético, L11 sin anticipo
    ├── structured-doc.md           # US5: reescritura bajo el contrato 5 (bloque de apertura) y 6 (encabezados §2), R27 = 0, hecho SSOT ≤ 2
    ├── prose-conforming.md         # US3: cabecera re-clavada con cifras y fecha; US5: sin autodescripción en el cuerpo
    ├── prose-with-seeded-flaws.md  # US3: desvío R26 = párrafo de 5+ oraciones, cabecera re-clavada; US5: sin autodescripción
    └── seeded-violations.md        # US5: lista enumerada de violaciones sembradas con su regla (33, 10, 32 incluidas)
```

**Structure Decision**: no se crea ningún archivo nuevo dentro de la skill. El único directorio nuevo es `specs/003-concision-confluence-docs/evidence/`, exigido por FR-017 y fuera del árbol de `.claude/`. Todo cambio en la skill es edición en sitio de archivos existentes, con `structured-doc.md` como la única reescritura amplia, acotada por contrato.

## Complexity Tracking

Sin violaciones de constitución. Tres riesgos de complejidad asumidos y declarados:

| Riesgo | Tratamiento |
| --- | --- |
| `structured-doc.md` cambia de estructura (bloque de apertura nuevo, secciones alineadas a §2, repetición eliminada) y es la edición más amplia de la feature | Se reescribe bajo los contratos 5 y 6 de `interfaces.md`, conservando lo que la lista "keep" del diagnóstico marcó (citas inline, tabla de trazabilidad con regla de propagación, un párrafo por modo) |
| Las pruebas de generación y auditoría dependen del modelo y no son deterministas | Una corrida por caso, persistida con fecha en `evidence/` (D7, D15); el quickstart la cita como evidencia de esa corrida, no como garantía |
| El comando deja de contar comentarios HTML (D10): cambia lo que publica sobre los fixtures | Se declara en `rules.md` junto al comando y en las cabeceras de fixture; la línea base sigue `Pendiente de recomputar` y se recomputa después de integrar (Out of Scope) |
