;int Pnice( int delta );					/* GEMDOS 0x10a */

.export Pnice
Pnice:
move.l a2,-(sp)
move.w d0,-(sp)
move.w #$10a,-(sp)
trap #1
addq.l #4,sp
movea.l (sp)+,a2
rts
