
;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* ECRANS
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

******* DEFAULT
Defo:	jsr	DefRun
	jsr	ReCop
	jsr	DefRun2
	jsr	ReCop
	IfEq	ROnly
	move.w	#1,DefFlag(a5)
	EndC
	IfNE	ROnly
	move.w	#-2,DefFlag(a5)
	EndC
	bra	InsRet

******* CLS
ICls0:	tst.w	ScOn(a5)
	beq	ScNOp
	WiCall	ClsWi
	bra	InsRet
******* CLS Couleur
ICls1:	bsr	Expentier
	move.l	d3,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	#10000,d4
	move.w	d4,d5
	bra.s	ICls5a
******* CLS couleur,x,y TO x,y
ICls5:	moveq	#5,d0
	bsr	ParD0
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
ICls5a:	tst.w	ScOn(a5)
	beq	ScNOp
	EcCall	ClsEc
	bra	InsRet

******* SCREEN BASE
FnSBase	move.l	ScOnAd(a5),d3
	beq	ScNOp
	moveq	#0,d2
	bra	OpeRet
******* =LOGBASE(n)
FnLog:	bsr	FnExpE
	cmp.l	#6,d3
	bcc	FonCall
	move.l	ScOnAd(a5),d0
	beq	ScNOp
	move.l	d0,a0
	lsl.w	#2,d3
	move.l	EcLogic(a0,d3.w),d3
	moveq	#0,d2
	bra	OpeRet
******* =PHYBASE(n)
FnPhy:	bsr	FnExpE
	cmp.l	#6,d3
	bcc	FonCall
	move.l	ScOnAd(a5),d0
	beq	ScNOp
	move.l	d0,a0
	lsl.w	#2,d3
	move.l	EcPhysic(a0,d3.w),d3
	moveq	#0,d2
	bra	OpeRet

******* DOUBLE BUFFER
ScDble:	tst.w	ScOn(a5)
	beq	ScNOp
	EcCall	Double
	bne	EcWiErr
	bra	InsRet	

******* SCREEN SWAP
ScSwp0:	tst.w	ScOn(a5)
	beq	ScNOp
	EcCall	SwapScS
	bne	EcWiErr
	bra	InsRet
******* SCREEN SWAP n
ScSwp1:	bsr	Expentier
	cmp.l	#8,d3
	bcc	IllScN
	move.l	d3,d1
	EcCall	SwapSc
	bne	EcWiErr
	bra	InsRet

******* SCREEN CLONE n
ScClone:tst.w	ScOn(a5)
	beq	ScNOp
	bsr	ExPentier
	cmp.l	#8,d3
	bcc	IllScN
	move.l	d3,d1
	EcCall	CCloEc
	bne	EcWiErr
	bra	InsRet

******* SCREEN OPEN n,tx,ty,#couleurs,mode
ScOpen:	bsr	GetPar
	move.l	(a3)+,d5		* Mode
	and.l	#$8004,d5
* Ham?
	move.l	(a3)+,d6
	cmp.l	#4096,d6
	bne.s	ScOo0
	tst.w	d5			* Lowres only!
	bmi	FonCall
	moveq	#6,d4
	move.w	#$0800,d5
	moveq	#64,d6
	bra.s	ScOo2
* Nombre de couleurs-> plans
ScOo0:	moveq	#1,d4			* Nb de plans
	moveq	#2,d1
ScOo1:	cmp.l	d1,d6
	beq.s	ScOo2
	lsl.w	#1,d1
	addq.w	#1,d4
	cmp.w	#7,d4
	bcs.s	ScOo1
IlNCo:	moveq	#5,d0			* Illegal number of colours
	bra	EcWiErr
ScOo2:	move.l	(a3)+,d3		* TY
	move.l	(a3)+,d2		* TX
	move.l	(a3)+,d1		* Numero
	cmp.l	#8,d1
	bcc.s	IllScN
	tst.w	d5			* Si HIRES, pas plus de 16 couleurs
	bpl.s	ScOo3
	cmp.w	#4,d4
	bhi	FonCall	
ScOo3:	lea	DefPal(a5),a1
	EcCall	Cree
	bne	EcWiErr
	move.l	a0,ScOnAd(a5)
	move.w	EcNumber(a0),ScOn(a5)
	addq.w	#1,ScOn(a5)
* Fait flasher la couleur 3 (si plus de 2 couleurs)
	cmp.w	#1,d4
	beq.s	ScOo4
	moveq	#3,d1
	ALea	DefEFl,a1
	EcCall	Flash
ScOo4:	bra	InsRet
IllScN:	moveq	#6,d0			* Illegal screen number
	bra	EcWiErr

******* SCREEN CLOSE n
ScClos:	bsr	ExpEntier
	move.l	d3,d1
	cmp.l	#8,d1
	bcc.s	IllScN
	EcCall	Del
	bne	EcWiErr
	clr.w	ScOn(a5)
	clr.l	ScOnAd(a5)
	cmp.l	#0,a0
	beq	InsRet
	move.w	EcNumber(a0),d0
	cmp.w	#8,d0
	bcc	InsRet
	addq.w	#1,d0
	move.w	d0,ScOn(a5)
	move.l	a0,ScOnAd(a5)
	bra	InsRet

******* SCREEN DISPLAY
ScDisp:	bsr	GetPar
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
ScDi4:	move.l	(a3)+,d1
	cmp.l	#8,d1
	bcc.s	IllScN
	EcCall	View
	bne	EcWiErr
	bra	InsRet

******* SCREEN OFFSET
ScOffs	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	GetPar
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	EcCall	OffSet
	bne	EcWiErr
	bra	InsRet

******* SCREEN SHOW [n]
ScSh0:	moveq	#0,d3
	move.w	ScOn(a5),d3
	beq	ScNOp
	subq.w	#1,d3
	bra.s	ScSh
ScSh1:	bsr	Expentier
ScSh:	moveq	#0,d2
	bra.s	ScHi2
******* SCREEN HIDE [n]
ScHi0:	moveq	#0,d3
	move.w	ScOn(a5),d3
	beq	ScNOp
	subq.w	#1,d3
	bra.s	ScHi
ScHi1:	bsr	Expentier
ScHi:	moveq	#-1,d2
ScHi2:	move.l	d3,d1
	cmp.l	#8,d1
	bcc	IllScN
	EcCall	EHide
	bne	EcWiErr
	bra	InsRet

******* SCREEN TO FRONT [n]
ScFr0:	moveq	#0,d3
	move.w	ScOn(a5),d3
	beq	ScNOp
	subq.w	#1,d3
	bra.s	ScFr
ScFr1:	bsr	Expentier
ScFr:	move.l	d3,d1
	cmp.l	#8,d1
	bcc	IllScN
	EcCall	First
	bne	EcWiErr
	bra	InsRet
******* SCREEN TO BACK [n]
ScBk0:	moveq	#0,d3
	move.w	ScOn(a5),d3
	beq	ScNOp
	subq.w	#1,d3
	bra.s	ScBk
ScBk1:	bsr	Expentier
ScBk:	move.l	d3,d1
	cmp.l	#8,d1
	bcc	IllScN
	EcCall	Last
	bne	EcWiErr
	bra	InsRet

