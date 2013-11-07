        ORG     $F8000-40000-10000-1000
        LOAD    $F8000-40000-10000-1000

vecteur:
        dc.l    decani
        dc.l    modpourc
        dc.l    chamb
        dc.l    suri
        dc.l    prio
        dc.l    feu
        dc.l    frico
        dc.l    fri
        dc.l    anim
        dc.l    main
        dc.l    inidep
        dc.l    decamb
        dc.l    routima
adpian: dc.l    0
posech: dc.l    0
basech: dc.l    0
flpian: dc.w    0
modivo: dc.w    0
finmor: dc.w    0
        dc.l    couto
        dc.l    texe
        dc.l    modcode
        dc.l    generi        
        dc.l    chargtot
;generique
decani:
        rts
modpourc:
       rts
chamb:
       rts
suri:
       rts
prio:
       rts
feu:
       rts
frico:
       rts
fri:
       rts
anim:
       rts
main:
       rts
inidep:
       rts
decamb:
       rts
routima:
       rts
couto:
       rts
texe:
       rts
modcode:
       rts
generi:
       rts
chargtot:
       rts
fin:
