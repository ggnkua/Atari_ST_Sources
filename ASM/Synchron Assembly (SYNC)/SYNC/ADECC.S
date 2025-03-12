*	opt	d+

p_tbase	PEA	rt(PC)
	MOVE.W	#$26,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	BRA	run

rt	LEA	L1B894(PC),A0
	LEA	$200.W,A1
	MOVE.L	$84.W,$BC.W
	MOVE.L	A1,$84.W
	MOVE.W	#$EE,D0
L1B88C	MOVE.W	(A0)+,(A1)+
	DBF	D0,L1B88C
	RTS
L1B894	MOVEM.L	D0-D5/A0-A3/A6,-(A7)
	LEA	$32(A7),A6
	BTST	#$D,$2C(A7)
	BNE.S	L1B8A6
	MOVE.L	USP,A6
L1B8A6	CMPI.W	#$3D,(A6)
	BNE.S	L1B8C0
	MOVEA.L	2(A6),A0
	CMPI.B	#$53,5(A0)
	BNE.S	L1B8E6
	MOVE.B	-$1C(A0),6(A0)
	BRA.S	L1B8E6
L1B8C0	CMPI.W	#$3F,(A6)
	BNE.S	L1B8E6
	LEA	$C(A6),A0
	MOVEQ	#5,D0
L1B8CC	MOVE.W	-(A0),-(A7)
	DBF	D0,L1B8CC
	TRAP	#15
	LEA	$C(A7),A7
	TST.L	D0
	BMI.S	L1B8DE
	BSR.S	L1B8F0
L1B8DE	MOVE.L	D0,(A7)
	MOVEM.L	(A7)+,D0-D5/A0-A3/A6
	RTE
L1B8E6	MOVEM.L	(A7)+,D0-D5/A0-A3/A6
	MOVE.L	$BC.W,-(A7)
	RTS
L1B8F0	MOVE.W	$FFFF8240.W,-(A7)
	MOVEA.L	8(A0),A1
	MOVEA.L	A1,A2
	CMPI.B	#$4C,(A2)+
	BNE	L1BA6C
	CMPI.B	#$53,(A2)+
	BNE	L1BA6C
	CMPI.B	#$44,(A2)+
	BNE	L1BA6C
	CMPI.B	#$21,(A2)+
	BNE	L1BA6C
	LEA	$60000,A3
	MOVEA.L	A3,A0
	MOVE.L	D0,D1
L1B924	MOVE.B	(A2)+,(A3)+
	SUBQ.L	#1,D1
	BNE.S	L1B924
	MOVE.L	(A0)+,D0
	ADDA.L	D0,A1
	ADDA.L	(A0),A0
	SUBQ.L	#4,A0
	TST.W	-(A0)
	BPL.S	L1B938
	SUBQ.L	#1,A0
L1B938	MOVE.B	-(A0),D5
L1B93A	LSL.B	#1,D5
	BNE.S	L1B942
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1B942	BCC.S	L1B99A
	CLR.W	D1
	LSL.B	#1,D5
	BNE.S	L1B94E
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1B94E	BCC.S	L1B990
	LEA	L1B988(PC),A3
	MOVEQ	#3,D3
L1B956	CLR.W	D1
	MOVE.B	0(A3,D3.W),D2
	EXT.W	D2
	MOVEQ	#-1,D4
	LSL.W	D2,D4
	NOT.W	D4
	SUBQ.W	#1,D2
L1B966	LSL.B	#1,D5
	BNE.S	L1B96E
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1B96E	ROXL.W	#1,D1
	DBF	D2,L1B966
	TST.W	D3
	BEQ.S	L1B97E
	CMP.W	D1,D4
	DBNE	D3,L1B956
L1B97E	MOVE.B	4(A3,D3.W),D2
	EXT.W	D2
	ADD.W	D2,D1
	BRA.S	L1B990
L1B988	dc.b	$a,$3,$2,$2
	dc.b	$e,$7,$4,$1	
L1B990	MOVE.B	-(A0),-(A1)
	MOVE.W	D5,$FFFF8240.W
	DBF	D1,L1B990
L1B99A	LEA	$60000,A3
	ADDQ.L	#8,A3
	CMPA.L	A3,A0
	BLE	L1BA6C
	LEA	L1B9E4(PC),A3
	MOVEQ	#3,D2
L1B9AE	LSL.B	#1,D5
	BNE.S	L1B9B6
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1B9B6	BCC.S	L1B9BC
	DBF	D2,L1B9AE
L1B9BC	CLR.W	D1
	ADDQ.W	#1,D2
	MOVE.B	0(A3,D2.W),D3
	BEQ.S	L1B9D8
	EXT.W	D3
	SUBQ.W	#1,D3
