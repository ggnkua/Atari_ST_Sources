	include	d:\centinel\both\define.s
	output	d:\centinel\40\dessas.o
	incdir	d:\centinel\40
	xref	ERR_MEM,COL_ERR_L
	
	include	macros.s

*****  attention lors du relatif pc prendre une variable avec
*****  le pc+2 dedans



****************************
** Noyau de d‚sassemblage **
** 12/02/97               **
***********************************************
** regarder les cas de movea ( ajouter le a) **
** faire le pmove ,mmusr et le fd et les pxx **
** etonnant avec cas.l	d1,d2,8(a4,d5*4)     **
***********************************************
	
dessas_one::
	xref	s_a7,pile_test,ADR_VBR,TRACE

	movem.l	d0-a3/a5-a6,-(sp)
	
	
; on detourne les erreurs de bus et autres

	clr.l	d0

.k	
	lea	memoire_cou,a0
	moveq	#4,d1
	
	
	pea	(a4)			; on sauve le a4 qui pointe sur le pc

	move.l	a4,d0
	addq.l	#2,d0
	move.l	d0,pcr			; on stocke pour le relatif
	
.cop	lit_mem.l	a4,d0		; copie de la memoire dans un buffer
	addq.l	#4,a4
	move.l	d0,(a0)+
	
	dbra	d1,.cop
	
	
	
	lea	memoire_cou,a4
	clr.l	d0
	move.w	(a4),d0
		
	lea	Table_des_instructions,a0
.cherche
	move.w	d0,d1
	and	(a0)+,d1
	cmp.w	(a0)+,d1
	beq.s	.ok
	lea	16(a0),a0
	bra.s	.cherche
.ok	lea	instruct,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	4(a0),mode_reg		; on copie la table d'autorisation
	clr.w	nb_compt
	jsr	([a0])
	

	move.l	a4,a5
	lea	memoire_cou,a6
	sub.l	a6,a5
	move.l	a5,d0			;dans d0 l'increment de l'instruction
	

	cmp.l	#'CNTL',(a4)
	bne.s	.p_commen
	
	move.l	(sp),a4
	add.l	#8,a4
.ch	cmp.l	#'CNTL',(a4)
	beq.s	.t_com
	addq.l	#1,a4
	bra.s	.ch
.t_com
	add.l	#10,d0		; pour le header
	add.w	-2(a4),d0
	
	
.p_commen
	move.l	(sp)+,a4
	move.l	a4,a5
	move.l	d0,d1
	subq.l	#1,d1




.test	lit_mem.b	a5,d2		; on teste s'il y aune erreur de lecture
	tst.b	ERR_MEM
	bne.s	.err
	dbra	d1,.test
	
	add.l	d0,a4			
	bra.s	.p_err
.err
	addq.l	#2,a4
	lea	m,a0
	move.l	#'Read',(a0)+
	cmp.b	#ADR_INT_L,ERR_MEM
	bne.s	.p_adr
	move.l	#' int',(a0)+
	bra.s	.dfg
.p_adr
	move.l	#' bus',(a0)+
.dfg
	clr.b	(a0)
.p_err



	xref	ATTRIBUTE
	lea	m,a0
	lea	n,a1
	move.w	COL_NOR,ATTRIBUTE
.op
	cmp.l	#'@~CO',(a0)
	bne.s	.r
	clr.w	ATTRIBUTE
	move.b	4(a0),ATTRIBUTE
	
	addq.l	#6,a0
.r
	clr.w	d0
	move.b	(a0)+,d0
	beq.s	.exit
	move	ATTRIBUTE,(a1)
	or	d0,(a1)+
	bra.s	.op
	
.exit
	move	#$8000,(a1)+
	
	
	lea	m,a0
	lea	n,a1
.i	move	(a1)+,(a0)+
	cmp	#$8000,-2(a0)
	bne.s	.i	
	
	clr.w	-2(a0)


	movem.l	(sp)+,d0-a3/a5-a6
	rts




	DATA
Table_des_instructions

******************************************************
* Format:                                            *
* .w masque a appliquer                              *
* .w resultat a obtenir                              *
* mn‚monique                                         *
* pointeur sur la routine qui cherche les registres  *
******************************************************
	include	'desas.inc\table_i.s'	
	include 'desas.inc\table_fp.s'	

	TEXT

lecture_mem_int
******************************************
** on affiche l'interdiction de lecture **
******************************************
	addq.l	#2,a4
	lea	instruct,a6
	move.l	#'Read',(a6)+
	move.l	#' int',(a6)+
	
	clr.b	(a6)
	rts


bcd_reg
*********************************
** calcul pour les instruc bcd **
*********************************

	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	lea	-1(a6),a6
	move.w	d0,d1
	lsr.w	#6,d1
	and.w	#%11,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	btst	#3,d0
	beq.s	.donne
	move.w	d0,d1
	and.w	#%111,d1
	move.l	a6,a5
	move.b	#'-',(a6)+
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	move.b	#',',(a6)+
	move.b	#'-',(a6)+
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	add.b	d1,3(a5)
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%111,d1
	add.b	d1,9(a5)
	bra.s	.sort
.donne
	move.w	d0,d1
	and.w	#%111,d1
	move.l	a6,a5
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,1(a5)
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%111,d1
	add.b	d1,4(a5)
.sort
	add.l	#2,a4			; on passe a l'instruction suivante
	clr.b	(a6)
	rts
	
	
	
*****************************************
** calcul pour les registres d'adresse **
*****************************************
	
reg_adr
	add.l	#2,a4			; au minimun
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	d0,d1
	lsr.w	#6,d1
	move.w	d1,d2
	and.w	#%11,d2
	cmp.b	#%11,d2
	bne	.pas_adr_dest
	sub.l	#1,a6
	move.b	#"A",(a6)+
	move.b	#'.',(a6)+
	lsr.w	#2,d1
	and.w	#1,d1
	cmp.b	#1,d1		; longueur instruct
	bne.s	.short
	move.b	#"L",(a6)+
	bra.s	.t
.short	
	move.b	#"W",(a6)+	
.t
	move.w	d0,d2
	move.w	d0,d3
	and.w	#%111,d2	;registre
	lsr.w	#3,d3
	and.w	#%111,d3	;mode
	move.b	#' ',(a6)+
	jsr	mode
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	bra	.dn_ae
.fin_traitement_adresse
.pas_adr_dest
	move.b	#'.',-(a6)
	lea	1(a6),a6
	
	move.w	d0,d1		; detection de la taille
	lsr.l	#6,d1
	and.w	#%11,d1
	cmp.b	#0,d1
	bne.s	.l1
	move.b	#'B',(a6)+
	bra.s	.s
.l1
	cmp.b	#1,d1
	bne.s	.l2
	move.b	#'W',(a6)+
	bra.s	.s
.l2
	move.b	#'L',(a6)+
.s
	move.b	#' ',(a6)+
	move.w	d1,d3
	move.w	d0,d1
	btst	#8,d1
	beq.s	.ae_dn
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	lsr.l	#8,d1
	lsr.l	#1,d1
	and.b	#%111,d1
	add.b	d1,-1(a6)
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d3,d1
	subq.w	#1,d1
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	jsr	mode
	bra.s	.dn_ae
.ae_dn
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d3,d1
	subq.w	#1,d1
	move.w	d0,d3
	lsr.l	#3,d3
	and.w	#%111,d3
	jsr	mode
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr.l	#8,d1
	lsr.l	#1,d1
	and.b	#%111,d1
	add.b	d1,-1(a6)
.dn_ae
	clr.b	(a6)
	rts


immediat
****************************
** calcul pour l'immediat **
****************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	lea	-1(a6),a6
	move.w	d0,d1
	lsr.w	#6,d1
	and.w	#%11,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	cmp.b	#2,d1
	beq.s	.long
	clr.l	d1
	move.w	(a4)+,d1
	bra.s	.autre
.long
	clr.l	d1
	move.l	(a4)+,d1
.autre
	move.w	d0,d2
	move.l	d1,d0
	move.b	#'#',(a6)+
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
	move.w	d2,d0
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	move.b	#',',(a6)+
	bsr	mode
	clr.b	(a6)	
	rts
	
quick
*****************************************
** fonction qui calcule les quicks adr **
*****************************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	lea	-1(a6),a6
	move.w	d0,d1
	lsr.w	#6,d1
	and.w	#%11,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%111,d1
	tst.b	d1
	bne.s	.p_nul
	addq.b	#8,d1
.p_nul
	move.b	#'#',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
	move.b	#',',(a6)+	
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts

vers_ccr
*********************
** calcul vers ccr **
*********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'#',(a6)+
	move.w	(a4)+,d0
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	move.b	#',',(a6)+
	move.b	#'C',(a6)+
	move.b	#'C',(a6)+
	move.b	#'R',(a6)+
	clr.b	(a6)
	rts
vers_sr
********************
** calcul vers sr **
********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'#',(a6)+
	move.w	(a4)+,d0
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	move.b	#',',(a6)+
	move.b	#'S',(a6)+
	move.b	#'R',(a6)+
	clr.b	(a6)
	rts
	
bkpt
********************
** calcul de bkpt **
********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'#',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	clr.b	(a6)
	rts
	
	
	
add_s_taille
************************************
** on a une adresse a taille fixe **
************************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	;move.b	#' ',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	move.l	#2,d1
	bsr	mode
	clr.b	(a6)
	rts



adr_seule
****************************************	attention a v‚rifier
** on a une adresse a taille variable **
****************************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	lea	-1(a6),a6
	move.w	d0,d1
	lsr.w	#6,d1
	and.w	#%11,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts


tout_tout
*****************************************
** routine tout en source tout en dest **
*****************************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	lea	-1(a6),a6
	move.w	d0,d1
	lsr.l	#8,d1
	lsr.l	#4,d1
	and.w	#%11,d1
	move.b	#'.',(a6)+
	cmp.b	#1,d1
	bne.s	.l2
	move.b	#'B',(a6)+
	moveq	#0,d1	
	bra.s	.exit	
.l2
	cmp.b	#3,d1
	bne.s	.l1
	move.b	#'W',(a6)+
	moveq	#0,d1	
	bra.s	.exit
.l1
	move.b	#'L',(a6)+
	moveq	#1,d1	
	
.exit
	move.b	#' ',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	bsr	mode
	move.b	#',',(a6)+
	move.w	d0,d2
	lsr	#8,d2
	lsr	#1,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#6,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts

no_param
**********************
** pas de parametre **
**********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	lea	-1(a6),a6
	clr.b	(a6)
	rts	
	
dummy
	rts
	
move_vers_sr
*****************
** met dans sr **
*****************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	bsr	mode
	move.b	#',',(a6)+
	move.b	#'S',(a6)+
	move.b	#'R',(a6)+
	clr.b	(a6)
	rts
move_vers_ccr
*****************
** met dans ccr **
*****************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	bsr	mode
	move.b	#',',(a6)+
	move.b	#'C',(a6)+
	move.b	#'C',(a6)+
	move.b	#'R',(a6)+
	clr.b	(a6)
	rts
move_de_sr
*****************
** prend de sr **
*****************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'S',(a6)+
	move.b	#'R',(a6)+
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts

move_de_ccr
*****************
** prend de ccr **
*****************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'C',(a6)+
	move.b	#'C',(a6)+
	move.b	#'R',(a6)+
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts


rtd
********************
** adresse du rtd **
********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	(a4)+,d0
	move.b	#'#',(a6)+
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	clr.b	(a6)
	rts


bcc
******************
** branchements **
******************
	addq.l	#2,a4
	lea	instruct,a6
	addq.l	#1,a6		; pointe apres le b
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#%1111,d1
	move.w	(termi,d1*2),d1
	move.w	d1,d2
	lsr.w	#8,d2
	move.b	d2,(a6)+
	move.b	d1,(a6)+
	tst.b	d0
	beq.s	.word
	cmp.b	#$ff,d0
	beq.s	.long
	move.b	#'.',(a6)+
	move.b	#'S',(a6)+
	move.b	#' ',(a6)+
	btst	#7,d0
	beq.s	.posi
	neg.b	d0
	clr.l	d1
	move.b	d0,d1
	move.l	pcr,d0
	sub.l	d1,d0
	bra.s	.l1
.posi
	clr.l	d1
	move.b	d0,d1
	add.l	pcr,d1
	move.l	d1,d0
	
.l1
	bra.s	.f_r
.word
	move.b	#' ',(a6)+
	clr.l	d1
	move.w	(a4)+,d1
	btst	#15,d1
	beq.s	.posi1
	neg.w	d1
	move.l	pcr,d0
	sub.l	d1,d0
	;subq.l	#2,d0
	bra.s	.l11
.posi1
	add.l	pcr,d1
	move.l	d1,d0
	;subq.l	#2,d0
.l11
	bra.s	.f_r
	
.long
	move.b	#'.',(a6)+
	move.b	#'L',(a6)+
	move.b	#' ',(a6)+
	clr.l	d1
	move.l	(a4)+,d1
	btst	#31,d1
	beq.s	.posi11
	neg.l	d1
	move.l	pcr,d0
	sub.l	d1,d0
	;subq.l	#4,d0
	bra.s	.l111
.posi11
	add.l	pcr,d1
	move.l	d1,d0
	;subq.l	#4,d0
.l111
	
.f_r
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	
	clr.b	(a6)
	
	rts
	
	
termi
	dc.b	'RA','SR','HI','LS'
	dc.b	'CC','CS','NE','EQ'
	dc.b	'VC','VS','PL','MI'
	dc.b	'GE','LT','GT','LE'


moves
****************************
** routine pour les moves **
****************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	lea	-1(a6),a6
	move.w	d0,d1
	lsr	#6,d1
	and.w	#%11,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	move.w	(a4)+,d4
	btst	#11,d4
	bne.s	.mem_reg
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.w	d4,d1
	rol.w	#1,d1
	tst.b	d1
	beq.s	.don
	sub.b	#3,-1(a6)
.don
	move.b	#'0',(a6)+
	move.w	d4,d2
	lsr.w	#8,d2
	lsr.w	#4,d2
	and.w	#%111,d2
	add.b	d2,-1(a6)
	
	bra.s	.reg_mem
.mem_reg
	move.b	#'D',(a6)+
	move.w	d4,d1
	rol.w	#1,d1
	tst.b	d1
	beq.s	.don1
	sub.b	#3,-1(a6)
.don1
	move.b	#'0',(a6)+
	move.w	d4,d2
	lsr.w	#8,d2
	lsr.w	#4,d2
	and.w	#%111,d2
	add.b	d2,-1(a6)
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
.reg_mem
	clr.b	(a6)
	rts
	
	
movec
*********************************
** routine qui traite le movec **
*********************************

	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	(a4)+,d4
	btst	#0,d0
	beq.s	.rc_rn
	move.b	#'A',(a6)+
	btst	#15,d4
	bne.s	.adr
	add.b	#3,-1(a6)
.adr
	move.b	#'0',(a6)+
	move.w	d4,d1
	lsr.w	#8,d1
	lsr.w	#4,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.b	#',',(a6)+
	move.w	d4,d0
	and.w	#%111111111111,d0
	bsr	reg_cont
	bra.s	.rn_rc
.rc_rn
	move.w	d4,d0
	and.w	#%111111111111,d0
	bsr	reg_cont
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	btst	#15,d4
	bne.s	.adr1
	add.b	#3,-1(a6)
.adr1
	move.b	#'0',(a6)+
	move.w	d4,d1
	lsr.w	#8,d1
	lsr.w	#4,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
.rn_rc
	clr.b	(a6)
	rts
	
reg_cont
** sort le registre de controle du moves **
	cmp.w	#0,d0
	bne.s	.1
	move.b	#'S',(a6)+
	move.b	#'F',(a6)+
	move.b	#'C',(a6)+
	bra	.end
.1
	cmp.w	#1,d0
	bne.s	.2
	move.b	#'D',(a6)+
	move.b	#'F',(a6)+
	move.b	#'C',(a6)+
	bra	.end
.2
	cmp.w	#2,d0
	bne.s	.3
	move.b	#'C',(a6)+
	move.b	#'A',(a6)+
	move.b	#'C',(a6)+
	move.b	#'R',(a6)+
	bra	.end
.3
	cmp.w	#$800,d0
	bne.s	.4
	move.b	#'U',(a6)+
	move.b	#'S',(a6)+
	move.b	#'P',(a6)+
	bra	.end
.4
	cmp.w	#$801,d0
	bne.s	.5
	move.b	#'V',(a6)+
	move.b	#'B',(a6)+
	move.b	#'R',(a6)+
	bra	.end
.5
	cmp.w	#$802,d0
	bne.s	.6
	move.b	#'C',(a6)+
	move.b	#'A',(a6)+
	move.b	#'A',(a6)+
	move.b	#'R',(a6)+
	bra	.end
.6
	cmp.w	#$803,d0
	bne.s	.7
	move.b	#'M',(a6)+
	move.b	#'S',(a6)+
	move.b	#'P',(a6)+
	bra	.end
.7
	cmp.w	#$804,d0
	bne.s	.8
	move.b	#'I',(a6)+
	move.b	#'S',(a6)+
	move.b	#'P',(a6)+
	bra	.end
.8
	cmp.w	#$3,d0			; on commence le 40
	bne.s	.9
	move.b	#'T',(a6)+
	move.b	#'C',(a6)+
	bra	.end
.9
	cmp.w	#$4,d0
	bne.s	.10
	move.b	#'I',(a6)+
	move.b	#'T',(a6)+
	move.b	#'T',(a6)+
	move.b	#'0',(a6)+
	bra	.end
.10
	cmp.w	#$5,d0
	bne.s	.11
	move.b	#'I',(a6)+
	move.b	#'T',(a6)+
	move.b	#'T',(a6)+
	move.b	#'1',(a6)+
	bra	.end
.11
	cmp.w	#$6,d0
	bne.s	.12
	move.b	#'D',(a6)+
	move.b	#'T',(a6)+
	move.b	#'T',(a6)+
	move.b	#'0',(a6)+
	bra	.end
.12
	cmp.w	#$7,d0
	bne.s	.13
	move.b	#'D',(a6)+
	move.b	#'T',(a6)+
	move.b	#'T',(a6)+
	move.b	#'1',(a6)+
	bra.s	.end
.13
	cmp.w	#$805,d0
	bne.s	.14
	move.b	#'M',(a6)+
	move.b	#'M',(a6)+
	move.b	#'U',(a6)+
	move.b	#'S',(a6)+
	move.b	#'R',(a6)+
	bra.s	.end
.14
	cmp.w	#$806,d0
	bne.s	.15
	move.b	#'U',(a6)+
	move.b	#'R',(a6)+
	move.b	#'P',(a6)+
	bra.s	.end
.15
	cmp.w	#$807,d0
	bne.s	.16
	move.b	#'S',(a6)+
	move.b	#'R',(a6)+
	move.b	#'P',(a6)+
