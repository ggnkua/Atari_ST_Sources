	include	structs.s
	include	gemdos.i
	include	vdi.i
*Si debugage
	include	zlib.i

	include	..\memory.s

	XREF	planes,contrl


	XDEF	save_dolmen_format
save_dolmen_format
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	56+0(sp),a6				; a6 = adresse du ressource en memoire

	Malloc	#500000
	tst.l	d0
	bne	.suite1

	moveq.l	#0,d0
	movem.l	(sp)+,d1-d7/a1-a6
	rts
.suite1
	move.l	d0,a5

*Si debugage
	clr_zone	a5,#500000
*--------------------------------------------------------------------------------------------------------------------------*
* On rempli le debut du header
	move.l	#"DLMN",nrsh_id(a5)
	move.l	#"RSRC",nrsh_id+4(a5)		; identificateur
	move.l	#$10000,nrsh_vrsn(a5)		; numero de version
	move.l	#sizeof_nrsh,nrsh_hdlen(a5)	; taille du header
	move.l	mrsc_ptrnbr(a6),d7
	move.l	d7,nrsh_ntree(a5)		; nombre d'arbre

	lea	sizeof_nrsh(a5),a4
	move.l	a4,nrsh_objs(a5)		; adresse du premier objet

*--------------------------------------------------------------------------------------------------------------------------*
* On copie tous les objets Q a Q en remplissant la table de pointeur sur arbre
	lea	tree_ptr,a3
	lea	mrsc_ptr(a6),a2		; init de la boucle
	move.l	d7,d6
	move.l	#0,a0
cp_arbre
	move.l	(a2)+,a1			; trouve l'arbre suivant

	move.l	mtree_type(a1),rptb_ptr(a3)	; rempli la table d'arbre
	move.l	a4,rptb_ptr(a3)
	lea	sizeof_rptb(a3),a3

	lea	mtree_objets(a1),a1
.cp_objs
	lea	24(a4),a4
	movem.l	(a1)+,d0-d5
	movem.l	d0-d5,-(a4)			; Copie un objet dans le ressource
	lea	24(a4),a4
	addq.l	#1,a0
	btst	#LASTOB,((ob_flags+1)-24)(a4)
	beq	.cp_objs	; fin arbre ?

	subq.l	#1,d6
	bne	cp_arbre
	move.l	a0,nrsh_nobj(a5)

*--------------------------------------------------------------------------------------------------------------------------*
* On copie la table de pointeur sur arbre a la suite
	move.l	a4,nrsh_treetbl(a5)		; update le header
	lea	tree_ptr,a3
	move.l	d7,d6

cp_ptr_arbre

	move.w	#(sizeof_rptb/2)-1,d5
.cp_un_ptr
	move.w	(a3)+,(a4)+
	dbf	d5,.cp_un_ptr

	subq.l	#1,d6
	bne	cp_ptr_arbre

*--------------------------------------------------------------------------------------------------------------------------*
* On place toutes les structures pointes grace au bit indirect dans le fichier
	move.l	a4,nrsh_label(a5)
	move.l	a0,d7	; nombre d'objet
	move.l	nrsh_objs(a5),a6
cp_indirected
	btst	#INDIRECT-8,ob_flags(a6)
	beq	.not_indirected

	lea	ob_spec(a6),a3
	move.l	(a3),ob_spec(a6)	; on vire l'indirection
	bclr	#INDIRECT-8,ob_flags(a6)






.not_indirected
	lea	24(a6),a6
	subq.l	#1,d7
	bne	cp_indirected

*--------------------------------------------------------------------------------------------------------------------------*
* On copie les structures de l'obspec a la suite, le bit indirect ayant disparu puisque sauve
	move.l	nrsh_nobj(a5),d7	; nombre d'objet
	move.l	nrsh_objs(a5),a6
next_obj
	move.l	ob_spec(a6),a3
.not_indirected
	moveq.l	#0,d0
	move.b	ob_type+1(a6),d0	; L'ob_type, non etendu, donne l'index dans la table de saut
	sub.w	#20,d0			; la table commence a partir de l'objet #20
	jmp	([table_type_copy.w,pc,d0.w*4])

	*----------------*
