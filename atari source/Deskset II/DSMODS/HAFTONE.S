
		.globl	_haftone


_haftone:

*	Scale a 16 color ST format image and transform to monochrome
*	domain using luminance value of pixels as input to a dither matrix.
*
*
*   iN:	sp+4	pointer to 28 byte image structure
*
*		+00	Source Memory Form base address
*		+04	width of memory form (in bytes)
*		+06	Xmin of source rectangle to be scaled and halftoned
*		+08	Ymin
*		+10	Width  (in pixels)
*		+12	Height (in pixels)
*
*		+14	Destination Memory Form base address
*		+18	width of memory form (in bytes)
*		+20	Xmin of destination rectangle
*		+22	Ymin
*		+24	Width
*		+26	Height
*
*	sp+8	pointer to 16 consecutive words of color information
*
*			each color word is in ST format:
*
*			RED <10:8>  GREEN <6:4>  BLUE <2:0>

	move.l	4(sp),a1	; a5 -> image structure
	move.l	8(sp),a0	; a0 -> color LUT values
	movem.l d3-d7/a3-a5,-(sp)
	move.l	a1,a5
	lea	halfbuf,a1	; a1 -> target area for dither matricies
	bsr	makehalf	; build the dither data

	clr.w	d0		; select appropriate scaling subroutine
	move.w	SRC_WD(a5),d1
	sub.w	DST_WD(a5),d1
	addx.w	d0,d0
	move.w	SRC_HT(a5),d1
	sub.w	DST_HT(a5),d1
	roxl.w	#3,d0
	move.l	halftbl(pc,d0.w),a0	
	jmp	(a0)

halftbl:

	dc.l	half400		; Dst Wd =< Src Wd   Dst Ht =< Src Ht   
	dc.l	half401		; Dst Wd =< Src Wd   Dst Ht  > Src Ht   
	dc.l	half410		; Dst Wd  > Src Wd   Dst Ht =< Src Ht   
	dc.l	half411		; Dst Wd  > Src Wd   Dst Ht  > Src Ht   



WS		set	-28

HAF_BASE	set	-28
HAF_RCTR	set	-24
SRC_ADDR	set	-22
SRC_X1ST	set	-18
SRC_SCNT	set	-16
DST_HCTR	set	-14
DST_ADDR	set	-12
DST_X1ST	set	-08
DDA_XINI	set	-06
DDA_YACC	set	-04
DDA_YINC	set	-02

half400:

*	Scale Down in X and Y
*
*  iN:
*	a1	pointer to initialized halftone table area
*	a5	pointer to parameter structure

	link	a6,#WS			; a6 -> temporary workspace

	move.l	a1,a2
	move.l	a1,HAF_BASE(a6)
	clr.w	HAF_RCTR(a6)

	move.l	SRC_BASE(a5),a0
	move.w	SRC_YMIN(a5),d0
	mulu	SRC_NXLN(a5),d0
	add.l	d0,a0
	move.w	SRC_XMIN(a5),d0
	move.w	d0,d1
	and.w	#$FFF0,d0
	lsr.w	#1,d0
	add.w	d0,a0
	move.l	a0,SRC_ADDR(a6)		; src starting address
	moveq.l	#15,d2
	and.w	d2,d1
	move.w	d1,SRC_SCNT(a6)		; src shift count for 1st word
	eor.w	d2,d1
	move.w	d1,SRC_X1ST(a6)		; src pixel counter for 1st word

	move.l	DST_BASE(a5),a1
	move.w	DST_YMIN(a5),d1
	mulu	DST_NXLN(a5),d1
	add.l	d1,a1
	move.w	DST_XMIN(a5),d1
	move.w	d1,d0
	lsr.w	#4,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	a1,DST_ADDR(a6)
	not.w	d0
	and.w	d2,d0
	move.w	d0,DST_X1ST(a6)

	move.w	DST_HT(a5),d0
	move.w	d0,d1
	subq.w	#1,d1
	move.w	d1,DST_HCTR(a6)

	swap	d0
	clr.w	d0
	divu	SRC_HT(a5),d0
	bvc.s	.1

	swap	d0
	move.w	#$FFFF,d0

