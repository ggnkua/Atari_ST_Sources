* MEGA RASTERS (UGLY RASTERS!) ROUTINE BY POWERMAN OF TWB
* (C) THE WILD BOYS, 10/6/91

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

MAIN		MOVE.L #VBL_ROUT,$70.W
.WAIT		CMPI.B #57,$FFFFFC02.W	      Space?
		BNE .WAIT
		RTS
		
VBL_ROUT     	CLR.B $FFFFFA1B.W             Stop timer B
	        MOVE.B #2,$FFFFFA21.W         Occur on every second scanline
	        MOVE.B #8,$FFFFFA1B.W         Start timer B
	        MOVE.L #TIMER_B,$120.W        Timer B routine
	        MOVE.W PALETTE,$FFFF8240.W    Set colour for colour 0
	        MOVE.L #PALETTE+2,POINTER     Initialise pointer in colour table
	        RTE                           End VBL interrupt

TIMER_B  	MOVE.L A0,-(A7)               Save A0
         	MOVE.L POINTER,A0             A0=address of next colour for colour 0
         	MOVE.W (A0)+,$FFFF8240.W      New colour 0
         	MOVE.L A0,POINTER             Save address of next colour 0
         	MOVE.L (A7)+,A0               Restore A0
         	BCLR #0,$FFFFFA0F.W     
         	RTE

POINTER  	DS.L 1
PALETTE  	DC.W $700,$710,$720,$730,$740,$750,$760,$770,$771,$772
		DC.W $773,$774,$775,$776,$777,$677,$577,$477,$377,$277
		DC.W $177,$077,$067,$057,$047,$037,$027,$017,$007,$107
		DC.W $207,$307,$407,$507,$607,$707,$717,$727,$737,$747
		DC.W $757,$767,$777,$676,$575,$474,$373,$272,$171,$070
		DC.W $700,$710,$720,$730,$740,$750,$760,$770,$771,$772
		DC.W $773,$774,$775,$776,$777,$677,$577,$477,$377,$277
		DC.W $177,$077,$067,$057,$047,$037,$027,$017,$007,$107
		DC.W $207,$307,$407,$507,$607,$707,$717,$727,$737,$747
		DC.W $757,$767,$777,$676,$575,$474,$373,$272,$171,$070
		DC.W $070	;this colour is used in the bottom border

		INCLUDE INIT.S
