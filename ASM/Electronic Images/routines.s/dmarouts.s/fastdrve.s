 	opt	p+
*	opt	o+

***********************************************************************
*  Ok... hopefully, dear god... this is the 99.9% finished version	*
* of the sound driver... this update 7/4/90.			*
***********************************************************************
* Flags
*
BINARY	equ	0
DEBUG	equ	1
HERTZ200	equ	0
NOISESEQ	equ	0
QUICKMAKE	equ	0
 IFNE	quickmake
 IFNE	hertz200
 "ERROR - INVALID OPTIONS!!"
 ENDC
 ENDC
*
* UDF flags
U_numberoftunes	equ	1
* Global offsets
__tunexists	equ	0
__changedwave	equ	2
__200count	equ	4
__timerasave	equ	6
* Array offsets
_arangbase	equ	0	Arrangement base long
_arangoff		equ	4	Arrangement offset word
_notebase		equ	6	Note base long
_noteoff		equ	10	Note offset word
_synthbase	equ	12	Synth block base long
_synthoff		equ	16	Synth block offset word
_restcount	equ	18	Rest countdown word
_notecount	equ	20	Note countdown word
_portcount	equ	22	Portamento countdown word
_arangecount	equ	24
_lastnote		equ	26	Last note word
_lastfreq		equ	28	Last frequency word
_workfreq		equ	30	Working frequency word
_chord1freq	equ	32	Chording frequency 1
_chord2freq	equ	34	 " 2
_chord3freq	equ	36	 " 3
_notetrans	equ	38	Note transponse word
_freqtrans	equ	40	Frequency transponse word
_chord1off	equ	42	Chording additions 1
_chord2off	equ	44	 " 2
_chord3off	equ	46	 " 3
_freqinuse	equ	48	Which frequency to output
_startvol		equ	50	Starting volume
_workvol		equ	52	Working/current volume
_allownoise	equ	54	Allow noise 1 yes 0 no
_startnoise	equ	56	Start noise 0 for none
_worknoise	equ	58	Working noise
_wavenote		equ	60	Note of wave
_setwaves		equ	62	Wave allow/setting
_waveperiod	equ	64	Period
_waveisused	equ	66	For output... use wave?
_udfperiod	equ	68
_miniloopcount	equ	70	Miniloop counter
_miniloop1	equ	72	Storage
_miniloop2	equ	74	 "
_miniloop3	equ	76	 "
_miniloop4	equ	78	 "
_porting		equ	80	Yes or no...
_portvalue	equ	82	How much to port by
_portcountstart	equ	84
_portspeed	equ	86
_voicestate	equ	88	Two low bits for note/noise on/off

_topreges		equ	88	The number of offsets
*** Noise offsets
_n_arangebase	equ	0
_n_arangeoff	equ	4
_n_notebase	equ	6
_n_noteoff	equ	10
_n_arangecount	equ	12
_n_countdown	equ	14
_n_worknoise	equ	16
_n_noisestate	equ	18
*** Output offsets
_o_tonealow	equ	4+0
_o_toneahi	equ	4+6
_o_toneblow	equ	4+12
_o_tonebhi	equ	4+18
_o_toneclow	equ	4+24
_o_tonechi	equ	4+30
_o_noisefreq	equ	4+36
_o_control	equ	4+42
_o_volumea	equ	4+48
_o_volumeb	equ	4+54
_o_volumec	equ	4+60
_o_waveformlow	equ	4+66
_o_waveformhi	equ	4+72
_o_waveformdef	equ	4+78
**********
* The general driver. Removed if BINARY=1
**********
	IFEQ	BINARY
	
	clr.l	-(a7)		Supexec
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	lea.l	STACKSAVE(pc),a0
	move.l	d0,(a0)
	
	lea.l	VBLSAVE(pc),a0	Save old vbl
	move.l	$70,(a0)
	
	moveq	#1,d0		Tune number
	bsr	C_Z_I		Setup driver
		
	move.w	#$2700,sr
	
	lea.l	NEWVBL(pc),a0
	move.l	a0,$70
	
	bsr	FLUSH
	
	move.w	#$2300,sr
	
	move.w	#7,-(a7)		Wait key
	trap	#1
	addq.l	#2,a7
	
	move.w	#$2700,sr
	
	moveq	#0,d0		No tunes
	bsr	C_Z_I		Call off
	
	bsr	FLUSH
	
	lea.l	VBLSAVE(pc),a0
	move.l	(a0),$70
	
	move.w	#$777,$ff8240
	
	move.w	#$2300,sr
	
	lea.l	STACKSAVE(pc),a0	User mode
	move.l	(a0),-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	
	clr.w	-(a7)		Exit
	trap	#1
*********
FLUSH
	btst.b	#0,$fffffc00.w	Flush keybuffer
	beq.s	FLUSH_DONE
	move.b	$fffffc02.w,d0
	bra.s	FLUSH
FLUSH_DONE
	rts
	
NEWVBL
	movem.l	d0-d7/a0-a6,-(a7)	New vbl calling my routine
	IFNE	DEBUG
	move.w	#2500,d0
TIMING
	dbra	d0,TIMING
	eori.w	#$700,$ffff8240.w
	ENDC
	bsr	C_Z_I+2		+6 gives registers saved
	IFNE	DEBUG
	eori.w	#$700,$ffff8240.w
	ENDC
	movem.l	(a7)+,d0-d7/a0-a6
	rte

STACKSAVE
	ds.l	1
VBLSAVE
	ds.l	1
	ENDC
**************
* The driver
**************
C_Z_I
	bra.s	INITIALISE
	bra	DRIVER
	bra	DRIVER_WITHSAVE
 IFNE	quickmake
	bra	SUPEROUTPUT
 ENDC
	dc.b	"Count Zero (Electronic Images) Music 01/07/90."
	dc.b	"Phone 071-794-0771."
	dc.b	"Please credit me if you use this music! Thanks!"
	even

INITIALISE
	movem.l	d0-d7/a0-a6,-(a7)
	tst.l	d0
	bgt.s	TUNEON
	
	IFNE	hertz200
	bclr	#5,$fffffa07.w
	bclr	#5,$fffffa13.w
	lea.l	GLOBALS(pc),a0
	move.l	__timerasave(a0),$134
	ENDC
	
	bsr	INITCHIP
	lea.l	GLOBALS(pc),a0
	clr.w	__tunexists(a0)
	movem.l	(a7)+,d0-d7/a0-a6
	rts
TUNEON
	cmpi.l	#U_numberoftunes,d0
	bhi.s	NO_SUCH_TUNE

	lea.l	GLOBALS(pc),a0
	move.w	d0,__tunexists(a0)
	
	IFNE	hertz200
	move.l	$134,__timerasave(a0)
	ENDC
	
	bsr	INITCHIP
	bsr	INSTALLTUNE
NO_SUCH_TUNE
	movem.l	(a7)+,d0-d7/a0-a6
	rts
*************
* Clear Soundchip
*************
INITCHIP	lea $ffff8800.w,a0
	move.b	#$7,(a0)		Control
	move.b	2(a0),d1		Get control byte
	and.b	#%11000000,d1	Get top two bits
	move.w	#$D00,d0
	move.w	#$100,d2
INITCHIPLOOP
	movep.w d0,(a0)
	sub.w d2,d0
	bge.s INITCHIPLOOP
	move.b	#$7,(a0)		Control
	move.b	d1,2(a0)		Restore control
	rts
*************
* Install the tune
*************
INSTALLTUNE
	lea.l	VOICE1(pc),a1	Clear the voice arrays
	lea.l	VOICE2(pc),a2
	lea.l	VOICE3(pc),a3
	moveq	#(_topreges/4)-1,d0
	moveq	#0,d7
CLEARVOICESLOOP
	move.l	d7,(a1)+	
	move.l	d7,(a2)+	
	move.l	d7,(a3)+	
	dbra	d0,CLEARVOICESLOOP

	lea.l	GLOBALS(pc),a0	Prepare for installing a tune
	move.w	__tunexists(a0),d7	Get tune number
	subq.w	#1,d7		-1 for offsets
	lsl.w	#3,d7		8 byte offset

	lea.l	SETUPS(pc),a0	Get the setups
	adda.w	d7,a0		And offset them
	lea.l	VOICE1(pc),a1	Base address voice1
	bsr.s	INSTALLAVOICE	Do one voice

	lea.l	SETUPS+2(pc),a0	Get the setups ( +2 Extra for next offset)
	adda.w	d7,a0		And offset them
	lea.l	VOICE2(pc),a1	Base address voice1
	bsr.s	INSTALLAVOICE	Do one voice

	lea.l	SETUPS+4(pc),a0	Get the setups ( +4	Extra for next offset)
	adda.w	d7,a0		And offset them
	lea.l	VOICE3(pc),a1	Base address voice1
	bsr.s	INSTALLAVOICE	Do one voice
 IFNE	noiseseq
	bsr.s	INSTALLNOISE	Install the noise
 ENDC
	rts

