GWVA_RELOCATE_RSC:	; a0 = adresse du ressource en m‚moire

	cmp.l #0,a0
	ble .erreur_ressource

	tst.w rsh_vrsn(a0)
	beq .old_format
	cmp.w #1,rsh_vrsn(a0)
	beq .old_format
	btst #2,rsh_vrsn+1(a0)
	beq .erreur_ressource

	; New format !

	move.l a0,a1
	add.w rsh_rssize(a0),a1
	move.l 4(a1),d0
	lea (a0,d0.l),a1	; ptr table de ptrs sur les Cicons blk

	move.l a1,a2
	moveq #-1,d0
.count:	addq #1,d0
	tst.l (a2)+
	beq.s .count

	tst d0
	beq .no_cicon
	subq #1,d0

	; a2 pointe sur le premier CICONBLK

	cmp.w #2,GWVA_APP_OBJ_VDI_WORKSTATION+39*2	; nbre de couleur
	beq .pas_besoin_icones_couleurs

	clr.l d4		; taille des icones couleurs … r‚server
	move.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d5	; nbre de plans affich‚s
	clr.l d7		; taille max d'une icone
;
.find_a_good_resolution_for_icons:
	save.l d0/a2

.parse_all_icons1:
	move.l a2,a3
	add.l #L_CICONBLK,a3
	move ib_wicon(a2),d1
	divu #16/2,d1
	mulu ib_hicon(a2),d1		; d1=taille mono en byte
	add.l d1,a3			; data
	add.l d1,a3			; mask
	add #12,a3			; longeur d'un texte

	move.l mainlist(a2),d2		; nb_cicon >=1
	subq.w #1,d2

.parse_all_icones_planes1:
	move.w d1,d3
	mulu num_planes(a3),d3
	move.l a3,a4
	add.l #L_CICON,a4
	add.l d3,a4
	add.l d1,a4

; Icone deja prise en compte ?
	btst #31,d2
	bne.s .icone_resolution_affichable1	; 
	btst #30,d2
	bne.s .icone_resolution_inf1	; 

; Est-ce une icone de la resolution recherch‚e ?
	cmp.w num_planes(a3),d5
	bne.s .saute_icones_couleurs1

; Est-ce une icone directement affichable ?
	move.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d6
	cmp.w num_planes(a3),d6
	beq.s .pas_de_reservation1		; transformation en place si icone de meme r‚solution

; Il faut reserver la place de l'icone
	move d1,d6
	mulu GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d6
	add.l d6,d4
	cmp.l d6,d7
	bge.s .max_taille_icone
	move.l d6,d7
.max_taille_icone:

	bset #30-24,mainlist(a2)
	bra.s .icone_resolution_inf1

.pas_de_reservation1:
	bset #31-24,mainlist(a2)
	bra.s .icone_resolution_affichable1

.saute_icones_couleurs1:
.icone_resolution_inf1:
.icone_resolution_affichable1:

	tst.l sel_data(a3)
	beq.s .pas_d_icon_selct1

	add.l d3,a4
	add.l d1,a4

	btst #31,d2
	bne.s .icone_resolution_affichable2	; 
	btst #30,d2
	bne.s .icone_resolution_inf2	; 

	cmp.w num_planes(a3),d5
	bne.s .saute_icones_couleurs2

	move.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d6
	cmp.w num_planes(a3),d6
	beq.s .pas_de_reservation2		; transformation en place si icone de meme r‚solution

	move d1,d6
	mulu GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d6
	add.l d6,d4

.pas_de_reservation2:
.saute_icones_couleurs2:
.icone_resolution_inf2:
.icone_resolution_affichable2:

.pas_d_icon_selct1:

	move.l a4,a3
	dbf d2,.parse_all_icones_planes1

	move.l a3,a2

	dbf d0,.parse_all_icons1

	load.l d0/a2

	lsr.w #1,d5		; 8 -> 4 -> 2 -> 1 plans ...
	tst d5
	bne .find_a_good_resolution_for_icons

	clr.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN
	clr.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN+4

	tst.l d4		; reservation memoire ?
	beq.s .pas_de_malloc

	save.l d0/a0-a2
	save.l d7
	MXALLOC #RAM_TT_ST,d4
	move.l d0,GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN
	load.l d7
	add.l d7,d7		; pour la selection eventuelle
	MXALLOC #RAM_TT_ST,d7
	move.l d0,GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN+4
	load.l d0/a0-a2
