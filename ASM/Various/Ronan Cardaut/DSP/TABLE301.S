col_cpy	macro
;\1=source
;\2=dest
	move	d0,-(sp)
	move	ATTRIBUTE,d0
.LOOP\@	move.b	(\1)+,d0
	beq.s	.COA\@
	move	d0,(\2)+
	bra.s	.LOOP\@
.COA\@	move	(sp)+,d0
	endm


;------------------------------------------------------------
;pour toute les tables
;d0= chap de bits
;d1= colonne de la table en ASCII de pref‚rence
;a6=ptr ascii
	xref	ATTRIBUTE,MEM_BANK



	*-----------------------------*

TABLE_A10			;DESTINATION ACCUMULATOR ENCODING
*---pour d/S/D
	move.b	ATTRIBUTE,(a6)+
	cmp	#1,d0
	beq.s	.U
	move.b	#'A',(a6)+
	rts
.U	move.b	#'B',(a6)+
	rts
	
	*-----------------------------*
	

TABLE_A11			;DATA ALU OPERANDS ENCODING
*---pour J
	move.b	ATTRIBUTE,(a6)+
	cmp	#1,d0
	beq.s	.U
	move.b	#'X',(a6)+
	rts
.U	move.b	#'Y',(a6)+
	rts

	*-----------------------------*


