#!/bin/sh
# prepare-workspace.sh — clona en la raíz de clones los repositorios del catálogo
# que todavía no están, y reporta el conjunto entero.
# Skill: development-repositories. Traza de la portación: specs/002-portar-agentes/.
#
# Forma del reporte: contrato "workspace-status-report" definido en el workspace
# de origen (réplica declarada de la portación, 07-09-2026, feature
# 002-portar-agentes); sus reglas se citan por número en este script.
# Códigos de salida, vocabulario y disposición de directorios: layout.md de la skill.
# Catálogo, raíz de clones y selección: lib-repo-set.sh, compartida con
# run-across-repos.sh.
#
# -----------------------------------------------------------------------------
# La comprobación que este script existe para hacer
# -----------------------------------------------------------------------------
#
# La regla 8 del contrato de reporte: si la ruta destino ya existe y no es un
# repositorio git, o lo es pero su remoto no corresponde al repositorio del
# catálogo, la operación se detiene ANTES DE CREAR NADA y lo reporta por nombre.
#
# Es el peligro que introdujo poner los clones como hermanos del workspace.
# Cuando la raíz era un subdirectorio propio de la skill, contenía solo clones
# del catálogo. Ahora es un directorio compartido que la skill no posee, donde ya
# vive el workspace y donde el usuario puede tener cualquier otra cosa.
#
# -----------------------------------------------------------------------------
# La corrida entera se detiene, no solo el repositorio en conflicto
# -----------------------------------------------------------------------------
#
# La alternativa era marcar ese repositorio como error y seguir clonando los
# demás. Se descartó por lo que significa una ruta ocupada: la raíz no contiene
# lo que el script supone. La causa más probable no es un directorio suelto sino
# una raíz mal apuntada —REPOS_ROOT es libre y el default se calcula desde
# la ubicación del workspace—, y en ese caso clonar los demás repositorios
# esparce el error en vez de detenerlo.
#
# Quien tenga una colisión real y acotada sigue teniendo salida: `--only` con los
# repositorios que sí quiere preparar.
#
# La inspección es una pasada completa previa. Se mira toda la selección, se
# juntan las colisiones y recién después se clona; así el reporte las nombra
# todas de una vez en vez de detenerse en la primera.
#
# -----------------------------------------------------------------------------
# Lo que este script NO hace
# -----------------------------------------------------------------------------
#
# No borra, no mueve y no renombra nada de la raíz de clones, ni siquiera lo que
# estorba: un directorio que ocupa la ruta destino se reporta y lo resuelve una
# persona (contrato de reporte, regla 5). Tampoco limpia un clon que quedó a
# medias por un fallo de red.
#
# No hace push ni abre pull request. No toca los repositorios que ya están
# presentes: un clon preexistente se reporta como `sin cambios` y no se actualiza
# —actualizar es `run-across-repos.sh pull`—.
#
# Invoca git a través de repo_git, que neutraliza hooks y core.fsmonitor. La
# mitigación es parcial y está descrita en lib-repo-state.sh. Las tres
# restricciones centrales de la skill —no tocar código de producto, no leer
# secretos, no publicar sin confirmación— siguen siendo garantías de proceso.

set -eu

# -----------------------------------------------------------------------------
# Estado global
# -----------------------------------------------------------------------------

CATALOGO_OPCION=''
RAIZ_OPCION=''
SOLO=''
DRY_RUN=0

# Plan de la pasada de inspección. Una línea por repositorio:
#     <nombre><TAB><accion><TAB><motivo>
# con accion en clonar | preexistente | error.
PLAN=''

# Colisiones detectadas. Una línea por repositorio: <nombre><TAB><motivo>.
COLISIONES=''

# -----------------------------------------------------------------------------
# Uso
# -----------------------------------------------------------------------------

