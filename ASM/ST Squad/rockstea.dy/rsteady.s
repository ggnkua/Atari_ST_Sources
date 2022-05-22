********************************
*        Rock-Steady           *
*   Written by John Reynolds.  *
*   (Matrixx of the ST-Squad)  *
*Copyright 1990-1 John Reynolds*
********************************

	OPT	O+,OW-,C-

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

MaxSprites	equ	100

NumberOfLevels	EQU	8
NumberOfLives	EQU	$3

Metal	EQU	4
Brick	EQU	5
Face	EQU	6
Rock	EQU	19
YellowDiamond	EQU	17
BlueDiamond	EQU	18
WallLeft	EQU	10
WallRight	EQU	11
WallSides	EQU	12
On		EQU	14
Off		EQU	13
Ghost		EQU	15
ExtraLife	EQU	16
Teleport	EQU	7
Bonus10		EQU	8
Bonus100	EQU	9

IEA	EQU	$FFFFFA07	Interrupt enable A.
IEB	EQU	$FFFFFA09	Interrupt enable B.
TBCR	EQU	$FFFFFA1B	Timer B control register.
TBDR	EQU	$FFFFFA21	Timer D control register.

**********
* MACROS *
**********

WaitVBL	MACRO
	MOVE.W	VBLFlag(PC),D7
.VBL\@
	CMP.W	VBLFlag(PC),D7
	BEQ.S	.VBL\@
	ENDM

LeaveProgram	MACRO
	CLR.W	-(SP)
	TRAP	#1
	ENDM

GetScreen	MACRO
	CLR.L	-(SP)		Get current screen position.
	MOVE.B	$FFFF8201.W,1(SP)
	MOVE.B	$FFFF8203.W,2(SP)
	MOVE.L	(SP)+,D0
	ENDM

SwapScreens	MACRO

	MOVE.L	ScreenPos(PC),D0
	MOVE.L	ScreenPos2(PC),ScreenPos-P(A5)
	MOVE.L	D0,ScreenPos2-P(A5)
*	WaitVBL
	SetScreen	D0
	WaitVBL
	ENDM

SetScreen	MACRO
	MOVE.L	\1,-(SP)	Set the new screen position.
	MOVE.B	1(SP),$FFFF8201.W
	MOVE.B	2(SP),$FFFF8203.W
	ADDQ.L	#4,SP
	ENDM

SwitchData	MACRO
*NUMBER,X,Y,OFFSET,FROM,TO
	DC.W	\1,\2+\3*SwitchXSize,\4
	DC.B	\5,\6
	ENDM

********************
* Large data stuff *
********************

	JMP	Main

	INCLUDE	ROCK.INC\LANDSLID.LVL
	EVEN
	INCLUDE	ROCK.INC\MAZE.LVL
	EVEN
	INCLUDE	ROCK.INC\STS.LVL
	EVEN
	INCLUDE	ROCK.INC\INNERC.LVL
	EVEN
	INCLUDE	ROCK.INC\BIGONE.LVL
	EVEN
	INCLUDE	ROCK.INC\AARRGH.LVL
	EVEN
	INCLUDE	ROCK.INC\ROCKS.LVL
	EVEN
	INCLUDE	ROCK.INC\BONUS.LVL
	EVEN

IceFont:
	INCBIN	ROCK.INC\ICEFONT.SPR
	
	EVEN
MonoFont:
	DCB.B	64,0
	INCBIN	ROCK.INC\MONOFONT.SPR
	EVEN

Logo:
	INCBIN	ROCK.INC\LOGO.SPR
	
	EVEN

PaletteTable1:
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,1,0,0,0,0
	DC.B	0,1,0,0,0,1,0,0
	DC.B	0,1,0,1,0,1,0,0
	DC.B	1,0,1,0,1,0,1,0
	DC.B	1,0,1,1,1,0,1,0
	DC.B	1,1,1,0,1,1,1,0
	DC.B	1,1,1,1,1,1,1,0

PaletteTable2:
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,$10,0,0,0,0
	DC.B	0,$10,0,0,0,$10,0,0
	DC.B	0,$10,0,$10,0,$10,0,0
	DC.B	$10,0,$10,0,$10,0,$10,0
	DC.B	$10,0,$10,$10,$10,0,$10,0
	DC.B	$10,$10,$10,0,$10,$10,$10,0
	DC.B	$10,$10,$10,$10,$10,$10,$10,0
	
	EVEN
	
* THE 3D Dots Code.
* Written by Archie, with some code based on Griff's stuff.
* Re-written by Matrixx.

CommandCity:
	SUBQ.W	#1,Counter-P(A5)
	TST.W	Counter-P(A5)
	BNE.S	Nothing
Force
	MOVE.L	PointerToCommands(PC),A0
	MOVE.W	(A0)+,D0
	BMI.S	Reset
	SUBQ.W	#1,D0
	BEQ.S	NewObject
	SUBQ.W	#1,D0
	BEQ	NewValues

	MOVE.L	A0,PointerToCommands-P(A5)
Reset:
	MOVE.L	(A0)+,PointerToCommands-P(A5)
	BRA.S	Force
Nothing:
	RTS
NewObject:
	MOVE.L	(A0)+,A1
	MOVE.W	(A1)+,NoSprites-P(A5)
	MOVE.L	A1,ObjectPointer-P(A5)
*Offsets
	MOVE.W	(A0)+,Xoff-P(A5)
	MOVE.W	(A0)+,Yoff-P(A5)
	MOVE.W	(A0)+,Zoff-P(A5)
*Angles
	MOVE.W	(A0)+,XAngle-P(A5)
	MOVE.W	(A0)+,YAngle-P(A5)
	MOVE.W	(A0)+,ZAngle-P(A5)
*Rots
	MOVE.W	(A0)+,xmod+2-P(A5)
	MOVE.W	(A0)+,ymod+2-P(A5)
	MOVE.W	(A0)+,zmod+2-P(A5)
*Offset Adders
	MOVE.W	(A0)+,xom+2-P(A5)
	MOVE.W	(A0)+,yom+2-P(A5)
	MOVE.W	(A0)+,zom+2-P(A5)
*Time
	MOVE.W	(A0)+,Counter-P(A5) 	value

	MOVE.L	A0,PointerToCommands-P(A5)

	BSR	DelSprites
	RTS

NewValues:
*Rots
	MOVE.W	(A0)+,xmod+2-P(A5)
	MOVE.W	(A0)+,ymod+2-P(A5)
	MOVE.W	(A0)+,zmod+2-P(A5)
*Offset Adders
	MOVE.W	(A0)+,xom+2-P(A5)
	MOVE.W	(A0)+,yom+2-P(A5)
	MOVE.W	(A0)+,zom+2-P(A5)
*Time
	MOVE.W	(A0)+,Counter-P(A5) 		value
	MOVE.L	A0,PointerToCommands-P(A5)
	RTS

Counter:
	DC.W	1
ResetVal:
	DC.W	10

TimeToTimeOut:
	DC.W	0
PointerToCommands:
	DC.L	Sequence
NoSprites:
	DC.W	0
*The command language
*Word based
*Comand 0=End command phase
*       1=Display new object (long pointer)
*	followed by x,y,z offsets
*	followed by x,y,z start angles
*	followed by x,y,z rots
*	followed by x,y,z adders
*	followed by time
*	2=Set new   x,y,z rots
*       followed by x,y,z adders
*	followed by time
*       $ffff, reset to dc.l
Sequence:
	DC.W	1		Func
	DC.L	RockShape	Shape
	DC.W	-600,0,2300	Offsets
	DC.W	0,90,0		Start Angles
	DC.W	0,-2,0		Rots
	DC.W	10,0,0		Adders
	DC.W	60		Time

	DC.W	2		New values
	DC.W	0,2,0		Rots
	DC.W	0,0,0		Adders
	DC.W	50		Time
	
	DC.W	2		New values
	DC.W	0,-2,0		Rots
	DC.W	0,0,0		Adders
	DC.W	45		Time

	DC.W	2		New values
	DC.W	2,3,1		Rots
	DC.W	1,0,-10		Adders
	DC.W	200		Time
	
	DC.W	2
	DC.W	2,3,1
	DC.W	-4,0,100
	DC.W	50
	
	DC.W	2
	DC.W	1,1,1
	DC.W	0,0,-10
	DC.W	100
	
	DC.W	2
	DC.W	1,0,0
	DC.W	10,0,0
	DC.W	150

	DC.W	1		Func
	DC.L	SteadyShape	Shape
	DC.W	0,0,5000	Offsets
	DC.W	0,0,0		Start Angles
	DC.W	10,0,0		Rots
	DC.W	0,0,-100	Adders
	DC.W	36		Time

	DC.W	2
	DC.W	1,1,1
	DC.W	0,0,1
	DC.W	360
	
	DC.W	2
	DC.W	0,0,10
	DC.W	0,0,10
	DC.W	72
	
	DC.W	2
	DC.W	1,1,1
	DC.W	0,-6,0
	DC.W	125

	DC.W	1		Func
	DC.L	InnerCircleShape	Shape
	DC.W	-1440,-1440,8200	Offsets
	DC.W	0,0,0		Start Angles
	DC.W	2,2,2		Rots
	DC.W	4,4,-20		Adders
	DC.W	360		Time

	DC.W	2
	DC.W	0,0,0
	DC.W	0,0,0
	DC.W	50
	
	DC.W	2
	DC.W	4,4,4
	DC.W	0,0,0
	DC.W	90

	DC.W	2
	DC.W	0,0,0
	DC.W	0,0,0
	DC.W	25
	
	DC.W	2
	DC.W	10,0,0
	DC.W	5,0,0
	DC.W	36

	DC.W	2
	DC.W	-10,0,0
	DC.W	-5,0,0
	DC.W	72

	DC.W	2
	DC.W	10,0,0
	DC.W	5,0,0
	DC.W	36

	DC.W	2
	DC.W	2,2,2
	DC.W	0,0,100
	DC.W	100

	DC.W	1		Func
	DC.L	StarShape	Shape
	DC.W	0,0,10000	Offsets
	DC.W	0,0,0		Start Angles
	DC.W	1,1,1		Rots
	DC.W	0,0,-100	Adders
	DC.W	70		Time

	DC.W	2
	DC.W	1,1,1
	DC.W	0,0,0
	DC.W	100
	
	DC.W	2
	DC.W	4,2,1
	DC.W	0,0,0
	DC.W	100
	
	DC.W	2
	DC.W	8,4,2
	DC.W	0,0,0
	DC.W	100
	
	DC.W	2
	DC.W	2,2,3
	DC.W	0,0,0
	DC.W	100
	
	DC.W	2
	DC.W	1,1,1
	DC.W	-10,10,0
	DC.W	100

	DC.W	1		Func
	DC.L	RockShape	Shape
	DC.W	0,-720,2300	Offsets
	DC.W	0,0,0		Start Angles
	DC.W	5,-5,5		Rots
	DC.W	0,10,0		Adders
	DC.W	72		Time

	DC.W	2
	DC.W	0,1,0
	DC.W	-20,0,0
	DC.W	100

	DC.W	1		Func
	DC.L	SteadyShape	Shape
	DC.W	0,720,5000	Offsets
	DC.W	0,0,0		Start Angles
	DC.W	10,0,0		Rots
	DC.W	0,-20,-100	Adders
	DC.W	36		Time

	DC.W	2
	DC.W	10,0,0
	DC.W	0,-20,100
	DC.W	36

	DC.W	1
	DC.L	Arrow
	DC.W	0,0,4000
	DC.W	0,0,15
	DC.W	0,0,0
	DC.W	0,5,-40
	DC.W	50

	DC.W	2
	DC.W	10,10,5
	DC.W	0,0,0
	DC.W	36
	
	DC.W	2
	DC.W	0,0,0
	DC.W	0,-5,40
	DC.W	50

	DC.W	1
	DC.L	TheTube
	DC.W	0,0,10000
	DC.W	0,0,0
	DC.W	1,1,1
	DC.W	0,0,-70
	DC.W	100
	
	DC.W	2
	DC.W	1,1,1
	DC.W	0,0,0
	DC.W	50
	
	DC.W	2
	DC.W	2,2,2
	DC.W	0,0,10
	DC.W	50
	
	DC.W	2
	DC.W	1,1,1
	DC.W	0,0,-10
	DC.W	300

	DC.W	2
	DC.W	1,1,1
	DC.W	-20,-20,70
	DC.W	130
	
	DC.W	-1
	DC.L	Sequence

RockShape:
	dc.w	43-1
	dc.w	-200,0,0
	dc.w	-175,0,0
	dc.w	-150,0,0
	dc.w	-200,25,0
	dc.w	-125,25,0
	dc.w	-200,50,0
	dc.w	-175,50,0
	dc.w	-150,50,0
	dc.w	-200,75,0
	dc.w	-150,75,0
	dc.w	-200,100,0
	dc.w	-125,100,0
	
	dc.w	-50,0,0
	dc.w	-25,-5,0
	dc.w	0,0,0
	dc.w	-75,25,0
	dc.w	25,25,0
	dc.w	-80,50,0
	dc.w	30,50,0
	dc.w	-75,75,0
	dc.w	25,75,0
	dc.w	-50,100,0
	dc.w	-25,105,0
	dc.w	0,100,0
	
	dc.w	100,0,0
	dc.w	125,-5,0
	dc.w	150,0,0
	dc.w	75,25,0
	dc.w	70,50,0
	dc.w	75,75,0
	dc.w	100,100,0
	dc.w	125,105,0
	dc.w	150,100,0


	dc.w	200,0,0
	dc.w	275,0,0
	dc.w	200,25,0
	dc.w	250,25,0
	dc.w	200,50,0
	dc.w	225,50,0
	dc.w	200,75,0
	dc.w	250,75,0
	dc.w	200,100,0
	dc.w	275,100,0

SteadyShape:
	DC.W	49-1
	DC.W	-400,-100,0
*	DC.W	-350,-100,0
	DC.W	-325,-100,0
	DC.W	-250,-100,0
	DC.W	-200,-100,0
	DC.W	-150,-100,0
	DC.W	-100,-100,0
	DC.W	-50,-100,0
	DC.W	50,-100,0
	DC.W	150,-100,0
	DC.W	200,-100,0
	DC.W	300,-100,0
	DC.W	400,-100,0
	DC.W	-450,-50,0
	DC.W	-250,-50,0
	DC.W	-150,-50,0
	DC.W	0,-50,0
	DC.W	100,-50,0
	DC.W	150,-50,0
	DC.W	250,-50,0
	DC.W	325,-50,0
	DC.W	375,-50,0
	DC.W	-400,0,0
	DC.W	-250,0,0
	DC.W	-150,0,0
	DC.W	-100,0,0
	DC.W	0,0,0
	DC.W	50,0,0
	DC.W	100,0,0
	DC.W	150,0,0
