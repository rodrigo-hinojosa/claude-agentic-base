#!/bin/sh
# workspace-status.sh — reporta el estado de los clones del catálogo de la skill
# development-repositories.
# Traza: réplica declarada de la portación, 07-09-2026 (feature 002-portar-agentes);
# ver specs/002-portar-agentes/.
#
# -----------------------------------------------------------------------------
# Es un envoltorio, no una implementación, y el motivo está registrado
# -----------------------------------------------------------------------------
#
# Todo lo que este archivo hace es invocar `run-across-repos.sh status` con los
# mismos argumentos que recibió. No lee estado, no parsea el catálogo, no decide
# nada.
#
# El diseño de origen lo deja escrito, y esta portación lo conserva: mantener
# este script como implementación separada dejaría dos lecturas del mismo estado
# —limpio, divergente, atrasado— divergiendo en silencio. Es la regla 09 del
# repositorio (`.claude/rules/09-punteros-y-replicas.md`) aplicada a código:
# cuando un dato lo consumen varios lugares, vive en uno y los demás lo citan.
# Una réplica queda falsa sin avisar; un puntero falla ruidosamente.
#
# El riesgo es concreto en este caso. El vocabulario de las columnas Limpieza y
# Respecto del remoto es cerrado y lo fija el ejecutor `run-across-repos.sh`,
# que es su única implementación; una segunda implementación podría clasificar
# el mismo repositorio distinto y ninguna de las dos salidas se vería
# equivocada.
#
# El nombre se conserva porque los artefactos previos de la skill lo nombran
# así. La decisión registrada en el diseño de origen: los nombres de estos
# scripts guardan la palabra "workspace" del vocabulario anterior, y lo que se
# corrigió fue su prosa y su salida, que hablan de raíz de clones.
#
# -----------------------------------------------------------------------------
# Qué hereda del ejecutor, y por lo tanto no se documenta acá
# -----------------------------------------------------------------------------
#
#   Opciones, variables de entorno y forma del reporte.
#   Códigos de salida: 0 corrida limpia, 1 error de precondición sin ejecutar
#   nada, 2 corrida completa con al menos un repositorio en error.
#   El tratamiento de un repositorio ausente, que se reporta como error y lleva
#   la corrida a código 2.
#
# `--help` y `-h` se atienden en el ejecutor y salen 0. El texto que imprimen es
# el de `run-across-repos.sh`, con el verbo ya fijado por este envoltorio: va
# dicho para que nadie lo lea como un desajuste.
#
# Reproducir cualquiera de esas cosas acá crearía la segunda copia que este
# archivo existe para evitar.

set -eu

# La ruta del ejecutor se resuelve relativa a este script, nunca contra el
# directorio de trabajo ni contra una ruta absoluta del entorno de una persona.
# Una ruta fija vuelve la skill inoperante en cualquier otro clon del
# repositorio; es un defecto ya observado y corregido en el workspace de origen.
DIR_SCRIPT=''
DIR_SCRIPT=$(cd "$(dirname "$0")" 2>/dev/null && pwd -P) || DIR_SCRIPT=''
if [ -z "$DIR_SCRIPT" ]; then
    printf 'ERROR: %s\n' 'no se pudo resolver el directorio de este script.' >&2
    exit 1
fi

EJECUTOR="$DIR_SCRIPT/run-across-repos.sh"
if [ ! -r "$EJECUTOR" ]; then
    printf 'ERROR: %s\n' "no se encuentra el ejecutor $EJECUTOR." >&2
    exit 1
fi

# `exec` reemplaza este proceso por el del ejecutor, de modo que su código de
# salida llega al invocador tal cual, sin traducción intermedia. Se usa `sh` de
# forma explícita para no depender del bit de ejecución del archivo.
exec sh "$EJECUTOR" status "$@"
