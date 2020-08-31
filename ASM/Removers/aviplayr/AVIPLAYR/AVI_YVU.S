; d‚compression indeo raw (YUV9)

; Stabylo / The removers.

; erreurs … corriger :
;	ProblŠme de couleurs. Il fallait signer les valeurs de U et V !!! (corrig‚)

	IFND	YVU9_GREY
YVU9_GREY equ	0
	ENDC
********************************************************************************
	TEXT
********************************************************************************
		IFND	NO_OPT
NO_OPT		equ	1
		ENDC
	IFND	precalculs_uv_bgr
; ne red‚finissons pas une deuxiŠme fois cette routine de pr‚calcul qui
; figure avec le format Cinepak.
precalculs_uv_bgr
	move.l	precalc_uv_bgr_adr(pc),a0
	moveq	#-1,d0
	moveq	#9,d7
boucle_precalc
	move.w	d0,d1

	bfexts	d0{16:5+1},d2	; on isole U (5 bits + 1 bit de trop)
	bset	#0,d2		; on ajoute une moiti‚ d'unit‚
	move.l	d2,d3
	muls.w	#-88,d2	; u->g (-0.34414*256=-88)
	muls.w	#454,d3	; u->b (1.772*256=454)
	bfexts	d0{16+5:5+1},d4	; on prend V (5 bits + 1 bit de trop)
	bset	#0,d4		; on ajoute une moiti‚ d'unit‚
	move.l	d4,d5
	muls.w	#359,d4	; v->r (1.402*256=359)
	muls.w	#-183,d5; v->g (-0.71414*256=-183)
	; d2, d3, d4 et d5 repr‚sentent sur 32 bits la valeur sign‚e voulue
	; multipli‚e par 2^(8-2)
	move.w	d0,d1		; on prend Y
	and.w	#$3f,d1
	lsl.w	#8,d1		; 9+5=6+8 bits
	bset	#7,d1		; on ajoute une moiti‚ d'unit‚

bleu	add.w	d1,d3
	asr.w	d7,d3	; 5+9 -> 5 bits
	bpl.s	.gt1
	clr.w	d3
.gt1	cmp.w	#$20,d3
	blo.s	.vc1	; (d‚passement)
	moveq	#-1,d3
.vc1	
	clr.l	d6
	add.l	d2,d5
vert	add.w	d1,d5
	asr.w	#8,d5
	bpl.s	.gt1
	clr.w	d5
.gt1	cmp.w	#$40,d5
	blo.s	.vc1
	moveq	#-1,d5
.vc1
rouge	add.w	d1,d4
	asr.w	d7,d4
	bpl.s	.gt1
	clr.w	d4
.gt1	cmp.w	#$20,d4
	blo.s	.vc1
	moveq	#-1,d4
.vc1
	bfins	d4,d6{16:5}	; rouge
	bfins	d5,d6{16+5:6}	; vert
	bfins	d3,d6{16+5+6:5}	; bleu
	move.w	d6,0(a0,d0.w*2)
	dbf	d0,boucle_precalc
	rts
	ENDC

decompresse_yvu9
	; a0 : pointe sur le buffer de l'image compress‚e
	move.w	width(pc),a6
	move.w	height(pc),d7
	move.l	taille_image_utile(pc),d0	; en pixels: heigth*width
	lea	(a0,d0.l),a2	; Vptr
	lsr.l	#4,d0		; 16 pixels par bloc
	lea	(a2,d0.l),a1	; Uptr
	move.l	ecran(pc),a3
	move.l	a3,a4
	move.w	a6,d2
	lsr.w	#2,d2
	subq.w	#1,d2
	exg	d2,a6
	move.w	d2,d3
	add.w	d3,d3
	add.w	d2,d3		; 3*taille de ligne utile
	move.l	passe_ligne(pc),d4	; passe_ligne:taille_ligne
	add.w	d4,a4			; une ligne plus bas
	add.w	d4,d4			; deux lignes
	moveq	#-$80,d6
	move.l	precalc_uv_bgr_adr(pc),a5
	lsr.w	#2,d7
	subq.w	#1,d7
