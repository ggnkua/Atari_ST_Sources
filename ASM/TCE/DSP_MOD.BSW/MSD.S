**** 68030 + DSP mod player for Falcon 030

		jsr	init_mod





main_loop	bsr	vsync

;		move.l	#$7e000000,$ffff9800.w	;256 colour mode colour regs

;		IFNE	TRACKER
		bsr	play
;		endc

;		clr.l	$ffff9800.w

		move.w	key,d0




exit
		jsr	stopmod





		clr.w	-(sp)
		trap	#1

	dc.b	"*DSP mod player by MAC SYS DATA of PERSISTENCE OF VISION "
	dc.b	"½ POV 1994 *"
	even

init_mod	moveq	#1,d0
player		movem.l	a0-a6/d0-d7,-(sp)
		TST.W	D0
		BEQ.S	L0001
		BSR	L00A0
L0001		BSR	L009E
		BSR	L0021
		bsr	init
		BSR	L0024
		bsr	L0002
		MOVEM.L	(sp)+,A0-A6/D0-D7
		rts
L0002		lea	$FFFF8930.W,a0
		MOVE.L	(a0),L00AA
		move.l	#$902000,(a0)
		move.w	4(a0),L00AB
		move.w	#$101,4(a0)
		move.w	10(a0),L00AC
L0003		RTS

stopmod		LEA	$FFFF8930.W,A0
		move.l	L00AA,(A0)
		move.w	L00AB,4(A0)
		move.w	L00AC,10(A0)
		BCLR	#0,$FFFFFA07.W
		BCLR	#0,$FFFFFA13.W
		MOVE.B	(A0)+,$FFFFFA1B.W
		MOVE.B	(A0)+,$FFFFFA21.W
L0006		RTS

play		lea	L00B8,A0
		lea	L00B7,A1
		lea	$FFFFA202.W,A3
		lea	3(A3),A4
		lea	4(A3),A5
		CLR.W	(A5)
		MOVEQ	#3,D6
L0009		MOVE.B	19(A1),(A4)
		CLR.W	(A5)
		move.w	16(A1),D0
		LEA	(0,A0,D0.W*4),A2
		MOVE.B	1(A2),(A4)
		move.w	2(A2),(A5)
		MOVEQ	#0,D0
L000A		BTST	#0,(A3)
		beq.s	L000A
		move.w	(A5),D0
		tst.W	20(A1)
		beq.s	L000B
		clr.W	20(A1)
		bra.S	L000E
L000B		MOVEM.L	(A1),D1-D4
		add.L	D0,D1
		move.l	D1,D0
		sub.L	D2,D0
		bls.S	L000D
		cmp.L	#2,D4
		bne.s	L000C
		move.l	D2,D1
		bra.S	L000D
L000C		MOVE.L	D3,D1
		DIVUL.L	D4,D4:D0
		add.L	D4,D1
L000D		MOVE.L	D1,(A1)
L000E		MOVEQ	#0,D0
L000F		BTST	#0,(A3)
		beq.s	L000F
		move.w	(A5),D0
		addQ.L	#2,D0
L0010		BTST	#0,(A3)
		beq.s	L0010
		move.w	(A5),D7
		move.w	D7,L00B0
		moveM.L	(A1),D1-D4
		move.l	D2,D5
		sub.L	D1,D5
		cmp.L	D5,D0
		bls.S	L0014
		sub.L	D5,D0
		move.w	D5,D7
		moveA.L	D1,A2
		bsr.S	L0016
		cmp.L	#2,D4
		beq.s	L0012
		cmp.L	D4,D0
		BCS.S	L0011
		move.l	D4,D0
L0011		MOVE.W	D0,D7
		moveA.L	D3,A2
		bsr.S	L0016
		bra.S	L0015
L0012		CLR.B	(A4)
		move.w	#2,(A5)
L0013		BTST	#1,(A3)
		beq.s	L0013
		clr.W	(A5)
		NOP
		clr.W	(A5)
		bra.S	L0015
L0014		MOVE.W	D0,D7
		moveA.L	D1,A2
		bsr.S	L0016
		clr.b	(A4)
		clr.W	(A5)
L0015		ADDA.W	#$16,A1
		addQ.W	#1,L00B1
		DBF	D6,L0009
		bsr	L0026
		rts

L0016		CLR.B	(A4)
		move.w	D7,(A5)
		beq.s	L0019
		lsr.W	#1,D7
L0017		BTST	#1,(A3)
		beq.s	L0017
L0018		MOVE.W	(A2)+,(A5)
		DBF	D7,L0018
L0019		RTS

init		lea	mod,a0
		lea	950(a0),a1
		lea	134(a1),a2
		moveq	#$1E,D0
		moveq	#1,D3
		cmp.l	#"M.K.",1080(a0)
		beq.s	L001B
		cmp.l	#"FLT4",1080(A0)
		beq.s	L001B
		lea	470(A0),A1
		lea	130(A1),A2
		moveQ	#$E,D0
		moveQ	#0,D3
L001B		MOVE.L	A1,L00B3
		move.l	A2,L00B4
		move.w	D0,L00B5
		moveA.L	L00B3,A1
		moveA.L	A1,A2
		addQ.L	#2,A1

		moveq	#$7f,d0
		moveq	#0,d1
L001C		move.b	(a1)+,d2
		cmp.b	D2,D1
		BCC.S	L001D
		move.b	D2,D1
L001D		DBF	D0,L001C

		cmp.b	1(A2),D1
		BCC.S	L001E
		clr.b	1(A2)
L001E		ADDQ.W	#1,D1
		mulu.L	#$400,D1
		moveA.L	L00B4,A1
		lea	0(A1,D1.L),a1
		add.w	#$2a,a0
		lea	L00B6,a2
		move.w	L00B5,d0

lop3		MOVE.L	A1,(A2)+
		moveQ	#0,D1
		move.w	(A0),D1
		add.L	D1,D1
		addA.L	D1,A1
		tst.W	D3
		bne.s	L0020
		lsr	4(A0)
L0020		ADDA.W	#$1E,A0
		DBF	D0,lop3
		rts

L0021		LEA	L00B8,A0
		move.w	#$4F,D0
L0022		clr.l	(a0)+
		DBF	D0,L0022
		move.w	#$31F,D0
		moveQ	#$50,D1
		move.l	#$24665268,D2
L0023		MOVE.L	D2,D4
		DIVU.L	D1,D4
		move.l	D4,(A0)+
		addQ.L	#1,D1
		DBF	D0,L0023
		rts

L0024		LEA	L00AA,A0
		lea	L00B7,A1
		move.w	#3,D0
L0025		MOVE.L	A0,(A1)
		move.l	A0,4(A1)
		clr.l	8(a1)
		move.l	#2,12(A1)
		move.w	#1,20(A1)
		addA.W	#$16,A1
		DBF	D0,L0025
		rts

L0026		lea	mod,a0
		addq.w	#1,L00BD
		move.w	L00BD,d0
		cmp.w	L00BE,d0
		BCS.S	L0027
		clr.w	L00BD
		tst.B	L00C7
		beq.s	L002A
		bsr.S	L0028
		bra	L002C
L0027		BSR.S	L0028
		bra	L0031
L0028		MOVEQ	#3,D6
		lea	voice1,A6
		lea	L00B7,A5
L0029		BSR	L0040
		addA.W	#$2C,A6
		addA.W	#$16,A5
		DBF	D6,L0029
		rts

L002A		LEA	12(A0),A3
		moveA.L	L00B4,A0
		moveQ	#0,D1
		moveA.L	L00B3,A2
		move.w	L00C1,D0
		move.b	2(A2,D0.W),D1
		ASL.L	#8,D1
		ASL.L	#2,D1
		move.w	L00C0,D0
		EXT.L	D0
		add.L	D0,D1
		clr.w	L00BF
		moveQ	#0,D6
		lea	L00B7,A5
		lea	voice1,A6
L002B		MOVE.W	D6,D2
		bsr	L0032
		moveQ	#0,D0
		move.b	19(A6),D0
		move.w	D0,18(A5)
		addA.W	#$16,A5
		addA.W	#$2C,A6
		addQ.W	#1,D6
		cmp.W	#4,D6
		bne.s	L002B
L002C		ADDI.W	#$10,L00C0
		move.b	L00C6,D0
		beq.s	L002D
		move.b	D0,L00C7
		clr.b	L00C6
L002D		TST.B	L00C7
		beq.s	L002E
		subQ.B	#1,L00C7
		beq.s	L002E
		subI.W	#$10,L00C0
L002E		TST.B	L00C4
		beq.s	L002F
		SF	L00C4
		moveQ	#0,D0
		move.b	L00C2,D0
		lsl.W	#4,D0 
		move.w	D0,L00C0
		clr.b	L00C2 
L002F		CMPI.W	#$400,L00C0
		bne.s	L0031
