#!/bin/sh

CC=gcc
f=$1
F=`basename $f .s|tr [a-z] [A-Z]`.s
o=`basename $f .s`.o

sed <$f -e 's/\.sect//g' \
	-e 's/\.align\(.*\)/.align/g'	\
	-e 's/\.define/.globl/g'	\
	-e 's/\.extern.*$//g' >$F
$CC -c -o $o $F
rm $F

# EOF
