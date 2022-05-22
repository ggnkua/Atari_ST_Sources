***************
* TESTPROGRAM *
***************
start:
	lea	$dff000,a5
	move.w	$1c(a5),d0
	bset	#15,d0
	move.w	d0,oldint
	move.l	#$7fff7fff,$9a(a5)
	move.w	#$c000,$9a(a5)
	move.w	#$1ff,$96(a5)
	
	move.l	#pr_data,pr_module
	bsr.w	pr_init
main:
	cmp.b	#160,$dff006
	bne.s	main
main2:
	cmp.b	#161,$dff006
	bls.s	main2

	move.w	#$f00,$dff180
	bsr.w	pr_music
	move.w	#$4,$dff180

	moveq.l	#0,d0
	move.b	$dff006,d0
	sub.w	#162,d0

	move.w	medraster,d1
	add.w	d0,d1
	lsr.w	#1,d1
	move.w	d1,medraster

	cmp.w	maxraster,d0
	bls.s	main3
	move.w	d0,maxraster
main3:
	btst	#6,$bfe001
	bne.s	main

	move.w	#-1,pr_musicfadedirection	; Now fading out...
main4:
	cmp.b	#160,$dff006
	bne.s	main4
main5:
	cmp.b	#161,$dff006
	bls.s	main5

	move.w	#$f00,$dff180
	bsr.w	pr_music
	move.w	#$4,$dff180

	moveq.l	#0,d0
	move.b	$dff006,d0
	sub.w	#162,d0

	move.w	medraster,d1
	add.w	d0,d1
	lsr.w	#1,d1
	move.w	d1,medraster
	
	cmp.w	maxraster,d0
	bls.s	main6
	move.w	d0,maxraster
main6:
	tst.w	pr_musicfadect
	bne.s	main4

	bsr.w	pr_end	

	lea	$dff000,a5
	move.w	oldint(pc),$9a(a5)
	move.w	#$83f0,$96(a5)
	
	moveq.l	#0,d0
	move.l	d0,d1
	move.w	maxraster,d0
	move.w	medraster,d1

	rts

maxraster:	dc.w	0
medraster:	dc.w	0
oldint:		dc.w	0

*****************************************
*					*
* PRORUNNER V2.0			*
* --------------			*
* CODED BY COSMOS OF SANITY IN 1992	*
*					*
*****************************************
*					*
* Supporting the following effects:	*
*					*
*	- Running with 68010/20/30/40	*
*	- Using VBR-register		*
*	- Packed/Normal PT-Moduleformat	*
*	- Fade Sound in/out		*
*	- Variable Musicfadespeed	*
*	- Variable Interrupt-timing	*
*	- Finetune			*
*	- Normal play or Arpeggio	*
*	- Slide Frequenz up		*
*	- Slide	Frequenz down		*
*	- Tone Portamento		*
*	- Vibrato			*
*	- Tone Portamento+Volume Slide	*
*	- Vibrato + Volume Slide	*
*	- Tremolo			*
*	- Set SampleOffset		*
*	- Volume Slide			*
*	- Position Jump			*
*	- Set Volume			*
*	- Pattern Break			*
*	- Set Speed			*
* - E-Commands:				*
*	- Set Filter			*
*	- Fine Slide Up			*
*	- Fine Slide Down		*
*	- Glissando Control		*
*	- Set Vibrato Waveform		*
*	- Set Finetune			*
*	- Set Loop / Jump to Loop	*
*	- Set Tremolo Waveform		*
*	- Retrig Note			*
*	- Fine VolumeSlide Up		*
*	- Fine VolumeSlide Down		*
*	- NoteCut			*
*	- NoteDelay			*
*	- PatternDelay			*
*	- FunkRepeat			*
*					*
*****************************************

YES				EQU	1
NO				EQU	0
INCLUDEFADINGROUTINE		EQU	YES
PACKEDSONGFORMAT		EQU	NO
FADINGSTEPS			EQU	6	; ( 0< FADINGSTEPS <9 )
MAXVOLUME			EQU	2^FADINGSTEPS
INTERRUPTTIME			EQU	$180

SAMPLELENGTHOFFSET		EQU	4
SAMPLEVOLUMEOFFSET		EQU	6
SAMPLEREPEATPOINTOFFSET		EQU	8
SAMPLEWITHLOOP			EQU	12
SAMPLEREPEATLENGTHOFFSET	EQU	14
SAMPLEFINETUNEOFFSET		EQU	16

* Init-Routine *******************************************************

pr_init:
	lea	pr_framecounter(pc),a6
	move.w	#$7fff,pr_oldledvalue-pr_framecounter(a6)
	move.l	pr_module(pc),a0
	cmp.l	#0,a0
	bne.s	pr_init1
	rts
pr_init1:
	IFEQ	PACKEDSONGFORMAT-YES
	cmp.l	#'SNT!',(a0)
	beq.s	pr_init2
	ELSE
	cmp.l	#'M.K.',1080(a0)
	beq.s	pr_init2
	cmp.l	#'SNT.',1080(a0)
	beq.s	pr_init2
	ENDC
	rts
pr_init2:
	IFEQ	PACKEDSONGFORMAT-YES
	lea	8(a0),a1
	ELSE
	lea	20(a0),a1
	ENDC
	lea	pr_Sampleinfos(pc),a2
	moveq.l	#32,d7
	moveq	#30,d0
pr_init3:
	IFNE	PACKEDSONGFORMAT-YES
	lea	22(a1),a1		; Samplenamen überspringen
	ENDC
	move.w	(a1)+,SAMPLELENGTHOFFSET(a2)	; Samplelength in Words
	lea	pr_periods(pc),a3
	moveq	#$f,d2
	and.b	(a1)+,d2		; Finetuning
	mulu.w	#36*2,d2
	add.l	d2,a3
	move.l	a3,SAMPLEFINETUNEOFFSET(a2)
	moveq	#0,d1
	move.b	(a1)+,d1
	move.w	d1,SAMPLEVOLUMEOFFSET(a2)	; Volume
	moveq.l	#0,d1
	move.w	(a1)+,d1		; Repeatpoint in Bytes
	add.l	d1,d1
	move.l	d1,SAMPLEREPEATPOINTOFFSET(a2)
	move.w	(a1)+,d1
	clr.w	SAMPLEWITHLOOP(a2)
	cmp.w	#1,d1
	bls.s	pr_init3_2
	addq.w	#1,SAMPLEWITHLOOP(a2)
pr_init3_2:
	move.w	d1,SAMPLEREPEATLENGTHOFFSET(a2)	; Repeatlength
	add.l	d7,a2
	dbf	d0,pr_init3

	moveq	#0,d0
	IFEQ	PACKEDSONGFORMAT-YES
	move.b	256(a0),d0
	ELSE
	move.b	950(a0),d0		; Number of patterns
	ENDC
	subq.w	#1,d0
	move.w	d0,pr_highestpattern-pr_framecounter(a6)
	moveq.l	#0,d1
	lea	pr_Patternpositions(pc),a3
	IFEQ	PACKEDSONGFORMAT-YES
	lea	258(a0),a1		; 1.Patternpos
	lea	770(a0),a2		; 1.Patterndata
	lea	642(a0),a4		; 1.Patternoffset
pr_init4:
	moveq.l	#0,d2
	move.b	(a1)+,d2
	add.w	d2,d2
	move.w	(a4,d2.w),d2
	add.l	a2,d2
	move.l	d2,(a3)+
	dbf	d0,pr_init4
	ELSE
	lea	952(a0),a1		; 1. Patternpos
	lea	1084(a0),a2		; 1. Patterndata
pr_init4:
	move.b	(a1)+,d2		; x. Patternpos
	moveq.l	#0,d3
	move.b	d2,d3
	mulu.w	#1024,d3
	add.l	a2,d3
	move.l	d3,(a3)+
	dbf	d0,pr_init4
	ENDC

	IFEQ	PACKEDSONGFORMAT-YES
	move.l	4(a0),d2
	add.l	a0,d2
	ELSE
	lea	952(a0),a1
	moveq.l	#0,d1
	moveq	#127,d0
pr_init4_1:
	move.b	(a1)+,d2
	cmp.b	d1,d2			; Highest Pattern ?
	bls.s	pr_init4_2
	move.b	d2,d1
