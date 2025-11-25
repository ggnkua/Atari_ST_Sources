;int Prenice( int pid, int delta );		/* GEMDOS 0x127 */

.export Prenice
Prenice:
move.l a2,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.w #$127,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
