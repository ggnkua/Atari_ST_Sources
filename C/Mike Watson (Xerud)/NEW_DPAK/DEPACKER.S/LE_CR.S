	movem.l	d0-a6,-(a7)
	move.l	a1,a4
	MOVEQ	#$31,D0		; save 1st $32 bytes	
	MOVE.L	A4,-(A7)		; save pack address
	MOVEA.L	A0,A1	
	LEA	buffer(PC),A2	; buffer
.lec00:
	MOVE.B	(A0)+,(A2)+	
	DBF	D0,.lec00

	CMPI.L	#$4C654372,(A1)	; check header	
	BNE.S	.exit	

; A0 now points to proper packed file
; A1 still points to packed file

	ADDA.L	.pk_size(PC),A0	; a0 now points to end
	lea	(a4),a1
	ADDA.L	.upk_size(PC),A1	; a1 now points to real end	
	LEA	$20(A1),A1	; add $20 to it
	MOVEA.L	A1,A2	
	SUBA.L	.upk_size2(PC),A2
	BSR	.lec06	

	MOVEA.L	A2,A1	
	MOVEA.L	(A7),A0	
	MOVEA.L	A0,A2	
	ADDA.L	.upk_size(PC),A2
	MOVE.W	.lec1F(PC),D0
	MOVEQ	#0,D1	
.lec01:
	MOVE.B	(A1)+,D1
	CMP.W	D0,D1	
	BNE.S	.lec03	
	MOVEQ	#0,D2	
	MOVE.B	(A1)+,D2
	BEQ.S	.lec03	
	MOVE.B	(A1)+,D1
.lec02:
	MOVE.B	D1,(A0)+
	DBF	D2,.lec02
	MOVE.B	D1,(A0)+
.lec03:
	MOVE.B	D1,(A0)+
	CMPA.L	A0,A2	
	BGT.S	.lec01	
	LEA	.lec20(PC),A0
	MOVEQ	#$1F,D0	
.lec04:
	MOVE.B	(A0)+,(A2)+	
	DBF	D0,.lec04
.exit:
	ADDQ.W	#4,A7	
	movem.l	(a7)+,d0-a6
	RTS	
.lec06:
	MOVEQ	#-$80,D3
.lec07:
	BSR.S	.lec0B	
	BCC.S	.lec0F	
	BSR.S	.lec0B	
	BCC.S	.lec0A	
	MOVEQ	#3,D0	
	MOVEQ	#8,D2	
.lec08:
	SUBQ.W	#2,D2	
	MOVE.B	.lec14(PC,D0.W),D4	
	BSR.S	.lec0D	
	CMP.W	.lec15(PC,D2.W),D1	
	DBNE	D0,.lec08
	MOVE.B	.lec16(PC,D0.W),D2	
	ADD.W	D1,D2	
.lec09:
	MOVE.B	-(A0),-(A1)	
	DBF	D2,.lec09
.lec0A:
	MOVE.B	-(A0),-(A1)	
	CMPA.L	A1,A2	
	BLE.S	.lec0F	
	RTS	
.lec0B:
	ADD.B	D3,D3	
	BNE.S	.lec0C	
	MOVE.B	-(A0),D3
	ADDX.B	D3,D3	
.lec0C:
	RTS	
.lec0D:
	MOVEQ	#0,D1	
.lec0E:
	BSR.S	.lec0B	
	ADDX.W	D1,D1	
	SUBQ.B	#1,D4	
	BPL.S	.lec0E	
	RTS	
.lec0F:
	MOVEQ	#4,D0	
.lec10:
	BSR.S	.lec0B	
	BCC.S	.lec11	
	SUBQ.W	#1,D0	
	BNE.S	.lec10	
.lec11:
	CLR.W	D1
	MOVE.B	.lec17(PC,D0.W),D4	
	BMI.S	.lec12	
	BSR.S	.lec0D	
.lec12:
	MOVE.B	.lec18(PC,D0.W),D0	
	ADD.W	D1,D0	
	MOVEQ	#2,D4	
	BSR.S	.lec0D	
	MOVE.L	D1,D2	
	MOVE.B	.lec19(PC,D2.W),D4	
	ADD.W	D2,D2	
	BSR.S	.lec0D	
	ADD.W	.lec1A(PC,D2.W),D1	
	MOVEA.L	A1,A3	
	ADDA.L	D1,A3	
.lec13:
	MOVE.B	-(A3),-(A1)	
	DBF	D0,.lec13
	CMPA.L	A1,A2	
	BLE	.lec07	
	RTS	
.lec14:
	DC.B	$09,$02,$01,$00	
.lec15:
	DC.B	$03,$FF,$00,$07,$00,$03,$00,$01	
.lec16:
	DC.B	$0B,$04,$01,$00	
.lec17:
	DC.B	$09,$01,$00,$FF,$FF	
.lec18:
	DC.B	$09,$05,$03,$02,$01	
.lec19:
	DC.B	$03,$05,$05,$06,$07,$08,$09,$0A	
.lec1A:
	DC.B	$00,$01,$00,$11,$00,'Q',$00,$91	
	DC.B	$01,$11,$02,$11,$04,$11,$08,$11	
.buffer:
	DC.B	'LeCr'
.pk_size:
	DCB.W	2,0	
.upk_size:
	DCB.W	2,0	
.upk_size2:
	DCB.W	2,0	
.lec1F:
	DC.B	$00,$00	
.lec20:
	DCB.W	16,0

