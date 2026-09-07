#!/bin/sh
# lib-repo-state.sh — biblioteca compartida de lectura de estado de un repositorio local.
# Skill: development-repositories. Procedencia de la portación: specs/002-portar-agentes/.
#
# Se consume con "." (source), no se ejecuta sola:
#
#     . "$(dirname "$0")/lib-repo-state.sh"
#
# Ejecutarla directo imprime su propósito y sale 0.
#
# Por qué existe una sola implementación: presencia, rama, limpieza y situación
# respecto del remoto los leen todos los scripts de la skill. Dos lecturas del
# mismo estado divergen en silencio, que es la regla 09 del repositorio
# (.claude/rules/09-punteros-y-replicas.md) aplicada a código.
#
# -----------------------------------------------------------------------------
# Funciones expuestas, y qué devuelve cada una
# -----------------------------------------------------------------------------
#
#   repo_git <dir> <args...>
#       Envoltorio único de git (ver la sección "Neutralización" más abajo).
#       Todos los scripts de la skill invocan git a través de él; ninguno llama
#       a git directamente. Propaga el código de salida de git tal cual.
#
#   repo_git_available
#       Solo como condición (if / && / ||). Devuelve 0 si git está disponible en
#       el PATH, 1 si no. No imprime nada.
#
#   repo_presence <dir>
#       presente | ausente
#
#   repo_presence_detail <dir>
#       presente
#       ausente: ruta inexistente
#       ausente: ruta ocupada por algo que no es un repositorio git
#       ausente: la ruta no es la raíz de su propio repositorio
#       Las tres formas de ausencia colapsan a `ausente` en repo_presence; el
#       detalle existe para que el consumidor pueda nombrar el motivo en su
#       reporte (contrato de reporte de estado del workspace, regla 8).
#
#   repo_branch <dir>
#       <nombre de rama> | HEAD desprendido | (cadena vacía)
#
#   repo_cleanliness <dir>
#       limpio | con cambios sin guardar | vacío | (cadena vacía)
#       Vocabulario cerrado de la columna Limpieza del contrato de reporte.
#
#   repo_upstream_status <dir>
#       al día | adelantado | atrasado | divergente | sin commits | desconocido
#       Vocabulario cerrado de la columna Respecto del remoto.
#
#   repo_upstream_ref <dir>
#       <upstream configurado> | (cadena vacía)
#       Auxiliar: distingue "sin upstream configurado" de "no se pudo consultar",
#       que repo_upstream_status colapsa a `desconocido`. Lo necesita el verbo
#       pull para reportar `saltado (sin upstream)` (hallazgo medido en el
#       workspace de origen).
#
#   repo_change_kind <dir>
#       sin cambios | solo sin seguimiento | con cambios versionados | (cadena vacía)
#       Auxiliar de decisión, NO vocabulario de reporte: no se escribe en la
#       columna Limpieza. Lo consume el verbo pull, que salta por defecto cuando
#       hay archivos sin seguimiento y solo avanza con --allow-untracked.
#
#   repo_remote_refs <dir>
#       Una línea "<refname> <objectname>" por referencia bajo refs/remotes, en
#       el orden estable de for-each-ref; nada si no se pudo leer. Sirve para
#       comparar antes y después de un fetch, que es la única forma conforme de
#       saber si trajo algo: el acuse del comando no lo dice (medido en el
#       workspace de origen).
#
# Los valores llevan acento porque son los del contrato de reporte de estado del
# workspace, que es su autoridad (diseño original en el workspace de origen;
# procedencia de esta portación: specs/002-portar-agentes/). Se escriben
# literalmente, sin normalizar.
#
# La cadena vacía NO es un valor del vocabulario: significa "no aplicable o no
# legible" —repositorio ausente, o git que falló al consultarlo—. El consumidor
# la renderiza como celda vacía y nombra el motivo en la columna Resultado.
#
# -----------------------------------------------------------------------------
# Reglas que esta biblioteca sostiene
# -----------------------------------------------------------------------------
#
#   1. Ninguna función aborta la corrida del script que la consume. Toda
#      invocación de git que pueda fallar va con condicional explícito y captura
#      del código. El patrón `comando && printf` bajo `set -eu` mata la corrida
#      entera: medido en el workspace de origen, el primer repositorio de tres
#      terminaba la ejecución sin reportar los otros dos.
#   2. Ninguna función llama a `exit`. Los códigos de salida los fija el script
#      que consume la biblioteca, según la convención de la skill (0 corrida
#      limpia, 1 error de precondición sin ejecutar nada, 2 corrida completa con
#      al menos un repositorio en error).
#   3. Toda lectura sale del repositorio real, nunca del acuse de un comando
#      previo (contrato de reporte, regla 1).
#   4. La rama se lee con `git symbolic-ref --short HEAD`, NUNCA con
#      `git rev-parse --abbrev-ref HEAD`, que falla con código 128 sobre un
#      repositorio sin commits. Medido en el workspace de origen. La prohibición
#      es sobre esa forma de leer la rama; `rev-parse` se usa para otras
#      consultas donde ya se verificó que HEAD resuelve.
#   5. Un repositorio sin commits es `vacío`, no `limpio`: `git status
#      --porcelain` devuelve vacío con código 0 sobre un clon sin commits, o sea
#      se ve idéntico a uno sano. Caso observado en el workspace de origen:
#      varios repositorios del catálogo estaban en ese estado y figuraban
#      `Activo` en la fuente.
#
# -----------------------------------------------------------------------------
# Neutralización de la configuración del repositorio gestionado, y su límite
# -----------------------------------------------------------------------------
#
# repo_git invoca git así:
#
#     git -c core.fsmonitor= -c core.hooksPath=/dev/null -C "$dir" "$@"
#
# Motivo: git ejecuta configuración del propio repositorio gestionado. Hooks en
# `pull`, `reference-transaction` en `fetch`, y `core.fsmonitor` en el mismo
# `git status --porcelain` que alimenta cada fila del reporte, incluido
# `--dry-run`. Neutralizar hooks y fsmonitor es lo que se puede neutralizar sin
# romper la operación.
#
# LA MITIGACIÓN ES PARCIAL, y va dicha acá para que nadie la lea como blindaje.
# No cubre todo lo que la configuración de un repositorio puede hacer ejecutar a
# git: `credential.helper`, `core.pager`, `diff.*.textconv`, `filter.*.clean` y
# `filter.*.smudge` siguen fuera. Las tres restricciones centrales de la skill
# —no tocar código de producto, no leer secretos, no publicar sin confirmación—
# siguen siendo garantías de PROCESO, no de permisos, tal como se declaró en el
# diseño original de la skill. Este envoltorio no endurece ninguna.
#
# Modelo de amenaza, dicho con precisión: `git clone` no trae hooks ni
# configuración del remoto, así que esto exige que algo ya haya escrito en el
# `.git/` local. Dicho eso, el workspace de origen de esta skill fue objetivo de
# un ataque de supply chain que persistía precisamente en `.git/`; un abanico
# sancionado sobre varios repositorios es su multiplicador.
#
# -----------------------------------------------------------------------------
# Convenciones internas
# -----------------------------------------------------------------------------
#
# POSIX sh no tiene `local`, de modo que toda variable interna lleva un prefijo
# propio por función (_rg_, _rp_, _rb_, _rc_, _ru_, _rk_, _rr_) para que una
# función que llama a otra no le pise las suyas. Toda variable va entre comillas.

