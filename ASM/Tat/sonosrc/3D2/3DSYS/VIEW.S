Send_Viewpoint:
		LEA	$FFFFA204.W,A1
		 wait_transmit
		MOVE.L	#"VIE",(A1)
		MOVEQ	#3-1,D0			;for view pos
		LEA	viewer_x,A2
.loop:
		MOVE.L	(A0)+,D1
		ADD.L	(A2)+,D1
		wait_transmit
		MOVE.L	D1,(A1)
		DBF	D0,.loop

		LEA	camera_x,A2
		MOVEQ	#3-1,D0			;for view pos
.loop2:
		MOVE.L	(A2)+,D1
		wait_transmit
		MOVE.L	D1,(A1)
		DBF	D0,.loop2

		 wait_transmit
		MOVE.L	Viewer_Size,(A1)
		RTS
