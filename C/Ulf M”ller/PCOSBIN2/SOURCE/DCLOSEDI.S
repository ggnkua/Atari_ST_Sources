;long Dclosedir( long dir );				/* GEMDOS 0x12b */

.export Dclosedir
Dclosedir:
move.l a2,-(sp)
move.l d0,-(sp)
move.w #$12b,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
