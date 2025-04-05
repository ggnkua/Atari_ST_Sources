; Falcon demosystem
;
; January 13, 2000
;
; loader.s

; in:   filename.l = address to filename (null term)
;     filebuffer.l = destination address

		section	text

loader:		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;
		beq.s	.ok					;ok
		move.l	#exit_filenotfound_text,error_adr	;error message
		bra.w	exit					;

.ok:		move.l	dta+26,filelength			;filelength

		move.w	#0,-(sp)				;open file read only
		move.l	filename,-(sp)				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,filenumber				;store filenumber
 
		move.l	filebuffer,-(sp)			;buffer address
		move.l	filelength,-(sp)			;length of file
		move.w	filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;

		move.w	filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;

		clr.l	filename

		rts



		section	bss

filename:	ds.l	1
filenumber:	ds.w	1
filelength:	ds.l	1
filebuffer:	ds.l	1


		section	text
