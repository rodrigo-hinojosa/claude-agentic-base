#!/bin/sh
# run-across-repos.sh — ejecutor de comandos sobre el conjunto de repositorios del
# catálogo de la skill development-repositories.
# Procedencia: réplica declarada de la portación, 07-09-2026 (feature
# 002-portar-agentes); la traza vive en specs/002-portar-agentes/.
#
# Diseño y sus motivos: relevados y medidos en el workspace de origen; las
# mediciones que sostienen cada decisión se conservan en los comentarios de este
# archivo. Forma del reporte: contrato de reporte de estado de la skill (el
# documento del contrato está `Pendiente de portar` a esta base; sus reglas
# rigen tal como quedan enunciadas acá y en layout.md).
# Códigos de salida, vocabulario y disposición de directorios: layout.md de la skill.
#
# -----------------------------------------------------------------------------
# Los cinco verbos son un conjunto cerrado, y el motivo está medido
# -----------------------------------------------------------------------------
#
# status, fetch, pull, branch, log. El `argv` que llega a git es fijo por verbo:
# ninguna palabra del usuario se convierte en bandera de git. Un ejecutor de paso
# libre no puede clasificar lo que ejecuta, de modo que no puede aplicar el gate
# por operación que el diseño de la skill exige, y produce por construcción un
# reporte fuera del vocabulario cerrado del contrato (decisión medida en el
# workspace de origen).
#
# -----------------------------------------------------------------------------
# `checkout` no existe acá, y no se agrega
# -----------------------------------------------------------------------------
#
# La primera versión del diseño lo incluía con la mitigación "rechazar lo que
# empiece con -". Insuficiente, medido sobre git 2.53.0: `--branch a.txt` (una
# ruta, no una rama) y `--branch .` descartan trabajo sin guardar y salen con
# código 0, de modo que el reporte diría "rama cambiada" sobre un borrado,
# multiplicado por el conjunto entero. La forma segura existe —`git checkout
# "$rama" --`, más verificación previa contra refs/heads/, más rechazo de `-`,
# las tres juntas— pero el verbo no es lo que se pidió y su superficie de daño es
# la mayor del conjunto. Se retiró por decisión registrada, no por olvido.
#
# -----------------------------------------------------------------------------
# `--prune` no se usa, y tampoco es un olvido
# -----------------------------------------------------------------------------
#
# La justificación para usarlo era que "otro fetch recompone" las referencias
# remotas borradas. Falso, medido: cuando el remoto ya borró la rama —el caso
# normal tras un merge con squash— ningún fetch posterior las repone. Es pérdida
# de información sin retorno, y choca con la regla 5 del contrato de reporte, que
# prohíbe que una operación de esta skill destruya algo. Quien lea este script
# buscando por qué las referencias remotas viejas se acumulan: se acumulan a
# propósito, y limpiarlas es una decisión de una persona sobre un repositorio
# concreto, no un efecto colateral de un abanico sobre el conjunto.
#
# -----------------------------------------------------------------------------
# Lo que este script NO endurece
# -----------------------------------------------------------------------------
#
# Invoca git a través de repo_git, que neutraliza hooks y core.fsmonitor. La
# mitigación es parcial y está descrita en lib-repo-state.sh: credential.helper,
# core.pager, diff.*.textconv y filter.* siguen fuera. Las tres restricciones
# centrales de la skill —no tocar código de producto, no leer secretos, no
# publicar sin confirmación— siguen siendo garantías de proceso, tal como quedó
# declarado en el diseño de origen de la skill. Este script no convierte ninguna
# en mecanismo.
#
# Ninguna operación borra clones, descarta cambios ni reescribe historia
# publicada. Nada hace push ni abre pull request: publicar hacia el remoto exige
# confirmación explícita por operación y nunca es efecto colateral de
# actualizar.

set -eu

# -----------------------------------------------------------------------------
# Constantes
# -----------------------------------------------------------------------------

# El nombre del workspace y la ruta del catálogo por defecto viven en
# lib-repo-set.sh, junto al parseo y a la resolución que los usan.

