*-----------------------------------------------------------------------*
*	UNPACK 'IFF' RASTERFILE								*
*-----------------------------------------------------------------------*

			rsreset
ANIM_oper		rs.b	1
ANIM_bitmask	rs.b	1
ANIM_xorwidth	rs.w	1
ANIM_xorheight	rs.w	1
ANIM_xorx		rs.w	1
ANIM_xory		rs.w	1
ANIM_abstime	rs.l	1
ANIM_reltime	rs.l	1
ANIM_ileave		rs.w	1
ANIM_modebits	rs.l	1
ANIM_extras		rs.b	16

ANHD_copy		=	0
ANHD_xor		=	1
ANHD_longdelta	=	2
ANHD_shortdelta	=	3
ANHD_general	=	4
ANHD_bytevert	=	5

			even
DLTA_datasize	rs.b	1
DLTA_copyxor	rs.b	1
DLTA_infouse	rs.b	1
DLTA_rawrun		rs.b	1
DLTA_horivert	rs.b	1
DLTA_infosize	rs.b	1

*-----------------------------------------*
read_form:
*-----------------------------------------*
	move.w	BUFFER2_HANDLE,d0
	jsr		Find_block
	move.l	a0,FILE_BUFFER
*-----------------------------------------*
	moveq		#12,d1	
	sub.l		d1,filebytes
	move.l	FILE_BUFFER,a0	; read in 'FORM',size,'ILBM'
	move.w	ANM_handle,d0
	jsr		ReadFile
	tst.l		d0
	bmi		.err
	tst.l		filebytes
	ble.s		.done
*-----------------------------------------*
	move.l	FILE_BUFFER,a0
	cmp.l		#'FORM',(a0)+
	bne.s		.prob
	move.l	(a0)+,d0
	subq.l	#4,d0
	move.l	d0,formbytes
	ble.s		.exit
	cmp.l		#'ILBM',(a0)
	bne.s		.prob
*-----------------------------------------*
.load	move.l	formbytes,d1
	sub.l		d1,filebytes
	move.l	FILE_BUFFER,a0	
	move.w	ANM_handle,d0
	jsr		ReadFile
	tst.l		d0
	bmi		.err
	tst.l		filebytes
	ble.s		.done
*-----------------------------------------*
.exit	moveq		#0,d0
.rts	rts
*-----------------------------------------*
.done	st		anim_done
	moveq		#0,d0
	rts
*-----------------------------------------*
.err	moveq		#-1,d0
	rts
*-----------------------------------------*
.prob	moveq		#4,d1	
	move.l	FILE_BUFFER,a0
	move.w	ANM_handle,d0
	sub.l		d1,filebytes
	jsr		ReadFile
	tst.l		d0
	bmi		.err
	tst.l		filebytes
	ble.s		.done
*-----------------------------------------*
	move.l	FILE_BUFFER,a0
	cmp.l		#'FORM',(a0)
	bne.s		.prob
*-----------------------------------------*
	moveq		#8,d1
	move.l	FILE_BUFFER,a0
	move.w	ANM_handle,d0
	sub.l		d1,filebytes
	jsr		ReadFile
	tst.l		d0
	bmi		.err
	tst.l		filebytes
	ble.s		.done
*-----------------------------------------*
	move.l	FILE_BUFFER,a0
	move.l	(a0)+,formbytes
	ble.s		.exit
	cmp.l		#'ILBM',(a0)
	bne.s		.prob
	bra		.load

*-----------------------------------------*
scan_form:
*-----------------------------------------*
	push.l	d0
	move.w	BUFFER2_HANDLE,d0
	jsr		Find_block
	pop.l		d0
	move.l	formbytes,d1
	subq.l	#2,d1
	ble.s		.err
.look	cmp.l		(a0)+,d0
	beq.s		.got
	subq.l	#2,a0
	subq.l	#2,d1
	bne.s		.look
.err	moveq		#-1,d0
	rts
.got	moveq		#0,d0
	rts

