; Atari ST/e synclock demosystem
;
; Image converter for 1byte/pixel BMP to 4 bitplane ST data
;
; Input
; * 8bit BMP
;
; Output
; * STe palette + RAW ST bitplane data


x:		equ	416		;image width, needs to be a multiple of 16
y:		equ	265		;image height

size:		equ	x*y/2+32

		output	.tos

start:
		lea	bmp+54,a0		;Convert palette
		lea	buffer,a1
		lea	stepal,a2
		move.w	#16-1,d7
.pal:		moveq.l	#0,d0
		move.b	0(a0),d0
		lsr.b	#4,d0
		move.b	(a2,d0.w),d0

		moveq.l	#0,d1
		move.b	1(a0),d1
		lsr.b	#4,d1
		move.b	(a2,d1.w),d1

		moveq.l	#0,d2
		move.b	2(a0),d2
		lsr.b	#4,d2
		move.b	(a2,d2.w),d2

		addq.l	#4,a0
		
		lsl.w	#4,d1
		or.w	d1,d0
		lsl.w	#8,d2
		or.w	d2,d0
		move.w	d0,(a1)+

		dbra	d7,.pal



		lea	bmp+54+1024,a0
		add.l	#x*(y-1),a0		;Read BMP upside down..
		lea	buffer+32,a1
		
		move.w	#y-1,d7
.y:		move.w	#x/16-1,d6
.x:
		moveq	#0,d0
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5

	rept	16

		lsl.l	#1,d2
		lsl.l	#1,d3
		lsl.l	#1,d4
		lsl.l	#1,d5
		
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
		
	endr

		move.w	d2,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d5,(a1)+

		dbra	d6,.x
		sub.l	#x*2,a0
		dbra	d7,.y




		; fcreate()
		clr.w	-(sp)
		pea	filename
		move.w	#$3c,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,.fn

		; fwrite()
		pea	buffer
		move.l	filesize,-(sp)
		move.w	.fn,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea	12(sp),sp

		; fclose()
		move.w	.fn,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

		clr.w	-(sp)
		trap	#1

.fn:		dc.w	0

		section	data

filesize:	dc.l	size

stepal:		dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f

filename:	dc.b	'pic.4pl',0
		even

bmp:		incbin	'pic.bmp'
		even

		section	bss

buffer:		ds.b	size
		even


		section	text
