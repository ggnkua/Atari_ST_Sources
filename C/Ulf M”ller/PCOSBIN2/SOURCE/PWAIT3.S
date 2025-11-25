;long Pwait3(int flag, long *rusage);	/* GEMDOS 0x11c */

.export Pwait3
Pwait3:
move.l a2,-(sp)
move.l a0,-(sp)
move.w d0,-(sp)
move.w #$11c,-(sp)
trap #1
addq.l #8,sp
movea.l (sp)+,a2
rts
