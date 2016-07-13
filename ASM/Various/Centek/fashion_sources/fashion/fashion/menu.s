*** Permet de faire ou non une version de demo ***
*DEMO	equ	1

	include	aes.i
	include	vdi.i
	include	gemdos.i
	include	zlib.i

	include	structs.s
	include	util.i

	include	memory.s
	include	fashion.s
	include	macro.i

* Variables ZLIB
	XREF	tab_adr,tab_type,tab_handle,x_max,y_max,init_x,init_y,planes,screen_mfdb
	XREF	appl_name,hauteur_menu,addr_in,contrl
	XREF	wd_create_form,wd_create_objet,wd_create_drag_window
* Variables FASHION
	XREF	rsc_files,appl_name,ENTER_NAME_adr,PREF_adr,INFO_adr,MAIN_adr,TOOL_BOX_adr
	XREF	ed_sel_objc,ed_sel_win
* messages d'erreurs (fichier messages.s)
	XREF	fenetre_non_toppe,new_rsc_name,Ressoucre_non_trouve,ereurum_batatestum
	XREF	fsel_open_texte,fsel_init_string,commentaire_de_sauvegarde
	XREF	fenetre_pas_trouve
	XREF	grid_origin_x,grid_origin_y
	XREF	default_alert_box
****************************************************************************************
***************************** Gestion du menu deroulant.  ******************************
****************************************************************************************
	XDEF	menu_deroulant,fenetre_enter_name,open_new_arbre_window
	XDEF	openrsc_path
menu_deroulant
	cmp.w	#M_INFO,d1
	beq	open_information
	cmp.w	#M_QUIT,d1
	beq	quitage
	cmp.w	#M_NEW,d1
	beq	nouvel_rsc
	cmp.w	#M_ARBRE,d1
	beq	nouvel_arbre
	cmp.w	#M_OPEN,d1
	beq	_open_ressource_file
	cmp.w	#M_DELETE,d1
	beq	eface_objets_en_cours
	cmp.w	#M_PREF,d1
	beq	open_pref_window
	cmp.w	#M_SAUVE,d1
	beq	sauve_ressource
	cmp.w	#M_EXPORT,d1
	beq	sauve_ressource
	cmp.w	#M_GRILLE,d1
	beq	set_grid_origine
	cmp.w	#M_OGRILLE,d1
	beq	set_obgrid_origine

	cmp.W	#M_MAIN,d1
	beq	open_main_window
	cmp.w	#M_TOOLBOX,d1
	beq	open_toolbox_window
	cmp.w	#M_HELP,d1
	beq	ouvre_aide
	rts
***********************************************************************************
set_grid_origine
	graf_mouse	#5
	evnt_button	#1,#1,#3
	move.w		int_out+2,grid_origin_x
	move.w		int_out+4,grid_origin_y
	graf_mouse	#0
	rts

set_obgrid_origine
	graf_mouse	#5
	evnt_button	#1,#1,#3

	move.w		int_out+2,d5
	move.w		int_out+4,d6

	wind_find	d5,d6
	tst.w		d0
	beq		.not_finded

	find_tab_w	#tab_handle,d0
	cmp.w		#-1,d0
	beq		.not_finded
	move.w		d0,d7

	get_tab		#tab_adr,d7
	move.l		d0,a6

	objc_find	a6,#0,#20,d5,d6
	cmp.w		#-1,d0
	beq		.not_finded
	move.w		d0,d4

	objc_offset	a6,d4
	tst.w		d0
	beq		.not_finded

	move.w		int_out+2,grid_origin_x
	move.w		int_out+4,grid_origin_y

	graf_mouse	#0
	rts
.not_finded
	form_alert	#1,#fenetre_pas_trouve
	rts
***********************************************************************************
ouvre_aide
	rsrc_gaddr	#0,#HELP
	wd_create	addr_out,#wd_create_form,#-1,#0,#0,#0
	rts
