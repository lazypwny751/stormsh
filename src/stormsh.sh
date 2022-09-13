#!/bin/bash

#    Simple dependencity controller (configuration) tool for more like shell scripts - stormsh
#    Copyright (C) 2022  lazypwny751
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Requirements:
#   GNU CoreUtils.
#   GNU Awk language.
#   shtandard shell library manager.

# Define variables:
export i="" x="" status="true" version="1.0.0" tab="$(printf '\t')"
export CWD="${PWD}" POINTER=":" DO="configure" SHARED="/usr/share/stormsh" FILE="Stormfile" STORMSH_LIBDIR="/usr/local/lib/stormsh" 
export reqcmd=(
    "requiresh"
    "awk"
)

export reqfile=(
    "${SHARED}/regulator.awk"
    "${SHARED}/parser.awk"
)

# Define functions:
stormsh:parser() {
    local file="Stormfile" opt="use"

    while [[ "${#}" -gt 0 ]] ; do
        case "${1}" in
            --file|-f)
                shift
                if [[ -n "${1}" ]] ; then
                    local file="${1}"
                    shift
                fi
            ;;
            --opt|-o)
                shift
                if [[ -n "${1}" ]] ; then
                    local opt="${1}"
                    shift
                fi
            ;;
            *)
                shift
            ;;
        esac
    done

    if [[ -f "${file}" ]] ; then
        awk -v "opt=${opt}${POINTER}" -f "${SHARED}/parser.awk" "${file}" | awk -v "opt=${opt}" -f "${SHARED}/regulator.awk"
    else
        echo -e "\t${0##*/}: ${FUNCNAME##*:}: the file '${file}' not found.."
        return 1
    fi
}

# Check requirements:
for i in ${reqcmd[@]} ; do
    if ! command -v "${i}" &> /dev/null ; then
        echo -e "\t${0##*/}: command: ${i} not found."
        export status="false"
    fi
done

for i in ${reqfile[@]} ; do
    if ! [[ -f "${i}" ]] ; then
        echo -e "\t${0##*/}: file: ${i##*/} not found."
        export status="false"
    fi
done

if ! ${status} ; then
    echo "${0##*/}: that requirements are not met."
    exit 1
fi

# Parse parameters:
while [[ "${#}" -gt 0 ]] ; do
    case "${1}" in
        --[cC][oO][nN][fF][iI][gG][uU][rR][eE]|-[cC])
            shift
            export DO="configure"
        ;;
        --[fF][iI][lL][eE]|-[fF])
            shift
            if [[ -n "${1}" ]] ; then
                export FILE="${1}"
                shift
            fi
        ;;
        --[vV][eE][rR][sS][iI][oO][nN]|-[vV])
            shift
            export DO="version"
        ;;
        --[hH][eE][lL][pP]|-[hH])
            shift
            export DO="help"
        ;;
        *)
            shift
        ;;
    esac
done

# Processing of option:
case "${DO}" in
    configure)
        if [[ -f "${FILE}" ]] ; then
            export REQUIRESH_LIBDIR="$(requiresh --path):${STORMSH_LIBDIR}"
            stormsh:parser -f "${FILE}" -o "use"
        else
            echo -e "\t${0##*/}: file: ${FILE} not found.."
            exit 1
        fi
    ;;
    version)
        echo "${version}"
    ;;
    help)
        echo -e "There is X parameters for ${0##*/}:
"
    ;;
    *)
        echo "${0##*/}: there is no option like '${DO}'."
        exit 1
    ;;
esac