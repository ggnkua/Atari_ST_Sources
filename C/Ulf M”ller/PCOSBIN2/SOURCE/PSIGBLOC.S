;long Psigblock(unsigned long mask);		/* GEMDOS 0x116 */

.export Psigblock
Psigblock:
move.l a2,-(sp)
move.l d0,-(sp)
move.w #$116,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