*	DC.W	250,0,0
	DC.W	350,0,0
	DC.W	-350,50,0
	DC.W	-250,50,0
	DC.W	-150,50,0
	DC.W	0,50,0
	DC.W	100,50,0
	DC.W	150,50,0
	DC.W	250,50,0
	DC.W	350,50,0
	DC.W	-450,100,0
	DC.W	-400,100,0
	DC.W	-250,100,0
	DC.W	-150,100,0
	DC.W	-100,100,0
	DC.W	-50,100,0
	DC.W	0,100,0
	DC.W	100,100,0
	DC.W	150,100,0
	DC.W	200,100,0
	DC.W	350,100,0

InnerCircleShape:
	DC.W	16*3-1
	DC.W	-150,-75,0
	DC.W	-100,-75,0
	DC.W	-50,-75,0
	DC.W	100,-75,0
	DC.W	50,-70,0
	DC.W	150,-70,0
	DC.W	-100,-25,0
	DC.W	25,-25,0
	DC.W	-100,25,0
	DC.W	25,25,0
	DC.W	-150,75,0
	DC.W	-100,75,0
	DC.W	-50,75,0
	DC.W	100,75,0
	DC.W	50,70,0
	DC.W	150,70,0

	DC.W	-150,-75,-50
	DC.W	-100,-75,-50
	DC.W	-50,-75,-50
	DC.W	100,-75,-50
	DC.W	50,-70,-50
	DC.W	150,-70,-50
	DC.W	-100,-25,-50
	DC.W	25,-25,-50
	DC.W	-100,25,-50
	DC.W	25,25,-50
	DC.W	-150,75,-50
	DC.W	-100,75,-50
	DC.W	-50,75,-50
	DC.W	100,75,-50
	DC.W	50,70,-50
	DC.W	150,70,-50
	
	DC.W	-150,-75,50
	DC.W	-100,-75,50
	DC.W	-50,-75,50
	DC.W	100,-75,50
	DC.W	50,-70,50
	DC.W	150,-70,50
	DC.W	-100,-25,50
	DC.W	25,-25,50
	DC.W	-100,25,50
	DC.W	25,25,50
	DC.W	-150,75,50
	DC.W	-100,75,50
	DC.W	-50,75,50
	DC.W	100,75,50
	DC.W	50,70,50
	DC.W	150,70,50

StarShape:
	DC.W	27-1
	DC.W	-300,0,0
	DC.W	0,-300,0
	DC.W	0,0,-300
	DC.W	300,0,0
	DC.W	0,300,0
	DC.W	0,0,300
	DC.W	-200,0,0
	DC.W	0,-200,0
	DC.W	0,0,-200
	DC.W	200,0,0
	DC.W	0,200,0
	DC.W	0,0,200
	DC.W	-100,0,0
	DC.W	0,-100,0
	DC.W	0,0,-100
	DC.W	100,0,0
	DC.W	0,100,0
	DC.W	0,0,100
	DC.W	0,0,0
	DC.W	300,300,300
	DC.W	300,300,-300
	DC.W	300,-300,300
	DC.W	300,-300,-300
	DC.W	-300,300,300
	DC.W	-300,300,-300
	DC.W	-300,-300,300
	DC.W	-300,-300,-300

TheTube:
	dc.w	40-1
	dc.w	-200,-200,0
	dc.w	-200,200,0
	dc.w	-200,0,0
	dc.w	200,-200,0
	dc.w	200,200,0
	dc.w	200,0,0
	dc.w	0,200,0
	dc.w	0,-200,0
	dc.w	-200,-200,100
	dc.w	-200,200,100
	dc.w	-200,0,100
	dc.w	200,-200,100
	dc.w	200,200,100
	dc.w	200,0,100
	dc.w	0,200,100
	dc.w	0,-200,100
	dc.w	-200,-200,200
	dc.w	-200,200,200
	dc.w	-200,0,200
	dc.w	200,-200,200
	dc.w	200,200,200
	dc.w	200,0,200
	dc.w	0,200,200
	dc.w	0,-200,200
	dc.w	-200,-200,-100
	dc.w	-200,200,-100
	dc.w	-200,0,-100
	dc.w	200,-200,-100
	dc.w	200,200,-100
	dc.w	200,0,-100
	dc.w	0,200,-100
	dc.w	0,-200,-100
	dc.w	-200,-200,-200
	dc.w	-200,200,-200
	dc.w	-200,0,-200
	dc.w	200,-200,-200
	dc.w	200,200,-200
	dc.w	200,0,-200
	dc.w	0,200,-200
	dc.w	0,-200,-200

Arrow:
	dc.w	11-1
	dc.w	0,0,-200
	dc.w	0,0,-100
	dc.w	0,0,-100
	dc.w	0,0,0
	dc.w	0,0,100
	dc.w	0,0,200
	dc.w	0,0,300
	dc.w	60,0,250
	dc.w	-60,0,250
	dc.w	-120,0,200
	dc.w	120,0,200

EndOfStuff
	rept	10
	dc.w	0,0,0
	endr

ObjectPointer:
	DC.L	RockShape
XInc
	DC.W	0
YInc
	DC.W	0
ZInc
	DC.W	0
ZAngle:
	DC.W	0
XAngle:
	DC.W	0
YAngle:
	DC.W	0
Xoff:	DC.W	0
Yoff:	DC.W	0
Zoff:	DC.W	0


SineTable:
	INCBIN	ROCK.INC\SIN.BIN
	EVEN
TrigValues
	DCB.W	6,0 

	EVEN
CalcCity:
*Do Rots etc

WaveRots:

	MOVE.W	#360,D1

	MOVE.W	ZAngle-P(A5),D0
zmod	ADD.W	#0,D0
	BMI.S	Zneg
	CMP.W	D1,D0
	BLT.S	ZCont
	SUB.W	D1,D0
	BRA.S	ZCont
Zneg
	ADD.W	D1,D0
ZCont
	MOVE.W	D0,ZAngle-P(A5)
	
	MOVE.W	XAngle-P(A5),D0
xmod	ADD.W	#0,D0
	BMI.S	Xneg
	CMP.W	D1,D0
	BLT.S	XCont
	SUB.W	D1,D0
	BRA.S	XCont
Xneg
	ADD.W	D1,D0
XCont
	MOVE.W	D0,XAngle-P(A5)

	MOVE.W	YAngle-P(A5),D0
ymod	ADD.W	#0,D0
	BMI.S	Yneg
	CMP.W	D1,D0
	BLT.S	YCont
	SUB.W	D1,D0
	BRA.S	YCont
Yneg
	ADD.W	D1,D0
YCont
	MOVE.W	D0,YAngle-P(A5)
	
xom	ADD.W	#0,Xoff-P(A5)
yom	ADD.W	#0,Yoff-P(A5)
zom	ADD.W	#0,Zoff-P(A5)

* Calculate the rotational matrix,first
* and then stick the data into the main code!
* Acording the griff's SMC law (thanks griff!)
* Note to Griff from Archie,
* Hi. I admit that I borrowed some
* Ideas (codeish) from the I.C. Vector screen.
* Sorry!

	LEA 	SineTable(PC),A0	sine table
	LEA 	180(A0),A1		cos=sin+90
	LEA 	TrigValues(PC),A2	and the values go here

	MOVE.W	XAngle-P(A5),D0
	ADD.W 	D0,D0
	MOVE.W 	(A0,D0),(A2)+
	MOVE.W 	(A1,D0),(A2)+

	MOVE.W	YAngle-P(A5),D0
	ADD.W 	D0,D0
	MOVE.W 	(A0,D0),(A2)+
	MOVE.W 	(A1,D0),(A2)+	

	MOVE.W	ZAngle-P(A5),D0
	ADD.W 	D0,D0
	MOVE.W 	(A0,D0),(a2)+
	MOVE.W 	(A1,D0),(a2)

* With the angle data we can now
* make the matrix(x) data
	LEA	TrigValues(pc),a0
*First some multi used values
* sin z * sin x into d6

	MOVE 	8(A0),D0		
	MOVE.W	d0,m6mod+2	(Matrix 3,2!)
	MOVE 	(A0),D6		
	MULS 	D0,D6
	LSL.L 	#2,D6
	SWAP 	D6
* sin z* cos x into d7
	MOVE 	2(A0),D7 		
	MULS 	D0,D7		d0 already=sin z
	LSL.L 	#2,D7
	SWAP	D7

*Now the actual matrix stuff!

*(1,1)
	MOVE 	6(A0),D0  		
	MOVE 	2(A0),D1  		
	MULS 	D1,D0			
	MOVE 	4(A0),D1		
	MULS 	D6,D1			
	SUB.L 	D1,D0
	LSL.L 	#2,D0
	SWAP 	D0			
	MOVE.W 	D0,m1mod+2
*(2,1)
	MOVE 	4(A0),D0		
	MOVE 	2(A0),D1		
	MULS 	D1,D0			
	MOVE 	6(A0),D1		
	MULS 	D6,D1			
	ADD.l 	D1,D0
	LSL.L 	#2,D0
	SWAP 	D0			
	MOVE.W	D0,m2mod+2
*(3,1) 
	MOVE.W 	10(A0),D0		
	MOVE.W	D0,D2
	NEG 	D0
	MOVE.W 	(A0),D1		
	MULS 	D1,D0
	LSL.L 	#2,D0
	SWAP	D0			
	MOVE.W 	D0,m3mod+2
*(1,2) 
	MOVE.W 	4(A0),D0		
	NEG 	D0
	MULS 	D2,D0
	LSL.L 	#2,D0
	SWAP 	D0			
	MOVE 	D0,m4mod+2
*(2,2) 
	MOVE.W 	6(A0),D0
	MOVE.W	D0,D3
	MULS 	D2,D0
	LSL.L 	#2,D0
	SWAP	D0
	MOVE.W 	D0,m5mod+2
*(1,3)
	MOVE.W 	(A0),D1		
	MOVE.W	D1,D4
	MULS 	D1,D3			
	MOVE.W 	4(A0),D1
	MOVE.W	D1,D5		
	MULS 	D7,D1
	ADD.l 	D1,D3
	LSL.L 	#2,D3
	SWAP	D3			
	MOVE.W 	D3,m7mod+2
*(2,3) 
	MULS 	D4,D5			
	MOVE.W 	6(A0),D1		
	MULS 	D7,D1	
	SUB.L 	D1,D5
	LSL.L 	#2,D5
	SWAP 	D5			
	MOVE.W 	D5,m8mod+2
*(3,3) 
	MOVE.W 	10(A0),D0		
	MOVE.W 	2(A0),D1		
	MULS 	D1,D0
	LSL.L	#2,D0
	SWAP	D0			
	MOVE.W 	D0,m9mod+2

* With the matrix data we calculate
* the co-ords!
* Using Griffs idea for SMC (Thanks!)

	MOVE.L	ObjectPointer(pc),A0
	MOVE.L	ScreenPos-P(A5),A3
	ADD.L	#6,A3
	MOVE.L	CurrentDel(pc),A1
	LEA	YShift(pc),A2
	MOVE.W	NoSprites,D7
	CLR.W	Deletable
	MOVEQ	#9,D6

LoopyDo
	MOVEM.W (a0),d0-d2	
	MOVE.W 	d0,d3	
	MOVE.W 	d1,d4			
	MOVE.W 	d2,d5
* Calc x
m1mod	MULS 	#0,d0			
m2mod	MULS 	#0,d1		
m3mod	MULS 	#0,d2
	ADD.L 	d1,d0
	ADD.L 	d2,d0
	LSL.L 	#2,d0
	SWAP	d0		
	ADD.W	Xoff-P(A5),d0
* Calc y
m4mod	MULS 	#0,d3
m5mod	MULS 	#0,d4		
m6mod	MULS 	#0,d5
	ADD.L 	D4,d3
	ADD.L 	D5,d3
	LSL.L 	#2,d3 
	SWAP 	D3		
	ADD.W	Yoff-P(A5),d3
* Calc z 
	MOVEM.W (A0)+,D1/D2/D4
m7mod	MULS 	#0,D1
m8mod	MULS 	#0,D2		
m9mod	MULS 	#0,D4
	ADD.L 	D1,D4
	ADD.L 	D2,D4
	LSL.L 	#2,D4 
	SWAP	D4		
	ADD.W	Zoff-P(A5),D4
* Perspective Bit (Improved due to griff!)
	EXT.L 	D0		extend
	EXT.L 	D3		
	LSL.L 	D6,D0		x*512
	LSL.L 	D6,D3		y*512
	DIVS	D4,D0		x/z
	DIVS 	D4,D3		y/z
	ADD.W 	#160,D0		x centre
	ADD.W 	#100,D3		y centre
**Clipping Bit!
	CMP.W	#200,D3
	BGE.S	.Clipped
	TST.W	D3
	BLE.S	.Clipped
	TST.W	D0
	BLE.S	.Clipped
	CMP.W	#320,D0
	BGE.S	.Clipped
**now plot
*x=d0,y=d3
*Calc X shift etc..
	ADD.W	d0,d0	
	ADD.W	d0,d0	
	MOVE.L	XShift(PC,D0.W),D0
*Calc Y Shift
	ADD.W	D3,D3
	MOVE.W	(A2,D3.W),D1
*And Plot with this wierd table!
	LEA	(A3,D1.W),A4	Add Y shift
	ADD.W	D0,A4		Add X shift
	SWAP	D0
	MOVE.L	A4,(A1)+
	OR.W	D0,(A4)

	ADDQ.W	#1,Deletable-P(A5)
.Clipped
	DBRA 	D7,LoopyDo

	RTS
	
XShift
base	SET	0
	REPT	20
	DC.W	32768,base
	DC.W	16384,base
	DC.W	8192,base
	DC.W	4096,base
	DC.W	2048,base
	DC.W	1024,base
	DC.W	512,base
	DC.W	256,base
	DC.W	128,base
	DC.W	64,base
	DC.W	32,base
	DC.W	16,base
	DC.W	8,base
	DC.W	4,base
	DC.W	2,base
	DC.W	1,base
base	SET	base+8
	ENDR

YShift
line	SET	0
	REPT	200
	DC.W	line
line	SET	line+160
	ENDR

