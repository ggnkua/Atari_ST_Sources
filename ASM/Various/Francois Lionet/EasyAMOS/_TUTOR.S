;---------------------------------------------------------------------
;  ******   **    *** **  **          **   **   **  ***   *** 
;  **      ****  **    ****          ****  *** *** ** ** **   
;  **     **  **  ***   **          **  ** ** * ** ** **  *** 
;  ****   ******    **  **    ***   ****** **   ** ** **    **
;  **     **  ** *  **  **          **  ** **   ** ** ** *  **
;  ****** **  **  ***   **          **  ** **   **  ***   *** 
;---------------------------------------------------------------------
;  TUTOR Shell
;
; Encore à faire :
;
; * Voir les sliders
;---------------------------------------------------------------------
Ttt_MinTy	equ	8
Ttt_MaxTy	equ	16

* Numéro des ecrans
EcTut1		equ	EcEdit
EcTut2		equ	EcFonc

* Image compactee pour ecran texte / help
Ttt_Pic		equ	28

* Sliders
ttsl_vx		equ	624+6
ttsl_vy		equ	8
ttsl_vtx	equ	5
ttsl_hx		equ	6
ttsl_hy		equ	2
ttsl_htx	equ	617
ttsl_hty	equ	2

* Slider infos / help
inf_slx		equ	624+6
inf_sltx	equ	5

* Boutons help
BtX		equ	384
BtY		equ	35
RedX		equ	16
RedY		equ	9
RedTX		equ	320
RedTY		equ	100
BoutInfos	equ	12
NBoutons	equ	16

Tjsr	MACRO
	jsr	\1
	move.l	Tt_Base(a5),a4
	ENDM


;					----------------------------------
;--------------------------------------    Zone commune HELP / TUTOR
;					----------------------------------
Inf_Size	equ	88*100		; 100 lignes max

		RsReset
Inf_Buf		rs.b	Inf_Size
Inf_sly		rs.w	1
Inf_slp1	rs.w	1
Inf_slp2	rs.w	1
Inf_Pos		rs.l	1
Inf_YPos	rs.w	1
Inf_AlertOn	rs.w	1
Inf_NLigne	rs.w	1		
Ttt_Tlb		rs.w	1
Tt_Init		rs.w	1
Inf_DataLong	equ	__Rs

;					----------------------------------
;--------------------------------------    Zone spécifique HELP
;					----------------------------------
		RsSet	Inf_DataLong
Hlp_Map		rs.l	1
Hlp_MapLong	rs.l	1
Hlp_OldEc	rs.w	1
Hlp_DataLong	equ	__Rs

Hlp_TY		equ	10

;					----------------------------------
;--------------------------------------    Zone spécifique TUTOR
;					----------------------------------
		RsSet	Inf_DataLong
StepMode	rs.w	1
TtBufE		rs.b	256*Ttt_MaxTy
TtLigne		rs.b	1024
TtSEdit		rs.b	WbClose-EdBufE+6+8
TtView		rs.w	1
TtViewTX	rs.w	1
TtViewTY	rs.w	1
TtViewNP	rs.w	1
TtViewAD	rs.l	1
ViewTy		rs.w	1
TttTy		rs.w	1
TtActive	rs.w	1
TtAccel		rs.w	1
TtEcran		rs.w	1
TttTlh		rs.w	1
ttsl_hp1	rs.w	1
ttsl_hp2	rs.w	1
ttsl_vp1	rs.w	1
ttsl_vp2	rs.w	1
TtYMark		rs.w	1
TtX1Mark	rs.w	1
TtX2Mark	rs.w	1
TtYInfo		rs.w	1
TtX1Info	rs.w	1
TtX2Info	rs.w	1
TtXNext		rs.w	1
TtYNext		rs.w	1
Ttpline		rs.l	1
Ttaline		rs.l	1
StepSp		rs.l	1
StepBreak	rs.l	1
StepStop	rs.w	1
TtEvPile	rs.l	1
TtEvDebut	rs.l	1
TtInfOn		rs.w	1
TtDCurLine	rs.l	1
StepMess	rs.l	1
TtRun		rs.w	1
TtMapAdr	rs.l	1
TtMapLong	rs.l	1
Ttt_Mode	rs.w	1
TtMKey		rs.w	1
TtMFlag		rs.w	1
TtAdress	rs.l	1
TtLocked	rs.w	1
ViewScrols	rs.w	4*8
TtDzLong	equ	__rs


;					----------------------------------
;--------------------------------------    Fenetre HELP
;					----------------------------------
Help_Edit
	movem.l	a3-a6,-(sp)
	movem.l	a0/d0,-(sp)
	bsr	Hlp_Init
	beq	Hlp_Out2

	bsr	Hlp_Open
* Va chercher le texte
	movem.l	(sp),a0/d0
	bsr	Hlp_Help

* Boucle de test
	SyCall	ClearKey
.Loop
	jsr	WaitMul
	SyCall	Inkey
	tst.l	d1
	beq.s	.nokey
	swap	d1
	cmp.b	#76,d1
	bne.s	.noup
	move.w	#1,-(sp)
	and.w	#$0300,d1
	beq.s	.nosh0
	move.w	#8,(sp)
.nosh0	bsr	InfDown
	subq.w	#1,(sp)
	bne.s	.nosh0
	addq.l	#2,sp
	bra.s	.Loop
.noup	cmp.b	#77,d1
	bne.s	.nodw
	move.w	#1,-(sp)
	and.w	#$0300,d1
	beq.s	.nosh1
	move.w	#8,(sp)
.nosh1	bsr	InfUp
	subq.w	#1,(sp)
	bne.s	.nosh1
	addq.l	#2,sp
	bra.s	.Loop
.nodw	cmp.b	#69,d1
	beq.s	Hlp_Quit
	cmp.b	#95,d1
	beq.s	Hlp_Quit
	cmp.b	#68,d1
	beq.s	Hlp_Quit
.nokey
* Tests souris
	SyCall	MouseKey
	btst	#0,d1			Bouton de gauche--> normal
	beq.s	.Loop
	SyCall	GetZone
	cmp.w	#EcFSel,d1
	bne	.Loop
	swap 	d1

	cmp.w	#3,d1
	bne.s	.padrag
	bsr	Hlp_Drag
	bra	.Loop
.padrag	
	cmp.w	#2,d1
	bne.s	.pasl
	bsr	Inf_SlClic
	bra	.Loop
.pasl
	cmp.w	#1,d1
	bne	.Loop

******* Quit!
.Wtend	SyCall	MouseKey
	tst.w	d1
	bne.s	.Wtend
Hlp_Quit
* Ferme tout.
	bsr	Hlp_Close	
	bsr	Hlp_End
Hlp_Out2
	movem.l	(sp)+,a0/d0
	movem.l	(sp)+,a3-a6
	rts

******* On bouge la fenetre HELP
Hlp_Drag
	SyCall	XYMou
	move.w	Hlp_WY(pc),d7
	sub.w	d2,d7
.loop	SyCall	MouseKey
	btst	#0,d1
	beq.s	.out
	SyCall	XYMou
	add.w	d7,d2
	move.w	d2,d3
	move.l	#EntNul,d2
	move.l	d2,d4
	move.l	d4,d5
	lea	Hlp_WY(pc),a0
	move.w	d3,(a0)
	EcCalD	View,EcFsel
	jsr	Recop
	bra.s	.loop
.out	rts
******* Initialisation HELP
Hlp_Init
	move.l	#Hlp_DataLong,d0
	SyCall	SyFast
	move.l	d0,a4
	tst.l	d0
	beq.s	.out
	lea	Inf_Buf(a4),a0
	move.l	a0,Inf_Pos(a4)
	move.w	#Hlp_TY,Ttt_Tlb(a4)
.out	rts
******* Fin HELP
Hlp_End
	bsr	Hlp_DelMap
	move.l	a4,a1
	move.l	#Hlp_DataLong,d0
	SyCall	SyFree
	rts
******* Open help screen
Hlp_Open
* Prend l'ancien ecran
	move.l	T_EcCourant(a5),a0
	move.w	EcNumber(a0),Hlp_OldEc(a4)
* Ouvre le nouveau
	move.l	#640,d2
	move.l	#Hlp_TY*8+16+8,d3
	moveq	#2,d4
	move.l	#$8000,d5
	moveq	#4,d6
	moveq	#0,d7
	lea	DefPal(a5),a1
	EcCalD	Cree,EcFSel
	move.w	Hlp_WY(pc),EcAWY(a0)
* Palette
	move.l	#$0000058D,EcPal(a0)
	move.l	#$0AEF0247,EcPal+4(a0)
* Curseur
	WiCalA	Print,Hlp_WInit(pc)
* Reserve des zones
	SyCalD	ResZone,3
* Fond du haut
	moveq	#Ttt_pic+5,d0		Image du haut
	moveq	#0,d1
	moveq	#0,d2
	moveq	#-1,d3
	bsr	TtUPack
	move.w	#16,Inf_Sly(a4)		Position du slider
* Fond de l'image
	moveq	#Hlp_TY-2,d7
	moveq	#24,d3
	move.l	T_EcAdr+EcFsel*4(a5),a0
	move.l	a0,a1
	moveq	#0,d0
	moveq	#16,d1
	moveq	#0,d2
	move.w	#640,d4
	moveq	#24,d5
.loop1	bsr	TtScc
	addq.w	#8,d3
	dbra	d7,.loop1
* Fond du bas
.skip1	moveq	#Ttt_pic+6,d0
	moveq	#0,d1
	move.l	d3,d2
	moveq	#-1,d3
	bsr	TtUPack
* Ouvre la fenetre
	moveq	#16,d2
	moveq	#16,d3
	moveq	#76,d4
	move.w	Ttt_tlb(a4),d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCalD	WindOp,1
	WiCalA	Print,Hlp_WInit(pc)
* Defini les sliders
	moveq	#3,d0
	moveq	#3,d1
	moveq	#3,d2
	moveq	#1,d3
	moveq	#1,d4
	moveq	#1,d5
	moveq	#1,d6
	moveq	#1,d7
	EcCall	SetSli
* Zone QUIT=1
	move.w	#640-64,d2
	move.w	#2,d3
	move.w	#640-8,d4
	move.w	#14,d5
	SyCalD	SetZone,1
* Zone SLIDER=2
	move.w	#Inf_slx,d2
	move.w	Inf_sly(a4),d3
	move.w	#Inf_slx+Inf_sltx,d4
	move.w	Ttt_tlb(a4),d5
	lsl.w	#3,d5
	add.w	d3,d5
	SyCalD	SetZone,2
* Zone DRAG=3
	move.w	#0,d2
	move.w	#2,d3
	move.w	#6-64,d4
	move.w	#14,d5
	SyCalD	SetZone,3
* Apparition de l'écran
	move.l	T_EcAdr+EcFsel*4(a5),a2
	moveq	#8,d7
	moveq	#1,d6
	move.w	Hlp_WY(pc),d5
	move.w	EcTy(a2),d0
	lsr.w	#1,d0
	add.w	d0,d5
	jsr	AppCentre
	rts
******* Ferme l'ecran HELP
Hlp_Close
	move.l	T_EcAdr+EcFsel*4(a5),a2
	moveq	#-10,d7
	move.w	Hlp_WY(pc),d5
	move.w	EcTY(a2),d6
	lsr.w	#1,d6
	add.w	d6,d5
	jsr	AppCentre
	EcCalD	Del,EcFsel
* Reactive l'ancien ecran
	move.w	Hlp_OldEc(a4),d1
	EcCall	Active
	rts

******* Explore le fichier MAP
*	A0/D0	Nom source
Hlp_Help
	movem.l	a0/a1/d0/d1,-(sp)
	moveq	#0,d3
	cmp.w	#1,d0
	bcs	.Noword

	bsr	Hlp_GetMap
	beq	.out1
	movem.l	a0/a1/d0/d1,(sp)

* Explore methodiquement les possibilites
	moveq	#2,d7
	move.b	(a0),d0			* Si operateur >>> 1 seul car!
	jsr	D0Maj
	cmp.b	#"A",d0
	bcs.s	.Gli0
	cmp.b	#"Z",d0
	bls.s	.Gli1
.Gli0	subq.w	#1,d7
.Gli1	moveq	#0,d6
.loop0	move.l	Buffer(a5),a2
	lea	128(a2),a3
	move.w	#$00FF,(a2)+
	moveq	#0,d2
	moveq	#0,d5
.loop1	move.w	d0,d3
.loop2	move.b	(a0)+,d0
	move.b	d0,(a3)+
	clr.b	(a3)
	jsr	D0Maj
	cmp.b	#32,d0
	beq.s	.skip
	move.b	d0,(a2)+
	addq.w	#1,d2
.skip	addq.w	#1,d5
	subq.w	#1,d3
	beq.s	.loop3
	cmp.w	d2,d7
	bne.s	.loop2
.loop3	moveq	#0,d4
	move.l	Buffer(a5),a2
	addq.w	#2,d2
	jsr	InstrFind
	movem.l	(sp),a0/a1/d0/d1
	tst.l	d3
	beq.s	.Nf

* Trouve, explore une lettre de plus
	move.l	d3,d6
	addq.w	#1,d7
	cmp.w	d0,d7
	bls.s	.loop0
	bra.s	.Trouve
* Pas trouve, peut-on revenir en arriere?
.Nf	move.l	d6,d3
	bne.s	.Trouve

	move.l	Buffer(a5),a1
	lea	128(a1),a1
	cmp.w	#32,d0
	bcs.s	.Nf1
	moveq	#32,d0
.Nf1	move.b	(a0)+,(a1)+
	subq.w	#1,d0
	bne.s	.Nf1
	clr.b	(a1)
	bra.s	.NFound

* Charge la portion demandee
.Trouve
	lea	Hlp_Found(pc),a0
	bsr	Hlp_Aff
	lea	-4(a1,d3.w),a1
	moveq	#0,d3		D3>>> offset
	move.b	(a1)+,d3
	lsl.l	#8,d3
	move.b	(a1)+,d3
	lsl.l	#8,d3
	move.b	(a1)+,d3

* Gestion des informations
.NFound
	move.l	d3,-(sp)
	moveq	#1,d0
	bsr	Inf_Del
	tst.l	(sp)
	bne.s	.noinfo
* Affiche le titre...
	lea	Hlp_Sep(pc),a0
	bsr	Hlp_Print
	move.l	Buffer(a5),a1
	lea	128(a1),a2
	lea	Hlp_About(pc),a0
.hf1	move.b	(a0)+,(a1)+
	bne.s	.hf1
	move.b	#'"',-1(a1)
.hf2	move.b	(a2)+,(a1)+
	bne.s	.hf2
	move.b	#'"',-1(a1)
	clr.b	(a1)
	move.l	Buffer(a5),a0
	bsr	Hlp_Print
	lea	Hlp_NFound(pc),a0
	bsr	Hlp_Print
.hf3	lea	Hlp_Sep(pc),a0
	bsr	Hlp_Aff
.noinfo
	move.l	(sp)+,d3

* Affiche le texte
.NoWord
	lea	Hlp_Nom(pc),a0
	move.l	a0,d1
	move.l	#1005,d2
	move.w	#DosOpen,d7
	jsr	DosCall
	move.l	d0,d1
	beq	.DErr
	move.l	d3,d2
	moveq	#-1,d3
	move.w	#DosSeek,d7
	move.l	d1,-(sp)
	jsr	DosCall
	move.l	(sp)+,d1
	move.l	Buffer(a5),a2
	move.l	a2,d2	
.HLop1	moveq	#2,d3
	bsr	Hlp_Read
	bne.s	.HOut
	move.w	(a2),d3
	beq.s	.HOut
	bsr	Hlp_Read
	bne.s	.HOut
	move.l	a2,a0
	bsr	Hlp_Print
	bra.s	.HLop1
.HOut	move.w	#DosClose,d7
	jsr	DosCall
* Imprime à l'écran, et revient
.out	bsr	Inf_AffAll
.out1	movem.l	(sp)+,a0/a1/d0/d1
	rts
* Disc Error
.DErr	bsr	Hlp_DErreur
	bra.s	.out
* Imprime et reaffiche
Hlp_Aff
	movem.l	a0-a3/d0-d7,-(sp)
	bsr	Hlp_Print
	bsr	Inf_AffAll
	movem.l	(sp)+,a0-a3/d0-d7
	rts
