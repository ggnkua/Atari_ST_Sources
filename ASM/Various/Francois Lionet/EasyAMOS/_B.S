 
		SECTION CODE
*
		Include	"_Equ.s"
		RsSet	DataLong
		Include "_Pointe.s"
*
		Include	"_WEqu.s"
		Include "_CEqu.s"
		Include "_LEqu.s"
*
Ext_Nb		equ	5
Ext_TkCmp       equ     6
Ext_TkCOp       equ     $14
Ext_TkTston     equ     $28
Ext_TkTstof     equ     $3a
Ext_TkTst       equ     $4e
*
TkRemp		equ	"~"
*
Finale:		equ 	1
ROnly:		equ 	0
VDemo:		equ 	0
TkCode		equ 	0
*
EzDatas		equ	32*2+DefEPa
LRunData	equ	EzDatas
LRunFlag	equ	LRunData
Environs	equ	LRunData+64*2
EzAlerts	equ	Environs+2+2*17*8
*
******************************************************************
*		6/10/1991
******************************************************************
		INCDIR	":AMOS.s/ABC/"
******************************************************************
;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* EDITEUR / INTERPRETEUR
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------


;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* INITIALISATION DE L'EDITEUR
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

Fk_sx		equ	640
Fk_sy		equ	55
Fk_np		equ	3
Fk_nc		equ	8
Ed_sx		equ	640
Ed_np		equ	3
Ed_nc		equ	8

HSli_Dx		equ	4
HSli_Dy		equ	2
HSli_Fx		equ	6
HSli_Fy		equ	3

VSli_Dx		equ	4
VSli_Dy		equ	2
VSli_Fx		equ	4
VSli_Fy		equ	4

W:	move.l	sp,SaveSp
	movem.l	a0/d0,-(sp)
******* Recherche et stoppe les programmes AMOS lancés...
	move.l	$4.w,a6
	jsr	Forbid(a6)
	lea	TaskName(pc),a1
	jsr	FindTask(a6)
	tst.l	d0
	beq.s	.skip
	move.l	d0,a0
	move.l	10(a0),a1
	move.b	#"S",(a1)		* STOP!!!
	move.l	a1,H_Stopped
.skip	jsr	Permit(a6)
* Change son propre nom...
	sub.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,a0
	move.l	d0,d5
	move.l	d0,H_MyTask
	move.l	10(a0),H_OldName
	lea	TaskName(pc),a1
	move.l	a1,10(a0)
* CLI ou WORKBENCH?
	tst.l	$ac(a0)
	bne.s	.skup
	lea	$5c(a0),a0
	move.l	a0,-(sp)
	jsr	-384(a6)		* WaitPort
	move.l	(sp)+,a0
	jsr	-372(a6)		* GetMsg
	move.l 	d0,Message
.skup

******* Init GRAPHICS Library
	moveq	#0,d0
	lea	GfxName(pc),a1
	jsr	OpenLib(a6)
	move.l	d0,_GfxBase
	beq	TheEnd
******* Ouvre le DOS
	moveq	#0,d0
	lea	DosName(pc),a1
	jsr	OpenLib(a6)		OpenOldLibrary
	move.l	d0,a6
	move.l	d0,_DosBase
* Si WB---> Change le DIR
	move.l	Message(pc),d0
	beq.s	IDs1
	move.l 	d0,a0
	move.l	$24(a0),d0
	beq.s	IDs1
	move.l	d0,a0
	move.l	(a0),d1
	beq.s	IDs1
	jsr	DosCuDir(a6)
IDs1

* Adresse des datas
	moveq	#2,d0
	bsr	GHunk
	move.l	d0,d2
	lea	4(a1),a2		; Saute le dc.l Datalong
* Adresse du W.Lib
	moveq	#1,d0
	bsr	GHunk
	move.l	a1,a4
	move.l	a4,Ad_W

* Reserve la zone de datas...
	move.w	EdTyM0-DataLong(a2),d1
	cmp.w	#22,d1
	bcc.s	.Skip
	moveq	#22,d1
.Skip	mulu	#256,d1
	move.l	d1,d0			;   Longueur du buffer
	add.l	8(a4),d0		; + Longueur datas W
	add.l	#DataLong,d0		; + Longueur datas BASIC
	add.l	d2,d0			; + Longueur messages
	move.l	d0,Size_Buffers
	jsr	RamFast
	beq	TheEnd
	move.l	d0,a1			; A1- Bas des buffer
	move.l	d0,a5
	move.l	d0,Ad_Buffers
	add.l	d1,a5
	move.l	a5,a0			; A0- Haut des buffers
	add.l	8(a4),a5		; A5- Datazone!
* Adresse de la tache
	move.l	d5,T_MyTask(a5)

* Trouve toutes les adresses de buffers...
	lea	-32(a0),a0
	move.l	a0,BufLabel(a5)		* Buffer label expression
	lea	-BbLong(a0),a0
	move.l	a0,BufBob(a5)		* Buffer dessin d'un bob
	lea	-12*2(a0),a0
	move.l	a0,MnTDraw(a5)		* Buffer outline menus
	lea	-(AreaSize*5+6)(a0),a0
	move.l	a0,AreaBuf(a5)		* Zone pour les AREAFILL
	lea	-24(a0),a0
	move.l	a0,AreaInfo(a5)
	lea	-16(a0),a0
	move.l	a0,BufAMSC(a5)		* Buffers chargement IFF
	lea	-12(a0),a0
	move.l	a0,BufCCRT(a5)
	lea	-70*3(a0),a0
	move.l	a0,BufCMAP(a5)
	lea	-4(a0),a0
	move.l	a0,BufCAMG(a5)
	lea	-20(a0),a0
	move.l	a0,BufBMHD(a5)
	lea	-108(a0),a0
	move.l	a0,DirFNeg(a5)		* Filtre negatif directory
	lea	-108(a0),a0
	move.l	a0,Name2(a5)		* Buffers nom disque
	lea	-256(a0),a0
	move.l	a0,Name1(a5)
	lea	-TBuffer(a0),a0	
	move.l	a0,Buffer(a5)		* Buffer
* Autres buffers
	move.l	a1,EdBufE(a5)		* Buffer d'edition	
	move.l	a1,BufEsc(a5)		* Touches mode Escape
* Limite le buffer de boucles
	move.l	a1,BaLoop(a5)
	move.l	a0,HoLoop(a5)
******* Copie les messages
	lea	DataLong(a5),a3
	subq.b	#1,d2
.Copy	move.b	(a2)+,(a3)+
	dbra	d2,.Copy
******* Efface l'ancien .ENV
	moveq	#2,d0
	bsr	DHunk

******* Buffer du PATHACT
	move.l	#256,d0
	jsr	RamFast
	beq	TheEnd
	move.l	d0,PathAct(a5)

******* WB---> Un programme a charger???
	move.l	Message(pc),d0
	beq.s	FrCli
	move.l	d0,a0
	cmp.l	#2,$1c(a0)
	bne	WBErr
	move.l	$24(a0),d0
	beq	WBErr
	move.l	d0,a4
	move.l	8(a4),d1
	jsr	DosCuDir(a6)
	move.l	12(a4),d0
	beq	WBErr
	move.l	d0,a0
	lea	BuFloat(a5),a1
WbL1	move.b	(a0)+,(a1)+
	bne.s	WbL1
	bra.s	WFin

******* Vient du CLI
FrCli	movem.l	(sp),a0/d0
	moveq	#0,d7
	lea	BuFloat(a5),a1
	clr.b	(a1)
	cmp.w	#1,d0
	bls.s	WX
	clr.b	-1(a0,d0.w)
* Explore la ligne de commande
W0	move.b	(a0)+,d0
	beq.s	WX
	cmp.b	#" ",d0
	beq.s	W0
	cmp.b	#"-",d0
	bne.s	W1
* Environnement?
	move.b	(a0),d0
	cmp.b	#"e",d0
	beq.s	.skip1
	cmp.b	#"E",d0
	bne.s	.skip2
.skip1	tst.b	(a0)+
	move.b	(a0)+,d0
	sub.b	#"0",d0
	and.w	#$07,d0
	move.w	d0,Environs(a5)
	bra.s	W0
* Taille de l'editeur?
.skip2	bsr	DecLong
	bne.s	W0
	move.l	d0,d7
	bra.s	W0
W1	move.b	d0,(a1)+
W2	move.b	(a0)+,d0
	beq.s	WX
	cmp.b	#32,d0
	bne.s	W1
	bra.s	W2
* Initialise la RAM
WbErr	lea	BuFloat(a5),a1
	moveq	#0,d7
WX	clr.b	(a1)
	move.l	d7,d0
	jsr	ChgTTexte
	beq	TheEnd
WFin	addq.l	#8,sp

******* On se debarrasse
	move.l	a6,DosBase(a5)
	move.l	_GfxBase(pc),T_GfxBase(a5)

******* Init INTUITION library / Find version!
	move.l	$4.w,a6
	moveq	#37,d0
	move.l	d0,d3
	lea	IntName(pc),a1
	jsr	OpenLib(a6)
	tst.l	d0
	bne.s	.Skp
	moveq	#36,d0
	move.l	d0,d3
	lea	IntName(pc),a1
	jsr	OpenLib(a6)
	tst.l	d0
	bne.s	.Skp
	moveq	#0,d0
	move.l	d0,d3
	lea	IntName(pc),a1
	jsr	OpenLib(a6)
.Skp	move.l	d0,T_IntBase(a5)
	move.w	d3,WB2.0(a5)

******* Init FLOAT library
	moveq	#0,d0
	lea	FloatName(pc),a1
	jsr	OpenLib(a6)
	move.l	d0,FloatBase(a5)
	move.l	#$c90fd942,ValPi(a5)
	move.l	#$b4000048,Val180(a5)
******* Init ICON Library
;	tst.w	Icons(a5)
;	beq.s	PaIcons
;	moveq	#0,d0
;	lea	IconName(pc),a1
;	jsr	OpenLib(a6)
;	move.l	d0,IconBase(a5)
;	move.l	d0,a6
;	Alea	DefIcon,a0
;	jsr	-78(a6)
;	move.l	d0,AdrIcon(a5)
;	beq.s	PaIcons
;	move.l	d0,a0
;	clr.l	$3a(a0)
;	clr.l	$3e(a0)
;PaIcons

* Branche le jeu de caracteres
	move.l	#DFont,T_JeuDefo(a5)
* Branche le clavier
	move.l	#DKy,T_ClAsc(a5)
* Branche la souris
	bsr	LdMouse

******* Attend que l'autre AMOS soit arrete!
	move.l	H_Stopped(pc),d0
	beq.s	.Wait2
	move.l	d0,a2
	move.w	#50*5,d3
.Wait1	move.l	T_GfxBase(a5),a6
	jsr	-270(a6)
	cmp.b	#"S",(a2)
	bne.s	.Wait2
	dbra	d3,.Wait1
	bra	TheEnd
.Wait2

