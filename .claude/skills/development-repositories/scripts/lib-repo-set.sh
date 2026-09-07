#!/bin/sh
# lib-repo-set.sh — biblioteca compartida del CONJUNTO de repositorios de la skill
# development-repositories: de dónde sale (catálogo), dónde vive (raíz de
# clones), cuáles se recorren (selección) y cómo se tabula el reporte.
# Traza: réplica declarada de la portación, 07-09-2026 (feature
# 002-portar-agentes, ver specs/002-portar-agentes/).
#
# Se consume con "." (source), no se ejecuta sola:
#
#     . "$(dirname "$0")/lib-repo-set.sh"
#
# Ejecutarla directo imprime su propósito y sale 0.
#
# -----------------------------------------------------------------------------
# Por qué existe, y de dónde salió su contenido
# -----------------------------------------------------------------------------
#
# El parseo del catálogo y la resolución de la raíz de clones nacieron dentro de
# run-across-repos.sh. prepare-workspace.sh necesita exactamente
# los mismos: el mismo archivo, la misma sección, la misma exclusión del
# workspace por nombre, la misma precedencia entre --root, DEV_REPOS_ROOT y el
# default. Copiarlos habría dejado dos lecturas del mismo catálogo divergiendo en
# silencio, que es lo que prohíbe .claude/rules/09-punteros-y-replicas.md.
#
# ASÍ QUE SE MOVIERON ACÁ, y el movimiento se declara: run-across-repos.sh ya no
# los implementa, los consume. Su comportamiento observable no cambió —los
# mensajes de error, los avisos y el orden de las comprobaciones se trasladaron
# literales—, y lo que sí cambió es que ahora hay un solo lugar donde corregirlos.
#
# Se eligió un archivo nuevo en vez de ampliar lib-repo-state.sh porque esa
# biblioteca declara un alcance distinto en su propio encabezado: el estado de UN
# repositorio local. El par se lee como lo que es — lib-repo-state.sh mira un
# repositorio, lib-repo-set.sh mira el conjunto — y ninguna de las dos consume a
# la otra.
#
# -----------------------------------------------------------------------------
# Funciones expuestas
# -----------------------------------------------------------------------------
#
#   repos_error <texto> / repos_avisar <texto>
#       Escriben a stderr con los prefijos `ERROR: ` y `AVISO: ` que fija
#       layout.md §7. Viven acá para que dos scripts no escriban el mismo
#       diagnóstico con dos redacciones distintas.
#
#   repos_rellenar <texto> <ancho>
#       Rellena con espacios hasta el ancho pedido, sin salto de línea.
#
#   repos_celda <fila> <n>
#       Celda n de una fila Markdown, sin espacios de borde. La primera celda es
#       la 1. Devuelve cadena vacía si la fila no tiene esa celda.
#
#   repos_columna_de <fila_de_encabezado> <titulo>
#       Número de columna cuyo título coincide exacto, o 0 si no está. Es lo que
#       permite ubicar `Link` sin fijar su índice en el código: si el catálogo
#       reordena sus columnas, la posición se vuelve a leer del encabezado.
#
#   repos_resolve_workspace <dir_del_script>
#       Fija REPOS_WORKSPACE. Devuelve 1 e imprime el error si no resuelve.
#
#   repos_resolve_root <ruta_de_opcion>
#       Fija REPOS_ROOT y REPOS_ROOT_ORIGEN. Precedencia: la opción, luego
#       DEV_REPOS_ROOT, luego el directorio padre del workspace (layout.md §3).
#       Devuelve 1 si la raíz no existe o si cae dentro del árbol del workspace.
#
#   repos_resolve_catalog <ruta_de_opcion> <dir_del_script>
#       Fija REPOS_CATALOG y REPOS_CATALOG_ORIGEN. Precedencia: la opción, luego
#       DEV_REPOS_CATALOG, luego repositories.md de la skill.
#
#   repos_parse_catalog
#       Lee REPOS_CATALOG y fija REPOS_NOMBRES, REPOS_ENTRADAS,
#       REPOS_TOTAL_FILAS, REPOS_NOMBRES_OK, REPOS_EXCLUIDAS y REPOS_LINK_COL.
#       Devuelve 1 si el catálogo no tiene filas de datos o si ninguna produce un
#       nombre operable.
#
#   repos_link_of <nombre>
#       Enlace de clonado registrado en el catálogo para ese repositorio, o
#       cadena vacía. No inventa una URL a partir del nombre.
#
#   repos_link_usable <enlace>
#       Solo como condición. Devuelve 0 si el enlace tiene una forma que git
#       acepta como origen remoto.
#
#   repos_remote_key <url>
#       Clave de comparación de dos URL de git. Ver sus límites más abajo.
#
#   repos_select <lista_de_only>
#       Fija REPOS_SELECCION, REPOS_SELECCIONADOS y REPOS_ANCHO. Un nombre fuera
#       del catálogo es error, nunca un recorrido vacío con éxito.
#
# -----------------------------------------------------------------------------
# El total y los nombres salen de caminos distintos, a propósito
# -----------------------------------------------------------------------------
#
# REPOS_TOTAL_FILAS cuenta filas de datos; REPOS_NOMBRES_OK cuenta nombres
# utilizables. Si ambas cifras salieran del mismo paso, una fila descartada sería
# indetectable: el reporte quedaría internamente consistente y nadie sabría que
# falta un repositorio (hallazgo registrado en el análisis del workspace de
# origen). La diferencia se avisa.
#
# -----------------------------------------------------------------------------
# Límites de repos_remote_key, dichos para que nadie la lea como equivalencia
# -----------------------------------------------------------------------------
#
# Normaliza esquema, usuario, forma scp, sufijo `.git`, barras finales y
# mayúsculas. NO entiende puertos, redirecciones del servidor, espejos ni
# nombres alternativos del mismo host. Dos URL que apuntan al mismo repositorio
# por caminos que ella no cubre se leen como distintas.
#
# La dirección del error es deliberada: una comparación que no reconoce se
# resuelve como "no corresponde", y quien la consuma se detiene en vez de
# escribir sobre un directorio que no identificó.
#
# -----------------------------------------------------------------------------
# Convenciones internas
# -----------------------------------------------------------------------------
#
# POSIX sh no tiene `local`, de modo que cada función usa un prefijo propio
# (_sf_, _sd_, _sw_, _sr_, _sc_, _sp_, _sl_, _sn_, _ss_). Ninguno coincide con
# los de lib-repo-state.sh (_rg_, _rp_, _rb_, _rc_, _ru_, _rk_, _rr_), porque las
# dos bibliotecas conviven en el mismo shell y una función que llame a la otra no
# debe pisarle sus variables. Toda variable va entre comillas.