# Número FIJO de commits del verbo log. No se toma del usuario: cualquier valor
# que llegue desde afuera es una palabra que termina en el argv de git, y el
# diseño de esta skill lo prohíbe (decisión medida en el workspace de origen).
LOG_COMMITS=5

# Formato FIJO del verbo log. Misma razón que la constante anterior.
LOG_FORMATO='%h %ad %s'

# -----------------------------------------------------------------------------
# Estado global
# -----------------------------------------------------------------------------

VERBO=''
CATALOGO_OPCION=''
RAIZ_OPCION=''
DRY_RUN=0
ALLOW_UNTRACKED=0
SOLO=''

# Alias locales de lo que fija lib-repo-set.sh. Se copian una vez, después de
# resolver, y solo para que el reporte los nombre; la autoridad de cada valor es
# la biblioteca.
CATALOGO=''
CATALOGO_ORIGEN=''
RAIZ=''
RAIZ_ORIGEN=''
WORKSPACE=''
SELECCION=''
TOTAL_FILAS=0
ANCHO_REPO=11

# Fijadas por las funciones operar_*.
RESULTADO=''
DETALLE=''
OPERADO=0

# -----------------------------------------------------------------------------
# Salida
# -----------------------------------------------------------------------------

# Diagnósticos propios de este script, antes de que las bibliotecas estén
# cargadas o para lo que solo a él le compete. Los avisos del parseo del catálogo
# los emite lib-repo-set.sh con `repos_avisar`, que es donde vive ese parseo:
# esta función quedó sin llamadas al mover el parseo y se retiró en vez de
# dejarla como superficie sin uso.
error() {
    printf 'ERROR: %s\n' "$1" >&2
}

uso() {
    cat <<'FIN_USO'
run-across-repos.sh — ejecuta un comando acotado sobre los repositorios del catálogo.

USO
    run-across-repos.sh <verbo> [opciones]
    run-across-repos.sh --help

VERBOS (conjunto cerrado; el argv que llega a git es fijo por verbo)
    status    Lee presencia, rama, limpieza y situación respecto del remoto.
              No ejecuta ninguna operación mutante.
    fetch     Trae referencias remotas de todos los remotos. NO usa --prune.
              El resultado se reporta por RELECTURA de refs/remotes, no por el
              acuse del comando.
    pull      Nunca se ejecuta como `git pull`. Se descompone en fetch,
              evaluación del estado y `merge --ff-only` contra el upstream.
    branch    Resuelve la rama con `git symbolic-ref --short HEAD`, que responde
              sobre un repositorio sin commits donde `rev-parse --abbrev-ref`
              falla con código 128.
    log       Imprime los últimos commits con un número y un formato FIJOS,
              declarados como constantes en el script.

    Ningún verbo acepta parámetros del usuario que lleguen a git como bandera.
    `checkout` no existe y no se agrega: el motivo, con su medición, está en el
    encabezado de este archivo.

OPCIONES
    --only <nombre>     Restringe el recorrido a ese repositorio. Repetible.
                        La coincidencia es EXACTA contra el catálogo; un nombre
                        que no exista es error de uso (código 1), nunca un
                        recorrido vacío con éxito.
    --allow-untracked   En el verbo pull, intenta el avance rápido aunque haya
                        archivos sin seguimiento. Por defecto se salta.
    --dry-run           Imprime lo que haría y no ejecuta ninguna operación
                        mutante. Ver la advertencia de abajo.
    --catalog <ruta>    Catálogo a usar. Precede a REPOS_CATALOG.
    --root <ruta>       Raíz de clones. Precede a REPOS_ROOT.
    --help, -h          Imprime este texto y sale 0.

VARIABLES DE ENTORNO
    REPOS_ROOT          Raíz de clones. Por defecto, el directorio padre del
                        workspace. La raíz resuelta se imprime en el encabezado
                        del reporte, como ruta y nunca como nombre de variable.
    REPOS_CATALOG       Catálogo a usar. Por defecto, repositories.md de la skill.
                        Existe para poder probar los scripts contra el catálogo
                        de prueba examples/test-catalog.md sin tocar el real.

--dry-run NO ES DEL TODO INOCUO, Y HAY QUE DECIRLO
    Suprime fetch y merge, pero las columnas de estado se siguen leyendo con
    `git status`, y git ejecuta configuración del propio repositorio al hacerlo
    —core.fsmonitor entre otras—. repo_git neutraliza hooks y fsmonitor; el resto
    de la configuración local sigue fuera de esa mitigación. Un --dry-run sobre
    un repositorio cuyo .git/ es sospechoso no es una inspección pasiva.

CÓDIGOS DE SALIDA
    0   La corrida completó y ningún repositorio quedó en error.
    1   Error de uso o de precondición: NADA se ejecutó.
    2   La corrida completó y al menos un repositorio terminó en `error: <motivo>`.

    Un repositorio ausente se reporta como `error: <motivo>` y lleva la corrida a
    código 2. Es deliberado: el vocabulario de la columna Resultado es cerrado y
    no tiene un valor para la ausencia, y un espacio de trabajo incompleto no es
    una corrida limpia. Clonar los ausentes es trabajo de prepare-workspace.sh.

    Los errores van a stderr con el prefijo `ERROR: `; los avisos, con `AVISO: `,
    y no alteran el código de salida.
FIN_USO
}

