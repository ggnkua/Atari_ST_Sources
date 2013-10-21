***************************************************************
*                                                             *
*        Gestion de m‚moire virtuelle pour DOOM Falcon        *
*                         version 0.4                         *
*                  Par Xavier Joubert (Xaz)                   *
*                                                             *
***************************************************************
*
* Il y a eu de NOMBREUX changements depuis la version 0.1.
*      ***************************************
* Donc * PRIERE DE LIRE ATTENTIVEMENT LA DOC *. Merci.
*      ***************************************
*
*


******************************************************************
*
* La variable … mettre … 0 pour utiliser les fonctions
*

XAZTEST	EQU	0


******************************************************************
*
* Les constantes publiques (… utiliser plut“t que leurs valeurs)
*

; Les codes de retour des fonctions
XAZ_OK	EQU	0	Tout c'est bien d‚roul‚
XAZ_ERR_MEM	EQU	(-1)	Pas assez de m‚moire dispo
XAZ_ERR_FICH	EQU	(-2)	Erreur d'accŠs … un fichier
XAZ_ERR_ADR	EQU	(-3)	Pas de zone d'adressage libre
XAZ_ERR_NOTFICH	EQU	(-4)	L'adr donn‚e n'est pas celle d'1 fichier
XAZ_ERR_NOTBLOC	EQU	(-5)	L'adr donn‚e n'est pas celle d'1 bloc allou‚
XAZ_ERR_INVMODE	EQU	(-6)	Le mode pass‚ n'est pas valide
XAZ_ERR_GROWTH	EQU	(-7)	Agrandissement de bloc impossible
XAZ_ERR_LEN	EQU	(-8)	Blocs de longueur 0 interdits (et inutiles)
XAZ_ERR_ON	EQU	(-9)	La gestion de m‚moire est d‚j… install‚e
XAZ_ERR_OFF	EQU	(-10)	La gestion de m‚moire n'est pas install‚e
XAZ_ERR_PROC	EQU	(-11)	Processeur non support‚
XAZ_ERR_MMU	EQU	(-12)	Pas de MMU sur ce systŠme ou MMU d‚j… utilis‚e

; La constante permettant de tester les retours
; cf. la description des fonctions pour + de d‚tails
XAZ_ERR_MAX	EQU	(-12)

; Les modes pour XazMxalloc()
XAZ_STRAM	EQU	0	ST Ram uniquement
XAZ_TTRAM	EQU	1	TT Ram uniquement
XAZ_PREFSTRAM	EQU	2	ST Ram de pr‚f‚rence
XAZ_PREFTTRAM	EQU	3	TT Ram de pr‚f‚rence

; Les modes pour XazFopen()
XAZ_READONLY	EQU	0	Lecture uniquement
XAZ_WRITEONLY	EQU	1	Ecriture uniquement
XAZ_READWRITE	EQU	2	Lecture/‚criture


******************************************************************
*
* Quelques d‚finitions internes
*

XAZ_ID	EQU	"DOOM"	Identificateur du programme
XAZ_FICHIDENT	EQU	$ffffffff	Permet de trouver le debut fichier

XAZ_UNUSED	EQU	(-2*1024*1024*1024)	Indique une page libre
XAZ_FIN_INFOS	EQU	(-2*1024*1024*1024+1)	Indique la fin des infos

XAZ_BIT_U_F	EQU	30	bit … 0 pr UNUSED et FIN_INFOS

XAZ_MAXNOTE	EQU	(-1)	Note maximum d'une page
XAZ_MINNOTE	EQU	20	Note minimum d'une page
XAZ_NOTEM	EQU	(XAZ_MINNOTE-1)	A - … la note d'1 pg modifi‚e

XAZ_BIT_TTRAM	EQU	30

XAZ_PAGE_C	EQU	(8*1024)	Taille d'une page de niveau C
XAZ_PAGE_B	EQU	(256*1024)	Taille d'une page de niveau B
XAZ_PAGE_A	EQU	(32*1024*1024)	Taille d'une page de niveau A

XAZ_MUL_PAGE_C	EQU	13	Pr multiplier par taille XAZ_PAGE_C
XAZ_MUL_PAGE_B	EQU	18	Pr multiplier par taille XAZ_PAGE_B
XAZ_MUL_PAGE_A	EQU	25	Pr multiplier par taille XAZ_PAGE_A

XAZ_MASK_PAGE_C	EQU	$1fff	Pr aligner sur une page de niveau C

XAZ_LST_REG	REG	d1-d7/a0-6
XAZ_1ST_PARAM	EQU	(4+4*14)	1er param (4 pour bsr, reste = regs)

XAZ_LST_REG2	REG	d0-d7/a0-6	Pr l'erreur de bus
XAZ_STACK_FRAME	EQU	(15*4)	D‚but des infos

	RSRESET		Les infos des fichiers
XazFichIdent	rs.l	1	Pour trouver le d‚but
XazFichMode	rs.w	1	Mode de XazFopen()
XazFichHandle	rs.w	1	Le handle du fichier
XazFichNbPgB	rs.w	1	le nbre de pages du niveau B
XazFichNbPgC	rs.l	1	le nbre de pages du niveau C
	RSSET	((__RS-1)!(%1111))+1	On s'aligne sur 16 octets
XazFichNivC	rs.l	1	Elle tue la ligne au dessus, hein !

XazSuperOn	MACRO
	movem.l	d0-d1/a0-a1,-(sp)
	SUPER	#0
	move.l	d0,Xaz_pile
	movem.l	(sp)+,d0-d1/a0-a1
	ENDM
	
XazSuperOff	MACRO
	movem.l	d0-d1/a0-a1,-(sp)
	SUPER	Xaz_pile
	movem.l	(sp)+,d0-d1/a0-a1
	ENDM

XazOn	MACRO	
	XazSuperOn
	jsr	XazOn_old
	XazSuperOff
	ENDM

XazOff	MACRO	
	XazSuperOn
	jsr	XazOff_old
	XazSuperOff
	ENDM

XazFopen	MACRO	fname,mode
	XazSuperOn
	move	\2,-(sp)
	move.l	\1,-(sp)
	jsr	XazFopen_old
	addq.l	#6,sp
	XazSuperOff
	ENDM

XazFclose	MACRO	adr
	XazSuperOn
	move.l	\1,-(sp)
	jsr	XazFclose_old
	addq.l	#4,sp
	XazSuperOff
	ENDM

XazMxalloc	MACRO	amount,mode
	XazSuperOn
	move	\2,-(sp)
	move.l	\1,-(sp)
	jsr	XazMxalloc_old
	addq.l	#6,sp
	XazSuperOff
	ENDM

XazMfree	MACRO	adr
	XazSuperOn
	move.l	\1,-(sp)
	jsr	XazMfree_old
	addq.l	#4,sp
	XazSuperOff
	ENDM

XazMshrink	MACRO	startadr,newsize
	XazSuperOn
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	jsr	XazMshrink_old
	addq.l	#8,sp
	XazSuperOff
	ENDM

SupXazFopen	MACRO	fname,mode
	move	\2,-(sp)
	move.l	\1,-(sp)
	jsr	XazFopen_old
	addq.l	#6,sp
	ENDM

SupXazFclose	MACRO	adr
	move.l	\1,-(sp)
	jsr	XazFclose_old
	addq.l	#4,sp
	ENDM

SupXazMxalloc	MACRO	amount,mode
	move	\2,-(sp)
	move.l	\1,-(sp)
	jsr	XazMxalloc_old
	addq.l	#6,sp
	ENDM

SupXazMfree	MACRO	adr
	move.l	\1,-(sp)
	jsr	XazMfree_old
	addq.l	#4,sp
	ENDM
	
	BSS
	
Xaz_pile	ds.l	1

	DATA

******************************************************************
*
* Routine d'installation de la gestion de mem virtuelle
*

XazOn_old	movem.l	XAZ_LST_REG,-(sp)

*** Verification du flag ***
XazVerifFlagOn
	moveq.l	#XAZ_ERR_ON,d0
	tst.w	XazFlagOn
	bne.w	FinXazOn

*** Verification du processeur ***
XazVerifProc
	moveq.l	#XAZ_ERR_PROC,d0
	move.l	$5a0.w,d1
	beq.w	FinXazOn

	subq.l	#4,d1
	move.l	d1,a0
XazBcleVerifProc
	addq.l	#4,a0
	move.l	(a0)+,d2
	beq.w	FinXazOn
	cmp.l	#"_CPU",d2
	bne.s	XazBcleVerifProc

	move.l	(a0),d2
	cmp.l	#30,d2
	bne.w	FinXazOn
	move.l	d2,XazProc

