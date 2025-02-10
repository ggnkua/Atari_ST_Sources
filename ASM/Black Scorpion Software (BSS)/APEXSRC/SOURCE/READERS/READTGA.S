*-------------------------------------------------------*
			text
*-------------------------------------------------------*

*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*

tga_id_len		=	0
tga_cmap_type		=	1
tga_image_type		=	2
tga_cmap_origin		=	3
tga_cmap_length		=	5
tga_cmap_bits		=	7
tga_xpos		=	8
tga_ypos		=	10

tga_width		=	12
tga_height		=	14

tga_pixsize		=	16
tga_imgdesc		=	17
tga_slen		=	18

*-------------------------------------------------------*
examine_targa:
*-------------------------------------------------------*
	move.l		tga_name,a0
	jsr		get_filesize
	move.l		d0,file_size
*-------------------------------------------------------*
	move.l		tga_name,a0
	jsr		OpenFile
	move.w		d0,tga_handle
	bmi		.error
*-------------------------------------------------------*
	lea		targa_header,a0
	moveq		#tga_slen,d1
	move.w		tga_handle,d0
	jsr		ReadFile
	tst.l		d0
	bmi		.error
*-------------------------------------------------------*
	lea		targa_header,a6
*-------------------------------------------------------*
	move.b		tga_image_type(a6),d0
	move.b		d0,targa_type
*-------------------------------------------------------*
	move.w		tga_width(a6),d0
	ror.w		#8,d0
	move.w		d0,targa_width
	move.w		tga_height(a6),d0
	ror.w		#8,d0
	move.w		d0,targa_height
*-------------------------------------------------------*
	moveq		#0,d0
	move.b		tga_pixsize(a6),d0
	move.w		d0,targa_cols
*-------------------------------------------------------*
	move.w		targa_width,d0
	mulu		targa_height,d0
	cmp.w		#32,targa_cols
	beq.s		.c32
	cmp.w		#24,targa_cols
	beq.s		.c24
	add.l		d0,d0
	bra.s		.go
.c24:	mulu.l		#3,d0
	bra.s		.go
.c32:	lsl.l		#2,d0
.go:	move.l		d0,tga_size	
*-------------------------------------------------------*
	move.b		tga_imgdesc(a6),targa_bits
*-------------------------------------------------------*
	move.w		#1,line_dir
	moveq		#1<<5,d0
	and.b		targa_bits,d0
	bne.s		.done
	move.w		#-1,line_dir
*-------------------------------------------------------*
.done:	moveq		#0,d0
	bra.s		.end
*-------------------------------------------------------*
.error:	moveq		#-1,d0
*-------------------------------------------------------*
.end:	push.l		d0
	move.w		tga_handle,d0
	bmi.s		.no
	bsr		CloseFile
.no:	pop.l		d0
	rts

*-------------------------------------------------------*
read_targa:
*-------------------------------------------------------*
	clr.w		pak_state
*-------------------------------------------------------*
	move.l		targa,targa_buffer
*-------------------------------------------------------*
	move.l		CIRCULAR_BUFFER,file_buffer
	move.l		#12*4096,d0
	move.l		d0,file_buffersize
*-------------------------------------------------------*
	move.l		tga_name,a0
	jsr		get_filesize
	move.l		d0,file_size
*-------------------------------------------------------*
	move.l		tga_name,a0
	jsr		OpenFile
	move.w		d0,tga_handle
	bmi.s		.error
*-------------------------------------------------------*
	lea		targa_header,a0
	moveq		#tga_slen,d1
	move.w		tga_handle,d0
	jsr		ReadFile
	tst.l		d0
	bmi.s		.error
*-------------------------------------------------------*
	sub.l		d0,file_size
	beq.s		.error
*-------------------------------------------------------*
	lea		targa_header,a6
	move.b		tga_image_type(a6),d0
	move.b		d0,targa_type
	cmp.b		#2,d0
	beq.s		.decode_image
	cmp.b		#10,d0
	bne.s		.error
