	OPT O+,OW-

*	*	*	*	*	*	*	*	*	*

test	;lea	 endprg,a0		 ; calculate screen base
	;add.l	 #48000,a0
	;move.l  a0,d7
	;move.b  #0,d7
	;move.l  d7,a0
	;bsr	 crescr

	pea	enable
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	bsr	try

	pea	disable
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

*

try	move.w	#40000,d0
trylp	move.l	#4589723,d1
	move.w	#567,d2
	divs	d2,d1
	move.l	#4589723,d1
	move.w	#567,d2
	divs	d2,d1
	move.l	#4589723,d1
	move.w	#567,d2
	divs	d2,d1
	move.l	#4589723,d1
	move.w	#567,d2
	divs	d2,d1

	dbra	d0,trylp
	rts

*	*	*	*	*	*	*	*	*	*

enable	;lsr.l	 #8,d7			 ; shift screen
	;move.w  #$8201,a0
	;movep.w d7,0(a0)

	bclr	#5,$fffffa09		; disable timer C
	pea	kbdoff			; disable keyboard send
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp

	move.w	#37,-(sp)		; wait for vertical blank
	trap	#14
	addq.l	#2,sp

	pea	hblint			; send HBL through MFP
	move.w	#1,-(sp)
	move.w	#8,-(sp)
	move.w	#1,-(sp)
	move.w	#31,-(sp)
	trap	#14
	add.l	#12,sp

	lea	store,a0		; define vbl interrupt
	move.l	$70,(a0)
	lea	vblint,a0
	move.l	a0,$70
     move.b    #0,$ffff8260
	rts

*	*	*	*	*	*	*	*	*	*

disable move.b	$44f,$ffff8201		; restore screen
	move.b	$450,$ffff8203
     move.b    #1,$ffff8260
     move.w    #$777,$ffff8240
	lea	store,a0
	move.l	(a0),$70		; restore vbl interrupt
	bclr	#0,$fffffa07		; disable hbl

	bset	#5,$fffffa09		; enable timer C
	pea	kbdon			; enable keyboard send
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

kbdoff	dc.b	$13
kbdon	dc.b	$11

*	*	*	*	*	*	*	*	*	*

vblint	addq.l	#1,$466 		; increment frame clock
	bset	#0,$fffffa07		; enable hbl int
	rte

*	*	*	*	*	*	*	*	*	*

hblint	movem.l d0-d7/a0-a6,-(sp)

	move.w	#$8209,a0
	move.w	#72,d0
hbldel1 cmp.b	(a0),d0 		; wait for exact address
	bgt	hbldel1 		; until pointer higher than offset
	sub.b	(a0),d0 		; exact syncronization
	add.w	#16,d0			; 2 bytes = 4cc
	lsr.w	d0,d0

	moveq	#32,d0			; conventional delay until
hbldel2 dbra	d0,hbldel2		; edge of screen

	move.w	#$820a,a0
	moveq	#0,d1
	moveq	#2,d2
	moveq	#100,d7 		; screen line count

	nop
	nop

linelp	move.b	d1,(a0)
	move.b	d2,(a0)
	nop
	nop
	moveq	#38,d0
linedel dbra	d0,linedel
	dbra	d7,linelp

hblok	movem.l (sp)+,d0-d7/a0-a6
	bclr	#0,$fffffa07		; disable int
	bclr	#0,$fffffa0f		; signal end of interrupt
	rte

*	*	*	*	*	*	*	*	*	*

store	dc.l	0
endprg	dc.l	0

*	*	*	*	*	*	*	*	*	*