pr_init4_2:
	dbf	d0,pr_init4_1
	addq.w	#1,d1
	move.l	a0,d2
	mulu.w	#1024,d1		; Highest Pattern * 1024 Bytes
	add.l	#1084,d2
	add.l	d1,d2
	ENDC
	lea	pr_Sampleinfos(pc),a3
	lea	pr_Sampleinfos+SAMPLELENGTHOFFSET(pc),a2
	moveq.l	#32,d7
	move.l	d2,(a3)
	moveq	#29,d0
pr_init4_3:
	move.l	(a3),d1
	add.l	d7,a3
	moveq.l	#0,d2
	move.w	(a2),d2
	add.l	d7,a2
	add.l	d2,d2
	add.l	d2,d1
	move.l	d1,(a3)
	dbf	d0,pr_init4_3

	lea	pr_Sampleinfos(pc),a2
	lea	pr_Sampleinfos+SAMPLEREPEATPOINTOFFSET(pc),a3
	moveq.l	#32,d7
	moveq	#30,d0
pr_init4_4:
	move.l	(a2),d1
	add.l	d1,(a3)
	add.l	d7,a2
	add.l	d7,a3
	dbf	d0,pr_init4_4
	
	IFNE	PACKEDSONGFORMAT-YES
	
	cmp.l	#'SNT.',1080(a0)
	beq.s	pr_init7
	
	lea	1084(a0),a1
	move.l	pr_Sampleinfos(pc),a2
	move.b	#$f0,d6
	move.w	#$fff,d7
pr_init5:
	move.b	(a1),d0
	move.b	2(a1),d1
	move.w	(a1),d2
	and.w	d7,2(a1)
	and.w	d7,d2
	
	and.b	d6,d0
	lsr.b	#4,d1
	or.b	d1,d0
	move.b	d0,(a1)
	
	tst.w	d2
	beq.s	pr_init5_3
	lea	pr_periods(pc),a4
	moveq	#0,d1
pr_init5_2:
	addq.w	#1,d1
	cmp.w	(a4)+,d2
	bne.s	pr_init5_2
	move.b	d1,1(a1)
pr_init5_3:
	cmp.b	#$d,2(a1)
	bne.s	pr_init5_4

	moveq	#0,d1
	move.b	3(a1),d1
	moveq	#$f,d2
	and.w	d1,d2
	lsr.w	#4,d1
	mulu.w	#10,d1
	add.w	d2,d1
	cmp.b	#63,d1
	bls.s	pr_init5_3_2
	moveq	#63,d1
pr_init5_3_2:
	move.b	d1,3(a1)
pr_init5_4:
	addq.l	#4,a1
	cmp.l	a2,a1
	blt.s	pr_init5	

	move.l	#'SNT.',1080(a0)

	ENDC
	
pr_init7:
	lea	pr_Arpeggiofastlist(pc),a2
	lea	pr_Arpeggiofastlistperiods(pc),a1
	lea	35*2(a1),a1		; to the end of list...
	moveq	#0,d0
	moveq	#35,d1
	move.w	#999,d2
	moveq	#0,d6
pr_init8:
	move.w	-(a1),d7
	addq.w	#1,d6
pr_init8_2:
	cmp.w	d7,d0
	blt.s	pr_init8_4
	subq.w	#1,d1
	tst.b	d1
	bne.s	pr_init8
pr_init8_3:
	move.b	d1,(a2)+
	dbf	d2,pr_init8_3
	bra.s	pr_init8_5	
pr_init8_4:
	move.b	d1,(a2)+
	addq.w	#1,d0
	dbf	d2,pr_init8_2
pr_init8_5:

	lea	pr_Channel0(pc),a1
	move.w	#1,pr_Channel1-pr_Channel0(a1)
	move.w	#1,pr_Channel2-pr_Channel0(a1)
	move.w	#1,pr_Channel3-pr_Channel0(a1)
	move.w	#1,(a1)+
	moveq	#(pr_Channel1-pr_Channel0)/2-2,d0
pr_init9_2:
	clr.w	pr_Channel1-pr_Channel0(a1)
	clr.w	pr_Channel2-pr_Channel0(a1)
	clr.w	pr_Channel3-pr_Channel0(a1)
	clr.w	(a1)+
	dbf	d0,pr_init9_2

	lea	pr_fastperiodlist(pc),a1
	lea	pr_periods(pc),a2
	move.l	a2,(a1)
	moveq.l	#36*2,d1
	moveq	#14,d0
pr_init9_3:
	move.l	(a1)+,d2
	add.l	d1,d2
	move.l	d2,(a1)
	dbf	d0,pr_init9_3
		
	lea	pr_Arpeggiofastdivisionlist(pc),a1
	moveq	#0,d1
	move.w	#$ff,d0
pr_init9_4:
	move.b	d1,(a1)+
	subq.b	#1,d1
	bpl.s	pr_init9_4_2
	moveq	#2,d1
pr_init9_4_2:
	dbf	d0,pr_init9_4
	
	move.w	#6,pr_speed-pr_framecounter(a6)
	move.w	pr_speed(pc),(a6)
	clr.w	pr_Patternct-pr_framecounter(a6)
	move.w	pr_highestpattern(pc),d0
	move.w	pr_startposition(pc),d1
	blt.s	pr_init9_5
	cmp.w	d0,d1
	bls.s	pr_init9_5_2
pr_init9_5:
	clr.w	pr_startposition-pr_framecounter(a6)
pr_init9_5_2:
	move.w	pr_startposition(pc),pr_currentpattern-pr_framecounter(a6)
	
	lea	pr_Patternpositions(pc),a3
	move.l	a3,d0
	moveq.l	#0,d1
	move.w	pr_startposition(pc),d1
	lsl.l	#2,d1
	add.l	d1,d0
	move.l	d0,pr_Patternpt-pr_framecounter(a6)
	move.l	pr_Patternpt(pc),a5
	move.l	(a5),pr_Currentposition-pr_framecounter(a6)
	
	lea	$dff000,a5
	lea	$bfd000,a0
	move.w	#$2000,d0
	move.w	d0,$9a(a5)
	move.w	d0,$9c(a5)
	
	lea	pr_int(pc),a1
	move.l	pr_Vectorbasept(pc),a3
	move.l	a1,$78(a3)

	move.b	#$7f,$d00(a0)
	move.b	#$08,$e00(a0)
	move.w	#INTERRUPTTIME,d0
	move.b	d0,$400(a0)
	lsr.w	#8,d0
	move.b	d0,$500(a0)
pr_init10:
	btst	#0,$bfdd00
	beq.s	pr_init10
	move.b	#$81,$d00(a0)
	move.w	#$2000,$9c(a5)
	move.w	#$a000,$9a(a5)
	move.w	#$f,$96(a5)
	move.w	#$8000,pr_dmacon-pr_framecounter(a6)
	clr.w	$a8(a5)
	clr.w	$b8(a5)
	clr.w	$c8(a5)
	clr.w	$d8(a5)
	moveq	#0,d0
	move.b	$bfe001,d0
	move.w	d0,pr_oldledvalue-pr_framecounter(a6)
	bset	#1,$bfe001
	rts

* End-Routine *********************************************************

pr_end:
	lea	$dff000,a5
	move.w	#$f,$96(a5)
	clr.w	$a8(a5)
	clr.w	$b8(a5)
	clr.w	$c8(a5)
	clr.w	$d8(a5)
	move.w	#$2000,$9a(a5)
	move.w	pr_oldledvalue(pc),d0
	cmp.w	#$7fff,d0
	beq.s	pr_end3
	btst	#1,d0
	beq.s	pr_end2
	bset	#1,$bfe001
	rts
pr_end2:
	bclr	#1,$bfe001
pr_end3:
	rts

* Music-Fading ********************************************************

	IFEQ	INCLUDEFADINGROUTINE-YES
pr_fademusic:	macro
	lea	pr_musicfadect(pc),a0
	move.w	pr_musicfadedirection(pc),d0
	add.w	d0,(a0)
	cmp.w	#MAXVOLUME,(a0)
	bls.s	pr_fademusicend
	bgt.s	pr_fademusictoohigh
	clr.w	(a0)
	clr.w	pr_musicfadedirection-pr_musicfadect(a0)
	rts
pr_fademusictoohigh:
	move.w	#MAXVOLUME,(a0)
	clr.w	pr_musicfadedirection-pr_musicfadect(a0)
pr_fademusicend:
	endm

pr_musicfadect:		dc.w	MAXVOLUME
pr_musicfadedirection:	dc.w	0
	ENDC
	
