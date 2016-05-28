	IfNE	ROnly
EdLoop:
AffBuf:
NewBuf:
Alert:
AlOuErr:
Avertir:
AverFin:
Escape:
FkIPoke
FkLPoke
AmiInit
EtPrint
AffSlV
AffSlH
Saved
EtAff
EtInp0
BufUntok
EdDefo
TokCur
EscLoop
FindA
HlpRt
EscToEd
EdRAff
Confirm
EdBlFree
EdBlSto
HelpNoF
EdOMm
	rts
	EndC

***********************************************************
*	BOUCLE PRINCIPALE DE L'EDITEUR
***********************************************************

	IfEq	ROnly
EdLoop:	

******* Multitache...
	bsr	WaitMul

******* AUTO-RUN???
	tst.w	LRunFlag(a5)
	bne	LRunReLoad

******* Teste les touches de la souris
	SyCall	MouseKey
	move.b	d1,EdMkIns(a5)
	moveq	#1,d2
EdMk0:	btst	d2,EdMkFl(a5)
	bne.s	EdMk1
* Appuie sur la touche
	btst	d2,d1
	beq.s	EdMk2
	bset	d2,EdMkFl(a5)
	bset	d2,EdMKey(a5)
	bra.s	EdMk2
* Doit relacher la touche
EdMk1:	bclr	d2,EdMKey(a5)
	btst	d2,d1
	bne.s	EdMk2
	bclr	d2,EdMkFl(a5)
EdMk2:	dbra	d2,EdMk0
* Relache la droite (bloc)
	btst	#1,d1
	bne.s	EdMk3
	clr.w	EdBloc(a5)
EdMk3	
******* Selectionne le jeu de touches de fonction
	EcCalD	Active,EcFonc
	SyCall	XYMou
	moveq	#0,d3
	SyCall	XyScr
	cmp.w	#8*7,d2
	bcc.s	MFk1
	btst	#1,EdMkIns(a5)
	bne.s	MFk2
	tst.w	FkMFlag(a5)
	bmi.s	PaMFk
MFk1:	clr.w 	FkJeu(a5)
	clr.w	FkMFlag(a5)
	bra.s	PaMFk
MFk2:	move.w	#10,FkJeu(a5)
	move.w	#1,FkMFlag(a5)
PaMFk:
******* Teste le CAPS lock
	SyCall	Shifts
	move.w	d1,-(sp)
	and.w	#%00000100,d1
	move.w	d1,EtCps(a5)
	cmp.w	EtOCps(a5),d1
	beq.s	EdCps
	move.w	d1,EtOCps(a5)
	bsr	EtCaps
EdCps:	
******* AMIGA G et D
	move.w	#-1,AmiAff(a5)
	move.w	(sp),d0
	and.w	#%10000000,d0
	beq.s	AmiD
	move.w	#10,AmiAff(a5)
AmiD	move.w	(sp),d0
	and.w	#%01000000,d0
	beq.s	AmiG
	move.w	#0,AmiAff(a5)

******* SHIFT / CONTROL ---> touches de fonction
AmiG:	moveq	#0,d1
	move.w	(sp),d0
	and.w	#%00000011,d0
	beq.s	EdShf
	moveq	#10,d1
EdShf:
	move.w	(sp),d0
	and.w	#%00001000,d0
	beq.s	EdCt
	moveq	#20,d1
EdCt:
	move.w	(sp),d0
	and.w	#%00110000,d0
	beq.s	EdAl
	moveq	#30,d1
EdAl:	
	addq.l	#2,sp
	tst.w	d1
	bne.s	EdAl1
	tst.w	FkMFlag(a5)
	bne.s	EdAl2
EdAl1:	move.w	d1,FkJeu(a5)
	clr.w	FkMFlag(a5)
EdAl2:

******* Priorite des ecrans
	SyCall	XYMou
	moveq	#-1,d3
	moveq	#16,d4
	SyCall	ScIn
	cmp.w	#EcFonc,d1
	beq.s	EdPre2
	cmp.w	#EcEdit,d1
	bne.s	EdPreX
* Edit en premier
EdPre1	tst.b	EdFront(a5)
	bne.s	EdPreX
	EcCalD	First,EcEdit
	EcCall	CopForce
	move.b	#-1,EdFront(a5)
	bra.s	EdPreX
* Fonc en premier
EdPre2	tst.b	EdFront(a5)
	beq.s	EdPreX
	EcCalD	First,EcFonc
	EcCall	CopForce
	clr.b	EdFront(a5)
EdPreX

******* Teste la souris dans les zones de fonction
	SyCall	GetZone
	cmp.w	#EcFonc,d1
	beq.s	EdLl
	moveq	#0,d1
EdLl	swap	d1
	move.w	d1,d5
	add.w	FkJeu(a5),d1
	moveq	#0,d4
	move.w	FkOn(a5),d0
	cmp.w	d0,d1
	beq.s	EdL2
	tst.w	d0
	beq.s	EdL1
	move.w	d0,d2
	move.b	#"0",d3
	bsr	FkAct
	addq.w	#1,d4
EdL1:	clr.w	FkOn(a5)
	tst.w	d5
	beq.s	EdL2
	cmp.w	#11,d5
	bcc.s	EdL2
	move.w	d1,FkOn(a5)
	move.w	d1,d2
	move.b	#"1",d3
	bsr	FkAct
	addq.w	#1,d4
EdL2:

******* Touches de fonction FLASH
	tst.w	EdFkCpt(a5)
	beq.s	EdL0
	subq.w	#1,EdFkCpt(a5)
	bne.s	EdL0
	moveq	#40,d2
	moveq	#0,d3
EdL3:	bsr	FkAct
	cmp.b	#"0",(a0)
	beq.s	EdL4
	cmp.w	FkOn(a5),d2
	beq.s	EdL4
	move.b	#"0",(a0)
	addq.w	#1,d4
EdL4:	subq.w	#1,d2
	bne.s	EdL3
EdL0:	add.w	d4,EdAfFk(a5)

******* Affiche les touches de fonction AMIGA
	move.w	AmiAff(a5),d1
	cmp.w	AmiOAff(a5),d1
	beq.s	AmiPaf
	move.w	d1,AmiOAff(a5)
	bpl.s	AmiA1
	addq.w	#1,EdAfFk(a5)
	move.w	#-1,FkOJeu(a5)
	bra.s	AmiPaf
* Poke tous les noms dans les touches
AmiA1:	moveq	#0,d2
AmiA2:	move.l	EdBufT(a5),a2
	bsr	SsGtKy
	move.w	d2,d0
	mulu	#FkLong,d0
	Alea	FkDef5,a1
	addq.l	#FkTDef,a1
	lea	12(a1,d0.w),a1
	moveq	#10,d3
AmiA3:	move.b	(a2)+,d0
	beq.s	AmiA4
	move.b	d0,(a1)+
	dbra	d3,AmiA3
	bra.s	AmiA5
AmiA4:	move.b	#" ",(a1)+
	dbra	d3,AmiA4
AmiA5:	addq.w	#1,d1
	addq.w	#1,d2
	cmp.w	#10,d2
	bcs.s	AmiA2
	Alea	FkDef5,a1
	WiCall	Print

******* Reaffiche le jeu de touches de fonction???
AmiPaf:	bsr	FkReAff

******* Affiche la position du curseur
	tst.w	EtAX(a5)
	beq.s	PaCuX
	subq.w	#1,EtAX(a5)
	bne.s	PaCuX
	bsr	EtCol
PaCuX:
	tst.w	EtAY(a5)
	beq.s	PaCuY
	subq.w	#1,EtAY(a5)
	bne.s	PaCuY
	bsr	EtLine
PaCuY:
	tst.w	EtFr(a5)
	beq.s	PaFr
	subq.w	#1,EtFr(a5)
	bne.s	PaFr
	bsr	EtFree
PaFr:

******* Message d'alerte
	tst.w	EtMess(a5)
	beq.s	PaMess
	tst.l	EtAlert(a5)
	beq.s	Mal1
* Affiche le message
	Alea	EtAl,a1
	WiCall	Print
	move.l	EtAlert(a5),a1
	WiCall	Centre 
	clr.l	EtAlert(a5)
	bra.s	PaMess
* Arrete le message
Mal1:	subq.w	#1,EtMess(a5)
	bne.s	PaMess
	bsr	EtPrint
PaMess:
	
******* Active la fenetre principale
	EcCalD	Active,EcEdit
	WiCalD	QWindow,1

* Affiche les sliders
	tst.w	EtASlY(a5)
	beq.s	PaSlY
	subq.w	#1,EtASlY(a5)
	bne.s	PaSlY
	bsr	AffSlV
PaSlY:
	tst.w	EtASlX(a5)
	beq.s	PaSlX
	subq.w	#1,EtASlX(a5)
	bne.s	PaSlX
	bsr	AffSlH
PaSlX:

* Appel d'une touche de fonction?
	move.w	FkOn(a5),d0
	beq	EdMfF
	cmp.w	#41,d0
	bcc.s	EdMfF
	btst	#0,EdMKey(a5)
	beq	EdMfF
	tst.w	AmiAff(a5)
	bpl.s	EdMfF
	subq.w	#1,d0
	moveq	#0,d1
	moveq	#0,d7
	moveq	#0,d6
	moveq	#0,d5
	bra	FkBis
EdMfF:
* Click ?
	tst.b	EdMkIns(a5)
	beq	Ed_Clavier

*******	Clique!
	SyCall	GetZone
	cmp.w	#EcEdit,d1
	bne	EdLoop
	swap	d1
	lsl.w	#2,d1
	lea	Ed_JClic(pc),a0
	jmp	0(a0,d1.w)
Ed_JClic
	bra	EdLoop
	bra	Ed_MTexte
	bra	Ed_MSlH
	bra	Ed_MSlV
	bra	Ed_MHo
	bra	Ed_MBa
	bra	Ed_MGo
	bra	Ed_MDr
	bra	EdLoop

******* Clique dans le texte
Ed_MTexte
	SyCall	XYMou
	moveq	#0,d3
	SyCall	XyScr
	SyCall	XyWin
	move.l	d1,d0
	or.l	d2,d0
	bmi	EdLoop
	btst	#1,EdMkIns(a5)
	bne.s	EBl0	
	bsr	TokCur
	add.w	EdXPos(a5),d1
	cmp.w	#250,d1
	bcc.s	EdMk4
	move.w	d1,EdXCu(a5)
EdMk4:	add.w	EdYPos(a5),d2
	cmp.w	EdNLigne(a5),d2
	bhi	EdLoop
	sub.w	EdYPos(a5),d2
	move.w	d2,EdYCu(a5)
EdMk5:	move.w	#1,EtAX(a5)
	move.w	#1,EtAY(a5)
	bsr	EdLoca
	bra	EdLoop
******* Bloc 
EBl0	bsr	TokCur
	move.w	d2,d3
	add.w	EdYPos(a5),d2		Y bloc GLOBAL
	cmp.w	EdNLigne(a5),d2
	bhi	EdLoop
	move.w	EdBloc(a5),d1
	bne.s	EBl1
* Creation du bloc
	move.w	d2,YOBloc(a5)
	move.w	d2,Y1Bloc(a5)
	move.w	d2,Y2Bloc(a5)
	bsr	NewBuf
	moveq	#0,d0
	bsr	EdBlFree
	bra	EBl5
* Bloc en route
EBl1	cmp.w	YOBloc(a5),d2
	beq	EdLoop
	move.w	d2,YOBloc(a5)
	cmp.w	#1,d1
	bne.s	EBl3
* Rattache a H ou B
	moveq	#2,d1
	cmp.w	Y1Bloc(a5),d2
	bcs.s	EBl2
	moveq	#3,d1
EBl2	move.w	d1,EdBloc(a5)
* Y1?
EBl3	cmp.w	#2,d1
	bne.s	EBl4
	move.w	d2,Y1Bloc(a5)
	bra.s	EBl5
* Y2
EBl4	move.w	d2,Y2Bloc(a5)
* Verifie
EBl5	move.w	Y1Bloc(a5),d0
	cmp.w	Y2Bloc(a5),d0
	bcs.s	EBl6
	move.w	#1,EdBloc(a5)
* Affiche
EBl6	tst.w	d3
	beq.s	EBl8
	cmp.w	EdTyM1(a5),d3
	beq.s	EBl9
EBl7	bsr	AffBuf
	clr.w	EtASlX(a5)
	clr.w	EtASlY(a5)
	bra	EdLoop
EBl8	tst.w	EdYPos(a5)
	beq.s	EBl7
	moveq	#0,d1
	bsr	ALigne
	bsr	EdSHaut
	bra	EdLoop
EBl9	cmp.w	EdNLigne(a5),d2
	bcc.s	EBl7
	move.w	EdTyM2(a5),d1
	bsr	ALigne
	bsr	EdSBas
	bra	EdLoop
	
******* Positionnement dans le slider HORIZONTAL (X)
Ed_MSlH	jsr	XYMouEc
	move.w	d1,d0
	sub.w	#HSli_Dx-1,d0
	cmp.w	Ed_Slh1,d0
	bcs	.Goch
	cmp.w	Ed_Slh2,d0
	bcc	.Droi
** POSITIONNE DIRECTEMENT
	move.w	d0,d7
	sub.w	Ed_Slh1,d7
.loop	sub.w	d7,d1
	bpl.s	.skip0
	moveq	#0,d1
.skip0	mulu	#254,d1
	divu	#Ed_Sx-16*3-HSli_Dx-HSli_Fx,d1
	move.w	EdXCu(a5),d2
	sub.w	EdXPos(a5),d2
	clr.w	d0
	cmp.w	EdXPos(a5),d1
	beq.s	.EdMh0
	addq.w	#1,d0
	move.w	d1,EdXPos(a5)
.EdMh0:	add.w	d2,d1
	cmp.w	#250,d1
	bcs.s	.EdMh1
	move.w	#250,d1
.EdMh1:	cmp.w	EdXCu(a5),d1
	beq.s	.EdMh2
	addq.w	#1,d0
	move.w	d1,EdXCu(a5)
.EdMh2:	tst.w	d0
	beq.s	.skip
	move.w	d7,-(sp)
	bsr	AffSlH
	move.w	(sp)+,d7
* Boucle?
.skip	bsr	WaitMul
	SyCall	Mousekey
	tst.w	d1
	beq.s	.exit
	jsr	XYMouEc
	bra.s	.loop
.exit	bsr	AffBuf
	move.w	#1,EtAX(a5)
	bra	EdLoop
** SCROLL VERS LA GAUCHE
.Goch	move.w	EdXPos(a5),d0
	move.w	d0,d1
	sub.w	#10,d0
	bpl.s	.sk0
	moveq	#0,d0
.sk0	sub.w	d0,d1
	move.w	d0,EdXPos(a5)
	sub.w	d1,EdXCu(a5)
	bsr	AffBuf
	bsr	AffSlH
	bra	Ed_MWait
** SCROLL VERS LA DROITE
.Droi	move.w	EdXPos(a5),d0
	move.w	d0,d1
	add.w	#10,d0
	cmp.w	#250-EdTx,d0
	bcs.s	.sk1
	move.w	#250-EdTx,d0
.sk1	move.w	d0,EdXPos(a5)
	sub.w	d1,d0
	add.w	d0,EdXCu(a5)
	bsr	AffBuf
	bsr	AffSlH
	bra	Ed_MWait

******* Positionnement dans le slider VERTICAL (Y)
Ed_MSlV	bsr	TokCur
	jsr	XYMouEc
	move.w	d2,d0
	sub.w	#VSli_Dy,d0
	cmp.w	Ed_Slv1,d0
	bcs	.Haut
	cmp.w	Ed_Slv2,d0
	bcc	.Bas
** POSITIONNE DIRECTEMENT
	move.w	d0,d7
	sub.w	Ed_Slv1,d7
.loop	sub.w	d7,d2
	bpl.s	.skip0
	moveq	#0,d2
.skip0	mulu	EdNLigne(a5),d2
	move.l	EdEcran(a5),a0
	move.w	EcTy(a0),d0
	sub.w	#8*3+VSli_Dy+VSli_Fy,d0
	divu	d0,d2
	move.w	d2,d0
	add.w	EdYCu(a5),d0
	cmp.w	EdNLigne(a5),d0
	bls.s	.EdMv1
	move.w	EdNLigne(a5),d2
	sub.w	EdYCu(a5),d2
	bpl.s	.EdMv1
	clr.w	d2
	move.w	EdNLigne(a5),EdYCu(a5)
