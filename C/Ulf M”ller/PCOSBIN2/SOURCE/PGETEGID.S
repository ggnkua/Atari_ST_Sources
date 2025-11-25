;int Pgetegid( void );						/* GEMDOS 0x139 */

.export Pgetegid
Pgetegid:
move.l a2,-(sp)
move.w #$139,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