* MACROS **************************************************************

pr_playchannel:	macro				; do not change: d7,a2-a6
		moveq	#0,d2
		moveq	#0,d0
		moveq	#0,d1
		IFEQ	PACKEDSONGFORMAT-YES
		move.b	(a6),d6
		bpl.s	.pr_playchannel1
		btst	#6,d6
		bne.s	.pr_playchannel0
		subq.l	#2,a6
		clr.w	4(a4)
		bra.s	.pr_playchannelend
.pr_playchannel0:		
		subq.l	#2,a6
		move.b	56(a4),d0
		move.b	57(a4),d1
		move.b	58(a4),d2
		move.w	58(a4),4(a4)
		bra.s	.pr_playchanneljump		
.pr_playchannel1:
		moveq	#$f,d0
		and.b	1(a6),d0
		move.b	d0,4(a4)
		move.b	d0,d2
		move.b	2(a6),5(a4)
		move.w	4(a4),58(a4)
		
		moveq	#1,d0
		and.b	(a6),d0
		move.b	1(a6),d1
		lsr.b	#3,d1
		bclr	#0,d1
		or.b	d1,d0
		move.b	d0,56(a4)		

		move.b	(a6),d1
		lsr.b	#1,d1
		move.b	d1,57(a4)
		ELSE
		move.w	2(a6),4(a4)
		move.b	2(a6),d2
		move.b	(a6),d0
		move.b	1(a6),d1
		ENDC
.pr_playchanneljump:
		add.w	d2,d2
		lea	pr_playchannellist(pc),a0
		move.w	(a0,d2.w),d2
		jsr	(a0,d2.w)
.pr_playchannelend:
		IFEQ	PACKEDSONGFORMAT-YES
		addq.l	#3,a6
		ELSE
		addq.l	#4,a6
		ENDC
		endm

pr_checkchannel:	macro			; do not change: d7,a2-a6
		bsr.w	pr_checkfunkrepeat
		moveq	#0,d0
		move.b	4(a4),d0
		add.b	d0,d0
		lea	pr_Effectchecklist(pc),a0
		move.w	(a0,d0.w),d0
		jsr	(a0,d0.w)
		endm
		
pr_copyplayvalues:	macro
		tst.w	pr_commandnotedelay-pr_framecounter(a2)
		bne.s	.pr_copyplayvalues2
		move.w	2(a4),6(a3)
.pr_copyplayvalues2:
		IFEQ	INCLUDEFADINGROUTINE-YES
		move.w	12(a4),d0
		mulu.w	pr_musicfadect-pr_framecounter(a2),d0
 		lsr.l	#FADINGSTEPS,d0
		move.w	d0,8(a3)
		ELSE
		move.w	12(a4),8(a3)
		ENDC
		endm

* Music-Routine *******************************************************

pr_music:
	IFEQ	INCLUDEFADINGROUTINE-YES
	pr_fademusic
	ENDC
	lea	$dff000,a5

	lea	pr_framecounter(pc),a2
	subq.w	#1,(a2)
	beq.s	pr_music2
	bra.w	pr_checkeffects
pr_music2:
	cmp.b	#1,pr_patterndelaytime-pr_framecounter+1(a2)
	blt.s	pr_music2_2
	bsr.w	pr_checkeffects
	bra.w	pr_music2_9
pr_music2_2:
	move.l	pr_Currentposition(pc),a6
	lea	pr_Channel0(pc),a4
	lea	$a0(a5),a3
	moveq	#1,d7
	pr_playchannel
	pr_copyplayvalues
pr_music2_3:	
	lea	pr_Channel1(pc),a4
	lea	$b0(a5),a3
	moveq	#2,d7
	pr_playchannel
	pr_copyplayvalues
pr_music2_4:
	lea	pr_Channel2(pc),a4
	lea	$c0(a5),a3
	moveq	#4,d7
	pr_playchannel
	pr_copyplayvalues
pr_music2_5:
	lea	pr_Channel3(pc),a4
	lea	$d0(a5),a3
	moveq	#8,d7
	pr_playchannel
	pr_copyplayvalues
	
	lea	pr_int(pc),a0
	move.l	pr_Vectorbasept(pc),a1
	move.l	a0,$78(a1)
	move.b	#$19,$bfde00

pr_music2_9:
	move.w	pr_speed(pc),(a2)
	tst.w	pr_patternhasbeenbreaked-pr_framecounter(a2)
	bne.s	pr_music3
	tst.w	pr_patterndelaytime-pr_framecounter(a2)
	beq.s	pr_music3_1
	subq.w	#1,pr_patterndelaytime-pr_framecounter(a2)
	beq.s	pr_music3_1
	bra.s	pr_nonextpattern
pr_music3:
	clr.w	pr_patternhasbeenbreaked-pr_framecounter(a2)
	tst.w	pr_patterndelaytime-pr_framecounter(a2)
	beq.s	pr_music3_1
	subq.w	#1,pr_patterndelaytime-pr_framecounter(a2)
pr_music3_1:
	lea	pr_Patternct(pc),a1
	tst.w	pr_dontcalcnewposition-pr_framecounter(a2)
	bne.s	pr_music3_2
	move.l	a6,pr_Currentposition-pr_framecounter(a2)
	addq.w	#1,(a1)
pr_music3_2:
	clr.w	pr_dontcalcnewposition-pr_framecounter(a2)
	moveq.l	#64,d1
	cmp.w	(a1),d1
	bgt.s	pr_nonextpattern
	sub.w	d1,(a1)
	lea	pr_currentpattern(pc),a0
	move.w	(a1),d1
	beq.s	pr_music3_3
	IFEQ	PACKEDSONGFORMAT-YES
	move.l	pr_module(pc),a1
	lea	386(a1),a1
	move.w	(a0),d1
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	ELSE
	lsl.w	#4,d1
	ENDC
pr_music3_3:
	addq.l	#4,pr_Patternpt-pr_framecounter(a2)
	addq.w	#1,(a0)
	move.w	(a0),d0
	cmp.w	pr_highestpattern-pr_framecounter(a2),d0
	bls.s	pr_nohighestpattern
	lea	pr_Patternpositions(pc),a1
	move.l	a1,pr_Patternpt-pr_framecounter(a2)
	clr.w	(a0)
pr_nohighestpattern:
	move.l	pr_Patternpt-pr_framecounter(a2),a6
	move.l	(a6),d0
	add.l	d1,d0
	move.l	d0,pr_Currentposition-pr_framecounter(a2)
pr_nonextpattern:
	rts

	
pr_int:
	tst.b	$bfdd00
	move.b	#$19,$bfde00
	move.w	pr_dmacon(pc),$dff096
	move.w	#$2000,$dff09c
	move.l	a0,-(sp)
	move.l	pr_Vectorbasept(pc),a0
	add.l	#pr_int2-pr_int,$78(a0)
	move.l	(sp)+,a0
	rte

pr_int2:
	tst.b	$bfdd00
	movem.l	a5-a6,-(sp)
	lea	$dff000,a5
	lea	pr_Channel0+6(pc),a6
	move.l	(a6),$a0(a5)
	move.w	4(a6),$a4(a5)
	move.l	pr_Channel1-pr_Channel0(a6),$b0(a5)
	move.w	4+pr_Channel1-pr_Channel0(a6),$b4(a5)
	move.l	pr_Channel2-pr_Channel0(a6),$c0(a5)
	move.w	4+pr_Channel2-pr_Channel0(a6),$c4(a5)
	move.l	pr_Channel3-pr_Channel0(a6),$d0(a5)
	move.w	4+pr_Channel3-pr_Channel0(a6),$d4(a5)
	move.w	#$2000,$9c(a5)
	move.l	pr_Vectorbasept(pc),a6
	move.l	pr_old78(pc),$78(a6)
	movem.l	(sp)+,a5-a6
	rte
		
