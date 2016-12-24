* Helix scroll on its own

	OPT O+,OW-,C-

IEA	EQU $FFFFFA07
IEB	EQU $FFFFFA09
IMA	EQU $FFFFFA13
SYSPAL	EQU $FFFF8240		System palette registers.
SHFTMOD	EQU $FFFF8260		Resolution mode.
VBL_VEC	EQU $70

WaitVBL	MACRO
WVBL\@	TST.W VBLFlag
	BEQ WVBL\@
	CLR.W VBLFlag
	ENDM

WaitVBL2 MACRO
WVBL\@	CLR.W VBLFlag
	TST.W VBLFlag
	BEQ WVBL\@
	CLR.W VBLFlag
	ENDM

Scrolld SET 136*160

Main:	CLR.L -(SP)
	MOVE.W #$20,-(SP)
	TRAP #1
	ADDQ.L #6,SP
	LEA Stack,A7
	MOVE.W #$2700,SR
	MOVE.B #$12,$FFFFFC02.W
	BSR ShiftFont
	MOVE.L $FFFF8200.W,TrueScreenPos
	MOVE.L ScreenPos2(PC),A0
 	BSR ClearWholeScreen
	MOVE.L ScreenPos(PC),A0
	BSR ClearWholeScreen
	MOVE.B (IEB).W,OLD_IEB
	MOVE.B (IEA).W,OLD_IEA
	MOVE.B (IMA).W,OLD_IMA
	MOVE.B (SHFTMOD).W,OLD_SHFTMOD
	CLR.B (IEB).W
	CLR.B (IEA).W
	MOVE.L (VBL_VEC).W,OLD_VBL_VEC
	MOVE.L #VBL_HANDLER,(VBL_VEC).W
	MOVEQ #7,D0			Save the old palette.
	LEA (SYSPAL).W,A1
	LEA OLD_PALETTE(PC),A0
	LEA Palette(PC),A2
SavePalette
	MOVE.L (A1),(A0)+
	MOVE.L (A2)+,(A1)+
	DBRA D0,SavePalette
	MOVE.B	$FFFF820A.W,OldMode
	MOVE.B	$FFFF8260.W,OldRes
	MOVE.W  #$2300,SR
	WaitVBL2
	MOVE.B	#2,$FFFF820A.W
	MOVE.B	#0,$FFFF8260.W

* Main vbl loop
	
VBLoop	MOVE.L ScreenPos2(PC),D0
	MOVE.L ScreenPos(PC),ScreenPos2
	MOVE.L D0,ScreenPos
	LSR #8,D0
	MOVE.L D0,$FFFF8200.W
 	MOVE #$000,$FFFF8240.W
	WaitVBL
 	MOVE #$777,$FFFF8240.W
	MOVE.L ScreenPos(PC),A0
	LEA Scrolld(A0),A0
	BSR ClearScreen
	MOVE.W	ScrollPos(PC),D0
	MULU #13440,D0
	MOVE.L #NEWFONT,FontPos
	ADD.L D0,FontPos

Do_plot	MOVE.B LineCount(PC),D6
	MOVE.L FontPos(PC),A1
	LEA OffsetTable+1(PC),A5
	LEA CharPointers(PC),A6
	MOVE.L ScreenPos(PC),A0
	LEA Scrolld(A0),A0
	TST.W ScrollPos16
	BEQ.S plotem
	SUBQ.L #8,A0
plotem	REPT 10
	MOVE.L A1,A2
	ADDA.W (A6)+,A2
	MOVE.L -1(A5,D6.W),A3
	MOVE.L 127(A5,D6.W),A4
	MOVE.W (A4),D5		
	MOVE.W #$4E75,(A4)
	MOVE.W D6,D1		
	ADD.W D6,D1
	ADD.W D6,D1
	SUBA.W D1,A2
	JSR (A3)
	MOVE.W D5,(A4)
	LEA 16(A0),A0
	ADD.B #64,D6			equiv of mod 255
	ENDR
	MOVE.L ScreenPos(PC),A0
	LEA Scrolld(A0),A0
	BSR EraseEnds
	add.B #4,LineCount
	ADDQ.W #2,ScrollPos
	AND.W #15,ScrollPos
	BNE.S notnew
	NOT ScrollPos16
	BNE.S notnew
