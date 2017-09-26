	text
objc_realoc	macro	ob_spec,ob_type
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr		reloge_specific_part_routine
	addq.l	#6,sp
	endm
***************************************************************************************************
* en entre : 4(sp).W contient le type de l'objet
*			 6(sp).L contient le ob_spec de l'objet source
* en sortie : d3.l contient le nouvel ob_spec
reloge_specific_part_routine
* Attention ! Il ce peut qu'il y est des objets que je ne connais pas.
	movem.l	d1-d4/a6,-(sp)
	move.w	24(sp),d1
	move.l	26(sp),d3
	andi.w	#$ff,d1
	sub.w	#20,d1				; la table commence a partir de l'objet #20
	jmp		([.table_de_saut.w,pc,d1.w*4])
	
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 1 L -> On ne touche pas au champ de bit...
.crg_g_box
.crg_g_ibox
.crg_g_boxchar
	move.l	d3,d0
	movem.l	(sp)+,d1-d4/a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 1 tedinfo -> On malloc un bloc de la taille d'une tedinfo, puis on reserve
* 256 octet par chaine aucupe...
.crg_g_text
.crg_g_boxtext
.crg_g_ftext
.crg_g_fboxtext
* Donc, le Malloc...
	move.w		d1,d4
	Malloc		#te_struc_size
	tst_rts
	move.l		d0,a0
	move.w		#te_struc_size/4,d2
	move.l		d3,a1
* La copie
.loop_reloge_spec_tedinfo
	move.l		(a1)+,(a0)+
	dbf			d2,.loop_reloge_spec_tedinfo
	move.l		d0,a6
* La chaine 1 est toujours la quelque soit le type d'objet...
	move.l		(a6),d3
	bsr			.crg_g_button
	move.l		d3,(a6)

	cmp.w		#G_FTEXT,d4
	bra			.reloge_les_2_autre_chaine
	cmp.w		#G_FBOXTEXT,d4
	beq			.reloge_les_2_autre_chaine
	move.l		a6,d3	; on oubli pas le retour : adresse de la tedinfo
	move.l		d3,d0
	movem.l		(sp)+,d1-d4/a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
.reloge_les_2_autre_chaine
* La chaine 2...
	move.l		te_ptmplt(a6),d3
	bsr			.crg_g_button
	move.l		d3,te_ptmplt(a6)
* ... et La chaine 3 ne sont utilise que pour les G_FBOXTEXT et G_FTEXT
	move.l		te_pvalid(a6),d3
	bsr			.crg_g_button
	move.l		d3,te_pvalid(a6)

	move.l		a6,d3	; en retour : adresse de la tedinfo
	move.l		d3,d0
	movem.l		(sp)+,d1-d4/a6
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 1 chaine -> On reserve 256 octets dans lesquels on place la chaine
.crg_g_string
.crg_g_button
.crg_g_title
	Malloc		#256	; pour moi, une chaine, c'est 256 octet...
	tst_rts
	move.l		d3,a0
	move.l		d0,a1
.boucle_reloge_spec_chaine
	move.b		(a0)+,(a1)+
	bne			.boucle_reloge_spec_chaine
	move.l		d0,d3
	movem.l		(sp)+,d1-d4/a6
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
.crg_g_image
	Malloc		#bi_struc_size		; BITBLK struct
	tst_rts
	move.l		d3,a0
	move.l		d0,a1
	move.w		#bi_struc_size/2,d4
.boucle_reloge_spec_bitblk
	move.w		(a0)+,(a1)+
	dbf			d4,.boucle_reloge_spec_bitblk
	move.l		d0,a0
* On calcul la taille du graphique.
	clr.l		d0
	move.w		bi_wb(a0),d0
	clr.l		d4
	move.w		bi_hl(a0),d4
	xmul		d0,d4
	move.l		a0,-(sp)
	xmalloc		d4		; on reservela taille de celui-ci
	tst_rts
	move.l		(sp)+,a0
	move.l		(a0),a1
	move.l		d0,d1
	move.l		d0,(a0)
	lsr.w		#1,d4
.loop_copy_monocrome_graf
	move.w		(a1)+,(a0)+
	dbf			d4,.loop_copy_monocrome_graf
	move.l		a0,d3
	move.l		d3,d0
	movem.l		(sp)+,d1-d4/a6
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
.crg_g_icon
* On calcul la taille du mask
	move.l		d7,-(sp)
	move.l		d6,-(sp)
	move.l		d3,a0
	clr.l		d6
	move.w		ib_wicon(a0),d6			; (largeur / 8) * hauteur = taille en octet
	lsr.w		#3,d6
	clr.l		d7
	move.w		ib_hicon(a0),d7
	xmul		d7,d6
	move.l		d7,d1
	move.l		d6,d0
	move.l		d0,d4
	move.l		d4,-(sp)

	lsl.l		#1,d0					; taille en octet du mask + data (meme taille que le mask)
	add.l		#ib_struc_size_mono,d0	; + ICONBLK struct
	add.l		#256,d0					; + 256 (pour la taille de la chaine)
	Malloc		d0						; = taille du bloc de l'icone
	tst_rts

