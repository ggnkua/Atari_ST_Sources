	IFNE Keys
Handle_Keyboard:
		LEA	Keyboard_Tests,A0
.loop		MOVE.L	(A0)+,D0
		BMI.S	.done
		MOVE.L	(A0)+,D1		;val to add
		MOVE.L	(A0)+,A1		;address
		TST.B	(Keyboard_Matrix.L,D0.w)
		BEQ.S	.nochange
		ADD.L	D1,(A1)			;along longword values
.nochange:
		BRA.S	.loop
.done:	RTS


Keyboard_Tests:
		DC.L	$02,+movespeed2,viewer_x
		DC.L	$03,-movespeed2,viewer_x
		DC.L	$04,+movespeed2,viewer_y
		DC.L	$05,-movespeed2,viewer_y
		DC.L	$06,+movespeed2,viewer_z
		DC.L	$07,-movespeed2,viewer_z

		DC.L	$67,+movespeed,rotation_x
		DC.L	$6a,-movespeed,rotation_x
		DC.L	$68,+movespeed,rotation_y
		DC.L	$6B,-movespeed,rotation_y
		DC.L	$69,+movespeed,rotation_z
		DC.L	$6C,-movespeed,rotation_z

		DC.L	$4E,+movespeed2,Viewer_Distance
		DC.L	$4A,-movespeed2,Viewer_Distance
		DC.L	-1
	ENDC

