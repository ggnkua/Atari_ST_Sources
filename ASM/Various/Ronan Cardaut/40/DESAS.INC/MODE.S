*****************************************
** macro qui va transformer dn*1 en dn **
*****************************************

	MC68881

vire_le	macro
	cmp.b	#1,d0
	beq.s	.vire\@
	add.b	d0,-1(a6)
	bra.s	.ok\@
.vire\@
	subq.l	#2,a6
.ok\@
	endm


	movem.l	d0-d5,-(sp)


	; d3=mode
	; d2=reg




	move.l	mode_reg,d0

	cmp.w	#1,nb_compt	; 2eme tour dans la routine
	bne.s	.ert
	
	swap	d0
.ert

	addq.w	#1,nb_compt

	cmp.b	#%111,d3
	beq.s	.df

	move.l	#13,d4
	sub.b	d3,d4
	btst	d4,d0
	beq	.erreur
	bra.s	.deb

.df
	
	lea	.tab,a0
	move.w	(a0,d2.w*2),d4
	
	;move.l	#6,d4
	;sub.b	d2,d4
	btst	d4,d0
	beq	.erreur
	bra.s	.deb
	
.tab
	dc.w	6
	dc.w	5
	dc.w	1
	dc.w	0
	dc.w	4
	dc.w	2
	dc.w	3
	
***************************
** verifier la ligne 260 **
***************************

.deb
	cmp.b	#%111,d3	; y a t il un registre ?
	bne	.ya_reg
	cmp.b	#%000,d2	; (xxx).w
	bne.s	.n
	clr.l	d0
	move.w	(a4)+,d0
	ext.l	d0
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c
	move.b	#'.',(a6)+
	move.b	#'W',(a6)+
	bra	.fin_rout



.n	cmp.b	#%001,d2	; (xxx).l
	bne.s	.n1
	move.l	(a4)+,d0
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c1	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c1
	move.b	#'.',(a6)+
	move.b	#'L',(a6)+
	bra	.fin_rout
	


.n1	cmp.b	#%100,d2	; #<donnee>		2 cas si l ou w
	bne	.n2
	cmp.b	#2,d1			; on a un double long
	bne.s	.p_double
	move.l	(a4)+,d0
	move.b	#'#',(a6)+
	bsr	affiche_nombre
	lea	nombre,a0
	move.b	#'$',(a6)+
.c200	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c200
	move.l	(a4)+,d0
	;move.b	#'#',(a6)+
	bsr	affiche_nombre_zero
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c201	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c201
	bra	.fin_rout
	
	
	
.p_double	
	cmp.b	#3,d1			; un fpu immediat
	bne.s	.p_x			
	
	
	fmove	fp0,-(sp)
	fmove.x	(a4),fp0
	add.l	#12,a4
	
	pea	(a5)
	pea	(a6)

	lea	float,a6
		
	xref	FLOAT_TO_SCI
	bsr.l	FLOAT_TO_SCI
	
	clr.l	(a6)
	
	move.l	(a7)+,a6

	lea	float,a5

	move.b	#'#',(a6)+
.cppo
	tst.b	(a5)+
	move.b	(a5)+,(a6)+
	bne.s	.cppo
	subq.w	#1,a6
	
	
	move.l	(sp)+,a5
	fmove	(sp)+,fp0
	
	
	;move.l	(a4)+,d0
	;move.b	#'#',(a6)+
	;bsr	affiche_nombre
	;lea	nombre,a0
	;move.b	#'$',(a6)+
.c202	;move.b	(a0)+,(a6)+
	;tst.b	(a0)
	;bne.s	.c202
	;move.l	(a4)+,d0
	;;move.b	#'#',(a6)+
	;bsr	affiche_nombre_zero
	;lea	nombre,a0
	;;move.b	#'$',(a6)+
