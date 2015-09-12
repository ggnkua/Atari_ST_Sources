;--------------------------------------------------------------------------------
;
; Cube Demo
;
; For Inner Circle Genetix Demo
;
; Last Update : 4/4/91
;
; Code	: Oberje'
;	  ( Except Stars Routine by Griff )
; Gfx	: Pixar
; Music	: Count Zero
;
;
; Early stages yet but it'll look okay in the end! - I hope!
; 5/4/91 : Rewritten some of cube display routine. Now addresses
; for cubes are worked out first then a jump is made to a block
; of code to draw them. This eliminates all the testing and jumping
; in the previous method. 
; 6/4/91. Added code to deal with edges and clearing with new
; code. On the test message 'M's the new method saves about 25-30
; raster lines ( 8-9% - maybe more? ). So despite the program size 
; increase I think I will keep it!
;
; Current memory use :
;   Program & Normal Storage	: 100k
;   Screens ( 2 of 32k )	:  64k
;   Precalc Stars		:  65k
;			  _______
;   Total			: 229k
;			  _______
;
; NB. Scrolltext will NOT contain fully capitalised words, at all!
; I want a little processor time left! okay!
;
; CONVERTED TO PDS FORMAT : 29 JUNE '92
;
; CONVERTED BACK TO DEVPAC FORMAT : 20 AGUST '97
;
;--------------------------------------------------------------------------------
; 2009/01/26	AJB		Verified buildable under Devpac 3
;						Verfied working under Steem 3.2
;						Config: 8MHz 1Mb TOS 1.04
;--------------------------------------------------------------------------------

TIMING		EQU	0	; 1 FOR TIMING BARS
DESK		EQU	1	; 1 FOR DESKTOP OPERATION
PDS			EQU	0	; 1 FOR PDS OPERATION.  
BLIPS		EQU	1	; 1 FOR MUSIC
STEP		EQU	0	; 1 FOR SINGLE STEP MODE
GRIFF		EQU	1	; 1 FOR GRIFFS STARS

	IFNE PDS
	OPTIMISE $BFFF	; REQUIRED!!!!!
	ENDC

	ifeq PDS
	opt	P=68000
	;opt NOCASE
	;opt O+
	;opt OW-
	endc	

TIMER_CONST	EQU	4	; FRAMES-1 FOR ANIMATION
NO_STRS		EQU 	131	; 324/176/131 STARS

BAR	MACRO
	IFNE	TIMING
	MOVE.W	#$\1,$FFFF8240.W
	ENDC
	ENDM

DEBUG	MACRO
	LEA	(PC),A0
	MOVE.W	#$2700,SR
	JMP	$140
	ENDM

WAVELEN		EQU	21
	
;--------------------------------------------------------------------------------
; MACROS
;--------------------------------------------------------------------------------
LEFT_SIDE	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D1,8+$A0*0(A3)
		OR.L	D3,8+$A0*1(A3)
		OR.L	D5,8+$A0*2(A3)
		OR.L	D7,8+$A0*3(A3)
		ENDM
LEFT_SIDE_2	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D1,8+$A0*4(A3)
		OR.L	D3,8+$A0*5(A3)
		OR.L	D5,8+$A0*6(A3)
		OR.L	D7,8+$A0*7(A3)
		ENDM
LEFT_SIDE_3	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D1,8+$A0*8(A3)
		OR.L	D3,8+$A0*9(A3)
		OR.L	D5,8+$A0*10(A3)
		OR.L	D7,8+$A0*11(A3)
		ENDM
LEFT_SIDE_4	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D1,8+$A0*12(A3)
		OR.L	D3,8+$A0*13(A3)
		OR.L	D5,8+$A0*14(A3)
		OR.L	D7,8+$A0*15(A3)
		ENDM
		
RIGHT_SIDE	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D0,$A0*0(A3)
		OR.L	D2,$A0*1(A3)
		OR.L	D4,$A0*2(A3)
		OR.L	D6,$A0*3(A3)
		ENDM
RIGHT_SIDE_2	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D0,$A0*4(A3)
		OR.L	D2,$A0*5(A3)
		OR.L	D4,$A0*6(A3)
		OR.L	D6,$A0*7(A3)
		ENDM
RIGHT_SIDE_3	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D0,$A0*8(A3)
		OR.L	D2,$A0*9(A3)
		OR.L	D4,$A0*10(A3)
		OR.L	D6,$A0*11(A3)
		ENDM
RIGHT_SIDE_4	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D0,$A0*12(A3)
		OR.L	D2,$A0*13(A3)
		OR.L	D4,$A0*14(A3)
		OR.L	D6,$A0*15(A3)
		ENDM

MIDDLE_SIDE	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D0,$A0*0(A3)
		OR.L	D2,$A0*1(A3)
		OR.L	D4,$A0*2(A3)
		OR.L	D6,$A0*3(A3)
		OR.L	D1,8+$A0*0(A3)
		OR.L	D3,8+$A0*1(A3)
		OR.L	D5,8+$A0*2(A3)
		OR.L	D7,8+$A0*3(A3)
		ENDM
MIDDLE_SIDE_2	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D0,$A0*4(A3)
		OR.L	D2,$A0*5(A3)
		OR.L	D4,$A0*6(A3)
		OR.L	D6,$A0*7(A3)
		OR.L	D1,8+$A0*4(A3)
		OR.L	D3,8+$A0*5(A3)
		OR.L	D5,8+$A0*6(A3)
		OR.L	D7,8+$A0*7(A3)
		ENDM
MIDDLE_SIDE_3	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D0,$A0*8(A3)
		OR.L	D2,$A0*9(A3)
		OR.L	D4,$A0*10(A3)
		OR.L	D6,$A0*11(A3)
		OR.L	D1,8+$A0*8(A3)
		OR.L	D3,8+$A0*9(A3)
		OR.L	D5,8+$A0*10(A3)
		OR.L	D7,8+$A0*11(A3)
		ENDM
