	include	d:\centinel\both\define.s
	output	d:\centinel\40\main.inc\aff_dump.o
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
	xref	buffer_r,buffer_r_anc,affiche_nombre,CPU_TYPE,buffer_int,buffer_int_anc,COL_PC,chaine_ascii	





;------------------------------------------------------------------------------
GEN_ASCII::	
;affiche en ASCII cr,lf et 0 font mise … la ligne
	
	xref	COL_NOR,COL_ADR
	movem.l	d0-a6,-(sp)
	move.l	adr_debut(a0),a1
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
	move	COL_NOR,d1
	move	d1,ATTRIBUTE
	move	Hauteur(a0),d7
	subq	#3,d7
	bmi.s	.ABORT
.LOOP	
	move	Largeur(a0),d6
	subq	#3,d6
	bmi.s	.ABORT
.XLOOP		
	bsr	get_a1
	
	tst	d2
	beq.s	.OK
.err0	
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	#'H',(a5)+
	bra.S	.CAR
.OK
	tst.b	d1
	beq.s	.CR
	cmp.b	#$d,d1
	beq.s	.CR
	cmp.b	#$a,d1
	beq.s	.LF
	move	d1,(a6)+
	move.b	#'A',(a5)+
.CAR	dbra	d6,.XLOOP
.NX	dbra	d7,.LOOP	
.ABORT	move	#$8000,(a6)+
	clr.b	(a5)+
.FIN	move.l	a1,adr_fin(a0)
	movem.l	(sp)+,d0-a6
	rts
.CR	
	cmp.b	#$a,-1(a6)	;un seul retour chariot … la suite...
	beq.s	.XLOOP
	move	#$d,(a6)+
	move.b	#$d,(a5)+
	bra	.CAR

.LF	
	cmp.b	#$d,-1(a6)	;un seul retour chariot … la suite...
	beq.s	.XLOOP
	move	#$d,(a6)+
	move.b	#$d,(a5)+
	bra	.CAR



GEN_H16::
**********************************************
** routine de generation de l'hexa et ascii **
**********************************************
	;illegal
	
	xref	COL_NOR,COL_ADR,HEXA0_16,HEXA0_32,key_valid,HEXA0_8,MODE_EDIT,CONV_A2H,MASK_BUF
	movem.l	d0-a6,-(sp)

;*** calcul du nombre de colonnes
	move.l	adr_debut(a0),a1
	moveq	#0,d6
	move	Largeur(a0),d6
	sub	#2+8+1,d6			;-2(bords) -8(adresse) -1 espace bin/ascii +1 (espace impaire)
	bpl.s	.POS
	moveq	#0,d6
.POS	divu	#5,d6				;nb colonnes	'_hhhh'
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#2,d7				;-2(titre+bottom)
	ext.l	d7
	move	d7,d5
	mulu	d6,d5				;nb_word = nb_ligne*nb_colonnes
	subq	#1,d7
	move.l	adr_debut(a0),d0
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
.LOOP	
	move	COL_ADR,ATTRIBUTE
	move.l	a1,d1
	jsr	HEXA0_32
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi	.GARG				;en th‚orie ca se peut pas, mais on assure
	move	d1,d0
	btst	#0,d0
	bne	.IMPAIRE
.LOOPVAL	
	move	#' ',(a6)+
	move.b	#' ',(a5)+

	bsr	get_a1
	tst	d2
	bmi.s	.err0
	subq	#1,a1	
	jsr	HEXA0_8		
	addq	#1,a1	
	move	#'HH',(a5)+
	bra.S	.octet2
.err0	
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
.octet2	bsr	get_a1
	tst	d2
	bmi.s	.err1
	subq	#1,a1	
	jsr	HEXA0_8		
	addq	#1,a1	
	move	#'HH',(a5)+
	bra.S	.octet3
.err1	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
.octet3
	dbra	d5,.LOOPVAL
	;move.l	#'    ',(a6)+
	;move	#'  ',(a5)+	
.GARG	move.b	#$d,(a5)+
	move	#$d,(a6)+
	add	nb_colonnes(a0),d0
	dbra	d7,.LOOP	
	move	#$8000,(a6)+
	clr.b	(a5)+
	move.l	d0,adr_fin(a0)
