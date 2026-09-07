#!/bin/sh
# check-spec-pointers.sh — verifica que los punteros del índice de specs de
# desarrollo resuelvan en el clon local del repositorio que cada entrada indica.
# Skill: development-repositories. Procedencia: portación trazada en
# specs/002-portar-agentes/ (réplica declarada de la portación, 07-09-2026).
#
# Forma del índice: la fija el propio spec-index.md de la skill (§2, columnas;
# §3, reglas). Códigos de salida, vocabulario y disposición de directorios:
# layout.md de la skill.
#
# -----------------------------------------------------------------------------
# SU EJECUCIÓN ES MANUAL
# -----------------------------------------------------------------------------
#
# No hay integración continua ni gancho en este repositorio que lo dispare.
# Presentarlo como salvaguarda automática sería falso: protege solo cuando
# alguien lo corre. La declaración se repite en `--help` y en la salida del
# propio reporte, porque quien lee el reporte puede no haber leído este archivo.
#
# Es la misma forma de declaración que usa la regla 09 del repositorio
# (.claude/rules/09-punteros-y-replicas.md) para su propio procedimiento de
# verificación, y la que layout.md §8 fija para `check-workspace-dirs.sh`.
#
# -----------------------------------------------------------------------------
# Verifica contra la RAMA REGISTRADA, y no toca el árbol de trabajo
# -----------------------------------------------------------------------------
#
# La comprobación es `git cat-file -e refs/heads/<rama>:<ruta>`, que resuelve el
# objeto dentro del árbol de esa rama sin mirar el directorio de trabajo. No hay
# `checkout`, no hay cambio de rama y no se escribe nada.
#
# Por qué contra la rama registrada y no contra el estado actual del clon: una
# spec de desarrollo vive en la rama de su feature, y el clon puede estar parado
# en `main`, donde ese archivo todavía no existe. Comprobar contra el árbol de
# trabajo reportaría rotos los punteros sanos de todo desarrollo en curso.
#
# -----------------------------------------------------------------------------
# Tres resultados que NO son el mismo, y por eso llevan nombres distintos
# -----------------------------------------------------------------------------
#
#   puntero roto            La rama existe en el clon y la ruta NO resuelve
#                           dentro de ella. Es la falla que este script busca.
#   no verificable          El repositorio no está presente localmente. NO es un
#                           puntero roto y no se reporta como tal (límite
#                           declarado en spec-index.md §5).
#   rama ausente en el clon El repositorio está, la rama registrada no. Tampoco
#                           es un puntero roto: dice que a este clon le falta la
#                           rama, no que a la rama le falte el archivo.
#
# Colapsar cualquiera de los tres en otro produciría un reporte que se lee como
# veredicto sobre el índice cuando en realidad habla del estado del clon.
#
# A los tres se suman `verificado`, que es el caso sano, y `entrada no válida`,
# que es defecto de la propia fila del índice. Los cinco valores forman el
# vocabulario cerrado de la columna Resultado.
#
# -----------------------------------------------------------------------------
# Un cero de este script no significa que los punteros estén sanos
# -----------------------------------------------------------------------------
#
# Significa que ninguno de los que SE PUDIERON verificar estaba roto. Con todos
# los repositorios sin clonar, la corrida sale 0 y no verificó nada. Por eso el
# cierre imprime siempre cuántas entradas se verificaron de cuántas, y avisa por
# `stderr` cuando esa cifra es cero. Es la lección que spec-index.md §5 registra:
# un verificador que no verificó se parece a un resultado limpio.
#
# -----------------------------------------------------------------------------
# Lo que este script NO hace
# -----------------------------------------------------------------------------
#
# - No comprueba que el repositorio de cada entrada exista en `repositories.md`.
#   Hacerlo exigiría una segunda implementación del parseo del catálogo, y dos
#   lecturas del mismo cuerpo divergen en silencio (regla 09 del repositorio,
#   .claude/rules/09-punteros-y-replicas.md).
# - No verifica el CONTENIDO de la spec ni su conformidad con la plantilla. Solo
#   comprueba que la ruta resuelva a un objeto dentro de la rama registrada.
# - No verifica contra referencias remotas. Una rama que solo existe como
#   `refs/remotes/<remoto>/<rama>` cuenta como `rama ausente en el clon`; el
#   detalle lo dice, para que se sepa que un `fetch` y una rama local bastarían.
# - No clona, no crea, no borra y no escribe. Invoca git a través de `repo_git`,
#   cuya neutralización de hooks y `core.fsmonitor` es PARCIAL y está descrita en
#   `lib-repo-state.sh`.

