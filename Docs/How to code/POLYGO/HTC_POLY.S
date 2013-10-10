***************************************************************************
*                                                                         *
*                    routine de polygone convex 1 plan                    *
*                            COMPATIBLE STF                               *
*                         coded by SKYNET-ABSTRACT                        *
*                                                                         *
***************************************************************************

* TABULATION SOUS GENST : 3


MFP	equ	$fffffa00
MFPIERA	equ	MFP+$07
MFPIERB	equ	MFP+$09
MFPISRA	equ	MFP+$0f
MFPISRB	equ	MFP+$11
MFPIMRA	equ	MFP+$13
MFPIMRB	equ	MFP+$15
MFPVR	equ	MFP+$17
MFPTACR	equ	MFP+$19
MFPTBCR	equ	MFP+$1b
MFPTADR	equ	MFP+$1f
MFPTBDR	equ	MFP+$21

		TEXT

; SUPERVISEUR

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap		#1
	addq.l	#6,sp
	
; SAUVEGARDE DE L'ETAT DU ST

	bsr	SAVE_STATE

; INSTAL LES NOUVELLES INTERUPTIONS

	bsr	INSTALL_INTER

; INSTAL LES INITS SPECIALES

	bsr	SPE_INITS

WAIT_SPACE:
	cmpi.b	#$39,$fffffc02.w
	bne.s	WAIT_SPACE

WAIT_NO_SPACE:
	cmpi.b	#$39+$80,$fffffc02.w
	bne.s	WAIT_NO_SPACE
	
 	move.w	#$2700,sr		; masque les interruptions
	
; FIN DU PRG. ON REMET LE ST DANS L'ETAT OU ON LA TROUVE

	bsr	RESTORE_STATE
	
	move.w	#$2300,sr 		; lache les anciennes interruptions
	
; ON QUITTE LE PROGRAMME

	pea	0.w
	trap	#1

***************************************************************************

*************************
*    Initialisation     *
* sauve l'etat initiale *
*************************

SAVE_STATE:
	
; SAUVE LES REGISTRES DU SHIFTER
	lea	$ffff8200.w,a6		; adr de base du shifter
	lea	OLD_SHIFTER,a5		; adr de base de la sauvegarde 
	move.l	(a6),d0
	move.l	d0,(a5)+		; sauve l'ancienne adr de l'ecran
	
	movem.l	$40(a6),d0-7
	movem.l	d0-7,(a5)		; sauve l'ancienne palette
	lea	32(a5),a5
	
	move.w	$60(a6),(a5)		; sauve la resolution
	
; SAUVE LES INTERUPTIONS
	move.l	$70.w,OLD_VBL		; sauve l'ancien vecteur VBL
	move.l	$118.w,OLD_KBD		; sauve le vecteur KBD
	move.b	MFPIERA.w,OLD_MFP			
	move.b	MFPIERB.w,OLD_MFP+1	; sauve masks IT MFP
	move.b	MFPIMRA.w,OLD_MFP+2		
	move.b	MFPIMRB.w,OLD_MFP+3		
	
	RTS

              ***********************
              *   Initialisation    *
              * installe les inters *
              ***********************

INSTALL_INTER:

; ON COUPE LA SOURIS 

	move.b	#$12,$fffffc02.w	; desactive donne souris
	dc.w	$a00a			; hide MOUSE

; Interruptions

	clr.b	MFPIERA.w		; inhibe toutes
	move.b	#$40,MFPIERB.w		; les ITs du MFP
	move.b	#$40,MFPIMRB.w		; sauf l'IT Clavier/Midi

	move.l	#VBL_RET,$70.w		; routine VBL vide pour attendre
	stop	#$2300			; le retour du faisceau d'eÿ afin
					; d'eviter les decalages de plan
	; Parametres ecran              

	clr.w	$60(a6)			; met en place la Basse resolution
	
	movem.l	PALETTE,d0-d7
	movem.l	d0-d7,$40(a6)		; met en place la nouvelle Palette
	
	move.l	#SCREEN+256,d0		; met en place le nouvel
	clr.b	d0			; ecran en tenant compte
	move.l	d0,ADR_SCR		; du stf.
	lsr.l	#8,d0
	movep.w	d0,$1(a6)
	RTS

               ********************
               *   Initiation     *
               * INSTAL LES       *
               * ANCIENNES INTERS *
               ********************

