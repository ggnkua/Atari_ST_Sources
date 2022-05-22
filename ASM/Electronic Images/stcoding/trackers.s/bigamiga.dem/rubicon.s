; Rubicon Driver (Amiga)

RUBYMUSIC	JMP	L22D94(PC)	;PAL/NTSC select
		JMP	L22F2E(PC)	;Vbl Sequencer
		JMP	L22E38(PC)	;Initialise/Fadeout etc.

L22D94		LEA	mus_vars(PC),A5
		BCLR	#0,$19A(A5)
		TST.B	D0
		BEQ.S	L22DAA
		BSET	#1,$19A(A5)
		BRA.S	L22DB0
L22DAA		BCLR	#1,$19A(A5)
L22DB0		LEA	0(A5),A1
		LEA	L23166(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L23072(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L2306A(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L23096(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L230C2(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L2311E(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L23144(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L23044(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L23062(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L23020(PC),A0
		MOVE.L	A0,(A1)+
		LEA	$28(A5),A1
		LEA	L2319A(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L231A6(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L231C0(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L231DA(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L231A0(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L2321C(PC),A0
		MOVE.L	A0,(A1)+
		LEA	L231EE(PC),A0
		MOVE.L	A0,(A1)+
		LEA	musdata(PC),A0
		MOVE.L	A0,$19C(A5)
		MOVEQ	#0,D0
		MOVE.B	$1AC(A5),D0
		MULU	#$C,D0
		ADDA.W	D0,A0
		MOVE.L	A0,$1A0(A5)
		RTS
L22E38		LEA	mus_vars(PC),A5
		ANDI.L	#$FF,D0
		BEQ	L22F02
		BCLR	#0,$19A(A5)
		SUBQ.B	#1,D0
		CMP.B	$1AC(A5),D0
		BGE	L22F00
		MULU	#$C,D0
		LEA	musdata(PC),A0
		ADDA.W	D0,A0
L22E78		CLR.B	$44(A5)
		CLR.B	$46(A5)
		MOVE.B	8(A0),$45(A5)
		MOVE.B	8(A0),$1B1(A5)
		MOVE.B	$A(A0),$47(A5)
		CLR.B	$1AD(A5)
		TST.B	D1
		BEQ.S	L22EB2
		MOVE.B	#1,$1AD(A5)
		MOVE.B	D1,$1AE(A5)
		MOVE.B	D1,$1AF(A5)
		CLR.B	$45(A5)
		MOVE.B	$1B1(A5),$1B0(A5)
L22EB2		LEA	$48(A5),A1
		MOVE.W	#6,D0
		MOVE.W	#$FC,D1
		MOVE.W	#$F,D6
		MOVEQ	#3,D7
L22EC4		LEA	musdata(PC),A2
		TST.W	0(A0,D0.W)
		BNE.S	L22ED0
		BCLR	D7,D6
L22ED0		ADDA.W	0(A0,D0.W),A2
		MOVE.L	A2,0(A1,D1.W)
		MOVE.L	A2,4(A1,D1.W)
		MOVE.B	#1,$3D(A1,D1.W)
		CLR.B	$3F(A1,D1.W)
		MOVE.B	#1,$44(A1,D1.W)
		SUBQ.B	#2,D0
		SUBI.W	#$54,D1
		DBF	D7,L22EC4
		MOVE.B	D6,$198(A5)
		BSET	#0,$19A(A5)
L22F00		RTS
L22F02		TST.B	D1
		BNE.S	L22F1A
		MOVEQ	#0,D0
		MOVE.B	$198(A5),D0
		move_dmacon D0
		BCLR	#0,$19A(A5)
		RTS
L22F1A		MOVE.B	#$FF,$1AD(A5)
		MOVE.B	D1,$1AE(A5)
		MOVE.B	D1,$1AF(A5)
		CLR.B	$1B0(A5)
		RTS
L22F2E		LEA	mus_vars(PC),A5
		BTST	#0,$19A(A5)
		BEQ	L2341E
		BTST	#1,$19A(A5)
		BEQ.S	L22F54
		SUBQ.B	#1,$19B(A5)
		BNE.S	L22F54
		MOVE.B	#6,$19B(A5)
		BRA	L2341E
L22F54		MOVEQ	#3,D7
		LEA	$144(A5),A0
		MOVEA.L	$19C(A5),A4
		LEA ch4s,A6
L22F64		BTST	D7,$198(A5)
		BEQ	L233D2
		TST.B	$44(A0)
		BNE	L23160
		MOVEA.L	$10(A0),A1
		SUBQ.W	#1,$24(A0)
		BNE	L23228
L22F80		MOVEA.L	$C(A0),A2
L22F84		MOVEQ	#0,D2
		MOVE.B	(A2)+,D2
		BPL.S	L22F98
		ANDI.B	#$F,D2
		ADD.B	D2,D2
		ADD.B	D2,D2
		MOVEA.L	0(A5,D2.W),A3
		JMP	(A3)
L22F98		ADD.B	$3F(A0),D2
		MOVE.B	D2,$3E(A0)
		ADD.W	D2,D2
		LEA	$1B2(A5),A3
		MOVE.W	0(A3,D2.W),D2
		MULU	2(A1),D2
		LSR.L	#8,D2
		LSR.L	#2,D2
		MOVE.W	D2,$1E(A0)
		MOVE.W	D2,$2E(A0)
		MOVEQ	#0,D2
		MOVE.B	(A2)+,D2
		MULU	$46(A5),D2
		MOVEQ	#0,D0
		MOVE.B	$53(A0),D0
		SUB.W	D0,D2
		CLR.B	$53(A0)
		MOVE.W	D2,$24(A0)
		MOVE.B	#1,$4A(A0)
		MOVE.B	#1,$4B(A0)
		CLR.B	$49(A0)
		MOVE.B	#1,$4D(A0)
		CLR.B	$4C(A0)
		CLR.W	$32(A0)
		MOVE.B	$12(A1),$45(A0)
		MOVE.B	#1,$47(A0)
		CLR.B	$46(A0)
		CLR.W	$34(A0)
		MOVE.B	#2,$40(A0)
		BSET	D7,$199(A5)
		MOVEQ	#0,D0
		BSET	D7,D0
		move_dmacon D0
		MOVE.L	A2,$C(A0)
		BRA	L233D2
L23020		MOVEQ	#0,D2
		MOVE.B	(A2)+,D2
		MULU	$46(A5),D2
		MOVEQ	#0,D0
		MOVE.B	$53(A0),D0
		SUB.W	D0,D2
		CLR.B	$53(A0)
		MOVE.W	D2,$24(A0)
		CLR.B	$4B(A0)
		MOVE.L	A2,$C(A0)
		BRA	L233D2
L23044		MOVEQ	#0,D2
		MOVE.B	(A2)+,D2
		MOVE.W	D2,$24(A0)
		BCLR	D7,$199(A5)
		MOVEQ	#0,D0
		BSET	D7,D0
		move_dmacon D0
		MOVE.L	A2,$C(A0)
		BRA	L233D2
L23062		MOVE.B	(A2)+,$53(A0)
		BRA	L22F84
L2306A		MOVE.B	(A2)+,$1D(A0)
		BRA	L22F84
L23072		MOVE.B	(A2)+,D2
		LSL.W	#6,D2
		MOVEA.L	$1A0(A5),A1
		ADDA.W	D2,A1
		MOVE.L	A1,$10(A0)
		MOVE.B	#1,$3C(A0)
		MOVE.B	$E(A1),$1D(A0)
		MOVE.W	$14(A1),$30(A0)
		BRA	L22F84
L23096		MOVE.B	(A2)+,D2
		ADD.B	$3F(A0),D2
		ADD.W	D2,D2
		LEA	$1B2(A5),A3
		MOVE.W	0(A3,D2.W),D2
		MULU	2(A1),D2
		LSR.L	#8,D2
		LSR.L	#2,D2
		MOVE.W	D2,$2A(A0)
		MOVEQ	#0,D2
		MOVE.B	(A2)+,D2
		MULU	$46(A5),D2
		MOVE.W	D2,$26(A0)
		BRA	L22F84
L230C2		MOVE.B	(A2)+,D2
		ADD.B	$3F(A0),D2
		ADD.W	D2,D2
		LEA	$1B2(A5),A3
		MOVE.W	0(A3,D2.W),D2
		MULU	2(A1),D2
		LSR.L	#8,D2
		LSR.L	#2,D2
		MOVE.W	$1E(A0),$2A(A0)
		MOVE.W	D2,$1E(A0)
		MOVE.W	D2,$2E(A0)
		MOVEQ	#0,D2
		MOVE.B	(A2)+,D2
		MULU	$46(A5),D2
		MOVE.W	D2,$26(A0)
		MOVEQ	#0,D2
		MOVE.B	(A2)+,D2
		MULU	$46(A5),D2
		MOVEQ	#0,D0
		MOVE.B	$53(A0),D0
		SUB.W	D0,D2
		CLR.B	$53(A0)
		MOVE.W	D2,$24(A0)
		MOVE.B	#3,$40(A0)
		BSET	D7,$199(A5)
		MOVE.L	A2,$C(A0)
		BRA	L233D2
L2311E		MOVE.B	(A2)+,D2
		MULU	$46(A5),D2
		MOVEQ	#0,D0
		MOVE.B	$53(A0),D0
		SUB.W	D0,D2
		CLR.B	$53(A0)
		MOVE.W	D2,$24(A0)
		CLR.W	sam_vol(A6)
		BCLR	D7,$199(A5)
		MOVE.L	A2,$C(A0)
		BRA	L233D2
L23144		MOVE.B	#1,$4D(A0)
		CLR.B	$4C(A0)
		CLR.W	$32(A0)
		MOVE.B	(A2)+,D2
		LSL.W	#8,D2
		MOVE.B	(A2)+,D2
		MOVE.W	D2,$30(A0)
		BRA	L22F84
L23160		CLR.B	$44(A0)
		BRA.S	L23172
L23166		SUBQ.B	#1,$3D(A0)
		BNE.S	L23190
		MOVE.B	#1,$3D(A0)
L23172		MOVEA.L	4(A0),A2
L23176		MOVEQ	#0,D2
		MOVE.W	(A2)+,D2
		CMPI.W	#$F000,D2
		BCS.S	L231AC
		MOVEQ	#0,D0
		MOVE.B	D2,D0
		ANDI.W	#$F00,D2
		LSR.W	#6,D2
		MOVEA.L	$28(A5,D2.W),A3
		JMP	(A3)
L23190		MOVE.L	8(A0),$C(A0)
		BRA	L22F80
L2319A		MOVE.B	D0,$3F(A0)
		BRA.S	L23176
L231A0		MOVE.B	D0,$47(A5)
		BRA.S	L23176
L231A6		MOVE.B	D0,$3D(A0)
		BRA.S	L23176
L231AC		MOVEA.L	A4,A3
		ADDA.W	D2,A3
		MOVE.L	A3,8(A0)
		MOVE.L	A3,$C(A0)
		MOVE.L	A2,4(A0)
		BRA	L22F80
L231C0		MOVE.B	#1,$1AD(A5)
		MOVE.B	D0,$1AE(A5)
		MOVE.B	D0,$1AF(A5)
		CLR.B	$45(A5)
		MOVE.B	$1B1(A5),$1B0(A5)
		BRA.S	L23176
L231DA		MOVE.B	#$FF,$1AD(A5)
		MOVE.B	D0,$1AE(A5)
		MOVE.B	D0,$1AF(A5)
		CLR.B	$1B0(A5)
		BRA.S	L23176
L231EE		BCLR	#0,$19A(A5)
		MOVEQ	#3,D7
		LEA	ch4s+sam_vol,A6
L231FC		BTST	D7,$19A(A5)
		BEQ.S	L23208
		CLR.W	(A6)
		LEA	-sam_vcsize(A6),A6
L23208		DBF	D7,L231FC
		MOVE.B	(A5),D0
		ANDI.W	#$F,D0
		move_dmacon D0
		BRA	L2341E
L2321C		ADD.W	D0,D0
		MOVEA.L	0(A0),A2
		ADDA.W	D0,A2
		BRA	L23176
L23228		BTST	D7,$199(A5)
		BEQ	L233D2
		SUBQ.B	#1,$4A(A0)
		BNE.S	L23288
		MOVE.B	$F(A1),$4A(A0)
		MOVEA.L	A4,A2
		ADDA.W	$C(A1),A2
		MOVEQ	#0,D0
		MOVEQ	#0,D2
		MOVE.B	$49(A0),D2
L2324A		MOVE.B	0(A2,D2.W),D0
		CMPI.B	#$81,D0
		BEQ.S	L23266
		CMPI.B	#$80,D0
		BNE.S	L23274
L2325A		MOVE.B	1(A2,D2.W),D0
		SUB.B	D0,D2
		SUB.B	D0,$49(A0)
		BRA.S	L2324A
L23266		TST.B	$4B(A0)
		BNE.S	L2325A
		ADDQ.B	#2,$49(A0)
		ADDQ.W	#2,D2
		BRA.S	L2324A
L23274		ADDQ.B	#1,$49(A0)
		MULU	$1C(A0),D0
		LSR.W	#6,D0
		MULU	$44(A5),D0
		LSR.W	#6,D0
		MOVE.W	D0,$20(A0)
L23288		TST.W	$26(A0)
		BEQ.S	L232E6
		CMPI.B	#3,$40(A0)
		BNE.S	L2329C
		CLR.B	$40(A0)
		BRA.S	L232A4
L2329C		CMPI.B	#2,$40(A0)
		BNE.S	L232BC
L232A4		MOVE.W	#1,$28(A0)
		MOVE.W	$2A(A0),D2
		MOVE.W	D2,$2E(A0)
		SUB.W	$1E(A0),D2
		MOVE.W	D2,$2C(A0)
		BRA.S	L232E6
L232BC		MOVE.W	$28(A0),D2
		MULS	$2C(A0),D2
		DIVS	$26(A0),D2
		MOVE.W	$2A(A0),D0
		SUB.W	D2,D0
		MOVE.W	D0,$2E(A0)
		MOVE.W	$28(A0),D2
		CMP.W	$26(A0),D2
		BNE.S	L232E2
		CLR.W	$26(A0)
		BRA.S	L232E6
L232E2		ADDQ.W	#1,$28(A0)
L232E6		MOVE.W	$2E(A0),D0
		ADD.W	$32(A0),D0
		MOVE.W	D0,$22(A0)
		TST.W	$10(A1)
		BEQ.S	L23348
		TST.B	$45(A0)
		BEQ.S	L23304
		SUBQ.B	#1,$45(A0)
		BRA.S	L23348
L23304		SUBQ.B	#1,$47(A0)
		BNE.S	L23348
		MOVE.B	$13(A1),$47(A0)
		MOVEA.L	A4,A2
		ADDA.W	$10(A1),A2
		MOVEQ	#0,D0
		MOVEQ	#0,D2
		MOVE.B	$46(A0),D2
L2331E		MOVE.B	0(A2,D2.W),D0
		CMPI.B	#$80,D0
		BNE.S	L23334
		MOVE.B	1(A2,D2.W),D0
		SUB.B	D0,D2
		SUB.B	D0,$46(A0)
		BRA.S	L2331E
L23334		ADDQ.B	#1,$46(A0)
		MOVE.W	$22(A0),D1
		LSR.W	#7,D1
		NEG.B	D0
		EXT.W	D0
		MULS	D1,D0
		MOVE.W	D0,$34(A0)
L23348		MOVE.W	$34(A0),D0
		ADD.W	D0,$22(A0)
		TST.B	0(A1)
		BEQ	L233B6
		TST.B	$40(A0)
		BEQ	L233B6
		SUBQ.B	#1,$40(A0)
		BEQ.S	L23382
		MOVEA.L	A4,A2
		ADDA.L	4(A1),A2
		MOVE.L	A2,sam_start(A6)
		MOVEQ.L #0,D0
		MOVE.W	8(A1),D0
		ADD.L	D0,D0
		ADD.L	D0,sam_start(A6)
		MOVE.W	D0,sam_length(A6)
		MOVE.W	#$8200,D0
		BSET	D7,D0
		move_dmacon D0
		BRA	L233B6
L23382		MOVE.W	$A(A1),D2
		CMPI.W	#$FFFF,D2
		BEQ.S	L233A6
		MOVEA.L	A4,A2
		ADDA.L	4(A1),A2
		ADDA.W	D2,A2
		ADDA.W	D2,A2
		MOVE.L	A2,sam_lpstart(A6)
		MOVEQ	#0,D0
		MOVE.W	8(A1),D0
		SUB.W	D2,D0
		ADD.L	D0,D0
		ADD.L	D0,sam_lpstart(A6)
		MOVE.W	D0,sam_lplength(A6)
		BRA	L233B6
L233A6		LEA	$1A4(A5),A3
		MOVE.L	A3,sam_lpstart(A6)
		MOVE.W	#1*2,sam_lplength(A6)
		ADD.L	#1*2,sam_lpstart(A6)
		BRA	L233B6
L233B6		CLR.B	$3C(A0)
		MOVE.W	$3A(A0),D0
		BEQ.S	L233C6
		MOVE.W	D0,sam_period(A6)
		BRA.S	L233CC
L233C6		MOVE.W	$22(A0),sam_period(A6)
L233CC		MOVE.W	$20(A0),sam_vol(A6)
L233D2		LEA	-$54(A0),A0
		LEA	-sam_vcsize(A6),A6
		DBF	D7,L22F64
		TST.B	$1AD(A5)
		BEQ.S	L2341E
		SUBQ.B	#1,$1AF(A5)
		BNE.S	L2341E
		MOVE.B	$1AE(A5),$1AF(A5)
		MOVE.B	$1AD(A5),D0
		ADD.B	D0,$45(A5)
		MOVE.B	$1B0(A5),D0
		CMP.B	$45(A5),D0
		BNE.S	L2341E
		CLR.B	$1AD(A5)
		TST.B	$45(A5)
		BNE.S	L2341E
		MOVEQ	#0,D0
		MOVE.B	$198(A5),D0
		move_dmacon D0
		BCLR	#0,$19A(A5)
L2341E		RTS
mus_vars	DS.W    204
		DC.B   $0F,$0F
volshite	DC.B	$00,$06,$00,$00,$00,$00
		DS.W    6
; Periods table starts ere
		DC.B   $02,$00,$00,$00,$00,$00,' ',$00
		DC.B   $1E,'0',$1C,$80,$1A,$E8,$19,'h'
		DC.B   $17,$F8,$16,$A0,$15,'X',$14,'('
		DC.B   $13,$08,$11,$F8,$10,$F0,$10,$00
		DC.B   $0F,$18,$0E,'@',$0D,'t',$0C,$B4
		DC.B   $0B,$FC,$0B,'P',$0A,$AC,$0A,$14
		DC.B   $09,$84,$08,$FC,$08,'x',$08,$00
		DC.B   $07,$8C,$07,' ',$06,$BA,$06,'Z'
		DC.B   $05,$FE,$05,$A8,$05,'V',$05,$0A
		DC.B   $04,$C2,$04,'~',$04,'<',$04,$00
		DC.B   $03,$C6,$03,$90,$03,']',$03,'-'
		DC.B   $02,$FF,$02,$D4,$02,$AB,$02,$85
		DC.B   $02,'a',$02,'?',$02,$1E,$02,$00
		DC.B   $01,$E3,$01,$C8,$01,$AE,$01,$96
		DC.B   $01,'',$01,'j',$01,'U',$01,'B'
		DC.B   $01,'0',$01,$1F,$01,$0F,$01,$00
		DC.B   $00,$F1,$00,$E4,$00,$D7,$00,$CB
		DC.B   $00,$BF,$00,$B5,$00,$AA,$00,$A1
		DC.B   $00,$98,$00,$8F,$00,$87,$80,$00
		DC.B   'v',$83,'m',$BA,'e',$97,'^',$10
		DC.B   'W',$17,'P',$A2,'J',$A8,'E',$1F
		DC.B   '@',$00,';A6',$DD,'2',$CB
		DC.B   '/',$08,'+',$8B,'(Q%T' 
		DC.B   '"',$8F,' ',$00,$1D,$A0,$1B,'n'
		DC.B   $19,'e',$17,$84,$15,$C5,$14,'('
		DC.B   $12,$AA,$11,'G',$10,$00,$0E,$D0
		DC.B   $0D,$B7,$0C,$B2,$0B,$C2,$0A,$E2
		DC.B   $0A,$14,$09,'U',$08,$A3,$08,$00
		DC.B   $07,'h',$06,$DB,$06,'Y',$05,$E1
		DC.B   $05,'q',$05,$0A,$04,$AA,$04,'Q'
		DC.B   $04,$00,$03,$B4,$03,'m',$03,','
		DC.B   $02,$F0,$02,$B8,$02,$85,$02,'U'
		DC.B   $02,'(',$02,$00,$01,$DA,$01,$B6
		DC.B   $01,$96,$01,'x',$01,'\',$01,'B'
		DC.B   $01,'*',$01,$14,$01,$00,'??' 
		DC.B   '????????' 
		DC.B   '????????' 
		DC.B   '????????' 
		DC.B   '??????',$C0,$C0 
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,'??' 
		DC.B   '????????' 
		DC.B   '????????' 
		DC.B   '????????' 
		DC.B   '??????',$C0,$C0 
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,'??' 
		DC.B   '????????' 
		DC.B   '????????' 
		DC.B   '????????' 
	  	DC.B   '??????',$C0,$C0 
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	  	DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	  	DC.B   $C0,$C0,$C0,$C0,$C0,$C0,'??' 
		DC.B   '????????' 
		DC.B   '????????' 
		DC.B   '????????' 
		DC.B   '??????',$C0,$C0 
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
		DC.B   $C0,$C0,$C0,$C0,$C0,$C0
		DS.W    256
