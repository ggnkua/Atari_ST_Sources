FrqPlayer	equ	3
*0:  7.5KHz
*1:  8.5KHz
*2: 10.1KHz
*3: 12.5KHz

* routine de replay des fichiers modules soundtracker (v 2.5)
	BRA	ReplayRoutine
	BRA	ChangeMicrowire


* Routs...
ChangeMicrowire
	MOVEM.L	D0-A6,-(SP)
	LEA	MwParameters(PC),A0
	MOVE.L	64(SP),D0
	AND.L	#$001F001F,D0
	OR.L	#$05400500,D0
	MOVE.L	D0,(A0)+
	MOVE.L	68(SP),D0
	AND.L	#$000F000F,D0
	OR.L	#$04800440,D0
	MOVE.L	D0,(A0)+
	MOVE.W	72(SP),D0
	AND.W	#$003F,D0
	OR.W	#$04C0,D0
	MOVE.W	D0,(A0)+
	MOVEM.L	(SP)+,D0-A6
	RTS

ReplayRoutine
	BSR.S	ReadStack
	PEA	ST_Connexion(PC)
	MOVE.W	#$26,-(SP)
	TRAP	#14
	LEA	6(SP),SP
	RTS

ReadStack
	MOVEM.L	D0-A6,-(SP)
	LEA	68(SP),A0
	LEA	ModuleAddress(PC),A1
	MOVE.L	(A0)+,(A1)
	LEA	Output(PC),A1
	MOVE.W	(A0)+,(A1)
	LEA	NewVolumeTable(PC),A1
	MOVE.L	(A0)+,(A1)

	LEA	FlagSoundchip+Flags+Vectors(PC),A1
	LEA	FlagDma+Flags+Vectors(PC),A2
	LEA	FlagVolume7bits+Flags+Vectors(PC),A3
	LEA	FlagCartridge+Flags+Vectors(PC),A4
	
	LEA	Output(PC),A0
	AND.W	#$00FF,(A0)
	MOVE.W	(A0),D0
	CMP.W	#$00,D0
	BNE.S	.Out0b
	ST	(A1)
	SF	(A2)
	SF	(A3)
	SF	(A4)
	BRA	.Out
.Out0b	CMP.W	#$01,D0
	BNE.S	.Out1
	ST	(A1)
	SF	(A2)
	SF	(A3)
	SF	(A4)
	BRA	.Out
.Out1	CMP.W	#$10,D0
	BNE.S	.Out2
	SF	(A1)
	ST	(A2)
	SF	(A3)
	SF	(A4)
	BRA	.Out
.Out2	CMP.W	#$11,D0
	BNE.S	.Out3
	SF	(A1)
	ST	(A2)
	ST	(A3)
	SF	(A4)
	BRA.S	.Out
.Out3	CMP.W	#$12,D0
	BNE.S	.Out4
	SF	(A1)
	ST	(A2)
	SF	(A3)
	SF	(A4)
	BRA.S	.Out
.Out4	CMP.W	#$13,D0
	BNE.S	.Out4b
	SF	(A1)
	ST	(A2)
	ST	(A3)
	SF	(A4)
	BRA.S	.Out
.Out4b	CMP.W	#$14,D0
	BNE.S	.Out5
	SF	(A1)
	ST	(A2)
	SF	(A3)
	SF	(A4)
	BRA.S	.Out
.Out5	CMP.W	#$20,D0
	BNE.S	.Out6
	SF	(A1)
	SF	(A2)
	SF	(A3)
	ST	(A4)
	BRA.S	.Out
.Out6	CMP.W	#$21,D0
	BNE.S	.Out7
	SF	(A1)
	SF	(A2)
	SF	(A3)
	ST	(A4)
	BRA.S	.Out
.Out7	CMP.W	#$22,D0
	BNE.S	.Out8
	SF	(A1)
	SF	(A2)
	SF	(A3)
	ST	(A4)
	BRA.S	.Out
.Out8	CMP.W	#$24,D0
	BNE.S	.Out
	SF	(A1)
	SF	(A2)
	SF	(A3)
	ST	(A4)
.Out	TST.B	(A3)
	BEQ.S	.NoDma
	LEA	NewVolumeTable(PC),A0
	TST.L	(A0)
	BNE.S	.NoDma
	LEA	Output(PC),A0
	MOVE.W	#$10,(A0)
	SF	(A1)
	ST	(A2)
	SF	(A3)
	SF	(A4)
.NoDma	MOVEM.L	(SP)+,D0-A6
	RTS

ST_Connexion
	MOVEM.L	D0-A6,-(SP)
	BSR	ClearAcias
	BSR	SaveInterrupts
	BSR	TransformModule
	BSR	InitDataOfPlayer
	BSR	PlayModule
	BSR	TransformModule
	BSR	ClearAcias
	BSR	ResetInterrupts
	BSR	ClearKbd
	MOVEM.L	(SP)+,D0-A6
	RTS

SaveInterrupts
	MOVE.W	#$2700,SR
	MOVE.B	#$12,$FFFFFC02.W
	DC.W	$A00A
	MOVEM.L	D0-A6,-(SP)
	LEA	Vectors(PC),A6
	MOVE.L	$70.W,Vbl(A6)
	MOVE.L	$134.W,Timera(A6)
	MOVE.L	$120.W,Timerb(A6)
	MOVE.L	$114.W,Timerc(A6)
	MOVE.L	$110.W,Timerd(A6)
	lea	VideoRegisters(A6),A1
	move.w	#$8200,a0
	movep.w	1(a0),d0
	move.w	d0,(a1)+
	move.w	$60(a0),(a1)+
	movem.l	$40(a0),d0-d7
	movem.l	d0-d7,(a1)
	clr.l	$fffffa06.w
	clr.l	$fffffa12.w
	bclr.b	#3,$fffffa17.w
	TST.B	FlagSoundchip+Flags(A6)
	BEQ.S	.NoSoundchip
	Lea	YamahaRegisters(A6),A1
	Lea	$FFFF8800.w,A0
	Moveq	#$E,D0
.SaveYamahaRegisters
	Move.b	D0,(A0)
	Move.b	(A0),(A1)+
	Dbra	D0,.SaveYamahaRegisters
	CLR.L	(A0)
	MOVE.L	#$01010000,(A0)
	MOVE.L	#$02020000,(A0)
	MOVE.L	#$03030000,(A0)
	MOVE.L	#$04040000,(A0)
	MOVE.L	#$05050000,(A0)
	MOVE.L	#$06060000,(A0)
	MOVE.L	#$0707FFFF,(A0)
	MOVE.L	#$08080000,(A0)
	MOVE.L	#$09090000,(A0)
	MOVE.L	#$0A0A0000,(A0)
