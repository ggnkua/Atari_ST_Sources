;long Fmidipipe( int pid, int in, int out );	/* GEMDOS 0x126 */

.export Fmidipipe
Fmidipipe:
move.l a2,-(sp)
move.w d2,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.w #$126,-(sp)
trap #1
addq.l #8,sp
movea.l (sp)+,a2
rts