******* SCREEN n
InSc:	bsr	Expentier
	move.l	d3,d1
	cmp.l	#8,d1
	bcc	IllScN
	EcCall	Active
	bne	EcWiErr
	move.w	EcNumber(a0),d0
	addq.w	#1,d0
	move.w	d0,ScOn(a5)
	move.l	a0,ScOnAd(a5)
	bra	InsRet
******* = SCREEN
FnSc:	move.w	ScOn(a5),d3
	subq.w	#1,d3
	ext.l	d3
	clr.b	d2
	bra	Operet

******* LACED
FLaced	moveq	#4,d3
	moveq	#0,d2
	bra	OpeRet
******* HIRES
FnHi:	move.l	#%1000000000000000,d3
	moveq	#0,d2
	bra	OpeRet
******* LOWRES
FnLow:	moveq	#0,d3
	moveq	#0,d2
	bra	OpeRet

******* Wait vbl
WtVbl:	SyCall	WaitVbl
	bsr	Tests
	bra	InsRet

******* COLOUR n,xxx
InCol:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Par2
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	cmp.l	#31,d1
	bhi	FonCall
	EcCall	SCol
	bne	EcWiErr
	bra	InsRet
ScNOp:	moveq	#3,d0
	bra	EcWiErr
******* = COLOUR (x)
FnCol:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	FnExpE
	move.l	d3,d1
	EcCall	GCol
	bne	EcWiErr
	move.l	d1,d3
	clr.b	d2
	bra	OpeRet
******* COLOUR BACK
ColB:	bsr	Expentier
	move.w	d3,ColBack(a5)
	move.l	d3,d1
	EcCall	SColB
	bra	InsRet

******* PALETTE
Pal:	tst.w	ScOn(a5)
	beq	ScNOp
	moveq	#15,d0
	move.l	Buffer(a5),a0
	move.l	a0,a1
Pal1:	move.l	#-1,(a1)+
	dbra	d0,Pal1
	bsr	Plt
	EcCall	SPal
	bne	EcWiErr
	bra	InsRet
* Routine palette
Plt:	move.l	a0,-(sp)
	bsr	Evalue
	subq.b	#1,d2
	bmi.s	Plt1
	bsr	IntToFl
Plt1:	move.l	(sp)+,a0
	tst.l	d3
	bmi.s	Plt2
	and.w	#$FFF,d3
	move.w	d3,(a0)
Plt2:	addq.l	#2,a0
	move.w	(a6)+,d0
	cmp.w	#TkVir-Tk,d0
	beq.s	Plt
	subq.l	#2,a6
	move.l	Buffer(a5),a1
	rts
* Copie de palette masquee
PalRout	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	Buffer(a5),a1
	moveq	#0,d0
PalR1:	move.w	#$FFFF,(a1)
	btst	d0,d3
	beq.s	PalR2
	move.w	(a0),(a1)
PalR2:	addq.l	#2,a0
	addq.l	#2,a1
	addq.w	#1,d0
	cmp.w	#32,d0
	bcs.s	PalR1
	move.l	Buffer(a5),a1
	rts

******* GET SPRITE PALETTE (x)
GSpPa0:	moveq	#-1,d3
	bra.s	Gsp0
GSpPa1:	bsr	expentier
Gsp0	move.l	BkSpr,d1
	move.l	ABanks(a5),a0
	move.l	(a0),d0
GIc1	beq	BkNoRes
	move.l	d0,a0
	cmp.l	(a0),d1
	bne	BkNoRes
	lea	8(a0),a0
	move.w	(a0)+,d0
	lsl.w	#3,d0
	lea	0(a0,d0.w),a0
GSp:	bsr	PalRout
	EcCall	SPal
	beq	InsRet
	bne	EcWiErr
******* GET PALETTE n,mask
GPal2:	moveq	#2,d0
	bsr	ParD0
	move.l	(a3)+,d3
	bra.s	GPal
******* GET PALETTE n
GPal1:	moveq	#1,d0
	bsr	ParD0
	moveq	#-1,d3
GPal:	move.l	(a3)+,d1
	bsr	GetEc
	lea	EcPal(a0),a0
	bra.s	GSp

******* FADE 
IFade	bsr	Expentier
	move.l	d3,-(a3)
	move.w	(a6),d0
	cmp.w	#TkTo-Tk,d0
	beq.s	IFaTo
	cmp.w	#TkVir-Tk,d0
	beq.s	IFaPal
* FADE n
	move.l	Buffer(a5),a0
	move.l	a0,a1
	moveq	#31,d0
IFad0	clr.w	(a0)+	
	dbra	d0,IFad0
	bra.s	IFadT
* FADE TO
IFaTo	bsr	FnExpE
	tst.l	d3
	bpl.s	IFat1
	move.l	BkSpr,d1		* <0 -> Sprites palette!
	move.l	ABanks(a5),a0
	move.l	(a0),d0
	beq	BkNoRes
	move.l	d0,a0
	cmp.l	(a0),d1
	bne	BkNoRes
	lea	8(a0),a0
	move.w	(a0)+,d0
	lsl.w	#3,d0
	lea	0(a0,d0.w),a0
	bra.s	IFat2
IFat1	move.l	d3,d1			* Dans un ecran
	bsr	GetEc
	lea	EcPal(a0),a0
IFat2	moveq	#-1,d3
	cmp.w	#TkVir-Tk,(a6)
	bne.s	IFat3
	move.l	a0,-(sp)
	bsr	FnExpE
	move.l	(sp)+,a0
IFat3	bsr	PalRout
	bra.s	IFadT
* FADE palette
IFaPal	moveq	#15,d0
	move.l	Buffer(a5),a0
	move.l	a0,a1
IFap	move.l	#-1,(a1)+
	dbra	d0,IFap
	addq.l	#2,a6
	bsr	Plt
* Appelle!
IFadT	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	(a3)+,d1
	bls	FonCall
	EcCall	FadeOn
	beq	InsRet
	bra	FonCall

******* FLASH OFF
FlOff:	tst.w	ScOn(a5)
	beq	ScNOp
	EcCall	FlRaz
	bra	InsRet
******* FLASH n,xxx
FlOn:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Expentier
	cmp.l	#32,d3
	bcc	IlNCo
	move.l	d3,-(sp)
	bsr	FnExpA
	bsr	ChVerBuf
	move.l	Buffer(a5),a1
	move.l	(sp)+,d1
	EcCall	Flash
	bne	EcWiErr
	bra	InsRet

******* SET RAINBOW number,colour#,size,a$,b$,c$[,debut]
ISRain7	moveq	#7,d0
	bsr	ParD0
	move.l	(a3)+,d7
	bra.s	ISRain
ISRain6	moveq	#6,d0
	bsr	ParD0
	moveq	#0,d7
ISRain	move.l	(a3)+,d6
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d2
	cmp.l	#16,d2
	bcs	FonCall
	cmp.l	#32700,d2
	bcc	FonCall
	move.l	(a3)+,d3
	bmi	FonCall
	move.l	(a3)+,d1
	cmp.l	#4,d1
	bcc	FonCall
	EcCall	RainSet
	beq	InsRet
	bmi	OOfMem
	bra	FonCall
