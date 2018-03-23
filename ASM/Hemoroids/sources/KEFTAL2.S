screen	=	$60000

	dc.w	$a00a

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	sf	$484.w
	move.b	#$12,$fffffc02.w

	lea	old_sp(pc),a0
	move.l	a7,2(a0)
	lea	new_sp(pc),a7

	lea	old_colors(pc),a0
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	lea	new_colors(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#screen,a0
	move.l	a0,phyz
	move.l	a0,d0
	move	#7999,d7
cls	move.l	#$00000000,(a0)+
	dbf	d7,cls

	move.l	a0,phyz+4
	move	#7999,d7
cls2	move.l	#$00000000,(a0)+
	dbf	d7,cls2

;	lea	$ffff8201.w,a0
;	lsr.l	#8,d0
;	movep	d0,(a0)
;	clr.b	$c(a0)

	stop	#$2300
	clr.b	$ffff8260.w

	move	#$2700,sr

	lea	old_vbl(pc),a0
	move.l	$70.w,2(a0)
	lea	new_vbl(pc),a0
	move.l	a0,$70.w

	lea	$fffffa00.w,a1
	lea	old_interrupts(pc),a0
	move.b	$05(a1),3(a0)
	move.b	$13(a1),9(a0)
	move.b	$15(a1),15(a0)

	bset	#4,$05(a1)
	clr.b	$13(a1)
	clr.b	$15(a1)

	moveq	#0,d5
loop_always	move.l	phyz(pc),a0
	lea	160*100+72(a0),a0
	lea	(a0),a1

	lea	xy_square-2(pc),a6
	move	#101,d7
.loop_y	move	(a6)+,d1
	moveq	#1,d2
	moveq	#1,d3

	clr.l	(a0)
	clr.l	(a1)
	clr.l	4(a0)
	clr.l	4(a1)

	lea	xy_square(pc),a5
	move	#159,d6
.loop_x	move	(a5)+,d0

.change_instr	add	d1,d0	;sub=hyperboles
			;add=circles
	lsr	d5,d0	;d5 = alpha parameter

	andi	#$000f,d0

	btst	#0,d0
	beq.s	.not_plane1
	or	d2,(a0)
	or	d3,(a1)
.not_plane1
	btst	#1,d0
	beq.s	.not_plane2
	or	d2,2(a0)
	or	d3,2(a1)
.not_plane2
	btst	#2,d0
	beq.s	.not_plane3
	or	d2,4(a0)
	or	d3,4(a1)
.not_plane3
	btst	#3,d0
	beq.s	.not_plane4
	or	d2,6(a0)
	or	d3,6(a1)
.not_plane4
	lsl	d2
	bne.s	.not_extend
	moveq	#1,d2
	lea	-8(a0),a0
	clr.l	(a0)
	clr.l	4(a0)
.not_extend
	lsr	d3
	bne.s	.not_extend2
	move	#$8000,d3
	lea	8(a1),a1
	clr.l	(a1)
	clr.l	4(a1)
.not_extend2

	cmpi.b	#$39,$fffffc02.w
	beq	exit

	dbf	d6,.loop_x
	moveq	#1,d2
	lea	-80(a0),a0
	lea	-240(a1),a1
	dbf	d7,.loop_y

	move.l	phyz(pc),a0
	move.l	a0,a1
	lea	-160(a0),a0
	adda.l	#31840,a1

	move	#99,d7
.copy	rept	40
	move.l	(a0)+,(a1)+
	endr
	lea	-320(a1),a1
	dbf	d7,.copy

	addq	#1,d5
	andi	#$000f,d5

	lea	phyz(pc),a0
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)

	lea	$ffff8201.w,a0
	lsr.l	#8,d0
	movep	d0,(a0)

	move.l	phyz+4(pc),a0
	lea	bitmap,a1
	move.w	#7999,d0
.co	move.l	(a0)+,(a1)+
	dbra	d0,.co


.wait_key	cmpi.b	#$1c,$fffffc02.w
	bne.s	.not_return
	lea	.change_instr(pc),a0
	bchg	#6,(a0)
	subq	#1,d5
	andi	#$f,d5
	bra.s	.wait_unpressed
.not_return	cmpi.b	#$39,$fffffc02.w
	bne.s	.wait_key

.wait_unpressed	btst.b	#7,$fffffc02.w
	beq.s	.wait_unpressed

	bra	loop_always
exit

old_vbl	move.l	#0,$70.w
	lea	$fffffa00.w,a1
old_interrupts	move.b	#0,$05(a1)
	move.b	#0,$13(a1)
	move.b	#0,$15(a1)

old_sp	move.l	#0,a7

	move	#$2300,sr

	st	$484.w
	move.b	#$8,$fffffc02.w

	lea	old_colors(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

***************************************************************************

	ds.l	128
new_sp
old_colors	ds.l	8

***************************************************************************

new_vbl	rte

phyz	dc.l	0
	dc.l	0
	
xy_square	incbin	a:\xysquare.dat

pic	dc.w	0
new_colors	dc.l	$00000111,$02220333,$04440555,$06660777
	dc.l	$07770666,$05550444,$03330222,$01110000
bitmap	ds.l	8000
picend
	end