*** Verification de la MMU ***
XazVerifMMU
	moveq.l	#XAZ_ERR_MMU,d0
	movea.l	d1,a0
XazBcleVerifMMU
	addq.l	#4,a0
	move.l	(a0)+,d2
	beq.s	XazInit
	cmp.l	#"PMMU",d2
	bne.s	XazBcleVerifMMU

	bra.w	FinXazOn

*** Quelques initialisations ***
XazInit
	clr.l	XazNbPgST
	clr.l	XazNbPgTT
	clr.l	XazSTRam
	clr.l	XazTTRam
	clr.l	XazAdrMalloc1
	clr.l	XazAdrMalloc2
	clr.l	d4
	clr.l	d5
	moveq.l	#XAZ_MUL_PAGE_C,d3 Pour diviser (et multiplier) par 8192

*** Quantit‚ de ST Ram dispo ***
XazSTRamDispo
	clr.w	-(sp)	Mode 0 : ST Ram only
	pea	-1.w	Demande de la taille du + gd bloc dispo
	move.w	#$44,-(sp)	Code fonction Mxalloc
	trap	#1	Appel au Gemdos
	addq.l	#8,sp	R‚alignement

	move.l	d0,d1
	cmp.l	#12*XAZ_PAGE_C,d0	12 pages minimum
	blo.s	XazTTRamDispo		Pas assez

*** Calcul du nombre de pages de ST Ram ***
XazCalcNbPgST
	lsr.l	d3,d0	On divise par 8192
	subq.l	#1,d0	On enlŠve une page (pour ˆtre s–r)
	move.l	d0,d4	Pour la verif.
	move.l	d0,XazNbPgST

*** Allocation de la ST Ram ***
XazMallocSTRam
	clr.w	-(sp)	Mode 0 : ST Ram only
	move.l	d1,-(sp)	Le plus gd bloc dispo
	move.w	#$44,-(sp)	Code fonction Mxalloc
	trap	#1	Appel au Gemdos
	addq.l	#8,sp	R‚alignement

	move.l	d0,XazAdrMalloc1	Adresse de d‚but de la ST Ram

	subq.l	#1,d0
	ori.w	#XAZ_MASK_PAGE_C,d0	Alignement
	addq.l	#1,d0
	move.l	d0,XazSTRam	On stocke le r‚sultat

*** Quantit‚ de TT Ram dispo ***
XazTTRamDispo
	move.w	#1,-(sp)	Mode 1 : TT Ram only
	pea	-1.w	Demande de la taille du + gd bloc dispo
	move.w	#$44,-(sp)	Code fonction Mxalloc
	trap	#1	Appel au Gemdos
	addq.l	#8,sp	R‚alignement

	move.l	d0,d1
	cmp.l	#12*XAZ_PAGE_C,d0	12 pages minimum
	blo.s	XazVerifRam		Pas assez

*** Calcul du nombre de pages de TT Ram ***
XazCalcNbPgTT
	lsr.l	d3,d0	On divise par 8192
	subq.l	#1,d0	On enlŠve une page (pour ˆtre s–r)
	move.l	d0,d5	Pour la verif.
	move.l	d0,XazNbPgTT

*** Allocation de la TT Ram ***
XazMallocTTRam
	move.w	#1,-(sp)	Mode 1 : TT Ram only
	move.l	d1,-(sp)	Le plus gd bloc dispo
	move.w	#$44,-(sp)	Code fonction Mxalloc
	trap	#1	Appel au Gemdos
	addq.l	#8,sp	R‚alignement

	move.l	d0,XazAdrMalloc2	Adresse de d‚but de la TT Ram

	subq.l	#1,d0
	ori.w	#XAZ_MASK_PAGE_C,d0	Alignement
	addq.l	#1,d0
	move.l	d0,XazTTRam	On stocke le r‚sultat

*** Verification de la Ram allou‚e ***
XazVerifRam
	moveq.l	#XAZ_ERR_MEM,d0
	move.l	d4,d1
	add.l	d5,d1	Nbre total de pages
	beq.w	FinXazOn
	move.l	d1,d0

*** Nombre de pages utilis‚es pour les infos des pages & l'arbre de MMU ***
XazCalcNbPg
	lsl.l	#3,d0	NbPg * 8 = Taille infos
	add.l	#(4*128*129)+16,d0	+ Taille de l'arbre + 16 = Total
	move.l	d0,a4	a4 : Taille du 1er malloc
	subq.l	#1,d0	
	lsr.l	d3,d0	d0 : nb de pages necessaires - 1

*** Choix de l'endroit o— mettre les infos des pages & l'arbre de MMU ***
XazChoixBloc
	cmp.l	d4,d5	Quel est le plus grand bloc ?
	blt.s	XazSTRamChoisie

XazTTRamChoisie
	movea.l	XazTTRam,a0
	lea	XazInfoPgTT(pc),a1
	lea	XazInfoPgST(pc),a2
	move.l	d5,d1	NbPgTT
	move.l	d4,d2	NbPgST
	bra.s	XazChercheAdresseLibre

XazSTRamChoisie
	movea.l	XazSTRam,a0
	lea	XazInfoPgST(pc),a1
	lea	XazInfoPgTT(pc),a2
	move.l	d4,d1	NbPgST
	move.l	d5,d2	NbPgTT

*** Recherche du d‚but de la zone d'adressage libre ***
XazChercheAdresseLibre
	move.l	#$1000000,d7	L'adresse par d‚faut
	cmpi.l	#$1357bd13,$5a8.w	Ramtop est-il valide ?
	bne.s	XazAdresseTrouvee	Non
	move.l	$5a4.w,d6	Ramtop
	cmp.l	d7,d6	Avant l'adresse standard ?
	bls.s	XazAdresseTrouvee	Oui
	move.l	d6,d7	Non
XazAdresseTrouvee
	subq.l	#1,d7
	moveq.l	#XAZ_MUL_PAGE_B,d6		
	lsr.l	d6,d7	No de la 1Šre page de 256ko libre
	subi.l	#64-1,d7	On enlŠve les 16 1ers m‚gs

*** Initialisation du nouvel arbre de MMU ***
XazInitMMU
	lea	XAZ_PAGE_C(a0),a0	On laisse une page libre (swap)
	move.l	a0,d6
	movea.l	a0,a3
	addi.l	#(4*128)+%10,d6 Adresse du niveau B+2 (descripteurs courts)
	move.w	#127,d5	128 pages au niveau A

XazBcleINA
	move.l	d6,(a0)+	Ecriture du pointeur
	addi.l	#(4*128),d6	On pointe sur la page suivante
	dbra	d5,XazBcleINA	Et c'est reparti pour un tour !

XazInitNivB			;Initialisation du niveau B de l'arbre
	move.l	a0,XazAdrNivB	On sauve pour plus tard

* 1Šre Partie : La ST RAM
	moveq.l	#1,d6	Descripteur court de fin pr‚coce
	moveq.l	#59,d5	Pour les 14 premiers Mo
XazBcleINB1
	move.l	d6,(a0)+	On ‚crit le descripteur
	addi.l	#XAZ_PAGE_B,d6	On passe aux 256 ko suivants
	dbra	d5,XazBcleINB1	Et on boucle !

* 2Šme partie : La zone d'entr‚e sortie (non cachable)
XazInitNivB2
	addi.l	#$40,d6	On met … 1 le bit CI (Cache Inhibit)
	moveq.l	#3,d5	Pour 2 Mo
XazBcleINB2
	move.l	d6,(a0)+	On ‚crit le descripteur
	addi.l	#XAZ_PAGE_B,d6	On passe aux 256 ko suivants
	dbra	d5,XazBcleINB2	Faites tourner, faites tourner !

* 3Šme partie : La TT Ram
XazInitNivB3
	subi.l	#$40,d6	On annule le bit CI
	tst.l	d7	Y-a-t-il des pages entre les deux ?
	beq.s	XazInitNivB4	Non => On passe tout de suite au reste
	subq.l	#1,d7	Pour le dbra
XazBcleINB3
	move.l	d6,(a0)+	On ‚crit le descripteur
	addi.l	#XAZ_PAGE_B,d6	On passe aux 256 ko suivants
	dbra	d7,XazBcleINB3	Par ici la monnaie !

* 4Šme partie : La zone libre
XazInitNivB4
	move.l	#$fe000001,d5	D‚but de la zone VME
	cmp.l	d5,d6	D‚j… fini ?
	beq.s	XazInitNivB5	On passe tout de suite … la zone VME
