adtro_adress	=	$60000

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.b	$ffff8260.w
	lea	old_sp(pc),a0
	move.l	a7,2(a0)
	lea	new_sp(pc),a7

	move.l	$44e.w,a0
	move	#7999,d7
cls	clr.l	(a0)+
	dbne	d7,cls

	move	#$7,$ffff8240.w
	jsr	premove_logo(pc)
	move	#$777,$ffff8240.w
	move	#$0,$ffff8242.w
	move	#$0,$ffff8246.w

	lea	offset(pc),a0

	move	#$f,d6
loop_total	move.l	(a0)+,a2
	lea	2(a2),a2
	move.l	$44e.w,a1

	move	#133,d7
loop_display	move	(a2)+,(a1)
	move	(a2)+,8(a1)
	move	(a2)+,16(a1)
	move	(a2)+,24(a1)
	move	(a2)+,32(a1)
	move	(a2)+,40(a1)
	move	(a2)+,48(a1)
	move	(a2)+,56(a1)
	move	(a2)+,64(a1)
	move	(a2)+,72(a1)
	move	(a2)+,80(a1)
	move	(a2)+,88(a1)
	move	(a2)+,96(a1)
	move	(a2)+,104(a1)
	move	(a2)+,112(a1)
	move	(a2)+,120(a1)
	move	(a2)+,128(a1)
	move	(a2)+,136(a1)
	move	(a2)+,144(a1)
	move	(a2)+,152(a1)
	lea	2(a2),a2
	lea	160(a1),a1
	dbf	d7,loop_display
	dbf	d6,loop_total

wait_key	cmpi.b	#$b9,$fffffc02.w
	bne.s	wait_key
exit

old_sp	move.l	#0,a7

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

	ds.l	128
new_sp

premove_logo	move.l	#adtro_adress,a1
	lea	offset(pc),a2

	move	#$f,d7
.loop_premove	move	d7,d5
	eori	#$f,d5
	move.l	a1,(a2)+
	lea	adtro_log(pc),a0
	move	#133,d6

.loop_line	moveq	#0,d0
	move	40(a0),d0
	lsl.l	d5,d0
	move	d0,42(a1)
	swap	d0
	move	d0,40(a1)
	moveq	#0,d0
	move	38(a0),d0
	lsl.l	d5,d0
	or	d0,40(a1)
	swap	d0
	move	d0,38(a1)
	moveq	#0,d0
	move	36(a0),d0
	lsl.l	d5,d0
	or	d0,38(a1)
	swap	d0
	move	d0,36(a1)
	moveq	#0,d0
	move	34(a0),d0
	lsl.l	d5,d0
	or	d0,36(a1)
	swap	d0
	move	d0,34(a1)
	moveq	#0,d0
	move	32(a0),d0
	lsl.l	d5,d0
	or	d0,34(a1)
	swap	d0
	move	d0,32(a1)
	moveq	#0,d0
	move	30(a0),d0
	lsl.l	d5,d0
	or	d0,32(a1)
	swap	d0
	move	d0,30(a1)
	moveq	#0,d0
	move	28(a0),d0
	lsl.l	d5,d0
	or	d0,30(a1)
	swap	d0
	move	d0,28(a1)
	moveq	#0,d0
	move	26(a0),d0
	lsl.l	d5,d0
	or	d0,28(a1)
	swap	d0
	move	d0,26(a1)
	moveq	#0,d0
	move	24(a0),d0
	lsl.l	d5,d0
	or	d0,26(a1)
	swap	d0
	move	d0,24(a1)
	moveq	#0,d0
	move	22(a0),d0
	lsl.l	d5,d0
	or	d0,24(a1)
	swap	d0
	move	d0,22(a1)
	moveq	#0,d0
	move	20(a0),d0
	lsl.l	d5,d0
	or	d0,22(a1)
	swap	d0
	move	d0,20(a1)
	moveq	#0,d0
	move	18(a0),d0
	lsl.l	d5,d0
	or	d0,20(a1)
	swap	d0
	move	d0,18(a1)
	moveq	#0,d0
	move	16(a0),d0
	lsl.l	d5,d0
	or	d0,18(a1)
	swap	d0
	move	d0,16(a1)
	moveq	#0,d0
	move	14(a0),d0
	lsl.l	d5,d0
	or	d0,16(a1)
	swap	d0
	move	d0,14(a1)
	moveq	#0,d0
	move	12(a0),d0
	lsl.l	d5,d0
	or	d0,14(a1)
	swap	d0
	move	d0,12(a1)
	moveq	#0,d0
	move	10(a0),d0
	lsl.l	d5,d0
	or	d0,12(a1)
	swap	d0
	move	d0,10(a1)
	moveq	#0,d0
	move	8(a0),d0
	lsl.l	d5,d0
	or	d0,10(a1)
	swap	d0
	move	d0,8(a1)
	moveq	#0,d0
	move	6(a0),d0
	lsl.l	d5,d0
	or	d0,8(a1)
	swap	d0
	move	d0,6(a1)
	moveq	#0,d0
	move	4(a0),d0
	lsl.l	d5,d0
	or	d0,6(a1)
	swap	d0
	move	d0,4(a1)
	moveq	#0,d0
	move	2(a0),d0
	lsl.l	d5,d0
	or	d0,4(a1)
	swap	d0
	move	d0,2(a1)
	moveq	#0,d0
	move	(a0),d0
	lsl.l	d5,d0
	or	d0,2(a1)
	swap	d0
	move	d0,(a1)
	lea	40(a0),a0
	lea	42(a1),a1

	dbf	d6,.loop_line

	dbf	d7,.loop_premove
	
	rts

offset	ds.l	16
adtro_log	incbin	a:\adtro.log
		end