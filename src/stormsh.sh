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

# Define variables:
export root="" status="true" prefix="/usr" version="1.0.0" ROOT="" CWD="${PWD}" DO="build" FILE="Stormfile" WORKSPACE="StormshWorkSpace"
export LIBDIR="${root}${prefix}/local/lib/stormsh/${version%.*}" SRCDIR="${root}${prefix}/share/stormsh"
export reqcmd=(
    "awk"
)

export reqent=(
    "${SRCDIR}/repetitious.awk"
    "${SRCDIR}/lib_source.awk"
    "${SRCDIR}/lib_parser.awk"
    "${SRCDIR}/regulator.awk"
    "${SRCDIR}/parser.awk"
    "${LIBDIR}/command.sh"
)

# Define functions:
stormsh:awk:parse() {
    local status="true" file="" option="" DO="parse"
    while [[ "${#}" -gt 0 ]] ; do
        case "${1}" in
            --file|-f)
                shift
                if [[ -n "${1}" ]] ; then
                    local file="${1}"
                    shift
                fi
            ;;
            --option|-o)
                shift
                if [[ -n "${1}" ]] ; then
                    local option="${1}"
                    shift
                fi
            ;;
            *)
                shift
            ;;
        esac
    done

    case "${DO}" in
        parse)
            if [[ -n "${option}" && -f "${file}" ]] ; then
                "${SRCDIR}/parser.awk" -v opt="${option}" "${file}" | "${SRCDIR}/regulator.awk" -v opt="${option}" && {
                    return 0
                } || {
                    return 1
                }
            else
                echo -e "\t${0##*/}: ${FUNCNAME##*:}: please give parameters of these arguments correctly: --file, --option."
                return 1
            fi
        ;;
        *)
            return 1
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

# Correction for initialize:
for command in "${reqcmd[@]}" ; do
    if ! command -v "${command}" &> /dev/null ; then
        echo -e "\t${0##*/}: command: '${command}' not found!"
        export status="false"
    fi
done

for entity in "${reqent[@]}" ; do
    if ! [[ -e "${entity}" ]] ; then
        echo -e "\t${0##*/}: file or directory: '${entity}' doesn't exist!"
        export status="false"
    fi
done

if ! ${status} ; then
    exit 1
fi

# Parse parameters:
while [[ "${#}" -gt 0 ]] ; do
    case "${1}" in
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

# Execution the option:
case "${DO}" in
    build)
        export REALFILE="$(stormsh:realpath "${FILE}")"

        if [[ -f "${REALFILE}" ]] ; then
            if [[ -d "${WORKSPACE}" ]] ; then 
                rm -rf "${WORKSPACE}"
            fi
            mkdir -p "${WORKSPACE}" && (
                cd "${WORKSPACE}"
                echo "export use=()" > module.sh 
                stormsh:awk:parse -o "use" -f "${REALFILE}" >> module.sh
                echo "readonly use" >> module.sh
                source module.sh
                echo "export reserve=()" > reserve.sh
                if [[ -n "${use[@]}" ]] ; then
                    for i in "${use[@]}" ; do
                        if [[ -f "${LIBDIR}/${i}.sh" ]] ; then
                            export libfile="${LIBDIR}/${i}.sh"
                        elif [[ -f "${LIBDIR}/${i}" ]] ; then
                            export libfile="${LIBDIR}/${i}"
                        else
                            export libfile=""
                        fi

                        if [[ -f "${libfile}" ]] ; then
                            "${SRCDIR}/lib_parser.awk" "${libfile}" | "${SRCDIR}/repetitious.awk" >> reserve
                            "${SRCDIR}/lib_source.awk" "${libfile}" >> function
                        else
                            echo -e "\t${0##*/}: the library '${i}' not found."
                            export status="false"
                        fi
                    done
                fi
                
                if ! ${status} ; then
                    exit 1
                fi

                if [[ -f "reserve" ]] ; then
                    "${SRCDIR}/regulator.awk" -v opt="reserve" "reserve" >> reserve.sh
                    echo "readonly reserve" >> reserve.sh
                    source reserve.sh
                fi
                # there is no bug, variables can not obtain white spaces it's must be just another variable.
                echo -e "#!/bin/bash\n\n# This script was generated by ${0##*/} under GPL license\n# Copyright by lazypwny751 - 03.10.2022.\n\nexport CWD=\"\${PWD}\"\n\nset -e\n" > "${REALFILE%/*}/${FILE}.sh"

                if [[ -n "${reserve[@]}" ]] ; then
                    for var in "${reserve[@]}" ; do
                        stormsh:awk:parse -o "${var}" -f "${REALFILE}" >> "${REALFILE%/*}/${FILE}.sh"
                    done
                fi

                if [[ -n "${reserve[@]}" ]] ; then
                    echo -e "\nreadonly ${reserve[@]}\n\ncd \${CWD}\n" >> "${REALFILE%/*}/${FILE}.sh"
                else
                    echo -e "cd \${CWD}\n" >> "${REALFILE%/*}/${FILE}.sh"
                fi

                if [[ -f "function" ]] ; then
                    awk "{print(\$0)}" ./"function" >> "${REALFILE%/*}/${FILE}.sh"
                fi

                if command -v "chmod" &> /dev/null ; then
                    chmod u+x "${REALFILE%/*}/${FILE}.sh"
                fi
            ) || {
                echo -e "\t${0##*/}: couldn't parsing the file '${REALFILE##*/}' in '${WORKSPACE}'."
                exit 1
            }
        else
            echo -e "\t${0##*/}: the file '${REALFILE##*/}' is does not exist."
            exit 1
        fi
    ;;
    help)
        echo "this helper text"
    ;;
    version)
        echo "${version}"
    ;;
    *)
        echo -e "\t${0##*/}: there is no option called '${DO}', so will doing nothing."
    ;;
esac