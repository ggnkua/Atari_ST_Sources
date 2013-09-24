
; convert 320x200 4pl pi1 to 320x60 2pl rawdump


x:		equ	320
y:		equ	60

size:		equ	x*y/4

		opt	p=68030/68882

		output	.tos

start:
		lea.l	data+34,a0
		lea.l	buffer,a1
		move.w	#x/16*y-1,d7
.copy:		move.l	(a0)+,(a1)+
		addq.l	#4,a0
		dbra	d7,.copy


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


data:		incbin	'text.pi1'
		even

		
snap_filesize:	dc.l	size

snap_filename:	dc.b	'text.2pl',0
		even

masktab:	dc.b	0
		dcb.b	255,1

		bss

snap_filenum:	ds.w	1

		even

buffer:		ds.b	size

		section	text
