#!/bin/sh
# check-workspace-dirs.sh — detector de deriva entre el catálogo de la skill y los
# directorios de lectura del agente enumerados en `.claude/settings.json`.
# Skill: development-repositories. Portado del workspace de origen; réplica
# declarada de la portación, 07-09-2026 (feature 002-portar-agentes, traza en
# specs/002-portar-agentes/).
#
# Origen: automatización propuesta en el workspace de origen. Decisión que lo
# hace necesario: enumerar los directorios de lectura uno por uno en vez de
# conceder la raíz de clones entera (layout.md §8 de la skill).
# Forma de la configuración y códigos de salida: layout.md §7 y §8 de la skill.
#
# -----------------------------------------------------------------------------
# Qué problema existe, y por qué un detector
# -----------------------------------------------------------------------------
#
# La skill decidió enumerar uno por uno los directorios que el agente puede leer,
# en vez de conceder la raíz de clones entera (layout.md §8). Es menor privilegio,
# y su costo quedó aceptado por escrito: la enumeración es una réplica del
# catálogo dentro de la configuración, y nada la sincroniza sola.
#
# El modo de fallo de esa réplica es el peor de los posibles. Cuando el catálogo
# suma un repositorio y la configuración queda corta, el agente informa que no
# encuentra un archivo que sí existe, y la causa no aparece por ninguna parte.
# Este script hace visible esa brecha antes de que alguien la sufra.
#
# -----------------------------------------------------------------------------
# COMPARA Y NO REPONE
# -----------------------------------------------------------------------------
#
# No escribe en `.claude/settings.json`, no agrega entradas, no borra ninguna y
# no imprime un bloque JSON listo para pegar. Ampliar el alcance de lectura de un
# agente es decisión de una persona, y un bloque que solo hay que pegar traslada
# esa decisión a un paso mecánico. Lo que sí imprime son las rutas exactas de
# ambos lados, que es lo que hace falta para decidir con el dato a la vista.
#
# -----------------------------------------------------------------------------
# SU EJECUCIÓN ES MANUAL
# -----------------------------------------------------------------------------
#
# En este repositorio no hay integración continua ni gancho que lo dispare: se
# corre a mano, cuando alguien toca el catálogo o la configuración. La ausencia
# se declara acá en vez de suponerse cubierta, por el mismo argumento con que la
# declararon los detectores de otras skills en el workspace de origen. Un
# detector que nadie corre protege tanto como ninguno, con la diferencia de que
# uno de los dos parece seguro.
#
# -----------------------------------------------------------------------------
# Dependencia declarada: python3
# -----------------------------------------------------------------------------
#
# El JSON de la configuración se parsea con `python3`, no con `grep` ni con `sed`.
# Un parseo por texto sobre JSON acierta con el archivo de hoy y falla en silencio
# ante un formato equivalente —la misma clave en una línea, un comentario, un
# escape— devolviendo cero entradas, que es indistinguible de una clave vacía.
#
# `jq` no se usa porque no es parte de una instalación base de macOS ni de la
# mayoría de las imágenes de Linux, y `python3` sí está en el entorno de trabajo
# de esta skill. La presencia se COMPRUEBA antes de comparar nada: si falta, el
# script sale con el código de precondición y lo dice, en vez de reportar cero.
#
# -----------------------------------------------------------------------------
# Este script no invoca git, y por eso no incluye lib-repo-state.sh
# -----------------------------------------------------------------------------
#
# Compara dos listas de texto —los nombres del catálogo y las rutas de la
# configuración— y no lee el estado de ningún repositorio: ni presencia, ni rama,
# ni limpieza. Incluir la biblioteca compartida sin usar ninguna de sus funciones
# sería dependencia muerta. La regla de la skill de invocar git solo a través de
# `repo_git` se cumple acá porque no hay ninguna invocación de git que hacer.
#
# Consecuencia deliberada: este detector NO dice si un repositorio está clonado.
# Un directorio enumerado y presente en el catálogo se reporta conforme aunque el
# clon todavía no exista, porque la enumeración es un permiso y no un clon. El
# estado de los clones lo reporta `run-across-repos.sh status`.
#
# -----------------------------------------------------------------------------
# Códigos de salida, y por qué la deriva devuelve 2
# -----------------------------------------------------------------------------
#
#   0   La comparación corrió y no hay deriva en ninguna de las dos direcciones.
#   1   Error de uso o de precondición: NADA se comparó.
#   2   La comparación corrió y encontró deriva, o la clave no existe.
#
# La deriva NO es un error de este script: el script hizo su trabajo, y lo que
# está mal es la configuración que inspeccionó. El `1` ya está tomado por el caso
# en que nada se ejecutó, de modo que devolver `1` mezclaría "no pude comparar"
# con "comparé y encontré algo", que son estados opuestos para quien encadene
# este script sin leer su salida. El `2` de layout.md §7 es exactamente ese
# lugar: la corrida completó y al menos un repositorio quedó en un estado que
# alguien tiene que atender.
#
# La clave ausente también devuelve `2`, y se reporta como su propio caso con su
# propio bloque. No es una comparación con cero derivas: es una comparación que
# no tuvo contra qué contrastar el catálogo, y un cero sin causa declarada es
# indistinguible de un detector que no corrió.
#
# -----------------------------------------------------------------------------
# Límites de la comparación, dichos antes de que alguien los descubra
# -----------------------------------------------------------------------------
#
# 1. UNA ENTRADA RELATIVA SE RESUELVE CONTRA LA RAÍZ DEL WORKSPACE. Es la base
#    que documenta layout.md §8: el directorio desde el cual se ejecuta `claude`.
#    Si alguien lanza la sesión desde otro directorio, esas mismas entradas
#    apuntan a otra parte y este detector no tiene cómo saberlo.
# 2. LA NORMALIZACIÓN DE RUTAS ES LÉXICA cuando el directorio todavía no existe:
#    resuelve `.`, `..` y `~`, y no resuelve enlaces simbólicos, porque un enlace
#    de una ruta inexistente no se puede resolver. Cuando el directorio sí
#    existe, se compara además su forma con enlaces resueltos.
# 3. NO COMPRUEBA QUE EL PERMISO FUNCIONE. Verifica que la ruta esté enumerada,
#    no que el agente efectivamente pueda leer ahí. Formas alternativas de la
#    clave —patrones glob, por ejemplo— quedaron sin verificar en layout.md §8 y
#    este script no las interpreta: una entrada así se reportaría como sobrante.
# 4. NO CONTRASTA CONTRA LA FUENTE EXTERNA. El catálogo es su única referencia;
#    si el catálogo está caduco, la comparación hereda esa caducidad. Contrastar
#    el catálogo contra su fuente es el modo `sincronizar` de la skill.

