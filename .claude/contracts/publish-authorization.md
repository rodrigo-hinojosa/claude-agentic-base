# Contrato — Autorización de publicación

Autoridad viva de la autorización con que `developer` publica una rama de desarrollo hacia su remoto. El diseño de su portación vive en [`specs/002-portar-agentes/`](../../specs/002-portar-agentes/spec.md) y su verificación en [`specs/002-portar-agentes/evidence.md`](../../specs/002-portar-agentes/evidence.md); divergir de aquel diseño acá exige anotarlo en la spec de la feature correspondiente, no silenciarlo (regla 09, `.claude/rules/09-punteros-y-replicas.md`).

Procedencia: réplica declarada del contrato madurado en un workspace anterior, portada y parametrizada el 07-09-2026 (feature `002-portar-agentes`).

**Precedente citado, no replicado**: la `MarcaDeAprobacion` de [`write-plan.md`](write-plan.md), que aprueba operaciones ya escritas en un plan. Esta autorización aprueba una **operación futura sobre una rama nombrada**, porque el commit todavía no existe cuando el usuario aprueba. Comparten tres ideas — la escribe la sesión principal, lleva un hash que el receptor recomputa, y una alteración posterior la invalida — y difieren en qué cubren.

## Quién la emite y cuándo

1. El usuario pide abrir o transicionar un desarrollo **y** publicar la rama.
2. La sesión principal muestra el gate con lo exacto: clave, repositorio, rama que se va a publicar, y que la publicación es un push sin forzar de esa rama y nada más.
3. Solo si el usuario aprueba, la sesión principal escribe el bloque y lo incluye en la invocación a `developer`.

**Nunca la escribe el agente, ni el usuario en prosa.** Una petición como "haz push" dentro de la invocación no es una autorización: le falta la forma y el hash, y el agente la trata como `ausente`.

## Forma

Un bloque delimitado por par (repositorio, rama), con seis campos en este orden. Un desarrollo de varias piezas con publicación lleva un bloque por pieza, y cada pieza busca el bloque cuyo `repositorio` y `rama` coinciden con lo que operó. El campo `clave` usa la clave del issue si el proyecto gestiona su trabajo en Jira (`<CLAVE>-XXX`, regla 05); si no, el identificador del desarrollo que el proyecto use (por ejemplo el slug de la feature) — el campo nunca queda vacío ni sin semántica.

```text
<!-- publish-authorization -->
clave: <CLAVE>-XXX
repositorio: ejemplo-backend
rama: tipo/<CLAVE>-XXX-descripcion
aprobacion: "expresión del usuario en el gate, citada"
fecha: 2026-09-07T15:12:30-04:00
hash: <SHA-256 de la línea canónica>
<!-- end-publish-authorization -->
```

**Línea canónica**: `clave|repositorio|rama|fecha`, sin espacios alrededor de las barras y sin salto de línea final.

```bash
printf '%s|%s|%s|%s' "$clave" "$repositorio" "$rama" "$fecha" | shasum -a 256 | cut -d' ' -f1
```

La `aprobacion` no entra al hash: es la cita para quien lea el reporte, y cambiarla no cambia lo autorizado. Los cuatro campos que sí entran son exactamente los que definen la operación.

## Qué verifica el agente antes de publicar

En este orden; la primera falla detiene y clasifica:

| Paso | Comprobación | Si falla |
| --- | --- | --- |
| 1 | Existe un bloque con ambos delimitadores cuyo `repositorio` es el de la pieza | `ausente` |
| 2 | Los seis campos están presentes y no vacíos | `malformada` |
| 3 | El hash recomputado coincide con el declarado | `malformada` |
| 4 | `clave` es la del desarrollo operado en esta corrida | `no coincide` |
| 5 | `repositorio` y `rama` son exactamente los que el agente operó en esta corrida | `no coincide` |
| 6 | `rama` no es la rama base ni la rama por defecto del repositorio | `no coincide` |
| 7 | Esta corrida produjo un `CommitDeSpec` en esa rama (ver [`specs/002-portar-agentes/contracts/developer-flow.md`](../../specs/002-portar-agentes/contracts/developer-flow.md)) | `sin commit` |
| 8 | Tras `fetch`, la rama remota (si existe) es ancestro de la local (`merge-base --is-ancestor origin/<rama> <rama>`) | `no fast-forward` |
| 9 | Si `origin/<rama>` existe, `fecha` es posterior a la fecha de committer de su punta (`git log -1 --format=%cI origin/<rama>`) | `reutilizada` |

Con las nueve en verde: `repo_git "$DIR" push -u origin <rama>` — el envoltorio de la skill `development-repositories` que neutraliza hooks, y `-u` para que el upstream quede en la propia rama remota —, **sin `--force` ni variantes**, y después `git ls-remote origin refs/heads/<rama>` para leer la referencia remota resultante, que es lo que el reporte declara. Un push cuyo resultado no se releyó se reporta `pendiente: no verificada`, no como publicado.

## Lo que la autorización no habilita

- Abrir un pull request: lo abre una persona.
- `--force`, `--force-with-lease`, `--delete`, borrar ramas locales o remotas, reescribir historia.
- Publicar una rama distinta de la nombrada, o hacia otro repositorio.
- Publicar hacia la rama por defecto del repositorio.
- Reutilizarse en otra corrida: la verificación 9 detecta todo bloque emitido antes del último push de esa rama. Si una corrida posterior necesita publicar otra vez la misma rama —una transición de estado—, la sesión principal emite una autorización nueva tras un gate nuevo. **Residuo declarado**: un bloque reutilizado antes del primer push de la rama, o con un reloj desfasado, no se detecta; es el límite de una garantía de proceso.

## Garantía, dicha con precisión

**Es de proceso.** `Bash` está declarada en `developer` y no distingue subcomandos: nada técnico impide un `git push` sin autorización. Lo que lo impide es este contrato y el cuerpo del agente que lo cita. La métrica de cumplimiento (cero publicaciones sin autorización; con autorización, solo la rama nombrada) queda `Pendiente` de instrumentarse en el proyecto que adopte el flujo.

## Referencias

- Verificación de la portación (casos tipados con bloque sintético): [`specs/002-portar-agentes/evidence.md`](../../specs/002-portar-agentes/evidence.md).
- Precedente: [`write-plan.md`](write-plan.md), autoridad del plan de escritura que `developer` también produce.
