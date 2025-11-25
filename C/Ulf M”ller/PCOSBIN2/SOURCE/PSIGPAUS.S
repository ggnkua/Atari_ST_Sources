;void Psigpause( unsigned long mask);	/* GEMDOS 0x136 */

.export Psigpause
Psigpause:
move.l a2,-(sp)
move.l d0,-(sp)
move.w #$136,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