set -eu

# -----------------------------------------------------------------------------
# Envoltorio de git
# -----------------------------------------------------------------------------

repo_git() {
    # Sin ruta no hay repositorio al que preguntarle. Se avisa y se devuelve un
    # código de fallo, que todo consumidor captura; nunca se aborta la corrida.
    if [ "$#" -lt 2 ]; then
        printf 'ERROR: repo_git requiere la ruta del repositorio y al menos un argumento de git.\n' >&2
        return 1
    fi
    _rg_dir="$1"
    shift
    git -c core.fsmonitor= -c core.hooksPath=/dev/null -C "$_rg_dir" "$@"
}

# Solo como condición. No imprime.
repo_git_available() {
    command -v git >/dev/null 2>&1
}

# Uso interno. Solo como condición: devuelve 1 y avisa por stderr cuando falta la
# ruta. Un argumento ausente es error de programación, no estado del repositorio,
# y aun así no se aborta la corrida de quien consume.
_repo_arg_ok() {
    if [ -z "${2:-}" ]; then
        printf 'ERROR: %s requiere la ruta del repositorio.\n' "${1:-lib-repo-state.sh}" >&2
        return 1
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Presencia
# -----------------------------------------------------------------------------

# Devuelve el motivo, no solo el veredicto. Una ruta que existe pero no es un
# repositorio git es ausente, y ese caso se distingue porque el contrato de
# reporte (regla 8) obliga a detenerse antes de crear nada sobre ella.
repo_presence_detail() {
    if ! _repo_arg_ok repo_presence_detail "${1:-}"; then
        printf '%s\n' 'ausente: ruta inexistente'
        return 0
    fi
    _rp_dir="$1"

    if [ ! -d "$_rp_dir" ]; then
        printf '%s\n' 'ausente: ruta inexistente'
        return 0
    fi

    _rp_top=''
    _rp_top=$(repo_git "$_rp_dir" rev-parse --show-toplevel 2>/dev/null) || _rp_top=''
    if [ -z "$_rp_top" ]; then
        printf '%s\n' 'ausente: ruta ocupada por algo que no es un repositorio git'
        return 0
    fi

    # `rev-parse` responde también desde un subdirectorio de otro repositorio, de
    # modo que la ruta tiene que ser la raíz de su propio árbol para contar como
    # el clon esperado. La regla 7 del contrato deriva el directorio del nombre
    # del repositorio, sin transformarlo.
    _rp_here=''
    _rp_here=$(cd "$_rp_dir" 2>/dev/null && pwd -P) || _rp_here=''
    _rp_there=''
    _rp_there=$(cd "$_rp_top" 2>/dev/null && pwd -P) || _rp_there=''

    if [ -n "$_rp_here" ] && [ "$_rp_here" = "$_rp_there" ]; then
        printf '%s\n' 'presente'
    else
        printf '%s\n' 'ausente: la ruta no es la raíz de su propio repositorio'
    fi
    return 0
}

repo_presence() {
    case "$(repo_presence_detail "${1:-}")" in
        presente) printf '%s\n' 'presente' ;;
        *)        printf '%s\n' 'ausente' ;;
    esac
    return 0
}