# -----------------------------------------------------------------------------
# Bibliotecas compartidas
# -----------------------------------------------------------------------------
#
# lib-repo-state.sh lee el estado de UN repositorio. lib-repo-set.sh resuelve el
# CONJUNTO: la raíz de clones, el catálogo, su parseo y la selección. Lo segundo
# nació dentro de este script y se movió allá cuando prepare-workspace.sh pasó a
# necesitar exactamente lo mismo; dos parseos del mismo catálogo divergen en
# silencio (.claude/rules/09-punteros-y-replicas.md).

DIR_SCRIPT=''
DIR_SCRIPT=$(cd "$(dirname "$0")" 2>/dev/null && pwd -P) || DIR_SCRIPT=''
if [ -z "$DIR_SCRIPT" ]; then
    error 'no se pudo resolver el directorio de este script.'
    exit 1
fi

for _lib in lib-repo-state.sh lib-repo-set.sh; do
    if [ ! -r "$DIR_SCRIPT/$_lib" ]; then
        error "no se encuentra la biblioteca $DIR_SCRIPT/$_lib."
        exit 1
    fi
done

# shellcheck source=lib-repo-state.sh
. "$DIR_SCRIPT/lib-repo-state.sh"
# shellcheck source=lib-repo-set.sh
. "$DIR_SCRIPT/lib-repo-set.sh"

# -----------------------------------------------------------------------------
# Parseo de argumentos
# -----------------------------------------------------------------------------

# --help en cualquier posición gana sobre todo lo demás: pedir ayuda nunca se
# confunde con equivocarse al invocar.
for _arg in "$@"; do
    case "$_arg" in
        --help|-h) uso; exit 0 ;;
    esac
done

if [ "$#" -lt 1 ]; then
    error 'falta el verbo.'
    uso >&2
    exit 1
fi

VERBO="$1"
shift

case "$VERBO" in
    status|fetch|pull|branch|log) : ;;
    *)
        error "verbo desconocido: $VERBO. Los verbos son status, fetch, pull, branch y log."
        exit 1
        ;;
esac

while [ "$#" -gt 0 ]; do
    case "$1" in
        --only)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error '--only requiere el nombre de un repositorio.'
                exit 1
            fi
            SOLO="${SOLO}$2
"
            shift 2
            ;;
        --catalog)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error '--catalog requiere una ruta.'
                exit 1
            fi
            CATALOGO_OPCION="$2"
            shift 2
            ;;
        --root)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error '--root requiere una ruta.'
                exit 1
            fi
            RAIZ_OPCION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --allow-untracked)
            ALLOW_UNTRACKED=1
            shift
            ;;
        *)
            error "opción desconocida: $1."
            exit 1
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Precondiciones globales — todas antes de tocar nada
# -----------------------------------------------------------------------------

