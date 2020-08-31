; d‚compression Indel video : indeo (IV32)
; version 2.1 adapt‚e … AviPlayer
;	   _
;	  / \
;	 / ! \ cette adaptation est *incompatible* avec le module d'Animator
;	/_____\ (la variable NEW_PLAYER=1 ferait tout foirer)

; Stabylo / The removers.

; erreurs … corriger :
;
; proc‚dures pr‚sentes
;	init_iv32
;	free_blocs
;	quit_iv32
;	precalculs_yuv_grey_iv32
;	precalculs_yuv_iv32
;	precalculs_multiples_signes_iv32
;	decode_iv32
; 	dec_plane_iv32
;		.separations
;			.bt_horiz		(%00)
;			.bt_vert		(%01)
;		.commandes
;			.valide_mv		(%10)
;			.remplissage		(%11)
;				..bt_rel_fill
;				..bt_vq_data
;					.mode_0
;					.mode_0_pmv
;					.mode_1
;					.mode_4
;					.mode_3
;					.mode_10
;					.mode_10_pmv
;					.mode_11
;				.cellule_suivante
;	convert_yuv_grey_iv32
********************************************************************************
OPT_IV32	equ	1^NO_OPT
CALLS_TO_BSS	equ	1
THE_PIC		equ	0
XA_DEBUG	equ	0
HP_OBJ		equ	0
BSD_OBJ		equ	1
POS_Y		equ	1
DEBUG_IV32	equ	0
		IFND	OBJ_TYP
OBJ_TYP		equ	BSD_OBJ		;0=HP_OBJ/1=BSD_OBJ
		ENDC
		IFND	OPT_IV32
OPT_IV32	equ	1
		ENDC
		IFND	OUT_FILE
OUT_FILE	equ	0
		ENDC
		IFND	OUT_SCREEN
OUT_SCREEN	equ	0
		ENDC
* constante de compilation en module. Mettre 1 si on compile ce module.
		IFND	MODUL
MODUL		equ	0
		ENDC

		IF	MODUL
		MC68030
		opt	d-,y-,ow-
NEW_PLAYER	equ	1
		include	'gemdos.s'
		include	'modules.s'
		include	'avi_def.s'
		ENDC

		IFND	NEW_PLAYER
NEW_PLAYER	equ	0
		ENDC
********************************************************************************
	TEXT
********************************************************************************

		IFND	precalcYUV2tag
		IF	OPT_IV32
precalcYUV2tag	equ	'YUV2'		; pr‚calcul am‚lior‚
		ELSE
precalcYUV2tag	equ	'_YUV'		; pr‚calcul standard
		ENDC
		ENDC
fini_init_iv32	macro
	movem.l	(sp)+,d1-d7/a1-a6
	endm
****************
init_iv32
	movem.l	d1-d7/a1-a6,-(sp)
* initialise Indeo iv32
	moveq	#info_init_codec.video_sizeof,d1
	cmp.l	d1,d0
	blo	.pas_assez_parametres
	lea	info_entree_iv32(pc),a1
	lea	(a1),a3
	lsr.l	#1,d1
	subq.l	#1,d1
.copy_parametres
	move.w	(a0)+,(a1)+
	dbf	d1,.copy_parametres

	IF	NEW_PLAYER
	move.l	info_init_codec.compression(a3),d0
	cmp.l	#IV31tag|MIN,d0
	beq.s	.supported
	cmp.l	#IV32tag|MIN,d0
	beq.s	.supported
	cmp.l	#IR31tag|MIN,d0
	beq.s	.supported
	cmp.l	#IR32tag|MIN,d0
	bne	.mauvaise_compression
.supported
	ENDC

* initialisations g‚n‚rales
	clr.l	indeo_o
	lea	info_entree_iv32(pc),a3
* variables sp‚cifiques
	move.w	info_init_codec.hauteur(a3),d1
	addq.w	#3,d1
	and.w	#-4,d1
	move.w	d1,height_iv32
	lsr.w	#2,d1
	addq.w	#3,d1
	and.w	#-4,d1
	move.w	d1,height_uv_iv32
	move.w	info_init_codec.largeur(a3),d1
	addq.w	#3,d1
	and.w	#-4,d1
	move.w	d1,width_iv32
	move.w	d1,d2
	lsr.w	#2,d2
	addq.w	#3,d2
	and.w	#-4,d2
	move.w	d2,width_uv_iv32
	add.w	d1,d1
	move.w	info_init_codec.x_ecran(a3),d3
	add.w	d3,d3
	move.w	d3,taille_ligne_iv32
	move.w	d3,d4
	lsl.w	#2,d4
	sub.w	d1,d4
	move.w	d4,passe_ligne_iv32
* mise en place du fichier Indeo
	move.l	#indeo_ice,indeo_o
* pour le plan Y
	move.w	width_iv32(pc),d0
	move.w	#160,d1
	cmp.w	d1,d0
	bhi.s	.width_petit
	move.w	d0,d1
.width_petit
;	move.w	d1,strip_width_iv32
	move.w	d1,d2
	bra.s	*+4
.calc_first_width
	add.w	d1,d1
	cmp.w	d0,d1		; tant que sp->Width<width, sp->width*=2
	blo.s	.calc_first_width
	move.w	d1,first_width_iv32
	move.w	d0,d1
.calc_last_strip_left
	sub.w	d2,d1
	cmp.w	d2,d1
	bhi.s	.calc_last_strip_left
	move.w	d1,last_strip_left_y_iv32
	sub.w	d1,d0
	move.w	d0,pos_last_strip_iv32
* pour les plans U et V
	move.w	width_uv_iv32(pc),d0
	move.w	#40,d1
	cmp.w	d1,d0
	bhi.s	.width_petit_uv
	move.w	d0,d1
.width_petit_uv
;	move.w	d1,strip_width_uv_iv32
	move.w	d1,d2
	bra.s	*+4
.calc_first_width_uv
	add.w	d1,d1
	cmp.w	d0,d1		; tant que sp->Width<width, sp->width*=2
	blo.s	.calc_first_width_uv
	move.w	d1,first_width_uv_iv32
	move.w	d0,d1
.calc_last_strip_left_uv
	sub.w	d2,d1
	cmp.w	d2,d1
	bhi.s	.calc_last_strip_left_uv
	move.w	d1,last_strip_left_uv_iv32
	sub.w	d1,d0
	move.w	d0,pos_last_strip_uv_iv32

* libŠre les buffers YUV
	bsr	free_blocs
* allocation des buffers YUV
	move.w	height_iv32(pc),d3
	addq.w	#1,d3
	clr.l	d4
	move.w	width_iv32(pc),d4
	mulu.w	d4,d3
	moveq	#15,d5
	move.w	height_uv_iv32(pc),d6
	addq.w	#1,d6
	clr.L	d7
	move.w	width_uv_iv32(pc),d7
	mulu.w	d7,d6
	move.l	d3,d0
	add.l	d6,d0
	add.l	d6,d0
	add.l	d5,d0
	moveq	#3,d1
	IF	NEW_PLAYER
	jsr	([info_init_codec.adr_mem_alloc.w,a3])
	ELSE
	Mxalloc	d0,d1
	ENDC
	move.l	d0,y1_buffer_adr_bloc		; assez de m‚moire pour y1_buffer ?
	beq	.unw_err
	move.l	d0,a4
	add.l	d5,d0
	and.w	#$fff0,d0
	add.l	d4,d0
	move.l	d0,y1_buffer
	sub.l	d4,d0
	add.l	d3,d0
	add.l	d7,d0
	move.l	d0,u1_buffer
	add.l	d6,d0
	move.l	d0,v1_buffer
	move.l	d3,d0
	add.l	d6,d0
	add.l	d6,d0
	add.l	d5,d0
	moveq	#3,d1
	IF	NEW_PLAYER
	jsr	([info_init_codec.adr_mem_alloc.w,a3])
	ELSE
	Mxalloc	d0,d1
	ENDC
	move.l	d0,y2_buffer_adr_bloc		; assez de m‚moire pour y2_buffer ?
	beq	.unw_err_free_blocs
	move.l	d0,a5
	add.l	d5,d0
	and.w	#$fff0,d0
	add.l	d4,d0
	move.l	d0,y2_buffer
	sub.l	d4,d0
	add.l	d3,d0
	add.l	d7,d0
	move.l	d0,u2_buffer
	add.l	d6,d0
	move.l	d0,v2_buffer
	* efface ces buffers
	move.l	#$40404040,d4
	add.l	d6,d3
	add.l	d6,d3
	lsr.l	#3,d3
	subq.l	#1,d3
	ble.s	.efface_pas
	swap	d3
.eff_bcl_y
	swap	d3
.eff_bcl_x
	move.l	d4,(a4)+
	move.l	d4,(a5)+
	move.l	d4,(a4)+
	move.l	d4,(a5)+
	dbf	d3,.eff_bcl_x
	swap	d3
	dbf	d3,.eff_bcl_y
.efface_pas
* Cr‚ation du pr‚calcul des multiples Y
	IF	NEW_PLAYER
	clr.l	precalc_multiples_iv32
	move.l	#precalcMULStag,d0
	lea	info_entree_iv32(pc),a3
	jsr	([info_init_codec.adr_recherche_precalc.w,a3])
	move.l	a0,a4
	tst.l	d0
	blt	.unw_err_free_blocs
	bgt.s	.deja_precalcule_muls_iv32
	ELSE
	tst.l	precalc_multiples_y_adr_bloc_iv32
	bne.s	.deja_precalcule_muls_iv32
	ENDC
.faire_precalcul
	* r‚serve la m‚moire
	clr.l	d0
	move.w	height_iv32(pc),d0
	add.w	#130+16,d0		; pour stocker la hauteur et les valeurs -128..0
	lsl.l	#2,d0		; tout est stock‚ comme des mots longs
	move.w	#3,d1
	IF	NEW_PLAYER
	jsr	([info_init_codec.adr_mem_alloc.w,a3])
	ELSE
	Mxalloc	d0,d1
	ENDC
	tst.l	d0
	beq	.unw_err_free_blocs
	* cr‚‚ le pr‚calcul
	IF	NEW_PLAYER
	move.l	#precalcMULStag,descripteur_precalc.identificateur(a4)
	move.l	d0,descripteur_precalc.adresse_bloc(a4)
	ELSE
	move.l	d0,precalc_multiples_y_adr_bloc_iv32
	ENDC
	addq.l	#8,d0
	addq.l	#7,d0
	and.w	#$fff0,d0; on s'aligne car‚ment sur la taille d'une ligne de cache !
	clr.l	d1
	move.w	height_iv32(pc),d1
	move.l	d0,a0
	move.l	d1,(a0)
	add.w	#129*4,a0	; sauter la hauteur et les valeurs n‚gatives
	move.l	a0,precalc_multiples_y_iv32
	move.l	a0,precalc_multiples_iv32
	clr.l	d0
	move.w	width_iv32(pc),d0
	bsr	precalculs_multiples_signes_iv32
	bra.s	.fini_precalcule_muls
.deja_precalcule_muls_iv32
	IF	NEW_PLAYER
	move.l	descripteur_precalc.adresse_bloc(a4),d0
	ELSE
	move.l	precalc_multiples_y_adr_bloc_iv32,d0
	ENDC
	addq.l	#8,d0
	addq.l	#7,d0
	and.w	#$fff0,d0; on s'aligne car‚ment sur la taille d'une ligne de cache !
	move.l	d0,a5
	move.l	(a5),d1
	cmp.w	width_iv32(pc),d1
	bne.s	.recalculer
	add.w	#129*4,a5	; sauter la hauteur et les valeurs n‚gatives
	clr.l	d1
	move.w	height_iv32(pc),d1
	cmp.l	4(a5),d1	; sauter le 0
	beq.s	.pas_recalculer
.recalculer
	IF	NEW_PLAYER
	Mfree	descripteur_precalc.adresse_bloc(a4)
	clr.l	descripteur_precalc.adresse_bloc(a4)
	ELSE
	Mfree	precalc_multiples_y_adr_bloc_iv32
	clr.l	precalc_multiples_y_adr_bloc_iv32
	ENDC
	bra	.faire_precalcul
.pas_recalculer
	move.l	a5,precalc_multiples_y_iv32
.fini_precalcule_muls
	IF	NEW_PLAYER
	addq.w	#1,descripteur_precalc.nb_utilisateurs(a4)
	ENDC
* Cr‚ation du pr‚calcul des multiples U V
	clr.l	precalc_multiples_iv32
	IF	NEW_PLAYER
	move.l	#precalcMULS2tag,d0
	lea	info_entree_iv32(pc),a3
	jsr	([info_init_codec.adr_recherche_precalc.w,a3])
	move.l	a0,a4
	tst.l	d0
	blt	.unw_err_free_blocs
	bgt.s	.deja_precalcule_muls_uv_iv32
	ELSE
	tst.l	precalc_multiples_uv_adr_bloc_iv32
	bne.s	.deja_precalcule_muls_uv_iv32
	ENDC
