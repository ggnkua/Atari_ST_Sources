	opt	x+
as
;****************************************************************
;*								*
;*	Emulation chip AMIGA Paula.				*
;*								*
;*  	Atari STE - 25Khz					*
;*	Written by Leonard (Arnaud Carre) Dec 1996.		*
;
;
;	new 2006 version, cleaner and faster.
;	July 2007: relocatable code and CT60 compatible (MOVEP removed)
;
; TODO: Faire une routine pour les voies avec volume à 64 (sans table de volume)
;*								*
;****************************************************************


PLAYERRATE						=	50
PAULA_50K_NBSAMPLE_PER_BLOCK	=	(50066/PLAYERRATE)+4			; +4 to always do a bit more, so we can skip frame sometimes and perfectly keep in sync without using interrupts
PAULA_25K_NBSAMPLE_PER_BLOCK	=	(25033/PLAYERRATE)+4			; +4 to always do a bit more, so we can skip frame sometimes and perfectly keep in sync without using interrupts
NB_BLOCK						=	4

_25KHZ_8BITS					=	0
_50KHZ_8BITS					=	1
_50KHZ_16BITS					=	2

MULTIPLEX	=1						=	0



paulaEmul:
		bra.w	paulaInstall
		bra.w	paulaClose
		bra.w	setUserRout
		bra.w	paulaTick
		dc.b	'Real AMIGA-PAULA Emulation v1.0. STE sound only. Written by Leonard/OXYGENE.'
		even



;----------------------------------------------------------------
;
;	paulaInstall
;
;	Input:	d0 Machine type
;			0: STF (not supported)
;			1: STE
;			2: MegaSTE
;			3: TT
;			4: Falcon
;			5: Falcon CT60
;
;	Output:	A0 Pointer on the AMIGA Custom chip ($dff000)
;			(Use it instead of $dff000 !!)
;			NULL if error.
;
;----------------------------------------------------------------
paulaInstall:	

		lea		iMachine(pc),a1
		move.b	d0,(a1)

		lea	userRout(pc),a1
		clr.l	(a1)

		lea		iHwConfig(pc),a1
		cmpi.b	#2,d0
		bge.s	.MSTEOrBest
		move.b	#_25KHZ_8BITS,(a1)			; STE only
		bra.s	.hwOk

.MSTEOrBest:	
		cmpi.b	#4,d0
		bge.s	.falconOrBest
		move.b	#_50KHZ_8BITS,(a1)			; TT or MegaSTE (16Mhz CPU allow 50Khz mixing)
		bra.s	.hwOk

.falconOrBest:
		move.b	#_50KHZ_16BITS,(a1)			; Falcon or CT60

.hwOk:		
		bsr		checkDMASound
		bne.s	.okSTE

		suba.l	a0,a0
		rts

.okSTE:

		moveq	#0,d0
		move.b	iHwConfig(pc),d0
		lsl.w	#3,d0
		lea		HardwareTable(pc),a1
		add.w	d0,a1

		move.w	(a1)+,d0
		lea		iRightOffset(pc),a2
		move.w	(a1)+,(a2)
		lea		nbSamplePerFrame(pc),a2
		move.w	(a1)+,(a2)
		lea		blockSize(pc),a2
		move.w	(a1)+,(a2)

		move.b	iHwConfig(pc),d1
		cmpi.b	#_50KHZ_16BITS,d1
		bne.s	.noFalcon
		move.w	#0,$ffff8934.w
		move.b	#0,$ffff8920.w

.noFalcon:
		move.b	d0,$ffff8921.w
		
		bsr	volumeBuild
		bsr	frequenceBuild
		bsr	codeBuilder

;.skip:
		lea	pSampA(pc),a0
		lea	channela(pc),a2
		lea	nullSample(pc),a1
		moveq	#4-1,d0
