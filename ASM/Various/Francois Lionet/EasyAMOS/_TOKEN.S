
;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* TOKENISATION / STOCKAGE
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;----------------------------------------------------------------
	IfNE	ROnly
InitTok
EffTok	rts
	EndC

	IfEQ	ROnly

***********************************************************
*	INSERTION D'UNE LIGNE
InsLine:
	bsr	TokCur

* Active la touche du menu
InsL0:	tst.w	EdILigne(a5)
	bne.s	RetI4
	bsr	BaTxt
* Insere 
	moveq	#10,d2
	moveq	#"1",d3
	bsr	FkAct
RetI1:	addq.w	#1,EdILigne(a5)
	WiCalD	ChrOut,20		* Scrolle dans l'ecran
	bsr	DLigneT
	bsr	LCourant		* Scrolle dans le buffer
	lea	-2(a0),a0
	move.l	EdBufE(a5),a2
	move.w	EdTyM0(a5),d0
	lsl.w	#8,d0
	add.w	d0,a2
	lea	-256(a2),a1
	move.l	a1,d0
	sub.l	a0,d0
	beq.s	RetI3
	lsr.w	#2,d0
	subq.w	#1,d0
RetI2:	move.l	-(a1),-(a2)
	dbra	d0,RetI2
RetI3:	clr.w	(a0)
RetI4:	rts

* Bas du texte?
BaTxt:	move.w	EdYPos(a5),d1
	add.w	EdYCu(a5),d1
	cmp.w	EdNLigne(a5),d1
	beq.s	BaT0
	rts
BaT0:	Alea	EdBot,a0
	moveq	#25,d0
	bra	Alert

***********************************************************
*	TOUCHE RETURN
***********************************************************
Return:	tst.w	EdFlag(a5)
	bne	Ret1
******* On a rien change: Copie / Insersion d'une ligne
	tst.w	EdILigne(a5)		* Si INSERT---> Tokenise!
	bne	Ret1
	bsr	BaTxt
* Copie la fin de la ligne ---> ST MINI
	move.l	StMini(a5),a2		* Adresse dans STMINI
	lea	2(a2),a2		* CHAINE VIDE!
	move.l	StBas(a5),a0
	lea	-256(a0),a0
	cmp.l	a0,a2
	bcc	RetOut		
	bsr	LCourant
	tst.w	d1
	beq	InsLine
	move.w	d1,d2
	cmp.w	d0,d2
	bcs.s	RtI1
	move.w	d0,d2
RtI1:	move.w	d2,-2(a0)		* Change la taille ligne origine
RtI2:	cmp.w	d0,d1
	bcc.s	RtI3
	move.b	(a1)+,(a2)+
	addq.w	#1,d1
	bra.s	RtI2
RtI3:	clr.b	(a2)
* Tokenise la ligne / insere une nouvelle (si possible)
	bsr	Ret1
	move.w	EdYPos(a5),d1
	add.w	EdYCu(a5),d1
	cmp.w	EdNLigne(a5),d1
	beq.s	RtI0
	bsr	InsL0
RtI0:
* Recopie la nouvelle
	bsr	LCourant
	move.l	a0,a2
	clr.w	d0
	move.l	StMini(a5),a1
	lea	2(a1),a1
RtI4:	move.b	(a1)+,d1
	beq.s	RtI5
	move.b	d1,(a2)+
	addq.w	#1,d0
	bra.s	RtI4
RtI5:	move.w	d0,-2(a0)
* Affiche la nouvelle ligne/revient a l'editeur
	addq.w	#1,EdFlag(a5)
	bra	EALiCu

******* Va tokeniser la ligne
Ret1:	clr	EdFlag(a5)
	bsr	LCourant	* Adresse de la ligne courante
	move.l	a0,a3
	clr.b	0(a3,d0.w)	* Marque la fin
	move.l	EdBufT(a5),a4	* Buffer de tokenisation
	bsr	Tokenise
* Enleve une ligne vide?
	bne.s	PaVide
* En bas du texte?
DLine:	move.w	EdYPos(a5),d1		* Deja la derniere ligne
	add.w	EdYCu(a5),d1
	cmp.w	EdNLigne(a5),d1
	bcc	DLigneT
* Enleve une ligne du programme
	tst.w	EdILigne(a5)		* Enleve la ligne si INSERE
	bne.s	RetV0
	bsr	DeLigne
	bne	RetS0
* Enleve la ligne d'insertion
RetV0:	clr.w	EdILigne(a5)
	WiCalD	ChrOut,23
	bsr	LCourant
	lea	-2(a0),a0
	lea	256(a0),a1
	move.w	EdTyM0(a5),d0
	mulu	#256,d0
	add.l	EdBufE(a5),d0
	move.l	d0,a2
	sub.l	a1,d0
	bls.s	RetV2
	lsr.w	#2,d0
	subq.w	#1,d0
RetV1:	move.l	(a1)+,(a0)+
	dbra	d0,RetV1
RetV2:	clr.w	-256(a2)
	move.w	EdYPos(a5),d0
	move.w	EdTyM1(a5),d1
	add.w	d1,d0
	bsr	UnTok
	bsr	EALigne
	bsr	EdLoca
	move.w	#SlDelai,EtASlY(a5)
	bra	RetS0
PaVide:

*******	Stocke la ligne
RetOk:
* Stocke la ligne
	move.l	EdBufT(a5),a1
	move.w	EdYPos(a5),d1
	add.w	EdYCu(a5),d1
	bsr	Stocke
	bne	RetOut
* Reaffiche la ligne
	bsr	LCourant
	lea	-2(a0),a4
	sub.l	a3,a3		* Pas d'erreur!
	bsr	Detok
	move.w	EdYCu(a5),d1
	bsr	EALigne
* Fait descendre le curseur, SI RETURN
	move.w	#SlDelai,EtASlY(a5)
	cmp.l	#ToCuR,(sp)
	beq.s	RetS0
	bsr	CBasT
	bsr	DLigneT
* Inserer une ligne?
	tst.w	EdILigne(a5)
	bne	RetI1
	rts
RetS0:	clr.w	EdILigne(a5)
	moveq	#"0",d3			Enleve la touche activee
	moveq	#10,d2
	bra	FkAct

******* Out of mem
RetOut:	move.w	#200,d0
	Alea	EdMem,a0
	bra	Alert

***********************************************************
*	TOKENISATION PAR MOUVEMENT DU CURSEUR
***********************************************************
TokCur:	movem.l	a0-a6/d0-d7,-(sp)
	subq.w	#1,SchFlag(a5)
	tst.w	EdFlag(a5)
	bne.s	ToCu1
	tst.w	EdILigne(a5)
	beq.s	ToCuR
ToCu1:	bsr	Return
ToCuR:	movem.l	(sp)+,a0-a6/d0-d7
	rts

***********************************************************
*	INITIALISATION TOKENISATION
InitTok	
* Reserve le buffer de tokenisation...
	move.l	#EdBtt,d0
	jsr	RamFast
	beq	TheEnd
	move.l	d0,EdBufT(a5)
* Fabrique les tables de tokenisation
	lea	AdTokens(a5),a3
	lea	AdTTokens(a5),a4
	moveq	#-4,d7
MTok1	addq.w	#4,d7
	cmp.w	#26*4,d7
	bcc	MTokX
	move.l	0(a3,d7.w),d6
	beq.s	MTok1
	move.l	d6,a1
	addq.l	#6,a1
* Premiere table
	move.l	EdEcran(a5),a6
	move.l	EcPhysic(a6),a6
	move.l	a6,a0
	lea	2048(a0),a2
	moveq	#0,d0
MTok2	move.l	a1,d1
	lea	4(a1),a1
MTok0	move.b	(a1)+,d0
	bpl.s	MTok3
	and.w	#$7f,d0
	subq.l	#1,a1
MTok3	cmp.b	#"!",d0
	beq.s	MTok0
	cmp.b	#" ",d0
	beq.s	MTok0
	bsr	MinD0
	cmp.b	#"a",d0
	bcs.s	MTok4
	cmp.b	#"z",d0
	bhi.s	MTok4
	move.w	d0,(a0)+
	sub.l	d6,d1
	move.w	d1,(a2)+
MTok4	bsr	TklNext
	bne.s	MTok2
	move.w	#-1,(a0)+
* Deuxieme table
	move.l	a0,d0
	sub.l	a6,d0
	add.l	#26*4+2+4,d0
	move.l	d0,d1
	jsr	RamFast
	beq	TheEnd
	move.l	d0,0(a4,d7.w)
	move.l	d0,a1
	move.l	d0,d3
	move.l	d1,(a1)+
	lea	26*2+2(a1),a2
	moveq	#"a",d5
	move.w	#2048,d4
MTok5	move.l	a2,d0
	sub.l	d3,d0
	move.w	d0,(a1)+
	move.l	a6,a0
MTok6	move.w	(a0)+,d0
	bmi.s	MTok7
	cmp.w	d0,d5
	bne.s	MTok6
	move.w	-2(a0,d4.w),(a2)+
	bra.s	MTok6
MTok7	clr.w	(a2)+
	addq.w	#1,d5
	cmp.w	#"z",d5
	bls.s	MTok5
	clr.w	(a1)+
	bra	MTok1
MTokX	rts
******* Effacement de la tokenisation
EffTok	lea	AdTTokens(a5),a2
	moveq	#25,d1
DlTk1	move.l	(a2)+,d0
	beq.s	DlTk2
	move.l	d0,a1
	move.l	(a1),d0
	jsr	RamFree
DlTk2	dbra	d1,DlTk1
* Efface le buffer de tokenisation
	move.l	EdBufT(a5),d0
	beq.s	.Skip
	move.l	d0,a1
	move.l	#EdBtt,d0
	jsr	RamFree
.Skip	rts
	
***********************************************************
*	TOKENISE LA LIGNE COURANTE
***********************************************************
Tokenise:
	movem.l	a4/a6,-(sp)	* Sauve le debut de la ligne
	clr.w	d5		* RAZ de tous les flags

******* Compte les TABS
	moveq	#0,d1
TokT:	addq.w	#1,d1
	move.b	(a3)+,d0
	beq	TokVide
	cmp.b	#32,d0
	beq.s	TokT
	subq.l	#1,a3
	clr.b	(a4)+
	cmp.w	#127,d1
	bcs.s	TokT1
	moveq	#127,d1
TokT1:	move.b	d1,(a4)+

******* Un chiffre au debut de la ligne?
	move.b	(a3),d0
	cmp.b	#"0",d0
	bcs.s	TokT2
	cmp.b	#"9",d0
	bhi.s	TokT2
	bset	#1,d5		* Flag VARIABLE
	bset 	#4,d5		* Flag LABEL
	move.l	a4,TkAd(a5)
	move.w	#TkVar-Tk,(a4)+
	clr.l	(a4)+
	move.b	(a3)+,(a4)+

******* Une apostrophe en debut de ligne?
TokT2:	cmp.b 	#"'",d0
	bne.s	TokLoop
	addq.l	#1,a3
	move.w	#TkRem2-Tk,(a4)+
	bra	TkKt2

*******	Prend une lettre
TokLoop:move.b	(a3)+,d0
	beq	TokFin

* Rem en route?
	btst	#5,d5
	beq.s	TkROn
	move.b	d0,(a4)+
	bra.s	TokLoop
TkROn:

* Variable en route?
	btst	#1,d5
	bne	TkVD

* Chaine en route?
	btst	#0,d5
	beq.s	TkC2
	cmp.b	TkChCar(a5),d0
	beq.s	TkC1
	move.b	d0,(a4)+
	bra.s	TokLoop
* Fin d'une chaine alphanumerique
TkChf:	subq.l	#1,a3
TkC1:	bclr	#0,d5
	move.l	a4,d0
	btst	#0,d0
	beq.s	TkC0
	clr.b	(a4)+
TkC0:	move.l	TkAd(a5),a0
	sub.l	a0,d0
	subq.w	#4,d0
	move.w	d0,2(a0)
	bra.s	TokLoop
* Debut d'une chaine alphanumerique?
TkC2:	cmp.b	#'"',d0
	beq 	TkC2a
	cmp.b	#"'",d0
	bne	TkOtre
TkC2a:	move.b	d0,TkChCar(a5)
	move.l	a4,TkAd(a5)
	cmp.b	#"'",d0
	beq.s	TkC2b
	move.w	#TkCh1-Tk,(a4)+
	bra.s	TkC2c
TkC2b:	move.w	#TkCh2-Tk,(a4)+
TkC2c:	clr.w	(a4)+
	bset	#0,d5
	bra.s	TokLoop

