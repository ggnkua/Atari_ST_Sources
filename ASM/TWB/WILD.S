***************************************************************************
* FULLSCREEN ROUTINE, CODED BY POWERMAN OF THE WILD BOYS		  *
* (C) THE WILD BOYS, 1991						  *
* Credit us if you use this source!  It doesn't work on the STE though.   *
* I know how to do an STE fullscreen (thanks Tony!) but I dont want to    *
* give away this information...tought shit....we're outta here, SEE YA!	  *
***************************************************************************

		CLR.L -(A7)
		MOVE.W #32,-(A7)
		TRAP #1
		ADDQ.L #6,A7

		CLR.W -(A7)
		PEA $70000
		PEA $70000
		MOVE.W #5,-(A7)
		TRAP #14
		LEA 12(A7),A7

		LEA $70000,A6
		MOVE.W #64000/4-1,D7
FILL		MOVE.W #17,-(A7)
		TRAP #14
		ADDQ.L #2,A7
		MOVE.L D0,(A6)+
		MOVE.L D0,(A6)+
		DBF D7,FILL

		LEA PALETTE,A0
		LEA $FFFF8240.W,A1
		REPT 8	
		MOVE.L (A0)+,(A1)+	
		ENDR

		MOVE.L $70.W,-(A7)
		MOVE.B #$12,$FFFFFC02.W
		MOVE.B $FFFFFA07.W,-(A7)
		MOVE.B $FFFFFA09.W,-(A7)
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.L #VBL,$70.W
WAIT_KEY	CMPI.B #57,$FFFFFC02.W
		BNE WAIT_KEY
		MOVE.W #$2700,SR
		MOVE.B (A7)+,$FFFFFA09.W
		MOVE.B (A7)+,$FFFFFA07.W
		MOVE.L (A7)+,$70.W
		MOVE.B #$8,$FFFFFC02.W
		CLR.W $FFFF8246.W
		MOVE.W #$777,$FFFF8240.W

		CLR.L -(A7)
		TRAP #1

PALETTE		DC.W 0,$700,$770,$070,$077,$007,$777,$740
		DC.W $363,$233,$373,$182,$772,$307,$764,$712

* Here comes the overscan bit.......

VBL		MOVE.W #$2700,SR
		LEA $FFFF8209.W,A0		Video counter low byte
		MOVEQ.W #16,D1
		MOVE.W #1432-1,D0
.L1		DBF D0,.L1
		CLR.W D0

		MOVE.B #0,$FFFF820A.W		open top border
		DCB.W 10,$4E71
		MOVE.B #2,$FFFF820A.W

.L2		MOVE.B (A0),D0
		BEQ.S .L2
		SUB.W D0,D1
		LSL.W D1,D1
		DCB.W 90,$4E71
		MOVEQ.W #0,D0			low res/60hz
		MOVEQ.W #2,D1			high res/50hz
		LEA $FFFF820A.W,A0		sync mode
		LEA $FFFF8260.W,A1		shift mode
		MOVE.W #227-1,D2
.L3		MOVE.B D1,(A1)		       high/low res for left border
		MOVE.B D0,(A1)
		DCB.W 89,$4E71
		MOVE.B D0,(A0)		       60/50hz for right border
		MOVE.B D1,(A0)	
		DCB.W 13,$4E71
		MOVE.B D1,(A1)		       high/low res again
		NOP
		MOVE.B D0,(A1)
		DCB.W 10,$4E71
		DBF D2,.L3
		
		MOVE.B D1,(A1)		 
		MOVE.B D0,(A1)
		DCB.W 88,$4E71
		MOVE.B D0,(A0)		 
		MOVE.B D1,(A0)	
		DCB.W 12,$4E71

		MOVE.B D0,(A0)			60hz for lower border
		MOVE.B D1,(A1)	
		NOP
		MOVE.B D0,(A1)
		
		MOVEQ.W #45-1,D2
		DCB.W 9,$4E71
		MOVE.B D1,(A0)			50hz

.L4		MOVE.B D1,(A1)		  
		MOVE.B D0,(A1)
		DCB.W 89,$4E71
		MOVE.B D0,(A0)		  
		MOVE.B D1,(A0)	
		DCB.W 13,$4E71
		MOVE.B D1,(A1)		  
		NOP
		MOVE.B D0,(A1)
		DCB.W 10,$4E71
		DBF D2,.L4
		RTE
