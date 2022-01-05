	output	d:\centinel\both\hexedit.o
	incdir	d:\centinel\dsp

	include	d:\centinel\both\define.s

EDITOR::	xref	ACTIVE_WINDOW,set_all_flags
	movem.l	d0-a6,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	cmp	#T_reg_68,d0
	beq.S	.FIN
	cmp	#T_disas_68,d0
	beq.S	.FIN
	cmp	#T_ASCII,d0
	beq.S	.FIN
	
	bsr	HEXEDIT
.FIN	jsr	set_all_flags
	xref	forme_bra
	bsr.l	forme_bra
	
	movem.l	(sp)+,d0-a6
	rts



HEXEDIT	xref	TITRE,CORP,BOTTOM,get_key,TAB_GEN,TAB_GEN_INV
	xref	COL_40,COL_DSP,COL_QUICC,COL_FEN
	move	type(a0),d0
	jsr	([TAB_GEN.l,d0.w*4])
	bsr	INIT_POSXY	;cherche 1er champ ‚ditable
	bmi	.FIN		;erreur
	clr	SCROLL_FLAG_DOWN
	clr	SCROLL_FLAG_UP
.LOOP_ED
	move	type(a0),d0
	move	COL_40,d1
	cmp	#T_dernier,d0
	ble.s	.OK
	cmp	#T_dsp_dernier,d0
	bgt.s	.QUI
	move	COL_DSP,d1
	bra.S	.OK
.QUI	move	COL_QUICC,d1
.OK	move	d1,COL_FEN


	jsr	([TAB_GEN.l,d0.w*4])	;genere ascii

	bsr	TRAITE_BUFFER	;genere curseur
	bsr	TITRE		;
	bsr	CORP		;
	bsr	BOTTOM		;affiche
	bsr	get_key		;lit une touche
	move.l	d0,SAVE_CAR
	cmp.b	#$1,d0
	beq.s	.FIN		;ESC ?
	bsr	gere_touche	;place la touche en RAM ou deplacement
	move	type(a0),d0
	jsr	([TAB_GEN_INV.l,d0.w*4])	;genere ASCII->RAM

	*--------------------*
	* Scroll vers le bas
	*--------------------*

	tst	SCROLL_FLAG_DOWN
	beq.s	.OK0
	move	nb_colonnes(a0),d0
	ext.l	d0
	cmp	#T_reg,type(a0)
	bge.s	.DSP
	add.l	d0,d0			;en 68k 1 colonne = 2.b
.DSP	
	add.l	d0,adr_debut(a0)
	clr	SCROLL_FLAG_DOWN

	*--------------------*

.OK0
	*--------------------*
	* Scroll vers le haut
	*--------------------*

	tst	SCROLL_FLAG_UP
	beq.s	.OK1
	move	nb_colonnes(a0),d0
	ext.l	d0
	cmp	#T_reg,type(a0)
	bge.s	.DSP2
	add.l	d0,d0			;en 68k 1 colonne = 2.b
.DSP2	
	sub.l	d0,adr_debut(a0)
	clr	SCROLL_FLAG_UP

	*--------------------*
.OK1

	bra	.LOOP_ED

.FIN	st	flag_aff(a0)
	rts
MODE_EDIT::	dc	0
key_valid::	dc	0

TAB_TAB	dc.l	NULL_ROUT		;reserved
	dc.l	NULL_ROUT,NULL_ROUT,FIND_SAME,TAB_HEXASCII16,NULL_ROUT,NULL_ROUT,NULL_ROUT,NULL_ROUT,NULL_ROUT,NULL_ROUT

	rept	10
	dc.l	NULL_ROUT
	endr

NULL_ROUT
	rts

TAB_HEXASCII16
;trouve le no du char de la pos 
;et calcule la pos pour le no de char de l'autre type
	lea	MASK_BUF,a5
	move	POSY,d7
	subq	#1,d7
	bmi.s	.FOUND_Y
.LY	move.b	(a5)+,d0
	beq.s	.NXT
	cmp.b	#$d,d0
	beq.s	.NXT
	cmp.b	#$a,d0
	bne.s	.LY