******* RAINBOW Number,Base,Deb,Size
IRain	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	cmp.l	#4,d1
	bcc	FonCall
	EcCall	RainDo
	beq	InsRet
RainErr	moveq	#31,d0
	bra	EcWiErr
******* RAINBOW DEL
IRDel0	moveq	#-1,d1
	bra.s	IRDel
IRDel1	bsr	Expentier
	move.l	d3,d1
	cmp.l	#4,d1
	bcc	FonCall
IRDel	EcCall	RainDel
	bra	InsRet
******* =RAIN(n,m)=
VIRain	bsr	FnPar2
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	EcCall	RainVar
	bne	RainErr
	move.l	a0,-(sp)
	bsr	FnExpE
	and.w	#$0FFF,d3
	move.l	(sp)+,a0
	move.w	d3,(a0)
	bra	InsRet
VFRain	bsr	FnPar2
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	EcCall	RainVar
	bne	RainErr
	moveq	#0,d3
	move.w	(a0),d3
	moveq	#0,d2
	bra	OpeRet

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* INSTRUCTIONS GRAPHIQUES
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

******* AUTOBACK N
IAB:	bsr	Expentier
	cmp.l	#3,d3
	bcc	FonCall
	move.l	ScOnAd(a5),d0
	beq	ScNOp
	move.l	d0,a0
	move.w	d3,EcAuto(a0)
	bra	InsRet

******* Entree speciale pour PAINT!
GfxPnt	movem.l	a3-a6,-(sp)
	move.l	T_EcVect(a5),a3
	lea	SuPaint*4(a3),a3
	bra.s	GfxF0
******* Appel d'une fonction GFX avec autoback!
GfxFunc	movem.l	a3-a6,-(sp)
	move.l	T_GfxBase(a5),a6
	lea	0(a6,d6.w),a3
GfxF0	move.l	ScOnAd(a5),a2
	tst.w	EcAuto(a2)
	bne.s	GfxF1
	jsr	(a3)
	bra.s	GfxX1
* Autoback!!
GfxF1	move.l 	36(a1),a4
	moveq	#0,d7
	movem.l	d0-d7/a0-a3,-(sp)
	EcCall	AutoBack1
	movem.l	(sp),d0-d7/a0-a3
	btst	#BitDble,EcFlags(a2)
	beq.s	GfxF2
	jsr	(a3)
	EcCall	AutoBack2
	movem.l	(sp),d0-d7/a0-a3
	move.l	a4,36(a1)
	jsr	(a3)
	EcCall	AutoBack3
GfxX	movem.l	(sp)+,d0-d7/a0-a3
GfxX1	movem.l	(sp)+,a3-a6
	rts
* Single buffer
GfxF2	jsr	(a3)
	EcCall	AutoBack4
	bra.s	GfxX

******************************************************************
*	PLOT x,y
IPlot2:	
*******
	bsr	Par2
	tst.w	ScOn(a5)
	beq	ScNOp
RePlot:	bsr	GrXY
	move.w	36(a1),d0
	move.w	38(a1),d1
Plit:	move.w	#WritePixel,d6
	bsr	GfxFunc
	bra	InsRet
******* PLOT X,Y,ink
IPlot3:	moveq	#3,d0
	bsr	ParD0
	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	T_RastPort(a5),a1
	move.l	(a3)+,d0
	bmi	FonCall
	cmp.l	#EntNul,d0
	beq.s	RePlot
	GfxCa5	SetAPen
	bra.s	RePlot
******* =POINT(x,y)
FPoint:	bsr	FnPar2
	bsr.s	RPoint
	bra	OpeRet
RPoint	bsr	GrXY
	move.w	36(a1),d0
	move.w	38(a1),d1
	movem.l	a3-a6,-(sp)
	move.l	T_GfxBase(a5),a6
	jsr	ReadPixel(a6)
	movem.l	(sp)+,a3-a6
	move.l	d0,d3
	moveq	#0,d2
	rts

******************************************************************
*	DRAW x,y TO x,y
IDraw4:	tst.w	ScOn(a5)
	beq	ScNOp
	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	bsr	GrXY
	bra.s	Drw
******* DRAW TO x,y
IDraw2:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Par2
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	move.l	T_RastPort(a5),a1
Drw:	move.w	#RDraw,d6
	bsr	GfxFunc	
	bra	InsRet
******* Routine: SET XY curseur??
GrXY:	move.l	T_RastPort(a5),a1
	move.l	#Entnul,d7
	move.l	(a3)+,d6
	cmp.l	d7,d6
	beq.s	GrXy1
	move.w	d6,38(a1)
GrXy1:	move.l	(a3)+,d6
	cmp.l	d7,d6
	beq.s	GrXy2
	move.w	d6,36(a1)
GrXy2:	rts

******************************************************************
*	CIRCLE x,y,n
ICir:	moveq	#3,d0
	bsr	ParD0
	move.l	(a3)+,d2
	bls	FonCall
	move.l	d2,d3
	move.l	ScOnAd(a5),d0
	beq	ScNOp
	move.l	d0,a0
	tst.w	EcCon0(a0)
	bpl.s	EllCir
	lsl.w	#1,d2
	bra.s	EllCir
******************************************************************
*	ELLIPSE x,y,a,b
IEll:	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d3
	bls	FonCall
	move.l	(a3)+,d2
	bls	FonCall
	tst.w	ScOn(a5)
	beq	ScNOp
EllCir:	bsr	GrXY
	move.w	36(a1),d0
	move.w	38(a1),d1
	move.w	#DrawEllipse,d6
	bsr	GfxFunc
	bra	InsRet

IGrLoc:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Par2
	bsr	GrXY
	bra	InsRet

******************************************************************
*	BOX x,y TO x,y
IBox:	tst.w	ScOn(a5)
	beq	ScNOp
	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	move.l	T_RastPort(a5),a1
	move.l	Buffer(a5),a0
	move.l	a0,a2
	move.w	d0,36(a1)
	move.w	d1,38(a1)
	move.w	d0,(a2)+
	move.w	d3,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d2,(a2)+
	move.w	d1,(a2)+
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	addq.w	#1,d1
	cmp.w	d3,d1
	bcc.s	IBx1
	subq.w	#2,d1
IBx1	moveq	#4,d0
	move.w	#PolyDraw,d6
	bsr	GfxFunc
	bra	InsRet

******************************************************************
*	Fonctions CLIP
IClip0:	moveq	#-1,d1
	bra.s	GoClip
IClip4:	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	moveq	#0,d1
GoClip	tst.w	ScOn(a5)
	beq	ScNOp
	EcCall	SetClip
	beq	InsRet
	bra	FonCall

******************************************************************
*	Fonctions TEXT
******* GET ROM FONTS
IGRFont	moveq	#1,d1
	bra.s	Igf
******* GET DISC FONTS
IGDFont	moveq	#2,d1
	bra.s	Igf
******* GET FONTS
IGFont:	moveq	#3,d1
Igf:	move.l	Buffer(a5),a1
	EcCall	GFonts
	beq	InsRet
	bra	OOfMem

