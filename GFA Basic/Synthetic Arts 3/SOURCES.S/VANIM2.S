*_TEST
	IFND _TEST
	OUTPUT e:\code\synthy.art\curent\fichiers.inl\video.inl
	OPT O+,W-,P+
	ENDC
	
TestEnd	MACRO
	moveq	#-95,d0
	and.b	$fffffc00.w,d0
	beq	.NoKey\@
	move.b	$fffffc02.w,d0
	cmp.b	#$39,d0
	beq	ExitLoop
.NoKey\@
	ENDM

	IFD _TEST
	move.w	#1,-(sp)
	pea	TestPtr
	bsr	VideoClic
	addq.l	#6,sp
	clr.w	-(sp)
	trap	#1
	ENDC
	
VideoClic	lea	4(sp),a6
	pea	Super(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	d7,d0
	rts
	
FakeIrq	subq.w	#1,d7
	rte
	
Super	move.w	#$2700,sr
	move.l	$ffff8200.w,-(sp)
	move.l	$fffffa06.w,-(sp)
	move.l	$70.w,-(sp)
	move.w	$ffff8260.w,-(sp)

	clr.l	$fffffa06
	lea	FakeIrq(pc),a0
	move.l	a0,$70.w
	lea	$fa0021,a0
	lea	$fb0020,a1

	stop	#$2300
	stop	#$2300
	clr.b	$ffff8260.w

	move.l	(a6),a5	
***********	Boucle d'acquisition
.SyncOne	TestEnd
	tst.b	(a0)
	bpl	.SyncOne
.SyncTwo	TestEnd
	tst.b	(a0)
	IFND _TEST
	bmi	.SyncTwo
	ENDC
	stop	#$2300
	moveq	#0,d7	
MainLoop	tst.w	d7
	bne.s	MainLoop
	moveq	#2,d7
.SyncOne	TestEnd
	tst.b	(a0)
	bpl	.SyncOne
.SyncTwo	TestEnd
	tst.b	(a0)
	IFND _TEST
	bmi	.SyncTwo
	ENDC
	move.l	(a5)+,d0
	bne.s	.Skip
	tst.w	4(a6)
	beq.s	ExitLoop
	move.l	(a6),a5
	move.l	(a5)+,d0
.Skip	move.l	d0,a3
	move.w	d0,-(sp)
	move.b	(sp)+,d0
	move.l	d0,$ffff8200.w
	bsr	GetPicture
	bra	MainLoop
	
***********	Fin de la boucle
ExitLoop	stop	#$2300
	move.w	#$2700,sr
	move.w	(sp)+,$ff8260

FlushKBD	moveq	#-95,d1
	and.b	$fffffc00.w,d1
	beq	.EndFlush
	move.b	$fffffc02.w,d1
	bra	FlushKBD

.EndFlush	move.l	(sp)+,$70.w
	move.l	(sp)+,$fffa06
	move.l	(sp)+,$ffff8200.w
	move.w	#$2300,sr
	sub.l	(a6),a5
	move.l	a5,d7
	lsr.w	#2,d7
	subq.w	#1,d7
	rts

GetPicture	bsr	GetSub1
	bsr	GetSub1
	bsr	WaitData
	rts
GetSub1	REPT 8
	bsr	GetSub2
	ENDR
	rts
GetSub2	bsr	GetSub3
	bsr	GetSub3
	rts
GetSub3	REPT 250
	move.l	(a1),(a3)+
	ENDR
	rts
WaitData	REPT 192
	move.l	(a1),(a3)
	ENDR
	rts

	IFD _TEST
TestPtr	dc.l	grosgato,0
	ds.b	256
grosgato	dcb.l	8000,$eeee
	ENDC