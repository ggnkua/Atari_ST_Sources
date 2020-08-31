; d‚compression cinepak video (CVID)
; version 1.2

; Stabylo / The removers.

; erreurs … corriger :
;	il faudrait positionner les variables passe_ligne et taille_ligne SVP !
;	j'exige qu'… terme, ce soit fait … l'aide des paramŠtres gentiment
;	donn‚s par la VDI (d'o— l'obligation d'utiliser SetScreen).
;	pr‚calculs : u<->v (corrig‚)
;	c1_c4 : changements de palette (corrig‚)
;	modifie palettes : on n'‚tait pas sur 8 bits, mais 5 (corrig‚)
;	compter les y : mauvaise piste (correction : introduction de "curseur"...)
;	NE PAS SAUTER D'IMAGES POUR UNE BETE RAISON DE TAILLE INCORRECTE
;	incr‚mentation du pointeur palettes (corrig‚)
********************************************************************************
		IFND	NO_OPT
NO_OPT		equ	1
		ENDC
CVID_GREY	equ	0
* constante de compilation en module. Mettre 1 si on compile ce module.
		IFND	MODUL
MODUL		equ	0
		ENDC
DEBUG1		equ	0
STRIPSOVERFLOW	equ	1

		IFNE	MODUL
		opt	d-,y-
NEW_PLAYER	equ	1
		include	'modules.s'
		include	'avi_def.s'
		ENDC
		IFND	NEW_PLAYER
NEW_PLAYER	equ	0
		ENDC
TAILLE_PALETTE	equ	2*4*16*256	; = $8000
********************************************************************************
	TEXT
********************************************************************************
	IF	NEW_PLAYER
		IFND	precalcYUVtag
precalcYUVtag	equ	'_YUV'
		ENDC
fini_init_cvid	macro
	movem.l	(sp)+,d1-d7/a1-a6
	endm
****************
init_cvid
	movem.l	d1-d7/a1-a6,-(sp)
* initialise Cinepak CVID
	cmp.l	#_info_pour_codec.video_sizeof,d0
	blo	.pas_assez_parametres
	lea	info_entree_cvid(pc),a1
	lea	(a1),a3
	lsr.l	#1,d0
	subq.l	#1,d0
.copy_par
	move.w	(a0)+,(a1)+
	dbf	d0,.copy_par
	move.l	_info_pour_codec.compression(a3),d0
	cmp.l	#CVIDtag|MIN,d0
	bne	.mauvaise_compression
* initialisations g‚n‚rales
	move.w	_info_pour_codec.largeur(a3),d1
	addq.w	#3,d1
	and.w	#$fffc,d1
	add.w	d1,d1
	move.w	_info_pour_codec.x_ecran(a3),d3
	add.w	d3,d3
	move.w	d3,taille_ligne_cvid
	move.w	d3,d4
	lsl.w	#2,d4
	sub.w	d1,d4
	move.w	d4,passe_ligne_cvid
* Cr‚ation du pr‚calcul YUV
	clr.l	precalc_uv_bgr_adr_cvid
	move.l	#precalcYUVtag,d0
	lea	info_entree_cvid(pc),a3
	jsr	([_info_pour_codec.adr_recherche_precalc.w,a3])
	move.l	a0,a4
	tst.l	d0
	blt.s	.unw_err
	bgt.s	.deja_precalcule_cvid
	* r‚serve la m‚moire
	move.l	#$10000*2,d0
	move.w	#3,d1
	jsr	([_info_pour_codec.adr_mem_alloc.w,a3])
	tst.l	d0
	beq.s	.unw_err
	* cr‚‚ le pr‚calcul
	move.l	#precalcYUVtag,descripteur_precalc.identificateur(a4)
	move.l	d0,descripteur_precalc.adresse_bloc(a4)
	add.l	#$8000*2,d0
	move.l	d0,precalc_uv_bgr_adr_cvid
	bsr.s	precalculs_uv_bgr
	bra.s	.finir_init
.deja_precalcule_cvid
	move.l	descripteur_precalc.adresse_bloc(a4),d0
	add.l	#$8000*2,d0
	move.l	d0,precalc_uv_bgr_adr_cvid
.finir_init
	addq.w	#1,descripteur_precalc.nb_utilisateurs(a4)
	moveq	#0,d0
	lea	info_retour_cvid(pc),a0
	fini_init_cvid
	rts
********
.mauvaise_compression
	moveq	#-1,d0
	fini_init_cvid
	rts
.pas_assez_parametres
	moveq	#-2,d0
	fini_init_cvid
	rts
.unw_err
	moveq	#-3,d0
	fini_init_cvid
	rts
**********************
quit_cvid
	move.l	#precalcYUVtag,d0
	jsr	([info_entree_cvid+_info_pour_codec.adr_libere_precalc.w,pc])
	rts
**********************
	ENDC

	IFND	precalculs_uv_bgr

	IF	NO_OPT		; routine d‚-optimis‚e ?
precalculs_uv_bgr
	movem.l	d0-d7/a0,-(sp)

	IF	NEW_PLAYER
	move.l	precalc_uv_bgr_adr_cvid(pc),a0
	ELSE
	move.l	precalc_uv_bgr_adr(pc),a0
	ENDC
	nop
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
	lsl.w	#8,d1		; 9+5=8+6 bits
	bset	#7,d1		; on ajoute une moiti‚ d'unit‚

.bleu	add.w	d1,d3
	asr.w	d7,d3	; 5+9 -> 5 bits
	bpl.s	.gt1
	clr.w	d3
.gt1	cmp.w	#$20,d3
	blo.s	.vc1	; (d‚passement)
	moveq	#-1,d3
.vc1	
	clr.l	d6
	add.l	d2,d5
.vert	add.w	d1,d5
	asr.w	#8,d5
	bpl.s	.gt2
	clr.w	d5
.gt2	cmp.w	#$40,d5
	blo.s	.vc2
	moveq	#-1,d5
.vc2
.rouge	add.w	d1,d4
	asr.w	d7,d4
	bpl.s	.gt3
	clr.w	d4
.gt3	cmp.w	#$20,d4
	blo.s	.vc3
	moveq	#-1,d4
.vc3
	bfins	d4,d6{16:5}	; rouge
	bfins	d5,d6{16+5:6}	; vert
	bfins	d3,d6{16+5+6:5}	; bleu
	move.w	d6,(a0,d0.w*2)
	dbf	d0,boucle_precalc

	move.w	#$1000-1,d0
	lea	palettes0,a0
.init_pal
	REPT	4
	clr.l	(a0)+
	ENDR
	dbf	d0,.init_pal

	movem.l	(sp)+,d0-d7/a0
	rts

	ELSE		; routine optimis‚e ?
precalculs_uv_bgr
	movem.l	d0-d7/a0,-(sp)

	IF	NEW_PLAYER
	move.l	precalc_uv_bgr_adr_cvid(pc),a0
	ELSE
	move.l	precalc_uv_bgr_adr(pc),a0
	ENDC
	move.l	#$ffff,d0	; il est trŠs important que la partie haute soit nulle
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

.bleu	add.w	d1,d3
	asr.w	d7,d3	; 5+9 -> 5 bits
	bpl.s	.gt1
	clr.w	d3
.gt1	cmp.w	#$20,d3
	blo.s	.vc1	; (d‚passement)
	moveq	#-1,d3
.vc1	
	clr.l	d6
	add.l	d2,d5
.vert	add.w	d1,d5
	asr.w	#8,d5
	bpl.s	.gt2
	clr.w	d5
.gt2	cmp.w	#$40,d5
	blo.s	.vc2
	moveq	#-1,d5
.vc2
.rouge	add.w	d1,d4
	asr.w	d7,d4
	bpl.s	.gt3
	clr.w	d4
.gt3	cmp.w	#$20,d4
	blo.s	.vc3
	moveq	#-1,d4
.vc3
	bfins	d4,d6{16:5}	; rouge
	bfins	d5,d6{16+5:6}	; vert
	bfins	d3,d6{16+5+6:5}	; bleu
	bfins	d6,d6{0:16}
	move.l	d6,0(a0,d0.l*8)		; pas d'extension de signe, cette fois
	move.l	d6,4(a0,d0.l*8)
	dbf	d0,boucle_precalc

	move.w	#$1000-1,d0
	lea	palettes0,a0
.init_pal
	REPT	4
	clr.l	(a0)+
	ENDR
	dbf	d0,.init_pal

	movem.l	(sp)+,d0-d7/a0
	rts
**********************
	ENDC
**********************
	ENDC

decompresse_cvid
	; a0 : pointe sur le buffer de l'image compress‚e
	; d0 : taille du chunk
	lea	general_flags(pc),a1
	moveq	#1,d1
	and.b	(a0)+,d1	; flags
	move.w	d1,(a1)+	;->general_flags

	IFNE	DEBUG1
	move.b	(a0)+,d1	; len
	swap	d1
	move.w	(a0)+,d1
	cmp.l	d0,d1
	bne	mauvaise_taille
	ELSE

	addq.l	#3,a0
	ENDC
taille_ok


	IFNE	NEW_PLAYER
	move.w	(a0)+,d6	; xsize
	swap	d6
	ELSE

	move.w	(a0)+,d2	; xsize.w
	move.w	d2,d6		; on sauve xsize
	swap	d6
	add.w	d2,d2		; true color : 1 pixel = 2 octets
	sub.w	d2,passe_ligne
	ENDC

	IFNE	DEBUG1
	addq.l	#2,a1
	move.w	(a0)+,(a1)+	; et ysize.w
	ELSE
	addq.l	#2,a0		; saute ysize
	ENDC

	move.w	(a0)+,d7	; strips : nombre de palettes utilis‚e dans l'image

	IFNE	STRIPSOVERFLOW
	cmp.w	#16,d7
	bhi	trop_de_palettes
	ENDC

	subq.w	#1,d7
	swap	d7

	IFNE	NEW_PLAYER
	move.l	info_entree_cvid+_info_pour_codec.adr_ecran_centre(pc),a6
	ELSE
	move.l	ecran(pc),a6
	ENDC

	lea	palettes0,a1
	move.l	#TAILLE_PALETTE,a4
	IF	NEW_PLAYER
	move.l	passe_ligne_cvid(pc),d3
	ELSE
	move.l	passe_ligne(pc),d3	; passe_ligne:taille_ligne
	ENDC

	bra.s	entree_boucle
change_palette
	add.w	#256*8,a1
	bra.s	entree_boucle
pour_chaque_palette
	swap	d7
	tst.w	general_flags(pc)	; ce flag interdit la recopie de la palette
	bne.s	change_palette
	move.l	a1,a2
	add.w	#256*8,a2
	move.l	a4,a3
	add.l	a1,a4
	add.l	a2,a3
	move.w	#512-1,d0
.copie_palette
	move.l	(a1)+,(a2)+
	move.l	(a4)+,(a3)+
	dbf	d0,.copie_palette
	sub.l	a1,a4			; restitue TAILLE_PALETTE
entree_boucle
	lea	(a0),a5

	IFNE	DEBUG1
	lea	top_cmd_id(pc),a2
	move.w	(a0)+,(a2)+	; identificateur de commande principale
	add.w	(a0)+,a5	; fin de la commande principale
	move.l	(a0)+,(a2)+	; y0.w et x0.w
	move.w	(a0)+,d7	; y1 : ordonn‚e maximale
	move.w	d7,(a2)+
	move.w	(a0)+,(a2)	; x1.w

	ELSE
	addq.l	#2,a0		; ingnore top_id
	add.w	(a0)+,a5	; fin de la commande
	addq.l	#4,a0
	move.w	(a0)+,d7	; y1 : ordonn‚e maximale
	addq.l	#2,a0
	ENDC
pour_faire_la_commande_principale
	cmp.l	a0,a5
	bls	fin_commande_principale
	move.l	(a0)+,d5	; cmd_id.w et cmd_size.w
	subq.w	#4,d5		; on saute cmd_id et cmd_size
pp	btst.l	#12+16,d5
	bne	commandes_image
commandes_palettes
; durant les modif de palette : 
;	d0 : y0:y1:y2:y3		a0 : pointe sur le flux entrant (buffer)
;	d1 : 0:uv_b:uv_g:uv_r		a1 : flux sortant (palette trait‚e)
;	d2 : sauvegarde palette 0	a2 : fin de la commande
;	d3 : passe_ligne:taille_ligne	a3 : pointe sur precalculs
;	d4 : flags de modif partielle	a4 : TAILLE_PALETTE
;	d5 : compteur de bits		a5 : fin commande principale
;	d6 : xsize.w:--.w		a6 : curseur_ecran
;	d7 : strips.w:ordonn‚e.w
	IF	NEW_PLAYER
	move.l	precalc_uv_bgr_adr_cvid(pc),a3
	ELSE
	move.l	precalc_uv_bgr_adr(pc),a3
	ENDC
	lea	(a0,d5.w),a2	; a2 : fin de la commande de modification
	move.l	a1,d2
	btst.l	#9+16,d5		; diff‚rentie palette 0 ou 1
	beq.s	.palette_choisie
	add.l	a4,a1
.palette_choisie
	btst.l	#8+16,d5
	bne.s	modif_partielle
modif_complete
	bfclr	d5{0:16}; pour le divu
	IF	NO_OPT
	divu.w	#6,d5	; paquets de 6 octets.
	subq.w	#1,d5
	ELSE
	subq.w	#6,d5
	ENDC
	bmi.s	_fin_m
boucle_index_palette
************************ 50 octets contre 10+3*68 !!!
	move.l	(a0)+,d0	; lit 4 couleurs
	IF	NO_OPT
	move.w	(a0)+,d1
	bfins	d1,d1{16+5:8}	; copie 5 bits de V
	rol.l	#6,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a3,d1.w*2),(a1)+	; attention, il y a extension du signe
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a3,d1.w*2),(a1)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a3,d1.w*2),(a1)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a3,d1.w*2),(a1)+
	ELSE
	clr.l	d1		; 42 octets au lieu de 48. Un gain assez mince.
	IF	CVID_GREY
	addq.l	#2,a0
	ELSE
	move.w	(a0)+,d1
	lsl.l	#2,d1
	bfins	d1,d1{14+5:5+3+2}	; copie 5 bits de V
	ENDC
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a3,d1.l*2),(a1)+
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a3,d1.l*2),(a1)+
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a3,d1.l*2),(a1)+
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a3,d1.l*2),(a1)+
	ENDC