RESTORE_STATE
	move.l	#VBL_RET,$70.w
	stop		#$2300						
	move.w	#$2700,sr

	move.b	OLD_MFP,MFPIERA.w				
	move.b	OLD_MFP+1,MFPIERB.w	
	move.b	OLD_MFP+2,MFPIMRA.w	; Anciens masks IT MFP
	move.b	OLD_MFP+3,MFPIMRB.w	

	
; REINSTALLE LES REGISTRES DU SHIFTER                                        
	lea	$ffff8200.w,a6		; adr de base du shifter
	lea	OLD_SHIFTER,a5		; adr de base de la sauvegarde
	move.l	(a5)+,d0		; remet l'ancienne adr de l'ecran
	move.l	d0,(a6)
	movem.l	(a5),d0-7
	movem.l	d0-7,$40(a6)		; remet l'ancienne palette
	lea	32(a5),a5
	move.w	(a5),$60(a6)		; remet la rezo
	
  	move.l	OLD_KBD,$118.w		; restaure l'ancien vecteur KBD
	move.l	OLD_VBL,$70.w		; restaure l'ancien vecteur VBL

TEST_KEY:

	btst.b	#0,$fffffc00.w
	beq.s	NO_KEY
	move.b	$fffffc02.w,d0
	bra.s	TEST_KEY

NO_KEY:

; Souris		
	dc.w	$a009				; line A No 9 : Show Mouse
	move.b	#8,$fffffc02.w			; reactive donnees souris
		
	RTS
  
*******************
* INTER SPECIALES *
*******************

SPE_INITS

* creation d'un tableau contenant les adresses 
* de chaques lignes de l'ecran

	lea	TAB_LINE_ADR,a0		; adresse du tableau
	move.l	ADR_SCR,a1		; adresse de l'ecran
	move.w	#199,d0			; nombre de lignes-1
.mk_tab
	move.l	a1,(a0)+		; on inscrit l'adr de la 1ere ligne
	lea	160(a1),a1		; ligne suivante
	dbf	d0,.mk_tab		; on reboucle 199 fois

* routine de creation des code auto-generes pour
* le remplisage de la ligne SUIVANT LE NBR DE BLOC

MK_ROUT

	lea	TAB_AFF,a2	  	; tablo contenant les adr des routines
	move.w	#$c440,d0		; AND.W   D0,D2
	move.w	#$8168,d1		; OR.W    D0,x(A0)
	move.w	#$8568,d2		; OR.W    D2,x(A0)
	move.w	#$3141,d3		; MOVE.W  D1,x(A0)

* on va generer la routine qui se charge d'afficher une ligne 
* d'un DX entre 1 et 15.on reuni le mask de depart et d'arrive.
.rout1	
	move.l	(a2)+,a1		; adr de la premiere routine
	move.w	d0,(a1)+		; AND.W   D0,D2 : pour avoir la partie
					; commune des deux masks.            
	move.w	d2,(a1)+		; OR.W    D2,x(A0) : on affiche...
	move.w	#0,(a1)+		; x=0 , donc on affiche au 1er bloc
	move.w	#$4e75,(a1)+		; RTS
	
* on va genere la routine qui se charge d'afficher une ligne 
* d'un DX entre 2 et 32.on affiche le mask de depart et d'arrive.
.rout2
	move.l	(a2)+,a1		; adr de la deuxieme routine
	move.w	d1,(a1)+		; OR.W    D0,x(A0)
	move.w	#0,(a1)+		; x=0 , donc on affiche au 1er bloc
	move.w	d2,(a1)+		; OR.W    D2,x,(A0)
	move.w	#8,(a1)+		; x=8 , donc on affiche au 2eme bloc
	move.w	#$4e75,(a1)+	; RTS
	
* on va genere les routine qui se charge d'affiche le mask de
* depart,un nombre de block (suivant la routine) et le mask d'arrive.
	move.w	#18,d7			; nbr de routines-1 restante a generer
	moveq	#0,d6			; nbr de bloc-1 a afficher
					; pour la 1ere routine.