set -eu

# -----------------------------------------------------------------------------
# Constantes
# -----------------------------------------------------------------------------

# Nombre del workspace. Parámetro por proyecto (SKILL.md lo declara): si este
# repositorio se clona bajo otro nombre de directorio, este valor se ajusta.
# Una entrada que lo cite como repositorio es defecto del índice: el workspace
# nunca es objetivo de esta skill (layout.md §2).
WORKSPACE_NOMBRE='claude-agentic-base'

# Ruta del índice relativa al directorio de la skill, cuando no se indica otra.
INDICE_POR_DEFECTO='spec-index.md'

# Separador interno para partir las celdas de una fila. Se usa el carácter de
# separación de unidades (0x1F) y NO un tabulador: con un IFS de espacio en
# blanco, dos celdas vacías consecutivas se colapsan en una y los campos se
# corren sin aviso. Con un separador que no es espacio en blanco, cada celda
# vacía sigue siendo un campo.
SEP=$(printf '\037')

# IFS original, para restaurarlo tras cada lectura por campos.
IFS_ORIGINAL="$IFS"

# -----------------------------------------------------------------------------
# Estado global
# -----------------------------------------------------------------------------

INDICE=''
INDICE_ORIGEN=''
RAIZ=''
RAIZ_ORIGEN=''
WORKSPACE=''

ENTRADAS=''
REGISTRADAS=0
TERMINALES=0
PENDIENTES=0
NO_INTERPRETABLES=0

ANCHO_CLAVE=5
ANCHO_REPO=11

VERIFICADOS=0
ROTOS=0
NO_VERIFICABLES=0
RAMA_AUSENTE=0
NO_VALIDAS=0

LISTA_ROTOS=''
LISTA_NO_VERIFICABLES=''
LISTA_RAMA_AUSENTE=''
LISTA_NO_VALIDAS=''

# Fijados por verificar_entrada.
RESULTADO=''
MOTIVO=''

# -----------------------------------------------------------------------------
# Salida
# -----------------------------------------------------------------------------

error() {
    printf 'ERROR: %s\n' "$1" >&2
}

avisar() {
    printf 'AVISO: %s\n' "$1" >&2
}