newchar	ADD.B #64,LineCount
	LEA CharPointers+2(PC),A0
	MOVEM.L	(A0)+,D0-D4
	MOVEM.L	D0-D4,-22(A0)
	MOVE.L PositionInText(PC),A1
	MOVEQ #0,D0			
	MOVE.B (A1),D0			
	BNE.S notend
	MOVE.L #Message,PositionInText
	MOVE.B (A1),D0			
notend	ADD D0,D0
	LEA CharTable(PC),A1	
	MOVE.W (A1,D0.W),-(A0)		
	ADDQ.L #1,PositionInText
notnew	CMP.B #$39,$FFFFFC02.W
	BNE VBLoop

* Restore mfp and interrupt vectors

Restore	WaitVBL2
	MOVE.B OldMode(pc),$FFFF820A.W
	MOVE.B OldRes(pc),$FFFF8260.W
	MOVE.W #$2700,SR
	MOVE.B OLD_IEB(PC),IEB
	MOVE.B OLD_IEA(PC),IEA
	MOVE.B OLD_IMA(PC),IMA
	MOVE.L OLD_VBL_VEC(PC),VBL_VEC
	MOVEQ #7,D0
	LEA SYSPAL,A1
	LEA OLD_PALETTE(PC),A0
RST_LP	MOVE.L (A0)+,(A1)+
	DBF D0,RST_LP
	MOVE.L TrueScreenPos,$FFFF8200.W
	MOVE.B #$8,$FFFFFC02.W
	MOVE.W  #$2300,SR
	CLR.W -(SP)
	TRAP #1

* Plot one line of the scroller.
* \1 = Offset into the character.
* \2 = Line offset on screen.
* A0 = Position on the screen.
* A1 = Position of reverse line.
* A2 = Pointer to character data.

off	EQU 10244-480	offset to bottom of scroll (3rd plane)

SingleLine	MACRO
Line	SET 160*\2
	MOVEM.L	\1*12(A2),D0-D2
	OR.L D0,Line(A0)	
	OR.L D0,off-Line(A0)	
	MOVE.L D1,8+Line(A0)	
	MOVE.L D1,off+8-Line(A0)
	MOVE.L D2,16+Line(A0)
	MOVE.L D2,off+16-Line(A0)
	ENDM

* Plot two lines of the scroller.

DoubleLine	MACRO
Line	SET 160*\2		
	MOVEM.L	\1*12(A2),D0-D2
	OR.L D0,Line(A0)
	OR.L D0,160+Line(A0)
	OR.L D0,off-Line(A0)
	OR.L D0,off-160-Line(A0)
	MOVE.L D1,8+Line(A0)
	MOVE.L D1,168+Line(A0)
	MOVE.L D1,off+8-Line(A0)
	MOVE.L D1,off-152-Line(A0)
	MOVE.L D2,16+Line(A0)
	MOVE.L D2,176+Line(A0)
	MOVE.L D2,off+16-Line(A0)
	MOVE.L D2,off-144-Line(A0)
	ENDM
	
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
* A0 = Screen Location.
ClearScreen:
	LEA	10240-8(A0),A0
	MOVEQ	#0,D0
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
	REPT 64
	MOVEM.L	D0-D7/A1-A6,-(A0)
	MOVEM.L	D0-D7/A1-A6,-(A0)
	MOVEM.L	D0-D7,-(A0)
	LEA -16(A0),A0
	ENDR
	RTS
	
* Routine to clear the whole screeen.

ClearWholeScreen:
	MOVEQ #0,D0
	MOVE #3999,D1
.Loop	MOVE.L D0,(A0)+
	MOVE.L D0,(A0)+
	DBF D1,.Loop
	LEA -32000(A0),A0
	RTS

* Shift the font.

ShiftFont:
	LEA Chars(PC),A0
	LEA NEWFONT(PC),A1
	MOVE.W	#1119,D0
.Loop	CLR.L (A1)+
	MOVE.L (A0)+,(A1)+
	MOVE.L (A0)+,(A1)+
	DBRA D0,.Loop
	MOVEQ #14,D7		14 shifts
	LEA NEWFONT(PC),A6
shftylp	LEA (A6),A0
	LEA 1120*12(A0),A1
	MOVE.W	#1119,D3
