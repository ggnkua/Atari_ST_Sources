*-----------------------------------------------------------------------*
*	68030 M.I.P. Mapping/colour reduction engine				*
*-----------------------------------------------------------------------*
*	½ October 1993  Douglas Little of Black Scorpion			*
*-----------------------------------------------------------------------*

red_bits		=	5
green_bits		=	6
blue_bits		=	5

hist_entries	=	(1<<red_bits)*(1<<green_bits)*(1<<blue_bits)
histo_limit		=	$7FFF

			rsreset
fmat_bitplane	rs.b	1	; values for [source_format.w]
fmat_bytepixel	rs.b	1
fmat_wordpixel	rs.b	1
fmat_24bit_rgb	rs.b	1
fmat_24bit_bgr	rs.b	1

			rsreset
logic_replace	rs.b	1	; values for [logic_operation.b]
logic_overlay	rs.b	1
logic_underlay	rs.b	1

			rsreset
use_old		rs.b	1	; values for [palette_mode.b]
use_new		rs.b	1
make_new		rs.b	1

dspwaitr		macro
.wr\@	btst		#0,\1
	beq.s		.wr\@
	endm

dspwaitw		macro
.ww\@	btst		#1,\1
	beq.s		.ww\@
	endm

*-----------------------------------------------------------------------*
*	Convert image data from one format to another				*
*-----------------------------------------------------------------------*
CONVERT_IMAGE:
	push.b	killspin
	st		killspin
	jsr		.main
	pop.b		killspin
	rts

*-----------------------------------------------------------------------*
*	determine scaled/direct
*-----------------------------------------------------------------------*
.main	sf		scale_flag		
	move.w	source_width,d0
	sub.w		dest_width,d0
	move.w	source_height,d1
	sub.w		dest_height,d1
	or.w		d0,d1
	sne		scale_flag		
*-----------------------------------------------------------------------*
*	determine fast/slow convert							*
*-----------------------------------------------------------------------*
	cmp.b		#make_new,palette_mode
	beq		slow_conv			; if rebuild cols, use slow
	moveq		#0,d0
	move.b	scale_flag,d0
	and.b		mip_map,d0
	move.w	REDUCE_BITS,d1
	and.w		#1<<Bit_REDUCE_DITHER,d1
	or.w		d1,d0
	bne		slow_conv			; if (mip&size)|dither then slow

*-----------------------------------------------------------------------*
*	Squash/convert image with no mip-mapping/no colour reduction	*
*-----------------------------------------------------------------------*
fast_conv:
	tst.b		TRUE_FLAG
	beq		fast_remap_bpl
fast_remap_true:
	cmp.w		#fmat_bytepixel,source_format
	beq		scale_bpp_wpp
	cmp.w		#fmat_wordpixel,source_format
	beq		scale_wpp_wpp
	bra		slow_conv
fast_remap_bpl:
	cmp.w		#fmat_bytepixel,source_format
	beq		scale_bpp_bpl
	bra		slow_conv

*-----------------------------------------------------------------------*
*	Squash/convert image using mip-mapping + colour reduction		*
*-----------------------------------------------------------------------*
slow_conv:
	tst.b		scale_flag
	beq		REDUCE_ONLY

*-----------------------------------------------------------------------*
*	Smooth-scale image and reduce colours to 256 or less			*
*-----------------------------------------------------------------------*

MIPMAP_AND_REDUCE:
	push.b	killspin
	st		killspin
	jsr		.main
	pop.b		killspin
	rts
.main	move.w	#-1,MIPMAP_HANDLE
	tst.b		sacrifice
	beq.s		.make
	move.w	source_width(pc),d0
	move.w	source_format,d3
	jsr		([length_routs.w,pc,d3.w*4])
	move.l	d0,d1
	move.w	dest_width(pc),d0
	move.w	#fmat_wordpixel,d3
	jsr		([length_routs.w,pc,d3.w*4])
	move.l	d0,d2
	cmp.l		d1,d2
	bgt.s		.make
	move.l	source_image,a0
	bra.s		.go2
.make	move.w	dest_width,d0
	move.w	dest_height,d1
	addq		#2,d1
	mulu		d1,d0
	add.l		d0,d0
	jsr		Add_fast
	tst.l		d0
	bpl.s		.cont
	rts
.cont	move.w	d0,MIPMAP_HANDLE
	jsr		Find_block
	move.l	a0,MIPMAP_PTR
	move.w	dest_width,d0
	move.w	dest_height,d1
	addq		#2,d1
	mulu		d1,d0
	add.l		d0,d0
	jsr		memclr
	move.l	MIPMAP_PTR,a0
.go2	move.l	a0,MIPMAP_PTR
	move.l	MIPMAP_PTR,a0
	push.l	dest_image
	move.l	a0,dest_image
	jsr		MIPMAP_IMAGE
	pop.l		dest_image

	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_FREQ,d0
	beq.s		.go
	move.l	#hist_entries,hist_size
	move.l	hist_size,d0
	lsl.l		#2,d0
	jsr		Add_fast
	tst.l		d0
	bpl.s		.cnt2
	move.w	MIPMAP_HANDLE,d0
	bmi.s		.n1
	jsr		Remove_block
.n1	moveq		#-1,d0
	rts
.cnt2	move.w	d0,HISTOGRAM_HANDLE
	jsr		Find_block
	move.l	a0,HISTOGRAM_PTR

.go	push.w	source_format(pc)
	push.w	source_width(pc)
	push.w	source_height(pc)
	push.w	dest_width(pc)
	push.w	dest_height(pc)
	push.l	source_image(pc)
	move.w	dest_width,source_width	
	move.w	dest_height,source_height
	move.w	CANVAS_WIDTH,dest_width
	move.w	CANVAS_HEIGHT,dest_height
	move.l	MIPMAP_PTR,source_image
	move.w	#fmat_wordpixel,source_format
	move.w	#fmat_wordpixel,dest_format
	tst.b		TRUE_FLAG
	bne.s		.true
	move.w	#fmat_bitplane,dest_format
.true	jsr		REDUCE_COLOURMAP
	pop.l		source_image
	pop.w		dest_height
	pop.w		dest_width
	pop.w		source_height
	pop.w		source_width
	pop.w		source_format

	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_FREQ,d0
	beq.s		.no
	move.w	HISTOGRAM_HANDLE,d0
	jsr		Remove_block

.no	move.w	MIPMAP_HANDLE,d0
	bmi.s		.n2
	jsr		Remove_block
.n2	moveq		#0,d0
	rts

create_histogram:
	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_FREQ,d0
	beq.s		.done
	move.l	#hist_entries,hist_size
	move.l	hist_size,d0
	lsl.l		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		.rts
	move.w	d0,HISTOGRAM_HANDLE
	jsr		Find_block
	move.l	a0,HISTOGRAM_PTR
.done	moveq		#0,d0
.rts	rts

remove_histogram:
	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_FREQ,d0
	beq.s		.done
	move.w	HISTOGRAM_HANDLE,d0
	jsr		Remove_block
.done	rts


*-----------------------------------------------------------------------*
*	Reduce image to 256 colours or less						*
*-----------------------------------------------------------------------*

REDUCE_ONLY:
	push.b	killspin
	st		killspin
	jsr		.main
	pop.b		killspin
	rts
.main
	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_FREQ,d0
	beq.s		.go
	move.l	#hist_entries,hist_size
	move.l	hist_size,d0
	lsl.l		#2,d0
	jsr		Add_fast
	tst.l		d0
	bpl.s		.cont
	rts
.cont	move.w	d0,HISTOGRAM_HANDLE
	jsr		Find_block
	move.l	a0,HISTOGRAM_PTR

.go	push.w	dest_width(pc)
	push.w	dest_height(pc)
	move.w	CANVAS_WIDTH,dest_width
	move.w	CANVAS_HEIGHT,dest_height
	move.w	#fmat_wordpixel,dest_format
	tst.b		TRUE_FLAG
	bne.s		.true
	move.w	#fmat_bitplane,dest_format
.true	jsr		REDUCE_COLOURMAP
	pop.w		dest_height
	pop.w		dest_width

	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_FREQ,d0
	beq.s		.no
	move.w	HISTOGRAM_HANDLE,d0
	jsr		Remove_block

.no	moveq		#0,d0
	rts

*-----------------------------------------------------------------------*
*	Colourspace reduction of bitplane/bytepixel/truecolour image	*
*-----------------------------------------------------------------------*

MIPMAP_IMAGE:
	push.b	killspin
	st		killspin
	jsr		.main
	pop.b		killspin
	rts
.main	lea		mipmap_text,a0
	jsr		percentage_box
	move.w	source_width(pc),d0
	mulu		#3*16,d0
	jsr		Add_fast
	tst.l		d0
	bpl.s		.cont
	rts
.cont	addq.b	#1,BUSY
	move.w	d0,CIRCBUFF_HANDLE
	jsr		Find_block
	move.l	a0,CIRCULAR_BUFFER
	move.l	source_image(pc),a0
	move.l	dest_image(pc),a3
	bsr		get_increments
	move.w	source_format(pc),d0
	move.l	(read_routs.w,pc,d0.w*4),a5
	move.w	source_width(pc),d0
	move.w	source_format(pc),d1
	jsr		([length_routs.w,pc,d1.w*4])
	move.l	d0,next_source
	move.w	dest_width(pc),d0
	move.w	#fmat_wordpixel,d1
	jsr		([length_routs.w,pc,d1.w*4])
	move.l	d0,next_dest
	move.w	source_width(pc),d0
	move.w	#fmat_24bit_rgb,d1
	jsr		([length_routs.w,pc,d1.w*4])
	move.l	d0,a4
	moveq		#0,d0
	move.w	d0,last_y
	move.l	source_palette(pc),a2
	move.w	dest_height(pc),d7
	move.w	d7,maximum_do
	clr.w		current_do

;	pushall
;	jsr		get_bgcolour
;	move.b	d1,d5
;	lsl.l		#8,d5
;	move.b	d2,d5
;	lsl.l		#8,d5
;	move.b	d3,d5
;	lsl.l		#8,d5
;	move.l	d5,bgrefcol
;	move.l	COLMASK,d7
;	lsl.l		#8,d7
;	move.l	d7,bgmask
;	popall

	dbra		d7,.sylp
.exit	move.w	CIRCBUFF_HANDLE,d0
	jsr		Remove_block
	subq.b	#1,BUSY
	moveq		#0,d0
	rts
.sylp	move.l	a3,-(sp)
	move.w	d7,-(sp)
	swap		d0
	add.l		yinc_int(pc),d0
	swap		d0
	move.l	d0,-(sp)
	move.w	d0,d1
	sub.w		last_y(pc),d1
	move.w	d1,line_count
	move.w	d0,last_y
	move.l	CIRCULAR_BUFFER(pc),a1
	bra.s		.srlp