# Rellena con espacios hasta el ancho pedido. Solo se usa sobre columnas cuyo
# contenido pasó la validación de caracteres ASCII. Las demás no se alinean:
# `${#s}` cuenta bytes en varias implementaciones de sh, de modo que una tabla
# alineada sobre valores con acentos queda torcida aparentando estar derecha.
rellenar() {
    _rl_s="$1"
    _rl_n="$2"
    printf '%s' "$_rl_s"
    _rl_i=${#_rl_s}
    while [ "$_rl_i" -lt "$_rl_n" ]; do
        printf ' '
        _rl_i=$((_rl_i + 1))
    done
}

uso() {
    cat <<'FIN_USO'
check-spec-pointers.sh — comprueba que los punteros del índice de specs resuelvan.

USO
    check-spec-pointers.sh [opciones]
    check-spec-pointers.sh --help

SU EJECUCIÓN ES MANUAL
    No hay integración continua ni gancho que dispare este script en este
    repositorio. Protege solo cuando alguien lo corre; presentarlo como
    salvaguarda automática sería falso.

QUÉ COMPRUEBA
    Por cada entrada NO TERMINAL del índice —estado `abierta` o `en curso`—,
    que la ruta registrada resuelva dentro de la RAMA registrada del clon local
    del repositorio indicado:

        git cat-file -e refs/heads/<rama>:<ruta>

    La comprobación no cambia el estado del clon: no hay checkout, no se toca el
    árbol de trabajo y no se escribe nada. Verificar contra el árbol de trabajo
    daría rotos los punteros sanos de todo desarrollo cuya rama no esté activa.

    Las entradas `cerrada` y `cancelada` se conservan en el índice y NO se
    verifican. El índice es traza; el cierre declara cuántas se omitieron.

VOCABULARIO DE LA COLUMNA RESULTADO (cerrado)
    verificado               La ruta resuelve dentro de la rama registrada.
    puntero roto             La rama existe en el clon y la ruta NO resuelve.
    no verificable           El repositorio no está presente localmente.
                             NO es un puntero roto y no se reporta como tal.
    rama ausente en el clon  El repositorio está; la rama registrada, no.
                             Tampoco es un puntero roto.
    entrada no válida        Defecto de la propia fila del índice: estado fuera
                             del conjunto cerrado, celda obligatoria vacía,
                             nombre de repositorio inutilizable, o cita al
                             workspace.

OPCIONES
    --index <ruta>   Índice a verificar. Precede a SPEC_INDEX.
    --root <ruta>    Raíz de clones. Precede a REPOS_ROOT.
    --help, -h       Imprime este texto y sale 0.

VARIABLES DE ENTORNO
    SPEC_INDEX       Índice a verificar. Por defecto, spec-index.md de la skill.
    REPOS_ROOT       Raíz de clones. Por defecto, el directorio padre del
                     workspace. La raíz resuelta se imprime en el encabezado del
                     reporte, como ruta y nunca como nombre de variable.

QUÉ NO COMPRUEBA
    - Que el repositorio de cada entrada exista en repositories.md. Exigiría una
      segunda implementación del parseo del catálogo, y dos lecturas del mismo
      cuerpo divergen en silencio.
    - El contenido de la spec ni su conformidad con la plantilla.
    - Referencias remotas. Una rama que solo existe como refs/remotes/<remoto>/
      <rama> cuenta como `rama ausente en el clon`, y el detalle lo dice.

CÓDIGOS DE SALIDA
    0   La corrida completó y ninguna entrada quedó rota ni inválida.
    1   Error de uso o de precondición: NADA se verificó.
    2   La corrida completó y al menos una entrada quedó en `puntero roto`,
        `entrada no válida`, o en una fila que no se pudo interpretar.

    `no verificable` y `rama ausente en el clon` NO llevan la corrida a 2: son
    estados del clon local, no fallas del índice, y confundirlos haría
    indistinguible un índice roto de un espacio de trabajo incompleto.

    UN CERO NO SIGNIFICA QUE LOS PUNTEROS ESTÉN SANOS. Significa que ninguno de
    los que se pudieron verificar estaba roto. Con los repositorios sin clonar,
    la corrida sale 0 y no verificó nada. El cierre imprime siempre cuántas
    entradas se verificaron de cuántas, y avisa cuando esa cifra es cero.

    Los errores van a stderr con el prefijo `ERROR: `; los avisos, con `AVISO: `,
    y no alteran el código de salida.
FIN_USO
}

# -----------------------------------------------------------------------------
# Biblioteca compartida de lectura de estado
# -----------------------------------------------------------------------------

DIR_SCRIPT=''
DIR_SCRIPT=$(cd "$(dirname "$0")" 2>/dev/null && pwd -P) || DIR_SCRIPT=''
if [ -z "$DIR_SCRIPT" ]; then
    error 'no se pudo resolver el directorio de este script.'
    exit 1
fi

if [ ! -r "$DIR_SCRIPT/lib-repo-state.sh" ]; then
    error "no se encuentra la biblioteca $DIR_SCRIPT/lib-repo-state.sh."
    exit 1
fi

# shellcheck source=lib-repo-state.sh
. "$DIR_SCRIPT/lib-repo-state.sh"

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

while [ "$#" -gt 0 ]; do
    case "$1" in
        --index)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error '--index requiere una ruta.'
                exit 1
            fi
            INDICE="$2"
            INDICE_ORIGEN='--index'
            shift 2
            ;;
        --root)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error '--root requiere una ruta.'
                exit 1
            fi
            RAIZ="$2"
            RAIZ_ORIGEN='--root'
            shift 2
            ;;
        *)
            error "opción desconocida: $1."
            exit 1
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Precondiciones globales — todas antes de verificar nada
# -----------------------------------------------------------------------------

# 1. git presente. Sin git no hay forma de resolver un puntero, y decirlo por
#    entrada sería repetir por cada entrada la misma precondición incumplida.
if ! repo_git_available; then
    error 'git no está disponible en el PATH.'
    exit 1
fi

# 2. Workspace resuelto. El script vive en
#    .claude/skills/development-repositories/scripts/, cuatro niveles bajo
#    la raíz del workspace.
WORKSPACE=$(cd "$DIR_SCRIPT/../../../.." 2>/dev/null && pwd -P) || WORKSPACE=''
if [ -z "$WORKSPACE" ]; then
    error 'no se pudo resolver la raíz del workspace desde la ubicación del script.'
    exit 1
