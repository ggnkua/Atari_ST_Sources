* This is the PIPEWORX DEMO, written by Matrixx of the ST Squad 1990.
* Copyright 1990 ST Squad.

	OPT	O+,OW-,C-

demo	EQU	0

IEA	EQU	$FFFFFA07	Interrupt enable A.
IEB	EQU	$FFFFFA09	Interrupt enable B.
ISRA	EQU	$FFFFFA0F	
IMA	EQU	$FFFFFA13	Interrupt mask A.
TBCR	EQU	$FFFFFA1B	Timer B control register.
TBDR	EQU	$FFFFFA21	Timer D control register.
VBLVec	EQU	$70		VBL vector.
KeyVec	EQU	$118		Keyboard interrupt vector.
HBLVec	EQU	$120		MFP HBL vector.
SoundReg	EQU	$FFFF8800

* General MACROS and data storage.

IntoSuper	MACRO
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,OldSSP
	ENDM

OutOfSuper	MACRO
	MOVE.L	OldSSP(PC),-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	ENDM

LeaveProgram	MACRO
	CLR.W	-(SP)
	TRAP	#1
	ENDM

SetScreen	MACRO
	MOVE.L	\1,-(SP)	Set the new screen position.
	MOVE.B	1(SP),$FFFF8201.W
	MOVE.B	2(SP),$FFFF8203.W
	ADDQ.L	#4,SP
	ENDM

KillMouse	MACRO
	MOVE.B	#$12,$FFFFFC02.W
	ENDM

ReviveMouse	MACRO
	MOVE.B	#$8,$FFFFFC02.W	Revive the mouse!
	ENDM

SwapScreens	MACRO
	SetScreen	ScreenPos	Set the new screen position.
	
	MOVE.L	ScreenPos2(PC),D0	Swap the pointers.
	MOVE.L	ScreenPos(PC),ScreenPos2
	MOVE.L	D0,ScreenPos
	WaitVBL		Wait for the next vbl.
	ENDM

WaitVBL	MACRO
WaitVBLLoop\@
	TST.W	VBLFlag
	BEQ	WaitVBLLoop\@
	CLR.W	VBLFlag
	ENDM

SaveMFPStatus	MACRO
	LEA	MFPSave,A0
	LEA	(IEA).W,A1
	MOVEP.W	(A1),D0
	MOVE.W	D0,(A0)+
	MOVEP.W	12(A1),D0
	MOVE.W	D0,(A0)+
	MOVEQ.W	#$0,D0
	MOVEP.W	D0,(A1)
	MOVEP.W	D0,12(A1)
	BCLR	#3,16(A1)
	ENDM
	

RestoreMFPStatus	MACRO
	LEA	MFPSave,A0
	LEA	(IEA).W,A1
	MOVE.W	(A0)+,D0
	MOVEP.W	D0,(A1)
	MOVE.W	(A0)+,D0
	MOVEP.W	D0,12(A1)
	BSET	#3,16(A1)
	ENDM

MaskData	MACRO
	MOVEM.W	(A0)+,D0-D3
	MOVEQ	#0,D4
	OR.W	D0,D4
	OR.W	D1,D4
	OR.W	D2,D4
	OR.W	D3,D4
	NOT.W	D4
	MOVE.W	D4,(A1)+
	MOVE.W	D4,(A1)+
	MOVEM.W	D0-D3,(A1)
	ADDQ	#8,A1
	ENDM

CopyData	MACRO
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	ENDM

CopyData2	MACRO
	CopyData
	CopyData
	ENDM

CopyData3	MACRO
	CopyData2
	CopyData
	ENDM

CopyData4	MACRO
	MOVEM.L	(A0)+,D0-D4/A2-A4
	MOVEM.L	D0-D4/A2-A4,(A1)
	LEA	32(A1),A1
	ENDM

CopyData5	MACRO
	MOVEM.L (A0)+,D0-D4/A2-A6
	MOVEM.L D0-D4/A2-A6,(A1)
	LEA	40(A1),A1
	ENDM

CopyData6	MACRO
	MOVEM.L (A0)+,D0-D6/A2-A6
	MOVEM.L D0-D6/A2-A6,(A1)
	LEA	48(A1),A1
	ENDM

CopyData7	MACRO
	CopyData6
	CopyData
	ENDM