DelSprites:
	MOVE.L	LastDel(PC),A0
	MOVEQ	#0,D0

	MOVE.W	CDeletable-P(A5),D1
	MOVE.W	D1,D2
	ADD.W	#1,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	lea	(A0,D2.W),A0
.Dloop	
	MOVE.L	-(A0),A1
	MOVE.W	D0,(A1)
	DBRA	D1,.Dloop

	MOVE.L	LastDel(PC),A0
	MOVE.L	CurrentDel(PC),LastDel-P(A5)
	MOVE.L	A0,CurrentDel-P(A5)

	MOVE.W	CDeletable(PC),D0
	MOVE.W	Deletable(PC),CDeletable-P(A5)
	MOVE.W	D0,Deletable-P(A5)
	RTS

CDeletable	dc.w	0
Deletable	dc.w	0

CurrentDel:	dc.l	DelTab1
LastDel:	dc.l	DelTab2

	SECTION	BSS

	ds.w	1024
DelTab1:
	ds.w	MaxSprites*3
DelTab2:
	ds.w	MaxSprites*3


******************
* Small Routines *
******************
	SECTION	TEXT
	EVEN
	
* A0 = Screen position.
ClearScreen:
	LEA	32000(A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVE.L	D0,A1
	MOVE.W	#499,D7
.Loop
	MOVEM.L	D0-D6/A1,-(A0)
	MOVEM.L	D0-D6/A1,-(A0)
	DBRA	D7,.Loop
	RTS

****************
* Main program *
****************
Main:
	MOVE.W #-1,-(SP)
	MOVE.W #$58,-(SP)
	TRAP #14
	ADDQ.L #4,SP
	AND.W	#$1FF,D0
	MOVE.W D0,oldvideo
	MOVE.W	#STMODES+VERTFLAG+BPS4+VGA,-(SP)
	MOVE.W #$58,-(SP)
	TRAP #14
	ADDQ.L #4,SP

	LEA	P(PC),A5	Load the main pointer location for all offsets in the program.

	CLR.L	-(SP)		Into supervisor mode.
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.W	#6,SP
	MOVE.L	D0,OldSSP-P(A5)
	
	LEA	Stack(PC),A7	Load program stack.
	
	MOVE.W	#3,-(SP)	Get the screen position.
	TRAP	#14
	ADDQ.W	#2,SP
	MOVE.L	D0,TrueScreenPos-P(A5)

	MOVE.L	#SecondScreenStore+256,D0
	CLR.B	D0
	MOVE.L	D0,ScreenPos-P(A5)

	MOVE.L	#FirstScreenStore+256,D0
	CLR.B	D0
	MOVE.L	D0,ScreenPos2-P(A5)

	SetScreen	ScreenPos2

	LEA	OldPalette(PC),A0	Save the old palette.
	LEA	Palette(PC),A1
	LEA	UpdatePalette(PC),A2
	LEA	$FFFF8240.W,A3
	MOVEQ	#7,D0
SetColLoop:
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A1)+,(A2)+
	DBRA	D0,SetColLoop

SaveStatus:
	MOVE.W	#$2700,SR
	LEA	StatusSaveArea(PC),A0
	
	MOVE.L	$70.W,(A0)+	Store VBL interrupt vector.
	MOVE.L	$118.W,(A0)+	Store keyboard interrupt vector.
	MOVE.L	$120.W,(A0)+	Store HBL interrupt vector.

	LEA	$FFFFFA07.W,A1
	MOVEP.W	(A1),D0
	MOVE.W	D0,(A0)+
	MOVEP.L	12(A1),D0
	MOVE.L	D0,(A0)+
	MOVE.W	#$0140,D0	Keyboard interrupt on only.
	MOVEP.W	D0,(A1)
	MOVEP.W	D0,12(A1)

	MOVEQ	#$12,D0		Mouse off.
	BSR	IKBDSend
	MOVEQ	#$14,D0		Joysticks on.
	BSR	IKBDSend

SetInts:
	MOVE.L	#KeyInterrupt,$118.W	Keyboard Interrupt.
 
	MOVE.L	#QVBL,$70.W		VBL rout.
	MOVE.W	#$2300,SR
	WaitVBL
	WaitVBL
	MOVE.L	#VBLHandler,$70.W	VBL rout.

	;move.w	#$ffff,MusicFlag-P(A5)

	WaitVBL
	
	BSR	PlotSTSLogo
	
	BRA	TitleScreen

********************
* End of init code *
********************

**********************
* Start of game code *
**********************

GameStart:

	MOVE.L	ScreenPos(PC),A0
	BSR	ClearScreen
	MOVE.L	ScreenPos2(PC),A0
	BSR	ClearScreen

	BSR	Password

	MOVEQ	#0,D0
	BSR	UpdateLevel

	MOVE.W	#NumberOfLives,Lives-P(A5)
	MOVEQ	#0,D0
	BSR	UpdateLivesUp

	CLR.L	Score-P(A5)
	MOVEQ	#0,D0
	BSR	UpdateScore	

	CLR.W	DiamondCount-P(A5)
	MOVEQ	#0,D0
	BSR	UpdateDiamonds

	CLR.W	SplatFlag-P(A5)

	CLR.W	ExtraLifeClear-P(A5)
	
***********************
* Start of level code *
***********************
LevelStart:
	MOVE.W	CurrentLevel(PC),D0
	BSR	CopyLevel

	BSR	UpdateInitDiamonds

	CLR.W	LevelDoneFlag-P(A5)

	BSR	ExtraLifeDelete

	MOVEQ	#2,D0
	BSR	FadeOut

	LEA	LevelStartString(PC),A2
	MOVE.L	ScreenPos2(PC),A0
	BSR	Print
	
	MOVE.W	CurrentLevel(PC),D0
	SUBQ	#1,D0
	MULU	#6,D0
	LEA	PasswordPrint(PC),A2
	LEA	Passwords(PC),A1
	ADD.W	D0,A1
	MOVE.L	(A1)+,(A2)
	MOVE.W	(A1),4(A2)
	MOVE.L	ScreenPos2(PC),A0
	BSR	Print
	
	LEA	Palette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn
	
	BSR	PauseKeyOrJoy

	MOVEQ	#0,D0
	BSR	UpdateLivesUp

	MOVEQ	#1,D0
	BSR	FadeOut

	LEA	StatusString(PC),A2
	MOVE.L	ScreenPos(PC),A0
	BSR	Print
	LEA	StatusString(PC),A2
	MOVE.L	ScreenPos2(PC),A0
	BSR	Print

	LEA	Level+10,A0
	LEA	OldXPosition(PC),A1
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0),(A1)+

	BSR	Update
	SwapScreens
	BSR	Update
	SwapScreens

	LEA	Palette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn
	
	BRA.S	IntoLoop
	
MainLoop:

	;CMPI.W	#4,VBLFlag-P(A5)
	;BMI.S	MainLoop

IntoLoop:	
	CLR.W	VBLFlag-P(A5)
	
	SwapScreens

	BSR	Update

	BSR	ObjectMove

	BSR	GhostMove

	TST.W	SplatFlag-P(A5)
	BNE	KerSplatt
	
	BSR	Move
	
	TST.W	LevelDoneFlag-P(A5)
	BNE	LevelDone
	
	BSR	ReadKeyboard
	
	CMPI.B	#'Q',D1
	BEQ	Suicide
	
	ROR.W	#8,D1
	CMPI.B	#$44,D1
	BNE.S	MainLoop
	
**********************
* End of the program *
**********************

Exit:

	MOVE.L	#QVBL,$70.W
	WaitVBL
	
	move.w	#$2700,sr

	LEA	OldPalette(PC),A0	Restore the old palette.
	LEA	$FFFF8240.W,A2
	MOVEQ	#7,D0
RestoreColLoop:
	MOVE.L	(A0)+,(A2)+
	DBRA	D0,RestoreColLoop


	MOVE.B	OldResolution(PC),$FFFF8260.W
	SetScreen	TrueScreenPos(PC)

	MOVEQ	#$08,D0		Mouse off.
	BSR	IKBDSend

RestoreStatus:
	LEA	StatusSaveArea(PC),A0
	MOVE.L	(A0)+,$70.W	Restore VBL interrupt vector.
	MOVE.L	(A0)+,$118.W	Restore keyboard interrupt vector.
	MOVE.L	(A0)+,$120.W	Restore HBL interrupt vector.

	LEA	$FFFFFA07.W,A1
	MOVE.W	(A0)+,D0
	MOVEP.W	D0,(A1)
	MOVE.L	(A0)+,D0
	MOVEP.L	D0,12(A1)

	;move.l	OldTimerA,$134.w
	
	move.w	#$2300,sr
	
	MOVE.L	OldSSP(PC),-(SP)	Out of supervisor mode.
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.W	#6,SP
	MOVE.W oldvideo(PC),-(SP)
	MOVE.W #$58,-(SP)
	TRAP #14
	ADDQ.L #4,SP

	
	LeaveProgram
oldvideo
	dc.w 0

************
* Routines *
************

Suicide:
	MOVEQ	#1,D0
	BSR	UpdateLivesDown
	TST.W	Lives-P(A5)
	BEQ	GameOver

	CLR.W	DiamondCount-P(A5)

	MOVEQ	#0,D0
	BSR	UpdateDiamonds

	MOVE.L	ScreenPos(PC),A0
	BSR	ClearScreen

	BRA	LevelStart

ExtraLifeDelete:
	
	LEA	ExtraLifeClear(PC),A0
	MOVE.W	(A0)+,D0
	CMP.W	CurrentLevel(PC),D0
	BNE.S	.Done
	LEA	Level,A1
	ADD.W	2(A1),A1
	MOVE.W	(A1)+,D2
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MULU	D2,D1
	ADD.W	D1,D0
	CLR.B	2(A1,D0.W)
	
.Done
	RTS


LevelDone:
	SwapScreens
	BSR	Update
	SwapScreens
	BSR	Update
	SwapScreens
	MOVEQ	#10,D0
.Wait
	WaitVBL
	DBRA	D0,.Wait

	MOVEQ	#1,D0
	BSR	FadeOut

	MOVE.L	ScreenPos2(PC),A0
	LEA	LevelDoneText(PC),A2
	BSR	Print

	LEA	Palette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn

	BSR	PauseKeyOrJoy

	MOVEQ	#1,D0
	BSR	UpdateLevel
	
.Loop
	BSR	ReadJoystick
	BTST	#7,D0
	BNE.S	.Loop

	CMPI.W	#NumberOfLevels,CurrentLevel-P(A5)
	BGT.S	GameDone

	CLR.W	DiamondCount-P(A5)

	MOVE.L	ScreenPos(PC),A0
	BSR	ClearScreen

	BRA	LevelStart

GameDone:

	MOVEQ	#1,D0
	BSR	FadeOut
	
	MOVE.L	ScreenPos2(PC),A0
	LEA	GameDoneText(PC),A2
	BSR	Print

	LEA	IcePalette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn
	
	LEA	UpdateString+3(PC),A0
	LEA	LastScoreAlter(PC),A1
	MOVEQ	#7,D0
.ScoreLoop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,.ScoreLoop

	BSR	PauseKeyOrJoy
.Loop
	BSR	ReadJoystick
	BTST	#7,D0
	BNE.S	.Loop
	
	BRA	HighScoreCheck

Update:
	MOVE.W	XPosition(PC),D0
	MOVE.W	YPosition(PC),D1

	SUB.W	#10,D0
	BPL.S	.XOk1
	MOVEQ	#0,D0
.XOk1
	LEA	Level,A0
	ADD.W	2(A0),A0
	MOVE.W	(A0)+,D2
	MOVE.W	D2,D3
	SUB.W	#20,D3
	CMP.W	D3,D0
	BMI.S	.XOk2
	SUB.W	#20,D2
	MOVE.W	D2,D0
.XOk2
	SUBQ.W	#6,D1
	BPL.S	.YOk1
	MOVEQ	#0,D1
.YOk1
	MOVE.W	(A0),D2
	MOVE.W	D2,D3
	SUB.W	#12,D3
	CMP.W	D3,D1
	BMI.S	.YOk2
	SUB.W	#12,D2
	MOVE.W	D2,D1
.YOk2
	BSR	DrawScreen
	
	MOVE.L	ScreenPos(PC),A0
	LEA	UpdateString(PC),A2
	BSR	Print
	
	RTS


Swap1:
	MOVE.L	A2,A6
	MOVE.L	A3,A2
	MOVE.L	A4,A3
	MOVE.L	A5,A4
	MOVE.L	A6,A5
	RTS

Swap2:
	EXG.L	A2,A4
	EXG.L	A3,A5
	RTS

	
* Routine to draw the screen.
* Parameters:
* D0.W = X position of start.
* D1.W = Y position of start.

DrawScreen:
	LEA	Level,A1
	ADD.W	2(A1),A1
	MOVE.L	ScreenPos(PC),A0
	LEA	GraphicBlocks(PC),A2
	LEA	2560(A2),A3
	LEA	2560(A3),A4
	LEA	2560(A4),A5
	
	BTST	#0,D0
	BEQ.S	.J1
	BSR.S	Swap1
.J1
	BTST	#1,D0
	BEQ.S	.J2
	BSR.S	Swap2
.J2
	BTST	#0,D1
	BEQ.S	.J3
	BSR.S	Swap1
.J3
	BTST	#1,D1
	BEQ.S	.J4
	BSR.S	Swap2
.J4

	MOVE.W	(A1)+,D4		X-size of the level.
	LEA	2(A1,D0.W),A1		Get offset start.
	MOVE.W	D4,D5			Copy X-size.
	MULU	D1,D5			Multiply by Y-offset.
	ADD.W	D5,A1			Add it to data pointer.
	SUB.W	#20,D4			Calculate offset to next line.
	
	MOVEQ	#11,D6			12 lines to plot.

	MOVEQ	#4,D7			20 columns to plot.
.PlotLoop
	MOVEQ	#0,D0			Clear D0.
	MOVE.B	(A1)+,D0		Get object code.
	LSL.W	#7,D0			* 128 for graphics offset.
	LEA	0(A2,D0.W),A6		Get block location.
OFFSET	SET	0
	REPT	8
	MOVEM.L	(A6)+,D0-D3		Get data for first two lines.
	MOVEM.L	D0-D1,OFFSET(A0)		Plot it.
	MOVEM.L	D2-D3,OFFSET+160(A0)
OFFSET	SET	OFFSET+320
	ENDR
	ADDQ.L	#8,A0			Point to next block on screen.

	MOVEQ	#0,D0			Clear D0.
	MOVE.B	(A1)+,D0		Get object code.
	LSL.W	#7,D0			* 128 for graphics offset.
	LEA	0(A3,D0.W),A6		Get block location.
