	include		zlib.i
	include		gemdos.i
	include		vdi.i

	include		structs.s

	include		..\memory.s

	include		gcicontr.s

	XREF		contrl,planes

	XDEF		save_atari_format
save_atari_format
	movem.l		d1-d7/a1-a6,-(sp)
	move.l		56+0(sp),a6				; a6 = adresse du ressource en memoire

	move.l		a6,a4

	xmalloc		#500000		; on malloc 500k pour commencer. D'ici la, on aura fait une routine cool...
	tst_rts				; ...pour tester la taille du ressource avant sauvegarde.
	move.l		d0,a4
	move.w		#4,(a4)
	add.l		#rsh_struct_size,d0
	move.w		#rsh_struct_size,rsh_object(a4)
	move.l		d0,a3

*------------------------------------------------------------------------------------*
* On copi les arbres un par un a la suite
	lea		mrsc_ptr(a6),a2
	move.l		mrsc_ptrnbr(a6),d7
	move.w		d7,rsh_ntrees(a4)
	lea		sauve_tree_ptr,a1
	move.w		#0,a5		; nombre d'objet
.boucle_copi_les_arbres
	move.l		(a2)+,a0
	move.l		a3,(a1)+	; on sauve l'adresse de l'arbre a copier ds le buffer de sauvegarde
	add.l		#mtree_objets,a0
.boucle_copy_un_arbre
	addq.w		#1,a5
	movem.l		(a0)+,d0-d5				; on copi les objets

* On se passe de l'indirection des objets contenant des chunks
	btst		#INDIRECT+16,d2
	beq		.no_indy
	move.l		(d3.l),d3
	bclr		#INDIRECT+16,d2
.no_indy

* On converti les coordonnees ecran (pixel) de l'objet en coordonnees disk (caractere, pixel)
* Ne marche qu'en haute resol !!!
	swap		d4
	move.w		d4,d6
	and.w		#$fff8,d6
	sub.w		d6,d4
	lsl.w		#8,d4
	lsr.w		#3,d6
	or.w		d6,d4
	swap		d4
	move.w		d4,d6
	and.w		#$fff0,d6
	sub.w		d6,d4
	lsl.w		#8,d4
	lsr.w		#4,d6
	or.w		d6,d4

	swap		d5
	move.w		d5,d6
	and.w		#$fff8,d6
	sub.w		d6,d5
	lsl.w		#8,d5
	lsr.w		#3,d6
	or.w		d6,d5
	swap		d5
	move.w		d5,d6
	and.w		#$fff0,d6
	sub.w		d6,d5
	lsl.w		#8,d5
	lsr.w		#4,d6
	or.w		d6,d5

	add.l		#24,a3
	movem.l		d0-d5,-(a3)
	add.l		#24,a3
	btst		#LASTOB+16,d2			; et ce jusqu'au dernier
	beq		.boucle_copy_un_arbre
	subq.l		#1,d7
	bne		.boucle_copi_les_arbres
	move.w		a5,d6
	move.w		d6,rsh_nobs(a4)

*------------------------------------------------------------------------------------*
	move.l		a4,d4	; !!! il sagit bien du meme pointeur !!!
*------------------------------------------------------------------------------------*
* On fabrique une liste d'arbre
	move.l		a3,d0
	sub.l		a4,d0
	move.w		d0,rsh_trindex(a4)

	move.l		mrsc_ptrnbr(a6),d7
	lea		sauve_tree_ptr,a0
.update_la_liste_darbre
	move.l		(a0)+,d0
	sub.l		a4,d0
	move.l		d0,(a3)+
	subq.l		#1,d7
	bne		.update_la_liste_darbre

*------------------------------------------------------------------------------------*
* Puis on copi les tedinfos				; a3 pointe vers la suite du fichier
* G_TEXT G_FTEXT G_BOXTEXT G_FBOXTEXT
	move.w		rsh_nobs(a4),d7
	subq.w		#1,d7				; d7 contient le nombre d'objet total ds le rsc (-1 : dbf)
	move.l		a4,a2
	add.w		rsh_object(a4),a2	; a2 pointe vers le 1er objet
	moveq.l		#0,d5
	moveq.l		#0,d6

	move.l		a3,d0				; on update le pointeur du header
	sub.l		a4,d0
	move.w		d0,rsh_tedinfo(a4)

	move.l		a3,a1	; sauvegarde pour plus tard...
