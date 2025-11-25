;void Psigreturn( void );				/* GEMDOS 0x11a */

.export Psigreturn
Psigreturn:
move.l a2,-(sp)
move.w #$11a,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
