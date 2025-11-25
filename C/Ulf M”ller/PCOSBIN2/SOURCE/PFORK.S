;long Pfork( void );						/* GEMDOS 0x11b */

.export Pfork
Pfork:
move.l a2,-(sp)
move.w #$11b,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
