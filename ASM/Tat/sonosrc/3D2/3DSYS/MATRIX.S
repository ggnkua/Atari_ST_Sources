

MakeMatrixObject:
		MOVEM.L	Rotation_X,D0/D1/D2
		MOVE.L	#"MAT",D7
		BRA.S	DoMatrix
MakeMatrixLight:
		MOVEM.L	Rotation_X,D0/D1/D2
		;MOVEM.L	LightRot_X,D0/D1/D2
		MOVE.L	#"LIG",D7
; Expansion to allow fading using the unit_vector?

DoMatrix:
		AND.L	#$1FFF,D0
		AND.L	#$1FFF,D1
		AND.L	#$1FFF,D2
		LEA	CosTable,A0
		LEA	SineTable,A1
		wait_transmit
		MOVE.L	D7,$FFFFA204.W
		MOVEQ	#0,D7
		MOVE.W	(A0,D0.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A1,D0.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A0,D1.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A1,D1.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A0,D2.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A1,D2.W*2),D7
		BSR.S	SendInfo
		RTS
SendInfo:
		EXT.L	D7
		ASL.L	#8,D7
		 wait_transmit
		MOVE.L	D7,$FFFFA204.W
		RTS

Send_Viewpoint:
		LEA	$FFFFA204.W,A1
		LEA	viewer_x,A2
		 wait_transmit
		MOVE.L	#"VIE",(A1)
		MOVEQ	#3-1,D0			;for view pos
.loop:
		MOVE.L	(A0)+,D1
		ADD.L	(A2)+,D1
		wait_transmit
		MOVE.L	D1,(A1)

		DBF	D0,.loop

		 wait_transmit
		MOVE.L	Camera_X,(A1)
		 wait_transmit
		MOVE.L	Camera_Y,(A1)
		 wait_transmit
		MOVE.L	Camera_Z,(A1)


		 wait_transmit
		MOVE.L	Viewer_Size,(A1)
		RTS