.faire_precalcul_uv
	* r‚serve la m‚moire
	clr.l	d0
	move.w	height_uv_iv32(pc),d0
	add.w	#130+16,d0		; pour stocker la hauteur et les valeurs -128..0
	lsl.l	#2,d0		; tout est stock‚ comme des mots longs
	move.w	#3,d1
	IF	NEW_PLAYER
	jsr	([info_init_codec.adr_mem_alloc.w,a3])
	ELSE
	Mxalloc	d0,d1
	ENDC
	tst.l	d0
	beq	.unw_err_free_blocs
	* cr‚‚ le pr‚calcul
	IF	NEW_PLAYER
	move.l	#precalcMULS2tag,descripteur_precalc.identificateur(a4)
	move.l	d0,descripteur_precalc.adresse_bloc(a4)
	ELSE
	move.l	d0,precalc_multiples_uv_adr_bloc_iv32
	ENDC
	addq.l	#8,d0
	addq.l	#7,d0
	and.w	#$fff0,d0; on s'aligne car‚ment sur la taille d'une ligne de cache !
	clr.l	d1
	move.w	height_uv_iv32(pc),d1
	move.l	d0,a0
	move.l	d1,(a0)
	add.w	#129*4,a0	; sauter la hauteur et les valeurs n‚gatives
	move.l	a0,precalc_multiples_uv_iv32
	move.l	a0,precalc_multiples_iv32
	clr.l	d0
	move.w	width_uv_iv32(pc),d0
	bsr	precalculs_multiples_signes_iv32
	bra.s	.fini_precalcule_muls_uv
.deja_precalcule_muls_uv_iv32
	IF	NEW_PLAYER
	move.l	descripteur_precalc.adresse_bloc(a4),d0
	ELSE
	move.l	precalc_multiples_uv_adr_bloc_iv32,d0
	ENDC
	addq.l	#8,d0
	addq.l	#7,d0
	and.w	#$fff0,d0; on s'aligne car‚ment sur la taille d'une ligne de cache !
	move.l	d0,a5
	move.l	(a5),d1
	cmp.w	height_uv_iv32(pc),d1
	bne.s	.recalculer_uv
	add.w	#129*4,a5	; sauter la hauteur et les valeurs n‚gatives
	clr.l	d1
	move.w	width_uv_iv32(pc),d1
	cmp.l	4(a5),d1	; sauter le 0
	beq.s	.pas_recalculer_uv
.recalculer_uv
	IF	NEW_PLAYER
	Mfree	descripteur_precalc.adresse_bloc(a4)
	clr.l	descripteur_precalc.adresse_bloc(a4)
	ELSE
	Mfree	precalc_multiples_uv_adr_bloc_iv32
	clr.l	precalc_multiples_uv_adr_bloc_iv32
	ENDC
	bra	.faire_precalcul_uv
.pas_recalculer_uv
	move.l	a5,precalc_multiples_uv_iv32
.fini_precalcule_muls_uv
	IF	NEW_PLAYER
	addq.w	#1,descripteur_precalc.nb_utilisateurs(a4)
	ENDC
* Cr‚ation du pr‚calcul YUV

	IF	NEW_PLAYER
	clr.l	precalc_uv_bgr_adr_iv32
	move.l	#precalcYUV2tag,d0
	lea	info_entree_iv32(pc),a3
	jsr	([info_init_codec.adr_recherche_precalc.w,a3])
	move.l	a0,a4
	tst.l	d0			; le pr‚calcul existe-t-il d‚j… ?
	blt	.unw_err
	bgt.s	.deja_precalcule_iv32
	ELSE
	move.l	precalc_uv_bgr_adr(pc),prec_yuv_iv32
	bne.s	.deja_precalcule_iv32
	ENDC
	* r‚serve la m‚moire
	IF	OPT_IV32
	move.l	#$10000*2*4+16,d0
	ELSE
	move.l	#$10000*2+16,d0
	ENDC
	moveq	#3,d1
	IF	NEW_PLAYER
	jsr	([info_init_codec.adr_mem_alloc.w,a3])
	ELSE
	Mxalloc	d0,d1
	ENDC
	tst.l	d0
	beq.s	.unw_err
	* cr‚‚ le pr‚calcul

	IF	NEW_PLAYER
	move.l	#precalcYUV2tag,descripteur_precalc.identificateur(a4)
	move.l	d0,descripteur_precalc.adresse_bloc(a4)
	ELSE
	move.l	prec_yuv_iv32,precalc_uv_bgr_adr
	ENDC

	IF	OPT_IV32
	add.l	#15,d0
	ELSE
	add.l	#$8000*2+15,d0
	ENDC
	and.w	#$fff0,d0	; on s'aligne sur une ligne de cache !
	move.l	d0,prec_yuv_iv32
	move.l	d0,precalc_uv_bgr_adr
	bsr.s	precalculs_uv_bgr_iv32
	IF	NEW_PLAYER
	bra.s	.finir_init
.deja_precalcule_iv32
	move.l	descripteur_precalc.adresse_bloc(a4),d0
	IF	OPT_IV32
	add.l	#15,d0
	ELSE
	add.l	#$8000*2+15,d0
	ENDC
	and.w	#$fff0,d0	; on s'aligne sur une ligne de cache !
	move.l	d0,precalc_uv_bgr_adr_iv32
.finir_init
	addq.w	#1,descripteur_precalc.nb_utilisateurs(a4)
	ELSE

.deja_precalcule_iv32
	ENDC
	lea	info_retour_iv32(pc),a0
	move.l	#decode_iv32,information_module.adr_decodeur(a0)
	clr.l	information_module.adr_encodeur(a0)
	moveq	#0,d0
	fini_init_iv32
	rts
**********************
.mauvaise_compression
	moveq	#INIT_MOD_BAD_COMP,d0
	fini_init_iv32
	rts
.pas_assez_parametres
	moveq	#INIT_MOD_TOO_FEW_ARGS,d0
	fini_init_iv32
	rts
.unw_err_free_blocs
	bsr.s	free_blocs
.unw_err
	moveq	#INIT_MOD_UNWAITED_ERROR,d0
	fini_init_iv32
	rts
********
free_blocs
	move.l	a3,-(sp)
	lea	y2_buffer_adr_bloc(pc),a3
	tst.l	(a3)
	beq.s	.pas_y2
	bsr.s	..free_bloc
.pas_y2
	lea	y1_buffer_adr_bloc(pc),a3
	tst.l	(a3)
	beq.s	.pas_y1
	bsr.s	..free_bloc
.pas_y1
	move.l	(sp)+,a3
	rts
..free_bloc
	Mfree	(a3)
	clr.l	(a3)
	rts
**********************

	IF	OPT_IV32
precalculs_uv_bgr_iv32
	movem.l	d0-d7/a0,-(sp)
	move.l	prec_yuv_iv32(pc),a0
	move.l	#$ffff,d0	; il est trŠs important que la partie haute soit nulle
	moveq	#9,d7
.boucle_precalc
	move.w	d0,d1

	bfexts	d0{16:5+1},d2	; on isole U (5 bits + 1 bit de trop)
;	bset	#0,d2		; on ajoute une moiti‚ d'unit‚
	move.l	d2,d3
	muls.w	#-88,d2	; u->g (-0.34414*256=-88)
	muls.w	#454,d3	; u->b (1.772*256=454)
	bfexts	d0{16+5:5+1},d4	; on prend V (5 bits + 1 bit de trop)
;	bset	#0,d4		; on ajoute une moiti‚ d'unit‚
	move.l	d4,d5
	muls.w	#359,d4	; v->r (1.402*256=359)
	muls.w	#-183,d5; v->g (-0.71414*256=-183)
	; d2, d3, d4 et d5 repr‚sentent sur 32 bits la valeur sign‚e voulue
	; multipli‚e par 2^(8-2)
	move.w	d0,d1		; on prend Y
	and.w	#$3f,d1
	lsl.w	#8,d1		; 9+5=6+8 bits
;	bset	#7,d1		; on ajoute une moiti‚ d'unit‚

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
	dbf	d0,.boucle_precalc
	movem.l	(sp)+,d0-d7/a0
	rts

	ELSE
precalculs_uv_bgr_iv32
	movem.l	d0-d7/a0,-(sp)
	move.l	precalc_uv_bgr_adr_iv32(pc),a0
	moveq	#-1,d0
	moveq	#9,d7
.boucle_precalc
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
	move.w	d6,0(a0,d0.w*2)
	dbf	d0,.boucle_precalc
	movem.l	(sp)+,d0-d7/a0
	rts
	ENDC


*************************************************

precalculs_multiples_signes_iv32
; paramŠtre :
;	d0.l : largeur animation (arrondie au multiple de 4 sup‚rieur)
;	d1.l : hauteur animation (arrondie au multiple de 4 sup‚rieur)
	movem.l	d0-d2/a0,-(sp)
	move.l	precalc_multiples_iv32(pc),a0
	clr.l	d2
.boucle_pos			; 0..height (i.e. height+1 mots longs)
	move.l	d2,(a0)+
	add.l	d0,d2
	dbf	d1,.boucle_pos

	move.l	precalc_multiples_iv32(pc),a0
	move.l	d0,d2
	neg.l	d2
	moveq	#127,d1		; -1..-128
.boucle_neg
	move.l	d2,-(a0)
	sub.l	d0,d2
	dbf	d1,.boucle_neg
.fini
	movem.l	(sp)+,d0-d2/a0
	rts

*************************************************

decode_iv32
	add.w	#16,a0		; saute 16 octets
	move.l	a0,a1

;	move.w	(a0)+,d0
;	IM.w	d0
;	move.w	d0,version_iv32
	addq.l	#2,a0		; saute 'version'

	move.w	(a0)+,d7
	IM.w	d7
	btst.l	#9,d7
	seq	change_y2_iv32
	move.w	d7,flags_iv32

	move.l	(a0)+,d0
	IM.l	d0
;	move.l	d0,dsize_iv32
	cmp.l	#$80,d0			; dsize=$80 -> image invalide !
	bne.s	.pas_fini
	rts
.pas_fini

	clr.w	d0
	move.b	(a0)+,d0
	move.w	d0,cb_offset_iv32

;	move.b	(a0)+,cb_set_iv32
;	addq.l	#2,a0		; saute 2 octets (surement r‚serv‚s)
;	move.w	(a0)+,d0
;	IM.w	d0
;	move.w	d0,height_iv32
;	move.w	(a0)+,d0
;	IM.w	d0
;	move.w	d0,width_iv32
	addq.l	#7,a0		; saute 'cb_set', 2 octets, 'width, 'height'

	move.l	(a0)+,d0
	IM.l	d0
;	move.l	d0,off_y_iv32
	move.l	(a0)+,d1
	IM.l	d1
	add.l	a1,d1
	move.l	d1,off_v_iv32
	move.l	(a0)+,d1
	IM.l	d1
	add.l	a1,d1
	move.l	d1,off_u_iv32
	addq.l	#4,a0		; saute 4 octets (sans doute r‚serv‚s)

	move.l	a0,pred_tbls_iv32	; index de tables de pr‚diction
	lea	(a1,d0.l),a0

* plan Y
	move.l	y1_buffer(pc),a1	; old_img
	move.l	y2_buffer(pc),a2	; new_img
	movem.w	height_iv32(pc),d1/a6	; height:width
	clr.l	d0
	move.w	first_width_iv32(pc),d0
	move.w	pos_last_strip_iv32(pc),d6
	move.w	last_strip_left_y_iv32(pc),last_strip_left_iv32
	move.l	precalc_multiples_y_iv32(pc),precalc_multiples_iv32
	bsr	dec_plane_iv32
* plan V
	move.l	off_v_iv32(pc),a0
	move.l	v1_buffer(pc),a1	; old_img
	move.l	v2_buffer(pc),a2	; new_img
	movem.w	height_uv_iv32(pc),d1/a6	; height:width
	clr.l	d0
	move.w	first_width_uv_iv32(pc),d0
	move.w	pos_last_strip_uv_iv32(pc),d6
	move.w	flags_iv32(pc),d7
	move.w	last_strip_left_uv_iv32(pc),last_strip_left_iv32
	move.l	precalc_multiples_uv_iv32(pc),precalc_multiples_iv32
	bsr	dec_plane_iv32
* plan U
	move.l	off_u_iv32(pc),a0
	move.l	u1_buffer(pc),a1	; old_img
	move.l	u2_buffer(pc),a2	; new_img
	move.w	height_uv_iv32(pc),d1	; height
	clr.l	d0
	move.w	first_width_uv_iv32(pc),d0
	move.w	pos_last_strip_uv_iv32(pc),d6
	move.w	flags_iv32(pc),d7
	bsr	dec_plane_iv32
* conversion YUV
	clr.l	d5
	move.w	width_iv32(pc),d5
	move.w	height_iv32(pc),d7
	tst.b	change_y2_iv32(pc)
	bne.s	.use_y2
	movem.l	y1_buffer(pc),a0-a2	; buffers y u v
	bra.s	.use_ok
.use_y2
	movem.l	y2_buffer(pc),a0-a2	; buffers y u v
