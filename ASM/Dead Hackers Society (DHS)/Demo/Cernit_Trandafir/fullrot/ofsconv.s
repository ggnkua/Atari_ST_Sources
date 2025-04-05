; Create ofsmap from 24-bit Targa
;
; Input
; 24bit uncompressed Targa
;
; Output
; byte:byte ofsmap scrambled order to fit movem ofsmap routine

width:		equ	104
height:		equ	68

size:		equ	width*height*2


		comment HEAD=%111
		opt	p=68000

		output	.tos

start:
		lea.l	tga+18,a0
		lea.l	buffer2,a1
		move.w	#height-1,d7
.y:		move.w	#width-1,d6
.x:		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		addq.l	#1,a0
		dbra	d6,.x
		dbra	d7,.y

		lea.l	buffer2,a0
		lea.l	buffer,a1
		lea.l	buffer+52*68*1,a2
		lea.l	buffer+52*68*2,a3
		lea.l	buffer+52*68*3,a4
		move.w	#68-1,d7
.scramble:
		rept	26
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a2)+
		move.w	(a0)+,(a3)+
		move.w	(a0)+,(a4)+
		endr

		dbra	d7,.scramble


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

buffer:		ds.b	size
buffer2:	ds.b	size
		even

tga:		incbin	'ofs_spir.tga'
		even
		
snap_filesize:	dc.l	size

snap_filename:	dc.b	'spiral.ofs',0
		even
 


		section	bss

snap_filenum:	ds.w	1


		section	text
