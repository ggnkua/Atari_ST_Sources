	lea	EXPRESSION,a0
	bsr	READ_EXPRESSION
	illegal	
	
	
READ_EXPRESSION
	movem.l	d1-d7/a1-a6,-(sp)	

NEXT_CHAR
	move.b	(a0)+,d1
	beq	FIN_EXPRESSION
	cmp.b	#')',d1
	beq	FIN_EXPRESSION		;on termine sur \0 ou ")"

	cmp.b	#'(',d1
	beq	OPEN_P
	
	cmp.b	#'~',d1
	beq	TILDE
		
	cmp.b	#'<',d1
	beq.S	ASL
		
	cmp.b	#'$',d1
	beq	DOLLAR
	
	bra	DECIMAL
	

	
OPEN_P	
	bsr	READ_EXPRESSION
	bra	NEXT_CHAR


	*---------------------*
	* ~
	*---------------------*
TILDE
	bsr	READ_EXPRESSION
	not.l	d0
		
	bra	NEXT_CHAR
	bra	FIN_EXPRESSION
		

	*---------------------*
	* <<
	*---------------------*
ASL
	move.b	(a0)+,d1
	cmp.b	#'<',d1
	beq.S	.OK
	illegal	
.OK	
	move.l	d0,d1
	bsr	READ_EXPRESSION
	lsl.l	d0,d1
	move.l	d1,d0

	bra	NEXT_CHAR
	bra	FIN_EXPRESSION



	*---------------------*
	* NOMBRE HEXADECIMAL
	*---------------------*

DOLLAR
	moveq	#0,d0
.LOOP	
	move.b	(a0),d1
	cmp.b	#'0',d1
	blt	FIN_EXPRESSION
	cmp.b	#'9',d1
	ble	.OK9
	
	cmp.b	#'A',d1
	blt	FIN_EXPRESSION
	cmp.b	#'F',d1
	bgt	FIN_EXPRESSION
	sub.b	#'A'-10-'0',d1
	
.OK9	sub.b	#'0',d1

	

	and.l	#$f,d1
	lsl.l	#4,d0
	or.l	d1,d0
	addq	#1,a0
	bra.S	.LOOP


DECIMAL
	*---------------------*
	* NOMBRE DECIMAL
	*---------------------*
	cmp.b	#'0',d1
	blt	NO_DECI
	cmp.b	#'9',d1
	bgt	NO_DECI		;d‚tection d'un nombre d‚cimal par son premier chiffre
	sub	#'0',d1
	and.l	#$f,d1		
	move.l	d1,d0
	
	move.b	(a0),d1
	cmp.b	#'0',d1
	blt	FIN_EXPRESSION
	cmp.b	#'9',d1
	bgt	FIN_EXPRESSION
	sub	#'0',d1
	and.l	#$f,d1		
	mulu	#10,d0
	add.l	d1,d0	
NO_DECI	

	
	
FIN_EXPRESSION
	movem.l	(sp)+,d1-d7/a1-a6
	rts
	
			






EXPRESSION	dc.b	'~(~0<<8)',0
;EXPRESSION	dc.b	'~(~(~0<<8)<<12)',0
;EXPRESSION	dc.b	'($02a00481&~(~(~0<<8)<<12))'