* On sauve d'abbord les structures de tedinfos
.boucle_sauve_les_tedinfo
	moveq.l		#0,d5
	move.b		ob_type+1(a2),d5
	cmp.w		#G_TEXT,d5
	beq		.sauve_la_ted_info
	cmp.w		#G_BOXTEXT,d5
	beq		.sauve_la_ted_info
	cmp.w		#G_FTEXT,d5
	beq		.sauve_la_ted_info
	cmp.w		#G_FBOXTEXT,d5
	bne		.pas_de_ted_info

.sauve_la_ted_info
	move.l		ob_spec(a2),a0
	btst		#INDIRECT-8,ob_flags(a2)
	beq		.not_extended
	move.l		(a0),a0
.not_extended
	move.l		a3,ob_spec(a2)
	sub.l		d4,ob_spec(a2)
	move.l		(a0)+,(a3)+
	cmp.w		#G_TEXT,d5
	beq		.cest_pas_un_editable
	cmp.w		#G_BOXTEXT,d5
	beq		.cest_pas_un_editable
	move.l		(a0)+,(a3)+
	move.l		(a0)+,(a3)+
	bra.s		.suite_sauve_tedinfo

.cest_pas_un_editable
	addq.l		#8,a0
	clr.l		(a3)+
	clr.l		(a3)+

.suite_sauve_tedinfo
	move.w		#3,d0
.loop_sauve_tedinfo
	move.l		(a0)+,(a3)+
	dbf		d0,.loop_sauve_tedinfo

	addq.w		#1,d6			; numero de la prochaine ted_info
.pas_de_ted_info
	lea		24(a2),a2
	dbf		d7,.boucle_sauve_les_tedinfo
	move.w		d6,rsh_nted(a4)
	beq		.yapas_de_tedinfos

* Puis on sauve les chaines pointes par les tedinfos
	subq.w		#1,d6
.sauve_les_chaine_de_tedinfo
	move.l		(a1),a0				; ptext
	move.l		a3,(a1)
	sub.l		d4,(a1)+
.tedinfo_chaine_ptext
	move.b		(a0)+,(a3)+
	bne		.tedinfo_chaine_ptext
;	addq.l		#1,a3
;	andi.l		#$fffffffe,a3	; On arondi au word

	tst.l		(a1)
	beq		.pas_de_ptmplt_ni_de_pvalid
	move.l		(a1),a0
	move.l		a3,(a1)
	sub.l		d4,(a1)+
.tedinfo_chaine_ptmplt
	move.b		(a0)+,(a3)+
	bne		.tedinfo_chaine_ptmplt
;	addq.l		#1,a3
;	andi.l		#$fffffffe,a3

	move.l		(a1),a0
	move.l		a3,(a1)
	sub.l		d4,(a1)
.tedinfo_chaine_pvalid
	move.b		(a0)+,(a3)+
	bne		.tedinfo_chaine_pvalid
;	addq.l		#1,a3
;	andi.l		#$fffffffe,a3
	subq.l		#4,a1

.pas_de_ptmplt_ni_de_pvalid
	add.l		#te_struc_size-4,a1
	dbf		d6,.sauve_les_chaine_de_tedinfo

.yapas_de_tedinfos
*------------------------------------------------------------------------------------*
* On sauvegarde les chaine une a une
* G_TITLE G_STRING
	move.w		rsh_nobs(a4),d7
	subq.w		#1,d7
	move.l		a4,a2
	add.w		rsh_object(a4),a2
	moveq.l		#0,d5
	moveq.l		#0,d6
	move.l		a3,d0
	sub.l		a4,d0
.boucle_sauve_les_chaine
	move.b		ob_type+1(a2),d5
	cmp.w		#G_STRING,d5
	beq		.sauve_une_chaine
	cmp.w		#G_BUTTON,d5
	beq		.sauve_une_chaine
	cmp.w		#G_TITLE,d5
	bne		.pas_de_chaine
.sauve_une_chaine
	move.l		ob_spec(a2),a1
	btst		#INDIRECT-8,ob_flags(a2)
	beq		.not_extended2
	move.l		(a1),a1
.not_extended2

	move.l		a3,ob_spec(a2)
	sub.l		d4,ob_spec(a2)
.boucle_copy_chaine
	move.b		(a1)+,(a3)+
	bne		.boucle_copy_chaine

.pas_de_chaine
	lea		24(a2),a2
	dbf		d7,.boucle_sauve_les_chaine


