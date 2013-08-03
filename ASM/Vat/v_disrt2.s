	opt	x+
	lea	$7fffe,a7
	bsr	Rez
Loop
	move.w	#$111,$ffff8240.w
	bsr	Vert_Disort
	move.w	#0,$ffff8240.w
	bsr	Vbl
	bra.s	Loop

Vert_Disort
	lea	SinCnt(pc),a0
	*lea	Kwadrat(pc),a1
	lea	Trkjt(pc),a1
	lea	SINUS(pc),a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#1,d5
	move.w	#$8000,d6
	move.w	(a0),d0
	move.b	(a2,d0.w),d1
	move.b	16*8-2(a2,d0.w),d2
	cmp.b	#-1,d2
	bne.s	NotNxt
	move.w	d3,(a0)
	move.b	(a2),d1
NotNxt	lea	DSRT(pc),a4
	lea	(a4),a5
	addq.w	#1,a2
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
FIRST	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
GetNew
	moveq	#14,d7
OTHERS	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS
DoItNow	lea	$78000,a4
	bsr	DoOnScr

GetNew2	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRST2	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERS2	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS2
	lea	$78008,a4
	bsr	DoOnScr
GetNew3	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRST3	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERS3	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS3
	lea	$78010,a4
	bsr	DoOnScr
GetNew4	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRST4	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERS4	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS4
	lea	$78018,a4
	bsr	DoOnScr
GetNew5	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRST5	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERS5	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS5
	lea	$78020,a4
	bsr	DoOnScr
GetNew6	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRST6	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERS6	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS6
	lea	$78028,a4
	bsr	DoOnScr

GetNew7	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRST7	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERS7	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS7
	lea	$78030,a4
	bsr	DoOnScr

GetNew8	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRST8	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERS8	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS8
	lea	$78038,a4
	bsr	DoOnScr

GetNew9	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRST9	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERS9	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERS9
	lea	$78040,a4
	bsr	DoOnScr

GetNewA	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
FIRSTA	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	move.l	d3,(a4)+
	endr
	ror.w	d5,d6
	moveq	#14,d7
OTHERSA	move.b	(a2,d0.w),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a1),a3
	add.w	d1,a3
	lea	(a5),a4
	rept	8
	move.l	(a3)+,d3
	and.w	d6,d3
	swap	d3
	and.w	d6,d3
	swap	d3
	or.l	d3,(a4)+
	endr
	ror.w	d5,d6
	addq.w	#1,a2
	dbf	d7,OTHERSA
	lea	$78048,a4
	bsr	DoOnScr

	addq.w	#1,SinCnt
	rts

