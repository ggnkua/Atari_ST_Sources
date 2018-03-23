	dc.w	$a00a

	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	old_a7(pc),a0
	move.l	a7,2(a0)
	lea	new_a7(pc),a7

	lea	old_colors(pc),a0
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	clr.b	$ffff8260.w

	move	#$777,$ffff8240.w

	lea	screen(pc),a1
	move.l	$44e.w,a0
	lea	-12032(a0),a0
	move.l	a0,(a1)
	move	#11008,d7
cls	move.l	#$0,(a0)+
	dbf	d7,cls

	lea	old_screen(pc),a0
	lea	$ffff8201.w,a2
	movep	(a2),d7
	move	d7,4(a0)
	move.b	$c(a2),3(a0)
	clr.b	$c(a2)

	move.l	(a1),d6
	lsr.l	#8,d6
	movep	d6,(a2)

	jsr	fade_to_black

	move	#$2700,sr

	move.b	#$12,$fffffc02.w
	sf	$484.w

	lea	$ffff8800.w,a0
	move.l	#$00000000,(a0)
	move.l	#$01010000,(a0)
	move.l	#$02020000,(a0)
	move.l	#$03030000,(a0)
	move.l	#$04040000,(a0)
	move.l	#$05050000,(a0)
	move.l	#$06060000,(a0)
	move.l	#$0707ffff,(a0)
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)

;	save all i can

	lea	timer(pc),a0
	lea	$fffffa00.w,a1
	move.b	$1f(a1),$3(a0)
	move.b	$21(a1),$9(a0)
	move.b	$07(a1),$f(a0)
	move.b	$09(a1),$15(a0)
	move.b	$13(a1),$1b(a0)
	move.b	$15(a1),$21(a0)
	move.b	$19(a1),$27(a0)
	move.b	$1b(a1),$2d(a0)
	lea	interrupts(pc),a0
	move.l	$68.w,2(a0)
	move.l	$70.w,$a(a0)
	move.l	$120.w,$12(a0)
	move.l	$134.w,$1a(a0)

	clr.b	$15(a1)

;	set up timer b for rasters

	clr.b	$07(a1)
	clr.b	$09(a1)
	bset	#$3,$17(a1)
	lea	new_timer_b(pc),a0
	move.l	a0,$120.w
	move.b	#$1,$07(a1)
	move.b	#$1,$13(a1)

;	set up new_vbl

	lea	new_hbl(pc),a0
	move.l	a0,$68.w
	lea	new_vbl(pc),a0
	move.l	a0,$70.w

;	let's go

	move	#$2300,sr

;	wait for the 'space' key and constitutes all parts of intro

wait_key	cmpi.b	#$b9,$fffffc02.w
	beq.s	overall_end
	bra.s	wait_key
exit	
	move	#$2700,sr

	lea	$fffffa00.w,a1

	clr.b	$07(a1)
	bclr.b	#$3,$17(a1)

	clr.b	$19(a1)
	move.b	#$26,$1f(a1)
	move.b	#$1,$19(a1)

	lea	sample(pc),a6
	lea	sample_player(pc),a0
	move.l	a0,$134.w

	move.b	#$20,$07(a1)
	move.b	#$20,$13(a1)

	lea	nothing(pc),a0
	move.l	a0,$70.w
	move.l	a0,$68.w

	move	#$2300,sr
	lea	flag(pc),a5
	clr	(a5)

wait_key2	cmpi.b	#$b9,$fffffc02.w
	beq.s	overall_end
	tst	(a5)
	beq.s	wait_key2
overall_end

	move	#$2700,sr

;	restore all i can

	lea	$ffff8800.w,a0
	move.l	#$00000000,(a0)
	move.l	#$01010000,(a0)
	move.l	#$02020000,(a0)
	move.l	#$03030000,(a0)
	move.l	#$04040000,(a0)
	move.l	#$05050000,(a0)
	move.l	#$06060000,(a0)
	move.l	#$0707ffff,(a0)
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)

interrupts	move.l	#0,$68.w
	move.l	#0,$70.w
	move.l	#0,$120.w
	move.l	#0,$134.w

	clr.b	$fffffa1b.w
	clr.b	$fffffa19.w
timer	move.b	#0,$fffffa1f.w
	move.b	#0,$fffffa21.w
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	move.b	#0,$fffffa13.w
	move.b	#0,$fffffa15.w
	move.b	#0,$fffffa19.w
	move.b	#0,$fffffa1b.w
	bset.b	#$3,$fffffa17.w

