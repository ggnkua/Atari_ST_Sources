;
; Screenshot
;
; Bitplane screenshots saved as IFF
; Hicolour screenshots saved as Targa
; 
; 
; June 17, 2006
;
; Anders Eriksson
; ae@dhs.nu
; 
; screenshot.s

		section	text


screenshot_snapit:

		cmp.w	#8,video_depth
		beq.s	.do8
		
		cmp.w	#16,video_depth
		bne.s	.nodo

.do16:		move.l	#screenshot_targaname,screenshot_filename
		move.l	#screenshot_targa_buffer,screenshot_buffer
		bsr.w	screenshot_hicol
		bsr.w	screenshot_save
		bra.s	.nodo

.do8:		move.l	#screenshot_iffname,screenshot_filename
		move.l	#screenshot_iff_buffer,screenshot_buffer
		bsr.w	screenshot_bitplanes
		bsr.w	screenshot_save

.nodo:		rts


screenshot_save:

;input:		screenshot_filename.l	address to filename
;		screenshot_size.l	bytes to save
;		screenshot_buffer.l	address to buffer to save

		clr.w	-(sp)				;fcreate()
		move.l	screenshot_filename,-(sp)	;
		move.w	#$3c,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,.fn

		move.l	screenshot_buffer,-(sp)		;fwrite()
		move.l	screenshot_size,-(sp)		;
		move.w	.fn,-(sp)			;
		move.w	#$40,-(sp)			;
		trap	#1				;
		lea.l	12(sp),sp			;

		move.w	.fn,-(sp)			;fclose()
		move.w	#$3e,-(sp)			;
		trap	#1				;
		addq.l	#4,sp				;
	
		rts

.fn:		dc.w	0


		include	'sys\targa.s'
		include	'sys\iff.s'

		section	data

screenshot_targaname:	dc.b	'output.tga',0
			even

screenshot_iffname:	dc.b	'output.iff',0
			even

		section	bss

screenshot_filename:	ds.l	1
screenshot_size:	ds.l	1
screenshot_buffer:	ds.l	1
		
		section	text