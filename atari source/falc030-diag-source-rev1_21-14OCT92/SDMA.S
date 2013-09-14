*-------------------------------
* SDMA Audio Tests - Attempt # 1 (SOMEBODY's got to do it)
*------------------------------- 
* Started : Roy Stedman 22JUN92
*
* Right now the plan is to do three loopbacks:
 
* 1. DSP SSI (already done in DSP.s - no work here)

* 2. DMA Play -> XO -> Loopback -> XI -> DMA Record
;	we need to use GP1 to trigger XO_SYNC and XI_SYNC.
;	we can't check XI_CLK because it's an output.
;	with the sinewave from part 2, we get it back exactly..
;	we should test the lsb's too though...maybe 2 or 3 passes..
;	sine, linear, pseudorandom
; NOTE: Functional! Sometimes wave may be slightly shifted. Don't know why.

* 3. DMA Play -> DAC  -> Loopback -> ADC -> DMA Record
;	For this we have to start a sinewave and see what we
;	get back. Horton wants to do FFT's on it. I don't. 
;	I'm going to check to see the wave is at least
;	triangular. Beyond that I don't care much, at least 
;	for this version.
; NOTE: Functional. Test is visual (using Video:Graph). But the idea works.

;;;	Note, the Xrec/Xsrc = Const. test is not done. It should be.

* 4. EXINT <-> GP0 We'll also trigger EXT_INT with GP0 for fun. GP2 can be
; 	connected to GP0 for all we care. And we do, so much.

; NOTE: Strange error/bug when returning to menu. Dunno what it is, I
; think it has something to do with loopback & MFP, but aren't sure
; (maybe uWire junk?)


* We don't check any DSP audio, the EXTCLK & such... that needs to
* be done later, along with more complex tests. 
* maybe Tom Le will get around to it.

	.include hardware
	.include defs
	.include macros
	.include nvram

.macro SHOWWORD byt
	bsr	dspspc
	move.w	d1,-(sp)
	move.w	\byt,d1
	bsr	dspwrd
	move.w	(sp)+,d1
.endm

.macro ZEROCROSSCHK	
	tst.w	(a0)		; NOW!: Only checks for +- transitions
	bmi	.\~minus
	tst.w	4(a0)
	bmi	.\~cross
	bra	.\~endeq
.\~minus:
;	tst.w	2(a0)
;	beq	.\~cross
;	bpl	.\~cross
;== SET EQUAL
.\~endeq:
	addq.l	#4,a0		;stick with the same channel
	cmp.b	d0,d0
	bra	.\~end
.\~cross:
	addq.l	#4,a0
.\~end:
.endm

.macro	cmp2wa0d1
;	cmp2.w	(a0),d1
	dc.l	$02d01000
.endm

.macro	CHECKGUARD guard,checkee,guardval
	movem.l	d1/a0,-(sp)
	move.w	\checkee,d1
	move.l	#guardlo,a0
	move.w	\guard,(a0)
	move.w	\guard,2(a0)
	add.w	\guardval,2(a0)
	sub.w	\guardval,(a0)
	cmp2wa0d1	
	movem.l	(sp)+,d1/a0
.\~exit:	
.endm

.macro	RESETSDMA
	move.w	#$0008,DACRECCTRL	; global sound reset
	nop
	move.w	#$0000,DACRECCTRL
.endm

	.extern falmsg,pasmsg,SDMAerrflg
	.globl SDMA

VR = mfp+vr
AER = mfp+aer
DDR = mfp+ddr
IERB = mfp+ierb
IPRB = mfp+iprb
IMRB = mfp+imrb
GPIP = mfp+gpip

RECADDR		= $48000	; we should probably change these : DONE :RWS 24JUL92
PLAYADDR	= $44000 	; NOTE : they are hardcoded below!

;SineWave = m1k3 + 4
 
