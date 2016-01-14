BLOC1:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	2(A4),D3/D4/D5/D6/D7/A0/A1	* 18
	MOVE.W	30(A4),D0			* 3
	SWAP	D0				* 1
	MOVE.W	(A4),D0				* 2
	MOVE.L	D0,A2				* 1
	MOVEQ	#0,D0				* 1
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC3:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	6(A4),D3/D4/D5/D6/D7/A0		* 16
	MOVE.L	2(A4),A2			* 4
	MOVE.W	30(A4),D0			* 3
	SWAP	D0				* 1
	MOVE.W	(A4),D0				* 2
	MOVE.L	D0,A1				* 1
	MOVEQ	#0,D0				* 1
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC5:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	10(A4),D3/D4/D5/D6/D7		* 14
	MOVE.L	6(A4),A2			* 4
	MOVE.L	2(A4),A1			* 4
	MOVE.W	30(A4),D0			* 3
	SWAP	D0				* 1
	MOVE.W	(A4),D0				* 2
	MOVE.L	D0,A0				* 1
	MOVEQ	#0,D0				* 1
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC7:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	14(A4),D3/D4/D5/D6		* 12
	MOVE.L	10(A4),A2			* 4
	MOVE.L	6(A4),A1			* 4
	MOVE.L	2(A4),A0			* 4
	MOVE.W	30(A4),D0			* 3
	SWAP	D0				* 1
	MOVE.W	(A4),D0				* 2
	MOVE.L	D0,D7				* 1
	MOVEQ	#0,D0				* 1
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC9:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	18(A4),D3/D4/D5			* 10
	MOVEM.L	2(A4),D7/A0/A1/A2		* 12
	MOVE.W	30(A4),D0			* 3
	SWAP	D0				* 1
	MOVE.W	(A4),D0				* 2
	MOVE.L	D0,D6				* 1
	MOVEQ	#0,D0				* 1
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC11:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVE.L	22(A4),D3			* 4
	MOVE.L	26(A4),D4			* 4
	MOVEM.L	2(A4),D6/D7/A0/A1/A2		* 14
	MOVE.W	30(A4),D0			* 3
	SWAP	D0				* 1
	MOVE.W	(A4),D0				* 2
	MOVE.L	D0,D5				* 1
	MOVEQ	#0,D0				* 1
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC13:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVE.L	26(A4),D3			* 4
	MOVEM.L	2(A4),D5/D6/D7/A0/A1/A2		* 16
	MOVE.W	30(A4),D0			* 3
	SWAP	D0				* 1
	MOVE.W	(A4),D0				* 2
	MOVE.L	D0,D4				* 1
	MOVEQ	#0,D0				* 1
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC15:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	2(A4),D4/D5/D6/D7/A0/A1/A2	* 18
	MOVE.W	30(A4),D0			* 3
	SWAP	D0				* 1
	MOVE.W	(A4),D0				* 2
	MOVE.L	D0,D3				* 1
	MOVEQ	#0,D0				* 1
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC0:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	(A4)+,D3/D4/D5/D6/D7/A0/A1/A2	* 19
	ENDM
BLOC2:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	4(A4),D3/D4/D5/D6/D7/A0/A1	* 18
	MOVE.L	(A4),A2				* 3
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC4:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	8(A4),D3/D4/D5/D6/D7/A0		* 16
	MOVE.L	(A4),A1				* 3
	MOVE.L	4(A4),A2			* 4
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC6:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	12(A4),D3/D4/D5/D6/D7		* 14
	MOVE.L	(A4),A0				* 3
	MOVE.L	4(A4),A1			* 4
	MOVE.L	8(A4),A2			* 4
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC8:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	16(A4),D3/D4/D5/D6		* 12
	MOVEM.L	(A4),D7/A0/A1/A2		* 11
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC10:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	20(A4),D3/D4/D5			* 10
	MOVEM.L	(A4),D6/D7/A0/A1/A2		* 13
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC12:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVEM.L	24(A4),D3/D4			* 8
	MOVEM.L	(A4),D5/D6/D7/A0/A1/A2		* 15
	LEA	8*4(A4),A4			* 2
	ENDM
BLOC14:	MACRO
	MOVEM.L	A0/A1/A2,(A3)			* 8
	MOVE.L	28(A4),D3			* 4
	MOVEM.L	(A4),D4/D5/D6/D7/A0/A1/A2	* 17
	LEA	8*4(A4),A4			* 2
	ENDM

overgd0:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC0
	DCB.W	80-27,$4E71
	rts
overgd1:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC1
	DCB.W	80-36,$4E71
	rts
overgd2:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC2
	DCB.W	80-31,$4E71
	rts
overgd3:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC3
	DCB.W	80-38,$4E71
	rts
overgd4:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC4
	DCB.W	80-33,$4E71
	rts
overgd5:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC5
	DCB.W	80-40,$4E71
	rts
overgd6:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC6
	DCB.W	80-35,$4E71
	rts
overgd7:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC7
	DCB.W	80-42,$4E71
	rts
overgd8:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC8
	DCB.W	80-33,$4E71
	rts
overgd9:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC9
	DCB.W	80-40,$4E71
	rts
overgd10:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC10
	DCB.W	80-33,$4E71
	rts
overgd11:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC11
	DCB.W	80-40,$4E71
	rts
overgd12:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC12
	DCB.W	80-33,$4E71
	rts
overgd13:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC13
	DCB.W	80-38,$4E71
	rts
overgd14:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC14
	DCB.W	80-31,$4E71
	rts
overgd15:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	move.b	d2,(a5)
	DCB.W	7,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	LEA	16(A3),A3
	move.b	d0,(a6)
	BLOC15
	DCB.W	80-36,$4E71
	rts
bas0:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC0
	DCB.W	76-27,$4E71
	rts
bas1:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC1
	DCB.W	76-36,$4E71
	rts
bas2:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC2
	DCB.W	76-31,$4E71
	rts
bas3:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC3
	DCB.W	76-38,$4E71
	rts
bas4:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC4
	DCB.W	76-33,$4E71
	rts
bas5:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC5
	DCB.W	76-40,$4E71
	rts
bas6:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC6
	DCB.W	76-35,$4E71
	rts
bas7:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC7
	DCB.W	76-42,$4E71
	rts
bas8:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC8
	DCB.W	76-33,$4E71
	rts
bas9:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC9
	DCB.W	76-40,$4E71
	rts
bas10:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC10
	DCB.W	76-33,$4E71
	rts
bas11:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC11
	DCB.W	76-40,$4E71
	rts
bas12:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC12
	DCB.W	76-33,$4E71
	rts
bas13:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC13
	DCB.W	76-38,$4E71
	rts
bas14:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC14
	DCB.W	76-31,$4E71
	rts
bas15:
	move.b	d0,(a5)
	LEA	$FFFF8240.W,A3
	DCB.W	9,$4E71
	MOVE.L	D3,(A3)+
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	MOVEM.L	D4/D5/D6/D7,(A3)
	NOP
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	LEA	4*4(A3),A3
	move.b	d2,(a5)
	BLOC15
	DCB.W	76-36,$4E71
	rts
