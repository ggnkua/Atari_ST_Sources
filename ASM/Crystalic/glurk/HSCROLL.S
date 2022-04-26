	JSR	SETSUPER
	JSR	SETSCREEN
	JSR	COPYSCREENS
	JSR	INITHSCROLL
	JSR	INIT
MAINLOOP:
	JSR	WAITVBL

	LEA	SCR_DAT(PC),A1
	MOVE.W	(A6),$FF8264	scr pix
	MOVE.W	6(A6),$FF820E	resten

	LEA	X_SCT,A1	
	ADD.W	8(A6),A1		right x-scroll
	MOVE.W	(A1)+,(A6)		update scroll registers
	MOVE.L	(A1)+,2(A6)
	MOVE.W	(A1)+,6(A6)
	MOVE.L	10(A6),D0		+y-scroll
	ADD.L	D0,2(A6)

	MOVE.W	D6,8(A6)                 * xcord*8     - 145*8,8(A0)
	MOVE.L	D7,10(A6)		 * ycord*160*4 - 33*160*4,10(A0)

	MOVE.B	3(A6),$FF8201	high byte
	MOVE.B	4(A6),$FF8203	middle byte
	MOVE.B	5(A6),$FF820D	low byte

	CMP.B	#1,$FFFC02
	BNE	MAINLOOP
	ADD.W	#8,D6
	JMP	MAINLOOP
*******************************
SETSUPER:
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,SAVESUPER
	RTS
ENDSUPER:
	MOVE.L	SAVESUPER,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	RTS
*******************************
SETSCREEN:
	MOVE.W	#0,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.W	#$5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	RTS
*******************************
INIT:
	MOVE.L	$70,OLDVBL
	MOVE.L	#NEWVBL,$70
	RTS
RETINIT:
	MOVE.L	OLDVBL,$70
	RTS
*******************************
WAITVBL:
	CMP.W	#1,WFNC
	BNE.S	WAITVBL
	MOVE.W	#0,WFNC
	RTS
*******************************
COPYSCREENS:
	MOVE.L	#PIC+34,A0
	MOVE.L	#PIC2+34,A1
	MOVE.L	#PIC2+34,A2
	MOVE.L	#$78000,A6
	MOVE.W	#199,D0
COPYLOOP:
	REPT	40
	MOVE.L	(A0)+,(A6)+
	ENDR
	REPT	40
	MOVE.L	(A1)+,(A6)+
	ENDR
	REPT	40
	MOVE.L	(A2)+,(A6)+
	ENDR
	DBF.W	D0,COPYLOOP
	RTS
*******************************
*      HARDWARE SCROLLING     *
*******************************
INITHSCROLL:
	LEA	X_SCT,A6	
	MOVE.L	#$78000,D5		
	MOVE.W	#80-1,D4		width in words
S_2:
	MOVE.L	NRSCREENS,D2		rest of screen
	MOVE.W	#16-1,D0		
S_1:
	MOVE.W	D0,D1		get counter
	SUB.W	#16-1,D1		upside down
	NEG	D1
	MOVE.W	D1,(A6)+		save pixel
	CMP.W	#1,D1 		1 pixel?
	BNE	DD 
	SUB.W	#4,D2		
DD:
	MOVE.L	D5,(A6)+		save byte
	MOVE.W	D2,(A6)+
	DBF	D0,S_1
	ADD.L	#8,D5		scoll 16 pix
	DBF	D4,S_2

	MOVE.W	#0,8(A6)                 * xcord*8     - 145*8,8(A0)
	MOVE.L	#0,10(A6)		 * ycord*160*4 - 33*160*4,10(A0)

	MOVE.B	3(A6),$FF8201	high byte
	MOVE.B	4(A6),$FF8203	middle byte
	MOVE.B	5(A6),$FF820D	low byte
	RTS
*******************************
RETINITHSCROLL:
	MOVE.W	#0,$FF820C		reset scroll
	MOVE.W	#0,$FF820E
	MOVE.W	#0,$FF8264
	RTS
*******************************
NEWVBL:
	MOVE.W	#1,WFNC
	RTE
*******************************
SAVESUPER:	DC.L	0
OLDVBL:		DC.L	0
WFNC:		DC.L	0
		EVEN
NRSCREENS:	DC.L	2*80		* ANTAL SKŽRMAR-1 I BREDD
		EVEN
SCR_DAT:	
HSCROLL:	DC.W	0	
SCREEN:		DC.L	0	
LINEWID:	DC.W	80*3	
X_POS:		DC.W	0	
Y_POS:		DC.L	0
		EVEN
X_SCT:		DS.W	320*4*4
		EVEN
PIC:		INCBIN	B:\PARTPART.PI1
PIC2:		INCBIN	A:\32UNDER.PI1
		EVEN                                                           