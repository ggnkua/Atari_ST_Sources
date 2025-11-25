;long Fsymlink( char *oldname, char *newname ); /* GEMDOS 0x12e */

.export Fsymlink
Fsymlink:
move.l a2,-(sp)
move.l a1,-(sp)
move.l a0,-(sp)
move.w #$12e,-(sp)
trap #1
lea 10(sp),sp
movea.l (sp)+,a2
rts
