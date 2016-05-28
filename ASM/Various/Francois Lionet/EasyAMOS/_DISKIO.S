;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* CHARGEMENT EDITEUR
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

***********************************************************
*	Pas sauvegarde si demo!
	IfNE 	VDemo
EdPRun
LRunReLoad
EdLRunBob
EdLRunDisc
EdSave
EdSaveAs
EdSBlA
EdPrt
EdSBloc	Alea	EdDemo,a0
	moveq	#125,d0
	bra	Alert
	EndC

***********************************************************
*	Sauvegardes (si pas demo)!
	IfEQ	VDemo
******* SAVE AS
EdSaveAs
	bsr	TokCur
	bsr	ClearVar
	jsr	EffBanks
	bsr	CptLines
	bra.s	EdSv1a
*******	SAUVEGARDE PROGRAMME
EdSave:
	bsr	TokCur
	bsr	ClearVar
	jsr	EffBanks
	bsr	CptLines
******* Demander le nom?
	lea	NamePrg(a5),a0
	tst.b	(a0)
	beq.s	EdSv1a
	move.l	Name1(a5),a1
	bsr	CoCop
	bra.s	EdSv1b
EdSv1a	Alea	MesSv1,a0
	Alea	MesSv2,a1
	Alea	MesLd3,a2
	lea	EdVide(pc),a3
	bsr	FSelEdit
	beq	NotDone
	bsr	FillFFree
	bsr	PathIt
* Change le nom courant
EdSv1b	move.l	Name1(a5),a0
	lea	NamePrg(a5),a1
	jsr	CoCop
* SAVING
	tst.w	EdNLigne(a5)
	beq	EdSx
	move.w	#1,EdDisk(a5)
	Alea	AvSv,a0
	move.l	Name1(a5),a1
	bsr	AvName
* Fait un .BAK si present
	tst.w	EdSvBak(a5)
	beq	PaBak
******* Fabrique NOM.BAK
	move.l	Name1(a5),a0
	move.l	Name2(a5),a1
EdSv1:	move.b	(a0)+,(a1)+
	bne.s	EdSv1
EdSv2:	cmp.l	Name2(a5),a1
	bls	PaBak
	cmp.b	#".",-(a1)
	bne.s	EdSv2
	move.l	a1,a2
	Alea	SufBas,a0
EdSv3:	move.b	(a0)+,d0
	move.b	(a1)+,d1
	cmp.b	#"a",d0
	bcs.s	EdSv3a
	cmp.b	#"z",d0
	bhi.s	EdSv3a
	sub.b	#$20,d0
EdSv3a	cmp.b	#"a",d1
	bcs.s	EdSv3b
	cmp.b	#"z",d1
	bhi.s	EdSv3b
	sub.b	#$20,d1
EdSv3b	cmp.b 	d0,d1
	bne.s	PaBak
	tst.b	d0
	bne.s	EdSv3
* Change les noms
	move.l	a2,a1
	sub.l	Name2(a5),a1
	add.l	Name1(a5),a1
	Alea	SufBas,a0
EdSv4:	move.b	(a0)+,(a1)+
	bne.s	EdSv4
	Alea	SufBak,a0
EdSv4a:	move.b	(a0)+,(a2)+
	bne.s	EdSv4a
* Renomme NOM.AMOS si present
EdSv5:	move.l	Name1(a5),d1
	move.l	Name2(a5),d2
	move.w	#DosRen,d7
	bsr	DosCall
	bne.s	PaBak
	move.w	#DosIoErr,d7
	bsr	DosCall
	cmp.w	#205,d0
	beq.s	PaBak
	cmp.w	#203,d0
	bne	DiskError
* Efface NOM.BAK et recommence!
EdSv6:	move.l	Name2(a5),d1
	moveq	#DosDel,d7
	bsr	DosCall
	beq	DiskError
	bra.s	EdSv5
******* Sauve le fichier! 
PaBak:	bsr	SaveIcon
	move.l	#1006,d2
	bsr	FOpen
* Sauve l'entete AMOS BASIC V1.3
	lea	EnHead(pc),a0
	move.b	#"V",d0			* Teste!
	tst.w	StModif(a5)
	beq.s	.Skip
	move.b	#"v",d0			* Non teste!
.Skip	move.b	d0,11(a0)
	move.l	a0,d2
	moveq	#16,d3
	bsr	FWrite
