;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~ Shell *.TTP type for the routine CPU_MOD.BIN ~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	OUTPUT	CPU_MODX.TTP

;-------------------------------------------------------------------------------
;TOS-Type call:

;Error.B = CPU_MOD( Cmd.W ,8_16.W , Mo_St.W , Freq.W , MOD_Ad.L , MOD_Ln.L )
;D0		    SP+4	    SP+8      SP+10    SP+12	  SP+16

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

;8_16=	0:-
;	1:8 bits/16 bits					[/]

;Mo_St= 0:-
;	1:Mono/Stereo						[*]

;Freq=	0:-
;	1: 8195 Hz						[7]
;	2: 9834 Hz						[6]
;	3:12292 Hz						[5]
;	4:16390 Hz						[4]
;	5:19668 Hz						[3]
;	6:24585 Hz						[2]
;	7:32780 Hz						[1]
;	8:49170 Hz						[0]

;Other commands:
;	Decrease Volume 					[F1]
;	Increase Volume 					[F2]
;	Reset Timer						[T]
;	Save Preferences					[S]
;	Show Sample Infos					(Help]

;-------------------------------------------------------------------------------

ProgHeader=28

ONull		=0
OModuleText	=1
OCommandText	=2
OSampleText1	=3
OSampleText2	=4
OBottomLine	=5
OFileName	=6
OFileExtension	=7
OFileLength	=8
OModuleName	=9
OCurrentPosition=10
OPositionCount	=11
OCurrentPattern =12
OPatternCount	=13
OMinutes	=14
OSeconds	=15
OPlay		=16
OFastForward	=17
ORepeat 	=18
O_8_16bits	=19
OMonoStereo	=20
OFrequency	=21
OVolumeInt	=22
OVolumeFrc	=23
OInversionV0V1	=24
OInversionV2V3	=25

ProgramStart	BRA	e0e

	INCLUDE TEXT+.S

;Addresses of some usefull variables in CPU_MOD
; CurrentPosition = (CPU_MOD_BSS+142).W 			   = 0 to 127
; PositionCount   = ((CPU_MOD_BSS+2).L-2).B -1			   = 0 to 127
; CurrentPattern  = ((CPU_MOD_BSS+2).L+(CPU_MOD_BSS+142).W).B	   = 0 to 63
; PatternCount	  = ((CPU_MOD_BSS+10).L-(CPU_MOD_BSS+6).L)/1024 -1 = 0 to 63
; SampleNumber	  = (CPU_MOD_BSS+0).W				   = 15 or 31
; Play		  = BTST #0,SND_CR+1

GetCurrentPosition:	;(CPU_MOD_BSS+142).W
	MOVEQ	#0,D0
	MOVE	CPU_MOD_BSS+142(PC),D0
	RTS

GetPositionCount:	;((CPU_MOD_BSS+2).L-2).B -1
	MOVEQ	#0,D0
	MOVEA.L CPU_MOD_BSS+2(PC),A0
	MOVE.B	-2(A0),D0
	SUBQ	#1,D0
	RTS

GetCurrentPattern:	;((CPU_MOD_BSS+2).L+(CPU_MOD_BSS+142).W).B
	MOVEQ	#0,D0
	MOVEA.L CPU_MOD_BSS+2(PC),A0
	ADDA	CPU_MOD_BSS+142(PC),A0
	MOVE.B	(A0),D0
	RTS

GetPatternCount:	;((CPU_MOD_BSS+10).L-(CPU_MOD_BSS+6).L)/1024 -1
	MOVE.L	CPU_MOD_BSS+10(PC),D0
	SUB.L	CPU_MOD_BSS+6(PC),D0
	LSR.L	#8,D0
	LSR.L	#2,D0
	SUBQ	#1,D0
	RTS

GetSampleNumber:	;(CPU_MOD_BSS+0).W
	MOVEQ	#0,D0
	MOVE	CPU_MOD_BSS(PC),D0
	RTS

GetPlay:
	BTST	#0,SND_CR+1
	SNE	D0
	RTS

