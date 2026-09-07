# Flujo del agente developer — contrato de interacción

Quién hace qué cuando `developer` abre, transiciona o publica un desarrollo, y qué no puede hacer nadie más. Lo gobiernan dos hechos del harness, verificados en el diseño de origen y vigentes en esta base: la pregunta interactiva no existe dentro de un subagente, y el agente no lleva la herramienta de lanzar subagentes. El flujo de escritura a Atlassian **no se redefine acá**: es el del contrato vivo [`.claude/contracts/write-plan.md`](../../../.claude/contracts/write-plan.md), con `developer` en el lugar del productor.

Procedencia: adaptación declarada del contrato de diseño del workspace de origen, portada el 07-09-2026 (feature `002-portar-agentes`).

## Flujo A — Abrir un desarrollo

| Paso | Actor | Acción | Salida |
| --- | --- | --- | --- |
| 1 | Usuario | Pide abrir el desarrollo `<CLAVE>-XXX` con su `slug` en uno o más componentes; opcionalmente nombra la rama base y pide publicar. Solo en verificación nombra además la raíz de clones, el catálogo y el índice de prueba, que el agente pasa a los scripts como `--root`, `--catalog`, `--only` e `--index` en cada llamada, porque el estado del shell no persiste entre llamadas | Petición |
| 2 | Sesión principal | Si pidió publicar: gate con clave, repositorio y rama exacta; si aprueba, emite una `AutorizacionDePublicacion` por par (repositorio, rama) según [`.claude/contracts/publish-authorization.md`](../../../.claude/contracts/publish-authorization.md) | Invocación con petición y, si aplica, autorizaciones |
| 3 | `developer` | Resuelve cada componente contra el catálogo (`development-repositories`, modo consultar); lee el issue por la skill del tablero; rehúsa si la clave falta (va al Flujo C); valida el `slug`; lee el índice y detiene la pieza con `no creada: entrada existente` si ya hay una entrada no terminal para (clave, repositorio), antes de tocar el repositorio | Piezas a abrir |
| 4 | `developer` | Por pieza: lee el estado real de la copia (modo preparar, verbo `status`); resuelve la `RamaBase` (remoto o invocación) y comprueba las precondiciones — si la copia está limpia en otra rama, cambia a la base con `switch` sin `-c` y lo declara —; una pieza que falla se reporta y no bloquea a las demás | Precondiciones por pieza |
| 5 | `developer` | Crea la `RamaDeDesarrollo` desde la rama base actualizada, a través del envoltorio que neutraliza hooks; si ya existe, la pieza se detiene con `no creada: rama existente` y reporta la punta | Rama |
| 6 | `developer` | Redacta la spec sobre la plantilla (`development-repositories`, modo especificar) desde el issue, la documentación y el código del componente en solo lectura; sin marcadores ni `Guía:`; vacíos con su nombre | `SpecDeDesarrollo` |
| 7 | `developer` | Commitea **solo** la spec en esa rama, hooks neutralizados; relee hash y rama | `CommitDeSpec` |
| 8 | `developer` | Registra la `EntradaDeIndice` en `spec-index.md` con estado `abierta`; corre el verificador de punteros; **no commitea en el workspace** | Entrada + veredicto |
| 9 | `developer` | Verifica la autorización (contrato de publicación); si es válida, `repo_git push -u origin <rama>` sin forzar y relee la referencia remota; si no, push pendiente con motivo; en varias piezas, cada una con su bloque | Publicación o pendiente |
| 10 | `developer` | Devuelve el `ReporteDeOperacion` ([`operation-report.md`](operation-report.md)) con estado leído, pendientes y límites | Reporte |
| 11 | Sesión principal | Presenta el reporte; muestra en el gate el push pendiente si lo hay; el commit del índice queda para quien opera bajo la regla 05 | Cierre |

## Flujo B — Transicionar una spec

| Paso | Actor | Acción |
| --- | --- | --- |
| 1 | Usuario | Pide pasar la spec de `<CLAVE>-XXX` en un repositorio a `en curso`, `cerrada` o `cancelada`; opcionalmente pide publicar |
| 2 | Sesión principal | Gate y autorización como en A2, si pidió publicar |
| 3 | `developer` | Localiza la entrada por (`clave`, `repositorio`); verifica que la transición está entre las cuatro admitidas; si no, rehúsa citándolas |
| 4 | `developer` | Precondiciones sobre la `RamaDeDesarrollo` (no sobre la base): copia limpia, en esa rama — o limpia en otra, y cambia con `switch` sin `-c` —, al día |
| 5 | `developer` | Edita la fila `Estado` de la spec y commitea solo ese archivo; edita la entrada del índice con `Estado` y `Actualizada` en la misma operación; si spec e índice divergían, manda la spec y la corrección se declara |
| 6 | `developer` | Publicación como en A9; si el usuario pidió mover el issue en el tablero, produce el `PlanDeEscritura` (Flujo C) |
| 7 | `developer` | Reporte |

## Flujo D — Consultar el estado de los desarrollos

| Paso | Actor | Acción |
| --- | --- | --- |
| 1 | Usuario | Pide el estado de los desarrollos abiertos |
| 2 | `developer` | Lee el índice y corre `check-spec-pointers.sh` (`--index` y `--root` cuando aplique); reporta los tres veredictos sin renombrarlos y el vacío calificado |
| 3 | `developer` | Por entrada no terminal cuyo puntero resuelve, lee la fila `Estado` de la spec en su rama con `git show refs/heads/<rama>:<ruta>`, sin checkout; si difiere del índice, corrige el índice — `Estado` y `Actualizada` — y lo declara como `corregida contra la spec` |
| 4 | `developer` | Reporte; el cambio del índice queda pendiente para quien opera, como siempre |

## Flujo C — Escribir a Jira o Confluence

El de [`.claude/contracts/write-plan.md`](../../../.claude/contracts/write-plan.md), con `developer` como productor: produce el `PlanDeEscritura` sin marca, con `origen: developer`; la sesión principal muestra el gate, escribe la `MarcaDeAprobacion` y lanza a `atlassian-executor`; el hijo ejecuta y reporta. El agente **no** dispone de herramientas de escritura remota ni de la herramienta de lanzar subagentes: ambas garantías son de permisos.

Casos que lo disparan: crear el issue que falta para abrir un desarrollo, mover el issue cuando una transición de spec lo amerita y el usuario lo pide, actualizar una página de Confluence tras un análisis.

## Prohibiciones por actor

- **`developer`** no publica sin autorización válida; no abre pull requests; no borra, fuerza ni reescribe; no commitea en el workspace; no escribe código de producto ni ningún archivo distinto de la spec; no escribe a Atlassian; no lanza subagentes; no ejecuta hooks del repositorio operado; no lee archivos de secretos; no inventa la clave, el slug ni la rama base; no reutiliza ramas existentes.
- **La sesión principal** no parcha una autorización ni un plan después de mostrados: una corrección del usuario produce un gate nuevo.
- **Nadie** asume éxito: rama, hash, entrada y referencia remota se leen después de operar.

## Qué queda pendiente y para quién

| Pendiente | Quién lo cierra | Cómo |
| --- | --- | --- |
| Push sin autorización | Sesión principal | Gate con el comando exacto que el reporte nombra |
| Commit de `spec-index.md` en el workspace | Quien opera | Rama `chore/` y PR, regla 05 |
| Pull request de la rama de desarrollo | Una persona | Cuando decida que la rama está lista |
| Issue en el tablero, página en Confluence | `atlassian-executor` | Plan aprobado, Flujo C |
