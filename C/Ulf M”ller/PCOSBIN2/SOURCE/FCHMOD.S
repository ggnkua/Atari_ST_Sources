;long Fchmod( char *name, int mode );	/* GEMDOS 0x132 */

.export Fchmod
Fchmod:
move.l a2,-(sp)
move.w d0,-(sp)
move.l a0,-(sp)
move.w #$132,-(sp)
trap #1
addq.l #8,sp
movea.l (sp)+,a2
rts
