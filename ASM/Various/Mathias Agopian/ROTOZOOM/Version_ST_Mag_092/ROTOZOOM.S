;
; Rotations/zooms
; Par Agopian Mathias pour STMAG
;


BaseDsp		equ	$ffffa200		
SprAdd		equ	0
SprXSize	equ	4
SprYSize	equ	6
SprXinc		equ	8
SprXinc_d	equ	12
SprYinc		equ	16
SprYinc_d	equ	20
SprAngle	equ	24
SprLTrue	equ	26
SprHTrue	equ	28
SprXctr		equ	30
SprYctr		equ	32


Vsetmode	MACRO
		move.w	\1,-(sp)
		move.w	#3,-(sp)
		move.l	\2,-(sp)
		move.l	\2,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp
		ENDM

Vgetmode	MACRO
		move.w	#-1,-(sp)
		move.w	#88,-(sp)
		trap	#14
		addq.l	#4,sp
		ENDM

Physbase	MACRO
		move.w	#2,-(sp)
		trap	#14
		addq.l	#2,sp
		ENDM


	include	'startup.s'
	section	text

	bsr	Init
	bsr	InitDsp
	bsr	Demo
	bsr	Restore

	clr.w	-(sp)
	trap	#1
	

	; - - - - - - - - - - - - - - - - - - - - - - -
	; Initialisation 
	; - - - - - - - - - - - - - - - - - - - - - - - 

Init	Vgetmode
	move.w	d0,OldMode
	move.w	d0,d6
	and.w	#$30,d6
	or.w	#$0004,d6	;True Color 40 colones
	move.w	#89,-(sp)
	trap	#14
	addq.l	#2,sp
	cmp.w	#2,d0
	bne.s	.novga
	or.w	#$0100,d6	;double ligne
.novga	Vsetmode d6,#0	 	;Reserve memoire
	Physbase		;Adresse de l'ecran
	Vsetmode d6,d0		;Nouveau mode a la nouvelle adresse
	rts

InitDsp	pea	DspBuffer	; Dsp_LoadProg
	move.w	#$8000,-(sp)
	pea	DspFile
	move.w	#108,-(sp)
	trap	#14
	lea	12(sp),sp
	rts
	
	; - - - - - - - - - - - - - - - - - - - - - - - 
	; Programme principal
	; - - - - - - - - - - - - - - - - - - - - - - - 

Demo	pea	0.L			; Superviseur
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	move.w	#$20,-(sp)

	move.l	#Black,$ffffa204.w	; Adresse d'un pixel noir

	; La demo proprement dit
.jeu	;bsr	Wvbl
	clr.w	d0			; Envoyer le donnees du sprite 0
	bsr	InitSprite
	clr.w	d0
	bsr	AfficheSprite		; Afficher le sprite 0
	
	move.w	Rotate,d0		; Gestion du deplacement:
	add.w	d0,Sprite0+SprAngle	; C'est pas tres original mais
	and.w	#$ff,Sprite0+SprAngle	; bon; on "rotate" le sprite de
	lea	Sprite0,a0		; plus en plus vite et on "zoom" et 
	move.l	Zoom,d0			; "d‚zoom" dessus.
	add.l	d0,SprXinc_d(a0)
	move.b	SprXinc_d(a0),(SprXinc+3)(a0)
	add.l	d0,SprYinc_d(a0)
	move.b	SprYinc_d(a0),(SprYinc+3)(a0)	
	cmp.b	#3,SprYinc_d(a0)
	ble.s	.ok
	move.l	#-$080000,Zoom
	add.w	#1,Rotate
.ok	tst.b	SprYinc_d(a0)
	bge.s	.ok1
	move.l	#$080000,Zoom
	add.w	#1,Rotate
.ok1
	
	cmp.b	#$B9,$fffffc02	; A t on appuy‚ sur la barre d'espace?
	bne.s	.jeu

	trap	#1		; On repasse en utilisateur
	addq.l	#6,sp		; (les donnees on deja ete empil‚es)
	rts