* Variable en route
TkVD:	bsr	Minus
* Numero de ligne en route
TkFV:	moveq	#0,d1
	move.l	TkAd(a5),a0
	btst	#4,d5	
	beq.s	TkV2
	cmp.b	#"0",d0
	bcs.s	TkV0
	cmp.b	#"9",d0
	bls.s	TkV3
TkV0:	bset	#3,d5		Fin du debut de ligne!
	bclr	#4,d5		Fin du numero de ligne
	cmp.b	#":",d0
	beq.s	TkV1
	subq.l	#1,a3
	bra.s	TkV1
* Variable normale / label
TkV2:	cmp.b	#"_",d0
	beq.s	TkV3
	cmp.b	#"0",d0
	bcs.s	TkV4
	cmp.b	#"9",d0
	bls.s	TkV3
	cmp.b	#"a",d0
	bcs.s	TkV4
	cmp.b	#"z",d0
	bls.s	TkV3
	cmp.b	#128,d0
	bls.s	TkV4
TkV3:	move.b	d0,(a4)+
	bra	TokLoop
* Fin de la variable/label/label goto
TkV4:	bset	#3,d5		* Si pas debut de ligne
	bne.s	TkV5
	cmp.b	#":",d0		* Si :
	bne.s	TkV5
TkV1:	move.w	#TkLab-Tk,(a0)
	bra.s	TkV7		
	
TkV5:	subq.l	#1,a3
	moveq	#2,d1
	cmp.b	#"$",d0
	beq.s	TkV6
	moveq	#1,d1
	cmp.b	#"#",d0
	beq.s	TkV6
	moveq	#0,d1
	bra.s	TkV7
TkV6:	addq.w	#1,a3
TkV7:	move.w	a4,d2		* Rend pair
	btst	#0,d2
	beq.s	TkV8
	clr.b	(a4)+
TkV8:	move.l	a4,d0
	sub.l	a0,d0
	subq.l	#6,d0
	move.b	d0,4(a0)	* Poke la longueur
	move.b	d1,5(a0)	* Poke le flag
	bclr	#1,d5
	bra	TokLoop

* Saute les 32
TkOtre:	cmp.b	#" ",d0
	beq	TokLoop

* Est-ce un chiffre?
	lea	-1(a3),a0
	bsr	ValTok
	bne.s	TkK
	move.w	d1,(a4)+
	move.l	d3,(a4)+
	move.l	a0,a3
	bra	TokLoop
TkK:

******* Tokenisation RAPIDE!
	moveq	#0,d7			* D7--> Numero de l'extension
	lea	AdTokens(a5),a6
* Mode rapide ou lent?
	moveq	#0,d0
	move.b	-1(a3),d0
	bsr	MinD0	
	move.l	d0,d2
	cmp.b	#"a",d2
	bcs.s	Tkl1
	cmp.b	#"z",d2
	bhi.s	Tkl1
	bset	#31,d2
	move.w	d2,d6
	sub.w	#"a",d6
	lsl.w	#1,d6
* Mode rapide: init!
Tkr1	lea	AdTTokens(a5),a2
	move.l	0(a2,d7.w),d0
	beq.s	Tkl1
	move.l	d0,a2
	move.w	4(a2,d6.w),d0
	add.w	d0,a2			* A2-> Adresse des adresses
	bset	#31,d6
	bra	TkrNext
* Tokens lents
Tkl1	move.l	0(a6,d7.w),d0
	beq	TkNext
	move.l	d0,a1
	bclr	#31,d6
	addq.l	#6,a1
	cmp.b	#"!",d2
	beq	TkKF
	cmp.b	#"?",d2
	bne.s	Tkl2
	move.l	a3,a0
Tkl1a	move.b	(a0)+,d0		* ? PRINT / ? PRINT #
	beq.s	Tkl1b
	cmp.b	#"#",d0
	beq.s	Tkl1c
	cmp.s	#" ",d0
	beq.s	Tkl1a
Tkl1b	move.w	#TkPr-Tk,d4
	bra	TkKt0
Tkl1c	move.l	a0,a3
	move.w	#TkHPr-Tk,d4
	bra	TkKt0
Tkl2	move.l	a1,d4			* Recherche la 1ere lettre
	lea	4(a1),a1
	move.w	d2,d0
Tkl0	move.b	(a1)+,d1
	bmi	Tkl4
	cmp.b	#TkRemp,d1
	beq.s	Tkl0
	cmp.b	#" ",d1
	beq.s	Tkl0
	cmp.b	#"!",d1
	beq.s	Tkl0
	cmp.b	d0,d1
	beq.s	TkRe0
Tkl3	bsr	TklNext
	bne.s	Tkl2
* Tableau de token suivant!
TkNext	addq.l	#4,d7
	cmp.l	#4*26,d7
	bcc	TkKF
	tst.l	d2
	bpl.s	Tkl1
	bra	Tkr1
* Trouve 1 lettre lent?
Tkl4	subq.l	#1,a1
	and.b	#$7f,d1
	cmp.b	#" ",d1
	beq.s	TklT
	cmp.b	d0,d1
	bne.s	Tkl3
	bra	TklT
* Token rapide suivant
TkRNext	move.w	(a2)+,d0
	beq	TkNext
	move.l	0(a6,d7.w),a1
	add.w	d0,a1
	move.l	a1,d4
	lea	5(a1),a1
	move.b	-1(a1),d0
	cmp.b	#"!",d0
	beq.s	TkRe0a
	cmp.b	#" ",d0
	bne.s	TkRe0
TkRe0a	addq.l	#1,a1
* Explore les autres lettres du token
TkRe0	move.l	a3,a0
TkRe1	move.b	(a0)+,d0
	bsr	MinD0
TkRe2	move.b	(a1)+,d1
	bmi.s	TkKT
	cmp.b	#TkRemp,d1
	beq.s	TkRe2
	cmp.b	#" ",d1
	bne.s	TkRe3
	cmp.b	d1,d0
	bne.s	TkRe2
	beq.s	TkRe1
TkRe3	cmp.b	d0,d1
	beq.s	TkRe1
* Mot cle suivant
TkRe4	tst.l	d6
	bpl.s	Tkl3
	bmi.s	TkRNext
* Mot trouve?
TkKt:	subq.l	#1,a0
	subq.l	#1,a1
	and.b	#$7f,d1
	cmp.b	#" ",d1
	beq.s	TkKt1
	cmp.b	d0,d1
	bne.s	TkRe4
	addq.l	#1,a0
TkKt1:	move.l	a0,a3
* Token normal
TklT	tst.w	d7
	bne	TkKtE
	sub.l	#Tk,d4
TkKt0:	move.w	d4,(a4)+
	bclr	#4,d5			* Plus de numero de ligne
	bset	#3,d5			* Plus debut de ligne
	cmp.w	#TkOn-Tk,d4
	beq.s	TkKt7
	cmp.w	#TkData-Tk,d4
	beq	TkKt3
	cmp.w	#TkRem1-Tk,d4
	beq.s	TkKt2
	cmp.w	#TkFor-Tk,d4
	beq.s	TkKt3
	cmp.w	#TkRpt-Tk,d4
	beq.s	TkKt3
	cmp.w	#TkWhl-Tk,d4
	beq.s	TkKt3
	cmp.w	#TkDo-Tk,d4
	beq.s	TkKt3	
	cmp.w	#TkExit-Tk,d4
	beq.s	TkKt4
	cmp.w	#TkExIf-Tk,d4
	beq.s	TkKt4
	cmp.w	#TkIf-Tk,d4
	beq.s	TkKt3
	cmp.w	#TkElse-Tk,d4
	beq.s	TkKta
	cmp.w	#TkThen-Tk,d4
	beq.s	TkKtb
	cmp.w	#TkProc-Tk,d4
	beq.s	TkKt6
	bra	TokLoop
* ON
TkKt7:	clr.l	(a4)+
	bra	TokLoop
* Debut d'une REM
TkKt2:	clr.w	(a4)+
	move.l	a4,TkAd(a5)
	bset	#5,d5
	bra	TokLoop
* Token avec 2 octets
TkKt3:	clr.w	(a4)+
	bra	TokLoop
* Token avec 4 octets
TkKt4:	clr.l	(a4)+
	bra	TokLoop
* Token avec 8 octets
TkKt6:	clr.l	(a4)+
	clr.l	(a4)+
	bra	TokLoop
* Token d'extension! .w EXT/.b #Ext/.b Nb Par/.w TOKEN
TkKtE:	move.w	#TkExt-Tk,(a4)+
	move.w	d7,d0
	lsr.w	#2,d0
	move.b	d0,(a4)+
	clr.b	(a4)+
	lea	AdTokens(a5),a6
	sub.l	0(a6,d7.w),d4
	move.w	d4,(a4)+
	bclr	#4,d5
	bset	#3,d5
	bra	TokLoop
* ELSE/THEN: regarde si numero de ligne apres!
TkKta:	clr.w	(a4)+
TkKtb:	move.l	a3,a0
TkKtc:	move.b	(a0)+,d0
	beq	TokLoop
	cmp.b	#" ",d0
	beq	TkKtc
	cmp.b	#"0",d0
	bcs	TokLoop
	cmp.b	#"9",d0
	bhi	TokLoop
	move.l	a0,a3
	move.w	#TkLGo-Tk,d1
	bra.s	TkKf2

******* Rien trouve ===> debut d'une variable
TkKF:	move.w	#TkVar-Tk,d1
	move.b	-1(a3),d0
TkKf0:	cmp.b	#"A",d0
	bcs.s	TkKf1
	cmp.b	#"Z",d0
	bhi.s	TkKf1
	add.b	#"a"-"A",d0
TkKf1:	cmp.b	#"_",d0
	beq.s	TkKf2
	cmp.b	#128,d0
	bcc.s	TkKf2
	cmp.b	#"a",d0
	bcs	TokLoop
	cmp.b	#"z",d0
	bhi	TokLoop
TkKf2:	move.l	a4,TkAd(a5)
	move.w	d1,(a4)+
	clr.l	(a4)+
	move.b	d0,(a4)+
	bset 	#1,d5
	bra	TokLoop
* Appel d'un label?
TkKf3:	move.w	#TkLGo-Tk,d1
	cmp.b	#"0",d0
	bcs.s	TkKf0
	cmp.b	#"9",d0
	bls.s	TkKf2
	bra.s	TkKf0

******* Fin de la tokenisation
TokFin:	btst	#1,d5		Fin de variable
	bne	TkFV	
	btst	#0,d5		Fin de chaine alphanumerique
	bne	TkChf
	btst	#5,d5		REM
	beq.s	TokPaR
	move.w	a4,d0
	btst	#0,d0		Rend pair la REM!
	beq.s	FRem
	move.b	#" ",(a4)+
FRem:	move.l	a4,d0		Calcule et stocke la longueur
	move.l	TkAd(a5),a0
	sub.l	a0,d0
	move.w	d0,-2(a0)
* Marque la fin
TokPaR:	clr.w	(a4)+
* Poke la longueur de la ligne / 2
	movem.l	(sp)+,a0/a6
	move.l	a4,d0
	sub.l	a0,d0
	lsr.w	#1,d0
	move.b	d0,(a0)
	moveq	#-1,d0		* VRAI
	rts

******* Ligne vide
TokVide:addq.l	#8,sp
	moveq	#0,d0		* FAUX
	rts

* Routine: D0 minuscule
MinD0	cmp.b	#"A",d0
	bcs.s	Mnd0a
	cmp.b	#"Z",d0
	bhi.s	Mnd0a
	add.b	#32,d0
Mnd0a	rts
* Routine: token suivant
TklNext	tst.b	(a1)+			* Saute le nom
	bpl.s	TklNext
Tkln1	tst.b	(a1)+			* Saute les params
	bpl.s	Tkln1
	move.w	a1,d1
	btst	#0,d1			* Rend pair
	beq.s	Tkln2
	addq.l	#1,a1
Tkln2	tst.w	(a1)
	rts

***********************************************************
*	DETOKENISE TOUT LE BUFFER
***********************************************************
BufUntok:
	clr.w	-(sp)
	move.w	EdYPos(a5),d0
	bsr	FindL
	bra.s	BUnt1
BUnt0	bsr	NextL
BUnt1	move.w	(sp),d1
	move.l	EdBufE(a5),a1
	lsl.w	#8,d1
	lea	0(a1,d1.w),a4
	clr.w	(a4)
	tst.w	d0
	beq.s	BUnt2
	move.l	a0,a6
	sub.l	a3,a3
	bsr	Detok