.clear:		move.l	a1,(a0)+		; sample
		move.l	a1,(a0)+		; end
		add.l	#2,-4(a0)
		move.w	#0,(a0)+		; virgule

		move.l	a1,(a2)
		move.w	#1,4(a2)		; replen
		move.w	#0,6(a2)		; period
		move.w	#0,8(a2)		; volume

		lea	16(a2),a2
		dbf	d0,.clear

		moveq	#$f,d0
		bsr	writeDmaconPrivate

		bsr	clearVoice
		
		lea	status(pc),a1
		move.l	$80.w,(a1)+
		move.l	$84.w,(a1)+

		lea	super(pc),a0
		move.l	a0,$80.w

		lea	writeDmacon(pc),a0
		move.l	a0,$84.w

	;--------------------------------------
	; setup MicroWire
	;--------------------------------------
		move.b	iHwConfig(pc),d0
		cmpi.b	#2,d0
		bge.s	.skipFalcon				; falcon has no microwire interface
		lea		MicroWireData(pc),a0
		moveq	#3-1,d0
.mloop:	move.w	#$07ff,$ffff8924.w
.wait1:	cmp.w	#$07ff,$ffff8924.w
		bne.s	.wait1
		move.w	(a0)+,$ffff8922.w
		dbf		d0,.mloop
.skipFalcon:

		lea		sampleBuffer(pc),a0
		lea		$ffff8900.w,a1
		move.b	#0,1(a1)

	; Avoid MOVEP for Falcon-CT60 compatibility
		move.l	a0,d0
		move.b	d0,$7(a1)
		lsr.w	#8,d0
		move.b	d0,$5(a1)
		swap	d0
		move.b	d0,$3(a1)
;	move.l	d0,2(a1)

		move.w	blockSize(pc),d0
		mulu.w	#NB_BLOCK,d0			; stereo means 2 bytes per sample
		add.w	d0,a0						; end of buffer

		move.l	a0,d0
		move.b	d0,$13(a1)
		lsr.w	#8,d0
		move.b	d0,$11(a1)
		swap	d0
		move.b	d0,$f(a1)

		move.b	#%11,1(a1)			; start (bit0) and loop mode (bit1)
.over:

		lea	custom(pc),a0
		lea	pSampA(pc),a1
		rts

MicroWireData:
		dc.w	%0000010011000000 + 40	; master volume
		dc.w	%0000010101000000 + 20	; left volume
		dc.w	%0000010100000000 + 20	; right volume

		; HW freq, sample stride, 
HardwareTable:
	IFNE	 MULTIPLEX			 = 1
;	{
		dc.w	%00000011,	-1,	PAULA_25K_NBSAMPLE_PER_BLOCK,	PAULA_25K_NBSAMPLE_PER_BLOCK * 4	; 0: STE, MegaSTE
;	}
	ELSEIF
;	{
		dc.w	%00000010,	1,	PAULA_25K_NBSAMPLE_PER_BLOCK,	PAULA_25K_NBSAMPLE_PER_BLOCK * 2	; 0: STE, MegaSTE
;	}
	endc
		dc.w	%00000011,	1,	PAULA_50K_NBSAMPLE_PER_BLOCK,	PAULA_50K_NBSAMPLE_PER_BLOCK * 2	; 1: TT
		dc.w	%01000011,	2,	PAULA_50K_NBSAMPLE_PER_BLOCK,	PAULA_50K_NBSAMPLE_PER_BLOCK * 4	; 2: Falcon, CT60
		

		
clearVoice:	
		movem.l	d0/a0,-(a7)
		lea	sampleBuffer(pc),a0
		move.w	blockSize(pc),d0
		mulu.w	#NB_BLOCK,d0
		lsr.l	#2,d0						; /4 for clr.l
		subq.w	#1,d0						; -1 for DBF
.fill:	clr.l	(a0)+
		dbf	d0,.fill
		movem.l	(a7)+,d0/a0
		rts

setUserRout:
		lea	userRout(pc),a1
		move.l	a0,(a1)
		beq.s	clearVoice	; NULL use rout means "no sound" ?
		rts

checkDMASound:
		move.l	a7,a4
		move.l	$8.w,a5
		lea		.back(pc),a0
		move.l	a0,$8.w
		moveq	#0,d0
		move.b	#0,$ffff8901.w
		move.l	#$00120034,$ffff8902.w
		move.l	$ffff8902.w,d1
		andi.l	#$00ff00ff,d1
		cmpi.l	#$00120034,d1
		seq		d0
.back:	move.l	a5,$8.w
		move.l	a4,a7

		tst.b	d0
		rts
		