L0030		MOVEQ	#0,D0
		move.b	L00C2,D0
		lsl.W	#4,D0
		move.w	D0,L00C0
		clr.b	L00C2
		clr.b	L00C3
		addQ.W	#1,L00C1
		andI.W	#$7F,L00C1
		move.w	L00C1,D1
		moveA.L	L00B3,A0
		cmp.b	(A0),D1
		BCS.S	L0031
		moveQ	#0,D1
		move.b	1(A0),D1
		move.w	D1,L00C1
L0031		TST.B	L00C3
		bne.s	L0030
		rts
L0032		TST.L	(A6)
		bne.s	L0033
		bsr	L0043
L0033		MOVE.L	0(A0,D1.L),(A6)
		addQ.L	#4,D1
		btst	D2,L00C8
		beq	L0042
		moveQ	#0,D2
		move.b	2(A6),D2
		and.B	#$F0,D2
		lsr.B	#4,D2
		move.b	(A6),D0
		and.B	#$F0,D0
		OR.B	D0,D2
		tst.B	D2
		beq	L0036
		moveQ	#0,D3
		lea	L00B6,A1
		move.w	D2,D4
		move.b	D2,43(A6)
		subQ.L	#1,D2
		lsl.L	#2,D2
		mulu	#$1E,D4
		move.l	0(A1,D2.L),4(A6)
		move.w	0(A3,D4.L),8(A6)
		move.w	0(A3,D4.L),40(A6)
		move.b	2(A3,D4.L),18(A6)
		move.b	3(A3,D4.L),19(A6)
		move.w	4(A3,D4.L),D3
		beq.s	L0035
		move.l	4(A6),D2
		ASL.W	#1,D3
		add.L	D3,D2
		move.l	D2,10(A6)
		move.l	D2,36(A6)
		moveM.W	4(A3,D4.L),D2/D0
		add.W	D2,D0
		move.w	40(A6),D3
		cmp.W	D3,D0
		bls.S	L0034
		move.w	D3,8(A6)
		sub.W	D3,D0
		sub.W	D0,D2
		move.w	D2,14(A6)
		bra.S	L0036
L0034		MOVE.W	D0,8(A6)
		move.w	D2,14(A6)
		bra.S	L0036
L0035		MOVE.L	4(A6),D2
		move.l	D2,10(A6)
		move.l	D2,36(A6)
		move.w	6(A3,D4.L),14(A6)
L0036		MOVE.W	(A6),D0
		and.W	#$FFF,D0
		beq	L0084
		move.w	2(A6),D0
		and.W	#$FF0,D0
		cmp.W	#$E50,D0
		beq.s	L0037
		move.b	2(A6),D0
		and.B	#$F,D0
		cmp.b	#3,D0
		beq.s	L0038
		cmp.b	#5,D0
		beq.s	L0038
		cmp.b	#9,D0
		bne.s	L0039
		bsr	L0084
		bra.S	L0039
L0037		BSR	L0089
		bra.S	L0039
L0038		BSR	L0050
		bra	L0084
L0039		MOVEM.L	A0-A1/D0-D1,-(A7)
		move.w	(A6),D1
		and.w	#$FFF,D1
		lea	L00BB,A1
		moveQ	#0,D0
		moveQ	#$24,D7
L003A		CMP.W	0(A1,D0.W),D1
		BCC.S	L003B
		addQ.L	#2,D0
		DBF	D7,L003A
L003B		MOVEQ	#0,D1
		move.b	18(A6),D1
		mulu	#$4A,D1
		addA.L	D1,A1
		move.w	0(A1,D0.W),16(A6)
		moveM.L	(A7)+,A0-A1/D0-D1
		move.w	2(A6),D0
		and.W	#$FF0,D0
		cmp.W	#$ED0,D0
		beq	L0084
		btst	#2,30(A6)
		bne.s	L003C
		clr.b	27(A6)
L003C		BTST	#6,30(A6)
		bne.s	L003D
		clr.b	29(A6)
L003D		MOVE.W	#1,20(A5)
		move.l	4(A6),D0
		bne.s	L003E
		move.l	#L00BB,D0
		move.l	D0,(A5)
		move.l	D0,4(A5)
		moveQ	#2,D0
		move.l	D0,12(A5)
		clr.L	10(A6)
		move.w	#1,14(A6)
		bra.S	L003F
L003E		MOVE.L	D0,(A5)
		moveQ	#0,D2
		move.w	8(A6),D2
		add.L	D2,D2
		add.L	D2,D0
		move.l	D0,4(A5)
		move.l	10(A6),8(A5)
		moveQ	#0,D0
		move.w	14(A6),D0
		add.L	D0,D0
		move.l	D0,12(A5)
L003F		MOVE.W	16(A6),D0
		move.w	D0,16(A5)
		ST	42(A6)
		move.w	20(A6),D0
		OR.W	D0,L00BF
		bra	L0084
L0040		BSR.S	L0041
		moveQ	#0,D0
		move.b	19(A6),D0
		move.w	D0,18(A5)
		rts
L0041		BSR	L009B
		move.w	2(A6),D0
		and.W	#$FFF,D0
		beq.s	L0042
		move.b	2(A6),D0
		and.B	#$F,D0
		tst.B	D0
		beq.s	L0044
		cmp.b	#1,D0
		beq	L004B
		cmp.b	#2,D0
		beq	L004E
		cmp.b	#3,D0
		beq	L0055
		cmp.b	#4,D0
		beq	L005C
		cmp.b	#5,D0
		beq	L0066
		cmp.b	#6,D0
		beq	L0067
		cmp.b	#$E,D0
		beq	L0085
		move.w	16(A6),16(A5)
		cmp.b	#7,D0
		beq	L0068
		cmp.b	#$A,D0
		beq	L0077
L0042		RTS
L0043		MOVE.W	16(A6),16(A5)
		rts
L0044		MOVEQ	#0,D0
		move.w	L00BD,D0
	DIVS	#3,D0
	SWAP	D0
		cmp.W	#1,D0
		beq.s	L0045
		cmp.W	#2,D0
		beq.s	L0046
		move.w	16(A6),D2
		bra.S	L0049
L0045		MOVEQ	#0,D0
		move.b	3(A6),D0
		lsr.B	#4,D0
		bra.S	L0047
L0046		MOVEQ	#0,D0
		move.b	3(A6),D0
		and.B	#$F,D0
L0047		ASL.W	#1,D0
		moveQ	#0,D1
		move.b	18(A6),D1
		mulu	#$4A,D1
		lea	L00BB,A0
		addA.L	D1,A0
		moveQ	#0,D1
		move.w	16(A6),D1
		moveQ	#$24,D7
L0048		MOVE.W	0(A0,D0.W),D2
		cmp.W	(A0),D1
	BCC.S	L0049
		addQ.L	#2,A0
	DBF	D7,L0048
		rts
L0049		MOVE.W	D2,16(A5)
		rts
L004A		TST.W	L00BD
		bne.s	L0042
		move.b	#$F,L00C5
L004B		MOVEQ	#0,D0
		move.b	3(A6),D0
		and.B	L00C5,D0
		move.b	#$FF,L00C5
		sub.W	D0,16(A6)
		move.w	16(A6),D0
		and.W	#$FFF,D0
		cmp.W	#$71,D0
	BPL.S	L004C
		andI.W	#$F000,16(A6)
	ORI.W	#$71,16(A6)
L004C		MOVE.W	16(A6),D0
		and.W	#$FFF,D0
		move.w	D0,16(A5)
		rts
L004D		TST.W	L00BD
		bne	L0042
		move.b	#$F,L00C5
L004E		CLR.W	D0
		move.b	3(A6),D0
		and.B	L00C5,D0
		move.b	#$FF,L00C5
		add.W	D0,16(A6)
		move.w	16(A6),D0
		and.W	#$FFF,D0
		cmp.W	#$358,D0
	BMI.S	L004F
		andI.W	#$F000,16(A6)
	ORI.W	#$358,16(A6)
L004F		MOVE.W	16(A6),D0
		and.W	#$FFF,D0
		move.w	D0,16(A5)
		rts
L0050		MOVE.L	A0,-(A7)
		move.w	(A6),D2
		and.W	#$FFF,D2
		moveQ	#0,D0
		move.b	18(A6),D0
		mulu	#$4A,D0
		lea	L00BB,A0
		addA.L	D0,A0
		moveQ	#0,D0
L0051		CMP.W	0(A0,D0.W),D2
	BCC.S	L0052
		addQ.W	#2,D0
		cmp.W	#$4A,D0
	BCS.S	L0051
		moveQ	#$46,D0
L0052		MOVE.B	18(A6),D2
		and.B	#8,D2
		beq.s	L0053
		tst.W	D0
		beq.s	L0053
		subQ.W	#2,D0
L0053		MOVE.W	0(A0,D0.W),D2
		moveA.L	(A7)+,A0
		move.w	D2,24(A6)
		move.w	16(A6),D0
		clr.b	22(A6)
		cmp.W	D0,D2
		beq.s	L0054
	BGE	L0042
		move.b	#1,22(A6)
		rts