.read	move.w	d1,-(sp)
	move.l	a0,-(sp)
	jsr		(a5)	
	move.l	(sp)+,a0
	add.l		next_source(pc),a0
	move.w	(sp)+,d1
.srlp	dbra		d1,.read
	moveq		#0,d0
	move.w	d0,last_x
	move.w	dest_width(pc),d6
	subq		#1,d6
.xlop	move.w	d6,-(sp)
	move.w	d0,d1
	add.w		d1,d1
	add.w		d0,d1
	move.l	CIRCULAR_BUFFER(pc),a1
	add.w		d1,a1
	swap		d0
	add.l		xinc_int(pc),d0
	swap		d0	
	move.l	d0,-(sp)
	move.w	d0,d6
	sub.w		last_x(pc),d6
	move.w	d6,pixel_count
	move.w	d0,last_x
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d4
	moveq		#0,d0
;	move.l	bgrefcol(pc),d5
	move.w	line_count(pc),d7
	subq		#1,d7
.yadd	;push.w	d7
;	move.l	bgmask(pc),d7
	move.w	pixel_count(pc),d6
	subq		#1,d6
	move.l	a1,a6
.xadd	;push.w	d6

;	move.l	(a6),d0
;	addq.l	#3,a6
;	clr.b		d0
;	move.l	d0,d6
;	and.l		d7,d6
;	cmp.l		d5,d6
;	beq.s		.err		

;	rol.l		#8,d0
;	add.w		d0,d1
;	clr.w		d0
;	rol.l		#8,d0
;	add.w		d0,d2
;	clr.w		d0
;	rol.l		#8,d0
;	add.w		d0,d3
	
	move.b	(a6)+,d0
	add.w		d0,d1
	move.b	(a6)+,d0
	add.w		d0,d2
	move.b	(a6)+,d0
	add.w		d0,d3
	addq		#1,d4

.err	;pop.w		d6
	dbra		d6,.xadd
	add.l		a4,a1
	;pop.w		d7
	dbra		d7,.yadd

	divu		d4,d1	
	divu		d4,d2	
	divu		d4,d3
	bfins		d1,d0{16:08}
	bfins		d2,d0{21:08}
	bfins		d3,d0{27:08}
	move.w	d0,(a3)+	
	move.l	(sp)+,d0
	move.w	(sp)+,d6
	dbra		d6,.xlop
	addq		#1,current_do
	moveq		#4,d0
	bsr		print_scalebar
	move.l	(sp)+,d0
	move.w	(sp)+,d7
	move.l	(sp)+,a3
	add.l		next_dest(pc),a3
	dbra		d7,.sylp
	bra		.exit

;bgmask:	ds.l	1
;bgrefcol:	ds.l	1

*-----------------------------------------------------------------------*
*	Colour + resolution reduction routines					*
*-----------------------------------------------------------------------*

REDUCE_COLOURMAP:
	push.b	killspin
	st		killspin
	jsr		.main
	pop.b		killspin
	rts
.main	moveq		#0,d0
	move.b	logic_operation,d0
	and.b		#3,d0
	move.l	(logic_table.l,d0.w*4),write_ptr
*-----------------------------------------------------------------------*
	addq.b	#1,BUSY
*-----------------------------------------------------------------------*
*	Check for palette requirement							*
*-----------------------------------------------------------------------*
	cmp.w		#fmat_bytepixel,dest_format
	bgt		.map
*-----------------------------------------------------------------------*
*	Is there an incoming palette?							*
*-----------------------------------------------------------------------*
	cmp.w		#fmat_bytepixel,source_format
	ble.s		.c256
*-----------------------------------------------------------------------*
*	Source image is true-colour: avoid 'make' if mode='use_old'		*
*-----------------------------------------------------------------------*
.true	cmp.b		#use_old,palette_mode
	beq.s		.old
	cmp.b		#make_new,palette_mode
	beq.s		.make
	tst.b		colours_available
	beq.s		.make
	move.l	source_palette(pc),write_palette
	bra.s		.map
.old	move.l	alt_palette(pc),write_palette
	bra.s		.map	
*-----------------------------------------------------------------------*
*	Use incoming palette?								*
*-----------------------------------------------------------------------*
.c256	cmp.b		#use_new,palette_mode
	bne.s		.duic
	move.l	source_palette(pc),write_palette
	bra.s		.map	
*-----------------------------------------------------------------------*
*	Use old palette?									*
*-----------------------------------------------------------------------*
.duic	cmp.b		#use_old,palette_mode
	bne.s		.make
	move.l	alt_palette(pc),write_palette
	bra.s		.map	
*-----------------------------------------------------------------------*
*	Rebuild palette from image							*
*-----------------------------------------------------------------------*
.make	move.l	source_palette(pc),read_palette
	bsr		extract_colours
	move.l	#PALETTE_COPY,write_palette
	bsr		remap_image
	lea		PALETTE_COPY,a0
	move.l	dest_palette(pc),a1
	jsr		COPYCOLS
	st		PALETTE_CHANGED
	bra.s		.rts
*-----------------------------------------------------------------------*
*	Remap image										*
*-----------------------------------------------------------------------*
.map	move.l	source_palette(pc),read_palette
	bsr		remap_image
.rts	subq.b	#1,BUSY
	rts

extract_colours:
	lea		extract_text,a0
	jsr		percentage_box
*-----------------------------------------*
	lea		INITIAL_COLOURS,a0
	lea		PALETTE_COPY,a1
	jsr		COPYCOLS
*-----------------------------------------*
	move.l	COLMASK,d0
	move.w	REDUCE_BITS,d1
	and.w		#1<<Bit_REDUCE_DITHER,d1
	beq.s		.ok1
	and.l		#$00F0F0F0,d0
.ok1	move.l	d0,colmask
	bfins		d0,d1{16:24}
	bfins		d0,d1{21:16}
	bfins		d0,d1{27:08}
	move.w	d1,colmask2
*-----------------------------------------*
	jsr		quick_count
	tst.l		d0
	beq.s		.done
*-----------------------------------------*
	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_FREQ,d0
	beq.s		.spac
*-----------------------------------------*
	move.l	HISTOGRAM_PTR,a0
	move.l	hist_size,d0
	lsl.l		#2,d0
	jsr		memclr
*-----------------------------------------*
	move.l	HISTOGRAM_PTR,a1
	move.l	source_image(pc),a0
	move.l	read_palette(pc),a2
	move.w	source_format(pc),d0
	jsr		([prescan_routs.w,pc,d0.w*4])
*-----------------------------------------*
	bsr		compress_histogram
	bsr		sort_histogram
	bsr		build_palette
*-----------------------------------------*
	bra.s		.done
.spac	jsr		spacial_extract
.done	rts

*-----------------------------------------*
quick_count:
*-----------------------------------------*
	lea		buffer48k,a0
	move.l	#((64*3)+256)*4,d0
	jsr		memclr
*-----------------------------------------*
	lea		buffer48k,a1
	move.l	source_image(pc),a0
	move.l	read_palette(pc),a2
	move.w	source_format(pc),d0
	clr.w		quick_track
	jsr		([quickscan_routs.w,pc,d0.w*4])
	tst.l		d0
	bmi		.err
*-----------------------------------------*
* Compress unused slots out of hash		*
*-----------------------------------------*
	lea		buffer48k,a0
	moveq		#0,d2
	moveq		#0,d6
	moveq		#0,d7
.loop	move.l	(a0,d7.l*4),d1
	bne.s		.next
	moveq		#0,d4
	cmp.l		d6,d7
	ble.s		.lop2
	move.l	d7,d6
	addq.l	#1,d6
.lop2	move.l	(a0,d6.l*4),d1
	beq.s		.nxt2
	move.l	d1,(a0,d7.l*4)
	move.l	d2,(a0,d6.l*4)
	bra.s		.next
.nxt2	addq.l	#1,d6
	cmp.l		#(64*3)+256,d6
	bne.s		.lop2
	bra.s		.done
.next	addq.l	#1,d7
	move.l	#(64*3)+256,d0
	subq.l	#1,d0
	cmp.l		d0,d7
	bne.s		.loop
.done	move.w	d7,colour_count
*-----------------------------------------*
.make	lea		buffer48k,a0
	lea		PALETTE_COPY,a1
	bra.s		.elp
.copy	move.l	(a0)+,d0
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	move.w	d1,(a1)+
	move.b	d2,(a1)+
	move.b	d3,(a1)+
.elp	dbra		d7,.copy
	moveq		#0,d0
.err	rts

read_routs:
	dc.l		read_bitplane
	dc.l		read_bytepixel
	dc.l		read_wordpixel
	dc.l		read_24bit_rgb
	dc.l		read_24bit_bgr

write_routs:
	dc.l		write_bitplane
	dc.l		write_bytepixel
	dc.l		write_wordpixel
	dc.l		write_24bit_rgb
	dc.l		write_24bit_bgr

overlay_routs:
	dc.l		overlay_bitplane
	dc.l		overlay_bytepixel
	dc.l		overlay_wordpixel
	dc.l		overlay_24bit_rgb
	dc.l		overlay_24bit_bgr

underlay_routs:
	dc.l		underlay_bitplane
	dc.l		underlay_bytepixel
	dc.l		underlay_wordpixel
	dc.l		underlay_24bit_rgb
	dc.l		underlay_24bit_bgr

*-----------------------------------------*

logic_table:
	dc.l		write_routs
	dc.l		overlay_routs
	dc.l		underlay_routs
	dc.l		write_routs

*-----------------------------------------*

length_routs:
	dc.l		length_bitplane
	dc.l		length_bytepixel
	dc.l		length_wordpixel
	dc.l		length_24bit_rgb
	dc.l		length_24bit_bgr

scan_routs:
	dc.l		scan_bitplane
	dc.l		scan_bytepixel
	dc.l		scan_wordpixel
	dc.l		scan_24bit_rgb
	dc.l		scan_24bit_bgr
	
*-----------------------------------------*
*	Quick scanners				*
*-----------------------------------------*

quickscan_routs:
	dc.l		quickscan_bitplane
	dc.l		quickscan_bytepixel
	dc.l		quickscan_wordpixel
	dc.l		quickscan_24bit_rgb
	dc.l		quickscan_24bit_bgr

hash_quick:
	push.l	d0
	bfins		d1,d5{16:8}
	bfins		d2,d5{21:8}
	bfins		d3,d5{27:8}
	and.w		colmask2,d5
	lsr.w		#2,d1
	lsr.w		#2,d2
	lsr.w		#2,d3
	move.w	d1,d4
	add.w		d2,d4
	add.w		d3,d4
	lea		(a1,d4.w*4),a6
	move.w	#256-1,d0
