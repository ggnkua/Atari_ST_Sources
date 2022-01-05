	MC68881
	TEXT
	output	d:\centinel\dsp\dsp_desa.o
	include	d:\centinel\both\define.s
	incdir	d:\centinel\dsp

COPY	macro
	move	d0,-(sp)
	move	ATTRIBUTE,d0
	lea	\1,a1
.L@	move.b	(a1)+,d0
	beq.s	.OUT@
	move	d0,(a6)+
	bra.S	.L@
.OUT@	move	(sp)+,d0
	endm

DESAS::		xref	DSP_REG,COL_ADR,COL_NOR
	movem.l	d0-d7/a1-a5,-(sp)
;a0=ptr sur le buffer
;a6=ptr sur le texte
	move.l	(a0)+,P_COUNT		;adr d‚but
	move	(a0)+,-(sp)		;nb d'instruction … produire
LOOP_DESAS
	*--------------------------*
	* Place l'adresse ou un LABEL
	*--------------------------*
	move.l	P_COUNT,d1
	move	#'P:',MEM_BANK		
	bsr	FIND_LABEL
	tst.b	d2
	beq.s	.RIEN
	move	COL_LAB,ATTRIBUTE
	cpy	'------',a6
	col_cpy a1,a6
	move	#$d,(a6)+
	subq	#1,(sp)			;une ligne de remplie...
	beq	.FIN			;on est au bout ?
.RIEN	
	move	COL_ADR,ATTRIBUTE
	bsr	HEXA0_24		;ADRESSE

	*--------------------------*


	
	*--------------------------*
	* Affiche un BKP si il y en a un
	*--------------------------*
	move	COL_NOR,ATTRIBUTE
	bsr	FIND_BKP						
	tst	d2
	bne.s	.FO
	cpy	<'    '>,a6
.FO	
	
	*--------------------------*
	

	bsr	FORME_CURSEUR	

	*--------------------------*


.DESAS	
	
	bsr	DESAS_ONE
	move	COL_NOR,ATTRIBUTE
	bsr	FIND_BKP_CC	
	
	move	#$d,(a6)+
	subq	#1,(sp)
	bne	LOOP_DESAS
.FIN	addq	#2,sp
	move	#$8000,(a6)+
	movem.l	(sp)+,d0-d7/a1-a5
	rts


;------------------------------------------------------------------------------
; affiche le petit curseur du PC
;------------------------------------------------------------------------------
FORME_CURSEUR::
	*--------------------------*
	* affiche la fleche si on est sur la ligne du PC
	* Change de couleur pour l'instruction du PC
	*--------------------------*
	xref	COL_PC
	move	#' ',d2
	cmp.l	DSP_REG+REG_PC,d1
	bne.s	.OK00
	
	move	ATTRIBUTE,d2
	move.b	#'',d2
	btst	#7,DSP_REG+REG_SR+2	;LOOP FLAG == 1 ?
	beq.s	.OK	
	cmp.l	DSP_REG+REG_LA,d1	;on est sur la fin d'ubne boucle ?
	bne.s	.OK		
	move.l	d1,d3

	*--------------------------*
	* calcule le sens de la fleche
	*1. recupere le bon SSH ds la pile ( -> SP-1)
	
	move.l	DSP_REG+REG_SP,d3
	subq.l	#1,d3
	;move.l	(DSP_REG+REG_SS,d3.l*8),d3
	move.l	DSP_REG+REG_SSH,d3
	sub.l	d1,d3
	beq.s	.OK			;"en th‚orie" ca se peut pas, mais bon,...
	bpl.s	.POS
	move.b	#'',d2
	bra.s	.OK
.POS	move.b	#'',d2
.OK	move	COL_PC,ATTRIBUTE	

.OK00	move	d2,(a6)+

	rts
	
;------------------------------------------------------------------------------
; recherche ds la table de break points
; si il y en a un sur la ligne
; affiche selon son type
;------------------------------------------------------------------------------
FIND_BKP::
	xref	TAB_BKPT,COL_BKPT
	movem.l	d0/d1/d7/a0,-(sp)
	clr.l	BKP_ADR			;raz
	
	lea	TAB_BKPT,a0
	move.l	P_COUNT,d0
	moveq	#0,d1
	move	#nb_dsp_bkp-1,d7	;max 256 BKP
