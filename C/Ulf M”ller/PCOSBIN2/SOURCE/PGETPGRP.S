;int Pgetpgrp( void );					/* GEMDOS 0x10d */

.export Pgetpgrp
Pgetpgrp:
move.l a2,-(sp)
move.w #$10d,-(sp)
trap #1
addq.l #2,sp
movea.l (sp)+,a2
rts