set -eu

# -----------------------------------------------------------------------------
# Constantes
# -----------------------------------------------------------------------------

# Nombre del workspace. Nunca es objetivo de la skill y nunca debe estar
# enumerado: concederlo por una segunda ruta es justamente lo que la skill
# evitó al no conceder la raíz entera (layout.md §8). Valor por proyecto: se
# fija al adoptar la skill (`Pendiente de configurar`). El centinela de la
# plantilla no coincide con ningún nombre real; si el catálogo llegara a listar
# el workspace antes de configurarlo, la deriva se reporta en vez de excluirse
# en silencio.
WORKSPACE_NOMBRE='Pendiente-de-configurar'

# Ruta del catálogo relativa al directorio de la skill, cuando no se indica otra.
CATALOGO_POR_DEFECTO='repositories.md'

# Configuración inspeccionada, relativa a la raíz del workspace.
SETTINGS_POR_DEFECTO='.claude/settings.json'

# Clave que se inspecciona. Hallazgo replicado en layout.md §8 de la skill
# (arreglo de cadenas, uniqueItems según el esquema declarado en el `$schema`
# de `.claude/settings.json`); réplica declarada de la portación, 07-09-2026
# (feature 002-portar-agentes).
CLAVE='permissions.additionalDirectories'

TAB=$(printf '\t')