volumeBuild:	

		lea	volumeBuild(pc),a0
		add.l	#(volumeTableBuffer+255-volumeBuild),a0

		move.l	a0,d0
		clr.b	d0
		lea	pVolumeTable(pc),a0
		move.l	d0,(a0)
		move.l	d0,a0
		moveq	#0,d0
		
		move.b	iHwConfig(pc),d1
		cmpi.b	#_50KHZ_16BITS,d1
		beq		go16
	IFne	MULTIPLEX		=1
;	{
		moveq	#6,d3				; right shift 6bits for volume (still a full 8bit original sample!)
		cmpi.b	#_25KHZ_8BITS,d1
		beq.s	.loopv
;	}
	endc
		moveq	#6+1,d3				; 6+1bit shift for volume, keep only 7bits per sample
		
.loopv:		moveq	#0,d1
.loops:		move.b	d1,d2
		ext.w	d2
		muls.w	d0,d2
		asr.w	d3,d2		; /64: Amiga volume max.
		move.b	d2,(a0)+
		addq.b	#1,d1
		bne.s	.loops
		addq.w	#1,d0
		cmpi.w	#65,d0
		bne.s	.loopv
		rts

go16:

.loopv:		moveq	#0,d1
.loops:		move.b	d1,d2
		ext.w	d2
		muls.w	d0,d2
		add.w	d2,d2			; 6+1 = 15bits sample
		move.w	d2,(a0)+
		addq.b	#1,d1
		bne.s	.loops
		addq.w	#1,d0
		cmpi.w	#65,d0
		bne.s	.loopv
		rts
		

PERMIN		=	$71
PERMAX		=	$d60


frequenceBuild:	lea	frequenceTable(pc),a0
		moveq	#PERMIN-1,d0
.clear:		clr.l	(a0)+
		dbf	d0,.clear
		move.w	#PERMIN,d0
		move.w	#PERMAX-PERMIN-1,d1
		move.l	#9371195,d2	; (3579546(paula) * 65536(prec)) / 25033(MIXERFRQ)
		move.b	iHwConfig(pc),d5
		beq.s	.ok25
		lsr.l	#1,d2			; 50khz
.ok25:
		move.l	d2,d5
		clr.w	d5
		swap	d5
.compute:
		move.l	d5,d3
		divu	d0,d3
		move.w	d3,d4
		cmpi.w	#2,d4
		bge.s	.clamp
		swap	d4
		move.w	d2,d3
		divu	d0,d3
		move.w	d3,d4

		move.l	d4,(a0)+
.backClamp:
		addq.w	#1,d0
		dbf	d1,.compute
		rts

.clamp:	; NOTE: Only two notes are high on STF (high part more = 2)
		move.l	#$0001FFFF,(a0)+
		bra.s	.backClamp

exepVector:
		trap	#0
		move.w	#$2700,sr
		move.l	#$700,d0
.eLoop:	move.w	d0,$ffff8240.w
		swap	d0
		bra.s	.eLoop
		

codeBuilder:



		lea		jmpTable(pc),a5

		lea		codeBuilder(pc),a4
		add.l	#codeBuffer-codeBuilder,a4

		lea		codeSteFastPath(pc),a0
		move.b	iHwConfig(pc),d0
		cmpi.b	#_50KHZ_16BITS,d0
		bne.s	.no16
		lea		codeFalconFastPath(pc),a0
.no16:	pea		(a0)
		
		move.w	nbSamplePerFrame(pc),d0
		move.w	-4(a0),d2
		bsr.s	.towerBuild

		move.l	(a7)+,a0
		move.w	nbSamplePerFrame(pc),d0
		move.w	-8(a0),d2
		bsr.s	.towerBuild

;		lea		codeBuilder(pc),a0
;		add.l	#codeBuffer-codeBuilder,a0
;		suba.l	a0,a4
;		dc.w	$60fe
		
		; NOW check if this is MSTE
		move.b	iMachine(pc),d0
		cmpi.b	#2,d0
		bne		.noMSTE

		; use the looped routine for MSTE
		lea		jmpTable(pc),a5
		lea		Loop8bitsMove(pc),a0
		move.l	a0,8(a5)
		move.l	a0,12(a5)
		lea		Loop8bitsMoveFast(pc),a0
		move.l	a0,(a5)

		lea		jmpTableAdd(pc),a5
		lea		Loop8bitsAdd(pc),a0
		move.l	a0,8(a5)
		move.l	a0,12(a5)
		lea		Loop8bitsAddFast(pc),a0
		move.l	a0,(a5)

		
