; take 96 col apx (first 96 col of 256 used)
; move colours 96 positions up and resave file
; then fill lower 96 colours black and upper
; 64 colours white, and last moves pixels in the image
; up 96 steps

		opt	p=68030/68882

maketunnel:

		lea.l	buffer+20,a0
		lea.l	buffer+20+288,a1
		move.w	#288/4-1,d7
.palmove:	move.l	(a0)+,(a1)+
		dbra	d7,.palmove


		lea.l	buffer+20,a0
		move.w	#288/4-1,d7
.black:		clr.l	(a0)+
		dbra	d7,.black

		lea.l	buffer+20+576,a0
		move.w	#192/4-1,d7
.white:		move.l	#$ffffffff,(a0)+
		dbra	d7,.white


		lea.l	buffer+788,a0
		clr.l	d0
		move.w	#200-1,d7
.y:		move.w	#4096-1,d6
.x:
		move.b	(a0),d0
		add.b	#96,d0
		move.b	d0,(a0)+

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

snap_filesize:	dc.l	788+4096*200

snap_filename:	dc.b	'output.apx',0
		even

buffer:		incbin	'foo.apx'
		even


		bss

snap_filenum:	ds.w	1

		even
		section	text
