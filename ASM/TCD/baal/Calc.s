;This code generates a unique file name from the start track being read and adds the DAT
;extension to it.  Use from within Monst then do a normal save and give it the file name
;that has been generated.

;You must have written down the values before every call to the track loader

CALC	MOVEM.L	D0-A6,-(A7)
	LEA	STORE(PC),A1
	MOVE.W	#"  ",(A1)
	MOVE.L	D0,D3		;START TRACK
	MOVE.L	A0,A4		;LOAD ADDRESS
	CLR.L	D4
	CLR.L	D5
	LEA	ASCII(PC),A0
	MOVE.B	D3,D4
	DIVU	#16,D4	
	MOVE.W	D4,D5
	CLR.W	D4
	SWAP	D4
	MOVE.B	(A0,D5.W),(A1)
	MOVE.B	(A0,D4.W),1(A1)
	MOVEM.L	(A7)+,D0-A6
	RTS
	
STORE	DC.B	"  "
	DC.B	".DAT"
	DC.B	0,0
	EVEN
	

ASCII	DC.B	"0123456789ABCDEF"
