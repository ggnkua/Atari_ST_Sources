; The Voice 5
; TFTE
************************************
* prosty program dla Resetu		   *
************************************
* Po uruchomieniu nacisnij RESET   *
* Pamietaj o dograniu obrazka.     *
* Na dysku datkiego brak.		   *
************************************
* Coded by STRych				   *
************************************


	move.w #$20,-(sp)
	trap #1
	addq.l #2,sp
	move.l #$31415926,$426.w
	move.l #reset_program,$42a.w
	
xxx	bra xxx

reset_program
	lea $ffff8240.w,a0
	rept 8
	clr.l (a0)+
	endr
   	move.b #2,$ffff820a
	move.l #$f8000,d0
	move.l d0,$44e.w
    lsr.l   #8,d0
    move.b  d0,$ffff8203
    lsr.l   #8,d0
    move.b  d0,$ffff8201
	move.l $44e.w,a1
	move.l #8000,d0
.lp
	clr.l (a1)+
	dbf d0,.lp
	lea stos(pc),a7

	lea reset_p(pc),a0
	move.l $44e.w,a1
	sub.l #34,a1
	bsr ICE_2.34

	move.l $44e,a0
	sub.l #32,a0
	lea $ffff8240.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
.kl	bra .kl
reset_p
	incbin dupa.pi1				; tu spakowany przez ICE pak 
	even						; obrazek w formacie PI1
ICE_2.34
*	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.S	ICE_00
	CMPI.L	#$49434521,D0
	BNE.S	NO_PACK
	BSR.S	ICE_00
	LEA	-8(A0,D0.L),A5
	BSR.S	ICE_00
*	MOVE.L	D0,(A7)
	MOVEA.L	A1,A4
	MOVEA.L	A1,A6
	ADDA.L	D0,A6
	MOVEA.L	A6,A3
	MOVE.B	-(A5),D7
	BSR.S	ICE_01
NO_PACK	*MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
ICE_00	MOVEQ	#3,D1
ICE_02	LSL.L	#8,D0
	MOVE.B	(A0)+,D0
	DBF	D1,ICE_02
	RTS
ICE_01	BSR.S	ICE_03
	BCC.S	ICE_04
	MOVEQ	#0,D1
	BSR.S	ICE_03
	BCC.S	ICE_05
	LEA	ICE_06(PC),A1
	MOVEQ	#4,D3
*	MOVE.W	#$400,$FFFF8240.W
*	MOVE.W	#$FFF,$FFFF8240.W
ICE_11	MOVE.L	-(A1),D0
	BSR.S	ICE_09
	SWAP	D0
	CMP.W	D0,D1
	DBNE	D3,ICE_11
	ADD.L	$14(A1),D1
ICE_05	MOVE.B	-(A5),-(A6)
	DBF	D1,ICE_05
ICE_04	CMPA.L	A4,A6
	BGT.S	ICE_12
	RTS
ICE_03	ADD.B	D7,D7
	BNE.S	ICE_20
	MOVE.B	-(A5),D7
	ADDX.B	D7,D7
ICE_20	RTS
ICE_09	MOVEQ	#0,D1
ICE_21	ADD.B	D7,D7
	BNE.S	ICE_19
	MOVE.B	-(A5),D7
	ADDX.B	D7,D7
ICE_19	ADDX.W	D1,D1
	DBF	D0,ICE_21
	RTS
ICE_12	LEA	ICE_07(PC),A1
	MOVEQ	#3,D2
ICE_13	BSR.S	ICE_03
	DBCC	D2,ICE_13
	MOVEQ	#0,D4
	MOVEQ	#0,D1
	MOVE.B	1(A1,D2.W),D0
	EXT.W	D0
	BMI.S	ICE_14
	BSR.S	ICE_09
ICE_14	MOVE.B	6(A1,D2.W),D4
	ADD.W	D1,D4
	BEQ.S	ICE_16
	LEA	ICE_08(PC),A1
	MOVEQ	#1,D2
ICE_15	BSR.S	ICE_03
	DBCC	D2,ICE_15
	MOVEQ	#0,D1
	MOVE.B	1(A1,D2.W),D0
	EXT.W	D0
	BSR.S	ICE_09
	ADD.W	D2,D2
	ADD.W	6(A1,D2.W),D1
	BPL.S	ICE_10
	SUB.W	D4,D1
	BRA.S	ICE_10
ICE_16	MOVEQ	#0,D1
	MOVEQ	#5,D0
	MOVEQ	#-1,D2
	BSR.S	ICE_03
	BCC.S	ICE_17
	MOVEQ	#8,D0
	MOVEQ	#$3F,D2
ICE_17	BSR.S	ICE_09
	ADD.W	D2,D1
ICE_10	LEA	2(A6,D4.W),A1
	ADDA.W	D1,A1
	MOVE.B	-(A1),-(A6)
ICE_18	MOVE.B	-(A1),-(A6)
	DBF	D4,ICE_18
	BRA	ICE_01
		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
ICE_06		DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01
ICE_07		DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
ICE_08		DC.B $0b,$04,$07,$00,$01,$1F,$FF,$FF
		DC.B $00,$1F,$33,$FC,$00,$01
		DC.W	$0015,$C80A
		DC.W	$6000,$FEEC
		DC.W	$41F9,$0016
;***************************************************************************
	even
	dcb.l 100
stos
