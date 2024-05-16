;*****************************************************************************
;Nom    : DEPACKER
;Version: 2.0
;Auteur : The Beyonder
;Groupe : The Black Cats
;Date	: 08/05/92
;Hello  : SHARPOX,SHAM,CONAN,DOC PROF and MLM
; Programme pour dÇcompacter les donnÇes et les exÇcutables
; Formats reconnus par la 2.0 :
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< EXECUTABLE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  
;	ICE 1.0 1.11 2.1 2.2 2.3 2.4
;	POMPEY
;	AUTOMATION 2.31 2.41
;	ATOMIK 3.3
;	FIRE 1.0 2.0
;	HAPPY
;	M-PACKER (un seul fichier connu ! C'est vraiment histoire de se trouer le cul)
;	JEK 1.2 1.3 1.3U(!) 2.3 1.6
;	JAM 1.0 1.4 2.3 3 4
;	SPACKER+ 
;	SPACKER 2
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< DONNEES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  
;	ICE 1.0 1.11 2.2 2.3 2.4
;	ATOMIK 3.3 3.5 (algos images Ö vÇrifier ...)
;	FIRE 1.0 2.0
;	JEK 1.6 2.3
;	JAM 1.0 1.4 3 4
;	SPACKER 2
;	AUTOMATION 2.31 2.4
; impossible :	data ice 2.1 voir rem dans le source
;		data jek 1.3 pas de routines + meme id que 2.3
;*****************************************************************************

RTS	equ	$4E75
NOP	equ	$4E71
JMP	equ	$4EF9
	
	TEXT
	

;* initialisations ***********************************************************
	movea.l	4(a7),a5
	move.l	12(a5),d0 
	add.l	20(a5),d0 
	add.l	28(a5),d0 
	add.l	#$100,d0	
	move.l	32(a5),DTA
	
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp) 
	move.w	#$4A,-(sp)
	trap	#1
	lea	12(sp),sp


	;malloc
	pea	-1.L
	move.w	#$48,-(sp)
	trap	#1
	subi.l	#10000,d0	;laisse un peu de place pour le systäme
	move.l	d0,MAX
	move.l	d0,2(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ADR_BUF
	add.l	MAX,d0
	move.l	d0,a7		;pile en haut de la mÇmoire (pourquoi ?! mais pour le happy de merde,...................... connard (avec l'accent de Bigard sioux-play) )
	subi.l	#4096,MAX	;laisse 4 ko de pile ( duracell si possible,j'aimerai qu'ca fonctionne longtemps)
	bsr	INITAES

	lea	SAVE_DIR,a6
	bsr	GETDIR		;rÇcupäre dir initial

;******************************************	
;prÇsente
;	
DEBUT	lea	INFO_BOX,a0
	move.w	#1,d0
	bsr	ALERT
	cmp.w	#2,d0		
	bgt	FIN		;QUIT -> FIN
	blt.s	Encore		;CONTINUE -> Encore
	;sinon boite d'info
	lea	INFO_BOX2,a0	
	move.w	#1,d0
	bsr	ALERT
	bra.s	DEBUT
	
Encore	lea	FICHIER,a6
	lea	MASQUE,a5
	lea	DEFAUT,a4
	bsr	FILESELECT
	tst.l	d0
	bne.s	DEBUT		;si on clique sur annuler on retourne au debut
	
	bsr	EXIST		;le fichier choisi existe-t-il ?
	tst.l	d0	
	bne	NOT_EXIST	;non => not_exist

	movea.l	DTA,a0		
	move.l	$1A(a0),d0	;d0=taille du fichier
	cmp.l	MAX,d0		;on a la place pour le charger ?
	ble.s	LOAD

	lea	TAILLE_BOX,a0	;non => alertbox
	bra	COMMUN	

LOAD	lea	LONG_PACK,a0
	bsr	CONVERT
	lea	TAILLE,a4	;oui
	move.l	d0,(a4)
	move.l	ADR_BUF,a5
	bsr	LECTURE		;chargement
	tst.l	d0		;erreur ?
	beq.s	DEPACK		;non alors on va dÇpacker
	
	lea	ERR_LEC_BOX,a0	;erreur de chargement
	lea	DEFAUT,a1	;rajoute nom du fichier dans la boite
	lea	ERR_LEC_BOX2,a2
	moveq	#11,d0
.2	move.b	(a1)+,(a2)+
	beq.s	.3
	dbf	d0,.2
	bra	COMMUN
.3	subq.l	#1,a2
.4	move.b	#" ",(a2)+
	dbf	d0,.4
	bra	COMMUN
	
DEPACK	move.l	ADR_BUF,a1		;vÇrifie type du packer
	lea	INFO_PACKER,a0
	moveq	#0,d0
.ENCORE	move.l	(a0),d3
	beq.s	INCONNU
	move.l	4(a0),d2
	bpl.s	.SUITE
	add.l	TAILLE,d2
.SUITE	moveq	#3,d1
.BOUCLE	lsl.l	#8,d4
	move.b	0(a1,d2.l),d4
	addq.l	#1,d2
	dbf	d1,.BOUCLE	
	cmp.l	d4,d3
	beq.s	.TROUVE
	addq.l	#8,d0
	lea	12(a0),a0
	bra.s	.ENCORE
.TROUVE	add.l	#TYPES,d0
	move.l	d0,METTYPE+2
	move.l	8(a0),a0
	jmp	(a0)
INCONNU	lea	FORMAT_INCONNU,a0
	bra	COMMUN
	
HAPPY	move.w	#JMP,$24A(a1)
	move.l	#RETOUR,$24C(a1)
	bra	SPECIAL

JEK1_2	move.w	#JMP,$A8(a1)
	move.l	#RETOUR,$AA(a1)
	bra	SPECIAL

JEK1_3	move.w	#JMP,$AC(a1)
	move.l	#RETOUR,$AE(a1)
	bra	SPECIAL	

JAM4	move.w	#JMP,$9C(a1)
	move.l	#RETOUR,$9E(a1)
	bra	SPECIAL
	
JAM3	move.w	#JMP,$9A(a1)
	move.l	#RETOUR,$9C(a1)
	bra	SPECIAL
	
SPACKER	move.w	#JMP,$88(a1)
	move.l	#.RETOUR,$8A(a1)
	bsr	VERIFPALETTE
	bsr	CREEPAGE		;
	pea	PAGEBASE		;comme avec le systäme
	pea	0.l		;
	jmp	$1C(a1)	
.RETOUR	move.l	$80.w,-(sp)	;c'est ici que cet enculÇ de mes deux (Çnormes!) sauvegarde sa pile utilisateur ... 
	move.w	#$20,-(sp)	;et quand on sait que ses variables sont des vecteurs d'exceptions on peut me trouver poli !!!
	trap	#1
	addq.l	#6,sp
	bsr	CHERCHE
	move.l	a1,CREATE+2
	bsr	CALCULTAILLE
	move.l	d0,TAILLE
	bra	NEW

SPACKER2	move.w	#JMP,$3E(a1)
	move.l	#RETOUR,$40(a1)
	bra	SPECIAL

AUTOMATION
	move.w	#JMP,$BC(a1)
	move.l	#RETOUR,$BE(a1)
	bra	SPECIAL
	
POMPEY	lea	$1C(a1),a0
	move.l	a0,6(a0)		;reloge
	move.w	#JMP,$10C(a0)
	move.l	#RETOUR,$10E(a0)
	bra	SPECIAL
	
AUTOMATIQUE
	move.l	a1,a0
.1	cmp.b	#$61,(a0)+
	bne.s	.1
	cmp.b	#$00,(a0)+
	bne.s	.1
	move.w	#JMP,2(a0)
	move.l	#RETOUR,4(a0)

SPECIAL	move.l	a7,PILE
	bsr	VERIFPALETTE
	bsr	CREEPAGE		;
	pea	PAGEBASE		;comme avec le systäme
	pea	0.l			;
	jmp	$1C(a1)	
RETOUR	move.l	PILE,a7
	bsr	CHERCHE
	move.l	a1,CREATE+2
	bsr	CALCULTAILLE
	move.l	d0,TAILLE
	bra	NEW

*si automatique ne marche pas remettre cette routine ! Test Ö refaire	
*MPACKER	pea	$1FC(a1)
*	pea	$36(a1)
*	move.l	$1F8(a1),TAILLE
*	move.w	#RTS,$64(a1)
*	bra	DEPACK2


	;donnÇes
DATAICE2.2.3.4
	move.l	8(a1),TAILLE
	pea	(a1)
	pea	ice_decrunch
	move.l	a1,a0
	bra	DEPACK2
	
DATAATM3.3
	move.l	4(a1),TAILLE
	pea	(a1)
	pea	atomik3.3
	move.l	a1,a0
	bra	DEPACK2
	
DATASP20
	move.l	12(a1),TAILLE
	pea	(a1)
	pea	sp20
	move.l	a1,a0
	bra	DEPACK2

DATAATM3.5
	move.l	4(a1),TAILLE
	pea	(a1)
	pea	atomik3.5
	move.l	a1,a0
	bra	DEPACK2

	
DATAFIRE1.0
	move.l	a1,a0
	add.l	TAILLE,a1
	move.l	-8(a1),d1
	move.l	TAILLE,d0
	move.l	d1,TAILLE
	pea	120(a0)
	pea	firepack
	bra	DEPACK2
	
DATAICE1.0
	move.l	a1,a0
	add.l	TAILLE,a1
	move.l	-8(a1),d1
	move.l	TAILLE,d0
	move.l	d1,TAILLE
	pea	(a0)
	pea	ice1_0
	bra	DEPACK2
	
DATAJEK1.6
	move.l	a1,a0
	add.l	TAILLE,a0
	move.l	-8(a0),TAILLE
	subq.l	#4,a0
	move.l	a0,d6
	pea	(a1)
	pea	jek1.6
	bra	DEPACK2
	
DATAJEK2.3
	move.l	a1,a0
	add.l	TAILLE,a1
	move.l	-8(a1),d1
	move.l	TAILLE,d0
	move.l	d1,TAILLE
	pea	(a0)
	pea	jek2_3
	bra	DEPACK2
	
DATAFIRE2.0
	move.l	8(a1),TAILLE
	pea	(a1)
	pea	firepack2
	move.l	a1,a0
	bra	DEPACK2

DATALZH	move.l	a1,d0
	add.l	TAILLE,d0
	addq.l	#8,d0
	andi.l	#-2,d0
	move.l	d0,a6
	move.l	4(a1),TAILLE
	move.l	a1,a5
	pea	(a6)
	pea	LZH
	bra	DEPACK2
	
DATALZW	move.l	a1,a0
	move.l	a1,d0
	add.l	TAILLE,d0
	addq.l	#8,d0
	andi.l	#-2,d0
	move.l	d0,a1
	move.l	4(a0),TAILLE
	pea	(a1)
	pea	LZW
	bra	DEPACK2

DATAV2	move.l	a1,a0
	move.l	a1,d0
	add.l	TAILLE,d0
	addq.l	#8,d0
	andi.l	#-2,d0
	move.l	d0,a1
	move.l	4(a0),TAILLE
	pea	(a1)
	pea	V2
	bra	DEPACK2
	
	
DEPACK2	move.l	(sp)+,DEPACK3+2
	move.l	(sp)+,CREATE+2

	movem.l	d0/a0,-(sp)
	move.l	TAILLE,d0
	move.l	CREATE+2,a0
	sub.l	ADR_BUF,a0
	add.l	a0,d0
	cmp.l	MAX,d0
	movem.l	(sp)+,d0/a0	;rappel : un movem ne touche pas aux flags
	ble.s	DEPACK3
	lea	TAILLE_BOX2,a0
	bra	COMMUN
	
DEPACK3	jsr	$12345678

NEW	lea	LONG_DEPACK,a0
	move.l	TAILLE,D0
	bsr	CONVERT
METTYPE	move.l	#$12345678,a0
	lea	TYPE,a1
	moveq	#8-1,d0
.1	move.b	(a0)+,(a1)+
	dbf	d0,.1
	
	lea	INFO_TYPE,a0
	move.w	#1,d0
	bsr	ALERT	
	cmp.w	#2,d0
	beq	Encore
	bgt	FIN
SAUVE	lea	FICHIER,a6
	lea	MASQUE,a5
	lea	DEFAUT,a4
	bsr	FILESELECT
	tst.l	d0
	bne	DEBUT		;annuler on retourne au dÇbut
	
	clr.w	-(sp)
	pea	TAMPON
	move.w	#$36,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	TAMPON,d0
	mulu	#1024,d0
	move.l	d0,TAMPON
	
	
	bsr	EXIST
	tst.l	d0	
	bne.s	.1
	move.l	DTA,a0
	move.l	$1A(a0),d0
	add.l	d0,TAMPON
	lea	EXISTDEJA_BOX,a0
	move.w	#1,d0
	bsr	ALERT
	cmp.w	#2,d0
	beq.s	SAUVE
	bgt	FIN
	bra.s	CREATE
	
.1	move.l	TAMPON,d0
	cmp.l	TAILLE,d0
	bgt.s	CREATE
	lea	TAILLE_BOX3,a0
	move.w	#1,d0
	bsr	ALERT
	cmp.w	#2,d0
	beq	ENCORE
	bgt.s	FIN
	bra	SAUVE
CREATE	movea.l	#$12345678,a5
	lea	TAILLE,a4
	bsr	CREATION
	lea	CREATION_OK,a0
	tst.l	d0
	beq.s	COMMUN
	lea	ERREUR_CREATION,a0
	move.w	#1,d0
	bsr	ALERT
	cmp.w	#1,d0
	beq	SAUVE
	cmp.w	#2,d0
	beq	Encore
	bra.s	FIN
NOT_EXIST
	lea	EXIST_BOX,a0
COMMUN	move.w	#1,d0
	bsr	ALERT
	cmp.w	#1,d0		;on recommence?
	beq	Encore
FIN	
; restaure dir
	lea	SAVE_DIR,a6
	pea	(a6)
	move.w	#$3B,-(sp)
	trap	#1
	addq.l	#6,sp
; restaure mem
	move.l	ADR_BUF,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr	EXITAES

	clr.w	-(sp)
	trap	#1


;vÇrification de la bonne adresse de la palette pour les TT
;regarde dans le premier kilo
VERIFPALETTE
	move.w	#1024-1,d0
.1	cmpi.b	#$FF,0(a1,d0.w)
	bne.s	.2
	cmpi.b	#$82,1(a1,d0.w)
	bne.s	.2
	cmpi.b	#$40,2(a1,d0.w)
	bne.s	.2
	clr.b	-1(a1,d0.w)
.2	dbf	d0,.1
	RTS

;crÇe la page de base
;entrÇe : a1 = adresse entete du fichier
CREEPAGE
	lea	PAGEBASE,a5
	move.l	a5,(a5)		;adr page de base
	move.l	a1,d0
	add.l	MAX,d0
	move.l	d0,4(a5)	;adr max
	move.l	a1,d0
	addi.l	#$1C,d0
	move.l	d0,8(a5)	;adr texte
	add.l	2(a1),d0
	move.l	2(a1),$C(a5)	;taille texte
	move.l	d0,$10(a5)	;adr DATA
	move.l	6(a1),$14(a5)	;taille DATA
	add.l	6(a1),d0
	move.l	d0,$18(a5)	;adr BSS
	move.l	d0,a4		;pour le pompey car le systäme fout l'adr du bss dans a4 (c'est un monde je vous jure !)
	move.l	$A(a1),$1C(a5)	;taille BSS
	;initialisation du BSS Ö zÇro
	move.l	d0,a0
	add.l	$1C(a5),d0
	bra.s	.0
.encore	clr.b	(a0)+
.0	cmp.l	d0,a0
	bne.s	.encore	
	RTS
	
;cherche entete du prg dÇpackÇ
;sortie a1=adr
CHERCHE	move.l	ADR_BUF,a1
	lea	2(a1),a1
.ENCORE	cmp.b	#$60,(a1)+
	bne.s	.ENCORE
	cmp.b	#$1A,(a1)
	bne.s	.ENCORE
	cmp.b	#0,1(a1)
	bne.s	.ENCORE
	lea	-1(a1),a1
	RTS
	
;calcul taille du fichier avec table de relocation
;entrÇe : a1 = adresse de l'entete
;sortie : d0 = taille
CALCULTAILLE
	move.l	$2(a1),d0	;taille texte
	add.l	$6(a1),d0	;+taille data
	add.l	$E(a1),d0	;+taille symbole
	addi.l	#$1C,d0		;+taille entete
	addq.l	#1,d0		;correction...
	andi.b	#$FE,d0		;...nb impair
	lea	(a1,d0.l),a1
	move.l	a1,a0
	tst.l	(a0)+
	beq.s	.FINI
.ENCORE	tst.b	(a0)+
	bne.s	.ENCORE
.FINI	suba.l	a1,a0
	add.l	a0,d0
	RTS		
	

EXIST	clr.w	-(sp)
	pea	(a6)	
	move.w	#$4E,-(sp)
	trap	#1
	addq.l	#8,sp
	RTS

	
MFREE	move.l	ADR_BUF,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	RTS
	
ALERT	move.w	#52,CONTROL
	move.w	#1,CONTROL+2
	move.w	#1,CONTROL+4
	move.w	#1,CONTROL+6
	clr.w	CONTROL+8
	move.w	d0,INT_IN
	move.l	a0,ADDR_IN
	jsr	AES
	move.w	INT_OUT,d0
	RTS

;met d0.l en dÇcimal dans le buffer pointÇ par a0
CONVERT movem.l	d0-d1/a0-a1,-(sp)
	lea	6(a0),a1
.2	move.l	d0,d1
	divu	#10,d1
	move.w	d1,d0
	andi.l	#$FFFF,d0
	swap	d1
	addi.b	#"0",d1
	move.b	d1,-(a1)	
	cmpi.w	#0,d0
	bne.s	.2
.3	cmp.l	a0,a1
	beq.s	.4
	move.b	#"0",-(a1)
	bra.s	.3
.4	movem.l	(sp)+,d0-d1/a0-a1
	RTS


;chargement,sauvegarde et crÇation de fichier
;LECTURE,ECRITURE,CREATION
;entrÇe	:	a6 = adresse du nom du fichier
;		a5 = adresse du buffer
;		a4 = adresse de la taille du fichier
LECTURE	clr.w	-(sp)		;mode=lecture
	pea	(a6)
	move.w	#$3D,-(sp)	;open
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi.s	LECTURE3
	move.l	d0,d7		;d7=handle

	pea	(a5)
	move.l	(a4),-(sp)
	move.w	d7,-(sp)
	move.w	#$3F,-(sp)	;read
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi.s	LECTURE3
	
LECTURE2
	cmp.l	(a4),d0
	bne.s	LECTURE3
	move.w	d7,-(sp)
	move.w	#$3E,-(sp)	;close
	trap	#1
	addq.l	#4,sp
	RTS

LECTURE3
	moveq	#-1,d0	
	RTS
	
CREATION
	clr.w	-(sp)		
	pea	(a6)
	move.w	#$3C,-(sp)	;create
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi.s	LECTURE3
	move.l	d0,d7		;d7=handle

	pea	(a5)
	move.l	(a4),-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)	;write
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi.s	LECTURE3
	bra.s	LECTURE2



FILESELECT
;a6=zone oó sera mise le chemin et le nom : 64 octets min.
;a5=masque : 16 octets
;a4=nom du fichier par dÇfaut : 16 octets
;crÇation du nom du fichier avec le lecteur et le chemin
	
	movem.l	d1/a4-a6,-(sp)
	bsr	GETDIR
	moveq	#0,d0
.1	addq.b	#1,d0
	tst.b	1(a6,d0.w)
	bne.s	.1
	move.b	#"\",1(a6,d0.w)		;place "\"
	moveq	#0,d1	
.2	addq.b	#1,d0
	addq.b	#1,d1
	move.b	-1(a5,d1.w),1(a6,d0.w)	;recopie le masque derriäre
	bne.s	.2			;le chemin

;AES:fsel_input 
	move.w	#90,CONTROL
	clr.w	CONTROL+2
	move.w	#2,CONTROL+4
	move.w	#2,CONTROL+6
	clr.w	CONTROL+8
	move.l	a6,ADDR_IN
	move.l	a4,ADDR_IN+4
	bsr	AES
	tst.w	int_out+2
	bne.s	.8		;cliquÇ sur annuler ?
	moveq	#-1,d0		;oui alors erreur d0<0
	bra.s	.6
.8	move.l	a6,-(sp)	;sauve adresse du directory
	move.b	(a6),d0
	andi.w	#$FF,d0
	subi.b	#$41,d0
	move.w	d0,-(sp)
	move.w	#$E,-(sp)
	trap	#1
	addq.l	#4,sp
.7	tst.b	(a6)+		
	bne.s	.7		;cherche fin de chaine
.3	cmpi.b	#"\",-(a6)	;cherche dernier "\"
	bne.s	.3
	clr.b	(a6)		;met fin de chaine
	move.w	#$3B,-(sp)
	trap	#1		;positionne nouveau dir
	addq.l	#6,sp
	move.b	#"\",(a6)+	;repositionne le "\"
	lea	MASQUE,a5
.4	move.b	(a6),(a5)+	;garde nouveau masque
	move.b	(a4)+,(a6)+	;fabrique nom du fichier
	bne.s	.4
.5	move.b	(a6)+,(a5)+	;termine de recopier le masque
	bne.s	.5		;si long(masque)>long(filename)
 	moveq	#0,d0		;pas d'erreur
.6	movem.l	(sp)+,d1/a4-a6
	RTS

;init AES
INITAES	move.w	#10,CONTROL
	clr.w	CONTROL+2
	move.w	#1,CONTROL+4
	clr.w	CONTROL+6
	clr.w	CONTROL+8
 	bra.s	AES
	RTS

;exit AES
EXITAES	move.l	#$130000,CONTROL
	move.w	#1,CONTROL+4
	clr.l	CONTROL+6
	bra.s	AES
	RTS
	
AES	move.l	#AESPB,d1
	move.w	#$C8,d0
	trap	#2
	RTS
	
	
	
;fabrique chemin avec le lecteur
;a6 pointe sur la zone de sauvegarde
GETDIR	move.w	#$19,-(sp)
	trap	#1			;rÇcupäre lecteur courant
	addq.l	#2,sp
	addi.b	#'A',d0
	move.b	d0,(a6)			;place lecteur
	move.b	#":",1(a6)		;place ":"

	clr.w	-(sp)			;lecteur courant
	pea	2(a6)			;adresse du buffer
	move.w	#$47,-(sp)	
 	trap	#1			;place chemin courant
	addq.l	#8,sp
	RTS


;Unpacking routine of PACK-ICE
;a0 = Adress of packed data
;routine de ICE 2.3 car 2.4 buggÇ pour l'algo spÇcial image
;marche avec 2.2 mais pas 2.1 
ice_decrunch
      LINK    A3,#-$78
      MOVEM.L A0-A6/D0-D7,-(A7) 
      LEA     120(A0),A4
      MOVEA.L A4,A6 
      BSR.S   L0009 
      BSR.S   L0009 
      LEA     -8(A0,D0.L),A5
      BSR.S   L0009 
      MOVE.L  D0,(A7) 
      ADDA.L  D0,A6 
      MOVEA.L A6,A1 
      MOVEQ   #$77,D0 
L0000:MOVE.B  -(A1),-(A3) 
      DBF     D0,L0000
      MOVEA.L A6,A3 
      MOVE.B  -(A5),D7
      BSR.S   L000A 
      MOVEA.L A3,A6 
      BSR.S   L000E 
      BCC.S   L0005 
      MOVE.W  #$F9F,D1
      BSR.S   L000E 
      BCC.S   L0001 
      MOVEQ   #$F,D0
      BSR.S   L0010 
L0001:MOVE.W  D1,D7 
L0002:MOVEQ   #3,D6 
L0003:MOVE.W  -(A3),D4
      MOVEQ   #3,D5 
L0004:ADD.W   D4,D4 
      ADDX.W  D0,D0 
      ADD.W   D4,D4 
      ADDX.W  D1,D1 
      ADD.W   D4,D4 
      ADDX.W  D2,D2 
      ADD.W   D4,D4 
      ADDX.W  D3,D3 
      DBF     D5,L0004
      DBF     D6,L0003
      MOVEM.W D0-D3,(A3)
      DBF     D7,L0002
L0005:MOVEM.L (A7),A0-A3/D0-D7
L0006:MOVE.B  (A4)+,(A0)+ 
      SUBQ.L  #1,D0 
      BNE.S   L0006 
      MOVEQ   #$77,D0 
L0007:MOVE.B  -(A3),-(A6) 
      DBF     D0,L0007
L0008:MOVEM.L (A7)+,A0-A6/D0-D7 
      UNLK    A3
      RTS 
L0009:BRA.S   L0013 
L000A:BSR.S   L000E 
      BCC.S   L000D 
      MOVEQ   #0,D1 
      BSR.S   L000E 
      BCC.S   L000C 
      LEA     L001D(PC),A1
      MOVEQ   #4,D3 
L000B:MOVE.L  -(A1),D0
      BSR.S   L0010 
      SWAP    D0
      CMP.W   D0,D1 
      DBNE    D3,L000B
      ADD.L   20(A1),D1 
L000C:MOVE.B  -(A5),-(A6) 
      DBF     D1,L000C
L000D:CMPA.L  A4,A6 
      BGT.S   L0015 
      RTS 
L000E:ADD.B   D7,D7 
      BNE.S   L000F 
      MOVE.B  -(A5),D7
      ADDX.B  D7,D7 
L000F:RTS 
L0010:MOVEQ   #0,D1 
L0011:ADD.B   D7,D7 
      BNE.S   L0012 
      MOVE.B  -(A5),D7
      ADDX.B  D7,D7 
L0012:ADDX.W  D1,D1 
      DBF     D0,L0011
      RTS 
L0013:MOVEQ   #3,D1 
L0014:LSL.L   #8,D0 
      MOVE.B  (A0)+,D0
      DBF     D1,L0014
      RTS 
L0015:LEA     L001E(PC),A1
      MOVEQ   #3,D2 
L0016:BSR.S   L000E 
      DBCC    D2,L0016
      MOVEQ   #0,D4 
      MOVEQ   #0,D1 
      MOVE.B  1(A1,D2.W),D0 
      EXT.W   D0
      BMI.S   L0017 
      BSR.S   L0010 
L0017:MOVE.B  6(A1,D2.W),D4 
      ADD.W   D1,D4 
      BEQ.S   L0019 
      LEA     L001F(PC),A1
      MOVEQ   #1,D2 
L0018:BSR.S   L000E 
      DBCC    D2,L0018
      MOVEQ   #0,D1 
      MOVE.B  1(A1,D2.W),D0 
      EXT.W   D0
      BSR.S   L0010 
      ADD.W   D2,D2 
      ADD.W   6(A1,D2.W),D1 
      BPL.S   L001B 
      SUB.W   D4,D1 
      BRA.S   L001B 
L0019:MOVEQ   #0,D1 
      MOVEQ   #5,D0 
      MOVEQ   #-1,D2
      BSR.S   L000E 
      BCC.S   L001A 
      MOVEQ   #8,D0 
      MOVEQ   #$3F,D2 
L001A:BSR.S   L0010 
      ADD.W   D2,D1 
L001B:LEA     2(A6,D4.W),A1 
      ADDA.W  D1,A1 
      MOVE.B  -(A1),-(A6) 
L001C:MOVE.B  -(A1),-(A6) 
      DBF     D4,L001C
      BRA     L000A 
      DC.B   $7F,$FF,$00,$0E,$00,$FF,$00,$07
      DC.B   $00,$07,$00,$02,$00,$03,$00,$01
      DC.B   $00,$03,$00,$01
L001D:DC.B   $00,$00,$01,$0D,$00,$00,$00,$0E
      DC.B   $00,$00,$00,$07,$00,$00,$00,$04
      DC.B   $00,$00,$00,$01
L001E:DC.B   $09,$01,$00,$FF,$FF,$08,$04,$02
      DC.B   $01,$00
L001F:DC.B   $0B,$04,$07,$00,$01,$1F,$FF,$FF
      DC.B   $00,$1F
ende_ice_decrunch
;************************************************** end of unpacking routine


;decrunch source code of ATOMIK by ALTAIR	;je tiens a preciser
;A0=packed code		;que j'ai entierement
;call it by bsr		;ecris ce compacteur
			;environnement compris.
DEC_MARGE:	equ	$10	;min=0 , max=126 (pair!)
RESTORE_M:	equ	1	;argh j'ai plantÇ pendant
			;10 jours sur TOTAL RECALL
			;a cause de ca!!!!!
PIC_ALGO:	equ	1	;PIC_ALGO=1,RESTORE_M=0 ; lenght=$18e
atomik3.3
	movem.l	d0-a6,-(a7)	;PIC_ALGO=0,RESTORE_M=0 ; lenght=$146
	cmp.l	#"ATOM",(a0)+	;RESTORE_M=1 ; lenght=lenght+
	bne	no_crunched	;DEC_MARGE+$32
	move.l	(a0)+,d0
	move.l	d0,-(a7)
	lea	DEC_MARGE(a0,d0.l),a5
	ifne	RESTORE_M
	move.l	a5,a4
	lea	buff_marg(pc),a3
	moveq	#DEC_MARGE+9,d0
.save_m:	move.b	-(a4),(a3)+
	dbf	d0,.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.l	(a0)+,d0	
	lea	0(a0,d0.l),a6
	move.b	-(a6),d7
	bra	make_jnk
tablus:	lea	tablus_table(pc),a4
	moveq	#1,d6
	bsr.s	get_bit2
	bra.s	tablus2
decrunch:	moveq	#6,d6
take_lenght:	add.b	d7,d7
	beq.s	.empty1
.cont_copy:	dbcc	d6,take_lenght
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy:	move	d5,-(a7)
	bne.s	bigger
	lea	decrun_table2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2
	cmp	#5,d5
	blt.s	contus
	addq	#2,a7
	subq	#6,d5
	bgt.s	tablus
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4:	moveq	#1,d6
	bsr.s	get_bit2
tablus2:	move.b	0(a4,d5.w),-(a5)	
	bra.s	make_jnk
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	lea	decrun_table(pc),a4
cont:	moveq	#2,d6
	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d5,.copy_same
make_jnk:	moveq	#11,d6
	moveq	#11,d5
take_jnk:	add.b	d7,d7
	beq.s	empty
cont_jnk:	dbcc	d6,take_jnk
	bcs.s	next_cod
	sub	d6,d5
	bra.s	copy_jnk1
next_cod:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1
.next_cod1:	moveq	#2,d6
	bsr.s	get_bit2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5	
copy_jnk1:	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk:	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word:	cmp.l	a6,a0
.decrunch:	bne	decrunch
	cmp.b	#$80,d7
	bne.s	.decrunch
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	bsr.s	decod_picture
	endc
	ifne	RESTORE_M
	movem.l	(a7)+,a3-a4
	endc
	move.l	(a7)+,d0
	bsr	copy_decrun
	ifne	RESTORE_M
	moveq	#DEC_MARGE+9,d0
.restore_m:	move.b	-(a3),(a4)+
	dbf	d0,.restore_m
	endc
no_crunched:	movem.l	(a7)+,d0-a6
 	rts
empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	cont_jnk
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2:	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table:	dc.b	$60,$20,$10,$8
	ifne	PIC_ALGO
decod_picture:	move	-(a0),d7
	clr	(a0)
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.l),a1
	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	ifne	RESTORE_M