XazBcleINB4
	clr.l	(a0)+	On ‚crit le descripteur
	addi.l	#XAZ_PAGE_B,d6	On passe aux 256 ko suivants
	cmp.l	d5,d6
	bne.s	XazBcleINB4	Tournez manŠge !

* 5Šme partie : Le bus VME A24:D16
XazInitNivB5
	moveq.l	#(16*4)-1,d5	16 m‚gas
XazBcleINB5
	move.l	d6,(a0)+	On ‚crit le descripteur
	addi.l	#XAZ_PAGE_B,d6	On passe aux 256 ko suivants
	dbra	d5,XazBcleINB5	-C'est encore loin ? -Non, plus maintenant !

* 6Šme partie : l'ombre de la ST Ram
XazInitNivB6
	moveq.l	#1,d6	Voir partie 1
	moveq.l	#59,d5
XazBcleINB6
	move.l	d6,(a0)+
	addi.l	#XAZ_PAGE_B,d6
	dbra	d5,XazBcleINB6

* 7Šme partie : l'ombre de la zone d'entr‚e sortie
XazInitNivB7
	addi.l	#$40,d6	Voir partie 2
	moveq.l	#3,d5
XazBcleINB7
	move.l	d6,(a0)+
	addi.l	#XAZ_PAGE_B,d6
	dbra	d5,XazBcleINB7

*** Initialisation des infos des pages ***
XazInitInfoPg
	move.l	#XAZ_UNUSED,d3	Page pas encore utilis‚e
	moveq.l	#-2,d4	Bloc no 1 (NOT(1)=-2)
	moveq.l	#XAZ_MAXNOTE,d5
	move.l	#XAZ_FIN_INFOS,d6

XazIIP0
	move.l	a0,(a1)	Adresse des infos des pages

	move.l	d3,(a0)+	Page libre
	move.l	d5,(a0)+	Note maximale

	sub.l	d0,d1
XazBcleIIP1
	move.l	d4,(a0)+	Page d‚j… utilis‚e
	move.l	a4,(a0)+	Taille du bloc
	dbra	d0,XazBcleIIP1

	subq.l	#2,d1	Page libre + Nb page -1
XazBcleIIP2
	move.l	d3,(a0)+	Page libre
	move.l	d5,(a0)+	Note maximale
	subq.l	#1,d1
	bne.s	XazBcleIIP2

	move.l	d6,(a0)+

	move.l	a0,(a2)	Adr des autres infos
	addq.l	#1,d2	Pour la boucle
	bra.s	XazFinBcleIIP3
XazBcleIIP3
	move.l	d3,(a0)+	Page libre
	move.l	d5,(a0)+	Note maximale
XazFinBcleIIP3
	subq.l	#1,d2
	bne.s	XazBcleIIP3

	move.l	d6,(a0)+	Marque de fin de bloc
	move.l	d6,4(a0)	2Šme marque (Bug du Malloc si 0 pages)

*** Sauvegarde de la configuration MMU ***
XazSauvMMU
	lea	XazSavMMU(pc),a0
	pmove.l	tc,16(a0)	On sauve tc,...
	pmove.l	tt1,12(a0)	... tt1,...
	pmove.l	tt0,8(a0)	... tt0,...
	pmove.d	crp,(a0)	... et crp.

*** Remappage la MMU ***	Version pour 030 seulement !
XazChgMMU
	clr.l	-(sp)
	pmove.l	(sp),tc	On d‚sactive la MMU ...
	pmove.l	(sp),tt1	... et les translations transparentes.
	pmove.l	(sp),tt0
	move.l	a3,(sp)	Adresse de l'arbre de MMU
	pea	$80000002
	pmove.d	(sp),crp	On d‚clare notre arbre
	move.l	#%10000000110100000111011101010000,(sp)
	pmove.l	(sp),tc	Et c'est parti mon kiki !
	addq.l	#8,sp	R‚alignement

*** D‚viation du Gemdos ***
XazInstGemdos
	pea	XazGemdos(pc)	Adr de mon trap #1
	move.w	#$21,-(sp)	Vecteur $21 (Gemdos)
	move.w	#5,-(sp)	Code fonction setexc
	trap	#13	Appel du Bios
	addq.l	#8,sp	R‚alignement
	move.l	d0,XazAncGemdos	Stockage de l'ancien vecteur

*** Installation de la nouvelle routine d'erreur de bus ***
XazInstalle
	pea	XazErrBus(pc)	Adr de la routine superviseur
	move.w	#2,-(sp)	Vecteur nø2 (Erreur de bus)
	move.w	#5,-(sp)	Code fonction setexc
	trap	#13	Appel du Bios
	addq.l	#8,sp	R‚alignement
	move.l	d0,XazAncRout	Stockage de l'ancien vecteur

	clr.l	d0	0 :  tout s'est bien pass‚
	move.w	#-1,XazFlagOn
FinXazOn
	movem.l	(sp)+,XAZ_LST_REG
	rts		Ouf ! Enfin termin‚ !

******************************************************************
*
* La routine de gestion des erreurs de bus (le coeur du systŠme)
*

	even

XazEnTete
	dc.l	"XBRA"	En tˆte compatible norme XBRA
	dc.l	XAZ_ID	Identificateur du prog
XazAncRout
	dc.l	$ffffffff	Adresse de la routine dont on prend la place

XazErrBus
;	illegal

	movem.l	XAZ_LST_REG2,-(sp)	Hop, sauv‚s !
	lea	XAZ_STACK_FRAME(sp),a0
	lea	XazTableTesteFormat(pc),a1

XazTstFmt
	clr.l	d0
	move.b	6(a0),d0	Format de la pile
	lsr.b	#4,d0	Seulement 4 bits significatifs

	jmp	([a1,d0.w*4])


*** Stack frames non g‚r‚s ***
XazFmt4
XazFmt5
XazFmt6
XazFmtC
XazFmtD
XazFmtE
XazFmtF
	bra.w	XazFinPbl

XazFmt0			; 010 020 030 040
	move.l	2(a0),d0
	bra.s	XazTraitAdr

XazFmt1			;     020 030 040
	movec.l	msp,a0
	bra.s	XazTstFmt

XazFmt2			;     020 030 040
XazFmt3			;             040
XazFmt9			;     020 030
	move.l	8(a0),d0
	bra.s	XazTraitAdr

XazFmt7			;             040
	move.l	$14(a0),d0
	bra.s	XazTraitAdr

XazFmt8			; 010
	move.l	$a(a0),d0
	bra.s	XazTraitAdr

XazFmtA			;     020 030
XazFmtB			;     020 030
	move.l	$10(a0),d0

*** Verifier la validite de la demande ***
XazTraitAdr
	andi.l	#$ffffe000,d0	On aligne s/ 8ko
	movea.l	d0,a0
	ptestr	#0,(a0),#7,a1	On tente une lecture

	clr.w	-(sp)	On fait de la place sur la pile
	pmove.w	mmusr,(sp)	On regarde le mmusr
	move.w	(sp)+,d0	On r‚aligne

	btst.l	#10,d0	Descripteur invalide
	beq.w	XazFinPbl	Non -> On bombe

	btst.l	#0,d0	Nbre de niveaux = 2 ou 3 ?
	beq.w	XazFinPbl	2 -> On bombe

*** Liberer une page ***
XazDemandePgLibre
	bsr.w	XazLiberePage	d0 contient le no d'1 page libre

	btst.l	#XAZ_BIT_TTRAM,d0	Page en TT Ram ?
	bne.s	XazPageLibreTT

XazPageLibreST
	move.l	XazSTRam,d1
	movea.l	XazInfoPgST,a2
	bra.s	XazCalcPageLibre

XazPageLibreTT
	move.l	XazTTRam,d1
	movea.l	XazInfoPgTT,a2

XazCalcPageLibre
	lea	(a2,d0.l*8),a2	a2 : Infos de la page
	moveq.l	#XAZ_MUL_PAGE_C,d2
	lsl.l	d2,d0
	add.l	d0,d1	d1 : adr r‚elle de la page

XazMAJInfosPg
	move.l	a0,d3	d3 : adresse demand‚e
	lsr.l	d2,d3	d3 : no de la page demand‚e
	move.l	d3,(a2)+	On ‚crit les infos
	move.l	#XAZ_MINNOTE,(a2)	Note minimale

*** Remapper la MMU ***
XazRemapMMU
	pea	(a1)
	bsr.w	XazChercheHandleModeAdr
	addq.l	#4,sp

	move.l	d1,d2
	addq.l	#1,d2	Descripteur de page
	btst.l	#17,d0
	bne.s	XazRW
