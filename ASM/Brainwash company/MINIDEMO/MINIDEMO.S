
     ; T„m„ on woman's without brains  companyn (vai olikose 
     ; brainwash co?) 1/2 vuoden ty”n tulos, eli minidemo.
     ; 
     ; Vaikka koodi onkin sotkuista ja n„ytt„„ 10v lapsen en-
     ; simm„iselt„ basic-ohjelmalta, se saattaa silti olla 
     ; hy”dyllinen henkil”ille jotka haluavat vihjeit„ 
     ; ruudun ja tekstin vierityksest„.
     ; 
     ; ps.1  Anna t„st„ kopio kaikille kavereillesi!
     ; ps.2  K„yt„ huoletta mit„ tahansa t„m„n sorsan
     ;       rutiinia omissa demoissasi!
     ;
     ;                t: Whack

	CLR.W	-(A7)
	PEA	$78000
	PEA	$78000
	MOVE.W	#5,-(A7)
	TRAP	#14
	DC.W	$A00A
	PEA	L21376
	MOVE.W	#6,-(A7)
	TRAP	#14
	ADDA.L	#$14,A7
	DC.W	$A000
	MOVEA.L	8(A0),A3
	MOVEA.L	$C(A0),A4
	LEA	L21446,A6
	LEA	L21504,A5
	MOVEQ	#$31,D5
L2117A	MOVE.B	(A6)+,D6
	LSL.L	#8,D6
	MOVE.B	(A6)+,D6
	MOVE.W	D6,D7
	SUBQ.W	#1,D7
	CLR.B	(A5)+
	MOVE.B	D7,(A5)+
	LSR.W	#8,D7
	MOVE.B	#1,(A5)+
	MOVE.B	D7,(A5)+
	MOVE.W	D6,D7
	ADDQ.W	#1,D7
	MOVE.B	#2,(A5)+
	MOVE.B	D7,(A5)+
	LSR.W	#8,D7
	MOVE.B	#3,(A5)+
	MOVE.B	D7,(A5)+
	MOVE.B	#$82,(A5)+
	MOVE.B	(A6)+,(A5)+
	MOVE.W	D6,D7
	MOVE.B	#4,(A5)+
	MOVE.B	D7,(A5)+
	LSR.W	#8,D7
	MOVE.B	#5,(A5)+
	MOVE.B	D7,(A5)+
	MOVE.W	#$D09,(A5)+
	DBF	D5,L2117A
	MOVE.L	#$8000900,(A5)+
	MOVE.W	#$FF00,(A5)+
	JSR	L2133A
	MOVE.W	#$EE00,D6
L211D4	MOVE.W	#$F900,D7
L211D8	MOVE.W	D7,D5
	MOVE.W	D6,D4
	CLR.B	D3
L211DE	MOVE.W	D5,D1
	MULS	D1,D1
	LSR.L	#7,D1
	LSR.L	#5,D1
	MOVE.W	D1,D2
	MOVE.W	D4,D1
	MULS	D1,D1
	LSR.L	#7,D1
	LSR.L	#5,D1
	SUB.W	D1,D2
	ADD.W	D7,D2
	MOVE.W	D2,-(A7)
	MOVE.W	D5,D1
	MOVE.W	D4,D2
	MULS	D2,D1
	TST.W	D1
	BMI.S	L21206
	LSR.L	#7,D1
	LSR.L	#4,D1
	BRA.S	L2120E
L21206	NEG.L	D1
	LSR.L	#7,D1
	LSR.L	#4,D1
	NEG.W	D1
L2120E	ADD.W	D6,D1
	MOVE.W	D1,D4
	MOVE.W	(A7)+,D5
	ADDQ.B	#1,D3
	MOVE.W	D5,D1
	MOVE.W	D4,D2
	MULS	D1,D2
	DIVS	#$1000,D2
	CMP.W	#$2000,D2
	BGE.S	L2122E
	CMP.B	#$20,D3
	BGE.S	L2122E
	BRA.S	L211DE
L2122E	MOVE.W	D7,D2
	MULS	#$215,D2
	LSR.L	#7,D2
	LSR.L	#5,D2
	ADDI.W	#$E9,D2
	MOVE.W	D2,(A4)
	MOVE.W	D6,D2
	MULS	#$215,D2
	LSR.L	#7,D2
	LSR.L	#5,D2
	ADDI.W	#$261,D2
	MOVE.W	D2,2(A4)
	LSR.B	#1,D3
	MOVE.W	D3,(A3)
	DC.W	$A001
	ADDI.W	#7,D7
	CMP.W	#$299,D7
	BLE	L211D8
	ADDI.W	#7,D6
	CMP.W	#$F37E,D6
	BLE	L211D4
	JSR	L2133A
L21274	LEA	L2134A,A5
	LEA	L21396,A2     ; T„st„ alkaa scrolli-rutiini
L21280	MOVE.B	(A2),L21375     
	CMPI.B	#1,(A2)+
 	BEQ.S	L21274
	LEA	$78001,A0
	MOVEQ	#7,D0
