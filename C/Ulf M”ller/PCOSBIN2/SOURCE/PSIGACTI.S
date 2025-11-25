;long Psigaction(int sig, long act, long oact); /* GEMDOS 0x137 */

.export Psigaction
Psigaction:
move.l a2,-(sp)
move.l d2,-(sp)
move.l d1,-(sp)
move.w d0,-(sp)
move.w #$137,-(sp)
trap #1
lea 12(sp),sp
movea.l (sp)+,a2
rts
