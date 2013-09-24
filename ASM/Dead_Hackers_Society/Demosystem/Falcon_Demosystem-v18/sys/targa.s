; Falcon demosystem
;
; Targa saving routine
; (Atari Falcon hicolour -> 24bit Targa)
; 
; February 15, 2003
; Updated June 17, 2006
;
; targa.s

		section	text

screenshot_hicol:

		clr.l	d0					;
		clr.l	d1					;
		move.w	video_width,d0				;Calculate Targa file size
		move.w	video_height,d1				;
		mulu.l	d1,d0					;
		mulu.l	#3,d0					;
		add.l	#18,d0					;
		move.l	d0,screenshot_size			;

		move.l	#screenshot_targa_buffer,.dest_adr

		move.w	video_width,d0				;Big -> little endian
		rol.w	#8,d0					;
		move.w	video_height,d1				;
		rol.w	#8,d1					;

		move.l	.dest_adr,a0				;Fill out header datas
		clr.w	(a0)+					;0 ID field length + colour map type
		move.b	#2,(a0)+				;2 Data type 2
		clr.l	(a0)+					;3
		clr.l	(a0)+					;7
		clr.b	(a0)+					;11
		move.w	d0,(a0)+				;12 Width
		move.w	d1,(a0)+				;14 Height
		move.b	#24,(a0)+				;16 24-bits
		move.b	#32,(a0)+				;17 Origo

		move.l	screen_adr,a0				;Convert 16-bit Falcon image to 24bit Targa
		move.l	.dest_adr,a1				;
		lea	18(a1),a1				;
		
		move.w	video_height,d7				;
		subq.w	#1,d7					;
.y:		move.w	video_width,d6				;
		subq.w	#1,d6					;
.x:
		clr.l	d0					;
		clr.l	d1					;
		move.w	(a0)+,d0				;

		move.w	d0,d1					;Blue
		and.w	#$001f,d1				;
		lsl.b	#3,d1					;5->8-bit
		move.b	d1,(a1)+				;

		move.w	d0,d1					;Green
		and.w	#$07e0,d1				;
		lsr.w	#3,d1					;6->8-bit
		move.b	d1,(a1)+				;

		rol.w	#5,d0					;Red
		and.w	#$001f,d0				;
		lsl.b	#3,d0					;5->8-bit
		move.b	d0,(a1)+				;

		dbra	d6,.x					;
		dbra	d7,.y					;

		rts
.dest_adr:	ds.l	1



		section	bss

screenshot_targa_buffer:
		ds.b	scr_w*scr_h*3+18			;Max targa size

		section	text


