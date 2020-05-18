;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~ Shell *.TTP type for the routine CPU_MOD.BIN ~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;This routine is relocatable , reserve 70000 bytes free after the code
;reserve 1000 bytes free after the module
;You must be in supervisor mode.

	OUTPUT	CPU_MODX.TTP

;-------------------------------------------------------------------------------
;TOS-Type call:

;Error.B = CPU_MOD( Cmd.W ,0.W , Mo_St.W , Freq.W , MOD_Ad.L , MOD_Ln.L )
;D0		    SP+4	 SP+8	   SP+10    SP+12      SP+16

;Error= 0:No error
;      -1:Error (Power OFF ? , Incorrect module ? , No module ?)

;Cmd=	0:-
;	1:Power OFF/ON						[Esc]
;	2:Open new module at address=MOD_Ad and length=MOD_Ln
;	3:Pause/Play						[SP]
;	4:Stop							[-]
;	5:Song position Reverse Search				[(]
;	6:Song position Forward Search				[)]
;	7:Fast Forward OFF/ON					[+]
;	8:Repeat mode OFF/ON					[.]

;Mo_St= 0:-
;	1:Mono/Stereo						[*]

;Freq=	0:-
;	1: 6258 Hz (Default)					[3]
;	2:12517 Hz						[2]
;	3:25033 Hz						[1]
;	4:50066 Hz						[0]

;Other commands:
;	Decrease Volume 					[F1]
;	Increase Volume 					[F2]
;	Decrease Left  Fader					[F3]
;	Increase Left  Fader					[F4]
;	Decrease Right Fader					[F5]
;	Increase Right Fader					[F6]
;	Decrease Bass						[F7]
;	Increase Bass						[F8]
;	Decrease Treble 					[F9]
;	Increase Treble 					[F10]
;	Reset Timer						[T]
;	Save Preferences					[S]
;	Show Sample Infos					(Help]

;-------------------------------------------------------------------------------

ProgHeader=28

Esc=27

ObjectArrayLength=24

ObjectNext=0
ObjectHead=2
ObjectTail=4
ObjectType=6
ObjectFlags=8
ObjectState=10
ObjectSpec=12
ObjectX=16
ObjectY=18
ObjectW=20
ObjectH=22

ONil=-1
ONull=0
OModuleText=1
OCommandText=2
OSampleText1=3
OSampleText2=4
OBottomLine=5
OFileName=6
OFileExtension=7
OFileLength=8
OModuleName=9
OCurrentPosition=10
OPositionCount=11
OCurrentPattern=12
OPatternCount=13
OMinutes=14
OSeconds=15
OPlay=16
OFastForward=17
ORepeat=18
OMonoStereo=19
OFrequency=20
OVolume=21
OLeftFader=22
ORightFader=23
OBass=24
OTreble=25
TNull=0
TIndexedString=1
TInteger8bUnsigned=2
TInteger8bSigned=3
TInteger16bUnsigned=4
TInteger16bSigned=5
TInteger24bUnsigned=6
TInteger24bSigned=7
TInteger32bUnsigned=8
TInteger32bSigned=9
TString=28
FIndirect=1<<8
SSelected=1
SRightJustified=1<<9
SZeroed=1<<10
SPlus_0=%10<<11

	M_
bss	DS.B 70000 ;for CPU_MOD.BIN
_BSS=bss-4 ;Cause to "0000" at the end of CPU_MOD.BIN

;Addresses of some usefull variables in CPU_MOD
; CurrentPosition = (_BSS+142).W			= 0 to 127
; PositionCount   = ((_BSS+2).L-2).B -1 		= 0 to 127
; CurrentPattern  = ((_BSS+2).L+(_BSS+142).W).B 	= 0 to 63
; PatternCount	  = ((_BSS+10).L-(_BSS+6).L)/1024 -1	= 0 to 63
; SampleNumber	  = (_BSS+0).W				= 15 or 31
; Play		  = BTST #0,SND_CR+1
	P_

	BRA.S	e0e
;Preferences saved here in the file CPU_MODX.TTP
;with the command "S"
MonoStereo	DC.W 0 ;0 or 1
Frequency	DC.W 0 ;0:6258 1:12517 2:25033 3:50066 Hz
Volume		DC.W 0 ;0 dB
LeftFader	DC.W 0 ;0 dB
RightFader	DC.W 0 ;0 dB
Bass		DC.W 0 ;0 dB
Treble		DC.W 0 ;0 dB

GetCurrentPosition:	;(_BSS+142).W
	MOVEQ	#0,D0
	MOVE	_BSS+142(PC),D0
	RTS

GetPositionCount:	;((_BSS+2).L-2).B -1
	MOVEQ	#0,D0
	MOVEA.L _BSS+2(PC),A0
	MOVE.B	-2(A0),D0
	SUBQ	#1,D0
	RTS

GetCurrentPattern:	;((_BSS+2).L+(_BSS+142).W).B
	MOVEQ	#0,D0
	MOVEA.L _BSS+2(PC),A0
	ADDA	_BSS+142(PC),A0
	MOVE.B	(A0),D0
	RTS

GetPatternCount:	;((_BSS+10).L-(_BSS+6).L)/1024 -1
	MOVE.L	_BSS+10(PC),D0
	SUB.L	_BSS+6(PC),D0
	LSR.L	#8,D0
	LSR.L	#2,D0
	SUBQ	#1,D0
	RTS

GetSampleNumber:	;(_BSS+0).W
	MOVEQ	#0,D0
	MOVE	_BSS(PC),D0
	RTS

GetPlay:
	BTST	#0,SND_CR+1
	SNE	D0
	RTS