.Loop2	MOVEM.L	(A0)+,D0-D2
	ADD D2,D2
	ADDX D1,D1
	ADDX D0,D0
	SWAP D2
	SWAP D1
	SWAP D0
	ADD D2,D2
	ADDX D1,D1
	ADDX D0,D0
	SWAP D2
	SWAP D1
	SWAP D0
	MOVE.L D0,(A1)+
	MOVE.L D1,(A1)+
	MOVE.L D2,(A1)+
	DBF D3,.Loop2
	LEA 1120*12(A6),A6
	DBF D7,shftylp
	RTS

* Routine to erase ends of the scroller.
* A0 = Screen Position.

EraseEnds:
	LEA SideBar(PC),A1		Load data.
i	SET -480
	REPT 68
	MOVE.L (A1)+,D0
	MOVE.L D0,i(A0)
	MOVE.L D0,i+152(A0)
i	SET i+160
	ENDR
	RTS

VBL_HANDLER
	MOVE.W #$FFFF,VBLFlag
	RTE
	
OffsetTable
	DC.L P0,P1,P2,P3,P4,P5,P6,P7,P8,P9
	DC.L P10,P11,P12,P13,P14,P15,P16,P17,P18,P19
	DC.L P20,P21,P22,P23,P24,P25,P26,P27,P28,P29
	DC.L P30,P31,P32,P33,P34,P35,P36,P37,P38,P39
	DC.L P40,P41,P42,P43,P44,P45,P46,P47,P48,P49
	DC.L P50,P51,P52,P53,P54,P55,P56,P57,P58,P59
	DC.L P60,P61,P62,P63,P64,P65,P66,P67,P68,P69
	DC.L P70,P71,P72,P73,P74,P75,P76,P77,P78,P79
	DC.L P80,P81,P82,P83,P84,P85,P86,P87,P88,P89
	DC.L P90,P91,P92,P93,P94,P95,P96,P97,P98,P99

PositionInText
	DC.L Message

Message		
 DC.B " WELL HERE IS THE HELIX SCROLL BY MATRIXX OF THE ST SQUAD, IMPRESSIVE? NO, NOT REALLY!!! BUT ONCE THE MASTER GRIFF HAS FINISHED WITH IT..........          ",0
	EVEN

CharTable:
	DS.W 32
	DC.W 00*384,27*384,31*384,32*384,32*384,32*384,32*384,31*384,34*384,33*384,31*384,32*384,30*384,32*384,29*384,32*384
	DC.W 00*384,00*384,00*384,00*384,00*384,00*384,00*384,00*384,00*384,00*384,32*384,32*384,32*384,32*384,32*384,28*384
	DC.W 32*384,01*384,02*384,03*384,04*384,05*384,06*384,07*384,08*384,09*384,10*384,11*384,12*384,13*384,14*384,15*384
	DC.W 16*384,17*384,18*384,19*384,20*384,21*384,22*384,23*384,24*384,25*384,26*384,34*384,31*384,33*384,31*384,32*384
	DC.W 31*384,01*384,02*384,03*384,04*384,05*384,06*384,07*384,08*384,09*384,10*384,11*384,12*384,13*384,14*384,15*384
	DC.W 16*384,17*384,18*384,19*384,20*384,21*384,22*384,23*384,24*384,25*384,26*384,34*384,31*384,33*384,32*384,29*384

Palette	DC.W $000,$322,$433,$544,$112,$322,$433,$544
	DC.W $223,$322,$433,$544,$334,$322,$433,$544
CharPointers	
	DS.W 11
Chars	DS.L 64
	INCBIN	A:\HELIX.INC\TWSTFONT.SPR
	EVEN

SideBar	DS.L 3 
	INCBIN	A:\HELIX.INC\SIDEBAR.SPR
	DS.L 4
	EVEN

ScreenPos	DC.L $F0300
ScreenPos2	DC.L $F8000
LineCount	DC.W 128
ScrollPos	DC.W 0
ScrollPos16	DC.W 0
FontPos		DC.L NEWFONT
		DC.W 50
		DC.W 50
		SECTION BSS
		DS.L 139
Stack		DS.W 1
TrueScreenPos	DS.L 1
OldMode		DS.B 1
OldRes		DS.B 1
VBLFlag		DS.W 1
OLD_VBL_VEC	DS.L 1
OLD_IEB		DS.B 1
OLD_IEA		DS.B 1
OLD_IMA		DS.B 1
OLD_SHFTMOD	DS.B 1
OLD_PALETTE	DS.L 8
NEWFONT		DS.L 53760