************************
fin_1_couleur
	IF	NO_OPT
	dbf	d5,boucle_index_palette	; fin de 4 couleurs
	ELSE
	subq.w	#6,d5
	bpl.s	boucle_index_palette
	ENDC
_fin_m	move.l	a2,a0	; se place … la fin de la commande
	move.l	d2,a1
	bra.s	pour_faire_la_commande_principale

modif_partielle
.un_flag
	cmp.l	a0,a2
	bls.s	.fin_modif_partielle_palette
	move.l	(a0)+,d4	; flags de modif
	moveq	#32-1,d5
.un_bit
	addq.l	#8,a1
	lsl.l	#1,d4
	dbcs	d5,.un_bit
	bcc.s	.un_flag	; si carry=0, alors d5=-1 et on a rien … faire
* si le bit vaut 1, on finit de s'en occuper
	subq.l	#8,a1		; il faut revenir en arriŠre (bidouille)
	move.l	(a0)+,d0	; lit 4 couleurs
	IF	NO_OPT
	move.w	(a0)+,d1
	bfins	d1,d1{16+5:8}
	rol.l	#6,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a3,d1.w*2),(a1)+	; attention, il y a extension du signe
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a3,d1.w*2),(a1)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a3,d1.w*2),(a1)+
	rol.l	#8,d0
	bfins	d0,d1{16+5+5:6}
	move.w	(a3,d1.w*2),(a1)+

	ELSE
	clr.l	d1		; 42 octets au lieu de 48. Un gain assez mince.
	IF	CVID_GREY
	addq.l	#2,a0
	ELSE
	move.w	(a0)+,d1
	lsl.l	#2,d1
	bfins	d1,d1{14+5:10}	; copie 5 bits de V
	ENDC
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a3,d1.l*2),(a1)+
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a3,d1.l*2),(a1)+
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a3,d1.l*2),(a1)+
	rol.l	#8,d0
	move.b	d0,d1
	move.w	(a3,d1.l*2),(a1)+
	ENDC
