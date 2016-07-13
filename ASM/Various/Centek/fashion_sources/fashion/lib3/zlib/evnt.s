	include	structs.s
	include	aes.i
	include	vdi.i
	include	zlib.i
	include	xbios.i
	include	gemdos.i
	include	dragndro.i
*** Importation des variables standard AES/VDI ***
*** Importation et exportation de variable pour Z_LIB ***
	XREF	options,redraw,MENU_adr,bouton_droit
	XREF	wd_create_form

	XDEF	evnt
	XDEF	opt_arbre,opt_num
	XDEF	x_mouse_clik,y_mouse_clik,n_mouse_clik,s_mouse_clik
	XDEF	evnt_key,evnt_state,ascii_key
	XDEF	tampon
	XDEF	mouse_moved

	XREF	tab_x,tab_y,tab_w,tab_h,tab_adr
	XREF	tab_adr,tab_rout,tab_kind,tab_type
	XREF	tab_name,tab_handle,tab_gadget,tab_clic,tab_key

	XDEF	root_window
	text
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**********************
***** even multi *****
**********************
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
evnt
	move.l		#tampon,addr_in		; on lance le teste d'evenement
	tst.l		mouse_moved
	beq		.not_listen_mouse

	evnt_multi	#%10111,#$102,#3,#0,#1,x_mouse_clik,y_mouse_clik,#1,#1	; on ecoute aussi les deplacement sourie

	bra		.evnt_done
.not_listen_mouse

	evnt_multi	#%10011,#$102,#3,#0	; on ecoute pas les deplacement de sourie

; si le dernier parametre est a $103, alors on attend
; le  clic gauche & le clic droit
.evnt_done
	btst	#4,d0			; on a ferm‚ ou deplace la fenetre
	bne	wind_message

	btst	#1,d0			; on a clique dans notre fenetre
	bne	mouse

	btst	#0,d0			; on a apuye sur une touche du clavier
	bne	key

	btst	#2,d0			; on a deplace la sourie
	beq	.suite_evnt
	move.l	d0,-(sp)
	move.l	mouse_moved,a0
	move.w	int_out+2,x_mouse_clik
	move.w	int_out+4,y_mouse_clik
	jsr	(a0)
	move.l	(sp)+,d0
.suite_evnt

	bra	evnt

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*******************************
*** gestion de massages AES ***
*******************************
wind_message
redraw_mess	cmpi.w	#20,tampon	; * message de redraw ?
		bne	moved
		bsr	redraw
		bra	evnt
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
moved
	cmpi.w	#28,tampon	; * on veut bouger la fenetre ?
	bne	ap_drag_drop

sized_moved
;	move.w		tampon+8,int_in+4	; on dit au gem de d‚placer sa fenetre
;	move.w		tampon+10,int_in+6
;	move.w		tampon+12,int_in+8
;	move.w		tampon+14,int_in+10
;	wind_set2	tampon+6,#5

	clr.l		d0
	move.w		tampon+6,d0
	find_tab_w	#tab_handle,d0
	move.w		d0,d6			; d6 = _offset

	clr.l		d7
	move.w		tampon+8,d7		; on sauve les coordonnees dans les
	put_tab_w	#tab_x,d6,d7		; tableau
	move.w		tampon+10,d7
	put_tab_w	#tab_y,d6,d7
	move.w		tampon+12,d7
	put_tab_w	#tab_w,d6,d7
	move.w		tampon+14,d7
	put_tab_w	#tab_h,d6,d7

	get_tab		#tab_gadget,d6
	move.l		d0,a0
	move.w		d6,-(sp)
	jsr		(a0)
	addq.l		#2,sp
	bra		evnt

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ap_drag_drop
	cmpi.w	#63,tampon	; * on veut bouger la fenetre ?
	bne	closed

* Initialisation du drag & drop
	tst.b	dragndrop_extentions		; l'app gere-t-elle le drag & drop ?
	bne	.suite_dragndrop
	bra	evnt
