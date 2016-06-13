
lamers	BRA	INIT
		BRA	END
		BRA	PLAY
;adresse de la musique
		DC.L	0
		DC.W	0


INIT	MOVEM.L	D0-A6,-(SP)
;adresse musique
	LEA	lamers(PC),A0
	MOVE.L	12(A0),A0
	LEA	OFFSET(PC),A1
	MOVE.W	#$1D8,POS(A1)
	MOVE.W	#$258,PATT(A1)
	MOVE.W	#$F,NBR(A1)
;module du type 31 instruments ?
	CMP.L	#'M.K.',$438(A0)
	BNE.S	NO_NEW_MODULES
	MOVE.W	#$3B8,POS(A1)
	MOVE.W	#$43C,PATT(A1)
	MOVE.W	#$1F,NBR(A1)
NO_NEW_MODULES
	LEA	lamers(PC),A0
	MOVE.L	12(A0),A0
	LEA	OFFSET(PC),A1
	ADD.W	POS(A1),A0
	MOVEQ	#$7F,D0
	MOVEQ	#0,D1
;nombre de patterns
.LOOP1	MOVE.L	D1,D2
	SUBQ.W	#1,D0
.LOOP2	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	.LOOP1
	DBF	D0,.LOOP2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	LEA	lamers(PC),A0
	MOVE.L	12(A0),A0
	ADD.L	A0,D2
	LEA	$14(A0),A0
	LEA	OFFSET(PC),A1
	MOVE.W	NBR(A1),D7
	ADD.W	PATT(A1),D2
	MOVE.L	D2,A2
	LEA	SAMPLESTARTS(PC),A1
	LEA	(A1),A3
	MOVEQ	#$1E,D6
.LOOP3	CLR.L	(A3)+
	DBRA	D6,.LOOP3
	SUBQ.W	#1,D7
.LOOP4	CLR.L	(A2)
;adresse de debut des samples
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	22(A0),D1
	LSL.L	#1,D1
	MOVE.L	A2,A5
	ADD.L	D1,A2
	MOVE.L	A2,(A1)
	LEA	(A2),A6
	MOVE.W	22(A0),D6
	BEQ.S	.NO_REVERSE
	SUBQ.W	#1,D6
;inverse les samples en memoire
.LOOP5	MOVE.B	(A5),D2
	MOVE.B	-1(A6),D3
;met les samples au format non signes
	EOR.B	#$80,D2
	EOR.B	#$80,D3
	MOVE.B	D3,(A5)+
	MOVE.B	D2,-(A6)
	DBRA	D6,.LOOP5
.NO_REVERSE
	CMP.W	#$0001,28(A0)
	BNE.S	.LOOP6
	CLR.W	28(A0)
.LOOP6	LEA	$1E(A0),A0
	DBRA	D7,.LOOP4
	LEA	CHIP(PC),A0
	LEA	NO_INS(PC),A1
	MOVEQ	#$7,D0
