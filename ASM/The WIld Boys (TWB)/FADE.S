***************************************************************************
* COLOUR FADE ROUTINES BY POWERMAN OF THE WILD BOYS, (C) TWB 1991         *
* CALL FADE_BLACK TO FADE ALL COLOURS TO BLACK                            *
* CALL FADE TO FADE ALL COLOURS TO A NEW PALETTE, MAKE SURE THAT          *
* A6=ADDRESS OF NEW PALETTE DATA.                                         *
* ON BOTH ROUTINES, D6=SPEED OF FADE (0=FASTEST)			  *
* DONT FORGET TO CREDIT ME IF YOU USE THESE ROUTS!                        *
***************************************************************************

FADE		; Note: A6=source address of new palette
		;       D6=Speed of fade (0,1,2 etc)
		MOVE.L $70.W,-(A7)
		MOVE.W SR,-(A7)
		MOVE.W #$2300,SR
		MOVE.L #FADE_VBL,$70.W
		MOVEQ.W #8-1,D0					
.L1		MOVEQ.W #16-1,D1			16 colours
		LEA $FFFF8240.W,A0
		MOVE.L A6,A5
.L2		MOVE.W (A0),D2
		ANDI.W #%0000011101110111,D2
		MOVE.W (A5)+,D7
		BSR FADE_D2_TO_D7
		MOVE.W D2,(A0)+
		DBF D1,.L2
		MOVE.W D6,D5
.L3		BSR WAIT_VBL
		DBF D5,.L3
		DBF D0,.L1	
		MOVE.W (A7)+,SR
		MOVE.L (A7)+,$70.W
		RTS

FADE_D2_TO_D7	MOVEM.L D0-D1,-(A7)
		MOVE.W D2,D3
		ANDI.W #$F,D2
		LSR.W #4,D3
		MOVE.W D3,D4
		ANDI.W #$F,D3
		LSR.W #4,D4			D2,D3,D4=R,G,B VALUES OF OLD COLOUR
		ANDI.W #$F,D4
		MOVE.W D7,D0
		ANDI.W #$F,D7
		LSR.W #4,D0
		MOVE.W D0,D1
		ANDI.W #$F,D0
		LSR.W #4,D1			D7,D0,D1=R,G,B VALUES OF NEW COLOUR
		ANDI.W #$F,D1

		CMP.W D2,D7
		BEQ .L2
		BLT .L1
		ADDQ.W #1,D2
		BRA .L2
.L1		SUBQ.W #1,D2	
.L2		CMP.W D3,D0
		BEQ .L22
		BLT .L11
		ADDQ.W #1,D3
		BRA .L22
.L11		SUBQ.W #1,D3	
.L22		CMP.W D4,D1
		BEQ .L222
		BLT .L111
		ADDQ.W #1,D4
		BRA .L222
.L111		SUBQ.W #1,D4	
.L222		LSL.W #4,D3
		LSL.W #8,D4
		OR.W D3,D2
		OR.W D4,D2		
		MOVEM.L (A7)+,D0-D1
		RTS		

FADE_BLACK	; Note: D6=Speed of fade
		MOVE.L $70.W,-(A7)
		MOVE.W SR,-(A7)
		MOVE.W #$2300,SR
		MOVE.L #FADE_VBL,$70.W
		MOVEQ.W #8-1,D0					
.L1		MOVEQ.W #16-1,D1			16 colours
		LEA $FFFF8240.W,A0
.L2		MOVE.W (A0),D2
		BSR FADE_D2
		MOVE.W D2,(A0)+
		DBF D1,.L2
		MOVE.W D6,D5
.L3		BSR WAIT_VBL
		DBF D5,.L3
		DBF D0,.L1	
		MOVE.W (A7)+,SR
		MOVE.L (A7)+,$70.W
		RTS

FADE_D2		MOVE.W D2,D3
		ANDI.W #$F,D2
		LSR.W #4,D3
		MOVE.W D3,D4
		ANDI.W #$F,D3
		LSR.W #4,D4			D2,D3,D4=R,G,B VALUES
		ANDI.W #$F,D4
		TST.W D2
		BEQ .L1
		SUBQ.W #1,D2
.L1		TST.W D3
		BEQ .L2
		SUBQ.W #1,D3
.L2		TST.W D4
		BEQ .L3
		SUBQ.W #1,D4
.L3		LSL.W #8,D4
		LSL.W #4,D3
		OR.W D4,D2
		OR.W D3,D2
		RTS
		
WAIT_VBL	CLR.B VBL_FLAG
.L1		TST.B VBL_FLAG
		BEQ .L1	
		RTS

VBL_FLAG	DS.W 1

FADE_VBL	ST VBL_FLAG	
		RTE