******* =FONT$(n)
FFont:	bsr	FnExpE
	move.l	d3,d1
	bmi	FonCall
	EcCall	GFont
	bmi	FftE
	bne	FftV
	move.l	a0,a2
	moveq	#40,d3
	jsr	Demande
	move.l	a1,-(sp)
	move.w	#38,(a1)+
	move.l	a1,a0
	moveq	#37,d0
Fft1:	move.b	#" ",(a0)+
	dbra	d0,Fft1
	lea	40(a1),a0
	move.l	a0,HiChaine(a5)
* Copie le nom
	move.l	2(a2),a0
Fft2:	move.b	(a0)+,(a1)+
	bne.s	Fft2
	move.b	#" ",-1(a1)
* Taille des caracteres
	move.l	(sp),a0
	lea	30+2(a0),a0
	moveq	#0,d0
	move.w	6(a2),d0
	jsr	LongDec
* Disque ou mem
	move.l	(sp),a0
	lea	34+2(a0),a0
	lea	FtRom(pc),a1
	cmp.w	#1,(a2)
	beq.s	Fft3
	lea	FtDisc(pc),a1
Fft3:	move.b	(a1)+,(a0)+
	bne.s	Fft3
* Ramene la chaine!
	move.l	(sp)+,d3
	moveq	#2,d2
	bra	OpeRet
* Chaine vide
FftV:	move.l	ChVide(a5),d3
	moveq	#2,d2
	bra	OpeRet
* Erreur
FftE:	moveq	#37,d0
	bra	RunErr
FtRom:	dc.b 	"Rom ",0
FtDisc:	dc.b	"Disc",0

******* SET FONT n
ISFont:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Expentier
	move.l	d3,d1
	bmi	FonCall
	EcCall	SFont
	beq	InsRet
	bmi.s	FftE
	moveq	#44,d0			* Font not found
	bra	RunErr
	
******* TEXT x,y,a$
IText:	tst.w	ScOn(a5)
	beq	FonCall
	moveq	#3,d0
	bsr	ParD0
	move.l	(a3)+,a0
	move.w	(a0)+,d0
	bsr	GrXY
	tst.w	d0
	beq	InsRet
	moveq	#Text,d6
	bsr	GfxFunc
	bra	InsRet

******* =TEXT BASE
FTBase	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	T_RastPort(a5),a1
	moveq	#0,d3
	move.w	62(a1),d3
	moveq	#0,d2
	bra	OpeRet

******* =TEXT LENGTH (a$)
FText:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Par1
	move.l	(a3)+,a0
	move.w	(a0)+,d0
	move.l	T_RastPort(a5),a1
	movem.l	a3-a6,-(sp)
	move.l	T_GfxBase(a5),a6
	jsr	TextLength(a6)
	movem.l	(sp)+,a3-a6
	move.l	d0,d3
	moveq	#0,d2
	bra	OpeRet

******* =TEXT STYLES
FStyle:	tst.w	ScOn(a5)	
	beq	ScNOp
	move.l	T_RastPort(a5),a1
	moveq	#0,d3
	move.b	56(a1),d3
	moveq	#0,d2
	bra	OpeRet

******* SET TEXT n
ISText:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Expentier
	move.l	T_RastPort(a5),a1
	move.b	d3,56(a1)
	bra	InsRet
	
******************************************************************
*	Fonctions AREA

******* SET PATTERN n
ISPat:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Expentier
	move.l	d3,d1
	EcCall	Pattern
	beq	InsRet
	bra	FonCall

******* SET PAINT n
ISPaint	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Expentier
	move.l	T_RastPort(a5),a1
	move.w	32(a1),d0
	bclr 	#3,d0
	tst.l	d3
	beq.s	ISpt
	bset	#3,d0
ISpt:	move.w	d0,32(a1)
	bra	InsRet

******* PAINT x,y [,mode]
IPaint3	moveq	#3,d0
	bsr	ParD0
	bra.s	IPaint
IPaint2	bsr	Par2
	move.l	#1,-(a3)
IPaint:	tst.w	ScOn(a5)
	beq	ScNOp
	moveq	#0,d1
	bsr	Getras
	move.l	(a3)+,d4
	and.w	#$01,d4
	bsr	RPoint
	move.l	T_RastPort(a5),a1
	move.w	36(a1),d1
	move.w	38(a1),d2
	move.l	Buffer(a5),d5
	bsr	GfxPnt
	bra	InsRet

*******	POLYGON
IPoG:	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	T_RastPort(a5),a1
	move.l	Buffer(a5),a2
	cmp.w	#TkTo-Tk,(a6)
	bne.s	PGi0
	addq.l	#2,a6
	move.w	36(a1),d0
	move.w	38(a1),d1
	bra.s	PGi1
PGi0:	move.l	a1,-(sp)
	bsr	Par2
	move.l	(sp)+,a1
	addq.l	#2,a6
	move.l	(a3)+,d1
	move.l	(a3)+,d0
PGi1:	GfxCa5	AreaMove
PGi2:	move.l	a1,-(sp)
	bsr	Par2
	move.l	(sp)+,a1
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	GfxCa5	AreaDraw
	cmp.w	#TkTo-Tk,(a6)+
	beq.s	PGi2
	subq.l	#2,a6
FinRas	bsr	GetRas
	GfxCa5	AreaEnd
	bsr	FreeRas
	bra	InsRet

******* BAR x,y TO x,y
IBar:	moveq	#4,d0
	bsr	ParD0
	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	T_RastPort(a5),a1
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	cmp.w	d0,d2
	ble	FonCall
	cmp.w	d1,d3
	ble	FonCall
	move.w	d0,36(a1)
	move.w	d1,36(a1)
	move.w	#RectFill,d6
	bsr	GfxFunc
	bra	InsRet

******* Reserve un TEMPRAS!
GetRas	movem.l	a0/a1/d0/d1,-(sp)
	bsr	FreeRas
	bmi.s	GRas2
	bne.s	GRas1
	move.l	ScOnAd(a5),d0
	beq	ScNOp
	move.l	d0,a0
	move.l	EcTPlan(a0),d0
GRas1:	move.l	d0,d1
	move.l	Buffer(a5),a1
	cmp.l	#TBuffer,d0
	bls.s	GRas2
	jsr	RamChip2
	beq	OOfMem
	move.l	d0,RasAd(a5)
	move.l	d1,RasLong(a5)
	move.l	d0,a1
GRas2:	move.l	d1,d0
	lea	TmpRas(a5),a0
	move.l	T_RastPort(a5),a2
	move.l	a0,12(a2)
	GfxCa5	InitTmpRas
	movem.l	(sp)+,a0/a1/d0/d1
	rts
******* Libere le TEMPRAS si reserve!
FreeRas	move.l	RasAd(a5),d0
	beq.s	FriRX
	move.l	d0,a1
	move.l	RasLong(a5),d0
	jsr	RamFree
	clr.l	RasAd(a5)
	clr.l	RasLong(a5)
	move.l	T_RastPort(a5),a1
	clr.l	12(a1)
