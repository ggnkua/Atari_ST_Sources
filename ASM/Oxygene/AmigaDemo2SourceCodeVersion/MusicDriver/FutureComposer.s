;*************************************************************************
;
; AMIGA Future Composer v1.4 player
; v1.3 support added by Leonard
; Changed for "Oxygene Paula Emulator" compatible
;
;*************************************************************************


		bra.w	fcInit
		bra.w	fcTick
		bra.w	fcEnd


fcEnd:
	moveq	#$f,d0
	trap	#1		;bsr	writeDmacon
	rts

fcInit:

	move.l	a1,pCustom

;	bset #1,$bfe001
	lea	pModule(pc),a1
	move.l	a0,(a1)


	lea		dataClearStart(pc),a1
	move.w	#(dataClearEnd - dataClearStart) - 1,d1
.dClear:
	clr.b	(a1)+
	dbf		d1,.dClear

	tst.b	bSoundBankReloc
	bne.s	.already
	
	lea		FCSoundBank(pc),a1
	move.l	a1,d1
	lea		SOUNDINFO+90*16(pc),a1
	move.w	#256-90-1,d2
.rLoop:
	add.l	d1,(a1)
	lea		16(a1),a1
	dbf		d2,.rLoop
	st		bSoundBankReloc
	
	
.already:


	move.w #1,onoff

	lea		bFc14(pc),a1
	cmpi.l	#'FC14',(a0)
	seq		(a1)

	lea	100(a0),a1
	tst.b	bFc14
	beq.s	.no14
	lea		180(a0),a1
.no14:
	move.l a1,SEQpoint
	move.l a0,a1
	add.l 8(a0),a1
	move.l a1,PATpoint
	move.l a0,a1
	add.l 16(a0),a1
	move.l a1,FRQpoint
	move.l a0,a1
	add.l 24(a0),a1
	move.l a1,VOLpoint

	lea 40(a0),a1
	lea SOUNDINFO+4(pc),a2
	moveq #10-1,d1
initloop:
	move.w (a1)+,(a2)+
	move.l (a1)+,(a2)+
	adda.w #10,a2
	dbf d1,initloop

	move.l a0,d1
	add.l 32(a0),d1
	lea SOUNDINFO(pc),a3
	move.l d1,(a3)+
	moveq #9-1,d3
	moveq #0,d2
	
	moveq	#0,d4
	tst.b	bFc14
	beq.s	.no142
	moveq	#2,d4
.no142:
	
	
initloop1:
	move.w (a3),d2
	add.l d2,d1
	add.l d2,d1
	add.l d4,d1				; +0 ou +2 selon FC13 ou FC14
	adda.w #12,a3
	move.l d1,(a3)+
	dbf d3,initloop1


	tst.b	bFc14
	beq		init13

;---------------- init FC14

	lea 100(a0),a1
	lea SOUNDINFO+(10*16)(pc),a2
	move.l a0,a3
	add.l 36(a0),a3

	moveq #47-1,d1
	moveq #0,d2
initloop2:
	move.l a3,(a2)+
	move.b (a1)+,d2
	move.w d2,(a2)+
	clr.w (a2)+
	move.w d2,(a2)+
	addq.w #6,a2
	add.w d2,a3
	add.w d2,a3
	dbf d1,initloop2
	bra		skipInit13

;--------------------- init FC13

sndInfo3:
	dc.b	$10,$10,$10,$10,$10,$10,$10,$10
	dc.b	$10,$10,$10,$10,$10,$10,$10,$10
	dc.b	$10,$10,$10,$10,$10,$10,$10,$10
	dc.b	$10,$10,$10,$10,$10,$10,$10,$10
	dc.b	$08,$08,$08,$08,$08,$08,$08,$08
	dc.b	$10,$08,$10,$10,$08,$08,$18
	even

init13:
	lea SOUNDINFO+(10*16)(pc),a2
	lea		sndInfo3(pc),a3
	
	moveq #80-1,d1
	moveq #0,d2
	lea		waveForms,a4
	