.all	move.l	(a6)+,d4
	bpl.s		.free
	cmp.w		d5,d4
	beq.s		.next
	dbra		d0,.all
.free	move.w	d5,-(a6)
	move.w	#-1,-(a6)
	addq		#1,quick_track
.next	pop.l		d0
	rts

quickscan_24bit_rgb:
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	jsr		hash_quick
	move.w	quick_track,d0
	cmp.w		colours_needed,d0
	bgt.s		.more
	dbra		d6,.xlp
	dbra		d7,.ylp	
	moveq		#0,d0
	rts
.more	moveq		#-1,d0
	rts

quickscan_24bit_bgr:
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,d3
	move.b	(a0)+,d2
	move.b	(a0)+,d1
	jsr		hash_quick
	move.w	quick_track,d0
	cmp.w		colours_needed,d0
	bgt.s		.more
	dbra		d6,.xlp
	dbra		d7,.ylp	
	moveq		#0,d0
	rts
.more	moveq		#-1,d0
	rts

quickscan_wordpixel:
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d4
	move.w	(a0)+,d4
	and.w		colmask2,d4
	bfextu	d4{16:8},d1
	bfextu	d4{21:8},d2
	bfextu	d4{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3

;	cmp.w		#32,d1
;	bgt.s		.cont
;	cmp.w		#32,d2
;	bgt.s		.cont
;	cmp.w		#32,d3
;	bgt.s		.cont
;	moveq		#0,d4
;.cont

	jsr		hash_quick
	move.w	quick_track,d0
	cmp.w		colours_needed,d0
	bgt.s		.more
	dbra		d6,.xlp
	dbra		d7,.ylp	
	moveq		#0,d0
	rts
.more	moveq		#-1,d0
	rts

quickscan_bytepixel:
	move.l	read_palette(pc),a2
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d4
	move.b	(a0)+,d4
	move.l	(a2,d4.w*4),d5
	move.b	d5,d3
	lsr.w		#8,d5
	move.w	d5,d2
	swap		d5
	move.b	d5,d1
	jsr		hash_quick
	move.w	quick_track,d0
	cmp.w		colours_needed,d0
	bgt.s		.more
	dbra		d6,.xlp
	dbra		d7,.ylp	
	moveq		#0,d0
	rts
.more	moveq		#-1,d0
	rts

quickscan_bitplane:
	move.w	source_width(pc),d0
	move.w	source_format(pc),d1
	jsr		([length_routs.w,pc,d1.w*4])
	move.l	d0,a4
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	swap		d7
	sub.w		d7,d7
	move.w	source_width(pc),d6
	subq		#1,d6
	move.l	a0,a3
	move.l	(a3)+,d0
	move.l	(a3)+,d1
	move.l	(a3)+,d2
	move.l	(a3)+,d3
.xlp	moveq		#0,d4
	add.w		d3,d3
	addx.w	d4,d4
	swap		d3
	add.w		d3,d3
	addx.w	d4,d4
	swap		d3
	add.w		d2,d2
	addx.w	d4,d4
	swap		d2
	add.w		d2,d2
	addx.w	d4,d4
	swap		d2
	add.w		d1,d1
	addx.w	d4,d4
	swap		d1
	add.w		d1,d1
	addx.w	d4,d4
	swap		d1
	add.w		d0,d0
	addx.w	d4,d4
	swap		d0
	add.w		d0,d0
	addx.w	d4,d4
	swap		d0
	addq		#1,d7
	and.w		#16-1,d7
	bne.s		.cont
	move.l	(a3)+,d0
	move.l	(a3)+,d1
	move.l	(a3)+,d2
	move.l	(a3)+,d3
.cont	move.l	(a2,d4.w*4),d5
	move.b	d5,d3
	lsr.w		#8,d5
	move.w	d5,d2
	swap		d5
	move.b	d5,d1
	jsr		hash_quick
	move.w	quick_track,d1
	cmp.w		colours_needed,d1
	bgt.s		.more
.next	dbra		d6,.xlp
	add.l		a4,a0
	swap		d7
	dbra		d7,.ylp	
	moveq		#0,d0
	rts
.more	moveq		#-1,d0
	rts

*-----------------------------------------*
*	Histogram pre-scanners			*
*-----------------------------------------*

prescan_routs:
	dc.l		prescan_bitplane
	dc.l		prescan_bytepixel
	dc.l		prescan_wordpixel
	dc.l		prescan_24bit_rgb
	dc.l		prescan_24bit_bgr

prescan_24bit_rgb:
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	moveq		#0,d4
	add.w		d1,d4
	add.w		d2,d4
	add.w		d3,d4
	cmp.w		#(1<<5)*2,d4
	bgt.s		.cont
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
.cont	bfins		d1,d4{16:8}
	bfins		d2,d4{21:8}
	bfins		d3,d4{27:8}
	and.w		colmask2,d4
	cmp.w		#histo_limit,2(a1,d4.l*4)
	beq.s		.next
	addq.w	#1,2(a1,d4.l*4)
	move.w	d4,0(a1,d4.l*4)
.next	dbra		d6,.xlp
	dbra		d7,.ylp	
	rts

prescan_24bit_bgr:
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,d3
	move.b	(a0)+,d2
	move.b	(a0)+,d1
	moveq		#0,d4
	bfins		d1,d4{16:8}
	bfins		d2,d4{21:8}
	bfins		d3,d4{27:8}
	and.w		colmask2,d4
	cmp.w		#histo_limit,2(a1,d4.l*4)
	beq.s		.next
	addq.w	#1,2(a1,d4.l*4)
	move.w	d4,0(a1,d4.l*4)
.next	dbra		d6,.xlp
	dbra		d7,.ylp	
	rts

prescan_wordpixel:
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d4
	move.w	(a0)+,d4
	and.w		colmask2,d4
	bfextu	d4{16:8},d1
	bfextu	d4{21:8},d2
	bfextu	d4{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	cmp.w		#1<<5,d1
	bgt.s		.cont
	cmp.w		#1<<5,d2
	bgt.s		.cont
	cmp.w		#1<<5,d3
	bgt.s		.cont
	moveq		#0,d4
.cont	cmp.w		#histo_limit,2(a1,d4.l*4)
	beq.s		.next
	addq.w	#1,2(a1,d4.l*4)
	move.w	d4,0(a1,d4.l*4)
.next	dbra		d6,.xlp
	dbra		d7,.ylp	
	rts

prescan_bytepixel:
	move.l	read_palette(pc),a2
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d4
	move.b	(a0)+,d4
	move.l	(a2,d4.w*4),d5
	bfins		d5,d4{16:24}
	bfins		d5,d4{21:16}
	bfins		d5,d4{27:08}
	and.w		colmask2,d4
	cmp.w		#histo_limit,2(a1,d4.l*4)
	beq.s		.next
	move.w	d4,0(a1,d4.l*4)
	addq.w	#1,2(a1,d4.l*4)
.next	dbra		d6,.xlp
	dbra		d7,.ylp	
	rts

prescan_bitplane:
	move.w	source_width(pc),d0
	move.w	source_format(pc),d1
	jsr		([length_routs.w,pc,d1.w*4])
	move.l	d0,a4
	move.w	source_height(pc),d7
	subq		#1,d7
.ylp	swap		d7
	sub.w		d7,d7
	move.w	source_width(pc),d6
	subq		#1,d6
	move.l	a0,a3
	move.l	(a3)+,d0
	move.l	(a3)+,d1
	move.l	(a3)+,d2
	move.l	(a3)+,d3
.xlp	moveq		#0,d4
	add.w		d3,d3
	addx.w	d4,d4
	swap		d3
	add.w		d3,d3
	addx.w	d4,d4
	swap		d3
	add.w		d2,d2
	addx.w	d4,d4
	swap		d2
	add.w		d2,d2
	addx.w	d4,d4
	swap		d2
	add.w		d1,d1
	addx.w	d4,d4
	swap		d1
	add.w		d1,d1
	addx.w	d4,d4
	swap		d1
	add.w		d0,d0
	addx.w	d4,d4
	swap		d0
	add.w		d0,d0
	addx.w	d4,d4
	swap		d0
	addq		#1,d7
	and.w		#16-1,d7
	bne.s		.cont
	move.l	(a3)+,d0
	move.l	(a3)+,d1
	move.l	(a3)+,d2
	move.l	(a3)+,d3
.cont	move.l	(a2,d4.w*4),d5
	bfins		d5,d4{16:24}
	bfins		d5,d4{21:16}
	bfins		d5,d4{27:08}
	and.w		colmask2,d4
	cmp.w		#histo_limit,2(a1,d4.l*4)
	beq.s		.next
	addq.w	#1,2(a1,d4.l*4)
	move.w	d4,0(a1,d4.l*4)
.next	dbra		d6,.xlp
	add.l		a4,a0
	swap		d7
	dbra		d7,.ylp	
	rts

*-----------------------------------------*
* Compress unused slots out of histogram	*
*-----------------------------------------*
compress_histogram:
*-----------------------------------------*
	move.l	HISTOGRAM_PTR(pc),a0
	moveq		#0,d2
	moveq		#0,d6
	moveq		#0,d7
.loop	move.l	(a0,d7.l*4),d1
	bne.s		.next
	moveq		#0,d4
	cmp.l		d6,d7
	ble.s		.lop2
	move.l	d7,d6
	addq.l	#1,d6
.lop2	move.l	(a0,d6.l*4),d1
	beq.s		.nxt2
	move.l	d1,(a0,d7.l*4)
	move.l	d2,(a0,d6.l*4)
	bra.s		.next
.nxt2	addq.l	#1,d6
	cmp.l		hist_size,d6
	bne.s		.lop2
	bra.s		.done
.next	addq.l	#1,d7
	move.l	hist_size,d0
	subq.l	#1,d0
	cmp.l		d0,d7
	bne.s		.loop
.done	move.l	d7,colours_used
	rts

*-----------------------------------------*
*   Sort histogram entries by frequency	*
*-----------------------------------------*
sort_histogram:
*-----------------------------------------*
	move.l	HISTOGRAM_PTR(pc),a0
	move.l	colours_used(pc),d5
	subq.l	#1,d5
	beq.s		.done
	moveq		#0,d6
	moveq		#0,d7
.main	move.w	2(a0,d7.l*4),d1
	move.l	d7,d6
.loop	cmp.w		6(a0,d6.l*4),d1
	bge.s		.next
	move.l	4(a0,d6.l*4),d1
	move.l	(a0,d7.l*4),d2
	move.l	d1,(a0,d7.l*4)
	move.l	d2,4(a0,d6.l*4)
.next	addq.l	#1,d6
	cmp.l		d5,d6
	bne.s		.loop
	addq.l	#1,d7
	cmp.l		d5,d7
	bne.s		.main
.done	rts

*-----------------------------------------*
*	Extract palette from histogram	*
*-----------------------------------------*
build_palette:
*-----------------------------------------*
	cmp.l		#1,colours_used
	ble.s		.err
	move.w	colours_needed(pc),boxes_required
.redo	bsr		bound_colours
	bsr		make_palette
	move.w	boxes_required(pc),d0
	ext.l		d0
	cmp.l		colours_used(pc),d0
	beq.s		.done			; finish if boxes are used up
	move.w	colours_needed(pc),d0
	sub.w		colour_count(pc),d0
	beq.s		.done			; finish if unique slots are used up
	addq		#1,boxes_required	; otherwise try again
	move.l	colours_used(pc),d0
	move.w	colour_count(pc),d1
	ext.l		d1
	cmp.l		d1,d0
	bgt.s		.redo			; finish if used =< needed
.done	bsr		sort_palette
.err	rts

*-----------------------------------------*
* Create bounding slabs for quantization	*
*-----------------------------------------*
bound_colours:
*-----------------------------------------*
	move.l	HISTOGRAM_PTR(pc),a1
.clear_flags
	move.l	colours_used(pc),d0
	subq.l	#1,d0
.clr	move.l	d0,d1
	lsl.l		#2,d1
	and.w		#$7FFF,2(a1,d1.l)
	subq.l	#1,d0
	bpl.s		.clr
.first_box
	move.l	colours_used(pc),d0
	subq.l	#1,d0
	move.l	d0,d1
	lsl.l		#2,d1
	or.w		#1<<15,2(a1,d1.l)
	move.w	boxes_required(pc),d0
	subq		#1,d0
	lea		box_count(pc),a5
	move.w	d0,(a5)
	lea		boxes(pc),a5
	move.w	#1,(a5)
.chop	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d6
	moveq		#0,d7
	move.l	d7,a6
	move.l	d2,box_top
	move.l	d3,box_bot
	move.l	colours_used(pc),d4
	subq.l	#1,d4
.scan	move.l	d3,d5
	lsl.l		#2,d5
	move.w	2(a1,d5.l),d6
	move.w	d6,d5
	and.w		#$7FFF,d6
	add.l		d6,d7
	tst.w		d5
	bpl.s		.next
	cmp.l		a6,d7
	ble.s		.skip
	cmp.l		d2,d3
	beq.s		.skip
	move.l	d7,a6
	move.l	d2,box_top
	move.l	d3,box_bot
.skip	moveq		#0,d7
	move.w	d3,d2
	addq.l	#1,d2
.next	addq.l	#1,d3
	subq.l	#1,d4
	bpl.s		.scan
	move.l	box_top(pc),d2			
	move.l	box_bot(pc),d3
	cmp.l		d2,d3
	beq.s		.done
	add.l		d2,d3
	lsr.l		d3
	lsl.l		#2,d3
	or.w		#1<<15,2(a1,d3.l)
	lea		boxes(pc),a5
	addq		#1,(a5)
	lea		box_count(pc),a5
	subq		#1,(a5)
	bne.s		.chop
.done	rts

*-----------------------------------------*
*	Quantize the bounding slabs		*
*-----------------------------------------*
make_palette:
*-----------------------------------------*
.clear_out
	lea		PALETTE_COPY,a0
	move.l	#$FF000000,d1
	move.w	colours_needed(pc),d0
	subq		#1,d0
	ble		.done
.clr	or.l		d1,(a0)+
	dbra		d0,.clr	
	lea		colour_count(pc),a5
	clr.w		(a5)
.make_cols
	move.l	HISTOGRAM_PTR,a1
	lea		PALETTE_COPY,a2
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d5
	move.l	colours_used(pc),d4
.mac	move.l	(a1,d3.l*4),d6
	bfextu	d6{00:8},d7
	and.w		#%11111000,d7
	add.w		d7,d0
	bfextu	d6{05:8},d7
	and.w		#%11111100,d7
	add.w		d7,d1
	bfextu	d6{11:8},d7
	and.w		#%11111000,d7
	add.w		d7,d2
	addq		#1,d5
	tst.w		d6
	bpl.s		.skip
	divu		d5,d0
	divu		d5,d1
	divu		d5,d2
	and.w		#$FF,d0
	swap		d0
	move.b	d1,d0
	ror.w		#8,d0
	move.b	d2,d0
	bsr.s		store_colour
	tst.l		d0
	bmi.s		.done
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d5
	move.w	colour_count(pc),d7
	cmp.w		colours_needed(pc),d7
	beq.s		.done
.skip	addq.l	#1,d3
	subq.l	#1,d4
	bne.s		.mac
.done	rts

*-----------------------------------------*
*	Place new colour into the palette	*
*-----------------------------------------*
store_colour:
*-----------------------------------------*
	lea		PALETTE_COPY,a6
	move.w	colours_needed(pc),d1
	lsl.w		#2,d1
	add.w		d1,a6
	move.l	colmask,d5
	and.l		d5,d0
	move.w	colours_needed(pc),d1
	subq		#1,d1
	moveq		#0,d7
.look	move.l	-(a6),d2
	bpl.s		.cont
	moveq		#-1,d7		; free slot found
	move.l	a6,a5			; store slot address
	bra.s		.skip
.cont	and.l		d5,d2
	cmp.l		d0,d2
	beq.s		.rts
.skip	dbra		d1,.look
	tst.w		d7
	beq.s		.err
	move.l	d0,(a5)
	addq		#1,colour_count
.rts	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts

boxes_required:	ds.w	1
	
*-----------------------------------------*

sort_palette:
	lea		PALETTE_COPY,a0
	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7
	move.w	colour_count,d5
	subq		#1,d5
.main	move.l	(a0,d7.l*4),d1
	move.l	d7,d6
.loop	cmp.l		4(a0,d6.l*4),d1
	bls.s		.next
	move.l	4(a0,d6.l*4),d1
	move.l	(a0,d7.l*4),d2
	move.l	d1,(a0,d7.l*4)
	move.l	d2,4(a0,d6.l*4)
.next	addq.l	#1,d6
	cmp.l		d5,d6
	bne.s		.loop
	addq.l	#1,d7
	cmp.l		d5,d7
	bne.s		.main
.done	rts

remap_image:
	move.w	source_width(pc),d0
	mulu		#3,d0
	jsr		Add_fast
	tst.l		d0
	bpl.s		.cont
	rts
.cont	move.w	d0,SCANLINE_HANDLE
	jsr		Find_block
	move.l	a0,SCANLINE_PTR
	cmp.w		#fmat_bytepixel,dest_format
	blt.s		.ndr
	pushall
	lea		remap_text,a0
	jsr		percentage_box
	popall
	bsr		.do_remap
	bra		.rts
.ndr	move.l	write_palette(pc),a0
	move.w	#256,d0
	cmp.b		#use_old,palette_mode
	beq.s		.make
	move.w	colours_needed,d0
.make	move.w	d0,colsearch_count
	move.l	a0,colsearch_ptr
	pushall
	lea		remap_text,a0
	jsr		percentage_box
	popall
	bsr		Init_DSPColSearch
	bsr		create_indexlist
	tst.l		d0
	bmi		.rts
	jsr		.do_remap
;	tst.l		d0
;	bmi.s		.rts
	bsr		remove_indexlist
	moveq		#0,d0
.rts	push.l	d0
	move.w	SCANLINE_HANDLE,d0
	jsr		Remove_block
	pop.l		d0
	rts


.do_remap:
	tst.b		output_image
	beq.s		.no2
	pushall
	lea		writefile_text,a0
	jsr		percentage_box
	move.l	#buffer48k,diskbufferptr
	popall
.no2	move.w	source_format(pc),d0
	move.l	(read_routs.w,pc,d0.w*4),a5
	move.w	dest_format(pc),d0
	move.l	write_ptr(pc),a0
	move.l	(a0,d0.w*4),a6
	move.l	source_image(pc),a0
	move.l	dest_image(pc),a1
	move.l	read_palette(pc),a2
	move.w	source_width(pc),d0
	move.w	source_format(pc),d1
	jsr		([length_routs.w,pc,d1.w*4])
	move.l	d0,next_source
	move.w	dest_scrwidth(pc),d0
	move.w	dest_format(pc),d1
	jsr		([length_routs.w,pc,d1.w*4])
	move.l	d0,next_dest
	move.l	d0,d7
	mulu		dest_y(pc),d7
	add.l		d7,a1
	move.w	dest_x(pc),d0
	move.w	dest_format(pc),d1
	jsr		([length_routs.w,pc,d1.w*4])
	add.l		d0,a1
	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_DITHER,d0
	beq		.con2
	cmp.l		#write_bitplane,a6
	beq.s		.go_bpl
	cmp.l		#write_bytepixel,a6
	beq.s		.go_bpp
	bra.s		.con2
.go_bpl
	lea		write_bitplane_fs,a6
	bra.s		.go
.go_bpp
	lea		write_bytepixel_fs,a6
.go	pushall
	tst.b		output_image
	bne.s		.no3
	lea		dither_text,a0
	jsr		percentage_box
.no3	move.w	colsearch_count,d0
	move.l	colsearch_ptr,a0
	bsr		Init_DSPDither
	popall
.con2	move.w	source_height(pc),d7
	move.w	d7,maximum_do
	clr.w		current_do
	subq		#1,d7
	tst.b		image_inverted
	beq.s		.ylp
	move.l	next_source,d0
	mulu		d7,d0
	add.l		d0,a0
	neg.l		next_source
.ylp	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	move.l	SCANLINE_PTR(pc),a1
	jsr		(a5)
	move.l	(sp)+,a1
	move.l	SCANLINE_PTR(pc),a0
	jsr		(a6)
	move.l	(sp)+,a0
	move.l	(sp)+,a1
	tst.b		output_image
	beq.s		.no
	jsr		buffered_write
	tst.l		d0
	bmi		.rts
	sub.l		next_dest(pc),a1
.no	add.l		next_source(pc),a0
	add.l		next_dest(pc),a1
	addq		#1,current_do
	moveq		#2,d0
	bsr		print_scalebar
	dbra		d7,.ylp
	bsr		flush_diskbuffer
	rts

buffered_write:
	movem.l	d1-a6,-(sp)
	move.l	next_dest(pc),d3
	move.l	diskbufferptr,a0
	move.l	#buffer48k+32768,d2
	bra.s		.strt
.full	move.l	a0,diskbufferptr
	bsr		flush_diskbuffer
	tst.l		d0
	bmi.s		.err
.next	cmp.l		d2,a0
	beq.s		.full
.nful	move.b	(a1)+,(a0)+
.strt	dbra		d3,.next
	move.l	a0,diskbufferptr
	moveq		#0,d0
.err	movem.l	(sp)+,d1-a6
	rts

flush_diskbuffer:
	tst.b		output_image
	beq.s		.no
	movem.l	d1-a6,-(sp)
	move.l	diskbufferptr,d1
	lea		buffer48k,a0
	sub.l		a0,d1
	bgt.s		.ok
	moveq		#-1,d0
	bra.s		.err
.ok	move.w	FILE_HANDLE,d0
	jsr		WriteFile
	tst.l		d0
	bmi.s		.err
	moveq		#0,d0
.err	movem.l	(sp)+,d1-a6
	lea		buffer48k,a0
.no	rts

create_indexlist:
	move.l	#65536,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,IDXLIST_HANDLE
	jsr		Find_block
	move.l	a0,idx_list
	move.l	#65536,d0
	jsr		memclr
	dspwritel	#0
	dspwritel	#0
	dspwritel	#0
	dspread	d0
	move.b	d0,black
	moveq		#0,d0
.err	rts

remove_indexlist:
	move.w	IDXLIST_HANDLE,d0
	jsr		Remove_block
	rts

length_bitplane:	
	add.w		#15,d0
	and.w		#-16,d0
	ext.l		d0
	rts

length_bytepixel:	
	ext.l		d0
	rts

length_wordpixel:	
	ext.l		d0
	add.l		d0,d0
	rts

length_24bit_bgr:	
length_24bit_rgb:	
	mulu		#3,d0
	rts

*-----------------------------------------------------------------------*
	
read_bitplane:	
	push.l	d7
	moveq		#0,d7
	move.l	a0,a3
	move.l	(a3)+,d0
	move.l	(a3)+,d1
	move.l	(a3)+,d2
	move.l	(a3)+,d3
	move.w	source_width(pc),d6
	bra		.sxlp
.xlp	moveq		#0,d4
	add.w		d3,d3
	addx.w	d4,d4
	swap		d3
	add.w		d3,d3
	addx.w	d4,d4
	swap		d3
	add.w		d2,d2
	addx.w	d4,d4
	swap		d2
	add.w		d2,d2
	addx.w	d4,d4
	swap		d2
	add.w		d1,d1
	addx.w	d4,d4
	swap		d1
	add.w		d1,d1
	addx.w	d4,d4
	swap		d1
	add.w		d0,d0
	addx.w	d4,d4
	swap		d0
	add.w		d0,d0
	addx.w	d4,d4
	swap		d0
	addq		#1,d7
	and.w		#16-1,d7
	bne.s		.cont
	move.l	(a3)+,d0
	move.l	(a3)+,d1
	move.l	(a3)+,d2
	move.l	(a3)+,d3
.cont	move.b	1(a2,d4.w*4),(a1)+
	move.b	2(a2,d4.w*4),(a1)+
	move.b	3(a2,d4.w*4),(a1)+
.sxlp	dbra		d6,.xlp
	pop.l		d7
	rts

read_bytepixel:	
	move.w	source_width(pc),d6
	subq		#1,d6
	moveq		#0,d4
.xlp	move.b	(a0)+,d4
	move.b	1(a2,d4.w*4),(a1)+
	move.b	2(a2,d4.w*4),(a1)+
	move.b	3(a2,d4.w*4),(a1)+
	dbra		d6,.xlp
	rts

read_wordpixel:	
	move.w	source_width(pc),d6
	subq		#1,d6
	moveq		#0,d4
.xlp	move.w	(a0)+,d4
	bfextu	d4{16:8},d1
	bfextu	d4{21:8},d2
	bfextu	d4{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	move.b	d1,(a1)+	
	move.b	d2,(a1)+	
	move.b	d3,(a1)+	
	dbra		d6,.xlp
	rts

read_24bit_rgb:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra		d6,.xlp
	rts

read_24bit_bgr:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,d3
	move.b	(a0)+,d2
	move.b	(a0)+,d1
	move.b	d1,(a1)+
	move.b	d2,(a1)+
	move.b	d3,(a1)+
	dbra		d6,.xlp
	rts

*-----------------------------------------------*	

this_x	ds.w	1

write_bitplane:	
	push.l	d7
	moveq		#0,d7
	move.l	idx_list(pc),a4
	move.w	source_width(pc),d6
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	move.l	a1,a3
	bra		.skip
.blck	move.b	black(pc),d4
	bra.s		.use
.xlp	swap		d6
	swap		d7
	sub.w		d5,d5
	sub.w		d6,d6
	sub.w		d7,d7
	move.b	(a0)+,d5
	move.b	(a0)+,d6
	move.b	(a0)+,d7
	bfins		d5,d4{00:8}
	bfins		d6,d4{05:8}
	bfins		d7,d4{11:8}
	clr.w		d4
	tst.l		d4
	beq.s		.blck
	swap		d4
	lea		(a4,d4.l),a3
	move.b	(a3),d4
	bne.s		.use
	dspwrite	d5
	dspwrite	d6
	dspwrite	d7
	dspread	d4
	move.b	d4,(a3)
.use	swap		d7
	swap		d6
	add.b		d4,d4
	addx.w	d3,d3
	add.b		d4,d4
	swap		d3
	addx.w	d3,d3
	swap		d3
	add.b		d4,d4
	addx.w	d2,d2
	add.b		d4,d4
	swap		d2
	addx.w	d2,d2
	swap		d2
	add.b		d4,d4
	addx.w	d1,d1
	add.b		d4,d4
	swap		d1
	addx.w	d1,d1
	swap		d1
	add.b		d4,d4
	addx.w	d0,d0
	add.b		d4,d4
	swap		d0
	addx.w	d0,d0
	swap		d0
	addq		#1,d7
	and.w		#16-1,d7
	bne.s		.skip
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
.skip	dbra		d6,.xlp
	tst.w		d7
	beq.s		.rts
	neg.w		d7
	add.w		#16,d7
	lsl.l		d7,d0
	lsl.l		d7,d1
	lsl.l		d7,d2
	lsl.l		d7,d3
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
.rts	pop.l		d7
	rts

write_bitplane_fs:	
	clr.w		this_x
	push.l	d7
	moveq		#0,d7
	move.w	source_width(pc),d6
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	move.l	a1,a3
	bra		.skip
.xlp	swap		d6
	swap		d7
	sub.w		d5,d5
	sub.w		d6,d6
	sub.w		d7,d7
	dspwrite	this_x(pc)
	move.b	(a0)+,d5
	dspwrite	d5
	move.b	(a0)+,d6
	dspwrite	d6
	move.b	(a0)+,d7
	dspwrite	d7
	dspread	d4
	swap		d7
	swap		d6
	add.b		d4,d4
	addx.w	d3,d3
	add.b		d4,d4
	swap		d3
	addx.w	d3,d3
	swap		d3
	add.b		d4,d4
	addx.w	d2,d2
	add.b		d4,d4
	swap		d2
	addx.w	d2,d2
	swap		d2
	add.b		d4,d4
	addx.w	d1,d1
	add.b		d4,d4
	swap		d1
	addx.w	d1,d1
	swap		d1
	add.b		d4,d4
	addx.w	d0,d0
	add.b		d4,d4
	swap		d0
	addx.w	d0,d0
	swap		d0
	addq		#1,d7
	addq		#1,this_x
	and.w		#16-1,d7
	bne.s		.skip
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
.skip	dbra		d6,.xlp
	tst.w		d7
	beq.s		.rts
	neg.w		d7
	add.w		#16,d7
	lsl.l		d7,d0
	lsl.l		d7,d1
	lsl.l		d7,d2
	lsl.l		d7,d3
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
.rts	pop.l		d7
	dspwritel	#$1000
	rts
	
write_bytepixel:	
	move.l	idx_list(pc),a4
	move.b	black(pc),d3
	move.w	source_width(pc),d2
	bra.s		.skip
.blck	move.b	d3,(a1)+
	dbra		d2,.xlp
	rts
.xlp	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7
	move.b	(a0)+,d5
	move.b	(a0)+,d6
	move.b	(a0)+,d7
	bfins		d5,d0{00:8}
	bfins		d6,d0{05:8}
	bfins		d7,d0{11:8}
	clr.w		d0
	tst.l		d0
	beq.s		.blck
	swap		d0
	move.b	(a4,d0.l),d4
	bne.s		.use
	dspwrite	d5
	dspwrite	d6
	dspwrite	d7
	dspread	d4
	move.b	d4,(a4,d0.l)
.use	move.b	d4,(a1)+
.skip	dbra		d2,.xlp
	rts

write_bytepixel_fs:	
	clr.w		this_x
	move.w	source_width(pc),d2
	bra.s		.skip
.xlp	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7
	dspwrite	this_x(pc)
	move.b	(a0)+,d5
	dspwrite	d5
	move.b	(a0)+,d6
	dspwrite	d6
	move.b	(a0)+,d7
	dspwrite	d7
	dspread	d4
	move.b	d4,(a1)+
.skip	dbra		d2,.xlp
	dspwritel	#$1000
	rts

write_wordpixel:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d4
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	bfins		d1,d4{16:8}
	bfins		d2,d4{21:8}
	bfins		d3,d4{27:8}
	move.w	d4,(a1)+
	dbra		d6,.xlp
	rts

write_24bit_rgb:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra		d6,.xlp
	rts

write_24bit_bgr:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	move.b	d3,(a1)+
	move.b	d2,(a1)+
	move.b	d1,(a1)+
	dbra		d6,.xlp
	rts

*-----------------------------------------------*	

overlay_bitplane:	
	push.w	d7
	clr.w		d7
	move.w	source_width(pc),d6
	subq		#1,d6
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	move.l	a1,a3
.xlp	moveq		#0,d4
	move.b	(a0)+,d4
	dspwrite	d4
	move.b	(a0)+,d4
	dspwrite	d4
	move.b	(a0)+,d4
	dspwrite	d4
	dspread	d4
	add.b		d4,d4
	addx.w	d3,d3
	add.b		d4,d4
	swap		d3
	addx.w	d3,d3
	swap		d3
	add.b		d4,d4
	addx.w	d2,d2
	add.b		d4,d4
	swap		d2
	addx.w	d2,d2
	swap		d2
	add.b		d4,d4
	addx.w	d1,d1
	add.b		d4,d4
	swap		d1
	addx.w	d1,d1
	swap		d1
	add.b		d4,d4
	addx.w	d0,d0
	add.b		d4,d4
	swap		d0
	addx.w	d0,d0
	swap		d0
	addq		#1,d7
	and.w		#16-1,d7
	bne.s		.skip
	move.l	d0,d4
	or.l		d1,d4
	or.l		d2,d4
	or.l		d3,d4
	move.w	d4,d7
	swap		d4
	or.w		d4,d7
	move.w	d7,d4
	swap		d4
	move.w	d7,d4
	not.l		d4
	move.l	(a3),d7
	and.l		d4,d7
	or.l		d0,d7
	move.l	d7,(a3)+
	move.l	(a3),d7
	and.l		d4,d7
	or.l		d1,d7
	move.l	d7,(a3)+
	move.l	(a3),d7
	and.l		d4,d7
	or.l		d2,d7
	move.l	d7,(a3)+
	move.l	(a3),d7
	and.l		d4,d7
	or.l		d3,d7
	move.l	d7,(a3)+
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d7
.skip	dbra		d6,.xlp
	neg.w		d7
	beq.s		.rts
	add.w		#16,d7
	lsl.w		d7,d0
	lsl.w		d7,d1
	lsl.w		d7,d2
	lsl.w		d7,d3
	swap		d0
	swap		d1
	swap		d2
	swap		d3
	lsl.w		d7,d0
	lsl.w		d7,d1
	lsl.w		d7,d2
	lsl.w		d7,d3
	swap		d0
	swap		d1
	swap		d2
	swap		d3
	move.l	d0,d4
	or.l		d1,d4
	or.l		d2,d4
	or.l		d3,d4
	move.w	d4,d7
	swap		d4
	or.w		d4,d7
	move.w	d7,d4
	swap		d4
	move.w	d7,d4
	not.l		d4
	move.l	(a3),d7
	and.l		d4,d7
	or.l		d0,d7
	move.l	d7,(a3)+
	move.l	(a3),d7
	and.l		d4,d7
	or.l		d1,d7
	move.l	d7,(a3)+
	move.l	(a3),d7
	and.l		d4,d7
	or.l		d2,d7
	move.l	d7,(a3)+
	move.l	(a3),d7
	and.l		d4,d7
	or.l		d3,d7
	move.l	d7,(a3)+
.rts	pop.w		d7
	rts

overlay_bytepixel:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d4
	move.b	(a0)+,d4
	dspwrite	d4
	move.b	(a0)+,d4
	dspwrite	d4
	move.b	(a0)+,d4
	dspwrite	d4
	dspread	d4
	beq.s		.skip
	move.b	d4,(a1)
.skip	addq.l	#1,a1
	dbra		d6,.xlp
	rts

overlay_wordpixel:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d4
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	bfins		d1,d4{16:8}
	bfins		d2,d4{21:8}
	bfins		d3,d4{27:8}
	beq.s		.skip
	move.w	d4,(a1)
.skip	addq.l	#2,a1
	dbra		d6,.xlp
	rts

overlay_24bit_rgb:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	move.b	d1,d0
	or.b		d2,d0
	or.b		d3,d0
	beq.s		.skip
	move.b	d1,(a1)
	move.b	d2,1(a1)
	move.b	d3,2(a1)
.skip	addq.l	#3,a1
	dbra		d6,.xlp
	rts

overlay_24bit_bgr:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	move.b	d1,d0
	or.b		d2,d0
	or.b		d3,d0
	beq.s		.skip
	move.b	d3,(a1)
	move.b	d2,1(a1)
	move.b	d1,2(a1)
.skip	addq.l	#3,a1
	dbra		d6,.xlp
	rts

*-----------------------------------------------*	

underlay_bitplane:	
	push.w	d7
	clr.w		d7
	move.w	source_width(pc),d6
	subq		#1,d6
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	move.l	a1,a3
.xlp	moveq		#0,d4
	move.b	(a0)+,d4
	dspwrite	d4
	move.b	(a0)+,d4
	dspwrite	d4
	move.b	(a0)+,d4
	dspwrite	d4
	dspread	d4
	add.b		d4,d4
	addx.w	d3,d3
	add.b		d4,d4
	swap		d3
	addx.w	d3,d3
	swap		d3
	add.b		d4,d4
	addx.w	d2,d2
	add.b		d4,d4
	swap		d2
	addx.w	d2,d2
	swap		d2
	add.b		d4,d4
	addx.w	d1,d1
	add.b		d4,d4
	swap		d1
	addx.w	d1,d1
	swap		d1
	add.b		d4,d4
	addx.w	d0,d0
	add.b		d4,d4
	swap		d0
	addx.w	d0,d0
	swap		d0
	addq		#1,d7
	and.w		#16-1,d7
	bne.s		.skip
	move.l	(a3)+,d4
	or.l		(a3)+,d4
	or.l		(a3)+,d4
	or.l		(a3)+,d4
	move.w	d4,d7
	swap		d4
	or.w		d4,d7
	move.w	d7,d4
	swap		d4
	move.w	d7,d4
	not.l		d4
	lea		-16(a3),a3
	and.l		d4,d0
	and.l		d4,d1
	and.l		d4,d2
	and.l		d4,d3
	or.l		d0,(a3)+
	or.l		d1,(a3)+
	or.l		d2,(a3)+
	or.l		d3,(a3)+
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d7
.skip	dbra		d6,.xlp
	neg.w		d7
	beq.s		.rts
	add.w		#16,d7
	lsl.w		d7,d0
	lsl.w		d7,d1
	lsl.w		d7,d2
	lsl.w		d7,d3
	swap		d0
	swap		d1
	swap		d2
	swap		d3
	lsl.w		d7,d0
	lsl.w		d7,d1
	lsl.w		d7,d2
	lsl.w		d7,d3
	swap		d0
	swap		d1
	swap		d2
	swap		d3
	move.l	(a3)+,d4
	or.l		(a3)+,d4
	or.l		(a3)+,d4
	or.l		(a3)+,d4
	move.w	d4,d7
	swap		d4
	or.w		d4,d7
	move.w	d7,d4
	swap		d4
	move.w	d7,d4
	not.l		d4
	lea		-16(a3),a3
	and.l		d4,d0
	and.l		d4,d1
	and.l		d4,d2
	and.l		d4,d3
	or.l		d0,(a3)+
	or.l		d1,(a3)+
	or.l		d2,(a3)+
	or.l		d3,(a3)+
.rts	pop.w		d7
	rts

underlay_bytepixel:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d4
	move.b	(a0)+,d4
	dspwrite	d4
	move.b	(a0)+,d4
	dspwrite	d4
	move.b	(a0)+,d4
	dspwrite	d4
	dspread	d4
	tst.b		(a1)+
	bne.s		.skip
	move.b	d4,-1(a1)
.skip	dbra		d6,.xlp
	rts

underlay_wordpixel:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d4
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	bfins		d1,d4{16:8}
	bfins		d2,d4{21:8}
	bfins		d3,d4{27:8}
	tst.w		(a1)+
	bne.s		.skip
	move.w	d4,-2(a1)
.skip	dbra		d6,.xlp
	rts

underlay_24bit_rgb:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a1)+,d0
	or.b		(a1)+,d0
	or.b		(a1)+,d0
	bne.s		.skip
	move.b	(a0),-3(a1)
	move.b	1(a0),-2(a1)
	move.b	2(a0),-1(a1)
.skip	addq.l	#3,a0
	dbra		d6,.xlp
	rts

underlay_24bit_bgr:	
	move.w	source_width(pc),d6
	subq		#1,d6
.xlp	move.b	(a1)+,d0
	or.b		(a1)+,d0
	or.b		(a1)+,d0
	bne.s		.skip
	move.b	2(a0),-3(a1)
	move.b	1(a0),-2(a1)
	move.b	(a0),-1(a1)
.skip	addq.l	#3,a0
	dbra		d6,.xlp
	rts

*-----------------------------------------------*	
	
scale_bpp_bpl:
	tst.b		scale_flag
	beq.s		.ns
	lea		rescale_text,a0
	jsr		percentage_box
.ns	addq.b	#1,BUSY
	bsr		get_increments
	moveq		#0,d0
	move.b	logic_operation,d0
	and.b		#3,d0
	move.l	(bpp_bpl_table.l,d0.w*4),a5
	lea		INDEX_BASE,a2
	cmp.b		#use_old,palette_mode
	bne.s		.ign
	pushall
	move.l	source_palette(pc),a0
	move.l	alt_palette(pc),a1
	jsr		TRANSLATE_COLOURS
	popall
	lea		TRANSLATOR_TABLE,a2
.ign	jsr		Init_DSP_MIX
	move.l	source_image(pc),a0
	move.l	dest_image(pc),a3
	clr.w		cur_line
	clr.l		yinc_copy
	move.l	xinc_int(pc),d5
	move.w	dest_height,d7
	move.w	d7,maximum_do
	clr.w		current_do
	subq		#1,d7
.ylop	push.w	d7
	move.l	yinc_copy(pc),d0
	tst.b		image_inverted
	beq.s		.ok
	neg.w		d0
	add.w		source_height,d0
	subq		#1,d0
.ok	mulu		source_width(pc),d0
	lea		(a0,d0.l),a1
	move.l	a3,a4
	moveq		#0,d0


	move.w	dest_width,d6
	beq.s		.skip

;	push.l	a5
;	lea		$FFFFA207.w,a6
;	lea		$FFFFA202.w,a5

	dspwrite	d6
	dspwrite	#0
	bra.s		.xs
.xlop	moveq		#0,d7
	move.b	(a1,d0.w),d7
	move.b	(a2,d7.w),d7

	dspwrite	d7

;	dspwaitw	(a5)
;	move.b	d7,(a6)

	swap		d0
	add.l		d5,d0
	swap		d0
.xs	dbra		d6,.xlop

;	pop.l		a5

	movem.l	d5/a0/a3/a5,-(sp)
	lea		$FFFFA206.w,a6
	lea		$FFFFA202.w,a0
	jsr		(a5)
	movem.l	(sp)+,d5/a0/a3/a5

.skip



.done	move.l	yinc_copy(pc),d0
	swap		d0
	add.l		yinc_int(pc),d0
	swap		d0
	move.l	d0,yinc_copy
	add.w		dest_scrwidth(pc),a3
	tst.b		scale_flag
	beq.s		.ns2
	addq		#1,current_do
	moveq		#8,d0
	bsr		print_scalebar
.ns2	pop.w		d7
	dbra		d7,.ylop
	subq.b	#1,BUSY
	rts

scale_bpp_wpp:
	tst.b		scale_flag
	beq.s		.ns
	lea		rescale_text,a0
	jsr		percentage_box
.ns	addq.b	#1,BUSY
	bsr		get_increments
	moveq		#0,d0
	move.b	logic_operation,d0
	and.b		#3,d0
	move.l	(bpp_wpp_table.l,d0.w*4),a5
	move.l	source_image(pc),a0
	move.l	dest_image(pc),a3
	clr.w		cur_line
	clr.l		yinc_copy
	move.l	xinc_int(pc),d5
	move.w	dest_height,d7
	move.w	d7,maximum_do
	clr.w		current_do
	move.l	source_palette,a2
	subq		#1,d7
.ylop	push.w	d7
	move.l	yinc_copy(pc),d0
	tst.b		image_inverted
	beq.s		.ok
	neg.w		d0
	add.w		source_height,d0
	subq		#1,d0
.ok	mulu		source_width(pc),d0
	lea		(a0,d0.l),a1
	move.l	a3,a4
	moveq		#0,d0
	moveq		#0,d3
	moveq		#0,d6
	moveq		#0,d7
	move.w	dest_width,d7
	subq		#1,d7
.xlop	move.b	(a1,d0.w),d3
	move.l	(a2,d3.w*4),d1
	bfins		d1,d2{16:24}
	bfins		d1,d2{21:16}
	bfins		d1,d2{27:08}
	swap		d0
	add.l		d5,d0
	swap		d0
	jsr		(a5)
	dbra		d7,.xlop
	move.l	yinc_copy(pc),d0
	swap		d0
	add.l		yinc_int(pc),d0
	swap		d0
	move.l	d0,yinc_copy
	add.w		dest_scrwidth(pc),a3
	add.w		dest_scrwidth(pc),a3
	tst.b		scale_flag
	beq.s		.ns2
	addq		#1,current_do
	moveq		#16,d0
	bsr		print_scalebar
.ns2	pop.w		d7
	dbra		d7,.ylop
	subq.b	#1,BUSY
	rts

scale_wpp_wpp:
	tst.b		scale_flag
	beq.s		.ns
	lea		rescale_text,a0
	jsr		percentage_box
.ns	addq.b	#1,BUSY
	bsr		get_increments
	moveq		#0,d0
	move.b	logic_operation,d0
	and.b		#3,d0
	move.l	(bpp_wpp_table.l,d0.w*4),a5
	move.l	source_image(pc),a0
	move.l	dest_image(pc),a3
	move.w	dest_y,d7
	mulu		dest_scrwidth,d7
	move.w	dest_x,d6
	ext.l		d6
	add.l		d6,d7
	add.l		d7,d7
	add.l		d7,a3
	clr.w		cur_line
	clr.l		yinc_copy
	move.l	xinc_int(pc),d5
	move.w	dest_height,d7
	move.w	d7,maximum_do
	clr.w		current_do
	subq		#1,d7
.ylop	push.w	d7
	move.l	yinc_copy(pc),d0
	tst.b		image_inverted
	beq.s		.ok
	neg.w		d0
	add.w		source_height,d0
	subq		#1,d0
.ok	mulu		source_width(pc),d0
	lea		(a0,d0.l*2),a1
	move.l	a3,a4
	moveq		#0,d0
	moveq		#0,d6
	moveq		#0,d7
	move.w	dest_width,d7
	subq		#1,d7
.xlop	move.w	(a1,d0.w*2),d2
	swap		d0
	add.l		d5,d0
	swap		d0
	jsr		(a5)
	dbra		d7,.xlop
	move.l	yinc_copy(pc),d0
	swap		d0
	add.l		yinc_int(pc),d0
	swap		d0
	move.l	d0,yinc_copy
	add.w		dest_scrwidth(pc),a3
	add.w		dest_scrwidth(pc),a3
	tst.b		scale_flag
	beq.s		.ns2
	addq		#1,current_do
	moveq		#16,d0
	bsr		print_scalebar
.ns2	pop.w		d7
	dbra		d7,.ylop
	subq.b	#1,BUSY
	rts

*-----------------------------------------------*	

bpp_bpl_table:
	dc.l		write_bpl
	dc.l		overlay_bpl
	dc.l		underlay_bpl
	dc.l		write_bpl

bpp_wpp_table:
	dc.l		write_wpp
	dc.l		overlay_wpp
	dc.l		underlay_wpp
	dc.l		write_wpp
	
write_bpl:
	dspwaitr	(a0)	
	move.w	(a6),d7
	bra.s		.xs
.xlp	dspwaitr	(a0)	
	move.w	(a6),(a4)+
	dspwaitr	(a0)	
	move.w	(a6),(a4)+
	dspwaitr	(a0)	
	move.w	(a6),(a4)+
	dspwaitr	(a0)	
	move.w	(a6),(a4)+
	dspwaitr	(a0)	
	move.w	(a6),(a4)+
	dspwaitr	(a0)	
	move.w	(a6),(a4)+
	dspwaitr	(a0)	
	move.w	(a6),(a4)+
	dspwaitr	(a0)	
	move.w	(a6),(a4)+
.xs	dbra		d7,.xlp
	rts

overlay_bpl:
	dspwaitr	(a0)	
	move.w	(a6),d7
	bra.s		.xs
.xlp	dspwaitr	(a0)	
	move.w	(a6),d1
	swap		d1
	dspwaitr	(a0)	
	move.w	(a6),d1
	dspwaitr	(a0)	
	move.w	(a6),d2
	swap		d2
	dspwaitr	(a0)	
	move.w	(a6),d2
	dspwaitr	(a0)	
	move.w	(a6),d3
	swap		d3
	dspwaitr	(a0)	
	move.w	(a6),d3
	dspwaitr	(a0)	
	move.w	(a6),d4
	swap		d4
	dspwaitr	(a0)	
	move.w	(a6),d4
	move.l	d1,d6
	or.l		d2,d6
	or.l		d3,d6
	or.l		d4,d6
	move.w	d6,d5
	swap		d6
	or.w		d6,d5
	move.w	d5,d6
	swap		d6
	move.w	d5,d6
	not.l		d6
	and.l		d6,(a4)
	or.l		d1,(a4)+
	and.l		d6,(a4)
	or.l		d2,(a4)+
	and.l		d6,(a4)
	or.l		d3,(a4)+
	and.l		d6,(a4)
	or.l		d4,(a4)+
.xs	dbra		d7,.xlp
	rts

underlay_bpl:
	dspwaitr	(a0)	
	move.w	(a6),d7
	bra.s		.xs
.xlp	dspwaitr	(a0)	
	move.w	(a6),d1
	swap		d1
	dspwaitr	(a0)	
	move.w	(a6),d1
	dspwaitr	(a0)	
	move.w	(a6),d2
	swap		d2
	dspwaitr	(a0)	
	move.w	(a6),d2
	dspwaitr	(a0)	
	move.w	(a6),d3
	swap		d3
	dspwaitr	(a0)	
	move.w	(a6),d3
	dspwaitr	(a0)	
	move.w	(a6),d4
	swap		d4
	dspwaitr	(a0)	
	move.w	(a6),d4
	move.l	(a4)+,d6
	or.l		(a4)+,d6
	or.l		(a4)+,d6
	or.l		(a4)+,d6
	lea		-16(a4),a4
	move.w	d6,d5
	swap		d6
	or.w		d6,d5
	move.w	d5,d6
	swap		d6
	move.w	d5,d6
	not.l		d6
	and.l		d6,d1
	and.l		d6,d2
	and.l		d6,d3
	and.l		d6,d4
	or.l		d1,(a4)+
	or.l		d2,(a4)+
	or.l		d3,(a4)+
	or.l		d4,(a4)+
.xs	dbra		d7,.xlp
	rts

*-----------------------------------------------*	

write_wpp:
	move.w	d2,(a4)+
	rts

overlay_wpp:
	tst.w		d2
	beq.s		.next
	move.w	d2,(a4)
.next	addq.l	#2,a4
	rts

underlay_wpp:
	tst.w		(a4)+
	bne.s		.used
	move.w	d2,-2(a4)
.used	rts

*-----------------------------------------------*	

spacial_extract:
	jsr		init_extract
	cmp.w		#4,colours_needed
	blt		.done	
	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_GREY,d0
	bne		.done
	clr.w		colour_count
	move.w	source_format(pc),d0
	move.l	(scan_routs.w,pc,d0.w*4),a6
	move.w	source_width(pc),d0
	move.w	source_format(pc),d1
	jsr		([length_routs.w,pc,d1.w*4])
	move.l	d0,next_source
	lea		PALETTE_COPY,a0
	moveq		#-1,d0
	clr.w		current_do
	move.w	colours_needed,d7
	move.w	d7,maximum_do
	subq		#1,d7
.clr	move.b	d0,(a0,d7.w*4)
	dbra		d7,.clr
	move.w	source_width(pc),d3
	move.w	source_height(pc),d4
	moveq		#0,d1
	moveq		#0,d2
.scan	movem.l	d1-d4,-(sp)
	jsr		(a6)
	moveq		#0,d5
	move.w	colours_needed(pc),d7
	lea		(PALETTE_COPY.l,d7.w*4),a0
	subq		#1,d7
.loop	move.l	-(a0),d6
	bpl.s		.used
	move.l	a0,a5
	moveq		#1,d5
	bra.s		.next
.used	cmp.l		d0,d6
	beq.s		.same
.next	dbra		d7,.loop
	tst.w		d5
	bne.s		.got
.full	movem.l	(sp)+,d1-d4
	bra		.done
.got	move.l	d0,(a5)
	addq		#1,colour_count
	addq		#1,current_do
	moveq		#2,d0
	bsr		print_scalebar
.same	movem.l	(sp)+,d1-d4
	add.w		d3,d1
	cmp.w		source_width(pc),d1
	blt.s		.scan
	moveq		#0,d1
	add.w		d4,d2
	cmp.w		source_height(pc),d2
	blt.s		.scan
	moveq		#0,d2
	lsr.w		d3
	beq.s		.done
	lsr.w		d4
	bne		.scan
.done	jsr		sort_palette
	rts

init_extract:
	lea		PALETTE_COPY,a0
	move.w	#256-3-1,d0
.lp	clr.l		(a0)+
	dbra		d0,.lp
	move.l	#$FCFCFC,(a0)+
	move.l	#$A8A8A8,(a0)+
	move.l	#$585858,(a0)+
	move.w	colours_needed,d1
	move.w	REDUCE_BITS,d0
	and.w		#1<<Bit_REDUCE_GREY,d0
	bne		.go
	cmp.w		#4,d1
	bge.s		.ok
.go	move.w	#$FF,d0
	swap		d0
	clr.w		d0
	subq		#1,d1
	ext.l		d1
	divs.l	d1,d0
	lea		PALETTE_COPY,a0
	moveq		#0,d2
	move.l	COLMASK,d3
.loop	swap		d2
	addq.l	#1,a0
	move.b	d2,(a0)+
	move.b	d2,(a0)+
	move.b	d2,(a0)+
	and.l		d3,-4(a0)
	swap		d2
	add.l		d0,d2
	dbra		d1,.loop
	move.w	colours_needed,colour_count
.ok	rts
		
colmask:	ds.l	1

scan_bitplane:
	push.l	a5
	push.l	a6
	move.w	#16,wrdwid
	move.l	next_source(pc),scrwid
	move.l	source_image(pc),a0
	jsr		READ_PIXEL
	and.w		#$FF,d0
	move.l	read_palette(pc),a0
	move.l	(a0,d0.w*4),d0
	and.l		colmask(pc),d0
	pop.l		a6
	pop.l		a5
	rts

scan_bytepixel:
	mulu		source_width(pc),d2
	ext.l		d1
	add.l		d1,d2
	move.l	source_image(pc),a0
	move.b	(a0,d2.l),d0
	and.w		#$FF,d0
	move.l	read_palette(pc),a0
	move.l	(a0,d0.w*4),d0
	and.l		colmask(pc),d0
	rts

scan_wordpixel:
	mulu		source_width(pc),d2
	ext.l		d1
	add.l		d1,d2
	move.l	source_image(pc),a0
	move.w	(a0,d2.l*2),d0
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	moveq		#0,d0
	move.b	d1,d0
	swap		d0
	move.b	d2,d0
	ror.w		#8,d0
	move.b	d3,d0
	and.l		#%111110001111110011111000,d0
	and.l		colmask(pc),d0
	rts

scan_24bit_rgb:
	mulu		source_width(pc),d2
	ext.l		d1
	add.l		d1,d2
	move.l	d2,d0
	add.l		d2,d2
	add.l		d0,d2
	move.l	source_image(pc),a0
	move.l	-1(a0,d2.l),d0
	and.l		colmask(pc),d0
	rts

scan_24bit_bgr:
	mulu		source_width(pc),d2
	ext.l		d1
	add.l		d1,d2
	move.l	d2,d0
	add.l		d2,d2
	add.l		d0,d2
	move.l	source_image(pc),a0
	move.b	2(a0,d2.l),d0
	swap		d0
	move.b	1(a0,d2.l),d0
	ror.w		#8,d0
	move.b	0(a0,d2.l),d0
	and.l		colmask(pc),d0
	rts

*-----------------------------------------------*	

get_increments:
	moveq		#0,d2
	move.w	source_width(pc),d2
	move.w	dest_width(pc),d3
	swap		d2
	ext.l		d3
	divs.l	d3,d2
	move.l	d2,xinc_int
	moveq		#0,d2
	move.w	source_height(pc),d2
	move.w	dest_height(pc),d3
	swap		d2
	ext.l		d3
	divs.l	d3,d2
	move.l	d2,yinc_int
	rts
	
print_scalebar:
	subq		#1,d0
	and.w		current_do,d0
	bne.s		.rts
	movem.l	d1-a6,-(sp)
	move.w	current_do,d0
	move.w	#DOBAR_Xmin+6,d1
	move.w	#DOBAR_Ymin+3,d2
	move.w	#DOBAR_Xmin+6,d3
	move.w	#DOBAR_Ymax-3,d4
	mulu		#(DOBAR_Xmax-DOBAR_Xmin)-1-12,d0
	divu		maximum_do,d0
	add.w		d0,d3
	cmp.w		d1,d3
	bgt.s		.go
	move.w	d1,d3
	addq		#1,d3
.go	jsr		Raised_bar_gold
	movem.l	(sp)+,d1-a6
.rts	rts

*-----------------------------------------------------------------------*

Init_DSPColSearch:
	push.w	d0
	push.l	a0
	moveq		#1,d1
	move.l	#DSPCSEARCH_L,d0
	lea		DSPCSEARCH,a0
	jsr		DspExecProg
	pop.l		a0
	pop.w		d1
	ext.l		d1
	dspwritel	d1
	subq		#1,d1
	moveq		#0,d0
.cols	addq.l	#1,a0
	move.b	(a0)+,d0
	dspwritel	d0
	move.b	(a0)+,d0
	dspwritel	d0
	move.b	(a0)+,d0
	dspwritel	d0
	dbra		d1,.cols
	rts

Init_DSPDither:
	push.w	d0
	push.l	a0
	moveq		#1,d1
	move.l	#DSPDITHER_L,d0
	lea		DSPDITHER,a0
	jsr		DspExecProg
	pop.l		a0
	pop.w		d1
	ext.l		d1
	dspwritel	d1
	subq		#1,d1
	moveq		#0,d0
.cols	addq.l	#1,a0
	move.b	(a0)+,d0
	dspwritel	d0
	move.b	(a0)+,d0
	dspwritel	d0
	move.b	(a0)+,d0
	dspwritel	d0
	dbra		d1,.cols
	move.w	source_width,d0
	ext.l		d0
	dspwritel	d0
	rts

*--------------------------------------------------------------------------*
* Convert 8 bit plane screen to byte per pixel format.
*--------------------------------------------------------------------------*
* a0 = Pic pointer, d0 = pic width, d1 = pic height.
*--------------------------------------------------------------------------*
BPS2BytePerPixel:
		movem.l	a0-a6/d0-d7,-(sp)
		subq.w	#1,d1
		lsr.w		#4,d0		; /16
		subq.w	#1,d0
		move.w	d1,d7
		move.w	d0,a6
.lp1:		move.w	a6,d6
.lp2:		move.l	a0,a1
		move.l	(a1)+,d5	; planes 1 & 2
		move.l	(a1)+,d4	; planes 3 & 4
		move.l	(a1)+,d3	; planes 5 & 6
		move.l	(a1)+,d2	; planes 7 & 8
		move.l	d2,d0
		or.l		d3,d0
		or.l		d4,d0
		or.l		d5,d0
		bne.s		.nz
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		bra.s		.olp
.nz		moveq		#16-1,d0
.lp3:		add.w		d2,d2		; plane 8
		addx.b	d1,d1
		swap		d2
		add.w		d2,d2		; plane 7
		addx.b	d1,d1
		swap		d2
		add.w		d3,d3		; plane 6
		addx.b	d1,d1
		swap		d3
		add.w		d3,d3		; plane 5
		addx.b	d1,d1
		swap		d3
		add.w		d4,d4		; plane 4
		addx.b	d1,d1
		swap		d4
		add.w		d4,d4		; plane 3
		addx.b	d1,d1
		swap		d4
		add.w		d5,d5		; plane 2
		addx.b	d1,d1
		swap		d5
		add.w		d5,d5		; plane 1
		addx.b	d1,d1
		swap		d5
		move.b	d1,(a0)+	; output byte per pixel - pixel.
		dbra		d0,.lp3
.olp		dbra		d6,.lp2
		dbra		d7,.lp1
		movem.l	(sp)+,a0-a6/d0-d7
		rts

BytePerPixel2BPS:
		movem.l	a0-a6/d0-d7,-(sp)
		jsr		Init_DSP_MIX
		lea		$FFFFA202.w,a5
		lea		$FFFFA206.w,a6
		subq.w	#1,d1
		move.w	d1,d7
.ylp		move.w	d0,d5
		move.l	a0,a1
		dspwrite	d5
		dspwrite	#0
		bra.s		.xs
.pxlp		btst		#1,(a5)
		beq.s		.pxlp
		move.b	(a1)+,1(a6)
.xs		dbra		d5,.pxlp
		dspread	d5
		bra.s		.wgo
.wxlp		move.w	(a6),(a0)+
		move.w	(a6),(a0)+
		move.w	(a6),(a0)+
		move.w	(a6),(a0)+
		move.w	(a6),(a0)+
		move.w	(a6),(a0)+
		move.w	(a6),(a0)+
		move.w	(a6),(a0)+
.wgo		dbra		d5,.wxlp		

		dbra		d7,.ylp
		movem.l	(sp)+,a0-a6/d0-d7
		rts
		
Init_DSP_MIX:
	pushall
	moveq		#1,d1
	move.l	#DSPMIX_L,d0
	lea		DSPMIX,a0
	jsr		DspExecProg
	popall
	rts

*-----------------------------------------------*	

colours_needed:	dc.w	256

cur_line:		ds.w	1
last_line:		ds.w	1
last_pixel:		ds.w	1
dot_count:		ds.w	1

line_count:		ds.w	1
pixel_count:	ds.w	1

FLCTempYF:		ds.w	1
FLCTempYI:		ds.w	1
FLCTempYFI:		ds.w	1
FLCTempYII:		ds.w	1

xinc_int:		ds.w	1
xinc_frc:		ds.w	1
yinc_int:		ds.w	1
yinc_frc:		ds.w	1
last_x:		ds.w	1
last_y:		ds.w	1

IDXLIST_HANDLE:	ds.w	1
CIRCBUFF_HANDLE:	ds.w	1
SCANLINE_HANDLE:	ds.w	1
SCANLINE_PTR:	ds.l	1

CIRCULAR_BUFFER:	ds.l	1
LINELIST_BUFFER:	ds.l	1

colours_used:	ds.l	1

colour_count:	ds.w	1

HISTOGRAM_PTR:	ds.l	1
HISTOGRAM_HANDLE:	ds.w	1
box_count:		ds.w	1
boxes:		ds.w	1
box_top:		ds.l	1
box_bot:		ds.l	1

MIPMAP_PTR:		ds.l	1
MIPMAP_HANDLE:	ds.w	1

dest_format:	ds.w	1
dest_x:		ds.w	1
dest_y:		ds.w	1

maximum_do:		ds.w	1
current_do:		ds.w	1

diskbufferptr:	ds.l	1

read_palette:	ds.l	1
write_palette:	ds.l	1
next_source:	ds.l	1
next_dest:		ds.l	1

write_ptr:		ds.l	1

idx_list:		ds.l	1
yinc_copy:		ds.l	1

colsearch_count:	ds.w	1
colsearch_ptr:	ds.l	1

source_image:	ds.l	1	; image to process
source_palette:	ds.l	1	; incoming palette
source_width	ds.w	1	; width of source image
source_height:	ds.w	1	; height of source image
colmask2:		ds.w	1
quick_track:	ds.w	1

dest_image:		ds.l	1	; image output buffer
dest_palette:	ds.l	1	; final palette
dest_scrwidth:	ds.w	1	; pixel width of buffer
dest_width		ds.w	1	; width of new image
dest_height:	ds.w	1	; height of new image
hist_size:		ds.l	1
alt_palette:	ds.l	1	; alternative mapping palette

source_format:	ds.w	1	; type of source image
colours_available	ds.b	1	; palette available for truecolour image
logic_operation:	ds.b	1	; what to do with the image
image_inverted:	ds.b	1	; is image upside-down?
output_image:	ds.b	1	; write data to disk as file
palette_mode:	ds.b	1	; use old cols/use new cols/make new cols
sacrifice:		ds.b	1	; re-use source buffer
mip_map:		ds.b	1	; squash + smooth if set

scale_flag:		ds.b	1
black:		ds.b	1
			even

PALETTE_COPY:	ds.l	256	
