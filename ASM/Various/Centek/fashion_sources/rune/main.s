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

	include	rune.s

* Mon ressource
	XREF	rsc_name

* Messages d'erreurs
	XREF	quitage_fichier_non_trouve

* Quelques XREF pour la lib
	XREF	wd_create_drag_window	; mon type de fenetre invent‚ pour Fashion !
	XREF	evnt,wd_create_form,hauteur_menu,opt_num,opt_arbre,x_max,y_max
	XREF	mouse_moved,tab_handle,tab_adr,x_mouse_clik,y_mouse_clik
	XREF	root_window

* Les XDEF du source principale
	XDEF	options				; special fenetre formulaire et menu !
	XDEF	FILEBROWS_adr
	text
*--------------------------------------------------------------------------------------------------------------------------*
vive_le_dolmen
	GEMDOSinit	30000
	AESVDIinit

*--------------------------------------------------------------------------------------------------------------------------*
* Mise en place des chemin des fichiers dont j'ai besoin
	shel_find	#rsc_name

*--------------------------------------------------------------------------------------------------------------------------*
	ZLIBinit	#rsc_name,#MENU	; chargement ressource, affichage menu

	xaloc_init	#512*1024,#1024*1024*2

;	XREF		_INSTALL_LUT
;	jsr		_INSTALL_LUT

* Initialisations de quelques variables du soft *

* Mise en place du formulaire de la fenetre 0 *
	rsrc_gaddr	#0,#ROOT
	move.l		addr_out,a6
	move.l		a6,ROOT_adr
	move.w		x_max,ob_w(a6)
	move.w		y_max,d0
	sub.w		hauteur_menu,d0
	move.w		d0,ob_h(a6)
	move.w		#0,ob_x(a6)
	move.w		hauteur_menu,ob_y(a6)

	move.l		#$0000000e,int_in
	move.l		a6,int_in+4
	move.w		#0,int_in+8
	move.w		#20,int_in+10
	aes		105

	trouve_objc	a6,#ROOT_BACKPATERN
	move.w		x_max,ob_w(a0)
	move.w		y_max,d0
	sub.w		hauteur_menu,d0
	move.w		d0,ob_h(a0)
	move.w		#0,ob_x(a0)
	move.w		#0,ob_y(a0)

	form_dial	#3,#0,#0,x_max,y_max,#0,#0,x_max,y_max

* Initialisation du formulaire pour les fenetre du file-browser
	rsrc_gaddr	#0,#FILEBROWS
	move.l		addr_out,a6
	move.l		a6,FILEBROWS_adr	; recupere l'adresse du formulaire des fenetres du FB

	trouve_objc	a6,#BROWS_PIX
	move.l		#brows_gpix_bk,ob_spec(a0)
	move.w		#G_PIX,ob_type(a0)

	trouve_objc	a6,#BROWS_BOUND
	move.l		#filebrows_bounding,ob_spec(a0)
	move.w		#G_BOUNDING,ob_type(a0)
	move.w		#100,filebrows_bounding+gbo_depth
	clr.w		filebrows_bounding+gbo_first

	data
* Definition du GPIX background (fond de fenetre par default)
brows_gpix_bk
bgpb_path	dc.l	brows_back_path
bgpb_list	dc.l	0
bgpb_ptr	dc.l	0
bgpb_x		dc.l	0
bgpb_y		dc.l	0
bgpb_flag	dc.l	%11
	text
*--------------------------------------------------------------------------------------------------------------------------*
* Affichage de la sourie, mise en place du vecteur de clic dans la fenetre root
	move.l		#fond_de_bureau,root_window
	graf_mouse	#0
	jmp		evnt
*--------------------------------------------------------------------------------------------------------------------------*
options
	move.l	opt_arbre,d0
	move.w	opt_num,d1
	cmp.l	MENU_adr,d0
	beq	menu_deroulant
	cmp.l	ROOT_adr,d0
	beq	fond_de_bureau
	rts
*--------------------------------------------------------------------------------------------------------------------------*
fond_de_bureau
	objc_find	ROOT_adr,#0,#100,x_mouse_clik,y_mouse_clik
	move.w		d0,d7	; numero de l'objet ou on a clike
	XREF	n_mouse_clik
	cmp.w	#2,n_mouse_clik
	beq	double_clik
	rts
double_clik
	cmp.w	#ROOT_U,d7
	beq	.ok
	rts
.ok
	XREF	brows_new
	move.l	#brows_path,-(sp)
	jsr	brows_new
	addq.l	#4,sp
	rts
	data
brows_path	dc.b	"E:\*.*",0
*--------------------------------------------------------------------------------------------------------------------------*
	text
menu_deroulant
	cmp.w	#M_QUIT,d1
	beq	quitter
	rts
quitter
	XREF	gem_exit
	jsr	gem_exit
	clr.w	-(sp)
	trap	#1

	rts
*--------------------------------------------------------------------------------------------------------------------------*
	data
ROOT_adr	ds.l	1
FILEBROWS_adr	ds.l	1
*--------------------------------------------------------------------------------------------------------------------------*
*****************************************************
*** Variables determinant les preferences du soft ***
*****************************************************
	XDEF	display_sec,last_fb_state,last_fb_tri
pref_start
display_sec	dc.w	0	; afficher seconde lorsqu'on affiche l'heure d'un fichier
last_fb_state	dc.w	%1110	; derniere modification d'un etat de fenetre
last_fb_tri	dc.w	0	; dernier tri chosi pour une fenetre
brows_back_path	dc.b	"D:\RUNE\PIX\FOND.GIF",0
back_path_end	ds.b	1024-(back_path_end-brows_back_path)

pref_end
*--------------------------------------------------------------------------------------------------------------------------*
	bss
filebrows_bounding	ds.l	sizeof_gbo
*--------------------------------------------------------------------------------------------------------------------------*
**** Quelques variables **********************************************
	data
	XDEF	dragndrop_extentions
	even
dragndrop_extentions	dc.b	'.RSC'
			dc.b	0
	XDEF	appl_name
appl_name	dc.b	" RUNE v0.0.1 ",0
	even
	bss
