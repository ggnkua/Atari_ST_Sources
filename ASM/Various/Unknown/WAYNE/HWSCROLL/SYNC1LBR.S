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

try:	add.l	#1600,scraddr
	moveq	#19,d0
.loop1	move.l	#200000,d1
.loop2	subq.l	#1,d1
	bne	.loop2
	addq.l	#8,scraddr
	dbra	d0,.loop1
	rts

*	*	*	*	*	*	*	*	*	*

enable	move.b	$ffff8201,scrhigh	; store low byte of address
	move.b	$ffff8203,scrmid
 add.b #8,$ffff8203

	bclr	#5,$fffffa09		; disable timer C
	move.b	#$13,$fffffc02		; disable keyboard send

	move.w	#62,syncval		; set up synchronisation values

	move.w	#37,-(sp)		; wait for vertical blank
	trap	#14
	addq.l	#2,sp

	pea	hblsync			; send HBL through MFP
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
	rts

*	*	*	*	*	*	*	*	*	*

disable move.w	#$777,$ffff8240

	move.b	scrhigh,$ffff8201	; restore screen
	move.b	scrmid,$ffff8203

	lea	store,a0
	move.l	(a0),$70		; restore vbl interrupt
	bclr	#0,$fffffa07		; disable hbl

	bset	#5,$fffffa09		; enable timer C
	move.b	#$11,$fffffc02		; enable keyboard
	rts

*	*	*	*	*	*	*	*	*	*

vblint	addq.l	#1,$466 		; increment frame clock

	move.w	#$555,$ffff8240.w	; set border colour

	bset	#0,$fffffa07		; enable timer B int
	rte

*	*	*	*	*	*	*	*	*	*

hblsync	movem.l d0-d7/a0-a6,-(sp)	; synchronize the hardware scroll

;	move.b	$ffff8203.w,d0
;	addq.b	#1,d0
;.sync0	cmp.b	$ffff8207.w,d0		; wait for screen + 256
;	bne	.sync0

	move.w	#$8209,a0
	moveq	#72,d0
.sync1	cmp.b	(a0),d0 		; wait for exact address
	bgt	.sync1	 		; until pointer higher than offset
	sub.b	(a0),d0 		; exact syncronization
	add.w	#16,d0			; 2 bytes = 4cc
	lsr.w	d0,d0

	move.w	#$820a,a0
	move.w	#$8260,a1
	lea	scrltab,a2
	moveq	#0,d1
	moveq	#2,d2

*

	moveq	#16,d0
.delay	dbra	d0,.delay

	move.w	syncval,d0
	ror.l	d0,d0
	moveq	#13,d7

.bloop	movem.w	(a2)+,d4-d6
	REPT	4
	nop
	ENDR
	move.b	d4,(a1)			; left extend
	move.b	d1,(a1)
	REPT	89
	nop
	ENDR
	move.b	d5,(a0)			; right extend
	move.b	d2,(a0)
	REPT	13
	nop
	ENDR
	move.b	d6,(a1)			; left restore
	nop
	move.b	d1,(a1)
	dbra	d7,.bloop

*

.endlp	move.b	$ffff8209.w,d0		; wait till end of line
	cmp.b	$ffff8209.w,d0
	bne	.endlp

.sync	cmp.b	#208,d0			; check for overscan
	beq	.dnsync
	subq.w	#2,syncval
	bra	.done

.dnsync	move.l	#hblint,$120.w		; overscan found

*

.done	movem.l (sp)+,d0-d7/a0-a6
	bclr	#0,$fffffa07		; disable int
	bclr	#0,$fffffa0f		; signal end of interrupt
	rte

*	*	*	*	*	*	*	*	*	*

hblint	movem.l d0-d7/a0-a6,-(sp)	; synchronize the hardware scroll

;	move.b	$ffff8203.w,d0
;	addq.b	#1,d0
;.sync0	cmp.b	$ffff8207.w,d0		; wait for screen + 256
;	bne	.sync0

	move.w	#$8209,a0
	moveq	#72,d0
.sync1	cmp.b	(a0),d0 		; wait for exact address
	bgt	.sync1	 		; until pointer higher than offset
	sub.b	(a0),d0 		; exact syncronization
	add.w	#16,d0			; 2 bytes = 4cc
	lsr.w	d0,d0

	move.w	#$820a,a0
	move.w	#$8260,a1
	lea	scrltab,a2
	moveq	#0,d1
	moveq	#2,d2

