;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* RUN / CHRGET
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
	even

***********************************************************
*	RUNDIRECT: interprete la ligne!
***********************************************************
RunDirect:
	tst.l	VarBuf(a5)		* Buffer general deja reserve?
	bne.s	RnDi1
	move.l	#4*1024,d1
	jsr	ResVarBuf
RnDi1	jsr	ResDir
	tst.l	VNmMini(a5)		* Buffer noms deja reserve?
	bne.s	RnDi2
	move.l	VNmMax(a5),d1
	jsr	ResVNom
RnDi2	move.l	EdBufT(a5),DRun(a5)
	move.w	#1,Phase(a5)
	move.w	#1,DirFlag(a5)
	bsr	SsTest
	move.w	VarLong(a5),d0
	cmp.w	TVMax(a5),d0
	bcc	VerVTo
	move.l	EdBufT(a5),a6
* Active la fenetre par defaut
	move.w	ScOn(a5),d1
	beq.s	GChrIn2
	subq.w	#1,d1
	EcCall	Active
GChrIn2	jmp	ChrIn2	
GChrIn	jmp	ChrIn

***********************************************************
*	RUN
***********************************************************
Run:	bsr	TokCur
	move.l	BasSp(a5),sp
	Alea	EdTest,a0
	bsr	EtAff
	move.l	StBas(a5),DRun(a5)
	bsr	EdBlFree
	jsr	ClearVar
	jsr	EffBanks
	bsr	PTest
	bsr	EtPrint
	move.l	StBas(a5),a6
	bra	GChrIn

***********************************************************
*	TESTE LE PROGRAMME
***********************************************************
PrgTest	bsr	TokCur
	move.l	BasSp(a5),sp
	Alea	EdTest,a0
	bsr	EtAff
	move.l	StBas(a5),DRun(a5)
	jsr	ClearVar
	jsr	EffBanks
	bsr	PTest
	jsr	ClearVar
	bsr	CptLines
	EcCalD	Active,EcEdit
	bsr	NewBuf
	moveq	#100,d0
	Alea	EdNoE,a0
	bra	Alert

*****************************************
PTest:	

* RAZ de toutes les variables
	move.l	#8*1024,d1
	jsr	ResVarBuf
	move.l	VNmMax(a5),d1
	jsr	ResVNom
* Init
	clr.w	Phase(a5)
	clr.w	ErrRet(a5)
	clr.w	DirFlag(a5)

ReReVer:clr.w	VarLong(a5)
	move.l	DTablA(a5),a0
	move.l	a0,BaTablA(a5)
	move.l	a0,HoTablA(a5)
	clr.w	(a0)+
	move.l	a0,LabMini(a5)
	cmp.l	LabBas(a5),a0
	bcc	VerVNm
	move.l	DVNmBas(a5),a0
	move.l	a0,VNmHaut(a5)
	clr.w	-(a0)
	move.l	a0,VNmBas(a5)
	bsr	SsTest	

* Fin d'une PHASE: recherche les procedures
	tst.w	Phase(a5)
	bne.s	VerXa
	move.l	HoTablA(a5),a0
	clr.w	(a0)+
	move.l	DTablA(a5),CurTablA(a5)
	move.l	a0,DTablA(a5)
	move.l	VNmBas(a5),DVNmBas(a5)
	move.l	VNmHaut(a5),DVNmHaut(a5)
	move.w	VarLong(a5),GloLong(a5)
	bra.s	VerXb
VerXa:	move.l	DRun(a5),a0		Longueur variable procedure
	move.w	VarLong(a5),6(a0)

VerXb:	bsr	Locale			Nettoie les variables GLOBALES
	move.l	CurTablA(a5),a1
VerXc:	move.l	a1,a0
	move.w	(a0),d0
	beq.s	VerXx
	move.w	14(a0),d1
	lea	16(a0,d1.w),a1
	cmp.w	#TkProc-Tk,d0
	bne.s	VerXc
	move.l	a1,CurTablA(a5)
	move.l	2(a0),d0
	move.l	d0,DRun(a5)
	addq.w	#1,Phase(a5)
	bra	ReReVer
VerXx:

* Init chaines alphanumerique
*	move.l	StMini(a5),a0
*	move.l	a0,LoChaine(a5)
*	move.l	a0,ChVide(a5)
*	move.l	a0,ParamC(a5)
*	clr.w	(a0)+
*	move.l 	a0,HiChaine(a5)

* Libere l'espace pour les variables globales
	move.l	LabBas(a5),a1
	move.w	#-1,-(a1)		* Marque la fin des variables
	clr.l	-(a1)
	move.l	a1,a0
	sub.w	GloLong(a5),a0
	cmp.l	HiChaine(a5),a0
	bcs	VerVNm
	move.l	a0,VarGlo(a5)
	move.l	a0,VarLoc(a5)
	move.l	a0,TabBas(a5)
	bra.s	Rn2Cla
Rn2Cl	clr.l	(a0)+			* Nettoie les variables GLOBALES
	clr.w 	(a0)+
Rn2Cla	cmp.l	a1,a0
	bcs.s	Rn2Cl

* Rend toutes les variables GLOBALES
	bsr	Globale

* Flag: le programme est teste!
	clr.w	StModif(a5)
	rts

******  Sous programme de verification
SsTest:	clr.l	ErrRet(a5)
	clr.w	Passe(a5)
ReVer:	move.l	DRun(a5),a6
	sub.l	a4,a4
	tst.w	DirFlag(a5)
	bne.s	VerD
	tst.w	Phase(a5)
	bne.s	VerDd

VerD:	move.l	a6,VDLigne(a5)
	tst.w	(a6)+
	beq	VerX
* Definition procedures, en debut de ligne
VerDd:	move.l	a6,VerPos(a5)
	move.w	(a6),d0
	cmp.w	#TkProc-Tk,d0
	beq	VerProc
	cmp.w	#TkEndP-Tk,d0
	beq	VerEndP
	cmp.w	#TkData-Tk,d0
	beq	VerData
	cmp.w	#TkDFn-Tk,d0
	beq	VerDfn
	cmp.w	#TkSha-Tk,d0
	beq	VerSha
	cmp.w	#TkGlo-Tk,d0
	beq	VerSha

* Boucle principale: entree d'une INSTRUCTION
VerLoop:move.l	a6,VerPos(a5)
	move.w	(a6)+,d0
	beq	VerD
	cmp.w	#TkRem1-Tk,d0		Une REM?
	beq	VerRem
	cmp.w	#TkRem2-Tk,d0
	beq	VerRem
	cmp.w	#TkSBu-Tk,d0
	beq	VerSBu
	addq.w	#1,VarBufFlg(a5)

	cmp.w	#TkVar-Tk,d0		Une VARIABLE?
	beq	VerVar
	cmp.w	#TkLab-Tk,d0		Un label?
	beq	VerLab
	cmp.w	#TkPro-Tk,d0		Un appel de procedure?
	beq	VerPro
	cmp.w	#TkBcl1-Tk,d0		Un token de boucle/branchement?
	bcs.s	PaBcl
	cmp.w	#TkBcl2-Tk,d0
	bls	VerBcl
PaBcl:	cmp.w	#TkDim-Tk,d0		Un DIM?
	beq	VerDim
	cmp.w	#TkPr-Tk,d0		PRINT?
	beq	VerPr
	cmp.w	#TkLPr-Tk,d0
	beq	VerPr
	cmp.w	#TkHPr-Tk,d0
	beq	VerDPr
	cmp.w	#TkInp-Tk,d0		INPUT?
	beq	VerInp
	cmp.w	#TkLInp-Tk,d0
	beq	VerInp
	cmp.w	#TkDInp-Tk,d0		INPUT#
	beq	VerDInp
	cmp.w	#TkDLInp-Tk,d0
	beq	VerDInp
	cmp.w 	#TkMid1-Tk,d0		MID/LEFT/RIGHT en inst?
	bcs.s	VPaMid
	cmp.w	#TkMid2-Tk,d0
	bcs	VerMid
VPaMid:
	cmp.w	#TkProc-Tk,d0
	beq	VerPDb
	cmp.w	#TkEndP-Tk,d0
	beq	VerPDb
	cmp.w	#TkSha-Tk,d0
	beq	VerShal
	cmp.w	#TkGlo-Tk,d0
	beq	VerShal
	cmp.w	#TkPrc-Tk,d0
	beq	VerPrc
	cmp.w	#TkRLab-Tk,d0
	beq	VerRLab
	cmp.w	#TkDPal-Tk,d0
	beq	VerPal
	cmp.w	#TkPal-Tk,d0
	beq	VerPal
	cmp.w	#TkData-Tk,d0
	beq	VerDaL
	cmp.w	#TkRead-Tk,d0
	beq	VerRead
	cmp.w	#TkRest-Tk,d0
	beq	VerRest
	cmp.w	#TkChan-Tk,d0
	beq	VerChan
	cmp.w	#TkInc-Tk,d0
	beq	VerInc
	cmp.w	#TkDec-Tk,d0
	beq	VerInc
	cmp.w	#TkAd2-Tk,d0
	beq	VerAdd
	cmp.w	#TkAd4-Tk,d0
	beq	VerAdd
	cmp.w	#TkPol-Tk,d0
	beq	VerPo
	cmp.w	#TkPog-Tk,d0
	beq	VerPo
	cmp.w	#TkFld-Tk,d0
	beq	VerFld
	cmp.w	#TkCall-Tk,d0
	beq	VerCall
	cmp.w	#TkDMn-Tk,d0
	bcs.s	PaVMn
	cmp.w	#TkFMn-Tk,d0
	bcs	VerMen
PaVMn:	cmp.w	#TkFade-Tk,d0
	beq	VerFade
	cmp.w	#TkSort-Tk,d0
	beq	VerSort
	cmp.w	#TkSwap-Tk,d0
	beq	VerSwap
	cmp.w	#TkFol-Tk,d0
	beq	VerFol
	cmp.w	#TkDFn-Tk,d0
	beq	VerDal
* Une extension?
	cmp.w	#TkExt-Tk,d0
	bne.s	VerNo
	move.b	(a6)+,d1
	ext.w	d1
	move.l	a6,-(sp)
	tst.b	(a6)+
	move.w	(a6)+,d0
	lsl.w	#2,d1
	lea	AdTokens(a5),a0
	tst.l	0(a0,d1.w)
	beq	VerExN
	move.l	0(a0,d1.w),a0
	bra.s	VerNo1
* Une instruction normale?
VerNo:	pea	FoPoke(pc)
	lea	Tk,a0
VerNo1:	move.l	a0,VerBase(a5)
	bsr	VerDInst
	cmp.b	#"V",d0
	beq	VerVR
	cmp.b	#"I",d0
	bne	VerSynt
	bsr	VerI
	move.l	(sp)+,a0
	move.b	d0,(a0)
* Veut un deux points
VerDP:	move.l	a6,VerPos(a5)
	move.w	(a6)+,d0
	beq	VerD
	cmp.w	#TkDP-Tk,d0
	beq	VerLoop
	cmp.w	#TkElse-Tk,d0
	bne	VerSynt
	subq.l	#2,a6
	bra	VerLoop

******* Fin d'un passe
VerX:	addq.w	#1,Passe(a5)
	cmp.w	#2,Passe(a5)
	bne	ReVer

* Erreur retardee?
	move.l	ErrRet(a5),d0
	beq.s	VerPaE
	move.l	d0,a0
	move.l	ErrRAd(a5),VerPos(a5)
	bra	VerErr
* Fini
VerPaE:	rts

******* MESSAGES D'ERREUR VERIFICATION
* Loops crossing / ERREUR RETARDEE
VerCrs:	move.l	a0,-(sp)
	Alea	VCrs,a0
	bsr	ERetard
	move.l	(sp)+,a0
	rts
ERetard:tst.l	ErrRet(a5)
	bne.s	ERet1
	move.l	a0,ErrRet(a5)
	move.l	VerPos(a5),ErrRAd(a5)
ERet1:	rts
* User function
VerNFn	Alea	VNFn,a0
	bra	VerEr
* Impossible to change buffer
VerNoB	Alea	VNoB,a0
	bra	VerEr
* Datas en debut de ligne
VerDaL:	Alea	VDal,a0
	bra	VerEr
* Extension not present
VerExN:	Alea	VExN,a0
	bra	VerEr
* Too many direct variables
VerVTo:	Alea	VVTo,a0
	bra	VerEr
* Illegal direct mode
VerIlD:	Alea	VIlD,a0
	bra.s	VerEr
* Buffer variable too small
VerVNm:	Alea	VVNm,a0
	bra.s	VerEr
* Goto dans une boucle
VerPaGo:Alea	VPaGo,a0
	bra.s	VerEr
* Structure too long
VerLong:Alea	VLong,a0
	bra.s	VerEr
* Shared
VerShp:	Alea	VShP,a0
	bra.s	VerEr
VerAlG:	Alea	VAlG,a0
	bra.s	VerEr
VerPaG:	Alea	VPaG,a0
	bra.s	VerEr
VerNoPa:Alea	VNoPa,a0
	bra.s	VerEr
VerShal:Alea	VShal,a0
	bra.s	VerEr
* Procedures
VerPDb:	Alea	VPDeb,a0
	bra.s	VerEr
VerPOp:	Alea	VPOp,a0
	bra.s	VerEr
