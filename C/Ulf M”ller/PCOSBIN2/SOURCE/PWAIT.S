;long Pwait( void );						/* GEMDOS 0x109 */

.export Pwait
Pwait:
move.l a2,-(sp)
move.w #$109,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