******* Demarrage des interruptions 
	bsr	Sys_ClearCache
	lea	Paratrap(a5),a0
	move.l	Ad_W(pc),a1
	moveq	#1,d0
	jsr	(a1)
	move.w	#-1,W_Started
* Fabrique l'areainfo
	lea	AreaInfo(a5),a0
	lea	AreaBuf(a5),a1
	moveq	#AreaSize,d0
	move.l	T_RastPort(a5),a2
	move.l	a0,16(a2)
	GfxCa5	InitArea
	
***********************************************************
*	EXTENSIONS LOADING
	lea	AdTokens(a5),a6
	move.l	#DebTk-6,(a6)+
	moveq	#0,d6
.loop	bsr	LdExt
	addq.w	#1,d6
	addq.l	#4,a6
	cmp.w	#3,d6
	bne.s	.loop

***********************************************************
*	Reserve les ecrans / Fait apparaitre les fenetres
***********************************************************
	SyCall	Show,-1

******* Positions NTSC/PAL
	EcCall	MaxRaw
	move.w	d1,d0
	sub.w	#35,d0
	move.w	d0,EcYErr(a5)
	sub.w	#101,d1
	move.w	d1,EsWY(a5)
******* Tailles editeur
	EcCall	NTSC			* Si NTSC->>> petit ecran
	tst.l	d1
	beq.s	.skip
	subq.w	#4,EdTyM0(a5)
.skip	move.w	EdTyM0(a5),d0
	subq.w	#1,d0
	move.w	d0,EdTyM1(a5)
	subq.w	#1,d0
	move.w	d0,EdTyM2(a5)
	sub.w	#9-2,d0
	lsl.w	#3,d0
	move.w	d0,EsVY(a5)
	ALea	EscI,a0
	bsr	ChgTY

******* Cree l'ecran FKEY
sstop	move.l	#Fk_sx,d2
	move.l	#Fk_sy,d3
	moveq	#Fk_np,d4
	move.l	#$8000,d5
	moveq	#Fk_nc,d6
	moveq	#0,d7
	lea	DefPal(a5),a1
	EcCalD	Cree,EcFonc
	move.w	#-64,EcAWY(a0)
	bset	#2,EcAW(a0)
	move.l	a0,FkEcran(a5)
	move.w	EdColB(a5),EcPal(a0)
	bsr	CopyPal
	SyCalD	ResZone,10
	ALea	FkFond,a1
	WiCall	Print
	
******* Ouverture de l'ecran d'edition
	move.l	#Ed_sx,d2
	move.w	EdTyM0(a5),d3
	addq.w	#1,d3
	mulu	#8,d3
	moveq	#Ed_np,d4
	move.l	#$8000,d5
	move.b	InterEdit(a5),d5
	moveq	#Ed_nc,d6
	moveq	#0,d7
	lea	DefPal(a5),a1
	EcCalD	Cree,EcEdit
	move.l	a0,EdEcran(a5)
	move.w	#312,EcAWY(a0)
	bset	#2,EcAW(a0)
	bsr	CopyPal
	SyCalD	ResZone,10	
	moveq	#0,d2
	moveq	#0,d3
	moveq	#EdTx,d4
	move.w	EdTyM0(a5),d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCalD	WindOp,1


***********************************************************
*	TITLES
	bsr	InitTok
	bsr	EdEcInit
	bsr	EdInit

***********************************************************
*	Close the workbench?
	tst.w	AutoWB(a5)
	beq.s	PaAWb
	jsr	ClosWB
PaAWb:
	IFEQ	ROnly
	move.w	#1,T_AMOState(a5)
	ENDC
	EcCalD	AMOS_WB,1	

******* Fait les assigns automatiques
	bsr	AutoAssigns

***********************************************************
*	Adresse des datas pour AMOS_Switcher
	move.l	sp,BasSp(a5)
	move.l	H_MyTask(pc),a0
	move.l	a5,$58(a0)
	moveq	#Switcher_Signal,d3
	bsr	Send_Switcher

	EcCalD	AMOS_WB,1

***********************************************************
*	CHARGEMENT OU AUTOEXEC.AMOS?
	lea	BuFloat(a5),a0
	tst.b	(a0)
	beq.s	LAut1
	move.l	Name1(a5),a1
LAut0	move.b	(a0)+,(a1)+
	bne.s	LAut0
	bra.s	LAut3
LAut1	Alea	AutoEx,a0
	move.l	Name1(a5),a1
LAut2	move.b	(a0)+,(a1)+
	bne.s	LAut2
LAut3	move.w	#2,EdDisk(a5)
	move.l	#1005,d2
	jsr	FOpen
	jsr	GetAMOS
	move.l	16(a2),d0
	add.l	#258,d0
	tst.l	StTTexte(a5)
	bne.s	LAut4
	jsr	ChgTTexte
	beq.s	NoAuto
	jsr	RNew2
LAut4	jsr	LLAuto
	clr.w	EdDisk(a5)
	move.l	Name1(a5),a0
	lea	NamePrg(a5),a1
	jsr	CoCop
	IfNE	ROnly
	jsr	ClosEd
	EndC
; Enleve l'image de titre...
	moveq	#2,d0
	bsr	DHunk
	bra	Run
* En cas d'erreur de chargement
NoAuto	
	IfEQ	ROnly
	clr.w	EdDisk(a5)
	jsr	FClose
	tst.l	StTTexte(a5)
	bne.s	NoAut
	lea	DefSize(a5),a0
	move.l	(a0),d0
	jsr	ChgTTexte
	beq	TheEnd
	jsr	RNew
NoAut	bsr	NewBuf
	bsr	AverFin

*********************************************************************
* 	Display title picture
Tit_Wx	equ	176
Tit_Wy	equ	90
	moveq	#0,d1
	moveq	#-1,d2
	EcCall	EHide

	moveq	#2,d0
	bsr	GHunk
	moveq	#EcFSel,d1
	jsr	DoUPack
	move.l	a0,a2
	moveq	#0,d1
	move.w	EdColB(a5),d2
	EcCall	SCol
	move.w	#Tit_Wx,EcAWX(a2)
	bset	#1,EcAW(a2)
	move.w	#4,d7
	moveq	#1,d6
	move.w	#Tit_Wy,d5
	move.w	EcTy(a2),d0
	lsr.w	#1,d0
	add.w	d0,d5
	jsr	AppCentre
	moveq	#2,d0
	bsr	DHunk
	move.w	#250,d0
	bsr	TiWait

* EDITOR SCREEN APPERANCE
	bsr	AffVers
	EcCalD	Active,EcEdit
	WiCalD	QWindow,1
	ALea	Title1,a1
	WiCall	Print
	bsr	EdScrol
	jsr	ClearVar
	jsr	EffBanks

* Arret de l'ecran de titre 
	EcCalD	Del,EcFSel

* Apparition de l'ecran par defaut
	moveq	#0,d1
	moveq	#0,d2
	EcCall	EHide

* Effacement du titre
	move.w	#250,d0
	bsr	TiWait
	EcCalD	Active,EcEdit	
	WiCalD	QWindow,1
	ALea	Title2,a1
	WiCall	Print

***********************************************************
*	CALL EDITOR'S LOOP
	move.l	BasSp(a5),sp
	bra	EdLoop
	EndC

	
***********************************************************
*	END! 
TheEnd	move.l	Ad_Buffers(pc),d0
	beq	TEnd2

******* Les datas ont ete reserves...

* Empeche le switcher de fonctionner
	moveq	#Switcher_Signal+1,d3
	bsr	Send_Switcher

* Efface tous les accessoires
*	jsr	AccEAll

* Efface les zones de l'interpréteur
	moveq	#0,d0
	bsr	ChgTTexte
	moveq	#0,d1
	jsr	ResVarBuf
	moveq	#0,d1
	jsr	ResVNom
	moveq	#0,d0
	bsr	EdBlFree
* Arrete les extensions
	lea	ExtAdr+26*16(a5),a3
	lea	AdTokens+4+26*4(a5),a4
	moveq	#26-1,d4
; Appelle la routine QUIT
.loop0	
	move.l	-8(a3),d0
	beq.s	.loop1
	move.l	d0,a0
	movem.l	a0-a6/d0-d7,-(sp)
	jsr	(a0)
	movem.l	(sp)+,a0-a6/d0-d7
.loop1	
; Enleve l'extension de la memoire
	move.l	-4(a4),d0
	beq.s	.loop2
	move.l	d0,a1
	move.l	-(a1),d0
	jsr	RamFree
.loop2
; Extension précédente
	lea	-16(a3),a3
	lea	-4(a4),a4
	dbra	d4,.loop0

* Enleve la W.Lib
	SyCall	WaitVbl
	move.l	Ad_W(pc),d0
	beq.s	.Skip0
	move.l	d0,a0
	move.w	W_Started(pc),d0
	beq.s	.Skip0
	jsr	4(a0)
.Skip0
* Ferme les fichiers/l'imprimante
	jsr	FClose
	jsr	CloAll
	move.l	DosBase(a5),a6
	move.l	PrtHandle(a5),d1
	beq.s	.Skip
	jsr	DosClose(a6)
.Skip
* Enleve les fichiers systeme
	bsr	EffMouse	Enleve la souris
	bsr	EffTok		Enleve la tokenisation
* Enleve PATHACT
	move.l	PathAct(a5),d0
	beq.s	.SkipP	
	move.l	d0,a1
	move.l	#256,d0
	jsr	RamFree
.SkipP

	move.l	$4.w,a6

* Libere l'icone
;	move.l	AdrIcon(a5),d0
;	beq.s	.SkipI
;	move.l	d0,a0
;	move.l	IconBase(a5),a6
;	jsr	-90(a6)
;.SkipI
;* Ferme icon.library
;	move.l	$4.w,a6
;	move.l	IconBase(a5),d0
;	beq.s	.Skip1
;	move.l	d0,a1
;	jsr	CloseLib(a6)
;.Skip1
* Ferme les librairies mathématiques
	move.l	FloatBase(a5),d0
	beq.s	.Skip2
	move.l	d0,a1
	jsr	CloseLib(a6)
.Skip2	
	move.l	MathBase(a5),d0
	beq.s	.Skip3
	move.l	d0,a1
	jsr	CloseLib(a6)
.Skip3	
* Ferme Intuition
	move.l	T_IntBase(a5),d0
	beq.s	.Skip4
	move.l	d0,a1
	jsr	CloseLib(a6)
.Skip4
******* Si la DATA ZONE n'est pas réservée
TEnd2	
* Relance l'ancien AMOS
	move.l	H_Stopped(pc),d0
	beq.s	.Skup
	move.l	d0,a0
	move.b	#" ",(a0)
.Skup
* Remet son ancien nom
	move.l	H_MyTask(pc),d0
	beq.s	.Skiip
	move.l	d0,a0	
	move.l	H_OldName(pc),10(a0)
.Skiip
* Ferme la librairie graphique
	move.l	$4.w,a6
	move.l	_GfxBase(pc),d0
	beq.s	.Skip1
	move.l	d0,a1
	jsr	CloseLib(a6)