uso() {
    cat <<'FIN_USO'
prepare-workspace.sh — clona los repositorios del catálogo que faltan en la raíz de clones.

USO
    prepare-workspace.sh [opciones]
    prepare-workspace.sh --help

QUÉ HACE
    1. Resuelve la raíz de clones y el catálogo, y los declara en el encabezado.
    2. Inspecciona la ruta destino de cada repositorio SIN crear nada.
    3. Si alguna ruta está ocupada por algo que no es el clon esperado, se
       detiene, nombra todas las colisiones y no clona nada (código 1).
    4. Si no hay colisiones, clona los ausentes y reporta el conjunto entero.

    El directorio local se llama EXACTAMENTE como el repositorio, sin
    transformar. Un repositorio ya presente no se reclona: se reporta como
    `sin cambios`.

OPCIONES
    --only <nombre>     Restringe la preparación a ese repositorio. Repetible.
                        La coincidencia es EXACTA contra el catálogo; un nombre
                        que no exista es error de uso (código 1), nunca un
                        recorrido vacío con éxito.
    --dry-run           Inspecciona y reporta qué clonaría, sin clonar nada.
    --catalog <ruta>    Catálogo a usar. Precede a REPOS_CATALOG.
    --root <ruta>       Raíz de clones. Precede a REPOS_ROOT.
    --help, -h          Imprime este texto y sale 0.

VARIABLES DE ENTORNO
    REPOS_ROOT          Raíz de clones. Por defecto, el directorio padre del
                        workspace. La raíz resuelta se imprime en el encabezado
                        del reporte, como ruta y nunca como nombre de variable.
    REPOS_CATALOG       Catálogo a usar. Por defecto, repositories.md de la skill.

DE DÓNDE SALE LA URL DE CLONADO
    De la columna `Link` de la sección 1 del catálogo, ubicada leyendo el
    encabezado de la tabla y no por posición fija. Una fila sin enlace utilizable
    NO se clona y NO se completa con una URL derivada del nombre: se reporta como
    error de esa fila, y la corrida sale con código 2.

QUÉ CUENTA COMO COLISIÓN
    - La ruta existe y no es un repositorio git.
    - La ruta existe, es parte de un repositorio git, pero no es su raíz.
    - La ruta es un clon cuyo remoto no corresponde al enlace del catálogo,
      incluido el caso de un clon sin ningún remoto configurado.
    - La ruta derivada apunta al workspace.

    La URL remota encontrada NO se imprime en el reporte. Una URL de git puede
    llevar credenciales embebidas, y este script no escribe secretos a la salida:
    se dice que no corresponde, no cuál era.

CÓDIGOS DE SALIDA
    0   La corrida completó y ningún repositorio quedó en error.
    1   Error de uso o de precondición: NADA se creó. Incluye el caso de
        colisión, que se detecta antes de clonar.
    2   La corrida completó y al menos un repositorio terminó en `error: <motivo>`.

    Los errores van a stderr con el prefijo `ERROR: `; los avisos, con `AVISO: `,
    y no alteran el código de salida.

LÍMITE CONOCIDO
    El fixture examples/test-catalog.md no ejercita este script: sus enlaces son
    sintéticos y sus clones no tienen remoto real, de modo que la comprobación de
    remoto los lee como colisión. Probar la preparación exige una raíz y un
    catálogo armados con remotos locales.
FIN_USO
}

# -----------------------------------------------------------------------------
# Bibliotecas compartidas
# -----------------------------------------------------------------------------

DIR_SCRIPT=''
DIR_SCRIPT=$(cd "$(dirname "$0")" 2>/dev/null && pwd -P) || DIR_SCRIPT=''
if [ -z "$DIR_SCRIPT" ]; then
    printf 'ERROR: %s\n' 'no se pudo resolver el directorio de este script.' >&2
    exit 1
fi

for _lib in lib-repo-state.sh lib-repo-set.sh; do
    if [ ! -r "$DIR_SCRIPT/$_lib" ]; then
        printf 'ERROR: %s\n' "no se encuentra la biblioteca $DIR_SCRIPT/$_lib." >&2
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

