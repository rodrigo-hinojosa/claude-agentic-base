# Documentación técnica — Módulo de reglas (`rules.md`) de la skill `confluence-docs`

> **Fuente única (SSOT)** del estándar operativo que aplica la skill `confluence-docs`. Cubre qué es `rules.md`, su estructura, cómo lo consumen los modos y cómo se regenera. No reproduce las reglas del repositorio ni la constitución: deriva de ellas y las enlaza. Ejemplo de referencia del modo generar para documentos extensos (regla 25). Datos sintéticos.

| Campo | Valor |
| --- | --- |
| Artefacto documentado | `.claude/skills/confluence-docs/rules.md` |
| Tipo | Documentación técnica (doc extensa, regla 25 activa) |
| Autoridad de | Reglas operativas de la skill `confluence-docs` |
| Fuente de derivación | Reglas del repositorio (`.claude/rules/`) y constitución |
| Última actualización | 2026-09-06 |

**Rutas de lectura**: quien **usa** la skill puede leer solo §1 y §4; quien la **mantiene** o **regenera** el catálogo debe leer §3, §5 y §6.

## Índice

- §1. Propósito y alcance
- §2. Qué es `rules.md`
- §3. Estructura del archivo
  - §3.1 Tabla de reglas accionables
  - §3.2 Bloque de prioridad alta
  - §3.3 Reglas por categoría
- §4. Cómo lo consumen los modos
  - §4.1 Modo generar
  - §4.2 Modo auditar
  - §4.3 Modo consultar
- §5. Cómo se regenera
- §6. Trazabilidad inversa

Seis secciones no justifican agrupar el índice en bloques nombrados: la regla 25 los reserva para partes con muchas entradas.

## 1. Propósito y alcance

`rules.md` es el catálogo operativo que gobierna la skill `confluence-docs`. Su propósito es ser la fuente única y versionada de las reglas que la skill aplica al generar y audita al validar, sin que la skill tenga que releer `.claude/rules/` ni la constitución en cada invocación.

## 2. Qué es `rules.md`

Es un archivo Markdown ubicado en `.claude/skills/confluence-docs/rules.md`. Condensa el estándar de documentación en 25 reglas accionables más 7 reglas de prosa, cada una con categoría y prioridad. Deriva de las reglas del repositorio y del estándar madurado en la práctica.

## 3. Estructura del archivo

`rules.md` se organiza en tres secciones consumibles.

### 3.1 Tabla de reglas accionables

Una tabla `# | Regla | Categoría | Prioridad` con las 25 reglas. Es la referencia primaria: cada fila es una regla verificable de forma binaria (Fuente: `rules.md`, sección "Reglas accionables (25)").

### 3.2 Bloque de prioridad alta

Un subconjunto explícito (reglas 1, 2, 3, 4, 5, 8, 9, 10, 11, 16) que todo entregable generado debe cumplir sin excepción, sirve de chequeo rápido en modo generar (Fuente: `rules.md`, sección "Reglas de prioridad alta").

### 3.3 Reglas por categoría

El detalle agrupado por categoría (lenguaje-formato, estructura, ssot-trazabilidad, verificacion, adr-decisiones, tickets, commits-git, seguridad, interaccion, sdd-speckit, presentacion), con el "cuándo aplica" de cada regla.

## 4. Cómo lo consumen los modos

La skill lee `rules.md` al inicio de cada invocación (Fuente: `SKILL.md`, encabezado del cuerpo).

### 4.1 Modo generar

Aplica el bloque de prioridad alta (§3.2) sin excepción, más las reglas condicionales que active el tipo y la extensión (incluida la regla 25 de estructura para documentos extensos).

### 4.2 Modo auditar

Recorre el documento regla por regla contra la tabla (§3.1). Cada incumplimiento es un hallazgo cuya severidad es la prioridad de la regla, con la excepción de que todo secreto o PII es severidad alta (regla 16).

### 4.3 Modo consultar

Filtra `rules.md` por tipo o categoría y devuelve el subconjunto de reglas aplicables más la plantilla del tipo, sin generar ni auditar.

## 5. Cómo se regenera

`rules.md` no es fuente primaria: es un derivado versionado. Cuando cambian las reglas del repositorio (`.claude/rules/`) o la constitución (`.specify/memory/constitution.md`), el flujo de regeneración es: contrastar el catálogo contra las fuentes actualizadas y editar las reglas afectadas. La regeneración es manual y consciente; el chequeo de drift automático queda como mejora futura.

## 6. Trazabilidad inversa

Qué consume este artefacto y qué se rompe si cambia:

| Consumidor | Qué dato consume o rol del enlace | Tipo de enlace | Regla de propagación |
| --- | --- | --- | --- |
| `SKILL.md` modo generar | Bloque de prioridad alta + reglas condicionales | Consumo | Si cambia una regla alta, revisar el §3 de `SKILL.md` |
| `SKILL.md` modo auditar | Tabla completa de reglas | Consumo | Si se agrega o quita una regla, el auditor la evalúa automáticamente al leer la tabla |
| `SKILL.md` modo consultar | Reglas por categoría | Consumo | Si cambia una categoría, la consulta refleja el nuevo subconjunto |
| `examples/*.md` | Reglas verificadas en las validaciones | Consumo | Un cambio de regla puede invalidar un ejemplo; re-auditar |

Mantención: al incorporar un artefacto que consuma estas reglas o que las enlace por navegación, agregarlo con su tipo de enlace. Si deja de consumirlas, quitarlo. Un cambio en `rules.md` obliga a re-auditar los ejemplos para confirmar que siguen conformes.

## Próximos pasos

- Recomputar la línea base de prosa sobre el corpus del proyecto (ver `rules.md`, "Línea base por tipo de documento").
- Evaluar el modo híbrido con detección de drift entre `rules.md` y las fuentes, si el catálogo se desactualiza con frecuencia.

## Referencias

- Catálogo operativo: [`rules.md`](../rules.md)
- Plantillas de entregable: [`templates.md`](../templates.md)
