# Script to zoo up the Fnordadel sources
if $1
    zoo21 ah fns$1.zoo citmain\*.c citlib\*.c cith\*.h citutil\*.c citalt\*.c
    zoo21 ah fns$1.zoo help\*.* scripts\*
    zoo21 ah fns$1.zoo ctdlcnfg.doc makefile fnorddoc fnordbug fnordsug increm* netbsugs
ef
    echo 'usage: srcbak uvxyz (where uvxyz as in version u.vx-yz)'
endif
