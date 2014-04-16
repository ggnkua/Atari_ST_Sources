;
; GODconv
; 
; April 16, 2004
; Anders Eriksson
; ae@dhs.nu
; 
; loader.s

		section	text

loader:		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;does file exist?
		beq.s	.file_exists				;yes

		move.l	#nofile_text,exit_text_adr		;no
		bra.w	pterm					;


.file_exists:	move.l	dta+26,filelength			;store filelength

		move.l	filelength,d0				;reserve memory
		bsr.w	mxalloc_fast				;
		move.l	d0,source_adr				;

		move.w	#0,-(sp)				;open file read only
		move.l	filename,-(sp)				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,filenumber				;store filenumber

		move.l	source_adr,-(sp)			;buffer address
		move.l	filelength,-(sp)			;length of file
		move.w	filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;

		move.w	filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;


		section	text