set -eu

# -----------------------------------------------------------------------------
# Constantes
# -----------------------------------------------------------------------------

# Nombre del workspace. Se excluye del recorrido POR NOMBRE, además de por su
# ausencia del catálogo. Una garantía que dependiera solo de que la fuente nunca
# lo liste sería más frágil de lo necesario. Ajustar este valor si el proyecto
# que adopta la plantilla renombra su repositorio workspace.
REPOS_WORKSPACE_NOMBRE='claude-agentic-base'

# Ruta del catálogo relativa al directorio de la skill, cuando no se indica otra.
REPOS_CATALOGO_POR_DEFECTO='repositories.md'

# Separador interno de REPOS_ENTRADAS. Un tabulador no aparece en ninguna celda
# del catálogo, que es lo que lo vuelve utilizable como separador.
REPOS_TAB=$(printf '\t')

# -----------------------------------------------------------------------------
# Estado que fijan las funciones de esta biblioteca
# -----------------------------------------------------------------------------

REPOS_WORKSPACE=''
REPOS_ROOT=''
REPOS_ROOT_ORIGEN=''
REPOS_CATALOG=''
REPOS_CATALOG_ORIGEN=''
REPOS_NOMBRES=''
REPOS_ENTRADAS=''
REPOS_TOTAL_FILAS=0
REPOS_NOMBRES_OK=0
REPOS_EXCLUIDAS=0
REPOS_LINK_COL=0
REPOS_SELECCION=''
REPOS_SELECCIONADOS=0
REPOS_ANCHO=11

