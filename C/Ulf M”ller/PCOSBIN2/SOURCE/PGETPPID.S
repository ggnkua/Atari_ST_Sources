;int Pgetppid( void );					/* GEMDOS 0x10c */

.export Pgetppid
Pgetppid:
move.l a2,-(sp)
move.w #$10c,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