.Skip1
* Ferme le DOS 
	move.l	_DosBase(pc),d0
	beq.s	.Skip2
	move.l	d0,a1
	jsr	CloseLib(a6)		
.Skip2
* Enleve la datazone	
	move.l	Ad_Buffers(pc),d0
	beq.s	.Skip3	
	move.l	d0,a1
	move.l	Size_Buffers(pc),d0
	jsr	RamFree
.Skip3
* Renvoie le message au workbench!
	move.l	SaveSp(pc),a7
	move.l	Message(pc),d2
	beq.s	.Skip4
	move.l	$4.w,a6
	jsr	Forbid(a6)
	move.l 	d2,a1
	jsr	-378(a6)
* Pas d'erreur...
.Skip4	
	moveq	#0,d0
	rts


******* Envoie un signal à l'AMOS_Switcher
Send_Switcher
	lea	Switcher(pc),a1
	move.l	$4.w,a6
	jsr	-294(a6)		FindTask
	tst.l	d0
	beq.s	.PaSwi
	move.l	d0,a1
	moveq	#0,d0
	bset	d3,d0
	jsr	-324(a6)		Signal
.PaSwi	rts

******* Get Hunk: ramene l'adresse d'un HUNK
*	D0=	numero du hunk
*	>	A0: Adresse origine
*	>	A1= Adresse hunk
*	>	D0= Lon
GHunk	move.l	d0,d1
	lea	W(pc),a1
.loop	move.l	a1,a0
	move.l	-4(a0),d0
	lsl.l	#2,d0
	move.l	d0,a1
	move.l	-4(a1),d0
	addq.l	#4,a1
	subq.w	#1,d1
	bne.s	.loop
	rts
******* Del Hunk
DHunk	bsr	GHunk
	move.l	a0,d1
	beq.s	.skip
	move.l	-4(a1),-4(a0)
.skip	subq.l	#8,a1
	jmp	RamFree

*************** Adresses des routines accessibles aux extensions
AMOSJmps
; Routine d'erreur normale	
	dc.w	L_Error
	dc.l	RunErr
; Routine d'erreur specifique
	dc.w	L_ErrorExt
	dc.l	RunErrExt
; D3->A0 Bank address
	dc.w	L_BkAd
	dc.l	BkAd
; Tests
	dc.w	L_Tests
	dc.l	Tests
; Wait routine
	dc.w	L_WaitRout
	dc.l	WaitRout
; Screen address
	dc.w	L_GetEc
	dc.l	GetEc
; Address or bank
	dc.w	L_AdOuBank
	dc.l	AdOuBank
; Erase bank D3
	dc.w	L_EffBank
	dc.l	EffBank
; Ask for string space
	dc.w	L_Demande
	dc.l	Demande
; Ram
	dc.w	L_RamFast	
	dc.l	RamFast
	dc.w	L_RamFast2
	dc.l	RamFast2
	dc.w	L_RamChip
	dc.l	RamChip
	dc.w	L_RamChip2
	dc.l	RamChip2
	dc.w	L_RamFree
	dc.l	RamFree
; Finished!
	dc.w	0
CNop	nop
*************** Noms des Librairies
Message		dc.l	0
Ad_W		dc.l	0
W_Started	dc.w	0
SaveSp		dc.l 	0
_GfxBase	dc.l	0
_DosBase	dc.l	0
Size_Buffers	dc.l	0
Ad_Buffers	dc.l	0
H_Stopped	dc.l	0
H_OldName	dc.l	0
H_MyTask	dc.l	0
TaskName	dc.b	" AMOS",0
Switcher	dc.b	"_Switcher AMOS_",0
IconName:	dc.b 	"icon.library",0
FloatName:	dc.b 	"mathffp.library",0
MathName:	dc.b 	"mathtrans.library",0
IntName:	dc.b 	"intuition.library",0
		
Version:	dc.b	"Version 1.10 ",0
Nom_WW:		dc.b	0

*************** Nom des datas
Nom_W		ds.b	32
		IFEQ ROnly
NDatasPAL2:	dc.b 	0
NDatasPAL1:	dc.b 	0
NDatasNTSC2:	dc.b 	0
NDatasNTSC1:	dc.b 	0
NDatas2:	dc.b 	0
NDatas1:	dc.b 	0
		ENDC
		IFNE ROnly
NDatasPAL2:	dc.b 	0
NDatasPAL1:	dc.b 	0
NDatasNTSC2:	dc.b 	0
NDatasNTSC1:	dc.b 	0
NDatas2:	dc.b 	0
NDatas1:	dc.b 	0
		ENDC
		dc.b	0,"$VER: 1.01",0
GfxName:	dc.b 	"graphics.library",0
DosName:	dc.b 	"dos.library",0
		even

******************************************************************
	Include "_Token.s"
	Include "_Verif.s"
	Include "_Edit.s"
******************************************************************
******* Fait les assigns automatiquement!
AutoAssigns
	lea	AssInst(pc),a0
	move.l	Name1(a5),a1
	bsr	CoCop
	bsr	RExist
	beq.s	.NoAss
	bsr	AskDir
	lea	AssCon(pc),a0
	move.l	a0,d1
	move.l	#1004,d2
	move.w	#DosOpen,d7
	bsr	DosCall
	beq.s	.NoAss
	move.l	d0,ParamE(a5)
	lea	AssEasy(pc),a0
	bsr	DoAssign
	lea	AssEx(pc),a0
	bsr	DoAssign
	lea	AssTut(pc),a0
	bsr	DoAssign
	move.l	ParamE(a5),d1
	move.w	#DosClose,d7
	bsr	DosCall
.NoAss	rts
* Routine, fait les assigns, si possible!
DoAssign
	move.l	a0,-(sp)
	move.l	Name1(a5),a1		* Regarde si existe deja!
	bsr	CoCop
	move.l	a0,-(sp)
	bsr	RExist
	bne.s	.NoAss

	move.l	Buffer(a5),a0		* Fabrique le path normal
	lea	384(a0),a0
	move.l	Name1(a5),a1
	bsr	CoCop
	subq.l	#1,a1
	move.l	(sp),a0
	bsr	CoCop
	bsr	RExist
	beq.s	.NoAss

	lea	AssCall(pc),a0		* Appelle la commande
	move.l	Buffer(a5),a1	
	bsr	CoCop
	move.l	4(sp),a0
	subq.l	#1,a1
	bsr	CoCop
	move.b	#32,-1(a1)
	move.b	#'"',(a1)+
	move.l	Name1(a5),a0
	bsr	CoCop
	move.b	#'"',-1(a1)
	clr.b	(a1)
	move.l	Buffer(a5),d1
	move.l	ParamE(a5),d2
	move.l	ParamE(a5),d3
	move.l	DosBase(a5),a6
	jsr	-222(a6)
.NoAss	addq.l	#8,sp
	rts
AssInst	dc.b	"c:assign",0
AssCall	dc.b	"c:assign ",0 
AssEasy	dc.b	"Easy_AMOS:",0
	dc.b	0
AssEx	dc.b	"Easy_Examples:",0
	dc.b	"Easy_Examples",0
AssTut	dc.b	"Easy_Tutorial:",0
	dc.b	"Easy_Tutorial",0
AssCon	dc.b	"NIL:",0
	even
***********************************************************
SetFolow
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	bsr	Sys_ClearCache
	rts

;	Clear CPU Caches, quel que soit le systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sys_ClearCache
	movem.l	a0-a1/a6/d0-d1,-(sp)
	move.l	$4.w,a6
	cmp.w	#37,WB2.0(a5)			A partir de V37
	bcc.s	.Skip
	jsr	FindTask(a6)
	bra.s	.Exit
.Skip	jsr	-$27c(a6)			CacheClearU
.Exit	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts

******************************************************************
* WAIT FOR KEY PRESS
TiWait: move.w	d0,-(sp)
.loop	bsr	WaitMul
	SyCall	Inkey
	tst.l	d1
	bne.s	.end
	SyCall	MouseKey
	and.w	#%111,d1
	bne.s	.end
	subq.w	#1,(sp)
	bne.s	.loop
.end	addq.l	#2,sp
	rts
* Affichage de la version
AffVers	EcCalD	Active,EcFonc
	Alea	EtAl,a1
	WiCall	Print
	lea	Version(pc),a1
	WiCall	Centre 
	EcCalD	Active,EcEdit
	move.w	#1,EtMess(a5)
	rts
***********************************************************
*	FICHIERS SYSTEME

******* Branchement de l'extension #D6
LdExt	moveq	#2,d0
	bsr	GHunk
* Regarde l'entete
	move.l	a1,a3
	move.l	(a3),d3
	move.l	d3,d5
	lsr.w	#1,d5			* D5= nombre de fonctions
	lea	18(a3),a4
	lea	18(a3,d3.l),a1
* Copy la routine en mémoire...
	move.l	4(a3),d3
	add.l	8(a3),d3
	add.l	12(a3),d3
	move.l	d3,d0
	addq.l	#8,d0
	move.l	d0,d1
	jsr	RamFast2
	move.l	d0,a2
	move.l	d1,(a2)+
	move.l	a2,(a6)			* Adresse des TOKENS=Ad extension!!!
	move.l	a2,a0
	lsr.l	#1,d3
.loop	move.w	(a1)+,(a0)+
	subq.l	#1,d3
	bne.s	.loop
* Fabrique la table d'adresse des routines
	move.w	d5,d0
	subq.w	#1,d0
	move.l	a2,d1
	add.l	4(a3),d1
	move.l	a4,a0
	move.l	a0,a1
	add.l	(a3),a1
	move.l	a1,a3
	moveq	#0,d2
.Loop1	move.l	d1,(a1)+
	move.w	(a0)+,d2
	add.l	d2,d1
	add.l	d2,d1
	dbra	d0,.Loop1
	move.l	d1,(a1)+
	clr.l	(a1)
* Reloge la table de tokenisation
	move.l	(a6),a0
	move.l	a0,d1
	lea	6(a0),a0
.Loop2	move.w	(a0),d0
	beq.s	.Loop4
	bmi.s	.Loop3
	lsl.w	#2,d0
	move.l	0(a3,d0.w),d2
	sub.l	d1,d2
	move.w	d2,(a0)
.Loop3	move.w	2(a0),d0
	beq.s	.Loop4
	bmi.s	.Loop4
	lsl.w	#2,d0
	move.l	0(a3,d0.w),d2
	sub.l	d1,d2
	move.w	d2,2(a0)
.Loop4	addq.l	#4,a0
.Loop5	tst.b	(a0)+
	bpl.s	.Loop5
.Loop6	tst.b	(a0)+
	bpl.s	.Loop6
	move.w	a0,d0
	and.w	#$0001,d0
	add.w	d0,a0
	tst.w	(a0)
	bne.s	.Loop2
* Relocation des routines...
	moveq	#0,d3
GRouN	move.l	0(a3,d3.w),a0
	move.l	4(a3,d3.w),d4
	beq	GRouX
	addq.w	#4,d3
GRou1	cmp.l	d4,a0
	bcc.s	GRouN
	move.b	(a0),d0
	cmp.b	#C_Code1,d0
	beq	GRou10