MIDDLE_SIDE_4	MACRO
		MOVE.L	(A2)+,A3
		OR.L	D0,$A0*12(A3)
		OR.L	D2,$A0*13(A3)
		OR.L	D4,$A0*14(A3)
		OR.L	D6,$A0*15(A3)
		OR.L	D1,8+$A0*12(A3)
		OR.L	D3,8+$A0*13(A3)
		OR.L	D5,8+$A0*14(A3)
		OR.L	D7,8+$A0*15(A3)
		ENDM
		
LEFT_CLEAR	MACRO
		MOVE.L	(A2)+,A3
		MOVE.L	D0,8+$A0*0(A3)
		MOVE.L	D0,8+$A0*1(A3)
		MOVE.L	D0,8+$A0*2(A3)
		MOVE.L	D0,8+$A0*3(A3)
		MOVE.L	D0,8+$A0*4(A3)
		MOVE.L	D0,8+$A0*5(A3)
		MOVE.L	D0,8+$A0*6(A3)
		MOVE.L	D0,8+$A0*7(A3)
		MOVE.L	D0,8+$A0*8(A3)
		MOVE.L	D0,8+$A0*9(A3)
		MOVE.L	D0,8+$A0*10(A3)
		MOVE.L	D0,8+$A0*11(A3)
		MOVE.L	D0,8+$A0*12(A3)
		MOVE.L	D0,8+$A0*13(A3)
		MOVE.L	D0,8+$A0*14(A3)
		MOVE.L	D0,8+$A0*15(A3)
		ENDM

RIGHT_CLEAR	MACRO
		MOVE.L	(A2)+,A3
		MOVE.L	D0,$A0*0(A3)
		MOVE.L	D0,$A0*1(A3)
		MOVE.L	D0,$A0*2(A3)
		MOVE.L	D0,$A0*3(A3)
		MOVE.L	D0,$A0*4(A3)
		MOVE.L	D0,$A0*5(A3)
		MOVE.L	D0,$A0*6(A3)
		MOVE.L	D0,$A0*7(A3)
		MOVE.L	D0,$A0*8(A3)
		MOVE.L	D0,$A0*9(A3)
		MOVE.L	D0,$A0*10(A3)
		MOVE.L	D0,$A0*11(A3)
		MOVE.L	D0,$A0*12(A3)
		MOVE.L	D0,$A0*13(A3)
		MOVE.L	D0,$A0*14(A3)
		MOVE.L	D0,$A0*15(A3)
		ENDM

MIDDLE_CLEAR	MACRO
		MOVE.L	(A2)+,A3
		MOVE.L	D0,8+$A0*0(A3)
		MOVE.L	D0,8+$A0*1(A3)
		MOVE.L	D0,8+$A0*2(A3)
		MOVE.L	D0,8+$A0*3(A3)
		MOVE.L	D0,8+$A0*4(A3)
		MOVE.L	D0,8+$A0*5(A3)
		MOVE.L	D0,8+$A0*6(A3)
		MOVE.L	D0,8+$A0*7(A3)
		MOVE.L	D0,8+$A0*8(A3)
		MOVE.L	D0,8+$A0*9(A3)
		MOVE.L	D0,8+$A0*10(A3)
		MOVE.L	D0,8+$A0*11(A3)
		MOVE.L	D0,8+$A0*12(A3)
		MOVE.L	D0,8+$A0*13(A3)
		MOVE.L	D0,8+$A0*14(A3)
		MOVE.L	D0,8+$A0*15(A3)
		MOVE.L	D0,$A0*0(A3)
		MOVE.L	D0,$A0*1(A3)
		MOVE.L	D0,$A0*2(A3)
		MOVE.L	D0,$A0*3(A3)
		MOVE.L	D0,$A0*4(A3)
		MOVE.L	D0,$A0*5(A3)
		MOVE.L	D0,$A0*6(A3)
		MOVE.L	D0,$A0*7(A3)
		MOVE.L	D0,$A0*8(A3)
		MOVE.L	D0,$A0*9(A3)
		MOVE.L	D0,$A0*10(A3)
		MOVE.L	D0,$A0*11(A3)
		MOVE.L	D0,$A0*12(A3)
		MOVE.L	D0,$A0*13(A3)
		MOVE.L	D0,$A0*14(A3)
		MOVE.L	D0,$A0*15(A3)
		ENDM

		
;--------------------------------------------------------------------------------
; TEST CODE
;--------------------------------------------------------------------------------

	IFNE	PDS
	ORG	$1000
	OPT	P+
	OPT	D+
	ENDC

X:	JMP	START

;
; NEW VBL ROUTINE
;
NEW_VBL:
	MOVEM.L	D0-D7/A0-A7,-(A7)
	ADDQ.L	#1,$466.W

	IFNE	BLIPS
	 JSR	MUSIC+6
	ENDC

	MOVEM.L	(A7)+,D0-D7/A0-A7
	RTE

	IFNE	DESK
OLD_STACK:	DS.L	1
OLD_SCREEN:	DS.L	1
OLD_RES:	DS.W	1
	ENDC

;-----------------------------------------------------------------------------
;
; PROGRAM CODE
;	
;-----------------------------------------------------------------------------
START:
	IFNE	DESK
	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,OLD_STACK
	MOVE.W	#4,-(A7)
	TRAP	#14
	ADDQ.L	#2,A7
	MOVE.W	D0,OLD_RES
	MOVE.W	#2,-(A7)
	TRAP	#14
	ADDQ.L	#2,A7
	MOVE.L	D0,OLD_SCREEN
	MOVE.W	#0,-(A7)
	PEA	-1
	PEA	-1
	MOVE.W	#5,-(A7)
	TRAP	#14
	LEA	12(A7),A7
	ENDC
	
	IFNE	BLIPS
	MOVEQ	#1,D0
	JSR	MUSIC
	ENDC

	MOVE.L	#MY_STACK,A7	; SET STACK

	JSR	SET_UP_SCREENS
	JSR	MAKE_A_CHAR_SET
	JSR	CREATE_SPRITE_DATA
	JSR	START_ANIMATION
	JSR	START_SCROLLER
	JSR	CREATE_WAVE_DATA
	JSR	SET_INTERRUPTS
	IFNE	GRIFF
	 JSR	GENSTARS
	ENDC	
	JSR	CREATE_JUMP_TABLE
	JSR	DUMMY_CUBE_TABLE