.all_rout
	move.w	d6,d0				
	move.l	(a2)+,a1		; adr de la routine que l'on genere
	move.w	d1,(a1)+		; on affiche le mask de depart...
	move.w	#0,(a1)+		; ... a la bonne place
	move.w	#8,d5			; a partir de kel bloc on commence.
.nbr_blk:
	move.w	d3,(a1)+		; 1er move.w
	move.w	d5,(a1)+		; sur le 2eme bloc
	addq.w	#8,d5			; on saute au bloc d'apres
	dbf	d0,.nbr_blk		; on fait les autres
	move.w	d2,(a1)+		; le mask d'arrive...
	move.w	d5,(a1)+		; ... sur le bloc final
	move.w	#$4e75,(a1)+		; on place un RTS
	addq.w	#1,d6			; la prochaine routine affichera
					; un block en plus que la precedente.
	dbf	d7,.all_rout		; on genere les autres routines.
	
* creation d'un tableau contenant pour chaque X compris entre 0 et 319
* le mask de depart et le nombre de block depuis le debut de la ligne.

MK_TAB_X:
	lea	TAB_X,a1		; le adresse du bo tablo.
	lea	MASK,a0			; adr des differents masks.
	moveq	#0,d0			; le nbr de block depuis le debut
	move.w	#19,d1			; nbr de block a faire
.mk_tab
	rept	16
	move.w	(a0),(a1)+		; le mask
	move.w	d0,(a1)+		; le nbr de block
	addq.w	#4,a0			; on saute au mask suivant
	endr
	lea	MASK,a0			; on recommence
	addq.w	#8,d0			; mais un block plus loin.
	dbf	d1,.mk_tab

* creation d'un tableau contenant pour chaque X entre 0 et 319
* de mask d'arrive.
MK_TAB_X2
	lea	TAB_X2,a1		; adr du tablo...
	lea	MASK+2,a0		; adr des mask d'arrive...
	move.w	#19,d0			; nbr de bloc a faire...
.mk_tab
	rept	16			; on inscrit les masks possible
	move.w	(a0),(a1)+		; dans le bo tablo
	addq.w	#4,a0				; onprend le mask suivant.
	endr
	lea	MASK+2,a0		; on recommence pour les autres blocks
	dbf	d0,.mk_tab
	
* on a finir les petits precalcules...donc on lance l'interruption VBL.	
	move.l	#INSTAL_VBL,$70.w

	RTS

* cette VBL s'occupe de lance la vraie VBL,pour que celle-ci
* commce bien au bon moment.
INSTAL_VBL	
	move.l	#VBL_PLAY,$70.w
VBL_RET
	rte

* ET VOICI LA ZOLIE VBL QUI VA NOUS TRACER LE NON MOINS ZOLIE
* POLYGONE...
VBL_PLAY

	move.w	#$100,$ffff8240.w	; c'est pour tester le temps machine
					; pris par la routine de polygone.

	lea	OBJECT_1,a0	; point sur l'adr des differents parametres
				; de notre polygone...
	move.w	(a0)+,d7	; nbr de polygone-1 a tracer...

.mk_all_poly
	move.w	(a0)+,d6	; nbr de sommet-1 du 1er polygone.
	move.w	d6,NB_POINT		
	lea	CO_POINT,a1	; buffer ou la routine de polygone
				; va chercher les coordonnees des points.
.mk_one_poly
	move.w	(a0)+,(a1)+	; transfert de la coord. X
	move.w	(a0)+,(a1)+	; transfert de la coord. Y
	dbf	d6,.mk_one_poly	; on transfert les autres points.
	movem.l	d7/a0,-(sp)
	
	bsr	POLYGONE	; ALLEZ,HOP!!! ON TRACE LE POLYGONE.         
	
	movem.l	(sp)+,d7/a0
	dbf	d7,.mk_all_poly	; et on reboucle pour tracer les otres.

	clr.w	$ffff8240.w	; on a fini.
	
	RTE			; fin le l'interruption...

**************************************************
* routine d'affichage d'un polygone convex (stf) *
* les variables necessaires :                    *
*          - NB_POINT ( nbr de sommets -1 )      *
*          - CO_POINT ( x.w et y.w des point)    *
**************************************************

POLYGONE
	
