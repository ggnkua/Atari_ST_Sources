	OPT O+,OW-

*	*	*	*	*	*	*	*	*	*

test:	lea	data_area+256,a0	; calculate screen base
	move.l	a0,d0
	and.l	#$ffffff00,d0
	move.l	d0,scraddr

	move.l	d0,scrn0
	add.l	#32768,d0
	move.l	d0,scrn1
	add.l	#32768,d0
	move.l	d0,scrn2
	add.l	#32768,d0
	move.l	d0,scrn3

	move.l	scrn0,a0
	move.w	#1000,d0
.loop	move.l	#$ffffffff,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,.loop

	move.l	scrn0,a0
	move.l	scrn1,a1
	bsr	scroll4
	move.l	scrn1,a0
	move.l	scrn2,a1
	bsr	scroll4
	move.l	scrn2,a0
	move.l	scrn3,a1
	bsr	scroll4

	pea	enable			; turn on routine
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	bsr	try

	pea	disable			; turn off routine
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

*

try:	move.w	#39,d0

.loop	move.w	d0,-(sp)
	move.l	scrn0,scraddr
	subq.l	#8,scrn0
	bsr	wvbl
	move.l	scrn1,scraddr
	subq.l	#8,scrn1
	bsr	wvbl
	move.l	scrn2,scraddr
	subq.l	#8,scrn2
	bsr	wvbl
	move.l	scrn3,scraddr
	subq.l	#8,scrn3
	bsr	wvbl
	move.w	(sp)+,d0
	dbra	d0,.loop
	rts

wvbl:	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts

*	*	*	*	*	*	*	*	*	*

scroll4:
	move.w	#200,d0			; copy screen across 4 pixels

.yloop	move.l	a0,a5
	move.l	a1,a6
	moveq	#39,d1
	move.l	#$f000f000,d2
	moveq	#4,d3
	moveq	#0,d4
	moveq	#0,d5
.xloop	move.l	(a5)+,d6		; load source data
	move.l	(a5)+,d7
	ror.l	d3,d6			; shift right
	ror.l	d3,d7
	eor.l	d6,d4			; combine with dest
	eor.l	d7,d5
	and.l	d2,d4			; cancel right (low) bits
	and.l	d2,d5
	eor.l	d6,d4			; combine again
	eor.l	d7,d5
	move.l	d4,(a6)+
	move.l	d5,(a6)+
	swap	d6
	swap	d7
	move.l	d6,d4
	move.l	d7,d5
	dbra	d1,.xloop		; loop for next 32 pixel block

	add.w	#160,a0
	add.w	#160,a1
	dbra	d0,.yloop

	rts

*	*	*	*	*	*	*	*	*	*

enable:
 move.b	#0,$ffff8260
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

	move.b	$ffff8201,store		; store old screen address
	move.b	$ffff8203,store+1
	move.l	$70,store+2		; define vbl interrupt
	move.l	#vblint,$70
	rts

*	*	*	*	*	*	*	*	*	*

disable:
 move.b	#1,$ffff8260
	move.b	store,$ffff8201		; restore screen
	move.b	store+1,$ffff8203
	move.l	store+2,$70		; restore vbl interrupt

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

	move.w	#$555,$ffff8240.w	; set border colour

	bset	#0,$fffffa07		; enable timer B int
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

	move.w	#$820a,a0
	moveq	#0,d1
	moveq	#2,d2
	moveq	#13,d5
	movem.w	lineskp,d6-d7		; d5 = work line count
	sub.w	d6,d5			; d6 = skipped line count
	sub.w	d7,d5			; d7 = extended line count

*

	moveq	#27,d0			; conventional delay until
.wait1	dbra	d0,.wait1		; edge of screen
	nop
	nop
	bra	.llpin

.lloop	move.b	d1,(a0)			; -160 bytes for skipped line
	move.b	d2,(a0)
	nop
	nop
	moveq	#38,d0
.ldel	dbra	d0,.ldel
.llpin	dbra	d6,.lloop

*

	moveq	#22,d0			; now insert a delay
.wait2	dbra	d0,.wait2
	nop
	nop
	bra	.rlpin

.rloop	move.b	d1,(a0)			; +44 bytes for right extend
	move.b	d2,(a0)
	nop
	nop
	moveq	#38,d0
.rdel	dbra	d0,.rdel
.rlpin	dbra	d7,.rloop

*

	bra	.mlpin

.mloop	moveq	#40,d0			; upper edge mask
.mdel	dbra	d0,.mdel
.mlpin	dbra	d5,.mloop

	move.w	#$777,$ffff8240.w	; clear mask

*

	lea	hwstab,a0		; now work out the data for
	move.w	#$8201,a1		; the next extend
	move.b	scrlow,d0
	and.l	#$f8,d0
	add.l	d0,a0			; index into table of offsets

	move.l	scraddr,d0
	lsr.l	#8,d0
	add.w	(a0)+,d0
	movep.w	d0,0(a1)		; offset screen address

	move.w	(a0)+,lineext		; lines to skip
	move.w	(a0)+,lineskp		; lines to extend

*

	movem.l (sp)+,d0-d7/a0-a6
	bclr	#0,$fffffa07		; disable int
	bclr	#0,$fffffa0f		; signal end of interrupt
	rte

*	*	*	*	*	*	*	*	*	*

; 32 offset values for hardware scrolling table.
; 	    Addr, Right, Skip

hwstab:	dc.w	1, 0, 0, 0
	dc.w	0, 6, 0, 0
	dc.w	1, 4, 1, 0
	dc.w	2, 2, 2, 0
	dc.w	3, 0, 3, 0
	dc.w	2, 6, 3, 0
	dc.w	3, 4, 4, 0
	dc.w	4, 2, 5, 0
	dc.w	5, 0, 6, 0
	dc.w	4, 6, 6, 0
	dc.w	5, 4, 7, 0
	dc.w	1, 2, 0, 0
	dc.w	2, 0, 1, 0
	dc.w	1, 6, 1, 0
	dc.w	2, 4, 2, 0
	dc.w	3, 2, 3, 0
	dc.w	4, 0, 4, 0
	dc.w	3, 6, 4, 0
	dc.w	4, 4, 5, 0
	dc.w	5, 2, 6, 0
	dc.w	6, 0, 7, 0
	dc.w	5, 6, 7, 0
	dc.w	1, 4, 0, 0
	dc.w	2, 2, 1, 0
	dc.w	3, 0, 2, 0
	dc.w	2, 6, 2, 0
	dc.w	3, 4, 3, 0
	dc.w	4, 2, 4, 0
	dc.w	5, 0, 5, 0
	dc.w	4, 6, 5, 0
	dc.w	5, 4, 6, 0
	dc.w	6, 2, 7, 0

lineskp	dc.w	0
lineext	dc.w	0

scraddr	dc.b	0			; screen address (4 bytes)
scrhigh	dc.b	0
scrmid	dc.b	0
scrlow	dc.b	0

scrn0:	dc.l	0
scrn1:	dc.l	0
scrn2:	dc.l	0
scrn3:	dc.l	0

store:	ds.l	4

data_area:dc.l	0

*	*	*	*	*	*	*	*	*	*