FriRX:	tst.l	RasLock(a5)
	bne.s	FriRY
	moveq	#0,d0
	move.w	RasSize(a5),d0
	clr.w	RasSize(a5)
	tst.l	d0
	rts	
* Raster locke!
FriRY:	move.l	RasLock(a5),a1
	moveq	#0,d1
	move.w	RasSize(a5),d1
	moveq	#-1,d0
	rts

******************************************************************
*	INK a,b,c
IInk1:	bsr	Par1
	move.l	#EntNul,d7
	move.l	d7,-(a3)
	move.l	d7,-(a3)
	bra.s	IInk
IInk2:	bsr	Par2
	move.l	#EntNul,d7
	move.l	d7,-(a3)
	bra.s	IInk
IInk3:	moveq	#3,d0
	bsr	ParD0
	move.l	#EntNul,d7
IInk:	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	T_RastPort(a5),a1
	move.l	(a3)+,d0
	cmp.l	d0,d7
	beq.s	Iik0
	move.b	d0,27(a1)
Iik0:	move.l	(a3)+,d0
	cmp.l	d7,d0
	beq.s	Iik1
	GfxCa5	SetBPen
Iik1:	move.l	(a3)+,d0
	cmp.l	d7,d0
	beq.s	Iik2
	GfxCa5	SetAPen
Iik2:	bra	InsRet

******************************************************************
*	GR WRITING n
GrWrt:	bsr	Expentier
	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	d3,d0
	bmi	FonCall
	move.l	T_RastPort(a5),a1
	GfxCa5	SetDrMd
	bra	InsRet

******************************************************************
*	SET LINE n
StLine:	bsr	Expentier
	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	T_RastPort(a5),a0
	move.w	d3,34(a0)
	bra	InsRet

******************************************************************
*	SCREEN COPY n TO n(,minterm)
Scop3:
********
	moveq	#3,d0
	move.l	(a3)+,d6
	bra.s	Scop2a
Scop2:
********
	moveq	#2,d0
	bsr	ParD0
	move.l	#$CC,d6
* Adresse ecran 2
Scop2a:	move.l	(a3)+,d1
	bsr	GetEc
	move.l	d0,SccEcD(a5)
	move.l	a0,a1
* Adresse ecran 1
	move.l	(a3)+,d1
	bsr	GetEc
	move.l	d0,SccEcO(a5)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	#10000,d4
	move.w	#10000,d5
	bsr.s	Sco0
	bra	InsRet
******************************************************************
*	SCREEN COPY n,x1,y1,x2,y2 TO n,x3,y3(,minterm)
Scop8:	
********
	moveq	#8,d0			* NE PAS CHANGER!
	bsr	ParD0
	move.l	#$CC,d6
	bra.s	Scop
Scop9:
********
	moveq	#9,d0
	bsr	ParD0
	move.l	(a3)+,d6
* Adresse ecran 2
Scop:	move.l	8(a3),d1
	bsr	GetEc
	move.l	d0,SccEcD(a5)
	move.l	a0,a1
* Adresse ecran 1
	move.l	28(a3),d1
	bsr	GetEc
	move.l	d0,SccEcO(a5)
* Prend les coordonnees
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	addq.l	#4,a3
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	addq.l	#4,a3
* Appelle la routine
	bsr	Sco0
	bra	InsRet

******* Routine SCREEN COPY
Sco0:	movem.l	a3/a6,-(sp)
	tst.w	d0
	bpl.s	Sco1
	sub.w	d0,d2
	clr.w	d0
Sco1:	tst.w	d1
	bpl.s	Sco2
	sub.w	d1,d3
	clr.w	d1
Sco2:	tst.w	d2
	bpl.s	Sco3
	sub.w	d2,d0
	clr.w	d2
Sco3:	tst.w	d3
	bpl.s	Sco4
	sub.w	d3,d1
	clr.w	d3
Sco4:	cmp.w	EcTx(a0),d0
	bcc	ScoX
	cmp.w	EcTy(a0),d1
	bcc	ScoX
	cmp.w	EcTx(a1),d2
	bcc	ScoX
	cmp.w	EcTy(a1),d3
	bcc	ScoX

	tst.w	d4
	bmi	ScoX
	cmp.w	EcTx(a0),d4
	bls.s	Sco5
	move.w	EcTx(a0),d4
Sco5:	tst.w	d5
	bmi	ScoX
	cmp.w	EcTy(a0),d5
	bls.s	Sco6
	move.w	EcTy(a0),d5
Sco6:	sub.w	d0,d4
	bls	ScoX
	sub.w	d1,d5
	bls	ScoX

	move.w	d2,d7
	add.w	d4,d7
	sub.w	EcTx(a1),d7
	bls.s	Sco7	
	sub.w	d7,d4
	bls	ScoX
Sco7:	move.w	d3,d7
	add.w	d5,d7
	sub.w	EcTy(a1),d7
	bls.s	Sco8
	sub.w	d7,d5
	bls.s	ScoX
Sco8:	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3
	ext.l	d4
	ext.l	d5
* Fabrique les fausses bitmap
	move.l	T_ChipBuf(a5),a2
	lea	40(a2),a3
	move.w	EcTLigne(a0),(a2)+
	move.w	EcTLigne(a1),(a3)+
	move.w	EcTy(a0),(a2)+
	move.w	EcTy(a1),(a3)+
	move.w	EcNPlan(a0),(a2)+
	move.w	EcNPlan(a1),(a3)+
	clr.w	(a2)+
	clr.w	(a3)+
	move.l	SccEcO(a5),a0
	move.l	SccEcD(a5),a1
	moveq	#6-1,d7
Sco9	move.l	(a0)+,(a2)+
	move.l	(a1)+,(a3)+
	dbra	d7,Sco9	

* Appelle le systeme
	move.l	T_ChipBuf(a5),a0
	lea	40(a0),a1
	lea	40(a1),a2
	move.l	T_EcVect(a5),a6
	jsr	ScCpyW*4(a6)
	beq.s	Sc_F_Blit_Done
	moveq	#-1,d7
	move.l	T_GfxBase(a5),a6
	jsr	BltBitMap(a6)
Sc_F_Blit_Done:
ScoX	movem.l	(sp)+,a3/a6
	rts

******* =PHYSIC / =LOGIC
FPhy0	moveq	#-1,d3
	moveq	#0,d2
	bra	OpeRet
FLog0	moveq	#-1,d3
	bclr	#30,d3
	moveq	#0,d2
	bra	OpeRet
FPhy1	bsr	FnExpE
	bset	#31,d3
	bset	#30,d3
	moveq	#0,d2
	bra	OpeRet
FLog1	bsr	FnExpE
	bset	#31,d3
	bclr	#30,d3
	moveq	#0,d2
	bra	OpeRet

******* Prend l'adresse de l'ecran D1---> D0
*	A0-->   BitMap
GetEc	tst.l	d1
	bmi.s	GtE1
* >0 , <8
	cmp.l	#8,d1
	bcc	FonCall
	EcCall	AdrEc
	beq	ScNOp
	move.l	d0,a0
	add.l	#EcLogic,d0
	rts
