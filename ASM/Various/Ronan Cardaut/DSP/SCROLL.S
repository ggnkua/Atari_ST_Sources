	output	d:\centinel\dsp\scroll.o
	incdir	d:\centinel\dsp

	include	d:\centinel\both\define.s
;**************************************
SCROLL_U_DUMP_VITE::
	move	nb_colonnes(a0),d0
	move	Hauteur(a0),d1
	mulu	d1,d0
	sub.l	d0,adr_debut(a0)
	rts
;**************************************
SCROLL_D_DUMP_VITE::
	move	nb_colonnes(a0),d0
	move	Hauteur(a0),d1
	mulu	d1,d0
	add.l	d0,adr_debut(a0)
	rts
;**************************************
;**************************************
SCROLL_U_DUMP::
	move.l	d0,-(sp)
	move	nb_colonnes(a0),d0
	ext.l	d0
	sub.l	d0,adr_debut(a0)
	move.l	(sp)+,d0
	rts
;**************************************
SCROLL_D_DUMP::
	move.l	d0,-(sp)
	move	nb_colonnes(a0),d0
	ext.l	d0
	add.l	d0,adr_debut(a0)
	move.l	(sp)+,d0
	rts
;**************************************
SCROLL_L_DUMP::
	subq.l	#1,adr_debut(a0)
	rts
;**************************************
SCROLL_R_DUMP::
	addq.l	#1,adr_debut(a0)
	rts
;**************************************


;**************************************
SCROLL_U_DISAS::	xref	P_COUNT,DESAS_ONE
	movem.l	d0-a6,-(sp)
	xref	WORK_BUF,a6
	lea	WORK_BUF,a6
	envl	#'CMD'
	envl	#DSP_PDUMP
	subq.l	#2,adr_debut(a0)
	move.l	adr_debut(a0),d0
	envl	d0
	envl	#2
	recl	(a6)+
	recl	(a6)+
	move.l	a0,a1
	lea	-8(a6),a0
	lea	WORK_BUF+8,a6
	clr.l	P_COUNT	
	bsr	DESAS_ONE
	move.l	a1,a0
	cmp.l	#1,P_COUNT
	bne.s	.OK
	addq.l	#1,adr_debut(a0)
.OK	movem.l	(sp)+,d0-a6
	rts
;**************************************
SCROLL_U_DISAS_VITE::	
	move.l	d7,-(sp)
	move	Hauteur(a0),d7
	subq	#3,d7
	bmi.s	.FIN
.LOOP	bsr	SCROLL_U_DISAS
	dbra	d7,.LOOP	
.FIN	move.l	(sp)+,d7
	rts
;**************************************
SCROLL_D_DISAS::	xref	P_COUNT,DESAS_ONE
	movem.l	d0-a6,-(sp)
	lea	WORK_BUF,a6
	envl	#'CMD'
	envl	#DSP_PDUMP
	move.l	adr_debut(a0),d0
	envl	d0
	envl	#2	;2 mots … recevoir
	recl	(a6)+
	recl	(a6)+
	move.l	a0,a1
	lea	-8(a6),a0
	lea	WORK_BUF+8,a6
	clr.l	P_COUNT
	bsr	DESAS_ONE
	move.l	a1,a0
	addq.l	#1,adr_debut(a0)
	cmp.l	#1,P_COUNT
	beq.s	.OK
	addq.l	#1,adr_debut(a0)
.OK	movem.l	(sp)+,d0-a6
	rts
;**************************************
SCROLL_D_DISAS_VITE::	xref	P_COUNT,DESAS_ONE
	move.l	d7,-(sp)
	move	Hauteur(a0),d7
	subq	#3,d7
	bmi.s	.FIN
.LOOP	bsr	SCROLL_D_DISAS
	dbra	d7,.LOOP	
.FIN	
	move.l	(sp)+,d7
	rts
;**************************************


;------------------------------------------------------------------------------
SCROLL_ASCII_RIGHT::
	rts
	
;------------------------------------------------------------------------------
SCROLL_ASCII_LEFT::
	rts
;------------------------------------------------------------------------------
SCROLL_ASCII_DOWN::
	movem.l	a1/d0/d1/d2,-(sp)
	move.l	adr_debut(a0),a1
.LOOP	
	xref	get_a1
	bsr.l	get_a1
	tst	d2
	bne.s	.OK0
	move.b	d1,d0	

	
	beq.s	.OK
	cmp.b	#$d,d0
	beq.s	.OK
	cmp.b	#$a,d0
	beq.s	.OK
	bra.s	.LOOP		