eface_objets_en_cours
	wind_get	#1,#WF_TOP
	find_tab_w	#tab_handle,int_out+2	; Trouve la fenetre au premier plan
	move.w		d0,d7
	get_tab		#tab_type,d7
	XREF		wd_create_editmenu
	cmp.l		#wd_create_editmenu,d0

	XREF		efface_objc_dans_menu	; Methode de la fenetre "menu editable"
	beq		efface_objc_dans_menu

	XREF		wd_create_objet
	cmp.l		#wd_create_objet,d0
	beq		.efface_arbre_selectionne

	move.l		ed_sel_win,a6
	erase_list	#ed_sel_objc,#ed_sel_win
	find_tab_l	#tab_adr,a6
	wd_redraw_gem	d0
	rts
	*-----------------------------------------*
.efface_arbre_selectionne
* Cherche le ressource correspondant a la fenetre au premier plan
	lea		rsc_files,a6
	get_tab		#tab_adr,d7
	move.l		d0,d6
.lp_search_rsc
	move.l		(a6)+,a5
	lea		mrsc_tree_list(a5),a4
	cmp.l		a4,d6
	beq		.trouved
	tst.l		(a6)
	bne		.lp_search_rsc

	rts

.trouved
* Efface tous les arbres selectionne
	lea		mrsc_ptr(a5),a3			; a3 = la liste de pointeur sur arbre
	lea		mrsc_tree_list(a5),a4
	lea		wd_objc_header_size(a4),a4	; a4 = la liste de la fenetre liste d'arbre
	move.l		mrsc_ptrnbr(a5),d5
.boucle_erase
	tst		wd_objc_state(a4)
	beq		.do_not_errase

* Desalouage des objets contenus dans l'arbre
	move.l		(a3),a2
	lea		mtree_objets(a2),a2

	efface_tree	a2		; demallocage des objets de l'arbre a effacer
	Mfree		(a3)		; et demallocage de l'arbre lui-meme

* On retire le pointeur sur arbre de la liste de pointeur
	move.l		a3,a0
	lea		4(a3),a1
	move.l		d5,d4
.boucle_erase_liste_ptr
	move.l		(a1)+,(a0)+
	sub.l		#1,d4
	bne		.boucle_erase_liste_ptr
	clr.l		(a0)+

* On declare un arbre de moins
	sub.l		#1,mrsc_ptrnbr(a5)

* On enleve un objet de la fenetre liste d'arbre
	move.l		a4,a0
	lea		wd_objc_struct_size(a4),a1
	move.l		d5,d4
.boucle_erase_fenobj
	move.w		#(wd_objc_struct_size/2)-1,d3
.lp_cp_lafin
	move.w		(a1)+,(a0)+
	dbf		d3,.lp_cp_lafin

	sub.l		#1,d4
	bne		.boucle_erase_fenobj
	clr.l		(a0)+

* Puisqu'on a effacer l'arbre, il ne faut pas sauter l'abre courant, on est deja devant le suivant
	bra		.errazed

* Passe a l'arbre suivant si on a pas effacer l'arbre en cours
.do_not_errase
	lea		wd_objc_struct_size(a4),a4
	addq.l		#4,a3
.errazed
	subq.l		#1,d5
	bne		.boucle_erase

	wd_redraw_gem	d7
	rts
***********************************************************************************
open_main_window
	rsrc_gaddr	#0,#MAIN
	move.l		addr_out,MAIN_adr
	wd_create	addr_out,#wd_create_form,#-1,#0,#0,#0
	rts
***********************************************************************************
open_toolbox_window
	wd_create	TOOL_BOX_adr,#wd_create_drag_window,#-1,#0,#0,#0
	rts
***********************************************************************************
open_pref_window
	rsrc_gaddr	#0,#PREF
	move.l		addr_out,PREF_adr
	wd_create	addr_out,#wd_create_form,#-1,#0,#0,#0
	rts
***********************************************************************************
quitage
	clr.w	-(sp)
	trap	#1
***********************************************************************************
open_information
	rsrc_gaddr	#0,#INFO
	move.l		addr_out,INFO_adr
	wd_create	addr_out,#wd_create_form,#-1,#0,#0,#0
	rts
***********************************************************************************
nouvel_rsc
	lea		rsc_files,a6	; cherche une place vide dans les pointeurs
.loop
	tst.l		(a6)+
	bne		.loop
	subq.l		#4,a6

	xmalloc		#mrsc_size		; malloc un fichier
	move.l		d0,(a6)			; et sauvegarde l'adresse memoire