.EdMv1:	cmp.w	EdYPos(a5),d2
	beq.s	.skip
	move.w	d2,EdYPos(a5)
	move.w	d7,-(sp)
	bsr	AffSlV
	move.w	(sp)+,d7
* Boucle?
.skip	bsr	WaitMul
	SyCall	Mousekey
	tst.w	d1
	beq.s	.exit
	jsr	XYMouEc
	bra.s	.loop
.exit	bsr	NewBuf
	move.w	#1,EtAY(a5)
	bra	EdLoop
** SCROLL VERS LE HAUT
.Haut	bsr	PHaut
	bsr	AffSlV
	bra.s	Ed_MWait
** SCROLL VERS LE BAS
.Bas	bsr	PBas
	bsr	AffSlV
Ed_MWait	
	bsr	WaitMul
	SyCall	MouseKey
	btst	#0,d1
	bne.s	Ed_MWait
	move.w	#1,EtAX(a5)
	move.w	#1,EtAY(a5)
	bra	EdLoop

******* Click dans fleche HAUT
Ed_MHo:	bsr	CHaut
	bra	EdLoop
*******	Click dans fleche BAS
Ed_MBa:	bsr	CBas
	bra	EdLoop
*******	Click dans fleche DROITE
Ed_MDr:	bsr	CDroite
	bra	EdLoop
******* Click dans fleche GAUCHE
Ed_MGo:	bsr	CGauche
	bra	EdLoop

******* Teste le clavier
Ed_Clavier
	bclr	#BitControl,T_Actualise(a5)	* Simule CONTROL-C
	beq.s	EdPaCc
	move.l	#$08330043,d1
	bra.s	EdCc
EdPaCc	SyCall	Inkey
EdCc	tst.l	d1
	beq	EdLoop
	move.l	d1,-(sp)

* Explore la table des touches de fonctions
	move.b	d1,d7
	cmp.b	#"a",d7		* D7= lettre majuscule
	bcs.s	EdL5
	cmp.b	#"z",d7
	bhi.s	EdL5
	sub.b	#"a"-"A",d7
EdL5:	swap 	d1		
	move.b	d1,d6		* D6= scancode
	lsr.w	#8,d1
	and.b	#%11111011,d1	* Enleve le CAPS LOCK
	move.b	d1,d5		* D5= shifts
	swap	d1
* Est-ce une touche de fonction?
	cmp.b	#$50,d6
	bcs.s	EdL5a
	cmp.b	#$59,d6
	bhi	EdL5a
	tst.w	AmiAff(a5)
	bmi	EdTFonc
	addq.l	#4,sp
	bra	EdLoop
* Recherche dans la table
EdL5a:	clr.w	d2
	Alea	KFonc,a0
EdL6:	move.b	d5,d4
	move.b	(a0),d0		* Boucle de comparaison
	bpl.s	EdL7
	cmp.b	#$FF,d0
	beq	EdL10
	and.b	#$7f,d0		* Compare au scancode
	cmp.b	d0,d6
	bne.s	EdL9
	bra.s	EdL8
EdL7:	beq.s	EdLN
	cmp.b	d0,d7		* Compare au code ASCII
	bne.s	EdL9
EdL8:	move.b	1(a0),d3	* Compare le SHIFTS...
	bne.s	EdL8a
	tst.b	d4
	bne.s	EdL9
	bra.s	EdLG
EdL8a:	move.b	d4,d0
	and.b	#Shf,d0		* Teste les shifts
	beq.s	EdL8b
	and.b	d3,d0
	beq.s	EdL9
	and.b	#255^Shf,d3
	and.b	#255^Shf,d4
	beq.s	EdLG
EdL8b:	move.b	d4,d0
	and.b	#Ctr,d0		* Teste CONTROL
	beq.s	EdL8c
	and.b	d3,d0
	beq.s	EdL9
	and.b	#255^Ctr,d3
	and.b	#255^Ctr,d4
	beq.s	EdLG
EdL8c:	move.b	d4,d0
	and.b	#Alt,d0		* Teste ALTERNATE
	beq.s	EdL8d
	and.b	d3,d0
	beq.s	EdL9
	and.b	#255^Alt,d3
	and.b	#255^Alt,d4
	beq.s	EdLG
EdL8d:	move.b	d4,d0
	and.b	#Ami,d0		* Teste AMIGA
	beq.s	EdL9
	and.b	d3,d0
	beq.s	EdL9
	and.b	#255^Ami,d3
	and.b	#255^Ami,d4
	beq.s	EdLG
EdL9:	lea	2(a0),a0
	bra	EdL6
EdLN:	addq.w	#1,d2
	addq.l	#1,a0
	bra	EdL6
EdLG:	or.b	d4,d3
	bne.s	EdL9
	lsl.w	#2,d2		* Appelle la fonction
	lea	JFonc(pc),a0
	move.l	(sp)+,d1
	bsr	ClEProc
	clr.w	T_Actualise(a5)
	moveq	#0,d0
	jsr	0(a0,d2.w)
	bra	EdLoop

******* Stocke la lettre dans le buffer
EdL10:	clr.w	FkMFlag(a5)
	bsr	LCourant
* Positionne a la fin de la ligne
	cmp.w	d0,d1
	bls.s	EdL10a
	move.w	d0,d1
	lea	0(a0,d1.w),a1
	move.w	d1,EdXCu(a5)
	movem.l	a0/a1/d0/d1,-(sp)
	bsr	EdCent
	movem.l	(sp)+,a0/a1/d0/d1
* Recupere le code ASCII
EdL10a:	move.l	(sp)+,d7
	cmp.b	#32,d7			* Pas de codes directs!
	bcs	EdL15
	tst.b	EdInsert(a5)
	bne.s	EdL11
* Mode OVERWRITE
	cmp.w	d0,d1
	beq.s	EdL13
	bne.s	EdL14
* Mode INSERT
EdL11:	cmp.w	#250,d0
	bcc	EdL16
	cmp.w	d0,d1
	beq.s	EdL13
	lea	1(a0,d0.w),a2
EdL12:	move.b	-(a2),1(a2)
	cmp.l	a1,a2
	bhi.s	EdL12
EdL13:	addq.w	#1,d0
EdL14:	move.b	d7,(a1)
	move.w	d0,-2(a0)
	addq.w	#1,EdFlag(a5)		* Flag ligne editee
* Bouge le curseur
	bsr	CDroite
	move.w	EdYCu(a5),d1
	bsr	ALigne	
EdL15:	bsr	EdLoca
	bra	EdLoop
EdL16:	bsr	LToLong
	bra	EdLoop
* Line too long
LToLong:moveq	#50,d0
	Alea	EdLLong,a0
	bra	Alert
	
JFonc:	bra	CHaut
	bra	CBas
	bra	CGauche
	bra	CDroite
	bra	HPage
	bra	BPage
	bra	MGauche
	bra	MDroite
	bra	PHaut
	bra	PBas
	bra	DLigne
	bra	FLigne
	bra	EdSHaut
	bra	EdSBas
	bra	EdSGauche
	bra	EdSDroite
	bra	HTexte
	bra	BTexte
	bra	Return
	bra	Back
	bra	Delete
	bra	EffLigne
	bra	DelLigne
	bra	ETab
	bra	ShTab
	bra	EdSTab
	bra	JHelp
	bra	PreEsc
	bra	InsLine
	bra	DelFin
	bra	PLabel
	bra	NLabel
	bra	EdLoad			* Load Save
	bra	EdSaveAs
	bra	EdSave
	bra	JSHelp			* Multi run
	bra	CFin
	bra	CFin
	bra	SMark0			* Marks
	bra	SMark1
	bra	SMark2
	bra	SMark3
	bra	SMark4
	bra	SMark5
	bra	SMark6
	bra	SMark7
	bra	SMark8
	bra	SMark9
	bra	GMark0
	bra	GMark1
	bra	GMark2
	bra	GMark3
	bra	GMark4
	bra	GMark5
	bra	GMark6
	bra	GMark7
	bra	GMark8
	bra	GMark9
	bra	SDBloc			* BLocs
	bra	SFBloc
	bra	SHBloc
	bra	EdBlCut
	bra	EdBlPas
	bra	EdBlMve
	bra	EUndo			* Undo
	bra	EdSch			* Search
	bra	EdSchN			* Next
	bra	EdRep			* Replace
	bra	SABloc			* All text as block
	bra	RAlert			* Recall last alert
	bra	SEdLoad			* AMIGA-SHIFT-LOAD
	bra	EdBSto			* Store bloc

******* BACKSPACE
Back:	tst.w	EdXCu(a5)
	beq.s	Bac
	bsr	CGauche
	bra	Delete
* Joint la ligne et celle du dessus!
Bac:	tst.w	EdYCu(a5)
	beq	CFin
	bsr	LCourant
	lea	-256(a0),a1
	move.w	-2(a1),d1
	move.w	d0,d2
	add.w	d1,d2
	cmp.w	#250,d2			Line too long!
	bcc	BacE
	clr.w	-2(a0)
	move.w	d2,-2(a1)
	lea	0(a1,d1.w),a1
	subq.w	#1,d0
	bmi.s	Bac1
Bac0:	move.b	(a0)+,(a1)+
	dbra	d0,Bac0
Bac1:	move.w	d1,-(sp)
	bsr	EALiCu			Efface la ligne de l'ecran
	bsr	DLine			Va enlever la ligne!
	bsr	CHtT			Remonte le curseur	
	addq.w	#1,EdFlag(a5)
	move.w	#SlDelai,EtASlY(a5)
	move.w	(sp)+,EdXCu(a5)
	bsr	EALiCu
	bra	EdCent
BacE:	Alea	EdLLong,a0
	moveq	#100,d0
	bra	Alert
	
******* DELETE
Delete:	bsr	LCourant
	sub.w	EdXCu(a5),d0
	subq.w	#1,d0
	bmi	CFin
	addq.w	#1,EdFlag(a5)
	subq.w	#1,-2(a0)
	subq.w	#1,d0
	bmi.s	Del2
Del1:	move.b	1(a1),(a1)+
	dbra	d0,Del1
Del2:	move.b	#" ",(a1)
	bra.s	EALiCu

******* EFFACEMENT LIGNE
EffLigne:
	addq.w	#1,EdFlag(a5)
	bsr	LCourant
	clr.w	-2(a0)
	bsr	EALiCu
	clr.w	EdXCu(a5)
	bra	EdCent

******* UNDO
EUndo	tst.w	EdILigne(a5)
	bne	CFin
	clr.w	EdFlag(a5)
	move.w	EdYCu(a5),d1
	move.w	EdYPos(a5),d0
	add.w	d1,d0
	bsr	Untok
	bsr	EALigne
	bra	EdLoca

* Reaffichage de la ligne courante
EALiCu:	move.w	EdYCu(a5),d1
	bsr	EALigne
	bra	EdLoca

******* DELETION LIGNE DANS PROGRAMME
DelLigne:
	addq.w	#1,EdFlag(a5)
	bsr	LCourant
* Correction du BUG editeur!!!
	move.l	-2(a0),-(sp)
	move.l	a0,-(sp)
	move.w	EdNLigne(a5),-(sp)
	clr.w	-2(a0)
	bsr	Return	
	move.w	(sp)+,d0
	cmp.w	EdNLigne(a5),d0
	bne.s	.Skip
	move.l	(sp),a0
	move.l	4(sp),-2(a0)
.Skip	addq.l	#8,sp
	rts

******* DELETE JUSQUA LA FIN DE LA LIGNE
DelFin:	addq.w	#1,EdFlag(a5)
	bsr	LCourant
	cmp.w	d0,d1
	bcc.s	EdFin
	move.w	d1,-2(a0)
	bra	EALiCu
EdFin:	rts

******* TAB
ETab:	bsr	LCourant
	lea	0(a0,d0.w),a1		* Fin actuelle
	move.w	EdTabs(a5),d2
	add.w	d2,d0
	cmp.w	#250,d0
	bcc	LToLong
	add.w	d2,-2(a0)
	lea	0(a0,d0.w),a2		* Nouvelle fin
	bra.s	ETab2
ETab1:	move.b	-(a1),-(a2)
ETab2:	cmp.l	a0,a1
	bhi.s	ETab1
	add.w	d2,EdXCu(a5)
	subq.w	#1,d2
	bmi.s	ETab4
ETab3:	move.b	#" ",(a1)+
	dbra	d2,ETab3
ETab4:	addq.w	#1,EdFlag(a5)
	move.w	EdYCu(a5),d1
	bsr	EALigne
	bsr	EdCent
ETabX:	rts

******* SHIFT TAB (enleve les tabs)
ShTab:	bsr	LCourant
	lea	0(a0,d0.w),a2
	move.l	a0,a1
	moveq	#0,d0
	move.w	EdTabs(a5),d1
	subq.w	#1,d1
	bmi.s	ETabX
ShT1:	cmp.b	#" ",(a0)
	bne.s	ShT2
	addq.l	#1,a0
	cmp.l	a2,a0
	bcc.s	ShT2
	addq.w	#1,d0
	dbra	d1,ShT1
ShT2:	tst.w	d0
	beq.s	ETabX
	sub.w	d0,-2(a1)
	sub.w	d0,EdXCu(a5)
	bpl.s	ShT4
	clr.w	EdXCu(a5)
	bra.s	ShT4
ShT3:	move.b	(a0)+,(a1)+
ShT4:	cmp.l	a2,a0
	bls.s	ShT3
	bra.s	ETab4

******* Curseur vers le haut
CHaut:	bsr	TokCur

ChtT:	move.w	#1,EtAY(a5)
	tst.w	EdYCu(a5)
	beq.s	CHt1
	subq.w	#1,EdYCu(a5)
	bra	EdLoca
CHt1:	tst.w	EdYPos(a5)
	beq.s	CHtE
	subq.w	#1,EdYPos(a5)
* Scrolle l'ecran graphique
CHt:	bsr	CuOff
	WiCalD	ChrOut,20	
	move.w	#SlDelai,EtASlY(a5)
* Scrolle l'ecran texte
	move.l	EdBufE(a5),a1
	move.w	EdTyM0(a5),d0
	lsl.w	#8,d0
	add.w	d0,a1
	lea	-256(a1),a0
	move.w	EdTyM1(a5),d0
	lsl.w	#4,d0
	subq.w	#1,d0
CBs2:	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	dbra	d0,CBs2
* Affiche la derniere ligne
	move.w	EdYPos(a5),d0
	moveq	#0,d1
	bsr	Untok
	bsr	ALigne
	bra	EdLoca
* Top of text
CHtE:	Alea	EdTop,a0
	moveq	#25,d0
	bra	Alert

CFin:	rts

******* Curseur vers le bas
CBas:	bsr	TokCur
	
* Entree pour la tokenisation
CBasT:	move.w	#1,EtAY(a5)
	move.w	EdYPos(a5),d0		* Deja la derniere ligne
	add.w	EdYCu(a5),d0
	cmp.w	EdNLigne(a5),d0
	bcc	CBasE

	move.w	EdYCu(a5),d0
	cmp.w	EdTyM1(a5),d0
	bcc.s	CBs1
	addq.w	#1,EdYCu(a5)
	bra	EdLoca

CBs1:	addq.w	#1,EdYPos(a5)
* Scrolle l'ecran graphique
CBs:	bsr	CuOff
	WiCalD	ChrOut,22	
	move.w	#SlDelai,EtASlY(a5)
* Scrolle l'ecran texte
	move.l	EdBufE(a5),a1
	lea	256(a1),a0
	move.w	EdTyM1(a5),d0
	lsl.w	#4,d0
	subq.w	#1,d0
CHt2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,CHt2
* Affiche la derniere ligne
	move.w	EdYPos(a5),d0
	add.w	EdTyM1(a5),d0
	move.w	EdTyM1(a5),d1
	bsr	Untok
	bsr	ALigne
	bra	EdLoca
* Bottom of text
CBasE:	Alea	EdBot,a0
	moveq	#25,d0
	bra	Alert

