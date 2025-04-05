; Atari ST/e synclock demosystem
; May 10, 2011
;
; sys/dump.s
;
; Dump code-memory area to file


do_code_dump:
		section	text

		clr.w	-(sp)				;fcreate()
		move.l	#fn,-(sp)			;
		move.w	#$3c,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,num

		move.l	#codebuf,-(sp)			;fwrite()
		move.l	#codesize,-(sp)			;
		move.w	num,-(sp)			;
		move.w	#$40,-(sp)			;
		trap	#1				;
		lea.l	12(sp),sp			;

		move.w	num,-(sp)			;fclose()
		move.w	#$3e,-(sp)			;
		trap	#1				;
		addq.l	#4,sp				;

		rts

		section	data

fn:		dc.b	'dump.bin',0
		even

num:		dc.w	0

		section	text