XazWP
	addq.l	#4,d2
XazRW
	move.l	d2,(a1)
	pflusha

*** Charger la nouvelle page ***
XazChargePage
	move.l	d1,-(sp)	Adresse r‚elle de la page
	pea	XAZ_PAGE_C.w	Taille de la page (8 ko)
	move.w	d0,-(sp)	Le handle du WAD
	move.w	#$3f,-(sp)	Code fonction Fread
	trap	#1	Appel au Gemdos
	lea	12(sp),sp	R‚alignement

XazFinOK
	movem.l	(sp)+,XAZ_LST_REG2	On remet tout en etat
	rte			Fin de la routine

XazFinPbl
	movem.l	(sp)+,XAZ_LST_REG2	On remet tout en etat
	jmp	([XazAncRout])	Goodbye ...

******************************************************************
*
* Mon trap #1
*

	even

	dc.l	"XBRA"	En tˆte compatible norme XBRA
	dc.l	XAZ_ID	Identificateur du prog
XazAncGemdos
	dc.l	$ffffffff	Adresse de la routine dont on prend la place

XazGemdos
	movem.l	d3-7/a3-6,-(sp)	Sauvegarde

	lea	8+9*4(sp),a6
	btst.b	#5,9*4(sp)	Appel en super ou en user ?
	bne.s	XazSuper

	move.l	usp,a6	a6 pointe sur les parametres

XazSuper
	move.w	(a6),d6	Fonction appell‚e ?
	cmp.w	#63,d6	Fread()
	beq.s	XazFread
	cmp.w	#64,d6	Fwrite()
	beq.s	XazFwrite

XazGemdosOK
	movem.l	(sp)+,d3-7/a3-6	Restauration
	jmp	([XazAncGemdos])	On laisse tomber

XazFread
XazFwrite
	movea.l	8(a6),a3	Adresse du buffer

	ptestr	#0,(a3),#7,a4	On tente une lecture

	clr.w	-(sp)	On fait de la place sur la pile
	pmove.w	mmusr,(sp)	On regarde le mmusr
	move.w	(sp)+,d1	On r‚aligne

	btst.l	#0,d1	Nbre de niveaux = 2 ou 3 ?
	beq.s	XazGemdosOK	2 -> Pas dans la virtuelle

	move.l	4(a6),d3	Longueur
	move.w	2(a6),d5	Handle
	clr.l	d7		Mon retour
	bra.s	XazFinBcleFreadFwrite

XazBcleFreadFwrite
	move.b	(a3),d4	Une lecture (pour charger la page)

	cmp.w	#63,d6	Fread ?
	bne.s	XazPasFread

	move.b	d4,(a3)	Une ‚criture (en cas de lecture en DMA)

XazPasFread
	ptestr	#0,(a3),#7,a4	On r‚cupŠre l'adresse du descripteur
	move.l	(a4),d4	d4 : descripteur
	ori.w	#XAZ_MASK_PAGE_C,d4
	subi.w	#XAZ_MASK_PAGE_C,d4
	movea.l	d4,a4	a4 : pointeur s/ page physique

	move.l	a3,d4
	andi.w	#XAZ_MASK_PAGE_C,d4
	ext.l	d4	d4 : octets aprŠs le d‚but

	adda.w	d4,a4	a4 : adr buffer

	neg.w	d4
	addi.w	#XAZ_PAGE_C,d4	d4 : octets … lire/ecrire au max.

	cmp.l	d4,d3	Compare … ce qu'il reste … lire
	bhs.s	XazPlusGrand

	move.w	d3,d4	On termine la lecture

XazPlusGrand			;d4 : nb octets … lire
	sub.l	d4,d3	d3 : nb … lire encore ensuite
	adda.l	d4,a3	a3 : adresse pour la suite

	pea	(a4)	Buffer
	move.l	d4,-(sp)	Longueur
	move.w	d5,-(sp)	Handle
	move.w	d6,-(sp)	Fread ou Fwrite
	trap	#1	Appel au Gemdos
	lea	12(sp),sp	R‚alignement

	tst.l	d0	retour
	bmi.s	FinXazGemdos
	add.l	d0,d7	Somme de tous les octets lus

XazFinBcleFreadFwrite
	tst.l	d3	Encore des octets … lire ?
	bne.s	XazBcleFreadFwrite
	move.l	d7,d0	Mon retour

FinXazGemdos
	movem.l	(sp)+,d3-7/a3-6	Restauration
	rte

******************************************************************
*
* Routine d'ouverture de fichier
*

XazFopen_old
	movem.l	XAZ_LST_REG,-(sp)

*** Teste du mode d'ouverture demand‚ ***
XazTesteMode
	moveq.l	#XAZ_ERR_INVMODE,d0	Code de retour
	move.w	(XAZ_1ST_PARAM+4)(sp),d1	mode = XAZ_READONLY ?
	beq.s	XazOuvreFich
	cmp.w	#XAZ_READWRITE,d1
	bne.w	FinXazFopen		Non

*** Ouverture du fichier de swap ***
XazOuvreFich
	move.w	d1,-(sp)		Mode d'ouverture
	move.l	(XAZ_1ST_PARAM+2)(sp),-(sp)	Nom du Fichier
	move.w	#$3d,-(sp)		Code fonction Fopen
	trap	#1				Appel au Gemdos
	addq.l	#8,sp				R‚alignement

	move.l	d0,d3
	moveq.l	#XAZ_ERR_FICH,d0	Erreur Fichier
	tst.l	d3		Code de retour
	bmi	FinXazFopen		N‚gatif => Erreur … l'ouverture

*** Positionnement … la fin du fichier (pour avoir la taille) ***
XazPlaceFinFichier
	move.w	#2,-(sp)	Mode 2 : A partir de la fin du fichier
	move.w	d3,-(sp)	Handle du fichier
	clr.l	-(sp)	Offset
	move.w	#$42,-(sp)	Code fonction Fseek
	trap	#1	Appel au Gemdos
	lea	10(sp),sp	R‚alignement

*** Calcul du nombre de pages de 256 et 8 ko correspondant ***
XazCalcNbPg256ko
	move.w	#XAZ_MUL_PAGE_B,d1	Pour diviser par (256*1024)
	subq.l	#1,d0
	lsr.l	d1,d0
	addq.l	#1,d0		d0 : nombre de pages de 256ko

	move.l	d0,d6
	move.w	#(XAZ_MUL_PAGE_B)-(XAZ_MUL_PAGE_C),d1
	lsl.l	d1,d6		d6 : nombre de pages de 8ko

*** Recherche d'une zone d'adressage libre ***
XazChercheZoneLibre
	move.l	#(128*128)-1,d2	Compteur de boucle
	move.l	d0,d5		Compteur de pages
	clr.l	d4		No de la 1Šre page de la zone
	movea.l	XazAdrNivB,a0

XazBcleChercheZoneLibre
	tst.l	(a0)+
	bne.s	XazBlocPasLibre
XazBlocLibre
	subq.l	#1,d0
	beq.s	XazTrouveZoneLibre
	dbra	d2,XazBcleChercheZoneLibre
	bra.s	XazPasTrouveZoneLibre
XazBlocPasLibre
	move.w	#(128*128),d4
	sub.w	d2,d4
	move.l	d5,d0
	dbra	d2,XazBcleChercheZoneLibre

XazPasTrouveZoneLibre
	moveq.l	#XAZ_ERR_ADR,d7
	bra.s	XazErrMallocOuZone

XazTrouveZoneLibre

*** Calcul de la taille des infos du fichier ***
XazCalcTailleInfoFich
	move.l	d6,d7
	lsl.l	#2,d7		d7 : Taille du niveau C
	addi.l	#XazFichNivC,d7	d7 : Taille des infos du fichier

*** Allocation des infos fichier ***
XazAllocInfoFichier
	move.w	#XAZ_PREFTTRAM,-(sp)
	move.l	d7,-(sp)
	bsr.w	XazMxalloc_old
	addq.l	#6,sp

	moveq.l	#XAZ_ERR_MEM,d7
	cmp.l	d0,d7
	beq.s	XazErrMallocOuZone

*** Initialisation de l'en-tˆte des infos fichier ***
XazInitEnTeteInfoFich
	movea.l	d0,a0
	move.l	#XAZ_FICHIDENT,(a0)		XazFichIdent
	move.w	(XAZ_1ST_PARAM+4)(sp),XazFichMode(a0)	XazFichMode
	move.w	d3,XazFichHandle(a0)		XazFichHandle
	move.w	d5,XazFichNbPgB(a0)		XazFichNbPgB
	move.l	d6,XazFichNbPgC(a0)		XazFichNbPgC
	lea	XazFichNivC(a0),a0

