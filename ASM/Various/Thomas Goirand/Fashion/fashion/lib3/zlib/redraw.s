******************************
*** sub-routines de redraw ***
********************************************************************
* en paramŠtre on a :                                              *
* tampon+6             : handle de la fenetre                      *
* tampon+8 … tampon+14 : coordonn‚es AES de la fenetre a redessiner*
********************************************************************
	include	aes.i
	include	vdi.i
	include	zlib.i
	XREF	tampon

	XREF	tab_x,tab_y,tab_w,tab_h,tab_handle
	XREF	tab_adr,tab_kind,tab_type,tab_name
	XREF	tab_gadget,tab_clic,tab_rout

	XDEF	redraw
	text
redraw
	wind_update	#1			; on interdit et on efface la sourie
	graf_mouse	#256			; desactive

	clr.l		d0
	move.w		tampon+6,d0
	find_tab_w	#tab_handle,d0		; on cherche l'offcet dans le tableau des fenetres
	get_tab		#tab_kind,d0		; et on recupere les attribus de la fenetre a redessiner
	move.w		d0,d4

	wind_get	tampon+6,#5
	wind_calc	#1,d4,int_out+2,int_out+4,int_out+6,int_out+8
*-----------*
* on calcule les dimentions interieur de la fenetre en
* coordonnes AES, puis en coordonnee VDI.
*-----------*
	move.w	int_out+2,d0	; wx1 = x
	move.w	d0,wx1
	move.w	int_out+4,d1	; wy1 = y
	move.w	d1,wy1
	move.w	int_out+6,d2	; wx2 = x+w-1
	move.w	d2,wh
	add.w	d0,d2
	subq.w	#1,d2
	move.w	d2,wx2
	move.w	int_out+8,d3	; wy2 = y+h-1
	move.w	d3,ww
	add.w	d1,d3
	subq.w	#1,d3
	move.w	d3,wy2

*coordonnees du premier rectangle de redraw : sous fonction WF_FIRSTXYWH
	wind_get	tampon+6,#11	; coordonees 1er rectangle redraw

	move.w	int_out+2,d0	; rdx1 = x
	move.w	d0,rdx1
	move.w	int_out+4,d1	; rdy1 = y
	move.w	d1,rdy1
	move.w	int_out+6,d2	; rdx2 = x+w-1
	move.w	d2,rdw
	move.w	d2,d7
	add.w	d0,d2
	subq.w	#1,d2
	move.w	d2,rdx2
	move.w	int_out+8,d3	; rdy2 = y+h-1
	move.w	d3,rdh
	add.w	d1,d3
	subq.w	#1,d3
	move.w	d3,rdy2

redraw_loop:
	tst.w	d7		; si la largeur a redessiner est
	beq	end_redraw	; nul cela veut dire plus de redraw

