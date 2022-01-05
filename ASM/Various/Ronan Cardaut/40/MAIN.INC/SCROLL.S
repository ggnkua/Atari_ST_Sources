;------------------------------------------------------------------------------
; SCROLL pour les fenetres d'IO
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
SCROLL_IO_DOWN::
	move	IO_SIZE,d0
	;beq	SCROLL_IO8_DOWN		;n'existe pas
	cmp	#1,d0
	beq	SCROLL_HA16_DOWN
	cmp	#2,d0
	beq	SCROLL_IO32_DOWN

	bra	SCROLL_IO32_DOWN	;defaut
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
SCROLL_IO_UP::
	move	IO_SIZE,d0
	;beq	SCROLL_IO8_UP		;n'existe pas
	cmp	#1,d0
	beq	SCROLL_HA16_UP
	cmp	#2,d0
	beq	SCROLL_IO32_UP

	bra	SCROLL_IO32_UP		;defaut
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
SCROLL_IO_L::
	move	IO_SIZE,d0
	;beq	SCROLL_IO8_L		;n'existe pas
	cmp	#1,d0
	beq	SCROLL_HA16_L
	cmp	#2,d0
	beq	SCROLL_IO32_L

	bra	SCROLL_IO32_L	;defaut
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
SCROLL_IO_R::
	move	IO_SIZE,d0
	;beq	SCROLL_IO8_R	;n'existe pas
	cmp	#1,d0
	beq	SCROLL_HA16_R
	cmp	#2,d0
	beq	SCROLL_IO32_R

	bra	SCROLL_IO32_R		;defaut
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
SCROLL_IO_DOWN_VITE::
	move	IO_SIZE,d0
	;beq	SCROLL_IO8_DOWN_VITE		;n'existe pas
	cmp	#1,d0
	beq	SCROLL_HA16_DOWN_VITE
	cmp	#2,d0
	beq	SCROLL_IO32_DOWN_VITE

	bra	SCROLL_IO32_DOWN_VITE	;defaut
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
SCROLL_IO_UP_VITE::
	move	IO_SIZE,d0
	;beq	SCROLL_IO8_UP_VITE		;n'existe pas
	cmp	#1,d0
	beq	SCROLL_HA16_UP_VITE
	cmp	#2,d0
	beq	SCROLL_IO32_UP_VITE

	bra	SCROLL_IO32_UP_VITE		;defaut
;------------------------------------------------------------------------------
			
	



SCROLL_D_68_DESA::
**********************************************
** scroll vers le bas de la routine de desa **
**********************************************
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a4
	bsr	dessas_one_bk
	move.l	a4,adr_debut(a0)
	rts

SCROLL_R_68_DESA::
**********************************************
** scroll vers le bas de la routine de desa **
**********************************************
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a4
	addq.l	#2,a4
	move.l	a4,adr_debut(a0)
	rts

SCROLL_L_68_DESA::
**********************************************
** scroll vers le bas de la routine de desa **
**********************************************
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a4
	subq.l	#2,a4
	move.l	a4,adr_debut(a0)
	rts

SCROLL_D_68_DESA_VITE::
****************************************************************
** scroll vers le bas de la routine de desa de plusieurs inst **
****************************************************************
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a4
	move.w	Hauteur(a0),d7
	subq	#2,d7
	;asr	d7	;nb lignes	
	ext.l	d7
	subq	#2,d7				; on scroll vers le bas -1 instruction.
.d	bsr	dessas_one_bk
	dbra	d7,.d
	move.l	a4,adr_debut(a0)
	rts
	
	
		
*************************
** scroll vers le haut **	
*************************
SCROLL_U_68_DESA::
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a4
	move.l	a4,a6
	move.l	a4,a5
.p_encore
	subq.l	#2,a5
	move.l	a5,a4
	bsr	dessas_one_bk
	cmp.l	a4,a6
	bne.s	.p_encore1
	bra.s	.ok_inst
.p_encore1
	move.l	a6,a3
	sub.l	a5,a3
	cmp.l	#16,a3
	ble.s	.p_encore
.ok_inst
	move.l	a5,adr_debut(a0)
	rts

***************************************************
** scroll vers le haut de plusieurs instructions **	
***************************************************
SCROLL_U_68_DESA_VITE::
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a4
	;move.l	a4,a6
	;move.l	a4,a5
	move.w	Hauteur(a0),d7
	subq	#2,d7
	;asr	d7	;nb lignes	
	ext.l	d7
	subq	#1,d7			;hateur de la fenetre en lignes dans d7


;.p_encore
;	subq.l	#2,a5
;	move.l	a5,a4
;	bsr	dessas_one_bk
;	cmp.l	a4,a6
;	bne.s	.p_encore1
;	bra.s	.ok_inst
;.p_encore1
;	move.l	a6,a3
;	sub.l	a5,a3
;	cmp.l	#16,a3
;	ble.s	.p_encore
;.ok_inst
;	move.l	a5,adr_debut(a0)
	
	lsl.l	#1,d7
	sub.l	d7,a4
	
	move.l	a4,adr_debut(a0)
	
	
	rts



********************************************
** les routines de scroll pour le hexedit **
********************************************