# 1. git presente.
if ! repo_git_available; then
    error 'git no está disponible en el PATH.'
    exit 1
fi

# 2 a 6. Workspace, raíz de clones, catálogo, parseo y selección. Los ejecuta
#    lib-repo-set.sh, que imprime el diagnóstico con el prefijo que corresponda y
#    devuelve distinto de cero cuando la precondición no se cumple. Acá solo se
#    sale: el orden de las comprobaciones y el texto de cada mensaje son de la
#    biblioteca, para que este script y prepare-workspace.sh no los digan de dos
#    maneras distintas.

repos_resolve_workspace "$DIR_SCRIPT" || exit 1
repos_resolve_root "$RAIZ_OPCION" || exit 1
repos_resolve_catalog "$CATALOGO_OPCION" "$DIR_SCRIPT" || exit 1
repos_parse_catalog || exit 1
repos_select "$SOLO" || exit 1

WORKSPACE="$REPOS_WORKSPACE"
RAIZ="$REPOS_ROOT"
RAIZ_ORIGEN="$REPOS_ROOT_ORIGEN"
CATALOGO="$REPOS_CATALOG"
CATALOGO_ORIGEN="$REPOS_CATALOG_ORIGEN"
TOTAL_FILAS="$REPOS_TOTAL_FILAS"
SELECCION="$REPOS_SELECCION"
ANCHO_REPO="$REPOS_ANCHO"
_seleccionados="$REPOS_SELECCIONADOS"

# -----------------------------------------------------------------------------
# Operaciones por verbo
# -----------------------------------------------------------------------------
#
# Todas fijan RESULTADO y, cuando corresponde, DETALLE y OPERADO. Ninguna aborta
# la corrida ni devuelve un código distinto de 0: el error se señala en el texto
# de RESULTADO, que el bucle clasifica. El patrón `comando && printf` bajo modo
# estricto mata la corrida entera —medido en el workspace de origen: el primer
# repositorio de tres terminaba la ejecución sin reportar los otros dos—, así
# que toda invocación de git va con condicional explícito y captura del código
# de salida.

operar_status() {
    RESULTADO='sin cambios'
    return 0
}

operar_branch() {
    _ob_dir="$1"
    _ob_rama=$(repo_branch "$_ob_dir")
    if [ -n "$_ob_rama" ]; then
        DETALLE="$_ob_rama"
    else
        DETALLE='sin rama resoluble'
    fi
    RESULTADO='sin cambios'
    return 0
}

operar_log() {
    _ol_dir="$1"
    # --no-pager es una mitigación menor sobre core.pager, que repo_git no
    # neutraliza. La salida se captura, de modo que el pager no se dispararía de
    # todos modos; se pasa igual para no depender de esa circunstancia.
    _ol_out=''
    _ol_rc=0
    _ol_out=$(repo_git "$_ol_dir" --no-pager log -n "$LOG_COMMITS" --date=short --format="$LOG_FORMATO" 2>/dev/null) || _ol_rc=$?
    if [ "$_ol_rc" -ne 0 ] || [ -z "$_ol_out" ]; then
        DETALLE='sin commits, o historial no legible'
    else
        DETALLE="$_ol_out"
    fi
    RESULTADO='sin cambios'
    return 0
}

