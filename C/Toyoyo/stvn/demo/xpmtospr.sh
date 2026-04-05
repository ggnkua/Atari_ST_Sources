#!/bin/bash

[ "$1" == "" ] && echo "Usage: $(basename $0) [xpm file]" && exit 1
tail -n +7 "$1" | sed 's/"//g' | sed 's/,//g' | sed 's/}//g' | sed 's/;//g' | sed 's/"//g' | sed 's/+/0/g' | sed 's/\./1/g'
