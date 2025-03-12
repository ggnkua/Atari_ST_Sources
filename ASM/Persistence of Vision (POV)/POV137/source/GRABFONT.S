	opt	o+,w-


	SECTION	TEXT

start
	lea	picture+34,a0
	lea	buffer,a1
	moveq	#2,d0
.loopy
	moveq	#19,d1
.loopx
OFF	set	6
	REPT	16
	move.w	OFF(a0),(a1)+
OFF	set	OFF+160
	ENDR
	addq.w	#8,a0
	dbf	d1,.loopx
	add.w	#(160*15),a0
	dbf	d0,.loopy

	bsr	create_file
	bsr	write_file
	bsr	close_file

	clr.w	-(sp)		; Exit.
	trap	#1


create_file
	clr.w	-(sp)
	pea	filename(pc)
	move.w	#60,-(sp)
	trap	#1
	addq.w	#8,sp
	move.w	d0,handle
	rts

write_file
	pea	buffer
	pea	(16*2*51)
	move.w	handle,-(sp)
	move.w	#64,-(sp)
	trap	#1
	add.w	#12,sp
	rts

close_file
	move.w	handle,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.w	#4,sp
	rts


	SECTION	DATA

filename
	dc.b	'ROUNDED.FNT',0
	even

picture		incbin	"ROUNDED.PI1"


	SECTION	BSS

handle	ds.w	1

buffer	ds.b	(16*2*20*3)