* Imprime une ligne normale HELP
Hlp_Print	
	move.l	a0,-(sp)
	moveq	#1,d0
	bsr	Inf_PrDeb
	move.l	(sp)+,a0
	bsr	Inf_Print
	bra	Inf_PrFin

******* Charge le fichier .MAP en memoire
Hlp_GetMap
	movem.l	a0-a3/d0-d7,-(sp)
	tst.l	Hlp_Map(a4)
	bne.s	.DErr
* Charge...
	lea	Hlp_Loadmap(pc),a0
	bsr	Hlp_Aff
	lea	Hlp_NomMap(pc),a0
	move.l	a0,d1
	move.l	#1005,d2
	move.w	#DosOpen,d7
	jsr	Doscall
	beq	.Err2
	move.l	d0,d1
	lea	Hlp_MapLong(a4),a2
	move.l	a2,d2
	moveq	#4,d3
	bsr	Hlp_Read
	bne.s	.Err1
	move.l	(a2),d3
	move.l	d3,d0
	SyCall	SyFast
	move.l	d0,Hlp_Map(a4)
	beq	.Err1
	move.l	d0,d2
	bsr	Hlp_Read
	bne	.Err2
	move.w	#DosClose,d7
	jsr	DosCall
* Ramene l'adresse et la longueur...
.Err0	movem.l	(sp)+,a0-a3/d0-d7
.NoLoad	move.l	Hlp_Map(a4),a1
	move.l	Hlp_MapLong(a4),d1
	rts
* Erreurs de chargement!
.Err1	move.w	#DosClose,d7
	jsr	DosCall
.Err2	bsr	Hlp_DelMap
.DErr	bsr	Hlp_DErreur
	bra.s	.Err0
* Affiche le message
Hlp_DErreur
	lea	Hlp_Sep(pc),a0
	bsr	Hlp_Print
	lea	Hlp_DErr(pc),a0
	bsr	Hlp_Print
	lea	Hlp_Sep(pc),a0
	bra	Hlp_Aff

** Read 
Hlp_Read
	movem.l	d1-d7/a0/a1,-(sp)
	move.w	#Dosread,d7
	jsr	DosCall
	movem.l	(sp)+,d1-d7/a0/a1
	cmp.l	d0,d3
	rts
	
******* Efface le buffer MAP
Hlp_DelMap
	move.l	Hlp_Map(a4),d1
	beq.s	.skip
	move.l	d1,a1
	move.l	Hlp_MapLong(a4),d0
	clr.l	Hlp_Map(a4)
	clr.l	Hlp_MapLong(a4)
	SyCall	SyFree
.skip	rts

Hlp_WY	dc.w	88


;					----------------------------------
;--------------------------------------    Gestion de l'écran TEXTE
;					----------------------------------

******* Affichage de la ligne ecran D0
Inf_AffLine
	moveq	#0,d6
	move.w	d0,d3
	bra.s	ginf2
******* Comptage des lignes infos
Inf_CptLines
	bset	#31,d6
	bra.s	ginf1
*******	Affichage du contenu du buffer dans l'ordre des lignes!
Inf_AffAll
	moveq	#0,d6
ginf1	moveq	#-1,d3
ginf2	moveq	#0,d7
	move.w	Inf_YPos(a4),d6
	move.w	d6,d7
	add.w	Ttt_tlb(a4),d7
	moveq	#0,d5
	moveq	#0,d4
.loop	bsr	InfAf
	addq.w	#1,d4	
	cmp.w	#6,d4
	bcs.s	.loop
	move.w	d5,Inf_NLigne(a4)
* Efface jusqu'à la fin
.llop	tst.l	d6
	bmi.s	.skip2
	cmp.w	d7,d5
	bcc.s	.skip
	moveq	#0,d1
	move.w	d5,d2
	sub.w	d6,d2
	WiCall	Locate
	WiCalD	ChrOut,7
	addq.w	#1,d5
	bra.s	.llop
* Va dessiner le slider
.skip	bsr	Inf_Slider
.skip2	rts
** Imprime toutes les lignes numéro D4
InfAf	lea	Inf_Buf(a4),a2
	tst.w	(a2)
	beq.s	.out
.loop0	cmp.w	2(a2),d4
	bne.s	.next
	move.w	#-1,4(a2)
	cmp.w	#1,d4
	bne.s	.nxt1
	bset	#31,d7
.nxt1	cmp.w	#3,d4
	bne.s	.nxt2
	bset	#30,d7
.nxt2	cmp.w	d6,d5
	bcs.s	.nexta
	cmp.w	d7,d5
	bcc.s	.nexta
	move.w	d5,d2
	sub.w	d6,d2
	tst.w	d3
	bmi.s	.jd
	cmp.w	d3,d2
	bne.s	.nexta
.jd	move.w	d2,4(a2)
	bsr	InfA
.nexta	addq.w	#1,d5
.next	add.w	(a2),a2
	tst.w	(a2)
	bne.s	.loop0
.out	rts		

** Imprime la ligne info D2/A2
InfA	moveq	#0,d1
	ext.l	d2
	WiCall	Locate
	cmp.w	#2,2(a2)		Separation INFOS / LISTING
	beq.s	.sep1
	cmp.w	#4,2(a2)
	beq.s	.sep2
	cmp.w	#3,2(a2)
	beq.s	Iparam
* Impression simple...
.simple	tst.l	d6
	bmi.s	ttnp
	lea	6(a2),a1
	WiCall	Print
.out	rts
* Separation Infos1/Infos2
.sep1	bclr	#31,d7
	bne.s	.simple
	bra.s	.nosep
* Separation Infos2/Listing
.sep2	bclr	#30,d7
	bne.s	.simple
.nosep	move.w	#-1,4(a2)
	subq.w	#1,d5
ttnp	rts
* Affiche un parametre
Iparam	tst.l	d6
	bmi.s	ttnp
	movem.l	a2/d3-d7,-(sp)
	bclr	#31,d7
	tst.w	Tt_Init(a4)
	beq.s	.noi
	move.l	BasA3(a5),d0		Invalide???
	cmp.l	6(a2),d0
	beq.s	.ok
.noi	WiCalA	Print,Inf_Shade(pc)
	bset	#31,d7
.ok	lea	10(a2),a6
	movem.l	a1/a2/d1-d7,-(sp)
	sub.l	a3,a3
	move.l	EdBufT(a5),a4
	Tjsr	TtDetok
	movem.l	(sp)+,a1/a2/d1-d7
	move.l	EdBufT(a5),a0
	move.w	(a0)+,d4
	cmp.w	#60,d4
	bcs.s	.skip0
	moveq	#60,d4
.skip0	add.w	d4,a0
	btst	#31,d7
	bne	.suit
	lea	10(a2),a6
	bsr	TtEvalue
	bne	.suit
	move.b	#":",(a0)+
	move.b	#" ",(a0)+
	move.l	d3,d0
	subq.b	#1,d2
	bmi.s	.ent
	bne.s	.str
* Chiffre FLOAT
	moveq	#-1,d4
	moveq	#0,d5
	jsr	DtkFl
	bra.s	.suit
* Chiffre ENTIER
.ent	cmp.l	#EntNul,d3
	beq.s	.entD
	jsr	LongDec
	bra.s	.suit
.entD	lea	Inf_Nul(pc),a1
.entE	move.b	(a1)+,(a0)+
	bne.s	.entE
	subq.l	#1,a0
	bra.s	.suit
* Chaine
.str	moveq	#'"',d1
	move.b	d1,(a0)+
	sub.w	#76-6,d4
	neg.w	d4
	move.l	d0,a1
	move.w	(a1)+,d2
	cmp.w	d4,d2
	bcs.s	.skip1
	move.w	d4,d2
	moveq	#">",d1
.skip1	subq.w	#1,d2
	bmi.s	.skip2
.loop	move.b	(a1)+,d0
	cmp.b	#32,d0
	bcc.s	.skip3
	moveq	#".",d0
.skip3	move.b	d0,(a0)+
	dbra	d2,.loop
.skip2	move.b	d1,(a0)+
* Imprime la chaine...
.suit	btst	#31,d7
	beq.s	.suit1
	lea	Inf_ShadOff(pc),a1
.suit0	move.b	(a1)+,(a0)+
	bne.s	.suit0
	subq.l	#1,a0
.suit1	move.b	#7,(a0)+
	clr.b	(a0)
	move.l	EdBufT(a5),a1
	addq.l	#2,a1
	WiCall	Print
	movem.l	(sp)+,a2/d3-d7
	rts

******* Impression dans le buffer infos
Inf_PrDeb
	movem.l	a0/d0,-(sp)
	move.l	Inf_Pos(a4),a0
	clr.w	(a0)
	move.w	d0,2(a0)
	move.w	#-1,4(a0)
	movem.l	(sp)+,a0/d0
	rts
Inf_Print
	movem.l	a0-a2/d0,-(sp)
	move.l	Inf_Pos(a4),a1
	move.l	a1,a2
	move.w	(a2),d0
	lea	6(a1,d0.w),a1
	subq.w	#1,d0
.loop	addq.w	#1,d0
	cmp.b	#76,d0
	bcc.s	.out
	move.b	(a0)+,(a1)+
	bne.s	.loop
.out	clr.b	(a1)
	move.w	d0,(a2)
	movem.l	(sp)+,a0-a2/d0
	rts
Inf_PrFin
	move.l	d0,-(sp)
	move.l	Inf_Pos(a4),a0
	move.w	(a0),d0
	cmp.w	#76,d0
	bcc.s	.skip
	move.b	#7,6(a0,d0.w)
	clr.b	7(a0,d0.w)
	addq.w	#1,d0
.skip	addq.w	#8,d0
	and.w	#$FFFE,d0
	move.w	d0,(a0)
	add.w	d0,a0
	move.l	a0,Inf_Pos(a4)
	clr.w	(a0)
	move.l	(sp)+,d0
	rts

******* Supression ligne dans buffer...
*	D0=	numero des lignes a supprimer...
Inf_Del	
	lea	Inf_Buf(a4),a0
	move.l	Inf_Pos(a4),d1
	moveq	#0,d2
	moveq	#0,d3
.loop	move.l	a0,a1
	cmp.l	d1,a0
	bcc.s	.out
	cmp.w	2(a0),d0
	beq.s	.del
	add.w	(a0),a0
	bra.s	.loop
.del	add.w	(a1),d2
	lea	0(a0,d2.w),a1
	cmp.l	d1,a1
	bcc.s	.dele
	cmp.w	2(a1),d0
	beq.s	.del
.dele	sub.l	d2,d1
.loopD	move.w	(a1)+,(a0)+
	cmp.l	d1,a0
	bls.s	.loopD
	subq.l	#2,a0
	addq.w	#1,d3
	bra.s	.loop
.out	move.l	d1,Inf_Pos(a4)
	move.w	d3,d0
	rts
******* Insere D octets au debut des infos
Inf_Ins	movem.l	a1/a2,-(sp)
	lea	Inf_Buf(a4),a0
	move.l	Inf_Pos(a4),a1
	lea	0(a1,d0.w),a2
	move.l	a2,Inf_Pos(a4)
	clr.w	(a2)
.loop	move.w	-(a1),-(a2)
	cmp.l	a0,a1
	bcc.s	.loop
* Empeche les plantages...
	move.w	d0,(a0)+
	clr.l	(a0)
	clr.w	4(a0)
	movem.l	(sp)+,a1/a2
	rts

******* Clique dans le slider vertical
Inf_SlClic
	bsr	XYMouEc
	move.w	d2,d0
	sub.w	Inf_sly(a4),d0
	cmp.w	Inf_slp1(a4),d0
	bcs.s	InfDown
	cmp.w	Inf_slp2(a4),d0
	bcc	InfUp
** POSITIONNE DIRECTEMENT
	move.w	d2,d7
	sub.w	Inf_slp1(a4),d7
.loop	sub.w	d7,d2
	bpl.s	.skip0
	moveq	#0,d2
.skip0	move.w	Inf_NLigne(a4),d0
	mulu	d0,d2
	move.w	Ttt_tlb(a4),d1
	divu	d1,d2
	lsr.w	#3,d2
	move.w	Inf_NLigne(a4),d0
	sub.w	Ttt_tlb(a4),d0
	addq.w	#1,d0
	bmi.s	.skip
	cmp.w	d0,d2
	bcs.s	.skip1
	move.w	d0,d2
.skip1	cmp.w	Inf_YPos(a4),d2
	beq.s	.skip
	move.w	d2,Inf_YPos(a4)
	movem.l	d0-d7,-(sp)
	bsr	Inf_Slider
	movem.l	(sp)+,d0-d7
.skip	SyCall	Mousekey
	btst	#0,d1
	beq.s	.out
	bsr	XYMouEc
	bra.s	.loop
.out	bsr	Inf_AffAll
	rts
** SCROLL VERS LE BAS
InfDown	tst.w	Inf_YPos(a4)
	beq.s	.skip
	subq.w	#1,Inf_YPos(a4)
* Scrolle l'ecran graphique
	WiCalA	Print,Ttt_Scrdown(pc)	
* Affiche la derniere ligne
	moveq	#0,d0
	bsr	Inf_AffLine
	bsr	Inf_Slider
.skip	rts
** SCROLL VERS LE HAUT
InfUp	move.w	Inf_YPos(a4),d0		* Deja la derniere ligne
	add.w	Ttt_tlb(a4),d0
	cmp.w	Inf_NLigne(a4),d0
	bhi.s	.skip
	addq.w	#1,Inf_YPos(a4)
* Scrolle l'ecran graphique
	lea	Ttt_scrup(pc),a1
	move.w	Ttt_tlb(a4),d0
	add.b	#48-1,d0
	move.b	d0,2(a1)
	WiCall	Print	
* Affiche la derniere ligne
	move.w	Ttt_tlb(a4),d0
	subq.w	#1,d0
	bsr	Inf_AffLine
	bsr	Inf_Slider
.skip	rts

******* Affichage du slider informations
Inf_Slider
	moveq	#Inf_sltx,d1
	move.w	Ttt_tlb(a4),d2
	mulu	#8,d2
	move.w	Inf_NLigne(a4),d3
	move.w	Inf_YPos(a4),d4
	move.w	Ttt_tlb(a4),d5
	move.w	#Inf_slx,d6
	move.w	Inf_sly(a4),d7
	movem.l	d1-d7,-(sp)
	EcCall	VerSli
	movem.l	(sp)+,d1-d7
	move.w	d2,d0
	bsr	SliPour
	move.w	d6,Inf_slp1(a4)
	move.w	d7,Inf_slp2(a4)
	rts


***********************************************************************
*
*	Gestion principale


******* Entree du TUTOR par le PROGRAMME...
Prog_Tutor
	movem.l	a3-a6,-(sp)
	bsr	TutorInit
	move.w	#2,RunAct(a5)
	move.w	#1,tt_Init(a4)
	move.w	#-1,TtRun(a4)
	movem.l	(sp)+,a3-a6
	jmp	InsRet

******* Entree du TUTOR par l'EDITEUR...
Edit_Tutor
	jsr	TokCur
	move.l	BasSp(a5),sp
	jsr	EdBlFree
	jsr	EdHide
	bsr	TutorInit
	clr.w	TtRun(a4)

******* Boucle principale de test des touches
TtTests
	move.l	Tt_Base(a5),a4
	clr.w	TtActive(a4)
TtReLoop
	bsr	View_Act
	clr.w	TtAccel(a4)
	tst.w	TtActive(a4)
	beq.s	TtLoop
.loop	jsr	WaitMul
	SyCall	MouseKey
	btst	#0,d1
	beq.s	.Out
	SyCall	GetZone
	cmp.w	#EcTut1,d1
	bne.s	.Out
	swap	d1
	cmp.w	TtActive(a4),d1
	beq.s	.loop
.Out	move.w	TtActive(a4),d0
	clr.w	TtActive(a4)
	moveq	#0,d1
	bsr	ABouton
TtLoop
* Attente multitache
	jsr	WaitMul
* Gestion des zones actives!
	SyCall	MouseKey
	move.w	d1,TtMKey
	and.w	#$03,d1			Bouton de gauche--> normal
	beq	TtReLoop
	
	bsr	Ttt_InfAct
	bsr	Ttt_AlertDel		Enleve les alertes
	bsr	View_Act

	SyCall	GetZone
	cmp.w	#EcTut2,d1
	beq	Ttt_Zone
	cmp.w	#EcTut1,d1
	bne	TtReLoop
	swap 	d1
	tst.w	d1
	beq	TtReLoop
	move.w	d1,d0