*------------------------------------------------------------------------------------*
* Alignement de a3 sur un word
	move.l		a3,d0
	or.b		#1,d0
	addq.l		#1,d0
	move.l		d0,a3

* On sauve maintenant les BITBLKs
* G_IMAGE
	move.w		rsh_nobs(a4),d7
	subq.w		#1,d7
	moveq.l		#0,d3		; d3 est notre compteur d'objet
	move.l		a3,d0
	sub.l		a4,d0
	move.w		d0,rsh_bitblk(a4)
	move.l		a4,a2
	add.w		rsh_object(a4),a2
	move.l		a3,a5
	moveq.l		#0,d5
.boucle_sauve_les_bitblks
	move.b		ob_type+1(a2),d5
	cmp.w		#G_IMAGE,d5
	bne		.pas_de_bitblk

	add.w		#1,d3
* D'abbord les structures
	move.l		ob_spec(a2),a1	; on update pointeur_d'ob_spec->index
	btst		#INDIRECT-8,ob_flags(a2)
	beq		.not_extended3
	move.l		(a1),a1
.not_extended3
	move.l		a3,ob_spec(a2)
	sub.l		d4,ob_spec(a2)
	move.l		#bi_struc_size-2,d6
	lsr.l		#1,d6
.boucle_copi_bitblk
	move.w		(a1)+,(a3)+
	dbf		d6,.boucle_copi_bitblk	; on copi la structure

.pas_de_bitblk
	lea		24(a2),a2
	dbf		d7,.boucle_sauve_les_bitblks
	move.w		d3,rsh_nbb(a4)
	beq		.pas_de_bitblk_du_tout

* Puis les donnees : a5 pointe vers les structures bitblks
	subq.w		#1,d3
.boucle_sauve_les_bitblks_data
	move.l		a3,d0
	sub.l		a4,d0
	move.l		(a5),a1
	move.l		d0,(a5)
	moveq.l		#0,d5
	move.w		bi_wb(a5),d5			; (largeur / 8) * hauteur = taille en octet
	moveq.l		#0,d6						; Calcul la taille de l'image, les donnes
	move.w		bi_hl(a5),d6			; etants stoke juste apres la structure de l'objet
;	xmul		d5,d6
	mulu.l		d5,d6
	lsr.l		#1,d6
	subq.w		#1,d6
.boucle_copy_une_donnee
	move.w		(a1)+,(a3)+
	dbf		d6,.boucle_copy_une_donnee

	lea		bi_struc_size(a5),a5
	dbf		d3,.boucle_sauve_les_bitblks_data
.pas_de_bitblk_du_tout

*------------------------------------------------------------------------------------*
* On sauve les ICONBLKs
	move.w		rsh_nobs(a4),d7
	subq.w		#1,d7
	moveq.l		#0,d2		; compteur de G_ICONBLKs
	move.l		a4,a2
	add.w		rsh_object(a4),a2
* On sauve les structures
	move.l		a3,a5	; pointeur sur les structures ICONBLKs
.boucle_sauve_les_iconblks_structures
	cmp.b		#G_ICON,ob_type+1(a2)
	bne			.pas_de_iconblk

	add.w		#1,d2
	move.l		ob_spec(a2),a1	; on reloge l'ob_spec
	btst		#INDIRECT-8,ob_flags(a2)
	beq		.not_extended4
	move.l		(a1),a1
.not_extended4
	move.l		a3,ob_spec(a2)
	sub.l		d4,ob_spec(a2)

;	move.w		#(ib_struc_size_mono/2)-1,d6	; copy de la structure
	move.w		#17,d6
.boucle_copy_structure_iconblk
	move.w		(a1)+,(a3)+
	dbf		d6,.boucle_copy_structure_iconblk

.pas_de_iconblk
	lea		24(a2),a2
	dbf		d7,.boucle_sauve_les_iconblks_structures


* Puis les donnees, a5 pointant sur la 1ere structure
	move.w		d2,rsh_nib(a4)
	beq		.pas_de_iconblk_du_tout
	subq.w		#1,d2
	move.l		a5,d0
	sub.l		a4,d0
	move.w		d0,rsh_iconblk(a4)
.boucle_copy_les_donnees
* Calcul de la taille d'un plan d'icone pour un dbf
	moveq.l		#0,d0
	move.w		ib_wicon(a5),d0
	mulu.w		ib_hicon(a5),d0
	lsr.l		#4,d0
	sub.w		#1,d0
	move.w		d0,d1	; compteur dbf a conserver pour boucle suivante...
