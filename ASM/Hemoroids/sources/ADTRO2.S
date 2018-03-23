adtro_address	=	$60000

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.b	$ffff8260.w
	lea	old_sp(pc),a0
	move.l	a7,2(a0)
	lea	new_sp(pc),a7

	move	#$7,$ffff8240.w
	jsr	premove_logo(pc)

	move.l	#$00020007,$ffff8240.w
	move.l	#$00770077,$ffff8244.w
	move.l	#$00020007,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	move.l	#$00020007,$ffff8250.w
	move.l	#$00770077,$ffff8254.w
	move.l	#$00020007,$ffff8258.w
	move.l	#$00770077,$ffff825c.w

	lea	screen(pc),a1
	move.l	$44e.w,a0
	suba.l	#32000,a0
	move.l	a0,(a1)+
	lea	old_a1(pc),a2
	move.l	a0,8(a2)
	lea	old_a12(pc),a2
	move.l	a0,8(a2)

	move	#7999,d7
cls	clr.l	(a0)+
	dbne	d7,cls

	move.l	a0,(a1)+
	move	#7999,d7
cls2	clr.l	(a0)+
	dbne	d7,cls2

	lea	offset(pc),a0
	move.l	32(a0),a0
	lea	screen(pc),a2
	move.l	(a2)+,a1
	lea	5924(a1),a1
	
	jsr	display(pc)

	move.l	(a2)+,a1
	lea	5924(a1),a1

	jsr	display(pc)

	move	#$2700,sr

	move.b	$fffffa15.w,imra+3
	clr.b	$fffffa15.w
	move	#$12,$fffffc02.w

	lea	old_vbl(pc),a0
	move.l	$70.w,2(a0)

	lea	new_vbl(pc),a0
	move.l	a0,$70.w

	move	#$2300,sr

wait_key	;jsr	new_vbl(pc)
	cmpi.b	#$b9,$fffffc02.w
	bne.s	wait_key
exit	
	move	#$2300,sr
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
wait_fade_chang	tst	(a6)
	beq.s	wait_fade_chang

	bra.s	fade_it-4
get_the_fuck_out

	move	#$2700,sr
old_vbl	move.l	#0,$70.w
old_sp	move.l	#0,a7
imra	move.b	#0,$fffffa15.w

	move	#$8,$fffffc02.w

	move	#$0777,$ffff8240.w
	move	#$0000,$ffff8246.w

	move	#$2300,sr

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

	ds.l	128
new_sp

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

new_vbl	move	#$2700,sr

	lea	screen(pc),a0
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)

	move.b	d0,$ffff820d.w
	lsr.l	#8,d0
	lea	$ffff8201.w,a1
	movep	d0,(a1)

.instruchange	lea	efx(pc),a0
	addq	#1,(a0)
	andi	#$ff,(a0)
	bne.s	.continue

	lea	old_fx(pc),a1
	move.l	(a1),a2
	moveq	#0,d7
	move.b	(a2)+,d7

	tst.b	(a2)
	bne.s	.thats_ok

	lea	.instruchange(pc),a0
	addi	#2,2(a0)
	move	#$3,8(a0)
	andi	#$f0ff,10(a0)

	bra	exit
.thats_ok
	move.l	a2,(a1)

	subq	#1,d7
	lsl	#2,d7
	lea	all_effects(pc),a1
	jsr	(a1,d7.w)
.continue
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
	jsr	display(pc)

old_a12	move.l	#0,a1
	move.l	#0,a1

	lea	old_a12(pc),a0
	move.l	2(a0),8(a0)

	move.l	64(a5),a0
	jsr	display(pc)
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

	jsr	display(pc)
      
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

	jsr	display(pc)

	move	#$2300,sr

	cmpi.b	#$b9,$fffffc02.w
	beq	exit

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
	move.l	#$00770077,$ffff824c.w
	subq	#8,(a0)
	rts
fx21	move.l	#$01120117,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	subq	#8,(a0)
	rts
fx22	move.l	#$02220227,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	subq	#8,(a0)
	rts
fx23	move.l	#$03330307,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	subq	#8,(a0)
	rts
fx24	move.l	#$04440447,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	subq	#8,(a0)
	rts
fx25	move.l	#$05550557,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	subq	#8,(a0)
	rts
fx26	move.l	#$06660667,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	subq	#8,(a0)
	rts
fx27	move.l	#$07770777,$ffff8248.w
	move.l	#$00770077,$ffff824c.w
	subi	#100,(a0)
	rts

***************************************************************************

old_fade	dc.l	fade_colors
fade_colors	dc.l	$00020007,$00770777,$00020007,$00770777
	dc.l	$11121117,$11771777,$11121117,$11771777
	dc.l	$22222227,$22772777,$22222227,$22772777
	dc.l	$33333337,$33773777,$33333337,$33773777
	dc.l	$44444447,$44774777,$44444447,$44774777
	dc.l	$55555557,$55775777,$55555557,$55775777
	dc.l	$66666667,$66776777,$66666667,$66776777
	dc.l	$77777777,$77777777,$77777777,$77777777
	dc.l	-1
efx	dc.w	0
fade	dc.w	0
old_fx	dc.l	fxs
fxs	dc.b	12,13,14,15,16,17,18,19,18,17,16,15,14,13,12,1,2,3,4,5,6,7,8,7,6,5,4,3,2,9,1,2,3,4,5,6,7,10,20,21,22,23,24,25,26,27,26,25,24,23,22,21,20,7,6,5,4,3,2,1,11,11
	dc.b	0
	even
flag	dc.w	0
screen	ds.l	2
offset	ds.l	17
adtro_log	incbin	a:\adtro.log
current_sinus	dc.w	0
	dc.w	0
sinus	incbin	a:\boing.dat
display	include	include.s
	rts

	end