* Touches HELP/BREAK/EVAL?
	cmp.w	#14,d0
	bcc.s	.skip

	cmp.w	TtActive(a4),d1
	beq.s	.skip
* Active la touche
	tst.w	TtActive(a4)
	bne	TtReLoop
	move.w	d1,TtActive(a4)
	moveq	#1,d1
	bsr	ABouton
.skip
* Appel des fonctions
	lsl.w	#2,d0
	lea	TtBra-4(pc),a0
	jsr	0(a0,d0.w)
	bra	TtReLoop

******* Table des sauts
TtBra	bra	TtRien			1:  STOP, teste separement
	bra	Step0			2:  mode pas a pas
	bra	Step1			3:  mode semi-rapide 
	bra	Step2			4:  mode rapide 
	bra	Step3			5:  mode ultra-rapide
	bra	TtUp			6:
	bra	TtDown			7:
	bra	TtLeft			8:
	bra	TtRight			9:  
	bra	TtCEc			10: Change ecran
	bra	TtInitialise		11: Init
	bra	TtQuit			12: Quit
	bra	TtSee			13: Voir l'affichage
	bra	TtSHelp			14: Set Help
	bra	TtSBreak		15: Set break
	bra	TtSEval			16: Set evalue
TtRien	rts

******* INITIALISATION GENERALE...
TutorInit
* Ferme l'editeur.
	jsr	ClosEd
* Enleve le flash de l'ecran TUT
	move.w	#65535,T_TFlash+2(a5)	Pas de flash avant 21 heures!
* Reservation de la zone de datas
	move.l	#TtDzlong,d0
	jsr	RamFast
	move.l	d0,a4
* Sauve les donnees
	lea	EdBufE(a5),a0
	lea	TtSEdit(a4),a1
	moveq	#(WbClose-EdBufE)/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	lea	EdTyM0(a5),a0
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.l	T_EcAdr+EcTut1*4(a5),(a1)+
	move.l	T_EcAdr+EcTut2*4(a5),(a1)+
	clr.l	T_EcAdr+EcTut1*4(a5)
	clr.l	T_EcAdr+EcTut2*4(a5)
* Poke les nouvelles...
	move.l	a4,Tt_Base(a5)
	lea	TtBufE(a4),a0
	move.l	a0,EdBufE(a5)
*	clr.w	EdYPos(a5)
*	clr.w	EdYCu(a5)
*	clr.w	EdXPos(a5)
*	clr.w	EdYPos(a5)
*	clr.w	Y1Bloc(a5)
*	clr.w	Y2Bloc(a5)
	move.w	#-1,TtYMark(a4)
	move.w	#-1,TtYNext(a4)
*	clr.w	StepMode(a4)
*	clr.l	StepBreak(a4)
*	clr.w	tt_Init(a4)
	lea	Inf_Buf(a4),a0
	move.l	a0,Inf_Pos(a4)
	moveq	#2,d0
	lea	Inf_Separ(pc),a0
	bsr	Inf_PrDeb
	bsr	Inf_Print
	bsr	Inf_PrFin
	moveq	#4,d0
	lea	Inf_Separ(pc),a0
	bsr	Inf_PrDeb
	bsr	Inf_Print
	bsr	Inf_PrFin
* Poke les patches
	lea	TstPatch(pc),a0
	move.l	a0,ExtTests+4(a5)
	lea	GFolow,a0
	lea	GTutor(pc),a1
	jsr	SetFolow
* Ouverture de l'écran REDUCE
	moveq	#1,d0
	moveq	#EcTut1,d3
	jsr	TtUPack
	move.l	T_EcCourant(a5),a0
	move.w	FkPosY(a5),EcAWy(a0)
	move.w	EcTy(a0),ViewTy(a4)
	SyCalD	ResZone,NBoutons
* Affiche!
	bsr	ABoutons
	bsr	TttAMod
	move.w	#-1,TtView(a4)
	bsr	View_Cls
	bsr	Ttt_Open
	jsr	Recop
* Branche les interruptions couleurs...
	lea	VblRout(a5),a0
.loopI	tst.l	(a0)+
	bne.s	.loopI
	lea	View_Inter(pc),a1
	move.l	a1,-4(a0)
* Prepare les affichage des ecrans
	bsr	Set_WPatch
	bsr	View_ScUpdate
	bsr	View_Act
	bsr	View_Aff
* Limite la souris...
	bsr	MouSto
	rts

******* QUITTER / Retour à l'éditeur
TtQuit	
	tst.w	Tt_Init(a4)
	beq.s	.Quit
** Si Break Off >>> on peut pas!!!
	move.w	ActuMask(a5),d0
	btst	#BitControl,d0
	bne.s	.Quit
	lea	Inf_NoQuit(pc),a0
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	rts
.Quit
* Enleve le patch sur W
	bsr	Del_WPatch
* Enleve les interruptions
	lea	VblRout(a5),a0
	lea	View_Inter(pc),a1
.loopI	cmp.l	(a0)+,a1
	bne.s	.loopI
	clr.l	-4(a0)
* Enleve les ecrans
	EcCalD	Del,EcTut1
	EcCalD	Del,EcTut2
* Restore les donnees editeur
	lea	TtSEdit(a4),a0
	lea	EdBufE(a5),a1
	moveq	#(WbClose-EdBufE)/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	lea	EdTyM0(a5),a1
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.l	(a0)+,T_EcAdr+EcTut1*4(a5)
	move.l	(a0)+,T_EcAdr+EcTut2*4(a5)
	clr.w	RunAct(a5)
* Enleve le patch
	lea	GFolow,a0
	lea	CFol1,a1
	jsr	SetFolow
	clr.l	ExtTests+4(a5)
	bclr	#1,T_Actualise+1(a5)
	bclr	#1,ActuMask+1(a5)
** Retour à l'editeur ou au programme???
	move.l	a4,a1
	move.l	#TtDzLong,d0
	tst.w	TtRun(a4)
	bne.s	.torun
* Retour à l'éditeur...
.parun	jsr	RamFree
	jsr	OpnEd
	jsr	EscToEd
	move.w	#1,T_Tflash+2(a5)
	move.l	BasSp(a5),sp
	jmp	EdLoop
* Retour au programme
.torun	tst.w	tt_Init(a4)
	beq.s	.parun
	move.l	StepSp(a4),sp
	movem.l	(sp)+,a2-a6
	jsr	RamFree
	jsr	Recop
	move.w	#1,T_Tflash+2(a5)
	move.w	ScOn(a5),d1
	beq.s	.skip
	subq.w	#1,d1
	EcCall	Active
.skip	rts	

******* HELP / BREAK / EVAL
TtSHelp
	clr.w	Ttt_Mode(a4)
	bra.s	Tttamod
TtSBreak	
	move.w	#1,Ttt_Mode(a4)
	bra.s	Tttamod
TtSEval
	move.w	#2,Ttt_Mode(a4)
* Affiche les boutons
Tttamod
	moveq	#14,d0
	moveq	#0,d2
.loop	moveq	#0,d1
	cmp.w	Ttt_Mode(a4),d2
	bne.s	.skip
	moveq	#-1,d1
.skip	bsr	ABouton
	addq.w	#1,d0
	addq.w	#1,d2
	cmp.w	#3,d2
	bne.s	.loop
	rts

******* CHANGEMENT D'ECRAN VIEW
TtCEc	bsr	View_GEc
	bsr	View_Aff
	rts
******* MOUVEMENT VERS LE BAS DANS L'ECRAN
TtDown	bsr	View_ScAd
	bmi.s	TtMvX
	bsr	Accel
	move.w	6(a0),d0
	move.w	d0,d2
	sub.w	2(a0),d0
	sub.w	d1,d0
	cmp.w	#RedTy,d0
	bcs.s	TtMvS
	add.w	d1,2(a0)
	bsr	View_Aff
	bra.s	TtMvX
******* MOUVEMENT VERS LE HAUT DANS ECRAN
TtUp	bsr	View_ScAd
	bmi.s	TtMvX
	bsr	Accel
	move.w	2(a0),d0
	sub.w	d1,d0
	bmi.s	TtMvS
	move.w	d0,2(a0)
	bsr	View_Aff
	bra.s	TtMvX
TtMvS	clr.w	TtAccel(a4)
TtMvX	addq.l	#4,sp
	bra	TtLoop
******* MOUVEMENT VERS LA GAUCHE DANS ECRAN
TtLeft	bsr	View_ScAd
	bmi.s	TtMvX
	bsr	Accel
	move.w	(a0),d0
	sub.w	d1,d0
	bmi.s	TtMvS
	move.w	d0,(a0)
	bsr	View_Aff
	bra.s	TtMvX
******* MOUVEMENT VERS LA DROITE DANS L'ECRAN
TtRight	bsr	View_ScAd
	bmi.s	TtMvX
	bsr	Accel
	move.w	4(a0),d0
	sub.w	(a0),d0
	sub.w	d1,d0
	cmp.w	#RedTx,d0
	bcs.s	TtMvS
	add.w	d1,(a0)
	bsr	View_Aff
	bra.s	TtMvX
* Acceleration
Accel	move.w	TtAccel(a4),d1
	cmp.w	#15,d1
	bcc.s	.skip
	addq.w	#1,d1
	move.w	d1,TtAccel(a4)
.skip	lsr.w	#2,d1
	lea	Tablacc(pc),a1
	move.b	0(a1,d1.w),d1	
	ext.w	d1
	rts
******* PASSE AUX ECRANS DU PROGRAMME
TtSee	bsr	TtHide
	bsr	WMky
	bsr	TtShow
	rts

*********************************************************************
*	
*	Gestion du pas a pas
*

GTutor	jmp	InTutor

******* INIT
TtInitialise
	moveq	#1,d0
	bsr	Inf_Del
	moveq	#3,d0
	bsr	Inf_Del
	lea	Inf_Test(pc),a0
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	move.l	StBas(a5),DRun(a5)
	jsr	ClearVar
	jsr	EffBanks
	move.w	#2,RunAct(a5)
	Tjsr	PTest
	bsr	Ttt_AlertDel
	move.w	#1,DefFlag(a5)
	move.w	#1,Tt_Init(a4)
	clr.w	TtMFlag(a4)
	Tjsr	DefRun
	EcCalD	Last,0
	Tjsr	DefRun2
	jsr	Recop
	move.l	StBas(a5),a6
	jmp	ChrIn3
** Erreurs lors du test!
TtVerErr
	move.l	BasSp(a5),sp
	move.l	a0,-(sp)
	move.l	Tt_Base(a5),a4
	clr.w	tt_Init(a4)
	clr.w	TtXNext(a4)
	move.l	VerPos(a5),a0
	jsr	FindA			* Cherche le numero / adresse
	move.w	d0,TtYNext(a4)

	bsr	Ttt_TttAct
	bsr	Ttt_Centre
	bsr	Ttt_AffBuf

	move.l	(sp)+,a0
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bsr	Inf_AffAll

	bra	TtReLoop

******* Entree du pas a pas...
InTutor
	pea	0(a0,d0.w)
	cmp.w	#TkDP-Tk,-2(a6)		* Pas sur un :
	beq	InTutX
	lea	-2(a6),a1
** Mode RAPIDE, saute tout sauf si breakpoint...
	move.l	Tt_Base(a5),a0
	cmp.w	#2,StepMode(a0)
	bcs.s	.skipB
	bne.s	.skip
	bset	#1,T_Actualise+1(a5)
.skip	tst.w	StepStop(a0)
	bne.s	.skipB0
	cmp.l	StepBreak(a0),a1
	bne	InTutX
	cmp.w	#3,StepMode(a0)
	bne.s	.skipB
	bsr	TtShow
** Mode LENT, avec affichage...
.skipB	tst.w	tt_init(a0)
	beq.s	.skippy
	bclr	#BitControl,T_Actualise(a5)	* Control-C a chaque coup!
	bne.s	.skipB0
	cmp.l	StepBreak(a0),a1
	bne.s	.skipB1
	lea	Inf_Break(pc),a1
	move.l	a1,StepMess(a0)
.skipB0	clr.l	StepBreak(a0)
	clr.w	StepStop(a0)
	clr.w	StepMode(a0)
.skipB1	move.l	a4,d0
	move.l	d0,a0				* Adresse de la ligne
	beq	InTutX
	jsr	FindA
* Procedure fermee-> pointe le nom de la procedure
	tst.l	d1
	bne.s	.lockee
	move.l	a6,d1
	subq.l	#2,d1
	moveq	#0,d2
	bra.s	.nolock
.lockee	addq.l	#2,d1
	moveq	#-1,d2
* Poke les adresses
.nolock	move.l	a0,a2
.skippy	movem.l	a2-a6,-(sp)
	move.l	Tt_Base(a5),a4		Sauve la pile / Flag general
	move.l	sp,StepSp(a4)
	move.w	d0,TtYNext(a4)
	move.l	d1,TtAdress(a4)
	move.w	d2,TtLocked(a4)
	move.l	a2,TtDCurLine(a4)
* Empeche les appels du test
	bclr	#1,T_Actualise+1(a5)
	bclr	#1,ActuMask+1(a5)
* Actualise l'affichage
	move.w	#-1,TtEcran(a4)
	bsr	View_Act
*	move.w	ScOn(a5),d1
*	subq.w	#2,d1
*	bsr	View_Ec
	bsr	View_Aff

******* Affichage complet de la prochaine instruction
	moveq	#0,d0
	bsr	Inf_Del	
	moveq	#5,d0
	bsr	Inf_Del
** Programme initialise?
	tst.w	tt_Init(a4)
	beq	.nopar
** Pointe dans le programme
	move.w	TtYNext(a4),d0
	bsr	TtDecoup
	move.l	TtAdress(a4),a0
	sub.l	Ttaline(a4),a0
	lea	TtLigne-4(a4),a1
.loop	addq.l	#4,a1
	cmp.w	2(a1),a0
	bhi.s	.loop
	moveq	#0,d0
	move.b	1(a1),d0
	move.w	d0,TtXNext(a4)
	bsr	Ttt_TttAct
	bsr	Ttt_Centre
	bsr	Ttt_AffBuf
** Affiche le NOM de l'instruction
	moveq	#5,d0
	bsr	Inf_PrDeb
* Procedure fermee
	tst.w	TtLocked(a4)
	beq.s	.palok
	lea	Inf_PLock(pc),a0
	bsr	Inf_Print
	move.l	EdBufT(a5),a0
	move.b	1(a0),d0
	addq.l	#2,a0
	clr.b	0(a0,d0.w)
	bsr	Inf_Print
	bsr	Inf_PrFin	
	bra	.nopar
* Met le nom
.palok	lea	Inf_NextI(pc),a0
	bsr	Inf_Print
	lea	TtLigne(a4),a2
	move.l	TtAdress(a4),d0
	sub.l	TtAline(a4),d0
.loopA2	cmp.w	2(a2),d0
	beq.s	.outA2
	addq.l	#4,a2
	tst.b	(a2)
	bne.s	.loopA2
.outA2	moveq	#0,d0
	move.b	1(a2),d0
.loopA3	addq.l	#4,a2
	tst.b	(a2)
	beq.s	.outA3
	cmp.b	#":",(a2)
	bne.s	.loopA3
.outA3	moveq	#0,d1
	move.b	1(a2),d1
	move.l	EdBufT(a5),a0
	addq.l	#2,a0
	clr.b	0(a0,d1.w)
	add.w	d0,a0
	bsr	Inf_Print
	bsr	Inf_PrFin	
** Affiche la liste des parametres
	lea	Tk,a0
	move.l	TtAdress(a4),a6
	move.w	(a6)+,d0
	move.w	-2(a6),d0
	lea	4(a0,d0.w),a3
	moveq	#0,d7
	cmp.w	#TkRem1-Tk,d0
	beq	.nopar
	cmp.w	#TkRem2-Tk,d0
	beq	.nopar
	cmp.w	#TkFade-Tk,d0
	beq	.fade
	cmp.w	#TkPal-Tk,d0
	beq	.fade
	cmp.w	#TkExt-Tk,d0
	bne.s	.noext
