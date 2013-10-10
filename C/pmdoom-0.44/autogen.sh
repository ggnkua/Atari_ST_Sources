#!/bin/sh

#aclocal
aclocal -I /usr/local/share/aclocal
automake --add-missing --copy
autoheader
autoconf