* On copie ensuite la structure
	move.l		d3,a0
	move.l		d0,a1
;	move.w		#ib_struc_size_mono,d4	; les instruction en commentaire
;	lsr.w		#1,d4					; realise d4=$11 (David, tu t'es plante ??? t'es sur que
;	subq.w		#1,d4	; dbf rulez		; c'est un RESERVED a la fin ??? Moi en tracan, c'est $10...)
	move.w		#$10,d4
.boucle_reloge_spec_icon
	move.w		(a0)+,(a1)+
	dbf			d4,.boucle_reloge_spec_icon
	move.l		a1,a0
	move.l		d0,a1
	move.l		a0,(a1)			; pointeur sur le mask
	move.l		(sp)+,d4
	move.l		a0,ib_pdata(a1)
	add.l		d4,ib_pdata(a1)	; sur la zone de data
	move.l		a0,ib_ptext(a1)
	add.l		d4,ib_ptext(a1)
	add.l		d4,ib_ptext(a1)	; et sur le texte

	move.l		d3,a1
	move.l		(a1),a1
	move.l		d4,d1
	lsr.l		#1,d1
	subq.l		#1,d1
	cmp.l		#$10000,d1
	bge			.problem_de_dbf
.boucle_copi_le_mask_de_licone
	move.w		(a1)+,(a0)+
	dbf			d1,.boucle_copi_le_mask_de_licone

	move.l		d3,a1
	move.l		ib_pdata(a1),a1
	move.l		d4,d1
	lsr.l		#1,d1
	subq.l		#1,d1
.boucle_copi_le_data_de_licone
	move.w		(a1)+,(a0)+
	dbf			d1,.boucle_copi_le_data_de_licone

	move.l		d3,a1
	move.l		ib_ptext(a1),a1
.boucle_copi_le_text_de_licone
	move.b		(a1)+,(a0)+
	bne			.boucle_copi_le_text_de_licone

	move.l		d0,d3
	move.l		(sp)+,d6
	move.l		(sp)+,d7
	move.l		d3,d0
	movem.l		(sp)+,d1-d4/a6
	rts
.problem_de_dbf
	illegal
	move.l		#-1,d0
	movem.l		(sp)+,d1-d4/a6
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Note : le coeur de la routine est pratiquement le meme que pour un g_icon
* puisque un icone couleur contient un icone monochrome.
.crg_g_cicon
	movem.l		d5-d7/a3,-(sp)
