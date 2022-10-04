#!/bin/bash

# reserve: file

status="true"

for check in "${file[@]}" ; do
    if ! [[ -f "${check}" ]] ; then
        echo -e "\tfile: '${check}' does not exist!"
        status="false"
    fi
done

if ! ${status} ; then
    exit 1
fi