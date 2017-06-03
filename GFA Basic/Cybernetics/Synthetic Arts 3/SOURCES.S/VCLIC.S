_TEST
	IFD _TEST
	OPT O+,W-
main	pea	pal
	move.w	#6,-(sp)
	trap	#14
	clr.w	-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	10(sp),sp
	addq.l	#6,sp
	lea	TestList(pc),a0
.loop	and.l	#$ffff00,(a0)+
	bne.s	.loop
	pea	TMPBuf(pc)
	move.w	#1,-(sp)		Intervalle en 1/24eme de s
	move.w	#1,-(sp)
	pea	TestList(pc)
	bsr	VideoClic
	addq.l	#8,sp
	cmp.w	#-1,d0
	bne.s	.Skip
	pea	.NoCard(pc)
	move.w	#9,-(sp)
	trap	#1
	move.w	#7,(sp)
	trap	#1
	addq.l	#6,sp
.Skip	move.w	#$22,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0
	clr.l	$6c(a0)
	move.w	#1,-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	10(sp),sp
	clr.w	-(sp)
	trap	#1
.NoCard	dc.b	27,"HAucun signal video en entr‚e",13,10,0
TestList	dc.l	Space1,Space2,Space3,Space4
	REPT 3
	dc.l	Space1,Space2,Space3,Space4
	dc.l	Space1,Space2,Space3,Space4
	dc.l	Space1,Space2,Space3,Space4
	dc.l	Space1,Space2,Space3,Space4
	dc.l	Space1,Space2,Space3,Space4
	ENDR
	dc.l	Space1,Space2,Space3,Space4,0
	ELSE	
	OPT O+,W-,P+,D-
	OUTPUT	e:\code\synthy.art\curent\fichiers.inl\video.inl
	ENDC

RETURN_VALUE=4+4+4+4+2+4+4
LIST_PTR=4+4+RETURN_VALUE
LOOP_MODE=8+4+RETURN_VALUE
ANIM_SPEED=10+4+RETURN_VALUE
TMP_BUFFER=12+4+RETURN_VALUE

VideoDeclic	MACRO	EndLabel
.SyncOne\@	tst.w	(a6)
	bne	\1
	move.b	(a0),d1
	bpl	.SyncOne\@
.SyncTwo\@	tst.w	(a6)
	bne	\1
	move.b	(a0),d1
	bmi	.SyncTwo\@
	ENDM

VideoClic	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	-1.w
	move.l	d0,-(sp)
	
	move.w	#$2700,sr
	move.b	#$13,$fffffc02.w
.FlushKBD	moveq	#-95,d0
	and.b	$fffffc00.w,d0
	beq.s	.EndFlush
	move.b	$fffffc02.w,d0
	bra.s	.FlushKBD
.EndFlush	move.l	$fffffa06.w,-(sp)
	move.l	$fffffa12.w,-(sp)
	move.b	$fffffa17.w,-(sp)
	move.l	$118.w,-(sp)	Vecteur ACIA
	move.l	$70.w,-(sp)		Vecteur VBL	
	move.l	$ffff8200.w,-(sp)

***********	Inits
	lea	MyVBL(pc),a0
	move.l	a0,$70.w
	lea	MyKBDIrq(pc),a0
	move.l	a0,$118.w
	bset	#3,$fffffa17.w
	moveq	#$40,d0
	move.l	d0,$fffffa06.w
	move.l	d0,$fffffa12.w
	lea	VarBase(pc),a6
	move.l	a6,a0
	moveq	#VarLength/2-1,d0
.clear	clr.w	(a0)+
	dbf	d0,.clear
	move.b	#$11,$fffffc02.w
	stop	#$2300
	stop	#$2300

	move.l	TMP_BUFFER(sp),a0
	move.l	#$34d134d1,d1
	move	#7999,d0
.copy1	move.l	d1,(a0)+
	dbf	d0,.copy1
	move.l	#$30113011,d1
	move	#768/4-1,d0
.copy2	move.l	d1,(a0)+
	dbf	d0,.copy2
	move.w	#$4e75,(a0)+

	lea	$fa0021,a0
	lea	$fb0020,a1
	move.w	#60*2,VBLCount(a6)
	st	TestMode(a6)
	
***********	Synchro avec la carte
	VideoDeclic	ExitVideo

	clr.w	TestMode(a6)
	move.l	LIST_PTR(sp),a5
	clr.l	CurrentPtr(a6)
	tst.l	(a5)
	beq	ExitLoop
	
