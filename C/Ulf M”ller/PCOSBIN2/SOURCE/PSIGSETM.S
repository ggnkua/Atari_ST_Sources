;long Psigsetmask(unsigned long mask);	/* GEMDOS 0x117 */

.export Psigsetmask
Psigsetmask:
move.l a2,-(sp)
move.l d0,-(sp)
move.w #$117,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
