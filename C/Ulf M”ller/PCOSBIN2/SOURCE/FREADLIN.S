;long Freadlink( int siz, char *buf, char *name); /*GEMDOS 0x12f */

.export Freadlink
Freadlink:
move.l a2,-(sp)
move.l a1,-(sp)
move.l a0,-(sp)
move.w d0,-(sp)
move.w #$12f,-(sp)
trap #1
lea 12(sp),sp
movea.l (sp)+,a2
rts
