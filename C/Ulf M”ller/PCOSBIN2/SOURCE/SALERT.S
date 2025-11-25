;int Salert(char *ptr);					/* GEMDOS 0x13c */

.export Salert
Fpipe:
move.l a2,-(sp)
move.l a0,-(sp)
move.w #$13c,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts

