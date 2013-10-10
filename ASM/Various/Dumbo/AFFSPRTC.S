;
; Affichage de sprites en mode Falcon True Color
; 128 couleurs par sprite max et une palette de 256 octets max.
; By Dumbo - XXeme siecle
;
; Les sprites sont compactes par ligne, format :
; Ligne
;    *.b : Nbr de section - 1 sur cette ligne
;    Section
;       *.b : Nbr de pixels … sauter depuis le debut le la ligne
;       *.b : Nbr de pixels - 1 sur cette section
;       Pixels
;          *.b : Numero de couleur dans la palette * 2
;       Fin-pixels
;    Fin_section
; Fin_ligne
;
; NB : S'il y a plusieurs sections sur une lignes, elles doivent
;      ˆtre stoqu‚es de telle fa‡on que l'affichage se fasse dans
;      l'ordre, de la gauche vers la droite.
;      D'autre part, les longueurs ne doivent pas d‚passer 253


	OPT	p=68030
	OPT	x+

	TEXT


; Exemple, affich‚ en 1:26
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,a6
	move.l	a6,a1
	lea.l	sprite,a0
	lea.l	palette,a2
	move.l	#47,d0
	bsr	affsprite_noflip
	move.l	a6,a1
	add.l	#640,a1
	lea.l	sprite,a0
	move.l	#47,d0
	bsr	affsprite_fliph
	move.l	a6,a1
	add.l	#127360,a1
	lea.l	sprite,a0
	move.l	#47,d0
	bsr	affsprite_flipv
	move.l	a6,a1
	add.l	#128000,a1
	lea.l	sprite,a0
	move.l	#47,d0
	bsr	affsprite_fliphv
	move.l	#$ffff,d0
boucle:	move.l	#$ff,d1
boucle2:
	dbra	d1,boucle2
	dbra	d0,boucle
	move.l	#40000,d7
	move.l	#24,d5
boucle3:
	lea.l	(a6,d7.l*2),a1
	lea.l	sprite,a0
	move.l	#47,d0
	bsr	affsprite_pg_noflip
	dbra	d7,boucle3
	clr.w	-(sp)
	trap	#1



; Affichage normal
; En entree :
; a0 = adresse du sprite
; a1 = adresse de l'affichage (coin haut-gauche du sprite)
; a2 = adresse de la palette
; d0 = nombre de lignes - 1 a afficher
; registres egalement modifies :
; d1,d2,d3,d4,a3

affsprite_noflip:
	moveq	#0,d2
	moveq	#0,d3
	move.l	#640,d4		; Nombre d'octets par ligne
asnf_ligne:
	move.l	a1,a3		; Sauvegarde de a1
	moveq	#0,d1
	move.b	(a0)+,d1	; d1 = nombre de sections
asnf_sect:
	moveq	#0,d2
	move.b	(a0)+,d2	; Nombre de pixels a sauter
	add.w	d2,a3
	add.w	d2,a3
	move.b	(a0)+,d2	; d2 = nombre de pixels a afficher
asnf_pixels:
	move.b	(a0)+,d3	; Numero de la couleur
	move.w	(a2,d3.w),(a3)+	; Affiche le pixel
	dbra	d2,asnf_pixels	; Pixel suivant
	dbra	d1,asnf_sect	; Section suivante
	add.w	d4,a1
	dbra	d0,asnf_ligne	; Ligne suivante
	rts


; Affichage normal avec coupure verticale (affichage partie gauche seulement)
; En entree :
; a0 = adresse du sprite
; a1 = adresse de l'affichage (coin haut-gauche du sprite)
; a2 = adresse de la palette
; d0 = nombre de lignes - 1 a afficher
; d5 = position x dans le sprite de la coupure (nbr de colonnes … virer au d‚but)
; registres egalement modifies :
; d1,d2,d3,d4, a3,a4

affsprite_pg_noflip:
	moveq	#0,d2
	moveq	#0,d3
	move.l	#640,d4		; Nombre d'octets par ligne
asnfpg_ligne:
	move.l	a1,a3		; Sauvegarde de a1
	moveq	#0,d1
	move.b	(a0)+,d1		; d1 = nombre de sections
asnfpg_sect:
	moveq	#0,d2
	move.b	(a0)+,d2		; Nombre de pixels a sauter
	move.w	d5,d6		; d6 = nombre de pixels … sauter
	sub.w	d2,d6		; d6 = nombre maximum de pixels … afficher
	ble.s	asnfpg_finligne	; Fin de la ligne si son d‚but ‚tait aprŠs la coupure
	add.w	d2,a3
	add.w	d2,a3
	move.b	(a0)+,d2		; d2 = nombre de pixels a afficher
	cmp.w	d6,d2
	bge.s	asnfpg_limite	; Limitation du nombre de pixels … afficher
asnfpg_pixels:
	move.b	(a0)+,d3		; Numero de la couleur
	move.w	(a2,d3.w),(a3)+	; Affiche le pixel
	dbra	d2,asnfpg_pixels	; Pixel suivant
	dbra	d1,asnfpg_sect	; Section suivante
	add.w	d4,a1
	dbra	d0,asnfpg_ligne
	rts

asnfpg_limite:
	subq.w	#1,d6		; d6 = compteur … partir de 0
	move.l	a0,a4		; Sauve l'adresse du d‚but de section
asnfpg_pixels2:
	move.b	(a0)+,d3
	move.w	(a2,d3.w),(a3)+
	dbra	d6,asnfpg_pixels2
	lea.l	1(a4,d2.w),a0	; Avance a0 jusqu'… la section suivante
	dbra	d1,asnfpg_finligb	; Section coup‚e, ligne finie
	add.w	d4,a1
	dbra	d0,asnfpg_ligne
	rts

asnfpg_finligb:
	addq.l	#1,a0
asnfpg_finligne:
	move.b	(a0),d2
	lea.l	2(a0,d2.w),a0
	dbra	d1,asnfpg_finligb
	add.w	d4,a1
	dbra	d0,asnfpg_ligne
	rts



; Affichage avec flip horizontal
; En entree :
; a0 : adresse du sprite
; a1 : adresse de l'affichage (coin haut-exterieur droit du sprite)
; a2 : adresse de la palette
; d0 : nombre de lignes - 1 a afficher
; registres egalement modifies :
; d1,d2,d3,d4,a3

affsprite_fliph:
	moveq	#0,d2
	moveq	#0,d3
	move.l	#640,d4
asfh_ligne:
	move.l	a1,a3
	moveq	#0,d1
	move.b	(a0)+,d1
asfh_sect:
	moveq	#0,d2
	move.b	(a0)+,d2
	sub.w	d2,a3
	sub.w	d2,a3
	move.b	(a0)+,d2
asfh_pixels:
	move.b	(a0)+,d3
	move.w	(a2,d3.w),-(a3)
	dbra	d2,asfh_pixels
	dbra	d1,asfh_sect
	add.w	d4,a1
	dbra	d0,asfh_ligne
	rts


; Affichage avec flip vertical
; En entree :
; a0 = adresse du sprite
; a1 = adresse de l'affichage (coin bas-gauche du sprite)
; a2 = adresse de la palette
; d0 = nombre de lignes - 1 a afficher
; registres egalement modifies :
; d1,d2,d3,d4,a3

affsprite_flipv:
	moveq	#0,d2
	moveq	#0,d3
	move.l	#640,d4
asfv_ligne:
	move.l	a1,a3
	moveq	#0,d1
	move.b	(a0)+,d1
asfv_sect:
	moveq	#0,d2
	move.b	(a0)+,d2
	add.w	d2,a3
	add.w	d2,a3
	move.b	(a0)+,d2
asfv_pixels:
	move.b	(a0)+,d3
	move.w	(a2,d3.w),(a3)+
	dbra	d2,asfv_pixels
	dbra	d1,asfv_sect
	sub.w	d4,a1
	dbra	d0,asfv_ligne
	rts



