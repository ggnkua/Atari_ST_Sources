******************
* Guitar ~ Tuner *
******************
; Sound input on left voice
; Adjust Gain with '+' and '-'

VideoW=320
VideoH=200
VideoPlane=4
VideoFrameSize=(VideoW*VideoH*VideoPlane)/8
SoundSampleFrequency=49170
SoundFrameRatePerSec=5
SoundLevelSimilarity=3 ;Similarity of the sound level
 ;within +-Level/(2^SoundLevelSimilarity)

;Note:
;On the main picture, I consider that:
;A4 = 440 Hz = La3

	TOS_APP
i0i	PROG_SUPERMODE	#0
	LEA	SP0(PC),A0
	MOVE.L	D0,(A0)
i1i	PEA	M_PPP_VIDEO(PC)
	PW	#0
	BSR	PPP_VIDEO
	ADDQ	#6,SP
i2i	PEA	M_PPP_SOUND(PC)
	PW	#0
	BSR	PPP_SOUND
	ADDQ	#6,SP
i3i	BSR.S	SaveMFP
	BRA	INIT

EXIT:
o3o	BSR.S	RestoreMFP
o2o	PW	#0
	BSR	PPP_SOUND
	ADDQ	#2,SP
o1o	PW	#0
	BSR	PPP_VIDEO
	ADDQ	#2,SP
o0o	PROG_SUPERMODE SP0(PC)
	BRA	FIN

SaveMFP:
	ORI	#$0700,SR
	LEA	MFP0(PC),A0
	MOVE	MFP_DDR,(A0)+
	MOVE	MFP_AER,(A0)+
	MOVE	MFP_IERA,(A0)+
	MOVE	MFP_IMRA,(A0)+
	MOVE.L	$100+15*4,(A0)+
	ANDI	#$FBFF,SR
	RTS

RestoreMFP:
	ORI	#$0700,SR
	LEA	MFP0(PC),A0
	MOVE	(A0)+,MFP_DDR
	MOVE	(A0)+,MFP_AER
	MOVE	(A0)+,MFP_IERA
	MOVE	(A0)+,MFP_IMRA
	MOVE.L	(A0)+,$100+15*4
	ANDI	#$FBFF,SR
	RTS

	INCLUDE DEC_FIP.S

WaitVBL:
	PEA	VideoTable(PC)
	PW	#0
	PW	#1
	BSR	PPP_VIDEO
	ADDQ	#8,SP
	RTS

InverseObject:
 ;Inverse the plane #2 of the object (Simplist maner ...)
 ;D0 -> Object
	MOVEA.L VideoAddress+4(PC),A0
	LEA	ObjectTable(PC),A1
	LEA	(A1,D0.W*8),A1
	MOVE	(A1)+,D0 ;X
	LSR	#4,D0
	LSL	#3,D0
	ADDA	D0,A0
	MOVE	(A1)+,D0 ;Y
	MULU	#160,D0
	ADDA	D0,A0
	ADDQ	#4,A0 ;plane #2, AO -> 1st word to inverse
	MOVE	(A1)+,D0 ;W
	BEQ.S	.x
	LSR	#4,D0
	MOVE	D0,D2
	SUBQ	#1,D2 ;Number of "columns"-1
	MOVE	(A1)+,D1 ;H
	BEQ.S	.x
	SUBQ	#1,D1 ;Number of lines-1
	MOVEA.L A0,A2
.nl	MOVE	D2,D0
.nc	NOT	(A0)
	ADDQ	#8,A0
	DBRA	D0,.nc
	ADDA	#160,A2
	MOVEA.L A2,A0
	DBRA	D1,.nl
.x	RTS

ConvertInteger32bToASCII:
 ;D0.L -> Integer32b
 ;D1   -> Mode
 ;	     b0= Signed mode
 ;	  b2-b1= Sign for positive number
 ;		 00: ''
 ;		 01: ' '
 ;		 10: '+' except for 0
 ;		 11: '+'
 ;	  b4-b3= Base
 ;		 00: Decimal
 ;		 01: Binary
 ;		 10: Hexadecimal
 ;A0   -> String of 34 bytes maxi
	MOVEM.L D3/A3,-(SP)
   ;Intern:
   ;D3=Base
   ;A3=Number table
	MOVE	D1,D2
	LSR	#3,D2
	ANDI	#%11,D2
	LEA	.BaseTab(PC),A1
	MOVE	(A1,D2*2),D3
	LEA	.NumberTab(PC),A3
