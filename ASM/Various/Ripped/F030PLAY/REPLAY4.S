	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr.s	M_SETUP

	move	#$2700,sr
	bsr	M_ON
	move	#$2300,sr
	clr.l	$466.w
	move.w	#0,$ff9800
	moveq	#0,d0
vblank
;	move.l	$446.w,d0
;.wait	cmp.l	$446.w,d0
;	beq.s	.wait
	clr.l	$446.w
	cmp.b	#$39+$80,$fffffc02.w
	bne.s	vblank
	bsr.s	M_OFF
	clr	-(sp)
	trap	#1
M_SETUP	bra	SETUP_MO
M_ON	bra	INT_ON
M_OFF	bra	INT_OFF
SETUP_MO
	move.w	#$80,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	$134.w,OLD_A
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	move.w	#0,-(a7)
	move.w	#8,-(a7)
	move.w	#1,-(a7)
	move.w	#$8B,-(a7)
	trap	#14
	lea	$C(a7),a7
	move.w	#0,-(a7)
	move.w	#1,-(a7)
	move.w	#$89,-(a7)
	trap	#14
	addq.w	#6,a7
	move.w	#1,-(a7)
	move.l	#$1E4,-(a7)
	pea	DSPPROG(pc)
	move.w	#$6E,-(a7)
	trap	#14
	lea	$C(a7),a7
	bsr	MT_INIT
	bra	PREPARE

INT_OFF	move.l	OLD_A(pc),$134.w
	move.b	OLD_19(pc),$FFFFFA19.w
	move.b	OLD_1F(pc),$FFFFFA1F.w
	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	move.w	#0,-(a7)
	move.w	#8,-(a7)
	move.w	#0,-(a7)
	move.w	#$8B,-(a7)
	trap	#14
	lea	$C(a7),a7
	move.w	#1,-(a7)
	move.w	#$84,-(a7)
	trap	#14
	addq.w	#4,a7
	move.w	#$81,-(a7)
	trap	#14
	addq.l	#2,a7
	rts

INT_ON	move.b	$FFFFFA19.w,OLD_19
	move.b	$FFFFFA1F.w,OLD_1F
	bclr	#3,$FFFFFA17.w
	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w
	move.b	#$F6,$FFFFFA1F.w
	move.b	#7,$FFFFFA19.w
	move.l	#NEW_A,$134.w
	rts
OLD_A	DC.L	0
OLD_19	DC.L	0
OLD_1F	DC.L	0
NEW_A
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	#$00000000,$ffff9800.w
	lea	$FFFFA200.w,a6
	clr.b	7(a6)
	lea	CH1S(pc),a1
	bsr.s	SEND_VOICE
	lea	CH2S(pc),a1
	bsr.s	SEND_VOICE
	lea	CH3S(pc),a1
	bsr.s	SEND_VOICE
	lea	CH4S(pc),a1
	bsr.s	SEND_VOICE
	bsr	MT_MUSIC
	move.l	#$fffff00ff,$ffff9800.w
	movem.l	(a7)+,d0-d7/a0-a6
	rte
vbl
	addq.l	#1,$466.w
	rte

SEND_VOICE	
	move.b	$17(a1),5(a6)
	clr.w	6(a6)
	moveq	#0,d0
	move.w	$14(a1),d0
	move.l	#$24665268,d1
	divul.l	d0,d1:d1
	swap	d1
	move.b	d1,5(a6)
	rol.l	#8,d1
	move.b	d1,6(a6)
	rol.l	#8,d1
	move.b	d1,7(a6)
	moveq	#0,d0
.CHECK1	btst	#0,2(a6)
	beq.s	.CHECK1
	move.b	5(a6),d0
	lsl.l	#8,d0
	move.b	6(a6),d0
	lsl.l	#8,d0
	move.b	7(a6),d0
	move.l	(a1),d1
	tst.w	$C(a1)
	bne.s	.NOPS
	add.l	d0,d1
	cmp.l	4(a1),d1
	bcs.s	.NOPS
	sub.l	8(a1),d1
.NOPS	move.l	d1,(a1)
	movea.l	d1,a2
	moveq	#0,d0
.CHECK2	btst	#0,2(a6)
	beq.s	.CHECK2
	move.b	5(a6),d0
	lsl.l	#8,d0
	move.b	6(a6),d0
	lsl.l	#8,d0
	move.b	7(a6),d0
	moveq	#3,d2
	divu.w	d2,d0
	addq.w	#8,d0
	clr.b	5(a6)
	rol.w	#8,d0
	move.b	d0,6(a6)
	rol.w	#8,d0
	move.b	d0,7(a6)
	and.w	d0,d2
	lsr.w	#2,d0
	neg.w	d2
	jmp	.kaka(pc,d2.w*8)
.VAR
	move.b	(a2)+,5(a6)
	move.w	(a2)+,6(a6)
	move.b	(a2)+,5(a6)
	move.w	(a2)+,6(a6)
	move.b	(a2)+,5(a6)
	move.w	(a2)+,6(a6)
	move.b	(a2)+,5(a6)
	move.w	(a2)+,6(a6)
.kaka	dbf	d0,.VAR
	clr.w	$C(a1)
	rts
PREPARE	lea	WORKSPC,a6
	movea.l	MT_SAMPLESTARTS(pc),a0
	movea.l	END_OF_SAMPLE(pc),a1
TOSTACK	move.w	-(a1),-(a6)
	cmpa.l	a0,a1
	bgt.s	TOSTACK
	lea	MT_SAMPLESTARTS(pc),a2
	lea	MODULE,a1
	movea.l	(a2),a0
	movea.l	a0,a5
	moveq	#$1E,d7
ROOP	move.l	a0,(a2)+
	tst.w	$2A(a1)
	beq.s	SAMPLOK
	tst.w	$2E(a1)
	bne.s	REPNEG
REPEQU	move.w	$2A(a1),d0
	move.w	d0,d4
	subq.w	#1,d0
	movea.l	a0,a4
FROMSTK	move.w	(a6)+,(a0)+
	dbf	d0,FROMSTK
	bra.s	REP
REPNEG	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0
	movea.l	a6,a4
GET1ST	move.w	(a4)+,(a0)+
	dbf	d0,GET1ST
	adda.w	$2A(a1),a6
	adda.w	$2A(a1),a6
REP	movea.l	a0,a5
	moveq	#0,d1
TOOSMAL	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
MOVEREP	move.w	(a3)+,(a0)+
	addq.w	#2,d1
	dbf	d0,MOVEREP
	cmp.w	#$320,d1
	blt.s	TOOSMAL
	move.w	#$18F,d2
.LOOP	move.w	(a5)+,(a0)+
	dbf	d2,.LOOP
DONE	add.w	d4,d4
	move.w	d4,$2A(a1)
	move.w	d1,$30(a1)
	clr.w	$2E(a1)
SAMPLOK	lea	$1E(a1),a1
	dbf	d7,ROOP
	cmpa.l	#WORKSPC,a0
	bgt.s	.FLERP
	rts
.FLERP	ILLEGAL
END_OF_SAMPLE
	DC.L	0
MT_INIT	lea	MODULE,a0
	move.l	a0,MT_SONGDATAPOS
	movea.l	a0,a1
	lea	$3B8(a1),a1
	moveq	#$7F,d0
	moveq	#0,d1
MTLOOP	move.l	d1,d2
	subq.w	#1,d0
