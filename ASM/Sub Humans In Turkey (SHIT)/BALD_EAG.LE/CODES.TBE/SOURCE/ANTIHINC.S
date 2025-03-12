; THE NEW ORDER HORIZONTAL ANTI SCROLLER
; THIS IS TO BE USED UPON EXIT TO SCROLL ALL 4 COLOUR PLANES
; OF THE SROLLY MESSAGE BACKWARDS OFF THE SCREEN
; THIS WILL ONLY SCROL WHAT IS CURRENTLY ON SCREEN

antihscr
	move.w	#320,pixels
.loop	tst.w	pixels
	beq	exitantih
	bsr	ascroller
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	subq.w	#8,pixels
	bra	.loop
exitantih	rts


antitrans	macro
	; requires paramter telling which set of pixels to move
	movep.l	\1(a1),d1
	movep.l	d1,\1+1(a1)
	movep.l	\1-7(a1),d1
	movep.l	d1,\1(a1)
	endm

ascroller	move.l	#31,d0
; adjust to pixel lines to scroll (vertical) minus 1
; adjust the font accordingly
	move.l	#scraddr+(201*$a0),a1
	; adjust the one hundred to
	; top pixel line to scroll
.scrollit
	antitrans	152
	antitrans	144
	antitrans	136
	antitrans	128
	antitrans	120
	antitrans	112
	antitrans	104
	antitrans	96
	antitrans	88
	antitrans	80
	antitrans	72
	antitrans	64
	antitrans	56
	antitrans	48
	antitrans	40
	antitrans	32
	antitrans	24
	antitrans	16
	antitrans	8

	movep.l	(a1),d1
	movep.l	d1,1(a1)

	move.b	#0,(a1)
	move.b	#0,2(a1)
	move.b	#0,4(a1)
	move.b	#0,6(a1)

	add.l	#$a0,a1
	dbra	d0,.scrollit

exitit	rts