.WorkPad=34
	LINK	A6,#-.WorkPad
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
	DIVU	D3,D1
	SWAP	D1
	MOVEQ	#0,D2
	MOVE	D1,D2
	SWAP	D2
	ADD.L	D2,D0
	CLR	D1
	SWAP	D1
.divL	DIVU	D3,D0
	SWAP	D0
	MOVE.B	(A3,D0),-(A6)
	CLR	D0
	SWAP	D0
	BNE.S	.divH
.copy	MOVE.B	(A6)+,(A0)+
	CMPA.L	A1,A6
	BNE	.copy
	CLR.B	(A0)
	UNLK	A6
	MOVEM.L (SP)+,D3/A3
	RTS
.BaseTab	DC.W 10,2,16,10
.NumberTab	DC.B '0','1','2','3','4','5','6','7'
		DC.B '8','9','A','B','C','D','E','F'

PrintCharacter:
 ;D0 -> Character
 ;PrintStringX ->
 ;PrintStringY ->
	MOVEM.L D3/A3,-(SP)
	ANDI	#$FF,D0
	LEA	NUM_8X16_FNT(PC),A3
	CMP	38(A3),D0
	BHI.S	.x
	SUB	36(A3),D0
	BLO.S	.x
	MOVEA.L 72(A3),A0
	ADDA.L	A3,A0
	LEA	(A0,D0*2),A0
	LEA	(A0,2),A1
	CMPM	(A0)+,(A1)+
	BEQ.S	.x
	MOVE	-(A0),D1
	LSR	#3,D1	;Offset in DATA (in byte)
	MOVEA.L 76(A3),A0
	ADDA.L	A3,A0
	ADDA	D1,A0		;A0 -> 1st graphic byte
	MOVE	80(A3),D0	;D0 -> Offset for next graphic byte
	MOVE	82(A3),D1	;D1 -> line number
	SUBQ	#1,D1
   ;Calculate destination address A1
	MOVE	PrintStringY(PC),D2
	MULU	#160,D2
	MOVE	PrintStringX(PC),D3
	LSR	#4,D3
	LSL	#3,D3
	ADD	D3,D2
	MOVE	PrintStringX(PC),D3
	ANDI	#$F,D3
	LSR	#3,D3
	ADD	D3,D2
	MOVEA.L VideoAddress+4(PC),A1
	ADDA	D2,A1
   ;Background color = %0101
   ;Foreground color = %0110
   ;So: Not(Data),Data,1,0
.nline	MOVE.B	(A0),D2
	ADDA	D0,A0
	MOVE	D2,D3
	NOT	D3
	MOVE.B	D3,(A1)
	MOVE.B	D2,(A1,2)
	ST	(A1,4)
	SF	(A1,6)
	ADDA	#160,A1
	DBRA	D1,.nline
 ;Increase X
	LEA	PrintStringX(PC),A0
	ADDQ	#8,(A0)
.x	MOVEM.L (SP)+,D3/A3
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

INIT:
InitVideo: ;On long word
	LEA	VideoAddress(PC),A0
	MOVE.L	(A0),D0
	ADDQ.L	#4-1,D0
	ANDI	#-4,D0
	MOVE.L	D0,(A0)+
	MOVE.L	(A0),D0
	ADDQ.L	#4-1,D0
	ANDI	#-4,D0
	MOVE.L	D0,(A0)+
	LEA	VideoTable(PC),A0
	MOVE.B	D0,41(A0)
	LSR.L	#8,D0
	MOVEP	D0,37(A0)
	PEA	(A0)
	PW	#-1
	PW	#1
	BSR	PPP_VIDEO
	ADDQ	#8,SP
InitMFP:
	ORI	#$0700,SR
	MOVEQ	#7,D0
	BCLR	D0,MFP_DDR+1
	BSET	D0,MFP_AER+1
	BSET	D0,MFP_IERA+1
	BSET	D0,MFP_IMRA+1
	LEA	RECORD(PC),A0
	MOVE.L	A0,$100+15*4
	ANDI	#$FBFF,SR