*** Initialisation du niveau C ***
XazInitNivC
	move.l	a0,d0
XazBcleInitNivC
	clr.l	(a0)+
	subq.l	#1,d6
	bne.s	XazBcleInitNivC

*** Remplissage du niveau B ***
XazRempliNivB
	addq.l	#2,d0		Valid 4 bytes
	subq.l	#1,d5		Pour le dbra
	movea.l	XazAdrNivB,a0
	lea	0(a0,d4.w*4),a0
	move.l	#4*(XAZ_PAGE_B>>XAZ_MUL_PAGE_C),d1
XazBcleRempliNivB
	move.l	d0,(a0)+
	add.l	d1,d0
	dbra	d5,XazBcleRempliNivB

	pflusha

	move.w	#XAZ_MUL_PAGE_B,d3	Pour multiplier par (256*1024)
	lsl.l	d3,d4
	move.l	d4,d0		Adresse du fichier
	bra.s	FinXazFopen

XazErrMallocOuZone
	move.w	d3,-(sp)	Le handle du fichier
	move.w	#$3e,-(sp)	Code fonction Fclose
	trap	#1		Appel au Gemdos
	addq.l	#4,sp		R‚alignement

	move.l	d7,d0		Code de retour

FinXazFopen
	movem.l	(sp)+,XAZ_LST_REG
	rts

******************************************************************
*
* Routine de fermeture de fichier
*

XazFclose_old
	movem.l	XAZ_LST_REG,-(sp)
	movea.l	(XAZ_1ST_PARAM)(sp),a3

*** V‚rification de l'alignement sur 8 ko ***
	move.l	a3,d1
	moveq.l	#XAZ_ERR_NOTFICH,d0
	andi.l	#XAZ_MASK_PAGE_C,d1
	bne.s	FinXazFclose

*** Recherche du 1er descripteur MMU ***
XazTrouve1stDescript
	ptestr	#0,(a3),#7,a4	On tente une lecture

	clr.w	-(sp)		On fait de la place sur la pile
	pmove.w	mmusr,(sp)	On regarde le mmusr
	move.w	(sp)+,d1	On r‚aligne

	btst.l	#0,d1		Nbre de niveaux = 2 ou 3 ?
	beq.w	FinXazFclose	2 -> C'est pas bon

*** R‚cup‚ration des infos ***
XazRecupereInfos
	lea	-XazFichNivC(a4),a5	a5 pointe s/le d‚but des infos
	cmpi.l	#XAZ_FICHIDENT,(a5) C'est bien le d‚but d'un fichier ?
	bne.s	FinXazFclose	Non

*** Fermeture du fichier ***
XazFermeFich
	move.w	XazFichHandle(a5),-(sp)	Handle du fichier
	move.w	#$3e,-(sp)	Code fonction Fclose
	trap	#1		Appel au Gemdos
	addq.l	#4,sp		R‚alignement

*** Chercher Niveau B ***
XazChercheNivB
	ptestr	#0,(a3),#2,a6	On r‚cupere l'adr du niveau B dans a6

*** Lib‚rer le niveau B ***
XazLibereNivB
	move.w	XazFichNbPgB(a5),d0	d0 : Nbre de pages … lib‚rer
	subq.l	#1,d0			Pour le dbra
XazBcleLibereNivB
	clr.l	(a6)+			Erreur de bus
	dbra	d0,XazBcleLibereNivB	Et on boucle

	pflusha

*** Liberer les pages en m‚moire ***
XazLibereInfos
	move.l	XazFichNbPgC(a5),d1	d1 : Nombre total de pages
	move.l	#XAZ_UNUSED,d2
	moveq.l	#XAZ_MAXNOTE,d4