*-----------------------------------------*
OPEN_ANIM:
*-----------------------------------------*
	st		first_pass
	sf		anim_done
	move.w	#-1,ANM_handle
	lea		FILENAME,a0
	jsr		OpenFile
	tst.l		d0
	bmi		ANIM_error
	move.w	d0,ANM_handle
*-----------------------------------------*
*	Check file for correct I.D		*
*-----------------------------------------*
	move.w	BUFFER2_HANDLE,d0
	jsr		Find_block
	move.l	a0,FILE_BUFFER
	moveq		#12,d1
	move.w	ANM_handle,d0
	jsr		ReadFile
	move.l	FILE_BUFFER,a0
	cmp.l		#'FORM',(a0)+
	bne		ANIM_error
	move.l	(a0)+,filebytes
	cmp.l		#'ANIM',(a0)+
	bne		ANIM_error
	subq.l	#4,filebytes
*-----------------------------------------*
*	Read first frame & attributes		*
*-----------------------------------------*
	jsr		read_form
*-----------------------------------------*
*	Search for AMIGA attributes		*
*-----------------------------------------*
	move.l	#'CAMG',d0
	bsr		scan_form
	moveq		#0,d1
	tst.l		d0
	bmi.s		.norm
*-----------------------------------------*
	move.l	CAMG_Format(a0),d1
.norm	move.l	d1,IFF_Type
*-----------------------------------------*
*	Find basic attributes			*
*-----------------------------------------*
	move.l	#'BMHD',d0
	bsr		scan_form
	tst.l		d0
	bmi		ANIM_error
*-----------------------------------------*
	move.b	BMHD_Compression(a0),IFF_Comp
	move.w	BMHD_Width(a0),d0
	beq		ANIM_error
	addq		#7,d0
	and.w		#-8,d0
	move.w	d0,IFF_Width
	lsr.w		#3,d0
	move.w	d0,IFF_planebytes
	move.w	d0,d1
	move.w	BMHD_Height(a0),d0
	beq		ANIM_error
	mulu		d0,d1
	move.l	d1,IFF_planesize
	move.w	d0,IFF_Height
	moveq		#0,d0
	move.b	BMHD_Planes(a0),d0
	beq		ANIM_error
	move.w	d0,IFF_Planes
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
	move.w	#fmat_bytepixel,source_format
	move.l	IFF_Type,d2
	btst		#AMIGA_HAM,d2
	beq.s		.nHAM
	move.w	#fmat_wordpixel,source_format
	sf		IFF_HalfBrite
*-----------------------------------------*
	move.w	IFF_Planes,d0
	cmp.w		#12,d0
	bne.s		.nh12
	move.w	#16,IFF_Cols
	bra		.nHAM
*-----------------------------------------*
.nh12	subq		#2,d0
	ble		ANIM_error
	move.w	d0,hamplanes
	subq		#1,d0
	bmi		ANIM_error
	move.w	d0,hambits
*-----------------------------------------*
	move.w	hamplanes,d0
	moveq		#1,d1
	lsl.w		d0,d1
	move.w	d1,IFF_Cols
*-----------------------------------------*
*	Create buffers for delta-decoding	*
*-----------------------------------------*
.nHAM	move.l	IFF_planesize,d0
	move.w	IFF_Planes,d1
	ext.l		d1
	mulu.l	d1,d0
	move.l	d0,T
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		ANIM_error
	move.w	d0,abuff1_handle
	move.l	T,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		ANIM_error
	move.w	d0,abuff2_handle
*-----------------------------------------*
*	Find main ILBM 'BODY'			*
*-----------------------------------------*
	move.l	#'BODY',d0
	bsr		scan_form
	tst.l		d0
	bmi		ANIM_error
*-----------------------------------------*
	addq		#4,a0
	move.l	a0,IFF_PTR
	move.l	#raw_copyline,raw_rout
	move.l	#run_copyline,run_rout
	jsr		decode_body
	jsr		swap_animbuffers
	jsr		decode_body
	jsr		extract_anim_cols
	moveq		#0,d0
	rts

ANIM_error:
	moveq		#-1,d0
	rts