.c203	;move.b	(a0)+,(a6)+
	;tst.b	(a0)
	;bne.s	.c203
	;move.l	(a4)+,d0
	;;move.b	#'#',(a6)+
	;bsr	affiche_nombre_zero
	;lea	nombre,a0
	;;move.b	#'%',(a6)+
.c204	;move.b	(a0)+,(a6)+
	;tst.b	(a0)
	;bne.s	.c204
	
	
	bra	.fin_rout
	
	
.p_x
	cmp.b	#1,d1
	bne.s	.short		; ici c'est le long
	move.l	(a4)+,d0
	move.b	#'#',(a6)+
	cmp.w	#'.S',-4(a6)	; cas du fmove.s
	bne.s	.p_fpu_s
	
	fmove	fp0,-(sp)
	fsub	fp0,fp0
	fmove.s	d0,fp0
	pea	(a5)
	pea	(a6)
	lea	float,a6
		
	xref	FLOAT_TO_SCI
	bsr.l	FLOAT_TO_SCI
	
	clr.l	(a6)
	move.l	(a7)+,a6
	lea	float,a5
.cppo1
	tst.b	(a5)+
	move.b	(a5)+,(a6)+
	bne.s	.cppo1
	subq.w	#1,a6
	move.l	(sp)+,a5
	fmove	(sp)+,fp0
	bra	.fin_rout
	
	
.p_fpu_s
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c2	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c2

	bra	.fin_rout


.short	clr.l	d0			; ici le word
	move.w	(a4)+,d0
	;ext.w	d0
	move.b	#'#',(a6)+
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c3	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c3
	
	
	
	bra	.fin_rout
.n2	cmp.b	#%010,d2	; (d16,pc)
	bne.s	.n3
	clr.l	d0
	move.w	(a4)+,d0
	move.l	d0,d1
	;lsr.w	#8,d1
	;lsr.l	#6,d1
	;tst.w	d1
	btst	#15,d1
	beq.s	.ajoute
	;neg.w	d0
	;and.l	#$ffff,d0
	;move.b	#'-',(a6)+
	
	move.l	#$10000,d1		; virer pour le bon pc
	sub.l	d0,d1
	move.l	pcr,d2
	sub.l	d1,d2
	move.l	d2,d0
	;sub.l	#2,d0			; on compense le (a4)+
	bra.s	.s
		
.ajoute
	;nop
	add.l	pcr,d0	
	;sub.l	#2,d0
.s
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c4	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c4
	move.b	#'(',(a6)+
	move.b	#'P',(a6)+
	move.b	#'C',(a6)+
	move.b	#')',(a6)+
	
	
	bra	.fin_rout
.n3						; reste avec le pc
	move.w	(a4)+,d0
	btst	#8,d0
	bne	.en_long		; deplacement 8bits
	move.l	d0,d1
	clr.l	d0
	move.b	d1,d0
	btst	#7,d0
	beq.s	.pos
	;neg.b	d0
	;and.l	#$ff,d0
	;move.b	#'-',(a6)+
	
	move.l	#$100,d2
	sub.w	d0,d2
	move.l	pcr,d0
	sub.l	d2,d0
	;sub.l	#2,d0
	bra.s	.s4
.pos
	nop
	;add.l	pcr,d0
	;sub.l	#2,d0
.s4
	move.b	#'(',(a6)+		; on met le deplacment dans la (
	tst.b	d0
	beq.s	.p_aff2
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c5	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c5
	move.w	#'.B',(a6)+
	move.b	#',',(a6)+
.p_aff2
	move.l	d1,d0
	move.b	#'P',(a6)+
	move.b	#'C',(a6)+
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	btst	#15,d0
	bne.s	.pas_d
	add.b	#3,-1(a6)	
.pas_d
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#4,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.b	#'.',(a6)+
	btst	#11,d0
	bne.S	.32
	move.b	#'W',(a6)+
	bra.s	.16
.32
	move.b	#'L',(a6)+