;		ds.l	1		; fast path, MOVE
;		ds.l	1		; high freq, with loop, MOVE
;		ds.l	1		; lowFreq, no loop, MOVE
;		ds.l	1		; lowFreq, with loop, MOVE
		
		

.noMSTE:	
		rts

		
;		  |       |       |       |       |       |       |       |       
;		  |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
;		  | v1+v4 | v2+v3 | r1+r2 | l1+l2 | r1+r2 | l1+l2 | r1+r2 |
;		  | v1|v2 | v4|v3 |
		
.towerBuild:

	IFne MULTIPLEX		=1
;	{
		moveq	#4,d6
		move.b	iHwConfig(pc),d7
		cmpi.b	#_50KHZ_8BITS,d7
		bne.s	.ok
		moveq	#2,d6
.ok:
;	}
	ELSEIF
;	{
;		moveq	#2,d6
;		move.b	iHwConfig(pc),d7
;		cmpi.b	#_50KHZ_16BITS,d7
;		bne.s	.ok
;		moveq	#4,d6		; falcon only has 4bytes stride
;.ok:
;	}
	endc

		moveq	#4-1,d1
.tLoop:	move.l	a4,(a5)+

	moveq	#0,d7
		; first time, check the fast move
;		cmpi.w	#3,d1
;		bne		.noFast		
;		cmp.w	.mCodeSte(pc),d2
;		beq.s	.noFast				; garde le move
;		; ici fast add, on fait rien
;		move.l	a0,a1
;		bra.s	.nextIt

.noFast:
		move.w	.iexg(pc),(a4)+
		move.w	d0,d3
		subq.w	#1,d3
.cLoop:	movea.l	a0,a1
		move.w	d2,(a4)+				; fetch code

	IFne	MULTIPLEX		=1
;	{
		move.b	iHwConfig(pc),d5
		cmpi.b	#_25KHZ_8BITS,d5
		bne.s	.noSTE
		move.w	d7,(a4)+
		add.w	d6,d7
.noSTE:
	endc
;	}	
	
.copy:	cmpi.w	#$4e75,(a1)
		beq.s	.eLoop
		move.w	(a1)+,(a4)+
		bra.s	.copy
.eLoop:	dbf		d3,.cLoop
		move.w	.iexg(pc),(a4)+
.nextIt:
		move.w	#$4e75,(a4)+
		lea		2(a1),a0			; skip the RTS end block marker
		dbf		d1,.tLoop
		rts

.iexg:	exg		a3,a7





; WARNING: don't move this (offset -2 and -4 hardcoded in "codeBuilder" func		
	IFne	MULTIPLEX	=1
;	{
.aCodeSte:	add.b	d6,8(a7)
.mCodeSte:	move.b	d6,8(a7)
;	}
	elseif
;	ELSE
;	{
.aCodeSte:	add.b	d6,(a7)+
			nop
.mCodeSte:	move.b	d6,(a7)+
			nop
;	}
	endc

codeSteFastPath:
;		move.b	d6,(a7)+
		rts

codeSteHighLoop:				
;		move.b	d6,(a7)+
		move.b	(a0)+,d2
		move.l	d2,a2
		move.b	(a2),d6
		add.w	d0,d1
		bcc.s	.skip
		addq.w	#1,a0
.skip:	cmpa.l	a0,a1
		bgt.s	.fcode
		move.l	d3,a0
		move.l	d4,a1
.fcode:
		rts

codeSteLowLoop:				
;		move.b	d6,(a7)+
		add.w	d0,d1
		bcc.s	.fcode
		move.b	(a0)+,d2
		cmpa.l	a0,a1
		bgt.s	.noLoop
		move.l	d3,a0
		move.l	d4,a1
.noLoop:
		move.l	d2,a2
		move.b	(a2),d6
.fcode:
		rts

