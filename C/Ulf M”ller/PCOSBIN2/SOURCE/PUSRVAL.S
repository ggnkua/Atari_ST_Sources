;long Pusrval(long arg);					/* GEMDOS 0x118 */

.export Pusrval
Pusrval:
move.l a2,-(sp)
move.l d0,-(sp)
move.w #$118,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