* recherche des coord. YMIN et YMAX du polyg.

	lea	CO_POINT+2(pc),a0	; pointe sur Y1
	
	move.w	(a0),d0			; d0 = Y du 1er point.
	move.w	d0,d1			; d1 = d0 = YMIN TEMP.
	move.w	d0,d2			; d2 = d0 = YMAX TEMP.
	addq.w	#4,a0			; on poine sur Y2
	
	move.w	NB_POINT(pc),d3
	subq.w	#1,d3	; on auras deja fait 2 points avant de reboucler
.yminmax
	move.w	(a0),d0		; y
	cmp.w	d1,d0		; y<ymin ?
	bgt.s	.max		; y et plus grand ke xmin.dc on le met ds xmax
	move.w	d0,d1		; y et plus petit ke xmin.dc ...
	addq.w	#4,a0		; on point sur le y suivant et
	dbf	d3,.yminmax	; on reboucle
	bra.s	.fini		; on saute a la suite si c'est fini.
.max
	cmp.w	d2,d0		; y<ymax ?
	blt.s	.again		; oui dc on reboucle
	move.w	d0,d2		; non dc y est le nouvel ymax
.again
	addq.w	#4,a0		; pareille ke 7 lignes en ht...
	dbf	d3,.yminmax
.fini
	
* now,on clip YMIN et YMAX et on regarde si le polygone
* est dans l'ecran...sinon,on affiche rien.

	tst.w	d1		; ymin < 0 ??
	bge.s	.ok		; non donc c bon.
	moveq	#0,d1		; oui,donc on clip
	bra.s	.ymax
.ok
	cmpi.w	#199,d1		; ymin est dans l'ecran ?
	bgt	NO_POLY		; non,donc on affiche rien
.ymax
	cmpi.w	#199,d2		; ymax>199 ??
	ble.s	.okok		; non, donc c bon
	move.w	#199,d2		; vi, donc on clip
	bra.s	.cbon
.okok
	tst.w	d2		; ymax<0 ?
	blt	NO_POLY		; ymax est < 0.dc on affiche rien.
.cbon
	move.w	d1,YMIN		; voila...
	move.w	d2,YMAX

* now, copie le 1er point en dernier...coz on commence a tracer
* du premier et on termine par le premier.	

	move.w	NB_POINT(pc),d0		; nbr de point-1
	move.w	d0,d7			; pour plus tard
	lea	CO_POINT(pc),a6		; tab de coord. des points
	addq.w	#1,d0			; nbr de point tout court
	lsl.w	#2,d0			; nbr de point *4
	move.l	(a6),(a6,d0.w)		; et voila, le tour est joue.

* now, on trace virtuellement les lignes.

	lea		XMIN(pc),a0	; adresse du tableau des XMIN
	lea		XMAX(pc),a1	; et de celui des XMAX
MK_LINE
	movem.w	(a6),d0-3		; voila on transfert X1,Y1,X2 et Y2.
	addq.w	#4,a6			; on pointe sur X2 et Y2.
	jsr	LINE			; hop, on trace la 1ere ligne
	dbf	d7,MK_LINE		; on reboucle..
	
*************** NOW, ON VA TRACER CE FAMEUX POLYGONE.. ***************	

	lea	TAB_LINE_ADR(pc),a6	; tablo contenant les adr des lignes
	move.w	YMIN(pc),d3		; YMIN du polygone
	move.w	d3,d2			; c'est pour plus tard...
	lsl.w	#2,d2			; YMIN*4
	add.w	d2,a6			; on pointe sur l'adr de la 1ere ligne
	
	move.w	YMAX(pc),d7	; YMAX du polygone
	sub.w	d3,d7		; on a le nbr de lignes a afficher (DY)
	subq.w	#1,d7		; on aura deja fait 1 ligne avant de reboucler
	move.w	#$ffff,d1	; motif de remplissage.
	
	lea	XMIN(pc),a1		; tablo des XMIN.
	lea	XMAX(pc),a2		; tablo des XMAX.
	add.w	d3,d3			; YMIN*2
	add.w	d3,a1			; adr de depart ds le tablo XMIN
	add.w	d3,a2			; adr de depart ds le tablo XMAX.
	
	lea	TAB_X(pc),a3	; tablo de mask de dep + offset
	lea	TAB_X2(pc),a4	; tablo de mask d'arrivee pour chaque X
	lea	TAB_AFF(pc),a5	; tablo contenant les adr des routines d'affich
	move.w	#$fff0,d5		; mask pour obtebir un multiple de 16.