* <0
GtE1	tst.w	d1
	bpl.s	GtE2
	move.l	ScOnAd(a5),d0
	beq	ScNOp
	move.l	d0,a0
	bra.s	GtE3
GtE2	cmp.w	#8,d1
	bcc	FonCall
	EcCall	AdrEc
	beq	ScNOp
	move.l	d0,a0
GtE3	btst	#30,d1
	bne.s	GtE4
	add.l	#EcLogic,d0
	rts
GtE4	add.l	#EcPhysic,d0
	rts

******************************************************************
*	APPEAR Ecran TO ecran,param[,long]
IApp3	moveq	#4,d0
	bsr	ParD0
	move.l	(a3)+,d6
	bls	FonCall
	bra.s	IApp
IApp2	moveq	#3,d0
	bsr	ParD0
	moveq	#0,d6
IApp	move.l	(a3)+,d7
	bls	FonCall
	move.l	(a3)+,d1
	bsr	GetEc
	move.l	(a3)+,d1
	movem.l	a3-a6,-(sp)
	move.l	a0,a3
	move.l	d0,SccEcD(a5)
	bsr	GetEc
	move.l	a0,a2
	move.l	d0,SccEcO(a5)
	moveq	#0,d4
	move.w	EcNPlan(a2),d0		* Nb max de plans
	cmp.w	EcNPlan(a3),d0
	bls.s	LAppa
	move.w	EcNPlan(a3),d0
LAppa	subq.w	#1,d0
	move.w	d0,AppNPlan(a5)
	move.w	EcTLigne(a2),d5		* Nb Max de pixels
	mulu	EcTy(a2),d5
	lsl.l	#3,d5
	tst.l	d6
	bne.s	LApp0
	move.l	d5,d6
LApp0	cmp.l	d6,d7
	bcs.s	LApp1
	sub.l	d6,d7
	bra.s	LApp0
* Boucle!
LApp1	add.l	d7,d4
	cmp.l	d5,d4
	bcs.s	LApp2
	sub.l	d5,d4
LApp2	
* Point / Plot 
	move.l	d4,d0
	lsr.l	#3,d0			* D0-> Adresse image source
	move.l	d0,d1
	divu	EcTLigne(a2),d1
	move.w	d1,d2
	cmp.w	EcTy(a3),d2
	bcc.s	LApp5
	move.w	EcTLigne(a3),d3
	mulu	d3,d2
	clr.w	d1
	swap	d1
	cmp.w	d3,d1
	bcc.s	LApp5
	add.l	d2,d1			* D1-> Adresse image dest
	move.w	d4,d3
	and.w	#$0007,d3
	moveq	#7,d2
	sub.w	d3,d2			* D2-> decalage bits
	move.w	AppNPlan(a5),d3		* Nb max de plan
	move.l	SccEcO(a5),a4
	move.l	SccEcD(a5),a6
LApp3	move.l	(a4)+,a0
	move.l	(a6)+,a1
	btst	d2,0(a0,d0.l)
	bne.s	LApp4
	bclr	d2,0(a1,d1.l)
	dbra	d3,LApp3
	bra.s	LApp5
LApp4	bset	d2,0(a1,d1.l)
	dbra	d3,LApp3
* Encore?
LApp5	subq.l	#1,d6
	beq.s	LApp6
	tst.b	T_Actualise(a5)
	bpl.s	LApp1
	movem.l a2-a3/d4-d7,-(sp)
	movem.l	6*4(sp),a3-a6
	bsr	Tester
	movem.l	(sp)+,a2-a3/d4-d7
	bra.s	LApp1
* A y est!
LApp6	movem.l	(sp)+,a3-a6
	bra	InsRet	

******* ZOOM 9ec,8x,7y,6x,5y TO 4ec,3x,2y,1x,0y
		RsReset
ZSpTablX	rs.l	1
ZSpTablY	rs.l	1
ZSpASrce	rs.l	1
ZSpADest	rs.l	1
ZSpDSrce	rs.l	1
ZSpDDest	rs.l	1
ZSpNPlan	rs.w	1
ZSpSize		equ	__Rs

IZoom:	moveq	#10,d0
	bsr	ParD0
	movem.l	a3-a6,-(sp)
	lea	-ZSpSize(sp),sp
	move.l	9*4(a3),d1
	bsr	GetEc
	move.l	a0,a1			* Source
	move.l	d0,ZSpASrce(sp)
	move.l	4*4(a3),d1
	bsr	GetEc
	move.l	a0,a2			* Destination
	move.l	d0,ZSpADest(sp)
* Adresses des ecrans
	move.w	EcNPlan(a1),d0
	cmp.w	EcNPlan(a2),d0
	bls.s	IZooD1
	move.w	EcNPlan(a2),d0
IZooD1	subq.w	#1,d0
	move.w	d0,ZSpNPlan(sp)
* Reserve le buffer 4k!
	move.l	#4096,d0
	bsr	RamFast2
	beq	OOfMem
	move.l	d0,a0
	move.l	a0,ZSpTablX(sp)
* X3/X4/X2/X1
	move.l	1*4(a3),d5
	bmi	FonCall
	cmp.w	EcTx(a2),d5
	bhi	ZooF
	move.l	3*4(a3),d4
	cmp.l	d5,d4
	bcc	ZooF
	move.l	6*4(a3),d3
	bmi	ZooF
	cmp.w	EcTx(a1),d3
	bhi	ZooF
	move.l	8*4(a3),d2
	cmp.l	d3,d2
	bcc	ZooF
	moveq	#0,d0			* Position en X
	move.w	d2,d0
	lsr.w	#3,d0
	move.l	d0,ZSpDSrce(sp)
	moveq	#7,d6
	move.w	d2,d0
	and.w	#$0007,d0
	sub.w	d0,d6
	move.w	d4,d0
	lsr.w	#3,d0
	move.l	d0,ZSpDDest(sp)
	move.w	d4,d0
	and.w	#$0007,d0
	moveq	#7,d7
	sub.w	d0,d7
	bsr	ZooTab
* Y3/Y4/Y2/Y1
	move.l	0*4(a3),d5
	bmi	ZooF
	cmp.w	EcTy(a2),d5
	bhi	ZooF
	move.l	2*4(a3),d4
	cmp.l	d5,d4
	bcc	ZooF
	move.l	5*4(a3),d3
	bmi	ZooF
	cmp.w	EcTy(a1),d3
	bhi	ZooF
	move.l	7*4(a3),d2
	cmp.l	d3,d2
	bcc	ZooF
	move.w	d2,d0
	mulu	EcTLigne(a1),d0
	add.l	d0,ZSpDSrce(sp)
	move.w	d4,d0
	mulu	EcTLigne(a2),d0
	add.l	d0,ZSpDDest(sp)
	move.l	a0,ZSpTablY(sp)
	bsr	ZooTab
* Zoom / Reduce en Y
	moveq	#0,d4
	moveq	#0,d5
	move.w	EcTLigne(a1),d4
	move.w	EcTLigne(a2),d5
	move.l	ZSpTablX(sp),a0
	moveq	#0,d0
	move.w	(a0)+,d0
	beq.s	ZooD2
	bmi	ZooX
