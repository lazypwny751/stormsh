#!/usr/bin/env -S awk -f

($1 == "#reserve:" || $2 == "reserve:") {
    if ($1 == "#") {
        $1 = ""
        $2 = ""
    } else {
        $1 = ""
    }

    gsub(/^[ \t]+/, "")

    for (i=1;i<=NF;i++) {
        if (substr($i, length($i)) != ",") {
            print($i",")
        } else {
            print($i)
        }
    }
}