OFFSET	SET	0
	REPT	8
	MOVEM.L	(A6)+,D0-D3		Get data for first two lines.
	MOVEM.L	D0-D1,OFFSET(A0)		Plot it.
	MOVEM.L	D2-D3,OFFSET+160(A0)
OFFSET	SET	OFFSET+320
	ENDR
	ADDQ.L	#8,A0			Point to next block on screen.

	MOVEQ	#0,D0			Clear D0.
	MOVE.B	(A1)+,D0		Get object code.
	LSL.W	#7,D0			* 128 for graphics offset.
	LEA	0(A4,D0.W),A6		Get block location.
OFFSET	SET	0
	REPT	8
	MOVEM.L	(A6)+,D0-D3		Get data for first two lines.
	MOVEM.L	D0-D1,OFFSET(A0)		Plot it.
	MOVEM.L	D2-D3,OFFSET+160(A0)
OFFSET	SET	OFFSET+320
	ENDR
	ADDQ.L	#8,A0			Point to next block on screen.

	MOVEQ	#0,D0			Clear D0.
	MOVE.B	(A1)+,D0		Get object code.
	LSL.W	#7,D0			* 128 for graphics offset.
	LEA	0(A5,D0.W),A6		Get block location.
OFFSET	SET	0
	REPT	8
	MOVEM.L	(A6)+,D0-D3		Get data for first two lines.
	MOVEM.L	D0-D1,OFFSET(A0)		Plot it.
	MOVEM.L	D2-D3,OFFSET+160(A0)
OFFSET	SET	OFFSET+320
	ENDR
	ADDQ.L	#8,A0
	DBRA	D7,.PlotLoop
	
	MOVEQ	#4,D7			20 coloumns to plot.
	BSR	Swap1
	ADD.W	D4,A1			Point to correct data.
	LEA	2400(A0),A0		Next line on the screen.
	DBRA	D6,.PlotLoop		Loop.

	LEA	P(PC),A5
	RTS				All done!!

********************
* Movement routine *
********************

Move:
	MOVEQ	#0,D2
	BSR	ReadJoystick

	LEA	KeyTable(PC),A1

	TST.B	$48(A1)
	BEQ.S	.NoKey1
	BSET	#0,D0
.NoKey1
	TST.B	$50(A1)
	BEQ.S	.NoKey2
	BSET	#1,D0
.NoKey2
	TST.B	$4B(A1)
	BEQ.S	.NoKey3
	BSET	#2,D0
.NoKey3
	TST.B	$4D(A1)
	BEQ.S	.NoKey4
	BSET	#3,D0
.NoKey4

	LEA	Level,A0
	ADD.W	2(A0),A0

	TST.W	FireFlag-P(A5)
	BNE.S	.NoFire
	BTST	#7,D0
	BNE	ThrowSwitch
	TST.B	$39(A1)
	BNE	ThrowSwitch
.NoFire

	
	BTST	#7,D0
	BNE.S	.NoFire2
	TST.B	$39(A1)
	BNE	.NoFire2
	CLR.W	FireFlag-P(A5)
.NoFire2
	
	TST.B	D0
	BNE.S	.JoyMove
	CLR.W	DiagonalMoveFlag-P(A5)
	BRA	PosCheck
.JoyMove
	
	NOT.W	DiagonalMoveFlag-P(A5)
	TST.W	DiagonalMoveFlag-P(A5)
	BEQ.S	.Move2
	
	BTST	#0,D0			Up?
	BEQ.S	.Branch1		No.
	SUBQ.W	#1,YPosition-P(A5)	Move up.
	BPL	PosCheck		Not off the top then Ok.
	MOVE.W	D2,YPosition-P(A5)	Reset to the top otherwise.
	BRA	PosCheck
.Branch1
	BTST	#1,D0			Down?
	BEQ.S	.Branch2		No.
	MOVE.W	2(A0),D3		Get Y size.
	SUB.W	#2,D3			Fudge factor.
	CMP.W	YPosition-P(A5),D3	Off the bottom?
	BMI.S	.Branch2		No.
	ADDQ.W	#1,YPosition-P(A5)	Then move down.
	BRA	PosCheck
.Branch2
	BTST	#2,D0			Left?
	BEQ.S	.Branch3		No.
	SUBQ.W	#1,XPosition-P(A5)	Move left.
	BPL.S	PosCheck		Too far?
	MOVE.W	D2,XPosition-P(A5)	Yes, then reset to left.
	BRA.S	PosCheck
.Branch3
	BTST	#3,D0			Right?
	BEQ.S	.Branch4		No.
	MOVE.W	(A0),D3	Get X size.
	SUB.W	#2,D3			Fudge factor.
	CMP.W	XPosition-P(A5),D3	Too far right?
	BMI.S	.Branch4		Yes, then skip.
	ADDQ.W	#1,XPosition-P(A5)	Move right.
	BRA.S	PosCheck
.Branch4
	BRA.S	PosCheck
.Move2:
	BTST	#2,D0			Left?
	BEQ.S	.Branch1b		No.
	SUBQ.W	#1,XPosition-P(A5)	Move left.
	BPL.S	PosCheck		Too far?
	MOVE.W	D2,XPosition-P(A5)	Yes, then reset to left.
	BRA.S	PosCheck
.Branch1b
	BTST	#3,D0			Right?
	BEQ.S	.Branch2b		No.
	MOVE.W	(A0),D3	Get X size.
	SUB.W	#2,D3			Fudge factor.
	CMP.W	XPosition-P(A5),D3	Too far right?
	BMI.S	.Branch2b		Yes, then skip.
	ADDQ.W	#1,XPosition-P(A5)	Move right.
	BRA.S	PosCheck
.Branch2b
	BTST	#0,D0			Up?
	BEQ.S	.Branch3b		No.
	SUBQ.W	#1,YPosition-P(A5)	Move up.
	BPL.S	PosCheck		Not off the top then Ok.
	MOVE.W	D2,YPosition-P(A5)	Reset to the top otherwise.
	BRA.S	PosCheck
.Branch3b
	BTST	#1,D0			Down?
	BEQ.S	.Branch4b		No.
	MOVE.W	2(A0),D3		Get Y size.
	SUB.W	#2,D3			Fudge factor.
	CMP.W	YPosition-P(A5),D3	Off the bottom?
	BMI.S	.Branch4b		No.
	ADDQ.W	#1,YPosition-P(A5)	Then move down.
.Branch4b

PosCheck:
	MOVE.W	XPosition(PC),D1
	MOVE.W	YPosition(PC),D2
	LEA	ClearMap(PC),A1
	MOVE.W	(A0),D3
	MULU	D3,D2
	ADD.W	D2,D1
	MOVE.B	4(A0,D1.W),D3
	CMPI.B	#Metal,D3
	BEQ	NoMove
	CMPI.B	#Brick,D3
	BEQ	NoMove
	CMPI.B	#Rock,D3
	BEQ	BoulderPush
	CMPI.B	#YellowDiamond,D3
	BEQ	DiamondCollect
	CMPI.B	#BlueDiamond,D3
	BEQ	DiamondCollect
	CMPI.B	#Ghost,D3
	BEQ	IntoGhost
	CMPI.B	#Bonus10,D3
	BEQ	CollectBonus10
	CMPI.B	#Bonus100,D3
	BEQ	CollectBonus100
	CMPI.B	#Teleport,D3
	BEQ	BeamMeUpScottie
	CMPI.B	#ExtraLife,D3
	BEQ	CollectExtraLife
	
	CMPI.B	#WallLeft,D3
	BMI.S	PushReturn
	CMPI.B	#Ghost,D3
	BMI.S	NoMove

PushReturn:
	MOVE.W	OldXPosition(PC),D1
	MOVE.W	OldYPosition(PC),D2
	LEA	Level,A0
	ADD.W	2(A0),A0
	MOVE.W	(A0),D3
	MULU	D3,D2
	ADD.W	D2,D1
	CLR.B	4(A0,D1.W)
	MOVE.L	XPosition(PC),OldXPosition-P(A5)
	
	MOVE.W	XPosition(PC),D1
	MOVE.W	YPosition(PC),D2
	MULU	D3,D2
	ADD.W	D2,D1
	MOVE.B	#Face,4(A0,D1.W)

	LEA	ClearMap,A1

	TST.W	YPosition-P(A5)
	BEQ.S	.NoSplat
	SUB.W	D3,D1
	TST.B	(A1,D1)
	BEQ.S	.NoSplat
	MOVE.W	#-1,SplatFlag-P(A5)
.NoSplat

	RTS				All done.

NoMove:
	MOVE.L	OldXPosition(PC),XPosition-P(A5)
	RTS

BoulderPush:
	LEA	4(A0,D1.W),A0
	MOVE.W	XPosition(PC),D2
	CMP.W	OldXPosition(PC),D2
	BEQ.S	NoMove
	BMI.S	.Left
.Right
	TST.B	1(A0)
	BNE.S	NoMove
	MOVE.B	#Rock,1(A0)
	BRA.S	PushReturn
.Left
	TST.B	-1(A0)
	BNE	NoMove
	MOVE.B	#Rock,-1(A0)
	BRA	PushReturn

DiamondCollect:
	MOVEQ	#$10,D0
	BSR	UpdateScore
	MOVEQ	#1,D0
	BSR	UpdateDiamonds
	MOVE.W	Level+8,D0
	CMP.W	DiamondCount(PC),D0
	BLE.S	.LevelDone
	BRA	PushReturn

.LevelDone:
	MOVE.W	#-1,LevelDoneFlag-P(A5)
	BRA	PushReturn
	
IntoGhost:
	MOVE.W	#-1,SplatFlag-P(A5)
	BRA.S	NoMove

ThrowSwitch:

	MOVE.W	#-1,FireFlag-P(A5)

	LEA	Level,A0
	ADD.W	2(A0),A0
	MOVE.W	(A0)+,D0
	LEA	XPosition(PC),A1
	MOVE.W	(A1)+,D1
	MOVE.W	(A1)+,D2
	MULU	D0,D2
	ADD.W	D2,D1
	LEA	2(A0,D1.W),A0
	MOVEQ	#0,D0
	MOVE.B	-1(A0),D0
	CMPI.B	#Off,D0
	BNE.S	.B1
	LEA	-1(A0),A0
	BRA	SwitchOn
.B1
	CMPI.B	#On,D0
	BNE.S	.B2
	LEA	-1(A0),A0
	BRA	SwitchOff
.B2
	MOVE.B	1(A0),D0
	CMPI.B	#Off,D0
	BNE.S	.B3
	LEA	1(A0),A0
	BRA	SwitchOn
.B3
	CMPI.B	#On,D0
	BNE.S	.B4
	LEA	1(A0),A0
	BRA	SwitchOff
.B4

	RTS
	
SwitchOn:

	LEA	Level,A1
	ADD.W	6(A1),A1
	MOVE.W	YPosition(PC),D1
	MOVE.L	A1,A2
.Loop
	CMP.W	(A2),D1
	BEQ.S	.FoundSwitch
	TST.W	(A2)
	BMI.S	.Done
	ADDQ	#6,A2
	BRA.S	.Loop

.Done	RTS

.FoundSwitch
	MOVE.B	#On,(A0)
	MOVE.W	2(A2),D0
	BRA.S	DoSwitch

SwitchOff:
	LEA	Level,A1
	ADD.W	6(A1),A1
	MOVE.W	YPosition(PC),D1
	MOVE.L	A1,A2
.Loop
	CMP.W	(A2),D1
	BEQ.S	.FoundSwitch
	TST.W	(A2)
	BMI.S	.Done
	ADDQ	#6,A2
	BRA.S	.Loop

.Done	RTS

.FoundSwitch
	MOVE.B	#Off,(A0)
	MOVE.W	4(A2),D0
*	BRA.S	DoSwitch

DoSwitch:

	LEA	0(A1,D0.W),A1
	LEA	Level,A2
	ADD.W	2(A2),A2
	ADDQ	#4,A2
.Loop
	MOVE.L	A2,A0
	MOVE.W	(A1)+,D7	Count.
	BEQ.S	.Done
	SUBQ.W	#1,D7
	MOVE.W	(A1)+,D0	Start.
	MOVE.W	(A1)+,D1	Offset.
	MOVE.B	(A1)+,D2	Change from..
	MOVE.B	(A1)+,D3	 to..
	ADD.W	D0,A0
	TST.B	D2
	BMI.S	.Loop3
.Loop2
	CMP.B	(A0),D2
	BNE.S	.NoChange
	MOVE.B	D3,(A0)
.NoChange
	ADD.W	D1,A0
	DBRA	D7,.Loop2
	BRA	.Loop

.Done	RTS

.Loop3
	MOVE.B	D3,(A0)
	ADD.W	D1,A0
	DBRA	D7,.Loop3
	BRA	.Loop

CollectBonus10:
	MOVE.L	#$10,D0
	BSR	UpdateScore
	BRA	PushReturn

CollectBonus100:
	MOVE.L	#$100,D0
	BSR	UpdateScore
	BRA	PushReturn

CollectExtraLife:
	MOVEQ	#1,D0
	BSR	UpdateLivesUp
	MOVE.W	CurrentLevel(PC),ExtraLifeClear-P(A5)
	MOVE.L	XPosition(PC),ExtraLifeClear+2-P(A5)
	
	BRA	PushReturn

BeamMeUpScottie:

	LEA	Level,A1
	ADD.W	14(A1),A1
	LEA	XPosition(PC),A0
	MOVE.W	(A0),D0
	MOVE.W	2(A0),D1
.Loop
	TST.W	(A1)
	BMI.S	.NoTeleport
	
	CMP.W	(A1)+,D0
	BNE.S	.Add6
	
	CMP.W	(A1)+,D1
	BNE.S	.Add4
	
	MOVE.L	(A1)+,(A0)+

	LEA	Level,A0
	ADD.W	2(A0),A0
	
*	BRA	Nomove
	BRA	PosCheck

.Add6
	ADDQ.L	#6,A1
	BRA.S	.Loop
.Add4

	ADDQ.L	#4,A1
	BRA.S	.Loop
	
.NoTeleport
	BRA	NoMove


GhostMove:

	LEA	Level,A1
	MOVE.L	A1,A0
	ADD.W	4(A1),A1
	ADD.W	2(A0),A0
	MOVE.W	(A0)+,D6
	MOVE.W	(A0)+,D5
	MOVE.W	D6,D4
	NEG.W	D4
