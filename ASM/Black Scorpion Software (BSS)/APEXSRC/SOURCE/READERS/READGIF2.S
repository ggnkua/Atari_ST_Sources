
*-------------------------------------------------------*

chunk_size	=	8192

*-------------------------------------------------------*
*	Open GIF file for reading			*
*-------------------------------------------------------*
gif_openfile:
*-------------------------------------------------------*
	clr.l		gif_position_ptr
	clr.l		gif_loopback_ptr
	clr.l		gif_chunksize
	clr.l		gif_chunktide
	lea		gif_filename,a0
	moveq		#0,d0
	jsr		OpenFile
	move.w		d0,gif_handle
	rts
	
*-------------------------------------------------------*
*	Close GIF file					*
*-------------------------------------------------------*
gif_closefile
*-------------------------------------------------------*
	clr.l		gif_position_ptr
	clr.l		gif_loopback_ptr
	clr.l		gif_chunksize
	clr.l		gif_chunktide
	move.w		gif_handle,d0
	bmi.s		.done
	jsr		CloseFile
.done:	rts

*-------------------------------------------------------*
gif_index:
*-------------------------------------------------------*
	move.l		gif_position_ptr,d2
	move.l		d1,gif_position_ptr
	sub.l		d2,d1
	sub.l		d1,gif_filesize
	sub.l		d1,gif_chunksize
	add.l		d1,gif_chunktide
	bpl.s		.seek_done
*-------------------------------------------------------*
*	Seek exceeds chunk buffer - seek properly	*
*-------------------------------------------------------*
	clr.l		gif_chunksize
	clr.l		gif_chunktide
	move.l		gif_position_ptr,d2
	moveq		#0,d1
	move.w		gif_handle,d0
	bsr		SeekFile
*-------------------------------------------------------*
.seek_done:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
gif_readfile:
*-------------------------------------------------------*
*	Find maximum available chunk size		*
*-------------------------------------------------------*
	move.l		gif_chunksize,d6
	bmi.s		.chunk_error
	bne.s		.chunk_available
*-------------------------------------------------------*
*	Chunk buffer is empty, so fill it up		*
*-------------------------------------------------------*
	movem.l		d0/d1/a0,-(sp)
	move.l		#chunk_size,d1
	lea		gif_tidebuffer,a0
	move.w		gif_handle,d0
	bsr		ReadFile
	move.l		d1,d6
	movem.l		(sp)+,d0/d1/a0
	clr.l		gif_chunktide
	move.l		d6,gif_chunksize
	ble.s		.chunk_error
*-------------------------------------------------------*
.chunk_available:
*-------------------------------------------------------*
*	Clip chunk to required size			*
*-------------------------------------------------------*
	move.l		d1,d7
	cmp.l		d6,d7
	ble.s		.clip_chunk
	move.l		d6,d7
*-------------------------------------------------------*
.clip_chunk:
*-------------------------------------------------------*
*	Attempt to copy chunk to destination		*
*-------------------------------------------------------*
	lea		gif_tidebuffer,a1
	add.l		gif_chunktide,a1
	move.l		d7,d5
	lsr.l		d5
	bcc.s		.n0
	move.b		(a1)+,(a0)+
.n0:	lsr.l		d5
	bcc.s		.g2
	move.w		(a1)+,(a0)+
	bra.s		.g2
.c2:	move.l		(a1)+,(a0)+
.g2:	dbra		d5,.c2
*-------------------------------------------------------*
*	Repeat until job is complete			*
*-------------------------------------------------------*
	sub.l		d7,gif_filesize
	add.l		d7,gif_position_ptr
	add.l		d7,gif_chunktide
	sub.l		d7,gif_chunksize
	sub.l		d7,d1
	bne.s		gif_readfile
	moveq		#0,d0
.done:	rts
*-------------------------------------------------------*
.chunk_error:
*-------------------------------------------------------*
	moveq		#-1,d0
	bra.s		.done

*-------------------------------------------------------*
*	Macros						*
*-------------------------------------------------------*

gmovw	macro
	move.w		\1,d0
	ror.w		#8,d0
	move.w		d0,\2
	endm

*-------------------------------------------------------*
*	Screen descriptor				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
sd_width		rs.w	1
sd_height		rs.w	1
sd_flags		rs.b	1
sd_bgcol		rs.b	1
sd_aspect		rs.b	1

*-------------------------------------------------------*
*	Image descriptor				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
id_xoff			rs.w	1
id_yoff			rs.w	1
id_width		rs.w	1
id_height		rs.w	1
id_flags		rs.b	1

