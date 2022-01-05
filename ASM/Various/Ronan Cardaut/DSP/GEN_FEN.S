	output	d:\centinel\dsp\gen_fen.o
	incdir	d:\centinel\dsp

	include	d:\centinel\both\define.s
	;include	d:\Centinel\both\GEM.EQU
	;include	d:\Centinel\both\XBIOS.EQU

	;opt	p=68882
	;opt	p=68030

	MC68881




;------------------------------------------------------------------------------
;float READ_FLOAT(char *)
;	lit une chaine et ressort le float correspondant
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
READ_FLOAT::
	movem.l	d0/d1/d6/d7/a0,-(sp)
	fmovem	fp1,-(sp)

	moveq	#0,d0
	fmove.s	#0.0,fp0		;valeur de la mantisse
	moveq	#0,d7		;signe de la mantisse
	moveq	#0,d6		;signe de l'exponent
	moveq	#0,d1		;valeur de l'exponent
	
	*------------------------------
	* lit le signe du nombre
	*------------------------------
	move.b	(a0)+,d0
	cmp.b	#'+',d0
	beq.s	.POS
	cmp.b	#'-',d0
	bne.s	.NUM
	st	d7		;il est negatif
	bra.s	.POS	
.NUM	subq	#1,a0
.POS	
	*------------------------------
	* lit jusqu'a la virgule
	*------------------------------
.READ_INT
	move.b	(a0)+,d0
	beq	.FIN	
	cmp.b	#'.',d0
	beq	.DECI	

	fmul.s	#10.0,fp0
	sub.b	#'0',d0
	fmove.b	d0,fp1
	fadd	fp1,fp0
	bra.s	.READ_INT


	*------------------------------
	* lit la partie decimale
	*------------------------------

.DECI	
	fmove.s	#1E-1,fp2
.READ_DECI
	move.b	(a0)+,d0
	beq	.FIN	
	cmp.b	#'E',d0
	beq	.EXP
	cmp.b	#'e',d0
	beq	.EXP
	sub.b	#'0',d0
	fmove.b	d0,fp1
	fmul	fp2,fp1
	fadd	fp1,fp0
	fmul.s	#0.1,fp2
	bra.S	.READ_DECI	

	*------------------------------
	* lit l'exponent
	*------------------------------
.EXP				
	move.b	(a0)+,d0
	beq	.FIN
	cmp.b	#' ',d0		;peut etre un espace par commodit‚ ?
	beq	.EXP		;on le saute
	
	cmp.b	#'+',d0
	beq	.READ_EXP
	cmp.b	#'-',d0
	bne	.OK0
	st	d6
	bra.s	.READ_EXP
.OK0	subq	#1,a0
	
.READ_EXP
	move.b	(a0)+,d0
	beq	.COMPUTE_EXPONENT
	cmp.b	#' ',d0		
	beq	.COMPUTE_EXPONENT
			
	sub.b	#'0',d0
	and.l	#$ff,d0
	mulu	#10,d1
	add.l	d0,d1
	bra.s	.READ_EXP



	*------------------------------
	* on connait l'exponent
	* et la mantisse
	* on calcule le float..
	*------------------------------
.COMPUTE_EXPONENT
	tst	d7
	beq	.POS0
	fneg	fp0
.POS0					
	tst	d6
	beq	.POS1
	neg.l	d1
.POS1	
	fmove.l	d1,fp1
	ftentox	fp1,fp1
	fmul	fp1,fp0	
.FIN
	fmovem	(sp)+,fp1
	movem.l	(sp)+,d0/d1/d6/d7/a0
	rts
	

	
;------------------------------------------------------------------------------
;void FLOAT_TO_SCI(float , char*)
; affichage d'un flottant de format s d ou x ( et meme + facilement )
; ressort:
;	+~~	ou -~~
;	+0	ou -0
;	+Nan	ou -Nan
; 	+1.211E+210
;	-0.21E-20
;------------------------------------------------------------------------------
;IN:
;	fp0:	float … convertir
;	a6	ptr ASCII	;!!!
;------------------------------------------------------------------------------
	MC68881

FLOAT_TO_SCI::	
	ftst	fp0	

	fmove.l	fpsr,d0

	move	ATTRIBUTE,d1
	move.b	#'+',d1

	btst	#27,d0
	beq.s	.POS		;si negatif => on met un -
	
	move.b	#'-',d1
.POS
	btst	#25,d0
	bne	INFINITE

	btst	#26,d0
	bne	ZERO

	btst	#24,d0
	bne	NAN
	
.GENERAL
	move	d1,(a6)+	;signe

	fabs	fp0,fp0		;log10(x) ne marche que pour x>0
	flog10	fp0,fp1
	fmove.l	fpcr,d0
	and.l	#~%110000,d0
	or.l	#%110000,d0	;round toward plus infinite
	fmove.l	d0,fpcr
	fabs	fp1,fp2
	fint	fp2,fp2
	fmove.l	fp2,d1
	ftst	fp1
	fbge	.OK0
	fneg	fp2,fp2
	neg.l	d1
.OK0	
	ftentox	fp2,fp1		:la magnitude arrondi au dessus...
	fdiv	fp1,fp0

	fmul.s	#1E6,fp0
	fint	fp0
	fdiv.s	#1E6,fp0	;arrondi...


.GO
	fintrz	fp0,fp1
	fmove.l	fp1,d0
	tst.l	d0
	bne.s	.OK1		;un zero en premier est interdit en notation SCI
	subq	#1,d1
	fmul.s	#1E1,fp0	
	bra.s	.GO			
.OK1	
	fsub	fp1,fp0
	add.b	#'0',d0
	fmul.s	#1E1,fp0
	move.b	ATTRIBUTE,(a6)+
	move.b	d0,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	#'.',(a6)+

	move	#6-1,d7	
.LOOP	
	fintrz	fp0,fp1
	fmove.l	fp1,d0
	fsub	fp1,fp0
	add.b	#'0',d0
	fmul.s	#10.0,fp0
	move.b	ATTRIBUTE,(a6)+
	move.b	d0,(a6)+
	dbra	d7,.LOOP


	move.b	ATTRIBUTE,(a6)+
	move.b	#'E',(a6)+
	move.l	d1,d0
	bsr	S_DECI
	rts
	
S_DECI
	move	ATTRIBUTE,d1
	move.b	#'+',d1
	tst.l	d0
	bpl.s	.OK
	move.b	#'-',d1
	neg.l	d0
.OK	
	move	d1,(a6)+
				
	move.l	#1000000000,d2
	moveq	#0,d3	
	move	#10-1,d7
.LOOP	
	divul.l	d2,d1:d0
	tst.l	d0
	bne.s	.AFF
	tst	d7
	beq.S	.AFF
	tst	d3
	beq.s	.NOAFF	
.AFF	st	d3
	add.b	#'0',d0
	move.b	ATTRIBUTE,(a6)+	
	move.b	d0,(a6)+		
.NOAFF	divu.l	#10,d2	
	move.l	d1,d0
	dbra	d7,.LOOP	
	rts
					

NAN	
	move	d1,(a6)+
	cpy	<'Nan'>,a6
	rts	