* Reloge le pointeur de MASK et copi le buffer
	move.l		(a5),a1
	move.l		a3,(a5)
	sub.l		d4,(a5)
.boucle_copy_mask_de_liconblk
	move.w		(a1)+,(a3)+
	dbf			d0,.boucle_copy_mask_de_liconblk

* Idem pour le DATA
	move.l		ib_pdata(a5),a1
	move.l		a3,ib_pdata(a5)
	sub.l		d4,ib_pdata(a5)
.boucle_copy_data_de_liconblk
	move.w		(a1)+,(a3)+
	dbf		d1,.boucle_copy_data_de_liconblk

* Puis la chaine
	move.l		ib_ptext(a5),a1
	move.l		a3,ib_ptext(a5)
	sub.l		d4,ib_ptext(a5)
.boucle_copy_text_de_liconblk
	move.b		(a1)+,(a3)+
	bne		.boucle_copy_text_de_liconblk
	move.l		a3,d0
	addq.l		#1,d0
	andi.l		#$fffffffe,d0	; on alligne a3 sur le mot suivant... ca parait un peut long !
	move.l		d0,a3

	dbf		d2,.boucle_copy_les_donnees

.pas_de_iconblk_du_tout
	move.l		a3,d0
	sub.l		a4,d0
	move.w		d0,rsh_rssize(a4)	; on sauve la taille de la partie basse du fichier

;	bra		.yop_sauve
*------------------------------------------------------------------------------------*
* Sauvegarde des icones couleurs... aii !!!
* Le debut de la routine est largement inspirer de la routine des icones monochromes,
* puisqu'un icone couleur est un icone monochrome long de 2 octets de plus dans sa
* structure specifique, avec comme dernier mot long le pointeur sur la 1ere resolution
* couleur...
* Il faut d'abord creer l'extention du ressource (format aes 3)
* pour l'instant on ne fait que reserver de la place, a6 pointe vers la structure
	move.l	a3,a6				; a6 pointe vers la structure "extention array"
	add.l	#ext_array_size,a3	; a3 pointe sur le premier emplacement pour zone ICONBLK

	move.l	a3,cicon_offset(a6)
	sub.l	d4,cicon_offset(a6)
*----------------------------------------------------------------------------*
* On compte le nombre de G_CICON dans le fichier, et pour chaque G_CICON
* on place un 0.l dans le fichier ressource (CICONBLK pointer table)
	move.w		rsh_nobs(a4),d7
	subq.w		#1,d7
	moveq.l		#0,d2		; compteur de G_CICONBLKs
	move.l		a4,a2
	add.w		rsh_object(a4),a2
.compte_les_icones_couleurs
	cmp.b		#G_CICON,ob_type+1(a2)
	bne		.najoute_pas_un
	addq.w		#1,d2
	clr.l		(a3)+	; qui qu'a invente une pareil merde ? Un 0 = un icone de plus !!!
.najoute_pas_un
	lea		24(a2),a2
	dbf		d7,.compte_les_icones_couleurs
	tst.w		d2
	beq		.pas_de_iconblk_du_toutC
	move.l		#-1,(a3)+

*----------------------------------------------------------------------------*
* On sauve les ICONBLKs contenus dans les icone couleur
	move.w		rsh_nobs(a4),d7
	subq.w		#1,d7
	moveq.l		#0,d2		; compteur de G_CICONBLKs
	move.l		a4,a2
	add.w		rsh_object(a4),a2
* On sauve les structures
.boucle_sauve_les_iconblks_structuresC
	cmp.b		#G_CICON,ob_type+1(a2)
	bne		.pas_de_iconblkC

	move.l		a3,a5	; pointeur sur le debut de la structure ICONBLK
	move.l		ob_spec(a2),a1	; on reloge l'ob_spec
	btst		#INDIRECT-8,ob_flags(a2)
	beq		.not_extended5
	move.l		(a1),a1
.not_extended5
	move.l		d2,ob_spec(a2)	; On place dans l'ob_spec le numero de l'icone couleur
	add.w		#1,d2

	clr.l		(a3)+
	clr.l		(a3)+
	clr.l		(a3)+
	lea		12(a1),a1
	move.w		#4,d6
.boucle_copy_structure_iconblkC
	move.l		(a1)+,(a3)+							; copy de la structure ICONBLK++
	dbf		d6,.boucle_copy_structure_iconblkC
	move.w		(a1)+,(a3)+