L21294	MOVEQ	#$12,D1
L21296	MOVE.B	4(A0),3(A0)
	MOVE.B	$B(A0),4(A0)
	ADDQ.W	#8,A0
	DBF	D1,L21296
	MOVE.B	4(A0),3(A0)
	ADDQ.W	#8,A0
	DBF	D0,L21294
	MOVE.W	#$25,-(A7)
	TRAP	#14
	MOVEA.L	(A5)+,A3
	MOVEA.L	(A5)+,A4
	MOVE.L	(A5)+,D0
L212C0	MOVEM.L	(A3)+,D1-D7
	MOVEM.L	D1-D7,(A4)
	ADDA.L	#$1C,A4
	DBF	D0,L212C0
	CMPI.B	#$1B,(A5)
	BNE.S	L212DE
	LEA	L2134A,A5
L212DE	PEA	L2136E
	MOVE.W	#9,-(A7)
	TRAP	#1
	LEA	$78000,A0
	LEA	$7F8A0,A1
	MOVE.W	#$118,D0
L212FA	MOVE.L	(A0)+,(A1)+
	DBF	D0,L212FA
	PEA	$600FF
	TRAP	#1
	ADDA.L	#$C,A7
	TST.W	D0
	BEQ	L21280
	MOVE.W	#1,-(A7)
	PEA	$78000
	PEA	$78000
	MOVE.W	#5,-(A7)
	TRAP	#14
	ADDA.L	#$C,A7
	DC.W	$A009
	PEA	$4800
	TRAP	#1
L2133A	PEA	L214DC
	MOVE.W	#$20,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	RTS

L2134A  dc.l $78500,$7f800,$5       ; Ruudun scrollauksessa
        dc.l $785a0,$78500,$20d     ; tarpeellisia lukuja
        dc.l $7bf1c,$7be7c,$20d

L2136E	MOVE.B	-(A2),$41B(A5)
	SUBQ.B	#4,-(A0)
L21375	DC.W	$4758   

L21376  dc.w $200,$300,$400,$500,$600,$700    ; V„ripaletti
        dc.w $710,$720,$730,$740,$750,$760
        dc.w $770,$773,$775	

L21396  dc.b 'THIS DEMO IS THE SHORTEST ST-DEMO '
        dc.b '(WITH MUSAX AND GRAFIX) IN THE WORLD.'
        dc.b 'IT WAS MADE BY BRAINWASH COMPANY 7.5 '
        dc.b 'AND IT IS LESS THAN 1 KB IN LENGHT. '
        dc.b 'TRY TO BEAT THAT!',0

L21446	BCLR	D0,$1001(A2)     ; TŽMŽK™ MUSIIKKIA?!? 
	DC.W	$7B10            ; HAR HAR!!
	BCHG	D0,-(A6)
	MOVE.B	D1,D0
	MOVE.W	(A0),-(A7)
	BTST	D0,(A4)+
	MOVE.B	D1,D0
	BNE.S	L21468
	BCLR	D0,$2001(A2)
	CMPI.B	#$1C,-(A0)
	MOVE.B	D1,D0
	MOVE.W	(A0),-(A7)
	BTST	D0,(A4)+
	MOVE.B	D1,D0
L21468	BNE.S	L2147A
	BCLR	D0,$2001(A2)
	MOVE.W	(A0),-(A7)
	BCHG	D0,-(A6)
	MOVE.B	D1,D0
	DC.W	$7B10
	BCLR	D0,$1001(A2)
L2147A	ADD.B	(A0),D7
	*BCHG	D0,??
	MOVE.B	D1,D0
	MOVE.W	-(A0),-(A7)
	*BCHG	D0,??
	MOVE.L	D1,D0
	MOVE.B	-(A0),D6
	*BTST	D0,?
	MOVE.L	D1,D0
	MOVE.B	-(A0),D6
	BCLR	D0,$1001(A2)
	DC.W	$7B10
	BCHG	D0,-(A6)
	MOVE.B	D1,D0
	MOVE.W	(A0),-(A7)
	BTST	D0,(A4)+
	MOVE.B	D1,D0
	BNE.S	L214B0
	BCLR	D0,$2000(A2)
	DC.W	$FD20
	BTST	D0,(A4)+
	MOVE.B	D1,D0
	MOVE.W	(A0),-(A7)
	BTST	D0,(A4)+
	MOVE.B	D1,D0
L214B0	BNE.S	L214C2
	BCLR	D0,$2001(A2)
	BNE.S	L214C8
	*BCHG	D0,??
	MOVE.B	D1,D0
	MOVE.B	(A0),D6
	*BCHG	D0,??
	MOVE.B	D1,D0
L214C2	MOVE.W	(A0),-(A7)
	BTST	D0,(A4)+
	MOVE.B	D1,D0
L214C8	DC.W	$7B20
	*BTST	D0,?
	MOVE.B	D1,D0
	MOVE.B	(A0),D6
	BCHG	D0,-(A6)
	MOVE.B	D1,D0
	DC.W	$7B10
	BCLR	D0,$2000(A2)
	ADD.B	D2,(A0)
L214DC	MOVEP.L	D3,$61E(A6)
	BTST	#$10,(A0)
	EORI.B	#$46,(A0)
	ORI.B	#$C,D0
	*MOVEP.W	$82C8(A1),D6
	*ADDI.B	#$C7,??
	CMPI.B	#$E,-(A0)
	*DIVU	?,D1
	*DIVU	?,D1
	BSET	D3,$80E.W
	MOVEP.W	$C60(A6),D4

L21504