._fin_1_couleur
	subq.w	#1,d5	; pas de dbf, parce que si on vient d'executer
	bpl.s	.un_bit	; le dernier bit, alors d5 = -1
	bra.s	.un_flag
.fin_modif_partielle_palette
	move.l	a2,a0
	move.l	d2,a1
	bra	pour_faire_la_commande_principale
	
commandes_image
	move.l	a6,a2		; curseur_ecran
	lea	(a0,d5.w),a6	; fin de la commande
	swap	d6
	bfins	d6,d6{0:16}	; sauve la valeur d'initialisation (xsize)
	lea	(a2,d3.w),a3	; une ligne plus bas
	lsl.w	#1,d3		; taille de 2 lignes
	add.l	a1,a4		; palettes 1
	btst	#8+16,d5
	beq	modif_img_complet
modif_image_partielle
;	d0 : index 			a0 : pointe sur le flux entrant
;	d1 : couleurs 1/2		a1 : palette courante 0
;	d2 : couleurs 3/4		a2 : pointe sur l'‚cran
;	d3 : passe_ligne:taille_ligne	a3 : sur l'‚cran, mais une ligne plus bas
;	d4 : flags de modification	a4 : palette courrante 1
;	d5 : cmd_id.w:cmd_size.w	a5 : fin commande principale
;		PUIS compteur dbf de bits
;	d6 : xsize:abscisse		a6 : fin de la commande
;	d7 : strips.w:ordonn‚e.w
	clr.l	d0
