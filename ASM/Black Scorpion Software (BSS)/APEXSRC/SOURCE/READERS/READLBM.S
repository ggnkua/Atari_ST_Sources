*-----------------------------------------------------------------------*
*	UNPACK 'IFF' RASTERFILE								*
*-----------------------------------------------------------------------*

			rsreset
BMHD_Head		rs.l	1
BMHD_Width		rs.w	1
BMHD_Height		rs.w	1
BMHD_X		rs.w	1
BMHD_Y		rs.w	1
BMHD_Planes		rs.b	1
BMHD_Mask		rs.b	1	; 0-no. 1,2,3-yes.
BMHD_Compression	rs.b	1	; 0-no. 1-yes.
			rs.b	1
BMHD_Transcol	rs.b	1	; if mask=2

			rsreset
CAMG_Head		rs.l	1
CAMG_Format		rs.l	1	; bit 11-HAM 3-Interlaced

AMIGA_INT		=	3
AMIGA_HAM		=	11

*-----------------------------------------*

FIND_HEADER:
	move.l	IFF_PTR,a0
	move.w	#1024-1,d7
	move.l	d0,d1
	lsr.l		#8,d1
	move.l	d1,d2
	lsr.l		#8,d2
	move.l	d2,d3
	lsr.l		#8,d3
.find	cmp.b		(a0),d3
	bne.s		.next
	cmp.b		1(a0),d2
	bne.s		.next
	cmp.b		2(a0),d1
	bne.s		.next
	cmp.b		3(a0),d0
	beq.s		.got
.next	addq		#1,a0
	dbra		d7,.find
	moveq		#-1,d0
	bra.s		.out
.got	addq		#4,a0
	moveq		#0,d0
.out	rts

*-----------------------------------------*

EXAMINE_IFF:
*-----------------------------------------*
*	Search for AMIGA attributes		*
*-----------------------------------------*
	move.l	#'CAMG',d0
	bsr		FIND_HEADER
	moveq		#0,d1
	tst.l		d0
	bmi.s		.norm
	move.l	CAMG_Format(a0),d1	; bit 3-Interlace/bit 11-HAM
*-----------------------------------------*
*	Find basic attributes			*
*-----------------------------------------*
.norm	move.l	d1,IFF_Type
	move.l	#'BMHD',d0
	bsr		FIND_HEADER
	tst.l		d0
	bmi		IFF_error
*-----------------------------------------*
	move.b	BMHD_Compression(a0),IFF_Comp
	move.w	BMHD_Width(a0),d0
	beq		IFF_error
	move.w	d0,IFF_Width
	move.w	d0,d1
	add.w		#15,d0
	lsr.w		#4,d0
	move.w	d0,IFF_planewords
	add.w		d0,d0
	move.w	d0,IFF_planebytes
	move.w	BMHD_Height(a0),d0
	beq		IFF_error
	move.w	d0,IFF_Height
	moveq		#0,d0
	move.b	BMHD_Planes(a0),d0
	beq		IFF_error
	move.w	d0,IFF_Planes
	move.w	d0,d1
	add.w		d1,d1
	move.w	d1,wordgap
*-----------------------------------------*
	sf		IFF_HalfBrite
	moveq		#1,d1
	lsl.w		d0,d1
	cmp.w		#64,d1
	bne.s		.nEHB
	st		IFF_HalfBrite
	moveq		#32,d1
.nEHB	move.w	d1,IFF_Cols
*-----------------------------------------*
	move.l	IFF_Type,d2
	btst		#AMIGA_HAM,d2
	beq.s		.nHAM
	sf		IFF_HalfBrite
*-----------------------------------------*
	move.w	IFF_Planes,d0
	cmp.w		#12,d0
	bne.s		.nh12
	move.w	#16,IFF_Cols
	bra		.nHAM
*-----------------------------------------*
.nh12	cmp.w		#6,d0
	bge.s		.six
	moveq		#6,d0
.six	subq		#2,d0
	ble		IFF_error
	move.w	d0,hamplanes
	subq		#1,d0
	bmi		IFF_error
	move.w	d0,hambits
*-----------------------------------------*
	move.w	hamplanes,d0
	moveq		#1,d1
	lsl.w		d0,d1
	move.w	d1,IFF_Cols
*-----------------------------------------*
.nHAM	bsr		extract_iff_cols
	moveq		#0,d0
	rts

*-----------------------------------------*
DECODE_IFF:
*-----------------------------------------*
	move.l	#'BODY',d0
	bsr		FIND_HEADER
	tst.l		d0
	bmi		IFF_error
	addq		#4,a0
*-----------------------------------------*
	move.l	IFF_image,a1			; dest scrn.
	move.w	IFF_Height,d0
	subq		#1,d0