* on rempli la structure du fichier en memoire...
	move.l		d0,a6
	clr.l		mrsc_ptrnbr(a6)
	move.l		d0,a0

	string_copy	#new_rsc_name,a0	; on rempli les trois chaines du header

	add.l		#mrsc_wind_name,a0
	string_copy	#appl_name,a0
.loop2
	tst.b		(a0)+	
	bne		.loop2
	subq.l		#1,a0
	move.b		#":",(a0)+
	move.b		#" ",(a0)+
	string_copy	#new_rsc_name,a0

	move.l		a6,a0				; puis on rempli la structure d'une fenetre
	add.l		#mrsc_tree_list,a0
	move.w		#145,(a0)
	move.w		#17,wd_objc_y(a0)
	move.w		#0,wd_objc_skip(a0)

	add.l		#wd_objc_header_size,a0

	move.w		#nbr_of_tree,d0		; nombre maxi d'arbre editable dans un fichier ressource
	mulu.w		#(wd_objc_struct_size/2),d0
	subq.w		#1,d0
.loop3
	clr.w		(a0)+		; on efface car on est apres un Malloc
	dbf		d0,.loop3

	add.l		#mrsc_tree_list,a6

	move.w		x_max,d0
	sub.w		init_x,d0
	lsr.w		#1,d0
	move.w		y_max,d1
	sub.w		init_y,d1
	lsr.w		#1,d1
	wd_create	a6,#wd_create_objet,init_x,init_y,d0,d1
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* On demande le nom et type du nouveau formulaire par ouverture d'une fenetre...
nouvel_arbre
	wind_get	#0,#10					; la fenetre du premier plan est-elle

	moveq.l		#0,d0
	move.w		int_out+2,d0
	find_tab_w	#tab_handle,d0			; du type OBJET ?
	move.w		d0,d4
	get_tab		#tab_type,d4
	cmp.l		#wd_create_objet,d0
	beq		.suitex1
.suitex2
	form_alert	#1,#fenetre_non_toppe
	rts
.suitex1
	move.w		d4,-(sp)
	bsr		open_new_arbre_window
	addq.w		#2,sp
	rts

open_new_arbre_window
	move.w		4(sp),d4
	get_tab		#tab_adr,d4
	move.l		d0,d7

* on trouve ensuite la structure du ressource correspondant a la fenetre topp‚.
	lea		rsc_files,a0
.loopx1
	tst.l		(a0)					; corespondant a la fenetre toppe.
	beq		oups			; (a0) == 0 ??? si test = vrai -> message d'erreur
	move.l		(a0)+,a6
	add.l		#mrsc_tree_list,a6
	cmp.l		a6,d7
	bne		.loopx1			; d7 == [mrsc_tree_liste(a0)]+ ??? <-- nouvel offset

; new_arbre_pointeur contient maintenant le pointeur sur la structure du ressource
	move.l		-4(a0),new_arbre_pointeur
	move.l		d4,new_arbre_window_offset
* on cherche une place pour un nouvel arbre
	rsrc_gaddr	#0,#ENTER_NAME
	move.l		addr_out,ENTER_NAME_adr
	wd_create	addr_out,#wd_create_form,#-1,#0,#0,#0	; Boite de dialogue pour demander un nouvel arbre
	rts
	bss
new_arbre_pointeur		ds.l	1
new_arbre_window_offset		ds.l	1
	text
oups
	form_alert	#1,#Ressoucre_non_trouve
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*L'utilisateur a edit‚ la fenetre NEW_ARBRE et appuiy‚ sur le bouton OK... on cree donc nouvel
*arbre dans le ressource point‚ par new_arbre_pointeur
fenetre_enter_name
	cmp.w		#ENTER_NAME_OK,d1
	beq		.suite
	rts
.suite
	xobjc_change	ENTER_NAME_adr,#ENTER_NAME_OK
	move.l		new_arbre_pointeur,a5
	lea		mrsc_ptr(a5),a4
	move.l		mrsc_ptrnbr(a5),d0
	cmp.l		#nbr_of_tree,d0
	blt		.suite_no_err
	illegal		; Il manque de la place pour les arbre. Si on arrive ici, alors je modifirais le "EQU"
