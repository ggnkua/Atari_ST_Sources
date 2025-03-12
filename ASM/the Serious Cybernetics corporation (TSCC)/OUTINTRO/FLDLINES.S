; Field line effect, by ray//.tSCc., jan. 2007


FLD_XSIZE 	=	128		; Resolution of the effect window
FLD_YSIZE 	=	128


		data
fldPalObj:	dc.w	15		; Field line effect split palette object
		dc.l	outPal

		dc.w	OUTLOGO_Y-1
fldFade:	dc.w	1
		dc.l	fldLnPalette

		dc.w	FLD_YSIZE-1,15
		dc.l	outPal

		dc.w	-1


fldLnPalette:	include	'fldpal.i'

;>		dc.w $0000,$0100,$0110,$0210,$0320,$0430,$0540,$0650
;>		dc.w $0750,$0761,$0762,$0763,$0764,$0765,$0766,$0777


		text
fpos:		dc.w	320


******************************************************
*  Field line screen demo sequencing routines
******************************************************

fieldInit:	move.l	#outPal,logoPalPatch ;;fujiPal1,logoPalPatch
		move.w	#15,logoFade2

		lea.l	logoPalObj,a0	; Show Interlude #1
		movea.l	fujiPtr1,a1
		bsr.w	interludeInit


		bra.w	initField	; Init effect

fieldInitFadeOut:
		movea.l	fujiPtr1,a0
		bsr.w	interludeDeinit

		move.l	fujiPtr1,d0	; Release image
		bra.w	FreeSomeMem


fieldDeinit:	bsr.w	restoreField
		bra.w	setSemaphore


fieldFadeIn:	lea.l	fldPalObj,a0	; Fade in
		bsr.w	installSplitPalette


		move.l	#fldFadeIn,VBLHookPtr
		bra.w	setSemaphore

fieldFadeOut:   move.l	#fldFadeOut,VBLHookPtr
		bra.w	fieldMain


*********************************************************
*  void fldFadeIn()
*  void fldFadeOut()
*
* Fading VBL hook routines.
*********************************************************

		text
fldFadeIn:	moveq.l	#3,d0
		and.l	$466.w,d0	; Fade every 4th VBL
		bne.s	.break

		moveq.l	#(1<<PHYS_BPP)-1,d0	; Max. brightness

		cmp.w	fldFade(pc),d0	; Max. brightness approached yet?
		beq.s	.done

		addq.w	#1,fldFade

.break:		rts

.done:		clr.l	VBLHookPtr
		rts

fldFadeOut:	moveq.l	#3,d0		; Fade every 4th VBL
		and.l	$466.w,d0
		bne.s	.break

      		tst.w	fldFade	; Min. brightness approached yet?
		beq.s	.done

		subq.w	#1,fldFade

.break:		rts

.done:          clr.l	VBLHookPtr
		rts


*********************************************
*  void initField()
*
* Init field line effect.
*********************************************

initField:     	move.l	#2*2*FLD_XSIZE*FLD_YSIZE,d0 ; Allocate angular Table array
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,angTablePtr


; Align c2pTable to 256 byte boundary

		move.l	#c2p+256,d0
		clr.b	d0

		lea.l	.c2pTmp1,a0
		movea.l d0,a1

		lea.l	c2pTable1,a2
		move.l	#64*4,d1

		move.l	d0,(a2)+
		add.l	d1,d0
		move.l	d0,(a2)+
		add.l	d1,d0
		move.l	d0,(a2)+
		add.l	d1,d0
		move.l	d0,(a2)+

		moveq	#2*32-1,d0
.c2p_cpy_loop:	move.l	(a0)+,d1
		move.l	d1,3*2*32*4(a1)
		lsl.l	#2,d1
		move.l	d1,2*2*32*4(a1)
		lsl.l	#2,d1
		move.l	d1,1*2*32*4(a1)
		lsl.l	#2,d1
		move.l	d1,(a1)+
		dbra	d0,.c2p_cpy_loop

; Compute atan(x) lut, |x| <= 1

		lea	atan-2*257,a0

		move.w	#-257,d0

.atan_loop:	move.w	d0,d2		; atan(x) ~ x/(1+0.28x^2), |x| <= 1
		muls	d2,d2
		lsr.l	#8,d2
		mulu	#(28<<8)/100,d2
		lsr.l	#8,d2
		addi.w	#$0100,d2

		move.w	d0,d1
		ext.l	d1
		asl.l	#8,d1
		divs	d2,d1

		move.w	d1,(a0)+

		addq.w	#1,d0
		cmpi.w	#257,d0
		ble.s	.atan_loop


; Init angular gradient table

		movea.l angTablePtr,a0
		lea	atan,a1

		move.w	#(31415<<8)/20000,d4 ; pi/2 in 8.8 fixedpoint

		move.w	#2*FLD_YSIZE-1,d0