; Affichage avec flip vertical et coupure verticale (affichage partie gauche seulement)
; En entree :
; a0 = adresse du sprite
; a1 = adresse de l'affichage (coin bas-gauche du sprite)
; a2 = adresse de la palette
; d0 = nombre de lignes - 1 a afficher
; d5 = position x dans le sprite de la coupure (nbr de colonnes … virer au d‚but)
; registres egalement modifies :
; d1,d2,d3,d4, a3,a4

affsprite_pg_flipv:
	moveq	#0,d2
	moveq	#0,d3
	move.l	#640,d4		; Nombre d'octets par ligne
asfvpg_ligne:
	move.l	a1,a3		; Sauvegarde de a1
	moveq	#0,d1
	move.b	(a0)+,d1		; d1 = nombre de sections
asfvpg_sect:
	moveq	#0,d2
	move.b	(a0)+,d2		; Nombre de pixels a sauter
	move.w	d5,d6		; d6 = nombre de pixels … sauter
	sub.w	d2,d6		; d6 = nombre maximum de pixels … afficher
	ble.s	asfvpg_finligne	; Fin de la ligne si son d‚but ‚tait aprŠs la coupure
	add.w	d2,a3
	add.w	d2,a3
	move.b	(a0)+,d2		; d2 = nombre de pixels a afficher
	cmp.w	d6,d2
	bge.s	asfvpg_limite	; Limitation du nombre de pixels … afficher
asfvpg_pixels:
	move.b	(a0)+,d3		; Numero de la couleur
	move.w	(a2,d3.w),(a3)+	; Affiche le pixel
	dbra	d2,asfvpg_pixels	; Pixel suivant
	dbra	d1,asfvpg_sect	; Section suivante
	sub.w	d4,a1
	dbra	d0,asfvpg_ligne
	rts

asfvpg_limite:
	subq.w	#1,d6		; d6 = compteur … partir de 0
	move.l	a0,a4		; Sauve l'adresse du d‚but de section
asfvpg_pixels2:
	move.b	(a0)+,d3
	move.w	(a2,d3.w),(a3)+
	dbra	d6,asfvpg_pixels2
	lea.l	1(a4,d2.w),a0	; Avance a0 jusqu'… la section suivante
	dbra	d1,asfvpg_finligb	; Section coup‚e, ligne finie
	sub.w	d4,a1
	dbra	d0,asfvpg_ligne
	rts

asfvpg_finligb:
	addq.l	#1,a0
asfvpg_finligne:
	move.b	(a0),d2
	lea.l	2(a0,d2.w),a0
	dbra	d1,asfvpg_finligb
	sub.w	d4,a1
	dbra	d0,asfvpg_ligne
	rts



; Affichage avec flip horizontal et vertical
; En entree :
; a0 : adresse du sprite
; a1 : adresse de l'affichage (coin bas-exterieur droit du sprite)
; a2 : adresse de la palette
; d0 : nombre de lignes - 1 a afficher
; registres egalement modifies :
; d1,d2,d3,d4,a3

affsprite_fliphv:
	moveq	#0,d2
	moveq	#0,d3
	move.l	#640,d4
asfhv_ligne:
	move.l	a1,a3
	moveq	#0,d1
	move.b	(a0)+,d1
asfhv_sect:
	moveq	#0,d2
	move.b	(a0)+,d2
	sub.w	d2,a3
	sub.w	d2,a3
	move.b	(a0)+,d2
asfhv_pixels:
	move.b	(a0)+,d3
	move.w	(a2,d3.w),-(a3)
	dbra	d2,asfhv_pixels
	dbra	d1,asfhv_sect
	sub.w	d4,a1
	dbra	d0,asfhv_ligne
	rts


	DATA

sprite:
comp:	SET	0
	REPT	48
	dc.b	0
	dc.b	47-comp
	dc.b	comp
comp2:	SET	0
	REPT	comp+1
	dc.b	comp2
comp2:	SET	comp2+1
	ENDR
comp:	SET	comp+1
	ENDR

palette:
comp:	SET	$1111
	REPT	48
	dc.w	comp
comp:	SET	comp+1
	ENDR
