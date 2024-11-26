* MEGA BORDERS ROUTINE BY POWERMAN OF TWB, (C) THE WILD BOYS 10/6/91

SCREEN		EQU $78000
		
		JSR SUPER
		MOVE.L #SCREEN,SCR1
		MOVE.L #SCREEN,SCR2
		JSR INIT
		JSR MAIN
		JSR END
		JSR USER
		CLR.L -(A7)
		TRAP #1

MAIN		BSR FILL_SCREEN	
		MOVE.L #VBL_ROUT,$70.W
.WAIT		CMPI.B #57,$FFFFFC02.W	      	Space?
		BNE .WAIT
		RTS

FILL_SCREEN	LEA SCREEN,A0
		MOVE.W #(274*20)-1,D0		274 SCANLINES!
		MOVE.W #%1000000010000000,D1	
		SWAP D1
		MOVE.W #%1000000010000000,D1	
.FILL		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,.FILL
		MOVE.W #$777,$FFFF8240+(2*15).W	
		CLR.W $FFFF8240.W		
		RTS

VBL_ROUT	MOVE.W #$2700,SR                   16 CYCLES
  	        CLR.B $FFFFFA1B.W                  16 CYCLES
         	MOVE.W #1429-1,D0                  8 CYCLES
.WAIT     	DBF D0,.WAIT                       12 CYCLES (10 WHEN D0=-1)
         	DCB.W 8,$4E71                      8 NOPS=32 CYCLES
         	CLR.B $FFFF820A.W                  60 HZ
         	DCB.W 10,$4E71                     10 NOPS=40 CYCLES
        	MOVE.B #2,$FFFF820A.W              50 HZ
         	MOVE.B #228,$FFFFFA21.W
         	MOVE.B #8,$FFFFFA1B.W              START TIMER B
         	MOVE.L #TIMER_B,$120.W
         	RTE

TIMER_B  	CLR.B $FFFFFA1B.W
         	MOVEM.L A0/D0,-(A7)
         	MOVE.W #$FA21,A0                   A0=TIMER B DATA REGISTER
         	MOVE.B #200,(A0)
         	MOVE.B #8,$FFFFFA1B.W
         	MOVE.B (A0),D0
.WAIT    	CMP.B (A0),D0                      SCANLINE DRAWN?
         	BEQ .WAIT
         	CLR.B $FFFF820A.W                  60 HZ
         	MOVEQ.W #3,D0
.WAIT2   	NOP                                WAIT A WHILE
         	DBF D0,.WAIT2
         	MOVE.B #2,$FFFF820A.W              50 HZ
         	MOVEM.L (A7)+,A0/D0
         	BCLR #0,$FFFFFA0F.W
         	RTE
			
		INCLUDE INIT.S