;	d0 : y0:y1:y2:y3		a0 : pointe sur le flux entrant (buffer Y)
;	d1 : 0:0:u:v:v			a1 : (buffer U)
;	d2 : largeur utile		a2 : (buffer V)
;	d3 : largeur_utile*3		a3 : ecran
;	d4 : passe_ligne:taille_ligne*2	a4 : ecran, une ligne plus bas
;	d5 : compteur_colonnes.w	a5 : pointe sur precalculs
;	d6 : #$80 pour signer U et V	a6 : compteur_colonnes_init.w
;	d7 : compteur_lignes.w
boucle_lignes		; 2+50+48+48+68 = 216 ‡'est bon !
	move.w	a6,d5		; compteur x
boucle_colonnes
	; ligne 1
	move.l	(a0),d0		; lit 4 Y
	IFEQ	NO_OPT
	clr.l	d1
	ENDC
	move.b	(a1)+,d1	; U
	eor.b	d6,d1		; ARGH !!!! C'‚tait donc ‡a !!!!!!!!
	lsl.w	#5,d1
	move.b	(a2)+,d1	; V
	eor.b	d6,d1		; ARGH !!!! C'‚tait donc ‡a !!!!!!!!
	IF	NO_OPT
	lsl.w	#3,d1
	ELSE
	lsl.l	#5,d1
	ENDC
	IFNE	YVU9_GREY
	clr.l	d1
	ENDC
	IF	NO_OPT
	rol.l	#6,d0
	bfins	d0,d1{16+5+5:6}	; transfert + masque
	move.w	(a5,d1.w*2),(a3)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a3)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a3)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a3)+
	; ligne 2
	add.w	d2,a0
	add.w	d4,a3		; deux lignes plus bas
	subq.w	#8,a3
	move.l	(a0),d0		; lit 4 Y
	rol.l	#6,d0
	bfins	d0,d1{16+5+5:6}	; transfert + masque
	move.w	(a5,d1.w*2),(a4)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a4)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a4)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a4)+
	; ligne 3
	add.w	d2,a0
	add.w	d4,a4
	subq.w	#8,a4
	move.l	(a0),d0		; lit 4 Y
	rol.l	#6,d0
	bfins	d0,d1{16+5+5:6}	; transfert + masque
	move.w	(a5,d1.w*2),(a3)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a3)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a3)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a3)+
	; ligne 4
	add.w	d2,a0
	sub.w	d4,a3
	move.l	(a0)+,d0	; lit 4 Y (on incremente)
	rol.l	#6,d0
	bfins	d0,d1{16+5+5:6}	; transfert + masque
	move.w	(a5,d1.w*2),(a4)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a4)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a4)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a5,d1.w*2),(a4)+

	ELSE
	REPT	4
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a5,d1.l*2),(a3)+
	ENDR
	; lignes 2, 3, 4
	add.w	d2,a0
	add.w	d4,a3		; deux lignes plus bas
	subq.w	#8,a3
	move.l	(a0),d0		; lit 4 Y
	REPT	4
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a5,d1.l*2),(a4)+
	ENDR

	add.w	d2,a0
	add.w	d4,a4		; deux lignes plus bas
	subq.w	#8,a4
	move.l	(a0),d0		; lit 4 Y
	REPT	4
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a5,d1.l*2),(a3)+
	ENDR

	add.w	d2,a0
	sub.w	d4,a3
	move.l	(a0)+,d0		; lit 4 Y (incr)
	REPT	4
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a5,d1.l*2),(a4)+
	ENDR
	ENDC
	sub.w	d4,a4
	sub.w	d3,a0		; revient en arriŠre
	dbf	d5,boucle_colonnes
	add.w	d3,a0		; avance de 3 lignes dans les Y
	swap	d4
	add.w	d4,a3		; retour chariot
	add.w	d4,a4
	swap	d4
	dbf	d7,boucle_lignes
	rts

********************************************************************************
	BSS
********************************************************************************
taille_image_utile
	ds.l	1



