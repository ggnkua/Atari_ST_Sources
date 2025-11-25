;int Pgetgid( void );					/* GEMDOS 0x114 */

.export Pgetgid
Pgetgid:
move.l a2,-(sp)
move.w #$114,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
