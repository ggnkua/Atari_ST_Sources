 	* code by Larry Lamer
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	lea 6(sp),sp
	move.w #0,-(sp)
	pea $78000
	pea $78000
	move.w #5,-(sp)
	trap #14
	lea 12(sp),sp
	move.l #$ffff8240,a0
	move.l #$07770077,(a0)+
	move.l #$00670057,(a0)+
	move.l #$00470037,(a0)+
	move.l #$00270017,(a0)+
	move.l #$00070006,(a0)+
	move.l #$00050004,(a0)+
	move.l #$00030002,(a0)+
	move.l #$00010000,(a0)
	move.l d0,oldssp
	move.l $4da,oldint
	moveq	#1,d0
	jsr	musak
	move.l	#musak+8,$4da
demo	bsr ekal
	bsr ekal2
	bsr ekal3
	move.w #$00ff,-(sp)
	move.w #6,-(sp)
	trap #1
	lea 4(sp),sp
	cmp.w #32,d0
	beq end
	bne demo

end	move.l #$ffff8240,a0
	move.l #$07770000,(a0)+
	move.l #$00000000,(a0)+
	move.l	oldint,$4da
	move.l  oldssp,d0
	move.w #32,-(sp)
	trap #1
	lea 6(sp),sp

	clr.w	-(a7)
	trap	#1

ekal	lea	$ffff8800.w,a2
	move.b	#0,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+48,a0
	jsr	draw
	move.b	#2,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+56,a0
	jsr	draw
	move.b	#4,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+64,a0
draw
	add.l	ecran2,a0
	lsl.w	#2,d0
	move.w	#$3c,d1
	sub.w	d0,d1
	move.l	#$98,d2
	lea	egalise,a1
	tst.w	d1
	beq	l28202
	subq.w	#1,d1
l281f8	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	adda.l	d2,a0
	dbf	d1,l281f8
l28202	tst.w	d0
	beq.s	return
	lea	496(a1),a1		;default 504 /16*63
	subq.w	#1,d0			
l28216	move.l	(a1)+,(a0)+		
	move.l	(a1)+,(a0)+		
	adda.l	d2,a0			
	dbf	d0,l28216	
return	rts				

ekal2	lea	$ffff8800.w,a2
	move.b	#5,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+72,a0
	jsr	draw2
	move.b	#6,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+80,a0
	jsr	draw2
	move.b	#7,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+88,a0
draw2
	add.l	ecran2,a0
	lsl.w	#2,d0
	move.w	#$3c,d1
	sub.w	d0,d1
	move.l	#$98,d2
	lea	egalise,a1
	tst.w	d1
	beq	l282022
	subq.w	#1,d1
l281f82	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	adda.l	d2,a0
	dbf	d1,l281f82
l282022	tst.w	d0
	beq.s	return2
	lea	496(a1),a1		;default 504 /16*63
	subq.w	#1,d0			
l282162	move.l	(a1)+,(a0)+		
	move.l	(a1)+,(a0)+		
	adda.l	d2,a0			
	dbf	d0,l282162	
return2	rts				

ekal3	lea	$ffff8800.w,a2
	move.b	#8,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+96,a0
	jsr	draw3
	move.b	#9,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+104,a0
	jsr	draw3
	move.b	#$a,(a2)
	move.b	(a2),d0
	andi.w	#$f,d0
	movea.l	#18*160+112,a0
draw3
	add.l	ecran2,a0
	lsl.w	#2,d0
	move.w	#$3c,d1
	sub.w	d0,d1
	move.l	#$98,d2
	lea	egalise,a1
	tst.w	d1
	beq	l282023
	subq.w	#1,d1
l281f83	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	adda.l	d2,a0
	dbf	d1,l281f83
l282023	tst.w	d0
	beq.s	return3
	lea	496(a1),a1		;default 504 /16*63
	subq.w	#1,d0			
l282163	move.l	(a1)+,(a0)+		
	move.l	(a1)+,(a0)+		
	adda.l	d2,a0			
	dbf	d0,l282163	
return3	rts				

egalise	incbin "a:xtraequa.obj"
ecran2	dc.l $78000
musak	incbin "ancool4.b"
oldssp	dc.l 0
oldint	dc.l 0
