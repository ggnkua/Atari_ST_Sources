*******************************************************************************
*									      *
*			'DrawLine V1.01' By TIP/SPREADPOINT		      *
*			ннннннннннннннннннннннннннннннннннн		      *
*									      *
*******************************************************************************

DL_Width	=	40
DL_Fill		=	0		; 0=NOFILL / 1=FILL
	IFEQ	DL_Fill
DL_MInterns	=	$CA
	ELSE
DL_MInterns	=	$4A
	ENDC

;нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
;	A0 = PlanePtr, A6 = $DFF002, D0/D1 = X0/Y0, D2/D3 = X1/Y1
;	D4 = PlaneWidth > Kills: D0-D4/A0-A1 (+D5 in Fill Mode)

DrawLine:	cmp.w	d1,d3		; Drawing only from Top to Bottom is
		bge.s	.y1ly2		; necessary for:
		exg	d0,d2		; 1) Up-down Differences (same coords)
		exg	d1,d3		; 2) Blitter Invert Bit (only at top of
					;    line)
.y1ly2:		sub.w	d1,d3		; D3 = yd

; Here we could do an Optimization with Special Shifts
; depending on the DL_Width value... I know it, but please, let it be.

		mulu	d4,d1		; Use muls for neg Y-Vals
		add.l	d1,a0		; Please don't use add.w here !!!
		moveq	#0,d1		; D1 = Quant-Counter
		sub.w	d0,d2		; D2 = xd
		bge.s	.xdpos
		addq.w	#2,d1		; Set Bit 1 of Quant-Counter (here it
					; could be a moveq)
		neg.w	d2
.xdpos:		moveq	#$f,d4		; D4 full cleaned (for later oktants
					; move.b)
		and.w	d0,d4
	IFNE	DL_Fill
		move.b	d4,d5		; D5 = Special Fill Bit
		not.b	d5
	ENDC
		lsr.w	#3,d0		; Yeah, on byte (necessary for bchg)...
		add.w	d0,a0		; ...Blitter ands automagically
		ror.w	#4,d4		; D4 = Shift
		or.w	#$B00+DL_MInterns,d4	; BLTCON0-codes
		swap	d4
		cmp.w	d2,d3		; Which Delta is the Biggest ?
		bge.s	.dygdx
		addq.w	#1,d1		; Set Bit 0 of Quant-Counter
		exg	d2,d3		; Exchange xd with yd
.dygdx:		add.w	d2,d2		; D2 = xd*2
		move.w	d2,d0		; D0 = Save for $52(a6)
		sub.w	d3,d0		; D0 = xd*2-yd
		addx.w	d1,d1		; Bit0 = Sign-Bit
		move.b	Oktants(PC,d1.w),d4	; In Low Byte of d4
						; (upper byte cleaned above)
		swap	d2
		move.w	d0,d2
		sub.w	d3,d2		; D2 = 2*(xd-yd)
		moveq	#6,d1		; D1 = ShiftVal (not necessary) 
					; + TestVal for the Blitter
		lsl.w	d1,d3		; D3 = BLTSIZE
		add.w	#$42,d3
		lea	$52-2(a6),a1	; A1 = CUSTOM+$52

; WARNING : If you use FastMem and an extreme DMA-Access (e.g. 6
; Planes and Copper), you should Insert a tst.b (a6) here (for the
; shitty AGNUS-BUG)

.wb:		btst	d1,(a6)		; Waiting for the Blitter...
		bne.s	.wb
	IFNE	DL_Fill
		bchg	d5,(a0)		; Inverting the First Bit of Line
	ENDC
;-------------- Not necessary, only for testing purposes ! (Cf Init Part...)
;		move.w	#$8000,$74-2(a6)
;		move.w	#-1,$44-2(a6)
;		move.w	#-1,$72-2(a6)
;		move.w	#DL_Width,$60-2(a6)
;		move.w	#DL_Width,$66-2(a6)
;--------------
		move.l	d4,$40-2(a6)	; Writing to the Blitter Regs as fast
		move.l	d2,$62-2(a6)	; as possible
		move.l	a0,$48-2(a6)
		move.w	d0,(a1)+
		move.l	a0,(a1)+	; Shit-Word Buffer Ptr...
		move.w	d3,(a1)
		rts
;нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
	IFNE	DL_Fill
SML		= 	2
	ELSE
SML		=	0
	ENDC

Oktants:	dc.b	SML+1,SML+1+$40
		dc.b	SML+17,SML+17+$40
		dc.b	SML+9,SML+9+$40
		dc.b	SML+21,SML+21+$40
;нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
;		Optimized Init Part... A6 = $DFF000 > Kills : D0-D2

DL_Init:	addq.w	#2,a6		; A6 = $DFF002 for DrawLine !
		moveq	#-1,d1
	IFGT	DL_Width-127
		move.w	#DL_Width,d0
	ELSE
		moveq	#DL_Width,d0
	ENDC
		moveq	#6,d2
.wb:		btst	d2,(a6)
		bne.s	.wb
		move.w	d1,$44-2(a6)
		move.w	d1,$72-2(a6)
		move.w	#$8000,$74-2(a6)
		move.w	d0,$60-2(a6)
		move.w	d0,$66-2(a6)
		rts

DL_Exit:	subq.w	#2,a6		; A6 = $DFF000
		rts

