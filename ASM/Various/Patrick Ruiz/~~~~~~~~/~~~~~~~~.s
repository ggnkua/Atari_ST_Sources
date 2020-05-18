**************************
* Real Time Oscilloscope *
**************************
; Input Mono (On left voice)
; Adjust Gain with '+' and '-'
; Adjust Zoom on X with Left and Right Arrows (Ratios of 1,2,4,8)
; Adjust Zoom on Y with Up and Down Arrows (Ratios of 1,2,4,8,16,32,64,128,256)
; Freeze screen with 'F' and ...
;	... save sample with 'S'
;	... unfreeze with any other key

VideoW=344
VideoH=256
VideoPlaneNumber=16
SoundSampleFrequency=49170
SoundFrameExplorationDepth=512
SoundFrameRatePerSec=15	;No more because zoom on X could be equal to 8
 ;and we must verify this condition:
 ;SoundSampleFrequency/SoundFrameRatePerSec >= VideoW*ZoomX+SoundFrameExplorationDepth
SoundLevelSimilarity=3	;Similarity of the sound level
 ;within +-Level/(2^SoundLevelSimilarity)
BackGroundColor=0		;Black
AxisColor=%1000010000110000	;Grey
SampleColor=%1110011111100000	;Yellow

	TOS_APP
i0i	PROG_SUPERMODE	#0
	LEA	SP0(PC),A0
	MOVE.L	D0,(A0)
i1i	PEA	M_PPP_VIDEO(PC)
	PW	#0
	BSR	PPP_VIDEO
	ADDQ	#6,SP
	PW	#0
	PW	#0
	PW	#0
	PW	#0
	PW	#0
	PW	#0
 ;LONG WORD
	LEA	VideoAddress(PC),A0
	MOVE.L	(A0),D0
	ADDQ.L	#4-1,D0
	ANDI	#-4,D0
	MOVE.L	D0,(A0)+
	MOVE.L	(A0),D0
	ADDQ.L	#4-1,D0
	ANDI	#-4,D0
	MOVE.L	D0,(A0)
	PL	VideoAddress+4(PC)
	PW	#VideoPlaneNumber
	PW	#VideoH
	PW	#VideoW
	PEA	M_PPP_VIDEO2(PC)
	PW	#0
	BSR	PPP_VIDEO2
	ADDA	#28,SP
i2i	PEA	M_PPP_SOUND(PC)
	PW	#0
	BSR	PPP_SOUND
	ADDQ	#6,SP
i3i	BSR.S	SaveMFP
	BRA.S	INIT

EXIT
o3o	BSR.S	RestoreMFP
o2o	PW	#0
	BSR	PPP_SOUND
	ADDQ	#2,SP
o1o	PW	#0
	BSR	PPP_VIDEO2
	ADDQ	#2,SP
	PW	#0
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

INIT:
InitVideo:
	LEA	VideoTable(PC),A0
	MOVE.L	VideoAddress(PC),D0
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
InitSound:
	LEA	SoundTable(PC),A0
	MOVE.L	SoundAddress(PC),D0
	MOVE.B	D0,25(A0)
	LSR.L	#8,D0
	MOVEP	D0,21(A0)
	MOVE.L	SoundAddress+4(PC),D0
	MOVE.B	D0,31(A0)
	LSR.L	#8,D0
	MOVEP	D0,27(A0)
	PEA	(A0)
	PW	#%11101
	PW	#1
	BSR	PPP_SOUND
	ADDQ	#8,SP
Inittim_cnt0:
	LEA	tim_cnt0(PC),A0
	MOVE.L	tim_cnt,(A0)
	BRA	MAIN

DrawAxis:
	PW	#AxisColor
	PW	#3
	BSR	PPP_VIDEO2
	ADDQ	#4,SP
	MOVEA.L	PointTable+4(PC),A0
	MOVE	#VideoW-1,D0 ;X
	MOVE	#127,D1 ;Y
.1	MOVE	D0,(A0)+
	MOVE	D1,(A0)+
	DBRA	D0,.1
	PW	#VideoW
	PL	PointTable+4(PC)
	PW	#5
	BSR	PPP_VIDEO2
	ADDQ	#8,SP
	RTS

DrawSample:
	PW	#SampleColor
	PW	#3
	BSR	PPP_VIDEO2
	ADDQ	#4,SP
.searchperiod:
	;Search a regular positive alternance for "synchronizing" the sound
	MOVEA.L	SoundAddress+8(PC),A0 ;Regular positive alternance
	MOVEQ	#0,D0 ;Level of the regular positive alternance
	MOVEA.L	A0,A1 ;Positive alternance
	MOVEQ	#0,D1 ;Level of the positive alternance
	MOVEA.L	A0,A2 ;Sample
	MOVEQ	#0,D2 ;Level
	MOVEQ	#0,D3
	MOVE	InputError(PC),D3
	MOVE	#SoundFrameExplorationDepth,D4