**********************
.un_flag		; 14+20+24+76+32+74=244 octets ! c'est juste !
	cmp.l	a0,a6
	bls	._fin
	move.l	(a0)+,d4
	moveq	#31,d5
	lsl.l	#1,d4
	bcs.s	.autre_bit
.saute_bloc	; 20 octets
	addq.l	#8,a2
	addq.l	#8,a3
	subq.w	#4,d6
	bls.s	.passe_ligne
	lsl.l	#1,d4
	dbcs	d5,.saute_bloc	; bit = 0
	dbcc	d5,.autre_bit	; bit = 1
	bra.s	.un_flag
.autre_bit	; 24 octets
	lsl.l	#1,d4
	dbcc	d5,.bloc_c4	; bit = 1
	dbcs	d5,.bloc_c1	; bit = 0
	; cas de retenue
	cmp.l	a0,a6
	bls	._fin
	move.l	(a0)+,d4
	moveq	#31,d5
	lsl.l	#1,d4
	bcc.s	.bloc_c1
.bloc_c4	; 76 octets
	move.b	(a0)+,d0
	movem.l	0(a1,d0.w*8),d1/d2
	move.l	d1,(a2)+
	move.l	d2,(a3)+
	move.b	(a0)+,d0
	movem.l	0(a1,d0.w*8),d1/d2
	move.l	d1,(a2)+
	add.w	d3,a2
	subq.l	#8,a2
	move.l	d2,(a3)+
	add.w	d3,a3
	subq.l	#8,a3
	move.b	(a0)+,d0
	movem.l	0(a1,d0.w*8),d1/d2
	move.l	d1,(a2)+
	move.l	d2,(a3)+
	move.b	(a0)+,d0
	movem.l	0(a1,d0.w*8),d1/d2
	move.l	d1,(a2)+
	sub.w	d3,a2
	move.l	d2,(a3)+
	sub.w	d3,a3
	
	subq.w	#4,d6
	bls.s	.passe_ligne
	lsl.l	#1,d4
	dbcc	d5,.autre_bit	; bit = 1
	dbcs	d5,.saute_bloc	; bit = 0
	bra	.un_flag
