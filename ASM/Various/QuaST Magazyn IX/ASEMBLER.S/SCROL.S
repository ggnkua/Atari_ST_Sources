;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|				Scroll - scrollowanie tekstu przy pomocy blittera	  	  |
;|  																	  |
;| autor: Jao 								    				  		  |	
;| uwagi: -																  |
;*------------------------------------------------------------------------*

     	OPT W-,O+  
S:
		CLR.L 	-(SP)
		MOVE.W 	#$20,-(SP)
		TRAP 	#1
		ADDQ.L 	#6,SP
		MOVE.L 	$44E.W,$3F4.W
		MOVE.L 	#$B0000,D7
		MOVE.W 	#1,-(SP)
		MOVE.L 	D7,-(SP)
		MOVE.L 	D7,-(SP)
		MOVE.W 	#5,-(SP)
		TRAP 	#14
		ADD.L 	#12,SP
		MOVE.L 	$70.W,-(A7)
		MOVE.L 	#PRG,$70.W
ERT:
		CMP.L 	#$E00802,$70.W
		BNE.S 	ERT
		MOVE.L 	(A7)+,$70.W
		MOVE.L 	$3F4.W,D7
		MOVE.W 	#1,-(SP)
		MOVE.L 	D7,-(SP)
		MOVE.L 	D7,-(SP)
		MOVE.W 	#5,-(SP)
		TRAP 	#14
		ADD.L 	#12,SP
		CLR.W 	-(SP)
		TRAP 	#1

PRG:
		MOVEM.L D0-D7/A0-A6,-(A7)
	
		CMP.B 	#$39,$FFFFFC02.W
		BNE.S 	KKK
		MOVE.L 	#$E00802,$70.W
KKK:
		MOVE.L 	#BUFER+40,A0
		MOVE.L 	A0,A2
		MOVE.L 	$44E,A1
		MOVEQ 	#15,D0
RER:
		REPT 	10
		MOVE 	(A0),(A1)
		MOVE 	4(A0),4(A1)
		MOVE 	8(A0),8(A1)
		MOVE 	12(A0),12(A1)
		LEA 	$10(A0),A0
		LEA 	$10(A1),A1
		ENDR
		LEA 	$E6(A2),A2
		MOVE.L 	A2,A0
		DBF 	D0,RER
		TST.W 	COUNTX
		BNE 	EWPRZ
		MOVEQ 	#0,D0
		MOVE 	#10,COUNTX
		MOVE.L 	OFFTXT,A0
		TST.B 	(A0)
		BNE.S 	FRR
		LEA 	TEXT(PC),A0
FRR:
		MOVE.B 	(A0)+,D0
		MOVE.L 	A0,OFFTXT
		LEA 	FONT_D,A0
		LSL.W 	#4,D0
		ADD.L 	D0,A0
		MOVE.L 	#BUFER+(52*4),A1
		MOVE.B 	(A0)+,(A1)
		MOVE.B 	(A0)+,$E6(A1)
		MOVE.B 	(A0)+,$E6*2(A1)
		MOVE.B 	(A0)+,$E6*3(A1)
		MOVE.B 	(A0)+,$E6*4(A1)
		MOVE.B 	(A0)+,$E6*5(A1)
		MOVE.B 	(A0)+,$E6*6(A1)
		MOVE.B 	(A0)+,$E6*7(A1)
		MOVE.B 	(A0)+,$E6*8(A1)
		MOVE.B 	(A0)+,$E6*9(A1)
		MOVE.B 	(A0)+,$E6*10(A1)
		MOVE.B 	(A0)+,$E6*11(A1)
		MOVE.B 	(A0)+,$E6*12(A1)
		MOVE.B 	(A0)+,$E6*13(A1)
		MOVE.B 	(A0)+,$E6*14(A1)
		MOVE.B 	(A0),$E6*15(A1)
		MOVEQ 	#0,D0
		LEA 	1(A1),A1
		MOVE.B 	D0,(A1)
		MOVE.B 	D0,$E6(A1)
		MOVE.B 	D0,$E6*2(A1)
		MOVE.B 	D0,$E6*3(A1)
		MOVE.B 	D0,$E6*4(A1)
		MOVE.B 	D0,$E6*5(A1)
		MOVE.B 	D0,$E6*6(A1)
		MOVE.B 	D0,$E6*7(A1)
		MOVE.B 	D0,$E6*8(A1)
		MOVE.B 	D0,$E6*9(A1)
		MOVE.B 	D0,$E6*10(A1)
		MOVE.B 	D0,$E6*11(A1)
		MOVE.B 	D0,$E6*12(A1)
		MOVE.B 	D0,$E6*13(A1)
		MOVE.B 	D0,$E6*14(A1)
		MOVE.B 	D0,$E6*15(A1)
EWPRZ:	MOVE.L 	#$FFFCFFEA,$FFFF8A20.W
		MOVE.L 	#BUFER+($E6*15)+208,$FFFF8A24.W
		MOVE.L 	#BUFER+($E6*15)+208,$FFFF8A32.W
		MOVE.L 	#$FFFCFFEA,$FFFF8A2E.W
		MOVE.L 	#$00350010,$FFFF8A36.W
		MOVE.L 	#-1,$FFFF8A28.W
		MOVE.W 	#-1,$FFFF8A2C.W
		MOVE.L 	#$0203800E,$FFFF8A3A.W 
		SUBQ.W 	#2,COUNTX
		MOVEM.L (A7)+,D0-D7/A0-A6
		RTE
	
COUNTX:	DC.W 	8
OFFTXT: DC.L 	TEXT

TEXT:	DC.B 	'THIS DEMO IS LAST FOR EVER (C) 1992 SKOCZOW Jestem Jarek Parcha;ski Copyright 1992'
		DC.B 	"       ",0
		EVEN
FONT_D:	INCBIN 	"\asembler.s\dane.dat\STEK_16.FNT"
		DC.B 	"JAO0"
BUFER:	DS.B 	230*16

