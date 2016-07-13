	include	aes.i
	include	gemdos.i
	include	zlib.i

	include	structs.s
	include	util.i

	include	..\memory.s
	include	..\macro.i
	include	..\fashion.s

	XREF	label_dial_default,label_menu_default

	XREF	x_max,y_max,init_x,init_y,wd_create_objet

	XREF		appl_name
	XREF		rsc_files
	XREF		openrsc_path
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	newload
	XDEF	newrsc_gaddr
newload
	movem.l	d1-a6,-(sp)
	move.l	60(sp),d6

* On rempli un pointeur de ressource
	lea		rsc_files,a6
.cherche_une_place
	tst.l		(a6)+
	bne		.cherche_une_place
	subq.l		#4,a6

* on reserve de la place pour un bloc racine de ressource et on rempli le bloc racine
	xmalloc		#mrsc_size
	move.l		d0,(a6)
	move.l		d0,d7

	move.l		d0,a4
	move.l		d6,a0
	move.l		nrsh_ntree(a0),d5
	cmp.l		#nbr_of_tree,d5
	blt		.no_max_tree_err
	illegal		; Erreur : le "EQU" definissant le nombre maxi d'arbre n'est pas assez grand
.no_max_tree_err
	move.l		d5,mrsc_ptrnbr(a4)

	string_copy	#openrsc_path,d0

* 1 - Nom de fichier
	move.l		d7,d0
	add.l		#mrsc_wind_name,d0
	string_copy	#appl_name,d0
	move.l		d7,d0
	add.l		#mrsc_wind_name,d0
	add.l		#20,d0
	string_copy	#openrsc_path,d0

* 2 - copie des arbres
	move.l		d6,a6
	move.l		nrsh_ntree(a6),d5
	beq		.pas_de_tree
	move.l		nrsh_treetbl(a6),a5	; a5 pointe sur le debut de la liste des tree
	move.l		d7,a4
	add.l		#mrsc_ptr,a4

.boucle_charge_tree

* on trouve l'adresse de l'arbre puis on le copi et on update un pointeur
* (pour le multifichier) dans un Malloc. On en profite pour Mallok‚ un blok par objet...
* ... plus simple pour les delete
	move.l		rptb_ptr(a5),a3
	lea		sizeof_rptb(a5),a5
	xmalloc		#mtree_size
	tst_rts
	move.l		d0,(a4)+
	move.l		d0,a2
	add.l		#mtree_objets,a2

.boucle_copy_un_objet
	move.l		a2,a0
	movem.l		(a3)+,d0-d4
	move.l		d0,(a2)+
	move.l		d1,(a2)+
	move.l		d2,(a2)+
	move.l		d3,(a2)+
	move.l		d4,(a2)+
	move.l		(a3)+,(a2)+
	objc_real	a0		; macro magique qui malloc l'objet dans un bloc separe.
* Refait le chemin d'un eventuelle G_PIX
	*---*
	cmp.b		#G_PIX,ob_type+1(a0)
	bne		.not_gpix
	move.l		ob_spec(a0),a1
	string_copy	#openrsc_path,#temp_path

	lea		temp_path,a0
.lp_find_end
	tst.b		(a0)+
	bne		.lp_find_end
.lp_find_file
	cmp.b		#"/",-(a0)
	beq		.ok_end_path
	cmp.b		#"\",(a0)
	beq		.ok_end_path
	bra		.lp_find_file
.ok_end_path
	addq.l		#1,a0
	move.b		#0,(a0)

	string_concat	(a1),#temp_path
	string_size	#temp_path
	xaloc_grow	d0,a1
	string_copy	#temp_path,(a1)
	*---*
.not_gpix
	btst		#16+LASTOB,d2	; dernier objet ?
	beq		.boucle_copy_un_objet
	move.w		#5,d0
.yo	clr.l		(a2)+
	dbf		d0,.yo

	subq.l		#1,d5
	bne		.boucle_charge_tree
.pas_de_tree

* Maintenant, on rempli la structure wd_objet pour que la fenetre
* "liste d'arbre" s'affiche correctement.

*; d'abbord le header
	move.l		d7,a4
	add.l		#mrsc_tree_list,a4
	rsrc_gaddr	#0,#ENTER_NAME
	trouve_objc	addr_out,#RB_DIALOG
	move.w		ob_w(a0),wd_objc_x(a4)	
	add.w		#1,wd_objc_x(a4)
	move.w		ob_h(a0),wd_objc_y(a4)
	add.w		#1,wd_objc_y(a4)
	clr.w		wd_objc_skip(a4)
	add.l		#wd_objc_header_size,a4

	move.l		d6,a6
	move.l		nrsh_ntree(a6),d5	; d5 contient le nombre de tree
	move.l		d7,a3
	add.l		#mrsc_ptr,a3

*; puis la liste d'objet.
	bsr		init_num_arbre

