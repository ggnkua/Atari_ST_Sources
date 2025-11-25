;int Pgetuid( void );					/* GEMDOS 0x10f */

.export Pgetuid
Pgetuid:
move.l a2,-(sp)
move.w #$10f,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