INSTALLAVOICE
	moveq	#0,d0		Clear d0
	move.w	(a0),d0		Get arrange offset for this voice
	lea.l	ARRANG_BASE(pc),a0	Get base of arrangements
	adda.w	d0,a0		Make offset an address
	move.l	a0,_arangbase(a1)	Save it
	clr.w	_arangoff(a1)	Clear offset
	move.l	(a0),d0		Get the data for first offset
	move.w	d0,_arangecount(a1)	Save counter
	swap	d0		Access offset
	lea.l	NOTE_BASE(pc),a0	Get base of notes(bars)
	adda.w	d0,a0		Get base as an address
	move.l	a0,_notebase(a1)	Save address
	move.w	#-2,_noteoff(a1)	Set startup note offset
	lea.l	INS_0(pc),a0	Nothing instrument
	move.l	a0,_synthbase(a1)	Save it
	rts
 IFNE	noiseseq
INSTALLNOISE
	lea.l	SETUPS+6(pc),a0	Get setups (+6 For noise)
	adda.w	d7,a0		Offset
	lea.l	NOISE(pc),a1	Noise storage
	moveq	#0,d0
	move.w	(a0),d0		Get arrange offset
	lea.l	ARRANG_BASE(pc),a0
	adda.w	d0,a0
	move.l	a0,_n_arangebase(a1)
	clr.w	_n_arangeoff(a1)
	move.l	(a0),d0
	move.w	d0,_n_arangecount(a1)
	swap	d0
	lea.l	NOTE_BASE(pc),a0
	adda.w	d0,a0
	move.l	a0,_n_notebase(a1)
	move.w	#-2,_n_noteoff(a1)
	rts
 ENDC
*************
* The driver itself
*************
DRIVER_WITHSAVE
	movem.l	d0-d7/a0-a6,-(a7)
	bsr.s	DRIVER
	movem.l	(a7)+,d0-d7/a0-a6
	rts
DRIVER
	lea.l	GLOBALS(pc),a0
	tst.w	__tunexists(a0)
	beq.s	NO_PLAY
	bsr	DO_OUTPUT		Working
	IFNE	hertz200
	move.b	#$0,$fffffa19.w
	lea.l	SYNTH200(pc),a0
	move.l	a0,$134.w
	lea.l	GLOBALS(pc),a0
	move.w	#2,__200count(a0)
	move.b	#192,$fffffa1f.w
	move.b	#$5,$fffffa19.w
	bset	#$5,$fffffa07.w
	bset	#$5,$fffffa13.w
	ENDC
	
	lea.l	VOICE1(pc),a6
	bsr	MAIN_SYNTH
	lea.l	VOICE2(pc),a6
	bsr	MAIN_SYNTH
	lea.l	VOICE3(pc),a6
	bsr	MAIN_SYNTH
 IFNE	noiseseq
	bsr	DO_NOISE
 ENDC
	bsr	FORM_OUTPUT
NO_PLAY
	rts

 IFNE	quickmake
SUPEROUTPUT
	lea.l	GLOBALS(pc),a0
	tst.w	__tunexists(a0)
	beq.s	NO_SUPERPLAY
	bsr	DO_OUTPUT		Working
	IFNE	hertz200
	move.b	#$0,$fffffa19.w
	lea.l	SYNTH200(pc),a0
	move.l	a0,$134.w
	lea.l	GLOBALS(pc),a0
	move.w	#2,__200count(a0)
	move.b	#192,$fffffa1f.w
	move.b	#$5,$fffffa19.w
	bset	#$5,$fffffa07.w
	bset	#$5,$fffffa13.w
	ENDC
	
	lea.l	VOICE1(pc),a6
	bsr	MAIN_SYNTH
	lea.l	VOICE2(pc),a6
	bsr	MAIN_SYNTH
	lea.l	VOICE3(pc),a6
	bsr	MAIN_SYNTH
 IFNE	noiseseq
	bsr	DO_NOISE
 ENDC
	bsr	FORM_OUTPUT
NO_SUPERPLAY
	rts
 ENDC
*************
	IFNE	hertz200
SYNTH200
	IFNE	debug
	eori.w	#$700,$ffff8240.w
	ENDC
	movem.l	d0-d7/a0-a6,-(a7)
	lea.l	GLOBALS(pc),a0
	tst.w	__200count(a0)
	bhi.s	YES_200
	move.b	#$0,$fffffa19.w
	bra.s	NO_200
YES_200
	subq.w	#1,__200count(a0)
	bsr.s	DO_OUTPUT
	lea.l	VOICE1(pc),a6
	bsr	SYNTH
	lea.l	VOICE2(pc),a6
	bsr	SYNTH
	lea.l	VOICE3(pc),a6
	bsr	SYNTH
	bsr	FORM_OUTPUT
NO_200
	movem.l	(a7)+,d0-d7/a0-a6
	IFNE	debug
	eori.w	#$700,$ffff8240.w
	ENDC
	bclr.b	#5,$fffffa0f.w
	rte
	ENDC
*************
DO_OUTPUT
*	move.w	#$2700,sr
	lea.l	OUTPUT(pc),a0
	lea.l	$ffff8800.w,a1
	lea.l	$ffff8802.w,a2
	lea.l	GLOBALS(pc),a3
	
	move.b	#$7,(a1)
	move.b	(a2),d1
	move.b	_o_control(a0),d2
	and.w	#%111111,d2
	and.w	#%11000000,d1
	or.b	d1,d2
	move.b	d2,_o_control(a0)
	
OUTPUT
	move.l	#$00000000,(a1)
	move.l	#$01000000,(a1)
	move.l	#$02000000,(a1)
	move.l	#$03000000,(a1)
	move.l	#$04000000,(a1)
	move.l	#$05000000,(a1)
	move.l	#$06000000,(a1)
	move.l	#$07000000,(a1)
	move.l	#$08000000,(a1)
	move.l	#$09000000,(a1)
	move.l	#$0a000000,(a1)
	move.l	#$0b000000,(a1)
	move.l	#$0c000000,(a1)
	move.l	#$0d000000,d0
	
	tst.w	__changedwave(a3)
	beq.s	OUT_SAMEWAVE
	move.l	d0,(a1)
	clr.w	__changedwave(a3)
OUT_SAMEWAVE
*	move.w	#$2300,sr
	rts
 IFNE	quickmake
DO_SUPEROUTPUT
*	move.w	#$2700,sr
	lea.l	OUTPUT(pc),a0
	lea.l	ALTERNATIVE_OUTPUT(pc),a1
	lea.l	GLOBALS(pc),a3

	move.b	2(a0),(a1)
	move.b	(4*1)+2(a0),1(a1)
	move.b	(4*2)+2(a0),2(a1)
	move.b	(4*3)+2(a0),3(a1)
	move.b	(4*4)+2(a0),4(a1)
	move.b	(4*5)+2(a0),5(a1)
	move.b	(4*6)+2(a0),6(a1)
	move.b	(4*7)+2(a0),7(a1)
	move.b	(4*8)+2(a0),8(a1)
	move.b	(4*9)+2(a0),9(a1)
	move.b	(4*10)+2(a0),10(a1)
	move.b	(4*11)+2(a0),11(a1)
	move.b	(4*12)+2(a0),12(a1)
	move.b	(4*13)+2(a0),13(a1)

*	move.w	#$2300,sr
	rts
 ENDC
*************
* The main synth bit
*************
MAIN_SYNTH
	tst.w	_restcount(a6)	Rest going on?
	ble.s	NOREST		No...
	subq.w	#1,_restcount(a6)	Yes... decrement
	clr.w	_workvol(a6)	Clear volume
	rts
NOREST
	tst.w	_notecount(a6)	Is there a note on?
	ble.s	NONOTE		No...
	subq.w	#1,_notecount(a6)	Yes, decrement
	bra	SYNTH		Synth process
NONOTE
	move.w	_noteoff(a6),d2	Get note offset
	addq.w	#2,d2		Increment
	move.w	d2,_noteoff(a6)	Save
	move.l	_notebase(a6),a0	Get notebase address
	moveq	#0,d0		Clear
	moveq	#0,d1
	move.b	1(a0,d2.w),d1	Get note data
	move.b	0(a0,d2.w),d0
	bne.s	IS_A_NOTE		Not zero... (end of note)
TOTAL_RESET
	move.w	#-2,_noteoff(a6)	Reset note offset
	tst.w	_arangecount(a6)	End of arrangements loops?
	ble.s	END_AREPS		If 0 loop
	subq.w	#1,_arangecount(a6)	Decremement
	bra.s	NONOTE		Continue this bar again
END_AREPS
	move.w	_arangoff(a6),d0	Get arrangeoffset
	addq.w	#4,d0		Increment
	move.w	d0,_arangoff(a6)	Save it
	move.l	_arangbase(a6),a0	Get arrangements base
	move.l	0(a0,d0.w),d0	Get arrangment
	bne.s	NOT_END_ARRANGE	Not zero... (end of arrange list)
	move.w	#-4,_arangoff(a6)	Reset arrangement offset
	bra.s	TOTAL_RESET
