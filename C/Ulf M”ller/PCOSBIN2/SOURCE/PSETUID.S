;int Psetuid( int id );					/* GEMDOS 0x110 */

.export Psetuid
Psetuid:
move.l a2,-(sp)
move.w d0,-(sp)
move.w #$110,-(sp)
trap #1
addq.l #4,sp
movea.l (sp)+,a2
rts