;AUXACTRL	equ	$ffff8938
;AUXAIN		equ	$ffff893c
;AUXBCTRL	equ	$ffff893a
;CLOCKSCALE	equ	$ffff8934
;DACRECCTRL	equ	$ffff8936
;DATAMXREC	equ	$ffff8932
;DATAMXSRC	equ	$ffff8930
;GPIOC		equ	$ffff8940
;GPIOD		equ	$ffff8942
;PLAYMODECR	equ	$ffff8920
;SNDCTRL	equ	$ffff8900
SNDFBALL	equ	$ffff8907
SNDFBALM	equ	$ffff8905
SNDFBAUM	equ	$ffff8903
SNDFEALL	equ	$ffff8913
SNDFEALM	equ	$ffff8911
SNDFEAUM	equ	$ffff890f

DSPLB = 1
DIGLB = 2
ANALB = 5
EXINT = 4
EXINT2 = 3	; GP1 fail

;	.bss
;SDMAerrflg:	ds.b	1
	.text

*========================================================
SDMA:
	movem.l	d0-d7/a0-a6,-(sp)
;	move.l	sp,d7
	lea.l	DSPTESTMsg,a5
	bsr	dsptst
;RWS.T	
;	move.b	SPControl,d1
;	bsr	dspbyt
;
;;RWS.TPE	bclr.b	#5,SPControl	; turn off bus errors for test
	clr.b	SDMAerrflg
	RESETSDMA
.dtst:
	clr.b	erflg0
	bset.b	#5,SPControl
	bsr	DSPSSITEST
;	bra	.dtst
	tst.b	erflg0
	beq	.dsppassed
	bset.b	#DSPLB,SDMAerrflg
.dsppassed:
;;RWS.TPE	bclr.b	#5,SPControl	; turn off bus errors for test (again)
	clr.b	erflg0
	move.w	#3,tries
	bsr	SDMA_test2
	bsr	SDMA_test4	; put exint before analog loop
	move.w	#3,tries
	bsr	SDMA_test3
	bsr	CheckErrors
	
;	move.l	d7,sp
;;RWS.TPE	bset.b	#5,SPControl	; berrs back on..
	movem.l	(sp)+,d0-d7/a0-a6
	rts

*========================================================
;TEST2:
;	Setup DMA W/sinewaves
;	Connect DMA out -> XO looping
;	Connect DMA in	-> XI one-shot (larger buffer)
;	Setup XO, XI handshaked, same clocks? (maybe mess w/prescaler)
;	Start XI, XO
;	Hit play
;	Hit record
;	WAIT
;	Turn off DMA & such
; NOTE : THIS ONE TESTS HANDSHAKE LINES...
SDMA_test2:
	DSPMSG	DIGLBMsg
	RESETSDMA
* setup DMA
	bsr	SetupSDMA
* FILL SOURCE DATA..
	bsr	FillSource
* CLEAR GP1
	move.w	#$4,GPIOC	; bit is an output
	move.w	#0,GPIOD

* hook up DMA's/ set multimix
	move.w	#$00c3,PLAYMODECR	; mon trks 1,2, play 2 tracks, 16bit stereo, /160 prescale
	move.w	#$0008,DATAMXSRC	; all on internal 25.175 MHz clock, handshake
	move.w	#$008c,DATAMXREC	; DAC <- dma out, extout <- dma out, DSP <- dma (no tri st), DMA in <- ext
	move.w	#$0002,CLOCKSCALE	; prescale on clocks ??? (no sampling noise, please)
	move.w	#$0002,DACRECCTRL	; record trks 1&2, no reset, enable data to dac, no psg
	move.w	#$0000,AUXACTRL		; codec mic input, small gain.
	move.w	#$0000,AUXBCTRL 		
* setup & start XO,XI
	move.w	SNDCTRL,d0
	ori.w	#$0011,d0		; record & play enable
	move.w	d0,SNDCTRL
* raise GP1
	move.w	#4,GPIOD
* wait for transfer
	move.w	#$ffff,d0			; wait for sound data to play.
.lp:		
	dbra	d0,.lp
* lower GP1
	move.w	#0,GPIOD
* turn stuff off
	RESETSDMA
* compare record buffer
	bsr	CheckBuffers
	bne	.failed
	DSPMSG	pasmsg
	CRLF
	bra	.exit