ZooD0	move.w	d0,d1
	lsr.w	#3,d0
	and.w	#7,d1
	sub.w	d1,d6
	bcc.s	ZooD1
	addq.l	#1,d0
	addq.w	#8,d6
ZooD1	add.l	d0,ZSpDSrce(sp)
ZooD2	move.w	ZSpNPlan(sp),d1
	move.l	ZSpASrce(sp),a4
	move.l	ZSpADest(sp),a5
ZooD3	move.l	(a4)+,a2
	move.l	(a5)+,a3
	move.l	ZSpDSrce(sp),d2
	move.l	ZSpDDest(sp),d3
	move.l	ZSpTablY(sp),a1
	move.w	(a1)+,d0
* Boucle de pokage en Y
ZooD4	bmi.s	ZooD9
	mulu	d4,d0
	add.l	d0,d2
ZooD5	btst	d6,0(a2,d2.l)
	beq.s	ZooD7
	bset	d7,0(a3,d3.l)
	add.l	d5,d3
	move.w	(a1)+,d0
	bne.s	ZooD4
ZooD6	bset	d7,0(a3,d3.l)
	add.l	d5,d3
	move.w	(a1)+,d0
	beq.s	ZooD6
	bra.s	ZooD4
ZooD7	bclr	d7,0(a3,d3.l)
	add.l	d5,d3
	move.w	(a1)+,d0
	bne.s	ZooD4
ZooD8	bclr	d7,0(a3,d3.l)
	add.l	d5,d3
	move.w	(a1)+,d0
	beq.s	ZooD8
	bra.s	ZooD4
* Encore un plan?
ZooD9	dbra	d1,ZooD3
* Position en X suivante!
	subq.w	#1,d7
	bcc.s	ZooDA
	moveq	#7,d7
	addq.l	#1,ZSpDDest(sp)
ZooDA	moveq	#0,d0
	move.w	(a0)+,d0
	beq.s	ZooD2
	bpl.s	ZooD0
* Fini! Youpi!
ZooX	move.l	ZSpTablX(sp),a1
	move.l	#4096,d0
	bsr	RamFree
	lea	ZSpSize(sp),sp
	movem.l	(sp)+,a3-a6
	lea	10*4(a3),a3
	bra	InsRet
* FonCall!
ZooF	move.l	ZSpTablX(sp),a1
	move.l	#4096,d0
	bsr	RamFree
	bra	FonCall

******* Fabrique la table de zoom
*	D2= X1
*	D3= X2
*	D4= X3
*	D5= X4
*	A0= Table
ZooTab	sub.w 	d2,d3
	sub.w	d4,d5
	cmp.w	d3,d5
	bcc.s	ZooZ
* Reduce!
	moveq	#-1,d0
	move.w	d3,d2
	move.w	d3,d4
	subq.w	#1,d4
	subq.w	#1,d2
ZooR1	addq.w	#1,d0
	sub.w	d5,d4
	bcc.s	ZooR2
	add.w	d3,d4
	move.w	d0,(a0)+
	moveq	#0,d0
ZooR2	dbra	d2,ZooR1
	move.w	#-1,(a0)+
	rts
* Zoom
ZooZ	clr.w	(a0)+
	move.w	d5,d4
	move.w	d5,d2
	subq.w	#2,d2
	bmi.s	ZooZ3
	subq.w	#1,d5
ZooZ1	sub.w	d3,d5
	bcc.s	ZooZ2
	add.w	d4,d5
	move.w	#1,(a0)+
	dbra	d2,ZooZ1
	bra.s	ZooZ3
ZooZ2	clr.w	(a0)+
	dbra	d2,ZooZ1
ZooZ3	move.w	#-1,(a0)+
	rts

******************************************************************
*	CONVERSIONS DE COORDONNEES

******* X HARD(x)
XHard1:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	FnExpE
	move.l	d3,d1
	moveq	#0,d3
	bra.s	XHr1
******* X HARD(n,x)
XHard2:	bsr	FnPar2
	move.l	(a3)+,d1
	move.l	(a3)+,d3
	cmp.l	#8,d3
	bge	FonCall
	addq.w	#1,d3
XHr1:	moveq	#0,d2
	SyCall	XyHard
	bne	EcWiErr
	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet

******* Y HARD(x)
YHard1:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	FnExpE
	move.l	d3,d2
	moveq	#0,d3
	bra.s	YHr1
******* Y HARD(n,x)
YHard2:	bsr	FnPar2
	move.l	(a3)+,d2
	move.l	(a3)+,d3
	cmp.l	#8,d3
	bge	FonCall
	addq.l	#1,d3
YHr1:	moveq	#0,d1
	SyCall	XyHard
	bne	EcWiErr
	move.l	d2,d3
	moveq	#0,d2
	bra	OpeRet

******* X SCREEN(x)
XScr1:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	FnExpE
	move.l	d3,d1
	moveq	#0,d3
	bra.s	XSc1
******* X SCREEN(n,x)
XScr2:	bsr	FnPar2
	move.l	(a3)+,d1
	move.l	(a3)+,d3
	cmp.l	#8,d3
	bge	FonCall
	addq.l	#1,d3
XSc1:	moveq	#0,d2
	SyCall	XyScr
	bne	EcWiErr
	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet

******* Y SCREEN(x)
YScr1:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	FnExpE
	move.l	d3,d2
	moveq	#0,d3
	bra.s	YSc1
******* Y SCREEN(n,x)
YScr2:	bsr	FnPar2
	move.l	(a3)+,d2
	move.l	(a3)+,d3
	cmp.l	#8,d3
	bge	FonCall
	addq.l	#1,d3
YSc1:	moveq	#0,d1
	SyCall	XyScr
	bne	EcWiErr
	move.l	d2,d3
	moveq	#0,d2
	bra	OpeRet

******* X TEXT(x)
XTxt1:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	FnExpE
	move.l	d3,d1
	moveq	#0,d2
	SyCall	XyWin
	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet
******* Y TEXT(x)
YTxt1:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	FnExpE
	move.l	d3,d2
	moveq	#0,d1
	SyCall	XyWin
	move.l	d2,d3
	moveq	#0,d2
	bra	OpeRet

******************************************************************
*	ZONES

******* RESERVE ZONE n
IRZo0:	moveq	#0,d1
	bra.s	IRZo2
IRZo1:	bsr	Expentier
	move.l	d3,d1
	bmi	FonCall
IRZo2:	tst.w	ScOn(a5)
	beq	ScNOp
	SyCall	ResZone
	beq	InsRet
	bra	OOfMem

******* RESET ZONE n
IRsZo0:	moveq	#0,d1
	bra.s	IRsZo2
IRsZo1:	bsr	Expentier
	move.l	d3,d1
	bmi	FonCall
IRsZo2:	tst.w	ScOn(a5)
	beq	ScNOp
	SyCall	RazZone
	beq	InsRet
	moveq	#73,d0
	bra	RunErr

******* SET ZONE n,x,y TO x,y
ISZo:	moveq	#5,d0
	bsr	ParD0
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	bls	FonCall
	tst.w	ScOn(a5)
	beq	ScNOp
	SyCall	SetZone
	beq	InsRet
	bra	FonCall

