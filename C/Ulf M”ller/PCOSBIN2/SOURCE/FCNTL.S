;long Fcntl( int f, long arg, int cmd);	/* GEMDOS 0x104 */

.export Fcntl
Fcntl:
move.l a2,-(sp)
move.w d2,-(sp)
move.l d1,-(sp)
move.w d0,-(sp)
move.w #$104,-(sp)
trap #1
lea 10(sp),sp
movea.l (sp)+,a2
rts
