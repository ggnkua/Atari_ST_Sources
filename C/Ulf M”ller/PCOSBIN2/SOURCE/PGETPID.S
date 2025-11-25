;int Pgetpid( void );					/* GEMDOS 0x10b */

.export Pgetpid
Pgetpid:
move.l a2,-(sp)
move.w #$10b,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
