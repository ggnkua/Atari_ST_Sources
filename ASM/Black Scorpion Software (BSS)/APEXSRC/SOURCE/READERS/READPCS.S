*-----------------------------------------------------------------------*
*		PCS FILE DECOMPRESSION SUBROUTINES					*
*-----------------------------------------------------------------------*
* IN:		FILEDATA		[.long]	points to a PCS picture file	*
* 		BITMAP_1		[.long]	points to a 32000 byte buffer	*
* 		BITMAP_2		[.long]	points to a 32000 byte buffer	*
* 		PALETTE_1		[.long]	points to a 19136 byte buffer	*
* 		PALETTE_2		[.long]	points to a 19136 byte buffer	*
*-----------------------------------------------------------------------*
* OUT:	FREQUENCY		[.byte]	picture frequency (50/60)Hz	*
* 		INTERLACE		[.byte]	if<>0, picture is SuperHAM	*
*-----------------------------------------------------------------------*

			rsreset
PCS_width		rs.w	1	; usually 320 for now
PCS_height		rs.w	1	; usually 200 for now
PCS_interlace	rs.b	1	; PCS-ST/E = 0 : SuperHam and Pchrome <> 0
PCS_ste		rs.b	1	; uses ste palette? 50/60Hz?
PCS_start		rs.b	0	; end of file header

*-----------------------------------------------------------------------*
*	UNPACK A STANDARD PCS FILE							*
*-----------------------------------------------------------------------*

INTERLACE:		ds.b	1
			even

SWAP_LIST:
BITMAP_1:		ds.l	1
PALETTE_1:		ds.l	1
BITMAP_2:		ds.l	1
PALETTE_2:		ds.l	1

UNPACK_PCS:
	clr.l		SCREEN_PTR_2
	clr.l		COLOUR_PTR_2
	lea		PCS_start(a0),a1
	move.l	a0,a6
	move.l	BITMAP_1,a0
	move.l	a0,SCREEN_PTR_1
	bsr.s		UNPACK_BITMAP
	move.l	PALETTE_1,a0
	move.l	a0,COLOUR_PTR_1
	bsr		UNPACK_PALETTE
	clr.b		INTERLACE
	tst.b		PCS_interlace(a6)
	beq.s		.done
	st		INTERLACE
	move.l	BITMAP_2,a0
	move.l	a0,SCREEN_PTR_2
	bsr.s		UNPACK_BITMAP
	move.l	PALETTE_2,a0
	move.l	a0,COLOUR_PTR_2
	bsr		UNPACK_PALETTE
	bsr		XOR_BITMAP
	bsr		XOR_PALETTE
.done	rts
	
UNPACK_BITMAP:			; decompress a bitmap.
	moveq		#0,d6
	move.w	#40,d2
	move.w	#200,d3
	moveq		#5,d4
	move.b	(a1)+,d7
	lsl.w		#8,d7
	move.b	(a1)+,d7
.Main	moveq		#0,d0
	subq		#1,d7
	bmi.s		.esc
	move.b	(a1)+,d0
	bmi.s		.B_block_copy
	beq.s		.W_run_length
	cmp.b		#1,d0
	beq.s		.W_block_copy
	bra.s		.B_run_length
.W_run_length
	move.b	(a1)+,d0
	lsl.w		#8,d0
	move.b	(a1)+,d0
.B_run_length
	subq		#1,d0
	move.b	(a1)+,d1
.run	move.b	d1,(a0,d6)
	addq		#1,d6
	and.w		#1,d6
	bne.s		.ok
	addq		#8,a0
.ok	subq		#1,d2				; drop 1 line
	bne.s		.fine
	moveq		#40,d2
	subq		#1,d3
	bne.s		.fine
	move.w	#200,d3
	lea		2-32000(a0),a0
	subq		#1,d4
	beq.s		.esc
.fine	dbra		d0,.run
	bra.s		.Main
.esc	rts
.B_block_copy
	neg.b		d0
	bra.s		.nw
.W_block_copy
	move.b	(a1)+,d0
	lsl.w		#8,d0
	move.b	(a1)+,d0
.nw	subq		#1,d0
.blk	move.b	(a1)+,d1
	move.b	d1,(a0,d6)
	addq		#1,d6
	and.w		#1,d6
	bne.s		.ok2
	addq		#8,a0
.ok2	subq		#1,d2				; drop 1 line
	bne.s		.fin2
	moveq		#40,d2
	subq		#1,d3
	bne.s		.fin2
	move.w	#200,d3
	lea		2-32000(a0),a0
	subq		#1,d4
	beq.s		.esc
.fin2	dbra		d0,.blk
	bra		.Main

UNPACK_PALETTE:				; decompress a palette
	move.b	(a1)+,d7
	lsl.w		#8,d7
	move.b	(a1)+,d7
