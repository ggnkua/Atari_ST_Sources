**********************************************
*** librairie de fenetre version 0.10 BETA ***
***                                        ***
*** Par Thomas GOIRAND                     ***
**********************************************
	include	zlib.i
	include	aes.i

	XDEF	wd_create_routine,wd_close_routine,wd_kill_routine
	XDEF	tab_x,tab_y,tab_w,tab_h,tab_adr
	XDEF	tab_adr,tab_rout,tab_kind,tab_type
	XDEF	tab_name,tab_handle,tab_gadget,tab_clic,tab_key
	XREF	appl_name
	text
*******************************************************************************************
*** ouvre une fenetre  : utilise d0                                                     ***
*******************************************************************************************
* Les parametres de wd_create
	
	rsreset
wdc_h		rs.w	1
wdc_w		rs.w	1
wdc_y		rs.w	1
wdc_x		rs.w	1
wdc_adr_create	rs.l	1
wdc_adr		rs.l	1
wd_create_routine
	movem.l		d1-a6,-(sp)
	lea		60(sp),a4

***************************************************************************************************
	find_tab_l	#tab_adr,wdc_adr(a4)		; on verifie qu'on a pas deja cr‚‚ la fenetre
	move.w		d0,d4
	cmp.w		#-1,d0				; demande : si oui, ou on la top si elle est d‚j… ouverte,
	beq		nouvelle_fenettre		; ou on l'ouvre au 1er plan.

* fenetre_deja_cree				; si on a encore le handle de la fenetre,
	move.l		#0,a6
	get_tab		#tab_handle,d4		; alors elle est encore ouverte.
	tst.w		d0
	beq		wd_open_routine
* top_la_fenetre_encore_ouverte
	wind_set2	d0,#10		; alors, on la met au 1er plan au lieu de l'ouvrir
	movem.l		(sp)+,d1-a6
	rts

***************************************************************************************************
nouvelle_fenettre
	find_tab_l	#tab_type,#0			; cherche une place vide dans les tableaux
	move.l		d0,d4
	put_tab_l	#tab_adr,d4,wdc_adr(a4)		; place l'adresse des donnees dans le tableau
	put_tab_l	#tab_type,d4,wdc_adr_create(a4) ; place le type de fenetre
	put_tab_l	#tab_name,d4,#appl_name		; et un nom par defaut.
	put_tab_w	#tab_x,d4,wdc_x(a4)
	put_tab_w	#tab_y,d4,wdc_y(a4)
	put_tab_w	#tab_w,d4,wdc_w(a4)
	put_tab_w	#tab_h,d4,wdc_h(a4)

	move.w		d4,-(sp)
	move.l		wdc_adr_create(a4),a3
	jsr		(a3)		; appel du constructeur specifique au type de fenetre (coordonnees, pointeurs, kind...)
	move.l		d0,a6
* En retour, a6 contient soit :
*        - un pointeur sur une routine modifiant la fenetre une fois cree
*        - 0.l ce qui veut dire pas de routine
	addq.l		#2,sp
wd_open_routine
	get_tab		#tab_x,d4	; on recupŠre les x,y,w,h dans le tableau
	move.w		d0,d3
	get_tab		#tab_y,d4
	move.w		d0,d5
	get_tab		#tab_w,d4
	move.w		d0,d6
	get_tab		#tab_h,d4
	move.w		d0,d7
	get_tab		#tab_kind,d4

	wind_create	d0,d3,d5,d6,d7		; ainsi que le pointeur sur la ligne de texte de la barre
;	clr.l		d2			; de d‚placement de la fenetre. On fait au passage un
	move.w		int_out,d2		; petit wind_set pour que le nom apparaisse correctement
	put_tab_w	#tab_handle,d4,int_out

	get_tab		#tab_name,d4		; on recupere le nom de la fenetre qui a
	move.l		d0,int_in+4		; pue etre modifier par le constructeur specifique.
	wind_set2	d2,#2