******* Curseur vers la gauche
CGauche:
	move.w	#1,EtAX(a5)
	move.w	EdXCu(a5),d0
	beq	CFin
	subq.w	#1,d0
	move.w	d0,EdXCu(a5)
	sub.w	EdXPos(a5),d0
	cmp.w	#15,d0
	bcc.s	CGo1
	tst.w	EdXPos(a5)
	beq.s	CGo1
CGo:	move.w	#SlDelai,EtASlX(a5)
	subq.w	#1,EdXPos(a5)
	bsr	CuOff
	WiCalD	ChrOut,19
	moveq	#0,d2
	bsr	AffBufCar
CGo1:	bra	EdLoca
 
******* Curseur vers la droite
CDroite:
	move.w	#1,EtAX(a5)
	move.w	EdXCu(a5),d0
	cmp.w	#250,d0
	bcc	CFin
	addq.w	#1,d0
	move.w	d0,EdXCu(a5)
	sub.w	EdXPos(a5),d0
	cmp.w	#WiTx-10,d0
	bcs.s	CDr0
CDr:	move.w	#SlDelai,EtASlX(a5)
	addq.w	#1,EdXPos(a5)
	bsr	CuOff
	WiCalD	ChrOut,17
	moveq	#EdTx-1,d2
	bsr	AffBufCar
CDr0:	bra	EdLoca

******* Haut page
HPage:	bsr	TokCur
	clr.w	EdYCu(a5)
EdLXY:	move.w	#1,EtAX(a5)
	move.w	#1,EtAY(a5)
	bra	EdLoca

******* Bas page
BPage:	bsr	TokCur
	move.w	EdTyM1(a5),d0
	move.w	EdYPos(a5),d1
	add.w	d0,d1
	cmp.w	EdNLigne(a5),d1
	bcs.s	BPag
	sub.w	EdNLigne(a5),d1
	sub.w	d1,d0
BPag:	move.w	d0,EdYCu(a5)
	bra	EdLXY

******* Mot gauche
MGauche:bsr	LCourant
	cmp.w	d0,d1
	bls.s	MGo0
	move.w	d0,d1
	bra.s	MGo4
MGo0:	subq.w	#1,d1
	bmi.s	MGo3
	cmp.b	#32,-(a1)
	bne.s	MGo2
MGo1	subq.w	#1,d1
	bmi.s	MGo3
	cmp.b	#32,-(a1)
	beq.s	MGo1
MGo2:	subq.w	#1,d1
	bmi.s	MGo3		
	move.b	-(a1),d2
	bsr	Lettre
	bne.s	MGo2
MGo3:	addq.w	#1,d1
MGo4:	move.w	d1,EdXCu(a5)
	bra	EdCent

******* Mot droit
MDroite:bsr	LCourant
MDr1:	addq.w	#1,d1
	cmp.w	d0,d1
	bcc.s	MDr2
	move.b	(a1)+,d2
	bsr	Lettre
	bne.s	MDr1
	cmp.b	#32,(a1)
	beq.s	MDr1
MDr2:	move.w	d1,EdXCu(a5)
	bra	EdCent

	
* Routine: centre la fenetre editeur sur la position du curseur
EdCent:	move.w	#1,EtAX(a5)
	moveq	#15,d1
	move.w	EdXCu(a5),d0
	sub.w	EdXPos(a5),d0
	bcs.s	EdC1
	cmp.w	#4,d0
	bcs.s	EdC1
	moveq	#EdTx-15,d1
	cmp.w	#EdTx-4,d0
	bls	EdLoca
EdC1:	move.w	EdXCu(a5),d0
	sub.w	d1,d0
	bcc.s	EdC2
	moveq	#0,d0
EdC2:	cmp.w	EdXPos(a5),d0
	beq	EdLoca
	move.w	d0,EdXPos(a5)
	move.w	#SlDelai,EtASlX(a5)
	bra	AffBuf

******* Debut ligne
DLigne:	
DLigneT:clr.w	EdXCu(a5)
	bra	EdCent

******* Fin ligne
FLigne:	bsr	LCourant
	move.w	d0,EdXCu(a5)
	bra	EdCent

******* Page up
PHaut:	bsr	TokCur
	move.w	#1,EtAY(a5)
	move.w	#SlDelai,EtASlY(a5)
	tst.w	EdYPos(a5)
	beq	HTex
	move.w	EdTyM2(a5),d0
	sub.w	d0,EdYPos(a5)
	bcc	NewBuf
	clr.w	EdYPos(a5)
	bra	NewBuf

******* Page down
PBas:	bsr	TokCur
	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	add.w	EdTyM2(a5),d0
	cmp.w	EdNLigne(a5),d0
	bcc	BTex
	move.w	EdTyM2(a5),d0
	add.w	d0,EdYPos(a5)
	move.w	#1,EtAY(a5)
	move.w	#SlDelai,EtASlY(a5)
	bra	NewBuf

******* Scrolling sous le curseur HAUT
EdSHaut:bsr	TokCur
	tst.w	EdYPos(a5)
	beq	CHtE
	subq.w	#1,EdYPos(a5)
	bsr	CuOff
	moveq	#0,d1
	moveq	#0,d2
	WiCall	Locate
	bra	CHt

******* Scrolling sous le curseur BAS
EdSBas:	bsr	TokCur
	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	cmp.w	EdNLigne(a5),d0
	bcc	CBasE
	addq.w	#1,EdYPos(a5)
	bsr	CuOff
	moveq	#0,d1
	move.w	EdTyM1(a5),d2
	WiCall	Locate
	bra	CBs

******* Scrolling sous le curseur GAUCHE
EdSGauche:
	bsr	TokCur
	tst.w	EdXPos(a5)
	beq	CFin
	subq.w	#1,EdXCu(a5)
	bra	CGo

******* Scrolling sous le curseur DROITE
EdSDroite:
	bsr	TokCur
	move.w	EdXCu(a5),d0
	cmp.w	#250,d0
	bcc	CFin
	addq.w	#1,EdXCu(a5)
	bra	CDr

******* Haut du texte
HTexte:	bsr	TokCur
HTex:	clr.w	EdYPos(a5)
	clr.w	EdXPos(a5)
	clr.w	EdYCu(a5)
	clr.w	EdXCu(a5)
	move.w	#SlDelai,EtASlX(a5)
	move.w	#SlDelai,EtASlY(a5)
	bsr	NewBuf
	bra	CHtE

******* Bas du texte
BTexte:	bsr	TokCur
BTex:	move.w	EdNLigne(a5),d0
	move.w	EdTyM0(a5),d1
	lsr.w	#1,d1				*XXX EdTy-EdTY/3
	sub.w	d1,d0
	bcc.s	BTx1
	moveq	#0,d0
BTx1:	move.w	d0,EdYPos(a5)
	neg.w	d0
	add.w	EdNLigne(a5),d0
	move.w	d0,EdYCu(a5)
	clr.w	EdXPos(a5)
	clr.w	EdXCu(a5)
	move.w	#SlDelai,EtASlX(a5)
	move.w	#SlDelai,EtASlY(a5)
	bsr	NewBuf
	bra	CBasE

******* NEXT / PREVIOUS label
PLabel:	bsr	TokCur
	bsr	NLab
	move.w	d1,d0
	beq	HTexte
	bra.s	NLb1
NLabel:	bsr	TokCur
	bsr	NLab
	move.w	d2,d0
	beq	HTexte
NLb1:	cmp.w	EdNLigne(a5),d0
	bcc	BTexte
	move.w	#1,EtAX(a5)
	move.w	#1,EtAY(a5)
	move.w	#SlDelai,EtASlY(a5)
	move.w	#SlDelai,EtASlX(a5)
	move.w	d0,d1
	sub.w	EdYCu(a5),d0
	bpl.s	NLb2
	clr.w	d0
	move.w	d1,EdYCu(a5)
NLb2:	move.w	d0,EdYPos(a5)
	clr.w	EdXCu(a5)
	bra	NewBuf

* Routine situe le label AVANT et APRES LCour: D1= avant / D2= apres
* XXX verifier si dans procedure fermee ou ouverte!
NLab:	move.w	EdYPos(a5),d3
	add.w	EdYCu(a5),d3
	moveq	#0,d1
	moveq	#-1,d2
	bsr	FindL
	bra.s	NLab1
NLab0:	bsr	NextL
NLab1:	beq.s	NLab3
	addq.l	#1,d2
	move.w	2(a0),d0
	cmp.w	#TkProc-Tk,d0
	beq.s	NLab2
	cmp.w	#TkLab-Tk,d0
	bne.s	NLab0
NLab2:	cmp.w	d3,d2
	beq.s	NLab0
	bhi.s	NLab3
	move.w	d2,d1
	bra.s	NLab0
NLab3:	rts

***********************************************************
*	MARKS


******* Laisse une marque
SetMark	Alea	SMark,a0
	moveq	#1,d6
	bsr	EtChif0
	bra.s	SMark0
SMark9	addq.w	#1,d0
SMark8	addq.w	#1,d0
SMark7	addq.w	#1,d0
SMark6	addq.w	#1,d0
SMark5	addq.w	#1,d0
SMark4	addq.w	#1,d0
SMark3	addq.w	#1,d0
SMark2	addq.w	#1,d0
SMark1	addq.w	#1,d0
SMark0	bsr	TokCur
	lea	EdMarks(a5),a0
	lsl.w	#2,d0
	pea	0(a0,d0.w)
	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	bsr	FindL
	moveq	#0,d0
	move.w	EdXCu(a5),d0
	ror.l	#8,d0
	sub.l	StMini(a5),a0
	move.l	a0,d1
	or.l	d1,d0
	move.l	(sp)+,a0
	move.l	d0,(a0)
	bra	AverFin
******* Va a une marque
GoMark	Alea	SMark,a0
	moveq	#1,d6
	bsr	EtChif0
	bra.s	GMark0
GMark9	addq.w	#1,d0
GMark8	addq.w	#1,d0
GMark7	addq.w	#1,d0
GMark6	addq.w	#1,d0
GMark5	addq.w	#1,d0
GMark4	addq.w	#1,d0
GMark3	addq.w	#1,d0
GMark2	addq.w	#1,d0
GMark1	addq.w	#1,d0
GMark0	bsr	TokCur
	lea	EdMarks(a5),a0
	lsl.w	#2,d0
	move.l	0(a0,d0.w),d1
	beq	NoMark
	move.l	d1,d0
	and.l	#$FFFFFF,d1
	add.l	StMini(a5),d1
	move.l	d1,a0
	swap	d0
	lsr.w	#8,d0
	bra	EdSetXY
NoMark	moveq	#100,d0
	Alea	NMark,a0
	bra	Alert	

***********************************************************
*	TOUCHES DE FONCTIONS
***********************************************************

******* Entree touche de fonction
EdTFonc:move.l	(sp)+,d1
	moveq	#0,d0
	move.b	d6,d0
	sub.w	#$50,d0
	add.w	FkJeu(a5),d0
FkBis:	move.w	d0,d2		* D2 index de la touche
	move.w	d0,d1
	addq.w	#1,d2
	lsl.w	#2,d0
	lea	EdFcIn(pc),a0
	pea	0(a0,d0.w)
* Passe la touche en blanc?
	ext.l	d1
	divu	#10,d1
	move.w	d1,d0
	lsl.w	#1,d0		* pointe le MOT
	swap	d1
	neg.w	d1
	add.w	#9,d1		* Pointe le Bit
	lea	FkFlags(pc),a0
	move.w	0(a0,d0.w),d0
	btst	d1,d0
	beq.s	FkBis1
	moveq	#20,d0
	bsr	EfTemp
	EcCalD	Active,EcFonc
	move.w	#-1,FkOJeu(a5)
	bsr	FkReAff
	EcCalD	Active,EcEdit
* Appele la touche
FkBis1:	bsr	ClEProc
	clr.w	T_Actualise(a5)
	move.l	(sp)+,a0
	jsr	(a0)
	EcCalD	Active,EcFonc
	bsr	EtFree
	bsr	EtChip
	bsr	EtFast
	bsr	EtNom
	bra	EdLoop

EdFcIn:	bra	Run		;F1-  Run
	bra	PrgTest		;F2-  Test
	bra	Indent		;F3-  Indent
	bra	MBloc		;F4-  Menu blocs
	bra	MSear		;F5-  Menu Search
	bra	JTutor		;F6-  TUTOR!   
	bra	JHelp		;F7-  HELP!
	bra	FkIns		;F8-  Insert
	bra	EdFold		;F9-  Open/Close Proc
	bra	InsLine		;F10- Line Insert

	bra	EdLoad		;F11- Load normal
	bra	EdSave		;F12- Save
	bra	EdSaveAs	;F13- Save As
	bra	EdMerge		;F14- Merge
	bra	EdLoadA		;F15- Merge Ascii
	bra	EdEnv		;F16- Environnement
	bra	EdLRunBob	;F17- Load Other
	bra	EdLRunDisc	;F18- New Other
	bra	EdNew		;F19- New
	bra	EdQuit		;F20- Quit

	bra	SDBloc		;F21- Debut bloc
	bra	EdBlCut		;F22- Cut
	bra	EdBlMve		;F23- Move
	bra	SHBloc		;F24- Hide
	bra	EdSBlA		;F25- Save Ascii
	bra	SFBloc		;F26- Fin bloc
	bra	EdBlPas		;F27- Paste
	bra	EdBSto		;F28- Store
	bra	EdSBloc		;F29- Save
	bra	EdPrt		;F30- Print

	bra	EdSch		;F31- Search
	bra	EdSchN		;F32- Search Next
	bra	EdSchT		;F33- Search Top
	bra	EdRep		;F34- Replace 
	bra	EdRepA		;F35- Replace All
	bra	SetSch		;F36- Lower / Upper
	bra	EdFAOp		;F37- Open All
	bra	EdFACl		;F38- Close All
	bra	EdSSize		;F39- Text Buffer Size
	bra	EdSTab		;F40- Set tab

FkFlags dc.w	%0111111110
	dc.w	%1111111111
	dc.w 	%1111111111
	dc.w	%1111111111

FRien:	rts
JTutor	jmp	Edit_Tutor

******* Appele de la routine HELP
*	Met le mot sous le curseur en A0/D0
JHelp	bsr	LCourant
	move.l	a1,a0
	sub.w	d1,d0
	bpl.s	.skip
	moveq	#0,d0
.skip	jmp	Help_Edit
******* SHIFT HELP
*	Informations sur les touches de fonction
JSHelp	lea	.SHelp(pc),a0
	moveq	#6,d0
	jmp	Help_Edit
.SHelp	dc.b	"EDITOR"
	even

******* Passe au nouvel environnement de couleurs
EdEnv	addq.w	#1,Environs(a5)
	and.w	#$07,Environs(a5)
SetEnv	lea	Environs(a5),a2
	move.w	(a2)+,d0
	mulu	#(1+8+8)*2,d0
	add.w	d0,a2
* Colour back
	move.w	(a2)+,d1
	move.w	d1,EdColB(a5)
	EcCall	SColB
* Ecran edition...
	EcCalD	Active,EcFonc
	bsr.s	.rout
	EcCalD	Active,EcEdit
	bsr.s	.rout
* Calcule la liste copper
	bsr	ReCop
	rts
* Routinette
.rout	moveq	#0,d1
.loop2	move.w	(a2)+,d2
	movem.l	d1/a2,-(sp)
	EcCall	SCol
	movem.l	(sp)+,d1/a2
	addq.w	#1,d1
	cmp.w	#8,d1
	bne.s	.loop2
	rts

******* Passe au menu BLOCS
MBloc:	move.w	#-1,FkMFlag(a5)
	move.w	#20,FkJeu(a5)
	rts
******* Passe au menu SEARCH
MSear:	move.w	#-1,FkMFlag(a5)
	move.w	#30,FkJeu(a5)
	rts

******* Insert / Overwrite
FkIns:	not.b	EdInsert(a5)
	bsr	FkIPoke
	moveq	#10,d0
	bsr	EfTemp
	EcCalD	Active,EcFonc
	bra	EtIns

******* Indentation automatique!
Indent:	
* Teste
	bsr	TokCur
	bsr	VaTester
* Calcule l'indentation
	move.l	StBas(a5),a0
	moveq	#0,d6
IndLine	move.l	a0,a1		* Adresse de debut de ligne
	moveq	#0,d4
	moveq	#0,d7
	move.w	d6,d5
	tst.w	(a0)+
	beq	IndX