# -----------------------------------------------------------------------------
# Estado global
# -----------------------------------------------------------------------------

CATALOGO=''
CATALOGO_ORIGEN='default'
SETTINGS=''
SETTINGS_ORIGEN='default'
RAIZ=''
RAIZ_ORIGEN=''
WORKSPACE=''

TOTAL_FILAS=0
NOMBRES=''
NOMBRES_OK=0
EXCLUIDAS=0

ESTADO_CLAVE=''
ENTRADAS=''
TOTAL_ENTRADAS=0

FALTANTES=''
N_FALTANTES=0
SOBRANTES=''
N_SOBRANTES=0
CONFORMES=0

ANCHO_REPO=11
ANCHO_ENTRADA=7

# -----------------------------------------------------------------------------
# Salida
# -----------------------------------------------------------------------------

error() {
    printf 'ERROR: %s\n' "$1" >&2
}

avisar() {
    printf 'AVISO: %s\n' "$1" >&2
}

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
check-workspace-dirs.sh — detecta la deriva entre el catálogo de repositorios y
los directorios de lectura del agente enumerados en la configuración.

USO
    check-workspace-dirs.sh [opciones]
    check-workspace-dirs.sh --help

QUÉ COMPARA, EN LAS DOS DIRECCIONES
    1. Repositorios del catálogo cuyo directorio NO está enumerado en
       permissions.additionalDirectories. Es la dirección que produce el fallo
       silencioso: el agente dice que no encuentra un archivo que sí existe.
    2. Entradas enumeradas que NO corresponden a ningún repositorio del catálogo.
       Es alcance concedido de más, que nadie vuelve a mirar.

COMPARA Y NO REPONE
    No escribe en la configuración, no agrega entradas, no borra ninguna y no
    imprime un bloque JSON listo para pegar. Ampliar el alcance de lectura de un
    agente es decisión de una persona.

EJECUCIÓN MANUAL
    Ningún gancho ni integración continua dispara este detector en este
    repositorio. Se corre a mano, cuando alguien toca el catálogo o la
    configuración.

OPCIONES
    --catalog <ruta>    Catálogo a comparar. Precede a REPOS_CATALOG.
    --settings <ruta>   Archivo de configuración a inspeccionar. Por defecto,
                        .claude/settings.json de la raíz del workspace.
    --root <ruta>       Raíz de clones. Precede a REPOS_ROOT.
    --help, -h          Imprime este texto y sale 0.

VARIABLES DE ENTORNO
    REPOS_ROOT          Raíz de clones. Por defecto, el directorio padre del
                        workspace. La raíz resuelta se imprime en el encabezado,
                        como ruta y nunca como nombre de variable.
    REPOS_CATALOG       Catálogo a usar. Por defecto, repositories.md de la skill.

DEPENDENCIA
    python3, para parsear el JSON de la configuración. Su presencia se comprueba
    antes de comparar nada; si falta, el script sale 1 y lo dice.

CÓDIGOS DE SALIDA
    0   La comparación corrió y no hay deriva en ninguna de las dos direcciones.
    1   Error de uso o de precondición: NADA se comparó.
    2   La comparación corrió y encontró deriva, o la clave no existe.

    La deriva no es un error de este script: el script hizo su trabajo y lo que
    está mal es la configuración que inspeccionó. Por eso devuelve 2 y no 1: el 1
    significa que nada se comparó, y mezclarlos volvería indistinguible "no pude
    comparar" de "comparé y encontré algo".

    Los errores van a stderr con el prefijo `ERROR: `; los avisos, con `AVISO: `,
    y no alteran el código de salida.
