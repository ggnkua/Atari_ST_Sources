; ENCRYPTER for coding messages so no text changes can have a play.
	bra	skip
filename:	dc.b	"mess.dat",0	;destination name
	even

key	equ	'M'
skip
	lea	mess,a0
loop	move.b	(a0),d0
	eor.b	#key,d0
	move.b	d0,(a0)+
	cmp.l	#messend,a0
	blt.s	loop

;now save
	bsr	f_create
	bsr	f_write
	bsr	f_close

wait	clr.w	-(sp)	; RETURN TO GEM DESKTOP.
	trap	#1


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
	move.l	#mess,-(sp)
	move.l	#messend-mess,-(sp)
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

****************
	SECTION DATA
****************
mess:		
	dc.b	27,'E'
	dc.b	"               BaPAUG DEMO",13,10
	dc.b	"               -----------",13,10,10,10,10
	dc.b	"               Packed by",13,10,10
	dc.b	"              MAC SYS DATA",13,10,10
	dc.b	"                  of",13,10,10
	dc.b	"         PERSISTENCE OF VISION",13,10,10,10,10
	dc.b	"                23/3/90",13,10,0

messend:

	even

	SECTION BSS
stack_save	ds.l	1
handle		ds.w	1