e0e	LEA	Module,A6	;A6 = Module
	LEA	CPU_MOD(PC),A5	;A5 = CPU_MOD
	MOVEA.L 4(SP),A0
	MOVE.L	4(A0),D7
	SUB.L	A6,D7
	SUBI.L	#1000,D7 	;D7 = Module length maxi
				;-1000 for CPU_MOD.BIN
	LEA	128+1(A0),A4	;A4 = Parameter Line
 ;LOADING
	FILE_OPEN A4,#0
	MOVE	D0,D3
	BMI	x0x
	FILE_READ D3,D7,A6
	LEA	FileLength(PC),A0
	MOVE.L	D0,(A0)
	BMI	x0x
	FILE_CLOSE D3
e1e	PROG_SUPERMODE #0
	MOVE.L	D0,SPSaved
 ;CPU_MOD INIT
e2e	MOVE	Frequency(PC),D0
	BEQ.S	.1
	ADDQ	#1,D0
.1	MOVE	D0,-(SP)
	MOVE	MonoStereo(PC),-(SP)
	CLR	-(SP)
	MOVE	#1,-(SP) ;Power ON
	JSR	(A5)
	ADDQ	#8,SP
	MOVE.L	FileLength(PC),-(SP)
	PEA	(A6)
	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	MOVE	#2,-(SP) ;Open MOD
	JSR	(A5)
	ADDA	#16,SP
	TST.B	D0
	BNE	x2x
	BRA	LMC1992

WriteData:
	ORI	#%10<<9,D0
	MOVE	#%11111111111,D1 ;Mask
	ORI	#$0700,SR
	LEA	TON_MASK,A0
	MOVE	D1,(A0)
	MOVE	D0,TON_DATA
.1	CMP	(A0),D1
	BEQ	.1
.2	CMP	(A0),D1
	BNE	.2
	ANDI	#$FCFF,SR
	RTS

SetVolume:
	MOVE	Volume(PC),D0
	ADDI	#80,D0
	LSR	#1,D0
	ANDI	#%111111,D0
	ORI	#%011<<6,D0
	BRA	WriteData

SetLeftFader:
	MOVE	LeftFader(PC),D0
	ADDI	#40,D0
	LSR	#1,D0
	ANDI	#%111111,D0
	ORI	#%101<<6,D0
	BRA	WriteData

SetRightFader:
	MOVE	RightFader(PC),d0
	ADDI	#40,D0
	LSR	#1,D0
	ANDI	#%111111,D0
	ORI	#%100<<6,D0
	BRA	WriteData

SetBass:
	MOVE	Bass(PC),D0
	ADDI	#12,D0
	LSR	#1,D0
	ANDI	#%111111,D0
	ORI	#%001<<6,D0
	BRA	WriteData

SetTreble:
	MOVE	Treble(PC),D0
	ADDI	#12,D0
	LSR	#1,D0
	ANDI	#%111111,D0
	ORI	#%010<<6,D0
	BRA	WriteData

LMC1992:
	BSR	SetVolume
	BSR	SetLeftFader
	BSR	SetRightFader
	BSR	SetBass
	BSR	SetTreble

e3e	LEA	$484,A0 ;CLICK OFF
	MOVE.B	(A0),KeyPrefsSaved
	ANDI.B	#%11111000,(A0)

e4e	MOVE.B	#18,KBD_TD ;MOUSE OFF
	BRA	e5e

ConvertInteger32bToASCII:
 ;D0.L -> Integer32b
 ;D1   -> Mode
 ;	     b0= Signed mode
 ;	  b2-b1= Sign for positive number
 ;		 00: ''
 ;		 01: ' '
 ;		 10: '+' except for 0
 ;		 11: '+'
 ;A0   -> String of 1+10+1 bytes maxi
 ;Base=10
WorkPad=12
	LINK	A6,#-WorkPad
	MOVEA.L A6,A1
	BTST	#0,D1
	BEQ.S	.32bu
	ANDI	#%110,D1
	LSR	#1,D1
.32bs	TST.L	D0
	BMI.S	.neg
.pos	CMPI	#%00,D1
	BEQ.S	.32bu
	CMPI	#%01,D1
	BNE.S	.1
	MOVE.B	#' ',(A0)+
	BRA.S	.32bu
.1	CMPI	#%10,D1
	BNE.S	.2
	TST.L	D0
	BEQ.S	.32bu
.2	MOVE.B	#'+',(A0)+
	BRA.S	.32bu
.neg	MOVE.B	#'-',(A0)+
	NEG.L	D0
.32bu	SWAP	D0
	MOVEQ	#0,D1
	MOVE	D0,D1 ;D1=XHigh
	CLR	D0
	SWAP	D0 ;D0=XLow
.divH	TST	D1
	BEQ.S	.divL
	DIVU	#10,D1
	SWAP	D1
	MOVEQ	#0,D2
	MOVE	D1,D2
	SWAP	D2
	ADD.L	D2,D0
	CLR	D1
	SWAP	D1
.divL	DIVU	#10,D0
	SWAP	D0
	ADDI	#'0',D0
	MOVE.B	D0,-(A6)
	CLR	D0
	SWAP	D0
	BNE.S	.divH
.copy	MOVE.B	(A6)+,(A0)+
	CMPA.L	A1,A6
	BNE	.copy
	CLR.B	(A0)
	UNLK	A6
	RTS

PrintMode		DS.W 1
PrintStringAddress	DS.L 1
PrintStringAddress2	DS.L 1
PrintStringLength	DS.W 1
PrintOutput		DS.W 1
PrintCharacterCount	DS.W 1
PrintCharacterCount2	DS.W 1
PrintAnteSPCount	DS.W 1
PrintPastSPCount	DS.W 1

PrintCharacter:
 ;D0 -> Character , Yes D0 !
 ;PrintOutput -> Output
 ;		      2:CONS
 ;		      5:SCRN
	CONS_OUT PrintOutput(PC),D0
	RTS