.16
	move.b	#'*',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%11,d1
	add.b	#1,d1
	move.b	#0,d0
	bset	#7,d0
	rol.b	d1,d0
	vire_le
	;add.b	d0,-1(a6)
	move.b	#')',(a6)+
	bra	.fin_rout
	
.en_long
	
				; deplacement 16 ou 32 bits
	move.b	#'(',(a6)+
	move.w	d0,d1
	and.w	#%111,d1
	move.w	d1,d5		; test de l'indirection
	tst.b	d1
	beq.s	.pas_indirection1
	move.b	#'[',(a6)+
.pas_indirection1
	
	move.w	d0,d1
	lsr	#4,d1
	and.w	#%11,d1
	cmp.b	#1,d1
	beq	.p_dep
	cmp.b	#2,d1
	bne.s	.32b		;dep 16 bits
	clr.l	d4
	move.w	d0,d4
	clr.l	d0
	move.w	(a4)+,d0
	btst	#15,d0
	beq.s	.posi
	neg.w	d0
	and.l	#$ffff,d0
	move.b	#'-',(a6)+
	;move.l	#$10000,d3
	;sub.l	d0,d3
	;move.l	pcr,d0
	;sub.l	d3,d0
	;sub.l	#4,d0
	bra.s	.16b	
.posi
	nop
	;add.l	pcr,d0
	;sub.l	#4,d0
	bra.s	.16b
.32b
	clr.l	d4
	move.w	d0,d4
	clr.l	d0
	move.l	(a4)+,d0
	btst	#31,d0
	beq.s	.posi1
	neg.l	d0
	move.b	#'-',(a6)+
	;move.l	pcr,d3
	;sub.l	d0,d3				; verifier qu'il ne faut pas enelver 2
	;move.l	d3,d0
	;sub.l	#6,d0
	bra.s	.16b
.posi1
	nop
	;add.l	pcr,d0
	;sub.l	#6,d0
.16b
	bsr	affiche_nombre
	bsr	test_label
	move.l	d4,d0
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c51	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c51
	move.b	#'.',(a6)+
	btst	#4,d0		
	beq.s	.d16
	move.b	#'L',(a6)+
	bra.s	.d32
.d16
	move.b	#'W',(a6)+
.d32
	move.b	#',',(a6)+
.p_dep
	move.b	#'P',(a6)+
	move.b	#'C',(a6)+
	btst	#2,d5
	beq.s	.mm12
	move.b	#']',(a6)+
.mm12
	btst	#6,d0
	bne.s	.pas_index1		; pas de registre d'index
	
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	btst	#15,d0
	bne.s	.pas_d1
	add.b	#3,-1(a6)	
.pas_d1
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#4,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.b	#'.',(a6)+
	btst	#11,d0
	bne.S	.321
	move.b	#'W',(a6)+
	bra.s	.161
.321
	move.b	#'L',(a6)+
.161
	move.b	#'*',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%11,d1
	add.b	#1,d1
	move.b	#0,d0
	bset	#7,d0
	rol.b	d1,d0
	vire_le
	;add.b	d0,-1(a6)
.pas_index1
	tst.b	d5
	beq.s	.pl1
	btst	#2,d5
	bne.s	.pl1
	move.b	#']',(a6)+
.pl1
	
	
	tst.b	d5
	beq.s	.p_i1		; y a le od
	cmp.b	#1,d5
	beq.s	.p_i1		; non
	cmp.b	#%101,d5
	beq.s	.p_i1
	move.b	#',',(a6)+
	btst	#0,d5
	beq.s	.16bits1
	move.l	(a4)+,d0
	btst	#31,d0
	beq.s	.po1
	neg.l	d0
	move.b	#'-',(a6)+
.po1
	bra.s	.32bits1
.16bits1
	****
	clr.l	d0
	****
	
	move.w	(a4)+,d0
	btst	#15,d0
	beq.s	.p1
	neg.w	d0
	move.b	#'-',(a6)+