IndLoop	move.w	(a0)+,d0
	beq	IndFL
	bsr	TInst
	cmp.w	#TkProc-Tk,d0
	beq.s	IndPro
	cmp.w	#TkEndP-Tk,d0
	beq.s	IndProF
	cmp.w	#TkFor-Tk,d0
	beq.s	IndPls
	cmp.w	#TkRpt-Tk,d0
	beq.s	IndPls
	cmp.w	#TkWhl-Tk,d0
	beq.s	IndPls
	cmp.w	#TkDo-Tk,d0
	beq.s	IndPls
	cmp.w	#TkIf-Tk,d0
	beq.s	IndPls
	cmp.w	#TkThen-Tk,d0
	beq.s	IndThen
	cmp.w	#TkElse-Tk,d0
	beq.s	IndElse
	cmp.w	#TkEndI-Tk,d0
	beq.s	IndMns
	cmp.w	#TkNxt-Tk,d0
	beq.s	IndMns
	cmp.w	#TkUnt-Tk,d0
	beq.s	IndMns
	cmp.w	#TkWnd-Tk,d0
	beq.s	IndMns
	cmp.w	#TkLoo-Tk,d0
	beq.s	IndMns
	bra.s	IndLoop
* Debut d'une procedure: RAZ
IndPro:	moveq	#0,d5
	move.w	EdTabs(a5),d6
	tst.b	10(a1)
	bpl.s	IndLoop
	moveq	#0,d6
	move.l	4(a1),d0
	lea	12+2(a1,d0.l),a0
	bra	IndFL
* Fin d'une procedure
IndProF	moveq	#0,d5
	moveq	#0,d6
	bra	IndLoop
* Debut d'une boucle: + pour la ligne suivante
IndPls:	addq.w	#1,d7
	add.w	EdTabs(a5),d6	
	bra	IndLoop
* Fin d'une boucle: - pour cette ligne et la suivante
IndMns:	subq.w	#1,d7
	bpl.s	IndM
	clr.w	d7
	sub.w	EdTabs(a5),d5
	sub.w	EdTabs(a5),d6
	bra	IndLoop
IndM:	sub.w	EdTabs(a5),d6
	bra	IndLoop
* THEN: met le flag pour ELSE
IndThen:moveq	#1,d4
	bra.s	IndMns
* ELSE: si FLAG, ne fait RIEN
IndElse tst.w	d4
	bne	IndLoop
	sub.w	EdTabs(a5),d5
	bra	IndLoop
* Fin d'une ligne: poke D5!
IndFL:	tst.w	d5
	bpl.s	IndFl1
	clr.w	d5
IndFl1:	cmp.w	#127,d5
	bcs.s	IndFl2
	moveq	#127,d5
IndFl2:	addq.w	#1,d5
	move.b	d5,1(a1)
	bra	IndLine
* Fin de l'indentation automatique
IndX:	bsr	NewBuf
	rts

******* OPEN / CLOSE ALL PROCEDURES
EdFAOp	clr.w	-(sp)
	bra.s	EdFa0
EdFACl	move.w	#-1,-(sp)
EdFa0	bsr	TokCur
	bsr	VaTester
	clr.w	Y1Bloc(a5)
	clr.w	Y2Bloc(a5)
	move.w	(sp)+,d7
* Boucle
	clr.w	d0
	bsr	FindL
	beq	EdFa3
EdFa1	cmp.w	#TkProc-Tk,2(a0)
	bne.s	EdFa2
	btst	#6,10(a0)
	bne.s	EdFa2
	bclr	#7,10(a0)
	tst.w	d7
	beq.s	EdFa2
	bset	#7,10(a0)
EdFa2	bsr	NextL
	bne.s	EdFa1
EdFa3	bsr	CptLines
	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	bsr	EdSetY
	bra	NewBuf

******* OPEN / CLOSE PROCEDURE
EdFold	bsr	TokCur
* Plus de bloc!!!
	clr.w	Y1Bloc(a5)
	clr.w	Y2Bloc(a5)
* Trouve la ligne
	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	bsr	FindL
	move.l	DebProc(a5),d0
	beq.s	EdFoE
	move.l	d0,a0
	btst	#6,10(a0)
	bne.s	EdFo1
	btst	#7,10(a0)
	bne.s	EdFo2
	move.l	a0,-(sp)
	bsr	VaTester
	move.l	(sp)+,a0
EdFo2	bchg	#7,10(a0)
	bsr	CptLines
* Recentre (autour de l'erreur s'il faut)!
	move.l	DebProc(a5),a0
	tst.w	10(a0)
	bmi.s	EdFo0
	tst.l	AdEProc(a5)
	beq.s	EdFo1
	move.w	XEProc(a5),d0
	bsr	EdSetX
	move.l	AdEProc(a5),d0
	and.l	#$FFFFFF,d0
	move.l	d0,a0
EdFo0	bsr	FindA
	bsr	EdSetY
EdFo1	bsr	NewBuf
	rts	
EdFoE	Alea	NoFold,a0
	moveq	#100,d0
	bra	Alert
* Arret de l'auto-> centre
ClEProc	tst.l	AdEProc(a5)
	beq.s	ClEp2
	bmi.s	ClEp1
	bset	#7,AdEProc(a5)
	rts
ClEp1	clr.l	AdEProc(a5)
ClEp2	rts

***********************************************************
*	BLOCS

******* Set all
SABloc	bsr	TokCur
	moveq	#7,d0
	bsr	EzAlert
	bsr	EdBlFree
	clr.w	EdBloc(a5)
	clr.w	Y1Bloc(a5)
	move.w	EdNLigne(a5),Y2Bloc(a5)
	bra	AffBuf

******* Set debut
SDBloc	bsr	TokCur
	moveq	#3,d0
	bsr	EzAlert

	bsr	EdBlFree
	clr.w	EdBloc(a5)
	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	move.w	d0,Y1Bloc(a5)
	cmp.w	Y2Bloc(a5),d0
	bls	AffBuf
	move.w	d0,Y2Bloc(a5)
	bra	AffBuf

******* Set end
SFBloc	bsr	TokCur
	moveq	#4,d0
	bsr	EzAlert

	bsr	EdBlFree
	clr.w	EdBloc(a5)
	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	cmp.w	EdNLigne(a5),d0
	bne.s	SFBl1
	subq.w	#1,d0
SFBl1	addq.w	#1,d0
	move.w	d0,Y2Bloc(a5)
	cmp.w	Y1Bloc(a5),d0
	bcc	AffBuf
	move.w	d0,Y1Bloc(a5)
	bra	AffBuf
******* Hide
SHBloc	bsr	TokCur
	clr.w	Y1Bloc(a5)
	clr.w	Y2Bloc(a5)
	bra	AffBuf
******* Block STORE
EdbSto	bsr	EdBlSto
	moveq	#2,d0
	bra	EzAlert

EdBlSto	bsr	TokCur
	bsr	EdBlAd
	bsr	EdBlRes
	beq	EdOMm
* Copie les lignes
	move.l	a0,a2
	move.l	(a2),d1
	lsr.l	#1,d1
	move.l	a3,a0
	lea	6(a2),a1
BlSt1	move.w	(a0)+,(a1)+
	subq.l	#1,d1
	bne.s	BlSt1
* Compte les lignes ecrans du bloc
	bsr	EdBlCpt
	move.w	d0,d7
	rts
******* Block CUT
EdBlCut	bsr	TokCur
	moveq	#1,d0
	bsr	EzAlert
EdBlCt
	bsr	EdBlSto				* Stocke
	move.l	a3,a0
	move.l	a4,a1
	move.l	a1,d0
	sub.l	a0,d0
	bsr	DelBis
	clr.w	Y1Bloc(a5)			* Plus de bloc
	clr.w	Y2Bloc(a5)
EdBlPx	bsr	CptLines			* Recompte
	move.w	EdYPos(a5),d0			* Reaffiche
	add.w	EdYCu(a5),d0
	bsr	EdSetY
	bra	NewBuf
******* Block PASTE
EdBlPas	bsr	TokCur
	moveq	#6,d0
	bsr	EzAlert
EdBlPs
	tst.l	EdBlocAd(a5)
	bne.s	EdBlp1
	bsr	EdBlSto
EdBlp1	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	move.w	d0,d6
EdBlP2	bsr	FindL
	move.l	EdBlocAd(a5),a1
	move.l	(a1)+,d2
	move.w	(a1)+,d7
	bsr	StoI
	beq.s	EdBlPx
	bsr	NewBuf
	bra	RetOut
******* Bloc MOVE
EdBlMve	bsr	TokCur
	moveq	#5,d0
	bsr	EzAlert

	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	cmp.w	Y1Bloc(a5),d0			* Pas au milieu du bloc
	bcs.s	EBm0
	cmp.w	Y2Bloc(a5),d0
	bls	NotDone
EBm0	move.w	Y2Bloc(a5),-(sp)
	move.w	d0,-(sp)
	bsr	EdBlCt				* Cut
	move.l	EdBlocAd(a5),a0
	move.w	(sp)+,d0
	cmp.w	(sp)+,d0
	bcs.s	EBm2
	sub.w	4(a0),d0
	bcc.s	EBm1
	moveq	#0,d0
EBm1	bsr	EdSetY
EBm2	move.w	d0,-(sp)
	add.w	4(a0),d0
	move.w	d0,-(sp)
	bsr	EdBlPs				* Paste
	move.w	(sp)+,Y2Bloc(a5)
	move.w	(sp)+,Y1Bloc(a5)
	bra	AffBuf
******* Bloc FORGET
EdBlFor	jsr	TokCur
	moveq	#0,d0
* Routine: reserve le bloc, taille D0
EdBlRes	bsr	EdBlFree
	move.l	d0,d1
	addq.l	#6,d0
	jsr	RamFast
	beq	EdBlr
	move.l	d0,EdBlocAd(a5)
	move.l	d0,a0
	move.l	d1,(a0)
	moveq	#-1,d0
EdBlr	rts
* Routine: efface le bloc stocke
EdBlfree
	move.l	d0,-(sp)
	move.l	EdBlocAd(a5),d0
	beq.s	EbFx
	clr.l	EdBlocAd(a5)
	move.l	d0,a1
	move.l	(a1),d0
	addq.l	#6,d0
	jsr	RamFree
EbFx:	move.l	(sp)+,d0
	rts
* Routine: compte les lignes ecrans du bloc
EdBlCpt	move.l	EdBlocAd(a5),a2
	lea	6(a2),a0
	move.l	a0,a1
	add.l	(a2),a1
	moveq	#0,d0
	moveq	#0,d1
BlCp2	addq.w	#1,d0
	move.b	(a0),d1
	cmp.w	#TkProc-Tk,2(a0)
	bne.s	BlCp3
	tst.w	10(a0)
	bpl.s	BlCp3
	move.l	4(a0),d1
	lea	12+2(a0,d1.l),a0
	moveq	#0,d1
BlCp3	add.w	d1,a0
	add.w	d1,a0
	cmp.l	a1,a0
	bcs.s	BlCp2
BlCp4	move.w	d0,4(a2)
	rts
* Routine: trouve les adresses du bloc
* D0---> longueur / A3-A4---> Adresses
EdBlAd	move.w	Y1Bloc(a5),d0
	cmp.w	Y2Bloc(a5),d0
	bcc.s	NoBloc
	bsr	FindL
	move.l	a0,a3
	move.w	Y2Bloc(a5),d0
	bsr	FindL
	move.l	a0,d0
	move.l	a0,a4
	sub.l	a3,d0
	ble.s	NoBloc
	rts
* Pas de bloc!!!
NoBloc	Alea	WBloc,a0
	moveq	#100,d0
	bra	Alert
* Out of memory / alert
EdOMm	jsr	EffBanks
	jsr	ClearVar
	jsr	DefRun
	jsr	DefRun2
	Alea	EdOm,a0
	moveq	#120,d0
	bra	Alert

***********************************************************
*	TEXT BUFFER'S SIZE
EdSSize	bsr	TokCur
	bsr	Saved
	move.l	StTTexte(a5),d0
	Alea	EdTSize,a0
	moveq	#7,d6
	bsr	EtChD0
	cmp.l	#1024,d0
	bcs	NotDone
	cmp.l	StTTexte(a5),d0
	beq	NotDone
* On y va!
	move.l	d0,-(sp)
	bsr	RNew
	bsr	NewBuf
	move.l	(sp),d0
	move.l	StTTexte(a5),(sp)
	bsr	ChgTTexte
	beq.s	EdTs1
	addq.l	#4,sp
	bsr	RNew2
	bra	AverFin
EdTs1	move.l	(sp),d0
	bsr	ChgTTexte
	bne.s	EdTs2
	move.l	#1024,d0
	bsr	ChgTTexte
EdTs2	bsr	RNew2
	bra	EdOMm

***********************************************************
*	SET TAB VALUE
EdSTab	bsr	TokCur
	moveq	#0,d0
	move.w	EdTabs(a5),d0
	Alea	EdTTab,a0
	moveq	#1,d6
	bsr	EtChD0
	move.w	d0,EdTabs(a5)
	bra	AverFin

***********************************************************
*	SEARCH / REPLACE

******* Lower / Upper case
SetSch	not.w	SchMode(a5)
	bsr	FkLPoke
	moveq	#10,d0
	bsr	EfTemp
	rts
******* REPLACE
EdRep	bsr	TokCur
	tst.w	SchFlag(a5)
	beq.s	EdRep1
* Demande simplement la chaine
	bsr	GetRep
	bsr	AverFin
	rts
* Remplace/Passe au suivant
EdRep1	tst.b	RepBuf(a5)
	bne.s	EdRep2
	bsr	GetRep
EdRep2	lea	SchBuf(a5),a0
	bsr	CptRep
	move.w	d0,d3
	lea	RepBuf(a5),a0
	bsr	CptRep
	move.w	d0,d5
	bsr	LCourant
	bsr	RRep
	EcCalD	Active,EcEdit
	addq.w	#1,EdFlag(a5)
EdRep3	bra	EdSchN
******* REPLACE ALL
EdRepA	bsr	TokCur
	Alea	ConfConf,a0
	bsr	Confirm
	beq	NotDone
	bsr	GetSch
	bsr	GetRep
	move.w	EdYPos(a5),d4
	add.w	EdYCu(a5),d4
	move.w	EdXCu(a5),d6
	move.w	SchMode(a5),d7
	lea	SchBuf(a5),a0
	bsr	CptRep
	move.w	d0,d3
	lea	RepBuf(a5),a0
	bsr	CptRep
	move.w	d0,d5
	move.l	EdBufE(a5),a4
	bclr	#31,d7
* Trouve! Remplace...
EdRa1	bsr	Sch			* Premiere recherche
	beq	EdRa4
	move.w	d6,d0
EdRa2	move.w	d0,d6
	move.l	a4,a0
	lea	2(a4,d0.w),a1
	move.w	(a0)+,d0
	bsr	RRep
	lea	2(a4),a0		* Recherches suivantes
	lea	SchBuf(a5),a1
	bsr	RSearch
	bpl.s	EdRa2
EdRa3	movem.l	a4/d3-d7,-(sp)
	move.w	d4,-(sp)
	lea	2(a4),a3
	move.l	EdBufT(a5),a4
	bsr	Tokenise
	move.w	(sp)+,d1
	move.l	EdBufT(a5),a1
	bsr	Stocke
	bne	EdOMm
	movem.l	(sp)+,a4/d3-d7
	bset	#31,d7
* Ligne suivante
	moveq	#0,d6
	addq.w	#1,d4
	bra.s	EdRa1
* Fini!
EdRa4	tst.l	d7
	bpl	NoFound
	bsr	NewBuf
	bra	AverFin
******* SEARCH TOP
EdSchT	bsr	TokCur
	bsr	GetSch
	Alea	Sching,a0
	bsr	Avertir
	clr.w	d4
	clr.w	d6
	bra.s	STop

******* SEARCH
EdSch	bsr	TokCur
	bsr	GetSch
******* SEARCH NEXT
EdSchN	bsr	TokCur
	Alea	Sching,a0
	bsr	Avertir
	lea	SchBuf(a5),a0
	tst.b	(a0)
	beq	NotDone
	move.w	EdYPos(a5),d4
	add.w	EdYCu(a5),d4
	move.w	EdXCu(a5),d6
	addq.w	#1,d6
