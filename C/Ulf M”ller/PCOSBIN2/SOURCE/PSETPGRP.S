;int Psetpgrp(int pid, int newgrp);		/* GEMDOS 0x10e */

.export Psetpgrp
Psetpgrp:
move.l a2,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.w #$10e,-(sp)
trap #1
addq.l #6,sp
movea.l (sp)+,a2
rts
