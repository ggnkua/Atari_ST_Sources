; Atari ST/e synclock demosystem
; August 22, 2008
;
; Image converter for 320x273 Spectrum 4096 screenmode
;
; Input
; * Two Spectrum 4096 (SPU) files, the first file having 199 effective lines (top line empty out of 200)
;   and the second having 73 effective lines (top line empty)
;
; Output
; * 320x273 4 bitplane rawdata
; * 273*3 palettes


size:		equ	(320*273/2)+(273*32*3)

		comment HEAD=%111

		opt	p=68030/68882

		output	.tos

start:

		lea.l	orggfx1+160,a0
		lea.l	buffer,a1
		move.w	#320*199/2/4-1,d7
.cpy1:		move.l	(a0)+,(a1)+
		dbra	d7,.cpy1
		
		lea.l	orggfx2+160,a0
		move.w	#320*74/2/4-1,d7
.cpy2:		move.l	(a0)+,(a1)+
		dbra	d7,.cpy2

		lea.l	orggfx1+32000,a0
		move.w	#199*32*3/4-1,d7
.cpy3:		move.l	(a0)+,(a1)+
		dbra	d7,.cpy3
		
		lea.l	orggfx2+32000,a0
		move.w	#74*32*3/4-1,d7
.cpy4:		move.l	(a0)+,(a1)+
		dbra	d7,.cpy4



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


orggfx1:	incbin	'1up.spu'
orggfx2:	incbin	'1down.spu'
		even

		
snap_filesize:	dc.l	size

snap_filename:	dc.b	'pic1.4k',0
		even
 


		section	bss

snap_filenum:	ds.w	1

		even
buffer:		ds.b	size


		section	text