.NoSoundchip
	TST.B	FlagDma+Flags(A6)
	BEQ.S	.NoDma
	LEA	Vectors(PC),A6
	LEA	DmaSte(A6),A0
	LEA	$FFFF8900.W,A1
	MOVEP.L	$1(A1),D0
	MOVE.L	D0,(A0)+
	MOVEP.L	$D(A1),D0
	AND.L	#$00FFFFFF,D0
	MOVE.L	D0,(A0)+
	MOVE.W	$20(A1),(A0)+
	CLR.B	$1(A0)
.NoDma	MOVEM.L	(SP)+,D0-A6
	MOVE.W	#$2300,SR
	RTS

ResetInterrupts
	MOVE.W	#$2700,SR
	MOVEM.L	D0-A6,-(SP)
	LEA	Vectors(PC),A6
	MOVE.L	Vbl(A6),$70.W
	MOVE.L	Timera(A6),$134.W
	MOVE.L	Timerb(A6),$120.W
	MOVE.L	Timerc(A6),$114.W
	MOVE.L	Timerd(A6),$110.W
	lea	VideoRegisters(A6),A1
	move.w	#$8200,a0
	move.w	(a1)+,d0
	movep.w	d0,1(a0)
	move.w	(a1)+,$60(a0)
	movem.l	(a1),d0-d7
	movem.l	d0-d7,$40(a0)
* Restore Mfp Registers ($FFFA03 - $FFFA25)
	Lea	$FFFFFA00.w,A1
	Move.l	#$04001e64,D0
	Movep.l	D0,$3(A1)
	Move.w	#$1e64,D0
	Movep.w	D0,$13(A1)
	Clr.b	$19(A1)
	Clr.b	$1B(A1)
	Clr.b	$1D(A1)
	Move.l	#$fff0c002,D0
	Movep.l	D0,$1F(A1)
	Move.b	#$51,$1D(A1)
	Move.b	#$48,$17(A1)
	TST.B	FlagSoundchip+Flags(A6)
	BEQ.S	.NoSoundchip
	Lea	YamahaRegisters(A6),A0
	Lea	$FFFF8800.w,A1
	Moveq	#$E,D0
.RestoreYamahaRegisters
	Move.b	D0,(A1)
	Move.b	(A0)+,2(A1)
	Dbra	D0,.RestoreYamahaRegisters
.NoSoundchip
	TST.B	FlagDma+Flags(A6)
	BEQ.S	.NoDma
	LEA	Vectors(PC),A6
	LEA	DmaSte(A6),A0
	LEA	$FFFF8900.W,A1
	MOVE.L	(A0)+,D0
	AND.L	#$00FFFFFF,D0
	MOVEP.L	D0,$1(A1)
	MOVE.L	(A0)+,D0
	MOVEP.W	D0,$11(A1)
	SWAP	D0
	MOVE.B	D0,$E(A1)
	MOVE.W	(A0)+,$20(A1)
	LEA	MwResetState(PC),A0
	MOVEQ	#5,D7
.ResetMicrowire
	MOVE.W	(A0)+,D0
.ResetMicrowire1
	MOVE.W	#$7FF,$FFFF8924.W
	CMP.W	#$7FF,$FFFF8924.W
	BNE.S	.ResetMicrowire1
	MOVE.W	D0,$FFFF8922.W
	DBRA	D7,.ResetMicrowire
	MOVE.B	DmaSte(A6),$1(A1)
.NoDma	MOVEM.L	(SP)+,D0-A6
	DC.W	$A009
	MOVE.B	#$8,$FFFFFC02.W
	MOVE.W	#$2300,SR
	RTS

ClearAcias
	MOVE.W	D0,-(SP)
	move.b	#$13,$fffffc02.w
.FlushKey
	moveq.l	#$a1,d0
	and.b	$fffffc00.w,d0
	beq.s	.Flush
	tst.b	$fffffc02.w
	bra.s	.FlushKey
.Flush	move.b	#$11,$fffffc02.w
	MOVE.W	(SP)+,D0
	RTS

ClearKbd
	movem.l	d0-a6,-(sp)
	move.w	#$22,-(sp)
	trap	#14
	addq.l	#2,sp
	sub.l	a0,a0
	clr.b	109(a0,d0.l)
	movem.l	(sp)+,d0-a6
	rts

TransformModule
	MOVEM.L	D0-A6,-(SP)
	MOVE.L	ModuleAddress(PC),A0
	LEA	Offset(PC),A1
	MOVE.W	#$1D8,Pos(A1)
	MOVE.W	#$258,Patt(A1)
	MOVE.W	#$F,NbrIns(A1)
	CMP.L	#'M.K.',$438(A0)
	BNE.S	OldModules
	MOVE.W	#$3B8,Pos(A1)
	MOVE.W	#$43C,Patt(A1)
	MOVE.W	#$1F,NbrIns(A1)
OldModules
	ADD.W	Pos(A1),A0
	MOVEQ	#$7F,D0
	MOVEQ	#0,D1
.0	MOVE.L	D1,D2
	SUBQ.W	#1,D0
.1	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	.0
	DBF	D0,.1
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	MOVE.L	ModuleAddress(PC),A0
	ADD.L	A0,D2
	LEA	$14(A0),A0
	LEA	Offset(PC),A1
	MOVE.W	NbrIns(A1),D7
	ADD.W	Patt(A1),D2
	MOVE.L	D2,A2
	LEA	SampleStarts(PC),A1
	LEA	(A1),A3
	MOVEQ	#$1E,D6
.Clr	CLR.L	(A3)+
	DBRA	D6,.Clr
	SUBQ.W	#1,D7
.TransformIns
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	22(A0),D1
	LSL.L	#1,D1
	MOVE.L	A2,A5
	ADD.L	D1,A2
	MOVE.L	A2,(A1)
	LEA	(A2),A6
	MOVE.W	22(A0),D6
	BEQ.S	.NoIns
	SUBQ.W	#1,D6
.ReverseIns
	MOVE.B	(A5),D2
	MOVE.B	-1(A6),D3
	EOR.B	#$80,D2
	EOR.B	#$80,D3
	MOVE.B	D3,(A5)+
	MOVE.B	D2,-(A6)
	DBRA	D6,.ReverseIns
.NoIns	CMP.W	#$0001,28(A0)
	BNE.S	.Replen
	CLR.W	28(A0)
.Replen	LEA	$1E(A0),A0
	DBRA	D7,.TransformIns
	MOVEM.L	(SP)+,D0-A6
	RTS

InitDataOfPlayer
	MOVEM.L	D0-A6,-(SP)
	LEA	Flags+Vectors(PC),A6
	LEA	Chip(PC),A0
	LEA	NoIns(PC),A1
	MOVEQ	#$7,D0