buff_marg:	dcb.b	DEC_MARGE+10,0
	endc


;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)

;ce depacker est indissociable du programme ATOMIK V3.5 tous les mecs
;qui garderons se source dans l'espoir de prendre de l'importance
;en se disant moi je l'ai et pas l'autre sont des lamers.

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
             
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

;call it by BSR DEPACK or JSR DEPACK but call it!

MODE:		EQU	1
;PIC_ALGO:	EQU	1	dÇjÖ dÇfini dans atomik 3.3
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	1

atomik3.5
	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	.not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	.buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	.take_type
.decrunch:	move	d3,d5
.take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,.take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	.get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	.get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	.get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	.decrun_table(pc),a4
	move	d5,d2
	bne.s	.bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	.word
.ho_kesako:	moveq	#3,d6
	bsr.s	.get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	.tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	.tst_end
.get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
.bigger:	moveq	#2,d6
.word:	bsr.s	.get_bit2
.contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	.get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	.get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	.get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	.get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	.get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	.tst_end
.make_jnk:	add.b	d7,d7
	bne.s	.not_empty2
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty2:	
	bcs.s	.string
	move.b	-(a6),-(a5)
.tst_end:	cmp.l	a5,a3
	bne.s	.make_jnk
	cmp.l	a6,a0
	beq.s	.work_done