.s1neg	MOVE	(A2),D2
	ADDQ	#4,A2
	SUBQ	#1,D4
	BEQ.S	.draw
	EXT.L	D2
	SUB.L	D3,D2
	BPL	.s1neg
.spos	MOVE	(A2),D2
	ADDQ	#4,A2
	SUBQ	#1,D4
	BEQ.S	.draw
	EXT.L	D2
	SUB.L	D3,D2
	BMI	.spos
	LEA	(A2,-4),A1
	MOVE.L	D2,D1
.smax	MOVE	(A2),D2
	ADDQ	#4,A2
	SUBQ	#1,D4
	BEQ.S	.draw
	EXT.L	D2
	SUB.L	D3,D2
	BMI.S	.reg
	CMP.L	D1,D2
	BLS	.smax
	MOVE.L	D2,D1
	BRA	.smax
.reg	MOVE.L	D0,D5
	SUB.L	D1,D5
	BPL.S	.tol
	NEG.L	D5
.tol	MOVE.L	D0,D6
	LSR.L	#SoundLevelSimilarity,D6
	CMP.L	D6,D5
	BLS.S	.draw
	CMP.L	D0,D1
	BLO	.spos
	MOVEA.L	A1,A0
	MOVE.L	D1,D0
	BRA	.spos

.draw	MOVEA.L	A0,A1
	MOVEA.L	PointTable+4(PC),A0
	MOVEQ	#0,D0 ;X
	MOVEQ	#0,D1 ;Y
	MOVEQ	#0,D2
	MOVE	InputError(PC),D2
	MOVEQ	#127,D3 ;Horizontal line
	MOVE	#VideoW-1,D4 ;X maxi
	MOVE	ZoomX(PC),D5
	LSL	#2,D5
	MOVE	ZoomY(PC),D6
	BFFFO	D6{16:16},D6
	SUBI	#31-8,D6
.nspl	MOVE	D0,(A0)+
	ADDQ	#1,D0
	MOVE	(A1),D1
	ADDA	D5,A1
	EXT.L	D1
	SUB.L	D2,D1
	NEG.L	D1
	;Round to nearest
		MOVEQ	#0,D7
		BSET	D6,D7
		LSR	#1,D7
		ADD.L	D7,D1
	ASR.L	D6,D1
	ADD.L	D3,D1
	MOVE	D1,(A0)+
	CMP	D4,D0
	BLO	.nspl
	PW	#VideoW
	PL	PointTable+4(PC)
	PW	#5
	BSR	PPP_VIDEO2
	ADDQ	#8,SP
	RTS

EraseSample:
	PW	#BackGroundColor
	PW	#3
	BSR	PPP_VIDEO2
	ADDQ	#4,SP
	PW	#VideoW
	PL	PointTable+4(PC)
	PW	#5
	BSR	PPP_VIDEO2
	ADDQ	#8,SP
	RTS

NewFrames:
	LEA	SoundFrameFull(PC),A0
	SF	(A0)
.video	LEA	VideoAddress(PC),A0
	MOVEM.L (A0),D0-D1
	EXG.L	D0,D1
	MOVEM.L D0-D1,(A0)
	PL	D1
	PW	#1
	BSR	PPP_VIDEO2
	ADDQ	#6,SP
	LEA	VideoTable(PC),A0
	MOVE.L	VideoAddress(PC),D0
	MOVE.B	D0,41(A0)
	LSR.L	#8,D0
	MOVEP	D0,37(A0)
	PEA	(A0)
	PW	#%1000
	PW	#1
	BSR	PPP_VIDEO
	ADDQ	#8,SP
.sound	LEA	SoundAddress(PC),A0
	MOVEM.L (A0),D0-D3
	EXG.L	D0,D2
	EXG.L	D1,D3
	MOVEM.L D0-D3,(A0)
	LEA	PointTable(PC),A0
	MOVEM.L	(A0),D0-D1
	EXG.L	D0,D1
	MOVEM.L	D0-D1,(A0)
.1	MOVE.B	SoundFrameFull(PC),D0
	BEQ	.1
	RTS

CalcFPS: ;FramePerSec ?
	LEA	FPS(PC),A0
	ADDQ	#1,(A0)
	MOVE.L	tim_cnt,D0
	LEA	tim_cnt0(PC),A0
	SUB.L	(A0),D0
	CMPI.L	#200,D0
	BLO.S	.x
	MOVE.L	tim_cnt,(A0)
	LEA	FramePerSec(PC),A0
	LEA	FPS(PC),A1
	MOVE	(A1),D0
	CLR	(A1)
	CMP	(A0),D0
	BHS.S	.x
	MOVE	D0,(A0)
.x	RTS

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

IncreaseZoomX:
	LEA	ZoomX(PC),A0
	MOVE	(A0),D0
	CMPI	#1,D0
	BEQ.S	.x
	LSR	#1,D0
	MOVE	D0,(A0)
.x	RTS

