;
; GODconv
; 
; April 16, 2004
; Anders Eriksson
; ae@dhs.nu
; 
; targa.s

		section	text

convert_hicol_to_targa:

		clr.l	d0
		clr.l	d1
		move.l	source_adr,a0
		move.w	2(a0),d0
		move.w	d0,x_res
		move.w	4(a0),d1
		move.w	d1,y_res
		mulu.l	d1,d0
		mulu.l	#3,d0
		move.l	d0,imgdata_size
		add.l	#18,d0
		move.l	d0,totalimg_size

		bsr.w	mxalloc_fast
		move.l	d0,dest_adr

		move.w	x_res,d0	;big -> little endian
		rol.w	#8,d0		;
		move.w	y_res,d1	;
		rol.w	#8,d1		;

		move.l	dest_adr,a0	;fill out header datas
		clr.w	(a0)+		;0 id field length + colour map type
		move.b	#2,(a0)+	;2 data type 2
		clr.l	(a0)+		;3
		clr.l	(a0)+		;7
		clr.b	(a0)+		;11
		move.w	d0,(a0)+	;12 width
		move.w	d1,(a0)+	;14 height
		move.b	#24,(a0)+	;16 24 bits
		move.b	#32,(a0)+	;17 origo

		move.l	source_adr,a0	;convert 16bit falcon image
		lea.l	20(a0),a0	;to 24bit targa
		move.l	dest_adr,a1	;
		lea.l	18(a1),a1	;
		
		move.w	y_res,d7	;
		subq.w	#1,d7		;
.y:		move.w	x_res,d6	;
		subq.w	#1,d6		;
.x:
		clr.l	d0		;
		clr.l	d1		;
		move.w	(a0)+,d0	;

		move.w	d0,d1		;blue
		and.w	#$001f,d1	;
		lsl.b	#3,d1		;5->8bit
		move.b	d1,(a1)+	;

		move.w	d0,d1		;green
		and.w	#$07e0,d1	;
		lsr.w	#3,d1		;6->8bit
		move.b	d1,(a1)+	;

		rol.w	#5,d0		;red
		and.w	#$001f,d0	;
		lsl.b	#3,d0		;5->8bit
		move.b	d0,(a1)+	;

		dbra	d6,.x
		dbra	d7,.y



		move.l	#targa_filename,filename
		include	'save.s'



		section	text