.failed:
	sub.w	#1,tries
	bne	SDMA_test2
;TEMP FOR TAIWAN RUN #1 (for some reason sound only works occasionally)

	bset.b	#DIGLB,SDMAerrflg
	DSPMSG	DIGLBNEMsg
	move	#red,palette
.exit:
	rts 

*==========================================
* Checkbuffers - compare record and play buffers
CheckBuffers:
	move.l	#RECADDR+100,a0		; skip over first 100 samples
	move.l	#PLAYADDR+100,a1
	move.w	#1000,d1		; check 1001 entries
.lp:
	cmp.w	(a0)+,(a1)+
	dbne	d1,.lp			; sets equal at end if ok..
	rts

*-----------------------------
* FILL SOURCE DATA..
FillSource:
	move.l	#PLAYADDR,a0	; play addresses
	move.l	#RECADDR,a2	; record address
	move.l	#PLAYADDR+$1000,a1	; end of play
	move.l	#SineWave,a3
.lpa:
	move.b	(a3)+,d0
	asl.w	#8,d0		; turn it into a 16 bit word
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	cmp.l	#SineEnd,a3
	bne	.skip
	move.l	#SineWave,a3	; loop through it again
.skip:	
	move.l	#0,(a2)+ 	; clear record buffer
	move.l	#0,(a2)+ 
	cmp.l	a0,a1		; at end?
	bne	.lpa		; no, keep going..

	rts

*========================================================
;TEST3:
;	Setup DMA W/sinewaves
;	Set DMA out -> DAC looping
;	Set DMA in  -> ADC one shot (larger buffer)
;	Hit play
;	Hit record
;	WAIT
;	Turn off DMA & such
;	Compare sineliness of input
;	compute frequency for boredom relief & time wasting
SDMA_test3:
	DSPMSG	ANALBMsg
	bclr.b	#ANALB,SDMAerrflg
	RESETSDMA
* setup DMA
	bsr	SetupSDMA
	bsr	FillSource

* hook up DMA's/ set multimix
	move.w	#$00c3,PLAYMODECR	; mon trks 1,2, play 2 tracks, 16bit stereo, /160 prescale
	move.w	#$0009,DATAMXSRC	; all on internal 25.175 MHz clock, no handshake
	move.w	#$0087,DATAMXREC	; DAC <- dma out, extout <- dma out, DSP <- dma (no tri st), DMA in <- ADC
	move.w	#$0101,CLOCKSCALE	; prescale on clocks ??? (no sampling noise, please)
	move.w	#$0002,DACRECCTRL	; record trks 1&2, no reset, enable data to dac, no psg
	move.w	#$00aa,AUXACTRL		; codec mic input, small gain. 
	move.w	#$0000,AUXBCTRL		
* setup & start XO,XI
	ori.w	#$0001,SNDCTRL	; record & play enable
	move.w	#$ff,d0
.lp12:	nop				; wait for sound data to play.
	dbra	d0,.lp12
	ori.w	#$0010,SNDCTRL
* wait for transfer
	move.w	#$ffff,d0
.lp11:	nop				; wait for sound data to play.
	dbra	d0,.lp11

* kill lsb's (we only had 8 bit quantizing to begin with)

	move.l	#RECADDR,a0	; kill off 7 lsb's
.lp2:
	move.w	(a0),d0
	andi.w	#$ff80,d0
;;	andi.w	#$fe00,d0
	tst.b	d0
	beq	.skip
	add.w	#$0100,d0
	andi.w	#$ff00,d0
.skip:
	move.w	d0,(a0)+
	cmp.l	#RECADDR+$4000,a0
	bne	.lp2
*----------
* QConnChk: quick test to see if we got ANYTHING
* usu. there's sampling noise at t=0 - t-400
QConnChk:
	move.l	#RECADDR+$400,a0
	move.l	(a0),d0
	move.w	#$8f,d1
.lpc:
	cmp.l	(a0)+,d0
	dbne	d1,.lpc
	bne	Graph
	DSPMSG	ANALBNoDatMsg
	
