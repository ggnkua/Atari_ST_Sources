*******************************************
**	ROTATE STE PAL
*******************************************
ROTATE_PAL:	LEA PAL,A0
EN_TILL:	MOVE.W (A0)+,D0
		CMP.W #-1,D0
		BEQ.S SLUT_ROTERAT
		MOVE.W D0,D1
		MOVE.W D0,D2
		AND.W #$F,D0
		BTST #0,D0
		BEQ.S CLEARED1
		BSET #4,D0
CLEARED1:	LSR #1,D0
		AND.W #$F0,D1
		BTST #4,D1
		BEQ.S CLEARED2
		BCLR #4,D1
		BSET #8,D1
CLEARED2:	LSR #1,D1
		AND.W #$F00,D2
		BTST #8,D2
		BEQ.S CLEARED3
		BSET #12,D2
		BCLR #8,D2
CLEARED3:	LSR #1,D2
		OR.W D1,D0
		OR.W D2,D0
		MOVE.W D0,-2(A0)
		BRA.S EN_TILL
SLUT_ROTERAT:	RTS

PAL:	DC.W $000,$111,$222,$333,$444,$555,$666,$777,$888,$999
	DC.W $AAA,$BBB,$CCC,$DDD,$EEE,$FFF,
	DC.W -1