LOOP:	BSR	SWAP_SCREENS
	JSR	DO_ANIMATE
	BAR	000
	JSR	SCROLLER
	BAR	333
	IFNE	GRIFF
	 JSR 	CLEARSTARS
	 BAR	000
	 JSR 	PLOTSTARS
	 BAR	333
	ENDC

	IFNE	STEP
.WAIT	BTST.B	#0,$FFFFFC00.W
	BEQ.S	.WAIT
	MOVE.B	$FFFFFC02.W,D0
	BRA	LOOP
	ENDC

	BTST.B	#0,$FFFFFC00.W
	BEQ.S	LOOP
	MOVE.B	$FFFFFC02.W,D0
	CMP.W	#$39,D0
	BNE.S	LOOP
	
	BSR	FLUSH		; FLUSH KEYBOARD
	
	JSR	UNSET_INTERRUPTS
	JSR	SET_DOWN_SCREENS
	IFNE	BLIPS
	MOVEQ	#0,D0
	JSR	MUSIC
	ENDC
	
	IFNE	DESK
	MOVE.W	OLD_RES,-(A7)
	MOVE.L	OLD_SCREEN,-(A7)
	MOVE.L	(A7),-(A7)
	MOVE.W	#5,-(A7)
	TRAP	#14
	LEA	12(A7),A7
	MOVE.L	OLD_STACK,-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	CLR	-(A7)
	TRAP	#1
	ENDC

	IFNE	PDS
	MOVE.W	#$2700,SR
	JMP	$148.W
	ENDC

	RTS

FLUSH:	BTST.B	#0,$FFFFFC00.W
	BEQ.S	.EXIT
	MOVE.B	$FFFFFC02.W,D0	
	BRA.S	FLUSH
.EXIT	RTS

SET_INTERRUPTS:
	MOVE.W	#$2700,SR
	LEA	SAVE_MFP,A0
	MOVE.B	$FFFFFA07.W,(A0)+
	MOVE.B	$FFFFFA09.W,(A0)+
	MOVE.B	$FFFFFA13.W,(A0)+
	MOVE.B	$FFFFFA15.W,(A0)+
	MOVE.L	$70.W,(A0)+
	MOVE.L	$120.W,(A0)+
	
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W	
	MOVE.L	#NEW_VBL,$70.W
	MOVE.W	#$2300,SR
	RTS

UNSET_INTERRUPTS:
	MOVE.W	#$2700,SR
	LEA	SAVE_MFP,A0
	MOVE.B	(A0)+,$FFFFFA07.W
	MOVE.B	(A0)+,$FFFFFA09.W
	MOVE.B	(A0)+,$FFFFFA13.W
	MOVE.B	(A0)+,$FFFFFA15.W
	MOVE.L	(A0)+,$70.W
	MOVE.L	(A0)+,$120.W
	MOVE.W	#$2300,SR
	RTS

SAVE_MFP:
	DS.B	4
	DS.L	2
	
;--------------------------------------------------------------------------------
; ANIMATION CODE
;--------------------------------------------------------------------------------
TIMER_CLICK:	DS.W	1

DO_ANIMATE:
	SUB.W	#1,TIMER_CLICK
	BNE.S	.NO_GO
	JSR	ANIMATE
	MOVE.W	#TIMER_CONST,TIMER_CLICK	
.NO_GO
	RTS

;--------------------------------------------------------------------------------
; SCREEN SWAPPING
;--------------------------------------------------------------------------------
SWAP_SCREENS:
	MOVE.L	SCREEN_1,D0
	LSR.W	#8,D0
	MOVE.L	D0,$FFFF8200.W

	MOVE.L	$466.W,D0
WAIT:	CMP.L	$466.W,D0
 	BEQ.S	WAIT

	MOVE.L	SCREEN_2,D0
	MOVE.L	SCREEN_1,SCREEN_2
	MOVE.L	D0,SCREEN_1

	MOVE.L	SPRITES_1,D0
	MOVE.L	SPRITES_2,SPRITES_1
	MOVE.L	SPRITES_3,SPRITES_2
	MOVE.L	SPRITES_4,SPRITES_3
	MOVE.L	D0,SPRITES_4

	RTS
	
;-----------------------------------------------------------------------------
; CREATE TABLE OF CUBE ADDRESSES
;-----------------------------------------------------------------------------
CREATE_CUBE_TABLE:
	MOVE.L	SCREEN_1,A1		; SCREEN BASE
	MOVE.L	SPRITES_1,A2	; SPRITE OFFSETS
	LEA	SCROLL_DATA,A4	; SPRITE ON/OFF FLAGS
	MOVE.L	CUBE_TABLE,A5

	MOVE	#1*7,D1		; COUNTER
	MOVE.W	#7-1,D7
.LOOP2
	MOVE.W	(A4)+,D0		; ON/OFF?
	BEQ.S	.CONT2
	MOVE.W	(A2),D0		; ON = GET POS
	LEA	(A1,D0.W),A3	; ADDRESS
	MOVE.L	A3,(A5)+		; SAVE
	SUBQ.L	#1,D1		; COUNT
.CONT2
	LEA	2(A2),A2
	DBF	D7,.LOOP2
	LSL.W	#2,D1
	MOVE.W	D1,LEAP_2
	
	MOVE	#19*7,D1		; COUNTER
	MOVE.W	#(19*7)-1,D7
.LOOP
	MOVE.W	(A4)+,D0		; ON/OFF?
	BEQ.S	.CONT
	MOVE.W	(A2),D0		; ON = GET POS
	LEA	(A1,D0.W),A3	; ADDRESS
	MOVE.L	A3,(A5)+		; SAVE
	SUBQ.L	#1,D1		; COUNT