*-------------------------------------------------------*
*	Graphic control extension			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
gce_flags		rs.b	1
gce_delay		rs.b	2
gce_tcidx		rs.b	1

*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
gifcmd_inquire		rs.b	1
gifcmd_decode		rs.b	1

sd_gcmap_bit		=	7
id_lcmap_bit		=	7
id_lace_bit		=	6

*-------------------------------------------------------*
read_gif:
*-------------------------------------------------------*
*	Store inquire/decode command			*
*-------------------------------------------------------*
	move.b		d0,gif_command
*-------------------------------------------------------*
*	GIF header (6 bytes)				*
*-------------------------------------------------------*
	move.l		#6,d1
	bsr		read_gifdata
*-------------------------------------------------------*
	move.l		gif_filebuffer,a0
	cmp.l		#'GIF8',(a0)+
	bne		gif_error
	move.w		(a0)+,d0
	cmp.w		#'7a',d0
	beq.s		.type_gif87
	cmp.w		#'9a',d0
	beq.s		.type_gif89
	bra		gif_error
*-------------------------------------------------------*
.type_gif87:
*-------------------------------------------------------*
	move.b		#87,gif_type
	bra.s		.got_type
*-------------------------------------------------------*
.type_gif89:
*-------------------------------------------------------*
	move.b		#89,gif_type
*-------------------------------------------------------*
.got_type:
*-------------------------------------------------------*
*	Screen descriptor (7 bytes)			*
*-------------------------------------------------------*
	move.l		#7,d1
	bsr		read_gifdata
*-------------------------------------------------------*
	move.l		gif_filebuffer,a0
	gmovw		sd_width(a0),gif_sd_width
	gmovw		sd_height(a0),gif_sd_height
	move.b		sd_flags(a0),gif_sd_flags
	move.b		sd_bgcol(a0),gif_sd_bgcol
	move.b		sd_aspect(a0),gif_sd_aspect
*-------------------------------------------------------*
*	Optional global colour map			*
*-------------------------------------------------------*
	move.b		gif_sd_flags,d0
	btst		#sd_gcmap_bit,d0
	beq.s		.no_gcmap
*-------------------------------------------------------*
*	Global colour map (n*3 bytes)			*
*-------------------------------------------------------*
	moveq		#0,d1
	and.b		#%111,d0
	addq.w		#1,d0
	bset		d0,d1
	move.w		d1,gif_colours
	mulu.w		#3,d1
	bsr		read_gifdata
*-------------------------------------------------------*
	move.l		gif_filebuffer,a0
	lea		gif_palette,a1
	move.w		gif_colours,d0
	bra.s		.clps
.clp:	clr.b		(a1)+
	move.b		(a0)+,(a1)+
	move.w		(a0)+,(a1)+
.clps:	dbra		d0,.clp
*-------------------------------------------------------*
.no_gcmap:
*-------------------------------------------------------*
*	Data blocks					*
*-------------------------------------------------------*
gif_block_loop
*-------------------------------------------------------*
	moveq		#1,d1
	bsr		read_gifdata
*-------------------------------------------------------*
	move.l		gif_filebuffer,a0
	move.b		(a0),d0
*-------------------------------------------------------*
*	Extension block case				*
*-------------------------------------------------------*
	cmp.b		#'!',d0
	beq		gif_extension_block
*-------------------------------------------------------*
*	Check decode command				*
*-------------------------------------------------------*
	cmp.b		#gifcmd_decode,gif_command
	bne.s		gif_error
*-------------------------------------------------------*
*	Image descriptor case				*
*-------------------------------------------------------*
	cmp.b		#',',d0
	beq		gif_image_descriptor
*-------------------------------------------------------*
*	Artificial ring-frame for looping animation	*
*-------------------------------------------------------*
	tst.b		animated_gif
	beq.s		gif_error
	move.l		gif_loopback_ptr,d1
	bsr		gif_index
*-------------------------------------------------------*
*	Repeat forever					*
*-------------------------------------------------------*
	bra		gif_block_loop
*-------------------------------------------------------*
*	Unrecognised case - probable terminator		*
*-------------------------------------------------------*
gif_error:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
*	GIF extension block				*
*-------------------------------------------------------*
gif_extension_block:
*-------------------------------------------------------*
*	Read block type					*
*-------------------------------------------------------*
	moveq		#1,d1
	bsr		read_gifdata
	move.l		gif_filebuffer,a0
	move.b		(a0),gif_eblock_type