.mloop:
	move.l	a4,(a2)+
	moveq	#0,d0
	move.b	(a3)+,d0		; TODO: Bug in original AMIGA routine: Read more entries than the sndInfo3 contains !!
	move.w	d0,(a2)+		; length
	clr.w	(a2)+			; repeat start = 0
	move.w	d0,(a2)+		; repeat length = length
	add.w	d0,d0			; word to bytes
	add.w	d0,a4
	addq.w	#6,a2
	dbf		d1,.mloop

;--------------------------------------------


skipInit13:

	move.l SEQpoint(pc),a0
	moveq #0,d2
	move.b 12(a0),d2		;Get replay speed
	bne.s speedok
	move.b #3,d2			;Set default speed
speedok:
	move.w d2,respcnt		;Init repspeed counter
	move.w d2,repspd
INIT2:
	clr.w audtemp
;	move.w #$000f,$dff096		;Disable audio DMA
;	move.w #$0780,$dff09a		;Disable audio IRQ

	moveq	#$f,d0
	trap	#1		;	bsr	writeDmacon
	moveq #0,d7

	move.l	pModule(pc),a0
	move.l 4(a0),d0
	divu	#13,d0
	mulu.w	#13,d0

	moveq #0,d6			;Number of soundchannels-1
	lea V1data(pc),a0		;Point to 1st voice data area
	lea SILENT(pc),a1
initloop3:
	move.l a1,10(a0)
	move.l a1,18(a0)
	clr.w 4(a0)
	move.w #$000d,6(a0)
	clr.w 8(a0)
	clr.l 14(a0)
	move.b #$01,23(a0)
	move.b #$01,24(a0)
	clr.b 25(a0)
	clr.l 26(a0)
	clr.w 30(a0)
	clr.l 38(a0)
	clr.w 42(a0)
	clr.l 44(a0)
	clr.l 48(a0)
	clr.w 56(a0)

	moveq	#0,d4
	bset	d6,d4
	move.w	d4,32(a0)

	move.l	pCustom(pc),a6
	lea		$a0(a6),a6
	move.w	d6,d1
	lsl.w	#4,d1
	add.w	d1,a6
	move.l #nullSample,(a6)
	move.w #$0100,4(a6)
	move.w #$0000,6(a6)
	move.w #$0000,8(a6)
	move.l a6,60(a0)

	move.l SEQpoint(pc),(a0)
	move.l SEQpoint(pc),52(a0)
	move.w	d6,d5
	mulu.w	#3,d5
	add.l	d5,52(a0)
	add.l	d5,(a0)
	add.l	d0,52(a0)

	move.l	(a0),a3
	moveq	#0,d1
	move.b	(a3),d1
	lsl.w	#6,d1
	move.l	PATpoint(pc),a4
	adda.w	d1,a4
	move.l	a4,34(a0)
	move.b	1(a3),44(a0)
	move.b	2(a3),22(a0)
	lea 	74(a0),a0		;Point to next voice's data area
	addq.w	#1,d6
	cmpi.w	#4,d6
	bne		initloop3
	rts


fcTick:
	lea audtemp(pc),a5
	tst.w 8(a5)
	bne.s music_on
	rts
music_on:
	moveq #0,d5			; [ARNAUD] BUG in original code: D5 and D6 were not settet properly in no new note !!!
	moveq #6,d6
	subq.w #1,4(a5)			;Decrease replayspeed counter
	bne.s nonewnote
	move.w 6(a5),4(a5)		;Restore replayspeed counter
	lea V1data(pc),a0		;Point to voice1 data area
	bsr.w new_note
	lea V2data(pc),a0		;Point to voice2 data area
	bsr.w new_note
	lea V3data(pc),a0		;Point to voice3 data area
	bsr.w new_note
	lea V4data(pc),a0		;Point to voice4 data area
	bsr.w new_note
nonewnote:
	clr.w (a5)
