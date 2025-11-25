;void Pause( void );						/* GEMDOS 0x121 */

.export Pause
Pause:
move.l a2,-(sp)
move.w #$121,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