.take_type:	moveq	#0,d6
	bsr	.get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	.get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	.make_jnk
.string:	bra	.decrunch
.work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	.decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	.copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
.not_packed:	movem.l	(a7)+,d0-a6
 	rts
.decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
.decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
.copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun2:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun2
	rts
	endc
	ifne	RESTORE_SPACE
.buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc




;********************************************* Unpackroutine von FIRE-PACK
; a0 = Pack-Adresse, d0 = LÑnge
firepack
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(a0,d0.l),a5	; a5 = Ende aller Daten
	bsr.s	getlongword	; Kenn-Langwort holen
	cmp.l	#'Fire',d7	; Kennung gefunden?
	bne.s	not_packed	; nein: nicht gepackt
	add.w	#120,a0		; Anfang entpackte Daten: hîher
	bsr.s	getlongword	; LÑnge holen
	move.l	d7,(sp)		; OriginallÑnge: spÑter nach d0
	lea	(a0,d7.l),a6	; a6 = neues Ende
				; a5 = Ende von Byte-Daten
	bsr.s	getlongword	; erstes Informationslangwort
	lea	tabellen(pc),a4	; a4 = Zeiger auf Datenbereich
	moveq	#1,d6
	swap	d6		; d6 = $10000
	moveq	#0,d5		; d5 = 0 (oberes Wort: immer 0!)