VerPNo:	Alea	VPNo,a0
	bra.s	VerEr
VerPRTy:Alea	VPRTy,a0
	bra.s	VerEr
VerIlP:	Alea	VIlP,a0
	bra.s	VerEr
VerUndP:Alea	VUndP,a0
	bra.s	VerEr
* Else without If
VerElI:	Alea	VElI,a0
VerEr:	bra	VerErr
VerIfE:	Alea	VIfE,a0
	bra	VerErr
VerEIf:	Alea	VEIf,a0
	bra	VerErr
VerElE:	Alea	VElE,a0
	bra	VerErr
VerNoT:	Alea	VNot,a0
	bra	VerErr
* Not enough loop
VerNoL:	Alea	VNoL,a0
	bra	VerErr
* Do/Loop
VerDoL:	Alea	VDoL,a0
	bra	VerErr
VerLDo:	Alea	VLDo,a0
	bra.s	VerErr
* While/Wend
VerWWn:	Alea	VWWn,a0
	bra.s	VerErr
VerWnW:	Alea	VWnW,a0
	bra.s	VerErr
* Repeat/until
VerRUn:	Alea	VRUn,a0
	bra.s	VerErr
VerUnR:	Alea	VUnR,a0
	bra.s	VerErr
* For/Next
VerFoN:	Alea	VFoN,a0
	bra.s	VerErr
VerNFo:	Alea	VNFo,a0
	bra.s	VerErr
* Syntax
VerSynt:Alea	VSynt,a0
	bra.s	VerErr
* Out of mem
VerOut:	Alea	VOut,a0
	bra.s	VerErr
* Out of variable name space
VerNmO:	ALea	VNmO,a0
	bra.s	VerErr
* Non dimensionned
VerNDim	Alea	VNDim,a0
	bra.s	VerErr
* Already dimensionned
VerAlD:	Alea	VAlD,a0
	bra.s	VerErr
* Type mismatch
VerType	Alea	VType,a0
	bra.s	VerErr
* Label not defined
VerUnd:	Alea	VUnd,a0
	bra.s	VerErr
* Label defined twice
VerLb2:	Alea	VLbl2,a0

* Affiche le message d'erreur
VerErr:	move.l	BasSp(a5),sp
	tst.w	RunAct(a5)
	bne	JTtVerErr 
	move.l	a0,-(sp)
	or.b	#%00010001,ActuMask(a5)	* Autorise le mouvement de la fenetre
	tst.w	Direct(a5)		* et le break
	beq.s	RnE0
* Mode direct!
	move.w	d0,d7
	EcCalD	CopOnOff,-1		* Remet le copper!
	EcCalD	First,EcEdit
	EcCalD	Active,EcEdit
	bsr	ReCop
	move.l	(sp)+,a1
	cmp.w	#NbEnd,d7
	beq	EscLoop
	WiCall	Print
	bra	EscLoop
* Mode programme!
RnE0:	bsr	EscToEd			* Retour en mode editeur
	EcCalD	Active,EcEdit		* Reactive l'ecran principal
	move.l	VerPos(a5),a0
	bsr	FindA			* Cherche le numero / adresse
	clr.l	AdEProc(a5)
	move.l	a0,a6
	tst.l	d1
	beq.s	RnE2
	move.l	a0,AdEProc(a5)		* Si procedure fermee--> Stocke!
	move.w	d0,-(sp)
	move.l	d1,-(sp)
	move.l	Buffer(a5),a4
	move.l	VerPos(a5),a3
	bsr	Detok
	move.w	d0,XEProc(a5)
	clr.l	VerPos(a5)
	move.l	(sp)+,a6
	move.w	(sp)+,d0
RnE2	bsr	EdSetY			* Localise en Y
	move.l	Buffer(a5),a4		* Offset de l'erreur
	move.l	VerPos(a5),a3
	bsr	Detok
	bsr	EdSetX
	bsr	NewBuf
	bsr	CptLines
* Affiche le message / retour editeur
	move.l	(sp)+,a0
	move.w	#200,d0
	bra	Alert
JTtVerErr
	jmp	TtVerErr

******* ROUTINE: saute l'instruction courante
Saute:	cmp.w	#TkVar-Tk,d0
	beq.s	So6
	cmp.w	#TkFl-Tk,d0
	bls.s	So6
	cmp.w	#TkGto-Tk,d0
	beq.s	So4
	cmp.w	#TkGsb-Tk,d0
	beq.s	So4
	rts
So4:	lea	2(a6),a6
	rts
* Constantes
So6:	cmp.w	#TkCh1-Tk,d0		Normale: 6
	beq.s	So7
	cmp.w	#TkCh2-Tk,d0
	beq.s	So7
	lea	4(a6),a6
	rts
So7:	move.w	(a6)+,d0		Chaine alphanumerique
	add.w	d0,a6
	btst	#0,d0
	beq.s	So8
	addq.l	#1,a6
So8:	rts

******* REM
VerRem:	tst.w	Direct(a5)
	bne	VerIld
	add.w	(a6)+,a6
	addq.l	#2,a6
	bra	VerD

******* TOKEN PROCEDURE---> change en VARIABLE!
VerPro:	tst.w	Direct(a5)
	bne	VerIlD
	tst.w	Passe(a5)
	bne.s	VPap
	move.w	#TkVar-Tk,-2(a6)
******* VARIABLE EN INSTRUCTION
VerVar:	bsr	VVInst
	bra	VerDP
******* Procedure passe 2
VPap:	bsr	VInP2
	bra	VerDP

******* LABEL
VerLab:	tst.w	Direct(a5)
	bne	VerIlD
	tst.w	Passe(a5)
	bne.s	VerL1
	bsr	StoLab1
	cmp.w	#TkData-Tk,(a6)
	beq	VerData
	bra	VerLoop
VerL1:	move.b	2(a6),d0
	ext.w	d0
	lea	4(a6,d0.w),a6
	cmp.w	#TkData-Tk,(a6)
	beq	VerData
	bra	VerLoop

******* SET BUFFER n
VerSBu	tst.w	Direct(a5)
	bne	VerIlD
	tst.w	Passe(a5)
	bne.s	VSb2
	tst.w	VarBufFlg(a5)
	bne	VerNoB
	cmp.w	#TkEnt-Tk,(a6)+
	bne	VerSynt
	move.l	(a6)+,d1
	mulu	#1024,d1
	cmp.l	VarBufL(a5),d1
	beq	VerDP
* Change la taille / recommence
	jsr	ResVarBuf
	addq.l	#4,sp
	bra	ReReVer
* Passe 2
VSb2	addq.l	#6,a6
	bra	VerDP

******* DIM
VerDim:	cmp.w	#TkVar-Tk,(a6)+		Veut une variable
	bne	VerSynt
	tst.w	Passe(a5)
	bne	VDmB
* Premiere passe
	and.b	#%00001111,3(a6)	RAZ du flag!
	bsr	VarA0
	cmp.w	#TkPar1-Tk,(a0)		TABLEAU?
	bne	VerSynt
	bset	#6,3(a6)		Met le flag tableau!
	move.b	3(a6),d3
	move.l	VNmBas(a5),-(sp)	Stocke la variable
	bsr	StoVar1
	move.l	(sp)+,d1	
	cmp.l	VNmBas(a5),d1		Already dimensionned!
	beq	VerAlD
	bsr	VerTablo		Verifie les params d'un tableau
	move.b	d0,4(a1)		Stocke le nb de dimensions
	bra.s	VDm1
* Deuxieme passe
VDmB:	bsr	VarA0
	bsr	StoVar2
	bsr	VerTablo
* Une autre variable?
VDm1:	cmp.w	#TkVir-Tk,(a6)+
	beq	VerDim
	subq.l	#2,a6
	bra	VerDp

******* SORT
VerSort	move.l	a6,-(sp)
	bsr	VerGV
	move.l	(sp)+,a0
	btst	#6,5(a0)
	bne	VerDP
	bra	VerSynt

******* SWAP
VerSwap	bsr	VerGV
	move.w	d2,-(sp)
	cmp.w	#TkVir-Tk,(a6)+
	bne	VerSynt
	bsr	VerGV
	cmp.w	(sp)+,d2
	beq	VerDP
	bne	VerType

******* Verification DEF FN
VerDFn	addq.w	#1,VarBufFlg(a5)
	addq.l	#2,a6
	cmp.w	#TkVar-Tk,(a6)+
	bne	VerSynt
	tst.w	Passe(a5)
	bne.s	VDfn0
	and.b	#%00001111,3(a6)
	bset	#3,3(a6)
VDfn0	bsr	VarA0
	move.w	d2,-(sp)
	bsr	StoVar
	bsr	VDfnR
	cmp.w	#TkEg-Tk,(a6)+
	bne	VerSynt
	bsr	VerExp
	move.w	(sp)+,d0
	cmp.b	d0,d2
	bne	VerType
	tst.w	(a6)
	beq	VerDP
	bra	VerDal
* Routinnette---> Prend les variables!
VDfnR	cmp.w	#TkPar1-Tk,(a6)
	bne	VDfn2
	addq.l	#2,a6
VDfn1	bsr	VerGV
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VDfn1
	cmp.w	#TkPar2-Tk,-2(a6)
	bne	VerSynt
VDfn2	rts	
	
******* Verification PRINT/LPRINT
VerDPr	bsr	VerExpE
	cmp.w	#TkVir-Tk,(a6)+
	bne	VerSynt
VerPr:	move.w	(a6),d0
	cmp.w	#TkDieze-Tk,d0
	bne.s	VerPr1
	addq.l	#2,a6
	bsr	VerExp
	cmp.b	#"2",d2
	beq	VerType
	cmp.w	#TkVir-Tk,(a6)
	bne 	VerDP
	addq.l	#2,a6
VerPr1:	bsr	Finie
	beq	VerDP
	move.l	a6,VerPos(a5)
	cmp.w	#TkUsing-Tk,(a6)
	bne.s	VerPr2
	addq.l	#2,a6
	bsr	VerExpA
	cmp.w	#TkPVir-Tk,(a6)+
	bne	VerSynt
VerPr2	bsr	VerExp
	move.w	(a6)+,d0
	cmp.w	#TkVir-Tk,d0
	beq.s	VerPr1
	cmp.w	#TkPVir-Tk,d0
	beq.s	VerPr1
	subq.l	#2,a6
	bra	VerDp

******* Verification INPUT / LINE INPUT
VerDInp	bsr	VerExpE
	cmp.w	#TkVir-Tk,(a6)+
	bne	VerSynt
	bra.s	VerIn1
VerInp:	cmp.w	#TkVar-Tk,(a6)
	beq.s	VerIn1
	bsr	VerExp
	cmp.b	#"2",d2
	bne	VerType
	cmp.w	#TkPVir-Tk,(a6)+
	bne	VerSynt
VerIn1:	bsr	VerGV
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VerIn1
	cmp.w	#TkPVir-Tk,-2(a6)
	beq	VerDP
	subq.l	#2,a6
	bra	VerDP

******* Verification PALETTE / DEFAULT PALETTE
VerFa1:	addq.l	#2,a6
VerPal:	clr.w	d0
VPal:	addq.w	#1,d0
	move.w	d0,-(sp)
	bsr	VerExpE
	move.w	(sp)+,d0
	cmp.w	#TkVir-Tk,(a6)
	bne	VerDP
	addq.l	#2,a6
	cmp.w	#32,d0
	bcs.s	VPal
	bra	VerDP
******* Verification FADE
VerFade	bsr	VerExpE
	cmp.w	#TkVir-Tk,d0
	beq.s	VerFa1
	cmp.w	#TkTo-Tk,d0
	bne	VerDP
	addq.l	#2,a6
	bsr	VerExpE
	cmp.w	#TkVir-Tk,(a6)
	bne	VerDp
	addq.l	#2,a6
	bsr	VerExpE
	bra	VerDP

******* Verification MENU$
VerMen:	cmp.w	#TkMenu-Tk,d0
	beq.s	VerMn
	cmp.w	#TkMnD-Tk,d0
	beq	VerMnD
	cmp.w	#TkSMn-Tk,d0
	beq	VerSMn
	cmp.w	#TkMnK-Tk,d0
	beq	VerMnK
	cmp.w	#TkIMn1-Tk,d0
	bcs.s	VMn1
	cmp.w	#TkIMn2-Tk,d0
	bcs.s	VerIMn
VMn1	bra	VerSynt	

* Instruction MENU$(,,)=
VerMn	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	cmp.w	#TkEg-Tk,(a6)+
	bne	VerSynt
* Chaines alphanumeriques
	cmp.w	#TkVir-Tk,(a6)
	beq.s	VerMn1
	bsr	VerExpA
	cmp.w	#TkVir-Tk,(a6)
	bne	VerDP
VerMn1	addq.l	#2,a6
	cmp.w	#TkVir-Tk,(a6)
	beq.s	VerMn2
	bsr	VerExpA
	cmp.w	#TkVir-Tk,(a6)
	bne	VerDP
VerMn2	addq.l	#2,a6
	cmp.w	#TkVir-Tk,(a6)
	beq.s	VerMn3
	bsr	VerExpA
	cmp.w	#TkVir-Tk,(a6)
	bne	VerDP
VerMn3	addq.l	#2,a6
	bsr	VerExpA
	bra	VerDP