PlotMaskedData	MACRO
	MOVEM.L	(A0)+,D0-D2
	AND.L	D0,(A1)
	OR.L	D1,(A1)+
	AND.L	D0,(A1)
	OR.L	D2,(A1)+
	ENDM

PlotMaskedData2	MACRO
	MOVEM.L	(A0)+,D0-D5
	AND.L	D0,(A1)
	OR.L	D1,(A1)+
	AND.L	D0,(A1)
	OR.L	D2,(A1)+
	AND.L	D3,(A1)
	OR.L	D4,(A1)+
	AND.L	D3,(A1)
	OR.L	D5,(A1)+
	ENDM

*********************
* General Routines. *
*********************

	JMP	Main


Characters:
	DCB.B	960,0

	INCBIN	GLASS.SPR
	INCBIN	GLASS2.SPR

Link:
	INCBIN	LINK.SPR

**************************
* Logo plotting routine. *
**************************

	EVEN

PlotShiftedLogo:
* A0 = Data position.
* A1 = ScreenPosition
	LEA	160*8(A1),A1
	
	MOVEQ	#2,D7
.Loop1	REPT	4
	PlotMaskedData2
	PlotMaskedData
	LEA	136(A1),A1
	ENDR
	DBRA	D7,.Loop1

	SUBQ	#8,A1
.Loop2	REPT	4
	PlotMaskedData2
	PlotMaskedData2
	LEA	128(A1),A1
	ENDR

.Loop3	REPT	4
	PlotMaskedData2
	PlotMaskedData2
	PlotMaskedData
	LEA	120(A1),A1
	ENDR

	MOVEQ	#1,D7
.Loop4	REPT	4
	PlotMaskedData2
	CopyData
	PlotMaskedData2
	LEA	120(A1),A1
	ENDR
	DBRA	D7,.Loop4

	SUBQ	#8,A1
.Loop5	REPT	4
	PlotMaskedData2
	CopyData2
	PlotMaskedData2
	PlotMaskedData
	LEA	104(A1),A1
	ENDR

.Loop6	REPT	3
	PlotMaskedData2
	CopyData3
	PlotMaskedData2
	LEA	104(A1),A1
	ENDR
	PlotMaskedData2
	CopyData3
	PlotMaskedData2
	LEA	104-8(A1),A1

	MOVEQ	#1,D7
.Loop7	REPT	4
	PlotMaskedData2
	CopyData4
	PlotMaskedData2
	PlotMaskedData
	LEA	88(A1),A1
	ENDR
	DBRA	D7,.Loop7

.Loop8	REPT	4
	PlotMaskedData2
	CopyData4
	PlotMaskedData2
	LEA	96(A1),A1
	ENDR

.Loop9	REPT	4
	PlotMaskedData2
	CopyData4
	PlotMaskedData2
	PlotMaskedData
	LEA	88(A1),A1
	ENDR

	MOVEQ	#1,D7
.Loop10	REPT	4
	PlotMaskedData2
	CopyData5
	PlotMaskedData2
	LEA	88(A1),A1
	ENDR
	DBRA	D7,.Loop10

	LEA	-8(A1),A1
.Loop11	REPT	4
	PlotMaskedData2
	PlotMaskedData
	CopyData5
	PlotMaskedData2
	LEA	80(A1),A1
	ENDR

.Loop12	REPT	4
	PlotMaskedData2
	CopyData6
	PlotMaskedData2
	PlotMaskedData
	LEA	72(A1),A1
	ENDR

	MOVEQ	#1,D7
.Loop13	REPT	4
	PlotMaskedData2
	CopyData7
	PlotMaskedData2
	LEA	72(A1),A1
	ENDR
	DBRA	D7,.Loop13
	
	PlotMaskedData2
	CopyData7
	PlotMaskedData2
	
	RTS



FlushKey:
	BTST	#0,$FFFFFC00.W
	BEQ.S	.Exit
	MOVE.B	$FFFFFC02.W,D0
	BRA.S	FlushKey
.Exit	RTS


* A0=Postion of the screen.
ClearScreen:
	MOVE.W	#1999,D7
	MOVEQ	#0,D0
.Loop	
	REPT	4
	MOVE.L	D0,(A0)+
	ENDR
	DBRA	D7,.Loop
	RTS

SECTION BSS

	DS.L	200
Stack	DS.W	1

OldSSP		DS.L	1
VBLFlag		DS.W	1

MFPSave	DS.W	2