L0054		CLR.W	24(A6)
		rts
L0055		MOVE.B	3(A6),D0
		beq.s	L0056
		move.b	D0,23(A6)
		clr.b	3(A6)
L0056		TST.W	24(A6)
		beq	L0042
		moveQ	#0,D0
		move.b	23(A6),D0
		tst.B	22(A6)
		bne.s	L0057
		add.W	D0,16(A6)
		move.w	24(A6),D0
		cmp.W	16(A6),D0
	BGT.S	L0058
		move.w	24(A6),16(A6)
		clr.W	24(A6)
		bra.S	L0058
L0057		SUB.W	D0,16(A6)
		move.w	24(A6),D0
		cmp.W	16(A6),D0
	BLT.S	L0058
		move.w	24(A6),16(A6)
		clr.W	24(A6)
L0058		MOVE.W	16(A6),D2
		move.b	31(A6),D0
		and.B	#$F,D0
		beq.s	L005B
		moveQ	#0,D0
		move.b	18(A6),D0
		mulu	#$4A,D0
		lea	L00BB,A0
		addA.L	D0,A0
		moveQ	#0,D0
L0059		CMP.W	0(A0,D0.W),D2
	BCC.S	L005A
		addQ.W	#2,D0
		cmp.W	#$4A,D0
	BCS.S	L0059
		moveQ	#$46,D0
L005A		MOVE.W	0(A0,D0.W),D2
L005B		mOVE.W	D2,16(A5)
		rts
L005C		MOVE.B	3(A6),D0
		beq.s	L005F
		move.b	26(A6),D2
		and.B	#$F,D0
		beq.s	L005D
		and.B	#$F0,D2
	OR.B	D0,D2
L005D		MOVE.B	3(A6),D0
		and.B	#$F0,D0
		beq.s	L005E
		and.B	#$F,D2
	OR.B	D0,D2
L005E		MOVE.B	D2,26(A6)
L005F		MOVE.L	A4,-(A7)
		move.b	27(A6),D0
		lea	sin,A4
		lsr.W	#2,D0
		and.W	#$1F,D0
		moveQ	#0,D2
		move.b	30(A6),D2
		and.B	#3,D2
		beq.s	L0062
		lsl.B	#3,D0
		cmp.b	#1,D2
		beq.s	L0060
		move.b	#$FF,D2
		bra.S	L0063
L0060		TST.B	27(A6)
	BPL.S	L0061
		move.b	#$FF,D2
		sub.B	D0,D2
		bra.S	L0063
L0061		MOVE.B	D0,D2
		bra.S	L0063
L0062		MOVE.B	0(A4,D0.W),D2
L0063		MOVE.B	26(A6),D0
		and.W	#$F,D0
		mulu	D0,D2
		lsr.W	#7,D2
		move.w	16(A6),D0
		tst.B	27(A6)
	BMI.S	L0064
		add.W	D2,D0
		bra.S	L0065
L0064		SUB.W	D2,D0
L0065		MOVE.W	D0,16(A5)
		move.b	26(A6),D0
		lsr.W	#2,D0
		and.W	#$3C,D0
		add.B	D0,27(A6)
		moveA.L	(A7)+,A4
		rts
L0066		BSR	L0056
		bra	L0077
L0067		BSR.S	L005F
		bra	L0077
L0068		MOVE.L	A4,-(A7)
		move.b	3(A6),D0
		beq.s	L006B
		move.b	28(A6),D2
		and.B	#$F,D0
		beq.s	L0069
		and.B	#$F0,D2
	OR.B	D0,D2
L0069		MOVE.B	3(A6),D0
		and.B	#$F0,D0
		beq.s	L006A
		and.B	#$F,D2
	OR.B	D0,D2
L006A		MOVE.B	D2,28(A6)
L006B		MOVE.B	29(A6),D0
		lea	sin,A4
		lsr.W	#2,D0
		and.W	#$1F,D0
		moveQ	#0,D2
		move.b	30(A6),D2
		lsr.B	#4,D2
		and.B	#3,D2
		beq.s	L006E
		lsl.B	#3,D0
		cmp.b	#1,D2
		beq.s	L006C
		move.b	#$FF,D2
		bra.S	L006F
L006C		TST.B	27(A6)
	BPL.S	L006D
		move.b	#$FF,D2
		sub.B	D0,D2
		bra.S	L006F
L006D		MOVE.B	D0,D2
		bra.S	L006F
L006E		MOVE.B	0(A4,D0.W),D2
L006F		MOVE.B	28(A6),D0
		and.W	#$F,D0
		mulu	D0,D2
		lsr.W	#6,D2
		moveQ	#0,D0
		move.b	19(A6),D0
		tst.B	29(A6)
	BMI.S	L0070
		add.W	D2,D0
		bra.S	L0071
L0070		SUB.W	D2,D0
L0071		BPL.S	L0072
		clr.W	D0
L0072		CMP.W	#$40,D0
		bls.S	L0073
		move.w	#$40,D0
L0073	MOVE.W	D0,18(A5)
		move.b	28(A6),D0
		lsr.W	#2,D0
		and.W	#$3C,D0
		add.B	D0,29(A6)
		moveA.L	(A7)+,A4
		addQ.L	#4,A7
		rts
L0074	MOVEQ	#0,D0
		move.b	3(A6),D0
		beq.s	L0075
		move.b	D0,32(A6)
L0075	MOVE.B	32(A6),D0
		lsl.W	#7,D0
		cmp.W	8(A6),D0
	BGE.S	L0076
		sub.W	D0,8(A6)
		lsl.W	#1,D0
		add.L	D0,4(A6)
		rts
L0076	MOVE.W	#1,8(A6)
		rts
L0077	MOVEQ	#0,D0
		move.b	3(A6),D0
		lsr.B	#4,D0
		tst.B	D0
		beq.s	L007A 
L0078	ADD.B	D0,19(A6) 
		cmpI.B	#$40,19(A6) 
	BMI.S	L0079 
		move.b	#$40,19(A6) 
L0079	MOVE.B	19(A6),D0 
		rts 
L007A	MOVEQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
L007B	SUB.B	D0,19(A6) 
	BPL.S	L007C 
		clr.b	19(A6)
L007C	MOVE.B	19(A6),D0 
		rts 
L007D	MOVEQ	#0,D0 
		move.b	3(A6),D0
		subQ.B	#1,D0 
		move.w	D0,L00C1
L007E	CLR.B	L00C2 
	ST	L00C3 
		rts 
L007F	MOVEQ	#0,D0 
		move.b	3(A6),D0
		cmp.b	#$40,D0 
		bls.S	L0080 
		moveQ	#$40,D0 
L0080	MOVE.B	D0,19(A6) 
		rts 
L0081	MOVEQ	#0,D0 
		move.b	3(A6),D0
	move.l	D0,D2 
		lsr.B	#4,D0 
		mulu	#$A,D0
		and.B	#$F,D2
		add.B	D2,D0 
		cmp.b	#$3F,D0 
	BHI.S	L007E 
		move.b	D0,L00C2
	ST	L00C3 
		rts 
L0082	MOVE.B	3(A6),D0
		and.W	#$FF,D0 
		beq.s	L0083 
		clr.W	L00BD 
		move.w	D0,L00BE
L0083	RTS 
L0084	MOVE.B	2(A6),D0
		and.B	#$F,D0
		cmp.b	#9,D0 
		beq	L0074 
		cmp.b	#$B,D0
		beq	L007D 
		cmp.b	#$D,D0
		beq.s	L0081 
		cmp.b	#$E,D0
		beq.s	L0085 
		cmp.b	#$F,D0
		beq.s	L0082 
		cmp.b	#$C,D0
		beq	L007F 
		bra	L0043 
L0085	MOVE.B	3(A6),D0
		and.B	#$F0,D0 
		lsr.B	#4,D0 
		beq.s	L0086 
		cmp.b	#1,D0 
		beq	L004A 
		cmp.b	#2,D0 
		beq	L004D 
		cmp.b	#3,D0 
		beq.s	L0087 
		cmp.b	#4,D0 
		beq.s	L0088 
		cmp.b	#5,D0 
		beq	L0089 
		cmp.b	#6,D0 
		beq	L008A 
		cmp.b	#7,D0 
		beq	L008E 
		cmp.b	#8,D0 
		beq	L008F 
		cmp.b	#$E,D0
		beq	L0099 
		cmp.b	#9,D0 
		beq	L0091 
		cmp.b	#$A,D0
		beq	L0095 
		cmp.b	#$B,D0
		beq	L0096 
		cmp.b	#$C,D0
		beq	L0097 
		cmp.b	#$D,D0
		beq	L0098 
		cmp.b	#$F,D0
		beq	L009A 
		rts 
