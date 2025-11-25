;long Fxattr( int flag, char *name, void *buf ) ;/* GEMDOS 0x12c */

.export Fxattr
Fxattr:
move.l a2,-(sp)
move.l a1,-(sp)
move.l a0,-(sp)
move.w d0,-(sp)
move.w #$12c,-(sp)
trap #1
lea 12(sp),sp
movea.l (sp)+,a2
rts
