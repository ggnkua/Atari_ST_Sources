***********************************************************
*                                                         *
*   FRACTALS    for the Atari TT med resolution           *
*                                                         *
*   (C) 9/1990  by Uwe Seimet, MAXON Computer             *
*                                                         *
*   taken from 'ST Computer' Vol. 11/90, Heim Verlag      *
*                                                         *
*   - procedure KEYPRESS added by Markus Wenzel -         *
*                                                         *
***********************************************************


GEMDOS		=  1
LOGBASE		=  3
XBIOS		= 14

iter_depth 	= 50	
	
		text
	
		dc.w	$a00a
		
		move 	#LOGBASE,-(sp)
		trap	#XBIOS
		addq.l	#2,sp
		move.l	d0,a0
		
		fmove.x	#-2,fp6
		fmove.x	#-1.25,fp7
		fmove.x	#1,fp4
		fmove.x	#1.25,fp5
		fsub.x	fp6,fp4
		fdiv.x	#320,fp4
		fsub.x	fp7,fp5
		fdiv.x	#200,fp5
		
		fsub.x	fp5,fp7
		fmove.x	fp5,-(sp)
		moveq	#4,d2
		clr		d7
	loopi:
		fadd.x	(sp),fp7
		fmove.x	#-2,fp6
		fsub.x	fp4,fp6
		clr		d6
	loopk:
		moveq	#0,d0
		moveq	#0,d1
		clr		d5
	loopj:
		fadd.x	fp4,fp6
		fmovecr.x #$0f,fp0
		fmovecr.x #$0f,fp1
		moveq	#0,d4
		moveq	#0,d3
	looph:
		fmove.x	fp0,fp2
		fmul.x	fp0,fp2
		fmove.x	fp1,fp3
		fmul.x	fp1,fp3
		fmove.x	fp3,fp5
		fadd.x	fp2,fp5
		fcmp.w	d2,fp5
		fblt	else
		move.l	d3,d4
		bra cont
	else:
		fmul.x	fp0,fp1
		fadd.x	fp1,fp1
		fadd.x	fp7,fp1
		fmove.x	fp2,fp0
		fsub.x	fp3,fp0
		fadd.x	fp6,fp0
		addq	#1,d3
		cmp		#iter_depth,d3		
		bne		looph
	cont:
		lsr		#1,d4
		roxl	#1,d0
		swap	d0
		lsr		#1,d4
		roxl	#1,d0
		swap	d0
		lsr		#1,d4
		roxl	#1,d1
		swap	d1
		lsr		#1,d4
		roxl	#1,d1
		swap	d1
		addq	#1,d5
		cmp		#16,d5
		bne		loopj
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		add		#16,d6
		cmp		#320,d6
		bne		loopk
		addq	#1,d7
		cmp		#200,d7
		bne		loopi
		
keypress:
 		move.w	#$0B,-(sp)
 		trap	#GEMDOS
 		addq.l	#2,sp
 		tst.b	d0
 		beq		keypress
 		
		fmove.x	(sp)+,fp5
		dc.w	$a009
		clr		-(sp)
		trap	#GEMDOS
		