.CONT	
	LEA	2(A2),A2
	DBF	D7,.LOOP	
	LSL.W	#2,D1
	MOVE.W	D1,LEAP

	MOVE	#1*7,D1		; COUNTER
	MOVE.W	#7-1,D7
.LOOP3
	MOVE.W	(A4)+,D0	; ON/OFF?
	BEQ.S	.CONT3
	MOVE.W	(A2),D0		; ON = GET POS
	LEA	(A1,D0.W),A3	; ADDRESS
	MOVE.L	A3,(A5)+	; SAVE
	SUBQ.L	#1,D1		; COUNT
.CONT3
	LEA	2(A2),A2
	DBF	D7,.LOOP3
	LSL.W	#2,D1
	MOVE.W	D1,LEAP_3

	RTS

LEAP:			DC.W	19*7*4
LEAP_2:			DC.W	1*7*4
LEAP_3:			DC.W	1*7*4
OLD_LEAP:		DC.W	19*7*4
OLD_LEAP_2:		DC.W	1*7*4
OLD_LEAP_3:		DC.W	1*7*4

CUBE_TABLE_1:		DS.L	21*7
CUBE_TABLE_2:		DS.L	21*7
CUBE_TABLE:		DC.L	CUBE_TABLE_1
CUBE_TABLE_X:		DC.L	CUBE_TABLE_2
JUMP_TABLE:		DS.L	20*7
JUMP_TABLE_LEFT:	DS.L	8
JUMP_TABLE_RIGHT:	DS.L	8
JUMP_CLEAR_TABLE:	DS.L	20*7
JUMP_CLEAR_TABLE_LEFT:	DS.L	8
JUMP_CLEAR_TABLE_RIGHT:	DS.L	8

;--------------------------------------------------------------------------------
; NO PRIZES FOR GUESSING WHAT THIS DOES
;--------------------------------------------------------------------------------
CLEAR_BASTARD_SPRITES:
C_LEFT:	
	REPT	7
	LEFT_CLEAR
	ENDR
	LEA	JUMP_CLEAR_TABLE,A0
	MOVE.L	(A0,D1.W),A0
	JMP	(A0)
	
C_MID:	
	REPT	7*19
	MIDDLE_CLEAR
	ENDR
	LEA	JUMP_CLEAR_TABLE_RIGHT,A0
	MOVE.L	(A0,D3.W),A0
	JMP	(A0)

C_RIGHT:
	REPT	7
	RIGHT_CLEAR
	ENDR

	RTS

CLEAR_THE_FRIGGER:
	MOVEQ	#0,D0

	MOVE.L	CUBE_TABLE_X,A2
	MOVE.W	OLD_LEAP,D1
	MOVE.W	OLD_LEAP_2,D2
	MOVE.W	OLD_LEAP_3,D3
	MOVE.W	LEAP,OLD_LEAP
	MOVE.W	LEAP_2,OLD_LEAP_2
	MOVE.W	LEAP_3,OLD_LEAP_3

	LEA	JUMP_CLEAR_TABLE_LEFT,A0
	MOVE.L	(A0,D2.W),A0
	JMP	(A0)

;
; SET UP DUMMY CUBE TABLE
;
DUMMY_CUBE_TABLE:
	LEA	CUBE_TABLE_1,A0
	LEA	CUBE_TABLE_1,A1
	MOVE.L	SCREEN_1,D0
	MOVE.W	#21*7-1,D7
.LOOP
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	DBF	D7,.LOOP
	RTS

CREATE_JUMP_TABLE:
	LEA	JUMP_TABLE,A0
	LEA	DRAW_A_SLICE,A1
	MOVE.W	#21*7,D0
.LOOP
	MOVE.L	A1,(A0)+
	ADDA.L	#(L2-L1),A1	
	DBF	D0,.LOOP

	LEA	JUMP_TABLE_LEFT,A0
	LEA	DRAW_A_SLICE_LEFT,A1
	MOVE.W	#7,D0
.LOOP5
	MOVE.L	A1,(A0)+
	ADDA.L	#(N2-N1),A1	
	DBF	D0,.LOOP5

	LEA	JUMP_TABLE_RIGHT,A0
	LEA	DRAW_A_SLICE_RIGHT,A1
	MOVE.W	#7,D0
.LOOP6
	MOVE.L	A1,(A0)+
	ADDA.L	#(O2-O1),A1	
	DBF	D0,.LOOP6

	LEA	JUMP_CLEAR_TABLE,A0
	LEA	C_MID,A1
	MOVE.W	#21*7,D0
.LOOP_2
	MOVE.L	A1,(A0)+
	ADDA.L	#(K2-K1),A1	
	DBF	D0,.LOOP_2

	LEA	JUMP_CLEAR_TABLE_LEFT,A0
	LEA	C_LEFT,A1
	MOVE.W	#7,D0
.LOOP_3
	MOVE.L	A1,(A0)+
	ADDA.L	#(J2-J1),A1	
	DBF	D0,.LOOP_3

	LEA	JUMP_CLEAR_TABLE_RIGHT,A0
	LEA	C_RIGHT,A1
	MOVE.W	#7,D0
.LOOP_4
	MOVE.L	A1,(A0)+
	ADDA.L	#(G2-G1),A1	
	DBF	D0,.LOOP_4

	RTS