* Instructions diverses flags
VerIMn	cmp.w	#TkPar1-Tk,(a6)
	beq.s	VIMn1
	cmp.w	#TkMnCl-Tk,(a6)
	bcc	VerSynt
	bsr	VerExpE
	bra	VerDP
VImn1	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	bra	VerDP
* Menu del
VerMnD	cmp.w	#TkPar1-Tk,(a6)
	bne	VerDP
	bra.s	VIMn1
* Set Menu
VerSmn	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	cmp.w	#TkTo-Tk,(a6)+
	bne	VerSynt
	bsr	VerExpE
	cmp.w	#TkVir-Tk,(a6)+
	bne	VerSynt
	bsr	VerExpE
	bra	VerDP
* On menu 
VerOMn	move.w	(a6)+,d0
	cmp.w	#TkGto-Tk,d0
	beq.s	VOmn1
	cmp.w	#TkGsb-Tk,d0
	beq.s	VOmn1
	cmp.w	#TkPrc-Tk,d0
	beq.s	VOmn2
	bra	VerSynt
VOmn1	bsr	VerLGo
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VOmn1
	subq.l	#2,a6
	bra	VerDP
VOmn2	bsr	VInP
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VOmn2
	subq.l	#2,a6
	bra	VerDP
* Menu key
VerMnK	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	cmp.w	#TkTo-Tk,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	VerEva
	cmp.b	#"2",d2
	beq	VerDP
	cmp.b	#"0",d2
	bne	VerType
	cmp.w	#TkVir-Tk,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	VerExpE
	bra	VerDP

******* Verification FOLLOW
VerFol	bsr	Finie
	beq	VerDP
VFol1	bsr	VerExp
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VFol1
	subq.l	#2,a6
	bra	VerDP

******* Verification DATAS
VerData	addq.w	#1,VarBufFlg(a5)
	addq.l	#2,a6
	move.l	a6,d0
	sub.l	VDLigne(a5),d0
	move.w	d0,(a6)
VerDat1	addq.l	#2,a6
	bsr	VerExp
	cmp.w	#TkVir-Tk,(a6)
	beq.s	VerDat1
	bra	VerDP
******* Verification READ
VerRead:bsr	VerGV
	cmp.w	#TkVir-Tk,(a6)
	bne	VerDP
	addq.l	#2,a6
	bra.s	VerRead
******* Verification RESTORE
VerRest:jsr	Finie
	beq	VerDP
	bsr	VerLGo
	bra	VerDP

******* Verification CHANNEL x TO SPRITE x
VerChan:bsr	VerExpE
	cmp.w	#TkTo-Tk,(a6)+
	bne	VerSynt
	move.w	(a6)+,d0
	cmp.w	#TkScD-Tk,d0
	beq.s	VerCh1
	cmp.w	#TkScO-Tk,d0
	beq.s	VerCh1
	cmp.w	#TkScS-Tk,d0
	beq.s	VerCh1
	cmp.w	#TkBob-Tk,d0
	beq.s	VerCh1
	cmp.w	#TkSpr-Tk,d0
	beq	VerCh1
	cmp.w	#TkRn-Tk,d0
	beq.s	VerCh1
	subq.l	#2,a6			* Channel to ADRESS!
VerCh1:	bsr	VerExpE
	bra	VerDP

******* Verification POLYLINE/POLYGON
VerPo:	cmp.w	#TkTo-Tk,(a6)
	beq.s	VerPo1
VerPo0:	bsr	VerExpE
	cmp.w	#TkVir-Tk,(a6)+	
	bne	VerSynt
	bsr	VerExpE
VerPo1:	cmp.w	#TkTo-Tk,(a6)+
	beq.s	VerPo0
	subq.l	#2,a6
	bra	VerDP

******* Verification VARIABLE RESERVEE en instruction
VerVR:	move.b	(a0)+,d2
	move.w	d2,-(sp)
	bsr	VerF
	move.l	2(sp),a0
	move.b	d0,(a0)
	move.l	a6,VerPos(a5)
	cmp.w	#TkEg-Tk,(a6)+
	bne	VerSynt
	bsr	VerExp
	move.w	(sp)+,d0
	cmp.b	d0,d2
	bne	VerType
	addq.l	#4,sp
	bra	VerDP

******* Verification MID/LEFT/RIGHT en instruction
VerMid:	tst.w	Passe(a5)
	bne.s	.Bug
	move.w	d0,-(sp)
	move.l	a6,-(sp)
	addq.l	#2,a6
	bsr	VerVarA
	cmp.w	#TkVir-Tk,(a6)+
	bne	VerSynt
	move.l	(sp)+,a6
	move.w	(sp)+,d0
.Bug	lea	Tk,a0
	move.l	a0,VerBase(a5)
	bsr	VerDInst
	bsr	VerF
	cmp.w	#TkEg-Tk,(a6)+
	bne	VerSynt
	bsr	VerExp
	cmp.b	#"2",d2
	bne 	VerType
	bra	VerDP

******* Verification INC/DEC
VerInc:	bsr.s	VerVEnt
	bsr	VerGV
	bra	VerDP
VerVEnt	
	move.l	a6,-(sp)
	cmp.w	#TkVar-Tk,(a6)+
	bne	VerSynt
	bsr	VarA0
	tst.b	d0
	bne	VerType
	move.l	(sp)+,a6
	rts
******* Verification ADD
VerAdd:	move.w	#TkAd2-Tk,-2(a6)
	move.l	a6,-(sp)
	bsr.s	VerVEnt
	bsr	VerGV
	cmp.w	#TkVir-Tk,(a6)+
	bne	VerSynt
	bsr	VerExpE
	cmp.w	#TkVir-Tk,(a6)
	bne	VerAdX
* Plus de 2 parametres
	move.l	(sp),a0
	move.w	#TkAd4-Tk,-2(a0)
	addq.l	#2,a6
	bsr	VerExpE
	cmp.w	#TkTo-Tk,(a6)+
	bne	VerAdX
	bsr	VerExpE
* Ca y est!
VerAdX:	addq.l	#4,sp
	bra	VerDP

******* Verification FIELD
VerFld	bsr	VerExpE
	cmp.w	#TkVir-Tk,(a6)
	bne	VerSynt
VFld1	addq.l	#2,a6
	bsr	VerExpE
	cmp.w	#TkAs-Tk,(a6)+
	bne	VerSynt
	bsr	VerVarA
	cmp.w	#TkVir-Tk,(a6)
	beq.s	VFld1
	bra	VerDP

******* CALL
VerCall	bsr	VerExpE
VCl1	cmp.w	#TkVir-Tk,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	VerExp
	bra.s	VCl1

******* Veut une variable seule alphanumerique
VerVarA:bsr	VerGV
	cmp.b	#"2",d2
	bne	VerType
	rts
******* Veut une variable, SEULE
VerGV:	move.l	a6,VerPos(a5)
	cmp.w	#TkVar-Tk,(a6)+
	bne	VerSynt
	tst.w	Passe(a5)
	bne	VGvB
* Premiere passe
	and.b	#%00001111,3(a6)	RAZ du flag!
	bsr	VarA0
	cmp.w	#TkPar1-Tk,(a0)		TABLEAU?
	bne.s	VGv1
	bset	#6,3(a6)		Met le flag tableau!
	move.b	3(a6),d3
	move.l	VNmBas(a5),-(sp)	Ne stocke pas la variable
	bsr	StoVar1
	move.l	(sp)+,d0	
	cmp.l	VNmBas(a5),d0
	bne	VerNDim
	bsr	VerTablo		Verifie les params d'un tableau
	bra.s	VGv2
VGv1:	bsr	StoVar1
VGv2:	rts
* Deuxieme passe
VGvB:	bsr	VarA0
	bsr	StoVar2
	btst	#6,d3
	beq.s	VGv2
	bsr	VerTablo
	bra.s	VGv2

*****************************************************************
*	VERIFICATION PROCEDURES

******* Instruction PROC
VerPrc:	tst.w	Direct(a5)
	bne	VerIlD
	tst.w	Passe(a5)
	beq	VerLoop
	move.l	a6,VerPos(a5)
	cmp.w	#TkPro-Tk,(a6)+
	bne	VerSynt
	bsr	VInP2
	bra	VerDP

******* APPEL PROCEDURE
VerProc:
	addq.w	#1,VarBufFlg(a5)
	tst.w	Direct(a5)
	bne	VerIlD
	tst.w	Phase(a5)
	bne	VPP

* PHASE 0: Stocke et saute le nom et les params
	tst.w	Passe(a5)
	bne	Vp2P
* Va decoder la procedure!
	btst	#6,8(a6)
	beq.s	VPr0
	btst	#5,8(a6)
	beq.s	VPr0
	bsr	ProCode
VPr0:	move.l	HoTablA(a5),a2		Adresse de la procedure
	move.w	d0,(a2)+
	move.l	a6,(a2)+
	move.l	a6,(a2)+
	move.w	a4,(a2)+
	move.w	a4,(a2)+
	move.w	#4,(a2)+
	move.l	a6,-(sp)
	move.l	a2,-(sp)
	
	lea	10(a6),a6
	cmp.w	#TkVar-TK,(a6)+		Stocke dans les labels
	bne	VerSynt
	and.b	#$0F,3(a6)
	or.b	#$80,3(a6)
	bsr	StoLab1
	move.l	4(sp),(a2)		Pointe le DEBUT de la procedure!
	cmp.w	#TkBra1-Tk,(a6)
	bne.s	VP1Pb

VP1Pa:	addq.l	#2,a6
	move.l	a6,VerPos(a5)
	cmp.w	#TkVar-Tk,(a6)+
	bne	VerSynt
	and.b	#$0F,3(a6)
	move.b	2(a6),d0
	ext.w	d0
	lea	4(a6,d0.w),a6
	cmp.w	#TkVir-Tk,(a6)
	beq.s	VP1Pa
	move.l	a6,VerPos(a5)
	cmp.w	#TkBra2-Tk,(a6)+
	bne	VerSynt

Vp1Pb:	move.l	a6,VerPos(a5)
	move.w	(a6),d0
	bne	VerPDb
	addq.l	#2,a6
; Saute une procedure COMPILED
	move.l	4(sp),a0
	btst	#4,8(a0)
	beq.s	VP1Pf
	move.l	2(a0),d0
	lea	12-6(a0,d0.l),a6
	bra.s	VP1Pg
; Cherhe le ENDPROC
VP1Pf:	move.w	(a6),d0
	beq	VerPOp
	move.w	2(a6),d1
	cmp.w	#TkProc-Tk,d1
	beq	VerPOp
	cmp.w	#TkEndP-Tk,d1
	beq.s	VP1Pg
	cmp.w	#TkSha-Tk,d1
	beq.s	Vp1pf0
	cmp.w	#TkGlo-Tk,d1
	bne.s	Vp1pfS
Vp1pf0	movem.l	d0/a6,-(sp)
	addq.l	#2,a6
	bsr	VpSha
	movem.l	(sp)+,d0/a6
VP1pfS	lsr.w	#8,d0
	lsl.w	#1,d0
	add.w	d0,a6
	bra.s	VP1Pf
* Verifie le END PROC
VP1Pg:	addq.l	#2,a6
	move.l	a6,VerPos(a5)
	addq.l	#2,a6
	cmp.w	#TkBra1-Tk,(a6)
	bne.s	VP1Ph
	addq.l	#2,a6
	move.l	VNmBas(a5),-(sp)
	bsr	VerExp
	move.l	(sp)+,VNmBas(a5)
	move.l	a6,VerPos(a5)
	cmp.w	#TkBra2-Tk,(a6)+
	bne	VerSynt
Vp1Ph:	move.l	(sp)+,a2
	move.l	(sp)+,a1
	move.l	a6,(a2)+
	move.l	a6,a0
	sub.l	a1,a0		Poke la distance au END PROC
	lea	-10(a0),a0
	move.l	a0,2(a1)
	bsr	FinTablA
* END PROC seul sur la ligne!
	move.w	(a6)+,d0
	bne	VerPDb
	bra	VerD

* Passe2: saute le tout
Vp2P:	move.l	BaTablA(a5),a2
	move.w	14(a2),d2
	lea	16(a2,d2.w),a2
	move.l	a2,BaTablA(a5)
; Saute la procedure COMPILED
	btst	#4,8(a6)
	beq.s	.skip
	move.l	2(a6),d0
	lea	12-6+2(a6,d0.l),a6	* Pointe le END PROC!
.skip	subq.l	#2,a6	
VP2p1:	move.w	(a6),d0
	move.w	2(a6),d1
	cmp.w	#TkEndP-Tk,d1
	beq.s	VP2p3
	cmp.w	#TkGlo-Tk,d1
	beq.s	Vp2p0
	cmp.w	#TkSha-Tk,d1
	bne.s	Vp2p2
VP2p0	movem.l	d0/a6,-(sp)
	addq.l	#2,a6
	bsr	VpSha
	movem.l	(sp)+,d0/a6
VP2p2	lsr.w	#8,d0
	lsl.w	#1,d0
	add.w	d0,a6
	bra.s	VP2p1
VP2p3:	lsr.w	#8,d0
	lsl.w	#1,d0
	add.w	d0,a6
	bra	VerD


******* PHASE >0: Stocke les variables!
VpP:	
* Procedure COMPILED: saute carrement au dessus!
	btst	#4,8(a6)
	bne	VerX
