*
* grabball.s
*

	opt	o+,w-


	SECTION	TEXT

start
	lea	buffer,a1

	lea	picture+34(pc),a0
OFF	set	0
	REPT	16
	move.l	OFF+(160*16)(a0),d1
	not.l	d1
	move.l	d1,(a1)+
	move.l	OFF(a0),(a1)+
	move.l	OFF+8+(160*16)(a0),d1
	not.l	d1
	move.l	d1,(a1)+
	move.l	OFF+8(a0),(a1)+
OFF	set	OFF+160
	ENDR

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
	lea	handle(pc),a0
	move.w	d0,(a0)
	rts

write_file
	pea	buffer(pc)
	pea	(16*8*16*2)
	move.w	handle(pc),-(sp)
	move.w	#64,-(sp)
	trap	#1
	add.w	#12,sp
	rts

close_file
	move.w	handle(pc),-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.w	#4,sp
	rts


	SECTION	DATA

filename
	dc.b	'BALL.DAT',0
	even

picture		incbin	"BALL.PI1"


	SECTION	BSS

handle	ds.w	1

buffer	ds.b	(16*8*16*2)