pr_playchannellist:
	dc.w	pr_playnormalchannel-pr_playchannellist		; 0
	dc.w	pr_playnormalchannel-pr_playchannellist		; 1
	dc.w	pr_playnormalchannel-pr_playchannellist		; 2
	dc.w	pr_playtpchannel-pr_playchannellist		; 3
	dc.w	pr_playnormalchannel-pr_playchannellist		; 4
	dc.w	pr_playtpchannel-pr_playchannellist		; 5
	dc.w	pr_playnormalchannel-pr_playchannellist		; 6
	dc.w	pr_playnormalchannel-pr_playchannellist		; 7
	dc.w	pr_playnormalchannel-pr_playchannellist		; 8
	dc.w	pr_playsochannel-pr_playchannellist		; 9
	dc.w	pr_playnormalchannel-pr_playchannellist		; A
	dc.w	pr_playnormalchannel-pr_playchannellist		; B
	dc.w	pr_playnormalchannel-pr_playchannellist		; C
	dc.w	pr_playnormalchannel-pr_playchannellist		; D
	dc.w	pr_playnormalchannel-pr_playchannellist		; E
	dc.w	pr_playnormalchannel-pr_playchannellist		; F
	
* KANAL NORMAL SPIELEN ************************************************

pr_playnormalchannel:
	lea	pr_Sampleinfos(pc),a0
	lea	(a0),a1
	lea	SAMPLEFINETUNEOFFSET(a1),a1
	clr.w	pr_commandnotedelay-pr_framecounter(a2)
	moveq	#-1,d4
	lsl.w	#4,d4
	and.w	4(a4),d4
	cmp.w	#$ed0,d4
	bne.s	pr_playnormalsamplenotedelay
	addq.w	#1,pr_commandnotedelay-pr_framecounter(a2)
pr_playnormalsamplenotedelay:
	tst.b	d0
	beq.w	pr_playnormalnonewsample	; Irgendein Sample ?
	move.w	d0,(a4)				; Trage Samplenummer ein
	tst.b	d1
	bne.s	pr_playnormalsample
	subq.b	#1,d0
	lsl.l	#5,d0
	add.l	d0,a0
	addq.l	#6,a0
	move.w	(a0)+,12(a4)
	move.l	(a0)+,d2
	move.l	d2,6(a4)
	tst.w	(a0)+
	beq.s	pr_playnormalchannel2
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playnormalchannel2:
	move.w	(a0)+,10(a4)
	bra.w	pr_playnormalnonewperiod
pr_playnormalsample:
	or.w	d7,pr_dmacon-pr_framecounter(a2)
	tst.w	pr_commandnotedelay-pr_framecounter(a2)
	beq.w	pr_playnormalsamplenoedcom
	subq.b	#1,d0
	lsl.l	#5,d0
	add.l	d0,a0
	move.w	6(a0),12(a4)
	move.l	8(a0),6(a4)
	move.w	14(a0),10(a4)
	bra.s	pr_playnormalnewperiod
pr_playnormalsamplenoedcom:
	move.w	d7,$96(a5)
	subq.b	#1,d0
	lsl.l	#5,d0
	add.l	d0,a0
	move.l	(a0)+,(a3)		; Setze Samplestart
	move.w	(a0)+,4(a3)		; Setze Audiodatenlänge
	move.w	(a0)+,12(a4)		; Setze Samplelautstärke
	move.l	(a0)+,d2
	move.l	d2,6(a4)		; Samplerepeatpoint eintragen
	tst.w	(a0)+
	beq.s	pr_playnormalsample2
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playnormalsample2:
	move.w	(a0)+,10(a4)		; Samplerepeatlength eintragen
	bra.s	pr_playnormalnewperiod
pr_playnormalnonewsample:
	clr.l	14(a4)
	tst.b	d1
	beq.s	pr_playnormalnonewperiod	; Irgend ne neue Frequenz ?
	move.w	(a4),d0			; Alte Samplenummer holen
	or.w	d7,pr_dmacon-pr_framecounter(a2)
	tst.w	pr_commandnotedelay-pr_framecounter(a2)
	bne.s	pr_playnormalnewperiod
	move.w	d7,$96(a5)
pr_playnormalnonewsamplenoedcom:
	subq.b	#1,d0
	lsl.l	#5,d0
	add.l	d0,a0
	move.l	(a0)+,(a3)		; Setze Samplestart
	move.w	(a0)+,4(a3)		; Setze Audiodatenlänge
	addq.l	#2,a0
	move.l	(a0)+,d2
	move.l	d2,6(a4)		; Samplerepeatpoint eintragen
	tst.w	(a0)+
	beq.s	pr_playnormalnonewsample2
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playnormalnonewsample2:
	move.w	(a0)+,10(a4)		; Samplerepeatlength eintragen
pr_playnormalnewperiod:
	subq.b	#1,d1
	add.b	d1,d1
	move.w	(a4),d0
	subq.b	#1,d0
	lsl.w	#5,d0
	move.l	(a1,d0.w),a1
	move.w	(a1,d1.w),2(a4)		; Frequenz eintragen
pr_playnormalnonewperiod:
	bra.w	pr_playeffect

* KANAL MIT OFFSET SPIELEN *********************************************

pr_playsochannel:
	lea	pr_Sampleinfos(pc),a0
	lea	(a0),a1
	lea	SAMPLEFINETUNEOFFSET(a1),a1
	tst.b	d0
	beq.w	pr_playsononewsample	; Irgendein Sample ?
	move.w	d0,(a4)				; Trage Samplenummer ein
	tst.b	d1
	bne.s	pr_playsosample
	subq.b	#1,d0
	lsl.l	#5,d0
	add.l	d0,a0
	addq.l	#6,a0
	move.w	(a0)+,12(a4)
	move.l	(a0)+,d2
	move.l	d2,6(a4)
	tst.w	(a0)+
	beq.s	pr_playsochannel2
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playsochannel2:
	move.w	(a0)+,10(a4)
	bra.w	pr_playsononewperiod
pr_playsosample:
	move.w	d7,$96(a5)
	or.w	d7,pr_dmacon-pr_framecounter(a2)
	moveq.l	#0,d6
	move.b	5(a4),d6
	lsl.w	#7,d6
	subq.b	#1,d0
	lsl.l	#5,d0
	add.l	d0,a0
	move.l	(a0)+,d2
	move.w	(a0)+,d3
	cmp.w	d3,d6
	bge.s	pr_playsosample2
	sub.w	d6,d3
	add.l	d6,d6
	add.l	d6,d2
	move.l	d2,(a3)			; Setze Samplestart
	move.w	d3,4(a3)		; Setze Audiodatenlänge
	move.w	(a0)+,12(a4)		; Setze Samplelautstärke
	move.l	(a0)+,d2
	move.l	d2,6(a4)		; Samplerepeatpoint eintragen
	tst.w	(a0)+
	beq.s	pr_playsosample1
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playsosample1:
	move.w	(a0)+,10(a4)		; Samplerepeatlength eintragen
	bra.w	pr_playsonewperiod
pr_playsosample2:
	move.w	(a0)+,12(a4)
	move.l	(a0),(a3)
	move.w	4(a0),4(a3)
	move.l	(a0)+,d2
	move.l	d2,6(a4)
	tst.w	(a0)+
	beq.s	pr_playsosample4
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playsosample4:
	move.w	(a0)+,10(a4)
	bra.s	pr_playsonewperiod
pr_playsononewsample:
	clr.l	14(a4)
	tst.b	d1
	beq.b	pr_playsononewperiod	; Irgend ne neue Frequenz ?
	move.w	(a4),d0			; Alte Samplenummer holen
	move.w	d7,$96(a5)
	or.w	d7,pr_dmacon-pr_framecounter(a2)
	moveq.l	#0,d6
	move.b	5(a4),d6
	lsl.w	#7,d6
	subq.b	#1,d0
	lsl.l	#5,d0
	add.l	d0,a0
	move.l	(a0)+,d2
	move.w	(a0)+,d3
	cmp.w	d3,d6
	bge.s	pr_playsosample3
	sub.w	d6,d3
	add.l	d6,d6
	add.l	d6,d2
	move.l	d2,(a3)			; Setze Samplestart
	move.w	d3,4(a3)		; Setze Audiodatenlänge
	addq.l	#2,a0
	move.l	(a0)+,d2
	move.l	d2,6(a4)		; Samplerepeatpoint eintragen
	tst.w	(a0)+
	beq.s	pr_playsononewsample2
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playsononewsample2:
	move.w	(a0)+,10(a4)		; Samplerepeatlength eintragen
	bra.s	pr_playsonewperiod
pr_playsosample3:
	addq.l	#2,a0
	move.l	(a0),(a3)
	move.w	4(a0),4(a3)
	move.l	(a0)+,d2
	move.l	d2,6(a4)
	tst.w	(a0)+
	beq.s	pr_playsosample5
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playsosample5:
	move.w	(a0)+,10(a4)
	bra.w	pr_playsonewperiod