cp_g_title
cp_g_string
cp_g_button
	move.l	a4,ob_spec(a6)
.cp_txt
	move.b	(a3)+,(a4)+
	bne	.cp_txt

	move.l	a4,d0
	addq.l	#3,d0
	and.b	#$fc,d0
	move.l	d0,a4

	bra	end_cp_obj

	*----------------*
cp_g_text
cp_g_boxtext
cp_g_ftext
cp_g_fboxtext
	move.l	a4,ob_spec(a6)
	move.l	a4,a2
* Copie de la structure tedinfo
	move.w	#(te_struc_size/2)-1,d1
.cp_tedinfo_struc
	move.w	(a3)+,(a4)+
	dbf	d1,.cp_tedinfo_struc
* Copie du p_text
	move.l	(a2),a1
	move.l	a4,(a2)
.cp_ptext
	move.b	(a1)+,(a4)+
	bne	.cp_ptext

	move.l	a4,d0
	addq.l	#3,d0
	and.b	#$fc,d0
	move.l	d0,a4

* Si boxtext ou text (cad non editable) alors on a fini
	cmp.b	#G_TEXT,ob_type+1(a6)
	beq	end_cp_obj
	cmp.b	#G_BOXTEXT,ob_type+1(a6)
	beq	end_cp_obj

* Copie du ptmplt
	move.l	te_ptmplt(a2),a1
	move.l	a4,te_ptmplt(a2)
.cp_ptmplt
	move.b	(a1)+,(a4)+
	bne	.cp_ptmplt

	move.l	a4,d0
	addq.l	#3,d0
	and.b	#$fc,d0
	move.l	d0,a4

* Copie du pvalid
	move.l	te_pvalid(a2),a1
	move.l	a4,te_pvalid(a2)
.cp_pvalid
	move.b	(a1)+,(a4)+
	bne	.cp_pvalid

	move.l	a4,d0
	addq.l	#3,d0
	and.b	#$fc,d0
	move.l	d0,a4

	bra	end_cp_obj

	*----------------*
cp_g_image
	move.l	a4,ob_spec(a6)
	move.l	a4,a2
* Copie de la structure bi
	move.w	#(bi_struc_size/2)-1,d1
.cp_bi_struc
	move.w	(a3)+,(a4)+
	dbf	d1,.cp_bi_struc

	moveq.l	#0,d5
	moveq.l	#0,d6				; Calcul la taille de l'image
	move.w	bi_wb(a2),d5			; largeur en word * hauteur = taille en octet = d6
	move.w	bi_hl(a2),d6
	mulu.l	d5,d6

	lsr.l	#1,d6	; on deplace 2 byte en meme temps
	move.l	d6,d5

	move.l	bi_pdata(a2),a1		; le pointeur de bitmap
	move.l	a4,bi_pdata(a2)

.cp_datas
	move.w	(a1)+,(a4)+
	subq.l	#1,d5
	bne	.cp_datas

	bra	end_cp_obj
	*----------------*
cp_g_icon
	move.l	a4,ob_spec(a6)
	move.l	a4,a2
* Copie de la structure bi
	move.w	#(ib_struc_size_mono/2)-1,d1
.cp_ib_struc
	move.w	(a3)+,(a4)+
	dbf	d1,.cp_ib_struc

* Calcul de la taille d'un plan de bitmap
	moveq.l	#0,d0
	move.w	ib_wicon(a2),d0
	mulu.w	ib_hicon(a2),d0
	lsr.l	#4,d0
	move.l	d0,d6	; compteur a conserver pour boucle suivante...
	move.l	d0,d5

* Copie du masque
	move.l	ib_pmask(a2),a1
	move.l	a4,ib_pmask(a2)
.cp_mask
	move.w	(a1)+,(a4)+
	subq.l	#1,d5
	bne	.cp_mask

* Copie du data
	move.l	d6,d5
	move.l	ib_pdata(a2),a1
	move.l	a4,ib_pdata(a2)
.cp_data
	move.w	(a1)+,(a4)+
	subq.l	#1,d5
	bne	.cp_data