ZERO	
	move	d1,(a6)+
	cpy	<'0'>,a6
	rts	
		
INFINITE
	move	d1,(a6)+
	cpy	<'oo'>,a6
	rts

	
	
;**************************************
GEN_REG::
	xref	HEXA0_16,HEXA0_8,HEXA0_24,COL_CHG,HEXA0_4
	xref	ATTRIBUTE
	xref	DSP_REG,OLD_DSP_REG
	
	movem.l	d0-a6,-(sp)

	move	#11,max_ligne(a0)
	move	#80,max_col(a0)






	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
	move	COL_NOR,ATTRIBUTE

	ifne	0
	illegal
	*----------------------------*
	* v‚rifications...
	*----------------------------*
	fmove.s	#5E-1,fp0
	fmul.s	#1E1,fp0
	flog10	fp0,fp0	
	bsr	FLOAT_TO_SCI		
	move	#$d,(a6)+	

	fmove.x #$000000000000000000000000,fp0	;+0
	bsr	FLOAT_TO_SCI		
	move	#$d,(a6)+	
	fmove.x #$800000000000000000000000,fp0	;-0
	bsr	FLOAT_TO_SCI		
	move	#$d,(a6)+	

	fmove.x #$7fff00000000000000000000,fp0	;+~~
	bsr	FLOAT_TO_SCI		
	move	#$d,(a6)+	
	fmove.x #$ffff00000000000000000000,fp0	;-~~
	bsr	FLOAT_TO_SCI		
	move	#$d,(a6)+	

	fmove.x #$7fffffffffffffffffffffff,fp0	;+Nan
	bsr	FLOAT_TO_SCI		
	move	#$d,(a6)+	
	fmove.x #$ffffffffffffffffffffffff,fp0	;-Nan
	bsr	FLOAT_TO_SCI		
	move	#$d,(a6)+	

	endc


	lea	DSP_REG+REG_R0,a0
	lea	OLD_DSP_REG+REG_R0,a1
	move.b	#'0',d7
	bsr	PUTRNM
	cpy	<'  SP:'>,a6
	lea	DSP_REG+REG_SP,a0
	lea	OLD_DSP_REG+REG_SP,a1
	bsr	C_HEXA0_16
	cpy.b	<'         '>,a5
	
	move	#$d,(a6)+	;R0:hhhhhh N0:hhhhhh M0:hhhhhh  SP:hhhhhh
	move.b	#$d,(a5)+
	
	lea	DSP_REG+REG_R1,a0
	lea	OLD_DSP_REG+REG_R1,a1
	move.b	#'1',d7
	bsr	PUTRNM
	cpy	<' SSH:'>,a6
	lea	DSP_REG+REG_SSH,a0
	lea	OLD_DSP_REG+REG_SSH,a1
	bsr	C_HEXA0_24
	cpy.b	<'           '>,a5

	cpy	<' SSL:'>,a6
	lea	DSP_REG+REG_SSL,a0
	lea	OLD_DSP_REG+REG_SSL,a1
	bsr	C_HEXA0_24
	cpy.b	<'           '>,a5
	move	#$d,(a6)+	;R1:hhhhhh N1:hhhhhh M1:hhhhhh SSH:hhhhhh SSL:hhhhhh
	move.b	#$d,(a5)+

	lea	DSP_REG+REG_R2,a0
	lea	OLD_DSP_REG+REG_R2,a1
	move.b	#'2',d7
	bsr	PUTRNM
	cpy	<'  LA:'>,a6
	lea	DSP_REG+REG_LA,a0
	lea	OLD_DSP_REG+REG_LA,a1
	bsr	C_HEXA0_24
	cpy.b	<'           '>,a5
	cpy	<'  LC:'>,a6
	lea	DSP_REG+REG_LC,a0
	lea	OLD_DSP_REG+REG_LC,a1
	bsr	C_HEXA0_24
	cpy.b	<'           '>,a5
	move	#$d,(a6)+	;R2:hhhhhh N2:hhhhhh M2:hhhhhh  LA:hhhhhh  LC:hhhhhh
	move.b	#$d,(a5)+

	lea	DSP_REG+REG_R3,a0
	lea	OLD_DSP_REG+REG_R3,a1
	move.b	#'3',d7
	bsr	PUTRNM
	move	#$d,(a6)+	;R3:hhhhhh N3:hhhhhh M3:hhhhhh
	move.b	#$d,(a5)+

	lea	DSP_REG+REG_R4,a0
	lea	OLD_DSP_REG+REG_R4,a1
	move.b	#'4',d7
	bsr	PUTRNM
	cpy	<'   A:'>,a6
	lea	DSP_REG+REG_A2,a0
	lea	OLD_DSP_REG+REG_A2,a1
	bsr	C_HEXA0_8
	cpy	':',a6
	lea	DSP_REG+REG_A1,a0
	lea	OLD_DSP_REG+REG_A1,a1
	bsr	C_HEXA0_24
	cpy	':',a6
	lea	DSP_REG+REG_A0,a0
	lea	OLD_DSP_REG+REG_A0,a1
	bsr	C_HEXA0_24
	cpy.b	<'      HH HHHHHH HHHHHH'>,a5
	move	#$d,(a6)+	;R4:hhhhhh N4:hhhhhh M4:hhhhhh A=hh:hhhhhh:hhhhhh
	move.b	#$d,(a5)+

	lea	DSP_REG+REG_R5,a0
	lea	OLD_DSP_REG+REG_R5,a1
	move.b	#'5',d7
	bsr	PUTRNM
	cpy	<'   B:'>,a6
	lea	DSP_REG+REG_B2,a0
	lea	OLD_DSP_REG+REG_B2,a1
	bsr	C_HEXA0_8
	cpy	':',a6
	lea	DSP_REG+REG_B1,a0
	lea	OLD_DSP_REG+REG_B1,a1
	bsr	C_HEXA0_24
	cpy	':',a6
	lea	DSP_REG+REG_B0,a0
	lea	OLD_DSP_REG+REG_B0,a1
	bsr	C_HEXA0_24
	cpy.b	<'      HH HHHHHH HHHHHH'>,a5
	move	#$d,(a6)+	;R5:hhhhhh N5:hhhhhh M5:hhhhhh B=hh:hhhhhh:hhhhhh
	move.b	#$d,(a5)+

	lea	DSP_REG+REG_R6,a0
	lea	OLD_DSP_REG+REG_R6,a1
	move.b	#'6',d7
	bsr	PUTRNM
	cpy	<'   X:   '>,a6
	lea	DSP_REG+REG_X1,a0
	lea	OLD_DSP_REG+REG_X1,a1
	bsr	C_HEXA0_24
	cpy	':',a6
	lea	DSP_REG+REG_X0,a0
	lea	OLD_DSP_REG+REG_X0,a1
	bsr	C_HEXA0_24
	cpy.b	<'        HHHHHH HHHHHH'>,a5
	move	#$d,(a6)+	;R6:hhhhhh N6:hhhhhh M6:hhhhhh X= hhhhhh:hhhhhh
	move.b	#$d,(a5)+

	lea	DSP_REG+REG_R7,a0
	lea	OLD_DSP_REG+REG_R7,a1
	move.b	#'7',d7
	bsr	PUTRNM
	cpy	<'   Y:   '>,a6
	lea	DSP_REG+REG_Y1,a0
	lea	OLD_DSP_REG+REG_Y1,a1
	bsr	C_HEXA0_24
	cpy	':',a6
	lea	DSP_REG+REG_Y0,a0
	lea	OLD_DSP_REG+REG_Y0,a1
	bsr	C_HEXA0_24
	cpy.b	<'        HHHHHH HHHHHH'>,a5
	move	#$d,(a6)+	;R7:hhhhhh N7:hhhhhh M7:hhhhhh Y= hhhhhh:hhhhhh
	move.b	#$d,(a5)+
	
	cpy	'PC:',a6
	lea	DSP_REG+REG_PC,a0
	lea	OLD_DSP_REG+REG_PC,a1
	bsr	C_HEXA0_24
	cpy.b	<'   HHHHHH'>,a5
	
	
	;bsr	EVAL_MODE

	move	#$d,(a6)+
	move.b	#$d,(a5)+
	
	cpy	'SR:',a6
	lea	DSP_REG+REG_SR,a0
	lea	OLD_DSP_REG+REG_SR,a1
	bsr	C_HEXA0_24

	bsr	PUTCCR
	bsr	PUTEMR

	move	#$d,(a6)+		;SR:hhhhhh CCR:SLEUNZVC
	move.b	#$d,(a5)+


	;move.l	a6,a5
	cpy	'DSP->',a6
	xref	TEMP_BUF
	lea	TEMP_BUF,a0