e0e	LEA	Module,A6		;A6 = Module
	LEA	CPU_MOD_BSS(PC),A5	;A5 = "Callable" CPU_MOD
	MOVE	#CPU_MODEnd-CPU_MODStart,D0
	SUBQ	#4,D0 ;Cause to "0000" at the end of CPU_MOD.BIN
	ADDQ	#1,D0
	ANDI.B	#$FE,D0 ;EVEN
	SUBA	D0,A5
	MOVEA.L A5,A0
	LEA	CPU_MODStart(PC),A1
	LSR	#1,D0
	SUBQ	#1,D0
.cp	MOVE	(A1)+,(A0)+
	DBRA	D0,.cp
	MOVEA.L 4(SP),A0
	MOVE.L	4(A0),D7
	SUB.L	A6,D7		;D7 = Module length maxi
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
	MOVE	_8_16bits(PC),-(SP)
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
	BRA	TONE

SetVolume:
	MOVE.L	VolumeInt(PC),D0
	ASR.L	#8,D0
	ASR.L	#7,D0
	DIVS	#%11,D0 ;1.5 !
	NEG	D0
	ANDI	#%1111,D0
	MOVE	D0,D1
	LSL	#4,D0
	LSL	#8,D1
	OR	D1,D0
	LEA	SND_OUTPUT,A0
	MOVE	(A0),D1
	ANDI	#$F00F,D1
	OR	D1,D0
	MOVE	D0,(A0)
	RTS

	INCLUDE	M4.S

TONE:	MOVE	SND_OUTPUT,VolumeSaved
	BSR	SetVolume
	BSR	TestM4
	MOVE.B	MODX4V_Ind(PC),D0
	BEQ.S	e3e
	PW	InversionV0V1(PC)
	PW	#2
	BSR	MODX4V
	ADDQ	#4,SP
	PW	InversionV2V3(PC)
	PW	#3
	BSR	MODX4V
	ADDQ	#4,SP
e3e	LEA	$484,A0 ;CLICK OFF
	MOVE.B	(A0),KeyPrefsSaved
	ANDI.B	#%11111000,(A0)
e5e	LEA	VID_CR0,A0
	MOVE	(A0),VID_CR0Saved
	CLR	(A0)
	LEA	SetScreen(PC),A0
	BSR	PrintString0
	BRA	RscInit

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

RscInversion:
	MOVE.B	MODX4V_Ind(PC),D0
	BNE.S	.x
	LEA	ObjectList(PC),A0
	MOVEQ	#OInversionV0V1,D0
	MOVEQ	#ObjectArrayLength,D1
	MULU	D1,D0
	MOVE	#ONull,ObjectType(A0,D0)
	MOVEQ	#OInversionV2V3,D0
	MULU	D1,D0
	MOVE	#ONull,ObjectType(A0,D0)
.x	RTS

RscInit:
	MOVEQ	#OInversionV2V3,D0
	BSR	RscCenterAndInit
	BSR	RscModuleText
	BSR	RscSampleText
	BSR	RscInversion

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
	BSR	ChangeInversion
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
	CMPI.B	#'/',D0
	BEQ	_816
	CMPI.B	#'*',D0
	BEQ	MOST
	CMPI.B	#'0',D0
	BLO.S	.1
	CMPI.B	#'7',D0
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

_816	LEA	_8_16bits(PC),A0
	NOT	(A0)
	ADDQ	#2,(A0)
	MOVEQ	#1,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	BSR	HARD
	LEA	DrawObjectNb(PC),A0
	MOVE	#O_8_16bits,(A0)
	BSR	DrawObject
	BRA	WaitKey

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
	MOVE.B	MODX4V_Ind(PC),D0
	BEQ	WaitKey
	MOVE	MonoStereo(PC),D0
	BEQ	WaitKey
 ;Toujours ces valeurs par d‚fauts ...
	PW	InversionV0V1(PC)
	PW	#2
	BSR	MODX4V
	ADDQ	#4,SP
	PW	InversionV2V3(PC)
	PW	#3
	BSR	MODX4V
	ADDQ	#4,SP
	BRA	WaitKey

FREQ	ANDI	#$FF,D0
	SUBI	#'0',D0
	MOVEQ	#8,D2
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

WriteDouble:
	MOVE	D0,D1
	ADDI.L	#$0000FFFF,D0 ; 0.999 dB
	SWAP	D0
	MOVE	D0,(A0)+
	LSR	#1,D1
	MOVE	D1,(A0)
	RTS

