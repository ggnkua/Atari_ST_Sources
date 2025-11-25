;long Fputchar( int f, long c, int mode ); /* GEMDOS 0x108 */

.export Fputchar
Fputchar:
move.l a2,-(sp)
move.w d2,-(sp)
move.l d1,-(sp)
move.w d0,-(sp)
move.w #$108,-(sp)
trap #1
lea 10(sp),sp
movea.l (sp)+,a2
rts