BUnt2	addq.w	#1,(sp)
	move.w	(sp),d0
	cmp.w	EdTyM0(a5),d0
	bcs.s	BUnt0
	addq.l	#2,sp
	rts
	
***********************************************************
*	DETOKENISE la LIGNE D0 dans le BUFFER ligne D1
***********************************************************
Untok:	movem.l	d0-d7/a0-a6,-(sp)
	move.l	EdBufE(a5),a1
	lsl.w	#8,d1
	lea	0(a1,d1.w),a4
	clr.w	(a4)
	bsr	FindL
	beq.s	UntFin
	move.l	a0,a6
	sub.l	a3,a3
	bsr	Detok
UntFin:	movem.l	(sp)+,d0-d7/a0-a6
	rts

***********************************************************
*	DETOKENISATION DE LA LIGNE
*	A6 ---> A4
***********************************************************
TtDetok:
	lea	2(a4),a4
	move.l	a4,a2
	clr.w	-(sp)
	clr.w	d5
	bra.s	DtkLoop
Detok:	
	lea	2(a4),a4		* Place pour la taille
	move.l	a4,a2
	clr.w	-(sp)			* Position du curseur

******* HELP bug!!!!!!!!
	tst.b	(a6)
	beq	DtkFin
******* Met les espaces devant
	clr.w	d0
	move.b	1(a6),d0
	subq.w	#2,d0
	bmi.s	Dtk2
Dtk1:	move.b	#" ",(a4)+
	dbra	d0,Dtk1
Dtk2:	addq.l	#2,a6
	clr.w	d5
******* Boucle de detokenisation
DtkLoop:cmp.l	a3,a6			* Trouve la P en X?
	bne.s	Dtk0
	move.l	a4,d0
	sub.l	a2,d0
	move.w	d0,(sp)
Dtk0:	move.l	a3,d1			* Appele par TUTOR?
	bpl.s	.skip
	movem.l	a0-a6/d0-d7,-(sp)
	jsr	TtDecoupe
	movem.l	(sp)+,a0-a6/d0-d7
.skip	move.w	(a6)+,d0
	beq	DtkFin
	cmp.w	#TkLGo-Tk,d0
	bls	DtkVar
	cmp.w	#TkExt-Tk,d0
	bcs	DtkCst
	bclr	#0,d5
	lea	AdTokens(a5),a0
	cmp.w	#TkPar1-Tk,d0
	beq	DtkP
	cmp.w	#TkExt-Tk,d0
	bne.s	Dtk0a

* Detokenise une extension
	move.w	2(a6),d1
	move.b	(a6),d2
	ext.w	d2
	move.w	d2,d3
	lsl.w	#2,d2
	tst.l	0(a0,d2.w)
	beq.s	DtkEe
	move.l	0(a0,d2.w),a0
	lea	4(a0,d1.w),a0
	move.l	a0,a1
	bra.s	Dtk3
* Extension not present
DtkEe:	Alea	ExtNot,a0
	add.b	#"A",d3
	add.b	#$80,d3
	move.l	a0,a1
DtkEee	tst.b	(a1)+
	bpl.s	DtkEee
	move.b	d3,-1(a1)
	move.w	#"I",d3
	bra.s	Dtk3a

* Instruction normale
Dtk0a:	lea	Tk,a0
	lea	4(a0,d0.w),a0
	move.l	a0,a1
Dtk3:	tst.b	(a1)+
	bpl.s	Dtk3
	move.b	(a1),d3
	cmp.b	#"O",d3
	beq.s	Dtk4
	cmp.b	#"0",d3
	beq.s	Dtk4
	cmp.b	#"1",d3
	beq.s	Dtk4
	cmp.b	#"2",d3
	beq.s	Dtk4
	cmp.b	#"V",d3
	beq.s	Dtk4
* Met un espace avant s'il n'y en a pas!
Dtk3a:	cmp.l	a4,a2		* Debut de la ligne?
	beq.s	Dtk4
	cmp.b	#" ",-1(a4)
	beq.s	Dtk4
	move.b	#" ",(a4)+
* Doit prendre le token prececent?
Dtk4:	cmp.b	#$80,(a0)
	bne.s	Dtk4x
	subq.l	#4,a0
Dtk4a:	move.b	-(a0),d1
	cmp.b	#"!",d1
	beq.s	Dtk4x
	cmp.b	#$80,d1
	bne.s	Dtk4a
	bra.s	Dtk4
* Ecrit le mot
Dtk4x:	cmp.b	#"!",(a0)
	bne.s	Dtk4y
	addq.l	#1,a0
Dtk4y:	move.w	DtkMaj1(a5),d1
	beq.s	Dtk5
	cmp.w	#1,d1
	beq.s	Dtk6
	bne.s	Dtk8
* 0- Ecrit en MINUSCULES
Dtk5:	move.b	(a0)+,d1
	cmp.b	#TkRemp,d1
	beq.s	Dtk5
	move.b	d1,(a4)+
	bpl.s	Dtk5
	and.b	#$7f,-1(a4)
	bra.s	DtkE
* 1- Ecrit en MAJUSCULES
Dtk6:	move.b	(a0)+,d1
	cmp.b	#TkRemp,d1
	beq.s	Dtk6
	move.b	d1,d2
	and.b	#$7f,d1
	cmp.b	#"a",d1
	bcs.s	Dtk7
	cmp.b	#"z",d1
	bhi.s	Dtk7
	sub.b	#"a"-"A",d1
Dtk7:	move.b	d1,(a4)+
	tst.b	d2
	bpl.s	Dtk6
	bra	DtkE
* 2- Ecrit AVEC UNE MAJUSCULE
Dtk8:	move.b	(a0)+,d1
	cmp.b	#TkRemp,d1
	beq.s	Dtk8
	move.b	d1,d2
	and.b	#$7f,d1
	cmp.b	#"a",d1
	bcs.s	Dtk9
	cmp.b	#"z",d1
	bhi.s	Dtk9
	sub.b	#"a"-"A",d1
Dtk9:	move.b	d1,(a4)+
	tst.b	d2
	bmi.s	DtkE
Dtk9a:	move.b	(a0)+,d1
	cmp.b	#TkRemp,d1
	beq.s	Dtk9a
	move.b	d1,(a4)+
	bmi.s	Dtk9b
	cmp.b	#" ",d1
	bne.s	Dtk9a
	bra.s	Dtk8
Dtk9b:	and.b	#$7f,-1(a4)
* Met une espace si c'est une INSTRUCTION
DtkE:	cmp.w	#TkRem1-Tk,d0
	beq	DtkRem
	cmp.w	#TkRem2-Tk,d0
	beq	DtkRem
	cmp.b	#"I",d3
	bne.s	DtkE1
	move.b	#" ",(a4)+
* Saute le token...
DtkE1:	move.l	a6,a0
	bsr	TInst
	move.l	a0,a6
	bra	DtkLoop
* Ouverture de parenthese, jamais d'espace!
DtkP:	cmp.l	a4,a2
	beq.s	DtkP1
	cmp.b 	#" ",-1(a4)
	bne.s	DtkP1
	subq.l	#1,a4
DtkP1:	move.b	#"(",(a4)+
	bra.s	DtkE1

******* Detokenisation de VARIABLE
DtkVar:	btst	#0,d5		* Si variable juste avant, met 32
	beq.s	DtkV0
	cmp.b	#" ",-1(a4)
	beq.s	DtkV0
	move.b	#" ",(a4)+
DtkV0:	move.b	2(a6),d2	* Longueur
	ext.w	d2
	move.w	d2,d1
	subq.w	#1,d1
	move.b	3(a6),d3	FLAG
	lea	4(a6),a0
	moveq	#0,d4
	cmp.w	#TkLab-Tk,d0
	bne.s	DtkV1
	moveq	#1,d4		D4: 0=> Variable 
	cmp.b	#"0",(a0)	    1=> Label
	bcs.s	DtkV1		   -1=> Numero ligne
	cmp.b	#"9",(a0)
	bhi.s	DtkV1
	moveq	#-1,d4
DtkV1:	move.w	DtkMaj2(a5),d0
	beq.s	DtkV2
	cmp.w	#1,d0
	beq.s	DtkV3
	bne.s	DtkV5
* 0- En MINUSCULES
DtkV2:	move.b	(a0)+,d0
	beq	DtkVF
	move.b	d0,(a4)+
	dbra	d1,DtkV2
	bra	DtkVF
* 1- En MAJUSCULES
DtkV3:	move.b	(a0)+,d0
	beq	DtkVF
	cmp.b	#"a",d0
	bcs.s	DtkV4
	cmp.b	#"z",d0
	bhi.s	DtkV4
	sub.b	#"a"-"A",d0
DtkV4:	move.b	d0,(a4)+
	dbra	d1,DtkV3
	bra	DtkVF
* 2- Avec UNE MAJUSCULE
DtkV5:	move.b	(a6)+,d0
	cmp.b	#"a",d0
	bcs.s	DtkV6
	cmp.b	#"z",d0
	bhi.s	DtkV6
	sub.b	#"a"-"A",d0
DtkV6:	move.b	d0,(a4)+
	dbra	d1,DtkV2
* Saute la variable / met le flag de la variable
DtkVF:	bset	#0,d5
	lea	4(a6,d2.w),a6
	moveq	#":",d0
	tst.w	d4
	bmi	DtkLoop
	bne.s	DtkV7
	moveq	#"#",d0
	and.b	#3,d3
	cmp.b	#1,d3
	beq.s	DtkV7
	moveq	#"$",d0
	cmp.b	#2,d3
	bne	DtkLoop
DtkV7:	move.b	d0,(a4)+
	bra	DtkLoop

******* Detokenise des constantes
DtkCst:	bclr	#0,d5		Si variable avant, met un espace!
	beq.s	DtkC0
	cmp.b	#" ",-1(a4)
	beq.s	DtkC0
	move.b	#" ",(a4)+
DtkC0:	cmp.w	#TkEnt-Tk,d0
	beq.s	DtkC3
	cmp.w	#TkHex-Tk,d0
	beq.s	DtkC4
	cmp.w	#TkBin-Tk,d0
	beq.s	DtkC5
	cmp.w	#TkFl-Tk,d0
	beq.s	DtkC6
* Detokenise une chaine alphanumerique
	cmp.w	#TkCh1-Tk,d0
	bne.s	DtkC0a
	moveq	#'"',d0
	bra.s	DtkC0b
DtkC0a:	moveq	#"'",d0
DtkC0b:	move.b	d0,(a4)+
	move.w	(a6)+,d1
	subq.w	#1,d1
	bmi.s	DtkC2
DtkC1:	move.b	(a6)+,(a4)+
	dbra	d1,DtkC1
	move.w	a6,d1
	btst	#0,d1
	beq.s	DtkC2
	addq.l	#1,a6
DtkC2:	move.b	d0,(a4)+
	bra	DtkLoop
* Detokenise un chiffre entier
DtkC3:	move.l	(a6)+,d0
	move.l	a4,a0
	bsr	LongDec
	move.l	a0,a4
	bra	DtkLoop
* Detokenise un chiffre HEXA
DtkC4:	move.l	(a6)+,d0
	move.l	a4,a0
	bsr	LongAscii
	move.l	a0,a4
	bra	DtkLoop
* Detokenise un chiffre BINAIRE
DtkC5:	move.l	(a6)+,d0
	move.l	a4,a0
	bsr	LongBin
	move.l	a0,a4
	bra	DtkLoop
* Detokenise un chiffre FLOAT
DtkC6:	move.l	(a6)+,d0
	move.l	a4,a0
	moveq	#-1,d4
	moveq	#0,d5
	bsr	DtkFl
	exg	a0,a4
DtkC7	move.b	(a0)+,d0		* Si pas de .0, le met!
	beq.s	DtkC8
	cmp.b	#".",d0
	beq	DtkLoop
	cmp.b	#"E",d0
	beq	DtkLoop
	bra.s	DtkC7
DtkC8	move.b	#".",(a4)+
	move.b	#"0",(a4)+
	bra	DtkLoop

******* Token d'extension
DtkX:	bra	DtkLoop

******* REMarque
DtkRem:	addq.w	#2,a6		Saute la longueur
DtkR:	tst.b	(a6)
	beq	DtkLoop
	move.b	(a6)+,(a4)+
	bra.s	DtkR 

******* Fin de la DETOKENISATION
DtkFin:	sub.l	a2,a4		* Ramene PX
	move.w	a4,-2(a2)
	move.w	(sp)+,d0
	rts