.FIN	movem.l	(sp)+,d0-a6
	rts
.IMPAIRE
	bsr	get_a1
	tst	d2
	bmi.s	.err2
	subq	#1,a1
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	bsr.l	HEXA0_8				;space+binaire
	addq	#1,a1	
	move	#'HH',(a5)+
	bra.S	.sui09
.err2	move	#' ',(a6)+
	move.b	#' ',(a5)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
.sui09
	subq	#1,d5
	bmi	.GARG
.LOOPVAL2	
	move	#' ',(a6)+
	move.b	#' ',(a5)+

	bsr	get_a1
	tst	d2
	bmi.s	.err00
	subq	#1,a1	
	jsr	HEXA0_8		
	addq	#1,a1	
	move	#'HH',(a5)+
	bra.S	.octet02
.err00
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
.octet02	
	bsr	get_a1
	tst	d2
	bmi.s	.err01
	subq	#1,a1	
	jsr	HEXA0_8		
	addq	#1,a1	
	move	#'HH',(a5)+
	bra.S	.octet03
.err01	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
.octet03
	dbra	d5,.LOOPVAL2
	
	bsr	get_a1
	tst	d2
	bmi.s	.err002
	subq	#1,a1
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	bsr.l	HEXA0_8				;space+binaire
	addq	#1,a1	
	move	#'HH',(a5)+
	bra.S	.sui009
.err002	move	#' ',(a6)+
	move.b	#' ',(a5)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
.sui009
	move	#' ',(a6)+
	bra	.GARG	

;------------------------------------------------------------------------------
; transformation vers la RAM
;------------------------------------------------------------------------------
GEN_H16_INV::	
	xref	ASCII_BUF
	movem.l	d0-a6,-(sp)
	lea	ASCII_BUF,a6
	move.l	adr_debut(a0),a1
	move	Hauteur(a0),d7
	subq	#3,d7
.LOOP	add	#8*2,a6	;adresse
	move	nb_colonnes(a0),d5
	subq	#1,d5	;;
	move.l	a1,d0
	btst	#0,d0
	bne.s	.IMPAIRE
.COLONNE
	addq	#2,a6	;espace	
	bsr	CONV_OCTET
	bsr	CONV_OCTET
	dbra	d5,.COLONNE	
.SC	cmp	#$d,(a6)+
	bne.s	.SC
	dbra	d7,.LOOP	
.FIN	
	movem.l	(sp)+,d0-a6
	rts
.IMPAIRE	
	addq	#2,a6	;espace	
	bsr	CONV_OCTET
	move.b	d1,(a1)+
	subq	#1,d5
	bmi.s	.SC0
.COLONNE2	
	addq	#2,a6	;espace	

	bsr	CONV_OCTET
	bsr	CONV_OCTET
	dbra	d5,.COLONNE2	
.SC0	addq	#2,a6	;espace	
	bsr	CONV_OCTET
	bra.s	.SC

	*-----------------*
	* lit un octet en ASCII
	* et le sauve en RAM
	*-----------------*
CONV_OCTET
	move	(a6)+,d0
	and	#$ff,d0
	sub.b	#'0',d0
	cmp.b	#9,d0
	ble.s	.OK0
	sub.b	#'A'-'9'-1,d0
	
.OK0	move.b	d0,d1
	lsl	#4,d1

	move	(a6)+,d0
	and	#$ff,d0
	sub.b	#'0',d0
	cmp.b	#9,d0
	ble.s	.OK1
	sub.b	#'A'-'9'-1,d0
.OK1
	or	d0,d1

	bsr	write_a1
	rts
		
;------------------------------------------------------------------------------

GEN_HEXASCII16::
**********************************************
** routine de generation de l'hexa et ascii **
**********************************************

	xref	COL_NOR,COL_ADR,HEXA0_16,HEXA0_32,key_valid,HEXA0_8,MODE_EDIT,CONV_A2H,MASK_BUF
	movem.l	d0-a6,-(sp)
