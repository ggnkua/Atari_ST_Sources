*
* sprtdata.s
*

	opt	o+,w-,p+


	SECTION	TEXT

start
	lea	buffer(pc),a1

	lea	picture(pc),a0
	add.w	#34,a0
	bsr	store

	bsr	create_file
	bsr	write_file
	bsr	close_file

	clr.w	-(sp)		; Exit.
	trap	#1


store
	moveq	#7,d0
.loop1	move.l	a0,a2
	moveq	#(12*8)-1,d1
.loop2
	movep.l	(a2),d2
	move.l	d2,(a1)+
	movep.l	1(a2),d2
	move.l	d2,(a1)+
	lsr.w	(a2)
	lsr.w	2(a2)
	lsr.w	4(a2)
	lsr.w	6(a2)
	lea	160(a2),a2
	dbf	d1,.loop2
	dbf	d0,.loop1
	rts


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
	pea	(12*8*8*8)
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
	dc.b	'SPRITES.DAT',0
	even

picture
	incbin	"SPRITES.PI1"


	SECTION	BSS

handle	ds.w	1

buffer	ds.b	(12*8*8*8)
