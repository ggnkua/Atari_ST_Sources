*	Program III.....get screen resolution

prints	MACRO			Print a string
	PEA \1(PC)
	MOVE #9,-(A7)		c_conws
	TRAP #1
	ADDQ.L #6,A7
	ENDM

*----->	Start of program
	MOVE #4,-(A7)		_getRez
	TRAP #14		XBIOS
	ADDQ.L #2,A7		Tidy stack
	CMP #2,D0		rez = 2?
	BNE a
	prints high
	BRA exit
a	CMPI #1,D0		rez = 1?
	BNE b
	prints med
	BRA exit
b	prints low		Must be low then

*----->	Wait for a keypress
exit	MOVE #8,-(A7)		c_necin
	TRAP #1			GEMDOS
	ADDQ.L #2,A7

*----->	CLR -(A7)		p_term
	TRAP #1

************************************
* Print out any number in any base *
* D0.L=number / D1.L=base	   *
* Uses D0, D1, A0		   *
************************************
printn	LEA buffer(PC),A0  A0->buffer start
	CLR.L (A0)+        Zero buffer
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+        A0->buffer end
loop1	DIVU D1,D0         D0 DIV D1
	SWAP D0            D0.low=remainder
	ADDI #'0',D0       Make into digit
	CMPI #'9',D0       Digit or letter?
	BLE ok
	ADDQ #7,D0         Make into letter
ok	MOVE.B D0,-(A0)    Store character
	CLR D0
	SWAP D0            D0.low=quotient
	BNE loop1          Another one?
loop2	MOVE.L A0,-(A7)    c_conws
	MOVE #9,-(A7)      Print string
	TRAP #1            GEMDOS 9
	ADDQ.L #6,A7       Tidy stack
	RTS

buffer	DS.L 5          Number$ - 20 digits
	DC.W 0          Buffer end marker

high	DC.B 'Monochrome',0
	EVEN
med	DC.B 'Medium resolution',0
	EVEN
low	DC.B 'Low resolution',0
	EVEN
	END
