;int Dlock( int mode, int drive );		/* GEMDOS 0x135 */

.export Dlock
Dlock:
move.l a2,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.w #$135,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