* Copie du texte
	move.l	ib_ptext(a2),a1
	move.l	a4,ib_ptext(a2)
.cp_text
	move.w	(a1)+,(a4)+
	bne	.cp_text

	move.l	a4,d0
	addq.l	#3,d0
	and.b	#$fc,d0
	move.l	d0,a4

	bra	end_cp_obj
	*----------------*
cp_g_cicon
	move.l	a4,ob_spec(a6)
	move.l	a4,a2
* Copie de la structure bi
	move.w	#(ib_struc_size_color/2)-1,d1
.cp_ib_struc
	move.w	(a3)+,(a4)+
	dbf	d1,.cp_ib_struc

	move.l	a2,a3
* Calcul de la taille d'un plan de bitmap
	moveq.l	#0,d0
	move.w	ib_wicon(a2),d0
	mulu.w	ib_hicon(a2),d0
	lsr.l	#4,d0
	move.l	d0,d6	; compteur a conserver pour boucle suivante...
	move.l	d0,d5

* Copie du masque
	move.l	ib_pmask(a2),a1
	move.l	a4,ib_pmask(a2)
.cp_maskicon
	move.w	(a1)+,(a4)+
	subq.l	#1,d5
	bne	.cp_maskicon

* Copie du data
	move.l	d6,d5
	move.l	ib_pdata(a2),a1
	move.l	a4,ib_pdata(a2)
.cp_data
	move.w	(a1)+,(a4)+
	subq.l	#1,d5
	bne	.cp_data

* Copie du texte
	move.l	ib_ptext(a2),a1
	move.l	a4,ib_ptext(a2)
.cp_text
	move.w	(a1)+,(a4)+
	bne	.cp_text

	move.l	a4,d0
	addq.l	#3,d0
	and.b	#$fc,d0
	move.l	d0,a4

* On attaque la partie couleur
;* On commence par chercher la resol correspondant a l'affichage
	move.l	ib_resvd(a2),a1
	tst.l	a1
	beq	.no_color

	move.l	next_res(a1),a1

	move.l	a4,ib_resvd(a2)
.cp_icon_res
* Copi de la structure couleur
	move.w	#(ciconblk_struc_size/2)-1,d0
	move.l	a4,a2
.cp_strucol
	move.w	(a1)+,(a4)+
	dbf	d0,.cp_strucol

* Sans transformation
	move.l	d6,d4
	mulu.w	num_planes(a2),d4
	move.l	col_data(a2),a1
	move.l	a4,col_data(a2)
.cp_datas
	move.w	(a1)+,(a4)+
	sub.l	#1,d4
	bne	.cp_datas

* Copie le masque
	move.l	d6,d4
	move.l	col_mask(a2),a1
	move.l	a4,col_mask(a2)
.cp_mask
	move.W	(a1)+,(a4)+
	sub.l	#1,d4
	bne	.cp_mask

;* Copie la partie icone selectionne, data
;	cmp.w	num_planes(a2),d5
;	beq	.transform_slect

* Quand pas de transformation
	move.l	d6,d4
	mulu.w	num_planes(a2),d4
	move.l	sel_data(a2),a1
	move.l	a4,sel_data(a2)
.cp_sels
	move.w	(a1)+,(a4)+
	sub.l	#1,d4
	bne	.cp_sels

	move.l	next_res(a2),a1
	tst.l	a1
	beq	.no_color
	move.l	a4,next_res(a2)
	bra	.cp_icon_res

.no_color
	bra	end_cp_obj
	*----------------*
cp_g_pix
	move.l	a4,ob_spec(a6)
	move.l	a4,a2

	move.l	gpix_path(a3),(a4)
	clr.l	gpix_list(a4)
	clr.l	gpix_ptr(a4)
	move.l	gpix_x(a3),gpix_x(a4)
	move.l	gpix_y(a3),gpix_y(a4)
	move.l	gpix_flags(a3),d0
	or.w	#1,d0
	move.l	d0,gpix_flags(a4)

	lea	sizeof_gpix(a4),a4

	move.l	(a2),a3		; puis le chemin de la g_pix
	move.l	a4,(a2)
