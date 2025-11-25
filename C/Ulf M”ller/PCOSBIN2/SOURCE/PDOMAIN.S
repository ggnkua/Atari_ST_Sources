;int Pdomain(int newdom);				/* GEMDOS 0x119 */

.export Pdomain
Pdomain:
move.l a2,-(sp)
move.w d0,-(sp)
move.w #$119,-(sp)
trap #1
addq.l #4,sp
movea.l (sp)+,a2
rts