GRou2	addq.l	#2,a0
	bra.s	GRou1
;-----> Instruction speciale
GRou10	move.w	(a0),d0
	move.b	d0,d2
	and.b	#$0F,d0
	cmp.b	#C_Code2,d0
	bne	GRou2
	and.w	#$00F0,d2
	lsr.w	#1,d2
	lea	GRout(pc),a1
	jmp	0(a1,d2.w)
;-----> Table des sauts
GRout	bra.s	GRouJ			; 0 - RJmp
	jmp	$FFFFF0
	bra.s	GRouJ			; 1 - RJsr
	jsr	$FFFFF0
	bra	GRouB			; 2 - RBra
	bra	GRout
	bra	GRouB			; 3 - RBsr
	bsr	GRout
	bra	GRouB			; 4 - RBeq
	beq	GRout
	bra	GRouB			; 5 - RBne
	bne	GRout
	bra	GRouB			; 6 - RBcs
	bcs	GRout
	bra	GRouB			; 7 - RBcc
	bcc	GRout
	bra	GRouB			; 8 - RBlt
	blt	GRout
	bra	GRouB			; 9 - RBge
	bge	GRout
	bra	GRouB			; 10- RBls
	bls	GRout
	bra	GRouB			; 11- RBhi
	bhi	GRout
	bra	GRouB			; 12- RBle
	ble	GRout
	bra	GRouB			; 13- RBpl
	bpl	GRout
	bra	GRouB			; 14- RBmi
	bmi	GRout
	bra	GRouD			; 15- RData
;-----> RJMP / RJSR
GRouJ	cmp.b	#C_CodeJ,2(a0)
	bne	GRou2
	moveq	#0,d1
	move.b	3(a0),d1
	cmp.b	#27,d1
	bcc	GRou2	
	move.w	2(a1,d2.w),(a0)
	move.w	4(a0),d0
	tst.b	d1
	beq.s	GRouJ1
	cmp.w	d6,d1
	bne	TheEnd
; Dans l'extension (!)
	lsl.w	#2,d0
	move.l	0(a3,d0.w),2(a0)
	addq.l	#6,a0
	bra	GRou1
; Dans AMOS
GRouJ1	lea	AMOSJmps(pc),a1
GRouJ2	cmp.w	(a1),d0
	beq.s	GRouJ3
	addq.l	#6,a1
	tst.w	(a1)
	beq	TheEnd
	bne.s	GRouJ2
GRouJ3	move.l	2(a1),2(a0)
	addq.l	#6,a0
	bra	GRou1
;-----> RBRA etc..
GRouB	move.w	2(a0),d1
	cmp.w	d5,d1
	bcc	GRou2
	lsl.w	#2,d1
	move.w	4(a1,d2.w),(a0)+
	move.l	0(a3,d1.w),d0
	sub.l	a0,d0
	move.w	d0,(a0)+
	bra	GRou1
;-----> Instruction RDATA
GRouD	cmp.w	#C_CodeD,2(a0)
	bne	GRou2
	move.w	CNop(pc),d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	bra	GRouN
******* Call init routine!
GRouX	moveq	#2,d0
	bsr	DHunk
	bsr	Sys_ClearCache
	move.l	(a3),a0
	movem.l	d1-d7/a0-a6,-(sp)
	jsr	(a0)
	movem.l	(sp)+,d1-d7/a0-a6
	cmp.w	d0,d6
	bne	TheEnd
	rts

******* SOURIS / LOGO
LdMouse
	moveq	#2,d0
	bsr	GHunk
	move.l	a1,a2
	move.l	(a2)+,d7
	sub.w	#6+64,d7
	move.l	(a2)+,d0
	cmp.l	LMsN(pc),d0
	bne	TheEnd
	cmp.w	#4,(a2)+
	bcs	TheEnd
* Calcule la taille des sprites
	moveq	#0,d1
	moveq	#2,d2
	move.l	a2,a0
	bsr	SoSp
	bsr	SoSp
	bsr	SoSp
	move.l	d1,Logo(a5)
	moveq	#4,d2
	bsr	SoSp
* Reserve un buffer de la taille des sprites
	move.l	d7,d0
	addq.l	#2,d0
	move.l	d0,LMouse(a5)
	bsr	RamChip
	beq	TheEnd
	move.l	d0,AdMouse(a5)
	move.l	d0,T_MouBank(a5)
	add.l	d0,Logo(a5)
	move.l	d0,a0
	subq.w	#1,d7
LMs1:	move.b	(a2)+,(a0)+
	dbra	d7,LMs1
	move.w	#-1,(a0)+
* Recupere la palette IFF (couleurs 16-32)
	lea	DefEPa+32(a5),a1
	lea	32(a2),a2
	moveq	#15,d0
LMs2:	move.w	(a2)+,(a1)+
	dbra	d0,LMs2
* Fini!
	moveq	#2,d0
	bsr	DHunk
	rts
* Sote le sprite
SoSp:	move.w	4(a0),d0
	cmp.w	d0,d2
	bne	TheEnd
	mulu	(a0),d0
	mulu	2(a0),d0
	addq.l	#5,d0
	lsl.l	#1,d0
	add.l	d0,d1
	add.l	d0,a0
	rts
LMsN:	dc.b	"AmSp"
* Copie la palette des sprites
CopyPal	lea	EcPal+32(a0),a0
	lea	DefEPa+32(a5),a1
	moveq	#16-1,d0
.loop	move.w	(a1)+,(a0)+
	dbra	d0,.loop
	rts
*******	Effacement du buffer mouse
EffMouse
	tst.l	AdMouse(a5)
	beq.s	StMx
	move.l	AdMouse(a5),a1
	move.l	LMouse(a5),d0
	bsr	RamFree
StMx:	rts

***********************************************************
*	Change Y coords in control strings
ChgTY	move.b	(a0)+,d0
	beq.s	ChgTYx
	cmp.b	#27,d0
	bne.s	ChgTY
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	cmp.b	#"Y",d0
	bne.s	ChgTY
	add.b	EdTyM0+1(a5),d1
	move.b	d1,-1(a0)
	bra.s	ChgTY
ChgTYx	rts

******************************************************************
	Include "_DiskIO.s"
	Include "_Branch.s"
	Include "_String.s"
	Include	"_Menus.s"
******************************************************************
RIllDir	moveq	#17,d0
	bra	RunErr
******************************************************************

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* RUN
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
***********************************************************
*	CHRGET
***********************************************************
	IfEq	ROnly
ChrIn:	move.w	#1,DefFlag(a5)
	EndC
	IfNE	ROnly
ChrIn:	move.w	#-2,DefFlag(a5)
	EndC
	bsr	DefRun
	bsr	EdHide
	bsr	DefRun2
	bsr	ReCop

******* Sauve les params
ChrIn2:	lea	GFolow(pc),a0
	lea	CFol1(pc),a1
	bsr	SetFolow
	clr.w	FolFlg(a5)
ChrIn3:	move.l	BasSp(a5),sp
	move.l	HoLoop(a5),a3
	move.l	a3,PLoop(a5)
	move.l	a3,BasA3(a5)
	move.l	BaLoop(a5),MinLoop(a5)
	clr.w	T_Actualise(a5)
	move.l	a6,DProc(a5)
	move.l	a6,PData(a5)
	clr.l	AData(a5)
	move.w	#1,DefFlag(a5)
	bsr	Sys_ClearCache

******* Boucle du ChrGet
ChrGet:	move.w	(a6)+,d0
	beq.s	ChrX
InsRet:	move.w	(a6)+,d0
	beq.s	ChrGet
	move.l	a6,a4
InsMen	lea	Tk(pc),a0
	move.w	0(a0,d0.w),d0
GFolow	jmp	0(a0,d0.w)
	nop
CFol1	jmp	0(a0,d0.w)
CFol2	jmp	0(a0,d0.w)

******* Fin du RUN: attend une touche
ChrX:	moveq	#NbEnd,d0
	bra	RunErr

******* REM
Rem:	add.w	(a6)+,a6
	addq.l	#2,a6		Saute le ZERO de fin de ligne
	bra	ChrGet

******* EXTENSION INSTRUCTION CALL
InExt:	move.b	(a6)+,d1
	move.b	(a6)+,d0
	move.w	(a6)+,d2
	ext.w	d1
	lsl.w	#2,d1
	lea	AdTokens(a5),a0
	move.l	0(a0,d1.w),a0
	move.w	0(a0,d2.w),d2
	lea	0(a0,d2.w),a0
	ext.w	d0
	beq.s	InX1
	move.l	a0,-(sp)
	bsr	ParD0
	move.l	(sp)+,a0
InX1:	jsr	(a0)
	bra	InsRet
******* EXTENSION FUNCTION CALL
FnExt:	move.b	(a6)+,d1
	move.b	(a6)+,d0
	move.w	(a6)+,d2
	ext.w	d1
	lsl.w	#2,d1
	lea	AdTokens(a5),a0
	move.l	0(a0,d1.w),a0
	move.w	2(a0,d2.w),d2
	lea	0(a0,d2.w),a0
	ext.w	d0
	beq.s	FnX1
	move.l	a0,-(sp)
	bsr	FnParD0
	move.l	(sp)+,a0
FnX1:	jsr	(a0)
	bra	OpeRet
******* SYSTEM
ISys	bsr	OpeWB
	tst.w	WbClose(a5)
	bne	InsRet
	jsr	OpenEd
	move.w	#-2,DefFlag(a5)
	jsr	RNew0
	jmp	TheEnd

******* SET BUFFER
ISBuf	addq.l	#6,a6
	bra	InsRet
******* TUTOR
ToTutor	tst.w	Direct(a5)
	bne	RIllDir
	tst.w	RunAct(a5)
	beq.s	.skip
	jsr	TtShow
	move.l	EdBufE(a5),a0
	clr.w	StepMode(a0)
	bra	InsRet
.skip	jmp	Prog_Tutor
******* BREAK ON
BrkOn:	bset	#BitControl,ActuMask(a5)
	bra	InsRet
******* BREAK OFF
BrkOf:	bclr	#BitControl,ActuMask(a5)
	bra	InsRet
******* CLOSE EDITOR
CloEd	tst.w	Direct(a5)
	bne	InsRet
*	tst.w	FolFlg(a5)
*	bne	NoFol3
	bsr.s	ClosEd
	bra	InsRet
* Ferme l'editeur
ClosEd	move.l	EdEcran(a5),a2
	bsr	.rout
	move.l	FkEcran(a5),a2
* Routine fermeture
.rout	move.w	EcTx(a2),d0
	lsr.w	#3,d0
	mulu	EcTy(a2),d0
	lea	EcPhysic(a2),a2
	move.w	EcNPlan(a5),d2
	subq.w	#1,d2
.loop	tst.l	(a2)
	beq.s	.skip
	move.l	(a2),a1
	bsr	RamFree
	clr.l	(a2)+
.skip	dbra	d2,.loop
	rts
