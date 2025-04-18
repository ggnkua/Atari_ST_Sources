*********************************************
* THE NEW FAST NON-BUFFERED SCROLL ROOTS    *
* WRITTEN FOR THE MINDBOMB MAIN MENU BY     *
* MANIKIN 20-11-89			    *
*********************************************

SCREEN1		EQU $70000

*********************************************

	CLR.L -(SP)			SET SUPERVISOR
	MOVE.W #$20,-(SP)
	TRAP #1
	ADD.L #6,SP

	MOVE.L #STRING,-(SP)		TURN OFF MOUSE/JOYSTICKS
	MOVE.W #1,-(SP)
	MOVE.W #25,-(SP)
	TRAP #14
	ADDQ.L #8,SP

	BSR SHIFTER			PRE SHIFT FONT
	BSR CLEARSCREEN			CLEARS THE SCREENS
	BSR PREDOSCROLL

	MOVE.L #$00000300,$FF8240	SET PALETTE
	MOVE.L #$04000510,$FF8244
	MOVE.L #$05200630,$FF8248
	MOVE.L #$06400750,$FF824C
	MOVE.L #SCREEN1,D0		SET PHYSBASE
	LSR.W #8,D0
	MOVE.L D0,$FF8200

LOOP1
	MOVE.W #37,-(SP)		WAIT FOR VBL
	TRAP #14
	ADD.L #2,SP

	BSR DO_SCROLL

	BRA.S LOOP1

WRAP
	CLR.W COUNT
	MOVE.L #SCROLLINE,SCROLLPOINT

**********************************
* THE SCROLL ROUTINES
*********************************

DO_SCROLL
	MOVE.W COUNT,D0
	ADDQ.W #1,D0
	CMP.W #4,D0
	BNE.S BYPASS
	CLR.W D0
	ADD.L #1,SCROLLPOINT
	MOVE.L SCROLLPOINT,A0
	MOVE.B 21(A0),D1
	CMP.B #$FF,D1
	BEQ WRAP
BYPASS
	MOVE.W D0,COUNT
	CMP.W #1,D0
	BEQ ROOT1
	CMP.W #2,D0
	BEQ ROOT2
	CMP.W #3,D0
	BEQ ROOT3

ROOT0
	LEA SCREEN1+16000,A0
	MOVE.L SCROLLPOINT,A1

	REPT 10
	MOVEQ #0,D0
	MOVE.B (A1)+,D0
	MULU #512,D0
	LEA FONT1,A2
	ADD.L D0,A2
	BSR ROOT0LOOP
	ENDR
	RTS

ROOT0LOOP
ADDIT	SET 0

	REPT 10	
	MOVEM.L (A2)+,D0-D7/A3-A6
	MOVEM.L D0-D3,ADDIT(A0)
	MOVEM.L D4-D7,ADDIT+160(A0)
	MOVEM.L A3-A6,ADDIT+320(A0)
ADDIT	SET ADDIT+480
	ENDR
	MOVEM.L (A2)+,D0-D7
	MOVEM.L D0-D3,ADDIT(A0)
	MOVEM.L D4-D7,ADDIT+160(A0)
	LEA 16(A0),A0
	RTS

ROOT1
	MOVEQ #0,D0
	LEA SCREEN1+16000,A0
	MOVE.L SCROLLPOINT,A1

	MOVE.B (A1)+,D0
	MULU #768,D0
	LEA FONT2,A2
	ADD.L D0,A2
ADDIT	SET 0
	REPT 32
	LEA 8(A2),A2
	MOVEM.L (A2)+,D0-D3
	MOVEM.L D0-D3,ADDIT(A0)
ADDIT	SET ADDIT+160
	ENDR
	LEA 8(A0),A0

	REPT 9
	MOVEQ #0,D0
	MOVE.B (A1)+,D0
	MULU #768,D0
	LEA FONT2,A2
	ADD.L D0,A2
	BSR ROOT1LOOP
	ENDR

	MOVEQ #0,D0
	MOVE.B (A1)+,D0
	MULU #768,D0
	LEA FONT2,A2
	ADD.L D0,A2
ADDIT	SET 0
	REPT 32	
	MOVE.L (A2)+,D0
	MOVE.L (A2)+,D1
	OR.L D0,ADDIT(A0)	
	OR.L D1,ADDIT+4(A0)
	LEA 16(A2),A2
ADDIT	SET ADDIT+160
	ENDR

	RTS

ROOT1LOOP
ADDIT	SET 0

	REPT 16	
	MOVEM.L (A2)+,D0-D7/A3-A6
	OR.L D0,ADDIT(A0)	
	OR.L D1,ADDIT+4(A0)
	MOVEM.L D2-D5,ADDIT+8(A0)
	OR.L D6,ADDIT+160(A0)	
	OR.L D7,ADDIT+164(A0)
	MOVEM.L A3-A6,ADDIT+168(A0)
ADDIT	SET ADDIT+320
	ENDR
	LEA 16(A0),A0

	RTS

