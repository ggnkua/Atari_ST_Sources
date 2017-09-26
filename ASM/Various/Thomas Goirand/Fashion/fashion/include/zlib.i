******************************************************
*** Fichier d'inclusion de ZLIB                    ***
*** Contient toutes les macros internes et externe ***
*** a ZLIB.                                        ***
******************************************************
MAX_WD	equ	50	; nombre de fenetre gere au maximum par ces routines (ocupation memoire = 40*MAX_WD)

***********************************************
*** Charge un ressource et installe le menu ***
***********************************************
ZLIBinit	macro	; rsc_pathname,menu_tree_index
	XDEF		MENU_adr
	XREF		gem_exit
	rsrc_load	\1
	tst.w		int_out
	bne		ZINIT_resource_loaded
	form_alert	#1,#rsc_absent_sur_disk		; on demande confirmation, puis on quite
	jsr		gem_exit
	clr.w		-(sp)
	trap		#1
ZINIT_resource_loaded
	rsrc_gaddr	#0,\2
	move.l		addr_out,MENU_adr
	menu_bar	addr_out,#1
* Une petite boucle indispensable si on veut mettre le bit de fast-load !
	XREF		tab_type
	lea		tab_type,a0
	XREF		tab_key
	lea		tab_key,a1
	move.l		#MAX_WD,d0
ZINIT_loop
	clr.l		(a0)+
	clr.l		(a1)+
	subq.l		#1,d0
	bne		ZINIT_loop
	data
rsc_absent_sur_disk	dc.b	"[3][Ressource non|trouver sur|le disque.][ Quitter ]",0
	bss
MENU_adr		ds.l	1
	text
	endm

get_tab	macro	; lignetab,ofset	; renvois une donnee dans d0
	move.l	a0,-(sp)
	move.l	\1,a0
	move.w	\2,d0
	lsl	#2,d0
	add.w	d0,a0
	move.l	(a0),d0
	move.l	(sp)+,a0
	endm

put_tab_l	macro	; lignetab,ofset,donnee	; place une donnee en long dans le tableau
	ifnd	pub_tab_l_routine
	XREF	put_tab_l_routine
	endc
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	jsr	put_tab_l_routine
	lea	10(sp),sp
	endm

put_tab_w	macro	; lignetab,ofset,donnee	; place une donnee en word dans le tableau
	ifnd	pub_tab_w_routine
	XREF	put_tab_w_routine
	endc
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	jsr	put_tab_w_routine
	addq.l	#8,sp
	endm

find_tab_w	macro	; lignetab,donnee		; retour dans d0, -1 si erreur
	ifnd	find_tab_w_routine
	XREF	find_tab_w_routine
	endc
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	find_tab_w_routine
	addq.l	#6,sp
	endm

find_tab_l	macro	; lignetab,donnee		; retour dans d0, -1 si erreur
	ifnd	find_tab_l_routine
	XREF	find_tab_l_routine
	endc
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	find_tab_l_routine
	addq.l	#8,sp
	endm

trouve_objc	macro	; adr_tree,index
	ifnd	trouve_objc_routine
	XREF	trouve_objc_routine
	endc
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	trouve_objc_routine
	addq.l	#6,sp
	endm

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*******************************
**** deselectionne un objet ***
*******************************
select	macro	; formulaire_adr,objet_index
	movem.l	d0/a0,-(sp)
	trouve_objc	\1,\2
	add.l	#ob_states,a0
	move.w	(a0),d0
	bset	#0,d0
	move.w	d0,(a0)
	movem.l	(sp)+,d0/a0
	endm
*****************************
**** selectionne un objet ***
*****************************
deselect	macro	; formulaire_adr,objet_index
	movem.l	d0/a0,-(sp)
	trouve_objc	\1,\2
	add.l	#ob_states,a0
	move.w	(a0),d0
	bclr	#0,d0
	move.w	d0,(a0)
	movem.l	(sp)+,d0/a0
	endm

********************************************************************
**** selectionne ou deselectionne un objet et demande son redraw ***
********************************************************************
xobjc_change	macro	; adresse_arbre,index_objc
	ifnd	change_objc_routine
	XREF	change_objc_routine
	endc
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	change_objc_routine
	addq.l	#6,sp
	endm