while [ "$#" -gt 0 ]; do
    case "$1" in
        --only)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                repos_error '--only requiere el nombre de un repositorio.'
                exit 1
            fi
            SOLO="${SOLO}$2
"
            shift 2
            ;;
        --catalog)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                repos_error '--catalog requiere una ruta.'
                exit 1
            fi
            CATALOGO_OPCION="$2"
            shift 2
            ;;
        --root)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                repos_error '--root requiere una ruta.'
                exit 1
            fi
            RAIZ_OPCION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        *)
            repos_error "opción desconocida: $1."
            exit 1
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Precondiciones globales — todas antes de tocar nada
# -----------------------------------------------------------------------------
#
# Son las mismas de run-across-repos.sh, y lo son porque las ejecuta el mismo
# código: la resolución y el parseo viven en lib-repo-set.sh.

if ! repo_git_available; then
    repos_error 'git no está disponible en el PATH.'
    exit 1
fi

repos_resolve_workspace "$DIR_SCRIPT" || exit 1
repos_resolve_root "$RAIZ_OPCION" || exit 1
repos_resolve_catalog "$CATALOGO_OPCION" "$DIR_SCRIPT" || exit 1
repos_parse_catalog || exit 1
repos_select "$SOLO" || exit 1

# -----------------------------------------------------------------------------
# Pasada de inspección — no crea nada
# -----------------------------------------------------------------------------

anotar_plan() {
    PLAN="${PLAN}${1}${REPOS_TAB}${2}${REPOS_TAB}${3}
"
}

anotar_colision() {
    COLISIONES="${COLISIONES}${1}${REPOS_TAB}${2}
"
}

A_CLONAR=0

while IFS= read -r REPO; do
    [ -n "$REPO" ] || continue

    DIR="$REPOS_ROOT/$REPO"
    LINK=$(repos_link_of "$REPO")

    # El workspace nunca es objetivo. Ya se excluyó por nombre al parsear; esta
    # comprobación es sobre la RUTA resuelta, y cubre el caso de una raíz
    # apuntada de forma que el directorio derivado caiga sobre el workspace.
    _dir_real=''
    _dir_real=$(cd "$DIR" 2>/dev/null && pwd -P) || _dir_real=''
    if [ -n "$_dir_real" ] && [ "$_dir_real" = "$REPOS_WORKSPACE" ]; then
        anotar_colision "$REPO" 'la ruta derivada apunta al workspace'
        continue
    fi

    _detalle=$(repo_presence_detail "$DIR")
    case "$_detalle" in
        presente)
            if ! repos_link_usable "$LINK"; then
                anotar_plan "$REPO" 'error' 'el catálogo no trae un enlace utilizable: no se pudo comprobar el remoto'
                continue
            fi
            case "$(repos_veredicto_remoto "$DIR" "$LINK")" in
                corresponde)
                    anotar_plan "$REPO" 'preexistente' ''
                    ;;
                'sin remotos')
                    anotar_colision "$REPO" 'la ruta es un repositorio git sin remotos configurados'
                    ;;
                ilegible)
                    anotar_plan "$REPO" 'error' 'no se pudo leer la configuración de remotos del clon'
                    ;;
                *)
                    anotar_colision "$REPO" 'la ruta es un repositorio git cuyo remoto no corresponde al del catálogo'
                    ;;
            esac
            ;;
        'ausente: ruta inexistente')
            if repos_link_usable "$LINK"; then
                anotar_plan "$REPO" 'clonar' ''
                A_CLONAR=$((A_CLONAR + 1))
            else
                anotar_plan "$REPO" 'error' 'el catálogo no trae un enlace de clonado utilizable'
            fi
            ;;
        'ausente: ruta ocupada por algo que no es un repositorio git')
            anotar_colision "$REPO" 'la ruta existe y no es un repositorio git'
            ;;
        *)
            anotar_colision "$REPO" 'la ruta existe y no es la raíz de su propio repositorio'
            ;;
    esac