***********************************************************
*	DEFAULT EN MODE DIRECT
EdDefo:
	tst.w	DefFlag(a5)
	beq.s	EdDx
	jsr	DefRun
	jsr	DefRun2
	EcCalD	Last,0
EdDx:	rts

***********************************************************
*	NEW
***********************************************************
******* TOUCHE DE FONCTION
EdNew:	bsr	TokCur
	Alea	ConfConf,a0
	bsr	ConFirm
	beq	NotDone
	bsr	Saved
	bsr	RNew
	bsr	NewBuf
	bra	AverFin

***********************************************************
*	STOCKE LA LIGNE (A1) EN POSITION D1
***********************************************************
Stocke:	move.w	d1,d6
	moveq	#1,d7
	move.w	d1,d0
	bsr	FindL			* Cherche l'adresse ---> A0
	moveq	#0,d2			* Longueur de la ligne
	move.b	(a1),d2
	lsl.w	#1,d2
* Fin du programme?
	moveq	#0,d1
	move.b	(a0),d1
	lsl.l	#1,d1			* Longueur ligne actuelle
	beq.s	StoI
	tst.w	EdILigne(a5)
	bne.s	StoI	

******* Remplacement d'une ligne
	move.l	a0,a6
	cmp.w	#TkProc-Tk,2(a0)	* On est sur une procedure fermee???
	bne.s	.Stck1
	tst.w	10(a0)
	bmi	StoClo
.Stck1	cmp.l	d1,d2
	beq	StoCop
	bhi.s	StoR5
* Nouvelle plus petite
	move.l	a0,a2
	sub.l	d2,d1
	add.l	d1,a0
	move.l	a0,a3
	move.l	StBas(a5),d0
	bra.s	StoR2
StoR1:	move.w	-(a2),-(a3)
StoR2:	cmp.l	d0,a2
	bhi.s	StoR1
	move.l	a3,StBas(a5)
	move.l	d1,d0
	move.l	a0,d1
	bra.s	StoCop
* Nouvelle plus grande
StoR5:	move.l	d2,d0
	sub.l	d1,d0
	moveq	#0,d5
	bra.s	StoI0

******* Insertion d'une ligne
StoI:	move.l	d2,d0
	moveq	#1,d5
StoI0:	move.l	StBas(a5),a2
	move.l	a2,a3
	sub.l	d0,a3
	cmp.l	StMini(a5),a3
	bls	StoMem
	move.l	a3,StBas(a5)
	bra.s	StoI2
StoI1:	move.w	(a2)+,(a3)+		* Fait de la place
StoI2:	cmp.l	a0,a2
	bcs.s	StoI1
	move.l	a0,d1	
	sub.l	d0,a0
	neg.l	d0

******* Change les pointeurs
	add.w	d5,EdNLigne(a5)
	add.w	d5,StNLigne(a5)
	bsr	ChgBloc
StoCop	bsr	ChgMark

******* Copie de la ligne
	move.l	a0,a6
	lsr.l	#1,d2
StoC:	move.w	(a1)+,(a0)+		* Copie la ligne
	subq.l	#1,d2
	bne.s	StoC

******* Nettoie les variables (si pas MERGE!)
* <> Flags
	move.w	#1,EtFr(a5)
	move.w	#1,EdChange(a5)
	addq.w	#1,StModif(a5)
StoClo	moveq	#0,d0
	rts

******* Out of mem
StoMem:	moveq	#1,d0
	rts

***********************************************************
*	ENLEVE LA LIGNE D1
***********************************************************
DeLigne:move.w	d1,d6
	moveq	#-1,d7
	move.w	d1,d0
	bsr	FindL
	beq.s	DelLX
	cmp.w	#TkProc-Tk,2(a0)	* Pas si procedure fermee!
	bne.s	DelL0
	tst.w	10(a0)
	bmi.s	DelLN
DelL0	moveq	#0,d0
	move.b	(a0),d0
	lsl.w	#1,d0
	lea	0(a0,d0.w),a1
* Entree pour le bloc
DelBis	move.l	StBas(a5),a2
	move.l	a0,d1
	bra.s	DelL2
DelL1:	move.w	-(a0),-(a1)
DelL2:	cmp.l	a2,a0
	bhi.s	DelL1
	move.l	a1,StBas(a5)
* Marks
	bsr	ChgMark
* Bloc
	bsr	ChgBloc
* Flags
	subq.w	#1,EdNLigne(a5)
	subq.w	#1,StNLigne(a5)
	move.w	#1,EtFr(a5)
	move.w	#1,EdChange(a5)
	addq.w	#1,StModif(a5)
DelLX:	moveq	#0,d0
	rts
DelLN	moveq	#1,d0
	rts

******* Change les marks
*	D0= Decalage
*	D1= Ad pivot
ChgMark	movem.l	d1/d2/d3/d4/a0,-(sp)
	sub.l	StMini(a5),d1
	moveq	#9,d2
	lea	EdMarks(a5),a0
DelL3	move.l	(a0),d3
	beq.s	DelL4
	move.l	d3,d4
	and.l	#$00FFFFFF,d3
	cmp.l	d1,d3
	bcc.s	DelL4
	add.l	d0,d3
	and.l	#$FF000000,d4
	or.l	d4,d3
	move.l	d3,(a0)
DelL4	addq.l	#4,a0
	dbra	d2,DelL3
	movem.l	(sp)+,d1/d2/d3/d4/a0
	rts
******* Change le bloc
ChgBloc	cmp.w	Y2Bloc(a5),d6
	bcc.s	StoIa
	add.w	d7,Y2Bloc(a5)
StoIa	cmp.w	Y1Bloc(a5),d6
	bhi.s	StoIb
	add.w	d7,Y1Bloc(a5)
StoIb	rts

***********************************************************
*	TROUVE L'ADRESSE DE LA LIGNE D0 (coord editeur)
*	Si au milieu d'une procedure, AD ---> ADPROC
***********************************************************
FindL:	move.l	d1,-(sp)
	clr.l	DebProc(a5)
	move.l	StBas(a5),a0
	subq.w	#1,d0
	bmi.s	FndT
* Boucle principale
Fnd0	moveq	#0,d1
Fnd1	move.b	(a0),d1
	beq.s	FndT
	cmp.w	#TkProc-Tk,2(a0)
	beq.s	Fnd4
Fnd2	add.w	d1,a0
	add.w	d1,a0
Fnd3	dbra	d0,Fnd1
	bra.s	FndT
* Debut de procedure
Fnd4	tst.w	10(a0)			* Fermee
	bpl.s	Fnd5
	move.l	4(a0),d1
	lea	12+2(a0,d1.l),a0
	moveq	#0,d1
	bra.s	Fnd3
Fnd5	move.l	a0,DebProc(a5)		* Ouverte
	bra.s	Fnd7
Fnd6	move.b	(a0),d1
	beq.s	FndT
	cmp.w	#TkEndP-Tk,2(a0)
	beq.s	Fnd8
Fnd7	add.w	d1,a0
	add.w	d1,a0
	dbra	d0,Fnd6
	bra.s	FndT
Fnd8	clr.l	DebProc(a5)
	bra.s	Fnd2
* Trouve!
FndT	move.l	(sp)+,d1
	move.l	a0,CurLigne(a5)
	move.w	(a0),d0
	beq.s	FndT1
	cmp.w	#TkProc-Tk,2(a0)
	bne.s	FndT1
	move.l	a0,DebProc(a5)
	tst.w	d0
FndT1	rts
******* Trouve la ligne (editeur) suivante
NextL:	move.l	d1,-(sp)
	move.l	CurLigne(a5),a0
	moveq	#0,d0
	bra.s	Fnd0
	
***********************************************************
*	TROUVE LE NUMERO ET LE DEBUT DE LA LIGNE A0
*	D0-> Numero
*	D1-> Adresse debut proc
***********************************************************
FindA:	movem.l	d2/a1/a2,-(sp)
	move.l	StBas(a5),a2
	moveq	#-1,d0
	moveq	#0,d1
	moveq	#0,d2
FdA1:	addq.l	#1,d0
	move.l	a2,a1
	move.b	(a2),d2
	beq.s	FdAT
	cmp.w	#TkProc-Tk,2(a2)
	beq.s	FdA4
FdA2	add.w	d2,a2
	add.w	d2,a2
FdA3	cmp.l	a0,a2
	bls.s	FdA1
	bra.s	FdAT
* Une procedure
FdA4	tst.w	10(a2)
	bpl.s	FdA2
	move.l	a2,d1
	btst	#4,10(a2)
	beq.s	FdA6
	add.l	4(a2),a2
	lea	12+2(a2),a2
	moveq	#0,d2
	bra.s	FdA6
FdA5	move.l	a2,a1
	move.b	(a2),d2
	beq.s	FdAT
	cmp.w	#TkEndP-Tk,2(a2)
	beq.s	FdA7
FdA6	add.w	d2,a2
	add.w	d2,a2
	cmp.l	a0,a2
	bls.s	FdA5
	bra.s	FdAT
FdA7	moveq	#0,d1
	bra.s	FdA2
* Trouve!
FdAT	move.l	a1,a0
	movem.l	(sp)+,d2/a1/a2
	rts

	EndC

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* CONVERSIONS
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
; MINI CHRGET POUR LES CONVERSIONS
minichr:  move.b (a0)+,d2
          beq.s mc1
          cmp.b #32,d2
          beq minichr
          cmp.b #"a",d2       ;si minuscule: majuscule
          bcs.s mc0
          sub.b #"a"-"A",d2
mc0:      sub.b #48,d2
          rts
mc1:      move.b #-1,d2
          rts

; CONVERSION DECIMAL->HEXA SUR QUATRE OCTETS, SIGNE!
declong:  clr.l d0
          clr.l d2
          clr d3
          move.l a0,-(sp)
ddh1:     bsr minichr
ddh1a:    cmp.b #10,d2
          bcc.s ddh5
          move d0,d1
          mulu #10,d1
          swap d0
          mulu #10,d0
          swap d0
          tst d0
          bne.s ddh2
          add.l d1,d0
          bcs.s ddh2
          add.l d2,d0
          bmi.s ddh2
          addq #1,d3
          bra.s ddh1
ddh2:     move.l (sp)+,a0
          move #1,d1          ;out of range: bpl, et recupere l'adresse
          rts
ddh5:     subq.l #1,a0
	  addq.l #4,sp
          tst d3
          beq.s ddh7
          clr d1              ;OK: chiffre en d0, et beq
          rts
ddh7:     move #-1,d1         ;pas de chiffre: bmi
          rts

; CONVERSION HEXA-ASCII EN HEXA-HEXA
hexalong: clr.l d0
          clr d2
          clr d3
          move.l a0,-(sp)
hh1:      bsr minichr2
          cmp.b #10,d2
          bcs.s hh2
          cmp.b #17,d2
          bcs.s ddh5
          sub #7,d2
hh2:      cmp.b #16,d2
          bcc.s ddh5
          lsl.l #4,d0
          or.b d2,d0
          addq #1,d3
          cmp #9,d3
          bne.s hh1
          beq.s ddh2
minichr2  move.b (a0)+,d2
          beq.s .mc1
          cmp.b #"a",d2       ;si minuscule: majuscule
          bcs.s .mc0
          sub.b #"a"-"A",d2
.mc0:     sub.b #48,d2
          rts
.mc1:     move.b #-1,d2
          rts

; CONVERSION BINAIRE ASCII ---> HEXA SUR QUATRE OCTETS
binlong:  clr.l d0
          clr d2
          clr d3
          move.l a0,-(sp)
bh1:      bsr minichr
          cmp.b #2,d2
          bcc.s ddh5
          roxr #1,d2
          roxl.l #1,d0
          bcs.s ddh2
          addq #1,d3
          cmp #33,d3
          bne.s bh1
          beq ddh1

; CONVERSION HEXA--->DECIMAL SUR QUATRE OCTETS
longdec1: move #-1,d3         ;proportionnel
          moveq #1,d4         ;avec signe
          bra.s longent
longdec:  clr.l d4            ;proportionnel, sans espace si positif!
          move.l #-1,d3
; conversion proprement dite: LONG-->ENTIER
longent:  move.l a1,-(sp)
	  tst.l d0            ;test du signe!
          bpl.s hexy
          move.b #"-",(a0)+
          neg.l d0
          bra.s hexz
hexy:     tst d4
          beq.s hexz
          move.b #32,(a0)+
hexz:     tst.l d3
          bmi.s hexv
          neg.l d3
          add.l #10,d3
hexv:     move.l #9,d4
          lea multdix(pc),a1
