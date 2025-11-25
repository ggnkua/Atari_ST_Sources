;long Foutstat( int f );					/* GEMDOS 0x106 */

.export Foutstat
Foutstat:
move.l a2,-(sp)
move.w d0,-(sp)
move.w #$106,-(sp)
trap #1
addq.l #4,sp
movea.l (sp)+,a2
rts