* Phase 1/2
	lea	12(a6),a6
	move.b	2(a6),d0
	ext.w	d0
	lea	4(a6,d0.w),a6
	cmp.w	#TkBra1-Tk,(a6)
	bne	VerDP
VpP1a:	addq.l	#4,a6
	bsr	StoVar
	cmp.w	#TkVir-Tk,(a6)
	beq.s	VpP1a
	addq.l	#2,a6
	bra	VerDP

******* END PROC [expression]
VerEndP:tst.w	Direct(a5)
	bne	VerIlD
	tst.w	Phase(a5)
	beq	VerPNo
	addq.l	#2,a6
	cmp.w	#TkBra1-Tk,(a6)+
	bne	VerX
	bsr	VerExp
	bra	VerX

*****************************************************************
*	VERIFICATION BRANCHEMENTS

******* Cree la table des adresses
VerBcl:	tst.w	Direct(a5)
	bne	VerIlD
	cmp.w	#TkOn-Tk,d0
	beq	VerOn
	cmp.w	#TkRes-Tk,d0
	beq	VerRes
	cmp.w	#TkRLab-Tk,d0
	beq	VerRLab
	cmp.w	#TkPpp-Tk,d0
	beq	VerPpp
	cmp.w	#TkOMen-Tk,d0
	beq	VerOMn
	cmp.w	#TkEve-Tk,d0
	beq	VerEve
	tst.w	Passe(a5)
	bne	VerBcl2
* Passe 1 : Stocke dans la table
	move.l	HoTablA(a5),a2
	cmp.w	#TkExit-Tk,d0
	beq	Vp1Ext
	cmp.w	#TkExIf-Tk,d0
	beq	Vp1ExI
	cmp.w	#TkGsb-Tk,d0
	beq	VerGsb
	cmp.w	#TkGto-Tk,d0
	beq	Vp1Gto
	cmp.w	#TkOnE-Tk,d0
	beq	Vp1OnE
	move.w	d0,(a2)+
	move.l	a6,(a2)+
	move.l	a6,(a2)+
	move.w	a4,(a2)+
	cmp.w	#TkFor-Tk,d0
	beq	VP1For
	cmp.w	#TkNxt-Tk,d0
	beq	VP1Nxt
	cmp.w	#TkRpt-Tk,d0
	beq	Vp1Rpt
	cmp.w	#TkUnt-Tk,d0
	beq	Vp1Unt
	cmp.w	#TkWhl-Tk,d0
	beq	Vp1Whl
	cmp.w	#TkWnd-Tk,d0
	beq	Vp1Wnd
	cmp.w	#TkDo-Tk,d0
	beq	Vp1Do
	cmp.w	#TkLoo-Tk,d0
	beq	Vp1Loo
	cmp.w	#TkIf-Tk,d0
	beq	Vp1If
	cmp.w	#TkElse-Tk,d0
	beq	Vp1Else
	cmp.w	#TkThen-Tk,d0
	beq	VerSynt
	cmp.w	#TkEndI-Tk,d0
	beq	Vp1EndI
	bra	VerSynt
* Passe 2 : recupere les donnes
VerBcl2:move.l	BaTablA(a5),a2		Adresse actuelle dans la table
	move.w	14(a2),d1
	lea	16(a2,d1.w),a3		Pointe le suivant
	cmp.w	#TkExit-Tk,d0
	beq	Vp2Ext
	cmp.w	#TkExIf-Tk,d0
	beq	Vp2ExI
	cmp.w	#TkGsb-Tk,d0
	beq	VerGsb
	cmp.w	#TkGto-Tk,d0
	beq	Vp2Gto
	cmp.w	#TkOnE-Tk,d0
	beq	Vp2OnE
	move.l	a3,BaTablA(a5)
	cmp.w	#TkFor-Tk,d0
	beq	VP2For
	cmp.w	#TkNxt-Tk,d0
	beq	VP2Nxt
	cmp.w	#TkRpt-Tk,d0
	beq	Vp2Rpt
	cmp.w	#TkUnt-Tk,d0
	beq	Vp2Unt
	cmp.w	#TkWhl-Tk,d0
	beq	Vp2Whl
	cmp.w	#TkWnd-Tk,d0
	beq	Vp2Wnd
	cmp.w	#TkDo-Tk,d0
	beq	Vp2Do
	cmp.w	#TkLoo-Tk,d0
	beq	Vp2Loo
	cmp.w	#TkIf-Tk,d0
	beq	Vp2If
	cmp.w	#TkElse-Tk,d0
	beq	Vp2Else
	cmp.w	#TkEndI-Tk,d0
	beq	Vp2EndI
	bra	VerSynt

******* FOR / Passe 1
VP1For:	add.w	#TForNxt,a4
	clr.w	(a6)+
	move.w	a4,(a2)+
	move.w	#6,(a2)+
	movem.l	a2/a6,-(sp)
	bsr	VerGV
	cmp.b	#"0",d2
	bne	VerType
	movem.l	(sp)+,a2/a3
	move.w	2(a3),(a2)+		Stocke pointeur variable
	clr.l	(a2)+			Place pour ad du next
	bsr	FinTablA		Poke nouvelle adresse
Vp1F0:	move.w	d2,-(sp)		Verifie la suite
	cmp.w	#TkEg-Tk,(a6)+
	bne	VerSynt
	bsr	VerExp
	cmp.b	1(sp),d2
	bne	VerType
	move.l	a6,VerPos(a5)
	cmp.w	#TkTo-Tk,(a6)+
	bne	VerSynt
	bsr	VerExp
	cmp.b	1(sp),d2
	bne	VerType
	cmp.w	#TkStp-Tk,(a6)
	bne.s	VerF1
	addq.l	#2,a6
	bsr	VerExp
	cmp.b	1(sp),d2
	bne	VerType
VerF1:	addq.l	#2,sp
	bra	VerDP
******* FOR / Passe 2 : cherche le NEXT
VP2For:	add.w	#TForNxt,a4
	move.l	a3,a1
	bsr	LoopFind
	beq	VerFoN
	cmp.w	#TkNxt-Tk,d0
	bne	VerFoN
	cmp.w	#-1,16(a0)		Une variable?			
	beq.s	Vp2F3
	move.w	4(a6),d0
	cmp.w	16(a0),d0		Verifie la variable
	bne	VerFoN
Vp2F3:	cmp.w	10(a0),a4		Bon niveau de pile?
	beq.s	Vp2F4
	bsr	VerCrs
Vp2F4:	move.l	2(a2),18(a0)		Marque le NEXT
	move.l	2(a0),18(a2)		Marque le FOR
	bsr	DokDis			Distance au NEXT
	bsr	VerGV			Cherche la variable
	bra	Vp1F0			Termine le FOR
* Doke une distance 
DokDis:	move.l	2(a0),d0
DokD:	sub.l	a6,d0
	subq.l	#2,d0
	cmp.l	#$10000,d0
	bcc	VerLong
	move.w	d0,(a6)+
	rts

******* NEXT / Passe 1
VP1Nxt:	pea	-12(a2)
	sub.w	#TForNxt,a4
	move.w	a4,(a2)+
	move.w	#6,(a2)+
	move.w	#-1,(a2)+		Pas de variable
	bsr	Finie
	beq.s	VP1N1
	subq.l	#2,a2
	movem.l	a2/a6,-(sp)
	bsr	VerGV
	movem.l	(sp)+,a2/a3
	move.w	2(a3),(a2)+		Stocke pointeur variable
VP1N1:	clr.l	(a2)+			Place pour ad du next
	bsr	FinTablA		Poke nouvelle adresse
	bra	Verue
*******	NEXT / Passe 2
VP2Nxt:	sub.w	#TForNxt,a4
	tst.l	18(a2)			NEXT without FOR?
	beq	VerNFo
	cmp.w	#-1,16(a2)		Saute la variable si presente
	beq	VerDp
	bsr	VerGV
	bra	VerDP

******* REPEAT / Passe1
Vp1Rpt:	clr.w	(a6)+
	lea	TRptUnt(a4),a4
	move.w	a4,(a2)+
	clr.w	(a2)+
	bsr	FinTablA
	bra	VerDP
******* REPEAT / Passe2
Vp2Rpt:	lea	TRptUnt(a4),a4
	move.l	a3,a1
	bsr	LoopFind
	beq	VerRUn
	cmp.w	#TkUnt-Tk,d0
	bne	VerRUn
	cmp.w	10(a0),a4		Bon niveau de pile?
	beq.s	Vp2R3
	bsr	VerCrs
Vp2R3:	move.l	2(a2),16(a0)		Marque le UNTIL
	bsr	DokDis			Distance au UNTIL
	bra	VerDp

******* UNTIL / Passe1
Vp1Unt:	pea	-12(a2)
	lea	-TRptUnt(a4),a4
	move.w	a4,(a2)+
	move.w	#4,(a2)+
	clr.l	(a2)+
	bsr	FinTablA
	bsr	VerExp
* Stocke la veritable adresse de fin
Verue:	move.l	a6,a0
	move.w	(a0),d0
	bne.s	Vp1U1
	tst.w	2(a0)
	beq.s	Vp1U2
	addq.l	#4,a0
	bra.s	Vp1U2
Vp1U1:	cmp.w	#TkDP-Tk,d0
	bne	VerSynt
	addq.l	#2,a0
Vp1U2:	move.l	(sp)+,a1
	move.l	a0,6(a1)
	bra	VerDP
******* UNTIL / Passe2
Vp2Unt:	lea	-TRptUnt(a4),a4
	tst.l	16(a2)
	beq	VerRUn
	bsr	VerExp
	bra	VerDP

******* WHILE / Passe1
Vp1Whl:	lea	TWhlWnd(a4),a4
	move.w	a4,(a2)+
	move.w	#4,(a2)+
	clr.l	(a2)+
	bsr	FinTablA
	addq.l	#2,a6
	bsr	VerExp
	bra	VerDP
******* WHILE / Passe2
Vp2Whl:	lea	TWhlWnd(a4),a4
	move.l	a3,a1
	bsr	LoopFind
	beq	VerWWn
	cmp.w	#TkWnd-Tk,d0
	bne	VerWWn
	cmp.w	10(a0),a4		Bon niveau de pile?
	beq.s	Vp2W3
	bsr	VerCrs
Vp2W3:	move.l	2(a2),16(a0)		Marque le WEND
	move.l	6(a0),d0
	move.l	d0,16(a2)		Marque le WHILE
	bsr	DokD			Distance au WEND
	bsr	VerExp
	bra	VerDp

******* WEND / Passe1
Vp1Wnd:	pea	-12(a2)
	lea	-TWhlWnd(a4),a4
	move.w	a4,(a2)+
	move.w	#4,(a2)+
	clr.l	(a2)+
	bsr	FinTablA
	bra	Verue
******* WEND / Passe2
Vp2Wnd:	lea	-TWhlWnd(a4),a4
	tst.l	16(a2)
	beq	VerWnW
	bra	VerDP

******* DO / Passe1
Vp1Do:	lea	TDoLoop(a4),a4
	clr.w	(a6)+
	move.w	a4,(a2)+
	move.w	#4,(a2)+
	clr.l	(a2)+
	bsr	FinTablA
	bra	VerDP
******* DO / Passe2
Vp2Do:	lea	TDoLoop(a4),a4
	move.l	a3,a1
	bsr	LoopFind
	beq	VerDoL
	cmp.w	#TkLoo-Tk,d0
	bne	VerDoL
	cmp.w	10(a0),a4		Bon niveau de pile?
	beq.s	Vp2D
	bsr	VerCrs
Vp2D:	move.l	2(a2),16(a0)		Marque le UNTIL
	move.l	2(a0),16(a2)		Marque le REPEAT
	bsr	DokDis			Distance au LOOP
	bra	VerDp

******* LOOP / Passe1
Vp1Loo:	pea	-12(a2)
	lea	-TDoLoop(a4),a4
	move.w	a4,(a2)+
	move.w	#4,(a2)+
	clr.l	(a2)+
	bsr	FinTablA
	bra	Verue
******* LOOP / Passe2
Vp2Loo:	lea	-TDoLoop(a4),a4
	tst.l	16(a2)
	beq	VerLDo
	bra	VerDP

******* EXIT / Passe1
Vp1Ext:	addq.l	#4,a6
	cmp.w	#TkEnt-Tk,(a6)
	bne	VerDp
	addq.l	#6,a6
	bra	VerDp	
******* EXIT / Passe2
Vp2Ext:	move.l	a6,-(sp)
	move.l	a2,-(sp)
	addq.l	#4,a6
Vp2E:	moveq	#1,d7
	cmp.w	#TkEnt-Tk,(a6)
	bne.s	Vp2Ex1
	move.l	a6,VerPos(a5)
	addq.l	#2,a6
	move.l	(a6)+,d7
	bmi	VerSynt
Vp2Ex1:	move.l	(sp)+,a1
	bsr	Lf1
	beq	VerNoL
	move.l	6(a0),d0
	sub.l	(sp),d0
	subq.l	#4,d0
	cmp.l	#$10000,d0
	bcc	VerSynt
	move.w	a4,d1
	sub.w	12(a0),d1
	move.l	(sp)+,a1
	move.w	d0,(a1)+		Distance a la fin
	move.w	d1,(a1)+		Decalage de la pile
	bra	VerDP