.Main	moveq		#0,d0
	subq		#1,d7
	bmi.s		.esc
	move.b	(a1)+,d0
	bmi.s		.B_block_copy
	beq.s		.W_run_length
	cmp.b		#1,d0
	beq.s		.W_block_copy
	bra.s		.B_run_length
.W_run_length
	move.b	(a1)+,d0
	lsl.w		#8,d0
	move.b	(a1)+,d0
.B_run_length
	subq		#1,d0
	move.b	(a1)+,d1
	lsl.w		#8,d1
	move.b	(a1)+,d1
.run	move.w	d1,(a0)+
	dbra		d0,.run
	bra.s		.Main
.esc	rts
.B_block_copy
	neg.b		d0
	bra.s		.nw
.W_block_copy
	move.b	(a1)+,d0
	lsl.w		#8,d0
	move.b	(a1)+,d0
.nw	subq		#1,d0
.blk	move.b	(a1)+,d1
	lsl.w		#8,d1
	move.b	(a1)+,d1
	move.w	d1,(a0)+
	dbra		d0,.blk
	bra.s		.Main

XOR_BITMAP:						; delta decompression on bitmap.
	btst.b	#0,PCS_interlace(a6)
	bne.s		.nox
	pushall
	move.l	BITMAP_1,a0
	move.l	BITMAP_2,a1
	move.w	#32000/4-1,d0
.blop	move.l	(a0)+,d1
	eor.l		d1,(a1)+
	dbra		d0,.blop
	popall
.nox	rts

XOR_PALETTE:						; delta decompression on palette.
	btst.b	#1,PCS_interlace(a6)
	bne.s		.nox
	pushall
	move.l	PALETTE_1,a0
	move.l	PALETTE_2,a1
	move.w	#16*(3*199+1)-1,d0
.clop	move.w	(a0)+,d1
	eor.w		d1,(a1)+
	dbra		d0,.clop
	popall
.nox	rts

Xreg			equr	d1
Yreg			equr	d2
Scrn			equr	a0
Color			equr	a1
Table			equr	a2

DECODE_PCS:
	lea		PCS_CONVERSION_TABLE,Table
	move.l	SCREEN_PTR_1(pc),d0
	beq		EXIT
	move.l	d0,Scrn
	move.l	COLOUR_PTR_1(pc),d0
	beq		EXIT
	move.l	d0,Color
	move.w	Xreg,d0
	lsl.w		#4,d0
	lea		(Table,d0),a3
	move.w	Yreg,d0
	lsl.w		#5,d0
	move.w	d0,d3
	add.w		d0,d0
	add.w		d3,d0
	lea		-64(Color,d0),a4
	move.w	Xreg,d0
	move.w	d0,d3
	and.b		#$F0,d3
	lsr.w		d3
	move.w	Yreg,d4
	lsl.w		#5,d4
	move.w	d4,d5
	add.w		d5,d5
	add.w		d5,d5
	add.w		d4,d5
	add.w		d3,d5
	lea		(Scrn,d5),a5
	move.w	(a5)+,d3
	move.w	(a5)+,d4
	move.w	(a5)+,d5
	move.w	(a5)+,d6
	move.w	#$8000,d7
	and.w		#16-1,d0
	lsr.w		d0,d7
	and.w		d7,d3
	and.w		d7,d4
	and.w		d7,d5
	and.w		d7,d6
	addq		#1,d0
	rol.w		d0,d3
	addq		#1,d0
	rol.w		d0,d4
	addq		#1,d0
	rol.w		d0,d5
	addq		#1,d0
	rol.w		d0,d6
	or.w		d3,d4
	or.w		d4,d5
	or.w		d5,d6
	tst.w		d6
	bne.s		.cont
	cmp.w		#320-4,Xreg
	blt.s		.cont
	moveq		#0,d0
	bra.s		.forc
.cont	move.b	(a3,d6),d0
	ext.w		d0
	asl.w		#5,d0			; palette (*32) 
	add.w		d6,d0			; colour in pal (*2)
	add.w		d6,d0
	move.w	(a4,d0),d0		; points to actual colour