*on fait l'intersection du rectangle tampon et de celui
*que nous donne WF_FIRSTXYWH ou WF_NEXTXYWH (sous fonction #11 de WIND_GET)

	bsr	intersect	; si les rectangle ne se chevauche
	tst.w	d0		; pas : on ne redessine pas !!!
	beq	redraw_suite

*puis on redessine
	bsr	graf				; on saute a la routine d'affichage
							; de partition.
redraw_suite:
*coordonnees des rectangle de redraw suivants : sous fonction #12 WF_NEXTXYWH
	wind_get	tampon+6,#12	; coordonees rectangle redraw suivant

	move.w	int_out+2,d0	; rdx1 = x
	move.w	d0,rdx1
	move.w	int_out+4,d1	; rdy1 = y
	move.w	d1,rdy1
	move.w	int_out+6,d2	; rdx2 = x+w-1
	move.w	d2,rdw
	move.w	d2,d7
	add.w	d0,d2
	subq.w	#1,d2
	move.w	d2,rdx2
	move.w	int_out+8,d3	; rdy2 = y+h-1
	move.w	d3,rdh
	add.w	d1,d3
	subq.w	#1,d3
	move.w	d3,rdy2
	bra	redraw_loop			; on boucle pour pouvoir reafficher
						; plusieur parties de fenetre
end_redraw:
	vs_clip		#0,#0,#0,#0,#0		; on desactive le cliping VDI
	wind_update	#0			; et on reactive la sourie
	graf_mouse	#257			; active

	rts

intersect:
* intersection de rectangle
; parametres : rdx1 = wind_get 11/12 redraw_x1
;              rdy1 = wind_get 11/12 redraw_y1
;              rdw  = wind_get 11/12 redraw_w
;              rdh  = wind_get 11/12 redraw_h
; retour : d0=0 -> pas d'intersection
;          d0=1 -> intersection
	move.w	rdx1,d1
	move.w	rdy1,d2
	move.w	rdw,d3
	move.w	rdh,d4

	cmp.w	tampon+8,d1		; x_tampon > rdx1 ?
	bgt	itrs_1
	move.w	tampon+8,cord_x		; oui cord_x = rdx1
	bra	itrs_2
itrs_1	move.w	d1,cord_x		; sinon cord_x = x_tamon

itrs_2	cmp.w	tampon+10,d2		; y_tampon > rdy1 ?
	bgt	itrs_3
	move.w	tampon+10,cord_y	; oui cord_y = rdy1
	bra	itrs_4
itrs_3	move.w	d2,cord_y		; sinon cord_y = y_tamon

itrs_4	move.w	tampon+8,d0		; x1+...___\ tampon_x2
	add.w	tampon+12,d0		; ...w1    /
	add.w	d3,d1				; x2+w2 ---> redraw_x2
	cmp.w	d1,d0				; x2+w2 < x1+w1 ?
	blt	itrs_5
	move.w	d1,cord_x2			; cord_x2=x1+w1
	bra	itrs_6
itrs_5	move.w	d0,cord_x2
itrs_6	sub.w	#1,cord_x2

	move.w	tampon+10,d0		; y1+...   \ y2_tampon
	add.w	tampon+14,d0		; ...h1    /
	add.w	d4,d2				; y2+h2
	cmp.w	d2,d0				; y2+h2 < y1+h1 ?
	blt	itrs_7
	move.w	d2,cord_y2
	bra	itrs_8
itrs_7	move.w	d0,cord_y2
itrs_8	sub.w	#1,cord_y2

	clr.w	d0
	move.w	cord_x2,d1
	cmp.w	cord_x,d1			; cord_x2<cord_x
	blt	itrs_9					; alors erreur
	move.w	cord_y2,d1			; pareil pour les y :
	cmp.w	cord_y,d1			; cord_y2<cord_y
	blt	itrs_9					; alors erreur
	move.w	#1,d0

itrs_9	rts

*******************************************************
*** redessine : redessine l'interieur d'une fenetre ***
*******************************************************
*ici, on place la routine de redraw "maison", CAD on dessine la zone
*rectangle a chaque appele de cette fonction en observant
*les coordonnees du rectangle donne par le GEM et celles de la fenetre.
graf	vsf_interior	#0
	vsf_perimeter	#0

	move.w	cord_x,d4
	move.w	cord_y,d5
	move.w	cord_x2,d6
	move.w	cord_y2,d7
	sub.w	d4,d6
	sub.w	d5,d7
	addq.w	#1,d6
	addq.w	#1,d7
	move.w	d6,cord_w
	move.w	d7,cord_h

	clr.l		d0
	move.w		tampon+6,d0
	find_tab_w	#tab_handle,d0		; on cherche l'offcet dans le tableau des fenetres
	move.l		#window_work_border,a6

	move.w		d0,d3			; d3 contient l'offset dans les tableaux
; vs_clip : on clip le rectangle a redessiner
	get_tab		#tab_rout,d0		; et on recupere l'adresse de la routine de redraw
	move.l		d0,a5

********************************************************************************************
*** routines gerants tous types de redraw                                                ***
***--------------------------------------------------------------------------------------***
*** l'adresse de la routine et des donnes sont deja instal‚ dans                         ***
*** les tableaux de fenetre                                                              ***
*** la routine REDRAW (appel‚ apres chaques event_message = wd_redraw) saute a wd_redes- ***
*** sine.                                                                                ***
***--------------------------------------------------------------------------------------***
*** param. : tampon+6              -> handle de la fenetre                               ***
***          wx1,wy1,wx2,wy2,wh,ww -> coordonnes de la surface de travail de la fenetre  ***
***                                                    a redessiner en format VDI et AES ***
***          d4 … d7               -> coordonnees X,Y,W,H du rectangle a redessiner      ***
***          d3                    -> offset dans les tableaux                           ***
********************************************************************************************
	vs_clip		#1,d4,d5,cord_x2,cord_y2
	jmp		(a5)	; et on y saute...
	vs_clip		#0,d4,d5,cord_x2,cord_y2

	vsf_perimeter	#1
	rts

	bss
*---------*
* coordonnes de la sufrace de travail de la fenetre a redessiner
window_work_border
wx1	ds.w	1
wy1	ds.w	1
wx2	ds.w	1
wy2	ds.w	1
wh	ds.w	1
ww	ds.w	1
*---------*
rdx1	ds.w	1
rdy1	ds.w	1
rdw	ds.w	1
rdx2	ds.w	1
rdh	ds.w	1
rdy2	ds.w	1
cord_x	ds.w	1
cord_y	ds.w	1
cord_x2	ds.w	1
cord_y2	ds.w	1
cord_w	ds.w	1
cord_h	ds.w	1
*********************************
* Quelques variables locales... *
*********************************
	text