******* EXIT IF / Passe1
Vp1ExI:	addq.l	#4,a6
	bsr	VerExp
	cmp.w	#TkVir-Tk,(a6)
	bne	VerDP
	addq.l	#2,a6
	cmp.w	#TkEnt-Tk,(a6)+
	bne	VerSynt
	addq.l	#4,a6
	bra	VerDP
******* EXIT IF / Passe 2
Vp2ExI:	move.l	a6,-(sp)
	move.l	a2,-(sp)
	addq.l	#4,a6
	bsr	VerExp
	moveq	#1,d7
	cmp.w	#TkVir-tk,(a6)
	bne.s	Vp2E
	addq.l	#2,a6
	bra.s	Vp2E

******* IF / Passe1
Vp1If:	move.w	a4,(a2)+
	move.w	#2,(a2)+
	pea	(a2)
	move.w	#1,(a2)+
	bsr	FinTablA
	addq.l	#2,a6
	bsr	VerExp
	move.l	(sp)+,a2
	cmp.w	#TkThen-Tk,(a6)
	bne	VerDp
	clr.w	(a2)
	addq.l	#2,a6
	cmp.w	#TkLGo-Tk,(a6)
	bne	VerLoop
	bsr	SoLGo
	bra	VerDP
******* IF / Passe2
Vp2If:  lea	2(a6),a0
	tst.w	16(a2)
	bne.s	VIfB
* IF THEN... sur la meme ligne= ANCIENNE MANIERE
	moveq	#1,d7
	move.w	(a0)+,d0
	beq	VerSynt
VIfA0:	bsr	TInst
	cmp.w	#TkIf-Tk,d0
	beq.s	VifA2
	cmp.w	#TkElse-Tk,d0
	beq.s	VIfA3
VIfA1:	move.w	(a0)+,d0
	bne.s	VIfA0
	subq.l	#2,a0
	beq.s	VIfA4
VIfA2:	addq.w	#1,d7
	bra.s	VIfA1
VIfA3:	subq.w	#1,d7
	bne.s	VIfA1
* Poke la distance au ELSE dans le IF
VIfA4:	move.l	a0,d1
	sub.l	a6,d1
	subq.l	#2,d1
	cmp.l	#$10000,d1
	bcc	VerSynt
	move.w	d1,(a6)+
	tst.w	d0
	beq.s	VifA5
	move.l	a0,d0
	subq.l	#2,d0
	move.l	a3,a1
	bsr	FnTablA
	beq.s	VIfA5
	move.l	a6,16(a0)	Marque le ELSE si present
VIfA5:	bsr	VerExp
	addq.w	#2,a6		Saute le THEN
	cmp.w	#TkLGo-Tk,(a6)
	bne	VerLoop
	bsr	SoLGo
	move.l	(a2),d6		Adresse de destination
	bsr	VerGto
	bra	VerDP
* IF structure
VIfB:	
VIfB0:	move.w	(a0)+,d0
	move.l	a0,a1
	bsr	TInst
	beq.s	VIfBf
	cmp.w	#TkThen-Tk,d0
	beq	VerNoT
	cmp.w	#TkIf-Tk,d0
	bne.s	VIfB2
		clr.w	d7		Saute les boucles imbriquees
VIfBa:		addq.w	#1,d7
VIfBb:		move.w	(a0)+,d0
		bsr	TInst
		beq.s	VIfBc
		cmp.w	#TkThen-Tk,d0
		beq	VerNoT
		cmp.w	#TkIf-Tk,d0
		beq.s	VIfBa
		cmp.w	#TkEndI-Tk,d0
		bne.s	VIfBb
		subq.w	#1,d7
		bne.s	VIfBb
		bra.s	VIfB0
VIfBc:		bsr	LSuiv
		bne.s	VIfBb
		bra	VerIfE
VIfB2:	cmp.w	#TkEndI-Tk,d0
	beq.s	VIfB3
	cmp.w	#TkElse-Tk,d0
	beq.s	VIfB3
	bra.s	VIfB0
VIfBf:	bsr	LSuiv
	beq	VerElE
	bra.s	VIfB0
VIfB3:	sub.l	a6,a0
	subq.l	#2,a0
	cmp.l	#$10000,a0
	bcc	VerSynt
	move.w	a0,(a6)+
	move.l	a1,d0
	move.l	a3,a1
	bsr	FnTablA
	beq	VerIfE
	move.l	a6,16(a0)	Marque le ELSE/ENDIF si present
	move.w	#1,20(a0)	BUGBUGBUGBUGBUGBUGBUGBUGBUGBUG
	bsr	VerExp
	bra	VerDP

******* ELSE / Passe1
Vp1Else:move.w	a4,(a2)+
	move.w	#6,(a2)+
	clr.l	(a2)+
	clr.w	(a2)+
	bsr	FinTablA
	clr.w	(a6)+
	cmp.w	#TkLGo-Tk,(a6)
	bne	VerLoop
	bsr	SoLGo
	bra	VerDP
******* ELSE / Passe2
Vp2Else:tst.l	16(a2)
	beq	VerElI
	lea	2(a6),a0
	tst.w	20(a2)
	bne.s	VElB
* NON STRUCTURE: cherche la fin de la ligne
	tst.w	(a0)
	beq	VerSynt
VElA0:	move.w	(a0)+,d0
	bsr	TInst
	bne.s	VElA0
	bsr	LSuiv
	sub.l	a6,a0
	subq.l	#2,a0
	cmp.l	#$10000,a0
	bcc	VerLong
	move.w	a0,(a6)+
	cmp.w	#TkLGo-Tk,(a6)
	bne	VerLoop
	bsr	SoLGo
	move.l	(a2),d6		Adresse de destination
	bsr	VerGto
	bra	VerDP
* STRUCTURE: cherche le ENDIF correspondant
VElB:	moveq	#1,d7
VElB0:	move.w	(a0)+,d0
	bsr	TInst
	beq.s	VElB1
	cmp.w	#TkIf-Tk,d0
	beq.s	VElB2
	cmp.w	#TkEndI-Tk,d0
	beq.s	VElB3
	cmp.w	#TkThen-Tk,d0	NO THEN in structured tests!
	beq	VerNoT
	bra.s	VElB0
VElB1:	bsr	LSuiv
	bne.s	VElB0
	bra	VerElE
VElB2:	addq.w	#1,d7
	bra.s	VElB0
VElB3:	subq.w	#1,d7
	bne.s	VElB0
	move.l	a0,d0
	sub.l	a6,a0
	subq.l	#2,a0
	cmp.l	#$10000,a0
	bcc	VerLong
	move.w	a0,(a6)+
	move.l	a3,a1
	bsr	FnTablA
	beq	VerElE
	move.l	a6,16(a0)	Marque le ENDIF
	bra	VerLoop

******* ENDIF / Passe1
Vp1EndI:move.w	a4,(a2)+
	move.w	#6,(a2)+
	clr.l	(a2)+
	clr.w	(a2)+
	bsr	FinTablA
	bra	VerDP
******* ENDIF / Passe2
Vp2EndI:tst.l	16(a2)
	beq	VerEIf
	bra	VerDP
	
******* GOSUB 
VerGsb:	bsr	VerLGo
	bra	VerDP
	
******* GOTO / Passe1
Vp1Gto:	bsr	VerLGo
	bra	VerDP
******* GOTO / Passe2
Vp2Gto:	bsr	VerLGo
	beq	VerDP
	move.l	(a2),d6		Adresse de destination
	bsr	VerGto
	bra	VerDP

******* Verification du saut: PAS A L'INTERIEUR D'UNE BOUCLE!
VerGto:	cmp.l	a6,d6
	bcs	VGob
* Saut en avant!
	move.l	a6,a0
VGoa1:	bsr	VGo
	cmp.l	d6,a0
	bcc.s	VGoOk
	tst.w	d1
	bmi.s	VGoa1
	beq.s	VGoa1
	moveq	#0,d7
VGoa2:	addq.w	#1,d7
VGoa3:	bsr	VGo
	beq.s	VGoa3
	bpl.s	VGoa2
	subq.w	#1,d7
	bne.s	VGoa3
	bra.s	VGoa1
* Saut en arriere
VGob:	move.l	d6,a0
VGob1:	bsr	VGo
	cmp.l	a6,a0
	bcc.s	VGoOk
	tst.w	d1
	beq.s	VGob1
	bmi	VerPaGo
	moveq	#0,d7
VGob2:	addq.w	#1,d7
VGob3:	bsr	VGo
	cmp.l	a6,a0
	bcc.s	VGoOk
	tst.w	d1
	beq.s	VGob3
	bpl.s	VGob2
	subq.w	#1,d7
	bne.s	VGob3
	bra.s	VGob1
VGoOk:	rts
******* Verifie
VGo:	move.w	(a0)+,d0
	bsr	TInst
	bne.s	VGo1
	bsr	LSuiv
	beq	VerPaGo
VGo1:	cmp.w	#TkFor-Tk,d0
	beq.s	VGo3
	cmp.w	#TkWhl-Tk,d0
	beq.s	VGo3
	cmp.w	#TkRpt-Tk,d0
	beq.s	VGo3
	cmp.w	#TkDo-Tk,d0
	beq.s	VGo3
	cmp.w	#TkNxt-Tk,d0
	beq.s	VGo4
	cmp.w	#TkUnt-Tk,d0
	beq.s	VGo4
	cmp.w	#TkWnd-Tk,d0
	beq.s	VGo4
	cmp.w	#TkLoo-Tk,d0
	beq.s	VGo4
	moveq	#0,d1
	rts
VGo3:	moveq	#1,d1
	rts
VGo4:	moveq	#-1,d1
	rts

******* ON x GOTO/GOSUB label,label
VerOn:	move.l	a6,-(sp)
	clr.l	(a6)+
	bsr	VerExp
	cmp.b	#"0",d2
	bne	VerType
	move.l	a6,VerPos(a5)
	move.w	(a6)+,-(sp)
	cmp.w	#TkGto-Tk,(sp)
	beq.s	VerO1
	cmp.w	#TkGsb-Tk,(sp)
	beq.s	VerO1
	cmp.w	#TkPrc-Tk,(sp)
	bne	VerSynt
* PROC
	clr.w	-(sp)
VerO0	addq.w	#1,(sp)
	bsr	VInP
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VerO0
	bra.s	VerO4
* GOTO / GOSUB
VerO1:	clr.w	-(sp)
VerO2:	addq.w	#1,(sp)
	bsr	VerLGo
	beq.s	VerO3
	tst.w	Passe(a5)
	beq.s	VerO3
	cmp.w	#TkGto-Tk,2(sp)
	bne.s	VerO3
	move.l	(a2),d6
	bsr	VerGto
VerO3:	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VerO2
VerO4	subq.l	#2,a6
	move.w	(sp)+,d0
	tst.w	(sp)+
	move.l	(sp)+,a0
	move.w	d0,2(a0)
	move.l	a6,d0
	sub.l	a0,d0
	subq.l	#4,d0
	move.w	d0,(a0)
	bra	VerDp

******* ON ERROR / ON ERROR GOTO / ON ERROR PROC xxxx / ON ERROR GOTO 0
Vp1OnE:	cmp.w	#TkPrc-Tk,(a6)
	beq	VerLoop
	cmp.w	#TkGto-Tk,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	VerLGo
	bra	VerDP
Vp2OnE: cmp.w	#TkPrc-Tk,(a6)
	beq	VerLoop
	cmp.w	#TkGto-Tk,(a6)
	bne	VerDP
	addq.l	#2,a6
	bra	Vp2Gto
******* RESUME
VerRes:	bsr	Finie
	beq	VerDP
	tst.w	Passe(a5)
	beq	Vp1Gto
	bne	Vp2Gto	
******* RESUME LABEL
VerRLab:bsr	Finie
	beq	VerDP
	bsr	VerLGo
	bra	VerDP

******* POP PROC
VerPpp:	tst.w	Phase(a5)
	bne	VerDP
	bra	VerShP

******* EVERY n PROC / GOSUB
VerEve:	bsr	VerExpE
	move.w	(a6)+,d0
	cmp.w	#TkGsb-Tk,d0
	beq.s	VEv1
	cmp.w	#TkPrc-Tk,d0
	bne	VerSynt
* Nom de procedure (sans label!!!)
	bsr	VInP
	bra	VerDP
* Gosub
VEv1:	bsr	VerLGo
	bra	VerDP

******* Saute un LABEL GOTO
SoLGo:	move.l	a6,VerPos(a5)
	cmp.w	#TkLGo-Tk,(a6)+
	bne	VerSynt
	tst.w	Passe(a5)
	bne.s	SolG1
* Premiere passe: saute simplement
	move.b	2(a6),d0
	ext.w	d0
	lea	4(a6,d0.w),a6
	rts
* Deuxieme passe: explore la table
SolG1:	bsr	StoLab2
	beq	VerUnd
	rts

******* Trouve une adresse dans la table
FnTablA:move.l	a1,a0
	move.w	(a0),d1
	beq.s	FnTx
	move.w	14(a0),d1
	lea	16(a0,d1.w),a1
	cmp.l	2(a0),d0
	bne.s	FnTablA
	moveq	#1,d1
FnTX:	rts