*-------------------------------------------------------*
.decode_image:
*-------------------------------------------------------*
	bsr		targa_true_colour
*-------------------------------------------------------*
.done:	moveq		#0,d0
	bra.s		.end
*-------------------------------------------------------*
.error:	moveq		#-1,d0
*-------------------------------------------------------*
.end:	push.l		d0
	move.w		tga_handle,d0
	bmi.s		.no
	bsr		CloseFile
.no:	pop.l		d0
	rts

*-------------------------------------------------------*
targa_true_colour:
*-------------------------------------------------------*
	move.w		targa_width,d0
	mulu.w		targa_height,d0

;	lsr.l		#2,d0

	move.l		d0,targa_pixels
*-------------------------------------------------------*
	lea		targa_header,a6
	moveq		#0,d0
	move.b		tga_pixsize(a6),d0
	move.w		d0,file_cols
*-------------------------------------------------------*
*	Skip any header comments			*
*-------------------------------------------------------*
	move.b		tga_id_len(a6),d0
	beq.s		.no_comments
*-------------------------------------------------------*
	pushall
	ext.w		d0
	ext.l		d0
	move.l		d0,d1
	sub.l		d1,file_size
	move.w		tga_handle,d0
	move.l		targa_buffer,a0
	jsr		ReadFile
	popall
*-------------------------------------------------------*
.no_comments:
*-------------------------------------------------------*
	bsr		decrunch
	moveq		#0,d0
.err	rts

*-------------------------------------------------------*
decrunch:
*-------------------------------------------------------*
	cmp.w		#24,file_cols
	beq.s		.l24
	cmp.w		#32,file_cols
	beq.s		.l32
.l16	moveq		#0,d0
	bra.s		.go
.l24	moveq		#1,d0
	bra.s		.go
.l32	moveq		#2,d0
.go	add.w		d0,d0
	cmp.b		#10,targa_type
	bne.s		.get
	addq		#1,d0
.get	lea		decrunchers,a1
	lsl.w		#2,d0
	move.l		(a1,d0.w),loader
	push.l		targa_buffer
.loop	jsr		read_block
	move.l		targa_buffer,a1
	move.l		loader,a0	
	jsr		(a0)
	move.l		a1,targa_buffer
	tst.l		file_size
	ble.s		.stop
	tst.w		pak_state
	bmi.s		.stop
	tst.l		targa_pixels
	bgt.s		.loop
.stop	pop.l		targa_buffer
	rts	
	
decrunchers:
	dc.l		raw_16bit,pak_16bit
	dc.l		raw_24bit,pak_24bit
	dc.l		raw_32bit,pak_32bit
	
*-------------------------------------------------------*
*	16-bit unpack routine				*
*-------------------------------------------------------*
	
*-------------------------------------------------------*
		rsreset
*-------------------------------------------------------*
p16_strt	rs.b	1
p16_code	rs.b	1
p16_gotrlu	rs.b	1
p16_gotcpu	rs.b	1
p16_gotcpl	rs.b	1

p16_routs:	dc.l	G16_strt
		dc.l	G16_code
		dc.l	G16_rlU
		dc.l	G16_cpU
		dc.l	G16_cpL

pak_16bit:
	move.l		file_buffer,a0
	move.w		pak_state,d0
	lsl.w		#2,d0
	lea		p16_routs,a2
	move.l		(a2,d0.w),a2
	jmp		(a2)

G16_strt:
	moveq		#0,d7
	move.b		(a0)+,d7
	move.w		d7,got_code
	move.w		#p16_code,pak_state
	subq.l		#1,counter
	beq		G16_stop
G16_code:
	move.w		got_code,d7
	tst.b		d7
	bmi		G16_run
G16_copy:
	and.w		#%1111111,d7
	addq		#1,d7
	move.w		d7,copysize