.passe_ligne	; 32 octets
	swap	d3
	add.w	d3,a2
	add.w	d3,a3
	swap	d3
	subq.w	#4,d7		; une ligne de plus
	bls.s	.fin_cause_y
	swap	d6
	bfins	d6,d6{0:16}	; sauve la valeur d'initialisation (xsize/4-1)
	lsl.l	#1,d4
	dbcs	d5,.saute_bloc	; bit = 0
	dbcc	d5,.autre_bit	; bit = 1
	bra	.un_flag
.bloc_c1	; 74 octets
	move.b	(a0)+,d0
	movem.l	0(a4,d0.w*8),d1/d2
	swap	d1
	move.w	d1,(a2)+
	move.w	d1,(a2)+
	move.w	d1,(a3)+
	move.w	d1,(a3)+
	swap	d1
	move.w	d1,(a2)+
	move.w	d1,(a2)+
	add.w	d3,a2
	move.w	d1,(a3)+
	subq.l	#8,a2
	move.w	d1,(a3)+
	swap	d2
	move.w	d2,(a2)+
	add.w	d3,a3
	move.w	d2,(a2)+
	subq.l	#8,a3
	move.w	d2,(a3)+
	move.w	d2,(a3)+
	swap	d2
	move.w	d2,(a2)+
	move.w	d2,(a2)+
	sub.w	d3,a2
	move.w	d2,(a3)+
	move.w	d2,(a3)+
	sub.w	d3,a3
	
	subq.w	#4,d6
	bls.s	.passe_ligne
	lsl.l	#1,d4
	dbcs	d5,.saute_bloc	; bit = 0
	dbcc	d5,.autre_bit	; bit = 1
	bra	.un_flag
