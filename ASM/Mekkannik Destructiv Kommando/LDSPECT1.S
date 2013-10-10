adscreen equ $F8000


        BSR     L18E66   * decompactage
        BSR     L18EEE   * vbl init
        MOVE.W  #7,-(SP)
        TRAP #1
        ADDQ.L #2,SP
        BSR     L18F2A   * vbl del
        RTS
        
L18E62	ORI.B	#0,D0

*-------------------------------------------------------------*
*             Decompactage de l'image spectrum                *
*-------------------------------------------------------------*

L18E66	MOVEM.L	D0-D7/A0-A5,-(A7)
       	lea     image+12,a0
       	lea     adscreen,a1
	MOVE.W	#1,D1
	MOVE.W	#7,D7
	LEA	$7D00(A1),A2
	LEA	8(A2),A3
L18E86	LEA	-$7C60(A2),A1
L18E8A	MOVE.B	(A0)+,D6
	EXT.W	D6
	BMI.S	L18E9C
L18E90	MOVE.B	(A0)+,(A1)
	ADDA.W	D1,A1
	EXG	D1,D7
	DBF	D6,L18E90
	BRA.S	L18EAC
L18E9C	NEG.W	D6
	ADDQ.W	#1,D6
	MOVE.B	(A0)+,D0
L18EA2	MOVE.B	D0,(A1)
	ADDA.W	D1,A1
	EXG	D1,D7
	DBF	D6,L18EA2
L18EAC	CMPA.L	A2,A1
	BCS.S	L18E8A
	ADDQ.L	#2,A2
	CMPA.L	A3,A2
	BCS.S	L18E86

*-------------------------------------------------------------*
*             Decompactage  des couleurs de l'image           *
*-------------------------------------------------------------*
        movea.l image+4,a0
        adda.l  #image+12,a0	
	lea     buffer,A1   * ad.palette
	MOVE.W	#$254,D7
	CLR.W	D0
L18EC4	MOVE.W	#$D,D6
	MOVE.W	(A0)+,D1
	LSR.W	#1,D1
	MOVE.W	D0,(A1)+
L18ECE	LSR.W	#1,D1
	BCC.S	L18EDA
	MOVE.W	(A0)+,(A1)+
	DBF	D6,L18ECE
	BRA.S	L18EE0
L18EDA	MOVE.W	D0,(A1)+
	DBF	D6,L18ECE
L18EE0	MOVE.W	D0,(A1)+
	DBF	D7,L18EC4
	MOVEM.L	(A7)+,D0-D7/A0-A5
	RTS

*   init  VBL
	
L18EEE	MOVEM.L	D0-D7/A0-A5,-(A7)
	LEA	L190F0(PC),A5
	MOVE.L	#buffer,(A5)
	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,-(A7)
	MOVE.L	$4CE.W,4(A5)
	LEA	L18F66(PC),A0
	MOVE.L	A0,$4CE.W
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVEM.L	(A7)+,D0-D7/A0-A5
	RTS

*  del VBL
	
L18F2A	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	L190F0(PC),A5
	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,-(A7)
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	MOVE.L	4(A5),$4CE.W
	MOVEA.W	#$8240,A1
	MOVEQ	#7,D0
L18F50	CLR.L	(A1)+
	DBF	D0,L18F50
	MOVE.W	(A7)+,SR
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

* routine spectrum
	
L18F66	TST.W	$43E.W
	BNE	L190EE
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	LEA	$FF8240,A4
	LEA	$FF8209,A5
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	LEA	L18FA2(PC),A6
	MOVEA.L	L190F0(PC),A3
	MOVE.W	#$C4,D7
	MOVEQ	#0,D0
L18F94	TST.B	(A5)
	BEQ.S	L18F94
	MOVE.B	(A5),D0
	ADDA.L	D0,A6
	ADDA.L	L18E62(PC),A6
	JMP	(A6)
L18FA2	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
L1903A	NOP
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	NOP
	DBF	D7,L1903A
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	LEA	-$4A60(A3),A4
	NOP
	NOP
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.W	(A7)+,SR
L190EE	RTS
L190F0	ds.l 2

image   incbin  kathleen.spc
 section bss
buffer  ds.l 19200