DoOnScr
	movem.l	d0-d3/a0-a3,-(a7)
	movem.l	(a5),d0-d3/a0-a3
	move.l	d0,(a4)
	move.l	d0,8*160(a4)
	move.l	d0,16*160(a4)
	move.l	d0,24*160(a4)
	move.l	d0,32*160(a4)
	move.l	d0,40*160(a4)
	move.l	d0,48*160(a4)
	move.l	d0,56*160(a4)
	move.l	d0,64*160(a4)
	move.l	d0,72*160(a4)
	move.l	d0,80*160(a4)
	move.l	d0,88*160(a4)
	move.l	d0,96*160(a4)
	move.l	d0,104*160(a4)
	move.l	d0,112*160(a4)
	move.l	d0,120*160(a4)
	move.l	d0,128*160(a4)
	move.l	d0,136*160(a4)
	move.l	d0,144*160(a4)
	move.l	d0,152*160(a4)
	move.l	d0,160*160(a4)
	move.l	d0,168*160(a4)
	move.l	d0,176*160(a4)
	move.l	d0,184*160(a4)
	move.l	d0,192*160(a4)
	lea	160(a4),a4
	move.l	d1,(a4)
	move.l	d1,8*160(a4)
	move.l	d1,16*160(a4)
	move.l	d1,24*160(a4)
	move.l	d1,32*160(a4)
	move.l	d1,40*160(a4)
	move.l	d1,48*160(a4)
	move.l	d1,56*160(a4)
	move.l	d1,64*160(a4)
	move.l	d1,72*160(a4)
	move.l	d1,80*160(a4)
	move.l	d1,88*160(a4)
	move.l	d1,96*160(a4)
	move.l	d1,104*160(a4)
	move.l	d1,112*160(a4)
	move.l	d1,120*160(a4)
	move.l	d1,128*160(a4)
	move.l	d1,136*160(a4)
	move.l	d1,144*160(a4)
	move.l	d1,152*160(a4)
	move.l	d1,160*160(a4)
	move.l	d1,168*160(a4)
	move.l	d1,176*160(a4)
	move.l	d1,184*160(a4)
	move.l	d1,192*160(a4)
	lea	160(a4),a4
	move.l	d2,(a4)
	move.l	d2,8*160(a4)
	move.l	d2,16*160(a4)
	move.l	d2,24*160(a4)
	move.l	d2,32*160(a4)
	move.l	d2,40*160(a4)
	move.l	d2,48*160(a4)
	move.l	d2,56*160(a4)
	move.l	d2,64*160(a4)
	move.l	d2,72*160(a4)
	move.l	d2,80*160(a4)
	move.l	d2,88*160(a4)
	move.l	d2,96*160(a4)
	move.l	d2,104*160(a4)
	move.l	d2,112*160(a4)
	move.l	d2,120*160(a4)
	move.l	d2,128*160(a4)
	move.l	d2,136*160(a4)
	move.l	d2,144*160(a4)
	move.l	d2,152*160(a4)
	move.l	d2,160*160(a4)
	move.l	d2,168*160(a4)
	move.l	d2,176*160(a4)
	move.l	d2,184*160(a4)
	move.l	d2,192*160(a4)
	lea	160(a4),a4
	move.l	d3,(a4)
	move.l	d3,8*160(a4)
	move.l	d3,16*160(a4)
	move.l	d3,24*160(a4)
	move.l	d3,32*160(a4)
	move.l	d3,40*160(a4)
	move.l	d3,48*160(a4)
	move.l	d3,56*160(a4)
	move.l	d3,64*160(a4)
	move.l	d3,72*160(a4)
	move.l	d3,80*160(a4)
	move.l	d3,88*160(a4)
	move.l	d3,96*160(a4)
	move.l	d3,104*160(a4)
	move.l	d3,112*160(a4)
	move.l	d3,120*160(a4)
	move.l	d3,128*160(a4)
	move.l	d3,136*160(a4)
	move.l	d3,144*160(a4)
	move.l	d3,152*160(a4)
	move.l	d3,160*160(a4)
	move.l	d3,168*160(a4)
	move.l	d3,176*160(a4)
	move.l	d3,184*160(a4)
	move.l	d3,192*160(a4)
	lea	160(a4),a4
	move.l	a0,(a4)
	move.l	a0,8*160(a4)
	move.l	a0,16*160(a4)
	move.l	a0,24*160(a4)
	move.l	a0,32*160(a4)
	move.l	a0,40*160(a4)
	move.l	a0,48*160(a4)
	move.l	a0,56*160(a4)
	move.l	a0,64*160(a4)
	move.l	a0,72*160(a4)
	move.l	a0,80*160(a4)
	move.l	a0,88*160(a4)
	move.l	a0,96*160(a4)
	move.l	a0,104*160(a4)
	move.l	a0,112*160(a4)
	move.l	a0,120*160(a4)
	move.l	a0,128*160(a4)
	move.l	a0,136*160(a4)
	move.l	a0,144*160(a4)
	move.l	a0,152*160(a4)
	move.l	a0,160*160(a4)
	move.l	a0,168*160(a4)
	move.l	a0,176*160(a4)
	move.l	a0,184*160(a4)
	move.l	a0,192*160(a4)
	lea	160(a4),a4
	move.l	a1,(a4)
	move.l	a1,8*160(a4)
	move.l	a1,16*160(a4)
	move.l	a1,24*160(a4)
	move.l	a1,32*160(a4)
	move.l	a1,40*160(a4)
	move.l	a1,48*160(a4)
	move.l	a1,56*160(a4)
	move.l	a1,64*160(a4)
	move.l	a1,72*160(a4)
	move.l	a1,80*160(a4)
	move.l	a1,88*160(a4)
	move.l	a1,96*160(a4)
	move.l	a1,104*160(a4)
	move.l	a1,112*160(a4)
	move.l	a1,120*160(a4)
	move.l	a1,128*160(a4)
	move.l	a1,136*160(a4)
	move.l	a1,144*160(a4)
	move.l	a1,152*160(a4)
	move.l	a1,160*160(a4)
	move.l	a1,168*160(a4)
	move.l	a1,176*160(a4)
	move.l	a1,184*160(a4)
	move.l	a1,192*160(a4)
	lea	160(a4),a4
	move.l	a2,(a4)
	move.l	a2,8*160(a4)
	move.l	a2,16*160(a4)
	move.l	a2,24*160(a4)
	move.l	a2,32*160(a4)
	move.l	a2,40*160(a4)
	move.l	a2,48*160(a4)
	move.l	a2,56*160(a4)
	move.l	a2,64*160(a4)
	move.l	a2,72*160(a4)
	move.l	a2,80*160(a4)
	move.l	a2,88*160(a4)
	move.l	a2,96*160(a4)
	move.l	a2,104*160(a4)
	move.l	a2,112*160(a4)
	move.l	a2,120*160(a4)
	move.l	a2,128*160(a4)
	move.l	a2,136*160(a4)
	move.l	a2,144*160(a4)
	move.l	a2,152*160(a4)
	move.l	a2,160*160(a4)
	move.l	a2,168*160(a4)
	move.l	a2,176*160(a4)
	move.l	a2,184*160(a4)
	move.l	a2,192*160(a4)
	lea	160(a4),a4
	move.l	a3,(a4)
	move.l	a3,8*160(a4)
	move.l	a3,16*160(a4)
	move.l	a3,24*160(a4)
	move.l	a3,32*160(a4)
	move.l	a3,40*160(a4)
	move.l	a3,48*160(a4)
	move.l	a3,56*160(a4)
	move.l	a3,64*160(a4)
	move.l	a3,72*160(a4)
	move.l	a3,80*160(a4)
	move.l	a3,88*160(a4)
	move.l	a3,96*160(a4)
	move.l	a3,104*160(a4)
	move.l	a3,112*160(a4)
	move.l	a3,120*160(a4)
	move.l	a3,128*160(a4)
	move.l	a3,136*160(a4)
	move.l	a3,144*160(a4)
	move.l	a3,152*160(a4)
	move.l	a3,160*160(a4)
	move.l	a3,168*160(a4)
	move.l	a3,176*160(a4)
	move.l	a3,184*160(a4)
	move.l	a3,192*160(a4)
	movem.l	(a7)+,d0-d3/a0-a3
	rts

