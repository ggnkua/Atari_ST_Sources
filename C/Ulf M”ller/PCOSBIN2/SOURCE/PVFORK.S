;long Pvfork( void );					/* GEMDOS 0x113 */

.export Pvfork
Pvfork:
move.l a2,-(sp)
move.w #$113,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
