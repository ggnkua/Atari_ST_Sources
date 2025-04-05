; Converts BMP texture to 4bit nibble rawdata
;
; Input
; * 8bit BMP
;
; Output
; * nibble rawdata


x:		equ	256
y:		equ	256

size:		equ	x*y/2


		comment HEAD=%111

		output	.tos

start:
		lea.l	bmp+54+1024,a0
		lea.l	buffer,a1
		
		move.w	#y-1,d7
.y:		move.w	#x/2-1,d6
.x:
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		lsl.b	#4,d0
		lsl.b	#4,d1
		lsr.b	#4,d1
		or.b	d1,d0
		move.b	d0,(a1)+

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


bmp:		incbin	'texture.bmp'
		even

		
snap_filesize:	dc.l	size

snap_filename:	dc.b	'texture.nib',0
		even
 


		section	bss

buffer:		ds.b	size

snap_filenum:	ds.w	1

		even


		section	text