fi

# 3. Raíz de clones resuelta. Orden: --root, REPOS_ROOT, directorio padre
#    del workspace (layout.md §3).
if [ -z "$RAIZ" ]; then
    if [ -n "${REPOS_ROOT:-}" ]; then
        RAIZ="$REPOS_ROOT"
        RAIZ_ORIGEN='REPOS_ROOT'
    else
        RAIZ="$WORKSPACE/.."
        RAIZ_ORIGEN='default, directorio padre del workspace'
    fi
fi

_raiz_resuelta=''
_raiz_resuelta=$(cd "$RAIZ" 2>/dev/null && pwd -P) || _raiz_resuelta=''
if [ -z "$_raiz_resuelta" ]; then
    error "la raíz de clones no existe o no es accesible: $RAIZ"
    exit 1
fi
RAIZ="$_raiz_resuelta"

# 4. La raíz resuelta debe quedar FUERA del árbol del workspace (layout.md §6).
case "$RAIZ" in
    "$WORKSPACE"|"$WORKSPACE"/*)
        error "la raíz de clones resuelta cae dentro del árbol del workspace: $RAIZ"
        error "el workspace es $WORKSPACE. Los clones son sus hermanos, nunca sus hijos."
        exit 1
        ;;
esac

# 5. Índice legible. Orden: --index, SPEC_INDEX, spec-index.md de la skill.
if [ -z "$INDICE" ]; then
    if [ -n "${SPEC_INDEX:-}" ]; then
        INDICE="$SPEC_INDEX"
        INDICE_ORIGEN='SPEC_INDEX'
    else
        INDICE="$DIR_SCRIPT/../$INDICE_POR_DEFECTO"
        INDICE_ORIGEN='default'
    fi
fi

# La ruta se resuelve ANTES de comprobar que exista, para que el mensaje de error
# nombre la ruta absoluta y no una con `..` intermedios que quien lo lee tenga que
# resolver de cabeza. La misma ruta resuelta se declara después en el encabezado.
_ind_dir=''
_ind_dir=$(cd "$(dirname "$INDICE")" 2>/dev/null && pwd -P) || _ind_dir=''
if [ -n "$_ind_dir" ]; then
    INDICE="$_ind_dir/$(basename "$INDICE")"
fi

if [ ! -f "$INDICE" ] || [ ! -r "$INDICE" ]; then
    error "el índice no existe o no es legible: $INDICE"
    error 'no se verificó nada. Un índice ilegible no es un índice sin entradas.'
    exit 1
fi

# -----------------------------------------------------------------------------
# Parseo del índice
# -----------------------------------------------------------------------------
#
# La tabla se localiza por su ENCABEZADO —la fila cuya primera celda es `Clave`,
# según las ocho columnas de spec-index.md §2— y se lee hasta la primera
# línea que ya no es fila de tabla. Acotarla así importa porque el archivo lleva
# además un callout de apertura y puede llevar tablas auxiliares; un barrido
# sobre el archivo entero devolvería filas que no son entradas.
#
# Que el encabezado exista o no es lo que separa los dos ceros. Sin encabezado,
# el parseo no resolvió y no se sigue; con encabezado y sin filas, el índice está
# vacío y eso es un estado legítimo que se declara.

filas_del_indice() {
    awk '
        BEGIN { encabezado = 0; dentro = 0 }
        {
            linea = $0
            sub(/^[[:space:]]+/, "", linea)

            if (encabezado == 0) {
                if (linea ~ /^\|/) {
                    primera = linea
                    sub(/^\|[[:space:]]*/, "", primera)
                    sub(/[[:space:]]*\|.*$/, "", primera)
                    sub(/[[:space:]]+$/, "", primera)
                    if (primera == "Clave") { encabezado = 1; dentro = 1 }
                }
                next
            }

            if (linea !~ /^\|/) { dentro = 0; next }
            if (dentro == 1) { print NR ":" linea }
        }
    ' "$1"
}

if ! grep -q '^[[:space:]]*|[[:space:]]*Clave[[:space:]]*|' "$INDICE"; then
    error "no se encontró la tabla del índice en $INDICE."
    error 'se busca la fila de encabezado cuya primera celda dice Clave, según las ocho columnas del contrato.'
    error 'no se verificó nada. Un índice sin tabla no es un índice sin entradas.'
    exit 1