.Clr0	MOVE.L	A1,(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBRA	D0,.Clr0
	LEA	Voices(PC),A0
	MOVEQ	#$1C-1,D0
.Clr1	CLR.L	(A0)+
	DBRA	D0,.Clr1
	LEA	Offset(PC),A0
	MOVE.B	#$6,Speed(A0)
	CLR.B	SongPos(A0)
	CLR.W	PattPos(A0)
	CLR.B	Counter(A0)
	CLR.B	Break(A0)
	TST.B	FlagDma(A6)
	BEQ.S	.Unsigned
	CLR.L	D1
	BRA.S	.Signed
.Unsigned
	MOVE.L	#$04000400,D1
.Signed	LEA	DigitSwap(PC),A0
	LEA	DigitBuffer+2040(PC),A1
	MOVE.L	A1,(A0)
	LEA	DigitBuffer(PC),A1
	MOVE.L	A1,4(A0)
	MOVE.W	#1020-1,D0
.Fill1	MOVE.L	D1,(A1)+
	DBRA	D0,.Fill1
	LEA	VoicesBuffer(PC),A0
	TST.B	FlagDma(A6)
	BEQ.S	.Unsigned_
	CLR.L	D1
	BRA.S	.Signed_
.Unsigned_
	MOVE.L	#$80808080,D1
.Signed_
	MOVE.W	#510-1,D0
.Fill2	MOVE.L	D1,(A0)+
	DBRA	D0,.Fill2
	LEA	VoiceOff(PC),A0
	MOVE.W	#205-1,D0
.Fill3	MOVE.L	D1,(A0)+
	DBRA	D0,.Fill3
	LEA	DigitBuffer(PC),A0
	MOVE.L	A0,D0
	LEA	Dig00+2(PC),A0
	MOVE.L	D0,(A0)
	LEA	Dig01+2(PC),A0
	MOVE.L	D0,(A0)
	LEA	Dig20+2(PC),A0
	MOVE.L	D0,(A0)
	LEA	Dig21+2(PC),A0
	MOVE.L	D0,(A0)
	LEA	Dig22+2(PC),A0
	MOVE.L	D0,(A0)
	LEA	Dig24+2(PC),A0
	MOVE.L	D0,(A0)
	TST.B	FlagVolume7bits(A6)
	BEQ.S	.NoVolume7bits
	LEA	Volume(PC),A0
	MOVE.L	NewVolumeTable(PC),A1
	MOVE.W	#$80,D1
	MOVE.W	#65*256-1,D2
.Calc7bitsVolumeTable
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	EOR.W	D1,D0
	EXT.W	D0
	ASR.W	D0
	MOVE.B	D0,(A1)+
	DBRA	D2,.Calc7bitsVolumeTable
.NoVolume7bits
	MOVEM.L	(SP)+,D0-A6
	RTS

************************************************************
* Here's the soundtracker replay routine.                  *
************************************************************
PlayModule
	MOVEM.L	D0-A6,-(SP)
	BSR	Init
.Main	BSR	WaitFrame
	CMP.B	#$81,$FFFFFC02.W
	BNE.S	.Main
	BSR	End
	MOVEM.L	(SP)+,D0-A6
	RTS

Init	MOVEM.L	D0-A6,-(SP)
	MOVE.W	#$2700,SR

	LEA	Flags+Vectors(PC),A5
	TST.B	FlagDma(A5)
	BNE	DmaProgrammation
	LEA	No_Timera(PC),A0
	MOVE.L	A0,$134.W
	LEA	No_Timera(PC),A0
	MOVE.L	A0,$110.W
	LEA	Frame(PC),A0
	MOVE.L	A0,$70.W
	MOVE.W	#$FA00,A6
	CLR.B	$19(A6)
	MOVE.B	#FrqData,$1F(A6)
	MOVE.B	#1,$19(A6)
	CLR.B	$1D(A6)
	MOVE.B	#246,$25(A6)
	MOVE.B	#%111,$1D(A6)
	OR.B	#%00100000,$13(A6)
	OR.B	#%00100000,$7(A6)
	OR.B	#%00010000,$15(A6)
	OR.B	#%00010000,$9(A6)

	MOVE.W	Output(PC),D0
	CMP.W	#$00,D0
	BNE.S	.Out1
	LEA	PlayerSTf(PC),A0
	MOVE.L	A0,$110.W
	LEA	STf(PC),A0
	MOVE.L	A0,$134.W
	BRA.S	.Out
.Out1	CMP.W	#$01,D0
	BNE.S	.Out20
	LEA	PlayerSTf1(PC),A0
	MOVE.L	A0,$110.W
	LEA	STf1(PC),A0
	MOVE.L	A0,$134.W
	BRA.S	.Out
.Out20	CMP.W	#$20,D0
	BNE.S	.Out21
	LEA	PlayerStReplay(PC),A0
	MOVE.L	A0,$110.W
	LEA	StReplay(PC),A0
	MOVE.L	A0,$134.W
	BRA.S	.Out
.Out21	CMP.W	#$21,D0
	BNE.S	.Out22
	LEA	PlayerStReplayPro(PC),A0
	MOVE.L	A0,$110.W
	LEA	StReplayPro(PC),A0
	MOVE.L	A0,$134.W
	BRA.S	.Out
.Out22	CMP.W	#$22,D0
	BNE.S	.Out24
	LEA	PlayerPlayBack(PC),A0
	MOVE.L	A0,$110.W
	LEA	PlayBack(PC),A0
	MOVE.L	A0,$134.W
	BRA.S	.Out
.Out24	CMP.W	#$24,D0
	BNE.S	.Out
	LEA	PlayerProSound(PC),A0
	MOVE.L	A0,$110.W
	LEA	ProSound(PC),A0
	MOVE.L	A0,$134.W
.Out	MOVE.W	#$2300,SR
	MOVEM.L	(SP)+,D0-A6
	RTS

DmaProgrammation
	MOVE.W	#$FA00,A6
	CLR.B	$19(A6)
	MOVE.B	#1,$1F(A6)
	MOVE.B	#8,$19(A6)
	OR.B	#%00100000,$13(A6)
	OR.B	#%00100000,$7(A6)
	LEA	PlayerDma(PC),A0
	MOVE.L	A0,$134.W
	LEA	Frame(PC),A0
	MOVE.L	A0,$70.W
	MOVE.W	Output(PC),D0
	CMP.W	#$10,D0
	BNE.S	.No12KHz
	MOVE.L	#249*2,D1
	MOVEQ	#1,D2
	BRA.S	.OK
.No12KHz
	CMP.W	#$11,D0
	BNE.S	.No25KHz7bits
	MOVE.L	#501*2,D1
	MOVEQ	#2,D2
	BRA.S	.OK
.No25KHz7bits
	CMP.W	#$12,D0
	BNE.S	.No50KHz
	MOVE.L	#1002*2,D1
	MOVEQ	#3,D2
	BRA.S	.OK
.No50KHz
	CMP.W	#$13,D0
	BNE.S	.No50KHz7bits
	MOVE.L	#1002*2,D1
	MOVEQ	#3,D2
	BRA.S	.OK
.No50KHz7bits
	CMP.W	#$14,D0
	BNE.S	.No25KHz
	MOVE.L	#501*2,D1
	MOVEQ	#2,D2
	BRA.S	.OK
.No25KHz
	MOVEQ	#2,D1
	MOVEQ	#0,D2
.OK	MOVE.L	DigitSwap(PC),D0
	AND.L	#$00FFFFFF,D0
	LEA	$FFFF8900.W,A0
	MOVEP.L	D0,$1(A0)
	ADD.L	D1,D0
	MOVEP.W	D0,$11(A0)
	SWAP	D0
	MOVE.B	D0,$F(A0)
	MOVE.W	D2,$20(A0)
	LEA	MwParameters(PC),A1
	MOVEQ	#5,D1
.SetMicrowire
	MOVE.W	(A1)+,D0
.SetMicrowire1
	MOVE.W	#$7FF,$FFFF8924.W
	CMP.W	#$7FF,$FFFF8924.W
	BNE.S	.SetMicrowire1
	MOVE.W	D0,$FFFF8922.W
	DBRA	D1,.SetMicrowire
	MOVE.B	#%11,$1(A0)
	MOVE.W	#$2300,SR
	MOVEM.L	(SP)+,D0-A6
	RTS
End	MOVEM.L	D0-A6,-(SP)
	MOVE.W	#$2700,SR
	MOVE.W	#$FA00,A6
	MOVEQ	#0,D0
	MOVEP.W	D0,$13(A6)
	MOVEP.W	D0,$7(A6)
	MOVE.W	#$2300,SR
	MOVEM.L	(SP)+,D0-A6
	RTS

WaitFrame
	MOVE.L	A0,-(SP)
	LEA	Switch(PC),A0
	SF	(A0)
.Wait	TST.B	(A0)
	BEQ.S	.Wait
	MOVE.L	(SP)+,A0
	RTS

************************************************************
* Interrupts routs.                                        *
************************************************************
Frame	PEA	(A0)
	LEA	Switch(PC),A0
	ST	(A0)
	MOVE.L	(SP)+,A0
	RTE

No_Timera
	RTE
STf	MOVEM.L	D0/A0,-(SP)
Dig00	MOVE.W	0.L,D0
	LEA	Dig00+2(PC),A0
	ADDQ.L	#2,(A0)
	LEA	Sound(PC,D0.W),A0
	MOVE.L	(A0)+,D0
	MOVE.L	(A0),$FFFF8800.W
	LEA	$FFFF8800.W,A0
	MOVEP.L	D0,(A0)
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE
Sound	INCBIN	sndchip.cnx
STf1	MOVEM.L	D0/A0,-(SP)
Dig01	MOVE.W	0.L,D0
	LEA	Dig01+2(PC),A0
	ADDQ.L	#2,(A0)
	MOVE.W	TableStf1(PC,D0.W),D0
	LEA	Sound(PC),A0
	ADD.W	D0,A0
	MOVE.L	(A0)+,D0
	MOVE.L	(A0),$FFFF8800.W
	LEA	$FFFF8800.W,A0
	MOVEP.L	D0,(A0)
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE
TableStf1
	rept	384
	dc.w	0
	endr
x	set	0
	rept	256
	dc.w	x*8
x	set	x+1
	endr
	rept	384
	dc.w	255*8
	endr
StReplay
	MOVEM.L	D0/A0,-(SP)
Dig20	MOVE.W	0.L,D0
	LEA	Dig20+2(PC),A0
	ADDQ.L	#2,(A0)
	LEA	$FFFA0000,A0
	TST.B	0(A0,D0.W)
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE
StReplayPro
	MOVEM.L	D0/A0,-(SP)
Dig21	MOVE.W	0.L,D0
	LEA	Dig21+2(PC),A0
	ADDQ.L	#2,(A0)
	LEA	$FFFA0000,A0
	TST.B	0(A0,D0.W)
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE
PlayBack
	MOVEM.L	D0/A0-A1,-(SP)
Dig22	MOVE.L	0.L,D0
	LEA	Dig22+2(PC),A0
	ADDQ.L	#4,(A0)
	LEA	$FFFA0000,A0
	LEA	$FFFA0200,A1
	TST.B	0(A0,D0.W)
	SWAP	D0
	TST.B	0(A1,D0.W)
	MOVEM.L	(SP)+,D0/A0-A1
	RTE
ProSound
	MOVEM.L	D0/A0,-(SP)
Dig24	MOVE.W	0.L,D0
	LEA	Dig24+2(PC),A0
	ADDQ.L	#2,(A0)
	LEA	$FFFF8848.W,A0
	MOVE.W	#$0F00,(A0)+
	MOVE.B	D0,(A0)
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE

PlayerDma
	MOVE.W	#$2300,SR
	MOVEM.L	D0-D1/A0,-(SP)
	MOVE.W	Output(PC),D0
	CMP.W	#$10,D0
	BNE.S	.1
	MOVE.L	#249*2,D1
	BRA.S	.0
.1	CMP.W	#$11,D0
	BNE.S	.2
	MOVE.L	#501*2,D1
	BRA.S	.0
.2	CMP.W	#$12,D0
	BNE.S	.3
	MOVE.L	#1002*2,D1
.3	CMP.W	#$13,D0
	BNE.S	.4
	MOVE.L	#1002*2,D1
.4	CMP.W	#$14,D0
	BNE.S	.0
	MOVE.L	#501*2,D1
.0	LEA	DigitSwap(PC),A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	MOVE.L	DigitSwap+4(PC),D0
	AND.L	#$00FFFFFF,D0
	OR.L	#$01000000,D0
	MOVE.W	#$8900,A0
	MOVEP.L	D0,$1(A0)
	ADD.L	D1,D0
	MOVEP.W	D0,$11(A0)
	SWAP	D0
	MOVE.B	D0,$F(A0)
	BSR	Player
	BSR	PrecalcDigitDma
	MOVEM.L	(SP)+,D0-D1/A0
	RTE

PlayerSTf
	MOVE.W	#$2300,SR
	MOVEM.L	D0/A0,-(SP)
	LEA	DigitSwap(PC),A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	LEA	Dig00+2(PC),A0
	MOVE.L	D0,(A0)
	BSR	Player
	BSR	PrecalcDigit
	MOVEM.L	(SP)+,D0/A0
	RTE
PlayerSTf1
	MOVE.W	#$2300,SR
	MOVEM.L	D0/A0,-(SP)
	LEA	DigitSwap(PC),A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	LEA	Dig01+2(PC),A0
	MOVE.L	D0,(A0)
	BSR	Player
	BSR	PrecalcDigit
	MOVEM.L	(SP)+,D0/A0
	RTE
PlayerStReplay
	MOVE.W	#$2300,SR
	MOVEM.L	D0/A0,-(SP)
	LEA	DigitSwap(PC),A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	LEA	Dig20+2(PC),A0
	MOVE.L	D0,(A0)
	BSR	Player
	BSR	PrecalcDigit
	MOVEM.L	(SP)+,D0/A0
	RTE
PlayerStReplayPro
	MOVE.W	#$2300,SR
	MOVEM.L	D0/A0,-(SP)
	LEA	DigitSwap(PC),A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	LEA	Dig21+2(PC),A0
	MOVE.L	D0,(A0)
	BSR	Player
	BSR	PrecalcDigit
	MOVEM.L	(SP)+,D0/A0
	RTE
PlayerPlayBack
	MOVE.W	#$2300,SR
	MOVEM.L	D0/A0,-(SP)
	LEA	DigitSwap(PC),A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	LEA	Dig22+2(PC),A0
	MOVE.L	D0,(A0)
	BSR	Player
	BSR	PrecalcDigit
	MOVEM.L	(SP)+,D0/A0
	RTE
PlayerProSound
	MOVE.W	#$2300,SR
	MOVEM.L	D0/A0,-(SP)
	LEA	DigitSwap(PC),A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	LEA	Dig24+2(PC),A0
	MOVE.L	D0,(A0)
	BSR	Player
	BSR	PrecalcDigit
	MOVEM.L	(SP)+,D0/A0
	RTE


Player	MOVEM.L	D0-A6,-(SP)
	LEA	Offset(PC),A4
	ADDQ.B	#$1,Counter(A4)
	MOVE.B	Counter(A4),D0
	CMP.B	Speed(A4),D0
	BLT.S	ReadCommands
	CLR.B	Counter(A4)
	BRA.S	ReadPatterns
ReadCommands
	LEA	Chip0(PC),A5
	LEA	Voice0(PC),A6
	BSR	CheckCommand
	LEA	Chip1(PC),A5
	LEA	Voice1(PC),A6
	BSR	CheckCommand
	LEA	Chip2(PC),A5
	LEA	Voice2(PC),A6
	BSR	CheckCommand
	LEA	Chip3(PC),A5
	LEA	Voice3(PC),A6
	BSR	CheckCommand
	BRA	EndOfPlayer
ReadPatterns
	MOVE.L	ModuleAddress(PC),A0
	LEA	$C(A0),A3
	LEA	(A0),A2
	ADD.W	Pos(A4),A2
	ADD.W	Patt(A4),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	SongPos(A4),D0
	MOVE.B	0(A2,D0.W),D1
	SWAP	D1
	LSR.L	#$6,D1
	ADD.W	PattPos(A4),D1
	LEA	Chip0(PC),A5
	LEA	Voice0(PC),A6
	BSR.S	PlayVoice
	LEA	Chip1(PC),A5
	LEA	Voice1(PC),A6
	BSR.S	PlayVoice
	LEA	Chip2(PC),A5
	LEA	Voice2(PC),A6
	BSR.S	PlayVoice
	LEA	Chip3(PC),A5
	LEA	Voice3(PC),A6
	BSR.S	PlayVoice
	BRA	SetRepeat
PlayVoice
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	$2(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ.S	SetRegs
	MOVEQ	#0,D3
	LEA	SampleStarts(PC),A1
	MOVE.L	D2,D4
	SUBQ.L	#$1,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	MOVE.W	D4,D5
	LSL.W	#5,D4
	SUB.W	D5,D4
	SUB.W	D5,D4
	MOVE.L	(A1,D2.L),$4(A6)
	MOVE.W	(A3,D4.L),$8(A6)
	MOVE.W	$2(A3,D4.L),$12(A6)
	MOVE.W	$4(A3,D4.L),D3
	BEQ.S	NoLoop
	MOVE.W	$8(A6),D3
	SUB.W	$6(A3,D4.L),D3
	SUB.W	$4(A3,D4.L),D3
	BLT.S	NoLoop
	ADD.W	D3,D3
	ADD.L	D3,$4(A6)
	MOVE.L	$4(A6),$A(A6)
	MOVE.W	$6(A3,D4.L),$E(A6)
	MOVE.W	$12(A6),$8(A5)
	BRA.S	SetRegs
NoLoop	MOVE.L	$4(A6),$A(A6)
	MOVE.W	$6(A3,D4.L),$E(A6)
	MOVE.W	$12(A6),$8(A5)
SetRegs	MOVE.W	(A6),D0
	AND.W	#$FFF,D0
	BEQ	CheckCommand2
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	CMP.B	#$3,D0
	BNE.S	SetPeriod
	BSR	SetPortamentoTone
	BRA	CheckCommand2
SetPeriod
	MOVE.W	(A6),$10(A6)
	AND.W	#$FFF,$10(A6)
	CLR.B	$1B(A6)
	MOVE.L	$4(A6),(A5)
	MOVEQ	#0,D0
	MOVE.W	$8(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$4(A5)
	MOVE.W	$10(A6),$A(A5)
	BRA	CheckCommand2
SetRepeat
	MOVEQ	#0,D0
	LEA	Chip0(PC),A5
	LEA	Voice0(PC),A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	Chip1(PC),A5
	LEA	Voice1(PC),A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	Chip2(PC),A5
	LEA	Voice2(PC),A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	Chip3(PC),A5
	LEA	Voice3(PC),A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	ADD.W	#$10,PattPos(A4)
	CMP.W	#$400,PattPos(A4)
	BNE.S	EndOfPlayer
NextPatt
	CLR.W	PattPos(A4)
	CLR.B	Break(A4)
	ADDQ.B	#1,SongPos(A4)
	AND.B	#$7F,SongPos(A4)
	MOVE.B	SongPos(A4),D1
	MOVE.L	ModuleAddress(PC),A0
	ADD.W	Pos(A4),A0
	CMP.B	-2(A0),D1
	BNE.S	EndOfPlayer
	CLR.B	SongPos(A4)
EndOfPlayer
	TST.B	Break(A4)
	BNE.S	NextPatt
	MOVEM.L	(SP)+,D0-A6
	RTS
CheckCommand
	MOVE.W	$2(A6),D0
	AND.W	#$FFF,D0
	BEQ.S	NoCommand
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	BEQ.S	Arpeggio
	CMP.B	#$1,D0
	BEQ	PortamentoUp
	CMP.B	#$2,D0
	BEQ	PortamentoDown
	CMP.B	#$3,D0
	BEQ	PortamentoTone
	CMP.B	#$4,D0
	BEQ	Vibrato
	MOVE.W	$10(A6),$A(A5)
	CMP.B	#$A,D0
	BEQ	VolumeSlide
NoCommand
	RTS
Arpeggio
	MOVEQ	#0,D0
	MOVE.B	Counter(A4),D0
	DIVS	#$3,D0
	SWAP	D0
	CMP.W	#$0,D0
	BEQ.S	Arpeggio2
	CMP.W	#$2,D0
	BEQ.S	Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	LSR.B	#$4,D0
	BRA.S	Arpeggio3
Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	AND.B	#$F,D0
	BRA.S	Arpeggio3
Arpeggio2
	MOVE.W	$10(A6),D2
	BRA.S	Arpeggio4
Arpeggio3
	ADD.W	D0,D0
	MOVEQ	#0,D1
	MOVE.W	$10(A6),D1
	LEA	Periods(PC),A0
	MOVEQ	#$24,D7
ArpeggioLoop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BGE.S	Arpeggio4
	LEA	2(A0),A0
	DBRA	D7,ArpeggioLoop
	RTS
Arpeggio4
	MOVE.W	D2,$A(A5)
	RTS
PortamentoUp
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	SUB.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMP.W	#$71,D0
	BPL.S	PortUp
	MOVE.W	#$71,$10(A6)
PortUp	MOVE.W	$10(A6),$A(A5)
	RTS
PortamentoDown
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	ADD.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMP.W	#$358,D0
	BMI.S	PortDwn
	MOVE.W	#$358,$10(A6)
PortDwn	MOVE.W	$10(A6),$A(A5)
	RTS
SetPortamentoTone
	MOVE.W	(A6),D2
	AND.W	#$FFF,D2
	MOVE.W	D2,$18(A6)
	MOVE.W	$10(A6),D0
	CLR.B	$16(A6)
	CMP.W	D0,D2
	BEQ.S	ClrPortamentoTone
	BGE.S	OkRts
	MOVE.B	#$1,$16(A6)
	RTS
ClrPortamentoTone
	CLR.W	$18(A6)
OkRts	RTS
PortamentoTone
	MOVE.B	$3(A6),D0
	BEQ.S	MySlide
	MOVE.B	D0,$17(A6)
	CLR.B	$3(A6)
MySlide	TST.W	$18(A6)
	BEQ.S	OkRts
	MOVEQ	#0,D0
	MOVE.B	$17(A6),D0
	TST.B	$16(A6)
	BNE.S	MySub
	ADD.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BGT.S	MyOk
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
MyOk	MOVE.W	$10(A6),$A(A5)
	RTS
MySub	SUB.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BLT.S	MyOk
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
	MOVE.W	$10(A6),$A(A5)
	RTS
Vibrato
	MOVE.B	$3(A6),D0
	BEQ.S	Vib
	MOVE.B	D0,$1A(A6)
Vib	MOVE.B	$1B(A6),D0
	LEA	Sinus(PC),A0
	LSR.W	#$2,D0
	AND.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	(A0,D0.W),D2
	MOVE.B	$1A(A6),D0
	AND.W	#$F,D0
	MULU	D0,D2
	LSR.W	#$6,D2
	MOVE.W	$10(A6),D0
	TST.B	$1B(A6)
	BMI.S	VibMin
	ADD.W	D2,D0
	BRA.S	Vib2
VibMin	SUB.W	D2,D0
Vib2	MOVE.W	D0,$A(A5)
	MOVE.B	$1A(A6),D0
	LSR.W	#$2,D0
	AND.W	#$3C,D0
	ADD.B	D0,$1B(A6)
	RTS
VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	VolumeDown
	ADD.W	D0,$12(A6)
	CMP.W	#$40,$12(A6)
	BMI.S	VolUpOk
	MOVE.W	#$40,$12(A6)
VolUpOk	MOVE.W	$12(A6),$8(A5)
	RTS
VolumeDown
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	AND.B	#$F,D0
	SUB.W	D0,$12(A6)
	BPL.S	VolDwnOk
	CLR.W	$12(A6)
VolDwnOk
	MOVE.W	$12(A6),$8(A5)
	RTS
CheckCommand2
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	CMP.B	#$B,D0
	BEQ.S	PositionJump
	CMP.B	#$C,D0
	BEQ.S	SetVolume
	CMP.B	#$D,D0
	BEQ.S	PatternBreak
	CMP.B	#$E,D0
	BEQ.S	SetFilter
	CMP.B	#$F,D0
	BEQ.S	SetSpeed
	RTS
PositionJump
	MOVE.B	$3(A6),D0
	SUBQ.B	#$1,D0
	MOVE.B	D0,SongPos(A4)
	NOT.B	Break(A4)
	RTS
SetVolume
	CMP.B	#$40,$3(A6)
	BLE.S	VolumeOk
	MOVE.B	#$40,$3(A6)
VolumeOk
	MOVE.B	$3(A6),$13(A6)
	MOVE.B	$3(A6),$9(A5)
	RTS
PatternBreak
	NOT.B	Break(A4)
	RTS
SetFilter
	RTS
SetSpeed
	MOVE.B	$3(A6),D0
	AND.W	#$1F,D0
	BEQ.S	NoChangeSpeed
	CLR.B	Counter(A4)
	MOVE.B	D0,Speed(A4)
NoChangeSpeed
	RTS


PrecalcDigit
	MOVEM.L	D0-A6,-(SP)
	LEA	Volume(PC),A3
	LEA	VoicesBuffer+1020*0(PC),A5
	LEA	Chip0(PC),A6
	BSR	CalcVoice
	LEA	VoicesBuffer+1020*1(PC),A5
	LEA	Chip1(PC),A6
	BSR	CalcVoice
	LEA	VoicesBuffer+1020*2(PC),A5
	LEA	Chip2(PC),A6
	BSR	CalcVoice
	LEA	VoicesBuffer+1020*3(PC),A5
	LEA	Chip3(PC),A6
	BSR	CalcVoice

	LEA	VoicesBuffer(PC),A0
	LEA	1020(A0),A1
	LEA	1020(A1),A2
	LEA	1020(A2),A3
	LEA	DigitSwap(PC),A4
	MOVE.L	4(A4),A4

	MOVE.W	Output(PC),D0
	CMP.W	#$00,D0
	BEQ	MixSTf
	CMP.W	#$01,D0
	BEQ	MixSTf1
	CMP.W	#$20,D0
	BEQ	MixStReplay
	CMP.W	#$21,D0
	BEQ	MixStReplayPro
	CMP.W	#$22,D0
	BEQ	MixPlayBack
	CMP.W	#$24,D0
	BEQ	MixProSound
	MOVEM.L	(SP)+,D0-A6
	RTS

CalcVoice
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHigh,D0
	MOVE.L	#FrqLow,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVEQ	#FrqLoop,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
MixSTf	MOVEQ	#0,D1
	MOVE.W	#$7F8,D2
	MOVEQ	#FrqLoop,D3
.Mix	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	AND.W	D2,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	AND.W	D2,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	AND.W	D2,D0
	MOVE.W	D0,(A4)+
	DBRA	D3,.Mix
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVEM.L	(SP)+,D0-A6
	RTS
MixSTf1	MOVEQ	#0,D1
	MOVEQ	#FrqLoop,D3
.Mix	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	MOVE.W	D0,(A4)+
	DBRA	D3,.Mix
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVEM.L	(SP)+,D0-A6
	RTS
MixStReplay
	MOVEQ	#0,D1
	MOVEQ	#FrqLoop,D3
.Mix	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	MOVE.W	D0,(A4)+
	DBRA	D3,.Mix
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVEM.L	(SP)+,D0-A6
	RTS
MixStReplayPro
	MOVEQ	#0,D1
	MOVEQ	#FrqLoop,D3
.Mix	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.W	D0,(A4)+
	DBRA	D3,.Mix
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVEM.L	(SP)+,D0-A6
	RTS
MixPlayBack
	MOVEQ	#0,D1
	MOVEQ	#FrqLoop,D3
.Mix	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	SWAP	D0
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.L	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	SWAP	D0
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.L	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	SWAP	D0
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.L	D0,(A4)+
	DBRA	D3,.Mix
	MOVE.L	D0,(A4)+
	MOVE.L	D0,(A4)+
	MOVE.L	D0,(A4)+
	MOVE.L	D0,(A4)+
	MOVEM.L	(SP)+,D0-A6
	RTS
MixProSound
	MOVEQ	#0,D1
	MOVEQ	#FrqLoop,D3
.Mix	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	#2,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	#2,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.B	(A1)+,D1
	ADD.W	D1,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	#2,D0
	MOVE.W	D0,(A4)+
	DBRA	D3,.Mix
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVEM.L	(SP)+,D0-A6
	RTS

PrecalcDigitDma
	MOVEM.L	D0-A6,-(SP)
	MOVE.W	Output(PC),D0
	CMP.W	#$10,D0
	BEQ	Calc12KHz
	CMP.W	#$11,D0
	BEQ	Calc25KHz7bits
	CMP.W	#$12,D0
	BEQ	Calc50KHz
	CMP.W	#$13,D0
	BEQ	Calc50KHz7bits
	CMP.W	#$14,D0
	BEQ	Calc25KHz
	MOVEM.L	(SP)+,D0-A6
	RTS
Calc12KHz
	LEA	Volume(PC),A3
	LEA	VoicesBuffer+1020*0(PC),A5
	LEA	Chip0(PC),A6
	BSR	CalcVoice12KHz
	LEA	VoicesBuffer+1020*1(PC),A5
	LEA	Chip1(PC),A6
	BSR	CalcVoice12KHz
	LEA	VoicesBuffer+1020*2(PC),A5
	LEA	Chip2(PC),A6
	BSR	CalcVoice12KHz
	LEA	VoicesBuffer+1020*3(PC),A5
	LEA	Chip3(PC),A6
	BSR	CalcVoice12KHz
	LEA	VoicesBuffer(PC),A0
	LEA	1020(A0),A1
	LEA	1020(A1),A2
	LEA	1020(A2),A3
	LEA	DigitSwap(PC),A4
	MOVE.L	4(A4),A4
	BSR	Mix12KHz
	MOVEM.L	(SP)+,D0-A6
	RTS
CalcVoice12KHz
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#249/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
Mix12KHz
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	#$80,D2
	MOVEQ	#249/3-1,D3
.Mix	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	DBRA	D3,.Mix
	RTS
Calc25KHz
	LEA	Volume(PC),A3
	LEA	VoicesBuffer+1020*0(PC),A5
	LEA	Chip0(PC),A6
	BSR	CalcVoice25KHz
	LEA	VoicesBuffer+1020*1(PC),A5
	LEA	Chip1(PC),A6
	BSR	CalcVoice25KHz
	LEA	VoicesBuffer+1020*2(PC),A5
	LEA	Chip2(PC),A6
	BSR	CalcVoice25KHz
	LEA	VoicesBuffer+1020*3(PC),A5
	LEA	Chip3(PC),A6
	BSR	CalcVoice25KHz
	LEA	VoicesBuffer(PC),A0
	LEA	1020(A0),A1
	LEA	1020(A1),A2
	LEA	1020(A2),A3
	LEA	DigitSwap(PC),A4
	MOVE.L	4(A4),A4
	BSR	Mix25KHz
	MOVEM.L	(SP)+,D0-A6
	RTS
CalcVoice25KHz
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#501/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
Mix25KHz
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	#$80,D2
	MOVE.W	#501/3-1,D3
.Mix	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	DBRA	D3,.Mix
	RTS
Calc50KHz
	LEA	Volume(PC),A3
	LEA	VoicesBuffer+1020*0(PC),A5
	LEA	Chip0(PC),A6
	BSR	CalcVoice50KHz
	LEA	VoicesBuffer+1020*1(PC),A5
	LEA	Chip1(PC),A6
	BSR	CalcVoice50KHz
	LEA	VoicesBuffer+1020*2(PC),A5
	LEA	Chip2(PC),A6
	BSR	CalcVoice50KHz
	LEA	VoicesBuffer+1020*3(PC),A5
	LEA	Chip3(PC),A6
	BSR	CalcVoice50KHz
	LEA	VoicesBuffer(PC),A0
	LEA	1020(A0),A1
	LEA	1020(A1),A2
	LEA	1020(A2),A3
	LEA	DigitSwap(PC),A4
	MOVE.L	4(A4),A4
	BSR	Mix50KHz
	MOVEM.L	(SP)+,D0-A6
	RTS
CalcVoice50KHz
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	#2,D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#1002/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
Mix50KHz
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	#$80,D2
	MOVE.W	#1002/3-1,D3
.Mix	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A0)+,D0
	MOVE.B	(A3)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A1)+,D0
	MOVE.B	(A2)+,D1
	ADD.W	D1,D0
	LSR.W	D0
	EOR.W	D2,D0
	MOVE.B	D0,(A4)+
	DBRA	D3,.Mix
	RTS
Calc25KHz7bits
	MOVE.L	DigitSwap+4(PC),A1
	LEA	Chip1(PC),A6
	MOVE.L	A1,A5
	BSR	CalcVoiceSte0
	LEA	Chip2(PC),A6
	MOVE.L	A1,A5
	BSR	CalcVoiceSte3
	LEA	Chip0(PC),A6
	MOVE.L	A1,A5
	BSR	CalcVoiceSte1
	LEA	Chip3(PC),A6
	MOVE.L	A1,A5
	BSR	CalcVoiceSte2
	MOVEM.L	(SP)+,D0-A6
	RTS
CalcVoiceSte0
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	NewVolumeTable(PC),A3
	LEA	(A3,D4.W),A3
	MOVEQ	#0,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#501/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	MOVE.W	D4,(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	MOVE.W	D4,(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	MOVE.W	D4,(A5)+
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
CalcVoiceSte1
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	NewVolumeTable(PC),A3
	LEA	(A3,D4.W),A3
	MOVEQ	#0,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#501/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),2(A5)
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),4(A5)
	ADDQ.L	#6,A5
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
CalcVoiceSte2
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	NewVolumeTable(PC),A3
	LEA	(A3,D4.W),A3
	MOVEQ	#0,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#501/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.B	D4,(A5)
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.B	D4,2(A5)
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.B	D4,4(A5)
	ADDQ.L	#6,A5
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
CalcVoiceSte3
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	NewVolumeTable(PC),A3
	LEA	(A3,D4.W),A3
	MOVEQ	#0,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#501/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.W	D4,(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.W	D4,(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.W	D4,(A5)+
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
Calc50KHz7bits
	MOVE.L	DigitSwap+4(PC),A1
	LEA	Chip1(PC),A6
	MOVE.L	A1,A5
	BSR	CalcVoiceDma50KHz7bits0
	LEA	Chip2(PC),A6
	MOVE.L	A1,A5
	BSR	CalcVoiceDma50KHz7bits3
	LEA	Chip0(PC),A6
	MOVE.L	A1,A5
	BSR	CalcVoiceDma50KHz7bits1
	LEA	Chip3(PC),A6
	MOVE.L	A1,A5
	BSR	CalcVoiceDma50KHz7bits2
	MOVEM.L	(SP)+,D0-A6
	RTS