DrawImage:
  ;Unpack
	PW	#0
	PL	#VideoH*VideoPlane
	PL	#VideoW/8
	PL	VideoAddress(PC)
	PEA	G_TUNER_FIP+16+20+64(PC)
	BSR	DECOMPACTER_LIGNES
	ADDA	#18,SP
  ;Arrange
	PL	#VideoFrameSize
	PW	#VideoPlane
	PL	#VideoFrameSize/4
	PL	VideoAddress+4(PC)
	PL	VideoAddress(PC)
	BSR	EP16I
	ADDA	#18,SP
  ;Palette
   ;Convert palette
	LEA	VideoTable+48(PC),A0
	LEA	G_TUNER_FIP+16+20(PC),A1
	MOVEQ	#16-1,D2
.nc	MOVEQ	#0,D0
	MOVE.L	(A1)+,D1
	LSR.L	#5,D1
	BFINS	D1,D0{29:3} ;B
	LSR.L	#8,D1
	BFINS	D1,D0{25:3} ;G
	LSR.L	#8,D1
	BFINS	D1,D0{21:3} ;R
	MOVE	D0,(A0)+
	DBRA	D2,.nc
   ;Set palette
	PEA	VideoTable(PC)
	PW	#%100000
	PW	#1
	BSR	PPP_VIDEO
	ADDQ	#8,SP
InitSound:
	LEA	SoundTable(PC),A0
	MOVE.L	SoundAddress+8(PC),D0
	MOVE.B	D0,25(A0)
	LSR.L	#8,D0
	MOVEP	D0,21(A0)
	MOVE.L	SoundAddress+12(PC),D0
	MOVE.B	D0,31(A0)
	LSR.L	#8,D0
	MOVEP	D0,27(A0)
	PEA	(A0)
	PW	#%11101
	PW	#1
	BSR	PPP_SOUND
	ADDQ	#8,SP
	BRA.S	MAIN

IncreaseInputGain:
	LEA	SND_INPUT+1,A0
	MOVE.B	(A0),D0
	ADDQ	#1,D0
	ANDI	#$F,D0
	BEQ.S	.x
	MOVE	D0,D1
	LSL	#4,D0
	OR	D1,D0
	MOVE.B	D0,(A0)
	LEA	InputError(PC),A0
	LEA	InputErrorTable(PC),A1
	MOVE	(A1,D1*2),(A0)
.x	RTS

DecreaseInputGain:
	LEA	SND_INPUT+1,A0
	MOVE.B	(A0),D0
	ANDI	#$F,D0
	BEQ.S	.x
	SUBQ	#1,D0
	MOVE	D0,D1
	LSL	#4,D0
	OR	D1,D0
	MOVE.B	D0,(A0)
	LEA	InputError(PC),A0
	LEA	InputErrorTable(PC),A1
	MOVE	(A1,D1*2),(A0)
.x	RTS

MAIN:	LEA	SoundFrameFull(PC),A0
	SF	(A0)
.wsff	TST.B	(A0)
	BEQ	.wsff
* A0= Sample
* D0= Level
* A1= Positive alternance
* D1= Level of the positive alternance
* A2= Maxima positive alternance
* D2= Level of the maxima positive alternance
* A3= Period sum (*4)
* D3= Period count
* D6= Input error
* D7= Sample count
* Period= (A3/4)/D3
* Frequency= SoundSampleFrequency/Period
	MOVEA.L SoundAddress(PC),A0
	MOVEQ	#0,D0
	MOVEA.L A0,A1
	MOVEQ	#0,D1
	MOVEA.L A0,A2
	MOVEQ	#0,D2
	SUBA.L	A3,A3
	MOVEQ	#0,D3
	MOVEQ	#0,D6
	MOVE	InputError(PC),D6
	MOVE.L	SoundAddress+4(PC),D7
	SUB.L	A0,D7
	LSR.L	#2,D7
; Search 1st Period
.SearchNegativeSample
	SUBQ	#1,D7
	BEQ.S	.CalcFrequency
	MOVE	(A0),D0
	ADDQ	#4,A0
	EXT.L	D0
	SUB.L	D6,D0
	BPL	.SearchNegativeSample
.SearchPositiveSample
	SUBQ	#1,D7
	BEQ.S	.CalcFrequency
	MOVE	(A0),D0
	ADDQ	#4,A0
	EXT.L	D0
	SUB.L	D6,D0
	BMI	.SearchPositiveSample
	LEA	(A0,-4),A1
	MOVE.L	D0,D1