******* Fin de pokage dans la table
FinTablA:
	move.l	a2,HoTablA(a5)
	clr.w	(a2)+
	cmp.l	LabBas(a5),a2
	bcc	VerVNm
	move.l	a2,LabMini(a5)
	rts

******* Compte le boucles ---> ZERO
LoopFind:
	moveq	#1,d7
Lf1:	move.l	a1,a0
	move.w	(a0),d0
	beq.s	LfX
	move.w	14(a0),d1
	lea	16(a0,d1.w),a1
	cmp.w	#TkFor-Tk,d0
	beq.s	Lf2
	cmp.w	#TkWhl-Tk,d0
	beq.s	Lf2
	cmp.w	#TkRpt-Tk,d0
	beq.s	Lf2
	cmp.w	#TkDo-Tk,d0
	beq.s	Lf2
	cmp.w	#TkNxt-Tk,d0
	beq.s	Lf3
	cmp.w	#TkUnt-Tk,d0
	beq.s	Lf3
	cmp.w	#TkWnd-Tk,d0
	beq.s	Lf3
	cmp.w	#TkLoo-Tk,d0
	beq.s	Lf3
	bra.s	Lf1
Lf2:	addq.w	#1,d7
	bra.s	Lf1
Lf3:	subq.w	#1,d7
	bne.s	Lf1
	move.w	(a0),d0
LfX:	rts

*****************************************************************

*****************************************************************
*	VERIFICATION EXPRESSIONS

******* Veut une expression alphanumerique
VerExpA	bsr	VerExp
	cmp.b	#"2",d2
	bne	VerType
	rts
******* Veut une expression entiere
VerExpE	bsr	VerExp
	cmp.b	#"0",d2
	bne	VerType
	rts
******* Evaluation / Test parentheses
VerExp:	move.l	a6,VerPos(a5)
	bsr	VerEva
	tst.w	Parenth(a5)
	bne	VerSynt
	rts

******* Evaluation / Verification
VerEva:	clr.w	Parenth(a5)
* Premier operande
VerEv:	move.l	VerBase(a5),-(sp)
	bsr	VerOpe	
	move.l	(sp)+,VerBase(a5)
VerEv1:	move.w	(a6),d0
	beq	VerEvF
	cmp.w	#TkDP-Tk,d0
	beq	VerEvF
	cmp.w	#TkVir-Tk,d0
	beq	VerEvF
	cmp.w	#TkPVir-Tk,d0
	beq	VerEvF
	cmp.w	#TkTo-Tk,d0
	beq	VerEvF
	cmp.w	#TkAs-Tk,d0
	beq	VerEvF
	cmp.w	#TkStp-Tk,d0
	beq	VerEvF
	cmp.w	#TkThen-Tk,d0
	beq	VerEvF
	cmp.w	#TkElse-Tk,d0
	beq	VerEvF
	cmp.w	#TkBra2-Tk,d0
	beq	VerEvF
	cmp.w	#TkGto-Tk,d0
	beq	VerEvF
	cmp.w	#TkGsb-Tk,d0
	beq	VerEvF
	cmp.w	#TkPrc-Tk,d0
	beq	VerEvF
	cmp.w	#TkPar2-Tk,d0
	beq	VerEvP
	addq.l	#2,a6
* Operateur
	cmp.w	#TkPow-Tk,d0	* Si puissance---> ouvre la librarie!
	bne.s	VerEv4
	bsr	OpMath
VerEv4	lea	Tk,a0
	bsr	VerDInst
	cmp.b	#"O",d0
	bne	VerSynt
	move.b	(a0)+,d0
	move.b	(a0)+,d1	* Type ramene par l'operateur
	cmp.b	#"2",d1
	bne.s	VerEv3
	move.b	d2,d1
VerEv3	cmp.b	#"0",d0		* Operateur CHIFFRE seulement?
	bne.s	VerEv0
	cmp.b	#"2",d2		* Oui: est-ce un chiffre?
	beq	VerType
* Deuxieme operande
VerEv0:	move.w	d1,-(sp)
	move.w	d2,-(sp)
	move.l	VerBase(a5),-(sp)
	bsr	VerOpe
	move.w	d2,d1
	move.l	(sp)+,VerBase(a5)
	move.w	(sp)+,d3
	move.w	(sp)+,d2
	cmp.b	#"2",d1			* Type mismatch?
	beq.s	VerEv2
	cmp.b	#"2",d3
	bne	VerEv1
	bra	VerType
VerEv2:	cmp.b	#"2",d3
	beq	VerEv1
	bra	VerType
* Fin parenthese
VerEvP:	subq.w	#1,Parenth(a5)
	addq.l	#2,a6
VerEvF:	rts
FoPoke:	dc.w 	0

******* Operande / Verification
VerOpe:	clr.w	-(sp)			* Pas de signe devant
VerOp0:	move.w	(a6)+,d0
	bsr	FinieB
	beq.s	VerVif
	cmp.w	#TkPar2-Tk,d0
	beq.s	VerVif
	cmp.w	#TkTo-Tk,d0
	beq.s	VerVif
	cmp.w	#TkVir-Tk,d0
	beq.s	VerViv
	cmp.w	#TkPar1-Tk,d0		* Ouverture d'une parenthese
	beq	VerOpP
******* Signe moins devant?
	cmp.w	#TkM-Tk,d0		* Signe moins devant?
	bne.s	VerOp1
	tst.w	(sp)
	bne	VerSynt
	addq.w	#1,(sp)
	bra.s	VerOp0
******* Fin: une virgule avant---> ommis!
VerVif:	cmp.w	#TkVir-Tk,-4(a6)
	bne	VerSynt
******* Virgule: parametre ommis
VerViv:	subq.l	#2,a6
	moveq	#"0",d2
	tst.w	(sp)+
	bne	VerSynt
	rts
******* Autres...
VerOp1:	cmp.w	#TkExt-Tk,d0		* Token d'extension?
	bne.s	VerOpX
	move.b	(a6)+,d1
	move.l	a6,a1
	tst.b	(a6)+
	move.w	(a6)+,d0
	ext.w	d1
	lsl.w	#2,d1
	lea	AdTokens(a5),a0
	tst.l	0(a0,d1.w)
	beq	VerExN
	move.l	0(a0,d1.w),a0
	bra.s	VerOpX1
VerOpX:	cmp.w	#TkVar-Tk,d0		* Variable?
	beq	VerOpV
	cmp.w	#TkVPtr-Tk,d0		* Varptr?
	beq	VerVPtr
	cmp.w	#TkFn-Tk,d0
	beq	VerFn
	cmp.w	#TkNot-Tk,d0
	beq	VerNNot
	cmp.w	#TkXMn-Tk,d0
	beq	VerFMn
	cmp.w	#TkYMn-Tk,d0
	beq	VerFMn
	cmp.w	#TkFnd1-Tk,d0
	beq	VerFind
	cmp.w	#TkMin-Tk,d0
	beq	VerMM
	cmp.w	#TkMax-Tk,d0
	beq	VerMm
	cmp.w	#TkMat1-Tk,d0		* Si fonction math
	bcs.s	VerOpM
	cmp.w	#TkMat2-Tk,d0
	bcc.s	VerOpM
	bsr	OpMath			* Ouvre la librairie!
VerOpM	lea	FoPoke(pc),a1
******* FONCTION / VARIABLE RESERVEE
	lea	Tk,a0
VerOpX1	move.l	a0,VerBase(a5)
	bsr	VerDInst
	cmp.b	#"C",d0
	beq.s	VerOp3
	move.l	a1,-(sp)
	move.w	d0,d2
	cmp.b	#"0",d2
	beq.s	VerOp2
	cmp.b	#"1",d2
	beq.s	VerOp2
	cmp.b	#"2",d2
	beq.s	VerOp2
	cmp.b	#"I",d2
	beq.s	VOpI
	cmp.b	#"V",d2			* Variable reservee
	bne	VerSynt
	move.b	(a0)+,d2
VerOp2	bsr	VerF			* Va verifier
	move.l	(sp)+,a0
	move.b	d0,(a0)			* Nb parametre (extensions)
	bra.s	VerOp4
******* CONSTANTE
VerOp3:	move.b	(a0)+,d2
	cmp.b	#"2",d2
	beq.s	VerOp3a
	addq.l	#4,a6			* Saute la constante
	bra.s	VerOp4
VerOp3a:move.w	(a6)+,d0		* Saute la chaine
	lea	0(a6,d0.w),a6
	btst	#0,d0
	beq.s	VerOp4
	addq.l	#1,a6
VerOp4:	cmp.b	#"1",d2
	bne.s	VerOp5
	moveq	#"0",d2
VerOp5:	addq.l	#2,sp
	rts
******* Essaie de trouver une fonction apres!
VOpI:	move.b	(a0)+,d2
	bpl.s	VOpI
	cmp.b	#-1,d2
	beq	VerSynt
* Saute la prochaine
	move.w	a0,d0
	btst	#0,d0
	beq.s	VOpi1
	addq.l	#1,a0
VOpi1:	move.l	a0,d1
	lea	4(a0),a0
VOpi2:	tst.b	(a0)+
	bpl.s	VOpi2
	move.b	(a0)+,d2
	cmp.b	#"I",d2
	beq.s	VOpI
	cmp.b	#"0",d2
	beq.s	VOpi3
	cmp.b	#"1",d2
	beq.s	VOpi3
	cmp.b	#"2",d2
	bne	VerSynt
* Trouve change le token!
VOpi3:	sub.l	VerBase(a5),d1
	move.w	d1,-2(a6)
	bra	VerOp2

* Ouverture parenthese
VerOpP:	addq.w	#1,Parenth(a5)
	bsr	VerEv
	addq.l	#2,sp
	rts

******* VARIABLE EN FONCTION
VerOpV:	bsr	VVFonc
	addq.l	#2,sp
	rts

******* =FIND(a$(n),b)
VerFind	move.l	a6,-(sp)
	lea	Tk,a0
	move.l	a0,VerBase(a5)
	bsr	VerDInst
	bsr	VerF
	move.l	(sp)+,a0
	btst	#6,5+2(a0)
	bne	VerOp4
	bra	VerSynt	
******* =MIN / MAX
VerMM	cmp.w	#TkPar1-Tk,(a6)+
	bne	VerSynt
	move.w	Parenth(a5),-(sp)
	bsr	VerExp
	move.w	d2,-(sp)
	cmp.w	#TkVir-Tk,(a6)+
	bne	VerSynt
	bsr	VerEva
	cmp.w	#-1,Parenth(a5)
	bne	VerSynt
	move.w	(sp)+,d1
	cmp.b	d1,d2
	bne	VerType
	move.w	(sp)+,Parenth(a5)
	addq.l	#2,sp
	rts
******* Ouvre la librairie math
OpMath:	tst.l	MathBase(a5)
	bne.s	OpMx
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	$4,a6
	moveq	#0,d0
	lea	MathName,a1
	jsr	OpenLib(a6)
	move.l	d0,MathBase(a5)
	movem.l	(sp)+,d0-d7/a0-a6
OpMx:	rts
	
******* NOT
VerNNot	move.w	Parenth(a5),-(sp)
	bsr	VerEva
	tst.w	Parenth(a5)
	bne	VerSynt
	move.w	(sp)+,Parenth(a5)
	cmp.b	#"2",d2
	beq	VerType
	addq.l	#2,sp
	rts
******* VARPTR(var)
VerVPtr:cmp.w	#TkPar1-Tk,(a6)+
	bne	VerSynt
	cmp.w	#TkVar-Tk,(a6)+
	bne	VerSynt
	bsr	VVFonc
	cmp.w	#TkPar2-Tk,(a6)+
	bne	VerSynt
	moveq	#"0",d2
	addq.l	#2,sp
	rts
******* = Fn AKJDKJS(k,d,d,d)
VerFn	cmp.w	#TkVar-Tk,(a6)+
	bne	VerSynt
	and.b	#%00001111,3(a6)
	bset	#3,3(a6)
	bsr	VarA0
	move.w	d2,-(sp)
	move.l	VNmBas(a5),-(sp)
	bsr	StoVar
	move.l	(sp)+,d0
	cmp.l	VNmBas(a5),d0
	bne	VerNFn
* Verifie les parametres
	cmp.w	#TkPar1-Tk,(a6)
	bne.s	VerFn3
	addq.l	#2,a6
	move.w	Parenth(a5),-(sp)
VerFn1	bsr	VerEva
	tst.w	Parenth(a5)
	bne.s	VerFn2
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VerFn1
	bne	VerSynt
VerFn2	cmp.w	#-1,Parenth(a5)
	bne	VerSynt
	move.w	(sp)+,Parenth(a5)
* Ok!
VerFn3	move.w	(sp)+,d2
	addq.w	#2,sp
	rts
******* =XY MENU(,,) / =MENU(,,)
VerFMn	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	moveq	#"0",d2
	addq.l	#2,sp
	rts

******* Verification INSTRUCTION!
VerI:	move.w	d2,-(sp)
	pea	-2(a6)			* Adresse de l'instruction
	move.l	a0,-(sp)
	clr.w	-(sp)			* Position dans definition
	clr.l	-(sp)			* Chaine SOURCE
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.b	#-1,(sp)
	move.w	(a6),d0			* Fin ligne?
	bsr	FinieB
	beq	VerI6