TABLE_A12			;DATA ALU SOURCE OPERANDS ENCODING
	lea	(.TAB,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB	dc	'X0',0,0
	dc	'Y0',0,0
	dc	'X1',0,0
	dc	'Y1',0,0
		

	*-----------------------------*

TABLE_A13			;PROGRAM CONTROL UNIT ENCODING
	lea	(.TAB,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB	dc.b	'MR',0,0
	dc.b	'CCR',0
	dc.b	'COM',0
	dc.b	'EOM',0


	*-----------------------------*


TABLE_A14			;DATA ALU OPERANDS ENCODING
	;ici MSW de d0 prend la valeur de d
	cmp.b	#1,d0
	beq.s	.special				
	lea	(.TAB,d0.w*4),a2
	col_cpy	a2,a6
	rts
.special
	move.b	ATTRIBUTE,(a6)+
	btst	#16,d0
	bne.s	.A
	move.b	#'B',(a6)+
	rts
.A	move.b	#'A',(a6)+
	rts
	
.TAB	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'X',0,0,0
	dc.b	'Y',0,0,0
	dc.b	'X0',0,0
	dc.b	'Y0',0,0
	dc.b	'X1',0,0
	dc.b	'Y1',0,0


	*-----------------------------*
TABLE_A15			;DATA ALU OPERANDS ENCODING
	cmp.b	#'S',d7
	beq	.COL1
	cmp.b	#'s',d7
	beq	.COL1
	cmp.b	#'q',d7
	beq	.COL2
	cmp.b	#'g',d7
	beq	.COL3
	move.b	ATTRIBUTE,(a6)+
	move.b	#'/',(a6)+		;erreur
	rts
.COL1	lea	(.TAB1,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB1	dc	'//',0,0
	dc	'//',0,0
	dc	'A1',0,0
	dc	'B1',0,0
	dc	'X0',0,0
	dc	'Y0',0,0
	dc	'X1',0,0
	dc	'Y1',0,0

.COL2	lea	(.TAB2,d0.w*2),a2
	col_cpy	a2,a6
	rts
.TAB2	dc	'//',0,0
	dc	'//',0,0
	dc	'A0',0,0
	dc	'B0',0,0
	dc	'X0',0,0
	dc	'Y0',0,0
	dc	'X1',0,0
	dc	'Y1',0,0

.COL3	cmp	#0,d0
	beq.s	.special
	lea	(.TAB3,d0.w*2),a2
	col_cpy	a2,a6
	rts
.special
	move.b	ATTRIBUTE,(a6)+
	btst	#16,d0
	bne.s	.A
	move.b	#'B',(a6)+
	rts
.A	move.b	#'A',(a6)+
	rts
.TAB3	dc	'//',0,0
	dc	'//',0,0
	dc	'//',0,0
	dc	'//',0,0
	dc	'X0',0,0
	dc	'Y0',0,0
	dc	'X1',0,0
	dc	'Y1',0,0
	
	
	*-----------------------------*
TABLE_A16			;EFFECTIVE ADRESSING MODE ENCODING #1
	lea	(.TAB.l,d0.w*8),a2
	col_cpy	a2,a6
	rts
.TAB	
A	set	'0'
	rept	8
	dc.b	'(R',A,')-N',A,0	
A	set	A+1
	endr				;(Rn)-Nn

A	set	'0'
	rept	8
	dc.b	'(R',A,')+N',A,0	
A	set	A+1
	endr				;(Rn)+Nn

A	set	'0'
	rept	8
	dc.b	'(R',A,')-',0,0,0	
A	set	A+1
	endr				;(Rn)-

A	set	'0'
	rept	8
	dc.b	'(R',A,')+',0,0,0	
A	set	A+1
	endr				;(Rn)+


A	set	'0'
	rept	8
	dc.b	'(R',A,')',0,0,0,0	
A	set	A+1
	endr				;(Rn)

A	set	'0'
	rept	8
	dc.b	'(R',A,'+N',A,')',0
A	set	A+1
	endr				;(Rn+Nn)



	dcb.l	2*8,0			;absolute adresse 

A	set	'0'
	rept	8
	dc.b	'-(R',A,')',0,0,0	
A	set	A+1
	endr				;-(Rn)
	
	dcb.l	2*8,0			;imm‚diate data
					
	
			
	*-----------------------------*
TABLE_A17				;MEMORY/PERIPHERAL SPACE
	tst	d0
	bne.s	.OK
	move	#'X:',MEM_BANK
	rts
.OK	move	#'Y:',MEM_BANK
	rts

	*-----------------------------*

TABLE_A18				;EFFECTIVE ADRESSING MODE ENCODING #2
;pour l'instant c'est compatible avec table a16
	bra	TABLE_A16


	*-----------------------------*

TABLE_A19				;EFFECTIVE ADRESSING MODE ENCODING #3
;pour l'instant c'est compatible avec table a16
	bra	TABLE_A16


	*-----------------------------*


TABLE_A20				;EFFECTIVE ADRESSING MODE ENCODING #4
;pour l'instant c'est compatible avec table a16
	bra	TABLE_A16


	*-----------------------------*

TABLE_A21				;TRIPLE BIT REGISTER ENCODING
	cmp	#'1D',d1
	beq	.COL1
	cmp.b	#'D',d1
	beq	.COL2
	cmp.b	#'T',d1
	beq	.COL3
	cmp.b	#'N',d1
	beq	.COL4
	cmp.b	#'F',d1
	beq	.COL5
	cmp.b	#'E',d1
	beq	.COL6
	cmp.b	#'V',d1
	beq	.COL7
	cmp.b	#'G',d1
	beq	.COL8
	move.b	ATTRIBUTE,(a6)+
	move.b	#'/',(a6)+		;erreur
	rts

.COL1	lea	(.TAB1,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB1	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'X0',0,0	
	dc.b	'X1',0,0	
	dc.b	'Y0',0,0	
	dc.b	'Y1',0,0	

.COL2	lea	(.TAB2,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB2	dc.b	'A0',0,0
	dc.b	'B0',0,0
	dc.b	'A2',0,0
	dc.b	'B2',0,0
	dc.b	'A1',0,0
	dc.b	'B1',0,0
	dc.b	'A',0,0,0
	dc.b	'B',0,0,0

.COL3	lea	(.TAB3,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB3	dc.b	'R0',0,0
	dc.b	'R1',0,0
	dc.b	'R2',0,0
	dc.b	'R3',0,0
	dc.b	'R4',0,0
	dc.b	'R5',0,0
	dc.b	'R6',0,0
	dc.b	'R7',0,0


.COL4	lea	(.TAB4,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB4	dc.b	'N0',0,0
	dc.b	'N1',0,0
	dc.b	'N2',0,0
	dc.b	'N3',0,0
	dc.b	'N4',0,0
	dc.b	'N5',0,0
	dc.b	'N6',0,0
	dc.b	'N7',0,0


.COL5	lea	(.TAB5,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB5	dc.b	'M0',0,0
	dc.b	'M1',0,0
	dc.b	'M2',0,0
	dc.b	'M3',0,0
	dc.b	'M4',0,0
	dc.b	'M5',0,0
	dc.b	'M6',0,0
	dc.b	'M7',0,0



.COL6	lea	(.TAB6,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB6	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'EP'
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0


.COL7	lea	(.TAB7,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB7	
	dc.b	'VBA',0
	dc.b	'SC',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0
	dc.b	'//',0,0


.COL8	lea	(.TAB8,d0.w*4),a2
	col_cpy	a2,a6
	rts
.TAB8	dc.b	'SZ',0,0
	dc.b	'SR',0,0
	dc.b	'OMR',0
	dc.b	'SP',0,0
	dc.b	'SSH',0
	dc.b	'SSL',0
	dc.b	'LA',0,0
	dc.b	'LC',0,0




	