.pas_de_malloc:

	; a2 pointe sur le premier CICONBLK

.pas_besoin_icones_couleurs:

	move.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN,d4

.parse_all_icons2:
	move.l a2,(a1)+

	move.l a2,a3
	add.l #L_CICONBLK,a3
	move.l a3,ib_pdata(a2)
	move ib_wicon(a2),d1
	divu #16/2,d1
	mulu ib_hicon(a2),d1		; d1=taille mono en byte
	add.l d1,a3
	move.l a3,ib_pmask(a2)
	add.l d1,a3
	move.l a3,ib_ptext(a2)
	add #12,a3			; longeur d'un texte
	
	move.l mainlist(a2),d2		; nb_cicon
	clr.l mainlist(a2)

	subq #1,d2

	cmp.w #2,GWVA_APP_OBJ_VDI_WORKSTATION+13*2	; monochrome ?
	beq.s .pas_besoin_icones_couleurs2

	move.l a3,mainlist(a2)

.pas_besoin_icones_couleurs2:

.parse_all_icones_planes:

	move d1,d3
	mulu num_planes(a3),d3
	move.l a3,a4
	add.l #L_CICON,a4
	move.l a4,col_data(a3)
	add.l d3,a4
	move.l a4,col_mask(a3)
	add.l d1,a4

	btst #31,d2
	bne.s .icone_resolution_affichable3	; 

	btst #30,d2
	beq.s .pas_cette_resolution	;

	move.l col_data(a3),a5
	move.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN+4,d7
	bsr .cree_resolution_icone

	move.l d4,col_data(a3)
	move d1,d5
	mulu GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d5
	add.l d5,d4
	add.l d5,d7

	bra.s .icone_resolution_affichable3

.pas_cette_resolution:
	clr.l mainlist(a2)

.icone_resolution_affichable3:

	tst.l sel_data(a3)
	beq.s .pas_d_icon_selct2

	move.l a4,sel_data(a3)
	add.l d3,a4
	move.l a4,sel_mask(a3)
	add.l d1,a4

	btst #31,d2
	bne.s .icone_resolution_affichable4	; 

	btst #30,d2
	beq.s .pas_cette_resolution2	;

	move.l sel_data(a3),a5
	bsr .cree_resolution_icone

	move.l d4,sel_data(a3)
	move d1,d5
	mulu GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d5
	add.l d5,d4

.icone_resolution_affichable4:
.pas_cette_resolution2:

.pas_d_icon_selct2:
	save.l d4

	move.l col_data(a3),d4			; source

	btst #31,d2
	bne.s .icone_resolution_affichable5	; 

	btst #30,d2
	beq.s .pas_cette_resolution3	;

	move.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,num_planes(a3)

	move.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN+4,d4	; source

.icone_resolution_affichable5:

	move.l col_data(a3),d5			; destination
	bsr .remets_plans_entrelaces_en_place

.pas_cette_resolution3:

	load.l d4

	tst.l sel_data(a3)
	beq.s .pas_d_icon_selct3

	save.l d4

	move.l sel_data(a3),d4			; source

	btst #31,d2
	bne.s .icone_resolution_affichable6	;

	btst #30,d2
	beq.s .pas_cette_resolution4	;

	move.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN+4,d4
	move d1,d5
	mulu GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d5
	add.l d5,d4				; source

.icone_resolution_affichable6:

	move.l sel_data(a3),d5			; destination
	bsr .remets_plans_entrelaces_en_place

.pas_cette_resolution4:

	load.l d4

.pas_d_icon_selct3:
	cmp.l #1,next_res(a3)
	bne.s .no_more_res

	move.l a4,next_res(a3)
.no_more_res:
	move.l a4,a3
	dbf d2,.parse_all_icones_planes