fi

_filas=''
_filas=$(filas_del_indice "$INDICE") || _filas=''

while IFS= read -r _cruda; do
    [ -n "$_cruda" ] || continue

    _nlinea=${_cruda%%:*}
    _linea=${_cruda#*:}

    # Fila separadora: primera celda con solo guiones, dos puntos y espacios.
    _primera=$(printf '%s' "$_linea" | sed -e 's/^[[:space:]]*|//' -e 's/|.*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [ -n "$_primera" ] || continue
    _resto=$(printf '%s' "$_primera" | tr -d '\-: ')
    [ -n "$_resto" ] || continue

    REGISTRADAS=$((REGISTRADAS + 1))

    # Se quitan la barra inicial y la final para que awk vea exactamente las
    # ocho celdas y ni una más.
    _fila=$(printf '%s' "$_linea" | sed -e 's/^[[:space:]]*|//' -e 's/|[[:space:]]*$//')
    _datos=$(printf '%s\n' "$_fila" | awk -F'|' -v s="$SEP" '
        {
            printf "%d", NF
            for (i = 1; i <= NF; i++) {
                c = $i
                gsub(/^[[:space:]]+/, "", c)
                gsub(/[[:space:]]+$/, "", c)
                printf "%s%s", s, c
            }
            printf "\n"
        }
    ')

    _n=''
    _clave=''; _slug=''; _repo=''; _rama=''; _ruta=''; _estado=''; _abierta=''; _actualizada=''
    IFS="$SEP"
    read -r _n _clave _slug _repo _rama _ruta _estado _abierta _actualizada <<_FIN_CAMPOS
$_datos
_FIN_CAMPOS
    IFS="$IFS_ORIGINAL"

    if [ "${_n:-0}" != '8' ]; then
        avisar "línea $_nlinea del índice: la fila tiene ${_n:-0} celdas y el contrato define 8; no se interpreta."
        NO_INTERPRETABLES=$((NO_INTERPRETABLES + 1))
        continue
    fi

    # La clave viene enlazada al issue: `[ABC-123](url)`. Se guarda el texto del
    # enlace, que es la clave; la URL no se usa para verificar nada.
    _clave=$(printf '%s' "$_clave" | sed -e 's/^\[\([^]]*\)\](.*)$/\1/')

    # El estado terminal admite un sufijo de motivo tras " — ", que la regla 4 de
    # spec-index.md usa para marcar una entrada cuyo repositorio salió del
    # catálogo. Se recorta acá, y no en cada comparación, para que el vocabulario
    # cerrado se evalúe sobre el estado y no sobre el estado más su marca.
    #
    # Caso observado en el workspace de origen: esa marca iba en la celda
    # Repositorio, y dejaba el nombre inutilizable como directorio: toda entrada
    # conservada caía en `entrada no válida` y la corrida quedaba en código 2 de
    # forma permanente. Es decir, la regla que promete conservar la entrada la
    # invalidaba.
    _estado_marca=''
    case "$_estado" in
        *' — '*)
            _estado_marca="${_estado#* — }"
            _estado="${_estado%% — *}"
            ;;
    esac

    # Terminales: se conservan en el índice y no se verifican (spec-index.md §3,
    # regla 2).
    case "$_estado" in
        cerrada|cancelada)
            TERMINALES=$((TERMINALES + 1))
            continue
            ;;
    esac

    PENDIENTES=$((PENDIENTES + 1))
    ENTRADAS="${ENTRADAS}${_clave}${SEP}${_repo}${SEP}${_rama}${SEP}${_ruta}${SEP}${_estado}
"

    case "$_clave" in
        *[!A-Za-z0-9._-]*) : ;;
        *) if [ "${#_clave}" -gt "$ANCHO_CLAVE" ]; then ANCHO_CLAVE=${#_clave}; fi ;;
    esac
    case "$_repo" in
        *[!A-Za-z0-9._-]*) : ;;
        *) if [ "${#_repo}" -gt "$ANCHO_REPO" ]; then ANCHO_REPO=${#_repo}; fi ;;
    esac
done <<_FIN_FILAS
$_filas
_FIN_FILAS

# -----------------------------------------------------------------------------
# Verificación de una entrada
# -----------------------------------------------------------------------------
#
# Fija RESULTADO —uno de los cinco valores del vocabulario cerrado— y MOTIVO.
# Ninguna invocación de git va sin condicional explícito y captura del código: el
# patrón `comando && printf` bajo modo estricto mata la corrida entera y dejaría
# sin verificar las entradas que siguen.

verificar_entrada() {
    _ve_repo="$1"
    _ve_rama="$2"
    _ve_ruta="$3"
    _ve_estado="$4"

    RESULTADO=''
    MOTIVO=''

    # 1. Defectos de la propia fila. Se agotan antes de tocar el disco.
    case "$_ve_estado" in
        abierta|'en curso') : ;;
        '')
            RESULTADO='entrada no válida'
            MOTIVO='celda Estado vacía'
            return 0
            ;;
        *)
            RESULTADO='entrada no válida'
            MOTIVO="estado fuera del conjunto cerrado: $_ve_estado"
            return 0
            ;;
    esac

    if [ -z "$_ve_repo" ] || [ -z "$_ve_rama" ] || [ -z "$_ve_ruta" ]; then
        RESULTADO='entrada no válida'
        MOTIVO='celda obligatoria vacía entre Repositorio, Rama y Ruta'
        return 0
    fi

    if [ "$_ve_repo" = "$WORKSPACE_NOMBRE" ]; then
        RESULTADO='entrada no válida'
        MOTIVO="cita el workspace ($WORKSPACE_NOMBRE), que nunca es objetivo de esta skill"
        return 0
    fi

    case "$_ve_repo" in
        .|..|*[!A-Za-z0-9._-]*)
            RESULTADO='entrada no válida'
            MOTIVO="nombre de repositorio no utilizable como directorio: $_ve_repo"
            return 0
            ;;
    esac

    # Un `:` en la rama o en la ruta rompería la composición `<ref>:<ruta>` que
    # git interpreta, y el resultado sería una consulta distinta de la pedida.
    case "$_ve_rama" in
        *:*|*[[:space:]]*|-*)
            RESULTADO='entrada no válida'
            MOTIVO="nombre de rama no admisible: $_ve_rama"
            return 0
            ;;
    esac

    case "$_ve_ruta" in
        /*)
            RESULTADO='entrada no válida'
            MOTIVO="la ruta debe ser relativa a la raíz del repositorio: $_ve_ruta"
            return 0
            ;;
        *:*)
            RESULTADO='entrada no válida'
            MOTIVO='la ruta contiene dos puntos, que rompen la composición <rama>:<ruta>'
            return 0
            ;;
    esac

    # 2. Presencia del clon. Ausente es `no verificable`, NUNCA `puntero roto`.
    _ve_dir="$RAIZ/$_ve_repo"

    _ve_real=''
    _ve_real=$(cd "$_ve_dir" 2>/dev/null && pwd -P) || _ve_real=''
    if [ -n "$_ve_real" ] && [ "$_ve_real" = "$WORKSPACE" ]; then
        RESULTADO='entrada no válida'
        MOTIVO='la ruta derivada apunta al workspace'
        return 0
    fi

    _ve_presencia=$(repo_presence_detail "$_ve_dir")
    case "$_ve_presencia" in
        presente) : ;;
        *)
            RESULTADO='no verificable'
            MOTIVO="$_ve_presencia — $_ve_dir"
            return 0
            ;;
    esac

    # 3. La rama registrada, en el clon. Se consulta refs/heads por nombre
    #    completo: `show-ref --verify` no adivina ni desambigua.
    _ve_rc=0
    repo_git "$_ve_dir" show-ref --verify --quiet "refs/heads/$_ve_rama" >/dev/null 2>&1 || _ve_rc=$?
    if [ "$_ve_rc" -ne 0 ]; then
        RESULTADO='rama ausente en el clon'
        # Si la rama existe como referencia remota, se dice: el arreglo es un
        # fetch y una rama local, no una corrección del índice.
        _ve_remota=0
        _ve_ref=''
        _ve_obj=''
        while read -r _ve_ref _ve_obj; do
            [ -n "$_ve_ref" ] || continue
            _ve_cola=${_ve_ref#refs/remotes/}
            [ "$_ve_cola" != "$_ve_ref" ] || continue
            case "$_ve_cola" in
                */*) : ;;
                *) continue ;;
            esac
            if [ "${_ve_cola#*/}" = "$_ve_rama" ]; then
                _ve_remota=1
            fi
        done <<_FIN_REMOTAS
