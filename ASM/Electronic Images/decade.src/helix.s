	OPT	O+,OW-,C-
* Yes, this is the helix scroll
* by (you've guessed) Matrixx of the
* ST Squad!

***************
*   EQUATES   *
***************

SReg	EQU	$FFFF8800

* MFP 68901 Registers.

IEA	EQU	$FFFFFA07
IEB	EQU	$FFFFFA09
ISRA	EQU	$FFFFFA0F
IMA	EQU	$FFFFFA13
TBCR	EQU	$FFFFFA1B
TBDR	EQU	$FFFFFA21

* Video control registers.

SCRN_RAM	EQU	$FFFF8201
SYSPAL		EQU	$FFFF8240		System palette registers.
SHFTMOD		EQU	$FFFF8260		Resolution mode.

* 68000 and MFP 68901 Exception Vectors.

VBL_VEC		EQU	$70
KEY_VEC		EQU	$118
HBL_VEC		EQU	$120

* Sound chip.
SoundReg	EQU	$FFFF8800


***********
* Macros. *
***********

* Plot one line of the scroller.
* \1 = Offset into the character.
* \2 = Line offset on screen.
* A0 = Position on the screen.
* A1 = Position of reverse line.
* A2 = Pointer to character data.

SingleLine	MACRO
Line	SET	160*\2
	MOVEM.L	\1*12(A2),D0-D2		Grab data.
	ADD.L	D0,Line(A0)		Write 1st 16 pixels.
	ADD.L	D0,-Line(A1)		Write background 16 pixels.
	MOVE.L	D1,8+Line(A0)		Write 2nd 16 pixels etc.
	MOVE.L	D1,8-Line(A1)
	MOVE.L	D2,16+Line(A0)
	MOVE.L	D2,16-Line(A1)
	ENDM

* Plot two lines of the scroller.

DoubleLine	MACRO
Line	SET	160*\2		As before.
	MOVEM.L	\1*12(A2),D0-D2
	ADD.L	D0,Line(A0)
	ADD.L	D0,160+Line(A0)
	ADD.L	D0,-Line(A1)
	ADD.L	D0,-160-Line(A1)
	MOVE.L	D1,8+Line(A0)
	MOVE.L	D1,168+Line(A0)
	MOVE.L	D1,8-Line(A1)
	MOVE.L	D1,-152-Line(A1)
	MOVE.L	D2,16+Line(A0)
	MOVE.L	D2,176+Line(A0)
	MOVE.L	D2,16-Line(A1)
	MOVE.L	D2,-144-Line(A1)
	ENDM

	
* The actual plotting routine.
* Parameters:
* A0 = Position on screen for top.
* A1 = Position on screen for background.
* A2 = Start of character.
* 
* D0.W = Rotate value.
* 
Plot	MACRO
	LEA	OffsetTable(PC),A4	Get offset table position.
	LSL.W	#2,D0			Longword offset.
	MOVE.L	0(A4,D0.W),A3		Get position of start of routine.
	LEA	128(A4),A4
	MOVE.L	0(A4,D0.W),A5		Get position of end of routine.
	MOVE.W	(A5),D5			Save word at end or routine.
	MOVE.W	#$4E75,(A5)		Put an RTS there.
	MOVE.W	D0,D1			Multiply by 3.
	ADD.W	D0,D1
	ADD.W	D0,D1
	SUBA.W	D1,A2			Subtract from character position.
	JSR	(A3)			Jump to the routine.
	MOVE.W	D5,(A5)			Restore the destroyed word.
	
	ENDM


SwapScreens	MACRO
	MOVE.L	ScreenPos,-(SP)	Set the new screen position.
	MOVE.B	1(SP),$FFFF8201.W
	MOVE.B	2(SP),$FFFF8203.W
	ADDQ.L	#4,SP
	
	MOVE.L	ScreenPos2,D0	Swap the pointers.
	MOVE.L	ScreenPos,ScreenPos2
	MOVE.L	D0,ScreenPos
	
	WaitVBL		Wait for the next vbl.
	
	ENDM
	
WaitVBL	MACRO
WaitVBLLoop\@
	TST.W	VBLFlag		Check VBL flag.
	BEQ	WaitVBLLoop\@	Branch if not set yet.
	CLR.W	VBLFlag		Clear the flag.
	ENDM

WaitVBL2	MACRO
WaitVBLLoop\@
	CLR.W	VBLFlag
	TST.W	VBLFlag		Check VBL flag.
	BEQ	WaitVBLLoop\@	Branch if not set yet.
	CLR.W	VBLFlag		Clear the flag.
	ENDM


ClearLines	MACRO
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	
	MOVEM.L	D3-D6,-160(A0)
	MOVEM.L	D3-D6,4960-160(A0)
	MOVEM.L	D3-D6,-160(A4)
	MOVEM.L	D3-D6,4960-160(A4)
	MOVEM.L	D3-D6,-160(A5)
	MOVEM.L	D3-D6,4960-160(A6)
	MOVEM.L	D3-D6,-320(A0)
	MOVEM.L	D3-D6,5120-160(A0)
	MOVEM.L	D3-D6,-320(A4)
	MOVEM.L	D3-D6,5120-160(A4)
	MOVEM.L	D3-D6,-320(A5)
	MOVEM.L	D3-D6,5120-160(A5)
	MOVEM.L	D3-D6,5280-160(A0)
	MOVEM.L	D3-D6,5280-160(A4)
	MOVEM.L	D3-D6,5280-160(A5)

	ENDM

************************
* START OF THE PROGRAM *
************************

	BRA	Main
MUSIC	INCBIN	HELIX.INC\ROLLOUT.MUS

****************
* Main program *
****************
Main:
	LEA	Stack,A7
	
	CLR.L	-(SP)		Into supervisor mode.
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,OldSSP
	
	MOVE.W	#$2700,SR	Kill the mouse.
	MOVE.B	#$12,$FFFFFC02.W
	MOVE.W  #$2300,SR
	
	MOVEQ	#2,D0		Initialize musix.
	BSR	MUSIC
	
	CLR.L	-(SP)		Get current screen position.
	MOVE.B	$FFFF8201.W,1(SP)
	MOVE.B	$FFFF8203.W,2(SP)
	MOVE.L	(SP)+,D0
	
	MOVE.L	D0,TrueScreenPos	Save it.

	MOVE.L	#SecondScreenStore,D0	Set up screen.
	ADD.W	#256,D0
	CLR.B	D0
	MOVE.L	D0,ScreenPos
	MOVE.L	#ThirdScreenStore,D0	Set up next screen.
	ADD.W	#256,D0
	CLR.B	D0
	MOVE.L	D0,ScreenPos2
	
	MOVE.L	D0,A0			Clear the screens.
 	BSR	ClearWholeScreen
	MOVE.L	ScreenPos,A0
	BSR	ClearWholeScreen
	
	
	MOVE.B	(IEB).W,OLD_IEB		 Save system registers that will be altered.
	MOVE.B	(IEA).W,OLD_IEA
	MOVE.B	(IMA).W,OLD_IMA
	MOVE.B	(SHFTMOD).W,OLD_SHFTMOD
	
	AND.B	#$DF,(IEB).W		Disable Timer C (200Hz)
	AND.B	#$FE,(IEA).W		Disable Timer B (H-Blank)
	
	BCLR	#6,(IEB).W
	
	MOVE.L	(HBL_VEC).W,OLD_HBL_VEC
	MOVE.L	#HBL_HANDLER,(HBL_VEC).W
	
	OR.B	#1,(IEA).W			Turn H-Blank on.
	OR.B	#1,(IMA).W
	
	MOVE.L	(VBL_VEC).W,OLD_VBL_VEC
	MOVE.L	#VBL_HANDLER,(VBL_VEC).W
	
	MOVEQ	#$F,D0			Save the old palette.
	LEA	(SYSPAL).W,A1
	LEA	OLD_PALETTE,A0
SavePalette
	MOVE.W	(A1)+,(A0)+
	DBRA	D0,SavePalette
	
	MOVE.B	$FFFF820A.W,OldMode	Into 50Hz low resolution.
	MOVE.B	$FFFF8260.W,OldRes
	WaitVBL2
	MOVE.B	#2,$FFFF820A.W
	MOVE.B	#0,$FFFF8260.W
	
	BSR	ShiftFont	Shift the font.
	BSR	SetPalette	Set up the palette.
	
MainLoop:
*	MOVE.W	#$002,(SYSPAL).W	Timing bars.
	SwapScreens
*	MOVE.W	#$0,(SYSPAL).W
	
	MOVE.L	ScreenPos,A0	Clear the old scroll bar.
	ADDA.W	OldTwistHeight2(PC),A0
	BSR	ClearScreen

	MOVE.W	ScrollPos(PC),D0
	MULU	#13440,D0
	MOVE.L	#NEWFONT,FontPos
	ADD.L  	D0,FontPos

	TST.W	ScrollPos16
	BNE.S	.BRA1
	BSR	Plot1
	BRA.S	.BRA2
.BRA1	BSR	Plot2
.BRA2
	
	MOVE.L	ScreenPos,A0		Plot bar ends.
	ADDA.W	ScrollHeight,A0
	BSR	EraseEnds
	
	
	MOVE.L	ScreenPos,A0		Duplicate the scroll bar.
	ADDA.W	ScrollHeight,A0
	BSR	CopyScroll
	
	MOVE.L	ScreenPos,A0		Plot bar ends.
	ADDA.W	ScrollHeight,A0
	BSR	PlotSmallBars
	
	
	MOVE.W	OldTwistHeight(PC),OldTwistHeight2
	MOVE.W	ScrollHeight(PC),OldTwistHeight
	ADDQ.W	#4,TwistHeight
	MOVE.W	TwistHeight(PC),D0
	CMP.W	#360,D0
	
	BMI.S	.HOK
	CLR.W	TwistHeight
.HOK	LEA	SineTable(PC),A0
	MOVE.W	0(A0,D0.W),ScrollHeight
	ADD.W	#(47+39)*160,ScrollHeight
	 
*	MOVE.L	ScreenPos,A0		Plot bar ends.
*	ADDA.W	ScrollHeight,A0
*	BSR	EraseEnds
	
*	MOVE.L	ScreenPos,A0		Duplicate the scroll bar.
*	ADDA.W	ScrollHeight,A0
*	BSR	CopyScroll
	
	SUBQ.W	#2,LineCount
	ADDQ.W	#1,ScrollPos
	AND.W	#$7,ScrollPos
	TST	ScrollPos
	BNE.S	.BRA3
	NOT	ScrollPos16
*	SUBQ.W	#1,LineCount
	TST	ScrollPos16
	BNE.S	.BRA3
	ADD.W	#16,LineCount
	BSR	OffScroll
.BRA3
	
	BSR	PlotSoundBars

	BSR	PlotSTSLogo
	
	MOVE.B	$FFFFFC02.W,D0
	CMPI.B	#185,D0
	BEQ.S	Exit
	
Test	TST	LineCount
	BGT.S	AndIt
	ADD.W	#64,LineCount
AndIt:	AND.W	#$003F,LineCount
	BRA	MainLoop
Exit:
	WaitVBL2
	MOVE.B	OldMode,$FFFF820A.W
	MOVE.B	OldRes,$FFFF8260.W
	
	MOVE.W	#$2700,SR

	MOVE.B	OLD_IEB,IEB		Put everything back again.
	MOVE.B	OLD_IEA,IEA
	MOVE.B	OLD_IMA,IMA
	
	BSET	#6,(IEB).W
	
	MOVE.L	OLD_HBL_VEC,HBL_VEC
	MOVE.L	OLD_VBL_VEC,VBL_VEC
	
	MOVE.W	#$F,D0			Restore palette.
	LEA	SYSPAL,A1
	LEA	OLD_PALETTE,A0
RESTORE_LOOP
	MOVE.W	(A0)+,(A1)+
	DBRA	D0,RESTORE_LOOP
	
	MOVE.L	TrueScreenPos,-(SP)	Restore screen position.
	MOVE.B	1(SP),$FFFF8201.W
	MOVE.B	2(SP),$FFFF8203.W
	ADDQ.L	#4,SP
	
	MOVE.B	#$8,$FFFFFC02.W		Resurrect mouse.
	MOVE.W  #$2300,SR
	
	MOVE.B	#8,(SoundReg).W		Sound off.
	MOVE.B	#0,(SoundReg+2).W
	MOVE.B	#9,(SoundReg).W
	MOVE.B	#0,(SoundReg+2).W
	MOVE.B	#10,(SoundReg).W
	MOVE.B	#0,(SoundReg+2).W
	
	MOVE.L	OldSSP,-(SP)		Out of supervisor mode.
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR.W	-(SP)			Bye bye.
	TRAP	#1
	
******************************
* The main plotting routine. *
******************************
	
P0 SingleLine  0,0
P1
P2
P3
P4 
P5 SingleLine  5,1
P6 
P7 SingleLine  7,2
P8 
P9 SingleLine  9,3
P10 SingleLine  10,4
P11 
P12 SingleLine  12,5
P13 SingleLine  13,6
P14 SingleLine  14,7
P15 SingleLine  15,8
P16 SingleLine  16,9
P17 DoubleLine  17,10
P18 SingleLine  18,12
P19 SingleLine  19,13
P20 SingleLine  20,14
P21 DoubleLine  21,15
P22 SingleLine  22,17
P23 DoubleLine  23,18
P24 SingleLine  24,20
P25 SingleLine  25,21
P26 DoubleLine  26,22
P27 SingleLine  27,24
P28 DoubleLine  28,25
P29 DoubleLine  29,27
P30 SingleLine  30,29
P31 DoubleLine  31,30
P32 SingleLine  32,32
P33 DoubleLine  33,33
P34 DoubleLine  34,35
P35 SingleLine  35,37
P36 DoubleLine  36,38
P37 SingleLine  37,40
P38 SingleLine  38,41
P39 DoubleLine  39,42
P40 SingleLine  40,44
P41 DoubleLine  41,45
P42 SingleLine  42,47
P43 SingleLine  43,48
P44 SingleLine  44,49
P45 DoubleLine  45,50
P46 SingleLine  46,52
P47 SingleLine  47,53
P48 SingleLine  48,54
P49 SingleLine  49,55
P50 SingleLine  50,56
P51 
P52 SingleLine  52,57
P53 SingleLine  53,58
P54 
P55 SingleLine  55,59 
P56 
P57 SingleLine  57,60
P58
P59
P60
P61 
P62 SingleLine  62,61
P63 

P64 SingleLine  64,0 
P65
P66
P67
P68 
P69 SingleLine  69,1
P70 
P71 SingleLine  71,2
P72 
P73 SingleLine  73,3
P74 SingleLine  74,4
P75 
P76 SingleLine  76,5
P77 SingleLine  77,6
P78 SingleLine  78,7
P79 SingleLine  79,8
P80 SingleLine  80,9
P81 DoubleLine  81,10
P82 SingleLine  82,12
P83 SingleLine  83,13
P84 SingleLine  84,14
P85 DoubleLine  85,15
P86 SingleLine  86,17
P87 DoubleLine  87,18
P88 SingleLine  88,20
P89 SingleLine  89,21
P90 DoubleLine  90,22
P91 SingleLine  91,24
P92 DoubleLine  92,25
P93 DoubleLine  93,27
P94 SingleLine  94,29
P95 DoubleLine  95,30
P96 SingleLine  96,32
P97 DoubleLine  97,33
P98 DoubleLine  98,35
P99 SingleLine  99,37
	RTS

* Routine to clear the screen where the scroller is.
* Parameters:
* A0 = Screen Location.
ClearScreen:
	LEA	10240(A0),A0	Add offset to the bottom of the bar.
	MOVEQ	#0,D0		Clear registers.
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	MOVE.L	D0,A4
	MOVE.L	D0,A5
	MOVE.L	D0,A6
	
	REPT	182			Clear the screen.
	MOVEM.L	D0-D7/A1-A6,-(A0)
	ENDR
	MOVEM.L	D0-D7/A1-A4,-(A0)
	RTS
	
* Routine to clear the whole screeen.

ClearWholeScreen:
	LEA	32000(A0),A0	Move to the bottom of the screen.
	MOVEQ	#0,D0		Clear registers.
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVE	#249,D7
	MOVE.L	D0,A1
.Loop	MOVEM.L	D0-D6/A1,-(A0)	Clear the screen.
	MOVEM.L	D0-D6/A1,-(A0)
	MOVEM.L	D0-D6/A1,-(A0)
	MOVEM.L	D0-D6/A1,-(A0)
	DBRA	D7,.Loop
	RTS


* Shift the font.

ShiftFont:
	LEA	Chars(PC),A0
	LEA	NEWFONT(PC),A1
	MOVE.W	#1119,D0
.Loop	ADDQ.W	#4,A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,.Loop
	LEA NEWFONT(PC),A5
	MOVEQ #6,D7
shftylp	LEA (A5),A0
	LEA 1120*12(A0),A1
	MOVE.W	#1119,D3
.Loop2	MOVE.L	(A0)+,D0
	MOVE.L	(A0)+,D1
	MOVE.L	(A0)+,D2
	REPT	2
	LSL.W	#1,D2
	ROXL.W	#1,D1
	ROXL.W	#1,D0
	ENDR
	SWAP	D2
	SWAP	D1
	SWAP	D0
	REPT	2
	LSL.W	#1,D2
	ROXL.W	#1,D1
	ROXL.W	#1,D0
	ENDR
	SWAP	D2
	SWAP	D1
	SWAP	D0
	MOVE.L	D0,(A1)+
	MOVE.L	D1,(A1)+
	MOVE.L	D2,(A1)+
	DBRA	D3,.Loop2
	LEA	1120*12(A5),A5
	DBF D7,shftylp
	RTS


* Routine to 'Scroll' the character offsets.
OffScroll:
	LEA	CharPointers(PC),A0	Load position of character offsets.
	REPT	5
	MOVE.L	2(A0),(A0)+		Shift them along.
	ENDR
	MOVE.L	PositionInText(PC),A1	Load position in the message.
	MOVEQ	#0,D0			Clear D0.
	MOVE.B	(A1),D0			Get next character.
	LEA	CharTable(PC),A1	Get position of the character lookup table.
	MOVE.B	0(A1,D0.W),D0		Get posiiton of the character in the font.
	MULU	#384,D0			Work out character position.
	MOVE.W	D0,-(A0)		Store position.
	ADDQ.L	#1,PositionInText	Move pointer to next character.
	CMPI.L	#EndText,PositionInText	At end?
	BNE.S	.Exit			No, then branch.
	MOVE.L	#Message,PositionInText	Restart messsage.
.Exit
	RTS		Bye bye.
	
*Routine to erase ends of the scroller.
*Parameters:
* A0 = Screen Position.
EraseEnds:
	LEA	-480(A0),A0	Move back three scan lines.
	
	MOVEQ	#0,D0		Clear top and bottom on two planes.
	MOVE.L	D0,4(A0)
	MOVE.L	D0,160+4(A0)
	MOVE.L	D0,320+4(A0)
	MOVE.L	D0,4+(160*63)(A0)
	MOVE.L	D0,160+4+(160*63)(A0)
	MOVE.L	D0,320+4+(160*63)(A0)
	MOVE.L	D0,4+152(A0)
	MOVE.L	D0,160+4+152(A0)
	MOVE.L	D0,320+4+152(A0)
	MOVE.L	D0,4+(160*63)+152(A0)
	MOVE.L	D0,160+4+(160*63)+152(A0)
	MOVE.L	D0,320+4+(160*63)+152(A0)
	
	LEA	SideBar(PC),A1	Load data.
	MOVEQ	#67,D1
.Loop	MOVE.L	(A1),(A0)	Plot the bar on both sides of the screen.
	MOVE.L	(A1)+,152(A0)
	LEA	160(A0),A0
	DBRA	D1,.Loop
	RTS

**********
* Routine to plot the small side bars. 
* Parameters:
* A0 = Position of the screen.
PlotSmallBars:
	
	MOVE.L	A0,A2
	
	LEA	-5760(A0),A0
	LEA	SmallBar(PC),A1	Load data.
	MOVEQ	#32,D1
.Loop	MOVE.L	(A1),(A0)	Plot the bar on both sides of the screen.
	MOVE.L	(A1)+,152(A0)
	LEA	160(A0),A0
	DBRA	D1,.Loop
	
	LEA	10400(A2),A0
	LEA	SmallBar+136(PC),A1	Load data.
	MOVEQ	#32,D1
.Loop2	MOVE.L	(A1),(A0)	Plot the bar on both sides of the screen.
	MOVE.L	(A1)+,152(A0)
	LEA	160(A0),A0
	DBRA	D1,.Loop2
	
	RTS

	
* Routine to draw the scroller.
* Offset 1

Plot1:	
	MOVEQ	#9,D7			Ten characters to plot.
	MOVE.W	LineCount(PC),D6	Load everything.
	LEA	CharPointers(PC),A6
	MOVE.L	ScreenPos(PC),A5
	ADDA.W	ScrollHeight(PC),A5
.Loop	
	MOVE.L	FontPos(PC),A2
	ADDA.W	(A6)+,A2
	MOVE.L	A5,A0
	LEA	16(A5),A5
	MOVE.L	A0,A1
	LEA	10244-480(A1),A1
	MOVE.W	D6,D0
	ADD.W	#16,D6
	CMPI.W	#64,D6		Wrapped yet?
	BLT	.BRA1		No, then branch.
	SUB.W	#64,D6
.BRA1
	MOVE.L	A5,D4		Save A5.
	Plot
	MOVE.L	D4,A5		Restore A5.
	DBRA	D7,.Loop
	RTS

* Routine to draw the scroller.
* Offset 2

Plot2:	
	MOVEQ	#9,D7			As before.
	MOVE	LineCount(PC),D6
	LEA	CharPointers(PC),A6
	MOVE.L	ScreenPos(PC),A5
	ADDA.W	ScrollHeight(PC),A5
	SUBQ.W	#8,A5
.Loop	
	MOVE.L	FontPos(PC),A2
	ADDA.W	(A6)+,A2
	MOVE.L	A5,A0
	LEA	16(A5),A5
	MOVE.L	A0,A1
	LEA	10244-480(A1),A1
	MOVE.W	D6,D0
	ADD.W	#16,D6
	CMPI.W	#64,D6
	BLT	.BRA1
	SUB.W	#64,D6
.BRA1
	MOVE.L	A5,D4
	Plot
	MOVE.L	D4,A5
	DBRA	D7,.Loop
	RTS

* Set the standard palette.
SetPalette:
	LEA	$FFFF8240.W,A1
	LEA	Palette(PC),A0
	REPT	16
	MOVE.W	(A0)+,(A1)+
	ENDR
	RTS

* Routine to copy the scrolline.
* A0 = Position of the Scrolline.

CopyScroll:
	LEA	13920-3200(A0),A6	Clear above and below the scroller.
	LEA	-36*160(A0),A5
	MOVE.L	A6,A1
	MOVE.L	A5,A4
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	REPT	16
	MOVEM.L	D0-D7/A2-A3,-(A6)
	MOVEM.L	D0-D7/A2-A3,-(A5)
	ENDR
	
	LEA	18880+640-3200(A0),A6
	LEA	-1*160(A0),A5

	REPT	16
	MOVEM.L	D0-D7/A2-A3,-(A6)
	MOVEM.L	D0-D7/A2-A3,-(A5)
	ENDR
	
	MOVE.L	A0,A6
	MOVE.L	A4,A0

CopyCount	SET	0

* Copy the scroll bar.

	REPT	31
	MOVEM.L	(A6)+,D0-D7/A2-A5
	MOVEM.L	D0-D7/A2-A5,CopyCount(A1)
	MOVEM.L	D0-D7/A2-A5,CopyCount(A0)
CopyCount	SET	CopyCount+48
	MOVEM.L	(A6)+,D0-D7/A2-A5
	MOVEM.L	D0-D7/A2-A5,CopyCount(A1)
	MOVEM.L	D0-D7/A2-A5,CopyCount(A0)
CopyCount	SET	CopyCount+48
	MOVEM.L	(A6)+,D0-D7/A2-A5
	MOVEM.L	D0-D7/A2-A5,CopyCount(A1)
	MOVEM.L	D0-D7/A2-A5,CopyCount(A0)
CopyCount	SET	CopyCount+48
	MOVEM.L	(A6)+,D0-D3
	MOVEM.L	D0-D3,CopyCount(A1)
	MOVEM.L	D0-D3,CopyCount(A0)
CopyCount	SET	CopyCount+16
	LEA	160(A6),A6	Next Line.
	ENDR
	
	RTS

**********************************
* Routine to plot the sound bars *
**********************************

PlotSoundBars:
* Read the volume on all three channels.
	MOVE.B	#8,(SoundReg).W
	MOVEQ	#0,D0
	MOVE.B	(SoundReg).W,D0
	BNE	.BR1
	MOVEQ	#1,D0
.BR1
	MOVE.B	#9,(SoundReg).W
	MOVEQ	#0,D1
	MOVE.B	(SoundReg).W,D1
	BNE	.BR2
	MOVEQ	#1,D1
.BR2
	MOVE.B	#10,(SoundReg).W
	MOVEQ	#0,D2
	MOVE.B	(SoundReg).W,D2
	BNE	.BR3
	MOVEQ	#1,D2
.BR3

* Put value of 10 if chip waveform.
	CMPI.B	#16,D0
	BNE	.B1
	MOVEQ	#10,D0
.B1
	CMPI.B	#16,D1
	BNE	.B2
	MOVEQ	#10,D1
.B2
	CMPI.B	#16,D2
	BNE	.B3
	MOVEQ	#10,D2
.B3

	SUB.L	A6,A6
	
	SUBQ.W	#1,D0
	MOVE.L	ScreenPos(PC),A0
	MOVE.W	DialWavePointer(PC),D3
	LEA	DialWave(PC),A1
	LEA	(A1,D3.W),A3
	MOVE.L	A0,A2
	LEA	16(A0),A4
	LEA	32(A0),A5
	ADDA.W	(A3),A0
	ADDA.W	4*2(A3),A4
	ADDA.W	8*2(A3),A5
	LEA	Dials(PC),A1
	LSL.W	#4,D0
	SUBA.W	D0,A1
	LSL.W	#5,D0
	ADDA.W	D0,A1
	MOVEQ	#30,D7
	ClearLines
.Loop	MOVEM.L	(A1)+,D3-D6
	MOVEM.L	D3-D6,(A0)
	MOVEM.L	D3-D6,(A4)
	MOVEM.L	D3-D6,(A5)
	LEA	160(A0),A0
	LEA	160(A4),A4
	LEA	160(A5),A5
	DBRA	D7,.Loop

	SUBQ.W	#1,D1
	LEA	48(A2),A0
	LEA	16(A0),A4
	LEA	32(A0),A5
	ADDA.W	12*2(A3),A0
	ADDA.W	16*2(A3),A4
	ADDA.W	20*2(A3),A5
	LEA	Dials(PC),A1
	LSL.W	#4,D1
	SUBA.W	D1,A1
	LSL.W	#5,D1
	ADDA.W	D1,A1
	MOVEQ	#30,D7
	ClearLines
.Loop2	MOVEM.L	(A1)+,D3-D6
	MOVEM.L	D3-D6,(A0)
	MOVEM.L	D3-D6,(A4)
	MOVEM.L	D3-D6,(A5)
	LEA	160(A0),A0
	LEA	160(A4),A4
	LEA	160(A5),A5
	DBRA	D7,.Loop2

	SUBQ.W	#1,D2
	LEA	96(A2),A0
	LEA	16(A0),A4
	LEA	32(A0),A5
	ADDA.W	24*2(A3),A0
	ADDA.W	28*2(A3),A4
	ADDA.W	32*2(A3),A5
	LEA	Dials(PC),A1
	LSL.W	#4,D2
	SUBA.W	D2,A1
	LSL.W	#5,D2
	ADDA.W	D2,A1
	MOVEQ	#30,D7
	ClearLines
.Loop3	MOVEM.L	(A1)+,D3-D6
	MOVEM.L	D3-D6,(A0)
	MOVEM.L	D3-D6,(A4)
	MOVEM.L	D3-D6,(A5)
	LEA	160(A0),A0
	LEA	160(A4),A4
	LEA	160(A5),A5
	DBRA	D7,.Loop3
	
	ADDQ.W	#4,DialWavePointer
	CMPI.W	#198,DialWavePointer
	BMI	.PointerOK
	SUB.W	#198,DialWavePointer
.PointerOK
	
	RTS


************
* Routine to plot the STS Logo in the top right hand corner of the screen.
PlotSTSLogo:
	MOVE.L	ScreenPos(PC),A0
	LEA	DialWave,A1
	MOVE.W	DialWavePointer,D0
	ADDA.W	72(A1,D0.W),A0
	LEA	144(A0),A0
	LEA	STSLogo(PC),A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEM.L	D0-D3,-160(A0)
	MOVEM.L	D0-D3,-320(A0)
	MOVEM.L	D0-D3,5120(A0)
	MOVEM.L	D0-D3,5280(A0)
	MOVEQ	#15,D7
.Loop	MOVEM.L	(A2)+,D0-D6/A3
	MOVEM.L	D0-D3,(A0)
	MOVEM.L	D4-D6/A3,160(A0)
	LEA	320(A0),A0
	DBRA	D7,.Loop
	RTS
	

**********************
* Interrupt Handlers *
**********************

HBL_HANDLER
	MOVEM.L	D0/A0/A1,-(SP)
	LEA	$FFFF8240.W,A1
	LEA	Palette2(PC),A0
	REPT	8
	MOVE.L	(A0)+,(A1)+
	ENDR
	
	LEA	SineTable2,A0
	MOVE.W	TwistHeight,D0
	SUBQ.W	#4,D0
	MOVE.B	1(A0,D0.W),D0
	ADDQ.B	#1,D0
	
	MOVE.B	#0,(TBCR).W
	MOVE.L	#HBL_HANDLER2,(HBL_VEC).W
	MOVE.B	D0,(TBDR).W
	MOVE.B	#8,(TBCR).W
	MOVE.B	#150,D0
	SUB.B	(TBDR).W,D0
	MOVE.B	D0,(TBDR).W
	
	MOVEM.L	(SP)+,D0/A0/A1
	
	BCLR	#0,(ISRA).W
	RTE
	
HBL_HANDLER2
	MOVE.W	#$001,$FFFF8240.W
	
	MOVE.L	#HBL_HANDLER3,(HBL_VEC).W
	
	BCLR	#0,(ISRA).W
	RTE
	
HBL_HANDLER3
	MOVEM.L	D0/A1,-(SP)
	LEA	$FFFFFA21.W,A1
	MOVE.B	(A1),D0
.L1	CMP.B	(A1),D0
	BEQ	.L1
	CLR.B	$FFFF820A.W
	MOVEQ	#3,D0
.L2	NOP
	DBRA	D0,.L2
	MOVE.B	#2,$FFFF820A.W
	
	MOVEM.L	(SP)+,D0/A1
	
	BCLR	#0,(ISRA).W
	
	RTE

VBL_HANDLER
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	$FFFF8240.W,A1
	LEA	Palette(PC),A0
	REPT	8
	MOVE.L	(A0)+,(A1)+
	ENDR
	
	MOVE.B	#0,(TBCR).W
	MOVE.L	#HBL_HANDLER,(HBL_VEC).W
	MOVE.B	#49,(TBDR).W
	MOVE.B	#8,(TBCR).W
*	MOVE.B	#150,(TBDR).W
	
	BSR	MUSIC+8
	
	MOVE.W	#$FFFF,VBLFlag
	
	MOVEM.L	(SP)+,D0-D7/A0-A6

	RTE
	
SECTION DATA

OffsetTable
	DC.L	P0,P1,P2,P3,P4,P5,P6,P7,P8,P9
	DC.L	P10,P11,P12,P13,P14,P15,P16,P17,P18,P19
	DC.L	P20,P21,P22,P23,P24,P25,P26,P27,P28,P29
	DC.L	P30,P31,P32,P33,P34,P35,P36,P37,P38,P39
	DC.L	P40,P41,P42,P43,P44,P45,P46,P47,P48,P49
	DC.L	P50,P51,P52,P53,P54,P55,P56,P57,P58,P59
	DC.L	P60,P61,P62,P63,P64,P65,P66,P67,P68,P69
	DC.L	P70,P71,P72,P73,P74,P75,P76,P77,P78,P79
	DC.L	P80,P81,P82,P83,P84,P85,P86,P87,P88,P89
	DC.L	P90,P91,P92,P93,P94,P95,P96,P97,P98,P99

PositionInText	DC.L	Message

Message	INCBIN HELIX.INC\NEWH2.TXT

EndText


CharTable:
	DCB.B	32,0
	DC.B	0,27,31,32,32,32,32,31,34,33,31,32,30,32,29,32
	DC.B	0,0,0,0,0,0,0,0,0,0,32,32,32,32,32,28
	DC.B	32,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	DC.B	16,17,18,19,20,21,22,23,24,25,26,34,31,33,31,32
	DC.B	31,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	DC.B	16,17,18,19,20,21,22,23,24,25,26,34,31,33,32,29
	
Palette:
	DC.W	$000
	DC.W	$122
	DC.W	$233
	DC.W	$344
	DC.W	$455
	DC.W	$566
	DC.W	$677
	DC.W	$700
	DC.W	$740
	DC.W	$770
	DC.W	$500
	DC.W	$710
	DC.W	$721
	DC.W	$737
	DC.W	$300
	DC.W	$777
	

Palette2:
	DC.W	$000
	DC.W	$322
	DC.W	$433
	DC.W	$544
	DC.W	$112
	DC.W	$322
	DC.W	$433
	DC.W	$544
	DC.W	$223
	DC.W	$322
	DC.W	$433
	DC.W	$544
	DC.W	$334
	DC.W	$322
	DC.W	$433
	DC.W	$544
CharPointers	DCB.W	10,0
	EVEN
Chars:
	DCB.B	256,0
	INCBIN	HELIX.INC\TWSTFONT.SPR

	EVEN
Dials:	INCBIN	HELIX.INC\DIALS.SPR
	
	EVEN
SideBar	DCB.B	12,0
	INCBIN	HELIX.INC\SIDEBAR.SPR
	DCB.B	16,0

	EVEN
SmallBar:
	INCBIN	HELIX.INC\SMALLBAR.SPR

	EVEN
STSLogo:
	INCBIN	HELIX.INC\STSLOGO.SPR

LineCount	DC.W	32
ScrollHeight	DC.W	136*160

*ScrollHeight	DC.W	(47+39+50)*160
ScrollPos	DC.W	0
ScrollPos16	DC.W	0

TwistHeight	DC.W	0
OldTwistHeight	DC.W	136*160
OldTwistHeight2	DC.W	136*160
DialWavePointer	DC.W	0

FontPos	DC.L	NEWFONT


SineTable:	INCBIN	HELIX.INC\SINE.WAV

		DC.W	50
		DC.W	50
SineTable2:	INCBIN	HELIX.INC\SINE2.WAV

DialWave:	
	REPT	2
	INCBIN	HELIX.INC\DIALWAVE.WAV
	ENDR

SECTION BSS

	DS.L	200
Stack	DS.W	1
ScreenPos	DS.L	1
ScreenPos2	DS.L	1
TrueScreenPos	DS.L	1
OldMode		DS.B	1
OldRes		DS.B	1
VBLFlag	DS.W	1
OldSSP	DS.L	1

OLD_VBL_VEC	DS.L	1
OLD_HBL_VEC	DS.L	1
PAL_POINTER	DS.L	1
OLD_IEB		DS.B	1
OLD_IEA		DS.B	1
OLD_IMA		DS.B	1
OLD_SHFTMOD	DS.B	1
OLD_PALETTE	DS.W	16
OLD_SSP		DS.L	1


NEWFONT	DS.B	53760*2

	DS.B	1000
SecondScreenStore	DS.B	40000
ThirdScreenStore	DS.B	40000