.SearchTopAlternance
	SUBQ	#1,D7
	BEQ.S	.CalcFrequency
	MOVE	(A0),D0
	ADDQ	#4,A0
	EXT.L	D0
	SUB.L	D6,D0
	BMI.S	.Maxima
	CMP.L	D1,D0
	BLS	.SearchTopAlternance
	MOVE.L	D0,D1
	BRA	.SearchTopAlternance
.Maxima MOVE.L	D2,D4
	SUB.L	D1,D4
	BPL.S	.Tolerance
	NEG.L	D4
.Tolerance
	MOVE.L	D2,D5
	LSR.L	#SoundLevelSimilarity,D5
	CMP.L	D5,D4
	BLS.S	.NewPeriod
	CMP.L	D2,D1
	BLO	.SearchPositiveSample
	MOVEA.L A1,A2
	MOVE.L	D1,D2
	BRA	.SearchPositiveSample
.NewPeriod
	ADDA.L	A1,A3
	SUBA.L	A2,A3
	ADDQ	#1,D3
	MOVEA.L A1,A2
	MOVE.L	D1,D2
	BRA	.SearchPositiveSample
.CalcFrequency
	TST	D3
	BEQ.S	.LowFr
* Period= (A3/4)/D3
* Frequency= SoundSampleFrequency/Period
	MOVE.L	A3,D1
	LSR.L	#2,D1
	SWAP	D1 ;I16.F16
	DIVU.L	D3,D1
	LSR.L	#8,D1 ;I24.F8
	LSR.L	#2,D1 ;I26.F6
	MOVE.L	#SoundSampleFrequency<<16,D0 ;I16.F16
	DIVU.L	D1,D0 ;I22.F10
	CMPI.L	#20<<10,D0 ; 0 Hz if < 20 Hz
	BHS.S	.Frequency
.LowFr	MOVEQ	#0,D0
.Frequency
	LEA	Frequency(PC),A0
	MOVE.L	D0,(A0)
 ;print frequency
  ;I22
	LSR.L	#8,D0
	LSR.L	#2,D0
	MOVEQ	#0,D1
	LEA	FrequencyString(PC),A3
	MOVEA.L A3,A0
	BSR	ConvertInteger32bToASCII
	LEA	PrintMode(PC),A0
	MOVE	#%011100,(A0)
	LEA	PrintCharacterCount(PC),A0
	MOVE	#5,(A0)
	LEA	PrintStringAddress(PC),A0
	MOVE.L	A3,(A0)
	LEA	PrintStringX(PC),A0
	MOVE	#128,(A0)
	LEA	PrintStringY(PC),A0
	MOVE	#155,(A0)
	BSR	WaitVBL
	BSR	PrintString
  ;F10
	MOVE.L	Frequency(PC),D0
	LSL	#6,D0 ;(I0).F16
	MULU	#10,D0 ;I16.F16
	SWAP	D0
	ADDI	#'0',D0
	MOVE.B	D0,(A3)
	CLR.B	(A3,1)
	LEA	PrintMode(PC),A0
	MOVE	#0,(A0)
	LEA	PrintCharacterCount(PC),A0
	MOVE	#1,(A0)
	LEA	PrintStringAddress(PC),A0
	MOVE.L	A3,(A0)
	LEA	PrintStringX(PC),A0
	MOVE	#176,(A0)
	LEA	PrintStringY(PC),A0
	MOVE	#155,(A0)
	BSR	PrintString
 ;draw indicator
	MOVEQ	#0,D0 ;object
	MOVE.L	Frequency(PC),D1
	BEQ.S	.DrawIndicator
	MOVEQ	#7,D0
	LEA	FrequencyTable(PC),A0
	MOVE	String(PC),D2
	SUBQ	#1,D2
	LSL	#5,D2 ;8L = x32
	ADDA	D2,A0
	MOVEQ	#8-1,D2 ;8L
.SearchIndicator
	CMP.L	(A0)+,D1
	BLO.S	.DrawIndicator
	ADDQ	#1,D0
	DBRA	D2,.SearchIndicator