.use_ok
	move.l	info_entree_iv32+info_init_codec.adr_ecran_centre(pc),a3
	move.l	a3,a4
	move.l	passe_ligne_iv32(pc),d4	; passe_ligne:taille_ligne
	clr.l	d3
	move.w	d4,d3
	add.l	d3,a4			; une ligne plus bas
	add.l	d3,d3			; deux lignes
	move.l	d5,d2
	lsr.w	#2,d5
	move.w	d5,d0
	subq.w	#1,d5		; valeur initiale du compteur colonnes
	neg.w	d0
	moveq	#3,d6
	and.l	d0,d6		; ajustement en fin de ligne U ou V
	move.w	d2,d4
	add.w	d4,d4
	add.w	d2,d4		; 3*width
	subq.l	#4,d2		; width-4
	move.l	prec_yuv_iv32(pc),a5
	lsr.w	#2,d7
	subq.w	#1,d7
;	d0 : cpt_col.w			a0 : pointe sur le flux entrant (buffer Y)
;	d1 : 0:0:u:v:y			a1 : (buffer U)
;	d2 : width - 4			a2 : (buffer V)
;	d3 : taille_ligne*2		a3 : ecran
;	d4 : passe_ligne:width*3	a4 : ecran, une ligne plus bas
;	d5 : init_col.w			a5 : pointe sur precalculs
;	d6 : ajustement par ligne UV	a6 : pointe temporairement sur les pr‚calculs
;	d7 : compteur_lignes.w
.boucle_lignes		; 2+50+48+48+68 = 216 ‡'est bon !
	move.w	d5,d0		; compteur x
.boucle_colonnes
	; ligne 1
	clr.l	d1
	move.b	(a1)+,d1	; U
	lsl.w	#6,d1
	move.b	(a2)+,d1	; V
	lsl.b	#1,d1
	eor.w	#$1080,d1		; adapte le signe de U et de V
	and.w	#-8,d1
	lsl.l	#6,d1
	lea	(a5,d1.l),a6
	clr.l	d1
	REPT	4
	move.b	(a0)+,d1
	move.w	(a6,d1.l*4),(a3)+
	ENDR
	; lignes 2, 3, 4
	add.l	d2,a0
	add.l	d3,a3		; deux lignes plus bas
	subq.l	#8,a3
	REPT	4
	move.b	(a0)+,d1
	move.w	(a6,d1.l*4),(a4)+
	ENDR

	add.l	d2,a0
	add.l	d3,a4		; deux lignes plus bas
	subq.l	#8,a4
	REPT	4
	move.b	(a0)+,d1
	move.w	(a6,d1.l*4),(a3)+
	ENDR

	add.l	d2,a0
	sub.l	d3,a3
	REPT	4
	move.b	(a0)+,d1
	move.w	(a6,d1.l*4),(a4)+
	ENDR
	sub.l	d3,a4
	sub.w	d4,a0		; revient en arriŠre
	dbf	d0,.boucle_colonnes
	add.l	d6,a1
	add.l	d6,a2
	add.w	d4,a0		; avance de 3 lignes dans les Y
	swap	d4
	add.w	d4,a3		; retour chariot
	add.w	d4,a4
	swap	d4
	dbf	d7,.boucle_lignes
	rts
	
****************
dec_plane_iv32
	clr.w	niveau_recursion_iv32
	move.l	(a0)+,d2		; nombre de motion vectors
	IM.l	d2
	move.l	a0,pmv_iv32		; motion vectors
	lea	(a0,d2.l*2),a0		; se positionne sur les commandes

	btst.l	#9,d7
	beq.s	.normal
	exg	a1,a2
.normal
	move.l	a2,a3
	add.w	d6,a3
	move.l	a3,offset_last_strip_iv32
	move.l	a1,a3	; c'est le flux Indeo qui d‚cide du signe : je ne peux
	sub.l	a2,a3	; donc pas faire autrement que calculer ‡a … chaque fois
	move.l	a3,difference_buffers_iv32
	; d0 : flags:largeur_cellule/4-1	a0 : commandes
	; d1 : hauteur_cellule/4-1		a1 : source (old img)
	; d2 : octet_courant			a2 : origine destination (new img)
	; d3 : compteur dbf sur chaine de bits	a3 : destination courante
	; d4 : 					a4 : corr type
	; d5 : 					a5 : correction
	; d6 :					a6 : width
	; d7 :
REPEAT		equ	16	; num‚ros de bits dans d0
FIRST_LINE	equ	17
PMV		equ	18
ESC_COPY	equ	19
VALID_PMV	equ	24
SON_NB		equ	25
VERT		equ	26

MOD_PRED		equ	$20+$31b4
CORRECTOR_TYPE		equ	$20+$35b4		; $3000
CORRECTION		equ	$20+$35b4+$3000		; $6000
CORRECTION_LOW_ORDER	equ	$20+$35b4+$3000+$6000	; $6000 (mode 10)
CORRECTION_HI_ORDER	equ	$20+$35b4+$3000+$6000*2	; $6000 (mode 10)
* decode y plane
	IF	POS_Y
	clr.w	pos_y
	ENDC
	bset.l	#SON_NB,d0		; la racine est seule : pas de frŠre

	IF	DEBUG_IV32
ip
	subq.l	#1,saute_img
	bhi.s	*+4
	illegal
	clr.l	bt_null_copy
	clr.l	saw_mode_0
	clr.l	saw_mode_0_pmv
	clr.l	saw_mode_1
	clr.l	saw_mode_3
	clr.l	saw_mode_4
	clr.l	saw_mode_10
	clr.l	saw_mode_10_pmv
	clr.l	saw_mode_11
	clr.l	m0_init_echappe_sup_32
	clr.l	m0p_init_echappe_sup_32
	ENDC

	clr.w	d2
****************
.nouvel_octet
	move.b	(a0)+,d2
	moveq	#4-1,d3
	lsl.b	#1,d2
	bcs	.commandes
****************
.separations
	lsl.b	#1,d2
	bcs.b	.bt_vert
********
.bt_horiz
* s‚paration horizontale
	addq.w	#1,niveau_recursion_iv32
	movem.l	d0-d1/a2,-(sp)		; sauvegarde de contexte
	bclr.l	#SON_NB,d0
	bclr.l	#VERT,d0
	cmp.w	#8,d1
	bls.s	.horiz_force_a_4
	lsr.w	#1,d1
	addq.w	#4,d1
	and.w	#-8,d1
.suite_horiz
	lsl.b	#1,d2
	dbcc	d3,.commandes
	dbcs	d3,.separations
	bra.s	.nouvel_octet
.horiz_force_a_4
	moveq	#4,d1
	bra.s	.suite_horiz
********
.bt_vert
* s‚paration verticale
	addq.w	#1,niveau_recursion_iv32
	movem.l	d0-d1/a2,-(sp)		; sauvegarde de contexte
	bclr.l	#SON_NB,d0
	bset.l	#VERT,d0
	cmp.w	#8,d0
	bls.s	.vert_force_a_4
	lsr.w	#1,d0
	addq.w	#4,d0
	and.w	#-8,d0
.suite_vert
	lsl.b	#1,d2
	dbcc	d3,.commandes
	dbcs	d3,.separations
	bra.s	.nouvel_octet
.vert_force_a_4
	move.w	#4,d0
	bra.s	.suite_vert
****************
.valide_mv
* positionne le motion vector
	bset.l	#VALID_PMV,d0
	bne.s	..bt_null	; BT_NULL : 
	bclr.l	#PMV,d0		; BT_ABS_FILL : pas de motion vector
	lsl.b	#1,d2
	dbcc	d3,.commandes
	dbcs	d3,.separations
	bra	.nouvel_octet
..bt_null
* BT NULL : copie si code suivant =0 ou si =1 et pMV<>0
	* calcule source (pMV)
	lea	(a2),a1
	sub.l	a6,a1
	btst.l	#PMV,d0
	beq.s	...pmv_calcule1
	add.l	a6,a1		; nouveau source (avec pMV)
	add.l	difference_buffers_iv32(pc),a1
	add.l	motion_vector_iv32(pc),a1
...pmv_calcule1

	IF	DEBUG_IV32
	tst.l	saute_img(pc)
	bne.s	*+6+8
	subq.l	#1,saute_cellules
	bne.s	*+6
	bsr	convert_yuv_grey_iv32
	ENDC

	dbf	d3,...pas_nouvel_octet
	move.b	(a0)+,d2
	moveq	#4-1,d3
...pas_nouvel_octet
	IF	POS_Y
	add.w	d1,pos_y
	ENDC
	lsl.b	#1,d2
	bcs	.fini			; %1x-> illegal
	lsl.b	#1,d2
	bcc.s	...bt_null_copy		; %00-> copie
	btst.l	#PMV,d0
	beq	.cellule_suivante	; %01 et pMV=0 -> saute (bt_null_skip)
...bt_null_copy
	IF	DEBUG_IV32
	addq.l	#1,bt_null_copy
	ENDC
	lea	(a2),a3		; destination
	move.w	d1,d5
	move.w	d0,d7
	subq.w	#1,d5
	lsr.w	#2,d7
	sub.w	d0,a6		; modifie a6 := width-cell_width
	subq.w	#1,d7
...bcl_copy_y
	move.w	d7,d6
...bcl_copy_x
	move.l	(a1)+,(a3)+
	dbf	d6,...bcl_copy_x
	add.l	a6,a3
	add.l	a6,a1
	dbf	d5,...bcl_copy_y
	add.w	d0,a6		; restitue a6 = width
	bra	.cellule_suivante
********
..bt_rel_fill
	* charge nouveau pMV
	bset.l	#PMV,d0
	clr.l	d4
	move.b	(a0)+,d4
	move.l	pmv_iv32(pc),a4
	move.w	(a4,d4.l*2),d4
	move.w	d4,d5
	asr.w	#8,d5		; pMV.y (sign‚ !)
	extb.l	d4		; pMV.x
	move.l	precalc_multiples_iv32(pc),a4
	add.l	(a4,d5.w*4),d4
	move.l	d4,motion_vector_iv32
	lsl.b	#1,d2
	dbcc	d3,.commandes
	dbcs	d3,.separations
	bra	.nouvel_octet
********
.commandes
	lsl.b	#1,d2
	bcc	.valide_mv
********
.remplissage
	bset.l	#VALID_PMV,d0
	beq.s	..bt_rel_fill
****
..bt_vq_data
	lsr.w	#2,d0
	lsr.w	#2,d1
	subq.w	#1,d0
	subq.w	#1,d1
	lea	(a2),a3
	lea	(a2),a1
	sub.l	a6,a1
	btst.l	#PMV,d0
	beq.s	...pmv_calcule2
	add.l	a6,a1
	add.l	difference_buffers_iv32(pc),a1
	add.l	motion_vector_iv32(pc),a1
...pmv_calcule2
	* init tables et mode pour la cellule
	clr.l	d4
	move.b	(a0)+,d4
	move.w	d4,d5
	and.w	#%00001111,d4		; d4 = table
	add.w	cb_offset_iv32(pc),d4
	lsr.w	#4,d5			; d5 = mode
	move.w	d4,d6
	subq.w	#8,d6
	cmp.w	#15-8,d6		; le test non sign‚ permet de ne faire qu'une
	bhi.s	...pas_special_0_3_10	; seule comparaison
	move.w	d5,d6
	beq.s	...special_0_3_10
	subq.w	#3,d6
	beq.s	...special_0_3_10
	subq.w	#10-3,d6
	bne.s	...pas_special_0_3_10
...special_0_3_10
	* modifie la premiŠre ligne de la source.
	lsl.l	#7,d4
	move.l	data_indeo(pc),a5
	lea	(MOD_PRED-$400.w,a5,d4.l),a4
	move.w	d0,d6	; width/4-1
	lsr.l	#7,d4
	move.l	a1,a5
	clr.l	d7
....bcl_special
	REPT	4
	move.b	(a5),d7
	move.b	(a4,d7.l),(a5)+
	ENDR
	dbf	d6,....bcl_special
...pas_special_0_3_10
	swap	d2
	swap	d3
	clr.w	d2
	lsl.l	#8,d4
	move.l	data_indeo(pc),a5

	IF	DEBUG_IV32
	tst.l	saute_img(pc)
	bne.s	*+6+8
	subq.l	#1,saute_cellules
	bne.s	*+6
	bsr	convert_yuv_grey_iv32
	ENDC
	* switch sur le mode, par ordre de fr‚quence d‚croissante
	tst.w	d5
	beq.s	.mode_0
	move.l	d4,d6
	lea	(CORRECTOR_TYPE.w,a5,d4.l*2),a4
	lea	(CORRECTION.w,a5,d4.l*4),a5
	move.w	d1,d4	; cpt_y
	subq.w	#1,d4	; (X-1)/2 est ‚quivalent … faire (X+1)/2-1
	swap	d1
	lsr.w	#1,d4
	sub.w	#10,d5
	beq	.mode_10
	addq.w	#7,d5
	beq	.mode_3
	subq.w	#8,d5
	beq	.mode_11
	add.w	#10,d5
	beq	.mode_1
	subq.w	#3,d5
	beq	.mode_4
	IF	DEBUG_IV32
	illegal
	ENDC
	bra	.fini