* Compte les parametres
VerI2:	bsr	VerEva
	move.w	20(sp),d0
	move.b	d2,0(sp,d0.w)
	move.b	#-1,1(sp,d0.w)
	addq.w	#1,d0
	cmp.w	#19,d0
	bcs.s	VerI3
	subq.w	#1,d0
VerI3:	move.w	d0,20(sp)
	tst.w	Parenth(a5)
	bne	VerSynt
	moveq	#",",d2
	move.w	(a6),d1
	cmp.w	#TkVir-Tk,d1
	beq.s	VerI4
	moveq	#"t",d2
	cmp.w	#TkTo-Tk,d1
	bne	VerI6
VerI4:	addq.l	#2,a6
	move.b	d2,0(sp,d0.w)
	move.b	#-1,1(sp,d0.w)
	addq.w	#1,d0
	cmp.w	#19,d0
	bcs.s	VerI5
	subq.w	#1,d0
VerI5:	move.w	d0,20(sp)
 	bra.s	VerI2
* Compare la chaine cree aux parametres
VerI6:	bsr	VerC
	
* C'est bon: depile
	move.w	20(sp),d0		* Nombre de parametres!
	addq.w	#1,d0
	lsr.w	#1,d0
	lea	30(sp),sp
	move.w	(sp)+,d2
	rts

******* Verification FONCTION!
VerF:	move.w	d2,-(sp)
	move.w	Parenth(a5),-(sp)
	pea	-2(a6)			* Adresse de l'instruction
	move.l	a0,-(sp)		* Adresse definition
	clr.w	-(sp)			* Position dans definition
	clr.l	-(sp)			* Chaine SOURCE
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.b	#-1,(sp)
	cmp.w	#TkPar1-Tk,(a6)
	bne	Verf6
	addq.l	#2,a6
	cmp.w	#TkPar2-Tk,(a6)+
	beq	Verf6
	subq.l	#2,a6
* Compte les parametres
Verf2:	bsr	VerEva
	move.w	20(sp),d0
	move.b	d2,0(sp,d0.w)
	move.b	#-1,1(sp,d0.w)
	addq.w	#1,d0
	cmp.w	#19,d0
	bcs.s	Verf3
	subq.w	#1,d0
Verf3:	move.w	d0,20(sp)
	cmp.w	#-1,Parenth(a5)
	beq.s	Verf6
	tst.w	Parenth(a5)
	bne	VerSynt
	moveq	#",",d2
	move.w	(a6)+,d1
	cmp.w	#TkVir-Tk,d1
	beq.s	Verf4
	moveq	#"t",d2
	cmp.w	#TkTo-Tk,d1
	bne	VerSynt
Verf4:	move.b	d2,0(sp,d0.w)
	move.b	#-1,1(sp,d0.w)
	addq.w	#1,d0
	cmp.w	#19,d0
	bcs.s	Verf5
	subq.w	#1,d0
Verf5:	move.w	d0,20(sp)
	bra.s	Verf2
* Compare la chaine cree aux parametres
Verf6:	bsr	VerC
* C'est bon: depile et ramene le type
	move.w	20(sp),d0
	addq.w	#1,d0
	lsr.w	#1,d0
	lea	30(sp),sp
	move.w	(sp)+,Parenth(a5)
	move.w	(sp)+,d2
	rts

******* Compare la chaine cree aux parametres
VerC:	move.l	(sp)+,a2	* Adresse de retour
	lea	(sp),a0
	move.l	22(sp),a1	* Pas de definition: PROCEDURE!
	cmp.l	#0,a1
	beq	VerCF
* Pas de parametre?
	move.b	(a1),d1
	bpl.s	VerC0
	tst.b	(a0)
	bmi.s	VerCF
	bra.s	VerC3
VerC0:	tst.b	(a0)
	bmi.s	VerC3
* Explore les params
VerC1:	move.b	(a1)+,d1
	bmi.s	VerC4
	move.b	(a0)+,d0
	cmp.b	#"3",d1
	beq.s	VerC1a
	cmp.b	d0,d1
	bne	VerType
VerC1a:	move.b	(a0)+,d0
	bmi.s	VerC2
	move.b	(a1)+,d1
	bmi.s	VerC4
	cmp.b	d0,d1
	beq.s	VerC1
	bra	VerC3
VerC2:	move.b	(a1)+,d1
	bpl.s	VerC3
* OK!
VerCF:	jmp	(a2)
* Essaie les params suivants
VerC3:	move.b	(a1)+,d1
	bpl.s	VerC3
VerC4:	cmp.b	#-2,d1		* Change le numero de l'instruction
	bne	VerSynt
	move.l	a1,d0
	btst	#0,d0
	beq.s	VerC5
	addq.l	#1,a1
	addq.l	#1,d0
VerC5:	sub.l	VerBase(a5),d0
	move.l	26(sp),a0
	move.w	d0,(a0)
	addq.l	#4,a1
VerC6:	tst.b	(a1)+
	bpl.s	VerC6
	lea	(sp),a0
	cmp.b	#"V",(a1)+
	bne.s	VerC1
	addq.l	#1,a1
	bra.s	VerC1

******* Pointe la liste des params d'une instruction
VerDInst:
	lea	4(a0,d0.w),a0
VerD1:	tst.b	(a0)+
	bpl.s	VerD1
	move.b	(a0)+,d0
	bpl.s	VerD2
	subq.l	#1,a0
VerD2:	rts

******* Passe en minuscules
Minus:	cmp.b 	#"A",d0
	bcs.s	MnF
	cmp.b	#"Z",d0
	bhi.s	MnF
	add.b	#"a"-"A",d0
MnF:	rts	

*****************************************************************

*****************************************************************
*	VERIFICATION VARIABLES

*******	Variable en INSTRUCTION: egalisation ou appel procedure
VVInst:	tst.w	Passe(a5)
	bne	VViB

* Premiere passe: appel procedure ou variable?
	and.b	#%00001111,3(a6)	RAZ du flag!
	bsr	VarA0
	move.w	d2,-(sp)
	cmp.w	#TkEg-Tk,(a0)
	beq.s	VVi1
	cmp.w	#TkPar1-Tk,(a0)		TABLEAU ou PROCEDURE?
	bne	VInPp1
	bset	#6,3(a6)		Met le flag tableau!
	move.l	VNmBas(a5),-(sp)	Ne stocke pas la variable
	bsr	StoVar1
	move.l	(sp)+,d1	
	cmp.l	VNmBas(a5),d1
	bne	VerNDim
	bsr	VerTablo		Verifie les params d'un tableau
	cmp.b	4(a1),d0
	bne	VerIlP			Illegal numbre of dimensions
	bra.s	VVi2
VVi1:	bsr	StoVar1
VVi2:	cmp.w	#TkEg-Tk,(a6)+
	bne	VerSynt
	move.l	a6,VerPos(a5)
	bsr	VerExp
	move.w	(sp)+,d0
	cmp.b	d0,d2
	bne	VerType 
	rts
* DEUXIEME PASSE / Variable
VViB:	bsr	VarA0
	move.w	d2,-(sp)
	bsr	StoVar2
	btst	#6,d3
	beq.s	VVi2
	bsr	VerTablo
	bra.s	VVi2

*******	VARIABLE EN FONCTION
VVFonc:	tst.w	Passe(a5)
	bne	VVfB
	and.b	#%00001111,3(a6)	RAZ du flag
	bsr	VarA0
* Variable / PASSE 1
	cmp.w	#TkPar1-Tk,(a0)
	bne	StoVar1
	bset	#6,3(a6)		Met le flag tableau!
	move.l	VNmBas(a5),-(sp)	Ne stocke pas la variable
	bsr	StoVar1
	move.l	(sp)+,d1	
	cmp.l	VNmBas(a5),d1
	bne	VerNDim
	bsr	VerTablo		Verifie les params d'un tableau
	cmp.b	4(a1),d0
	bne	VerIlP			Illegal numbre of dimensions
	rts
* Variable / PASSE 2
VVfb:	bsr	VarA0
	bsr	StoVar2
	btst	#6,d3
	beq.s	VVfB1
	bsr	VerTablo
VVfB1:	rts

******* Veut une procedure!!!
VInP:	moveq	#1,d7
	move.w	(a6)+,d0
	cmp.w	#TkPro-Tk,d0
	beq.s	Vinpa
	cmp.w	#TkVar-Tk,d0
	bne	VerSynt
Vinpa:	bsr	VarA0
	tst.w	Passe(a5)
	beq.s	VInP1
	bne.s	VInP2
******* Procedure / PASSE1 : change le token
VInpp1:	addq.l	#2,sp
	moveq	#0,d7
VInP1:	tst.w	Direct(a5)
	bne	VerIlD
	move.w	#TkPro-Tk,-2(a6)
	or.b	#$80,3(a6)
	move.l	a0,a6
* Saute les params
	move.l	a6,VerPos(a5)
	cmp.w	#TkBra1-Tk,(a6)
	bne.s	SoPPb
	tst.w	d7
	bne	VerSynt
SoPPa:	addq.l	#2,a6
	bsr	VerExp
	cmp.w	#TkVir-Tk,d0
	beq.s	SoPPa
	move.l	a6,VerPos(a5)
	cmp.w	#TkBra2-Tk,(a6)+
	bne	VerSynt
SoPPb:	rts
******* Procedure PASSE2: verifie tout! 
VInP2:	tst.w	Direct(a5)
	bne	VerIlD
	moveq	#0,d5			; ANCIEN: STOLAB2, pas de D5
	bsr	StoLabP
	beq	VerUndP
	move.l	(a2),a2
	lea	12(a2),a2
	move.b	2(a2),d0
	ext.w	d0
	lea	4(a2,d0.w),a2
* Verifie les variables
	move.l	a6,VerPos(a5)
	cmp.w	#TkBra1-Tk,(a6)
	bne.s	SoVpx
	cmp.w	#TkBra1-Tk,(a2)
	bne	VerIlP
SoVpa:	addq.l	#2,a6
	pea	4(a2)
	bsr	VerExp
	move.l	(sp)+,a2
	move.b	2(a2),d0
	ext.w	d0
	move.b	3(a2),d1
	and.w	#$0F,d1
	cmp.w	#1,d1
	bne.s	SoVpb
	moveq	#0,d1
SoVpb:	add.b	#"0",d1
	lea	4(a2,d0.w),a2
	cmp.b	d1,d2
	bne	VerSynt
	cmp.w	#TkVir-Tk,(a6)
	bne.s	SoVpc
	cmp.w	#TkVir-Tk,(a2)
	beq.s	SoVpa
	move.l	a6,VerPos(a5)
	bra	VerIlP
SoVPc:	cmp.w	#TkBra2-Tk,(a6)+
	bne	VerSynt
	cmp.w	#TkBra2-Tk,(a2)+
	bne	VerIlP
	rts
SoVpx:	cmp.w	#TkBra1-Tk,(a2)
	beq	VerIlP
	rts
	
*******	Saute le nom d'une variable / A0
VarA0:	lea	2(a6),a0
	move.b	(a0)+,d1
	ext.w	d1
	move.b	(a0)+,d3
	move.b	d3,d0
	moveq	#"0",d2
	and.b	#%111,d0
	beq.s	VerA1
	cmp.b	#1,d0
	beq.s	VerA1
	moveq	#"2",d2
VerA1:	add.w	d1,a0
	rts
	
******* Verifie les params d'un tableau
VerTablo:
	move.w	d2,-(sp)
	move.l	a1,-(sp)
	move.l	a6,VerPos(a5)
	cmp.w	#TkPar1-Tk,(a6)+
	bne	VerSynt
	move.w	Parenth(a5),-(sp)
	clr.w	-(sp)
VTab:	move.l	a6,VerPos(a5)
	addq.w	#1,(sp)
	bsr	VerEva			Verifie les parametres
	cmp.b	#"0",d2
	bne	VerType
	tst.w	Parenth(a5)
	bne.s	VTab1
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VTab
	bne	VerSynt
VTab1:	cmp.w	#-1,Parenth(a5)
	bne	VerSynt
	move.w	(sp)+,d0		Nombre de dimensions
	move.w	(sp)+,Parenth(a5)
	move.l	(sp)+,a1
	move.w	(sp)+,d2
	rts

******* SHARED a,b()

******* Routine SHARED: cree les variables
VpSha:	addq.l	#2,a6
VpSha1:	bsr	VpGV
	cmp.w	#TkVir-Tk,(a6)+
	beq.s	VpSha1
	move.w	-(a6),d0
	move.l	a6,VerPos(a5)
	tst.w	d0
	bne	VerSynt
	rts
* Verification des variables
VpGv:	move.l	a6,VerPos(a5)
	cmp.w	#TkVar-Tk,(a6)+
	bne	VerSynt
	tst.w	Passe(a5)
	bne	VpGv0
* Premiere passe
	and.b	#%00001111,3(a6)
	bsr	VarA0
	cmp.w	#TkPar1-Tk,(a0)
	bne	StoVar1
	cmp.w	#TkPar2-Tk,2(a0)
	beq.s	VpGv1
	bra	VerNoPa
* Deuxieme passe
VpGv0:	bsr	VarA0
	cmp.w	#TkPar1-Tk,(a0)
	bne	StoVar2
VpGv1	lea	4(a0),a6
	rts
******* Verification proprement dite
VerSha:	addq.w	#1,VarBufFlg(a5)
	tst.w	Direct(a5)
	bne	VerIlD
