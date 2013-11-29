	include	structs.s
	include	zlib.i


	XDEF	ob_real_g_box
	XDEF	ob_real_g_text
	XDEF	ob_real_g_boxtext
	XDEF	ob_real_g_image
	XDEF	ob_real_g_progdef
	XDEF	ob_real_g_ibox
	XDEF	ob_real_g_button
	XDEF	ob_real_g_boxchar
	XDEF	ob_real_g_string
	XDEF	ob_real_g_ftext
	XDEF	ob_real_g_fboxtext
	XDEF	ob_real_g_icon
	XDEF	ob_real_g_title
	XDEF	ob_real_g_cicon

;	XDEF	0		ob_real_g_bounding
;	XDEF	0		ob_real_g_bounded
	XDEF	ob_real_g_pix
	XDEF	ob_real_g_line
;	XDEF	0		ob_real_g_check



***********************************************************************
*** Fonction realisant une copie de ce qui est pointe par l'ob_spec ***
*** et remplace celui-ci par un nouveau                             ***
***********************************************************************
	XDEF	objc_real_rout
objc_real_rout
	movem.l	d1-a6,-(sp)
	move.l	60(sp),a6	; adresse de l'objet a reloger
	lea	ob_spec(a6),a5	; adresse de l'ob_spec
	btst	#0,ob_flags(a6)
	beq	not_indirect
	move.l	(a5),a5
not_indirect
	move.l	(a5),d3
	moveq.l	#0,d1
	move.b	ob_type+1(a6),d1	; L'ob_type, non etendu, donne l'index dans la table de saut
	sub.w	#20,d1
	bge	.ok
	cmp.w	#13,d1
	ble	.ok
	illegal