.NXT	dbra	d7,.LY
.FOUND_Y
	move.l	a5,a3
	move	POSX,d0
	subq	#1,d0
	bmi.s	.X_DONE

	moveq	#0,d1
	move.b	MODE_EDIT,d2
.LX	cmp.b	(a5)+,d2
	bne.s	.OK00
	addq	#1,d1
.OK00	dbra	d0,.LX
.X_DONE
;d1=pos en type sur la ligne	


	cmp.b	#'A',MODE_EDIT
	beq	.GO_HEX
	move	#'AA',MODE_EDIT
	asr	d1
	bra	.SUITE
.GO_HEX	move	#'HH',MODE_EDIT
	add	d1,d1
.SUITE	move.l	a3,a5	
	moveq	#0,d0
	move	MODE_EDIT,d2
	;subq	#1,d1
	;bpl.s	.LOOP
	;moveq	#0,d1
.LOOP	
	cmp.b	(a5)+,d2
	beq.s	.FO
	addq	#1,d0
	bra.s	.LOOP
.FO	
	addq	#1,d0
	dbra	d1,.LOOP	
	subq	#1,d0
	move	d0,POSX	
.OK0	rts


FIND_SAME	xref	SCROLL_DOWN,MASK_BUF
	movem.l	d0/d1/d6/d7/a1,-(sp)
	move.l	ptr_car_mask,a1
	move.b	MODE_EDIT,d0
	move	POSX,d6
	move	POSY,d7
	addq	#1,a1
	addq	#1,d6
.LOOP
	move.b	(a1)+,d1
	beq.s	.END		;fin du buffer
	cmp.b	#' ',d1
	beq.s	.LOOP2
	cmp.b	#$d,d1
	beq.s	.CR
	addq	#1,d6
	bra.S	.LOOP
.LOOP2
	move.b	(a1)+,d1
	beq.s	.END2
	cmp.b	d0,d1
	beq.s	.OK
	cmp.b	#$d,d1
	beq.s	.CR2
	addq	#1,d6
	bra.S	.LOOP2

.OK	addq	#1,d6
	move	d6,POSX
	move	d7,POSY
	movem.l	(sp)+,d0/d1/d6/d7/a1
	rts
.END			;scroll bas necessaire
	
	st	SCROLL_FLAG_DOWN
	;bsr	SCROLL_DOWN
	move.b	MODE_EDIT,d0
	subq	#1,d7	;remet y correct
	subq	#2,a1	;retour avant $d,$0
.SEARCH	cmp.b	#$d,-(a1)
	bne.s	.SEARCH
	addq	#1,a1
	clr	d6
	bra.S	.LOOP

.CR	; passage … la ligne suivante
	clr	d6
	addq	#1,d7
	bra	.LOOP
.END2			;scroll bas necessaire
	st	SCROLL_FLAG_DOWN
	;bsr	SCROLL_DOWN

	move.b	MODE_EDIT,d0
	subq	#1,d7	;remet y correct
	subq	#2,a1	;retour avant $d,$0
.SEARC2	cmp.b	#$d,-(a1)
	bne.s	.SEARC2
	addq	#1,a1
	clr	d6
	bra.S	.LOOP2

.CR2	; passage … la ligne suivante
	clr	d6
	addq	#1,d7
	bra	.LOOP2
;******************************************	
gere_touche
	movem.l	d1/a0,-(sp)
	clr	key_valid
	swap	d0
	move.b	d0,d1	;d1=code ascii
	swap	d0
	cmp.b	#$48,d0
	beq	.haut
	cmp.b	#$50,d0
	beq	.bas
	cmp.b	#$4b,d0
	beq	.gauc
	cmp.b	#$4d,d0
	beq	.droi	;d'abord les fleches

	cmp.b	#9,d1
	bne.s	.NOTAB
	move	type(a0),d2
	jsr	([TAB_TAB.l,d2.w*4])	;GERE LA TOUCHE TAB
	BRA	.FIN
.NOTAB
	cmp.b	#'H',MODE_EDIT
	beq	.HEXA
	cmp.b	#'A',MODE_EDIT
	beq	.ASCII
	cmp.b	#'F',MODE_EDIT
	beq	.FRAC24