*----------------------------------------------------------------------------*
* Combien de resolution y a-t-il dans l'icone ???
	moveq.l		#0,d0
	move.l		(a1),a0
.boucle_compte_nbr_resol
	tst.l		a0
	beq		.fin_compte_nbr_resol
	addq.w		#1,d0
	move.l		next_res(a0),a0
	bra		.boucle_compte_nbr_resol

.fin_compte_nbr_resol
	move.l		d0,(a3)+		; on met ca dans le fichier
	move.w		d0,d5			; et dans un compteur pour notre boucle

	sub.l		#ib_resvd,a1
*----------------------------------------------------------------------------*
**************
* Puis les donnees monochromes.
.boucle_copy_les_donneesC
* Calcul de la taille d'un plan d'icone pour un dbf (donc en nombre de word -1)
	moveq.l		#0,d0
	move.w		ib_wicon(a5),d0
	mulu.w		ib_hicon(a5),d0
	lsr.l		#4,d0
	sub.w		#1,d0
	move.w		d0,d1	; compteur dbf a conserver pour les boucles suivantes...
	*--------------*
	move.l		a3,ib_pmask(a5)
	sub.l		d4,ib_pmask(a5)		; reloge le pointeur du mask

	move.l		ib_pmask(a1),a0
.boucle_copy_mask_de_liconblkC
	move.w		(a0)+,(a3)+
	dbf		d0,.boucle_copy_mask_de_liconblkC
	*--------------*
* Idem pour le DATA
	move.l		a3,ib_pdata(a5)
	sub.l		d4,ib_pdata(a5)		; reloge le pointeur du mask

	move.w		d1,d0
	move.l		ib_pdata(a1),a0
.boucle_copy_data_de_liconblkC
	move.w		(a0)+,(a3)+
	dbf		d0,.boucle_copy_data_de_liconblkC
	*--------------*
	move.l		a3,ib_ptext(a5)
	sub.l		d4,ib_ptext(a5)
* Puis la chaine
	move.l		ib_ptext(a1),a0
	move.w		#11,d0
.boucle_copy_text_de_liconblkC
	move.b		(a0)+,(a3)+
	dbf		d0,.boucle_copy_text_de_liconblkC

*----------------------------------------------------------------------------*
* Pis la, on s'attaque a une partie plus chiante, specifique au icones couleurs.
* C'est presque fini !!!
* L'icone a-t-il une partie couleur ?
	move.l		ib_resvd(a1),a1

* Puisque la premiere resol est celle adapte a la resol ecran, on la saute
	move.l		next_res(a1),a1

;	tst.l		a1
;	bne.s		.ya_de_la_couleur_la_dedant
;.ya_de_la_couleur_la_dedant

***********
	add.w		#1,d1	; nombre de word d'un plan-1 +1

.copy_la_couleur
* On uptdate d'abord le header (a zero... cool la phylosophie Atari !)
	move.w		(a1),(a3)+
	clr.l		(a3)+
	clr.l		(a3)+	; calculated upon loading
	tst.l		sel_data(a1)
	beq		.pas_de_selection
	move.l		#1,(a3)+			; 0 = pas de selection
	bra		.suite_couleur2
.pas_de_selection
	clr.l		(a3)+
.suite_couleur2
	clr.l		(a3)+
	tst.l		next_res(a1)
	beq		.last_resol
	move.l		#1,(a3)+		; 1 = il reste des icones
	bra		.suite_couleur
.last_resol
	clr.l		(a3)+
.suite_couleur

**************************************************************************
*** Deplacement des donnees des icones couleurs dans le fichier sauver ***
**************************************************************************
* Deplacement des donnes (parti non selectionne)
	move.l		col_data(a1),a0
	moveq.l		#0,d0
	move.w		(a1),d0		; nombre de plan de l'icone
	mulu.w		d1,d0		; nombre d'iteration
	subq.w		#1,d0
	move.l		a3,temp_ptr	; Ziiiiiiiiiiiiip.
.copy_les_donnees_couleurs
	move.w		(a0)+,(a3)+
	dbf		d0,.copy_les_donnees_couleurs

* Si nombre de plan courant des donnees deplace = nombre de plan de la station vdi courante...
	move.w		(a1),d0
	cmp.w		planes,d0
	bne		.data_pas_de_transform

* ...alors on transform de dessin de l'icone au format VDI.
	move.l		temp_ptr,d0		; Zaaaaaaaaaaaap.