DVOL	LEA	VolumeInt(PC),A0
	MOVE.L	(A0),D0
	CMPI.L	#$FFE98000,D0 ; -22.5 dB
	BEQ	WaitKey
	SUBI.L	#$00018000,D0 ; 1.5 dB
	MOVE.L	D0,(A0)+
	BSR	WriteDouble
	BSR	SetVolume
	LEA	DrawObjectNb(PC),A0
	MOVE	#OVolumeInt,(A0)
	BSR	DrawTree
	BRA	WaitKey

IVOL	LEA	VolumeInt(PC),A0
	MOVE.L	(A0),D0
	BEQ	WaitKey
	ADDI.L	#$00018000,D0
	MOVE.L	D0,(A0)+
	BSR	WriteDouble
	BSR	SetVolume
	LEA	DrawObjectNb(PC),A0
	MOVE	#OVolumeInt,(A0)
	BSR	DrawTree
	BRA	WaitKey

ChangeInversion:
	MOVE.B	MODX4V_Ind(PC),D0
	BEQ.S	.x
 ;Seulement si on se trouve en st‚r‚o
	MOVE   MonoStereo(PC),D0
	BEQ.S  .x
	DC.W	$A000
	MOVE	-596(A0),D0 ;MOUSE_BT
	BEQ.S	.x
	CMPI	#3,D0
	BHS.S	.x
	SUBQ	#1,D0
	LEA	InversionV0V1(PC),A1
	LEA	(A1,D0*2),A1
	MOVE	-602(A0),D1 ;G_CURX
	SWAP	D1
	CLR	D1
	DIVU	-12(A0),D1 ;V_REZ_HZ
	LSR	#1,D1
	MOVE	D1,(A1)
	PW	D1
	ADDQ	#2,D0 ;pour code 2 ou 3
	PW	D0
	BSR	MODX4V
	ADDQ	#4,SP
	LEA	DrawObjectNb(PC),A0
	MOVE	#OInversionV0V1,(A0)
	BSR	DrawTree
	BRA	ChangeInversion
.x	RTS

TIME	BSR	Time0
	LEA	DrawObjectNb(PC),A0
	MOVE	#OMinutes,(A0)
	BSR	DrawTree
	BRA	WaitKey

SAVE	FILE_OPEN #CPU_MODName,#1
	MOVE	D0,D3
	BMI	WaitKey
	FILE_SEEK  #StartSave-ProgramStart+ProgHeader,D3,#0
	FILE_WRITE D3,#EndSave-StartSave,#StartSave
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
x3x	MOVE.B	KeyPrefsSaved,$484 ;CLICK ON
x2x	MOVE	VolumeSaved,SND_OUTPUT
	MOVE	#1,-(SP) ;Power OFF
	JSR	(A5)
	ADDQ	#2,SP
x1x	PROG_SUPERMODE SPSaved
x0x	PROG_END

	D_
SPSaved 	DS.L 1
VolumeSaved	DS.W 1
MODX4V_Ind	DS.B 1
KeyPrefsSaved	DS.B 1
VID_CR0Saved	DS.W 1
CPU_MODStart	INCBIN "CPU_MOD.BIN"
CPU_MODEnd
CPU_MODName	DC.B "CPU_MODX.TTP",0
	EVEN
;Preferences saved here in the file CPU_MODX.TTP
;with the command "S"
StartSave
_8_16bits	DC.W 0 ;0 or 1
MonoStereo	DC.W 0 ;0 or 1
Frequency	DC.W 0 ;0: 8195 1: 9834 2:12292 3:16390 Hz
		       ;4:19668 5:24585 6:32780 7:49170 Hz
VolumeInt	DC.W 0 ;0  dB
VolumeFrc	DC.W 0 ;.0 dB
VolumeInt2	DC.W 0 ;Corrig‚ pour l'affichage
VolumeFrc2	DC.W 0 ;Corrig‚ pour l'affichage
InversionV0V1	DC.W 0 ;0 %
InversionV2V3	DC.W 0 ;0 %
EndSave
ObjectList	INCLUDE CPU_MODX.RSC

	M_
		DS.B 8000  ;CPU_MOD.BIN (TEXT+DATA)
CPU_MOD_BSS	DS.B 80000 ;CPU_MOD.BIN (BSS)
Module		;All the rest of the memory below HighTPA
 END