.LOOP_TEMP	
	move.l	(a0)+,d0
	cmp.l	#'CTK',d0
	beq.s	.OK_TEMP
	bsr	HEXA0_24
	cpy	'->',a6
	bra.S	.LOOP_TEMP
.OK_TEMP
	cpy	'040',a6

	move	#$d,(a6)+		;SR:hhhhhh CCR:SLEUNZVC
	move.b	#$d,(a5)+


	cpy	'040->',a6
	xref	HOST_BUF
	lea	HOST_BUF,a0
.LOOP_HOST
	move.l	(a0)+,d0
	cmp.l	#'CTK',d0
	beq.s	.OK_HOST
	bsr	HEXA0_24
	cpy	'->',a6
	bra.s	.LOOP_HOST
.OK_HOST
	cpy	'DSP',a6



.FIN	move	#$8000,(a6)+
	clr.b	(a5)+
	movem.l	(sp)+,d0-a6
	rts

PUTEMR	move.l	DSP_REG+REG_SR,d0
	move	COL_NOR,ATTRIBUTE
	cpy	<' EMR: CP'>,a6
	bfextu	d0{8:2},d1
	bsr	HEXA0_4		;core priority
	
	move.b	#grisF,ATTRIBUTE
	btst	#21,d0
	beq.s	.OK0
	move	COL_NOR,ATTRIBUTE
.OK0	cpy	<' RM'>,a6	;Rounding Mode



	move.b	#grisF,ATTRIBUTE
	btst	#20,d0
	beq.s	.OK1
	move	COL_NOR,ATTRIBUTE
.OK1	cpy	<' SM'>,a6	;arithemtic Saturation

	move.b	#grisF,ATTRIBUTE
	btst	#19,d0
	beq.s	.OK2
	move	COL_NOR,ATTRIBUTE
.OK2	cpy	<' CE'>,a6	;Cache Enable

	move.b	#grisF,ATTRIBUTE
	btst	#17,d0
	beq.s	.OK3
	move	COL_NOR,ATTRIBUTE
.OK3	cpy	<' SA'>,a6	;16 bi Arithmetic

	move.b	#grisF,ATTRIBUTE
	btst	#16,d0
	beq.s	.OK4
	move	COL_NOR,ATTRIBUTE
.OK4	cpy	<' FV'>,a6	;do forever flag

	move.b	#grisF,ATTRIBUTE
	btst	#15,d0
	beq.s	.OK5
	move	COL_NOR,ATTRIBUTE
.OK5	cpy	<' LV'>,a6	;do loop flag

	move.b	#grisF,ATTRIBUTE
	btst	#14,d0
	beq.s	.OK6
	move	COL_NOR,ATTRIBUTE
.OK6	cpy	<' DM'>,a6	;double precision mode

	move.b	#grisF,ATTRIBUTE
	btst	#13,d0
	beq.s	.OK7
	move	COL_NOR,ATTRIBUTE
.OK7	cpy	<' SC'>,a6	;16 bit compatibility
	
	move	COL_NOR,ATTRIBUTE
	cpy	<' S'>,a6
	move.b	COL_NOR,(a6)+	
	bfextu	d0{20:2},d1
	cmp.b	#0,d1
	beq.s	.DNO
	cmp.b	#1,d1
	beq.s	.DNO0
	move.b	#'',(a6)+
	bra.s	.OK8
.DNO0	move.b	#'',(a6)+
	bra.s	.OK8
.DNO	move.b	#'-',(a6)+

.OK8	move	COL_NOR,ATTRIBUTE
	cpy	<' I'>,a6
	bfextu	d0{22:2},d1
	bsr	HEXA0_4
	rts
PUTCCR
	cpy	<' CCR:'>,a6
	move.l	DSP_REG+REG_SR,d0
	lea	.LISTCCR,a0
	move	#7,d7
.LOOPCCR
	move	COL_NOR,d1
	btst	d7,d0
	bne.s	.S1
	move	#grisF*256,d1
.S1	move.b	(a0)+,d1
	move	d1,(a6)+
	dbra	d7,.LOOPCCR
	rts
	
.LISTCCR	dc.b	'SLEUNZVC'	

PUTRNM	xref	ATTRIBUTE
	move	COL_NOR,ATTRIBUTE
	cpy	<'R0:'>,a6
	move.b	d7,-3(a6)
	bsr	C_HEXA0_24	;r0:hhhhhh
	move.l	#'    ',(a5)+
	subq	#1,a5
	move.l	#'HHHH',(a5)+	
	move	#'HH',(a5)+	
	
	cpy	<' N0:'>,a6	
	move.b	d7,-3(a6)
	bsr	C_HEXA0_24	;n0:hhhhhh
	move.l	#'    ',(a5)+
	move.l	#'HHHH',(a5)+	
	move	#'HH',(a5)+	

	cpy	<' M0:'>,a6	
	move.b	d7,-3(a6)
	bsr	C_HEXA0_24	;m0:hhhhhh
	move.l	#'    ',(a5)+
	move.l	#'HHHH',(a5)+	
	move	#'HH',(a5)+	
	
	rts
	
C_HEXA0_24
	move	COL_NOR,ATTRIBUTE
	move.l	(a0)+,d1
	cmp.l	(a1)+,d1
	beq.s	.SAME0
	move	COL_CHG,ATTRIBUTE
.SAME0	bsr	HEXA0_24	
	move	COL_NOR,ATTRIBUTE
	rts
