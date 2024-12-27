	pea	mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	pea	reading
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

;read in old sector
	move.w	#1,-(sp)	;no. sectors to read
	move.w	#0,-(sp)	;side 0
	move.w	#0,-(sp)	;track to seek to
	move.w	#1,-(sp)	;sector to start reading
	move.w	#0,-(sp)	;device
	clr.l	-(sp)		;not used
	pea	buffer
	move.w	#8,-(sp)
	trap	#14
	add.l	#20,sp

	pea	creating
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

;now create a file
	clr.w	-(sp)	;.prg
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	d0,d7

	pea	writing
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	buffer
	move.l	#512,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	pea	ok
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#1
filename:	dc.b	"boot.img",0,0
	even
buffer:	ds.b	512

mess:	dc.b	27,'E'
	dc.b	"Insert disc to read boot sector from and press a key.",0
reading: dc.b	13,10,10,"Reading boot sector.",0
creating: dc.b	13,10,"Creating file BOOT.IMG",0
writing:  dc.b	13,10,"Writing boot sector to file BOOT.IMG",0
ok:	dc.b	13,10,10,"All done, press a key to exit.",13,10,0