.LOOP	tst	(a0)
	beq	.GO
	
	cmp.l	Adresse(a0),d0		;PC == BKPT ADR ?
	bne	.GO	
	move	COL_BKPT,ATTRIBUTE
	

	move	Actif(a0),d0

	btst	#1,d0			;bit P(ermanence)
	bne.s	.PERMANENT		

	btst	#0,d0			;bit Actif
	beq.s	.GO			

	
.NORMAL	
	cpy	<'[00]'>,a6	
	bra.S	.NUM
.PERMANENT	
	cpy	'<00>',a6	

.NUM	unpk	d1,d1,#0
	add.b	d1,-3(a6)
	lsr	#8,d1
	add.b	d1,-5(a6)
	moveq	#-1,d2
	
	move.l	Ptr_expr(a0),d0
	beq.s	.FIN
	move.l	d0,BKP_ADR		;sauve l'adresse de la condition
	bra.s	.FIN
.GO	add	#BKP_Long,a0
	addq	#1,d1
	dbra	d7,.LOOP
	moveq	#0,d2
.FIN	
	move	COL_NOR,ATTRIBUTE
	movem.l	(sp)+,d0/d1/d7/a0
	rts	

;------------------------------------------------------------------------------
; ajoute une condition en fin de ligne si BKP_ADR … ‚t‚ positionn‚
; ds find_bkp
;------------------------------------------------------------------------------
FIND_BKP_CC	xref	TAB_BKPT,COL_BKPT
	movem.l	d0/d7/a0,-(sp)


	move.l	BKP_ADR,d0
	beq.s	.FIN
	move.l	d0,a0
	move	COL_BKPT,ATTRIBUTE
	move	ATTRIBUTE,d0
	move.b	#"[",d0
	move	d0,(a6)+
.COP	move.b	(a0)+,d0
	beq.S	.CLOSE
	move	d0,(a6)+
	bra.S	.COP		
	
.CLOSE	move.b	#"]",d0
	move	d0,(a6)+
	move	COL_NOR,ATTRIBUTE
.FIN	
	movem.l	(sp)+,d0/d7/a0
	rts	
	
;************************************************
DESAS_ONE::	
;a0=dump p
;a6=buffer text
	movem.l	d0-d7/a1-a5,-(sp)	
	lea	NO_PARALLEL,a1
.OK	move.l	(a0)+,d0
	addq.l	#1,P_COUNT
.NEXT	move.l	d0,d1
	and.l	(a1)+,d1
	cmp.l	(a1)+,d1
	bne.s	.NOFOUND
	bsr	FOUND	
	bra.S	.FIN
.NOFOUND
	add	#12,a1
	cmp.l	#END_NP,a1
	blt	.NEXT

	lea	MULTIPLY,a1
.NEXT1	move.l	d0,d1
	and.l	(a1)+,d1
	cmp.l	(a1)+,d1
	bne.s	.NOFOUND2
	bsr	FOUND
	bsr	DEC_PAR
	bra.s	.FIN
.NOFOUND2
	add	#12,a1
	cmp.l	#END_MULT,a1
	blt	.NEXT1
.FIN	movem.l	(sp)+,d0-d7/a1-a5	
	rts
FOUND	
	move.l	a1,a2
	move	ATTRIBUTE,d1
.LOOP	move.b	(a2)+,d1
	cmp.b	#' ',d1
	beq	.OUT
	move	d1,(a6)+
	bra.s	.LOOP
.OUT	addq	#8,a1
	jsr	([a1])
	rts
;************************************************
FIND_LABEL	xref	SYMBOLS_PTR,COL_LAB,COL_NOR
;IN:		d1=adresse 
;		MEM BANK
;OUT:		d2 (0= pas trouv‚  1=trouv‚)
;		a1 = ptr sur le symbol
	move	MEM_BANK,d2
	clr.b	d2

	move.l	SYMBOLS_PTR,a1
	tst.l	a1			;ya t il une table de symboles ?
	beq.s	.FIN
	move.l	(a1)+,d7
	subq	#1,d7
	bmi.s	.FIN
.LOOP	cmp.w	(a1)+,d2
	beq.s	.SUITE
	addq	#8,a1
	dbra	d7,.LOOP	
	bra.s	.FIN
.SUITE	cmp.l	(a1)+,d1
	beq.s	.FOUND
	addq	#4,a1
	dbra	d7,.LOOP
	bra.s	.FIN
.FOUND	
	move.l	(a1),a1
	st	d2
	rts
.FIN	sf	d2
	rts	