.1:	move.w	d0,DDA_YINC(a6)
	swap	d0
	move.w	d0,DDA_YACC(a6)

	move.w	DST_WD(a5),d0
	swap	d0
	clr.w	d0
	divu	SRC_WD(a5),d0
	bvc.s	.2

	swap	d0
	move.w	#$FFFF,d0

.2:	move.w	d0,a3			; a3 <- X DDA accumulator
	swap	d0
	move.w	d0,DDA_XINI(a5)

	move.w	SRC_NXLN(a5),d0
	bra	.70


.10:	add.w	a3,d4		; advance the SRC DDA accumulator
	bcs.s	.15		; fetch pixel if DDA rollover

	add.l	d0,d0		; otherwise skip the pixel
	add.l	d1,d1
	dbra	d2,.10		; check for SRC word fault

	moveq.l	#15,d2		; d2 <- src pixel counter for next word
	move.l	(a0)+,d0	; reload source pixel cache with 
	move.l	(a0)+,d1	; the next 16 pixels
	bra.s	.10


.15:	clr.w	d7		; isolate next logical pixel
	add.w	d1,d1
	addx.w	d7,d7
	swap	d1
	add.w	d1,d1
	addx.w	d7,d7
	swap	d1
	add.w	d0,d0
	addx.w	d7,d7
	swap	d0
	add.w	d0,d0
	roxl.w	#2,d7		; d7 <- offset into relevant dither matrix 
	swap	d0
	dbra	d2,.20		; check for SRC word fault 

	moveq.l	#15,d2		; d2 <- src pixel counter for next word
	move.l	(a0)+,d0	; reload source pixel cache with 
	move.l	(a0)+,d1	; the next 16 pixels

.20:	move.w	(a2,d7.w),d7	; d7 <- dither data: is pixel on or off at X

.30:	btst.l	d3,d7		; given luminance, does dst pix get set ?
	beq.s	.40

	bset.l	d3,d5

.40:	dbra	d3,.50		; destination word fault ?

	moveq.l	#15,d3		; d3 <- hi bit of dst halftone cache word
	or.w	d5,(a1)+	; OR halftone cache into dst
	clr.w	d5		; reinit dst buffer

.50:	dbra	d6,.10		; d6 <- destination pixels remaining

	or.w	d5,(a1)		; flush dst buffer

	move.l	SRC_ADDR(a6),a0
	move.l	DST_ADDR(a6),a1
	add.w	DST_NXLN(a5),a1	; a1 -> first word of next dst line
	move.l	a1,DST_ADDR(a6)

	move.l	HAF_BASE(a6),a2
	move.w	HAF_RCTR(a6),d7
	add.w	#$0020,d7
	and.w	#$00E0,d7
	add.w	d7,a2		; a2 -> halftone dither matrix array for line n
	move.w	d7,HAF_RCTR(a6)

	move.w	SRC_NXLN(a5),d0
	add.w	d0,a0

.70:	move.w	DDA_YINC(a6),d1
	move.w	DDA_YACC(a6),d2

.80:	add.w	d1,d2
	bcs.s	.90
	add.w	d0,a0
	bra.s	.80	

.90:	move.w	d2,DDA_YACC(a6)
	move.l	a0,SRC_ADDR(a6)

	move.w	SRC_SCNT(a6),d2	; load src pixel cache and
	move.l	(a0)+,d0	; adjust registers so that the bits
	move.l	(a0)+,d1	; of the first pixel are in positions
	lsl.l	d2,d0		; 15 and 31 of each register
	lsl.l	d2,d1

	move.w	SRC_X1ST(a6),d2	; d2 <- src pixel pointer
	move.w	DST_X1ST(a6),d3	; d3 <- dst pixel pointer
	move.w	DDA_XINI(a6),d4	; d4 <- reinited DDA X accumulator
	clr.w	d5		; clear dst pixel buffer
	move.w	DST_WD(a5),d6
	subq.w	#1,d6		; d6 <- src pixel counter

	subq.w	#1,DST_HCTR(a6)
	bcc	.10

	unlk	a6
	movem.l (sp)+,d3-d7/a3-a5
	rts




