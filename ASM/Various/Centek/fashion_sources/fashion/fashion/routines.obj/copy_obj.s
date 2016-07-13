	include	aes.i
	include	vdi.i
	include	gemdos.i
	include	zlib.i
	include	structs.s

	include	..\macro.i

* Variables ZLIB
	XREF	tab_handle,tab_adr,tab_type,wd_create_drag_window
	XREF	x_mouse_clik,y_mouse_clik
	XREF	planes,x_max,y_max
	XREF	contrl,hauteur_menu
	XREF	vdi_params
* Quelques messages d'erreurs
	XREF	copy_impossible,copy_impossible2,copy_erreur
*--------------------------------------------------------------------------------------------------------------------------*
* On copie l'objet selectionne est ses fils dans un buffer tampon.
	XDEF	copy_objet_routine
copy_objet_routine
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d7	; l'index de l'objet
	move.l		60+2(sp),a6	; l'adresse du formulaire
	move.l		a6,-(sp)
	move.w		d7,-(sp)
	bsr		copy_to_buff_rout
	addq.l		#6,sp
	bsr		drag_obj_to_mouse

	cmp.w		#0,y_mouse_clik
	bne		.nepas_annuler

	movem.l		(sp)+,d1-a6
	rts

.nepas_annuler

* Puis on regarde ou il faut copier les objets
	wind_find	x_mouse_clik,y_mouse_clik
	tst.w		d0
	bne		.suite_drag
	form_alert	#1,#copy_impossible
	movem.l		(sp)+,d1-a6
	rts
.suite_drag
	move.w		d0,d3
	find_tab_w	#tab_handle,d3
	cmp.l		#-1,d0
	bne		.suite_drag_ok_offset
	form_alert	#1,#copy_erreur
	movem.l		(sp)+,d1-a6
	rts
.suite_drag_ok_offset
	move.w		d0,d7
	get_tab		#tab_type,d7
	cmp.l		#wd_create_drag_window,d0
	beq		.suite_drag2
	form_alert	#1,#copy_impossible2
	movem.l		(sp)+,d1-a6
	rts

* ou dans l'arbre destination doit-on copier le buffer ?
.suite_drag2
	get_tab		#tab_adr,d7
	move.l		d0,a6
	move.l		d0,a4
	objc_find	d0,#0,#201,x_mouse_clik,y_mouse_clik
	move.w		d0,d6	; numero de l'objet qui vat etre le pere.
* On trouve les coordonnes dans l'objet ou l'on vat copier
	objc_offset	a4,d6
	move.w		x_mouse_clik,d0
	move.w		y_mouse_clik,d1
	sub.w		int_out+2,d0
	sub.w		int_out+4,d1
* Enfin on copie les objets dans la destination
	move.w		d0,-(sp)
	move.w		d1,-(sp)
	move.w		d6,-(sp)
	move.l		a6,-(sp)
	bsr		copy_to_formul_rout
	lea		10(sp),sp
* Et on fait un redraw de la fenetre conserne !
	wd_redraw	d7
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF		copy_to_formul_rout
copy_to_formul_rout
	movem.l		d1-a6,-(sp)
	move.l		60+0(sp),a6	; adresse du formulaire
	move.w		60+4(sp),d7	; index de l'objet destination
	move.w		60+6(sp),d6	; Y de l'objet que l'on place
	move.w		60+8(sp),d5	; X idem
* On trouve le dernier objet du formulaire
	move.l		a6,a5
	add.l		#ob_flags+1-24,a5
	moveq.l		#0,d4
boucle_cherche_fin
	addq.w		#1,d4
	lea		24(a5),a5
	btst		#LASTOB,(a5)
	beq		boucle_cherche_fin
	bclr		#LASTOB,(a5)
	add.l		#24-(ob_flags+1),a5	; a5 pointe sur la place vide, et d4 est l'index du 1er objet a rajouter
* On copi tous les objets qu'on a dans le buffer tampon vers le formulaire en rajoutant d4 aux indexs
	move.l		a5,a3
	lea		copy_buff,a4
boucle_rajoute_objc
	move.l		a5,a2
	addq.w		#1,d3
	movem.w		(a4)+,d0-d3
	cmp.w		#-1,d0
	beq		.ob_next_ok
	add.w		d4,d0
.ob_next_ok
	cmp.w		#-1,d1
	beq		.ob_head_ok
	add.w		d4,d1
.ob_head_ok
	cmp.w		#-1,d2
	beq		.ob_tail_ok
	add.w		d4,d2
.ob_tail_ok
	move.w		d0,(a5)+
	move.w		d1,(a5)+
	move.w		d2,(a5)+
	move.w		d3,(a5)+
	move.w		(a4)+,d3
	move.w		d3,(a5)+
	move.w		#6,d1
.boucle_lafin
	move.w		(a4)+,(a5)+
	dbra		d1,.boucle_lafin
	objc_real	a2
	btst		#LASTOB,d3
	beq		boucle_rajoute_objc
