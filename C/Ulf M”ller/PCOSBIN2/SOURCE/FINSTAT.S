;long Finstat( int f );					/* GEMDOS 0x105 */

.export Finstat
Finstat:
move.l a2,-(sp)
move.w d0,-(sp)
move.w #$105,-(sp)
trap #1
addq.l #4,sp
movea.l (sp)+,a2
rts