WS		set	-28

HAF_BASE	set	-28
HAF_RCTR	set	-24
SRC_ADDR	set	-22
SRC_X1ST	set	-18
SRC_SCNT	set	-16
SRC_HCTR	set	-14
DST_ADDR	set	-12
DST_X1ST	set	-08
DDA_XINI	set	-06
DDA_YACC	set	-04
DDA_YINC	set	-02

half401:

*	Scale Down in X
*	Scale Up in Y
*
*  iN:
*	a1	pointer to initialized halftone table area
*	a5	pointer to parameter structure

	link	a6,#WS			; a6 -> temporary workspace

	move.l	a1,a2
	move.l	a1,HAF_BASE(a6)
	clr.w	HAF_RCTR(a6)

	move.l	SRC_BASE(a5),a0
	move.w	SRC_YMIN(a5),d0
	mulu	SRC_NXLN(a5),d0
	add.l	d0,a0
	move.w	SRC_XMIN(a5),d0
	move.w	d0,d1
	and.w	#$FFF0,d0
	lsr.w	#1,d0
	add.w	d0,a0
	move.l	a0,SRC_ADDR(a6)		; src starting address
	moveq.l	#15,d2
	and.w	d2,d1
	move.w	d1,SRC_SCNT(a6)		; src shift count for 1st word
	eor.w	d2,d1
	move.w	d1,SRC_X1ST(a6)		; src pixel counter for 1st word

	move.l	DST_BASE(a5),a1
	move.w	DST_YMIN(a5),d1
	mulu	DST_NXLN(a5),d1
	add.l	d1,a1
	move.w	DST_XMIN(a5),d1
	move.w	d1,d0
	lsr.w	#4,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	a1,DST_ADDR(a6)
	not.w	d0
	and.w	d2,d0
	move.w	d0,DST_X1ST(a6)

	move.w	SRC_HT(a5),d0
	move.w	d0,d1
	subq.w	#1,d1
	move.w	d1,SRC_HCTR(a6)

	swap	d0
	clr.w	d0
	divu	DST_HT(a5),d0
	bvc.s	.1

	swap	d0
	move.w	#$FFFF,d0

.1:	move.w	d0,DDA_YINC(a6)
	swap	d0
	move.w	d0,DDA_YACC(a6)

	move.w	DST_WD(a5),d0
	swap	d0
	clr.w	d0
	divu	SRC_WD(a5),d0
	bvc.s	.2

	swap	d0
	move.w	#$FFFF,d0

.2:	move.w	d0,a3			; a3 <- X DDA accumulator
	swap	d0
	move.w	d0,DDA_XINI(a5)

	bra	.70


.10:	add.w	a3,d4		; advance the SRC DDA accumulator
	bcs.s	.15		; fetch pixel if DDA rollover

	add.l	d0,d0		; otherwise skip the pixel
	add.l	d1,d1
	dbra	d2,.10		; check for SRC word fault

	moveq.l	#15,d2		; d2 <- src pixel counter for next word
	move.l	(a0)+,d0	; reload source pixel cache with 
	move.l	(a0)+,d1	; the next 16 pixels
	bra.s	.10


.15:	clr.w	d7		; isolate next logical pixel
	add.w	d1,d1
	addx.w	d7,d7
	swap	d1
	add.w	d1,d1
	addx.w	d7,d7
	swap	d1
	add.w	d0,d0
	addx.w	d7,d7
	swap	d0
	add.w	d0,d0
	roxl.w	#2,d7		; d7 <- offset into relevant dither matrix 
	swap	d0
	dbra	d2,.20		; check for SRC word fault 

	moveq.l	#15,d2		; d2 <- src pixel counter for next word
	move.l	(a0)+,d0	; reload source pixel cache with 
	move.l	(a0)+,d1	; the next 16 pixels

