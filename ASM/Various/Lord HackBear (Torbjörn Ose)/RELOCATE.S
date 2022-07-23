; ROUTINE TO RELOCATE A RELOCATEABLE FILE
; Torbj”rn Ose (ST-Klubben Norway)
;(Made with DEVPAC2 but should work with other assemblers 
; without much modification)

DO_REL:	MOVE.L  #$17000,A0    Start of HEADER (change it to suit your needs)
	MOVE.L  2(A0),D0      Length of PROGRAM (Text)
	ADD.L   6(A0),D0      Length of INITIALISED DATA
	ADD.L   14(A0),D0     Length of SYMBOL TABLE
; D0 contains relative position of RELOCATION TABLE
	ADD.L   #$1C,A0       A0 Points to programs start adress
	MOVE.L  A0,A1         Copy it to A1
	MOVE.L  A1,A2         and A2
	MOVE.L  #$1701c,D1    This is the adress we relocate the program
;                             to execute from (Change as above)
;If you use another adress remember to move your program to the new
;adress before executing it!
	ADD.L   D0,A1         Get adress of RELOCATION TABLE
	MOVE.L  (A1)+,D0      Get the Long Word
	ADD.L   D0,A2         Point to the first Absolute adress
	ADD.L   D1,(A2)       Relocate it
	CLR.L   D0            Clear D0
RELO:	MOVE.B  (A1)+,D0      Get next byte from table
	BEQ     RELEND        Is it the end (zero)
	CMP.B   #1,D0         1 is a 254 jump
	BEQ     JUMP          If it is then do it
	ADD.L   D0,A2         If not find next absolute adress
	ADD.L   D1,(A2)       and relocate it
	BRA     RELO          Continue until the zero is found
JUMP:	ADD.L   #254,A2       Jump 254 bytes
	BRA     RELO          and continue
RELEND:
	RTS
; Uninitialised data is not loader so we simply forget it

