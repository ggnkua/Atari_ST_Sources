	SECTION	TEXT

	
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)		;supervisor mode
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,old_sp		;store old stack pointer
	
	MOVE.W	#4,-(SP)		;get rez
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,old_rez		;store rez
	CMPI.W	#2,D0			;high rez??
	BEQ	quit			;yes then quit

	LEA	$FFFF8240.W,A0
	LEA	def_pal,A1
	LEA	32(A1),A1		;offset to top of pal store
	MOVEM.L	(A0)+,D0-D7		;move 8L or 16W from col reg
	MOVEM.L	D0-D7,-(A1)		;to D-regs then to col store

	CLR.W	-(SP)			;low rez
	MOVE.L	#-1,-(SP)		;leave physbase
	MOVE.L	#-1,-(SP)		;leave logbase
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP		;smaller code than:  add.l #12,sp
	
******** Scroller code goes here ********

	MOVE.W	old_rez,-(SP)		;restore rez
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP

	LEA	def_pal,A0
	LEA	$FFFF8260.W,A1		;restore colours
	MOVEM.L	(A0)+,D0-D7
	MOVEM.L	D0-D7,-(A1)

quit	MOVE.L	old_sp,-(SP)
	MOVE.W	#$20,-(SP)		;user mode
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR.W	-(SP)			;p_term
	TRAP	#1


	SECTION	DATA

	SECTION	BSS


old_sp	DS.L	1
old_rez	DS.W	1
def_pal	DS.W	16