;*** calcul du nombre de colonnes
	
	
	move.l	adr_debut(a0),a1
	moveq	#0,d6
	move	Largeur(a0),d6
	sub	#2+8+1+1,d6			;-2(bords) -8(adresse) -1 espace bin/ascii +1 (espace impaire)
	bpl.s	.POS
	moveq	#0,d6
.POS	divu	#7,d6				;nb colonnes	'_hhhh' +'AA'
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#2,d7				;-2(titre+bottom)
	ext.l	d7
	move	d7,d5
	mulu	d6,d5				;nb_word = nb_ligne*nb_colonnes
	subq	#1,d7
	move.l	adr_debut(a0),d0
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
.LOOP	
	move	nb_colonnes(a0),d1
	mulu	#5,d1				;pointe sur l'ascii
	lea	10(a5,d1.w),a3
	lea	20(a6,d1.w*2),a4

	move	COL_ADR,ATTRIBUTE
	move.l	a1,d1
	jsr	HEXA0_32
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi	.GARG				;en th‚orie ca se peut pas, mais on assure
	move	d1,d0
	btst	#0,d0
	bne	.IMPAIRE
.LOOPVAL	
	move	#' ',(a6)+
	move.b	#' ',(a5)+

	bsr	get_a1
	tst	d2
	bmi.s	.err0
	subq	#1,a1	
	jsr	HEXA0_8		
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	(a1)+,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
	bra.S	.octet2
.err0	
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
.octet2	bsr	get_a1
	tst	d2
	bmi.s	.err1
	subq	#1,a1	
	jsr	HEXA0_8		
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	(a1)+,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
	bra.S	.octet3
.err1	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
.octet3
	
	
	dbra	d5,.LOOPVAL
	move.l	#'    ',(a6)+
	move	#'  ',(a5)+	
	move.l	a4,a6
	move.l	a3,a5
.GARG	move.b	#$d,(a5)+
	move	#$d,(a6)+
	add	nb_colonnes(a0),d0
	dbra	d7,.LOOP	
	move	#$8000,(a6)+
	clr.b	(a5)+
	move.l	d0,adr_fin(a0)
.FIN	movem.l	(sp)+,d0-a6
	rts
.IMPAIRE
	bsr	get_a1
	tst	d2
	bmi.s	.err2
	subq	#1,a1
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	bsr.l	HEXA0_8				;space+binaire
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	(a1)+,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
	bra.S	.sui09
.err2	move	#' ',(a6)+
	move.b	#' ',(a5)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
.sui09
	subq	#1,d5
	bmi	.GARG
.LOOPVAL2	
	move	#' ',(a6)+
	move.b	#' ',(a5)+

	bsr	get_a1
	tst	d2
	bmi.s	.err00
	subq	#1,a1	
	jsr	HEXA0_8		
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	(a1)+,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
	bra.S	.octet02
.err00
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
.octet02	
	bsr	get_a1
	tst	d2
	bmi.s	.err01
	subq	#1,a1	
	jsr	HEXA0_8		
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	(a1)+,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
	bra.S	.octet03
.err01	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
.octet03
	dbra	d5,.LOOPVAL2
	
	bsr	get_a1
	tst	d2
	bmi.s	.err002
	subq	#1,a1
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	bsr.l	HEXA0_8				;space+binaire
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	(a1)+,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
	bra.S	.sui009
.err002	move	#' ',(a6)+
	move.b	#' ',(a5)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	d1,(a6)+
	move	#'HH',(a5)+
	bset	#5,ATTRIBUTE			;affiche binaire
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	move.b	#'A',(a3)+
	bclr	#5,ATTRIBUTE			;affiche normal
.sui009
	move	#' ',(a6)+
	move.l	a4,a6
	move.l	a3,a5

	bra	.GARG	


GEN_HEXASCII16_INV::	
*******************************************
*** G‚n‚ration inverse de l'ascii-hexa  ***
*******************************************

;transfert de la fenetre => RAM
	movem.l	d0-a6,-(sp)
	tst	key_valid	
	beq	.FIN				;y a t il eu saisie ?
	
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
	move.l	adr_debut(a0),a1
	move	Hauteur(a0),d7
	subq	#3,d7
	move	a1,d1
	btst	#0,d1
	bne	HA_INV_IMPAIRE
	cmp.b	#'A',MODE_EDIT
	beq	.ASCC