*-----------------------------------------*
CLOSE_ANIM:
*-----------------------------------------*
	move.w	ANM_handle,d0
	bmi.s		.rts
	jsr		CloseFile
.rts	rts

*-----------------------------------------*
swap_animbuffers:
*-----------------------------------------*
	move.w	abuff1_handle,d0
	move.w	abuff2_handle,abuff1_handle
	move.w	d0,abuff2_handle
	rts

*-----------------------------------------*
extract_anim_cols:
*-----------------------------------------*
	move.l	#'CMAP',d0
	bsr		scan_form
	tst.l		d0
	bmi		.nEHB
	addq		#4,a0
	lea		animcols,a1
	move.l	PALETTE_PTR,a2
	move.w	#256-1,d0
.clr	clr.l		(a1)+
	clr.l		(a2)+
	dbra		d0,.clr
	lea		animcols,a1
	move.l	PALETTE_PTR,a2
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
	move.l	-4(a1),(a2)+
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
	move.l	-4(a1),(a2)+
	dbra		d0,.hbcl
.nEHB	st		PALETTE_CHANGED
	rts

*-----------------------------------------*
DECODE_ANIM_FRAME:
*-----------------------------------------*
	tst.b		first_pass
	bne.s		.draw
*-----------------------------------------*
	jsr		read_form
	tst.l		d0
	bmi		ANIM_error
*-----------------------------------------*
*	Find delta header				*
*-----------------------------------------*
	move.l	#'ANHD',d0
	bsr		scan_form
	tst.l		d0
	bmi		ANIM_error
	addq.l	#4,a0
	move.b	ANIM_oper(a0),D_oper
	move.w	ANIM_xorwidth(a0),D_xorwidth
	move.w	ANIM_xorheight(a0),D_xorheight
	move.w	ANIM_xorx(a0),D_xorx
	move.w	ANIM_xory(a0),D_xory
	move.l	ANIM_modebits(a0),D_modebits
*-----------------------------------------*
	moveq		#0,d0
	move.b	D_oper,d0
	cmp.w		#5,d0
	bgt		ANIM_error
	jsr		([anim_routs.w,pc,d0.w*4])
	tst.l		d0
	bmi		.rts
*-----------------------------------------*
.draw	jsr		extract_anim_cols
	bsr		pixelise_iff
	jsr		swap_animbuffers
	moveq		#0,d0
.rts	sf		first_pass
	rts

anim_routs:
	dc.l		copy_body
	dc.l		xor_body
	dc.l		longdelta
	dc.l		shortdelta
	dc.l		gendelta
	dc.l		bytevert

gendelta:
	moveq		#0,d0
	rts

bytevert:
	move.l	#'DLTA',d0
	bsr		scan_form
	tst.l		d0
	bmi		.rts
	addq		#4,a0
	move.l	a0,IFF_PTR
	move.w	IFF_Planes,d0
	subq		#1,d0
	clr.l		plane_offset
*-----------------------------------------*
.plan	move.l	(a0)+,d1
	beq.s		.skip
*-----------------------------------------*
	add.l		IFF_PTR,d1
	move.l	d1,delta_ptr	; get correct source data
	pushall
	move.w	abuff2_handle,d0
	jsr		Find_block
	move.l	a0,a1
	add.l		plane_offset,a1	; get to correct bitplane
	move.l	delta_ptr,a0	; get source data
*-----------------------------------------*
	move.w	IFF_planebytes,d6
	subq		#1,d6
*-----------------------------------------*
.row	move.l	a1,a2
	move.w	IFF_Height,d7
	moveq		#0,d5
	move.b	(a0)+,d5
	beq.s		.next
	subq		#1,d5
*-----------------------------------------*
.op	moveq		#0,d0
	move.b	(a0)+,d0
	beq.s		.same
	btst		#7,d0
	beq.s		.skip
*-----------------------------------------*
.uniq	bclr		#7,d0
	subq		#1,d0
.copy	move.b	(a0)+,(a2)
	add.w		IFF_planebytes,a2
	subq		#1,d7
	bmi		.err
	dbra		d0,.copy
	bra.s		.nxop