.16
	cmp.w	#$808,d0
	bne.s	.17
	move.b	#'P',(a6)+
	move.b	#'C',(a6)+
	move.b	#'R',(a6)+
.17
	cmp.w	#$008,d0
	bne.s	.18
	move.b	#'B',(a6)+
	move.b	#'U',(a6)+
	move.b	#'S',(a6)+
	move.b	#'C',(a6)+
	move.b	#'R',(a6)+
.18



.end
	rts


moveq
***************************
** routine pour le moveq **
***************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	d0,d1
	move.w	d0,d2
	and.w	#%11111111,d1
	clr.l	d0
	move.w	d1,d0
	move.b	#'#',(a6)+
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	move.w	d2,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	and.w	#%111,d0
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d0,-1(a6)
	

	clr.b	(a6)
	rts
	

p_divers
***********************************
** gestion du pmove pflush ..... **
***********************************
	move.w	(a4)+,d0	;instruct normale
	lea	instruct,a6
	addq.l	#1,a6
	move.w	(a4)+,d1
	btst	#13,d1
	beq.s	.p_flu_load
	move.w	d1,d2
	and.w	#%1111110000000000,d2
	cmp.w	#%0010000000000000,d2
	beq.s	.pload
	move.b	#'F',(a6)+	; on a le pflush
	move.b	#'L',(a6)+
	move.b	#'U',(a6)+
	move.b	#'S',(a6)+
	move.b	#'H',(a6)+
	bra	.fin
.pload
	move.b	#'L',(a6)+	; on a le pload
	move.b	#'O',(a6)+
	move.b	#'A',(a6)+
	move.b	#'D',(a6)+
	bra	.fin
	
	
	
.p_flu_load
	clr.l	d4
	btst	#11,d1
	beq.s	.p_double
	btst	#14,d1
	beq.s	.p_double
	move.b	#1,d4
.p_double
	
	move.w	d1,d2
	lsr.w	#8,d2
	lsr.w	#5,d2
	and.w	#%111,d2
	cmp.b	#0,d2
	beq.s	.move
	cmp.b	#2,d2
	beq.s	.move
	cmp.b	#3,d2
	beq.s	.move
	bra	.p_move
.move
	move.b	#'M',(a6)+
	move.b	#'O',(a6)+
	move.b	#'V',(a6)+
	move.b	#'E',(a6)+
	tst.b	d4
	beq.s	.ok
	move.b	#'.',(a6)+
	move.b	#'D',(a6)+
	bra.s	.o
.ok
	move.b	#'.',(a6)+
	move.b	#'L',(a6)+
.o
	move.b	#' ',(a6)+
	cmp.b	#2,d2
	bne	.p_crp		; g‚rer l'invalidation de l'atc
	btst	#9,d1
	bne.s	.mem_reg
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	move.b	#',',(a6)+
	lsr	#8,d1
	lsr	#2,d1
	and.w	#%111,d1
	cmp.b	#0,d1
	bne.s	.p_tc
	move.b	#'T',(a6)+
	move.b	#'C',(a6)+
	bra	.fin
.p_tc	cmp.b	#2,d1
	bne.s	.p_srp
	move.b	#'S',(a6)+
	move.b	#'R',(a6)+
	move.b	#'P',(a6)+
	bra	.fin
.p_srp	move.b	#'C',(a6)+
	move.b	#'R',(a6)+
	move.b	#'P',(a6)+
	bra	.fin

	
.mem_reg
	lsr	#8,d1
	lsr	#2,d1
	and.w	#%111,d1
	cmp.b	#0,d1
	bne.s	.p_tc1
	move.b	#'T',(a6)+
	move.b	#'C',(a6)+
	bra.s	.s
.p_tc1	cmp.b	#2,d1
	bne.s	.p_srp1
	move.b	#'S',(a6)+
	move.b	#'R',(a6)+
	move.b	#'P',(a6)+
	bra.s	.s
.p_srp1	move.b	#'C',(a6)+
	move.b	#'R',(a6)+
	move.b	#'P',(a6)+
.s
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	bra	.fin
.p_crp
	cmp.b	#0,d2
	bne	.p_tt		; g‚rer l'invalidation de l'atc
	btst	#9,d1
	bne.s	.mem_reg1
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	move.b	#',',(a6)+
	lsr	#8,d1
	lsr	#2,d1
	and.w	#%111,d1
	cmp.b	#2,d1
	bne.s	.p_tt0
	move.b	#'T',(a6)+
	move.b	#'T',(a6)+
	move.b	#'0',(a6)+
	bra.s	.fin
.p_tt0	move.b	#'T',(a6)+
	move.b	#'T',(a6)+
	move.b	#'1',(a6)+
	bra.s	.fin

	
.mem_reg1
	lsr	#8,d1
	lsr	#2,d1
	and.w	#%111,d1
	cmp.b	#2,d1
	bne.s	.p_tt01
	move.b	#'T',(a6)+
	move.b	#'T',(a6)+
	move.b	#'0',(a6)+
	bra.s	.s1
.p_tt01	move.b	#'T',(a6)+
	move.b	#'T',(a6)+
	move.b	#'1',(a6)+
.s1
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	bra.s	.fin
.p_tt
	
	**** les deux autres cas du pmove *****
	
	nop
	
	bra.s	.fin
.p_move
	nop
.fin
	clr.b	(a6)
	rts



btst_dn
***************************************
** routine qui traite les forme btst **
***************************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.l	#1,d1
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts
	

btst_imm
*********************************
** traitement du btst immediat **
*********************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	(a4)+,d1
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	clr.l	d0
	move.w	d1,d0
	move.b	#'#',(a6)+
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	move.b	#',',(a6)+
	bsr	mode
	clr.b	(a6)
	rts
	
	
dbcc
**************************
** routine pour le dbcc **
**************************
	addq.l	#2,a4
	lea	instruct,a6
	addq.l	#2,a6		; pointe apres le db
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#%1111,d1
	cmp.b	#1,d1		; on met en place pour le dbra
	bne.s	.p_i
	moveq	#0,d1
.p_i
	move.w	(termi,d1*2),d1
	move.w	d1,d2
	lsr.w	#8,d2
	move.b	d2,(a6)+
	move.b	d1,(a6)+
	move.b	#' ',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	move.b	#',',(a6)+
	clr.l	d1
	move.w	(a4)+,d1
	btst	#15,d1
	beq.s	.posi1
	neg.w	d1
	move.l	pcr,d0
	sub.l	d1,d0
	;sub.l	#2,d0
	bra.s	.l11
.posi1
	add.l	pcr,d1
	move.l	d1,d0
	;sub.l	#2,d0
.l11
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	
	
	
	clr.b	(a6)
	rts

trapcc
****************************
** routine pour le trapcc **
****************************
	addq.l	#2,a4
	lea	instruct,a6
	addq.l	#4,a6		; pointe apres le trap
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#%1111,d1
	move.w	(termi,d1*2),d1
	move.w	d1,d2
	lsr.w	#8,d2
	move.b	d2,(a6)+
	move.b	d1,(a6)+
	
	
	and.w	#%111,d0
	cmp.b	#4,d0
	beq.s	.fin
	cmp.b	#2,d0
	beq.s	.word
	move.b	#'.',(a6)+
	move.b	#'L',(a6)+
	move.b	#' ',(a6)+
	move.b	#'#',(a6)+
	move.l	(a4)+,d0
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c1	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c1
	bra.s	.fin
.word
	move.b	#'.',(a6)+
	move.b	#'W',(a6)+
	move.b	#' ',(a6)+
	move.b	#'#',(a6)+
	clr.l	d0
	move.w	(a4)+,d0
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
.fin	clr.b	(a6)
	rts
	

	
scc
*************************
** routine pour le scc **
*************************
	addq.l	#2,a4
	lea	instruct,a6
	addq.l	#1,a6		; pointe apres le s
	move.w	d0,d3
	lsr.w	#8,d3
	and.w	#%1111,d3
	move.w	(termi1,d3*2),d1
	move.w	d1,d2
	lsr.w	#8,d2
	move.b	d2,(a6)+
	cmp.b	#1,d3
	ble.s	.d
	move.b	d1,(a6)+
.d	move.b	#' ',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts


termi1
	dc.b	'T ','F ','HI','LS'
	dc.b	'CC','CS','NE','EQ'
	dc.b	'VC','VS','PL','MI'
	dc.b	'GE','LT','GT','LE'

	
	
as_ae
*******************************
** routine de decalage en ae **
*******************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	d0,d2
	and.w	#%111,d2
	move.b	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts
	
	
as_dn
*******************************
** routine de decalage en ae **
*******************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	d0,d1
	lsr.w	#6,d1
	and.w	#%11,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	btst	#5,d0
	beq.s	.imm
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%111,d1
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
	bra.s	.don
.imm
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%111,d1
	move.b	#'#',(a6)+
	move.b	#'0',(a6)+
	tst.b	d1
	bne.s	.lp
	moveq	#8,d1
.lp
	add.b	d1,-1(a6)
.don
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	clr.b	(a6)
	rts
	
	
	
	
trap
*********************
** gestion du trap **
*********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	and.w	#%1111,d0
	bsr	affiche_nombre
	move.b	#'#',(a6)+
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	clr.b	(a6)
	rts

	
	
swap
*********************
** gestion du swap **
*********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	clr.b	(a6)
	rts
	
unlk
*********************
** gestion du swap **
*********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	clr.b	(a6)
	rts