* GLOBAL: Cree les variables
	move.l	DVNmBas(a5),a3
	tst.w	Phase(a5)
	bne	VSh0a
	move.l	a6,-(sp)
	bsr	VpSha
	move.l	(sp)+,a6
	move.l	VNmBas(a5),a3
* Ok! verifie
VSh0a:	addq.l	#2,a6
	tst.w	Passe(a5)
	bne	VSh2
* Passe 1
VSh1a:	move.l	a6,VerPos(a5)
	cmp.w	#TkVar-Tk,(a6)+
	bne	VerSynt
	lea	4(a6),a0		* Pointe le nom
	move.l	a0,d0
	move.b	2(a6),d1	
	ext.w	d1			* Longueur variable
	and.b	#%00001111,3(a6)
	move.b	3(a6),d2		* Flag
	lea	4(a6,d1.w),a6
	cmp.w	#TkPar1-Tk,(a6)
	bne.s	Sh1d
	bset	#6,d2
	bset	#6,-1(a0)
	cmp.w	#TkPar2-Tk,2(a6)
	bne	VerNoPa
	addq.l	#4,a6
* Cherche la variable dans les variables globales
Sh1d:	move.l	a3,a1
Sh1a:	move.l	a1,a2
	move.b	(a1),d3
	beq	VerNDim			* PaG	* Pas une variable GLOBALE!
	ext.w	d3
	cmp.w	d1,d3
	bne.s	Sh1n
	cmp.b	1(a1),d2
	bne.s	Sh1n
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
	addq.w	#6,a1
	move.l	d0,a0
Sh1b:	cmp.w	(a0)+,(a1)+
	bne.s	Sh1n
	dbra	d4,Sh1b
	cmp.b	#2,5(a2)		* Already GLOBALE!
	beq.s	Sh1c
	move.b	#1,5(a2)		* Marque la variable
	tst.w	Phase(a5)
	bne.s	Sh1c
	addq.b	#1,5(a2)		* Devient globale!
	bra.s	Sh1c	
Sh1n:	lea	6(a2,d3.w),a1
	bra.s	Sh1a
* Une autre variable?
Sh1c:	move.w	(a6)+,d0
	cmp.w	#TkVir-Tk,d0
	beq	VSh1a
	tst.w	d0
	bne	VerShal
	bra	VerD
******* Passe 2 : saute les variables
VSh2:	bsr	RouSha
	bra	VerDP
RouSha:	move.b	4(a6),d0
	ext.w	d0
	lea	6(a6,d0.w),a6
	cmp.w	#TkPar1-Tk,(a6)
	bne.s	Sha1
	addq.l	#4,a6
Sha1:	cmp.w	#TkVir-Tk,(a6)+
	beq.s	RouSha
	subq.l	#2,a6
	rts

***********************************************************
*	VEUT UN LABEL GOTO / EXPRESSION
VerLGo:	move.w	(a6),d0
	tst.w	Passe(a5)
	bne.s	Vlg2
******* Premiere passe
	cmp.w	#TkLGo-Tk,d0
	bne.s	Vlg1a
	move.w	#TkVar-Tk,d0
	move.w	d0,(a6)
Vlg1a	cmp.w	#TkVar-Tk,d0
	bne.s	Vlg1b
	move.b	5(a6),d2
	and.b	#$0F,d2
	bne.s	Vlg1b
* Est-ce REEELEMENT un label?
	move.b	4(a6),d0
	ext.w	d0
	lea	6(a6,d0.w),a0
	move.w	(a0),d0
	beq.s	Vlg1c
	cmp.w	#TkVir-Tk,d0
	beq.s	Vlg1c
	bsr	FinieB
	bne.s	Vlg1b
* C'est un label GOTO! Change le token!
Vlg1c	move.w	#TkLGo-Tk,(a6)
	move.l	a0,a6
	rts
* C'est une expression: va evaluer!
Vlg1b	bsr	VerEva
	rts
******* Seconde passe
Vlg2:	cmp.w	#TkLGo-Tk,d0
	bne.s	Vlg2a
* Label: defini?
	addq.l	#2,a6
	bsr	StoLab2
	beq	VerUnd
	rts
* Expression: evalue!
Vlg2a	bsr	VerEva
	moveq	#0,d0
	rts

******* STOCKAGE D'UN LABEL / PASSE 1
StoLab1:move.l	a3,-(sp)
	move.l	a4,-(sp)
	lea	4(a6),a0		* Pointe le nom
	move.l	a0,d0
	move.b	2(a6),d1	
	ext.w	d1			* Longueur variable
	move.b	3(a6),d2		* Flag
	move.l	a6,a3

	move.l	LabBas(a5),a4
	move.l	a4,a1
SL1a:	move.l	d0,a0
	move.l	a1,a2
	move.b	(a1),d3
	beq.s	SL1x
	ext.w	d3
	cmp.w	d1,d3			* Longueur egale?
	bne.s	SL1n
	cmp.b	1(a1),d2
	bne.s	SL1n
	move.w	2(a1),d4		* Local a la procedure?
	cmp.w	Phase(a5),d4
	bne.s	SL1n
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
	lea	8(a1),a1
SL1b:	cmp.w	(a0)+,(a1)+
	bne.s	SL1n
	dbra	d4,SL1b
* ERREUR: Label defined twice
	bra	VerLb2
* Passe au label suivant
SL1n:	lea	8(a2,d3.w),a1
	bra.s	SL1a
* Cree le label
SL1x:	lea	-8(a4),a1		* Baisse le bas LABEL
	sub.w	d1,a1
	cmp.l	LabMini(a5),a1
	bcs	VerVNm
	move.l	a1,LabBas(a5)
	move.b	d1,(a1)+		* Poke la longueur
	move.b	d2,(a1)+		* Poke le flag
	move.w	Phase(a5),(a1)+		* Numero de procedure
	move.l	a1,a2
	lea	4(a6,d1.w),a6
	move.l	a6,a0
	tst.w	(a0)			* Adresse du label
	bne.s	SL1y
	tst.w	2(a0)			Pointe la ligne suivante si on peut
	beq.s	SL1y
	addq.l	#4,a0
SL1y:	move.l	a0,(a1)+
SL1p0:	move.l	d0,a0
	lsr.w	#1,d1
	subq.w	#1,d1
SL1z:	move.w	(a0)+,(a1)+
	dbra	d1,SL1z
	move.l	(sp)+,a4
	move.l	(sp)+,a3
	rts

******* STOCKAGE LABEL PASSE 2 : essaie de retrouver le label
StoLab2:move.w	Phase(a5),d5		* Niveau de procedure
StoLabP
	lea	4(a6),a0		* Pointe le nom
	move.l	a0,d0
	move.b	2(a6),d1	
	ext.w	d1			* Longueur variable
	move.b	3(a6),d2		* Flag

	move.l	LabBas(a5),a1
SL2a:	move.l	d0,a0
	move.l	a1,a2
	move.b	(a1),d3
	beq.s	SL2e
	ext.w	d3
	cmp.w	d3,d1
	bne.s	SL2n
	cmp.b	1(a1),d2
	bne.s	SL2n
	cmp.w	2(a1),d5		* ANCIEN: rien, D5 pas utilise
	bne.s	SL2n
	lea	8(a1),a1
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
SL2c:	cmp.w	(a0)+,(a1)+
	bne.s	SL2n
	dbra	d4,SL2c
* Label trouve, DOKE dans le listing / saute le label
	addq.l	#4,a2		A2= adresse absolue du label
	move.l	a2,a0
	sub.l	LabHaut(a5),a0
	move.w	a0,(a6)
	moveq	#-1,d0
	lea	4(a6,d1.w),a6
	rts
* Label suivant
SL2n:	lea	8(a2,d3.w),a1
	bra.s	SL2a
* Label inexistant / reste sur le label!
SL2e:	moveq	#0,d0
	rts

******* ENLEVE TOUS LES FLAGS VARIABLE GLOBALE!
Locale:	move.l	DVNmBas(a5),a0
	bra.s	LoK2
LoK1:	ext.w	d0
	cmp.b	#2,5(a0)
	beq.s	LoK0
	clr.b	5(a0)
LoK0:	lea	6(a0,d0.w),a0
LoK2:	move.b	(a0),d0
	bne.s	LoK1
	rts
******* MET TOUS LES FLAGS VARIABLE GLOBALE!
Globale:move.l	DVNmBas(a5),a0
	bra.s	GlK2
GlK1:	ext.w	d0
	move.b	#1,5(a0)
	lea	6(a0,d0.w),a0
GlK2:	move.b	(a0),d0
	bne.s	GlK1
	rts

******* Stockage variables 1/2
Stovar:	tst.w	Passe(a5)
	bne	StoVar2

******* STOCKAGE VARIABLE PASSE 1
StoVar1:
	movem.l	d2/d3/a3/a4,-(sp)
	lea	4(a6),a0		* Pointe le nom
	move.l	a0,d0
	move.b	2(a6),d1	
	ext.w	d1			* Longueur variable
	move.b	3(a6),d2		* Flag
	move.l	a6,a3

	tst.w	Phase(a5)
	beq.s	StV1
* Essaie de trouver les variables globales
	move.l	DVNmBas(a5),a4		* Prend les noms GLOBAUX
	move.l	a4,a1
StV1a:	move.l	a1,a2
	move.b	(a1),d3
	beq.s	StV1
	ext.w	d3
	tst.b	5(a1)
	beq.s	StV1n
	cmp.w	d1,d3
	bne.s	StV1n
	cmp.b	1(a1),d2
	bne.s	StV1n
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
	addq.w	#6,a1
	move.l	d0,a0
StV1b:	cmp.w	(a0)+,(a1)+
	bne.s	StV1n
	dbra	d4,StV1b
	move.l	a2,a1			* Ramene l'adresse variable
	move.l	a2,d0
	sub.l	DVNmHaut(a5),d0		* Offset / Table variables
	neg.w	d0			* >0===> GLOBALES!
	move.w	d0,(a6)
	bra.s	Rn1VFin			* Va terminer
StV1n:	lea	6(a2,d3.w),a1
	bra.s	StV1a

* Trouve la variable LOCALE!
StV1:	move.l	VNmBas(a5),a4
	move.l	a4,a1
Rn1Va:	move.l	d0,a0
	move.l	a1,a2
	move.b	(a1)+,d3	
	beq.s	Rn1Vx
	ext.w	d3
	cmp.b	d1,d3			* Longueur egale?
	bne.s	Rn1Vn
	cmp.b	(a1)+,d2		* Flag egal?
	bne.s	Rn1Vn
	tst.w	(a1)+			* Saute DIVERS
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
	addq.w	#2,a1
Rn1Vb:	cmp.w	(a0)+,(a1)+
	bne.s	Rn1Vn
	dbra	d4,Rn1Vb
	bra.s	Rn1Vz
* Passe a la variable suivante
Rn1Vn:	lea	6(a2,d3.w),a1
	bra.s	Rn1Va
* Cree la variable
Rn1Vx:	lea	-6(a4),a2
	sub.w	d1,a2
	cmp.l	VNmMini(a5),a2
	bcs	VerNmO
	move.l	a2,VNmBas(a5)
	move.l	a2,a1
	move.b	d1,(a1)+		* Poke la longueur
	move.b 	d2,(a1)+		* Poke le flag
	move.w	VarLong(a5),(a1)+	* Pointeur
	clr.w	(a1)+			* Variables Locale-Non dim
	addq.w	#6,VarLong(a5)		* Place pour le type
	move.w	d1,d3
	lsr.w	#1,d3
	subq.w	#1,d3
	move.l	d0,a0
Rn1Vy:	move.w	(a0)+,(a1)+
	dbra	d3,Rn1Vy
* Variable trouvee
Rn1Vz:	move.l	a2,a1			* Ramene l'adresse variable
	sub.l	VNmHaut(a5),a2		* Offset / Table variables
	move.w	a2,(a6)
Rn1VFin:lea	4(a6,d1.w),a6		* Saute la variable
	movem.l	(sp)+,d2/d3/a3/a4
	rts

*******	STOCKAGE VARIABLE DEUXIEME PASSE: retrouve l'adresse
StoVar2:movem.w	d2/d3,-(sp)
	lea	4(a6),a0		* Pointe le nom
	move.b	2(a6),d1	
	ext.w	d1			* Longueur variable
	move.w	(a6),d3
	bpl.s	StVGlo
* DOKE le pointeur, variable locale (<0!)
	move.l	VNmHaut(a5),a1
	lea	0(a1,d3.w),a1
	move.w	2(a1),(a6)
	bra.s	StVv
* Variable GLOBALE (>0!)
StVGlo:	neg.w	d3
	move.l	DVNmHaut(a5),a1
	lea	0(a1,d3.w),a1
	move.w	2(a1),d0
	neg.w	d0
	subq.w	#1,d0
	move.w	d0,(a6)
StVv:	lea	4(a6,d1.w),a6
	movem.w	(sp)+,d2/d3
	rts

***********************************************************

******* Instruction finie??
Finie:	move.w	(a6),d0
FinieB:	beq.s	Finy
	cmp.w	#TkDP-Tk,d0
	beq.s	Finy
	cmp.w	#TkThen-Tk,d0
	beq.s	Finy
	cmp.w	#TkElse-Tk,d0
Finy:	rts