SECTION TEXT	

***************************
* Main Plotting Routines. *
***************************

* Plot a single line:
* Parameters:
* A0 = Position on screen.
* A1 = Base of screen data.

PlotSingleLine	MACRO
	MOVEM.L	\1(A1),D0-D7/a2-a3
	MOVEM.L	D0-D5,-(A0)
	MOVEM.L	D0-D5,-24(A0)
	MOVEM.L	D0-D5,-48(A0)
	movem.l	d6-d7/a2-a3,-64(a0)
	
	MOVEM.L	D0-D5,-80-8(A0)
	MOVEM.L	D0-D5,-80-24-8(A0)
	MOVEM.L	D0-D5,-80-48-8(A0)
	LEA	-136(A0),A0
	ENDM

* Plot two lines:
* Parameters as before.

PlotDoubleLine	MACRO
	MOVEM.L	\1(A1),D0-D7/a2-a3
	MOVEM.L	D0-D5,-(A0)
	MOVEM.L	D0-D5,-24(A0)
	MOVEM.L	D0-D5,-48(A0)

	movem.l	d6-d7/a2-a3,-64(a0)

	MOVEM.L	D0-D5,-80-8(A0)
	MOVEM.L	D0-D5,-80-24-8(A0)
	MOVEM.L	D0-D5,-80-48-8(A0)
	MOVEM.L	D0-D5,-160(A0)
	MOVEM.L	D0-D5,-160-24(A0)
	MOVEM.L	D0-D5,-160-48(A0)

	movem.l	d6-d7/a2-a3,-64-160(a0)

	MOVEM.L	D0-D5,-160-80-8(A0)
	MOVEM.L	D0-D5,-160-80-24-8(A0)
	MOVEM.L	D0-D5,-160-80-48-8(A0)
	LEA	-296(A0),A0
	ENDM

Plot2Lines:
* Parameters:
* A0 = Output position.
* D0.L = Character.
* D1.W = Position in character.
* D2.W = Link position.


	LEA	Link,A3
	ADD	D2,A3
	LEA	Characters,A2
	
	ADD.L	D0,A2
	ADD.W	D1,A2
	
	MOVEM.L	(A2)+,D0-D5
	MOVEM.L	(A3)+,D6-D7/A4-A5
	MOVEM.L	D0-D7/A4-A5,(A0)

	MOVEM.L	(A2),D0-D5
	MOVEM.L	(A3),D6-D7/A4-A5
	MOVEM.L	D0-D7/A4-A5,80(A0)
	
	RTS

Clear2Lines:
* Parameters:
* A0 = Output position.

	LEA	Link,A3
	ADD.W	D2,A3

	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	
	MOVEM.L	(A3)+,D6-D7/A4-A5
	MOVEM.L	D0-D7/A4-A5,(A0)
	MOVEM.L	D0-D7/A4-A5,-15680(A0)
	MOVEM.L	(A3),D6-D7/A4-A5
	MOVEM.L	D0-D7/A4-A5,80(A0)
	MOVEM.L	D0-D7/A4-A5,80-15680(A0)
	
	RTS



* Music.

Music	INCBIN	PIPEWURX.CZI

	
*****************
* Main Program. *
*****************

	EVEN

Main:	
	IFEQ demo
	CLR -(SP)
	PEA $FFFFFFFF.W
	PEA $FFFFFFFF.W
	MOVE #5,-(SP)
	TRAP #14
	LEA 12(SP),SP
	IntoSuper
	ENDC
	MOVE.W	#$2700,SR
	MOVE.L SP,oldsp
	LEA	Stack(PC),A7

	MOVE.L	#ScreenStore+256,D0
	CLR.B	D0
	MOVE.L	D0,ScreenPos
	ADD.L #32000,D0
	MOVE.L D0,ScreenPos2
	
	MOVE.L	ScreenPos,A0
	BSR	ClearScreen
	MOVE.L	ScreenPos2,A0
	BSR	ClearScreen
	
	MOVEQ	#7,D7
	LEA	$FFFF8240.W,A0
	LEA	Palette,A1
	LEA	OldPalette,A2
SetPaletteLoop:
	MOVE.L	(A0),(A2)+
	MOVE.L	(A1)+,(A0)+
	DBRA	D7,SetPaletteLoop
	
	BSR	ShiftLogo

	BSR	FlushKey
	
	MOVEQ	#1,D0
	BSR	Music+28

	MOVE.L	(VBLVec).W,OldVBLVec
	MOVE.L	#VBLHandler,(VBLVec).W
	KillMouse
	SaveMFPStatus
	MOVE.W	#$2300,SR

