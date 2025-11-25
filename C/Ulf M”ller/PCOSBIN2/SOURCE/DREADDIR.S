;long Dreaddir( int buflen, long dir, char *buf); /*GEMDOS 0x129 */

.export Dreaddir
Dreaddir:
move.l a2,-(sp)
move.l a0,-(sp)
move.l d1,-(sp)
move.w d0,-(sp)
move.w #$129,-(sp)
trap #1
lea 12(sp),sp
movea.l (sp)+,a2
rts