# -----------------------------------------------------------------------------
# Rama
# -----------------------------------------------------------------------------

repo_branch() {
    if ! _repo_arg_ok repo_branch "${1:-}"; then
        printf '%s\n' ''
        return 0
    fi
    _rb_dir="$1"

    if [ "$(repo_presence "$_rb_dir")" != 'presente' ]; then
        printf '%s\n' ''
        return 0
    fi

    # `symbolic-ref --short HEAD` responde correctamente sobre un repositorio sin
    # commits, donde `rev-parse --abbrev-ref HEAD` falla con código 128.
    _rb_out=''
    _rb_out=$(repo_git "$_rb_dir" symbolic-ref --short HEAD 2>/dev/null) || _rb_out=''
    if [ -n "$_rb_out" ]; then
        printf '%s\n' "$_rb_out"
        return 0
    fi

    # Sin salida, HEAD no apunta a una rama. Si además resuelve a un commit, es
    # HEAD desprendido; si no resuelve, no hay dato que dar.
    _rb_rc=0
    repo_git "$_rb_dir" rev-parse --verify --quiet HEAD >/dev/null 2>&1 || _rb_rc=$?
    if [ "$_rb_rc" -eq 0 ]; then
        printf '%s\n' 'HEAD desprendido'
    else
        printf '%s\n' ''
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Limpieza
# -----------------------------------------------------------------------------

repo_cleanliness() {
    if ! _repo_arg_ok repo_cleanliness "${1:-}"; then
        printf '%s\n' ''
        return 0
    fi
    _rc_dir="$1"

    if [ "$(repo_presence "$_rc_dir")" != 'presente' ]; then
        printf '%s\n' ''
        return 0
    fi

    # El repositorio vacío se detecta antes que nada: `status --porcelain` no lo
    # distingue de uno sano.
    _rc_rc=0
    repo_git "$_rc_dir" rev-parse --verify --quiet HEAD >/dev/null 2>&1 || _rc_rc=$?
    if [ "$_rc_rc" -ne 0 ]; then
        printf '%s\n' 'vacío'
        return 0
    fi

    _rc_out=''
    _rc_rc=0
    _rc_out=$(repo_git "$_rc_dir" status --porcelain 2>/dev/null) || _rc_rc=$?
    if [ "$_rc_rc" -ne 0 ]; then
        printf '%s\n' ''
        return 0
    fi

    if [ -n "$_rc_out" ]; then
        printf '%s\n' 'con cambios sin guardar'
    else
        printf '%s\n' 'limpio'
    fi
    return 0
}

# Auxiliar de decisión para el verbo pull. No se escribe en el reporte.
repo_change_kind() {
    if ! _repo_arg_ok repo_change_kind "${1:-}"; then
        printf '%s\n' ''
        return 0
    fi
    _rk_dir="$1"

    if [ "$(repo_presence "$_rk_dir")" != 'presente' ]; then
        printf '%s\n' ''
        return 0
    fi

    _rk_out=''
    _rk_rc=0
    _rk_out=$(repo_git "$_rk_dir" status --porcelain 2>/dev/null) || _rk_rc=$?
    if [ "$_rk_rc" -ne 0 ]; then
        printf '%s\n' ''
        return 0
    fi
    if [ -z "$_rk_out" ]; then
        printf '%s\n' 'sin cambios'
        return 0
    fi

    # Las líneas `??` son archivos sin seguimiento; cualquier otra marca un
    # cambio sobre algo versionado, que es lo que obliga a saltar el repositorio.
    _rk_versionados=0
    _rk_line=''
    while IFS= read -r _rk_line; do
        [ -n "$_rk_line" ] || continue
        case "$_rk_line" in
            '??'*) : ;;
            *)     _rk_versionados=1 ;;
        esac
    done <<_FIN_PORCELAIN