normal_bytes:
	bsr.s	get_1_bit
	bcc.s	test_if_end	; Bit %0: keine Daten
	moveq	#0,d1		; falls zu copy_direkt
	bsr.s	get_1_bit
	bcc.s	copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
;	lea.l	direkt_tab+16-tabellen(a4),a1	; ... siehe nÑchste Zeile
	move.l	a4,a1
	moveq	#3,d3
nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	get_d0_bits
	swap	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,nextgb		; ja: dann weiter Bits lesen
no_more:	add.l	16(a1),d1		; Anzahl der zu Åbertragenen Bytes
copy_direkt:
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,copy_direkt	; noch ein Byte
test_if_end:
	cmp.l	a0,a6		; Fertig?
	bgt.s	strings		; Weiter wenn Ende nicht erreicht
not_packed:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;************************** Unterroutinen: wegen Optimierung nicht am Schluû
getlongword:
	moveq	#3,d0
glw:	move.b	-(a5),d7
	ror.l	#8,d7
	dbf	d0,glw
	rts

; get_d0_bits: Siehe weiter unten
not_found:move.w	a5,d7
	btst	#0,d7
	bne.s	noteven
	move.l	-(a5),d7		; hole sonst ein weiters longword
	addx.l	d7,d7		; hole ein bit
;	addx.w	d1,d1		; und Åbernimm es
;	dbf	d0,hole_bit_loop	; bis alle bits geholt wurden
;	rts
	bra.s	on_d0

noteven:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
;	addx.w	d1,d1
;	dbf	d0,hole_bit_loop
;	rts
	bra.s	on_d0

get_1_bit:
	add.l	d7,d7		; hole ein bit
	beq.s	not_found2	; quellfeld leer
	rts
not_found2:
	move.w	a5,d7
	btst	#0,d7
	bne.s	noteven2
	move.l	-(a5),d7		; hole sonst ein weiters longword
	addx.l	d7,d7		; hole ein bit
	rts
noteven2:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts

get_d0_bits:
	moveq	#0,d1		; ergebnisfeld vorbereiten
hole_bit_loop:
	add.l	d7,d7		; hole ein bit
	beq.s	not_found		; quellfeld leer
on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,hole_bit_loop	; bis alle bits geholt wurden
	rts
;************************************ Ende der Unterroutinen


strings:
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	get_d0_bits
	subq.w	#1,d1
	bmi.s	gleich_morestring	; %00
	beq.s	length_2		; %01
	subq.w	#1,d1
	beq.s	length_3		; %10
	bsr.s	get_1_bit
	bcc.s	bitset		; %110
	bsr.s	get_1_bit
	bcc.s	length_4		; %1110
	bra.s	length_5		; %1111

get_short_offset:
	moveq	#1,d0
	bsr.s	get_d0_bits	; d1:  0,  1,  2,  3
	subq.w	#1,d1
	bpl.s	contoffs
	moveq	#0,d0		; Sonderfall
	rts

get_long_offset:
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	get_d0_bits	; d1:  0,  1,  2,  3
contoffs:	add.w	d1,d1		; d1:  0,  2,  4,  6
	add.w	d1,d1		; d1:  0,  4,  8, 12
	movem.w	offset_table-tabellen(a4,d1),d0/d5
	bsr.s	get_d0_bits	; 4, 8, 12 oder 16 Bits lesen
	add.l	d5,d1
	rts


gleich_morestring:			; %00
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	get_d0_bits	; d1:  0,  1,  2,  3
	subq.w	#1,d1
	bmi.s	gleich_string	; %0000

	add.w	d1,d1		; d1:      0,  2,  4
	add.w	d1,d1		; d1:      0,  4,  8
	movem.w	more_table-tabellen(a4,d1),d0/d2
	bsr.s	get_d0_bits
	add.w	d1,d2		; d2 = StringlÑnge
	bsr.s	get_long_offset
	move.w	d2,d0		; d0 = StringlÑnge
	bra.s	copy_longstring

bitset:	moveq	#2,d0		; %110
	bsr.s	get_d0_bits
	moveq	#0,d0
	bset	d1,d0
	bra.s	put_d0

length_2:	moveq	#7,d0		; %01
	bsr.s	get_d0_bits
	moveq	#2-2,d0
	bra.s	copy_string

length_3:	bsr.s	get_short_offset	; %10
	tst.w	d0
	beq.s	put_d0		; 0 ablegen
	moveq	#3-2,d0
	bra.s	copy_string

length_4:	bsr.s	get_short_offset	; %1110
	tst.w	d0
	beq.s	vorgÑnger_kopieren
	moveq	#4-2,d0
	bra.s	copy_string

length_5:	bsr.s	get_short_offset	; %1111
	tst.w	d0
	beq.s	put_ff
	moveq	#5-2,d0
	bra.s	copy_string


put_ff:	moveq	#-1,d0
	bra.s	put_d0

vorgÑnger_kopieren:
	move.b	(a6),d0
;	bra.s	put_d0

put_d0:	move.b	d0,-(a6)
	bra.s	backmain


gleich_string:
	bsr.s	get_long_offset	; Anzahl gleicher Bytes lesen
	beq.s	backmain		; 0: zurÅck
	move.b	(a6),d0
copy_gl:	move.b	d0,-(a6)
	dbf	d1,copy_gl
	sub.l	d6,d1
	bmi.s	backmain
	bra.s	copy_gl

copy_longstring:
	subq.w	#2,d0		; StringlÑnge - 2 (wegen dbf)
copy_string:			; d1 = Offset, d0 = Anzahl Bytes -2
	lea.l	2(a6,d1.l),a1	; Hier stehen die Originaldaten
	add.w	d0,a1		; dazu die StringlÑnge-2
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d0,dep_b		; und noch ein Mal
backmain:	bra	normal_bytes	; Jetzt kommen wieder normale Bytes


direkt_tab:
	dc.l	$03ff0009,$00070002,$00030001,$00030001 ; Anzahl 1-Bits
tabellen:	dc.l	    15-1,      8-1,      5-1,      2-1  ; Anz. Bytes

offset_table:
	dc.w	 3,             0
	dc.w	 7,          16+0
	dc.w	11,      256+16+0
	dc.w	15, 4096+256+16+0
more_table:
	dc.w	3,       5
	dc.w	5,    16+5
	dc.w	7, 64+16+5
;*************************************************** Ende der Unpackroutine


;********************************************* Unpackroutine von FIRE-PACK
; Eingabe: a0 = Adresse gepackter Daten

firepack2
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	; a4 = Anfang entpackte Daten
	move.l	a4,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'FIRE',d0	; Kennung gefunden?
	bne.s	.not_packed
	bsr.s	.getinfo		; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	.getinfo		; ungepackte LÑnge holen (original)
	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a1
	moveq	#119,d0		; 120 Bytes hinter entpackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d0,.save
	move.l	a6,a3		; merken fÅr spÑter

	move.b	-(a5),d7		; erstes Informationsbyte
	lea	.tabellen(pc),a2	; a2 = Zeiger auf Datenbereich
	moveq	#1,d6
	swap	d6		; d6 = $10000
	moveq	#0,d5		; d5 = 0 (oberes Wort: immer 0!)

.normal_bytes:
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq	#0,d1		; falls zu .copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	 ; Bitfolge: %10: 1 Byte direkt kop.
;	lea.l	.direkt_tab+16-.tabellen(a2),a0 ; ...siehe nÑchste Zeile
	move.l	a2,a0
	moveq	#3,d3
.nextgb:	move.l	-(a0),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	16(a0),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:
	cmp.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht

	movem.l	(sp),d0-a2/a5	; hole nîtige Register
.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		; um Åberschriebenen Bereich
.rest	move.b	-(a5),-(a3)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

;************************** Unterroutinen: wegen Optimierung nicht am Schluû
.getinfo:
	moveq	#3,d1
.glw:	rol.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.glw
	rts


.get_1_bit:
	add.b	d7,d7		; hole ein Bit
	beq.s	.no_bit_found
	rts
.no_bit_found:
	move.b	-(a5),d7
	addx.b	d7,d7
	rts

.get_d0_bits:
	moveq	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:
	add.b	d7,d7		; hole ein Bit
	beq.s	.not_found	; quellfeld leer
.on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts

.not_found:
	move.b	-(a5),d7		; hole sonst ein weiters longword
	addx.b	d7,d7		; hole ein Bit
	bra.s	.on_d0

;************************************ Ende der Unterroutinen


.strings:
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits
	subq.w	#1,d1
	bmi.s	.gleich_morestring	; %00
	beq.s	.length_2 	; %01
	subq.w	#1,d1
	beq.s	.length_3 	; %10
	bsr.s	.get_1_bit
	bcc.s	.bitset		; %110
	bsr.s	.get_1_bit
	bcc.s	.length_4 	; %1110
	bra.s	.length_5 	; %1111

.get_short_offset:
	moveq	#1,d0
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
	subq.w	#1,d1
	bpl.s	.contoffs
	moveq	#0,d0		; Sonderfall
	rts

.get_long_offset:
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
.contoffs add.w	d1,d1		; d1:  0,  2,  4,  6
	add.w	d1,d1		; d1:  0,  4,  8, 12
	movem.w	.offset_table-.tabellen(a2,d1),d0/d5
	bsr.s	.get_d0_bits	; 4, 8, 12 oder 16 Bits lesen
	add.l	d5,d1
	rts


.gleich_morestring: 		; %00
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
	subq.w	#1,d1
	bmi.s	.gleich_string	; %0000

	add.w	d1,d1		; d1:	 0,  2,  4
	add.w	d1,d1		; d1:	 0,  4,  8
	movem.w	.more_table-.tabellen(a2,d1),d0/d2
	bsr.s	.get_d0_bits
	add.w	d1,d2		; d2 = StringlÑnge
	bsr.s	.get_long_offset
	move.w	d2,d0		; d0 = StringlÑnge
	bra.s	.copy_longstring

.bitset:	moveq	#2,d0		; %110
	bsr.s	.get_d0_bits
	moveq	#0,d0
	bset	d1,d0
	bra.s	.put_d0

.length_2:
	moveq	#7,d0		; %01
	bsr.s	.get_d0_bits
	moveq	#2-2,d0
	bra.s	.copy_string

.length_3:
	bsr.s	.get_short_offset	; %10
	tst.w	d0
	beq.s	.put_d0		; 0 ablegen
	moveq	#3-2,d0
	bra.s	.copy_string

