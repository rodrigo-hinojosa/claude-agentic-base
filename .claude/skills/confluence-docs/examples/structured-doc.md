<!--
Ejemplo de referencia del modo GENERAR (SKILL.md §3): documento extenso bajo la regla 25.
No es documentación real de un proyecto — es material de prueba de la skill. Datos sintéticos.
Contrastado contra rules.md el 15-09-2026 (feature 003-concision-confluence-docs).
-->

# Documentación técnica — Módulo de reglas (`rules.md`) de la skill `confluence-docs`

> **Fuente única (SSOT)** de las reglas operativas que aplica `confluence-docs`: qué exige cada regla, cómo la consumen los modos y cómo se regenera. Deriva de `.claude/rules/` y la constitución, y las enlaza sin reproducirlas.

- `rules.md` condensa el estándar en 25 reglas accionables más 8 de prosa, cada una con categoría, prioridad y, en prosa, método.
- El modo generar aplica el bloque de prioridad alta sin excepción; el modo auditar recorre la tabla completa regla por regla.
- Cuando cambian las reglas del repositorio o la constitución, `rules.md` se regenera a mano: no hay chequeo de drift automático.

| Campo | Valor |
| --- | --- |
| Artefacto documentado | `.claude/skills/confluence-docs/rules.md` |
| Tipo | Documentación técnica (doc extensa, regla 25 activa) |
| Autoridad de | Reglas operativas de la skill `confluence-docs` |
| Última actualización | 2026-09-15 |

## Índice

- §1. Descripción
  - §1.1 Estructura del archivo
- §2. Uso y ejemplos
  - §2.1 Modo generar
  - §2.2 Modo auditar
  - §2.3 Modo consultar
- §3. Decisiones y supuestos
- §4. Referencias y pendientes

| Artefacto | Qué dato consume o rol del enlace | Tipo de enlace |
| --- | --- | --- |
| `SKILL.md` modo generar | Bloque de prioridad alta más reglas condicionales | Consumo |
| `SKILL.md` modo auditar | Tabla completa de reglas | Consumo |
| `examples/*.md` | Reglas verificadas en cada validación | Consumo |

Nota de mantención: agregar una fila cuando un artefacto nuevo empiece a consumir estas reglas; quitarla cuando deje de hacerlo.

## 1. Descripción

`rules.md` es un archivo Markdown en `.claude/skills/confluence-docs/rules.md`. Condensa el estándar en 25 reglas accionables más 8 de prosa; las de prosa agregan su método, Comando o Juicio.

### 1.1 Estructura del archivo

Tres piezas consumibles: la tabla de reglas accionables, el bloque de prioridad alta y el detalle por categoría. El bloque de prioridad alta es el subconjunto que todo entregable generado cumple sin excepción, y el detalle por categoría trae el "cuándo aplica" de cada regla.

## 2. Uso y ejemplos

### 2.1 Modo generar

Aplica el bloque de prioridad alta sin excepción, más las reglas condicionales que active el tipo de entregable y, si corresponde, la regla 25 de estructura.

### 2.2 Modo auditar

Recorre el documento regla por regla contra la tabla de `rules.md`. Cada incumplimiento es un hallazgo cuya severidad es la prioridad de la regla, salvo un secreto o dato personal, que siempre es severidad alta.

### 2.3 Modo consultar

Filtra `rules.md` por tipo o categoría y devuelve el subconjunto de reglas aplicables, sin generar ni auditar.

## 3. Decisiones y supuestos

`rules.md` deriva de las reglas del repositorio y de la constitución, en vez de leerlas en vivo en cada invocación. La relectura en vivo introduce costo y no-determinismo entre invocaciones consecutivas. La regeneración es manual y consciente.

## 4. Referencias y pendientes

Catálogo operativo: [`rules.md`](../rules.md). Plantillas de entregable: [`templates.md`](../templates.md).

Pendiente: recomputar la línea base de prosa sobre el corpus del proyecto (ver `rules.md`, "Línea base por tipo de documento").