XazBcleLibereInfos
	move.l	(a4)+,d3		Decripteur
	beq.s	XazFinBcleLibereInfos

	move.l	d3,-(sp)		Adresse de la page + ?(on s'en fout)
	bsr.w	XazChercheInfos		Appel … la fonction
	addq.l	#4,sp			R‚alignement

	movea.l	d0,a0
	move.l	d2,(a0)+		Page inutilis‚e
	move.l	d4,(a0)			Note maximale

XazFinBcleLibereInfos
	subq.l	#1,d1
	bne.s	XazBcleLibereInfos

*** Lib‚rer le bloc utilis‚ pour le niveau C et les infos ***
XazLibereBlocInfos
	pea	(a5)		Adresse du bloc
	bsr.w	XazMfree_old	Appel … la fonction
	addq.l	#4,sp		R‚alignement

	clr.l	d0

FinXazFclose
	movem.l	(sp)+,XAZ_LST_REG
	rts

******************************************************************
*
* Routine d'allocation m‚moire
*

XazMxalloc_old
	movem.l	XAZ_LST_REG,-(sp)

XazVerifMode
;	moveq.l	#XAZ_ERR_INVMODE,d0
	move.w	(XAZ_1ST_PARAM+4)(sp),d1	mode
;	move.w	d1,d2
;	andi.w	#$fffc,d2			Seulement 2 bits utilis‚s
;	bne.w	FinXazMxalloc			Mode non valide

XazGetAmount
	move.l	XAZ_1ST_PARAM(sp),d2		Amount
	cmpi.l	#-1,d2				-1 : demande taille bloc
	beq.w	XazRegardeRamInit
	moveq.l	#XAZ_ERR_LEN,d0			Code de retour
	tst.l	d2				longueur = 0 ?
	beq.w	FinXazMxalloc			Oui

XazChercheRamInit
	movea.l	d2,a0			a0 : quantit‚ demand‚e
	subq.l	#1,d2			Pour le lsr
	moveq.l	#XAZ_MUL_PAGE_C,d0	pour diviser par 8ko
	lsr.l	d0,d2
	addq.l	#1,d2			d2 : nbre de pages … chercher
	move.l	#XAZ_UNUSED,d3
	move.l	#XAZ_FIN_INFOS,d4

XazChercheRam
	moveq.l	#1,d5			d5 : No de la page courante + 1
	bchg.l	#0,d1
	beq.s	XazChercheSTRam

XazChercheTTRam
	movea.l	XazInfoPgTT,a1		a1 : pointeur sur les infos
	movea.l	XazTTRam,a2		a2 : d‚but du bloc choisi
	bset.l	#XAZ_BIT_TTRAM,d5	d5 : No de page dans TT Ram
	bra.s	XazChercheRam2

XazChercheSTRam
	movea.l	XazInfoPgST,a1
	movea.l	XazSTRam,a2

XazChercheRam2
	movea.l	a1,a3			a3 : pointeur s/d‚but des infos
	clr.l	d0			d0 : nbre de page bloc courant
	move.l	d5,d6			d6 : No page de d‚but du bloc

XazBcleChercheRam
	addq.l	#8,a1			page suivante (on passe la 1Šre)
	addq.l	#1,d5
	move.l	(a1),d7			Info pg
	bpl.s	XazChercheRamPageLibre	Page contenant du swap
	cmp.l	d7,d3			Inutilis‚e ?
	beq.s	XazChercheRamPageLibre

	clr.l	d0			Bloc courant … 0
	move.l	d5,d6
	cmp.l	d7,d4			Fin des infos ?
	bne.s	XazBcleChercheRam	Non -> on boucle

XazPasTrouveBloc
	bchg	#1,d1			Doit-on tester l'autre ram ?
	bne.s	XazChercheRam		Oui
	moveq.l	#XAZ_ERR_MEM,d0		Non -> on a ‚chou‚
	bra.w	FinXazMxalloc

XazChercheRamPageLibre
	addq.l	#1,d0			Bloc courant ++
	cmp.l	d2,d0			Bloc assez grand ?
	blo.s	XazBcleChercheRam	Non -> On boucle

*** Marquer le bloc + Lib‚rer les pages occup‚es par du swap ***
XazMarqueBloc
	lea	(a3,d6.l*8),a4		a4 : adr des infos
	move.l	d6,d5			d6 : 1ere page … modifier
	not.l	d5			d5 : Status
	move.l	d6,d4
	add.l	d2,d4			d4 : Derniere page … modifier + 1

XazBcleMarqueBloc
	tst.l	(a4)			Page inutilis‚e ou d‚ja marqu‚e ?
	bmi.s	XazPageLibere		Oui
XazMarqueBlocLiberePage
	bsr.w	XazLiberePage		On libŠre une page
	cmp.l	d6,d0			Est-ce la bonne ?
	beq.s	XazPageLibere		Oui (Cool !)
	blo.s	XazBougePage		Pas dans le bloc
	cmp.l	d4,d0			Dans le bloc ?
	bhs.s	XazBougePage		Non
	move.l	d5,(a3,d0.l*8)		On marque la page (Pour ne pas la re-choisir)
	bra.s	XazMarqueBlocLiberePage
XazBougePage
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	bsr.s	XazDeplacePage		On copie la page
	addq.l	#8,sp
XazPageLibere
	move.l	d5,(a4)+		Le Status de la page
	move.l	a0,(a4)+		La taille
	addq.l	#1,d6
	cmp.l	d6,d4			Fini ?
	bne.s	XazBcleMarqueBloc

*** Retourner l'adresse du bloc allou‚ ***
XazRetourneAdrMalloc
	not.l	d5
	moveq.l	#XAZ_MUL_PAGE_C,d1	pour multiplier par 8ko
	lsl.l	d1,d5			No page * 8ko
	add.l	a2,d5			+ d‚but du bloc = d‚but zone allou‚e
	move.l	d5,d0

	bra.s	FinXazMxalloc

*** Chercher le plus grand bloc dispo ***
XazRegardeRamInit
	clr.l	d2			Taille du + gd bloc trouv‚
	clr.l	d3			Taille du bloc courant
	move.l	#XAZ_UNUSED,d4
	move.l	#XAZ_FIN_INFOS,d5

XazRegardeRam
	bchg.l	#0,d1
	beq.s	XazRegardeSTRam

XazRegardeTTRam
	move.l	XazInfoPgTT,a0
	bra.s	XazBcleRegardeRam

XazRegardeSTRam
	move.l	XazInfoPgST,a0

XazBcleRegardeRam
	addq.l	#8,a0			page suivante (on passe la 1Šre)
	move.l	(a0),d6			Info pg
	bpl.s	XazRegardeRamPageLibre	Page contenant du swap
	cmp.l	d6,d4			Inutilis‚e ?
	bne.s	XazRegardeRamPagePasLibre

XazRegardeRamPageLibre
	addq.l	#1,d3			Bloc courant ++
	cmp.l	d2,d3			+ gd bloc ?
	bls.s	XazBcleRegardeRam
	move.l	d3,d2			On sauve
	bra.s	XazBcleRegardeRam

XazRegardeRamPagePasLibre
	clr.l	d3			Bloc courant … 0
	cmp.l	d6,d5			Fin des infos ?
	bne.s	XazBcleRegardeRam	Non -> on boucle

XazFinRegardeRam
	bchg	#1,d1
	bne.s	XazRegardeRam

XazRetournePlusGdBloc
	move.l	d2,d0			+ gd bloc dans d0
	moveq.l	#XAZ_MUL_PAGE_C,d1	Pour multiplier par 8*1024
	lsl.l	d1,d0			La taille du plus gd bloc dispo

FinXazMxalloc
	movem.l	(sp)+,XAZ_LST_REG
	rts

******************************************************************
*
* Routine de d‚placement de pages
*
* (Usage interne uniquement)
*

XazDeplacePage
	movem.l	XAZ_LST_REG,-(sp)
	movem.l	(XAZ_1ST_PARAM)(sp),d0-1 d0 : org ; d1 : dest

*** Trouver les infos et l'adr r‚elle des deux pages ***
	movea.l	XazSTRam,a5
	movea.l	XazTTRam,a4
	movea.l	XazInfoPgST,a2
	movea.l	XazInfoPgTT,a1
XazTstPage1
	btst.l	#XAZ_BIT_TTRAM,d0
	bne.s	XazPage1TT

XazPage1ST
	movea.l	a2,a0			a0 : Info 1ere page
	movea.l	a5,a3			a3 : Adresse
	bra.s	XazTstPage2

XazPage1TT
	movea.l	a1,a0
	movea.l	a4,a3

XazTstPage2
	btst.l	#XAZ_BIT_TTRAM,d1
	bne.s	XazPage2TT

XazPage2ST
	movea.l	a2,a1			a1 : Info 2eme page
	movea.l	a5,a4			a4 : Adresse

XazPage2TT

	move.w	#XAZ_MUL_PAGE_C,d2
	lea	(a0,d0.l*8),a0		a0 : Info 1ere page
	lea	(a1,d1.l*8),a1		a1 : Info 2eme page
	lsl.l	d2,d0
	lsl.l	d2,d1
	adda.l	d0,a3			a3 : Adresse 1ere page
	adda.l	d1,a4			a4 : Adresse 2eme page

*** R‚cup‚rer le niveau C de la 1Šre page ***
XazTrouveNivC
	move.l	(a0),d0			d0 : Numero de la page
	lsl.l	d2,d0			d0 : Adresse

	movea.l	d0,a2
	ptestr	#0,(a2),#7,a2		a2 : adr niv C

*** Mettre … jour le niveau C ***
XazNivCMAJ
	move.l	(a2),d0			On r‚cupŠre le descripteur
	andi.l	#$f,d0			On ne garde que les bits d'infos
	add.l	a4,d0			On met l'adr de la nvelle page
	move.l	d0,(a2)			On sauve le tout

	pflusha

*** Mettre … jour les infos des pages ***
XazInfoMAJ
	move.l	(a0)+,(a1)+		On copie les infos
	move.l	(a0),(a1)		Et la note

*** Copier le contenu de la page 1 dans la page 2 ***
XazCopie
	move.w	#(XAZ_PAGE_C/4)-1,d0
XazBcleCopie
	move.l	(a3)+,(a4)+
	dbra	d0,XazBcleCopie

XazFinDeplacePage
	movem.l	(sp)+,XAZ_LST_REG
	rts

******************************************************************
*
* Routine de lib‚ration d'une page.
*
* (Usage interne uniquement)
*

XazLiberePage
	movem.l	XAZ_LST_REG,-(sp)

*** Choisir la page … virer ***
XazInitChoixPg
	move.l	#XAZ_UNUSED,d2	d2 : Page inutilis‚e
	moveq.l	#XAZ_BIT_U_F,d3	d3 : Inutilis‚e ou Fin des infos
	moveq.l	#XAZ_MUL_PAGE_C,d4	d4 : pour calculer l'adr de la pg
	clr.l	d7		d7 : Note de la page pr‚f‚r‚e
	suba.l	a1,a1		a1 : No de la pg choisie
	lea	XAZ_MAXNOTE.w,a3 a3 : Note maximum
	lea	XAZ_NOTEM.w,a4 a4 : Note minimum

	movea.l	XazInfoPgST,a0	a0 : Infos de la page courante

;.attent_timer
;	move.w	$4bc,d6
;	andi.w	#%11,d6
;	bne.s	.attent_timer
;	move.l	#$00FF0000,$FFFF9800

	clr.l	d6		d6 : no de la page courante + 1

XazBcleChoixPg
	addq.l	#1,d6		Num Pg ++
	move.l	(a0)+,d0	d0 : Status de la pg courante
	bmi.s	XazPasSwap	Negatif -> Pas du swap
XazSwap	move.l	(a0)+,d1	d1 : Note de la page
	cmp.l	a3,d1		Note max ?
	beq.s	XazPgPasModifiee On ne peut plus monter la note
	lsl.l	d4,d0		On calcule l'adr de la page
	movea.l	d0,a5		a5 : Scratch
	ptestr	#0,(a5),#7,a2	a2 : Niv C
	addq.l	#3,a2		Pour tester le bon octet
	bclr.b	#3,(a2)		Test du bit U(sed)
	bne.s	XazPgAccedee
XazPgPasAccedee			; Pas pas utilisee
	addq.l	#1,d1		On augmente la note
	move.l	d1,-4(a0)	On ecrit la nouvelle note
XazPgAccedee
	btst.b	#4,(a2)		Test du bit M(odified)
	beq.s	XazPgPasModifiee
XazPgModifiee			Page modifi‚e
	sub.l	a4,d1		On DIMINUE la note
XazPgPasModifiee
	cmp.l	d7,d1		Note > … la meilleure note ?
	blo.s	XazBcleChoixPg	Non -> on boucle
	move.l	d6,a1		On note le No...
	move.l	d1,d7		... et la note !
	bra.s	XazBcleChoixPg	Puis on boucle
XazPasSwap			Page ne contenant pas du swap
	addq.l	#4,a0		On pointe sur la page suivante
	btst.l	d3,d0		Est-ce une page allou‚e
	bne.s	XazBcleChoixPg	Oui -> on boucle
XazUouF	cmp.l	d2,d0		Page inutilis‚e ?
	beq.s	XazPageChoisie	Oui -> On la prend
				; Cas Fin des infos
	movea.l	XazInfoPgTT,a0	On pointe sur la TT Ram
	andi.l	#1<<XAZ_BIT_TTRAM,d6	On passe … la pge 0...
	bset.l	#XAZ_BIT_TTRAM,d6	... de la TTRam
	beq.s	XazBcleChoixPg	On recommence pour la TT Ram

	move.l	a1,d6		d6 : No de la pg pr‚f‚r‚e + 1

XazPageChoisie
;	move.l	#$ffffffff,$ffff9800
	move.l	d6,d1
	subq.l	#1,d1		d0 : Page pr‚f‚r‚e
	move.l	XazInfoPgST,a0
	move.l	XazSTRam,a1
	btst.l	#XAZ_BIT_TTRAM,d1	Dans la TT Ram
	beq.s	XazLiberePageSTRam

XazLiberePageTTRam
	move.l	XazInfoPgTT,a0
	move.l	XazTTRam,a1

XazLiberePageSTRam
	lea	(a0,d1.l*8),a0		a0 pointe s/info page … virer

	move.l	(a0),d2			d2 : infos de la page
	bmi.s	FinXazLiberePage	<0 -> XAZ_UNUSED

XazLiberePageSwap
	move.l	#XAZ_UNUSED,(a0)+
	move.l	#XAZ_MAXNOTE,(a0)	Mise … jour des infos

	move.w	#XAZ_MUL_PAGE_C,d3
	lsl.l	d3,d2			d2 : adresse contenue
	movea.l	d2,a0
	ptestr	#0,(a0),#7,a3		a3 pointe s/ Niv C adr

	move.l	(a3),d2			d2 : Niv C adr
	btst.l	#4,d2			Page modifi‚e ?
	beq.s	FinXazLiberePageSwap	Non

	pea	(a3)
	bsr.s	XazChercheHandleModeAdr
	addq.l	#4,sp

	move.w	#XAZ_MUL_PAGE_C,d2	Pour multiplier par 8192
	move.l	d1,d3
	lsl.l	d2,d1
	add.l	a1,d1			d1 : adresse de la page en mem

	move.l	d1,-(sp)		Adresse du buffer
	pea	XAZ_PAGE_C.w		Taille d'une page
	move.w	d0,-(sp)		Handle du fichier
	move.w	#$40,-(sp)		Code fonction Fwrite
	trap	#1			Appel au Gemdos
	lea	12(sp),sp		R‚alignement

	move.l	d3,d1

FinXazLiberePageSwap
	clr.l	(a3)			Page plus en m‚moire
	pflusha

FinXazLiberePage
	move.l	d1,d0			On retourne le num‚ro
	movem.l	(sp)+,XAZ_LST_REG
	rts

******************************************************************
*
* Routine renvoyant … partir du niveau C d'une page le handle du
* fichier dans lequel elle r‚side, ainsi que le mode d'ouverture
* (dans le mot de poid fort). Elle fait le Fseek en prime !
*
* (Usage interne uniquement)
*

XazChercheHandleModeAdr
	movem.l	XAZ_LST_REG,-(sp)

	move.l	XAZ_1ST_PARAM(sp),d0	Adr pass‚e en param.
	move.l	d0,d1
	move.l	#XAZ_MASK_PAGE_C,d2

	and.l	d2,d1
	lsr.l	#2,d1			d1 : No de la page + ? - ?

	not.l	d2
	and.l	d2,d0			On s'aligne sur 8 ko
	movea.l	d0,a0			a0 : pointeur s/FichIdent

	moveq.l	#XAZ_FICHIDENT,d2	d2 : D‚but du fichier
	move.l	#XAZ_PAGE_C,d3		d3 : 8 ko
	move.l	#(XAZ_PAGE_C)/4,d4	d4 : Nb de descripteurs / page
XazBcleChercherInfoFich
	cmp.l	(a0),d2			Est-ce l'identificateur ?
	beq.s	XazFinBcleChercherInfoFich
	suba.l	d3,a0			a0 pointe une page avant
	add.l	d4,d1			No page += 2048
	bra.s	XazBcleChercherInfoFich	On boucle !

XazFinBcleChercherInfoFich
	subq.l	#((XazFichNivC)/4),d1	d1 : No de la page dans le fichier
	moveq.l	#XAZ_MUL_PAGE_C,d0	Pour multiplier par 8192
	lsl.l	d0,d1			d1 : Adresse dans le fichier

	move.l	XazFichMode(a0),d3	Mode + Handle du fichier

	clr.w	-(sp)			mode SEEK_SET : depuis la d‚but
	move.w	d3,-(sp)		Handle du fichier
	move.l	d1,-(sp)		Offset dans le fichier
	move.w	#$42,-(sp)		Code fonction Fseek
	trap	#1			Appel au Gemdos
	lea	10(sp),sp		R‚alignement

	move.l	d3,d0			Handle + mode en retour
	movem.l	(sp)+,XAZ_LST_REG
	rts

******************************************************************
*
* Routine de lib‚ration de m‚moire
*

XazMfree_old
	movem.l	XAZ_LST_REG,-(sp)
	move.l	XAZ_1ST_PARAM(sp),d1	Adr pass‚e en param.

*** V‚rification de l'alignement sur 8 ko ***
	move.l	d1,d2
	moveq.l	#XAZ_ERR_NOTBLOC,d0
	andi.l	#XAZ_MASK_PAGE_C,d2
	bne.s	FinXazMfree

	move.l	d1,-(sp)
	bsr.s	XazChercheInfos
	addq.l	#4,sp

	cmp.l	#XAZ_ERR_NOTBLOC,d0	Erreur durant la v‚rif ?
	beq.s	FinXazMfree		Oui

*** V‚rification de d‚but bloc ***
XazVerifDebutBloc
	movea.l	d0,a0
	moveq.l	#XAZ_ERR_NOTBLOC,d0
	move.l	(a0),d2		d2 : Status du bloc
	bpl.s	FinXazMfree	>=0 (=swap)
	btst.l	#XAZ_BIT_U_F,d2	XAZ_UNUSED ou XAZ_FIN_INFOS
	beq.s	FinXazMfree
	cmp.l	-8(a0),d2	Status du bloc pr‚c‚dent
	beq.s	FinXazMfree

*** Lib‚ration des pages du bloc ***
XazLiberePages
	move.l	#XAZ_UNUSED,d1
	moveq.l	#XAZ_MAXNOTE,d3
XazBcleLiberePg
	move.l	d1,(a0)+
	move.l	d3,(a0)+
	cmp.l	(a0),d2			Fin du bloc ?
	beq.s	XazBcleLiberePg		Non

	clr.l	d0

FinXazMfree
	movem.l	(sp)+,XAZ_LST_REG
	rts


******************************************************************
*
* Routine de recherche de l'adresse des infos d'une page … partir
* de l'adresse de la page
*
* (Usage interne uniquement)
*

XazChercheInfos
	movem.l	XAZ_LST_REG,-(sp)
	move.l	(XAZ_1ST_PARAM)(sp),d1	Adr pass‚e en param
	moveq.l	#XAZ_ERR_NOTBLOC,d0

*** Recherche du bloc d'origine ***
XazChercheBlocOrg
	moveq.l	#XAZ_MUL_PAGE_C,d2 Pour multiplier (et diviser) par 8196
	lsr.l	d2,d1		d1 : Bloc demand‚

XazTesteSTRam
	move.l	XazSTRam,d3
	lsr.l	d2,d3		d3 : 1er bloc de la ST Ram
	move.l	XazNbPgST,d4
	add.l	d3,d4		d4 : Bloc de fin de la ST Ram
	cmp.l	d3,d1
	blt.s	XazTesteTTRam
	cmp.l	d4,d1
	bge.s	XazTesteTTRam
	move.l	XazInfoPgST,a0

	bra.s	XazRecupInfos

XazTesteTTRam
	move.l	XazTTRam,d3
	lsr.l	d2,d3		d3 : 1er bloc de la TT Ram
	move.l	XazNbPgTT,d4
	add.l	d3,d4		d4 : Bloc de fin de la TT Ram
	cmp.l	d3,d1
	blt.s	XazFinChercheInfos
	cmp.l	d4,d1
	bge.s	XazFinChercheInfos
	move.l	XazInfoPgTT,a0

*** R‚cup‚ration des infos de la page ***
XazRecupInfos
	sub.l	d3,d1		d1 : Page dans le bloc
	lea	0(a0,d1.l*8),a0

	move.l	a0,d0
XazFinChercheInfos
	movem.l	(sp)+,XAZ_LST_REG
	rts


******************************************************************
*
* Routine de diminution de bloc m‚moire
*

XazMshrink_old
	movem.l	XAZ_LST_REG,-(sp)
	move.l	(XAZ_1ST_PARAM)(sp),d1	Adr pass‚e en param

*** V‚rification de l'alignement sur 8 ko ***
	move.l	d1,d2
	moveq.l	#XAZ_ERR_NOTBLOC,d0
	andi.l	#XAZ_MASK_PAGE_C,d2
	bne.s	FinXazMshrink

	move.l	d1,-(sp)
	bsr.s	XazChercheInfos
	addq.l	#4,sp

	cmp.l	#XAZ_ERR_NOTBLOC,d0	Erreur durant la v‚rif ?
	beq.s	FinXazMshrink		Oui

*** V‚rification de d‚but bloc ***
XazVerifDebutBloc2
	movea.l	d0,a0
	moveq.l	#XAZ_ERR_NOTBLOC,d0
	move.l	(a0)+,d2		d2 : Status du bloc
	bpl.s	FinXazMshrink		>=0 (=swap)
	btst.l	#XAZ_BIT_U_F,d2		XAZ_UNUSED ou XAZ_FIN_INFOS
	beq.s	FinXazMshrink
	cmp.l	-12(a0),d2		Status du bloc pr‚c‚dent
	beq.s	FinXazMshrink

*** Verifier Nouvelle Taille <= Ancienne Taille ***
XazSuiteMshrink
	moveq.l	#XAZ_ERR_LEN,d0
	move.l	(XAZ_1ST_PARAM+4)(sp),d1	d1 : Nouvelle taille
	beq.s	FinXazMshrink			Egale … 0
	moveq.l	#XAZ_ERR_GROWTH,d0
	cmp.l	(a0),d1				ancienne taille
	bhi.s	FinXazMshrink			Nouvelle > ancienne

*** Calculer le num‚ro de la premiŠre page … lib‚rer ***
XazCalcNumPageToFree
	moveq.l	#XAZ_MUL_PAGE_C,d0
	move.l	d1,d4				d4 : Nouvelle taille
	subq.l	#1,d1
	lsr.l	d0,d1
	addq.l	#1,d1				d1 : 1Šre page … lib‚rer

*** Mettre la taille du bloc … jour ***
XazBcleMAJTaille
	move.l	d4,(a0)				‚criture
	addq.l	#8,a0				page suivante
	subq.l	#1,d1
	bne.s	XazBcleMAJTaille

*** Lib‚rer ‚ventuellement la (les) page(s) ***
XazLiberePages2
	subq.l	#4,a0				On pointe s/1er long
	move.l	#XAZ_UNUSED,d1
	moveq.l	#XAZ_MAXNOTE,d3
	bra.s	XazFinBcleLiberePg2

XazBcleLiberePg2
	move.l	d1,(a0)+			Page inutilis‚e
	move.l	d3,(a0)+			Note Maximum
XazFinBcleLiberePg2
	cmp.l	(a0),d2				Toujours le mˆme bloc ?
	beq.s	XazBcleLiberePg2

	clr.l	d0				Code de retour
FinXazMshrink
	movem.l	(sp)+,XAZ_LST_REG
	rts

******************************************************************
*
* Routine de remise en ‚tat du systŠme
*

XazOff_old	movem.l	XAZ_LST_REG,-(sp)

*** Fermeture de tous les fichiers encore ouverts ***
XazFermeFichiers
	clr.l	d1
	moveq.l	#1,d2		Num‚ro du bit … tester
	move.l	#XAZ_PAGE_B,d3	Chaque descripteur correspond … 256 ko
	move.l	#128*128-1,d4	128*128 descripeurs au niveau B
	move.l	XazAdrNivB,a0
	addq.l	#3,a0		+3 pour tester le bon bit

XazBoucleFermeFichiers
	btst.b	d2,(a0)
	beq.s	XazNi2Ni3
Xaz2ou3
	move.l	d1,-(sp)	Adresse du fichier
	bsr.w	XazFclose_old	Fermeture
	addq.l	#4,sp		R‚alignement
XazNi2Ni3
	add.l	d3,d1
	addq.l	#4,a0
	dbra	d4,XazBoucleFermeFichiers

*** D‚sinstallation de la routine d'erreur bus ***
XazEnleveErrBus
	move.l	XazAncRout,-(sp)	Adr de l'ancienne routine
	move.w	#2,-(sp)	Vecteur nø2 (Erreur de bus)
	move.w	#5,-(sp)	Code fonction setexc
	trap	#13		Appel du Bios
	addq.l	#8,sp		R‚alignement
*** D‚sinstallation de mon Gemdos ***
XazEnleveGemdos
	move.l	XazAncGemdos,-(sp)	Adr de l'ancienne routine
	move.w	#$21,-(sp)	Vecteur $21 (Gemdos)
	move.w	#5,-(sp)	Code fonction setexc
	trap	#13		Appel du Bios
	addq.l	#8,sp		R‚alignement

*** Remise en ‚tat de la MMU ***	Version pour 030 seulement !
XazRemetMMU
	clr.l	-(sp)
	pmove.l	(sp),tc		On d‚sactive la MMU ...
	addq.l	#4,sp		R‚alignement
	lea	XazSavMMU(pc),a0
	pmove.d	(a0),crp	On remet les anciens crp, ...
	pmove.l	8(a0),tt0	... tt0,...
	pmove.l	12(a0),tt1	... tt1,...
	pmove.l	16(a0),tc	... et tc.

*** Lib‚ration de toute la m‚moire r‚serv‚e ***
XazFreeTTRam
	move.l	XazAdrMalloc2,d0	Adresse du bloc de TT Ram
	beq.s	XazFreeSTRam
	move.l	d0,-(sp)	L'adresse de la zone memoire
	move.w	#$49,-(sp)	Code fonction Mfree
	trap	#1		Appel au Gemdos
	addq.l	#6,sp		R‚alignement
XazFreeSTRam
	move.l	XazAdrMalloc1,d0	Adresse du bloc de ST Ram
	beq.s	FinXazOffOK
	move.l	d0,-(sp)	L'adresse de la zone memoire
	move.w	#$49,-(sp)	Code fonction Mfree
	trap	#1		Appel au Gemdos
	addq.l	#6,sp		R‚alignement

FinXazOffOK
	clr.w	XazFlagOn
	clr.l	d0

FinXazOff
	movem.l	(sp)+,XAZ_LST_REG
	rts

******************************************************************
*** Variables ***

SECTION DATA

XazFlagOn	dc.w	0	… TRUE quand la gestion est install‚e

XazTableTesteFormat	; Vachement compliqu‚e comme table !
	dc.l	XazFmt0
	dc.l	XazFmt1
	dc.l	XazFmt2
	dc.l	XazFmt3
	dc.l	XazFmt4
	dc.l	XazFmt5
	dc.l	XazFmt6
	dc.l	XazFmt7
	dc.l	XazFmt8
	dc.l	XazFmt9
	dc.l	XazFmtA
	dc.l	XazFmtB
	dc.l	XazFmtC
	dc.l	XazFmtD
	dc.l	XazFmtE
	dc.l	XazFmtF

SECTION DATA

XazProc		dc.l	0	Le type du processeur (cookie _CPU)

XazAdrNivB	dc.l	0	L'adresse de d‚but du niveau B de l'arbre

XazAdrMalloc1	dc.l	0	A cause de l'alignement s/ 8 ko
XazSTRam	dc.l	0	L'adr de d‚but du bloc de ST Ram
XazInfoPgST	dc.l	0	L'adr de d‚but des infos des pages de ST Ram
XazNbPgST	dc.l	0	Le nombre de pages de ST Ram trouv‚es

XazAdrMalloc2	dc.l	0	A cause de l'alignement s/ 8 ko
XazTTRam	dc.l	0	L'adr de d‚but du bloc de TT Ram
XazInfoPgTT	dc.l	0	L'adr de d‚but des infos des pages de TT Ram
XazNbPgTT	dc.l	0	Le nombre de pages de TT Ram trouv‚es

XazSavMMU			; Pour sauver la configuration MMU
XazSavCRP	dc.l	0,0	Registre sur un Quad-Word
XazSavTT0	dc.l	0
XazSavTT1	dc.l	0
XazSavTC	dc.l	0