MainLoop	move.l	(a5),a2
	move.w	ANIM_SPEED(sp),d6
.Sync	tst.w	(a6)
	bne	ExitLoop

	VideoDeclic	ExitLoop
	subq.w	#1,d6
	bne.s	.Sync
	move.l	TMP_BUFFER(sp),a3
	jsr	(a3)

	move.l	a5,CurrentPtr(a6)
	move.l	(a5)+,d0
	tst.l	(a5)
	bne.s	.Cont
	tst.w	LOOP_MODE(sp)
	beq.s	ExitLoop
	move.l	LIST_PTR(sp),a5
.Cont	move.l	d0,Logic(a6)
	tst.w	(a6)
	beq	MainLoop

***********	Fin d'acquisition
ExitLoop	clr.l	$fffffa06.w
	move.w	#-2,RETURN_VALUE+2(sp)
	move.l	CurrentPtr(a6),d0
	beq.s	ExitVideo
	sub.l	LIST_PTR(sp),d0
	lsr.w	#2,d0
	move.l	d0,RETURN_VALUE(sp)
			
ExitVideo	stop	#$2300
	move.l	(sp)+,$ffff8200.w

***********	Restore
	move.w	#$2700,sr
	move.b	#$13,$fffffc02.w
.FlushKBD	moveq	#-95,d0
	and.b	$fffffc00.w,d0
	beq.s	.EndFlush
	move.b	$fffffc02.w,d0
	bra.s	.FlushKBD
.EndFlush	move.l	(sp)+,$70.w
	move.l	(sp)+,$118.w
	move.b	(sp)+,$fffffa17.w
	move.l	(sp)+,$fffffa12.w
	move.l	(sp)+,$fffffa06.w
	move.b	#$11,$fffffc02.w
	move.w	#$2300,sr

	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp		
	move.l	(sp)+,d0
	rts

***********	Interruptions
MyVBL	move.l	d0,-(sp)
	subq.w	#1,VBLCount(a6)
	bne.s	.Cont
	tst.w	TestMode(a6)
	beq.s	.Cont
	st	(a6)	
.Cont	tst.l	Logic(a6)
	beq.s	.Skip
	move.l	Physic(a6),d0
	move.l	Logic(a6),Physic(a6)
	tst.l	d0
	beq.s	.Skip
	move.w	d0,-(sp)
	move.b	(sp)+,d0
	move.l	d0,$ffff8200.w
.Skip	move.l	(sp)+,d0
	rte

MyKBDIrq	move.w	d0,-(sp)
	move.l	d1,-(sp)
.Kbd	moveq	#-95,d1
	and.b	$fffffc00.w,d1
	beq.s	.kbdend
	move.b	$fffffc02.w,d0
	tst.w	MouseFlag(a6)
	bne.s	.Mouse
	moveq	#-4,d1
	and.w	d0,d1
	cmp.b	#$f8,d1
	bne.s	.Key
	move.w	#2,MouseFlag(a6)
	sub.b	d1,d0
	beq.S	.kbdend
	st	(a6)
	bra.s	.kbdend
.Mouse	subq.w	#1,MouseFlag(a6)
	bra.s	.kbdend
.Key	move.b	d0,Key(a6)
	bclr	#7,d0
	cmp.b	#$39,d0
	bne.s	.kbdend
	st	(a6)
.kbdend	bclr	#6,$fffffa11.w
	move.l	(sp)+,d1
	move.w	(sp)+,d0
	rte
	
	RSRESET
EndFlag	rs.w	1
Physic	rs.l	1
Logic	rs.l	1
CurrentPtr	rs.l	1
VBLCount	rs.w	1
MouseFlag	rs.w	1
*MouseX	rs.w	1
*MouseY	rs.w	1
*MouseK	rs.w	1
Key	rs.w	1
TestMode	rs.w	1
VarLength	rs.w	1
	SECTION DATA
VarBase	ds.b	VarLength

	IFD _TEST
pal:	dc.w	$000,$888,$111,$999,$222,$aaa,$333,$bbb,$444,$ccc,$555,$ddd,$666,$eee,$777,$fff
	SECTION BSS
TMPBuf	ds.w	16000+768/2+1
	ds.b	256
Space1	ds.l	8000
Space2	ds.l	8000
Space3	ds.l	8000
Space4	ds.l	8000
	ENDC