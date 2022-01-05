	include	d:\centinel\both\define.s
	include d:\centinel\40\macros.s
	output	d:\centinel\both\gestion.o
	incdir	d:\centinel\both
	xref	ERR_MEM,COL_NOR,COL_ERR_L,ATTRIBUTE


EVALUATEUR::
**************************************
** Routine qui va evaluer un chaine **
**************************************
	xref	MESSAGE_ADR,PETIT_MESSAGE,ACTIVE_WINDOW,eval
	xref	GET_CHAINE
.erreur
	xref	AUTO_IO			; autorise l'evaluation des io
	move.w	#-1,AUTO_IO
	
	move.l	#MES_EVAL,a0
	bsr	GET_CHAINE
	tst.b	d0
	beq.s	.annule


	move.l	a2,a0
	
	
	bsr	eval
	tst.b	d2
	bne.s	.erreur
	

	xref	convert_inv
	bsr	convert_inv
	
	
	move.l	a0,MESSAGE_ADR
	move.l	a0,a2
	bsr	PETIT_MESSAGE
	
	move.l	a2,MESSAGE_ADR

	xref	set_all_flags
	bsr	set_all_flags	

.annule
	xref	set_all_flags
	bsr	set_all_flags	
	clr.w	AUTO_IO			; interdit l'eval des io
	rts
	
adresse::
***************************************************
** Routine qui va mettre la fentre a une adresse **
***************************************************
	xref	convert


	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	bne.s	.p_source
.erreur1
	move.l	#MES_ADR_LIGNE,a0
	bsr	GET_CHAINE
	tst.b	d0
	beq	.annule

	move.l	a2,a0
	bsr	eval
	tst.b	d2
	bne.s	.erreur1
	
	tst.w	d1
	beq.s	.erreur
	
	move.l	ACTIVE_WINDOW,a0
	move.l	Src_adr(a0),a1
	move.w	nb_ligne(a1),d0
	cmp.w	d0,d1
	bgt.s	.erreur1
	
	
	
	move.w	d1,Line_nb(a0)
	
	move.l	#MES_OK,a0
	
	move.l	a0,MESSAGE_ADR
	move.l	a0,a2
	bsr	PETIT_MESSAGE
	
	move.l	a2,MESSAGE_ADR
	rts
	
	
	
.p_source

.erreur

	move.l	#MES_ADDR,a0
	bsr	GET_CHAINE
	tst.b	d0
	beq.s	.annule


	move.l	a2,a0
	bsr	eval
	tst.b	d2
	bne.s	.erreur
	
.cont
	move.l	d1,d2
	move.l	ACTIVE_WINDOW,a1
	cmp	#T_disas_68,type(a1)
	bne	.ok
	bclr	#0,d2
.ok	move.l	ACTIVE_WINDOW,a1
	move.l	d2,adr_debut(a1)
	
	move.l	#MES_OK,a0
	
	move.l	a0,MESSAGE_ADR
	move.l	a0,a2
	bsr	PETIT_MESSAGE
	
	move.l	a2,MESSAGE_ADR
.annule

	rts


get_object::
********************************************************************
** Routine qui va chercher un object dans la fenetre et plus loin ** 
********************************************************************
	xref	get_key,AFFICHE,forme_bra,MEM_HAUTE,ADR_VBR,s_a7,TRACE,pile_test
	
	movem.l	d0-a6,-(sp)


.j

	tst.b	(chaine_encore)
	beq.s	.p_e

	lea	chaine_encore+1,a2
	cmp.b	#$23,-1(a2)
	beq	.hexa_again
	bra	.ascii_again
	




.p_e
	move.l	#MES_GET,MESSAGE_ADR

	bsr	PETIT_MESSAGE

	jsr	get_key
	
	
	cmp.b	#1,d0
	beq	.exit



*************************
*** Recherche en hexa ***
*************************

	cmp.b	#$23,d0			; Hexa
	bne	.i
.recom
	move.l	#MES_SEARCH_HEXA,a0
	bsr	GET_CHAINE
	tst.b	d0
	beq	.exit


	lea	chaine_encore,a0
	move.l	a2,a1
	move.b	#$23,(a0)+
.copi	move.b	(a1)+,(a0)+
	bne.s	.copi
