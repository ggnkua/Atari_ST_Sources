; int Pwaitpid(int pid, int flag, long *rusage);	/* GEMDOS 0x13a */

.export Pwaitpid
Pwaitpid:
move.l a2,-(sp)
move.l a0,-(sp)
move.w d1,-(sp)
move.w d0,-(sp)
move.w #$13a,-(sp)
trap #1
lea 10(sp),sp
movea.l (sp)+,a2
rts
