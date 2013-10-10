*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
.crg_g_icon
* On calcul la taille du mask
	move.l		d7,-(sp)
	move.l		d6,-(sp)
	move.l		a1,-(sp)
	move.l		d4,-(sp)
	move.l		d5,-(sp)

;* Realocation de la structure
	move.l		#ib_struc_size_mono,d7
	xaloc_aloc	d7,d2
	move.l		d0,a0
	move.l		d0,d5	; adresse de base de la structure de l'objet

	move.l		d3,a1
	lsr.w		#1,d7
	subq.w		#1,d7
.boucle_g_icon_struc
	move.l		(a1)+,(a0)+
	dbf		d7,.boucle_g_icon_struc

	move.l		d3,a0
	clr.l		d6
	move.w		ib_wicon(a0),d6			; (largeur / 8) * hauteur = taille en octet
	lsr.w		#3,d6
	clr.l		d7
	move.w		ib_hicon(a0),d7
	mulu.l		d7,d6
	move.l		d7,d1
	move.l		d6,d0
	move.l		d0,d4			; d0 = taille du plan de bit

;* Realocation du mask
	xaloc_aloc	d0,d5
	move.l		d0,a0

	move.l		d3,a1
	move.l		(a1),a1
	move.l		d4,d1
	lsr.l		#1,d1
.boucle_copi_le_mask_de_licone
	move.w		(a1)+,(a0)+
	subq.l		#1,d1
	bne		.boucle_copi_le_mask_de_licone
	move.l		d3,a1
	move.l		d0,(a1)

;* Realocation du data
	move.l		d5,d1
	add.l		#ib_pdata,d1
	xaloc_aloc	d0,d1
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

	move.l		d5,d0
	move.l		(sp)+,d5
	move.l		(sp)+,d4
	move.l		(sp)+,a1
	move.l		(sp)+,d6
	move.l		(sp)+,d7
	movem.l		(sp)+,d1-d4/a6
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Note : le coeur de la routine est pratiquement le meme que pour un g_icon
* puisque un icone couleur contient un icone monochrome.
.crg_g_cicon
;	move.l		d3,d0
;	movem.l		(sp)+,d1-d4/a6
;	rts
	illegal
	movem.l		d5-d7/a3,-(sp)
* On calcul la taille du mask
	move.l		d3,a0
	move.l		#ib_struc_size_color,d7
	move.l		d7,d5
	xaloc_aloc	d7,d2
	move.l		d0,a6
	move.l		d0,a1
	lsr.w		#1,d7
	subq.w		#1,d7
.g_cicon_struc_copy
	move.l		(a0)+,a1
	dbf		d7,.g_cicon_struc_copy

	clr.l		d6
	move.w		ib_wicon(a6),d6			; (largeur / 8) * hauteur = taille en octet d'un bloc mono
	lsr.w		#3,d6
	clr.l		d7
	move.w		ib_hicon(a6),d7
	mulu.l		d7,d6
	move.l		d6,d4	; d6=taille en octet d'un bloc monochrome

	xaloc_aloc	d6,a6
	move.l		d0,a1




	move.l		ib_resvd(a0),a0
.boucle_calcul_taille_blok
	clr.l		d7
	move.w		num_planes(a0),d7
	addq.w		#1,d7
	mulu.l		d6,d7			; taille (data+mask) = (nombre de plan+1) * taille bloc mono
	lsl.l		#1,d7			; selectionne et non selectionne....
	add.l		d7,d0
	add.l		#ciconblk_struc_size,d0	; taille total = taille icone + taille structure CICONBLK
	move.l		next_res(a0),a0
;	beq		.suite_reloge_cicon
	tst.l		a0
	bne		.boucle_calcul_taille_blok

.suite_reloge_cicon
	add.l		#36+256,d0				; + ICONBLK struct + 256 (pour la taille de la chaine)
	xaloc_aloc	d0,d2

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
	dbf		d4,.2boucle_reloge_spec_icon
	move.l		d0,d4
	
	move.l		a1,(a1)		; le pointeur sur la structure de resol suivante.
	add.l		#4,(a1)		; ...un peut de code 68030 SVP
	add.l		d6,(a1)		; *next_res = &next_res + 4 + taille_mask
	add.l		d6,(a1)		; + taille_data		; heu... ca s'optimise ca non ?
	add.l		#256,(a1)+	; + taille_chaine
	;lea		(a1,260.w,d6.l*2),a3
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
.2boucle_copi_le_mask_de_licone
	move.w		(a1)+,(a0)+
	subq.l		#1,d1
	bne		.2boucle_copi_le_mask_de_licone

	move.l		d3,a1
	move.l		ib_pdata(a1),a1
	move.l		d6,d1
	lsr.l		#1,d1
.2boucle_copi_le_data_de_licone
	move.w		(a1)+,(a0)+
	subq.l		#1,d1
	bne		.2boucle_copi_le_data_de_licone

	move.l		d3,a1
	move.l		ib_ptext(a1),a1
.2boucle_copi_le_text_de_licone
	move.b		(a1)+,(a0)+
	bne		.2boucle_copi_le_text_de_licone

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
	tst.l		sel_data(a1)
	beq		.no_animated_icone
	move.l		d7,(a0)+					; *sel_data = &col_mask + mono_blk
	add.l		d5,d7
	move.l		d7,(a0)+					; *sel_mask = &sel_data + color_blk
	add.l		d6,d7
	bra		.end_reloge_selected_pointer
.no_animated_icone
	clr.l		(a0)+
	clr.l		(a0)+
.end_reloge_selected_pointer
	move.l		a0,a3
	move.l		d7,(a0)+					; *next_res = &sel_mask + mono_blk

	move.l		col_data(a1),a6
	move.l		d5,d0
	lsr.l		#1,d0
.copy_le_data1
	move.w		(a6)+,(a0)+
	subq.l		#1,d0
	bne		.copy_le_data1

	move.l		col_mask(a1),a6
	move.l		d6,d0
	lsr.l		#1,d0
.copy_le_mask1
	move.w		(a6)+,(a0)+
	subq.l		#1,d0
	bne		.copy_le_mask1

	tst.l		sel_data(a1)
	beq		.pas_dicone_de_selection
	move.l		sel_data(a1),a6
	move.l		d5,d0
	lsr.l		#1,d0
.copy_le_data2
	move.w		(a6)+,(a0)+
	subq.l		#1,d0
	bne		.copy_le_data2

	move.l		sel_mask(a1),a6
	move.l		d6,d0
	lsr.l		#1,d0
.copy_le_mask2
	move.w		(a6)+,(a0)+
	subq.l		#1,d0
	bne		.copy_le_mask2

.pas_dicone_de_selection
	move.l		next_res(a1),a1
	tst.l		a1
	bne		.boucle_copi_la_couleur_de_licone

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
