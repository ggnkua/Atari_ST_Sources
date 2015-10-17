*****************************
* ROUTINE DE FACES CACHEES  * 
*           by	      *
*    Cristalion/Hydroxid    *
*****************************

CACHE
	MOVEM.L	CLR,D0-D5
	MOVE.W	X1,D0		
	MOVE.W	X3,D1
	MOVE.W	Y1,D2
	MOVE.W	Y2,D3
;
	SUB	D0,D1	;X3-X1
	SUB	D2,D3	;Y2-Y1
	MULS	D1,D3	
;
	MOVE	X2,D4
	MOVE	Y3,D5
	SUB	D0,D4	;X2-X1
	SUB	D2,D5	;Y3-Y1
	MULS	D4,D5
;
	SUB.L	D5,D3
*	NEG.L	D3
	RTS