$(repo_remote_refs "$_ve_dir")
_FIN_REMOTAS
        if [ "$_ve_remota" -eq 1 ]; then
            MOTIVO="la rama $_ve_rama existe como referencia remota; un fetch y una rama local la harían verificable"
        else
            MOTIVO="la rama $_ve_rama no existe en el clon, ni siquiera como referencia remota"
        fi
        return 0
    fi

    # 4. La ruta, dentro del árbol de esa rama. `cat-file -e` resuelve el objeto
    #    sin mirar el árbol de trabajo: no hay checkout y el clon queda como
    #    estaba.
    _ve_rc=0
    repo_git "$_ve_dir" cat-file -e "refs/heads/$_ve_rama:$_ve_ruta" >/dev/null 2>&1 || _ve_rc=$?
    if [ "$_ve_rc" -ne 0 ]; then
        RESULTADO='puntero roto'
        MOTIVO="$_ve_ruta no resuelve en refs/heads/$_ve_rama"
        return 0
    fi

    RESULTADO='verificado'
    return 0
}

# -----------------------------------------------------------------------------
# Encabezado del reporte
# -----------------------------------------------------------------------------

printf 'Índice de specs de desarrollo — punteros — %s\n' "$(date '+%d-%m-%Y %H:%M')"
printf '%s\n' 'Ejecución MANUAL: no hay integración continua ni gancho que dispare este script.'
printf 'Índice: %s   (fuente: %s)\n' "$INDICE" "$INDICE_ORIGEN"
printf 'Raíz de clones: %s   (fuente: %s)\n' "$RAIZ" "$RAIZ_ORIGEN"
printf 'Entradas registradas: %s | no terminales por verificar: %s | terminales omitidas: %s\n' \
    "$REGISTRADAS" "$PENDIENTES" "$TERMINALES"