FIN_USO
}

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
        --catalog)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error '--catalog requiere una ruta.'
                exit 1
            fi
            CATALOGO="$2"
            CATALOGO_ORIGEN='--catalog'
            shift 2
            ;;
        --settings)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error '--settings requiere una ruta.'
                exit 1
            fi
            SETTINGS="$2"
            SETTINGS_ORIGEN='--settings'
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
# Precondiciones — todas antes de comparar nada
# -----------------------------------------------------------------------------

# 1. python3 presente. Sin él no hay parseo de JSON conforme, y un parseo por
#    texto devolvería un cero que parecería una configuración limpia.
if ! command -v python3 >/dev/null 2>&1; then
    error 'python3 no está disponible en el PATH, y este detector lo necesita para parsear el JSON de la configuración.'
    error 'nada se comparó: un cero acá sería indistinguible de una configuración sin deriva.'
    exit 1
fi

# 2. Directorio del script y raíz del workspace. El script vive en
#    .claude/skills/development-repositories/scripts/, cuatro niveles bajo
#    la raíz del workspace.
DIR_SCRIPT=''
DIR_SCRIPT=$(cd "$(dirname "$0")" 2>/dev/null && pwd -P) || DIR_SCRIPT=''
if [ -z "$DIR_SCRIPT" ]; then
    error 'no se pudo resolver el directorio de este script.'
    exit 1
fi

WORKSPACE=$(cd "$DIR_SCRIPT/../../../.." 2>/dev/null && pwd -P) || WORKSPACE=''
if [ -z "$WORKSPACE" ]; then
    error 'no se pudo resolver la raíz del workspace desde la ubicación del script.'
    exit 1
