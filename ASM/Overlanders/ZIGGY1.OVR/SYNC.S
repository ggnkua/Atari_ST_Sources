set_mus:
 clr.w music+$80a
 moveq #1,d0
 jsr music
 move.l #music+4,$4d2
 rts
 dpl1:
 move.l (a0)+,(a1)+
 dbra d0,dpl1
 jsr $63268
 move.l #$a,$4d2
 rts
unset_mus:
 clr.l $4d2
 rts
music:
 incbin sync.b