.length_4:
	bsr.s	.get_short_offset	; %1110
	tst.w	d0
	beq.s	.vorgÑnger_kopieren
	moveq	#4-2,d0
	bra.s	.copy_string

.length_5:
	bsr.s	.get_short_offset	; %1111
	tst.w	d0
	beq.s	.put_ff
	moveq	#5-2,d0
	bra.s	.copy_string


.put_ff:	moveq	#-1,d0
	bra.s	.put_d0

.vorgÑnger_kopieren:
	move.b	(a6),d0
;	bra.s	.put_d0

.put_d0:	move.b	d0,-(a6)
	bra.s	.backmain


.gleich_string:
	bsr.s	.get_long_offset	; Anzahl gleicher Bytes lesen
	beq.s	.backmain 	; 0: zurÅck
	move.b	(a6),d0
.copy_gl: move.b	d0,-(a6)
	dbf	d1,.copy_gl
	sub.l	d6,d1
	bmi.s	.backmain
	bra.s	.copy_gl

.copy_longstring:
	subq.w	#2,d0		; StringlÑnge - 2 (wegen dbf)
.copy_string:			; d1 = Offset, d0 = Anzahl Bytes -2
	lea.l	2(a6,d1.l),a0	; Hier stehen die Originaldaten
	add.w	d0,a0		; dazu die StringlÑnge-2
	move.b	-(a0),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a0),-(a6)	; mehr Bytes kopieren
	dbf	d0,.dep_b 	; und noch ein Mal
.backmain bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l	$03ff0009,$00070002,$00030001,$00030001 ; Anzahl 1-Bits
.tabellen:dc.l	    15-1,      8-1,      5-1,      2-1	; Anz. Bytes

.offset_table:
	dc.w	 3,	      0
	dc.w	 7,	   16+0
	dc.w	11,      256+16+0
	dc.w	15, 4096+256+16+0
.more_table:
	dc.w	3,       5
	dc.w	5,    16+5
	dc.w	7, 64+16+5

;*************************************************** Ende der Unpackroutine

; This is the unpacking source for Pack-Ice.
; Pack-Ice and this unpacking source were written by Axe of Delight.
; The unpacking routine is called with "bsr unpack".
; a0: is a pointer on the packed data
; d0: indicates the length of the packed data
; In return, you will get the new length in d0

ice1_0	movem.l d0-a6,-(sp)
	lea	0(a0,d0.l),a5
	bsr.s	.L0017
	cmpi.l	#'Ice!',d7
	bne.s	.L0012
	adda.w	#$78,a0
	bsr.s	.L0017
	move.l	d7,(sp)
	lea	0(a0,d7.l),a6
	movea.l a6,a3
	movea.l a6,a1
	lea	.savemem+$78(pc),a2
	moveq	#$77,d0
.L000F:	move.b	-(a1),-(a2)
	dbra	d0,.L000F
	bsr.s	.L0017
	bsr.s	.L0013
	move.l	(sp),d0
	lea	-120(a0),a1
.L0010:	move.b	(a0)+,(a1)+
	dbra	d0,.L0010
	subi.l	#$010000,d0
	bpl.s	.L0010
	moveq	#$77,d0
	lea	.savemem+$78(pc),a2
.L0011:	move.b	-(a2),-(a3)
	dbra	d0,.L0011
.L0012:	movem.l (sp)+,d0-a6
	rts
.L0013:	bsr.s	.L001B
	bcc.s	.L0016
	moveq	#0,d1
	bsr.s	.L001B
	bcc.s	.L0015
	lea	.L0028(pc),a1
	moveq	#3,d3
.L0014:	move.l	-(a1),d0
	bsr.s	.L001E
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.L0014
	add.l	16(a1),d1
.L0015:	move.b	-(a5),-(a6)
	dbra	d1,.L0015
.L0016:	cmpa.l	a0,a6
	bgt.s	.L0020
	rts
.L0017:	moveq	#3,d0
.L0018:	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,.L0018
	rts
.L0019:	move.w	a5,d7
	btst	#0,d7
	bne.s	.L001A
	move.l	-(a5),d7
	addx.l	d7,d7
	addx.w	d1,d1
	dbra	d0,.L001F
	rts
.L001A:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	addx.w	d1,d1
	dbra	d0,.L001F
	rts
.L001B:	add.l	d7,d7
	beq.s	.L001C
	rts
.L001C:	move.w	a5,d7
	btst	#0,d7
	bne.s	.L001D
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
.L001D:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
.L001E:	moveq	#0,d1
.L001F:	add.l	d7,d7
	beq.s	.L0019
	addx.w	d1,d1
	dbra	d0,.L001F
	rts
.L0020:	lea	.L0029(pc),a1
	moveq	#3,d2
.L0021:	bsr.s	.L001B
	dbcc	d2,.L0021
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.L0022
	bsr.s	.L001E
.L0022:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.L0024
	lea	.L002A(pc),a1
	moveq	#1,d2
.L0023:	bsr.s	.L001B
	dbcc	d2,.L0023
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.L001E
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	.L0026
.L0024:	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	.L001B
	bcc.s	.L0025
	moveq	#8,d0
	moveq	#$40,d2
.L0025:	bsr.s	.L001E
	add.w	d2,d1
.L0026:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.L0027:	move.b	-(a1),-(a6)
	dbra	d4,.L0027
	bra	.L0013

	  dc.b $03,$FF,$00,$09,$00,$07,$00,$02
	  dc.b $00,$03,$00,$01,$00,$03,$00,$01
.L0028:	  dc.b $00,$00
	  dc.b $00,$0E,$00,$00,$00,$07,$00,$00
	  dc.b $00,$04,$00,$00,$00,$01
.L0029:	  dc.b $09,$01,$00,$FF,$FF,$08,$04,$02
	  dc.b $01,$00
.L002A:	  dc.b $0B,$04,$07,$00,$01,$20,$00,$00
	  dc.b $00,$20

.savemem:  ds.b 120


jek	rts
;---------------------------------------
;in: a1 = pointer auf start der gepackten daten
;in: d6 = pointer auf erstes Wort hinter gepackten Daten
jek1.6
	lea	.cmdtab(pc),a5		; hilfstabelle
	movea.l d6,a0			; pointer auf gepacktes ende
	bsr.s	.getlongword		; hole original programmlaenge
	lea	0(a1,d0.l),a2		; pointer hinter entpacktes ende
	bsr.s	.getlongword		; und erstes datenlongwort

.patch:
	moveq	#2,d1			; hole 2 bit
	bsr.s	.hole_d1_bits
	bset	#1,d2			; 3 bit code noetig ?
	beq.s	.no3bit			; nein
	add.l	d0,d0			; 3. bit holen
	bne.s	.noget1			; noch nicht alle bits verarbeitet
	bsr.s	.getlongword		; hole naechstes langwort
	add.l	d0,d0			; damit hier ein bit ankommt
	bset	#0,d0
.noget1:
	addx.w	d2,d2			; jetzt 3 bit code
.no3bit:
	asl.w	#3,d2			; (* 8) = 6 + 2n =	12 Zyklen
	movem.w -2*8(a5,d2.w),d1/d3-d4	; parameter holen
	pea	0(a5,d4.l)		; unterroutine bestimmen
	bra.s	.hole_d1_bits		; erst mal weitere bits holen
					; und ab gehts
.einzelne:
	add.w	d2,d3			; anzahl einzelner bytes
.loop:
	move.b	-(a0),-(a2)		; byte speichern
	dbf	d3,.loop		; hole alle bytes
.zuende:
	cmpa.l	a2,a1			; sind wir fertig?
	blt.s	.patch			; nein, weiter in hauptschleife
.over:	rts				; entpacken fertig

.longstring:
	move.w	d2,d3			; stringlaenge merken
	moveq	#12,d1			; 12 bits decodieren
	bsr.s	.hole_d1_bits		; als distanzwert
.strings:
	move.b	-1(a2,d2.w),-(a2)	; string kopieren
	dbf	d3,.strings		; komplett
	cmpa.l	a2,a1			; sind wir fertig?
	blt.s	.patch			; nein, weiter in hauptschleife
	bra.s	.over			; Fertig!

.hole_d1_bits:
	subq.w	#1,d1			; eins weniger wegen dbf
	clr.w	d2			; ergebnisfeld vorbereiten
.hole_bit_loop:
	add.l	d0,d0			; hole ein bit
	bne.s	.no			; quellfeld nicht leer
	bsr.s	.getlongword		; hole ansonsten ein weiters longword
	add.l	d0,d0			; hole ein bit
	bset	#0,d0
.no:
	addx.w	d2,d2			; und uebernimm es
	dbf	d1,.hole_bit_loop	; bis alle bits geholt wurden
	rts

.getlongword:		; das x-Flag wird in dieser Routine gelîscht
	move.w	a0,d0
	lsr.w	#1,d0
	bcs.s	.noteven
	move.l	-(a0),d0		; hole ganz normal ein Longword
	rts
.noteven:
	move.l	-5(a0),d0		; Longword von ungerader Adresse
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	rts

.cmdtab:
	dc.w 03,0,.einzelne-.cmdtab,0	; (0)00 codiert als 010
	dc.w 08,1,.strings-.cmdtab,0	; (0)01 codiert als 011
	dc.w 09,2,.strings-.cmdtab,0	;  1 00
	dc.w 10,3,.strings-.cmdtab,0	;  1 01
	dc.w 08,0,.longstring-.cmdtab,0 	;  1 10
	dc.w 08,8,.einzelne-.cmdtab,0	;  1 11

.ende_header:
;~~~~~~~~~~~~~~~~~~~~~~~
.string_tab:
	dc.b $01,$00,$02,$00,$04,$00,$10,$00 ;max. erlaubter Distanzwert
	dc.b $00,$08,$00,$09,$00,$0A,$00,$0C ;Anzahl Bits fuer Distanzwert
	dc.b $00,$00,$00,$00,$00,$00,$00,$08 ;Anzahl Bits fuer Stringlaenge
	dc.b $00,$02,$00,$03,$00,$03,$00,$03 ;Anzahl Bits fuer Kennung
	dc.b $00,$01,$00,$04,$00,$05,$00,$06 ;Wert der Kennung (siehe unten)

		ds.l 2
	
;a0=adr
;d0=long
;---------------------------------------------------------------
jek2_3	  movem.l   d0-d7/a0-a6,-(sp)
          move.l    d0,.packed_length
          move.l    d0,.actual_length
	  move.l    a0,.load_addr
          btst      #0,d0		; odd length: not packed
          bne       .end_read
          move.l    a0,d7		; odd address of buffer
          btst      #0,d7
          bne       .end_read
          adda.l    d0,a0
          move.l    -(a0),d0  		; check if crunched file
          cmpi.l    #'JEK!',d0          ; crunched, last Longw. = 'JEK!'
          bne       .end_read
          move.l    -(a0),.actual_length
          subq.l    #4,.packed_length
          move.l    .load_addr(pc),a0
          adda.l    .packed_length(pc),a0
          move.l    .load_addr(pc),a1
          move.l    -(a0),a2
          adda.l    a1,a2
          move.l    -(a0),d5
          move.l    -(a0),d0
          eor.l     d0,d5
.L541f8:   lsr.l     #1,d0
          bne.s     .L54200
          bsr.s       .L542be