pr_playsonewperiod:
	subq.w	#1,d1
	add.b	d1,d1
	move.w	(a4),d0
	subq.b	#1,d0
	lsl.w	#5,d0
	move.l	(a1,d0.w),a1
	move.w	(a1,d1.w),2(a4)		; Frequenz eintragen
pr_playsononewperiod:
	bra.b	pr_playeffect

* Kanal spielen mit TONE PORTAMENTO **********************************

pr_playtpchannel:
	lea	pr_Sampleinfos(pc),a0
	lea	(a0),a1
	lea	SAMPLEFINETUNEOFFSET(a1),a1
	tst.b	d0
	beq.s	pr_playtpnonewsample	; Irgendein Sample ?
	move.w	d0,(a4)			; Trage Samplenummer ein
	subq.b	#1,d0
	lsl.l	#5,d0
	add.l	d0,a0
	addq.l	#6,a0
	move.w	(a0)+,12(a4)		; Lautstärke eintragen
	move.l	(a0)+,d2
	move.l	d2,6(a4)		; Repeatpoint eintragen
	tst.w	(a0)+
	beq.s	pr_playtpchannel2
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_playtpchannel2:
	move.w	(a0)+,10(a4)		; Repeatlength eintragen
pr_playtpnonewsample:
	tst.b	d1
	beq.s	pr_playtpnonewperiod	; Irgend ne neue Frequenz ?
pr_playtpnewperiod:
	move.w	2(a4),14(a4)
	subq.w	#1,d1
	add.b	d1,d1
	move.w	(a4),d0
	subq.b	#1,d0
	lsl.w	#5,d0
	move.l	(a1,d0.w),a1
	move.w	(a1,d1.w),d2
	move.w	d2,16(a4)		; Frequenz eintragen
	bra.s	pr_playtpallowed
pr_playtpnonewperiod:
	tst.w	16(a4)
	bne.s	pr_playtpallowed
	clr.w	14(a4)
	clr.l	26(a4)
pr_playtpallowed:
	bra.w	pr_playeffect

pr_playeffect:
	bsr.w	pr_checkfunkrepeat
	moveq	#0,d0
	move.b	4(a4),d0
	add.b	d0,d0
	lea	pr_normaleffectlist(pc),a0
	move.w	(a0,d0.w),d0
	jmp	(a0,d0.w)
pr_playnoeffect:
	rts

pr_normaleffectlist:
	dc.w	pr_playnoeffect-pr_normaleffectlist		; 0
	dc.w	pr_playnoeffect-pr_normaleffectlist		; 1
	dc.w	pr_playnoeffect-pr_normaleffectlist		; 2
	dc.w	pr_preptoneportamento-pr_normaleffectlist	; 3
	dc.w	pr_prepvibrato-pr_normaleffectlist		; 4
	dc.w	pr_playnoeffect-pr_normaleffectlist		; 5
	dc.w	pr_prepvibandvolslide-pr_normaleffectlist	; 6
	dc.w	pr_preptremolo-pr_normaleffectlist		; 7
	dc.w	pr_playnoeffect-pr_normaleffectlist		; 8
	dc.w	pr_playnoeffect-pr_normaleffectlist		; 9
	dc.w	pr_playnoeffect-pr_normaleffectlist		; A
	dc.w	pr_jumptopattern-pr_normaleffectlist		; B
	dc.w	pr_newvolume-pr_normaleffectlist		; C
	dc.w	pr_patternbreak-pr_normaleffectlist		; D
	dc.w	pr_play_e_command-pr_normaleffectlist		; E
	dc.w	pr_newspeed-pr_normaleffectlist			; F

pr_play_e_command:
	moveq	#0,d0
	move.b	5(a4),d0
	lsr.b	#3,d0
	bclr	#0,d0
	lea	pr_e_commandeffectlist(pc),a0
	move.w	(a0,d0.w),d0
	jmp	(a0,d0.w)
	
pr_e_commandeffectlist:
	dc.w	pr_setfilter-pr_e_commandeffectlist		; 0
	dc.w	pr_fineslideup-pr_e_commandeffectlist		; 1
	dc.w	pr_fineslidedown-pr_e_commandeffectlist		; 2
	dc.w	pr_setglissandocontrol-pr_e_commandeffectlist	; 3
	dc.w	pr_setvibratowaveform-pr_e_commandeffectlist	; 4
	dc.w	pr_playfinetune-pr_e_commandeffectlist		; 5
	dc.w	pr_jumptoloop-pr_e_commandeffectlist		; 6
	dc.w	pr_settremolowaveform-pr_e_commandeffectlist	; 7
	dc.w	pr_playnoeffect-pr_e_commandeffectlist		; 8
	dc.w	pr_prepretrignote-pr_e_commandeffectlist	; 9
	dc.w	pr_finevolumeslideup-pr_e_commandeffectlist	; A
	dc.w	pr_finevolumeslidedown-pr_e_commandeffectlist	; B
	dc.w	pr_prepnotecut-pr_e_commandeffectlist		; C
	dc.w	pr_prepnotedelay-pr_e_commandeffectlist		; D
	dc.w	pr_preppatterndelay-pr_e_commandeffectlist	; E
	dc.w	pr_prepfunkrepeat-pr_e_commandeffectlist	; F

pr_preppatterndelay:
	cmp.b	#1,pr_patterndelaytime-pr_framecounter+1(a2)
	bge.s	pr_preppatterndelayend
	moveq	#$f,d0
	and.b	5(a4),d0
	addq.b	#1,d0
	move.b	d0,pr_patterndelaytime-pr_framecounter+1(a2)
pr_preppatterndelayend:
	rts

pr_setvibratowaveform:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.w	d0,50(a4)
	rts

pr_settremolowaveform:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.w	d0,52(a4)
	rts

pr_setglissandocontrol:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.w	d0,48(a4)
	rts

pr_playfinetune:
	moveq	#$f,d0
	and.b	5(a4),d0
	lsl.w	#2,d0
	lea	pr_fastperiodlist(pc),a0
	move.l	(a0,d0.w),a0
	moveq	#0,d1
	IFEQ	PACKEDSONGFORMAT-YES
	move.b	(a6),d1
	lsr.b	#1,d1
	ELSE
	move.b	1(a6),d1
	ENDC
	beq.s	pr_playfinetuneend
	subq.b	#1,d1
	add.w	d1,d1
	move.w	(a0,d1.w),2(a4)		; Frequenz eintragen
pr_playfinetuneend:
	rts
	
pr_jumptoloop:
	moveq	#$f,d0
	and.b	5(a4),d0
	beq.s	pr_prepjumptoloop
	addq.b	#1,47(a4)
	cmp.b	47(a4),d0
	blt.s	pr_jumptoloopend
	moveq.l	#0,d0
	move.w	44(a4),d0
	move.w	d0,pr_Patternct-pr_framecounter(a2)
	move.l	pr_Patternpt(pc),a0
	move.l	(a0),d5
	IFEQ	PACKEDSONGFORMAT-YES
	moveq.l	#0,d0
	move.w	60(a4),d0
	ELSE
	lsl.l	#4,d0
	ENDC
	add.l	d0,d5
	move.l	d5,pr_Currentposition-pr_framecounter(a2)
	addq.w	#1,pr_dontcalcnewposition-pr_framecounter(a2)
	rts
pr_jumptoloopend:
	clr.w	46(a4)
	rts
pr_prepjumptoloop:
	tst.w	46(a4)
	bne.s	pr_prepjumptoloopend
	move.w	pr_Patternct-pr_framecounter(a2),44(a4)
	IFEQ	PACKEDSONGFORMAT-YES
	move.l	pr_Currentposition(pc),d0
	move.l	pr_Patternpt(pc),a1
	sub.l	(a1),d0
	move.w	d0,60(a4)
	ENDC
	clr.w	46(a4)
pr_prepjumptoloopend:
	rts

pr_prepnotedelay:
	IFEQ	PACKEDSONGFORMAT-YES
	tst.b	57(a4)
	ELSE
	tst.b	1(a6)
	ENDC
	beq.s	pr_prepnotedelayend2

	moveq	#$f,d0
	and.b	5(a4),d0
	bne.s	pr_prepnotedelay2
	move.w	#$fff,18(a4)
	bra.w	pr_checknotedelay2
pr_prepnotedelay2:
	move.w	d7,d0
	not.b	d0
	and.b	d0,pr_dmacon-pr_framecounter+1(a2)
	clr.w	18(a4)
	rts