;***************************************
.FRAC24	bra	.FIN
;***************************************
.ASCII	;toutes les touches sont valides en ASCII (sauf tab..)
	bra	.OK
;***************************************
.HEXA	;test de la validit‚ des touches hexa
	cmp.b	#'0',d1
	blt	.FIN
	cmp.b	#'9',d1
	ble	.OK
	cmp.b	#'A',d1
	blt	.FIN
	cmp.b	#'F',d1
	ble	.OK
	cmp.b	#'a',d1
	blt	.FIN
	cmp.b	#'f',d1
	bgt	.FIN
	and	#$ff-$20,d1	
	bra	.OK
;**************************************

;*** gestion des fleches **************
.haut	bsr	find_haut
	bra.s	.ERROR
.bas	bsr	find_bas
	bra.s	.ERROR
.gauc	bsr	find_gauc
	bra.s	.ERROR
.droi	bsr	find_droi
	bra.s	.ERROR	
;**************************************
.OK	;ICI ON UN CAR VALIDE 
	st	key_valid
	move.l	ptr_car,a0
	move.b	d1,1(a0)	
	bsr	find_droi
	MOVEQ	#0,D1		;RENVOIE OK RAM … changer
.FIN	movem.l	(sp)+,d1/a0
	rts
.ERROR	moveq	#-1,d1		;pas de chgmnt RAM
	movem.l	(sp)+,d1/a0
	rts
;******************************************	
;**** le curseur se d‚cale de 1 CAR … droite
find_droi
	xref	SCROLL_DOWN,MASK_BUF
	movem.l	d0/d1/d6/d7/a1,-(sp)
	move.l	ptr_car_mask,a1
	move.b	MODE_EDIT,d0
	move	POSX,d6
	move	POSY,d7
	addq	#1,a1
	addq	#1,d6
.LOOP
	move.b	(a1)+,d1
	beq.s	.END
	cmp.b	d0,d1
	beq.S	.OK
	cmp.b	#$d,d1
	beq.s	.CR
	addq	#1,d6
	bra.S	.LOOP
.OK	move	d6,POSX
	move	d7,POSY
	movem.l	(sp)+,d0/d1/d6/d7/a1
	rts
.END			;scroll bas necessaire
	;illegal
	;bsr	SCROLL_DOWN
	*--------------*
	* scrolle la fenetre de 1 vers le bas
	*--------------*
	st	SCROLL_FLAG_DOWN
	*--------------*
	move.b	MODE_EDIT,d0
	subq	#1,d7	;remet y correct
	subq	#2,a1	;retour avant $d,$0
.SEARCH	cmp.b	#$d,-(a1)
	bne.s	.SEARCH
	addq	#1,a1
	clr	d6
	bra.S	.LOOP

.CR	; passage … la ligne suivante
	clr	d6
	addq	#1,d7
	bra	.LOOP
;******************************************	
;******************************************	
;**** le curseur se d‚cale de 1 CAR … gauche
find_gauc
	xref	SCROLL_UP,MASK_BUF
	movem.l	d0/d1/d6/d7/a1,-(sp)
	move.l	ptr_car_mask,a1
	move.b	MODE_EDIT,d0
	move	POSX,d6
	move	POSY,d7
	subq	#1,d6
.LOOP
	cmp.l	#MASK_BUF,a1
	beq.s	.END		;on sort du buffer en haut
	move.b	-(a1),d1
	cmp.b	d0,d1
	beq.S	.OK
	cmp.b	#$d,d1
	beq.s	.CR
	subq	#1,d6
	bra.S	.LOOP
.OK	move	d6,POSX
	move	d7,POSY
	movem.l	(sp)+,d0/d1/d6/d7/a1
	rts
.END			;scroll bas necessaire
	st	SCROLL_FLAG_UP
	;bsr	SCROLL_UP
	clr	d7	;remet y correct
	clr	d6
.SEARC1	addq	#1,d6
	cmp.b	#$d,(a1)+
	bne.s	.SEARC1
	subq	#1,a1
	subq	#2,d6
	bra.S	.LOOP

.CR	; passage … la ligne precedante
	;remise … 0 de posx et recalcul de la nvlle pos
	subq	#1,d7
