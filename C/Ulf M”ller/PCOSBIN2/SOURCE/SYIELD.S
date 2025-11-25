;int Syield( void );						/* GEMDOS 0xff */

.export Syield
Syield:
move.l a2,-(sp)
move.w #$ff,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