.pas_icones_couleurs:

	move.l a3,a2

	dbf d0,.parse_all_icons2

	tst.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN+4
	beq.s .pas_buffer_temp
	save.l a0
	MFREE GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN+4
	load.l a0
	clr.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN+4
.pas_buffer_temp:

.no_cicon:
.old_format:
	; fin du traitement des icones couleur, ouf !

	move.w #rsh_frstr,d1
	move rsh_nstring(a0),d0
	bsr .reloc_array
	move.w #rsh_frimg,d1
	move rsh_nimages(a0),d0
	bsr .reloc_array
	move.w #rsh_trindex,d1
	move rsh_ntree(a0),d0
	bsr .reloc_array

	; reloc la table des teds_info
	move.l a0,a1
	move.l a0,d7
	add.w rsh_tedinfo(a0),a1
	move rsh_nted(a0),d0
	subq #1,d0
	bmi.s .nothing1
.reloc_ptrs_ted:
	add.l d7,te_ptext(a1)
	add.l d7,te_ptmplt(a1)
	add.l d7,te_pvalid(a1)
	lea L_TEDINFO(a1),a1
	dbf d0,.reloc_ptrs_ted
.nothing1:
	; reloc la table des icon_blk
	move.l a0,a1
	move.l a0,d7
	add.w rsh_iconblk(a0),a1
	move rsh_nib(a0),d0
	subq #1,d0
	bmi.s .nothing2
.reloc_ptrs_iconblk:
	add.l d7,ib_pmask(a1)
	add.l d7,ib_pdata(a1)
	add.l d7,ib_ptext(a1)
	lea L_ICONBLK(a1),a1
	dbf d0,.reloc_ptrs_iconblk
.nothing2:
	; reloc la table des bit_blk
	move.l a0,a1
	move.l a0,d7
	add.w rsh_bitblk(a0),a1
	move rsh_nbb(a0),d0
	subq #1,d0
	bmi.s .nothing3
.reloc_ptrs_bitblk:
	add.l d7,bi_pdata(a1)
	lea L_BITBLK(a1),a1
	dbf d0,.reloc_ptrs_bitblk
.nothing3:
	; reloc la table des cicon_blk

	; parse tous les objets
	move rsh_ntree(a0),d0
	subq #1,d0
	bmi .nothing4

	move.l a0,a1
	move.l a0,d7
	add.w rsh_trindex(a0),a1

.parse_all_trees:
	move.l (a1)+,a2

	move #1-1,d1
	tst ob_tail(a2)
	bmi.s .pas_de_fils
	move ob_tail(a2),d1	; +1 pour le pŠre -1 pour dbf
.pas_de_fils:

	clr d2		; No objet = pere
.parse_all_this_tree:		; -4(a1) =ptr tree a2=ptr object

	move.w ob_type(a2),d3
	and.w #$ff,d3

	cmp.w #G_TEXT,d3
	beq.s .reloc_ted
	cmp.w #G_BOXTEXT,d3
	beq.s .reloc_ted
	cmp.w #G_FTEXT,d3
	beq.s .reloc_ted
	cmp.w #G_FBOXTEXT,d3
	bne.s .no_reloc_ted

.reloc_ted:	add.l d7,ob_spec(a2)

.no_reloc_ted:

	cmp.w #G_IMAGE,d3
	beq.s .reloc_classique
	cmp.w #G_BUTTON,d3
	beq.s .reloc_classique
	cmp.w #G_STRING,d3
	beq.s .reloc_classique
	cmp.w #G_ICON,d3
	beq.s .reloc_classique
	cmp.w #G_TITLE,d3
	beq.s .reloc_classique
	cmp.w #G_CICON,d3
	bne.s .reloc_done

	move.l ob_spec(a2),d4
	lsl.l #2,d4
	move.l a0,a3
	add.w rsh_rssize(a0),a3
	lea ([4,a3],a0.l),a3	; ptr table de ptrs sur les Cicons blk
	move.l (a3,d4.l),ob_spec(a2)
	bra.s .reloc_done

.reloc_classique:
	add.l d7,ob_spec(a2)

