;
; GODconv
; 
; April 16, 2004
; Anders Eriksson
; ae@dhs.nu
; 
; save.s

		section	text

		clr.w	-(sp)				;fcreate()
		move.l	filename,-(sp)			;
		move.w	#$3c,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,filenumber

		move.l	dest_adr,-(sp)			;fwrite()
		move.l	totalimg_size,-(sp)		;
		move.w	filenumber,-(sp)		;
		move.w	#$40,-(sp)			;
		trap	#1				;
		lea.l	12(sp),sp			;

		move.w	filenumber,-(sp)		;fclose()
		move.w	#$3e,-(sp)			;
		trap	#1				;
		addq.l	#4,sp				;
		
		section	text