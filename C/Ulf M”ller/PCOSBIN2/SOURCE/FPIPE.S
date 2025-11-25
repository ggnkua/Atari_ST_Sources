;int Fpipe( int *ptr );					/* GEMDOS 0x100 */

.export Fpipe
Fpipe:
move.l a2,-(sp)
move.l a0,-(sp)
move.w #$100,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
