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

# Definitions:
set -e
shopt -s expand_aliases

# status, run, version, ROOT, PREFIX, DO, FILE, WORKSPACE, CWD, SRCDIR, STORMSH_LIBDIR
export status="true" run="true" version="2.0.0"
export ROOT="" PREFIX="/usr" DO="build" FILE="Stormfile" WORKSPACE="Stormdir"
export CWD="${PWD}" SRCDIR="${ROOT}${PREFIX}/share/stormsh"
if ! [[ -n "${STORMSH_LIBDIR}" ]] ; then
    export STORMSH_LIBDIR="${ROOT}${PREFIX}/local/lib/stormsh/${version%.*}:${ROOT}${PREFIX}/local/lib/bash-5.1.16"
fi

export STORMSH_REQUIRE=(
    "command:rm"
    "command:awk"
    "command:cat"
    "command:mkdir"
    "entity:${SRCDIR}/lexer.awk"
    "entity:${SRCDIR}/parser.awk"
)

# Regular Colors
reset='\033[0m'           # Text Reset
black='\033[0;30m'        # Black
red='\033[0;31m'          # Red
green='\033[0;32m'        # Green
yellow='\033[0;33m'       # Yellow
blue='\033[0;34m'         # Blue
purple='\033[0;35m'       # Purple
cyan='\033[0;36m'         # Cyan
white='\033[0;37m'        # White

# Bold
Bblack='\033[1;30m'       # Black
Bred='\033[1;31m'         # Red
Bgreen='\033[1;32m'       # Green
Byellow='\033[1;33m'      # Yellow
Bblue='\033[1;34m'        # Blue
Bpurple='\033[1;35m'      # Purple
Bcyan='\033[1;36m'        # Cyan
Bwhite='\033[1;37m'       # White

## Functions:
stormsh:requires() {
    # Requirement Resolver.
    local status="true"
    if [[ -n "${STORMSH_REQUIRE}" ]] ; then
        local i=""
        for i in "${STORMSH_REQUIRE[@]}" ; do
            case "${i%:*}" in
                command|[cC])
                    if ! command -v "${i#*:}" &> /dev/null ; then
                        echo "'${i#*:}' not found."
                        local status="false"
                    fi
                ;;
                entity|[eE])
                    if ! [[ -e "${i#*:}" ]] ; then
                        echo "'${i#*:}' doesn't exist."
                        local status="false"
                    fi
                ;;
                *)
                    echo "'${i#*:}' in unknown category: '${i%:*}'?."
                    local status="false"
                ;;
            esac
        done
    else
        echo "fatal: \${STORMSH_REQUIRE} isn't definied yet, please define the requirements."
        local status="false"
    fi

    if ! ${status} ; then
        return 1
    fi
}

stormsh:output() {
    local OPTARG=() SETMOD="success"
    while [[ "${#}" -gt 0 ]] ; do
        case "${1}" in
            --error|-e)
                shift
                local SETMOD="error"
            ;;
            --success|-s)
                shift
                local SETMOD="success"
            ;;
            --info|-i)
                shift
                local SETMOD="info"
            ;;
            --warning|-w)
                shift
                local SETMOD="warning"
            ;;
            *)
                local OPTARG+=("${1}")
                shift
            ;;
        esac
    done

    case "${SETMOD}" in
        error)
            echo -e "\t${Bred}${BASH_SOURCE[0]##*/}${reset}: ${Bred}error${reset}: ${OPTARG[@]}."
            return 1
        ;;
        success)
            echo -e "\t${Bgreen}${BASH_SOURCE[0]##*/}${reset}: ${Bgreen}success${reset}: ${OPTARG[@]}."
        ;;
        info)
            echo -e "\t${Bblue}${BASH_SOURCE[0]##*/}${reset}: ${Bblue}info${reset}: ${OPTARG[@]}."
        ;;
        warning)
            echo -e "\t${Byellow}${BASH_SOURCE[0]##*/}${reset}: ${Byellow}warning${reset}: ${OPTARG[@]}."
        ;;
        *)
            # Ayıp olmasın diye return edelim.
            return 2
        ;;
    esac
}

stormsh:realpath() {
    # emulate real path, this function can't show real path only theory.
    if [[ -n "${1}" ]] ; then
        if [[ "${1:0:1}" = "/" ]] ; then
            local CWD=""
        else
            local CWD="${PWD//\// }"
        fi

        local realpath="${1//\// }"
        local i="" markertoken="/"

        for i in ${CWD} ${realpath} ; do
            if [[ "${i}" = "." ]] ; then
                setpath="${setpath}"
            elif [[ "${i}" = ".." ]] ; then
                setpath="${setpath%/*}"
            else
                case "${i}" in
                    ""|" ")
                        :
                    ;;
                    *)
                        setpath+="${markertoken}${i}"
                    ;;
                esac
            fi
        done

        if [[ -z "${setpath}" ]] ; then
            setpath="${markertoken}"
        fi

        echo "${setpath}"
    else
        echo -e "\t${FUNCNAME##*:}: insufficient parameter."
        return 1
    fi
}

stormsh:tmpup() {
    if [[ -d "${CWD}/${WORKSPACE}" ]] ; then
        rm -rf "${CWD}/${WORKSPACE}"
    fi
    mkdir -p "${CWD}/${WORKSPACE}"
    > "${CWD}/${WORKSPACE}/require"
    > "${CWD}/${WORKSPACE}/reserve"
}

awk:parse() {
    :
}

# Initialize:
stormsh:requires

# Parse parameters:
while [[ "${#}" -gt 0 ]] ; do
    case "${1}" in
        --[dD][iI][rR][eE][cC][tT][oO][rR][yY]|-[dD])
            shift
            if [[ -n "${1}" ]] ; then
                export CWD="${1}"
                shift
            fi
        ;;
        --[fF][iI][lL][eE]|-[fF])
            shift
            if [[ -n "${1}" ]] ; then
                export FILE="${1}"
                shift
            fi
        ;;
        --[hH][eE][lL][pP]|-[hH])
            shift
            export DO="help"
        ;;
        --[vV][eE][rR][sS][iI][oO][nN]|-[vV])
            shift
            export DO="version"
        ;;
        *)
            shift
        ;;
    esac
done

case "${DO}" in
    build)
        unset version status STORMSH_REQUIRE DO
        if [[ -d "${CWD}" ]] ; then
            if [[ -f "${FILE}" ]] ; then
                stormsh:tmpup
                awk:parse ""
            else
                stormsh:output -e "The rule file '${Byellow}${FILE}${reset}' not found!"
            fi
        else
            stormsh:output -e "Current Work Directory '${Byellow}${CWD}${reset}' doesn't exist!"
        fi
    ;;
    path)
        echo "${STORMSH_LIBDIR}"
    ;;
    help)
        echo -e "This helper text"
    ;;
    version)
        echo "${version}"
    ;;
    *)
        echo -e "\t${0##*/}: '${DO}' is never definied yet!"
        exit 1
    ;;
esac