.suite_dragndrop
	move.w	tampon+14,drag_n_drop_fileid	; ajoute l'extention au fichier du pipe

	XREF	dragndrop_extentions

	cconws	#drag_1
	Fopen	#2,#drag_n_drop_file		; ouvre le pipe
	move.w	d0,d7
	bgt	.ok_opened
	bra	evnt
.ok_opened
	cconws	#drag_2
	move.b	#DD_OK,drag_n_drop_DD_MSG	; ecrit DD_OK
	Fwrite	#drag_n_drop_DD_MSG,#1,d7
	cmp.w	#1,d0
	bne	.close

	cconws	#drag_22
	Fwrite	#drag_n_drop_exts,#32,d7	; ecrit le buffer de 32 octets contenant les extentions supportees (remplis de 0 ce qui signifi TOUTES les extentions (plus de 8))

* Commence a lire un header
	cconws	#drag_3
	Fread	#drag_n_drop_file_lenght,#2,d7	;recupere la taille du header
	bmi	evnt
	moveq.l	#0,d6
	move.w	drag_n_drop_file_lenght,d6
	cmp.w	#2,d6
	blt	.end	; si <2 alors plus d'extentions

	Malloc	d6
	move.l	d0,a6
	cconws	#drag_4
	Fread	a6,d6,d7	; lit le header dans le buffer aloue
	cmp.w	#8,d0
	blt	.err

	cconws	#drag_5
;	move.b	#DD_OK,drag_n_drop_DD_MSG
;	Fwrite	#drag_n_drop_DD_MSG,#1,d7

	cmp.l	#"ARGS",a6
	bne	.err

	Mfree	a6

	move.b	#DD_EXT,drag_n_drop_DD_MSG	; ecrit DD_OK
	Fwrite	#drag_n_drop_DD_MSG,#1,d7

	Fread	#drag_n_drop_file_lenght,#2,d7	;recupere la taille du header
	bmi	evnt
	moveq.l	#0,d6
	move.w	drag_n_drop_file_lenght,d6
	cmp.w	#2,d6
	blt	.end	; si <2 alors plus d'extentions

	Malloc	d6
	move.l	d0,a6
	cconws	#drag_4
	Fread	a6,d6,d7	; lit le header dans le buffer aloue
	cmp.w	#8,d0
	blt	.err



.loop_type
	move.l	a6,a5
	cconws	a5
	lea	4(a5),a5
.lp_find_0
	tst.b	(a5)+
	bne	.lp_find_0
	cconws	a5

* Desalou le buffer de header
.err	Mfree	a6
.close	Fclose	d7
.end	bra	evnt
	data
* Print pour tracer
drag_1	dc.b	10,13,"Drag n drop recu. Ouverture du pipe...",0
drag_2	dc.b	10,13,"Ouverture OK, envois de DD_OK...",0
drag_22	dc.b	10,13,"Envois des extentions...",0
drag_3	dc.b	10,13,"Recuperation de la taille du header...",0
drag_4	dc.b	10,13,"Lecture du header...",0
drag_5	dc.b	10,13,"Header OK, envois de DD_OK",0
* Nom du fichier dans le pipe
drag_n_drop_file	dc.b	"U:\PIPE\DRAGDROP."
drag_n_drop_fileid	ds.b	2
drag_n_drop_fileend	dc.b	0

drag_n_drop_DD_MSG	dc.w	0	; permet d'envoyer des message

* Un buffer vide a retourner comme type d'extention supporte, puisqu'on peut en sopporter plus de 8
drag_n_drop_exts	ds.b	4*9
	bss
drag_n_drop_file_lenght	ds.w	1
drag_n_drop_given_fname	ds.b	1024
	text
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
closed:	cmpi.w		#22,tampon	; on veut fermer la fenetre ?
	bne		toped
	clr.l		d7
	move.w		tampon+6,d7
	find_tab_w	#tab_handle,d7
	cmp.w		#-1,d0
	beq		evnt
	move.w		d0,d6

	get_tab		#tab_gadget,d6
	move.l		d0,a0
	move.w		d6,-(sp)
	jsr		(a0)
	addq.l		#2,sp

	bra		evnt
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
toped:	cmp.w		#21,tampon			***; fenetre au 1er plan ?
	bne		acc_selected

