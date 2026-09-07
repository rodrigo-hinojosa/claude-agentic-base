# Documentación y entregables

<!-- Define cómo producir contenido reutilizable: docs, tickets, ADR, bitácoras, resúmenes. -->

## Principio

Todo entregable debe quedar listo para usarse en su destino real (documentación, tablero, presentación, ticket, bitácora) con mínima edición posterior.

> **Esta regla registra y remite; no contiene.** Los criterios de calidad son suyos y se aplican siempre. La **estructura** de cada entregable —qué secciones lleva, en qué orden, cuáles se omiten— vive en [`.claude/skills/confluence-docs/templates.md`](../skills/confluence-docs/templates.md), que es su autoridad única. Reproducir esas plantillas aquí crearía una segunda copia que se desincronizaría en silencio, y nadie sabría cuál de las dos rige.

Todo lo que esta regla necesita vive **dentro del repositorio**. Los comandos que se mencionan al pie son atajos opcionales que pueden existir o no en la configuración de quien trabaja; su ausencia no exime de cumplir el formato, y su presencia no lo reemplaza.

## Documentación técnica

Criterios de calidad, exigibles siempre:

- Empieza con propósito y alcance en una o dos frases.
- Estructura escaneable: encabezados, listas, tablas. Nada de muros de texto.
- Incluye ejemplos concretos y bloques de código ejecutables cuando aplique.
- Documenta el "por qué", no solo el "qué": decisiones, supuestos y trade-offs.
- Cierra con próximos pasos, pendientes o referencias cuando corresponda.

Estructura: [`templates.md`](../skills/confluence-docs/templates.md) §2. Atajo opcional: `/documentar`.

## Tickets (Jira)

Formato estándar para un ticket bien formado:

- **Título:** claro y accionable, en imperativo.
- **Contexto:** por qué existe el ticket.
- **Descripción:** qué hay que hacer.
- **Criterios de aceptación:** lista verificable de condiciones de "hecho".
- **Notas técnicas:** dependencias, riesgos, enlaces.

Si el proyecto documenta el estándar real de su tablero mediante la skill `jira-management`, ese estándar observado es la autoridad para ese tablero y puede diferir del formato genérico de arriba. No es una divergencia: son ámbitos distintos. Atajo opcional para tickets genéricos: `/ticket`.

## Registros de decisión (ADR)

Un ADR registra una elección entre alternativas reales, con sus consecuencias. Exigencias que esta regla sostiene:

- **Dueño y fecha son obligatorios.** Sin registro escrito con ambos no hay decisión válida.
- **Las alternativas son las que se evaluaron de verdad**, con su motivo de descarte. No se rellenan con opciones de paja.
- **Las consecuencias incluyen contras.** Una decisión sin contras está mal analizada.
- Si el proyecto mantiene una fuente única externa de decisiones (por ejemplo, un espacio de documentación), toda decisión estructural se refleja además allí. Dónde: `Pendiente de configurar` por proyecto.

Estructura: [`templates.md`](../skills/confluence-docs/templates.md) §3. Atajo opcional: `/decision`.

## Resúmenes ejecutivos

Criterios de calidad:

- Orientado a decisión: qué se necesita saber y qué acción se espera.
- Sin jerga innecesaria para la audiencia objetivo.
- Lo más importante primero; la conclusión nunca queda enterrada.

Estructura: [`templates.md`](../skills/confluence-docs/templates.md) §5. Atajo opcional: `/resumen`.

## Bitácoras

Criterio de calidad: trazable y consultable después. Una bitácora que no permite reconstruir qué pasó no cumple su función.

Estructura: [`templates.md`](../skills/confluence-docs/templates.md) §4. Atajo opcional: `/bitacora`.
