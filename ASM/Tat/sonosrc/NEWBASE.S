








				avena_1_9_96:




Tracker_On	EQU	0

ScreenLines	EQU	100
BytesPerLine	EQU	768
Lines		EQU	100
Pixels		EQU	384

Object_Width	EQU	384
Object_Height	EQU	100
Number_Of_Colours EQU	4
Back_Colour	EQU	$00040004

xmax		EQU	383
ymax		EQU	099

noscreens	EQU	3
Keys		EQU	0
Demo		EQU	1

Direction	EQU	0





start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\fish.prg
		opt	nodebug
	ENDC


	IFEQ	Demo
		INCLUDE EQUATES.S
		INCLUDE	TOSSTART.I
	ELSE
		INCLUDE	DEMSTART.I
	ENDC


;--------------------------------------------------------------
Initialize_Routine:
		RTS

Display_Routine:
		LEA	Fish_Sequence_1,A0
		JSR	Init_Sequencer

		BSR	Do_Effects

	IFEQ	Demo
		ILLEGAL
	ELSE
		MOVE.L	(A7)+,A0		;restore stack info
		RTS
	ENDC
