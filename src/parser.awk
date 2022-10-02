#!/usr/bin/env -S awk -f

BEGIN	{
    if (length(opt) == 0) {
        print("please define the 'opt' variable.")
        exit(1)
    }
}

($1 == opt":") {
    $1 = ""
    gsub(/^[ \t]+/, "")
    if (substr($0, length($0)) != ",") {
        $0 = $0","
    }

    for (i=1;i<=NF;i++) {
        if (substr($i, length($i)) == ",") {
            print($i)
        } else {
            # White Space limit = 1
            printf("%s ", $i)
        }
    }
}