* Plus besoin, puique la seule resol au fromat ecran est celle du debut de la liste
	movem.l		d0-d3/a0-a3,-(sp)

	lea		mfdb_insauve_rsc,a2
	lea		mfdb_outsauve_rsc,a3
	move.l		d0,(a2)
	move.l		d0,(a3)
	move.w		ib_wicon(a5),mfdb_w(a2)
	move.w		ib_wicon(a5),mfdb_w(a3)
	move.w		ib_hicon(a5),mfdb_h(a2)
	move.w		ib_hicon(a5),mfdb_h(a3)
	moveq.l		#0,d0
	moveq.l		#0,d2
	move.w		d1,d0
	move.w		ib_hicon(a5),d2
	divu.w		d2,d0
	move.w		d0,larg_mot(a2)
	move.w		d0,larg_mot(a3)
	move.w		(a1),nbr_plan(a2)
	move.w		(a1),nbr_plan(a3)
	move.w		#0,format(a2)
	move.w		#1,format(a3)

	move.l		#mfdb_insauve_rsc,-(sp)
	move.l		#mfdb_outsauve_rsc,-(sp)
;	jsr		icon_trans
	addq.l		#8,sp

	movem.l		(sp)+,d0-d3/a0-a3




.data_pas_de_transform

* Deplacement du masque de l'icone
	move.w		d1,d0
	move.l		col_mask(a1),a0
	subq.w		#1,d0
.boucle_copy_le_mask
	move.w		(a0)+,(a3)+
	dbf		d0,.boucle_copy_le_mask

*--------------------------------------------------------------------------------------------------------------------------*
* Ya-t-il une parti selectionne ?
	tst.l		sel_data(a1)
	beq		.pas_de_partie_selectionne
* Copy de la parti selectionne de l'icone
	move.l		sel_data(a1),a0
	moveq.l		#0,d0
	move.w		(a1),d0		; nombre de plan de l'icone
	mulu.w		d1,d0		; nombre d'iteration
	subq.w		#1,d0
	move.l		a3,temp_ptr	; Ziiiiiiiiiiiiip.
.sel_copy_les_donnees_couleurs
	move.w		(a0)+,(a3)+
	dbf		d0,.sel_copy_les_donnees_couleurs

* Si nombre de plan courant des donnees deplace = nombre de plan de la station vdi courante...
	move.w		(a1),d0
	cmp.w		planes,d0
	bne		.sel_pas_de_transform

* ...alors on transform de dessin de l'icone au format VDI.
	move.l		temp_ptr,d0		; Zaaaaaaaaaaaap.




* Plus besoin, puique la seule resol au fromat ecran est celle du debut de la liste
	movem.l		d0-d3/a0-a3,-(sp)
	lea		mfdb_insauve_rsc,a2
	lea		mfdb_outsauve_rsc,a3
	move.l		d0,(a2)
	move.l		d0,(a3)

	move.l		#mfdb_insauve_rsc,-(sp)
	move.l		#mfdb_outsauve_rsc,-(sp)
;	jsr		icon_trans
	addq.l		#8,sp

	movem.l		(sp)+,d0-d3/a0-a3




.sel_pas_de_transform

* Deplacement du masque de l'icone
	move.w		d1,d0
	move.l		sel_mask(a1),a0
	subq.w		#1,d0
.boucle_copy_le_mask_sel
	move.w		(a0)+,(a3)+
	dbf		d0,.boucle_copy_le_mask_sel
.pas_de_partie_selectionne

	move.l		next_res(a1),a1
	tst.l		a1
	bne		.copy_la_couleur

.pas_de_iconblkC
	lea		24(a2),a2
	dbf		d7,.boucle_sauve_les_iconblks_structuresC

	bra		.suite_extention_array
.pas_de_iconblk_du_toutC
	move.l		#-1,cicon_offset(a6)
.suite_extention_array
	move.l		a3,d0
	sub.l		a4,d0
	move.l		d0,(a6)
;	move.l		#-1,palette_interf(a6)
*------------------------------------------------------------------------------------*
.yop_sauve
	move.l		a4,a0		; adresse du ressource a sauver
	move.l		a3,d0
	sub.l		a4,d0		; taille du ressource a sauver
	movem.l		(sp)+,d1-d7/a1-a6
	rts
	bss
mfdb_insauve_rsc	ds.b	mfdb_size
mfdb_outsauve_rsc	ds.b	mfdb_size
sauve_tree_ptr		ds.l	nbr_of_tree
temp_ptr		ds.l	1
	text