MainLoop:
	SwapScreens

	MOVE.L	Character(PC),D0
	MOVE.W	CharacterFinePosition(PC),D1
	MOVE.W	LinkPosition,D2
	
	LEA	StartBuffer+16000,A0
	ADDA.W	ScrollPointer(PC),A0

	CMPI.W	#960,D1
	BPL.S	.NewChar

	LEA	(A0),A6
	BSR	Plot2Lines
	LEA	(A6),A0
	BSR	Copy2Lines
	ADD.W	#48,CharacterFinePosition
	BRA.S	.CharOk
	
.NewChar
	LEA	(A0),A6
	BSR	Clear2Lines
	LEA	(A6),A0
	BSR	Copy2Lines

	CLR.W	CharacterFinePosition
	MOVE.L	PositionInText,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.L	A0,PositionInText
	LEA	CharacterTable,A0
	MOVE.B	(A0,D0.W),D0
	MULU	#960,D0
	MOVE.L	D0,Character
	CMPI.L	#EndMessage,PositionInText
	BMI.S	.CharOK
	MOVE.L	#Message,PositionInText
	
.CharOK

	BSR	PlotScreen

	LEA	LinkPosition(PC),A0
	MOVE.W	(A0),D0
	ADD.W	#32,D0
	CMPI.W	#16*184,D0
	BMI.S	.LinkOk
	MOVEQ	#0,D0
.LinkOk
	MOVE.W	D0,(A0)

	ADD.W	#2*80,ScrollPointer
	CMPI.W	#15680,ScrollPointer
	BMI.S	ScrollOK
	CLR.W	ScrollPointer
ScrollOK

	MOVE.L	ScreenPos(PC),A1
	MOVE.W	SpriteVWavePos(PC),D0
	LEA	VWaveform(PC),A0
	ADDA.W	(A0,D0.W),A1
	LEA	ShiftedLogo,A0
	
	MOVE.W	SpriteWavePos(PC),D0
	LEA	HWaveform(PC),A2
	ADDA.W	(A2,D0),A1
	ADDA.L	2(A2,D0),A0
	
	BSR	PlotShiftedLogo
	ADDQ.W	#2,SpriteVWavePos
	CMPI.W	#360,SpriteVWavePos
	BMI.S	.SpriteOK
	CLR.W	SpriteVWavePos
.SpriteOK

	ADDQ.W	#6,SpriteWavePos
	CMPI.W	#864,SpriteWavePos
	BMI.S	.SpriteOK2
	SUB.W	#864,SpriteWavePos
.SpriteOK2

	BTST.B	#0,$FFFFFC00.W
	BEQ	MainLoop
	MOVE.B	$FFFFFC02.W,D0
	CMPI.B	#$39,D0
	BNE	MainLoop

Exit:	MOVE.W	#$2700,SR
	BSR	FlushKey
	LEA	OldPalette(PC),A1
	LEA	$FFFF8240.W,A0
	MOVEQ	#7,D7
RestorePaletteLoop:
	MOVE.L	(A1)+,(A0)+
	DBRA	D7,RestorePaletteLoop
	
	MOVE.B	#8,(SoundReg).W		Sound off.
	MOVE.B	#0,SoundReg+2.W
	MOVE.B	#9,(SoundReg).W
	MOVE.B	#0,SoundReg+2.W
	MOVE.B	#10,(SoundReg).W
	MOVE.B	#0,SoundReg+2.W
	
	MOVE.L	OldVBLVec(PC),(VBLVec).W
	RestoreMFPStatus
	ReviveMouse
	MOVE.W	#$2300,SR
	IFEQ demo
	LeaveProgram
	ENDC
	MOVE.L oldsp,SP
	RTS

oldsp	dc.l 0

