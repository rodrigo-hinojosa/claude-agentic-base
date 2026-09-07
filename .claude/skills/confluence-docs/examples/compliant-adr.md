# ADR-000: Usar un catálogo versionado como fuente de reglas de `confluence-docs`

> Ejemplo de referencia del modo GENERAR: documento conforme al estándar. No es un ADR real de un proyecto — es material de prueba de la skill (ver `SKILL.md` §3). Datos sintéticos.

## Estado

Aceptada. Dueño: responsable de documentación del proyecto | Fecha: 2026-09-06.

## Contexto

La skill `confluence-docs` necesita una fuente de reglas para los modos generar y auditar. Derivar las reglas leyendo `.claude/rules/` y la constitución en cada invocación es posible, pero introduce costo y no-determinismo. Se evaluó fijar la fuente en un catálogo versionado.

## Decisión

`confluence-docs` usa [`rules.md`](../rules.md) como fuente única y versionada. Se regenera cuando cambian las reglas del repositorio o la constitución; no se deriva en vivo en cada invocación.

## Alternativas consideradas

- **Reglas vivas** (leer `.claude/rules/` + constitución en cada invocación): siempre actualizada, pero costosa y no determinista — dos invocaciones consecutivas podrían leer estados intermedios distintos.
- **Híbrido con detección de drift**: más robusto (avisa si el catálogo quedó desactualizado), pero añade complejidad no justificada para v1.

## Consecuencias

Positivas: reglas estables y trazables, sin relectura costosa por invocación. Negativas: si `.claude/rules/` o la constitución cambian, `rules.md` puede quedar desactualizado hasta su próxima regeneración manual — deuda asumida conscientemente para v1.

## Referencias

Fuente: [`rules.md`](../rules.md) (catálogo operativo de la skill) y [`templates.md`](../templates.md) §3 (plantilla de ADR).

## Próximos pasos

Evaluar en una futura iteración el modo híbrido (chequeo de drift) si el catálogo se desactualiza con frecuencia en la práctica.
