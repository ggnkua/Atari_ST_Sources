;long Fgetchar(int f, int mode);			/* GEMDOS 0x107 */

.export Fgetchar
Fgetchar:
move.l a2,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.w #$107,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
