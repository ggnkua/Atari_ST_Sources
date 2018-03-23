adtro_address	=	$60000
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
	move	#11007,d7
cls1	move.l	#$0,(a0)+
	dbf	d7,cls1

	move.l	$44e.w,a0
	lea	-12032(a0),a0
	lea	-32032(a0),a0
	lea	-12000(a0),a0
	move.l	a0,(a1)
	move	#11007,d7
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

;	set up the new screen

	lea	old_screen(pc),a0
	lea	$ffff8201.w,a2
	movep	(a2),d7
	move	d7,4(a0)
	move.b	$c(a2),3(a0)
	clr.b	$c(a2)

	move.l	-4(a1),d6
	lsr.l	#8,d6
	movep	d6,(a2)

;	premove the logo for the adtro bumping

	jsr	premove_logo(pc)

;	fades the screen(it's much cooler than a flash...)

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
	move.b	$07(a1),$3(a0)
	move.b	$09(a1),$9(a0)
	move.b	$13(a1),$f(a0)
	move.b	$15(a1),$15(a0)
	move.b	$19(a1),$1b(a0)
	move.b	$1b(a1),$21(a0)
	move.b	$1f(a1),$27(a0)
	move.b	$21(a1),$2d(a0)
	lea	interrupts(pc),a0
	move.l	$68.w,2(a0)
	move.l	$70.w,$a(a0)
	move.l	$120.w,$12(a0)
	move.l	$134.w,$1a(a0)

	clr.b	$13(a1)
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

wait_key2	cmpi.b	#$b9,$fffffc02.w
	beq	overall_end
	bra.s	wait_key2
exit2
;	a small pause

	move	#30000,d7
pause	divu	#-1,d0
	dbf	d7,pause

	move	#$2700,sr

;	switch off all mfp interrupts

	lea	$fffffa00.w,a0
	moveq	#0,d0
	movep	d0,$19(a0)
	movep	d0,$7(a0)
	movep	d0,$13(a0)

	lea	nothing(pc),a0
	move.l	a0,$120.w
	move.l	a0,$134.w

;	new colors for the logos(about to change...)

	move.l	#$00020007,$ffff8240.w
	move.l	#$00770077,$ffff8244.w
	move.l	#$00020007,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	move.l	#$00020007,$ffff8250.w
	move.l	#$00770077,$ffff8254.w
	move.l	#$00020007,$ffff8258.w
	move.l	#$00770077,$ffff825c.w

;	prepare an auto-modifiyng part

	lea	old_a1(pc),a1
	move.l	screen(pc),8(a1)
	lea	old_a12(pc),a1
	move.l	screen(pc),8(a1)

;	clear old left letters

	move.l	screen(pc),a0
	lea	74*160(a0),a0
	move.l	screen+4(pc),a1
	lea	74*160(a1),a1
	move	#1480*2-1,d7
clear_letters	clr.l	(a1)+
	clr.l	(a0)+
	dbf	d7,clear_letters

;	display the logo which sometimes flashes

	lea	offset(pc),a0
	move.l	32(a0),a0
	lea	screen(pc),a2
	move.l	(a2)+,a1
	lea	5924(a1),a1
	
	jsr	display

	move.l	(a2)+,a1
	lea	5924(a1),a1

	jsr	display

	lea	flag(pc),a0
	clr	(a0)

;	set up a new vbl

	lea	bumping_logo(pc),a0
	move.l	a0,$70.w

;	here we go!!

	move	#$2300,sr

wait_key3	cmpi.b	#$b9,$fffffc02.w
	beq	overall_end
	bra.s	wait_key3
exit3	move	#$2300,sr
	lea	fade(pc),a6
fade_it	tst	(a6)
	bne.s	fade_it

	lea	old_fade(pc),a6
	move.l	(a6),a5

	cmpi.l	#-1,(a5)
	beq.s	get_the_fuck_out
	cmpi.b	#$b9,$fffffc02.w
	beq.s	get_the_fuck_out

	movem.l	(a5)+,d3-d6
	move.l	a5,(a6)
	movem.l	d3-d6,$ffff8240.w

	lea	fade(pc),a6
fade_it2	tst	(a6)
	beq.s	fade_it2

	bra.s	fade_it-4
get_the_fuck_out
	move	#$2700,sr

	lea	fading_vbl(pc),a0
	move.l	a0,$70.w

	move.l	screen(pc),a0
	lea	$ffff8201.w,a1
	move.l	a0,d0
	move.l	a0,a3
	lsr.l	#8,d0
	movep	d0,(a1)
	move.l	screen+4(pc),a1

	move	#11007,d7
clear_whole	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d7,clear_whole

	lea	14720+40(a3),a3
	
	lea	fonts(pc),a0
	lea	faded_text(pc),a1

display_fonts	moveq	#0,d0
	move.b	(a1)+,d0
	subq	#1,d0
	lsl	#5,d0
	lea	(a0,d0.w),a2

	move	(a2)+,d0
	movep	d0,(a3)
	move	(a2)+,d0
	movep	d0,160(a3)
	move	(a2)+,d0
	movep	d0,320(a3)
	move	(a2)+,d0
	movep	d0,480(a3)
	move	(a2)+,d0
	movep	d0,640(a3)
	move	(a2)+,d0
	movep	d0,800(a3)
	move	(a2)+,d0
	movep	d0,960(a3)
	move	(a2)+,d0
	movep	d0,1120(a3)
	move	(a2)+,d0
	movep	d0,1280(a3)
	move	(a2)+,d0
	movep	d0,1440(a3)
	move	(a2)+,d0
	movep	d0,1600(a3)
	move	(a2)+,d0
	movep	d0,1760(a3)
	move	(a2)+,d0
	movep	d0,1920(a3)
	move	(a2)+,d0
	movep	d0,2080(a3)
	move	(a2),d0
	movep	d0,2240(a3)

	addq	#1,a3
	move.l	a3,d0
	btst	#0,d0
	bne.s	dont_add
	addq	#6,a3
dont_add
	tst.b	(a1)
	beq.s	end_display

	bra.s	display_fonts
end_display
	move	#$2300,sr

	lea	faded_text_colors(pc),a5
	lea	flag(pc),a6
fade_again	tst	(a6)
	beq.s	fade_again
	clr	(a6)
fade_always	tst	(a6)
	beq.s	fade_always
	clr	(a6)
	move.l	(a5)+,$ffff8242.w
	tst	(a5)
	bne.s	fade_again

	move	#$2700,sr

	moveq	#-1,d7
pause2	divs	#-1,d6
	cmpi.b	#$b9,$fffffc02.w
	beq	overall_end
	dbf	d7,pause2

	move	#$2300,sr

	lea	faded_text_colors2(pc),a5
	lea	flag(pc),a6
fade_again2	tst	(a6)
	beq.s	fade_again2
	clr	(a6)
fade_always2	tst	(a6)
	beq.s	fade_always2
	clr	(a6)
	move.l	(a5)+,$ffff8240.w
	move.l	(a5)+,$ffff8244.w
	tst	(a5)
	bne.s	fade_again2

	move	#$2700,sr
overall_end

;	restore all i can

	move	#$2700,sr
timer	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	move.b	#0,$fffffa13.w
	move.b	#0,$fffffa15.w
	move.b	#0,$fffffa19.w
	move.b	#0,$fffffa1b.w
	move.b	#0,$fffffa1f.w
	move.b	#0,$fffffa21.w
	bset	#3,$fffffa17.w

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

;	small datas for fadings and for new sp

	ds.l	128
new_a7
old_colors	ds.l	8

old_fade	dc.l	fade_colors
fade_colors	dc.l	$00020007,$00770077,$00020007,$00770077
	dc.l	$00020006,$00660066,$00020006,$00660066
	dc.l	$00020005,$00550055,$00020005,$00550055
	dc.l	$00010004,$00440044,$00010004,$00440044
	dc.l	$00010003,$00330033,$00010003,$00330033
	dc.l	$00010002,$00220022,$00010002,$00220022
	dc.l	$00000001,$00110011,$00000001,$00110011
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	-1
faded_text_colors	dc.l	$00000000
	dc.l	$01110000
	dc.l	$02220111
	dc.l	$03330222
	dc.l	$04440333
	dc.l	$05550333
	dc.l	$06660444
	dc.l	$07770444
	dc.l	0
faded_text_colors2	dc.l	$00000777,$04440000
	dc.l	$01110777,$04440000
	dc.l	$02220777,$05550000
	dc.l	$03330777,$05550000
	dc.l	$04440777,$06660000
	dc.l	$05550777,$06660000
	dc.l	$06660777,$07770000
	dc.l	0

;	precalculation part for the bumping ADTRO logo

premove_logo	move.l	#adtro_address,a1
	lea	offset(pc),a2

	move	#$f,d7
.loop_premove	move	d7,d5
	eori	#$f,d5
	move.l	a1,(a2)+
	lea	adtro_log(pc),a0

	move	#125,d6
.loop_line	moveq	#0,d0
	move	(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,2(a1)
	swap	d0
	move	d0,(a1)

	moveq	#0,d0
	move	2(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,4(a1)
	swap	d0
	or	d0,2(a1)

	moveq	#0,d0
	move	4(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,6(a1)
	swap	d0
	or	d0,4(a1)

	moveq	#0,d0
	move	6(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,8(a1)
	swap	d0
	or	d0,6(a1)

	moveq	#0,d0
	move	8(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,10(a1)
	swap	d0
	or	d0,8(a1)

	moveq	#0,d0
	move	10(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,12(a1)
	swap	d0
	or	d0,10(a1)

	moveq	#0,d0
	move	12(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,14(a1)
	swap	d0
	or	d0,12(a1)

	moveq	#0,d0
	move	14(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,16(a1)
	swap	d0
	or	d0,14(a1)

	moveq	#0,d0
	move	16(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,18(a1)
	swap	d0
	or	d0,16(a1)

	moveq	#0,d0
	move	18(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,20(a1)
	swap	d0
	or	d0,18(a1)

	moveq	#0,d0
	move	20(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,22(a1)
	swap	d0
	or	d0,20(a1)

	moveq	#0,d0
	move	22(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,24(a1)
	swap	d0
	or	d0,22(a1)

	moveq	#0,d0
	move	24(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,26(a1)
	swap	d0
	or	d0,24(a1)

	moveq	#0,d0
	move	26(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,28(a1)
	swap	d0
	or	d0,26(a1)

	moveq	#0,d0
	move	28(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,30(a1)
	swap	d0
	or	d0,28(a1)

	moveq	#0,d0
	move	30(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,32(a1)
	swap	d0
	or	d0,30(a1)

	moveq	#0,d0
	move	32(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,34(a1)
	swap	d0
	or	d0,32(a1)

	moveq	#0,d0
	move	34(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,36(a1)
	swap	d0
	or	d0,34(a1)

	moveq	#0,d0
	move	36(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,38(a1)
	swap	d0
	or	d0,36(a1)

	moveq	#0,d0
	move	38(a0),d0
	swap	d0
	lsr.l	d5,d0
	move	d0,40(a1)
	swap	d0
	or	d0,38(a1)

	lea	40(a0),a0
	lea	40(a1),a1

	dbf	d6,.loop_line

	dbf	d7,.loop_premove
	
	move.l	a1,(a2)

	move	#1259,d7
.clear	move.l	#$0,(a1)+
	dbf	d7,.clear

	rts


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
	beq	overall_end

	rte

***************************************************************************
;    this is the part of the bumping ADTRO logos (drawn by me! (beurk))
***************************************************************************

bumping_logo	move	#$2700,sr

	lea	screen(pc),a0
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)

	move.b	d0,$ffff820d.w
	lsr.l	#8,d0
	lea	$ffff8201.w,a1
	movep	d0,(a1)

instruchange	lea	efx(pc),a0
	addq	#1,(a0)
	andi	#$ff,(a0)
	bne.s	continue

	lea	old_fx(pc),a1
	move.l	(a1),a2
	moveq	#0,d7
	move.b	(a2)+,d7

	tst.b	(a2)
	bne.s	thats_ok

	lea	instruchange(pc),a0
	addi	#2,2(a0)
	move	#$3,8(a0)
	andi	#$f0ff,10(a0)

	jmp	exit3(pc)
thats_ok
	move.l	a2,(a1)

	subq	#1,d7
	lsl	#2,d7
	lea	all_effects(pc),a1
	jsr	(a1,d7.w)

continue
	lea	screen+4(pc),a2
	lea	current_sinus(pc),a3
	addq	#4,(a3)
	andi	#$ffe,(a3)
	subq	#4,2(a3)
	andi	#$ffe,2(a3)

	lea	offset(pc),a5
	lea	flag(pc),a4

	tst	(a4)
	beq.s	dont

old_a1	move.l	#0,a1
	move.l	#0,a1

	lea	old_a1(pc),a0
	move.l	2(a0),8(a0)

	move.l	64(a5),a0
	jsr	display

old_a12	move.l	#0,a1
	move.l	#0,a1

	lea	old_a12(pc),a0
	move.l	2(a0),8(a0)

	move.l	64(a5),a0
	jsr	display
dont
	st	(a4)

	move.l	(a2),a1
	lea	320(a1),a1
	move	(a3),d7
	lea	sinus(pc),a4
	add	(a4,d7.w),a1
	lea	old_a1(pc),a0
	move.l	a1,2(a0)
	move	2(a4,d7.w),a0
	add.l	a5,a0
	move.l	(a0),a0

	jsr	display
      
	move.l	(a2),a1
	lea	320(a1),a1
	move	2(a3),d7
	add	(a4,d7.w),a1
	lea	2(a1),a1
	lea	old_a12(pc),a0
	move.l	a1,2(a0)
	move	2(a4,d7.w),a0
	add.l	a5,a0
	move.l	(a0),a0

	jsr	display

	move	#$2300,sr

	cmpi.b	#$b9,$fffffc02.w
	beq	overall_end

	rte

all_effects	jmp	fx1(pc)
	jmp	fx2(pc)
	jmp	fx3(pc)
	jmp	fx4(pc)
	jmp	fx5(pc)
	jmp	fx6(pc)
	jmp	fx7(pc)
	jmp	fx8(pc)
	jmp	fx9(pc)
	jmp	fx10(pc)
	jmp	fx11(pc)
	jmp	fx12(pc)
	jmp	fx13(pc)
	jmp	fx14(pc)
	jmp	fx15(pc)
	jmp	fx16(pc)
	jmp	fx17(pc)
	jmp	fx18(pc)
	jmp	fx19(pc)
	jmp	fx20(pc)
	jmp	fx21(pc)
	jmp	fx22(pc)
	jmp	fx23(pc)
	jmp	fx24(pc)
	jmp	fx25(pc)
	jmp	fx26(pc)
	jmp	fx27(pc)

fx1	move	#$077,$ffff8246.w
	move	#$077,$ffff824e.w
	subq	#8,(a0)
	rts
fx2	move	#$067,$ffff8246.w
	move	#$067,$ffff824e.w
	subq	#8,(a0)
	rts
fx3	move	#$057,$ffff8246.w
	move	#$057,$ffff824e.w
	subq	#8,(a0)
	rts
fx4	move	#$047,$ffff8246.w
	move	#$047,$ffff824e.w
	subq	#8,(a0)
	rts
fx5	move	#$037,$ffff8246.w
	move	#$037,$ffff824e.w
	subq	#8,(a0)
	rts
fx6	move	#$027,$ffff8246.w
	move	#$027,$ffff824e.w
	subq	#8,(a0)
	rts
fx7	move	#$017,$ffff8246.w
	move	#$017,$ffff824e.w
	subq	#8,(a0)
	rts
fx8	move	#$007,$ffff8246.w
	move	#$007,$ffff824e.w
	subq	#8,(a0)
	rts
fx9	move	#$077,$ffff8246.w
	move	#$077,$ffff824e.w
	rts
fx10	move	#$007,$ffff8246.w
	move	#$007,$ffff824e.w
	rts
fx11	move	#$777,$ffff8246.w
	move	#$777,$ffff824e.w
	rts

fx12	move.l	#$00020007,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	subq	#8,(a0)
	rts
fx13	move.l	#$01120117,$ffff8248.w
	move.l	#$01770177,$ffff824c.w
	subq	#8,(a0)
	rts
fx14	move.l	#$02220227,$ffff8248.w
	move.l	#$02770277,$ffff824c.w
	subq	#8,(a0)
	rts
fx15	move.l	#$03330337,$ffff8248.w
	move.l	#$03770377,$ffff824c.w
	subq	#8,(a0)
	rts
fx16	move.l	#$04440447,$ffff8248.w
	move.l	#$04770477,$ffff824c.w
	subq	#8,(a0)
	rts
fx17	move.l	#$05550557,$ffff8248.w
	move.l	#$05770577,$ffff824c.w
	subq	#8,(a0)
	rts
fx18	move.l	#$06660667,$ffff8248.w
	move.l	#$06770677,$ffff824c.w
	subq	#8,(a0)
	rts
fx19	move.l	#$07770777,$ffff8248.w
	move.l	#$07770777,$ffff824c.w
	subi	#100,(a0)
	rts

fx20	move.l	#$00020007,$ffff8248.w
	move.l	#$00770007,$ffff824c.w
	subq	#8,(a0)
	rts
fx21	move.l	#$01120007,$ffff8248.w
	move.l	#$01770117,$ffff824c.w
	subq	#8,(a0)
	rts
fx22	move.l	#$02220007,$ffff8248.w
	move.l	#$02770227,$ffff824c.w
	subq	#8,(a0)
	rts
fx23	move.l	#$03330007,$ffff8248.w
	move.l	#$03770337,$ffff824c.w
	subq	#8,(a0)
	rts
fx24	move.l	#$04440007,$ffff8248.w
	move.l	#$04770447,$ffff824c.w
	subq	#8,(a0)
	rts
fx25	move.l	#$05550007,$ffff8248.w
	move.l	#$05770557,$ffff824c.w
	subq	#8,(a0)
	rts
fx26	move.l	#$06660007,$ffff8248.w
	move.l	#$06770667,$ffff824c.w
	subq	#8,(a0)
	rts
fx27	move.l	#$07770007,$ffff8248.w
	move.l	#$07770777,$ffff824c.w
	subi	#100,(a0)
	rts

;	little VBL for the fading...

fading_vbl	lea	flag(pc),a6
	move	#1,(a6)
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

;	datas for the sample of t2

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

;	datas of the moving adtro logos

efx	dc.w	0
fade	dc.w	0
old_fx	dc.l	fxs
fxs	dc.b	12,13,14,15,16,17,18,19,18,17,16,15,14,13,12	;logo flashes
	dc.b	9,2,3,4,5,6,7		;plans swap
	dc.b	20,21,22,23,24,25,26,27,26,25,24,23,22,21,20	;logo flashes again
	dc.b	10,7,6,5,4,3,2,1	;swap plans again
	dc.b	0
	even
offset	ds.l	17
adtro_log	incbin	a:\adtro.log
current_sinus	dc.w	0
	dc.w	0
sinus	incbin	a:\boing.dat

;	faded text

faded_text	dc.b	16,18,5,19,5,14,20,5,4,46,9,14,46,36,44,44,38,46,2,25,0
	even
sample_counter	dc.w	22

;	all datas of samples

sample	incbin	a:\close.spl
sample_end
sample2	incbin	a:\broux.spl
sample_end2
sample3	incbin	a:\risx.spl
sample_end3
	even

;	here lies the generated code for the logo dumping
;	the file is 42Kb long so nothing after it pliz...

display	include	include.s
	rts

	end