;------------------------------------------------------------------------------
; scroll dans les fenetres de 16 bits
;------------------------------------------------------------------------------
SCROLL_HA16_DOWN::
	move.l	d0,-(sp)
	move.w	nb_colonnes(a0),d0
	asl	d0
	ext.l	d0
	add.l	d0,adr_debut(a0)
	move.l	(sp)+,d0
	rts
SCROLL_HA16_UP::
	move.l	d0,-(sp)
	move.w	nb_colonnes(a0),d0
	asl	d0
	ext.l	d0
	sub.l	d0,adr_debut(a0)
	move.l	(sp)+,d0
	rts

SCROLL_HA16_R::
	add.l	#1,adr_debut(a0)
	rts
SCROLL_HA16_L::
	sub.l	#1,adr_debut(a0)
	rts

SCROLL_HA16_DOWN_VITE::
	movem.l	d0-d1,-(sp)
	move.w	nb_colonnes(a0),d0
	asl	d0
	ext.l	d0
	move	Hauteur(a0),d1
	sub	#2,d1
	mulu	d1,d0
	add.l	d0,adr_debut(a0)
	movem.l	(sp)+,d0-d1
	rts
SCROLL_HA16_UP_VITE::
	movem.l	d0-d1,-(sp)
	move.w	nb_colonnes(a0),d0
	asl	d0
	ext.l	d0
	move	Hauteur(a0),d1
	sub	#2,d1
	mulu	d1,d0
	sub.l	d0,adr_debut(a0)
	movem.l	(sp)+,d0-d1
	rts
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; scroll dans les fenetres de 32 bits 
; seule IO existe dasn cette taille
;------------------------------------------------------------------------------
SCROLL_IO32_DOWN::
	move.l	d0,-(sp)
	move.w	nb_colonnes(a0),d0
	asl	#2,d0
	ext.l	d0
	add.l	d0,adr_debut(a0)
	move.l	(sp)+,d0
	rts
SCROLL_IO32_UP::
	move.l	d0,-(sp)
	move.w	nb_colonnes(a0),d0
	asl	#2,d0
	ext.l	d0
	sub.l	d0,adr_debut(a0)
	move.l	(sp)+,d0
	rts

SCROLL_IO32_R::
	add.l	#4,adr_debut(a0)
	rts
SCROLL_IO32_L::
	sub.l	#4,adr_debut(a0)
	rts

SCROLL_IO32_DOWN_VITE::
	movem.l	d0-d1,-(sp)
	move.w	nb_colonnes(a0),d0
	asl	#2,d0
	ext.l	d0
	move	Hauteur(a0),d1
	sub	#2,d1
	mulu	d1,d0
	add.l	d0,adr_debut(a0)
	movem.l	(sp)+,d0-d1
	rts
SCROLL_IO32_UP_VITE::
	movem.l	d0-d1,-(sp)
	move.w	nb_colonnes(a0),d0
	asl	#2,d0
	ext.l	d0
	move	Hauteur(a0),d1
	sub	#2,d1
	mulu	d1,d0
	sub.l	d0,adr_debut(a0)
	movem.l	(sp)+,d0-d1
	rts
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; scroll des fenetres registres 040 et DSP + les fenetres d'infos & co
;------------------------------------------------------------------------------
SCROLL_L_REG::
	move	start_col(a0),d0
	subq	#1,d0
	bmi.s	.FIN
	move	d0,start_col(a0)
.FIN	rts
	
SCROLL_R_REG::
	move	start_col(a0),d0
	add	Largeur(a0),d0
	subq	#2,d0
	cmp	max_col(a0),d0
	bgt	.FIN
	addq.w	#1,start_col(a0)
	
.FIN	rts

SCROLL_D_REG::
	move	start_ligne(a0),d0
	add	Hauteur(a0),d0
	subq	#2,d0
	cmp	max_ligne(a0),d0
	bgt	.FIN
	addq.w	#1,start_ligne(a0)
.FIN	rts

SCROLL_U_REG::
	tst	start_ligne(a0)
	beq.s	.err
	subq.w	#1,start_ligne(a0)
.err	rts

SCROLL_L_REG_VITE::
	move	start_col(a0),d0
	sub	Largeur(a0),d0
	addq	#2,d0
	bpl.s	.OK0
	moveq	#0,d0
.OK0	move	d0,start_col(a0)
	rts
	
SCROLL_R_REG_VITE::
	move	start_col(a0),d0
	add	Largeur(a0),d0
	subq	#2,d0
	move	d0,d1
	add	Largeur(a0),d1
	subq	#2,d1
	cmp	max_col(a0),d1
	ble	.OK0
	move	max_col(a0),d0
	sub	Largeur(a0),d0
	addq	#3,d0
.OK0	move	d0,start_col(a0)
	
	rts


SCROLL_U_REG_VITE::
	move	start_ligne(a0),d0
	sub	Hauteur(a0),d0
	addq	#2,d0
	bpl.s	.OK0
	moveq	#0,d0
.OK0	move	d0,start_ligne(a0)
	rts
	
SCROLL_D_REG_VITE::
	move	start_ligne(a0),d0
	add	Hauteur(a0),d0
	subq	#2,d0

	move	d0,d1
	add	Hauteur(a0),d1
	subq	#2,d1
	cmp	max_ligne(a0),d1
	blt	.OK0
	move	max_ligne(a0),d0
	sub	Hauteur(a0),d0
	addq	#3,d0
.OK0	move	d0,start_ligne(a0)
	
	rts
	


