;long Sysconf( int n );					/* GEMDOS 0x122 */

.export Sysconf
Sysconf:
move.l a2,-(sp)
move.w d0,-(sp)
move.w #$122,-(sp)
trap #1
addq.l #4,sp
movea.l (sp)+,a2
rts