.p1
.32bits1
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c51911	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c51911
					; on aff les .l ou .w
	move.b	#'.',(a6)+
	btst	#0,d5
	beq.s	.seize1
	move.b	#'L',(a6)+
	bra	.trente1
.seize1
	move.b	#'W',(a6)+
.trente1

.p_i1

	move.b	#')',(a6)+
	bra	.fin_rout
.ya_reg
	
	cmp.b	#0,d3
	bne.s	.d1
	move.b	#'D',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
	bra	.fin_rout
.d1
	cmp.b	#1,d3
	bne.s	.d2
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
	bra	.fin_rout
.d2
	cmp.b	#2,d3
	bne.s	.d3
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	add.b	d2,-2(a6)
	bra	.fin_rout
.d3
	cmp.b	#3,d3
	bne.s	.d4
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	move.b	#'+',(a6)+
	add.b	d2,-3(a6)
	bra	.fin_rout
.d4
	cmp.b	#4,d3
	bne.s	.d5
	move.b	#'-',(a6)+
	move.b	#'(',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	add.b	d2,-2(a6)
	bra	.fin_rout
.d5
	cmp.b	#5,d3
	bne.s	.d6
	clr.l	d0
	move.w	(a4)+,d0
	move.l	d0,d1
	lsr.w	#8,d1
	lsr.l	#6,d1
	move.b	#'(',(a6)+
	tst.w	d1
	beq.s	.ajoute1
	btst	#15,d0
	beq.s	.ajoute1
	move.l	#$10000,d1
	sub.l	d0,d1
	move.l	d1,d0
	move.b	#'-',(a6)+
	bra	.s1
		
.ajoute1
.s1
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c41	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c41
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	move.b	#')',(a6)+
	add.b	d2,-2(a6)
	
	bra	.fin_rout
.d6
	****
	clr.l	d0
	****
	move.w	(a4)+,d0
	btst	#8,d0
	bne	.en_long9		; deplacement 8bits
	move.l	d0,d1
	clr.l	d0
	move.b	d1,d0
	move.b	#'(',(a6)+		; on met le deplacement de la (
	btst	#7,d0
	beq.s	.pos9
	neg.b	d0
	move.b	#'-',(a6)+
.pos9
	tst.b	d0
	beq.s	.p_aff1
	
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c59	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c59
	move.w	#'.B',(a6)+
	move.b	#',',(a6)+
.p_aff1
	move.l	d1,d0
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
	move.b	#',',(a6)+
	move.b	#'A',(a6)+
	btst	#15,d0
	bne.s	.pas_d9
	add.b	#3,-1(a6)	
.pas_d9
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#4,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.b	#'.',(a6)+
	btst	#11,d0
	bne.S	.329
	move.b	#'W',(a6)+
	bra.s	.169
.329
	move.b	#'L',(a6)+
.169
	move.b	#'*',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%11,d1
	add.b	#1,d1
	move.b	#0,d0
	bset	#7,d0
	rol.b	d1,d0
	vire_le
	;add.b	d0,-1(a6)
	move.b	#')',(a6)+
	bra	.fin_rout
.en_long9
	
					; deplacement 16 ou 32 bits
	move.b	#'(',(a6)+
	move.w	d0,d1
	and.w	#%111,d1
	move.w	d1,d5		; test de l'indirection
	tst.b	d1
	beq.s	.pas_indirection
	move.b	#'[',(a6)+
.pas_indirection
	move.w	d0,d1
	lsr	#4,d1
	and.w	#%11,d1
	cmp.b	#1,d1
	beq	.p_dep9
	cmp.b	#2,d1
	bne.s	.32b9		;dep 16 bits
	clr.l	d4
	move.w	d0,d4
	clr.l	d0
	move.w	(a4)+,d0
	btst	#15,d0
	beq.s	.posi9
	neg.w	d0
	move.b	#'-',(a6)+
	
.posi9
	bra.s	.posi19