.forc	move.w	d0,a6
	move.w	d0,d3
	move.l	SCREEN_PTR_2(pc),d0
	beq		.done
	move.l	d0,Scrn
	move.l	COLOUR_PTR_2(pc),d0
	beq		EXIT
	move.l	d0,Color
	move.w	Xreg,d0
	lsl.w		#4,d0
	lea		(Table,d0),a3
	move.w	Yreg,d0
	lsl.w		#5,d0
	move.w	d0,d3
	add.w		d0,d0
	add.w		d3,d0
	lea		-64(Color,d0),a4
	move.w	Xreg,d0
	move.w	d0,d3
	and.b		#$F0,d3
	lsr.w		d3
	move.w	Yreg,d4
	lsl.w		#5,d4
	move.w	d4,d5
	add.w		d5,d5
	add.w		d5,d5
	add.w		d4,d5
	add.w		d3,d5
	lea		(Scrn,d5),a5
	move.w	(a5)+,d3
	move.w	(a5)+,d4
	move.w	(a5)+,d5
	move.w	(a5)+,d6
	move.w	#$8000,d7
	and.w		#16-1,d0
	lsr.w		d0,d7
	and.w		d7,d3
	and.w		d7,d4
	and.w		d7,d5
	and.w		d7,d6
	addq		#1,d0
	rol.w		d0,d3
	addq		#1,d0
	rol.w		d0,d4
	addq		#1,d0
	rol.w		d0,d5
	addq		#1,d0
	rol.w		d0,d6
	or.w		d3,d4
	or.w		d4,d5
	or.w		d5,d6
	tst.w		d6
	bne.s		.con2
	cmp.w		#320-4,Xreg
	blt.s		.con2
	moveq		#0,d3
	bra.s		.done
.con2	move.b	(a3,d6),d0
	ext.w		d0
	asl.w		#5,d0			; palette (*32) 
	add.w		d6,d0			; colour in pal (*2)
	add.w		d6,d0
	move.w	(a4,d0),d3		; points to actual colour
.done	move.w	a6,d0
	move.w	d0,d4
	lsl.w		d0
	and.w		#%0000111011101110,d0
	and.w		#%0000100010001000,d4
	lsr.w		#3,d4
	or.w		d4,d0
	move.w	d3,d4
	lsl.w		d3
	and.w		#%0000111011101110,d3
	and.w		#%0000100010001000,d4
	lsr.w		#3,d4
	or.w		d4,d3
	move.w	d0,d1
	move.w	d1,d2
	and.w		#$F,d2
	lsr.w		#4,d1
	and.w		#$F,d1
	lsr.w		#8,d0
	move.w	d3,d4
	move.w	d4,d5
	and.w		#$F,d5
	lsr.w		#4,d4
	and.w		#$F,d4
	lsr.w		#8,d3
	add.w		d3,d0
	add.w		d4,d1
	add.w		d5,d2
	lsl.b		#3,d0	
	lsl.b		#3,d1
	lsl.b		#3,d2
	rts

DECODE_SPU:
	lea		SPU_CONVERSION_TABLE,Table
	move.l	SCREEN_PTR_1(pc),d0
	beq		EXIT
	move.l	d0,Scrn
	move.l	COLOUR_PTR_1(pc),d0
	beq		EXIT
	move.l	d0,Color
	move.w	Xreg,d0
	lsl.w		#4,d0
	lea		(Table,d0),a3
	move.w	Yreg,d0
	lsl.w		#5,d0
	move.w	d0,d3
	add.w		d0,d0
	add.w		d3,d0
	lea		-64(Color,d0),a4
	move.w	Xreg,d0
	move.w	d0,d3
	and.b		#$F0,d3
	lsr.w		d3
	move.w	Yreg,d4
	lsl.w		#5,d4
	move.w	d4,d5
	add.w		d5,d5
	add.w		d5,d5
	add.w		d4,d5
	add.w		d3,d5
	lea		(Scrn,d5),a5
	move.w	(a5)+,d3
	move.w	(a5)+,d4
	move.w	(a5)+,d5
	move.w	(a5)+,d6
	move.w	#$8000,d7
	and.w		#16-1,d0
	lsr.w		d0,d7
	and.w		d7,d3
	and.w		d7,d4
	and.w		d7,d5
	and.w		d7,d6
	addq		#1,d0
	rol.w		d0,d3
	addq		#1,d0
	rol.w		d0,d4
	addq		#1,d0
	rol.w		d0,d5
	addq		#1,d0
	rol.w		d0,d6
	or.w		d3,d4
	or.w		d4,d5
	or.w		d5,d6
	move.b	(a3,d6),d0
	ext.w		d0
	asl.w		#5,d0			; palette (*32) 
	add.w		d6,d0			; colour in pal (*2)
	add.w		d6,d0
	move.w	(a4,d0),d0		; points to actual colour
	move.w	d0,d4
	lsl.w		d0
	and.w		#%0000111011101110,d0
	and.w		#%0000100010001000,d4
	lsr.w		#3,d4
	or.w		d4,d0
	move.w	d0,d1
	move.w	d1,d2
	and.w		#$F,d2
	lsr.w		#4,d1
	and.w		#$F,d1
	lsr.w		#8,d0
	lsl.b		#4,d0	
	lsl.b		#4,d1
	lsl.b		#4,d2
EXIT:	rts

SCREEN_PTR_1:	dc.l	0
COLOUR_PTR_1:	dc.l	0
SCREEN_PTR_2:	dc.l	0
COLOUR_PTR_2:	dc.l	0
