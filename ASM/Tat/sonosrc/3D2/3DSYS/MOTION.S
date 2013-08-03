;--------------------------------------------------------------
MotionBlurScreen:
		MOVE.L	#$0019,D0
		MOVEC	D0,CACR

		MOVE.L	third,A0
		MOVE.L	logic,A1

		add.l	#BytesPerLine*2,a0
		add.l	#BytesPerLine*2+4,a1

		LEA.L	Colour_Table,A2

		MOVE.W	#100-4-1,D0
		MOVEQ	#0,D4
.Feedbackloop1:
		MOVE.W	#(192/4)-1,D3
		Ifeq	Direction
		 MOVEQ	#0,D2
		Else
		 MOVEQ	#-1,D2
		Endc
.Feedbackloop2:
		REPT	4
		 move.w	(a1),d4
		 MOVE.W	(A2,D4.L*2),D2
		 MOVE.L	D2,(A0)+
		 SWAP	D2
		 ADDQ.L	#4,a1
		ENDR
		DBF	D3,.Feedbackloop2
		DBF	D0,.Feedbackloop1
		RTS