pr_prepnotedelayend2:
	move.w	#$fff,18(a4)
	rts

pr_prepretrignote:
	clr.w	18(a4)
	IFEQ	PACKEDSONGFORMAT-YES
	tst.b	56(a4)
	ELSE
	tst.w	(a6)
	ENDC
	bne.s	pr_prepretrignoteend
	bra.w	pr_checkretrignote2	
pr_prepretrignoteend:
	rts

pr_prepnotecut:
	clr.w	18(a4)
	moveq	#$f,d0
	and.b	5(a4),d0
	tst.b	d0
	bne.s	pr_prepnotecutend
	clr.w	12(a4)
pr_prepnotecutend:
	rts
	
pr_finevolumeslideup:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.w	12(a4),d1
	add.w	d0,d1
	moveq	#64,d0
	cmp.w	d0,d1
	bls.s	pr_finevolumeslideup2
	move.w	d0,d1
pr_finevolumeslideup2:
	move.w	d1,12(a4)
	rts

pr_finevolumeslidedown:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.w	12(a4),d1
	sub.w	d0,d1
	bpl.s	pr_finevolumeslidedown2
	moveq	#0,d1
pr_finevolumeslidedown2:
	move.w	d1,12(a4)
	rts

pr_fineslideup:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.w	2(a4),d1
	sub.w	d0,d1
	cmp.w	#108,d1
	bge.s	pr_fineslideup2
	move.w	#108,d1
pr_fineslideup2:
	move.w	d1,2(a4)
	rts

pr_fineslidedown:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.w	2(a4),d1
	add.w	d0,d1
	cmp.w	#907,d1
	bls.s	pr_fineslidedown2
	move.w	#907,d1
pr_fineslidedown2:
	move.w	d1,2(a4)
	rts

pr_setfilter:
	btst	#0,5(a4)
	beq.s	pr_setfilteron
pr_setfilteroff:
	bset	#1,$bfe001
	rts
pr_setfilteron:
	bclr	#1,$bfe001
	rts

pr_prepvibandvolslide:
	cmp.b	#1,pr_speed-pr_framecounter+1(a2)
	beq.s	pr_prepvibandvolslide2
	IFEQ	PACKEDSONGFORMAT-YES
	move.b	(a6),d1
	lsr.b	#1,d1
	ELSE
	tst.b	1(a6)
	ENDC
	beq.s	pr_prepvibandvolslide2
	clr.w	18(a4)
pr_prepvibandvolslide2:
	rts

pr_preptoneportamento:
	tst.b	5(a4)
	beq.s	pr_preptoneportamento2
	move.w	4(a4),22(a4)
pr_preptoneportamento2:
	rts

pr_prepvibrato:
	cmp.b	#1,pr_speed-pr_framecounter+1(a2)
	beq.s	pr_prepvibrato2
	IFEQ	PACKEDSONGFORMAT-YES
	move.b	(a6),d1
	lsr.b	#1,d1
	ELSE
	tst.b	1(a6)
	ENDC
	beq.s	pr_prepvibrato0
	clr.w	18(a4)
pr_prepvibrato0:
	move.b	5(a4),d0
	move.b	d0,d1
	lsr.b	#4,d1
	beq.s	pr_prepvibrato1
	move.b	d1,24(a4)
pr_prepvibrato1:
	and.b	#$f,d0
	beq.s	pr_prepvibrato2
	move.b	d0,25(a4)
pr_prepvibrato2:
	rts

pr_preptremolo:
	cmp.b	#1,pr_speed-pr_framecounter+1(a2)
	beq.s	pr_preptremolo2
	IFEQ	PACKEDSONGFORMAT-YES
	move.b	(a6),d1
	lsr.b	#1,d1
	ELSE
	tst.b	1(a6)
	ENDC
	beq.s	pr_preptremolo0
	clr.w	18(a4)
pr_preptremolo0:
	move.w	12(a4),20(a4)
	move.b	5(a4),d0
	move.b	d0,d1
	lsr.b	#4,d1
	beq.s	pr_preptremolo1
	move.b	d1,30(a4)
pr_preptremolo1:
	and.b	#$f,d0
	beq.s	pr_preptremolo2
	move.b	d0,31(a4)
pr_preptremolo2:
	rts

pr_newvolume:
	move.b	5(a4),d0
	cmp.b	#64,d0
	bls.s	pr_newvolumeend
	moveq	#64,d0
pr_newvolumeend:
	move.b	d0,13(a4)
	rts

pr_newspeed:
	move.b	5(a4),d0
	tst.b	d0
	bne.s	pr_newspeed2
	moveq	#1,d0
pr_newspeed2:
	move.b	d0,pr_speed-pr_framecounter+1(a2)
	rts

pr_patternbreak:
	moveq	#0,d0
	move.b	5(a4),d0
	add.w	#64,d0
	move.w	d0,pr_Patternct-pr_framecounter(a2)
	addq.w	#1,pr_patternhasbeenbreaked-pr_framecounter(a2)
	addq.w	#1,pr_dontcalcnewposition-pr_framecounter(a2)
	rts
		
pr_jumptopattern:
	moveq.l	#0,d0
	move.b	5(a4),d0
	subq.b	#1,d0
	bpl.s	pr_playjumptopattern2
	move.w	#128,d0
pr_playjumptopattern2:
	move.b	d0,pr_currentpattern-pr_framecounter+1(a2)
	lsl.l	#2,d0
	lea	pr_Patternpositions(pc),a0
	add.l	a0,d0
	move.l	d0,pr_Patternpt-pr_framecounter(a2)
	move.w	#64,pr_Patternct-pr_framecounter(a2)
	addq.w	#1,pr_patternhasbeenbreaked-pr_framecounter(a2)
	addq.w	#1,pr_dontcalcnewposition-pr_framecounter(a2)
	rts

* Control FX every frame **********************************************

pr_checkeffects:
	moveq	#1,d7
	lea	$a0(a5),a3
	lea	pr_Channel0(pc),a4
	move.w	12(a4),54(a4)
	pr_checkchannel
	IFEQ	INCLUDEFADINGROUTINE-YES
	move.w	54(a4),d0
	mulu.w	pr_musicfadect-pr_framecounter(a2),d0
	lsr.l	#FADINGSTEPS,d0
	move.w	d0,8(a3)
	ELSE
	move.w	54(a4),8(a3)
	ENDC
	
	moveq	#2,d7
	lea	$b0(a5),a3
	lea	pr_Channel1(pc),a4
	move.w	12(a4),54(a4)
	pr_checkchannel
	IFEQ	INCLUDEFADINGROUTINE-YES
	move.w	54(a4),d0
	mulu.w	pr_musicfadect-pr_framecounter(a2),d0
	lsr.l	#FADINGSTEPS,d0
	move.w	d0,8(a3)
	ELSE
	move.w	54(a4),8(a3)
	ENDC

	moveq	#4,d7
	lea	$c0(a5),a3
	lea	pr_Channel2(pc),a4
	move.w	12(a4),54(a4)
	pr_checkchannel
	IFEQ	INCLUDEFADINGROUTINE-YES
	move.w	54(a4),d0
	mulu.w	pr_musicfadect-pr_framecounter(a2),d0
	lsr.l	#FADINGSTEPS,d0
	move.w	d0,8(a3)
	ELSE
	move.w	54(a4),8(a3)
	ENDC

	moveq	#8,d7
	lea	$d0(a5),a3
	lea	pr_Channel3(pc),a4
	move.w	12(a4),54(a4)
	pr_checkchannel
	IFEQ	INCLUDEFADINGROUTINE-YES
	move.w	54(a4),d0
	mulu.w	pr_musicfadect-pr_framecounter(a2),d0
	lsr.l	#FADINGSTEPS,d0
	move.w	d0,8(a3)
	ELSE
	move.w	54(a4),8(a3)
	ENDC

	lea	pr_int(pc),a0
	move.l	pr_Vectorbasept(pc),a1
	move.l	a0,$78(a1)
	move.b	#$19,$bfde00
	rts

***********************************************************************

pr_checknotchannel:
	rts

pr_check_e_commands
	moveq	#0,d0
	move.b	5(a4),d0
	lsr.b	#3,d0
	bclr	#0,d0
	lea	pr_E_Command_checklist(pc),a0
	move.w	(a0,d0.w),d0
	jmp	(a0,d0.w)
	