# -----------------------------------------------------------------------------
# Salida
# -----------------------------------------------------------------------------

repos_error() {
    printf 'ERROR: %s\n' "${1:-}" >&2
}

repos_avisar() {
    printf 'AVISO: %s\n' "${1:-}" >&2
}

# Solo se usa sobre la columna Repositorio, cuyo contenido es ASCII por la
# validación del parseo. Las otras columnas NO se alinean: sus valores llevan
# acentos (`al día`, `vacío`) y `${#s}` cuenta bytes en varias implementaciones
# de sh, de modo que una tabla alineada sobre ellos quedaría torcida aparentando
# estar derecha.
repos_rellenar() {
    _sf_s="${1:-}"
    _sf_n="${2:-0}"
    printf '%s' "$_sf_s"
    _sf_i=${#_sf_s}
    while [ "$_sf_i" -lt "$_sf_n" ]; do
        printf ' '
        _sf_i=$((_sf_i + 1))
    done
}

# -----------------------------------------------------------------------------
# Lectura de una fila Markdown
# -----------------------------------------------------------------------------
#
# Una fila `| a | b |` parte en campos vacío, " a ", " b ", vacío al cortar por
# la barra, de modo que la celda n es el campo n+1.

repos_celda() {
    printf '%s\n' "${1:-}" | awk -F'|' -v n="${2:-1}" '
        {
            if (n + 1 > NF) { print ""; exit }
            v = $(n + 1)
            sub(/^[ \t]+/, "", v)
            sub(/[ \t]+$/, "", v)
            print v
            exit
        }
    '
}

repos_columna_de() {
    printf '%s\n' "${1:-}" | awk -F'|' -v t="${2:-}" '
        {
            for (i = 2; i <= NF; i++) {
                v = $i
                sub(/^[ \t]+/, "", v)
                sub(/[ \t]+$/, "", v)
                if (v == t) { print i - 1; exit }
            }
            print 0
            exit
        }
    '
}

# -----------------------------------------------------------------------------
# Resolución del workspace, de la raíz de clones y del catálogo
# -----------------------------------------------------------------------------

# Los scripts de la skill viven en
# .claude/skills/development-repositories/scripts/, cuatro niveles bajo la
# raíz del workspace.
repos_resolve_workspace() {
    _sw_dir="${1:-}"
    if [ -z "$_sw_dir" ]; then
        repos_error 'repos_resolve_workspace requiere el directorio del script.'
        return 1
    fi

    REPOS_WORKSPACE=$(cd "$_sw_dir/../../../.." 2>/dev/null && pwd -P) || REPOS_WORKSPACE=''
    if [ -z "$REPOS_WORKSPACE" ]; then
        repos_error 'no se pudo resolver la raíz del workspace desde la ubicación del script.'
        return 1
    fi
    return 0
}

repos_resolve_root() {
    _sr_opcion="${1:-}"

    if [ -z "$REPOS_WORKSPACE" ]; then
        repos_error 'repos_resolve_root exige el workspace ya resuelto.'
        return 1
    fi

    if [ -n "$_sr_opcion" ]; then
        REPOS_ROOT="$_sr_opcion"
        REPOS_ROOT_ORIGEN='--root'
    elif [ -n "${DEV_REPOS_ROOT:-}" ]; then
        REPOS_ROOT="$DEV_REPOS_ROOT"
        REPOS_ROOT_ORIGEN='DEV_REPOS_ROOT'
    else
        REPOS_ROOT="$REPOS_WORKSPACE/.."
        REPOS_ROOT_ORIGEN='default, directorio padre del workspace'
    fi

    _sr_resuelta=''
    _sr_resuelta=$(cd "$REPOS_ROOT" 2>/dev/null && pwd -P) || _sr_resuelta=''
    if [ -z "$_sr_resuelta" ]; then
        repos_error "la raíz de clones no existe o no es accesible: $REPOS_ROOT"
        return 1
    fi
    REPOS_ROOT="$_sr_resuelta"

    # La raíz resuelta debe quedar FUERA del árbol del workspace. Vale para el
    # default y para un valor de DEV_REPOS_ROOT. Sin esta comprobación, las
    # razones registradas en el análisis del workspace de origen quedarían
    # sostenidas por una afirmación en prosa, y con la raíz calculada a partir
    # de dónde está el workspace, apuntarla adentro es un error fácil de
    # cometer.
    case "$REPOS_ROOT" in
        "$REPOS_WORKSPACE"|"$REPOS_WORKSPACE"/*)
            repos_error "la raíz de clones resuelta cae dentro del árbol del workspace: $REPOS_ROOT"
            repos_error "el workspace es $REPOS_WORKSPACE. Los clones son sus hermanos, nunca sus hijos."
            return 1
            ;;
    esac
    return 0
}

repos_resolve_catalog() {
    _sc_opcion="${1:-}"
    _sc_dir_script="${2:-}"

    if [ -n "$_sc_opcion" ]; then
        REPOS_CATALOG="$_sc_opcion"
        REPOS_CATALOG_ORIGEN='--catalog'
    elif [ -n "${DEV_REPOS_CATALOG:-}" ]; then
        REPOS_CATALOG="$DEV_REPOS_CATALOG"
        REPOS_CATALOG_ORIGEN='DEV_REPOS_CATALOG'
    else
        if [ -z "$_sc_dir_script" ]; then
            repos_error 'repos_resolve_catalog requiere el directorio del script para el catálogo por defecto.'
            return 1
        fi
        REPOS_CATALOG="$_sc_dir_script/../$REPOS_CATALOGO_POR_DEFECTO"
        REPOS_CATALOG_ORIGEN='default'
    fi

    if [ ! -f "$REPOS_CATALOG" ] || [ ! -r "$REPOS_CATALOG" ]; then
        repos_error "el catálogo no existe o no es legible: $REPOS_CATALOG"
        return 1
    fi

    # La ruta del catálogo también se declara resuelta en el encabezado del
    # reporte. Una ruta escrita con `..` intermedios obliga a quien la lee a
    # resolverla de cabeza para verificarla.
    _sc_dir=''
    _sc_dir=$(cd "$(dirname "$REPOS_CATALOG")" 2>/dev/null && pwd -P) || _sc_dir=''
    if [ -n "$_sc_dir" ]; then
        REPOS_CATALOG="$_sc_dir/$(basename "$REPOS_CATALOG")"
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Parseo del catálogo
# -----------------------------------------------------------------------------

# Acota el barrido a la sección 1, igual que el comando recomputable que declara
# repositories.md. Otras secciones nombran repositorios en prosa y dentro de
# tablas auxiliares; un barrido sobre el archivo entero devolvería una cifra
# mayor que parecería correcta.
repos_filas() {
    awk '
        /^## 1\./ { dentro = 1; next }
        /^## /    { if (dentro == 1) dentro = 0 }
        dentro == 1 && /^[[:space:]]*\|/ { print }
    ' "${1:-}"
}

repos_parse_catalog() {
    if [ -z "$REPOS_CATALOG" ]; then
        repos_error 'repos_parse_catalog exige el catálogo ya resuelto.'
        return 1
    fi

    REPOS_NOMBRES=''
    REPOS_ENTRADAS=''
    REPOS_TOTAL_FILAS=0
    REPOS_NOMBRES_OK=0
    REPOS_EXCLUIDAS=0
    REPOS_LINK_COL=0

    _sp_filas=''
    _sp_filas=$(repos_filas "$REPOS_CATALOG") || _sp_filas=''

    while IFS= read -r _sp_linea; do
        [ -n "$_sp_linea" ] || continue

        _sp_celda=$(repos_celda "$_sp_linea" 1)

        # Una fila sin primera celda no es fila de datos.
        [ -n "$_sp_celda" ] || continue

        # Encabezado de la tabla. Es la única fila que dice dónde está el enlace.
        if [ "$_sp_celda" = 'Repositorio' ]; then
            REPOS_LINK_COL=$(repos_columna_de "$_sp_linea" 'Link')
            continue
        fi

        # Separador: solo guiones, dos puntos y espacios.
        _sp_resto=$(printf '%s' "$_sp_celda" | tr -d '\-: ')
        [ -n "$_sp_resto" ] || continue

        # A partir de acá es una fila de datos, y se cuenta como tal ANTES de
        # saber si su nombre es utilizable.
        REPOS_TOTAL_FILAS=$((REPOS_TOTAL_FILAS + 1))

        # El workspace se excluye por nombre, además de por su ausencia del
        # catálogo.
        if [ "$_sp_celda" = "$REPOS_WORKSPACE_NOMBRE" ]; then
            repos_avisar "el catálogo contiene $REPOS_WORKSPACE_NOMBRE; se excluye por nombre y no se opera."
            REPOS_EXCLUIDAS=$((REPOS_EXCLUIDAS + 1))
            continue
        fi

        # Nombre utilizable como directorio. Lo que no lo sea se declara, nunca
        # se descarta en silencio.
        case "$_sp_celda" in
            *[!A-Za-z0-9._-]*|.|..)
                repos_avisar "fila del catálogo con un nombre no utilizable como directorio: $_sp_celda"
                continue
                ;;
        esac

        _sp_link=''
        if [ "$REPOS_LINK_COL" -gt 0 ]; then
            _sp_link=$(repos_celda "$_sp_linea" "$REPOS_LINK_COL")
        fi

        REPOS_NOMBRES="${REPOS_NOMBRES}${_sp_celda}
"
        REPOS_ENTRADAS="${REPOS_ENTRADAS}${_sp_celda}${REPOS_TAB}${_sp_link}
"
        REPOS_NOMBRES_OK=$((REPOS_NOMBRES_OK + 1))
    done <<_FIN_FILAS
$_sp_filas
_FIN_FILAS

    if [ "$REPOS_TOTAL_FILAS" -eq 0 ]; then
        repos_error "el catálogo no tiene filas de datos en su sección 1: $REPOS_CATALOG"
        repos_error 'un cero acá es catálogo vacío o parseo que no resolvió, y son indistinguibles: no se sigue.'
        return 1
    fi

    _sp_perdidas=$((REPOS_TOTAL_FILAS - REPOS_NOMBRES_OK - REPOS_EXCLUIDAS))
    if [ "$_sp_perdidas" -gt 0 ]; then
        repos_avisar "descuadre de parseo del catálogo — filas de datos: $REPOS_TOTAL_FILAS; nombres operables: $REPOS_NOMBRES_OK; exclusiones por nombre: $REPOS_EXCLUIDAS; fuera del recorrido: $_sp_perdidas."
    fi

    if [ "$REPOS_LINK_COL" -eq 0 ]; then
        repos_avisar "el catálogo no declara una columna Link en su sección 1: $REPOS_CATALOG"
        repos_avisar 'sin enlace no se puede clonar ni comprobar a qué remoto corresponde un clon existente.'
    fi

    if [ "$REPOS_NOMBRES_OK" -eq 0 ]; then
        repos_error 'ninguna fila del catálogo produjo un nombre operable.'
        return 1
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Enlace de clonado
# -----------------------------------------------------------------------------

repos_link_of() {
    _sl_nombre="${1:-}"
    _sl_out=''
    if [ -z "$_sl_nombre" ]; then
        printf '%s\n' ''
        return 0
    fi

    while IFS="$REPOS_TAB" read -r _sl_n _sl_l; do
        [ -n "$_sl_n" ] || continue
        if [ "$_sl_n" = "$_sl_nombre" ]; then
            _sl_out="${_sl_l:-}"
        fi
    done <<_FIN_ENTRADAS
$REPOS_ENTRADAS
_FIN_ENTRADAS

    printf '%s\n' "$_sl_out"
    return 0
}

# Solo como condición. Las formas admitidas son las que git acepta como origen y
# que además no pueden confundirse con una bandera: ninguna empieza con `-`.
repos_link_usable() {
    case "${1:-}" in
        https://*|http://*|ssh://*|git://*|file://*) return 0 ;;
        *@*:*)                                      return 0 ;;
        *)                                          return 1 ;;
    esac
}

repos_remote_key() {
    _sn_u="${1:-}"
    if [ -z "$_sn_u" ]; then
        printf '%s\n' ''
        return 0
    fi

    case "$_sn_u" in
        https://*) _sn_u="${_sn_u#https://}" ;;
        http://*)  _sn_u="${_sn_u#http://}" ;;
        ssh://*)   _sn_u="${_sn_u#ssh://}" ;;
        git://*)   _sn_u="${_sn_u#git://}" ;;
        file://*)  _sn_u="${_sn_u#file://}" ;;
    esac

    # Quita la parte de usuario. También deja fuera una credencial embebida en la
    # URL, de modo que la clave se puede comparar sin arrastrarla.
    case "$_sn_u" in
        *@*) _sn_u="${_sn_u#*@}" ;;
    esac

    # Forma scp `host:ruta`, que git acepta y que equivale a `host/ruta`.
    case "$_sn_u" in
        *:*) _sn_u="${_sn_u%%:*}/${_sn_u#*:}" ;;
    esac

    while : ; do
        case "$_sn_u" in
            */) _sn_u="${_sn_u%/}" ;;
            *)  break ;;
        esac
    done
    _sn_u="${_sn_u%.git}"
    while : ; do
        case "$_sn_u" in
            */) _sn_u="${_sn_u%/}" ;;
            *)  break ;;
        esac
    done

    printf '%s\n' "$_sn_u" | tr '[:upper:]' '[:lower:]'
    return 0
}