;	lea	custom(pc),a6
	move.l	pCustom(pc),a6
	lea V1data(pc),a0
	bsr.w EFFECTS
	move.l d0,$a6(a6)
	lea V2data(pc),a0
	bsr.w EFFECTS
	move.l d0,$b6(a6)
	lea V3data(pc),a0
	bsr.w EFFECTS
	move.l d0,$c6(a6)
	lea V4data(pc),a0
	bsr.w EFFECTS
	move.l d0,$d6(a6)
	lea V1data(pc),a0
	move.l 68+(0*74)(a0),a1		;Get samplepointer
	adda.w 64+(0*74)(a0),a1		;add repeat_start
	move.l 68+(1*74)(a0),a2
	adda.w 64+(1*74)(a0),a2
	move.l 68+(2*74)(a0),a3
	adda.w 64+(2*74)(a0),a3
	move.l 68+(3*74)(a0),a4
	adda.w 64+(3*74)(a0),a4
	move.w 66+(0*74)(a0),d1		;Get repeat_length
	move.w 66+(1*74)(a0),d2
	move.w 66+(2*74)(a0),d3
	move.w 66+(3*74)(a0),d4

	move.w (a5),d0
	ori.w #$8000,d0			;Set/clr bit = 1
;	move.w	d0,$dff096
	trap	#1		;	bsr	writeDmacon

	moveq #2,d0
	moveq #0,d5
chan1:
	lea V1data+72(pc),a0
	move.w (a0),d7
	beq.s chan2
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan2
	move.w d5,(a0)
	move.l a1,$a0(a6)		;Set samplestart
	move.w d1,$a4(a6)		;Set samplelength
chan2:
	lea V2data+72(pc),a0
	move.w (a0),d7
	beq.s chan3
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan3
	move.w d5,(a0)
	move.l a2,$b0(a6)
	move.w d2,$b4(a6)
chan3:
	lea V3data+72(pc),a0
	move.w (a0),d7
	beq.s chan4
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan4
	move.w d5,(a0)
	move.l a3,$c0(a6)
	move.w d3,$c4(a6)
chan4:
	lea V4data+72(pc),a0
	move.w (a0),d7
	beq.s endplay
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s endplay
	move.w d5,(a0)
	move.l a4,$d0(a6)
	move.w d4,$d4(a6)
endplay:

	rts

new_note:
	move.l 34(a0),a1
	adda.w 40(a0),a1
	cmp.b #$49,(a1)		;Check "END" mark in pattern
	beq.s patend
	cmp.w #64,40(a0)		;Have all the notes been played?
	bne.w samepat
patend:
	move.w d5,40(a0)
	move.l (a0),a2
	adda.w 6(a0),a2		;Point to next sequence row
	cmpa.l 52(a0),a2	;Is it the end?
	bne.s notend
	move.w d5,6(a0)		;yes!
	move.l (a0),a2		;Point to first sequence
	st		bEndMusicTrigger
	
notend:
	lea spdtemp(pc),a3
	moveq #1,d1
	addq.b #1,(a3)
	cmpi.b #5,(a3)
	bne.s nonewspd
	move.b d1,(a3)
	move.b 12(a2),d1	;Get new replay speed
	beq.s nonewspd
	move.w d1,2(a3)		;store in counter
	move.w d1,4(a3)
nonewspd:
	move.b (a2)+,d1		;Pattern to play
	move.b (a2)+,44(a0)	;Transpose value
	move.b (a2)+,22(a0)	;Soundtranspose value
	lsl.w d6,d1
	move.l PATpoint(pc),a1	;Get pattern pointer
	add.w d1,a1
	move.l a1,34(a0)
	addi.w #$000d,6(a0)
samepat:
	move.b 1(a1),d1		;Get info byte
	move.b (a1)+,d0		;Get note
	bne.s ww1
	andi.w #%11000000,d1
	beq.s noport
	bra.s ww11
ww1:
	move.w d5,56(a0)