*-------------------------------------------------------*
*	Read extension sub-blocks			*
*-------------------------------------------------------*
.gif_block_loop:
*-------------------------------------------------------*
*	Read block size					*
*-------------------------------------------------------*
	moveq		#1,d1
	move.l		a0,-(sp)
	bsr		gif_readfile
	move.l		(sp)+,a0
	moveq		#0,d1
	move.b		(a0),d1
	beq.s		.block_terminator
*-------------------------------------------------------*
*	Read block data					*
*-------------------------------------------------------*
	lea		(a0,d1.l),a1
	move.l		a1,-(sp)
	bsr		gif_readfile
	move.l		(sp)+,a0
	bra.s		.gif_block_loop
*-------------------------------------------------------*
.block_terminator:
*-------------------------------------------------------*
	move.l		gif_filebuffer,a0
	move.b		gif_eblock_type,d0
*-------------------------------------------------------*
*	Graphic control extension case			*
*-------------------------------------------------------*
	cmp.b		#$f9,d0
	beq		extension_gc
*-------------------------------------------------------*
*	Unrecognised extension block			*
*-------------------------------------------------------*
	bra		gif_block_loop

*-------------------------------------------------------*
*	Graphic control extension handler		*
*-------------------------------------------------------*
extension_gc:
*-------------------------------------------------------*
	move.b		gce_flags(a0),gif_gce_flags
	gmovw		gce_delay(a0),gif_gce_delay
	move.b		gce_tcidx(a0),gif_gce_tcidx
	moveq		#0,d0
	move.w		gif_gce_delay,d0
	add.l		d0,d0
	move.l		d0,last_delay
	bra		gif_block_loop

*-------------------------------------------------------*
*	GIF image descriptor + image data stream	*
*-------------------------------------------------------*
gif_image_descriptor:
*-------------------------------------------------------*
*	Keep pointer to first frame			*
*-------------------------------------------------------*
	tst.l		gif_loopback_ptr
	beq.s		.first_frame
	st		animated_gif
	bra.s		.second_frame
*-------------------------------------------------------*
.first_frame:
*-------------------------------------------------------*
	move.l		gif_position_ptr,d0
	subq.l		#1,d0
	move.l		d0,gif_loopback_ptr
	sf		animated_gif
*-------------------------------------------------------*
.second_frame:
*-------------------------------------------------------*
*	Read header					*
*-------------------------------------------------------*
	moveq		#9,d1
	bsr		read_gifdata
*-------------------------------------------------------*
*	Image descriptor (9 bytes)			*
*-------------------------------------------------------*
	move.l		gif_filebuffer,a0
	gmovw		id_xoff(a0),gif_id_xoff
	gmovw		id_yoff(a0),gif_id_yoff
	gmovw		id_width(a0),gif_id_width
	gmovw		id_height(a0),gif_id_height	
	move.b		id_flags(a0),gif_id_flags
*-------------------------------------------------------*
*	Local colour table				*
*-------------------------------------------------------*
	move.b		gif_id_flags,d0
	btst		#id_lcmap_bit,d0
	beq.s		.no_lcmap
*-------------------------------------------------------*
*	Global colour map (n*3 bytes)			*
*-------------------------------------------------------*
	moveq		#0,d1
	and.b		#%111,d0
	addq.w		#1,d0
	bset		d0,d1
	move.w		d1,gif_colours
	mulu.w		#3,d1
	bsr		read_gifdata
*-------------------------------------------------------*
	move.l		gif_filebuffer,a0
	lea		gif_palette,a1
	move.w		gif_colours,d0
	bra.s		.clps
.clp:	clr.b		(a1)+
	move.b		(a0)+,(a1)+
	move.w		(a0)+,(a1)+
.clps:	dbra		d0,.clp
*-------------------------------------------------------*
.no_lcmap:
*-------------------------------------------------------*
*	Allocate temporary lzw code-buffer		*
*-------------------------------------------------------*
	move.l		gif_filesize,d0
	jsr		Add_fast
	move.l		d0,gif_codebuffer_h
	bmi.s		.decode_error
	jsr		Find_block
	move.l		a0,gif_codebuffer
*-------------------------------------------------------*
*	Read minimum code size				*
*-------------------------------------------------------*
	moveq		#1,d1
	lea		(a0,d1.l),a1
	move.l		a1,-(sp)
	bsr		gif_readfile
	move.l		(sp)+,a0
