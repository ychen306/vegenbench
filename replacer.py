#!/usr/bin/env python

import sys

target=""
version=""
flags=""

for arg in sys.argv:
    if "target=" in arg:
        target = arg.split("target=")[1]
    elif "ver=" in arg:
        version = arg.split("ver=")[1]
    elif "flags=" in arg:
        flags = arg.split("flags=")[1]
with open("bench.cc", "r") as original:
    contents = original.read().replace("UNKNOWN", version).replace("FLAGS_HERE", flags)
    with open(target, "w") as new_file:
        new_file.write(contents)
