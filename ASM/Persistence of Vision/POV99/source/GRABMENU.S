*
* grabmenu.s
*

	opt	o+,w-


	SECTION	TEXT

start
	lea	picture+34(pc),a0
	lea	buffer,a1
	moveq	#64-1,d1
.loop
	moveq	#8-1,d2
.column
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d2,.column
	lea	160-(8*8)(a0),a0
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
	pea	(64*64)
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
	dc.b	'MENU.DAT',0
	even

picture		incbin	"MENU.PI1"


	SECTION	BSS

handle	ds.w	1

buffer	ds.b	(64*64)