.suite_no_err
	move.l		d0,d6
	lea		(a4,d0.l*4),a4		; on cherche de la place vide dans les pointeurs d'arbre
	add.l		#1,mrsc_ptrnbr(a5)

	xmalloc		#mtree_size
	move.l		d0,(a4)
	move.l		d0,a4	; a4 et a3 pointent sur l'espace mememoire du nouvel arbre
	move.l		d0,a3

* Note : c'est ICI qu'il faut changer les donnees en fonction du type d'arbre selectionne dans
* la boite ENTER_NAME (en rajoutant un test...)
	add.l		#mtree_objets,a3

* Recopie du formulaire correspondant au type d'arbre selectionne
	rsrc_gaddr	#0,#ENTER_NAME
	trouve_objc	addr_out,#RB_DIALOG
	btst		#SELECTED,ob_states+1(a0)
	bne		.dial_slelected

	trouve_objc	addr_out,#RB_MENU
	btst		#SELECTED,ob_states+1(a0)
	bne		.menu_slelected
*------------------------- Cas de la boite d'alerte -------------------------*
.alert_selected
	move.l		#rptt_alrt,mtree_type(a4)
	lea		default_alert_box,a0
.cp_alrt
	move.b		(a0)+,(a3)+
	bne		.cp_alrt
	bra		.end_cp_default
*------------------------- Cas du menu deroulant -------------------------*
.menu_slelected
	move.l		#rptt_menu,mtree_type(a4)
	rsrc_gaddr	#0,#NEW_MENU_DEFAULT
	move.l		addr_out,a0
.loop_cp_newmenu

	move.w		#5,d0
.cp_obj
	move.l		(a0)+,(a3)+
	dbf		d0,.cp_obj
	lea		-24(a3),a1
	objc_real	a1
	btst		#LASTOB,ob_flags+1(a1)
	beq		.loop_cp_newmenu
	bra		.end_cp_default

*------------------------- Cas du dialogue -------------------------*
.dial_slelected
	move.l		#rptt_dial,mtree_type(a4)
	rsrc_gaddr	#0,#NEW_DIAL_DEFAULT	; on recopi un objet BOX pour initialiser le dialogue.
	move.l		addr_out,a0
	rept		6
	move.l		(a0)+,(a3)+
	endr

*------------------------- Cas du menu deroulant -------------------------*
* Update de la liste d'arbre
.end_cp_default
	lea		mrsc_tree_list(a5),a6
	add.l		#wd_objc_header_size,a6		; on cherche une place vide
	mulu.l		#wd_objc_struct_size,d6
	add.l		d6,a6				; dans la structure des donnes de la fennetre

* on recopie l'icone dans la fenetre W_OBJET en fonction de ce qui a ete rentre dans le formulaire
	rsrc_gaddr	#0,#ENTER_NAME
	move.l		addr_out,wd_objc_form(a6)		; adresse du formulaire ou trouver l'icone
	trouve_bouton_precedent	#RB_MENU,addr_out
	move.w		d0,wd_objc_icon(a6)			; index de l'icone
	give_txt_adr	addr_out,#ED_ARBRE_LABEL		; adresse de l'editable du dialogue dans a0
	string_copy	a0,a4
	move.l		a4,wd_obcj_string(a6)			; texte de l'icone

	clr.l		wd_objc_struct_size(a6)			; effacement de la zone d'icone suivante

	wd_close	ENTER_NAME_adr
	move.l		new_arbre_window_offset,d7
	wd_redraw	d7
	rts
****************************************************************************************
****************************************************************************************
****************************************************************************************
* Demande un file selector, puis ouvre un ressource en remplissant les pointeurs et
* et faisant des Malloc.
* Note : le fichier est d'abbord charge dans une memoire temporaire, puis est decoupe
* en plein de Malloc, puis le 1er bloc est efface.
****************************************************************************************
****************************************************************************************
****************************************************************************************
_open_ressource_file
	string_copy	#fsel_init_string,#openrsc_path
	file_select	#openrsc_path,#fsel_open_texte
	tst.w		d0
	beq		.suite
	rts