;;RWS.TP 1.18d	sub.w	#1,tries
;;	bne	SDMA_test3
;TEMP FOR TAIWAN RUN #1 (for some reason sound only works occasionally)
	move.w	#red,palette
	bset.b	#ANALB,SDMAerrflg
	bra	endofANALB
	
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Graph:
	tst.b	ProdTestStat
	bpl	endGraph
	tst.b	autotst		; skip over sequences too..
	bne	endGraph
	move.l	#spscrmem,a0
	move.w	#$2000,d0
.clar:	move.l	#0,(a0)+
	dbra	d0,.clar
 
	move.w	#639,maxx
	move.w	#199,maxy
	move.w	#1,wrdmde	; # planes -1
	move.w	#160,bytperline
	move.w	#2,logplanes	; log2(#planes*2) ??
	move.l	#$0,d0		; x starts at 0
.setvid:
	move.b	#spscrh,v_bas_h	; - SET VIDEO BASE ADDR
	move.b	#spscrm,v_bas_m
	move.b	#spscrl,v_bas_l

	move.l	palette+4,d5
	move.l	#$00030ff0,$ff8240	; set colors
	move.l	#$0fff0f00,$ff8244	; set colors

	move.l	#PLAYADDR,a0	; start of source data
.Glp:
	move.w	(a0)+,d3
	move.w	(a0)+,d3
	asr.w	#8,d3
	asr.w	#1,d3
;	asr.w	#4,d3
	add.w	#100,d3
	move.w	d3,d1
	move.w	#1,d4		; color
	bsr	VGAPoint	; d0 =x, d1 = y, d4 = color
	add.w	#1,d0
	cmp.w	maxx,d0
	bne	.Glp

	move.l	#0,d0
	move.l	#RECADDR+$800,a0	; start of recorded data
.Glp2:
;	move.w	(a0)+,d3
	move.w	(a0)+,d3
	asr.w	#8,d3
	asr.w	#1,d3
;	asr.w	#4,d3

	add.w	#100,d3
	move.w	d3,d1
	move.w	#2,d4		; color
	bsr	VGAPoint	; d0 =x, d1 = y, d4 = color
; next channel
	move.w	(a0)+,d3
	asr.w	#8,d3
	asr.w	#1,d3
;	asr.w	#4,d3

	add.w	#100,d3
	move.w	d3,d1
	move.w	#3,d4		; color
	bsr	VGAPoint	; d0 =x, d1 = y, d4 = color

	add.w	#1,d0
	cmp.w	maxx,d0
	bne	.Glp2

	bsr	uconin
	move.l	d5,palette+4
	move.b	#scrmemh,v_bas_h	; - SET VIDEO BASE ADDR
	move.b	#scrmemm,v_bas_m
	move.b	#scrmeml,v_bas_l

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
endGraph:

*** CHECK RETURNED WAVES ***
* Skip over first few hundred samples.
;	check R & L are close
;	find zero crossing
;	match w/src wave
;	match points are 'close' to each other
;	orig/rcvd should be constantish.
;---------------------------------------------

*--- Check R & L =
	move.l	#RECADDR+$1000,a0	; skip junk, I hope
	move.w	#1000,d2
RLloop:
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	CHECKGUARD d0,d1,#$1000		; way too big...
	dbcs	d2,RLloop
	bcc	.noerrRL
	bset.b	#ANALB,SDMAerrflg
	DSPMSG	RLNEMsg
	bsr	dsptab
	bsr	dspwrd
	move.w	d0,d1
	bsr	dspspc
	bsr	dspwrd
	bsr	crlf
.noerrRL:
*---
.nexttst:
*--------------------------------
* Check spacing of zero crossings.
ZeroTst:
	move.l	#PLAYADDR,a0
	clr.l	d0
.lp0:
	add.w	#8,d0
	tst.l	(a0)+
	tst.l	(a0)+
	bne	.lp0
.lp1:
	add.w	#8,d0
	tst.l	(a0)+
	tst.l	(a0)+
	bne	.lp1
	subq.l	#8,d0	;get rid of last one
