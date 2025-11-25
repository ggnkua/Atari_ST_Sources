;long Talarm( long secs );				/* GEMDOS 0x120 */

.export Talarm
Talarm:
move.l a2,-(sp)
move.l d0,-(sp)
move.w #$120,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