FILL

	lea	TAB_AFF(pc),a5	
	move.l	(a6)+,a0		; adr de la ligne suivante de l'ecran
	move.w	(a1)+,d0		; XMIN
	move.w	(a2)+,d2		; XMAX

	move.w	d0,d3			; d3 = XMIN
	move.w	d2,d6			; d6 = XMAX
	lsl.w	#2,d0			; XMIN*4
	add.w	2(a3,d0.w),a0		; on pointe sur le bon bloc de depart
	move.w	(a3,d0.w),d0		; mask de depart
	add.w	d2,d2			; XMAX *2
	move.w	(a4,d2.w),d2		; mask d'arrive
	
	and.w	d5,d3			; nbr de bloc pour XMIN *16
	and.w	d5,d6			; nbr de bloc pour XMAX *16
	sub.w	d3,d6			; nbr de block*16 a afficher.
	lsr.w	#2,d6			; nbr de block*4 a afficher.
	move.l	(a5,d6.w),a5		; adr de la routine
	jsr	(a5)
	dbf	d7,FILL
	
NO_POLY
	RTS

NB_POINT		; ici doit figurer le nbr de sommets du polyg.-1
	DS.W	1
CO_POINT		; coordonnees X et Y des sommets du polyg.
	DS.L	50
YMIN			; variable contenant le YMIN du polyg.
	DS.W	1
YMAX			; varaible contenant le YMAX du polyg.
	DS.W	1
TAB_LINE_ADR
	DS.L	200
TAB_X			; tablo contenant mask de depart + offset
	DS.l	320
TAB_X2			; tablo contenant pour chaque X le mask d'arrive
	DS.W	320

AFF1				
	DS.W	4	; routine qui affiche 1 mask ( M1 & M2) 
AFF2				
	DS.W	5 	; routine qui affiche 2 masks : M1 et M2
AFF3
	DS.W	7	; routine qui affiche 2 masks + 1 bloc
AFF4
	DS.W	9	; routine qui affiche 2 masks + 2 blocs
AFF5
	DS.W	11	; routine qui affiche 2 masks + 3 blocs
AFF6
	DS.W	13	; routine qui affiche 2 masks + 4 blocs
AFF7
	DS.W	15	; routine qui affiche 2 masks + 5 blocs
AFF8
	DS.W	17	; routine qui affiche 2 masks + 6 blocs
AFF9
	DS.W	19	; routine qui affiche 2 masks + 7 blocs
AFF10
	DS.W	21	; routine qui affiche 2 masks + 8 blocs
AFF11
	DS.W	23	; routine qui affiche 2 masks + 9 blocs
AFF12
	DS.W	25	; routine qui affiche 2 masks + 10 blocs
AFF13
	DS.W	27	; routine qui affiche 2 masks + 11 blocs
AFF14
	DS.W	29	; routine qui affiche 2 masks + 12 blocs
AFF15
	DS.W	31	; routine qui affiche 2 masks + 13 blocs
AFF16
	DS.W	33	; routine qui affiche 2 masks + 14 blocs
AFF17
	DS.W	35	; routine qui affiche 2 masks + 15 blocs
AFF18
	DS.W	37	; routine qui affiche 2 masks + 16 blocs
AFF19
	DS.W	39	; routine qui affiche 2 masks + 17 blocs
AFF20
	DS.W	41	; routine qui affiche 2 masks + 18 blocs
AFF21
	DS.W	43	; routine qui affiche 2 masks + 19 blocs
	
TAB_AFF
	DC.L	AFF1,AFF2,AFF3,AFF4,AFF5,AFF6,AFF7,AFF8,AFF9,AFF10,AFF11
	DC.L	AFF12,AFF13,AFF14,AFF15,AFF16,AFF17,AFF18,AFF19,AFF20,AFF21

XMIN
	DS.W	200
XMAX
	DS.W	200
	
