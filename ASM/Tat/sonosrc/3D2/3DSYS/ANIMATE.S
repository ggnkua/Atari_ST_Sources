	IFNE Animation_Mode

Animate_Data_1 = sequence_misc_data+inside_anim_size

Animate_Init:
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"A_I",(A0)
		MOVE.L	#384,D0			;must be less than
						;maximum_points
		MOVEQ	#0,D1
		 wait_transmit
		MOVE.L	D0,(A0)			;point count

		MULU.W	#3,D0			;x,y,z
		SUBQ.W	#1,D0			;(for dbf)
.ai_loop:
		 wait_transmit
		MOVE.L	D1,(A0)
		ADDQ.L	#1,D1
		CMP.L	#11,D1
		BLT.S	.no
		MOVEQ	#-11,D1
.no:		DBF	D0,.ai_loop
		RTS

Animate_Object:
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"A_O",(A0)
		 wait_transmit
		MOVE.L	Animate_Data_1(PC),(A0)		;size
		RTS

	ENDC