*-----------------------------------------*
.skip	subq		#1,d0
.skpl	add.w		IFF_planebytes,a2
	subq		#1,d7
	bmi		.err
	dbra		d0,.skpl
	bra.s		.nxop
*-----------------------------------------*
.same	moveq		#0,d1
	move.b	(a0)+,d1
	subq		#1,d1
	move.b	(a0)+,d2
.rnlp	move.b	d2,(a2)
	add.w		IFF_planebytes,a2
	subq		#1,d7
	bmi		.err
	dbra		d1,.rnlp
*-----------------------------------------*
.nxop	dbra		d5,.op
*-----------------------------------------*
.next	addq.l	#1,a1
	dbra		d6,.row	
*-----------------------------------------*
.stop	popall
	move.l	IFF_planesize,d1
	add.l		d1,plane_offset
	dbra		d0,.plan
*-----------------------------------------*
	moveq		#0,d0
.rts	rts
.err	popall
	moveq		#0,d0
	bra.s		.rts

copy_body:
	move.l	#'BMHD',d0
	bsr		scan_form
	tst.l		d0
	bmi		.rts
	move.b	BMHD_Compression(a0),IFF_Comp
	move.l	#'BODY',d0
	bsr		scan_form
	tst.l		d0
	bmi		.rts
	addq		#4,a0
	move.l	a0,IFF_PTR
	move.l	#raw_copyline,raw_rout
	move.l	#run_copyline,run_rout
	jsr		decode_body	
	moveq		#0,d0
.rts	rts

xor_body:
	move.l	#'BMHD',d0
	bsr		scan_form
	tst.l		d0
	bmi		.rts
	move.b	BMHD_Compression(a0),IFF_Comp
	move.l	#'BODY',d0
	bsr		scan_form
	tst.l		d0
	bmi		.rts
	addq		#4,a0
	move.l	a0,IFF_PTR
	move.l	#raw_xorline,raw_rout
	move.l	#run_xorline,run_rout
	jsr		decode_body	
	moveq		#0,d0
.rts	rts

longdelta:
	move.l	#'DLTA',d0
	bsr		scan_form
	tst.l		d0
	bmi		.rts
	addq		#4,a0
	move.l	a0,IFF_PTR
	move.w	IFF_Planes,d0
	subq		#1,d0
	clr.l		plane_offset
.plan	move.l	(a0)+,d1
	beq.s		.skip
	add.l		IFF_PTR,d1
	move.l	d1,delta_ptr
	pushall
	move.w	abuff2_handle,d0
	jsr		Find_block
	move.l	a0,a1
	add.l		plane_offset,a1
	move.l	delta_ptr,a0
.next	move.w	(a0)+,d0
	bmi.s		.diff
	add.w		d0,a1
	move.l	(a0)+,(a1)	
	bra.s		.next
.diff	cmp.w		#$FFFF,d0
	beq.s		.stop
	addq		#2,d0	
	neg.w		d0
	add.w		d0,a1
	move.w	(a0)+,d0
	subq		#1,d0
.raw	move.l	(a0)+,(a1)+
	dbra		d0,.raw
	bra.s		.next		
.stop	popall
.skip	move.l	IFF_planesize,d1
	add.l		d1,plane_offset
	dbra		d0,.plan
	moveq		#0,d0
.rts	rts

shortdelta:
	move.l	#'DLTA',d0
	bsr		scan_form
	tst.l		d0
	bmi		.rts
	addq		#4,a0
	move.l	a0,IFF_PTR
	move.w	IFF_Planes,d0
	subq		#1,d0
	clr.l		plane_offset
.plan	move.l	(a0)+,d1
	beq.s		.skip
	add.l		IFF_PTR,d1
	move.l	d1,delta_ptr
	pushall
	move.w	abuff2_handle,d0
	jsr		Find_block
	move.l	a0,a1
	add.l		plane_offset,a1
	move.l	delta_ptr,a0