*************************************************
* calcul des xmin et xmax d'une ligne           *
* en entree: X1,Y1,X2,Y2 coordonnees            *
*            des sommets de la ligne            *
* en sortie: MIN_MAX contient les xmin          *
*            et xmax de la ligne                *
*************************************************

LINE

	move.l	a1,a3			; pointe sur XMAX
	move.w	d3,d4			; d4=Y2
	sub.w	d1,d4			; d4=DY
	beq.s	.horiz			; kelle chance c'est horizontale !!!
	bpl.s	.tab_max		; si DY>0,on cherche XMAX
	move.l	a0,a3			; pointe sur tableau XMIN
	exg.l	d1,d3			; echange Y1 et Y2
	exg.l	d0,d2			; echange X1 et X2
	neg.w	d4			; DY>0
.tab_max
	move.w	d2,d5			; d5=X2
	sub.w	d0,d5			; d5=DX
	beq.s	.verti			; ben dit donc, c'est verticale !!!
	add.w	d1,d1			; Y1*2
	add.w	d1,a3			; on est sur la bonne ligne du tablo
	ext.l	d5			; rien dans le poids fort...
	asl.l	#7,d5			; DX multiplie par 128 ( 2^7 )
	divs	d4,d5			; (DX*128)/DY = pente
	ext.l	d5			; rien ds le poids fort.
	swap	d5			; ca revient a un asl.l #9,d5
	asr.l	#7,d5			; partie entiere ds le poid faible
	swap	d5			; virgule ds le poid fort pour le ADDX
 	subq.w	#1,d4
.mk_line
	move.w	d0,(a3)+		; on mets le X dans XMIN ou XMAX...
	addx.l	d5,d0			; HOP !!! c magique
	dbf	d4,.mk_line
	rts
.verti
	add.w	d1,d1			; Y1*2
	add.w	d1,a3			; on est a la bonne adresse
.mk_vert
	move.w	d0,(a3)+		; nouvel XMIN/XMAX
	dbf	d4,.mk_vert
	rts				; c'est fini !
.horiz
	add.w		d1,d1		; Y*2
	cmp.w		d0,d2		; le quel est le plus grand des 2 ?
	bge.s		.horiz_no_swap	; si c bon, c bon...
	exg.l		d0,d2		; boum ...
.horiz_no_swap	
	move.w	d0,(a0,d1.w)		;  XMIN
	move.w	d2,(a1,d1.w)		;  XMAX
	rts

*******************
* ROUTINE CLAVIER *
*******************

KEYBOARD	
	rte


***************************************************************************
* ZONE DATA *
*************

				DATA

OBJECT_1:
		DC.W		0
		DC.W		3
		DC.W		160,0,319,99,160,199,0,99
	
PALETTE:
		DC.W		$000,$777,$007,$555,$444,$333,$222,$111
		DC.W		$007,$006,$005,$004,$003,$002,$001,$070

; MASK DE DEPART ET D'ARRIVE POUR UN BLOCK

MASK:
	DC.W	$FFFF,$0000
	DC.W	$7FFF,$8000
	DC.W	$3FFF,$C000
	DC.W	$1FFF,$E000
	DC.W	$0FFF,$F000
	DC.W	$07FF,$F800
	DC.W	$03FF,$FC00
	DC.W	$01FF,$FE00
	DC.W	$00FF,$FF00
	DC.W	$007F,$FF80
	DC.W	$003F,$FFC0
	DC.W	$001F,$FFE0
	DC.W	$000F,$FFF0
	DC.W	$0007,$FFF8
	DC.W	$0003,$FFFC
	DC.W	$0001,$FFFE


***************************************************************************
* ZONE BSS *
************

		BSS

OLD_SHIFTER:
	DS.W		19
	
; SAUVEGARDE DES INTERUPTIONS

OLD_VBL:					; ancien vecteur VBL
	DS.L		1
OLD_KBD:					; ancien vecteur clavier
	DS.L		1
OLD_MFP:					; ancien vecteur MFP
	DS.B		4

FLAG: 	
	DS.B		1			; flag pour le clavier
		EVEN
ADR_SCR:					; adresse actuelle de l'ecran
	DS.L		1
SCREEN:	
	DS.B		160*200+256		; buffer d'ecran

