	move.w	#0,d6		;track number
	lea	buffer,a6
read
	move.w	#10,-(sp)	;no. sectors to read
	move.w	#0,-(sp)	;side 0
	move.w	d6,-(sp)	;track to seek to
	move.w	#1,-(sp)	;sector to start reading
	move.w	#0,-(sp)	;device
	clr.l	-(sp)		;not used
	move.l	a6,-(sp)
	move.w	#8,-(sp)
	trap	#14
	add.l	#20,sp

	add.w	#512*10,a6
	move.w	#10,-(sp)	;no. sectors to read
	move.w	#1,-(sp)	;side 1
	move.w	d6,-(sp)	;track to seek to
	move.w	#1,-(sp)	;sector to start reading
	move.w	#0,-(sp)	;device
	clr.l	-(sp)		;not used
	move.l	a6,-(sp)
	move.w	#8,-(sp)
	trap	#14
	add.l	#20,sp

	add.w	#512*10,a6
	add.w	#1,d6
	cmp.w	#79,d6
	bne.s	read
bp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#1
	even
buffer:	ds.b	512

