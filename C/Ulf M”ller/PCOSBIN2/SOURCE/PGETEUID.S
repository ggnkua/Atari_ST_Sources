;int Pgeteuid( void );						/* GEMDOS 0x138 */

.export Pgeteuid
Pgeteuid:
move.l a2,-(sp)
move.w #$138,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
