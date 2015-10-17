;
; Interrupt driven palette fader. Automatically switches the interrupt
; off when it's finished 8 cycles.
;
;
;	~C:fade_to(speed,L:palette)
;	~C:fade_to_black(speed)
;	~C:fade_to_white(speed)

	bra	fade_to
	bra	fade_to_black

palpos=-10
speed=-6
count=-4
cycle=-2

fade_to_white
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d7
	lea	whitepal(pc),a6
	bra.s	fade
whitepal dcb.w	16,$777

fade_to_black
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d7
	lea	blackpal(pc),a6
	bra.s	fade
blackpal dcb.w	16,0
	
fade_to	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d7
	move.l	62(a7),a6
fade	lea	fade_it(pc),a0
	pea	(a0)
	move	#38,-(a7)
	trap	#14
	addq	#6,a7
	movem.l	(a7)+,d1-7/a0-6
	rts
	
fade_it	lea	vblfade(pc),a0
	move.l	a0,$4de.w
	move	d7,speed(a0)
	clr.l	count(a0)
	move.l	a6,palpos(a0)
	rts

turn_off
	clr.l	$4de.w			; switches itself off !
	movem.l	(a7)+,d0-7/a0-6
	rts
	
variables ds.w	5

vblfade	movem.l	d0-7/a0-6,-(a7)
	lea	vblfade(pc),a0
	addq	#1,count(a0)
	move	speed(a0),d0
	cmp	count(a0),d0
	blt.s	.fade
	movem.l	(a7)+,d0-7/a0-6
	rts
.fade	clr	count(a0)
	addq	#1,cycle(a0)
	cmp	#9,cycle(a0)
	bge.s	turn_off
	moveq	#15,d4			; 16 colours
	move.l	palpos(a0),a2
	lea	$ffff8240.w,a1
.c32	move	(a1),d0			; current colour
	move	(a2)+,d1		; destination colour
	bsr.s	fade_d0d1		; fade from d0 to d1
	move	d7,(a1)+		; result in d7
	dbf	d4,.c32
	movem.l	(a7)+,d0-7/a0-6
	rts
fade_d0d1
	and	#$777,d0
	move	d0,d7
	move	d1,d2
	and	#$7,d7
	and	#$7,d2
	cmp	d2,d7
	beq.s	.green
	ble.s	.inc1
	subq	#1,d7			; increase in red
	bra.s	.green
.inc1	addq	#1,d7			; decrease in red

.green	move	d0,d6
	move	d1,d2
	and	#$70,d6
	and	#$70,d2
	cmp	d2,d6
	beq.s	.blue
	ble.s	.inc2
	sub	#$10,d6			; decrease in green
	bra.s	.blue
.inc2	add	#$10,d6			; increase in green

.blue	move	d0,d5
	move	d1,d2
	and	#$700,d5
	and	#$700,d2
	cmp	d2,d5
	beq.s	.done
	ble.s	.inc3
	sub	#$100,d5		; decrease in blue
	bra.s	.done
.inc3	add	#$100,d5		; increase in blue

.done	or	d5,d7
	or	d6,d7			; merge red, green & blue
	rts