C_HEXA0_16
	move	COL_NOR,ATTRIBUTE
	move.l	(a0)+,d1
	cmp.l	(a1)+,d1
	beq.s	.SAME0
	move	COL_CHG,ATTRIBUTE
.SAME0	bsr	HEXA0_16	
	move	COL_NOR,ATTRIBUTE
	rts
C_HEXA0_8
	move	COL_NOR,ATTRIBUTE
	move.l	(a0)+,d1
	cmp.l	(a1)+,d1
	beq.s	.SAME0
	move	COL_CHG,ATTRIBUTE
.SAME0	bsr	HEXA0_8
	move	COL_NOR,ATTRIBUTE
	rts

;------------------------------------------------------------------------------
; d‚sassemble l'instrucion en cours
; + ‚valuation des modes d'adressage
;
;------------------------------------------------------------------------------
EVAL_MODE
	xref	DESAS_ONE
	
	move	#' ',(a6)+		;un espace

	lea	WORK_BUF,a1
	envl	#'CMD'
	envl	#DSP_PDUMP
	envl	DSP_REG+REG_PC
	envl	#2			;2 mots … recevoir
	recl	(a1)+
	recl	(a1)+
	move.l	a0,a1
	lea	WORK_BUF,a0
	move.l	DSP_REG+REG_PC,P_COUNT
	move.l	a6,-(sp)
	bsr	DESAS_ONE		;PC:hhhhhh  JMP $40 
	clr	(a6)+		;fin d'instruction
	move.l	(sp)+,a0

	*--------------------*
	* recherche des acces RAM
	* + remplace les tabs
	* par des espaces
	*--------------------*

ONE_MODE
	lea	WORK_BUF,a1
	clr.l	(a1)
.SCAN0	move	(a0)+,d0
	beq	.FINEVAL
	cmp.b	#'	',d0
	beq.s	.TAB
	cmp.b	#'P',d0
	beq.s	.EXPLICITE
	cmp.b	#'X',d0
	beq.s	.EXPLICITE
	cmp.b	#'Y',d0
	beq.s	.EXPLICITE
	cmp.b	#'L',d0
	beq.s	.EXPLICITE
	cmp.b	#'$',d0
	beq.s	.IMPLICITE
	bra.S	.SCAN0
.TAB	
	move.b	#' ',-1(a0)
	bra.s	.SCAN0
.IMPLICITE
	cmp.b	#'#',-1(a0)
	beq.s	.SCAN0
	move	#'P:',(a1)+		;les acces en P implicites
	move	#'{$',(a1)+
.COP0	move	(a0)+,d0
	beq	.FINCOP0
	cmp.b	#' ',d0
	beq	.FINCOP0
	cmp.b	#'	',d0
	beq	.FINCOP0
	cmp.b	#',',d0
	beq	.FINCOP0
	move.b	d0,(a1)+
	bra.s	.COP0
.FINCOP0
	move	#'}'*256,(a1)+
	bra.S	.GOEVAL	
	
.EXPLICITE
	cmp.b	#':',1(a0)
	bne.s	.SCAN0
	move.b	d0,(a1)+
	move	(a0)+,d0
	move.b	d0,(a1)+		;P:, X:, Y:
	
	moveq	#0,d1
	move	(a0)+,d0
	cmp.b	#'-',d0
	bne.s	.NOPRED
	moveq	#1,d1
	addq	#2,a0
.NOPRED	
	move.b	#'{',(a1)+		;skippe la '(' 
.COP1	move	(a0)+,d0
	beq.s	.FINCOP1
	cmp.b	#')',d0
	beq.s	.FINCOP1
	move.b	d0,(a1)+		
	bra.S	.COP1
.FINCOP1
	tst	d1
	beq.S	.NOPRED1
	move	#'-1',(a1)+
.NOPRED1
	move	#'}'*256,(a1)+


.GOEVAL
	move.l	a0,-(sp)		;sauve ptr string instruction
	
	lea	WORK_BUF,a0
	tst.b	(a0)
	beq.s	.NEXT_EVAL
	lea	WORK_BUF+512,a1
.SCAN1	
	move.b	(a0)+,d0
	cmp.b	#'{',d0
	beq.s	.IND
	cmp.b	#'$',d0
	beq.s	.IND
	bra.S	.SCAN1	
.IND	move.b	(a0)+,d0
	beq.s	.OKADR
	cmp.b	#'}',d0
	beq.s	.OKADR
	move.b	d0,(a1)+	
	bra.s	.IND
	*--------------------*
	* ‚value l'adresse
	*--------------------*
.OKADR
	clr.b	(a1)+
	move	ATTRIBUTE,d0
	move.b	WORK_BUF,d0
	move	d0,(a6)+
	move.b	#':',d0
	move	d0,(a6)+

	lea	WORK_BUF+512,a0
	xref	eval	
	bsr.l	eval	
	xref	HEXA_24
	bsr	HEXA_24
	move.b	ATTRIBUTE,(a6)+
	move.b	#'=',(a6)+
	lea	WORK_BUF,a0
	bsr.l	eval
	xref	HEXA0_24
	bsr	HEXA0_24
	move	#' ',(a6)+

.NEXT_EVAL
	move.l	(sp)+,a0
	tst	-2(a0)
	bne	ONE_MODE
.FINEVAL
	move	#' ',-2(a0)
.FIN
	rts
	



;********************************************************************
; Voici les routines de g‚n‚ration de texte
;elles remplissent le buffer ASCII
;********************************************************************
GEN_DIVERS::
	movem.l	d0-a6,-(sp)
	move.l	adr_debut(a0),a1
	lea	ASCII_BUF,a6

.LOOP	move	(a1)+,d0
	bmi.s	.FIN
	move	d0,(a6)+
	bra.s	.LOOP
	
	

.FIN	
	move	d0,(a6)+
	movem.l	(sp)+,d0-a6
	rts
	



GEN_DISAS::	xref	DESAS
	movem.l	d0-a6,-(sp)
.AGAIN	
	xref	WORK_BUF,ASCII_BUF,P_COUNT
	lea	WORK_BUF,a6
	envl	#'CMD'
	envl	#DSP_PDUMP
	move.l	adr_debut(a0),d0
	envl	d0
	move.l	d0,(a6)+	;ADR DBUT

	move	Hauteur(a0),d0
	subq	#2,d0
	move	d0,(a6)+	;NB de lignes … desassembler
	add	d0,d0		;2*nb_instr mots … recevoir
	ext.l	d0
	envl	d0
	subq	#1,d0
.LOOP	recl	(a6)+
	dbra	d0,.LOOP	
	lea	ASCII_BUF,a6

	move.l	a0,-(sp)
	lea	WORK_BUF,a0
	move.l	a0,a1
	bsr	DESAS	
	move.l	a1,a0
	move.l	(sp)+,a0
	move.l	P_COUNT,adr_fin(a0)
.OK	movem.l	(sp)+,d0-a6
	rts
;**************************************
;**************************************
GEN_H24::	
	xref	COL_NOR,COL_ADR,MASK_BUF
	movem.l	d0-a6,-(sp)
	envl	#'CMD'
	move	mem_type(a0),d0
	cmp.w	#MEM_P,d0
	beq.s	.MP
	cmp.w	#MEM_X,d0
	beq.s	.MX
	cmp.w	#MEM_Y,d0
	beq.s	.MY
	bra	.FIN	