NOT_END_ARRANGE
	move.w	d0,_arangecount(a6)	Save counter
	swap	d0		Get top word
	lea.l	NOTE_BASE(pc),a0	Note base address
	adda.w	d0,a0		Make offset an address
	move.l	a0,_notebase(a6)	Save it
	bra.s	NONOTE
IS_A_NOTE
	cmpi.w	#96,d0		A note?
	ble	REAL_NOTE
	cmpi.w	#$e0,d0		A port?
	ble	PORT_NOTE
***************
* A command!
**************
	and.w	#$f,d0
	add.w	d0,d0
	add.w	d0,d0
	lea.l	COMMAND_JUMPTABLE(pc),a0
	jmp	0(a0,d0.w)
COMMAND_JUMPTABLE
	bra	CONTINUE_NOTE	$f0
	bra	REST		$f1
	bra	SET_VOLUME	$f2
	bra	SET_INSTRUMENT	$f3
	bra	SET_NOISE		$f4
	bra	SET_NOISESTATUS	$f5
	bra	SET_CHORD1	$f6
	bra	SET_CHORD2	$f7
	bra	SET_CHORD3	$f8
	bra	SET_WAVEFORM	$f9
	bra	SET_WAVENOTE	$fa
	bra	SET_PORTSPEED	$fb	
	bra	SET_WAVEPERIOD	$fc
	bra	SET_QUICKCHORD	$fd
	bra	SET_FREQTRANS	$fe
	bra	SET_NOTETRANS	$ff
CONTINUE_NOTE
	subq.w	#1,d1		Sub 1 cos we're already doing one
	move.w	d1,_notecount(a6)	Save length
	clr.w	_porting(a6)
	rts
REST
	subq.w	#1,d1		Sub 1 cos we're already doing one
	move.w	d1,_restcount(a6)	Save rest
	rts
SET_VOLUME
	move.w	d1,_startvol(a6)	Save start volume
	bra	NONOTE		Get next note
SET_INSTRUMENT
	add.w	d1,d1		Word access
	lea.l	SYNTH_OFFS(pc),a0	Get base of instrument list
	move.w	(a0,d1.w),d0	Get offset
	lea.l	INS_BASE(pc),a0	Get base of synth block
	adda.w	d0,a0		Make an address
	move.l	a0,_synthbase(a6)	Save
	move.w	#-6,_synthoff(a6)	Reset synth counter
	bra	NONOTE
SET_NOISE
	move.w	d1,_startnoise(a6)	Save noise
	bra	NONOTE
SET_NOISESTATUS
	move.w	d1,_allownoise(a6)	Save allow status
	bra	NONOTE
SET_CHORD1
	ext.w	d1		Extend
	move.w	d1,_chord1off(a6)	Save it
	bra	NONOTE
SET_CHORD2
	ext.w	d1		Extend
	move.w	d1,_chord2off(a6)	Save it
	bra	NONOTE
SET_CHORD3
	ext.w	d1		Extend
	move.w	d1,_chord3off(a6)	Save it
	bra	NONOTE
SET_WAVEFORM
	move.w	d1,_setwaves(a6)	Save waveform and also flagged!
	bne.s	NO_WAVE_OFF
	moveq	#0,d0
	move.l	d0,_wavenote(a6)
	move.l	d0,_waveperiod(a6)
	move.w	d0,_udfperiod(a6)
	lea.l	GLOBALS(pc),a0
	move.b	#0,_o_waveformdef(a6)
NO_WAVE_OFF
	lea.l	GLOBALS(pc),a0
	addq.w	#1,__changedwave(a0)	Update wave change
	bra	NONOTE
SET_WAVENOTE
	move.w	d1,_wavenote(a6)
	lea.l	GLOBALS(pc),a0
*	addq.w	#1,__changedwave(a0)	Update wave change
	bra	NONOTE
SET_PORTSPEED
	ext.w	d1
	move.w	d1,_portspeed(a6)
	bra	NONOTE
SET_WAVEPERIOD
	move.w	d1,_udfperiod(a6)
	bra	NONOTE
SET_QUICKCHORD
	lsl.w	#3,d1
	lea.l	QUICK_CHORDS(pc),a0
	movem.w	(a0,d1.w),d2-d4
	movem.w	d2-d4,_chord1off(a6)
	bra	NONOTE
SET_FREQTRANS
	ext.w	d1
	move.w	d1,_freqtrans(a6)
	bra	NONOTE
SET_NOTETRANS
	ext.w	d1
	move.w	d1,_notetrans(a6)
	bra	NONOTE
*************
* If it is a note...
*************
REAL_NOTE
	move.w	#$0,_porting(a6)	Tranponse off
	clr.w	_portvalue(a6)
	clr.w	_portspeed(a6)
	clr.w	_portcount(a6)
	move.w	#-1,_miniloopcount(a6)
	move.w	#$0,_waveisused(a6)
	tst.w	_startnoise(a6)
	beq.s	NOT_RESETNOISE
	move.w	_startnoise(a6),d2
	subq.w	#1,d2
	move.w	d2,_worknoise(a6)
NOT_RESETNOISE
	move.w	_startvol(a6),_workvol(a6)	Reset volume
	move.w	#-6,_synthoff(a6)	Reset synth block offset
	move.w	d1,_notecount(a6)	Save note length
	move.w	d0,_lastnote(a6)	Save last note
	move.w	_notetrans(a6),d1
	add.w	d1,d0
	subq.w	#1,d0		Sub 1 for proper offsets
	move.w	d0,d5		Duplicate for the three chords	
	move.w	d0,d6
	move.w	d0,d7
	movem.w	_chord1off(a6),d2-d4 Get chording offsets
	add.w	d2,d5		Add offsets
	add.w	d3,d6
	add.w	d4,d7
	add.w	d0,d0		Word access
	add.w	d5,d5
	add.w	d6,d6
	add.w	d7,d7
	lea.l	FREQUENCY_TABLE(pc),a0
	move.w	(a0,d0.w),d0	So we have the frequencies
	move.w	(a0,d5.w),d5
	move.w	(a0,d6.w),d6
	move.w	(a0,d7.w),d7
	move.w	_freqtrans(a6),d1	And the transponse
	add.w	d1,d0
	movem.w	d0/d5-d7,_workfreq(a6)
	tst.w	_setwaves(a6)
	beq.s	WAVEEXIT
	tst.w	_udfperiod(a6)
	ble.s	NOUDFWAVE
	move.w	_udfperiod(a6),d0
	subq.w	#1,d0
	move.w	d0,_waveperiod(a6)
	bra.s	WAVEEXIT
NOUDFWAVE
	move.w	_wavenote(a6),d0
	subq.w	#1,d0
	move.w	_notetrans(a6),d1
	add.w	d1,d0
	add.w	d0,d0
	lea.l	WAVE_TABLE(pc),a0
	move.w	(a0,d0.w),_waveperiod(a6)
WAVEEXIT
	subq.w	#1,_notecount(a6)
	bra	SYNTH
*************
* Portanote for later
*************
PORT_NOTE
	move.w	#$1,_porting(a6)	We are porting
	move.w	d1,_notecount(a6)	Save length
	IFNE	hertz200
	lsl.w	#2,d1		By four for 200 hertz port
	ENDC
	sub.w	_portspeed(a6),d1	Correct for speed
	move.w	_lastnote(a6),d7	Get last note
	sub.w	#$80,d0		Make this one true
	move.w	d0,_lastnote(a6)	Save this one
	move.w	d0,d6		Dup note
	move.w	d7,d2		Get subber
	sub.w	d2,d0
	move.w	d0,d5
	move.w	d6,d0
	subq.w	#1,d0
	subq.w	#1,d2
	add.w	d0,d0
	add.w	d2,d2
	lea.l	FREQUENCY_TABLE(pc),a0
	moveq	#0,d3
	moveq	#0,d4
	move.w	(a0,d0.w),d3
	move.w	(a0,d2.w),d4
	sub.w	d4,d3
	bgt.s	NOTMAKEPOS
	neg.w	d3
NOTMAKEPOS
	divu	d1,d3
	ble.s	SLOW_PORT
	tst.w	d5
	ble.s	PORTUP
	neg.w	d3
PORTUP
	move.w	d3,_portvalue(a6)
	clr.w	_portcount(a6)
	move.w	_notecount(a6),d1
	bra.s	AFTER_PORT
SLOW_PORT
	swap	d3
	move.w	_notecount(a6),d1
	divu	d3,d1
	tst.w	d5
	ble.s	SPORTUP
	move.w	#-1,_portvalue(a6)
	bra.s	NPORTUD
SPORTUP
	move.w	#1,_portvalue(a6)