.loop0:
;	ZEROCROSSCHK
;	beq	.loop0
;	clr.l	d0
;.loop1:
;	addq	#1,d0		; establish spacing of first wave
;	ZEROCROSSCHK
;	beq	.loop1
; now check the rest are ~= d0/2.

	asr.l	#1,d0
	move.l	#RECADDR+$800,a0
.lp11:	ZEROCROSSCHK
	beq	.lp11
;.lp12:	ZEROCROSSCHK
;	beq	.lp12
	move.w	#10,d3		; test 10 cycles
.loop2:
;	SHOWWORD d1
	clr.l	d1
.loop3:
	addq.l	#1,d1
	ZEROCROSSCHK
	beq	.loop3
	CHECKGUARD d0,d1,#8
	dbcs	d3,.loop2
	tst.b	d3
	bmi	.test3
; failed.... oops	
;---
	sub.w	#1,tries
	bne	SDMA_test3
;TEMP FOR TAIWAN RUN #1 (for some reason sound only works occasionally)

	DSPMSG	WaveNEMsg
	bsr	dsptab
	bsr	dspwrd		; separation of erring wave
	bsr	dspspc
	move.w	d0,d1
	bsr	dspwrd		; what we wanted
	bsr	crlf
	bset.b	#ANALB,SDMAerrflg
	bra	endofANALB

; make sure wave fits under source wave
; ( should do Xrec/Xsrc = K, & check K is really constant)
; right now all we do is check signs are =
.test3:
* Phase match src & rec
.Pmatch:
	move.l	#PLAYADDR,a0
	move.l	#RECADDR+$500,a1
.cmp1:	cmpi.w	#0,(a0)+
	bne	.cmp1
; now we are one point further along than zero point
; we are either matched or 90' out of phase. gonna hafta work on that.
.cmp2:
	cmpi.w	#0,(a1)+
	bne	.cmp2
	tst.w	$10(a1)		; check the sign a few bits along.
	bmi	.cmp2

; ok, both are phase matched now (as long as they are freq. locked)
*=========
	bra	.test4		;RWS.T TEMP ! THIS BELOW HAS PROBLEMS TO BE FIXED LATER
;
;	move.w	#500,d3		; number of samples to check
;.cklop:
;	bsr	.letest		;uses a0,a1,d0,d1
;	dblt	d3,.cklop
;	bge	.test4		; skip over fail stuff
;
;;* go along, checking only sign bits until end	
;;.signlp:
;;	move.w	(a0)+,d0
;;	move.w	(a1)+,d1
;;	andi.w	#$8000,d0
;;	andi.w	#$8000,d1
;;	cmp.w	d0,d1
;;	dbeq	d2,.signlp	
;;	beq	.test4
;;failed.... oops
	DSPMSG	WaveWrongMsg
	bset.b	#ANALB,SDMAerrflg
.test4: 
endofANALB:
	btst.b	#ANALB,SDMAerrflg
	beq	.passed
	move.w	#red,palette
	bra	.exit
.passed:	
	DSPMSG	pasmsg
	CRLF
.exit:
* we're DONE! Turn stuff off
	RESETSDMA
	rts
*=========
; .letest: check less than or equal
;	compare:	|src| >= |rec|
.letest:
;	move.w	(a0)+,d0	;get src
;	bpl	.plus
;	neg.w	d0
;.plus:
;	move.w	(a1)+,d1
;	bpl	.noneg
;	neg.w	d1
;.noneg:
;	SHOWWORD d0
;	SHOWWORD d1
;	cmp.w	d0,d1
	rts

*=========================================================
;TEST4:
;	Setup to get an interrupt from EX_INT (MFP IO3).
;	hit GP0
;	wait for it.
;	if we don't get it, err...
SDMA_test4:
	DSPMSG	EXINTMsg
	bset.b	#EXINT,SDMAerrflg	; set initial error..
* CLEAR GP0
	move.w	#1,GPIOC	; bit is an output
	move.w	#1,GPIOD

	move.l	#3,d0		; 
	move.l	#sdmaint,a2		

	bsr	initint
	move.b	#$00,GPIP
