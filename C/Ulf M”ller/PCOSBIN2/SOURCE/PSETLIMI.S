;long Psetlimit(int lim, long value);	/* GEMDOS 0x11f */

.export Psetlimit
Psetlimit:
move.l a2,-(sp)
move.l d1,-(sp)
move.w d0,-(sp)
move.w #$11f,-(sp)
trap #1
addq.l #8,sp
movea.l (sp)+,a2
rts
