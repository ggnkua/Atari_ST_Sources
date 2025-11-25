;int Prusage( long r[8] );				/* GEMDOS 0x11e */

.export Prusage
Prusage:
move.l a2,-(sp)
move.l a0,-(sp)
move.w #$11e,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