$_rk_out
_FIN_PORCELAIN

    if [ "$_rk_versionados" -eq 1 ]; then
        printf '%s\n' 'con cambios versionados'
    else
        printf '%s\n' 'solo sin seguimiento'
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Situación respecto del remoto
# -----------------------------------------------------------------------------

# Devuelve el upstream configurado, o cadena vacía si no hay o no se pudo leer.
repo_upstream_ref() {
    if ! _repo_arg_ok repo_upstream_ref "${1:-}"; then
        printf '%s\n' ''
        return 0
    fi
    _ru_ref_dir="$1"

    if [ "$(repo_presence "$_ru_ref_dir")" != 'presente' ]; then
        printf '%s\n' ''
        return 0
    fi

    _ru_ref_out=''
    _ru_ref_out=$(repo_git "$_ru_ref_dir" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) || _ru_ref_out=''
    printf '%s\n' "$_ru_ref_out"
    return 0
}

repo_upstream_status() {
    if ! _repo_arg_ok repo_upstream_status "${1:-}"; then
        printf '%s\n' 'desconocido'
        return 0
    fi
    _ru_dir="$1"

    if [ "$(repo_presence "$_ru_dir")" != 'presente' ]; then
        printf '%s\n' 'desconocido'
        return 0
    fi

    _ru_rc=0
    repo_git "$_ru_dir" rev-parse --verify --quiet HEAD >/dev/null 2>&1 || _ru_rc=$?
    if [ "$_ru_rc" -ne 0 ]; then
        printf '%s\n' 'sin commits'
        return 0
    fi

    # Sin upstream configurado no hay contra qué comparar. El consumidor que
    # necesite separar este caso de un fallo de consulta usa repo_upstream_ref.
    _ru_up=''
    _ru_up=$(repo_git "$_ru_dir" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) || _ru_up=''
    if [ -z "$_ru_up" ]; then
        printf '%s\n' 'desconocido'
        return 0
    fi

    # `--left-right --count` imprime "<solo en HEAD> <solo en upstream>", es
    # decir adelanto y atraso en una sola lectura del repositorio.
    _ru_counts=''
    _ru_counts=$(repo_git "$_ru_dir" rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null) || _ru_counts=''
    if [ -z "$_ru_counts" ]; then
        printf '%s\n' 'desconocido'
        return 0
    fi

    _ru_ahead=''
    _ru_behind=''
    read -r _ru_ahead _ru_behind <<_FIN_COUNTS
$_ru_counts
_FIN_COUNTS

    case "${_ru_ahead:-}" in
        ''|*[!0-9]*) printf '%s\n' 'desconocido'; return 0 ;;
    esac
    case "${_ru_behind:-}" in
        ''|*[!0-9]*) printf '%s\n' 'desconocido'; return 0 ;;
    esac

    if [ "$_ru_ahead" -gt 0 ] && [ "$_ru_behind" -gt 0 ]; then
        printf '%s\n' 'divergente'
    elif [ "$_ru_ahead" -gt 0 ]; then
        printf '%s\n' 'adelantado'
    elif [ "$_ru_behind" -gt 0 ]; then
        printf '%s\n' 'atrasado'
    else
        printf '%s\n' 'al día'
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Referencias remotas, para contrastar antes y después de un fetch
# -----------------------------------------------------------------------------