L0086	MOVE.B	3(A6),D0
		and.B	#1,D0 
	ASL.B	#1,D0 
		rts 
L0087	MOVE.B	3(A6),D0
		and.B	#$F,D0
		andI.B	#$F0,31(A6) 
	OR.B	D0,31(A6) 
		rts 
L0088	MOVE.B	3(A6),D0
		and.B	#$F,D0
		andI.B	#$F0,30(A6) 
	OR.B	D0,30(A6) 
		rts 
L0089	MOVE.B	3(A6),D0
		and.B	#$F,D0
		move.b	D0,18(A6) 
		rts 
L008A	TST.W	L00BD 
		bne	L0042 
		move.b	3(A6),D0
		and.B	#$F,D0
		beq.s	L008D 
		tst.B	34(A6)
		beq.s	L008C 
		subQ.B	#1,34(A6) 
		beq	L0042 
L008B		MOVE.B	33(A6),L00C2
		ST	L00C4 
		rts 
L008C		MOVE.B	D0,34(A6) 
		bra.S	L008B 
L008D		MOVE.W	L00C0,D0
		lsr.L	#4,D0 
		and.B	#$3F,D0 
		move.b	D0,33(A6) 
		rts 
L008E		MOVE.B	3(A6),D0
		and.B	#$F,D0
		lsl.B	#4,D0 
		andI.B	#$F,30(A6)
		OR.B	D0,30(A6) 
		rts 
L008F		MOVEM.L	A0-A1/D1-D2,-(A7) 
		moveA.L	10(A6),A0 
		moveA.L	A0,A1 
		move.w	14(A6),D0 
		add.W	D0,D0 
		subQ.W	#2,D0 
L0090		MOVE.B	(A0),D1 
		EXT.W	D1
		move.b	1(A0),D2
		EXT.W	D2
		add.W	D1,D2 
		ASR.W	#1,D2 
		move.b	D2,(A0)+
		DBF	D0,L0090
		move.b	(A0),D1 
		EXT.W	D1
		move.b	(A1),D2 
		EXT.W	D2
		add.W	D1,D2 
		ASR.W	#1,D2 
		move.b	D2,(A0) 
		moveM.L	(A7)+,A0-A1/D1-D2 
		rts 
L0091		MOVE.L	D1,-(A7)
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		beq.s	L0094 
		move.w	L00BD,D1
		bne.s	L0092 
		move.w	(A6),D1 
		and.W	#$FFF,D1
		bne.s	L0094 
		move.w	L00BD,D1
L0092		EXT.L	D1
		DIVU	D0,D1 
		SWAP	D1
		tst.W	D1
		bne.s	L0094 
L0093		MOVE.W	#1,20(A5) 
		move.l	4(A6),D0
		move.l	D0,(A5) 
		moveQ	#0,D1 
		move.w	8(A6),D1
		add.L	D1,D1 
		add.L	D1,D0 
		move.l	D0,4(A5)
		move.w	16(A6),16(A5) 
		move.l	10(A6),8(A5)
		moveQ	#0,D0 
		move.w	14(A6),D0 
		add.L	D0,D0 
		move.l	D0,12(A5) 
L0094		MOVE.L	(A7)+,D1
		rts 
L0095		TST.W	L00BD 
		bne	L0042 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		bra	L0078 
L0096		TST.W	L00BD 
		bne	L0042 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		bra	L007B 
L0097		MOVEQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		cmp.W	L00BD,D0
		bne	L0042 
		clr.b	19(A6)
		rts 
L0098		MOVEQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		cmp.W	L00BD,D0
		bne	L0042 
		move.w	(A6),D0 
		and.W	#$FFF,D0
		beq	L0042 
		move.l	D1,-(A7)
		bra	L0093 
L0099		TST.W	L00BD 
		bne	L0042 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		tst.B	L00C7 
		bne	L0042 
		addQ.B	#1,D0 
		move.b	D0,L00C6
		rts 
L009A		TST.W	L00BD 
		bne	L0042 
		move.b	3(A6),D0
		and.B	#$F,D0
		lsl.B	#4,D0 
		andI.B	#$F,31(A6)
		OR.B	D0,31(A6) 
		tst.B	D0
		beq	L0042 
L009B		MOVEM.L	A0/D1,-(A7) 
		moveQ	#0,D0 
		move.b	31(A6),D0 
		lsr.B	#4,D0 
		beq.s	L009D 
		lea	L00B9,A0
		move.b	0(A0,D0.W),D0 
		add.B	D0,35(A6) 
		btst	#7,35(A6) 
		beq.s	L009D 
		clr.b	35(A6)
		move.l	10(A6),D0 
		moveQ	#0,D1 
		move.w	14(A6),D1 
		add.L	D1,D0 
		add.L	D1,D0 
		moveA.L	36(A6),A0 
		addQ.L	#1,A0 
		cmpA.L	D0,A0 
		bCS.S	L009C 
		moveA.L	10(A6),A0 
L009C		MOVE.L	A0,36(A6) 
		moveq	#$FF,D0 
		sub.B	(A0),D0 
		move.b	D0,(A0) 
L009D		MOVEM.L	(A7)+,A0/D1 
		rts 

L009E		movem.l	a0-a1,-(sp) 
		lea	voice1,A0
		lea	L00C9,A1
L009F		clr.b	(a0)+ 
		cmp.l	a0,a1 
		bne.s	L009F 
		lea	voice1,A0
		move.b	#1,20(A0) 
		move.b	#2,64(A0) 
		move.b	#4,108(A0)
		move.b	#8,152(A0)
		move.w	#6,L00BE
		move.b	#$F,L00C8 
		movem.l	(sp)+,a0-a1 
		rts 

L00A0		MOVEM.L	A0-A6/D0-D7,-(A7) 
		bsr	L00A1
		moveM.L	(A7)+,A0-A6/D0-D7 
		rts 
L00A1		LEA	$FFFF8800.W,A0
		move	SR,D1 
		move	#$2700,SR 
		move.b	#$E,(A0)
		move.b	(A0),D0 
		and.B	#$EF,D0 
		move.b	D0,2(A0)
		OR.B	#$10,D0 
		move.b	D0,2(A0)
		move	D1,SR 
		move.l	$4BA.W,D0 
		addQ.L	#2,D0 
L00A2		CMP.L	$4BA.W,D0 
		BLT.S	L00A2 
		move	SR,D1 
		move	#$2700,SR 
		move.b	#$E,(A0)
		move.b	(A0),D0 
		and.B	#$EF,D0 
		move.b	D0,2(A0)
		move	D1,SR 
		lea	$FFFFA200.W,A0
		lea	L00CA,A1
		move.w	#$200,D0
L00A3		TST.B	(A1)
		BMI.S	L00A4 
		addQ.W	#3,A1 
		move.b	(A1)+,5(A0) 
		move.b	(A1)+,6(A0) 
		move.b	(A1)+,7(A0) 
		subQ.W	#1,D0 
		bra.S	L00A3 
L00A4	TST.W	D0
		beq.s	L00A6 
L00A5	CLR.B	5(A0) 
		clr.b	6(A0) 
		clr.b	7(A0) 
		subQ.W	#1,D0 
		bne.s	L00A5 
L00A6	BTST	#2,2(A0)
		beq.s	L00A6 
		clr.b	5(A0) 
		clr.b	6(A0) 
		clr.b	7(A0) 
		lea	L00CB,A1
L00A7	BTST	#2,2(A0)
		beq.s	L00A7 
		move.b	(A1)+,5(A0) 
		move.b	(A1)+,6(A0) 
		move.b	(A1)+,7(A0) 
		tst.B	-3(A1)
	BMI.S	L00A9 
L00A8	BTST	#2,2(A0)
		beq.s	L00A8 
		move.b	(A1)+,5(A0) 
		move.b	(A1)+,6(A0) 
		move.b	(A1)+,7(A0) 
		bra.S	L00A7 
L00A9		RTS 

** do not move the following data else where!!!
*******************
   SECTION DATA
*******************

	DC.w	$00 
L00AA	DC.l	0 
L00AB	DC.w	$00 
L00AC	DC.w	$00 
L00AF	DCB.W	3,0 
L00B0	DC.w	$00 
L00B1	DC.w	$00 

L00B3	dc.l	0 
L00B4	dc.l	0 
L00B5	dc.b	0 
L00B6	DCB.W	62,0
L00B7	dc.l	0 
L00B8	DCB.W	1760,0

L00B9	DC.B	$00,$05,$06,$07,$08,$0A,$0B,$0D 
	DC.B	$10,$13,$16,$1A,' +@',$80 

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18
	DC.B $00,$00 

