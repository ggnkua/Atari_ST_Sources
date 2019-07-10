# Script to zoo up the Fnordadel manual
if $1
    zoo21 ah man$1.zoo man\* ref-man\RCS\*
ef
    echo 'usage: manbak uvxyz (where uvxyz as in version u.vx-yz)'
endif