****************
* Plot Routine *
****************
PlotScreen:
	MOVE.L	ScreenPos(PC),A0
	LEA	32000(A0),A0
	LEA	StartBuffer(PC),A1
	ADDA.W	ScrollPointer(PC),A1

	PlotSingleLine	15680
	PlotSingleLine	14960
	PlotSingleLine	14640
	PlotSingleLine	14400
	PlotSingleLine	14240
	PlotSingleLine	14000
	PlotSingleLine	13920
	PlotSingleLine	13760
	PlotSingleLine	13600
	PlotSingleLine	13520
	PlotSingleLine	13360
	PlotSingleLine	13280
	PlotSingleLine	13120
	PlotSingleLine	13040
	PlotSingleLine	12960
	PlotSingleLine	12880
	PlotSingleLine	12720
	PlotSingleLine	12640
	PlotSingleLine	12560
	PlotSingleLine	12480
	PlotSingleLine	12400
	PlotSingleLine	12320
	PlotSingleLine	12240
	PlotSingleLine	12160
	PlotSingleLine	12080
	PlotSingleLine	12000
	PlotSingleLine	11920
	PlotSingleLine	11840
	PlotSingleLine	11760
	PlotSingleLine	11680
	PlotSingleLine	11600
	PlotDoubleLine	11520
	PlotSingleLine	11440
	PlotSingleLine	11360
	PlotSingleLine	11280
	PlotSingleLine	11200
	PlotDoubleLine	11120
	PlotSingleLine	11040
	PlotSingleLine	10960
	PlotSingleLine	10880
	PlotDoubleLine	10800
	PlotSingleLine	10720
	PlotSingleLine	10640
	PlotDoubleLine	10560
	PlotSingleLine	10480
	PlotSingleLine	10400
	PlotDoubleLine	10320
	PlotSingleLine	10240
	PlotDoubleLine	10160
	PlotSingleLine	10080
	PlotSingleLine	10000
	PlotDoubleLine	9920
	PlotSingleLine	9840
	PlotDoubleLine	9760
	PlotSingleLine	9680
	PlotDoubleLine	9600
	PlotSingleLine	9520
	PlotDoubleLine	9440
	PlotSingleLine	9360
	PlotDoubleLine	9280
	PlotSingleLine	9200
	PlotDoubleLine	9120
	PlotSingleLine	9040
	PlotDoubleLine	8960
	PlotSingleLine	8880
	PlotDoubleLine	8800
	PlotSingleLine	8720
	PlotDoubleLine	8640
	PlotSingleLine	8560
	PlotDoubleLine	8480
	PlotDoubleLine	8400
	PlotSingleLine	8320
	PlotDoubleLine	8240
	PlotSingleLine	8160
	PlotDoubleLine	8080
	PlotSingleLine	8000
	PlotDoubleLine	7920
	PlotDoubleLine	7840
	PlotSingleLine	7760
	PlotDoubleLine	7680
	PlotSingleLine	7600
	PlotDoubleLine	7520
	PlotSingleLine	7440
	PlotDoubleLine	7360
	PlotSingleLine	7280
	PlotDoubleLine	7200
	PlotDoubleLine	7120
	PlotSingleLine	7040
	PlotDoubleLine	6960
	PlotSingleLine	6880
	PlotDoubleLine	6800
	PlotSingleLine	6720
	PlotDoubleLine	6640
	PlotSingleLine	6560
	PlotDoubleLine	6480
	PlotSingleLine	6400
	PlotDoubleLine	6320
	PlotSingleLine	6240
	PlotDoubleLine	6160
	PlotSingleLine	6080
	PlotDoubleLine	6000
	PlotSingleLine	5920
	PlotDoubleLine	5840
	PlotSingleLine	5760
	PlotDoubleLine	5680
	PlotSingleLine	5600
	PlotSingleLine	5520
	PlotDoubleLine	5440
	PlotSingleLine	5360
	PlotDoubleLine	5280
	PlotSingleLine	5200
	PlotSingleLine	5120
	PlotDoubleLine	5040
	PlotSingleLine	4960
	PlotSingleLine	4880
	PlotDoubleLine	4800
	PlotSingleLine	4720
	PlotSingleLine	4640
	PlotSingleLine	4560
	PlotDoubleLine	4480
	PlotSingleLine	4400
	PlotSingleLine	4320
	PlotSingleLine	4240
	PlotSingleLine	4160
	PlotDoubleLine	4080
	PlotSingleLine	4000
	PlotSingleLine	3920
	PlotSingleLine	3840
	PlotSingleLine	3760
	PlotSingleLine	3680
	PlotSingleLine	3600
	PlotSingleLine	3520
	PlotSingleLine	3440
	PlotSingleLine	3360
	PlotSingleLine	3280
	PlotSingleLine	3200
	PlotSingleLine	3120
	PlotSingleLine	3040
	PlotSingleLine	2960
	PlotSingleLine	2880
	PlotSingleLine	2720
	PlotSingleLine	2640
	PlotSingleLine	2560
	PlotSingleLine	2480
	PlotSingleLine	2320
	PlotSingleLine	2240
	PlotSingleLine	2080
	PlotSingleLine	2000
	PlotSingleLine	1840
	PlotSingleLine	1680
	PlotSingleLine	1600
	PlotSingleLine	1360
	PlotSingleLine	1200
	PlotSingleLine	960
	PlotSingleLine	640
		
	RTS
	