* On install alors l'objet dans l'arbre
	trouve_objc	a6,d7
	cmp.w		#-1,ob_head(a0)
	beq		.pas_de_fils
	move.w		ob_head(a0),ob_next(a3)
	move.w		d4,ob_head(a0)
	bra		end_install_obj
.pas_de_fils
	move.w		d4,ob_head(a0)
	move.w		d4,ob_tail(a0)
	move.w		d7,ob_next(a3)
end_install_obj
	move.w		d5,ob_x(a3)
	move.w		d6,ob_y(a3)
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF		copy_to_buff_rout
copy_to_buff_rout
	movem.l		d1-a6,-(sp)
	move.l		60+2(sp),a6	; l'adresse du formulaire
	move.w		60(sp),d7	; l'index de l'objet
	lea		copy_buff,a5
	moveq.l		#0,d6		; compteur d'objet
	trouve_objc	a6,d7
	moveq.l		#11,d0
boucle_copy_1er_objet
	move.w		(a0)+,(a5)+
	dbra		d0,boucle_copy_1er_objet
	move.w		#-1,ob_next-24(a5)

	addq.w		#1,d6
	move.w		d7,-(sp)
	bsr		copy_children
	addq.l		#2,sp
	bset		#LASTOB,ob_flags+1-24(a5)
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
* Routine recursive de copie
copy_children
	movem.l		d2/d3/d5/a0/a3/a4,-(sp)
	move.w		28(sp),d5
	move.w		d6,d3
	trouve_objc	a6,d5
	move.w		ob_head(a0),d4
	cmp.w		#-1,d4
	beq		end_copy_child
	lea		-24(a5),a4
	move.w		d6,ob_head(a4)
boucle_copy_les_enfants
	move.w		d6,d2
	addq.w		#1,d6
	trouve_objc	a6,d4
	moveq.l		#11,d0
boucle_copy_objet
	move.w		(a0)+,(a5)+
	dbra		d0,boucle_copy_objet
	lea		-24(a5),a3
	bclr		#LASTOB,ob_flags+1(a3)
	move.w		d4,-(sp)
	bsr		copy_children
	addq.l		#2,sp
	move.w		d6,ob_next(a3)
	move.w		ob_next-24(a0),d4
	cmp.w		d4,d5
	bne		boucle_copy_les_enfants

fini_liens
	subq.w		#1,d3
	move.w		d3,ob_next(a3)
	move.w		d2,ob_tail(a4)
end_copy_child
	movem.l		(sp)+,d2/d3/d5/a0/a3/a4
	rts

*--------------------------------------------------------------------------------------------------------------------------*
drag_obj_to_mouse
	movem.l		d1-a6,-(sp)
	graf_mouse	#M_OFF	; on cache la sourie...
	move.w	x_mouse_clik,d4
	move.w	y_mouse_clik,d5
	lea	copy_buff,a4
	move.w	d4,ob_x(a4)
	move.w	d5,ob_y(a4)
	move.w	ob_w(a4),d2
	move.w	ob_h(a4),d3
	addq.w	#8,d2
	addq.w	#8,d3			; calcul des coordonnes "elargie" de l'objet a cause du flag AES 3.4
	subq.w	#4,d4
	subq.w	#4,d5

* on calcul la taille en mot de l'objet a deplacer.
;	moveq.l	#0,d6
;	move.w	ob_w(a4),d6	; calcul de la taille en pixel :
;	add.l	#15+8,d6	; 		- on arondi a 16 pixels... on ajoute 8 a cause de la bordure de
;	andi.b	#$f0,d6		; 		- l'AES 3d flag...
;	moveq.l	#0,d7
;	move.w	planes,d7
;	mulu.l	d7,d6		; taille de la destination en word :			* ! et ca passe en 35 mille !
;	lsr.l	#3,d6		;		- nombre de pixel * nombre de plan / 16 bits...

* on fait le Malloc du bloc a deplacer...
;	moveq.l	#0,d7
;	move.w	d3,d7		; calcul de la taille du buffer en octet :
;	mulu.l	d6,d7		;		- taille en Y * taille en mot * 2
;	lsl.l	#1,d7

	move.w	d2,d7		; largeur
	add.w	#15,d7
	and.w	#$fff0,d7	; arondi a 16 au dessus
	mulu.w	d3,d7		; * hauteur

	moveq.l	#0,d6
	move.w	planes,d6
	mulu.l	d6,d7	; * nbr plan
;	add.l	#7,d7
;	lsr.l	#3,d7	; / 8 bits
;	movem.l	d1-a6,-(sp)
	move.l	d2,-(sp)
	Malloc	d7
	move.l	(sp)+,d2
;	movem.l	(sp)+,d1-a6

********************************************
* on rempli les mfdb source et destination *
********************************************
	move.l		#mfdb_dest,a5
	move.l		#mfdb_source,a6
	move.l		d0,(a5)					; adresse de la dest.

	clr.l		(a6)			; mfdb ecran : on place l'adresse a 0, et la VDI remplie le reste pour nous
	move.w		d2,larg_pixel(a5)
	move.w		d3,haut_pixel(a5)

	moveq.l		#0,d0
	move.w		d2,d0
	add.l		#15,d0
	lsr.l		#4,d0		; largeur en mot de la source...
	move.w		d0,larg_mot(a5)

	clr.w		format(a5)				; format = ecrant
	move.w		planes,nbr_plan(a5)