hxx0:     move.l (a1)+,d1     ;table des multiples de dix
          move.b #$ff,d2
hxx1:     addq.b #1,d2
          sub.l d1,d0
          bcc.s hxx1
          add.l d1,d0
          tst.l d3
          beq.s hxx4
          bpl.s hxx3
          btst #31,d4
          bne.s hxx4
          tst d4
          beq.s hxx4
          tst.b d2
          beq.s hxx5
          bset #31,d4
          bra.s hxx4
hxx3:     subq.l #1,d3
          bra.s hxx5
hxx4:     add #48,d2
          move.b d2,(a0)+
hxx5:     dbra d4,hxx0
	  move.l (sp)+,a1
          rts

* TABLE DES MULTIPLES DE DIX
multdix:  dc.l 1000000000,100000000,10000000,1000000
          dc.l 100000,10000,1000,100,10,1,0

; CONVERSION HEXA-HEXA -> HEXA-ASCII
longascii:move.b #"$",(a0)+
          tst.l d3
          bmi.s ha0
          neg.l d3
          add.l #8,d3
ha0:      clr d4
          move #7,d2
ha1:      rol.l #4,d0
          move.b d0,d1
          and.b #$0f,d1
          cmp.b #10,d1
          bcs.s ha2
          add.b #7,d1
ha2:      tst.l d3
          beq.s ha4
          bpl.s ha3
          tst d4
          bne.s ha4
          tst d2
          beq.s ha4
          tst.b d1
          beq.s ha5
          move #1,d4
          bra.s ha4
ha3:      subq.l #1,d3
          bra.s ha5
ha4:      add #48,d1
          move.b d1,(a0)+
ha5:      dbra d2,ha1
          rts

; CONVERSION HEXA -> BINAIRE, avec choix du nombre de decimales!!!
longbin:  move.b #"%",(a0)+
          tst.l d3
          bmi.s hb0
          neg.l d3
          add.l #32,d3
hb0:      clr d4
          move #31,d2
hb1:      clr d1
          roxl.l #1,d0
          addx.b d1,d1
          tst.l d3            ;si d3<0: representation PROPORTIONNELLE
          beq.s hb3
          bpl.s hb2
          tst d4
          bne.s hb3
          tst d2
          beq.s hb3
          tst.b d1
          beq.s hb4
          move #1,d4
          bra.s hb3
hb2:      subq.l #1,d3
          bra.s hb4
hb3:      add.b #48,d1
          move.b d1,(a0)+
hb4:      dbra d2,hb1
          rts

; CONVERSION D'UN CHIFFRE FLOAT (d3) EN ASCII ---> (a0), 
strflasc: 
	bclr	#31,d4
	bra.s	Flta
floatasc: 
	bset	#31,d4
Flta:	move.l 	d3,d0
	move.w	FixFlg(a5),d4
        move.w 	ExpFlg(a5),d5
; entree pour la tokenisation
dtkfl: 	movem.l	a1-a3,-(sp)
	move.l	a0,a3
	lea	DeFloat(a5),a0
	bsr	FlToAsc
	btst	#31,d4			* Met un espace si >0?
	bne.s	p00a
	move.b	#32,(a3)+
	cmp.b	#"-",(a0)
	bne.s	P00a
	subq.l	#1,a3
p00a:   tst 	d4
        bmi.s 	p0b
p0a:    move.b 	(a0)+,(a3)+  		* FIX: imprime tout defloat!
        bne.s 	p0a
        bra 	p7
p0b:    move.l 	a0,a2
p1:     move.b 	(a2)+,d0
        cmp.b 	#".",d0
        beq.s 	p1a
        move.b 	d0,(a3)+
        bne.s 	p1
        bra.s 	p7
p1a:    move.l 	a2,a1        	;a1= ancien non nul
        move.l 	a2,a0
p2:     move.b 	(a0)+,d0
        beq.s 	p3
        cmp.b 	#"E",d0
        beq.s 	p3
        cmp.b 	#"0",d0
        beq.s 	p2
        move.l 	a0,a1
        bra.s 	p2
p3:     subq.l 	#1,a0
        move.l 	a0,d0        	;adresse de la fin du chiffre
        cmp.l 	a2,a1         	;imprime les chiffres utiles
        beq.s 	p5
        move.b 	#".",(a3)+
p4:     move.b 	(a2)+,(a3)+
        cmp.l 	a2,a1
        bne.s 	p4
p5:     move.l 	d0,a2
        cmp.b 	#"E",(a2)
        bne.s 	p6
        move.b 	#32,(a3)+    	;imprime un espace avant le E
p6:     move.b 	(a2)+,(a3)+
        bne.s 	p6
p7:     lea	-1(a3),a0
	movem.l	(sp)+,a1-a3
        rts

; SOUS PROGRAMME UTILISE PAR LA TOKENISATION
ValTok:	move.l	a0,-(sp)
	move.l	a0,a2
	movem.l a1-a2/d5-d7,-(sp)
	clr.w	d4
	bra.s	Val1c
; SOUS PROGRAMME UTILISE PAR VAL ET INPUT
valprg: move.l 	a0,-(sp)     		
        movem.l a1-a2/d5-d7,-(sp) 
        clr 	d4         
; y-a-tl un signe devant?
val1:   move.b 	(a0)+,d0   
        beq 	val10
        cmp.b 	#32,d0
        beq.s 	val1
        move.l 	a0,a2      
        subq.l 	#1,a2
        cmp.b 	#"-",d0
        bne.s 	val1a
        not 	d4
        bra.s 	val1c
val1a:  cmp.b 	#"+",d0
        beq.s 	val1c
val1b:  subq.l 	#1,a0
; est-un HEXA ou un BINAIRE?
val1c:  move.b 	(a0)+,d0
        beq 	val10
        cmp.b 	#32,d0
        beq.s 	val1c
        cmp.b 	#"$",d0      	;chiffre HEXA
        beq 	val5
        cmp.b	#"%",d0       	;chiffre BINAIRE
        beq 	val6
        cmp.b 	#".",d0
        beq.s 	val2
        cmp.b 	#"0",d0
        bcs 	val10
        cmp.b 	#"9",d0
        bhi 	val10
; c'estn chiffre DECIMAL: entier ou float?
val2:   subq.l	#1,a0
	move.l 	a0,a1        	;si float: trouve la fin du chiffre
        clr 	d3
val3:   move.b 	(a1)+,d0
        beq.s 	val4
        cmp.b 	#32,d0
        beq.s 	val3
        cmp.b 	#"0",d0
        bcs.s 	val3z
        cmp.b 	#"9",d0
        bls.s 	val3
val3z:  cmp.b 	#".",d0       	;cherche une "virgule"
        bne.s	val3a
        bset 	#0,d3          	;si deux virgules: fin du chiffre
        beq.s 	val3
        bne.s 	val4
val3a:  cmp.b 	#"e",d0       	;cherche un exposant
        beq.s 	val3b
        cmp.b 	#"E",d0       	;autre caractere: fin du chiffre
        bne.s 	val4
val3ab: move.b 	#"e",-1(a1)  	;met un E minuscule!!!
val3b:  move.b 	(a1)+,d0     	;apres un E, accepte -/+ et chiffres
        cmp.b 	#32,d0
        beq.s 	val3b
        cmp.b 	#"+",d0
        beq.s 	val3c
        cmp.b 	#"-",d0
        bne.s 	val3e
val3c:  bset 	#1,d3          	;+ ou -: c'est un float! 
val3d:  move.b 	(a1)+,d0     	;puis cherche la fin de l'exposant
        cmp.b 	#32,d0
        beq.s 	val3d
val3e:  cmp.b 	#"0",d0
        bcs.s 	val4
        cmp.b 	#"9",d0       	;chiffre! c'est un float
        bls.s 	val3c
val4:   tst 	d3              ;si d3=0: c'est un entier
        beq 	val7
; conversion ASCII--->FLOAT
	move.l	a2,a0
        subq.l 	#1,a1
	movem.l	a1/a3-a6,-(sp)
	lea 	BuFloat(a5),a2
	move.l	a2,-(sp)
	moveq 	#18,d1
Ca1:	cmp.l	a0,a1
	beq.s	Ca2
	move.b 	(a0)+,d0
	cmp.b 	#32,d0
	beq.s 	Ca1
	move.b 	d0,(a2)+
	dbra 	d1,Ca1
Ca2:	clr.b 	(a2)
	clr.b 	1(a2)
	bsr 	atof
	addq.l 	#4,sp
	move.l	d0,d3
        moveq 	#1,d2
        move.w 	#TkFl-Tk,d1        ;chiffre FLOAT
	movem.l	(sp)+,a0/a3-a6
        movem.l (sp)+,a1-a2/d5-d7
        addq.l 	#4,sp
	moveq	#0,d0
        rts
; chiffre hexa
val5:   bsr 	hexalong
        move.w 	#TkHex-Tk,d2
        bra.s 	val8
; chiffre binaire
val6:   bsr 	binlong
        move.w 	#TkBin-Tk,d2
        bra.s 	val8
; chiffre entier
val7:   bsr 	declong
        move.w 	#TkEnt-Tk,d2
val8:   exg 	d2,d1           ;type de conversion--->d1
        tst 	d2
        bne.s 	val10           ;si probleme: ramene zero!
        move.l 	d0,d3
; test du signe
        tst 	d4
        beq.s 	val8a
        neg.l 	d3
val8a:  movem.l (sp)+,a1-a2/d5-d7
        addq.l 	#4,sp           ;pas d'erreur, ne recupere pas l'adresse debut
        moveq	#0,d2
        rts
; ramene zero
val10:  moveq	#0,d2           ;ramene zero!
        moveq	#0,d3
        movem.l (sp)+,a1-a2/d5-d7
        move.l 	(sp)+,a0        ;repointe au debut du chiffre
        moveq 	#1,d0           ;erreur!
        rts

******* FLOAT to ASCII
Zero:	dc.b 	"0.0000000",0
FlToAsc	movem.l a2/d1-d5,-(sp)
	movem.l	a3-a6,-(sp)
	move.l 	a0,TempBuf(a5)
	move.l 	d0,TempFl(a5)
	tst.w 	d5		;D5= FIX FLAG
	bne.s 	PaFix
	tst.w 	d4
	bmi.s 	PaFix
; Fix precise NORMAL
	cmp.w 	#8,d4
	bcs.s 	Fx1
	moveq 	#7,d4
Fx1:	move.w 	d4,-(sp)
	move.l 	a0,-(sp)
	move.l 	d0,-(sp)
	bsr 	ftoa
	lea 	10(sp),sp
	movem.l	(sp)+,a3-a6
	tst.w 	d4		;Si FIX=0, enleve le POINT!
	bne.s 	Fx2
	cmp.b 	#".",-1(a0)
	bne.s 	Fx2
	clr.b 	-(a0)
Fx2:	sub.l 	d0,a0
	exg 	d0,a0
	movem.l (sp)+,a2/d1-d5
	rts
; Representation proportionnelle
PaFix:	move.b 	d0,d1
	and.b 	#$7f,d1
	cmp.b 	#$41,d1
	bcs.s 	PaF1
	move.w 	#7,-(sp)
	bra.s 	PaF5
PaF1:	cmp.b 	#$31,d1
	bcs.s 	PaF2
	move.w 	#7+3,-(sp)
	bra.s 	PaF5
PaF2:	move.w 	#16+6,-(sp)	;Si >-1 et <1, demande 16 chiffres!
PaF5:	pea	BuFloat(a5)
	move.l 	d0,-(sp)
	bsr	ftoa
	lea 	10(sp),sp
	movem.l	(sp),a3-a6
	move.l 	d0,a1
	cmp.b 	#"-",(a1)
	bne.s 	PaFix1
	addq.l 	#1,a1
PaFix1:	move.l 	a1,a0
	cmp.b 	#"0",(a0)
	beq.s 	PaFix5
;-----> Chiffre >1
PaFix2:	move.b 	(a0)+,d0		;Compte AVANT la virgule
	beq.s 	PaFix3
	cmp.b 	#$2e,d0
	bne.s 	PaFix2
PaFix3:	sub.l 	a1,a0
	tst.w 	d5
	bne 	ExFix1
	moveq 	#7,d0
	cmp.w 	#8,a0		;Si >7 ---> representation E+
	bcc 	ExFix1
	sub.w 	a0,d0
	cmp.b 	#5,d0
	bcs 	Clean
	moveq 	#5,d0
	bra 	Clean
;-----> Chiffre <1
PaFix5:	addq.l 	#1,a0
	addq.l 	#1,a0
	move.l 	a0,a1