.SC	
	cmp.l	#MASK_BUF,a1
	blt.s	.OK0		;on sort du buffer en haut
	cmp.b	#$d,-(a1)
	bne.s	.SC
.OK0	clr	d6
	addq	#1,a1
.SC2	cmp.b	#$d,(a1)+		
	beq.s	.OK1
	addq	#1,d6
	bra.s	.SC2
.OK1	subq	#1,a1
	subq	#1,d6

	bra.s	.LOOP
	
;******************************************	

;******************************************	
;**** le curseur se d‚cale de 1 CAR en bas
find_bas
	xref	SCROLL_DOWN,MASK_BUF
	movem.l	d0/d1/d6/d7/a1,-(sp)
	move.l	ptr_car_mask,a1
	move.b	MODE_EDIT,d0
.LOOP	cmp.b	#$d,(a1)+
	bne.s	.LOOP
	tst.b	(a1)
	beq	.END		;deborde ?
	addq	#1,POSY	;ok descend...
.OK	movem.l	(sp)+,d0/d1/d6/d7/a1
	rts
.END			;scroll bas necessaire
	st	SCROLL_FLAG_DOWN
	;bsr	SCROLL_DOWN
	bra.s	.OK
;******************************************	
	
;******************************************	
;**** le curseur se d‚cale de 1 CAR en haut
find_haut
	xref	SCROLL_UP
	movem.l	d0/d1/d6/d7/a1,-(sp)
	move.l	ptr_car_mask,a1
	move.b	MODE_EDIT,d0
	move	POSX,d6
	move	POSY,d7
	subq	#1,d7	
	bmi.s	.END
.OK	move	d6,POSX
	move	d7,POSY
	movem.l	(sp)+,d0/d1/d6/d7/a1
	rts
.END			;scroll bas necessaire
	clr	d7
	st	SCROLL_FLAG_UP
	;bsr	SCROLL_UP
	bra.s	.OK

;******************************************	
INIT_POSXY	xref	MASK_BUF
;recherche le premier champ ‚ditable
;sauve ses coord...sauve son type ds mode edit
;si yen a pas renvoie -1
	moveq	#0,d6
	moveq	#0,d7
	lea	MASK_BUF,a1
.LOOP	move.b	(a1)+,d1
	beq	.ERROR
	cmp.b	#$d,d1
	bne.s	.NOCR
	addq	#1,d7
	bra.s	.LOOP
.NOCR	cmp.b	#'H',d1
	beq.S	.FOUND
	cmp.b	#'A',d1
	beq.S	.FOUND
	cmp.b	#'9',d1
	beq.S	.FOUND
	cmp.b	#'S',d1
	beq.S	.FOUND
	addq	#1,d6
	bra.s	.LOOP
.FOUND	move	d6,POSX
	move	d7,POSY
	move.b	d1,MODE_EDIT
.FIN	moveq	#0,d0
	rts
.ERROR	moveq	#-1,d0
	clr	POSX
	clr	POSY
	
	rts
;**************************************************


;**************************************************
TRAITE_BUFFER		xref	ASCII_BUF
	moveq	#0,d6	;x
	moveq	#0,d7	;y
;recherche de la position du curseur et mise en inverse
;attention , les bords de fenetre sont exclus	
	
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
	move	POSY,d7
	subq	#1,d7
	bmi.s	.OU
.LOOP	move.b	(a5)+,d0
	addq	#2,a6
	cmp.b	#$d,d0
	beq.S	.OK0
	bra.s	.LOOP
.OK0	dbra	d7,.LOOP
.OU
	move	POSX,d6
	subq	#1,d6
	bmi.s	.FOUND
.LOOP2	addq	#1,a5
	addq	#2,a6
	dbra	d6,.LOOP2

.FOUND
	bset	#6,(a6)
	move.l	a6,ptr_car
	move.l	a5,ptr_car_mask
;.FIN	
	rts

	BSS
ptr_car		ds.l	1		
ptr_car_mask	ds.l	1		
SAVE_CAR	ds.l	1
;******************************************************

	DATA	
		
SCROLL_FLAG_DOWN	dc	0		
SCROLL_FLAG_UP		dc	0		

POSX	dc	8
POSY	dc	1
	