# -----------------------------------------------------------------------------
# Selección
# -----------------------------------------------------------------------------
#
# Un nombre fuera del catálogo es ERROR, no un recorrido vacío con éxito. Es la
# trampa del cero dentro del código escrito para respetarla (hallazgo registrado
# en el análisis del workspace de origen).

# -----------------------------------------------------------------------------
# repos_veredicto_remoto <dir> <link>
# -----------------------------------------------------------------------------
#
# Vive acá, y no en un script, porque la consumen DOS scripts: prepare-workspace.sh
# antes de clonar, y run-across-repos.sh antes de toda operación mutante. En el
# diseño de origen estuvo solo en el primero, y esa asimetría era un defecto
# real: el verbo que muta el árbol de trabajo operaba sobre cualquier
# repositorio git que ocupara la ruta derivada, sin comprobar de dónde venía.
# Caso observado en el workspace de origen sobre repositorios efímeros: un clon
# de otro origen recibió `fetch` y `merge --ff-only`, avanzó su HEAD, y el
# reporte dijo `actualizado`.
#
# La regla del contrato de reporte que la sostiene rige el modo preparar en sus
# TRES operaciones y no solo en la que clona (procedencia del diseño:
# specs/002-portar-agentes/).
#
# Compara los remotos de un clon existente contra el enlace del catálogo. Imprime
# el veredicto en una palabra: corresponde | no corresponde | sin remotos |
# ilegible. Nunca imprime la URL encontrada.
repos_veredicto_remoto() {
    _rvr_dir="$1"
    _rvr_link="$2"

    _rvr_raw=''
    _rvr_rc=0
    _rvr_raw=$(repo_git "$_rvr_dir" remote -v 2>/dev/null) || _rvr_rc=$?
    if [ "$_rvr_rc" -ne 0 ]; then
        printf '%s\n' 'ilegible'
        return 0
    fi
    if [ -z "$_rvr_raw" ]; then
        printf '%s\n' 'sin remotos'
        return 0
    fi

    _rvr_esperada=$(repos_remote_key "$_rvr_link")
    _rvr_hallada=0
    while IFS= read -r _rvr_linea; do
        [ -n "$_rvr_linea" ] || continue
        _rvr_url=$(printf '%s\n' "$_rvr_linea" | awk '{ print $2 }')
        [ -n "$_rvr_url" ] || continue
        if [ "$(repos_remote_key "$_rvr_url")" = "$_rvr_esperada" ]; then
            _rvr_hallada=1
        fi
    done <<_FIN_REMOTOS
$_rvr_raw
_FIN_REMOTOS

    if [ "$_rvr_hallada" -eq 1 ]; then
        printf '%s\n' 'corresponde'
    else
        printf '%s\n' 'no corresponde'
    fi
    return 0
}

