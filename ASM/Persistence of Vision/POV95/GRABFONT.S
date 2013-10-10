*
* grabfont.s
*

	opt	o+,w-


MAX_CHARS	equ	49


	SECTION	TEXT

start
	lea	picture+34+(160*2)(pc),a0
	lea	buffer,a1
	moveq	#0,d0
	move.w	#(MAX_CHARS*4)-1,d1
.loop
OFF	set	0
	REPT	30
	movep.l	OFF(a0),d2
	move.l	d2,(a1)+
OFF	set	OFF+160
	ENDR
	addq.w	#1,a0
	move.w	a0,d2
	and.w	#1,d2
	bne.s	.cont
	addq.w	#6,a0
.cont	addq.w	#1,d0
	cmp.w	#40,d0
	blt.s	.skip
	moveq	#0,d0
	add.w	#(160*32),a0
.skip	dbf	d1,.loop

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
	pea	(MAX_CHARS*32*4*4)
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
	dc.b	'LEAN.FNT',0
	even

picture		incbin	"LEAN_FNT.PI1"


	SECTION	BSS

handle	ds.w	1

buffer	ds.b	(MAX_CHARS*32*4*4)
