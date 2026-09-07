# Data Model: Portar agentes del workspace CIAM

Los "datos" de esta feature son artefactos de configuración y las entidades contractuales que gobiernan la escritura delegada. Las entidades del plan tienen su autoridad en `.claude/contracts/write-plan.md` (decisión D5 de research.md); aquí se describen para diseño y verificación, remitiendo sin replicar.

## Agente de rol

Artefacto en `.claude/agents/<nombre>.md`.

| Campo | Definición | Validación |
|-------|------------|------------|
| `name` (frontmatter) | Identificador, igual al nombre de archivo | Inglés, sin sufijo de proyecto en la plantilla |
| `description` | Cuándo lo invoca la sesión principal | Sin referencias corporativas; remite a skills por su nombre de la base |
| `tools` | Allowlist de herramientas | Prefijo `mcp__atlassian__` para Atlassian; coherente con la garantía de Permisos que el cuerpo declara |
| `model` | Modelo por rol | Se conserva del origen (analítico vs ejecutor) |
| Cuerpo | Mecanismos, parámetros, fronteras | Parámetros por proyecto `Pendiente de configurar`; declara renombre `<rol>-<proyecto>` al adoptarse |

**Instancias**: `product-owner` (lectura y propuesta; produce planes), `developer` (abre desarrollos; produce planes; publica con autorización), `atlassian-executor` (clase ejecutor; consume planes).

**Invariante estructural**: ningún agente productor declara tools de escritura al conector ni la herramienta de lanzar subagentes; el ejecutor no declara herramientas de análisis ni borrado.

## Contract (autoridad runtime)

Documento en `.claude/contracts/`.

| Instancia | Qué gobierna | Relación |
|-----------|--------------|----------|
| `write-plan.md` | Estructura del plan, marca de aprobación, catálogo cerrado, frontera de resolución, reporte | Citado por los 3 agentes; define las entidades del plan |
| `publish-authorization.md` | Autorización de push por par (repositorio, rama), nueve verificaciones, lista negativa | Citado por `developer`; precedente conceptual en `write-plan.md` |

**Validación común**: cero referencias corporativas; punteros que resuelven; divergencias diseño↔contrato se anotan en esta spec.

## Entidades del plan (autoridad: `write-plan.md`)

- **PlanDeEscritura**: secciones en orden fijo con delimitador de cierre; una corrección produce un plan nuevo.
- **Operacion**: par sistema+herramienta del catálogo cerrado; lo no catalogado se rehúsa individualmente.
- **MarcaDeAprobacion**: fecha, aprobación, alcance total y hash de la sección de operaciones; solo la escribe la sesión principal; alterar el plan la caduca.
- **ReporteDeEjecucion**: estado por operación con dato releído del sistema; posteriores a un aborto quedan "no ejecutadas".

**Transiciones**: borrador → sellado (sesión principal, tras gate) → ejecutado | rehusado (ejecutor: caducado / fuera de catálogo / precondición fallida).

## AutorizacionDePublicacion (autoridad: `publish-authorization.md`)

Bloque con seis campos; hash de línea canónica (clave|repositorio|rama|fecha). **Estados de fallo tipados**, cada uno producido por verificaciones distintas de la secuencia ordenada del contract:

| Estado | Qué lo produce |
| --- | --- |
| `ausente` | No hay bloque con ambos delimitadores para el repositorio de la pieza (verificación 1). Una petición en prosa ("haz push") cae aquí: le faltan la forma y el hash |
| `malformada` | Falta un campo o está vacío (verificación 2), **o el hash recomputado no coincide con el declarado** (verificación 3) |
| `no coincide` | El bloque es internamente consistente, pero su `clave`, `repositorio` o `rama` no es la operada, o la rama es la base o la por defecto (verificaciones 4-6) |
| `sin commit` | La corrida no produjo un commit de spec en esa rama (verificación 7) |
| `no fast-forward` | La rama remota no es ancestro de la local (verificación 8) |
| `reutilizada` | La fecha del bloque no es posterior a la punta remota de esa rama (verificación 9) |

La distinción entre `malformada` y `no coincide` importa al verificar: un hash alterado es `malformada` (falla la integridad del bloque), no `no coincide` (que es desajuste con lo operado).

## Catálogo de repositorios

`development-repositories/repositories.md`. En la plantilla: estructura con columnas y cero filas reales; procedimiento de poblado por proyecto. Los scripts leen de aquí toda configuración específica (D6).

## Índice de specs de desarrollo

`development-repositories/spec-index.md`. Plantilla vacía; celda de recuento recomputable (el número se rehace, no se recuerda); el developer registra cada desarrollo con la entrada que define su contrato de flujo.

## Relaciones clave

```text
product-owner ──produce──> PlanDeEscritura ──sella──> sesión principal ──delega──> atlassian-executor
developer ─────produce──> PlanDeEscritura (ídem)
developer ──solicita──> AutorizacionDePublicacion ──emite──> sesión principal ──habilita──> push único
developer ──usa──> development-repositories (catálogo, scripts, índice, template)
atlassian-executor ──delega Confluence──> confluence-docs (modo publicar, equivalencia FR-005)
```