.L54200:   bcs.s     .L54242
          moveq     #8,d1
          moveq     #1,d3
          lsr.l     #1,d0
          bne.s     .L5420e
          bsr.s       .L542be
.L5420e:   bcs.s     .L5426e
          moveq     #3,d1
          clr.w     d4
.L54214:   bsr.s       .L542ca
          move.w    d2,d3
          add.w     d4,d3
.L5421c:   moveq     #7,d1
.L5421e:   lsr.l     #1,d0
          bne.s     .L54226
          bsr.s       .L542be
.L54226:   roxl.l    #1,d2
          dbra      d1,.L5421e
          move.b    d2,-(a2)
          dbra      d3,.L5421c
          bra.s     .L5427c
.L5423c:   moveq     #8,d1
          moveq     #8,d4
          bra.s     .L54214
.L54242:   moveq     #2,d1
          bsr.s     .L542ca
          cmpi.b    #2,d2
          blt.s     .L54264
          cmpi.b    #3,d2
          beq.s     .L5423c
          moveq     #8,d1
          bsr.s     .L542ca
          move.w    d2,d3
          move.w    #$c,d1
          bra.s     .L5426e
.L54264:   move.w    #9,d1
          add.w     d2,d1
          addq.w    #2,d2
          move.w    d2,d3
.L5426e:   bsr.s     .L542ca
.L54272:   subq.l    #1,a2
          move.b    0(a2,d2.w),(a2)
          dbra      d3,.L54272
.L5427c:   cmpa.l    a2,a1
          blt.s       .L541f8
.end_read: 
          movem.l   (sp)+,d0-d7/a0-a6
          move.l    .actual_length,d0
	  rts

.L542be:   move.l    -(a0),d0
          eor.l     d0,d5
          move.w    #$10,ccr
          roxr.l    #1,d0
          rts       
.L542ca:   subq.w    #1,d1
          clr.w     d2
.L542ce:   lsr.l     #1,d0
          bne.s     .L542dc
          move.l    -(a0),d0
          eor.l     d0,d5
          move.w    #$10,ccr
          roxr.l    #1,d0
.L542dc:   roxl.l    #1,d2
          dbra      d1,.L542ce
          rts       
.actual_length:      
          DC.l 0
.load_addr:          
          DC.l 0
.packed_length:      
          DC.l 0


* LZH DEPACKER; For use with the JAM Packer V3.0 & 4.0
*
* USAGE:
* LEA $ADDRESS OF PACKED DATA,A5
* LEA $ADDRESS TO UNPACK DATA TO,A6
* BSR LZH
*
* NOTE: Must save registers before executing depack if original
*       contents are required.



LZH	LEA	.TABLE1(PC),A0
	MOVE.L	#0,(A0)		;SET UP RELATIVE TABLE OFFSETS
	MOVE.L	#$274,4(A0)
	MOVE.L	#$4E8,8(A0)
	MOVE.L	#$9CE,12(A0)
	MOVE.L	#$C42,16(A0)
	MOVE.L	#$EB6,20(A0)
	MOVE.L	#$112A,24(A0)
	MOVE.L	#$122A,28(A0)

	MOVE.L	A7,D1		;GET STACK POSITON
	sub.l	#$1500,D1	;TABLES START ADDRESS IN D1
				;STORE UNDER STACK (NASTY!)
	MOVE.W	#7,D0
.TABLOOP
	ADD.L	D1,(A0)+	;ADD TABLE BASE ADDRESS TO OFFSETS
	DBF	D0,.TABLOOP
	
	BSR	.CREATE
	BSR     .CREATE2
	MOVE.L	.TABLE3(PC),A0
	MOVE.L	.TABLE5(PC),A1
	MOVE.L	.TABLE1(PC),A3
	MOVE.L  A6,-(A7)
	ADD.L	4(A5),A6
	ADD.L	8(A5),A5
	ADD.L	#$0C,A5
	MOVE.L	A6,A4

	MOVE.W	#59,D0		;MOVE 60 SPACES TO END OF UNPACKED AREA
.SPACES	MOVE.B	#$20,(A4)+	;NOTE: SHOULD PROBABLY SAVE THIS AREA
	DBF	D0,.SPACES	;      BEFORE WIPING IT OUT!

	MOVEQ   #$08,D6
	MOVE.B  -(A5),D5
	MOVE.W  #$04E6,D7
	MOVE.L	.TABLE8(PC),A4

.TOP	CMPA.L  (A7),A6
	BLE	.EXIT

	MOVE.W  $04E4(A1),D0
.MORE	DBF     D6,.NOTEMPTY
	MOVEQ   #$07,D6
	MOVE.B  -(A5),D5
.NOTEMPTY
	ADD.B   D5,D5
	BCC.S   .ZERO
	ADDQ.W  #2,D0
.ZERO	MOVE.W  $00(A1,D0.W),D0
	CMP.W   D7,D0
	BLT.S   .MORE
	MOVE.W  D0,D1
	SUB.W   D7,D0
	MOVE.W  $04E4(A3),D4
	BMI	.RESTORE

.BACK	MOVE.W  $00(A0,D1.W),D1
.SCAN	LEA     $00(A3,D1.W),A2
	ADDQ.W  #1,(A2)
	CMPM.W  (A2)+,(A2)+
	BCS.S   .FRSTGTR
	MOVE.W  $00(A0,D1.W),D1
	BNE.S   .SCAN
	LSR.W   #1,D0
	CMP.W   #$0100,D0
	BGE.S   .GTE256
.WRITE	MOVE.B	D0,-(A6)
	BRA.S   .TOP

.FRSTGTR SUBQ.W  #1,-$0004(A2)
	MOVE.W  -$0004(A2),D4
.SAME	CMP.W   (A2)+,D4
	BEQ.S   .SAME
	SUBQ.L  #4,A2
	ADDQ.W  #1,(A2)
	SUBA.L  A3,A2
	MOVE.W  $00(A1,D1.W),D4
	MOVE.W  A2,$00(A0,D4.W)
	CMP.W   D7,D4
	BCC.S   .SKIP
	MOVE.W  A2,$02(A0,D4.W)
.SKIP	MOVE.W  $00(A1,A2.W),D2
	MOVE.W  D4,$00(A1,A2.W)
	MOVE.W  D1,$00(A0,D2.W)
	CMP.W   D7,D2
	BCC.S   .SKIP2
	MOVE.W  D1,$02(A0,D2.W)
.SKIP2   MOVE.W  D2,$00(A1,D1.W)
	MOVE.W  $00(A0,A2.W),D1
	BNE.S   .SCAN
	LSR.W   #1,D0
	CMP.W   #$0100,D0
	BLT.S   .WRITE
.GTE256	MOVE.B  -1(A5),D1
	MOVEQ   #$00,D2
	LSR.B   D6,D1
	OR.B    D5,D1
	MOVE.B  $00(A4,D1.W),D2
	SUB.W   D2,D6
	BPL.S  .POSITIVE
	MOVE.B  -(A5),D5
	MOVE.B  D5,D4
	ADDQ.W  #2,D6
	BMI.S   .OVERFLOW
	BEQ.S   .MODD4
	LSR.B   #1,D4
	LSL.B   #7,D5
	BRA.S   .MODD4
.READONE MOVE.B  -(A5),D5
	MOVE.B  D5,D4
	LSL.B   #6,D5
	MOVEQ   #$02,D6
	LSR.B   D6,D4
	BRA.S   .DOCOPY
.POSITIVE
	BEQ.S   .READONE
	MOVE.B (A5),D5
	SUBQ.W  #6,D6
.OVERFLOW
	NEG.W   D6
	LSL.B   D6,D5
	MOVE.B  D5,D4
	MOVE.B  -(A5),D5
	MOVE.B  D5,D2
	LSL.B   D6,D5
	SUBQ.W  #8,D6
	NEG.W   D6
	LSR.B   D6,D2
	OR.B    D2,D4
.MODD4   ANDI.W  #$003F,D4
.DOCOPY	MOVE.L	.TABLE7(PC),A0
	MOVE.B  (A0,D1.W),D2
	LSL.W   #4,D2
	OR.B    D4,D2
	;NEG.W   D2
	LEA     $01(A6,D2.W),A0
	SUBI.W  #$00FE,D0
	MOVE.W  D0,D1
.COPY	MOVE.B  -(A0),D0
	MOVE.B  D0,-(A6)
	DBF     D1,.COPY
	MOVE.L	.TABLE3(PC),A0
	BRA	.TOP

.TDATA2	DC.W	$0F2F
	DC.W	$2F3F
	DC.W	$2F1F
.TDATA1
	DC.W	$FFF7
	DC.W	$7777
	DC.W	$7773
	DC.W	$3333
	DC.W	$3333
	DC.W	$3331
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1110
	DC.L	$00
	DC.L	$00


.RESET   MOVEM.W D0-D1/D3/D5,-(A7)
	MOVEA.L A1,A2
	MOVEQ   #$00,D2
	MOVEQ   #-$02,D4
	MOVEQ   #$00,D1
	MOVE.W  #$0139,D5
.OUTER	ADDQ.W  #2,D4
	CMP.W   (A2)+,D7
	BHI.S   .OUTER
	MOVE.W  $00(A3,D4.W),D3
	ADDQ.W  #1,D3
	LSR.W   #1,D3
	CMP.W   -$02(A3,D2.W),D3
	BLS.S 	.BIDDLE
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	CMP.W   D0,D3
	BLS.S	.BIDDLE
.BITH	MOVE.W  D0,$00(A3,D2.W)
	MOVE.W  D1,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D1.W)
	MOVE.W  D2,$02(A0,D1.W)
	ADDQ.W  #2,D2
	ADDQ.L  #4,D1
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	CMP.W   D0,D3
	BHI.S	.BITH
.BIDDLE	MOVE.W  D3,$00(A3,D2.W)
	MOVE.W  $00(A1,D4.W),D0
	MOVE.W  D0,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D0.W)
	ADDQ.W  #2,D2
	DBF     D5,.OUTER
.MAKETABLE2
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	MOVE.W  D0,$00(A3,D2.W)
	MOVE.W  D1,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D1.W)
	MOVE.W  D2,$02(A0,D1.W)
	ADDQ.W  #2,D2
	ADDQ.L  #4,D1
	CMP.W   D7,D2
	BNE.S	.MAKETABLE2
	MOVEM.W (A7)+,D0-D1/D3/D5
	RTS     

.CREATE  MOVE.L	.TABLE7(PC),A0
	LEA     .TDATA1(PC),A1
	MOVEQ   #$00,D0
	MOVEQ   #$1F,D1
	MOVEQ   #$00,D2
.LOOP1   MOVE.B  D0,(A0)+
	DBF     D1,.LOOP1
	DBF     D2,.EXIT1
	MOVE.W  (A1)+,D3
	MOVEQ   #$03,D2
.EXIT1   ROL.W   #4,D3
	MOVE.W  D3,D1
	ANDI.W  #$000F,D1
	ADDQ.B  #4,D0
	BCC.S   .LOOP1
	MOVE.L	.TABLE8(PC),A0
	LEA     .TDATA2(PC),A1
	MOVEQ   #$05,D0
	MOVEQ   #$03,D1
.LOOP2   MOVE.B  $00(A1,D0.W),D2
	EXT.W   D2