CalcVoiceDma50KHz7bits0
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	NewVolumeTable(PC),A3
	LEA	(A3,D4.W),A3
	MOVEQ	#0,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	#2,D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#1002/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	MOVE.W	D4,(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	MOVE.W	D4,(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	MOVE.W	D4,(A5)+
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
CalcVoiceDma50KHz7bits1
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	NewVolumeTable(PC),A3
	LEA	(A3,D4.W),A3
	MOVEQ	#0,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	#2,D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#1002/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),2(A5)
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),4(A5)
	ADDQ.L	#6,A5
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
CalcVoiceDma50KHz7bits2
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	NewVolumeTable(PC),A3
	LEA	(A3,D4.W),A3
	MOVEQ	#0,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	#2,D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#1002/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.B	D4,(A5)
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.B	D4,2(A5)
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.B	D4,4(A5)
	ADDQ.L	#6,A5
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
CalcVoiceDma50KHz7bits3
	MOVE.L	$0(A6),A0
	MOVE.L	$4(A6),D3
	MOVE.W	$8(A6),D4
	LSL.W	#$8,D4
	MOVE.L	NewVolumeTable(PC),A3
	LEA	(A3,D4.W),A3
	MOVEQ	#0,D4
	MOVE.L	$10(A6),D6
	MOVEQ	#0,D7
	MOVE.W	$A(A6),D7
	BEQ.S	.1
	MOVE.L	#FrqHighDma,D0
	MOVE.L	#FrqLowDma,D1
	SWAP	D1
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	MOVE.L	D0,D7
	LSR.L	#2,D7
