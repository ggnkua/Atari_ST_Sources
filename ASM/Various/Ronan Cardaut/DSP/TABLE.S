EFF_SP	macro
.MMG\@	cmp.b	#' ',-1(a6)
	bne.s	.MGG\@
	subq	#2,a6
	bra.s	.MMG\@
.MGG\@	
	endm
	TEXT
	
;de maniere g‚n‚rale:
;d7 sert … identifier la colonne de la table par un code ASCCII
;d1 identifie la ligne
;**************************************
TABLE_A15::
SINGLE
	cmp.b	#'d',d7
	beq	.D
	cmp.b	#'e',d7
	beq	.E
	cmp.b	#'f',d7
	beq	.F
	rts
.SUITE	col_cpy	a2,a6
	;move	(a2,d1.w*2),(a6)+	;;
	EFF_SP
	rts
.D	lea	(.TABD,d1.w*4),a2
	bra.s	.SUITE
.E	lea	(.TABE,d1.w*4),a2
	bra.s	.SUITE
.F	lea	(.TABF,d1.w*4),a2
	bra.s	.SUITE
.TABD	dc.b	'A',0,0,0,'B',0,0,0
.TABE	dc.b	'X0',0,0,'X1',0,0
.TABF	dc.b	'Y0',0,0,'Y1',0,0
;**************************************

TABLE_A15_II
SINGLE_II
	cmp.b	#'X',d7
	beq.s	.X
	cmp.b	#'Y',d7
	beq	.Y
	rts
.X	tst	d1
	bne.s	.XUN
	cpy	<'A,'>,a6
	move	#'X:',MEM_BANK
	move	d2,d1
	bsr	EA
	cpy	<'	X0,A'>,a6
	rts	
.XUN	cpy	<'B,'>,a6
	move	#'X:',MEM_BANK
	move	d2,d1
	bsr	EA
	cpy	<'	X0,B'>,a6
	rts	
.Y	tst	d1
	bne.s	.YUN
	cpy	<'Y0,A	A,'>,a6
	move	#'Y:',MEM_BANK
	move	d2,d1
	bsr	EA	
	rts
.YUN	cpy	<'Y0,B	B,'>,a6
	move	#'Y:',MEM_BANK
	move	d2,d1
	bsr	EA	
	rts
;**************************************
	xdef	TABLE_A17
TABLE_A17
DOUBLE
	cmp.b	#'D',d7
	beq.s	.D
	cmp.b	#'e',d7
	beq.s	.E
	cmp.b	#'f',d7
	beq.s	.F
	rts
.SUITE	col_cpy	a2,a6
	EFF_SP
	rts
.D	lea	(.TABD,d1.w*4),a2
	bra.s	.SUITE	
.E	lea	(.TABE,d1.w*4),a2
	bra.s	.SUITE	
.F	lea	(.TABF,d1.w*4),a2
	bra.s	.SUITE	
.TABD	dc.b	'X0',0,0,'X1',0,0,'Y0',0,0,'Y1',0,0
.TABE	dc.b	'X0',0,0,'X1',0,0,'A',0,0,0,'A',0,0,0
.TABF	dc.b	'Y0',0,0,'Y1',0,0,'A',0,0,0,'A',0,0,0
;**************************************
	xdef	TABLE_A18
TABLE_A18
TRIPLE
	cmp.b	#'D',d7
	beq	.D
	cmp.b	#'L',d7
	beq	.LL
	cmp.b	#'F',d7
	beq	.F
	cmp.b	#'N',d7
	beq	.N
	cmp.b	#'T',d7
	beq	.T
	cmp.b	#'G',d7
	beq	.G
	cmp.b	#'E',d7
	beq	.E
	rts
.SUITE	lea	(a2,d1.w*4),a2
	;move.l	(a2,d1.w*4),(a6)+
	col_cpy	a2,a6
	EFF_SP
	rts
.E	lea	.TABE,a2
	bra.s	.SUITE
.D	lea	.TABD,a2
	bra.s	.SUITE
.LL	lea	.TABL,a2
	bra.s	.SUITE
.F	lea	.TABF,a2
	bra.s	.SUITE
.N	lea	.TABN,a2
	bra.s	.SUITE
.T	lea	.TABT,a2
	bra.s	.SUITE
.G	lea	.TABG,a2
	bra.s	.SUITE