old_screen	move.l	#0,d7
	lea	$ffff8201.w,a0
	movep	d7,(a0)
	swap	d7
	move.b	d7,$c(a0)
	lea	old_colors(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

old_a7	move.l	#0,a7
	move.b	#$8,$fffffc02.w
	st	$484.w

	move	#$2300,sr

	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	dc.w	$a009

	clr.l	-(a7)
	trap	#1

	ds.l	128
new_a7
old_colors	ds.l	8

***************************************************************************
;	here begins the real program with all fxs you can see
***************************************************************************

***************************************************************************

***************************************************************************
;	fade to black(like the metallica's song)
***************************************************************************

nothing	rte

fade_to_black	lea	.old_vbl(pc),a0
	move.l	$4ce.w,2(a0)
	lea	vbl_pos_flag(pc),a0
	lea	flag(pc),a1
	move	#$777,d7
	move.l	a0,$4ce.w

.loop_fading	cmpi	#2,(a1)
	blo.s	.loop_fading

	clr	(a1)
	subi	#$111,d7
	move	d7,$ffff8240.w

	bne.s	.loop_fading

.old_vbl	move.l	#0,$4ce.w
	rts

flag	dc.w	0

;	vbl vector for fading

vbl_pos_flag	move.l	a1,-(a7)
	lea	flag(pc),a1
	addq	#1,(a1)
	move.l	(a7)+,a1
	rts

***************************************************************************
;	here's the effect of closing in blue
***************************************************************************

;	timer b

new_timer_b	move	#$000,$ffff8240.w
	move.l	a6,-(a7)
	lea	new_timer_b(pc),a6
	not	2(a6)
	andi	#$004,2(a6)

	lea	flag(pc),a6
	tst	(a6)
	bne.s	follow_timer_b

	move	#1,(a6)
	lea	line_counter(pc),a6

	clr.b	$fffffa1b.w
	move.b	1(a6),$fffffa21.w
	move.b	#8,$fffffa1b.w

	bclr.b	#0,$fffffa0f.w
	move.l	(a7)+,a6
	rte

follow_timer_b	clr	(a6)
	lea	new_timer_b(pc),a6
	clr	2(a6)
	clr.b	$fffffa1b.w
	bclr.b	#0,$fffffa0f.w

	move.l	(a7)+,a6
	rte

line_counter	dc.w	$00fc

;	first vbl to make the screen close in blue

full_counter	dc.w	0

new_hbl	subq	#1,(a6)
	rte

new_vbl	move	#$004,$ffff8240.w
	lea	full_counter(pc),a6
	move	#$21,(a6)

	move	#$2100,sr

.loop_full	tst	(a6)
	bpl	.loop_full

	move	#$2700,sr

	clr.b	$fffffa1b.w
	lea	line_counter(pc),a6
	addq.b	#2,(a6)
	subq.b	#4,1(a6)
	move.b	(a6),$fffffa21.w
	tst.b	1(a6)
	beq	exit
	move.b	#$8,$fffffa1b.w

	rept	53
	nop
	endr

	move.b	#0,$ffff820a.w
	rept	10
	nop
	endr
	move.b	#2,$ffff820a.w

	move	#$2300,sr

	lea	screen(pc),a0
	move	2(a0),d7
	lsr	#8,d7
	addi	#143,d7
	andi	#$ff,d7

	moveq	#0,d6
.loop_test	cmp.b	$ffff8207.w,d7
	bhi.s	.loop_test

	move.b	$ffff8209.w,d7
	neg	d7
	lsl.l	d7,d7

	move	#$2700,sr

	move.b	#0,$ffff820a.w
	rept	10
	nop
	endr
	move.b	#2,$ffff820a.w

	move	#$2300,sr

	rte

***************************************************************************
;	here,the close sample player
***************************************************************************

sample_player	movem.l	d7/a4-a5,-(sp)
;	addi	#$1,$ffff8240.w

	lea	$ffff8800.w,a4
	moveq	#0,d7
	move.b	(a6)+,d7
	lea	replay_table(pc,d7.w),a5
	move.b	#$8,(a4)
	move.b	(a5),2(a4)
	move.b	#$9,(a4)
	move.b	256(a5),2(a4)
	move.b	#$a,(a4)
	move.b	512(a5),2(a4)

.bouh	cmpa.l	#sample_end,a6
	blo.s	.return

	lea	sample2,a6

	lea	.bouh(pc),a5
	lea	sample_end2,a4
	move.l	a4,2(a5)

.bouh2	addi.l	#14153,10(a5)
	lea	.bouh2(pc),a5
	move.l	#$4E714E71,(a5)+
	move.l	#$4E714E71,(a5)


;	lea	flag(pc),a5
;	move	#1,(a5)
.return	
	movem.l	(sp)+,d7/a4-a5
	rte

screen	dc.l	0
replay_table	incbin	a:\replay.dat
sample	incbin	a:\close.spl
sample_end	
sample2	incbin	a:\broum.spl
sample_end2	end