#!/usr/bin/env -S awk -f

(!seen[$0]++) {
    print($0)
}