;--------------------------------------------------------------------------------
;
; DRAW A COMPLETE FRAME OF SCROLL, USING DATA POINTED TO BY 'sprite_data'
; PRINTED ACCORDING TO 'scroll_data' ( OFFSETS ) AND '{sprites_1}' 
; ( ON/OFF INFO )
;		
;--------------------------------------------------------------------------------
DRAW_THE_FRIGGER:
	MOVE.L	CUBE_TABLE,D0
	MOVE.L	CUBE_TABLE_X,CUBE_TABLE
	MOVE.L	D0,CUBE_TABLE_X

	JSR	CREATE_CUBE_TABLE

	LEA	JUMP_TABLE,A0
	LEA	JUMP_TABLE_LEFT,A4
	LEA	JUMP_TABLE_RIGHT,A5
	MOVE.W	LEAP,D0
	MOVE.L	(A0,D0.W),A0
	MOVE.W	LEAP_2,D0
	MOVE.L	(A4,D0.W),A4
	MOVE.W	LEAP_3,D0
	MOVE.L	(A5,D0.W),A5
	
	MOVE.L	SPRITE_DATA,A6

	MOVE.L	CUBE_TABLE,A2
	MOVEM.L	(A6)+,D0-D7	; GET SPRITE DATA
	JSR	(A4)		; LEFT
	JSR	(A0)		; MIDLE
	JSR	(A5)		; RIGHT
	LEA	$11AC(A0),A0
	LEA	$80(A4),A4
	LEA	$80(A5),A5

	MOVE.L	CUBE_TABLE,A2
	MOVEM.L	(A6)+,D0-D7	; GET SPRITE DATA
	JSR	(A4)
	JSR	(A0)		; DRAW IT!
	JSR	(A5)
	LEA	$11AC(A0),A0
	LEA	$80(A4),A4
	LEA	$80(A5),A5

	MOVE.L	CUBE_TABLE,A2
	MOVEM.L	(A6)+,D0-D7	; GET SPRITE DATA
	JSR	(A4)
	JSR	(A0)		; DRAW IT!
	JSR	(A5)
	LEA	$11AC(A0),A0
	LEA	$80(A4),A4
	LEA	$80(A5),A5

	MOVE.L	CUBE_TABLE,A2
	MOVEM.L	(A6)+,D0-D7		; GET SPRITE DATA
	JSR	(A4)
	JSR	(A0)		; DRAW IT!
	JSR	(A5)

	RTS
	
DRAW_A_SLICE:
	REPT	7*19
	MIDDLE_SIDE
	ENDR
	RTS
DRAW_A_SLICE2
	REPT	7*19
	MIDDLE_SIDE_2
	ENDR
	RTS
DRAW_A_SLICE3
	REPT	7*19
	MIDDLE_SIDE_3
	ENDR
	RTS
DRAW_A_SLICE4
	REPT	7*19
	MIDDLE_SIDE_4
	ENDR
	RTS

DRAW_A_SLICE_LEFT
	REPT	7
	LEFT_SIDE
	ENDR
	RTS
DRAW_A_SLICE2_LEFT
	REPT	7
	LEFT_SIDE_2
	ENDR
	RTS
DRAW_A_SLICE3_LEFT
	REPT	7
	LEFT_SIDE_3
	ENDR
	RTS
DRAW_A_SLICE4_LEFT
	REPT	7
	LEFT_SIDE_4
	ENDR
	RTS

DRAW_A_SLICE_RIGHT
	REPT	7
	RIGHT_SIDE
	ENDR
	RTS
DRAW_A_SLICE2_RIGHT
	REPT	7
	RIGHT_SIDE_2
	ENDR
	RTS
DRAW_A_SLICE3_RIGHT
	REPT	7
	RIGHT_SIDE_3
	ENDR
	RTS
DRAW_A_SLICE4_RIGHT
	REPT	7
	RIGHT_SIDE_4
	ENDR
	RTS

L1	MIDDLE_SIDE_2
L2

K1	MIDDLE_CLEAR
K2

J1	LEFT_CLEAR
J2

G1	RIGHT_CLEAR
G2

N1	LEFT_SIDE_2
N2

O1	RIGHT_SIDE_2
O2	


;--------------------------------------------------------------------------------
; TURN 8X8 CHAR SET INTO SOMETHING MORE USABLE
;--------------------------------------------------------------------------------
MAKE_A_CHAR_SET:
	LEA	CHAR_SET_IN+1,A0	; +1 TO ALIGN FONT ( THIS FONT ONLY )
	LEA	CHAR_SET_OUT,A1

	MOVE.W	#128-1,D7		; NO OF CHARS ( CAN CHANGE )
.N_CHAR	MOVE.W	#8-1,D6		; NO PIX WIDE ( CAN CHANGE )
.N_COL	LEA	(A0),A2
	MOVE.W	#7-1,D5		; NO PIX HIGH ( LEAVE!!! )
.N_ROW	MOVE.B	(A2),D0		; GET BYTE
	LSL.B	#1,D0		; GET MSB
	BCS.S	.SET
.CLEAR	MOVE.W	#0,(A1)+
	BRA.S	.OVER
.SET	MOVE.W	#1,(A1)+
.OVER	MOVE.B	D0,(A2)+
	DBF	D5,.N_ROW
	DBF	D6,.N_COL
	LEA	8(A0),A0
	DBF	D7,.N_CHAR
	RTS


;--------------------------------------------------------------------------------
;
; SOME SCROLLER CODE
;
;--------------------------------------------------------------------------------
SCROLLER:
	JMP	SCROLL_0
	
SCROLL_0:
	MOVE.L	CURRENT_SPRITE,D0
	MOVE.L	D0,SPRITE_DATA
	LEA	SCROLL_DATA-14,A4	
	BSR	CLEAR_THE_FRIGGER
	JSR	DRAW_THE_FRIGGER
	MOVE.L	#SCROLL_1,SCROLLER+2
	RTS
SCROLL_1:
	MOVE.L	CURRENT_SPRITE,D0
	ADD.L	#128,D0
	MOVE.L	D0,SPRITE_DATA
	LEA	SCROLL_DATA-14,A4	
	BSR	CLEAR_THE_FRIGGER
	JSR	DRAW_THE_FRIGGER
	MOVE.L	#SCROLL_2,SCROLLER+2
	RTS
SCROLL_2:
	MOVE.L	CURRENT_SPRITE,D0
	ADD.L	#256,D0
	MOVE.L	D0,SPRITE_DATA
	LEA	SCROLL_DATA,A4	
	BSR	CLEAR_THE_FRIGGER
	JSR	DRAW_THE_FRIGGER
	MOVE.L	#SCROLL_3,SCROLLER+2
	RTS