codeSteLowNoLoop:				
;		move.b	d6,(a7)+
		add.w	d0,d1
		bcc.s	.fcode
		move.b	(a0)+,d2
		move.l	d2,a2
		move.b	(a2),d6
.fcode:
		rts


Loop8bitsMove:
		exg		a3,a7
		move.w	nbSamplePerFrame(pc),d7
		subq.w	#1,d7
.sLoop:
		move.b	d6,(a7)+
		add.w	d0,d1
		bcc.s	.fcode
		move.b	(a0)+,d2
		cmpa.l	a0,a1
		bgt.s	.noLoop
		move.l	d3,a0
		move.l	d4,a1
.noLoop:
		move.l	d2,a2
		move.b	(a2),d6
.fcode:
		dbf		d7,.sLoop
		exg		a3,a7
		rts

Loop8bitsMoveFast:
		exg		a3,a7
		move.w	nbSamplePerFrame(pc),d7
		subq.w	#1,d7
.sLoop:	move.b	d6,(a7)+
		dbf		d7,.sLoop
		exg		a3,a7
		rts
		
Loop8bitsAdd:

		exg		a3,a7

		move.w	nbSamplePerFrame(pc),d7
		subq.w	#1,d7
		
.sLoop:
		add.b	d6,(a7)+
		add.w	d0,d1
		bcc.s	.fcode
		move.b	(a0)+,d2
		cmpa.l	a0,a1
		bgt.s	.noLoop
		move.l	d3,a0
		move.l	d4,a1
.noLoop:
		move.l	d2,a2
		move.b	(a2),d6
.fcode:
		dbf		d7,.sLoop

		exg		a3,a7

		rts
		
Loop8bitsAddFast:
		exg		a3,a7
		move.w	nbSamplePerFrame(pc),d7
		subq.w	#1,d7
.sLoop:	add.b	d6,(a7)+
		dbf		d7,.sLoop
		exg		a3,a7
		rts
		

; WARNING: don't move this (offset -2 and -4 hardcoded in "codeBuilder" func		

.aCodeFalcon:	add.w	d6,(a7)
				nop
.mCodeFalcon:	move.w	d6,(a7)
				nop

codeFalconFastPath:
;		move.b	d6,(a7)+
		addq.w	#4,a7
		rts

codeFalconHighLoop:				
;		move.b	d6,(a7)+
		illegal
		rts

codeFalconLowLoop:				
;		move.b	d6,(a7)+
		addq.w	#4,a7
		add.w	d0,d1
		bcc.s	.fcode
		move.b	(a0)+,d2
		cmpa.l	a0,a1
		bgt.s	.noLoop
		move.l	d3,a0
		move.l	d4,a1
.noLoop:
;		move.w	0(a2,d2.w*2),d6
		dc.l	$3c322200

;		add.w	d2,d2
;		move.w	0(a2,d2.w),d6
;		moveq	#0,d2
		
.fcode:
		rts

codeFalconLowNoLoop:				
;		move.b	d6,(a7)+
		addq.w	#4,a7
		add.w	d0,d1
		bcc.s	.fcode
		move.b	(a0)+,d2

;		move.w	0(a2,d2.w*2),d6
		dc.l	$3c322200
		
;		add.w	d2,d2
;		move.w	0(a2,d2.w),d6
;		moveq	#0,d2
.fcode:
		rts

		
	; input: d0 voice (0,1,2 or 3)
	; 	a0: Paula hardware registers (channela, etc.)
	; 	a1: Paula internal registers (pSampA, etc.)
	;	a3:	output buffer
	;	a5: Mixing routine
voiceMixProcess:

		pea	(a1)

		move.w	dmacon(pc),d3
		btst	d0,d3
		beq		.noDMA

		moveq	#0,d2
		move.w	8(a0),d2		; volume
	; NOTE: no fast path when 0 volume because pointers should advance
		cmpi.w	#64,d2
		ble.s	.vok
		move.w	#64,d2
.vok:	lsl.w	#8,d2

		move.b	iHwConfig(pc),d3
		cmpi.b	#_50KHZ_16BITS,d3
		bne.s	.no16
		add.l	d2,d2