* Appel d'une extension
	move.b	(a6)+,d1
	move.b	(a6)+,d0
	move.w	(a6)+,d2
	ext.w	d1
	lsl.w	#2,d1
	lea	AdTokens(a5),a0
	lea	4(a0,d1.w),a3
.noext
.floop1	tst.b	(a3)+
	bpl.s	.floop1
	move.b	(a3)+,d0
	cmp.b	#"I",d0
	bne	.nopar
.floop2	tst.b	(a3)+
	bmi	.nopar	
	bsr	TtImpParam
	tst.b	(a3)+
	bpl	.floop2
	bra.s	.nopar
** FADE / PALETTE
.fade	bsr	TtImpParam
	subq.l	#2,a6
	jsr	Finie
	addq.l	#2,a6
	bne.s	.fade
.nopar	
** Afficher un message???
	move.l	StepMess(a4),d0
	beq.s	.jij
	clr.l	StepMess(a4)
	move.l	d0,a0
	bsr	Ttt_Alert
.jij
** Va tout imprimer...
	bsr	Ttt_InfAct
	bsr	Inf_AffAll

******* Attente de commande
	bsr	View_Act
	move.w	StepMode(a4),d0
* Pas a pas: libere le bouton, et branche aux tests
	bne.s	.skk
	bsr	MouSto
	bra	TtReLoop
.skk	cmp.w	#1,d0
	beq.s	.skiu
	bsr	MouSto
	bra	TtTests
* Deroulement semi-rapide: appui sur STOP?
.skiu	SyCall	Mousekey
	btst	#0,d1
	beq.s	StepOut
	SyCall	GetZone
	cmp.w	#EcTut1,d1
	bne.s	StepOut
	swap	d1
	tst.w	d1
	beq.s	StepOut
	cmp.w	#13,d1
	beq.s	StepOut
	bsr	MouSto
	clr.w	StepMode(a4)
	bsr	View_Act
	bsr	BoutStop
	moveq	#10,d2
.Loap	SyCall	WaitVbl
	dbra	d2,.Loap
	bra	TtReLoop

******* Sortie du mode pas a pas, reactive l'ancien ecran
StepOut	bset	#1,T_Actualise+1(a5)
	bset	#1,ActuMask+1(a5)
StepOut2
	bsr	MouBack
	move.l	StepSp(a4),sp
	movem.l	(sp)+,a2-a6
	move.w	#2,RunAct(a5)
	move.w	ScOn(a5),d1
	beq.s	InTutX
	subq.w	#1,d1
	EcCall	Active
* Branche a l'instruction
InTutX	rts

******* Routine : Imprime "Param #1="
TtImpParam
	moveq	#5,d0
	bsr	Inf_PrDeb
	lea	Inf_Par1(pc),a0
	bsr	Inf_Print
	addq.l	#1,d7
	move.l	d7,d0
	move.l	Buffer(a5),a0
	jsr	LongDec
	clr.b	(a0)
	move.l	Buffer(a5),a0
	bsr	Inf_Print
	lea	Inf_Par2(pc),a0
	bsr	Inf_Print
* Va evaluer...
	bsr	TtEvalue
	beq.s	.paer
	lea	Inf_ParE(pc),a1
.parer	move.b	(a1)+,(a0)+
	bne.s	.parer
	subq.l	#1,a0
	bra.s	.suit
.paer	addq.l	#2,a6
	move.l	d3,d0	
	move.l	Buffer(a5),a0
	subq.b	#1,d2
	bmi.s	.ent
	beq.s	.fl
* Une chaine...
	moveq	#'"',d2
	move.b	d2,(a0)+
	move.l	d0,a1
	move.w	(a1)+,d0
	beq.s	.Bla
	cmp.w	#60,d0
	bcs.s	.Ble
	moveq	#60,d0
	moveq	#">",d2
.Ble	subq.w	#1,d0
.Bli	move.b	(a1)+,d1
	cmp.b	#32,d1
	bcc.s	.Blo
	moveq	#".",d1
.Blo	move.b	d1,(a0)+
	dbra	d0,.Bli
.Bla	move.b	d2,(a0)+
	bra.s	.suit
* Chiffre FLOAT
.fl	moveq	#-1,d4
	moveq	#0,d5
	jsr	DtkFl
	bra.s	.suit
* Chiffre ENTIER
.ent	cmp.l	#EntNul,d3
	beq.s	.entD
	jsr	LongDec
	bra.s	.suit
.entD	lea	Inf_Ommit(pc),a1
.entE	move.b	(a1)+,(a0)+
	bne.s	.entE
 	subq.l	#1,a0
* Imprime
.suit	clr.b	(a0)
	move.l	Buffer(a5),a0
	bsr	Inf_Print
	bsr	Inf_PrFin
	rts

******* En cas d'erreur non détournee
TtError	move.l	Tt_Base(a5),a1
	move.l	a0,StepMess(a1)
	move.w	d0,d1
	lea	2(a4),a6
	move.l	PLoop(a5),a3
	move.l	BasSp(a5),sp
	lea	Tk,a0
	move.w	(a4)+,d0
	move.w	0(a0,d0.w),d0
	clr.w	StepMode(a1)
	bsr	TtShow
	cmp.w	#9,d1
	beq	InTutor
	clr.w	tt_Init(a1)
	jsr	CloAll
	bra	InTutor


******* Stocke l'etat de la souris
MouSto	movem.l	d0-d7/a0-a3,-(sp)
	move.w	#1,TtMFlag(a4)
	SyCall	StoreM			Hide / Show
	lea 	T_MouXMin(a5),a0
	lea	LimSave(a5),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	moveq	#0,d1
	moveq	#0,d2
	moveq	#EcTut1+1,d3
	SyCall	XyHard
	movem.w	d1/d2,-(sp)
	move.l	T_EcAdr+EcTut2*4(a5),a0
	move.w	EcTx(a0),d1
	move.w	EcTy(a0),d2
	moveq	#EcTut2+1,d3
	SyCall	XyHard
	movem.w	(sp)+,d3/d4
	SyCall	LimitM
	SyCalD	Show,-1
	movem.l	(sp)+,d0-d7/a0-a3
	rts
******* Remet la souris
MouBack	tst.w	TtMFlag(a4)
	beq.s	.nos
	movem.l	d0-d7/a0-a3,-(sp)
	clr.w	TtMFlag(a4)
	SyCall	ReCallM
	lea	LimSave(a5),a0
	lea	T_MouXMin(a5),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movem.l	(sp)+,d0-d7/a0-a3
.nos	rts

******* Va evaluer une expression
TtEvalue
	movem.l	d1/d4-d7/a0-a5,-(sp)
	move.l	a6,TtEvDebut(a4)
	move.w	#1,RunAct(a5)		Patcher les erreurs
TtReEv	move.l	sp,TtEvPile(a4)		Position pile en cas de menage
	sub.l	a4,a4
	move.l	PLoop(a5),a3
	jsr	Evalue
	movem.l	(sp)+,d1/d4-d7/a0-a5
	clr.w	RunAct(a5)
	moveq	#0,d0			Pas d'erreur!
	rts
** En cas d'erreurs d'evaluation
TtErreur
	move.l	Tt_Base(a5),a4
	move.l	TtEvPile(a4),sp
	movem.l	(sp)+,d1/d4-d7/a0-a5
	clr.w	RunAct(a5)
	moveq	#0,d3
	moveq	#0,d2
	moveq	#-1,d0
	rts
** En cas de menage
TtMenage
	move.l	Tt_Base(a5),a4
	move.l	TtEvPile(a4),sp
	move.l	TtEvDebut(a4),d0
	beq.s	.err
	move.l	d0,a6
	clr.l	TtEvDebut(a4)
	movem.l	(sp),d4-d7/a0-a5
	bra.s	TtReEv	
.err	moveq	#11,d0
	jmp	RunErr

******* Patch branche sur TESTS: reaffiche l'ecran (mode 3)
TstPatch
	movem.l	d0-d7/a0-a6,-(sp)
* Actualise
	move.l	Tt_Base(a5),a4
	move.w	#-1,TtEcran(a4)
	bsr	View_Act
*	move.w	ScOn(a5),d1
*	subq.w	#2,d1
*	bsr	View_Ec
	bsr	View_Aff
* Verifie que l'on appuie pas sur la souris
	cmp.w	#2,StepMode(a4)
	bcs.s	.skip
	SyCall	Mousekey
	btst	#0,d1
	beq.s	.skip
	SyCall	GetZone
	cmp.w	#EcTut1,d1
	bne.s	.skip
	swap	d1
	tst.w	d1
	beq.s	.skip
	cmp.w	#13,d1
	beq.s	.skip
	addq.w	#1,StepStop(a4)
	bsr	BoutStop
* Empeche les boucles
.skip	move.w	ScOn(a5),d1
	beq.s	.skip1
	subq.w	#1,d1
	EcCall	Active
.skip1	bclr	#7,T_Actualise(a5)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
BoutStop
	move.w	TtActive(a4),d0
	moveq	#0,d1
	bsr	ABouton
	moveq	#1,d0
	move.w	d0,TtActive(a4)
	moveq	#1,d1
	bra	ABouton
	
******* UNE INSTRUCTION 
Step0	bsr	WMky
	tst.w	tt_Init(a4)
	bne	StepOut
NoInit	lea	Inf_NoInit(pc),a0
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bra	WMky
******* DEROULEMENT SEMI-RAPIDE
Step1	bsr	WMky
	tst.w	tt_Init(a4)
	beq.s	NoInit
	move.w	#1,StepMode(a4)
	bra	StepOut
******* DEROULEMENT RAPIDE
Step2	bsr	WMky
	tst.w	tt_Init(a4)
	beq.s	NoInit
	move.w	#2,StepMode(a4)
	bra	StepOut
******* DEROULEMENT ULTRA-RAPIDE
Step3	bsr	WMky
	tst.w	tt_Init(a4)
	beq.s	NoInit
	bsr	TtHide
	move.w	#3,StepMode(a4)
	bra	StepOut2

******* Cache les deux ecrans
TtHide	moveq	#-1,d2
Tth	movem.l	d0-d7/a0-a4,-(sp)
	EcCalD	EHide,EcTut1
	EcCalD	EHide,EcTut2
	jsr	Recop
	movem.l	(sp)+,d0-d7/a0-a4
	rts
******* Remet les deux ecrans
TtShow	moveq	#0,d2
	bra.s	Tth

******* Branche le patch sur W
Set_WPatch
	lea	Old_EcVect(pc),a0
	move.l	T_EcVect(a5),(a0)
	lea	Old_SyVect(pc),a0
	move.l	T_SyVect(a5),(a0)
	lea	EcIn(pc),a0
	move.l	a0,T_EcVect(a5)
	lea	SyIn(pc),a0
	move.l	a0,T_SyVect(a5)
	rts
******* Enleve le patch sur W
Del_WPatch
	move.l	Old_EcVect(pc),T_EcVect(a5)
	move.l	Old_SyVect(pc),T_SyVect(a5)
	rts

******* Patch des fonctions W ecrans...
Ecin	bsr	TT_WPatch		RAZ
	bsr	TT_WPatch2		Copper
	bsr	TT_WPatch2		Libre
	bsr	TT_WPatchC		Cree
	bsr	TT_WPatch		Del
	bsr	TT_WPatch		First
	bsr	TT_WPatch		Last
	bsr	TT_WPatch		Active
	bsr	TT_WPatch2		Forcecop
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch

******* Restore les ecrans puis appelle
TT_WPatch2
	bsr.s	Ttfirst
******* Patch normal...
TT_WPatch
	move.l	a0,-(sp)
	move.l	4(sp),a0
	sub.l	T_EcVect(a5),a0
	subq.l	#4,a0
	add.l	Old_EcVect(pc),a0
	move.l	a0,4(sp)
	move.l	(sp)+,a0
	rts
******* Appelle puis restore les ecrans
TT_WPatch1
	move.l	(sp)+,a0
	sub.l	T_EcVect(a5),a0
	subq.l	#4,a0
	add.l	Old_EcVect(pc),a0
	jsr	(a0)
* Routine: met les deux en premier...
Ttfirst	movem.l	a0-a6/d0-d7,-(sp)
	move.l	Old_EcVect(pc),a0	* Ecran Tutor1
	moveq	#EcTut1,d1
	jsr	First*4(a0)
	move.l	Old_EcVect(pc),a0	* Ecran Tutor2
	moveq	#EcTut2,d1
	jsr	First*4(a0)
	move.l	Old_EcVect(pc),a0	* Ecran FSEL
	moveq	#EcFSel,d1
	jsr	First*4(a0)
	move.l	Old_EcVect(pc),a0	* Ecran Requester
	moveq	#EcReq,d1
	jsr	First*4(a0)
	movem.l	(sp)+,a0-a6/d0-d7
	tst.l	d0
	rts
******* Patch pour CREATION ecran
Tt_WPatchC
* Appelle
	move.l	(sp)+,a0
	sub.l	T_EcVect(a5),a0
	subq.l	#4,a0
	add.l	Old_EcVect(pc),a0
	jsr	(a0)
	bne.s	.Err
* Change les tables du TUTOR
	movem.l	a0/a1/d0/d1,-(sp)
	move.w	EcNumber(a0),d1
	cmp.w	#8,d1
	bcc.s	.skuo
	lsl.w	#3,d1
	move.l	Tt_Base(a5),a1
	lea	ViewScrols(a1),a1
	add.w	d1,a1
	clr.l	(a1)
	move.w	EcTx(a0),4(a1)
	move.w	EcTy(a0),d0
	tst.w	EcCon0(a0)
	bmi.s	.skip
	lsr.w	#1,d0
.skip	move.w	d0,6(a1)
.skuo	movem.l	(sp)+,a0/a1/d0/d1
* Ok!
.Err	tst.w	d0
	rts


