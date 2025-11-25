;long Pmsg( int mode, long mbox, void *msg ); /* GEMDOS 0x125 */

.export Pmsg
Pmsg:
move.l a2,-(sp)
move.l a0,-(sp)
move.l d1,-(sp)
move.w d0,-(sp)
move.w #$125,-(sp)
trap #1
lea 12(sp),sp
movea.l (sp)+,a2
rts