* HIT GP0   
	andi.w	#$fffe,GPIOD	; clear bit 0
	nop
	nop
	nop
	nop
	move.w	GPIOD,d2	; save GP2 stat
	move.w	#1,GPIOD
	move.w	#$ffff,d1
.loop2:
	nop			;wait for interrupt
	dbra	d1,.loop2
	move.w	GPIOD,d1
	move.w	#0,GPIOD	; set back to 0

* TURN OFF MFP INTERRUPT.
	move.b	#3,d0
	bsr	disint

	eor.w	d1,d2
	cmp.b	#$03,d2		; GP1 & GP0 lit..
	beq	.nexttst
	bset.b	#EXINT2,SDMAerrflg
	move	#red,palette
	DSPMSG	GP1ERRMsg
	bra	.exit
.nexttst:
	btst.b	#EXINT,SDMAerrflg
	beq	.pass
.fail:
	move	#red,palette
	bset.b	#EXINT,SDMAerrflg	; timed out waiting for int
	DSPMSG	NoEXINTMsg
	bra	.exit
.pass:
	DSPMSG	pasmsg
	CRLF
.exit:
	move.w	#$00,GPIOC	; all bits input for now.
	rts

*--------------------------------
* interrupt handler for extint
sdmaint:
	bclr.b	#EXINT,SDMAerrflg
	rte

******************************************************************
*-------------------
* check for errors..
*-------------------
CheckErrors:
	cmpi.b	#0,SDMAerrflg
	beq	.green
	move.b	SDMAerrflg,d1
;RWS.T	bsr	dspbyt		; for testing use
.red:
* do error stuff
	lea.l	falmsg,a5
	bra	.outta
.green:
	lea.l	pasmsg,a5
.outta:
	move.b	#t_DSP,d0
	bsr	dsppf
	CRLF
* restore registers?
	rts

***************************
***************************

*---------- Sound Play/Record setup for one shot record & multi play
*	sound data should be a 1kHz sinewave, preferably 16 bits/

SetupSDMA:
* setup record regs
	move.b	#%0000,SNDCTRL		; no SINT or SCNT
	move.b	#%10000000,SNDCTRL+1	; record, no repeat, not enabled
*	move.b	#%10100000,SNDCTRL+1	; record, repeat, not enabled
	move.b	#$04,SNDFBAUM		; address is $40000-$44000 ???
	move.b	#$80,SNDFBALM
	move.b	#$00,SNDFBALL

	move.b	#$04,SNDFEAUM
;RWS.TPE	move.b	#$40,SNDFEALM
	move.b	#$f0,SNDFEALM
	move.b	#$00,SNDFEALL
* setup play regs
	move.b	#%0000,SNDCTRL		; no SINT or SCNT
	move.b	#%00000010,SNDCTRL+1	; play, repeat, not enabled
	move.b	#$04,SNDFBAUM		; address is $50000-$51000 ???
	move.b	#$40,SNDFBALM
	move.b	#$00,SNDFBALL

	move.b	#$04,SNDFEAUM
	move.b	#$47,SNDFEALM
	move.b	#$80,SNDFEALL
	rts


	.data

DIGLBNEMsg:	dc.b	'Data Not Equal',CR,LF,EOT
DIGLBMsg:	dc.b	'Digital Loopback...',EOT
ANALBMsg:	dc.b	'Analog Loopback...',EOT
EXINTMsg:	dc.b	'External Interrupt...',EOT
NoEXINTMsg:	dc.b	'No Ext Int',CR,LF,EOT
GP1ERRMsg:	dc.b	'GP1 failure',CR,LF,EOT
DSPTESTMsg:	dc.b	'Testing DSP Port and Analog Loopback',CR,LF,EOT
RLNEMsg:	dc.b	'Right and Left not equal',EOT 
WaveNEMsg:	dc.b	'Frequency Check Failed',EOT
WaveWrongMsg:	dc.b	'Waveform Mismatch',CR,LF,EOT
ANALBNoDatMsg:	dc.b	'No Record Data',CR,LF,EOT


