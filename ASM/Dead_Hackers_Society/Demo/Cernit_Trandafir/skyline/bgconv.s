
; convert 8bit bmp to 1 bit rawdump


x:		equ	416
y:		equ	32

size:		equ	x*y/8

		opt	p=68030/68882

		output	.tos

start:
		lea.l	data+54+1024,a0
		lea.l	buffer,a1
		lea.l	masktab,a2

		

		move.w	#y-1,d7
.y:		move.w	#x/8-1,d6
.x:
		moveq.l	#7,d2
		moveq.l	#0,d1
		
		rept	8
		moveq.l	#0,d0
		move.b	(a0)+,d0
		move.b	(a2,d0.w),d0
		lsl.b	d2,d0
		or.b	d0,d1
		subq.b	#1,d2
		endr
		
		move.b	d1,(a1)+

		dbra	d6,.x
		dbra	d7,.y



		; fcreate()
		move.w	#0,-(sp)			;Normal file
		move.l	#snap_filename,-(sp)			;Filename address
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


data:		incbin	'bgpic.bmp'
		even

		
snap_filesize:	dc.l	size

snap_filename:	dc.b	'bgpic.1pl',0
		even

masktab:	dc.b	0
		dcb.b	255,1

		bss

snap_filenum:	ds.w	1

		even

buffer:		ds.b	size

		section	text
