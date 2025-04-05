; Falcon demosystem
;
; IFF saving routine 
; (Atari Falcon bitplane-screen -> IFF)
;
; November 15, 2000
; Modified June 17, 2006


		section	text

screenshot_bitplanes:

		clr.l	d0
		clr.l	d1
		move.w	video_width,d0				;Calculate IFF size
		move.w	video_height,d1				;
		move.w	d0,screenshot_bpl_x1			;
		move.w	d0,screenshot_bpl_x2			;
		move.w	d1,screenshot_bpl_y1			;
		move.w	d1,screenshot_bpl_y2			;
		mulu.l	d0,d1					;
		move.l	d1,screenshot_bplsize			;
		add.l	#56+768,d1				;Header+palette
		move.l	d1,screenshot_iff_size			;
		move.l	d1,screenshot_size			;


		lea.l	$ffff9800.w,a0				;Save the colour palette
		lea.l	screenshot_iff_pal,a1			;
		move.w	#256-1,d7				;
.pal:		move.b	(a0),(a1)+				;
		move.b	1(a0),(a1)+				;
		move.b	3(a0),(a1)+				;
		addq.l	#4,a0					;
		dbra	d7,.pal					;


		move.l	screen_adr,a2				;Screen address! (change if needed)
		lea.l	screenshot_bpl_buffer,a1		;

		clr.l	d0					;
		move.w	video_width,d0				;

		move.w	video_height,d7				;
		subq.w	#1,d7					;
.loop:		move.l	a2,a3					;
		add.l	d0,a2					;
		move.w	#8-1,d6					;Eight bitplanes
.loop2:		move.l	a3,a0					;
		addq.l	#2,a3					;
		move.w	video_width,d5				;
		lsr.w	#4,d5					;
		subq.w	#1,d5					;
.loop3:		
		move.w	(a0),(a1)+				;
		lea.l	16(a0),a0				;

		dbra	d5,.loop3				;
		dbra	d6,.loop2				;
		dbra	d7,.loop				;
		rts


		section	data


;-------------- IFF headers and buffers 

screenshot_iff_buffer:
			;filesize
			dc.b	'FORM'
screenshot_iff_size:	dc.l	0

			;header
			dc.b	'ILBM'
		
			;information
			dc.b	'BMHD'
			dc.l	20				;Infosize
screenshot_bpl_x1:	dc.w	0				;X-pixels
screenshot_bpl_y1:	dc.w	0				;Y-pixels
			dc.w	0				;X-offset
			dc.w	0				;Y-offset
			dc.b	8				;# of bitplanes
			dc.b	0				;No mask
			dc.b	0				;Uncompressed
			dc.b	0				;Unused
			dc.w	0				;Transparentcolour for mask
			dc.b	10				;X-aspect (320*200)
			dc.b	11				;Y-aspect (?)
screenshot_bpl_x2:	dc.w	0				;Page width
screenshot_bpl_y2:	dc.w	0				;Page height

			;palette
			dc.b	'CMAP'
			dc.l	768
screenshot_iff_pal:	ds.b	768

			;pic data
			dc.b	'BODY'
screenshot_bplsize:	dc.l	0
screenshot_bpl_buffer:	ds.b	scr_w*scr_h			;Maximum bitplane screen size


;-------------- End of IFF


		section	text