.Loop
	MOVE.W	(A1)+,D0
	BEQ	.Skip
	CMPI.W	#-1,D0
	BEQ	.Finished

	MOVE.W	(A1)+,D0
	MOVE.W	(A1)+,D1
	MULU	D6,D1
	ADD.W	D1,D0
	MOVEQ	#0,D3
	LEA	(A0,D0.W),A2
	MOVE.B	(A2),D3
	CMPI.B	#15,D3
	BNE	.KillGhost
	MOVE.W	(A1)+,D2
	BEQ.S	.GhostRight
	CMPI.W	#1,D2
	BEQ	.GhostUp
	CMPI.W	#2,D2
	BEQ	.GhostLeft
.GhostDown:
	MOVE.W	D5,D0
	SUBQ.W	#1,D0
	CMP.W	-4(A1),D0
	BLE.S	.StuckDown
	CMPI.B	#Face,(A2,D6)
	BEQ	.GhostSplat
	TST.B	(A2,D6)
	BNE.S	.StuckDown
	MOVE.B	#Ghost,(A2,D6)
	CLR.B	(A2)
	ADDQ.W	#1,-4(A1)
	BRA	.Loop
.StuckDown
	TST.W	-6(A1)
	BEQ.S	.StuckDown3
	CMPI.B	#Face,-1(A2)
	BEQ	.GhostSplat
	TST.B	-1(A2)
	BEQ.S	.StuckDown2
.StuckDown3
	CLR.W	-2(A1)
	BRA	.Loop
.StuckDown2
	MOVE.W	#2,-2(A1)
	BRA	.Loop

.GhostRight:
	MOVE.W	D6,D0
	SUBQ.W	#1,D0
	CMP.W	-6(A1),D0
	BLE.S	.StuckRight
	CMPI.B	#Face,1(A2)
	BEQ	.GhostSplat
	TST.B	1(A2)
	BNE.S	.StuckRight
	MOVE.B	#Ghost,1(A2)
	CLR.B	(A2)
	ADDQ.W	#1,-6(A1)
	BRA	.Loop
.StuckRight
	MOVE.W	D5,D0
	SUBQ.W	#1,D0
	CMP.W	-4(A1),D0
	BLE.S	.StuckRight3
	CMPI.B	#Face,(A2,D6.W)
	BEQ	.GhostSplat
	TST.B	(A2,D6.W)
	BEQ.S	.StuckRight2
.StuckRight3
	MOVE.W	#1,-2(A1)
	BRA	.Loop
.StuckRight2
	MOVE.W	#3,-2(A1)
	BRA	.Loop

.GhostUp:
	TST.W	-4(A1)
	BEQ.S	.StuckUp
	CMPI.B	#Face,(A2,D4)
	BEQ	.GhostSplat
	CMPI.B	#Rock,(A2,D4)
	BNE.S	.GhostAlive
	MOVE.L	A2,A3
	BSR	GhostHit
.GhostAlive
	TST.B	(A2,D4)
	BNE.S	.StuckUp
	MOVE.B	#Ghost,(A2,D4)
	CLR.B	(A2)
	SUBQ.W	#1,-4(A1)
	BRA	.Loop
.StuckUp
	MOVE.W	D6,D0
	SUBQ.W	#1,D0
	CMP.W	-6(A1),D0
	BLE.S	.StuckUp3
	CMPI.B	#Face,1(A2)
	BEQ	.GhostSplat
	TST.B	1(A2)
	BEQ.S	.StuckUp2
.StuckUp3
	MOVE.W	#2,-2(A1)
	BRA	.Loop
.StuckUp2
	CLR.W	-2(A1)
	BRA	.Loop

.GhostLeft:
	TST.W	-6(A1)
	BEQ.S	.StuckLeft
	CMPI.B	#Face,-1(A2)
	BEQ.S	.GhostSplat
	TST.B	-1(A2)
	BNE.S	.StuckLeft
	MOVE.B	#Ghost,-1(A2)
	CLR.B	(A2)
	SUBQ.W	#1,-6(A1)
	BRA	.Loop
.StuckLeft
	TST.W	-4(A1)
	BEQ.S	.StuckLeft3
	CMPI.B	#Face,(A2,D4)
	BEQ	.GhostSplat
	TST.B	(A2,D4)
	BEQ.S	.StuckLeft2
.StuckLeft3
	MOVE.W	#3,-2(A1)
	BRA	.Loop
.StuckLeft2
	MOVE.W	#1,-2(A1)
	BRA	.Loop

.Skip

	ADDQ	#6,A1
	BRA	.Loop
	
.KillGhost
	CLR.W	-6(A1)
	ADDQ	#2,A1
	BRA	.Loop

.GhostSplat
	MOVE.W	#-1,SplatFlag-P(A5)
	BRA	.Loop

.Finished
	RTS


* D0 = Amount to add on.
UpdateScore:
	LEA	ABCDStore2(PC),A0
	LEA	ABCDStore2+4(PC),A1
	MOVE.L	Score(PC),-4(A0)
	MOVE.L	#$2000,(A0)
	ANDI.W	#$E000,-2(A0)
	MOVE.W	#0,CCR
	ABCD.B	-(A1),-(A0)
	ABCD.B	-(A1),-(A0)
	ABCD.B	-(A1),-(A0)
	ABCD.B	-(A1),-(A0)
	MOVE.L	(A0),D1
	LEA	Score+4(PC),A0
	LEA	UpdateString+3(PC),A1
	LEA	ABCDStore+4(PC),A2
	MOVE.L	D0,-4(A2)
	MOVE.W	#0,CCR
	ABCD.B	-(A2),-(A0)
	ABCD.B	-(A2),-(A0)
	ABCD.B	-(A2),-(A0)
	ABCD.B	-(A2),-(A0)
	CMP.L	(A0),D1
	BLE.S	.ExtraLife
.ExtraLifeReturn
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#48,D2
	MOVEQ	#3,D3
	MOVEQ	#$F,D4
.Loop
	MOVE.B	(A0)+,D0
	MOVE.B	D0,D1
	LSR.B	#4,D1
	ADD.B	D2,D1
	MOVE.B	D1,(A1)+
	AND.B	D4,D0
	ADD.B	D2,D0
	MOVE.B	D0,(A1)+
	DBRA	D3,.Loop
	RTS

.ExtraLife:
	MOVE.L	A0,-(SP)
	MOVE.L	A1,-(SP)
	
	MOVEQ	#1,D0
	BSR	UpdateLivesUp
	
	MOVE.L	(SP)+,A1
	MOVE.L	(SP)+,A0

	BRA.S	.ExtraLifeReturn
	
UpdateLevel:
	LEA	CurrentLevel+2(PC),A0
	LEA	LevelNo(PC),A1
	LEA	ABCDStore+2(PC),A2
	MOVE.W	D0,-2(A2)
	MOVE.W	#0,CCR
	ABCD.B	-(A2),-(A0)
	ABCD.B	-(A2),-(A0)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#48,D2
	MOVEQ	#3,D3
	MOVEQ	#$F,D4
	MOVE.W	(A0),D0
	MOVE.W	D0,D1
	LSR.W	#4,D1
	AND.W	D4,D1
	AND.W	D4,D0
	ADD.W	D2,D0
	ADD.W	D2,D1
	MOVE.B	D1,(A1)+
	MOVE.B	D0,(A1)+
	RTS

UpdateInitDiamonds:
	MOVE.W	Level+8,D0
	LEA	DiPerLevel1+3(PC),A0
	LEA	DiPerLevel2+3(PC),A1
	MOVEQ	#$F,D2
	MOVEQ	#'0',D3
	MOVE.B	D0,D1
	AND.B	D2,D1
	ADD.B	D3,D1
	MOVE.B	D1,-(A0)
	MOVE.B	D1,-(A1)

	MOVE.B	D0,D1
	LSR.B	#4,D1
	ADD.B	D3,D1
	MOVE.B	D1,-(A0)
	MOVE.B	D1,-(A1)
	
	MOVE.W	D0,D1
	LSR.W	#8,D1
	AND.B	D2,D1
	ADD.B	D3,D1
	MOVE.B	D1,-(A0)
	MOVE.B	D1,-(A1)
	
	RTS

* D0 = Amount to add on.
UpdateDiamonds:
	LEA	DiamondCount+2(PC),A0
	LEA	UpdateString+15(PC),A1
	LEA	ABCDStore+2(PC),A2
	MOVE.W	D0,-2(A2)
	MOVE.W	#0,CCR
	ABCD.B	-(A2),-(A0)
	ABCD.B	-(A2),-(A0)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#48,D2
	MOVEQ	#$F,D4
	MOVE.B	(A0)+,D1
	AND.B	D4,D1
	ADD.B	D2,D1
	MOVE.B	D1,(A1)+
	MOVE.B	(A0)+,D0
	MOVE.B	D0,D1
	LSR.B	#4,D1
	ADD.B	D2,D1
	MOVE.B	D1,(A1)+
	AND.B	D4,D0
	ADD.B	D2,D0
	MOVE.B	D0,(A1)+
	
	RTS


* D0 = Amount to add on.
UpdateLivesUp:
	LEA	Lives+2(PC),A0
	LEA	UpdateString+21(PC),A1
	LEA	LivesString(PC),A3
	LEA	ABCDStore+2(PC),A2
	MOVE.W	D0,-2(A2)
	MOVE.W	#0,CCR
	ABCD.B	-(A2),-(A0)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#48,D2
	MOVEQ	#$F,D4
	MOVE.B	(A0)+,D0
	MOVE.B	D0,D1
	LSR.B	#4,D1
	ADD.B	D2,D1
	MOVE.B	D1,(A1)+
	AND.B	D4,D0
	ADD.B	D2,D0
	MOVE.B	D0,(A1)+
	
	RTS
	
* D0 = Amount to subtract.
UpdateLivesDown:
	LEA	Lives+2(PC),A0
	LEA	UpdateString+21(PC),A1
	LEA	LivesString(PC),A3
	LEA	ABCDStore+2(PC),A2
	MOVE.W	D0,-2(A2)
	MOVE.W	#0,CCR
	SBCD.B	-(A2),-(A0)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#48,D2
	MOVEQ	#$F,D4
	MOVE.B	(A0)+,D0
	MOVE.B	D0,D1
	LSR.B	#4,D1
	ADD.B	D2,D1
	MOVE.B	D1,(A1)+
	AND.B	D4,D0
	ADD.B	D2,D0
	MOVE.B	D0,(A1)+

	RTS

KerSplatt:
	MOVEQ	#1,D0
	BSR	UpdateLivesDown

	SwapScreens
	BSR	Update
	SwapScreens
	BSR	Update
	SwapScreens

	BSR	WhiteOut

	TST.W	Lives-P(A5)
	BEQ	GameOver

	LEA	SplatText(PC),A2
	MOVE.L	ScreenPos2(PC),A0
	BSR	Print

	WaitVBL

	MOVEQ	#1,D0
	BSR	FadeOut
	LEA	Palette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn

	BSR	PauseKeyOrJoy

	MOVEQ	#1,D0
	BSR	FadeOut

	LEA	XPosition(PC),A0
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	LEA	Level,A0
	ADD.W	2(A0),A0
	MOVE.W	(A0)+,D2
	MULU	D2,D1
	ADD.W	D1,D0
	CLR.B	2(A0,D0.W)
	LEA	StatusString(PC),A2
	MOVE.L	ScreenPos2(PC),A0
	BSR	Print
	
	LEA	Level+10,A0
	LEA	OldXPosition(PC),A1
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0),(A1)+
	
	CLR.W	SplatFlag-P(A5)
	
	MOVE.L	ScreenPos(PC),A0
	BSR	ClearScreen
	LEA	StatusString(PC),A2
	MOVE.L	ScreenPos(PC),A0
	BSR	Print

	BSR	Update
	SwapScreens
	BSR	Update
	SwapScreens
	
	LEA	Palette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn

	BRA	MainLoop

GameOver:
.Loop1
	BSR	ReadJoystick
	BTST	#7,D0
	BNE.S	.Loop1

	MOVEQ	#1,D0
	BSR	FadeOut

	MOVE.L	ScreenPos2(PC),A0
	LEA	GameOverText(PC),A2
	BSR	Print
	
	MOVEQ	#1,D0
	LEA	IcePalette(PC),A0
	BSR	FadeIn

	LEA	UpdateString+3(PC),A0
	LEA	LastScoreAlter(PC),A1
	MOVEQ	#7,D0
.ScoreLoop
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,.ScoreLoop
	
	BSR	PauseKeyOrJoy
	
.LoopJoy
	BSR	ReadJoystick
	BTST	#7,D0
	BNE.S	.LoopJoy
	
	BRA	HighScoreCheck


WipeClearMap:
*	LEA	ClearMap(PC),A1
	MOVE.W	D7,D5
	LSR.W	#5,D5
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
.Loop
	MOVEM.L	D0-D3,(A1)
	MOVEM.L	D0-D3,16(A1)
	LEA	32(A1),A1
	DBRA	D5,.Loop
	RTS

ObjectMove:
	LEA	Level,A0
	ADD.W	2(A0),A0
	MOVE.W	(A0)+,D6
	MOVE.W	(A0)+,D7
	MULU	D6,D7
	LEA	ClearMap(PC),A1
	BSR.S	WipeClearMap
	MOVE.W	D6,D5
	ADD.W	D5,D5
	SUBQ.W	#1,D7
	MOVEQ	#18,D4
	LEA	ClearMap(PC),A1
	MOVE.L	A1,D1
	SUB.L	A0,D1
.Loop
	MOVE.B	(A0)+,D0
	CMP.B	D4,D0
	BMI.S	.Ok
	CMPI.B	#Rock,D0
	BEQ.S	.Boulder
	BRA	.BlueDiamond
.Ok
	DBRA	D7,.Loop
	RTS

.Boulder:
	LEA	0(A0,D1.W),A1
	TST.B	-1(A1)
	BNE.S	.Loop
	MOVE.B	-1(A0,D6.W),D0
	BNE.S	.Boulder1
	CLR.B	-1(A0)
	MOVE.B	#Rock,-1(A0,D6.W)
	MOVE.B	#$FF,-1(A1,D6.W)
	CMPI.B	#Face,-1(A0,D5.W)
	BNE.S	.J1
	MOVE.W	#$FFFF,SplatFlag
	BRA.S	.Ok
.J1	CMPI.B	#Ghost,-1(A0,D5.W)
	BNE.S	.Ok
	LEA	-1(A0,D5.W),A3
	BSR	GhostHit
	BRA.S	.Ok
