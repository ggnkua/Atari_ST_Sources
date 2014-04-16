; DUMP
;
; September 21, 2003
; Anders Eriksson
; ae@dhs.nu
;
; loader.s


		section	text

	ifeq	ttpfile
		move.l	#fixedname,filename
	endc

		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		tst.l	d0					;
		bne.w	exit_filenotfound			;

		move.l	dta+26,filelength			;store filelength

		move.w	#3,-(sp)				;mxalloc() - prefer fastram
		move.l	filelength,-(sp)			;modulesize
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		tst.l	d0					;check if there is ram enough
		beq.w	exit_nomodram				;nope
		move.l	d0,filebuffer


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


		section	text