# fetch se reporta por RELECTURA de refs/remotes, comparando antes y después.
# El acuse del comando no distingue un fetch que trajo algo de uno que no
# trajo nada, y esa es la regla 1 del contrato de reporte, la más dura.
#
# Límite declarado de esa comparación: refs/remotes no incluye refs/tags, de modo
# que un fetch que solo trajo etiquetas se lee como `sin cambios`.
# -----------------------------------------------------------------------------
# guardia_remoto <repo> <dir>
# -----------------------------------------------------------------------------
#
# Comprueba que el clon que ocupa la ruta derivada sea el del catálogo, ANTES de
# toda operación mutante. Devuelve 0 si puede operarse, 1 si no, y en ese caso
# deja fijado RESULTADO.
#
# La asimetría que corrige era un defecto real, observado en el workspace de
# origen. `prepare-workspace.sh` comprobaba el remoto antes de clonar; `fetch` y
# `pull` no comprobaban nada, de modo que la operación que MUTA el árbol de
# trabajo era la única sin la comprobación que la regla 8 del contrato exige.
# Reproducido sobre repositorios efímeros: un clon de otro origen recibió
# `fetch` y `merge --ff-only`, su HEAD avanzó con un commit ajeno, y la fila del
# reporte dijo `actualizado` sin ninguna señal.
#
# No es un caso de borde. La raíz de clones es un directorio compartido que la
# skill no posee: es el directorio padre del workspace, y esa pérdida está
# declarada en layout.md §2 de la skill como el precio de poner los clones como
# hermanos.
#
# **Nunca imprime la URL hallada.** Un remoto puede traer credenciales embebidas.
guardia_remoto() {
    _gr_repo="$1"
    _gr_dir="$2"

    _gr_link=$(repos_link_of "$_gr_repo")

    # Sin enlace utilizable no hay contra qué comparar. No se muta lo que no se
    # puede verificar: es la misma postura que `prepare-workspace.sh` toma ante
    # un enlace ilegible, y la alternativa sería operar a ciegas.
    if ! repos_link_usable "$_gr_link"; then
        RESULTADO='error: el catálogo no trae un enlace utilizable: no se pudo comprobar el remoto'
        return 1
    fi

    case "$(repos_veredicto_remoto "$_gr_dir" "$_gr_link")" in
        corresponde)
            return 0
            ;;
        'sin remotos')
            RESULTADO='error: el clon no tiene remotos configurados'
            return 1
            ;;
        ilegible)
            RESULTADO='error: no se pudo leer la configuración de remotos del clon'
            return 1
            ;;
        *)
            RESULTADO='error: el remoto del clon no corresponde al del catálogo'
            return 1
            ;;
    esac
}

# Los tres verbos de solo lectura NO se bloquean por esta comprobación, y la
# decisión va escrita en vez de quedar implícita: `status`, `branch` y `log` no
# tocan el árbol de trabajo ni la red, de modo que leer un repositorio que no
# corresponde no puede dañar nada. Sí lo AVISAN, porque un reporte que describa
# un repositorio ajeno como si fuera el del catálogo sería un dato falso con
# forma de dato correcto.
aviso_remoto_lectura() {
    _arl_repo="$1"
    _arl_dir="$2"

    _arl_link=$(repos_link_of "$_arl_repo")
    repos_link_usable "$_arl_link" || return 0

    case "$(repos_veredicto_remoto "$_arl_dir" "$_arl_link")" in
        corresponde|ilegible) : ;;
        *) repos_avisar "el clon de $_arl_repo no corresponde al remoto del catálogo; la fila describe el repositorio que ocupa la ruta" ;;
    esac
    return 0
}

operar_fetch() {
    _of_dir="$1"

    if [ "$DRY_RUN" -eq 1 ]; then
        RESULTADO='sin cambios'
        DETALLE='ejecutaría: git fetch --all (sin --prune)'
        return 0
    fi

    _of_antes=''
    _of_antes=$(repo_remote_refs "$_of_dir") || _of_antes=''

    OPERADO=1
    _of_rc=0
    repo_git "$_of_dir" fetch --all >/dev/null 2>&1 || _of_rc=$?
    if [ "$_of_rc" -ne 0 ]; then
        RESULTADO="error: git fetch terminó con código $_of_rc"
        return 0
    fi

    _of_despues=''
    _of_despues=$(repo_remote_refs "$_of_dir") || _of_despues=''

    if [ "$_of_antes" = "$_of_despues" ]; then
        RESULTADO='sin cambios'
    else
        RESULTADO='actualizado'
    fi
    return 0
}