.TABD	dc.b	'A0',0,0,'B0',0,0,'A2',0,0,'B2',0,0,'A1',0,0,'B1',0,0,'A',0,0,0,'B',0,0,0
.TABL	dc.b	'A10',0,'B10',0,'X',0,0,0,'Y',0,0,0,'A',0,0,0,'B',0,0,0,'AB',0,0,'BA',0,0
.TABF	dc.b	'M0',0,0,'M1',0,0,'M2',0,0,'M3',0,0,'M4',0,0,'M5',0,0,'M6',0,0,'M7',0,0
.TABN	dc.b	'N0',0,0,'N1',0,0,'N2',0,0,'N3',0,0,'N4',0,0,'N5',0,0,'N6',0,0,'N7',0,0
.TABT	dc.b	'R0',0,0,'R1',0,0,'R2',0,0,'R3',0,0,'R4',0,0,'R5',0,0,'R6',0,0,'R7',0,0
.TABG	dc.b	'*',0,0,0,'SR',0,0,'OMR',0,'SP',0,0,'SSH',0,'SSL',0,'LA',0,0,'LC',0,0
.TABE	dc.b	'MR',0,0,'CCR',0,'OMR',0,'--',0,0,'--',0,0,'--',0,0,'--',0,0,'--',0,0
;**************************************
	xdef	TABLE_A19
TABLE_A19
FOUR
	move	d1,d2
	lsr	#2,d2
	jmp	([.TAB.l,d2.w*4])
.TAB	dc.l	.T0,.T1,.T2,.T2
.T0	rts
.T1	and.w	#%11,d1
	move.b	#'D',d7
	bra	TABLE_A17
.T2	and	#%111,d1
	move.b	#'D',d7
	bra	TABLE_A18
;**************************************
TABLE_A19b
CCCC
	lea	(.TAB.L,d1.w*4),a2
	col_cpy	a2,a6		
	;move	(.TAB.l,d1.w*2),(a6)+
	rts
.TAB	dc	'CC',0,'GE',0,'NE',0,'PL',0,'NN',0,'EC',0,'LC',0,'GT',0,'CS',0,'LT',0,'EQ',0,'MI',0,'NR',0,'ES',0,'LS',0,'LE',0	
;**************************************
	xdef	TABLE_A20
TABLE_A20
FIVE
	move	d1,d2
	lsr	#3,d2
	jmp	([.TAB.l,d2.w*4])
.TAB	dc.l	.T0,.T1,.T2,.T3
.T0	btst	#2,d1
	beq.s	.RESERVED
	and	#%11,d1
	move.b	#'D',d7
	bra	TABLE_A17		
.RESERVED
	rts
.T1	and	#%111,d1
	move.b	#'D',d7
	bra	TABLE_A18		
.T2	and	#%111,d1
	move.b	#'T',d7
	bra	TABLE_A18		
.T3	and	#%111,d1
	move.b	#'N',d7
	bra	TABLE_A18		
;**************************************
	xdef	TABLE_A21
TABLE_A21
SIX
	move	d1,d2
	lsr	#3,d2
	jmp	([.TAB.l,d2.w*4])
.TAB	dc.l	.T0,.T1,.T2,.T3,.T4,.T5,.T6,.T7
.T0	btst	#2,d1
	beq.s	.RESERVED
	and	#%11,d1
	move.b	#'D',d7
	bra	TABLE_A17		
.RESERVED	
	rts
.T1	and	#%111,d1
	move.b	#'D',d7
	bra	TABLE_A18		
.T2	and	#%111,d1
	move.b	#'T',d7
	bra	TABLE_A18		
.T3	and	#%111,d1
	move.b	#'N',d7
	bra	TABLE_A18		
.T4	and	#%111,d1
	move.b	#'F',d7
	bra	TABLE_A18		
.T5	rts
.T6	rts
.T7	and	#%111,d1
	move.b	#'G',d7
	bra	TABLE_A18		
;**************************************
	xdef	TABLE_A22
TABLE_A22
WRITE_CTRL
	tst	d0
	seq	W_CTRL
	rts
;**************************************
	xdef	TABLE_A23
TABLE_A23
MEMORY_S
	tst	d1
	bne.s	.OK
	move	#'X:',MEM_BANK
	rts
.OK	move	#'Y:',MEM_BANK
	rts
;**************************************
	xdef	TABLE_A24
TABLE_A24
PCR
	lea	(.TAB.l,d1.w*4),a2
	col_cpy	a2,a6
	;move.l	(.TAB.l,d1.w*4),(a6)+
	EFF_SP
	rts
.TAB	dc.b	'MR',0,0,'CCR',0,'OMR',0,'---',0	
;**************************************
	xdef	TABLE_A26
TABLE_A26
EA	;d1=MMMRRR
	move	d1,d2
	lsr	#3,d2
	and	#%111,d1	
	jmp	([.TAB.l,d2.w*4])
.TAB	dc.l	.T0,.T1,.T2,.T3,.T4,.T5,.T6,.T7
.T0	cpy	<'(R0)-N0'>,a6
	add.b	d1,-1(a6)
	add.b	d1,-9(a6)
	rts