******* Reopen EDITOR
OpenEd	movem.l	d0-d7/a0-a4,-(sp)
	bsr	OpnEd			* 1er essai
	bne.s	OpEdX
	move.w	#-2,DefFlag(a5)
	bsr	DefRun			* Fait un DEFAULT SANS OUVERTURE!!!
	bsr	DefRun2
	bsr	OpnEd
OpEdX	movem.l	(sp)+,d0-d7/a0-a4
	rts	
* Routine: remet l'ecran editeur
OpnEd	move.l	EdEcran(a5),a2
	bsr	.rout
	beq	OpnEe
	move.l	FkEcran(a5),a2
	bsr	.rout
	beq.s	OpnEe
; Ok, pas d'erreur
	moveq	#-1,d0
	rts
* Routine bitmaps
.rout	move.w	EcTx(a2),d1
	lsr.w	#3,d1
	mulu	EcTy(a2),d1
	lea	EcPhysic(a2),a1
	move.w	EcNPlan(a2),d2
	subq.w	#1,d2
	move.w	d2,d3
.loop	tst.l	(a1)+
	bne.s	.skip
	move.l	d1,d0
	jsr	RamChip2
	beq.s	OpnEe
	move.l	d0,-4(a1)
.skip	dbra	d2,.loop
	lea	EcLogic(a2),a0
	lea	EcCurrent(a2),a1
	lea	EcPhysic(a2),a2
.loop2	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbra	d3,.loop2
	moveq	#-1,d0
OpnEe	rts
******* CLOSE WORKBENCH
* Routine
ClosWB	movem.l	a3-a6,-(sp)
	move.l	T_Intbase(a5),a6	
	jsr	-78(a6)			
	move.w	d0,WbClose(a5)
	move.w	d0,WbClose(a5)
	beq.s	.Skup
	bset	#3,T_WFlags(a5)
.Skup	
WbCloX	movem.l	(sp)+,a3-a6
	rts
******* Reopen WB
OpeWb	movem.l	a3-a6,-(sp)
	move.l	T_IntBase(a5),a6
	jsr	-210(a6)
	tst.l	d0
	beq.s	OpeW1
	clr.w	WbClose(a5)
	bra.s	WbCloX
OpeW1	move.w	#-1,WbClose(a5)
	bra.s	WbCloX

******* = DISPLAY HEIGHT
FDispH	EcCall	MaxRaw
	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet
******* =NTSC
FNTSC	EcCall	CopForce
	EcCall	NTSC
	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet
******* COMMAND LINE$=
ICom	bsr	FnExpA
	cmp.w	#256,d2
	bcc	FonCall
	move.l	Buffer(a5),a1
	lea	TBuffer-256-6(a1),a1
	move.l	#"CmdL",(a1)+
	move.w	d2,(a1)+
	addq.w	#1,d2
	lsr.w	#1,d2
	subq.w	#1,d2
	bmi.s	.skip
.loop	move.w	(a2)+,(a1)+
	dbra	d2,.loop
.skip	bra	InsRet
******* =COMMAND LINE$
FCom	move.l	Buffer(a5),a2
	lea	TBuffer-256-6(a2),a2
	cmp.l	#"CmdL",(a2)+
	bne.s	.vide
	moveq	#0,d3
	move.w	(a2)+,d3
	beq.s	.vide
	cmp.w	#256,d3
	bcc.s	.vide
	bsr	Demande
	move.w	d3,(a0)+
	move.w	d3,d0
	addq.w	#1,d0
	lsr.w	#1,d0
	subq.w	#1,d0
.loop	move.w	(a2)+,(a0)+
	dbra	d0,.loop
	move.l	a0,HiChaine(a5)
	move.l	a1,d3
	moveq	#2,d2
	bra	OpeRet
.vide	move.l	ChVide(a5),d3
	moveq	#2,d2
	bra	OpeRet

***********************************************************
*	TEST DES INTERRUPTIONS
***********************************************************
******* Entree SANS SAUTS au menu!
TTests:	movem.l	d0-d7/a0-a2,-(sp)
	bsr	Tests
	movem.l	(sp)+,d0-d7/a0-a2
	rts
******* Entree normale
Tests:	tst.b	T_Actualise(a5)
	bmi.s	Tester
TstX:	rts
******* Ya eu un VBL!
Tester:	move.w	ActuMask(a5),d7

* 	Tests cycliques 
	SyCall	Test_Cyclique

******* Autres choses???
	move.w	T_Actualise(a5),d6
	bclr	#BitControl,d6
	bne.s	Tst00
	and.w	d7,d6
	bne.s	Tst1
	beq	TstX1
* 	CONTROLE-C?
Tst00	and.w	d7,d6
	move.w	d6,T_Actualise(a5)
	cmp.w	#2,RunAct(a5)
	beq.s	IStop
	btst	#BitControl,d7
	beq.s	Tst1
IStop	moveq	#9,d0
	bra	RunErr
*******	Actualisation des ecrans/animations
Tst1:	move.w	T_VBLCount+2(a5),d0
	sub.w	VBLOCount(a5),d0
	cmp.w	VBLDelai(a5),d0
	bcs	TstX1
	movem.l	a3-a6,-(sp)
	move.w	T_VBLCount+2(a5),VBLOCount(a5)
*	Bobs?
	bclr	#BitBobs,d6
	beq.s	Tst3
	movem.l	d6/d7/a5,-(sp)
	SyCall	EffBob
	SyCall	ActBob
	SyCall	AffBob
	EcCall	SwapScS
	movem.l	(sp)+,d6/d7/a5
* 	Hard Sprites?
*Tst2:	bclr	#BitSprites,d6
*	beq.s	Tst3
*	movem.w	d6/d7,-(sp)
*	SyCall	ActHs
*	SyCall	AffHs
*	movem.w	(sp)+,d6/d7
* 	Extensions?
Tst3:	lsr.b	#1,d6
	beq.s	Tst4
	lea	ExtTests(a5),a1
	bra.s	Tst3b
Tst3a	move.l	(a1),d0
	beq.s	Tst3b
	move.l	d0,a0
	jsr	(a0)
Tst3b	addq.l	#4,a1
	lsr.b	#1,d6
	bcs.s	Tst3a
	bne.s	Tst3b
* 	Ecrans?
Tst4:	bclr	#BitEcrans,d6
	beq.s	Tst5
	EcCall	CopMake
* 	Fin des tests animations
Tst5:	movem.l	(sp)+,a3-a6
* Correction du bug CONTROL-C / Beaucoup de sprites
	move.w	T_Actualise(a5),d0
	and.w	#%0000000100000000,d0		BITCONTROL=8
	or.w	d0,d6
*******	Every
TstX1:	
*	move.w	d6,T_Actualise(a5)
*	btst	#BitEvery,d7
*	beq.s	TstX2
*	tst.w	T_EveCpt(a5)
*	bhi.s	TstX2
*	move.w	EveCharge(a5),T_EveCpt(a5)
*	bclr	#BitEvery,d7
*	bsr	EveJump

TstX2	bclr 	#BitVBL,T_Actualise(a5)
	rts

***********************************************************
*	RESERVATION/LIBERATION MEMOIRE
***********************************************************

******* Mise a zero!
RamFast	movem.l	d1-d7/a0-a6,-(sp)
	move.l	#Clear|Public,d1
	ExeCall	AllocMem
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	rts
RamChip	movem.l	d1-d7/a0-a6,-(sp)
	move.l	#Chip|Clear|Public,d1
	ExeCall	AllocMem
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	rts
******* NON mise a zero!
RamFast2
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	#Public,d1
	ExeCall	AllocMem
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	rts
RamChip2
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	#Chip|Public,d1
	ExeCall	AllocMem
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0
	rts
******* Liberation
RamFree	movem.l	d0-d7/a0-a6,-(sp)
	ExeCall	FreeMem
	movem.l	(sp)+,d0-d7/a0-a6
	rts

******************************************************************
	Include "_TokTab.s"
******************************************************************
JEdDiskErr
	jmp	EdDiskErr
JEdFsErr
	jmp	EdFsErr
;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* ERREURS RUN-TIME
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
* MINI AMOS!!!
Mini	moveq	#18,d0
	bra	RunErr
* Erreurs ecrans/fenetres
EcWiErr:cmp.w	#1,d0
	beq.s	OOfMem
	add.w	#EcEBase-1,d0
	bra	RunErr
* Erreurs banques...
BkAlRes	moveq	#35,d0
	bra.s	RunErr
BkNoRes	moveq	#36,d0
	bra.s	RunErr
* Autres erreurs
EProErr	moveq	#8,d0
	bra.s	RunErr
ResLNo:	moveq	#6,d0
	bra.s	RunErr
NoOnErr	moveq	#5,d0
	bra.s	RunErr
ResPLab	moveq	#4,d0
	bra.s	RunErr
NoResum	moveq	#3,d0
	bra.s	RunErr
NoErr:	moveq	#7,d0
	bra.s	RunErr
OofStack moveq #0,d0
	bra.s	RunErr
OOfMem:	moveq 	#24,d0
	bra.s 	RunErr
NonDim  moveq 	#27,d0
	bra.s 	RunErr
AlrDim	moveq 	#28,d0
	bra.s 	RunErr
DByZero moveq 	#20,d0
	bra.s 	RunErr
OverFlow moveq 	#29,d0
	bra.s 	RunErr
Synt:	moveq 	#22,d0
	bra.s 	RunErr
StooLong moveq 	#21,d0
	bra.s 	RunErr
RetGsb:	moveq	#1,d0
	bra.s	RunErr
PopGsb:	moveq	#2,d0
	bra.s	RunErr
TypeMis	moveq	#34,d0
	bra.s	RunErr
FonCall:moveq 	#23,d0

******* Traitement des erreurs EXTENSIONS
*	Entree:	D0= erreur
*		D1= limite stop
*		D2= numero de l'extension
*		A0= messages
******* Traitement des erreurs RUN TIME
RunErr:	Alea	MErreur,a0
	moveq	#19,d1
	moveq	#-1,d2
RunErrExt
	tst.l	T_JError(a5)		* JUMP à une extension???
	bne	ExtError
	tst.w	EdDisk(a5)		* Chargement editeur?
	bne	JEdDiskErr 
	movem.l	d0/d1/d2/a0,-(sp)
	jsr	FClose			* Ferme le fichier systeme
	bsr	FsOut			* Enleve le selecteur de fichier!
	movem.l	(sp)+,d0/d1/d2/a0
	tst.w	EdFSel(a5)		* Si appel de l'editeur---> BRANCHE
	bne	JEdFsErr
	clr.l	PrintPos(a5)
	clr.w	InputFlg(a5)
	clr.w	ContFlg(a5)
	cmp.w	#1,RunAct(a5)
	beq	JTtEv
	cmp.w	#ErrDir,d0		* Instruction DIRECT?
	beq.s	rErr1
	cmp.w	#11,d0			* Out of variable space?
	beq.s	.skip
	cmp.w	d1,d0
	bcs.s	rErr1
.skip	tst.w	Direct(a5)
	bne.s	rErr1
	tst.w	ErrorOn(a5)
	bne.s	rErr1
	tst.l	OnErrLine(a5)
	beq.s	rErr1