G16_cpL:
	move.w		#p16_gotcpu,pak_state
	move.b		(a0)+,cpU
	subq.l		#1,counter
	beq		G16_stop
G16_cpU:
	move.w		#p16_gotcpl,pak_state
	move.b		cpU,d0
	ror.w		#8,d0
	move.b		(a0)+,d0
	ror.w		#8,d0
	move.w		d0,d1
	lsl.w		#3,d1
	move.w		d0,d2
	lsr.w		#2,d2
	move.w		d0,d3
	lsr.w		#7,d3
	and.w		#%11111000,d1
	and.w		#%11111000,d2
	and.w		#%11111000,d3
	bfins		d3,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d1,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq		G16_err
	subq		#1,copysize
	subq.l		#1,counter
	move.l		counter,d0
	or.w		copysize,d0
	tst.l		d0
	beq		G16_end
	tst.l		counter
	beq		G16_stop
	tst.w		copysize
	bne		G16_cpL
	bra		G16_strt
G16_run:
	and.w		#%1111111,d7
	move.w		d7,runsize
	move.w		#p16_gotrlu,pak_state
	move.b		(a0)+,rlU
	subq.l		#1,counter
	beq		G16_stop
G16_rlU:
	move.w		runsize,d7
	move.b		rlU,d0
	ror.w		#8,d0
	move.b		(a0)+,d0
	subq.l		#1,counter
	ror.w		#8,d0
	move.w		d0,d1
	lsl.w		#3,d1
	move.w		d0,d2
	lsr.w		#2,d2
	move.w		d0,d3
	lsr.w		#7,d3
	and.w		#%11111000,d1
	and.w		#%11111000,d2
	and.w		#%11111000,d3
.run:	bfins		d3,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d1,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq		G16_err
	dbra		d7,.run
	tst.l		counter
	bne		G16_strt
G16_end:
	move.w		#p16_strt,pak_state
G16_stop
	rts
G16_err:
	move.w		#-1,pak_state
	rts

*-------------------------------------------------------*
*	24-bit unpack routine				*
*-------------------------------------------------------*
	
*-------------------------------------------------------*
		rsreset
*-------------------------------------------------------*
p24_strt	rs.b	1
p24_code	rs.b	1
p24_gotrlr	rs.b	1
p24_gotrlg	rs.b	1
p24_gotcpr	rs.b	1
p24_gotcpg	rs.b	1
p24_gotcpb	rs.b	1

p24_routs:	dc.l	G24_strt
		dc.l	G24_code
		dc.l	G24_rlR
		dc.l	G24_rlG
		dc.l	G24_cpR
		dc.l	G24_cpG
		dc.l	G24_cpB

pak_24bit:
	move.l		file_buffer,a0
	move.w		pak_state,d0
	lsl.w		#2,d0
	lea		p24_routs,a2
	move.l		(a2,d0.w),a2
	jmp		(a2)

G24_strt:
	moveq		#0,d7
	move.b		(a0)+,d7
	move.w		d7,got_code
	move.w		#p24_code,pak_state
	subq.l		#1,counter
	beq		G24_stop
G24_code:
	move.w		got_code,d7
	tst.b		d7
	bmi		G24_run
G24_copy:
	and.w		#%1111111,d7
	addq		#1,d7
	move.w		d7,copysize
G24_cpB:
	move.w		#p24_gotcpr,pak_state
	move.b		(a0)+,rlR
	subq.l		#1,counter
	beq		G24_stop
G24_cpR:
	move.w		#p24_gotcpg,pak_state
	move.b		(a0)+,rlG
	subq.l		#1,counter
	beq		G24_stop
G24_cpG:
	move.w		#p24_gotcpb,pak_state
	move.b		(a0)+,rlB
	move.b		rlR,d1
	move.b		rlG,d2
	move.b		rlB,d3
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq		G24_err
	subq		#1,copysize
	subq.l		#1,counter
	move.l		counter,d0
	or.w		copysize,d0
	tst.l		d0
	beq		G24_end
	tst.l		counter
	beq		G24_stop
	tst.w		copysize
	bne		G24_cpB
	bra		G24_strt