******* Patch des fonctions W systeme
SyIn:	bsr 	TT_SPatch	ClInky		;0
	bsr	TT_SPatch	ClVide		;1
	bsr 	TT_SPatch	ClSh		;2
	bsr	TT_SPatch	ClInst		;3
	bsr	TT_SPatch	ClKeyM		;4
	bsr	TT_SPatch	ClJoy		;5
	bsr	TT_SPatch	ClPutK		;6
	bsr	TT_SPatch	MHide		;7
	bsr	TT_SPatch	MShow		;8
	bsr	TT_SPatch	MChange		;9 - ChMouse
	bsr	TT_SPatch	MXy		;10- XY Mouse
	bsr	TT_SPatch	CXyHard		;11- Conversion SCREEN-> HARD
	bsr	TT_SXyScr	CXyScr		;12- Conversion HARD-> SCREEN
	bsr	TT_SPatch	MBout		;13
	bsr	TT_SPatch	MSetAb		;14
	bsr	TT_SGSIn	GetSIn		;15- Get screen IN
	bsr	TT_SPatch	CXyWi		;16- Conversion SCREEN-> WINDOW courante
	bsr	TT_SPatch	MLimA		;17- Limit mouse
	bsr	TT_SZoHd	SyZoHd		;18- Zone coordonnees HARD
	bsr	TT_SPatch	SyResZ		;19- Reserve des zones
	bsr	TT_SPatch	SyRazZ		;20- Effacement zones
	bsr	TT_SPatch	SySetZ		;21- Set zone
	bsr	TT_SPatch	SyMouZ		;22- Zone souris!	
	bsr	TT_SPatch	WVbl		;23
	bsr	TT_SPatch	HsSet		;24- Affiche un hard sprite
	bsr	TT_SPatch	HsUSet		;25- Efface un hard sprite
	bsr	TT_SPatch	ClFFk		;26
	bsr	TT_SPatch	ClGFFk		;27
	bsr	TT_SPatch	HsAff		;28- Recalcule les hard sprites
	bsr	TT_SPatch	HsBank		;29- Fixe la banque de sprites
	bsr	TT_SPatch	HsNXYA		;30- Instruction sprite
	bsr	TT_SPatch	HsXOff		;31- Sprite off n
	bsr	TT_SPatch	HsOff		;32- All sprite off
	bsr	TT_SPatch	HsAct		;33- Actualisation HSprite	
	bsr	TT_SPatch	HsSBuf		;34- Set nombre de lignes
	bsr	TT_SPatch	HsStAct		;35- Arrete les HS sans deasctiver!
	bsr	TT_SPatch	HsReAct		;36- Re-Active tous!
	bsr	TT_SPatch	MStore		;37- Stocke etat souris / Show on
	bsr	TT_SPatch	MRecall		;38- Remet la souris 
	bsr	TT_SPatch	HsPri		;39- Priorites SPRITES/PLAYFIELD
	bsr	TT_SPatch	TokAMAL		;40- Tokenise AMAL
	bsr	TT_SPatch	CreAMAL		;41- Demarre AMAL
	bsr	TT_SPatch	MvOAMAL		;42- On/Off/Freeze AMAL
	bsr	TT_SPatch	DAllAMAL	;43- Enleve TOUT!
	bsr	TT_SPatch	Animeur		;44- Un coup d'animation
	bsr	TT_SPatch	RegAMAL		;45- Registre!
	bsr	TT_SPatch	ClrAMAL		;46- Clear
	bsr	TT_SPatch	FrzAMAL		;47- FREEZE all
	bsr	TT_SPatch	UFrzAMAL	;48- UNFREEZE all
	bsr	TT_SPatch	BobSet		;49- Entree set bob
	bsr	TT_SPatch	BobOff		;50- Arret bob
	bsr	TT_SPatch	BobSOff		;51- Arret tous bobs
	bsr 	TT_SPatch	BobAct		;52- Actualisation bobs
	bsr	TT_SPatch	BobAff		;53- Affichage bobs
	bsr	TT_SPatch	BobEff		;54- Effacement bobs
	bsr	TT_SPatch	ChipMM		;55- Reserve CHIP
	bsr	TT_SPatch	FastMM		;56- Reserve FAST
	bsr	TT_SPatch	BobLim		;57- Limite bobs!
	bsr	TT_SPatch	SyZoGr		;58- Zone coord graphiques
	bsr	TT_SPatch	GetBob		;59- Saisie graphique
	bsr	TT_SPatch	Masque		;60- Calcul du masque
	bsr	TT_SPatch	SpotH		;61- Fixe le point chaud
	bsr	TT_SPatch	BbColl		;62- Collisions bob
	bsr	TT_SPatch	GetCol		;63- Fonction collision
	bsr	TT_SPatch	SpColl		;64- Collisions sprites
	bsr	TT_SPatch	SyncO		;65- Synchro on/off
	bsr	TT_SPatch	Sync		;66- Synchro step
	bsr	TT_SPatch	SetPlay		;67- Set play direction...
	bsr	TT_SPatch	BobXY		;68- Get XY Bob
	bsr	TT_SPatch	HsXY		;69- Get XY Sprite
	bsr	TT_SPatch	BobPut		;70- Put Bob!
	bsr	TT_SPatch	TPatch		;71- Patch icon/bob!
	bsr	TT_SPatch	MRout		;72- Souris relachee
	bsr	TT_SPatch	MLimEc		;73- Limit mouse ecran
	bsr	TT_SPatch	FreeMM		;74- Libere mem
	bsr	TT_SPatch	HColSet		;75- Set HardCol
	bsr	TT_SPatch	HColGet		;76- Get HardCol
	bsr	TT_SPatch	TMovon		;77- Movon!
	bsr	TT_SPatch	TKSpeed		;78- Key speed
	bsr	TT_SPatch	TChanA		;79- =ChanAn
	bsr	TT_SPatch	TChanM		;80- =ChanMv
	bsr	TT_SPatch	TPrio		;81- Set priority
	bsr	TT_SPatch	TGetDisc	;82- State of disc drive
	bsr	TT_SPatch	Add_VBL		;83- Restart VBL
	bsr	TT_SPatch	Rem_VBL		;84- Stop VBL
	bsr	TT_SPatch	Test_Cyclique	;85- V110 Tests Cycliques AA

******* Patch systeme normal...
TT_SPatch
	move.l	a0,-(sp)
	move.l	4(sp),a0
	sub.l	T_SyVect(a5),a0
	subq.l	#4,a0
	add.l	Old_SyVect(pc),a0
	move.l	a0,4(sp)
	move.l	(sp)+,a0
	rts
******* Patch fonction XyScr
TT_SXyScr
	bsr	TT_SHere	
	bne	TT_SPatch
	move.l	a4,(sp)
	move.l	TT_Base(a5),a4
	bsr	TTHard2Screen
	movem.l	(sp)+,a4
	bpl.s	.Skip
	moveq	#0,d1
	moveq	#0,d2
.Skip	moveq	#0,d0
	rts
******* Patch fonction Zone Hard
TT_SZoHd
	bsr	TT_SHere	
	bne	TT_SPatch
	move.l	a4,(sp)
	move.l	TT_Base(a5),a4
	bsr	TTHard2Screen
	move.l	(sp)+,a4
	bmi.s	.Out
	moveq	#8,d5
	move.l	Old_SyVect(pc),a0
	jsr	ZoGr*4(a0)
.Skip	rts
.Out	moveq	#0,d1
	moveq	#0,d0
	rts
******* Patch fonction GetSCin
TT_SGSin
	bsr	TT_SHere	
	bne	TT_SPatch
	move.l	a4,(sp)
	move.l	TT_Base(a5),a4
	bsr	TTEcIn
	bmi.s	.Out
	lsl.w	#2,d0
	lea	T_EcAdr(a5),a1
	move.l	0(a1,d0.w),d0
	beq.s	.Out
	move.l	d0,a1
	bsr	XY2Ec
	bmi.s	.Out
	cmp.w	EcTx(a1),d1
	bcc.s	.Out
	cmp.w	EcTy(a1),d2
	bcc.s	.Out
	moveq	#0,d1
	move.w	EcNumber(a1),d1
	move.l	(sp)+,a4
	moveq	#0,d0
	rts
.Out	move.l	#EntNul,d1
	move.l	(sp)+,a4
	moveq	#0,d0
	rts

******* Conversion coordonnées hard (d1/d2/d3) -> coordonnées ecran 
TTHard2Screen
	bsr	TTEcToA1
	bmi.s	.Out
	move.l	a0,a1
	bsr	TTEcIn
	bmi.s	.Out
	move.w	EcNumber(a1),d3
	addq.w	#1,d3
	cmp.w	EcNumber(a1),d0
	beq.s	XY2Ec
.Out	moveq	#-1,d0
	rts
******* Converti D1/D2 en coord dans l'ecran A1
XY2Ec	movem.w	d1-d3,-(sp)
	bsr	View_Scad
	movem.w	(sp)+,d1-d3
	add.w	(a0)+,d1
	add.w	(a0)+,d2
* Si lowres, multiplie par 2 en Y
	btst	#7,EcCon0(a1)
	bne.s	.Hires
	lsl.w	#1,d2
.Hires
	moveq	#0,d0
	rts

******* Trouve l'écran sous les coordonnees hard...
*	D1/D2= X/Y HARD
*	D3= 1er ecran
*	D4= Ecran MAX
TTEcIn	movem.l	a0/d3,-(sp)
	move.w	d2,-(sp)
	move.w	d1,-(sp)
	moveq	#EcTut1+1,d3
	move.l	Old_SyVect(pc),a0
	jsr	XyScr*4(a0)
	tst.w	(sp)
	beq.s	.Skip1
	sub.w	#RedX,d1
	bmi.s	.Pas
	cmp.w	#RedTX,d1
	bcc.s	.Pas
.Skip1	tst.w	2(sp)
	beq.s	.Ok
	sub.w	#RedY,d2
	bmi.s	.Pas
	cmp.w	#RedTY,d2
	bcc.s	.Pas
* Dans le petit ecran...
.Ok	move.w	TtView(a4),d0
	bpl.s	.In
.Pas	moveq	#-1,d0
.In	addq.l	#4,sp
	movem.l	(sp)+,a0/d3
	rts

******* Ecrans D3
*	<0	=> Rien du tout
*	0	=> Ecran courant
*	>0	=> Ecran+1
TTEcToA1
	tst.w	d3
	bmi.s	EcToD4
	bne.s	EcToD2
	move.l	T_EcCourant(a5),a0
	rts
EcToD2:	lsl.w	#2,d3
	lea	T_EcAdr(a5),a0
	move.l	-4(a0,d3.w),d3
	beq.s	EcToD3
	move.l	d3,a0
	rts
EcToD3:	addq.l	#4,sp
	moveq	#3,d0
	rts
EcToD4:	moveq	#-1,d0
	rts

******* Retourne BNE si l'ecran du tuteur n'est pas la
*	Si ecran courant de 8 à 12
*	Si StepMode>2
TT_SHere
	movem.l	a0/d0,-(sp)
	move.l	T_EcCourant(a5),d0
	beq.s	.No
	move.l	d0,a0
	move.w	EcNumber(a0),d0
	cmp.w	#8,d0
	bcc.s	.No
	moveq	#0,d0
	move.l	Tt_Base(a5),a0
	cmp.w	#3,StepMode(a0)
	bcs.s	.Out
.No	moveq	#1,d0
.Out	tst.w	d0
	movem.l	(sp)+,a0/d0
	rts

*********************************************************************
*
*	Gestion de l'ecran de texte
*

******* Appui sur une zone
Ttt_Zone
	swap 	d1
	subq.w	#1,d1
	bmi	TtReLoop
* Active l'écran texte
	move.w	d1,-(sp)
	bsr	Ttt_TttAct
	move.w	(sp)+,d1
* Appel des fonctions
	lsl.w	#2,d1
	lea	TttBra(pc),a0
	jsr	0(a0,d1.w)
	bra	TtReLoop
TttBra	bra	Ttt_ListClic		1 : Zone de listing
	bra	Ttt_Separ		2 : Separation
	bra	Ttt_InfClic		3 : Zone d'infos
	bra	Ttt_slhclic		4 : Slider horizontal
	bra	Ttt_CText		5 : Centre text
	bra	Ttt_slvclic		6 : Slider vertical 1
	bra	Ttt_InfSlClic		7 : Slider vertical 2

******* Clique sur le slider infos
Ttt_InfSlClic
	bsr	Ttt_InfAct
	bra	Inf_slclic

******* Clique sur une expression dans les infos
Ttt_InfClic
	bsr	XYMouEc
	lsr.w	#3,d2
	sub.w	Ttttlh(a4),d2
	subq.w	#2,d2
* Recherche la ligne dans le buffer
	lea	Inf_Buf(a4),a0
	moveq	#100,d0
	moveq	#0,d1
.loop	add.w	d1,a0
	move.w	(a0),d1
	beq.s	.out
	cmp.w	4(a0),d2
	bne.s	.loop
	cmp.w	#3,2(a0)		Enleve 1 ligne PARAM
	beq.s	.skip
	cmp.w	#1,2(a0)		... et TOUTES les infos
	bne.s	.out
	moveq	#1,d0
.skip	move.w	d0,2(a0)
	bsr	Inf_Del
	bsr	Inf_Centre
.out	bsr	WMky
	rts

******* Centre text
Ttt_CText
	tst.w	TtYNext(a4)
	bmi	NoInit
	bsr	Ttt_Centre
	bra	Ttt_AffBuf

******* Clique dans le texte
*	Delimite une zone soulignee dans le texte
Ttt_ListClic	
	bsr	.MouMou
	cmp.w	EdNLigne(a5),d2
	bcc	.out
	
* Regarde le mode courant
	cmp.w	#2,TtMKey(a4)		Bouton droit>>> short cut
	beq.s	.Break
	move.w	Ttt_Mode(a4),d0
	subq.w	#1,d0
	bmi.s	.Help
	beq.s	.Break
	bne	.Eval

******* Demande de HELP sur un mot...
.Help	bsr	.Souligne
	beq	WMky
* Enleve le PATCH W!
	bsr	Del_WPatch
	bsr	Help_Edit
	bsr	Set_WPatch
	move.w	#-1,TtYInfo(a4)
	bra	Ttt_AffBuf
	
******* Fixe le breakpoint
.Break
	move.w	#-1,TtYMark(a4)
	clr.l	StepBreak(a4)
	move.w	d2,d0
	bsr	TtDecoup
	lea	TtLigne(a4),a0
	move.b	(a0),d0
	beq.s	.out
	cmp.b	1(a0),d1
	bcs.s	.out
	move.l	a0,a1
.loop1	addq.l	#4,a0
	move.b	(a0),d0
	beq.s	.skip2
	cmp.b	#":",d0
	beq.s	.skip1
	cmp.b	#"W",d0
	beq.s	.skip1
	cmp.b	#"X",d0
	beq.s	.skip1
	cmp.b	#"I",d0
	bne.s	.loop1
.skip1	cmp.b	1(a0),d1
	bcs.s	.found
	move.l	a0,a1
	bra.s	.loop1
.skip2	cmp.b	1(a0),d1
	bcc.s	.out
.found	cmp.l	a0,a1
	beq.s	.out
	cmp.b	#":",(a1)
	beq.s	.out
* OK, on pointe une instruction!!!
	move.w	d2,TtYMark(a4)
	moveq	#0,d0
	move.b	1(a1),d0
	move.w	d0,TtX1Mark(a4)
	move.b	1(a0),d0
	move.w	d0,TtX2Mark(a4)
* Marque le breakpoint!
	move.l	TTAline(a4),a2
	add.w	2(a1),a2
	move.l	a2,StepBreak(a4)
* Provoque un reaffichage de l'ecran
.out	bsr	Ttt_AffBuf
	bra	Wmky

******* On veut evaluer une expression...
.Eval
	bsr	.Souligne
	beq	.paexp
* Test ASCII de la ligne
	move.l	a0,a1
	move.w	d0,d3
	subq.w	#1,d3
	moveq	#0,d4
	moveq	#0,d5
.chk	move.b	(a1)+,d6
	cmp.b	#"(",d6
	bne.s	.chk2
	addq.w	#1,d4
.chk2	cmp.b	#")",d6
	bne.s	.chk3
	subq.w	#1,d4
.chk3	cmp.b	#'"',d6
	bne.s	.chk4
	addq.w	#1,d5
.chk4	dbra	d3,.chk
	tst.w	d4
	bne	.paexp
	btst	#0,d4
	bne	.paexp
* Decoupe la ligne en bouts...
	move.w	d2,d0
	bsr	TtDecoup
	lea	TtLigne(a4),a0
	move.b	(a0),d0
	beq	.paexp
	cmp.b	1(a0),d1
	bcs	.paexp
* Trouve le debut
.eloop1	move.l	a0,a1
	cmp.b	1(a1),d1
	beq.s	.eout1
	addq.l	#4,a0
	cmp.b	1(a0),d1
	bcs.s	.eout1
	tst.b	(a0)
	bne.s	.eloop1
	bra	.paexp
* Trouve la fin
.eout1	move.w	TtX2Info(a4),d0
	move.l	a1,a2
.eloop2	addq.l	#4,a2
	tst.b	(a2)
	beq.s	.eout2
	cmp.b	1(a2),d0
	bhi.s	.eloop2
* Que pointe thon?
.eout2	move.b	(a1),d0
	cmp.b	#":",d0
	beq	.paexp
	cmp.b	#"W",d0
	beq	.paexp
	cmp.b	#":",-4(a1)
	beq	.paexp
	tst.w	tt_Init(a4)
	beq	NoInit
	cmp.b	#"-",d0
	beq.s	.exp1
	cmp.b	#"V",d0
	beq.s	.exp1
	cmp.b	#"0",d0
	bcs	.paexp
	cmp.b	#"2",d0
	bhi	.paexp
* Recopie dans le buffer tokenisation
.exp1	move.l	EdBufT(a5),a3
	move.l	TtAline(a4),a0
* Un GLOBAL ou un SHARED
	cmp.w	#TkGlo-Tk,2(a0)
	beq	.paexp
	cmp.w	#TkSha-Tk,2(a0)
	beq	.paexp
	add.w	2(a2),a0
	move.l	a0,a2
	move.l	TtAline(a4),a0
	add.w	2(a1),a0
.lp1	move.w	(a0)+,(a3)+
	cmp.l	a2,a0
	bcs.s	.lp1
	clr.w	(a3)+
	sub.l	EdBufT(a5),a3
	move.l	a3,d7
* Meme niveau de procedure?
	move.l	TtDCurLine(a4),a2
	move.l	TtAline(a4),a3
	cmp.l	a2,a3
	bcc.s	.pro1
	exg	a2,a3
.pro1	cmp.l	a3,a2
	bhi.s	.pro2
	move.w	2(a2),d0
	cmp.w	#TkProc-Tk,d0
	beq.s	.paniv
	cmp.w	#TkEndP-Tk,d0
	beq.s	.paniv
	moveq	#0,d0
	move.b	(a2),d0
	lsl.w	#1,d0
	add.w	d0,a2
	bra.s	.pro1
