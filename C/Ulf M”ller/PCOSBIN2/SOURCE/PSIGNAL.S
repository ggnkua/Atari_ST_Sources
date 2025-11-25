;long Psignal(int sig, long handler);	/* GEMDOS 0x112 */

.export Psignal
Psignal:
move.l a2,-(sp)
move.l d1,-(sp)
move.w d0,-(sp)
move.w #$112,-(sp)
trap #1
addq.l #8,sp
movea.l (sp)+,a2
rts