done <<_FIN_INSPECCION
$REPOS_SELECCION
_FIN_INSPECCION

# -----------------------------------------------------------------------------
# Encabezado del reporte (contrato workspace-status-report.md)
# -----------------------------------------------------------------------------
#
# Se imprime también cuando la corrida se detiene por colisión. Un reporte que no
# dice sobre qué directorio operó no es verificable, y eso vale igual para el
# reporte de una corrida que no clonó nada.

printf 'Espacio de trabajo — %s\n' "$(date '+%d-%m-%Y %H:%M')"
printf 'Raíz: %s   (fuente: %s)\n' "$REPOS_ROOT" "$REPOS_ROOT_ORIGEN"
printf 'Catálogo: %s repositorios | Operación: preparar\n' "$REPOS_TOTAL_FILAS"
printf 'Archivo del catálogo: %s   (fuente: %s)\n' "$REPOS_CATALOG" "$REPOS_CATALOG_ORIGEN"
if [ -n "$SOLO" ]; then
    printf 'Selección: %s repositorios (--only)\n' "$REPOS_SELECCIONADOS"
fi
if [ "$DRY_RUN" -eq 1 ]; then
    printf '%s\n' 'Modo: --dry-run. No se clona nada; las columnas de estado sí se leen del repositorio.'
fi
printf '\n'

# -----------------------------------------------------------------------------
# Detención por colisión — antes de crear nada
# -----------------------------------------------------------------------------

if [ -n "$COLISIONES" ]; then
    printf '%s\n' 'La preparación se detuvo antes de crear nada. Rutas destino ocupadas:'
    printf '\n'
    while IFS="$REPOS_TAB" read -r _c_repo _c_motivo; do
        [ -n "$_c_repo" ] || continue
        printf '  %s — %s\n' "$_c_repo" "$_c_motivo"
        printf '    ruta: %s\n' "$REPOS_ROOT/$_c_repo"
    done <<_FIN_COLISIONES
$COLISIONES
_FIN_COLISIONES
    printf '\n'
    printf '%s\n' '0 repositorios clonados. Ninguna ruta se creó, se borró ni se modificó.'
    printf '%s\n' 'Qué revisar: que la raíz de clones sea la correcta, y qué ocupa cada ruta nombrada.'
    printf '%s\n' 'Para preparar solo los repositorios sin conflicto: --only <nombre>, repetible.'
    printf '\n'

    repos_error 'la raíz de clones tiene rutas destino ocupadas por algo que no es el clon esperado.'
    repos_error 'nada se clonó. Los nombres y sus motivos están en el reporte de arriba.'
    exit 1
fi

# -----------------------------------------------------------------------------
# Precondición de escritura, solo si hay algo que clonar
# -----------------------------------------------------------------------------
#
# Se comprueba después de la inspección y antes del primer clonado: una raíz no
# escribible haría fallar todos los clonados uno por uno, y ese es un error de
# precondición disfrazado de un error por repositorio.

if [ "$A_CLONAR" -gt 0 ] && [ "$DRY_RUN" -eq 0 ] && [ ! -w "$REPOS_ROOT" ]; then
    repos_error "la raíz de clones no admite escritura: $REPOS_ROOT"
    repos_error 'nada se clonó.'
    exit 1
fi

# -----------------------------------------------------------------------------
# Clonado y tabla por repositorio
# -----------------------------------------------------------------------------

printf '| '
repos_rellenar 'Repositorio' "$REPOS_ANCHO"
printf ' | Presencia | Rama | Limpieza | Respecto del remoto | Resultado |\n'
printf '| '
repos_rellenar '---' "$REPOS_ANCHO"
printf ' | --- | --- | --- | --- | --- |\n'

DISPONIBLES=0
CLONADOS=0
HUBO_ERROR=0
SALTADOS=''
ERRORES=''
DETALLES=''