* Erreurs detournees
	addq.w	#1,d0
	addq.w	#1,d2
	lsl.w	#8,d2
	or.w	d2,d0
	move.w	d0,ErrorOn(a5)
	move.l	PLoop(a5),a3
	move.l	BasSp(a5),sp
	subq.l	#2,a4
	tst.w	ErrorChr(a5)
	bmi.s	rErr0
	move.l	a4,ErrorChr(a5)
	move.l	OnErrLine(a5),a6	On error GOTO
	bra	InsRet
rErr0:	move.l	a4,a6			Retour procedure= RESUME
	move.l	OnErrLine(a5),a2
	move.w	ErrorOn(a5),-(sp)
	bra	InProE
* Erreur avec les menus ouverts!!!
rErrM:
*	movem.l	a0-a6/d0-d7,-(sp)
*	bsr	MnEnd
*	movem.l	(sp)+,a0-a6/d0-d7
E_Retour:
rErr1:
	IfEQ	ROnly
* Reserve l'espace pour les variables ESCAPE
	cmp.w	#256,d0
	bcc.s	rErr3
	move.w	d0,d1
	subq.w	#1,d1
	bmi.s	rErr3
rErr2:	tst.b	(a0)+
	bne.s	rErr2
	dbra	d1,rErr2
rErr3:	subq.l	#2,a4
	move.l	a4,VerPos(a5)
* Branche au tuteur???
	cmp.w	#2,RunAct(a5)
	beq	JTtEr
* Remet l'editeur!
	jsr	OpenEd
	tst.w	Direct(a5)
	bne	GVerErr
* Espace pour variables direct
	jsr	ResDir
	move.l	a0,-(sp)
	move.w	d0,-(sp)
* Ferme les fichiers
	bsr	CloAll
* Affiche une ligne avec l'erreur
	EcCalD	CopOnOff,-1	
	SyCall	AMALFrz
	EcCalD	First,EcEdit
	EcCalD	Active,EcEdit
	moveq	#1,d1
	Alea	ErrFl,a1
	EcCall	Flash
	WiCalD	QWindow,0
* Affiche le message
	Alea	ErrIOn,a1
	WiCall	Print
	move.l	2(sp),a1
	move.l	EdBufT(a5),a0
rErra:	move.b	(a1)+,(a0)+
	bne.s	rErra
	subq.l	#1,a0
	Alea	ErrLine,a1
rErrb:	move.b	(a1)+,(a0)+
	bne.s	rErrb
	pea	-1(a0)
	clr.l	AdEProc(a5)
	move.l	VerPos(a5),a0
	jsr	FindA
	move.l	a0,a6			* Adresse de la ligne
	move.l	(sp)+,a0
	addq.l	#1,d0
	and.l	#$FFFF,d0
	jsr	LongDec
	clr.b	(a0)
	move.l	EdBufT(a5),a1
	WiCall	Centre
	ALea	ErrIOff,a1
	WiCall	Print
* Fin du programme?
	cmp.w	#NbEnd,(sp)
	bne.s	rErrs
	Alea	ErrFin,a1
	WiCall	Centre
	moveq	#2,d1
	bra.s	rErrt
* Imprime la ligne
rErrs:	move.l	VerPos(a5),a3		* Offset de l'erreur dans la ligne
	bsr	SELine
* Gere l'ecran
rErrt:	lea	ErrPal(a5),a0
	bsr	SEGest
	bsr	SEOff
* ESCAPE ---> mode direct
	move.w	(sp)+,d0
	move.l	(sp)+,a0
	cmp.b	#27,d1
	beq	JEscape
* Sinon, retour editeur / affiche l'erreur
	cmp.w	#NbEnd,d0
	bne	GVerErr
	EndC
	IfNE	ROnly
	jsr	OpenEd
	move.w	#-2,DefFlag(a5)
	jsr	RNew0
	jmp	TheEnd
	EndC
******* Instruction EDIT---> retour editeur
Edit:	
	IfEQ	ROnly
	cmp.w	#2,RunAct(a5)		* Tutor
	beq	ChrX
	tst.w	Direct(a5)
	bne.s	JEscEs
	jsr	OpenEd
	jsr	ResDir
	move.l	BasSp(a5),sp
	clr.w	EsFlag(a5)
	jsr	EdRAff
	jsr	EdScrol
	jmp	EdLoop
	EndC
	IfNE	ROnly
	bra	ChrX
	EndC
******* Appelle la routine erreur de l'extension, UNE fois
ExtError
	move.l	T_JError(a5),a1
	clr.l	T_JError(a5)
	jmp	(a1)

******* Instruction DIRECT---> mode direct
ErrDir:	equ 	255
GoDir:	tst.w	Direct(a5)
	bne	InsRet
	cmp.w	#2,RunAct(a5)		* Tutor
	beq	ChrX
	move.w	#ErrDir,d0
	bra	RunErr
JttEr	jmp	TtError
JTtEv	jmp	TtErreur
GVerErr	jmp	VerErr
JEscape	jmp	Escape
JEscEs	jmp	EscEs

***********************************************************
*	Gestion de l'ecran d'erreur!

******* Affiche la ligne
SELine	move.l	EdBufT(a5),a4
	jsr	Detok
	move.l	a2,a1
	move.w	-2(a1),d1
	clr.b	0(a1,d1.w)
	add.w	#168,d1
	ext.l	d1
	divu	#80,d1
	move.w	d1,-(sp)
	lea	0(a1,d0.w),a2
	move.b	(a2),d0
	move.w	d0,-(sp)
	clr.b	(a2)
	WiCall	Print
	ALea	ErrIci,a1
	WiCall	Print
	move.l	a2,a1
	move.w	(sp)+,d0
	move.b	d0,(a1)
	WiCall	Print
	move.w	(sp)+,d1		* Nombre de lignes
	rts
******* Gestion de l'ecran. D1=Nb de lignes
SEGest	move.l	EdEcran(a5),a1
	move.w	EcYErr(a5),EcAWy(a1)
	bset	#2,EcAW(a1)
	lsl.w	#3,d1
	move.w	d1,EcAWTy(a1)
	bset	#2,EcAWT(a1)
	lea	EcPal(a1),a1
	moveq	#3,d0
rErrz:	move.w	(a0)+,(a1)+
	dbra	d0,rErrz
	move.l	EdEcran(a5),a0
	moveq	#27,d1
	cmp.w	#ErrDir,4(sp)
	beq.s	rErr7
	jsr	Recop
* Attend la pression d'une touche
	SyCall	ClearKey
rErr4:	jsr	WaitMul
	SyCall	Inkey
	tst.l	d1
	beq.s	rErr4
	move.l	d1,d0
	swap	d0
	move.l	EdEcran(a5),a0
	move.w	EcYErr(a5),d2
* Remonte la ligne
	cmp.b	#$4C,d0
	bne.s	rErr5
	cmp.w	#16,d2
	bcs.s	rErr4
	subq.w	#8,d2
	bra.s	rErr6
* Descend la ligne
rErr5:	cmp.b	#$4D,d0
	bne.s	rErr7
	cmp.w	#312,d2
	bcc.s	rErr4
	addq.w	#8,d2
rErr6:	move.w	d2,EcYErr(a5)
	move.w	d2,EcAWY(a0)
	bset	#2,EcAW(a0)
	jsr	ReCop
	bra.s	rErr4
* Fini!
rErr7:	rts
******* Enleve l'ecran follow!
SEOff	move.w	d1,-(sp)
	move.w	#312,EcAWy(a0)
	move.w	EdTyM0(a5),d0
	addq.w	#1,d0
	mulu	#8,d0
	move.w	d0,EcAWTy(a0)
	bset	#2,EcAW(a0)
	bset	#2,EcAWT(a0)
	lea	EdPal(a5),a1
	lea	EcPal(a0),a0
	moveq	#3,d0
rErr8:	move.w	(a1)+,(a0)+
	dbra	d0,rErr8
	moveq	#1,d1
	Alea	EdFlCu,a1
	EcCall	Flash
	jsr	ReCop
	move.w	(sp)+,d1
	rts

******* Instruction RUN!
IRun0:	tst.w	Direct(a5)
	beq	Synt
	clr.w	EsFlag(a5)
	jsr	EscToEd
	move.w	#1,EsFlag(a5)
	jmp	Run
******* RUN "PROGRAMME"
IRunN	jsr	Par1
RunRou	jsr	NomDisk
* Verifie la presence du programme!
	move.l	#1005,d2
	jsr	FOpen
	jsr	GetAMOS
	move.l	16(a2),d0
	add.l	#258,d0
	move.l	d0,-(sp)
	jsr	FClose
* Fait un NEW!
	jsr	EffAllBanks
	jsr	ClearVar
	jsr	RNew2
* Change la taille du buffer
	move.l	StBas(a5),a4
	move.l	(sp)+,d0
	jsr	ChgTTexte
	beq	IRunE
* Change le nom du programme courant
	move.l	Name1(a5),a0
	lea	NamePrg(a5),a1
	jsr	CoCop
* Charge et compte
	jsr	LLAmos
	jsr	SendBanks
	tst.w	Direct(a5)
	bne	IRun0
* Appelle...
	move.l	BasSp(a5),sp
	move.l	StBas(a5),DRun(a5)
	moveq	#0,d0
	jsr	EdBlFree
	jsr	ClearVar
	jsr	PTest
	move.l	StBas(a5),a6
	bra	ChrIn2
******* Out of mem!
IRunE	move.l	#1024,d0
	jsr	ChgTTexte
	bra	OOfMem

******* ON ERROR GOTO n / ON ERROR / ON ERROR GOTO 0
OnEGo:	tst.w	ErrorOn(a5)		Error not resumed!
	bne	NoResum
	clr.l	OnErrLine(a5)
	clr.l	ErrorChr(a5)
	cmp.w	#TkPrc-Tk,(a6)
	beq.s	OnEPrc
	cmp.w	#TkGto-Tk,(a6)
	bne	InsRet
	addq.l	#2,a6
	cmp.w	#TkEnt-Tk,(a6)
	bne.s	OnEg1
	move.l	2(a6),d0
	bne.s	OnEg1
	addq.l	#6,a6
	bra	InsRet
OnEg1	bsr	GetLabel	
	beq	LbNDef
	move.l	d0,OnErrLine(a5)
	bra	InsRet
* ON ERROR PROC
OnEPrc:	addq.l	#4,a6
	move.w	(a6)+,d0
	move.b	(a6),d1
	ext.w	d1
	lea	2(a6,d1.w),a6
	move.l	LabHaut(a5),a2
	move.l	0(a2,d0.w),OnErrLine(a5)
	bset	#7,ErrorChr(a5)
	bra	InsRet

******* RESUME LABEL
ResLab:	jsr	Finie
	beq.s	ResL1
	tst.l	OnErrLine(a5)
	beq	NoOnErr
	tst.w	ErrorChr(a5)
	bpl	NoOnErr
	bsr	GetLabel
	beq	LbNDef
	bset	#31,d0
	move.l	d0,ErrorChr(a5)
	bra	InsRet
