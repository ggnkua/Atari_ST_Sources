; file loader
; input:  a0:   pointer to file path
;         d0.l: NULL = alloc memory
;               NEG  = alloc memory & align
;               else use as filebuffer
;         d1.w: flag fox mxalloc() (0: STRAM, 3: TTRAM)
; output: a0:   pointer to buffer
;         d0.l: length of file

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

load_file:	move.l	a0,filename
		move.l	d0,filealloc
		move.w	d1,alloc_flag

		move.w	#0,-(sp)			; fsfirst() get fileinfo
		move.l	filename,-(sp)			;
		move.w	#$4e,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;

		tst.l	d0				;
		beq.b	.found				;ok
		move.l	#exit_filenotfound_text,error_adr	; error message
		bra.w	exit				;

.found:		move.l	dta+26,filelength		; filelength
		move.l	filealloc,d0
		bgt.b	.load				; use as address
		beq.b	.alloc
		neg.l	d0
		add.l	d0,filelength

.alloc:		move.w	alloc_flag,-(sp)		; mxalloc()
		move.l	filelength,-(sp)		;
		move.w	#$44,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;

		tst.l	d0				; ramcheck
		bne.b	.load				; ok
		move.l	#exit_noram_text,error_adr	; error message
		bra.w	exit				;

.load:		move.l	filealloc,d1
		bge.b	.not_align
		neg.l	d1
		add.l	d1,d0
		neg.l	d1
		and.l	d1,d0
.not_align:	move.l	d0,filebuffer

		move.w	#0,-(sp)			; open file read only
		move.l	filename,-(sp)			; address to filename
		move.w	#$3d,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,filenumber			; store filenumber
 
		move.l	filebuffer,-(sp)		; buffer address
		move.l	filelength,-(sp)		; length of file
		move.w	filenumber,-(sp)		; filenumber
		move.w	#$3f,-(sp)			;
		trap	#1				;
		lea.l	12(sp),sp			;

		move.w	filenumber,-(sp)		; filenumber for closing
		move.w	#$3e,-(sp)			;
		trap	#1				;
		addq.l	#4,sp				;

		clr.l	filename
		movea.l	filebuffer,a0
		move.l	filelength,d0
		rts


; --------------------------------------------------------------
		SECTION	BSS
; --------------------------------------------------------------

alloc_flag:	ds.w	1
filenumber:	ds.w	1
filename:	ds.l	1
filelength:	ds.l	1
filebuffer:	ds.l	1
filealloc:	ds.l	1

; --------------------------------------------------------------
		SECTION	TEXT
; --------------------------------------------------------------