L1B9CA	LSL.B	#1,D5
	BNE.S	L1B9D2
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1B9D2	ROXL.W	#1,D1
	DBF	D3,L1B9CA
L1B9D8	MOVE.B	5(A3,D2.W),D3
	EXT.W	D3
	ADD.W	D3,D1
	BRA	L1B9EE
L1B9E4	dc.b	$a,$2,$1,$0,$0
	dc.b	$a,$6,$4,$3,$2
L1B9EE	CMPI.W	#2,D1
	BEQ.S	L1BA34
	LEA	L1BA28(PC),A3
	MOVEQ	#1,D3
L1B9FA	LSL.B	#1,D5
	BNE.S	L1BA02
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1BA02	BCC.S	L1BA08
	DBF	D3,L1B9FA
L1BA08	ADDQ.W	#1,D3
	CLR.W	D2
	MOVE.B	0(A3,D3.W),D4
	EXT.W	D4
L1BA12	LSL.B	#1,D5
	BNE.S	L1BA1A
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1BA1A	ROXL.W	#1,D2
	DBF	D4,L1BA12
	LSL.W	#1,D3
	ADD.W	4(A3,D3.W),D2
	BRA.S	L1BA58
L1BA28	dc.b	$b,$4,$7,$0,$1
	dc.b	$20,$0,$0,$0
	dc.b	$20,$0,$0
L1BA34	CLR.W	D2
	MOVEQ	#5,D3
	CLR.W	D4
	LSL.B	#1,D5
	BNE.S	L1BA42
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1BA42	BCC.S	L1BA48
	MOVEQ	#8,D3
	MOVEQ	#$40,D4
L1BA48	LSL.B	#1,D5
	BNE.S	L1BA50
	MOVE.B	-(A0),D5
	ROXL.B	#1,D5
L1BA50	ROXL.W	#1,D2
	DBF	D3,L1BA48
	ADD.W	D4,D2
L1BA58	LEA	0(A1,D2.W),A2
	EXT.L	D1
	ADDA.L	D1,A2
	SUBQ.W	#1,D1
L1BA62	MOVE.B	-(A2),-(A1)
	DBF	D1,L1BA62
	BRA	L1B93A
L1BA6C	MOVE.W	(A7)+,$FFFF8240.W
	RTS
	
run	lea	prg_len(pc),a0
	move.l	#endbuf-buffer,(a0)	
	bsr	relog		
	bsr	calc_bp		
	bsr	exec		
relog	lea	buffer(pc),a0
	move.l	2(a0),d0
	add.l	6(a0),d0
	lea	memo(pc),a1
	move.l	d0,(a1)
	tst	$1a(a0)
	bne.s	.stop
	move.l	a0,a1
	add.l	#$1c,a1
	move.l	a1,a2
	add.l	2(a0),a2
	add.l	6(a0),a2
	add.l	14(a0),a2
	clr.l	d1
	lea	p_tbase(pc),a0
	move.l	a0,d2
	move.l	(a2)+,d0
	beq.s	.stop
.1	add.l	d2,0(a1,d0.l)
.2	move.b	(a2)+,d1
	beq.s	.stop
	add.l	d1,d0
	cmp.b	#1,d1
	bne.s	.1
	addi.l	#$fd,d0
	bra.s	.2
.stop	rts

calc_bp move.l	8(a7),a0
	lea	p_tbase(pc),a1
	move.l	a1,d0
	lea	buffer(pc),a1
	move.l	2(a1),12(a0)
	add.l	12(a0),d0
	move.l	d0,16(a0)
	move.l	6(a1),20(a0)
	add.l	20(a0),d0
	move.l	d0,24(a0)
	move.l	10(a1),28(a0)
	rts

exec	addq.l	#4,a7
	lea	p_tbase-$100(pc),a0
	move.l	a0,4(a7)
	move.l	24(a0),a2
	move.l	a2,a3
	add.l	28(a0),a3
	lea	buffer(pc),a0
	add.l	prg_len(pc),a0
	cmp.l	a3,a0
	ble.s	.1
	move.l	a0,a3
.1	move	#9,d0
	lea	transf(pc),a0
	lea	p_tbase(pc),a1
	move.l	a1,-(sp)
.2	move	-(a0),-(sp)
	dbra	d0,.2
	lea	buffer(pc),a0
	add.l	#$1c,a0
	move.l	memo(pc),d0
	jmp	(a7)
.3	move.l	(a0)+,(a1)+
	subq.l	#4,d0
	bpl.s	.3
.4	clr.l	(a2)+
	cmp.l	a2,a3
	bgt.s	.4
	add.l	#$14,sp
	rts
transf
prg_len	dc.l	0
memo	dc.l	0
buffer
		*INCBIN	A:folder.PRG
endbuf
	even

	end



	