.1	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
	MOVE.W	D7,D2
	SWAP	D7
	TST.L	D6
	BNE.S	.0
	CLR.L	D7
.0	MOVE.L	$C(A6),A2
	MOVEQ	#0,D1
	MOVE.W	#1002/3-1,D5
.Paula	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R1
.Rr1	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.W	D4,(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.Rr2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.W	D4,(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.Rr3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),D4
	ADD.W	D4,(A5)+
	DBRA	D5,.Paula
	BRA.S	.EndOfCalcVoice
.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.Rr3
.EndOfCalcVoice
	MOVE.L	A0,$0(A6)
	MOVE.L	D3,$4(A6)
	RTS
************************************************************
* Data Field.                                              *
************************************************************
* Data: parameters
ModuleAddress
	DC.L	0
Output
	DC.W	0
NewVolumeTable	DC.L	0
MwParameters
	DC.W	%10101010100,%10100010100,%10010000110,%10001000110,%10011101000,%10000000000,0
* Data: interrupts
Vectors	EQU	*
Vbl	EQU	*-Vectors
	DC.L	0
Timera	EQU	*-Vectors
	DC.L	0
Timerb	EQU	*-Vectors
	DC.L	0
Timerc	EQU	*-Vectors
	DC.L	0
Timerd	EQU	*-Vectors
	DC.L	0
VideoRegisters	EQU	*-Vectors
	DCB.L	9,0
YamahaRegisters	EQU	*-Vectors
	DC.L	0,0,0,0
DmaSte	EQU	*-Vectors
	DC.W	0,0,0,0,0,0,0
MwResetState	DC.W	%10011101000,%10101010100,%10100010100,%10010000110,%10001000110,%10000000001
Flags		EQU	*-Vectors
FlagTT		EQU	*-Flags-Vectors
		DC.B	0
FlagSoundchip	EQU	*-Flags-Vectors
		DC.B	0
FlagDma		EQU	*-Flags-Vectors
		DC.B	0
FlagVolume7bits	EQU	*-Flags-Vectors
		DC.B	0
FlagCartridge	EQU	*-Flags-Vectors
		DC.B	0
* Data: player
	ifge	FrqPlayer-4
	fail	FrqPlayer<3
	endc
	ifeq	FrqPlayer-0
FrqData	EQU	82
FrqLoop	EQU	49
FrqHigh	EQU	$1DD
FrqLow	EQU	$BD2C
	endc
	ifeq	FrqPlayer-1
FrqData	EQU	72
FrqLoop	EQU	56
FrqHigh	EQU	$1A3
FrqLow	EQU	$7A64
	endc
	ifeq	FrqPlayer-2
FrqData	EQU	61
FrqLoop	EQU	66
FrqHigh	EQU	$163
FrqLow	EQU	$6424
	endc
	ifeq	FrqPlayer-3
FrqData	EQU	49
FrqLoop	EQU	82
FrqHigh	EQU	$11E
FrqLow	EQU	$5D1D
	endc
FrqHighDma	EQU	$11E
FrqLowDma	EQU	$5D1D
Switch	DC.W	0
Offset
Speed	EQU	*-Offset
	DC.W	0
SongPos	EQU	*-Offset
	DC.W	0
PattPos	EQU	*-Offset
	DC.W	0
Counter	EQU	*-Offset
	DC.W	0
Break	EQU	*-Offset
	DC.W	0
Pos	EQU	*-Offset
	DC.W	0
Patt	EQU	*-Offset
	DC.W	0
NbrIns	EQU	*-Offset
	DC.W	0
Sinus
 DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
 DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18
Periods
 DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
 DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$00FE
 DC.W $00F0,$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097,$008F,$0087
 DC.W $007F,$0078,$0071,$0000,$0000
NoIns	DC.L	$80808080
Voices	DCB.L	$1C,0
Voice0	EQU	Voices+$1C*0
Voice1	EQU	Voices+$1C*1
Voice2	EQU	Voices+$1C*2
Voice3	EQU	Voices+$1C*3
Chip	DCB.L	$18,0
Chip0	EQU	Chip+$18*0
Chip1	EQU	Chip+$18*1
Chip2	EQU	Chip+$18*2
Chip3	EQU	Chip+$18*3
SampleStarts	DCB.L	$20,0
VoiceOff	DCB.B	1020,$0
VoicesBuffer	DCB.L	1020,$0
DigitBuffer	DCB.W	2040,$0
DigitSwap	DC.L	0,0
Volume	INCBIN	volume.cnx