*-------------------------------------------------------*
*	Read GIF image data sub-blocks			*
*-------------------------------------------------------*
.gif_block_loop:
*-------------------------------------------------------*
*	Read block size					*
*-------------------------------------------------------*
	moveq		#1,d1
	move.l		a0,-(sp)
	bsr		gif_readfile
	move.l		(sp)+,a0
	moveq		#0,d1
	move.b		(a0),d1
	beq.s		.block_terminator
*-------------------------------------------------------*
*	Read block data					*
*-------------------------------------------------------*
	lea		(a0,d1.l),a1
	move.l		a1,-(sp)
	bsr		gif_readfile
	move.l		(sp)+,a0
	bra.s		.gif_block_loop
*-------------------------------------------------------*
.block_terminator:
*-------------------------------------------------------*
*	Build line pointers for de-interlacing		*
*-------------------------------------------------------*
	move.l		gif_linebuffer,a6
	move.l		gif_imagebuffer,a1
	bsr		build_linepointers
*-------------------------------------------------------*
*	Decode image data				*
*-------------------------------------------------------*
	move.l		gif_codebuffer,a0
	move.l		gif_imagebuffer,a1
	move.l		gif_linebuffer,a2
	bsr		decode_image
*-------------------------------------------------------*
*	Release temporary buffer			*
*-------------------------------------------------------*
	move.l		gif_codebuffer_h,d0
	jsr		Remove_block

;*-------------------------------------------------------*
;*	Display GIF frame				*
;*-------------------------------------------------------*
;	jsr		gif_display_frame
;*-------------------------------------------------------*
;*	Check user-abort flag				*
;*-------------------------------------------------------*
;	tst.l		d0
;	bmi		gif_error

	bra		gif_error

*-------------------------------------------------------*
.decode_error:
*-------------------------------------------------------*
	bra		gif_block_loop

*-------------------------------------------------------*
read_gifdata:
*-------------------------------------------------------*
	move.l		gif_filebuffer,a0
	bra		gif_readfile

gifchkline		macro
	subq.w		#1,d5
	bne.s		.nnl\@
	bsr		gif_newline
.nnl\@:
	endm

*-------------------------------------------------------*
decode_image:
*-------------------------------------------------------*
	move.l		a2,gif_lineptr
	moveq		#0,d4
	move.b		(a0)+,d4
	moveq		#1,d1
	lsl.w		d4,d1
	move.l		d1,a3
	addq.w		#1,d1
	move.l		d1,a4
	addq.w		#1,d1
	addq.w		#1,d4
	moveq		#1,d2
	lsl.w		d4,d2
	move.w		d2,d7
	subq.w		#1,d2
	swap		d1
	move.w		d4,d1
	swap		d1
	moveq		#0,d3	
	moveq		#0,d6
	bsr		gif_newline
	lea		dictionary,a2
	lea		codestack,a5
.next:	move.l		(a0),d0
	lsr.w		#8,d0
	swap		d0
	ror.w		#8,d0
	lsr.l		d3,d0
	add.w		d4,d3
	and.w		d2,d0
	move.w		d3,d6
	and.w		#%111,d3
	lsr.w		#3,d6
	add.l		d6,a0
	cmp.w		a3,d0
	bne.s		.nres
	swap		d1
	move.w		d1,d4
	swap		d1
	moveq		#1,d7
	lsl.w		d4,d7
	move.w		d7,d2
	subq.w		#1,d2
	move.w		a4,d1
	addq.w		#1,d1
	bra.s		.next
.nres:	lea		(a2,d1.w*4),a6
	cmp.w		a4,d0
	bgt.s		.nend
	beq.s		.exit
	move.w		d0,(a6)
	move.w		d0,-(a6)
	move.b		d0,(a1)+
	bra.s		.done
.nend:	move.w		d0,(a6)
	move.w		d0,d6
	addq.w		#1,d6	
.read:	move.b		3(a2,d0.w*4),-(a5)
	move.w		0(a2,d0.w*4),d0
	cmp.w		a4,d0
	bgt.s		.read
	move.w		d0,-(a6)
	move.b		d0,(a1)+	
	move.l		#(codestack-1),d0
	sub.l		a5,d0
.copy:	gifchkline
	move.b		(a5)+,(a1)+
	dbra		d0,.copy
	cmp.w		d1,d6
	bne.s		.done
	move.b		1(a6),-1(a1)	
