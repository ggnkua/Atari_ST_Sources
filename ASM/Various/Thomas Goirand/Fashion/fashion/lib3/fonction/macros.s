*********************************************************
*** fichier de macro comande ‚dit‚ par Thomas GOIRAND ***
*** alias  ZIGO of ADRENALINE.  Utilise les macros de ***
*** devpac-3.                                         ***
***                                                   ***
*** Fichier indispensable pour la librairie ZIGO LIB  ***
*********************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	XDEF	change_objc_routine
	XDEF	put_tab_l_routine,put_tab_w_routine,find_tab_l_routine,find_tab_w_routine
	XDEF	trouve_objc_routine,trouve_parent_routine,redraw_objc_routine

	include	zlib.i
	include	structs.s
	include	gemdos.i
	include	aes.i
	include	vdi.i

	XREF	tab_handle,tab_adr
	XREF	tab_x,tab_y,tab_w,tab_h
	XREF	tampon,ap_id,int_in,int_out,addr_out,redraw
	XREF	contrl1
	XREF	hauteur_menu
	XREF	x_mouse_clik,y_mouse_clik
	XREF	x_max,y_max
******************************************
* macro de gestion de tableau de fenetre *
******************************************
	text
put_tab_l_routine
	movem.l	d0/a0,-(sp)
	clr.l	d0
	move.l	12+6(sp),a0
	clr.l	d0
	move.w	12+4(sp),d0
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	12+0(sp),(a0)
	movem.l	(sp)+,d0/a0
	rts

put_tab_w_routine
	movem.l	d0/a0,-(sp)
	clr.l	d0
	move.l	12+4(sp),a0
	clr.l	d0
	move.w	12+2(sp),d0
	lsl.l	#2,d0
	add.l	d0,a0
	move.w	12+0(sp),2(a0)
	movem.l	(sp)+,d0/a0
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
find_tab_w_routine
	movem.l	a0/d1/d2,-(sp)
	move.l	16+2(sp),a0
	move.w	16+0(sp),d0
	move.w	#MAX_WD-1,d1
	clr.l	d2
	addq.l	#2,a0
.loop
	add.w	#1,d2
	cmp.w	(a0)+,d0
	beq	.suite
	addq.l	#2,a0
	dbf	d1,.loop
	move.l	#-1,d0
	movem.l	(sp)+,a0/d1/d2
	rts
.suite
	subq.w	#1,d2
	clr.l	d0
	move.w	d2,d0
	movem.l	(sp)+,a0/d1/d2
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
find_tab_l_routine
	movem.l	a0/d1/d2,-(sp)
	move.l	16+4(sp),a0
	move.l	16+0(sp),d0
	move.w	#MAX_WD-1,d1
	clr.l	d2
.loop
	add.w	#1,d2
	cmp.l	(a0)+,d0
	beq	.suite
	dbf	d1,.loop
	move.l	#-1,d0
	movem.l	(sp)+,a0/d1/d2
	rts
.suite
	subq.w	#1,d2
	clr.l	d0
	move.w	d2,d0
	movem.l	(sp)+,a0/d1/d2
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*********************************************************
*** trouve l'adresse d'un objet a partir de l'adresse ***
*** de son arbre et de son index                      ***
*********************************************************
*** Macro limite a ~ 1300 objets/arbre maxi           ***
*********************************************************
	XDEF	trouve_objc_routine
