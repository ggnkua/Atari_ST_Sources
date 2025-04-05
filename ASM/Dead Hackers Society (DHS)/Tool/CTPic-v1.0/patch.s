;
; CTPic
;
; July 25, 2004
; Anders Eriksson
; ae@dhs.nu
;
; patch.s

		section	text

flashload:	move.l	#flashname,filename

		move.w	#0,-(sp)				;fsfirst() get fileinfo
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

		move.l	filelength,d0				;reserve memory
		bsr.w	mxalloc_fast				;
		move.l	d0,flashbuffer				;

		move.w	#0,-(sp)				;open file read only
		move.l	filename,-(sp)				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,filenumber				;store filenumber
 
		move.l	flashbuffer,-(sp)			;buffer address
		move.l	filelength,-(sp)			;length of file
		move.w	filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;

		move.w	filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;

		move.l	#goodpatch,d0				;print flashloaded ok
		bsr.w	cconws					;
		
		move.l	flashbuffer,a0				;search flashrom for Targa file
		move.l	filelength,d6				;maxlength = flashsize - tgasize
		sub.l	#230418,d6				;first long of tga
.loop:		cmp.l	#$00000200,(a0)				;
		bne.s	.no					;
		bsr.w	testall					;first long OK, check do detailed check
		tst.l	d0					;
		beq.s	.found					;correct header found
.no:		addq.l	#1,a0					;
		subq.l	#1,d6					;
		bpl.s	.loop					;
		bra.w	.notfound				;header not found
.found:		


		move.l	filebuffer,a1				;copy new tga file to flashtos
		move.l	#(320*240*3+18)/2-1,d7			;230418 bytes
.copy:								;
		move.w	(a1)+,(a0)+				;
								;
		subq.l	#1,d7					;
		bpl.s	.copy					;


								;save new ct60tos.bin
		move.w	#0,-(sp)				;fcreate()
		move.l	#outputname,-(sp)			;
		move.w	#$3c,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,filenumber

		move.l	flashbuffer,-(sp)			;fwrite()
		move.l	filelength,-(sp)			;
		move.w	filenumber,-(sp)			;
		move.w	#$40,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;

		move.w	filenumber,-(sp)			;fclose()
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;

		bra.w	patchdone
		

.notfound:	move.l	#notgainflash,d0			;error message if no Targa found in flashfile
		bsr.w	cconws					;
		bra.w	exit					;


testall:	lea.l	tgahead,a1				;check flashfile for 18byte Targe header
		move.l	a0,a2					;
		move.w	#9-1,d7					;
.loop:		move.w	(a1)+,d0				;
		cmp.w	(a2)+,d0				;
		bne.s	.no					;
		dbra	d7,.loop				;
.yes:		clr.l	d0					;
		rts						;
.no:		move.l	#-1,d0					;
		rts						;


patchdone:
		
		section	text