****************
* Line copier. *
****************
Copy2Lines:
* Routine to copy the new data.
* Parameters:
* A0 = Position of new data.
	LEA	-15680(A0),A1
	MOVEM.L	(A0),D0-D7/A2-A3
	MOVEM.L	D0-D7/A2-A3,(A1)
	MOVEM.L	80(A0),D0-D7/A2-A3
	MOVEM.L	D0-D7/A2-A3,80(A1)
	RTS


*********************
* Big Sprite Routs. *
*********************
******************************
* Logo pre-shifting routine. *
******************************

ShiftLogo:
	LEA	ShiftedLogo,A1
	BSR	CutLogo

	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo,A1
	BSR	CutLogo
	
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*2,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*3,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*4,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*5,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*6,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*7,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*8,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*9,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*10,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*11,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*12,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*13,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*14,A1
	BSR	CutLogo
	LEA	Logo,A0
	BSR	ShiftLogoSub
	LEA	ShiftedLogo+5888*15,A1
	BSR	CutLogo
	
	RTS

ShiftLogoSub:
	
	MOVEQ	#63,D6
	MOVEQ	#3,D7
	
.Loop	
	BSR.S	ShiftLogoSub2

	DBRA	D7,.Loop
	MOVEQ	#3,D7
	LEA	72(A0),A0
	
	DBRA	D6,.Loop

	MOVEQ	#13,D6
	MOVEQ	#3,D7
	
	LEA	ExtraData(PC),A2
	
.Loop2	
	BSR.S	ShiftLogoSub2
		
	MOVE.W	(A2),D1
	LSR.W	#1,D2
	ROXR.W	#1,D1
	MOVE.W	D1,(A2)+

	DBRA	D7,.Loop2
	MOVEQ	#3,D7
	LEA	72(A0),A0
	
	DBRA	D6,.Loop2
	RTS

