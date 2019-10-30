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