.find_path_end
	tst.b	(a3)+
	bne	.find_path_end

.find_file_name
	cmp.b	#"\",-(a3)
	beq	.dos

	cmp.b	#"/",(a3)
	beq	.unix

	bra	.find_file_name

.dos
	move.b	#"P",(a4)+
	move.b	#"I",(a4)+
	move.b	#"X",(a4)+
	move.b	#"\",(a4)+
	bra	.addpath_ok

.unix
	move.b	#"p",(a4)+
	move.b	#"i",(a4)+
	move.b	#"x",(a4)+
	move.b	#"/",(a4)+

.addpath_ok
	addq.l	#1,a3

.gpix_cp_path
	move.b	(a3)+,(a4)+
	bne	.gpix_cp_path

	move.l	a4,d0
	addq.l	#3,d0
	and.b	#$fc,d0
	move.l	d0,a4

	bra	end_cp_obj
	*----------------*
cp_g_progdef
cp_g_boxchar
cp_g_ibox
cp_g_box
cp_g_line

end_cp_obj
	lea	24(a6),a6
	subq.l	#1,d7
	bne	next_obj
	bra	objc_copied
table_type_copy
	dc.l	cp_g_box
	dc.l	cp_g_text
	dc.l	cp_g_boxtext
	dc.l	cp_g_image
	dc.l	cp_g_progdef
	dc.l	cp_g_ibox
	dc.l	cp_g_button
	dc.l	cp_g_boxchar
	dc.l	cp_g_string
	dc.l	cp_g_ftext
	dc.l	cp_g_fboxtext
	dc.l	cp_g_icon
	dc.l	cp_g_title
	dc.l	cp_g_cicon
	dc.l	0	cp_g_bounding
	dc.l	0	cp_g_bounded
	dc.l	cp_g_pix
	dc.l	cp_g_line
	dc.l	0	cp_g_check
*--------------------------------------------------------------------------------------------------------------------------*
reloc_adr	macro	; adr
	move.l	\1,d0
	sub.l	d5,d0
	move.l	d0,(a4)+
	move.l	(\1),d0
	sub.l	d5,d0
	move.l	d0,(\1)
	endm


table_type_reloc
	dc.l	reloc_g_box
	dc.l	reloc_g_text
	dc.l	reloc_g_boxtext
	dc.l	reloc_g_image
	dc.l	reloc_g_progdef
	dc.l	reloc_g_ibox
	dc.l	reloc_g_button
	dc.l	reloc_g_boxchar
	dc.l	reloc_g_string
	dc.l	reloc_g_ftext
	dc.l	reloc_g_fboxtext
	dc.l	reloc_g_icon
	dc.l	reloc_g_title
	dc.l	reloc_g_cicon
	dc.l	0	reloc_g_bounding
	dc.l	0	reloc_g_bounded
	dc.l	reloc_g_pix
	dc.l	reloc_g_line
	dc.l	0	reloc_g_check

objc_copied
* Avant de reloger on place la partie specifique a l'editeur de resource (pour l'instant vide)
	move.l	a4,nrsh_rsced(a5)
	move.l	#"FASH",nrsh_edtype(a5)

* Fabrique la table de relocation en relogeant le ressource
	move.l	nrsh_nobj(a5),d7	; nombre d'objet

* On commence par reloger les objets du ressource
	move.l	a5,d5
	move.l	nrsh_objs(a5),a6
	move.l	a4,nrsh_reloc(a5)
	sub.l	d5,nrsh_reloc(a5)
	moveq.l	#0,d6			; compteur d'adresse relogee
relocobj_loop
	moveq.l	#0,d0
	lea	ob_spec(a6),a3
	move.b	ob_type+1(a6),d0
	sub.w	#20,d0
	jmp	([table_type_reloc.w,pc,d0.w*4])

reloc_g_button
reloc_g_string
reloc_g_title
	addq.l		#1,d6
	reloc_adr	a3
	bra		end_reloc_obj
	*---------------*