Zoom	dc.l	$080000
Rotate	dc.w	1	

Wvbl	move.l	$466,d0		; Attendre la VBL
.wait	cmp.l	$466,d0
	beq.s	.wait
	rts
	
AfficheSprite			; Affichage du sprite
	lea	BaseDsp,a6
	lea	4(a6),a5
	bsr	WaitDsp
	move.l	(Sprites_Tbl,d0.w*4),a1
	
	move.l	#1,4(a6)	; On calcule l'offset … la ligne suivante
	move.l	$44e,a0
	move.w	#320,d5
	sub.w	SprXSize(a1),d5
	
	move.w	SprYSize(a1),d7		; Nombre de tours de boucle
	subq.w	#1,d7
	
.NextL	move.w	SprXSize(a1),d6		; Nombre de pixels
	subq.w	#1,d6
	
	bsr	WaitRec			; Attendre le DSP
.NextP	move.w	([a5]),d0
	beq.s	.next
	move.w	d0,(a0)
.next	addq.l	#2,a0
	nop
	dbf	d6,.NextP

	lea	(a0,d5.w*2),a0		; Ligne suivante
	dbf	d7,.NextL
	rts
	
WaitRec	btst	#0,2(a6)		; Attendre que DSP envoie
	beq.s	WaitRec			; quelque chose
	rts
	
InitSprite
	move.l	(Sprites_Tbl,d0.w*4),a0	; Envoyer les donnees du sprite
	lea	BaseDsp,a6
	bsr	WaitDsp
	clr.l	4(a6)	
	bsr	WaitDsp
	move.l	SprAdd(a0),4(a6)	
	clr.b	5(a6)
	move.w	SprXSize(a0),6(a6)
	move.w	SprYSize(a0),6(a6)
	move.l	SprXinc(a0),4(a6)
	move.l	SprXinc_d(a0),4(a6)
	move.l	SprYinc(a0),4(a6)
	move.l	SprYinc_d(a0),4(a6)
	clr.b	5(a6)
	move.w	SprAngle(a0),6(a6)
	move.w	SprLTrue(a0),6(a6)
	move.w	SprHTrue(a0),6(a6)
	move.w	SprXctr(a0),6(a6)
	move.w	SprYctr(a0),6(a6)
	rts

WaitDsp	btst	#1,$ffffa202.w		; attendre que le DSP ait recu
	beq.s	WaitDsp			; les donnees
	rts
		
	; - - - - - - - - - - - - - - - - - - - - - - - 
	; Tout remetre en place
	; - - - - - - - - - - - - - - - - - - - - - - - 
	
Restore	Vsetmode OldMode,#0	;Reserve memoire
	Physbase		;Adresse de l'ecran
	Vsetmode OldMode,d0	;Nouveau mode a la nouvelle adresse
	rts



		data
Black		dc.w	0
DspFile		dc.b	'ROTOZOOM.LOD',0
		even

Sprites_Tbl	dc.l	Sprite0

Sprite0		dc.l	SprImg0+18	;Adresse des donnees du sprite
		dc.w	160		;Largeur de la fenetre … afficher
		dc.w	100		;Hauteur de la fenetre … afficher
		dc.l	$000000		;Increment X (partie entiere)
		dc.l	$000000		;Increment X (partie decimale)
		dc.l	$000000		;Idem pour Y (entiere)
		dc.l	$000000		;Idem pour Y (decimale)
		dc.w	0		;Angle compris en 0 et 256
		dc.w	320		;Taille reelle du sprite en pixels
		dc.w	198		;hauteur reelle du sprite en lignes
		dc.w	60		;Point central pour la rotation (X)
		dc.w	60		;Point central pour la rotation (Y) 
		
SprImg0		incbin	'SPR2.TG1'


		bss
OldMode		ds.w	1
DspBuffer	ds.b	$400
CntVbl		ds.l	1

		ds.b	5120
pile		ds.l	0