******* = ZONE([n],x,y)
FZo2:	moveq	#-1,d0
	move.l	d0,-(a3)
	moveq	#2,d0
	bra.s	FZo
FZo3:	moveq	#3,d0
FZo:	bsr	FnParD0
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	move.l	(a3)+,d3
	cmp.l	#8,d3
	bge	FonCall
	addq.l	#1,d3
	tst.w	ScOn(a5)
	beq	ScNOp
	moveq	#8,d5
	SyCall	ZoGr
FZoF:	tst.w	d0
	bne	EcWiErr
FZoG:	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet
******* = MOUSE SCREEN
FMouSc:	tst.w	ScOn(a5)
	beq	ScNOp
	SyCall	XYMou
	moveq	#0,d3
	moveq	#8,d4
	SyCall	ScIn
	bra	FZoG
******* = MOUSE ZONE
FMouZo:	tst.w	ScOn(a5)
	beq	ScNOp
	SyCall	XYMou
	moveq	#0,d3
	moveq	#8,d5
	SyCall	ZoHd
	bra	FZoG

BFonCall:
	moveq	#22,d0
	bra	EcWiErr

******************************************************************
*	GET BLOC n,x,y,tx,ty[,masque]
GtBl6:	moveq	#6,d0
	bsr	ParD0
	move.l	(a3)+,d6
	bra.s	GtBla
GtBl5:	moveq	#5,d0
	bsr	ParD0
	moveq	#0,d6
GtBla	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	beq	BFoncall
	cmp.l	#65536,d1
	bcc	BFonCall
	EcCall	BlGet
	bne	EcWiErr
	bra	InsRet		

******************************************************************
*	PUT BLOC n
PtBl1:	bsr	Expentier
	move.l	d3,d1
	move.l	#EntNul,d5
	move.l	d5,d4
	move.l	d4,d3
	move.l	d3,d2
	bra.s	PtBlc
PtBl3:	moveq	#3,d0
	bsr	ParD0
	move.l	#EntNul,d5
	move.l	d5,d4
	bra.s	PtBlb
PtBl4:	moveq	#4,d0
	bsr	ParD0
	move.l	#EntNul,d5
	bra.s	PtBla
PtBl5:	moveq	#5,d0
	bsr	ParD0
	move.l	(a3)+,d5
PtBla	move.l	(a3)+,d4
PtBlb	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d1
PtBlc:	tst.l	d1
	beq	BFonCall
	cmp.l	#65536,d1
	bcc	BFonCall
	move.l	Buffer(a5),a1
	EcCall	BlPut
	bne	EcWiErr
	bra	InsRet

******************************************************************
*	DEL BLOC
DlBl0:	EcCall	BlRaz
	bra	InsRet
DlBl1:	bsr	Expentier
	move.l	d3,d1
	beq	BFonCall
	cmp.l	#65536,d1
	bcc	BFonCall
	EcCall	BlDel
	bne	EcWiErr
	bra	InsRet

******************************************************************
*	Bloc reverse
IHRev	move.w	#%1000000000000000,-(sp)
	bra.s	IRev
IVRev	move.w	#%0100000000000000,-(sp)
IRev	bsr	Expentier
	move.l	d3,d1
	move.w	(sp)+,d2
	EcCall	BlRev
	beq	InsRet
	bra	EcWiErr


******************************************************************
*	XYCURS
FnXCu:	tst.w	ScOn(a5)
	beq	ScNOp
	WiCall	XYCuWi
	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet
FnYCu:	tst.w	ScOn(a5)
	beq	ScNOp
	WiCall	XYCuWi
	move.l	d2,d3
	moveq	#0,d2
	bra	OpeRet


******************************************************************
*	SET CURS 
WnSCu:	moveq	#8,d0
	bsr	ParD0
	move.l	Buffer(a5),a1
	lea	8(a1),a0
	moveq	#7,d0
WnSCu1:	move.l	(a3)+,d1
	move.b	d1,-(a0)
	dbra	d0,WnScu1
	WiCall	SCurWi
	bra	InsRet

******************************************************************
*	LOCATE x,y
WnLoc:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	Par2
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	WiCall	Locate
	bne	EcWiErr
	bra	InsRet

******************************************************************
*	CENTRE a$
WnCen:	tst.w	ScOn(a5)
	beq	ScNOp
	bsr	ExpAlpha
	bsr	ChVerBuf
	move.l	Buffer(a5),a1
	WiCall	Centre
	bne	EcWiErr
	bra	InsRet

******************************************************************
*	PAPER n
WnPap:	lea	ChPap(pc),a1
	bra.s	WnPp
******************************************************************
*	PEN
WnPen:	lea	ChPen(pc),a1
WnPp:	move.l	a1,-(sp)
	bsr	ExpEntier
	cmp.l	#64,d3
	bcc	WFonCall
	move.l	(sp)+,a1
	add.b	#"0",d3
	move.b	d3,2(a1)
	bra	GoWn

******************************************************************
*******	HOME
WnHom:	lea	ChHom(pc),a1
	bra.s	GoWn
*******	CURSOFF
WnCOf:	lea	ChCOf(pc),a1
	bra.s	GoWn
*******	CURSON
WnCOn:	lea	ChCOn(pc),a1
	bra.s	GoWn
*******	INVERSE ON
WnIOf:	lea	ChIOf(pc),a1
	bra.s	GoWn
*******	INVERSE OFF
WnIOn:	lea	ChIOn(pc),a1
******* Envoie à la trappe!
GoWn:	tst.w	ScOn(a5)
	beq	ScNOp
	WiCall	Print
	bne	EcWiErr
	bra	InsRet
WFonCall:
	moveq	#16,d0
	bra	EcWiErr

ChClw:	dc.b 25,0
ChHom:	dc.b 12,0
ChCUp:	dc.b 30,0
ChCDn:	dc.b 31,0
ChCLf:	dc.b 29,0
ChCRt:	dc.b 28,0
ChIOf:	dc.b 27,"I0",0
ChIOn:	dc.b 27,"I1",0
ChUOf:	dc.b 27,"U0",0
ChUOn:	dc.b 27,"U1",0
ChSOf:	dc.b 27,"S0",0
ChSOn:	dc.b 27,"S1",0
ChCOf:	dc.b 27,"C0",0
ChCOn:	dc.b 27,"C1",0
ChCPe:	dc.b 27,"D0",0
ChPap:	dc.b 27,"B0",0
ChPen:	dc.b 27,"P0",0
ChScOf:	dc.b 27,"V0",0
ChScOn:	dc.b 27,"V1",0
ChWrt:	dc.b 27,"W0",0
ChMx1:	dc.b 27,"M0",0
ChMx2:	dc.b 27,"M1",0
ChMy1:	dc.b 27,"M2",0
ChMy2:	dc.b 27,"M3",0
ChCMv:	dc.b 27,"N0",27,"O0",0
ChCll:	dc.b 26,0
ChCln:	dc.b 27,"Q0",0
ChHSc:	dc.b 16,0,17,0,18,0,19,0
ChVSc:	dc.b 20,0,21,0,22,0,23,0
ChSTa:	dc.b 27,"T0",0
	even
