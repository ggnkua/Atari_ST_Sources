;
; APXconv
; 
; February 22, 2003
; Anders Eriksson
; ae@dhs.nu
; 
; iff.s

		section	text

convert_chunky_to_iff:
		move.w	#1,chunky

convert_planes_to_iff:
		
		clr.l	d0
		clr.l	d1
		move.l	source_adr,a0			;apex-file
		move.w	12(a0),d0			;x-res
		move.w	d0,x_res			:
		*move.w	#256,x_res
		move.w	14(a0),d1			;y-res
		move.w	d1,y_res			;
		*move.w	#256,y_res
		mulu.l	d1,d0				;imagedata size
		move.l	d0,imgdata_size			;
		add.l	#768+56,d0			;palette+header
		move.l	d0,totalimg_size		;
		bsr.w	mxalloc_fast			;reserve space
		move.l	d0,dest_adr			;destination picture
		
		lea.l	iff_head,a0
		move.l	dest_adr,a1
		move.w	#48/4-1,d7
.copyheader:	move.l	(a0)+,(a1)+
		dbra	d7,.copyheader


		move.l	dest_adr,a0		
		move.l	totalimg_size,4(a0)		;image size
		move.w	x_res,20(a0)			;x-res
		move.w	y_res,22(a0)			;y-res
		move.b	#8,28(a0)			;bitplanes
		move.w	x_res,36(a0)			;x-res
		move.w	y_res,38(a0)			;y-res
		move.l	#"BODY",816(a0)			;start of imagedata
		move.l	imgdata_size,820(a0)		;size of imagedata

		move.l	source_adr,a0			;apx file
		lea.l	20(a0),a0			;paletteofs
		move.l	dest_adr,a1			;iff file
		lea.l	48(a1),a1			;paletteofs
		move.w	#768/4-1,d7			;copy colour palette
.copycolours:	move.l	(a0)+,(a1)+			;
		dbra	d7,.copycolours			;
			

		tst.w	chunky				;should we convert a
		beq.w	planes_to_iff			;chunky or plane picture?

chunky_to_iff:
		move.l	imgdata_size,d0			;bplsize
		bsr.w	mxalloc_fast			;reserve space for c2p
		move.l	d0,c2p_adr			;
		
		move.l	source_adr,a0			;chunky data
		lea.l	788(a0),a0			;
		
		move.l	d0,a1				;planar data buffer
		bsr.w	c2p1x1_8_falcon			;chunky -> bitplanes




		move.l	c2p_adr,a2			;source data
		
		move.l	dest_adr,a1			;destination
		lea.l	824(a1),a1			;
		
		clr.l	d0				;linewidth of apx (incl. mask)
		move.w	x_res,d0			;
		
		move.w	y_res,d7			;move.w	#snap_y-1,d7
		subq.w	#1,d7				;
.loop:		move.l	a2,a3				;
		add.l	d0,a2				;
		move.w	#8-1,d6				;#snap_planes-1,d6
.loop2:		move.l	a3,a0				;
		addq.l	#2,a3				;
		move.w	x_res,d5			;move.w	#snap_x/16-1,d5
		lsr.w	#4,d5
		subq.w	#1,d5
.loop3:		
		move.w	(a0),(a1)+			;
		lea.l	16(a0),a0			;8bpl+mask

		dbra	d5,.loop3			;
		dbra	d6,.loop2			;
		dbra	d7,.loop			;

		bra.w	conversion_done			;save it as file		



planes_to_iff:
		move.l	source_adr,a2			;source data
		lea.l	788+2(a2),a2			;
		
		move.l	dest_adr,a1			;destination
		lea.l	824(a1),a1			;
		
		clr.l	d0				;linewidth of apx (incl. mask)
		move.w	x_res,d0			;
		divu.l	#8,d0				;
		mulu.l	#9,d0				;
		

		move.w	y_res,d7			;move.w	#snap_y-1,d7
		subq.w	#1,d7				;
.loop:		move.l	a2,a3				;
		add.l	d0,a2				;
		move.w	#8-1,d6				;#snap_planes-1,d6
.loop2:		move.l	a3,a0				;
		addq.l	#2,a3				;
		move.w	x_res,d5			;move.w	#snap_x/16-1,d5
		lsr.w	#4,d5
		subq.w	#1,d5
.loop3:		
		move.w	(a0),(a1)+			;
		lea.l	18(a0),a0			;8bpl+mask

		dbra	d5,.loop3			;
		dbra	d6,.loop2			;
		dbra	d7,.loop			;





conversion_done:
		move.l	#iff_filename,filename
		
		include	'save.s'
		

		rts		

		section	data

iff_head:	dc.b	'FORM'				;4b o0
		dc.l	0 				;4b o4
		dc.b	'ILBM'				;4b o8
		dc.b	'BMHD'				;4b o12
		dc.l	20				;4b o16 infosize
		dc.w	0 				;2b o20 x pixels
		dc.w	0 				;2b o22 y pixels
		dc.w	0				;2b o24 x offset
		dc.w	0				;2b o26 y offset
		dc.b	8 				;1b o28 # of bitplanes
		dc.b	0				;1b o29 no mask
		dc.b	0				;1b o30 uncompressed
		dc.b	0				;1b o31 unused
		dc.w	0				;2b o32 transparentcolour for mask
		dc.b	10				;1b o34 x aspect (320*200)
		dc.b	11				;1b o35 y aspect (?)
		dc.w	0 				;2b o36 page width
		dc.w	0 				;2b o38 page height
		dc.b	'CMAP'				;4b o40
		dc.l	768				;4b o44

		section	text

