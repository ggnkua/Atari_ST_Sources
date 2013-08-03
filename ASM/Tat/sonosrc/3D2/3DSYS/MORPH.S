
	IFNE Morphing_Mode
Send_Morph:
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"M_I",(A0)
		MOVE.L	A5,A1
		bsr	.Send_Morph
		bsr	.Send_Morph

		MOVE.L	A6,A1
		bsr	.Send_Morph
		bsr	.Send_Morph
		rts

.Send_Morph:
		MOVE.L	(A1)+,D0		;must be less than
						;maximum_points
		 wait_transmit
		MOVE.L	D0,(A0)			;point count

		SUBQ.W	#1,D0			;(for dbf)
.mo_loop:
		 wait_transmit
		MOVE.L	(A1)+,(A0)
		 wait_transmit
		MOVE.L	(A1)+,(A0)
		 wait_transmit
		MOVE.L	(A1)+,(A0)
		DBF	D0,.mo_loop
		RTS

Morph_Init:
		move.l	morph_list,a5
		move.l	morph_list+4,a6
		bsr	send_morph

Morph_Object:
		bsr	Update_Morph
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"M_O",(A0)
		 wait_receive
		move.l	(a0),d0
		 wait_transmit
		MOVE.L	Morph_Data_1(PC),(A0)		;size
		RTS

Update_Morph:
		MOVE.L	Morph_Data_2,D0
		add.L	#64,D0
		AND.L	#$7FF,D0
		BEQ.S	.new_morph		;it's a new one..
.morph_back
		MOVE.L	D0,Morph_Data_2
		MOVE.W	(SineTable.l,d0.w*2),D0
		EXT.L	D0
		ASL.L	#8,D0
		;neg.l	d0			;??why neg??
		MOVE.L	D0,Morph_Data_1
		RTS

.new_morph:
		move.l	d0,-(a7)
		move.l	morph_list_ptr,a0
		move.l	(A0)+,a5		
		move.l	(A0)+,a6
		bsr	Send_Morph
		move.l	(a7)+,d0
		addq.l	#4,morph_list_ptr
		bra.s	.morph_back

morph_list_ptr	dc.l	morph_list+4
Morph_Data_1:	Dc.L	0
Morph_Data_2:	Dc.L	0

		endc