**********************
.fin_cause_y
	move.l	a6,a0
	move.l	a2,a6	; on sauve curseur_ecran
	sub.l	a1,a4	; restitue TAILLE_PALETTE
	lsr.w	#1,d3	; restitue taille_ligne
	bra	pour_faire_la_commande_principale
._fin
	IFNE	NEW_PLAYER&(~MODUL)
	move.l	#(1<<bitCorrErr),d0
	bsr	erreur
	bra	fini_cvid
	ENDC
	rts

modif_img_complet
	btst	#9+16,d5
	bne	modif_grossiere_c1
modif_complete_c1_c4
	clr.l	d0
**********************	; 14+76+32+78 = 200 octets, ‡a tient dans le cache !!!
.un_flag
	cmp.l	a0,a6
	bls	._fin
	move.l	(a0)+,d4
	moveq	#31,d5
	lsl.l	#1,d4
	bcc.s	.bloc_c1
.bloc_c4	; 76 octets
	move.b	(a0)+,d0
	movem.l	0(a1,d0.w*8),d1/d2
	move.l	d1,(a2)+
	move.l	d2,(a3)+
	move.b	(a0)+,d0
	movem.l	0(a1,d0.w*8),d1/d2
	move.l	d1,(a2)+
	add.w	d3,a2
	subq.l	#8,a2
	move.l	d2,(a3)+
	add.w	d3,a3
	subq.l	#8,a3
	move.b	(a0)+,d0
	movem.l	0(a1,d0.w*8),d1/d2
	move.l	d1,(a2)+
	move.l	d2,(a3)+
	move.b	(a0)+,d0
	movem.l	0(a1,d0.w*8),d1/d2
	move.l	d1,(a2)+
	sub.w	d3,a2
	move.l	d2,(a3)+
	sub.w	d3,a3
	
	subq.w	#4,d6
	bls.s	.passe_ligne
	lsl.l	#1,d4
	dbcc	d5,.bloc_c4	; bit = 1
	dbcs	d5,.bloc_c1	; bit = 0
	bra.s	.un_flag