.T1	cpy	<'(R0)+N0'>,a6
	add.b	d1,-1(a6)
	add.b	d1,-9(a6)
	rts
.T2	cpy	'(R0)-',a6
	add.b	d1,-5(a6)
	rts
.T3	cpy	'(R0)+',a6
	add.b	d1,-5(a6)
	rts
.T4	cpy	'(R0)',a6
	add.b	d1,-3(a6)
	rts
.T5	cpy	'(R0+N0)',a6
	add.b	d1,-3(a6)
	add.b	d1,-9(a6)
	rts
.T6	btst	#2,d1
	bne.s	.IMM
.ABS	move.l	(a0)+,d1
	addq.l	#1,P_COUNT
	bsr	HEXA_16
	rts
.IMM	subq	#4,a6
	move.b	ATTRIBUTE,(a6)+
	move.b	#'#',(a6)+
	move.l	(a0)+,d1
	addq.l	#1,P_COUNT
	bsr	HEXA_24
	rts
.T7	cpy	'-(R0)',a6
	add.b	d1,-3(a6)
	;move	#'-(',(a6)+
	;move.b	#'R',(a6)+
	;move.b	d1,(a6)+
	;move.b	#')',(a6)+
	rts
;**************************************
ABS_16
	move.l	(a0)+,d1
	addq.l	#1,P_COUNT
	bsr	FIND_LABEL
	tst.b	d2
	beq.s	.OK
	col_cpy	a1,a6
	move	COL_NOR,ATTRIBUTE		;met le LABEL
	rts
.OK	bra	HEXA_16
;**************************************
ABS_12
	bsr	FIND_LABEL
	tst.b	d2
	beq.s	.OK
	col_cpy	a1,a6
	move	COL_NOR,ATTRIBUTE		;met le LABEL
	rts
.OK	bra	HEXA_12
;**************************************
IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#'#',(a6)+
	and	#31,d1
	bra	HEXA_5
;**************************************
IMM_8
	move.b	ATTRIBUTE,(a6)+
	move.b	#'#',(a6)+
	and	#255,d1
	bra	HEXA_8
;**************************************
IMM_12	
	move.b	ATTRIBUTE,(a6)+
	move.b	#'#',(a6)+
	and	#$0fff,d1
	bra	HEXA_12	
;**************************************
ABSa6	
	move.b	ATTRIBUTE,(a6)+
	move.b	#'<',(a6)+
	bsr	FIND_LABEL
	tst.b	d2
	beq.s	.OK
	col_cpy	a1,a6
	move	COL_NOR,ATTRIBUTE		;met le LABEL
	rts
.OK	bra	HEXA_6
;**************************************
ABSp6	or	#%1111111111000000,d1
	cpy	'<<',a6
	bsr	FIND_LABEL
	tst.b	d2
	beq.s	.OK
	col_cpy	a1,a6
	move	COL_NOR,ATTRIBUTE		;met le LABEL
	rts
.OK	bra	HEXA_16
;**************************************
ABSa12	
	move.b	ATTRIBUTE,(a6)+
	move.b	#'<',(a6)+
	bsr	FIND_LABEL
	tst.b	d2
	beq.s	.OK
	col_cpy	a1,a6
	move	COL_NOR,ATTRIBUTE		;met le LABEL
	rts
.OK	bra	HEXA_12
;**************************************
JJJD	;sp‚cial pour Tcc and CO
	;move.l	(.TAB.l,d1.w*4),(a6)+
	lea	(.TAB.l,d1.w*4),a2
	col_cpy	a2,a6
	;EFF_SP
	rts
.TAB	dc.b	'B,A',0,'A,B',0
	dc.l	0,0,0,0
	dc.b	'X0,A','X0,B','Y0,A','Y0,B'
	dc.b	'X1,A','X1,B','Y1,A','Y1,B'
;**************************************
JJJd	;pour les instructions avec Par move
	;move.l	(.TAB.l,d1.w*8),(a6)+
	lea	(.TAB.l,d1.w*8),a2
	col_cpy	a2,a6
	;EFF_SP
	rts
.TAB	dc.b	'B,A',0,0,0,0,0,'A,B',0,0,0,0,0,'B,A',0,0,0,0,0,'A,B',0,0,0,0,0,'X,A',0,0,0,0,0,'X,B',0,0,0,0,0,'Y,A',0,0,0,0,0,'Y,B',0,0,0,0,0
	dc.l	'X0,A',0,'X0,B',0,'Y0,A',0,'Y0,B',0,'X1,A',0,'X1,B',0,'Y1,A',0,'Y1,B',0
;**************************************
;**************************************
	BSS
MEM_BANK::	ds	1	
W_CTRL		ds	1