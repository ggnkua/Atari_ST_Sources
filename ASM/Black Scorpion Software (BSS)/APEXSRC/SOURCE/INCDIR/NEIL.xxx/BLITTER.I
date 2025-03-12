
;--------------------------------------------------------------------
; BLITTER REGISTERS
;--------------------------------------------------------------------

B_HALFTONE	=	$FFFF8A00
B_SRC_XINC	=	$FFFF8A20
B_SRC_YINC	=	$FFFF8A22
B_SRC_ADDRESS	=	$FFFF8A24
B_ENDMASK_1	=	$FFFF8A28
B_ENDMASK_2	=	$FFFF8A2A
B_ENDMASK_3	=	$FFFF8A2C
B_DEST_XINC	=	$FFFF8A2E
B_DEST_YINC	=	$FFFF8A30
B_DEST_ADDRESS	=	$FFFF8A32
B_XCOUNT	=	$FFFF8A36
B_YCOUNT	=	$FFFF8A38
B_HOP		=	$FFFF8A3A
B_OP		=	$FFFF8A3B
B_CONTROL1	=	$FFFF8A3C
B_BUSY		=	7
B_HOG		=	6
B_SMUDGE	=	5
B_LINENUM	=	-16
B_CONTROL2	=	$FFFF8A3D
B_FXSR		=	7
B_NFSR		=	6
B_SKEW		=	-16

B_NASTY	macro
	push.w	d0
	moveq	#-B_LINENUM-1,d0
	and.b	B_CONTROL1.w,d0
	or.w	#192,d0
	move.b	d0,B_CONTROL1.w
	pop.w	d0
	endm

B_NICE	macro
	movem.l	d0/a0,-(sp)
	lea	B_CONTROL1.w,a0
	moveq	#(-B_LINENUM)-1,d0
	and.b	(a0),d0
	or.w	#128,d0
	move.b	d0,(a0)
	moveq	#7,d0
.\@lp	
	bset.b	d0,(a0)
	bne.s	.\@lp
	movem.l	(sp)+,d0/a0
	endm	