.LOOP7	MOVE.L	A1,(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBRA	D0,.LOOP7
	LEA	VOICES(PC),A0
	MOVEQ	#$1C-1,D0
.LOOP11	CLR.L	(A0)+
	DBRA	D0,.LOOP11
;initialise quelques datas...
	LEA	OFFSET(PC),A0
	MOVE.B	#$6,SPEED(A0)
	CLR.B	SONGPOS(A0)
	CLR.B	COUNTER(A0)
	CLR.W	PATTPOS(A0)
	LEA	DIGIT_SWAP(PC),A0
	LEA	(DIGIT+1000)(PC),A1
	MOVE.L	A1,(A0)
	LEA	DIGIT(PC),A1
	MOVE.L	A1,4(A0)
	MOVE.W	#1000-1,D0
.LOOP8	MOVE.W	#$400,(A1)+
	DBRA	D0,.LOOP8
	LEA	YET(PC),A0
	CMP.L	#'CNX',(A0)
	BEQ.S	.NO_CHANGE
	LEA	SOUND(PC),A0
	MOVE.W	#255,D0
.LOOP9	MOVE.B	5(A0),6(A0)
	MOVE.B	5(A0),7(A0)
	MOVE.B	4(A0),5(A0)
	LEA	8(A0),A0
	DBRA	D0,.LOOP9
	LEA	VOLUME(PC),A0
	MOVE.W	#$3FFF,D0
.LOOP10	MOVE.B	(A0),D1
;transformation de la table de volume
;en donnees 6 bits
	LSR.B	#2,D1
	MOVE.B	D1,(A0)+
	DBRA	D0,.LOOP10
	LEA	YET(PC),A0
	MOVE.L	#'CNX',(A0)
.NO_CHANGE

;yamaha reset
	MOVE.L	#$00000000,$FFFF8800.W
	MOVE.L	#$01010000,$FFFF8800.W
	MOVE.L	#$02020000,$FFFF8800.W
	MOVE.L	#$03030000,$FFFF8800.W
	MOVE.L	#$04040000,$FFFF8800.W
	MOVE.L	#$05050000,$FFFF8800.W
	MOVE.L	#$06060000,$FFFF8800.W
	MOVE.L	#$0707FFFF,$FFFF8800.W
	MOVE.L	#$08080000,$FFFF8800.W
	MOVE.L	#$09090000,$FFFF8800.W
	MOVE.L	#$0A0A0000,$FFFF8800.W
;sauve les interruptions:
	LEA	STORE_INTERRUPTS(PC),A0
;vbl
	MOVE.L	$70.W,$0(A0)
;timer a
	MOVE.L	$134.W,$4(A0)
	LEA	$FFFFFA00.W,A1
;iera et ierb
	MOVEP.W	$7(A1),D0
	MOVE.W	D0,$8(A0)
;imra imrb vr et tacr
	MOVEP.L	$13(A1),D0
	MOVE.L	D0,$A(A0)
	CLR.B	$19(A1)
;tadr
	MOVE.B	$1F(A1),$E(A0)
;mouse off
	MOVE.B	#$12,$FFFFFC02.W
;coupe le mfp
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W
;passage en fin automatique des interruptions
	BCLR.B	#$3,$FFFFFA17.W
	CLR.B	$FFFFFA19.W
;positionne le tadr = registre de data du timer a
	MOVE.B	#FRQ_DATA,$FFFFFA1F.W
;le prediviseur divise par 4
	MOVE.B	#1,$FFFFFA19.W
;le timer a est autorise
	OR.B	#32,$FFFFFA07.W
	OR.B	#32,$FFFFFA13.W
;mise en place du timer a
	LEA	SOUNDCHIP(PC),A0
	MOVE.L	A0,$134.W
	LEA	lamers(PC),A1
	LEA	16(A1),A1
	CMP.W	#1,(A1)
	BNE.S	MV16?
	LEA	ST_REPLAY(PC),A0
	MOVE.L	A0,$134.W
MV16?	CMP.W	#2,(A1)
	BNE.S	SOUNDCHIP?
	LEA	MV16(PC),A0
	MOVE.L	A0,$134.W
SOUNDCHIP?
	MOVEM.L	(SP)+,D0-A6
	RTS

;zone de sauvegarde du contexte du st
STORE_INTERRUPTS	DCB.W	8,0


END	MOVEM.L	D0-A6,-(SP)
;restaure les interruptions:
	LEA	STORE_INTERRUPTS(PC),A0
;la vbl
	MOVE.L	$0(A0),$70.W
;le timer a
	MOVE.L	$4(A0),$134.W
;et le mfp
	LEA	$FFFFFA00.W,A1
	MOVE.L	$A(A0),D0
	MOVEP.L	D0,$13(A1)
	CLR.B	$19(A1)
	MOVE.B	$E(A0),$1F(A1)
	MOVE.B	$D(A0),$19(A1)
	MOVE.W	$8(A0),D0
	MOVEP.W	D0,$7(A1)
;mouse on
	MOVE.B	#$8,$FFFFFC02.W
	MOVEM.L	(SP)+,D0-A6
	RTS


PLAY	MOVE.W	#$2700,SR
	MOVEM.L	D0/A0,-(SP)
;permutation des deux buffers
;de digit  de travail
	LEA	DIGIT_SWAP(PC),A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	LEA	GRRR(PC),A0
	MOVE.L	D0,2(A0)
	LEA	GRR(PC),A0
	MOVE.L	D0,2(A0)
	LEA	GR(PC),A0
	MOVE.L	D0,2(A0)
	MOVEM.L	(SP)+,D0/A0
	MOVE.W	#$2300,SR
;lit la partition et produit
;les effets sonores
	BSR	PLAYER
;calcule la digit a jouer
;a la prochaine vbl
	BSR	PRECALC_DIGIT
	RTS

PLAYER	MOVEM.L	D0-A6,-(SP)
	LEA	OFFSET(PC),A4
	ADDQ.B	#$1,COUNTER(A4)
	MOVE.B	COUNTER(A4),D0
;effets sonore ou nouvelle
;lecture de la partition ?
	CMP.B	SPEED(A4),D0
	BLT.S	NONEW
	CLR.B	COUNTER(A4)
	BRA.S	READ_PATTERN

;produit les effets sonores
;sur les 4 voies
;commandes:0,1,2,3,4,A
NONEW	LEA	CHIP1(PC),A5
	LEA	VOICE1(PC),A6
	BSR	CHECK_COMMAND
	LEA	CHIP2(PC),A5
	LEA	VOICE2(PC),A6
	BSR	CHECK_COMMAND
	LEA	CHIP3(PC),A5
	LEA	VOICE3(PC),A6
	BSR	CHECK_COMMAND
	LEA	CHIP4(PC),A5
	LEA	VOICE4(PC),A6
	BSR	CHECK_COMMAND
	BRA	END_OF_PLAYER

;lit la partition pour les 4 voies
READ_PATTERN
	LEA	lamers(PC),A0
	MOVE.L	12(A0),A0
	LEA	$C(A0),A3
	LEA	(A0),A2
	ADD.W	POS(A4),A2
	ADD.W	PATT(A4),A0

	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	SONGPOS(A4),D0
	MOVE.B	0(A2,D0.W),D1
	SWAP	D1
	LSR.L	#$6,D1
	ADD.W	PATTPOS(A4),D1

	LEA	CHIP1(PC),A5
	LEA	VOICE1(PC),A6
	BSR.S	PLAYVOICE
	LEA	CHIP2(PC),A5
	LEA	VOICE2(PC),A6
	BSR.S	PLAYVOICE
	LEA	CHIP3(PC),A5
	LEA	VOICE3(PC),A6
	BSR.S	PLAYVOICE
	LEA	CHIP4(PC),A5
	LEA	VOICE4(PC),A6
	BSR.S	PLAYVOICE
	BRA	SET_REPEAT

;routine qui traite une voie
PLAYVOICE
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
	BEQ.S	SET_REGS
	MOVEQ	#0,D3
	LEA	SAMPLESTARTS(PC),A1
	MOVE.L	D2,D4
	SUBQ.L	#$1,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	MULU	#$1E,D4
	MOVE.L	(A1,D2.L),$4(A6)
	MOVE.W	(A3,D4.L),$8(A6)
	MOVE.W	$2(A3,D4.L),$12(A6)
	MOVE.W	$4(A3,D4.L),D3
	BRA.S	NO_LOOP
	MOVE.L	$4(A1,D2.L),$4(A6)
	ADD.W	$6(A3,D4.L),D3
	MOVE.W	D3,$8(A6)
	ADD.W	D3,D3
	SUB.L	D3,$4(A6)
	MOVE.L	$4(A6),$A(A6)
	MOVEQ	#0,D3
	MOVE.W	$6(A3,D4.L),D3
	MOVE.W	D3,$E(A6)
	MOVE.W	$12(A6),$8(A5)
	BRA.S	SET_REGS
NO_LOOP
	MOVE.L	$4(A6),$A(A6)
	MOVE.W	$6(A3,D4.L),$E(A6)
	MOVE.W	$12(A6),$8(A5)
SET_REGS
	MOVE.W	(A6),D0
	AND.W	#$FFF,D0
	BEQ	CHECK_COMMAND_2
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	CMP.B	#$3,D0
	BNE.S	SETPERIOD
	BSR	SET_PORTAMENTO_TONE
	BRA	CHECK_COMMAND_2
SETPERIOD
	MOVE.W	(A6),$10(A6)
	AND.W	#$FFF,$10(A6)
	CLR.B	$1B(A6)

	MOVE.L	$4(A6),(A5)
	MOVEQ	#0,D0
	MOVE.W	$8(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$4(A5)
	MOVE.W	$10(A6),$A(A5)
	BRA	CHECK_COMMAND_2

;active les repeat des 4 voies
SET_REPEAT
	MOVEQ	#0,D0
	LEA	CHIP1(PC),A5
	LEA	VOICE1(PC),A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	CHIP2(PC),A5
	LEA	VOICE2(PC),A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	CHIP3(PC),A5
	LEA	VOICE3(PC),A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	CHIP4(PC),A5
	LEA	VOICE4(PC),A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)

	ADD.W	#$10,PATTPOS(A4)
;nouveau pattern?
	CMP.W	#$400,PATTPOS(A4)
	BNE.S	END_OF_PLAYER
NEXT_PATT
	CLR.W	PATTPOS(A4)
	CLR.B	BREAK(A4)
	ADDQ.B	#1,SONGPOS(A4)
	AND.B	#$7F,SONGPOS(A4)
	MOVE.B	SONGPOS(A4),d1
	LEA	lamers(PC),A0
	MOVE.L	12(A0),A0
	ADD.W	POS(A4),A0
	CMP.B	-2(A0),d1
	BNE.S	END_OF_PLAYER
	CLR.B	SONGPOS(A4)
END_OF_PLAYER
	TST.B	BREAK(A4)
	BNE.S	NEXT_PATT
	MOVEM.L	(SP)+,D0-A6
	RTS

;effets sonores qui se produisent
;lorsqu'il ne faut pas lire la partition
CHECK_COMMAND
	MOVE.W	$2(A6),D0
	AND.W	#$FFF,D0
;pas de commande
	BEQ.S	NO_COMMAND
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	BEQ.S	ARPEGGIO
	CMP.B	#$1,D0
	BEQ	PORTAMENTO_UP
	CMP.B	#$2,D0
	BEQ	PORTAMENTO_DOWN
	CMP.B	#$3,D0
	BEQ	PORTAMENTO_TONE
	CMP.B	#$4,D0
	BEQ	VIBRATO
	MOVE.W	$10(A6),$A(A5)
	CMP.B	#$A,D0
	BEQ	VOLUME_SLIDE
NO_COMMAND
	RTS

;commande 0: arpeggio
ARPEGGIO
	MOVEQ	#0,D0
	MOVE.B	COUNTER(A4),D0
	DIVS	#$3,D0
	SWAP	D0
	CMP.W	#$0,D0
	BEQ.S	ARPEGGIO2
	CMP.W	#$2,D0
	BEQ.S	ARPEGGIO1

	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	LSR.B	#$4,D0
	BRA.S	ARPEGGIO3
ARPEGGIO1
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	AND.B	#$F,D0
	BRA.S	ARPEGGIO3
ARPEGGIO2
	MOVE.W	$10(A6),D2
	BRA.S	ARPEGGIO4
ARPEGGIO3
	ADD.W	D0,D0
	MOVEQ	#0,D1
	MOVE.W	$10(A6),D1
	LEA	PERIODS(PC),A0
	MOVEQ	#$24,D7
ARPEGGIO_LOOP
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BGE.S	ARPEGGIO4
	LEA	2(A0),A0
	DBRA	D7,ARPEGGIO_LOOP
	RTS
ARPEGGIO4
	MOVE.W	D2,$A(A5)
	RTS

;commande 1: portamento up
PORTAMENTO_UP
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	SUB.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMP.W	#$71,D0
	BPL.S	PORTUP
	MOVE.W	#$71,$10(A6)
PORTUP	MOVE.W	$10(A6),$A(A5)
	RTS

;commande 2: portamento down
PORTAMENTO_DOWN
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	ADD.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMP.W	#$358,D0
	BMI.S	PORTDWN
	MOVE.W	#$358,$10(A6)
PORTDWN	MOVE.W	$10(A6),$A(A5)
	RTS

;met en place le portamento tone
SET_PORTAMENTO_TONE
	MOVE.W	(A6),D2
	AND.W	#$FFF,D2
	MOVE.W	D2,$18(A6)
	MOVE.W	$10(A6),D0
	CLR.B	$16(A6)
	CMP.W	D0,D2
	BEQ.S	CLR_PORTAMENTO_TONE
	BGE.S	OK_RTS
	MOVE.B	#$1,$16(A6)
	RTS
CLR_PORTAMENTO_TONE
	CLR.W	$18(A6)
OK_RTS
	RTS

;commande 3: portamento tone
PORTAMENTO_TONE
	MOVE.B	$3(A6),D0
	BEQ.S	MY_SLIDE
	MOVE.B	D0,$17(A6)
	CLR.B	$3(A6)
MY_SLIDE
	TST.W	$18(A6)
	BEQ.S	OK_RTS
	MOVEQ	#0,D0
	MOVE.B	$17(A6),D0
	TST.B	$16(A6)
	BNE.S	MY_SUB
	ADD.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BGT.S	MY_OK
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
MY_OK	MOVE.W	$10(A6),$A(A5)
	RTS
MY_SUB
	SUB.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BLT.S	MY_OK
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
	MOVE.W	$10(A6),$A(A5)
	RTS

;commande 4: vibrato
VIBRATO
	MOVE.B	$3(A6),D0
	BEQ.S	VIB
	MOVE.B	D0,$1A(A6)

VIB	MOVE.B	$1B(A6),D0
	LEA	SINUS(PC),A0
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
	BMI.S	VIB_MIN
	ADD.W	D2,D0
	BRA.S	VIB2
VIB_MIN	SUB.W	D2,D0
VIB2	MOVE.W	D0,$A(A5)
	MOVE.B	$1A(A6),D0
	LSR.W	#$2,D0
	AND.W	#$3C,D0
	ADD.B	D0,$1B(A6)
	RTS

;commande $A: volume slide
VOLUME_SLIDE
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	VOLUME_DOWN
	ADD.W	D0,$12(A6)
	CMP.W	#$40,$12(A6)
	BMI.S	VOLUP_OK
	MOVE.W	#$40,$12(A6)
VOLUP_OK
	MOVE.W	$12(A6),$8(A5)
	RTS

VOLUME_DOWN
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	AND.B	#$F,D0
	SUB.W	D0,$12(A6)
	BPL.S	VOLDWN_OK
	CLR.W	$12(A6)
VOLDWN_OK
	MOVE.W	$12(A6),$8(A5)
	RTS

;commandes qui peuvent etre effectuees
;lors de la lecture de la partition
CHECK_COMMAND_2
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	CMP.B	#$B,D0
	BEQ.S	POSITION_JUMP
	CMP.B	#$C,D0
	BEQ.S	SET_VOLUME
	CMP.B	#$D,D0
	BEQ.S	PATTERN_BREAK
	CMP.B	#$E,D0
	BEQ.S	SET_FILTER
	CMP.B	#$F,D0
	BEQ.S	SET_SPEED
;pas de commande
	RTS

;commande $B: postion jump
POSITION_JUMP
	MOVE.B	$3(A6),D0
	SUBQ.B	#$1,D0
	MOVE.B	D0,SONGPOS(A4)
	NOT.B	BREAK(A4)
	RTS

;commande $C: set volume
SET_VOLUME
	CMP.B	#$40,$3(A6)
	BLE.S	VOLUME_OK
	MOVE.B	#$40,$3(A6)
VOLUME_OK
	MOVE.B	$3(A6),$9(A5)
	RTS

;commande $D: pattern break
PATTERN_BREAK
	NOT.B	BREAK(A4)
	RTS

;commande $E: filter
;il n'est pas implemente ici
SET_FILTER
	RTS

;commande $F: set speed
SET_SPEED
	MOVE.B	$3(A6),D0
	AND.W	#$1F,D0
	BEQ.S	NO_CHANGE_SPEED
	CLR.B	COUNTER(A4)
	MOVE.B	D0,SPEED(A4)
NO_CHANGE_SPEED
	RTS


;precalcule la digit qui sera jouee
;lors de la prochaine vbl
PRECALC_DIGIT
	MOVEM.L	D0-A6,-(SP)
	LEA	VOLUME(PC),A3
	LEA	FRQ(PC),A4
	LEA	MEGABUFFER(PC),A5
	LEA	CHIP1(PC),A6
	BSR.S	CALC_VOICE
	LEA	MEGABUFFER+500(PC),A5
	LEA	CHIP2(PC),A6
	BSR.S	CALC_VOICE
	LEA	MEGABUFFER+1000(PC),A5
	LEA	CHIP3(PC),A6
	BSR.S	CALC_VOICE
	LEA	MEGABUFFER+1500(PC),A5
	LEA	CHIP4(PC),A6
	BSR.S	CALC_VOICE

	LEA	MEGABUFFER(PC),A0
	LEA	500(A0),A1
	LEA	500(A1),A2
	LEA	500(A2),A3
	LEA	DIGIT_SWAP(PC),A4
	MOVE.L	4(A4),A4
	BSR	MIX_ALL_VOICES
	MOVEM.L	(SP)+,D0-A6
	RTS

;calcul la digit pour une voie
CALC_VOICE
;adresse ins
	MOVE.L	$0(A6),A0
;valeur decimale du pointeur
	MOVEQ	#0,D1
;longueur du sample
	MOVE.L	$4(A6),D3
;volume
	MOVE.W	$8(A6),D4
	BEQ.S	.VOLUME_NUL
	SUBQ.W	#1,D4
.VOLUME_NUL
	LSL.W	#$8,D4
;repeat lenght
	MOVE.L	$10(A6),D6
;periode
	MOVE.W	$A(A6),D7
;*2
	ADD.W	D7,D7
;*2
	ADD.W	D7,D7
;periode.l
	MOVE.L	(A4,D7.W),D7
;.w bas de la periode
	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
;.w haut de la periode
	MOVE.W	D7,D2
	SWAP	D7
;repeat?
	TST.L	D6
	BNE.S	.0
;pas repeat -> frq=0
	CLR.L	D7
;adresse loop
.0	MOVE.L	$C(A6),A2

	MOVEQ	#FRQ_LOOP,D5
.PAULA
;partie decimale de la frequence
	SUB.W	D0,D1
;partie entiere de la frequence
;+retenue(s'il y a lieu)
	SUBX.W	D2,D3
;fin du sample ?
	BCS.S	.R1
.RR1
;charge le sample
	MOVE.B	0(A0,D3.L),D4
;charge sa correspondance avec le volume
	MOVE.B	0(A3,D4.W),(A5)+
;et on recommence
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.RR2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.RR3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
;la meme routine est executee 3 fois
;cela permet d'eviter 2 dbra
	DBRA	D5,.PAULA
	BRA.S	END_OF_CALC_A_VOICE

.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.RR1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.RR2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.RR3
END_OF_CALC_A_VOICE
;adresse du sample a sauver
	MOVE.L	A0,$0(A6)
;position dans le sample a sauver
	MOVE.L	D3,$4(A6)
	RTS

;mixe les 4 voies
MIX_ALL_VOICES
	MOVEQ	#FRQ_LOOP,D1
.LOOP	MOVEQ	#0,D0
;v1
	MOVE.B	(A0)+,D0
;v1+v2
	ADD.B	(A1)+,D0
;v1+v2+v3
	ADD.B	(A2)+,D0
;v1+v2+v3+v4
	ADD.B	(A3)+,D0
;multiplie par 8
	LSL.W	#3,D0
;sauve le resultat pour etre execute
;la vbl d'apres
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ADD.B	(A1)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A3)+,D0
	LSL.W	#3,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ADD.B	(A1)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A3)+,D0
	LSL.W	#3,D0
	MOVE.W	D0,(A4)+
;la meme routine est executee 3 fois
;cela permet d'eviter 2 dbra
	DBRA	D1,.LOOP
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	RTS

;gestion cartouche mv16
MV16
	MOVEM.L	D0/A0,-(SP)
GR	LEA	DIGIT,A0
;lit le mot de digit
	MOVE.W	(A0),D0
	LEA	(GR+4)(PC),A0
;incremente adresse du buffer
	ADD.W	#2,(A0)
	LEA	$FFFA0000,A0
;format octet pour la cartouche
;du type: %1111111111110
;13 bits avec les 12 bits de poids
;forts de significatif
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.B	0(A0,D0.W),D0
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE

;gestion cartouche st replay
ST_REPLAY
	MOVEM.L	D0/A0,-(SP)
GRR	LEA	DIGIT,A0
;lit le mot de digit
	MOVE.W	(A0),D0
	LEA	(GRR+4)(PC),A0
;incremente adresse du buffer
	ADD.W	#2,(A0)
	LEA	$FFFA0000,A0
;format octet pour la cartouche
;du type: %111111110
;9 bits avec les 8 bits de poids
;forts de significatif
	LSR.W	#2,D0
	MOVE.B	0(A0,D0.W),D0
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE

;gestion yamaha 2149
SOUNDCHIP
	MOVEM.L	D0/A0,-(SP)
GRRR	LEA	DIGIT,A0
;lit le mot de digit
	MOVE.W	(A0),D0
	LEA	(GRRR+4)(PC),A0
;incremente adresse du buffer
	ADD.W	#2,(A0)
;pointe sur la valeur de la table
;st replay pour le soundchip
	LEA	SOUND(PC,D0.W),A0
	MOVE.L	(A0)+,D0
	MOVE.L	(A0),$FFFF8800.W
	LEA	$FFFF8800.W,A0
	MOVEP.L	D0,(A0)
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE

SOUND:
	incbin	"a:\xerox\dst2.tab"
	even
;table pour le vibrato
SINUS
 DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
 DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18
;table pour l'arpeggio
PERIODS
 dc.w $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
 dc.w $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$00FE
 dc.w $00F0,$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097,$008F,$0087
 dc.w $007F,$0078,$0071,$0000,$0000
OFFSET	DCB.W	$6,0
SPEED	EQU	$0
SONGPOS	EQU	$1
PATTPOS	EQU	$2
COUNTER	EQU	$4
BREAK	EQU	$5
POS	EQU	$6
PATT	EQU	$8
NBR	EQU	$A
SAMPLESTARTS	DCB.L	$20,0
VOICES	DCB.L	$1C,0
VOICE1	EQU	VOICES
VOICE2	EQU	VOICES+$1C
VOICE3	EQU	VOICES+$38
VOICE4	EQU	VOICES+$54
CHIP	DCB.L	$18
CHIP1	EQU	CHIP
CHIP2	EQU	CHIP+$18
CHIP3	EQU	CHIP+$30
CHIP4	EQU	CHIP+$48
NO_INS	DC.W	$8080
MEGABUFFER	DCB.L	500
DIGIT	DCB.W	500*2
DIGIT_SWAP	DCB.L	2,0
FRQ_LOOP	EQU	92
FRQ_DATA	EQU	44
FRQ	DC.L	0
	INCBIN	14_KHZ.FRQ
YET	DC.L	0
VOLUME	INCBIN	VOLUME.BIN