.mode_0
	lea	(CORRECTOR_TYPE.w,a5,d4.l*2),a4
	lea	(CORRECTION.w,a5,d4.l*4),a5
.entree_mode_1
	* delta 4*4
	; d0 : flags:largeur_cellule/4-1	a0 : commandes
	; d1 : hauteur_cellule/4-1:cpt_x	a1 : source (old img)
	; d2 : octet_courant1:octet_courant2.w	a2 : temp
	; d3 : cpt_dbf_bits:cpt_4_lignes	a3 : destination courante
	; d4 : cpt_y				a4 : corr type
	; d5 : corrTyp ; temp1			a5 : correction
	; d6 : source.l				a6 : width
	; d7 : cpt_esc
	move.w	d1,d4	; cpt_y
	swap	d1
	btst.l	#PMV,d0
	bne	.mode_0_pmv
	IF	DEBUG_IV32
	addq.l	#1,saw_mode_0
	ENDC
			; quad+dyad = 154. +copy = 208. +esc = 308
			; 20
	move.w	d0,d1	; cpt_x
	bra.s	.m0_bcl_y
.m0_bcl_x
	move.l	a6,d5
	lsl.l	#2,d5
	subq.l	#4,d5	; width*4-4
	sub.l	d5,a1
	sub.l	d5,a3
.m0_bcl_y
	IF	DEBUG_IV32
	cmp.l	#SAW_MODE_0,saw_mode_0
	bmi.s	*+8
	bsr	convert_yuv_grey_iv32
	illegal
	ENDC
	move.l	(a1),d6
	move.w	#3,d3
.m0_bcl_bloc		; 52
	move.b	(a0)+,d2
	move.w	(a4,d2.w*2),d5
	beq.s	.m0_quad
	subq.w	#1,d5
	beq.s	.m0_dyad
	clr.w	d2
	subq.w	#1,d5
	beq	.m0_copie_jusque_l1
	subq.w	#1,d5
	beq	.m0_copie_jusque_l2
	subq.w	#1,d5
	beq	.m0_copie_jusque_l3
	subq.w	#1,d5
	beq.s	.m0_copie_jusque_l3_rep
	subq.w	#3,d5
	beq	.m0_sequence_echappe
	addq.w	#2,d5
	beq	.m0_saute_bloc
	subq.w	#1,d5
	beq	.m0_saute_bloc_rep
	subq.w	#2,d5
	beq	.m0_bloc_mono
	IF	DEBUG_IV32
	illegal
	ENDC
	bra	.fini
.m0_quad		; 26
	add.l	(a5,d2.w*4),d6
	move.l	d6,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m0_bcl_bloc
	dbf	d1,.m0_bcl_x
	bra.s	.m0_continue
.m0_dyad		; 56
	add.w	2(a5,d2.w*4),d6
	swap	d6
	move.b	(a0)+,d2
	add.w	2(a5,d2.w*4),d6
	swap	d6
	move.l	d6,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m0_bcl_bloc
	dbf	d1,.m0_bcl_x
.m0_continue
	move.w	d0,d1
	lsl.w	#2,d1		; revient en arriŠre de la largeur de la cellule - 4
	sub.w	d1,a1
	sub.w	d1,a3
	move.w	d0,d1	; cpt_x
	dbf	d4,.m0_bcl_y
.m0_fini
	swap	d1
	swap	d2
	addq.w	#1,d1
	addq.w	#1,d0
	lsl.w	#2,d1
	lsl.w	#2,d0
	IF	POS_Y
	add.w	d1,pos_y
	ENDC
	swap	d3
	bra	.cellule_suivante
.m0_copie_jusque_l3_rep	; 10	; laisse 0 lignes (d7=0)
	bchg.l	#REPEAT,d0
	bne.s	.m0_copie_jusque_l3	; pas_2_fois
	subq.l	#1,a0
.m0_copie_jusque_l3	; 32
	move.l	d6,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,*-6
	dbf	d1,.m0_bcl_x
	bra.s	.m0_continue
.m0_copie_jusque_l2	; 12
	subq.l	#1,d2		; laisse 1 lignes (d7=-1+2=+1)
	addq.w	#1,d3
.m0_copie_jusque_l1
	addq.l	#2,d2		; laisse 2 lignes (d7=+2)
	subq.w	#2,d3
	bls	.fini
	move.l	d6,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,*-6
	move.w	d2,d3		; restitue cpt_lignes
	dbf	d3,.m0_bcl_bloc
	dbf	d1,.m0_bcl_x
	bra.s	.m0_continue
.m0_sequence_echappe	; 70+46=116
	clr.l	d7
	move.l	d7,a2
	move.b	(a0)+,d7		; d‚bute ‚chappe
	moveq	#32,d5
	cmp.w	d5,d7
	bhs.s	.m0_esc_skip
	lea	-4(a2,a6.l*4),a2	; width*4-4
	move.w	d0,d5		; (le 'moveq' pr‚c‚dent remplace un 'clr')
	lsl.l	#2,d5
	bra.s	.m0_esc_copy
.m0_esc_bcl_x
	sub.l	a2,a1
	sub.l	a2,a3
.m0_esc_bcl_y
	move.l	(a1),d6
	addq.w	#4,d3		; d3=3
.m0_esc_copy
	move.l	d6,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m0_esc_copy
	subq.w	#1,d7
	dble	d1,.m0_esc_bcl_x
	dbgt	d1,.m0_bcl_x
	sub.l	d5,a1		; revient en arriŠre de la largeur de la cellule - 4
	sub.l	d5,a3
	move.w	d0,d1	; cpt_x
	tst.w	d7
	dble	d4,.m0_esc_bcl_y
	dbgt	d4,.m0_bcl_y
	bra	.m0_fini
.m0_esc_skip
	IF	DEBUG_IV32
	addq.l	#1,m0_init_echappe_sup_32
	ENDC
	sub.w	d5,d7
	addq.w	#1,d0	; d0 = width/4
	move.l	a6,d5
	lsl.l	#2,d5
	sub.w	d7,d1
	bpl.s	.m0_esc_skip_x
.m0_esc_skip_y
	sub.w	d0,d7
	subq.w	#1,d4		; une ligne de moins … faire
	add.l	d5,a1		; ligne suivante
	add.l	d5,a3
	add.w	d0,d1
	bmi.s	.m0_esc_skip_y
.m0_esc_skip_x
	subq.w	#1,d0	; restitue d0
	ext.l	d7
	lsl.l	#2,d7
	add.l	d7,a1		; blocs suivants
	add.l	d7,a3
	addq.w	#1,d1
	tst.w	d4
	dbmi	d1,.m0_bcl_y
	bpl	.m0_continue
	bra	.m0_fini
.m0_bloc_mono		; 50
	subq.w	#3,d3
	blo	.fini
	move.b	(a0)+,d7
	bclr.l	#7,d7
	beq.s	.m0_mono_pas_repeat
	bchg.l	#REPEAT,d0
	bne.s	.m0_mono_pas_repeat
	subq.l	#2,a0
.m0_mono_pas_repeat
	bfins	d7,d7{16:8}
	bfins	d7,d7{0:16}
	addq.w	#3,d3		; d3=3
.m0_mono_bcl
	move.l	d7,(a3)
	add.l	a6,a3
	dbf	d3,.m0_mono_bcl
	lea	(a1,a6.l*4),a1
	dbf	d1,.m0_bcl_x
	bra	.m0_continue
.m0_saute_bloc_rep	; 8
	bchg.l	#REPEAT,d0
	bne.s	.m0_saute_bloc	; pas_2_fois
	subq.l	#1,a0
.m0_saute_bloc		; 22
	subq.w	#3,d3
	blo	.fini
	lea	(a1,a6.l*4),a1
	lea	(a3,a6.l*4),a3
	dbf	d1,.m0_bcl_x
	bra	.m0_continue

.mode_0_pmv
	IF	DEBUG_IV32
	addq.l	#1,saw_mode_0_pmv
	ENDC
	* delta 4*4
	; d0 : flags:largeur_cellule/4-1	a0 : commandes
	; d1 : hauteur_cellule/4-1:cpt_x	a1 : source (old img)
	; d2 : octet_courant1:octet_courant2.w	a2 : temp
	; d3 : cpt_dbf_bits:cpt_4_lignes	a3 : destination courante
	; d4 : cpt_y				a4 : corr type
	; d5 : corrTyp ; temp1			a5 : correction
	; d6 : restitution de d3		a6 : width
	; d7 : cpt_esc
			; quad+dyad = 154. +copy = 208. +esc = 308
		; 20
	move.w	d0,d1	; cpt_x
	bra.s	.m0p_bcl_y
.m0p_bcl_x
	move.l	a6,d5
	lsl.l	#2,d5
	subq.l	#4,d5	; width*4-4
	sub.l	d5,a1
	sub.l	d5,a3
.m0p_bcl_y
	IF	DEBUG_IV32
	bra.s	*+6
	bsr	convert_yuv_grey_iv32
	ENDC
	move.w	#3,d3
.m0p_bcl_bloc		; 52
	move.b	(a0)+,d2
	move.w	(a4,d2.w*2),d5
	beq.s	.m0p_quad
	subq.w	#1,d5
	beq.s	.m0p_dyad
	clr.w	d6
	subq.w	#1,d5
	beq	.m0p_copie_jusque_l1
	subq.w	#1,d5
	beq	.m0p_copie_jusque_l2
	subq.w	#1,d5
	beq	.m0p_copie_jusque_l3
	subq.w	#1,d5
	beq.s	.m0p_copie_jusque_l3_rep
	subq.w	#3,d5
	beq	.m0p_sequence_echappe
	addq.w	#2,d5
	beq	.m0p_saute_bloc
	subq.w	#1,d5
	beq	.m0p_saute_bloc_rep
	subq.w	#2,d5
	beq	.m0p_bloc_mono
	IF	DEBUG_IV32
	illegal
	ENDC
	bra	.fini
.m0p_quad		; 26
	move.l	(a1),d5
	add.l	(a5,d2.w*4),d5
	move.l	d5,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m0p_bcl_bloc
	dbf	d1,.m0p_bcl_x
	bra.s	.m0p_continue
.m0p_dyad		; 56
	move.l	(a1),d5
	add.w	2(a5,d2.w*4),d5
	swap	d5
	move.b	(a0)+,d2
	add.w	2(a5,d2.w*4),d5
	swap	d5
	move.l	d5,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m0p_bcl_bloc
	dbf	d1,.m0p_bcl_x
.m0p_continue
	move.w	d0,d1
	lsl.w	#2,d1		; revient en arriŠre de la largeur de la cellule - 4
	sub.w	d1,a1
	sub.w	d1,a3
	move.w	d0,d1	; cpt_x
	dbf	d4,.m0p_bcl_y
.m0p_fini
	swap	d1
	swap	d2
	addq.w	#1,d1
	addq.w	#1,d0
	lsl.w	#2,d1
	lsl.w	#2,d0
	IF	POS_Y
	add.w	d1,pos_y
	ENDC
	swap	d3
	bra	.cellule_suivante
.m0p_copie_jusque_l3_rep	; 10	; laisse 0 lignes (d7=0)
	bchg.l	#REPEAT,d0
	bne.s	.m0p_copie_jusque_l3	; pas_2_fois
	subq.l	#1,a0
	bra.s	.m0p_copie_jusque_l3
.m0p_copie_jusque_l2	; 12
	subq.w	#1,d6		; laisse 1 lignes (d7=-1+2=+1)
	addq.w	#1,d3
.m0p_copie_jusque_l1
	addq.w	#2,d6		; laisse 2 lignes (d7=+2)
	subq.w	#2,d3
	bls	.fini