ww11:
	move.b d5,47(a0)
	btst #7,d1
	beq.s noport
	move.b 2(a1),47(a0)
noport:
	andi.w #$007f,d0
	beq.w nextnote
	move.b d0,8(a0)
	move.b (a1),d1
	move.b d1,9(a0)
	move.w 32(a0),d3
	or.w d3,(a5)
;	move.w d3,$dff096

	move.w	d0,-(a7)
	move.w	d3,d0
	trap	#1	;	bsr	writeDmacon
	move.w	(a7)+,d0

	andi.w #$003f,d1	;Max 64 instruments
	add.b 22(a0),d1		;add Soundtranspose
	move.l VOLpoint(pc),a2
	lsl.w d6,d1
	adda.w d1,a2
	move.w d5,16(a0)
	move.b (a2),23(a0)
	move.b (a2)+,24(a0)
	moveq #0,d1
	move.b (a2)+,d1
	move.b (a2)+,27(a0)
	move.b #$40,46(a0)
	move.b (a2),28(a0)
	move.b (a2)+,29(a0)
	move.b (a2)+,30(a0)
	move.l a2,10(a0)
	move.l FRQpoint(pc),a2
	lsl.w d6,d1
	adda.w d1,a2
	move.l a2,18(a0)
	move.w d5,50(a0)
	move.b d5,25(a0)
	move.b d5,26(a0)
nextnote:
	addq.w #2,40(a0)
	rts

EFFECTS:
	moveq #0,d7
testsustain:
	tst.b 26(a0)		;Is sustain counter = 0
	beq.s sustzero
	subq.b #1,26(a0)	;if no, decrease counter
	bra.w VOLUfx
sustzero:		;Next part of effect sequence
	move.l 18(a0),a1	;can be executed now.
	adda.w 50(a0),a1
testeffects:
	cmpi.b #$e1,(a1)	;E1 = end of FREQseq sequence
	beq.w VOLUfx
	move.b (a1),d0
	cmpi.b #$e0,d0		;E0 = loop to other part of sequence
	bne.s testnewsound
	move.b 1(a1),d1		;loop to start of sequence + 1(a1)
	andi.w #$003f,d1
	move.w d1,50(a0)
	move.l 18(a0),a1
	adda.w d1,a1
	move.b (a1),d0
testnewsound:
	cmpi.b #$e2,d0		;E2 = set waveform
	bne.s testE4




e2:	move.w 32(a0),d1
	or.w d1,(a5)
;	move.w d1,$dff096
	move.w	d0,-(a7)
	move.w	d1,d0
	trap	#1	;	bsr	writeDmacon
	move.w	(a7)+,d0

	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO(pc),a4
	lsl.w #4,d0
	adda.w d0,a4

	move.l 60(a0),a3	; dff0?0
	move.l (a4)+,d1
	move.l d1,(a3)
	move.l d1,68(a0)


	move.w (a4)+,4(a3)	; nouvelle taille replen




	move.l (a4),64(a0)	; replen adress

	move.w #$0003,72(a0)
	move.w d7,16(a0)
	move.b #$01,23(a0)
	addq.w #2,50(a0)
	bra.w transpose
testE4:
	cmpi.b #$e4,d0
	bne.s testE9
	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO(pc),a4
	lsl.w #4,d0
	adda.w d0,a4
	move.l 60(a0),a3	; dff0?0
	move.l (a4)+,d1
	move.l d1,(a3)
	move.l d1,68(a0)


	move.w (a4)+,4(a3)
	move.l (a4),64(a0)
	move.w #$0003,72(a0)
	addq.w #2,50(a0)
	bra.w transpose
testE9:
	cmpi.b #$e9,d0
	bne testpatjmp
	move.w 32(a0),d1
	or.w d1,(a5)