.hexa_again
	

	move.l	a2,a0
	moveq	#-1,d1
.po	addq.l	#1,d1
	cmp.b	#'.',(a0)
	beq.s	.z
	tst.b	(a0)+
	bne.s	.po
.z
	
	cmp.l	#16,d1
	bgt	.recom
	
	
	moveq	#0,d0			; dans d5 on a la taille 0 pas d'ext
	cmp.b	#'.',(a0)		; on peut avoir .l .w .b
	bne.s	.e
	
	cmp.b	#'l',1(a0)
	bne.s	.r0
	moveq	#8,d0
	bra.s	.e
.r0	cmp.b	#'L',1(a0)
	bne.s	.r1
	moveq	#8,d0
	bra.s	.e
.r1	cmp.b	#'W',1(a0)
	bne.s	.r2
	moveq	#4,d0
	bra.s	.e
.r2	cmp.b	#'w',1(a0)
	bne.s	.r3
	moveq	#4,d0
	bra.s	.e
.r3	cmp.b	#'b',1(a0)
	bne.s	.r4
	moveq	#2,d0
	bra.s	.e
.r4	cmp.b	#'B',1(a0)
	bne.s	.r5
	moveq	#2,d0
	bra.s	.e
.r5
	moveq	#0,d0			; on a une erreur
.e
	move.l	a2,a0
	
	
	tst.b	d0
	beq.s	.p_point
	
	move.l	d0,d2
	sub.l	d1,d0
	bmi.s	.p_point
	beq.s	.p_point
	subq.l	#1,d0
	lea	temp,a0			; on va ajouter des 0 pour completer
.cop
	move.b	#'0',(a0)+	
	dbra	d0,.cop
	
	move.l	a2,a1
.o	move.b	(a1)+,d1
	cmp.b	#'.',d1
	beq.s	.i1
	cmp.b	#0,d1
	beq.s	.o
	move.b	d1,(a0)+
	bra.s	.o
	
	
.i1
	clr.b	(a0)+
	
	lea	temp,a0
	move.l	a2,a1
.l	move.b	(a0)+,(a1)+
	bne.s	.l
	
	move.l	a2,a0
	
	
	move.l	d2,d1
	
	
.p_point
	
	
	move.l	d1,d5
	
	
	
	bsr	convert			; nbe dans nbe
	
	
	move.l	d0,d6
	move.l	d1,d0
	move.l	#0,d7
	
	
	
	move.l	d5,d1
	
	
	move.l	#MES_SCH,MESSAGE_ADR
	bsr	PETIT_MESSAGE

	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a1	; adresse de depart de la recherche
	
	tst.b	(chaine_encore)		; si on recherche encore, on ajoute un pour prendre le suivant
	beq.s	.p_ch_again
	addq.l	#1,a1
.p_ch_again
	
	
	cmp.b	#8,d1
	beq.s	.k_l		; recherche en long
	cmp.b	#4,d1
	beq	.k_w		; recherche en word
	cmp.b	#2,d1
	beq	.k_b		; recherche en byte
	bra	.k_d		; recherche avec un nb qcq de caractere
	
****************************
.k_l	lit_mem.l	a1,d1
	tst.b	ERR_MEM
	bne.s	.err
	cmp.l	d1,d0			; long
	beq	.ok1
;.suiv1
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq	.abort
.err
	addq.l	#1,a1			; on ajoute que 1 a a1 car la lecture se fait d'octect en octects
	bra	.k_l
****************************	
.k_w	lit_mem.w	a1,d1
	tst.b	ERR_MEM
	bne.s	.err1
	cmp.w	d1,d0			; word
	beq	.ok1
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq	.abort
.err1
	addq.l	#1,a1			; meme remarque que plus haut
	bra	.k_w
****************************
.k_b	lit_mem.b	a1,d1
	tst.b	ERR_MEM
	bne.s	.err2
	cmp.b	d1,d0			; byte
	beq	.ok1
;.suiv3	
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq	.abort
.err2	addq.l	#1,a1
	bra	.k_b
**************************************
** dans d1 on a le nb de caracteres **
** nombre dans d6.d0
** chaine sur a1
***************
*--- recherche sur un deplacement plus grand que 8 ou impair