PrintString:
 ;PrintMode
 ;	 b0= Invalid 0 terminated string
 ;	     Valid PrintStringLength ->
 ;	 b1= Invalid control characters
 ;	 b2= Output character count =< PrintCharacterCount
 ;	 b3= Output character count => PrintCharacterCount
 ;	 b4= Right Justified
 ;	 b5= '0' for GAP
 ;PrintStringAddress= Address of string

	LEA	PrintStringAddress2(PC),A0
	MOVE.L	PrintStringAddress(PC),(A0)
	LEA	PrintCharacterCount2(PC),A0
	MOVE.L	PrintCharacterCount(PC),(A0)
.InitPrintOutput
	LEA	PrintOutput(PC),A0
	MOVEQ	#2,D0
	MOVE	PrintMode(PC),D1
	BTST	#1,D1
	BEQ.S	.Output
	MOVEQ	#5,D0
.Output MOVE	D0,(A0)
.InitPrintStringLength
	MOVE	PrintMode(PC),D0
	BTST	#0,D0
	BNE.S	.InitPrintStringAddress2
	ANDI	#%111101,D0
	BEQ	.PrintQuickC
	MOVEQ	#0,D0 ;count
	MOVE	#65535-1,D1 ;65535 bytes for limit
	MOVE	PrintMode(PC),D2
	ANDI	#%010100,D2
	CMPI	#%000100,D2
	BNE.S	.cnt
	MOVE	PrintCharacterCount(PC),D1
	SUBQ	#1,D1
.cnt	MOVEA.L PrintStringAddress2(PC),A0
.test	TST.B	(A0)+
	BEQ.S	.length
	ADDQ	#1,D0
	DBRA	D1,.test
.length LEA	PrintStringLength(PC),A0
	MOVE	D0,(A0)
.InitPrintStringAddress2
	LEA	PrintStringAddress2(PC),A0
	MOVE	PrintMode(PC),D0
	BTST	#2,D0
	BEQ.S	.InitPrintCharacterCount2
	BTST	#4,D0
	BEQ.S	.InitPrintCharacterCount2
	MOVEQ	#0,D0
	MOVE	PrintStringLength(PC),D0
	SUB	PrintCharacterCount2(PC),D0
	BLS.S	.InitPrintCharacterCount2
	ADD.L	D0,(A0)
.InitPrintCharacterCount2 ; with SP
	LEA	PrintCharacterCount2(PC),A0
	MOVE	PrintStringLength(PC),D0
	MOVE	PrintMode(PC),D1
	BTST	#2,D1
	BEQ.S	.min
	CMP	(A0),D0
	BLS.S	.min
	MOVE	(A0),D0
.min	BTST	#3,D1
	BEQ.S	.CharacterCount
	CMP	(A0),D0
	BHS.S	.CharacterCount
	MOVE	(A0),D0
.CharacterCount
	MOVE	D0,(A0)
.InitPrintAnteSPCount2
	LEA	PrintAnteSPCount(PC),A1
	MOVEQ	#0,D0
	BTST	#4,D1
	BEQ.S	.AnteSPCount
	MOVE	(A0),D2
	SUB	PrintStringLength(PC),D2
	BLS.S	.AnteSPCount
	MOVE	D2,D0
.AnteSPCount
	MOVE	D0,(A1)
	SUB	D0,(A0)
.InitPrintPastSPCount
	LEA	PrintPastSPCount(PC),A1
	MOVEQ	#0,D0
	BTST	#4,D1
	BNE.S	.PastSPCount
	MOVE	(A0),D2
	SUB	PrintStringLength(PC),D2
	BLS.S	.PastSPCount
	MOVE	D2,D0
.PastSPCount
	MOVE	D0,(A1)
	SUB	D0,(A0)

.PrintAnteSP
	MOVE	PrintAnteSPCount(PC),D0
	BEQ.S	.PrintCharacter
.nasp	MOVEQ	#' ',D0
	LEA	PrintMode+1(PC),A0
	BTST	#5,(A0)
	BEQ.S	.pasp
	MOVEQ	#'0',D0
.pasp	BSR	PrintCharacter
	LEA	PrintAnteSPCount(PC),A0
	SUBQ	#1,(A0)
	BNE	.nasp

.PrintCharacter
	MOVE	PrintCharacterCount2(PC),D0
	BEQ.S	.PrintPastSP
.nchar	LEA	PrintStringAddress2(PC),A0
	MOVEA.L (A0),A1
	MOVE.B	(A1)+,D0
	MOVE.L	A1,(A0)
	BSR	PrintCharacter
	LEA	PrintCharacterCount2(PC),A0
	SUBQ	#1,(A0)
	BNE	.nchar

.PrintPastSP
	MOVE	PrintPastSPCount(PC),D0
	BEQ.S	.x
.npsp	MOVEQ	#' ',D0
	LEA	PrintMode+1(PC),A0
	BTST	#5,(A0)
	BEQ.S	.ppsp
	MOVEQ	#'0',D0
.ppsp	BSR	PrintCharacter
	LEA	PrintPastSPCount(PC),A0
	SUBQ	#1,(A0)
	BNE	.npsp
.x	RTS

.PrintQuickC
	LEA	PrintStringAddress2(PC),A0
	MOVEA.L (A0),A1
	MOVE.B	(A1)+,D0
	BEQ.S	.xQC
	MOVE.L	A1,(A0)
	BSR	PrintCharacter
	BRA	.PrintQuickC
.xQC	RTS

PrintString0: ; C-style
 ;A0 -> Address of string
	LEA	PrintStringAddress(PC),A1
	MOVE.L	A0,(A1)
	LEA	PrintMode(PC),A1
	CLR	(A1)
	BSR	PrintString
	RTS