PaFix6:	move.b 	(a0)+,d0		;Compte le nombre de ZEROS
	beq.s 	PaFix7
	cmp.b 	#"0",d0
	beq.s 	PaFix6
PaFix7:	sub.l 	a1,a0
	clr.w 	d0
	cmp.w 	#16+6,a0		;Est-ce un vrai ZERO?
	bcs.s 	PaFix8
	move.w 	#6,a0
	moveq 	#1,d0
	bra.s 	PaFix9
PaFix8:	cmp.w 	#4,a0		;0.0001 ---> Exponantielle
	bcc 	ExVir1
PaFix9:	tst.w 	d5
	bne 	ExVir1	
	addq.w 	#6,a0
	move.w 	a0,d0
; Calcule BIEN, et nettoie le chiffre
Clean:	move.w 	d0,-(sp)
	pea	BuFloat(a5)
	move.l 	Tempfl(a5),-(sp)	
	bsr 	Ftoa
	lea 	10(sp),sp
	movem.l	(sp)+,a3-a6
	move.l 	d0,a0
	move.l 	TempBuf(a5),a1
Cl1:	move.b 	(a0)+,d0
	beq.s	Cl5
	move.b 	d0,(a1)+
	cmp.b 	#".",d0
	bne.s 	Cl1
	lea 	-1(a1),a2
Cl2:	move.b 	(a0)+,d0
	beq.s 	Cl3
	move.b 	d0,(a1)+
	cmp.b 	#"0",d0
	beq.s 	Cl2
	move.l 	a1,a2		;Dernier non nul
	bra.s 	Cl2
Cl3:	move.l 	a2,a1
Cl5:	clr.b 	(a1)
	move.l 	TempBuf(a5),a0
	sub.l 	a0,a1
	move.l 	a1,d0
	movem.l (sp)+,a2/d1-d5
	rts

;-----> Representation exponantielle >= 1
ExFix1:	move.w 	a0,d2
	subq.w 	#2,d2
	cmp.w 	#7,a0
	bcs.s 	Exf0
	move.w 	#7,a0
Exf0:	moveq 	#9,d0
	sub.w 	a0,d0
	move.w 	d0,-(sp)
	pea	BuFloat(a5)
	move.l 	TempFl(a5),-(sp)
	bsr 	ftoa
	lea 	10(sp),sp
	movem.l	(sp)+,a3-a6

	lea	BuFloat(a5),a0
	move.l 	TempBuf(a5),a1
	cmp.b 	#"-",(a0)
	bne.s 	Exf0a
	move.b 	(a0)+,(a1)+
Exf0a:	move.b 	(a0)+,(a1)+
	move.b 	#".",(a1)+
	lea 	-1(a1),a2
	move.w 	d4,d1
	bpl.s 	ExF1
	moveq 	#5,d1
	bra.s 	ExF2
Exf1:	cmp.w 	#5,d1
	bcs.s 	Exf2
	moveq 	#5,d1
Exf2:	move.b 	(a0)+,d0
	beq.s 	Exf2a
	cmp.b 	#".",d0
	beq.s 	Exf2
	move.b 	d0,(a1)+
	subq.w 	#1,d1
	bne.s 	Exf2
Exf2a:	clr.b 	(a1)
	tst.w 	d4
	bpl.s 	Exf5
; Enleve les zeros
	lea 	1(a2),a0
Exf3:	move.b 	(a0)+,d0
	beq.s 	Exf4
	cmp.b 	#"0",d0
	beq.s 	Exf3
	move.l 	a0,a2		;Dernier non nul
	bra.s 	Exf3
Exf4:	move.l 	a2,a1
; Rajoute le E+00
Exf5:	move.b 	#"E",(a1)+
	move.b 	#"+",(a1)+
	move.b 	#"0",(a1)+
Exf6:	cmp.b 	#10,d2
	bcs.s 	Exf7
	add.b 	#1,-1(a1)
	sub.w 	#10,d2
	bra.s 	Exf6
Exf7:	add.b 	#"0",d2
	move.b 	d2,(a1)+
	clr.b 	(a1)
	move.l 	TempBuf(a5),a0
	sub.l 	a0,a1
	move.l 	a1,d0
	movem.l (sp)+,a2/d1-d5
	rts

;-----> Exponantielle <1
ExVir1:	tst.w 	d0
	beq.s 	Exv0
	clr.w 	d2
	moveq 	#1,d3
	lea 	Zero(pc),a0
	bra.s 	Exv0a

Exv0:	clr.w 	d3
	move.w 	a0,d2
	addq.l 	#6,a0
	move.w 	a0,-(sp)
	pea	BuFloat(a5)
	move.l 	TempFl(a5),-(sp)
	bsr 	ftoa
	lea 	10(sp),sp
	movem.l	(sp)+,a3-a6
	lea	BuFloat(a5),a0

Exv0a:	move.l 	TempBuf(a5),a1
	cmp.b 	#"-",(a0)
	bne.s 	Exv1
	move.b 	(a0)+,(a1)+
Exv1:	lea 	2(a0),a2
Exv2:	move.b 	(a0)+,d0			;Cherche le debut du chiffre
	beq.s 	Exv3
	cmp.b 	#".",d0
	beq.s	Exv2
	cmp.b 	#"0",d0
	beq.s 	Exv2
	bra.s 	Exv4
Exv3:	move.l 	a2,a0
	moveq 	#"0",d0		 
Exv4:	move.w 	d4,d1
	bpl.s 	Exv5
	moveq 	#6,d1
	bra.s 	Exv6
Exv5:	cmp.w 	#6,d1
	bcs.s 	Exv6
	moveq 	#6,d1
Exv6:	move.b	d0,(a1)+
	move.b 	#".",(a1)+
	lea 	-1(a1),a2
	tst.w 	d1
	beq.s 	Exv7b
Exv7:	move.b 	(a0)+,d0
	beq.s 	Exv7a
	move.b 	d0,(a1)+ 
	cmp.b 	#"0",d0
	beq.s 	Exv7a
	move.l 	a1,a2
Exv7a	subq.w 	#1,d1
	bne.s 	Exv7
Exv7b:	tst.w 	d4		;Nettoie le chiffre
	bpl.s 	Exv8
	move.l 	a2,a1
Exv8:	tst.w 	d3
	bne 	Exf5
	move.b 	#"E",(a1)+
	move.b 	#"-",(a1)+
	move.b 	#"0",(a1)+
	bra 	Exf6	

*****************************************************************
*	CONVERSION FLOAT ---> ASCII
************************************
ftoa	LINK	A6,#-8
	MOVEM.L	D3-d7,-(A7)
	MOVE.L	$C(A6),-4(A6)
	TST.W	$10(A6)
	BGT.S	L27CDA
	MOVEQ	#1,D0
	BRA.S	L27CEC
L27CDA	CMPI.W	#$16,$10(A6)
	BLE.S	L27CE6
	MOVEQ	#$17,D0
	BRA.S	L27CEC
L27CE6	MOVE.W	$10(A6),D0
	ADDQ.W	#1,D0
L27CEC	MOVE.W	D0,D4
	CLR.W	D7
	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BGE.S	L27D1C
	MOVEA.L	$C(A6),A0
	MOVE.B	#$2D,(A0)
	ADDQ.L	#1,$C(A6)
	MOVE.L	8(A6),-(A7)
	JSR	L283A8
	ADDQ.L	#4,A7
	MOVE.L	D0,8(A6)
L27D1C	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BLE.S	L27D5A
	BRA.S	L27D46
L27D2E	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	SUBQ.W	#1,D7
L27D46	MOVE.L	#$80000041,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BLT.S	L27D2E
L27D5A	BRA.S	L27D74
L27D5C	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	ADDQ.W	#1,D7
L27D74	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BGE.S	L27D5C
	ADD.W	D7,D4
	MOVEQ	#1,D6
	MOVE.W	D6,D0
	EXT.L	D0
	MOVE.L	D0,-(A7)
	JSR	L28270
	ADDQ.L	#4,A7
	MOVE.L	D0,-8(A6)
	BRA.S	L27DB8
