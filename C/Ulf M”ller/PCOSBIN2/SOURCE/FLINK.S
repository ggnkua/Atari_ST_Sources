;long Flink( char *oldname, char *newname ); /* GEMDOS 0x12d */

.export Flink
Flink:
move.l a2,-(sp)
move.l a1,-(sp)
move.l a0,-(sp)
move.w #$12d,-(sp)
trap #1
lea 10(sp),sp
movea.l (sp)+,a2
rts