G24_run:
	and.w		#%1111111,d7
	move.w		d7,runsize
	move.w		#p24_gotrlr,pak_state
	move.b		(a0)+,rlR
	subq.l		#1,counter
	beq		G24_stop
G24_rlR:
	move.w		runsize,d7
	move.w		#p24_gotrlg,pak_state
	move.b		(a0)+,rlG	
	subq.l		#1,counter
	beq		G24_stop
G24_rlG:
	move.w		runsize,d7
	move.b		(a0)+,d3
	subq.l		#1,counter
	move.b		rlR,d1
	move.b		rlG,d2
.run:	bfins		d3,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d1,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq		G24_err
	dbra		d7,.run
	tst.l		counter
	bne		G24_strt
G24_end:
	move.w		#p24_strt,pak_state
G24_stop:
	rts
G24_err:
	move.w		#-1,pak_state
	rts

*-------------------------------------------------------*
*	32-bit unpack routine				*
*-------------------------------------------------------*
	
*-------------------------------------------------------*
		rsreset
*-------------------------------------------------------*
p32_strt	rs.b	1
p32_code	rs.b	1
p32_gotrlr	rs.b	1
p32_gotrlg	rs.b	1
p32_gotrlb	rs.b	1
p32_gotcpr	rs.b	1
p32_gotcpg	rs.b	1
p32_gotcpb	rs.b	1
p32_gotcpx	rs.b	1

p32_routs:	dc.l	G32_strt
		dc.l	G32_code
		dc.l	G32_rlR
		dc.l	G32_rlG
		dc.l	G32_rlB
		dc.l	G32_cpR
		dc.l	G32_cpG
		dc.l	G32_cpB
		dc.l	G32_cpX

pak_32bit:
	move.l		file_buffer,a0
	move.w		pak_state,d0
	lsl.w		#2,d0
	lea		p32_routs,a2
	move.l		(a2,d0.w),a2
	jmp		(a2)

G32_strt:
	moveq		#0,d7
	move.b		(a0)+,d7
	move.w		d7,got_code
	move.w		#p32_code,pak_state
	subq.l		#1,counter
	beq		G32_stop
G32_code:
	move.w		got_code,d7
	tst.b		d7
	bmi		G32_run
G32_copy:
	and.w		#%1111111,d7
	addq		#1,d7
	move.w		d7,copysize
G32_cpX:
	move.w		#p32_gotcpr,pak_state
	move.b		(a0)+,rlR
	subq.l		#1,counter
	beq		G32_stop
G32_cpR:
	move.w		#p32_gotcpg,pak_state
	move.b		(a0)+,rlG
	subq.l		#1,counter
	beq		G32_stop
G32_cpG:
	move.w		#p32_gotcpb,pak_state
	move.b		(a0)+,rlB
	subq.l		#1,counter
	beq		G32_stop
G32_cpB:
	move.w		#p32_gotcpx,pak_state
	addq.l		#1,a0
	move.b		rlR,d1
	move.b		rlG,d2
	move.b		rlB,d3
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq		G32_err
	subq		#1,copysize
	subq.l		#1,counter
	move.l		counter,d0
	or.w		copysize,d0
	tst.l		d0
	beq		G32_end
	tst.l		counter
	beq		G32_stop
	tst.w		copysize
	bne		G32_cpX
	bra		G32_strt
G32_run:
	and.w		#%1111111,d7
	move.w		d7,runsize
	move.w		#p32_gotrlr,pak_state
	move.b		(a0)+,rlR
	subq.l		#1,counter
	beq		G32_stop
G32_rlR:
	move.w		runsize,d7
	move.w		#p32_gotrlg,pak_state
	move.b		(a0)+,rlG	
	subq.l		#1,counter
	beq		G32_stop
