*	Program I.....print random numbers

	MOVE #14,D7		loop counter - 15 numbers
loop	MOVE #17,-(A7)		_random
	TRAP #14		XBIOS
	ADDQ.L #2,A7		Tidy stack
	ANDI.L #$FF,D0		0 - 255
	MOVE.L #10,D1		Print number in decimal
	BSR printn
	MOVE #13,-(A7)		Print CR
	MOVE #2,-(A7)		c_conout
	TRAP #1
	ADDQ.L #4,-(A7)		Tidy stack
	MOVE #10,-(A7)		Print LF
	MOVE #2,-(A7)		c_conout
	TRAP #1
	ADDQ.L #4,-(A7)		Tidy stack
	DBRA D7,loop		Another one?

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