* On doit tester si un bouton de la souris est pushe :
* si pas de bouton apuye, alors on tope a tous les coups. (multitache avec CTRL+ALT/TAB par exemple)
	vq_mouse
;	tst.w		intout
;	beq		.tope_la_fenetre
* Note : impossible de tester si le bouton est appuye ou pas, a cause de la lenteur.
* Il arrive en effet que si l'on relache le bouton de la sourie avant l'appel de vq_mouse
* (putain de evnt_multi...)

* De meme, il n'est pas possible de savoir quel nombre de clik a ete envoye puisqu'on recois un
* message de TOP et non un message de clik
	move.w		ptsout+0,x_mouse_clik
	move.w		ptsout+2,y_mouse_clik
	wind_find	ptsout+0,ptsout+2		; quelle fenetre a ete clik‚ ?
	moveq.l		#0,d7
	move.w		int_out,d7
	find_tab_w	#tab_handle,d7	; on cherche l'offcet dans le tableau des fenetres

	cmp.w	#-1,d0			; si on trouve un offset de -1, c'est qu'il y a eu une erreur
	beq	.tope_la_fenetre	; (c'est pas notre fenetre sous la sourie), donc on boucle...
	move.w	d0,d6			; sinon, continue de verifier qu'on est bien DANS la surface
					; de travail de la fenetre
* La sourie est-elle dans la zone de travail ???
	move.w	#1,int_in
	get_tab	#tab_kind,d6
	move.w	d0,int_in+2
	get_tab	#tab_x,d6
	move.w	d0,int_in+4
	get_tab	#tab_y,d6
	move.w	d0,int_in+6
	get_tab	#tab_w,d6
	move.w	d0,int_in+8
	get_tab	#tab_h,d6
	move.w	d0,int_in+10
	aes	108					; wind_calc

* Si non, on tope la fenetre...
	move.w	x_mouse_clik,d1
	move.w	y_mouse_clik,d2
	sub.w	int_out+2,d1
	ble	.tope_la_fenetre
	sub.w	int_out+4,d2
	ble	.tope_la_fenetre
	cmp.w	int_out+6,d1
	bge	.tope_la_fenetre
	cmp.w	int_out+8,d2
	bge	.tope_la_fenetre

* .clic_on_it
	move.w	#1,n_mouse_clik
	get_tab	#tab_clic,d6
	move.l	d0,a0
	move.w	d6,-(sp)
	jsr	(a0)
	addq.l	#2,sp
	bra	evnt

.tope_la_fenetre
	wind_set	tampon+6,#10
	bra		evnt
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
acc_selected:	cmp.w	#40,tampon		; on a cliquer sur la ligne de l'acc
	bne		fulled			; (acc_open)
	wind_set2	tampon+6,#10
	bra		evnt

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fulled:		cmp.w	#23,tampon			***; on a cliquer sur le bouton fuller
	bne		menu_selected
	find_tab_w	#tab_handle,tampon+6
	move.w		d0,d7
	get_tab		#tab_gadget,d7
	move.l		d0,a0
	move.w		d7,-(sp)
	jsr		(a0)
	addq.l		#2,sp
	bra		evnt

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
menu_selected	cmp.w	#10,tampon
	bne		sized

	move.w	tampon+6,mn_title		; on sauve pour le menu_tnormal
	move.w	tampon+8,mn_item

	move.l	MENU_adr,opt_arbre		; on transmet l'option selectionne
	move.w	tampon+8,opt_num

	jsr		options
	menu_tnormal	MENU_adr,mn_title,#1

	bra		evnt

	bss
mn_title	ds.w	1
mn_item		ds.w	1
	text
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
* Routine protege contre le retrecissement exessif...                                             *
* Minimum 40*40...                                                                                *
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
sized	cmp.w	#WM_SIZED,tampon
	bne	arrowed

	cmp.w	#40,tampon+12
	bge	.suite1
	move.w	#40,tampon+12
.suite1
	cmp.w	#40,tampon+14
	bge	.suite2
	move.w	#40,tampon+14
.suite2

	clr.l		d0
	move.w		tampon+6,d0
	find_tab_w	#tab_handle,d0	; retrouve l'ofset...
	move.w		d0,d4		; d4 = _offset

	get_tab		#tab_w,d4	; si les nouvelles coordonnees en w et h sont toutes
	move.w		tampon+12,d7
	cmp.w		d0,d7			; les deux plus petites que les anciennes, alors
	bge		.suite3

	move.w		tampon+8,int_in+4		; on dit au gem de d‚placer sa fenetre
	move.w		tampon+10,int_in+6
	move.w		tampon+12,int_in+8
	move.w		tampon+14,int_in+10
	wind_set2	tampon+6,#5

	clr.l		d0
	move.w		tampon+6,d0
	find_tab_w	#tab_handle,d0
	move.w		d0,d4

	clr.l		d7
	move.w		tampon+8,d7		; on sauve les coordonnees dans les
	put_tab_w	#tab_x,d4,d7		; tableau
	move.w		tampon+10,d7
	put_tab_w	#tab_y,d4,d7
	move.w		tampon+12,d7
	put_tab_w	#tab_w,d4,d7
	move.w		tampon+14,d7
	put_tab_w	#tab_h,d4,d7

	get_tab		#tab_gadget,d4
	move.l		d0,a0
	move.w		d4,-(sp)
	jsr		(a0)
	addq.l		#2,sp

;	bsr		redraw
	bra		evnt

.suite3
	bra		sized_moved
arrowed
	cmp.w		#WM_ARROWED,tampon
	bne		hslided
	find_tab_w	#tab_handle,tampon+6
	move.w		d0,d7
	get_tab		#tab_gadget,d7
	move.l		d0,a0
	move.w		d7,-(sp)
	jsr		(a0)
	addq.l		#2,sp
	bra		evnt
hslided
	cmp.w		#WM_HSLID,tampon
	bne		vslided
	find_tab_w	#tab_handle,tampon+6
	move.w		d0,d7
	get_tab		#tab_gadget,d7
	move.l		d0,a0
	move.w		d7,-(sp)
	jsr		(a0)
	addq.l		#2,sp
	bra		evnt

vslided
	cmp.w		#WM_VSLID,tampon
	bne		evnt
	find_tab_w	#tab_handle,tampon+6
	move.w		d0,d7
	get_tab		#tab_gadget,d7
	move.l		d0,a0
	move.w		d7,-(sp)
	jsr		(a0)
	addq.l		#2,sp
	bra		evnt
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**************************************************************************
*** evenement sourie *****************************************************
**************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
mouse
	move.w		int_out+12,n_mouse_clik	; nombre de clik sourie
	move.w		int_out+2,x_mouse_clik	; coordonne en X
	move.w		int_out+4,y_mouse_clik	; coordonne en y
	move.w		int_out+6,d0		; numero du bouron de sourie
	move.w		d0,s_mouse_clik		; state de la sourie (gauche ou droite...)

	wind_find	int_out+2,int_out+4	; quelle fenetre a ete clik‚ ?
	clr.l		d0
	move.w		int_out,d0
	bne		.not_root_window

	tst.l		root_window
	beq		evnt
	move.l		root_window,a0
	jsr		(a0)
	bra		evnt

.not_root_window
	find_tab_w	#tab_handle,d0	; on cherche l'offcet dans le tableau des fenetres

	cmp.w		#-1,d0		; si on trouve un offset de -1, c'est qu'il y a eu une erreur
	beq		evnt		; (c'est pas notre fenetre sous la sourie), donc on boucle...
	move.w		d0,d7		; sinon, on selectionne l'objet sous la sourie si celui-ci
					; a le flag SELCTABLE a 1

* Verifie qu'on a bien clique dans l'INTERRIEUR de la fenetre (work)
	get_tab		#tab_x,d7
	move.w		d0,d3
	get_tab		#tab_y,d7
	move.w		d0,d4
	get_tab		#tab_w,d7
	move.w		d0,d5
	get_tab		#tab_h,d7
	move.w		d0,d6
	get_tab		#tab_kind,d7

	wind_calc	#1,d0,d3,d4,d5,d6
	move.w		int_out+2,d3
	move.w		int_out+4,d4
	move.w		int_out+6,d5
	move.w		int_out+8,d6
	add.w		d3,d5
	add.w		d4,d6
	subq.w		#1,d5
	subq.w		#1,d6

	move.w		x_mouse_clik,d0
	move.w		y_mouse_clik,d1

	cmp.w		d0,d3
	bgt		evnt
	cmp.w		d0,d5
	blt		evnt

	cmp.w		d1,d4
	bgt		evnt
	cmp.w		d1,d6
	blt		evnt

	get_tab		#tab_clic,d7
	move.l		d0,a0
	move.w		d7,-(sp)
	jsr		(a0)
	addq.l		#2,sp
	bra		evnt

	bss
n_mouse_clik	ds.w	1
x_mouse_clik	ds.w	1
y_mouse_clik	ds.w	1
s_mouse_clik	ds.w	1
	text
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*************** racourcie clavier **************
key
	move.w	int_out+10,evnt_key
	move.w	int_out+8,evnt_state

	cmp.b	#" ",evnt_key+1
	beq	key_encapsuled

	cmp.b	#$1C,int_out+10
	beq	return_pressed
	cmp.b	#$72,int_out+10
	beq	return_pressed

* On verifi que la touche est dans la tranche des caractere ascii
	tst.b	int_out+11
	beq	key_encapsuled

* Si oui, alors ca peut etre un racourci de menu
.suite_key_menu
	clr.l	d7					; on prend le scan code de la touche appuye par
	move.b	int_out+10,d7		; l'utilisteur (evnt_multi) : octet fort de int_ou+10

	Keytbl	#-1,#-1,#-1			; on transforme le scan code du racourcie en son equivalent
	move.l	d0,a0				; ASCII majuscule

	move.l	4(a0),a0
	add.l	d7,a0
	move.b	(a0),ascii_key

	move.w	#0,d7
	move.l	MENU_adr,a6			; on cherche le 1er G_TITLE de l'arbre
.loop1
	lea	24(a6),a6
	addq.w	#1,d7
	cmp.b	#32,ob_type+1(a6)
	bne.s	.loop1

	move.w	d7,title_index
	move.l	a6,title_adr

.loop2
	lea	24(a6),a6			; puis le 1er G_STRING
	addq.w	#1,d7
	cmp.b	#28,ob_type+1(a6)
	bne.s	.loop2

racourcie_loop
	move.l	a6,g_string_adr

	move.l	ob_spec(a6),a5
.loop3
	tst.b	(a5)+
	bne		.loop3				; puis sur son racourcie clavier
	subq.l	#3,a5
	move.b	(a5),d6

	cmp.b	ascii_key,d6		; on test pour savoir si ‡a correspond
	bne	no_racourcie			; a la touche frappee

	move.w	evnt_state,d5
	subq.l	#1,a5

	move.b	(a5),d6			; puis on test les touches alt, ctrl et shift
	cmp.b	#"",d6
	bne	no_alt
	btst	#3,d5
	beq	no_racourcie
	subq.l	#1,a5
	bra	suite1
no_alt
	btst	#3,d5
	bne	no_racourcie

suite1
	move.b	(a5),d6		; puis on test la touche shift
	cmp.b	#"",d6
	bne	no_shift
	btst	#1,d5		; la touche doit etre shiftee
	beq	no_shift_gauche
	bra	shift
no_shift_gauche
	btst	#2,d5
	beq	no_racourcie
shift
	subq.l	#1,a5
	bra	suite2
no_shift
	btst	#0,evnt_state	; mais pas ici
	bne	no_racourcie
	btst	#1,evnt_state
	bne	no_racourcie

suite2
	move.b	(a5),d6			; puis on test la touche ctrl
	cmp.b	#"^",d6
	bne		no_ctrl
	btst	#2,d5
	beq		no_racourcie
	subq.l	#1,a5
	bra		racourcie_ok
no_ctrl
	btst	#2,d5
	bne		no_racourcie
* test racourcie reussie : la combinaison de touche appuiy‚ est identique a
* celle decrite dans le G_STRING du menu.
racourcie_ok
	move.w		#10,tampon
	move.w		title_index,tampon+6
	move.w		d7,tampon+8
	menu_tnormal	MENU_adr,title_index,#0
	bra		menu_selected

* test racourcie negatif : la touche appuie ne correspond pas a celle decrite
* dans le G_STRING, donc on cherche le G_STRING suivant, sauf si celui-ci est
* le dernier de l'arbre.
no_racourcie
	move.l	g_string_adr,a6
	move.w	ob_flags(a6),d0		; on verifie qu'on a pas attend le dernier objet
	btst	#5,d0			; de l'arbre du menu
	bne	key_encapsuled

ligne_de_menu_suivante
	addq.w	#1,d7			; on ajoute 1 au compteur d'index
	add.l	#24,a6
	cmp.b	#28,ob_type+1(a6)		; si l'objet suivant
	bne	titre_de_menu_suivant
	bra	racourcie_loop

	bra	evnt
titre_de_menu_suivant
	addq.w	#1,title_index
	bra	ligne_de_menu_suivante

****** si la touche return est appuye, on cherche l'objet par defaut ************
****** de la fenetre en 1er plan, et on l'active                     ************
return_pressed
	wind_get	#0,#10
	clr.l		d0
	move.w		int_out+2,d0
	find_tab_w	#tab_handle,d0	; trouve l'offcet de la fenetre en 1er plan
	cmp.w		#-1,d0
	beq		evnt
	move.w		d0,d7

	get_tab		#tab_type,d7	; on verifie qu'il sagit d'un formulaire en fenetre
	cmp.l		#wd_create_form,d0
	beq		return_pressed_ok

	bra		evnt

return_pressed_ok
	get_tab	#tab_adr,d7	; puis on cherche le bouton par defaut
	move.l	d0,d5
	move.l	d0,a6
	clr.w	d6

.loop
	move.w	ob_flags(a6),d0
	btst	#DEFAULT,d0
	bne	objet_defaut_trouver

	btst	#LASTOB,d0
	bne	evnt

	add.l	#24,a6
	add.w	#1,d6
	bra	.loop

objet_defaut_trouver
	trouve_objc	d5,d6	; si l'objet est disabled, alors on ne fait rien.
	move.w		ob_states(a0),d0
	btst		#DISABLED,d0
	bne		evnt

	xobjc_change	d5,d6
	move.l		d5,opt_arbre
	move.w		d6,opt_num
	jsr		options

	bra		evnt

key_encapsuled
	wind_get	#0,#10
	move.w		int_out+2,d0
	find_tab_w	#tab_handle,d0	; trouve l'offcet de la fenetre en 1er plan
	cmp.w		#-1,d0
	beq		evnt
	get_tab		#tab_key,d0
	move.l		d0,a0
	tst.l		a0
	beq		evnt
	jsr		(a0)
	bra		evnt
	data
mouse_moved	dc.l	0
root_window	dc.l	0
	bss
************************************************
*** Les variables globales de retour de EVNT ***
************************************************
opt_arbre	ds.l	1
opt_num		ds.w	1

evnt_key	ds.w	1
evnt_state	ds.w	1
title_index	ds.w	1
title_adr	ds.l	1
ascii_key	ds.w	1
		even
g_string_adr	ds.l	1
tampon		ds.w	16