# pull NUNCA se ejecuta como `git pull`. Se descompone en fetch, evaluación del
# estado y `merge --ff-only`. `git pull` mezcla dos operaciones de riesgo
# distinto y su comportamiento depende de configuración local (pull.rebase) que
# la skill no controla.
operar_pull() {
    _op_dir="$1"

    # 1. Cambios sin guardar sobre archivos versionados: no se intenta siquiera.
    #    Es una garantía central del diseño de la skill y la regla 2 del
    #    contrato de reporte.
    _op_kind=$(repo_change_kind "$_op_dir")
    case "$_op_kind" in
        'con cambios versionados')
            RESULTADO='saltado (cambios sin guardar)'
            return 0
            ;;
        'solo sin seguimiento')
            if [ "$ALLOW_UNTRACKED" -eq 0 ]; then
                RESULTADO='saltado (sin seguimiento)'
                return 0
            fi
            ;;
    esac

    # 2. Divergente ANTES de intentar nada. Un fetch no deshace una divergencia,
    #    y resolverla es merge o rebase, decisión de una persona.
    if [ "$(repo_upstream_status "$_op_dir")" = 'divergente' ]; then
        RESULTADO='saltado (divergente)'
        return 0
    fi

    # 3. Sin upstream configurado no hay contra qué avanzar. Un repositorio sin
    #    commits cae acá también, porque @{upstream} no resuelve.
    if [ -z "$(repo_upstream_ref "$_op_dir")" ]; then
        RESULTADO='saltado (sin upstream)'
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        RESULTADO='sin cambios'
        DETALLE='ejecutaría: git fetch --all y, si quedara atrasado, git merge --ff-only @{upstream}'
        return 0
    fi

    # 4. fetch, con relectura.
    _op_antes=''
    _op_antes=$(repo_remote_refs "$_op_dir") || _op_antes=''

    OPERADO=1
    _op_rc=0
    repo_git "$_op_dir" fetch --all >/dev/null 2>&1 || _op_rc=$?
    if [ "$_op_rc" -ne 0 ]; then
        RESULTADO="error: git fetch terminó con código $_op_rc"
        return 0
    fi

    # 5. Reevaluación después del fetch: la divergencia puede nacer acá, cuando
    #    el repositorio estaba adelantado y el remoto trajo commits propios.
    _op_estado=$(repo_upstream_status "$_op_dir")
    case "$_op_estado" in
        divergente)
            RESULTADO='saltado (divergente)'
            return 0
            ;;
        atrasado)
            : ;;
        *)
            # al día, adelantado, sin commits o desconocido: no hay avance rápido
            # que hacer, y forzar uno sería salirse de --ff-only.
            RESULTADO='sin cambios'
            return 0
            ;;
    esac

    # 6. Avance rápido, con el destino explícito. `git merge --ff-only` sin
    #    argumento resuelve el upstream por configuración; nombrarlo evita
    #    depender de esa resolución implícita.
    _op_rc=0
    repo_git "$_op_dir" merge --ff-only '@{upstream}' >/dev/null 2>&1 || _op_rc=$?
    if [ "$_op_rc" -ne 0 ]; then
        RESULTADO="error: git merge --ff-only terminó con código $_op_rc"
        return 0
    fi

    RESULTADO='actualizado'
    return 0
}

# -----------------------------------------------------------------------------
# Encabezado del reporte (contrato de reporte de estado de la skill)
# -----------------------------------------------------------------------------

case "$VERBO" in
    pull)   _operacion='pull (actualizar)' ;;
    status) _operacion='status (estado)' ;;
    *)      _operacion="$VERBO" ;;
esac

printf 'Espacio de trabajo — %s\n' "$(date '+%d-%m-%Y %H:%M')"
printf 'Raíz: %s   (fuente: %s)\n' "$RAIZ" "$RAIZ_ORIGEN"
printf 'Catálogo: %s repositorios | Operación: %s\n' "$TOTAL_FILAS" "$_operacion"
printf 'Archivo del catálogo: %s   (fuente: %s)\n' "$CATALOGO" "$CATALOGO_ORIGEN"
if [ -n "$SOLO" ]; then
    printf 'Selección: %s repositorios (--only)\n' "$_seleccionados"
fi
if [ "$DRY_RUN" -eq 1 ]; then
    printf '%s\n' 'Modo: --dry-run. No se ejecuta ninguna operación mutante; las columnas de estado sí se leen del repositorio.'
fi
printf '\n'

