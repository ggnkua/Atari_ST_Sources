;******************************
;*        PROGRAM IV          *
;* Shows all programs working *
;*     Uses D0,D1,D3,D4,D7    *
;******************************

	MOVE.L #wrap,-(A7)
	MOVE.W #9,-(A7)
	TRAP #1
	ADDQ.W #6,A7
	MOVE.l #199,D7     Do it 200 times
progloop1
	MOVE.l #01,D3      Minimum number
	MOVE.l #50,D4      Maximum number
	BSR random         Get number in D0
	MOVE.L #10,D1      Number base 10
	BSR printn         Print the number
	MOVE.W #32,-(A7)   Print a space
	MOVE.W #2,-(A7)    beteen numbers
	TRAP #1
	ADDQ.W #4,A7
	DBRA D7,progloop1  Done 200 times?
	MOVE.B #65,D7      Ascii value of A
	BSR wait_key       Until A pressed
	MOVE.W #0,-(A7)    Back to desktop
	TRAP #1
wrap
	DC.B 27,"v",0
	EVEN

;***************************
;*        PROGRAM I        *
                       ;* Random number generator *
;*     uses D0 D3 D4       *
;***************************

;To use this routine set D3 and D4
;and call it with BSR random
;D0.L - The returned random number
;D3.L - Minimum random value
;D4.L - Maximum random value+1
random
	MOVE.W #17,-(A7)  Use function
	TRAP #14          17 to get the
	ADDQ.W #2,A7      random number.
	AND.L #$ffff,D0   Make it 16 bits
	SUB. D3,D4        D4=max-min
	DIVU D4,D0        D0 / D4
	SWAP D0           Put MOD value
	AND.L #$FFFF,D0   into lower bytes.
	ADD.L D3,D0       D0=D0+min.
	RTS               Finished.

;*****************************
;*        PROGRAM IV         *
;*    wait for a key press   *
;*       Uses D0, D7         *
;*****************************

wait_key
	MOVE.W #255,-(A7) Set for read
	MOVE.W #6,-(A7)   Read the keyboard
	TRAP #1
	ADDQ.W #4,A7
	BCLR #5,D0        Make upper case
	CMP.B D7,D0       Is correct key?
	BNE wait_key      No
	RTS               Yes

;************************************
;* Print out any number in any base *
;*     D0.L=number / D1.L=base      *
;*         Uses D0, D1, A0          *
;************************************
printn
	LEA buffer(PC),A0 A0->buffer
	CLR.L (A0)+       Zero buffer
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+       A0->buffer end
loop1
	DIVU D1,D0        D0 DIV D1
	SWAP D0           D0.low=remainder
	ADDI #'0',D0      Make into digit
	CMPI #'9',D0      Digit or letter?
	BLE ok
	ADDQ #7,D0        Make into letter
ok
	MOVE.B D0,-(A0)   Store character
	CLR D0
	SWAP D0           D0.low=quotient
	BNE loop1         Another one?
loop2
	MOVE.L A0,-(A7)
_conws
	MOVE #9,-(A7)     Print string
	TRAP #1           GEMDOS 9
	ADDQ.L #6,A7      Tidy stack
	RTS
buffer
	DS.L 5            Number$ - 20 digits
	DC.B 0            Buffer end marker
	EVEN
