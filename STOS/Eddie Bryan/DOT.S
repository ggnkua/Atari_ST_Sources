************************************************
* STOS EXTENSION ROUTINES BY  EDDIE BRYAN      *
*					       *
*        THE HAPPENING BOIZ (C) 1991           *
************************************************

************************************************
*      MEGA FAST 1 PLANE PIXEL PLOT ROUTINE    *
* 					       *
* ENTER WITH A0 - DESTINATION SCREEN           *
*            A1 - POINTS TO PIXEL DATA         *
*	     D0 - NUMBER OF PIXELS TO PLOT     * 
************************************************

DOT_MATRIX
	MOVE.L	A0,A2			*SAVE SCREEN ADDRESS
	MOVE.W	D0,D4
DOT_WIPE
	MOVE.L	A2,A0
	MOVE.W	(A3)+,D1
	ADD.W	D1,A0
	MOVE.W	#0,(A0)			*WIPE DOTS
	MOVE.W	#0,160(A0)
	MOVE.W	#0,320(A0)
	ADD.W	#2,A3
	DBF	D4,DOT_WIPE


DOT_LOOP

	MOVE.L	A2,A0	
	MOVE.W	(A1)+,D1		*GET SCREEN POS
	MOVE.W	(A1)+,D2		*GET PIXEL POS
	ADD.W	D1,A0
	MOVE.W	D2,D3		

	NOT.W	D3			*MASK PIXEL
	AND.W	D3,(A0)
	OR.W	D2,(A0)
	AND.W	D3,160(A0)
	OR.W	D2,160(A0)
	AND.W	D3,320(A0)
	OR.W	D2,320(A0)

	DBF	D0,DOT_LOOP		*LOOP

	RTS				*JUMP BACK TO STOS!!!