.LOOP	add	#8*2,a6				;adresse
	move	nb_colonnes(a0),d5
	subq	#1,d5	;
.COLONNE
	addq	#2,a6	;'_'	
	moveq	#0,d1
	move	#4-1,d6
.CONV	lsl.l	#4,d1
.ADD	move.w	(a6)+,d0
	and	#$ff,d0
	cmp.b	#'9',d0
	ble	.NUM
	sub.b	#'A'-10,d0
	bra	.GO
.NUM	sub.b	#'0',d0
.GO	or.b	d0,d1
	dbra	d6,.CONV
	move	d1,d3
	lsr	#8,d1
	bsr	write_a1
	move	d3,d1
	bsr	write_a1
	dbra	d5,.COLONNE	
.SC	cmp	#$d,(a6)+
	bne.s	.SC
	dbra	d7,.LOOP	
	bra	.FIN
.ASCC	move	nb_colonnes(a0),d0
	mulu	#5*2,d0
	add	d0,a6
	add	#20,a6				;adresse+space
	move	nb_colonnes(a0),d5
	subq	#1,d5	;
.COLONNE2
	rept	2
	addq	#1,a6
	move.b	(a6)+,d1
	bsr	write_a1
	;move.b	(a6)+,(a1)+
	endr
	dbra	d5,.COLONNE2
.SC2	cmp	#$d,(a6)+
	bne.s	.SC2
	dbra	d7,.ASCC		

.FIN	
.END	movem.l	(sp)+,d0-a6
	rts

HA_INV_IMPAIRE
	cmp.b	#'A',MODE_EDIT
	beq	.ASCC
.LOOP	add	#8*2,a6				;adresse
	move	nb_colonnes(a0),d5

	addq	#2,a6	;'_'	
	move	#2-1,d6
	jSR	CONV_A2H
	bsr	write_a1
	subq	#2,d5	;
	BMI.S	.OK0
.COLONNE
	addq	#2,a6	;'_'	
	move	#4-1,d6
	jSR	CONV_A2H
	move	d1,d3
	lsr	#8,d1
	bsr	write_a1
	move	d3,d1
	bsr	write_a1
	
	dbra	d5,.COLONNE	
.OK0	addq	#2,a6	;'_'	
	move	#2-1,d6
	jSR	CONV_A2H
	bsr	write_a1
.SC	cmp	#$d,(a6)+
	bne.s	.SC
	dbra	d7,.LOOP	
	bra	.FIN

.ASCC	move	nb_colonnes(a0),d0
	mulu	#5*2,d0
	add	d0,a6
	add	#20,a6				;adresse+space
	move	nb_colonnes(a0),d5

	addq	#1,a6
	move.b	(a6)+,d1
	bsr	write_a1
	subq	#2,d5	;
	BMI.S	.OK1
.COLONNE2
	rept	2
	addq	#1,a6
	move.b	(a6)+,d1
	bsr	write_a1
	endr
	dbra	d5,.COLONNE2
.OK1	addq	#1,a6
	move.b	(a6)+,d1
	bsr	write_a1
.SC2	cmp	#$d,(a6)+
	bne.s	.SC2
	dbra	d7,.ASCC		
.FIN	
.END	movem.l	(sp)+,d0-a6
	rts




get_a1::
	moveq	#0,d2			; on ramene dans un registre a 
	lit_mem.b	a1,d1		; voir la valeur de d0
	addq.l	#1,a1
	tst.b	ERR_MEM
	beq.s	.SUITE
	moveq	#-1,d2
.SUITE
	rts
	
	

write_a1
	moveq	#0,d2
	writ_mem.b	d1,a1
	addq.l	#1,a1
	tst.b	ERR_MEM
	bne.s	.err
	rts
.err
	move.l	#-1,d2
	rts


;------------------------------------------------------------------------------
GEN_IO::
	move	IO_SIZE,d0
	;beq	IO_8				
	cmp	#1,d0
	beq	IO_16
	cmp	#2,d0
	beq	IO_32
	
