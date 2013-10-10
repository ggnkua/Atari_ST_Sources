*** program to SUB 32 from ASCII to absolute data (prevents text changing)
***
***
	bra	skip
filename:	dc.b	"text.dat",0	;destination name
	even
ascii:	incbin	"text"	;source asciiture
endascii
	even

skip
	lea	ascii,a0
	lea	buffer,a1
loop	move.b	(a0)+,d0
	cmp.b	#31,d0
	blt.s	loop
	sub.b	#32,d0
	move.b	d0,(a1)+
	cmp.l	#endascii,a0
	blt.s	loop

	move.l	a1,a6
;now save
	bsr	f_create
	bsr	f_write
	bsr	f_close

wait:	bsr	get_key

	CMP.B	#27,D0		;Wait for ESC.
	bne	wait

	MOVE.W	#$0,-(SP)	; RETURN TO GEM DESKTOP.
	TRAP	#1

***********************
* SUBROUTINES SECTION *
***********************

f_create:
	move.w	#0,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp
	move.w	d0,handle
	rts

f_write:
	lea	buffer,a0
	move.l	a0,-(sp)
	sub.l	a0,a6
	move.l	a6,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts

f_close:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

****************
* DATA SECTION *
****************
handle:		dc.w	0
	even
buffer:	ds.l	1