.DrawIndicator
	LEA	Indicator(PC),A3
	CMP	(A3),D0
	BEQ.S	KeyTest
	MOVE	D0,D3
	MOVE	(A3),D0
	BSR	InverseObject
	MOVE	D3,(A3)
	MOVE	D3,D0
	BSR	InverseObject
KeyTest CONS_GINSTATE #2
	TST.B	D0
	BEQ	MAIN
Key	CONS_IN #2
	CMPI.B	#27,D0
	BEQ	EXIT
	PEA	MAIN(PC)
	CMPI.B	#'+',D0
	BEQ	IncreaseInputGain
	CMPI.B	#'-',D0
	BEQ	DecreaseInputGain
	SWAP	D0
	CMPI.B	#$3B,D0 ;F1
	BLO.S	.x
	CMPI.B	#$40,D0 ;F6
	BLS.S	FunctionKey
.x	RTS
FunctionKey:
	ANDI	#$FF,D0
	SUBI	#$3B-1,D0 ;F1
	LEA	String(PC),A3
	CMP	(A3),D0
	BEQ.S	.x
	MOVE	D0,D3
	MOVE	(A3),D0
	BSR	InverseObject
	MOVE	D3,(A3)
	MOVE	D3,D0
	BSR	InverseObject
.x	RTS

RECORD: MOVE.L	A6,-(SP)
	LEA	SoundFrameFull(PC),A6
	TST.B	(A6)
	BNE.S	.overrun
	ST	(A6)
	LEA	SoundAddress+0+1(PC),A6 ;YES +0 !!! --> LOOP mode
	MOVE.B	(A6)+,SND_BH+1
	MOVE.B	(A6)+,SND_BM+1
	MOVE.B	(A6)+,SND_BL+1
	ADDQ	#1,A6
	MOVE.B	(A6)+,SND_EH+1
	MOVE.B	(A6)+,SND_EM+1
	MOVE.B	(A6)+,SND_EL+1
 ;Swapping
	MOVEM.L D0-D3,-(SP)
	LEA	SoundAddress(PC),A6
	MOVEM.L (A6),D0-D3
	EXG.L	D0,D2
	EXG.L	D1,D3
	MOVEM.L D0-D3,(A6)
	MOVEM.L (SP)+,D0-D3/A6
.x	BCLR	#7,MFP_ISRA+1
	RTE
.overrun	MOVE	#$F00,VID_CR0
		MOVEA.L (SP)+,A6
		BRA.S	.x

	D_
PPP_VIDEO	INCBIN	VIDEO.PPP
PPP_VIDEO2	INCBIN	VIDEO2.PPP
PPP_SOUND	INCBIN	SOUND.PPP
G_TUNER_FIP	INCBIN	G~TUNER.FIP
NUM_8X16_FNT	INCBIN	NUM_8X16.FNT

VideoTable:
.PPP_VID_SYNC	DC.W	0
.PPP_VID_RES1	DC.W	0
.PPP_VID_RES2	DC.W	0
.PPP_VID_RES12	DC.W	-1
.PPP_VID_CO	DC.W	$186
.PPP_VID_MODE	DC.W	5
.PPP_VID_HHT	DC.W	$017
.PPP_VID_HBB	DC.W	$012
.PPP_VID_HBE	DC.W	$001
.PPP_VID_HDB	DC.W	$20D
.PPP_VID_HDE	DC.W	$00C
.PPP_VID_HSS	DC.W	$011
.PPP_VID_VFT	DC.W	$419
.PPP_VID_VBB	DC.W	$3AF
.PPP_VID_VBE	DC.W	$08F
.PPP_VID_VDB	DC.W	$08F
.PPP_VID_VDE	DC.W	$3AF
.PPP_VID_VSS	DC.W	$415
.PPP_VID_BH	DC.W	0
.PPP_VID_BM	DC.W	0
.PPP_VID_BL	DC.W	0
.PPP_VID_HJ	DC.W	0
.PPP_VID_VJ	DC.W	0
.PPP_VID_LW	DC.W	$50
.PPP_VID_CR	DS.W	16