printf '%s\n' 'La comprobación es de solo lectura: git cat-file contra la rama registrada, sin checkout.'
printf '\n'

# -----------------------------------------------------------------------------
# Los dos ceros, que no son el mismo
# -----------------------------------------------------------------------------
#
# El índice ilegible y el índice sin tabla ya salieron con código 1 más arriba.
# Acá quedan los ceros legítimos, y se dicen en vez de callarse: un índice sin
# entradas y un índice cuyas entradas son todas terminales son estados válidos,
# y una salida silenciosa los volvería indistinguibles de un parseo que falló.

if [ "$PENDIENTES" -eq 0 ]; then
    if [ "$REGISTRADAS" -eq 0 ]; then
        printf '%s\n' 'El índice tiene su tabla y no tiene entradas registradas: cero entradas por verificar.'
        printf '%s\n' 'No es un fallo de lectura. Un índice ilegible o sin tabla sale con código 1 y lo dice.'
    else
        printf 'Todas las entradas registradas son terminales (cerrada o cancelada): %s registradas, cero por verificar.\n' "$REGISTRADAS"
        printf '%s\n' 'Se conservan en el índice porque el índice es traza, y no se verifican por decisión del contrato.'
    fi
    if [ "$NO_INTERPRETABLES" -gt 0 ]; then
        printf 'Filas no interpretables: %s. Su línea va nombrada en los avisos de stderr.\n' "$NO_INTERPRETABLES"
        exit 2
    fi
    exit 0
fi

# -----------------------------------------------------------------------------
# Tabla por entrada
# -----------------------------------------------------------------------------

printf '| '
rellenar 'Clave' "$ANCHO_CLAVE"
printf ' | '
rellenar 'Repositorio' "$ANCHO_REPO"
printf ' | Rama | Ruta | Estado | Resultado |\n'
printf '| '
rellenar '---' "$ANCHO_CLAVE"
printf ' | '
rellenar '---' "$ANCHO_REPO"
printf ' | --- | --- | --- | --- |\n'

while IFS= read -r _entrada; do
    [ -n "$_entrada" ] || continue

    CLAVE=''; REPO=''; RAMA=''; RUTA=''; ESTADO=''
    IFS="$SEP"
    read -r CLAVE REPO RAMA RUTA ESTADO <<_FIN_ENTRADA