* Sauve la taille PRG et nb de ligne
	move.l	Buffer(a5),a0
	move.l	StHaut(a5),d0
	subq.l	#2,d0
	sub.l	StBas(a5),d0
	move.l	d0,(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	FWrite
* Sauve le corps du programme
	move.l	StBas(a5),d2
	move.l	StHaut(a5),d3
	subq.l	#2,d3
	sub.l	d2,d3
	bsr	FWrite
* Sauve les banques....
	bsr	SaveBks
* Fin de la sauvegarde
EdSvX	clr.w	EdChange(a5)
	clr.w	EdDisk(a5)
	bsr	FClose
	bsr	AverFin
	bsr	NewBuf
EdSx:	rts

*******	SAVE BLOCK
EdSBloc	bsr	TokCur
	bsr	CptLines
	bsr	EdBlSto
* Selecteur de fichier
	Alea	MesSBl1,a0
	Alea	MesSBl2,a1
	Alea	MesLd3,a2
	lea	EdVide(pc),a3
	bsr	FSelEdit
	beq	NotDone
	bsr	FillFFree
	bsr	PathIt
	move.w	#1,EdDisk(a5)
	Alea	AvSv,a0
	move.l	Name1(a5),a1
	bsr	AvName
* Ouvre!
	move.l	#1006,d2
	bsr	FOpen
* Sauve l'entete AMOS BASIC V1.00
	lea	EnHead(pc),a0
	move.b	#"v",11(a0)		* Non teste!
	move.l	a0,d2
	moveq	#16,d3
	bsr	FWrite
* Sauve la taille
	move.l	EdBlocAd(a5),a0
	move.l	a0,d2
	moveq	#4,d3
	bsr	FWrite
* Sauve le corps du bloc
	move.l	(a0)+,d3
	addq.l	#6,d2
	bsr	FWrite
* Banques vides
	moveq	#3,d0
	bsr	SHunk
	move.l	Buffer(a5),a0
	clr.w	(a0)
	move.l	a0,d2
	moveq	#2,d3
	bsr	FWrite
* Fin de la sauvegarde
	bra	EdSvX

*******	SAUVEGARDE BLOC EN ASCII
EdSBlA:	bsr	TokCur
	bsr	EdBlSto
	Alea	MesSvA1,a0
	Alea	MesSvA2,a1
	Alea	MesSvA3,a2
	lea	EdVide(pc),a3
	bsr	FSelEdit
	beq	NotDone
	bsr	FillFFree
	bsr	PathIt
	move.w	#1,EdDisk(a5)
* Ouvre le fichier MODE_NEW
	move.l	#1006,d2
	bsr	FOpen
	Alea	AvSvA,a0
	move.l	Name1(a5),a1
	bsr	AvName
* Detokenise tout le bloc
	bsr	BlToA0
EdSva1	bsr	BlToA1
	move.b	#10,(a0)
	addq.l	#1,d3
	bsr	FWrite
	bsr	BlToA2
	bne.s	EdSva1
* Ca y est!
EdSvAx:	bsr	FClose			* Va fermer le fichier
	clr.w	EdDisk(a5)
	bsr	BufUntok		* Remet tout le buffer!
	bsr	AverFin
	rts

*******	PRINT BLOC 
EdPrt:	bsr	TokCur
	bsr	EdBlSto
	Alea	AvPrt,a0
	lea	NamePrg(a5),a1
	bsr	AvName
	move.w	#1,EdDisk(a5)
* Detokenise tout le bloc
	bsr	BlToA0
EdPrt1	bsr	BlToA1
	move.b	#13,(a0)+
	move.b	#10,(a0)+
	clr.b	(a0)
	move.l	d2,a0
	bsr	ImpImp
	bsr	BlToA2
	beq.s	EdPrt3
* Control-C?
	move.w	T_Actualise(a5),d0
	bclr	#BitControl,d0
	beq.s	EdPrt1
	move.w	d0,T_Actualise(a5)
* Ca y est!
EdPrt3	clr.w	EdDisk(a5)
	bsr	BufUntok		* Remet tout le buffer!
	bsr	AverFin
	SyCall	ClearKey
	rts

	EndC

******* Routines
BlToA0	move.l	EdBlocAd(a5),a6		* 1-> Init
	move.w	4(a6),d7
	addq.l	#6,a6
	rts
BlToA1	move.l	EdBufE(a5),a4		* 2-> Detokenise
	sub.l	a3,a3
	movem.l	a4/a6/d7,-(sp)
	bsr	Detok
	movem.l	(sp)+,a4/a6/d7
	moveq	#0,d3
	move.w	(a4)+,d3
	lea	0(a4,d3.w),a0
	move.l	a4,d2
	rts	
BlToA2	subq.w	#1,d7			* 3-> Suivante
	beq.s	BlToA4
	moveq	#0,d0
	move.b	(a6),d0
	cmp.w	#TkProc-Tk,2(a6)
	bne.s	BlToA3
	tst.w	10(a6)
	bpl.s	BlToA3
	move.l	4(a6),d0
	lea	12+2(a6,d0.l),a6
	moveq	#0,d0
BlToA3	add.w	d0,a6
	add.w	d0,a6
	moveq	#1,d0
BlToA4	rts
******* Routine: Charge et verifie l'entete AMOS
GetAMOS	move.l	Buffer(a5),d2
	moveq	#16+4,d3
	bsr	FRead
	move.l	Buffer(a5),a2
	move.l	a2,a1
	lea	EnHead(pc),a0
	moveq	#10-1,d0
EdLd1:	cmp.b	(a0)+,(a1)+
	bne	PaAmos
	dbra	d0,EdLd1
	rts
* Routine: Copie le message A0 et le NOM A1 et averti!
AvName:	move.l	EdBufT(a5),a2
AcL0a	move.b	(a0)+,(a2)+
	bne.s	AcL0a
	move.b	#" ",-1(a2)
AcL0b	move.b	(a1)+,(a2)+
	bne.s	AcL0b
	move.l	EdBufT(a5),a0
	clr.b	76(a0)
	bra	Avertir
* Messages LOAD
PaAmos:	bsr	FClose
	Alea	MPAmos,a0
	moveq	#100,d0
	bra	AlOuErr
******* Demande plus de place
GetPlace
	clr.w	EdDisk(a5)
	move.l	d0,-(sp)
	bsr	FClose
	Alea	ConfText,a0
	bsr	Confirm
	beq	GtPl2
	move.l	(sp),d0
	move.l	StTTexte(a5),(sp)
	bsr	ChgTTexte
	bne.s	GtPl1
	move.l	(sp),d0
	bsr	ChgTTexte
	bne	GtPl0
GtPl1	bsr	RNew2
	addq.l	#4,sp
	rts
GtPl0	bsr	RNew2
	bsr	NewBuf
	bra	VerOut
* Affiche la taille necessaire
GtPl2	bsr	NewBuf
	ALea	DispText,a1
	move.l	EdBufT(a5),a0
GtPl3	move.b	(a1)+,(a0)+
	bne.s 	GtPl3
	subq.l	#1,a0
	move.l	(sp)+,d0
	bsr	LongDec
	clr.b	(a0)
	move.l	EdBufT(a5),a0
	move.w	#200,d0
	bra	Alert
* Pas de place, c'est tout!
PaPlace	bsr	FClose
	Alea	MPlace,a0
	moveq	#100,d0
	bra	AlOuErr

******* SAUVEGARDE ICONE PROGRAMME
SaveIcon:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	Icons(a5)
	beq.s	SvIccX
	move.l	IconBase(a5),d0
	beq.s	SvIccX
	move.l	d0,a6
	move.l	AdrIcon(a5),d0
	beq.s	SvIccX
	move.l	d0,a1
	move.l	Name1(a5),a0
	jsr	-84(a6)
SvIccX	movem.l	(sp)+,d0-d7/a0-a6
	rts

***********************************************************
*	CHARGEMENTS 

	IFEQ	VDemo
******* Fait fonctionner un programme en accessoire...
EdPRun
	Alea	MesAc1,a0
	Alea	MesAc2,a1
	Alea	MesAc3,a2
	lea	EdVide(pc),a3
	bsr	FSelEdit
	beq	NotDone
	bsr	FillFFree
	bsr	PathIt
	move.l	Name1(a5),-(sp)
	move.l	(sp),-(sp)
	bra.s	LRunit
******* LOAD / RUN program...
EdLRunBob
	Alea	NameHelp,a0
	bra.s	EdLRun
EdLRunDisc
	ALea	HelpLoad,a0
EdLRun	
	move.l	Name1(a5),a2
	move.l	a2,-(sp)
	Alea	DefIcon,a1
.lp1	move.b	(a1)+,(a2)+
	bne.s	.lp1
	subq.l	#1,a2
	move.l	a2,-(sp)
.lp2	move.b	(a0)+,(a2)+
	bne.s	.lp2
* Essaie d'ouvrir le fichier...
LRunit	bsr	TokCur
	move.l	#1005,d2
	move.l	(sp),d1
	move.l	d1,d3
	bsr	OpenF
	bne.s	.ok
	move.l	4(sp),d1
	move.l	d1,d3
	bsr	OpenF
	bne.s	.ok
* Not found!	
	Alea	HNof,a0
	moveq	#100,d0
	bra	AlOuErr
** Ok, sauve le premier programme?
.ok	addq.l	#8,sp
	move.l	d3,a0
	move.l	Name1(a5),a1
	bsr	CoCop
	bsr	GetAMOS
	move.l	16(a2),d0
	add.l	#258,d0
	move.l	d0,-(sp)
	bsr	FClose
* Fait un NEW!
	move.l	Name1(a5),a0			* Sauve le nom
	lea	LRunData(a5),a1
	bsr	CoCop
	bsr	Saved
	lea	LRunData(a5),a0			* Recopie le nom
	move.l	Name1(a5),a1
	bsr	CoCop
* Sauve les données de l'éditeur
	lea	LRunData(a5),a1
	move.w	#1,(a1)+
	move.l	StTTexte(a5),(a1)+
	move.w	EdNLigne(a5),(a1)+
	move.w	EdXPos(a5),(a1)+
	move.w	EdYPos(a5),(a1)+
	move.w	EdXCu(a5),(a1)+
	move.w	EdYCu(a5),(a1)+
	lea	NamePrg(a5),a0
	bsr	CoCop
	bsr	RNew
* Change la taille du buffer
	move.l	StBas(a5),a4
	move.l	(sp)+,d0
	jsr	ChgTTexte
	beq	OOfMem
* Charge et compte
	bsr	LdAMOS
* Run!
	bra	Run
******* Recharge le programme initial!
LRunReLoad
	bsr	RNew
	lea	Environs(a5),a0
	lea	LRunData(a5),a2
	clr.w	(a2)+
	move.l	(a2)+,d0
	bsr	ChgTTexte
	beq	OOfMem
	tst.w	(a2)+
	beq.s	.skip
	lea	8(a2),a0
	move.l	Name1(a5),a1
	bsr	CoCop
	bsr	LdAMOS
	move.w	(a2)+,EdXPos(a5)
	move.w	(a2)+,EdYPos(a5)
	move.w	(a2)+,EdXCu(a5)
	move.w	(a2)+,EdYCu(a5)
.skip	bsr	NewBuf
	move.l	BasSp(a5),sp
	bra	EdLoop	

* OPEN: ouvre le fichier systeme (diskname1) access mode D2
OpenF	move.l 	Name1(a5),d1
	move.w	#DosOpen,d7
	bsr	DosCall
	move.l	d0,Handle(a5)
	rts
* Charge et compte un programmme
LdAMOS	movem.l	a0-a4/d0-d7,-(sp)
	move.w	#4,EdDisk(a5)
	Alea	AvLd,a0
	move.l	Name1(a5),a1
	bsr	AvName
	bsr	LLAmos
	clr.w	EdDisk(a5)
	move.l	Name1(a5),a0
	lea	NamePrg(a5),a1
	bsr	CoCop
	bsr	AverFin
	movem.l	(sp)+,a0-a4/d0-d7
	rts
	ENDC

******* AMIGA-SHIFT-LOAD
SEdLoad	bsr	TokCur
	bsr	Saved
* Demande le nom!
	Alea	EdLName,a0
	moveq	#40,d6
	bsr	EtInp0
	move.l	EdBufT(a5),a0
	tst.b	(a0)
	beq	NotDone
	move.l	Name1(a5),a1
	bsr	CoCop
	bsr	PathIt
	bsr	RNew
	bra.s	ReLoad

******* LOAD PROGRAMME
EdLoad:	bsr	TokCur
	bsr	Saved
* Selecteur de fichier
	Alea	MesLd1,a0
	Alea	MesLd2,a1
	Alea	MesLd3,a2
	lea	EdVide(pc),a3
	bsr	FSelEdit
	beq	NotDone
	bsr	FillFFree
	bsr	PathIt
* NEW
	bsr	RNew
* Message LOADING
ReLoad	move.w	#1,EdDisk(a5)
	Alea	AvLd,a0
	move.l	Name1(a5),a1
	bsr	AvName
* Charge
	bsr	LLAmos
	bne.s	EdLok
	bsr	GetPlace
	bra.s	ReLoad
* Change le nom
EdLok	clr.w	EdDisk(a5)
	move.l	Name1(a5),a0
	lea	NamePrg(a5),a1
	bsr	CoCop
	bsr	AverFin
* Ca y est!
	bsr	NewBuf
	rts
******* ROUTINE: Charge le fichier! 
LLAmos	move.l	#1005,d2
	bsr	FOpen
* Verifie l'entete
	bsr	GetAMOS
* Verifie la taille du buffer
LLAuto	move.l	16(a2),d0
	add.l	#256,d0
	cmp.l	StTTexte(a5),d0
	bhi.s 	PPlace
	move.l	16(a2),d3
	move.l	StHaut(a5),a0
	clr.w	-(a0)
	move.l	a0,d2
	sub.l	d3,d2
* Charge le fichier
	bsr	FRead
	move.l	d2,StBas(a5)
	addq.w	#1,StModif(a5)
	bsr	CptLines
* Charge les banques
	move.l	#EntNul,d3
	bsr	LoadBk
* Fin du chargement
	bsr	FClose
	moveq	#-1,d1
	rts
* Pas de place!!!
PPlace:	moveq	#0,d1
	rts

******* RUN ONLY
	IfNE	ROnly
AccEAll	
AccELast
FillAcc
AccEnd
Detok
RBGrab
	rts
PrgRun	
IBGrab	bra	InsRet
	EndC

	IfEQ	ROnly
*******	MERGE PROGRAMME
EdMerge:
	bsr	TokCur
	bsr	ClearVar
	jsr	EffBanks
	bsr	EdBlFree
* Selecteur de fichier
	Alea	MesMe1,a0
	Alea	MesMe2,a1
	Alea	MesLd3,a2
	lea	EdVide(pc),a3
	bsr	FSelEdit
	beq	NotDone
	bsr	FillFFree
	bsr	PathIt
	move.w	#1,EdDisk(a5)
* Message MERGING
	Alea	AvMe,a0
	move.l	Name1(a5),a1
	bsr	AvName
* Charge dans le bloc
	move.l	#1005,d2
	bsr	FOpen
	bsr	GetAmos
	move.l	16(a2),d0
	bsr	EdBlRes
	beq	PaPlace
	move.l	(a0),d3
	lea	6(a0),a0
	move.l	a0,d2
	bsr	FRead
	clr.w	EdDisk(a5)
	bsr	FClose
* Paste!
	bsr	EdBlCpt
	bsr	EdBlPas
	bsr	EdBlFree
	bsr	AverFin
	rts

*******	CHARGEMENT FICHIER ASCII
LMerg:	equ 	64
EdLoadA:
	bsr	TokCur
	bsr	ClearVar
	jsr	EffBanks
	Alea	MesLdA1,a0
	Alea	MesLdA2,a1
	Alea	MesLdA3,a2
	lea	EdVide(pc),a3
	bsr	FSelEdit
	beq	NotDone
	bsr	FillFFree
	bsr	PathIt
	EcCalD	Active,EcFonc
* Ouvre le fichier MODE_OLD
	move.w	#1,EdDisk(a5)
	move.l	#1005,d2
	bsr	FOpen
* Charge dans le buffer!
	move.w	EdYPos(a5),d1
	add.w	EdYCu(a5),d1
	move.w	d1,-(sp)
Merg0:	move.l	EdBufE(a5),a2
	moveq	#0,d5
Merg1:	move.l	a2,d2
	moveq	#1,d3
	bsr	FRead
	beq	MergX
	bmi	DiskError
	cmp.l	d0,d3
	bne	DiskError
* Verifie l'octet!
	cmp.b	#10,(a2)
	beq.s	MergS
	addq.w	#1,d5
	cmp.w	#245,d5
	bcc.s	MergL	
	cmp.b	#32,(a2)
	bcs.s	Merg1
	addq.l	#1,a2
	bra.s	Merg1
* Line too long
MergL	ALea	EdLLong,a0
	move.l	EdBufE(a5),a1
MergL1	move.b	(a0)+,(a1)+
	bne.s	MergL1
	subq.l	#1,a1
	sub.l	EdBufE(a5),a1
	move.w	a1,-(sp)
	bra.s	MergL2
* Tokenise!
MergS:	clr.b	(a2)
	sub.l	EdBufE(a5),a2
	move.w	a2,-(sp)
	move.l	EdBufE(a5),a3
	move.l	EdBufT(a5),a4
	bsr	Tokenise
	bne.s	MergOk
	addq.l	#2,sp
	bra.s	Merg0
* Stocke!
MergOk	move.w	2(sp),d1
	move.w	#1,EdILigne(a5)
	move.l	EdBufT(a5),a1
	bsr	Stocke
	bne	MergOut
	addq.w	#1,2(sp)
* Imprime la ligne
MergL2	Alea	MrgMes,a1
	WiCall	Print
	move.l	EdBufE(a5),a1
	clr.b	LMerg(a1)
	move.w	(sp)+,d0
	cmp.w	#LMerg,d0
	bcc.s	Merg3
	lea	0(a1,d0.w),a0
Merg2	move.b	#32,(a0)+
	addq.w	#1,d0
	cmp.w	#LMerg,d0
	bcs.s	Merg2
Merg3	WiCall	Print
* Control-C?
	move.w	T_Actualise(a5),d0
	bclr	#BitControl,d0
	beq	Merg0
	move.w	d0,T_Actualise(a5)
* Fini!
MergX:	addq.l	#2,sp
MergX1	clr.w	EdDisk(a5)
	clr.w	EdILigne(a5)
	bsr	FClose
	bsr	AverFin
	bsr	CptLines
	bsr	NewBuf
	SyCall	ClearKey
	rts
* Trop long!!!
MergOut	bsr	MergX1
	bra	RetOut	

	EndC

***********************************************************
*	FILL FILE DEVICES
FillDev	movem.l	d0-d7/a0-a6,-(sp)
	bsr	FFDeb
* Cherche les devices
	move.l	$4,a6
	jsr	Forbid(a6)
	move.l	DosBase(a5),a3
	move.l	34(a3),a3
	move.l	24(a3),d0
	lsl.l	#2,d0
	move.l	d0,a3
	move.l	4(a3),d0
	lsl.l	#2,d0
	move.l	d0,a3
* Boucle d'exploration
FDev1	
	tst.l	8(a3)
	beq.s	FDev5
	move.l	40(a3),d0
	beq.s	FDev5
	lsl.l	#2,d0
	move.l	d0,a0
	move.b	(a0)+,d0
	ext.w	d0
	move.l	Buffer(a5),a2
	lea	8(a2),a1
	subq.w	#1,d0
	bmi.s	FDev5
FDev2	move.b	(a0)+,(a1)+
	dbra	d0,FDev2
	move.b	#":",(a1)+
FDev3	clr.b	(a1)
* Filtre 
	move.l	Name2(a5),a0		* Filtre POSITIF
	tst.b	(a0)
	beq.s	FDev4
	lea	8(a2),a1
	bsr	Joker
	beq.s	FDev5
* Poke dans la liste
FDev4	move.l	#-1,124(a2)
	moveq	#" ",d2
	bsr	FillFPoke
* Device suivant
FDev5	move.l	(a3),d0
	lsl.l	#2,d0
	move.l	d0,a3
	bne.s	FDev1
* C'est fini!
	jsr	Permit(a6)
	bsr	FillSort
	movem.l	(sp)+,d0-d7/a0-a6
	rts

******* Enleve l'ancien buffer -si present-
FfDeb	bsr	FillFFree
* Premier faux fichier
	move.l	Buffer(a5),a2
	clr.w	8(a2)
	clr.l	124(a2)
	moveq	#0,d2
	bsr	FillFPoke
	clr.w	FillFNb(a5)
	rts

******* Pointe le debut du nom
DNom:	move.l	a0,a1
FaL1	tst.b	(a0)+
	bne.s	FaL1
	subq.l	#1,a0
FaL2	move.b	-(a0),d0
	cmp.b	#"/",d0
	beq.s	FaL3
	cmp.b	#":",d0
	beq.s	FaL3
	cmp.l	a1,a0
	bcc.s	FaL2
FaL3	addq.l	#1,a0
	rts
	
***********************************************************
*	ERREUR DISQUE SOUS EDITEUR
EdDiskErr:
	cmp.w	#2,EdDisk(a5)
	beq.s	EddEr5
*	cmp.w	#3,EdDisk(a5)
*	beq.s	EddEr6
	Alea	MErreur,a0
	subq.w	#1,d0
	bmi.s	EddEr3
EddEr2:	tst.b	(a0)+
	bne.s	EddEr2
	dbra	d0,EddEr2
EddEr3:	move.l	a0,-(sp)
	bsr	FClose
	bsr	BufUntok
* Si LRUN systeme: fait un NEWBUF
	cmp.w	#4,EdDisk(a5)
	bne.s	.skip
	bsr	NewBuf
.skip
* Erreur chargement d'un accessoire --> Efface l'accessoire!
*	tst.w	EdDisk(a5)
*	bpl.s	EddEr4
*	bsr	AccELast
* ALERTE!
EddEr4	clr.w	EdDisk(a5)
	move.l	(sp)+,a0
	moveq	#125,d0
	bra	Alert
* AUTOLOAD
EddEr5	jmp	NoAuto
* HELP accessory
*EddEr6	clr.w	EdDisk(a5)
*	bsr	FClose
*	bra	HelpNoF
	
******* NOT DONE
NotDone:EcCalD	Active,EcEdit
	bsr	NewBuf
	Alea	MesNotD,a0
	moveq	#100,d0
	bra	Alert	

******* Appel direct du selecteur de fichier par l'editeur
FSelEdit
	clr.w	AccFlag(a5)
FSelE1	
	move.l	a2,-(sp)
	move.l	a3,-(sp)
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	move.l	sp,a3
	move.w	#1,EdFSel(a5)
	bsr	FSel0
	clr.w	EdFSel(a5)
	lea	16(sp),sp
	tst.w	d0
	rts
******* ERREUR selecteur de fichier
EdFsErr	clr.w	EdFSel(a5)
	cmp.w	#1,d0		* Si out of mem---> CLEARVAR...
	beq	EdOMm
	Alea	MErreur,a0
	subq.w	#1,d0
	bmi.s	EdFs3
EdFs2:	tst.b	(a0)+
	bne.s	EdFs2
	dbra	d0,EdFs2
EdFs3:	moveq	#100,d0
	bra	Alert
EdVide:	dc.w 0


;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* DISQUE
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

******* DOS CALL: appelle une routine DOS
DosCall	movem.l a2-a6,-(sp)
	move.l 	DosBase(a5),a6
	move.l	a6,a5
	add.w	d7,a5
	jsr	(a5)
	movem.l	(sp)+,a2-a6
	tst.l	d0
	rts

******* OPEN: ouvre le fichier systeme (diskname1) access mode D2
FOpen:	move.l 	Name1(a5),d1
	move.w	#DosOpen,d7
	bsr	DosCall
	tst.l	d0
	beq	DiskError
	move.l	d0,Handle(a5)
	rts

******* CLOSE fichier systeme
FClose:	tst.l	Handle(a5)
	beq.s	PaFCl
	move.l	Handle(a5),d1
	move.w	#DosClose,d7
	bsr	DosCall
	clr.l	Handle(a5)
PaFCl:	rts

******* READ fichier systeme D3 octets dans D2	/ Pas erreurs
FRead:	movem.l	d1-d7/a0-a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	DosRead(a6)
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	rts
* Avec erreurs!
ERead:	movem.l	d1-d7/a0-a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	DosRead(a6)
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	beq	DiskError
	bmi	DiskError
	cmp.l	d0,d3
	bne	DiskError
	rts

******* WRITE fichier systeme D3 octets de D2	
FWrite:	movem.l	d1-d7/a0-a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	DosWrite(a6)
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	beq	DiskError
	bmi	DiskError
	cmp.l	d0,d3
	bne	DiskError
	rts

******* SEEK fichier system D3 mode D2 deplacement
FSeek:	movem.l	d1-d7/a0-a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	DosSeek(a6)
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	bmi	DiskError
	rts

******* ENLEVE LE LOCK COURANT
LockFree:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	LockSave(a5),d1
	beq.s	LokF
	moveq	#DosUnLock,d7
	bsr	DosCall
	clr.l	LockSave(a5)
LokF:	movem.l	(sp)+,d0-d2/a0-a2
	rts

******* Compute NAME1 + PATHACT >>> NAME1
PathIt
	movem.l	a0-a1/d0-d1,-(sp)
* Cherche un ":" dans le nom
	move.l	Name1(a5),a0
	cmp.b	#":",(a0)
	beq.s	.DP
.Loop1	move.b	(a0)+,d0
	beq.s	.NoDP
	cmp.b	#":",d0
	bne.s	.Loop1
	bra.s	.Fini
* Recopie à la fin du pathact
.NoDp	move.l	PathAct(a5),a0
.Loop2	tst.b	(a0)+
	bne.s	.Loop2
	move.l	Name1(a5),a1
.Loop3	move.b	(a1)+,(a0)+
	bne.s	.Loop3
* Remet dans NAME1
	move.l	PathAct(a5),a0
	move.l	Name1(a5),a1
.Loop4	move.b	(a0)+,(a1)+
	bne.s	.Loop4
	subq.l	#1,a1
.Loop5	move.b	(a0)+,(a1)+
	bne.s	.Loop5
* Ok
.Fini	movem.l	(sp)+,a0-a1/d0-d1	
	rts
** Deux points au début
.Dp	move.l	PathAct(a5),a1
.Dpl1	tst.b	(a1)+
	bne.s	.Dpl1
	move.l	a1,d1
.Dpl2	move.b	(a0)+,(a1)+
	bne.s	.Dpl2
	move.l	Name1(a5),a1
	move.l 	PathAct(a5),a0
.Dpl3	move.b	(a0)+,d0
	beq.s	.Dpl4
	cmp.b	#":",d0
	beq.s	.Dpl4
	move.b	d0,(a1)+
	bra.s	.Dpl3
.Dpl4	move.l	d1,a0
.Dpl5	move.b	(a0)+,(a1)+
	bne.s	.Dpl5
	bra.s	.Fini

******* NOM DISQUE
NomDisk	move.l	(a3)+,a2
	move.w	(a2)+,d2
	beq	IlDName
	cmp.w	#108,d2
	bcc	IlDName
	move.l	Name1(a5),a0
	jsr	ChVerBuf2
	bra	PathIt
IlDName	jmp	FonCall

******* NOM DIR1
*	Met la racine en NAME1
*	Met le filtre en NAME2
NomDir:	move.l	(a3)+,a2
	move.w	(a2)+,d2
	cmp.w	#256,d2
	bcc	Stoolong
	moveq	#0,d7
NDir:	move.l	Name1(a5),a0
	clr.b	(a0)
	move.l	Name2(a5),a1
	clr.b	(a1)
	moveq	#-1,d1
	move.l	a0,d6
NmD1	addq.w	#1,d1
	cmp.w	d1,d2
	beq.s	NmD5
	move.b	(a2)+,d0
	move.b	d0,(a0)+
	clr.b	(a0)
	cmp.b	#"*",d0
	beq.s	NmD2
	cmp.b	#"?",d0
	bne.s	NmD3
NmD2	bset	#0,d7
NmD3	cmp.b	#":",d0
	beq.s	NmD4
	cmp.b	#"/",d0
	bne.s	NmD1
NmD4	bclr	#0,d7
	bne	IlDName
	move.l	a0,d6
	bra.s	NmD1
NmD5	tst.w	d7
	beq.s	NmDX
	move.l	d6,a0
NmD6	move.b	(a0)+,(a1)+
	bne.s	NmD6
	move.l	d6,a0
	clr.b	(a0)
NmDx	bra	PathIt

******* Erreurs disque
DiskError:
	move.w	#DosIOErr,d7
	bsr	DosCall
DiskErr	lea	ErDisk(pc),a0
	moveq	#-1,d1
DiE1:	addq.l	#1,d1
	move.w	(a0)+,d2
	bmi.s	DiE2
	cmp.w	d0,d2
	bne.s	DiE1
	add.w	#DEBase,d1
	move.w	d1,d0
	tst.w	FsFlag(a5)
	bne	FsError
	tst.w	EdDisk(a5)
	bne	EdDiskErr
	bra	RunErr
DiE2:	moveq	#DEBase+15,d0
	bra	RunErr
* Bad file format
DiForm:	moveq	#DEBase+16,d0
	bra	RunErr
* Table des erreurs reconnues
ErDisk:	dc.w 203,204,205,210,213,214,216,218
	dc.w 220,221,222,223,224,225,226,-1

***********************************************************

******* Charge et trouve le hunk
LHunk:	movem.l	a0/a1/d1/d2/d3,-(sp)
* Charge les 4 octets de debut!
	move.l	Buffer(a5),d2
	moveq	#4,d3
	bsr	ERead
	move.l	d2,a1
	move.l	(a1),d1
	lea	NHunk(pc),a0
	moveq	#1,d0
NHu1:	cmp.l	(a0)+,d1
	beq.s	NHu2
	addq.l	#1,d0
	tst.l	(a0)
	bne.s	NHu1
	moveq	#0,d0
NHu2:	movem.l	(sp)+,a0/a1/d1/d2/d3
	tst.w	d0
	rts
NHunk:	dc.b 	"AmBk"
	dc.b 	"AmSp"
	dc.b 	"AmBs"
	dc.b 	"AmIc"
	dc.l 	0
******* Sauve le hunk D0
SHunk:	movem.l	a0/d0/d2/d3,-(sp)
	lea	NHunk(pc),a0
	lsl.w	#2,d0
	lea	-4(a0,d0.w),a0
* Sauve le hunk
	move.l	a0,d2
	moveq	#4,d3
	bsr	FWrite
	movem.l	(sp)+,a0/d0/d2/d3
	rts

***********************************************************
*	SAVE a$,adresse-> sauver UNE banque memoire!
*******
Save2:	jsr	Par2
	move.l	(a3)+,d3
* Ouvre le fichier / Mode NEW
	bsr	NomDisk
	move.l	#1006,d2
	bsr	FOpen
	beq	DiskError
* Va sauver la banque
	bsr	SaveBk
	bsr	FClose
	bra	InsRet
******* Sauve toutes les banques
Save1:	jsr	Par1
	bsr	NomDisk
	move.l	#1006,d2
	bsr	FOpen
	beq	DiskError
	bsr	SaveBks
	bsr	FClose
	bra	InsRet
* Entete AMBS
SaveBks	moveq	#3,d0
	bsr	SHunk
* Nombre de banques
	move.l	ABanks(a5),a0
	moveq	#0,d7
	moveq	#15,d0
SvB1a:	tst.l	(a0)
	beq.s	SvB1b
	addq.w	#1,d7
SvB1b:	addq.l	#8,a0
	dbra	d0,SvB1a
	move.l	Buffer(a5),a2
	move.w	d7,(a2)
	move.l	a2,d2
	moveq	#2,d3
	bsr	FWrite
* Sauve les banques!
	move.l	ABanks(a5),a0
	moveq	#1,d3
SvB1c:	tst.l	(a0)
	beq.s	SvB1d
	movem.l	a0/d3,-(sp)
	bsr	SaveBk
	movem.l	(sp)+,a0/d3
SvB1d:	addq.l	#8,a0
	addq.w	#1,d3
	cmp.w	#16,d3
	bls.s	SvB1c
	rts

******* SAVE BANQUE D3
SaveBk:	cmp.l	#16,d3
	bhi	FonCall
	move.w	d3,d0
	lsl.w	#3,d0
	beq	FonCall
	move.l	ABanks(a5),a2
	move.l	-8(a2,d0.w),d2
	beq	BkNoRes
	move.l	-8+4(a2,d0.w),d7
	move.l	d2,a2
	move.l	(a2),d0
	cmp.l	BkSpr,d0
	beq.s	SvSp
	cmp.l	BkIco,d0
	beq.s	SvIc
******* Sauve une banque normale!
	moveq	#1,d0			* AmBk
	bsr	SHunk
	move.l	Buffer(a5),a0
	move.w	d3,(a0)			* Puis NUMERO.W
	clr.w	2(a0)			* 0-> CHIP / 1-> FAST
	bclr	#30,d7
	bne.s	SvBk0
	addq.w	#1,2(a0)
SvBk0:	move.l	d7,4(a0)		* Puis LONGUEUR.L
	move.l	a0,d2
	moveq	#8,d3
	bsr	FWrite
	move.l	a2,d2			* Puis banque en entier
	move.l	d7,d3
	and.l	#$0FFFFFFF,d3
	bra	FWrite
******* Sauve la banque d'icones
SvIc	moveq	#4,d0			* AmIc
	bra.s	SvIc1
******* Sauve la banque de sprites!
SvSp:	moveq	#2,d0			* AmSp
SvIc1	bsr	SHunk
	bsr	UnRevSp			* Remet les sprites droit...
	lea	8(a2),a2		* Nombre de sprites!
	move.l	a2,d2	
	moveq	#2,d3
	bsr	FWrite
	move.w	(a2)+,d6
	subq.w	#1,d6
	move.l	Buffer(a5),a0
	move.l	a0,d5
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	(a0)
SvSp1:	move.l	(a2),d0
	bne.s	SvSp2
* Sprite VIDE!
	move.l	d5,d2
	moveq	#10,d3
	bsr	FWrite
	bra.s	SvSp3
* Sauve un sprite!
SvSp2:	move.l	d0,a0
	move.l	d0,d2
	move.w	(a0)+,d3
	mulu	(a0)+,d3
	mulu	(a0)+,d3
	lsl.w	#1,d3
	add.l	#10,d3
	bsr	FWrite
* Suivant!
SvSp3:	addq.l	#8,a2
	dbra	d6,SvSp1
* Sauve la palette
	move.l	a2,d2
	moveq	#32*2,d3
	bsr	FWrite
* Ca y est!
	rts

******* Remet droit les sprites de la banque
UnRevSp	movem.l	d0-d7/a0-a6,-(sp)
	lea	8(a2),a2
	move.w	(a2)+,d2
	subq.w	#1,d2
	bmi.s	URbx
* Va retourner
URb1	move.l	a2,a1
	moveq	#0,d1
	EcCall	DoRev
* Remet le point chaud, si negatif!!!
	move.l	(a2),d0		
	beq.s	URb2
	move.l	d0,a0
	move.w	6(a0),d0
	lsl.w	#2,d0
	asr.w	#2,d0
	move.w	d0,6(a0)
URb2	lea	8(a2),a2
	dbra	d2,URb1
URbx	movem.l	(sp)+,d0-d7/a0-a6
	rts

***********************************************************
*	LOAD a$,banque-> charger UNE banque memoire!
*******
Load1:	jsr	Par1
	move.l	#EntNul,-(a3)
	bra.s	Load0
Load2:	jsr	Par2
Load0:	move.l	(a3)+,d3
	bsr	NomDisk
	move.l	#1005,d2
	bsr	FOpen
	beq	DiskError
* Va charger!
	bsr	LoadBk
	bsr	FClose
	jsr	SendBanks
	bra	InsRet

*******	LOAD BANQUE (s), en D3 si possible
LoadBk:	move.l	d3,d5
	bsr	LHunk
	cmp.w	#4,d0
	beq	LdIc
	cmp.w	#3,d0
	beq	LdBs
	cmp.w	#2,d0
	beq	LdSp
	cmp.w	#1,d0
	bne	DiForm
******* Banque normale
	move.l	Buffer(a5),d2
	move.l	d2,a2
	moveq	#8,d3
	bsr	ERead
	move.l	d5,d3
	cmp.l	#EntNul,d3
	bne.s	LdBk1
	move.w	(a2),d3
	ext.l	d3
LdBk1:	subq.w	#1,d3
	bmi	FonCall
	jsr	EffBank
	lsl.w	#3,d3
	move.l	ABanks(a5),a1
	lea	0(a1,d3.w),a1
	move.l	4(a2),d0
	move.l	d0,d1
	and.l	#$0FFFFFFF,d0
	move.l	d0,d3
	tst.w	2(a2)
	bne.s	LdBk2
	bset	#30,d1
	bsr	RamChip
	bra.s	LdBk3
LdBk2:	bclr	#30,d1
	bsr	RamFast
LdBk3:	beq	OOfMem
	move.l	d0,(a1)
	move.l	d1,4(a1)
	move.l	d0,d2
	bsr	ERead
	rts
******* Banque d'icones
LdIc	moveq	#2,d3			* Nombre de sprites
	move.l	Buffer(a5),d2
	move.l	d2,a2
	bsr	ERead
	move.w	(a2),d7
* Append?
	moveq	#1,d0
	move.w	d7,d1
	move.w	d5,d2
	clr.w	d5
	tst.w	d2
	beq.s	LdIc1
	move.l	ABanks(a5),a0
	tst.l	8(a0)
	beq.s	LdIc1
	move.w	8+6(a0),d5
	subq.w	#8,d5
	beq.s	LdIc1
	add.w	d5,d1
	moveq	#0,d0
LdIc1:	jsr	ResIco
	bne	OOfMem
	bra.s	LdIc2
******* Banque de sprites
LdSp:	moveq	#2,d3			* Nombre de sprites
	move.l	Buffer(a5),d2
	move.l	d2,a2
	bsr	ERead
	move.w	(a2),d7
* Append?
	moveq	#1,d0
	move.w	d7,d1
	move.w	d5,d2
	clr.w	d5
	tst.w	d2
	beq.s	LdSp1
	move.l	ABanks(a5),a0
	tst.l	(a0)
	beq.s	LdSp1
	move.w	6(a0),d5
	subq.w	#8,d5
	bmi.s	LdSp1
	add.w	d5,d1
	moveq	#0,d0
LdSp1:	jsr	ResSpr
	bne	OOfMem
* Fin du chargement SPRITES/ICONES
LdIc2:	addq.l	#2,a1
	tst.w	d5			* Pointe le debut des nouveaux!
	beq.s	LdSp2
	lsl.w	#3,d5
	add.w	d5,a1
LdSp2:	move.l	Buffer(a5),a2
* Charge tous les sprites
	tst.w	d7			* Pas de sprite?
	beq.s	LdSp5
	clr.w	d6
LdSp3:	clr.l	(a1)+
	clr.l	(a1)+
	move.l	a2,d2
	moveq	#10,d3
	bsr	ERead
	move.w	(a2),d0
	beq.s	LdSp4
	mulu	2(a2),d0
	mulu	4(a2),d0
	lsl.l	#1,d0
	move.l	d0,d3
	add.l	#10,d0
	bsr	RamChip
	beq	OOfMem
	move.l	d0,-8(a1)		* Poke le pointeur
	clr.l	-4(a1)
	move.l	d0,a0			* Poke les entetes
	move.l	(a2),(a0)+		* TX/TY
	move.w	4(a2),(a0)+
	move.w	6(a2),(a0)		* Plus de FLAGS!
	and.w	#$3FFF,(a0)+
	move.w	8(a2),(a0)+
	move.l	a0,d2			* Charge l'image
	bsr	ERead
LdSp4:	addq.w	#1,d6
	cmp.w	d7,d6
	bcs.s	LdSp3
* Charge la palette
LdSp5:	move.l	a1,d2
	moveq	#32*2,d3
	bsr	ERead
	rts

******* Charge plusieurs banques
LdBs:	jsr	EffAllBanks
	move.l	Buffer(a5),d2
	move.l	d2,a2
	moveq	#2,d3
	bsr	ERead
	move.w	(a2),d0
	beq.s	LdBs2
* Charge!
	move.w	d0,-(sp)
LdBs1:	move.l	#EntNul,d3
	bsr	LoadBk
	subq.w	#1,(sp)
	bne.s	LdBs1
	addq.l	#2,sp
LdBs2:	rts

***********************************************************
*	PLOAD PRG nom,bank
PLoad:
*******
	jsr	Par2
* Banque
	clr.w	d4
	move.l	(a3)+,d3
	bpl.s	Plo3
	neg.l	d3
	addq.w	#1,d4
Plo3	subq.l	#1,d3
	cmp.l	#$10,d3
	bcc	FonCall
	jsr	EffBank
	lsl.w	#3,d3
	move.l	ABanks(a5),a2
	pea	0(a2,d3.w)
	move.w	d4,-(sp)
* Nom disque
	bsr	NomDisk
	move.l	#1005,d2
	bsr	FOpen
* Saute les premiers HUNKS!
	bsr	GetH
	cmp.l	#$3F3,d0
	bne	DiForm
Plo0	bsr	GetH
	cmp.l	#$3E9,d0
	bne.s	Plo0
	bsr	GetH
	lsl.l	#2,d0
	move.l	d0,d3
	addq.l	#8,d0
	move.l	d0,d1
* Reserve la banque
	tst.w	(sp)+
	bne.s	Plo1
	bsr	RamFast
	bra.s	Plo2
Plo1	bset	#30,d1
	bsr	RamChip
Plo2	beq	OOfMem
	move.l	(sp)+,a2
	move.l	d0,(a2)+
	bset	#31,d1
	move.l	d1,(a2)+
	move.l	d0,a1
	lea	BkAsm,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
* Charge!
	move.l	a1,d2
	bsr	FRead
	bsr	FClose
	bra	InsRet
******* ROUTINE
GetH	move.l	Buffer(a5),d2
	moveq	#4,d3
	bsr	FRead
	move.l	Buffer(a5),a0
	move.l	(a0),d0
	rts

***********************************************************
*	BLOAD a$,adresse
BLoad:
*******
	jsr	Par2
	jsr	AdOuBank
	move.l	d3,-(sp)
* Ouvre le fichier
	bsr	NomDisk
	move.l	#1005,d2
	bsr	FOpen
	beq	DiskError
* Trouve la taille du fichier!
	moveq	#0,d2
	moveq	#1,d3
	bsr	FSeek
	moveq	#0,d2
	moveq	#-1,d3
	bsr	FSeek
* Charge!
	move.l	d0,d3
	move.l	(sp)+,d2
	bsr	ERead
* Ferme!
	bsr	FClose
	bra	InsRet

***********************************************************
*	BSAVE a$,adresse to fin
BSave:
*******
	moveq	#3,d0
	jsr	ParD0
	move.l	(a3)+,-(sp)
	jsr	AdOuBank
	sub.l	d3,(sp)
	bls	FonCall
	move.l	d3,-(sp)
* Ouvre le fichier / Mode NEW
	bsr	NomDisk
	move.l	#1006,d2
	bsr	FOpen
	beq	DiskError
* Sauve!
	move.l	(sp)+,d2
	move.l	(sp)+,d3
	bsr	FWrite
* Ferme!
	bsr	FClose
	bra	InsRet

***********************************************************
*	LOAD IFF "nom"
LdIff1:	
*******
	jsr	Evalue
	move.l	d3,-(a3)
	move.l	#EntNul,-(a3)
	bra.s	LdIff
***********************************************************
*	LOAD IFF "nom",param
LdIff2:
*******
	jsr	Par2
* Inits
LdIff:	bsr	IffInit
	move.l	(a3)+,IffParam(a5)
* Ouvre le fichier
	bsr	NomDisk
	move.l	#1005,d2
	bsr	FOpen
	beq	DiskError
* Lis les chunks
LdIfa:	bsr	IffLoad
	bne.s	LdIfa
* Ferme le fichier
	bsr	FClose
* Ca y est!
	bra	InsRet

******* Initialisation des flags IFF
IffInit	clr.l	IffFlag(a5)
	rts

******* Charge un CHUNK ou une FORM
IffLoad	move.l	Buffer(a5),d2
	moveq	#8,d3
	bsr	FRead
	beq.s	IffEnd
	bmi	DiskError
	move.l	d2,a0
	move.l	DForm(pc),d0
	cmp.l	(a0),d0
	bne	IffChunk
* Explore les headers!
	addq.l	#8,d2			* Charge le type de fichier
	moveq	#4,d3
	bsr	FRead
	beq	DiskError
	bmi	DiskError
	move.l	d2,a0
	lea	Form(pc),a1
	bsr	GetIff
	bmi	SoChunk			* Inconnu: saute le tout!
* Iff encore
IffOk:	moveq	#-1,d1
	rts
* Iff fini!
IffEnd:	moveq	#0,d1
	rts

******* CHARGE UN CHUNK
IffChunk:
	move.l	d2,a0
	lea	Chunks(pc),a1
	bsr	GetIff
	bmi.s	SoChunk
	move.l	IffMask(a5),d1		* Peut charger le chunk?
	btst	d0,d1
	beq.s	SoChunk
	move.w	d0,-(sp)		* Met les flags
	move.l	IffFlag(a5),d1
	bset	d0,d1
	move.l	d1,IffFlag(a5)
	move.l	4(a0),d3
	lsl.w	#2,d0
	lea	IffJumps(pc),a0
	jsr	0(a0,d0.w)
	move.w	(sp)+,d0
	bra	IffOk
* Saute le FORM/CHUNK inconnu
SoChunk:move.l	Buffer(a5),a0
	move.l	4(a0),d2
	bsr	D2Pair
	moveq	#0,d3
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	DosSeek(a6)
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	bmi	IffEnd
	moveq	#-1,d0
	bra	IffOk

******* BMHD!
IffBMHD:move.l	BufBMHD(a5),d2
FinBM:	bsr	ERead
* Rend pair
	and.l	#$01,d3
	beq.s	FinBM1
	moveq	#1,d2
	moveq	#0,d3
	bsr	FSeek
FinBM1:	rts
******* CMAP!
IffCMAP:move.l	BufCMAP(a5),a0
	move.w	d3,d0
	divu	#3,d0
	move.w	d0,(a0)+
	move.l	a0,d2
	bra.s	FinBM
******* CAMG
IffCAMG:move.l	BufCAMG(a5),d2
	bra.s	FinBM	
******* CCRT
IffCCRT:move.l	BufCCRT(a5),d2
	bra.s	FinBM	
******* AMSC
IffAMSC:move.l	BufAMSC(a5),d2
	bra.s	FinBM

******* BODY
IffBODY	
* Stocke fin du CHUNK body!
	bsr	D3Pair
	move.l	d3,-(sp)
	moveq	#0,d2
	moveq	#0,d3
	bsr	FSeek
	add.l	(sp),d0
	move.l	d0,-(sp)
	cmp.l	#EntNul,IffParam(a5)
	beq.s	IffB1
* Fabrique l'ecran!
	bsr	IffScreen
	beq	IffFor
	move.l	IffParam(a5),d1
	cmp.l	#8,d1
	bcc	GIllScN
	lea	DefPal(a5),a1
	EcCall	Cree
	bne	EcWiErr
	move.l	a0,ScOnAd(a5)
	move.w	EcNumber(a0),ScOn(a5)
	addq.w	#1,ScOn(a5)
	bsr	IffCentre
* Termine!
IffB1:	tst.w	ScOn(a5)
	beq	GScNOp
	bsr	IffPal
	bsr	IffShift
* Charge les plans de bits
IffB2:	moveq	#0,d1			* Trouve l'adresse ecran
	move.w	ScOn(a5),d1
	subq.w	#1,d1
	bmi	GScNOp
	EcCall	Active
	move.l	a0,a2
	move.l	IffFlag(a5),d7		* BMHD charge?
	btst	#0,d7
	beq	FonCall
	move.l	BufBMHD(a5),a1
* Regarde si l'image n'est pas + grande que l'ecran!
	move.w	(a1),d5			* Largeur du dessin
	ext.l	d5
	cmp.w	EcTx(a2),d5
	bhi	CantFit
	lsr.w	#3,d5
	move.w	2(a1),d6		* Hauteur du dessin
	cmp.w	EcTy(a2),d6
	bls	IffB3
	move.w	EcTy(a2),d6
IffB3:	move.b	8(a1),d7		* Nombre de plans
	ext.w	d7
	cmp.w	EcNPlan(a2),d7
	bhi	CantFit
	subq.w	#1,d7
* Enleve le curseur
	movem.l	a0-a6/d0-d7,-(sp)
	ALea	ChCuOff,a1
	WiCall	Print
	movem.l	(sp)+,a0-a6/d0-d7
* Format compresse?
	tst.b	10(a1)
	bne.s	BodyC
* Pas de compression
	move.l	d5,d3
	move.w	d7,d5
	subq.w	#1,d6
	moveq	#0,d4
Bd2:	lea	EcLogic(a2),a0
	move.w	d5,d7
Bd3:	move.l	(a0)+,d2
	add.l	d4,d2
	bsr	ERead
	dbra	d7,Bd3
	move.w	EcTLigne(a2),d0
	ext.l	d0
	add.l	d0,d4
	dbra	d6,Bd2
	bra	FinBODY
* Compression! BYTE RUN 1
BodyC:	cmp.b	#1,10(a1)
	bne	IffCmp
* Regarde si peut travailler dans un buffer
	movem.l	a3-a6,-(sp)
	move.l	16+4(sp),d0
	bsr	RamFast
	tst.l	d0
	beq	Br0	
	move.l	d0,a3
	move.l	d0,a1
	move.l	d0,d2
	move.l	16+4(sp),d3
	bsr	FRead
	beq.s	BBErr
	bmi.s	BBErr
	cmp.l	d0,d3
	bne.s	BBErr
******* Travaille avec un buffer
	move.w	d7,d3
	move.w	d6,d2
	subq.w	#1,d2
	moveq	#0,d6
Bb2:	lea	EcLogic(a2),a6
	move.w	d3,d7
Bb3:	move.l	(a6)+,a4
	add.l	d6,a4
	moveq	#0,d4
Bb4:	moveq	#0,d0
	move.b	(a3)+,d0
	bmi.s	Bb5
* Lire N octets decodes
	add.w	d0,d4
	addq.w	#1,d4
Bb4a:	move.b	(a3)+,(a4)+
	dbra	d0,Bb4a
	bra.s	Bb7
* Repeter N fois...
Bb5:	cmp.b	#128,d0
	beq.s	Bb7
	move.b	(a3)+,d1
	neg.b	d0
	add.w	d0,d4
	addq.w	#1,d4
Bb6:	move.b	d1,(a4)+
	dbra	d0,Bb6
* Encore pour la ligne?
Bb7:	cmp.w	d5,d4
	bcs.s	Bb4
* Encore un plan?
	dbra	d7,Bb3
* Encore une ligne?
	move.w	EcTLigne(a2),d0
	ext.l	d0
	add.l	d0,d6
	dbra	d2,Bb2
* Libere le buffer
	movem.l	(sp)+,a3-a6
	move.l	4(sp),d0
	bsr	RamFree
	bra	FinBody
* ERREUR DISQUE! Libere le buffer
BBerr:	movem.l	(sp)+,a3-a6
	move.l	4(sp),d0
	bsr	RamFree
	bra	DiskError
******* Travaille directement dans l'ecran
Br0:	move.w	d7,-(sp)
	move.w	d6,d1
	subq.w	#1,d1
	move.l	Buffer(a5),a3
	moveq	#0,d6
Br2:	lea	EcLogic(a2),a6
	move.w	(sp),d7
Br3:	move.l	(a6)+,a4
	add.l	d6,a4
	moveq	#0,d4
Br4:	move.l	a3,d2
	moveq	#1,d3
	bsr	ERead
	move.b	(a3),d3
	bmi.s	Br5
* Lire N octets decodes
	addq.l	#1,d3
	move.l	a4,d2
	add.w	d3,d4
	add.w	d3,a4
	bsr	ERead
	bra.s	Br7
* Repeter N fois...
Br5:	cmp.b	#128,d3
	beq.s	Br7
	move.w	d3,-(sp)
	moveq	#1,d3
	move.l	a3,d2
	bsr	ERead
	move.b	(a3),d2
	move.w	(sp)+,d0
	neg.b	d0
	add.w	d0,d4
	addq.w	#1,d4
Br6:	move.b	d2,(a4)+
	dbra	d0,Br6
* Encore pour la ligne?
Br7:	cmp.w	d5,d4
	bcs.s	Br4
* Encore un plan?
	dbra	d7,Br3
* Encore une ligne?
	move.w	EcTLigne(a2),d0
	ext.l	d0
	add.l	d0,d6
	dbra	d1,Br2
	addq.l	#2,sp
	movem.l	(sp)+,a3-a6
* Fin du BODY: saute le CHUNK
FinBody move.l	(sp)+,d2
	addq.l	#4,sp
	moveq	#-1,d3
	bsr	FSeek
	rts
CantFit	moveq	#32,d0
	bra	RunErr
IffFor:	moveq	#30,d0
	bra	RunErr
IffCmp:	moveq	#31,d0
	bra	RunErr
GIllScN	jmp	IllScN

******* Fabrique l'ecran avec les donnees
IffScreen:
* Peut-on fabriquer un ecran?
	move.l	IffFlag(a5),d7
	btst	#0,d7		* Une BMHD?
	beq	IffEnd
* Parametre?
	moveq	#0,d5
	move.l	BufBMHD(a5),a0
	move.w	0(a0),d2	* Largeur, MOT superieur!
	add.w	#15,d2
	and.w	#$FFF0,d2
	ext.l	d2
	move.w	2(a0),d3	* Hauteur
	ext.l	d3
	move.b	8(a0),d4	
	ext.w	d4		* Nb plans
	ext.l	d4
	moveq	#2,d6		* Calcule le nb de couleurs
	move.w	d4,d0
IfS0:	subq.w	#1,d0
	beq.s	IfS0a
	lsl.w	#1,d6
	bra.s	IfS0
* Trouve les modes graphiques
IfS0a:	moveq	#0,d5	

*	moveq	#0,d0		* Analyse du ratio HAUTEUR/LARGEUR
*	move.b	14(a0),d0
*	beq.s	IfS0b
*	lsl.w	#8,d0
*	moveq	#0,d1
*	move.b	15(a0),d1
*	beq.s	IfS0b
*	divu	d1,d0
*	cmp.w	#174,d0
*	bcc.s	IfS0b
*	bset	#2,d5
*IfS0b	cmp.w	#348,d0
*	bcc.s	IfS0c

	cmp.w	#640,16(a0)
	bcs.s	IfS0d
IfS0c	cmp.w	#4,d4
	bhi.s	IfS0d
	bset	#15,d5
IfS0d	cmp.w	#400,18(a0)
	bcs.s	IfS0e
	bset	#2,d5
IfS0e	
* CAMG chunk
	btst	#1,d7
	beq.s	IfS5
	moveq	#0,d5
	move.l	BufCAMG(a5),a0	* Modes graphiques
	move.l	(a0),d0
IfS1:	btst	#11,d0			* HAM?
	beq.s	IfS2
	moveq	#6,d4
	move.w	#$0800,d5
	moveq	#64,d6
IfS2:	and.w	#%1000000000000100,d0	* HIRES? INTERLACED?
	or.w	d0,d5
IfS5:	bra	IffOk

******* Centre l'ecran IFF dans l'ecran
IffCentre:
* Prend les parametres de l'IMAGE
	moveq	#0,d1			* Trouve l'adresse ecran
	move.w	ScOn(a5),d1
	subq.w	#1,d1
	bmi	GScNOp
	EcCall	Active
* Un chunk AMSC?
	btst	#5,d7
	beq	IffEnd
	move.l	a0,a1
	move.l	BufAMSC(a5),a0
	move.w	(a0)+,EcAWX(a1)
	move.w	(a0)+,EcAWY(a1)
	move.w	(a0)+,EcAWTX(a1)
	move.w	(a0)+,EcAWTY(a1)
	move.w	(a0)+,EcAVX(a1)
	move.w	(a0)+,EcAVY(a1)
	move.w	(a0)+,EcFlags(a1)
	moveq	#6,d0
	move.b	d0,EcAW(a1)
	move.b	d0,EcAWT(a1)
	move.b	d0,EcAV(a1)
	bset	#BitEcrans,T_Actualise(a5)
	rts
GScNOp	jmp	ScNOp

******* Fait shifter les couleurs
IffShift:
	move.l	IffFlag(a5),d7
	btst	#3,d7
	beq.s	IffShX
	move.l	BufCCRT(a5),a0
	move.w	(a0),d5
	beq.s	IffShX
	bpl.s	IffSh0
	moveq	#0,d5
IffSh0	move.b	2(a0),d3
	bmi.s	IffShX
	ext.w	d3
	move.b	3(a0),d4
	bmi.s	IffShX
	ext.w	d4
	cmp.w	d4,d3
	bcc.s	IffShX
	move.l	8(a0),d2		* 1/1000 ---> 1/50
	divu	#20,d2
	tst.w	d2
	beq.s	IffShX
	moveq	#1,d1
	moveq	#1,d6			* Boucle!
	EcCall	Shift
	bne	EcWiErr
IffShX:	rts

******* Recupere la palette IFF
IffPal:	lea	DefPal(a5),a2
	move.l	Buffer(a5),a0
	move.l	a0,a1
	moveq	#31,d0
IfSa:	move.w	(a2)+,(a0)+
	dbra	d0,IfSa
	move.l	IffFlag(a5),d7
	btst	#2,d7
	beq	IfSc
	move.l	a1,a0
	move.l	BufCMAP(a5),a2
	move.w	(a2)+,d0
	subq.w	#1,d0
IfSb:	clr.w	d1
	move.b	(a2)+,d1
	lsl.w	#4,d1
	or.b	(a2)+,d1
	lsl.w	#4,d1
	or.b	(a2)+,d1
	lsr.w	#4,d1
	move.w	d1,(a0)+
	dbra	d0,IfSb
IfSc:	EcCall	SPal
	rts

******* EXPLORE LES NOMS IFF (a0)<->(a1)
GetIff:	moveq	#-1,d0
	move.l	(a0),d1
Giff1:	tst.b	(a1)
	bmi.s	Giff2
	addq.l	#1,d0
	cmp.l	(a1)+,d1
	bne.s	Giff1
	tst.l	d0
Giff2:	rts

******* D1 pair
D1Pair:	btst	#0,d1
	beq.s	D1p
	addq.l	#1,d1
D1p:	rts
******* D2 pair
D2Pair:	btst	#0,d2
	beq.s	D2p
	addq.l	#1,d2
D2p:	rts
******* D3 pair
D3Pair:	btst	#0,d3
	beq.s	D3p
	addq.l	#1,d3
D3p:	rts

******* DEBUT IFF
DForm:	dc.b "FORM"
******* FORMES iff
Form:	dc.b "ILBM"
	dc.b -1
	even
******* CHUNKS iff
Chunks:	dc.b "BMHD","CAMG","CMAP","CCRT","BODY"
	dc.b "AMSC"
	dc.b -1
	even
******* Table des sauts
IffJumps:
	bra	IffBMHD
	bra	IffCAMG
	bra	IffCMAP
	bra	IffCCRT
	bra	IffBODY
	bra	IffAMSC

***********************************************************
DScNOp	moveq	#3,d0
	bra	EcWiErr
******* SCREEN SAVE a$,compress
ScSave2	jsr	Par2
	move.l	(a3)+,d7
	cmp.l	#2,d7
	bcc	FonCall
	bra.s	ScSave
*******	SCREEN SAVE a$
ScSave1 jsr	Par1
	moveq	#1,d7
ScSave	move.l	ScOnAd(a5),d0
	beq	DScNOp
	move.l	d7,-(sp)
	move.l	d0,-(sp)
* Ouvre le fichier / Mode NEW
	bsr	NomDisk
	move.l	#1006,d2
	bsr	FOpen
	beq	DiskError
* Sauve!
	move.l	(sp)+,a2
	move.l	(sp)+,d7
	move.l	Buffer(a5),a1
	lea	DForm(pc),a0
	move.l	(a0)+,(a1)+		* FORM
	clr.l	(a1)+			* Espace
	move.l	(a0)+,(a1)+		* ILBM
	bsr	SaveA1
	bsr	SaveBMHD
	bsr	SaveCAMG
	bsr	SaveAMSC
	bsr	SaveCMAP
	bsr	SaveBODY
	moveq	#-1,d3
	moveq	#4,d2
	bsr	FSeek
	subq.l	#8,d0
	move.l	Buffer(a5),a1
	move.l	d0,(a1)+
	bsr	SaveA1
* Ferme
	bsr	FClose
	bra	InsRet

******* Sauve le BMHD
SaveBMHD
	move.l	Buffer(a5),a1
	move.l	Chunks(pc),(a1)+
	move.l	#20,(a1)+
	move.w	EcTx(a2),(a1)+
	move.w	EcTy(a2),(a1)+
	clr.w	(a1)+
	clr.w	(a1)+
	move.b	EcNPlan+1(a2),(a1)+
	clr.b	(a1)+
	move.b	d7,(a1)+
	clr.b	(a1)+
	clr.w	(a1)+
	moveq	#20,d0
	moveq	#22,d1
	move.w	EcWTX(a2),d2
	move.w	EcWTY(a2),d3
	move.w	EcCon0(a2),d4
	bpl.s	Sbmhd1
	lsr.w	#1,d0
	lsl.w	#1,d2
Sbmhd1	btst	#2,d4
	beq.s	Sbmhd2
	lsr.w	#1,d1
	lsl.w	#1,d3
Sbmhd2	move.b	d0,(a1)+
	move.b	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	bra	SaveA1
******* Sauve la CMAP
SaveCMAP
	move.l	Buffer(a5),a1
	move.l	Chunks+4*2(pc),(a1)+
	move.l	#32*3,(a1)+
	moveq	#31,d0
	lea	EcPal(a2),a0
SCm1	move.w	(a0)+,d1
	lsl.w	#4,d1
	moveq	#2,d2
SCm2	rol.w	#4,d1
	move.w	d1,d3
	and.w	#$000F,d3
	lsl.w	#4,d3
	move.b	d3,(a1)+
	dbra	d2,SCm2
	dbra	d0,SCm1
	bra	SaveA1
******* Sauve de CAMG
SaveCAMG
	move.l	Buffer(a5),a1
	move.l	Chunks+4*1(pc),(a1)+
	move.l	#4,(a1)+
	moveq	#0,d0
	move.w	EcCon0(a2),d0
	and.w	#%1000100000000110,d0
	cmp.w	#64,EcNbCol(a2)
	bne.s	SCa
	btst	#11,d0
	bne.s	SCa
	bset	#7,d0
SCa	move.l	d0,(a1)+
	bra	SaveA1
******* Sauve le AMSC
SaveAMSC
	move.l	Buffer(a5),a1
	move.l	Chunks+4*5(pc),(a1)+
	move.l	#7*2,(a1)+
	move.w	EcAWX(a2),(a1)+
	move.w	EcAWY(a2),(a1)+
	move.w	EcAWTx(a2),(a1)+
	move.w	EcAWTy(a2),(a1)+	
	move.w	EcAVX(a2),(a1)+
	move.w	EcAVY(a2),(a1)+
	move.w	EcFlags(a2),d0
	and.w	#$8000,d0
	move.w	d0,(a1)+
	bra	SaveA1
******* Sauve le BODY
SaveBODY
	move.l	Buffer(a5),a1
	move.l	Chunks+4*4(pc),(a1)+
	tst.b	d7
	bne.s	SBc
* Non compacte
	move.l	EcTPlan(a2),d0		* Entete
	mulu	EcNPlan(a2),d0
	move.l	d0,(a1)+
	bsr	SaveA1
	move.w	EcTy(a2),d7		* Image
	moveq	#0,d3
	move.w	EcTLigne(a2),d3
	moveq	#0,d4
SBo1	move.w	EcNPlan(a2),d6
	lea	EcLogic(a2),a0
SBo2	move.l	(a0)+,d2
	add.l	d4,d2
	bsr	FWrite
	subq.w	#1,d6
	bne.s	SBo2
	add.l	d3,d4
	subq.w	#1,d7
	bne.s	SBo1
	rts
* Compacte!
SBc:	clr.l	(a1)+
	bsr	SaveA1
	moveq	#0,d2			* Position dans le fichier
	moveq	#0,d3
	bsr	FSeek
	move.l	d0,-(sp)
	moveq	#0,d7
	move.w	EcTy(a2),d6
	moveq	#0,d5
	move.w	EcTLigne(a2),d5
	moveq	#0,d4
	move.l	a3,-(sp)
	move.w	EcNPlan(a2),-(sp)
	pea	EcLogic(a2)
SBc1	move.l	(sp),a2
	move.w	4(sp),d3
	move.l	Buffer(a5),a1
SBc2	move.w	d5,d2
	move.l	(a2)+,a0
	add.l	d4,a0
SBc3	moveq	#0,d1			
	move.b	(a0)+,d0
	subq.w	#1,d2
	beq.s	SBc5a
SBc4	cmp.b	(a0),d0
	bne.s	SBc5
	addq.l	#1,d1
	addq.l	#1,a0
	cmp.w	#127,d1
	bcc.s	SBc5
	subq.w	#1,d2
	bne.s	SBc4
SBc5	tst.w	d1
	beq.s	SBc6
	neg.b	d1
	move.b	d1,(a1)+
	move.b	d0,(a1)+
	tst.w	d2
	bne.s	SBc3
	bra.s	SBc10
SBc5a	clr.b	(a1)+
	move.b	d0,(a1)+
	bra.s	SBc10
SBc6	move.l	a1,a3
	moveq	#0,d1
	clr.b	(a1)+
	move.b	d0,(a1)+
SBc7	move.b	(a0),d0
	cmp.b	1(a0),d0
	bne.s	SBc8
	cmp.b	2(a0),d0
	beq.s	SBc9
SBc8	move.b	(a0)+,(a1)+
	addq.w	#1,d1
	subq.w	#1,d2
	beq.s	SBc9
	cmp.w	#127,d1
	bcs.s	SBc7
SBc9	move.b	d1,(a3)
	tst.w	d2
	bne.s	SBc3
* Autre plan?
SBc10	subq.w	#1,d3
	bne.s	SBc2
* Sauve le buffer
	move.l	Buffer(a5),d2
	move.l	a1,d3
	sub.l	d2,d3
	add.l	d3,d7
	bsr	FWrite
* Encore une ligne?
	add.l	d5,d4
	subq.w	#1,d6
	bne	SBc1
* A y est!
	addq.l	#6,sp
	move.l	(sp)+,a3
* Rend le chunk pair
	btst	#0,d7
	beq.s	SBc11
	move.l	Buffer(a5),a1
	clr.b	(a1)
	move.l	a1,d2
	moveq	#1,d3
	bsr	FWrite
	addq.l	#1,d7
* Marque la longueur du chunk!
SBc11	move.l	(sp)+,d2		* Debut du chunk
	subq.l	#4,d2
	moveq	#-1,d3
	bsr	FSeek
	move.l	d0,-(sp)
	move.l	Buffer(a5),a1		* Sauve la longueur
	move.l	d7,(a1)
	move.l	a1,d2
	moveq	#4,d3
	bsr	FWrite
	move.l	(sp)+,d2		* Remet a la fin
	moveq	#-1,d3
	bsr	FSeek
	rts

******* Sauve jusqu'a A1
SaveA1	move.l	Buffer(a5),d2
	move.l	a1,d3
	sub.l	d2,d3
	bne	FWrite
	rts

***********************************************************
*	=DIR$=
* Fonction
FDir:	moveq	#126,d3
	bsr	Demande
	move.l	PathAct(a5),a2
	tst.b	(a2)
	bne.s	.Skip
* Si pas de path courant, demande le path reel
	movem.l	a0/a1,-(sp)
	bsr	AskDir
	movem.l	(sp)+,a0/a1
	move.l	Buffer(a5),a2
	lea	384(a2),a2
* Copie
.Skip	clr.w	(a1)+
FDi1	move.b	(a2)+,(a1)+
	bne.s	FDi1
	move.l	a1,d0
	sub.l	a0,d0
	btst	#0,d0
	beq.s	FDi2
	addq.l	#1,a1
FDi2	move.l	a1,HiChaine(a5)
	subq.w	#3,d0
	move.w	d0,(a0)
	move.l	a0,d3
	moveq	#2,d2
	jmp	OpeRet
*** Instruction
IDir:	addq.l	#2,a6
	jsr	Par1
	bsr	NomDisk
	bsr	LockGet
	move.l	LockSave(a5),d1
	move.l	Buffer(a5),d2
	moveq	#DosExam,d7
	bsr	DosCall
	move.l	d2,a0
	tst.w	4(a0)
	bmi	DiskError
	move.l	LockSave(a5),d0
	bsr	AskDir2
	bsr	LockFree
	bsr	CopyPath
	bra	InsRet

***********************************************************
*	PARENT
IPar	move.l	PathAct(a5),a0
	tst.b	(a0)
	bne.s	.Loop
	bsr	AskDir
	bsr.s	CopyPath
	move.l	PathAct(a5),a0
.Loop	tst.b	(a0)+
	bne.s	.Loop
	subq.l	#1,a0
	cmp.b	#"/",-(a0)
	bne.s	.Out
.Loop1	move.b	-(a0),d0
	cmp.b	#"/",d0
	beq.s	.Skip1
	cmp.b	#":",d0
	bne.s	.Loop1
.Skip1	clr.b	1(a0)
.Out	bra 	InsRet
** Copie le path dans PATHACT
CopyPath
	move.l	Buffer(a5),a0
	lea	384(a0),a0
	move.l	PathAct(a5),a1
.Loop	move.b	(a0)+,(a1)+
	bne.s	.Loop
	rts
***********************************************************
*	KILL a$
IKill	jsr	Par1
	bsr	NomDisk
	move.l 	Name1(a5),d1
	move.w	#DosDel,d7
	bsr	DosCall
	tst.l	d0
	bne	InsRet
	bra	DiskError
***********************************************************
*	RENAME a$ TO a$
IRen	jsr	Par2
	bsr	NomDisk
	move.l	Name1(a5),a0
	move.l	Name2(a5),a1
IRen1	move.b	(a0)+,(a1)+
	bne.s	IRen1
	bsr	NomDisk
	move.l	Name1(a5),d1
	move.l	Name2(a5),d2
	move.w	#DosRen,d7
	bsr	DosCall
	tst.l	d0
	bne	InsRet
	bra	DiskError
***********************************************************
*	MKDIR a$
IMkDir	bsr	LockFree
	jsr	Par1
	bsr	NomDisk
	move.l	Name1(a5),d1
	move.w	#DosMkDir,d7
	bsr	DosCall
	beq	DiskError
	move.l	d0,LockSave(a5)
	bsr	LockFree
	bra	InsRet	
***********************************************************
*	=DFREE
FDFree	move.l	PathAct(a5),a0
	move.l	Name1(a5),a1
	bsr	CoCop
	bsr	LockGet
	move.l	Buffer(a5),d2
	addq.l	#4,d2
	lsr.l	#2,d2
	lsl.l	#2,d2
	move.l	d2,-(sp)
	move.w	#DosInfo,d7
	bsr	DosCall
	beq	DiskError
	move.l	(sp)+,a0
	move.l	12(a0),d3
	sub.l	16(a0),d3
	move.l	20(a0),d6
	jsr	Mul32
	move.l	d1,d3
	moveq	#0,d2
	bsr	LockFree
	jmp	OpeRet

******* DISC INFO! Nouveau!!!
FDInfo
	jsr	Par1
	moveq	#126,d3
	bsr	Demande
	move.l	a0,-(sp)
	bsr	NomDisk
	bsr	LockGet
	move.l	LockSave(a5),d1
	move.l	Buffer(a5),d2
	move.w	#DosInfo,d7
	bsr	DosCall
	beq	DiskError
	bsr	LockFree
	move.l	(sp),a0
	addq.w	#2,a0
	move.l	Buffer(a5),a2
	move.l	12(a2),d3
	sub.l	16(a2),d3
	move.l	20(a2),d6
	jsr	Mul32
	move.l	d1,d3
	moveq	#0,d6
	move.l	28(a2),d0
	beq.s	.skip
	lsl.l	#2,d0
	move.l	d0,a2
	move.l	$28(a2),d0
	beq.s	.skip
	lsl.l	#2,d0
	move.l	d0,a2
	addq.l	#1,a2
.loop	addq.w	#1,d6
	move.b	(a2)+,(a0)+
	bne.s	.loop
	move.b	#":",-1(a0)
.skip	move.l	a0,a1
	moveq	#9,d0
.loop1	move.b	#32,(a1)+
	dbra	d0,.loop1
	add.w	#10,d6
	move.l	d3,d0
	jsr	LongDec
	move.l	(sp)+,a0
	move.w	d6,(a0)
	move.l	a0,d3
	addq.w	#1,d6
	and.w	#$FFFE,d6
	lea	2(a0,d6.w),a0
	move.l	a0,HiChaine(a5)
	moveq	#2,d2
	bra	Operet
***********************************************************
******* Trouve le descripteur fichier
GetFile	move.l	(a3)+,d0
	cmp.l	#10,d0
	bcc	FonCall
	subq.l	#1,d0
	bmi	FonCall
	mulu	#TFiche,d0
	lea	Fichiers(a5),a2
	add.w	d0,a2
	move.l	Fha(a2),d1
	rts
******* Nettoie le descripteur
FiClean	movem.l	a0/d0,-(sp)
	move.l	a2,a0
	moveq	#TFiche-1,d0
Ficl	clr.b	(a0)+
	dbra	d0,Ficl
	movem.l	(sp)+,a0/d0
	rts
******* GetByte (a2)
GetByte	movem.l	a0/a1/d1-d4,-(sp)
	btst	#1,FhT(a2)
	beq	FilTM
	btst	#2,FhT(a2)
	beq.s	GBy2
* PORT--> Attend un caractere en gerant les interruptions...
GBy1	move.w	#DosWChar,d7
	move.l	Fha(a2),d1
	moveq	#50,d2
	bsr	DosCall
	tst.l	d0
	bne.s	GBy1a
	bsr	Tests
	bra.s	GBy1
GBy1a	move.l	FhA(a2),d1
	lea	DeFloat(a5),a0
	addq.l	#8,a0
	move.l	a0,d2
	move.l	a0,-(sp)
	moveq	#1,d3
	move.w	#DosRead,d7
	bsr	DosCall
	tst.l	d0
	beq	EOFil
	bmi	DiskError
	move.l	(sp)+,a0
	move.b	(a0),d0
	bra.s	EByE
* Va prendre le caractere
GBy2	move.l	FhA(a2),d1
	lea	DeFloat(a5),a0
	cmp.l	(a0),d1
	beq.s	GBy4
* Charge 64 caracteres
GBy3	move.l	a0,-(sp)
	move.l	d1,(a0)
	clr.w	4(a0)
	clr.w	6(a0)
	move.l	a0,d2
	addq.l	#8,d2
	moveq	#32-8,d3
	move.w	#DosRead,d7
	bsr	DosCall
	move.l	(sp)+,a0
	tst.l	d0
	beq	EOFil
	bmi	DiskError
	move.w	d0,6(a0)
* Prend un caractere
GBy4	move.w	4(a0),d0
	cmp.w	6(a0),d0
	bcc.s	GBy3
	addq.w	#1,4(a0)
	move.b	8(a0,d0.w),d0
EByE	movem.l	(sp)+,a0/a1/d1-d4
	rts
******* Fin de GetByte (a2)
EndByte	movem.l	a0/a1/d1-d4,-(sp)
	lea	DeFloat(a5),a0
	move.l	(a0),d1
	beq.s	EByE
	clr.l	(a0)
	move.w	4(a0),d2
	sub.w	6(a0),d2
	beq.s	EByE
	ext.l	d2
	moveq	#0,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	bra.s	EByE

******* OPEN OUT canal,nom
IOpOut	move.w	#%001,-(sp)
	move.l	#1006,-(sp)
	bra.s	OpIn
*******	OPEN IN canal,nom
IOpIn	move.w	#%010,-(sp)
	move.l	#1005,-(sp)		* Mode OLD
* Ouvre!
OpIn:	jsr	Par2
	bsr	NomDisk
	bsr	GetFile
	bne	FilOO
	bsr	FiClean
	move.l	Name1(a5),d1
	move.l	(sp)+,d2
	move.w	#DosOpen,d7
	bsr	DosCall
	tst.l	d0
	beq	DiskError
	move.l	d0,Fha(a2)		* Handle!
	move.w	(sp)+,d0
	move.b	d0,Fht(a2)		* Type
	bra	InsRet

******* LOF(n)
FLof	bsr	RLof
	moveq	#0,d2			* Seek --> fin
	moveq	#1,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	move.l	FhA(a2),d1
	move.l	d0,d2			* Seek --> debut!
	moveq	#-1,d3
	bsr	DosCall
	move.l	d0,d3
	moveq	#0,d2
	bra	OpeRet
******* =POF(n)=
FPof	bsr	RLof
	moveq	#0,d2
	moveq	#0,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	move.l	d0,d3
	moveq	#0,d2
	bra	OpeRet
IPof	bsr	RLof
	move.l	d1,-(sp)
	jsr	FnExpE
	tst.l	d3
	bmi	FonCall
	move.l	d3,d2
	move.l	(sp)+,d1
	moveq	#-1,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	tst.l	d0
	bpl	InsRet
	bra	DiskError
******* EOF
FEof	bsr	RLof
	moveq	#0,d2			* Seek --> fin
	moveq	#1,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	move.l	d0,d4
	move.l	FhA(a2),d1
	move.l	d0,d2			* Seek --> debut!
	moveq	#-1,d3
	bsr	DosCall
	moveq	#0,d2
	moveq	#0,d3
	cmp.l	d0,d4
	bcs	OpeRet
	moveq	#-1,d3
	bra	OpeRet
* Routine...
RLof:	jsr	FnPar1
	bsr	GetFile
	beq	FilNO
	btst	#2,FhT(a2)
	bne	FilTM
	rts

******* CLOSE [n]
IClo1	jsr	Par1
	bsr	GetFile
	beq	FilNO
	moveq	#0,d6
	bsr	Cloa1
	bra	InsRet
IClo0	bsr	CloAll
	bra	InsRet
* Ferme tous les fichiers
CloAll	lea	Fichiers(a5),a2
	moveq	#NFiche-1,d6
Cloa1	move.l	Fha(a2),d1		* Fichier
	beq.s	Cloa2
	clr.l	Fha(a2)
	moveq	#DosClose,d7
	bsr	DosCall
	move.l	FhF(a2),d0		* Field
	beq.s	Cloa2	
	move.l	d0,a1
	clr.l	FhF(a2)
	move.w	(a1),d0
	mulu	#6,d0
	addq.l	#8,d0
	bsr	RamFree
Cloa2	lea	TFiche(a2),a2
	dbra	d6,Cloa1
	rts
* Erreurs
FilOO	moveq	#DEBase+17,d0
	bra	RunErr
FilNO	moveq	#DEBase+18,d0
	bra	RunErr
FilTM	moveq	#DEBase+19,d0
	bra	RunErr
InpTL	moveq	#DEBase+20,d0
	bra	RunErr
EOFil	moveq	#DEBase+21,d0
	bra	RunErr

******* OPEN RANDOM canal,nom
IOpRan	move.w	#$80,d0
	bsr	RanApp
	bra	InsRet
	bra.s	RanApp
******* APPEND canal,nom
IAppn	move.w	#%001,d0
	bsr	RanApp
	moveq	#0,d2
	moveq	#1,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	bra	InsRet
* Ouvre, en .OLD s'il faut!
RanApp	move.w	d0,-(sp)
	jsr	Par2
	bsr	NomDisk
	bsr	GetFile
	bne	FilOO
	bsr	FiClean
	move.l	Name1(a5),d1		* Essaie en OLD
	move.l	#1005,d2
	move.w	#DosOpen,d7
	bsr	DosCall
	bne.s	IOpr1
	move.l	Name1(a5),d1		* NEW!
	move.l	#1006,d2
	bsr	DosCall
	beq	DiskError
IOpr1	move.l	d0,Fha(a2)		* Handle!
	move.l	d0,d1
	move.w	(sp)+,d0
	move.b	d0,Fht(a2)		* Type
	rts

******* FIELD N,AA as A$...
IField	jsr	Par1
	bsr	GetFile
	beq	FilNO
	move.l	a3,-(sp)
	move.l	a2,-(sp)
	clr.w	-(sp)
* Recupere les variables
Fld1	addq.l	#2,a6
	jsr	Par1
	addq.l	#2,a6
	bsr	FindVar
	move.l	a0,-(a3)
	addq.w	#1,(sp)
	cmp.w	#TkVir-Tk,(a6)
	beq.s	Fld1
* Reserve la memoire necessaire
	move.w	(sp),d0
	mulu	#6,d0
	addq.l	#8,d0
	bsr	RamFast
	beq	OOfMem
	move.w	(sp)+,d1
	move.l	(sp)+,a2
	move.l	d0,FhF(a2)
	move.l	d0,a1
	lea	8(a1),a0
	move.w	d1,(a1)
	subq.w	#1,d1
	moveq	#0,d2
	move.l	(sp),a3
Fld2	move.l	-(a3),d0
	beq	FldFonc
	add.l	d0,d2
	cmp.l	#65500,d2
	bcc	FldFonc
	move.w	d0,(a0)+
	move.l	-(a3),(a0)+
	dbra	d1,Fld2
	move.w	d2,2(a1)
* Taille du fichier
	move.l	(sp)+,a3
	move.l	a1,-(sp)
	move.l	FhA(a2),d1
	moveq	#0,d2
	moveq	#1,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	move.l	FhA(a2),d1
	moveq	#0,d2
	moveq	#-1,d3
	bsr	DosCall
	move.l	(sp)+,a1
	move.l	d0,4(a1)
	bra	InsRet	
* FonCall field!
FldFonc	moveq	#0,d6
	bsr	Cloa1
	bra	FonCall

******* Routine GET et PUT
GetPut	bsr	Par2
	move.l	(a3)+,d6
	cmp.l	#65500,d6
	bcc	FonCall
	subq.w	#1,d6
	bmi	FonCall
	bsr	GetFile
	beq	FilNO
	move.l	d1,-(sp)
	tst.b	FhT(a2)
	bpl	FilTM
	move.l	FhF(a2),a2
	mulu	2(a2),d6
	move.l	4(a2),d5
	move.l	d6,d2
	cmp.l	d5,d6
	bls.s	GP1
	move.l	d5,d2
GP1	move.l	(sp),d1
	moveq	#-1,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	move.l	(sp)+,d1
	rts

******* GET #n,vv
IGet:	bsr	GetPut
	cmp.l	d5,d6
	bcc	EOFil
	move.l	d1,-(sp)
	move.w	(a2),d6
	subq.w	#1,d6
	lea	8(a2),a2
IGet1	moveq	#0,d3
	move.w	(a2)+,d3
	bsr	DDemande
	move.l	(a2)+,a1
	move.l	a0,(a1)
	move.w	d3,(a0)+
	move.l	a0,d2
	add.w	d3,a0
	btst	#0,d3
	beq.s	IGet2
	addq.l	#1,a0
IGet2	move.l	a0,HiChaine(a5)
	move.l	(sp),d1
	move.w	#DosRead,d7
	bsr	DosCall
	cmp.l	d0,d3
	bne	DiskError
	dbra	d6,IGet1
	addq.l	#4,sp
	bra	InsRet

******* PUT 
IPut: 	bsr	GetPut
	cmp.l	d5,d6
	bhi	EOFil
	move.w	(a2),d6
	subq.w	#1,d6
	move.l	a2,-(sp)
	lea	8(a2),a2
IPut1:  moveq	#0,d3
	move.w	(a2)+,d3
	move.l	(a2)+,a0
        move.l 	(a0),a0
        moveq	#0,d4
        move.w 	(a0)+,d4
        cmp.w	d3,d4
        beq.s 	IPut2
        bcs.s 	IPut2
        move.w 	d3,d4
IPut2:  movem.l	a0/d1-d4,-(sp)
	move.l	a0,d2
	move.l	d4,d3
	move.w	#DosWrite,d7
	bsr	DosCall
	cmp.l	d0,d3
	bne	DiskError
	movem.l	(sp)+,a0/d1-d4
        cmp.w	d3,d4
        bcc.s 	IPut4
        sub.l 	d4,d3
        bsr 	DDemande
        move.w 	d3,d0
	subq.w	#1,d0
IPut3:  move.b 	#32,(a1)+
	dbra	d0,IPut3
	move.l	a0,d2
	movem.l	d1-d3,-(sp)
	move.w	#DosWrite,d7
	bsr	DosCall
	cmp.l	d0,d3
	bne	DiskError
	movem.l	(sp)+,d1-d3
IPut4	dbra	d6,IPut1
* Taille augmente?
	move.l	(sp)+,a2
	moveq	#0,d2
	moveq	#0,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	cmp.l	4(a2),d0
	bls	InsRet
	move.l	d0,4(a2)
	bra	InsRet

***********************************************************
*	IMPRIMANTE
******* Ouverture de l'imprimante
OpPrt:	move.l	PrtHandle(a5),d1
	bne.s	OpPrx
	movem.l	a0-a2/d2-d7,-(sp)
	Alea	NmPrt,a0
	move.l	a0,d1
	move.l	#1005,d2
	move.w	#DosOpen,d7
	bsr	DosCall
	tst.l	d0
	beq	DiskError
	move.l	d0,PrtHandle(a5)
	move.l	d0,d1
	movem.l	(sp)+,a0-a2/d2-d7
OpPrx:	rts
******* Imprime la chaine A0 (finie par zero) sur l'imprimante
ImpImp	bsr	OpPrt
	movem.l	a0-a2/d2-d7,-(sp)
	move.l	a0,d2
	move.l	a0,a1
* Compte et enleve les CARRIAGE RETURN 
Ip1:	move.b	(a0)+,d0
	move.b	d0,(a1)+
	beq.s	Ip2
	cmp.b	#13,d0
	bne.s	Ip1
	tst.w	PrtRet(a5)
	bne.s	Ip1
	cmp.b	#10,(a0)
	bne.s	Ip1
	move.b	(a0)+,-1(a1)
	bra.s	Ip1
* Envoie!
Ip2	sub.l	d2,a0
	subq.l	#1,a0
	move.l	a0,d3
	beq.s	Ip3
	move.w	#DosWrite,d7
	jsr	DosCall
	tst.l	d0
	bmi	DiskError
Ip3:	movem.l	(sp)+,a0-a2/d2-d7
	rts

***********************************************************
*	SET DIR A
SDir1:	bsr	GetPar
	bra.s	SDir3
***********************************************************
*	SET DIR A,A$
SDir2:	bsr	GetPar
	move.l	(a3)+,a2
	cmp.l	#EntNul,a2
	beq	SDir3
	move.w	(a2)+,d2
	cmp.w	#106,d2
	bcc	STooLong
	move.l	DirFNeg(a5),a0
	bsr	ChVerBuf2
SDir3:	move.l	(a3)+,d3
	cmp.l	#EntNul,d3
	beq	InsRet
	and.l	#$FFFFFFFE,d3
	beq	FonCall
	cmp.l	#106,d3
	bcc	FonCall
	move.w	d3,DirLNom(a5)
	bra	InsRet

***********************************************************
*	=DEV FIRST$("filter")
FDevF	pea	FillDev(pc)
*	bra.s	FDevAcc
***********************************************************
*	=ACC FIRST$("filter")
*FAccF	pea	FillAcc(pc)
FDevAcc	bsr	FnPar1
	bsr	NomDir
	move.w	#1,FillF32(a5)
	clr.w	DirComp(a5)
	move.w	DirLNom(a5),FillFSize(a5)
	move.l	(sp)+,a0
	jsr	(a0)
	bra.s	FDirN
***********************************************************
*	=DIR FIRST$("filter")
FDirF	cmp.w	#1,RunAct(a5)
	beq	FonCall
	bsr	FnPar1
	bsr	NomDir
	bsr	GetDir
	move.w	#1,FillF32(a5)
	clr.w	DirComp(a5)
	move.w	DirLNom(a5),FillFSize(a5)
	bsr	FillAll
	bsr	FillSort
FDevN
FAccN
FDirN	cmp.w	#1,RunAct(a5)
	beq	FonCall
	move.w	PosFillF(a5),d0
	bsr	FillGet
	beq.s	FDirV
	lea	6(a0),a2
	addq.w	#1,PosFillF(a5)
	move.w	FillFSize(a5),d3
	ext.l	d3
	move.w	d3,d2
	addq.l	#8,d3
	bsr	DDemande
	move.l	a0,-(sp)
	move.w	d3,(a1)+
	lea	2(a0,d3.w),a0
	move.l	a0,HiChaine(a5)
	lea	4(a2),a0
	subq.w	#1,d2
FDirN1	move.b	(a0)+,(a1)+
	dbra	d2,FDirN1
	moveq	#7,d1
FDirN2	move.b	#" ",(a1)+
	dbra	d1,FDirN2
	lea	-8(a1),a0
	cmp.b	#"*",4(a2)
	beq.s	FDirN3
	move.l	(a2),d0
	bmi.s	FDirN3
	jsr	LongDec
FDirN3	moveq	#2,d2
	move.l	(sp)+,d3
	bra	OpeRet
* Enleve le buffer--> vide!
FDirV	bsr	FillFFree
	move.l	ChVide(a5),d3
	moveq	#2,d2
	bra	OpeRet

***********************************************************
*	=EXIST("name")
FExist	bsr	FnPar1
	bsr	NomDisk
	bsr	RExist
	moveq	#0,d2
	bra	OpeRet
RExist	bsr	NoReq
	move.l 	Name1(a5),d1
	move.w	#DosLock,d7
	bsr	DosCall
	move.l	d0,-(sp)
	bsr	YesReq
	move.l	(sp)+,d0
	move.l	d0,d1
	beq.s	FExF
	move.w	#DosUnLock,d7
	bsr	DosCall
	moveq	#-1,d3
	rts
FExF	moveq	#0,d3
	rts

* Plus de requester
NoReq	movem.l	a0-a1/a6/d0-d1,-(sp)
	move.l	$4.w,a6
	sub.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,a0
	move.l	$b8(a0),ReqSave(a5)
	move.l	#-1,$b8(a0)
	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts
* Remet le requester
YesReq	movem.l	a0-a1/a6/d0-d1,-(sp)
	move.l	$4.w,a6
	sub.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,a0
	move.l	ReqSave(a5),$b8(a0)
	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts

***********************************************************
*	DIR/W  / LDIR/W
DirW0:	clr.w	impflg(a5)
DirW0a:	move.l	Name1(a5),a0
	clr.b	(a0)
	move.l	Name2(a5),a0
	clr.b	(a0)
	bsr	PathIt
	bra.s	DirW2
***********************************************************
*	DIR/W / LDIR/W a$
DirW1:	clr.w	impflg(a5)
DirW1a:	bsr	Par1
	bsr	NomDir
DirW2:	move.w	#1,DirComp(a5)
	move.w	#20,FillFSize(a5)
	bra.s	Dir3
***********************************************************
*	DIR/LDIR 
Dir0:	clr.w	impflg(a5)
Dir0a:	move.l	Name1(a5),a0
	clr.b	(a0)
	move.l	Name2(a5),a0
	clr.b	(a0)
	bsr	PathIt
	bra.s	Dir2
***********************************************************
*	DIR/LDIR a$
Dir1:	clr.w	impflg(a5)
Dir1a:	bsr	Par1
	bsr	NomDir
Dir2:	clr.w	DirComp(a5)
	move.w	DirLNom(a5),FillFSize(a5)

******* Affiche le nom de la disquette
Dir3:	move.w	#1,FillF32(a5)
	clr.l	DirLong(a5)
	bsr	FillFirst
	Alea	ChDir0,a0
	bsr	ImpChaine
	move.l	BufFillF(a5),a0
	lea	6+4(a0),a0
	bsr	ImpChaine
	Alea	CRet,a0
	bsr	ImpChaine

******* Boucle du directory
DirLoop	bsr	FillNxt
	bmi	DiskError
	beq	DirL5
	cmp.w	#1,d0
	beq.s	DirLoop
	move.l	a0,a2
	tst.w	DirComp(a5)
	beq.s	DirL0
* Affichage condense!
	lea	4(a2),a0
	bsr	ImpChaine
	bra.s	DirL3
* Affichage normal
DirL0:	cmp.b	#"*",4(a2)
	bne.s	DirL1
* Directory
	Alea	ChDir3,a0
	bsr	ImpChaine
	lea	5(a2),a0
	bsr	ImpChaine
	bra.s	DirL2
* Fichier normal
DirL1:	Alea	ChDir4,a0
	bsr	ImpChaine
	lea	5(a2),a0
	bsr	ImpChaine
	Alea	ChDir5,a0
	bsr	ImpChaine
	move.l	Name1(a5),a0
	move.l	(a2),d0
	and.l	#$00FFFFFF,d0
	add.l	d0,DirLong(a5)
	jsr	LongDec
	clr.b	(a0)
	move.l	Name1(a5),a0
	bsr	ImpChaine
* Encore un?
DirL2:	Alea	CRet,a0
	bsr	ImpChaine
DirL3:	bsr	TTDir
	beq	DirLoop
* Message de fin
DirL5:	tst.w	DirComp(a5)
	beq.s	DirL6
	Alea	CRet,a0
	bsr	ImpChaine
	bra.s	DirL7
DirL6:	move.l	Buffer(a5),a0
	move.l	DirLong(a5),d0
	jsr	LongDec
	clr.b	(a0)
	move.l	Buffer(a5),a0
	bsr	ImpChaine
	Alea	ChDir6,a0
	bsr	ImpChaine
* Va liberer la memoire FILL FILE
DirL7:	bsr	FillFFree
	bra	InsRet

******* Tests touches DIR
TTDir:	bsr	Tests
	SyCall	Inkey			* SPACE/ESC?
	tst.l	d1
	beq.s	TTdiC
	cmp.b	#" ",d1
	beq.s	TTdiW
	swap 	d1
	cmp.b	#$45,d1
	beq.s	TTdiF
TTdiC:	SyCall	Shifts			* CONTROL?
	and.w	#%00001000,d1
	beq.s	TTdiX
	moveq	#25,d7
TTdiL:	bsr	Tests
	SyCall	WaitVBL
	dbra	d7,TTdiL
TTdiX:	moveq	#0,d0
	rts
* Boucle d'attente
TTdiW:	bsr	Tests
	SyCall	Inkey
	tst.l	d1
	beq.s	TTdiW
	swap	d1
	cmp.b	#$45,d1
	bne.s	TTdiX
* Fin du directory!
TTdiF:	moveq	#1,d0
	rts

***********************************************************
*	Trouve le cheminement ---> 384(buffer)
AskDir	move.l	Buffer(a5),a0
	clr.w	(a0)
	move.l	a0,d1
	moveq	#-2,d2
	move.w	#DosLock,d7
	jsr	DosCall
	tst.l	d0
	beq	DiskError
AskDir2	clr.l	-(sp)
ADir0:	move.l	d0,-(sp)
	move.l	d0,d1
	move.w	#DosParent,d7
	jsr	DosCall
	tst.l	d0
	bne.s	ADir0
* Redescend les LOCKS en demandant le NOM!
	move.l	Buffer(a5),a2
	lea	384(a2),a2
	clr.b	(a2)
	moveq	#":",d2
ADir1:	move.l	(sp)+,d1
	beq.s	ADir4
	move.l	Buffer(a5),a1
	movem.l	d1/d2/a1/a2,-(sp)
	move.l	a1,d2
	move.w	#DosExam,d7
	jsr	DosCall
	movem.l	(sp)+,d1/d2/a1/a2
	tst.l	d0
	beq.s	ADir3
	lea	8(a1),a1
ADir2:	move.b	(a1)+,(a2)+
	bne.s	ADir2
	move.b	d2,-1(a2)
	clr.b	(a2)
	moveq	#"/",d2
ADir3	move.w	#DosUnLock,d7
	jsr	DosCall
	bra.s	ADir1
ADir4	rts

******* Trouve le lock NAME1
GetDir
LockGet	move.l	Name1(a5),d1
	bsr	LockFree
	moveq	#-2,d2
	move.w	#DosLock,d7
	bsr	DosCall
	move.l	d0,d1
	beq	DiskError
	move.l	d1,LockSave(a5)
	rts

***********************************************************
*	FILL FILE

******* Rempli TOUT!
FillAll	bsr	FillFirst
FlAl1	bsr	FillNxt
	bmi.s	FlAl2
	bne.s	FlAl1
FlAl2	rts
******* Ramene le nom SELECTIONNE d0 ---> A0
FillGet	movem.l	d1/d2,-(sp)
	move.l	BufFillF(a5),d2
	beq.s	FlGNo
	move.l	d2,a0
	moveq	#-1,d1
FlG0	move.l	(a0),d2
	beq.s	FlGNo
	move.l	d2,a0
	addq.w	#1,d1
	cmp.w	d0,d1
	bne.s	FlG0
	movem.l	(sp)+,d1/d2
	moveq	#-1,d0
	rts
FlGNo	movem.l	(sp)+,d1/d2
	moveq	#0,d0
	rts

******* Cree le buffer!
FillFirst
* Enleve l'ancien buffer -si present-, reserve le nouveau
	bsr	FillFFree
* Trouve le nom du disque
	bsr	LockGet
	move.l	Buffer(a5),d2
	move.w	#DosExam,d7
	bsr	DosCall
	move.l	Buffer(a5),a0
	tst.w	4(a0)			* Si FICHIER-> filtre
	bpl.s	FlF2
	move.l	d6,a0
	move.l	Name2(a5),a1
FlF1	move.b	(a0)+,(a1)+
	bne.s	FlF1
	move.l	d6,a0
	clr.b	(a0)
FlF2	bsr	LockGet
	bsr	AskDir2
	clr.l	LockSave(a5)
	move.l	#6+4+128,d0
	move.l	d0,d1
	bsr	RamFast
	beq	OOfMem
	move.l	d0,BufFillF(a5)
	move.l	d0,a1
	move.w	d1,4(a1)
	lea	6+4(a1),a1
	move.l	Buffer(a5),a0
	lea	384(a0),a0
FlF3	move.b	(a0)+,(a1)+
	bne.s	FlF3
* Saute le nom du disque...
	bsr	LockGet
	move.l	LockSave(a5),d1
	move.l	Buffer(a5),d2
	move.w	#DosExam,d7
	bsr	DosCall
	rts

******* Boucle de recherche
FillNxt
	move.l	LockSave(a5),d1
	move.l	Buffer(a5),a2
	move.l	a2,d2
	move.w	#DosExNext,d7
	bsr	DosCall
	tst.l	d0
	beq	FFFini
* Filtre les noms, si pas directory...
	tst.w	4(a2)
	bpl.s	Ff6b
	move.l	DirFNeg(a5),a0		* Filtre NEGATIF
	tst.b	(a0)
	beq.s	Ff6
	lea	8(a2),a1
	bsr	Joker
	bne.s	Ff8
Ff6:	move.l	Name2(a5),a0		* Filtre POSITIF
	tst.b	(a0)
	beq.s	Ff6a
	lea	8(a2),a1
	bsr	Joker
	beq.s	Ff8
Ff6a	moveq	#" ",d2
	bra.s	Ff7
* Une *
Ff6b	moveq	#"*",d2
* Poke dabs le buffer
Ff7	bsr	FillFPoke
	beq.s	FfFini
* OK! Ramene le nom = A0 / D0>0
	move.l	d7,a0
	moveq	#2,d0
	rts
* Pas filtre!
Ff8	moveq	#1,d0
	rts
******* Plus de nom. D0=0 fin / D0<0 erreur
FfFini	move.w	#DosIoErr,d7
	bsr	DosCall
	cmp.w	#232,d0
	bne.s	FfErr
	moveq	#0,d0
	rts
FfErr	moveq	#-1,d0
	rts

******* Libere les buffers FILLFILE
FillFFree:
	bsr	LockFree
	move.l	BufFillF(a5),d1
	beq.s	FFr2
FFr1	move.l	d1,a1
	move.l	(a1),d1
	move.w	4(a1),d0
	ext.l	d0
	bsr	RamFree
	tst.l	d1
	bne.s	FFr1
FFr2	clr.l	BufFillF(a5)
	clr.w	FillFNb(a5)
	clr.w	PosFillF(a5)
	rts

******* Trie le buffer!
FillSort
	movem.l	a0-a4/d0-d2,-(sp)
Fss1	moveq	#0,d7
	move.l	BufFillF(a5),d0
	beq.s	FssX
	move.l	d0,a0
	move.l	(a0),d0
	beq.s	FssX
	move.l	d0,a1
	bra.s	Fss4
* Compare les chaines
Fss2	move.l	d0,a1
	lea	10(a0),a3
	lea	10(a1),a4
Fss3	move.b	(a4)+,d0
	bsr	MajD0a
	cmp.b	#"*",d0
	bne.s	Fss3a
	moveq	#1,d0
Fss3a	move.b	d0,d1
	move.b	(a3)+,d0
	bsr	MajD0a
	cmp.b	#"*",d0
	bne.s	Fss3b
	moveq	#1,d0
Fss3b	move.b	d0,d2
	or.b	d1,d2
	beq.s	Fss4
	cmp.b	d0,d1
	beq.s	Fss3
	bhi.s	Fss4
* Echange
	move.l	(a1),(a0)
	move.l	a0,(a1)
	move.l	a1,(a2)
	addq.w	#1,d7
	exg.l	a0,a1
* La chaine suivante?
Fss4	move.l	a0,a2
	move.l	a1,a0
	move.l	(a0),d0
	bne.s	Fss2
* Encore une fois?
	tst.w	d7
	bne.s	Fss1
* Ca y est!
FssX	movem.l	(sp)+,a0-a4/d0-d2
	rts

******* Poke dans le buffer, sans classement
*	D2= premier caractere
FillFPoke
	move.w	FillFSize(a5),d0
	add.w	#4+2+4+2,d0
	ext.l	d0
	move.l	d0,d1
	bsr	RamFast
	beq.s	pfH
	move.l	d0,a1
	move.l	BufFillF(a5),d0
	bne.s	pfA
	move.l	a1,BufFillF(a5)
	bra.s	pfB
pfA	move.l	d0,a0
	move.l	(a0),d0
	bne.s	pfA
	move.l	a1,(a0)
pfB	move.w	d1,4(a1)
	lea	6(a1),a1
	move.l	a1,d7
* Recopie du nom, en le tronquant.
	move.l	124(a2),(a1)+
	move.w	FillFSize(a5),d1
	subq.w	#2,d1
	move.b	d2,(a1)+
	lea 	8(a2),a0
pfD:    move.b 	(a0)+,(a1)+
	beq.s	PfE
        dbra 	d1,pfD
	bra.s	PfG
pfE:	tst.w	FillF32(a5)
	beq.s	PfG
	subq.l	#1,a1
pfF:	move.b	#" ",(a1)+
	dbra	d1,PfF
; Un nom de plus!
pfG:	addq.w	#1,FillFNb(a5)
	tst.l	d7
	rts
* Plus de place
pfH:	moveq	#0,d7
	rts

******* Filtre les noms disque!
Joker:	move.l	a0,d2	
	move.l	a1,d3
JokLoop	move.b	(a1)+,d1
	beq.s	JokX
JokL0	move.b	(a0)+,d0
	beq.s	JokNON
	cmp.b	#"/",d0
	beq.s	ReJok
	cmp.b	#"?",d0
	beq.s	JokC
	cmp.b	#".",d0
	beq.s	JokD
	cmp.b	#"*",d0
	beq.s	JokE
* Veut une lettre normale!
	cmp.b	#"a",d0
	bcs.s	JokA
	cmp.b	#"z",d0
	bhi.s	JokA
	sub.b	#"a"-"A",d0
JokA:	cmp.b	#"a",d1
	bcs.s	JokB
	cmp.b	#"z",d1
	bhi.s	JokB
	sub.b	#"a"-"A",d1
JokB:	cmp.b	d0,d1
	beq.s	JokLoop
	bra.s	ReJok
* N'importe quelle lettre!
JokC:	cmp.b 	#".",d1
	bne.s	JokLoop
	bra.s	ReJok
* Un Point!
JokD:	cmp.b	#".",d1
	beq.s	JokLoop
	bra.s	ReJok
* Une etoile
JokE:	cmp.b	#"*",(a0)
	beq.s	JokOUI
JokF:	cmp.b	#".",d1
	beq.s	JokL0
	move.b	(a1)+,d1
	bne.s	JokF
* Fin du mot sur le disque
JokX:	move.b	(a0)+,d0
	beq.s	JokOUI
	cmp.b	#"/",d0
	beq.s	JokOUI
* Recommence!
ReJok:	move.l	d2,a0
	move.l	d3,a1
ReJ:	move.b	(a0)+,d0
	beq.s	JokNON
	cmp.b	#"/",d0
	bne.s	ReJ
	move.l	a0,d2
	bra	JokLoop
* Reponses...
JokNON:	moveq	#0,d0
	rts
JokOUI:	moveq	#1,d0
	rts
	
******* Recopie les textes dans le buffer
EFText:	tst.w	EdFSel(a5)
	beq.s	EFtx
* Recopie dans le buffer!
	movem.l	d0/a0-a2,-(sp)
	move.l	(a3),a2
	move.l	Buffer(a5),a0
	lea	2(a0),a1
	moveq	#-1,d0
EFt1:	addq.w	#1,d0
	move.b	(a2)+,(a1)+
	bne.s	EFt1
	move.w	d0,(a0)
	move.l	a0,(a3)
	movem.l	(sp)+,d0/a0-a2
EFtx:	rts

***********************************************************
*	SELECTEUR DE FICHIERS / ACCESSOIRES
*******

******* FSEL$("filtre$")
FSel1:	bsr	FnPar1
	move.l	ChVide(a5),d0
	move.l	d0,-(a3)
	move.l	d0,-(a3)
	move.l	d0,-(a3)
	bra.s	FSel
******* FSEL$("filtre$","default")
Fsel2:	bsr	FnPar2
	move.l	ChVide(a5),-(a3)
	move.l	ChVide(a5),-(a3)
	bra	FSel
******* FSEL$("f","d","titre1")
FSel3:	moveq	#3,d0
	bsr	FnParD0
	move.l	ChVide(a5),-(a3)
	bra.s	FSel
******* FSEL$("f","d","t1","t2")
FSel4:	moveq	#4,d0
	bsr	FnParD0
	
******* Sauve la pile! 
FSel:	cmp.w	#1,RunAct(a5)		Si TUTOR!
	beq	FonCall
	clr.w	AccFlag(a5)
FSel0	move.l	sp,FsSp(a5)
******* Ouverture de l'ecran
	lea	Ed_pics,a0
	moveq	#1,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#EcFSel,d3
	jsr	UPack
* Change la palette de couleurs
	lea	Environs(a5),a2
	move.w	(a2)+,d0
	mulu	#(1+8+8)*2,d0
	lea	(1+8)*2(a2,d0.w),a2
	moveq	#0,d1
.loop	move.w	(a2)+,d2
	movem.l	d1/a2,-(sp)
	EcCall	SCol
	movem.l	(sp)+,d1/a2
	addq.w	#1,d1
	cmp.w	#8,d1
	bcs.s	.loop
	move.l	T_EcCourant(a5),a0
	move.l	a0,FsAdEc(a5)	
	SyCalD	ResZone,32	
	moveq	#1,d1
	Alea	EdFlCu,a1
	EcCall	Flash
* Init du slider
	moveq	#6,d0
	moveq	#6,d1
	moveq	#6,d2
	moveq	#1,d3
	moveq	#4,d4
	moveq	#4,d5
	moveq	#4,d6
	moveq	#1,d7
	EcCall	SetSli
* Init des titres
	WiCalA	Print,FsITit2(pc)
	bsr	EFText
	move.l	(a3)+,a2
	move.l	a2,a1
	move.w	(a2)+,d2
	beq.s	FsTi1
	cmp.w	#39,d2
	bcc	FsTi1
	bsr	ChVerBuf
	move.l	Buffer(a5),a1
	WiCall	Centre
FsTi1:	WiCalA	Print,FsITit1(pc)
	bsr	EFText
	move.l	(a3)+,a2
	move.l	a2,a1
	Alea	FsDTit,a1
	move.w	(a2)+,d2
	beq.s	FsTi2
	cmp.w	#39,d2
	bcc	FsTi2
	bsr	ChVerBuf
	move.l	Buffer(a5),a1
FsTi2:	WiCall	Centre
* Init du texte par defaut
	moveq	#8,d1
	Alea	FaTxt,a0
	tst.w	AccFlag(a5)
	bne.s	FsIt0
	Alea	FsTxt,a0
FsIt0:	bsr	FsCopT			* Copie le texte
	addq.w	#1,d1			* Jusqu'au dernier
	cmp.w	#17,d1
	bcs.s	FsIt0
* Fenetre PATHNAME
	moveq	#2*8,d2
	move.w	#15*8,d3
	moveq	#36,d4
	moveq	#2,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d7,a1
	WiCalD	WindOp,1	
	bne	EcWiErr
	WiCalA	Print,FsPathI(pc)
* Fenetre NOM
	moveq	#2*8,d2
	move.w	#18*8,d3
	moveq	#36,d4
	moveq	#1,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d7,a1
	WiCalD	WindOp,2
	bne	EcWiErr
	move.w	#2,FsWiAct(a5)
	move.l	Buffer(a5),a0
	lea	FsDNom(a0),a0
	clr.b	(a0)
	clr.w	FsCNom(a5)
	clr.w	FsLNom(a5)
	bsr	EFText
	move.l	(a3)+,a2
	move.w	(a2)+,d2
	cmp.w	#35,d2
	bcc	FsInm0
	move.w	d2,FsCNom(a5)
	move.w	d2,FsLNom(a5)
	bsr	ChVerBuf2
FsINm0:	WiCalA	Print,FsNomI(pc)

******* Fait apparaitre l'ecran
	move.l	FsAdEc(a5),a2
	move.w	FsDWX(a5),EcAWX(a2)
	bset	#1,EcAW(a2)
	move.w	FsDVApp(a5),d7
	moveq	#1,d6
	move.w	FsDWY(a5),d5
	add.w	#(21*8)/2,d5
	bsr	AppCentre
	move.w	#1,FsFlag(a5)
* Limite la souris
	lea	T_MouXMin(a5),a0
	lea	FsLimSave(a5),a1
	moveq	#3,d0
FsTi0	move.w	(a0)+,(a1)+
	dbra	d0,FsTi0
	moveq	#0,d1
	SyCall	LimitMEc

******* Prend le PATH
FsDr4:	bsr	EFText
	bsr	NomDir
	bsr	FsCoPath

******* Boucle !
	clr.w	FsActive(a5)
FsReLoop
	clr.w	FsIFlag(a5)
FsReLp
	sub.l	a1,a1			* Efface le message
	bsr	FsMess
	moveq	#0,d0
	bsr	FsANom
	bsr	FsFirst
	bsr	FsAffF
	bsr	FsSli

FsRLoop	SyCall	MouseKey
	and.b	#$3,d1
	bne.s	FsRLoop
FsLoop:
* Attente multitache
	SyCall	Test_Cyclique
	tst.w	T_AMOSHere(a5)
	bne.s	.Skip
	jsr	WaitMul
.Skip
* Affichage progressif des fichiers
	bsr	FsNext

* Gestion des zones actives!
FsL0:	SyCall	GetZone
	cmp.w	#EcFSel,d1
	beq.s	FsL1
FsL1a:	moveq	#0,d1
FsL1:	swap 	d1
	cmp.w	FsActive(a5),d1
	beq.s	FsL3
	move.w	d1,-(sp)
	move.w	FsActive(a5),d1
	beq.s	FsL2
	moveq	#0,d0
	bsr	FsAffT
	clr.w	FsActive(a5)
FsL2:	move.w	(sp)+,d1
	move.w	d1,FsActive(a5)
	beq.s	FsL3
	moveq	#1,d0
	bsr	FsAffT

* Appuie sur la souris
FsL3:	SyCall	MouseKey
	move.w	d1,d2 
	btst	#1,d2
	bne	FsGoDev			* Devices!!!
	btst	#0,d2			
	beq	FsKey	
	move.w	FsActive(a5),d1
	beq	FsKey
	cmp.w	#8,d1
	beq	FsGoDev
	cmp.w	#14,d1
	beq	FsGoch
	cmp.w	#10,d1
	beq	FsDroi
	cmp.w	#15,d1
	beq	FsHaut
	cmp.w	#16,d1
	beq	FsBas
	cmp.w	#17,d1
	beq	FsMou
	cmp.w	#11,d1
	beq	FsFin
	cmp.w	#12,d1
	beq	FsEsc
	cmp.w	#13,d1
	beq	FsSort
	cmp.w	#9,d1
	beq	FsParent
	cmp.w	#18,d1
	beq	FsGPath
	cmp.w	#19,d1
	beq	FsGNom
	cmp.w	#20,d1
	bcc	FsFile

******* Appui sur une touche
FsKey:	SyCall	Inkey
	tst.l	d1
	beq	FsLoop
* Prend les parametres actuels
	moveq	#35,d6			* Nom
	move.w	FsLNom(a5),d5
	move.w	FsCNom(a5),d4
	move.l	Buffer(a5),a2
	lea	FsDNom(a2),a2 
	cmp.w	#2,FsWiAct(a5)
	beq.s	FsEdI0
	move.w	#PathMax,d6		* Path
	move.w	FsLPath(a5),d5
	move.w	FsCPath(a5),d4
	move.l	Buffer(a5),a2
	lea	512(a2),a2
FsEdI0:
	swap	d1
	cmp.b	#$4F,d1			* Fleche gauche
	beq	FsEdG
	cmp.b	#$4E,d1			* Fleche droite
	beq	FsEdR
	cmp.b	#$4C,d1			* Fleche haute
	beq	FsGPath
	cmp.b	#$4D,d1			* Fleche basse
	beq	FsGNom
	cmp.b	#$41,d1			* BackSpace
	beq	FsEdB
	cmp.b	#$46,d1			* Delete
	beq	FsEdD
	cmp.b	#$45,d1			* Escape
	beq	FsEsc
	swap	d1
	cmp.b	#13,d1
	beq	FsRet
	cmp.b	#32,d1
	bcs	FsLoop
* Insere une lettre
	cmp.w	d6,d5			* Longueur maximum
	bcc	FsLoop
	move.w	d5,d0
FsEdI1:	move.b	0(a2,d0.w),1(a2,d0.w)
	subq.w	#1,d0
	cmp.w	d4,d0
	bge.s	FsEdI1
	move.b	d1,0(a2,d4.w)
	addq.w	#1,d5
	addq.w	#1,d4
	clr.b	0(a2,d5.w)
	bra	FsEdPrt
* Curseur a gauche
FsEdG:	tst.w	d4
	beq	FsLoop
	and.w	#$0300,d1
	bne.s	FsEdMg
	subq.w	#1,d4
	bra	FsEdPrt
* Mot gauche
FsEdMg:	subq.w	#1,d4
	tst.w	d4
	beq	FsEdPrt
	move.b	-1(a2,d4.w),d2
	jsr	Lettre
	bne.s	FsEdMg
	bra	FsEdPrt
* Curseur a droite
FsEdR:	cmp.w	d5,d4
	bcc	FsLoop
	and.w	#$0300,d1
	bne.s	FsEdMd
	addq.w	#1,d4
	bra	FsEdPrt
* Mot droit
FsEdMd:	addq.w	#1,d4
	cmp.w	d5,d4
	bcc	FsEdPrt
	move.b	-1(a2,d4.w),d2
	jsr	Lettre
	bne.s	FsEdMd
	bra	FsEdPrt
* BackSpace
FsEdB:	and.w	#$0300,d1
	bne.s	FsEdCl
	tst.w	d4
	beq	FsLoop
	subq.w	#1,d4
* Delete
FsEdD:	and.w	#$0300,d1
	bne.s	FsEdCl
	cmp.w	d5,d4
	bcc	FsEdPrt
	move.w	d4,d0
FsEdD1:	move.b	1(a2,d0.w),0(a2,d0.w)
	addq.w	#1,d0
	cmp.w	d5,d0
	bcs.s	FsEdD1
	subq.w	#1,d5
	clr.b	0(a2,d5.w)
	bra	FsEdPrt	
* Nettoyage ligne
FsEdCl:	clr.b	(a2)
	clr.w	d4
	clr.w	d5
* Imprime le resultat!
FsEdPrt cmp.w	#1,FsWiAct(a5)
	beq.s	FsEdP
* Fenetre NOM
	move.w	d4,FsCNom(a5)
	move.w	d5,FsLNom(a5)
	moveq	#-1,d0
	bsr	FsANom
	bra	FsLoop
* Fenetre PATH
FsEdP:	move.w	d4,FsCPath(a5)
	move.w	d5,FsLPath(a5)
	moveq	#-1,d0
	bsr	FsAPath
	bra	FsLoop
******* RETURN
FsRet:	cmp.w	#2,FsWiAct(a5)
	beq.s	FsFin
* Change le path!
	move.l	Buffer(a5),a2
	lea	512(a2),a2
	move.w	FsLPath(a5),d2
	moveq	#0,d7
	bsr	NDir
	bra	FsReLoop

******* ESCAPE
FsEsc:	bsr	FsOut
	bsr	FillFFree
	tst.w	EdFSel(a5)
	bne.s	FsEsc1
	move.l	ChVide(a5),d3
	moveq	#2,d2
	move.l	FsSp(a5),sp
	bra	OpeRet
FsEsc1:	clr.w	d0
	rts
******* Fin du selecteur de fichier
FsFin:	
	tst.w	FsLNom(a5)
	beq.s	FsEsc

; Recopie NAME1 dans PATHACT
	tst.w	AccFlag(a5)
	bne.s	.sskip
	move.l	Name1(a5),a0
	move.l	PathAct(a5),a1
	move.w	FsLPath1(a5),d0
	subq.w	#1,d0
	beq.s	.skip
.loop	move.b	(a0)+,(a1)+
	dbra	d0,.loop
.skip	clr.b	(a1)
.sskip
; Sortie normale
	bsr	FsOut
	move.l	Name1(a5),a0
	move.w	FsLPath1(a5),d3
	lea	0(a0,d3.w),a0
	move.l	Buffer(a5),a1
	lea	FsDNom(a1),a1
FsFin1:	addq.w	#1,d3
	move.b	(a1)+,(a0)+
	bne.s	FsFin1
	tst.w	EdFSel(a5)
	bne.s	FsFin3
	subq.w	#1,d3
	ext.l	d3
	bsr	Demande
	move.w	d3,(a0)+
	lsr.w	#1,d3
	move.l	Name1(a5),a2
FsFin2:	move.w	(a2)+,(a0)+
	dbra	d3,FsFin2
	move.l	a0,HiChaine(a5)
	move.l	a1,d3
	moveq	#2,d2
	move.l	FsSp(a5),sp
	bsr	FillFFree
	bra	OpeRet
FsFin3:	clr.b	(a0)			* Pas FILLFREE si sous editeur
	move.l	Name1(a5),a0
	moveq	#-1,d0
	rts

******* ERREUR DANS LE SELECTEUR
FsError:move.l	FsSp(a5),sp
	Alea	MErreur,a0
	subq.w	#1,d0
	bmi.s	FsEr3
FsEr2:	tst.b	(a0)+
	bne.s	FsEr2
	dbra	d0,FsEr2
FsEr3:	move.l	a0,-(sp)
* Efface tout!
	bsr	FillFFree
	clr.w	FillFNb(a5)
	clr.w	FsPosF(a5)
	clr.w	FsPosFX(a5)
	clr.b	FsIFlag+1(a5)
	bsr	FsAPath
	bsr	FsAffF
	bsr	FsSli
* Affiche le message
	move.l	(sp)+,a1
	bsr	FsMess
* Retourne a la boucle!
	bra	FsLoop
******* Affiche un  message
FsMess:	move.l	a1,-(sp)
	WiCalD	QWindow,0
	WiCalA	Print,FsMess1(pc)
	move.l	(sp)+,d0
	beq.s	FsMm
	move.l	d0,a1
	WiCall	Centre
FsMm	WiCalA	Print,FsMess2(pc)
	bra	FsWind

******* Apparition / disparition par le centre
*	A2= ecran
*	d7= vitesse
*	d6= WTy
*	d5= WY
AppCentre:
	move.w	d6,d4
	move.w	d6,EcAWTy(a2)
	add.w	d6,EcAWTy(a2)
	bset	#2,EcAWT(a2)
	move.w	EcTy(a2),d0
	lsr.w	#1,d0
	sub.w	d6,d0
	move.w	d0,EcAVY(a2)
	bset	#2,EcAV(a2)
	move.w	d5,EcAWy(a2)
	sub.w	d6,EcAWy(a2)
	bset	#2,EcAW(a2)
	movem.l	a2/d4-d7,-(sp)
	jsr	Recop
	movem.l	(sp)+,a2/d4-d7
	add.w	d7,d6
	bpl.s	FsApp2
	clr.w	d6
FsApp2:	move.w	EcTy(a2),d0
	lsr.w	#1,d0
	cmp.w	d0,d6
	bcs.s	FsApp3
	move.w	d0,d6
FsApp3:	cmp.w	d4,d6
	bne.s	AppCentre
	rts

******* Effacement de l'ecran du selecteur
FsOut:	movem.l	d0-d2/a0-a2,-(sp)
	tst.w	FsFlag(a5)
	beq.s	FsO1
* Fait disparaitre lentement
	move.l	FsAdEc(a5),a2
	move.w	FsDVApp(a5),d7
	neg.w	d7
	move.w	EcTY(a2),d6
	lsr.w	#1,d6
	move.w	FsDWY(a5),d5
	add.w	#(21*8)/2,d5
	bsr	AppCentre
* Enleve de la memoire
	EcCalD	Del,EcFSel
	clr.w	FsFlag(a5)
* Remet la souris
	lea	FsLimSave(a5),a0
	lea	T_MouXMin(a5),a1
	moveq	#3,d0
FsO0	move.w	(a0)+,(a1)+
	dbra	d0,FsO0
* A y est
FsO1:	movem.l	(sp)+,d0-d2/a0-a2
	rts
******* Click dans le path
FsGPath	move.w	#1,FsWiAct(a5)
	bsr	FsWind
	bra	FsLoop
******* Click dans le nom
FsGNom:	move.w	#2,FsWiAct(a5)
	bsr	FsWind
	bra	FsLoop
******* Fleche vers le haut
FsHaut:	tst.w	FsPosF(a5)
	beq	FsLoop
	subq.w	#1,FsPosF(a5)
	bsr	GoAffF
	bra	FsLoop
******* Fleche vers le bas
FsBas:	move.w	FsPosF(a5),d0
	add.w	#9,d0
	cmp.w	FillFNb(a5),d0
	bcc	FsLoop
	addq.w	#1,FsPosF(a5)
	bsr	GoAffF
	bra	FsLoop	
******* Fleche vers la gauche
FsGoch	tst.w	FsPosFX(a5)
	beq	FsLoop
	subq.w	#1,FsPosFX(a5)
	bsr	GoAffF
	bra	FsLoop
******* Fleche vers la droite
FsDroi	cmp.w	#40,FsPosFx(a5)
	bcc	FsLoop
	addq.w	#1,FsPosFX(a5)
	bsr	GoAffF
	bra	FsLoop
******* Positionnement dans le slider VERTICAL (Y)
FsMou	jsr	XYMouEc
	move.w	d2,d0
	sub.w	#FsSlY,d0
	bmi	FsLoop
	cmp.w	#FsSlTy,d0
	bcc	FsLoop
	cmp.w	Fs_Slv1(a5),d0
	bcs	.Haut
	cmp.w	Fs_Slv2(a5),d0
	bcc	.Bas
** POSITIONNE DIRECTEMENT
	move.w	d2,d7
	sub.w	Fs_Slv1(a5),d7
.loop	sub.w	d7,d2
	bpl.s	.skip0
	moveq	#0,d2
.skip0	mulu	FillFNb(a5),d2
	divu	#FsSlTy,d2
	move.w	d2,d0
	add.w	#9,d0
	cmp.w	FillFNb(a5),d0
	bcs.s	.FsM1
	move.w	FillFNb(a5),d2
	sub.w	#9,d2
	bpl.s	.FsM1
	moveq	#0,d2
.FsM1:	move.w	d2,FsPosF(a5)
	move.w	d7,-(sp)
	bsr	FsSli
	move.w	(sp)+,d7
* Boucle?
.skip	bsr	WaitMul
	SyCall	Mousekey
	tst.w	d1
	beq.s	.exit
	jsr	XYMouEc
	bra.s	.loop
.exit	bsr	GoAfff
	bra	FsLoop
** SCROLL VERS LE HAUT
.Haut	move.w	FsPosF(a5),d0
	subq.w	#8,d0
	bpl.s	.se
	moveq	#0,d0
	bra.s	.se
** SCROLL VERS LE BAS
.Bas	move.w	FsPosF(a5),d0
	move.w	FillFNb(a5),d1
	sub.w	#9,d1
	addq.w	#8,d0
	cmp.w	d1,d0
	bls.s	.se
	move.w	d1,d0
.se	move.w	d0,FsPosF(a5)
	bsr	GoAfff
.Gli	bsr	WaitMul
	SyCall	MouseKey
	btst	#0,d1
	bne.s	.Gli
	bra	FsLoop
******* Parent / All
FsParent:
	tst.w	AccFlag(a5)
	bne	FaAll
	bsr	FsEffF
	move.l	Name1(a5),a0
	add.w	FsLPath1(a5),a0
	cmp.b	#"/",-(a0)
	bne	FsLoop
FsPa1:	move.b	-(a0),d0
	cmp.b	#"/",d0
	beq.s	FsPa2
	cmp.b	#":",d0
	bne.s	FsPa1
FsPa2:	clr.b	1(a0)
	bra	FsReLoop
* All
FaAll	move.l	Buffer(a5),a0
	lea	FsDNom(a0),a0
	move.b	#"*",(a0)+
	move.b	#"*",(a0)+
	clr.b	(a0)
	move.w	#2,FsLNom(a5)
	move.w	#2,FsCNom(a5)
	bra	FsFin

******* Efface le nom active!
FsEffF:	movem.l	d0-d7/a0-a2,-(sp)
	move.w	FsActive(a5),d1
	beq.s	FsEfx
	moveq	#0,d0
	bsr	FsAffT
	clr.w	FsActive(a5)
FsEfX:	movem.l	(sp)+,d0-d7/a0-a2	
	rts
	
******* Clicke dans un nom de fichier
FsFile:	move.w	d1,d0
	sub.w	#20,d0
	cmp.w	#10,d0
	bcc	FsLoop
	add.w	FsPosF(a5),d0
	bsr	FillGet
	beq	FsLoop
	lea	6+4(a0),a2
	btst	#0,FsIFlag(a5)
	bne.s	FsChDev
	cmp.b	#" ",(a2)+
	beq	FsCNm
* Changement de directory!
	bsr	FsEffF
	move.l	a2,a0
	moveq	#0,d0
FsChd1:	addq.w	#1,d0		* Verifie la taille!
	tst.b	(a0)+
	bne.s	FsChd1
	add.w	FsLPath(a5),d0
	cmp.w	#255,d0
	bcc	FsLoop
	move.l	Name1(a5),a0
	add.w	FsLPath1(a5),a0
FsChd2:	move.b	(a2)+,(a0)+
	bne.s	FsChd2
	bra	FsReLoop
* Fichier normal
FsCNm:	move.l	Buffer(a5),a0
	lea	FsDNom(a0),a0
	moveq	#-1,d0
	moveq	#0,d1
FsCnm1:	addq.w	#1,d0
	move.b	(a2)+,d2
	cmp.b	(a0),d2
	beq.s	FsCnm2
	addq.w	#1,d1
FsCnm2:	move.b	d2,(a0)+
	bne.s	FsCnm1
	tst.w	d1			* Double CLICK?
	beq	FsFin
	move.w	d0,FsLNom(a5)
	move.w	d0,FsCNom(a5)
	moveq	#0,d0
	bsr	FsANom
	bra	FsRLoop	
* Changement de device
FsChDev	move.l	Name1(a5),a0
	addq.l	#1,a2
FsDv1	move.b	(a2)+,(a0)+
	bne.s	FsDv1
	bra	FsReLoop

******* Mode devices/normal
FsGoDev	tst.w	AccFlag(a5)
	bne	FsLoop
	bchg	#0,FsIFlag(a5)
	bra	FsReLp
******* Rempli les noms de fichier
FsFirst	clr.w	FsPosF(a5)
	clr.w	FsPosFX(a5)
	clr.b	FsIFlag+1(a5)
	clr.w	FillF32(a5)
	move.w	#40,FillFSize(a5)
*	tst.w	AccFlag(a5)
*	bne.s	FaFill
	btst	#0,FsIFlag(a5)
	bne	FdFill
* Fichiers
	ALea	FsWait,a1
	bsr	FsMess
	move.b	#1,FsIFlag+1(a5)
	bsr	GetDir
	bsr	FillFirst
	bsr	FsMkPath
	moveq	#0,d0
	bra	FsAPath
* Accessoires
*FaFill	move.l	Name1(a5),a0
*	clr.b	(a0)	
*	bsr	FsMkPath
*	moveq	#0,d0
*	bsr	FsAPath
*	bra	FillAcc
* Devices
FdFill	move.l	Name2(a5),a0
	move.w	(a0),d0
	clr.w	(a0)
	bsr	FillDev
	move.w	d0,(a0)
	bsr	FsAffF
	bra	FsSli

******* Prend le nom suivant
FsNext	tst.b	FsIFlag+1(a5)
	beq	FaOut
	subq.b	#1,FsIFlag+1(a5)
	bne	FaOut
	bsr	FillNxt
	ble	FsNEnd
	move.b	#1,FsIFlag+1(a5)
	cmp.w	#1,d0
	beq	FaOut
	bra	FsAffF
FsNEnd	bsr	FsSli
	sub.l	a1,a1
	bra	FsMess
******* SORT! Trie le buffer
FsSort	bsr	FillSort
	bsr	GoAffF
	bra	FsLoop

******* Fabrique le PATH COMPLET en buffer+512
FsMkPath:
	movem.l	d0-d2/a0-a2,-(sp)
	moveq	#-1,d0
	clr.w	FsLPath1(a5)
	move.l	Buffer(a5),a1
	lea	512(a1),a1
	move.l	Name1(a5),a2
	clr.b	(a2)
	tst.w	AccFlag(a5)
	bne.s	FsMp3
* Path
	move.l	BufFillF(a5),a0
	lea	6+4(a0),a0
FsMp1:	addq.w	#1,d0
	move.b	(a0),(a1)+
	move.b	(a0)+,(a2)+
	bne.s	FsMp1
	move.w	d0,FsLPath1(a5)
	subq.w	#1,d0
	subq.l	#1,a1
* Filtre
FsMp3	move.l	Name2(a5),a0
FsMp2:	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	FsMp2
	move.w	d0,FsLPath(a5)
	move.w	d0,FsCPath(a5)
	movem.l	(sp)+,d0-d2/a0-a2
FaOut	rts

******* Recopie le PATHACT dans NAME1
FsCoPath
	tst.w	AccFlag(a5)
	bne.s	.skip
	move.l	Name1(a5),a1
	tst.b	(a1)
	bne.s	.skip
	move.l	PathAct(a5),a0
.loop	move.b	(a0)+,(a1)+
	bne.s	.loop
.skip	rts

******* Affiche le PATHNAME
FsAPath	movem.l	d0-d2/a0-a2,-(sp)
	move.w	d0,-(sp)
	WiCalD	QWindow,1
	lea	FsInv0(pc),a1
	move.w	(sp)+,d0
	bmi.s	FsAp4
	beq.s	FsAp0
	lea	FsInv1(pc),a1
FsAp0:	WiCall	Print
FsAp4:	WiCalA	Print,FsPath(pc)
* Affiche la partie visible
	move.l	Buffer(a5),a1
	lea	512(a1),a1
	WiCall	Print
* Positionne le curseur
	move.w	FsCPath(a5),d0
	moveq	#-1,d2
FsAp3:	addq.l	#1,d2
	move.w	d0,d1
	sub.w	#36,d0
	bpl.s	FsAp3
	WiCall	Locate
	movem.l	(sp)+,d0-d2/a0-a2
	bra	FsWind

******* Affiche le NOM FICHIER
FsANom:	movem.l	d0-d2/a0-a2,-(sp)
	move.w	d0,-(sp)
	WiCalD	QWindow,2
	lea	FsInv0(pc),a1
	move.w	(sp)+,d0
	bmi.s	FsAn1
	beq.s	FsAn0
	lea	FsInv1(pc),a1
FsAn0:	WiCall	Print
FsAn1:	WiCalA	Print,FsNom(pc)
	move.l	Buffer(a5),a1
	lea	FsDNom(a1),a1
	WiCall	Print
	move.w	FsCNom(a5),d1
	ext.l	d1
	move.l	#EntNul,d2
	WiCall	Locate
	movem.l	(sp)+,d0-d2/a0-a2
******* Reactive la fenetre
FsWind:	movem.l	d0-d2/a0-a2,-(sp)
	move.w	FsWiAct(a5),d1
	WiCall	QWindow
	movem.l	(sp)+,d0-d2/a0-a2
	rts

******* Affiche tous les noms de fichier
GoAfff	tst.b	FsIFlag+1(a5)
	bne	FaOut
	bsr	FsAfff
	bsr	FsSli
	rts
* Affiche tous les fichiers
FsAffF:	move.w	#20,-(sp)
FsAfff1	move.w	(sp),d1
	SyCall	RazZone
	move.w	(sp),d1
	moveq	#0,d0
	cmp.w	FsActive(a5),d1
	bne.s	FsAfff2
	moveq	#1,d0
FsAfff2	bsr	FsAffT
	addq.w	#1,(sp)
	cmp.w	#29,(sp)
	bcs.s	FsAfff1
	addq.l	#2,sp
	bra	FsWind

******* Affiche le slider!
FsSli	moveq	#FsSlTx,d1
	moveq	#FsSlTy,d2
	move.w	FillFNb(a5),d3
	subq.w	#1,d3
	bpl.s	.skip
	moveq	#0,d3
.skip	move.w	FsPosF(a5),d4
	moveq	#9,d5
	move.w	#FsSlX,d6
	moveq	#FsSlY,d7
	movem.l	d1-d7,-(sp)
	EcCall	VerSli
	movem.l	(sp)+,d1-d7
	move.w	d2,d0
	jsr	SliPour
	move.w	d6,Fs_slv1(a5)
	move.w	d7,Fs_slv2(a5)
	bra	FsWind

******* Affiche le TEXTE ACTIF #D1 - Inverse D0
FsAffT:	cmp.w	#18,d1
	beq	FsAPath
	cmp.w	#19,d1
	beq	FsANom
	movem.l	a0-a2/d0-d2,-(sp)
	WiCalD	QWindow,0
	movem.l	(sp)+,a0-a2/d0-d2
	movem.l	a0-a2/d0-d2,-(sp)
	cmp.w	#20,d1
	bcc.s	FsA2
	cmp.w	#17,d1
	bcc.s	FsAx
* Affichage normal
	move.w	d1,-(sp)
	lea	FsInv0(pc),a1
	tst.w	d0
	beq.s	FsA1
	lea	FsInv1(pc),a1
FsA1:	WiCall	Print
	move.w	(sp)+,d1
	lea	FsA(pc),a1
	lsl.w	#1,d1
	add.w	-2(a1,d1.w),a1
	WiCall	Print
FsAx:	movem.l	(sp)+,a0-a2/d0-d2
	bra	FsWind
* Affichage d'un nom de fichier
FsA2:	move.w	d0,-(sp)
	sub.w	#20,d1
	lea	FsTFile(pc),a1
	move.w	d1,d0			* Coordonnee en Y
	add.w	#48+5,d0
	move.b	d0,2(a1)
	move.l	a1,a2
FsA3:	cmp.b	#29,(a2)+
	bne.s	FsA3
	move.l	a2,d2
FsA4:	move.b	#" ",(a2)+
	cmp.b	#27,(a2)
	bne.s	FsA4
	move.w	d1,d0
	add.w	FsPosF(a5),d0
	bsr	FillGet
	bne.s	FsA5
* + Loin	
	move.b	#48+64,2(a2)		* Pas de zone
	lea	FsInv0(pc),a0
	addq.l	#2,sp
	bra.s	FsA7
* Dans les affiches
FsA5:	add.w	#48+20,d1
	move.b	d1,2(a2)		* Marque la zone
	lea	6+4(a0),a0
	add.w	FsPosfX(a5),a0		* Decalage en Y
	move.l	d2,a2
FsA6:	move.b	(a0)+,d0
	beq.s	FsA8
	move.b	d0,(a2)+
	cmp.b	#27,(a2)
	bne.s	FsA6
FsA8:	lea	FsInv0(pc),a0
	tst.w	(sp)+
	beq.s	FsA7
	lea	FsInv1(pc),a0
* Affiche!
FsA7:	move.l	a1,-(sp)
	move.l	a0,a1
	WiCall	Print
	move.l	(sp)+,a1
	WiCall	Print
	movem.l	(sp)+,a0-a2/d0-d2
	bra	FsWind
	
******* Copie le texte A0 dans le TEXTE ACTIF D1 (si defini!)
FsCopT:	movem.l	a1-a2/d0-d2,-(sp)
FsCt0	lea	FsA(pc),a1
	lsl.w	#1,d1
	add.w	-2(a1,d1.w),a1
	move.l	a1,a2
FsCt1:	move.b	(a2)+,d0
	beq.s	FsCt4
	cmp.b	#29,d0
	bne.s	FsCt1
FsCt2:	move.b	(a0)+,d0
	beq.s	FsCt4
	cmp.b	#27,(a2)
	beq.s	FsCt3
	move.b	d0,(a2)+
	bra.s	FsCt2
FsCt3:	tst.b	(a0)+
	bne.s	FsCt3
FsCt4:	move.l	a0,-(sp)
	WiCall	Print
	move.l	(sp)+,a0
	movem.l	(sp)+,a1-a2/d0-d2
	rts

******* UNPACK TO screen A1 TO d1 / Retour A0= screen base
DoUPack	movem.l	a1-a3/d0-d7,-(sp)
*
	move.w	ScOn(a5),-(sp)
	move.l	ScOnAd(a5),-(sp)
*
	move.l	Buffer(a5),a3
	lea	256(a3),a3
	move.l	a1,-(a3)
	move.l	AdTokens+8(a5),a0
	move.l	a0,a1
	moveq	#6-1,d0
.loop	cmp.w	#-1,(a0)+
	bne.s	.loop
	dbra	d0,.loop
	add.w	-4(a0),a1
	jsr	12(a1)
	move.l	ScOnAd(a5),a0
*
	move.l	(sp)+,ScOnAd(a5)
	move.w	(sp)+,ScOn(a5)
*
	movem.l	(sp)+,a1-a3/d0-d7
	rts

******* Zone temporaire
FsPosFX	equ	MnRA3
Fs_Slv1	equ	MnRA4
Fs_Slv2	equ	MnRA4+2
******* Entete AMOS Basic
	IFEQ	TkCode
EnHead	dc.b	"AMOS Basic V1.3 "
	ENDC
	IFNE	TkCode
EnHead	dc.b	"EasyAMOS AF.Demo"
	ENDC
******* Definition par defaut
PathMax equ 36*2
FsDNom:	equ 512+256+128
******* Activation zones actives
FsInv0:	dc.b 27,"I0",0
FsInv1:	dc.b 27,"I1",0
FsMess1	dc.b 27,"J7",27,"B2",27,"P1",27,"X2",27,"Y3",27,"Q",48+36,0
FsMess2	dc.b 27,"B2",27,"P3",27,"J1",0
FsTFile	dc.b 27,"Y0",27,"X2",27,"Z0",28,29,"                        ",27,"Z0",0
FsPathI:dc.b 27,"V0",27,"Z0",27,"X",48+35,27,"Y1",27,"Z",48+18,24,0
FsPath:	dc.b 25,0
FsNomI:	dc.b 27,"V0",27,"Z0",27,"X",48+35,27,"Z",48+19,27,"C0",24
	dc.b 27,"B2",27,"P3",0
FsNom:	dc.b 25,27,"C1",0
FsITit1 dc.b 27,"Y1",0
FsITit2	dc.b 27,"D1",27,"B2",27,"P3",27,"J1"
	dc.b 27,"X",48+FsSlX/8,27,"Y",48+FsSlY/8,27,"Z0",28,28,27,"Y",48+(FsSlY+FsSlTy)/8,27,"Z",48+17
	dc.b 27,"Y2",0
******* Slider
FsSlX	equ	26*8+4
FsSlY	equ	7*8+2
FsSlTx	equ	8
FsSlTy	equ	5*8-1-4
******* Zones actives disque
FsA:	dc.w 0,0,0,0,0
	dc.w 0,0,FsD18-FsA,FsD13-FsA,FsD17-FsA
	dc.w FsD10-FsA,FsD11-FsA,FsD12-FsA,FsD16-FsA
	dc.w FsD14-FsA,FsD15-FsA
FsD10:	dc.b 27,"X",48+30,27,"Y",48+9,27,"Z0",28,29,"        ",27,"Z",48+11,0
FsD11:	dc.b 27,"X",48+30,27,"Y",48+11,27,"Z0",28,29,"        ",27,"Z",48+12,0
FsD12:	dc.b 27,"X",48+30,27,"Y",48+13,27,"Z0",28,29,"        ",27,"Z",48+13,0
FsD13:	dc.b 27,"X",48+30,27,"Y",48+7,27,"Z0",28,29,"        ",27,"Z",48+9,0
FsD14:	dc.b 27,"X",48+26,27,"Y",48+5,27,"Z0",28,28,27,"Z",48+15,0
FsD15:	dc.b 27,"X",48+26,27,"Y",48+6,27,"Z0",28,28,27,"Z",48+16,0
FsD16:	dc.b 27,"X",48+26,27,"Y",48+12,27,"Z0",28,28,27,"Z",48+14,0
FsD17:	dc.b 27,"X",48+26,27,"Y",48+13,27,"Z0",28,28,27,"Z",48+10,0
FsD18:	dc.b 27,"X",48+30,27,"Y",48+5,27,"Z0",28,29,"        ",27,"Z",48+8,0
FaR:	dc.b 0
	even
