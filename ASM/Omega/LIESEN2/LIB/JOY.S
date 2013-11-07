**************************************************
**	JOYSTICKS
**	RESULT IN JOY0 AND JOY1 (BOTH BYTE)
**	DON'T FORGET TO SAVE $118.W (ACIA IRQ ADDRESS)
**************************************************
***********************************************
**		JOY SETUP
***********************************************
JOYSETUP:	LEA	$FFFFFC00.W,A0	; JOYSTICK ON
WAITACIA:	BTST	#1,(A0)
		BEQ.S	WAITACIA
		MOVE.B	#$14,2(A0)
WAITACIA2:	BTST	#1,(A0)
		BEQ.S	WAITACIA2
		MOVE.B	#$12,2(A0)
		MOVE.L	#ACIA,$118.W
		BSET	#6,$FFFFFA09.W
		RTS
************************************************
**		ACIA RUTINE
************************************************
ACIA:		CMP.B	#$FE,$FFFFFC02.W
		BNE.S	TEST_JOY1
		MOVE.L	#JOYSTICK0,$118.W
TEST_JOY1:	CMP.B	#$FF,$FFFFFC02.W
		BNE.S	ALL_DONE
		MOVE.L	#JOYSTICK1,$118.W
ALL_DONE:	BCLR	#6,$FFFFFA11.W
		RTE
*************************************************
**		JOYSTICK 0
*************************************************
JOYSTICK0:	MOVE.B	$FFFFFC02.W,JOY0
		MOVE.L	#ACIA,$118.W
		BCLR	#6,$FFFFFA11.W
		RTE
*************************************************
**		JOYSTICK 1
*************************************************
JOYSTICK1:	MOVE.B	$FFFFFC02.W,JOY1
		MOVE.L	#ACIA,$118.W
		BCLR	#6,$FFFFFA11.W
		RTE
*************************************************
**		DATA
*************************************************
JOY0:		DC.B 0		; BIT 0-3 JOYSTICK DIRECTION
JOY1:		DC.B 0		; BIT 0-3 JOYSTICK DIRECTION
