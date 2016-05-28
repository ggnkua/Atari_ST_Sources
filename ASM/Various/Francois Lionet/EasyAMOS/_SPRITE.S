;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* SPRITES/SOURIS
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

***********************************************************
*	UPDATE et assimiles

******* BOB UPDATE
BUpOf:	bclr	#5,ActuMask(a5)
	bra	InsRet
BUpOn:	bset	#5,ActuMask(a5)
	bra	InsRet
BUpDa:	movem.l	a3-a6,-(sp)		* Bobs
	SyCall	EffBob
	SyCall	ActBob
	SyCall	AffBob
	EcCall	SwapScS
	movem.l	(sp)+,a3-a6
	bra	InsRet

***********************************************************
*	BOB a la main!
BbClr:	
*******
	movem.l	a3-a6,-(sp)
	SyCall	EffBob
	movem.l	(sp)+,a3-a6
	bra	InsRet
*******
BbDrw:	movem.l	a3-a6,-(sp)
	SyCall	ActBob
	SyCall	AffBob
	movem.l	(sp)+,a3-a6
	bra	InsRet

***********************************************************
*	LIMIT BOB [numero,],x,y to x,y
LBob0:
*******	
	move.l	#EntNul,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	moveq	#-1,d1
	bra.s	LBob1
LBob5:
********
	bsr	Expentier
	move.l	d3,-(a3)
	addq.l	#2,a6
	bra.s	LBob
LBob4:	
********
	move.l	#-1,-(a3)
LBob:	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
LBob1:	SyCall	LimBob
	beq	InsRet
	bra	FonCall

***********************************************************
*	PRIORITY (REVERSE) ON/OFF
IPrOn	moveq	#1,d1
	bra.s	IPrOo
IPrOf	moveq	#0,d1
IPrOo	moveq	#-1,d2
	bra.s	IPrOoo
IPrROn	moveq	#1,d2
	bra.s	IPrROo
IPrROf	moveq	#0,d2
IPrROo	moveq	#-1,d1
IPrOoo	tst.w	ScOn(a5)
	beq	ScNOp
	SyCall	SPrio
	bra	InsRet

***********************************************************
*	=XY BOB(n)
FXBob:	bsr	FnExpE
	move.l	d3,d1
	bmi	FonCall
	SyCall	XYBob
	bne	FonCall
	move.w	d1,d3
	ext.l	d3
	moveq	#0,d2
	bra	OpeRet
FYBob:	bsr	FnExpE
	move.l	d3,d1
	bmi	FonCall
	SyCall	XYBob
	bne	FonCall
	move.w	d2,d3
	ext.l	d3
	moveq	#0,d2
	bra	OpeRet

***********************************************************
*	=I BOB / I SPRITE
FIBb:	bsr	FnExpE
	move.l	d3,d1
	bmi	FonCall
	SyCall	XYBob
	bne	FonCall
	ext.l	d3
	moveq	#0,d2
	bra	OpeRet

***********************************************************
*	=X / Y MOUSE
XMou:	SyCall	XyMou
	move.w	d1,d3
	ext.l	d3
	moveq	#0,d2
	bra	OpeRet
YMou:	SyCall	XyMou
	move.w	d2,d3
	ext.l	d3
	moveq	#0,d2
	bra	OpeRet
***********************************************************
*	X / Y MOUSE=
SXMou	bsr	FnExpE
	move.l	d3,d1
	move.l	#EntNul,d2
	bra.s	SXYMou
SYMou	bsr	FnExpE
	move.l	d3,d2
	move.l	#EntNul,d1
SXYMou	SyCall	SetM
	bra	InsRet
***********************************************************
*	=MOUSEKEY
MouK:	SyCall	MouseKey
MouK1	moveq	#0,d3
	move.w	d1,d3
	moveq	#0,d2
	bra	OpeRet
MouKR	SyCall	MouRel
	bra.s	MouK1
***********************************************************
*	HIDE ON HIDE
IHidO:	SyCalD	Hide,-1
	bra	InsRet