pr_Effectchecklist:
	dc.w	pr_checkarpeggio-pr_Effectchecklist		; 0
	dc.w	pr_checkperiodslideup-pr_Effectchecklist	; 1
	dc.w	pr_checkperiodslidedown-pr_Effectchecklist	; 2
	dc.w	pr_checktoneportamento-pr_Effectchecklist	; 3
	dc.w	pr_checkvibrato-pr_Effectchecklist		; 4
	dc.w	pr_checktpandvolslide-pr_Effectchecklist	; 5
	dc.w	pr_checkvibandvolslide-pr_Effectchecklist	; 6
	dc.w	pr_checktremolo-pr_Effectchecklist		; 7
	dc.w	pr_checknotchannel-pr_Effectchecklist		; 8
	dc.w	pr_checknotchannel-pr_Effectchecklist		; 9
	dc.w	pr_checkvolumeslide-pr_Effectchecklist		; A
	dc.w	pr_checknotchannel-pr_Effectchecklist		; B
	dc.w	pr_checknotchannel-pr_Effectchecklist		; C
	dc.w	pr_checknotchannel-pr_Effectchecklist		; D
	dc.w	pr_check_e_commands-pr_Effectchecklist		; E
	dc.w	pr_checknotchannel-pr_Effectchecklist		; F

pr_E_Command_checklist:
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 0
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 1
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 2
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 3
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 4
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 5
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 6
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 7
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; 8
	dc.w	pr_checkretrignote-pr_E_Command_checklist	; 9
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; A
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; B
	dc.w	pr_checknotecut-pr_E_Command_checklist		; C
	dc.w	pr_checknotedelay-pr_E_Command_checklist	; D
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; E
	dc.w	pr_checknotchannel-pr_E_Command_checklist	; F

pr_prepfunkrepeat:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.b	d0,33(a4)
	tst.b	d0
	bne.s	pr_checkfunkrepeat
	rts
pr_checkfunkrepeat:
	move.w	32(a4),d0
	beq.s	pr_checkfunkrepeatend
	lea	pr_FunkTable(pc),a0
	move.b	(a0,d0.w),d0
	move.b	35(a4),d1
	add.b	d0,d1
	bmi.s	pr_checkfunkrepeat2
	move.b	d1,35(a4)
	rts
pr_checkfunkrepeat2:
	clr.b	35(a4)

	move.l	36(a4),d0
	beq.s	pr_checkfunkrepeatend
	move.l	d0,d2
	moveq.l	#0,d1
	move.w	10(a4),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	40(a4),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.s	pr_checkfunkrepeatok
	move.l	d2,a0
pr_checkfunkrepeatok:
	move.l	a0,40(a4)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
pr_checkfunkrepeatend:
	rts

pr_checknotedelay:
	move.w	18(a4),d1
	addq.w	#1,d1
	cmp.w	d0,d1
	bne.s	pr_checknotedelayend
pr_checknotedelay2:
	move.w	d7,$96(a5)
	or.w	d7,pr_dmacon-pr_framecounter(a2)
	moveq.l	#0,d0
	move.w	(a4),d0
	subq.w	#1,d0
	lsl.w	#5,d0
	lea	pr_Sampleinfos(pc),a0
	add.l	d0,a0
	move.w	2(a4),6(a3)
	move.l	(a0)+,(a3)		; Setze Samplestart
	move.w	(a0)+,4(a3)		; Setze Audiodatenlänge
	addq.l	#2,a0
	move.l	(a0)+,d2
	move.l	d2,6(a4)		; Samplerepeatpoint eintragen
	tst.w	(a0)+
	beq.s	pr_checknotedelay3
	move.l	d2,36(a4)
	move.l	d2,40(a4)
pr_checknotedelay3:
	move.w	(a0)+,10(a4)		; Samplerepeatlength eintragen
pr_checknotedelayend:
	move.w	d1,18(a4)
	rts

pr_checkretrignote:
	moveq	#$f,d0
	and.b	5(a4),d0
	move.w	18(a4),d1
	addq.w	#1,d1
	cmp.w	d0,d1
	bne.s	pr_checkretrignoteend
pr_checkretrignote2:
	moveq	#0,d1
	move.w	d7,$96(a5)
	or.w	d7,pr_dmacon-pr_framecounter(a2)
	move.w	(a4),d0
	subq.w	#1,d0
	lsl.w	#5,d0
	lea	pr_Sampleinfos(pc),a0
	move.l	(a0,d0.w),(a3)
	move.w	4(a0,d0.w),4(a3)
pr_checkretrignoteend:
	move.w	d1,18(a4)
	rts

pr_checknotecut:
	moveq	#$f,d0
	and.b	5(a4),d0
	addq.w	#1,18(a4)
	move.w	18(a4),d1
	cmp.w	d0,d1
	blt.s	pr_checknotecutend
	clr.w	12(a4)
	clr.w	54(a4)
pr_checknotecutend:
	rts

pr_checkarpeggio:
	tst.b	5(a4)
	bne.s	pr_checkarpeggio0
	rts
pr_checkarpeggio0:
	move.w	(a2),d0
	lea	pr_Arpeggiofastdivisionlist(pc),a1
	move.b	(a1,d0.w),d0
	beq.s	pr_checkarpeggio2
	cmp.b	#2,d0
	beq.s	pr_checkarpeggio1
	moveq	#0,d0
	move.b	5(a4),d0
	lsr.b	#4,d0
	bra.s	pr_checkarpeggio3
pr_checkarpeggio2:
	move.w	2(a4),6(a3)
	rts
pr_checkarpeggio1:
	moveq	#$f,d0
	and.b	5(a4),d0
pr_checkarpeggio3:
	asl.w	#1,d0
	move.w	(a4),d1
	lsl.w	#5,d1
	lea	pr_Sampleinfos+SAMPLEFINETUNEOFFSET(pc),a0
	move.l	(a0,d1.w),a0
	move.w	2(a4),d1
	lea	pr_Arpeggiofastlist(pc),a1
	moveq.l	#0,d2
	move.b	(a1,d1.w),d2
	add.b	d2,d2
	add.l	d2,a0
	moveq	#36,d7
pr_checkarpeggioloop:
	cmp.w	(a0)+,d1
	bhs.s	pr_checkarpeggio4
	dbf	d7,pr_checkarpeggioloop
	rts
pr_checkarpeggio4:
	subq.l	#2,a0
	move.w	(a0,d0.w),6(a3)
	rts

pr_checktpandvolslide:
	bsr.w	pr_checkvolumeslide
	moveq	#0,d2
	move.b	23(a4),d2
	move.w	26(a4),d0
	move.w	28(a4),d1
	bsr.s	pr_checktoneportamento2
	move.w	14(a4),26(a4)
	rts
	
pr_checktoneportamento:
	moveq	#0,d2
	move.b	5(a4),d2
	bne.s	pr_checktoneportamento1
	move.b	23(a4),d2
pr_checktoneportamento1:
	move.w	14(a4),d0
	move.w	16(a4),d1
pr_checktoneportamento2:
	cmp.w	d0,d1
	bgt.s	pr_checktoneportamentoplus
	blt.s	pr_checktoneportamentominus
	cmp.w	#1,(a2)
	beq.s	pr_savetpvalues
	rts
pr_checktoneportamentoplus:
	add.w	d2,d0
	cmp.w	d0,d1
	bgt.s	pr_checktoneportamentoend
	move.w	d1,d0
	move.w	d1,14(a4)
	move.w	d1,2(a4)
	tst.w	48(a4)
	bne.s	pr_checktoneportamentoglissando
	move.w	d1,6(a3)
	cmp.w	#1,(a2)
	beq.s	pr_savetpvalues
	rts
pr_checktoneportamentominus:
	sub.w	d2,d0
	cmp.w	d0,d1
	blt.s	pr_checktoneportamentoend
	move.w	d1,d0
	move.w	d1,14(a4)
	move.w	d1,2(a4)
	tst.w	48(a4)
	bne.s	pr_checktoneportamentoglissando
	move.w	d1,6(a3)
	cmp.w	#1,(a2)
	beq.s	pr_savetpvalues
	rts
pr_checktoneportamentoend:
	move.w	d0,14(a4)
	move.w	d0,2(a4)
	tst.w	48(a4)
	bne.s	pr_checktoneportamentoglissando
	move.w	d0,6(a3)
	cmp.w	#1,(a2)
	beq.s	pr_savetpvalues
	rts	