;	move.w d1,$dff096
	move.w	d0,-(a7)
	move.w	d1,d0
	trap	#1	;	bsr	writeDmacon
	move.w	(a7)+,d0
	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO(pc),a4
	lsl.w #4,d0
	adda.w d0,a4
	move.l (a4),a2
	cmpi.l #"SSMP",(a2)+
	bne.s nossmp
	lea 320(a2),a4
	moveq #0,d1
	move.b 2(a1),d1
	lsl.w #4,d1
	add.w d1,a2
	add.l (a2),a4
	move.l 60(a0),a3	; dff0?0


	move.l a4,(a3)
	move.l 4(a2),4(a3)
	move.l a4,68(a0)
	move.l 6(a2),64(a0)

	move.w d7,16(a0)
	move.b #1,23(a0)
	move.w #3,72(a0)
nossmp:
	addq.w #3,50(a0)
	bra.s transpose
testpatjmp:
	cmpi.b #$e7,d0
	bne.s testpitchbend
	moveq #0,d0
	move.b 1(a1),d0
	lsl.w d6,d0
	move.l FRQpoint(pc),a1
	adda.w d0,a1
	move.l a1,18(a0)
	move.w d7,50(a0)
	bra.w testeffects
testpitchbend:
	cmpi.b #$ea,d0
	bne.s testnewsustain
	move.b 1(a1),4(a0)
	move.b 2(a1),5(a0)
	addq.w #3,50(a0)
	bra.s transpose
testnewsustain:
	cmpi.b #$e8,d0
	bne.s testnewvib
	move.b 1(a1),26(a0)
	addq.w #2,50(a0)
	bra.w testsustain
testnewvib:
	cmpi.b #$e3,(a1)+
	bne.s transpose
	addq.w #3,50(a0)
	move.b (a1)+,27(a0)
	move.b (a1),28(a0)
transpose:
	move.l 18(a0),a1
	adda.w 50(a0),a1
	move.b (a1),43(a0)
	addq.w #1,50(a0)

VOLUfx:
	tst.b 25(a0)
	beq.s volsustzero
	subq.b #1,25(a0)
	bra.w calcperiod
volsustzero:
	tst.b 15(a0)
	bne.s do_VOLbend
	subq.b #1,23(a0)
	bne.s calcperiod
	move.b 24(a0),23(a0)
volu_cmd:
	move.l 10(a0),a1
	adda.w 16(a0),a1
	move.b (a1),d0
testvoluend:
	cmpi.b #$e1,d0
	beq.s calcperiod
	cmpi.b #$ea,d0
	bne.s testVOLsustain
	move.b 1(a1),14(a0)
	move.b 2(a1),15(a0)
	addq.w #3,16(a0)
	bra.s do_VOLbend
testVOLsustain:
	cmpi.b #$e8,d0
	bne.s testVOLloop
	addq.w #2,16(a0)
	move.b 1(a1),25(a0)
	bra.s calcperiod
testVOLloop:
	cmpi.b #$e0,d0
	bne.s setvolume
	move.b 1(a1),d0
	andi.w #$003f,d0
	subq.b #5,d0
	move.w d0,16(a0)
	bra.s volu_cmd
do_VOLbend:
	not.b 38(a0)
	beq.s calcperiod
	subq.b #1,15(a0)
	move.b 14(a0),d1
	add.b d1,45(a0)
	bpl.s calcperiod
	moveq #0,d1
	move.b d1,15(a0)
	move.b d1,45(a0)
	bra.s calcperiod
setvolume:
	move.b (a1),45(a0)
	addq.w #1,16(a0)
calcperiod:
	move.b 43(a0),d0
	bmi.s lockednote
	add.b 8(a0),d0
	add.b 44(a0),d0
lockednote:
	moveq #$7f,d1
	and.l d1,d0
	lea PERIODS(pc),a1
	add.w d0,d0
	move.w d0,d1
	adda.w d0,a1
	move.w (a1),d0

	move.b 46(a0),d7
	tst.b 30(a0)		;Vibrato_delay = zero ?
	beq.s vibrator
	subq.b #1,30(a0)
	bra.s novibrato