NormalVideo:
	LEA	.nv(PC),A0
	BSR	PrintString0
	RTS
.nv	DC.B	Esc,'q',0,0

InverseVideo:
	LEA	.iv(PC),A0
	BSR	PrintString0
	RTS
.iv	DC.B	Esc,'p',0,0

e5e	LEA	VID_CR0,A0
	MOVE	(A0),VID_CR0Saved
	CLR	(A0)
	LEA	SetScreen(PC),A0
	BSR	PrintString0
	BRA	RscInit

GetSpec:
 ;D0 <- Spec
 ;D1 -> Object
	LEA	ObjectList(PC),A0
	MULU	#ObjectArrayLength,D1
	ADDA	D1,A0
	MOVEA.L ObjectSpec(A0),A1
	BTST	#0,ObjectFlags(A0)
	BEQ.S	.1
	MOVEA.L (A1),A1
.1	MOVE.L	A1,D0
	RTS

SetSpec:
 ;D0 -> Spec
 ;D1 -> Object
	LEA	ObjectList(PC),A0
	MULU	#ObjectArrayLength,D1
	ADDA	D1,A0
	LEA	ObjectSpec(A0),A1
	BTST	#0,ObjectFlags(A0)
	BEQ.S	.1
	MOVEA.L (A1),A1
.1	MOVE.L	D0,(A1)
	RTS

RscCenter:
	DC.W	$A000
	MOVE	-44(A0),D0 ; V_CEL_MX
	ADDQ	#1,D0
	MOVE	-42(A0),D1 ; V_CEL_MY
	ADDQ	#1,D1
	LEA	ObjectList(PC),A0
	MOVEQ	#OTreble-ONull,D2
	SUB	ObjectW(A0),D0
	LSR	#1,D0
	SUB	ObjectH(A0),D1
	LSR	#1,D1
.center ADD	D0,ObjectX(A0)
	ADD	D1,ObjectY(A0)
	ADDA	#ObjectArrayLength,A0
	DBRA	D2,.center
	RTS

RscModuleText:
 ;Init FileName & FileExtension
	LEA	FileExtension(PC),A0
	MOVEQ	#0,D0
	MOVE.B	-1(A4),D0
	LEA	(A4,D0),A3
	MOVEA.L A3,A2
	MOVEA.L A3,A1
	MOVEQ	#4-1,D0 ;4 characters for '.XXX'
.se	CMPA.L	A4,A1
	BEQ.S	.file
	CMPI.B	#'.',-(A1)
	DBEQ	D0,.se
	BNE.S	.file
	MOVEA.L A1,A2
	ADDQ	#1,A1
.ce	CMPA.L	A3,A1
	BEQ.S	.file
	MOVE.B	(A1)+,(A0)+
	BRA	.ce
.file	LEA	FileName(PC),A0
	MOVEA.L A2,A1
	MOVEQ	#9-1,D0 ;9 characters for '\XXXXXXXX'
.sf	CMPA.L	A4,A1
	BEQ.S	.cf
	CMPI.B	#'\',-1(A1)
	BEQ.S	.cf
	CMPI.B	#':',-1(A1)
	BEQ.S	.cf
	SUBQ	#1,A1
	DBRA	D0,.sf
.cf	CMPA.L	A2,A1
	BEQ.S	.poscount
	MOVE.B	(A1)+,(A0)+
	BRA	.cf
.poscount ;Init PositionCount & PatternCount
	BSR	GetPositionCount
	MOVEQ	#OPositionCount,D1
	BSR	SetSpec
	BSR	GetPatternCount
	MOVEQ	#OPatternCount,D1
	BSR	SetSpec
	RTS

RscSampleText:
	LEA	SampleText1+40+9(PC),A0
	LEA	20(A6),A1
	MOVEQ	#15-1,D0
.1_15	MOVEQ	#22-1,D1
.r1	MOVE.B	(A1)+,D2
	BNE.S	.w1
	MOVEQ	#' ',D2
.w1	MOVE.B	D2,(A0)+
	DBRA	D1,.r1
	LEA	40-22(A0),A0
	LEA	30-22(A1),A1
	DBRA	D0,.1_15
	BSR	GetSampleNumber
	CMPI	#31,D0
	BNE.S	.x
	LEA	SampleText2+9(PC),A0
	LEA	20+30*15(A6),A1
	MOVEQ	#16-1,D0
.16_31	MOVEQ	#22-1,D1
.r2	MOVE.B	(A1)+,D2
	BNE.S	.w2
	MOVEQ	#' ',D2
.w2	MOVE.B	D2,(A0)+
	DBRA	D1,.r2
	LEA	40-22(A0),A0
	LEA	30-22(A1),A1
	DBRA	D0,.16_31
.x	RTS

RscInit:
	BSR	RscCenter
	BSR	RscModuleText
	BSR	RscSampleText
	BRA	DrawMainPage

DrawTreeAd	DS.L 1
DrawObjectNb	DS.W 1
DrawObjectRoot	DS.W 1
DrawObjectTail	DS.W 1
DrawObjectAd	DS.L 1
DrawX		DS.W 1
DrawY		DS.W 1
DrawSpec	DS.L 1
DrawString	DS.B 12

DrawAt:
 ;DrawX -> X
 ;DrawY -> Y
	LEA	.at(PC),A0
	MOVE	DrawX(PC),D0
	MOVE	DrawY(PC),D1
	ADDI	#32,D0
	ADDI	#32,D1
	MOVE.B	D0,3(A0)
	MOVE.B	D1,2(A0)
	BSR	PrintString0
	RTS
.at	DC.B	Esc,'Y',0,0,0 ;Y+32 and X+32
	EVEN

