	include	d:\centinel\both\define.s
	output	d:\centinel\40\main.inc\aff_desa.o
	incdir	d:\centinel\40
	include	d:\centinel\both\LOCALMAC.S
	include 40\macros.s
	xref	COL_ADR,COL_NOR,COL_LAB,COL_FCT,COL_REG,COL_CHG,COL_BKPT,COL_ERR_L,ATTRIBUTE,COL_MENU,COL_DSP
	xref	bkpt,m,TRACE,nombre,affiche_nombre_zero
	xref	dessas_one,affiche_nombre_2,num_func
	xref	ADR_VBR
	xref	ERR_MEM,p_c,get_function_trap
	xref	adr_label,nb_symbols,hash_table,excep,fonction_type,s_a7,LIGNE_BRA,type_excep
	xref	FLAG_EV,is_break,dessas_one_bk,s_buf,pile_test,eval_bkpt,calcule_adresse,ASCII_BUF,forme_curseur
	




GEN_FEN_DISAS::
*******************************************************
** routine qui va se charger de dasassembler le prog **
*******************************************************
	movem.l	d0-a6,-(sp)
	;move.l	ACTIVE_WINDOW,a0
	move.w	Hauteur(a0),d7
	subq	#2,d7
	;asr	d7	;nb lignes	
	ext.l	d7

	subq	#1,d7
	
	
	
	move.l	adr_debut(a0),d0
	bclr	#0,d0			; positionne toujours l'adresse sur du paire
	move.l	d0,a4
	bsr	affiche_fen_dessas
	
	move.l	a2,adr_fin(a0)
	
	movem.l	(sp)+,d0-a6
	rts

	
	
affiche_fen_dessas
*******************************
** adresse de debut dans a4  **
** nb d'instructions dans d7 **
*******************************

	xref	COL_PC
	
	movem.l	d0-a1/a3/a5/a6,-(sp)
	
	move.l	a4,a6

	clr.l	LIGNE_BRA
	move.l	p_c,a4
	bsr.l	dessas_one_bk	
	lea	s_buf,a1
	bsr.l	calcule_adresse
	tst.b	d0
	beq.s	.p_adr
	
	lea	m,a1
	cmp.b	#'D',1(a1)
	bne.s	.p_dbra
	cmp.b	#'B',3(a1)
	bne.s	.p_dbra
	
	move.l	d2,LIGNE_BRA		; si dbra, on prend la 2eme
	bra.s	.p_adr
.p_dbra
	
	move.l	d1,LIGNE_BRA
.p_adr
	move.l	a6,a4
	

	move.l	#ASCII_BUF,a0

	
.o
	bsr	test_symbol

	cmp.w	#$ffff,d7
	beq	.fin

	move.l	a4,d0
	move.l	a4,a6
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move	COL_ADR,ATTRIBUTE
	cmp.l	LIGNE_BRA,a4		; a t on un branchement sur la ligne
	bne.s	.nomr_adr
	move	COL_LAB,ATTRIBUTE
.nomr_adr
	
	
	
	
		
	lea	nombre,a1
	clr	d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c
.d
		
		
	move	COL_NOR,ATTRIBUTE
	move	ATTRIBUTE,(a0)
	
	or	#' ',(a0)+	


	bsr.l	is_break
	tst.w	bkpt
	beq	.p_trouve
	
	
	move.w	(a4),-(sp)		; on sauve le nb de l'execption
	move.w	(a1)+,(a4)	
	move.l	a4,a5
	move	COL_BKPT,ATTRIBUTE
	move	ATTRIBUTE,(a0)
	
	move.w	(a1),d1
	btst	#1,d1
	bne.s	.p_per
	or	#'[',(a0)+
	bra.s	.per
.p_per
	or	#'<',(a0)+
.per
	
	sf	FLAG_EV			; on regarde s'il y a quelque chose aprŠs
	btst	#0,d1
	beq.s	.saut
	st	FLAG_EV
.saut
	
	
	moveq	#0,d0
	move.w	bkpt,d0
	and.l	#$ff,d0
	bsr.l	affiche_nombre_2
	lea	nombre,a2
;.p_z
	
	clr.w	d1
	move.b	(a2)+,d1
	move	ATTRIBUTE,(a0)
	or	d1,(a0)+
	move.b	(a2)+,d1
	move	ATTRIBUTE,(a0)
	or	d1,(a0)+
	
	
	move	ATTRIBUTE,(a0)
	move.w	(a1),d1
	btst	#1,d1
	bne.s	.p_per1
	or	#']',(a0)+
	bra.s	.per1
.p_per1
	or	#'>',(a0)+
.per1
	move	COL_NOR,ATTRIBUTE
	bra.s	.p_ajoute_bk	
.p_trouve
	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+	
	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+	
	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+	
	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+	

.p_ajoute_bk



	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+	
	
	move	#0,d6			; on invalide le changement de couleur
	
	cmp.l	p_c,a4
	bne.s	.K
	move	COL_NOR,ATTRIBUTE	; on met la couleur du pc sur a ligne en cours
	;move	COL_PC,ATTRIBUTE	; on met la couleur du pc sur a ligne en cours
	move	#-1,d6			; on valide le changement de couleur	
	clr.w	d0
	move.b	forme_curseur,d0	; on met la forme de la fleche dans la chaine
	move	ATTRIBUTE,(a0)
	or	d0,(a0)+
	bra.s	.PK
.K
	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+	