STop	move.w	SchMode(a5),d7
	move.l	EdBufT(a5),a4
	bsr	Sch
	bpl.s	NoFound
	move.w	d6,d0
	bsr	EdSetX
	move.w	d4,d0
	bsr	EdSetY
	bsr	NewBuf
	bsr	AverFin
	move.w	#1,SchFlag(a5)
	rts
NoFound	bsr	NewBuf
	Alea	NFound,a0
	moveq	#100,d0
	bra	Alert
******* Demande la chaine a entrer
GetSch	lea	SchBuf(a5),a0
	move.l	EdBufT(a5),a1
	bsr	CoCop
	moveq	#32,d6
	Alea	Schinp,a0
	bsr	EtInput
	move.l	EdBufT(a5),a0
	lea	SchBuf(a5),a1
	bsr	CoCop
	rts
******* Demande la chaine a entrer
GetRep	lea	RepBuf(a5),a0
	move.l	EdBufT(a5),a1
	bsr	CoCop
	moveq	#32,d6
	Alea	RepInp,a0
	bsr	EtInput
	move.l	EdBufT(a5),a0
	lea	RepBuf(a5),a1
	bsr	CoCop
	rts
******* Recherche a partir de D4 - D6=X
Sch	move.w	d4,d0
	bsr	FindL
	beq	SrchN
	move.l	a0,a6
Srch1	sub.l	a3,a3
	movem.l	d3-d7/a4/a6,-(sp)
	bsr	Detok
	movem.l	(sp)+,d3-d7/a4/a6
	move.w	(a4),d0
	cmp.w	d0,d6
	bcc.s	Srch2
	clr.b	2(a4,d0.w)
	lea	2(a4),a0
	lea	SchBuf(a5),a1
	bsr	RSearch
	bpl.s	SrchT
Srch2	moveq	#0,d6
	moveq	#0,d0
	move.b	(a6),d0
	beq.s	SrchN
	cmp.w	#TkProc-Tk,2(a6)
	bne.s	Srch3
	tst.w	10(a6)
	bpl.s	Srch3
	move.l	4(a6),d0
	lea	12+2(a6,d0.l),a6
	moveq	#0,d0
Srch3	add.w	d0,a6
	add.w	d0,a6
	addq.w	#1,d4
	tst.w	(a6)
	beq.s	SrchN
	move.w	T_Actualise(a5),d0
	bclr	#BitControl,d0
	beq.s	Srch1
	move.w	d0,T_Actualise(a5)
SrchN	moveq	#0,d0
	rts
SrchT	move.w	d0,d6
	moveq	#-1,d0
	rts
* Routine SEARCH
*	Cherche A1
*	Dans A0
*	D6-> Flags
RSearch	movem.l	a1/d1-d4,-(sp)
	move.l	a0,d4
	add.w	d6,a0
	move.b	(a1)+,d0
	bsr	MajD0
	move.b	d0,d1
	move.l	a1,d3
RSe1	move.b	(a0)+,d0		* Cherche la 1ere lettre
	beq.s	RSeN
	bsr	MajD0
	cmp.b	d0,d1
	bne.s	RSe1
	move.l	a0,d2
	swap	d1
RSe2	move.b	(a1)+,d0
	beq.s	RSeT
	bsr	MajD0
	move.b	d0,d1
	move.b	(a0)+,d0
	bsr	MajD0
	cmp.b	d0,d1
	beq.s	RSe2
	move.l	d2,a0
	move.l	d3,a1
	swap	d1
	bra.s	RSe1
RSeN	movem.l	(sp)+,a1/d1-d4
	moveq	#-1,d0
	rts
RSeT	move.l	d2,d0
	sub.l	d4,d0
	subq.l	#1,d0
	movem.l	(sp)+,a1/d1-d4
	rts
******* Routine REPLACE
* A0= Chaine a changer
* A1= Position!
RRep:	movem.l	a0-a2,-(sp)
	move.l	a0,d1
	clr.b	0(a0,d0.w)
	move.l	a1,a2
	move.l	a1,a0
	add.w	d3,a0
RChg1	move.b	(a0)+,(a1)+
	bne.s	RChg1
* Place pour le nouveau
	move.l	a1,a0
	add.w	d5,a1
	sub.l	a1,d1
	neg.l	d1
	cmp.w	#252,d1
	bcc	NoRep
RChg2	move.b	-(a0),-(a1)
	cmp.l	a2,a0
	bcc.s	RChg2
* Poke le nouveau
	lea	RepBuf(a5),a0
	move.w	d5,d0
	subq.w	#1,d0
RChg3	move.b	(a0)+,(a2)+
	dbra	d0,RChg3
* Change la longueur de la ligne / pointe la fin du mot
	movem.l	(sp)+,a0-a2
	add.w	d5,d6
	subq.w	#1,d1
	move.w	d1,-2(a0)
	moveq	#0,d0
	rts
* Line too long
NoRep	bsr	NewBuf
	Alea	EdLLong,a0
	moveq	#100,d0
	bra	Alert
* Routine: compte le buffer REPLACE
CptRep	moveq	#-1,d0
CRp1	addq.w	#1,d0
	tst.b	(a0)+
	bne.s	CRp1
	tst.w	d0
	beq	NotDone
	rts

***********************************************************
* 	QUIT!
EdQuit:	bsr	TokCur
	Alea	ConfConf,a0
	bsr	Confirm
	bne	Quit
	rts
Quit:	bsr	Saved
	bsr	RNew
	jsr	OpeWB
	tst.w	WbClose(a5)
	beq	TheEnd
PaQuit:	Alea	Cloclo,a0
	moveq	#100,d0
	bra	Alert

* Poke Lower=Upper dans les touches
FkLPoke	Alea	FkLt0,a1
	tst.s	SchMode(a5)
	beq.s	FkL1
	Alea	FkLt1,a1
FkL1	moveq	#36,d2
	bra.s	FkPoke
* Poke INSERT dans les touches
FkIPoke:Alea	FkIt0,a1
	tst.b	EdInsert(a5)
	beq.s	FkI1
	Alea	FkIt1,a1
FkI1:	moveq	#8,d2
* Poke le mot A1 dans la touche D2
FkPoke	moveq	#0,d3
	bsr	FkAct
	moveq	#10,d0
	lea	10(a0),a0
FkI2:	move.b	(a1)+,(a0)+
	dbra	d0,FkI2
	addq.w	#1,EdAfFk(a5)
	rts	

******* Active temporairement une touche de fonction
EfTemp:	move.w	d0,EdFkCpt(a5)
	moveq	#"1",d3

******* Active la touche D2 (D3= "0" ou "1")
FkAct:	move.l	d2,-(sp)
	Alea	FkDef1,a0
	addq.l	#FkTDef,a0
	sub.w	#FkLong,a0
	cmp.w	#11,d2
	bcs.s	FkAc
	Alea	FkDef2,a0
	addq.l	#FkTDef,a0
	sub.w	#11*FkLong,a0
	cmp.w	#21,d2
	bcs.s	FkAc
	Alea	FkDef3,a0
	addq.l	#FkTDef,a0
	sub.w	#21*FkLong,a0
	cmp.w	#31,d2
	bcs.s	FkAc
	Alea	FkDef4,a0
	addq.l	#FkTDef,a0
	sub.w	#31*FkLong,a0
FkAc:	mulu	#FkLong,d2
	lea	2(a0,d2.w),a0
	tst.b	d3
	beq.s	FkAc2
	move.b	d3,(a0)
	addq.w	#1,EdAfFk(a5)
FkAc2:	move.l	(sp)+,d2
	rts

******* Re-affichage des touches de fonction?
FkReAff:tst.w	AmiAff(a5)
	bpl.s	FkPaAf
	move.w	FkJeu(a5),d0
	cmp.w	FkOJeu(a5),d0
	bne.s	FkA1
	tst.w	EdAfFk(a5)
	beq.s	FkPaAf
FkA1:	move.w	d0,FkOJeu(a5)
	clr.w	EdAfFk(a5)
	Alea	FkDef1,a1
	cmp.w	#10,d0
	bcs.s	FkA2
	Alea	FkDef2,a1
	cmp.w	#20,d0
	bcs.s	FkA2
	Alea	FkDef3,a1	
	cmp.w	#30,d0
	bcs.s	FkA2
	Alea	FkDef4,a1	
FkA2:	WiCall	Print	
	bsr	EtChip
	bsr	EtFast
FkPaAf:	rts

***********************************************************
*	ROUTINES DIVERSES
***********************************************************

******* Ramene l'adresse de la ligne sous le curseur
*	A0= adresse
*	A1= lettre sous le curseur
*	D0= longueur
*	D1= position curseur
LCourant:
	move.w	EdYCu(a5),d0
	lsl.w	#8,d0
	move.l	EdBufE(a5),a0
	lea	0(a0,d0.w),a0
	move.w	(a0)+,d0
	move.w	EdXCu(a5),d1
	lea	0(a0,d1.w),a1
	rts

******* Sauve le programme si on l'a change!
Saved:	
	IFEQ	VDemo
	tst.w	EdChange(a5)
	beq.s	Sved
	Alea	ConfSave,a0
	bsr	Confirm
	beq.s 	Sved
	bsr	EdSave
	ENDC
Sved:	rts

******* DEMANDE CONFIRMATION!
Confirm:move.l	a0,-(sp)
	EcCalD	Active,EcFonc
	Alea	EtAl,a1
	WiCall	Print
	moveq	#"0",d6
	moveq	#"0",d7
* Affiche la phrase
Conf1:	move.l	(sp),a2
	move.l	EdBufT(a5),a0
	move.l	a0,a1
Conf2:	move.b	(a2)+,(a0)+
	bne.s	Conf2
	subq.l	#1,a0
	Alea	ConfYN,a2
Conf3:	move.b	(a2)+,(a0)+
	bne.s	Conf3
	subq.l	#1,a0
	Alea	ConfYi,a2
	move.b	d6,(a2)
Conf3a:	move.b	(a2)+,(a0)+
	bne.s	Conf3a
	subq.l	#1,a0
	Alea	ConfNi,a2
	move.b	d7,(a2)
Conf3b:	move.b	(a2)+,(a0)+
	bne.s	Conf3b
	WiCall	Centre
* Teste le clavier
ConfL:	SyCall	Inkey
	tst.l	d1
	beq.s	ConfB
	cmp.b	#"a",d1
	bcs.s	Conf4
	cmp.b	#"z",d1
	bhi.s	Conf4
	sub.b	#$20,d1
Conf4:	ALea	ConfYes,a0
	cmp.b	(a0),d1
	beq.s	ConfOui
	ALea	ConfNo,a0
	cmp.b	(a0),d1
	beq.s	ConfNon
* Appuie sur la souris?
ConfB:	SyCall	MouRel
	btst	#0,d1
	beq.s	Conf5
	cmp.b	#"1",d6
	beq.s	ConfOui
	cmp.b	#"1",d7
	beq.s	ConfNon
* Teste les zones
Conf5:	SyCall	GetZone
	moveq	#"0",d4
	moveq	#"0",d5
	cmp.w	#EcFonc,d1
	bne.s	Conf7
	swap	d1
	cmp.w	#1,d1
	bne.s	Conf6
	moveq	#"1",d4
Conf6:	cmp.w	#2,d1
	bne.s	Conf7
	moveq	#"1",d5
Conf7:	moveq	#0,d0
	cmp.b	d4,d6
	beq.s	Conf8
	move.b	d4,d6
	addq.w	#1,d0
Conf8:	cmp.b	d5,d7
	beq.s	Conf9
	move.b	d5,d7
	addq.w	#1,d0
Conf9:	tst.w	d0
	beq	ConfL
	bne	Conf1
* OUI!
ConfOui	move.w	#-1,-(sp)
	bra.s	ConfX
* NON!
ConfNon:clr.w	-(sp)
* Efface les deux zones!
ConfX:	SyCalD	RazZone,1
	SyCalD	RazZone,2
	bsr	AverFin
	move.w	(sp)+,d0
	addq.l	#4,sp
	rts

******* Initialise les touches de fonction AMIGA
AmiInit:moveq	#0,d1
	Alea	AmiDef,a1
Amii:	SyCall	SetFunK
	move.l	a0,a1
	addq.w	#1,d1
	cmp.w	#20,d1
	bcs.s	Amii
	rts
	
******* Locate le curseur dans l'ecran
EdLoca:	move.w	EdYCu(a5),d2
	move.w	EdXCu(a5),d1
	sub.w	EdXPos(a5),d1
	ext.l	d1
	ext.l	d2
	WiCall	Locate
	bsr	CuOn
	rts

******* Affiche le caractere ECRAN D2 de tout le buffer d'edition
AffBufCar:
	bsr	CuOff
	moveq	#0,d1
ABufC:	bsr	ACar
	addq.w	#1,d1
	cmp.w	EdTyM0(a5),d1
	bcs.s	ABufC
	bsr	EdLoca
	rts

******* Imprime le caractere ECRAN D2 de la ligne D1
ACar:	movem.l	d0-d4/a0,-(sp)	* Affiche seulement

* Locate en debut de ligne
	movem.w	d1/d2,-(sp)
	exg	d1,d2
	ext.l	d1
	ext.l	d2
	WiCall	Locate
	movem.w	(sp)+,d2/d3
* Pointe la ligne dans le buffer
	move.w	d2,d4
	lsl.w	#8,d2
	move.l	EdBufE(a5),a0
	lea	0(a0,d2.w),a0
	move.w	EdXPos(a5),d1
	add.w	d3,d1
	move.w	(a0)+,d0	* Longueur de la ligne
	cmp.w	d0,d1
	bcs.s	ACa1
* Imprime un 32
	moveq	#32,d1
	bra.s	ACa2
* Imprime le caractere
ACa1:	move.b	0(a0,d1.w),d1
	add.w	EdYPos(a5),d4
	cmp.w	Y1Bloc(a5),d4
	bcs.s	ACa2
	cmp.w	Y2Bloc(a5),d4
	bcc.s	ACa2
* En inverse
	move.w	d1,-(sp)
	Alea	EdDbloc,a1
	WiCall	Print
	move.w	(sp)+,d1
	WiCall	ChrOut
	Alea	EdFBloc,a1
	WiCall	Print
	bra.s	ACaF	
* Normal
ACa2:	WiCall	ChrOut
* Fini
AcAF:	movem.l	(sp)+,d0-d4/a0
	rts

******* Detokenise et affiche le buffer
NewBuf:	EcCalD	Active,EcEdit
	bsr	BufUntok
******* Affiche tout le buffer d'edition
AffBuf:	bsr	CuOff
	moveq	#0,d1
ABuf:	bsr	EALigne
	addq.w	#1,d1
	cmp.w	EdTyM0(a5),d1
	bcs.s	ABuf
	move.w	#1,EtASlX(a5)
	move.w	#1,EtASlY(a5)
	bsr	EdLoca
	rts

******* Imprime la ligne du buffer D1
EALigne:movem.l	d0-d2/a0-a2,-(sp)	* Efface
	bset	#30,d1
	bra.s	ALi0
ALigne:	movem.l	d0-d2/a0-a2,-(sp)	* Affiche seulement
	bclr	#30,d1
ALi0:
* Locate en debut de ligne
	move.l	d1,-(sp)
	move.w	d1,d2
	moveq	#0,d1
	ext.l	d2
	WiCall	Locate

* Passe en inverse?
	move.w	2(sp),d0
	add.w	EdYPos(a5),d0
	cmp.w	Y1Bloc(a5),d0
	bcs.s	ALi0a
	cmp.w	Y2Bloc(a5),d0
	bcc.s	ALi0a
	bset	#7,(sp)
	ALea	EdDbloc,a1
	WiCall	Print
ALi0a
* Pointe la ligne dans le buffer
	move.w	2(sp),d0
	lsl.w	#8,d0
	move.l	EdBufE(a5),a0
	lea	0(a0,d0.w),a0
	move.w	EdXPos(a5),d1
	move.w	(a0)+,d0		* Longueur de la ligne
	cmp.w	d0,d1
	bcc.s	ALiF
	lea	0(a0,d1.w),a1		* Pointe le debut
	add.w	#EdTx,d1
	move.w	d1,d2
	cmp.w	d0,d1
	bls.s	ALi1
	move.w	d0,d1