DrawAtObject:
 ;DrawObjectAd -> ObjectAddress
	MOVEA.L DrawObjectAd(PC),A0
	LEA	DrawX(PC),A1
	MOVE	ObjectX(A0),(A1)
	LEA	DrawY(PC),A1
	MOVE	ObjectY(A0),(A1)
	BRA	DrawAt

DrawNormal:
 ;DrawObjectAd -> ObjectAddress
	MOVEA.L DrawObjectAd(PC),A0
	BTST	#0,ObjectState+1(A0)
	BEQ.S	.x
	BSR	NormalVideo
.x	RTS

DrawInverse:
 ;DrawObjectAd -> ObjectAddress
	MOVEA.L DrawObjectAd(PC),A0
	BTST	#0,ObjectState+1(A0)
	BEQ.S	.x
	BSR	InverseVideo
.x	RTS

ReadSpec:
 ;DrawObjectAd -> ObjectAddress
 ;DrawSpec     <-
	LEA	DrawSpec(PC),A0
	MOVEA.L DrawObjectAd(PC),A1
	MOVEA.L ObjectSpec(A1),A2
	BTST	#0,ObjectFlags(A1)
	BEQ.S	.1
	MOVEA.L (A2),A2
.1	MOVE.L	A2,(A0)
	RTS

DrawInteger32bUnsigned:
 ;D0 -> Integer32b
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	MOVEQ	#%000,D1
	LEA	DrawString(PC),A0
	BSR	ConvertInteger32bToASCII
	LEA	PrintMode(PC),A0
	MOVEQ	#%001100,D0
	MOVEA.L DrawObjectAd(PC),A1
	MOVE	ObjectState(A1),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A0)
	LEA	PrintCharacterCount(PC),A0
	MOVE	ObjectW(A1),(A0)
	LEA	PrintStringAddress(PC),A0
	LEA	DrawString(PC),A1
	MOVE.L	A1,(A0)
	BSR	PrintString
	RTS

DrawInteger32bSigned:
 ;D0 -> Integer32b
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	MOVEQ	#%001,D1
	MOVE.B	ObjectState(A0),D2
	LSR	#2,D2
	ANDI	#%110,D2
	OR	D2,D1
	LEA	DrawString(PC),A0
	BSR	ConvertInteger32bToASCII
	LEA	PrintMode(PC),A0
	MOVEQ	#%001100,D0
	MOVEA.L DrawObjectAd(PC),A1
	MOVE	ObjectState(A1),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A0)
	LEA	PrintCharacterCount(PC),A0
	MOVE	ObjectW(A1),(A0)
	LEA	PrintStringAddress(PC),A0
	LEA	DrawString(PC),A1
	MOVE.L	A1,(A0)
	BSR	PrintString
	RTS

DrawTNull:
	RTS

DrawTIndexedString:
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	MOVEA.L DrawSpec(PC),A1
	MOVEA.L (A1)+,A2
	MOVE	(A2),D0
	LSL	#2,D0
	MOVEA.L (A1,D0),A1
	LEA	PrintStringAddress(PC),A2
	MOVE.L	A1,(A2)
	LEA	PrintMode(PC),A1
	MOVEQ	#%001110,D0
	MOVE	ObjectState(A0),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A1)
	LEA	PrintCharacterCount(PC),A1
	MOVE	ObjectW(A0),(A1)
	BSR	PrintString
	RTS

DrawTInteger8bUnsigned:
	MOVEQ	#0,D0
	MOVE.B	DrawSpec+3(PC),D0
	BRA	DrawInteger32bUnsigned

DrawTInteger8bSigned:
	MOVE.B	DrawSpec+3(PC),D0
	EXT.W	D0
	EXT.L	D0
	BRA	DrawInteger32bSigned

DrawTInteger16bUnsigned:
	MOVEQ	#0,D0
	MOVE	DrawSpec+2(PC),D0
	BRA	DrawInteger32bUnsigned

DrawTInteger16bSigned:
	MOVE	DrawSpec+2(PC),D0
	EXT.L	D0
	BRA	DrawInteger32bSigned

DrawTInteger24bUnsigned:
	MOVE.L	DrawSpec(PC),D0
	ANDI.L	#$FFFFFF,D0
	BRA	DrawInteger32bUnsigned

DrawTInteger24bSigned:
	MOVE.L	DrawSpec(PC),D0
	SWAP	D0
	EXT.W	D0
	SWAP	D0
	BRA	DrawInteger32bSigned

DrawTInteger32bUnsigned:
	MOVE.L	DrawSpec(PC),D0
	BRA	DrawInteger32bUnsigned

DrawTInteger32bSigned:
	MOVE.L	DrawSpec(PC),D0
	BRA	DrawInteger32bSigned

DrawTString:
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	LEA	PrintStringAddress(PC),A1
	MOVE.L	DrawSpec(PC),(A1)
	LEA	.ox(PC),A1
	MOVE	ObjectX(A0),(A1)+
	MOVE	ObjectY(A0),(A1)+
	MOVE	ObjectW(A0),(A1)+
	MOVE	ObjectH(A0),(A1)
	LEA	PrintMode(PC),A1
	MOVEQ	#%001110,D0
	MOVE	ObjectState(A0),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A1)
	LEA	PrintCharacterCount(PC),A1
	MOVE	.ow(PC),(A1)
.p	BSR	PrintString
	LEA	.oh(PC),A0
	SUBQ	#1,(A0)
	BEQ.S	.x
	MOVEA.L PrintStringAddress(PC),A0
	MOVEQ	#0,D0
	MOVE	PrintStringLength(PC),D0
	ADDA.L	D0,A0
	PEA	(A0)
	MOVE	PrintMode(PC),-(SP)
	LEA	DrawX(PC),A0
	MOVE	.ox(PC),(A0)
	LEA	DrawY(PC),A0
	LEA	.oy(PC),A1
	ADDQ	#1,(A1)
	MOVE	(A1),(A0)
	BSR	DrawAt
	LEA	PrintMode(PC),A0
	MOVE	(SP)+,(A0)
	LEA	PrintStringAddress(PC),A0
	MOVE.L	(SP)+,(A0)
	BRA	.p