L27DA0	MOVE.L	#$A0000044,-(A7)
	MOVE.L	-8(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,-8(A6)
	ADDQ.W	#1,D6
L27DB8	CMP.W	D4,D6
	BLT.S	L27DA0
	MOVE.L	#$80000042,-(A7)
	MOVE.L	-8(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28212
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BLT.S	L27DFE
	MOVE.L	#$80000041,8(A6)
	ADDQ.W	#1,D7
L27DFE	TST.W	D7
	BGE.S	L27E36
	MOVEA.L	$C(A6),A0
	MOVE.B	#$30,(A0)
	ADDQ.L	#1,$C(A6)
	MOVEA.L	$C(A6),A0
	MOVE.B	#$2E,(A0)
	ADDQ.L	#1,$C(A6)
	TST.W	D4
	BGE.S	L27E20
	SUB.W	D4,D7
L27E20	MOVEQ	#-1,D6
	BRA.S	L27E32
L27E24	MOVEA.L	$C(A6),A0
	MOVE.B	#$30,(A0)
	ADDQ.L	#1,$C(A6)
	SUBQ.W	#1,D6
L27E32	CMP.W	D7,D6
	BGT.S	L27E24
L27E36	CLR.W	D6
	BRA.S	L27EA4
L27E3A	MOVE.L	8(A6),-(A7)
	JSR	L28300
	ADDQ.L	#4,A7
	MOVE.W	D0,D5
	MOVE.W	D5,D0
	ADD.W	#$30,D0
	MOVEA.L	$C(A6),A1
	MOVE.B	D0,(A1)
	ADDQ.L	#1,$C(A6)
	CMP.W	D7,D6
	BNE.S	L27E68
	MOVEA.L	$C(A6),A0
	MOVE.B	#$2E,(A0)
	ADDQ.L	#1,$C(A6)
L27E68	MOVE.W	D5,D0
	EXT.L	D0
	MOVE.L	D0,-(A7)
	JSR	L28270
	ADDQ.L	#4,A7
	MOVE.L	D0,-8(A6)
	MOVE.L	D0,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L283C4
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	ADDQ.W	#1,D6
L27EA4	CMP.W	D4,D6
	BLT.S	L27E3A
	MOVEA.L	$C(A6),A0
	CLR.B	(A0)
	ADDQ.L	#1,$C(A6)
	MOVE.L	-4(A6),D0
	TST.L	(A7)+
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS

******************************************************************
*	Conversion ASCII---> FLOAT
***********************************
Atof	LINK	A6,#-$2E
	MOVEM.L	D7/A4-A5,-(A7)
	LEA	-$14(A6),A5
	LEA	-$18(A6),A4
	CLR.W	-$1E(A6)
	CLR.W	-$26(A6)
	BRA.S	L27EDE
L27EDA	ADDQ.L	#1,8(A6)
L27EDE	MOVEA.L	8(A6),A0
	CMPI.B	#$20,(A0)
	BEQ.S	L27EDA
	MOVEA.L	8(A6),A0
	CMPI.B	#9,(A0)
	BEQ.S	L27EDA
	MOVEA.L	8(A6),A0
	CMPI.B	#$2D,(A0)
	BEQ.S	L27F00
	CLR.W	D0
	BRA.S	L27F02
L27F00	MOVEQ	#1,D0
L27F02	MOVE.W	D0,-$22(A6)
	MOVEA.L	8(A6),A0
	CMPI.B	#$2D,(A0)
	BEQ.S	L27F1A
	MOVEA.L	8(A6),A0
	CMPI.B	#$2B,(A0)
	BNE.S	L27F1E
L27F1A	ADDQ.L	#1,8(A6)
L27F1E	BRA.S	L27F44
L27F20	MOVEA.L	8(A6),A0
	CMPI.B	#$2E,(A0)
	BNE.S	L27F30
	ADDQ.W	#1,-$1E(A6)
	BRA.S	L27F40
L27F30	MOVEA.L	8(A6),A0
	MOVE.B	(A0),(A5)+
	TST.W	-$1E(A6)
	BEQ.S	L27F40
	ADDQ.W	#1,-$26(A6)
L27F40	ADDQ.L	#1,8(A6)
L27F44	MOVEA.L	8(A6),A0
	TST.B	(A0)
	BEQ.S	L27F60
	MOVEA.L	8(A6),A0
	CMPI.B	#$65,(A0)
	BEQ.S	L27F60
	MOVEA.L	8(A6),A0
	CMPI.B	#$45,(A0)
	BNE.S	L27F20
L27F60	CLR.B	(A5)
	MOVEA.L	8(A6),A0
	CMPI.B	#$65,(A0)
	BEQ.S	L27F76
	MOVEA.L	8(A6),A0
	CMPI.B	#$45,(A0)
	BNE.S	L27FBA
L27F76	ADDQ.L	#1,8(A6)
	MOVEA.L	8(A6),A0
	CMPI.B	#$2D,(A0)
	BEQ.S	L27F88
	CLR.W	D0
	BRA.S	L27F8A
L27F88	MOVEQ	#1,D0
L27F8A	MOVE.W	D0,-$20(A6)
	MOVEA.L	8(A6),A0
	CMPI.B	#$2D,(A0)
	BEQ.S	L27FA2
	MOVEA.L	8(A6),A0
	CMPI.B	#$2B,(A0)
	BNE.S	L27FA6
L27FA2	ADDQ.L	#1,8(A6)
L27FA6	BRA.S	L27FB2
L27FA8	MOVEA.L	8(A6),A0
	MOVE.B	(A0),(A4)+
	ADDQ.L	#1,8(A6)
L27FB2	MOVEA.L	8(A6),A0
	TST.B	(A0)
	BNE.S	L27FA8
L27FBA	CLR.B	(A4)
	MOVE.L	A6,(A7)
	ADDI.L	#$FFFFFFEC,(A7)
	BSR	L280A8
	MOVE.L	D0,-$2A(A6)
	MOVE.L	A6,(A7)
	ADDI.L	#$FFFFFFE8,(A7)
	JSR	L28654
	MOVE.W	D0,-$24(A6)
	TST.W	-$20(A6)
	BEQ.S	L27FF0
	MOVE.W	-$24(A6),D0
	NEG.W	D0
	SUB.W	-$26(A6),D0
	BRA.S	L27FF8
L27FF0	MOVE.W	-$24(A6),D0
	SUB.W	-$26(A6),D0
L27FF8	MOVE.W	D0,-$26(A6)
	MOVE.L	-$2A(A6),-(A7)
	MOVE.W	-$26(A6),-(A7)
	BSR.S	L28040
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,-$2E(A6)
	MOVE.L	-$2E(A6),(A7)
	JSR	L28116
	MOVE.L	D0,-$1C(A6)
	TST.W	-$22(A6)
	BEQ.S	L28032
	ORI.L	#$80,-$1C(A6)
L28032	MOVE.L	-$1C(A6),D0
	TST.L	(A7)+
	MOVEM.L	(A7)+,A4-A5
	UNLK	A6
	RTS
L28040	LINK	A6,#-8
	TST.W	8(A6)
	BGE.S	L28076
	MOVE.L	#$80000041,-4(A6)
	BRA.S	L2806E
L28054	MOVE.L	#$A0000044,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
	ADDQ.W	#1,8(A6)
L2806E	TST.W	8(A6)
	BLT.S	L28054
	BRA.S	L280A0
L28076	MOVE.L	#$80000041,-4(A6)
	BRA.S	L2809A
L28080	MOVE.L	#$A0000044,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
	SUBQ.W	#1,8(A6)
L2809A	TST.W	8(A6)
	BGT.S	L28080
L280A0	MOVE.L	-4(A6),D0
	UNLK	A6
	RTS
L280A8	LINK	A6,#-8
	MOVE.L	#0,-4(A6)
	BRA.S	L280FA
L280B6	MOVE.L	#$A0000044,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
	MOVE.L	-4(A6),-(A7)
	MOVEA.L	8(A6),A0
	MOVE.B	(A0),D0
	EXT.W	D0
	ADD.W	#$FFD0,D0
	EXT.L	D0
	MOVE.L	D0,-(A7)
	JSR	L28270
	ADDQ.L	#4,A7
	MOVE.L	D0,-(A7)
	JSR	L28212
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
	ADDQ.L	#1,8(A6)
L280FA	MOVEA.L	8(A6),A0
	CMPI.B	#$30,(A0)
	BLT.S	L2810E
	MOVEA.L	8(A6),A0
	CMPI.B	#$39,(A0)
	BLE.S	L280B6
L2810E	MOVE.L	-4(A6),D0
	UNLK	A6
	RTS
L28116	LINK	A6,#-4
	MOVEM.L	D4-D7,-(A7)
	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BNE.S	L28134
	CLR.L	D0
	BRA	L28208
L28134	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BGE.S	L28158
	MOVE.L	8(A6),-(A7)
	JSR	L283A8
	ADDQ.L	#4,A7
	MOVE.L	D0,8(A6)
	MOVEQ	#1,D5
	BRA.S	L2815A
L28158	CLR.W	D5
L2815A	CLR.W	D7
	BRA.S	L28176
L2815E	ADDQ.W	#1,D7
	MOVE.L	#$80000042,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
L28176	MOVE.L	#$80000041,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BGE.S	L2815E
	BRA.S	L281A4
L2818C	SUBQ.W	#1,D7
	MOVE.L	#$80000042,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
L281A4	MOVE.L	#$80000040,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BLT.S	L2818C
	MOVE.L	#$80000059,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	MOVE.L	8(A6),-(A7)
	JSR	L28300
	ADDQ.L	#4,A7
	MOVE.L	D0,-4(A6)
	MOVE.L	-4(A6),D0
	ASL.L	#8,D0
	MOVE.L	D0,-4(A6)
	ADD.W	#$40,D7
	MOVE.W	D7,D0
	AND.W	#$7F,D0
	EXT.L	D0
	OR.L	D0,-4(A6)
	TST.W	D5
	BEQ.S	L28204
	ORI.L	#$80,-4(A6)
L28204	MOVE.L	-4(A6),D0
L28208	TST.L	(A7)+
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
L28212	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L28422
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L28232	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L283E4
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L28250	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L28518
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L28270	LINK	A6,#0
	MOVEM.L	D5-D7,-(A7)
	TST.L	8(A6)
	BGE.S	L2828C
	MOVEQ	#1,D6
	MOVE.L	8(A6),D0
	NEG.L	D0
	MOVE.L	D0,8(A6)
	BRA.S	L2828E
L2828C	CLR.W	D6
L2828E	TST.L	8(A6)
	BNE.S	L28298
	CLR.L	D0
	BRA.S	L282F6
L28298	MOVEQ	#$18,D7
	BRA.S	L282A8
L2829C	MOVE.L	8(A6),D0
	ASR.L	#1,D0
	MOVE.L	D0,8(A6)
	ADDQ.L	#1,D7
L282A8	MOVE.L	8(A6),D0
	AND.L	#$7F000000,D0
	BNE.S	L2829C
	BRA.S	L282C2
L282B6	MOVE.L	8(A6),D0
	ASL.L	#1,D0
	MOVE.L	D0,8(A6)
	SUBQ.L	#1,D7
L282C2	BTST	#7,9(A6)
	BEQ.S	L282B6
	MOVE.L	8(A6),D0
	ASL.L	#8,D0
	MOVE.L	D0,8(A6)
	ADD.L	#$40,D7
	MOVE.L	D7,D0
	AND.L	#$7F,D0
	OR.L	D0,8(A6)
	TST.W	D6
	BEQ.S	L282F2
	ORI.L	#$80,8(A6)
L282F2	MOVE.L	8(A6),D0
L282F6	TST.L	(A7)+
	MOVEM.L	(A7)+,D6-D7
	UNLK	A6
	RTS
L28300	LINK	A6,#0
	MOVEM.L	D4-D7,-(A7)
	MOVE.L	8(A6),D0
	AND.L	#$7F,D0
	ADD.L	#$FFFFFFC0,D0
	MOVE.W	D0,D6
	TST.L	8(A6)
	BEQ.S	L28324
	TST.W	D6
	BGE.S	L28328
L28324	CLR.L	D0
	BRA.S	L2837E
L28328	MOVE.L	8(A6),D0
	AND.L	#$80,D0
	MOVE.W	D0,D5
	CMP.W	#$1F,D6
	BLE.S	L2834E
	TST.W	D5
	BEQ.S	L28346
	MOVE.L	#$80000000,D0
	BRA.S	L2834C
L28346	MOVE.L	#$7FFFFFFF,D0
L2834C	BRA.S	L2837E
L2834E	MOVE.L	8(A6),D7
	ASR.L	#8,D7
	AND.L	#$FFFFFF,D7
	SUB.W	#$18,D6
	BRA.S	L28364
L28360	ASR.L	#1,D7
	ADDQ.W	#1,D6
L28364	TST.W	D6
	BLT.S	L28360
	BRA.S	L2836E
L2836A	ASL.L	#1,D7
	SUBQ.W	#1,D6
L2836E	TST.W	D6
	BGT.S	L2836A
	TST.W	D5
	BEQ.S	L2837C
	MOVE.L	D7,D0
	NEG.L	D0
	MOVE.L	D0,D7
L2837C	MOVE.L	D7,D0
L2837E	TST.L	(A7)+
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
L28388	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L2858A
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L283A8	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	JSR	L28406
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L283C4	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L28410
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L283E4	TST.B	D6
	BPL.S	L283F4
	TST.B	D7
	BPL.S	L283F4
	CMP.B	D7,D6
	BNE.S	L283FA
	CMP.L	D7,D6
	RTS
L283F4	CMP.B	D6,D7
	BNE.S	L283FA
	CMP.L	D6,D7
L283FA	RTS
	TST.B	D7
	RTS
	AND.B	#$7F,D7
	RTS
L28406	TST.B	D7
	BEQ.S	L2840E
	EORI.B	#$80,D7
L2840E	RTS
L28410	MOVE.B	D6,D4
	BEQ.S	L28466
	EORI.B	#$80,D4
	BMI.S	L28484
	MOVE.B	D7,D5
	BMI.S	L2848A
	BNE.S	L2842E
	BRA.S	L28460
L28422	MOVE.B	D6,D4
	BMI.S	L28484
	BEQ.S	L28466
	MOVE.B	D7,D5
	BMI.S	L2848A
	BEQ.S	L28460
L2842E	SUB.B	D4,D5
	BMI.S	L2846A
	MOVE.B	D7,D4
	CMP.B	#$18,D5
	BCC.S	L28466
	MOVE.L	D6,D3
	CLR.B	D3
	LSR.L	D5,D3
	MOVE.B	#$80,D7
	ADD.L	D3,D7
	BCS.S	L2844C
L28448	MOVE.B	D4,D7
	RTS
L2844C	ROXR.L	#1,D7
	ADDQ.B	#1,D4
	BVS.S	L28454
	BCC.S	L28448
L28454	MOVEQ	#-1,D7
	SUBQ.B	#1,D4
	MOVE.B	D4,D7
	ORI.B	#2,CCR
	RTS
L28460	MOVE.L	D6,D7
	MOVE.B	D4,D7
	RTS
L28466	TST.B	D7
	RTS
L2846A	CMP.B	#$E8,D5
	BLE.S	L28460
	NEG.B	D5
	MOVE.L	D6,D3
	CLR.B	D7
	LSR.L	D5,D7
	MOVE.B	#$80,D3
	ADD.L	D3,D7
	BCS.S	L2844C
	MOVE.B	D4,D7
	RTS
L28484	MOVE.B	D7,D5
	BMI.S	L2842E
	BEQ.S	L28460
L2848A	MOVEQ	#-$80,D3
	EOR.B	D3,D5
	SUB.B	D4,D5
	BEQ.S	L284E2
	BMI.S	L284D0
	CMP.B	#$18,D5
	BCC.S	L28466
	MOVE.B	D7,D4
	MOVE.B	D3,D7
	MOVE.L	D6,D3
L284A0	CLR.B	D3
	LSR.L	D5,D3
	SUB.L	D3,D7
	BMI.S	L28448
L284A8	MOVE.B	D4,D5
L284AA	CLR.B	D7
	SUBQ.B	#1,D4
	CMP.L	#$7FFF,D7
	BHI.S	L284BC
	SWAP	D7
	SUB.B	#$10,D4
L284BC	ADD.L	D7,D7
	DBMI	D4,L284BC
	EOR.B	D4,D5
	BMI.S	L284CC
	MOVE.B	D4,D7
	BEQ.S	L284CC
	RTS
L284CC	MOVEQ	#0,D7
	RTS
L284D0	CMP.B	#$E8,D5
	BLE.S	L28460
	NEG.B	D5
	MOVE.L	D7,D3
	MOVE.L	D6,D7
	MOVE.B	#$80,D7
	BRA.S	L284A0
L284E2	MOVE.B	D7,D5
	EXG	D5,D4
	MOVE.B	D6,D7
	SUB.L	D6,D7
	BEQ.S	L284CC
	BPL.S	L284A8
	NEG.L	D7
	MOVE.B	D5,D4
	BRA.S	L284AA
L284F4	DIVU	#0,D7
	TST.L	D6
	BNE.S	L28518
L284FC	OR.L	#$FFFFFF7F,D7
	TST.B	D7
	ORI.B	#2,CCR
L28508	RTS
L2850A	SWAP	D6
	SWAP	D7
L2850E	EOR.B	D6,D7
	BRA.S	L284FC
L28512	BMI.S	L2850E
L28514	MOVEQ	#0,D7
	RTS
L28518	MOVE.B	D6,D5
	BEQ.S	L284F4
	MOVE.L	D7,D4
	BEQ.S	L28508
	MOVEQ	#-$80,D3
	ADD.W	D5,D5
	ADD.W	D4,D4
	EOR.B	D3,D5
	EOR.B	D3,D4
	SUB.B	D5,D4
	BVS.S	L28512
	CLR.B	D7
	SWAP	D7
	SWAP	D6
	CMP.W	D6,D7
	BMI.S	L2853E
	ADDQ.B	#2,D4
	BVS.S	L2850A
	ROR.L	#1,D7
L2853E	SWAP	D7
	MOVE.B	D3,D5
	EOR.W	D5,D4
	LSR.W	#1,D4
	MOVE.L	D7,D3
	DIVU	D6,D3
	MOVE.W	D3,D5
	MULU	D6,D3
	SUB.L	D3,D7
	SWAP	D7
	SWAP	D6
	MOVE.W	D6,D3
	CLR.B	D3
	MULU	D5,D3
	SUB.L	D3,D7
	BCC.S	L28566
	MOVE.L	D6,D3
	CLR.B	D3
	ADD.L	D3,D7
	SUBQ.W	#1,D5
L28566	MOVE.L	D6,D3
	SWAP	D3
	CLR.W	D7
	DIVU	D3,D7
	SWAP	D5
	BMI.S	L2857A
	MOVE.W	D7,D5
	ADD.L	D5,D5
	SUBQ.B	#1,D4
	MOVE.W	D5,D7
L2857A	MOVE.W	D7,D5
	ADD.L	#$80,D5
	MOVE.L	D5,D7
	MOVE.B	D4,D7
	BEQ.S	L28514
	RTS
L2858A	MOVE.B	D7,D5
	BEQ.S	L285E0
	MOVE.B	D6,D4
	BEQ.S	L285FA
	ADD.W	D5,D5
	ADD.W	D4,D4
	MOVEQ	#-$80,D3
	EOR.B	D3,D4
	EOR.B	D3,D5
	ADD.B	D4,D5
	BVS.S	L285FE
	MOVE.B	D3,D4
	EOR.W	D4,D5
	ROR.W	#1,D5
	SWAP	D5
	MOVE.W	D6,D5
	CLR.B	D7
	CLR.B	D5
	MOVE.W	D5,D4
	MULU	D7,D4
	SWAP	D4
	MOVE.L	D7,D3
	SWAP	D3
	MULU	D5,D3
	ADD.L	D3,D4
	SWAP	D6
	MOVE.L	D6,D3
	MULU	D7,D3
	ADD.L	D3,D4
	CLR.W	D4
	ADDX.B	D4,D4
	SWAP	D4
	SWAP	D7
	MULU	D6,D7
	SWAP	D6
	SWAP	D5
	ADD.L	D4,D7
	BPL.S	L285E2
	ADD.L	#$80,D7
	MOVE.B	D5,D7
	BEQ.S	L285FA
L285E0	RTS
L285E2	SUBQ.B	#1,D5
	BVS.S	L285FA
	BCS.S	L285FA
	MOVEQ	#$40,D4
	ADD.L	D4,D7
	ADD.L	D7,D7
	BCC.S	L285F4
	ROXR.L	#1,D7
	ADDQ.B	#1,D5
L285F4	MOVE.B	D5,D7
	BEQ.S	L285FA
	RTS
L285FA	MOVEQ	#0,D7
	RTS
L285FE	BPL.S	L285FA
	EOR.B	D6,D7
	OR.L	#$FFFFFF7F,D7
	TST.B	D7
	ORI.B	#2,CCR
	RTS

L28654	LINK	A6,#0
	MOVEM.L	D5-D7/A5,-(A7)
	MOVEA.L	8(A6),A5
	CLR.W	D7
	CLR.W	D6
	BRA.S	L28668
L28666	ADDQ.L	#1,A5
L28668	MOVE.B	(A5),D0
	EXT.W	D0
	EXT.L	D0
	ADD.L	#0,D0
	MOVEA.L	D0,A0
;	BTST	#5,(A0)
;	BNE.S	L28666
	CMPI.B	#$2B,(A5)
	BNE.S	L28686
	ADDQ.L	#1,A5
	BRA.S	L28690
L28686	CMPI.B	#$2D,(A5)
	BNE.S	L28690
	ADDQ.L	#1,A5
	ADDQ.W	#1,D6
L28690	BRA.S	L286A0
L28692	MULS	#$A,D7
	MOVE.B	(A5)+,D0
	EXT.W	D0
L2869A	ADD.W	D0,D7
L2869C	ADD.W	#$FFD0,D7
L286A0	CMPI.B	#$30,(A5)
L286A4	BLT.S	L286AC
	CMPI.B	#$39,(A5)
	BLE.S	L28692
L286AC	TST.W	D6
	BEQ.S	L286B6
	MOVE.W	D7,D0
	NEG.W	D0
	MOVE.W	D0,D7
L286B6	MOVE.W	D7,D0
	TST.L	(A7)+
	MOVEM.L	(A7)+,D6-D7/A5
	UNLK	A6
	RTS

***********************************************************
*	ROUTINES DIVERSES


******* Change la taille du buffer texte
*	D0= nouvelle
ChgTTexte
	movem.l	d1/a1,-(sp)
	and.l	#$FFFFFFFE,d0
	move.l	d0,-(sp)
	move.l	StTTexte(a5),d0
	beq.s	Ctt1
	move.l	StMini(a5),a1
	jsr	RamFree
	clr.l	StTTexte(a5)
Ctt1	move.l	(sp)+,d0
	beq.s	Ctt2
	move.l	d0,d1
	jsr	RamFast
	beq	Ctt3
	move.l	d1,StTTexte(a5)
	move.l	d0,StMini(a5)
	add.l	d1,d0
	move.l	d0,StHaut(a5)
Ctt2	moveq	#-1,d0
Ctt3	movem.l	(sp)+,d1/a1
	rts


***********************************************************
*	COMPTE LE NOMBRE TOTAL ET AFFICHE DE LIGNES
*	CODE les procedures lockees!
***********************************************************
CptLines
	move.l	a6,-(sp)
	move.l	StBas(a5),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
CpL1	add.w	d2,a0
	add.w	d2,a0
	move.b	(a0),d2
	beq.s	CptLx
	addq.w	#1,d0
	addq.w	#1,d1
	cmp.w	#TkProc-Tk,2(a0)
	bne.s	CpL1
; Saute une procedure COMPILE
	btst	#4,10(a0)
	beq.s	.skip
	move.l	4(a0),d0
	lea	10+2+2(a0,d0.l),a0
	moveq	#0,d2
	bra.s	CpL1
.skip
; Procedure normale
	tst.b	10(a0)
	bpl.s	CpL1
	btst	#6,10(a0)
	beq.s	CpL2
	btst	#5,10(a0)
	bne.s	CpL2
	lea	2(a0),a6
	bsr	ProCode
CpL2	add.w	d2,a0
	add.w	d2,a0
	addq.w	#1,d0
	move.b	(a0),d2
	cmp.w	#TkEndP-Tk,2(a0)
	bne.s	CpL2
	beq.s	CpL1
CptLx	move.w	d0,StNLigne(a5)
	move.w	d1,EdNLigne(a5)
	move.l	(sp)+,a6
	rts
******* Codage / Decodage procedure LOCKEE
*	A6---> "PROC"
ProCode	movem.l	d0-d7/a0-a6,-(sp)
	btst	#4,8(a6)		* Flag COMPILED?
	bne	PaCo
	move.l	2(a6),d0
	lea	10+2+4(a6,d0.l),a2	* A2---> ENDPROC
	move.w	-2(a6),d0
	lsr.w	#8,d0
	lsl.w	#1,d0
	lea	-2(a6,d0.w),a1		* A1---> Ligne suivante
	move.l	2(a6),d5
	rol.l	#8,d5
	move.b	9(a6),d5
	moveq	#1,d4
	move.w	6(a6),d3
	bra.s	PrCo2
PrCo1	eor.w	d5,(a0)+
	add.w	d4,d5
	add.w	d3,d4
	ror.l	#1,d5
	cmp.l	a0,a1
	bne.s	PrCo1
PrCo2	move.l	a1,a0
	move.w	(a0)+,d0
	lsr.w	#8,d0
	lsl.w	#1,d0
	lea	-2(a0,d0.w),a1
	addq.l	#2,a0
	cmp.l	a0,a2
	bne.s	PrCo1
* Change le flag
	bchg	#5,8(a6)
PaCo	movem.l	(sp)+,d0-d7/a0-a6
	rts

******* RAMENE LA TAILLE DE L'INSTRUCTION D0 en D1
TInst:	tst.w	d0
	beq.s	TFin
	cmp.w	#TkLGo-Tk,d0
	bls	TVar
	cmp.w	#TkCh1-Tk,d0	
	beq.s	TCh
	cmp.w	#TkCh2-Tk,d0
	beq.s	TCh
	cmp.w	#TkRem1-Tk,d0
	beq.s	TCh
	cmp.w	#TkRem2-Tk,d0
	beq.s	TCh
	cmp.w	#TkFl-Tk,d0
	bls.s	T4
	cmp.w	#TkExt-Tk,d0
	beq.s	T4
	cmp.w	#TkFor-Tk,d0
	beq.s	T2
	cmp.w	#TkRpt-Tk,d0
	beq.s	T2
	cmp.w	#TkWhl-Tk,d0
	beq.s	T2
	cmp.w	#TkDo-Tk,d0
	beq.s	T2
	cmp.w	#TkExit-Tk,d0
	beq.s	T4 
	cmp.w	#TkExIf-Tk,d0
	beq.s	T4
	cmp.w	#TkIf-Tk,d0
	beq.s	T2
	cmp.w	#TkElse-Tk,d0
	beq.s	T2
	cmp.w	#TkData-Tk,d0
	beq.s	T2
	cmp.w	#TkProc-Tk,d0
	beq.s	T8
	cmp.w	#TkOn-Tk,d0
	beq.s	T4
T0:	moveq	#1,d1
TFin:	rts
T2:	addq.l	#2,a0
	bra.s	T0
T4:	addq.l	#4,a0
	bra.s	T0
T8:	addq.l	#8,a0
	bra.s	T0
TCh:	add.w	(a0)+,a0
	move.w	a0,d1
	btst	#0,d1
	beq.s	T0
	addq.l	#1,a0
	bra.s	T0
TVar:	move.b	2(a0),d1
	ext.w	d1
	lea	4(a0,d1.w),a0
	bra.s	T0

*******	Pointe la ligne suivante, si pas fin programme!
LSuiv:	tst.w	(a0)
	beq.s	LSui1
	addq.l	#2,a0
LSui1:	rts

******* ROUTINE
RNew:	move.w	#-1,DefFlag(a5)
RNew0	jsr	DefRun
	jsr	DefRun2
	jsr	EffAllBanks
	jsr	ClearVar
	EcCalD	Last,0
	EcCalD	Active,EcEdit
	clr.b	T_Actualise(a5)
RNew2	move.l	StHaut(a5),d0
	beq.s	.Bug
	move.l	d0,a0
	clr.w	-(a0)
	move.l	a0,StBas(a5)
.Bug	clr.b	NamePrg(a5)
	clr.w	EdNLigne(a5)
	clr.w	StDLigne(a5)
	clr.w	StFLigne(a5)
	clr.w	StNLigne(a5)
	clr.w	EdXCu(a5)
	clr.w	EdYCu(a5)
	clr.w	EdXPos(a5)
	clr.w	EdYPos(a5)
	clr.w	EdFlag(a5)
	clr.w	EdChange(a5)
	clr.w	StModif(a5)
	clr.l	AdEProc(a5)
* Marks
	moveq	#9,d0
	lea	EdMarks(a5),a0
RNew3	clr.l	(a0)+
	dbra	d0,RNew3
	clr.w	Y1Bloc(a5)
	clr.w	Y2Bloc(a5)
	rts
