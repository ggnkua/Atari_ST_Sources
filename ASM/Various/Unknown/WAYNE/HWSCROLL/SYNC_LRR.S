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
.loop1
	move.w #100,d2
.loop2	REPT 1000
	moveq #-1,d1
	mulu d1,d1
	ENDR
	dbf d2,.loop2
	addq.l	#8,scraddr
	dbra	d0,.loop1
	rts

*	*	*	*	*	*	*	*	*	*

enable	move.b	$ffff8201,scrhigh	; store low byte of address
	move.b	$ffff8203,scrmid
 add.b #8,$ffff8203

	bclr	#5,$fffffa09		; disable timer C
	move.b	#$13,$fffffc02		; disable keyboard send

	move.w	#0,linrght		; set up synchronisation values
	move.w	#4,linleft
	move.w	#62,synrght
	move.w	#62,synleft

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
	moveq	#0,d1
	moveq	#2,d2

*

	moveq	#18,d0
.ldelay	dbra	d0,.ldelay

	move.w	linleft,d7		; left count
	move.w	synleft,d0
	ror.l	d0,d0
	bra	.llpin

.lloop	move.b	d2,(a1)			; +26 for left border
	move.b	d1,(a1)
	nop
	nop
	moveq	#38,d0
.ldel	dbra	d0,.ldel
.llpin	dbra	d7,.lloop

*

	move.w	linrght,d7
	move.w	synrght,d0
	ror.l	d0,d0
	bra	.rlpin

.rloop	moveq	#19,d0			; +44 bytes for right extend
.rdel1	dbra	d0,.rdel1
	move.b	d1,(a0)
	move.b	d2,(a0)
	moveq	#18,d0
.rdel2	dbra	d0,.rdel2
.rlpin	dbra	d7,.rloop

*

.endlp	move.b	$ffff8209.w,d0		; wait till end of line
	cmp.b	$ffff8209.w,d0
	bne	.endlp
	tst.w	linleft
	beq	.right

.left	cmp.b	#104,d0			; check for overscan
	beq	.dnleft
	subq.w	#2,synleft
	bra	.done

.dnleft	move.w	#0,linleft		; right extend found
	move.w	#4,linrght
	bra	.done

.right	cmp.b	#176,d0			; check for right extend
	beq	.dnrght
	subq.w	#2,synrght
	bra	.done

.dnrght	move.l	#hblint,$120.w		; overscan found

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
	moveq	#0,d1
	moveq	#2,d2

*

	moveq	#18,d0
.ldelay	dbra	d0,.ldelay

	move.w	linleft,d7		; left count
	move.w	synleft,d0
	ror.l	d0,d0
	bra	.llpin

.lloop	move.b	d2,(a1)			; +26 for left border
	move.b	d1,(a1)
	nop
	nop
	moveq	#38,d0
.ldel	dbra	d0,.ldel
.llpin	dbra	d7,.lloop

*

	move.w	linrght,d7
	move.w	synrght,d0
	ror.l	d0,d0
	bra	.rlpin

.rloop	moveq	#19,d0			; +44 bytes for right extend
.rdel1	dbra	d0,.rdel1
	move.b	d1,(a0)
	move.b	d2,(a0)
	moveq	#18,d0
.rdel2	dbra	d0,.rdel2
.rlpin	dbra	d7,.rloop

*

	moveq	#96,d0			; mask delay
	sub.w	synrght,d0
	sub.w	synleft,d0
	ror.l	d0,d0
	moveq	#22,d7			; mask count
	sub.w	linrght,d7
	sub.w	linleft,d7
	bra	.mlpin

.mloop	moveq	#40,d0			; upper edge mask
.mdel	dbra	d0,.mdel
.mlpin	dbra	d7,.mloop

	rept	20
	nop
	endr
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

	move.w	(a0)+,linleft		; lines to skip
	move.w	(a0)+,linrght		; lines to extend

*

	movem.l (sp)+,d0-d7/a0-a6
	bclr	#0,$fffffa07		; disable int
	bclr	#0,$fffffa0f		; signal end of interrupt
	rte

*	*	*	*	*	*	*	*	*	*

; 32 offset values for hardware scrolling table.
; Addr, Left, Right

hwstab:
 dc.w  2, 0, 0, 0
 dc.w  0, 20, 0, 0
 dc.w  1, 2, 5, 0
 dc.w  1, 4, 4, 0
 dc.w  1, 6, 3, 0
 dc.w  1, 8, 2, 0
 dc.w  1, 10, 1, 0
 dc.w  1, 12, 0, 0
 dc.w  0, 12, 6, 0
 dc.w  0, 14, 5, 0
 dc.w  0, 16, 4, 0
 dc.w  2, 0, 2, 0
 dc.w  2, 2, 1, 0
 dc.w  2, 4, 0, 0
 dc.w  1, 4, 6, 0
 dc.w  1, 6, 5, 0
 dc.w  1, 8, 4, 0
 dc.w  1, 10, 3, 0
 dc.w  1, 12, 2, 0
 dc.w  1, 14, 1, 0
 dc.w  1, 16, 0, 0
 dc.w  0, 16, 6, 0
 dc.w  2, 0, 4, 0
 dc.w  2, 2, 3, 0
 dc.w  2, 4, 2, 0
 dc.w  2, 6, 1, 0
 dc.w  2, 8, 0, 0
 dc.w  1, 8, 6, 0
 dc.w  1, 10, 5, 0
 dc.w  1, 12, 4, 0
 dc.w  1, 14, 3, 0
 dc.w  1, 16, 2, 0


linleft	dc.w	0
linrght	dc.w	0
synleft	dc.w	62
synrght	dc.w	62

scraddr	dc.b	0			; screen address (4 bytes)
scrhigh	dc.b	0
scrmid	dc.b	0
scrlow	dc.b	0

store	ds.l	4

*	*	*	*	*	*	*	*	*	*