.bloc_c1	; 74 octets
	move.b	(a0)+,d0
	movem.l	0(a4,d0.w*8),d1/d2
	swap	d1
	move.w	d1,(a2)+
	move.w	d1,(a2)+
	move.w	d1,(a3)+
	move.w	d1,(a3)+
	swap	d1
	move.w	d1,(a2)+
	move.w	d1,(a2)+
	add.w	d3,a2
	move.w	d1,(a3)+
	subq.l	#8,a2
	move.w	d1,(a3)+
	swap	d2
	move.w	d2,(a2)+
	add.w	d3,a3
	move.w	d2,(a2)+
	subq.l	#8,a3
	move.w	d2,(a3)+
	move.w	d2,(a3)+
	swap	d2
	move.w	d2,(a2)+
	move.w	d2,(a2)+
	sub.w	d3,a2
	move.w	d2,(a3)+
	move.w	d2,(a3)+
	sub.w	d3,a3
	
	subq.w	#4,d6
	bls.s	.passe_ligne
	lsl.l	#1,d4
	dbcc	d5,.bloc_c4	; bit = 1
	dbcs	d5,.bloc_c1	; bit = 0
	bra	.un_flag
.passe_ligne	; 32 octets
	swap	d3
	add.w	d3,a2
	add.w	d3,a3
	swap	d3
	subq.w	#4,d7
	bls.s	.fin_cause_y
	swap	d6
	bfins	d6,d6{0:16}
	lsl.l	#1,d4
	dbcc	d5,.bloc_c4	; bit = 1
	dbcs	d5,.bloc_c1	; bit = 0
	bra	.un_flag
**********************
.fin_cause_y
	move.l	a6,a0
	move.l	a2,a6	; on sauve curseur_ecran
	sub.l	a1,a4
	lsr.w	#1,d3	; restitue taille_ligne
	bra	pour_faire_la_commande_principale
._fin
	IFNE	NEW_PLAYER&(~MODUL)
	move.l	#(1<<bitCorrErr),d0
	bsr	erreur
	bra	fini_cvid
	ENDC
	rts
modif_grossiere_c1
; durant la modif grossiŠre : 
;	d0 : index 			a0 : pointe sur le flux entrant
;	d1 : couleurs 1/2		a1 : palette courante 0
;	d2 : couleurs 3/4		a2 : pointe sur l'‚cran
;	d3 : passe_ligne:taille_ligne	a3 : sur l'‚cran, mais une ligne plus bas
;	d4 : --				a4 : palette courante 1
;	d5 : cmd_id.w:cmd_size.w	a5 : fin commande principale
;	     PUIS compteur dbf 1 ligne
;	d6 : xsize.w			a6 : fin de la commande
;	d7 : strips.w:ordonn‚e.w
.une_ligne
	cmp.l	a0,a6
	bls.s	.fin_modif_grossiere
	move.w	d6,d5		; d5 initialis‚ … xsize/4-1
	lsr.w	#2,d5
	subq.w	#1,d5
	clr.w	d0
	move.b	(a0)+,d0