# -----------------------------------------------------------------------------
# Tabla por repositorio
# -----------------------------------------------------------------------------

printf '| '
repos_rellenar 'Repositorio' "$ANCHO_REPO"
printf ' | Presencia | Rama | Limpieza | Respecto del remoto | Resultado |\n'
printf '| '
repos_rellenar '---' "$ANCHO_REPO"
printf ' | --- | --- | --- | --- | --- |\n'

DISPONIBLES=0
OPERADOS=0
HUBO_ERROR=0
SALTADOS=''
ERRORES=''
DETALLES=''

while IFS= read -r REPO; do
    [ -n "$REPO" ] || continue

    DIR="$RAIZ/$REPO"
    RESULTADO=''
    DETALLE=''
    OPERADO=0
    PRESENCIA=''
    RAMA=''
    LIMPIEZA=''
    REMOTO=''

    # El workspace nunca es objetivo. Ya se excluyó por nombre al parsear; esta
    # segunda comprobación es sobre la RUTA resuelta, y cubre el caso de una raíz
    # apuntada de forma que el directorio derivado caiga sobre el workspace.
    _dir_real=''
    _dir_real=$(cd "$DIR" 2>/dev/null && pwd -P) || _dir_real=''
    if [ -n "$_dir_real" ] && [ "$_dir_real" = "$WORKSPACE" ]; then
        PRESENCIA='ausente'
        RESULTADO='error: la ruta derivada apunta al workspace'
    else
        _detalle_presencia=$(repo_presence_detail "$DIR")
        case "$_detalle_presencia" in
            presente)
                PRESENCIA='presente'
                DISPONIBLES=$((DISPONIBLES + 1))
                ;;
            'ausente: ruta inexistente')
                PRESENCIA='ausente'
                RESULTADO='error: no está clonado'
                ;;
            'ausente: ruta ocupada por algo que no es un repositorio git')
                PRESENCIA='ausente'
                RESULTADO='error: ruta ocupada por algo que no es un repositorio git'
                ;;
            *)
                PRESENCIA='ausente'
                RESULTADO='error: la ruta no es la raíz de su propio repositorio'
                ;;
        esac
    fi

    if [ "$PRESENCIA" = 'presente' ]; then
        case "$VERBO" in
            status) aviso_remoto_lectura "$REPO" "$DIR"; operar_status ;;
            branch) aviso_remoto_lectura "$REPO" "$DIR"; operar_branch "$DIR" ;;
            log)    aviso_remoto_lectura "$REPO" "$DIR"; operar_log "$DIR" ;;
            fetch)  if guardia_remoto "$REPO" "$DIR"; then operar_fetch "$DIR"; fi ;;
            pull)   if guardia_remoto "$REPO" "$DIR"; then operar_pull "$DIR"; fi ;;
        esac

        # Regla 1 del contrato: todo campo se lee del repositorio real DESPUÉS de
        # operar, nunca del acuse del comando.
        RAMA=$(repo_branch "$DIR")
        LIMPIEZA=$(repo_cleanliness "$DIR")
        REMOTO=$(repo_upstream_status "$DIR")

        # Un repositorio que la operación saltó NO cuenta como operado, aunque
        # una parte mutante haya corrido. Ocurre en pull: la divergencia puede
        # nacer del propio fetch, de modo que el fetch se ejecutó y el avance
        # rápido no. El contrato es explícito: un repositorio presente pero
        # saltado cuenta como disponible y no como operado.
        if [ "$OPERADO" -eq 1 ]; then
            case "$RESULTADO" in
                'saltado '*) : ;;
                *) OPERADOS=$((OPERADOS + 1)) ;;
            esac
        fi
    fi

    # Un repositorio ausente no tiene estado que leer, y la celda vacía NO
    # pertenece al vocabulario cerrado que el contrato fija para Limpieza y para
    # Respecto del remoto. Se escribe `no aplica`, que sí es un valor y se
    # distingue de "no se pudo leer". La columna Rama sí admite vacío: el
    # contrato no le fija vocabulario cerrado.
    [ -n "$LIMPIEZA" ] || LIMPIEZA='no aplica'
    [ -n "$REMOTO" ] || REMOTO='no aplica'

    printf '| '
    repos_rellenar "$REPO" "$ANCHO_REPO"
    printf ' | %s | %s | %s | %s | %s |\n' "$PRESENCIA" "$RAMA" "$LIMPIEZA" "$REMOTO" "$RESULTADO"

    case "$RESULTADO" in
        'error: '*)
            HUBO_ERROR=1
            ERRORES="${ERRORES}  ${REPO} (${RESULTADO#error: })
