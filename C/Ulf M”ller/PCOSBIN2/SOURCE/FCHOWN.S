;long Fchown( char *name, int uid, int gid); /* GEMDOS 0x131 */

.export Fchown
Fchown:
move.l a2,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.l a0,-(sp)
move.w #$131,-(sp)
trap #1
lea 10(sp),sp
movea.l (sp)+,a2
rts