MTLOOP2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	MTLOOP
	dbf	d0,MTLOOP2
	addq.b	#1,d2
	lea	MT_SAMPLESTARTS(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	addi.l	#$43C,d2
	add.l	a0,d2
	movea.l	d2,a2
	moveq	#$1E,d0
MTLOOP3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	$2A(a0),d1
	asl.l	#1,d1
	adda.l	d1,a2
	lea	$1E(a0),a0
	dbf	d0,MTLOOP3
	move.l	a2,END_OF_SAMPLE
	ori.b	#2,SHFILTER
	move.b	#6,MT_SPEED
	clr.b	MT_COUNTER
	clr.b	MT_SONGPOS
	clr.w	MT_PATTERNPOS
MT_END	move.w	#0,DMACTRL
	rts
MT_MUSIC
	addq.b	#1,MT_COUNTER
	move.b	MT_COUNTER(pc),d0
	cmp.b	MT_SPEED(pc),d0
	bcs.s	MT_NONEWNOTE
	clr.b	MT_COUNTER
	tst.b	MT_PATTDELTIME2
	beq.s	MT_GETNEWNOTE
	bsr.s	MT_NONEWALLCHANNELS
	bra	WZ_NCH4
MT_NONEWNOTE
	bsr.s	MT_NONEWALLCHANNELS
	bra	MT_NONEWPOSYET
MT_NONEWALLCHANNELS
	lea	CH1T(pc),a5
	lea	MT_CHAN1(pc),a6
	bsr	MT_CHECKEFX
	lea	CH2T(pc),a5
	lea	MT_CHAN2(pc),a6
	bsr	MT_CHECKEFX
	lea	CH3T(pc),a5
	lea	MT_CHAN3(pc),a6
	bsr	MT_CHECKEFX
	lea	CH4T(pc),a5
	lea	MT_CHAN4(pc),a6
	bra	MT_CHECKEFX
MT_GETNEWNOTE
	movea.l	MT_SONGDATAPOS(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2
	lea	1084(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	MT_SONGPOS(pc),d0
	move.b	0(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	MT_PATTERNPOS(pc),d1
	clr.w	MT_DMACONTEMP
	lea	CH1T(pc),a5
	lea	MT_CHAN1(pc),a6
	bsr.s	MT_PLAYVOICE
	lea	CH2T(pc),a5
	lea	MT_CHAN2(pc),a6
	bsr.s	MT_PLAYVOICE
	lea	CH3T(pc),a5
	lea	MT_CHAN3(pc),a6
	bsr.s	MT_PLAYVOICE
	lea	CH4T(pc),a5
	lea	MT_CHAN4(pc),a6
	bsr.s	MT_PLAYVOICE
	bra	MT_SETDMA
MT_PLAYVOICE
	tst.l	(a6)
	bne.s	MT_PLVSKIP
	bsr	MT_PERNOP
MT_PLVSKIP
	move.l	0(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	andi.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	andi.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq	MT_SETREGS
	moveq	#0,d3
	lea	MT_SAMPLESTARTS(pc),a1
	move.w	d2,d4
	subq.l	#1,d2
	asl.l	#2,d2
	mulu.w	#$1E,d4
	move.l	0(a1,d2.l),4(a6)
	move.w	0(a3,d4.l),8(a6)
	move.w	0(a3,d4.l),$28(a6)
	move.b	2(a3,d4.l),$12(a6)
	move.b	3(a3,d4.l),$13(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	MT_NOLOOP
	move.l	4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$A(a6)
	move.l	d2,$24(a6)
	move.w	4(a3,d4.l),d0
	add.w	6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	6(a3,d4.l),$E(a6)
	moveq	#0,d0
	move.b	$13(a6),d0
	move.w	d0,8(a5)
	bra.s	MT_SETREGS
MT_NOLOOP
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,$A(a6)
	move.l	d2,$24(a6)
	move.w	6(a3,d4.l),$E(a6)
	moveq	#0,d0
	move.b	$13(a6),d0
	move.w	d0,8(a5)
MT_SETREGS
	move.w	(a6),d0
	andi.w	#$FFF,d0
	beq	MT_CHECKMOREEFX
	move.w	2(a6),d0
	andi.w	#$FF0,d0
	cmp.w	#$E50,d0
	beq.s	MT_DOSETFINETUNE
	move.b	2(a6),d0
	andi.b	#$F,d0
	cmp.b	#3,d0
	beq.s	MT_CHKTONEPORTA
	cmp.b	#5,d0
	beq.s	MT_CHKTONEPORTA
	cmp.b	#9,d0
	bne.s	MT_SETPERIOD
	bsr	MT_CHECKMOREEFX
	bra.s	MT_SETPERIOD
MT_DOSETFINETUNE
	bsr	MT_SETFINETUNE
	bra.s	MT_SETPERIOD
MT_CHKTONEPORTA
	bsr	MT_SETTONEPORTA
	bra	MT_CHECKMOREEFX
MT_SETPERIOD
	movem.l	d0-d1/a0-a1,-(a7)
	move.w	(a6),d1
	andi.w	#$FFF,d1
	lea	MT_PERIODTABLE(pc),a1
	moveq	#0,d0
	moveq	#$24,d7
MT_FTULO
	cmp.w	0(a1,d0.w),d1
	bcc.s	MT_FTUFO
	addq.l	#2,d0
	dbf	d7,MT_FTULO
MT_FTUFO
	moveq	#0,d1
	move.b	$12(a6),d1
	mulu.w	#$48,d1
	adda.l	d1,a1
	move.w	0(a1,d0.w),$10(a6)
	movem.l	(a7)+,d0-d1/a0-a1
	move.w	2(a6),d0
	andi.w	#$FF0,d0
	cmp.w	#$ED0,d0
	beq	MT_CHECKMOREEFX
	move.w	$14(a6),d0
	or.w	d0,DMACTRL
	btst	#2,$1E(a6)
	bne.s	MT_VIBNO
	clr.b	$1B(a6)
MT_VIBNO
	btst	#6,$1E(a6)
	bne.s	MT_TRENO
	clr.b	$1D(a6)
MT_TRENO
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	$10(a6),d0
	move.w	d0,6(a5)
	move.w	$14(a6),d0
	or.w	d0,MT_DMACONTEMP
	bra	MT_CHECKMOREEFX
MT_SETDMA
	move.w	MT_DMACONTEMP(pc),d0
	btst	#0,d0
	beq.s	WZ_NCH1
	moveq	#0,d1
	moveq	#0,d2
	move.w	AUD1LEN(pc),d1
	move.w	MT_CHAN1+14(pc),d2
	add.l	d2,d1
	move.l	CH1T(pc),CH1S
	add.l	CH1T(pc),d1
	move.l	d1,GRF1LEN
	move.l	d2,GRF1RPT
	move.w	#$FFFF,GRF1FLAG
WZ_NCH1	btst	#1,d0
	beq.s	WZ_NCH2
	moveq	#0,d1
	moveq	#0,d2
	move.w	AUD2LEN(pc),d1
	move.w	MT_CHAN2+14(pc),d2
	add.l	d2,d1
	move.l	CH2T(pc),CH2S
	add.l	CH2T(pc),d1
	move.l	d1,GRF2LEN
	move.l	d2,GRF2RPT
	move.w	#$FFFF,GRF2FLAG
WZ_NCH2	btst	#2,d0
	beq.s	WZ_NCH3
	moveq	#0,d1
	moveq	#0,d2
	move.w	AUD3LEN(pc),d1
	move.w	MT_CHAN3+14(pc),d2
	add.l	d2,d1
	move.l	CH3T(pc),CH3S
	add.l	CH3T(pc),d1
	move.l	d1,GRF3LEN
	move.l	d2,GRF3RPT
	move.w	#$FFFF,GRF3FLAG
WZ_NCH3	btst	#3,d0
	beq.s	WZ_NCH4
	moveq	#0,d1
	moveq	#0,d2
	move.w	AUD4LEN(pc),d1
	move.w	MT_CHAN4+14(pc),d2
	add.l	d2,d1
	move.l	CH4T(pc),CH4S
	add.l	CH4T(pc),d1
	move.l	d1,GRF4LEN
	move.l	d2,GRF4RPT
	move.w	#$FFFF,GRF4FLAG
WZ_NCH4	addi.w	#$10,MT_PATTERNPOS
	move.b	MT_PATTDELTIME,d0
	beq.s	MT_DSKC
	move.b	d0,MT_PATTDELTIME2
	clr.b	MT_PATTDELTIME
MT_DSKC	tst.b	MT_PATTDELTIME2
	beq.s	MT_DSKA
	subq.b	#1,MT_PATTDELTIME2
	beq.s	MT_DSKA
	subi.w	#$10,MT_PATTERNPOS
MT_DSKA	tst.b	MT_PBREAKFLAG
	beq.s	MT_NNPYSK
	sf	MT_PBREAKFLAG
	moveq	#0,d0
	move.b	MT_PBREAKPOS(pc),d0
	clr.b	MT_PBREAKPOS
	lsl.w	#4,d0
	move.w	d0,MT_PATTERNPOS
MT_NNPYSK
	cmpi.w	#$400,MT_PATTERNPOS
	bcs.s	MT_NONEWPOSYET
MT_NEXTPOSTITION
	moveq	#0,d0
	move.b	MT_PBREAKPOS(pc),d0
	lsl.w	#4,d0
	move.w	d0,MT_PATTERNPOS
	clr.b	MT_PBREAKPOS
	clr.b	MT_POSJUMPFLAG
	
	addq.b	#1,MT_SONGPOS
	andi.b	#$7F,MT_SONGPOS
	move.b	MT_SONGPOS(pc),d1
	movea.l	MT_SONGDATAPOS(pc),a0
	cmp.b	950(a0),d1
	bcs.s	MT_NONEWPOSYET
	clr.b	MT_SONGPOS
MT_NONEWPOSYET
	tst.b	MT_POSJUMPFLAG
	bne.s	MT_NEXTPOSTITION
	rts
MT_CHECKEFX
	bsr	MT_UPDATEFUNK
	move.w	2(a6),d0
	andi.w	#$FFF,d0
	beq.s	MT_PERNOP
	move.b	2(a6),d0
	andi.b	#$F,d0
	beq.s	MT_ARPEGGIO
	cmp.b	#1,d0
	beq	MT_PORTAUP
	cmp.b	#2,d0
	beq	MT_PORTADOWN
	cmp.b	#3,d0
	beq	MT_TONEPORTOMENTO
	cmp.b	#4,d0
	beq	MT_VIBRATO
	cmp.b	#5,d0
	beq	MT_TONEPLUSVOLSLIDE
	cmp.b	#6,d0
	beq	MT_VIBRATOPLUSVOLSLIDE
	cmp.b	#$E,d0
	beq	MT_E_COMMANDS
SETBACK	move.w	$10(a6),6(a5)
	cmp.b	#7,d0
	beq	MT_TREMOLO
	cmp.b	#$A,d0
	beq	MT_VOLUMESLIDE
MT_RETUR
	rts
MT_PERNOP
MT_NOEFX1
	move.w	$10(a6),6(a5)
MT_RETURN2
	rts
MT_ARPEGGIO
	moveq	#0,d0
	move.b	MT_COUNTER(pc),d0
	divs.w	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	MT_ARPEGGIO2
	cmp.w	#2,d0
	beq.s	MT_ARPEGGIO1
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	MT_ARPEGGIO3
MT_ARPEGGIO1
	moveq	#0,d0
	move.b	3(a6),d0
	andi.b	#$F,d0
	bra.s	MT_ARPEGGIO3
MT_ARPEGGIO2
	move.w	$10(a6),d2
	bra.s	MT_ARPEGGIO4
MT_ARPEGGIO3
	add	D0,d0
	moveq	#0,d1
	move.b	$12(a6),d1
	mulu.w	#$48,d1
	lea	MT_PERIODTABLE(pc),a0
	adda.l	d1,a0
	moveq	#0,d1
	move.w	$10(a6),d1
	moveq	#$24,d7
.MT_ARPLOOP
	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bcc.s	MT_ARPEGGIO4
	addq.l	#2,a0
	dbf	d7,.MT_ARPLOOP
	rts
MT_ARPEGGIO4
	move.w	d2,6(a5)
	rts
MT_FINEPORTAUP
	tst.b	MT_COUNTER
	bne.s	MT_RTS2
	move.b	#$F,MT_LOWMASK
MT_PORTAUP
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	MT_LOWMASK(pc),d0
	move.b	#$FF,MT_LOWMASK
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	andi.w	#$FFF,d0
	cmp.w	#113,d0
	bpl.s	MT_PORTAUSKIP
	andi.w	#$F000,$10(a6)
	ori.w	#$71,$10(a6)
MT_PORTAUSKIP
	move.w	$10(a6),d0
	andi.w	#$FFF,d0
	move.w	d0,6(a5)
MT_RTS2	rts
MT_FINEPORTADOWN
	tst.b	MT_COUNTER
	bne	MT_RTS2
	move.b	#$F,MT_LOWMASK
MT_PORTADOWN
	clr.w	d0
	move.b	3(a6),d0
	and.b	MT_LOWMASK(pc),d0
	move.b	#$FF,MT_LOWMASK
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	andi.w	#$FFF,d0
	cmp.w	#856,d0
	bmi.s	MT_PORTASKIP
	andi.w	#$F000,$10(a6)
	ori.w	#856,$10(a6)
MT_PORTASKIP
	move.w	$10(a6),d0
	andi.w	#$FFF,d0
	move.w	d0,6(a5)
	rts
MT_SETTONEPORTA
	move.l	a0,-(a7)
	move.w	(a6),d2
	andi.w	#$FFF,d2
	moveq	#0,d0
	move.b	$12(a6),d0
	mulu.w	#$48,d0
	lea	MT_PERIODTABLE(pc),a0
	adda.l	d0,a0
	moveq	#0,d0
MT_STPLO
	cmp.w	0(a0,d0.w),d2
	bcc.s	MT_STPFO
	addq.w	#2,d0
	cmp.w	#$48,d0
	bcs.s	MT_STPLO
	moveq	#$46,d0
MT_STPFO
	move.b	$12(a6),d2
	andi.b	#8,d2
	beq.s	MT_STPGOSS
	tst.w	d0
	beq.s	MT_STPGOSS
	subq.w	#2,d0
MT_STPGOSS
	move.w	(a0,d0.w),d2
	movea.l	(a7)+,a0
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	MT_CLEARTONEPORTA
	bge.s	.MT_ET2
	move.b	#1,$16(a6)
.MT_ET2	rts
MT_CLEARTONEPORTA
	clr.w	$18(a6)
MT_ET2	rts
MT_TONEPORTOMENTO
	move.b	3(a6),d0
	beq.s	MT_TONEPORTNOCHANGE
	move.b	d0,$17(a6)
	clr.b	3(a6)
MT_TONEPORTNOCHANGE
	tst.w	$18(a6)
	beq.S	MT_ET2
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	MT_TONEPORTAUP
MT_TONEPORTADOWN
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	MT_TONEPORTASETPER
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	bra.s	MT_TONEPORTASETPER
MT_TONEPORTAUP
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	MT_TONEPORTASETPER
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
MT_TONEPORTASETPER
	move.w	$10(a6),d2
	move.b	$1F(a6),d0
	andi.b	#$F,d0
	beq.s	MT_GLISSKIP
	moveq	#0,d0
	move.b	$12(a6),d0
	mulu.w	#$48,d0
	lea	MT_PERIODTABLE(pc),a0
	adda.w	d0,a0
	moveq	#0,d0
MT_GLISSLOOP
	cmp.w	0(a0,d0.w),d2
	bhs.s	MT_GLISSFOUND
	addq.w	#2,d0
	cmp.w	#36*2,d0
	bcs.s	MT_GLISSLOOP
	moveq	#35*2,d0
MT_GLISSFOUND
	move.w	(a0,d0.w),d2
MT_GLISSKIP
	move.w	d2,6(a5)
	rts
MT_VIBRATO
	move.b	3(a6),d0
	beq.s	MT_VIBRATO2
	move.b	$1A(a6),d2
	andi.b	#$F,d0
	beq.s	MT_VIBSKIP
	andi.b	#$F0,d2
	or.b	d0,d2
MT_VIBSKIP
	move.b	3(a6),d0
	andi.b	#$F0,d0
	beq.s	MT_VIBSKIP2
	andi.b	#$F,d2
	or.b	d0,d2
MT_VIBSKIP2
	move.b	d2,$1A(a6)
MT_VIBRATO2
	move.b	$1B(a6),d0
	lea	MT_VIBRATOTABLE(pc),a4
	lsr.w	#2,d0
	andi.w	#$1F,d0
	moveq	#0,d2
	move.b	$1E(a6),d2
	andi.b	#3,d2
	beq.s	MT_VIB_SINE
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	MT_VIB_RAMPDOWN
	move.b	#$FF,d2
	bra.s	MT_VIB_SET
MT_VIB_RAMPDOWN
	tst.b	$1B(a6)
	bpl.s	MT_VIB_RAMPDOWN2
	move.b	#$FF,d2
	sub.b	d0,d2
	bra.s	MT_VIB_SET
MT_VIB_RAMPDOWN2
	move.b	d0,d2
	bra.s	MT_VIB_SET
MT_VIB_SINE
	move.b	0(a4,d0.w),d2
MT_VIB_SET
	move.b	$1A(a6),d0
	andi.w	#$F,d0
	mulu.w	d0,d2
	lsr.w	#7,d2
	move.w	$10(a6),d0
	tst.b	$1B(a6)
	bmi.s	MT_VIBRATONEG
	add.w	d2,d0
	bra.s	MT_VIBRATO3
MT_VIBRATONEG
	sub.w	d2,d0
MT_VIBRATO3
	move.w	d0,6(a5)
	move.b	$1A(a6),d0
	lsr.w	#2,d0
	andi.w	#$3C,d0
	add.b	d0,$1B(a6)
	rts
MT_TONEPLUSVOLSLIDE
	bsr	MT_TONEPORTNOCHANGE
	bra	MT_VOLUMESLIDE
MT_VIBRATOPLUSVOLSLIDE
	bsr.s	MT_VIBRATO2
	bra	MT_VOLUMESLIDE
MT_TREMOLO
	move.b	3(a6),d0
	beq.s	MT_TREMOLO2
	move.b	$1C(a6),d2
	andi.b	#$F,d0
	beq.s	MT_TRESKIP2
	andi.b	#$F0,d2
	or.b	d0,d2
MT_TRESKIP2
	move.b	3(a6),d0
	andi.b	#$F0,d0
	beq.s	MT_TRESKIP3
	andi.b	#$F,d2
	or.b	d0,d2
MT_TRESKIP3
	move.b	d2,$1C(a6)
MT_TREMOLO2
	move.b	$1D(a6),d0
	lea	MT_VIBRATOTABLE(pc),a4
	lsr.w	#2,d0
	andi.w	#$1F,d0
	moveq	#0,d2
	move.b	$1E(a6),d2
	lsr.b	#4,d2
	andi.b	#3,d2
	beq.s	MT_TRE_SINE
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	MT_TRE_RAMPDOWN
	move.b	#$FF,d2
	bra.s	MT_TRE_SET
MT_TRE_RAMPDOWN
	tst.b	$1B(a6)
	bpl.s	MT_TRE_RAMPDOWN2
	move.b	#$FF,d2
	sub.b	d0,d2
	bra.s	MT_TRE_SET
MT_TRE_RAMPDOWN2
	move.b	d0,d2
	bra.s	MT_TRE_SET
MT_TRE_SINE
	move.b	0(a4,d0.w),d2
MT_TRE_SET
	move.b	$1C(a6),d0
	andi.w	#$F,d0
	mulu.w	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	$13(a6),d0
	tst.b	$1D(a6)
	bpl.s	MT_TREMOLOPLUS
	neg	d2
MT_TREMOLOPLUS
	add.w	d2,d0
MT_TREMOLO3
	bpl.s	MT_TREMOLOSKIP
	clr.w	d0
MT_TREMOLOSKIP
	cmp.w	#$40,d0
	bls.s	MT_TREMOLOOK
	move.w	#$40,d0
MT_TREMOLOOK
	move.w	d0,8(a5)
	move.b	$1C(a6),d0
	lsr.w	#2,d0
	andi.w	#$3C,d0
	add.b	d0,$1D(a6)
	rts
MT_SAMPLEOFFSET
	moveq	#0,d0
	move.b	3(a6),d0
	beq.s	MT_SONONEW
	move.b	d0,$20(a6)
MT_SONONEW
	move.b	$20(a6),d0
	lsl.w	#7,d0
	cmp.w	8(a6),d0
	bge.s	MT_SOFSKIP
	sub.w	d0,8(a6)
	lsl.w	#1,d0
	add.l	d0,4(a6)
	rts
MT_SOFSKIP
	move.w	#1,8(a6)
	rts
MT_VOLUMESLIDE
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	MT_VOLSLIDEDOWN
MT_VOLSLIDEUP
	add.b	d0,$13(a6)
	cmpi.b	#$40,$13(a6)
	bmi.s	MT_VSUSKIP
	move.b	#$40,$13(a6)
MT_VSUSKIP
	move.b	$13(a6),d0
	move.w	d0,8(a5)
	rts
MT_VOLSLIDEDOWN
	moveq	#0,d0
	move.b	3(a6),d0
	andi.b	#$F,d0
MT_VOLSLIDEDOWN2
	sub.b	d0,$13(a6)
	bpl.s	MT_VSDSKIP
	clr.b	$13(a6)
MT_VSDSKIP
	move.b	$13(a6),d0
	move.w	d0,8(a5)
	rts
MT_POSITIONJUMP
	move.b	3(a6),d0
	subq.b	#1,d0
	move.b	d0,MT_SONGPOS
MT_PJ2	clr.b	MT_PBREAKPOS
	st	MT_POSJUMPFLAG
	rts
MT_VOLUMECHANGE
	moveq	#0,d0
	move.b	3(a6),d0
	cmp.b	#$40,d0
	bls.s	MT_VOLUMEOK
	moveq	#$40,d0
MT_VOLUMEOK
	move.b	d0,$13(a6)
	move.w	d0,8(a5)
	rts
MT_PATTERNBREAK
	moveq	#0,d0
	move.b	3(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu.w	#$A,d0
	andi.b	#$F,d2
	add.b	d2,d0
	cmp.b	#$3F,d0
	bhi.s	MT_PJ2
	move.b	d0,MT_PBREAKPOS
	st	MT_POSJUMPFLAG
	rts
MT_SETSPEED
	move.b	3(a6),d0
	beq	.MT_RTS
	clr.b	MT_COUNTER
	move.b	d0,MT_SPEED
.MT_RTS	rts
MT_CHECKMOREEFX
	bsr	MT_UPDATEFUNK
	move.b	2(a6),d0
	andi.b	#$F,d0
	cmp.b	#9,d0
	beq	MT_SAMPLEOFFSET
	cmp.b	#$B,d0
	beq	MT_POSITIONJUMP
	cmp.b	#$D,d0
	beq.s	MT_PATTERNBREAK
	cmp.b	#$E,d0
	beq.s	MT_E_COMMANDS
	cmp.b	#$F,d0
	beq.s	MT_SETSPEED
	cmp.b	#$C,d0
	beq	MT_VOLUMECHANGE
	bra	MT_PERNOP
MT_E_COMMANDS
	move.b	3(a6),d0
	andi.b	#$F0,d0
	lsr.b	#4,d0
	beq.s	MT_FILTERONOFF
	cmp.b	#1,d0
	beq	MT_FINEPORTAUP
	cmp.b	#2,d0
	beq	MT_FINEPORTADOWN
	cmp.b	#3,d0
	beq.s	MT_SETGLISSCONTROL
	cmp.b	#4,d0
	beq	MT_SETVIBRATOCONTROL
	cmp.b	#5,d0
	beq	MT_SETFINETUNE
	cmp.b	#6,d0
	beq	MT_JUMPLOOP
	cmp.b	#7,d0
	beq	MT_SETTREMOLOCONTROL
	cmp.b	#9,d0
	beq	MT_RETRIGNOTE
	cmp.b	#$A,d0
	beq	MT_VOLUMEFINEUP
	cmp.b	#$B,d0
	beq	MT_VOLUMEFINEDOWN
	cmp.b	#$C,d0
	beq	MT_NOTECUT
	cmp.b	#$D,d0
	beq	MT_NOTEDELAY
	cmp.b	#$E,d0
	beq	MT_PATTERNDELAY
	cmp.b	#$F,d0
	beq	MT_FUNKIT
	rts
MT_FILTERONOFF
	move.b	3(a6),d0
	andi.b	#1,d0
	asl.b	#1,d0
	andi.b	#$FD,SHFILTER
	or.b	d0,SHFILTER
MT_E_SK	rts
MT_SETGLISSCONTROL
	move.b	3(a6),d0
	andi.b	#$F,d0
	andi.b	#$F0,$1F(a6)
	or.b	d0,$1F(a6)
	rts
MT_SETVIBRATOCONTROL
	move.b	3(a6),d0
	andi.b	#$F,d0
	andi.b	#$F0,$1E(a6)
	or.b	d0,$1E(a6)
	rts
MT_SETFINETUNE
	move.b	3(a6),d0
	andi.b	#$F,d0
	move.b	d0,$12(a6)
	rts
MT_JUMPLOOP
	tst.b	MT_COUNTER
	bne	MT_RETURN2
	move.b	3(a6),d0
	andi.b	#$F,d0
	beq.s	MT_SETLOOP
	tst.b	$22(a6)
	beq.s	MT_JUMPCUT
	subq.b	#1,$22(a6)
	beq	MT_ERW2
MT_JMPLOOP
	move.b	$21(a6),MT_PBREAKPOS
	st	MT_PBREAKPOS
MT_ERW2	rts
MT_JUMPCUT
	move.b	d0,$22(a6)
	bra.s	MT_JMPLOOP
MT_SETLOOP
	move.w	MT_PATTERNPOS(pc),d0
	lsr.w	#4,d0
	move.b	d0,$21(a6)
	rts
MT_SETTREMOLOCONTROL
	move.b	3(a6),d0
	andi.b	#$F,d0
	lsl.b	#4,d0
	andi.b	#$F,$1E(a6)
	or.b	d0,$1E(a6)
	rts
MT_RETRIGNOTE
	move.l	d1,-(a7)
	moveq	#0,d0
	move.b	3(a6),d0
	andi.b	#$F,d0
	beq.s	MT_RTNEND
	moveq	#0,d1
	move.b	MT_COUNTER(pc),d1
	bne.s	MT_RTNSKP
	move.w	(a6),d1
	andi.w	#$FFF,d1
	bne.s	MT_RTNEND
	moveq	#0,d1
	move.b	MT_COUNTER(pc),d1
MT_RTNSKP
	divu.w	d0,d1
	swap	d1
	tst.w	d1
	bne.s	MT_RTNEND
MT_DORETRIG
	move.w	$14(a6),DMACTRL
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	$14(a6),d0
	bset	#$F,d0
	move.w	d0,DMACTRL
	move.l	$A(a6),(a5)
	move.l	$E(a6),4(a5)
MT_RTNEND	move.l	(a7)+,d1
	rts
MT_VOLUMEFINEUP
	tst.b	MT_COUNTER
	bne.s	MT_WER2
	moveq	#0,d0
	move.b	3(a6),d0
	andi.b	#$F,d0
	bra	MT_VOLSLIDEUP
MT_VOLUMEFINEDOWN
	tst.b	MT_COUNTER
	bne.s	MT_WER2
	moveq	#0,d0
	move.b	3(a6),d0
	andi.b	#$F,d0
	bra	MT_VOLSLIDEDOWN2
MT_NOTECUT
	moveq	#0,d0
	move.b	3(a6),d0
	andi.b	#$F,d0
	cmp.b	MT_COUNTER(pc),d0
	bne	MT_REQ2
	clr.b	$13(a6)
	move.w	#0,8(a5)
MT_WER2	rts
MT_NOTEDELAY
	moveq	#0,d0
	move.b	3(a6),d0
	andi.b	#$F,d0
	cmp.b	MT_COUNTER,d0
	bne	MT_REQ2
	move.w	(a6),d0
	beq	MT_REQ2
	move.l	d1,-(a7)
	bra	MT_DORETRIG
MT_PATTERNDELAY
	tst.b	MT_COUNTER
	bne	MT_RETURN2
	moveq	#0,d0
	move.b	3(a6),d0
	andi.b	#$F,d0
	tst.b	MT_PATTDELTIME2
	bne	MT_RETURN2
	addq.b	#1,d0
	move.b	d0,MT_PATTDELTIME
MT_REQ2	rts
MT_FUNKIT
	tst.b	MT_COUNTER
	bne.s	MT_REQ2
	move.b	3(a6),d0
	andi.b	#$F,d0
	lsl.b	#4,d0
	andi.b	#$F,$1F(a6)
	or.b	d0,$1F(a6)
	tst.b	d0
	beq.s	MT_REQ2
MT_UPDATEFUNK
	movem.l	d1/a0,-(a7)
	moveq	#0,d0
	move.b	$1F(a6),d0
	lsr.b	#4,d0
	beq.s	MT_FUNKEND
	lea	MT_FUNKTABLE(pc),a0
	move.b	0(a0,d0.w),d0
	add.b	d0,$23(a6)
	btst	#7,$23(a6)
	beq.s	MT_FUNKEND
	clr.b	$23(a6)
	move.l	$A(a6),d0
	moveq	#0,d1
	move.w	$E(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	movea.l	$24(a6),a0
	addq.l	#1,a0
	cmpa.l	d0,a0
	blo.s	MT_FUNKOK
	movea.l	$A(a6),a0
MT_FUNKOK
	move.l	a0,$24(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
MT_FUNKEND
	movem.l	(a7)+,d1/a0
	rts
MT_FUNKTABLE
	DC.B	0,5,6,7,8,$A,$B,$D
	DC.B	$10,$13,$16,$1A,$20,$2B,$40,$80
MT_VIBRATOTABLE
	DC.B	0,$18,$31,$4A,$61,$78,$8D,$A1
	DC.B	$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B	$FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5
	DC.B	$B4,$A1,$8D,$78,$61,$4A,$31,$18
MT_PERIODTABLE
	DC.B	3,$58,3,$28,2,$FA,2,$D0
	DC.B	2,$A6,2,$80,2,$5C,2,$3A
	DC.B	2,$1A,1,$FC,1,$E0,1,$C5
	DC.B	1,$AC,1,$94,1,$7D,1,$68
	DC.B	1,$53,1,$40,1,$2E,1,$1D
	DC.B	1,$D,0,$FE,0,$F0,0,$E2
	DC.B	0,$D6,0,$CA,0,$BE,0,$B4
	DC.B	0,$AA,0,$A0,0,$97,0,$8F
	DC.B	0,$87,0,$7F,0,$78,0,$71
	DC.B	3,$52,3,$22,2,$F5,2,$CB
	DC.B	2,$A2,2,$7D,2,$59,2,$37
	DC.B	2,$17,1,$F9,1,$DD,1,$C2
	DC.B	1,$A9,1,$91,1,$7B,1,$65
	DC.B	1,$51,1,$3E,1,$2C,1,$1C
	DC.B	1,$C,0,$FD,0,$EF,0,$E1
	DC.B	0,$D5,0,$C9,0,$BD,0,$B3
	DC.B	0,$A9,0,$9F,0,$96,0,$8E
	DC.B	0,$86,0,$7E,0,$77,0,$71
	DC.B	3,$4C,3,$1C,2,$F0,2,$C5
	DC.B	2,$9E,2,$78,2,$55,2,$33
	DC.B	2,$14,1,$F6,1,$DA,1,$BF
	DC.B	1,$A6,1,$8E,1,$78,1,$63
	DC.B	1,$4F,1,$3C,1,$2A,1,$1A
	DC.B	1,$A,0,$FB,0,$ED,0,$E0
	DC.B	0,$D3,0,$C7,0,$BC,0,$B1
	DC.B	0,$A7,0,$9E,0,$95,0,$8D
	DC.B	0,$85,0,$7D,0,$76,0,$70
	DC.B	3,$46,3,$17,2,$EA,2,$C0
	DC.B	2,$99,2,$74,2,$50,2,$2F
	DC.B	2,$10,1,$F2,1,$D6,1,$BC
	DC.B	1,$A3,1,$8B,1,$75,1,$60
	DC.B	1,$4C,1,$3A,1,$28,1,$18
	DC.B	1,8,0,$F9,0,$EB,0,$DE
	DC.B	0,$D1,0,$C6,0,$BB,0,$B0
	DC.B	0,$A6,0,$9D,0,$94,0,$8C
	DC.B	0,$84,0,$7D,0,$76,0,$6F
	DC.B	3,$40,3,$11,2,$E5,2,$BB
	DC.B	2,$94,2,$6F,2,$4C,2,$2B
	DC.B	2,$C,1,$EF,1,$D3,1,$B9
	DC.B	1,$A0,1,$88,1,$72,1,$5E
	DC.B	1,$4A,1,$38,1,$26,1,$16
	DC.B	1,6,0,$F7,0,$E9,0,$DC
	DC.B	0,$D0,0,$C4,0,$B9,0,$AF
	DC.B	0,$A5,0,$9C,0,$93,0,$8B
	DC.B	0,$83,0,$7C,0,$75,0,$6E
	DC.B	3,$3A,3,$B,2,$E0,2,$B6
	DC.B	2,$8F,2,$6B,2,$48,2,$27
	DC.B	2,8,1,$EB,1,$CF,1,$B5
	DC.B	1,$9D,1,$86,1,$70,1,$5B
	DC.B	1,$48,1,$35,1,$24,1,$14
	DC.B	1,4,0,$F5,0,$E8,0,$DB
	DC.B	0,$CE,0,$C3,0,$B8,0,$AE
	DC.B	0,$A4,0,$9B,0,$92,0,$8A
	DC.B	0,$82,0,$7B,0,$74,0,$6D
	DC.B	3,$34,3,6,2,$DA,2,$B1
	DC.B	2,$8B,2,$66,2,$44,2,$23
	DC.B	2,4,1,$E7,1,$CC,1,$B2
	DC.B	1,$9A,1,$83,1,$6D,1,$59
	DC.B	1,$45,1,$33,1,$22,1,$12
	DC.B	1,2,0,$F4,0,$E6,0,$D9
	DC.B	0,$CD,0,$C1,0,$B7,0,$AC
	DC.B	0,$A3,0,$9A,0,$91,0,$89
	DC.B	0,$81,0,$7A,0,$73,0,$6D
	DC.B	3,$2E,3,0,2,$D5,2,$AC
	DC.B	2,$86,2,$62,2,$3F,2,$1F
	DC.B	2,1,1,$E4,1,$C9,1,$AF
	DC.B	1,$97,1,$80,1,$6B,1,$56
	DC.B	1,$43,1,$31,1,$20,1,$10
	DC.B	1,0,0,$F2,0,$E4,0,$D8
	DC.B	0,$CC,0,$C0,0,$B5,0,$AB
	DC.B	0,$A1,0,$98,0,$90,0,$88
	DC.B	0,$80,0,$79,0,$72,0,$6C
	DC.B	3,$8B,3,$58,3,$28,2,$FA
	DC.B	2,$D0,2,$A6,2,$80,2,$5C
	DC.B	2,$3A,2,$1A,1,$FC,1,$E0
	DC.B	1,$C5,1,$AC,1,$94,1,$7D
	DC.B	1,$68,1,$53,1,$40,1,$2E
	DC.B	1,$1D,1,$D,0,$FE,0,$F0
	DC.B	0,$E2,0,$D6,0,$CA,0,$BE
	DC.B	0,$B4,0,$AA,0,$A0,0,$97
	DC.B	0,$8F,0,$87,0,$7F,0,$78
	DC.B	3,$84,3,$52,3,$22,2,$F5
	DC.B	2,$CB,2,$A3,2,$7C,2,$59
	DC.B	2,$37,2,$17,1,$F9,1,$DD
	DC.B	1,$C2,1,$A9,1,$91,1,$7B
	DC.B	1,$65,1,$51,1,$3E,1,$2C
	DC.B	1,$1C,1,$C,0,$FD,0,$EE
	DC.B	0,$E1,0,$D4,0,$C8,0,$BD
	DC.B	0,$B3,0,$A9,0,$9F,0,$96
	DC.B	0,$8E,0,$86,0,$7E,0,$77
	DC.B	3,$7E,3,$4C,3,$1C,2,$F0
	DC.B	2,$C5,2,$9E,2,$78,2,$55
	DC.B	2,$33,2,$14,1,$F6,1,$DA
	DC.B	1,$BF,1,$A6,1,$8E,1,$78
	DC.B	1,$63,1,$4F,1,$3C,1,$2A
	DC.B	1,$1A,1,$A,0,$FB,0,$ED
	DC.B	0,$DF,0,$D3,0,$C7,0,$BC
	DC.B	0,$B1,0,$A7,0,$9E,0,$95
	DC.B	0,$8D,0,$85,0,$7D,0,$76
	DC.B	3,$77,3,$46,3,$17,2,$EA
	DC.B	2,$C0,2,$99,2,$74,2,$50
	DC.B	2,$2F,2,$10,1,$F2,1,$D6
	DC.B	1,$BC,1,$A3,1,$8B,1,$75
	DC.B	1,$60,1,$4C,1,$3A,1,$28
	DC.B	1,$18,1,8,0,$F9,0,$EB
	DC.B	0,$DE,0,$D1,0,$C6,0,$BB
	DC.B	0,$B0,0,$A6,0,$9D,0,$94
	DC.B	0,$8C,0,$84,0,$7D,0,$76
	DC.B	3,$71,3,$40,3,$11,2,$E5
	DC.B	2,$BB,2,$94,2,$6F,2,$4C
	DC.B	2,$2B,2,$C,1,$EE,1,$D3
	DC.B	1,$B9,1,$A0,1,$88,1,$72
	DC.B	1,$5E,1,$4A,1,$38,1,$26
	DC.B	1,$16,1,6,0,$F7,0,$E9
	DC.B	0,$DC,0,$D0,0,$C4,0,$B9
	DC.B	0,$AF,0,$A5,0,$9C,0,$93
	DC.B	0,$8B,0,$83,0,$7B,0,$75
	DC.B	3,$6B,3,$3A,3,$B,2,$E0
	DC.B	2,$B6,2,$8F,2,$6B,2,$48
	DC.B	2,$27,2,8,1,$EB,1,$CF
	DC.B	1,$B5,1,$9D,1,$86,1,$70
	DC.B	1,$5B,1,$48,1,$35,1,$24
	DC.B	1,$14,1,4,0,$F5,0,$E8
	DC.B	0,$DB,0,$CE,0,$C3,0,$B8
	DC.B	0,$AE,0,$A4,0,$9B,0,$92
	DC.B	0,$8A,0,$82,0,$7B,0,$74
	DC.B	3,$64,3,$34,3,6,2,$DA
	DC.B	2,$B1,2,$8B,2,$66,2,$44
	DC.B	2,$23,2,4,1,$E7,1,$CC
	DC.B	1,$B2,1,$9A,1,$83,1,$6D
	DC.B	1,$59,1,$45,1,$33,1,$22
	DC.B	1,$12,1,2,0,$F4,0,$E6
	DC.B	0,$D9,0,$CD,0,$C1,0,$B7
	DC.B	0,$AC,0,$A3,0,$9A,0,$91
	DC.B	0,$89,0,$81,0,$7A,0,$73
	DC.B	3,$5E,3,$2E,3,0,2,$D5
	DC.B	2,$AC,2,$86,2,$62,2,$3F
	DC.B	2,$1F,2,1,1,$E4,1,$C9
	DC.B	1,$AF,1,$97,1,$80,1,$6B
	DC.B	1,$56,1,$43,1,$31,1,$20
	DC.B	1,$10,1,0,0,$F2,0,$E4
	DC.B	0,$D8,0,$CB,0,$C0,0,$B5
	DC.B	0,$AB,0,$A1,0,$98,0,$90
	DC.B	0,$88,0,$80,0,$79,0,$72

MT_CHAN1	dc.l	0,0,0,0,0,$00010000,0,0,0,0,0
MT_CHAN2	dc.l	0,0,0,0,0,$00020000,0,0,0,0,0
MT_CHAN3	dc.l	0,0,0,0,0,$00040000,0,0,0,0,0
MT_CHAN4	dc.l	0,0,0,0,0,$00080000,0,0,0,0,0
MT_SAMPLESTARTS	
	DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
MT_SONGDATAPOS	DC.L	0
MT_SPEED	DC.B	6
MT_COUNTER	DC.B	0
MT_SONGPOS	DC.B	0
MT_PBREAKPOS	DC.B	0
MT_POSJUMPFLAG	DC.B	0
MT_PBREAKFLAG	DC.B	0
MT_LOWMASK	DC.B	0
MT_PATTDELTIME	DC.B	0
MT_PATTDELTIME2	DC.B	0,0
MT_PATTERNPOS	DC.W	0
MT_DMACONTEMP	DC.W	0
CH1S	DC.B	0,$21,$68,$2C
GRF1LEN	DC.B	0,0,0,0
GRF1RPT	DC.B	0,0,0,0
GRF1FLAG	DC.B	0,0
CH1T	DC.B	0,$21,$68,$2C
AUD1LEN	DC.B	0,8
AUD1PER	DC.B	$1F,$40
AUD1VOL	DC.B	0,0,0,0,0,0,0,0
CH2S	DC.B	0,$21,$68,$2C
GRF2LEN	DC.B	0,0,0,8
GRF2RPT	DC.B	0,0,0,0
GRF2FLAG	DC.B	0,0
CH2T	DC.B	0,$21,$68,$2C
AUD2LEN	DC.B	0,0
AUD2PER	DC.B	$1F,$40
AUD2VOL	DC.B	0,0,0,0,0,0,0,0
CH3S	DC.B	0,$21,$68,$2C
GRF3LEN	DC.B	0,0,0,8
GRF3RPT	DC.B	0,0,0,0
GRF3FLAG	DC.B	0,0
CH3T	DC.B	0,$21,$68,$2C
AUD3LEN	DC.B	0,0
AUD3PER	DC.B	$1F,$40
AUD3VOL	DC.B	0,0,0,0,0,0,0,0
CH4S	DC.B	0,$21,$68,$2C
GRF4LEN	DC.B	0,0,0,8
GRF4RPT	DC.B	0,0,0,0
GRF4FLAG	DC.B	0,0
CH4T	DC.B	0,$21,$68,$2C
AUD4LEN	DC.B	0,8
AUD4PER	DC.B	$1F,$40
AUD4VOL	DC.B	0,0,0,0,0,0,0,0
SHFILTER	DC.w	0
DMACTRL	DC.W	0

DSPPROG	DC.B	$A,$F0,$80,0,0,$40,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	$B,$F0,$80,0,1,$B3,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	8,$F4,$BE,0,0,0,8,$F4
	DC.B	$A0,0,0,1,$66,$F4,0,0
	DC.B	$10,0,5,$F4,$26,0,$13,$FF
	DC.B	$67,$F4,0,0,$10,$64,4,$67
	DC.B	$A6,$20,0,$1B,$70,$F4,0,0
	DC.B	$14,0,6,$D8,0,0,0,$50
	DC.B	$5F,$5E,0,$20,0,$13,$56,$70
	DC.B	0,0,0,6,$56,$70,0,0
	DC.B	0,5,$56,$70,0,0,0,$D
	DC.B	$56,$70,0,0,0,$C,$56,$70
	DC.B	0,0,0,$14,$56,$70,0,0
	DC.B	0,$13,$56,$70,0,0,0,$1B
	DC.B	$56,$70,0,0,0,$1A,$56,$F4
	DC.B	0,0,0,0,$57,$F4,0,0
	DC.B	0,0,$56,$70,0,0,0,1
	DC.B	$57,$70,0,0,0,2,$57,$70
	DC.B	0,0,0,8,$56,$70,0,0
	DC.B	0,9,$57,$70,0,0,0,$F
	DC.B	$56,$70,0,0,0,$10,$56,$70
	DC.B	0,0,0,$16,$57,$70,0,0
	DC.B	0,$17,8,$F4,$BF,0,$30,0
	DC.B	8,$F4,$AC,0,$41,0,8,$F4
	DC.B	$AD,0,$58,0,8,$F4,$A1,0
	DC.B	1,$F0,8,$F4,$A3,0,0,8
	DC.B	0,$FC,$B8,$A,$A9,$80,0,0
	DC.B	$81,8,$45,$2B,$22,$ED,0,$A
	DC.B	$CD,$20,0,0,$84,$22,$C4,0
	DC.B	$20,0,$4C,$A,$F0,$A3,0,0
	DC.B	$8E,$44,$F4,0,0,$14,0,$20
	DC.B	0,$48,$20,0,$2A,$57,$70,0
	DC.B	0,0,$1C,$22,$D5,0,$60,$F4
	DC.B	0,0,3,0,$61,$F4,0,0
	DC.B	0,3,$B,$F0,$80,0,1,$B5
	DC.B	$60,$F4,0,0,4,$7C,$61,$F4
	DC.B	0,0,0,$A,$B,$F0,$80,0
	DC.B	1,$B5,$60,$F4,0,0,5,$F8
	DC.B	$61,$F4,0,0,0,$11,$B,$F0
	DC.B	$80,0,1,$B5,$60,$F4,0,0
	DC.B	7,$74,$61,$F4,0,0,0,$18
	DC.B	$B,$F0,$80,0,1,$B5,$46,$F4
	DC.B	0,$78,0,0,$47,$F4,0,0
	DC.B	0,0,$44,$F0,0,0,0,3
	DC.B	$20,0,$D0,$56,$70,0,0,0
	DC.B	1,$20,0,$C0,$56,$70,0,0
	DC.B	0,2,$44,$F0,0,0,0,$A
	DC.B	$20,0,$D0,$56,$70,0,0,0
	DC.B	9,$20,0,$C0,$56,$70,0,0
	DC.B	0,8,$44,$F0,0,0,0,$11
	DC.B	$20,0,$D0,$56,$70,0,0,0
	DC.B	$10,$20,0,$C0,$56,$70,0,0
	DC.B	0,$F,$44,$F0,0,0,0,$18
	DC.B	$20,0,$D0,$56,$70,0,0,0
	DC.B	$16,$20,0,$C0,$56,$70,0,0
	DC.B	0,$17,$60,$F4,0,0,3,0
	DC.B	$B,$F0,$80,0,1,$CE,$60,$F4
	DC.B	0,0,8,$F0,$57,$F0,0,0
	DC.B	0,6,$44,$F0,0,0,0,4
	DC.B	$70,$F0,0,0,0,$1C,6,$D8
	DC.B	0,0,0,$FA,$20,0,$48,$A
	DC.B	$F0,$A5,0,0,$E1,$A,$CD,$57
	DC.B	$45,$D8,0,$45,$D8,0,$47,$D0
	DC.B	0,$46,$F0,0,0,0,1,$20
	DC.B	0,$E0,$21,$C5,0,$20,0,$B0
	DC.B	$21,$E6,$64,$21,$C7,0,$20,0
	DC.B	$B0,$20,0,$60,$21,$C5,0,$4D
	DC.B	$5E,0,$45,$D8,0,$47,$D0,0
	DC.B	$46,$F0,0,0,0,2,$20,0
	DC.B	$E0,$21,$C5,0,$20,0,$B0,$21
	DC.B	$E6,$64,$21,$C7,0,$20,0,$B0
	DC.B	$20,0,$60,$21,$C5,0,$4D,$5E
	DC.B	0,$57,$70,0,0,0,6,$22
	DC.B	$F,0,$44,$F4,0,0,8,$F0
	DC.B	$20,0,$4C,$57,$70,0,0,0
	DC.B	5,$60,$F4,0,0,4,$7C,$B
	DC.B	$F0,$80,0,1,$CE,$22,$B6,0
	DC.B	$60,$F4,0,0,8,$F0,$57,$F0
	DC.B	0,0,0,$D,$44,$F0,0,0
	DC.B	0,$B,$70,$F0,0,0,0,$1C
	DC.B	6,$D8,0,0,1,$34,$20,0
	DC.B	$48,$A,$F0,$A5,0,1,$17,$A
	DC.B	$CD,$57,$45,$D8,0,$45,$D8,0
	DC.B	$47,$D0,0,$46,$F0,0,0,0
	DC.B	8,$20,0,$E0,$21,$C5,0,$20
	DC.B	0,$B0,$21,$E6,$64,$21,$C7,0
	DC.B	$20,0,$B0,$20,0,$60,$21,$C5
	DC.B	0,$5E,$E6,0,$20,0,$60,$5E
	DC.B	$5E,0,$45,$D8,0,$47,$D0,0
	DC.B	$46,$F0,0,0,0,9,$20,0
	DC.B	$E0,$21,$C5,0,$20,0,$B0,$21
	DC.B	$E6,$64,$21,$C7,0,$20,0,$B0
	DC.B	$20,0,$60,$21,$C5,0,$5E,$E6
	DC.B	0,$20,0,$60,$5E,$5E,0,$57
	DC.B	$70,0,0,0,$D,$22,$F,0
	DC.B	$44,$F4,0,0,8,$F0,$20,0
	DC.B	$4C,$57,$70,0,0,0,$C,$60
	DC.B	$F4,0,0,5,$F8,$B,$F0,$80
	DC.B	0,1,$CE,$22,$B6,0,$60,$F4
	DC.B	0,0,8,$F0,$57,$F0,0,0
	DC.B	0,$14,$44,$F0,0,0,0,$12
	DC.B	$70,$F0,0,0,0,$1C,6,$D8
	DC.B	0,0,1,$6E,$20,0,$48,$A
	DC.B	$F0,$A5,0,1,$51,$A,$CD,$57
	DC.B	$45,$D8,0,$45,$D8,0,$47,$D0
	DC.B	0,$46,$F0,0,0,0,$F,$20
	DC.B	0,$E0,$21,$C5,0,$20,0,$B0
	DC.B	$21,$E6,$64,$21,$C7,0,$20,0
	DC.B	$B0,$20,0,$60,$21,$C5,0,$5E
	DC.B	$E6,0,$20,0,$60,$5E,$5E,0
	DC.B	$45,$D8,0,$47,$D0,0,$46,$F0
	DC.B	0,0,0,$10,$20,0,$E0,$21
	DC.B	$C5,0,$20,0,$B0,$21,$E6,$64
	DC.B	$21,$C7,0,$20,0,$B0,$20,0
	DC.B	$60,$21,$C5,0,$5E,$E6,0,$20
	DC.B	0,$60,$5E,$5E,0,$57,$70,0
	DC.B	0,0,$14,$22,$F,0,$44,$F4
	DC.B	0,0,8,$F0,$20,0,$4C,$57
	DC.B	$70,0,0,0,$13,$60,$F4,0
	DC.B	0,7,$74,$B,$F0,$80,0,1
	DC.B	$CE,$22,$B6,0,$60,$F4,0,0
	DC.B	8,$F0,$57,$F0,0,0,0,$1B
	DC.B	$44,$F0,0,0,0,$19,$70,$F0
	DC.B	0,0,0,$1C,6,$D8,0,0
	DC.B	1,$A8,$20,0,$48,$A,$F0,$A5
	DC.B	0,1,$8B,$A,$CD,$57,$45,$D8
	DC.B	0,$45,$D8,0,$47,$D0,0,$46
	DC.B	$F0,0,0,0,$16,$20,0,$E0
	DC.B	$21,$C5,0,$20,0,$B0,$21,$E6
	DC.B	$64,$21,$C7,0,$20,0,$B0,$20
	DC.B	0,$60,$21,$C5,0,$5E,$E6,0
	DC.B	$20,0,$60,$5E,$5E,0,$45,$D8
	DC.B	0,$47,$D0,0,$46,$F0,0,0
	DC.B	0,$17,$20,0,$E0,$21,$C5,0
	DC.B	$20,0,$B0,$21,$E6,$64,$21,$C7
	DC.B	0,$20,0,$B0,$20,0,$60,$21
	DC.B	$C5,0,$5E,$E6,0,$20,0,$60
	DC.B	$5E,$5E,0,$57,$70,0,0,0
	DC.B	$1B,$22,$F,0,$44,$F4,0,0
	DC.B	8,$F0,$20,0,$4C,$57,$70,0
	DC.B	0,0,$1A,$A,$F0,$80,0,0
	DC.B	$81,8,$DF,$EF,0,0,4,$A
	DC.B	$A9,$80,0,1,$B5,8,$59,$AB
	DC.B	$A,$A9,$80,0,1,$B8,8,$45
	DC.B	$2B,$45,$59,0,$44,$F0,0,0
	DC.B	0,$1C,$20,0,$A8,$A,$A9,$81
	DC.B	0,1,$BF,8,$E1,$AB,$A,$A9
	DC.B	$81,0,1,$C2,8,$CF,$2B,$A
	DC.B	$A9,$80,0,1,$C5,8,$44,$2B
	DC.B	6,$C4,0,0,1,$CC,$A,$A9
	DC.B	$80,0,1,$CA,8,$58,$AB,0
	DC.B	0,$C,$46,$F4,0,$FF,0,0
	DC.B	$61,$F4,0,0,8,$F0,6,$7C
	DC.B	$81,0,1,$E2,$57,$E0,0,$45
	DC.B	$F4,$5E,0,0,$80,$55,$59,0
	DC.B	$44,$E0,0,$20,0,$A8,$21,$2F
	DC.B	0,$45,$F4,$5E,0,$80,0,$55
	DC.B	$59,0,$44,$D8,0,$20,0,$A8
	DC.B	$21,$2F,0,$20,0,$5E,$55,$59
	DC.B	0,0,0,$C
MODULE
	incbin	"d:\music\modules\overload.mod"
	DS.B	$20000	
WORKSPC