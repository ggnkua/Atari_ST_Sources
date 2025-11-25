;int Pumask( int mask );					/* GEMDOS 0x133 */

.export Pumask
Pumask:
move.l a2,-(sp)
move.w d0,-(sp)
move.w #$133,-(sp)
trap #1
addq.l #4,sp
movea.l (sp)+,a2
rts