.ok

	jmp	([table_de_saut.w,pc,d1.w*4])		; la table commence a partir de l'objet #20

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 1 L -> On ne touche pas au champ de bit...
ob_real_g_box
ob_real_g_ibox
ob_real_g_boxchar
ob_real_g_line
	movem.l	(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 1 tedinfo -> On malloc un bloc de la taille d'une tedinfo, puis on reserve
* 256 octet par chaine aucupe...
ob_real_g_text
ob_real_g_boxtext
ob_real_g_ftext
ob_real_g_fboxtext
	add.w		#20,d1	; d1 redevient ce qu'il etait avant, cad le type de l'objet (pas diminue de 20)
* Donc, le Malloc... pour la structure TEDINFO !
	move.w		d1,d4
	xaloc_aloc	#te_struc_size,a5
	move.w		#te_struc_size/2,d5
	subq.w		#1,d5
	move.l		d3,a1
	move.l		d0,(a5)
	move.l		d0,a6
	move.l		d0,a0

* La copie de la tedinfo
.loop_reloge_spec_tedinfo
	move.w		(a1)+,(a0)+
	dbf		d5,.loop_reloge_spec_tedinfo

* La tedinfo contien une chaine quelque soit le type d'objet : on la reloge.
	move.l		d3,a1
	move.l		(a1),a1
	moveq.l		#0,d0
.boucle_calcul_taille_txt_tedinfo
	addq.w		#1,d0
	tst.b		(a1)+
	bne		.boucle_calcul_taille_txt_tedinfo

	add.l		#1,d0
	and.l		#-2,d0	; on arondi a 2 au dessus
	xaloc_aloc	d0,a6
	move.l		d0,a0
	move.l		d3,a1
	move.l		d0,(a6)
	move.l		(a1),a1
.boucle_copy_txt_tedinfo
	move.b		(a1)+,(a0)+
	bne		.boucle_copy_txt_tedinfo
	move.l		d3,a1

	cmp.w		#G_FTEXT,d1
	beq		.reloge_les_2_autre_chaine
	cmp.w		#G_FBOXTEXT,d1
	beq		.reloge_les_2_autre_chaine
	move.l		a6,d3				; on oubli pas le retour : adresse de la tedinfo
	move.l		a6,d0
	movem.l		(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
.reloge_les_2_autre_chaine
* La chaine 2...
	move.l		te_ptmplt(a6),a0
	lea		te_ptmplt(a6),a1

	moveq.l		#0,d0
.calcul_ptmplt_size
	addq.w		#1,d0
	tst.b		(a0)+
	bne		.calcul_ptmplt_size
	sub.l		d0,a0

	xaloc_aloc	d0,a1
	move.l		d0,(a1)
	move.l		d0,a1
.copy_ptmplt_size
	move.b		(a0)+,(a1)+
	bne		.copy_ptmplt_size

* ... et La chaine 3 ne sont utilise que pour les G_FBOXTEXT et G_FTEXT
	move.l		te_pvalid(a6),a0
	lea		te_pvalid(a6),a1

	moveq.l		#0,d0
.calcul_pvalid_size
	addq.w		#1,d0
	tst.b		(a0)+
	bne		.calcul_pvalid_size
	sub.l		d0,a0

	xaloc_aloc	d0,a1
	move.l		d0,(a1)
	move.l		d0,a1
.calcul_ptmplt_valid
	move.b		(a0)+,(a1)+
	bne		.calcul_ptmplt_valid

	movem.l		(sp)+,d1-a6
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 1 chaine -> On reserve 256 octets dans lesquels on place la chaine
ob_real_g_string
ob_real_g_button
ob_real_g_title
	move.l		d3,a0
	clr.l		d0
.boucle_recherche_chaine_size
	addq.l		#1,d0
	tst.b		(a0)+
	bne		.boucle_recherche_chaine_size

	xaloc_aloc	d0,a5
	move.l		d0,(a5)
	move.l		d3,a0
	move.l		d0,a1
.boucle_reloge_spec_chaine
	move.b		(a0)+,(a1)+
	bne		.boucle_reloge_spec_chaine
	move.l		d0,d3

	movem.l		(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
ob_real_g_image
	xaloc_aloc	#bi_struc_size,a5	; BITBLK struct
	move.l		d0,(a5)
	move.l		d0,d2

* On recopie la structure BITBLK
	move.l		d3,a0
	move.l		d0,a1
	move.w		#bi_struc_size/2,d4
	subq.w		#1,d4
.boucle_reloge_spec_bitblk
	move.w		(a0)+,(a1)+
	dbf		d4,.boucle_reloge_spec_bitblk
	move.l		d0,a0

* On calcul la taille du graphique.
	clr.l		d0
	move.w		bi_wb(a0),d0
	clr.l		d4
	move.w		bi_hl(a0),d4
	mulu.l		d0,d4

* on reservela taille de celui-ci

	xaloc_aloc	d4,a0

* on reloge bi_pdata et on copie ce qu'il pointait dans le malloc predecedent
	move.l		(a0),a1
	move.l		d0,(a0)
	move.l		d0,a0
	lsr.l		#1,d4
.loop_copy_monocrome_graf
	move.w		(a1)+,(a0)+
	subq.l		#1,d4
	bne		.loop_copy_monocrome_graf
	move.l		d2,d0
	move.l		d2,d3
	movem.l		(sp)+,d1-a6
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
ob_real_g_icon
* On calcul la taille du mask

;* Realocation de la structure
	move.l		#36,d7	; ib_struc_size_mono
	xaloc_aloc	d7,a5
	move.l		d0,(a5)
	move.l		d0,a0
	move.l		d0,d5	; adresse de base de la structure de l'objet

	move.l		d3,a1
	lsr.w		#1,d7
	subq.w		#1,d7
.boucle_g_icon_struc
	move.w		(a1)+,(a0)+
	dbf		d7,.boucle_g_icon_struc

	move.l		d3,a0
	clr.l		d6
	move.w		ib_wicon(a0),d6			; (largeur+7 / 8) * hauteur = taille en octet
	add.w		#7,d6
	lsr.w		#3,d6
	clr.l		d7
	move.w		ib_hicon(a0),d7
	mulu.l		d7,d6
	move.l		d7,d1
	move.l		d6,d0
	move.l		d0,d4			; d4 = taille du plan de bit

;* Realocation du mask
	xaloc_aloc	d0,d5
	move.l		d0,a0

	move.l		d5,a1
	move.l		d0,(a1)			; copie du pointeur

	move.l		d3,a1
	move.l		(a1),a1
	move.l		d4,d1
	lsr.l		#1,d1
.boucle_copi_le_mask_de_licone
	move.w		(a1)+,(a0)+
	subq.l		#1,d1
	bne		.boucle_copi_le_mask_de_licone
	move.l		d3,a1
;	move.l		d0,(a1)

;* Realocation du data
	move.l		d5,d1
	add.l		#ib_pdata,d1
	xaloc_aloc	d6,d1
	move.l		d5,a0
	move.l		d0,ib_pdata(a0)
	move.l		d0,a0
	move.l		d0,d6

	move.l		ib_pdata(a1),a1
	move.l		d4,d1
	lsr.l		#1,d1
.boucle_copi_le_data_de_licone
	move.w		(a1)+,(a0)+
	subq.l		#1,d1
	bne		.boucle_copi_le_data_de_licone
	move.l		d3,a1


	clr.l		d0
	move.l		ib_ptext(a1),a1
.boucle_tst_taille_text_de_licone
	addq.w		#1,d0
	tst.b		(a1)+
	bne		.boucle_tst_taille_text_de_licone

	move.l		d5,d1
	addq.l		#ib_ptext,d1
	move.l		d1,a6
	xaloc_aloc	d0,d1
	move.l		d3,a1
	move.l		d0,a0
	move.l		d0,(a6)

	move.l		ib_ptext(a1),a1
.boucle_copi_le_text_de_licone
	move.b		(a1)+,(a0)+
	bne		.boucle_copi_le_text_de_licone

	movem.l		(sp)+,d1-a6
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Note : le coeur de la routine est pratiquement le meme que pour un g_icon
* puisque un icone couleur contient un icone monochrome.
* Note apres devellopement finalise : c'est de la merde et faut TOUT recoder.
* Font chier la mere chez Atari
ob_real_g_cicon
* On calcul la taille du mask
	move.l		d3,a0
	move.l		#ib_struc_size_color,d7
	xaloc_aloc	d7,a5
	move.l		d0,(a5)
	move.l		d0,a6
	move.l		d0,a1
	lsr.w		#1,d7
	subq.w		#1,d7
.g_cicon_struc_copy
	move.w		(a0)+,(a1)+
	dbf		d7,.g_cicon_struc_copy

	moveq.l		#0,d6
	move.w		ib_wicon(a6),d6			; (largeur+7 / 8) * hauteur = taille en octet d'un bloc mono
	add.w		#7,d6
	lsr.w		#3,d6
	moveq.l		#0,d7
	move.w		ib_hicon(a6),d7
	mulu.l		d7,d6
	move.l		d6,d4	; d6=taille en octet d'un bloc monochrome

;* Copy du mask monochrome
	xaloc_aloc	d6,a6
	move.l		d0,(a6)
	move.l		d3,a0
	move.l		d0,a1
	move.l		(a0),a0
	move.l		d6,d5
	lsr.l		#1,d5
.g_cicon_mask_mono
	move.w		(a0)+,(a1)+
	sub.l		#1,d5
	bne		.g_cicon_mask_mono

;* Idem pour les data
	move.l		a6,d0
	addq.l		#ib_pdata,d0
	xaloc_aloc	d6,d0
	move.l		d0,ib_pdata(a6)
	move.l		d3,a0
	move.l		d0,a1
	move.l		ib_pdata(a0),a0
	move.l		d6,d5
	lsr.l		#1,d5
.g_cicon_data_mono
	move.w		(a0)+,(a1)+
	sub.l		#1,d5
	bne		.g_cicon_data_mono

;* Calcul taille du texte
	clr.l		d0
	move.l		ib_ptext(a6),a0
	move.l		ib_ptext(a6),a1
.g_cicon_text_tst
	addq.l		#1,d0
	tst.b		(a0)+
	bne		.g_cicon_text_tst

;* Copy du texte
	move.l		a6,d1
	add.l		#ib_ptext,d1
	xaloc_aloc	d0,d1
	move.l		d0,a0
	move.l		d0,ib_ptext(a6)
.g_cicon_text_copy
	move.b		(a1)+,(a0)+
	bne		.g_cicon_text_copy

;* Preparation de la boucle de couleur
	move.l		ib_resvd(a6),a0
	tst.l		a0
	beq		.g_cicon_end

	move.l		a6,a1
	add.l		#ib_resvd,a1

;* Boucle copy de la partie couleur
.g_cicon_color_main_boucle
	move.l		#ciconblk_struc_size,d1
	xaloc_aloc	d1,a1
	move.l		d0,(a1)
	move.l		d0,a1

	lsr.w		#1,d1
	subq.w		#1,d1
.g_cicon_colstruc_copy
	move.w		(a0)+,(a1)+
	dbf		d1,.g_cicon_colstruc_copy

	sub.l		#ciconblk_struc_size,a0
	sub.l		#ciconblk_struc_size,a1

	clr.l		d1
	move.w		num_planes(a1),d1
;	bpl		.ok_resol
;	neg		d1
;.ok_resol
	mulu.l		d6,d1		; d1 est la taille du plan de bit

;* Copy du data
	move.l		a1,a3
	move.l		col_data(a1),d5
	add.l		#col_data,a3
	xaloc_aloc	d1,a3
	move.l		d0,(a3)

	bloc_move	d1,d5,d0

;* Copy du mask
	move.l		a1,a3
	move.l		col_mask(a1),d5
	add.l		#col_mask,a3
	xaloc_aloc	d6,a3
	move.l		d0,(a3)

	bloc_move	d6,d5,d0

;* Copy du data (partie selectionne)
	move.l		a1,a3
	move.l		sel_data(a1),d5
	beq		.pas_de_selection
	add.l		#sel_data,a3
	xaloc_aloc	d1,a3
	move.l		d0,(a3)

	bloc_move	d1,d5,d0

;* Copy du mask (partie selectionne)
	move.l		a1,a3
	move.l		sel_mask(a1),d5
	beq		.pas_de_selection
	add.l		#sel_mask,a3
	xaloc_aloc	d6,a3
	move.l		d0,(a3)

	bloc_move	d6,d5,d0

.pas_de_selection
	move.l		next_res(a0),a0
	add.l		#next_res,a1
	tst.l		a0
	bne		.g_cicon_color_main_boucle


.g_cicon_end
	move.l		a6,d0
	move.l		a6,d3
	movem.l		(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
ob_real_g_progdef
	XREF		user_blk
	move.l		#user_blk,(a5)
	movem.l		(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
ob_real_g_bounding
ob_real_g_bounded
ob_real_g_pix
	move.l		#sizeof_gpix,d7
	xaloc_aloc	d7,a5
	move.l		d0,(a5)
	move.l		d3,a4
	move.l		d0,a3
	moveq.l		#(sizeof_gpix/2)-1,d6
.lp_cp_struct
	move.w		(a4)+,(a3)+
	dbf		d6,.lp_cp_struct

	move.l		(a5),a4
	string_size	(a4)
	move.l		(a4),a3
	move.w		d0,d6
	subq.w		#1,d6
	xaloc_aloc	d0,a4
	move.l		d0,(a4)
	move.l		d0,a2
.lp_cp_chemin
	move.b		(a3)+,(a2)+
	dbf		d6,.lp_cp_chemin

	movem.l		(sp)+,d1-a6
	rts
ob_real_g_check
**************************************
* une petite table pour un jmp d0*4...
table_de_saut		 			; et c'est beaucoup plus rapide !
	dc.l	ob_real_g_box
	dc.l	ob_real_g_text
	dc.l	ob_real_g_boxtext
	dc.l	ob_real_g_image
	dc.l	ob_real_g_progdef
	dc.l	ob_real_g_ibox
	dc.l	ob_real_g_button
	dc.l	ob_real_g_boxchar
	dc.l	ob_real_g_string
	dc.l	ob_real_g_ftext
	dc.l	ob_real_g_fboxtext
	dc.l	ob_real_g_icon
	dc.l	ob_real_g_title
	dc.l	ob_real_g_cicon

	dc.l	0		ob_real_g_bounding
	dc.l	0		ob_real_g_bounded
	dc.l	ob_real_g_pix
	dc.l	ob_real_g_line
	dc.l	0		ob_real_g_check
****************************************************************************************