.x	RTS

.ox	DS.W	1
.oy	DS.W	1
.ow	DS.W	1
.oh	DS.W	1

DrawTypeTable:
	DC.W	DrawTNull-DrawTNull
	DC.W	DrawTIndexedString-DrawTNull
	DC.W	DrawTInteger8bUnsigned-DrawTNull
	DC.W	DrawTInteger8bSigned-DrawTNull
	DC.W	DrawTInteger16bUnsigned-DrawTNull
	DC.W	DrawTInteger16bSigned-DrawTNull
	DC.W	DrawTInteger24bUnsigned-DrawTNull
	DC.W	DrawTInteger24bSigned-DrawTNull
	DC.W	DrawTInteger32bUnsigned-DrawTNull
	DC.W	DrawTInteger32bSigned-DrawTNull

DrawType:
 ;DrawObjectAd -> ObjectAddress
	MOVEA.L DrawObjectAd(PC),A0
	MOVE	ObjectType(A0),D0
	CMPI	#TString,D0
	BNE.S	.1
	BRA	DrawTString
.1	CMPI	#TInteger32bSigned,D0
	BLS.S	.2
	RTS
.2	LEA	DrawTypeTable(PC),A1
	LSL	#1,D0
	MOVE	(A1,D0),D0
	LEA	DrawTNull(PC),A1
	JMP	(A1,D0) ;A0 -> ObjectAddress

DrawObject:
 ;DrawTreeAd -> Tree
 ;DrawObjectNb -> Object
	LEA	DrawObjectAd(PC),A0
	MOVEA.L DrawTreeAd(PC),A1
	MOVE	DrawObjectNb(PC),D1
	MULU	#ObjectArrayLength,D1
	ADDA	D1,A1
	MOVE.L	A1,(A0)
	BSR	DrawAtObject
	BSR	DrawInverse
	BSR	ReadSpec
	BSR	DrawType
	BSR	DrawNormal
	RTS

DrawTree:
 ;DrawTreeAd -> Tree
 ;DrawObjectNb -> Object
	LEA	DrawObjectRoot(PC),A0
	MOVE	DrawObjectNb(PC),(A0)
.draw	BSR	DrawObject
	MOVEA.L DrawTreeAd(PC),A0
	MOVE	DrawObjectNb(PC),D0
	MULU	#ObjectArrayLength,D0
	MOVE	ObjectHead(A0,D0),D1
	BMI.S	.next
.head	LEA	DrawObjectNb(PC),A1
	MOVE	D1,(A1)
	LEA	DrawObjectTail(PC),A1
	MOVE	(A1),-(SP)
	MOVE	ObjectTail(A0,D0),(A1)
	BRA	.draw
.next	MOVE	DrawObjectNb(PC),D1
	CMP	DrawObjectRoot(PC),D1
	BEQ.S	.x
.bof	LEA	DrawObjectTail(PC),A1
	CMP	(A1),D1
	BEQ.S	.father
.brother
	LEA	DrawObjectNb(PC),A1
	MOVE	ObjectNext(A0,D0),(A1)
	BRA	.draw
.father MOVE	(SP)+,(A1)
	MOVE	ObjectNext(A0,D0),D1
	CMP	DrawObjectRoot(PC),D1
	BEQ.S	.x
	MOVE	D1,D0
	MULU	#ObjectArrayLength,D0
	BRA	.bof
.x	RTS

DrawMainPage:
	LEA	DrawTreeAd(PC),A0
	LEA	ObjectList(PC),A1
	MOVE.L	A1,(A0) ;Once only: 1 single tree
	LEA	DrawObjectNb(PC),A0
	MOVE	#ONull,(A0)
	BSR	DrawTree
	BRA	PLAY

GetInputState:
	CONS_GINSTATE #2
	RTS

GetKey:
	CONS_IN #2
	RTS

WaitKey:
	BSR	RealTimeVar
	BSR	GetInputState
	TST	D0
	BEQ	WaitKey
	BSR	GetKey
	CMPI.B	#Esc,D0
	BEQ	x5x
	CMPI.B	#' ',D0
	BEQ	PLAY
	CMPI.B	#'-',D0
	BEQ	STOP
	CMPI.B	#'(',D0
	BEQ	SGRS
	CMPI.B	#')',D0
	BEQ	SGFS
	CMPI.B	#'+',D0
	BEQ	FAST
	CMPI.B	#'.',D0
	BEQ	REPT
	CMPI.B	#'*',D0
	BEQ	MOST
	CMPI.B	#'0',D0
	BLO.S	.1
	CMPI.B	#'3',D0
	BLS	FREQ
.1	CMPI.B	#'t',D0
	BEQ	TIME
	CMPI.B	#'T',D0
	BEQ	TIME
	CMPI.B	#'s',D0
	BEQ	SAVE
	CMPI.B	#'S',D0
	BEQ	SAVE
	SWAP	D0
	CMPI.B	#$3B,D0
	BEQ	DVOL
	CMPI.B	#$3C,D0
	BEQ	IVOL
	CMPI.B	#$3D,D0
	BEQ	DLFA
	CMPI.B	#$3E,D0
	BEQ	ILFA
	CMPI.B	#$3F,D0
	BEQ	DRFA
	CMPI.B	#$40,D0
	BEQ	IRFA
	CMPI.B	#$41,D0
	BEQ	DBAS
	CMPI.B	#$42,D0
	BEQ	IBAS
	CMPI.B	#$43,D0
	BEQ	DTRE
	CMPI.B	#$44,D0
	BEQ	ITRE
	CMPI.B	#$62,D0
	BEQ	HELP
	BRA	WaitKey