* Au debut de quelque chose de possible...
.pro2	lea	Inf_Buf(a4),a0
	move.l	Inf_Pos(a4),d0
	sub.l	a0,d0
	cmp.l	#Inf_Size-Inf_Size/3,d0
	bcc	.2many
	move.l	EdBufT(a5),a6
	bsr	TtEvalue
	bne.s	.paexp
	move.w	d7,d0			* Insere l'expression dans la liste
	add.w	#12,d0
	bsr	Inf_Ins
	move.w	#3,(a0)+
	move.w	#-1,(a0)+
	move.l	BasA3(a5),(a0)+
	move.l	EdBufT(a5),a1
.pro3	move.w	(a1)+,(a0)+
	subq.w	#2,d7
	bne.s	.pro3
* Va imprimer, et revient
.expout	move.w	#-1,TtYInfo(a4)
	bsr	Ttt_AffBuf
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	rts
* Cannot evaluate!
.paexp	move.w	#-1,TtYInfo(a4)
	lea	Inf_Err(pc),a0
	bsr	Ttt_Alert
	bra	.expout
* Erreur: pas meme niveau
.paniv	lea	Inf_Proc(pc),a0
	bsr	Ttt_Alert
	bra.s	.expout
* Too many expresions
.2many	lea	Inf_2Many(pc),a0
	bsr	Ttt_Alert
	bra.s	.expout
******* Routine, ouverture d'un souligne sur la ligne courante
.Souligne
	mulu	#256,d4
	move.l	EdBufE(a5),a0
	add.w	d4,a0
	cmp.w	(a0),d1
	bcc.s	.SNon
	move.w	d1,TtX1Info(a4)
	addq.w	#1,d1
	move.w	d1,TtX2Info(a4)
	move.w	d2,TtYInfo(a4)
	move.l	a0,-(sp)
	bsr	Ttt_AffBuf
.Sloop	jsr	WaitMul
	SyCall	Mousekey
	btst	#0,d1
	beq.s	.SOut
	bsr	.MouMou
	addq.w	#1,d1
	cmp.w	TtX1Info(a4),d1
	bls.s	.Sloop
	move.l	(sp),a0
	cmp.w	(a0),d1
	bhi.s	.Sloop
	move.w	d1,TtX2Info(a4)
	moveq	#0,d1
	move.w	TtYInfo(a4),d1
	sub.w	EdYPos(a5),d1
	bsr	TtEALigne
	bra.s	.Sloop
* Retour, A0 pointe la chaine...
.Sout	move.l	(sp)+,a0
	move.w	TtYInfo(a4),d2
	move.w	TtX1Info(a4),d1
	move.w	TtX2Info(a4),d0
	lea	2(a0,d1.w),a0
	sub.w	d1,d0
	bls.s	.SNon
	rts
* Rien!
.SNon	moveq	#0,d0
	rts
	
* Coordonnee de la souris
.MouMou	bsr	XYMouEc
	sub.w	#16,d1
	subq.w	#8,d2
	lsr.w	#3,d1
	lsr.w	#3,d2
	move.w	d2,d4
	add.w	EdXPos(a5),d1
	add.w	EdYPos(a5),d2
	cmp.w	TtYNext(a4),d2
	bne.s	.mou2
	move.w	TtXNext(a4),d0
	cmp.w	d0,d1
	bcs.s	.mou2
	addq.w	#3,d0
	sub.w	d1,d0
	bls.s	.mou1
	sub.w	d0,d1
	rts
.mou1	subq.w	#3,d1
.mou2	rts

******* Decoupe la ligne en ses instructions / fonctions
*	D0= ligne
TtDecoup
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	FindL
	move.l	a0,Ttaline(a4)
	move.l	a0,a6
	sub.l	a3,a3
	subq.l	#1,a3
	lea	Ttligne(a4),a0
	move.l	a0,Ttpline(a4)
	move.l	#":---",-4(a0)
	move.l	EdBufT(a5),a4
	Tjsr	Detok
	movem.l	(sp)+,d0-d7/a0-a6
	rts
* Partie appelle par la detokenisation...
TTDecoupe
	moveq	#0,d1
	move.w	(a6),d0
	beq	.skip1
	moveq	#"-",d1
	cmp.w	#TkM-Tk,d0
	beq	.skip1
	moveq	#":",d1
	cmp.w	#TkDP-Tk,d0
	beq	.skip1
	cmp.w	#TkThen-Tk,d0
	beq	.skip1
	cmp.w	#TkElse-Tk,d0
	beq	.skip1
	moveq	#"V",d1
	cmp.w	#TkVar-Tk,d0
	beq.s	.skip1
	moveq	#"X",d1
	cmp.w	#TkPro-Tk,d0
	beq.s	.skip1
	moveq	#"G",d1
	cmp.w	#TkLGo-Tk,d0
	beq.s	.skip1
	moveq	#"2",d1
	cmp.w	#TkCh1-Tk,d0
	beq.s	.skip1
	cmp.w	#TkCh2-Tk,d0
	beq.s	.skip1
	moveq	#"1",d1
	cmp.w	#TkFl-Tk,d0
	beq.s	.skip1
	moveq	#"(",d1
	cmp.w	#TkPar1-Tk,d0
	beq.s	.skip1
	moveq	#")",d1
	cmp.w	#TkPar2-Tk,d0
	beq.s	.skip1
	moveq	#",",d1
	cmp.w	#TkVir-Tk,d0
	beq.s	.skip1
	cmp.w	#TkPVir-Tk,d0
	beq.s	.skip1
	cmp.w	#TkTo-Tk,d0
	beq.s	.skip1
	cmp.w	#TkAs-Tk,d0
	beq.s	.skip1
	moveq	#"0",d1
	cmp.w	#TkExt-Tk,d0
	bcs.s	.skip1
	beq.s	.jmp1
* Instruction/fonction normale
	lea	Tk,a0
	lea	4(a0,d0.w),a0
.loop1	tst.b	(a0)+
	bpl.s	.loop1
	move.b	(a0)+,d1
	bpl.s	.skip2
.skip0	moveq	#"I",d1
.skip2	cmp.b	#"V",d1
	bne.s	.skip1
	move.b	(a0)+,d1
* Poke l'adresse dans la table
.skip1	move.l	Tt_Base(a5),a1
	move.l	Ttpline(a1),a0
	cmp.b	#"V",d1
	beq.s	.skup
	cmp.b	#"0",d1
	beq.s	.skup
	cmp.b	#"1",d1
	beq.s	.skup
	cmp.b	#"2",d1
	bne.s	.skip3
.skup	cmp.b	#":",-4(a0)
	bne.s	.skip3
	moveq	#"W",d1
.skip3	move.b	d1,(a0)+
	move.l	a4,d0
	sub.l	EdBufT(a5),d0
	subq.l	#2,d0
	move.b	d0,(a0)+
	move.l	a6,d0
	sub.l	Ttaline(a1),d0
	move.w	d0,(a0)+
	move.l	a0,Ttpline(a1)
	rts
* Detokenise une extension
.jmp1	lea	AdTokens(a5),a0
	move.w	2(a6),d1
	move.b	(a6),d2
	ext.w	d2
	move.w	d2,d3
	lsl.w	#2,d2
	tst.l	0(a0,d2.w)
	beq.s	.skip0
	move.l	0(a0,d2.w),a0
	lea	4(a0,d1.w),a0
	bra.s	.loop1

******* Clique dans le slider horizontal
Ttt_Slhclic
	bsr	XYMouEc
	move.w	d1,d0
	sub.w	#Ttsl_hx,d0
	cmp.w	Ttsl_hp1(a4),d0
	bcs.s	TttGoch
	cmp.w	Ttsl_hp2(a4),d0
	bcc	TttDroi
** POSITIONNE DIRECTEMENT
	move.w	d1,d7
	sub.w	Ttsl_hp1(a4),d7
.loop	sub.w	d7,d1
	bpl.s	.skip0
	moveq	#0,d1
.skip0	mulu	#254,d1
	divu	#76*8,d1
	cmp.w	#254-76,d1
	bcs.s	.skip1
	move.w	#254-76,d1
.skip1	cmp.w	EdXPos(a5),d1
	beq.s	.skip
	move.w	d1,EdXPos(a5)
	bsr	Ttt_NewBuf
.skip	SyCall	Mousekey
	btst	#0,d1
	beq.s	.out
	bsr	XYMouEc
	bra.s	.loop
.out	rts
** SCROLL VERS LA GAUCHE
TttGoch	tst.w	EdXPos(a5)
	beq.s	.skip
	sub.w	#10,EdXPos(a5)
	bsr	Ttt_NewBuf
.skip	rts
** SCROLL VERS LE HAUT
TttDroi	move.w	EdXPos(a5),d0
	add.w	#10,d0
	cmp.w	#254-76,d0
	bls.s	.skip
	move.w	#254-76,d0
.skip	move.w	d0,EdXPos(a5)
	bsr	Ttt_NewBuf
	rts

******* Clique dans le slider vertical
Ttt_Slvclic
	bsr	XYMouEc
	move.w	d2,d0
	sub.w	#Ttsl_vy,d0
	cmp.w	ttsl_vp1(a4),d0
	bcs.s	TttDown
	cmp.w	ttsl_vp2(a4),d0
	bcc	TttUp
** POSITIONNE DIRECTEMENT
	move.w	d2,d7
	sub.w	ttsl_vp1(a4),d7
.loop	sub.w	d7,d2
	bpl.s	.skip0
	moveq	#0,d2
.skip0	move.w	EdNLigne(a5),d0
	mulu	d0,d2
	move.w	Ttttlh(a4),d1
*	subq.w	#1,d1
	divu	d1,d2
	lsr.w	#3,d2
	move.w	EdNLigne(a5),d0
	sub.w	Ttttlh(a4),d0
	addq.w	#1,d0
	cmp.w	d0,d2
	bcs.s	.skip1
	move.w	d0,d2
.skip1	cmp.w	EdYPos(a5),d2
	beq.s	.skip
	move.w	d2,EdYPos(a5)
	move.l	d7,-(sp)
	bsr	Ttt_SliV
	move.l	(sp)+,d7
.skip	SyCall	Mousekey
	btst	#0,d1
	beq.s	.out
	bsr	XYMouEc
	bra.s	.loop
.out	bsr	Ttt_NewBuf
	rts
** SCROLL VERS LE BAS
TttDown	tst.w	EdYPos(a5)
	beq.s	.skip
	subq.w	#1,EdYPos(a5)
* Scrolle l'ecran graphique
	WiCalA	Print,Ttt_Scrdown(pc)	
* Scrolle l'ecran texte
	move.l	EdBufE(a5),a1
	move.w	EdTyM0(a5),d0
	lsl.w	#8,d0
	add.w	d0,a1
	lea	-256(a1),a0
	move.w	EdTyM1(a5),d0
	lsl.w	#4,d0
	subq.w	#1,d0
.loop	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	dbra	d0,.loop
* Affiche la derniere ligne
	move.w	EdYPos(a5),d0
	moveq	#0,d1
	Tjsr	Untok
	bsr	TtALigne
	bsr	Ttt_SliV
.skip	rts
** SCROLL VERS LE HAUT
TttUp	move.w	EdYPos(a5),d0		* Deja la derniere ligne
	add.w	Ttttlh(a4),d0
	cmp.w	EdNLigne(a5),d0
	bhi.s	.skip
	addq.w	#1,EdYPos(a5)
* Scrolle l'ecran graphique
	lea	Ttt_scrup(pc),a1
	move.w	Ttttlh(a4),d0
	add.b	#48-1,d0
	move.b	d0,2(a1)
	WiCall	Print	
* Scrolle l'ecran texte
	move.l	EdBufE(a5),a1
	lea	256(a1),a0
	move.w	EdTyM1(a5),d0
	lsl.w	#4,d0
	subq.w	#1,d0
.loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.loop
* Affiche la derniere ligne
	move.w	EdYPos(a5),d0
	add.w	EdTyM1(a5),d0
	move.w	EdTyM1(a5),d1
	Tjsr	Untok
	bsr	TtALigne
	bsr	Ttt_SliV	
.skip	rts

******* Centre le listing sur l'instruction courante
Ttt_Centre
	move.w	EdYPos(a5),d2
	move.w	d2,d3
	add.w	Ttttlh(a4),d3
	addq.w	#1,d2
	subq.w	#1,d3
	move.w	TtYNext(a4),d0
	cmp.w	d2,d0
	bcs.s	.change
	cmp.w	d3,d0
	bcc.s	.change
	rts
* Change la position de l'editeur
.change	move.w	Ttttlh(a4),d2
	subq.w	#1,d0
	bpl.s	.skip1
	moveq	#0,d0
.skip1	add.w	d0,d2
	cmp.w	EdNLigne(a5),d2
	bcs.s	.skip2
	sub.w	EdNLigne(a5),d2
	sub.w	d2,d0
	bpl.s	.skip2
	moveq	#0,d0
.skip2	move.w	d0,EdYPos(a5)
	Tjsr	BufUntok
	rts

******* CHANGEMENT DE LA SEPARATION LISTING/INFO
Ttt_Separ
	bsr	XYMouEc
	move.w	TttTlh(a4),d0
	lsl.w	#3,d0
	addq.w	#8,d0
	sub.w	d0,d2
	move.w	d2,-(sp)		Decalage souris/bloc
	move.w	d0,-(sp)		Ancien bloc
	move.w	d0,-(sp)		Nouveau bloc
.Loop0
* Fabrique le bloc
	moveq	#0,d2
	move.w	(sp),d3
	ext.l	d3
	move.l	#640,d4	
	moveq	#8,d5
	moveq	#0,d6
	move.l	Buffer(a5),a1
	EcCalD	BlGet,127
	move.w	(sp),2(sp)
* Dessine l'image
	moveq	#Ttt_pic+2,d0
	moveq	#0,d1
	move.w	(sp),d2
	moveq	#-1,d3
	bsr	TtUPack
* Prend la souris
.Loop1	SyCall	Mousekey
	btst	#0,d1
	beq.s	.Skip
	bsr	XYMouEc
	sub.w	4(sp),d2
	cmp.w	(sp),d2
	beq.s	.Loop1
	cmp.w	#8+3*8,d2
	bcs.s	.Loop1
	move.w	TttTy(a4),d0
	sub.w	#32-4,d0
	cmp.w	d0,d2
	bcc.s	.Loop1
	move.w	d2,(sp)
* Efface l'ancien
.Skip	moveq	#0,d2
	move.w	2(sp),d3
	ext.l	d3
	move.l	#Entnul,d4
	move.l	d4,d5
	move.l	Buffer(a5),a1
	EcCalD	BlPut,127
* Lache la souris?
	SyCall	Mousekey
	btst	#0,d1
	bne	.Loop0
* Efface le bloc
	EcCalD	BlDel,127
* Change la position du milieu...
	move.w	(sp),d0
	bsr	SetTtt
	addq.l	#6,sp
* Va redessinner les textes
	bsr	Ttt_Cls
	bsr	Ttt_NewBuf
* Recentre les infos?
Inf_Centre
	bsr	Inf_CptLines
	move.w	Inf_YPos(a4),d0
	add.w	Ttt_tlb(a4),d0
	move.w	Inf_Nligne(a4),d1
	cmp.w	d0,d1
	bcc.s	.sss
	sub.w	d1,d0
	sub.w	d0,Inf_YPos(a4)
	bpl.s	.sss
	clr.w	Inf_YPos(a4)
.sss	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	rts

******* Alertes
Ttt_Alert
	move.l	a0,-(sp)
	moveq	#0,d0
	bsr	Inf_Del
	move.l	(sp)+,a0
	moveq	#0,d0
	addq.w	#1,Inf_AlertOn(a4)
	clr.w	Inf_YPos(a4)
	bsr	Inf_PrDeb
	move.l	a0,-(sp)
	lea	Inf_Mark(pc),a0
	bsr	Inf_Print
	move.l	(sp)+,a0
	bsr	Inf_Print
	bsr	Inf_PrFin
	lea	Inf_Separ(pc),a0
	bsr	Inf_PrDeb
	bsr	Inf_Print
	bsr	Inf_PrFin
	rts
