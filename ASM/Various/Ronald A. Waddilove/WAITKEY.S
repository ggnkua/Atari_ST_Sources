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