IHide:	SyCalD	Hide,0
	bra	InsRet
***********************************************************
*	SHOW ON SHOW
IShoO:	SyCalD	Show,-1
	bra	InsRet
IShow:	SyCalD	Show,0
	bra	InsRet
***********************************************************
*	LIMIT MOUSE
ILimM0	moveq	#0,d1
ILimM2	tst.w	ScOn(a5)
	beq	ScNOp
	SyCall	LimitMEc
	beq	InsRet
	bne	EcWiErr
ILimM1	bsr	Expentier
	move.l	d3,d1
	bmi	FonCall
	addq.l	#1,d1
	cmp.l	#8,d1
	bhi	ILimM2
	bra	FonCall
ILimM4	tst.w	ScOn(a5)
	beq	ScNOp
	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	SyCall	LimitM
	bra	InsRet
	
***********************************************************
*	CHANGE MOUSE n
ChMou:	
*******
	bsr	Expentier
	subq.l	#1,d3
	bmi	FonCall
	move.l	d3,d1
	SyCall	ChangeM
	bra	InsRet

***********************************************************
*	SET BOB n,back,planes,minterm
IStBb	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d7
	move.l	(a3)+,d6
	move.l	(a3)+,d5
	move.l	#EntNul,d4
	move.l	d4,d3
	move.l	d3,d2
	move.l	(a3)+,d1
	cmp.l	d4,d7
	bne.s	IStb1
	moveq	#0,d7
IStb1	cmp.l	d4,d6
	bne.s	IStb2
	moveq	#-1,d6
IStb2	cmp.l	d4,d5
	bne.s	IStb3
	moveq	#0,d5
IStb3	bra.s	BbSt
***********************************************************
*	BOB n,x,y,a
BbSt4:	
********
	moveq	#4,d0
	bsr	ParD0
	moveq	#0,d7
	moveq	#-1,d6
	moveq	#0,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
BbSt	tst.w	ScOn(a5)
	beq	ScNOp
	SyCall	SetBob
	beq	InsRet	
	bmi	OOfMem
	bra	FonCall


***********************************************************
*	BOB OFF x
BbOff1:	
********
	bsr	Expentier
	move.l	d3,d1
	SyCall	OffBob
	bra	InsRet

***********************************************************
*	BOB OFF
BbOff0:
*******
	SyCall	OffBobS
	bra	InsRet

* Entree erreurs sprites
SpErr:	add.w	#SpEBase,d0
	bra	RunErr	

***********************************************************
*	= BOB COL(n[,x to y])
IBbCol1	bsr	FnExpE
	move.l	d3,d1
	bmi	FonCall
	moveq	#0,d2
	move.l	#10000,d3
	bra.s	IbbCo
IBbCol3	moveq	#3,d0
	bsr	FnParD0
	move.l	(a3)+,d3
	bmi	FonCall
	move.l	(a3)+,d2
	bmi	FonCall
	move.l	(a3)+,d1
	bmi	FonCall
IBbCo:	SyCall	ColBob
	move.l	d0,d3
	moveq	#0,d2
	bra	OpeRet

***********************************************************
*	= COL(n)
FnColl:	bsr	FnExpE
	move.l	d3,d1
	SyCall	ColGet
	move.l	d0,d3
	moveq	#0,d2
	bra	OpeRet

AAdBob	bsr	AdBob
	bne	RunErr
	rts
******* NO MASK [n]
NoMask0:moveq	#1,d1
	bsr	AAdBob
NoM0	subq.w	#1,d7
	bra.s	NoMa1
NoMask1:bsr	Expentier
	move.l	d3,d1
	bsr	AAdBob
NoM1	moveq	#0,d7
NoMa1:	tst.l	(a2)
	beq.s	NoMa3
	tst.l	4(a2)
	ble.s	NoMa2
	move.l	4(a2),a1
	move.l	(a1),d0
	jsr	RamFree
NoMa2:	move.l	#$C0000000,4(a2)
NoMa3:	addq.l	#8,a2
	dbra	d7,NoMa1
	bra	InsRet

