*	Program II.....print physbase and logbase

prints	MACRO			Print a string
	PEA \1(PC)
	MOVE #9,-(A7)		c_conws
	TRAP #1
	ADDQ.L #6,A7
	ENDM

*----->	Start of program
	prints phys		Get physical screen base
	MOVE #2,-(A7)		_physbase
	TRAP #14		XBIOS
	ADDQ.L #2,A7		Tidy stack
	MOVE.L #16,D1		Print number in hex
	BSR printn

	prints log		Get logical screen base
	MOVE #3,-(A7)		_logbase
	TRAP #14		XBIOS
	ADDQ.L #2,A7		Tidy stack
	MOVE.L #16,D1		Print number in hex
	BSR printn

*----->	Wait for a keypress
	MOVE #8,-(A7)		c_necin
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
	DC.B 0          Buffer end marker
	EVEN

phys	DC.B 13,10
	DC.B 'Screen Physbase = &',0
	EVEN
log	DC.B 13,10
	DC.B 'Screen Logbase = &',0
	END