ALi1:	cmp.w	d0,d2
	bhi.s	Ali2
	bclr	#6,(sp)
ALi2:	lea	0(a0,d1.w),a2		* Marque la fin de la ligne
	move.b	(a2),d2
	clr.b	(a2)
	WiCall	Print			* Imprime
	move.b	d2,(a2)			* Restore la ligne

* Repasse en normal
ALiF	move.l	(sp)+,d2
	bpl.s	ALiFa
	Alea	EdFBloc,a1
	WiCall	Print
* Efface ---> fin ligne
ALiFa	btst	#30,d2
	beq.s	ALiFb
	WiCalD	ChrOut,7
ALiFb
* Fini
	movem.l	(sp)+,d0-d2/a0-a2
	rts

******* Curseur ON/OFF
CuOn:	movem.l	d0/a0/a1,-(sp)
	ALea	ChCuOn,a1
	WiCall	Print
	movem.l	(sp)+,d0/a0/a1
	rts
CuOff:	movem.l	d0/a0/a1,-(sp)
	Alea	ChCuOff,a1
	WiCall	Print
	movem.l	(sp)+,d0/a0/a1
	rts

***********************************************************
*	GESTION LIGNE D'ETAT / SLIDERS
***********************************************************

******* Imprime une alerte EZAMOS
*	D0=	# alerte
EzAlert:
	lea	EzAlerts(a5),a0
	subq.w	#2,d0
	bmi.s	.Found
.Loop	tst.b 	(a0)+
	bne.s	.Loop
	dbra	d0,.Loop
.Found	moveq	#75,d0
	move.w	d0,EtMess(a5)
	move.l	a0,EtAlert(a5)
	rts

******* Imprime le slider VERTICAL
AffSlV:	moveq	#16-VSli_Fx-VSli_Dx,d1
	move.l	EdEcran(a5),a0
	move.w	EcTy(a0),d2
	sub.w	#8*3+VSli_Dy+VSli_Fy,d2
	move.w	EdNLigne(a5),d3
	move.w	EdYPos(a5),d4
	move.w	EdTyM0(a5),d5
	move.w	#Ed_Sx-16+VSli_Dx,d6
	moveq	#0+VSli_Dy,d7
	movem.l	d1-d7,-(sp)
	EcCall	VerSli
	movem.l	(sp)+,d1-d7
	move.w	d2,d0
	jsr	SliPour
	move.w	d6,Ed_slv1
	move.w	d7,Ed_slv2
	rts

******* Imprime le slider HORIZONTAL
AffSlH:	move.w	#Ed_Sx-16*3-HSli_Dx-HSli_Fx,d1
	moveq	#8-HSli_Dy-HSli_Fy,d2
	move.w	#254,d3
	move.w	EdXPos(a5),d4
	moveq	#EdTx,d5
	moveq	#HSli_Dx,d6
	move.l	EdEcran(a5),a0
	move.w	EcTy(a0),d7
	add.w	#-8+HSli_Dy,d7
	movem.l	d1-d7,-(sp)
	EcCall	HorSli
	movem.l	(sp)+,d1-d7
	move.w	d1,d0
	jsr	SliPour
	move.w	d6,Ed_slh1
	move.w	d7,Ed_slh2
	rts

******* Imprime la ligne
EtLine:	tst.w	EtMess(a5)
	bne.s	EtF
	ALea	EtY,a1
	WiCall	Print
	move.w	EdYPos(a5),d0
	add.w	EdYCu(a5),d0
	addq.w	#1,d0
	ext.l	d0
	Alea	EtY1,a0
	bsr	LongDec
	clr.b	(a0)
	ALea	EtY1,a1
	WiCall	Print
EtF:	rts

******* Imprime la colonne
EtCol:	tst.w	EtMess(a5)
	bne.s	EtF
	Alea	EtX,a1
	WiCall	Print
	move.w	EdXCu(a5),d0
	addq.w	#1,d0
	Alea	EtX1,a0
	bsr	LongDec
	clr.b	(a0)
	Alea	EtX1,a1
	WiCall	Print
	rts

******* Imprime la memoire libre
EtFree:	tst.w	EtMess(a5)
	bne.s	EtF
	ALea	EtFr0,a1
	WiCall	Print
	move.l	StBas(a5),d0
	sub.l	StMini(a5),d0
	Alea	EtFr1,a0
	bsr	LongDec
	clr.b 	(a0)
	ALea	EtFr1,a1
	WiCall	Print
	rts

******* Imprime la CHIP MEM
EtChip:	tst.w	EtMess(a5)
	bne	EtF
	Alea	EtCh0,a1
	WiCall	Print
	move.l	$4.w,a6
	moveq	#02,d1
	jsr	AvailMem(a6)
	Alea	EtFs1,a0
	bsr	LongDec
	clr.b 	(a0)
	Alea	EtFs1,a1
	WiCall	Print
	rts

******* Imprime la FAST MEM
EtFast:	tst.w	EtMess(a5)
	bne	EtF
	Alea	EtFs0,a1
	WiCall	Print
	move.l	$4.w,a6
	moveq	#04,d1
	jsr	AvailMem(a6)
	Alea	EtFs1,a0
	bsr	LongDec
	clr.b 	(a0)
	Alea	EtFs1,a1
	WiCall	Print
	rts

******* Imprime le NOM DU PROGRAMME
EtNom	tst.w	EtMess(a5)
	bne	EtF
	Alea	EtNm1,a1
	WiCall	Print
* Copie le nom
	lea	NamePrg(a5),a0
	tst.b	(a0)
	beq	Etnn0
	bsr	DNom
Etnn0	Alea	EtNm2,a1
	move.l	a1,a2
Etnn1	tst.b	(a0)
	beq.s	Etnn2
	move.b	(a0)+,(a2)+
	tst.b	(a2)
	bne.s	Etnn1
	beq.s	Etnn3
Etnn2	tst.b	(a2)
	beq.s	Etnn3
	move.b	#" ",(a2)+
	bra.s	Etnn2
Etnn3	WiCall	Print
	rts
	
******* CAPS
EtCaps:	tst.w	EtMess(a5)
	bne	EtF
	Alea	EtCps0,a1
	tst.w	EtCps(a5)
	beq.s	EtC2
	Alea	EtCps1,a1
EtC2:	WiCall	Print
	rts

******* INSERT
EtIns:	tst.w	EtMess(a5)
	bne	EtF
	Alea	EtIns0,a1
	tst.b	EdInsert(a5)
	beq.s	EtI1
	Alea	EtIns1,a1
EtI1:	WiCall	Print
	rts

******* ERREUR ou ALERTE????
AlOuErr	tst.w	EsFlag(a5)
	beq.s	Alert
	move.w	#256,d0
	moveq	#19,d1
	moveq	#-1,d2
	jmp	RunErrExt

******* MESSAGE D'ALERTE
Alert:	move.w	d0,EtMess(a5)
	move.l	a0,EtAlert(a5)
	move.l	BasSp(a5),sp
	move.l	EdBufT(a5),a1
	lea	256(a1),a1
	move.l	#$FFFE0102,(a1)+
Alrt	move.b	(a0)+,(a1)+
	bne.s	Alrt
	bsr	FClose
	bsr	EscToEd
	SyCall	ClearKey
	bra	EdLoop
******* Recall MESSAGE D'ALERTE
RAlert	moveq	#100,d0
	move.l	EdBufT(a5),a0
	lea	256(a0),a0
	cmp.l	#$FFFE0102,(a0)+
	beq.s	Alert
	rts

******* Affiche un AVERTISSEMENT
Avertir:move.l	a0,-(sp)
	EcCalD	Active,EcFonc
	Alea	EtAl,a1
	WiCall	Print
	move.l	(sp)+,a1
	WiCall	Centre 
	EcCalD	Active,EcEdit
	rts
AverFin	EcCalD	Active,EcFonc
	clr.w	EtMess(a5)
	bsr	EtPrint
	EcCalD	Active,EcEdit
	rts

******* Affiche un message dans la barre
EtAff:	tst.w	EsFlag(a5)
	bne.s	EtPx
Eta2	clr.w	EtMess(a5)
	move.l	a0,-(sp)
	EcCalD	Active,EcFonc
	Alea	EtAl,a1
	WiCall	Print
	move.l	(sp)+,a1
	WiCall	Centre
	rts

******* IMPRIME TOUT
EtPrint:tst.w	EsFlag(a5)
	bne.s	EtPx
	Alea	EtClw,a1
	WiCall	Print
	bsr	EtCaps
	bsr	EtIns
	bsr	EtLine
	bsr	EtCol
	bsr	EtFree
	bsr	EtChip
	bsr	EtFast
	bsr	EtNom
EtPx:	rts

******* INPUT CHIFFRE D0
EtChD0	move.l	a0,-(sp)
	move.l	EdBufT(a5),a0
	bsr	LongDec
	clr.b	(a0)
	move.l	(sp)+,a0
	bra.s	EtChif
******* INPUT CHIFFRE >0
EtChif0	move.l	EdBufT(a5),a1
	clr.b	(a1)
EtChif	bsr	EtInput
	move.l	EdBufT(a5),a0
	bsr	ValTok
	tst.w	d2
	bne	NotDone
	tst.l	d0
	bmi	NotDone
	rts

******* INPUT A0 + Texte BUFTOK / D6= LMAX
EtInp0	move.l	EdBufT(a5),a1
	clr.b	(a1)
EtInput	move.l	a0,-(sp)
	EcCalD	Active,EcFonc
	ALea	EtClw,a1
	WiCall	Print
	WiCalD	Print,32
	move.l	(sp)+,a1
	WiCall	Print
	Alea	EtInp,a1
	WiCall	Print
	WiCall	XYCuWi
	move.l	EdBufT(a5),a4
	moveq	#0,d7
	bsr	LLEdit
	bsr	CuOff
	rts

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* MODE ESCAPE
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------



***********************************************************
*	PASSAGE EN MODE ESCAPE
***********************************************************
PreEsc:	bsr	TokCur
Escape:	move.l	BasSp(a5),sp
* Init Ecran
	bsr	EdToEsc
	clr.w	EFkFlag(a5)

***********************************************************
*	BOUCLE DU MODE ESCAPE
***********************************************************
EscLoop:
	ALea	EscOk,a1
	WiCall	Print
	move.l	Buffer(a5),a4
	clr.b	(a4)
EscL:	move.l	Buffer(a5),a4
	move.w	#146,d6
	moveq	#3,d7
	move.w	#10,d1
	move.w	EdTyM1(a5),d2
	bsr	LLEdit

EscL1:	beq	EscR
	move.w	d1,d0		* Isole les SHIFTS
	lsr.w	#8,d0
	cmp.b	#$45,d1		* ESC?
	beq	EscEs
	cmp.b	#$4C,d1		* Fleche vers le HAUT
	beq.s	EscH
	cmp.b	#$4D,d1		* Fleche vers le BAS
	beq.s	EscB
	cmp.b	#$5F,d1		* HELP
	beq	EscHlp
	cmp.b	#$50,d1		* Touches de fonction
	bcs.s	EscF
	cmp.b	#$59,d1
	bls	EscFonc
EscF:	bsr	LEdLoop
	bra.s	EscL1

******* Fleche vers le HAUT
EscH:	move.l	EdEcran(a5),a0
	and.b	#Shf,d0
	bne.s	EscHS
*	Monte toute la fenetre
	move.w	EcAWY(a0),d0
	add.w	EcAWTy(a0),d0
	bmi.s	EscF
	subq.w	#8,EcAWY(a0)
* Recalcule les ecrans
EscCal:	bset	#2,EcAW(a0)
	bset	#2,EcAWT(a0)
	bset	#2,EcAV(a0)
	bset	#4,T_Actualise(a5)
	bset	#4,ActuMask(a5)
	SyCall	WaitVBL
	bra.s	EscF
*	Agrandi la fenetre
EscHS:	move.w	EcAVy(a0),d0
	subq.w	#1,d0
	bmi.s	EscF
	moveq	#8,d0
	add.w	d0,EcAWTy(a0)	
	sub.w	d0,EcAVy(a0)
	tst.b	InterEdit(a5)
	beq.s	EscHs1
	moveq	#4,d0
EscHS1	sub.w	d0,EcAWy(a0)	
	bra.s	EscCal

******* Fleche vers le bas
EscB:	move.l	EdEcran(a5),a0
	and.b	#Shf,d0
	bne.s	EscBS
* 	Descend toute la fenetre
	move.w	EcAWY(a0),d0
	cmp.w	#312,d0
	bge	EscF
	addq.w	#8,EcAWY(a0)
	bra	EscCal
*	Reduit la fenetre
EscBS:	move.w	EcAWTy(a0),d0
	cmp.w	#16,d0
	bls	EscF
	moveq	#8,d0
	sub.w	d0,EcAWTy(a0)	
	add.w	d0,EcAVy(a0)
	tst.b	InterEdit(a5)
	beq.s	EscBS1
	moveq	#4,d0
EscBS1:	add.w	d0,EcAWy(a0)	
	bra	EscCal

******* Touche HELP
EscHlp:	bsr	HlpRt
	bra	EscLoop

* Routine HELP
HlpRt:	Alea	EscH1,a1
	WiCall	Print
	moveq	#0,d7
EHlp1:	move.w	d7,d1
	mulu	#5,d1
	Alea	EscH2,a1
	lea	0(a1,d1.w),a1	
	WiCall	Print
	move.w	d7,d1
	move.l	EdBufT(a5),a0
	move.l	a0,a1
	move.l	a1,a2
	bsr	SsGtKy
	moveq	#11-1,d1
	cmp.w	#4,d7
	beq.s	EHlp0
	cmp.w	#9,d7
	beq.s	EHlp0
	cmp.w	#14,d7
	beq.s	EHlp0
	cmp.w	#19,d7
	bne.s	EHlp2
EHlp0:	subq.w	#1,d1
EHlp2:	move.b	(a0)+,d0
	beq.s	EHlp5
	move.b	d0,(a2)+
	dbra	d1,EHlp2
	bra.s	EHlp6
EHlp5:	move.b	#" ",(a2)+
	dbra	d1,EHlp5
EHlp6:	move.b	#" ",(a2)+
	clr.b	(a2)
	WiCall	Print
	cmp.w	#4,d7
	beq.s	EHlp8
	cmp.w	#9,d7
	beq.s	EHlp8
	cmp.w	#14,d7
	bne.s	EHlp7
EHlp8:	ALea	EscH4,a1
	WiCall	Print
EHlp7:	addq.w	#1,d7
	cmp.w	#20,d7
	bcs	EHlp1
	Alea	EscH5,a1
	WiCall	Print
	rts

******* Touches de fonction 1-10
EscFonc:and.w	#$FF,d1
	sub.w	#$50,d1
	cmp.w	EFkFlag(a5),d1
	bcc	EscF
	move.w	d1,-(sp)
	move.l	a4,a0
EscF0:	tst.b	(a0)
	beq.s	EscF1
	move.b	#" ",(a0)+
	bra.s	EscF0
EscF1:	moveq	#10,d1
	move.w	EdTYM1(a5),d2
	WiCall	Locate
	move.l	a4,a1
	WiCall	Print
	move.w	(sp)+,d0
	mulu	#160,d0
	move.l	a4,a1
	move.l	BufEsc(a5),a0
	add.w	d0,a0
EscF2:	move.b	(a0)+,(a1)+
	bne.s	EscF2
	bra	EscL

******* Return en mode ESCAPE
EscR:	tst.w	d5
	beq	EscLoop
	Alea	CRet,a1
	WiCall	Print
	cmp.w	#75,d5
	bcs.s	EscR1
	Alea	CRet,a1
	WiCall	Print
* Stocke la chaine dans le buffer (si <>"")
EscR1:	tst.b	(a4)
	beq.s	EscR5
	move.l	a4,a0
	move.l	BufEsc(a5),a0
	lea	160*9(a0),a0
	lea	160(a0),a1
	move.w	#(160*9)/4-1,d0
EscR3:	move.l	-(a0),-(a1)
	dbra	d0,EscR3
	move.l	a4,a1
EscR4:	move.b	(a1)+,(a0)+
	bne.s	EscR4
	addq.w	#1,EFkFlag(a5)