move_usp
*************************
** intruction move usp **
*************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.b	#'.',(a6)+
	move.b	#'L',(a6)+
	move.b	#' ',(a6)+
	btst	#3,d0
	beq.s	.an_usp
	move.b	#'U',(a6)+
	move.b	#'S',(a6)+
	move.b	#'P',(a6)+
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	bra.s	.s
.an_usp
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	move.b	#',',(a6)+
	move.b	#'U',(a6)+
	move.b	#'S',(a6)+
	move.b	#'P',(a6)+

.s
	clr.b	(a6)
	rts



pack
***************************
** instruction type pack **
***************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	btst	#3,d0
	beq.s	.don
	move.b	#'-',(a6)+
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	move.w	d0,d1
	and.w	#%111,d1
	add.b	d1,-2(a6)
	move.b	#',',(a6)+
	move.b	#'-',(a6)+
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	lsr.w	#8,d0
	lsr.w	#1,d0
	and.w	#%111,d0
	add.b	d0,-2(a6)
	bra.s	.s
.don
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	lsr.w	#8,d0
	lsr.w	#1,d0
	and.w	#%111,d0
	add.b	d0,-1(a6)
.s
	clr.l	d0
	move.w	(a4)+,d0
	move.b	#',',(a6)+
	move.b	#'#',(a6)+
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c


	clr.b	(a6)
	rts


bcd_reg1
******************
** pour le cmpm **
******************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	lea	-1(a6),a6
	move.w	d0,d1
	lsr.w	#6,d1
	and.w	#%11,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	move.w	d0,d1
	and.w	#%111,d1
	move.l	a6,a5
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	move.b	#'+',(a6)+
	move.b	#',',(a6)+
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	move.b	#'+',(a6)+
	add.b	d1,2(a5)
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%111,d1
	add.b	d1,8(a5)	
	clr.b	(a6)
	rts


link_w
*********************
** le link en word **
*********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	move.b	#',',(a6)+
	move.b	#'#',(a6)+
	clr.l	d0
	move.w	(a4)+,d0
	btst	#15,d0
	beq.s	.pas_neg
	move.b	#'-',(a6)+
	neg.w	d0
.pas_neg

	bsr	affiche_nombre
	move.b	#'$',(a6)+
	lea	nombre,a0
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	clr.b	(a6)
	rts

link_l
*********************
** le link en long **
*********************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)
	move.b	#',',(a6)+
	move.b	#'#',(a6)+
	move.l	(a4)+,d0
	btst	#31,d0
	beq.s	.pas_neg
	move.b	#'-',(a6)+
	neg.l	d0
.pas_neg
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	clr.b	(a6)
	rts

exg
************
** le exg **
************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	
	
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	
	move.w	d0,d1
	lsr.w	#3,d1
	and.w	#%11111,d1
	cmp.b	#%01001,d1
	beq.s	.rien
	cmp.b	#%01000,d1
	beq.s	.donne
	add.b	#3,-5(a6)
	bra.s	.rien
.donne
	add.b	#3,-2(a6)
	add.b	#3,-5(a6)
.rien
	move.w	d0,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.w	d0,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	and.w	#%111,d1
	add.b	d1,-4(a6)
	clr.b	(a6)
	rts



cmp2_chk2
*************
** le cmp2 **
*************
	addq.l	#2,a4
	lea	instruct,a6
	move.w	(a4),d1
	btst	#11,d1
	beq.s	.cmp2
	move.b	#'C',(a6)+
	move.b	#'H',(a6)+
	move.b	#'K',(a6)+
	move.b	#'2',(a6)+
	bra.s	.s
.cmp2
	move.b	#'C',(a6)+
	move.b	#'M',(a6)+
	move.b	#'P',(a6)+
	move.b	#'2',(a6)+
.s
	move.w	d0,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	and.w	#%11,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.w	(a4)+,d0
	btst	#15,d0
	bne.s	.adr
	add.b	#3,-2(a6)
.adr
	lsr.w	#8,d0
	lsr.w	#4,d0
	and.w	#%111,d0
	add.b	d0,-1(a6)
	

	clr.b	(a6)
	rts


movep
**************
** le movep **
**************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.b	#'.',(a6)+
	btst	#6,d0
	beq.s	.word
	move.b	#'L',(a6)+
	bra.s	.s
.word
	move.b	#'W',(a6)+
.s
	move.b	#' ',(a6)+
	btst	#7,d0
	beq.s	.mem_reg
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.b	#',',(a6)+
	move.w	d0,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	and.w	#%111,d1
	add.b	d1,-2(a6)
	move.w	(a4)+,d1
	btst	#15,d1
	beq.s	.posi
	move.b	#'-',(a6)+
	neg.w	d1
.posi
	move.w	d0,d2
	clr.l	d0
	move.w	d1,d0
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	move.w	d2,d0
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	and.w	#%111,d0
	add.b	d0,-2(a6)
	bra.s	.m
.mem_reg
	move.w	(a4)+,d1
	btst	#15,d1
	beq.s	.posi1
	move.b	#'-',(a6)+
	neg.w	d1
.posi1
	move.w	d0,d2
	clr.l	d0
	move.w	d1,d0
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c1	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c1
	move.w	d2,d0
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	move.w	d0,d1
	and.w	#%111,d1
	add.b	d1,-2(a6)
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	
.m
	clr.b	(a6)
	rts

ext
************
** le ext **
************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	d0,d1
	lsr.w	#6,d1
	and.w	#%111,d1
	cmp.b	#2,d1
	bne.s	.p8_16
	move.b	#'.',(a6)+
	move.b	#'W',(a6)+
	bra.s	.s
.p8_16	
	cmp.b	#3,d1
	bne.s	.p16_32
	move.b	#'.',(a6)+
	move.b	#'L',(a6)+
	bra.s	.s
.p16_32
	move.b	#'B',(a6)+
	move.b	#'.',(a6)+
	move.b	#'L',(a6)+
.s
	move.b	#' ',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d0
	add.b	d0,-1(a6)	
	clr.b	(a6)
	rts


chk
************
** le chk **
************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.b	#'.',(a6)+
	btst	#7,d0
	beq.s	.long
	move.b	#'W',(a6)+
	bra.s	.s
.long
	move.b	#'L',(a6)+
.s
	move.b	#' ',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode	
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	lsr.w	#8,d0
	lsr.w	#1,d0
	and.w	#%111,d0
	add.b	d0,-1(a6)
	clr.b	(a6)
	rts

mulu_w
*****************************
** les mult et div en word **
*****************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr	#3,d3
	and.w	#%111,d3
	bsr	mode
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	lsr.w	#8,d0
	lsr.w	#1,d0
	and.w	#%111,d0
	add.b	d0,-1(a6)	
	clr.l	(a6)
	rts



bfchg
*****************************
** les inst du type bfchg  **
*****************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	move.w	(a4)+,d0
	bsr	mode
	move.b	#'{',(a6)+
	move.w	d0,d1
	and.w	#%11111,d1
	move.w	d0,d2
	move.w	d0,d3
	lsr.w	#6,d2
	and.w	#%11111,d2
	btst	#11,d0
	bne.s	.reg
	clr.l	d0
	move.w	d2,d0
	bsr	affiche_nombre_deci
	lea	nombre,a0
.c1	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c1
	
	bra.s	.s
.reg
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
.s
	move.b	#':',(a6)+
	btst	#5,d3
	bne.s	.reg1
	clr.l	d0
	move.w	d1,d0
	bsr	affiche_nombre_deci
	lea	nombre,a0
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	bra.s	.s1
.reg1
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
.s1
	move.b	#'}',(a6)+
	clr.b	(a6)
	rts

bfchg_dn
********************************
** les inst du type bfchg_dn  **
********************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	move.w	(a4)+,d0
	bsr	mode
	move.b	#'{',(a6)+
	move.w	d0,d1
	and.w	#%11111,d1
	move.w	d0,d2
	move.w	d0,d3
	lsr.w	#6,d2
	and.w	#%11111,d2
	btst	#11,d0
	bne.s	.reg
	clr.l	d0
	move.w	d2,d0
	bsr	affiche_nombre_deci
	lea	nombre,a0
.c1	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c1
	bra.s	.s
.reg
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
.s
	move.b	#':',(a6)+
	btst	#5,d3
	bne.s	.reg1
	clr.l	d0
	move.w	d1,d0
	bsr	affiche_nombre_deci
	lea	nombre,a0
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	bra.s	.s1
.reg1
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
.s1
	move.b	#'}',(a6)+
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	lsr.w	#8,d3
	lsr.w	#4,d3
	and.w	#%111,d3
	add.b	d3,-1(a6)
	clr.b	(a6)
	rts

dn_bfchg
********************************
** les inst du type dn_bfchg  **
********************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.w	(a4),d2
	lsr.w	#8,d2
	lsr.w	#4,d2
	and.w	#%111,d2
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	move.w	(a4)+,d0
	bsr	mode
	move.b	#'{',(a6)+
	move.w	d0,d1
	and.w	#%11111,d1
	move.w	d0,d2
	move.w	d0,d3
	lsr.w	#6,d2
	and.w	#%11111,d2
	btst	#11,d0
	bne.s	.reg
	clr.l	d0
	move.w	d2,d0
	bsr	affiche_nombre_deci
	lea	nombre,a0
.c1	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c1
	
	bra.s	.s
.reg
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
.s
	move.b	#':',(a6)+
	btst	#5,d3
	bne.s	.reg1
	clr.l	d0
	move.w	d1,d0
	bsr	affiche_nombre_deci
	lea	nombre,a0
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	bra.s	.s1
.reg1
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
.s1
	move.b	#'}',(a6)+
	clr.b	(a6)
	rts


