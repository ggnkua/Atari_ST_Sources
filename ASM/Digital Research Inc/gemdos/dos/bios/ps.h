/*  ps.h - common header file for ps files				*/


#define	GLOBAL	.xref
#define	EXTERN	.xdef

#define	PUSH(m,x)	move.m	x,-(sp)
#define	POP(m,x)	move.m	(sp)+,x
#define	PUSHA		movem.l	d1-d7/a0-a6,-(sp)
#define	POPA		movem.l	(sp)+,d1-d7/a0-a6

