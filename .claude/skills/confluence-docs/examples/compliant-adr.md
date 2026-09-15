<!--
Ejemplo de referencia del modo GENERAR (SKILL.md §3): ADR conforme al estándar.
No es un ADR real de un proyecto — es material de prueba de la skill. Datos sintéticos.
Contrastado contra rules.md el 15-09-2026 (feature 003-concision-confluence-docs).
-->

# ADR-000: Usar un catálogo versionado como fuente de reglas de `confluence-docs`

## Estado

Aceptada. Dueño: Marcela Ibáñez (nombre sintético) | Fecha: 2026-09-06.

## Contexto

La skill `confluence-docs` necesita una fuente de reglas para los modos generar y auditar. Derivar las reglas leyendo `.claude/rules/` y la constitución en cada invocación introduce costo y no-determinismo: dos invocaciones consecutivas podrían leer estados intermedios distintos.

## Decisión

`confluence-docs` usa [`rules.md`](../rules.md) como fuente única y versionada. Se regenera cuando cambian las reglas del repositorio o la constitución; no se deriva en vivo en cada invocación.

## Alternativas consideradas

- **Reglas vivas** (leer `.claude/rules/` + constitución en cada invocación): siempre actualizada, pero costosa y no determinista.
- **Híbrido con detección de drift**: más robusto, porque avisa si el catálogo quedó desactualizado, pero añade complejidad no justificada para v1.

## Consecuencias

Positivas: reglas estables y trazables, sin relectura costosa por invocación. Negativas: si `.claude/rules/` o la constitución cambian, `rules.md` puede quedar desactualizado hasta su próxima regeneración manual.

## Referencias

Fuente: [`rules.md`](../rules.md), catálogo operativo de la skill.