NPORTUD
	IFNE	hertz200
	lsl.w	#2,d1
	ENDC
	move.w	d1,_portcountstart(a6)
	move.w	_notecount(a6),d1
AFTER_PORT
	subq.w	#1,d1
	move.w	d1,_notecount(a6)
*************
* Synth processing
*************
SYNTH
	tst.w	_miniloopcount(a6)	Is there a minicount on?
	ble.s	NO_MINI		Nope
	subq.w	#1,_miniloopcount(a6)
	movem.w	_miniloop1(a6),d1-d4
	bra	IFAMINI
NO_MINI
	move.w	_synthoff(a6),d5	Synth offset
	addq.w	#6,d5		Increment
	move.w	d5,_synthoff(a6)	Save
	move.l	_synthbase(a6),a0	Synth base
	adda.w	d5,a0		As an offset address
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.b	5(a0),d0
	move.b	4(a0),d1
	move.b	3(a0),d2
	move.b	2(a0),d3
	move.w	(a0),d4
	cmpi.w	#$ff,d0
	bne.s	NOT_LOOP_BLOCK
	addq.w	#6,d1
	sub.w	d1,_synthoff(a6)
	bra.s	SYNTH
NOT_LOOP_BLOCK
	ext.w	d1
	ext.w	d2
	ext.w	d3
	
	move.w	d0,d5		Voice states
	and.w	#%11,d0
	move.w	d0,_voicestate(a6)
	
	lsr.w	#2,d5		Chording
	move.w	d5,d0
	and.w	#%11,d5
	move.w	d5,_freqinuse(a6)
	
	lsr.w	#2,d0		Waveform
	move.w	d0,d5
	and.w	#%11,d0
	move.w	d0,_waveisused(a6)
	
	lsr.w	#2,d5
	and.w	#%11,d5
	beq.s	IFAMINI
	move.w	d5,_miniloopcount(a6)
	movem.w	d1-d4,_miniloop1(a6)
IFAMINI	
	tst.w	d1
	beq.s	EXIT_VOL
	
	move.w	_workvol(a6),d5
	add.w	d1,d5
	bpl.s	VOL_NOTNEG
	moveq	#0,d5
	bra.s	VOL_NOTTOOHI
VOL_NOTNEG
	cmpi.w	#15,d5
	ble.s	VOL_NOTTOOHI
	moveq	#15,d5
VOL_NOTTOOHI
	move.w	d5,_workvol(a6)
EXIT_VOL

	tst.w	_startnoise(a6)
	beq.s	EXIT_NOISE
	tst.w	d2
	beq.s	HALF_EXITNOISE
	move.w	_worknoise(a6),d5
	add.w	d2,d5
	bpl.s	NOISE_NOTNEG
	moveq	#0,d5
	bra.s	NOISE_NOTTOOHI
NOISE_NOTNEG
	cmpi.w	#31,d5
	ble.s	NOISE_NOTTOOHI
	moveq	#31,d5
NOISE_NOTTOOHI
	move.w	d5,_worknoise(a6)
HALF_EXITNOISE
	lea.l	NOISE(pc),a1
	move.w	_worknoise(a6),_n_worknoise(a1)
EXIT_NOISE

	tst.w	d3
	beq.s	NO_WAVEFLUC
	move.w	_waveperiod(a6),d5
	add.w	d3,d5
	bpl.s	WAVE_NOTNEG
	moveq	#1,d5
	bra.s	EXIT_WAVE
WAVE_NOTNEG
	cmpi.w	#4096,d5
	ble.s	EXIT_WAVE
	move.w	#4096,d5
EXIT_WAVE
	move.w	d5,_waveperiod(a6)
NO_WAVEFLUC

	move.w	_workfreq(a6),d5
	tst.w	d4
	beq.s	NO_FREQ
	add.w	d4,d5
NO_FREQ
	tst.w	_porting(a6)
	ble.s	END_PORT
	tst.w	_portcount(a6)
	bhi.s	END_PORTCOUNTING
	move.w	_portcountstart(a6),_portcount(a6)
	move.w	_portvalue(a6),d0
	add.w	d0,d5
	bra.s	END_PORT
END_PORTCOUNTING
	subq.w	#1,_portcount(a6)
END_PORT
	tst.w	d5
	bpl.s	FREQ_NOTNEG
	moveq	#0,d5
FREQ_NOTNEG
	cmpi.w	#4095,d5
	ble.s	FREQ_NOTTOOHI
	move.w	#4095,d5
FREQ_NOTTOOHI
	move.w	d5,_workfreq(a6)
END_FREQ
	rts
*************
* Noise sequencer
*************
 IFNE	noiseseq
DO_NOISE
	lea.l	NOISE(pc),a6
	tst.w	_n_countdown(a6)
	ble.s	NO_NOISEREST
	subq.w	#1,_n_countdown(a6)
	clr.w	_n_noisestate(a6)
	rts
NO_NOISEREST
	move.w	_n_noteoff(a6),d2
	addq.w	#2,d2
	move.w	d2,_n_noteoff(a6)
	move.l	_n_notebase(a6),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	1(a0,d2.w),d1
	move.b	0(a0,d2.w),d0
	bne.s	IS_A_NOISE
TOTAL_RENOISE
	move.w	#-2,_n_noteoff(a6)
	tst.w	_n_arangecount(a6)
	ble.s	END_NREPS
	subq.w	#1,_n_arangecount(a6)
	bra.s	NO_NOISEREST
END_NREPS
	move.w	_n_arangeoff(a6),d0
	addq.w	#4,d0
	move.w	d0,_n_arangeoff(a6)
	move.l	_n_arangebase(a6),a0
	move.l	(a0,d0.w),d0
	bne.s	NOT_END_ANOISE
	move.w	#-4,_n_arangeoff(a6)
	bra.s	TOTAL_RENOISE
NOT_END_ANOISE
	move.w	d0,_n_arangecount(a6)
	swap	d0
	lea.l	NOTE_BASE(pc),a0
	adda.w	d0,a0
	move.l	a0,_n_notebase(a6)
	bra.s	NO_NOISEREST
IS_A_NOISE
	cmpi.b	#$ff,d0
	bne.s	NOT_NREST
	move.w	d1,_n_countdown(a6)
	clr.w	_n_noisestate(a6)
	bra.s	NOISE_EXIT
NOT_NREST
	move.w	d1,_n_countdown(a6)
	move.w	#1,_n_noisestate(a6)
	IFNE	debug
	eori.w	#$007,$ff8240
	ENDC
NOISE_EXIT
	rts
 ENDC
*************
* The bit that forms the output, called, rather predictably...
*************
FORM_OUTPUT
	lea.l	OUTPUT(pc),a0
	lea.l	NOISE(pc),a1
	lea.l	VOICE1(pc),a6
	lea.l	VOICE2(pc),a5
	lea.l	VOICE3(pc),a4
	
	move.b	1+_workvol(a6),_o_volumea(a0)
	move.b	1+_workvol(a5),_o_volumeb(a0)
	move.b	1+_workvol(a4),_o_volumec(a0)
	
	move.w	_freqinuse(a6),d0
	add.w	d0,d0
	move.b	_workfreq(a6,d0.w),_o_toneahi(a0)
	move.b	1+_workfreq(a6,d0.w),_o_tonealow(a0)

	move.w	_freqinuse(a5),d0
	add.w	d0,d0
	move.b	_workfreq(a5,d0.w),_o_tonebhi(a0)
	move.b	1+_workfreq(a5,d0.w),_o_toneblow(a0)

	move.w	_freqinuse(a4),d0
	add.w	d0,d0
	move.b	_workfreq(a4,d0.w),_o_tonechi(a0)
	move.b	1+_workfreq(a4,d0.w),_o_toneclow(a0)

	tst.w	_waveisused(a6)
	beq.s	FORM_NOWAVEA
	bset	#4,_o_volumea(a0)
	move.b	1+_setwaves(a6),_o_waveformdef(a0)
	move.b	_waveperiod(a6),_o_waveformhi(a0)
	move.b	1+_waveperiod(a6),_o_waveformlow(a0)
	bra.s	FORM_ENDWAVES
FORM_NOWAVEA
	tst.w	_waveisused(a5)
	beq.s	FORM_NOWAVEB
	bset	#4,_o_volumeb(a0)
	move.b	1+_setwaves(a5),_o_waveformdef(a0)
	move.b	_waveperiod(a5),_o_waveformhi(a0)
	move.b	1+_waveperiod(a5),_o_waveformlow(a0)
	bra.s	FORM_ENDWAVES
FORM_NOWAVEB
	tst.w	_waveisused(a4)
	beq.s	FORM_NOWAVEC
	bset	#4,_o_volumec(a0)
	move.b	1+_setwaves(a4),_o_waveformdef(a0)
	move.b	_waveperiod(a4),_o_waveformhi(a0)
	move.b	1+_waveperiod(a4),_o_waveformlow(a0)