.LOOP3   MOVE.B  D1,(A0)+
	DBF     D2,.LOOP3
	ADDQ.W  #1,D1
	DBF     D0,.LOOP2
	RTS

.CREATE2 MOVE.L	.TABLE1(PC),A0
	MOVE.L	.TABLE5(PC),A1
	MOVE.L	.TABLE4(PC),A2
	MOVEQ   #$01,D1
	MOVE.W  #$04E6,D2
	MOVEQ   #$00,D4
	MOVE.W  #$0139,D0
.CONTINUE
	MOVE.W  D1,(A0)+
	MOVE.W  D2,(A1)+
	MOVE.W  D4,(A2)+
	ADDQ.W  #2,D2
	ADDQ.W  #2,D4
	DBF     D0,.CONTINUE
	MOVE.L	.TABLE1(PC),A0
	MOVE.L	.TABLE2(PC),A3
	MOVE.L	.TABLE6(PC),A1
	MOVE.L	.TABLE3(PC),A2
	MOVE.W  #$0274,D2
	MOVEQ   #$00,D4
	MOVE.W  #$0138,D0
.DOMORE	MOVE.W  (A0)+,D1
	ADD.W   (A0)+,D1
	MOVE.W  D1,(A3)+
	MOVE.W  D4,(A1)+
	MOVE.W  D2,(A2)+
	MOVE.W  D2,(A2)+
	ADDQ.W  #4,D4
	ADDQ.W  #2,D2
	DBF     D0,.DOMORE
	MOVE.W  #$FFFF,(A3)
	CLR.W   (A2)
	RTS     

.RESTORE BSR     .RESET
	BRA     .BACK

.TABLE1 DC.L 00
.TABLE2 DC.L 00
.TABLE3 DC.L 00
.TABLE4 DC.L 00
.TABLE5 DC.L 00
.TABLE6 DC.L 00
.TABLE7 DC.L 00
.TABLE8 DC.L 00

.EXIT
	ADDQ.L	#4,A7
	RTS


;LZW Depack routine for the JAM packer V4.0
;It is kept simple to minimise depack time.
;	MOVE.L	#START,A0	;start of packed data address
;	MOVE.L	#DEPACKICI,A1	;depack to address
;	BSR.S	LZW

LZW	MOVE.L	A0,A4
	MOVE.L	A1,A6
	ADDA.L	8(A0),A4
	ADDA.L	4(A0),A6
	MOVE.L	A6,A5			;KEEP COPY TO CHECK AGAINST
	MOVE.L	4(A0),D4
	MOVE.B	#$20,D3

	MOVE.W	#$0FED,D5
	MOVEA.L A6,A3			;KEEP ADDR OF END OF SPACES

	MOVEQ	#$00,D7			;START UNPACK ROUTINE
.TOPDEP	DBF	D7,.NOTUSED
	MOVE.B	-(A4),D6		;GET COMMAND BYTE
	MOVEQ	#$07,D7
.NOTUSED:
	LSR.B	#1,D6
	BCC.S	.COPY			;BIT NOT SET, COPY FROM UNPACKED AREA 
	MOVE.B	-(A4),-(A6)		;COPY BYTES FROM PACKED AREA
	ADDQ.W	#1,D5
	SUBQ.L	#1,D4
	BGT.S	.TOPDEP
	BRA.S	.EXITUP
.COPY:	MOVE.B	-2(A4),D0
	LSL.W	#4,D0
	MOVE.B	-(A4),D0
	SUB.W	D5,D0
	NEG.W	D0
	AND.W	#$0FFF,D0
	LEA	1(A6,D0.W),A0
	MOVEQ	#$0F,D1
	AND.B	-(A4),D1
	ADDQ.W	#2,D1
	MOVEQ	#$01,D0
	ADD.W	D1,D0
	CMPA.L	A5,A0
	BGT.S	.SPACES
	
.WRITE:	MOVE.B	-(A0),-(A6)
	DBF	D1,.WRITE
.BACK:	ADD.L	D0,D5
	SUB.L	D0,D4
	BGT.S	.TOPDEP
.EXITUP	RTS

.SPACES	CMPA.L	A5,A0
	BLE.S	.WRITE
	MOVE.B	D3,-(A6)		;COPY OUT SPACES
	SUBQ.L	#1,A0
	DBF	D1,.SPACES
	BRA.S	.BACK
	


;V2 Depack routine for JAM Packer V2.X/3.0/4.0
;a0 adresse DES DONNEES
;A1 ADRESSE OU ON LES MET
V2		ADDA.L	#$4,A0	;ALLOW FOR HEADER
		MOVE.W	#$FE,D7
		MOVE.L	A0,A6
		MOVE.L	(A0)+,D5
		ADDA.L	D5,A1
		ADDA.L	(A0),A0
		SUBA.L	#4,A0
		TST.W	-(A0)
		BPL.S	.SKIP
		SUBQ.L	#1,A0
.SKIP		MOVE.B	-(A0),D0

.TOP		ROL.W	D7
		LSL.B	#1,D0
		BNE.S	.NOTE
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.NOTE		BCC.S	.SHEP
		CLR.W	D1
		LSL.B	#1,D0
		BNE.S	.KLF
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.KLF		BCC.S	.PET
		LEA	.TABL1(PC),A3
		MOVEQ	#3,D3
.STE		CLR.W	D1
		MOVE.B	0(A3,D3.W),D2
		EXT.W	D2
		MOVEQ	#-1,D4
		LSL.W	D2,D4
		NOT.W	D4
		SUBQ.W	#1,D2
.ARJ		LSL.B	#1,D0
		BNE.S	.BOYS
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.BOYS		ROXL.W	#1,D1
		DBF	D2,.ARJ
		TST.W	D3
		BEQ.S	.SHOP
		CMP.W	D1,D4
		DBNE	D3,.STE
.SHOP		MOVE.B	4(A3,D3.W),D2
		EXT.W	D2
		ADD.W	D2,D1
.PET		MOVE.B	-(A0),-(A1)
		DBF	D1,.PET
.SHEP		MOVE.L	A6,A3
		ADDQ.L	#$8,A3
		CMPA.L	A3,A0
		BLE	.EXIT
		LEA	.TABL2(PC),A3
		MOVEQ	#3,D2
.CATHY		LSL.B	#1,D0
		BNE.S	.ALSA
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.ALSA		BCC.S	.FDC
		DBF	D2,.CATHY
.FDC		CLR.W	D1
		ADDQ.W	#1,D2
		MOVE.B	0(A3,D2.W),D3
		BEQ.S	.VAN
		EXT.W	D3
		SUBQ.W	#1,D3
.DE		LSL.B	#1,D0
		BNE.S	.VEN
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.VEN		ROXL.W	#1,D1
		DBF	D3,.DE
.VAN		MOVE.B	5(A3,D2.W),D3
		EXT.W	D3
		ADD.W	D3,D1
		CMPI.W	#2,D1
		BEQ.S	.MFD
		LEA	.TABL3(PC),A3
		MOVEQ	#1,D3
.LUC		LSL.B	#1,D0
		BNE.S	.CML
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.CML		BCC.S	.BBS
		DBF	D3,.LUC
.BBS		ADDQ.W	#1,D3
		CLR.W	D2
		MOVE.B	0(A3,D3.W),D4
		EXT.W	D4
.MCH		LSL.B	#1,D0
		BNE.S	.SAW
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.SAW		ROXL.W	#1,D2
		DBF	D4,.MCH
		LSL.W	#1,D3
		ADD.W	4(A3,D3.W),D2
		BRA.S	.CPUN
.MFD		CLR.W	D2
		MOVEQ	#5,D3
		CLR.W	D4
		LSL.B	#1,D0
		BNE.S	.EMF
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.EMF		BCC.S	.CLR1
		MOVEQ	#8,D3
		MOVEQ	#$40,D4
.CLR1		LSL.B	#1,D0
		BNE.S	.NOTZ
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
.NOTZ		ROXL.W	#1,D2
		DBF	D3,.CLR1
		ADD.W	D4,D2
.CPUN		LEA	0(A1,D2.W),A2
		EXT.L	D1
		ADDA.L	D1,A2
		SUBQ.W	#1,D1
.WRTLP		MOVE.B	-(A2),-(A1)
		DBF	D1,.WRTLP
		BRA	.TOP
.EXIT		RTS
.TABL1		DC.B	$0A,$03,$02,$02,$0E,$07,$04,$01
.TABL2		DC.B	$0A,$02,$01,$00,$00,$0A,$06,$04,$03,$02
.TABL3		DC.B	$0B,$04,$07,$00,$01,$20,$00,$00
		DC.B	$00,$20

* UNPACK source SPACKER 2.0/FIREHAWKS	* SUPERVISER Mode (Flash)
* ---------------------------------------------------------------
* In	a0: ^ source buffer
* Out	d0: original length or 0 if not SP20 packed
* ===============================================================

sp20:	movem.l	d1-a6,-(sp)
	clr.l	-(sp)
	cmp.l	#'SP20',(a0)+
	bne.s	sp2_05
	tst.w	(a0)
	bne.s	sp2_05
	move.l	a0,a5
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d1,(sp)
	tst.w	d5
	beq.s	sp2_01
	swap	d5
	btst	#1,$FFFF8260.W
	bne.s	sp2_01
	lea	$FFFF8240.W,a5
	move.w	(a5),d5
	swap	d5
sp2_01:	lea	64(a0),a1
	move.l	a1,a2
	add.l	d0,a0
	add.l	d1,a1
	move.l	a1,a3
	move.l	sp,a6
	moveq	#79,d0
sp2_02:	move.b	-(a3),-(a6)
	dbf	d0,sp2_02
	exg.l	a6,sp
	bsr.s	sp2_06
	lea	-80(a1),a3
	move.l	(a6),d0
sp2_03:	move.b	(a1)+,(a3)+
	subq.l	#1,d0
	bne.s	sp2_03
	exg.l	a6,sp
	moveq	#79,d0
sp2_04:	move.b	(a6)+,(a3)+
	dbf	d0,sp2_04
sp2_05:	movem.l	(sp)+,d0-a6
	rts	
sp2_06:	moveq	#0,d6
	moveq	#1,d7
	lea	sp2_38(pc),a3
	jsr	(a3)
	roxr.l	d7,d0
sp2_07:	add.l	d0,d0
	bne.s	sp2_08
	jsr	(a3)
sp2_08:	bcs.s	sp2_24
	move.b	-(a0),d1
	bra.s	sp2_13
sp2_09:	moveq	#2,d2
	bsr.s	sp2_16
	move.l	d6,d1
	bset	d2,d1
	bra.s	sp2_13
sp2_10:	add.l	d0,d0
	bne.s	sp2_11
	jsr	(a3)
sp2_11:	bcs	sp2_33
	moveq	#3,d2
	bsr.s	sp2_16
	add.w	d7,d2
	lsr.w	d7,d2
	bcc.s	sp2_12
	not.w	d2
sp2_12:	move.b	(a1),d1
	add.w	d2,d1
sp2_13:	move.b	d1,-(a1)
	clr.w	(a5)
sp2_14: cmp.l	a1,a2
	bne.s	sp2_07
	swap	d5
	move.w	d5,(a5)
	rts
