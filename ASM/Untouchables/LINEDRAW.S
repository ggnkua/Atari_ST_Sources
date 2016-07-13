; Line draw routine!
; Not too brilliant ...that's why i'm giving it away!!!!
; Clipped only on X.
; Coded by Tony B!


	opt	d+


	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	

loop
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	move	#7,$ffff8240.w
	
	move.l	$44e.w,linescr+2
	move	#150,d0
	move	#2,d1
	move	#150,d2
	move	#190,d3
	bsr.s	drawline

	move.l	$44e.w,linescr+2
	move	#10,d0
	move	#120,d1
	move	#240,d2
	move	#120,d3
	bsr.s	drawline
	
	move	#$777,$ffff8240.w

	cmp.b	#$39,$fffffc02.w
	bne.s	loop

	clr	-(sp)
	trap	#1


*------------------- line draw by Tony B of UNT!
; linescr+2 .. scr addr
; d0/d1 .. start x,y
; d2,d3 .. end x,y

drawline

linescr	lea	$f8000,a0

	cmp	d1,d3
	beq	horiz_line	;no change on Y

	cmp	d0,d2
	beq	vertical_line	;no change on X
	
	sub	d0,d2		;x2 negative?
	bpl.s	right
	neg	d2
	moveq	#-4,d4		;x direction left
	bra.s	left
right
	moveq	#4,d4		;x direction right
left
	sub	d1,d3		;y2 negative?
	bpl.s	down
	neg	d3
	move	#-160,a2		;y direction up
	bra.s	up
down
	move	#160,a2		;y direction down
up
	lea	mulu160(pc),a6
	add	d1,d1
	add	d1,a6
	add	(a6),a0

	cmp	d2,d3		;x=y ?
	blt.s	x_only
	exg	d2,d3		;x=y, y=x, =pixels to fill
	suba	a4,a4		;vertical line only
	move	a2,d6
	bra.s	y_only
x_only
	move	d4,a4		;horizontal line only
	clr	d6
y_only
	add	d3,d3		;diagonal line
	move	d3,a3
	sub	d2,d3
	move	d3,a1
	sub	d2,a1

	add	d0,d0
	add	d0,d0
	
	lea	xpoints(pc),a6
	neg	d2
	add	#319,d2
	mulu	#28,d2
	jmp	linelist(pc,d2.w)
linelist
	rept	319
	movem	(a6,d0.w),d1/d5
	or	d1,(a0,d5.w)
	tst	d3
	dc.w	$6a08
	add	a4,d0
	add	d6,a0
	add	a3,d3
	dc.w	$6006
	add	d4,d0
	add	a2,a0
	add	a1,d3
	endr
	rts

*------------------- drawing a vertical line only!
vertical_line
	sub	d1,d3		;y2 negative?
	bpl.s	.down
	neg	d3
	move	#-160,d6		;y direction up
	bra.s	.up
.down
	move	#160,d6		;y direction down
.up
	lea	mulu160(pc),a6
	add	d1,d1
	add	d1,a6
	add	(a6),a0

	add	d0,d0
	add	d0,d0
	lea	xpoints(pc),a6
	add	d0,a6
	move	(a6)+,d1
	add	(a6),a0
.lineloop
	or	d1,(a0)
	add	d6,a0		;next y
	dbf	d3,.lineloop
.nolines
	rts

*------------------- drawing a horizontal line only!
horiz_line	
	sub	d0,d2		;x2 negative?
	bpl.s	.right
	neg	d2
	moveq	#-4,d4		;x direction left
	bra.s	.left
.right
	moveq	#4,d4		;x direction right
.left
	add	d1,d1
	add	mulu160(pc,d1.w),a0
	
	add	d0,d0
	add	d0,d0
	lea	xpoints(pc),a6
.lineloop
	movem	(a6,d0.w),d1/d5
	or	d1,(a0,d5.w)
	add	d4,d0		;next x
	dbf	d2,.lineloop
.nolines
	rts


*------------------- line draw vars.
mulu160
i	set	0
	rept	200
	dc.w	i
i	set	i+160
	endr

	rept	500
	dc.w	0,0
	endr
xpoints
i	set	0
	rept	20
	dc.w	%1000000000000000,i
	dc.w	%0100000000000000,i
	dc.w	%0010000000000000,i
	dc.w	%0001000000000000,i
	dc.w	%0000100000000000,i
	dc.w	%0000010000000000,i
	dc.w	%0000001000000000,i
	dc.w	%0000000100000000,i
	dc.w	%0000000010000000,i
	dc.w	%0000000001000000,i
	dc.w	%0000000000100000,i
	dc.w	%0000000000010000,i
	dc.w	%0000000000001000,i
	dc.w	%0000000000000100,i
	dc.w	%0000000000000010,i
	dc.w	%0000000000000001,i
i	set	i+8
	endr	
	rept	500
	dc.w	0,i-8
	endr