SCROLL_3:
	MOVE.L	CURRENT_SPRITE,D0
	ADD.L	#384,D0
	MOVE.L	D0,SPRITE_DATA
	LEA	SCROLL_DATA,A4	
	BSR	CLEAR_THE_FRIGGER
	JSR	DRAW_THE_FRIGGER
	BSR	SCROLL_BUFFER
	MOVE.L	#SCROLL_0,SCROLLER+2
	BSR	DRAW_CHARACTER_SLICE
	RTS
	
;-----------------------------------------------------------------------------
DRAW_CHARACTER_SLICE:
	MOVE.L	CURRENT_CHARACTER,A0
	LEA	SCROLL_DATA+14*20,A1
	MOVEM.W	(A0)+,D0-D6
	MOVEM.W	D0-D6,(A1)
	MOVE.L	A0,CURRENT_CHARACTER
	MOVE.B	SLICE,D0	; UPDATE THE SLICE
	ADDI.B	#1,D0
	ANDI.B	#%111,D0
	BEQ.S	FINISHED_THE_CHARACTER
	MOVE.B	D0,SLICE
	RTS
FINISHED_THE_CHARACTER:
	BSR	GET_CHARACTER
	RTS

START_SCROLLER:
	MOVE.L	#MESSAGE,MESSAGE_POINTER
GET_CHARACTER:
	MOVE.L	MESSAGE_POINTER,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BMI	START_SCROLLER
	MOVE.L	A0,MESSAGE_POINTER
	LEA	CHAR_SET_OUT,A0
	MULU	#112,D0
	LEA	(A0,D0.W),A0
	MOVE.L	A0,CURRENT_CHARACTER
	MOVE.W	#0,SLICE
	RTS	
	
MESSAGE_POINTER:	DC.L	0
CURRENT_CHARACTER:	DC.L	0
SLICE:			DC.W	0	

SCROLL_BUFFER:				; SCROLL THE BUFFER
	LEA	SCROLL_DATA,A0		; 22*7 = 154
	LEA	-14(A0),A1
	
	MOVEM.L	(A0)+,D0-D7/A2-A4		;11*2=22
	MOVEM.L	D0-D7/A2-A4,(A1)	
COUNT	SET	44
	MOVEM.L	(A0)+,D0-D7/A2-A4
	MOVEM.L	D0-D7/A2-A4,COUNT(A1)	
COUNT	SET 	44+COUNT
	MOVEM.L	(A0)+,D0-D7/A2-A4
	MOVEM.L	D0-D7/A2-A4,COUNT(A1)	
COUNT	SET 	44+COUNT
	MOVEM.L	(A0)+,D0-D7/A2-A4
	MOVEM.L	D0-D7/A2-A4,COUNT(A1)	
COUNT	SET 	44+COUNT
	MOVEM.L	(A0)+,D0-D7/A2-A4
	MOVEM.L	D0-D7/A2-A4,COUNT(A1)	
COUNT	SET 	44+COUNT
	MOVEM.L	(A0)+,D0-D7/A2-A4
	MOVEM.L	D0-D7/A2-A4,COUNT(A1)	
COUNT	SET 	44+COUNT
	MOVEM.L	(A0)+,D0-D7/A2-A4
	MOVEM.L	D0-D7/A2-A4,COUNT(A1)	
COUNT	SET 	44+COUNT
	RTS


CURRENT_SPRITE	DC.L	0
SPRITE_DATA	DC.L	0			; ____|XXXX
		;DC.L	DUMMY_PRESHIFT		; ___X|XXX_
		;DC.L	DUMMY_PRESHIFT+128	; __XX|XX__
		;DC.L	DUMMY_PRESHIFT+256	; _XXX|X___

		DS.W	7		; SO RUBOUTS WORK!
SCROLL_DATA:	DS.W	24*7

CHAR_SET_OUT:	DS.W	14*8*128


;--------------------------------------------------------------------------------
; CREATE A SINE WAVE FOR SCROLLER
;--------------------------------------------------------------------------------
CREATE_WAVE_DATA:
	LEA	WAVE_DATA,A6
	LEA	WAVE_LIST,A3
	LEA	WAVE_LIST1,A2
	LEA	WAVE_LIST2,A1
	LEA	WAVE_LIST3,A0
	MOVEQ	#-8,D1
	MOVE.W	#WAVELEN-1,D7
.LOOP
	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0
	MULU	#$A0,D0
	ADD.L	D1,D0	
	MOVE.W	D0,(A0)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A0)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A0)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A0)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A0)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A0)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A0)+

	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0
	MULU	#$A0,D0
	ADD.L	D1,D0	
	MOVE.W	D0,(A1)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A1)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A1)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A1)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A1)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A1)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A1)+

	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0
	MULU	#$A0,D0
	ADD.L	D1,D0	
	MOVE.W	D0,(A2)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A2)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A2)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A2)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A2)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A2)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A2)+

	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0
	MULU	#$A0,D0
	ADD.L	D1,D0	
	MOVE.W	D0,(A3)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A3)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A3)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A3)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A3)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A3)+
	ADDI.L	#$A0*20,D0
	MOVE.W	D0,(A3)+
	ADDQ.L	#8,D1	

	DBF	D7,.LOOP

	MOVE.L	#WAVE_LIST3,SPRITES_1
	MOVE.L	#WAVE_LIST,SPRITES_2
	MOVE.L	#WAVE_LIST1,SPRITES_3
	MOVE.L	#WAVE_LIST2,SPRITES_4

	RTS



WAVE_DATA:	INCBIN	TAB1.DAT
		INCBIN	TAB1.DAT

	EVEN	

WAVE_LIST:	DS.W	7*WAVELEN
WAVE_LIST1:	DS.W	7*WAVELEN
WAVE_LIST2:	DS.W	7*WAVELEN
WAVE_LIST3:	DS.W	7*WAVELEN

SPRITES_1:	DC.L	WAVE_LIST3
SPRITES_2:	DC.L	WAVE_LIST
SPRITES_3:	DC.L	WAVE_LIST1
SPRITES_4:	DC.L	WAVE_LIST2