*-----------------------------------------*
	lea		iff_2_bpl(pc),a5
	cmp.w		#24,IFF_Planes
	beq.s		.i24
	move.l	IFF_Type,d2
	btst		#AMIGA_HAM,d2
	bne.s		.ham
	move.w	#16,wordgap
	bra.s		.skip
.ham	move.l	a1,a6
	move.l	PACK_SCR,a1
	lea		8192*1(a1),a1
	cmp.w		#12,IFF_Planes
	beq.s		.h12
	lea		ham68_2_rgb(pc),a5
	bra.s		.skip
.h12	lea		ham12_2_rgb(pc),a5
	bra.s		.skip
.i24	lea		iff24_2_rgb(pc),a5
	move.l	a1,a6
	move.l	PACK_SCR,a1
	lea		8192*1(a1),a1
*-----------------------------------------*
.skip	move.w	IFF_planewords,d1
	mulu		wordgap,d1
	move.w	d1,IFF_srcwidth
*-----------------------------------------*
	lea		raw_scanline(pc),a4
	tst.b		IFF_Comp
	beq.s		.ylp
	lea		cmp_scanline(pc),a4
*-----------------------------------------*
.ylp	move.w	IFF_Planes,d3
	subq		#1,d3
	moveq		#0,d4
.plp	lea		(a1,d4.w*2),a2
	addq		#1,d4
	jsr		(a4)
	dbra		d3,.plp
	jsr		(a5)
	dbra		d0,.ylp
	moveq		#0,d0
	rts

*-----------------------------------------*

cmp_scanline:
	move.l	PACK_SCR,a3
	move.w	IFF_planebytes,d6
.loop	move.b	(a0)+,d7
	ext.w		d7
	bmi.s		.comp
.copy	move.b	(a0)+,(a3)+
	subq		#1,d6
	ble.s		.exit
	dbra		d7,.copy
	bra.s		.loop
.comp	neg.w		d7
	move.b	(a0)+,d5
.unp	move.b	d5,(a3)+
	subq		#1,d6
	ble.s		.exit
	dbra		d7,.unp
	bra.s		.loop
.exit	move.l	a0,-(sp)
	move.l	PACK_SCR,a0
	bsr		raw_scanline
	move.l	(sp)+,a0
	rts

raw_scanline:
	move.w	IFF_planebytes,d6
	subq		#1,d6
.copy	move.b	(a0)+,(a2)
	subq		#1,d6
	bpl.s		.cont
	clr.b		1(a2)
	bra.s		.done
.cont	move.b	(a0)+,1(a2)
	add.w		wordgap,a2
	dbra		d6,.copy
.done	rts
	
IFF_error
	moveq		#-1,d0
	rts

iff_2_bpl:
	add.w		IFF_srcwidth,a1
	rts

iff24_2_rgb:
	push.w	d0
	push.l	a6
	push.l	a4
	push.l	a1
	move.l	PACK_SCR,a4
	lea		8192*2(a4),a4
	move.w	IFF_planewords,d6
	bra		.solp
.olp	move.l	PACK_SCR,a2
	lea		8192*3(a2),a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	moveq		#16-1,d4
.ilp	move.l	a2,a3
	moveq		#8-1,d0
.blu	lsl.w		-(a3)
	addx.b	d3,d3
	dbra		d0,.blu
	moveq		#8-1,d0
.grn	lsl.w		-(a3)
	addx.b	d2,d2
	dbra		d0,.grn
	moveq		#8-1,d0
.red	lsl.w		-(a3)
	addx.b	d1,d1
	dbra		d0,.red
	move.b	d1,(a4)+
	move.b	d2,(a4)+
	move.b	d3,(a4)+
	dbra		d4,.ilp
.solp	dbra		d6,.olp	
	move.l	PACK_SCR,a4
	lea		8192*2(a4),a4
	move.w	IFF_Width,d0
	bra.s		.sclp
.copy	move.b	(a4)+,d1
	move.b	(a4)+,d2
	move.b	(a4)+,d3
	bfins		d1,d6{16:8}
	bfins		d2,d6{21:8}
	bfins		d3,d6{27:8}
	move.w	d6,(a6)+
.sclp	dbra		d0,.copy
	pop.l		a1
	pop.l		a4
	pop.l		a6
	pop.w		d0
	add.w		dest_scrwidth,a6
	rts

ham68_2_rgb:
	push.w	d0
	push.l	a6
	push.l	a1
	move.l	PALETTE_PTR,a2
	clr.l		DR
	move.w	IFF_planewords,d7
	bra		.swlp
.wdlp	add.w		wordgap,a1
	moveq		#16-1,d6	
.btlp	lea		-(2*2)(a1),a3
	move.w	hambits,d5
	moveq		#0,d4