********************************************
*** grise un objet et demande son redraw ***
********************************************
xobjc_grise	macro	; adresse_arbre,index_objc
	XREF	grise_objc_routine
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#0,-(sp)
	jsr	grise_objc_routine
	addq.l	#8,sp
	endm

**********************************************
*** degrise un objet et demande son redraw ***
**********************************************
xobjc_degrise	macro	; adresse_arbre,index_objc
	XREF	grise_objc_routine
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#1,-(sp)
	jsr	grise_objc_routine
	addq.l	#8,sp
	endm

**************************
*** redessine un objet ***
**************************
redraw_objc	macro	; adresse_arbre,num_objc
	ifnd	redraw_objc_routine
	XREF	redraw_objc_routine
	endc
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	redraw_objc_routine
	addq.l	#6,sp
	endm

**************************
*** redessine un objet ***
**************************
redraw_objc_gem	macro	; adresse_arbre,num_objc
	ifnd	redraw_objc_gem_routine
	XREF	redraw_objc_gem_routine
	endc
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	redraw_objc_gem_routine
	addq.l	#6,sp
	endm

******************************************
*** redessine une partie d'une fenetre ***
******************************************
redraw_cords	macro	; handle_fenetre,x,y,w,h
	XREF	redraw_cords_rout
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	jsr	redraw_cords_rout
	lea	10(sp),sp
	endm

************************************************************************************
*** copie d'un chemin dans une chaine a partir d'une autre chaine pour affichage ***
************************************************************************************
affiche_chemin	macro	; adresse_chaine_source,adresse_chaine_destination
	XREF	affiche_chemin_routine
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	affiche_chemin_routine
	addq.l	#8,sp
	endm

*************************************************************
*** modifie sur demande l'un des bits du champs ob_states ***
*** d'un objet et commande un redraw sur l'objet en ques- ***
*** tion.                                                 ***
*************************************************************
state_bit_objc	macro	; adr_tree,index_objc,bit2change,mode
	XREF	state_bit_objc_routine
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	jsr	state_bit_objc_routine
	lea	10(sp),sp
	endm

*************************************************************
*** modifie sur demande l'un des bits du champs ob_flags  ***
*** d'un objet et commande un redraw sur l'objet en ques- ***
*** tion.                                                 ***
*************************************************************
flag_bit_objc	macro	; adr_tree,index_objc,bit2change,mode
	XREF	flag_bit_objc_routine
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	jsr	flag_bit_objc_routine
	lea		10(sp),sp
	endm

************************************************************
*** instale une boite de dialogue, puis fait un form_do. ***
*** Retabli le bouton de sortie de formulaire            ***
*** en sortie : d0 = bouton de sortie                    ***
************************************************************
dialogue	macro	; index_du_formulaire
	XREF	dialogue_routine
	movem.l	d1-a6,-(sp)
	move.w	\1,d7
	jsr	dialogue_routine
	movem.l	(sp)+,d1-a6
	endm

***************************************************
*** Donne l'adresse du texte de l'objet demande ***
***************************************************
*retour dans a0
give_txt_adr	macro	; adresse_arbre,index_objc
	XREF	give_txt_adr_routine
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	give_txt_adr_routine
	addq.l	#6,sp
	endm

*******************************************************************
*** Donne l'adresse du pointeur sur le texte de l'objet demande ***
*******************************************************************
* retour dans a0
give_txt_ptr	macro	; adresse_arbre,index_objc
	XREF	give_txt_ptr_routine
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	give_txt_ptr_routine
	add.l	#6,sp
	endm

***********************************************
*** Demande le redraw complet d'une fenetre ***
***********************************************
wd_redraw	macro	; offset
	XREF	wd_redraw_routine
	move.w	\1,-(sp)
	jsr	wd_redraw_routine
	addq.l	#2,sp
	endm

***********************************************
*** Demande le redraw complet d'une fenetre ***
***********************************************
wd_redraw_gem	macro	; offset
	XREF	wd_redraw_gem_routine
	move.w	\1,-(sp)
	jsr	wd_redraw_gem_routine
	addq.l	#2,sp
	endm

**************************************************
*** Permet la copy d'une chaine dans une autre ***
**************************************************
string_copy	macro	; adr1,adr2
	XREF	string_copy_routine
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	string_copy_routine
	addq.l	#8,sp
	endm