cas
****************
** cas du cas **
****************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	d0,d1
	lsr.w	#8,d1
	lsr.w	#1,d1
	and.w	#%11,d1
	subq.b	#1,d1
	bsr	taille_bcd
	move.b	#' ',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	(a4)+,d2
	move.w	d2,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d2,d1
	lsr.w	#6,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	clr.b	(a6)
	rts
	
cas2
*****************
** cas du cas2 **
*****************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'.',(a6)+
	btst	#9,d0
	bne.s	.lo
	move.b	#'W',(a6)+
	bra.s	.s
.lo
	move.b	#'L',(a6)+
.s
	move.b	#' ',(a6)+
	move.w	(a4)+,d0
	move.w	(a4)+,d1
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	add.b	d2,-1(a6)
	move.b	#':',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d1,d2
	and.w	#%111,d2
	add.b	d2,-1(a6)
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d2
	lsr.w	#6,d2
	and.w	#%111,d2
	add.b	d2,-1(a6)
	move.b	#':',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	move.w	d1,d2
	lsr.w	#6,d2
	and.w	#%111,d2
	add.b	d2,-1(a6)
	move.b	#',',(a6)+
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	btst	#15,d0
	bne.s	.o
	add.b	#3,-3(a6)
.o	
	lsr.w	#8,d0
	lsr.w	#4,d0
	and.w	#%111,d0
	add.b	d0,-2(a6)
	move.b	#':',(a6)+

	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	btst	#15,d1
	bne.s	.o1
	add.b	#3,-3(a6)
.o1
	lsr.w	#8,d1
	lsr.w	#4,d1
	and.w	#%111,d1
	add.b	d1,-2(a6)
	clr.b	(a6)
	rts