pr_savetpvalues:
	move.l	14(a4),26(a4)
	rts
pr_checktoneportamentoglissando:
	move.w	(a4),d1
	lsl.w	#5,d1
	lea	pr_Sampleinfos+SAMPLEFINETUNEOFFSET(pc),a0
	move.l	(a0,d1.w),a0
	lea	pr_Arpeggiofastlist(pc),a1
	moveq.l	#0,d2
	move.b	(a1,d0.w),d2
	add.w	d2,d2
	add.l	d2,a0
	moveq	#0,d3
	moveq	#36*2,d1
pr_checktoneportamentoglissandoloop:
	cmp.w	(a0,d3.w),d0
	bhs.s	pr_checktoneportamentoglissando2
	addq.w	#2,d3
	cmp.w	d1,d3
	blo.s	pr_checktoneportamentoglissandoloop
	moveq	#35*2,d3
pr_checktoneportamentoglissando2:
	move.w	(a0,d3.w),6(a3)
	cmp.w	#1,(a2)
	beq.s	pr_savetpvalues
	rts

pr_checkvolumeslide:
	moveq	#0,d0
	move.b	5(a4),d0
	move.w	d0,d1
	lsr.b	#4,d1
	beq.s	pr_checkvolumeslidedown
	move.w	12(a4),d2
	add.w	d1,d2
	bmi.s	pr_checkvolumeslide0
	moveq	#64,d0
	cmp.w	d0,d2
	bgt.s	pr_checkvolumeslide64
	move.w	d2,12(a4)
	move.w	d2,54(a4)
	rts
pr_checkvolumeslidedown:	
	and.b	#$f,d0
	move.w	12(a4),d2
	sub.w	d0,d2
	bmi.s	pr_checkvolumeslide0
	moveq	#64,d0
	cmp.w	d0,d2
	bgt.s	pr_checkvolumeslide64
	move.w	d2,12(a4)
	move.w	d2,54(a4)
	rts
pr_checkvolumeslide64:
	move.w	d0,12(a4)
	move.w	d0,54(a4)
	rts
pr_checkvolumeslide0:
	clr.w	12(a4)
	clr.w	54(a4)
	rts
	
pr_checkperiodslidedown:
	moveq	#0,d0
	move.b	5(a4),d0
	add.w	d0,2(a4)
	cmp.w	#907,2(a4)
	bls.s	pr_checkperiodslidedown2
	move.w	#907,2(a4)
pr_checkperiodslidedown2:
	move.w	2(a4),6(a3)
	rts

pr_checkperiodslideup:
	moveq	#0,d0
	move.b	5(a4),d0
	sub.w	d0,2(a4)
	cmp.w	#108,2(a4)
	bge.s	pr_checkperiodslideup2
	move.w	#108,2(a4)
pr_checkperiodslideup2:
	move.w	2(a4),6(a3)
	rts

pr_checkvibandvolslide:
	bsr.w	pr_checkvolumeslide
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.b	25(a4),d0
	move.b	24(a4),d1
	bra.s	pr_checkvibrato4

pr_checkvibrato:
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.b	5(a4),d0	; Tiefe
pr_checkvibrato2:
	move.w	d0,d1		; Geschwindigkeit
	and.w	#$f,d0
	bne.s	pr_checkvibrato3
	move.b	25(a4),d0
pr_checkvibrato3:
	lsr.b	#4,d1
	bne.s	pr_checkvibrato4
	move.b	24(a4),d1
pr_checkvibrato4:
	move.w	18(a4),d2	;Position
	lsr.w	#2,d2
	and.w	#$1f,d2
	move.w	50(a4),d3
	beq.s	pr_checkvibratosine
	btst	#0,d3
	bne.s	pr_checkvibratorampdown
	move.b	#255,d3
	bra.s	pr_checkvibratoset
pr_checkvibratorampdown:
	lsl.b	#3,d2
	tst.b	19(a4)
	bmi.s	pr_checkvibratorampdown2
	move.b	#255,d3
	sub.b	d2,d3
	bra.s	pr_checkvibratoset
pr_checkvibratorampdown2:
	move.b	d2,d3
	bra.s	pr_checkvibratoset
pr_checkvibratosine:
	lea	pr_VibratoTable(pc),a0
	moveq	#0,d3
	move.b	(a0,d2.w),d3
pr_checkvibratoset:
	mulu.w	d0,d3
	lsr.w	#7,d3
	move.w	2(a4),d2
	tst.b	19(a4)
	bpl.s	pr_checkvibratoneg
	add.w	d3,d2
	bra.s	pr_checkvibrato5
pr_checkvibratoneg:
	sub.w	d3,d2
pr_checkvibrato5:
	move.w	d2,6(a3)
	lsl.w	#2,d1
	add.b	d1,19(a4)
	rts

pr_checktremolo:
	moveq	#0,d0
	moveq.l	#0,d1
	move.b	5(a4),d0	; Tiefe
pr_checktremolo2:
	move.w	d0,d1		; Geschwindigkeit
	and.w	#$f,d0
	bne.s	pr_checktremolo3
	move.b	31(a4),d0
pr_checktremolo3:
	lsr.b	#4,d1
	bne.s	pr_checktremolo4
	move.b	30(a4),d1
pr_checktremolo4:
	move.w	18(a4),d2	;Position
	lsr.w	#2,d2
	and.w	#$1f,d2
	move.w	52(a4),d3
	beq.s	pr_checktremolosine
	btst	#0,d3
	bne.s	pr_checktremolorampdown
	move.b	#255,d3
	bra.s	pr_checktremoloset
pr_checktremolorampdown:
	lsl.b	#3,d2
	tst.b	19(a4)
	bmi.s	pr_checktremolorampdown2
	move.b	#255,d3
	sub.b	d2,d3
	bra.s	pr_checktremoloset
pr_checktremolorampdown2:
	move.b	d2,d3
	bra.s	pr_checktremoloset
pr_checktremolosine:
	lea	pr_VibratoTable(pc),a0
	moveq	#0,d3
	move.b	(a0,d2.w),d3
pr_checktremoloset:
	mulu.w	d0,d3
	lsr.w	#6,d3
	move.w	20(a4),d2
	tst.b	19(a4)
	bpl.s	pr_checktremoloneg
	add.w	d3,d2
	moveq	#64,d4
	cmp.w	d4,d2
	bls.s	pr_checktremolo5
	move.w	d4,d2
	bra.s	pr_checktremolo5
pr_checktremoloneg:
	sub.w	d3,d2
	bpl.s	pr_checktremolo5
	moveq	#0,d2
pr_checktremolo5:
	move.w	d2,54(a4)
	lsl.w	#2,d1
	add.b	d1,19(a4)
	rts

pr_VibratoTable:	
	dc.b	0,24,49,74,97,120,141,161
	dc.b	180,197,212,224,235,244,250,253
	dc.b	255,253,250,244,235,224,212,197
	dc.b	180,161,141,120,97,74,49,24
pr_FunkTable:
	dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	
* Variables ***********************************************************

pr_module:			dc.l	0
pr_startposition:		dc.w	0
pr_speed:			dc.w	6
pr_highestpattern:		dc.w	0
pr_currentpattern:		dc.w	0
pr_framecounter:		dc.w	0
pr_patterndelaytime:		dc.w	0
pr_patternhasbeenbreaked:	dc.w	0
pr_Patternpositions:		ds.l	128
pr_Patternpt:			dc.l	0
pr_Currentposition:		dc.l	0
pr_Patternct:			dc.w	0
pr_oldledvalue:			dc.w	0
pr_dontcalcnewposition:		dc.w	0
pr_commandnotedelay:		dc.w	0
pr_old78:			dc.l	0
pr_Vectorbasept:		dc.l	0
pr_Channel0:			dc.w	1
				ds.w	30
pr_Channel1:			dc.w	1
				ds.w	30
pr_Channel2:			dc.w	1
				ds.w	30
pr_Channel3:			dc.w	1
				ds.w	30
pr_dmacon:			dc.w	$8000

pr_Arpeggiofastlist:		ds.b	1000
pr_Arpeggiofastdivisionlist:	ds.b	$100
pr_fastperiodlist:		ds.l	16
pr_Sampleinfos:			ds.b	32*32

pr_periods:
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
pr_Arpeggiofastlistperiods:
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

* END OF PRORUNNER ***************************************************

	SECTION	DATA
pr_data:
	;incbin	"df0:mod.music" 
	END
