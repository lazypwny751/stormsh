#!/usr/bin/env -S awk -f

BEGIN {
    print("(")
}

{
    if (NR == 1 && match($0, "#!")) {
        $0 = "# lib source."
    }

    print("\t"$0)
}

END {
    print(")")
}