;
; CTPic
;
; July 25, 2004
; Anders Eriksson
; ae@dhs.nu
;
; tgaload.s

		section	text

tgaload:	move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;
		beq.s	.ok					;ok

		move.l	#filenotfound,d0			;error message
		bsr.w	cconws					;
		move.l	filename,d0				;
		bsr.w	cconws					;
		move.l	#br,d0					;
		bsr.w	cconws					;
		bra.w	exit					;exit

.ok:		move.l	dta+26,filelength			;filelength

		move.l	filelength,d0				;check Targa filelength
		cmp.l	#230418,d0				;
		beq.s	.sizeok					;correct size
	
		move.l	#tgasize,d0				;wrong size
		bsr.w	cconws					;
		bra.w	exit					;

.sizeok:	move.l	filelength,d0				;reserve memory
		bsr.w	mxalloc_fast				;
		move.l	d0,filebuffer				;

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


		lea.l	tgahead,a0				;check for correct Targa header
		move.l	filebuffer,a1				;
		move.w	#9-1,d7					;
.check:		move.w	(a0)+,d0				;
		cmp.w	(a1)+,d0				;
		bne.s	.no					;
		dbra	d7,.check				;
		bra.s	.checkok				;

.no:		move.l	#badtga,d0				;unknown header
		bsr.w	cconws					;
		bra.w	exit

.checkok:	move.l	#goodtga,d0				;header OK
		bsr.w	cconws					;
		
		section	text
		