***************************
*** Concatene 2 chaines ***
***************************
string_concat	macro	; chaine_a_ajouter,chaine_ou_ajouter
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	XREF	string_concat_rout
	jsr	string_concat_rout
	addq.l	#8,sp
	endm

***************************************************************************
*** Renvois dans d0 la taille de la chaine (caractere 0 de fin compris) ***
***************************************************************************
string_size	macro	; adr
	XREF	string_size_routine
	move.l	\1,-(sp)
	jsr	string_size_routine
	addq.l	#4,sp
	endm

*******************************************************
*** Fait un malloc et efface la zone avec des zeros ***
*******************************************************
xmalloc	macro	; ammount
	XREF	xmalloc_routine
	move.l	\1,-(sp)
	jsr	xmalloc_routine
	addq.l	#4,sp
	endm

*******************************************************
*** Trouve l'objet parent a l'objet d'entree        ***
*******************************************************
* retour : d0 contient l'index du parent
trouve_parent	macro	; index_objet,adr_arbre
	ifnd	trouve_parent_routine
	XREF	trouve_parent_routine
	endc
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	jsr	trouve_parent_routine
	addq.l	#6,sp
	endm

******************************************************************
*** Macro servant pour les radios boutons : on cherche l'objet ***
*** selectionne avant le cilc sur un radio                     ***
******************************************************************
trouve_bouton_precedent	macro	; index_objet,adr_arbre
	XREF	trouve_bouton_precedent_routine
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	jsr	trouve_bouton_precedent_routine
	addq.l	#6,sp
	endm

************************************************************************
*** Macro de multiplication de 2 long mots. Crame d0 pour le retour, ***
*** retourne -1 si il y a depacement de capacite.                    ***
************************************************************************
xmul	macro	; reg1,reg2
	XREF	xmul_routine
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	xmul_routine
	move.l	d0,\2
	endm

***************************************************************************************
*** routine qui vat trouve la VRAI taille d'un objet en fonction de ses coordonnees ***
*** Pour l'instant, le fait qu'elargir la taille de 4 parametres...                 ***
***************************************************************************************
objc_size	macro	; adr_arbre,index_objet,adr_array
	ifnd	objc_size_rout
	XREF	objc_size_rout
	endc
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	jsr	objc_size_rout
	lea	10(sp),sp
	endm

********************************************************************************
*** ouvre une fenetre  : utilise d0                                          ***
********************************************************************************
wd_create	macro	; adr_donnee,adr_routine_creation,x,y,w,h
	XREF	wd_create_routine
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.w	\6,-(sp)
	jsr	wd_create_routine
	lea	16(sp),sp
	endm

**************************
*** Ferme une fenettre ***
**************************
wd_close	macro	; adr_donne		; ferme une fenetre ouverte. Parametre = adresse
	XREF	wd_close_routine
	move.l	\1,-(sp)
	jsr	wd_close_routine
	addq.l	#4,sp
	endm

*******************************************
*** Ferme une fenettre en la detruisant ***
*******************************************
wd_kill	macro	; adr_donne		; ferme une fenetre ouverte. Parametre = adresse
	XREF	wd_kill_routine
	move.l	\1,-(sp)
	jsr	wd_kill_routine
	addq.l	#4,sp
	endm

**********************************************
*** Effacement rapide d'une zone de donnee ***
**********************************************
clr_zone	macro	; adr,size
	XREF	clr_zone_rout
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	clr_zone_rout
	addq.l	#8,sp
	endm

*********************************************************
*** Deplacement "presque" optimiser d'un bloc memoire ***
*********************************************************
bloc_move	macro	; size,adr_source,adr_dest
	XREF	bloc_move_rout
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	jsr	bloc_move_rout
	lea	12(sp),sp
	endm

************************************************
*** Macro du gestionnaire de memoire interne ***
************************************************
xaloc_init	macro	; big_bloc_size,big_init_bloc_size
	XREF	xaloc_init_rout
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	xaloc_init_rout
	addq.l	#4,sp
	endm