repos_select() {
    _ss_solo="${1:-}"
    REPOS_SELECCION=''
    REPOS_SELECCIONADOS=0
    REPOS_ANCHO=11

    if [ -n "$_ss_solo" ]; then
        while IFS= read -r _ss_pedido; do
            [ -n "$_ss_pedido" ] || continue
            _ss_encontrado=0
            while IFS= read -r _ss_n; do
                [ -n "$_ss_n" ] || continue
                if [ "$_ss_n" = "$_ss_pedido" ]; then
                    _ss_encontrado=1
                fi
            done <<_FIN_NOMBRES
$REPOS_NOMBRES
_FIN_NOMBRES
            if [ "$_ss_encontrado" -eq 0 ]; then
                repos_error "--only $_ss_pedido: ese nombre no está en el catálogo $REPOS_CATALOG."
                repos_error 'la coincidencia es exacta y nada se ejecutó.'
                return 1
            fi
            # Un nombre repetido no se agrega dos veces. Sin esto, `--only r
            # --only r` recorre el repositorio dos veces, imprime dos filas
            # idénticas y lo cuenta dos veces en el cierre: cifras infladas que
            # el reporte presenta como si fueran repositorios distintos.
            _ss_ya=0
            while IFS= read -r _ss_prev; do
                [ -n "$_ss_prev" ] || continue
                if [ "$_ss_prev" = "$_ss_pedido" ]; then
                    _ss_ya=1
                fi
            done <<_FIN_YA
$REPOS_SELECCION
_FIN_YA
            if [ "$_ss_ya" -eq 1 ]; then
                repos_avisar "--only $_ss_pedido aparece más de una vez; se recorre una sola."
            else
                REPOS_SELECCION="${REPOS_SELECCION}${_ss_pedido}
"
            fi
        done <<_FIN_SOLO
$_ss_solo
_FIN_SOLO
    else
        REPOS_SELECCION="$REPOS_NOMBRES"
    fi

    while IFS= read -r _ss_n; do
        [ -n "$_ss_n" ] || continue
        REPOS_SELECCIONADOS=$((REPOS_SELECCIONADOS + 1))
        _ss_largo=${#_ss_n}
        if [ "$_ss_largo" -gt "$REPOS_ANCHO" ]; then
            REPOS_ANCHO="$_ss_largo"
        fi
    done <<_FIN_ANCHO
$REPOS_SELECCION
_FIN_ANCHO

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
    lib-repo-set.sh)
        printf '%s\n' 'lib-repo-set.sh es una biblioteca de la skill development-repositories.'
        printf '%s\n' 'No se ejecuta sola: se incluye con "." desde los scripts de la skill.'
        printf '%s\n' ''
        printf '%s\n' '    . "$(dirname "$0")/lib-repo-set.sh"'
        printf '%s\n' ''
        printf '%s\n' 'Expone: repos_error, repos_avisar, repos_rellenar, repos_celda,'
        printf '%s\n' '        repos_columna_de, repos_resolve_workspace, repos_resolve_root,'
        printf '%s\n' '        repos_resolve_catalog, repos_filas, repos_parse_catalog,'
        printf '%s\n' '        repos_link_of, repos_link_usable, repos_remote_key,'
        printf '%s\n' '        repos_veredicto_remoto, repos_select.'
        exit 0
        ;;
esac