$_entrada
_FIN_ENTRADA
    IFS="$IFS_ORIGINAL"

    verificar_entrada "$REPO" "$RAMA" "$RUTA" "$ESTADO"

    printf '| '
    rellenar "$CLAVE" "$ANCHO_CLAVE"
    printf ' | '
    rellenar "$REPO" "$ANCHO_REPO"
    printf ' | %s | %s | %s | %s |\n' "$RAMA" "$RUTA" "$ESTADO" "$RESULTADO"

    case "$RESULTADO" in
        verificado)
            VERIFICADOS=$((VERIFICADOS + 1))
            ;;
        'puntero roto')
            ROTOS=$((ROTOS + 1))
            LISTA_ROTOS="${LISTA_ROTOS}  ${CLAVE} ${REPO}: ${MOTIVO}
"
            ;;
        'no verificable')
            NO_VERIFICABLES=$((NO_VERIFICABLES + 1))
            LISTA_NO_VERIFICABLES="${LISTA_NO_VERIFICABLES}  ${CLAVE} ${REPO}: ${MOTIVO}
"
            ;;
        'rama ausente en el clon')
            RAMA_AUSENTE=$((RAMA_AUSENTE + 1))
            LISTA_RAMA_AUSENTE="${LISTA_RAMA_AUSENTE}  ${CLAVE} ${REPO}: ${MOTIVO}
"
            ;;
        *)
            NO_VALIDAS=$((NO_VALIDAS + 1))
            LISTA_NO_VALIDAS="${LISTA_NO_VALIDAS}  ${CLAVE} ${REPO}: ${MOTIVO}
"
            ;;
    esac
done <<_FIN_ENTRADAS
$ENTRADAS
_FIN_ENTRADAS

# -----------------------------------------------------------------------------
# Cierre
# -----------------------------------------------------------------------------

printf '\n'
printf '%s de %s entradas no terminales verificadas.\n' "$VERIFICADOS" "$PENDIENTES"
printf 'Punteros rotos: %s | no verificables: %s | rama ausente en el clon: %s | entradas no válidas: %s\n' \
    "$ROTOS" "$NO_VERIFICABLES" "$RAMA_AUSENTE" "$NO_VALIDAS"
if [ "$TERMINALES" -gt 0 ]; then
    printf 'Entradas terminales omitidas: %s. Se conservan en el índice porque el índice es traza.\n' "$TERMINALES"
else
    printf '%s\n' 'Entradas terminales omitidas: 0.'
fi
if [ "$NO_INTERPRETABLES" -gt 0 ]; then
    printf 'Filas no interpretables: %s. Su línea va nombrada en los avisos de stderr.\n' "$NO_INTERPRETABLES"
fi

if [ -n "$LISTA_ROTOS" ]; then
    printf '%s\n' 'Punteros rotos:'
    printf '%s' "$LISTA_ROTOS"
fi
if [ -n "$LISTA_NO_VALIDAS" ]; then
    printf '%s\n' 'Entradas no válidas:'
    printf '%s' "$LISTA_NO_VALIDAS"
fi
if [ -n "$LISTA_NO_VERIFICABLES" ]; then
    printf '%s\n' 'No verificables (repositorio ausente; NO es un puntero roto):'
    printf '%s' "$LISTA_NO_VERIFICABLES"
fi
if [ -n "$LISTA_RAMA_AUSENTE" ]; then
    printf '%s\n' 'Rama ausente en el clon (tampoco es un puntero roto):'
    printf '%s' "$LISTA_RAMA_AUSENTE"
fi

printf '\n'
printf '%s\n' 'Límites de esta corrida, declarados: solo se verificaron repositorios presentes'
printf '%s\n' 'localmente y contra refs/heads de la rama registrada. No se comprobó que cada'
printf '%s\n' 'repositorio esté en repositories.md, ni el contenido de ninguna spec.'
printf '%s\n' 'La ejecución de este script es MANUAL: protege solo cuando alguien lo corre.'

# Un cero de verificados con entradas por verificar se parece a un resultado
# limpio y no lo es. Se avisa por stderr, sin alterar el código de salida.
if [ "$VERIFICADOS" -eq 0 ] && [ "$PENDIENTES" -gt 0 ]; then
    avisar "no se pudo verificar ninguna de las entradas no terminales del índice ($PENDIENTES); el código de salida no dice que los punteros estén sanos."
fi

if [ "$ROTOS" -gt 0 ] || [ "$NO_VALIDAS" -gt 0 ] || [ "$NO_INTERPRETABLES" -gt 0 ]; then
    exit 2
fi

exit 0