.OK	
	bsr.l	get_a1
	tst	d2
	bne.s	.OK0
	move.b	d1,d0	

	beq.S	.OK	
	cmp.b	#$d,d0
	beq.S	.OK	
	cmp.b	#$a,d0
	beq.S	.OK	
	subq	#1,a1
.OK0
	move.l	a1,adr_debut(a0)
	xref	set_all_flags
	bsr.l	set_all_flags
	movem.l	(sp)+,a1/d0/d1/d2
	rts

;------------------------------------------------------------------------------
SCROLL_ASCII_UP::
	movem.l	a1/d0,-(sp)
	move.l	adr_debut(a0),a1
.LOOP	
	subq	#1,a1
	bsr.l	get_a1
	subq	#1,a1
	tst	d2
	bne.s	.OK
	move.b	d1,d0	

	

	;move.b	-(a1),d0
	beq.s	.LOOP
	cmp.b	#$d,d0
	beq.s	.LOOP
	cmp.b	#$a,d0
	beq.s	.LOOP

.LOOP2	

	subq	#1,a1
	bsr.l	get_a1
	subq	#1,a1
	tst	d2
	bne.s	.OK
	move.b	d1,d0	

	beq.S	.OK	
	cmp.b	#$d,d0
	beq.S	.OK	
	cmp.b	#$a,d0
	beq.S	.OK	
	bra.s	.LOOP2
.OK
	addq	#1,a1	
	move.l	a1,adr_debut(a0)
	bsr.l	set_all_flags
	movem.l	(sp)+,a1/d0
	rts
;------------------------------------------------------------------------------
	
	
;------------------------------------------------------------------------------
	
	
	



;------------------------------------------------------------------------------
; scroll vers le haut
; empeche de monter au dela du d‚but
;------------------------------------------------------------------------------
SCROLL_U_SRC::
	move	Line_nb(a0),d0
	subq	#1,d0
	bne.s	.OK0
	moveq	#1,d0
.OK0	move	d0,Line_nb(a0)
	rts
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; scroll du source vers le bas
; v‚rifie le d‚bordement
;------------------------------------------------------------------------------
SCROLL_D_SRC::
	move	Line_nb(a0),d0
	addq	#1,d0
	cmp	max_ligne(a0),d0
	ble.s	.OK0
	subq	#1,d0
.OK0	move	d0,Line_nb(a0)
	rts
;------------------------------------------------------------------------------
	
;------------------------------------------------------------------------------
; SCROLL … gauche du source
;------------------------------------------------------------------------------
SCROLL_L_SRC::
	move	start_col(a0),d0
	beq.s	.FIN
	subq	#1,d0
	move	d0,start_col(a0)	
.FIN	rts
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; SCROLL … droite du source
; empeche d'aller trop loin
;------------------------------------------------------------------------------
SCROLL_R_SRC::
	move	start_col(a0),d0
	addq	#1,d0
	move	max_col(a0),d1
	sub	Largeur(a0),d1
	addq	#2,d1
	cmp	d1,d0
	ble.s	.OK0		
	subq	#1,d0
.OK0	move	d0,start_col(a0)
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; les scrolls rapides
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; scroll vers le haut de une page
; empeche de monter au dela du d‚but
;------------------------------------------------------------------------------
SCROLL_U_SRC_VITE::
	move	Line_nb(a0),d0
	addq	#2,d0
	sub	Hauteur(a0),d0
	bpl.s	.OK0
	moveq	#1,d0
.OK0	move	d0,Line_nb(a0)
	rts
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; scroll du source vers le bas de une page
; v‚rifie le d‚bordement
;------------------------------------------------------------------------------
SCROLL_D_SRC_VITE::
	move	Line_nb(a0),d0
	subq	#2,d0
	add	Hauteur(a0),d0
	cmp	max_ligne(a0),d0
	ble.s	.OK0
	move	max_ligne(a0),d0
.OK0	move	d0,Line_nb(a0)
	rts
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; SCROLL … gauche de une page du source 
;------------------------------------------------------------------------------
SCROLL_L_SRC_VITE::
	move	start_col(a0),d0
	sub	Largeur(a0),d0
	bpl.s	.OK
	clr	d0
.OK	move	d0,start_col(a0)	
.FIN	rts
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; SCROLL … droite de une page du source
; empeche d'aller trop loin
;------------------------------------------------------------------------------
SCROLL_R_SRC_VITE::
	move	start_col(a0),d0
	add	Largeur(a0),d0
	subq	#2,d0
	move	max_col(a0),d1
	sub	Largeur(a0),d1
	addq	#2,d1
	cmp	d1,d0
	ble.s	.OK
	move	d1,d0
.OK	
	move	d0,start_col(a0)
.FIN	rts