RealTimeVar:
.position
	MOVEQ	#OCurrentPosition,D1
	BSR	GetSpec
	MOVE.L	D0,D3
	BSR	GetCurrentPosition
	CMP.L	D3,D0
	BEQ.S	.pattern
	MOVEQ	#OCurrentPosition,D1
	BSR	SetSpec
	LEA	DrawObjectNb(PC),A0
	MOVE	#OCurrentPosition,(A0)
	BSR	DrawObject
.pattern
	MOVEQ	#OCurrentPattern,D1
	BSR	GetSpec
	MOVE.L	D0,D3
	BSR	GetCurrentPattern
	CMP.L	D3,D0
	BEQ.S	.time
	MOVEQ	#OCurrentPattern,D1
	BSR	SetSpec
	LEA	DrawObjectNb(PC),A0
	MOVE	#OCurrentPattern,(A0)
	BSR	DrawObject
.time	LEA	rtime(PC),A0
	MOVE.L	(A0),D0
	BNE.S	.vp
.irtim	MOVE.L	tim_cnt,(A0)
	BRA.S	.play
.vp	MOVE	Play(PC),D1
	BEQ.S	.irtim
	MOVE.L	tim_cnt,(A0)
	SUB.L	(A0),D0
	NEG.L	D0
	LEA	mtime(PC),A0
	ADD.L	D0,(A0)
	MOVE.L	(A0),D0
	DIVU	#200,D0 ;200 Hz D0=Time in seconds
	EXT.L	D0
	DIVU	#60,D0
	SWAP	D0 ;D0=Minutes|Seconds
	LEA	Minutes(PC),A0
	CMP.L	(A0),D0
	BEQ.S	.play
	MOVE.L	D0,(A0)
	LEA	DrawObjectNb(PC),A0
	MOVE	#OMinutes,(A0)
	BSR	DrawTree
.play	MOVE	Play(PC),D0
	BEQ.S	.x
	BSR	GetPlay
	TST.B	D0
	BNE.S	.x
	LEA	Play(PC),A0
	CLR	(A0)
	LEA	DrawObjectNb(PC),A0
	MOVE	#OPlay,(A0)
	BSR	DrawObject
	BSR.S	Time0
.x	RTS

rtime	DS.L	1
mtime	DS.L	1

Time0	LEA	rtime(PC),A0
	CLR.L	(A0)+
	CLR.L	(A0)
	LEA	Minutes(PC),A0
	CLR.L	(A0)
 ; Pas de redessin pour avoir … l'‚cran la dur‚e totale
 ; lors de l'auto-stop
	RTS

CMD	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	MOVE	D0,-(SP)
	JSR	(A5)
	ADDQ	#8,SP
	RTS

PLAY	LEA	Play(PC),A0
	NOT	(A0)
	ADDQ	#2,(A0)
	MOVEQ	#3,D0
	BSR	CMD
	LEA	DrawObjectNb(PC),A0
	MOVE	#OPlay,(A0)
	BSR	DrawObject
	BRA	WaitKey

STOP	LEA	Play(PC),A0
	CLR	(A0)
	MOVEQ	#4,D0
	BSR	CMD
	LEA	DrawObjectNb(PC),A0
	MOVE	#OPlay,(A0)
	BSR	DrawObject
	BSR	Time0
	BRA	WaitKey

SGRS	MOVEQ	#5,D0
	BSR	CMD
	BRA	WaitKey

SGFS	MOVEQ	#6,D0
	BSR	CMD
	BRA	WaitKey

FAST	LEA	FastForward(PC),A0
	NOT	(A0)
	ADDQ	#2,(A0)
	MOVEQ	#7,D0
	BSR	CMD
	LEA	DrawObjectNb(PC),A0
	MOVE	#OFastForward,(A0)
	BSR	DrawObject
	BRA	WaitKey

REPT	LEA	Repeat(PC),A0
	NOT	(A0)
	ADDQ	#2,(A0)
	MOVEQ	#8,D0
	BSR	CMD
	LEA	DrawObjectNb(PC),A0
	MOVE	#ORepeat,(A0)
	BSR	DrawObject
	BRA	WaitKey

HARD	MOVE	D2,-(SP)
	MOVE	D1,-(SP)
	MOVE	D0,-(SP)
	CLR	-(SP)
	JSR	(A5)
	ADDQ	#8,SP
	RTS

MOST	LEA	MonoStereo(PC),A0
	NOT	(A0)
	ADDQ	#2,(A0)
	MOVEQ	#0,D0
	MOVEQ	#1,D1
	MOVEQ	#0,D2
	BSR	HARD
	LEA	DrawObjectNb(PC),A0
	MOVE	#OMonoStereo,(A0)
	BSR	DrawObject
	BRA	WaitKey

FREQ	ANDI	#$FF,D0
	SUBI	#'0',D0
	MOVEQ	#4,D2
	SUB	D0,D2
		LEA	Frequency(PC),A0
		MOVE	D2,D0
		SUBQ	#1,D0
		MOVE	D0,(A0)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	BSR	HARD
	LEA	DrawObjectNb(PC),A0
	MOVE	#OFrequency,(A0)
	BSR	DrawObject
	BRA	WaitKey

DVOL	LEA	Volume(PC),A0
	MOVE	(A0),D0
	SUBQ	#2,D0
	CMPI	#-80,D0
	BLT	WaitKey
	MOVE	D0,(A0)
	BSR	SetVolume
	LEA	DrawObjectNb(PC),A0
	MOVE	#OVolume,(A0)
	BSR	DrawObject
	BRA	WaitKey