FORM_NOWAVEC
FORM_ENDWAVES

	moveq	#%111111,d1
	
	move.w	_voicestate(a6),d0
	roxr.w	d0
	bcs.s	FORM_A_TONEON
	roxr.w	d0
	bcs.s	FORM_A_NOISEON
	bra.s	FORM_A_ENDSTATS
FORM_A_TONEON
	bclr	#0,d1
	roxr.w	d0
	bcc.s	FORM_A_ENDSTATS
FORM_A_NOISEON
	bclr	#3,d1
FORM_A_ENDSTATS

	move.w	_voicestate(a5),d0
	roxr.w	d0
	bcs.s	FORM_B_TONEON
	roxr.w	d0
	bcs.s	FORM_B_NOISEON
	bra.s	FORM_B_ENDSTATS
FORM_B_TONEON
	bclr	#1,d1
	roxr.w	d0
	bcc.s	FORM_B_ENDSTATS
FORM_B_NOISEON
	bclr	#4,d1
FORM_B_ENDSTATS
	
	move.w	_voicestate(a4),d0
	roxr.w	d0
	bcs.s	FORM_C_TONEON
	roxr.w	d0
	bcs.s	FORM_C_NOISEON
	bra.s	FORM_C_ENDSTATS
FORM_C_TONEON
	bclr	#2,d1
	roxr.w	d0
	bcc.s	FORM_C_ENDSTATS
FORM_C_NOISEON
	bclr	#5,d1
FORM_C_ENDSTATS

 IFNE	noiseseq
	tst.w	_n_noisestate(a1)
	beq.s	FORM_NONOISES

	tst.w	_allownoise(a6)
	beq.s	NO_NOISE4A
	bclr	#3,d1
NO_NOISE4A
	tst.w	_allownoise(a5)
	beq.s	NO_NOISE4B
	bclr	#4,d1
NO_NOISE4B
	tst.w	_allownoise(a4)
	beq.s	NO_NOISE4C
	bclr	#5,d1
NO_NOISE4C
FORM_NONOISES
 ENDC
	move.b	1+_n_worknoise(a1),_o_noisefreq(a0)
	move.b	d1,_o_control(a0)
	rts
*********************
*  The note-lookup table
* In the form Octave NN - C,C#,D,D#,E#,F,F#,G,G#,A,A#,B
***************
FREQUENCY_TABLE
* Octave -3
	dc.b	015,209,014,238,014,023,013,077,012,142,011,217
	dc.b	011,047,010,142,009,247,009,103,008,224,008,097
* Octave -2
	dc.b	007,232,007,119,007,011,006,166,006,071,005,236
	dc.b	005,151,005,071,004,251,004,179,004,112,004,048
* Octave -1
	dc.b	003,244,003,187,003,133,003,083,003,035,002,246
	dc.b	002,203,002,163,002,125,002,089,002,056,002,024
* Octave 0
	dc.b	001,250,001,221,001,194,001,169,001,145,001,123
	dc.b	001,101,001,081,001,062,001,044,001,028,001,012
* Octave 1
	dc.b	000,253,000,238,000,225,000,212,000,200,000,189
	dc.b	000,178,000,168,000,159,000,150,000,142,000,134
* Octave 2
	dc.b	000,126,000,119,000,112,000,106,000,100,000,094
	dc.b	000,089,000,084,000,079,000,075,000,071,000,067
* Octave 3
	dc.b	000,063,000,059,000,056,000,053,000,050,000,047
	dc.b	000,044,000,042,000,039,000,037,000,035,000,033
* Octave 4
	dc.b	000,031,000,029,000,028,000,026,000,025,000,023
	dc.b	000,022,000,021,000,019,000,018,000,017,000,016
*
	dc.b	0,15
	EVEN
WAVE_TABLE
*
	dc.b	000,253,000,239,000,225,000,213,000,201,000,189
	dc.b	000,179,000,169,000,159,000,150,000,142,000,134
	
	dc.b	000,126,000,119,000,114,000,107,000,100,000,095
	dc.b	000,089,000,084,000,079,000,075,000,071,000,067
	
	dc.b	000,063,000,060,000,057,000,054,000,050,000,047
	dc.b	000,044,000,042,000,040,000,037,000,036,000,034
	
	dc.b	000,032,000,030,000,028,000,027,000,025,000,024
	dc.b	000,022,000,021,000,020,000,019,000,018,000,017

	dc.b	000,016,000,015,000,014,000,013,000,012,000,012
	dc.b	000,011,000,010,000,010,000,009,000,009,000,008
	EVEN
*************
* Variables
*************
GLOBALS
	ds.l	1
	ds.w	1
	ds.w	1
	ds.w	1
VOICE1
	ds.w	90
VOICE2
	ds.w	90
VOICE3
	ds.w	90 
NOISE
 IFNE	noiseseq
	ds.w	20
 ENDC
**************************************************
* Setups, Tune Data, Noise Data and Synth Block Data
**********
SETUPS
	dc.w	ARRANG_A1-ARRANG_BASE
	dc.w	ARRANG_B1-ARRANG_BASE
	dc.w	ARRANG_C1-ARRANG_BASE
	dc.w	ARRANG_N1-ARRANG_BASE
**************
* Quick chording tables
************
QUICK_CHORDS
	dc.w	0,0,0,0
	dc.w	12,24,36,0
**************
* Synth block offset table
**********
SYNTH_OFFS
	dc.w	INS_0-INS_BASE		; 0
	dc.w	newbassdrum-INS_BASE	; 1
	dc.w	snare-INS_BASE		; 2
	dc.w	hihat-INS_BASE		; 3
	dc.w	boinf2-INS_BASE		; 4
	dc.w	chacha-INS_BASE		; 5
	dc.w	touch-INS_BASE		; 6
	dc.w	nicespling-INS_BASE		; 7
	dc.w	zaazaa-INS_BASE		; 8
	dc.w	flick-INS_BASE		; 9
	dc.w	flickdecay-INS_BASE		; 10
	dc.w	chord-INS_BASE		; 11
	dc.w	basstom-INS_BASE		; 12
	dc.w	basstom2-INS_BASE		; 13
	dc.w	snafuu-INS_BASE		; 14
	dc.w	snafuu2-INS_BASE		; 15
	dc.w	ticcyecho-INS_BASE		; 16
	dc.w	gentleattack-INS_BASE	; 17
	dc.w	gentledecay-INS_BASE	; 18
*************************
* Bar arrangements for voice A, B, C and Noise.
********
ARRANG_BASE
	dc.l	0
ARRANG_A1
*	dc.w	wait-NOTE_BASE,9999

	dc.w	ladeda-NOTE_BASE,6
	dc.w	drumit-NOTE_BASE,0
	dc.w	leaden-NOTE_BASE,0

	dc.w	port0-NOTE_BASE,0
	dc.w	leaden2-NOTE_BASE,0
	dc.w	port3-NOTE_BASE,0
	dc.w	leaden2-NOTE_BASE,0
	dc.w	port0-NOTE_BASE,0

	dc.w	wait-NOTE_BASE,31
	dc.w	thingy-NOTE_BASE,0
	dc.w	wait-NOTE_BASE,31
	dc.w	thingy-NOTE_BASE,0

	dc.w	drumbreak-NOTE_BASE,0

	dc.w	wait-NOTE_BASE,31
	dc.w	leadyweedy-NOTE_BASE,0


	dc.w	wait-NOTE_BASE,63+32
	dc.l	0