SoundTable:
.PPP_SND_CR		DC.W	$02B0	;Record on, loop mode, I7
.PPP_SND_MODE1		DC.W	$0000
.PPP_SND_MODE2		DC.W	$0001
.PPP_SND_FREQ		DC.W	$0001
.PPP_SND_BHR		DC.W	0
.PPP_SND_BMR		DC.W	0
.PPP_SND_BLR		DC.W	0
.PPP_SND_EHR		DC.W	0
.PPP_SND_EMR		DC.W	0
.PPP_SND_ELR		DC.W	0
.PPP_SND_BHW		DC.W	0	;To init (+20)
.PPP_SND_BMW		DC.W	0	;To init
.PPP_SND_BLW		DC.W	0	;To init
.PPP_SND_EHW		DC.W	0	;To init
.PPP_SND_EMW		DC.W	0	;To init
.PPP_SND_ELW		DC.W	0	;To init
.PPP_SND_XBARIN 	DC.W	$8000
.PPP_SND_XBAROUT	DC.W	$000F
.PPP_SND_INPUT		DC.W	$0000	;00LR
.PPP_SND_OUTPUT 	DC.W	$0000	;-LR-

VideoAddress	DC.L	VideoFrame0
		DC.L	VideoFrame1	;No swapping here ...
SoundFrameFull	DC.B	-1,0
SoundAddress	DC.L	SoundFrame0
		DC.L	SoundFrame0+SoundSampleFrequency*4/SoundFrameRatePerSec
		DC.L	SoundFrame1
		DC.L	SoundFrame1+SoundSampleFrequency*4/SoundFrameRatePerSec

InputError	DC.W $00B4 ;It's the error for the current SND_INPUT
InputErrorTable DC.W $00B4,$00E0,$0116,$0153,$0177,$01D0,$023C,$02B6
		DC.W $0306,$03BC,$0490,$0586,$0631,$0790,$0920,$0ADE

String		DC.W	5	;1-6: Object#
Indicator	DC.W	0	;7-15: Object# (0:None)

FrequencyTable: ;I22.F10
	; 1/2T=  2^(1/12)= 1.059463
	;1/32T= 2^(1/192)= 1.003616
	;	-7/32T,-5/32T,-3/32T,-1/32T,+1/32T,+3/32T,+5/32T,+7/32T
.ST1	DC.L	329116,331500,333903,336322,338759,341214,343687,346177
.ST2	DC.L	246558,248345,250144,251957,253783,255622,257474,259340
.ST3	DC.L	195693,197111,198540,199978,201428,202887,204357,205838
.ST4	DC.L	146604,147667,148737,149815,150900,151994,153095,154204
.ST5	DC.L	109829,110825,111427,112234,113047,113867,114692,115523
.ST6	DC.L	082279,082875,083476,084081,084690,085304,085922,086544

ObjectTable:   ;  X   Y   W   H
.nul	DC.W	000,000,000,000
.F1	DC.W	000,046,320,016
.F2	DC.W	000,062,320,016
.F3	DC.W	000,078,320,016
.F4	DC.W	000,094,320,016
.F5	DC.W	000,110,320,016
.F6	DC.W	000,126,320,016
.BASS	DC.W	000,178,048,022
._3_16T DC.W	048,178,032,022
._1_8T	DC.W	080,178,032,022
._1_16T DC.W	112,178,032,022
.OK	DC.W	144,178,032,022
.1_16T	DC.W	176,178,032,022
.1_8T	DC.W	208,178,032,022
.3_16T	DC.W	240,178,032,022
.TREBLE DC.W	272,178,048,022

	M_
SP0		DS.L 1
MFP0		DS.W 6
PrintMode		DS.W 1
PrintStringX		DS.W 1
PrintStringY		DS.W 1
PrintStringAddress	DS.L 1
PrintStringAddress2	DS.L 1
PrintStringLength	DS.W 1
PrintOutput		DS.W 1
PrintCharacterCount	DS.W 1
PrintCharacterCount2	DS.W 1
PrintAnteSPCount	DS.W 1
PrintPastSPCount	DS.W 1
Frequency	DS.L	1 ;I22.F10
FrequencyString DS.B	34
M_PPP_VIDEO	DS.B	2*1024
M_PPP_SOUND	DS.B	1*1024
VideoFrame0	DS.B	VideoFrameSize
VideoFrame1	DS.B	VideoFrameSize
		DS.W	1 ;Necessary for VIDEO BASE on long word boundary
SoundFrame0	DS.L	SoundSampleFrequency/SoundFrameRatePerSec
SoundFrame1	DS.L	SoundSampleFrequency/SoundFrameRatePerSec
	END