IVOL	LEA	Volume(PC),A0
	MOVE	(A0),D0
	ADDQ	#2,D0
	BGT	WaitKey
	MOVE	D0,(A0)
	BSR	SetVolume
	LEA	DrawObjectNb(PC),A0
	MOVE	#OVolume,(A0)
	BSR	DrawObject
	BRA	WaitKey

DLFA	LEA	LeftFader(PC),A0
	MOVE	(A0),D0
	SUBQ	#2,D0
	CMPI	#-40,D0
	BLT	WaitKey
	MOVE	D0,(A0)
	BSR	SetLeftFader
	LEA	DrawObjectNb(PC),A0
	MOVE	#OLeftFader,(A0)
	BSR	DrawObject
	BRA	WaitKey

ILFA	LEA	LeftFader(PC),A0
	MOVE	(A0),D0
	ADDQ	#2,D0
	BGT	WaitKey
	MOVE	D0,(A0)
	BSR	SetLeftFader
	LEA	DrawObjectNb(PC),A0
	MOVE	#OLeftFader,(A0)
	BSR	DrawObject
	BRA	WaitKey

DRFA	LEA	RightFader(PC),A0
	MOVE	(A0),D0
	SUBQ	#2,D0
	CMPI	#-40,D0
	BLT	WaitKey
	MOVE	D0,(A0)
	BSR	SetRightFader
	LEA	DrawObjectNb(PC),A0
	MOVE	#ORightFader,(A0)
	BSR	DrawObject
	BRA	WaitKey

IRFA	LEA	RightFader(PC),A0
	MOVE	(A0),D0
	ADDQ	#2,D0
	BGT	WaitKey
	MOVE	D0,(A0)
	BSR	SetRightFader
	LEA	DrawObjectNb(PC),A0
	MOVE	#ORightFader,(A0)
	BSR	DrawObject
	BRA	WaitKey

DBAS	LEA	Bass(PC),A0
	MOVE	(A0),D0
	SUBQ	#2,D0
	CMPI	#-12,D0
	BLT	WaitKey
	MOVE	D0,(A0)
	BSR	SetBass
	LEA	DrawObjectNb(PC),A0
	MOVE	#OBass,(A0)
	BSR	DrawObject
	BRA	WaitKey

IBAS	LEA	Bass(PC),A0
	MOVE	(A0),D0
	ADDQ	#2,D0
	CMPI	#12,D0
	BGT	WaitKey
	MOVE	D0,(A0)
	BSR	SetBass
	LEA	DrawObjectNb(PC),A0
	MOVE	#OBass,(A0)
	BSR	DrawObject
	BRA	WaitKey

DTRE	LEA	Treble(PC),A0
	MOVE	(A0),D0
	SUBQ	#2,D0
	CMPI	#-12,D0
	BLT	WaitKey
	MOVE	D0,(A0)
	BSR	SetTreble
	LEA	DrawObjectNb(PC),A0
	MOVE	#OTreble,(A0)
	BSR	DrawObject
	BRA	WaitKey

ITRE	LEA	Treble(PC),A0
	MOVE	(A0),D0
	ADDQ	#2,D0
	CMPI	#12,D0
	BGT	WaitKey
	MOVE	D0,(A0)
	BSR	SetTreble
	LEA	DrawObjectNb(PC),A0
	MOVE	#OTreble,(A0)
	BSR	DrawObject
	BRA	WaitKey

TIME	BSR	Time0
	LEA	DrawObjectNb(PC),A0
	MOVE	#OMinutes,(A0)
	BSR	DrawTree
	BRA	WaitKey

SAVE	FILE_OPEN #CPU_MODName,#1
	MOVE	D0,D3
	BMI	WaitKey
	FILE_SEEK  #ProgHeader+2,D3,#0
	FILE_WRITE D3,#14,#MonoStereo
	FILE_CLOSE D3
	BRA	WaitKey

HELP	LEA	DrawObjectNb(PC),A0
	MOVE	#OSampleText1,(A0)
	BSR	DrawTree
.1	BSR	GetInputState
	TST	D0
	BEQ	.1
	BSR	GetKey
 ;31 samples ?
	BSR	GetSampleNumber
	CMPI	#31,D0
	BNE.S	.x
	LEA	DrawObjectNb(PC),A0
	MOVE	#OSampleText2,(A0)
	BSR	DrawTree
.2	BSR	GetInputState
	TST	D0
	BEQ	.2
	BSR	GetKey
.x	LEA	DrawObjectNb(PC),A0
	MOVE	#OCommandText,(A0)
	BSR	DrawTree
	BRA	WaitKey

x5x	LEA	ResetScreen(PC),A0
	BSR	PrintString0
	MOVE	VID_CR0Saved,VID_CR0
x4x	MOVE.B	#8,KBD_TD ;MOUSE ON
x3x	MOVE.B	KeyPrefsSaved,$484 ;CLICK ON
x2x	MOVE	#1,-(SP) ;Power OFF
	JSR	(A5)
	ADDQ	#2,SP
x1x	PROG_SUPERMODE SPSaved
x0x	PROG_END

	D_
SetScreen:	DC.B Esc,'f',Esc,'c',47,Esc,'b',50,Esc,'E',Esc,'w',0
ResetScreen:	DC.B Esc,'E',Esc,'c',48,Esc,'b',47,Esc,'e',0
	EVEN
SPSaved 	DS.L 1
KeyPrefsSaved	DS.B 1
	EVEN
VID_CR0Saved	DS.W 1
ObjectList	INCLUDE CPU_MODX.RSC
CPU_MODName	DC.B "CPU_MODX.TTP",0
	EVEN
CPU_MOD 	INCBIN "CPU_MOD.BIN"
	EVEN
	M_
Module:		;All the rest of the memory below HighTPA
 END