.Boulder1:
	CMPI.W	#15,D0
	BNE.S	.GOk
	LEA	-1(A0,D6.W),A3
	BSR	GhostHit
	BRA.S	.Ok
.GOk
	CMPI.W	#7,D0
	BMI.S	.Ok
	MOVE.B	(A0),D0
	BNE.S	.Boulder2
	MOVE.B	(A0,D6.W),D0
	BNE.S	.Boulder2
	CMPI.B	#WallLeft,-1(A0,D6.W)
	BEQ.S	.Boulder2
	CLR.B	-1(A0)
	MOVE.B	#Rock,(A0,D6.W)
	MOVE.B	#$FF,(A1,D6.W)
	CMPI.B	#Face,(A0,D5.W)
	BNE.S	.J2
	MOVE.W	#$FFFF,SplatFlag-P(A5)
	BRA	.Ok
.J2	CMPI.B	#Ghost,(A0,D5.W)
	BNE	.Ok
	LEA	(A0,D5.W),A3
	BSR	GhostHit
	BRA	.Ok
.Boulder2
	MOVE.B	-2(A0),D0
	BNE	.Ok
	MOVE.B	-2(A0,D6.W),D0
	BNE	.Ok
	CMPI.B	#WallRight,-1(A0,D6.W)
	BEQ	.Ok
	CLR.B	-1(A0)
	MOVE.B	#Rock,-2(A0,D6.W)
	MOVE.B	#$FF,-2(A1,D6.W)
	CMPI.B	#Face,-2(A0,D5.W)
	BNE.S	.J3
	MOVE.W	#$FFFF,SplatFlag-P(A5)
	BRA	.Ok
.J3	CMPI.B	#Ghost,-2(A0,D5.W)
	BNE	.Ok
	LEA	-2(A0,D5.W),A3
	BSR	GhostHit
	BRA	.Ok

.BlueDiamond:
	LEA	(A0,D1.W),A1
	TST.B	-1(A1)
	BNE	.Loop
	MOVE.B	-1(A0,D6.W),D0
	BNE.S	.BlueDiamond1
	CLR.B	-1(A0)
	MOVE.B	#BlueDiamond,-1(A0,D6.W)
	MOVE.B	#$FF,-1(A1,D6.W)
	CMPI.B	#Face,-1(A0,D5.W)
	BNE	.Ok
	MOVE.W	#$FFFF,SplatFlag-P(A5)
	BRA	.Ok
.BlueDiamond1:
	CMPI.W	#7,D0
	BMI	.Ok
	MOVE.B	(A0),D0
	BNE.S	.BlueDiamond2
	MOVE.B	(A0,D6.W),D0
	BNE.S	.BlueDiamond2
	CMPI.B	#WallLeft,-1(A0,D6.W)
	BEQ.S	.BlueDiamond2
	CLR.B	-1(A0)
	MOVE.B	#BlueDiamond,(A0,D6.W)
	MOVE.B	#$FF,(A1,D6.W)
	CMPI.B	#Face,(A0,D5.W)
	BNE	.Ok
	MOVE.W	#$FFFF,SplatFlag-P(A5)
	BRA	.Ok
.BlueDiamond2
	MOVE.B	-2(A0),D0
	BNE	.Ok
	MOVE.B	-2(A0,D6.W),D0
	BNE	.Ok
	CMPI.B	#WallRight,-1(A0,D6.W)
	BEQ	.Ok
	CLR.B	-1(A0)
	MOVE.B	#BlueDiamond,-2(A0,D6.W)
	MOVE.B	#$FF,-2(A1,D6.W)
	CMPI.B	#Face,-2(A0,D5.W)
	BNE	.Ok
	MOVE.W	#$FFFF,SplatFlag
	BRA	.Ok

ObjectRoutTable:

GhostHit:
	MOVEM.L	D0-A4/A6,-(SP)

*	MOVE.W	#$400,$FFFF8240.W

	MOVEQ	#YellowDiamond,D0
	MOVEQ	#13,D1
	MOVE.W	D6,D2
	NEG.W	D2
	MOVEQ	#Face,D3
	MOVE.B	D0,(A3)

	CMP.B	-1(A3),D3
	BEQ.S	.Bra1
	MOVE.B	D0,-1(A3)
.Bra1

	CMP.B	1(A3),D3
	BEQ.S	.Bra2
	MOVE.B	D0,1(A3)
.Bra2

	CMP.B	-1(A3,D6.W),D3
	BEQ.S	.Bra3
	MOVE.B	D0,-1(A3,D6.W)
.Bra3

	CMP.B	(A3,D6.W),D3
	BEQ.S	.Bra4
	MOVE.B	D0,(A3,D6.W)
.Bra4

	CMP.B	1(A3,D6.W),D3
	BEQ.S	.Bra5
	MOVE.B	D0,1(A3,D6.W)
.Bra5

	CMP.B	-1(A3,D2.W),D3
	BEQ.S	.Bra6
	MOVE.B	D0,-1(A3,D2.W)
.Bra6

	CMP.B	(A3,D2.W),D3
	BEQ.S	.Bra7
	MOVE.B	D0,(A3,D2.W)
.Bra7

	CMP.B	1(A3,D2.W),D3
	BEQ.S	.Bra8
	MOVE.B	D0,1(A3,D2.W)
.Bra8

	MOVE.L	#$200,D0
	BSR	UpdateScore
	
	MOVEM.L	(SP)+,D0-A4/A6

	RTS


WhiteOut:
	MOVEQ	#7,D6
.Loop2

	MOVEQ	#2,D0
.Wait
	WaitVBL
	DBRA	D0,.Wait
	LEA	UpdatePalette(PC),A0
	MOVEQ	#15,D7
.Loop
	MOVE.W	(A0),D0
	MOVE.W	D0,D1
	AND.W	#$7,D1
	CMPI.W	#7,D1
	BPL.S	.Bra1
	ADDQ.W	#1,D1
.Bra1	MOVE.W	D1,D2
	MOVE.W	D0,D1
	AND.W	#$70,D1
	CMPI.W	#$70,D1
	BPL.S	.Bra2
	ADD.W	#$10,D1
.Bra2	ADD.W	D1,D2
	AND.W	#$700,D0
	CMPI.W	#$700,D0
	BPL.S	.Bra3
	ADD.W	#$100,D0
.Bra3	ADD.W	D0,D2
	MOVE.W	D2,(A0)+
	DBRA	D7,.Loop
	DBRA	D6,.Loop2
	RTS

AnalyseColours:
* A0= Position of colours.
	LEA	ClearMap(PC),A1
	MOVEQ	#15,D0
.Loop
	MOVE.W	(A0)+,D1
	MOVE.W	D1,D2
	LSR.W	#8,D2
	AND.W	#$7,D2
	LSL.W	#3,D2
	MOVE.W	D2,(A1)+
	MOVE.W	D1,D2
	LSR.W	#4,D2
	AND.W	#$7,D2
	LSL.W	#3,D2
	MOVE.W	D2,(A1)+
	MOVE.W	D1,D2
	AND.W	#$7,D2
	LSL.W	#3,D2
	MOVE.W	D2,(A1)+
	DBRA	D0,.Loop
	RTS

FadeOut:
* D0=Speed.
	MOVE.W	D0,D4
	LEA	UpdatePalette(PC),A0
	BSR.S	AnalyseColours
	LEA	PaletteTable1(PC),A2
	LEA	PaletteTable2(PC),A3
	MOVEQ	#6,D6
.Loop
	MOVE	D4,D5
.Loop2
	WaitVBL
	DBRA	D5,.Loop2
	LEA	UpdatePalette(PC),A0
	LEA	ClearMap(PC),A1
	MOVEQ	#15,D5
.Loop3
	MOVE.W	(A1)+,D0
	MOVE.B	0(A2,D0.W),D1
	SUB.B	D1,(A0)+
	MOVE.W	(A1)+,D0
	MOVE.B	0(A3,D0.W),D1
	SUB.B	D1,(A0)
	MOVE.W	(A1)+,D0
	MOVE.B	0(A2,D0.W),D1
	SUB.B	D1,(A0)+
	DBRA	D5,.Loop3
	ADDQ	#1,A2
	ADDQ	#1,A3
	DBRA	D6,.Loop
	
	MOVE	D4,D5
.Loop4
	WaitVBL
	DBRA	D5,.Loop4
	
	RTS

FadeIn:
* A0=Palette.
* D0=Speed.
	MOVE.W	D0,D4
	BSR	AnalyseColours
	LEA	PaletteTable1(PC),A2
	LEA	PaletteTable2(PC),A3
	MOVEQ	#6,D6
.Loop
	MOVE	D4,D5
.Loop2
	WaitVBL
	DBRA	D5,.Loop2
	LEA	UpdatePalette(PC),A0
	LEA	ClearMap(PC),A1
	MOVEQ	#15,D5
.Loop3
	MOVE.W	(A1)+,D0
	MOVE.B	0(A2,D0.W),D1
	ADD.B	D1,(A0)+
	MOVE.W	(A1)+,D0
	MOVE.B	0(A3,D0.W),D1
	ADD.B	D1,(A0)
	MOVE.W	(A1)+,D0
	MOVE.B	0(A2,D0.W),D1
	ADD.B	D1,(A0)+
	DBRA	D5,.Loop3
	ADDQ	#1,A2
	ADDQ	#1,A3
	DBRA	D6,.Loop
	
	MOVE	D4,D5
.Loop4
	WaitVBL
	DBRA	D5,.Loop4
	
	RTS

* CopyLevel - routine to copy a level.
* D0 = Level number. (BCD) (1-99)
CopyLevel:
	MOVEQ	#0,D1		BCD -> Binary.
	MOVE.B	D0,D1
	AND.W	#$F,D1
	AND.W	#$F0,D0
	LSR.W	#4,D0
	MULU	#10,D0
	ADD.W	D0,D1
	
	LSL.W	#2,D1
	LEA	LevelList(PC),A0
	MOVE.L	-4(A0,D1.W),A0
	MOVE.W	(A0),D0
	LSR.W	#1,D0
	LEA	Level,A1
.Loop	
	MOVE.W	(A0)+,(A1)+
	DBRA	D0,.Loop
	RTS

HighScoreCheck:
	MOVE.L	Score(PC),D0
	LEA	ScoreData(PC),A0
	LEA	Score1Alter(PC),A1
	CMP.L	(A0),D0
	BGT.S	.Hiscore1
	ADDQ	#8,A0
	LEA	Score2Alter(PC),A1
	CMP.L	(A0),D0
	BGT.S	.Hiscore2
	ADDQ	#8,A0
	LEA	Score3Alter(PC),A1
	CMP.L	(A0),D0
	BGT.S	.Hiscore3
	BRA	TitleScreen

.HiScore1:
	LEA	ScoreData+16(PC),A3
	MOVEQ	#3,D7
.CopyScoreLoop1
	MOVE.L	-(A3),8(A3)
	DBRA	D7,.CopyScoreLoop1

	LEA	Score2Alter(PC),A3
	LEA	Score3Alter(PC),A4
	MOVEQ	#7,D7
.CopyScoreLoop2
	MOVE.B	(A3)+,(A4)+
	DBRA	D7,.CopyScoreLoop2

	LEA	Score1Alter(PC),A3
	LEA	Score2Alter(PC),A4
	MOVEQ	#7,D7
.CopyScoreLoop3
	MOVE.B	(A3)+,(A4)+
	DBRA	D7,.CopyScoreLoop3
	
	BRA.S	.HiScore3
	
.HiScore2:
	LEA	ScoreData+16(PC),A3
	MOVE.L	-(A3),8(A3)
	MOVE.L	-(A3),8(A3)

	LEA	Score2Alter(PC),A3
	LEA	Score3Alter(PC),A4
	MOVEQ	#7,D7
.CopyScoreLoop4
	MOVE.B	(A3)+,(A4)+
	DBRA	D7,.CopyScoreLoop4

.HiScore3:

	LEA	UpdateString+3(PC),A3
	MOVEQ	#7,D7
.ScoreLoop
	MOVE.B	(A3)+,(A1)+
	DBRA	D7,.ScoreLoop

	MOVEM.L	D0/A0,-(SP)
	MOVEQ	#1,D0
	BSR	FadeOut
	MOVEM.L	(SP)+,D0/A0

	MOVE.L	D0,(A0)

	MOVE.L	A0,-(SP)
	LEA	EnterNameText(PC),A2
	MOVE.L	ScreenPos2(PC),A0
	BSR	Print

	LEA	IcePalette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn

	MOVE.L	(SP)+,A3
	CLR.L	4(A3)
	ADDQ	#5,A3
	
	MOVE.L	ScreenPos2(PC),A0
	LEA	60*160+40(A0),A0
	MOVEQ	#2,D6
.Loop
	BSR	WaitKey
	MOVE.W	D1,D2
	LSR.W	#8,D2
	AND.W	#$FF,D1
	CMPI.W	#' ',D1
	BNE.S	.B1
	MOVE.B	#0,(A3)+
	LEA	24(A0),A0
	BRA.S	.LoopEnd
.B1
	CMPI.W	#$0E,D2
	BEQ.S	.Delete
	CMPI.W	#$1C,D2
	BEQ.S	.InputDone
	CMPI.W	#'A',D1
	BMI.S	.Loop
	CMPI.W	#'Z'+1,D1
	BPL.S	.Loop
	SUB.W	#64,D1
	MOVE.W	D1,D0
	MOVE.B	D0,(A3)+
	MOVE.L	A0,A4
	BSR	PlotIceChar
	LEA	24(A4),A0
	
.LoopEnd
	DBRA	D6,.Loop
	
.FinishLoop
	BSR	WaitKey
	LSR.W	#8,D1
	CMPI.W	#$0E,D1
	BEQ.S	.Delete
	CMPI.W	#$1C,D1
	BNE.S	.FinishLoop

.InputDone	
	CLR.W	VBLFlag-P(A5)
.Wait
	CMPI.W	#10,VBLFlag-P(A5)
	BMI.S	.Wait

	BRA.S	TitleScreen

.Delete:
	CMPI.W	#2,D6
	BEQ.S	.Loop
	ADDQ.W	#1,D6
	SUBQ	#1,A3
	CLR.B	(A3)
	LEA	-24(A0),A0
	MOVE.L	A0,A4
	MOVEQ	#0,D0
	BSR	PlotIceChar
	MOVE.L	A4,A0
	BRA	.Loop
	
TitleScreen:

.Return
	MOVEQ	#1,D0
	BSR	FadeOut
	BSR	PlotTitle
	LEA	LogoPalette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn
	
	lea	DelTab1,a0
	lea	DelTab2,a1
	move.l	ScreenPos,d0
	addq.l	#6,d0
	move.l	#MaxSprites-1,d1