vibrator:
	moveq #5,d2
	move.b d1,d5
	move.b 28(a0),d4
	add.b d4,d4
	move.b 29(a0),d1
	tst.b d7
	bpl.s vib1
	btst #0,d7
	bne.s vib4
vib1:
	btst d2,d7
	bne.s vib2
	sub.b 27(a0),d1
	bcc.s vib3
	bset d2,d7
	moveq #0,d1
	bra.s vib3
vib2:
	add.b 27(a0),d1
	cmp.b d4,d1
	bcs.s vib3
	bclr d2,d7
	move.b d4,d1
vib3:
	move.b d1,29(a0)
vib4:
	lsr.b #1,d4
	sub.b d4,d1
	bcc.s vib5
	subi.w #$0100,d1
vib5:
	addi.b #$a0,d5
	bcs.s vib7
vib6:
	add.w d1,d1
	addi.b #$18,d5
	bcc.s vib6
vib7:
	add.w d1,d0
novibrato:
	eori.b #$01,d7
	move.b d7,46(a0)

; DO THE PORTAMENTO THING
	not.b 39(a0)
	beq.s pitchbend
	moveq #0,d1
	move.b 47(a0),d1	;get portavalue
	beq.s pitchbend		;0=no portamento
	cmpi.b #$1f,d1
	bls.s portaup
portadown:
	andi.w #$1f,d1
	neg.w d1
portaup:
	sub.w d1,56(a0)
pitchbend:
	not.b 42(a0)
	beq.s addporta
	tst.b 5(a0)
	beq.s addporta
	subq.b #1,5(a0)
	moveq #0,d1
	move.b 4(a0),d1
	bpl.s pitchup
	ext.w d1
pitchup:
	sub.w d1,56(a0)
addporta:
	add.w 56(a0),d0
	cmpi.w #$0070,d0
	bhi.s nn1
	move.w #$0071,d0
nn1:
	cmpi.w #$0d60,d0
	bls.s nn2
	move.w #$0d60,d0
nn2:
	swap d0
	move.b 45(a0),d0
	rts


dataClearStart:

V1data:  dcb.b 64,0	;Voice 1 data area
offset1: dcb.b 2,0	;Is added to start of sound
ssize1:  dcb.b 2,0	;Length of sound
start1:  dcb.b 6,0	;Start of sound

V2data:  dcb.b 64,0	;Voice 2 data area
offset2: dcb.b 2,0
ssize2:  dcb.b 2,0
start2:  dcb.b 6,0

V3data:  dcb.b 64,0	;Voice 3 data area
offset3: dcb.b 2,0
ssize3:  dcb.b 2,0
start3:  dcb.b 6,0

V4data:  dcb.b 64,0	;Voice 4 data area
offset4: dcb.b 2,0
ssize4:  dcb.b 2,0
start4:  dcb.b 6,0

audtemp: dc.w 0		;DMACON
spdtemp: dc.w 0
respcnt: dc.w 0		;Replay speed counter
repspd:  dc.w 0		;Replay speed counter temp
onoff:   dc.w 0		;Music on/off flag.

SEQpoint: dc.l 0
PATpoint: dc.l 0
FRQpoint: dc.l 0
VOLpoint: dc.l 0


nullSample:	dc.w	0
bFc14:		dc.w	0



dataClearEnd:

pCustom:	ds.l	1
pModule:	ds.l	1

SOUNDINFO:
;Start.l , Length.w , Repeat start.w , Repeat-length.w , dcb.b 6,0
	dcb.b 10*16,0	;Reserved for samples
	dcb.b 80*16,0	;Reserved for waveforms

	include "FcSoundBank.inc"
	

SILENT: dc.w $0100,$0000,$0000,$00e1

