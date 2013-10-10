*--------------------------------------------------------------------------------------------------------------------------*
* Reste a faire :
*----------------
*-* Debogage complet
*-* gestion des labels
*-* optimisation du gestionnaire de memoire pour qu'il teste le bloc de fin en 1er
*-* xaloc_free dans routine d'effacement
*-* edition de la taille des fontes
*-* edition du type de fontes (AES 4.10)
*-* [control] pour selectionne un objet sous un autre
*-* form_alert editor
*-* demallocage lors d'une fermeture de fenetre liste d'arbre
*-* Selection multiple des objet (comme dans interface avec [ALT])
*-* malloc quand plus de place dans le gestionnaire de memoire (optimisation de la taille du gros bloc)
*-* Sauvegarde et import des labels
* Sauvegarde du commentaire dans le HRD
* gestion des G_BOUDING/G_BOUNDED
* chargement d'image dans les icones
* clipping sur l'ecran lors de la copie
* fonction de DEPLACEMENT d'objet
* deplacement de tous les objets en meme temps
* copie de plusieurs objet en meme temps
* copie d'un arbre entier
* Une doc correcte en anglais ET en francais, ainsi qu'une version anglaise du soft
* Fermer la fenetre d'edition de label quand l'objet edite est efface
* G_GOURAUD
* Reduire la taille que prend un alert en memoire
* Revoir les racoucis dans les menus
* editable en fenetre comme il faut
* gestion du slider dans la fenetre arbre
* Ne pas recharger une G_PIX si elle n'a pas changer
* Realignement automatique du texte dans l'edition de menu
* Quand on sort de la fenetre d'edition de label, verifier qu'on edite pas la fenetre ROOT
*--------------------------------------------------------------------------------------------------------------------------*
	text
	XDEF	START
START
	bra	vive_le_dolmen

	include	gemdos.i
	include	vdi.i
	include	aes.i
	include	zlib.i

	include	tosinit.i
	include	structs.s
	include	util.i

	include	memory.s
	include	fashion.s
* Mon ressource
	XREF	rsc_name

* Quelques XREF provenant des autres sources
	XREF	temp_gpix_img

* Des XREF pour les autre fenetre que la fenetre principale
	XREF	load_toolbar_rsc_file,menu_deroulant,edition_menu
	XREF	fenetre_enter_name,color_window,flag_window,tedinfo_window,wd_create_form_n_menu
	XREF	label_window,gline_window,form_alert_editor
	XREF	make_fonte_list

* Messages d'erreurs
	XREF	quitage_fichier_non_trouve

* Quelques XREF pour la lib
	XREF	wd_create_drag_window	; mon type de fenetre invent‚ pour Fashion !
	XREF	evnt,wd_create_form,hauteur_menu,opt_num,opt_arbre,x_max
	XREF	mouse_moved,tab_handle,tab_adr,x_mouse_clik,y_mouse_clik

* Les XDEF du source principale
	XDEF	options				; special fenetre formulaire et menu !
	XDEF	ed_sel_win,ed_sel_objc
	XDEF	rsc_files,init_x,init_y
	XDEF	MAIN_adr,ENTER_NAME_adr,PREF_adr,INFO_adr,COLOR_adr,FLAG_adr
	XDEF	TEDINFO_adr,LABEL_adr,TOOL_BOX_adr,EDIT_MENU_adr
	XDEF	grid_origin_x,grid_origin_y
	XDEF	FNT_LIST_adr,FORM_ALERT_adr
	text
*--------------------------------------------------------------------------------------------------------------------------*
vive_le_dolmen
	GEMDOSinit	30000
	AESVDIinit
;	TOSinit	30000	; 30k de pile, inits AES + VDI

;* Test du gestionnaire de memoire *
;	XREF	xaloc_debug_rout
;	jmp	xaloc_debug_rout


*--------------------------------------------------------------------------------------------------------------------------*
* Mise en place des chemin des fichiers dont j'ai besoin
	XREF		tool_bar_path
	shel_find	#temp_gpix_img
	shel_find	#tool_bar_path
	shel_find	#rsc_name

*--------------------------------------------------------------------------------------------------------------------------*
	ZLIBinit	#rsc_name,#MENU	; chargement ressource, affichage menu

	xaloc_init	#512*1024,#1024*1024*2

	Fopen		#0,#temp_gpix_img
	move.l		d0,d7
	Fseek		#2,d7,#0
	move.l		d0,d6
	Fclose		d7

	cmp.l		#564,d6
	beq		noproblemo

	form_alert	#1,#moderonan

	jsr		gem_exit
	clr.w		-(sp)
	trap		#1
	data