* On calcul la taille du mask
	move.l		d3,a0
	clr.l		d6
	move.w		ib_wicon(a0),d6			; (largeur / 8) * hauteur = taille en octet d'un bloc mono
	lsr.w		#3,d6
	clr.l		d7
	move.w		ib_hicon(a0),d7
	xmul		d7,d6
	move.l		d6,d4	; d6=taille en octet d'un bloc monochrome
	move.l		d6,d0	; d0 contient maintenant la taille totale du bloc (pour l'instant d0=d6)
	lsl.l		#1,d0					; taille en octet du mask + data (meme taille que le mask)

	move.l		ib_resvd(a0),a0
.boucle_calcul_taille_blok
	clr.l		d7
	move.w		num_planes(a0),d7
	addq.w		#1,d7
	move.l		d0,-(sp)
	xmul		d6,d7			; taille (data+mask) = (nombre de plan+1) * taille bloc mono
	move.l		(sp)+,d0
	lsl.l		#1,d7			; selectionne et non selectionne....
	add.l		d7,d0
	add.l		#ciconblk_struc_size,d0	; taille total = taille icone + taille structure CICONBLK
	move.l		next_res(a0),a0
;	beq			.suite_reloge_cicon
	tst.l		a0
	bne			.boucle_calcul_taille_blok

.suite_reloge_cicon
	add.l		#36+256,d0				; + ICONBLK struct + 256 (pour la taille de la chaine)
	xmalloc		d0						; = taille du bloc de l'icone
	tst_rts

* On copie ensuite la structure monochrome de l'icone (structure ICONBLK + icone mono + texte)
	move.l		d3,a0
	move.l		d0,a1
;	move.l		d6,d4
;	move.w		#ib_struc_size_mono,d4	; les instruction en commentaire
;	lsr.w		#1,d4
;	subq.w		#1,d4	; dbf rulez
	move.w		#$10,d4
.2boucle_reloge_spec_icon
	move.w		(a0)+,(a1)+
	dbf			d4,.2boucle_reloge_spec_icon
	move.l		d0,d4
	
	;move.l		a1,(a1)							; le pointeur sur la structure de resol suivante.
	;add.l		#4,(a1)							; ...un peut de code 68030 SVP
	;add.l		d6,(a1)		; *next_res = &next_res + 4 + taille_mask
	;add.l		d6,(a1)		; + taille_data		; heu... ca s'optimise ca non ?
	;add.l		#256,(a1)+	; + taille_chaine
	lea			(a1,260.w,d6.l*2),a3
	move.l		a3,(a1)+
	
;	clr.l		(a1)+
	move.l		d0,a0
	move.l		a1,(a0)			; pointeur sur le mask
	move.l		a1,ib_pdata(a0)
	add.l		d6,ib_pdata(a0)	; sur la zone de data
	move.l		a1,ib_ptext(a0)
	add.l		d6,ib_ptext(a0)
	add.l		d6,ib_ptext(a0)	; et sur le texte

	move.l		(a0),a0			; pointeur sur le mask destination
	move.l		d3,a1
	move.l		(a1),a1			; puis sur le source
	move.l		d6,d1
	lsr.l		#1,d1			; (taille d'un bloc monochrome / 2) - 1
	subq.l		#1,d1
	cmp.l		#$10000,d1
	bge			.problem_de_dbf
.2boucle_copi_le_mask_de_licone
	move.w		(a1)+,(a0)+
	dbf			d1,.2boucle_copi_le_mask_de_licone

	move.l		d3,a1
	move.l		ib_pdata(a1),a1
	move.l		d6,d1
	lsr.l		#1,d1
	subq.l		#1,d1
.2boucle_copi_le_data_de_licone
	move.w		(a1)+,(a0)+
	dbf			d1,.2boucle_copi_le_data_de_licone

	move.l		d3,a1
	move.l		ib_ptext(a1),a1
.2boucle_copi_le_text_de_licone
	move.b		(a1)+,(a0)+
	bne			.2boucle_copi_le_text_de_licone

	move.l		d3,a1
	move.l		ib_resvd(a1),a1	; source
	move.l		d0,a0
	move.l		ib_resvd(a0),a0	; destination

;	movem.l		d0-d2/a0-a2,-(sp)
;	Physbase
;	add.l		#768/4,d0
;	add.l		#768/2*288/2,d0
;	move.l		d0,physical_addr
;	movem.l		(sp)+,d0-d2/a0-a2

.boucle_copi_la_couleur_de_licone
	clr.l		d5
	move.l		a0,d7
	move.w		num_planes(a1),d5
	move.w		d5,(a0)+					; num_planes
	add.l		#ciconblk_struc_size,d7
	move.l		d7,(a0)+					; *col_data = &struct + taille struct
	mulu.w		d6,d5		; calcul de la taille du color_blk
	add.l		d5,d7
	move.l		d7,(a0)+					; *col_mask = &col_data + color_blk
	add.l		d6,d7
	move.l		d7,(a0)+					; *sel_data = &col_mask + mono_blk
	add.l		d5,d7
	move.l		d7,(a0)+					; *sel_mask = &sel_data + color_blk
	add.l		d6,d7
	move.l		a0,a3
	move.l		d7,(a0)+					; *next_res = &sel_mask + mono_blk

	move.l		col_data(a1),a6
	move.l		d5,d0
	lsr.l		#1,d0
	subq.w		#1,d0
.copy_le_data1
	move.w		(a6)+,(a0)+
	dbf			d0,.copy_le_data1

	move.l		col_mask(a1),a6
	move.l		d6,d0
	lsr.l		#1,d0
	subq.w		#1,d0
.copy_le_mask1
	move.w		(a6)+,(a0)+
	dbf			d0,.copy_le_mask1

	move.l		sel_data(a1),a6
	move.l		d5,d0
	lsr.l		#1,d0
	subq.w		#1,d0
.copy_le_data2
	move.w		(a6)+,(a0)+
	dbf			d0,.copy_le_data2

	move.l		sel_mask(a1),a6
	move.l		d6,d0
	lsr.l		#1,d0
	subq.w		#1,d0
.copy_le_mask2
	move.w		(a6)+,(a0)+
	dbf			d0,.copy_le_mask2

	move.l		next_res(a1),a1
	tst.l		a1
	bne			.boucle_copi_la_couleur_de_licone

	clr.l		(a3)	; pas de pointeur vers nouvelle structure (plus de resolution)
	move.l		d4,d3
	movem.l		(sp)+,d5-d7/a3
	move.l		d3,d0
	movem.l		(sp)+,d1-d4/a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
.crg_g_progdef
	illegal
;	Malloc		#applblk_struc_size	; CICONBLK struct
;	tst_rts
;	move.l		d0,d3
	rts
**************************************
* une petite table pour un jmp d0*4...
.table_de_saut		 			; et c'est beaucoup plus rapide !
	dc.l	.crg_g_box
	dc.l	.crg_g_text
	dc.l	.crg_g_boxtext
	dc.l	.crg_g_image
	dc.l	.crg_g_progdef
	dc.l	.crg_g_ibox
	dc.l	.crg_g_button
	dc.l	.crg_g_boxchar
	dc.l	.crg_g_string
	dc.l	.crg_g_ftext
	dc.l	.crg_g_fboxtext
	dc.l	.crg_g_icon
	dc.l	.crg_g_title
	dc.l	.crg_g_cicon

****************************************************************************************