ARRANG_B1
*	dc.w	wait-NOTE_BASE,9999

	dc.w	zuzzingbass1-NOTE_BASE,7
	dc.w	port0-NOTE_BASE,0
	dc.w	bassingsound-NOTE_BASE,3
	dc.w	port_4-NOTE_BASE,0
	dc.w	bassingsoundhalf1-NOTE_BASE,0
	dc.w	port_2-NOTE_BASE,0
	dc.w	bassingsoundhalf2-NOTE_BASE,0
	dc.w	port0-NOTE_BASE,0
	dc.w	bassingsound2-NOTE_BASE,0
	dc.w	port_4-NOTE_BASE,0
	dc.w	bassingsoundhalf1-NOTE_BASE,0
	dc.w	port_2-NOTE_BASE,0
	dc.w	bassingsoundhalf2-NOTE_BASE,0
	dc.w	port0-NOTE_BASE,0
	dc.w	bassingsound2-NOTE_BASE,0
	dc.w	port0-NOTE_BASE,0
	dc.w	bassingsound-NOTE_BASE,2

	rept	4
	dc.w	port0-NOTE_BASE,0
	dc.w	bassingsound-NOTE_BASE,0
	dc.w	port_4-NOTE_BASE,0
	dc.w	bassingsoundhalf1-NOTE_BASE,0
	dc.w	port_2-NOTE_BASE,0
	dc.w	bassingsoundhalf2-NOTE_BASE,0
	dc.w	port0-NOTE_BASE,0
	dc.w	bassingsound2-NOTE_BASE,0
	dc.w	port_4-NOTE_BASE,0
	dc.w	bassingsoundhalf1-NOTE_BASE,0
	dc.w	port_2-NOTE_BASE,0
	dc.w	bassingsoundhalf2-NOTE_BASE,0
	endr

	rept	4
	dc.w	port3-NOTE_BASE,0
	dc.w	bassingsound-NOTE_BASE,0
	dc.w	port_4-NOTE_BASE,0
	dc.w	bassingsoundhalf1-NOTE_BASE,0
	dc.w	port_2-NOTE_BASE,0
	dc.w	bassingsoundhalf2-NOTE_BASE,0
	dc.w	port3-NOTE_BASE,0
	dc.w	bassingsound2-NOTE_BASE,0
	dc.w	port_4-NOTE_BASE,0
	dc.w	bassingsoundhalf1-NOTE_BASE,0
	dc.w	port_2-NOTE_BASE,0
	dc.w	bassingsoundhalf2-NOTE_BASE,0
	endr

	dc.w	port0-NOTE_BASE,0
	dc.w	paddly2-NOTE_BASE,1
	dc.w	upabit-NOTE_BASE,0
	dc.w	thingy-NOTE_BASE,0
	dc.w	norm-NOTE_BASE,0
	dc.w	port0-NOTE_BASE,0
	dc.w	paddly2-NOTE_BASE,1
	dc.w	upabit-NOTE_BASE,0
	dc.w	thingy-NOTE_BASE,0
	dc.w	norm-NOTE_BASE,0

	dc.w	port0-NOTE_BASE,0
	dc.w	bassingsound2-NOTE_BASE,33

*	dc.w	wait-NOTE_BASE,9999
	dc.l	0
ARRANG_C1
*	dc.w	wait-NOTE_BASE,9999

	dc.w	generalintro-NOTE_BASE,0
	dc.w	generalintro2-NOTE_BASE,0
	dc.w	ticcy2-NOTE_BASE,1

	dc.w	ticcy3-NOTE_BASE,7
	dc.w	ticcy4-NOTE_BASE,7
	dc.w	ticcy3-NOTE_BASE,3

	dc.w	ticcy2-NOTE_BASE,3
	dc.w	ticcy5-NOTE_BASE,9

	dc.w	ticcy2-NOTE_BASE,7
*	dc.w	ticcy5-NOTE_BASE,7
*	dc.w	ticcy6-NOTE_BASE,6

*	dc.w	wait-NOTE_BASE,9999
	dc.l	0
ARRANG_N1
 IFNE	noiseseq
	dc.w	nwait-NOTE_BASE,32127
	dc.l	0
 ENDC
***********************
* Voice note data.
*********
NOTE_BASE
	dc.l	0
upabit
 dc.b $fe,1
 dc.w	0
norm
 dc.b $fe,0
 dc.w	0
vol15
 dc.b $f2,15
 dc.w	0
vol14
 dc.b $f2,14
 dc.w	0
vol13
 dc.b $f2,13
 dc.w	0
vol12
 dc.b $f2,12
 dc.w	0
vol11
 dc.b $f2,11
 dc.w	0
vol10
 dc.b $f2,10
 dc.w	0
vol9
 dc.b $f2,9
 dc.w	0
vol8
 dc.b $f2,8
 dc.w	0
vol7
 dc.b $f2,7
 dc.w	0
port_12
 dc.b $ff,-12
 dc.w	0
port_9
 dc.b $ff,-9
 dc.w	0
port_8
 dc.b $ff,-8
 dc.w	0
port_7
 dc.b $ff,-7
 dc.w	0
port_6
 dc.b $ff,-6
 dc.w	0
port_5
 dc.b $ff,-5
 dc.w	0
port_4
 dc.b $ff,-4
 dc.w	0
port_3
 dc.b $ff,-3
 dc.w	0
port_2
 dc.b $ff,-2
 dc.w	0
port_1
 dc.b $ff,-1
 dc.w	0
port0
 dc.b $ff,0
 dc.w	0
port1
 dc.b $ff,1
 dc.w	0
port2
 dc.b $ff,2
 dc.w	0
port3
 dc.b $ff,3
 dc.w	0
port4
 dc.b $ff,4
 dc.w	0
port5
 dc.b $ff,5
 dc.w	0
port6
 dc.b $ff,6
 dc.w	0
port7
 dc.b $ff,7
 dc.w	0
port8
 dc.b $ff,8
 dc.w	0
port9
 dc.b $ff,9
 dc.w	0
port10
 dc.b $ff,10
 dc.w	0
port11
 dc.b $ff,11
 dc.w	0
port12
 dc.b $ff,12
 dc.w	0
port13
 dc.b $ff,13
 dc.w	0
port14
 dc.b $ff,14
 dc.w	0
port15
 dc.b $ff,15
 dc.w	0
alloff
 dc.b $f2,0,$f9,0
 dc.w	0
 dc.b $f3,1,$f4,12,20,6*3
 dc.b $f3,2,$f4,18,35,6
leadyweedy
 dc.b $f2,10,$f3,17,60,6*16,$f2,15,$f3,18,60,6*16
 dc.b $f2,10,$f3,17,58,6*16,$f2,15,$f3,18,58,6*16
 dc.b $f2,10,$f3,17,62,6*16,$f2,15,$f3,18,62,6*16
 dc.b $f2,10,$f3,17,60,6*16,$f2,15,$f3,18,60,6*16

 dc.b $f2,10,$f3,17,60,6*16,$f2,15,$f3,18,60,6*16
 dc.b $f2,10,$f3,17,58,6*16,$f2,15,$f3,18,58,6*16
 dc.b $f2,10,$f3,17,62,6*16,$f2,10,$f3,17,58,6*16
 dc.b $f2,10,$f3,17,65-36,6*16,$f2,15,$f3,18,65-36,6*16
 dc.b $f2,10,$f3,17,65-36,6*16,$f2,15,$f3,18,65-36,6*16
 dc.w	0
drumit
 dc.b $f2,15
 dc.b $f1,6*4
 dc.b $f3,13,36,6,36,6*2,33,6,33,6*2,30,6,29,6*2,27,6,25,6*2
 dc.w	0

works
 dc.b $f3,11
 dc.b $f6,3,$f7,7
 dc.b 60,1,40+$80,6*8
 dc.w	0
thingy
 dc.b $f2,14,$f3,11
 dc.b $f6,3,$f7,7
 dc.b 41,6*32
 dc.w	0

generalintro
 dc.b $f2,15,$f3,9
 dc.b 53,1,52+$80,11,73+$80,6*32,90+$80,6*30
 dc.b 53,1,52+$80,11,73+$80,6*32,90+$80,6*14
 dc.b $f2,14
 dc.b $f3,14,60,6*(8+4)
 dc.b $f2,14
 dc.b $f3,15,60,6*4
 dc.w	0
generalintro2
 dc.b $f2,13,$f3,9
 dc.b 53,1,52+$80,11,73+$80,6*32,90+$80,6*30
 dc.b 53,1,52+$80,11,73+$80,6*32,90+$80,6*14
 dc.w	0
accomp
 dc.b $f2,15,$f3,9
 dc.b 17,6,17,6,29,6,17,6*2,17,6,29,6*2
 dc.w	0
leaden
 dc.b $f2,15,$f3,9
 dc.b 53,1,52+$80,11,53+$80,12,53,6*12
 dc.b 53,1,52+$80,11,56+$80,12,56,6*12
 dc.b 56,1,52+$80,11,58+$80,12,58,6*12
 dc.b 58,1,52+$80,11,60+$80,12,60,6*12
 
 dc.b 65,6*2
 dc.b 53,6,53,6,51,6,53,6,51,6,56,6*2,53,6*2,51,6*2
 dc.b 48,6*2,46,6
 dc.b 48,6*4,36+$80,6*4
 dc.b $f3,13,36,6,36,6,33,6,33,6,30,6,29,6*2,27,6
 dc.b $f3,9
 dc.b 65,6*2
 dc.b 53,6,53,6,51,6,53,6,51,6,56,6*2,53,6*2,51,6*2
 dc.b 48,6*2,46,6
 dc.b 53,6*4
 dc.b $f2,15,53,1,40+$80,(6*4)-1
 dc.b $f2,14,53,1,40+$80,(6*4)-1
 dc.b $f2,13,53,1,40+$80,(6*4)-1
 dc.b $f2,12,53,1,40+$80,(6*4)-1
 dc.b $f2,11,53,1,40+$80,(6*4)-1
 dc.b $f2,10,53,1,40+$80,(6*4)-1
 dc.b $f2,9,53,1,40+$80,(6*4)-1
 dc.b $f2,8,53,1,40+$80,(6*4)-1
 dc.b $f2,7,53,1,40+$80,(6*4)-1
 dc.b $f2,6,53,1,40+$80,(6*4)-1
 dc.b $f2,5,53,1,40+$80,(6*4)-1
 dc.b $f2,4,53,1,40+$80,(6*4)-1
 dc.b $f2,3,53,1,40+$80,(6*4)-1
 dc.b $f2,2,53,1,40+$80,(6*4)-1
 dc.b $f2,1,53,1,40+$80,(6*4)-1
 dc.w	0
