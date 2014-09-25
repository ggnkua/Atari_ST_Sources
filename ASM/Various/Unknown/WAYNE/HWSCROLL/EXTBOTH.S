	OPT O+,OW-

*	*	*	*	*	*	*	*	*	*

print	pea	enable			; set up screen and interrupts
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	bsr	demo

	pea	disable 		; restore screen and interrupts
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)			; end
	trap	#1

*	*	*	*	*	*	*	*	*	*

demo	move.l	#1000000,d0
demolp	subq.l	#1,d0
	bne	demolp
	rts

*	*	*	*	*	*	*	*	*	*

enable	;lsr.l	 #8,d7			 ; shift screen
	;move.w  #$8201,a0
	;movep.w d7,0(a0)

	pea	kbdoff			; disable keyboard send
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp

	bsr	wvbl
	bclr	#5,$fffffa09		; disable timer C
	bclr	#6,$fffffa09		; disable keyboard int

	lea	store,a0		; store old vbl interrupt
	move.l	$70,(a0)+
	move.l	$68,(a0)

	bsr	wvbl			; wait for vbl
	lea	vblint,a0		; set up screen extn interrupt
	move.l	a0,$70
	lea	hblint,a0
	move.l	a0,$68

	pea	timint			; send HBL through MFP
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	move.w	#1,-(sp)
	move.w	#31,-(sp)
	trap	#14
	add.l	#12,sp
	bclr	#0,$fffffa07		; and disable it
	rts

*	*	*	*	*	*	*	*	*	*

wvbl	move.l	$466,d0 		; wait for vertical blank
wvbllp	cmp.l	$466,d0
	beq	wvbl
	rts

*	*	*	*	*	*	*	*	*	*

disable move.b	$44f,$ffff8201		; restore screen
	move.b	$450,$ffff8203

	move.l	store,$70		; restore vbl interrupt
	move.l	store+4,$68
	bclr	#0,$fffffa07		; disable timer

	bset	#5,$fffffa09		; enable timer C
	bset	#6,$fffffa09		; enable keyboard int

	pea	kbdon			; enable keyboard send
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

kbdoff	dc.b	$13
kbdon	dc.b	$11

*	*	*	*	*	*	*	*	*	*

vblint	addq.l	#1,$466 		; vbl clock

	movem.l d0-d1/a0,-(sp)
	move.b	#212,$fffffa21
	bset	#0,$fffffa07		; enable timer B
	move.b	#8,$fffffa1b		; turn on timer

	move.w	#$21,$418

vbldone movem.l (sp)+,d0-d1/a0
	and.w	#$f1ff,(sp)		; enable hbl
	rte

*	*	*	*	*	*	*	*	*	*

hblint	subq.w	#1,$418 		; wait for start of 60 Hz screen
	beq	tophbl
	rte

*

tophbl	stop	#$2100			; synchronize with hbl
	move.w	#$2700,sr

	movem.l d0,-(sp)
	moveq	#23,d0
del1	dbra	d0,del1
	movem.l (sp)+,d0
	or.w	#$0300,(sp)

	move.b	#0,$ffff820a		; 60 Hz
	move.b	#2,$ffff820a		; 50 Hz

	rte

*	*	*	*	*	*	*	*	*	*

timint	bclr	#0,$fffffa07		; disable int
	clr.b	$fffffa1b		; turn off timer
	movem.l d0/a0,-(sp)
	move.w	#$8209,a0

	move.b	(a0),d0 		; wait until line started
timwait cmp.b	(a0),d0
	beq	timwait
timsync move.b	(a0),d0
	cmp.b	(a0),d0 		; sync with screen
	bne	timsync

	movem.l (sp)+,d0/a0

	move.b	#0,$ffff820a		; 60 Hz
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	#2,$ffff820a		; 50 Hz

	bclr	#0,$fffffa0f		; signal end of interrupt
	rte

*	*	*	*	*	*	*	*	*	*

store	ds.l	2
scrnbas dc.l	0

*	*	*	*	*	*	*	*	*	*


