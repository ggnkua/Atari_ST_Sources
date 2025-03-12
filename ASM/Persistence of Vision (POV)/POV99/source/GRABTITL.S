*
* grabtitl.s
*

	opt	o+,w-


	SECTION	TEXT

start
	lea	picture+34(pc),a0
	lea	buffer,a1
	move.w	#(160*5/4)-1,d1
.loop
	move.l	(a0)+,(a1)+
	dbf	d1,.loop

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
	pea	(160*5)
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
	dc.b	'TITLE.DAT',0
	even

picture		incbin	"TITLE.PI1"


	SECTION	BSS

handle	ds.w	1

buffer	ds.b	(160*5)