periods
L00BB	DC.B	$03,'X',$03,'(',$02,$FA,$02,$D0 
	DC.B	$02,$A6,$02,$80,$02,'\',$02,':' 
	DC.B	$02,$1A,$01,$FC,$01,$E0,$01,$C5 
	DC.B	$01,$AC,$01,$94,$01,'}',$01,'h' 
	DC.B	$01,'S',$01,'@',$01,'.',$01,$1D 
	DC.B	$01,$0D,$00,$FE,$00,$F0,$00,$E2 
	DC.B	$00,$D6,$00,$CA,$00,$BE,$00,$B4 
	DC.B	$00,$AA,$00,$A0,$00,$97,$00,$8F 
	DC.B	$00,$87,$00,$7F,$00,'x',$00,'q' 
	DC.B	$00,$00,$03,'R',$03,'"',$02,$F5 
	DC.B	$02,$CB,$02,$A2,$02,'}',$02,'Y' 
	DC.B	$02,'7',$02,$17,$01,$F9,$01,$DD 
	DC.B	$01,$C2,$01,$A9,$01,$91,$01,'{' 
	DC.B	$01,'e',$01,'Q',$01,'>',$01,',' 
	DC.B	$01,$1C,$01,$0C,$00,$FD,$00,$EF 
	DC.B	$00,$E1,$00,$D5,$00,$C9,$00,$BD 
	DC.B	$00,$B3,$00,$A9,$00,$9F,$00,$96 
	DC.B	$00,$8E,$00,$86,$00,'~',$00,'w' 
	DC.B	$00,'q',$00,$00,$03,'L',$03,$1C 
	DC.B	$02,$F0,$02,$C5,$02,$9E,$02,'x' 
	DC.B	$02,'U',$02,'3',$02,$14,$01,$F6 
	DC.B	$01,$DA,$01,$BF,$01,$A6,$01,$8E 
	DC.B	$01,'x',$01,'c',$01,'O',$01,'<' 
	DC.B	$01,'*',$01,$1A,$01,$0A,$00,$FB 
	DC.B	$00,$ED,$00,$E0,$00,$D3,$00,$C7 
	DC.B	$00,$BC,$00,$B1,$00,$A7,$00,$9E 
	DC.B	$00,$95,$00,$8D,$00,$85,$00,'}' 
	DC.B	$00,'v',$00,'p',$00,$00,$03,'F' 
	DC.B	$03,$17,$02,$EA,$02,$C0,$02,$99 
	DC.B	$02,'t',$02,'P',$02,'/',$02,$10 
	DC.B	$01,$F2,$01,$D6,$01,$BC,$01,$A3 
	DC.B	$01,$8B,$01,'u',$01,'`',$01,'L' 
	DC.B	$01,':',$01,'(',$01,$18,$01,$08 
	DC.B	$00,$F9,$00,$EB,$00,$DE,$00,$D1 
	DC.B	$00,$C6,$00,$BB,$00,$B0,$00,$A6 
	DC.B	$00,$9D,$00,$94,$00,$8C,$00,$84 
	DC.B	$00,'}',$00,'v',$00,'o',$00,$00 
	DC.B	$03,'@',$03,$11,$02,$E5,$02,$BB 
	DC.B	$02,$94,$02,'o',$02,'L',$02,'+' 
	DC.B	$02,$0C,$01,$EF,$01,$D3,$01,$B9 
	DC.B	$01,$A0,$01,$88,$01,'r',$01,'^' 
	DC.B	$01,'J',$01,'8',$01,'&',$01,$16 
	DC.B	$01,$06,$00,$F7,$00,$E9,$00,$DC 
	DC.B	$00,$D0,$00,$C4,$00,$B9,$00,$AF 
	DC.B	$00,$A5,$00,$9C,$00,$93,$00,$8B 
	DC.B	$00,$83,$00,'|',$00,'u',$00,'n' 
	DC.B	$00,$00,$03,':',$03,$0B,$02,$E0 
	DC.B	$02,$B6,$02,$8F,$02,'k',$02,'H' 
	DC.B	$02,$27,$02,$08,$01,$EB,$01,$CF 
	DC.B	$01,$B5,$01,$9D,$01,$86,$01,'p' 
	DC.B	$01,'[',$01,'H',$01,'5',$01,'$' 
	DC.B	$01,$14,$01,$04,$00,$F5,$00,$E8 
	DC.B	$00,$DB,$00,$CE,$00,$C3,$00,$B8 
	DC.B	$00,$AE,$00,$A4,$00,$9B,$00,$92 
	DC.B	$00,$8A,$00,$82,$00,'{',$00,'t' 
	DC.B	$00,'m',$00,$00,$03,'4',$03,$06 
	DC.B	$02,$DA,$02,$B1,$02,$8B,$02,'f' 
	DC.B	$02,'D',$02,'#',$02,$04,$01,$E7 
	DC.B	$01,$CC,$01,$B2,$01,$9A,$01,$83 
	DC.B	$01,'m',$01,'Y',$01,'E',$01,'3' 
	DC.B	$01,'"',$01,$12,$01,$02,$00,$F4 
	DC.B	$00,$E6,$00,$D9,$00,$CD,$00,$C1 
	DC.B	$00,$B7,$00,$AC,$00,$A3,$00,$9A 
	DC.B	$00,$91,$00,$89,$00,$81,$00,'z' 
	DC.B	$00,'s',$00,'m',$00,$00,$03,'.' 
	DC.B	$03,$00,$02,$D5,$02,$AC,$02,$86 
	DC.B	$02,'b',$02,'?',$02,$1F,$02,$01 
	DC.B	$01,$E4,$01,$C9,$01,$AF,$01,$97 
	DC.B	$01,$80,$01,'k',$01,'V',$01,'C' 
	DC.B	$01,'1',$01,' ',$01,$10,$01,$00 
	DC.B	$00,$F2,$00,$E4,$00,$D8,$00,$CC 
	DC.B	$00,$C0,$00,$B5,$00,$AB,$00,$A1 
	DC.B	$00,$98,$00,$90,$00,$88,$00,$80 
	DC.B	$00,'y',$00,'r',$00,'l',$00,$00 
	DC.B	$03,$8B,$03,'X',$03,'(',$02,$FA 
	DC.B	$02,$D0,$02,$A6,$02,$80,$02,'\' 
	DC.B	$02,':',$02,$1A,$01,$FC,$01,$E0 
	DC.B	$01,$C5,$01,$AC,$01,$94,$01,'}' 
	DC.B	$01,'h',$01,'S',$01,'@',$01,'.' 
	DC.B	$01,$1D,$01,$0D,$00,$FE,$00,$F0 
	DC.B	$00,$E2,$00,$D6,$00,$CA,$00,$BE 
	DC.B	$00,$B4,$00,$AA,$00,$A0,$00,$97 
	DC.B	$00,$8F,$00,$87,$00,$7F,$00,'x' 
	DC.B	$00,$00,$03,$84,$03,'R',$03,'"' 
	DC.B	$02,$F5,$02,$CB,$02,$A3,$02,'|' 
	DC.B	$02,'Y',$02,'7',$02,$17,$01,$F9 
	DC.B	$01,$DD,$01,$C2,$01,$A9,$01,$91 
	DC.B	$01,'{',$01,'e',$01,'Q',$01,'>' 
	DC.B	$01,',',$01,$1C,$01,$0C,$00,$FD 
	DC.B	$00,$EE,$00,$E1,$00,$D4,$00,$C8 
	DC.B	$00,$BD,$00,$B3,$00,$A9,$00,$9F 
	DC.B	$00,$96,$00,$8E,$00,$86,$00,'~' 
	DC.B	$00,'w',$00,$00,$03,'~',$03,'L' 
	DC.B	$03,$1C,$02,$F0,$02,$C5,$02,$9E 
	DC.B	$02,'x',$02,'U',$02,'3',$02,$14 
	DC.B	$01,$F6,$01,$DA,$01,$BF,$01,$A6 
	DC.B	$01,$8E,$01,'x',$01,'c',$01,'O' 
	DC.B	$01,'<',$01,'*',$01,$1A,$01,$0A 
	DC.B	$00,$FB,$00,$ED,$00,$DF,$00,$D3 
	DC.B	$00,$C7,$00,$BC,$00,$B1,$00,$A7 
	DC.B	$00,$9E,$00,$95,$00,$8D,$00,$85 
	DC.B	$00,'}',$00,'v',$00,$00,$03,'w' 
	DC.B	$03,'F',$03,$17,$02,$EA,$02,$C0 
	DC.B	$02,$99,$02,'t',$02,'P',$02,'/' 
	DC.B	$02,$10,$01,$F2,$01,$D6,$01,$BC 
	DC.B	$01,$A3,$01,$8B,$01,'u',$01,'`' 
	DC.B	$01,'L',$01,':',$01,'(',$01,$18 
	DC.B	$01,$08,$00,$F9,$00,$EB,$00,$DE 
	DC.B	$00,$D1,$00,$C6,$00,$BB,$00,$B0 
	DC.B	$00,$A6,$00,$9D,$00,$94,$00,$8C 
	DC.B	$00,$84,$00,'}',$00,'v',$00,$00 
	DC.B	$03,'q',$03,'@',$03,$11,$02,$E5 
	DC.B	$02,$BB,$02,$94,$02,'o',$02,'L' 
	DC.B	$02,'+',$02,$0C,$01,$EE,$01,$D3 
	DC.B	$01,$B9,$01,$A0,$01,$88,$01,'r' 
	DC.B	$01,'^',$01,'J',$01,'8',$01,'&' 
	DC.B	$01,$16,$01,$06,$00,$F7,$00,$E9 
	DC.B	$00,$DC,$00,$D0,$00,$C4,$00,$B9 
	DC.B	$00,$AF,$00,$A5,$00,$9C,$00,$93 
	DC.B	$00,$8B,$00,$83,$00,'{',$00,'u' 
	DC.B	$00,$00,$03,'k',$03,':',$03,$0B 
	DC.B	$02,$E0,$02,$B6,$02,$8F,$02,'k' 
	DC.B	$02,'H',$02,$27,$02,$08,$01,$EB 
	DC.B	$01,$CF,$01,$B5,$01,$9D,$01,$86 
	DC.B	$01,'p',$01,'[',$01,'H',$01,'5' 
	DC.B	$01,'$',$01,$14,$01,$04,$00,$F5 
	DC.B	$00,$E8,$00,$DB,$00,$CE,$00,$C3 
	DC.B	$00,$B8,$00,$AE,$00,$A4,$00,$9B 
	DC.B	$00,$92,$00,$8A,$00,$82,$00,'{' 
	DC.B	$00,'t',$00,$00,$03,'d',$03,'4' 
	DC.B	$03,$06,$02,$DA,$02,$B1,$02,$8B 
	DC.B	$02,'f',$02,'D',$02,'#',$02,$04 
	DC.B	$01,$E7,$01,$CC,$01,$B2,$01,$9A 
	DC.B	$01,$83,$01,'m',$01,'Y',$01,'E' 
	DC.B	$01,'3',$01,'"',$01,$12,$01,$02 
	DC.B	$00,$F4,$00,$E6,$00,$D9,$00,$CD 
	DC.B	$00,$C1,$00,$B7,$00,$AC,$00,$A3 
	DC.B	$00,$9A,$00,$91,$00,$89,$00,$81 
	DC.B	$00,'z',$00,'s',$00,$00,$03,'^' 
	DC.B	$03,'.',$03,$00,$02,$D5,$02,$AC 
	DC.B	$02,$86,$02,'b',$02,'?',$02,$1F 
	DC.B	$02,$01,$01,$E4,$01,$C9,$01,$AF 
	DC.B	$01,$97,$01,$80,$01,'k',$01,'V' 
	DC.B	$01,'C',$01,'1',$01,' ',$01,$10 
	DC.B	$01,$00,$00,$F2,$00,$E4,$00,$D8 
	DC.B	$00,$CB,$00,$C0,$00,$B5,$00,$AB 
	DC.B	$00,$A1,$00,$98,$00,$90,$00,$88 
	DC.B	$00,$80,$00,'y',$00,'r',$00,$00 