Ttt_AlertDel
	movem.l	a0-a6/d0-d7,-(sp)
	tst.w	Inf_AlertOn(a4)
	beq.s	.out
	clr.w	Inf_AlertOn(a4)
	moveq	#0,d0
	bsr	Inf_Del
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
.out	movem.l	(sp)+,a0-a6/d0-d7
	rts
******* Supression / Affichage lignes du buffer
Ttt_DelAff
	bsr	Inf_Del
	beq.s	.skip
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
.skip	rts
******* Active l'ecran / la fenetre infos
Ttt_InfAct
	bsr	Ttt_Act
	WiCalD	QWindow,2
	rts
******* Active l'ecran / la fenetre ttt
Ttt_TttAct	
	bsr	Ttt_Act
	WiCalD	QWindow,1
	rts

******* Fixe les tailles texte
SetTtt	subq.w	#8,d0	
	lsr.w	#3,d0
	move.w	d0,TTtTlh(a4)
	move.w	d0,EdTyM0(a5)
	move.w	d0,EdTyM1(a5)
	move.w	d0,EdTyM2(a5)
	subq.w	#1,EdTyM1(a5)
	subq.w	#2,EdTyM2(a5)
	move.w	TttTy(a4),d1
	sub.w	#24,d1
	lsr.w	#3,d1
	sub.w	d0,d1
	move.w	d1,TTt_Tlb(a4)
	rts

******* Ouverture de l'ecran
Ttt_Open
	move.l	#640,d2
	move.l	FkEcran(a5),a0		Taille du texte...
	move.w	EcTy(a0),d3
	move.l	EdEcran(a5),a0
	add.w	EcTy(a0),d3
	sub.w	ViewTy(a4),d3
	add.w	#15,d3
	and.w	#$FFF0,d3
	cmp.w	#Ttt_MinTy*8,d3
	bcc.s	.skipT1
	moveq	#Ttt_MinTy*8,d3
.skipT1	cmp.w	#Ttt_MaxTy*8,d3
	bcs.s	.skipT2
	move.w	#Ttt_MaxTy*8,d3
.skipT2	move.w	d3,TttTy(a4)
	ext.l	d3
	moveq	#2,d4
	move.l	#$8000,d5
	moveq	#4,d6
	moveq	#0,d7
	lea	DefPal(a5),a1
	EcCalD	Cree,EcTut2
	move.w	FkPosY(a5),d0
	add.w	#115,d0	
	move.w	d0,EcAWY(a0)
* Palette
	move.l	#$0000058D,EcPal(a0)
	move.l	#$0AEF0247,EcPal+4(a0)
* Curseur
	WiCalA	Print,Ttt_WInit(pc)
* Reserve des zones
	SyCalD	ResZone,20
* Dessine les bords
	moveq	#Ttt_pic,d0		Image du haut
	moveq	#0,d1
	moveq	#0,d2
	moveq	#-1,d3
	bsr	TtUPack
	moveq	#Ttt_pic+4,d0
	move.w	TttTy(a4),d2
	subq.w	#8,d2
	bsr	TtUPack
* Va dessiner le fond
	move.w	TttTy(a4),d0
	lsr.w	#1,d0
	addq.w	#8,d0
	bsr	SetTtt
	bsr	Ttt_Cls
* Defini les sliders
	moveq	#3,d0
	moveq	#3,d1
	moveq	#3,d2
	moveq	#1,d3
	moveq	#1,d4
	moveq	#1,d5
	moveq	#1,d6
	moveq	#1,d7
	EcCall	SetSli
* Affiche le contenu!
	bsr	Ttt_NewBuf
	rts

******* Affichage du programme
Ttt_AffBuf
	movem.l	d0-d7,-(sp)
	bra.s	Blu
Ttt_NewBuf
	movem.l	d0-d7,-(sp)
	TJsr	BufUntok
Blu
	bsr	Ttt_TttAct
	moveq	#0,d1
.loop	bsr	TtEALigne
	addq.w	#1,d1
	cmp.w	EdTyM0(a5),d1
	bcs.s	.loop
	bsr	Ttt_SliV
	bsr	Ttt_SliH
	movem.l	(sp)+,d0-d7
	rts

******* Affichage du slider vertical
Ttt_SliV
	moveq	#ttsl_vtx,d1
	move.w	EdTyM0(a5),d2
	mulu	#8,d2
	move.w	EdNLigne(a5),d3
	move.w	EdYPos(a5),d4
	move.w	EdTyM0(a5),d5
	move.w	#ttsl_vx,d6
	moveq	#ttsl_vy,d7
	movem.l	d1-d7,-(sp)
	EcCall	VerSli
	movem.l	(sp)+,d1-d7
	move.w	d2,d0
	bsr	SliPour
	move.w	d6,ttsl_vp1(a4)
	move.w	d7,ttsl_vp2(a4)
	rts

******* Affichage du slider horizontal
Ttt_SliH
	move.w	#ttsl_htx,d1
	moveq	#ttsl_hty,d2
	move.w	#254,d3
	move.w	EdXPos(a5),d4
	moveq	#76,d5
	moveq	#ttsl_hx,d6
	move.w	#ttsl_hy,d7
	movem.l	d1-d7,-(sp)
	EcCall	HorSli
	movem.l	(sp)+,d1-d7
	move.w	d1,d0
	bsr	SliPour
	move.w	d6,ttsl_hp1(a4)
	move.w	d7,ttsl_hp2(a4)
	rts

******* Activation de l'ecran de texte
Ttt_Act	moveq	#EcTut2,d1
	bra	TtEcAct

******* Effacement (intelligent) du fond texte
Ttt_Cls	
* Efface les fenetres
	WiCalD	WinDel,1
	WiCalD	WinDel,2

	moveq	#8,d3
	move.w	TttTlh(a4),d7
	beq.s	.skip1
* Fond du haut...
	moveq	#Ttt_pic+1,d0
	moveq	#0,d1
	moveq	#8,d2
	moveq	#-1,d3
	bsr	TtUPack
	moveq	#16,d3
	subq.w	#1,d7
	beq.s	.skip1
	move.l	T_EcAdr+EcTut2*4(a5),a0
	move.l	a0,a1
	moveq	#0,d0
	moveq	#8,d1
	moveq	#0,d2
	move.w	#640,d4
	moveq	#16,d5
.loop1	bsr	TtScc
	addq.w	#8,d3
	subq.w	#1,d7
	bne.s	.loop1
* Ligne de séparation
.skip1	moveq	#Ttt_pic+2,d0
	moveq	#0,d1
	move.l	d3,d2
	moveq	#-1,d3
	bsr	TtUPack
* Fond du bas
	move.w	Ttt_Tlb(a4),d7
	beq.s	.skip2
	moveq	#Ttt_pic+3,d0
	moveq	#0,d1
	addq.l	#8,d2
	moveq	#-1,d3
	bsr	TtUPack
	subq.w	#1,d7
	beq.s	.skip2
	move.l	T_EcAdr+EcTut2*4(a5),a0
	move.l	a0,a1
	moveq	#0,d0
	move.w	d2,d1
	move.w	#640,d4
	move.w	d2,d5
	addq.w	#8,d5
	moveq	#0,d2
	move.w	d5,d3
.loop2	bsr	TtScc
	addq.w	#8,d3
	subq.w	#1,d7
	bne.s	.loop2
.skip2
* Zone du haut
	SyCalD	RazZone,1
	moveq	#16,d2
	move.w	#8,d3
	move.w	#640-16,d4
	move.w	TttTlh(a4),d5
	lsl.w	#3,d5
	addq.w	#8,d5
	move.w	d5,d7
	SyCalD	SetZone,1
* Zone du milieu
	moveq	#16,d2
	move.w	d7,d3
	move.w	#640-16,d4
	addq.w	#8,d7
	move.w	d7,d5
	SyCalD	SetZone,2
	move.w	d7,Inf_sly(a4)
* Zone du bas
	SyCalD	RazZone,3
	moveq	#16,d2
	move.w	d7,d3
	move.w	#640-16,d4
	move.w	Tttty(a4),d5
	subq.w	#8,d5
	SyCalD	SetZone,3
* Zones slider haut
	moveq	#ttsl_hx,d2
	moveq	#ttsl_hy,d3
	move.w	#ttsl_hx+ttsl_htx,d4
	moveq	#ttsl_hy+ttsl_hty,d5
	SyCalD	SetZone,4
	move.w	#ttsl_hx+ttsl_htx+6,d2
	moveq	#ttsl_hy,d3
	move.w	#ttsl_hx+ttsl_htx+12,d4
	moveq	#ttsl_hy+ttsl_hty,d5
	SyCalD	SetZone,5
* Zones sliders
	move.w	#ttsl_vx,d2
	moveq	#ttsl_vy,d3
	move.w	#Ttsl_vx+Ttsl_vtx,d4
	move.w	Ttttlh(a4),d5
	lsl.w	#3,d5
	add.w	d3,d5
	SyCalD	SetZone,6
	move.w	#Inf_slx,d2
	move.w	Inf_sly(a4),d3
	move.w	#Inf_slx+Inf_sltx,d4
	move.w	Ttt_tlb(a4),d5
	lsl.w	#3,d5
	add.w	d3,d5
	SyCalD	SetZone,7
* Ouvre les fenetres
	moveq	#16,d2
	moveq	#8,d3
	moveq	#76,d4
	move.w	Ttttlh(a4),d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCalD	WindOp,1
	WiCalA	Print,Ttt_WInit(pc)
	moveq	#16,d2
	move.w	Ttttlh(a4),d3
	addq.w	#2,d3
	lsl.w	#3,d3
	moveq	#76,d4
	move.w	Ttt_tlb(a4),d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCalD	WindOp,2
	WiCalA	Print,Ttt_WInit(pc)
	rts

******* Imprime la ligne du buffer D1
TtEALigne
	movem.l	d0-d4/a0-a3,-(sp)	* Efface
	bset	#30,d1
	bra.s	ttaa
TtALigne
	movem.l	d0-d4/a0-a3,-(sp)	* Affiche seulement
	bclr	#30,d1
ttaa
* Locate en debut de ligne
	move.l	d1,-(sp)
	move.w	d1,d2
	move.w	d1,d3
	add.w	EdYPos(a5),d3
	moveq	#0,d1
	ext.l	d2
	WiCall	Locate

* Pointe la ligne dans le buffer
	move.w	2(sp),d0
	lsl.w	#8,d0
	move.l	EdBufE(a5),a0
	lea	0(a0,d0.w),a0
	move.w	EdXPos(a5),d1
	move.w	(a0)+,d0		Longueur de la ligne
	cmp.w	d0,d1
	bcc	.skipX
	lea	0(a0,d1.w),a1		Pointe le debut
	add.w	#76,d1
	move.w	d1,d2
	cmp.w	d0,d1
	bls.s	.skip1
	move.w	d0,d1
.skip1	cmp.w	d0,d2
	bhi.s	.skip2
	bclr	#6,(sp)
.skip2	lea	0(a0,d1.w),a2		Marque la fin de la ligne
	move.b	(a2),d2
	clr.b	(a2)

* Dessiner une marque dans la ligne???
	cmp.w	TtYNext(a4),d3
	beq.s	.Mark
	cmp.w	TtYInfo(a4),d3
	beq.s	.Mark
	cmp.w	TtYMark(a4),d3
	bne	.SkipM
	
.Mark	movem.l	a2/d2,-(sp)
	move.l	Buffer(a5),a0	
	move.w	EdXPos(a5),d2
.LoopM	cmp.w	TtYNext(a4),d3
	bne.s	.skipM1
	cmp.w	TtXNext(a4),d2
	bne.s	.skipM1
	lea	Ttt_Mark(pc),a2		Met le >>>
.loopM1	move.b	(a2)+,(a0)+
	bne.s	.loopM1
	subq.l	#1,a0
.skipM1	cmp.w	TtYMark(a4),d3
	bne.s	.skipM3
	cmp.w	TtX1Mark(a4),d2
	bne.s	.skipM2
	lea	Ttt_IOn(pc),a2		Passe en inverse
.loopM2	move.b	(a2)+,(a0)+
	bne.s	.loopM2
	subq.l	#1,a0
	bset	#7,8(sp)
.skipM2	cmp.w	TtX2Mark(a4),d2
	bne.s	.skipM3
	lea	Ttt_IOff(pc),a2		Retour en normal
.loopM3	move.b	(a2)+,(a0)+
	bne.s	.loopM3
	subq.l	#1,a0
.skipM3	
	cmp.w	TtYInfo(a4),d3
	bne.s	.skipM5
	cmp.w	TtX1Info(a4),d2
	bne.s	.skipM4
	lea	Ttt_InOn(pc),a2		Souligne
.loopM4	move.b	(a2)+,(a0)+
	bne.s	.loopM4
	subq.l	#1,a0
	bset	#7,8(sp)
.skipM4	cmp.w	TtX2Info(a4),d2
	bne.s	.skipM5
	lea	Ttt_InOff(pc),a2	Retour en normal
.loopM5	move.b	(a2)+,(a0)+
	bne.s	.loopM5
	subq.l	#1,a0
.skipM5	
	addq.w	#1,d2
	move.b	(a1)+,(a0)+
	bne.s	.LoopM
	move.l	Buffer(a5),a1
	movem.l	(sp)+,a2/d2
.skipM
* Impression
	WiCall	Print			Imprime
	move.b	d2,(a2)			Restore la ligne

* Repasse en normal
.skipX	move.l	(sp)+,d2
	bpl.s	.skip8
	WiCalA	Print,Ttt_IOff(pc)
	WiCalA	Print,Ttt_InOff(pc)
* Efface ---> fin ligne
.skip8	btst	#30,d2
	beq.s	.skip9
	WiCalD	ChrOut,7
.skip9
	movem.l	(sp)+,d0-d4/a0-a3
	rts


*********************************************************************
*
* 	Actualisation de la fenetre sur le programme
*
View_Aff
	movem.l	a0-a6/d0-d7,-(sp)

******* Trouve l'ecran actuel
	move.w	TtView(a4),d1
	bmi	.closed

* L'ecran est-il encore ouvert?
.Again	lea	T_EcAdr(a5),a0
	lsl.w	#2,d1
	move.l	0(a0,d1.w),d0
	beq	.closed
	move.l	d0,a2
	cmp.l	TtViewAD(a4),a2
	bne.s	.new
	move.w	EcTx(a2),d0
	cmp.w	TtViewTX(a4),d0
	bne.s	.new
	move.w	EcTy(a2),d0
	cmp.w	TtViewTY(a4),d0
	bne.s	.new
	move.w	EcNPlan(a2),d0
	cmp.w	TtViewNP(a4),d0
	beq.s	.old
* Nouvel ecran!
.new	bsr	View_Cls

******* Ok, fait la copie
.old	move.w	EcTX(a2),TtViewTX(a4)
	move.w	EcTY(a2),TtViewTY(a4)
	move.w	EcNPlan(a2),TtViewNP(a4)
	move.l	a2,TtViewAD(a4)
	
* Prend la position du scrolling
	SyCall	WaitVbl
	bsr	View_ScAD
	move.w	(a0),d0
	move.w	2(a0),d1
	
	tst.w	EcCon0(a2)
	bmi	.OHi
* Origine LOWRES : veritable reduce, ultra rapide (he he!)
	move.l	a2,a0
	move.l	T_EcAdr+EcTut1*4(a5),a1
	move.l	a0,SccEcO(a5)
	move.l	a1,SccEcD(a5)
	move.w	#RedX,d2
	move.w	#RedY,d3
	move.w	#RedTX,d4
	add.w	d0,d4
	move.w	#RedTY,d5
	add.w	d1,d5
	move.w	#$CC,d6
	move.w	EcTy(a0),-(sp)
	move.w	EcTLigne(a0),-(sp)
	move.l	a0,-(sp)
	move.w	EcTy(a0),d7
	lsr.w	#1,d7
	move.w	d7,EcTy(a0)
	move.w	EcTLigne(a0),d7
	lsl.w	#1,d7
	move.w	d7,EcTLigne(a0)
	jsr	Sco0
	move.l	(sp)+,a0
	move.w	(sp)+,EcTLigne(a0)
	move.w	(sp)+,EcTy(a0)
	jsr	Recop
	bra	TtRx