.k_d	
	move.l	d1,a6
	move.l	d1,d2
	move.l	d0,d1
	move.l	d6,d0
	moveq	#15,d3
	sub.l	d2,d3
	cmp.b	#16,d2
	beq.s	.p_deca
.deca
	rept	4
	lsl.l	d1
	roxl.l	d0
	endr
	dbra	d3,.deca
	
.p_deca	
.k_d1
	move.l	a6,d7
	lit_mem.l	a1,d2
	tst.b	ERR_MEM
	bne	.err3
	move.l	d2,d4
	
	addq.l	#4,a1
	lit_mem.l	a1,d3
	tst.b	ERR_MEM
	bne	.err3
	move.l	d3,d5
	
	subq.l	#4,a1
	
	rept	4			; on decale de 4 bits vers la gauche
	lsl.l	d5
	roxl.l	d4
	endr
	
	
	*-- dans d2.d3 on a (a0) en double --*
	*-- dans d4.d5 on a (a0) en double mais decal‚ de 1 quartet vers la gauche --*
	*-- dans d0.d1 on a la comparaison -- *
	*-- dans d7 on a le nombre de bit … comparer --*
	
	
	
	*-- on effacer les bits en trop dans d2,d3,d4,d5 --*
	
	cmp.b	#8,d7
	bgt.s	.d7_p_grand
	clr.l	d3		; on efface la fin
	clr.l	d5
	
	
	lsl.l	#2,d7
	moveq	#32,d6
	sub.l	d7,d6
	bfclr	d2{d7:d6}
	bfclr	d4{d7:d6}
	
	
	cmp.l	d2,d0
	beq.s	.ok1
	cmp.l	d4,d0
	beq.s	.ok1
	
	bra.s	.p_ok
	
.d7_p_grand
	cmp.l	d2,d0		; comparaison des premiers
	beq.s	.maybe
	cmp.l	d4,d0
	bne.s	.p_ok
.maybe
	
	
	subq.l	#8,d7
	lsl.l	#2,d7
	moveq	#32,d6
	sub.l	d7,d6
	beq.s	.zer		; si on a une recherche sur 16
	bfclr	d3{d7:d6}
	bfclr	d5{d7:d6}
	
	cmp.l	d5,d1
	beq.s	.ok1
.zer
	
	cmp.l	d3,d1
	beq.s	.ok1
	
	
.p_ok
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq	.abort
.err3	addq.l	#1,a1
	bra	.k_d1
	
	
	
	



.ok1
	
	move.l	a1,adr_debut(a0)
	

	move.l	#MES_FOUND,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_FOUND,MESSAGE_ADR
	
	
	bra	.exit


**************************
*** recherche en ascii ***
**************************

.i
	cmp.b	#$14,d0			; Ascii
	bne	.j
	move.l	#MES_SEARCH_ASCII,a0
	bsr	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.exit

	lea	chaine_encore,a0
	move.l	a2,a1
	move.b	#$14,(a0)+
.copi1	move.b	(a1)+,(a0)+
	bne.s	.copi1
.ascii_again


	move.l	#MES_SCH,MESSAGE_ADR
	bsr	PETIT_MESSAGE

	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a1	; adresse de depart de la recherche
	tst.b	(chaine_encore)		; si on recherche encore, on ajoute un pour prendre le suivant
	beq.s	.p_ch_again1
	addq.l	#1,a1
.p_ch_again1
	
	
	
	
.k	move.l	a1,a3			; source
	move.l	a2,a4			; dest
	
.ch	lit_mem.b	a3,d0
	addq.l	#1,a3
	tst.b	ERR_MEM
	bne.s	.suiv
	cmp.b	(a4)+,d0
	bne.s	.suiv
	tst.b	(a4)
	bne	.ch
	bra.s	.ok
.suiv
	
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq.s	.abort
	
	addq.l	#1,a1
	bra	.k
.ok

	move.l	a1,adr_debut(a0)
	move.l	#MES_FOUND,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_FOUND,MESSAGE_ADR

	
	
	
	
	

.exit
	movem.l	(sp)+,d0-a6
	
	rts
	
.abort
	move.l	a1,adr_debut(a0)
	move.l	#MES_N_FD,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_N_FD,MESSAGE_ADR
	movem.l	(sp)+,d0-a6
	rts

