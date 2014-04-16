; Atari ST/e synclock demosystem
; August 22, 2008
;
; Image converter for 1byte/pixel BMP to 4 bitplane ST data
;
; Input
; * 8bit BMP
;
; Output
; * RAW ST bitplane data


x:		equ	64		;image width, needs to be a multiple of 16
y:		equ	48		;image height

size:		equ	x*y/2


		comment HEAD=%111

		opt	p=68030/68882

		output	.tos

start:
		lea.l	bmp+54+1024,a0
		lea.l	buffer,a1
		
		move.w	#y-1,d7
.y:		move.w	#x/16-1,d6
.x:
		moveq.l	#0,d0
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5

		rept	15
		
		move.b	(a0)+,d0

		move.l	d0,d1
		and.l	#%00000001,d1
		or.l	d1,d2

		move.l	d0,d1
		and.l	#%00000010,d1
		lsr.l	#1,d1
		or.l	d1,d3

		move.l	d0,d1
		and.l	#%00000100,d1
		lsr.l	#2,d1
		or.l	d1,d4

		move.l	d0,d1
		and.l	#%00001000,d1
		lsr.l	#3,d1
		or.l	d1,d5
		
		lsl.l	#1,d2
		lsl.l	#1,d3
		lsl.l	#1,d4
		lsl.l	#1,d5

		endr

		move.b	(a0)+,d0

		move.l	d0,d1
		and.l	#%00000001,d1
		or.l	d1,d2

		move.l	d0,d1
		and.l	#%00000010,d1
		lsr.l	#1,d1
		or.l	d1,d3

		move.l	d0,d1
		and.l	#%00000100,d1
		lsr.l	#2,d1
		or.l	d1,d4

		move.l	d0,d1
		and.l	#%00001000,d1
		lsr.l	#3,d1
		or.l	d1,d5


		move.w	d2,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d5,(a1)+

		dbra	d6,.x
		dbra	d7,.y




		; fcreate()
		move.w	#0,-(sp)			;Normal file
		move.l	#snap_filename,-(sp)		;Filename address
		move.w	#$3c,-(sp)			;Gemdos #$3c (fcreate)
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,snap_filenum

		; fwrite()
		move.l	#buffer,-(sp)
		move.l	snap_filesize,-(sp)
		move.w	snap_filenum,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea.l	12(sp),sp

		; fclose()
		move.w	snap_filenum,-(sp)		;close
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

		clr.w	-(sp)
		trap	#1


		section	data


bmp:		incbin	'sp48_4pl.bmp'
		even

		
snap_filesize:	dc.l	size

snap_filename:	dc.b	'spr48.4pl',0
		even
 


		section	bss

buffer:		ds.b	size

snap_filenum:	ds.w	1

		even


		section	text
