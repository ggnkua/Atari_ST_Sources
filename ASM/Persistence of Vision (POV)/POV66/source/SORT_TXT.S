; FIX ASCII file for absolute text and remove all CR/LF
; Outfile is ASCII-32
;

	bsr	set_super
	move.w	$ffff8240.w,d7
	moveq.l	#0,d0
	lea	scroll_text,a0
	lea	buffer,a1
loop	move.b	(a0)+,d0
	bmi	last_byte
	move.b	d0,$ffff8240.w

	cmp.b	#127,d0
	bgt.s	loop	;no character greater than ~

	cmp.b	#31,d0
	ble.s	loop	;no character less than SPACE
	sub.b	#32,d0
	move.b	d0,(a1)+
	bra.s	loop

last_byte
	move.l	a1,a5	
	move.w	d7,$ffff8240.w
;now save
	bsr	f_create
	move.l	a5,a1
	bsr	f_write
	bsr	f_close

	bsr	set_user

	MOVE.W	#$0,-(SP)	; RETURN TO GEM DESKTOP.
	TRAP	#1
	RTS

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
	sub.l	a0,a1
	move.l	#buffer,-(sp)
	move.l	a1,-(sp)
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

pause:	move.w	d0,-(sp)
	move.w	#100,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

set_super:
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts
set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	rts

****************
* DATA SECTION *
****************
stack_save:	dc.l	0
handle:		dc.w	0
	even
filename
	dc.b	"scroll.txt",0	;destination name
	even
scroll_text	incbin	"ascii.txt"	;source text
	dc.b	$ff	;terminator
	even

buffer:	
	ds.b	10000