ShiftLogoSub2:
	MOVE.W	(A0),D0
	MOVE.W	8(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D0,(A0)
	MOVE.W	D1,8(A0)
	
	MOVE.W	D2,D0
	MOVE.W	16(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D1,16(A0)
	
	MOVE.W	D2,D0
	MOVE.W	24(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D1,24(A0)
	
	MOVE.W	D2,D0
	MOVE.W	32(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D1,32(A0)
	
	MOVE.W	D2,D0
	MOVE.W	40(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D1,40(A0)
	
	MOVE.W	D2,D0
	MOVE.W	48(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D1,48(A0)
	
	MOVE.W	D2,D0
	MOVE.W	56(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D1,56(A0)
	
	MOVE.W	D2,D0
	MOVE.W	64(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D1,64(A0)
	
	MOVE.W	D2,D0
	MOVE.W	72(A0),D1
	MOVE.W	D1,D2
	LSR.W	#1,D0
	ROXR.W	#1,D1
	MOVE.W	D1,72(A0)
	
	ADDQ	#2,A0
	RTS
	
CutLogo:
* A1 = Destination.
	LEA	Logo(PC),A0
	
	MOVEQ	#11,D7
	LEA	32(A0),A0
.Loop1	
	REPT	3
	MaskData
	ENDR
	
	LEA	56(A0),A0
	DBRA	D7,.Loop1

	MOVEQ	#3,D7
	LEA	-8(A0),A0
.Loop2	
	REPT	4
	MaskData
	ENDR
	LEA	48(A0),A0
	DBRA	D7,.Loop2

	MOVEQ	#3,D7
.Loop3	
	REPT	5
	MaskData
	ENDR
	LEA	40(A0),A0
	DBRA	D7,.Loop3

	MOVEQ	#7,D7
.Loop4	
	REPT	2
	MaskData
	ENDR
	CopyData
	MaskData
	MaskData
	LEA	40(A0),A0
	DBRA	D7,.Loop4

	MOVEQ	#3,D7
	LEA	-8(A0),A0
.Loop5	
	REPT	2
	MaskData
	ENDR
	CopyData2
	REPT	3
	MaskData
	ENDR
	LEA	24(A0),A0
	DBRA	D7,.Loop5

	MOVEQ	#3,D7
.Loop6	
	REPT	2
	MaskData
	ENDR
	REPT	3
	CopyData
	ENDR
	REPT	2
	MaskData
	ENDR
	LEA	24(A0),A0
	DBRA	D7,.Loop6

	MOVEQ	#7,D7
	LEA	-8(A0),A0
.Loop7	
	REPT	2
	MaskData
	ENDR
	REPT	4
	CopyData
	ENDR
	REPT	3
	MaskData
	ENDR
	LEA	8(A0),A0
	DBRA	D7,.Loop7

	MOVEQ	#3,D7
.Loop8
	REPT	2
	MaskData
	ENDR
	REPT	4
	CopyData
	ENDR
	REPT	2
	MaskData
	ENDR
	LEA	16(A0),A0
	DBRA	D7,.Loop8

	MOVEQ	#3,D7
.Loop9
	REPT	2
	MaskData
	ENDR
	REPT	4
	CopyData
	ENDR
	REPT	3
	MaskData
	ENDR
	LEA	8(A0),A0
	DBRA	D7,.Loop9

	MOVEQ	#7,D7
.Loop10
	REPT	2
	MaskData
	ENDR
	REPT	5
	CopyData
	ENDR
	REPT	2
	MaskData
	ENDR
	LEA	8(A0),A0
	DBRA	D7,.Loop10

	MOVEQ	#3,D7
	LEA	-8(A0),A0
.Loop11
	REPT	3
	MaskData
	ENDR
	REPT	5
	CopyData
	ENDR
	REPT	2
	MaskData
	ENDR
	DBRA	D7,.Loop11

	LEA	ExtraData,A2

	MOVEQ	#3,D7
.Loop12
	REPT	2
	MaskData
	ENDR
	REPT	6
	CopyData
	ENDR
	REPT	2
	MaskData
	ENDR
	EXG	A2,A0
	MaskData
	EXG	A2,A0
	DBRA	D7,.Loop12

	MOVEQ	#9,D7
.Loop13
	REPT	2
	MaskData
	ENDR
	REPT	7
	CopyData
	ENDR
	REPT	1
	MaskData
	ENDR
	EXG	A2,A0
	MaskData
	EXG	A2,A0
	DBRA	D7,.Loop13

	RTS


* Interrupt handlers:
VBLHandler:
	MOVE.W	#$FFFF,VBLFlag
	BSR	Music+28+6
	RTE

	
SECTION DATA
	
	EVEN
	
Palette:
	INCBIN	GLASS.COL

Logo	INCBIN	NEWLOGO.SPR
ExtraData	DCB.B	224,0
	

Message:
	INCBIN	MESSAGE.TXT

EndMessage:

CharacterTable:
	DCB.B	32,0
	DC.B	0,29,46,41,19,30,41,46,42,43,41,41,45,30,27,30
	DC.B	40,31,32,33,34,35,36,37,38,39,28,28,42,30,43,44,40
	DC.B	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
	DC.B	42,46,43,46,0,46
	DC.B	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
	DC.B	42,30,43,30,30
	DCB.B	128,0
	
ScrollPointer	DC.W	0

PositionInText	DC.L	Message
Character		DC.L	0
CharacterPosition	DC.W	0
CharacterFinePosition	DC.W	0
LinkPosition		DC.W	0
SpriteVWavePos		DC.W	0
SpriteWavePos		DC.W	0

VWaveform	
	INCLUDE	VWAVE.S
HWaveform
	INCLUDE	HWAVE.S
	
SECTION BSS

OldPalette	DS.W	16

TrueScreenPosition	DS.L	1
ScreenPos	DS.L	1
ScreenPos2	DS.L	1

OldRes		DS.B	1
OldMode		DS.B	1

OldVBLVec	DS.L	1

	EVEN
		DS.B	1000
StartBuffer	DS.B	16000
Buffer		DS.B	33000

ShiftedLogo	DS.B	95000

ScreenStore	DS.B	325
		DS.B 32000
		DS.B 32000
