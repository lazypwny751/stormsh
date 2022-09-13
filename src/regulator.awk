#!/usr/bin/awk -f

BEGIN	{
    if (length(opt) == 0) {
        print("please define the 'opt' variable.")
        exit(1)
    }
}

{
    if (substr($0, length($0)) == ",") {
        $0 = substr($0, 1, length($0)-1)
    }
    print(opt"+=(\""$0"\")")
}