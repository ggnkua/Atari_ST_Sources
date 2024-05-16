movespeed	equ	100
movespeed2	equ	300

Handle_Keyboard:
		lea	Keyboard_Matrix,a2
		LEA	Keyboard_Tests,A0
.loop		MOVE.L	(A0)+,D0
		BMI.S	.done
		MOVE.L	(A0)+,D1		;val to add
		MOVE.L	(A0)+,A1		;address
		TST.B	(A2,D0.w)
		BEQ.S	.nochange
		ADD.L	D1,(A1)			;along longword values
.nochange:
		BRA.S	.loop
.done:	RTS


Keyboard_Tests:
		DC.L	$4b,+movespeed,viewer_x
		DC.L	$4d,-movespeed,viewer_x
		DC.L	$48,+movespeed,viewer_y
		DC.L	$50,-movespeed,viewer_y
		DC.L	$4E,-movespeed2,Viewer_Distance
		DC.L	$4A,+movespeed2,Viewer_Distance
		DC.L	-1
