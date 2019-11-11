*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0017.S   *
*  This program should be assembled to disk as PROG0017.PRG or  *
*  PROG0017.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*****************************************************************
* Using the Vertical Blank Interrupt 			 	*
*****************************************************************
start:	MOVE.W	#2,-(SP)	;Get Screen Address
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,scraddr	;And Save It
*
loop:	MOVE.W	#1,-(SP)	;Get a key
	TRAP	#1
	ADDQ.L	#2,SP
*
	CMP.W	#'+',D0		;Plus pressed?
	BEQ.S	von
	CMP.W	#'-',D0		;Minus Pressed?
	BEQ.S	voff	
	BRA	quit



* Set the vertical blank routine on
von:	PEA	vert_on(PC)	;Address of routine to be executed
	MOVE.W	#38,-(SP)	;XBIOS 38 executes in Supervisor mode
	TRAP	#14
	ADDQ.L	#6,(SP)
	BRA	loop
*

* Set the vertical blank routine off
voff:	PEA	vert_off(PC)	;Address of routine to be executed
	MOVE.W	#38,-(SP)	;XBIOS 38 executes in Supervisor mode
	TRAP	#14
	ADDQ.L	#6,(SP)
	BRA	loop
*
quit:	CLR.W	-(SP)		;Quit
	TRAP	#1
**********************************************************
* Set the address of our vertical blank routine in the   *
* table of addresses used by the ST. 			 *
* THIS ROUTINE MUST BE EXECUTED IN SUPERVISOR MODE       *
**********************************************************
vert_on:
	MOVE.L	$456,A0		;Address of que into A0
	MOVE.W	$454,D0		;Size of table (x4) in D0
*
v_loop:	TST.L	(A0)		;This element of table = 0?
	BEQ.S	v_mt		;Yes - go fill it
	ADD.L	#4,A0		;Increase pointer
	SUB.W	#1,D0		;Decrease counter
	BNE.S	v_loop		;Until 0
	BRA.S	vert_x

v_mt:	LEA	inter(PC),A1	;Move address of interrupt routine
	MOVE.L	A1,(A0)		;into the table
vert_x:	RTS	
*
**********************************************************
* Clear the address of our vertical blank routine in the *
* table of addresses used by the ST. 			 *
* THIS ROUTINE MUST BE EXECUTED IN SUPERVISOR MODE       *
**********************************************************
vert_off:
	MOVE.L	$456,A0		;Address of que into A0
	MOVE.W	$454,D0		;Size of table (x4) in D0
*
vo_loop:
	CMP.L	#inter,(A0)	;This element of table = our routine
	BEQ.S	vo_mt		;Yes - go clear it
	ADD.L	#4,A0		;Increase pointer
	SUB.W	#1,D0		;Decrease counter
	BNE.S	vo_loop		;Until 0
	BRA.S	verto_x

vo_mt:	
	CLR.L	(A0)		;Clear table element.
verto_x:
	RTS	


inter:	MOVE.L	scraddr,A0	;Address of screen start in A0
	MOVE.W	count,D0	;counter in D0
	SUB.W	#160,D0		;Update counter
	BPL	ok		;Ok if still positive
*
	MOVE.W	#32000,D0	;Reset counter to 32000
ok:	MOVE.W	D0,count	;Update counter
*
	EOR.W	#$FFFF,(A0,D0.W)	;Draw on screen
*
	RTS
*
scraddr:	DC.L	0
count:		DC.W	0
