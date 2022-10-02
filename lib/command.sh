#!/bin/bash

# reserve: command

status="true"

for check in "${command[@]}" ; do
    if ! command -v "${check}" &> /dev/null ; then
        echo -e "\tcommand: '${check}' not found!"
        status="false"
    fi
done

if ! ${status} ; then
    exit 1
fi