get_object_back::
********************************************************************
** Routine qui va chercher un object dans la fenetre et plus loin ** 
********************************************************************
	xref	get_key,AFFICHE,forme_bra,MEM_HAUTE,ADR_VBR,s_a7,TRACE,pile_test
	
	movem.l	d0-a6,-(sp)


.j


	tst.b	(chaine_encore)
	beq.s	.p_e

	lea	chaine_encore+1,a2
	cmp.b	#$23,-1(a2)
	beq	.hexa_again
	bra	.ascii_again
	




.p_e


	move.l	#MES_GET_BACK,MESSAGE_ADR

	bsr	PETIT_MESSAGE

	jsr	get_key
	
	
	cmp.b	#1,d0
	beq	.exit



*************************
*** Recherche en hexa ***
*************************

	cmp.b	#$23,d0			; Hexa
	bne	.i
.recom
	move.l	#MES_SEARCH_HEXA,a0
	bsr	GET_CHAINE
	tst.b	d0
	beq	.exit



	lea	chaine_encore,a0
	move.l	a2,a1
	move.b	#$23,(a0)+
.copi	move.b	(a1)+,(a0)+
	bne.s	.copi
.hexa_again
	


	move.l	a2,a0
	moveq	#-1,d1
.po	addq.l	#1,d1
	cmp.b	#'.',(a0)
	beq.s	.z
	tst.b	(a0)+
	bne.s	.po
.z
	
	cmp.l	#16,d1
	bgt	.recom
	
	
	moveq	#0,d0			; dans d5 on a la taille 0 pas d'ext
	cmp.b	#'.',(a0)		; on peut avoir .l .w .b
	bne.s	.e
	
	cmp.b	#'l',1(a0)
	bne.s	.r0
	moveq	#8,d0
	bra.s	.e
.r0	cmp.b	#'L',1(a0)
	bne.s	.r1
	moveq	#8,d0
	bra.s	.e
.r1	cmp.b	#'W',1(a0)
	bne.s	.r2
	moveq	#4,d0
	bra.s	.e
.r2	cmp.b	#'w',1(a0)
	bne.s	.r3
	moveq	#4,d0
	bra.s	.e
.r3	cmp.b	#'b',1(a0)
	bne.s	.r4
	moveq	#2,d0
	bra.s	.e
.r4	cmp.b	#'B',1(a0)
	bne.s	.r5
	moveq	#2,d0
	bra.s	.e
.r5
	moveq	#0,d0			; on a une erreur
.e
	move.l	a2,a0
	
	
	tst.b	d0
	beq.s	.p_point
	
	move.l	d0,d2
	sub.l	d1,d0
	bmi.s	.p_point
	beq.s	.p_point
	subq.l	#1,d0
	lea	temp,a0			; on va ajouter des 0 pour completer
.cop
	move.b	#'0',(a0)+	
	dbra	d0,.cop
	
	move.l	a2,a1
.o	move.b	(a1)+,d1
	cmp.b	#'.',d1
	beq.s	.i1
	cmp.b	#0,d1
	beq.s	.o
	move.b	d1,(a0)+
	bra.s	.o
	
	
.i1
	clr.b	(a0)+
	
	lea	temp,a0
	move.l	a2,a1
.l	move.b	(a0)+,(a1)+
	bne.s	.l
	
	move.l	a2,a0
	
	
	move.l	d2,d1
	
	
.p_point
	
	
	move.l	d1,d5
	
	
	
	bsr	convert			; nbe dans nbe
	
	
	move.l	d0,d6
	move.l	d1,d0
	move.l	#0,d7
	
	
	
	move.l	d5,d1
	
	
	move.l	#MES_SCH,MESSAGE_ADR
	bsr	PETIT_MESSAGE

	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a1	; adresse de depart de la recherche
	
	tst.b	(chaine_encore)		; si on recherche encore, on ajoute un pour prendre le suivant
	beq.s	.p_ch_again
	subq.l	#1,a1
.p_ch_again
	
	
	cmp.b	#8,d1
	beq.s	.k_l		; recherche en long
	cmp.b	#4,d1
	beq	.k_w		; recherche en word
	cmp.b	#2,d1
	beq	.k_b		; recherche en byte
	bra	.k_d		; recherche avec un nb qcq de caractere
	