.FuckDel
	move.l	d0,(a0)+
	move.l	d0,(a1)+
	dbra	d1,.FuckDel	

.ObjectLoop
	SwapScreens
	JSR	DelSprites
	JSR	CommandCity
	JSR	CalcCity

	BSR	ReadJoystick
	BTST	#7,D0
	BNE.S	.Out
	BSR	ReadKeyboard
	ROR.W	#8,D1
	CMPI.B	#$44,D1
	BEQ	Exit
	ROR.W	#8,D1
	TST.B	D1
	BEQ.S	.ObjectLoop
	CMPI.B	#'H',D1
	BEQ.S	.ShowHiscores

.Out	
	
	
	MOVEQ	#1,D0
	BSR	FadeOut

.LoopJoy
	BSR	ReadJoystick
	BTST	#7,D0
	BNE.S	.LoopJoy

	BRA	GameStart
	
.ShowHiscores:
	BSR	PlotHiscores
	BSR	PauseKeyOrJoy
	BRA	.Return

PlotHiscores:
	MOVEQ	#1,D0
	BSR	FadeOut
	LEA	HiScoreText(PC),A2
	MOVE.L	ScreenPos(PC),A0
	BSR	Print
	
	MOVE.L	ScreenPos(PC),A2
	LEA	40*160+8*6(A2),A0
	LEA	ScoreData(PC),A3
	LEA	5(A3),A3
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar
	LEA	40*160+8*9(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar
	LEA	40*160+8*12(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar
	
	ADDQ	#5,A3
	
	LEA	46*160*2+8*6(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar
	LEA	46*160*2+8*9(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar
	LEA	46*160*2+8*12(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar

	ADDQ	#5,A3
	
	LEA	48*160*3+8*6(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar
	LEA	48*160*3+8*9(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar
	LEA	48*160*3+8*12(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	BSR	PlotIceChar
	
	SwapScreens

	LEA	IcePalette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn

	RTS

PlotTitle:
	LEA	TitleScreenText(PC),A2
	MOVE.L	ScreenPos(PC),A0
	BSR	Print
	MOVE.L	ScreenPos(PC),A0
	LEA	Logo(PC),A1
	MOVEQ	#38,D7
.Loop
	MOVEQ	#19,D6
.Loop2
	MOVE.L	(A1)+,(A0)+
	MOVE.W	(A1)+,(A0)+
	ADDQ	#2,A0
	DBRA	D6,.Loop2
	DBRA	D7,.Loop

	SwapScreens

	LEA	TitleScreenText(PC),A2
	MOVE.L	ScreenPos(PC),A0
	BSR	Print
	MOVE.L	ScreenPos(PC),A0
	LEA	Logo(PC),A1
	MOVEQ	#38,D7
.Loop3
	MOVEQ	#19,D6
.Loop4
	MOVE.L	(A1)+,(A0)+
	MOVE.W	(A1)+,(A0)+
	ADDQ	#2,A0
	DBRA	D6,.Loop4
	DBRA	D7,.Loop3

	SwapScreens


	RTS
	

PlotIceChar:
* D0=Char number.
* A0=Position.
	TST.B	D0
	BEQ.S	PlotCursor
	SUBQ.W	#1,D0
	MULU	#1152,D0
	LEA	IceFont,A1
	ADD.L	D0,A1
	MOVEQ	#47,D7
.Loop
	MOVEM.L	(A1)+,D0-D5
	MOVEM.L	D0-D5,(A0)
	LEA	160(A0),A0
	DBRA	D7,.Loop
	RTS

PlotCursor:
* A0=Position.
* D0.L= Data.
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	MOVE.L	D0,D4
	MOVE.L	D0,D5
	MOVEQ	#47,D7
.Loop
	MOVEM.L	D0-D5,(A0)
	LEA	160(A0),A0
	DBRA	D7,.Loop
	RTS

Password:
	MOVEQ	#1,D0
	BSR	FadeOut

	LEA	PasswordText(PC),A2
	MOVE.L	ScreenPos2(PC),A0
	BSR	Print
	
	LEA	IcePalette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn

	LEA	PasswordInput(PC),A3

	CLR.L	(A3)
	CLR.W	4(A3)
	
	MOVE.L	ScreenPos2(PC),A0
	LEA	48*160(A0),A0
	MOVEQ	#5,D6
.Loop
	BSR	WaitKey
	MOVE.W	D1,D2
	LSR.W	#8,D2
	AND.W	#$FF,D1
	CMPI.W	#' ',D1
	BNE.S	.B1
	MOVE.B	#0,(A3)+
	LEA	24(A0),A0
	BRA.S	.LoopEnd
.B1
	CMPI.W	#$0E,D2
	BEQ	.Delete
	CMPI.W	#$1C,D2
	BEQ.S	.InputDone
	CMPI.W	#'A',D1
	BMI.S	.Loop
	CMPI.W	#'Z'+1,D1
	BPL.S	.Loop
	MOVE.W	D1,D0
	SUB.W	#64,D0
	MOVE.B	D1,(A3)+
	MOVE.L	A0,A4
	BSR	PlotIceChar
	LEA	24(A4),A0
	
.LoopEnd
	DBRA	D6,.Loop
	
.FinishLoop
	BSR	WaitKey
	LSR.W	#8,D1
	CMPI.W	#$0E,D1
	BEQ.S	.Delete
	CMPI.W	#$1C,D1
	BNE.S	.FinishLoop

.InputDone	

	LEA	PasswordInput(PC),A3
	LEA	Passwords(PC),A1
	MOVEQ	#1,D7
	MOVE.L	(A3)+,D5
	MOVE.W	(A3)+,D6
.PasswordLoop:
	CMP.L	(A1)+,D5
	BNE.S	.NotFound1
	CMP.W	(A1)+,D6
	BNE.S	.NotFound2
	MOVE.W	D7,CurrentLevel-P(A5)
	RTS

.NotFound1:
	ADDQ	#2,A1
.NotFound2:
	ADDQ	#1,D7
	CMPA.L	#PasswordsEnd,A1
	BMI.S	.PasswordLoop
	
	MOVEQ	#0,D0
	BSR	FadeOut
	
	LEA	WrongPasswordText(PC),A2
	MOVE.L	ScreenPos2(PC),A0
	BSR	Print

	LEA	IcePalette(PC),A0
	MOVEQ	#1,D0
	BSR	FadeIn

	BSR	PauseKeyOrJoy
	
	BRA	Password

.Delete:
	CMPI.W	#5,D6
	BEQ	.Loop
	ADDQ.W	#1,D6
	SUBQ	#1,A3
	CLR.B	(A3)
	LEA	-24(A0),A0
	MOVE.L	A0,A4
	MOVEQ	#0,D0
	BSR	PlotIceChar
	MOVE.L	A4,A0
	BRA	.Loop
	
PlotSTSLogo:
	MOVE.L	ScreenPos(PC),A0
	MOVE.L	ScreenPos2(PC),A1
	
	LEA	MonoFont(PC),A2
	
	MOVE.L	#34720,D0
	ADD.L	D0,A0
	ADD.L	D0,A1
	
	LEA	.Offsets(PC),A4
	MOVEQ	#9,D7
.Loop
	MOVEM.L	A0-A1,-(SP)
	MOVE.L	A2,A3
	ADD.W	(A4)+,A3
	BSR	.PlotChar
	MOVEM.L	(SP)+,A0-A1
	LEA	16(A0),A0
	LEA	16(A1),A1
	DBRA	D7,.Loop
	RTS
	
.PlotChar:
	MOVEQ	#14,D0
.PlotCharLoop:
	MOVE.B	(A3),(A0)
	MOVE.B	(A3),(A1)
	MOVE.B	16(A3),1(A0)
	MOVE.B	16(A3),1(A1)
	MOVE.B	32(A3),8(A0)
	MOVE.B	32(A3),8(A1)
	MOVE.B	48(A3),9(A0)
	MOVE.B	48(A3),9(A1)
	ADDQ.L	#1,A3
	LEA	160(A0),A0
	LEA	160(A1),A1
	DBRA	D0,.PlotCharLoop
	RTS

.Offsets:
	DC.W	18*64
	DC.W	15*64
	DC.W	3*64
	DC.W	11*64
	DC.W	19*64
	DC.W	20*64
	DC.W	5*64
	DC.W	64
	DC.W	4*64
	DC.W	25*64

Scroll:
	MOVE.L	ScreenPos2(PC),A0
	LEA	32320(A0),A0
	MOVE.L	A0,A3

	MOVE.L	OldScrollPosition(PC),A1
	BEQ	.Skip
	
.Move:
	MOVEQ	#14,D0
	
	ADDQ.L	#1,A1
.Loop	
	REPT	19
	MOVE.B	(A1)+,(A0)+
	ADDQ.L	#6,A1
	MOVE.B	(A1)+,(A0)+
	ADDQ.L	#6,A0
	ENDR
	
	MOVE.B	(A1)+,(A0)+
	ADDQ.L	#7,A1
	ADDQ.L	#7,A0
	
	DBRA	D0,.Loop

.Skip
	MOVE.L	A3,OldScrollPosition
	
	LEA	FinePositionInText(PC),A2
	ADDQ.W	#1,(A2)
	MOVE.W	(A2),D0
	CMPI.W	#4,D0
	BEQ.S	.NewChar
	
.Plot
	MOVE.L	A3,A0
	LEA	MonoFont(PC),A1
	LEA	OldChar(PC),A2
	ADD.W	#16,(A2)
	MOVE.W	(A2),D0
	LEA	(A1,D0.W),A1
	LEA	153(A0),A0
	
OFFSET	SET	0
	REPT	15
	MOVE.B	(A1)+,OFFSET(A0)
OFFSET	SET	OFFSET+160
	ENDR

	RTS
	
.NewChar:
	CLR.W	(A2)
	LEA	MonoFontCharacterTable(PC),A0
	MOVE.L	PositionInText(PC),A1
	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.B	(A0,D0.W),D0
	LSL.W	#6,D0
	SUB.W	#15,D0
	MOVE.W	D0,OldChar
	MOVE.L	A1,PositionInText
	CMPA.L	#EndOfMessage,A1
	BMI.S	.Plot
	MOVE.L	#Message,PositionInText
	BRA	.Plot
	
	
********************************
* Character printing routines. *
********************************

* A0 = Screen position.
* A2 = String position.
Print:
	LEA	CharacterTable(PC),A3
	MOVE.L	A0,A4

PrintSub:
	MOVEQ	#0,D2
	MOVE.B	(A2)+,D2
	CMPI.W	#16,D2
	BMI.S	ControlCharacter
	MOVE.B	0(A3,D2.W),D2
	MOVE.W	CursorXPosition(PC),D0
	MOVE.W	CursorYPosition(PC),D1
	BSR	PlotCharacter
	MOVE.L	A4,A0
	BRA	CursorRight

ControlCharacter:
	ADD.W	D2,D2
	ADD.W	D2,D2
	MOVE.L	PrintRoutineTable(PC,D2.W),A6
	JMP	(A6)

PrintRoutineTable:
	DC.L	StringDone	0
	DC.L	CursorUp	1
	DC.L	CursorDown	2
	DC.L	CursorRight	3
	DC.L	CursorLeft	4
	DC.L	ClearHome	5
	DC.L	Home		6
	DC.L	SetCursor	7
	DC.L	StringDone	8
	DC.L	PrintSub	9
	DC.L	PrintSub	10
	DC.L	PrintSub	11
	DC.L	PrintSub	12
	DC.L	CReturn		13
	DC.L	CReturnBack	14
	DC.L	PrintSub	15
	DC.L	PrintSub	16

CReturnBack:
	MOVE.W	#39,CursorXPosition
	
CursorUp:
	TST.W	CursorYPosition
	BEQ	PrintSub
	SUBQ.W	#1,CursorYPosition
	BRA	PrintSub

CReturn:
	CLR.W	CursorXPosition

CursorDown:
	CMPI.W	#24,CursorYPosition
	BPL	PrintSub
	ADDQ.W	#1,CursorYPosition
	BRA	PrintSub

CursorRight:
	CMPI.W	#39,CursorXPosition
	BEQ.S	CReturn
	ADDQ.W	#1,CursorXPosition
	BRA	PrintSub

CursorLeft:
	TST.W	CursorXPosition
	BEQ.S	CReturnBack
	SUBQ.W	#1,CursorXPosition
	BRA	PrintSub

ClearHome:
	MOVEM.L	A0/A2/A3/A4,-(SP)
	BSR	ClearScreen
	MOVEM.L	(SP)+,A0/A2/A3/A4
Home:
	CLR.W	CursorXPosition
	CLR.W	CursorYPosition
	BRA	PrintSub

SetCursor:
	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	MOVE.W	D0,CursorXPosition
	MOVE.B	(A2)+,D0
	MOVE.W	D0,CursorYPosition
	BRA	PrintSub

StringDone:
	RTS

* Routine to plot an 8X8 character.

* Parameters:
* A0 = Screen Position.
* D0.W = X Position.
* D1.W = Y Position.
* D2.W = Character.

PlotCharacter:
	LEA	Font(PC),A1		Get position of the font.
	LSL.W	#3,D2			8 bytes for each character.
	ADDA	D2,A1			Add this offset.
	BCLR	#0,D0			Check for odd X-position.
	BEQ.S	.Even			Branch if even.
	ADDQ	#1,A0			If not, then change screen pointer.
.Even	ADD.W	D0,D0			Multiply X-position by 4.
	ADD.W	D0,D0
	ADD.W	D0,A0			Add it to the screen position.
	MULU	#1280,D1		Calculate Y-position offset.
	ADD.W	D1,A0			Add it on.
	
Offset	SET	0
	REPT	8
	MOVE.B	(A1)+,D0
	MOVE.B	D0,Offset(A0)
	MOVE.B	D0,Offset+2(A0)
	MOVE.B	D0,Offset+4(A0)
	MOVE.B	D0,Offset+6(A0)
Offset	SET	Offset+160
	ENDR
	
	RTS				Bye bye.

******
* Keyboard and Joystick routines


ReadJoystick:
	LEA	StickData(PC),A1
	MOVE.W	(A1),D1
	MOVE.W	2(A1),D0
	CLR.W	(A1)
	RTS

ReadKeyboard:
	MOVE.W	SR,-(SP)
	MOVE.W	#$2700,SR
	MOVE.L	KeyBufferPosition(PC),A2
	CMPA.L	#KeyBuffer,A2
	BEQ.S	.NoKey 
	MOVE.W	-(A2),D1
	MOVE.L	A2,KeyBufferPosition
	MOVE.W	(SP)+,SR
	RTS
.NoKey
	MOVEQ	#0,D1
	MOVE.W	(SP)+,SR
	RTS

FlushKeyboard:
	MOVE.L	#KeyBuffer,KeyBufferPosition
	RTS

WaitKey:
	MOVE.L	KeyBufferPosition(PC),A2
	CMPA.L	#KeyBuffer,A2
	BEQ.S	WaitKey
	MOVE.W	SR,-(SP)
	MOVE.W	#$2700,SR
	MOVE.L	KeyBufferPosition(PC),A2
	MOVE.W	-(A2),D1
	MOVE.L	A2,KeyBufferPosition
	MOVE.W	(SP)+,SR
		
	ROR.W	#8,D1
	CMPI.B	#$44,D1
	BEQ	Exit
	ROR.W	#8,D1

	RTS

PauseKeyOrJoy:
	MOVE.L	KeyBufferPosition(PC),A2
	CMPA.L	#KeyBuffer,A2
	BNE.S	.WaitKeyEnd
	BSR	ReadJoystick
	BTST	#7,D0
	BNE.S	.Joy
	BRA	PauseKeyOrJoy
.WaitKeyEnd	
	MOVE.W	SR,-(SP)
	MOVE.W	#$2700,SR
	MOVE.L	KeyBufferPosition(PC),A2
	MOVE.W	-(A2),D1
	MOVE.L	A2,KeyBufferPosition
	MOVE.W	(SP)+,SR
	
	ROR.W	#8,D1
	CMPI.B	#$44,D1
	BEQ	Exit
	ROR.W	#8,D1
	
	RTS
.Joy
	MOVEQ	#0,D1
	RTS
	
IKBDSend:
	LEA	$FFFFFC00.W,A0
.Loop
	MOVE.B	(A0),D1
	BTST	#1,D1
	BEQ.S	.Loop
	MOVE.B	D0,2(A0)
	RTS


**********************
* Interrupt routines *
**********************

QVBL:
	ADDQ.W	#1,VBLFlag
	RTE

VBLHandler:
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	UpdatePalette(PC),A0
	LEA	$FFFF8240.W,A1
	REPT	8
	MOVE.L	(A0)+,(A1)+
	ENDR
	ADDQ.W	#1,VBLFlag
	
	;MOVE.L	#SamplePlayer,$134.W
	;MOVE.L	#HBLRoutA,$120.W
        MOVE.B  #0,(TBCR).W		Set up raster routine.
        ;MOVE.B  #197,(TBDR).W
        ;MOVE.B  #8,(TBCR).W
        ;MOVE.B	#2,(TBDR).W

	;TST.W	MusicFlag
	;BEQ.S	.Skippy
	;JSR	Music
.Skippy

	BSR	Scroll

	MOVEM.L	(SP)+,D0-D7/A0-A6
*	NOT.W	$FFFF8240.W
*	NOT.W	$FFFF8240.W

	RTE
;MusicFlag:
;	DC.W	0

*NullRout:
*	RTE

***************************************************
* Keyboard, joystick and mouse handling routines. *
***************************************************

* The non keyboard interrupt routines.

NullIKBD:
	MOVE.B	2(A0),D0
	SUBQ.W	#1,PacketSize
	BPL	KeyReturn
	CLR.L	CurrentKeyRoutine
	CLR.W	PacketSize
	BRA.S	KeyReturn

AMouse:
	MOVE.B	2(A0),D0
	SUBQ.W	#1,PacketSize
	BPL.S	KeyReturn
	CLR.L	CurrentKeyRoutine
	CLR.W	PacketSize
	BRA.S	KeyReturn

RMouse:
	MOVE.B	2(A0),D0
	SUBQ.W	#1,PacketSize
	BPL.S	KeyReturn
	CLR.L	CurrentKeyRoutine
	CLR.W	PacketSize
	BRA.S	KeyReturn

JoystickHandler:
	LEA	StickData(PC),A1
	MOVE.W	PacketHeader(PC),D0
	CMPI.B	#$FE,D0
	BNE.S	.Branch2
	ST	(A1)
	MOVE.B	2(A0),2(A1)
	BRA.S	.Branch3
.Branch2
	ST	1(A1)
	MOVE.B	2(A0),3(A1)
.Branch3
	CLR.L	CurrentKeyRoutine
	BRA.S	KeyReturn
	
* Keyboard handler interrupt routine.

KeyInterrupt:
	MOVEM.L	D0/A0-A1,-(SP)
	MOVE.B	$FFFFFC00.W,D0
	BTST	#7,D0
	BNE.S	KeyReturn
KeyExit	MOVEM.L	(SP)+,D0/A0-A1
	BCLR.B	#6,$FFFFFA11.W
	RTE

KeyReturn:
	LEA	$FFFFFC00.W,A0
	MOVE.B	(A0),D0
	BTST	#0,D0
	BEQ.S	KeyExit
	MOVE.L	CurrentKeyRoutine(PC),D0
	BEQ.S	NewPackage
	MOVE.L	D0,A1
	JMP	(A1)

NewPackage:
	MOVEQ	#0,D0
	MOVE.B	2(A0),D0
	CMPI.W	#$F6,D0
	BPL.S	.NotKeyboard
	
	LEA	KeyTable(PC),A1
	BCLR	#7,D0
	BNE.S	.KeyOff
	ST	0(A1,D0.W)
	MOVE.L	KeyBufferPosition(PC),A1
	LEA	AsciiTable(PC),A0
	MOVE.B	D0,(A1)+
	MOVE.B	0(A0,D0.W),(A1)+
	CMPA.L	#EndOfKeyBuffer,A1
	BPL.S	.EndOfBuffer
	MOVE.L	A1,KeyBufferPosition
.EndOfBuffer:
	BRA.S	KeyReturn
	
.KeyOff	SF	0(A1,D0.W)
	BRA.S	KeyReturn

.NotKeyboard
	MOVE.W	D0,PacketHeader
	SUB.W	#$F6,D0
	LEA	IKBDHandlers(PC),A0
	LSL.W	#3,D0
	ADDA.W	D0,A0
	MOVE.L	(A0)+,CurrentKeyRoutine
	MOVE.W	(A0)+,PacketSize
	
	BRA.S	KeyReturn

* The main offset pointer in the program.
P:

****************
* Data section *
****************

SECTION DATA

* Standard game variables:

* The position of the character.
OldXPosition	DC.W	0
OldYPosition	DC.W	0
XPosition	DC.W	0
YPosition	DC.W	0

CursorXPosition	DC.W	0
CursorYPosition	DC.W	0

LevelDoneFlag	DC.W	0
SplatFlag	DC.W	0

PositionInText	DC.L	Message
FinePositionInText	DC.W	0
OldChar		DC.W	0
OldScrollPosition	DC.L	0

UpdatePalette	DCB.W	16,0

DiamondCount	DC.W	0
Score		DC.L	0
Lives		DC.W	NumberOfLives

DiagonalMoveFlag	DC.W	0

LevelList:
	DC.L	STS
	DC.L	INNERC
	DC.L	AARRGH
	DC.L	LANDSLID
	DC.L	BONUS
	DC.L	MAZE
	DC.L	ROCKS
	DC.L	BIGONE

CurrentKeyRoutine	DC.L	0
KeyBufferPosition	DC.L	KeyBuffer

IKBDHandlers:

	DC.L	NullIKBD	Read IKBD memory...
	DC.W	6		7 bytes to read.
	DC.W	0		Padding
	
	DC.L	AMouse
	DC.W	4
	DC.W	0
	
	REPT	4
	DC.L	RMouse
	DC.W	1
	DC.W	0
	ENDR
	
	DC.L	NullIKBD	Return time...
	DC.W	5
	DC.W	0
	
	DC.L	NullIKBD	Whassis do?
	DC.W	1
	DC.W	0
	
	REPT	2
	
	DC.L	JoystickHandler
	DC.W	0
	DC.W	0
	
	ENDR

AsciiTable:
	DC.B	0,0,'1234567890-=',0,0,'QWERTYUIOP[]',13,0,'ASDFGHJKL-','`','`',0
	DC.B	'#ZXCVBNM,./',0,0,0,' ',0
	DC.B	0,0,0,0,0,0,0,0,0,0		'Function keys.
	DC.B	0,0,0,0,0,'-',0,0,0,'+',0,0
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	0,0,'()/*7894561230.',13
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

CharacterTable:
	DCB.B	32,0
	DC.B	00,39,41,45,45,45,45,44,42,43,44,45,38,45,37,45
	DC.B	27,28,29,30,31,32,33,34,35,36,37,38,42,45,43,40
	DC.B	00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15
	DC.B	16,17,18,19,20,21,22,23,24,25,26,42,00,43,44,00
	DC.B	00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15
	DC.B	16,17,18,19,20,21,22,23,24,25,26,42,00,43,00,44
	DCB.B	16,0
	
MonoFontCharacterTable:
	DCB.B	32,0
	DC.B	00,27,44,42,42,42,42,44,38,39,44,42,41,42,40,42
	DC.B	37,28,29,30,31,32,33,34,35,36,40,41,38,42,39,43
	DC.B	00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15
	DC.B	16,17,18,19,20,21,22,23,24,25,26,38,42,39,44,42
	DC.B	44,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15
	DC.B	16,17,18,19,20,21,22,23,24,25,26,38,42,39,42,42
	DCB.B	16,0
	
StatusString:
	DC.B	7,0,24,'SCORE-00000000 DIAMONDS '
DiPerLevel1:
	DC.B	'000-000 LIVES '
LivesString:
	DC.B	'00',0

UpdateString:
	DC.B	7,6,24,'00000000',7,27,24,3,'000',7,38,24,'00',0

LevelStartString:
	DC.B	5,7,8,10,'LEVEL '
LevelNo:
	DC.B	'01 - GET READY!',13
	DC.B	7,6,12
DiPerLevel2:
	DC.B	'000 DIAMONDS TO COLLECT!',13,13
	DC.B	'    PASSWORD FOR THIS LEVEL - ',0

	EVEN
PasswordPrint:
	DS.W	3
	DC.B	0

LevelDoneText:
	DC.B	5,7,10,10,'LEVEL COMPLETED!!!',0

SplatText:
	DC.B	5,7,10,10,'OOPS - SPLAT!!!',0

GameOverText:
	DC.B	5,7,14,10,'GAME OVER!',0

GameDoneText:
	DC.B	5,7,12,10,'CONGRATULATIONS!',7,12,12,'GAME COMPLETED!!',13,13
	DC.B	'NOW THAT WAS NOT TOO DIFFICULT, WAS IT??',0

EnterNameText:
	DC.B	5,7,9,0,'HIGH SCORE ACHIEVED!',13
	DC.B	' ENTER YOUR INITIALS AND PRESS RETURN.',0

TitleScreenText:
	DC.B	5,7,5,24
	DC.B	'COPYRIGHT 1991 JOHN REYNOLDS.',0

HiScoreText:
	DC.B	5,7,15,0,'HIGH SCORES.'
	DC.B	7,10,2
	DC.B	'LAST SCORE - '
LastScoreAlter:
	DC.B	'00000000',13
	DC.B	13,13,13,13,13,13,'1. '
Score1Alter:
	DC.B	'00005000',13
	DC.B	13,13,13,13,13,13,'2. '
Score2Alter:
	DC.B	'00001000',13
	DC.B	13,13,13,13,13,13,'3. '
Score3Alter:
	DC.B	'00000500',13,0

PasswordText:
	DC.B	5,' ENTER PASSWORD AND PRESS RETURN.',13
	DC.B	'    PASSWORD FOR LEVEL 1 - STS',0

WrongPasswordText:
	DC.B	5,7,8,8,'PASSWORD NOT RECOGNISED',13
	DC.B	7,13,10,'PRESS A KEY',0

	EVEN	
ScoreData:
	DC.L	$5000
	DC.B	0,'J'-64,'M'-64,'R'-64
	DC.L	$1000
	DC.B	0,'A'-64,'J'-64,'B'-64
	DC.L	$500
	DC.B	0,'J'-64,0,'B'-64


Message:
	INCBIN	ROCK.INC\TEXT.TXT
		
EndOfMessage:
	DC.B	'  '

	EVEN
PasswordInput	DS.W	4
Passwords:
	DC.B	'STS',0,0,0
	DC.B	'INNER',0
	DC.B	'AARRGH'
	DC.B	'SLIDE',0
	DC.B	'BONUS',0
	DC.B	'MAZE',0,0
	DC.B	'ROCKS',0
	DC.B	'BIGONE'
PasswordsEnd

	EVEN
* Graphics data.
GraphicBlocks:
	INCBIN	ROCK.INC\BLOCKS5.SPR

Palette:
	DC.W	0,$30,$70,7
	DC.W	$77,$500,$550,$770
	DC.W	$774,$200,$410,$620
	DC.W	$111,$333,$555,$777

IcePalette:
	DC.W	0,2,3,4,5
	DC.W	$16,$26,$36,$47
	DC.W	$57,$67,$77,$277
	DC.W	$477,$577,$777

LogoPalette:
	DC.W	0,2,$730,$750
	DC.W	$770,7,$710,$777
	DC.W	$777,2,$730,$750
	DC.W	$770,7,$710,$777

Font:
	DCB.B	8,0
	INCBIN	ROCK.INC\8BY8FONT.SPR

	
*******************
* Storage section *
*******************

SECTION BSS

* Program stack space:
	DS.W	500
Stack	DS.W	1

* System storage:
OldSSP	DS.L	1
OldResolution	DS.W	1
OldPalette	DS.W	16
StatusSaveArea	DS.W	10

* Program storage:
VBLFlag		DS.W	1
ScreenPos	DS.L	1
ScreenPos2	DS.L	1
TrueScreenPos	DS.L	1
ABCDStore	DS.L	1
ABCDStore2	DS.L	1
FireFlag	DS.W	1
CurrentLevel	DS.W	1
ExtraLifeClear	DS.W	3

* IKBD Handler storage:
PacketHeader	DS.W	1
PacketSize	DS.W	1
KeyBuffer	DS.B	100
EndOfKeyBuffer	DS.W	1
KeyTable	DS.B	128
StickData	DS.W	5

* Object updated table.
ClearMap	DS.W	5000

* Level space.
Level		DS.W	5000

* Space for screen swapping.
FirstScreenStore	DS.B	40000
SecondScreenStore	DS.B	40000