G32_rlG:
	move.w		runsize,d7
	move.w		#p32_gotrlb,pak_state
	move.b		(a0)+,rlB	
	subq.l		#1,counter
	beq		G32_stop
G32_rlB:
	move.w		#-1,pak_state
	move.w		runsize,d7
	move.b		(a0)+,d0
	subq.l		#1,counter
	move.b		rlR,d1
	move.b		rlG,d2
	move.b		rlB,d3
.run:	bfins		d3,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d1,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq		G32_err
	dbra		d7,.run
	tst.l		counter
	bne		G32_strt
G32_end:
	move.w		#p32_strt,pak_state
G32_stop:
	rts
G32_err:
	move.w		#-1,pak_state
	rts

*-------------------------------------------------------*
*	raw routines					*
*-------------------------------------------------------*
	
raw_16bit:
	move.l		file_buffer,a0
	move.l		counter,d7
.rdlp	move.w		(a0)+,d0
	ror.w		#8,d0
	move.w		d0,d1
	lsl.w		#3,d1
	move.w		d0,d2
	lsr.w		#2,d2
	move.w		d0,d3
	lsr.w		#7,d3
	and.w		#%11111000,d1
	and.w		#%11111000,d2
	and.w		#%11111000,d3
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq.s		raw_err
	subq.l		#2,d7
	bgt.s		.rdlp
	rts
	
raw_24bit:
	move.l		file_buffer,a0
	move.l		counter,d7
.rdlp:	move.b		(a0)+,d3
	move.b		(a0)+,d2
	move.b		(a0)+,d1
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq.s		raw_err
	subq.l		#3,d7
	bgt.s		.rdlp
	rts

raw_32bit:
	move.l		file_buffer,a0
	move.l		counter,d7
.rdlp:	move.b		(a0)+,d3
	move.b		(a0)+,d2
	move.b		(a0)+,d1
	addq.l		#1,a0
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w		d0,(a1)+
	subq.l		#1,targa_pixels
	beq.s		raw_err
	subq.l		#4,d7
	bgt.s		.rdlp
	rts

raw_err:
	move.w		#-1,pak_state
	rts

*-------------------------------------------------------*
*	Read next block of data from disk		*
*-------------------------------------------------------*
read_block:
*-------------------------------------------------------*
	move.l		file_size,d0
	move.l		file_buffersize,d1
	sub.l		d1,d0
	bpl.s		.cont
	moveq		#0,d0
	move.l		file_size,d1
.cont	move.l		d0,file_size
	move.l		d1,counter
	move.w		tga_handle,d0
	move.l		file_buffer,a0
	jsr		ReadFile
	rts

*-------------------------------------------------------*
			bss
*-------------------------------------------------------*

*-------------------------------------------------------*
*	Local variables					*
*-------------------------------------------------------*

tga_name:		ds.l	1
tga_handle:		ds.l	1
tga_size:		ds.l	1
targa:			ds.l	1

targa_header:		ds.b	tga_slen
targa_width:		ds.w	1
targa_height:		ds.w	1
targa_cols:		ds.w	1
targa_bits:		ds.w	1
line_dir:		ds.w	1

buffer_base:		ds.l	1
file_buffer:		ds.l	1
file_buffersize:	ds.l	1
file_cols:		ds.w	1
file_type:		ds.w	1

pixels:			ds.l	1
loader:			ds.l	1
counter:		ds.l	1
targa_pixels:		ds.l	1
targa_buffer:		ds.l	1

runsize:		ds.w	1
copysize:		ds.w	1
got_code:		ds.w	1
pak_state:		ds.w	1
targa_type:		ds.w	1

rlR:			ds.b	1
rlG:			ds.b	1
rlB:			ds.b	1
rlU:			ds.b	1

cpR:			ds.b	1
cpG:			ds.b	1
cpB:			ds.b	1
cpU:			ds.b	1
			even

*-------------------------------------------------------*
			text
*-------------------------------------------------------*