*

	moveq	#16,d0
.delay	dbra	d0,.delay

	move.w	syncval,d0
	ror.l	d0,d0
	moveq	#13,d7

.bloop	movem.w	(a2)+,d4-d6
	REPT	4
	nop
	ENDR
	move.b	d4,(a1)			; left extend
	move.b	d1,(a1)
	REPT	89
	nop
	ENDR
	move.b	d5,(a0)			; right extend
	move.b	d2,(a0)
	REPT	13
	nop
	ENDR
	move.b	d6,(a1)			; left restore
	nop
	move.b	d1,(a1)
	dbra	d7,.bloop

*

	lea	hwstab,a0		; now work out the data for
	move.w	#$8201,a1		; the next extend
	move.b	scrlow,d0
	and.w	#$f8,d0
	add.w	d0,a0			; index into table of offsets (x8)

	move.l	scraddr,d0
	lsr.l	#8,d0
	add.w	(a0)+,d0
	movep.w	d0,0(a1)		; offset screen address

	movem.w	(a0)+,d0-d2		; lines of left, both, right
	move.w	#14,d3			; and left over
	sub.w	d0,d3
	sub.w	d1,d3
	sub.w	d2,d3
	lea	scrltab,a1		; fill in table

	bra	.llpin
.llp	move.w	#2,(a1)+		; left extend
	move.w	#2,(a1)+
	clr.w	(a1)+
.llpin	dbra	d0,.llp

	bra	.blpin
.blp	move.w	#2,(a1)+		; both extend
	clr.w	(a1)+
	move.w	#2,(a1)+
.blpin	dbra	d1,.blp

	bra	.rlpin
.rlp	clr.w	(a1)+			; right extend
	clr.w	(a1)+
	clr.w	(a1)+
.rlpin	dbra	d2,.rlp

	bra	.nlpin
.nlp	clr.w	(a1)+			; no extend
	move.w	#2,(a1)+
	clr.w	(a1)+
.nlpin	dbra	d3,.nlp

*

 move.w #$777,$ffff8240.w

	movem.l (sp)+,d0-d7/a0-a6
	bclr	#0,$fffffa07		; disable int
	bclr	#0,$fffffa0f		; signal end of interrupt
	rte

*	*	*	*	*	*	*	*	*	*

; Table of values for left, mid, right screen extend

scrltab:
	dc.w	2,2,0,	2,2,0,	2,2,0,	2,2,0
	dc.w	2,0,2,	2,0,2,	2,0,2,	2,0,2
	dc.w	0,0,0,	0,0,0,	0,0,0,	0,0,0
	dc.w	0,2,0,	0,2,0,	0,2,0,	0,2,0


; 32 offset values for hardware scrolling table.
; Addr, Left, Both, Right

hwstab:
 dc.w  3, 0, 0, 0
 dc.w  2, 0, 0, 6
 dc.w  2, 2, 0, 5
 dc.w  2, 4, 0, 4
 dc.w  2, 6, 0, 3
 dc.w  2, 8, 0, 2
 dc.w  2, 10, 0, 1
 dc.w  2, 12, 0, 0
 dc.w  1, 8, 4, 2
 dc.w  1, 9, 5, 0
 dc.w  0, 3, 11, 0
 dc.w  3, 0, 0, 2
 dc.w  3, 2, 0, 1
 dc.w  3, 4, 0, 0
 dc.w  2, 4, 0, 6
 dc.w  2, 6, 0, 5
 dc.w  2, 8, 0, 4
 dc.w  2, 10, 0, 3
 dc.w  2, 12, 0, 2
 dc.w  2, 13, 1, 0
 dc.w  1, 7, 7, 0
 dc.w  0, 1, 13, 0
 dc.w  3, 0, 0, 4
 dc.w  3, 2, 0, 3
 dc.w  3, 4, 0, 2
 dc.w  3, 6, 0, 1
 dc.w  3, 8, 0, 0
 dc.w  2, 8, 0, 6
 dc.w  2, 9, 1, 4
 dc.w  2, 10, 2, 2
 dc.w  2, 11, 3, 0
 dc.w  1, 5, 9, 0



syncval	dc.w	62

scraddr	dc.b	0			; screen address (4 bytes)
scrhigh	dc.b	0
scrmid	dc.b	0
scrlow	dc.b	0

store	ds.l	4

