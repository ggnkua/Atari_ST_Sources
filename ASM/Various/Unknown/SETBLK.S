; Perform "setblock" call, to free memory not needed.

	MOVE.L	A7,A5		;
	MOVE.L	4(A5),A5	;
	MOVE.L	$C(A5),D0	;
	ADD.L	$14(A5),D0	;
	ADD.L	$1C(A5),D0	;
	ADD.L	#$1100,D0	;
	MOVE.L	A5,D1		;
	ADD.L	D0,D1		;
	AND.L	#-2,D1		;
	MOVE.L	D1,A7		;
	MOVE.L	D0,-(SP)	;
	MOVE.L	A5,-(SP)	;
	MOVE.W	D0,-(SP)	;
	MOVE.W	#$4A,-(SP)	; SETBLOCK function code.
	TRAP	#1		; Call GEMDOS.
	ADD.L	#12,SP		; Correct stack pointer.
	TST.L	D0		; Test error status.
	BMI	TERM		; Exit on error.