moderonan	dc.b	"[3][La G_PIX defaut n'est pas bonne|mode Ronan enclenche][ Quitation ]",0
	text
noproblemo

	XREF		_INSTALL_LUT
	jsr		_INSTALL_LUT

* Initialisations de quelques variables du soft *
	clr.l		ed_sel_win
	move.l		#-1,ed_sel_objc	; pas d'objet selectionne

	rsrc_gaddr	#0,#MAIN
	move.l		addr_out,MAIN_adr
	wd_create	addr_out,#wd_create_form,#0,hauteur_menu,#0,#0

	move.l		MAIN_adr,a0
	move.w		ob_w(a0),d0		; coordonnee d'initialisation en X pour la fennetre
	move.w		d0,init_x		; d'un ressource.
	move.w		ob_h(a0),d0		; pareil pour les Y
	add.w		ob_y(a0),d0
	move.w		d0,init_y

* On charge le fichier rsc de la toolbar
	jsr		load_toolbar_rsc_file
	tst.l		d0
	bge		fichier_toolbox_rsc_trouve

	form_alert	#1,#quitage_fichier_non_trouve		; on demande confirmation, puis on quite
	jsr		gem_exit
	clr.w		-(sp)
	trap		#1
fichier_toolbox_rsc_trouve
* Puis on ouvre la fenetre toolbar
	move.l		d0,TOOL_BOX_adr
	wd_create	d0,#wd_create_drag_window,init_x,hauteur_menu,#0,#0

	jsr		make_fonte_list

*--------------------------------------------------------------------------------------------------------------------------*
* Affichage de la sourie, mise en place du vecteur de deplacement de la sourie, et lancement de la lib
	graf_mouse	#0
	move.l		#moved_mouse,mouse_moved
	jmp		evnt
*--------------------------------------------------------------------------------------------------------------------------*
* Quand la sourie bouge, on reaffiche les coordonnees de l'objet en dessous
moved_mouse
	wind_find	x_mouse_clik,y_mouse_clik
	find_tab_w	#tab_handle,d0
	cmp.w		#-1,d0
	beq		.end_moved
	move.w		d0,d7
	get_tab		#tab_type,d7
	cmp.l		#wd_create_drag_window,d0
	bne		.end_moved
	get_tab		#tab_adr,d7
	move.l		d0,a6		; a6 = adresse de la fenetre sous la sourie
	objc_find	d0,#0,#100,x_mouse_clik,y_mouse_clik
	cmp.w		#-1,d0
	beq		.end_moved
	move.w		d0,d6		; d6 = numero du bouton sous la sourie

	cmp.l		moused_window,a6
	bne		.suite_moused
	cmp.w		moused_object,d6
	beq		.end_moved
.suite_moused
	move.w		d6,moused_object
	move.l		a6,moused_window

	trouve_objc	a6,d6
	move.l		a0,a5		; a5 = adresse de l'objet
	rsrc_gaddr	#0,#MAIN
	move.l		addr_out,a4	; a4 = adresse du formulaire "MAIN"
	objc_offset	a6,d6
	moveq.l		#0,d4
	moveq.l		#0,d5
	move.w		int_out+2,d4
	move.w		int_out+4,d5
	sub.w		ob_x(a6),d4
	sub.w		ob_y(a6),d5
	give_txt_adr	a4,#MAIN_XPOSROOT
	long_2_chaine	d4,a0,#5
	give_txt_adr	a4,#MAIN_YPOSROOT
	long_2_chaine	d5,a0,#5

	move.w		ob_x(a5),d4
	move.w		ob_y(a5),d5
	give_txt_adr	a4,#MAIN_XPOSREL
	long_2_chaine	d4,a0,#5
	give_txt_adr	a4,#MAIN_YPOSREL
	long_2_chaine	d5,a0,#5

	move.w		ob_w(a5),d4
	move.w		ob_h(a5),d5
	give_txt_adr	a4,#MAIN_WPOS
	long_2_chaine	d4,a0,#5
	give_txt_adr	a4,#MAIN_HPOS
	long_2_chaine	d5,a0,#5

	give_txt_adr	a4,#MAIN_NUMOBJ
	long_2_chaine	d6,a0,#3
	moveq.l		#0,d6
	move.b		ob_type(a5),d6
	give_txt_adr	a4,#MAIN_OBTYPE
	long_2_chaine	d6,a0,#3

	redraw_objc	a4,#MAIN_CORDS