leaden2
 dc.b $f2,15,$f3,9
 dc.b 53,1,52+$80,11,53+$80,12,53,6*12
 dc.b 53,1,52+$80,11,56+$80,12,56,6*10
 dc.b 58,6*2,60,6*4,58,6*4,56,6*4,58,6*2
 dc.b $f3,10,53,6*8
 dc.b $f3,13,36,6,36,6,33,6,33,6,30,6,29,6*2,27,6,27,6,27,6
 dc.b $f2,15,$f3,9
 dc.b 53,1,52+$80,11,53+$80,12,53,6*12
 dc.b 53,1,52+$80,11,56+$80,12,56,6*10
 dc.b 58,6*2,60,6*4,61,6*4,60,6*4,58,6*2
 dc.b $f3,10,53,6*8
 dc.b $f3,13,36,6,36,6,33,6,33,6,30,6,29,6*2,27,6,27,6,27,6
 dc.b $f3,9
 dc.b 60,6*6,58,6*5,$f1,6*5
 dc.b 60,6*6,53,6*8
 dc.b 60,6*2,63,6*2,60,6*2,63,6*2,60,6*2,63,6*2,65,6*4,$f3,10,41,6*10
 rept	8
 dc.b $f3,13,27,6
 endr
 dc.b $f3,9
 dc.b 60,6*6,58,6*5,$f1,6*5
 dc.b 60,6*4,61,6*2,60,6*4,$f1,6*4
 dc.b 60,6*2,63,6*2,60,6*2,63,6*2,60,6*2,63,6*2,65,6*4
 dc.b 41+$80,6*18
 dc.w	0
drumbreak
 dc.b $f2,15,$f3,13
 dc.b 36,6,33,6*8,33,6,30,6,29,6*2,27,6,27,6,27,6
 dc.b 36,6,33,6,30,6
 dc.b 36,6,33,6,30,6
 dc.b 36,6,30,6
 dc.b $f2,15,36,6
 dc.b $f2,14,36,6
 dc.b $f2,13,36,6
 dc.b $f2,15,36,6
 dc.b $f2,14,36,6
 dc.b $f2,13,36,6
 dc.b $f2,15,46,6*2
 dc.b $f3,9
 dc.b 20,6*8
 dc.b 22,6*8
 dc.b 17,6*16

 dc.b $f3,13
 dc.b 36,6,33,6*8,33,6,30,6,29,6*2,27,6,27,6,27,6
 dc.b 36,6,36,6,36,6,36,6
 dc.b 33,6,33,6,33,6,33,6
 dc.b 30,6,30,6,30,6,30,6
 dc.b 29,6,29,6,29,6,29,6
 dc.b $f3,9
 dc.b 20,6*8
 dc.b 22,6*8
 dc.b 17,6*16
 dc.w	0
ticcy
 dc.b $f2,15,$f3,3,$f4,1
 dc.b 1,6
 dc.w	0
yeahticcy
 dc.b $f2,15
 dc.b $f3,1,$f4,12,22,6
 dc.b $f3,3,$f4,1,1,6,1,6,1,6
 dc.w	0
ticcy2
 dc.b $f2,15,$f4,1
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,3,$f4,1,1,6,1,6,1,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,3,$f4,1,1,6,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,3,$f4,1,1,6,1,6,1,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,3,$f4,1,1,6

 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,3,$f4,1,1,6,1,6,1,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,3,$f4,1,1,6,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,3,$f4,1,1,6
 dc.w	0
ticcy3
 dc.b $f2,15,$f4,1
 dc.b $f6,3,$f7,7,$f8,12
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,53-12,6
 dc.b $f3,7,53-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,53-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,53-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,7,53-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,53-12,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,53-12,6

 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,53-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,7,53-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,53-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,53-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,53-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,53-12,6
 dc.w	0
ticcy4
 dc.b $f2,15,$f4,1
 dc.b $f6,3,$f7,7,$f8,12
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,7,56-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,56-12,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6

 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,7,56-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.w	0
ticcy5
 dc.b $f2,15,$f3,16
 dc.b 60,6*3,58,6*3
 dc.b 60,6*2,61,6*2
 dc.b 58,6*2,60,6*4
 dc.w	0
ticcy6
 dc.b $f2,15,$f4,1
 dc.b $f6,3,$f7,7,$f8,12
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,7,56-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,56-12,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6

 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,7,56-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,7,56-12,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.b $f3,2,$f4,18,35,6
 dc.b $f3,3,$f4,1,1,6
 dc.b $f3,1,$f4,12,20,6
 dc.b $f3,7,56-12,6
 dc.w	0
bassingsound
 dc.b $f2,15,$f3,4
 dc.b 17,6*2,17,6*2,17+12,6,17,6*2
 dc.b 17,6,17+12,6*2,17,6*2,17,6*2,17+12,6,17,6
 dc.w	0
bassingsoundhalf1
 dc.b $f2,15,$f3,4
 dc.b 17,6*2,17,6*2,17+12,6,17,6*2
 dc.w	0
bassingsoundhalf2
 dc.b $f2,15,$f3,4
 dc.b 17,6,17+12,6*2,17,6*2,17,6*2,17+12,6,17,6
 dc.w	0
bassingsound2
 dc.b $f2,15
 dc.b $f3,4,17,6
 dc.b $f3,4,17+12,6
 dc.b $f3,8,$f9,%1110,$fc,11,17,6
 dc.b $f3,4,17,6
 dc.b $f3,4,17+12,6
 dc.b $f3,8,$f9,%1110,$fc,11,17,6
 dc.b $f3,4,17,6
 dc.b $f3,8,$f9,%1110,$fc,11,17,6
 dc.b $f3,4,17,6
 dc.b $f3,8,$f9,%1110,$fc,11,17+12,6
 dc.b $f3,4,17+12,6
 dc.b $f3,8,$f9,%1110,$fc,11,17+12,6
 dc.b $f3,4,17,6
 dc.b $f3,8,$f9,%1110,$fc,11,17,6
 dc.b $f3,4,17+12,6
 dc.b $f3,8,$f9,%1110,$fc,11,17,6
 dc.b $f9,0
 dc.w	0
zuzzingbass1
 dc.b $f2,0,$f3,8,$f9,%1110,$fc,11
 dc.b 17,6,17,6,17,6,17,6,17,6,17,6*2,17,6*2,17,6*2,17,6,17,6,17,6
 dc.b 17,6,17,6
 dc.w	0
zuzzingbass2
 dc.b $f3,8,$f9,%1110,$fc,12
 dc.b 15,6,15,6,15,6,15,6,15,6,15,6*2,15,6*2,15,6*2,15,6,15,6,15,6
 dc.b 15,6,15,6
 dc.w	0
paddly2
 dc.b $f3,6,$f9,%1100
 dc.b $fc,1
 dc.b 65,6,76,6,68,6,65,6,69,6,70,6,71,6,72,6
 dc.b 65,6,76,6,65,6,68,6,65,6,67,6,63,6,64,6
 dc.w	0
paddly
 dc.b $f3,6,$f9,%1100
 dc.b $fc,1
 dc.b 65,6*3,65,6*4,65,6,65,6*2,65,6*2,65,6*4
 dc.w	0
padding
 dc.b $f3,6,$f9,%1100
 dc.b $fc,6
 rept 2
 dc.b 65,6,76,6,68,6,65,6,69,6,70,6,71,6,72,6
 dc.b 65,6,76,6,68,6,65,6,61,6,67,6,62,6,64,6
 endr
 dc.b $fc,5
 rept 2
 dc.b 65,6,76,6,68,6,65,6,69,6,70,6,71,6,72,6
 dc.b 65,6,76,6,68,6,65,6,61,6,67,6,62,6,64,6
 endr
 dc.b $fc,4
 rept 2
 dc.b 65,6,76,6,68,6,65,6,69,6,70,6,71,6,72,6
 dc.b 65,6,76,6,68,6,65,6,61,6,67,6,62,6,64,6
 endr
 dc.b $fc,3
 rept 2
 dc.b 65,6,76,6,68,6,65,6,69,6,70,6,71,6,72,6
 dc.b 65,6,76,6,68,6,65,6,61,6,67,6,62,6,64,6
 endr
 dc.b $fc,1
 rept 2
 dc.b 65,6,76,6,68,6,65,6,69,6,70,6,71,6,72,6
 dc.b 65,6,76,6,68,6,65,6,61,6,67,6,62,6,64,6
 endr
 dc.w	0 
ladeda
 dc.b $f2,15,$f3,4
 dc.b 17,6*2,17,6*2,17,6*2,17,6,17,6*2,17,6*2,17,6*2,17,6,17,6*2
 dc.w	0
