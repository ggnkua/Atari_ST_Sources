	M_
PTail	=90
PNumber =26
PVTail	=22

REnable 		DS.B 1
RFull			DS.B 1
RWritePointer		DS.W 1 ;(0 … (PNumber-1)*PTail)
RReadPointer		DS.W 1 ;(0 … (PNumber-1)*PTail)
RTimeInt		DS.W 1
RTimeFrc		DS.W 1

PACKETS:		DS.B PTail*PNumber
PTimeFrc=0		;DS.W 1 (125/TIMER_BEAT)/50 , pas de Int

PV0=2
PVSamplePointerInt  =0	;DS.L 1
PVSamplePointerFrc  =4	;DS.W 1
PVSamplePointerEnd  =6	;DS.L 1 (0 ou -1:STOP)
PVSampleRepeatStart =10 ;DS.L 1
PVSampleRepeatEnd   =14 ;DS.L 1 (-1:STOP)
PVFreq		    =18 ;DS.W 1 3579546/VPitch
PVVolume	    =20 ;DS.W 1

PV1=PV0+PVTail
PV2=PV1+PVTail
PV3=PV2+PVTail

	P_
Osc	MOVE.B	REnable(PC),D0
	BEQ	OscFin
	MOVE.B	RFull(PC),D0
	BNE	OscFin
	LEA	PACKETS(PC),A0
	ADDA	RWritePointer(PC),A0
 ;PTimeFrc
	MOVE.L	#(2*65536)+(65536/2),D0
	DIVU	TIMER_BEAT(PC),D0
	MOVE	D0,(A0)+

 ;RAPPEL:
 ;le paquet est valide lorsque sa dur‚e est d‚clar‚e dans RTime
 ;-->Gardons D0

 ;Les voies
	LEA	VOICE0(PC),A1
	BSR.S	ReadVoice
	LEA	VOICE1(PC),A1
	BSR.S	ReadVoice
	LEA	VOICE2(PC),A1
	BSR.S	ReadVoice
	LEA	VOICE3(PC),A1
	BSR.S	ReadVoice
	LEA	RWritePointer(PC),A0
	MOVE	(A0),D1
	ADDI	#PTail,D1
	CMPI	#PNumber*PTail,D1
	BNE.S	.1
	MOVEQ	#0,D1
.1	MOVE	D1,(A0)
	LEA	RFull(PC),A0
	CMP	RReadPointer(PC),D1
	SEQ	(A0)
	MOVEQ	#0,D1
	MOVE	D0,D1
	LEA	RTimeInt(PC),A0
	ADD.L	D1,(A0)
	BRA.S	OscFin

ReadVoice:
	MOVE.L	VSamplePointerInt(A1),(A0)+
	MOVE	VSamplePointerFrac(A1),(A0)+
	MOVE.L	VSamplePointerEnd(A1),(A0)+
	MOVE.L	VSampleRepeatStart(A1),(A0)+
	MOVE.L	VSampleRepeatEnd(A1),(A0)+
 ;PVFreq=3579546/VPitch
	MOVE.L	#3579546,D1
	MOVE	VPitch(A1),D2
	BEQ.S	.f0
	DIVU	D2,D1
	MOVE	D1,(A0)+
.v	MOVE	VVolume(A1),(A0)+
	RTS

.f0	CLR	(A0)+
	BRA	.v

OscFin:
