
* Routines for palette handling through GEM
*	by: M†rten Lindstr”m

***************************	Translates a palette colour index
*	PAL_PEN		into the corresponding VDI pen #
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN:  D0: Palette colour index (i.e. "Hardware colour number")
* OUT: D0: VDI pen number
* If input number is too high then carry flag will be set (test with BCS)
* and the colour number unchanged
*~~~~~~~~~~~~~~~~~~~~~~~~~~
PAL_PEN	movem.l	D6/A3,-(SP)
	bsr	gtpentb	Get palette-to-pen table
	subq.w	#1,D6
	cmp.w	D0,D6
	bcs.s	pal_pen1	Undefined palette index
	move.b	0(A3,D0.W),D0	Get pen
pal_pen1	movem.l	(SP)+,D6/A3
	rts

*************************** Gets/sets palette in 24-bit format using VDI
*     GETPAL    SETPAL      - i.e. the compatible way, but using "hardware"
*~~~~~~~~~~~~~~~~~~~~~~~~~~ (bitplane related) rather than VDI colour numbering
* IN: A0 -> (space for) palette in 24-bit format
*     D0 MSW: 0 (or screen start colour for a short palette)
*        LSW: Number of colours
*~~~~~~~~~~~~~~~~~~~~~~~~~~
GETPAL	movem.l	D0-D7/A0-A4,-(SP)
	lea	(A0),A4
	bsr	gtpentb	Get palette-to-pen table
	moveq	#0,D4	D4: VDI pen number
	move.w	(SP),D5	D5.W: Screen colour to start with
	move.l	(SP),D7	D7.W: Number of colours to get
	bra.s	getpal3
getpal1	move.b	0(A3,D5.W),D4	Get pen
	addq.w	#1,D5		(new palette index)
	vq_color	D4,#0	Get colour; Exact RGB values
	lea	intout+2-ppb(A3),A0	A0->intout+2 = Red component
	moveq	#2,D0
getpal2	moveq	#0,D1	Next component
	move.w	(A0)+,D1
	lsl.l	#8,D1	Multiply by 256
	divu	#1001,D1
	move.b	D1,(A4)+
	dbf	D0,getpal2
getpal3	cmp.w	D5,D6
	dbls	D7,getpal1
	movem.l	(SP)+,D0-D7/A0-A4
	rts

*==========================
SETPAL	movem.l	D0-D7/A0-A4,-(SP)
	lea	(A0),A4
	bsr.s	gtpentb
	moveq	#0,D4	D4: VDI pen number
	move.w	(SP),D5	D5.W: Screen colour to start with
	move.l	(SP),D7	D7.W: Number of colours to set
	bra.s	setpal3
setpal1	moveq	#2,D0	Set next colour
setpal2	move.w	D2,D1	Next component
	move.w	D3,D2
	moveq	#0,D3
	move.b	(A4)+,D3
	mulu	#1000,D3
	divu	#255,D3
	dbf	D0,setpal2
	move.b	0(A3,D5.W),D4
	addq.w	#1,D5
	vs_color	D4,D1,D2,D3
setpal3	cmp.w	D5,D6
	dbls	D7,setpal1
	movem.l	(SP)+,D0-D7/A0-A4
	rts

*==========================
gtpentb	lea	palpentb,A3	Get address to pen table
	move.l	(A3)+,D6	Number of colours on screen
	bne.s	gtpentb1
	bsr.s	mkpentb	If not initialized, initialize now
gtpentb1	rts
*========================== Create translation table if not already done
mkpentb	movem.l	D0-D7/A0-A2,-(SP)
	moveq	#0,D4	D4: 0
	moveq	#1,D5	D5: 1
	vq_extnd	D5
	cmp.w	#8,intout+8-ppb(A3)
	bls.s	mkpentb1	# of colour bitplanes ó 8

	moveq	#-1,D6	Otherwise flag for table done
	clr.w	D6	But containing no colours
	bra.s	mkpentb4

mkpentb1	wind_update #1	BEG_UPDATE
	graf_mouse #256,#0	Hide mouse

	vswr_mode D5	Set writing mode to replace
	vsm_type	D5	Set marker type to single pixel
	v_get_pixel D4,D4
	move.w	intout+2-ppb(A3),D7	Save VDI pen for pixel (0,0)

	move.w	#$100,D3	Max 256 colours
	bra.s	mkpentb3	Begin with colour pen 0

mkpentb2	clr.l	ptsin-ppb(A3)	At (0,0)
	v_pmarker D5	 plot one marker
	v_get_pixel D4,D4
	move.w	intout-ppb(A3),D0	Get palette index #
	move.b	D6,0(A3,D0.W)	Store VDI pen # at appropriate place
	addq.w	#1,D6	Next pen
mkpentb3	vsm_color D6
	cmp.w	D6,intout-ppb(A3)	Pen set = Pen requested?
	dbne	D3,mkpentb2	Continue as long as this is the case

	vsm_color D7	Restore pixel (0,0)
	clr.l	ptsin-ppb(A3)	At (0,0)
	v_pmarker D5	 plot one pixel
	graf_mouse #257,#0	Show mouse
	wind_update #0	END_UPDATE
mkpentb4	move.l	D6,-4(A3)	Note number of colours
	movem.l	(SP)+,D0-D7/A0-A2
	rts		D6.W: Number of colours on screen

	BSS
palpentb	ds.l	1
ppb	ds.b	256
	TEXT