DecreaseZoomX:
	LEA	ZoomX(PC),A0
	MOVE	(A0),D0
	CMPI	#8,D0
	BEQ.S	.x
	LSL	#1,D0
	MOVE	D0,(A0)
.x	RTS

IncreaseZoomY:
	LEA	ZoomY(PC),A0
	MOVE	(A0),D0
	CMPI	#256,D0
	BEQ.S	.x
	LSL	#1,D0
	MOVE	D0,(A0)
.x	RTS

DecreaseZoomY:
	LEA	ZoomY(PC),A0
	MOVE	(A0),D0
	CMPI	#1,D0
	BEQ.S	.x
	LSR	#1,D0
	MOVE	D0,(A0)
.x	RTS

SaveSample:
	LEA	SampleFileName(PC),A3
	FILE_CREATE A3,#0
	MOVE	D0,D3
	BMI.S	.x
	FILE_WRITE D3,#SoundSampleFrequency*4/SoundFrameRatePerSec,SoundAddress+8(PC)
	FILE_CLOSE D3
.x	RTS
SampleFileName	DC.B "SAMPLE.SND",0
	EVEN

FreezeSample:
	CONS_IN #2
	ANDI	#$DF,D0
	CMPI	#'S',D0
	BEQ	SaveSample
	RTS

MAIN:	BSR	EraseSample
	BSR	DrawAxis
	BSR	DrawSample
	BSR	NewFrames
	BSR	CalcFPS
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
	ANDI.B	#$DF,D0
	CMPI.B	#'F',D0
	BEQ	FreezeSample
	SWAP	D0
	CMPI.B	#$4B,D0
	BEQ	IncreaseZoomX
	CMPI.B	#$4D,D0
	BEQ	DecreaseZoomX
	CMPI.B	#$48,D0
	BEQ	IncreaseZoomY
	CMPI.B	#$50,D0
	BEQ	DecreaseZoomY
	RTS

RECORD:	MOVE.L	A6,-(SP)
	LEA	SoundFrameFull(PC),A6
	TST.B	(A6)
	BNE.S	.x
	ST	(A6)
	LEA	SoundAddress+8+1(PC),A6 ;YES +8 !!! --> LOOP mode
	MOVE.B	(A6)+,SND_BH+1
	MOVE.B	(A6)+,SND_BM+1
	MOVE.B	(A6)+,SND_BL+1
	ADDQ	#1,A6
	MOVE.B	(A6)+,SND_EH+1
	MOVE.B	(A6)+,SND_EM+1
	MOVE.B	(A6)+,SND_EL+1
.x	MOVEA.L	(SP)+,A6
	BCLR	#7,MFP_ISRA+1
	RTE

	D_
PPP_VIDEO	INCBIN	VIDEO.PPP
PPP_VIDEO2	INCBIN	VIDEO2.PPP
PPP_SOUND	INCBIN	SOUND.PPP

VideoTable:
	DC.W $0000,$0000,$0100,$0000,$0186,$0005
	DC.W $00C6,$0096,$0008,$029E,$0096,$0096
	DC.W $0419,$0415,$0017,$0017,$0415,$0415
	DC.W	 0,    0,    0,$0000,$0000,$0158
	DC.L $00000000

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

VideoAddress	DC.L	VideoFrame0 ;Aligned on LONG WORD !!!
		DC.L	VideoFrame1
SoundFrameFull	DC.B	-1,0
SoundAddress	DC.L	SoundFrame0
		DC.L	SoundFrame0+SoundSampleFrequency*4/SoundFrameRatePerSec
		DC.L	SoundFrame1
		DC.L	SoundFrame1+SoundSampleFrequency*4/SoundFrameRatePerSec
PointTable	DC.L	PointTable0
		DC.L	PointTable1
; Variables for frame rate
tim_cnt0	DC.L 0
FPS		DC.W 0
FramePerSec	DC.W -1
ZoomX		DC.W 1 ;Ratio of 1,2,4,8
ZoomY		DC.W 1 ;Ratio of 1,2,4,8,16,32,64,128,256
InputError	DC.W $00B4
InputErrorTable	DC.W $00B4,$00E0,$0116,$0153,$0177,$01D0,$023C,$02B6
		DC.W $0306,$03BC,$0490,$0586,$0631,$0790,$0920,$0ADE
	M_
SP0		DS.L 1
MFP0		DS.W 6
M_PPP_VIDEO	DS.B	2*1024
M_PPP_VIDEO2	DS.B	8*1024
M_PPP_SOUND	DS.B	1*1024
PointTable0	DS.L	VideoW
PointTable1	DS.L	VideoW
VideoFrame0	DS.W	VideoW*VideoH
VideoFrame1	DS.W	VideoW*VideoH
		DS.W	1 ;Necessary for VIDEO BASE on long word boundary
SoundFrame0	DS.L	SoundSampleFrequency/SoundFrameRatePerSec
SoundFrame1	DS.L	SoundSampleFrequency/SoundFrameRatePerSec
	END