.no16:
		lea	pVolumeTable(pc),a2
		add.l	(a2),d2			; Adresse volume table.

		lea	frequenceTable(pc),a2
		moveq	#0,d3
		move.w	6(a0),d3
		add.w	d3,d3
		add.w	d3,d3
		add.w	d3,a2
		move.w	(a2)+,-(a7)		; high part (0 or 1)
		move.w	(a2),d0			; virgule

		; pointeurs de loop
		move.l	(a0),d3			; prochain repeat sample
		moveq	#0,d1
		move.w	4(a0),d1		; rep len en words

		move.w	d1,d5			; backup replen in d5 (to test later)
		
		add.l	d1,d1
		move.l	d3,a0
		add.l	d1,a0			; prochain end loop
		move.l	a0,d4

		move.l	(a1),a0			; current sample pointer
		move.w	8(a1),d1		; current fixed int
		move.l	4(a1),a1		; current sample loop end

		move.b	iHwConfig(pc),d6
		cmpi.b	#_50KHZ_16BITS,d6
		bne.s	.no16bitsFetch

		move.l	d2,a2
		moveq	#0,d2
		move.b	(a0),d2
		add.w	d2,d2
		move.w	0(a2,d2.w),d6
		moveq	#0,d2			; 16bits version only
		
		bra.s	.fetchOk
		
.no16bitsFetch:
		move.b	(a0),d2
		move.l	d2,a2
		move.b	(a2),d6			; current output sample with volume

.fetchOk:
		move.w	d6,-(a7)

		move.l	12(a5),a6		; JMP routine (no loop by default)

		move.l	a1,d6
		sub.l	a0,d6			; nb sample to proceed before loop
		cmp.w	nbSamplePerFrame(pc),d6	; more than sample to proceed for that frame?
		bge.s	.noLoop			; then it's ok, no loop !

	; loop
		move.l	8(a5),a6			; JMP Routine with loop

		cmpi.w	#1,d5			; if replen=1 then it's probably a NULL sound (PAULA loops on two bytes)
		bgt.s	.ok
		cmpi.l	#2,d6			; if replen=1 we MUST test if a large sample is finishing
		bgt.s	.ok

		; fast
		; high with loop
		; low with loop
		; low without loop

		
		
		move.l	(a5),a6		; JMP Routine: fast path, nothing to do !
		move.w	(a7)+,d6
		addq.w	#2,a7
		
		bra.s	.go
.ok:
.noLoop:
		move.w	(a7)+,d6
		move.w	(a7)+,d7			; test high part of period, if not 0, then the frequency is high (more than one PAULA sample per ATARI sample)
		beq.s	.lowFreq

		cmpi.w	#1,d7
		bne		exepVector

		move.l	4(a5),a6		; JMP Routine: High frequency WITH loop (the slowest routine)
		
		
.lowFreq:		
.go:


		jsr	(a6)

		; no need to test loop

		move.l	(a7)+,a2
		move.l	a0,(a2)+
		move.l	a1,(a2)+
		move.w	d1,(a2)+
		
		rts

;.nullVolume:
;		move.l	12(a5),a2	; fast path
;		bra.s	.go
		
.noDMA:

		move.l	(a5),a6	; fast path
		moveq	#0,d6
		jsr	(a6)
		addq.w	#4,a7		; compense le pea (a1)
		rts

super:	ori.w	#$2000,(a7)
		rte
		
paulaTick:

		movem.l	d0-a6,-(a7)

	;---------------------------------------------------------------
	; check si on a un block libre complet
	;---------------------------------------------------------------
		lea		$ffff8900.w,a0
		move.b	$9(a0),d0
		swap	d0
		move.b	$b(a0),d0	
		lsl.w	#8,d0
		move.b	$d(a0),d0
		andi.l	#$003ffffe,d0
		lea		sampleBuffer(pc),a0
		sub.l	a0,d0					; offset dans buffer

		sub.w	renderingBlock(pc),d0	; - offset de rendering
		bmi.s	.okr					; si negatif alors rendering devant playing, c'est ok

		; si positif on doit checker si y a de la place

		move.w	blockSize(pc),d1
		cmp.w	d1,d0
		blt		.skipMixing				; si on est trop pres du player on skip le mixing pour cette frame
		