;--------------------------------------------------------------------------------
; PRESHIFT A SPRITE
;--------------------------------------------------------------------------------
PRESHIFT_SPRITE:
	MOVE.W	#0,D7	
	MOVE.W	#4-1,D6
.NEXT_PRESHIFT
	LEA	(A2),A0

	MOVE.W	#16-1,D5
.NEXT_LINE
	MOVE.L	(A0),D0
	MOVE.W	4(A0),D0
	LSL.L	D7,D0
	MOVE.W	D0,4(A1)
	SWAP	D0
	MOVE.W	D0,(A1)
	MOVE.L	2(A0),D0
	MOVE.W	6(A0),D0
	LSL.L	D7,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	LEA	8(A0),A0
	LEA	8(A1),A1
	DBF	D5,.NEXT_LINE
	ADDQ.L	#4,D7
	DBF	D6,.NEXT_PRESHIFT

	RTS

;--------------------------------------------------------------------------------
; ANIMATION CODE
;--------------------------------------------------------------------------------
START_ANIMATION:
	MOVE.W	#TIMER_CONST,TIMER_CLICK	
RESTART_ANIMATION:
	MOVE.L	#ANIMATION_LIST,CURRENT_ANIMATION
ANIMATE:
	MOVE.L	CURRENT_ANIMATION,A0
	MOVE.L	(A0)+,D0
	BMI.S	RESTART_ANIMATION
	MOVE.L	D0,CURRENT_SPRITE
	MOVE.L	A0,CURRENT_ANIMATION
	RTS
	
			
CUBE_AREA:	DS.B	128*4*16
CUBE_0:	EQU	CUBE_AREA
CUBE_1:	EQU	CUBE_0+512
CUBE_2:	EQU	CUBE_1+512
CUBE_3:	EQU	CUBE_2+512
CUBE_4:	EQU	CUBE_3+512
CUBE_5:	EQU	CUBE_4+512
CUBE_6:	EQU	CUBE_5+512
CUBE_7:	EQU	CUBE_6+512
CUBE_8:	EQU	CUBE_7+512
CUBE_9:	EQU	CUBE_8+512
CUBE_10:	EQU	CUBE_9+512
CUBE_11:	EQU	CUBE_10+512
CUBE_12:	EQU	CUBE_11+512
CUBE_13:	EQU	CUBE_12+512
CUBE_14:	EQU	CUBE_13+512
CUBE_15:	EQU	CUBE_14+512

	EVEN

CURRENT_ANIMATION:	DS.L	1
ANIMATION_LIST:	DC.L	CUBE_0,CUBE_1,CUBE_2,CUBE_3
		DC.L	CUBE_4,CUBE_5,CUBE_6,CUBE_7
		DC.L	CUBE_8,CUBE_9,CUBE_10,CUBE_11
		DC.L	CUBE_12,CUBE_13,CUBE_14,CUBE_15
		DC.L	-1

;--------------------------------------------------------------------------------
; PRESHIFT ALL 16 SPRITES
;--------------------------------------------------------------------------------
CREATE_SPRITE_DATA:
	LEA	CUBE_AREA,A1
	LEA	CUBE_INCLUDE,A2
	MOVEQ	#16-1,D4
.LOOP:
	BSR	PRESHIFT_SPRITE
	LEA	128(A2),A2
	DBF	D4,.LOOP
	RTS

CUBE_INCLUDE:	INCBIN	CUBE.DAT

	EVEN

OLD_PALETTE:	DS.W	16
BLANK_PALETTE:	DC.L	0,0,0,0,0,0,0,0
NEW_PALETTE:	DC.W	$000,$002,$113,$22C
		DC.W	$333,$002,$113,$22C
		DC.W	$555,$002,$113,$22C
		DC.W	$777,$002,$113,$22C

;
; ALternative Palettes
;
USE_PAL0:	DC.W	$002,$113,$22C
USE_PAL1:	DC.W	$002,$113,$22C
USE_PAL2:	DC.W	$002,$113,$22C
USE_PAL3:	DC.W	$002,$113,$22C


;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
SET_UP_SCREENS:
	MOVEM.L	$FFFF8240.W,D0-D7	; OLD PALETTE
	MOVEM.L	D0-D7,OLD_PALETTE
	MOVEM.L	BLANK_PALETTE,D0-D7	; BLANK
	MOVEM.L	D0-D7,$FFFF8240.W	

	MOVE.L	#BIG_BUFF,D0	; SET
	ADDI.L	#512,D0
	MOVE.B	#0,D0
	MOVE.L	D0,SCREEN_1
	ADDI.L	#32000,D0
	MOVE.L	D0,SCREEN_2
	MOVE.L	SCREEN_1,A0
	MOVEQ	#0,D1
	MOVE.W	#4000-1,D0		; CLEAR
.LOOP:	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	DBF	D0,.LOOP

	MOVEM.L	NEW_PALETTE,D0-D7	; NEW PALETTE
	MOVEM.L	D0-D7,$FFFF8240.W	
	RTS		


;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
SET_DOWN_SCREENS:
	MOVEM.L	OLD_PALETTE,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W	
	RTS


	IFNE GRIFF	

;-------------------------------------------------------------------------
; GRIFF's Stars Code
;-------------------------------------------------------------------------
;
; CLEAR THE STARS.


; THIS BIT GENERATES A BIG TABLE OF NUMBERS WHICH ARE CO-ORDS
; FOR EVERY STAR POSITION. MEMORY WASTING BUT QUITE FAST. 

GENSTARS	LEA BIG_BUF,A0
		LEA STARS,A1		STAR CO-ORDS
		LEA OFFSETS(PC),A2
		LEA RES_OFFSETS(PC),A3
		MOVE #NO_STRS-1,D7
GENSTAR_LP	MOVE.L A0,(A3)+		SAVE RESET OFFSET
		MOVE.L A0,(A2)+		SAVE CURR OFFSET
		MOVEM.W (A1)+,D4-D6		GET X/Y/Z
		EXT.L D4			EXTEND SIGN
		EXT.L D5
		ASL.L #8,D4
		ASL.L #8,D5