****************************
.k_l	lit_mem.l	a1,d1
	tst.b	ERR_MEM
	bne.s	.err
	cmp.l	d1,d0			; long
	beq	.ok1
;.suiv1
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq	.abort
.err
	subq.l	#1,a1			; on ajoute que 1 a a1 car la lecture se fait d'octect en octects
	bra	.k_l
****************************	
.k_w	lit_mem.w	a1,d1
	tst.b	ERR_MEM
	bne.s	.err1
	cmp.w	d1,d0			; word
	beq	.ok1
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq	.abort
.err1
	subq.l	#1,a1			; meme remarque que plus haut
	bra	.k_w
****************************
.k_b	lit_mem.b	a1,d1
	tst.b	ERR_MEM
	bne.s	.err2
	cmp.b	d1,d0			; byte
	beq	.ok1
;.suiv3	
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq	.abort
.err2	subq.l	#1,a1
	bra	.k_b
**************************************
** dans d1 on a le nb de caracteres **
** nombre dans d6.d0
** chaine sur a1
***************
*--- recherche sur un deplacement plus grand que 8 ou impair

.k_d	
	move.l	d1,a6
	move.l	d1,d2
	move.l	d0,d1
	move.l	d6,d0
	moveq	#15,d3
	sub.l	d2,d3
	cmp.b	#16,d2
	beq.s	.p_deca
.deca
	rept	4
	lsl.l	d1
	roxl.l	d0
	endr
	dbra	d3,.deca
	
.p_deca	
.k_d1
	move.l	a6,d7
	lit_mem.l	a1,d2
	tst.b	ERR_MEM
	bne	.err3
	move.l	d2,d4
	
	addq.l	#4,a1
	lit_mem.l	a1,d3
	tst.b	ERR_MEM
	bne	.err3
	move.l	d3,d5
	
	subq.l	#4,a1
	
	rept	4			; on decale de 4 bits vers la gauche
	lsl.l	d5
	roxl.l	d4
	endr
	
	
	*-- dans d2.d3 on a (a0) en double --*
	*-- dans d4.d5 on a (a0) en double mais decal‚ de 1 quartet vers la gauche --*
	*-- dans d0.d1 on a la comparaison -- *
	*-- dans d7 on a le nombre de bit … comparer --*
	
	
	
	*-- on effacer les bits en trop dans d2,d3,d4,d5 --*
	
	cmp.b	#8,d7
	bgt.s	.d7_p_grand
	clr.l	d3		; on efface la fin
	clr.l	d5
	
	
	lsl.l	#2,d7
	moveq	#32,d6
	sub.l	d7,d6
	bfclr	d2{d7:d6}
	bfclr	d4{d7:d6}
	
	
	cmp.l	d2,d0
	beq.s	.ok1
	cmp.l	d4,d0
	beq.s	.ok1
	
	bra.s	.p_ok
	
.d7_p_grand
	cmp.l	d2,d0		; comparaison des premiers
	beq.s	.maybe
	cmp.l	d4,d0
	bne.s	.p_ok
.maybe
	
	
	subq.l	#8,d7
	lsl.l	#2,d7
	moveq	#32,d6
	sub.l	d7,d6
	beq.s	.zer		; si on a une recherche sur 16
	bfclr	d3{d7:d6}
	bfclr	d5{d7:d6}
	
	cmp.l	d5,d1
	beq.s	.ok1
.zer
	
	cmp.l	d3,d1
	beq.s	.ok1
	
	
.p_ok
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq	.abort
.err3	subq.l	#1,a1
	bra	.k_d1
	
	
	
	



.ok1
	
	move.l	a1,adr_debut(a0)
	

	move.l	#MES_FOUND,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_FOUND,MESSAGE_ADR
	
	
	bra	.exit


**************************
*** recherche en ascii ***
**************************

.i
	cmp.b	#$14,d0			; Ascii
	bne	.j
	move.l	#MES_SEARCH_ASCII,a0
	bsr	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.exit

	lea	chaine_encore,a0
	move.l	a2,a1
	move.b	#$14,(a0)+
.copi1	move.b	(a1)+,(a0)+
	bne.s	.copi1