* tableau de word X1, Y1, X2, Y2 pour la source et destination -> intin
	move.w		d4,vdi_tp_ptsin	; source
	move.w		d5,vdi_tp_ptsin+2
	move.w		d2,vdi_tp_ptsin+4	; !!! coordonnes en X1 / X2, Y1 / Y2 (vdi rules)
	add.w		d4,vdi_tp_ptsin+4
	sub.w		#1,vdi_tp_ptsin+4
	move.w		d3,vdi_tp_ptsin+6
	add.w		d5,vdi_tp_ptsin+6
	sub.w		#1,vdi_tp_ptsin+6
	clr.w		vdi_tp_ptsin+8		; puis destination
	clr.w		vdi_tp_ptsin+10
	move.w		d2,vdi_tp_ptsin+12
	sub.w		#1,vdi_tp_ptsin+12
	move.w		d3,vdi_tp_ptsin+14
	sub.w		#1,vdi_tp_ptsin+14

* on annoce au gem qu'on vat monopolise l'ecran
;	form_dial	#0,#0,#0,#0,#0,d4,d5,d2,d3

* on reserve une petite place...
	bss
mfdb_source		ds.b	mfdb_size
mfdb_dest		ds.b	mfdb_size
	text
***
*** boucle de deplacement : merci le Dolmen !
***
	wind_update	#1
	wind_update	#3
draging_loop

* on sauvegarde la surface sur laquelle on fait un redraw de l'objet...
* on dessine l'objet au bonnes coordonnes...
* on attent que la sourie ai bouge...
* sourie_bouge + clik
;	illegal
	XREF		vdi_params
	move.l		vdi_params+8,save_global
	move.l		#vdi_tp_ptsin,vdi_params+8
	vro_cpyfm	#3,#mfdb_source,#mfdb_dest	; sauvegarde de ce qui est sous l'objet
	move.l		save_global,vdi_params+8
	objc_draw	a4,#0,#200,d4,d5,d2,d3		; affichage de l'objet
drag_evnt_multi
	evnt_multi	#2+4,#$102,#3,#0,#1,x_mouse_clik,y_mouse_clik,#1,#1
* qu'elle est bouge ou qu'on ai clique, on redessinne le fond...
	lea		vdi_tp_ptsin,a1
	move.l		(a1),d0
	move.l		4(a1),d1
	move.l		8(a1),d6
	move.l		12(a1),d7	; pour cela, on inverse source et destination...

	move.l		d6,(a1)
	move.l		d7,4(a1)
	move.l		d0,8(a1)
	move.l		d1,12(a1)

	move.l		vdi_params+8,save_global
	move.l		#vdi_tp_ptsin,vdi_params+8
	vro_cpyfm	#3,#mfdb_dest,#mfdb_source	; restauration du fond
	move.l		save_global,vdi_params+8


drag_suite
	move.w		int_out,d0
	btst		#1,d0			; on a clique -> on veut donc deposer l'objet
	bne		drag_mouse_clik	; sinon, on a bouger la sourie... et il faut update l'ecran
	btst		#2,d0
	bne		mouse_moved
	bra		drag_evnt_multi	; on n'accepte que ces 2 messages...

mouse_moved
	move.l		#vdi_tp_ptsin,a1
	move.l		(a1),8(a1)
	move.l		4(a1),12(a1)		; on replace la destination

	move.w		int_out+2,d4
	move.w		int_out+4,d5
	cmp.w		#4,d4
	bge		.suite1
	move.w		#4,d4
.suite1
	cmp.w		hauteur_menu,d5
	bge		.suite2
	move.w		hauteur_menu,d5
.suite2
	move.w		d4,x_mouse_clik
	move.w		d5,y_mouse_clik
	move.w		d4,ob_x(a4)
	move.w		d5,ob_y(a4)
	subq.w		#4,d4
	subq.w		#4,d5
	move.w		d4,(a1)
	move.w		d5,2(a1)
	add.w		d4,4(a1)
	add.w		d5,6(a1)

	bra		draging_loop

* gestion des redraw
drag_mouse_clik
;	move.w		int_out+6,d0		; numero du bouron de sourie
	wind_update	#0
	wind_update	#2
	form_dial	#3,#0,#0,#0,#0,d4,d5,d2,d3
	graf_mouse	#M_ON
	Mfree		mfdb_dest
	cmp.w		#1,int_out+6		; si bouton gauche, alors
	beq		.annuler		; on annule la copie
	move.w		int_out+2,x_mouse_clik
	move.w		int_out+4,y_mouse_clik
	movem.l		(sp)+,d1-a6
	rts
.annuler
	move.w		#0,y_mouse_clik
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	bss
copy_buff	ds.b	24*256
vdi_tp_ptsin	ds.w	16
save_global	ds.l	1