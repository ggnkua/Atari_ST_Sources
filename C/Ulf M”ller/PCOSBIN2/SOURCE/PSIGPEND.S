;long Psigpending( void );				/* GEMDOS 0x123 */

.export Psigpending
Psigpending:
move.l a2,-(sp)
move.w #$123,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
