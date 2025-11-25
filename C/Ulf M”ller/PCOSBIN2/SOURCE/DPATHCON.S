;long Dpathconf( char *name, int n );	/* GEMDOS 0x124 */

.export Dpathconf
Dpathconf:
move.l a2,-(sp)
move.w d0,-(sp)
move.l a0,-(sp)
move.w #$124,-(sp)
trap #1
addq.l #8,sp
movea.l (sp)+,a2
rts
