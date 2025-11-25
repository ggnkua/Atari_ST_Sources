;int Pkill( int pid, int sig );			/* GEMDOS 0x111 */

.export Pkill
Pkill:
move.l a2,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.w #$111,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
