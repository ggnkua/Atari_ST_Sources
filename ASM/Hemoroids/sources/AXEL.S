screen	=	$40000

	dc.w	$a00a

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	sf	$484.w
	move.b	#$12,$fffffc02.w

	lea	old_sp(pc),a0
	move.l	a7,2(a0)
	lea	new_sp(pc),a7

	lea	old_colors(pc),a0
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	lea	palette(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#screen,a0
	move.l	a0,phyz
	move.l	a0,d0
	move	#7999,d7
cls	move.l	#$00000000,(a0)+
	dbf	d7,cls

	move.l	a0,phyz+4
	lea	$ffff8201.w,a1
	lsr.l	#8,d0
	movep	d0,(a1)
	clr.b	$c(a1)

	move	#7999,d7
cls2	move.l	#$00000000,(a0)+
	dbf	d7,cls2

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

	lea	color_list(pc),a1
loop_fade	stop	#$2300
	stop	#$2300
	stop	#$2300
	move	(a1)+,$ffff8240.w	
	tst	(a1)
	bne.s	loop_fade

	lea	sinus(pc),a2

wait_key	stop	#$2300
	move	#$2700,sr

	move.l	phyz(pc),a0
	lea	-160*6+128(a0),a0
	move	(a2)+,d0
	cmpi	#-1,(a2)
	beq	exit

	add	d0,a0
	cmpi	#32000,d0
	bhs	.dont_display

	move	#200*160,d7
	sub	d0,d7
	lsr	#4,d7
	divu	#10,d7
	ext.l	d7
	subq	#1,d7

	lea	picture(pc),a1

	rept	6
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	lea	128(a0),a0
	endr

.display	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	lea	160-32(a0),a0
	dbf	d7,.display
.dont_display

	move	#$2300,sr

	cmpi.b	#$39,$fffffc02.w
	bne	wait_key
exit

wait_key2	cmpi.b	#$39,$fffffc02.w
	bne	wait_key2
	move	#$2700,sr

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
color_list	dc.l	$00010002
	dc.l	$01030114
	dc.l	$02150226
	dc.l	$03270000
sinus	incbin	a:\ax_sinus.dat
	dc.l	-1
palette	incbin	a:\axel.col
picture	incbin	a:\axel.dat
	end