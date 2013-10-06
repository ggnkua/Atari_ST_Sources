


; make tpi-header
; (w) 28/09/96 by tarzan boy


		pea	0
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,ussp

		bsr	original_tpi_laden
		bsr	tpi_header_speichern

		move.l	ussp,-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		
		clr.w	-(sp)
		trap	#1


;---------------

original_tpi_laden

		clr.w	-(sp)
		pea	orig_tpi_file
		move.w	#61,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7
		
		pea	header
		move.l	#128,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		
		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp

		rts

;---------------

tpi_header_speichern

		clr.w	-(sp)
		pea	header_file
		move.w	#60,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7

		pea	header
		move.l	#128,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp

		rts


;**************************************



		data

orig_tpi_file	dc.b	"g:\running\tpi\320x240l.tpi",0
header_file	dc.b	"g:\running\data\misc\tpiheade.dat",0
		even

ussp		dc.l	0


;**************************************


		bss

header		ds.b	128

