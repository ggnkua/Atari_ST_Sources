 pea debut
 move #$26,-(sp)
 trap #14
rte rte
debut
 move #$2700,sr
 clr.b $fffffa07.w
 clr.b $fffffa09.w
 move.l #rte,$70.w
jmp
 incbin execf20.dat