
	lea	NEWPAL,A1
	bsr	fade

	rts

	
;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade	move.w	#7,d6
	move.l	a1,a2
next_value
	lea	$ffff8240.w,a0

	move.w	#16-1,d7
.loop	bsr	modify
	add.w	#2,a0
	add.w	#2,a1
	dbf	d7,.loop

	move.w	#4,d0
	bsr	vbl
	move.l	a2,a1
	dbf	d6,next_value
	rts

vbl	movem.l	d0-d3/d7/a0-a3,-(sp)
	move.l	d0,d7
.loop	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	dbf	d7,.loop
	movem.l	(sp)+,d0-d3/d7/a0-a3
	rts

modify	move.w	(a0),d0		;get color value
	move.w	(a1),d1		;target pal
	move.w	d0,d4		;NEW COL
	move.w	d0,d2
	move.w	d1,d3
	and.w	#7,d2
	and.w	#7,d3
	cmp.w	d2,d3
	beq.s	blue_ok
	bmi.s	blue_dn
	addq.w	#1,d4
	bra.s	blue_ok
blue_dn	subq	#1,d4
blue_ok	move.w	d0,d2
	move.w	d1,d3
	and.w	#$70,d2
	and	#$70,d3
	cmp.w	d2,d3
	beq.s	grn_ok
	bmi.s	grn_dn
	add.w	#$10,d4
	bra.s	grn_ok
grn_dn	sub.w	#$10,d4
grn_ok	move.w	d0,d2
	move.w	d1,d3
	and.w	#$700,d2
	and.w	#$700,d3
	cmp.w	d2,d3
	beq.s	red_ok
	bmi.s	red_dn
	add.w	#$100,d4
	bra.s	red_ok
red_dn	sub.w	#$100,d4
red_ok	move.w	d4,(a0)
	rts