lead1
 dc.b $f2,9,$f3,9
* dc.b 56,6*16,55,6*8,53,6*8,58,6*28,60,6*2,58,6*2,51,6*16
* dc.b 56,6*8,55,6*8,49,6*32
* dc.b 56,6*16,55,6*8,53,6*8,58-12,6*28,60-12,6*2,58-12,6*2,51,6*16
* dc.b 56,6*8,58,6*8,49,6*16,(56-12)+$80,6*16
 
 dc.b 53-24,6*32,50-24,6*32
 dc.w	0
bassintro
 dc.b $f2,15,$f3,8
 dc.b 17,6*4,12,6*2,17,6*2,8,6*2,10,6*4,12,6*2
 dc.b 17,6*4,12,6*2,17,6*2,8,6*2,1+12,6*2,12,6*2,3+12,6*2
 dc.b 17,6*4,12,6*2,17,6*2,8,6*2,10,6*4,12,6*2
 dc.b 17,6*4,12,6*2,17,6*2,8,6*2,3+12,6*2,12,6*2,10,6*2
 dc.w	0
wait
 dc.b $f1,6
 dc.w	0
*
 IFNE	noiseseq
nwait
 dc.b $ff,5
 dc.w	0
nplay
 dc.b 3,5,3,5,3,5,3,5
 dc.b 3,5,3,5,3,5,3,5
 dc.w	0
 ENDC
	EVEN
****************
* Synth block data
****************
INS_BASE
	dc.l	0
INS_0
 dc.w	000
 dc.b	000,000,000,%00000000
 dc.w	000
 dc.b	000,000,006,$ff
gentleattack
 dc.w	001
 dc.b	000,000,000,%10000001
 dc.w	-1
 dc.b	000,000,000,%10000001
 dc.w	-1
 dc.b	000,000,000,%10000001
 dc.w	001
 dc.b	000,000,000,%01000001
 dc.w	001
 dc.b	000,000,001,%00000001
 dc.w	000
 dc.b	000,000,6*5,$ff
gentledecay
 dc.w	001
 dc.b	000,000,000,%10000001
 dc.w	-1
 dc.b	000,000,000,%10000001
 dc.w	-1
 dc.b	000,000,000,%10000001
 dc.w	001
 dc.b	000,000,  0,%01000001
 dc.w	001
 dc.b	000,000, -1,%00000001
 dc.w	000
 dc.b	000,000,6*5,$ff
basstom2
 dc.w	0
 dc.b	00,00,00,%00000011
 dc.w	80
 dc.b	00,00,00,%00000001
 dc.w	50
 dc.b	00,00,00,%00000001
 dc.w	50
 dc.b	00,00,-1,%00000001
 dc.w	0
 dc.b	00,00,6*2,$ff
snafuu
 dc.w	02
 dc.b	00,00,000,%00000001
 dc.w	02
 dc.b	00,00,000,%00000101
 dc.w	0
 dc.b	00,00,6*2,$ff
snafuu2
 dc.w	02
 dc.b	00,00,000,%00000001
 dc.w	02
 dc.b	00,00,000,%00000101
 dc.w	02
 dc.b	00,00,000,%00000001
 dc.w	02
 dc.b	00,00, -1,%00000101
 dc.w	0
 dc.b	00,00,6*4,$ff

basstom
 dc.w	0
 dc.b	00,00,00,%00000011
 dc.w	80
 dc.b	00,00,00,%00000001
 dc.w	80
 dc.b	00,00,-1,%00000001
 dc.w	80
 dc.b	00,00,-1,%00000001
 dc.w	0
 dc.b	00,00,6*1,$ff

chord
 dc.w	000
 dc.b	000,000,000,%00000001
 dc.w	000
 dc.b	000,000,000,%00000101
 dc.w	000
 dc.b	000,000,000,%00000001
 dc.w	000
 dc.b	000,000,000,%00001001
 dc.w	000
 dc.b	000,000,6*4,$ff
newbassdrum
*$f2,14,$f3,1,$f4,12,22,6*32
 dc.w	000
 dc.b	000,000, -1,%00000011
 dc.w	-191
 dc.b	000,000,001,%00000001
 dc.w	+124
 dc.b	000,000,000,%00000001
 dc.w	+380
 dc.b	000,000,000,%00000001
 dc.w	+891
 dc.b	000,000,000,%00000001
 dc.w	-891
 dc.b	000,000,-15,%00000001
 dc.w	-313
 dc.b	000,000,013,%00000001
 dc.w	000
 dc.b	000,000,-15,%00000001
 dc.w	000
 dc.b	000,000,006,$ff
* $f4,18,35,6*2
snare
 dc.w	0
 dc.b	00,000,00,%00000011
 dc.w	100
 dc.b	00,-01,00,%00000001
 dc.w	100
 dc.b	00,-01,00,%01000001
 dc.w	100
 dc.b	00,-01,-1,%00000010
 dc.w	0
 dc.b	0,0,6*1,$ff
hihat 
 dc.w	0
 dc.b	000,000, -2,%00000010
 dc.w	0
 dc.b	000,000,-15,%00000010
 dc.w	0
 dc.b	0,0,6*1,$ff
nicespling
 dc.w	0
 dc.b	000,000, -1,%00000001
 dc.w	0
 dc.b	000,000, -1,%00000101
 dc.w	0
 dc.b	000,000, -1,%00001001
 dc.w	0
 dc.b	000,000, -1,%00001101
 dc.w	0
 dc.b	0,0,6*4,$ff
zaazaa
 dc.w	0
 dc.b	000,000,000,%00110001
 dc.w	0
 dc.b	000,000,000,%00000001
 dc.w	0
 dc.b	000,000,000,%11110001
 dc.w	0
 dc.b	0,0,6*1,$ff
flick
 dc.w	000
 dc.b	000,000,000,%00000001
 dc.w	000
 dc.b	000,000, -2,%00000001
 dc.w	001
 dc.b	000,000,000,%10000001
 dc.w	-1
 dc.b	000,000,000,%10000001
 dc.w	-1
 dc.b	000,000,000,%10000001
 dc.w	001
 dc.b	000,000,000,%10000001
 dc.w	0
 dc.b	0,0,6*4,$ff
flickdecay
 dc.w	000
 dc.b	000,000,000,%00000001
 dc.w	000
 dc.b	000,000, -2,%00000001
 dc.w	001
 dc.b	000,000,000,%10000001
 dc.w	-1
 dc.b	000,000,000,%10000001
 dc.w	-1
 dc.b	000,000,000,%10000001
 dc.w	001
 dc.b	000,000,000,%01000001
 dc.w	001
 dc.b	000,000, -1,%00000001
 dc.w	0
 dc.b	0,0,6*5,$ff
chacha
 dc.w	0
 dc.b	000,000,000,%00000011
 dc.w	0
 dc.b	000,000, -1,%11000001
 dc.w	0
 dc.b	000,000, -1,%00000001
 dc.w	0
 dc.b	000,000,  3,%00000011
 dc.w	0
 dc.b	000,000, -1,%11000001
 dc.w	0
 dc.b	000,000, -1,%00000001
 dc.w	0
 dc.b	000,000,  4,%00000001
 dc.w	0
 dc.b	000,000, -1,%11000001
 dc.w	0
 dc.b	000,000, -1,%00000001
 dc.w	0
 dc.b	0,0,6*1,$ff
boinf2
 dc.w	0
 dc.b	000,000, -1,%00000001
 dc.w	0
 dc.b	000,000,  1,%00000001
 dc.w	0
 dc.b	000,000, -1,%11000001
 dc.w	0
 dc.b	000,000,  2,%00000001
 dc.w	0
 dc.b	000,000,000,%00000001
 dc.w	0
 dc.b	000,000, -1,%00000001
 dc.w	0
 dc.b	0,0,6*2,$ff
ticcyecho
 dc.w	000
 dc.b	000,000,000,%00000001
 dc.w	000
 dc.b	000,000, -4,%00000001
 dc.w	000
 dc.b	000,000, -4,%00000001
 dc.w	000
 dc.b	000,000, -4,%00000001
 dc.w	000
 dc.b	000,000, 10,%00000001
 dc.w	000
 dc.b	000,000, -4,%00000001
 dc.w	000
 dc.b	000,000, -4,%00000001
 dc.w	000
 dc.b	000,000, -4,%00000001
 dc.w	000
 dc.b	000,000, 10,%00000001
 dc.w	000
 dc.b	000,000, -4,%00000001
 dc.w	000
 dc.b	000,000,006,$ff
touch
 dc.w	000
 dc.b	000,000,00,%00110001
 dc.w	000
 dc.b	000,000,-1,%01110001
 dc.w	000
 dc.b	000,000,-1,%00000001
 dc.w	000
 dc.b	000,000,6*1,$ff
 
 dc.b	"This is the end of the file, if you're ripping it... <CZI>"      
	EVEN
ALTERNATIVE_OUTPUT