EscR5:	move.l	a4,a3
	move.l	EdBufT(a5),a4
	bsr	Tokenise
	beq	EscLoop
	clr.w	(a4)
	bra	RunDirect
EscR2:	dc.b 13,10,10,0

***********************************************************
*	ENTREE EN MODE DIRECT
***********************************************************
EdToEsc:movem.l	d0-d7/a0-a6,-(sp)
	move.w	#1,Direct(a5)

******* Init fenetre direct
	bsr	EdHide
	bsr	SetEnv
	move.l	EdEcran(a5),a0
	move.w	EcPal+4(a0),EcPal(a0)

;	lea	EscPal(a5),a3		* Palette ESCAPE
;	moveq	#0,d7
;EdMc:	move.l	d7,d1
;	move.w	(a3)+,d2
;	EcCall	SCol
;	addq.w	#1,d7
;	cmp.w	#4,d7
;	bne.s	EdMc

	EcCalD	Active,EcEdit
	WiCalD	QWindow,0
	ALea	EscI,a1
	WiCall	Print
	bsr	HlpRt

******* Apparition de la fenetre
	move.l	EdEcran(a5),a4
	move.w	EsWTy(a5),EcAWTy(a4)
	bset	#2,EcAWT(a4)
	lea	EsVy(a5),a0
	move.w	(a0),EcAVy(a4)
	bset	#2,EcAV(a4)
	clr.w	EcCon2(a4)		* Sprites derriere ecran!

EsM2:	moveq	#0,d7
	move.w	EdVScrol(a5),d6
	move.w	EsWy(a5),d5
	move.l	a4,a0
	bsr	ChgEcran
	bsr	ReCop
	tst.w	d7
	bne.s	EsM2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

***********************************************************
*	SORTIE DU MODE ESCAPE
***********************************************************
EscToEd:tst.w	Direct(a5)
	beq	EsF1
	clr.w	Direct(a5)
	Alea	EscI0,a1
	WiCall	Print				* Arrete le curseur

* Stocke la position de la fenetre ESC
	move.l	EdEcran(a5),a0
	move.w	EcAWTy(a0),EsWTy(a5)		* Stocke
	move.w	EcAWy(a0),EsWy(a5)	
	move.w	EcAVy(a0),EsVy(a5)

* Amene la fenetre de fonction en bas
EsF0:	moveq	#0,d7
	move.w	#312,d5
	move.w	EdVScrol(a5),d6
	move.l	EdEcran(a5),a0
	bsr	ChgEcran
	bsr	ReCop
	tst.w	d7
	bne.s	EsF0

* Remet les pointeurs
	move.l	EdEcran(a5),a0
	clr.w	EcAVY(a0)
	bset	#2,EcAV(a0)
	move.w	EdTyM0(a5),d0
	addq.w	#1,d0
	mulu	#8,d0
	move.w	d0,EcAWTy(a0)
	bset	#2,EcAWT(a0)
	move.w	#%0100100,EcCon2(a0)		* Priorites des sprites

* Retour de l'editeur
EsF1:	tst.w	EsFlag(a5)
	beq.s	EsF2
	clr.w	EsFlag(a5)
EdRAff:	bsr	EdEcInit
	bsr	CptLines
	bsr	NewBuf
	bsr	AffSlV
	bsr	AffSlH	
	move.w	#1,EtMess(a5)
	clr.l	EtAlert(a5)
	WiCalD	QWindow,1

* Fait scroller les deux fenetres
	bsr	EdScrol
EsF2:	rts


	EndC


******* Routine-> majuscule
MajD0	tst.w	d7
	bpl.s	MajD1
MajD0a	cmp.b	#"a",d0
	bcs.s	MajD1
	cmp.b	#"z",d0
	bhi.s	MajD1
	sub.b	#$20,d0
MajD1	rts

***********************************************************
*	EDITEUR LIGNE
*	D7= Entree FLAG: retour si CURSEUR
*	A4= BUFFER
*	D6= LONGUEUR MAX
***********************************************************
LLEdit:	move.w	d1,LEdXCu(a5)
	move.w	d2,LEdYCu(a5)
	ext.l	d1
	ext.l	d2
	WiCall	Locate

******* Trouve la fin du mot
	moveq	#-1,d5
LEd1:	addq.w	#1,d5
	WiCalD	ChrOut,28
	cmp.w	d6,d5
	bcc.s	LEd2
	tst.b	0(a4,d5.w)
	bne.s	LEd1
LEd2:	clr.b	0(a4,d5.w)
	move.w	d5,d4
	WiCalD	ChrOut,29

******* Boucle de l'editeur
LEdLoop:WiCalA	Print,LEdP1(pc)		* Souvenir curseur
	move.w	LEdXCu(a5),d1
	move.w	LEdYCu(a5),d2
	ext.l	d1
	ext.l	d2
	WiCall	Locate
	move.l	a4,a1
	WiCall	Print			* Imprime la chaine
	WiCalA	Print,LEdP2(pc)		* Relocate
	clr.b	0(a4,d5.w)		* Efface le 32 si BACKSPACE

LEdL:	btst	#2,d7			* Correction du BUG input!
	beq.s	LEdL0
	move.w	T_Actualise(a5),d0
	and.w	ActuMask(a5),d0
	bclr	#BitControl,d0
	beq.s	LEdL0
	move.w	d0,T_Actualise(a5)	* CONTROL-C -> revient!!!!
	moveq	#-1,d0
	rts
LEdL0	SyCall	Test_Cyclique
	tst.w	T_AMOSHere(a5)
	bne.s	LEdL0a
	bsr	WaitMul
LEdL0a	btst	#1,d7			* Tester?
	beq.s	LEdLl
	bsr	TTests
LEdLl	SyCall	Inkey
	tst.l	d1
	beq.s	LEdL
	swap	d1
	cmp.b	#$4F,d1			* Fleche gauche
	beq	LEdG
	cmp.b	#$4E,d1			* Fleche droite
	beq	LEdR
	cmp.b	#$41,d1			* BackSpace
	beq	LEdB
	cmp.b	#$46,d1			* Delete
	beq	LEdD
	swap	d1
	cmp.b	#13,d1
	beq.s	LEdRet
	cmp.b	#32,d1
	bcc.s	LEdI
* Si FLAG, revient avec le SCANCODE en D1.W!
	btst	#0,d7
	beq.s	LEdL
	swap	d1
	moveq	#1,d0
	rts
* Insere une lettre
LEdI:	cmp.w	d6,d5			* Longueur maximum
	bcc	LEdL
	move.w	d5,d0
LEdI1:	move.b	0(a4,d0.w),1(a4,d0.w)
	subq.w	#1,d0
	cmp.w	d4,d0
	bge.s	LEdI1
	move.b	d1,0(a4,d4.w)
	addq.w	#1,d5
	addq.w	#1,d4
	WiCalD	ChrOut,28
	bra	LEdLoop
* Return
LEdRet:	move.w	LEdXCu(a5),d1
	move.w	LEdYCu(a5),d2
	ext.l	d1
	ext.l	d2
	WiCall	Locate
	moveq	#0,d0
	rts
* Curseur a gauche
LEdG:	tst.w	d4
	beq	LEdL
	and.w	#$0300,d1
	bne.s	LedMg
	subq.w	#1,d4
	WiCalD	ChrOut,29
	bra	LEdL
* Mot gauche
LEdMg:	subq.w	#1,d4
	WiCalD	ChrOut,29
	tst.w	d4
	beq	LEdL
	move.b	-1(a4,d4.w),d2
	bsr	Lettre
	bne.s	LEdMg
	bra	LEdL
* Curseur a droite
LEdR:	cmp.w	d5,d4
	bcc	LEdL
	and.w	#$0300,d1
	bne.s	LEdMd
	addq.w	#1,d4
	WiCalD	ChrOut,28
	bra	LEdL
* Mot droit
LEdMd:	addq.w	#1,d4
	WiCalD	ChrOut,28
	cmp.w	d5,d4
	bcc	LEdL
	move.b	-1(a4,d4.w),d2
	bsr	Lettre
	bne.s	LEdMd
	bra	LEdL
* BackSpace
LEdB:	and.w	#$0300,d1
	bne.s	LEdCl
	tst.w	d4
	beq	LEdL
	subq.w	#1,d4
	WiCalD	ChrOut,29
* Delete
LEdD:	and.w	#$0300,d1
	bne.s	LEdCl
	cmp.w	d5,d4
	bcc	LEdL
	move.w	d4,d0
LEdD1:	move.b	1(a4,d0.w),0(a4,d0.w)
	addq.w	#1,d0
	cmp.w	d5,d0
	bcs.s	LEdD1
	subq.w	#1,d5
	clr.b	1(a4,d5.w)
	move.b	#" ",0(a4,d5.w)
	bra	LEdLoop	
* Nettoyage ligne
LEdCl:	move.l	a4,a0
LEdC1:	tst.b	(a0)
	beq.s	LEdC2
	move.b	#" ",(a0)+
	bra.s	LEdC1
LEdC2:	clr.w	d4
	clr.w	d5
	move.w	LEdXCu(a5),d1
	move.w	LEdYCu(a5),d2
	ext.l	d1
	ext.l	d2
	WiCall	Locate
	bra	LEdLoop

******* Chaines de controle
*	Stockage des positions en X / Y
LEdP1:	dc.b 27,"C0",27,"M0",27,"M2",0
*	Restitue les positions en X / Y
LEdP2:	dc.b 27,"M1",27,"M3",27,"C1",0

***********************************************************
*	ROUTINES DIVERSES

******* Copie!
CoCop	move.b	(a0)+,(a1)+
	bne.s	CoCop
	rts

******* Change la taille d'un ecran
ChgEcran:
	move.w	EcAWy(a0),d0
	move.w	d5,d1
	bsr	ChgE
	move.w	d0,EcAWy(a0)
	bset	#2,EcAW(a0)
	rts
*	Pitite routine
ChgE:	cmp.w	d1,d0
	beq.s	ChgEF
	addq.w	#1,d7
	cmp.w	d1,d0
	blt.s	ChgE0
* Soustraie
	sub.w	d6,d0
	cmp.w	d1,d0
	bge.s	ChgEF
	move.w	d1,d0
	rts
* Additionne
ChgE0:	add.w	d6,d0
	cmp.w	d1,d0
	ble.s	ChgEF
	move.w	d1,d0
ChgEF:	rts