.MP	envl	#DSP_PDUMP
	bra	.SEND_OK
.MX	envl	#DSP_XDUMP
	bra	.SEND_OK
.MY	envl	#DSP_YDUMP
.SEND_OK
;*** calcul du nombre de colonnes
	envl	adr_debut(a0)
	moveq	#0,d6
	move	Largeur(a0),d6
	subq	#2+6,d6		;-2(bords) -6(adresse)
	bpl.s	.POS
	moveq	#0,d6
.POS	
	divu	#7,d6		;nb colonnes	_hhhhhh
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#2,d7		;-2(titre+bottom)
	ext.l	d7
	move	d7,d5
	mulu	d6,d5		;nb_word = nb_ligne*nb_colonnes
	envl	d5
	subq	#1,d7
	move.l	adr_debut(a0),d0
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5

.LOOP	move	COL_ADR,ATTRIBUTE
	move.l	d0,d1
	bsr	HEXA0_24
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move	#'  ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi.S	.GARG		;en th‚orie ca se peut pas, mais on assure
.LOOPVAL	
	recl	d1
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	bsr	HEXA0_24
	move.l	#'HHHH',(a5)+
	move	#'HH',(a5)+
	dbra	d5,.LOOPVAL
.GARG	move.b	#$d,(a5)+
	move	#$d,(a6)+
	moveq	#0,d1
	move	nb_colonnes(a0),d1
	add.l	d1,d0
	dbra	d7,.LOOP	
	move	#$8000,(a6)+
	clr.b	(a5)+
	move.l	d0,adr_fin(a0)
.FIN	movem.l	(sp)+,d0-a6
	rts
;****************************************


;****************************************
GEN_H48::	
	xref	COL_NOR,COL_ADR
	movem.l	d0-a6,-(sp)
	envl	#'CMD'
	move	mem_type(a0),d0
	;cmp.w	#'L',d0
	;bne	.FIN		;L oblig‚
	envl	#DSP_LDUMP
;*** calcul du nombre de colonnes
	envl	adr_debut(a0)
	moveq	#0,d6
	move	Largeur(a0),d6
	subq	#2+6,d6		;-2(bords) -6(adresse)
	bpl.s	.POS
	moveq	#0,d6
.POS	divu	#14,d6		;nb colonnes	_hhhhhh.hhhhhh
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#2,d7		;-2(titre+bottom)
	ext.l	d7
	move	d7,d5
	mulu	d6,d5		;nb_word = nb_ligne*nb_colonnes
	envl	d5
	subq	#1,d7
	move.l	adr_debut(a0),d0
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5

.LOOP	
	move	COL_ADR,ATTRIBUTE
	move.l	d0,d1
	bsr	HEXA0_24
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move	#'  ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi.S	.GARG		;en th‚orie ca se peut pas, mais on assure
.LOOPVAL	
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	recl	d1
	bsr	HEXA0_24
	move.l	#'HHHH',(a5)+
	move	#'HH',(a5)+
	move.b	#' ',(a5)+
	move.b	ATTRIBUTE,(a6)+
	move.b	#'.',(a6)+
	recl	d1
	bsr	HEXA0_24
	move.l	#'HHHH',(a5)+
	move	#'HH',(a5)+
	dbra	d5,.LOOPVAL
.GARG	move.b	#$d,(a5)+
	move	#$d,(a6)+
	moveq	#0,d1
	move	nb_colonnes(a0),d1
	add.l	d1,d0
	dbra	d7,.LOOP	
	move	#$8000,(a6)+
	clr.b	(a5)+
	move.l	d0,adr_fin(a0)
.FIN	movem.l	(sp)+,d0-a6
	rts
;**************************************
GEN_FRAC24::	
	xref	COL_NOR,COL_ADR
	xref	FRAC_24
	movem.l	d0-a6,-(sp)
	envl	#'CMD'
	move	mem_type(a0),d0
	cmp.w	#MEM_P,d0
	beq.s	.MP
	cmp.w	#MEM_X,d0
	beq.s	.MX
	cmp.w	#MEM_Y,d0
	beq.s	.MY
	bra	.FIN	
.MP	envl	#DSP_PDUMP
	bra	.SEND_OK
.MX	envl	#DSP_XDUMP
	bra	.SEND_OK
.MY	envl	#DSP_YDUMP
.SEND_OK
;*** calcul du nombre de colonnes
	envl	adr_debut(a0)
	moveq	#0,d6
	move	Largeur(a0),d6
	subq	#2+6,d6		;-2(bords) -6(adresse)
	bpl.s	.POS
	moveq	#0,d6
.POS	divu	#14,d6		;nb colonnes 	_+0.0000000E+0	
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#2,d7		;-2(titre+bottom)
	ext.l	d7
	move	d7,d5
	mulu	d6,d5		;nb_word = nb_ligne*nb_colonnes
	envl	d5
	subq	#1,d7
	move.l	adr_debut(a0),d0
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5

.LOOP	
	move	COL_ADR,ATTRIBUTE
	move.l	d0,d1
	bsr	HEXA0_24
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move	#'  ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi.S	.GARG		;en th‚orie ca se peut pas, mais on assure
.LOOPVAL	
	recl	d1
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	bsr	FRAC_24		;met … jour a5 et a6
	dbra	d5,.LOOPVAL
.GARG	move.b	#$d,(a5)+
	move	#$d,(a6)+
	moveq	#0,d1
	move	nb_colonnes(a0),d1
	add.l	d1,d0
	dbra	d7,.LOOP	
	move	#$8000,(a6)+
	clr.b	(a5)+
	move.l	d0,adr_fin(a0)
.FIN	movem.l	(sp)+,d0-a6
	rts
;****************************************
GEN_HEXASCII24::	xref	COL_NOR,COL_ADR,ATTRIBUTE
			xref	HEXA0_24
	movem.l	d0-a6,-(sp)
	envl	#'CMD'
	move	mem_type(a0),d0
	cmp.w	#MEM_P,d0
	beq.s	.MP
	cmp.w	#MEM_X,d0
	beq.s	.MX
	cmp.w	#MEM_Y,d0
	beq.s	.MY
	bra	.FIN	
.MP	envl	#DSP_PDUMP
	bra	.SEND_OK
.MX	envl	#DSP_XDUMP
	bra	.SEND_OK
.MY	envl	#DSP_YDUMP
.SEND_OK
;*** calcul du nombre de colonnes
	envl	adr_debut(a0)
	moveq	#0,d6
	move	Largeur(a0),d6
	sub	#2+6,d6	;-2(bords) -6(adresse)
	bpl.s	.POS
	moveq	#0,d6
