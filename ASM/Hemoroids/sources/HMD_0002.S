	dc.w	$a00a

	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

;	save the old stack pointer and set a new one

	lea	old_a7(pc),a0
	move.l	a7,2(a0)
	lea	new_a7(pc),a7

;	save all colors

	lea	old_colors(pc),a0
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	clr.b	$ffff8260.w

	move	#$777,$ffff8240.w

;	clear the screen (certainly because it's dirty)

	lea	screen(pc),a1
	move.l	$44e.w,a0
	lea	-12032(a0),a0
	move.l	a0,(a1)+
	move.l	a0,a2
	move	#11008,d7
cls	move.l	#$0,(a0)+
	dbf	d7,cls

	move.l	$44e.w,a0
	lea	-24064(a0),a0
	lea	-32000(a0),a0
	move.l	a0,(a1)
	move.l	a0,a2
	move	#7999,d7
cls2	move.l	#$0,(a0)+
	dbf	d7,cls2

;	prepare for bumping letters clearance

	lea	curve(pc),a3
	lea	old_curv(pc),a4
	rept	28
	move.l	a3,(a4)+
	endr
	lea	old_place(pc),a3
	rept	28
	move.l	a2,(a3)+
	endr

	lea	old_screen(pc),a0
	lea	$ffff8201.w,a2
	movep	(a2),d7
	move	d7,4(a0)
	move.b	$c(a2),3(a0)
	clr.b	$c(a2)

	move.l	-4(a1),d6
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
	move.b	$13(a1),$3(a0)
	move.b	$15(a1),$9(a0)
	move.b	$07(a1),$f(a0)
	move.b	$09(a1),$15(a0)
	move.b	$19(a1),$1b(a0)
	move.b	$1b(a1),$21(a0)
	move.b	$1f(a1),$27(a0)
	move.b	$21(a1),$2d(a0)
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
	beq	overall_end
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

	lea	flag(pc),a5
	clr	(a5)

;	colors of letters (bumping ones)

	lea	$ffff8240.w,a0
	move.l	#$00020777,(a0)+
               	move.l	#$04440777,(a0)+
	move.l	#$07770777,(a0)+
	move.l	#$07770777,(a0)+
	move.l	#$04440444,(a0)+
	move.l	#$04440444,(a0)+
	move.l	#$04440444,(a0)+
	move.l	#$04440444,(a0)

	lea	bumping_letters(pc),a0
	move.l	a0,$70.w

	move	#$2300,sr

wait_key3	cmpi.b	#$b9,$fffffc02.w
	beq.s	overall_end
	bra.s	wait_key3
exit2

overall_end

;	restore all i can

	move	#$2700,sr
timer	move.b	#0,$fffffa13.w
	move.b	#0,$fffffa15.w
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	move.b	#0,$fffffa19.w
	move.b	#0,$fffffa1b.w
	move.b	#0,$fffffa1f.w
	move.b	#0,$fffffa21.w
interrupts	move.l	#0,$68.w
	move.l	#0,$70.w
	move.l	#0,$120.w
	move.l	#0,$134.w
old_screen	move.l	#0,d7
	lea	$ffff8201.w,a0
	movep	d7,(a0)
	swap	d7
	move.b	d7,$c(a0)
	lea	old_colors(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

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
	andi	#$002,2(a6)

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

new_vbl	move	#$002,$ffff8240.w
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


bouh	cmpa.l	#sample_end,a6
	blo.s	return

	lea	sample2,a6

	lea	sample_counter(pc),a5
	subq	#1,(a5)
	bne.s	.bouh2-4

	lea	bouh(pc),a5
	lea	sample_end3,a6
	move.l	a6,2(a5)
	lea	sample3,a6
	move.l	a6,10(a5)

	clr.b	$fffffa19.w
.bouh2	move.b	#$32,$fffffa1f.w
	move.b	#$2f,$fffffa1f.w
	move.b	#1,$fffffa19.w

	lea	.bouh2(pc),a5
	move	2(a5),d7
	move	8(a5),2(a5)
	move	d7,8(a5)

bouh3	jsr	first_time(pc)

return	
	movem.l	(sp)+,d7/a4-a5
	rte

replay_table	incbin	a:\replay.dat
	even

first_time	lea	bouh(pc),a5
	lea	sample_end2-1000,a4
	move.l	a4,2(a5)
	addi.l	#16150,10(a5)

	clr.b	$fffffa19.w
	move.b	#$32,$fffffa1f.w
	move.b	#1,$fffffa19.w

	lea	bouh3(pc),a5
	move.l	#$4E714E71,(a5)
	rts

***************************************************************************
;	   the bumping letters...
***************************************************************************

bumping_letters	lea	screen(pc),a0
	move.l	4(a0),d0
	move.l	(a0),4(a0)
	move.l	d0,(a0)
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep	d0,(a0)

	move	#0,$ffff8240.w

.loop_factor	move	#27,d0
.loop_boing	move	d0,d1
	move	d1,d2
	lsl	#2,d1
	lea	validity(pc),a2
	tst.b	(a2,d2.w)
	beq	.dont_do_it

	lea	old_curv(pc),a0
	lea	(a0,d1.w),a0
	move.l	(a0),a1
	moveq	#0,d7
	move	(a1)+,d7

	cmpi.l	#19000,d7
	bhi.s	.dont_launch_next
	tst.b	-1(a2,d2.w)
	bne.s	.dont_launch_next
 	move.b	#2,-1(a2,d2.w)
.dont_launch_next

	move	(a1)+,d6
	cmpi	#-1,(a1)
	bne	.ok

 	clr.b	(a2,d2.w)

	tst	d0
	bne.s	.ok1

;	here,i modify the code for the other sentence

.myself	lea	.nop_nop(pc),a2
	lea	.replace_nop(pc),a3
	move	2(a2),2(a3)
	move.l	#$4e714e71,(a2)
.ok1

	lsr	d1
	move.l	screen+4(pc),a3
.base_offset	lea	75*160+24(a3),a3	;0
	adda.l	d7,a3		;4
	move.l	screen(pc),a4		;6
	lea	75*160+24(a4),a4	;10
	adda.l	d7,a4		;14
	lea	add_screen(pc),a5	;16
	add	(a5,d1.w),a3		;20
	add	(a5,d1.w),a4		;24
	lsl	d1

	move.b	(a3),(a4)
	move.b	2(a3),2(a4)
	move.b	160(a3),160(a4)
	move.b	162(a3),162(a4)
	move.b	320(a3),320(a4)
	move.b	322(a3),322(a4)
	move.b	480(a3),480(a4)
	move.b	482(a3),482(a4)
	move.b	640(a3),640(a4)
	move.b	642(a3),642(a4)
	move.b	800(a3),800(a4)
	move.b	802(a3),802(a4)
	move.b	960(a3),960(a4)
	move.b	962(a3),962(a4)
	move.b	1120(a3),1120(a4)
	move.b	1122(a3),1122(a4)
	move.b	1280(a3),1280(a4)
	move.b	1282(a3),1282(a4)
	move.b	1440(a3),1440(a4)
	move.b	1442(a3),1442(a4)
	move.b	1600(a3),1600(a4)
	move.b	1602(a3),1602(a4)
	move.b	1760(a3),1760(a4)
	move.b	1762(a3),1762(a4)
	move.b	1920(a3),1920(a4)
	move.b	1922(a3),1922(a4)
	move.b	2080(a3),2080(a4)
	move.b	2082(a3),2082(a4)
	move.b	2240(a3),2240(a4)
	move.b	2242(a3),2242(a4)

	lea	curve(pc),a1
	move.l	a1,(a0)

	bra	.dont_do_it
.ok	move.l	a1,(a0)

	lea	old_place(pc),a3
	adda	d1,a3

	cmpi.b	#1,(a2,d2.w)
	bne	.text

	move.l	(a3),a4

	move.l	28*4(a3),(a3)

	moveq	#0,d3

	movep	d3,-2560(a4)
	movep	d3,-2400(a4)
	movep	d3,-2240(a4)
	movep	d3,-2080(a4)
	movep	d3,-1920(a4)
	movep	d3,-1760(a4)
	movep	d3,-1600(a4)
	movep	d3,-1440(a4)
	movep	d3,-1280(a4)
	movep	d3,-1120(a4)
	movep	d3,-960(a4)
	movep	d3,-800(a4)
	movep	d3,-640(a4)
	movep	d3,-480(a4)
	movep	d3,-320(a4)
	movep	d3,-160(a4)
	movep	d3,(a4)
	movep	d3,160(a4)
	movep	d3,320(a4)
	movep	d3,480(a4)
	movep	d3,640(a4)
	movep	d3,800(a4)
	movep	d3,960(a4)
	movep	d3,1120(a4)
	movep	d3,1280(a4)
	movep	d3,1440(a4)
	movep	d3,1600(a4)
	movep	d3,1760(a4)
	movep	d3,1920(a4)
	movep	d3,2080(a4)
	movep	d3,2240(a4)
 	movep	d3,2400(a4)
	movep	d3,2560(a4)

.text	lea	ajoute1(pc),a0
	move.b	#1,(a2,d2.w)

	lsr	d1

	lea	fonts(pc),a2
	adda	(a0,d1.w),a2             
	lea	32(a2),a2

	move.l	screen(pc),a0

.base_offset2	lea	75*160+24(a0),a0	;0
	adda.l	d7,a0		;4
	lea	add_screen(pc),a4	;6
	add	(a4,d1.w),a0		;10
 	move.l	a0,28*4(a3)

	lea	rotation(pc),a3
	lea	(a3,d6.w),a3
	lea	table(pc),a4

***************************************************************************

	rept	16
	lea	(a0),a1
	move	(a3)+,d7
	move	(a4,d7.w),d7
	adda	d7,a1
	move.b	-(a2),2(a1)
	move.b	-(a2),(a1)
	endr

.dont_do_it
	dbf	d0,.loop_boing

	move	#2,$ffff8240.w

.nop_nop	jmp	.end_nop_nop(pc)

	lea	.nop_nop(pc),a2
	move	#$4efa,(a2)+
.replace_nop	move	#0,(a2)

	lea	validity(pc),a2
	move.b	#2,13(a2)
	lea	.myself(pc),a2
	move	#$4ef9,(a2)+
	lea	exit2(pc),a3
	move.l	a3,(a2)
	lea	.loop_factor(pc),a2
	move	#13,2(a2)
	lea	.text(pc),a2
	addi	#28*2,2(a2)
	lea	.base_offset2(pc),a2
	addi	#160*16-24+104+4,2(a2)
	add	#2*28,8(a2)
	bchg.b	#6,10(a2)

	lea	.base_offset(pc),a2
	add	#160*16-24+104+4,2(a2)
	add	#160*16-24+104+4,12(a2)
	add	#2*28,18(a2)
	bchg.b	#6,20(a2)
	bchg.b	#6,24(a2)

	lea	old_place(pc),a2
	rept	14
	move.l	screen(pc),(a2)+
	endr

.end_nop_nop
	cmpi.b	#$b9,$fffffc02.w
	beq	exit2

	rte

***************************************************************************
***************************************************************************
***************************************************************************
*                                                                         *
*                   datas part for all the pieces of fxs                  *
*                                                                         *
***************************************************************************
***************************************************************************
***************************************************************************

screen	dc.l	0
	dc.l	0

;	datas for the bumping letters

	dc.w	-2560,-2400,-2240,-2080,-1920,-1760,-1600,-1440,-1280,-1120,-960,-800,-640,-480,-320,-160
table	dc.w	0,160,320,480,640,800,960,1120,1280,1440,1600,1760,1920,2080,2240,2400,2560
	dc.w	0
validity	ds.w	13
	dc.w	2
old_curv	ds.l	28
old_place	ds.l	28*2
curve	incbin	a:\curve.dat
	dc.l	-1
ajoute1	dc.w	10*32,4*32,4*32,15*32,45*32,24*32,14*32,20*32,17*32,45*32,15*32,17*32,4*32
 	dc.w	15*32,0,17*32,0,19*32,8*32,14*32,13*32,45*32,7*32,45*32,22*32,8*32,19*32,7*32
	dc.w	24*32,0*32,28*32,2*32,14*32,25*32,45*32,7*32,4*32,17*32,4*32,45*32,8*32,18*32
add_screen	dc.w	0,1,8,9,16,17,24,25,32,33,40,41,48,49,56,57,64,65,72,73,80,81,88,89,96,97,104,105
add_screen2	dc.w	56,55,48,47,40,39,32,31,24,23,16,15,8,7
rotation	incbin	a:\rotated.dat
fonts	incbin	a:\tiny.fnt
	ds.l	8

sample_counter	dc.w	19

;	datas for the sample of t2

sample	incbin	a:\close.spl
sample_end

;	datas for the 2nd sample(from Van Hallen)

sample2	incbin	a:\broux.spl
sample_end2

;	datas for the 3rd sample(Thrashy one...)

sample3	incbin	a:\risx.spl
sample_end3
	end