.20:	move.w	(a2,d7.w),d7	; d7 <- dither data: is pixel on or off at X

.30:	btst.l	d3,d7		; given luminance, does dst pix get set ?
	beq.s	.40

	bset.l	d3,d5

.40:	dbra	d3,.50		; destination word fault ?

	moveq.l	#15,d3		; d3 <- hi bit of dst halftone cache word
	or.w	d5,(a1)+	; OR halftone cache into dst
	clr.w	d5		; reinit dst buffer

.50:	dbra	d6,.10		; d6 <- destination pixels remaining

	or.w	d5,(a1)		; flush dst buffer

	move.l	SRC_ADDR(a6),a0
	move.l	DST_ADDR(a6),a1

	move.w	DDA_YINC(a6),d0
	add.w	d0,DDA_YACC(a6)
	bcc.s	.60

	add.w	SRC_NXLN(a5),a0	; a0 -> first word of next src line
	move.l	a0,SRC_ADDR(a6)
	
	subq.w	#1,SRC_HCTR(a6)
	bcc.s	.60

	unlk	a6
	movem.l (sp)+,d3-d7/a3-a5
	rts

.60:	add.w	DST_NXLN(a5),a1	; a1 -> first word of next dst line
	move.l	a1,DST_ADDR(a6)

	move.l	HAF_BASE(a6),a2
	move.w	HAF_RCTR(a6),d7
	add.w	#$0020,d7
	and.w	#$00E0,d7
	add.w	d7,a2		; a2 -> halftone dither matrix array for line n
	move.w	d7,HAF_RCTR(a6)

.70:	move.w	SRC_SCNT(a6),d2	; load src pixel cache and
	move.l	(a0)+,d0	; adjust registers so that the bits
	move.l	(a0)+,d1	; of the first pixel are in positions
	lsl.l	d2,d0		; 15 and 31 of each register
	lsl.l	d2,d1

	move.w	SRC_X1ST(a6),d2	; d2 <- src pixel pointer
	move.w	DST_X1ST(a6),d3	; d3 <- dst pixel pointer
	move.w	DDA_XINI(a6),d4	; d4 <- reinited DDA accumulator
	clr.w	d5		; clear dst pixel buffer
	move.w	DST_WD(a5),d6
	subq.w	#1,d6		; d6 <- dst pixel counter
	bra	.10




WS		set	-28

HAF_BASE	set	-28
HAF_RCTR	set	-24
SRC_ADDR	set	-22
SRC_X1ST	set	-18
SRC_SCNT	set	-16
DST_HCTR	set	-14
DST_ADDR	set	-12
DST_X1ST	set	-08
DDA_XINI	set	-06
DDA_YACC	set	-04
DDA_YINC	set	-02


half410:

*	Scale Up in X
*	Scale Down in Y
*
*  iN:
*	a1	pointer to initialized halftone table area
*	a5	pointer to parameter structure

	link	a6,#WS			; a6 -> temporary workspace

	move.l	a1,a2
	move.l	a1,HAF_BASE(a6)
	clr.w	HAF_RCTR(a6)

	move.l	SRC_BASE(a5),a0
	move.w	SRC_YMIN(a5),d0
	mulu	SRC_NXLN(a5),d0
	add.l	d0,a0
	move.w	SRC_XMIN(a5),d0
	move.w	d0,d1
	and.w	#$FFF0,d0
	lsr.w	#1,d0
	add.w	d0,a0
	move.l	a0,SRC_ADDR(a6)		; src starting address
	moveq.l	#15,d2
	and.w	d2,d1
	move.w	d1,SRC_SCNT(a6)		; src shift count for 1st word
	eor.w	d2,d1
	move.w	d1,SRC_X1ST(a6)		; src pixel counter for 1st word

	move.l	DST_BASE(a5),a1
	move.w	DST_YMIN(a5),d1
	mulu	DST_NXLN(a5),d1
	add.l	d1,a1
	move.w	DST_XMIN(a5),d1
	move.w	d1,d0
	lsr.w	#4,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	a1,DST_ADDR(a6)
	not.w	d0
	and.w	d2,d0
	move.w	d0,DST_X1ST(a6)

	move.w	DST_HT(a5),d0
	move.w	d0,DST_HCTR(a6)

	swap	d0
	clr.w	d0
	divu	SRC_HT(a5),d0
	bvc.s	.1

	swap	d0
	move.w	#$FFFF,d0

