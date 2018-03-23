screen	=	$60000
d1	=	1
d2	=	3
d3	=	3
d4	=	4
d5	=	5
d6	=	8
d7	=	10
d8	=	15

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

	lea	axel_palette(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	picture(pc),a1

	move.l	#screen,a0
	move.l	a0,phyz
	move.l	a0,d0
	move	#199,d7
cls	
	rept	32
	move.l	#$00000000,(a0)+
	endr

	rept	8
	move.l	(a1)+,(a0)+
	endr

	dbf	d7,cls

	lea	-6400(a1),a1

	move.l	a0,phyz+4
	lea	$ffff8201.w,a2
	lsr.l	#8,d0
	movep	d0,(a2)
	clr.b	$c(a2)

	move	#199,d7
cls2	
	rept	32
	move.l	#$00000000,(a0)+
	endr

	rept	8
	move.l	(a1)+,(a0)+
	endr

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

	move	#$700,$ffff8240.w
;
;	lea	current_palette(pc),a0
;	move.l	(a0),a1
;
;	movem.l	(a1)+,d0-d7
;	movem.l	d0-d7,$ffff8240.w
;
;	cmpi	#-1,(a1)
;	bne.s	.no_pal_loop
;	lea	palette(pc),a1
;.no_pal_loop	move.l	a1,(a0)

	lea	crush_old+17*4(pc),a2

	move	#16,d7
.loop_display	lea	current_sine(pc),a0
	move	d7,d6
	lsl	#4,d6
	add	d6,a0

	move.l	(a0),a1
	move	(a1)+,d0

	cmpi	#-1,(a1)
	bne.s	.not_end_sine
	lea	cosinus1(pc),a1
.not_end_sine	move.l	a1,(a0)

	move.l	4(a0),a1
	add	(a1)+,d0

	cmpi	#-1,(a1)
	bne.s	.not_end_sine2
	lea	cosinus2(pc),a1
.not_end_sine2	move.l	a1,4(a0)

	asr	d0
	addi	#4+16+140,d0

	move.l	8(a0),a1
	move	(a1)+,d1

	cmpi	#-1,(a1)
	bne.s	.not_end_sine3
	lea	sinus1(pc),a1
.not_end_sine3	move.l	a1,8(a0)

	move.l	12(a0),a1
	add	(a1)+,d1
	ext.l	d1
	
	cmpi	#-1,(a1)
	bne.s	.not_end_sine4
	lea	sinus2(pc),a1
.not_end_sine4	move.l	a1,12(a0)

	asr	d1
	addi	#4+16+80,d1

	lsr	#2,d6
	lea	list(pc,d6.w),a1
	move.l	(a1),a1
	jsr	(a1)

	dbf	d7,.loop_display

	bra.s	end_list
list	dc.l	display_bubble6
	dc.l	display_bubble5
	dc.l	display_bubble4
	dc.l	display_bubble3
	dc.l	display_bubble2
	dc.l	display_bubble1
	dc.l	display_bubble1
	dc.l	display_bubble0
	dc.l	display_bubble0
	dc.l	display_bubble0
	dc.l	display_bubble1
	dc.l	display_bubble1
	dc.l	display_bubble2
	dc.l	display_bubble3
	dc.l	display_bubble4
	dc.l	display_bubble5
	dc.l	display_bubble6
end_list	move	#$070,$ffff8240.w
	bsr	crush_it

	move.l	phyz+4(pc),d0
	move.l	phyz(pc),phyz+4
	move.l	d0,phyz

	lea	$ffff8201.w,a0
	lsr.l	#8,d0
	movep	d0,(a0)

	move	#$000,$ffff8240.w

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

crush_it	lea	crush_old(pc),a2

n	set	0

	move.l	(a2)+,a0	;bubble6
	rept	5
	clr	n(a0)
	clr.b	n+8(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble5
	rept	9
	clr	n(a0)
	clr	n+8(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble4
	rept	13
	clr	n(a0)
	clr	n+8(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble3
	rept	18
	clr	n(a0)
	clr	n+8(a0)
	clr.b	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble2
	rept	21
	clr	n(a0)
	clr	n+8(a0)
	clr.b	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble1
	rept	27
	clr	n(a0)
	clr	n+8(a0)
	clr	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble1
	rept	27
	clr	n(a0)
	clr	n+8(a0)
	clr	n+16(a0)
n	set	n+160
	endr
n	set	0

	move.l	(a2)+,a0	;bubble0
	rept	32
	clr	n(a0)
	clr	n+8(a0)
	clr	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble0
	rept	32
	clr	n(a0)
	clr	n+8(a0)
	clr	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble0
	rept	32
	clr	n(a0)
	clr	n+8(a0)
	clr	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble1
	rept	27
	clr	n(a0)
	clr	n+8(a0)
	clr	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble1
	rept	27
	clr	n(a0)
	clr	n+8(a0)
	clr	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble2
	rept	21
	clr	n(a0)
	clr	n+8(a0)
	clr.b	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble3
	rept	18
	clr	n(a0)
	clr	n+8(a0)
	clr.b	n+16(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble4
	rept	13
	clr	n(a0)
	clr	n+8(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble5
	rept	9
	clr	n(a0)
	clr	n+8(a0)
n	set	n+160
	endr

n	set	0

	move.l	(a2)+,a0	;bubble6
	rept	5
	clr	n(a0)
	clr.b	n+8(a0)
n	set	n+160
	endr

	rept	17
	move.l	(a2)+,-4*17-4(a2)
	endr

	rts

display_bubble0	subi	#16,d0
	subi	#16,d1
	move.l	phyz(pc),a0
	move	d0,d2
	andi	#$fff0,d2
	sub	d2,d0
	add	d0,d0
	lsr	d2
	mulu	#160,d1
	add	d2,d1
	add.l	d1,a0
	move.l	a0,(a2)+

	lea	bubble0_offset(pc),a1
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

display_bubble1	subi	#14,d0
	subi	#13,d1
	move.l	phyz(pc),a0
	move	d0,d2
	andi	#$fff0,d2
	sub	d2,d0
	add	d0,d0
	lsr	d2
	mulu	#160,d1
	add	d2,d1
	add.l	d1,a0
	move.l	a0,(a2)+

	lea	bubble1_offset(pc),a1
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

display_bubble2	subi	#11,d0
	subi	#10,d1
	move.l	phyz(pc),a0
	move	d0,d2
	andi	#$fff0,d2
	sub	d2,d0
	add	d0,d0
	lsr	d2
	mulu	#160,d1
	add	d2,d1
	add.l	d1,a0
	move.l	a0,(a2)+

	lea	bubble2_offset(pc),a1
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

display_bubble3	subi	#9,d0
	subi	#9,d1
	move.l	phyz(pc),a0
	move	d0,d2
	andi	#$fff0,d2
	sub	d2,d0
	add	d0,d0
	lsr	d2
	mulu	#160,d1
	add	d2,d1
	add.l	d1,a0
	move.l	a0,(a2)+

	lea	bubble3_offset(pc),a1
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

display_bubble4	subq	#7,d0
	subq	#6,d1
	move.l	phyz(pc),a0
	move	d0,d2
	andi	#$fff0,d2
	sub	d2,d0
	add	d0,d0
	lsr	d2
	mulu	#160,d1
	add	d2,d1
	add.l	d1,a0
	move.l	a0,(a2)+

	lea	bubble4_offset(pc),a1
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

display_bubble5	subq	#4,d0
	subq	#4,d1
	move.l	phyz(pc),a0
	move	d0,d2
	andi	#$fff0,d2
	sub	d2,d0
	add	d0,d0
	lsr	d2
	mulu	#160,d1
	add	d2,d1
	add.l	d1,a0
	move.l	a0,(a2)+

	lea	bubble5_offset(pc),a1
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

display_bubble6	subq	#3,d0
	subq	#3,d1
	move.l	phyz(pc),a0
	move	d0,d2
	andi	#$fff0,d2
	sub	d2,d0
	add	d0,d0
	lsr	d2
	mulu	#160,d1
	add	d2,d1
	add.l	d1,a0
	move.l	a0,(a2)+

	lea	bubble6_offset(pc),a1
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

current_palette	dc.l	palette
palette	dc.l	$00000222,$04440444,$06660666,$06660666
	dc.l	$07770777,$07770777,$07770777,$07770777

	dc.l	$00000777,$02220222,$04440444,$04440444
	dc.l	$06660666,$06660666,$06660666,$06660666

	dc.l	$00000666,$07770777,$02220222,$02220222
	dc.l	$04440444,$04440444,$04440444,$04440444

	dc.l	$00000444,$06660666,$07770777,$07770777
	dc.l	$02220222,$02220222,$02220222,$02220222

	dc.w	-1

current_sine	dc.l	cosinus1,cosinus2,sinus1,sinus2
	dc.l	cosinus1+d1*4,cosinus2+d1*4,sinus1+d1*4,sinus2+d1*4
	dc.l	cosinus1+(d1+d2)*4,cosinus2+(d1+d2)*4,sinus1+(d1+d2)*4,sinus2+(d1+d2)*4
	dc.l	cosinus1+(d1+d2+d3)*4,cosinus2+(d1+d2+d3)*4,sinus1+(d1+d2+d3)*4,sinus2+(d1+d2+d3)*4
	dc.l	cosinus1+(d1+d2+d3+d4)*4,cosinus2+(d1+d2+d3+d4)*4,sinus1+(d1+d2+d3+d4)*4,sinus2+(d1+d2+d3+d4)*4

	dc.l	cosinus1+(d1+d2+d3+d4+d5)*4,cosinus2+(d1+d2+d3+d4+d5)*4,sinus1+(d1+d2+d3+d4+d5)*4,sinus2+(d1+d2+d3+d4+d5)*4
	dc.l	cosinus1+(d1+d2+d3+d4+d5+d6)*4,cosinus2+(d1+d2+d3+d4+d5+d6)*4,sinus1+(d1+d2+d3+d4+d5+d6)*4,sinus2+(d1+d2+d3+d4+d5+d6)*4

	dc.l	cosinus1+(d1+d2+d3+d4+d5+d6+d7)*4,cosinus2+(d1+d2+d3+d4+d5+d6+d7)*4,sinus1+(d1+d2+d3+d4+d5+d6+d7)*4,sinus2+(d1+d2+d3+d4+d5+d6+d7)*4
	dc.l	cosinus1+(d1+d2+d3+d4+d5+d6+d7+d8)*4,cosinus2+(d1+d2+d3+d4+d5+d6+d7+d8)*4,sinus1+(d1+d2+d3+d4+d5+d6+d7+d8)*4,sinus2+(d1+d2+d3+d4+d5+d6+d7+d8)*4
	dc.l	cosinus1+(d1+d2+d3+d4+d5+d6+d7+d8*2)*4,cosinus2+(d1+d2+d3+d4+d5+d6+d7+d8*2)*4,sinus1+(d1+d2+d3+d4+d5+d6+d7+d8*2)*4,sinus2+(d1+d2+d3+d4+d5+d6+d7+d8*2)*4

	dc.l	cosinus1+(d1+d2+d3+d4+d5+d6+d7*2+d8*2)*4,cosinus2+(d1+d2+d3+d4+d5+d6+d7*2+d8*2)*4,sinus1+(d1+d2+d3+d4+d5+d6+d7*2+d8*2)*4,sinus2+(d1+d2+d3+d4+d5+d6+d7*2+d8*2)*4
	dc.l	cosinus1+(d1+d2+d3+d4+d5+d6*2+d7*2+d8*2)*4,cosinus2+(d1+d2+d3+d4+d5+d6*2+d7*2+d8*2)*4,sinus1+(d1+d2+d3+d4+d5+d6*2+d7*2+d8*2)*4,sinus2+(d1+d2+d3+d4+d5+d6*2+d7*2+d8*2)*4

	dc.l	cosinus1+(d1+d2+d3+d4+d5*2+d6*2+d7*2+d8*2)*4,cosinus2+(d1+d2+d3+d4+d5*2+d6*2+d7*2+d8*2)*4,sinus1+(d1+d2+d3+d4+d5*2+d6*2+d7*2+d8*2)*4,sinus2+(d1+d2+d3+d4+d5*2+d6*2+d7*2+d8*2)*4
	dc.l	cosinus1+(d1+d2+d3+d4*2+d5*2+d6*2+d7*2+d8*2)*4,cosinus2+(d1+d2+d3+d4*2+d5*2+d6*2+d7*2+d8*2)*4,sinus1+(d1+d2+d3+d4*2+d5*2+d6*2+d7*2+d8*2)*4,sinus2+(d1+d2+d3+d4*2+d5*2+d6*2+d7*2+d8*2)*4
	dc.l	cosinus1+(d1+d2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,cosinus2+(d1+d2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,sinus1+(d1+d2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,sinus2+(d1+d2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4
	dc.l	cosinus1+(d1+d2*2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,cosinus2+(d1+d2*2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,sinus1+(d1+d2*2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,sinus2+(d1+d2*2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4
	dc.l	cosinus1+(d1*2+d2*2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,cosinus2+(d1*2+d2*2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,sinus1+(d1*2+d2*2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4,sinus2+(d1*2+d2*2+d3*2+d4*2+d5*2+d6*2+d7*2+d8*2)*4

cosinus1	incbin	"COSIN_X1.DAT"
	dc.w	-1
cosinus2	incbin	"COSIN_X2.DAT"
	dc.w	-1
sinus1	incbin	"SIN_Y1.DAT"
	dc.w	-1
sinus2	incbin	"SIN_Y2.DAT"
	dc.w	-1
crush_old	dcb.l	17,screen
	ds.l	17

bubble0	incbin	"BOULE0.DAT"
bubble1	incbin	"BOULE1.DAT"
bubble2	incbin	"BOULE2.DAT"
bubble3	incbin	"BOULE3.DAT"
bubble4	incbin	"BOULE4.DAT"
bubble5	incbin	"BOULE5.DAT"
bubble6	incbin	"BOULE6.DAT"

axel_palette	incbin	"AXEL.COL"
picture	incbin	"AXEL.DAT"
	end