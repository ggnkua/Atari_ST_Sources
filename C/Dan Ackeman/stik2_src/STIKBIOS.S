; STiK BIOS bindings as shown in the Atari Compendium Chap 5

export SBconout,SBcostat
import inint

savptr	equ	$4a2
savamt	equ	$23*2
xconout	equ	$57E
xcostat	equ $55E

SBconout:
		movem.l	d2-d7/a2-a7,-(sp)		/* save regs */
		move.w	d1,-(sp)				/* int c */
		move.w	d0,-(sp)				/* int dev */

		tst.w	inint					/* in interrupt? */
		beq		.SBconoutuser			/* no */

		add.w	d0,d0
		add.w	d0,d0
		lea.l	xconout,a0
		movea.l	0(a0,d0.w),a0			/* compute address of rout */
		jsr		(a0)
		addq.l	#4,sp					/* restore stack */
		movem.l	(sp)+,d2-d7/a2-a7
		rts
.SBconoutuser:
		move.w	#3,-(sp)				/* Bconout */
		trap #13
		addq.l	#6,sp
		movem.l (sp)+,d2-d7/a2-a7
		rts
		
		/* not currently used */

#if 0
SBcostat:
		movem.l	d2-d7/a2-a7,-(sp)		/* save regs */
		move.w	d0,-(sp)				/* int dev */
		move.w	#8,-(sp)				/* Bcostat */
		sub.l	#savamt,savptr
		lsl.l	#2,d0
		lea.l	xcostat,a0
		movea.l	0(a0,d0.w),a0			/* compute address of rout */
		jsr		(a0)
		ext.l	d0						/* return long as expected */
		addq.l	#4,sp					/* restore stack */
		add.l	#savamt,savptr
		movem.l	(sp)+,d2-d7/a2-a7
		rts
#endif