.next	move.w	(a0)+,d0
	bmi.s		.diff
	add.w		d0,a1
	move.w	(a0)+,(a1)	
	bra.s		.next
.diff	cmp.w		#$FFFF,d0
	beq.s		.stop
	addq		#2,d0	
	neg.w		d0
	add.w		d0,a1
	move.w	(a0)+,d0
	subq		#1,d0
.raw	move.w	(a0)+,(a1)+
	dbra		d0,.raw
	bra.s		.next		
.stop	popall
.skip	move.l	IFF_planesize,d1
	add.l		d1,plane_offset
	dbra		d0,.plan
	moveq		#0,d0
.rts	rts

*-----------------------------------------*
decode_body:
*-----------------------------------------*
	move.w	abuff2_handle,d0
	jsr		Find_block
	move.l	a0,a1
	move.l	raw_rout,a4
	tst.b		IFF_Comp
	beq.s		.raw
	move.l	run_rout,a4
.raw	move.l	IFF_PTR,a0
	move.w	IFF_Height,d0
	bra.s		.sylp
.ylp	moveq		#0,d4
	move.w	IFF_Planes,d3
	bra.s		.splp
.plp	lea		(a1,d4.l),a2
	jsr		(a4)
	add.l		IFF_planesize,d4
.splp	dbra		d3,.plp
	add.w		IFF_planebytes,a1
.sylp	dbra		d0,.ylp
	rts

*-----------------------------------------*
run_copyline:
*-----------------------------------------*
	move.w	IFF_planebytes,d6
.loop	move.b	(a0)+,d7
	ext.w		d7
	bmi.s		.comp
.copy	move.b	(a0)+,(a2)+
	subq		#1,d6
	ble.s		.exit
	dbra		d7,.copy
	bra.s		.loop
.comp	cmp.w		#-128,d7
	beq.s		.exit
	neg.w		d7
	move.b	(a0)+,d5
.unp	move.b	d5,(a2)+
	subq		#1,d6
	ble.s		.exit
	dbra		d7,.unp
	bra.s		.loop
.exit	rts

*-----------------------------------------*
raw_copyline:
*-----------------------------------------*
	move.w	IFF_planebytes,d6
	bra.s		.sxlp
.copy	move.b	(a0)+,(a2)+
.sxlp	dbra		d6,.copy
	rts

*-----------------------------------------*
run_xorline:
*-----------------------------------------*
	move.w	IFF_planebytes,d6
.loop	move.b	(a0)+,d7
	ext.w		d7
	bmi.s		.comp
.copy	move.b	(a0)+,d1
	eor.b		d1,(a2)+
	subq		#1,d6
	ble.s		.exit
	dbra		d7,.copy
	bra.s		.loop
.comp	cmp.w		#-128,d7
	beq.s		.exit
	neg.w		d7
	move.b	(a0)+,d5
	bne.s		.unp
	add.w		d6,a2
	bra.s		.skip
.unp	eor.b		d5,(a2)+
	subq		#1,d6
	ble.s		.exit
.skip	dbra		d7,.unp
	bra.s		.loop
.exit	rts

*-----------------------------------------*
raw_xorline:
*-----------------------------------------*
	move.w	IFF_planebytes,d6
	bra.s		.sxlp
.copy	move.b	(a0)+,d1
	eor.b		d1,(a2)+
.sxlp	dbra		d6,.copy
	rts

*-----------------------------------------*

pixelise_iff:
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,a6
	move.w	abuff2_handle,d0
	jsr		Find_block
	lea		animcols,a2
	move.l	IFF_Type,d0
	btst		#AMIGA_HAM,d0
	beq.s		.nham
	cmp.w		#12,IFF_Planes
	beq		ham12_2_wordpixels
	bra		ham68_2_wordpixels
.nham	bra		iff_2_bytepixels

ham68_2_wordpixels:
	move.w	IFF_Height,d7
	bra		.slin
.line	push.w	d7
	clr.l		DR
	move.w	IFF_planebytes,d7
	bra		.sbyt