.pour_une_ligne
	movem.l	0(a4,d0.w*8),d1/d2
	swap	d1
	move.w	d1,(a2)+
	move.w	d1,(a2)+
	move.w	d1,(a3)+
	move.w	d1,(a3)+
	swap	d1
	move.w	d1,(a2)+
	move.w	d1,(a2)+
	add.w	d3,a2
	move.w	d1,(a3)+
	subq.l	#8,a2
	move.w	d1,(a3)+
	swap	d2
	move.w	d2,(a2)+
	add.w	d3,a3
	move.w	d2,(a2)+
	subq.l	#8,a3
	move.w	d2,(a3)+
	move.w	d2,(a3)+
	swap	d2
	move.w	d2,(a2)+
	move.w	d2,(a2)+
	sub.w	d3,a2
	move.w	d2,(a3)+
	move.w	d2,(a3)+
	sub.w	d3,a3
	move.b	(a0)+,d0
	dbf	d5,.pour_une_ligne
	swap	d3
	add.w	d3,a2
	add.w	d3,a3
	swap	d3
	bra.s	.une_ligne
.fin_modif_grossiere
	move.l	a6,a0
	move.l	a2,a6	; on sauve curseur_ecran
	sub.l	a1,a4
	lsr.w	#1,d3	; restitue taille_ligne
	bra	pour_faire_la_commande_principale

fin_commande_principale
	lea	(a5),a0	; on se place … la fin de la commande
	swap	d7		; ordonn‚e
	dbf	d7,pour_chaque_palette
fini_cvid
	rts
*************************************************
	IFNE	DEBUG1
	; erreurs
mauvaise_taille
	addq.l	#1,d1
	cmp.l	d0,d1
	beq	taille_ok
	moveq	#-1,d2
	IFNE	MODUL
	move.l	info_entree_cvid+_info_pour_codec.adr_ecran_centre(pc),a2
	ELSE
	move.l	ecran(pc),a2
	ENDC
	move.l	d2,(a2)+
	move.l	d2,(a2)
	bra	taille_ok
	ENDC
trop_de_palettes

	IFNE	NEW_PLAYER&(~MODUL)
	move.l	#(1<<bitGoodErr),d0
	bsr	erreur
	ENDC

	rts

********************************************************************************
	DATA
********************************************************************************
	IFEQ	NEW_PLAYER
precalc_uv_bgr_adr
	dc.l	buff_prec_uv
	
	ELSE
info_retour_cvid
	dc.l	decompresse_cvid
	dc.l	0
	dc.l	quit_cvid
	ENDC
********************************************************************************
	BSS
********************************************************************************
	IF	NEW_PLAYER
precalc_uv_bgr_adr_cvid
	ds.l	1
	ENDC
general_flags
	ds.w	1
xsize	ds.w	1
ysize	ds.w	1

top_cmd_id
	ds.w	1
_y0	ds.w	1
_x0	ds.w	1
_y1	ds.w	1
_x1	ds.w	1

	IFEQ	NEW_PLAYER
passe_ligne
	ds.w	1
taille_ligne
	ds.w	1

	ELSE
passe_ligne_cvid
	ds.w	1
taille_ligne_cvid
	ds.w	1
info_entree_cvid
	ds.b	_info_pour_codec.video_sizeof
	even
	IF	MODUL
	; Il y a deux type de palette (0 pour les blocs C4, 1 pour les C1)
	; un type de palette contient 16 palettes de 256 entr‚es
	; une entree contient 4 couleurs.
	; il faut donc 1 entr‚e pour un bloc C1 et 4 pour un bloc C4
palettes0
	ds.b	TAILLE_PALETTE
palettes1
	ds.w	TAILLE_PALETTE
	ENDC
	ENDC