* Origine HIRES : simple recopie
.OHi	move.l	a2,a0
	move.l	T_EcAdr+EcTut1*4(a5),a1
	move.l	a0,SccEcO(a5)
	move.l	a1,SccEcD(a5)
	move.w	#RedX,d2
	move.w	#RedY,d3
	move.w	#RedTX,d4
	add.w	d0,d4
	move.w	#RedTY,d5
	add.w	d1,d5
	move.w	#$CC,d6
	jsr	Sco0
	jsr	Recop
	bra.s	TtRx
* Plus d'ecran. Trouve un nouveau ou sort...
.closed	bsr	View_GEc
	move.w	TtView(a4),d1
	bpl	.Again
	bsr	View_Cls
	clr.l	TtViewAd(a4)
* Sortie
TtRx	movem.l	(sp)+,a0-a6/d0-d7
	rts

******* Trouve le prochain ecran ouvert
View_GEc	
	move.w	TtView(a4),d1
View_Ec
	moveq	#7,d0
.loop	addq.w	#1,d1
	cmp.w	#8,d1
	bcs.s	.skip
	moveq	#0,d1
.skip	move.w	d1,d2
	lsl.w	#2,d2
	lea	T_EcAdr(a5),a0
	tst.l	0(a0,d2.w)
	bne.s	.skip1
	dbra	d0,.loop
	moveq	#-1,d1
.skip1	move.w	d1,TtView(a4)
	bsr	View_Info
	rts
******* Trouve l'adresse des positions de scrolling. 
*	D1->	A0
View_ScAd
	move.w	TtView(a4),d0
	bmi.s	.no
	lsl.w	#3,d0
	lea	ViewScrols(a4),a0
	add.w	d0,a0
	moveq	#0,d0
	rts
.no	moveq	#-1,d0
	rts
******* Clacule la table lors d'init!
View_ScUpdate
	movem.l	a0-a2/d0-d1,-(sp)
	lea	T_EcAdr(a5),a2
	lea	ViewScrols(a4),a1
	moveq	#7,d1
.loop	clr.l	(a1)
	tst.l	(a2)
	beq.s	.skip
	move.l	(a2),a0
	move.w	EcTx(a0),4(a1)
	move.w	EcTy(a0),d0
	tst.w	EcCon0(a0)
	bmi.s	.sk
	lsr.w	#1,d0
.sk	move.w	d0,6(a1)
.skip	addq.l	#4,a2
	dbra	d1,.loop
	movem.l	(sp)+,a0-a2/d0-d1
	rts
	
******* Routine d'interruption, recopie la palette...
View_Inter
	move.l	Tt_Base(a5),a0
	move.w	TtView(a0),d2	
	bmi.s	.skip
	lsl.w	#2,d2
	lea	T_EcAdr(a5),a0
	move.l	0(a0,d2.w),d0
	beq.s	.skip
	move.l	d0,a2
	lea	EcPal(a2),a2
	move.l	EcTut1*4(a0),a1
	lea	EcPal(a1),a1
	move.l	T_Copmark+EcTut1*128(a5),d0
	beq.s	.skip
	move.l	d0,a0
	addq.l	#2,a0
	moveq	#11-1,d0
.loop	move.w	(a2),(a0)
	addq.l	#4,a0
	move.w	(a2)+,(a1)+
	dbra	d0,.loop
.skip	rts

******* Activation de l'ecran des touches
View_Act
	moveq	#EcTut1,d1
TtEcAct	cmp.w	TtEcran(a4),d1
	beq.s	.skip
	move.w	d1,TtEcran(a4)
	EcCall	Active
.skip	rts

******* CLS de l'écran de zoom
View_Cls
	movem.l	d0-d5/a0-a1,-(sp)
	moveq	#0,d1	
	move.w	#RedX,d2
	move.w	#RedY,d3
	move.w	d2,d4
	move.w	d3,d5
	add.w	#RedTX,d4
	add.w	#RedTY,d5
	EcCall	ClsEc
	movem.l	(sp)+,d0-d5/a0-a1
	rts

******* Affiche la position de l'ecran
View_Info
	tst.w	TtView(a4)
	bpl.s	.Ok
	lea	Info_ViewOff(pc),a0
	bra.s	.Skip
.Ok	lea	Info_View(pc),a0
	bsr	TtText
	move.l	Buffer(a5),a0
	move.l	#$20202020,(a0)
	clr.l	4(a0)
	move.w	TtView(a4),d0
	ext.l	d0
	jsr	LongDec
	lea	Info_Buf(pc),a0
.Skip	bsr	TtText
	rts

******* PRINT TEXT A0
TtText	movem.l	a0-a2/d0-d2,-(sp)
	move.l	T_Rastport(a5),a1
	move.w	(a0)+,d0
	bmi.s	.skip1
	move.w	d0,36(a1)
.skip1	move.w	(a0)+,d0
	bmi.s	.skip2
	move.w	d0,38(a1)
.skip2	move.b	(a0)+,d0
	bmi.s	.skip3	
	ext.w	d0
	GfxCA5	SetBPen
.skip3	move.b	(a0)+,d0
	bmi.s	.skip4
	ext.w	d0
	GfxCA5	SetAPen
.skip4	move.w	(a0)+,d0
	bmi.s	.skop5
	ext.l	d0
	GfxCA5	SetDrMd
.skop5	move.l	a0,a2
	moveq	#-1,d0
.loop	addq.w	#1,d0
	tst.b	(a2)+
	bne.s	.loop
	tst.w	d0
	bne.s	.skip5
	move.l	Buffer(a5),a0
	bra.s	.skop5
.skip5	ext.l	d0
	movem.l	a0/d0,-(sp)
	GfxCA5	Text
	movem.l	(sp)+,a0/d0
	GfxCA5	TextLength
	subq.w	#8,d0
	add.w	d0,36(a1)
	movem.l	(sp)+,a0-a2/d0-d2
	rts

*********************************************************************
*
*	Gestion des boutons du menu
*
******* Impression de tous les boutons
ABoutons
	moveq	#NBoutons,d0
	moveq	#0,d1
.loop	bsr	ABouton
	subq.w	#1,d0
	bne.s	.loop
	rts
******* Impression du bouton D0, active: D1
ABouton	movem.l	a0/d2-d3,-(sp)
	move.l	#BtX,d2
	moveq	#BtY,d3
	lea	Tt_Boutons(pc),a0
	lea	Tt_Pics(pc),a1
	bsr	Aff_Bouton
	movem.l	(sp)+,a0/d2-d3
	rts

******* Bouton général
*	A0=table
*	A1= images
*	D0= numero
*	D1= on/off
*	D2= offset x
*	D3= offset y
Aff_Bouton
	movem.l	a0-a1/d0-d5,-(sp)
	move.w	d2,d4
	move.w	d3,d5
	mulu	#18,d0
	lea	-18+4(a0,d0.w),a0
	move.w	-4(a0),d0
	tst.w	d1
	beq.s	.skip
	move.w	-2(a0),d0
.skip	move.w	(a0)+,d1
	bclr	#0,d1
	bne.s	.sku
	add.w	d2,d1
.sku	ext.l	d1
	move.w	(a0)+,d2
	bclr	#0,d2
	bne.s	.sko
	add.w	d3,d2
.sko	ext.l	d2
	move.l	a0,-(sp)
	moveq	#-1,d3
	tst.w	d0
	beq.s	.ski
	move.l	a1,a0
	bsr	UPack
.ski
* Fixe la zone D0
	move.w	d2,d3
	move.w	d1,d2
	move.l	(sp)+,a0
	move.w	(a0)+,d1
	beq.s	.slip
	move.w	(a0)+,d0
	bclr	#0,d0
	beq.s	.sl
	move.w	d4,d2
.sl	add.w	d0,d2
	move.w	(a0)+,d0
	bclr	#0,d0
	beq.s	.sm
	move.w	d5,d3
.sm	add.w	d0,d3
	move.w	(a0)+,d0
	bclr	#0,d0
	bne.s	.sn
	move.w	d2,d4
.sn	add.w	d0,d4
	move.w	(a0)+,d0
	bclr	#0,d0
	bne.s	.so
	move.w	d3,d5
.so	add.w	d0,d5
	Sycall	SetZone
.slip
* Fini!
	movem.l	(sp)+,a0-a1/d0-d5
	rts

	
*******************************************************************
*
*	Routine, UNPACK une image contenue dans la banque
*
*	A0	Adresse banque d'images
*	D0	Numero de l'image
*	D1	X (-1 si non)
*	D2	Y
*	D3	Numero de l'écran, si SPACK, -1 sinon
UPack	movem.l	a0-a3/d0-d7,-(sp)
	bra.s	Ttu1
TtUPack
	movem.l	a0-a3/d0-d7,-(sp)
	lea	Tt_Pics(pc),a0
Ttu1
	lsl.w	#1,d0
	move.w	-2(a0,d0.w),d0
	add.w	d0,a0
	ext.l	d1
	ext.l	d2
	move.l	Buffer(a5),a3
	lea	16(a3),a3
	tst.w	d3
	bpl.s	.skip
* UNPACK N,X,Y
	move.l	a0,-(a3)
	move.l	d1,-(a3)
	move.l	d2,-(a3)
	moveq	#7-1,d0
	bsr	Pacad
	move.l	T_EcCourant(a5),a1
	jsr	10(a0)
	bra.s	TtpX
* UNPACK N TO N
.skip	move.l	ScOnAd(a5),-(sp)
	move.w	ScOn(a5),-(sp)
	move.l	a0,-(a3)
	move.l	d3,d1
	moveq	#6-1,d0
	bsr	Pacad
	jsr	12(a0)
	move.w	(sp)+,ScOn(a5)
	move.l	(sp)+,ScOnAd(a5)
* Fini!
Ttpx	movem.l	(sp)+,d0-d7/a0-a3
	rts
* Trouve l'adresse d'une intruction PACK
Pacad	move.l	AdTokens+8(a5),a0
	move.l	a0,a1
.loop	cmp.w	#-1,(a1)+
	bne.s	.loop
	dbra	d0,.loop
	add.w	-4(a1),a0
	rts

******* SCREEN COPY
TtScc	movem.l	d0-d7/a0-a4,-(sp)
	move.l	a0,SccEcO(a5)
	move.l	a1,SccEcD(a5)
	move.w	#$CC,d6
	jsr	Sco0
	movem.l	(sp)+,d0-d7/a0-a4
	rts

******* Attente souris
Wmky	sycall	Mousekey
	btst	#0,d1
	bne.s	Wmky
	rts

******* XY Mouse dans l'ecran courant
XYMouEc	SyCall	XYMou
	moveq	#0,d3
	SyCall	XYScr
	rts

******* Calcule les pourcentages
SliPour	moveq	#0,d6
	move.w	d0,d7
	cmp.w	d3,d5
	bcs.s	Poub
	tst.w	d3
	bne.s	Poua
	moveq	#1,d3
Poua:	move.w	d3,d5
Poub:	move.w	d0,d1		* Calculs *65536
	swap	d0
	clr.w	d0
	divu	d3,d0
	bvs.s	Pou1
	mulu	d0,d4
	swap	d4
	mulu	d5,d0
	swap	d0
	bra.s	Pou3
Pou1:	moveq	#0,d0		* Calculs *256
	move.w	d1,d0
	lsl.l	#8,d0
	divu	d3,d0
	bvs.s	Pou2
	mulu	d0,d4
	lsr.l	#8,d4
	mulu	d5,d0
	lsr.l	#8,d0
	bra.s	Pou3
Pou2:	moveq	#0,d0		* Calculs normaux
	move.w	d1,d0
	divu	d3,d0
	mulu	d0,d4
	mulu	d5,d0
Pou3:	cmp.w	#8,d0		* Ty >= 8
	bcc.s	SlPo1
	moveq	#8,d0
SlPo1:	move.w	d4,d6
	cmp.w	d1,d6		* Sort en bas?
	bcs.s	SlPo3
	move.w	d1,d6
	sub.w	d0,d6
SlPo3:	move.w	d6,d7		* Fin du slider
	add.w	d0,d7
	cmp.w	d1,d7		* Sort en bas?
	bls.s	SlPoF
	move.w	d1,d6
	move.w	d1,d7
	sub.w	d0,d6
SlPoF:	rts

*************** Donnees tutor
		Even
* Ancien vecteur ECRANS
Old_EcVect	dc.l	0
Old_SyVect	dc.l	0
* Definition des bouttons
* X,Y unpack / X,Y,TX,TY zones
Tt_Boutons	
		dc.w	7,22,0*48,2*24,1,0,0,48,24
		dc.w	8,23,1*48,+2*24,2,0,0,48,24
		dc.w	9,24,2*48,2*24,3,0,0,48,24
		dc.w	10,25,3*48,2*24,4,0,0,48,24
		dc.w	11,26,4*48,2*24,5,0,0,48,24

		dc.w	2,13,0*48,0*24,6,32,0,32,16
		dc.w	2,14,0*48,0*24,7,32,32,32,16
		dc.w	2,15,0*48,0*24,8,0,16,32,16
		dc.w	2,16,0*48,0*24,9,64,16,32,16
		dc.w	2,17,0*48,0*24,10,32,16,32,16

		dc.w	3,18,2*48,0*24,11,0,0,96,24
		dc.w	5,20,4*48,0*24,12,0,0,48,24
		dc.w	0,0,0+1,0+1,13,16,8,320,100

		dc.w	12,27,2*48,1*24,14,0,0,48,24
		dc.w	4,19,3*48,1*24,15,0,0,48,24
		dc.w	6,21,4*48,1*24,16,0,0,48,24

* Table d'acceleration des deplacements
Tablacc		dc.b	1,2,4,8

* Info ecran
Info_View	dc.w	134,6,$0D0E,%001
		dc.b	"Screen # ",0
Info_Buf	dc.w	134+8*9-3,6,$0D0E,%001
		dc.b	0
Info_ViewOff	dc.w	126,6,$0D0E,%001
		dc.b	" No screens ",0

* Textes fenetre listing
Ttt_WInit	dc.b	27,"C0",27,"B3",27,"P2",27,"V0",0
Ttt_scrup	dc.b	27,"Y0",22,0
Ttt_scrdown	dc.b	12,20,0
Ttt_IOn		dc.b	27,"I1",0
Ttt_IOff	dc.b	27,"I0",0
Ttt_InOn	dc.b	27,"U1",0
Ttt_InOff	dc.b	27,"U0",0
Ttt_Mark	dc.b	27,"B0",27,"P1>>>",27,"B3",27,"P2",0

* Textes fenetre info
Inf_Shade	dc.b	27,"S1",0
Inf_ShadOff	dc.b	27,"S0",0
Inf_NextI	dc.b	"* Next instruction: ",0
Inf_PLock	dc.b 	"* Next instruction in folded ",0
Inf_Par1	dc.b	"  Param #",0
Inf_Par2	dc.b	" = ",0
Inf_ParE	dc.b	"Error"
Inf_Separ	dc.b	" ",0
Inf_Proc	dc.b	"Cannot evaluate expression: not at the same level of procedure.",0
Inf_NoQuit	dc.b	"BREAK OFF mode: you must end the program before quitting the tutor.",0
Inf_Err		dc.b	"Cannot evaluate expression.",0
Inf_2Many	dc.b	"Too many expressions.",0
Inf_Break	dc.b	"Breakpoint reached.",0
Inf_NoInit	dc.b	"Program not initialised.",0
Inf_Test	dc.b	"Testing program.",0
Inf_Mark	dc.b	">>> ",0
Inf_Nul		dc.b	"Default value.",0
Inf_Ommit	dc.b	"Ommited.",0

* Fichiers HELP
Hlp_Nom		dc.b	"Easy_AMOS:EasyAMOS.Help",0
Hlp_NomMap	dc.b	"Easy_AMOS:EasyAMOS.Map",0
Hlp_Sep		dcb.b	75,137
		dc.b	0
Hlp_Loadmap	dc.b	"Loading EasyAMOS.Map file...",0
Hlp_Found	dc.b	"Help found.",0
Hlp_About	dc.b	"Help keyword: ",0
Hlp_NFound	dc.b	"Sorry, help not found! ",0
Hlp_DErr	dc.b	"Cannot load Easy-AMOS help files.",0
Hlp_WInit	dc.b	27,"C0",27,"B3",27,"P2",27,"V0",0
* Image de fond HAUT
		Even
Tt_Pics		INCBIN	"Tutor1.Bin"
		Even	