.1:	move.w	d0,DDA_YINC(a6)
	swap	d0
	move.w	d0,DDA_YACC(a6)

	move.w	SRC_WD(a5),d0
	swap	d0
	clr.w	d0
	divu	DST_WD(a5),d0
	bvc.s	.2

	swap	d0
	move.w	#$FFFF,d0

.2:	move.w	d0,a3			; a3 <- Xinc
	swap	d0
	move.w	d0,DDA_XINI(a5)

	move.w	SRC_NXLN(a5),d0
	bra.s	.70


.10:	clr.w	d7			; isolate next logical pixel
	add.w	d1,d1
	addx.w	d7,d7
	swap	d1
	add.w	d1,d1
	addx.w	d7,d7
	swap	d1
	add.w	d0,d0
	addx.w	d7,d7
	swap	d0
	add.w	d0,d0
	roxl.w	#2,d7		; d7 <- offset into relevant dither matrix 
	swap	d0
	dbra	d2,.20		; does next pixel cause source word fault ?

	moveq.l	#15,d2		; d2 <- src pixel counter for next word
	move.l	(a0)+,d0	; reload source pixel cache with 
	move.l	(a0)+,d1	; the next 16 pixels

.20:	move.w	(a2,d7.w),d7	; d7 <- dither data: is pixel on or off at X

.30:	btst.l	d3,d7		; given luminance, does dst pix get set ?
	beq.s	.40

	bset.l	d3,d5

.40:	dbra	d3,.50		; destination word fault ?

	moveq.l	#15,d3		; d3 <- hi bit of dst halftone cache word
	or.w	d5,(a1)+	; OR halftone cache into dst
	clr.w	d5		; reinit dst buffer

.50:	add.w	a3,d4		; source DDA rollover ?
	bcc.s	.30		; if not, process next dst pixel.

	dbra	d6,.10		; d5 <- source pixels remaining

	or.w	d5,(a1)		; flush dst buffer


	move.l	SRC_ADDR(a6),a0
	move.l	DST_ADDR(a6),a1
	add.w	DST_NXLN(a5),a1	; a1 -> first word of next dst line
	move.l	a1,DST_ADDR(a6)

	move.l	HAF_BASE(a6),a2
	move.w	HAF_RCTR(a6),d7
	add.w	#$0020,d7
	and.w	#$00E0,d7
	add.w	d7,a2		; a2 -> halftone dither matrix array for line n
	move.w	d7,HAF_RCTR(a6)

	move.w	SRC_NXLN(a5),d0
	add.w	d0,a0

.70:	move.w	DDA_YINC(a6),d1
	move.w	DDA_YACC(a6),d2

.80:	add.w	d1,d2
	bcs.s	.90
	add.w	d0,a0
	bra.s	.80	

.90:	move.w	d2,DDA_YACC(a6)
	move.l	a0,SRC_ADDR(a6)

	move.w	SRC_SCNT(a6),d2	; load src pixel cache and
	move.l	(a0)+,d0	; adjust registers so that the bits
	move.l	(a0)+,d1	; of the first pixel are in positions
	lsl.l	d2,d0		; 15 and 31 of each register
	lsl.l	d2,d1

	move.w	SRC_X1ST(a6),d2	; d2 <- src pixel pointer
	move.w	DST_X1ST(a6),d3	; d3 <- dst pixel pointer
	move.w	DDA_XINI(a6),d4	; d4 <- reinited DDA X accumulator
	clr.w	d5		; clear dst pixel buffer
	move.w	SRC_WD(a5),d6
	subq.w	#1,d6		; d6 <- src pixel counter

	subq.w	#1,DST_HCTR(a6)
	bcc	.10

	unlk	a6
	movem.l (sp)+,d3-d7/a3-a5
	rts