***********************************************************
*	HOT SPOT n,x,y / n,x
HotSp3:	moveq	#3,d0
	bsr	ParD0
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	moveq	#0,d1
	bra.s	HotSp
HotSp2:	bsr	Par2
	move.l	(a3)+,d1
	and.w	#%01110111,d1
	addq.w	#1,d1
HotSp:	movem.w	d1-d3,-(sp)
	move.l	(a3)+,d1
	bsr	AAdBob
	movem.w	(sp)+,d1-d3
	SyCall	SpotHot
	beq	InsRet
	bra	FonCall

***********************************************************
*	GET SPRITE/BOB [sc,]n,x,y to x,y
GetSp6:	bsr	Expentier
	move.l	d3,d1
	EcCall	AdrEc
	beq	ScNOp
	move.l	d0,-(sp)
	addq.l	#2,a6
	bra.s	GetSp0
GetSp5:	move.l	ScOnAd(a5),-(sp)
	beq	ScNOp
GetSp0:	moveq	#5,d0
	bsr	ParD0
	move.l	(sp),a0
	bsr	Ritoune
* Adresse du descripteur --> A2
	moveq	#0,d0			* Ne pas effacer
	bsr	ResSpr
	bne	OOfMem
	bsr	EfPointe
* Appelle la trappe
	move.l	(sp)+,a1		* Ecran en A1
	SyCall	SprGet
	beq	InsRet
	bne	OOfMem
GetIc0:	moveq	#5,d0
	bsr	ParD0
	move.l	(sp),a0
	bsr	Ritoune
* Adresse du descripteur --> A2
	moveq	#0,d0			* Ne pas effacer
	bsr	ResIco
	bne	OOfMem
	bsr	EfPointe
* Appelle la trappe
	move.l	(sp)+,a1		* Ecran en A1
	SyCall	SprGet
	bne	OOfMem
	move.l	#$C0000000,4(a2)	* Pas de masque!
	bra	InsRet
******* Calcule taille
Ritoune	move.l	(a3)+,d5
	bmi	FonCall
	move.l	(a3)+,d4
	bmi	FonCall
	move.l	(a3)+,d3
	bmi	FonCall
	move.l	(a3)+,d2
	bmi	FonCall
	move.l	(a3)+,d1
	bls	FonCall
* Calcule taille
	cmp.w	EcTx(a0),d4
	bhi	FonCall
	move.w	d4,d6
	cmp.w	EcTy(a0),d5
	bhi	FonCall
	sub.w	d2,d4
	bls	FonCall
	sub.w	d3,d5
	bls	FonCall
	rts

*******************************************************
*	Fonctions retournement
FRevX	bsr	FnExpE
	bset	#15,d3
	moveq	#0,d2
	bra	OpeRet
FRevY	bsr	FnExpE
FRv	bset	#14,d3
	moveq	#0,d2
	bra	OpeRet
FRev	bsr	FnExpE
	bset	#15,d3
	bra.s	FRv
***********************************************************
*	PATCH BOB x,y,n
PatBb
*******
	moveq	#3,d0
	bsr	ParD0
	move.l	(a3),d1
	bmi	FonCall	
	bsr	AdBob
	bne	RunErr
	tst.l	(a2)
	beq.s	PatBbe
PatIc1	move.l	(a3)+,d1
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	BufBob(a5),a1
	moveq	#0,d4
	moveq	#-1,d5
	SyCall	Patch
	bra	InsRet
PatBbe	moveq	#24,d0
	bra	EcWiErr
***********************************************************
*	=SPRITE BASE(n)
*	=ICON BASE(n)
FSBase	pea	AdBob(pc)
FsBi	bsr	FnExpE
	move.l	d3,d1
	bpl	FsBi1
	neg.l	d1
FsBi1	move.l	(sp)+,a0
	jsr	(a0)
	bne	RunErr
	tst.l	d3
	bpl.s	FsBi2
	addq.l	#4,a2
FsBi2	move.l	(a2),d3
	moveq	#0,d2
	bra	OpeRet



