;long Dopendir( char *name, int flag );	/* GEMDOS 0x128 */

.export Dopendir
Dopendir:
move.l a2,-(sp)
move.w d0,-(sp)
move.l a0,-(sp)
move.w #$128,-(sp)
trap #1
addq.l #8,sp
movea.l (sp)+,a2
rts