.m0p_copie_jusque_l3	; 32
	move.l	(a1),(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,*-6
	move.w	d6,d3		; restitue cpt_lignes
	dbf	d3,.m0p_bcl_bloc
	dbf	d1,.m0p_bcl_x
	bra.s	.m0p_continue
.m0p_sequence_echappe	; 72
	clr.l	d7
	move.l	d7,a2
	move.b	(a0)+,d7		; d‚bute ‚chappe
	moveq	#32,d5
	cmp.w	d5,d7
	blo.s	.m0p_esc_ok
	sub.w	d5,d7
.m0p_esc_ok
	lea	-4(a2,a6.l*4),a2	; width*4-4
	move.w	d0,d5		; (le 'moveq' remplace un 'clr')
	lsl.l	#2,d5
	bra.s	.m0p_esc_copy
.m0p_esc_bcl_x
	sub.l	a2,a1
	sub.l	a2,a3
.m0p_esc_bcl_y
	addq.w	#4,d3		; d3=3
.m0p_esc_copy
	move.l	(a1),(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m0p_esc_copy
	subq.w	#1,d7
	dble	d1,.m0p_esc_bcl_x
	dbgt	d1,.m0p_bcl_x
	sub.l	d5,a1		; revient en arriŠre de la largeur de la cellule - 4
	sub.l	d5,a3
	move.w	d0,d1	; cpt_x
	tst.w	d7
	dble	d4,.m0p_esc_bcl_y
	dbgt	d4,.m0p_bcl_y
	bra	.m0p_fini
.m0p_bloc_mono		; 50
	subq.w	#3,d3
	blo	.fini
	move.b	(a0)+,d7
	bclr.l	#7,d7
	beq.s	.m0p_mono_pas_repeat
	bchg.l	#REPEAT,d0
	bne.s	.m0p_mono_pas_repeat
	subq.l	#2,a0
.m0p_mono_pas_repeat
	bfins	d7,d7{16:8}
	bfins	d7,d7{0:16}
	addq.w	#3,d3
.m0p_mono_bcl
	move.l	d7,(a3)
	add.l	a6,a3
	dbf	d3,.m0p_mono_bcl
	lea	(a1,a6.l*4),a1
	dbf	d1,.m0p_bcl_x
	bra	.m0p_continue
.m0p_saute_bloc_rep	; 8
	bchg.l	#REPEAT,d0
	bne.s	.m0p_saute_bloc	; pas_2_fois
	subq.l	#1,a0
.m0p_saute_bloc		; 22
	move.l	(a1),(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,*-6
	dbf	d1,.m0p_bcl_x
	bra	.m0p_continue
.mode_1
	* change de tables
	move.l	pred_tbls_iv32(pc),a4
	move.w	cb_offset_iv32(pc),d7
	lsr.l	#8,d6
	sub.w	d7,d6
	move.b	(a4,d6.l),d6
	move.l	d6,d5
	lsr.w	#4,d6	; tbl1
	and.w	#$f,d5	; tlb2
	add.w	d7,d6
	add.w	d7,d5
	moveq	#9,d7
	lsl.l	d7,d6
	lsl.l	d7,d5
	move.l	data_indeo(pc),a5
	lea	(CORRECTOR_TYPE.w,a5,d5.l),a4
	add.w	#CORRECTION,a5
	lea	(a5,d6.l*2),a2
	lea	(a5,d5.l*2),a5
	swap	d1
	sub.l	d5,d6						; diff‚rence 1 <-> 2
	; puisqu'une table a pour taille $6000, ceci tient sur un mot !!!
	beq	.entree_mode_1
	swap	d1
	IF	DEBUG_IV32
	addq.l	#1,saw_mode_1
	ENDC
	* delta 4*4 avec ‚ventuellement deux tables (mais c'est trŠs rare)
	; d0 : flags:largeur_cellule/4-1	a0 : commandes
	; d1 : hauteur_cellule/4-1:cpt_x	a1 : source (old img)
	; d2 : octet_courant1:octet_courant2.w	a2 : correction 2
	; d3 : cpt_dbf_bits:cpt_4_lignes	a3 : destination courante
	; d4 : cpt_y				a4 : corr type
	; d5 : corrTyp ; temp1			a5 : correction 1
	; d6 : restitution de d3		a6 : width
	; d7 : cpt_esc
			; quad+dyad = 154. +copy = 208. +esc = 308
	move.w	d0,d1	; cpt_x
	move.l	d1,d4
	swap	d4
	bra.s	.m1_bcl_y
.m1_bcl_x
	move.l	a6,d5
	lsl.l	#2,d5
	subq.l	#4,d5	; width*4-4
	sub.l	d5,a1
	sub.l	d5,a3
.m1_bcl_y
	IF	DEBUG_IV32
	bra.s	*+6
	bsr	convert_yuv_grey_iv32
	ENDC
	move.w	#3,d3
.m1_bcl_bloc		; 52
	move.b	(a0)+,d2
	move.w	(a4,d2.w*2),d5
	beq.s	.m1_quad
	subq.w	#1,d5
	beq.s	.m1_dyad
	clr.w	d6
	subq.w	#1,d5
	beq	.m1_copie_jusque_l1
	subq.w	#1,d5
	beq	.m1_copie_jusque_l2
	subq.w	#1,d5
	beq	.m1_copie_jusque_l3
	subq.w	#1,d5
	beq.s	.m1_copie_jusque_l3_rep
	subq.w	#3,d5
	beq	.m1_sequence_echappe
	addq.w	#2,d5
	beq	.m1_saute_bloc
	subq.w	#1,d5
	beq	.m1_saute_bloc_rep
	subq.w	#2,d5
	beq	.m1_bloc_mono
	IF	DEBUG_IV32
	illegal
	ENDC
	bra	.fini
.m1_quad		; 26
	move.l	(a1),d5
	add.l	(a5,d2.w*4),d5
	move.l	d5,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	exg	a2,a5
	dbf	d3,.m1_bcl_bloc
	dbf	d1,.m1_bcl_x
	bra.s	.m1_continue
.m1_dyad		; 56
	move.l	(a1),d5
	add.w	2(a5,d2.w*4),d5
	swap	d5
	move.b	(a0)+,d2
	add.w	2(a5,d2.w*4),d5
	swap	d5
	move.l	d5,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	exg	a2,a5
	dbf	d3,.m1_bcl_bloc
	dbf	d1,.m1_bcl_x
.m1_continue
	move.w	d0,d1
	lsl.w	#2,d1		; revient en arriŠre de la largeur de la cellule
	sub.w	d1,a1
	sub.w	d1,a3
	move.w	d0,d1	; cpt_x
	dbf	d4,.m1_bcl_y
.m1_fini
	swap	d1
	swap	d2
	addq.w	#1,d1
	addq.w	#1,d0
	lsl.w	#2,d1
	lsl.w	#2,d0
	IF	POS_Y
	add.w	d1,pos_y
	ENDC
	swap	d3
	bra	.cellule_suivante
.m1_copie_jusque_l3_rep	; 10	; laisse 0 lignes (d7=0)
	bchg.l	#REPEAT,d0
	bne.s	.m1_copie_jusque_l3	; pas_2_fois
	subq.l	#1,a0
	bra.s	.m1_copie_jusque_l3
.m1_copie_jusque_l2	; 12
	subq.w	#1,d6		; laisse 1 lignes (d7=-1+2=+1)
	addq.w	#1,d3
.m1_copie_jusque_l1
	addq.w	#2,d6		; laisse 2 lignes (d7=+2)
	subq.w	#2,d3
	bls	.fini
.m1_copie_jusque_l3	; 32
	btst.l	#0,d3	; pas d'ajustement si le nombre est pair
	bne.s	*+4
	exg	a2,a5
	move.l	(a1),(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,*-6
	move.w	d6,d3		; restitue cpt_lignes
	dbf	d3,.m1_bcl_bloc
	dbf	d1,.m1_bcl_x
	bra.s	.m1_continue
.m1_sequence_echappe	; 70+46=116
	clr.l	d7
	btst.l	d7,d3	; pas d'ajustement si le nombre est pair
	bne.s	*+4
	exg	a2,a5
	move.b	(a0)+,d7		; d‚bute ‚chappe
	moveq	#32,d5
	cmp.w	d5,d7
	bhs.s	.m1_esc_skip
.m1_esc_pmv
	move.l	a6,d6
	lsl.l	#2,d6
	subq.l	#4,d6	; width*4-4
	move.w	d0,d5		; (le 'moveq' pr‚c‚dent remplace un 'clr')
	lsl.l	#2,d5
	bra.s	.m1_esc_copy
.m1_esc_bcl_x
	sub.l	d6,a1
	sub.l	d6,a3
.m1_esc_bcl_y
	addq.w	#4,d3
.m1_esc_copy
	move.l	(a1),(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m1_esc_copy
	subq.w	#1,d7
	dble	d1,.m1_esc_bcl_x
	dbgt	d1,.m1_bcl_x
	sub.l	d5,a1		; revient en arriŠre de la largeur de la cellule - 4
	sub.l	d5,a3
	move.w	d0,d1	; cpt_x
	tst.w	d7
	dble	d4,.m1_esc_bcl_y
	dbgt	d4,.m1_bcl_y
	bra	.m1_fini
.m1_esc_skip
	sub.w	d5,d7
	btst.l	#PMV,d0
	bne.s	.m1_esc_pmv
	addq.w	#1,d0	; d0 = width/4
	move.l	a6,d5
	lsl.l	#2,d5
	sub.w	d7,d1
	bpl.s	.m1_esc_skip_x
.m1_esc_skip_y
	sub.w	d0,d7
	subq.w	#1,d4		; une ligne de moins … faire
	add.l	d5,a1		; ligne suivante
	add.l	d5,a3
	add.w	d0,d1
	bmi.s	.m1_esc_skip_y
.m1_esc_skip_x
	subq.w	#1,d0	; restitue d0
	ext.l	d7
	lsl.l	#2,d7
	add.l	d7,a1		; blocs suivants
	add.l	d7,a3
	addq.w	#1,d1
	tst.w	d4
	dbmi	d1,.m1_bcl_y
	bpl	.m1_continue
	bra	.m1_fini
.m1_bloc_mono		; 50
	subq.w	#3,d3
	blo	.fini
	move.b	(a0)+,d7
	bclr.l	#7,d7
	beq.s	.m1_mono_pas_repeat
	bchg.l	#REPEAT,d0
	bne.s	.m1_mono_pas_repeat
	subq.l	#2,a0
.m1_mono_pas_repeat
	bfins	d7,d7{16:8}
	bfins	d7,d7{0:16}
	addq.w	#3,d3		; d3=3
.m1_mono_bcl
	move.l	d7,(a3)
	add.l	a6,a3
	dbf	d3,.m1_mono_bcl
	lea	(a1,a6.l*4),a1
	dbf	d1,.m1_bcl_x
	bra	.m1_continue
.m1_saute_bloc_rep	; 8
	bchg.l	#REPEAT,d0
	bne.s	.m1_saute_bloc	; pas_2_fois
	subq.l	#1,a0
.m1_saute_bloc		; 22
	btst.l	#PMV,d0
	beq.s	.m1_saute_bloc_continue	; si pMV=0, il est inutile de faire la copie
	move.l	(a1),(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,*-6
	dbf	d1,.m1_bcl_x
	bra	.m1_continue
.m1_saute_bloc_continue
	lea	(a1,a6.l*4),a1
	lea	(a3,a6.l*4),a3
	dbf	d1,.m1_bcl_x
	bra	.m1_continue
.mode_4
	IF	DEBUG_IV32
	addq.l	#1,saw_mode_4
	ENDC
	* change de tables
	move.l	pred_tbls_iv32(pc),a4
	move.w	cb_offset_iv32(pc),d7
	lsr.l	#8,d6
	sub.w	d7,d6
	move.b	(a4,d6.l),d6
	move.l	d6,d5
	lsr.w	#4,d6	; tbl1
	and.w	#$f,d5	; tlb2
	add.w	d7,d6
	add.w	d7,d5
	moveq	#9,d7
	lsl.l	d7,d6
	lsl.l	d7,d5
	move.l	data_indeo(pc),a5
	lea	(CORRECTOR_TYPE.w,a5,d5.l),a4
	add.w	#CORRECTION,a5
	lea	(a5,d6.l*2),a2	; correction 2
	lea	(a5,d5.l*2),a5	; correction 1
	bra.s	.entree_mode_4
.mode_3
	IF	DEBUG_IV32
	addq.l	#1,saw_mode_3
	ENDC
	lea	(a5),a2
.entree_mode_4
	* delta 4*8 sans motion vector avec interpolation
	; d0 : flags:largeur_cellule/4-1	a0 : commandes
	; d1 : hauteur_cellule/4-1:cpt_x	a1 : source (dst-width)
	; d2 : octet_courant1:octet_courant2.w	a2 : correction 2
	; d3 : cpt_dbf_bits:cpt_4_lignes	a3 : destination courante
	; d4 : pos_y:cpt_y			a4 : corr type
	; d5 : corrTyp ou temp1			a5 : correction 1
	; d6 : temp2				a6 : width
	; d7 : cpt_esc
	btst.l	#PMV,d0
	bne	.fini
	IF	POS_Y
	swap	d4
	move.w	pos_y(pc),d4
	ENDC
			; quad+dyad = 160. +copy = 224. +esc = 324
	move.w	d0,d1	; cpt_x
	IF	POS_Y
	swap	d4
	ENDC
	bra.s	.m3_bcl_y
.m3_bcl_x
	move.l	a6,d5
	lsl.l	#3,d5
	subq.l	#4,d5	; width*8-4
	sub.l	d5,a1
	sub.l	d5,a3
	IF	POS_Y
	sub.l	#8<<16,d4
	IF	DEBUG_IV32
	bpl.s	*+4
	illegal
	ENDC
	ENDC
.m3_bcl_y
	IF	DEBUG_IV32
	bra.s	*+6
	bsr	convert_yuv_grey_iv32
	ENDC
	move.w	#3,d3
	move.l	(a1),d6
.m3_bcl_bloc		; 60
	move.b	(a0)+,d2
	move.w	(a4,d2.w*2),d5
	beq.s	.m3_quad
	subq.w	#1,d5
	beq.s	.m3_dyad
	clr.w	d2
	subq.w	#1,d5
	beq	.m3_copie_jusque_l1
	subq.w	#1,d5
	beq	.m3_copie_jusque_l2
	subq.w	#1,d5
	beq	.m3_copie_jusque_l3
	subq.w	#1,d5
	beq.s	.m3_copie_jusque_l3_rep
	subq.w	#3,d5
	beq	.m3_sequence_echappe
	addq.w	#2,d5
	beq	.m3_saute_bloc	; ne fait presque rien puisque PMV=0
	subq.w	#1,d5
	beq	.m3_saute_bloc_rep
	subq.w	#2,d5
	beq	.m3_bloc_mono
	IF	DEBUG_IV32
	illegal
	ENDC
	bra	.fini
.m3_quad		; 10
	move.l	d6,d5
	add.l	(a5,d2.w*4),d6
	bra.s	..m3_quad_interpole
.m3_dyad		; 18
	move.l	d6,d5
	add.w	2(a5,d2.w*4),d6
	swap	d6
	move.b	(a0)+,d2
	add.w	2(a5,d2.w*4),d6
	swap	d6
..m3_quad_interpole	;
	IF	POS_Y
	bftst	d4{0:16}
	beq.s	..m3_1st_line
	ENDC
	add.l	d6,d5	; 14
	lsr.l	#1,d5
	and.l	#$7f7f7f7f,d5
	move.l	d5,(a3)
	IF	POS_Y
	bra.s	*+4
	ENDC
..m3_1st_line
	move.l	d6,(a3)
	IF	POS_Y
	add.l	#2<<16,d4
	ENDC
	add.l	a6,a3
	add.l	a6,a1
	move.l	d6,(a3)
	add.l	a6,a3
	add.l	a6,a1
	exg	a2,a5		; passage table 1<->2
	dbf	d3,.m3_bcl_bloc
	dbf	d1,.m3_bcl_x
.m3_continue
	move.w	d0,d1
	lsl.w	#2,d1	; on retranche la largeur de la case moins 4
	sub.w	d1,a1
	sub.w	d1,a3
	move.w	d0,d1	; cpt_x
	dbf	d4,.m3_bcl_y
	bra	.cellule_suivante_m3_m10
.m3_copie_jusque_l3_rep	; 10
	bchg.l	#REPEAT,d0
	bne.s	.m3_copie_jusque_l3	; pas_2_fois
	subq.l	#1,a0
	bra.s	.m3_copie_jusque_l3
.m3_copie_jusque_l2	; 12
	subq.w	#1,d2		; laisse 1 ligne de moins
	addq.w	#1,d3		; besoins d'une it‚ration de plus
.m3_copie_jusque_l1
	addq.w	#2,d2		; laisse 2 lignes
	subq.w	#2,d3
	bls	.fini
.m3_copie_jusque_l3	; 42
	btst.l	#0,d3		; pas d'ajustement si le nombre est pair
	bne.s	*+4
	exg	a2,a5		; passage table 1<->2
	move.l	d6,(a3)
	add.l	a6,a3
	add.l	a6,a1
	move.l	d6,(a3)
	add.l	a6,a3		; ligne suivante
	add.l	a6,a1
	IF	POS_Y
	add.l	#2<<16,d4
	dbf	d3,*-12-6
	ELSE
	dbf	d3,*-12
	ENDC
	move.w	d2,d3		; restitue cpt_lignes
	dbf	d3,.m3_bcl_bloc
	dbf	d1,.m3_bcl_x
	bra.s	.m3_continue
.m3_sequence_echappe	; 70+46=116
	clr.w	d2
	btst.l	d2,d3	; pas d'ajustement si le nombre est pair
	bne.s	*+4
	exg	a2,a5
	move.b	(a0)+,d2		; d‚bute ‚chappe
	moveq	#32,d5
	cmp.w	d5,d2
	bhs.s	.m3_esc_skip
.m3_esc_pmv
	move.l	a6,d7
	lsl.l	#3,d7
	subq.l	#4,d7	; width*4-4
	move.w	d0,d5		; (le 'moveq' pr‚c‚dent remplace un 'clr')
	lsl.l	#2,d5
	bra.s	.m3_esc_copy
.m3_esc_bcl_x
	sub.l	d7,a1
	sub.l	d7,a3
.m3_esc_bcl_y
	move.l	(a1),d6
	addq.w	#4,d3
.m3_esc_copy
	move.l	d6,(a3)
	add.l	a6,a3		; ligne suivante
	add.l	a6,a1
	move.l	d6,(a3)
	add.l	a6,a3
	add.l	a6,a1
	IF	POS_Y
	add.l	#2<<16,d4
	ENDC
	dbf	d3,.m3_esc_copy
	subq.w	#1,d2
	dble	d1,.m3_esc_bcl_x
	dbgt	d1,.m3_bcl_x
	sub.l	d5,a1		; revient en arriŠre de la largeur de la cellule - 4
	sub.l	d5,a3
	move.w	d0,d1	; cpt_x
	tst.w	d2
	dble	d4,.m3_esc_bcl_y
	dbgt	d4,.m3_bcl_y
	bra	.cellule_suivante_m3_m10	;.m3_fini
.m3_esc_skip
	sub.w	d5,d2
	addq.w	#1,d0	; d0 = width/4
	move.l	a6,d5
	lsl.l	#3,d5
	sub.w	d2,d1
	bpl.s	.m3_esc_skip_x
.m3_esc_skip_y
	IF	POS_Y
	add.l	#8<<16,d4
	ENDC
	sub.w	d0,d2
	subq.w	#1,d4		; une ligne de moins … faire
	add.l	d5,a1		; ligne suivante
	add.l	d5,a3
	add.w	d0,d1
	bmi.s	.m3_esc_skip_y
.m3_esc_skip_x
	subq.w	#1,d0	; restitue d0
	lsl.w	#2,d2
	add.w	d2,a1		; blocs suivants
	add.w	d2,a3
	addq.w	#1,d1
	tst.w	d4
	dbmi	d1,.m3_bcl_y
	bpl	.m3_continue
	bra	.cellule_suivante_m3_m10	;.m3_fini
.m3_bloc_mono		; 50
	subq.w	#3,d3
	blo	.fini
	move.b	(a0)+,d7
	bclr.l	#7,d7
	beq.s	.m3_mono_pas_repeat
	bchg.l	#REPEAT,d0
	bne.s	.m3_mono_pas_repeat
	subq.l	#2,a0
.m3_mono_pas_repeat
	IF	POS_Y
	add.l	#8<<16,d4
	ENDC
	bfins	d7,d7{16:8}
	bfins	d7,d7{0:16}
	addq.w	#3,d3
.m3_mono_bcl
	move.l	d7,(a3)
	add.l	a6,a3
	dbf	d3,.m3_mono_bcl
	lea	(a1,a6.l*8),a1
	dbf	d1,.m3_bcl_x
	bra	.m3_continue
.m3_saute_bloc_rep	; 8
	bchg.l	#REPEAT,d0
	bne.s	.m3_saute_bloc	; pas_2_fois
	subq.l	#1,a0
.m3_saute_bloc
	subq.w	#3,d3
	blo	.fini
	IF	POS_Y
	add.l	#8<<16,d4
	ENDC
	lea	(a1,a6.l*8),a1
	lea	(a3,a6.l*8),a3
	dbf	d1,.m3_bcl_x
	bra	.m3_continue

.mode_10
	add.w	#$6000,a5	; passe de 'correction' … 'correcrionLowOrder'
	subq.w	#1,d0	; (X-1)/2 est ‚quivalent … faire (X+1)/2-1
	lsr.w	#1,d0
	btst.l	#PMV,d0
	bne	.mode_10_pmv
	IF	DEBUG_IV32
	addq.l	#1,saw_mode_10
	ENDC
	* delta 8*8 avec interpolation
	; d0 : flags:largeur_cellule/4-1	a0 : commandes
	; d1 : hauteur_cellule/4-1:cpt_x	a1 : source (dst-width)
	; d2 : octet_courant1:octet_courant2.w	a2 : temp4
	; d3 : cpt_dbf_bits:cpt_4_lignes	a3 : destination courante
	; d4 : pos_y:cpt_y				a4 : corr type
	; d5 : corrTyp ou temp1			a5 : correction Low Order
	; d6 : temp2				a6 : width
	; d7 : temp3
	bset.l	#FIRST_LINE,d0
	IF	POS_Y
	swap	d4
	move.w	pos_y(pc),d4
	ENDC
			; quad+dyad = 208. +copy = 288
	move.w	d0,d1	; cpt_x
	IF	POS_Y
	swap	d4
	ENDC
	bra.s	.m10_bcl_y
.m10_bcl_x
	IF	POS_Y
	sub.l	#8<<16,d4
	ENDC
	move.l	a6,d5
	lsl.l	#3,d5
	subq.l	#8,d5	; width*8-8
	sub.l	d5,a1
	sub.l	d5,a3
.m10_bcl_y
	IF	DEBUG_IV32
	cmp.l	#SAW_MODE_10,saw_mode_10
	bmi.s	*+8
	bsr	convert_yuv_grey_iv32
	illegal
	ENDC

	move.w	#3,d3
	movem.l	(a1),d6/a2
	btst.l	#FIRST_LINE,d0
	beq.s	.m10_bcl_bloc
	move.l	#$ff00ff00,d7
	and.l	d7,d6
	move.l	d6,d5
	lsr.l	#8,d5
	or.l	d5,d6		; d6 = pixels 1133
	move.l	a2,d5
	and.l	d7,d5
	move.l	d5,a2
	lsr.l	#8,d5
	add.l	d5,a2		; a2 = pixels 5577
.m10_bcl_bloc		; 94
	move.l	a2,d7
	move.b	(a0)+,d2
	move.w	(a4,d2.w*2),d5
	beq.s	.m10_quad
	subq.w	#1,d5
	beq.s	.m10_dyad
	clr.w	d2
	subq.w	#1,d5
	beq	.m10_copie_jusque_l1
	subq.w	#1,d5
	beq	.m10_copie_jusque_l2
	subq.w	#1,d5
	beq	.m10_copie_jusque_l3
	subq.w	#1,d5
	beq	.m10_copie_jusque_l3_rep
	subq.w	#3,d5
	beq	.m10_sequence_echappe
	addq.w	#2,d5
	beq	.m10_saute_bloc		; ne fait presque rien puisque PMV=0
	subq.w	#1,d5
	beq	.m10_saute_bloc_rep
	subq.w	#2,d5
	beq	.m10_bloc_mono
	IF	DEBUG_IV32
	illegal
	ENDC
	bra	.fini
.m10_quad		; 12
	add.l	($6000.w,a5,d2.w*4),a2	; corrHi
	move.l	d6,d5
	add.l	(a5,d2.w*4),d6		; corrLow
	bra.s	.m10_quad_interpole
.m10_dyad		; 10
	add.l	(a5,d2.w*4),a2
	move.l	d6,d5
	move.b	(a0)+,d2
	add.l	(a5,d2.w*4),d6
.m10_quad_interpole	;
	IF	POS_Y
	bftst	d4{0:16}
	beq.s	..m10_1st_line
	ENDC
	movem.l	(a1),d5/d7
	add.l	d6,d5
	add.l	a2,d7
	lsr.l	#1,d5
	lsr.l	#1,d7
	and.l	#$7f7f7f7f,d5
	and.l	#$7f7f7f7f,d7
	movem.l	d5/d7,(a3)
	bra.s	*+6
..m10_1st_line
	movem.l	d6/a2,(a3)
	add.l	a6,a1
	add.l	a6,a3
	movem.l	d6/a2,(a3)		; corrLow
	add.l	a6,a1
	add.l	a6,a3
	IF	POS_Y
	add.l	#2<<16,d4
	ENDC
	dbf	d3,.m10_bcl_bloc
	dbf	d1,.m10_bcl_x
.m10_continue
	move.w	d0,d1
	lsl.w	#3,d1	; (cellWidth/8-1)*8 = cellWidth-8
	sub.w	d1,a1
	sub.w	d1,a3
	move.w	d0,d1	; cpt_x
	bclr.l	#FIRST_LINE,d0
	dbf	d4,.m10_bcl_y
.m10_fini
	lsl.w	#1,d0
	addq.w	#1,d0	; (X-1)/2 est ‚quivalent … faire (X+1)/2-1
	bra	.cellule_suivante_m3_m10
.m10_copie_jusque_l3_rep	; 10
	bchg.l	#REPEAT,d0
	bne.s	.m10_copie_jusque_l3	; pas_2_fois
	subq.l	#1,a0
	bra.s	.m10_copie_jusque_l3
.m10_copie_jusque_l2	; 12
	subq.w	#1,d2		; laisse 1 ligne de moins
	addq.w	#1,d3		; besoins d'une it‚ration de plus
.m10_copie_jusque_l1
	addq.w	#2,d2		; laisse 2 lignes
	subq.w	#2,d3		; on ne met pas 3 pour finir le premier doublet de lignes
	bls	.fini
.m10_copie_jusque_l3
			; 28
	move.l	d6,d5
	btst.l	#FIRST_LINE,d0	; NOTE ; barycentre … faire qu'en 1Šre ligne de cellule
	beq.s	..m10_cpy_1st_line
	IF	POS_Y
	bftst	d4{0:16}
	beq.s	..m10_cpy_1st_line
	ENDC
	movem.l	(a1),d5/d7
	add.l	d6,d5
	add.l	a2,d7
	lsr.l	#1,d5
	lsr.l	#1,d7
	and.l	#$7f7f7f7f,d5
	and.l	#$7f7f7f7f,d7
	movem.l	d5/d7,(a3)
	bra.s	*+6		; la premiŠre ligne est d‚ja faite
..m10_cpy_1st_line
			; 30
	movem.l	d6/a2,(a3)
	add.l	a6,a1
	add.l	a6,a3
	movem.l	d6/a2,(a3)
	add.l	a6,a1
	add.l	a6,a3		; ligne suivante
	IF	POS_Y
	add.l	#2<<16,d4
	dbf	d3,*-16-6
	ELSE
	dbf	d3,*-16
	ENDC
	move.w	d2,d3		; restitue cpt_lignes
	dbf	d3,.m10_bcl_bloc
	dbf	d1,.m10_bcl_x
	bra	.m10_continue
.m10_sequence_echappe	; 70+38=108
	clr.w	d2
	move.b	(a0)+,d2		; d‚bute ‚chappe
	moveq	#32,d5
	cmp.w	d5,d2
	bhs	.m10_esc_skip
	move.l	d6,d5
	bra.s	.m10_esc_copy
.m10_esc_bcl_x
	IF	POS_Y
	sub.l	#8<<16,d4
	ENDC
	move.l	a6,d5	; width*8-8
	lsl.l	#3,d5
	subq.l	#8,d5
	sub.l	d5,a1
	sub.l	d5,a3
.m10_esc_bcl_y
	addq.w	#4,d3		; d3=3
	movem.l	(a1),d6/a2
	move.l	d6,d5
	move.l	a2,d7
	btst.l	#FIRST_LINE,d0
	beq.s	.m10_esc_1st_line
	move.l	#$ff00ff00,d7
	and.l	d7,d6
	move.l	d6,d5
	lsr.l	#8,d5
	or.l	d5,d6		; d6 = pixels 1133
	move.l	a2,d5
	and.l	d7,d5
	move.l	d5,a2
	lsr.l	#8,d5
	add.l	d5,a2		; a2 = pixels 5577
	move.l	a2,d7
.m10_esc_copy	; NOTE ; barycentre … faire qu'en 1Šre ligne de cellule
	IF	POS_Y
	bftst	d4{0:16}
	beq.s	.m10_esc_1st_line
	ENDC
	movem.l	(a1),d5/d7
	add.l	d6,d5
	add.l	a2,d7
	lsr.l	#1,d5
	lsr.l	#1,d7
	and.l	#$7f7f7f7f,d5
	and.l	#$7f7f7f7f,d7
	movem.l	d5/d7,(a3)
	bra.s	*+6		; la premiŠre ligne est d‚ja faite
.m10_esc_1st_line
	movem.l	d6/a2,(a3)
	add.l	a6,a1
	add.l	a6,a3
	movem.l	d6/a2,(a3)
	add.l	a6,a1
	add.l	a6,a3
	IF	POS_Y
	add.l	#2<<16,d4
	dbf	d3,*-16-6
	ELSE
	dbf	d3,*-16
	ENDC
	subq.w	#1,d2
	dble	d1,.m10_esc_bcl_x
	dbgt	d1,.m10_bcl_x
	clr.l	d5
	move.w	d0,d5
	lsl.l	#3,d5
	sub.l	d5,a1		; revient en arriŠre de la largeur de la cellule - 8
	sub.l	d5,a3
	move.w	d0,d1	; cpt_x
	bclr.l	#FIRST_LINE,d0
	tst.w	d2
	dble	d4,.m10_esc_bcl_y
	dbgt	d4,.m10_bcl_y
	bra	.m10_fini
.m10_esc_skip
	sub.w	d5,d2
	addq.w	#1,d0	; d0 = width/8
	move.l	a6,d5
	lsl.l	#3,d5
	sub.w	d2,d1
	bpl.s	.m10_esc_skip_x
.m10_esc_skip_y
	IF	POS_Y
	add.l	#8<<16,d4
	ENDC
	sub.w	d0,d2
	subq.w	#1,d4		; une ligne de moins … faire
	add.l	d5,a1		; ligne suivante
	add.l	d5,a3
	add.w	d0,d1
	bmi.s	.m10_esc_skip_y
.m10_esc_skip_x
	subq.w	#1,d0	; restitue d0
	lsl.w	#3,d2		; d2 est sign‚, c'est la diff‚rence en x
	add.w	d2,a1		; ajustement en x
	add.w	d2,a3
	addq.w	#1,d1
	tst.w	d4
	dbmi	d1,.m10_bcl_y
	bpl	.m10_continue
	bra	.m10_fini
.m10_bloc_mono		; 50
	subq.w	#3,d3
	blo	.fini
	move.b	(a0)+,d7
	bclr.l	#7,d7
	beq.s	.m10_mono_pas_repeat
	bchg.l	#REPEAT,d0
	bne.s	.m10_mono_pas_repeat
	subq.l	#2,a0
.m10_mono_pas_repeat
	bfins	d7,d7{16:8}
	bfins	d7,d7{0:16}
	move.l	d7,d6
	addq.w	#7,d3		; d3=7
.m10_mono_bcl
	movem.l	d6/d7,(a3)
	add.l	a6,a3
	dbf	d3,.m10_mono_bcl
	lea	(a1,a6.l*8),a1
	IF	POS_Y
	add.l	#8<<16,d4
	ENDC
	dbf	d1,.m10_bcl_x
	bra	.m10_continue
.m10_saute_bloc_rep	; 8
	bchg.l	#REPEAT,d0
	bne.s	.m10_saute_bloc	; pas_2_fois
	subq.l	#1,a0
.m10_saute_bloc
	subq.w	#3,d3
	blo	.fini
	IF	POS_Y
	add.l	#8<<16,d4
	ENDC
	lea	(a1,a6.l*8),a1
	lea	(a3,a6.l*8),a3
	dbf	d1,.m10_bcl_x
	bra	.m10_continue

.mode_10_pmv
	IF	DEBUG_IV32
	addq.l	#1,saw_mode_10_pmv
	ENDC
	* delta 8*8 sans interpolation
	; d0 : flags:largeur_cellule/4-1	a0 : commandes
	; d1 : hauteur_cellule/4-1:cpt_x	a1 : source (dst-width)
	; d2 : octet_courant1:octet_courant2.w	a2 : origine destination (new img)
	; d3 : cpt_dbf_bits:cpt_4_lignes	a3 : destination courante
	; d4 : cpt_y				a4 : corr type
	; d5 : corrTyp ou temp1			a5 : correction Low Order
	; d6 : temp2				a6 : width
	; d7 : cpt_esc ou temp3
	swap	d4
	move.w	a6,d4
	subq.w	#4,d4
	swap	d4
			; quad+dyad = . +copy = 
.m10p_bcl_y		; 24
	swap	d4
	move.w	d0,d1	; cpt_x
	bra.s	.m10p_entree_bcl_x
.m10p_bcl_x
	move.l	a6,d5
	lsl.l	#3,d5
	subq.l	#8,d5	; width*8-8
	sub.l	d5,a1
	sub.l	d5,a3
.m10p_entree_bcl_x
	IF	DEBUG_IV32
	cmp.l	#SAW_MODE_10,saw_mode_10
	bmi.s	*+8
	bsr	convert_yuv_grey_iv32
	illegal
	ENDC
	move.w	#3,d3
.m10p_bcl_bloc		; 54
	move.b	(a0)+,d2
	move.w	(a4,d2.w*2),d5
	beq.s	.m10p_quad
	subq.w	#1,d5
	beq.s	.m10p_dyad
	clr.w	d2
	subq.w	#1,d5
	beq	.m10p_copie_jusque_l1
	subq.w	#1,d5
	beq	.m10p_copie_jusque_l2
	subq.w	#1,d5
	beq	.m10p_copie_jusque_l3
	subq.w	#1,d5
	beq	.m10p_copie_jusque_l3_rep
	subq.w	#3,d5
	beq	.m10p_sequence_echappe
	addq.w	#2,d5
	beq	.m10p_copie_jusque_l3		; identique … '.m10p_saute_bloc' car pMV=1
	subq.w	#1,d5
	beq.s	.m10p_copie_jusque_l3_rep	; .m10p_saute_bloc_rep
	subq.w	#2,d5
	beq	.m10p_bloc_mono
	IF	DEBUG_IV32
	illegal
	ENDC
	bra	.fini
.m10p_quad		; 12
	move.l	(a5,d2.w*4),d6		; corrLow -> pixels 1133
	move.l	($6000.w,a5,d2.w*4),d7	; corrHi  -> pixels 5577
	bra.s	.m10p_quad_ecrire
.m10p_dyad		; 10
	move.l	(a5,d2.w*4),d7
	move.b	(a0)+,d2
	move.l	(a5,d2.w*4),d6
.m10p_quad_ecrire
	movem.l	(a1),d5/a2		; ligne 0
	add.l	d6,d5
	add.l	d7,a2
	movem.l	d5/a2,(a3)
	add.l	a6,a1		; ligne 1
	add.l	a6,a3
	add.l	(a1)+,d6
	add.l	(a1),d7
	movem.l	d6/d7,(a3)
	add.w	d4,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m10p_bcl_bloc
	dbf	d1,.m10p_bcl_x
.m10p_continue
	move.w	d0,d1
	lsl.w	#3,d1	; cellWidth-8
	swap	d4
	sub.w	d1,a1
	sub.w	d1,a3
	dbf	d4,.m10p_bcl_y
.m10p_fini
	lsl.w	#1,d0
	addq.w	#1,d0	; X*2+1 est ‚quivalent … (X+1)*2-1
	swap	d1
	swap	d2
	addq.w	#1,d1
	addq.w	#1,d0
	lsl.w	#2,d1
	lsl.w	#2,d0
	IF	POS_Y
	add.w	d1,pos_y
	ENDC
	swap	d3
	bra	.cellule_suivante
.m10p_copie_jusque_l3_rep	; 10
	bchg.l	#REPEAT,d0
	bne.s	.m10p_copie_jusque_l3	; pas_2_fois
	subq.l	#1,a0
	bra.s	.m10p_copie_jusque_l3
.m10p_copie_jusque_l2	; 26
	subq.w	#1,d2		; laisse 1 ligne de moins
	addq.w	#1,d3		; besoins d'une it‚ration de plus
.m10p_copie_jusque_l1
	addq.w	#2,d2		; laisse 2 lignes
	subq.w	#2,d3
	bls	.fini
.m10p_copie_jusque_l3
	move.l	(a1)+,(a3)+
	move.l	(a1),(a3)
	add.w	d4,a3
	add.w	d4,a1
	move.l	(a1)+,(a3)+
	move.l	(a1),(a3)
	add.w	d4,a3		; ligne suivante
	add.w	d4,a1
	dbf	d3,*-16
	move.w	d2,d3		; restitue cpt_lignes
	dbf	d3,.m10p_bcl_bloc
	dbf	d1,.m10p_bcl_x
	bra.s	.m10p_continue
.m10p_sequence_echappe	; 70+38=108
	clr.w	d2
	move.b	(a0)+,d2		; d‚bute ‚chappe
	moveq	#32,d5
	cmp.w	d5,d2
	blo.s	.m10p_esc_ok
	sub.w	d5,d2
.m10p_esc_ok
	move.l	a6,d5	; width*8-8
	lsl.l	#3,d5
	subq.l	#8,d5
	clr.l	d6
	move.w	d0,d6
	lsl.l	#3,d6
	clr.l	d7
	move.w	d4,d7
	bra.s	.m10p_esc_copy
.m10p_esc_bcl_y
	swap	d4
	move.w	d0,d1	; cpt_x
	bra.s	.m10p_esc_entree
.m10p_esc_bcl_x
	sub.l	d5,a1
	sub.l	d5,a3
.m10p_esc_entree
	addq.w	#4,d3
.m10p_esc_copy
	move.l	(a1)+,(a3)+
	move.l	(a1),(a3)
	add.l	d7,a1
	add.l	d7,a3
	move.l	(a1)+,(a3)+
	move.l	(a1),(a3)
	add.l	d7,a1
	add.l	d7,a3		; ligne suivante
	dbf	d3,.m10p_esc_copy
	subq.w	#1,d2
	dble	d1,.m10p_esc_bcl_x
	dbgt	d1,.m10p_bcl_x
	swap	d4
	sub.l	d6,a1		; revient en arriŠre de la largeur de la cellule - 8
	sub.l	d6,a3
	tst.w	d2
	dble	d4,.m10p_esc_bcl_y
	dbgt	d4,.m10p_bcl_y
	bra	.m10p_fini
.m10p_bloc_mono		; 50
	subq.w	#3,d3
	blo	.fini
	move.b	(a0)+,d7
	bclr.l	#7,d7
	beq.s	.m10p_mono_pas_repeat
	bchg.l	#REPEAT,d0
	bne.s	.m10p_mono_pas_repeat
	subq.l	#2,a0
.m10p_mono_pas_repeat
	bfins	d7,d7{16:8}
	bfins	d7,d7{0:16}
	move.l	d7,d6
	addq.w	#7,d3		; d3=7
.m10p_mono_bcl
	movem.l	d6-d7,(a3)
	add.l	a6,a3
	dbf	d3,.m10p_mono_bcl
	lea	(a1,a6.l*8),a1
	dbf	d1,.m10p_bcl_x
	bra	.m10p_continue
.mode_11
	IF	DEBUG_IV32
	addq.l	#1,saw_mode_11
	ENDC
	btst.l	#PMV,d0
	beq	.fini
	* delta 4*8 avec motion vector sans interpolation
	; d0 : flags:largeur_cellule/4-1	a0 : commandes
	; d1 : hauteur_cellule/4-1:cpt_x	a1 : source (dst-width)
	; d2 : octet_courant1:octet_courant2.w	a2 : origine destination (new img)
	; d3 : cpt_dbf_bits:cpt_4_lignes	a3 : destination courante
	; d4 : cpt_y				a4 : corr type
	; d5 : corrTyp ou temp1			a5 : correction 2 ou 1
	; d6 : temp2				a6 : width
	; d7 : cpt_esc ou temp3
	move.w	d0,d1	; cpt_x
	bra.s	.m11_bcl_y
.m11_bcl_x
	move.l	a6,d5
	lsl.l	#3,d5
	subq.l	#4,d5	; width*8-4
	sub.l	d5,a1
	sub.l	d5,a3
.m11_bcl_y
	IF	DEBUG_IV32
	bra.s	*+6
	bsr	convert_yuv_grey_iv32
	ENDC
	move.w	#3,d3
.m11_bcl_bloc		; 50
	move.b	(a0)+,d2
	move.w	(a4,d2.w*2),d5
	beq.s	.m11_quad
	subq.w	#1,d5
	beq.s	.m11_dyad
	clr.w	d6
	subq.w	#1,d5
	beq	.m11_copie_jusque_l1
	subq.w	#1,d5
	beq	.m11_copie_jusque_l2
	subq.w	#1,d5
	beq	.m11_copie_jusque_l3
	subq.w	#1,d5
	beq	.m11_copie_jusque_l3_rep
	subq.w	#3,d5
	beq	.m11_sequence_echappe
	addq.w	#2,d5
	beq	.m11_copie_jusque_l3; '.m11_saute_bloc' est identique puisque pMV=1
	subq.w	#1,d5
	beq	.m11_copie_jusque_l3_rep; mˆme chose, parce que pMV=1
	subq.w	#2,d5
	beq	.m11_bloc_mono
	IF	DEBUG_IV32
	illegal
	ENDC
	bra	.fini
.m11_quad		; 10
	move.l	(a5,d2.w*4),d5
	move.l	(a1),d6
	add.l	a6,a1
	add.l	d5,d6
	add.l	(a1),d5
	move.l	d6,(a3)
	add.l	a6,a3
	add.l	a6,a1		; ligne suivante
	move.l	d5,(a3)
	add.l	a6,a3
	dbf	d3,.m11_bcl_bloc
	dbf	d1,.m11_bcl_x
	bra.s	.m11_continue
.m11_dyad		; 24
	move.l	(a1),d6
	add.l	a6,a1
	move.l	(a1),d7
	move.w	2(a5,d2.w*4),d5
	add.w	d5,d6
	add.w	d5,d7
	move.b	(a0)+,d2
	swap	d6
	move.w	2(a5,d2.w*4),d5
	add.w	d5,d6
	swap	d6
	move.l	d6,(a3)
	swap	d7
	add.w	d5,d7
	add.l	a6,a3
	swap	d7
	move.l	d7,(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m11_bcl_bloc
	dbf	d1,.m11_bcl_x
.m11_continue
	move.w	d0,d1
	lsl.w	#2,d1	; cellWidth*4-4
	sub.w	d1,a1
	sub.w	d1,a3
	move.w	d0,d1	; cpt_x
	dbf	d4,.m11_bcl_y
.m11_fini
	swap	d1
	swap	d2
	addq.w	#1,d1	; (X-1)/2 est ‚quivalent … faire (X+1)/2-1
	addq.w	#1,d0
	lsl.w	#2,d1
	lsl.w	#2,d0
	IF	POS_Y
	add.w	d1,pos_y
	ENDC
	swap	d3
	bra	.cellule_suivante
.m11_copie_jusque_l3_rep	; 10
	bchg.l	#REPEAT,d0
	bne.s	.m11_copie_jusque_l3	; pas_2_fois
	subq.l	#1,a0
	bra.s	.m11_copie_jusque_l3
.m11_copie_jusque_l2	; 26
	subq.w	#1,d6		; laisse 1 ligne de moins
	addq.w	#1,d3		; besoins d'une it‚ration de plus
.m11_copie_jusque_l1
	addq.w	#2,d6		; laisse 2 lignes
	subq.w	#2,d3
	bls	.fini
.m11_copie_jusque_l3
	move.l	(a1),(a3)
	add.l	a6,a1
	add.l	a6,a3
	move.l	(a1),(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,*-12
	move.w	d6,d3		; restitue cpt_lignes
	dbf	d3,.m11_bcl_bloc
	dbf	d1,.m11_bcl_x
	bra.s	.m11_continue
.m11_sequence_echappe	; 70+46=116
	clr.w	d2
	move.b	(a0)+,d2		; d‚bute ‚chappe
	moveq	#32,d5
	cmp.w	d5,d2
	blo.s	.m11_esc_ok
	sub.w	d5,d2
.m11_esc_ok
	move.l	a6,d7
	lsl.l	#3,d7
	subq.l	#4,d7	; width*4-4
	move.w	d0,d5		; (le 'moveq' pr‚c‚dent remplace un 'clr')
	lsl.l	#2,d5
	bra.s	.m11_esc_copy
.m11_esc_bcl_x
	sub.l	d7,a1
	sub.l	d7,a3
.m11_esc_bcl_y
	addq.w	#4,d3
.m11_esc_copy
	move.l	(a1),(a3)
	add.l	a6,a1
	add.l	a6,a3
	move.l	(a1),(a3)
	add.l	a6,a1		; ligne suivante
	add.l	a6,a3
	dbf	d3,.m11_esc_copy
	subq.w	#1,d2
	dble	d1,.m11_esc_bcl_x
	dbgt	d1,.m11_bcl_x
	sub.l	d5,a1		; revient en arriŠre de la largeur de la cellule - 4
	sub.l	d5,a3
	move.w	d0,d1	; cpt_x
	tst.w	d2
	dble	d4,.m11_esc_bcl_y
	dbgt	d4,.m11_bcl_y
	bra	.m11_fini
.m11_bloc_mono		; 50
	subq.w	#3,d3
	blo	.fini
	move.b	(a0)+,d7
	bclr.l	#7,d7
	beq.s	.m11_mono_pas_repeat
	bchg.l	#REPEAT,d0
	bne.s	.m11_mono_pas_repeat
	subq.l	#2,a0
.m11_mono_pas_repeat
	bfins	d7,d7{16:8}
	bfins	d7,d7{0:16}
	addq.w	#7,d3		; d3=7
.m11_mono_bcl
	move.l	d7,(a3)
	add.l	a6,a3
	dbf	d3,.m11_mono_bcl
	lea	(a1,a6.l*8),a1
	dbf	d1,.m11_bcl_x
	bra	.m11_continue
.cellule_suivante_m3_m10
	IF	POS_Y
	swap	d4
	move.w	d4,pos_y
	ENDC
	swap	d1
	swap	d2
	swap	d3
	addq.w	#1,d1
	addq.w	#1,d0
	lsl.w	#2,d1
	lsl.w	#2,d0
.cellule_suivante
	bset.l	#SON_NB,d0
	bne.s	.division_finie
	IFNE	OPT_IV32
	move.w	(sp),d7			; recopie le bit pMV
	bfextu	d7{31-PMV+16:1},d5
	bfins	d5,d0{31-PMV:1}
	lsr.w	#8,d7
	bfins	d7,d0{31-VALID_PMV:1}	; ‡a, c'‚tait une erreur d'h‚r‚dit‚...
	ELSE
	swap	d0		; on recopie tout, sauf SON_NB=1
	move.w	(sp),d0		; (et puisque SON_NB=1, on se fiche de VERT)
	or.w	#1<<(SON_NB-16),d0
	swap	d0
	ENDC
	move.l	8(sp),a2
	btst.l	#VERT,d0
	bne.s	.fils_1_vert
.fils_1_horiz
	move.l	precalc_multiples_iv32(pc),a4
	add.l	(a4,d1.w*4),a2	; passe au fils en bas
	neg.w	d1
	add.w	4+2(sp),d1	; taille verticale compl‚mentaire
	lsl.b	#1,d2
	dbcc	d3,.commandes
	dbcs	d3,.separations
	bra	.nouvel_octet
.fils_1_vert
	IF	POS_Y
	sub.w	d1,pos_y
	IF	DEBUG_IV32
	bpl.s	*+4
	illegal
	ENDC
	ENDC
	add.w	d0,a2		; passe au fils de droit
	neg	d0
	add.w	2(sp),d0	; taille horizontale compl‚mentaire
	cmpa.l	offset_last_strip_iv32(pc),a2
	beq.s	..corrige_largeur
..retour_corrige
	lsl.b	#1,d2
	dbcc	d3,.commandes
	dbcs	d3,.separations
	bra	.nouvel_octet
..corrige_largeur
	; il n'est pas n‚c‚ssaire de savoir si la cellule d‚borde r‚element,
	; puisque la premiŠre … d‚border sera la seule … ˆtre corrig‚e, et
	; on connaŒt son pos_x (c'est pos_last_strip_iv32)
;	cmp.w	last_strip_left_iv32(pc),d0
;	bls.s	..retour_corrige
	move.w	last_strip_left_iv32(pc),d0
	bra.s	..retour_corrige
.division_finie
	swap	d0
	move.b	d0,d7
	tst.w	niveau_recursion_iv32(pc)
	ble.s	.fini
	* prend le pŠre
	movem.l	(sp)+,d0-d1/a2	; remonte au niveau sup‚rieur de l'arborescence
	subq.w	#1,niveau_recursion_iv32
	ble.s	.fini
	bfins	d7,d0{8:8}	; recopie les flags non h‚r‚ditaires
	move.b	(sp),d7
	* recopie la validit‚ du pMV du pŠre de ce pŠre
	bfins	d7,d0{31-VALID_PMV:1}	; ‡a, c'‚tait une erreur d'h‚r‚dit‚...
	bra	.cellule_suivante
.fini
	move.w	niveau_recursion_iv32(pc),d0
	bgt.s	.depiler
	rts
.depiler
	moveq	#12,d1
.bcl_depile
	add.l	d1,sp
	subq.w	#1,d0
	bgt.s	.bcl_depile
	IF	DEBUG_IV32
	bsr.s	convert_yuv_grey_iv32
	ENDC
	rts

********************************************************************************
	BSS
********************************************************************************
info_entree_iv32
	ds.b	info_init_codec.video_sizeof
	even
info_retour_iv32
	ds.b	information_module.sizeof
	even
	ds.l	10
*****************
prec_yuv_iv32
	ds.l	1
precalc_multiples_y_adr_bloc_iv32
	ds.l	1
precalc_multiples_uv_adr_bloc_iv32
	ds.l	1
precalc_multiples_iv32
	ds.l	1
precalc_multiples_y_iv32
	ds.l	1
precalc_multiples_uv_iv32
	ds.l	1
passe_ligne_iv32	ds.w	1
taille_ligne_iv32	ds.w	1
*****************
y1_buffer_adr_bloc
	ds.l	1
y2_buffer_adr_bloc
	ds.l	1
y1_buffer	ds.l	1
u1_buffer	ds.l	1
v1_buffer	ds.l	1

y2_buffer	ds.l	1
u2_buffer	ds.l	1
v2_buffer	ds.l	1
*****************
difference_buffers_iv32
	ds.l	1
change_y2_iv32
	ds.w	1
;version_iv32
;	ds.w	1
flags_iv32
	ds.w	1
;dsize_iv32
;	ds.l	1
cb_offset_iv32
	ds.w	1
;cb_set_iv32
;	ds.b	1
height_iv32
	ds.w	1
width_iv32
	ds.w	1
;strip_width_iv32
;	ds.w	1
first_width_iv32
	ds.w	1
pos_last_strip_y_iv32
	ds.w	1
last_strip_left_y_iv32
	ds.w	1
********
height_uv_iv32
	ds.w	1
width_uv_iv32
	ds.w	1
;strip_width_uv_iv32
;	ds.w	1
first_width_uv_iv32
	ds.w	1
pos_last_strip_uv_iv32
	ds.w	1
last_strip_left_uv_iv32
	ds.w	1
********
pos_last_strip_iv32
	ds.w	1
last_strip_left_iv32
	ds.w	1
offset_last_strip_iv32
	ds.l	1
********
off_y_iv32
	ds.l	1
off_v_iv32
	ds.l	1
off_u_iv32
	ds.l	1
pred_tbls_iv32
	ds.l	1
pmv_iv32
	ds.l	1
niveau_recursion_iv32
	ds.w	1
motion_vector_iv32
	ds.l	1
********
indeo_o
data_indeo
	ds.l	1
********
pos_y
	ds.w	1