movem
******************
** cas du  movem **
****************/*
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.b	#'.',(a6)+
	btst	#6,d0
	beq.s	.16
	move.b	#'L',(a6)+
	bra.s	.32
.16
	move.b	#'W',(a6)+
.32
	move.b	#' ',(a6)+		; memoire vers registre un seul mode
	btst	#10,d0
	beq.s	.reg_mem
	
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	move.w	(a4)+,d4
	bsr	mode
	move.b	#',',(a6)+
	move.w	d4,d1
	bsr	ana_movem
	bra.s	.m
.reg_mem
	move.w	(a4)+,d1		; on doit inverser le registre
	moveq	#15,d4
	move.w	d0,d2
	lsr	#3,d2
	and.w	#%111,d2
	cmp.b	#%100,d2
	bne.s	.o
	clr.w	d2
	
.invert	
	and	#0,ccr
	lsr.w	#1,d1
	bcc.s	.ch
	bset	d4,d2
.ch
	
	dbra	d4,.invert
	move.w	d2,d1
.o	
	bsr	ana_movem
	move.b	#',',(a6)+
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	

.m

	clr.b	(a6)
	rts




ana_movem
*************************************
** affichage des registre du movem **
*************************************
	moveq	#-1,d2
.ch	addq.l	#1,d2
	cmp.b	#16,d2
	beq	.fo
	and	#0,ccr
	lsr.w	#1,d1
	bcc.s	.ch
	btst	#0,d1
	beq.s	.suivant
	move.b	#'A',(a6)+
	cmp.b	#8,d2
	bge.s	.p1
	add.b	#3,-1(a6)
.p1
	move.b	#'0',(a6)+
	cmp.b	#8,d2
	blt.s	.p11
	sub.b	#8,-1(a6)
.p11	add.b	d2,-1(a6)
	move.b	#'-',(a6)+	; ya juste un reg qui suit
.ch1
	addq.l	#1,d2
	cmp.b	#17,d2
	beq.s	.fo
	and	#0,ccr
	lsr.w	#1,d1
	bcs.s	.ch1
	move.b	#'A',(a6)+
	cmp.b	#8,d2
	bgt.s	.p2
	add.b	#3,-1(a6)
.p2	move.b	#'0',(a6)+
	cmp.b	#8,d2
	ble.s	.p21
	sub.b	#8,-1(a6)
.p21	add.b	d2,-1(a6)
	sub.b	#1,-1(a6)
	move.b	#'/',(a6)+
	bra.s	.p
.suivant
	move.b	#'A',(a6)+
	cmp.b	#8,d2
	bge.s	.p3
	add.b	#3,-1(a6)
.p3	move.b	#'0',(a6)+
	cmp.b	#8,d2
	blt.s	.p31
	sub.b	#8,-1(a6)
.p31	add.b	d2,-1(a6)
	move.b	#'/',(a6)+	; ya juste un reg qui suit
	
.p
	bra	.ch
.fo
	subq.l	#1,a6

	rts




muls_l
********************************
** cas des mul et div en long **
********************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	(a4),d1
	btst	#11,d1
	bne.s	.u
	move.b	#'U',(a6)+
	bra.s	.f
.u
	move.b	#'S',(a6)+
.f
	btst	#10,d1
	bne.s	.y
	move.w	(a4),d1
	and.w	#%111,d1
	move.w	(a4),d2
	lsr.w	#8,d2
	lsr.w	#4,d2
	and.w	#%111,d2
	cmp.w	d2,d1
	beq.s	.y
	move.b	#'L',(a6)+
.y

	move.b	#'.',(a6)+	
	move.b	#'L',(a6)+
	move.b	#' ',(a6)+

	move.w	(a4)+,d4
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	moveq	#1,d1
	bsr	mode
	
	move.w	d4,d0
	
	btst	#10,d0
	bne.s	.64
	move.w	d0,d1
	move.w	d0,d2
	and.w	#%111,d1
	lsr.w	#8,d2
	lsr.w	#4,d2
	and.w	#%111,d2
	cmp.w	d1,d2
	beq.s	.32	
	
.64
	move.w	d0,d1
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	and.w	#%111,d1
	add.b	d1,-1(a6)
	
	
	move.b	#':',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	lsr.w	#8,d0
	lsr.w	#4,d0
	and.w	#%111,d0
	add.b	d0,-1(a6)
	
	bra.s	.s
.32
	move.b	#',',(a6)+
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	lsr.w	#8,d0
	lsr.w	#4,d0
	and.w	#%111,d0
	add.b	d0,-1(a6)
	
.s
	clr.b	(a6)
	rts


fadr
****************************
** instruct fres et fsave **
****************************
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	
	move.w	(a4)+,d0
	
	move.w	d0,d2
	and.w	#%111,d2
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	#%111,d3
	bsr	mode
	
	clr.b	(a6)

	rts




fpu_norm
*************************************
** desassemblage des instructs fpu **
*************************************
	xref	COL_NOR,COL_FCT
	lea	instruct,a6
	lea	table_fpu,a0
	move.l	(a4)+,d0

	bfextu	d0{16:3},d1
	cmp.b	#%011,d1
	beq	.fmove_sp
	bfextu	d0{16:2},d1
	cmp.b	#%10,d1
	beq	.fmove_ccr
	cmp.b	#%11,d1
	beq	.fmovem
	


	bfextu 	d0{16:6},d1
	cmp.b	#%010111,d1
	beq	.fm_cr
	

.ch	
	move.l	d0,d1
	and.l	#%1111111,d1	; on cherche l'opcode normal
	move.w	(a0),d2
	cmp.w	#$ffff,d2
	beq	.fin_n
	;bfextu	d0{19:3},d3
	;cmp.b	#%111,d3
	;beq	.fin_n
	
	
	
	cmp.w	d2,d1
	beq.s	.op
	add.l	#10,a0
	bra.s	.ch
.op	addq.l	#2,a0		; on copie l'opcode
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	btst	#14,d0
	beq.s	.r_r
	
	subq.l	#1,a6
	
	bfextu	d0{19:3},d1
	lea	.table_ex,a0
	move.b	(a0,d1),d2
	lea	.table_lg,a0
	move.b	(a0,d1),d1
	move.b	#'.',(a6)+
	move.b	d2,(a6)+
	move.b	#' ',(a6)+
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	
	
	clr.w	pc_r
	
	cmp.w	#%111,d3		; regarde si on a un deplacement relatif pc
	bne.s	.p_dpc
	cmp.w	#%011,d2
	beq.s	.dpc
	cmp.w	#%010,d2
	bne.s	.p_dpc
.dpc
	st	pc_r
	add.l	#2,pcr	

.p_dpc




	
	bsr	mode
	
	
	tst.w	pc_r			; on recorrige
	beq.s	.p_cor
	subq.l	#2,pc_r
.p_cor
	
	bra.s	.fpn
	
	
.r_r
	subq.l	#1,a6
	
	;tst.b	d1
	;bne.s	.p_move
	;
	;move.w	#'.P',(a6)+
	;bra.s	.iop
.p_move
	move.w	#'.X',(a6)+
.iop
	move.b	#' ',(a6)+
		
	bfextu	d0{19:3},d1
	move.w	#'FP',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
	
	
	
	;bfextu	d0{22:3},d2
	;cmp.b	d2,d1			; ici i on remet la compa
	;beq	.exit			; on n'affiche pas le deuxieme fpn si = au premier
	
	
	
.fpn
	
	move.l	d0,d1
	and.l	#%1111111,d1		; test du ftst
	cmp.b	#%00111010,d1
	beq.s	.fin_n
	move.b	#',',(a6)+
	
	
	
	
	bfextu	d0{22:3},d1
	move.w	#'FP',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
	
	bra	.exit
	
	
.fin_n


	move.w	d0,d1
	and.w	#%01111000,d1
	cmp.b	#%00110000,d1
	bne	.p_sincos
	
	btst	#14,d0
	beq.s	.r_r1
	
	lea	instruct,a6
	move.l	#'FSIN',(a6)+
	move.w	#'CO',(a6)+
	move.b	#'S',(a6)+
	
	bfextu	d0{19:3},d1
	lea	.table_ex,a0
	move.b	(a0,d1),d2
	lea	.table_lg,a0
	move.b	(a0,d1),d1
	move.b	#'.',(a6)+
	move.b	d2,(a6)+
	move.b	#' ',(a6)+
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	
	bsr	mode
	bra.s	.fpn1
	
	
.r_r1
	move.w	#'.X',(a6)+
	move.b	#' ',(a6)+
	bfextu	d0{19:3},d1
	move.w	#'FP',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
	bfextu	d0{22:3},d2
	cmp.b	d2,d1
	beq	.exit
	
.fpn1
	move.b	#',',(a6)+
	bfextu	d0{29:3},d1
	move.w	#'FP',(a6)+
	move.b	#'0',(a6)+
	add.b	d1,-1(a6)
	bfextu	d0{22:3},d1
	move.l	#':FP0',(a6)+
	add.b	d1,-1(a6)
	


	bra	.exit
.p_sincos

	bfextu 	d0{16:6},d1
	cmp.b	#%010111,d1
	bne	.p_fm_cr
	
.fm_cr
	
	lea	instruct,a6
	move.l	#'FMOV',(a6)+
	move.l	#'ECR.',(a6)+
	move.l	#'X #$',(a6)+
	move.l	d0,d2
	bfextu	d0{25:7},d0
	bsr	affiche_nombre_2
	lea	nombre,a0
	move.w	(a0)+,(a6)+
	
	
	move.l	#',FP0',(a6)+
	bfextu	d2{22:3},d1
	add.b	d1,-1(a6)
	
	
	bfextu	d2{25:7},d0
	lea	table_cste,a0
	move.w	#'  ',(a6)+
	move.l	#'@~CO',(a6)+
	move.w	COL_FCT,(a6)+
	move.b	#$ff,-2(a6)
	move.b	#'<',(a6)+
	move.l	(a0,d0*8),(a6)+
	move.l	4(a0,d0*8),(a6)+
.c	cmp.b	#' ',-(a6)
	beq.s	.c
	addq.l	#1,a6
	
	
	move.b	#'>',(a6)+
	
	
	move.l	#'@~CO',(a6)+
	move.w	COL_NOR,(a6)+
	move.b	#$ff,-2(a6)
		
	
	
	
.p_fm_cr
	


	nop









	nop




.exit
	clr.b	(a6)
	rts

 
 
.fmove_sp
 	move.l	#'FMOV',(a6)+
 	move.b	#'E',(a6)+
 
 	bfextu	d0{19:3},d1
	lea	.table_ex,a0
	move.b	(a0,d1),d2
	lea	.table_lg,a0
	move.b	(a0,d1),d1
	move.b	#'.',(a6)+
	move.b	d2,(a6)+
	move.b	#' ',(a6)+
	
	move.l	#'FP0,',(a6)+
 	bfextu	d0{22:3},d4
 	add.b	d4,-2(a6)
 	
 		
	
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	
	bsr	mode
	
 	bfextu	d0{19:3},d1
 	cmp.b	#%111,d1
 	bne.s	.p_pack
 	
 	bfextu	d0{25:3},d1
 	move.l	#'{D0}',(a6)+
 	add.b	d1,-2(a6)
 	
 	
 	
 	bra	.exit
 .p_pack
 	cmp.b	#%011,d1
 	bne.s	.p_pack1
 	bfextu	d0{25:7},d1
 	move.w	#'{#',(a6)+
 	
 	btst	#6,d1
 	beq.s	.pos
 	neg.b	d1
 	bclr	#6,d1
 	bclr	#7,d1
 	move.l	d1,d0
 	bsr	affiche_nombre
	move.w	#'-$',(a6)+
	lea	nombre,a0
.c01	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c01
 	move.b	#'}',(a6)+
 	bra	.exit
 	
 	
 	
 .pos
 	move.b	#'$',(a6)+
 	move.l	d1,d0
 	bsr	affiche_nombre
	lea	nombre,a0
.c02	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c02
 	move.b	#'}',(a6)+
 	bra	.exit
 .p_pack1
 	bra	.exit
 
 
 
 
.fmove_ccr
 	move.l	#'FMOV',(a6)+
 	move.l	#'E.L ',(a6)+
 	btst	#13,d0
 	beq.s	.ae_d
 	
 	
	bfextu	d0{19:3},d1
	cmp.b	#%100,d1
	bne.s	.mp
	move.l	#'FPCR',(a6)+
.mp
	cmp.b	#%10,d1
	bne.s	.mp1
	move.l	#'FPSR',(a6)+
.mp1
	cmp.b	#%1,d1
	bne.s	.mp2
	move.l	#'FPIA',(a6)+
	move.b	#'R',(a6)+
.mp2
	move.b	#',',(a6)+
	
 	
	move.l	#1,d1		; en long
 	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	bsr	mode
	
 	bra	.exit
.ae_d
	move.l	#1,d1		; en long
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	bsr	mode
	move.b	#',',(a6)+
	
	bfextu	d0{19:3},d1
	cmp.b	#%100,d1
	bne.s	.mp00
	move.l	#'FPCR',(a6)+
.mp00
	cmp.b	#%10,d1
	bne.s	.mp01
	move.l	#'FPSR',(a6)+
.mp01
	cmp.b	#%1,d1
	bne.s	.mp02
	move.l	#'FPIA',(a6)+
	move.b	#'R',(a6)+	
.mp02
 
 	bra	.exit
 	
 	
.fmovem
	bfextu	d0{22:10},d1
	tst.w	d1
	beq	.ctrl_reg
	move.l	#'FMOV',(a6)+
	move.l	#'EM.X',(a6)+
	move.b	#' ',(a6)+
	btst	#13,d0
	bne.s	.ea_mem1
	
	bfextu	d0{19:2},d1
	btst	#0,d1
	beq.s	.p_dyn
	move.l	#3,d1
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	bsr	mode
	move.b	#',',(a6)+
	move.w	#'D0',(a6)+
	bfextu	d0{25:3},d1
	add.b	d1,-1(a6)
	bra	.exit
	
	
.p_dyn
	move.l	#3,d1
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	bsr	mode
	move.b	#',',(a6)+
	
	clr.w	d2
	bfextu	d0{24:8},d1
	bfextu	d0{19:2},d2
	btst	#1,d2
	bne.s	.p_pre
	
	move.w	#7,d4
.invert	and	#0,ccr
	lsr.w	#1,d1
	bcc.s	.ch7
	bset	d4,d2
.ch7	dbra	d4,.invert
	move.w	d2,d1
.p_pre

	
	bsr	.get_r
	
	
	
		
	
	
	bra	.exit
.ea_mem1
	
	
 	bfextu	d0{19:2},d1
	btst	#0,d1
	beq.s	.p_dyn1
	move.w	#'D0',(a6)+
	bfextu	d0{25:3},d1
	add.b	d1,-1(a6)
	move.b	#',',(a6)+
	move.l	#3,d1
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	bsr	mode
	
	bra	.exit
	
	
.p_dyn1
	
	
	clr.w	d2
	bfextu	d0{24:8},d1
	bfextu	d0{19:2},d2
	btst	#1,d2
	bne.s	.p_pre1
	
	move.w	#7,d4
.inv	and	#0,ccr
	lsr.w	#1,d1
	bcc.s	.ch71
	bset	d4,d2
.ch71	dbra	d4,.inv
	move.w	d2,d1
.p_pre1

	
	bsr	.get_r
	
	
	move.b	#',',(a6)+
	move.l	#3,d1
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	bsr	mode
	
	
	
 
 
 
 
 
 	bra	.exit


.ctrl_reg
	move.l	#'FMOV',(a6)+
	move.l	#'EM.L',(a6)+
	move.b	#' ',(a6)+
	
	
	
	btst	#13,d0
	beq.s	.ea_mem
	
	
	bsr	.get_list
	move.b	#',',(a6)+
	
	move.l	#1,d1		; en long
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	bsr	mode

	
	


	bra	.exit
.ea_mem

	move.l	#1,d1		; en long
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	bsr	mode
	move.b	#',',(a6)+
	bsr	.get_list


 
 
 	bra	.exit
 	
 	
 	
.get_r

	moveq	#-1,d2
.ch2	addq.l	#1,d2
	cmp.b	#8,d2
	beq	.fo
	and	#0,ccr
	lsr.w	#1,d1
	bcc	.ch2
	btst	#0,d1
	beq.s	.suivant
	move.w	#'FP',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
	move.b	#'-',(a6)+	; ya juste un reg qui suit
.ch1
	addq.l	#1,d2
	cmp.b	#9,d2
	beq.s	.fo
	and	#0,ccr
	lsr.w	#1,d1
	bcs.s	.ch1
	move.w	#'FP',(a6)+
.p2	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
	sub.b	#1,-1(a6)
	move.b	#'/',(a6)+
	bra.s	.p
.suivant
	move.w	#'FP',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
	move.b	#'/',(a6)+	; ya juste un reg qui suit
	
.p
	bra	.ch2
.fo
	subq.l	#1,a6

	rts







	rts 	
 	
 	
 	
.get_list
	bfextu	d0{19:3},d1
	cmp.b	#%001,d1
	bne.s	.r
	move.l	#'FPIA',(a6)+
	move.b	#'R',(a6)+
	rts
.r
	cmp.b	#%010,d1
	bne.s	.r1
	move.l	#'FPSR',(a6)+
	rts
.r1
	cmp.b	#%011,d1
	bne.s	.r2
	move.l	#'FPSR',(a6)+
	move.b	#'/',(a6)+
	move.l	#'FPIA',(a6)+
	move.b	#'R',(a6)+
	rts
.r2
	cmp.b	#%011,d1
	bne.s	.r3
	move.l	#'FPSR',(a6)+
	move.b	#'/',(a6)+
	move.l	#'FPIA',(a6)+
	move.b	#'R',(a6)+
	rts
.r3
	cmp.b	#%100,d1
	bne.s	.r4
	move.l	#'FPCR',(a6)+
	rts
.r4
	cmp.b	#%101,d1
	bne.s	.r5
	move.l	#'FPCR',(a6)+
	move.b	#'/',(a6)+
	move.l	#'FPIA',(a6)+
	move.b	#'R',(a6)+
	rts
.r5
	cmp.b	#%110,d1
	bne.s	.r6
	move.l	#'FPCR',(a6)+
	move.b	#'/',(a6)+
	move.l	#'FPSR',(a6)+
	rts
.r6
	cmp.b	#%111,d1
	bne.s	.r7
	move.l	#'FPCR',(a6)+
	move.b	#'/',(a6)+
	move.l	#'FPSR',(a6)+
	move.b	#'/',(a6)+
	move.l	#'FPIA',(a6)+
	move.b	#'R',(a6)+
	rts
.r7

	rts 
 	
 	
 
 
.table_ex
	dc.b	'L','S','X','P','W','D','B','P'
	even
.table_lg
	dc.b	1,1,3,3,0,2,0,3
	even



table_cste
	dc.b	'Pi      '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'?       '
	dc.b	'Log10(2)'
	dc.b	'e       '
	dc.b	'Log2(e) '
	dc.b	'Log10(e)'
	dc.b	'0.0     '
	rept    $30-$F-1
	dc.b	'?       '
	endr
	dc.b	'1n(2)   '
	dc.b	'1n(10)  '
	dc.b	'10^0    '
	dc.b	'10^1    '
	dc.b	'10^2    '
	dc.b	'10^4    '
	dc.b	'10^8    '
	dc.b	'10^16   '
	dc.b	'10^32   '
	dc.b	'10^64   '
	dc.b	'10^128  '
	dc.b	'10^256  '
	dc.b	'10^512  '
	dc.b	'10^1024 '
	dc.b	'10^2048 '
	dc.b	'10^4096 '
	rept	$ff-$3f
	dc.b	'?       '
	endr
	


ftrap_scc
***********************
** gestion du trapne **
** du dbcc et scc    **
***********************
	lea	instruct,a6
	move.l	(a4)+,d0
	
	bfextu	d0{9:4},d1
	cmp.b	#%1001,d1
	beq	.fdbcc
	
	cmp.b	#%1111,d1
	bne	.p_ftrap
	bfextu	d0{13:3},d1
	cmp.b	#%000,d1
	beq	.p_ftrap
	cmp.b	#%001,d1
	beq	.p_ftrap
	
	
	
	
	bfextu  d0{16:10},d1
	tst.l	d1
	bne	.p_ftrap
	move.L	#'FTRA',(a6)+
	move.b	#'P',(a6)+
	
	
	bfextu	d0{26:6},d1
	btst	#6,d1
	beq.s	.p
	move.w	#%100000,d1		; si mode non autoris‚
.p
	
	lea	table_condi,a0
	move.l	(a0,d1*4),(a6)+
.i	cmp.b	#' ',-(a6)
	beq.s	.i
	addq.l	#1,a6

	
	;
	
	bfextu	d0{13:3},d1
	cmp.b	#%100,d1		; pas operande
	beq	.exit
	cmp.b	#%010,d1
	bne.s	.p_word
	move.w	#'.W',(a6)+
	clr.l	d0
	move.w	(a4)+,d0
	move.w	#' #',(a6)+
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c11	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c11
	
	
	bra	.exit
.p_word
	move.w	#'.L',(a6)+
	move.l	(a4)+,d0
	move.w	#' #',(a6)+
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c1	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c1
	
	bra	.exit
	
	
.p_ftrap
	;*** scc
	
	move.w	#'FS',(a6)+
	
	bfextu	d0{26:6},d1
	btst	#6,d1
	beq.s	.p1
	move.w	#%100000,d1		; si mode non autoris‚
.p1
	
	lea	table_condi,a0
	move.l	(a0,d1*4),(a6)+
.i1	cmp.b	#' ',-(a6)
	beq.s	.i1
	addq.l	#1,a6
	move.w	#'.B',(a6)+
	move.b	#' ',(a6)+

	
	bfextu	d0{10:3},d3
	bfextu	d0{13:3},d2
	clr.b	d1		; on est en byte
	bsr	mode
	bra	.exit
	
	
.fdbcc
	move.w	#'FD',(a6)+
	move.b	#'B',(a6)+
	
	bfextu	d0{26:6},d1
	btst	#6,d1
	beq.s	.p2
	move.w	#%100000,d1		; si mode non autoris‚
.p2
	
	lea	table_condi,a0
	move.l	(a0,d1*4),(a6)+
.i2	cmp.b	#' ',-(a6)
	beq.s	.i2
	addq.l	#1,a6

	
	move.l	#' D0,',(a6)+
	bfextu	d0{13:3},d1
	add.b	d1,-2(a6)
	
	clr.l	d1
	move.w	(a4)+,d1
	
	
	btst	#15,d1
	beq.s	.posi1
	neg.w	d1
	move.l	pcr,d0
	add.l	#2,d0
	sub.l	d1,d0
	;subq.l	#2,d0
	bra.s	.l11
.posi1
	add.l	pcr,d1
	sub.l	#2,d1
	move.l	d1,d0
	;subq.l	#2,d0
.l11


	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	
	

.exit
	clr.b	(a6)
	rts






	DATA

table_condi
	dc.b	'F   '
	dc.b	'EQ  '
	dc.b	'OGT '
	dc.b	'OGE '
	dc.b	'OLT '
	dc.b	'OLE '
	dc.b	'OGL '
	dc.b	'OR  '
	dc.b	'UN  '
	dc.b	'UEQ '
	dc.b	'UGT '
	dc.b	'UGE '
	dc.b	'ULT '
	dc.b	'ULE '
	dc.b	'NE  '
	dc.b	'T   '
	dc.b	'SF  '
	dc.b	'SEQ '
	dc.b	'GT  '
	dc.b	'GE  '
	dc.b	'LT  '
	dc.b	'LE  '
	dc.b	'GL  '
	dc.b	'GLE '
	dc.b	'NGLE'
	dc.b	'NGL '
	dc.b	'NLE '
	dc.b	'NLT '
	dc.b	'NGE '
	dc.b	'NGT '
	dc.b	'SNE '
	dc.b	'ST  '
	dc.b	'????'
	
	TEXT


fbcc
*********************
** gestion du fbcc **
*********************
	lea	instruct,a6
	move.w	(a4)+,d0
	
	
	btst	#6,d0
	bne.s	.p_nop
	
	tst.w	(a4)
	beq	fpu_nop
.p_nop
	move.w	#'FB',(a6)+
	
	
	bfextu	d0{26:6},d1
	btst	#6,d1
	beq.s	.p
	move.w	#%100000,d1		; si mode non autoris‚
.p
	
	lea	table_condi,a0
	move.l	(a0,d1*4),(a6)+
.i	cmp.b	#' ',-(a6)
	beq.s	.i
	addq.l	#1,a6

	btst	#6,d0
	beq.s	.word
	move.w	#'.L',(a6)+
	move.l	(a4)+,d1
	btst	#31,d1
	beq.s	.posi11
	neg.l	d1
	move.l	pcr,d0
	sub.l	d1,d0
	;subq.l	#4,d0
	bra.s	.l111
.posi11
	add.l	pcr,d1
	move.l	d1,d0
	;subq.l	#4,d0
.l111
	bra.s	.f_r
	
.word
	move.w	#'.W',(a6)+
	clr.l	d1
	move.w	(a4)+,d1
	btst	#15,d1
	beq.s	.posi1
	neg.w	d1
	move.l	pcr,d0
	sub.l	d1,d0
	;subq.l	#2,d0
	bra.s	.l11
.posi1
	add.l	pcr,d1
	move.l	d1,d0
	;subq.l	#2,d0
.l11


.f_r	
	move.b	#' ',(a6)+
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	





	clr.b	(a6)
	rts
fpu_nop
************
** le nop **
************

	lea	instruct,a6
	move.l	#'FNOP',(a6)+
	addq.l	#2,a4
	clr.b	(a6)
	rts
	
	
	

lpstop
***************
** le lpstop **
***************

	cmp.w	#%0000000111000000,2(a4)
	bne.s	.p_lpstop	

	

	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	

	moveq	#0,d0
	move.w	4(a4),d0

	bsr	affiche_nombre
	
	move.w	#' #',(a6)+
	move.b	#'$',(a6)+
	
	
	
	lea	nombre,a0
.cop
	move.b	(a0)+,(a6)+
	bne.s	.cop





	addq.l	#6,a4
	clr.b	(a6)
	rts
	
	
.p_lpstop
	
	lea	instruct,a6
	move.l	#'LPXX',(a6)+
	add.l	#2,a4				; on a pas de lpstop
	clr.b	(a6)
	rts


plpa
*************
** le plpa **
*************

	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	
	
	btst	#6,1(a4)
	beq.s	.write
	
	move.l	#'R (A',(a6)+
	bra.s	.read
	
.write
	move.l	#'W (A',(a6)+
.read
	
	move.w	#'0)',(a6)+
	
	move.b	1(a4),d0
	and.w	#%111,d0
	add.b	d0,-2(a6)
	
	

	addq.l	#2,a4
	clr.b	(a6)
	rts
	
	




CINV
********************************
** cas des cinv et cpush      **
********************************
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	(a4)+,d1
	moveq	#0,d0
	move.w	d1,d0
	lsr.l	#3,d0
	and.w	#%11,d0
	tst.b	d0
	bne.s	.p_ill
	lea	instruct,a6	; mode interdit.
	move.b	#'I',(a6)+
	move.b	#'L',(a6)+
	move.b	#'L',(a6)+
	move.b	#'E',(a6)+
	move.b	#'G',(a6)+
	move.b	#'A',(a6)+
	move.b	#'L',(a6)+
	clr.b	(a6)+
	rts
.p_ill
	cmp.b	#1,d0
	bne.s	.p_l
	move.b	#'L',(a6)+
	bra.s	.i
.p_l
	cmp.b	#2,d0
	bne.s	.p_p
	move.b	#'P',(a6)+
	bra.s	.i
.p_p
	cmp.b	#3,d0
	bne.s	.p_a
	move.b	#'A',(a6)+
.p_a
	
.i	
	move.b	#' ',(a6)+
	move.w	d1,d2
	lsr.l	#6,d2
	and.w	#%11,d2
	tst.b	d2
	bne.s	.p_nc
	move.w	#'NC',(a6)+
	bra.s	.o
.p_nc
	cmp.b	#1,d2
	bne.s	.p_dc
	move.w	#'DC',(a6)+
	bra.s	.o
.p_dc
	cmp.b	#2,d2
	bne.s	.p_ic
	move.w	#'IC',(a6)+
	bra.s	.o
.p_ic
	cmp.b	#3,d2
	bne.s	.p_bc
	move.w	#'BC',(a6)+
.p_bc


	
.o
	cmp.w	#3,d0		; si registre all on arrete
	bne.s	.p
	clr.b	(a6)
	rts
.p
	and.w	#%111,d1
	move.w	#',(',(a6)+
	move.w	#'A0',(a6)+
	move.b	#')',(a6)+
	add.b	d1,-2(a6)
	

	clr.b	(a6)
	rts

PFLUSH
********************************
** cas des pflush             **
********************************
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	(a4)+,d1
	move.w	d1,d0
	lsr.w	#3,d0
	and.w	#%111,d0
	cmp.b	#0,d0
	bne.s	.p
	move.l	#'N (A',(a6)+
	move.w	#'0)',(a6)+
	bra	.sort1
.p
	cmp.b	#1,d0
	bne.s	.p1
	move.l	#' (A0',(a6)+
	move.b	#')',(a6)+
	bra	.sort1
.p1
	cmp.b	#2,d0
	bne.s	.p2
	move.w	#'AN',(a6)+
	bra	.sort
.p2
	cmp.b	#3,d0
	bne.s	.p3
	move.b	#'A',(a6)+
	bra	.sort
.p3
	
	

.sort
	clr.b	(a6)
	rts
.sort1
	and.w	#%111,d1
	add.b	d1,-2(a6)
	clr.b	(a6)
	rts
	
PTEST
********************************
** cas des ptest              **
********************************
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	(a4)+,d1
	btst	#5,d1
	beq.s	.w
	move.b	#'R',(a6)+
	bra.s	.i
.w	
	move.b	#'W',(a6)+
.i
	move.l	#' (A0',(a6)+
	move.b	#')',(a6)+
	and.w	#%111,d1
	add.b	d1,-2(a6)



	clr.b	(a6)
	rts



MOVE16AN
********************************
** cas des ptest              **
********************************
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	(a4)+,d1
	move.l	#' (A0',(a6)+
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.l	#')+,(',(a6)+
	move.l	#'A0)+',(a6)+
	move.w	(a4)+,d1
	lsr.l	#8,d1
	lsr.l	#4,d1
	and.w	#%111,d1
	add.b	d1,-3(a6)
	clr.b	(a6)
	rts

MOVE16ABS
********************************
** cas des ptest              **
********************************
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	subq.l	#1,a6
	move.w	(a4)+,d1
	move.w	d1,d2
	lsr.w	#3,d2
	and.w	#%11,d2
	and.w	#%111,d1
	move.l	(a4)+,d0	; adresse dans d0
	
	btst	#0,d2
	bne.s	.p_a
	
	move.l	#' (A0',(a6)+
	add.b	d1,-1(a6)
	move.b	#')',(a6)+
	btst	#1,d2
	bne.s	.p_p
	move.b	#'+',(a6)+
.p_p
	move.b	#',',(a6)+
	
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	move.w	#'.L',(a6)+
	clr.b	(a6)
	rts
.p_a

	move.b	#' ',(a6)+
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c1	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c1
	move.l	#'.L,(',(a6)+
	move.w	#'A0',(a6)+
	add.b	d1,-1(a6)
	move.b	#')',(a6)+
	btst	#1,d2
	bne.s	.p_p1
	move.b	#'+',(a6)+
.p_p1
	
	
	
	
	
	clr.b	(a6)
	rts




dcw
**************************
** cas des instruct dcw **
**************************
	addq.l	#2,a4
	lea	instruct,a6
.loop	cmp.b	#' ',(a6)+
	bne.s	.loop
	move.b	#'#',(a6)
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	

	clr.b	(a6)
	rts

mode
*********************************************
** routine qui renvoie le mode d'adressage **
** mode dans d3, registre dans d2          **
** longueur dans d1    =1 si long 0 si word**
** incremente automatiquement le a4        **
*********************************************
	
	include	'desas.inc\mode.s'
	
	
affiche_nombre::
*********************************************
** routine qui renvoie dans la chaine      **
** le nombre en hexa qui se trouve dans d0 **
** avec supression des zeros de debut      **
*********************************************
	include	'desas.inc\aff_nb.s'

affiche_nombre_zero::
*********************************************
** routine qui renvoie dans la chaine      **
** le nombre en hexa qui se trouve dans d0 **
*********************************************
	include	'desas.inc\aff_nb_z.s'

	cnop	0,16
test_label
	xref	COL_NOR,COL_LAB,adr_label,nb_symbols,hash_table
***********************************************************
** routine qui va voir si on doit mettre un label ou non **
** et qui le met en place sinon elle met un '$'          **
***********************************************************
	
	movem.l	a0-a1/d0,-(sp)
	lea	nombre,a0
	
	tst.l	nb_symbols
	beq.s	.e
	move.l	adr_label,a2
	tst.l	d0
	beq.s	.e		; si l'adresse est nulle, on sort



	move.l	hash_table,a1
	addq.l	#8,a1
.again
	cmp.l	(a1),d0
	blt.s	.ok1
	addq.l	#8,a1
	tst.l	(a1)
	bne.s	.again
.ok1
	*--- ici, on prend l'adresse juste avant ---*

	move.l	-4(a1),a2
	tst.l	a2
	beq	.e



.d	cmp.l	(a2)+,d0
	beq.s	.ok
	tst.l	(a2)+
	bne.s	.d
	bra	.e
.ok	



	clr.l	(a0)
	clr.l	4(a0)
	
	move.l	(a2)+,a1
	move.l	#'@~CO',(a0)+
	move	COL_LAB,(a0)+
	move.b	#1,-1(a0)
.i	move.b	(a1)+,(a0)+
	bne.s	.i
	subq.l	#1,a0
	move.l	#'@~CO',(a0)+
	move	COL_NOR,(a0)+
	move.b	#1,-1(a0)
	clr.b	(a0)+
	movem.l	(sp)+,a0-a1/d0
	rts
	
.e
	move.b	#'$',(a6)+
	movem.l	(sp)+,a0-a1/d0
	rts
	

affiche_nombre_deci
**************************************************
** routine qui va afficher un nombre en decimal **
**************************************************


	movem.l	d0-d1/a0-a1,-(sp)
	lea	float,a0
	cmp.l	#0,d0
	bne.s	.de
	
	move.b	#'0',(a0)+
	bra.s	.fin1
.de
	clr.l	d1
	
	divu.l	#10,d1:d0

	tst.l	d1		; on sort quand tous nuls
	bne.s	.klm
	tst.l	d0
	beq.s	.fin1
.klm
	add.b	#'0',d1
	move.b	d1,(a0)+
	
	move.l	#0,d1
	bra.s	.de
	
.fin1
	
	clr.b	(a0)+
	
	
	lea	nombre,a0
	lea	float,a1
	
	moveq	#0,d1
.fin
	addq.l	#1,d1
	move.b	(a1)+,d0
	
	bne.s	.fin
	
	subq.l	#1,a1
	subq.l	#1,d1
.cop
	move.b	-(a1),(a0)+
	dbra	d1,.cop
	
	
	
	
	
	movem.l	(sp)+,d0-d1/a0-a1
	rts


taille_bcd
***************************************
** taille dans d1 ajoute .b .w ou .l **
***************************************
	move.b	#'.',(a6)+
	cmp.b	#0,d1
	bne.s	.l2
	move.b	#'B',(a6)+
	bra.s	.exit	
.l2
	cmp.b	#1,d1
	bne.s	.l1
	move.b	#'W',(a6)+
	bra.s	.exit
.l1
	move.b	#'L',(a6)+
.exit

	rts
	
	BSS
float		ds.b	100
memoire_cou	ds.b	40
pcr	ds.l	1
mode_reg	ds.l	1
nb_compt	ds.w	1	

pc_r		ds.w	1
**************************************
	DATA

m::
instruct	dcb 200,0
n::
		dcb 200,0