repo_remote_refs() {
    if ! _repo_arg_ok repo_remote_refs "${1:-}"; then
        return 0
    fi
    _rr_dir="$1"

    if [ "$(repo_presence "$_rr_dir")" != 'presente' ]; then
        return 0
    fi

    _rr_out=''
    _rr_out=$(repo_git "$_rr_dir" for-each-ref --format='%(refname) %(objectname)' refs/remotes 2>/dev/null) || _rr_out=''
    if [ -n "$_rr_out" ]; then
        printf '%s\n' "$_rr_out"
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Ejecución directa
# -----------------------------------------------------------------------------
#
# POSIX sh no tiene forma de saber si un archivo fue incluido con ".", así que se
# compara el nombre con que se invocó el proceso. Al incluirla, "$0" es el script
# que la consume y este bloque no se activa.

case "${0##*/}" in
    lib-repo-state.sh)
        printf '%s\n' 'lib-repo-state.sh es una biblioteca de la skill development-repositories.'
        printf '%s\n' 'No se ejecuta sola: se incluye con "." desde los scripts de la skill.'
        printf '%s\n' ''
        printf '%s\n' '    . "$(dirname "$0")/lib-repo-state.sh"'
        printf '%s\n' ''
        printf '%s\n' 'Expone: repo_git, repo_git_available, repo_presence, repo_presence_detail,'
        printf '%s\n' '        repo_branch, repo_cleanliness, repo_change_kind, repo_upstream_ref,'
        printf '%s\n' '        repo_upstream_status, repo_remote_refs.'
        exit 0
        ;;
esac