;************************************************
HEXA_24	::
	movem.l	d2/d7,-(sp)
	and.l	#$ffffff,d1
	moveq	#0,d7
	move.b	ATTRIBUTE,(a6)+
	move.b	#'$',(a6)+
	move.l	d1,d2
	swap	d2
	lsr	#4,d2
	bsr	DIGIT
	move.l	d1,d2
	swap	d2
	bsr	DIGIT
	move.l	d1,d2
	lsl.l	#4,d2
	swap	d2
	bsr	DIGIT
	move.l	d1,d2
	lsl.l	#8,d2
	swap	d2
	bsr	DIGIT
	move	d1,d2
	lsr	#4,d2
	bsr	DIGIT
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
HEXA_16	and.l	#$ffff,d1
	bra	HEXA_24
HEXA_12	and.l	#$fff,d1
	bra	HEXA_24
HEXA_8	and.l	#$ff,d1
	bra	HEXA_24
HEXA_6	and.l	#$3f,d1
	bra	HEXA_24
HEXA_5::	and.l	#$1f,d1
	bra	HEXA_24
DIGIT		xref	ATTRIBUTE
	;digit ds d2
	and	#$f,d2
	bne.s	.AFF
	tst	d7
	beq.s	.FIN
.AFF	st	d7
	move.b	ATTRIBUTE,(a6)+
	move.b	(TAB_CONV.l,d2.w),(a6)+
.FIN	rts
;**************************************	
;*******************************************************
HEXA0_32::	
	movem.l	d2/d7,-(sp)
	move.l	d1,d2
	swap	d2
	lsr	#8,d2
	lsr	#4,d2
	bsr	DIGIT0
	move.l	d1,d2
	swap	d2
	lsr	#8,d2
	bsr	DIGIT0
	move.l	d1,d2
	swap	d2
	lsr	#4,d2
	bsr	DIGIT0
	move.l	d1,d2
	swap	d2
	bsr	DIGIT0
	move.l	d1,d2
	lsl.l	#4,d2
	swap	d2
	bsr	DIGIT0
	move.l	d1,d2
	lsl.l	#8,d2
	swap	d2
	bsr	DIGIT0
	move	d1,d2
	lsr	#4,d2
	bsr	DIGIT0
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
HEXA0_24::	
	movem.l	d2/d7,-(sp)
	and.l	#$ffffff,d1
	move.l	d1,d2
	swap	d2
	lsr	#4,d2
	bsr	DIGIT0
	move.l	d1,d2
	swap	d2
	bsr	DIGIT0
	move.l	d1,d2
	lsl.l	#4,d2
	swap	d2
	bsr	DIGIT0
	move.l	d1,d2
	lsl.l	#8,d2
	swap	d2
	bsr	DIGIT0
	move	d1,d2
	lsr	#4,d2
	bsr	DIGIT0
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
HEXA0_16::
	movem.l	d2/d7,-(sp)
	and.l	#$ffff,d1
	move.l	d1,d2
	lsl.l	#4,d2
	swap	d2
	bsr	DIGIT0
	move.l	d1,d2
	lsl.l	#8,d2
	swap	d2
	bsr	DIGIT0
	move	d1,d2
	lsr	#4,d2
	bsr	DIGIT0
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
HEXA0_12::
	movem.l	d2/d7,-(sp)
	and.l	#$fff,d1
	move.l	d1,d2
	lsl.l	#8,d2
	swap	d2
	bsr	DIGIT0
	move	d1,d2
	lsr	#4,d2
	bsr	DIGIT0
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
HEXA0_8::
	movem.l	d2/d7,-(sp)
	and.l	#$ff,d1
	move	d1,d2
	lsr	#4,d2
	bsr	DIGIT0
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
HEXA0_6::
	movem.l	d2/d7,-(sp)
	and.l	#$3f,d1
	move	d1,d2
	lsr	#4,d2
	bsr	DIGIT0
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
HEXA0_5::
	movem.l	d2/d7,-(sp)
	and.l	#$1f,d1
	move	d1,d2
	lsr	#4,d2
	bsr	DIGIT0
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
HEXA0_4::
	movem.l	d2/d7,-(sp)
	and.l	#$f,d1
	move	d1,d2
	bsr	DIGIT0
	movem.l	(sp)+,d2/d7
	rts
	
DIGIT0	;digit ds d2
	xref	ATTRIBUTE
	move.b	ATTRIBUTE,(a6)+
	and	#$f,d2
	move.b	(TAB_CONV.l,d2.w),(a6)+
.FIN	rts
;**************************************	

