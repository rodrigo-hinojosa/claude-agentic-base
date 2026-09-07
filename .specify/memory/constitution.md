<!--
Sync Impact Report — 2026-09-06
- Version change: template (sin ratificar) → 1.0.0 (ratificación inicial)
- Modified principles: n/a (primera versión; los cinco principios se definen por primera vez)
- Added sections: Core Principles (I-V), Restricciones de seguridad y datos,
  Flujo de desarrollo y gates, Governance
- Removed sections: ninguna (se llenaron todos los slots del template)
- Templates requiring updates:
  - .specify/templates/plan-template.md ✅ alineado (el Constitution Check es genérico y
    deriva sus gates de este archivo; no requiere edición)
  - .specify/templates/spec-template.md ✅ sin referencias a la constitución; sin cambios
  - .specify/templates/tasks-template.md ✅ sin referencias a la constitución; sin cambios
  - README.md ✅ sin referencias que corregir
- Follow-up TODOs: ninguno (sin placeholders diferidos)
-->

# Constitución de la Base Agéntica Personal (claude-agentic-base)

## Core Principles

### I. Verificación antes de afirmación

Toda afirmación no trivial DEBE provenir de una fuente verificada (archivo leído, comando
ejecutado, documentación consultada) y citarla. Está prohibido inventar hechos, APIs, rutas,
versiones o resultados. Lo que no se sabe se declara: un vacío se marca con su nombre
(`Pendiente`, `Sin información registrada`), nunca se rellena con genérico, y hecho,
inferencia y suposición se distinguen siempre de forma explícita.

Autoridad de detalle: `.claude/rules/01-prevencion-alucinaciones.md`.

### II. Referenciar, no duplicar

Cuando un dato lo consumen varios artefactos, DEBE vivir en uno solo y los demás lo citan;
el que lo aloja es su autoridad. Toda reproducción de contenido ajeno DEBE declararse como
réplica, con fuente y fecha — una réplica encubierta es no conforme. Un puntero cita un
identificador que existe, y toda cifra derivada se acompaña de su origen para poder
recomputarse. Racional: la réplica queda falsa en silencio cuando el origen cambia; el
puntero falla avisando.

Autoridad de detalle: `.claude/rules/09-punteros-y-replicas.md`.

### III. Trazabilidad SDD end-to-end

Todo artefacto sustantivo del repositorio DEBE nacer de una spec y recorrer el flujo
spec-kit completo (`specify` → `clarify` → `plan` → `tasks` → `implement`), trazado en
`specs/<NNN-slug>/` y desarrollado en la rama `<NNN-slug>`. `main` es la línea base: no
recibe commits directos, se integra por Pull Request, y la implementación nunca adelanta a
la fase de tasks. Las correcciones de andamiaje o gobernanza quedan exentas de la traza
spec-kit, pero NUNCA de rama y PR.

Autoridad de detalle: `.claude/rules/05-ramas-y-flujo-sdd.md`.

### IV. Escritura con gate en sistemas compartidos

Toda escritura a un sistema compartido (Confluence, Jira, git remoto, o equivalente) DEBE
mostrar antes el contenido exacto que producirá y esperar aprobación explícita; en ediciones
de campos el gate es por operación, con secuencia leer → componer → escribir → releer y
pre-flight de versión cuando la herramienta lo permita. Ninguna operación degrada en
silencio ante un fallo de acceso: se detiene y lo declara. Cada skill DEBE declarar qué
sostiene cada una de sus restricciones — permisos (herramienta no declarada) o proceso
(instrucción + gate) — sin presentar garantías de proceso como si fueran de permisos.

### V. Plantilla agnóstica y parametrizada

Esta base es una plantilla transversal: NINGÚN artefacto versionado contiene identificadores
de un tenant o proyecto concreto (cloudId, ids de proyecto/board/transiciones, labels,
claves de issue, URLs de instancia). Los valores que varían por proyecto se declaran como
`Pendiente de configurar` con su procedimiento de resolución en vivo, y los identificadores
de sesión (sitio, cloudId) se resuelven en runtime sin persistirse. La nomenclatura
distingue el origen de cada artefacto: skills del estándar sin sufijo, artefactos de
proyecto con su identificador al final, nombres en inglés bajo `.claude/`.

Autoridad de detalle: `.claude/rules/06-nomenclatura-agentica.md`.

## Restricciones de seguridad y datos

- Secretos y credenciales NUNCA se leen, escriben ni versionan; la autenticación a servicios
  externos es OAuth por sesión y ningún token entra al repositorio.
- Ejemplos y fixtures usan exclusivamente datos sintéticos; los datos personales de terceros
  quedan fuera de alcance de generación y edición.
- Acciones destructivas o irreversibles (borrado, force push, merge, escrituras masivas)
  exigen confirmación explícita del dueño; la detección de un secreto expuesto se reporta de
  inmediato con propuesta de rotación.

Autoridad de detalle: `.claude/rules/03-seguridad-y-secretos.md`.

## Flujo de desarrollo y gates

- El `Constitution Check` de `/speckit-plan` evalúa cada feature contra estos principios
  antes de la fase de investigación y de nuevo tras el diseño; toda violación se justifica
  en `Complexity Tracking` o se corrige.
- La evidencia de cierre de una feature es su `quickstart.md`: verificaciones ejecutables
  con resultado esperado, corridas antes del commit final. Las suites de tests incluidas en
  skills (`visual-docs/tests/`) DEBEN pasar en cada cambio que las toque.
- Commits en español, formato `tipo: descripción`, sin atribución automática ni emojis;
  staging acotado a la feature activa (skill `speckit-git-commit`), sin push ni merge sin
  confirmación explícita.
- El idioma, el formato y la estructura de los entregables los gobiernan
  `.claude/rules/00-lenguaje-y-formato.md` y `02-documentacion-y-entregables.md`, con las
  plantillas de `confluence-docs/templates.md` como autoridad única de estructura.

## Governance

Esta constitución prevalece sobre cualquier práctica ad-hoc del repositorio. Las reglas de
`.claude/rules/` son su autoridad de detalle: la constitución fija el principio y remite; la
regla contiene el texto operativo íntegro. Un conflicto entre ambas se resuelve enmendando
de forma explícita, nunca ignorando en silencio.

- **Enmiendas**: toda modificación de este archivo nace en una rama, se integra por PR y
  actualiza la versión y la fecha de enmienda. La confirmación explícita del dueño del
  repositorio es el gate de integración.
- **Versionado semántico**: MAJOR para remociones o redefiniciones incompatibles de
  principios; MINOR para principios o secciones nuevas o ampliadas materialmente; PATCH
  para clarificaciones y redacción.
- **Revisión de cumplimiento**: el `Constitution Check` de cada plan y el análisis de
  consistencia (`/speckit-analyze`) verifican estos principios por feature. La réplica
  deliberada entre las reglas del proyecto y el set global del usuario está declarada en
  `.claude/rules/09-punteros-y-replicas.md` (Alcance) y se reconcilia de forma explícita
  cuando diverge.
- Los proyectos derivados de esta plantilla PUEDEN reemplazar esta constitución por la suya;
  lo que no pueden es operar con esta como si fuera suya sin resolver sus
  `Pendiente de configurar`.

**Version**: 1.0.0 | **Ratified**: 2026-09-06 | **Last Amended**: 2026-09-06
