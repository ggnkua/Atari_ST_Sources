screen	=	$60000

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

	move.l	#screen,a0
	move.l	a0,phyz
	move.l	a0,crush4
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

wait_key	stop	#$2300
	move	#$2700,sr

	lea	current_sine(pc),a0
	move.l	(a0),a1
	move	(a1)+,d0
	ext.l	d0
	move	(a1)+,d1
	ext.l	d1

	cmpi	#-1,(a1)
	bne.s	.not_end_sine
	lea	sinus(pc),a1
.not_end_sine	move.l	a1,(a0)

	move.l	phyz(pc),a0
	move	d0,d2
	andi	#$fff0,d2
	sub	d2,d0
	add	d0,d0
	lsr	d2
	mulu	#160,d1
	add	d2,d1
	add.l	d1,a0

	lea	crush4(pc),a1
	move.l	(a1),a2
	move.l	a0,(a1)

n	set	0

	rept	13
	clr	n(a2)
	clr	n+8(a2)
n	set	n+160
	endr

	bsr	display_bubble4

	cmpi.b	#$39,$fffffc02.w
	bne	wait_key
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

display_bubble0	lea	bubble0_offset(pc),a1
	move	(a1,d0.w),d0
	lea	bubble0(pc),a1
	lea	(a1,d0.w),a1

n	set	0

	rept	32
	move	(a1)+,d0
	eor	d0,n(a0)
	move	(a1)+,d0
	eor	d0,n+8(a0)
	move	(a1)+,d0
	eor	d0,n+16(a0)

n	set	n+160
	endr

	rts
bubble0_offset	dc.w	0,384/2,768/2,1152/2,1536/2,1920/2,2304/2,2688/2,3072/2,3456/2,3840/2,4224/2,4608/2,4992/2,5376/2,5760/2

display_bubble1	lea	bubble1_offset(pc),a1
	move	(a1,d0.w),d0
	lea	bubble1(pc),a1
	lea	(a1,d0.w),a1

n	set	0

	rept	27
	move	(a1)+,d0
	eor	d0,n(a0)
	move	(a1)+,d0
	eor	d0,n+8(a0)
	move	(a1)+,d0
	eor	d0,n+16(a0)

n	set	n+160
	endr

	rts
bubble1_offset	dc.w	0,162,324,486,648,810,972,1134,1296,1458,1620,1782,1944,2106,2268,2430

display_bubble2	lea	bubble2_offset(pc),a1
	move	(a1,d0.w),d0
	lea	bubble2(pc),a1
	lea	(a1,d0.w),a1

n	set	0

	rept	21
	move.b	(a1)+,d0
	eor.b	d0,n(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+1(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+8(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+9(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+16(a0)

n	set	n+160
	endr

	rts
bubble2_offset	dc.w	0,105,210,315,420,525,630,735,840,945,1050,1155,1260,1365,1470,1575

display_bubble3	lea	bubble3_offset(pc),a1
	move	(a1,d0.w),d0
	lea	bubble3(pc),a1
	lea	(a1,d0.w),a1

n	set	0

	rept	18
	move.b	(a1)+,d0
	eor.b	d0,n(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+1(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+8(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+9(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+16(a0)

n	set	n+160
	endr

	rts
bubble3_offset	dc.w	0,90,180,270,360,450,540,630,720,810,900,990,1080,1170,1260,1350

display_bubble4	lea	bubble4_offset(pc),a1
	move	(a1,d0.w),d0
	lea	bubble4(pc),a1
	lea	(a1,d0.w),a1

n	set	0

	rept	13
	move	(a1)+,d0
	eor	d0,n(a0)
	move	(a1)+,d0
	eor	d0,n+8(a0)

n	set	n+160
	endr

	rts
bubble4_offset	dc.w	0,52,104,156,208,260,312,364,416,468,520,572,624,676,728,780

display_bubble5	lea	bubble5_offset(pc),a1
	move	(a1,d0.w),d0
	lea	bubble5(pc),a1
	lea	(a1,d0.w),a1

n	set	0

	rept	9
	move	(a1)+,d0
	eor	d0,n(a0)
	move	(a1)+,d0
	eor	d0,n+8(a0)

n	set	n+160
	endr

	rts
bubble5_offset	dc.w	0,36,72,108,144,180,216,252,288,324,360,396,432,468,504,540

display_bubble6	lea	bubble6_offset(pc),a1
	move	(a1,d0.w),d0
	lea	bubble6(pc),a1
	lea	(a1,d0.w),a1

n	set	0

	rept	5
	move.b	(a1)+,d0
	eor.b	d0,n(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+1(a0)
	move.b	(a1)+,d0
	eor.b	d0,n+8(a0)

n	set	n+160
	endr

	rts

bubble6_offset	dc.w	0,15,30,45,60,75,90,105,120,135,150,165,180,195,210,225

*

new_vbl	rte

phyz	dc.l	0
	dc.l	0

current_sine	dc.l	sinus
sinus	incbin	a:\m_bubble.dat
	dc.w	-1
crush4	dc.l	0

bubble0	;incbin	a:\boule0.dat
bubble1	;incbin	a:\boule1.dat
bubble2	;incbin	a:\boule2.dat
bubble3	;incbin	a:\boule3.dat
bubble4	incbin	a:\boule4.dat
bubble5	;incbin	a:\boule5.dat
bubble6	;incbin	a:\boule6.dat
	end