reloc_g_text
reloc_g_boxtext
	addq.l		#2,d6
	move.l		a3,a2
	reloc_adr	a2
	reloc_adr	a3
	bra		end_reloc_obj
	*---------------*
reloc_g_ftext
reloc_g_fboxtext
	addq.l		#4,d6
	move.l		a3,a2
	lea		4(a2),a1
	lea		8(a2),a0
	reloc_adr	a0
	reloc_adr	a1
	reloc_adr	a2
	reloc_adr	a3
	bra		end_reloc_obj
	*---------------*
reloc_g_image
	addq.l		#2,d6
	move.l		(a3),a2
	reloc_adr	a3
	reloc_adr	a2
	bra		end_reloc_obj
	*---------------*
reloc_g_icon
	addq.l		#4,d6
	move.l		(a3),a2
	lea		4(a2),a1
	lea		8(a2),a0
	reloc_adr	a3
	reloc_adr	a2
	reloc_adr	a1
	reloc_adr	a0
	bra		end_reloc_obj
	*---------------*
reloc_g_cicon
	addq.l		#4,d6
	move.l		(a3),a2
	lea		4(a2),a1
	lea		8(a2),a0
	reloc_adr	a3
	reloc_adr	a2
	reloc_adr	a1
	reloc_adr	a0
	move.l		ib_resvd(a2),a1
	tst.l		a1
	beq		.end_reloc_cicon
	lea		ib_resvd(a2),a0
	reloc_adr	a0
	addq.l		#1,d6
.loop_reloc_cicon_color
	tst.l		a1
	beq		.end_reloc_cicon
	addq.l		#2,d6
	lea		col_data(a1),a0
	reloc_adr	a0
	lea		col_mask(a1),a0
	reloc_adr	a0
	tst.l		sel_data(a1)
	beq		.no_selected
	addq.l		#2,d6
	lea		sel_data(a1),a0
	reloc_adr	a0
	lea		sel_mask(a1),a0
	reloc_adr	a0

.no_selected
	lea		next_res(a1),a0
	move.l		next_res(a1),a1
	tst.l		(a0)
	beq		.end_reloc_cicon
	addq.l		#1,d6
	reloc_adr	a0
	bra		.loop_reloc_cicon_color
.end_reloc_cicon
	bra		end_reloc_obj
	*---------------*
reloc_g_pix
	addq.l		#2,d6
	move.l		(a3),a2
	reloc_adr	a2
	reloc_adr	a3
	bra		end_reloc_obj
reloc_g_progdef
reloc_g_ibox
reloc_g_box
reloc_g_boxchar
reloc_g_line

end_reloc_obj
	lea	24(a6),a6
	sub.l	#1,d7
	bne	relocobj_loop
	*---------------*
* Reste plus qu'a reloger le reste de la ressource : la table d'arbre, la table de label et le header

* Relocation de la table d'arbre
	move.l	nrsh_treetbl(a5),a6
	move.l	nrsh_ntree(a5),d7
.loop_reloc_treetbl
	addq.l		#1,d6
	lea		rptb_ptr(a6),a3
	reloc_adr	a3
	lea		sizeof_rptb(a6),a6
	subq.l		#1,d7
	bne		.loop_reloc_treetbl

* Relocation du header
	addq.l		#4,d6
	lea		nrsh_treetbl(a5),a6
	reloc_adr	a6
	lea		nrsh_rsced(a5),a6
	reloc_adr	a6
	lea		nrsh_objs(a5),a6
	reloc_adr	a6
	lea		nrsh_label(a5),a6
	reloc_adr	a6

	move.l		d6,nrsh_naddr(a5)

	move.l		a4,d4
	sub.l		a5,d4
	mshrink		d4,a5

	move.l		d4,d0			; taille du ressource a sauver
	move.l		a5,a0			; et son adresse
	movem.l		(sp)+,d1-d7/a1-a6
	rts


****************************************************************************************


	bss
mfdb_insauve_rsc	ds.b	mfdb_struc_size
mfdb_outsauve_rsc	ds.b	mfdb_struc_size
tree_ptr		ds.b	sizeof_rptb*nbr_of_tree
	text
