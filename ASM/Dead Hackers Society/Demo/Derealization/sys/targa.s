; Targa saving routine
; (Atari Falcon hicolour -> 24bit Targa)
; 
; February 15, 2003
; Updated June 17, 2006
;
; Anders Eriksson
; ae@dhs.nu
; 
; targa.s

		section	text

screenshot_hicol:

		clr.l	d0
		clr.l	d1
		move.w	video_width,d0
		move.w	video_height,d1
		mulu.l	d1,d0
		mulu.l	#3,d0
		add.l	#18,d0
		move.l	d0,screenshot_size

		move.l	#screenshot_targa_buffer,.dest_adr

		move.w	video_width,d0			;big -> little endian
		rol.w	#8,d0				;
		move.w	video_height,d1			;
		rol.w	#8,d1				;

		move.l	.dest_adr,a0			;fill out header datas
		clr.w	(a0)+				;0 id field length + colour map type
		move.b	#2,(a0)+			;2 data type 2
		clr.l	(a0)+				;3
		clr.l	(a0)+				;7
		clr.b	(a0)+				;11
		move.w	d0,(a0)+			;12 width
		move.w	d1,(a0)+			;14 height
		move.b	#24,(a0)+			;16 24 bits
		move.b	#32,(a0)+			;17 origo

		move.l	screen_adr,a0			;convert 16bit falcon image
		move.l	.dest_adr,a1			;to 24bit targa
		lea.l	18(a1),a1			;
		
		move.w	video_height,d7			;
		subq.w	#1,d7				;
.y:		move.w	video_width,d6			;
		subq.w	#1,d6				;
.x:
		clr.l	d0				;
		clr.l	d1				;
		move.w	(a0)+,d0			;

		move.w	d0,d1				;blue
		and.w	#$001f,d1			;
		lsl.b	#3,d1				;5->8bit
		move.b	d1,(a1)+			;

		move.w	d0,d1				;green
		and.w	#$07e0,d1			;
		lsr.w	#3,d1				;6->8bit
		move.b	d1,(a1)+			;

		rol.w	#5,d0				;red
		and.w	#$001f,d0			;
		lsl.b	#3,d0				;5->8bit
		move.b	d0,(a1)+			;

		dbra	d6,.x
		dbra	d7,.y

		rts
.dest_adr:	ds.l	1



		section	bss

screenshot_targa_buffer:	ds.b	320*240*3+18			;maximum targa size

		section	text