;------------------------------------------------------------------------------
;IO_32
;------------------------------------------------------------------------------
; affichage de l'hexa sans protection des IO....
;------------------------------------------------------------------------------
IO_32
	xref	COL_NOR,COL_ADR,HEXA0_16,HEXA0_32,key_valid,HEXA0_8,MODE_EDIT,CONV_A2H,MASK_BUF
	movem.l	d0-a6,-(sp)
;*** calcul du nombre de colonnes
	move.l	adr_debut(a0),d0
	and	#~3,d0
	move.l	d0,a1
	moveq	#0,d6
	move	Largeur(a0),d6
	sub	#2+8+1,d6			;-2(bords) -8(adresse) -1 espace bin/ascii +1 (espace impaire)
	bpl.s	.POS
	moveq	#0,d6
.POS	divu	#9,d6				;nb colonnes	'_hhhhhhhh'
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#2,d7				;-2(titre+bottom)
	ext.l	d7
	move	d7,d5
	mulu	d6,d5				;nb_word = nb_ligne*nb_colonnes
	subq	#1,d7
	move.l	adr_debut(a0),d0
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
.LOOP	
	move	COL_ADR,ATTRIBUTE
	move.l	a1,d1
	jsr	HEXA0_32
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi	.GARG				;en th‚orie ca se peut pas, mais on assure
.LOOPVAL	
	move	#' ',(a6)+
	move.b	#' ',(a5)+

	lit_mem_io.l	a1,d1
	addq	#4,a1	
	jsr	HEXA0_32
	move.l	#'HHHH',(a5)+
	move.l	#'HHHH',(a5)+
	dbra	d5,.LOOPVAL
.GARG	move.b	#$d,(a5)+
	move	#$d,(a6)+
	add	nb_colonnes(a0),d0
	dbra	d7,.LOOP	
	move	#$8000,(a6)+
	clr.b	(a5)+
	move.l	d0,adr_fin(a0)
.FIN	movem.l	(sp)+,d0-a6
	rts


;------------------------------------------------------------------------------
;IO_16
;------------------------------------------------------------------------------
; affichage de l'hexa sans protection des IO....
;------------------------------------------------------------------------------
IO_16::
	xref	COL_NOR,COL_ADR,HEXA0_16,HEXA0_32,key_valid,HEXA0_8,MODE_EDIT,CONV_A2H,MASK_BUF
	movem.l	d0-a6,-(sp)
;*** calcul du nombre de colonnes
	move.l	adr_debut(a0),d0
	and	#~1,d0
	move.l	d0,a1
	moveq	#0,d6
	move	Largeur(a0),d6
	sub	#2+8+1,d6			;-2(bords) -8(adresse) -1 espace bin/ascii +1 (espace impaire)
	bpl.s	.POS
	moveq	#0,d6
.POS	divu	#5,d6				;nb colonnes	'_hhhh'
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#2,d7				;-2(titre+bottom)
	ext.l	d7
	move	d7,d5
	mulu	d6,d5				;nb_word = nb_ligne*nb_colonnes
	subq	#1,d7
	move.l	adr_debut(a0),d0
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
.LOOP	
	move	COL_ADR,ATTRIBUTE
	move.l	a1,d1
	jsr	HEXA0_32
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi	.GARG				;en th‚orie ca se peut pas, mais on assure
.LOOPVAL	
	move	#' ',(a6)+
	move.b	#' ',(a5)+

	lit_mem_io.w	a1,d1
	addq	#2,a1	
	jsr	HEXA0_16
	move.l	#'HHHH',(a5)+
	dbra	d5,.LOOPVAL
.GARG	move.b	#$d,(a5)+
	move	#$d,(a6)+
	add	nb_colonnes(a0),d0
	dbra	d7,.LOOP	
	move	#$8000,(a6)+
	clr.b	(a5)+
	move.l	d0,adr_fin(a0)
.FIN	movem.l	(sp)+,d0-a6
	rts
	
	
;------------------------------------------------------------------------------
;	DATA
;------------------------------------------------------------------------------
IO_SIZE::	dc	2
;------------------------------------------------------------------------------
