;long Dgetcwd( char *path, int drv, int size); /* GEMDOS 0x13b */

.export Dgetcwd
Fchown:
move.l a2,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.l a0,-(sp)
move.w #$13b,-(sp)
trap #1
lea 10(sp),sp
movea.l (sp)+,a2
rts

