;long Psemaphore(int mode, long id, long timeout); /* GEMDOS 0x134 */

.export Psemaphore
Psemaphore:
move.l a2,-(sp)
move.l d2,-(sp)
move.l d1,-(sp)
move.w d0,-(sp)
move.w #$134,-(sp)
trap #1
lea 12(sp),sp
movea.l (sp)+,a2
rts