PERIODS:dc.w $06b0,$0650,$05f4,$05a0,$054c,$0500,$04b8,$0474
	dc.w $0434,$03f8,$03c0,$038a,$0358,$0328,$02fa,$02d0
	dc.w $02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
	dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d
	dc.w $010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4
	dc.w $00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071
	dc.w $0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w $0071,$0071,$0071,$0071,$0d60,$0ca0,$0be8,$0b40
	dc.w $0a98,$0a00,$0970,$08e8,$0868,$07f0,$0780,$0714
	dc.w $1ac0,$1940,$17d0,$1680,$1530,$1400,$12e0,$11d0
	dc.w $10d0,$0fe0,$0f00,$0e28,$06b0,$0650,$05f4,$05a0
	dc.w $054c,$0500,$04b8,$0474,$0434,$03f8,$03c0,$038a
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a
	dc.w $021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d,$0168
	dc.w $0153,$0140,$012e,$011d,$010d,$00fe,$00f0,$00e2
	dc.w $00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f
	dc.w $0087,$007f,$0078,$0071

waveForms:
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$3f,$37,$2f,$27,$1f,$17,$0f,$07,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$37,$2f,$27,$1f,$17,$0f,$07,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$2f,$27,$1f,$17,$0f,$07,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$27,$1f,$17,$0f,$07,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$1f,$17,$0f,$07,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$17,$0f,$07,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$0f,$07,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$07,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$ff,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$80,$07,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$80,$88,$0f,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$80,$88,$90,$17,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$80,$88,$90,$98,$1f,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$80,$88,$90,$98,$a0,$27,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$80,$88,$90,$98,$a0,$a8,$2f,$37
	dc.b	$c0,$c0,$d0,$d8,$e0,$e8,$f0,$f8,$00,$f8,$f0,$e8,$e0,$d8,$d0,$c8
	dc.b	$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$80,$88,$90,$98,$a0,$a8,$b0,$37
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$81,$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$7f,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$7f,$7f,$7f,$7f
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$7f,$7f,$7f
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$7f,$7f
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$7f
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$80,$80,$80,$80,$80,$80,$80,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$80,$80,$80,$80,$80,$80,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$80,$80,$80,$80,$80,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$80,$80,$80,$80,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$80,$80,$80,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$80,$80,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$80,$80,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	dc.b	$80,$80,$90,$98,$a0,$a8,$b0,$b8,$c0,$c8,$d0,$d8,$e0,$e8,$f0,$f8
	dc.b	$00,$08,$10,$18,$20,$28,$30,$38,$40,$48,$50,$58,$60,$68,$70,$7f
	dc.b	$80,$80,$a0,$b0,$c0,$d0,$e0,$f0,$00,$10,$20,$30,$40,$50,$60,$70
	dc.b	$45,$45,$79,$7d,$7a,$77,$70,$66,$61,$58,$53,$4d,$2c,$20,$18,$12
	dc.b	$04,$db,$d3,$cd,$c6,$bc,$b5,$ae,$a8,$a3,$9d,$99,$93,$8e,$8b,$8a
	dc.b	$45,$45,$79,$7d,$7a,$77,$70,$66,$5b,$4b,$43,$37,$2c,$20,$18,$12
	dc.b	$04,$f8,$e8,$db,$cf,$c6,$be,$b0,$a8,$a4,$9e,$9a,$95,$94,$8d,$83
	dc.b	$00,$00,$40,$60,$7f,$60,$40,$20,$00,$e0,$c0,$a0,$80,$a0,$c0,$e0
	dc.b	$00,$00,$40,$60,$7f,$60,$40,$20,$00,$e0,$c0,$a0,$80,$a0,$c0,$e0
	dc.b	$80,$80,$90,$98,$a0,$a8,$b0,$b8,$c0,$c8,$d0,$d8,$e0,$e8,$f0,$f8
	dc.b	$00,$08,$10,$18,$20,$28,$30,$38,$40,$48,$50,$58,$60,$68,$70,$7f
	dc.b	$80,$80,$a0,$b0,$c0,$d0,$e0,$f0,$00,$10,$20,$30,$40,$50,$60,$70
	even

bSoundBankReloc:	dc.b	0
					dc.b	0
					
FCSoundBank:
	incbin	"FcSoundBank.bin"
	even