.POS	divu	#11,d6		;nb colonnes	_hhhhhh AAA
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#2,d7		;-2(titre+bottom)
	ext.l	d7
	move	d7,d5
	mulu	d6,d5		;nb_word = nb_ligne*nb_colonnes
	envl	d5
	subq	#1,d7
	move.l	adr_debut(a0),d0
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
.LOOP	move	COL_ADR,ATTRIBUTE
	move.l	d0,d1
	bsr	HEXA0_24
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move	#'  ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi.S	.GARG		;en th‚orie ca se peut pas, mais on assure
	move	nb_colonnes(a0),d1
	mulu	#7,d1
	lea	(a5,d1.w),a3
	lea	(a6,d1.w*2),a4
.LOOPVAL	
	recl	d1
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	bsr	HEXA0_24
	move.l	#'HHHH',(a5)+
	move	#'HH',(a5)+
	move.l	#' AAA',(a3)+
	move	#' ',(a4)+
	bset	#5,ATTRIBUTE	;affiche binaire
	swap	d1
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	rol.l	#8,d1	
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	rol.l	#8,d1	
	move.b	ATTRIBUTE,(a4)+
	move.b	d1,(a4)+
	bclr	#5,ATTRIBUTE	;affiche normal
	dbra	d5,.LOOPVAL
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
;****************************************
;****************************************


GEN_SS::
	ifne	0
	xref	HEXA0_5,HEXA0_16,COL_NOR,COL_ADR
	movem.l	a0/a6/d1/d6/d7,-(sp)
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
	lea	DSP_REG+REG_SS,a0
	move.l	DSP_REG+REG_SP,d7
	move	#0,d6
.LOOP	
	move	COL_ADR,ATTRIBUTE
	move	d6,d1
	bsr	HEXA0_5
	move.l	#'    ',(a5)+
	move	#'  ',(a5)+
	move	COL_NOR,ATTRIBUTE

	*-----------------------*
	* pace un p'tit signe pour pointer la pile
	*-----------------------*
	move	ATTRIBUTE,d3
	move.b	#' ',d3	
	cmp	d7,d6
	bne.s	.OK
	move.b	#'>',d3	
.OK	move	d3,(a6)+
	move.b	#' ',(a5)+

	move.l	(a0)+,d1
	bsr	HEXA0_24
	move.b	ATTRIBUTE,(a6)+
	move.b	#':',(a6)+
	move.l	(a0)+,d1
	bsr	HEXA0_24
	move.l	#'HHHH',(a5)+
	move.l	#'HH:H',(a5)+
	move.l	#'HHHH',(a5)+
	move.b	#'H',(a5)+
	move.b	#$d,(a5)+
	move	#$d,(a6)+
	addq	#1,d6
	cmp	#$e,d6
	ble.S	.LOOP
	
	clr.b	(a5)+
	move	#$8000,(a6)+
	movem.l	(sp)+,a0/a6/d1/d6/d7
	endc
	rts


	
	
;------------------------------------------------------------------------------
; place no ligne pares line: dans le nom du source
;------------------------------------------------------------------------------
UPDATE_COL
	move.l	Src_adr(a0),a1
	move.l	ptr_name(a1),a1	
.SCAN	tst.b	(a1)+
	bne.s	.SCAN

.SCAN1
	cmp.l	#'ne: ',(a1)
	beq.S	.OK1
	subq	#1,a1
	bra.s	.SCAN1
	
.OK1
	addq	#4,a1
	moveq	#0,d0	
	move	Line_nb(a0),d0
	
	move	#5-1,d2
	moveq	#0,d3
	move.l	#10000,d4
.LOOP	
	divu	d4,d0
	bne.s	.OK		;on a zero ?
	tst	d2
	beq.s	.OK		;dernier char obligatoire
.IGNORE
	tst	d3
	beq.s	.OK0		;premier char … 0 => ignor‚
.OK	add.b	#'0',d0
	move.b	d0,(a1)+
	st	d3
.OK0	swap	d0
	ext.l	d0
	divu	#10,d4
	dbra	d2,.LOOP
	
	clr.b	(a1)+
	rts
			
	
;------------------------------------------------------------------------------
; genere le type de fenetre DSP-source
; attention, je ne gere pas le mask buf
;------------------------------------------------------------------------------
GEN_DSP_SRC::	
	
;affiche en ASCII cr,lf et 0 font mise … la ligne
	xref	COL_NOR,COL_ADR
	movem.l	d0-a6,-(sp)

	bsr	UPDATE_COL

	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.l	ligne_ptr(a1),a1
	
	
	move	Line_nb(a0),d0
	lea.l	(a1,d0.w*4),a2		;adr_debut
	lea	(a3,d0.w*4),a3
	lea	ASCII_BUF,a6
	move	COL_NOR,d0
	move	Hauteur(a0),d7
	subq	#3,d7
	bmi.s	.OUT
.LOOP	
	move.l	a6,a5
	move	COL_NOR,d0
	move	d0,ATTRIBUTE
	move.b	#' ',d0
	rept	5
	move	d0,(a5)+
	endr
	move.b	#'Ÿ',d0		
	move	d0,(a5)+		;5 espaces+ barre verticale

	move.l	(a3)+,d0
	move.l	d0,P_COUNT
	tst.l	d0
	;beq.s	.NOPC			;!!!!!!!!!!!!!!!!!
	
	
	move.l	P_COUNT,d1
	xref	MEM_BANK
	move	#'P:',MEM_BANK		
	
	xref	FIND_BKP
	bsr	FIND_BKP

	tst	d2
	bne.s	.FO
	addq	#8,a6

.FO	
	xref	FORME_CURSEUR
	bsr	FORME_CURSEUR		;la p'tite fleche

.NOPC	
	move.l	a5,a6
	move	ATTRIBUTE,d0
	
	moveq	#0,d6
	move.l	(a2)+,a1
.XLOOP	
	move.b	(a1)+,d0
	beq.s	.OUT
	cmp.b	#9,d0
	beq.s	.TAB
	cmp.b	#$d,d0
	beq.s	.CR
	cmp.b	#$a,d0
	beq.s	.CR
	move	d0,(a6)+
	addq	#1,d6
	bra.s	.XLOOP
.CR	move	#$d,(a6)+
.ENY	dbra	d7,.LOOP
.OUT	move	#$8000,(a6)+
.	move.l	a1,adr_fin(a0)
	movem.l	(sp)+,d0-a6
	rts

.TAB	
	xref	TAB_VALUE
	
	move	d6,d5
	ext.l	d5
	;divu	TAB_VALUE,d5
	divu	Tab_Value(a0),d5
	swap	d5
	;move	TAB_VALUE,d4
	move	Tab_Value(a0),d4
	sub	d5,d4
	move	d4,d5
	move.b	#' ',d0
	subq	#1,d5
	bmi.s	.ZERO
.COP	move	d0,(a6)+
	addq	#1,d6
	dbra	d5,.COP
	bra.s	.XLOOP
.ZERO	moveq	#7,d5
	bra.S	.COP

;------------------------------------------------------------------------------
; genere le type de fenetre 040-source
; attention, je ne gere pas le mask buf
;------------------------------------------------------------------------------
GEN_M40_SRC::	
;affiche en ASCII cr,lf et 0 font mise … la ligne
	xref	COL_NOR,COL_ADR
	xref	buffer_r
	
	movem.l	d0-a6,-(sp)

	bsr	UPDATE_COL

	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.l	ligne_ptr(a1),a1
	
	
