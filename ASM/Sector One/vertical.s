;---------------------------------------------------------------------
;	Vertical overscan
;	by zerkman / Sector One
;---------------------------------------------------------------------

	section	text

__start:
debut:
	move	#32,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	d0,-(sp)

	lea	-128(sp),sp
	move.l	sp,a0
	move.l	$ffff8200.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.b	$ffff8260.w,(a0)+
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	movem.l $ffff8240.w,d1-d7/a1
	movem.l d1-d7/a1,(a0)

	lea	screen+256(pc),a0
	move.l	a0,d0
	move.l	d0,d1
	lsr	#8,d1
	move.l	d1,$ffff8200.w
	clr.b	d0

;fill screen with pattern
	move	#$0f0f,d1
	move.l	d0,a0		; screen address
	move	#276-1,d2	; number of lines
filbc1:	move	#20-1,d0	; 8 pixel blocks
filbc0:	move	d1,(a0)
	addq	#8,a0
	dbra	d0,filbc0
	moveq	#$3,d0
	and	d2,d0
	bne.s	lp2
	not	d1
lp2:	dbra	d2,filbc1

	move.l	sp,usp

	clr.b	$fffffa07.w	; iera
	clr.b	$fffffa09.w	; ierb

	bset	#5,$fffffa07.w	; activate timer A
	bset	#5,$fffffa13.w	; unmask timer A
	bset	#0,$fffffa07.w	; activate timer B
	bset	#0,$fffffa13.w	; unmask timer B

	clr.b	$fffffa19.w	; timer A - stop
	clr.b	$fffffa1b.w	; timer B - stop
	lea	timer_a_cfg(pc),a0
	move.l	a0,$134.w
	lea	timer_b(pc),a0
	move.l	a0,$120.w

	lea	hbl(pc),a0
	move.l	a0,$68.w
	lea	vbl(pc),a0
	move.l	a0,$70.w

	moveq	#0,d0
	lea	$ffff820a.w,a0
	lea	$ffff8260.w,a1
	stop	#$2300
	move.b	d0,(a1)
	move	a0,(a0)

nuts:	bra.s	nuts		; infinite wait loop

vbl:
	clr.b	$fffffa19.w	; timer A - stop
decale:	move.b	#$c2,$fffffa1f.w	; timer A - set counter
	move.b	#4,$fffffa19.w	; timer A - delay mode,divide by 50
	clr.b	$fffffa1b.w	; timer B - stop
	move.b	#228,$fffffa21.w	; timer B - set counter
	;move.b	#199,$fffffa21.w	; timer B - set counter
	move.b	#8,$fffffa1b.w	; timer B - event count mode

	cmp.b	#$39,$fffffc02.w
	beq	exit
	rte

hbl:
	rte

; On first frame, record HBL delay for lines 62 to 66.
; Since the delay is periodic every 5 lines, delay for lines 62-66
; is the same as lines 32-36 and line 32 is that which we use for
; synchronisation before we open the border between lines 32 and 33.
timer_a_cfg:
	clr.b	$fffffa19.w
	bclr.b	#5,$fffffa0f.w
	move	#$2300,sr

	moveq	#0,d5
	moveq	#12,d3
	moveq	#4,d2
	stop	#$2100
tacglp:
	stop	#$2100
	moveq	#0,d4
	move.b	$ffff8209.w,d4
	sub.b	d3,d4
	subq	#4,d4
	neg	d4
	add.b	#$a0,d3
	lsr	#2,d5
	lsl	#7,d4
	or	d4,d5
	dbra	d2,tacglp

	lea	snval(pc),a2
	move	d5,(a2)
	lea	decale+3(pc),a2
	move.b	#100,(a2)
	lea	timer_a(pc),a2
	move.l	a2,$134.w

	bsr	nextshift

	rte

; Shift HBL sync delays so the next delay is the (nth+3) mod 5
nextshift:
	lea	snval(pc),a2
	move	(a2),d2
	moveq	#$3f,d3
	and	d2,d3
	lsl	#4,d3
	lsr	#6,d2
	or	d3,d2
	move	d2,(a2)

	rts

timer_a:
	clr.b	$fffffa19.w	; timer A - stop
	bclr.b	#5,$fffffa0f.w
	stop	#$2100
	stop	#$2100
	move	#$2300,sr

; sync using the HBL delays table
	moveq	#3,d0
	and	snval(pc),d0
	add	d0,d0
	lsr	d0,d0

	dcb.w	90,$4e71
; Generic top border opening
	move.b	d0,(a0)	; LineCycles=488
	dcb.w	2,$4e71
	move	a0,(a0)	; LineCycles=504 - L16:16

	bsr	nextshift

	bclr.b	#5,$fffffa0f.w
	rte

timer_b:
	clr.b	$fffffa1b.w	; timer B - stop
	movem.l	d0-d1,-(sp)
	move.b	$ffff8209.w,d0
tbwbc:
	move.b	$ffff8209.w,d1
	cmp.b	d0,d1
	beq.s	tbwbc
	sub.b	d1,d0
	lsr.l	d0,d0		; now we're on sync with display
	rept	51
	nop
	endr
	move.b	#44,$fffffa21.w	; timer B - set counter
	move.b	#8,$fffffa1b.w	; timer B - event count mode
	clr.b	$ffff820a.w
	rept	6
	nop
	endr
	move.b	#2,$ffff820a.w
	movem.l	(sp)+,d0-d1

	bclr.b	#0,$fffffa0f.w
	rte

exit:
	move	#$2700,sr
	clr.b	$fffffa19.w

	clr.b	$ffff820a.w

	move.l	usp,sp

	move.l	sp,a0
	move.l	(a0)+,$ffff8200.w
	move.b	(a0)+,$ffff820a.w
	move.b	(a0)+,$ffff8260.w
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	movem.l (a0)+,d1-d7/a1
	movem.l d1-d7/a1,$ffff8240.w

	move	#$2300,sr

	lea	128(sp),sp

	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap	#1

	data

	bss
bss_start:
snval:	ds.w	1
screen:	ds.b	160*276+256