Vbl
	move.l	$466.w,d0
VSync	cmp.l	$466.w,d0
	beq.s	VSync
	cmp.b	#$39,$fffffc02.w
	beq.s	Koniec
	move.l	ScreenA(pc),d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	rts
Koniec
	move.w	#$555,$ffff8240.w
	clr.l	-(a7)
	trap	#1
Rez
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.w	#6,a7
	dc.w	$a00a
	clr.w	-(a7)
	pea	$78000
	pea	$78000
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	lea	(Palette+4)(pc),a0
	lea	$ffff8242.w,a1
	clr.w	-2(a1)
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	lea	SINUS(pc),a0
Ktulu	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#-1,d0
	beq.s	Jupi
	divu	#8,d0
	swap	d0
	move.b	d0,(a0)+
	bra.s	Ktulu
Jupi	rts
ScreenA	dc.l	$78000
Palette	dc.w	$000,$200,$300,$400,$510,$620,$730,$740
	dc.w	$750,$760,$002,$013,$024,$035,$046,$057
Kwadrat	dc.l	$FFFFFFFF,$81817F7F
	dc.l	$81817F7F,$81817F7F
	dc.l	$81817F7F,$81817F7F
	dc.l	$81817F7F,$FFFF0101
	dc.l	$FFFFFFFF,$81817F7F
	dc.l	$81817F7F,$81817F7F
	dc.l	$81817F7F,$81817F7F
	dc.l	$81817F7F,$FFFF0101
Trkjt	dc.l	$FFFF0000,$99996666
	dc.l	$A5A54242,$DBDB1818
	dc.l	$DBDB1818,$A5A54242
	dc.l	$99996666,$FFFF0000
	dc.l	$FFFF0000,$99996666
	dc.l	$A5A54242,$DBDB1818
	dc.l	$DBDB1818,$A5A54242
	dc.l	$99996666,$FFFF0000
SinCnt	dc.w	0
DSRT	ds.l	16
SINUS
 ds.l	30
	rept	8
 dc.b 40,40,41,42,43,44,45,46,47,48
 dc.b 48,49,50,50,51,52,52,53,53,53
 dc.b 54,54,54,54,54,55,54,54,54,54
 dc.b 54,53,53,53,52,52,51,50,50,49
 dc.b 48,48,47,46,45,44,43,42,41,40
 dc.b 40,39,38,37,36,35,34,33,32,31
 dc.b 31,30,29,29,28,27,27,26,26,26
 dc.b 25,25,25,25,25,25,25,25,25,25
 dc.b 25,26,26,26,27,27,28,29,29,30
 dc.b 31,31,32,33,34,35,36,37,38,39
	endr
 ds.b 16*8
 dc.l -1