"
            ;;
        'saltado '*)
            SALTADOS="${SALTADOS}  ${REPO} ${RESULTADO#saltado }
"
            ;;
    esac

    if [ -n "$DETALLE" ]; then
        _detalle_indentado=$(printf '%s\n' "$DETALLE" | sed 's/^/      /')
        DETALLES="${DETALLES}  ${REPO}
${_detalle_indentado}
"
    fi
done <<_FIN_SELECCION
$SELECCION
_FIN_SELECCION

# -----------------------------------------------------------------------------
# Detalle de los verbos que producen salida propia
# -----------------------------------------------------------------------------

if [ -n "$DETALLES" ]; then
    printf '\n'
    case "$VERBO" in
        branch) printf '%s\n' 'Detalle — rama de cada repositorio:' ;;
        log)    printf 'Detalle — últimos %s commits de cada repositorio:\n' "$LOG_COMMITS" ;;
        *)      printf '%s\n' 'Detalle — qué se ejecutaría:' ;;
    esac
    printf '%s' "$DETALLES"
fi

# -----------------------------------------------------------------------------
# Cierre (contrato de reporte de estado de la skill)
# -----------------------------------------------------------------------------
#
# Las dos cifras son distintas y no se usan indistintamente: la primera cuenta
# PRESENCIA, la segunda OPERACIONES EJECUTADAS. Un repositorio presente pero
# saltado cuenta como disponible y no como operado.
#
# `operados` cuenta invocaciones mutantes realmente hechas y no saltadas, no
# invocaciones exitosas: un fetch que terminó en error se ejecutó igual, y su
# motivo está en la tabla y en la lista de errores.

printf '\n'
printf '%s de %s repositorios disponibles.\n' "$DISPONIBLES" "$_seleccionados"
printf '%s de %s repositorios operados.\n' "$OPERADOS" "$_seleccionados"

case "$VERBO" in
    status|branch|log)
        printf '%s\n' "El verbo $VERBO no ejecuta operaciones mutantes: la segunda cifra es 0 por construcción."
        # El límite de la columna se declara en el propio reporte y no solo en la
        # documentación: `status` no trae referencias, de modo que compara HEAD
        # contra el refs/remotes guardado en el clon. Un repositorio atrasado de
        # verdad figura `al día`, que es el resultado plausible en su forma pura.
        if [ "$VERBO" = 'status' ]; then
            printf '%s\n' 'La columna Respecto del remoto compara contra las referencias que el clon ya tiene guardadas.'
            printf '%s\n' 'Este verbo no trae referencias: un repositorio atrasado respecto del remoto real puede figurar como al día.'
            printf '%s\n' 'Para compararlo contra el remoto, corre antes el verbo fetch.'
        fi
        ;;
esac

if [ -n "$SALTADOS" ]; then
    printf '%s\n' 'Saltados:'
    printf '%s' "$SALTADOS"
else
    printf '%s\n' 'Saltados: ninguno'
fi

if [ -n "$ERRORES" ]; then
    printf '%s\n' 'Errores:'
    printf '%s' "$ERRORES"
else
    printf '%s\n' 'Errores: ninguno'
fi

if [ "$TOTAL_FILAS" -ne "$_seleccionados" ]; then
    printf '%s\n' "Recorrido acotado: el catálogo declara $TOTAL_FILAS filas y esta corrida cubrió $_seleccionados repositorios."
fi

# La regla 4 del contrato prohíbe declarar completo un conjunto donde algo falló.
if [ "$HUBO_ERROR" -eq 1 ]; then
    exit 2
fi

exit 0