.ll
	move	Line_nb(a0),d0
.d
	
	lea.l	(a1,d0.w*4),a2		;adr_debut
	lea	(a3,d0.w*4),a3

	


	lea	ASCII_BUF,a6
	move	COL_NOR,d0
	move	Hauteur(a0),d7
	subq	#3,d7
	bmi	.OUT
.LOOP	

	move.l	(a3),d0		;on r‚cupere le PC ds la table conv
	
	cmp.l	#-1,d0
	beq.s	.d1
	move	COL_NOR,ATTRIBUTE
.d1
	move.w	COL_PC,d1
	cmp.w	ATTRIBUTE,d1
	bne.s	.nm
	xref	COL_LAB
	move.w	COL_LAB,ATTRIBUTE
.nm


	
	*--- routine qui va afficher les bkpt
	
	
	xref	is_break,bkpt
	move.l	d0,a4
	
	bsr.l	is_break
	tst.w	bkpt
	beq	.p_bkpt
	
	
	xref	ATTRIBUTE,COL_BKPT
	move	COL_BKPT,ATTRIBUTE
	move	ATTRIBUTE,(a6)
	
	move.w	2(a1),d1
	btst	#1,d1
	bne.s	.p_per
	or	#'[',(a6)+
	bra.s	.per
.p_per
	or	#'<',(a6)+
.per
	moveq	#0,d0
	move.w	bkpt,d0
	and.l	#$ff,d0
	xref	nombre,affiche_nombre_2
	bsr.l	affiche_nombre_2
	lea	nombre,a5
;.p_z
	
	clr.w	d1
	move.b	(a5)+,d1
	move	ATTRIBUTE,(a6)
	or	d1,(a6)+
	move.b	(a5)+,d1
	move	ATTRIBUTE,(a6)
	or	d1,(a6)+
	
	
	move	ATTRIBUTE,(a6)
	move.w	2(a1),d1
	btst	#1,d1
	bne.s	.p_per1
	or	#']',(a6)+
	bra.s	.per1
.p_per1
	or	#'>',(a6)+
.per1
	move.w	ATTRIBUTE,(a6)+
	move.b	#' ',-1(a6)
	move.w	COL_NOR,ATTRIBUTE
	
	bra.s	.bkpt
.p_bkpt
	cpy	<'     '>,a6

.bkpt

	*--- routine qui va afficher le pc

	move.l	(a3)+,d0		;on r‚cupere le PC ds la table conv
	
	cmp.l	buffer_r+r_pc,d0
	bne.s	.BLANC
	
	
	xref	forme_bra,forme_curseur
	bsr.l	forme_bra



	move.w	ATTRIBUTE,d0
	or.b	forme_curseur,d0
	move.w	d0,(a6)+
	move.w	ATTRIBUTE,d4
	move.w	COL_NOR,ATTRIBUTE
	cpy	<'Ÿ'>,a6		;on met un tite fleche
	move.w	d4,ATTRIBUTE
	
	xref	COL_PC
	move.w	COL_PC,ATTRIBUTE
	
	bra.S	.suite

.BLANC	
	move.w	ATTRIBUTE,d4
	move.w	COL_NOR,ATTRIBUTE
	cpy	<' Ÿ'>,a6		;sinon du blanc
	move.w	d4,ATTRIBUTE

.suite	
	
	move	ATTRIBUTE,d0
	
	moveq	#0,d6
	move.l	(a2)+,a1
	xref	buffer_int
	move.l	a1,buffer_int+r_i0
.XLOOP	
	move.b	(a1)+,d0
	beq.s	.OUT
	cmp.b	#9,d0
	beq.s	.TAB
	cmp.b	#$d,d0
	beq.s	.CR
	cmp.b	#$a,d0
	beq.s	.CR
	move	d0,(a6)+
	addq	#1,d6
	bra.s	.XLOOP
.CR	move	#$d,(a6)+
.ENY	dbra	d7,.LOOP
.OUT	move	#$8000,(a6)+
.	move.l	a1,adr_fin(a0)
	movem.l	(sp)+,d0-a6
	rts

.TAB	
	xref	TAB_VALUE
	
	move	d6,d5
	ext.l	d5
	;divu	TAB_VALUE,d5
	divu	Tab_Value(a0),d5
	swap	d5
	;move	TAB_VALUE,d4
	move	Tab_Value(a0),d4
	sub	d5,d4
	move	d4,d5
	move.b	#' ',d0
	subq	#1,d5
	bmi.s	.ZERO
.COP	move	d0,(a6)+
	addq	#1,d6
	dbra	d5,.COP
	bra.s	.XLOOP
.ZERO	moveq	#7,d5
	bra.S	.COP



;**************************************
;**************************************
;*** LES ROUTINES INVERSES !!!!!   ****
;**************************************
;**************************************

;------------------------------------------------------------------------------
GEN_H24_INV::	
	movem.l	d0-a6,-(sp)
	lea	ASCII_BUF,a6
	envl	#'CMD'
	move	mem_type(a0),d0
	cmp.w	#MEM_P,d0
	beq.s	.MP
	cmp.w	#MEM_X,d0
	beq.s	.MX
	cmp.w	#MEM_Y,d0
	beq.s	.MY
	bra	.FIN	
.MP	envl	#DSP_P2DSP
	bra	.SEND_OK
.MX	envl	#DSP_X2DSP
	bra	.SEND_OK
.MY	envl	#DSP_Y2DSP
.SEND_OK
	move.l	adr_debut(a0),d0
	envl	d0		;ADR_DEBUT

	move	Hauteur(a0),d7
	subq	#2,d7
	ext.l	d7
	move	d7,d6
	mulu	nb_colonnes(a0),d6
	envl	d6
	subq	#1,d7
.LOOP	add	#6*2,a6	;adresse
	move	nb_colonnes(a0),d5
	subq	#1,d5	;;
.COLONNE
	addq	#2,a6	;espace	
	moveq	#0,d1
	move	#6-1,d6
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
	envl	d1
	dbra	d5,.COLONNE	
.SC	cmp	#$d,(a6)+
	bne.s	.SC
	dbra	d7,.LOOP	
.FIN	
	movem.l	(sp)+,d0-a6
	rts
;------------------------------------------------------------------------------
GEN_H48_INV::	
	
	xref	key_valid,MODE_EDIT
	movem.l	d0-a6,-(sp)
	tst	key_valid
	beq	.FIN
	lea	ASCII_BUF,a6
	envl	#'CMD'
	envl	#DSP_L2DSP
	move.l	adr_debut(a0),d0
	envl	d0		;ADR_DEBUT

	move	Hauteur(a0),d7
	subq	#2,d7
	ext.l	d7
	move	d7,d6
	mulu	nb_colonnes(a0),d6
	envl	d6
	subq	#1,d7
.LOOP	add	#6*2,a6	;adresse
	move	nb_colonnes(a0),d5
	add	d5,d5
	subq	#1,d5	;;
.COLONNE
	addq	#2,a6	;espace	
	moveq	#0,d1
	move	#6-1,d6
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
	envl	d1
	dbra	d5,.COLONNE	
