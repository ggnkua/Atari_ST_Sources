;
; Rotations/zooms
; Par Agopian Mathias pour STMAG
;


BaseDsp		equ	$ffffa200		
SprAdd		equ	0
SprXSize	equ	4
SprYSize	equ	6
SprXinc		equ	8
SprYinc		equ	16
SprAngle	equ	24
SprLTrue	equ	26
SprHTrue	equ	28
SprXctr		equ	30
SprYctr		equ	32
SprEnd		equ	34


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

	bsr	LoadImage
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

	move.w	d6,-(sp)	; VgetSize
	move.w	#91,-(sp)
	trap	#14
	addq.l	#4,sp
	move.l	d0,ScrSize

	addq.l	#8,d0		; Malloc
	move.l	d0,-(sp)
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,MallocAdd
	addq.l	#4,d0
	and.l	#$fffffffc,d0
	move.l	d0,ScrAdd
	rts

	; - - - - - - - - - - - - - - - - - - - - - - - 
	; Tout remetre en place
	; - - - - - - - - - - - - - - - - - - - - - - - 
	
Restore	move.l	MallocAdd,-(sp)	;Mfree
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	Vsetmode OldMode,#0	;Reserve memoire
	Physbase		;Adresse de l'ecran
	Vsetmode OldMode,d0	;Nouveau mode a la nouvelle adresse
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

Scr0	dc.l	0
Scr1	dc.l	0

Demo	pea	0.L			; Superviseur
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	move.w	#$20,-(sp)

	clr.l	$ffff9800.w	; Bord noir (pour les t‚l‚s)

	move.l	$44e,a0		;Effacer les ecrans
	move.l	ScrAdd,a1
	move.l	ScrSize,d0
	lsr.l	#2,d0
.clear	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d0,.clear

	move.l	ScrAdd,Scr0
	move.l	$44e,Scr1

	; La demo proprement dit
.jeu	move.l	Scr0,$45e.w
	bsr	Wvbl
	clr.l	$45e.w
	move.l	Scr0,d0
	move.l	Scr1,Scr0
	move.l	d0,Scr1


	clr.w	d0			; Envoyer le donnees du sprite 0
	bsr	InitSprite
	clr.w	d0
	bsr	AfficheSprite		; Afficher le sprite 0
	
	move.w	Rotate,d0		; Gestion du deplacement:
	add.w	d0,Sprite0+SprAngle	; C'est pas tres original mais
	and.w	#$ff,Sprite0+SprAngle	; bon; on "rotate" le sprite de
	lea	Sprite0,a0		; plus en plus vite et on "zoom" et 
	move.l	Zoom,d0			; "d‚zoom" dessus.
	add.l	d0,SprXinc(a0)
	add.l	d0,SprYinc(a0)
	cmp.b	#1,(SprYinc+1)(a0)
	ble.s	.ok
	move.l	#-$000100,Zoom
.ok	tst.b	(SprYinc+1)(a0)
	bge.s	.ok1
	move.l	#$000100,Zoom
.ok1
	
	cmp.b	#$B9,$fffffc02	; A t on appuy‚ sur la barre d'espace?
	bne	.jeu
	
	clr.l	$45e.w

	trap	#1		; On repasse en utilisateur
	addq.l	#6,sp		; (les donnees on deja ete empil‚es)
	rts

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
	move.l	Scr0,a0
	move.w	#320,d5
	sub.w	SprXSize(a1),d5
	
	move.w	SprXSize(a1),d6		; Nombre de pixels
	lsr.w	#3,d6
	subq.w	#1,d6
	move.w	d6,BclCnt

	move.w	SprYSize(a1),d7		; Nombre de tours de boucle
	subq.w	#1,d7
	
	bsr	WaitRec			; Attendre le DSP
	
	;
	; Voici la routine d'affichage.
	; Je ne sais pas s'il est possible d'aller
	; plus vite. Si quelqu'un a une id‚e ?
	;
	
	move.w	#$2700,sr
