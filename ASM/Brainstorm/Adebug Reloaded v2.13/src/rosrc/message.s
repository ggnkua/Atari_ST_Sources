	include	rostruct.s
	output	.ro
	text
user:	bra.s	.main
	dc.l	'PHYS'
	dc.l	'ENDM'
.main:	lea	adebug_screen_message(pc),a2
	move.l	a2,RO.string(a0)
	lea	user_screen_message(pc),a0
	bsr.s	writeln
	bsr.s	get_char
	rts
writeln:
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	rts
get_char:
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	rts
	data
adebug_screen_message:	ASCIIZ	"This is in Adebug message"
user_screen_message:	dc.b	"This is user screen message",13,10,0
	end