*************************************************************
*** Alocation d'un bloc de memoire (gestionnaire interne) ***
*************************************************************
xaloc_aloc	macro	; size,adr_du_ptr_vers_le_1er_octet_du_bloc
	XREF	xaloc_aloc_rout
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	xaloc_aloc_rout
	addq.l	#8,sp
	endm

***********************************************************
*** Liberation d'un bloc memoire (gestionnaire interne) ***
***********************************************************
xaloc_free	macro	; adr_du_ptr_vers_le_1er_octet_du_bloc
	XREF	xaloc_free_rout
	move.l	\1,-(sp)
	jsr	xaloc_free_rout
	addq.l	#4,sp
	endm

*********************************************************************************************************
*** Fonction permettant l'enregistrement d'un nouveau pointeur vers une adresse apartenant a un bloc. ***
*** Si le bloc est deplacer, le pointeur vers ce bloc est automatiquement updater.                    ***
*** Pour ameliorer le rendement, on utilise un trie par insertion.                                    ***
*********************************************************************************************************
* Parametres : adresse du pointeur vers le bloc, ce pointeur etant rempli avec la bonne adresse
xaloc_addptr	macro	; adresse_pointeur
	XREF	xaloc_addptr_rout
	move.l	\1,-(sp)
	jsr	xaloc_addptr_rout
	addq.l	#4,sp
	endm

*********************************************************************************************
*** Fonction permettant de supprimer un pointeur vers une adresse dans un bloc en memoire ***
*********************************************************************************************
xaloc_supptr	macro	; adr_ptr
	XREF	xaloc_supptr_rout
	move.l	\1,-(sp)
	bsr	xaloc_supptr_rout
	addq.l	#4,sp
	endm

*********************************************************************************
*** Dit si un pointeur est principale ou non (0 = secondaire, 1 = principale) ***
*********************************************************************************
xaloc_is_main	macro	; adresse_ptr
	XREF	xaloc_is_main_rout
	move.l	\1,-(sp)
	bsr	xaloc_is_main_rout
	addq.l	#4,sp
	endm

*********************************************************************************
*** Permet d'informer le gestionnaire de memoire qu'on a deplacer un pointeur ***
*********************************************************************************
xaloc_moveptr	macro	; ancienne_adresse,nouvelle_adresse,adresse_pointe
	XREF	xaloc_moveptr_rout
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	jsr	xaloc_moveptr_rout
	lea	12(sp),sp
	endm

*****************************************************
*** Permet de changer la taille d'un bloc memoire ***
*****************************************************
xaloc_grow	macro	; nouvelle_taille,adresse_dun_pointeur
	XREF	xaloc_gow_rout
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	xaloc_gow_rout
	addq.l	#8,sp
	endm

****************************************************
*** Dessine un rectangle de coordonnees X,Y,W,H ****
****************************************************
v_rect	macro	;	x,y,w,h
	XREF	v_rect_rout
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	jsr	v_rect_rout
	addq.l	#8,sp
	endm

********************************************************************************
*** Realise un popup avec le bouton et le morceau d'arbre donne en parametre ***
********************************************************************************
* Retour : d0 = numero du bouton clike, -1 si erreur
popup	macro	; adresse_formulaire_clike,index,adresse_formulaire_du_popup,index
	XREF	popup_rout
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.w	\4,-(sp)
	jsr	popup_rout
	lea	12(sp),sp
	endm

**************************************************
*** Realise un form_dial autour d'un objet AES ***
**************************************************
dial_bouton	macro	; formulaire_adr,objet_index		; realise un form_dial
	ifnd	dial_bouton_routine
	XREF	dial_bouton_routine
	endc
	move.l	\1,-(sp)					; avec comme parametre les
	move.w	\2,-(sp)					; coordonnee du bouton lui-meme
	jsr	dial_bouton_routine
	addq.l	#6,sp
	endm

******************************************************************
*** Top la fenetre donne en parametre si celle-ci ne l'est pas ***
******************************************************************
top_wind_if_not_top_n_rts	macro	; index_de_la_fenetre
	wind_get	#0,#WF_TOP
	get_tab		#tab_handle,\1
	cmp.w		int_out+2,d0
	beq		@top_wind_if_not_top_test
	wind_set	d0,#WF_TOP
	rts
@top_wind_if_not_top_test		; joli label documentant quand on trace :) !
	endm