.end_moved
	rts
	data
moused_window	dc.l	-2
moused_object	dc.w	-2
	text
*--------------------------------------------------------------------------------------------------------------------------*
options
	move.l	opt_arbre,d0
	move.w	opt_num,d1
	cmp.l	MAIN_adr,d0
	beq	main_window_options
	cmp.l	MENU_adr,d0
	beq	menu_deroulant
	cmp.l	ENTER_NAME_adr,d0
	beq	fenetre_enter_name
	cmp.l	COLOR_adr,d0
	beq	color_window
	cmp.l	FLAG_adr,d0
	beq	flag_window
	cmp.l	TEDINFO_adr,d0
	bne	.suite1
	jmp	tedinfo_window
.suite1
	cmp.l	LABEL_adr,d0
	beq	label_window
	cmp.l	EDIT_MENU_adr,d0
	bne	.suite2
	jmp	edition_menu
.suite2
	cmp.l	LINE_adr,d0
	beq	gline_window
	cmp.l	FORM_ALERT_adr,d0
	beq	form_alert_editor
	rts

*--------------------------------------------------------------------------------------------------------------------------*
**** Fenetre principale **********************************************
main_window_options
	cmp.w	#MAIN_FLAG,d1
	beq	ouvre_fenetre_flag
	cmp.w	#MAIN_COLOR,d1
	beq	ouvre_fenetre_color
	cmp.w	#MAIN_FONTE,d1
	beq	ouvre_fenetre_tedinfo
	cmp.w	#MAIN_FLECHE,d1
	beq	ouvre_gline_edit
	rts
ouvre_gline_edit
	rsrc_gaddr	#0,#LINE_EDITOR
	move.l		addr_out,LINE_adr
	wd_create	addr_out,#wd_create_form,#0,init_y,#0,#0
	xobjc_change	MAIN_adr,#MAIN_FLECHE
	rts

ouvre_fenetre_tedinfo
	rsrc_gaddr	#0,#TEDINFO_EDIT
	move.l		addr_out,TEDINFO_adr
	move.w		x_max,d0
	move.l		addr_out,a0
	sub.w		ob_w(a0),d0
	wd_create	addr_out,#wd_create_form,d0,hauteur_menu,#0,#0
	xobjc_change	MAIN_adr,#MAIN_FONTE
	rts
ouvre_fenetre_color
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	move.l		addr_out,COLOR_adr
	wd_create	addr_out,#wd_create_form,#0,init_y,#0,#0
	xobjc_change	MAIN_adr,#MAIN_COLOR
	rts
ouvre_fenetre_flag
	rsrc_gaddr	#0,#FLAG
	move.l		addr_out,FLAG_adr
	wd_create	addr_out,#wd_create_form,init_x,hauteur_menu,#0,#0
	xobjc_change	MAIN_adr,#MAIN_FLAG
	rts
*--------------------------------------------------------------------------------------------------------------------------*
**** Quelques variables **********************************************
	data
	XDEF	inter
	even
inter	incbin	"d:\fashion\test.rsc\label.rsc"
	XDEF	dragndrop_extentions
	even
dragndrop_extentions	dc.b	'.RSC'
			dc.b	0
	XDEF	appl_name
appl_name	dc.b	" FASHION v0.62.7 ",0
	even

rsc_files	ds.l	256	; 256 fichiers ressources ouverts en meme temps... ca en fait des malloc !
	even
MAIN_adr	ds.l	1
TOOL_BOX_adr	ds.l	1
ENTER_NAME_adr	ds.l	1
PREF_adr	ds.l	1
INFO_adr	ds.l	1
COLOR_adr	ds.l	1
FLAG_adr	ds.l	1
TEDINFO_adr	ds.l	1
LABEL_adr	ds.l	1
EDIT_MENU_adr	ds.l	1
LINE_adr	ds.l	1
FNT_LIST_adr	ds.l	1
FORM_ALERT_adr	ds.l	1

grid_origin_x	ds.w	1
grid_origin_y	ds.w	1
	bss
init_x		ds.w	1
init_y		ds.w	1

form_n_menu	ds.l	2

*--------------------------------------------------------------------------------------------------------------------------*
***** L'etat du logiciel est la :
ed_sel_win	ds.l	1		; represente la fenetre et la liste d'objet
ed_sel_objc	ds.w	nbr_of_objc	; que le logiciel est en train d'editer