.byte	lea		linebuffer,a1
	moveq		#0,d0
	move.w	IFF_Planes,d1
	subq		#1,d1
.plan	move.b	(a0,d0.l),(a1)+
	add.l		IFF_planesize,d0
	dbra		d1,.plan
	addq		#1,a0
	moveq		#8-1,d6	
.word	lea		-2(a1),a3
	move.w	hambits,d5
	moveq		#0,d4
.plp	move.b	-(a3),d0
	add.b		d0,(a3)
	addx.b	d4,d4
	dbra		d5,.plp
	move.l	a1,a3
	moveq		#0,d5
	move.b	-(a3),d0
	add.b		d0,(a3)
	addx.b	d5,d5
	move.b	-(a3),d0
	add.b		d0,(a3)
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
	dbra		d6,.word
.sbyt	dbra		d7,.byte
	pop.w		d7
.slin	dbra		d7,.line
	rts
	
ham12_2_wordpixels:
	move.w	IFF_Height,d7
	bra		.slin
.line	push.w	d7
	move.w	IFF_planebytes,d7
	bra		.sbyt
.byte	lea		linebuffer,a1
	moveq		#0,d0
	move.w	IFF_Planes,d1
	subq		#1,d1
.plan	move.b	(a0,d0.l),(a1)+
	add.l		IFF_planesize,d0
	dbra		d1,.plan
	addq		#1,a0
	moveq		#8-1,d6	
.word	move.l	a1,a3
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#4-1,d5
.plp3	move.b	-(a3),d0
	add.b		d0,(a3)
	addx.b	d3,d3
	dbra		d5,.plp3
	moveq		#4-1,d5
.plp2	move.b	-(a3),d0
	add.b		d0,(a3)
	addx.b	d2,d2
	dbra		d5,.plp2
	moveq		#4-1,d5
.plp1	move.b	-(a3),d0
	add.b		d0,(a3)
	addx.b	d1,d1
	dbra		d5,.plp1
	lsl.w		#4,d1
	lsl.w		#4,d2
	lsl.w		#4,d3
	bfins		d1,d4{16:8}
	bfins		d2,d4{21:8}
	bfins		d3,d4{27:8}
	move.w	d4,(a6)+
	dbra		d6,.word
.sbyt	dbra		d7,.byte
	pop.w		d7
.slin	dbra		d7,.line
	rts

iff_2_bytepixels
	move.w	IFF_Height,d7
	bra		.slin
.line	push.w	d7
	move.w	IFF_planebytes,d7
	bra		.sbyt
.byte	lea		linebuffer,a1
	moveq		#0,d0
	move.w	IFF_Planes,d1
	subq		#1,d1
.plan	move.b	(a0,d0.l),(a1)+
	add.l		IFF_planesize,d0
	dbra		d1,.plan
	moveq		#8-1,d6	
.pix	move.l	a1,a3
	move.w	IFF_Planes,d5
	subq		#1,d5
	moveq		#0,d1
.plp1	move.b	-(a3),d0
	add.b		d0,(a3)
	addx.b	d1,d1
	dbra		d5,.plp1
	move.b	d1,(a6)+
	dbra		d6,.pix
	addq		#1,a0
.sbyt	dbra		d7,.byte
	pop.w		d7
.slin	dbra		d7,.line
	rts

*-----------------------------------------*
			bss
*-----------------------------------------*

animcols:		ds.l	256
			
linebuffer:		ds.b	24
abuff1_handle:	ds.w	1
abuff2_handle:	ds.w	1

ANM_handle:		ds.w	1
formbytes:		ds.l	1
plane_offset:	ds.l	1
delta_ptr:		ds.l	1
run_rout:		ds.l	1
raw_rout:		ds.l	1

D_xorwidth:		ds.w	1
D_xorheight:	ds.w	1
D_xorx:		ds.w	1
D_xory:		ds.w	1
D_modebits:		ds.l	1
D_oper:		ds.b	1
anim_done:		ds.b	1
first_pass:		ds.b	1
			even
			
*-----------------------------------------*
			text
*-----------------------------------------*
