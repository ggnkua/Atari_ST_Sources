#!/bin/sh

# Add -DDEBUG if you want extensive debug info written to error.log.
gcc -v init.c weblib.c -o cab.ovl -mshort -lsocket16 -fforce-addr -fforce-mem
chmod 711 cab.ovl
xstrip -k cab.ovl