WS		set	-28

HAF_BASE	set	-28
HAF_RCTR	set	-24
SRC_ADDR	set	-22
SRC_X1ST	set	-18
SRC_SCNT	set	-16
SRC_HCTR	set	-14
DST_ADDR	set	-12
DST_X1ST	set	-08
DDA_XINI	set	-06
DDA_YACC	set	-04
DDA_YINC	set	-02


half411:

*  iN:
*	a1	pointer to initialized halftone table area
*	a5	pointer to parameter structure

	link	a6,#WS			; a6 -> temporary workspace

	move.l	a1,a2
	move.l	a1,HAF_BASE(a6)
	clr.w	HAF_RCTR(a6)

	move.l	SRC_BASE(a5),a0
	move.w	SRC_YMIN(a5),d0
	mulu	SRC_NXLN(a5),d0
	add.l	d0,a0
	move.w	SRC_XMIN(a5),d0
	move.w	d0,d1
	and.w	#$FFF0,d0
	lsr.w	#1,d0
	add.w	d0,a0
	move.l	a0,SRC_ADDR(a6)		; src starting address
	moveq.l	#15,d2
	and.w	d2,d1
	move.w	d1,SRC_SCNT(a6)		; src shift count for 1st word
	eor.w	d2,d1
	move.w	d1,SRC_X1ST(a6)		; src pixel counter for 1st word

	move.l	DST_BASE(a5),a1
	move.w	DST_YMIN(a5),d1
	mulu	DST_NXLN(a5),d1
	add.l	d1,a1
	move.w	DST_XMIN(a5),d1
	move.w	d1,d0
	lsr.w	#4,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	a1,DST_ADDR(a6)
	not.w	d0
	and.w	d2,d0
	move.w	d0,DST_X1ST(a6)

	move.w	SRC_HT(a5),d0
	move.w	d0,d1
	subq.w	#1,d1
	move.w	d1,SRC_HCTR(a6)
	swap	d0
	clr.w	d0
	divu	DST_HT(a5),d0
	bvc.s	.1

	swap	d0
	move.w	#$FFFF,d0

.1:	move.w	d0,DDA_YINC(a6)
	swap	d0
	move.w	d0,DDA_YACC(a6)

	move.w	SRC_WD(a5),d0
	swap	d0
	clr.w	d0
	divu	DST_WD(a5),d0
	bvc.s	.2

	swap	d0
	move.w	#$FFFF,d0

.2:	move.w	d0,a3		; a3 <- Xinc
	swap	d0
	move.w	d0,DDA_XINI(a5)

	bra	.70


.10:	clr.w	d7		; isolate next logical pixel
	add.w	d1,d1
	addx.w	d7,d7
	swap	d1
	add.w	d1,d1
	addx.w	d7,d7
	swap	d1
	add.w	d0,d0
	addx.w	d7,d7
	swap	d0
	add.w	d0,d0
	roxl.w	#2,d7		; d7 <- offset into relevant dither matrix 
	swap	d0
	dbra	d2,.20		; does next pixel cause source word fault ?

	moveq.l	#15,d2		; d2 <- src pixel counter for next word
	move.l	(a0)+,d0	; reload source pixel cache with 
	move.l	(a0)+,d1	; the next 16 pixels

.20:	move.w	(a2,d7.w),d7	; d7 <- dither data: is pixel on or off at X

.30:	btst.l	d3,d7		; given luminance, does dst pix get set ?
	beq.s	.40

	bset.l	d3,d5

.40:	dbra	d3,.50		; destination word fault ?

	moveq.l	#15,d3		; d3 <- hi bit of dst halftone cache word
	or.w	d5,(a1)+	; OR halftone cache into dst
	clr.w	d5		; reinit dst buffer