.boucle_construit_liste_dobjet
	move.l		addr_out,wd_objc_form(a4)	; copy de : l'adresse du formulaire ou se trouve l'icone
	move.l		(a3)+,a5
	lea		mtree_label(a5),a0
	move.l		a0,wd_obcj_string(a4)		; Le pointeur de chaine de la fenetre wd_objet pointe vers
	move.l		a0,d4				; la chaine de label de l'arbre

	lea		mtree_objets(a5),a0
	move.l		a0,a2
	cmp.b		#G_IBOX,ob_type+1(a0)
	bne		.not_menu
	trouve_objc	a2,ob_head(a0)
	cmp.b		#G_BOX,ob_type+1(a0)
	bne		.not_menu
	trouve_objc	a2,ob_head(a0)
	cmp.b		#G_IBOX,ob_type+1(a0)
	bne		.not_menu
	trouve_objc	a2,ob_head(a0)		; On trouve le premier G_TITLE
	cmp.b		#G_TITLE,ob_type+1(a0)
	bne		.not_menu
	move.w		#RB_MENU,wd_objc_icon(a4)
	move.l		#rptt_menu,mtree_type(a5)
	string_copy	#label_menu_default,d4		; puis table de structure
	bra		.type_ok
.not_menu

	move.l		#rptt_dial,mtree_type(a5)
	move.w		#RB_DIALOG,wd_objc_icon(a4)
	string_copy	#label_dial_default,d4		; le label de l'arbre
.type_ok
	move.l		d4,a0
.loop_end_chaine
	tst.b		(a0)+
	bne		.loop_end_chaine
	subq.l		#1,a0
	string_copy	#label_num_chaine,a0		; On ajoute un numero incrementant...

	clr.w		wd_objc_state(a4)
	add.l		#wd_objc_struct_size,a4
	bsr		inc_num_arbre
	subq.l		#1,d5
	bne		.boucle_construit_liste_dobjet

	clr.l		(a4)+
	clr.l		(a4)+
	clr.l		(a4)+

	move.l		d7,a4
	add.l		#mrsc_tree_list,a4
	move.w		x_max,d0
	move.w		y_max,d1
	sub.w		init_x,d0
	sub.w		init_y,d1
	lsr.w		#1,d0
	lsr.w		#1,d1
	wd_create	a4,#wd_create_objet,init_x,init_y,d0,d1	; puissant non ?

	Mfree		d6

	move.l		d7,d0
	movem.l		(sp)+,d1-a6
	rts

* Gestion d'une erreur lors du chargement du fichier
memerror
error
	move.l	#0,d0		; 0 = error
	movem.l	(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
*******************************************************************************************************
*** Quelques petites fonctions bidon pour generer des numeros de dialogues lorsqu'on a pas de label ***
*******************************************************************************************************
init_num_arbre
	move.l		a6,-(sp)
	move.l		a5,-(sp)
	lea		label_num_init_chaine,a5
	lea		label_num_chaine,a6
.loop
	move.b		(a5)+,(a6)+
	bne		.loop

	move.l		(sp)+,a5
	move.l		(sp)+,a6
	rts

inc_num_arbre
	move.l		a6,-(sp)
	lea		label_num_chaine,a6
	addq.l		#3,a6
	cmp.b		#"9",(a6)
	beq		.dizaine
	add.b		#1,(a6)
	move.l		(sp)+,a6
	rts
.dizaine
	move.b		#"0",(a6)
	subq.l		#1,a6
	cmp.b		#"9",(a6)
	beq		.centaine
	add.b		#1,(a6)
	move.l		(sp)+,a6
	rts
.centaine
	move.b		#"0",(a6)
	subq.l		#1,a6
	add.b		#1,(a6)
	move.l		(sp)+,a6
	rts

	data
	even
label_num_init_chaine	dc.b	"_001",0
	even
label_num_chaine	dc.b	"_999",0
	even
	bss
temp_path	ds.b	1024
	text
*--------------------------------------------------------------------------------------------------------------------------*
* Realocation du fichier ressource
	XDEF	newrsc_reloc
newrsc_reloc
	movem.l	d6-d7/a5-a6,-(sp)
	move.l	20(sp),a6
	move.l	nrsh_naddr(a6),d7	; d7 = nombre d'adresse a reloger
	move.l	a6,a5
	add.l	nrsh_reloc(a6),a5	; a5 = pointeur sur table de relocation
	move.l	a6,d6			; d6 = adresse de base du ressource

.loop	move.l	(a5)+,a3
	add.l	d6,a3
	add.l	d6,(a3)
	subq.l	#1,d7
	bne	.loop

	movem.l	(sp)+,d6-d7/a5-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
newrsc_gaddr
	movem.l	d7/a5/a6,-(sp)
	move.l	16+4(sp),a5
	move.l	16(sp),d7
	move.l	nrsh_treetbl(a5),a6
	lea	0(a6,d7.l*4),a6
	move.l	(a6),d0
	movem.l	(sp)+,d7/a5/a6
	rts