.done:	gifchkline
	addq.w		#1,d1
	cmp.w		d7,d1
	ble		.next
	cmp.w		#12,d4
	beq		.next
	add.w		d7,d7
	addq.w		#1,d4
	move.w		d7,d2
	subq.w		#1,d2
	bra		.next
.exit:	rts

*-------------------------------------------------------*
gif_newline:
*-------------------------------------------------------*
	push.l		a6
	move.l		gif_lineptr,a6
.again:	move.l		(a6)+,d5
	bne.s		.cont
	move.l		gif_linebuffer,a6
	bra.s		.again
.cont:	move.l		d5,a1
	move.l		a6,gif_lineptr
	move.w		gif_id_width,d5
	pop.l		a6
	rts

*-------------------------------------------------------*
build_linepointers:
*-------------------------------------------------------*
	btst		#id_lace_bit,gif_id_flags
	bne.s		.interlaced
*-------------------------------------------------------*
.non_interlaced:
*-------------------------------------------------------*
	lea		normal_info,a2
	bsr		remap_lines
	bra.s		.remap_done
*-------------------------------------------------------*
.interlaced:
*-------------------------------------------------------*
	lea		group1_info,a2
	bsr		remap_lines
	lea		group2_info,a2
	bsr		remap_lines
	lea		group3_info,a2
	bsr		remap_lines
	lea		group4_info,a2
	bsr		remap_lines
*-------------------------------------------------------*
.remap_done:
*-------------------------------------------------------*
	clr.l		(a6)
	rts

*-------------------------------------------------------*
remap_lines:
*-------------------------------------------------------*
	push.l		a1
*-------------------------------------------------------*
	move.w		(a2)+,d1
	move.w		(a2)+,d2
*-------------------------------------------------------*
	move.w		gif_id_height,d7
	sub.w		d2,d7
	moveq		#1,d3
	lsl.w		d1,d3
	add.w		d3,d7
	subq.w		#1,d7
	lsr.w		d1,d7
*-------------------------------------------------------*
	moveq		#0,d0
	move.w		gif_id_width,d0
	mulu.w		d0,d2
	add.l		d2,a1
	lsl.l		d1,d0	
	move.l		d0,a5
*-------------------------------------------------------*
	bra		.ylps
.ylp:	move.l		a1,(a6)+
	add.l		a5,a1
.ylps:	dbra		d7,.ylp
*-------------------------------------------------------*
	pop.l		a1
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*

normal_info:	dc.w		0,0
group1_info:	dc.w		3,0
group2_info:	dc.w		3,4
group3_info:	dc.w		2,2
group4_info:	dc.w		1,1

*-------------------------------------------------------*
			bss
*-------------------------------------------------------*
*	Input fields					*
*-------------------------------------------------------*

last_delay:		ds.l	1

gif_lineptr:		ds.l	1
gif_linebuffer:		ds.l	1
gif_filebuffer:		ds.l	1
gif_imagebuffer:	ds.l	1
gif_filesize:		ds.l	1
gif_command:		ds.b	1
			even

*-------------------------------------------------------*
*	Local variables					*
*-------------------------------------------------------*

gif_sd_width:		ds.w	1
gif_sd_height:		ds.w	1
gif_sd_flags:		ds.b	1
gif_sd_bgcol:		ds.b	1
gif_sd_aspect:		ds.b	1
			even

gif_gce_delay:		ds.w	1
gif_gce_flags:		ds.b	1
gif_gce_tcidx:		ds.b	1
			even

gif_id_xoff:		ds.w	1
gif_id_yoff:		ds.w	1
gif_id_width:		ds.w	1
gif_id_height:		ds.w	1
gif_id_flags:		ds.b	1
			even

gif_codebuffer_h:	ds.l	1
gif_codebuffer:		ds.l	1
gif_colours:		ds.w	1
gif_handle:		ds.w	1
gif_type:		ds.b	1
gif_eblock_type:	ds.b	1
animated_gif:		ds.b	1
			even

*-------------------------------------------------------*
*	Dictionary & codes				*
*-------------------------------------------------------*

gif_palette:		ds.l	256

dictionary:		ds.b	16384 

			ds.b	4096
codestack:		ds.l	1

gif_position_ptr:	ds.l	1
gif_loopback_ptr:	ds.l	1
gif_chunksize:		ds.l	1
gif_chunktide:		ds.l	1
gif_tidebuffer:		ds.b	chunk_size

gif_filename:		ds.b	256

*-------------------------------------------------------*
			text
*-------------------------------------------------------*
