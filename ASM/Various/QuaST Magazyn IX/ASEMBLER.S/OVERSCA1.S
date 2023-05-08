;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|				Overscan I - usuniecie dolnej i gornej ramki		  	  |
;|  																	  |
;| autor: Jao		    											      |
;| uwagi: Aby skorzystac z tej procedury, trzeba by z niej jeszcze duzo   |
;|        wyciac.														  |
;*------------------------------------------------------------------------*

START:
		CLR.L 	-(SP)
		MOVE.W 	#$20,-(SP)
		TRAP 	#1
		ADDQ.L 	#6,SP
		MOVE.L 	D0,$3FC.W
	
		MOVE.W 	#$2100,SR

		MOVE.L 	#$78000,D7
		MOVE.W 	#1,-(SP)
		MOVE.L 	D7,-(SP)
		MOVE.L 	D7,-(SP)
		MOVE.W 	#5,-(SP)
		TRAP 	#14
		ADD.L 	#12,SP

		MOVE.W 	#7,$fff825E
		MOVE.L 	#$78000,A0
		MOVE.L 	#$25000,A1
		MOVE 	#15999,D0
D:		MOVE.W 	#255,(A0)+
		DBF 	D0,D
		MOVE 	#10000,D0
		MOVE.L 	#$11000,A1
DD:		MOVE.W 	#255,(A0)+
		DBF 	D0,DD
		MOVE.W 	#$25,-(SP)
		TRAP 	#14
		ADDQ.L 	#2,SP
		MOVE.L 	#PRG2,$70.W
		BCLR 	#5,$fffFA15
		MOVE 	#0,$0452

		PEA 	OVERSCAN(PC)
		MOVE.W 	#$C6,-(SP)
		MOVE.W 	#8,-(SP)
		MOVE.W 	#1,-(SP)
		MOVE.W 	#$1F,-(SP)
		TRAP 	#14
		ADD.L 	#12,SP

KEY:	MOVE 	#7,-(SP)
		TRAP 	#1
		ADDQ.L 	#2,SP

		CMP.B 	#'1',D0
		BNE.S 	OK
		ADDQ.W 	#1,WAITUP-2
OK:
		CMP.B 	#32,D0
		BNE.S 	KEY

ERROR:	MOVE.W 	#8,-(SP)
		MOVE.W 	#$1A,-(SP)
		TRAP 	#14
		ADDQ.L 	#4,SP

		MOVE.L 	#$E00802,$70.W
		BSET 	#5,$FffA15
		MOVE 	#1,$0452.W

		MOVE.L 	#$F8000,D7
		MOVE.W 	#1,-(SP)
		MOVE.L 	D7,-(SP)
		MOVE.L 	D7,-(SP)
		MOVE.W 	#5,-(SP)
		TRAP 	#14
		ADD.L 	#12,SP
		MOVE.W 	WAITUP-2,$3F0.W
		
		MOVE.L 	$3FC.W,-(SP)
		MOVE 	#$20,-(SP)
		TRAP 	#1
		ADDQ.L 	#6,SP
		CLR.L 	-(SP)
		TRAP 	#1

OVERSCAN:
		MOVEM.L D0-D7/A0-A6,-(SP)
		LEA 	$fff8209,A0
		MOVE.B 	(A0),D7
WAIT:	SUB.B 	(A0),D7
		BEQ.S 	WAIT
		BCLR 	#0,$fffFA0F
		MOVEQ 	#14,D0
WVBL:	DBF 	D0,WVBL
		MOVEM.L (SP)+,D0-D7/A0-A6
		MOVE.B 	#0,$fff820A
		MOVE.B 	#0,$fff8260
		CMP.B 	(A0),D0
		CMP.B 	(A0),D0
		MOVE.B 	#2,$ffff820A
		RTE

PRG2:	MOVEM.L D0-D7/A0-A6,-(SP)
		MOVE.B 	#$01,$fff8260
		MOVE.B 	#$00,$fffFA1B
		MOVE.B 	#$E4,$ffFA21
		MOVE.B 	#$08,$ffFA1B
		MOVE.W 	#1403,D0
WAITUP:	DBF 	D0,WAITUP
		MOVEM.L (SP)+,D0-D7/A0-A6
		MOVE.B 	#0,$ff820A
		CLR.L 	WEKT
		CLR.L 	WEKT
		MOVE.B 	#2,$ff820A
		RTE

WEKT:	DC.L 0