.PK


	move.l	a4,a3
	
	
	bsr.l	dessas_one
	tst.w	d7
	beq.s	.p_inc_pc
	move.l	a4,a2
	
.p_inc_pc
	
	
	
	
	
	
	lea	m,a1
.co	move	(a1)+,d2
	beq.s	.ecit
	tst.b	d6
	beq.s	.p_ch_c
	and	#$ff,d2
	or	COL_PC,d2		; on met la couleur soit normale , soit de changement
.p_ch_c
	move	d2,(a0)+
	bra.s	.co
.ecit
	clr	(a0)+
	
	subq.l	#2,a0



	lit_mem.w	a3,d2
	tst.b	ERR_MEM
	bne	.err_m
	cmp.w	#$4afc,d2		; regarde si on a un illegal
	bne	.err_m
	
	subq.l	#4,a3
	lit_mem.l	a3,d2
	tst.b	ERR_MEM
	bne	.err_m
	
	cmp.l	#'CNTL',d2
	bne.s	.err_m
	
	
	subq.l	#2,a3
	move.w	(a3),d2
	sub.w	d2,a3
	
	
	
	subq.w	#1,d2
	move.w	COL_LAB,d0
	move.b	#' ',d0
	
	;rept	10
	;move.w	d0,(a0)+
	;endr


	sub.l	#14,a0
	


	move.b	#'>',d0
	move.w	d0,(a0)+
	move.b	#' ',d0
	move.w	d0,(a0)+
	
.ccc
	move.b	(a3)+,d0
	beq.s	.fghj
	move.w	d0,(a0)+
	dbra	d2,.ccc
.fghj
	move.b	#' ',d0
	move.w	d0,(a0)+
	move.b	#'<',d0
	move.w	d0,(a0)+
	
	
	
.err_m
	

	
	
.ft

.p_bkpt
	;move.b	#10,(a0)+


	cmp.l	p_c,a6
	bne.s	.p_nom
	bsr.l	get_function_trap
	tst.w	excep			; teste pour voir s'il y a un nom a mettre
	beq.s	.p_nom
	lea	fonction_type,a6
	move.w	type_excep,d0
	move.l	(a6,d0.w*4),a6
	move.w	num_func,d0
	move.l	(a6,d0.w*4),a6
	tst.b	(a6)
	beq.s	.p_nom			; si le nom vaut zero
	move	COL_FCT,ATTRIBUTE
	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+
	move	ATTRIBUTE,(a0)
	or	#'<',(a0)+

	clr.w	d1
	
.c1	move.b	(a6)+,d1
	tst.b	-1(a6)
	beq.s	.d1
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c1
.d1
	
	
	move	ATTRIBUTE,(a0)
	or	#'>',(a0)+
	move	COL_NOR,ATTRIBUTE
.p_nom
	
	tst.w	bkpt			; on va regarder si on a une expression
	beq.s	.p_bkpt1		; apres le bkpt 
	move.w	(sp)+,(a5)
	tst.b	FLAG_EV
	beq.s	.p_bkpt1
	moveq	#0,d0
	move.w	bkpt,d0
	subq.l	#1,d0
	mulu	#256,d0
	lea	eval_bkpt,a1
	add.l	d0,a1
	
	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+
	
	move	COL_BKPT,ATTRIBUTE
	move	ATTRIBUTE,(a0)
	or	#'[',(a0)+
	
	clr.w	d1
.copiii	move.b	(a1)+,d1
	tst.b	d1
	beq.s	.xxx
	move	ATTRIBUTE,(a0)
	or	d1,(a0)+
	
	bra.s	.copiii
.xxx
	
	
	
	move	ATTRIBUTE,(a0)
	or	#']',(a0)+
	
	
	
	
	
	move	COL_NOR,ATTRIBUTE
.p_bkpt1


	move	#$000d,(a0)+
	dbra	d7,.o
	
.opi	
	move	COL_NOR,ATTRIBUTE


	move	#$8000,(a0)+
	
	

.fin
	movem.l	(sp)+,d0-a1/a3/a5-a6
	rts
	
	cnop	0,16
	
test_symbol
*****************************************************
** routine qui va afficher le symbol correspondant **
*****************************************************

	movem.l	d0/a1/a2,-(sp)
	move.l	nb_symbols,d0
	beq	.e
	addq.l	#1,d0
	move.l	adr_label,a2


	tst.l	a4
	beq	.e		; si l'adresse est nulle, on sort

	move.l	hash_table,a1
	addq.l	#8,a1
.again
	cmp.l	(a1),a4
	blt.s	.ok1
	addq.l	#8,a1
	tst.l	(a1)
	bne.s	.again
	
	
.ok1
	*--- ici, on prend l'adresse juste avant ---*
	move.l	-4(a1),a2
	
	
	tst.l	a2
	beq	.e


.d	cmp.l	(a2)+,a4
	beq.s	.ok
	tst.L	(a2)+
	bne.s	.d
	bra	.e
.ok

	move.l	(a2)+,a1
	move	COL_LAB,ATTRIBUTE
	
	
	rept	8
	move.w	ATTRIBUTE,(a0)
	or	#'-',(a0)+
	endr

	clr.w	d0
.i	move.b	(a1)+,d0
	move	ATTRIBUTE,(a0)
	or	d0,(a0)+
	tst.b	(a1)
	bne.s	.i
	
	
	
	
	move	COL_NOR,ATTRIBUTE
	
	move	#$000d,(a0)+
	subq.w	#1,d7
.e

	movem.l	(sp)+,d0/a1/a2
	rts