.ascii_again


	move.l	#MES_SCH,MESSAGE_ADR
	bsr	PETIT_MESSAGE

	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a1	; adresse de depart de la recherche
	
	tst.b	(chaine_encore)		; si on recherche encore, on ajoute un pour prendre le suivant
	beq.s	.p_ch_again1
	subq.l	#1,a1
.p_ch_again1
	
	
	
.k	move.l	a1,a3			; source
	move.l	a2,a4			; dest
	
.ch	lit_mem.b	a3,d0
	addq.l	#1,a3
	tst.b	ERR_MEM
	bne.s	.suiv
	cmp.b	(a4)+,d0
	bne.s	.suiv
	tst.b	(a4)
	bne	.ch
	bra.s	.ok
.suiv
	
	cmp.b	#$1,$fffffc02.w		; esc abandonne la recherche
	beq.s	.abort
	
	subq.l	#1,a1
	bra	.k
.ok

	move.l	a1,adr_debut(a0)
	move.l	#MES_FOUND,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_FOUND,MESSAGE_ADR

	
	
	
	
	

.exit
	movem.l	(sp)+,d0-a6
	
	rts
	
.abort
	move.l	a1,adr_debut(a0)
	move.l	#MES_N_FD,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_N_FD,MESSAGE_ADR
	movem.l	(sp)+,d0-a6
	rts

fill::
***************************************
** la routine de remplissage m‚moire **
***************************************
	movem.l	d0-a6,-(sp)
.j
	move.l	#MES_FILL,a0
	bsr	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.exit
	
	move.l	a2,a0			; cherche s'il y a un virgule
.ch	cmp.b	#',',(a0)
	beq.s	.ok1
	tst.b	(a0)+			; non ? => erreur
	bne.s	.ch
	bra.s	.j	
	
.ok1
	clr.b	(a0)
	move.l	a0,a6
	move.l	a2,a0
	bsr	eval			; evalue le premier parametre
	tst.b	d2
	bne	.j
	
	
	move.l	d1,d3		; convertion en hexa en stockage dans d3
	
	
	move.l	a6,a0
	addq.l	#1,a0
.ch1	cmp.b	#',',(a0)
	beq.s	.ok2
	tst.b	(a0)+
	bne.s	.ch1
	bra.s	.j	
.ok2
	clr.b	(a0)
	move.l	a0,a5
	move.l	a6,a0
	addq.l	#1,a0
	
	bsr	eval
	tst.b	d2
	bne	.j
	
	move.l	d1,d4		; sauvegarde de d1
	
	
	move.l	a5,a0
	addq.l	#1,a0
	tst.b	(a0)
	beq	.j
	bsr	eval
	tst.b	d2
	bne	.j
	move.l	d1,d2		; pareil, mais 3eme parametre dans d2
	
	move.l	d4,d1		; restauration de d1
	
	****** dans d3 la source d1 longueur d2 l'octet
	
	
	move.l	d3,a0
.cop	writ_mem.b	d2,a0
	tst.b	ERR_MEM
	bne.s	.err
	
	addq.l	#1,a0
	subq.l	#1,d1
	bne	.cop
	
	
	move.l	#MES_OK,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_OK,MESSAGE_ADR
	
	
.exit
	movem.l	(sp)+,d0-a6
	rts
	
.err
	move.l	#MES_ERR_FILL,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_ERR_FILL,MESSAGE_ADR
	
	movem.l	(sp)+,d0-a6
	rts
	


copy::
*************************************************
** la routine de copie de memoire vers memoire **
*************************************************
	move.l	a7,s_a7
.j

	move.l	#MES_COPY,a0
	bsr	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.exit

	
	move.l	a2,a0			; cherche s'il y a un virgule
.ch	cmp.b	#',',(a0)
	beq.s	.ok1
	tst.b	(a0)+			; non ? => erreur
	bne.s	.ch
	bra.s	.j	
	
.ok1
	clr.b	(a0)
	move.l	a0,a6
	move.l	a2,a0
	bsr	eval			; evalue le premier parametre
	tst.b	d2
	bne	.j
	
	
	move.l	d1,d3		; convertion en hexa en stockage dans d3
	
	
	move.l	a6,a0
	addq.l	#1,a0