* Resume label proprement dit
ResL1:	bsr	Tests
	tst.w	ErrorOn(a5)
	beq	NoErr
	bsr	PopP
	clr.w	ErrorOn(a5)
	move.l	ErrorChr(a5),d0
	bclr	#31,d0
	beq	NoOnErr
	tst.l	d0
	beq	ResLNo	
	move.l	d0,a6
	bra	LGoto

******* RESUME [label]
Resume:	bsr	Tests
	tst.w	ErrorOn(a5)
	beq	NoErr
	tst.w	ErrorChr(a5)
	bmi.s	ResP
	jsr	Finie
	bne.s	ResL
	clr.w	ErrorOn(a5)
	move.l	ErrorChr(a5),a6
	bra	LGoto
ResL:	bsr	GetLabel
	beq	LbNDef
	clr.w	ErrorOn(a5)
	move.l	d0,a6
	bra	LGoto
* PROCEDURE ERREUR!
ResP:	jsr	Finie			* Pas de label!
	bne	ResPLab
	bsr	PopP			* POPpe la procedure
	clr.w	ErrorOn(a5)
	bra	LGoto
	
******* ERRN
FErrN:	moveq	#0,d3
	moveq	#0,d2
	move.w	ErrorOn(a5),d3
	beq	OpeRet
	subq.w	#1,d3
	bra	OpeRet

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* INPUT PRINT et assimiles
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
******* ASKD3
AskD3:	tst.l	d3
	beq	FonCall
	bmi	FonCall
	bsr	Demande
	move.l	d3,d2
	move.l	a1,d3
	lea	2(a0,d2.w),a0
	btst	#0,d2
	beq.s	AskD
	addq.l	#1,a0
AskD:	move.l	a0,HiChaine(a5)
	move.l	a1,a0
	move.w	d2,(a1)+
	rts

***********************************************************
*	KEY SPEED delai,vitesse
IKSp	bsr	Par2
	move.l	(a3)+,d2
	bmi	FonCall
	move.l	(a3)+,d1
	bmi	FonCall
	move.l	Buffer(a5),a1
	SyCall	KeySpeed
	bra	InsRet

***********************************************************
*	=INPUT$(n)
FInput1	bsr	FnExpE
	bsr	AskD3
	tst.w	d2
	beq.s	FInp1b
FInp1a:	bsr	TTests
	movem.l	a1/d2/d3,-(sp)
	SyCall	Inkey
	movem.l	(sp)+,a1/d2/d3
	tst.l	d1
	beq.s	FInp1a
	cmp.b	#32,d1
	bcs.s	FInp1a
	move.b	d1,(a1)+
	subq.w	#1,d2
	bne.s	FInp1a
FInp1b:	moveq	#2,d2
	bra	OpeRet
