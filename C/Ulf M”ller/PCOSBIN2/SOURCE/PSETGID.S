;int Psetgid(int id);					/* GEMDOS 0x115 */

.export Psetgid
Psetgid:
move.l a2,-(sp)
move.w d0,-(sp)
move.w #$115,-(sp)
trap #1
addq.l #4,sp
movea.l (sp)+,a2
rts
