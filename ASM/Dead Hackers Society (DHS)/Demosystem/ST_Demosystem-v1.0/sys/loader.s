; Atari ST/e synclock demosystem
; June 6, 2011
;
; sys/loader.s
;
; File loader


; in:   filename.l = address to filename (null term)
;     filebuffer.l = destination address
;     filelength.l = bytes to load

		section	text

loader:
		clr.w	-(sp)					;Open file read only
		move.l	filename,-(sp)				;Address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,.fn					;Store filenumber
 
		move.l	filebuffer,-(sp)			;Buffer address
		move.l	filelength,-(sp)			;Length of file
		move.w	.fn,-(sp)				;Filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;

		move.w	.fn,-(sp)				;Filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;

	ifne	show_infos
		move.l	#text_fn_start,d0
		jsr	print

		move.l	filename,d0
		jsr	print

		move.l	#text_fn_end,d0
		jsr	print
	endc

		rts

.fn:		dc.w	0
filename:	dc.l	0
filebuffer:	dc.l	0
filelength:	dc.l	0

	ifne	show_infos
text_fn_start:	dc.b	"- ",0,0
text_fn_end:	dc.b	" loaded",13,10,0
	endc

		section	text