.32b9
	clr.l	d4
	move.w	d0,d4
	clr.l	d0
	move.l	(a4)+,d0
	btst	#31,d0
	beq.s	.posi19
	neg.l	d0
	move.b	#'-',(a6)+
.posi19
.16b9
	bsr	affiche_nombre
	bsr	test_label
	move.l	d4,d0
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c519	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c519
	move.b	#'.',(a6)+
	btst	#4,d0		
	beq.s	.d169
	move.b	#'L',(a6)+
	bra.s	.d329
.d169
	move.b	#'W',(a6)+
.d329

	btst	#7,d0
	beq.s	.r_base		; pas de registre de base
	btst	#2,d5
	beq.s	.mm
	move.b	#']',(a6)+
.mm	
	bra.s	.p_r_base
.r_base
	move.b	#',',(a6)+
.p_dep9
	btst	#7,d0
	bne.s	.p_r_base		; pas de registre de base
	move.b	#'A',(a6)+
	move.b	#'0',(a6)+
	add.b	d2,-1(a6)
	btst	#2,d5
	beq.s	.mm1
	move.b	#']',(a6)+
.mm1
	btst	#6,d0
	bne.s	.p_r_base	
	move.b	#',',(a6)+	:<---- deconne
.p_r_base
	btst	#6,d0
	bne	.pas_index		; pas de registre d'index
	
	cmp.b	#',',-1(a6)
	beq.s	.p_v
	cmp.b	#'(',-1(a6)
	beq.s	.p_v
.v
	move.b	#',',(a6)+
.p_v
	
	
.p_dep19
	btst	#6,d0
	bne.s	.pas_index
	move.b	#'A',(a6)+
	btst	#15,d0
	bne.s	.pas_d19
	add.b	#3,-1(a6)	
.pas_d19
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#4,d1
	and.w	#%111,d1
	add.b	d1,-1(a6)
	move.b	#'.',(a6)+
	btst	#11,d0
	bne.S	.3219
	move.b	#'W',(a6)+
	bra.s	.1619
.3219
	move.b	#'L',(a6)+
.1619
	move.b	#'*',(a6)+
	move.b	#'0',(a6)+
	move.w	d0,d1
	lsr	#8,d1
	lsr	#1,d1
	and.w	#%11,d1
	add.b	#1,d1
	move.b	#0,d0
	bset	#7,d0
	rol.b	d1,d0
	vire_le
	;add.b	d0,-1(a6)
	
.pas_index
	tst.b	d5
	beq.s	.pl
	btst	#2,d5
	bne.s	.pl
	move.b	#']',(a6)+
.pl

	tst.b	d5
	beq.s	.p_i		; y a le od
	cmp.b	#1,d5
	beq.s	.p_i		; non
	cmp.b	#%101,d5
	beq.s	.p_i
	move.b	#',',(a6)+
	btst	#0,d5
	beq.s	.16bits
	move.l	(a4)+,d0
	btst	#31,d0
	beq.s	.po
	neg.l	d0
	move.b	#'-',(a6)+
.po
	bra.s	.32bits
.16bits
	****
	clr.l	d0
	****
	move.w	(a4)+,d0
	btst	#15,d0
	beq.s	.p
	neg.w	d0
	move.b	#'-',(a6)+
.p
.32bits
	bsr	affiche_nombre
	bsr	test_label
	lea	nombre,a0
	;move.b	#'$',(a6)+
.c5191	move.b	(a0)+,(a6)+
	tst.b	(a0)
	bne.s	.c5191
					; on aff les .l ou .w
	move.b	#'.',(a6)+
	btst	#0,d5
	beq.s	.seize
	move.b	#'L',(a6)+
	bra	.trente
.seize
	move.b	#'W',(a6)+
.trente

.p_i

	move.b	#')',(a6)+
.fin_rout
	movem.l	(sp)+,d0-d5
	rts

.erreur
	move.l	#'<-?-',(a6)+
	move.b	#'>',(a6)+
	movem.l	(sp)+,d0-d5
	rts