voice1	ds.w	10
	dc.w	$1
	ds.w	3

voice2	ds.w	18
	dc.w	$2
	ds.w	3 

voice3	ds.w	18
	DC.w	$4
	ds.w	3

voice4	ds.w	18
	dc.w	$8
	ds.w	3

	ds.w	8 

L00BD	dc.w	0 
L00BE	DC.l	0 
L00BF	DC.w	0 
L00C0	DC.w	0 
L00C1	DC.l	0 
L00C2	DC.B	0 
L00C3	DC.B	0 
L00C4	DC.B	0 
L00C5	DC.B	0 
L00C6	DC.B	0 
L00C7	DC.B	0 
L00C8	DC.B	0 
L00C9	DC.B	0 

L00CA	DC.B	'P',$00,$00,'D',$F4,$00,'P',$00 
	DC.B	$01,$00,$00,$0E,'P',$00,$02,' ' 
	DC.B	$92,$00,'P',$00,$03,'V',$F4,$00 
	DC.B	'P',$00,$04,$00,$00,'IP',$00
	DC.B	$05,' ',$00,'DP',$00,$06,'`'
	DC.B	$F4,$00,'P',$00,$07,$00,'|',$0E 
	DC.B	'P',$00,$08,'"',$11,$00,'P',$00 
	DC.B	$09,$06,$CE,$00,'P',$00,$0A,$00 
	DC.B	$00,$0C,'P',$00,$0B,$07,$DA,$84 
	DC.B	'P',$00,$0C,$07,'X„P',$00 
	DC.B	$0D,$0A,$E1,$80,'P',$00,$0E,$08 
	DC.B	$F4,$A0,'P',$00,$0F,$00,$00,$01 
	DC.B	'P',$00,$10,'0',$00,$00,'P',$00 
	DC.B	$11,' ',$00,$13,'P',$00,$12,$06 
	DC.B	'@',$A0,'P',$00,$13,$07,'XŽ'
	DC.B	'P',$00,$14,$0B,$F0,$80,'P',$00 
	DC.B	$15,$00,'|EP',$00,$16,' ' 
	DC.B	$8F,$00,'P',$00,$17,' ',$00,$0B 
	DC.B	'P',$00,$18,$0A,$F0,$AA,'P',$00 
	DC.B	$19,$00,'|#P',$00,$1A,'`' 
	DC.B	$F4,$00,'P',$00,$1B,$00,'`',$00 
	DC.B	'P',$00,$1C,$0B,$F0,$80,'P',$00 
	DC.B	$1D,$00,'|EP',$00,$1E,$06 
	DC.B	$C4,$00,'P',$00,$1F,$00,'|"'
	DC.B	'P',$00,' ',$0B,$F0,$80,'P',$00 
	DC.B	'!',$00,'|EP',$00,'"',$07 
	DC.B	'X„P',$00,'#',$0B,$F0,$80 
	DC.B	'P',$00,'$',$00,'|EP',$00 
	DC.B	'% ',$90,$00,'P',$00,'& ' 
	DC.B	$8E,$00,'P',$00,$27,'$',$FF,$00 
	DC.B	'P',$00,'( ',$00,'FP',$00 
	DC.B	')%PEP',$00,'*',$0A 
	DC.B	$F0,$AA,'P',$00,'+',$00,'|@'
	DC.B	'P',$00,',',$0B,$F0,$80,'P',$00 
	DC.B	'-',$00,'|EP',$00,'.%'
	DC.B	'XeP',$00,'/',$0A,$F0,$A2 
	DC.B	'P',$00,'0',$00,'|4P',$00 
	DC.B	'1',$07,'`„P',$00,'2',$0A 
	DC.B	$F0,$80,'P',$00,'3',$00,'|#'
	DC.B	'P',$00,'4%YeP',$00 
	DC.B	'5',$0A,$F0,$A2,'P',$00,'6',$00 
	DC.B	'|:P',$00,'7D`',$00 
	DC.B	'P',$00,'8',$0A,$F0,$80,'P',$00 
	DC.B	'9',$00,'|#P',$00,': '
	DC.B	$00,'eP',$00,';',$0A,$F0,$A2
	DC.B	'P',$00,'<',$00,'|#P',$00 
	DC.B	'=L`',$00,'P',$00,'>',$0A 
	DC.B	$F0,$80,'P',$00,'?',$00,'|#'
	DC.B	'P',$00,'@ ',$00,$0B,'P',$00
	DC.B	'A',$0A,$F0,$AA,'P',$00,'B',$00 
	DC.B	$00,$00,'P',$00,'C',$0A,$F0,$80 
	DC.B	'P',$00,'D',$00,'`',$00,'P',$00 
	DC.B	'E',$0A,$A9,$80,'P',$00,'F',$00 
	DC.B	'|EP',$00,'G',$08,'D+'
	DC.B	'P',$00,'H',$00,$00,$0C,$FF,$FF 
	DC.B	$FF,$FF,$FF,$FF 