.NextL	movem.w	d5/d7,-(sp)
	move.w	BclCnt(pc),d6
.NextP	move.w	d6,-(sp)
	move.w	([a5]),d0
	move.w	([a5]),d1
	move.w	([a5]),d2
	move.w	([a5]),d3
	move.w	([a5]),d4
	move.w	([a5]),d5
	move.w	([a5]),d6
	move.w	([a5]),d7
	movem.w	d0-d7,(a0)		; On poke 8 pixels d'un coup
	lea	16(a0),a0
	move.w	(sp)+,d6
	dbf	d6,.NextP
	movem.w	(sp)+,d5/d7
	lea	(a0,d5.w*2),a0		; Ligne suivante
	dbf	d7,.NextL
	move.w	#$2300,sr
	rts

WaitRec	btst	#0,2(a6)		; Attendre que DSP envoie
	beq.s	WaitRec			; quelque chose
	rts
	
InitSprite
	move.l	(Sprites_Tbl,d0.w*4),a0	; Envoyer les donnees du sprite
	lea	BaseDsp,a6
	bsr	WaitDsp
	clr.l	4(a6)	
	move.l	SprAdd(a0),4(a6)
	clr.b	5(a6)
	move.w	SprXSize(a0),6(a6)
	move.w	SprYSize(a0),6(a6)
	move.l	SprXinc(a0),4(a6)
	move.l	SprYinc(a0),4(a6)
	clr.b	5(a6)
	move.w	SprAngle(a0),6(a6)
	move.w	SprLTrue(a0),6(a6)
	move.w	SprHTrue(a0),6(a6)
	move.w	SprXctr(a0),6(a6)
	move.w	SprYctr(a0),6(a6)
	move.l	SprAdd(a0),4(a6)
	move.l	SprEnd(a0),4(a6)
	move.l	#BlackPix,4(a6)
	rts

WaitDsp	btst	#1,$ffffa202.w		; attendre que le DSP ait recu
	beq.s	WaitDsp			; les donnees
	rts
		

LoadImage
	clr.w	-(sp)
	pea	SprName
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,d7
	
	pea	SprImg0
	move.l	#200000,-(sp)		; hou que c'est pas beau
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
	
	rts
	
	
	; - - - - - - - - - - - - - - - - - - - - - - - -
	; Datas
	; - - - - - - - - - - - - - - - - - - - - - - - -


		data
Black		dc.w	0
DspFile		dc.b	'ROTOZOOM.LOD',0
		even

Sprites_Tbl	dc.l	Sprite0

Sprite0		dc.l	SprImg0+18	;Adresse des donnees du sprite
		dc.w	200		;Largeur de la fenetre … afficher
		dc.w	200		;Hauteur de la fenetre … afficher
		dc.l	$010000		;Increment X
		dc.l	0		;r‚serv‚
		dc.l	$010000		;Idem pour Y
		dc.l	0		;r‚serv‚
		dc.w	0		;Angle compris en 0 et 256
		dc.w	296		;Taille reelle du sprite en pixels
		dc.w	309		;hauteur reelle du sprite en lignes
		dc.w	150		;Point central pour la rotation (X)
		dc.w	150		;Point central pour la rotation (Y) 
		dc.l	SprFin0		; Adresse de fin du sprite

Zoom		dc.l	$001000
Rotate		dc.w	2
BclCnt		dc.w	0
BlackPix	dc.w	0

SprName		dc.b	'SPR3.TG1',0
		even

		bss
ScrSize		ds.l	1
ScrAdd		ds.l	1
MallocAdd	ds.l	1
OldMode		ds.w	1
DspBuffer	ds.b	$400
CntVbl		ds.l	1
		
SprImg0		ds.b	200000		; Je sais que c'est pas trŠs beau comme
SprFin0					; facon de reserver de la RAM
					; mais c'est pratique!

		ds.b	5120
pile		ds.l	0