.suite
	graf_mouse	#BUSY_B
	charge_ressource	#openrsc_path
	tst_rts
	move.l		d0,d6			; d6 = adresse de base du ressource

	move.l		d0,a5
	cmp.l		#"DLMN",(a5)	; nouveau format Dolmen ou ancien TOS ?
	beq		.newformat

	XREF		oldload
	jsr		oldload
	bra		load_labels

	XREF		newload
.newformat
	move.l		a5,-(sp)
	jsr		newload
	addq.l		#4,sp

* Trouve le fichier HRD associe a un ressource et appel la routine de chargement les labels
* si il existe un ficher HRD du meme nom a cote du fichier ressource
load_labels
	move.l		d0,a5		; adresse de la structure mrsc renvoye par newload/oldload
	string_copy	#openrsc_path,#hrd_path
	lea		hrd_path,a6
.lp_find_end
	tst.b		(a6)+
	bne		.lp_find_end

.lp_find_ext
	cmp.b		#".",-(a6)
	bne		.lp_find_ext

	addq.l		#1,a6
	move.b		#"H",(a6)+
	move.b		#"R",(a6)+
	move.b		#"D",(a6)+

	move.w		#0,-(sp)
	move.l		#hrd_path,-(sp)
	move.w		#$4e,-(sp)	; fsfirst : y a-t-il un fichier HRD attache ?
	trap		#1
	addq.l		#8,sp

	tst.w		d0
	bmi		.no_hrd

	move.l		#hrd_path,-(sp)
	move.l		a5,-(sp)
	XREF		hrd_load
	jsr		hrd_load
	addq.l		#8,sp

.no_hrd
	graf_mouse	#ARROW

	rts
	bss
hrd_path	ds.b	1024
	text
****************************************************************************************
	text
sauve_ressource
	ifnd	DEMO
