;long Dcntl( int cmd, char *name, long arg ); /* GEMDOS 0x130 */

.export Dcntl
Dcntl:
move.l a2,-(sp)
move.l d1,-(sp)
move.l a0,-(sp)
move.w d0,-(sp)
move.w #$130,-(sp)
trap #1
lea 12(sp),sp
movea.l (sp)+,a2
rts