fi
# La lectura del catálogo se consume de la biblioteca compartida. En el
# workspace de origen este script tuvo su propia copia, con el bloque awk que
# acota el barrido a la sección 1 duplicado byte a byte: dos lecturas del mismo
# catálogo divergen en silencio, que es la regla 09 del repositorio aplicada a
# código y el mismo argumento con que update-workspace.sh y workspace-status.sh
# se hicieron envoltorios en vez de implementaciones propias.
. "$DIR_SCRIPT/lib-repo-state.sh"
. "$DIR_SCRIPT/lib-repo-set.sh"


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
#    Acá no se clona nada, pero una raíz apuntada hacia adentro produciría
#    directorios esperados que ningún clon puede ocupar, y la comparación
#    reportaría una deriva inventada por cada repositorio del catálogo.
case "$RAIZ" in
    "$WORKSPACE"|"$WORKSPACE"/*)
        error "la raíz de clones resuelta cae dentro del árbol del workspace: $RAIZ"
        error "el workspace es $WORKSPACE. Los clones son sus hermanos, nunca sus hijos."
        exit 1
        ;;
esac

# 5. Catálogo legible. Orden: --catalog, REPOS_CATALOG, repositories.md.
if [ -z "$CATALOGO" ]; then
    if [ -n "${REPOS_CATALOG:-}" ]; then
        CATALOGO="$REPOS_CATALOG"
        CATALOGO_ORIGEN='REPOS_CATALOG'
    else
        CATALOGO="$DIR_SCRIPT/../$CATALOGO_POR_DEFECTO"
        CATALOGO_ORIGEN='default'
    fi
fi

if [ ! -f "$CATALOGO" ] || [ ! -r "$CATALOGO" ]; then
    error "el catálogo no existe o no es legible: $CATALOGO"
    exit 1
fi

_cat_dir=''
_cat_dir=$(cd "$(dirname "$CATALOGO")" 2>/dev/null && pwd -P) || _cat_dir=''
if [ -n "$_cat_dir" ]; then
    CATALOGO="$_cat_dir/$(basename "$CATALOGO")"
fi

# 6. Configuración legible. Que el archivo falte es precondición, no deriva: sin
#    archivo no hay enumeración que contrastar, y decir "cero entradas" sería
#    afirmar algo que no se leyó.
if [ -z "$SETTINGS" ]; then
    SETTINGS="$WORKSPACE/$SETTINGS_POR_DEFECTO"
    SETTINGS_ORIGEN='default'
fi

if [ ! -f "$SETTINGS" ] || [ ! -r "$SETTINGS" ]; then
    error "el archivo de configuración no existe o no es legible: $SETTINGS"
    exit 1
fi

_set_dir=''
_set_dir=$(cd "$(dirname "$SETTINGS")" 2>/dev/null && pwd -P) || _set_dir=''
if [ -n "$_set_dir" ]; then
    SETTINGS="$_set_dir/$(basename "$SETTINGS")"
fi

# -----------------------------------------------------------------------------
# Parseo del catálogo
# -----------------------------------------------------------------------------
#
# Mismo criterio que run-across-repos.sh: el total se cuenta de las FILAS y los
# nombres se extraen de esas mismas filas por un camino distinto. Si ambas cifras
# salieran del mismo parseo, una fila descartada sería indetectable y el reporte
# quedaría internamente consistente con un repositorio de menos.

_filas=''
_filas=$(repos_filas "$CATALOGO") || _filas=''

while IFS= read -r _linea; do
    [ -n "$_linea" ] || continue

    _celda=$(printf '%s' "$_linea" | sed -e 's/^[[:space:]]*|//' -e 's/|.*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [ -n "$_celda" ] || continue
    [ "$_celda" != 'Repositorio' ] || continue

    # Separador de la tabla: solo guiones, dos puntos y espacios.
    _resto=$(printf '%s' "$_celda" | tr -d '\-: ')
    [ -n "$_resto" ] || continue

    TOTAL_FILAS=$((TOTAL_FILAS + 1))

    if [ "$_celda" = "$WORKSPACE_NOMBRE" ]; then
        avisar "el catálogo contiene $WORKSPACE_NOMBRE; se excluye por nombre y no se compara."
        EXCLUIDAS=$((EXCLUIDAS + 1))
        continue
    fi

    case "$_celda" in
        *[!A-Za-z0-9._-]*|.|..)
            avisar "fila del catálogo con un nombre no utilizable como directorio: $_celda"
            continue
            ;;
    esac

    NOMBRES="${NOMBRES}${_celda}
"
    NOMBRES_OK=$((NOMBRES_OK + 1))

    _largo=${#_celda}
    if [ "$_largo" -gt "$ANCHO_REPO" ]; then
        ANCHO_REPO="$_largo"
    fi
done <<_FIN_FILAS
$_filas
_FIN_FILAS

if [ "$TOTAL_FILAS" -eq 0 ]; then
    error "el catálogo no tiene filas de datos en su sección 1: $CATALOGO"
    error 'un cero acá es catálogo vacío o parseo que no resolvió, y son indistinguibles: no se sigue.'
    exit 1
fi

_perdidas=$((TOTAL_FILAS - NOMBRES_OK - EXCLUIDAS))
if [ "$_perdidas" -gt 0 ]; then
    avisar "descuadre de parseo del catálogo — filas de datos: $TOTAL_FILAS; nombres comparables: $NOMBRES_OK; exclusiones por nombre: $EXCLUIDAS; fuera de la comparación: $_perdidas."
fi

if [ "$NOMBRES_OK" -eq 0 ]; then
    error 'ninguna fila del catálogo produjo un nombre comparable.'
    exit 1
fi

# -----------------------------------------------------------------------------
# Lectura de la configuración
# -----------------------------------------------------------------------------
#
# El programa de python3 imprime una línea `ESTADO` y, cuando la clave existe,
# una línea `ENTRADA` por elemento con tres campos separados por tabulador: el
# valor literal, su forma normalizada de manera léxica, y su forma con enlaces
# simbólicos resueltos cuando el directorio ya existe. Cualquier configuración
# que no se pueda interpretar sale con código 3 y aborta la comparación: es
# precondición, no deriva.

_salida=''
_rc_py=0
_salida=$(python3 - "$SETTINGS" "$WORKSPACE" <<'FIN_PY'
import json
import os
import sys

ruta = sys.argv[1]
base = sys.argv[2]


def emitir(texto):
    # Se escribe en bytes UTF-8 para no depender de la configuración regional
    # del entorno: una ruta con acentos no debe romper el detector.
    sys.stdout.buffer.write((texto + "\n").encode("utf-8"))


def abortar(mensaje):
    sys.stderr.write(mensaje + "\n")
    sys.exit(3)


try:
    with open(ruta, "r", encoding="utf-8") as manejador:
        datos = json.load(manejador)
except OSError as excepcion:
    abortar("no se pudo leer el archivo: %s" % excepcion)
except ValueError as excepcion:
    abortar("el archivo no es JSON valido: %s" % excepcion)

if not isinstance(datos, dict):
    abortar("el contenido de nivel superior no es un objeto JSON")

if "permissions" not in datos:
    emitir("ESTADO\tsin-clave")
    sys.exit(0)

permisos = datos["permissions"]
if not isinstance(permisos, dict):
    abortar("permissions existe y no es un objeto JSON")

if "additionalDirectories" not in permisos:
    emitir("ESTADO\tsin-clave")
    sys.exit(0)

entradas = permisos["additionalDirectories"]
if not isinstance(entradas, list):
    abortar("permissions.additionalDirectories existe y no es un arreglo")

emitir("ESTADO\tcon-clave")

for elemento in entradas:
    if not isinstance(elemento, str):
        abortar("permissions.additionalDirectories contiene un elemento que no es una cadena")
    if elemento == "":
        abortar("permissions.additionalDirectories contiene una cadena vacia")
    if "\t" in elemento or "\n" in elemento or "\r" in elemento:
        abortar("permissions.additionalDirectories contiene una entrada con tabulador o salto de linea")

    expandida = os.path.expanduser(elemento)
    if not os.path.isabs(expandida):
        expandida = os.path.join(base, expandida)
    lexica = os.path.normpath(expandida)

    # Los enlaces simbolicos solo se resuelven cuando la ruta ya existe. Una ruta
    # inexistente no tiene enlace que resolver, y forzar realpath devolveria una
    # forma que no corresponde a nada.
    if os.path.exists(lexica):
        fisica = os.path.realpath(lexica)
    else:
        fisica = lexica

    emitir("ENTRADA\t%s\t%s\t%s" % (elemento, lexica, fisica))
FIN_PY
) || _rc_py=$?

if [ "$_rc_py" -ne 0 ]; then
    error "no se pudo interpretar la clave $CLAVE de $SETTINGS (python3 terminó con código $_rc_py)."
    error 'nada se comparó: una configuración que no se puede leer no es una configuración sin deriva.'
    exit 1
fi

while IFS="$TAB" read -r _tipo _c2 _c3 _c4; do
    case "${_tipo:-}" in
        ESTADO)
            ESTADO_CLAVE="$_c2"
            ;;
        ENTRADA)
            ENTRADAS="${ENTRADAS}${_c2}${TAB}${_c3}${TAB}${_c4}
"
            TOTAL_ENTRADAS=$((TOTAL_ENTRADAS + 1))
            _largo=${#_c2}
            if [ "$_largo" -gt "$ANCHO_ENTRADA" ]; then
                ANCHO_ENTRADA="$_largo"
            fi
            ;;
    esac
done <<_FIN_SALIDA
$_salida
_FIN_SALIDA

if [ -z "$ESTADO_CLAVE" ]; then
    error "la lectura de $SETTINGS no declaró estado de la clave $CLAVE."
    error 'nada se comparó.'
    exit 1
fi

# Duplicados: el esquema declara uniqueItems, de modo que dos entradas que
# resuelven a la misma ruta son señal de edición a mano. Se avisa y no se altera
# el código de salida, porque conceder dos veces lo mismo no amplía el alcance.
_dups=''
_dups=$(printf '%s' "$ENTRADAS" | awk -F'\t' 'NF >= 2 && $2 != "" { c[$2]++ } END { for (r in c) if (c[r] > 1) print r }') || _dups=''
while IFS= read -r _dup; do
    [ -n "$_dup" ] || continue
    avisar "entrada repetida en $CLAVE: $_dup"
done <<_FIN_DUPS
$_dups
_FIN_DUPS

# -----------------------------------------------------------------------------
# Dirección 1 — repositorios del catálogo que no están enumerados
# -----------------------------------------------------------------------------

while IFS= read -r _repo; do
    [ -n "$_repo" ] || continue

    _esperado="$RAIZ/$_repo"
    _hallado=0

    while IFS="$TAB" read -r _raw _lex _fis; do
        [ -n "${_raw:-}" ] || continue
        if [ "${_lex:-}" = "$_esperado" ] || [ "${_fis:-}" = "$_esperado" ]; then
            _hallado=1
        fi
    done <<_FIN_E1
$ENTRADAS
_FIN_E1

    if [ "$_hallado" -eq 1 ]; then
        CONFORMES=$((CONFORMES + 1))
    else
        FALTANTES="${FALTANTES}${_repo}${TAB}${_esperado}
"
        N_FALTANTES=$((N_FALTANTES + 1))
    fi
done <<_FIN_REPOS
$NOMBRES
_FIN_REPOS

# -----------------------------------------------------------------------------
# Dirección 2 — entradas enumeradas sin respaldo en el catálogo
# -----------------------------------------------------------------------------
#
# Se recorre por separado, no marcando las entradas que la dirección 1 usó. Dos
# recorridos independientes sobre las mismas dos listas hacen que un descuadre se
# note; un recorrido con estado compartido lo escondería.

while IFS="$TAB" read -r _raw _lex _fis; do
    [ -n "${_raw:-}" ] || continue

    _hallado=0
    while IFS= read -r _repo; do
        [ -n "$_repo" ] || continue
        _esperado="$RAIZ/$_repo"
        if [ "${_lex:-}" = "$_esperado" ] || [ "${_fis:-}" = "$_esperado" ]; then
            _hallado=1
        fi
    done <<_FIN_R2
$NOMBRES
_FIN_R2

    [ "$_hallado" -eq 0 ] || continue

    # El motivo se nombra, porque no todas las sobras pesan lo mismo. Una entrada
    # que alcanza el workspace concede por una segunda ruta justamente lo que la
    # skill evitó al no conceder la raíz entera (layout.md §8).
    case "${_lex:-}" in
        "$WORKSPACE")
            _motivo='apunta al workspace, que nunca se enumera'
            ;;
        "$WORKSPACE"/*)
            _motivo='cae dentro del árbol del workspace'
            ;;
        "$RAIZ")
            _motivo='concede la raíz de clones entera, no un repositorio'
            ;;
        *)
            _motivo='no corresponde a ningún repositorio del catálogo'
            ;;
    esac

    SOBRANTES="${SOBRANTES}${_raw}${TAB}${_lex}${TAB}${_motivo}
"
    N_SOBRANTES=$((N_SOBRANTES + 1))
done <<_FIN_E2
$ENTRADAS
_FIN_E2

# -----------------------------------------------------------------------------
# Reporte
# -----------------------------------------------------------------------------

printf 'Deriva entre catálogo y directorios de lectura del agente — %s\n' "$(date '+%d-%m-%Y %H:%M')"
printf 'Workspace: %s\n' "$WORKSPACE"
printf 'Raíz de clones: %s   (fuente: %s)\n' "$RAIZ" "$RAIZ_ORIGEN"
printf 'Archivo del catálogo: %s   (fuente: %s)\n' "$CATALOGO" "$CATALOGO_ORIGEN"
printf 'Configuración inspeccionada: %s   (fuente: %s)\n' "$SETTINGS" "$SETTINGS_ORIGEN"
printf 'Clave: %s\n' "$CLAVE"
printf 'Catálogo: %s repositorios comparables | Enumeradas: %s entradas\n' "$NOMBRES_OK" "$TOTAL_ENTRADAS"
printf '\n'

if [ "$ESTADO_CLAVE" = 'sin-clave' ]; then
    printf '%s\n' '## La clave no existe en la configuración'
    printf '\n'
    printf 'La clave %s no está en %s.\n' "$CLAVE" "$SETTINGS"
    printf '%s\n' 'Este resultado NO es una comparación con cero derivas: es una comparación que no'
    printf '%s\n' 'tuvo contra qué contrastar el catálogo. Los repositorios de abajo quedan todos sin'
    printf '%s\n' 'enumerar, y el agente no puede leer ninguno.'
    printf '\n'
fi

printf '%s\n' '## Repositorios del catálogo sin enumerar'
printf '\n'
if [ "$N_FALTANTES" -eq 0 ]; then
    printf '%s\n' 'Ninguno.'
else
    printf '| '
    rellenar 'Repositorio' "$ANCHO_REPO"
    printf ' | Directorio esperado |\n'
    printf '| '
    rellenar '---' "$ANCHO_REPO"
    printf ' | --- |\n'
    while IFS="$TAB" read -r _repo _esperado; do
        [ -n "${_repo:-}" ] || continue
        printf '| '
        rellenar "$_repo" "$ANCHO_REPO"
        printf ' | %s |\n' "$_esperado"
    done <<_FIN_FALTANTES
$FALTANTES
_FIN_FALTANTES
fi
printf '\n'

printf '%s\n' '## Entradas enumeradas sin respaldo en el catálogo'
printf '\n'
if [ "$N_SOBRANTES" -eq 0 ]; then
    printf '%s\n' 'Ninguna.'
else
    printf '| '
    rellenar 'Entrada' "$ANCHO_ENTRADA"
    printf ' | Ruta resuelta | Motivo |\n'
    printf '| '
    rellenar '---' "$ANCHO_ENTRADA"
    printf ' | --- | --- |\n'
    while IFS="$TAB" read -r _raw _lex _motivo; do
        [ -n "${_raw:-}" ] || continue
        printf '| '
        rellenar "$_raw" "$ANCHO_ENTRADA"
        printf ' | %s | %s |\n' "$_lex" "$_motivo"
    done <<_FIN_SOBRANTES
$SOBRANTES
_FIN_SOBRANTES
fi
printf '\n'

printf '%s\n' '## Cierre'
printf '\n'
printf 'Filas del catálogo: %s | comparables: %s | excluidas por nombre: %s\n' "$TOTAL_FILAS" "$NOMBRES_OK" "$EXCLUIDAS"
printf 'Enumerados y en el catálogo: %s | sin enumerar: %s | enumeradas de más: %s\n' "$CONFORMES" "$N_FALTANTES" "$N_SOBRANTES"

if [ "$ESTADO_CLAVE" = 'sin-clave' ]; then
    printf 'Estado de la clave: ausente en %s\n' "$SETTINGS"
else
    printf '%s\n' 'Estado de la clave: presente'
fi

printf '%s\n' 'Este detector compara y no repone: no escribió nada en la configuración.'
printf '%s\n' 'Su ejecución es manual; ningún gancho ni integración continua lo dispara.'

if [ "$ESTADO_CLAVE" = 'sin-clave' ] || [ "$N_FALTANTES" -gt 0 ] || [ "$N_SOBRANTES" -gt 0 ]; then
    printf '%s\n' 'Veredicto: hay deriva. Corregirla es decisión de una persona sobre .claude/settings.json.'
    exit 2
fi

printf '%s\n' 'Veredicto: sin deriva en ninguna de las dos direcciones.'
exit 0