.ch1	cmp.b	#',',(a0)
	beq.s	.ok2
	tst.b	(a0)+
	bne.s	.ch1
	bra.s	.j	
.ok2
	clr.b	(a0)
	move.l	a0,a5
	move.l	a6,a0
	addq.l	#1,a0
	
	bsr	eval
	tst.b	d2
	bne	.j
	
	move.l	d1,d4		; sauvegarde de d1
	
	
	move.l	a5,a0
	addq.l	#1,a0
	tst.b	(a0)
	beq	.j
	bsr	eval
	tst.b	d2
	bne	.j
	move.l	d1,d2		; pareil, mais 3eme parametre dans d2
	
	move.l	d4,d1		; restauration de d1
	
	****** dans d3 la source d1 destination d2 la longueur
	
	
	move.l	#MES_COPYING,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	
	move.l	d3,a0
	move.l	d1,a1
	
	tst.l	d2
	beq	.zero
.copy	lit_mem.b	a0,d0
	addq.l	#1,a0
	tst.b	ERR_MEM
	bne	.err_read
	writ_mem.b	d0,a1
	addq.l	#1,a1
	tst.b	ERR_MEM
	bne	.err_wri
	
	subq.l	#1,d2
	bne	.copy

.zero
	move.l	#MES_OK,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	#MES_OK,MESSAGE_ADR
	
.exit
	rts

.err_read
	move.l	#MES_ERR_COP,MESSAGE_ADR	; erreur en lecture
	bsr	PETIT_MESSAGE
	move.l	#MES_ERR_COP,MESSAGE_ADR
	rts
.err_wri
	move.l	#MES_ERR_COP,MESSAGE_ADR	; erreur en ecriture
	bsr	PETIT_MESSAGE
	move.l	#MES_ERR_COP,MESSAGE_ADR
	rts



	BSS
	
chaine_encore::	ds.b	150
temp		ds.b	150

	DATA

	ifne	(LANGUAGE=FRANCAIS)

	*------ FRANCAIS -----*

MES_OK		dc.b	'Operation effectu‚e',0
MES_EVAL	dc.b	'Expression : ',0
MES_ADDR	dc.b	'Adresse : ',0
MES_GET		dc.b	'Cherche  H)exa T)ext',0
MES_GET_BACK	dc.b	'Cherche arriere H)exa T)ext',0
MES_SEARCH_ASCII	dc.b	'Entrez la chaine ascii : ',0
MES_SEARCH_HEXA	dc.b	'Entrez le nombre : ',0
MES_FOUND	dc.b	'Trouv‚',0
MES_SCH		dc.b	'Recherche ...',0
MES_N_FD	dc.b	'Pas trouv‚',0
MES_FILL	dc.b	'Remplir (s,l,o) : ',0
MES_COPY	dc.b	'Copier (s/d/l) : ',0
MES_COPYING	dc.b	'Copie...',0
MES_ERR_COP	dc.b	'Erreur de copie',0
MES_ERR_FILL	dc.b	'Erreur de remplissage',0
MES_ADR_LIGNE	dc.b	'Num‚ro de la ligne : ',0
		even
		endc		

	*------ ANGLAIS -----*
		ifne	(LANGUAGE=ANGLAIS)
MES_OK		dc.b	'Operation done',0
MES_EVAL	dc.b	'Expression : ',0
MES_ADDR	dc.b	'Address : ',0
MES_GET_BACK	dc.b	'Get back H)exa T)ext',0
MES_GET		dc.b	'Get H)exa T)ext',0
MES_SEARCH_ASCII	dc.b	'Enter the ascii string : ',0
MES_SEARCH_HEXA	dc.b	'Enter the number : ',0
MES_FOUND	dc.b	'Found',0
MES_SCH		dc.b	'Searching ...',0
MES_N_FD	dc.b	'Not Found',0
MES_FILL	dc.b	'Fill (s,l,o) : ',0
MES_COPY	dc.b	'Copy (s/d/l) : ',0
MES_COPYING	dc.b	'Copying...',0
MES_ERR_COP	dc.b	'Copy error',0
MES_ERR_FILL	dc.b	'Fill error',0
MES_ADR_LIGNE	dc.b	'Line number : ',0
		even
		endc
		