.y_loop:	move.w	#2*FLD_XSIZE-1,d1

.x_loop:	move.w	d0,d3
		move.w	d1,d2
		subi.w	#FLD_XSIZE,d2	; dx
		subi.w	#FLD_YSIZE,d3	; dy
		bne.s	.dx_not_zero	; dy == 0?

		tst.w	d2		; Handle borderline cases
		bpl.s	.neg

		move.w	d4,d2		; atan(dx/dy) = +pi/2, dx > 0, dy == 0
		neg.w	d4

.neg:		move.w	d4,d2		; atan(dx/dy) = -pi/2, dx < 0, dy == 0
		neg.w	d2
		bra.s	.cont

.dx_not_zero:	ext.l	d2
		asl.l	#8,d2
		divs	d3,d2		; dx/dy, 8.8 fixedpoint

		move.w	d2,d3		; abs(dx/dy) <= 1 ?
		bpl.s	.pos
		neg.w	d3

.pos:		cmpi.w	#$0100,d3
		bhi.s	.greater

		add.w	d2,d2
		move.w	0(a1,d2.w),d2	; Look up atan (dx/dy), |dx/dy| <= 1
		bra.s	.cont

.greater:	move.l	#$00010000,d3	; Look up atan(dy/dx), |dx/dy| > 1
		divs	d2,d3

		move.w	d4,d2
		add.w	d3,d3
		sub.w	0(a1,d3.w),d2

.cont:		ext.l	d2
		asl.l	#8,d2
		divs	d4,d2
		asr.l	#2,d2
		addq.b	#4,d2
		andi.b	#$1f,d2 	; Limit to [0;15]
		lsl.b	#2,d2
		move.b	d2,(a0)+
		dbra	d1,.x_loop
		dbra	d0,.y_loop

		rts


.c2pTmp1:
	rept 2
	dc.l $00000000
	dc.l $03000000
	dc.l $00030000
	dc.l $03030000
	dc.l $00000300
	dc.l $03000300
	dc.l $00030300
	dc.l $03030300
	dc.l $00000003
	dc.l $03000003
	dc.l $00030003
	dc.l $03030003
	dc.l $00000303
	dc.l $03000303
	dc.l $00030303
	dc.l $03030303
	dc.l $03030303
	dc.l $00030303
	dc.l $03000303
	dc.l $00000303
	dc.l $03030003
	dc.l $00030003
	dc.l $03000003
	dc.l $00000003
	dc.l $03030300
	dc.l $00030300
	dc.l $03000300
	dc.l $00000300
	dc.l $03030000
	dc.l $00030000
	dc.l $03000000
	dc.l $00000000
	endr


c2pTable1:	dc.l	0
c2pTable2:	dc.l	0
c2pTable3:	dc.l	0
c2pTable4:	dc.l	0


*********************************************
*  void restoreField()
*
* Deinitialise field line effect.
*********************************************

restoreField:   
		movea.l	screen3(pc),a0	; Clear screen
		lea.l	OUTLOGO_Y*BYTESPERSCL(a0),a0
		move.l	#(PHYS_Y-2*OUTLOGO_Y)*BYTESPERSCL,d0
		moveq.l	#0,d1
		bsr.w	ClearBlock
		bsr.w	cycleScreens

;>		bsr.w	uninstallSplitPalette

             	move.l	angTablePtr,d0	; Release anglular table
		bra.w	FreeSomeMem


*********************************************
*  void moveCharges(d0.w keyFrameDelta)
*
* Update the two charges' position based on the
* given keyFrameDelta value. Every charge will follow
* a constantly changing sine spline. The new x, y
* position will be returned via the chrg1x, y and
* chrg2x, y variables.
*********************************************

chrg1x: 	dc.w	0			; Charge 1 x, y position
chrg1y:		dc.w	0

chrg2x: 	dc.w	0			; Charge 2 x, y position
chrg2y:		dc.w	0