sp2_15:	move.l	d7,d2
sp2_16:	move.l	d6,d1
sp2_17:	add.l	d0,d0
	bne.s	sp2_18
	jsr	(a3)
sp2_18:	addx	d1,d1
	dbf	d2,sp2_17
sp2_19:	move.l	d1,d2
	rts
sp2_20:	bsr.s	sp2_15
sp2_21:	beq.s	sp2_22
	move.b	-(a0),d1
	subq.w	#2,d2
	bcs.s	sp2_19
sp2_22:	add.w	d7,d2
	add.w	d2,d2
sp2_23:	add.w	d2,d2
	sub.w	d7,d2
	bra.s	sp2_17
sp2_24:	add.l	d0,d0
	bne.s	sp2_25
	jsr	(a3)
sp2_25:	bcs.s	sp2_27
	add.l	d0,d0
	bne.s	sp2_26
	jsr	(a3)
sp2_26:	bcs.s	sp2_10
	move.l	d6,d1
	move.b	-(a0),d1
	moveq	#0,d3
	bra.s	sp2_36
sp2_27:	add.l	d0,d0
	bne.s	sp2_28
	jsr	(a3)
sp2_28:	bcs.s	sp2_29
	bsr.s	sp2_15
	beq.s	sp2_13
	moveq	#1,d3
	bra.s	sp2_35
sp2_29:	add.l	d0,d0
	bne.s	sp2_30
	jsr	(a3)
sp2_30:	bcs	sp2_09
	add.l	d0,d0
	bne.s	sp2_31
	jsr	(a3)
sp2_31:	bcs.s	sp2_32
	bsr.s	sp2_15
	beq.s	sp2_12
	moveq	#2,d3
	bra.s	sp2_35
sp2_32:	moveq	#3,d3
	bsr.s	sp2_20
	bra.s	sp2_36
sp2_33:	bsr.s	sp2_15
	beq.s	sp2_34
	move.l	d6,d1
	add.w	d7,d2
	bsr.s	sp2_23
	move.l	d2,d3
	bsr.s	sp2_20
	bra.s	sp2_36
sp2_34:	bsr.s	sp2_20
	not.l	d1
	move.l	d2,d3
	bra.s	sp2_36
sp2_35:	move.l	d6,d1
	sub.w	d7,d2
	bsr.s	sp2_21
sp2_36:	move.l	a1,a4
	addq.l	#2,a4
	add.l	d1,a4
	add.l	d3,a4
	move.b	-(a4),-(a1)
sp2_37:	move.b	-(a4),-(a1)
	dbf	d3,sp2_37
	move.w	d5,(a5)
	bra	sp2_14
sp2_38:	move.w	a0,d4
	btst	d6,d4
	bne.s	sp2_39
	move.l	-(a0),d0
	addx.l	d0,d0
	rts
sp2_39:	move.l	-5(a0),d0
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	add.l	d0,d0
	bset	d6,d0
	rts


	DATA
AESPB		dc.l	CONTROL,GLOBAL,INT_IN,INT_OUT,ADDR_IN,ADDR_OUT
 	
	BSS
GLOBAL		ds.w	16
CONTROL		ds.w	10
INT_IN		ds.w	128
INT_OUT		ds.w	128
ADDR_IN		ds.l	128
ADDR_OUT	ds.l	128
TAILLE		ds.l	1
ADR_BUF		ds.l	1
TAMPON		ds.l	4
FICHIER		ds.b	64
SAVE_DIR	ds.b	64
DEFAUT		ds.l	4
DTA		ds.l	1
MAX		ds.l	1
PILE		ds.l	1
	DATA
	
;format d'un packer : dc.l identificateur,offset de l'id.,routine
INFO_PACKER	dc.l	$48E7FFFE,$D4,AUTOMATIQUE	;FIRE 2.0
		dc.l	$2C7C00FF,$44,POMPEY
		dc.l	$2C7C00FF,$62,POMPEY
		dc.l	$4BF0087E,$E0,AUTOMATIQUE	;ATOMIK 3.3
		dc.l	$48E7FFFE,$E2,AUTOMATIQUE	;ICE2_1
		dc.l	$49FA0214,$26,AUTOMATIQUE	;ICE2_2
		dc.l	$49FA0210,$26,AUTOMATIQUE	;ICE2_3
		dc.l	$1E25612A,$CC,AUTOMATIQUE	;ICE2_4
		dc.l	$D1FC0000,$1E6,AUTOMATION
		dc.l	$7800284A,$102,AUTOMATIQUE	;MPACKER
		dc.l	$45FA00EC,$182,JEK1_2
		dc.l	$45FA00EE,$188,JEK1_3
		dc.l	$61000104,$30,AUTOMATIQUE	;JEK2_3
		dc.l	$48E7FFFE,$46A,HAPPY
		dc.l	$41FA01A2,$2C4,JAM4		;LZH
		dc.l	$28482C49,$188,JAM4		;LZW
		dc.l	$48E7FFFE,$188,JAM4		;ICE
		dc.l	$3E3C00FE,$188,JAM4		;V2
		dc.l	"ICE!",0,DATAICE2.2.3.4
		dc.l	"Ice!",0,DATAICE2.2.3.4
		;rem : ice 2.1 ET 2.2 on le meme ID mais pas la meme routine ?!
		;d'apräs les docs,la .2 corrigerait des bugs de la .1
		;c'est pourquoi j'ai choisi la 2.2
		dc.l	"ATOM",0,DATAATM3.3
		dc.l	$613CDDC7,$EE,AUTOMATIQUE	;FIRE 1_0
		dc.l	"Fire",-4,DATAFIRE1.0		;offset nÇgatif <=> en partant de la fin !
		dc.l	"FIRE",0,DATAFIRE2.0
		dc.l	$6134DDC7,$EC,AUTOMATIQUE	;ICE1.0
		dc.l	$6134DDC7,$EA,AUTOMATIQUE	;ICE1.11
		dc.l	"Ice!",-4,DATAICE1.0
		dc.l	$616845F1,$D6,AUTOMATIQUE	;JEK1_6
		dc.l	$20462A20,$F0,AUTOMATIQUE	;JEK1_3U
		dc.l	"JEK!",-4,DATAJEK2.3
		dc.l	"DEL!",-4,DATAJEK1.6
		dc.l	$204E6134,$D0,AUTOMATIQUE
		dc.l	"LZH!",0,DATALZH
		dc.l	"LZW!",0,DATALZW
		dc.l	"LSD!",0,DATAV2
		dc.l	$41FA0194,$2BA,JAM4		;JAM3:LZH
		dc.l	$3E3C00FE,$17C,JAM3		;JAM3:V2
		dc.l	$45FA00DE,$1AC,AUTOMATION	;JAM 1.0
		dc.l	$45FA00DE,$1CC,AUTOMATION	;JAM 1.4
		dc.l	$2F004BF0,$E0,AUTOMATIQUE	;ATOMIK 3.5
		dc.l	"ATM5",0,DATAATM3.5
		dc.l	$2A6EFF10,$D4,SPACKER2
		dc.l	$227800A0,$88,SPACKER
		dc.l	"SP20",0,DATASP20
		dc.l	$D1FC0000,$17C,JAM3		;JAM 2.3
		dc.l	0	
;mettre ici le nom sur 8 caractäres (pas gÇnÇreux le gars ...)
;dans le meme ordre que les packers
TYPES		dc.b	"FIRE 2.0"
		dc.b	"POMPEY  "
		dc.b	"POMPEY  "
		dc.b	"ATM 3.3 "
		dc.b	"ICE 2.1 "
		dc.b	"ICE 2.2 "
		dc.b	"ICE 2.3 "
		dc.b	"ICE 2.4 "
		dc.b	"AUTOMAT."
		dc.b	"M-PACKER"
		dc.b	"JEK 1.2 "
		dc.b	"JEK 1.3 "
		dc.b	"JEK 2.3 "
		dc.b	"HAPPY   "
		dc.b	"JAM4:LZH"
		dc.b	"JAM4:LZW"
		dc.b	"JAM4:ICE"
		dc.b	"JAM4:V2 "
		dc.b	"ICE     "
		dc.b	"Ice     "
		dc.b	"ATM 3.3 "
		dc.b	"FIRE 1.0"
		dc.b	"Fire    "
		dc.b	"FIRE    "
		dc.b	"ICE 1.0 "
		dc.b	"ICE 1.11"
		dc.b	"ICE     "
		dc.b	"JEK 1.6 "
		dc.b	"JEK 1.3U"
		dc.b	"JEK     "
		dc.b	"JEK     "
		dc.b	"JEK 2.3 "
		dc.b	"JAM:LZH "
		dc.b	"JAM:LZW "
		dc.b	"AUTO/V2 "
		dc.b	"JAM3:LZH"
		dc.b	"JAM3:V2 "
		dc.b	"JAM 1.0 " 
		dc.b	"JAM 1.4 " 
		dc.b	"ATM 3.5 "
		dc.b	"ATM 3.5 "
		dc.b	"SPACKER2"
		dc.b	"SPACKER+"
		dc.b	"SPACKER2"
		dc.b	"JAM 2.3 "
		even
MASQUE		dc.b	"*.*",0
		dc.l	0,0,0
		even
INFO_BOX	dc.b	"[3][ |The TBC's depacker v2.0|"
		dc.b	"Choose the file to decrunch]"
		dc.b	"[Continue|Info|Quit]",0
INFO_BOX2	dc.b	"[3][ |Author : THE BEYONDER of TBC !|"
		dc.b	"Like ATOMIK,AUTOMATION,JEK,JAM|"
		dc.b	"ICE,POMPEY or M- packer.]"
		dc.b	"[OK]",0
EXIST_BOX	dc.b	"[1][ |This file does not exist]"
		dc.b	"[New file|Quit]",0
ERR_LEC_BOX	dc.b	"[3][ |Read error in "
ERR_LEC_BOX2	dc.b	"________.___]"
		dc.b	"[New file|Quit]",0
TAILLE_BOX3	dc.b	"[3][ |There is not enough room|"
		dc.b	"to save this file]"
		dc.b	"[New disk|New file|Quit]",0
TAILLE_BOX2	dc.b	"[3][ |There is not enough memory|"
		dc.b	"to decrunch this file]"
		dc.b	"[New file|Quit]",0
TAILLE_BOX	dc.b	"[3][ |This file is too big|"
		dc.b	"to fit in memory]"
		dc.b	"[New file|Quit]",0
EXISTDEJA_BOX	dc.b	"[2][ |This file already exist|"
		dc.b	"Using continue will delete it]"
		dc.b	"[Continue|Change|Quit]",0
FORMAT_INCONNU	dc.b	"[3][ |I don't know this packer !]"
		dc.b	"[New File|Quit]",0
CREATION_OK	dc.b	"[3][ |Save correctly done]"
		dc.b	"[New file|Quit]",0
ERREUR_CREATION	dc.b	"[3][ |Save error !]"
		dc.b	"[Retry|New file|Quit]",0
INFO_TYPE	dc.b	"[3][ |Packer : "
TYPE		dc.b	"________|Packed length : "
LONG_PACK	dc.b	"000000|Normal length : "
LONG_DEPACK	dc.b	"000000]"
		dc.b	"[Save|New File|Quit]",0
		BSS
PAGEBASE		ds.b	256-$1C