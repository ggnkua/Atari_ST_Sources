clavier:
			Move.w	#$2700,SR
			Lea	DataOffset(PC),A6
	* Ikbd Setup Routine
			Lea	Boot(A6),A0
			Move.w	#BootLen-1,D0
			Bsr.s	WriteToIkbd
			Lea	PauseOutput(A6),A0
			Moveq	#$0,D0
			Bsr.s	WriteToIkbd
			Lea	ControllerExecute(A6),A0
			Moveq	#$2,D0
			Bsr.s	WriteToIkbd
			Lea	Loader(A6),A1
			Moveq	#$FF-$BA,D1
SendLoader			Lea	0(A1,D1.w),A0
			Moveq	#$0,D0
			Bsr.s	WriteToIkbd
			Dbra	D1,SendLoader
			Lea	Program(A6),A1
			Moveq	#ProgramLen-1,D1
SendProgram		Lea	0(A1,D1.w),A0
			Moveq	#$0,D0
			Bsr.s	WriteToIkbd
			Dbra	D1,SendProgram
			move.w	#$2300,sr
			rts

WriteToIkbd
			Btst	#1,$FFFFFC00.w
			Beq.s	WriteToIkbd
			Move.b	(A0)+,$FFFFFC02.W
			Dbra	D0,WriteToIkbd
			Rts

	* FFFFFC02.w now reads:
	* Bit 7:	Fire
	* Bit 6:	Help
	* Bit 3:	Right
	* Bit 2:	Left
	* Bit 1:	Down
	* Bit 0:	Up

DataOffset			Equ	*
PauseOutput		Equ	*-DataOffset
			Dc.b	$13
ControllerExecute		Equ	*-DataOffset
			Dc.b	$22,$00,$B0
Boot			Equ	*-DataOffset
			Dc.b	$20,$00,$B0,$0B
			Dc.b	$0F			*B0		Sei
			Dc.b	$BE,$F9,$A1		*B1		LdS	$F9A1
			Dc.b	$DC,$11			*B4	Ready	LdD	$11
			Dc.b	$2A,$FC			*B6		Bpl	RDY
			Dc.b	$37			*B8		PshB
			Dc.b	$20,$F9			*B9		Bra	Ready
BootLen			Equ	(*-DataOffset)-Boot
Loader			Equ	*-DataOffset
			Dc.b	$00
			Dc.b	$DC,$B4			*BB		LdD	$B4
			Dc.b	$DD,$80			*BD		StD	$80
			Dc.b	$DC,$B6			*BF		LdD	$B6
			Dc.b	$DD,$82			*C1		StD	$82
			Dc.b	$DC,$B8			*C3		LdD	$B8
			Dc.b	$DD,$84			*C5		StD	$84
			Dc.b	$86,$F9			*C7		LdaA	#$F9
			Dc.b	$97,$86			*C9		StaA	$86
			Dc.b	$CC,$00,$01		*CB		LdD	#$0001
			Dc.b	$DD,$00			*CE		StD	$00
			Dc.b	$CC,$FF,$FF		*D0		LdD	#$FFFF
			Dc.b	$DD,$04			*D3		StD	$04
			Dc.b	$D7,$06			*D5		StaB	$06
			Dc.b	$8E,$00,ProgramLen+$85	*D7		LdS	#$85+ProgramLen
			Dc.b	$7E,$00,$80		*DA		Jmp	$0080
LoaderLen		Equ	(*-DataOffset)-Loader
			Ds.b	80-((LoaderLen-1)+(BootLen-4))
Program			Equ	*-DataOffset
			Dc.b	$00
Ok			Dc.b	$CC,$FF,$DF		*87	Ok	LdD	#$FFDF
			Dc.b	$97,$03			*		StaA	$03
			Dc.b	$97,$05			*		StaA	$05
			Dc.b	$DD,$06			*		StD	$06
			Dc.b	$96,$02			*		LdaA	$02
			Dc.b	$5F			*		ClrB
Up			Dc.b	$85,$02			*	Up	BitA	#$02
			Dc.b	$26,Down-(*+2)		*		Bne	Down
			Dc.b	$CA,$01			*		OraB	#$02
Down			Dc.b	$85,$10			*	Down	BitA	#$10
			Dc.b	$26,Left-(*+2)		*		Bne	Left
			Dc.b	$CA,$02			*		OraB	#$02
Left			Dc.b	$85,$08			*	Left	BitA	#$08
			Dc.b	$26,Right-(*+2)		*		Bne	Right
			Dc.b	$CA,$04			*		OraB	#$04
Right			Dc.b	$85,$20			*	Right	BitA	#$20
			Dc.b	$26,Help-(*+2)		*		Bne	Help
			Dc.b	$CA,$08			*		OraB	#$08
Help			Dc.b	$86,$EF			*	Help	LdaA	#$EF
			Dc.b	$97,$07			*		StaA	$07
			Dc.b	$96,$02			*		LdaA	$02
			Dc.b	$85,$01			*		BitA	#$02
			Dc.b	$26,Fire-(*+2)		*		Bne	Fire
			Dc.b	$CA,$40			*		OraB	#$40
Fire			Dc.b	$86,$FB			*	Fire	LdaA	#$FB
			Dc.b	$97,$07			*		StaA	$07
			Dc.b	$96,$02			*		LdaA	$02
			Dc.b	$2B,Joy-(*+2)		*		Bmi	Joy
			Dc.b	$CA,$80			*		OraB	#$80
Joy			Dc.b	$D7,$80			*	Joy	StaB	$80
			Dc.b	$86,$FE			*		LdaA	#$FE
			Dc.b	$97,$03			*		StaA	$03
			Dc.b	$4F			*		ClrA
			Dc.b	$97,$05			*		StaA	$05
			Dc.b	$96,$07			*		LdaA	$07
			Dc.b	$43			*		NotA
			Dc.b	$44			*		LsrA
			Dc.b	$44			*		LsrA
			Dc.b	$44			*		LsrA
			Dc.b	$44			*		LsrA
			Dc.b	$84,$0F			*		AndA	#$0F
			Dc.b	$7B,$04,$03		*		Bit	#$04,$03
			Dc.b	$26,Out-(*+2)		*		Bne	Out
			Dc.b	$8A,$80			*		OraA	#$80
Out			Dc.b	$9A,$80			*	Out	OraA	$80
Cts?			Dc.b	$7B,$20,$11		*	Cts?	Bit	#$20,$11
			Dc.b	$27,Cts?-(*+2)		*		Beq	Cts?
			Dc.b	$97,$13			*		StaA	$13
			Dc.b	$20,Ok-(*+2)		*		Bra	Ok
ProgramLen		Equ	(*-DataOffset)-Program