moveCharges:	lsr.w	#1,d0
		add.w	.angle(pc),d0
		move.w	d0,.angle

		move.w	#FLD_XSIZE/2,d5
		move.w	#FLD_YSIZE/2,d6

		move.w	#2048-1,d7	; Angle mask

		lea.l	sin,a0		; Lookup sin(pi/2*sin(angle))
		and.w	d7,d0
		add.w	d0,d0
		move.w	0(a0,d0.w),d0

		asr.l	#2,d0
		and.w	d7,d0
		move.w	d0,d2
		addi.w	#760,d2
		and.w	d7,d2
		add.w	d0,d0
		add.w	d2,d2
		move.w	0(a0,d0.w),d1
		move.w	0(a0,d2.w),d2

		moveq	#15,d0
		mulu	d5,d1
		mulu	d6,d2
		asr.l	d0,d1
		asr.l	d0,d2
		add.w	d5,d1
		add.w	d6,d2
		
		andi.l	#$ffff,d1
		andi.l	#$ffff,d2
		divu.w	#FLD_XSIZE,d1
		divu.w	#FLD_YSIZE,d2
		swap.w	d1
		swap.w	d2
		movem.w d1-d2,chrg1x

		move.w	.angle(pc),d0
		neg.w	d0

		lea.l	sin,a0		; Get sin(pi/2*sin(angle))
		and.w	d7,d0
		add.w	d0,d0
		move.w	0(a0,d0.w),d0

		asr.l	#1,d0
		and.w	d7,d0
		move.w	d0,d2
		addi.w	#1760,d2
		and.w	d7,d2
		add.w	d0,d0
		add.w	d2,d2
		move.w	0(a0,d0.w),d1
		move.w	0(a0,d2.w),d2

		moveq	#15,d0
		mulu	d5,d1
		mulu	d6,d2
		asr.l	d0,d1
		asr.l	d0,d2
		add.w	d5,d1
		add.w	d6,d2

		moveq.l	#0,d7		; d7.l = $0000ffff
		not.w	d7
		and.l	d7,d1
		and.l	d7,d2
		divu	#FLD_XSIZE,d1
		divu	#FLD_YSIZE,d2
		swap	d1
		swap	d2
		movem.w d1-d2,chrg2x

		rts

.angle:		dc.w	114



*********************************************
*  void plotFieldLines(d0.l x1y1, d1.l x2y2, a3.l * dstScreen)
*
* Plot field line effect based on current charge
* x, y position packed into d1, d2 in high word,
* low word order (2 charges).
* a3 points to a 4 bpl destination screen 160 bytes
* per scanline wide.
*********************************************

plotFieldLines:	movea.l angTablePtr,a0
		movea.l a0,a1

		move.w	d0,d2
		mulu	#2*FLD_XSIZE,d2
		adda.l	d2,a0
		swap	d0
		adda.w	d0,a0

		move.w	d1,d2
		mulu	#2*FLD_XSIZE,d2
		adda.l	d2,a1
		swap	d1
		adda.w	d1,a1

		movem.l c2pTable1,d2-d5	; Byte aligned c2p table preshifts

		move.w	#FLD_YSIZE-1,d0

.yloop:

ofs	set 0
	rept FLD_XSIZE/8
		move.b	(a0)+,d2	; 1st pixel
		sub.b	(a1)+,d2
		movea.l d2,a2
		move.l	(a2),d7

		move.b	(a0)+,d3	; 2nd pixel
		sub.b	(a1)+,d3
		movea.l d3,a2
		or.l	(a2),d7

		move.b	(a0)+,d4	; 3rd pixel
		sub.b	(a1)+,d4
		movea.l d4,a2
		or.l	(a2),d7

		move.b	(a0)+,d5	; 4th pixel
		sub.b	(a1)+,d5
		movea.l d5,a2
		or.l	(a2),d7

		movep.l d7,ofs(a3)

		move.b	(a0)+,d2
		sub.b	(a1)+,d2
		movea.l d2,a2
		move.l	(a2),d7

		move.b	(a0)+,d3
		sub.b	(a1)+,d3
		movea.l d3,a2
		or.l	(a2),d7

		move.b	(a0)+,d4
		sub.b	(a1)+,d4
		movea.l d4,a2
		or.l	(a2),d7

		move.b	(a0)+,d5
		sub.b	(a1)+,d5
		movea.l d5,a2
		or.l	(a2),d7

		movep.l d7,ofs+1(a3)

ofs	set ofs+8
	endr
		lea	BYTESPERSCL(a3),a3
		lea	FLD_XSIZE(a0),a0
		lea	FLD_XSIZE(a1),a1
		dbra	d0,.yloop
		rts

*********************************************
*  void fieldMain()
*
* Fieldline effect animation mainloop.
*********************************************

fieldMain:	bsr.w	getTime
		tst.w	d0		; Don't let VBL count drop below 1
		bne.s	.draw
      		moveq.l	#1,d0

.draw:		mulu.w	#256*190/60/4,d0
		lsr.l	#8,d0
		bsr.w	moveCharges

		movem.l chrg1x(pc),d0-d1	; Charge x, y positions
		movea.l screen3(pc),a3		; Destination address
		lea.l	(BYTESPERSCL-FLD_XSIZE)/2+80*(SCANLINES-FLD_YSIZE)(a3),a3 ; Center screen window

		bsr.w	plotFieldLines
		bra.w	cycleScreens


		bss
c2p:		ds.b	256		; Alignment
		ds.l	4*64

		ds.w	$0102
atan:		ds.w	$0102

angTablePtr:	ds.l	1		; Angular field line table