FRAC_24::
*IN
*	a6	ptr ASCII
*	a5	ptr MASK
*	d1	le word … convertir

NB_DIGIT	SET	12		;nb char sans compter " +." !!! pair !!!

	xref	ATTRIBUTE
	movem.l	d0/d1/d7/a0-a4,-(sp)

	move.l	d1,d0
	moveq	#0,d2
	
	* pour arrondir, il faut augmenter d0 de justze ce qu'il faut
	* avec une division doit y'avoir moyen...
	
	*------------------*
	* efface le buf
	*------------------*
	lea	RESULT,a1
	move.l	d0,d3
	lsl.l	#8,d3
	asr.l	#8,d3
	bpl.s	.OK0
	cmp.l	#$800000,d0
	beq.s	.OK0
	move.l	#$800000,d0
	sub.l	d3,d0
	and.l	#$7fffff,d0
.OK0
	move.l	#$800000,d1
	move	#NB_DIGIT-1,d7
.LOOP	divul.l	d1,d2:d0
	move.b	d0,(a1)+
	move.l	d2,d0	
	mulu.l	#10,d0
	dbra	d7,.LOOP			

	
	*------------------*
	* transfert en ASCII
	*------------------*
	
	lea	RESULT,a1
	move	ATTRIBUTE,d2
	move.b	#'+',d2
	tst.l	d3
	bpl.s	.POS
	move.b	#'-',d2

.POS	move	d2,(a6)+
	move.b	(a1)+,d2
	add.b	#'0',d2
	move	d2,(a6)+
	move.b	#'.',d2
	move	d2,(a6)+
	move.w	#'S9',(a5)+
	move.b	#' ',(a5)+
	
	
	
	move	#NB_DIGIT-2-1,d7
.ASC	move.b	(a1)+,d2
	add.b	#'0',d2
	move	d2,(a6)+
	move.b	#'9',(a5)+
	dbra	d7,.ASC

.FIN		
	movem.l	(sp)+,d0/d1/d7/a0-a4
	rts
RESULT	ds.b	16


OLD_FRAC_24::
	movem.l	d0/d1,-(sp)
	fmovem.x fp0/fp1,-(sp)
;conversion d'une valeur 24b en fraction DSP
;d0 = valeur 24b
;a6 = buffer DEST
	lsl.l	#8,d0		;sur 32 bits
	fmove.l	d0,fp0	
	fmove.l	#$7fffffff,fp1	;diviseur
	fdiv.x	fp1,fp0
	fmove.p	fp0,FRAC{#17}	;Mantisse de 7

	move.b	#'+',d0
	btst	#7,FRAC
	beq.s	.MPOS
	move.b	#'-',d0
.MPOS	move.b	d0,(a6)+	;signe de la MAntisse
	
	move	#'0.',(a6)+

	move.b	FRAC+3,d0
	unpk	d0,d0,#'00'
	move.b	d0,(a6)+	;digit 0
	
	move.b	FRAC+4,d0
	unpk	d0,d0,#'00'
	move	d0,(a6)+	;digit 1 et 2
	move.b	FRAC+5,d0
	unpk	d0,d0,#'00'
	move	d0,(a6)+	;digit 3 et 4

	move.b	FRAC+5,d0
	unpk	d0,d0,#'00'
	move	d0,(a6)+	;digit 5 et 6

	ftst.x	fp0		;la mantisse est nulle ? 
	fbeq	.NOEXP		;pas d'exposant
	
	move.b	FRAC+1,d1
	and	#$f,d1
	subq	#1,d1
	beq.s	.FIN
	
	move.b	#'E',(a6)+
			
	move.b	#'+',d0
	btst	#6,FRAC
	beq.s	.EPOS
	move.b	#'-',d0
.EPOS	move.b	d0,(a6)+	;signe de l'exposant

	unpk	d1,d1,#'00'
	move.b	d1,(a6)+	;Exposant
	bra.s	.FIN
.NOEXP	move	#'  ',(a6)+
	move.b	#' ',(a6)+

.FIN	fmovem.x	(sp)+,fp0/fp1
	movem.l	(sp)+,d0/d1

	rts

FRAC	ds	12


;**************************************	

	include	table.S
	include	NO_PARAL.S
	include	PARAL.S
	include	INSTRUCT.S

	DATA
TAB_CONV:: dc.b	'0123456789ABCDEF'
	BSS
P_COUNT::	ds.l	1
BKP_ADR		ds.l	1