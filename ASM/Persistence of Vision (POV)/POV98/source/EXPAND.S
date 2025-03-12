*
* expand.s
*

	opt	o+,w-,p+


	SECTION	TEXT

start
	lea	buffer(pc),a1

	lea	charset(pc),a0
	lea	chars(pc),a2
	moveq	#53,d0
.char
	move.l	a0,a3
	moveq	#0,d1
	move.b	(a2)+,d1
	lsl.w	#3,d1
	add.w	d1,a3
	move.b	#$80,d2
	moveq	#7,d1
.loopx
OFF	set	0
	REPT	8
	moveq	#0,d5
	move.b	OFF(a3),d4
	and.b	d2,d4
	sne	d5
	move.b	d5,(a1)+
OFF	set	OFF+1
	ENDR
	ror.b	#1,d2
	dbf	d1,.loopx
	dbf	d0,.char

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
	pea	(54*8*8)
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
	dc.b	'CHUNKY.FNT',0
	even

chars
	dc.b	" !""'()*+,-./0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	even
charset		incbin	"CHUNKY.SET"


	SECTION	BSS

handle	ds.w	1

buffer	ds.b	(54*8*8)