L00CB	DC.B	'X',$00,$00,$00,$00,$00,'X',$00 
	DC.B	$01,$00,$00,$00,'X',$00,$02,$00 
	DC.B	$00,$00,'X',$00,$03,$00,$00,$00 
	DC.B	'X',$00,$04,$00,$00,$00,'X',$00 
	DC.B	$05,$00,$00,$00,'X',$00,$06,$00 
	DC.B	$00,$00,'X',$00,$07,$00,$00,$00 
	DC.B	'X',$00,$08,$00,$00,$00,'X',$00 
	DC.B	$09,$00,$00,$00,'X',$00,$0A,$00 
	DC.B	$00,$00,'X',$00,$0B,$00,$00,$00 
	DC.B	'X',$00,$0C,$00,$00,$00,'X',$00 
	DC.B	$0D,$00,$00,$00,'X',$00,$0E,$00 
	DC.B	$00,$00,'X',$00,$0F,$00,$00,$00 
	DC.B	'X',$00,$10,$00,$00,$00,'X',$00 
	DC.B	$11,$00,$00,$00,'X',$00,$12,$00 
	DC.B	$00,$00,'X',$00,$13,$00,$00,$00 
	DC.B	'X',$00,$14,$00,$00,$00,'X',$00 
	DC.B	$15,$00,$00,$00,'X',$00,$16,$00 
	DC.B	$00,$00,'X',$00,$17,$00,$00,$00 
	DC.B	'X',$00,$18,$00,$00,$00,'X',$00 
	DC.B	$19,$00,$00,$00,'X',$00,$1A,$00 
	DC.B	$00,$00,'X',$00,$1B,$00,$00,$00 
	DC.B	'X',$00,$1C,$00,$00,$00,'X',$00 
	DC.B	$1D,$00,$00,$00,'X',$00,$1E,$00 
	DC.B	$00,$00,'X',$00,$1F,$00,$00,$00 
	DC.B	'X',$00,' ',$00,$00,$00,'P',$00 
	DC.B	$00,$0A,$F0,$80,'P',$00,$01,$00 
	DC.B	$00,'@P',$00,$10,$0B,$F0,$80
	DC.B	'P',$00,$11,$00,$01,'>P',$00
	DC.B	'@',$08,$F4,$BE,'P',$00,'A',$00 
	DC.B	$00,$00,'P',$00,'B',$08,$F4,$A0 
	DC.B	'P',$00,'C',$00,$00,$01,'P',$00 
	DC.B	'D',$05,$F4,'&P',$00,'E',$00
	DC.B	$07,$FF,'P',$00,'F',$04,'g',$A6 
	DC.B	'P',$00,'G ',$00,$1B,'P',$00
	DC.B	'Hg',$F4,$00,'P',$00,'I',$00
	DC.B	' ',$00,'P',$00,'J',$06,$00,$A8 
	DC.B	'P',$00,'KI_',$00,'P',$00 
	DC.B	'L',$05,$01,$A3,'P',$00,'M',$08 
	DC.B	$F4,$BF,'P',$00,'N',$00,'0',$00 
	DC.B	'P',$00,'O',$08,$F4,$AC,'P',$00 
	DC.B	'P',$00,'A',$00,'P',$00,'Q',$08 
	DC.B	$F4,$AD,'P',$00,'R',$00,'X',$00 
	DC.B	'P',$00,'S',$08,$F4,$A1,'P',$00 
	DC.B	'T',$00,$01,$F0,'P',$00,'U',$08 
	DC.B	$F4,$A3,'P',$00,'V',$00,$00,$08 
	DC.B	'P',$00,'W',$00,$F0,$B8,'P',$00 
	DC.B	'X',$0A,$A9,$80,'P',$00,'Y',$00 
	DC.B	$00,'XP',$00,'Z',$08,'E+' 
	DC.B	'P',$00,'[f',$F4,$00,'P',$00
	DC.B	'\',$00,' ',$00,'P',$00,']g'
	DC.B	$F4,$00,'P',$00,'^',$00,'$',$00 
	DC.B	'P',$00,'_',$0A,$F0,$80,'P',$00 
	DC.B	'`',$00,$00,'dP',$00,'a',$0A
	DC.B	$A9,$80,'P',$00,'b',$00,$00,'a' 
	DC.B	'P',$00,'c',$08,'E+P',$00 
	DC.B	'd',$0A,'p#P',$00,'e',$00 
	DC.B	$FF,$E5,'P',$00,'f"',$EF,$00
	DC.B	'P',$00,'g"',$C4,$00,'P',$00
	DC.B	'hD',$F4,'LP',$00,'i',$00 
	DC.B	$08,$00,'P',$00,'j',$0A,$F0,$A0 
	DC.B	'P',$00,'k',$00,$00,'mP',$00
	DC.B	'l ',$00,'HP',$00,'mW'
	DC.B	' ',$00,'P',$00,'n`',$F4,$00
	DC.B	'P',$00,'o',$00,$02,$00,'P',$00 
	DC.B	'pa',$F4,$00,'P',$00,'q',$00
	DC.B	$00,$04,'P',$00,'r',$0B,$F0,$80 
	DC.B	'P',$00,'s',$00,$01,$0D,'P',$00 
	DC.B	't`',$F4,$00,'P',$00,'u',$00
	DC.B	$06,$00,'P',$00,'va',$F4,$00
	DC.B	'P',$00,'w',$00,$00,$0C,'P',$00 
	DC.B	'x',$0B,$F0,$80,'P',$00,'y',$00 
	DC.B	$01,$0D,'P',$00,'z`',$F4,$00
	DC.B	'P',$00,'{',$00,$0A,$00,'P',$00 
	DC.B	'|a',$F4,$00,'P',$00,'}',$00
	DC.B	$00,$14,'P',$00,'~',$0B,$F0,$80 
	DC.B	'P',$00,$7F,$00,$01,$0D,'P',$00 
	DC.B	$80,'`',$F4,$00,'P',$00,$81,$00 
	DC.B	$0E,$00,'P',$00,$82,'a',$F4,$00 
	DC.B	'P',$00,$83,$00,$00,$1C,'P',$00 
	DC.B	$84,$0B,$F0,$80,'P',$00,$85,$00 
	DC.B	$01,$0D,'P',$00,$86,$0A,'p',$03 
	DC.B	'P',$00,$87,$00,$FF,$E5,'P',$00 
	DC.B	$88,'F',$F4,$00,'P',$00,$89,'p' 
	DC.B	$00,$00,'P',$00,$8A,$27,$00,$00 
	DC.B	'P',$00,$8B,'D',$84,$00,'P',$00 
	DC.B	$8C,' ',$00,$D0,'P',$00,$8D,'V' 
	DC.B	$02,$00,'P',$00,'Ž ',$00,$C0
	DC.B	'P',$00,$8F,'V',$03,$00,'P',$00 
	DC.B	$90,'D',$8C,$00,'P',$00,$91,' ' 
	DC.B	$00,$D0,'P',$00,$92,'V',$0B,$00 
	DC.B	'P',$00,$93,' ',$00,$C0,'P',$00 
	DC.B	$94,'V',$0A,$00,'P',$00,$95,'D' 
	DC.B	$94,$00,'P',$00,$96,' ',$00,$D0 
	DC.B	'P',$00,$97,'V',$13,$00,'P',$00 
	DC.B	$98,' ',$00,$C0,'P',$00,$99,'V' 
	DC.B	$12,$00,'P',$00,'šD',$9C,$00
	DC.B	'P',$00,$9B,' ',$00,$D0,'P',$00 
	DC.B	$9C,'V',$1A,$00,'P',$00,$9D,' ' 
	DC.B	$00,$C0,'P',$00,$9E,'V',$1B,$00 
	DC.B	'P',$00,$9F,'"',$DE,$00,'P',$00 
	DC.B	$A0,$0A,$DA,'`P',$00,$A1,'`'
	DC.B	$F4,$00,'P',$00,$A2,$00,$02,$00 
	DC.B	'P',$00,$A3,'2',$05,$00,'P',$00 
	DC.B	$A4,'3',$02,$00,'P',$00,$A5,$0D 
	DC.B	$00,$B7,'P',$00,$A6,$0A,$DA,'@' 
	DC.B	'P',$00,$A7,'`',$F4,$00,'P',$00 
	DC.B	$A8,$00,$06,$00,'P',$00,$A9,'2' 
	DC.B	$0D,$00,'P',$00,$AA,'3',$0A,$00 
	DC.B	'P',$00,$AB,$0D,$00,$B7,'P',$00 
	DC.B	$AC,'`',$F4,$00,'P',$00,$AD,$00 
	DC.B	$0A,$00,'P',$00,$AE,'2',$15,$00 
	DC.B	'P',$00,$AF,'3',$12,$00,'P',$00 
	DC.B	$B0,$0D,$00,$B7,'P',$00,$B1,'`' 
	DC.B	$F4,$00,'P',$00,$B2,$00,$0E,$00 
	DC.B	'P',$00,$B3,'2',$1D,$00,'P',$00 
	DC.B	$B4,'3',$1A,$00,'P',$00,$B5,$0D 
	DC.B	$00,$B7,'P',$00,$B6,$0C,$00,'a' 
	DC.B	'P',$00,$B7,'a',$F4,$00,'P',$00 
	DC.B	$B8,$00,$12,$00,'P',$00,$B9,'W' 
	DC.B	$D8,$00,'P',$00,$BA,'!',$F9,$00 
	DC.B	'P',$00,$BB,' ',$00,$0B,'P',$00 
	DC.B	$BC,$0B,$F0,$A2,'P',$00,$BD,$00 
	DC.B	$00,$F8,'P',$00,$BE,'a',$F4,$00 
	DC.B	'P',$00,$BF,$00,$12,$00,'P',$00 
	DC.B	$C0,'W',$D8,$00,'P',$00,$C1,' ' 
	DC.B	'I',$00,'P',$00,$C2,'!',$F9,$00 
	DC.B	'P',$00,$C3,'"4',$00,'P',$00
	DC.B	$C4,' ',$00,$0B,'P',$00,$C5,$0A 
	DC.B	$F0,$AA,'P',$00,$C6,$00,$00,$D3 
	DC.B	'P',$00,$C7,$0B,$F0,$80,'P',$00 
	DC.B	$C8,$00,$00,$F8,'P',$00,$C9,'"' 
	DC.B	$91,$00,'P',$00,$CA,'W',$F4,$00 
	DC.B	'P',$00,$CB,$00,$16,$00,'P',$00 
	DC.B	$CC,' I',$00,'P',$00,$CD,'"'
	DC.B	'$',$00,'P',$00,$CE,' ',$00,'L' 
	DC.B	'P',$00,$CF,$06,$CF,$00,'P',$00 
	DC.B	$D0,$00,$00,$D2,'P',$00,$D1,'D' 
	DC.B	$DC,$00,'P',$00,$D2,'DY',$00
	DC.B	'P',$00,$D3,'#',$D6,$00,'P',$00 
	DC.B	$D4,'`',$F4,$00,'P',$00,$D5,$00 
	DC.B	$12,$00,'P',$00,$D6,'D',$DA,$00 
	DC.B	'P',$00,$D7,'E',$D8,$00,'P',$00 
	DC.B	$D8,'F',$DB,$00,'P',$00,$D9,'F' 
	DC.B	$DB,$E0,'P',$00,$DA,'!',$C7,$00 
	DC.B	'P',$00,$DB,' Z',$E0,'P',$00
	DC.B	$DC,'!',$C6,$00,'P',$00,$DD,'W' 
	DC.B	$E2,$00,'P',$00,$DE,'p',$A0,$00 
	DC.B	'P',$00,$DF,$06,$D8,$00,'P',$00 
	DC.B	$E0,$00,$00,$F0,'P',$00,$E1,' ' 
	DC.B	$00,'HP',$00,$E2,$0A,$F0,$A5
	DC.B	'P',$00,$E3,$00,$00,$EB,'P',$00 
	DC.B	$E4,$0A,$CD,'WP',$00,$E5,'E'
	DC.B	$D8,$00,'P',$00,$E6,'F',$DB,$00 
	DC.B	'P',$00,$E7,'F',$DB,$E0,'P',$00 
	DC.B	$E8,'!',$C7,$00,'P',$00,$E9,' ' 
	DC.B	$00,$E0,'P',$00,$EA,'!',$C6,$00 
	DC.B	'P',$00,$EB,'H',$E6,$00,'P',$00 
	DC.B	$EC,$0A,$DA,$00,'P',$00,$ED,$00 
	DC.B	$00,$EF,'P',$00,$EE,' ',$00,$13 
	DC.B	'P',$00,$EF,' ',$00,'0P',$00
	DC.B	$F0,'H^',$00,'P',$00,$F1,'W'
	DC.B	'R',$00,'P',$00,$F2,'"',$0F,$00 
	DC.B	'P',$00,$F3,'D',$F4,$00,'P',$00 
	DC.B	$F4,$00,$12,$01,'P',$00,$F5,' ' 
	DC.B	$00,'LP',$00,$F6,'Wb',$00 
	DC.B	'P',$00,$F7,$00,$00,$0C,'P',$00 
	DC.B	$F8,'D',$F4,'+P',$00,$F9,$00
	DC.B	$00,$01,'P',$00,$FA,' ',$00,'H' 
	DC.B	'P',$00,$FB,$06,$CF,$00,'P',$00 
	DC.B	$FC,$00,$01,$0B,'P',$00,$FD,'D' 
	DC.B	$E0,$00,'P',$00,$FE,'E',$F4,$00 
	DC.B	'P',$00,$FF,$00,$00,$80,'P',$01 
	DC.B	$00,'D',$F4,$A8,'P',$01,$01,$FF 
	DC.B	$00,$00,'P',$01,$02,'!/',$00
	DC.B	'P',$01,$03,'E',$F4,'NP',$01
	DC.B	$04,$00,$80,$00,'P',$01,$05,'U' 
	DC.B	'Y',$00,'P',$01,$06,'D',$D8,$00 
	DC.B	'P',$01,$07,'D',$F4,$A8,'P',$01 
	DC.B	$08,$FF,$00,$00,'P',$01,$09,'!' 
	DC.B	'/',$00,'P',$01,$0A,' ',$00,'N' 
	DC.B	'P',$01,$0B,'UY',$00,'P',$01
	DC.B	$0C,$00,$00,$0C,'P',$01,$0D,$0A 
	DC.B	$A9,$80,'P',$01,$0E,$00,$01,$0D 
	DC.B	'P',$01,$0F,$08,'Y',$AB,'P',$01 
	DC.B	$10,$0A,$A9,$80,'P',$01,$11,$00 
	DC.B	$01,$10,'P',$01,$12,$08,'E+'
	DC.B	'P',$01,$13,'EY',$00,'P',$01
	DC.B	$14,$0A,$A9,$81,'P',$01,$15,$00 
	DC.B	$01,$14,'P',$01,$16,$08,$E1,$AB 
	DC.B	'P',$01,$17,'D',$A0,$00,'P',$01 
	DC.B	$18,' ',$00,$A8,'P',$01,$19,$0A 
	DC.B	$A9,$81,'P',$01,$1A,$00,$01,$19 
	DC.B	'P',$01,$1B,$08,$CF,'+P',$01
	DC.B	$1C,$0A,$A9,$81,'P',$01,$1D,$00 
	DC.B	$01,$1C,'P',$01,$1E,$08,$C4,'+' 
	DC.B	'P',$01,$1F,$0A,$A9,$80,'P',$01 
	DC.B	' ',$00,$01,$1F,'P',$01,'!',$08 
	DC.B	'O+P',$01,'"WX',$00 
	DC.B	'P',$01,'# ',$00,$0B,'P',$01
	DC.B	'$',$0A,$F0,$AA,'P',$01,'%',$00 
	DC.B	$01,'.P',$01,'&D',$F4,'+' 
	DC.B	'P',$01,$27,$00,$00,$01,'P',$01 
	DC.B	'( ',$00,'HP',$01,')',$06 
	DC.B	$CF,$00,'P',$01,'*',$00,$01,'-' 
	DC.B	'P',$01,'+',$0A,$A9,$80,'P',$01 
	DC.B	',',$00,$01,'+P',$01,'-',$08
	DC.B	'X',$AB,'P',$01,'.',$0A,$A9,$80 
	DC.B	'P',$01,'/',$00,$01,'.P',$01
	DC.B	'0',$08,'O+P',$01,'1W'
	DC.B	'X',$00,'P',$01,'2 ',$00,$0B
	DC.B	'P',$01,'3',$0A,$F0,$AA,'P',$01 
	DC.B	'4',$00,$01,'=P',$01,'5D' 
	DC.B	$F4,'+P',$01,'6',$00,$00,$01
	DC.B	'P',$01,'7 ',$00,'HP',$01 
	DC.B	'8',$06,$CF,$00,'P',$01,'9',$00 
	DC.B	$01,'<P',$01,':',$0A,$A9,$80
	DC.B	'P',$01,';',$00,$01,':P',$01
	DC.B	'<',$08,'X',$AB,'P',$01,'=',$00 
	DC.B	$00,$0C,'P',$01,'>',$0A,$AE,$82 
	DC.B	'P',$01,'?',$00,$01,'BP',$01
	DC.B	'@',$08,$DF,$EF,'P',$01,'A',$00 
	DC.B	$00,$04,'P',$01,'B',$08,$E7,$AF 
	DC.B	'P',$01,'C',$00,$00,$04,'P',$01 
	DC.B	'DDSPP',$01,'E-'
	DC.B	'PaP',$01,'Fula'
	DC.B	'P',$01,'G-EmP',$01 
	DC.B	'HulaP',$01,'It'
	DC.B	'orP',$01,'J V2'
	DC.B	'P',$01,'K.0 P',$01 
	DC.B	'LcodP',$01,'Me'
	DC.B	'riP',$01,'Nght'
	DC.B	'P',$01,'O byP',$01 
	DC.B	'P bIP',$01,'QT'
	DC.B	'mAP',$01,'RSTE'
	DC.B	'P',$01,'SR oP',$01 
	DC.B	'Tf BP',$01,'US'
	DC.B	'W P',$01,'Vof '
	DC.B	'P',$01,'WCC ',$FF,$FF
	DC.B	$FF,$FF,$FF,$FF 
;	endc




** mod can be anywhere

mod
		incbin	stardust.mod


	SECTION BSS
org_overscanbtm	ds.w	1
old_vbl		ds.l	1
a09		ds.b	1
a07		ds.b	1
a13		ds.b	1
		even
key		ds.w	1
old_kbd		ds.l	1
vsync_flag	ds.w	1