ROOT2
	MOVEQ #0,D0
	LEA SCREEN1+16000,A0
	MOVE.L SCROLLPOINT,A1

	MOVE.B (A1)+,D0
	MULU #512,D0
	LEA FONT1,A2
	ADD.L D0,A2
ADDIT	SET 0
	REPT 32	
	LEA 8(A2),A2
	MOVE.L (A2)+,ADDIT(A0)
	MOVE.L (A2)+,ADDIT+4(A0)
ADDIT	SET ADDIT+160
	ENDR
	LEA 8(A0),A0

	REPT 9
	MOVEQ #0,D0
	MOVE.B (A1)+,D0
	MULU #512,D0
	LEA FONT1,A2
	ADD.L D0,A2
	BSR ROOT0LOOP
	ENDR

	MOVEQ #0,D0
	MOVE.B (A1)+,D0
	MULU #512,D0
	LEA FONT1,A2
	ADD.L D0,A2
ADDIT	SET 0
	REPT 32	
	MOVE.L (A2)+,ADDIT(A0)
	MOVE.L (A2)+,ADDIT+4(A0)
	LEA 8(A2),A2

ADDIT	SET ADDIT+160
	ENDR

	RTS

ROOT3
	MOVEQ #0,D0
	LEA SCREEN1+16000,A0
	MOVE.L SCROLLPOINT,A1

	MOVE.B (A1)+,D0
	MULU #768,D0
	LEA FONT2,A2
	ADD.L D0,A2
ADDIT	SET 0

	REPT 32
	LEA 16(A2),A2
	MOVE.L (A2)+,ADDIT(A0)
	MOVE.L (A2)+,ADDIT+4(A0)
ADDIT	SET ADDIT+160
	ENDR

	REPT 9
	MOVEQ #0,D0
	MOVE.B (A1)+,D0
	MULU #768,D0
	LEA FONT2,A2
	ADD.L D0,A2
	BSR ROOT1LOOP
	ENDR

	MOVEQ #0,D0
	MOVE.B (A1)+,D0
	MULU #768,D0
	LEA FONT2,A2
	ADD.L D0,A2
ADDIT	SET 0
	REPT 32	
	MOVEM.L (A2)+,D0-D3
	OR.L D0,ADDIT(A0)	
	OR.L D1,ADDIT+4(A0)
	MOVE.L D2,ADDIT+8(A0)
	MOVE.L D3,ADDIT+12(A0)
	LEA 8(A2),A2
ADDIT	SET ADDIT+160
	ENDR

	RTS


************************************
* ROUTINE TO CLEAR SCREENS
************************************

CLEARSCREEN	
	LEA SCREEN1,A0
	MOVE.W #8000,D0
C_LOOP1
	CLR.L (A0)+
	DBF D0,C_LOOP1
	RTS


************************************
* ROUTINE TO PRE SHIFT THE FONT
***********************************

SHIFTER
	LEA FONT1,A0
	LEA FONT2,A1

	MOVE.W #1919,D0
LOOP
	MOVE.B (A0),1(A1)
	MOVE.B 1(A0),8(A1)
	MOVE.B 2(A0),3(A1)
	MOVE.B 3(A0),10(A1)
	MOVE.B 4(A0),5(A1)
	MOVE.B 5(A0),12(A1)
	MOVE.B 6(A0),7(A1)
	MOVE.B 7(A0),14(A1)

	MOVE.B 8(A0),9(A1)
	MOVE.B 9(A0),16(A1)
	MOVE.B 10(A0),11(A1)
	MOVE.B 11(A0),18(A1)
	MOVE.B 12(A0),13(A1)
	MOVE.B 13(A0),20(A1)
	MOVE.B 14(A0),15(A1)
	MOVE.B 15(A0),24(A1)
	LEA 24(A1),A1
	LEA 16(A0),A0
	DBF D0,LOOP

	RTS

PREDOSCROLL
	LEA SCROLLINE,A0
SLOOP
	MOVE.B (A0),D0
	CMP.B #$FF,D0
	BEQ.S ENDIT
	SUB.B #32,D0
	MOVE.B D0,(A0)+
	BRA.S SLOOP
ENDIT
	RTS

***********************************
* THE SCROLLINE
**********************************

SCROLLINE
	DC.B "  THIS IS THE NEW 4 PLANE SCROLL ROUTINE BY THE LOST BOYS (##)"
	DC.B "FEATURING THE NEW MEGADETH FONT BY SPAZ!! WE THINK THAT IT ISN'T "
	DC.B "POSSIBLE TO WRITE A SCROLL FASTER USING THIS TECHNIQUE????       ",$FF

	EVEN

SCROLLPOINT	DC.L SCROLLINE

***************************
* VARIABLES AND ALL SORTS OF OTHER SHIT
***************************

COUNT		DC.W -1
STRING		DC.B $12,$1A

********************************
* THE FONTS
******************************

FONT1	INCBIN "SCROLLIN.ES\MEGADETH.FON"
FONT2