.plp	lsl.w		-(a3)
	addx.b	d4,d4
	dbra		d5,.plp
	move.l	a1,a3
	moveq		#0,d5
	lsl.w		-(a3)
	addx.b	d5,d5
	lsl.w		-(a3)
	addx.b	d5,d5
	tst.b		d5
	beq.s		.norm
	moveq		#8,d1
	sub.w		hamplanes,d1
	lsl.b		d1,d4
	move.b	DR,d1
	move.b	DG,d2
	move.b	DB,d3
	cmp.b		#1,d5
	beq.s		.c1
	cmp.b		#2,d5
	beq.s		.c2
	cmp.b		#3,d5
	beq.s		.c3
.norm	lea		1(a2,d4.w*4),a3
	move.b	(a3)+,d1
	move.b	(a3)+,d2
	move.b	(a3)+,d3
	bra.s		.set
.c1	move.b	d4,d3
	bra.s		.set
.c2	move.b	d4,d1
	bra.s		.set
.c3	move.b	d4,d2
.set	move.b	d1,DR
	move.b	d2,DG
	move.b	d3,DB
	bfins		d1,d4{16:8}
	bfins		d2,d4{21:8}
	bfins		d3,d4{27:8}
	move.w	d4,(a6)+
	dbra		d6,.btlp
.swlp	dbra		d7,.wdlp
	pop.l		a1
	pop.l		a6
	pop.w		d0
	add.w		dest_scrwidth,a6
	rts

ham12_2_rgb:
	push.w	d0
	push.l	a6
	push.l	a1
	move.l	PALETTE_PTR,a2
	move.w	IFF_planewords,d7
	bra		.swlp
.wdlp	add.w		wordgap,a1
	moveq		#16-1,d6	
.btlp	move.l	a1,a3
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#4-1,d5
.plp3	lsl.w		-(a3)
	addx.b	d3,d3
	dbra		d5,.plp3
	moveq		#4-1,d5
.plp2	lsl.w		-(a3)
	addx.b	d2,d2
	dbra		d5,.plp2
	moveq		#4-1,d5
.plp1	lsl.w		-(a3)
	addx.b	d1,d1
	dbra		d5,.plp1
	lsl.w		#4,d1
	lsl.w		#4,d2
	lsl.w		#4,d3
	bfins		d1,d4{16:8}
	bfins		d2,d4{21:8}
	bfins		d3,d4{27:8}
	move.w	d4,(a6)+
	dbra		d6,.btlp
.swlp	dbra		d7,.wdlp
	pop.l		a1
	pop.l		a6
	pop.w		d0
	add.w		dest_scrwidth,a6
	rts

DR:	ds.b		1
DG:	ds.b		1
DB:	ds.b		1
DD:	ds.b		1
	even
		
*-----------------------------------------*

extract_iff_cols:
	move.l	#'CMAP',d0
	bsr		FIND_HEADER
	tst.l		d0
	bmi		.nEHB
	addq		#4,a0
	move.l	PALETTE_PTR,a1
	move.w	#256-3-1,d0
.clr	clr.l		(a1)+
	dbra		d0,.clr
	move.l	#$FCFCFC,(a1)+
	move.l	#$A8A8A8,(a1)+
	move.l	#$585858,(a1)+
	move.l	PALETTE_PTR,a1
	move.w	IFF_Cols,d0
	subq		#1,d0
	bmi.s		.nEHB
	move.l	COLMASK,d1
	push.l	a0
.copy	addq.l	#1,a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	and.l		d1,-4(a1)
	dbra		d0,.copy
	pop.l		a0
	tst.b		IFF_HalfBrite
	beq.s		.nEHB
	move.w	IFF_Cols,d0
	subq		#1,d0
	bmi.s		.nEHB
	move.l	COLMASK,d1
.hbcl	move.b	(a0)+,d5
	move.b	(a0)+,d6
	move.b	(a0)+,d7
	lsr.b		d5
	lsr.b		d6
	lsr.b		d7
	addq.l	#1,a1
	move.b	d5,(a1)+
	move.b	d6,(a1)+
	move.b	d7,(a1)+
	and.l		d1,-4(a1)
	dbra		d0,.hbcl
.nEHB	rts

*-----------------------------------------*
			bss
*-----------------------------------------*

IFF_PTR:		ds.l	1
IFF_Planes:		ds.w	1
IFF_Cols:		ds.w	1
IFF_Width:		ds.w	1
IFF_Height:		ds.w	1
IFF_X:		ds.w	1
IFF_Y:		ds.w	1
IFF_srcwidth:	ds.w	1
IFF_planebytes:	ds.w	1
IFF_planewords:	ds.w	1
IFF_planesize:	ds.l	1
iff_handle:		ds.w	1
hambits:		ds.w	1
hamplanes:		ds.w	1
wordgap:		ds.w	1
IFF_Type:		ds.l	1
IFF_image:		ds.l	1
IFF_Comp:		ds.b	1
IFF_HalfBrite	ds.b	1
			even
			
*-----------------------------------------*
			text
*-----------------------------------------*

