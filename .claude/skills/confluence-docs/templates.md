# Plantillas de entregable — estándar de documentación

> **Fuente única (SSOT)** del formato de los entregables que produce `confluence-docs`: qué secciones lleva cada tipo, en qué orden y cuáles pueden omitirse. Todo artefacto del repositorio que necesite esa información **cita este archivo**; ninguno la reproduce.

## Qué define y qué no

| Materia | Autoridad | Aquí |
| --- | --- | --- |
| **Estructura** de cada tipo: secciones, orden, omitibles | **Este archivo** | Se define |
| **Exigencias transversales** que caen sobre el entregable: idioma, SSOT, cita de fuente, seguridad | [`rules.md`](rules.md) | Se **cita por número**, nunca se copia |
| **Maquetación**: niveles de encabezado, numeración decimal, callouts | Regla 25 de `rules.md`, aplicada en el modo generar | No se fija aquí |
| Formato de un **ticket del tablero del proyecto** | Skill `jira-management` | Solo se remite |
| Formato de un artefacto **SDD** | `.specify/templates/` | Solo se remite |

Son **dos capas, no dos copias**: este archivo dice qué secciones lleva un ADR; `rules.md` dice que toda afirmación no trivial cita su fuente. Ninguna reproduce a la otra.

## Procedencia

Réplica declarada del estándar consolidado en un workspace anterior, portada y depurada el 06-09-2026 (feature `001-portar-skills-rules`). Las plantillas viven en el repositorio para que la skill opere en cualquier clon, sin depender de artefactos externos.

---

## 1. Índice de tipos

| Tipo | Dónde vive su formato |
| --- | --- |
| `doc-tecnica` | Sección 2 de este archivo |
| `adr` | Sección 3 |
| `bitacora` | Sección 4 |
| `resumen` | Sección 5 |
| `sdd` | Sección 6 — se remite a `.specify/templates/` |
| `ticket` | Sección 6 — se remite a `jira-management` |

---

## 2. Documentación técnica (`doc-tecnica`)

Todas las secciones son obligatorias.

| # | Sección | Qué contiene |
| --- | --- | --- |
| 1 | **Propósito y alcance** | Para qué existe el documento y qué cubre, en una o dos frases. Si el documento es autoridad de un dato, aquí va el callout SSOT declarando de qué |
| 2 | **Descripción** | Qué es la cosa documentada y cómo funciona. El cuerpo del documento |
| 3 | **Uso y ejemplos** | Cómo se usa en la práctica, con casos concretos y bloques ejecutables cuando aplique |
| 4 | **Decisiones y supuestos** | El porqué, no solo el qué: qué se decidió, qué se descartó, qué se está suponiendo |
| 5 | **Referencias y pendientes** | Enlaces a las fuentes, y lo que queda abierto |

**Qué la distingue**: describe algo que existe y que otros van a usar. Si lo que se documenta es una decisión y no una cosa, el tipo es `adr`.

---

## 3. Registro de decisión (`adr`)

Todas las secciones son obligatorias.

| # | Sección | Qué contiene |
| --- | --- | --- |
| 0 | **Identificador `ADR-NNN`** | Correlativo, en el título. Exigido por la regla 13 |
| 1 | **Estado**, con **dueño** y **fecha** | `Propuesta` por defecto, o `Aceptada`, `Reemplazada`, `Obsoleta`. Quién es dueño de la decisión y cuándo se tomó |
| 2 | **Contexto** | La situación y las fuerzas en juego: requisitos, restricciones, qué problema fuerza a decidir |
| 3 | **Decisión** | Qué se decidió, en afirmativo y sin ambigüedad |
| 4 | **Alternativas consideradas** | Las que se evaluaron **de verdad**, con su motivo de descarte. No se rellenan con opciones de paja |
| 5 | **Consecuencias** | Efectos positivos y negativos. **Debe incluir contras**: una decisión sin contras está mal analizada (regla 13) |
| 6 | **Referencias** | Enlaces, tickets, documentos relacionados. Se omite si no hay |

**Por qué dueño y fecha no son opcionales**: sin registro escrito con dueño y fecha no hay decisión válida — una plantilla sin esos campos no permite exigirlo (regla 13).

**Qué lo distingue**: registra una elección entre alternativas con consecuencias. Si no hubo alternativas reales, no es un ADR.

---

## 4. Bitácora (`bitacora`)

| # | Sección | Obligatoria | Qué contiene |
| --- | --- | --- | --- |
| 1 | **Contexto** | Sí | Fecha y en qué situación se hizo lo que se hizo |
| 2 | **Hecho** | Sí | Qué se hizo, en concreto |
| 3 | **Aprendizajes** | **Omitible** | Qué se aprendió. Se omite si no hubo nada que aprender, no se rellena |
| 4 | **Pendientes** | Sí | Qué quedó abierto |

**Qué la distingue**: es un registro fechado de trabajo hecho, para consultar después. Tipo corto de tema único; **no** se le aplica la estructura documental de la regla 25.

---

## 5. Resumen ejecutivo (`resumen`)

| # | Sección | Obligatoria | Qué contiene |
| --- | --- | --- | --- |
| 1 | **Resumen ejecutivo** | Sí | Lo más importante primero, en tres a cinco viñetas orientadas a decisión |
| 2 | **Puntos clave** | Sí | El detalle que sostiene el resumen |
| 3 | **Riesgos** | **Omitible** | Qué puede salir mal. Se omite si no hay riesgos identificados |
| 4 | **Recomendación** | Sí | Qué se propone hacer y por qué |

**Qué lo distingue**: está orientado a que alguien decida, no a que entienda un sistema. Tipo corto de tema único; **no** se le aplica la regla 25.

---

## 6. Tipos que se remiten

Este archivo **no define** su formato. Se listan para que quien busque no concluya que no existen.

| Tipo | Autoridad | Nota |
| --- | --- | --- |
| `sdd` | `.specify/templates/` | `spec.md`, `plan.md`, `tasks.md` según corresponda. Las genera el motor spec-kit |
| `ticket` | Skill [`jira-management`](../jira-management/SKILL.md) | Fuera del alcance de `confluence-docs`. Su plantilla real es la observada en el tablero del proyecto y puede diferir de la genérica |

---

## 7. Correcciones

Toda definición que un artefacto anterior contradiga queda registrada aquí, con su versión previa y su motivo de superación. **No se borra lo superado**: sin ese registro, quien vuelva al archivo no puede saber si un dato cambió o si siempre fue así. Este archivo arranca su historial propio en este repositorio; el historial del workspace de origen no se portó.

Sin correcciones registradas a la fecha.

---

## 8. Cómo usa este archivo cada modo

| Modo | Qué toma de aquí |
| --- | --- |
| **generar** | La plantilla del tipo solicitado, más las reglas de `rules.md` que activen |
| **auditar** | Las secciones esperadas del tipo, para detectar faltantes o fuera de orden |
| **consultar** | La sección del tipo, entera, más el subconjunto de reglas aplicables |
| **publicar** | Nada directamente: publica contenido ya conforme |