* Une fenetre est au 1er plan ?
	move.w		d1,d3
	move.w		#10,int_in+2
	aes		104			; ben ca, c'est le wind_get...
	tst.w		d0			; erreur ? (pas de fenetre d'ouverte...)
	bne		.suite
	bra		.ressource_ouca_en_mem
.suite
;	move.w		ap_id,d0
;	cmp.w		int_out+4,d0		; il sagit de notre apli ?
;	bne		.suite2			; ne marche que sous l'AES 4.0...
;	rts
;.suite2
	moveq.l		#0,d7
	move.w		int_out+2,d7
	find_tab_w	#tab_handle,d7		; quel est l'ofset dans les tableaux ?
	cmp.w		#-1,d0
	bne		.suite3
	bra		.ressource_ouca_en_mem
.suite3
	move.w		d0,d6	; l'index de la fenetre->d6
	get_tab		#tab_adr,d6
	move.l		d0,d5
	get_tab		#tab_type,d6
	move.l		d0,d4

	cmp.l		#wd_create_drag_window,d4
	beq		.fenetre_de_type_drag
	cmp.l		#wd_create_objet,d4
	beq		.fenetre_de_type_objet
	bra		.ressource_ouca_en_mem

* Si on trouve une fenetre de type drag au 1er plan, alors on cherche le fichier
* ressource correspondant.
.fenetre_de_type_drag
	lea		rsc_files,a6
	tst.l		(a6)
	beq		.ressource_ouca_en_mem
.boucle_cherche_resource_a_sauver
	move.l		(a6)+,a5
	add.l		#mrsc_ptr,a5
.boucle_est_ce_ce_ressource
	move.l		(a5)+,d0
	add.l		#mtree_objets,d0
	cmp.l		d0,d5
	beq		.ressource_trouve
	tst.l		(a5)
	bne		.boucle_est_ce_ce_ressource
	tst.l		(a6)
	bne		.boucle_cherche_resource_a_sauver

.ressource_ouca_en_mem
	rsrc_gaddr	#15,#RSC_NOT_FIND
	move.l		addr_out,a4
	add.l		#4,a4
	form_alert	#1,a4
	rts

* Pareil que pour les fenetre drag mais avec des structures differentes
.fenetre_de_type_objet
	lea		rsc_files,a6
.boucle_cherche_resource_a_sauver2
	move.l		(a6)+,a5
	add.l		#mrsc_tree_list,a5
	cmp.l		a5,d5
	beq		.ressource_trouve
	tst.l		(a6)
	bne		.boucle_cherche_resource_a_sauver2
	bra		.ressource_ouca_en_mem

****************************************************************************************
****************************************************************************************
****************************************************************************************
*------------------------------------------------------------------------------------*
* Le ressource est donc pointe par a6-4. Reste plus qu'a le sauver.
.ressource_trouve

	graf_mouse	#BUSY_B
	move.l		-4(a6),a6

	tst.l		mrsc_ptrnbr(a6)
	beq		.pas_de_tree_a_sauver


* Lancement de la preparation du fichier a sauvegarde au format demande (Dolmen ou Tos)
	move.l		a6,-(sp)

	cmp.w		#M_EXPORT,d3
	bne		.suite_sauve_r

	XREF		save_atari_format
	jsr		save_atari_format

	bra		.end_sauve_r
.suite_sauve_r

	XREF		save_dolmen_format
	jsr		save_dolmen_format

.end_sauve_r

	addq.l		#4,sp

* Demande de file-selector et sauvegarde
	move.l		a0,a4
	move.l		d0,d6
	addq.l		#1,d6
	and.l		#$fffffffe,d6

	graf_mouse	#ARROW
	file_select	#save_yop_file,#commentaire_de_sauvegarde
	graf_mouse	#BUSY_B

	Fcreate		#0,#save_yop_file
	move.w		d0,d5
	Fwrite		a4,d6,d5
	Fclose		d5
	Mfree		a4

* Fabrique un HRD si l'option est cochee dans la boite pref
	rsrc_gaddr	#0,#PREF
	trouve_objc	addr_out,#PREF_B_HRD
	btst		#SELECTED,ob_states+1(a0)
	beq		.no_hrd_save

	lea		save_yop_file,a0
.lp_find_extention
	tst.b		(a0)+
	bne		.lp_find_extention
	subq.l		#1,a0

	move.b		#"D",-(a0)
	move.b		#"R",-(a0)
	move.b		#"H",-(a0)

	move.l		#save_yop_file,-(sp)
	move.l		a6,-(sp)
	XREF		hrd_save
	jsr		hrd_save
	addq.l		#8,sp

.no_hrd_save

	rsrc_gaddr	#0,#PREF
	trouve_objc	addr_out,#PREF_B_ASM
	btst		#SELECTED,ob_states+1(a0)
	beq		.no_asm_save

	XREF		save_4_inc
	move.l		#save_frmt_asm,-(sp)
	move.l		#".S"<<16,-(sp)
	move.l		#save_yop_file,-(sp)
	move.l		a6,-(sp)
	jsr		save_4_inc
	lea		16(sp),sp

.no_asm_save

	rsrc_gaddr	#0,#PREF
	trouve_objc	addr_out,#PREF_B_GFA
	btst		#SELECTED,ob_states+1(a0)
	beq		.no_gfa_save

	XREF		save_4_inc
	move.l		#save_frmt_gfa,-(sp)
	move.l		#".LST",-(sp)
	move.l		#save_yop_file,-(sp)
	move.l		a6,-(sp)
	jsr		save_4_inc
	lea		16(sp),sp

.no_gfa_save

	rsrc_gaddr	#0,#PREF
	trouve_objc	addr_out,#PREF_B_C
	btst		#SELECTED,ob_states+1(a0)
	beq		.no_c_save

	XREF		save_4_inc
	move.l		#save_frmt_c,-(sp)
	move.l		#".H"<<16,-(sp)
	move.l		#save_yop_file,-(sp)
	move.l		a6,-(sp)
	jsr		save_4_inc
	lea		16(sp),sp

.no_c_save



	graf_mouse	#ARROW
	endc
	rts
*------------------------------------------------------------------------------------*
	rts
.pas_de_tree_a_sauver
	form_alert	#1,#ereurum_batatestum
	rts
*------------------------------------------------------------------------------------*
	bss
openrsc_path		ds.b	1024
	data
	even
save_yop_file	dc.b	"E:\*.RSC",0
		ds.b	1024
	even
save_frmt_asm	dc.b	"%l",9,"EQU",9,"%v",9,"; %c",0
save_frmt_c	dc.b	"#define %l %v",9,"/* %c */",0
save_frmt_gfa	dc.b	"LET %l&=%v ! %c",0
	even
