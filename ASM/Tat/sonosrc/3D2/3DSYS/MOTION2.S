	IFNE	Motion_Blur_Mode

MoveAndFade
		BSR	Init_DSP_Calc
		BSR	MotionBlurScreen
		BSR	Handle_Object_World
		BSR	screen_swap
		RTS

Handle_Object_Blur:
		MOVE.L	third,A0
		ADD.L	#192*2+BytesPerLine*(Lines/2),A0
		MOVE.L	A0,Screen_Centre
		MOVE.L	#$0019,D0
		MOVEC	D0,CACR

		LEA	$FFFFA206.W,A1
		LEA	$FFFFA202.W,A2
		MOVE.L	#BytesPerLine,D7
		MOVE.L	Screen_Centre,A4
		MOVEQ	#0,D0
		MOVEQ	#0,D2
.HandleLoop
		wait_transmit
		MOVE.L	#"GET",$FFFFA204.W
.wr2:
		wait_receive
		 MOVE.W	(A1),D0
		 BMI Done
		 JMP .polylist(PC,D0.W*4)
.polylist:
		BRA.W	.get_flat		;0
		BRA.W	.get_flat		;1
		BRA.W	.get_gouraud		;2
		BRA.W	.get_texmap		;3
.get_gouraud:
.get_flat:
		BRA	HandleLoop
; Routine does not appear to be getting *enough* data out
.get_texmap:
		 wait_receive
		 MOVE.W	(A1),D6			;get top_height
		 MULS.W	D7,D6
		 LEA	(A4,D6.L),A0
		 MOVE.W	(A1),D1
		 SUBQ.W	#1,D1
		 ;BMI.S	Dontdo
.printpoly:
		  wait_receive
		  MOVE.W (A1),D2
		  LEA (A0,D2.W*4),A3
		  MOVE.W (A1),D3
		  SUBQ.W #1,D3
		  BMI.S	.next
		  wait_receive
.PP	  	MOVE.W (A1),D0
		  ADD.W	D0,(A3)
		  ADDQ.L #4,A3
		  DBRA	D3,.PP
.next	  	ADD.L D7,A0
		 DBF	D1,.printpoly
.dontdo		BRA	.HandleLoop
.Done:
		RTS


;--------------------------------------------------------------

Send_Blur_Texmap:
		LEA	Texmap_Buffer,A0
		wait_transmit
		MOVE.L	#"TEX",$FFFFA204.W
		MOVE.L	#64*64,D0
		 wait_transmit
		MOVE.L	D0,$FFFFA204.W
		SUBQ.L	#1,D0
.SendPoints:
		 wait_transmit		; not time-critical!
		MOVE.W	(A0)+,D1
		LSR.W	#2,D1
		AND.W	#%0011100111100111,D1
		MOVE	D1,$FFFFA206.W
		DBF	D0,.SendPoints
		RTS