THISSTAR_LP	MOVE.L D4,D0 
		MOVE.L D5,D1
		MOVE.L D6,D2
		SUBQ #3,D6			Z=Z-3 (PERSPECT)
		DIVS D2,D0			X/Z(PERSPECT)
		DIVS D2,D1			Y/Z(PERSPECT)
		ADD #160,D0			ADD OFFSETS
		ADD #100,D1			
		CMP #319,D0
		BHI.S STAR_OFF
		CMP #199,D1
		BHI.S STAR_OFF
		MOVE D0,D3
		MULU #160,D1
		LSR #1,D0
		AND.W #$FFF8,D0
		ADD.W D0,D1
		MOVE.W D1,(A0)+
		NOT D3
		AND #15,D3
		MOVEQ #0,D1
		BSET D3,D1
		ASR #6,D2
		TST D2
		BLE.S WHITE
		CMP #1,D2
		BEQ.S WHITE
		CMP #2,D2
		BEQ.S C2
C1		MOVE.W D1,(A0)+
		CLR.W (A0)+
		BRA THISSTAR_LP
WHITE		MOVE.W D1,(A0)+
		MOVE.W D1,(A0)+
		BRA THISSTAR_LP
C2		MOVE.L D1,(A0)+
		BRA THISSTAR_LP
STAR_OFF	MOVE.L #-1,(A0)+
		MOVE.W #-1,(A0)+
		DBF D7,GENSTAR_LP
RANDOFFSETS	LEA OFFSETS(PC),A0
		LEA SEED,A2
		MOVE #NO_STRS-2,D7
RANDS		MOVEM.L (A0),D0/D1
		SUB.L D0,D1
		DIVU #6,D1
		MOVEQ #0,D2
		MOVE (A2),D2		
		ROL #1,D2			
		EOR #54321,D2
		SUBQ #1,D2		
		MOVE D2,(A2)	
		DIVU D1,D2						
		CLR.W D2
		SWAP D2
		MULU #6,D2
		ADD.L D2,D0
		MOVE.L D0,(A0)+
		DBF D7,RANDS			
REPEATROUT	LEA DRAW1(PC),A0
		LEA ENDDRAW1(PC),A1
		MOVE #NO_STRS-2,D7
.LP1		MOVE #(ENDDRAW1-DRAW1)-1,D6
.LP2		MOVE.B (A0)+,(A1)+
		DBF D6,.LP2
		DBF D7,.LP1
		RTS

FRAMESWITCH	DC.W 0
WHICH_OLD	DC.L 0

CSE1:		
		REPT NO_STRS
		MOVE.L D0,2(A0)
		ENDR
		RTS

CSE2:		
		REPT NO_STRS
		MOVE.L D0,2(A0)
		ENDR
		RTS

CLEARSTARS	MOVE.L SCREEN_1,A0
		LEA	4(A0),A0
		MOVEQ #0,D0
		MOVE.L #CSE2,WHICH_OLD
		NOT FRAMESWITCH
		BNE CSE2
		MOVE.L #CSE1,WHICH_OLD
		BRA CSE1

; PLOT THOSE DARN STARS!

PLOTSTARS	MOVE.L SCREEN_1,A0
		LEA	4(A0),A0
		LEA OFFSETS(PC),A1
		MOVE.L WHICH_OLD(PC),A5
		MOVE.L (A5),D5
DRAW1		MOVE.L (A1),A2		
		MOVE.W (A2)+,D5		
		BGE.S .RESTART
		MOVE.L NO_STRS*4(A1),A2	
		MOVE.W (A2)+,D5		
.RESTART	MOVE.L (A2)+,D4
		OR.L D4,(A0,D5)
		MOVE.L A2,(A1)+		
		MOVE.L D5,(A5)+		
ENDDRAW1	DS.B (NO_STRS-1)*(ENDDRAW1-DRAW1)
		RTS

STARS		INCBIN	RAND_131.XYZ
SEED		DC.W $9753

OFFSETS		DS.L NO_STRS
RES_OFFSETS	DS.L NO_STRS

	ENDC

;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------


	IFNE	BLIPS
MUSIC:	INCBIN	2.MUS
	ENDC

MESSAGE:
	DC.B	"MMMMMMMMMMM"
 DC.B " . . . . . .   Welcome to a development version of The Fingerbobs Cube Screen for the new Inner Circle Demo. "
 DC.B "   The fact that you are reading this leads me to conclude one of two things. You are either a) another member "
 DC.B "of the Inner Circle - Hurrah! or b) a bastard lamer who stole this screen from somewhere.   "
 DC.B " If you are in category b) then do us all a favour and fuck off. If however you are in a) listen to this......"
 DC.B "   Code : Oberse Ltd. ( Well thats the name that my CTW subscription is under! )   Starfield : Griffy-babes     Graphics & Final scrolltext : Pixar ("
 DC.B "Scroll on a roll)    Music : Count Zero-e-poos      ."
 DC.B "    Do you like this scroller, I think it is pretty cool. It bears a marked resemblence to a section of "
 DC.B "the ""Vectors 4 All"" demo from the Amiga. This similarity is not a coincidence. In fact it is quite Deliberate. "
 DC.B "As an average I have to count on the scroller taking about 70-75% of the available processor time. What a fucking bummer. It usually "
 DC.B "takes much less time but, when there are a lot of ""Bobs"" on the screen It takes a mighty big chunk.   "
 DC.B "  Griffs stars are rather cool, taking only about 11% of processor time!!     "
 DC.B " I wonder what the fuck else I can squeeze in this code, without having to go back and recode the scroller?  Any ideas?       "
 DC.B "     5   4   3   2   1  ...........  WRAPP        "
 DC.B "       "
 
 DC.B	-1

	EVEN

CHAR_SET_IN:	INCBIN	F6X6.FNT

SCREEN_1:	DS.L	1
SCREEN_2:	DS.L	1

		DS.L	50
MY_STACK:	DS.L	1

BIG_BUFF:	EQU	*
BIG_BUF:	EQU	*+65000


	END X
		