.SC	cmp	#$d,(a6)+
	bne.s	.SC
	dbra	d7,.LOOP	
.FIN	
	movem.l	(sp)+,d0-a6
	rts
;------------------------------------------------------------------------------
GEN_HEXASCII24_INV::	
;transfert de la fenetre => RAM
;et recalcul de POSX POSY si le mode_edite … chang‚ ( HEXA => ASCII ou l'inverse )
	movem.l	d0-a6,-(sp)
	tst	key_valid	
	beq	.FIN		;y a t il eu saisie ?
	
	envl	#'CMD'
	move	mem_type(a0),d0
	cmp.w	#MEM_P,d0
	beq.s	.MP
	cmp.w	#MEM_X,d0
	beq.s	.MX
	cmp.w	#MEM_Y,d0
	beq.s	.MY
	bra	.FIN	
.MP	envl	#DSP_P2DSP
	bra	.SEND_OK
.MX	envl	#DSP_X2DSP
	bra	.SEND_OK
.MY	envl	#DSP_Y2DSP
.SEND_OK
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5
	move.l	adr_debut(a0),d0
	envl	d0		;ADR_DEBUT

	move	Hauteur(a0),d7
	subq	#2,d7
	ext.l	d7
	move	d7,d6
	mulu	nb_colonnes(a0),d6
	envl	d6
	subq	#1,d7
	cmp.b	#'A',MODE_EDIT
	beq	.ASCC
.LOOP	add	#6*2,a6	;adresse
	move	nb_colonnes(a0),d5
	subq	#1,d5	;
.COLONNE
	addq	#2,a6	;'_'	
	moveq	#0,d1
	move	#6-1,d6
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
	envl	d1
	dbra	d5,.COLONNE	
.SC	cmp	#$d,(a6)+
	bne.s	.SC
	dbra	d7,.LOOP	
	bra	.FIN
.ASCC	move	nb_colonnes(a0),d0
	mulu	#7*2,d0
	add	d0,a6
	add	#12,a6
	move	nb_colonnes(a0),d5
	subq	#1,d5	;
.COLONNE2
	addq	#2,a6	;'_'
	move.b	1(a6),d1
	lsl.l	#8,d1
	move.b	3(a6),d1
	lsl.l	#8,d1
	move.b	5(a6),d1
	addq	#6,a6
	envl	d1
	dbra	d5,.COLONNE2
.SC2	cmp	#$d,(a6)+
	bne.s	.SC2
	dbra	d7,.ASCC		

.FIN	

.END	movem.l	(sp)+,d0-a6
	rts
;------------------------------------------------------------------------------
GEN_FRAC24_INV::	
	rts
;------------------------------------------------------------------------------
GEN_REG_INV::	
	movem.l	d0-a6,-(sp)
	lea	ASCII_BUF,a6

	move	Hauteur(a0),d7
	subq	#2,d7
	cmp	#8,d7
	ble	.OK00
	move	#8,d7
.OK00	subq	#1,d7
	lea	DSP_REG+REG_R0,a1
.LOOP	add	#6,a6
	bsr	.A2REG	
	add	#8,a6
	bsr	.A2REG	
	add	#8,a6
	bsr	.A2REG	
.CR	cmp	#$d,(a6)+
	bne.s	.CR
	dbra	d7,.LOOP	
.FIN	
	movem.l	(sp)+,d0-a6
	rts
.A2REG
	moveq	#0,d1
	move	#6-1,d6
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
	move.l	d1,(a1)+
	rts
			
	

	ifne	0
	;cette roitine est chez steph maintenant
;------------------------------------------------------------------------------
GEN_H16
	xref	COL_NOR,COL_ADR,ATTRIBUTE,HEXA0_32,HEXA0_16,HEXA0_8
	movem.l	d0-a6,-(sp)
;*** calcul du nombre de colonnes
	move.l	adr_debut(a0),a1
	moveq	#0,d6
	move	Largeur(a0),d6
	sub	#2+8+1,d6		;-2(bords) -8(adresse)-1(space)
	bpl.s	.POS
	moveq	#0,d6
.POS	divu	#5,d6			;nb colonnes	_hhhh
	move	d6,nb_colonnes(a0)
	move	Hauteur(a0),d7
	subq	#3,d7			;-2(titre+bottom)
	lea	ASCII_BUF,a6
	lea	MASK_BUF,a5

.LOOP	move	COL_ADR,ATTRIBUTE
	move.l	a1,d1
	bsr	HEXA0_32
	move	COL_NOR,ATTRIBUTE
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move	d6,d5
	subq	#1,d5
	bmi.S	.GARG		;"en th‚orie" ca se peut pas, mais on assure
	move	a1,d0
	btst	#0,d0
	bne.s	.IMPAIRE
.LOOPVAL	
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	move	(a1)+,d1
	bsr	HEXA0_16
	move.l	#'HHHH',(a5)+
	dbra	d5,.LOOPVAL
.GARG	move.b	#' ',(a5)+
	move.b	#$d,(a5)+
	move	#' ',(a6)+
	move	#$d,(a6)+
	add	nb_colonnes(a0),d0
	dbra	d7,.LOOP	
	move	#$8000,(a6)+
	clr.b	(a5)+
	move.l	a1,adr_fin(a0)
.FIN	movem.l	(sp)+,d0-a6
	rts
.IMPAIRE
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	move.b	(a1)+,d1
	bsr	HEXA0_8
	move	#'HH',(a5)+
	subq	#1,d5
	bmi.s	.COMP
.LOOPVAL2
	move	#' ',(a6)+
	move.b	#' ',(a5)+
	move	(a1)+,d1
	bsr	HEXA0_16
	move.l	#'HHHH',(a5)+
	dbra	d5,.LOOPVAL2
.COMP	move	#' ',(a6)+
	move.b	#' ',(a5)+
	move.b	(a1)+,d1
	bsr	HEXA0_8
	move	#'HH',(a5)+
	bra.s	.GARG
;------------------------------------------------------------------------------
GEN_H16_INV
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
	move	#4-1,d6
	bsr	CONV_A2H
	move	d1,(a1)+
	dbra	d5,.COLONNE	
.SC	cmp	#$d,(a6)+
	bne.s	.SC
	dbra	d7,.LOOP	
.FIN	
	movem.l	(sp)+,d0-a6
	rts
.IMPAIRE	
	addq	#2,a6	;espace	
	move	#2-1,d6
	bsr	CONV_A2H
	move.b	d1,(a1)+
	subq	#1,d5
	bmi.s	.SC0
.COLONNE2	
	addq	#2,a6	;espace	
	move	#4-1,d6
	bsr	CONV_A2H
	move.w	d1,(a1)+
	dbra	d5,.COLONNE2	
.SC0	addq	#2,a6	;espace	
	move	#2-1,d6
	bsr	CONV_A2H
	move.b	d1,(a1)+
	bra.s	.SC
	endc
;------------------------------------------------------------------------------


CONV_A2H::
;a6=ascii
;d6=nb de digits
	moveq	#0,d1
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
	rts	
;------------------------------------------------------------------------------




;**************************************
;**************************************