.50:	add.w	a3,d4		; source DDA rollover ?
	bcc	.30		; if not, process next dst pixel.

	dbra	d6,.10		; d5 <- source pixels remaining

	or.w	d5,(a1)		; flush dst buffer

	move.l	SRC_ADDR(a6),a0
	move.l	DST_ADDR(a6),a1

	move.w	DDA_YINC(a6),d0
	add.w	d0,DDA_YACC(a6)
	bcc.s	.60

	add.w	SRC_NXLN(a5),a0	; a0 -> first word of next src line
	move.l	a0,SRC_ADDR(a6)

	subq.w	#1,SRC_HCTR(a6)
	bcc.s	.60

	unlk	a6
	movem.l (sp)+,d3-d7/a3-a5
	rts


.60:	add.w	DST_NXLN(a5),a1	; a1 -> first word of next dst line
	move.l	a1,DST_ADDR(a6)

	move.l	HAF_BASE(a6),a2
	move.w	HAF_RCTR(a6),d7
	add.w	#$0020,d7
	and.w	#$00E0,d7
	add.w	d7,a2		; a2 -> halftone dither matrix array for line n
	move.w	d7,HAF_RCTR(a6)

.70:	move.w	SRC_SCNT(a6),d2	; load src pixel cache and
	move.l	(a0)+,d0	; adjust registers so that the bits
	move.l	(a0)+,d1	; of the first pixel are in positions
	lsl.l	d2,d0		; 15 and 31 of each register
	lsl.l	d2,d1

	move.w	SRC_X1ST(a6),d2	; d2 <- src pixel pointer
	move.w	DST_X1ST(a6),d3	; d3 <- dst pixel pointer
	move.w	DDA_XINI(a6),d4	; d4 <- reinited DDA accumulator
	clr.w	d5		; clear dst pixel buffer
	move.w	SRC_WD(a5),d6
	subq.w	#1,d6		; d6 <- src pixel counter
	
	bra	.10






makehalf:

*  iN:
*	a0	points to 16 words of RGB data
*	a1	points to 256 byte area for halftone tables

	move.w	#15,d4

.0:	move.w	(a0)+,d0
	bsr	getlum
	mulu	#33,d2
	swap	d2
	lsl.w	#2,d2
	lea	dither(pc,d2.w),a2

	moveq.l	#3,d1

.1:	move.b	(a2)+,d0
	move.b	d0,000(a1)
	move.b	d0,001(a1)
	ror.b	#4,d0
	move.b	d0,128(a1)
	move.b	d0,129(a1)
	add.w	#32,a1
	dbra	d1,.1

	sub.w	#126,a1
	dbra	d4,.0

	sub.w	#32,a1
	rts


dither:

*      T h E   d I t H e R   m A t R i X
*
*
*	12  09  05  14  16  25  20  18
*
*	04  00  01  11  23  28  29  27
*
*	10  03  02  06  26  31  30  21
*
*	13  07  08  15  17  22  24  19
*
*	16  25  20  18  12  09  05  14
*
*	23  28  29  27  04  00  01  11
*
*	26  31  30  21  10  03  02  06
*
*	17  22  24  19  13  07  08  15