trouve_objc_routine
	move.w	d0,-(sp)
	move.w	d1,-(sp)
	move.l	8+2(sp),a0
	move.w	8+0(sp),d0
	lsl.w	#3,d0	; d0 = d0 *8  \
	move.w	d0,d1	;              |d0 = d0*24
	add.w	d1,d0	; d0 = d0 +d0  |
	add.w	d1,d0	; d0 = d0 +d0 /
	add.w	d0,a0
	move.w	(sp)+,d1
	move.w	(sp)+,d0	; retour dans a0 (adresse de l'objet)
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* realise un form_dial avec comme parametre les coordonnees de l'objet.
	XDEF	dial_bouton_routine
dial_bouton_routine
	movem.l		d1-a6,-(sp)
	move.w		60+0(sp),d7
	move.l		60+2(sp),d6	; adresse du formulaire

	move.l		d6,-(sp)
	move.w		d7,-(sp)
	move.l		#dial_obsize,-(sp)
	jsr		objc_size_rout
	lea		10(sp),sp

	form_dial	#3,dial_obsize,dial_obsize+2,dial_obsize+4,dial_obsize+6,dial_obsize,dial_obsize+2,dial_obsize+4,dial_obsize+6
	movem.l		(sp)+,d1-a6
	rts
	bss
dial_obsize	ds.w	8
	text
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*******************************************************
*** grise ou degrise un objet et demande son redraw ***
*******************************************************
	XDEF	grise_objc_routine
grise_objc_routine
	movem.l	d3/d7/a0/a6,-(sp)
	move.l	20+4(sp),a6
	move.w	20+2(sp),d3
	move.w	20+0(sp),d7

	trouve_objc	a6,d3

	tst		d7
	beq		.degrise_lobjet
	bclr		#DISABLED,ob_states+1(a0)	; on selectionne le bouton
	bra		.objet_ok
.degrise_lobjet
	bset		#DISABLED,ob_states+1(a0)	; on selectionne le bouton
.objet_ok

	move.l		a6,-(sp)
	move.w		d3,-(sp)
	bsr		redraw_objc_gem_routine
	addq.l		#6,sp

	movem.l		(sp)+,d3/d7/a0/a6
	rts
********************************************************************
**** selectionne ou deselectionne un objet et demande son redraw ***
********************************************************************
change_objc_routine
	movem.l		d3/a0/a6,-(sp)
	move.l		16+2(sp),a6
	move.w		16+0(sp),d3
	trouve_objc	a6,d3

	bchg		#0,ob_states+1(a0)	; on selectionne le bouton

	move.l		a6,-(sp)
	move.w		d3,-(sp)
	bsr		redraw_objc_routine
	addq.l		#6,sp

	movem.l		(sp)+,d3/a0/a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**************************
*** redessine un objet ***
**************************
; redraw_objc_routine(adresse_arbre,index_objc)
	XDEF		redraw_objc_routine
redraw_objc_routine
	movem.l		d1-a6,-(sp)
	lea		-16(sp),a5	; a5 est un tableau de 8 short temporaire (pour objc_size)
	move.l		a5,sp
	move.l		76+2(sp),a6
	move.w		76+0(sp),d3

	move.l		a6,-(sp)
	move.w		d3,-(sp)
	move.l		a5,-(sp)
	jsr		objc_size_rout
	lea		10(sp),sp
	
	move.w		0(a5),d1
	move.w		2(a5),d2
	move.w		4(a5),d6
	move.w		6(a5),d7

	find_tab_l	#tab_adr,a6	; on trouve la fenetre consern‚ par le redraw
	cmp.w		#-1,d0
	beq		no_redraw
	get_tab		#tab_handle,d0
	move.w		d0,d4
	tst.w		d0		; si on a un handle de -1 ou de 0, alors on
	beq		no_redraw	; doit redessiner la "fenetre" du bureau

	move.w		#20,tampon	; et on fait un redraw sur la fenetre en
	move.w		ap_id,tampon+2	; question et sur la zone de l'objet a
	move.w		#0,tampon+4	; redessiner
	move.w		d4,tampon+6
	move.w		d1,tampon+8
	move.w		d2,tampon+10
	move.w		d6,tampon+12
	move.w		d7,tampon+14
	bsr		redraw
no_redraw				; mais on ne le fait pas encore
	lea		16(sp),sp
	movem.l		(sp)+,d1-a6
	rts
********************************************************
*** Redessine une fenetre a partir de coordonnes AES ***
********************************************************
; handle,x,y,w,h
	XDEF	redraw_cords_rout
redraw_cords_rout
	movem.l		d1-a6,-(sp)
	move.w		#20,tampon
	move.w		ap_id,tampon+2
	move.w		#0,tampon+4
	move.w		60+8(sp),tampon+6
	move.w		60+6(sp),tampon+8
	move.w		60+4(sp),tampon+10
	move.w		60+2(sp),tampon+12
	move.w		60+0(sp),tampon+14
	bsr		redraw
	movem.l		(sp)+,d1-a6
	rts
****************************************************
*** redessine un objet en passant par appl_write ***
****************************************************
; redraw_objc_routine(adresse_arbre,index_objc)
	XDEF		redraw_objc_gem_routine
redraw_objc_gem_routine
	movem.l		d1-a6,-(sp)
	lea		-16(sp),a5	; a5 est un tableau de 8 short temporaire (pour objc_size)
	move.l		a5,sp
	move.l		76+2(sp),a6
	move.w		76+0(sp),d3

	move.l		a6,-(sp)
	move.w		d3,-(sp)
	move.l		a5,-(sp)
	jsr		objc_size_rout
	lea		10(sp),sp
	
	move.w		0(a5),d1
	move.w		2(a5),d2
	move.w		4(a5),d6
	move.w		6(a5),d7

	find_tab_l	#tab_adr,a6	; on trouve la fenetre consern‚ par le redraw
	cmp.w		#-1,d0
	beq		no_redraw
	get_tab		#tab_handle,d0
	move.w		d0,d4
	tst.w		d0		; si on a un handle de -1 ou de 0, alors on
	beq		.no_redraw	; doit redessiner la "fenetre" du bureau

	move.w		#20,tampon_gem	; et on fait un redraw sur la fenetre en
	move.w		ap_id,tampon_gem+2	; question et sur la zone de l'objet a
	move.w		#0,tampon_gem+4	; redessiner
	move.w		d4,tampon_gem+6
	move.w		d1,tampon_gem+8
	move.w		d2,tampon_gem+10
	move.w		d6,tampon_gem+12
	move.w		d7,tampon_gem+14
	appl_write	ap_id,#16,#tampon_gem
.no_redraw				; mais on ne le fait pas encore
	lea		16(sp),sp
	movem.l		(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
************************************************************************************
*** copie d'un chemin dans une chaine a partir d'une autre chaine pour affichage ***
************************************************************************************
	XDEF	affiche_chemin_routine
affiche_chemin_routine
	movem.l	a0/a1,-(sp)
	move.l	12+4(sp),a1
	move.l	12+0(sp),a0
	cmp.b	#0,(a0)							; est-on arrive a la fin de la chaine affiche ?
	beq	affiche_chemin_routin_suite3
	move.b	(a1)+,(a0)+
	cmp.b	#0,(a1)							; est-on arrive a la fin de la chaine a copier ?
	bne	affiche_chemin_routine
	cmp.b	#0,(a0)
	beq	affiche_chemin_routin_suite2
	move.b	#"_",(a0)+
;	bra	affiche_chemin_routin_suite
affiche_chemin_routin_suite2
	bra	affiche_chemin_routin_end
affiche_chemin_routin_suite3
	subq.l	#3,a0
	move.b	#".",(a0)+
	move.b	#".",(a0)+
	move.b	#".",(a0)+
	bra		affiche_chemin_routin_end
affiche_chemin_routin_end
	movem.l	(sp)+,a0/a1
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*************************************************************
*** modifie sur demande l'un des bits du champs ob_states ***
*** d'un objet et commande un redraw sur l'objet en ques- ***
*** tion.                                                 ***
*************************************************************
	XDEF	state_bit_objc_routine
state_bit_objc_routine
	movem.l		d4-d7/a0/a6,-(sp)
	move.w		28+0(sp),d5
	move.w		28+2(sp),d6
	move.w		28+4(sp),d7
	move.l		28+6(sp),a6
	trouve_objc	a6,d7
	move.w		ob_states(a0),d4
	tst.w		d5
	beq		state_bit_objc_off
	bset		d6,d4
	bra		state_bit_objc_routine_2
state_bit_objc_off
	bclr		d6,d4
state_bit_objc_routine_2
	move.w		d4,ob_states(a0)
	redraw_objc	a6,d7
	movem.l		(sp)+,d4-d7/a0/a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*************************************************************
*** modifie sur demande l'un des bits du champs ob_flags  ***
*** d'un objet et commande un redraw sur l'objet en ques- ***
*** tion.                                                 ***
*************************************************************
	XDEF	flag_bit_objc_routine
flag_bit_objc_routine
	movem.l		d4-d7/a0/a6,-(sp)
	move.w		28+0(sp),d5
	move.w		28+2(sp),d6
	move.w		28+4(sp),d7
	move.l		28+6(sp),a6

	trouve_objc	a6,d7
	move.w		ob_flags(a0),d4
	tst.w		d5
	beq			flag_bit_objc_off
	bset		d6,d4
	bra			flag_bit_objc_routine_2
flag_bit_objc_off
	bclr		d6,d4
flag_bit_objc_routine_2
	move.w		d4,ob_flags(a0)
	redraw_objc	a6,d7
	movem.l		(sp)+,d4-d7/a0/a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
************************************************************
*** instale une boite de dialogue, puis fait un form_do. ***
*** Retabli le bouton de sortie de formulaire            ***
*** en sortie : d0 = bouton de sortie                    ***
************************************************************
	XDEF	dialogue_routine
dialogue_routine
	rsrc_gaddr	#0,d7
	move.l		addr_out,d3
	form_center	d3
	move.l		d3,a0
	move.w		ob_x(a0),d4
	move.w		ob_y(a0),d5
	move.w		ob_w(a0),d6
	move.w		ob_h(a0),d7
	subq.w		#4,d4
	subq.w		#4,d5
	addq.w		#8,d6
	addq.w		#8,d7

	objc_draw	d3,#0,#20,d4,d5,d6,d7
	form_do		d3,#0
	form_dial	#3,d4,d5,d6,d7,d4,d5,d6,d7
	bclr		#15,d0
	move.w		d0,d7

	trouve_objc	d3,d0
	move.w		ob_states(a0),d2
	bchg		#0,d2
	move.w		d2,ob_states(a0)
	move.w		d7,d0
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
***************************************************
*** Donne l'adresse du texte de l'objet demande ***
***************************************************
*retour dans a0
	XDEF		give_txt_adr_routine
give_txt_adr_routine
	movem.l		d1-d2/d5-d7/a1-a3/a6,-(sp)
	move.l		40+2(sp),a6
	move.w		40+0(sp),d6
	trouve_objc	a6,d6
	lea		ob_spec(a0),a3
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a3),a3
.not_indirect
	move.b		ob_type+1(a0),d5
	cmp.b		#G_ICON,d5
	beq		.iconblk
	cmp.b		#G_CICON,d5
	beq		.ciconblk
	cmp.b		#G_TITLE,d5
	beq		.point_text
	cmp.b		#G_BUTTON,d5
	beq		.point_text
	cmp.b		#G_STRING,d5
	beq		.point_text
	cmp.b		#G_TEXT,d5
	beq		.tedinfo
	cmp.b		#G_BOXTEXT,d5
	beq		.tedinfo
	cmp.b		#G_FTEXT,d5
	beq		.tedinfo
	cmp.b		#G_FBOXTEXT,d5
	beq		.tedinfo
	move.l		#-1,a0
	movem.l		(sp)+,d1-d2/d5-d7/a1-a3/a6
	rts

.tedinfo
	move.l		(a3),a3
	move.l		(a3),a0
	movem.l		(sp)+,d1-d2/d5-d7/a1-a3/a6
	rts
.point_text
	move.l		(a3),a0
	movem.l		(sp)+,d1-d2/d5-d7/a1-a3/a6
	rts
.iconblk
.ciconblk
	move.l		(a2),a2
	lea		ib_ptext(a2),a0
	move.l		(a0),a0
	movem.l		(sp)+,d1-d2/d5-d7/a1-a3/a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*******************************************************************
*** Donne l'adresse du pointeur sur le texte de l'objet demande ***
*******************************************************************
* retour dans a0
give_txt_ptr_routine
	XDEF	give_txt_ptr_routine
	movem.l		d1-d3/d6/d7/a1-a4,-(sp)
	move.l		40+2(sp),a4
	move.w		40+0(sp),d6
	trouve_objc	a4,d6
	lea		ob_spec(a0),a2
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.suite
	move.l		(a2),a2
.suite
	move.b		ob_type+1(a0),d5
	cmp.b		#G_ICON,d5
	beq		.iconblk
	cmp.b		#G_CICON,d5
	beq		.ciconblk
	cmp.b		#G_TITLE,d5
	beq		.point_text
	cmp.b		#G_BUTTON,d5
	beq		.point_text
	cmp.b		#G_STRING,d5
	beq		.point_text
	cmp.b		#G_TEXT,d5
	beq		.tedinfo
	cmp.b		#G_BOXTEXT,d5
	beq		.tedinfo
	cmp.b		#G_FTEXT,d5
	beq		.tedinfo
	cmp.b		#G_FBOXTEXT,d5
	beq		.tedinfo
	move.l		#-1,a0
	movem.l		(sp)+,d1-d3/d6/d7/a1-a4
	rts

.tedinfo
	move.l	(a2),a0
	movem.l	(sp)+,d1-d3/d6/d7/a1-a4
	rts
.point_text
	move.l	a2,a0
	movem.l	(sp)+,d1-d3/d6/d7/a1-a4
	rts
.iconblk
.ciconblk
	move.l	(a2),a2
	lea	ib_ptext(a2),a0
	movem.l	(sp)+,d1-d3/d6/d7/a1-a4
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**************************************************************************************
*** Demande le redraw complet d'une fenetre directement sans passer par evnt_multi ***
**************************************************************************************
	XDEF	wd_redraw_routine
wd_redraw_routine
	movem.l	d0-a6,-(sp)
	move.w	64(sp),d7
	get_tab	#tab_handle,d7	; si le handle est a 0 dans les tableau,
	tst.w	d0		; alors la fenetre est ferme, et on ne peut faire de redraw...
	bne	.suite
	movem.l	(sp)+,d0-a6
	rts
.suite
	move.w	#20,tampon
	move.w	ap_id,tampon+2	; on rempli le buffer du tampon gem et on fait un
	clr.w	tampon+4
	move.w	d0,tampon+6	; redraw classique...
	get_tab	#tab_x,d7
	move.w	d0,tampon+8
	get_tab	#tab_y,d7
	move.w	d0,tampon+10
	get_tab	#tab_w,d7
	move.w	d0,tampon+12
	get_tab	#tab_h,d7
	move.w	d0,tampon+14
	jsr	redraw
	movem.l	(sp)+,d0-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*************************************************************************
*** Demande le redraw complet d'une fenetre en passant par APPL_WRITE ***
*************************************************************************
	XDEF	wd_redraw_gem_routine
wd_redraw_gem_routine
	movem.l	d0-a6,-(sp)
	move.w	64(sp),d7
	get_tab	#tab_handle,d7	; si le handle est a 0 dans les tableau,
	tst.w	d0		; alors la fenetre est ferme, et on ne peut faire de redraw...
	bne	.suite
	movem.l	(sp)+,d0-a6
	rts
.suite
	move.w		#20,tampon_gem
	move.w		ap_id,tampon_gem+2	; on rempli le buffer tampon_gem et on fait un
	clr.w		tampon+4
	move.w		d0,tampon_gem+6		; appl_write : un classique...
	get_tab		#tab_x,d7
	move.w		d0,tampon_gem+8
	get_tab		#tab_y,d7
	move.w		d0,tampon_gem+10
	get_tab		#tab_w,d7
	move.w		d0,tampon_gem+12
	get_tab		#tab_h,d7
	move.w		d0,tampon_gem+14
	move.l		#tampon_gem,addr_in
	appl_write	ap_id,#16,#tampon_gem
	movem.l	(sp)+,d0-a6
	rts
	data
tampon_gem	ds.w	8
	text
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**************************************************
*** Permet la copy d'une chaine dans une autre ***
**************************************************
	XDEF	string_copy_routine
string_copy_routine
	movem.l	a5-a6,-(sp)
	move.l	12+4(sp),a5
	move.l	12+0(sp),a6
.loop
	move.b	(a5)+,(a6)+
	bne	.loop
	movem.l	(sp)+,a5-a6
	rts

***************************
*** Concatene 2 chaines ***
***************************
	XDEF	string_concat_rout
string_concat_rout
	movem.l	a5/a6,-(sp)
	move.l	12+4(sp),a5	; chaine a ajouter
	move.l	12+0(sp),a6	; chaine ou ajouter

.lp_find_end
	tst.b	(a6)+
	bne	.lp_find_end
	subq.l	#1,a6

.lp_add_string
	move.b	(a5)+,(a6)+
	bne	.lp_add_string
	movem.l	(sp)+,a5/a6
	rts

**********************************************
*** Renvois dans d0 la taille de la chaine ***
**********************************************
	XDEF	string_size_routine
string_size_routine
	move.l	a0,-(sp)
	move.l	8(sp),a0
	moveq.l	#0,d0
.loop	addq.l	#1,d0
	tst.b	(a0)+
	bne	.loop
	move.l	(sp)+,a0
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*******************************************************
*** Fait un malloc et efface la zone avec des zeros ***
*******************************************************
	XDEF	xmalloc_routine
xmalloc_routine
	move.l	a6,-(sp)
	move.l	8(sp),a6
	Malloc	a6
	tst.l	d0
	bgt	.suite_xmalloc_routine
	movem.l	(sp)+,d7/a5/a6
	rts
.suite_xmalloc_routine
	move.l	d0,-(sp)

	move.l	d0,-(sp)	; adresse
	move.l	a6,-(sp)	; taille
	bsr.l	clr_zone_rout
	addq.l	#8,sp

	move.l	(sp)+,d0
	move.l	(sp)+,a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*******************************************************
*** Trouve l'objet parent a l'objet d'entree        ***
*******************************************************
* retour : d0 contient l'index du parent
	XDEF		trouve_parent_routine
trouve_parent_routine
	movem.l		d7/a0/a5-a6,-(sp)
	move.l		20+0(sp),a6
	move.w		20+4(sp),d7
trouve_parent_boucle
	trouve_objc	a6,d7
	move.l		a0,a5
	trouve_objc	a6,ob_next(a5)
	cmp.w		ob_tail(a0),d7
	beq		.objet_pere_trouve
	move.w		ob_next(a5),d7
	bra		trouve_parent_boucle

.objet_pere_trouve
	move.w		ob_next(a5),d0
	movem.l		(sp)+,d7/a0/a5-a6
	rts								; le resultat est dans d0

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
******************************************************************
*** Macro servant pour les radios boutons : on cherche l'objet ***
*** selectionne avant le cilc sur un radio                     ***
******************************************************************
	XDEF	trouve_bouton_precedent_routine
trouve_bouton_precedent_routine
*on cherche l'adresse de l'objet pour savoir si il est radio
	movem.l		d5-d7/a0/a5,-(sp)
	move.l		24+0(sp),a5
	move.w		24+4(sp),d7

	trouve_parent	d7,a5
	move.w		d0,d6

	trouve_objc	a5,d6
	move.w		ob_head(a0),d5
.loop
	trouve_objc	a5,d5
	move.w		ob_flags(a0),d0
	btst		#RBUTTON,d0
	beq		.passauboutonsuivant
	move.w		ob_states(a0),d0
	btst		#SELECTED,d0
	bne		.suite
	move.w		ob_next(a0),d5
	cmp.w		d6,d5
	beq		.error
	bra		.loop
.suite
	move.w		d5,d0	; resultat dans d0
	movem.l		(sp)+,d5-d7/a0/a5
	rts
.passauboutonsuivant
	move.w		ob_next(a0),d5
	bra		.loop

.error
	move.w		#-1,d0
	movem.l		(sp)+,d5-d7/a0/a5
	rts
*** merci pour la routine de mul en long xaz...
*---------------------------------------------------------------*
* Routine de multiplication de 2 ULONG en 68000 (equivalent de mulu.l en 68030)
* Pr‚ : d0.l et d1.l -> valeurs … multiplier
* Post : d0.l : r‚sultat (=$FFFFFFFF en cas d'overflow)
	XDEF	xmul_routine
xmul_routine
	movem.l	d1-d2,-(sp)
	move.l	16+4(sp),d0
	move.l	16+0(sp),d1
	swap	d0
	swap	d1

	tst.w	d0			; Teste MSW
	beq.s	D0inf10000	; d0 < $1 0000

	exg.l	d0,d1

	tst.w	d0			; Teste MSW autre valeur
	bne.s	FinOverflow	; >$1 0000 => Overflow

D0inf10000
	swap	d0			; d0.w -> valeur 1
	move.w	d1,d2		; d2.w -> MSW valeur 2
	swap	d1			; d1.w -> LSW valeur 2

	mulu.w	d0,d1		; d1.l -> Partie basse
	mulu.w	d2,d0		; d0.l -> Partie haute / $1 0000 451
	swap	d0			; d0 = d0 * $1 0000
	tst.w	d0			; Overflow ?
	bne.s	FinOverflow	; Oui

	add.l	d1,d0		; On ajoute les 2 parties
	bhs.s	FinMyMulu	; Overfow ?

FinOverflow
	moveq.l	#-1,d0		; On renvoie $FFFF FFFF

FinMyMulu
	movem.l	(sp)+,d1-d2
	rts

**********************************************
*** Effacement rapide d'une zone de donnee ***
**********************************************
	XDEF	clr_zone_rout
clr_zone_rout
	movem.l	d0-d5/a2,-(sp)
	move.l	32(sp),d0	; la taille
	beq.s	.bss_end

	moveq.l	#0,d2
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5

	move.l	32+4(sp),a2	; l'adresse
	add.l	d0,a2	;… la fin
	moveq	#$3f,d1
	and.l	d0,d1
	lsr.l	#4+2,d0	;/64 octets
	beq.s	.pas_64
		
.clr_bss64
	movem.l	d2-d5,-(a2)
	movem.l	d2-d5,-(a2)
	movem.l	d2-d5,-(a2)
	movem.l	d2-d5,-(a2)
	subq.l	#1,d0
	bne.s	.clr_bss64
.pas_64
	moveq	#$f,d0
	and	d1,d0
	lsr	#4,d1
	beq.s	.pas_16
.clr_bss16
	movem.l	d2-d5,-(a2)
	subq	#1,d1
	bne.s	.clr_bss16
.pas_16
	tst	d0
	beq.s	.bss_end
.clr_bss1
	move.b	d2,-(a2)
	subq	#1,d0
	bne.s	.clr_bss1
.bss_end
	movem.l	(sp)+,d0-d5/a2
	rts


;************************************************************* Par David GODEC
;*** Deplacement d'un bloc memoire d'une adresse a l'autre ***
;*************************************************************
; bloc_move(taille,source,destination)
	rsset	4*4
_xfi_n	rs.l	1	; xfer length (bytes)
_xfi_s	rs.l	1	; xfer source
_xfi_d	rs.l	1	; xfer target
	XDEF	bloc_move_rout
bloc_move_rout
	movem.l	d0/a0-a1,-(sp)
	
	move.l	_xfi_s(sp),a0
	move.l	_xfi_d(sp),a1
	
	move.l	_xfi_n(sp),d0
	lsr.l	#4,d0
	beq.s	.no_16_octet
.copy_16
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	
	subq.l	#1,d0
	bgt.s	.copy_16
.no_16_octet
	moveq	#$f,d0
	and.l	_xfi_n(sp),d0
	beq.s	.exit
.copy_1
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bgt.s	.copy_1
.exit
	movem.l	(sp)+,d0/a0-a1
	rts

*************************************
*** conversion en chaine decimale ***
*************************************
*; d0.l=valeur(modifi‚)
*; a0.l=pointeur chaine(modifi‚)
*; d1.w=nombre de chiffres(modifi‚)
*; d2.l modifi‚
	XDEF	long_2_chaine_rout
long_2_chaine_rout
	movem.l	d0-d2/a0,-(sp)
	move.l	20+6(sp),d0
	move.l	20+2(sp),a0
	move.w	20+0(sp),d1
	lea	(a0,d1.w),a0
.yo
	divul.l	#10,d2:d0
	add.w	#"0",d2
	move.b	d2,-(a0)

	subq.w	#1,d1
	bgt.s	.yo

	movem.l	(sp)+,d0-d2/a0
	rts

****************************************************
*** Dessine un rectangle de coordonnees X,Y,W,H ****
****************************************************
	XDEF	v_rect_rout
v_rect_rout
	movem.l	d1/d2/d4-d7/a0-a2,-(sp)
	move.w	40+6(sp),d4
	move.w	40+4(sp),d5
	move.w	40+2(sp),d6
	move.w	40+0(sp),d7
	move.w	d4,ptsin
	move.w	d5,ptsin+2
	move.w	d6,ptsin+4
	move.w	d5,ptsin+6
	v_pline	#2
;	v_bar	d4,d5,d6,d5
	move.w	d4,ptsin
	move.w	d7,ptsin+2
	move.w	d6,ptsin+4
	move.w	d7,ptsin+6
	v_pline	#2
;	v_bar	d4,d7,d6,d7
	move.w	d4,ptsin
	move.w	d5,ptsin+2
	move.w	d4,ptsin+4
	move.w	d7,ptsin+6
	v_pline	#2
;	v_bar	d4,d5,d4,d7
	move.w	d6,ptsin
	move.w	d5,ptsin+2
	move.w	d6,ptsin+4
	move.w	d7,ptsin+6
	v_pline	#2
;	v_bar	d6,d5,d6,d7
	movem.l	(sp)+,d1/d2/d4-d7/a0-a2
	rts

********************************************************************************************
*** Idem fonction objc_calc mais demande le numero de l'objet et l'adresse du formulaire ***
********************************************************************************************
	XDEF	objc_size_rout
objc_size_rout
	movem.l		d4-d7/a0/a5/a6,-(sp)

	move.l		32+6(sp),a6	; adresse arbre
	move.w		32+4(sp),d7	; index objet
	move.l		32+0(sp),a5	; tableau de retour
	trouve_objc	a6,d7
	move.l		a5,-(sp)
	move.l		a0,-(sp)
	bsr		objc_calc		
	addq.l		#8,sp

	objc_offset	a6,d7
	move.w		int_out+2,d4
	move.w		int_out+4,d5
	add.w		0(a5),d4
	add.w		2(a5),d5

	move.w		4(a5),d6
	sub.w		0(a5),d6
	addq.w		#3,d6		; toutes les coordonnees
	move.w		d6,4(a5)

	move.w		6(a5),d7
	sub.w		2(a5),d7
	addq.w		#3,d7		; sont elargies
	move.w		d7,6(a5)

	subq.w		#1,d4		; de 1 pixels
	subq.w		#1,d5		; de chaques cotes
	move.w		d4,0(a5)
	move.w		d5,2(a5)

	movem.l		(sp)+,d4-d7/a0/a5/a6
	rts
**********************************************************
*** Trouve les VRAI coordonnees affiche d'un objet AES ***
**********************************************************
		XDEF	objc_calc
objc_calc		
		; aes_objc_calc (object,array)
		; calcule les dimensions d'un objet
		
		; object: pointeur sur objet aes
		; array: pointeur sur tableau de retour (8 short)
		
		; (cf. vq_extent)
		rsset	8
_oca_obj	rs.l	1
_oca_array	rs.l	1
		
		****
AesObjcCalc
		link	a6,#0
		movem.l	d0-d5/a0-a4,-(sp)

		move.l	_oca_obj(a6),a0
		
		****
		
		; il faut retrouver les paramŠtres
		; du cadre selon le type d'objet...
		
		moveq	#0,d0
		move.b	ob_type+1(a0),d0
		sub.w	#20,d0
		
		jsr	([.get_spec.w,pc,d0.w*4])
		
		; retour des paramŠtres en d4
		
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		
		; calcul x2,y2
		
		move.w	ob_w(a0),d2
		subq.w	#1,d2
		
		move.w	ob_h(a0),d3
		subq.w	#1,d3
		
		move.w	d0,a1
		move.w	d1,a2
		move.w	d2,a3
		move.w	d3,a4
		
		; %100=fond3d %110=activateur %010=indicateur
		
		moveq	#%110,d5
		and.b	ob_flags(a0),d5
		beq.s	.no_3d
		
		subq	#%100,d5
		beq	.no_3d
		
		; petit ajustement 3d
		
		subq.w	#2,d0
		subq.w	#2,d1
		addq.w	#2,d2
		addq.w	#2,d3
.no_3d

		btst	#SHADOWED,ob_states+1(a0)
		beq	.no_shadow

		add.w	#2,d2
		add.w	#2,d3

.no_shadow
		btst	#DEFAULT,ob_flags+1(a0)
		beq	.no_default

		subq.w	#1,d0
		subq.w	#1,d1
		addq.w	#1,d2
		addq.w	#1,d3

.no_default
		****
		
		; calcul pour le cadre
		
		tst.w	d4
		beq.s	.cadre_nul
		bmi.s	.cadre_ext
.cadre_int
		add.w	d4,a1
		sub.w	d4,a3
		add.w	d4,a2
		sub.w	d4,a4
		bra.s	.cadre_ok
.cadre_ext
		add.w	d4,d0
		add.w	d4,d1
		sub.w	d4,d2
		sub.w	d4,d3
.cadre_ok
		****
.cadre_nul
		; teste si effet 'outline'
		
		btst.b	#4,ob_states+1(a0)
		beq.s	.ok_cadre
		
		; si le cadre est interne on clippe 
		; sur l'effet 'outline' et si le cadre
		; est externe ET plus ‚pais on clippe sur
		; celui-ci ...
		
		moveq	#4,d5
		add.w	d4,d5
		bmi.s	.ok_cadre
		
		subq.w	#2,d0
		subq.w	#2,d1
		addq.w	#2,d2
		addq.w	#2,d3
.ok_cadre
		****
		
		; coordonn‚es internes dans a1-a4
		; coordonn‚es externes dans d0-d3
		
		move.l	_oca_array(a6),a0
		movem.w	d0-d3/a1-a4,(a0)
		
		****
.fin
		movem.l	(sp)+,d0-d5/a0-a4
		unlk	a6
		rts
		
		****
		****
.get_spec:
		dc.l	.cas_1	; gbox
		dc.l	.cas_2	; gtext
		dc.l	.cas_2	; gboxtext
		dc.l	.cas_3	; gimage
		dc.l	.cas_3	; guserdef
		dc.l	.cas_1	; gibox
		dc.l	.cas_4	; gbutton
		dc.l	.cas_1	; gboxchar
		dc.l	.cas_3	; gstring
		dc.l	.cas_2	; gftext
		dc.l	.cas_2	; gfboxtext
		dc.l	.cas_3	; gicon
		dc.l	.cas_3	; gtitle
		dc.l	.cas_3	; gcicon
		dc.l	.cas_3	; gbounding
		dc.l	.cas_3	; gbounded
		dc.l	.cas_3	; gpix
		dc.l	.cas_3	; gline
		dc.l	.cas_3	; gcheck
		
		****
		
		; cas #1
		; lecture cadre depuis l'obspec
.cas_1
		move.b	ob_spec+1(a0),d4
		extb.l	d4
		
		rts
		
		****
		
		; cas #2
		; lecture cadre depuis ted-info
.cas_2
		move.w	([ob_spec.w,a0],te_thickness.w),d4
		ext.l	d4
		rts
		
		****
		
		; cas #3
		; pas de cadre
.cas_3		
		moveq	#0,d4
		rts
		
		****
		
		; cas #4
		; cadre implicite du bouton standard
.cas_4
		moveq	#-1,d4
		rts		

********************************************************************************
*** Realise un popup avec le bouton et le morceau d'arbre donne en parametre ***
********************************************************************************
	XDEF	popup_rout
popup_rout
	movem.l	d1-a6,-(sp)
	move.l	60+8(sp),a5	; a5 = adresse du formulaire clique pour appeler le popup
	move.w	60+6(sp),d6	; d6 = index de l'objet sur lequel on a clique pour appeler le popup
	move.l	60+2(sp),a6	; a6 = adresse du formulaire ou trouver le popup racine
	move.w	60+0(sp),d7	; d7 = index de l'objet racine du popup

* On cherche le g_string correspondant a celui qui etait selectionne
	trouve_objc	a5,d6
	move.l		ob_spec(a0),a4	; adresse du texte selectionne avant
	trouve_objc	a6,d7
	move.w		ob_head(a0),d5
.lp_seach_g_string
	move.l		a4,a2
	trouve_objc	a6,d5
	move.l		ob_spec(a0),a3

.lp_cmp_string
	cmp.b		(a3)+,(a2)+	; Compare les deux chaine
	bne		.different
	tst.b		(a3)
	beq		.continu_test_fin_chaine
	bra		.lp_cmp_string
.continu_test_fin_chaine
	tst.b		(a2)
	beq		.pareil

.different
	move.w		ob_next(a0),d5
	cmp.w		d5,d7
	beq		.error2
	bra		.lp_seach_g_string

.pareil
	move.l		a0,a4	; adresse de l'objet dans le popup correspondant a l'objet clique
* D5 contien maintenant l'index de l'objet correspondant au popup cliquer pour derouler
* Centre l'objet racine du popup deroule sur l'objet clique, et ce en fonction de l'objet selectionne avant
	move.w		#0,ob_x(a6)
	move.w		#0,ob_y(a6)
	move.w		x_max,ob_w(a6)	; boite racine du formulaire contenant un ou plusieurs popup(s)
	move.w		y_max,ob_h(a6)	; aux dimentions de l'ecran

	objc_offset	a5,d6
;	move.l		a5,-(sp)
;	move.w		d6,-(sp)
;	move.l		#pop_ob_size
;	jsr		objc_size
;	lea		10(sp),sp

	move.w		int_out+2,d3	; X et
	move.w		int_out+4,d4	; Y de l'objet clique
;	trouve_objc	a5,d6

	sub.w		ob_x(a4),d3
	sub.w		ob_y(a4),d4	; et maintenant X et Y de l'objet root du popup deroule

	move.w		d3,d1	; coordonnees en bas a gauche du popup deroule
	move.w		d4,d2
	trouve_objc	a6,d7
	add.w		ob_w(a0),d1
	add.w		ob_h(a0),d2

* Verrification de debordement a l'ecran
	cmp.w		x_max,d1
	blt		.pas_trop_a_droite
	move.w		x_max,d3
	sub.w		ob_w(a0),d3
.pas_trop_a_droite

	cmp.w		y_max,d2
	blt		.pas_trop_en_bas
	move.w		y_max,d4
	sub.w		ob_h(a0),d4
.pas_trop_en_bas

	tst.w		d3
	bgt		.pas_trop_a_gauche
	moveq.l		#0,d3
.pas_trop_a_gauche

	cmp.w		hauteur_menu,d4
	bgt		.pas_trop_en_haut
	move.w		hauteur_menu,d4
.pas_trop_en_haut

	move.w		d3,ob_x(a0)	; placement de la corrdonnee de l'objet popup
	move.w		d4,ob_y(a0)

* Delai d'attente avant affichage
	move.l		#mnsetdata,a3
	menu_settings	#0,a3
	evnt_timer	(a3)

* Dessin du popup
	objc_draw	a6,d7,#20,#0,#0,x_max,y_max
	move.w		#-2,last_pop_objc		; permet de faire le 1er redraw de l'objet sous la sourie

	wind_update	#1
	wind_update	#3
* On selectionne l'objet selectionnable non grise sous la sourie et on le redraw si il est different du precedent trouve
.popup_mainloop
	objc_find	a6,d7,#20,x_mouse_clik,y_mouse_clik
	move.w		d0,d4
	cmp.w		#-1,d4
	beq		.no_object
	cmp.w		last_pop_objc,d4	; identique a celui de la boucle precedente ???
	beq		.first_pop
	cmp.w		#-2,last_pop_objc
	beq		.first_pop

	trouve_objc	a6,last_pop_objc		; deselection de l'objet sous la sourie avant le deplacement
	btst		#DISABLED,ob_states+1(a0)
	bne		.first_pop
	bclr		#SELECTED,ob_states+1(a0)	; si celui-ci est different de l'objet sous la sourie maintenant
	objc_size	a6,last_pop_objc,#pop_ob_size
	objc_draw	a6,d7,#20,pop_ob_size,pop_ob_size+2,pop_ob_size+4,pop_ob_size+6

.first_pop
	trouve_objc	a6,d4
	btst		#DISABLED,ob_states+1(a0)
	bne		.no_object
	btst		#SELECTABLE,ob_flags+1(a0)
	beq		.no_object
	btst		#SELECTED,ob_states+1(a0)
	bne		.no_object
	bset		#SELECTED,ob_states+1(a0)	; selection de l'objet sous la sourie
	objc_draw	a6,d4,#20,#0,#0,x_max,y_max
.no_object
	move.w		d4,last_pop_objc
	vq_mouse
	tst		intout
	beq		.souris_relache
* Maintenant on test la sourie. Deux solutions : soit la sourie est maintenue enfonce, soit elle est lache
* La sourie est maintenu enfonce, on attend donc qu'elle soit relache
.drag_evnt_multi
	evnt_multi	#4+2,#1,#1,#0,#1,x_mouse_clik,y_mouse_clik,#1,#1 ; on attend les boutons de la sourie ou un deplacement...
	bra		.suite_popup_evntmulti

* La sourie est relache, on attend donc qu'elle soit clique a nouveau
.souris_relache
	evnt_multi	#2+4,#1,#1,#1,#1,x_mouse_clik,y_mouse_clik,#1,#1

.suite_popup_evntmulti
	move.w		int_out+2,x_mouse_clik
	move.w		int_out+4,y_mouse_clik
	btst		#1,d0			; on a relacher le bouton -> on a donc selectionne l'option
	bne		.mouse_cliked		; sinon, on a bouger la sourie... -> donc on veut selectionner autre-chose
	btst		#2,d0
	bne		.popup_mainloop
	bra		.no_object

.mouse_cliked
	objc_find	a6,d7,#20,x_mouse_clik,y_mouse_clik
	cmp.w		#-1,d0
	beq		.error
	move.w		d0,d4
	trouve_objc	a6,d4
	btst		#DISABLED,ob_states+1(a0)
	bne		.un_obj_non_selectable
	btst		#SELECTABLE,ob_flags+1(a0)
	beq		.error

	bclr		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),d3

* On a selectionne une option de popup et elle est valide
	wind_update	#0
	wind_update	#2

	dial_bouton	a6,d7

	trouve_objc	a5,d6
	move.l		d3,ob_spec(a0)

	xobjc_change	a5,d6

	move.w		d4,d0		; retour = numero du G_STRING selectionne
	movem.l		(sp)+,d1-a6
	rts
* On a selectionne un objet non selectionnable
.un_obj_non_selectable
	wind_update	#0
	wind_update	#2
	bclr		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),d3


	dial_bouton	a6,d7
	xobjc_change	a5,d6

	moveq.l	#-1,d0
	movem.l	(sp)+,d1-a6
	rts

.error
	wind_update	#0
	wind_update	#2
.error2
	dial_bouton	a6,d7
	xobjc_change	a5,d6
	moveq.l	#-1,d0
	movem.l	(sp)+,d1-a6
	rts
	bss
pop_ob_size	ds.w	8
last_pop_objc	ds.w	1
mnsetdata	ds.b	sizeof_mn_set
	text