*******	ESCAPE ---> Retour ` l'editeur
EscEs:	bsr	EscToEd
	move.l	BasSp(a5),sp
	bra	EdLoop	

***********************************************************
*	ENLEVE L'ECRAN DE L'EDITEUR
***********************************************************
EdHide:	tst.w	EsFlag(a5)
	bne	EdHx
	addq.w	#1,EsFlag(a5)
* Met la couleur du fond
	move.w	ColBack(a5),d1
	EcCall	SColB
* Ecran de fonction
EdM1:	clr.w	d7
	move.w	#-9*8,d5
	move.w	EdVScrol(a5),d6
	lsr.w	#1,d6
	move.l	FkEcran(a5),a0
	bsr	ChgEcran
* Ecran de l'editeur
	move.w	#312,d5
	move.w	EdVScrol(a5),d6
	move.l	EdEcran(a5),a0
	bsr	ChgEcran
* Actualise
	bsr	ReCop
* Encore?
	tst.w	d7
	bne.s	EdM1
* Remet les rainbows
	EcCalD	RainHide,0
* Remet tous les sprites
	SyCall	ReCallM
	SyCall	ReActHs
	SyCall	AMALUFrz
	SyCall	WaitVBL
	SyCall	ActHs
	SyCall	AffHs
* Remet les limites souris
	lea	LimSave(a5),a0
	lea	T_MouXMin(a5),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
* Fini!
EdHx:	SyCall	ClearKey
	SyCall	AMALUFrz
	rts


WaitKey:SyCall	Inkey
	tst.l	d1
	beq.s	WaitKey
	rts

******* Routintint
ReCop:	SyCall	WaitVBL
	EcCall	CopForce
	rts

* Routine: ramene VRAI si D2 est une lettre ou un chiffre
Lettre:	cmp.b	#"0",d2
	bcs.s	LFaux
	cmp.b	#"9",d2
	bls.s	LVrai
	cmp.b	#"A",d2
	bcs.s	LFaux
	cmp.b	#"Z",d2
	bls.s	LVrai
	cmp.b	#"a",d2
	bcs.s	LFaux
	cmp.b	#"z",d2
	bls.s	LVrai
	cmp.b	#128,d2
	bcc.s	LVrai
LFaux:	moveq	#0,d2
	rts
LVrai:	moveq	#-1,d2
	rts

******* Centre l'ecran en X
EdSetX	move.w	d0,EdXCu(a5)
	moveq	#0,d1
	cmp.w	#70,d0
	bcs.s	EdSx2
EdSx1	add.w	#20,d1
	sub.w	#20,d0
	cmp.w	#60,d0
	bcc.s	EdSx1
EdSx2	move.w	d1,EdXPos(a5)
	rts

******* Centre l'ecran en Y
EdSetY	movem.w	d0/d1/d2,-(sp)
	cmp.w	EdNLigne(a5),d0
	bls.s	EdPy1
	move.w	EdNLigne(a5),d0
* Remonte la fenetre?
EdPy1	move.w	d0,d1
	sub.w	EdYCu(a5),d1
	bcc.s	EdPy2
	clr.w	d1
EdPy2	move.w	EdNLigne(a5),d2
	cmp.w	EdTyM0(a5),d2
	bcc.s	EdPy3
	clr.w	d1
EdPy3	move.w	d1,EdYPos(a5)
	sub.w	d1,d0
	move.w	d0,EdYCu(a5)
	movem.w	(sp)+,d0/d1/d2
	rts

******* Centre l'ecran en X et Y, gere les procedures....
*	A0= adresse dans programme
*	D0= X curseur
EdSetXY	clr.l	AdEProc(a5)
	move.w	d0,XEProc(a5)
	move.w	d0,-(sp)
	bsr	FindA
	tst.l	d1
	beq.s	EdSxy1
	move.l	a0,AdEProc(a5)
	clr.w	(sp)
EdSxy1	bsr	EdSetY
	move.w	(sp)+,d0
	bsr	EdSetX
	bsr	AverFin
	bra	NewBuf

******* Routine, teste
VaTester
	tst.w	StModif(a5)
	beq.s	VaTst
	Alea	EdTest,a0
	bsr	EtAff
	move.l	StBas(a5),DRun(a5)
	jsr	ClearVar
	jsr	EffBanks
	bsr	PTest
	bsr	AverFin
VaTst	jsr	ClearVar
	rts

***********************************************************
* 	Initialisation generale des ecrans
EdEcInit:
********
	move.l	a5,-(sp)
* Remet les palettes
	bsr	SetEnv
* Ecran des touches de fonction
	EcCalD	Active,EcFonc
	lea	Ed_pics,a0
	moveq	#2,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#-1,d3
	jsr	UPack
	ALea	FkFond,a1
	WiCall	Print
	Alea	FkDef1,a1
	WiCall	Print
* Ecran de l'editeur
	EcCalD	Active,EcEdit
	moveq	#1,d1
	Alea	EdFlCu,a1
	EcCall	Flash
Globi	moveq	#Ed_NBoutons,d0
	moveq	#0,d1
.loop	bsr	Ed_ABouton
	subq.w	#1,d0
	bne.s	.loop
* Slider horizontal
	move.l	EdEcran(a5),a0
	move.l	a0,a1
	moveq	#EdTx/2-6,d7
	moveq	#16,d0
	move.w	EdTyM0(a5),d1
	lsl.w	#3,d1
	ext.l	d1
	moveq	#32,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	add.w	#32,d4
	add.w	#8,d5
.lso	jsr	TtScc
	add.w	#16,d0
	add.w	#16,d2
	add.w	#16,d4
	dbra	d7,.lso
* Slider vertical
	move.w	EdTyM0(a5),d7
	subq.w	#6,d7
	move.l	#Ed_Sx-16,d0
	moveq	#8,d1
	move.l	d0,d2
	move.l	d1,d3
	addq.l	#8,d3
	move.l	d0,d4
	move.l	d1,d5
	add.w	#16,d4
	add.w	#16,d5
.ldo	jsr	TtScc
	addq.w	#8,d1
	addq.w	#8,d3
	addq.w	#8,d5
	dbra	d7,.ldo
* Init des sliders
	moveq	#6,d0
	moveq	#6,d1
	moveq	#6,d2
	moveq	#1,d3
	moveq	#4,d4
	moveq	#4,d5
	moveq	#4,d6
	moveq	#1,d7
	EcCall	SetSli
* Init du fond	
	WiCalD	QWindow,1
	ALea	EdClw,a1
	WiCall	Print
	move.l	(sp)+,a5
	rts

******* Impression du bouton D0, active: D1
Ed_ABouton
	movem.l	a0/d2-d3,-(sp)
	lea	Ed_Boutons,a0
	lea	Ed_Pics,a1
	move.w	#Ed_Sx,d2
	move.w	EdTyM0(a5),d3
	addq.w	#1,d3
	lsl.w	#3,d3
	jsr	Aff_Bouton
	movem.l	(sp)+,a0/d2-d3
	rts

***************
Ed_NBoutons	equ	8
Ed_Boutons	dc.w	0,0,0+1,0+1			1 Ecran
		dc.w	1,0,0,-16+1,-8+1
		dc.w	6,6,0+1,-8			2 Sli horiz
		dc.w	2,HSli_Dx,0,-16*3-HSli_Fx+1,8
		dc.w	3,3,-16,0+1			3 Sli vert
		dc.w	3,0,VSli_Dy,16,-8*3-VSli_Fy+1
		dc.w	4,4,-16,-8*3,4,0,0,16,8		4 Fleche H
		dc.w	5,5,-16,-8*2,5,0,0,16,8		5 Fleche B
		dc.w	7,7,-16*3,-8,6,0,0,16,8		6 Fleche G
		dc.w	8,8,-16*2,-8,7,0,0,16,8		7 Fleche D
		dc.w	9,9,-16*1,-8,8,0,0,16,8		8 Carre

******* Descente / Montee des ecrans de l'editeur
EdScrol:
* Enleve tous les sprites
	SyCall	AMALFrz
	SyCall	StActHs	
	SyCall	StoreM
* Remet les rainbows
	EcCalD	RainHide,-1
* Ecrans en 1er
	EcCalD	First,EcFonc
	EcCalD	First,EcEdit
	move.b	#-1,EdFront(a5)
EdScr1:	clr.w	d7
* Touches de fonction
	move.w	EdVScrol(a5),d6
	lsr.w	#1,d6
	move.w	FkPosY(a5),d5
	move.l	FkEcran(a5),a0
	bsr	ChgEcran
* Ecran de l'editeur
	move.w	EdVScrol(a5),d6
	move.w	EdPosY(a5),d5
	move.l	EdEcran(a5),a0
	bsr	ChgEcran
	bsr	ReCop
* Encore?
	tst.w	d7
	bne.s	EdScr1
* Remet le fond!
	move.w	EdColB(a5),d1
	EcCall	SColB
* Limite de la souris
	lea	T_MouXMin(a5),a0		* Pour l'initialisation!
	lea	LimSave(a5),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	moveq	#EcEdit+1,d3
	move.w	#Ed_Sx-2,d1
	move.w	EdTyM0(a5),d2
	addq.w	#1,d2
	mulu	#8,d2
	subq.w	#2,d2
	SyCall	XyHard
	movem.w	d1/d2,-(sp)
	moveq	#EcFonc+1,d3
	moveq	#0,d1
	moveq	#0,d2
	SyCall	XyHard
	movem.w	(sp)+,d3/d4
	SyCall	LimitM
	SyCalD	Show,-1
* Plus de touches
	SyCall	ClearKey
* Affiche le tout!
	bsr	ReCop
	bclr	#BitControl,T_Actualise(a5)	* Pas de bloc!!!
	rts

******* Initialisation de l'editeur
EdInit:	
* Autre inits
	clr.w	EdXPos(a5)
	clr.w	EdYPos(a5)
	clr.w	EdXCu(a5)
	clr.w	EdYCu(a5)
	clr.w	EdFlag(a5)
	clr.w	EdEdit(a5)
	move.b	#-1,EdInsert(a5)
	clr.w	EdMKey(a5)
	clr.w	EdMkFl(a5)
	clr.w	EdILigne(a5)
	move.w	#1,EtAX(a5)
	move.w	#1,EtAY(a5)
	move.w	#1,EtFr(a5)
	move.w	#1,EtASlX(a5)
	move.w	#1,EtASlY(a5)
	move.w	#-1,EtOCps(a5)
	move.w	#3,EdTabs(a5)
	move.w	#2,DtkMaj1(a5)
	move.w	#1,DtkMaj2(a5)
	move.w	#-1,SchMode(a5)
* Init touches de fonction
	bsr	FkIPoke
	bsr	FkLPoke
	clr.w	EdFkCpt(a5)
	clr.w	FkJeu(a5)
	clr.w	FkOJeu(a5)
	clr.w	FkMFlag(a5)
	bsr	AmiInit
	move.w	#-1,AmiAff(a5)
	move.w	#-1,AmiOAff(a5)
* Init mode escape
	clr.w	EsFlag(a5)
* Initialise le texte
	lea	BBanks(a5),a0
	move.l	a0,ABanks(a5)
	move.w	#1,DefFlag(a5)
	bsr	RNew
	lea	LimSave(a5),a0
	lea	T_MouXMin(a5),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
* Ecran de fonction
	clr.w	EtMess(a5)
	clr.l	EtAlert(a5)
	EcCalD	Active,EcFonc
	bsr	EtPrint
	EcCalD	Active,EcEdit
	WiCalD	QWindow,1
	ALea	EdClw,a1
	WiCall	Print
	bsr	AffSlV
	bsr	AffSlH	
	rts

***********************************************************
*	NETTOYAGE VARIABLES
***********************************************************
ClearVar:
	movem.l	d0-d7/a0-a6,-(sp)

******* Variables programme
	lea	DebRaz(a5),a0
	lea	FinRaz(a5),a1
ClV1:	clr.w	(a0)+
	cmp.l	a1,a0
	bcs.s	ClV1
* Disque
	move.l	#$FFFFFFFF,IffMask(a5)
	bsr	FillFFree
	Alea	DirFilt,a0
	move.l	DirFNeg(a5),a1
ClV2:	move.b	(a0)+,(a1)+
	bne.s	ClV2
	move.w	DirSize(a5),DirLNom(a5)
	clr.l	T_ClLast(a5)
	move.w	#$0A0D,ChrInp(a5)
	bsr	CloAll
* DREG/AREG
	lea	CallReg(a5),a0
	move.l	a5,(8+5)*4(a0)			* A5-> Datazone
	move.l	T_ClAsc(a5),(8+4)*4(a0)		* A4-> Clavier actuel
	move.l	StBas(a5),(8+3)*4(a0)		* A3-> Bas du programme
	move.l	T_RastPort(a5),(8+0)*4(a0)	* A0-> Rastport
	move.l	DosBase(a5),7*4(a0)		* D7-> Dos Base
	move.l	T_GfxBase(a5),6*4(a0)		* D6-> Gfx Base
	move.l	T_IntBase(a5),5*4(a0)		* D5-> Int Base
* MENUS
*	bsr	MnRaz
*	clr.w	MnMouse(a5)
*	lea	MnDFlags(a5),a0
*	moveq	#0,d0			* Barre de menu
*	bset	#MnTotal,d0
*	bset	#MnBouge,d0
*	bset	#MnTBouge,d0	
*	move.b	d0,(a0)+
*	moveq	#0,d0
*	bset	#MnBar,d0
*	bset	#MnBouge,d0
*	bset	#MnTBouge,d0
*	moveq	#MnNDim-1-1,d1		* Autres dimensions
*DRex3:	move.b	d0,(a0)+
*	dbra	d1,DRex3
*	moveq	#MnNDim-1,d0
*	lea	MnChoix(a5),a0
*DRex4	clr.w	(a0)+
*	dbra	d0,DRex4
* Plus de buffers!
	moveq	#0,d1
	bsr	ResVarBuf
	clr.w	VarBufFlg(a5)
	moveq	#0,d1
	bsr	ResVNom
* Plus de ON MENU
*	bsr	OMnEff
* Plus d'erreur compilateur
	clr.l	T_JError(a5)
* Init float
	move.w	#-1,FixFlg(a5)
	clr.w	ExpFlg(a5)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

******* RESERVE DE L'ESPACE POUR LES VARIABLES DIRECTES
ResDir:	movem.l	d0/d1/a0,-(sp)
	tst.w	TVMax(a5)
	bne.s	RsD3
	move.l	TabBas(a5),d1
	move.l	d1,a0
	sub.l	HiChaine(a5),d1
	bcs.s	RsD3
	moveq	#0,d0
	move.w	TVDirect(a5),d0
	cmp.l	d1,d0
	bls.s	RsD1
	move.l	d1,d0
RsD1:	divu	#6,d0
	mulu	#6,d0
	subq.l	#6,d0
	beq.s	RsD3
	move.w	#$FFFF,-(a0)
	move.l	VarLoc(a5),-(a0)
	sub.l	d0,a0
	move.l	a0,VarLoc(a5)
	move.l	a0,TabBas(a5)
	move.w	d0,TVMax(a5)
	lsr.w	#1,d0
	subq.w	#1,d0
	bmi.s	RsD3
RsD2:	clr.w	(a0)+
	dbra	d0,RsD2
RsD3:	movem.l	(sp)+,d0/d1/a0
	rts

******* Reserve le buffer chaines / variables
*	D1= Taille
ResVarBuf
	move.l	VarBuf(a5),d0
	beq.s	Vbr1
	clr.l	VarBuf(a5)
	move.l	d0,a1
	move.l	VarBufL(a5),d0
	bsr	RamFree
Vbr1	move.l	d1,d0
	beq.s	Vbr2
	bsr	RamFast
 	beq	VerOut
	move.l	d0,VarBuf(a5)
	move.l	d0,a0
	lea	0(a0,d1.l),a1
* Adresses dans ce buffer
	move.l	a1,LabHaut(a5)
	clr.w	-(a1)
	move.l	a1,LabBas(a5)
	move.w	#-1,-(a1)
	clr.l	-(a1)
	move.l	a1,VarGlo(a5)
	move.l	a1,TabBas(a5)
	move.l	a1,VarLoc(a5)
* Chaines
	move.l	a0,LoChaine(a5)
	move.l	a0,ChVide(a5)
	move.l	a0,ParamC(a5)
	clr.w	(a0)+
	move.l 	a0,HiChaine(a5)
	move.l	a0,DTablA(a5)
* Fini!
Vbr2	clr.w	VarLong(a5)
	clr.w	GloLong(a5)
	clr.w	TVMax(a5)
	move.l	d1,VarBufL(a5)
	rts

******* Reserve le buffer des noms de variable
*	D1= taille
ResVNom	move.l	VNmMini(a5),d0
	beq.s	RVn1
	clr.l	VNmMini(a5)
	move.l	d0,a1
	move.l	VNmLong(a5),d0
	clr.l	VNmLong(a5)
	bsr	RamFree
RVn1	move.l	d1,d0
	beq.s	RVn2
	bsr	RamFast
 	beq	VerOut
	move.l	d0,VNmMini(a5)
	move.l	d1,VNmLong(a5)
	move.l	d0,a0
	add.l	d1,a0
	move.l	a0,DVNmHaut(a5)
	clr.w	-(a0)
	move.l	a0,DVNmBas(a5)
	move.l	a0,VNmHaut(a5)
	clr.w	-(a0)
	move.l	a0,VNmBas(a5)
RVn2	rts

******* Default screen!
DefRun:	tst.w	DefFlag(a5)
	beq	DRunX
	movem.l	d0-d7/a0-a6,-(sp)
* Enleve les animations
*	SyCall	AMALClr
*	clr.w	PAmalE(a5)
* Enleve les rainbows
	EcCalD	RainDel,-1
* Enleve tous les ecrans
	move.w	DefEBa(a5),ColBack(a5)
	moveq	#0,d1	
	moveq	#7,d2
	tst.w	RunAct(a5)
	beq.s	.notut
	moveq	#5,d2
.notut	EcCall	DelAll
	clr.w	ScOn(a5)
	clr.l	ScOnAd(a5)
* Enleve les blocs!
	EcCall	CBlRaz
	EcCall	BlRaz
* Enleve les font-infos
	EcCall	FFonts
* RAZ des canaux d'animation
*	lea	AnCanaux(a5),a0
*	moveq	#0,d0
*DRun1:	clr.b	(a0)+
*	move.b	d0,(a0)+
*	addq.w	#1,d0
*	cmp.w	#64,d0
*	bne.s	DRun1
* Priority off
	moveq	#0,d1
	moveq	#0,d2
	SyCall	SPrio
* RAZ des scrollings
	moveq	#15,d0
	lea	DScrolls(a5),a0
DRun2:	move.w	#$8000,(a0)
	lea	12(a0),a0
	dbra	d0,DRun2
* Interruptions branchees
	clr.w	InterOff(a5)
	bsr	SyncS	
	move.w	#%0111000100000000,ActuMask(a5)
	clr.w	VBLDelai(a5)
	clr.w	VBLOCount(a5)
* Copie la palette par defaut
	lea	DefEPa(a5),a0
	lea	DefPal(a5),a1
	moveq	#31,d0
EdTr:	move.w	(a0)+,(a1)+
	dbra	d0,EdTr
* Init du selecteur de fichier
*	move.w	FsDWY(a5),FsWY(a5)
*	move.w	FsDWX(a5),FsWX(a5)
*	move.w	FsDVApp(a5),FsVApp(a5)
* Cree l'ecran (si pas system!)
	cmp.w	#-2,DefFlag(a5)
	beq.s	DRex0
	move.w	DefETx(a5),d2
	ext.l	d2
	move.w	DefETy(a5),d3
	ext.l	d3
	move.w	DefECo(a5),d4
	ext.l	d4
	move.w	DefEMo(a5),d5
	move.w	DefECoN(a5),d6
	moveq	#0,d7
	lea	DefPal(a5),a1
	EcCalD	Cree,0
	bne.s	DRex0
	move.l	a0,ScOnAd(a5)
	move.w	#1,ScOn(a5)
* Fait flasher la couleur 3 (si plus de 2 couleurs)
	cmp.w	#1,DefECo(a5)
	beq.s	EdTr1
	moveq	#3,d1
EdTr1:	ALea	DefEFl,a1
	EcCall	Flash
* Call extensions
DRex0	lea	ExtAdr(a5),a0
	moveq	#26-1,d0
DRex1:	move.l	4(a0),d1
	beq.s	DRex2
	move.l	d1,a1
	movem.l	a0/d0,-(sp)
	jsr	(a1)
	movem.l	(sp)+,a0/d0
DRex2:	lea	16(a0),a0
	dbra	d0,DRex1
* Enleve le tempraster
	clr.l	RasLock(a5)
	jsr	FreeRas
	movem.l	(sp)+,d0-d7/a0-a6
DRunX:	rts
GEcWiEr	jmp	EcWiErr
******* Second part
DefRun2:tst.w	DefFlag(a5)
	beq.s	DRunX
	clr.w	DefFlag(a5)
	move.l	ParaTrap+16(a5),d1	* Nombre de lignes
	SyCall	SBufHs
	SyCall	OffHs
	SyCall	StoreM
	SyCall	StoreM
	SyCall	AffHs
* Limite la souris
	move.w	T_DefWX(a5),d1
	move.w	T_DefWY(a5),d2
	move.w	DefETx(a5),d3
	move.w	DefETy(a5),d4
	subq.w	#1,d3
	subq.w	#1,d4
	add.w	d1,d3
	add.w	d2,d4
	lsl.w	#1,d1
	lsl.w	#1,d2
	lsl.w	#1,d3
	lsl.w	#1,d4
	lea	LimSave(a5),a0
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	rts
******* Routine: met la synchro
SyncS:	move.w	InterOff(a5),d1
	SyCall	SetSync
	rts
******* Wait vbl multi tache
WaitMul	movem.l	a0/a1/d0/d1/a6,-(sp)
	SyCall	Test_Cyclique
	move.l	T_gfxbase(a5),a6
	jsr	-270(a6)
	movem.l	(sp)+,a0/a1/d0/d1/a6
	rts

***********************************************************