d00:	dc.b	$FF,$FF,$FF,$FF
d01:	dc.b	$FF,$FF,$FB,$FF
d02:	dc.b	$FF,$FF,$F9,$FF
d03:	dc.b	$FF,$FD,$F9,$FF
d04:	dc.b	$FF,$F9,$F9,$FF
d05:	dc.b	$FF,$F8,$F9,$FF
d06:	dc.b	$FF,$F8,$F1,$FF
d07:	dc.b	$FB,$F8,$F1,$FF
d08:	dc.b	$FB,$F8,$F1,$FD
d09:	dc.b	$FB,$F0,$F1,$FD
d10:	dc.b	$FB,$F0,$F1,$F9
d11:	dc.b	$FB,$F0,$F0,$F9
d12:	dc.b	$F9,$F0,$F0,$F9
d13:	dc.b	$F9,$F0,$F0,$F8
d14:	dc.b	$F8,$F0,$F0,$F8
d15:	dc.b	$F8,$F0,$F0,$F0
d16:	dc.b	$F0,$F0,$F0,$F0
d17:	dc.b	$F0,$F0,$F0,$E0
d18:	dc.b	$E0,$F0,$F0,$E0
d19:	dc.b	$E0,$F0,$F0,$60
d20:	dc.b	$60,$F0,$F0,$60
d21:	dc.b	$60,$E0,$F0,$60
d22:	dc.b	$60,$E0,$70,$60
d23:	dc.b	$20,$E0,$70,$60
d24:	dc.b	$20,$E0,$70,$40
d25:	dc.b	$20,$E0,$70,$00
d26:	dc.b	$20,$E0,$60,$00
d27:	dc.b	$00,$E0,$60,$00
d28:	dc.b	$00,$60,$60,$00
d29:	dc.b	$00,$60,$20,$00
d30:	dc.b	$00,$60,$00,$00
d31:	dc.b	$00,$40,$00,$00
d32:	dc.b	$00,$00,$00,$00


getlum:

*  iN:
*	d0	color		RED[10:08] GREEN[06:04] BLUE[02:00]
* ouT:
*	d2	luminance	BLACK:0000 WHITE:FFFF


	moveq.l	#$0E,d3
	move.w	d0,d1
	lsl.w	#1,d1
	and.w	d3,d1
	move.w	b11(pc,d1.w),d2
	move.w	d0,d1
	lsr.w	#3,d1
	and.w	d3,d1
	add.w	g59(pc,d1.w),d2
	lsr.w	#7,d0
	and.w	d3,d0
	add.w	r30(pc,d0.w),d2
	bcc.s	.1

	subx.w	d2,d2		

.1:
	rts



r30:	dc.w					    0
	dc.w	(($10000/7)*(($10000*30)/100))/$10000
	dc.w	(($20000/7)*(($10000*30)/100))/$10000
	dc.w	(($30000/7)*(($10000*30)/100))/$10000
	dc.w	(($40000/7)*(($10000*30)/100))/$10000
	dc.w	(($50000/7)*(($10000*30)/100))/$10000
	dc.w	(($60000/7)*(($10000*30)/100))/$10000
	dc.w			      ($10000*30)/100


g59:	dc.w					    0
	dc.w	(($10000/7)*(($10000*59)/100))/$10000
	dc.w	(($20000/7)*(($10000*59)/100))/$10000
	dc.w	(($30000/7)*(($10000*59)/100))/$10000
	dc.w	(($40000/7)*(($10000*59)/100))/$10000
	dc.w	(($50000/7)*(($10000*59)/100))/$10000
	dc.w	(($60000/7)*(($10000*59)/100))/$10000
	dc.w			      ($10000*59)/100


b11:	dc.w					    0
	dc.w	(($10000/7)*(($10000*11)/100))/$10000
	dc.w	(($20000/7)*(($10000*11)/100))/$10000
	dc.w	(($30000/7)*(($10000*11)/100))/$10000
	dc.w	(($40000/7)*(($10000*11)/100))/$10000
	dc.w	(($50000/7)*(($10000*11)/100))/$10000
	dc.w	(($60000/7)*(($10000*11)/100))/$10000
	dc.w			      ($10000*11)/100


		.bss

*	Halftone Dither Table Buffer

halfbuf:	ds.b	256


*	Parameter Block Structure

		.abs

SRC_BASE:	ds.l	1
SRC_NXLN:	ds.w	1
SRC_XMIN:	ds.w	1
SRC_YMIN:	ds.w	1
SRC_WD:		ds.w	1
SRC_HT:		ds.w	1
DST_BASE:	ds.l	1
DST_NXLN:	ds.w	1
DST_XMIN:	ds.w	1
DST_YMIN:	ds.w	1
DST_WD:		ds.w	1
DST_HT:		ds.w	1