.reloc_done:
.pas_reloc_struct:

	save.l d0-d2/d7/a0-a2
	rsrc_obfix -4(a1),d2	; caractŠre -> pixel
	load.l d0-d2/d7/a0-a2

	move.w ob_head(a2),d3
	bmi.s .pas_de_fils2

	move.w d3,d2
	mulu #L_OBJECT,d3
	add.l -4(a1),d3
	move.l d3,a2
	bra.s .next_object

.pas_de_fils2:
.next_is_dad:
	move.w d2,d3		; objet courant

	move.w ob_next(a2),d2
	ble.s .pas_de_frere_pere	; -> le suivant est le root ou le root est tout seul

	move.w d2,d4
	mulu #L_OBJECT,d4
	add.l -4(a1),d4
	move.l d4,a2
	cmp.w ob_tail(a2),d3
	beq.s .next_is_dad

.next_object:
	bra .parse_all_this_tree
.pas_de_frere_pere:

	dbf d0,.parse_all_trees
.nothing4:
	move.l a0,a1
	add.w #L_RSC_HEADER,a1
	move.l a1,global+_AESrscfile
	move.l a0,global+_AESrscfile+4
	move.w rsh_rssize(a0),global+_AESrscfile+4+4

	btst #2,rsh_vrsn+1(a0)
	beq.s .old_rsc2

	move.l a0,a1
	add.w rsh_rssize(a0),a1
	move.w 2(a1),global+_AESrscfile+4+4
.old_rsc2:
	clr d7
	rts

.cree_resolution_icone:
	move.l d7,a6
	move.l d3,d6
	lsr.l #1,d6
.recopie_icone:
	move.w (a5)+,(a6)+
	subq.l #1,d6
	bne.s .recopie_icone

	save.w d0
	move.l d7,a5
	move.w d1,d6
	sub.w #1,d6
.cree_plans_icone:
	move.l a5,a6
	move.w (a5)+,d5
	move.w num_planes(a3),d0
	subq.w #1,d0
.and_plans:	and.w (a6),d5
	lea (a6,d1.w),a6
	dbf d0,.and_plans

	move.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d0
	sub.w num_planes(a3),d0		; on doit ajoutter des plans vides
	subq.w #1,d0
.move_plans:move d5,(a6)
	lea (a6,d1.w),a6
	dbf d0,.move_plans

	dbf d6,.cree_plans_icone
	load.w d0
	rts

.remets_plans_entrelaces_en_place:
	lea GWVA_APP_MFDB_SRC,a5
	move.l d4,(a5)+		; pointeur image
	move.l ib_wicon(a2),(a5)+	; largeur/hauteur image pixel
	move.w ib_wicon(a2),d6
	add.w #15,d6
	ext.l d6
	divu #16,d6
	move.w d6,(a5)+		; largeur image en mots
	move.w #1,(a5)+		; device independent
	move.w num_planes(a3),(a5)+
	clr.w (a5)+			; reserv‚s
	clr.w (a5)+
	clr.w (a5)+

	lea GWVA_APP_MFDB_DEST,a5
	move.l d5,(a5)+		; pointeur image
	move.l ib_wicon(a2),(a5)+	; largeur/hauteur image pixel
	move.w ib_wicon(a2),d6
	add.w #15,d6
	ext.l d6
	divu #16,d6
	move.w d6,(a5)+		; largeur image en mots
	move.w #0,(a5)+		; device dependent
	move.w num_planes(a3),(a5)+
	clr.w (a5)+			; reserv‚s
	clr.w (a5)+
	clr.w (a5)+

	save.l d0-d3/a0-a4
	vr_trnfm #GWVA_APP_MFDB_SRC,#GWVA_APP_MFDB_DEST
	load.l d0-d3/a0-a4
	rts

.reloc_array:
	move.l a0,a1
	move.l a0,d7
	add.w (a0,d1.w),a1
	subq #1,d0
	bmi.s .nothing
.reloc_array2:
	add.l d7,(a1)+
	dbf d0,.reloc_array2
.nothing:	rts

.erreur_ressource:
	moveq #GWVA_ERROR_GENERIC,d7
	rts