******* =INPUT$(#1,n)
FInput2	bsr	FnPar1
	bsr	GetFile
	beq	FilNO
	move.l	a2,-(sp)
	bsr	FnExpE
	bsr	AskD3
	tst.w	d2
	beq	FInp1b
	move.l	(sp)+,a2
	btst	#1,FhT(a2)
	beq	FilTM
	btst	#2,FhT(a2)
	beq.s	FInp2b
* Port E/S
FInp2a	bsr	GetByte
	move.b	d0,(a1)+
	subq.w	#1,d2
	bne.s	FInp2a
	moveq	#2,d2
	bra	OpeRet
* Disque
FInp2b 	move.l	d3,-(sp)
	addq.l	#2,d3
	exg	d2,d3
	move.l	FhA(a2),d1
	move.w	#DosRead,d7
	jsr	DosCall
	tst.l	d0
	beq	EOFil
	bmi.s	JDisk
	move.l	(sp)+,d3
	moveq	#2,d2
	bra	OpeRet
JDisk	jmp	DiskError

***********************************************************
* 	INPUT / LINE INPUT

******* SET INPUT first,second
ISInp	bsr	Par2
	move.l	(a3)+,d1
	lsl.w	#8,d1
	move.l	(a3)+,d0
	cmp.l	#256,d0
	bcc	FonCall
	or.w	d1,d0
	move.w	d0,ChrInp(a5)
	bra	InsRet

******* Input disque
DLInput	clr.w	-(sp)
	bra.s	DInp0
DInput	move.w	#",",-(sp)
DInp0	bsr	Par1
	addq.l	#2,a6
	bsr	GetFile
	beq	FilNO
	move.l	a2,PrintFile(a5)
	clr.l	DeFloat(a5)
	bra.s	ReInp
******* Input normal
IInput:	move.w	#",",-(sp)	
	bra.s	IInp0
LInput:	clr.w	-(sp)
IInp0:	clr.l	DeFloat(a5)
	clr.l	PrintFile(a5)
	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	Buffer(a5),a0
	clr.b	(a0)
	moveq	#1,d7
* Chaine a imprimer?
	cmp.w	#TkVar-Tk,(a6)
	beq.s	IInp1
	bsr	ExpAlpha
	addq.l	#2,a6
	moveq	#0,d7
	tst.w	d2
	beq.s	IInp1
	move.b	0(a2,d2.w),d6
	clr.b	0(a2,d2.w)
	move.l	a2,a1
	WiCall	Print
	move.b	d6,0(a2,d2.w)
* Imprime le ?
IInp1:	tst.w	d7
	beq.s	ReInp
	WiCalA	Print,InnInt(pc)
	clr.l	DeFloat(a5)

******* Rempli le buffer!
ReInp:	tst.l	PrintFile(a5)
	bne.s	ReDInp
* Clavier
	WiCall	XYCuWi
	movem.l	a3-a6,-(sp)
	move.l	Buffer(a5),a4
	moveq	#4+2,d7			* Retour si CONTROL-C!
	move.w	#510,d6
	jsr	LLEdit
	moveq	#0,d3
	move.w	d5,d3
	movem.l	(sp)+,a3-a6
	tst.w	d0
	beq	InnPut
	bra	IStop
* Fichier!
ReDInp:	move.l	PrintFile(a5),a2
	move.l	Buffer(a5),a1
	clr.b	(a1)
	moveq	#0,d1
	move.w	(sp),d2
	move.b	ChrInp+1(a5),d3
	move.b	ChrInp(a5),d4
	bra.s	InpD1
InpD0	move.b	d0,(a1)+
	addq.w	#1,d1
	cmp.w	#1000,d1
	bcc	InpTL
InpD1	bsr	GetByte
	cmp.b	d0,d2			* Stop aux virgules
	beq.s	InpD2
	cmp.b	d0,d3			* Premier caractere?
	bne.s	InpD0
 	tst.b	d4			* Sauter le deuxieme?
	bmi.s	InpD2
	bsr	GetByte
InpD2	clr.b	(a1)
	move.l	a1,d3
	sub.l	Buffer(a5),d3		* Nombre de caracteres -> D3

******* INPUT/LINE INPUT: interprete le buffer!
InnPut:	move.l	Buffer(a5),a2
Inn1:	move.l	a2,-(sp)
	bsr	FindVar
	move.l	(sp)+,a2
	movem.l	a0/d2,-(sp)
	cmp.b	#2,d2
	bne.s	Inn5
* Variable alphanumerique
	move.l	ChVide(a5),(a0)		* Libere la memoire!
	bsr	DDemande
	addq.l	#2,a0
	move.b	8+1(sp),d1
Inn2:	move.b	(a2)+,d0
	move.b	d0,(a0)+
	beq.s	Inn3
	cmp.b	d0,d1
	bne.s	Inn2
Inn3:	subq.l	#1,a0
	subq.l	#1,a2
	move.l	a0,d0
	sub.l	a1,d0
	subq.l	#2,d0
	move.w	d0,(a1)
	btst	#0,d0
	beq.s	Inn4
	addq.l	#1,a0
Inn4:	move.l	a0,HiChaine(a5)
	movem.l	(sp)+,a0/d2
	move.l	a1,(a0)
	bra.s	Inn10
* Variable numerique
Inn5:	move.l	a2,a0
	jsr	ValPrg
	move.l	a0,a2
	movem.l	(sp)+,a1/d1
	move.b	(a2),d0
	beq.s	Inn6
	cmp.b	1(sp),d0
	bne.s	InnRedo
Inn6:	cmp.b	d1,d2
	beq.s	Inn8
	tst.b	d1
	beq.s	Inn7
	bsr	IntToFl
	bra.s	Inn8
Inn7:	bsr	FlToInt
Inn8:	move.l	d3,(a1)
* Encore une variable a prendre???
Inn10:	cmp.w	#TkVir-Tk,(a6)+
	bne.s	Inn11
	cmp.b	#",",(a2)+
	beq	Inn1
* ??
	tst.l	PrintFile(a5)
	bne	ReInp
	WiCalA	Print,InnEnc(pc)
	move.l	Buffer(a5),a0
	clr.b	(a0)
	bra	ReInp
* Fini!
Inn11:	subq.l	#2,a6
	addq.l	#2,sp
	bsr	EndByte
	tst.l	PrintFile(a5)
	bne	InsRet
	cmp.w	#TkPVir-Tk,(a6)+
	beq	InsRet
	subq.l	#2,a6
	WiCalA	Print,InnRet(pc)
	bra	InsRet
* Redo from start
InnRedo	bsr	EndByte
	tst.l	PrintFile(a5)
	bne	TypeMis
	Alea	Redo,a1
	WiCall	Print
	move.l	a4,a6
	bra	IInp0
InnRet:	dc.b 	13,10,0
InnInt:	dc.b	"? ",0
InnEnc:	dc.b	13,10,"?? ",0
	even

******* Impression chaine A0
ImpChaine:
	tst.w	ImpFlg(a5)
	bne.s	JIp
	move.l	a0,a1
	WiCall	Print
	rts
******* Va a la sortie sur imprimante
JIp:	bra	ImpImp

******* Copie la chaine dans le buffer
ChVerBuf:
	move.l	Buffer(a5),a0
ChVerBuf2:
	move.l	a2,a1
	move.w	d2,d0
	beq.s	Chv2
	subq.w	#1,d0
	cmp.w	#510,d0
	bcs.s	Chv1
	move.w	#509,d0
Chv1:	move.b	(a1)+,(a0)+
	dbra	d0,Chv1
Chv2:	clr.b	(a0)+
	rts

******* PRINT #n,"ldlkslkdslk"
HPrnt:	bsr	Par1
	addq.l	#2,a6
	bsr	GetFile
	tst.l	FhA(a2)
	beq	FilNO
	btst	#0,FhT(a2)
	beq	FilTM
	cmp.w	#1,d0
	beq	FilTM
	move.l	a2,PrintFile(a5)
	clr.w	ImpFlg(a5)
	bra.s	Print0
******* LPRINT
LPrnt: 	clr.l	PrintFile(a5)
	move 	#1,ImpFlg(a5)
        bra.s 	Print0
******* PRINT
Prnt:  	tst.w	ScOn(a5)
	beq	ScNOp
	clr 	ImpFlg(a5)
	clr.l	PrintFile(a5)
* Entree commune
Print0	move.l 	PrintPos(a5),d0 
        beq.s 	Print1         
	move.l	d0,a6  
        bclr 	#7,PrintFlg(a5)
* Boucle
Print1	clr 	PrintFlg(a5)
Print2	bsr 	SsPrint
        beq 	FinPrint
        tst.w 	d7
        beq.s 	Print2
	move.l	PrintFile(a5),d0
	bne.s	Print4
* A l'ecran
	tst.w	ImpFlg(a5)
	bne.s	Print3
        move.l	Buffer(a5),a1
	WiCall	Print
	bra.s	Print2
* Imprimante - LPrint
Print3	move.l	Buffer(a5),a0
	bsr	ImpImp
	bra.s	Print2
* Impression dans un fichier
Print4	move.l	d0,a0
	move.l	FhA(a0),d1
Print5	move.l	Buffer(a5),d2
	move.l	d3,-(sp)
	moveq	#0,d3
	move.w	d7,d3
	move.w	#DosWrite,d7
	jsr	DosCall
	move.l	d3,d1
	move.l	(sp)+,d3
	cmp.l	d0,d1
	beq.s	Print2
	jmp	DiskError
* Fin du print
FinPrint: 
	clr.l 	PrintPos(a5)
        clr.l 	PrintFile(a5)
	bra 	InsRet

; ROUTINE DE PRINT: REMPLI LE BUFFER, REVIENT D7=LONGUEUR A IMPRIMER!
ssprint	btst #7,printflg(a5)    impression de chaine en route!
        bne sp2a
        btst #6,printflg(a5)    fini?
        bne sp17
 	move.l Buffer(a5),a0
        cmp.w #TkUsing-Tk,(a6)	Using?
	beq.s Sp20
	jsr Finie		Print termine?
	beq Sp11
	bra.s Spa
; USING "+ - #### . ^^^^ ~~~~": debut, STOCKE LA CHAINE
sp20:   bsr FnExpA
        cmp #120,d2         	pas plus de 200 caracteres
        bcc foncall
        move.l buffer(a5),a0
	lea 256(a0),a0
        bsr chverbuf2       	copie la chaine dans le buffer
        move #1,usingflg(a5)
	addq.l #2,a6		Saute le ;
	bra.s Spb
* Prend le param
spa:    clr usingflg(a5)
spb:    bsr evalue
	move.l a4,d0
	bne.s spb0
	move.l MenA4(a5),a4
spb0:   move.l Buffer(a5),a0
        subq.b #1,d2
        bmi.s sp1
        bne.s sp2
; IMPRESSION D'UN CHIFFRE FLOAT
        move fixflg(a5),d0
        jsr strflasc        ;va ecrire dans le buffer
        bra using1
; IMPRESSION D'UN CHIFFRE ENTIER
sp1:    move.l d3,d0
        jsr longdec1
        bra using1
; IMPRESSION D'UNE CHAINE -debut-
sp2:    move.l d3,a2
        move.w (a2)+,d3
        bne.s sp3
        bra using50 
; IMPRESSION D'UNE CHAINE -milieu-
sp2a:   move.l buffer(a5),a0
sp3:    moveq #120,d0
sp4:    move.b (a2)+,(a0)+  	;imprime par salves de 120 caracteres,
        subq #1,d3
        beq.s sp5
        dbra d0,sp4
        bset #7,printflg(a5)    ;on a pas fini d'imprimer la chaine!
        bra.s sp11
sp5:    bclr #7,printflg(a5)    ;on a fini!
        bra using50
; fin du sspgm/retour du USING
sp11:   clr usingflg(a5)        ;une seule expression par USING
        btst #7,printflg(a5)    ;pas fini: ne fait rien!
        bne.s sp15
        move.w (a6),d0
        cmp.w #TkVir-Tk,d0
        beq.s sp12
        cmp.b #TkPVir-Tk,d0     ;point virgule: ne fait rien!
        beq.s sp13
        bra.s Sp14
sp12:   move.b #9,(a0)+         ;TAB
sp13:   addq.l #2,a6
        jsr finie
	beq.s Sp14a
        bne.s sp15
sp14:   move.b #13,(a0)+        ;met le RETURN
        move.b #10,(a0)+
sp14a:  bset #6,printflg(a5)    ;flag: c'est fini apres!
sp15:   clr.b (a0)
        sub.l buffer(a5),a0
        move.l a0,d7            ;taille du buffer
        btst #7,printflg(a5)
        bne.s sp16
        move.l a6,printpos(a5)  ;position du CHRGET PRINT
sp16:   moveq #1,d0             ;retour: quelque chose a imprimer!
        rts
sp17: 	moveq #0,d0
        rts

; USING pour les CHIFFRES
using1: tst usingflg(a5)        Si pas using: revient imprimer
        beq sp11
        clr.b (a0)          	Stoppe la chaine
        move.l Buffer(a5),a1
        lea 128(a1),a2
        moveq #127,d0
us2:    move.b (a1),(a2)+   	recopie la chaine, et fait le menage!!!
        move.b #32,(a1)+
        dbra d0,us2
        move.l Buffer(a5),a0
        lea 128(a0),a1      	a1 pointe la chaine
        move.l a1,d6        	debut chaine a formatter
	move.l Buffer(a5),a2
	lea 256(a2),a2		a2 pointe la chaine de definition
        move.l a2,d7        	debut chaine de format
us3:    move.b (a2),d0
        beq.s us5
        cmp.b #".",d0       	cherche la fin du format de chiffre
        beq.s us5
        cmp.b #";",d0
        beq.s us5
        cmp.b #"^",d0
        beq.s us5
        addq.l #1,a0
        addq.l #1,a2
        bra.s us3
us5:    move.b (a1),d0
        beq.s us6
        cmp.b #".",d0       	trouve le point de la chaine a formatter
        beq.s us6             	ou la fin
        cmp.b #"E",d0
        beq.s us6
        addq.l #1,a1
        bra.s us5
us6:    movem.l a0-a3,-(sp)
; ecris la gauche du chiffre
us7:    cmp.l d7,a2         	fini a gauche???
        beq us15
        move.b -(a2),d0
        cmp.b #"#",d0
        beq.s us8
        cmp.b #"-",d0
        beq.s us11
        cmp.b #"+",d0
        beq.s us12
        move.b d0,-(a0)     	aucun signe reserve: le met simplement!
        bra.s us7
us8:    cmp.l d6,a1         	-----> "#"
        bne.s us10
us9:    move.b #" ",-(a0)   	arrive au debut du chiffre!
        bra.s us7
us10:   move.b -(a1),d0
        cmp.b #"0",d0       	pas un chiffre (signe)
        bcs.s us9
        cmp.b #"9",d0
        bhi.s us9
        move.b d0,-(a0)     	OK, chiffre: poke!
        bra.s us7
us11:   move.l d6,a3        	-----> "-"
        move.b (a3),-(a0)   	met le "signe": 32 ou "-"
        bra.s us7
us12:   move.l d6,a3
        move.b (a3),d0
        cmp.b #"-",d0
        beq.s us13
        move.b #"+",d0
us13:   move.b d0,-(a0)     	-----> "+"
        bra us7
; ecrit la droite du chiffre
us15:   movem.l (sp)+,a0-a3 	recupere les adresses pivot
        clr.l d2            	flag puissance
        cmp.b #".",(a1)     	saute le point dans le chiffre a afficher
        bne.s us16
        addq.l #1,a1
us16:   move.b (a2)+,d0
        beq sp11        	fini OUF!
        cmp.b #";",d0       	";" marque la virgule sans l'ecrire!
        beq.s us18z
        cmp.b #"#",d0
        beq.s us17
        cmp.b #"^",d0
        beq.s us20
        move.b d0,(a0)+     	ne correspond a rien: POKE!
        bra.s us16
us17:   move.b (a1),d0      	-----> "#"
        bne.s us19
us18:   tst d2
        beq.s us18a
us18z:  move.b #" ",(a0)+   	si puissance passee: met des espaces
        bra.s us16
us18a:  move.b #"0",(a0)+   	Fin du chiffre: met un zero apres la virgule
        bra.s us16
us19:   cmp.b #"0",d0
        bcs.s us18
        cmp.b #"9",d0
        bhi.s us18
        addq.l #1,a1
        move.b d0,(a0)+
        bra us16
us20:   tst d2              	-----> "^"
        bmi.s us24
        bne.s us25
us21:   move.b (a1),d0
        beq.s us22
        cmp.b #"E",d0
        beq.s us23
        addq.l #1,a1
        bra.s us21
us22:   move #1,d2          	pas de puissance: en fabrique une!
        bra.s us25
us23:   move #-1,d2
us24:   move.b (a1),d0      	si fin du chiffre: met des espaces
        beq us18
        addq.l #1,a1
        cmp.b #32,d0        	saute l'espace entre E et +/-
        beq.s us24
        move.b d0,(a0)+
        bra us16
us25:   move.l	a3,-(sp)
	lea 	uspuiss(pc),a3
        move.b 	-1(a3,d2.w),(a0)+ 	met une fausse puissance!
	move.l	(sp)+,a3
        cmp.b 	#6,d2
        beq 	us16
        addq 	#1,d2
        bra 	us16

; PRINT USING POUR DES CHAINES +++facile
using50:tst usingflg(a5)	si pas using, va imprimer
        beq sp11
	move.l a2,-(sp)
        clr.b (a0)        	stoppe la chaine
        move.l Buffer(a5),a0
        lea 128(a0),a1
        moveq #127,d0
us51:   move.b (a0)+,(a1)+  	recopie la chaine, et fait le menage!!!
        dbra d0,us51
        move.l Buffer(a5),a0
        lea 128(a0),a1      	a1 pointe la chaine
        lea 128(a1),a2		a2 pointe la chaine de definition
; ecris la chaine dans le buffer
us52:   move.b (a2)+,d0
        beq.s us55        	fini!
        cmp.b #"~",d0
        beq.s us53
        move.b d0,(a0)+
        bra.s us52
us53:   move.b (a1),d0      	----> "~"
        bne.s us54
        move.b #32,(a0)+
        bra.s us52
us54:   addq.l #1,a1
        move.b d0,(a0)+
        bra.s us52
us55:	move.l	(sp)+,a2
	bra	Sp11

UsPuiss dc.b "E+000  "
	even

	Include "_Evalue.s"
 	Include "_Memory.s"
	Include "_Ecrans.s"
	Include "_Sprite.s"
	Include "_Tutor.s"

		Even
		dc.b	"KeykokaK"

		IFEQ	VDemo+TkCode
DKy		Incbin	"Default.Key"
		ENDC
		IFNE	VDemo+TkCode
DKy		Incbin	"Work:AMOS_System/English.Key"
		ENDC

		Even
DFont		Incbin	"Default.Font"
		Even
Ed_Pics		Incbin	"Ed_Pics.Bin"
		Even
Ed_Slv1		dc.w	0
Ed_Slv2		dc.w	0
Ed_Slh1		dc.w	0
Ed_Slh2		dc.w	0
FinPrg		dc.l	0

	END