while IFS="$REPOS_TAB" read -r REPO ACCION MOTIVO; do
    [ -n "$REPO" ] || continue

    DIR="$REPOS_ROOT/$REPO"
    RESULTADO=''

    case "$ACCION" in
        preexistente)
            RESULTADO='sin cambios'
            ;;
        error)
            RESULTADO="error: $MOTIVO"
            ;;
        clonar)
            if [ "$DRY_RUN" -eq 1 ]; then
                RESULTADO='sin cambios'
                DETALLES="${DETALLES}  ${REPO}
      clonaría en ${DIR}
"
            else
                # El clonado corre desde la raíz, con el nombre del directorio
                # derivado del nombre del repositorio sin transformar (contrato
                # de reporte, regla 7). El `--` separa opciones de operandos: la
                # URL viene del catálogo y no se deja interpretar como bandera.
                _cl_link=$(repos_link_of "$REPO")
                _cl_rc=0
                repo_git "$REPOS_ROOT" clone -- "$_cl_link" "$REPO" >/dev/null 2>&1 || _cl_rc=$?
                if [ "$_cl_rc" -ne 0 ]; then
                    RESULTADO="error: git clone terminó con código $_cl_rc"
                elif [ "$(repo_presence "$DIR")" != 'presente' ]; then
                    # El acuse no basta: la regla 1 del contrato exige leer el
                    # repositorio real después de operar.
                    RESULTADO='error: git clone informó éxito y la ruta no quedó como repositorio'
                else
                    RESULTADO='clonado'
                    CLONADOS=$((CLONADOS + 1))
                fi
            fi
            ;;
        *)
            RESULTADO="error: acción de plan desconocida: $ACCION"
            ;;
    esac

    # Regla 1 del contrato: todo campo se lee del repositorio real DESPUÉS de
    # operar, nunca del acuse del comando.
    PRESENCIA=$(repo_presence "$DIR")
    RAMA=''
    LIMPIEZA=''
    REMOTO=''
    if [ "$PRESENCIA" = 'presente' ]; then
        DISPONIBLES=$((DISPONIBLES + 1))
        RAMA=$(repo_branch "$DIR")
        LIMPIEZA=$(repo_cleanliness "$DIR")
        REMOTO=$(repo_upstream_status "$DIR")
    fi

    # Vocabulario cerrado: la celda vacía no pertenece al contrato para Limpieza
    # ni para Respecto del remoto. Misma corrección que en run-across-repos.sh.
    [ -n "$LIMPIEZA" ] || LIMPIEZA='no aplica'
    [ -n "$REMOTO" ] || REMOTO='no aplica'

    printf '| '
    repos_rellenar "$REPO" "$REPOS_ANCHO"
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
done <<_FIN_PLAN
$PLAN
_FIN_PLAN

if [ -n "$DETALLES" ]; then
    printf '\n'
    printf '%s\n' 'Detalle — qué se clonaría:'
    printf '%s' "$DETALLES"
fi

# -----------------------------------------------------------------------------
# Cierre (contrato workspace-status-report.md)
# -----------------------------------------------------------------------------
#
# La cifra del cierre cuenta PRESENCIA, no operaciones: es la forma que el
# contrato fija para preparar y estado. Los clonados de esta corrida se dicen
# aparte, porque `clonado` y `sin cambios` son resultados distintos y el reporte
# tiene que distinguirlos.

printf '\n'
printf '%s de %s repositorios disponibles.\n' "$DISPONIBLES" "$REPOS_SELECCIONADOS"
printf 'Clonados en esta corrida: %s. Preexistentes: los demás disponibles.\n' "$CLONADOS"

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

if [ "$REPOS_TOTAL_FILAS" -ne "$REPOS_SELECCIONADOS" ]; then
    printf '%s\n' "Recorrido acotado: el catálogo declara $REPOS_TOTAL_FILAS filas y esta corrida cubrió $REPOS_SELECCIONADOS repositorios."
fi

# La regla 4 del contrato prohíbe declarar completo un conjunto donde algo falló.
if [ "$HUBO_ERROR" -eq 1 ]; then
    exit 2
fi

exit 0