.okr:

	;---------------------------------------------------------------
	; Appel de la fonction utilisateur.
	;---------------------------------------------------------------
		move.l	userRout(pc),d0
		beq.s	.no
		move.l	d0,a0
		jsr	(a0)
.no:

	;---------------------------------------------------------------
	; Mixage des 4 voies dans samp1
	;---------------------------------------------------------------
		move.w	#$300,sr
		lea	userStack(pc),a7

;-----------------------------------------------------------
.steMixing:
;-----------------------------------------------------------

		lea		sampleBuffer(pc),a0
		add.w	renderingBlock(pc),a0
		pea		(a0)

		IFne MULTIPLEX	=1
;		{
				move.b	iHwConfig(pc),d0
				cmpi.b	#_25KHZ_8BITS,d0
				bne		.normal

	;----------------------------------------------
	; monomix routine
	;----------------------------------------------
		lea	channela(pc),a0
		lea	pSampA(pc),a1
		moveq	#0,d0
		lea	jmpTable(pc),a5
		move.l	(a7),a3
		bsr	voiceMixProcess

		lea	channelc(pc),a0
		lea	pSampC(pc),a1
		moveq	#2,d0
		lea	jmpTable(pc),a5
		move.l	(a7),a3
		addq.w	#1,a3
		bsr	voiceMixProcess

		lea	channelb(pc),a0
		lea	pSampB(pc),a1
		moveq	#1,d0
		lea	jmpTable(pc),a5
		move.l	(a7),a3
;		add.w	iRightOffset(pc),a3
		addq.w	#2,a3
		bsr	voiceMixProcess

		lea	channeld(pc),a0
		lea	pSampD(pc),a1
		moveq	#3,d0
		lea	jmpTable(pc),a5
		move.l	(a7)+,a3
;		add.w	iRightOffset(pc),a3
		addq.w	#3,a3
		bsr	voiceMixProcess

		bra		.eofmix
;	}
	endc

.normal:		
		lea	channela(pc),a0
		lea	pSampA(pc),a1
		moveq	#0,d0
		lea	jmpTable(pc),a5
		move.l	(a7),a3
		bsr	voiceMixProcess

		lea	channelc(pc),a0
		lea	pSampC(pc),a1
		moveq	#2,d0
		lea	jmpTableAdd(pc),a5
		move.l	(a7),a3
		bsr	voiceMixProcess

		lea	channelb(pc),a0
		lea	pSampB(pc),a1
		moveq	#1,d0
		lea	jmpTable(pc),a5
		move.l	(a7),a3
		add.w	iRightOffset(pc),a3
		bsr	voiceMixProcess

		lea	channeld(pc),a0
		lea	pSampD(pc),a1
		moveq	#3,d0
		lea	jmpTableAdd(pc),a5
		move.l	(a7)+,a3
		add.w	iRightOffset(pc),a3
		bsr	voiceMixProcess

.eofmix:
		
		trap	#0			; Retour en superviseur.

	;---------------------------------------------------------------
	; Avance les pointeurs pour prochain appel.
	;---------------------------------------------------------------

		move.w	blockSize(pc),d1
		move.w	d1,d2

;		IF (NB_BLOCK = 4)
;		{
			lsl.w	#2,d2
;		}
;		ELSE
;		{
;			fail
;		}

		lea		renderingBlock(pc),a0
		move.w	(a0),d0
		add.w	d1,d0
		cmp.w	d2,d0
		bne.s	.now
		moveq	#0,d0
.now:	move.w	d0,(a0)

.skipMixing:
		movem.l	(a7)+,d0-a6
		rts
		

paulaClose:	
		move.w	#$2700,sr
		move.b	#0,$ffff8901.w		; coupe le replay STE.
		lea		status(pc),a0
		move.l	(a0)+,$80.w
		move.l	(a0)+,$84.w
		move.w	#$2300,sr
		rts


writeDmaconPrivate:
		lea		dmacon(pc),a0
		btst	#15,d0
		bne.s	.set

	; Ici on clear des dma de sample: coupe chaque voie.
		not.w	d0
		and.w	d0,(a0)
		not.w	d0

		bra.s	.ok

	; Ici on allume des DMA de sample: restart chaque voie.
.set:		
		andi.w	#$7fff,d0
		or.w	d0,(a0)
		lea	channeld(pc),a0
		lea	pSampD(pc),a1
		moveq	#4-1,d1

.loop:	btst	d1,d0
		beq.s	.skip

		move.l	(a0),a2
		move.l	a2,(a1)		; set sample adress.
		moveq	#0,d2
		move.w	4(a0),d2		; set sample len
		add.l	d2,d2
		add.l	d2,a2
		move.l	a2,4(a1)
		move.w	#0,8(a1)		; fixed part = 0

.skip:	lea	-16(a0),a0
		lea	-10(a1),a1
		dbf	d1,.loop

.ok:	
		rts

; d0.w : dmacon
writeDmacon:
		movem.l	d0-d2/a0-a2,-(a7)
		bsr		writeDmaconPrivate
		movem.l	(a7)+,d0-d2/a0-a2
		rte

;-----------------------------------------------------------------

bTableOk:			dc.b	0
iHwConfig:			dc.b	0
iMachine:			dc.b	0
					even
					
nbSamplePerFrame:	dc.w	PAULA_25K_NBSAMPLE_PER_BLOCK
blockSize:			dc.w	PAULA_25K_NBSAMPLE_PER_BLOCK * 2		; *2 for stereo
iRightOffset:		dc.w	1
nullSample			dc.w	0
renderingBlock:		dc.w	0
pVolumeTable:		ds.l	1
userRout:			ds.l	1

status:				ds.l	1
					ds.l	1

	; Custom chip AMIGA:
	;	$dff0a0.L : Sample start adress
	;	$dff0a4.W : Sample length (in words)
	;	$dff0a6.W : Channel period.
	;	$dff0a8.W : Channel Volume.

	; Amiga paula frequency:
	;	freplay = 1 / (period*2.79365E-7)

pSampA		ds.l	1       ; current sample ptr
		ds.l	1	; end sample ptr
		ds.w	1	; fixed point
pSampB		ds.l	1       ; current sample ptr
		ds.l	1	; end sample ptr
		ds.w	1	; fixed point
pSampC		ds.l	1       ; current sample ptr
		ds.l	1	; end sample ptr
		ds.w	1	; fixed point
pSampD		ds.l	1       ; current sample ptr
		ds.l	1	; end sample ptr
		ds.w	1	; fixed point


custom:		ds.b	$96		; Libre de $dff00 a $dff096

dmacon		dc.w	0		; DMACON ($dff096)

			ds.b	8		; 8 dummy bytes

channela:	; $dff0a0
		dc.l	$CDCDCDCD
		dc.w	0
		dc.w	0
		ds.b	8		; Custom chip canal 0
channelb:
		dc.l	$CDCDCDCD
		dc.w	0
		dc.w	0
		ds.b	8		; Custom chip canal 0
channelc:
		dc.l	$CDCDCDCD
		dc.w	0
		dc.w	0
		ds.b	8		; Custom chip canal 0
channeld:
		dc.l	$CDCDCDCD
		dc.w	0
		dc.w	0
		ds.b	8		; Custom chip canal 0

jmpTable:	
		ds.l	1		; lowFreq, with loop, MOVE
		ds.l	1		; lowFreq, no loop, MOVE
		ds.l	1		; high freq, with loop, MOVE
		ds.l	1		; fast path, MOVE
		
		
jmpTableAdd:	
		ds.l	1		; lowFreq, with loop, ADD
		ds.l	1		; lowFreq, no loop, ADD
		ds.l	1		; high freq, with loop, ADD
		ds.l	1		; fast path, add (=none)
		
		ds.l	32
userStack:					; only used for internal user stack


				even

sampleBuffer:	
		ds.w	PAULA_50K_NBSAMPLE_PER_BLOCK * NB_BLOCK	* 2; 16Kb (Warning: 32bits samples at worst (stereo 16 bits))	maximum lengh for 25 or 50khz
		even

frequenceTable:	
		ds.l	PERMAX					;	4Kb
		even

volumeTableBuffer:
		ds.b	(65*256)*2+255				;	34Kb	*2 for 16bits volume table (falcon)
		even

codeBuffer:	
		ds.b	128*1024				;	128Kb
		even
zx