.suite
	wind_open	d2,d3,d5,d6,d7
	tst.l		a6
	beq		.end
	move.w		d4,-(sp)
	jsr		(a6)
	addq.l		#2,sp
.end
	movem.l		(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**************************
*** Ferme une fenettre ***
**************************
wd_close_routine
	movem.l		d1-a6,-(sp)
	move.l		60(sp),d7	; des donnees que contien la fennetre
	tst.l		d7
	ble		.ne_fait_rien

	find_tab_l	#tab_adr,d7
	move.w		d0,d6

	clr.l		d7
	get_tab		#tab_handle,d6
	move.w		d0,d7
	tst.w		d0
	beq		.ne_fait_rien

	put_tab_w	#tab_handle,d6,#0	; place une donnee dans le tableau
	wind_close	d7
	wind_delete	d7

.ne_fait_rien
	movem.l		(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*******************************************
*** Ferme une fenettre en la detruisant ***
*******************************************
wd_kill_routine
	movem.l		d1-a6,-(sp)
	move.l		60(sp),d7
	tst.l		d7
	ble		.nothing

	find_tab_l	#tab_adr,d7
	cmp.l		#-1,d0
	beq		.nothing
	move.w		d0,d6

	clr.l		d7
	get_tab		#tab_handle,d6
	move.w		d0,d7
	tst.w		d0
	beq		.nothing

	wind_close	d7
	wind_delete	d7

	put_tab_l	#tab_handle,d6,#0	; place une donnee dans le tableau
	put_tab_l	#tab_x,d6,#0
	put_tab_l	#tab_y,d6,#0
	put_tab_l	#tab_w,d6,#0
	put_tab_l	#tab_h,d6,#0
	put_tab_l	#tab_adr,d6,#0
	put_tab_l	#tab_rout,d6,#0
	put_tab_l	#tab_kind,d6,#0
	put_tab_l	#tab_type,d6,#0
	put_tab_l	#tab_name,d6,#0
	put_tab_l	#tab_handle,d6,#0
	put_tab_l	#tab_gadget,d6,#0
	put_tab_l	#tab_clic,d6,#0
	put_tab_l	#tab_key,d6,#0

.nothing
	movem.l		(sp)+,d1-a6
	rts
*******************************************************************************************
*********************
*** window arrays ***
*********************
	bss
tab_x			ds.l	MAX_WD	; coordonnee en X
tab_y			ds.l	MAX_WD	; coordonnee en Y
tab_w			ds.l	MAX_WD	; coordonnee en W
tab_h			ds.l	MAX_WD	; coordonnee en H
tab_adr			ds.l	MAX_WD	; donnees remplissant la fenetre
tab_rout		ds.l	MAX_WD	; adresse de la routinne redessinant la fenetre
tab_kind		ds.l	MAX_WD	; attribus de la fenetre (closer, mover...)
tab_type		ds.l	MAX_WD	; type de fenetre, definie par les constantes W_FORM,W_TOOL...
tab_name		ds.l	MAX_WD	; pointeur sur le texte de la bare de d‚placement
tab_handle		ds.l	MAX_WD	; handle actuelle de la fenetre
tab_gadget		ds.l	MAX_WD	; pointeur sur les routines de gestions des gadgets
tab_clic		ds.l	MAX_WD	; pointeur sur la routine gerant un clic dans la fenetre
tab_key			ds.l	MAX_WD	; pointeur sur la routine gerant un appuis sur une touche

;	XDEF	_x,_y,_w,_h,_adr,_handle,_rout,_kind,_type,_offset,_name
;_x		ds.l	1
;_y		ds.l	1
;_w		ds.l	1
;_h		ds.l	1
;_adr		ds.l	1
;_handle	ds.l	1
;_rout		ds.l	1
;_kind		ds.l	1
;_type		ds.l	1
;_offset	ds.w	1
;_name		ds.l	1
	text
