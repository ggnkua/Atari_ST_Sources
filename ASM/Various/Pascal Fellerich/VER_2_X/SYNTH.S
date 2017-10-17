*************************************************************************
*
*  SYNTH.S
*  -------
*
*  Amiga Soundchip Emulator for 68000...68040
*
*
*
*  last modified: 08-Dec-1992
*					2-nov-1995: channel swap.
*
*************************************************************************

				include "pdefs.inc"

VIRGIN			equ 24					;LEFT, rightV = 25
LASTFLAG		equ 26					;LEFT, rightL = 27


; -----------------------------------------------------------------------
; Globals:
; -----------------------------------------------------------------------
;
; exported Subroutines:
;
				xdef calc_voltab		;volume table (only ST!)
				xdef calc_freqtab		;Frequency conversion table
				xdef Paula				;Chip Emulation
				xdef SoftPaula			;MONO-Abklatsch...

;
; exported Variables:
;
				xdef AudioChannel1,AudioChannel2
				xdef AudioChannel3,AudioChannel4
				xdef AudioFreqTabP
				xdef AudioFrameSize
				xdef voltabP			;zeiger auf Volume Table
				xdef LeftBuffer, RightBuffer

;
; imported variables
;
				xref p_boost			;from player.s
				xref p_interpolate
				xref p_swapchannel

				xref has_68020			;from system.s

; -----------------------------------------------------------------------
; internal defines
; -----------------------------------------------------------------------
;
; STATES der Emulation:
;
;STOPPED 		equ -1	;(defined in PDEFS.INC)
;RELOAD			equ 0	;(defined in PDEFS.INC)
RUNNING 		equ 1

;
; Wertigkeit der Attribute:
; FastCalc: 		4
; Volumes:			2
; FirstTime:		1
;
FASTCALC		equ 4*4
VOLUMES 		equ 2*4
FIRSTTIME		equ 1*4

; Zugriffsdistanzen fÅr andere Vektoren:
NORMALMAP		equ 8*4 				;der achte vektor
BOOSTMAP		equ 9*4 				;der neunte Vektor



; -----------------------------------------------------------------------
; Code
; -----------------------------------------------------------------------
				text

;
; Berechnet Volume Tables fÅr ST betrieb...
; Param:  a0: ptr to voltab
calc_voltab:
		move.l	d3,-(sp)
		moveq	#0,d0					;start with volume 0
for0:	moveq	#0,d1					;y=0
		moveq	#0,d2					;for (x=0;
for1:	move.w	d1,d3					;			 y
		asr.w	#6,d3					;			   >>6;
		move.b	d3,0(a0,d2.w)			;voltab[x] =
		add.w	d0,d1					;y += volume;
		addq.w	#1,d2					;x++
		cmpi.w	#128,d2
		blt.s	for1
		moveq	#0,d1					;y=0
		move.w	#255,d2 				;x=255
for2:	sub.w	d0,d1					;y-=volume;
		move.w	d1,d3					;			 y
		asr.w	#6,d3					;			   >>6;
		move.b	d3,0(a0,d2.w)			;voltab[x] =
		subq.w	#1,d2					;x--
		cmpi.w	#128,d2
		bge.s	for2
		lea 	256(a0),a0				;next voltab
		addq.w	#1,d0					;volume++
		cmpi.w	#TOGGLEVOLUME,d0
		blt.s	for0
		move.l	(sp)+,d3
		rts

*
* Frequenz-tabelle berechnen:
*
* Parameter:	d0.l Amiga Chip Clock Freq.
*				d1.l Samplingfrequenz bei der Ausgabe
*
* Register: d0-d2/a0
*
*-------------------------------------------------------------------
* Formel fÅr die Werte:
*
*			AmigaChipClock * 65536
*  Seed =  ------------------------
*				 TTSampleFreq
*
* danach:
*
*  Freqtab[i] = Seed / i
*  (division 32/16=16 bit)
*
* Werte sind:
*
* AmigaTakt: NTSC 7159090 Hz, PAL 7093790 Hz
*  -> PAULA erhÑlt im Amiga den halben Systemtakt!
*
*
calc_freqtab:
		movem.l d3-d4,-(sp)
		andi.l	#$FFFF,d1
		beq.s	ftab_done
		move.l	d1,d2
		eor.l	d0,d2
		cmp.l	last_freqtabcheck(pc),d2
		beq.s	ftab_done
		move.l	d2,last_freqtabcheck

		asr.l	#1,d0					;Paula wird mif fcpu/2 getaktet
		divu	d1,d0
		move.w	d0,d2
		swap	d2						;d2.hi = hiword Seed
		clr.w	d0
		divu	d1,d0
		move.w	d0,d2					;d2.l -> Seed

		lea 	freqtab(pc),a0			;tabellenstart
		move.w	#FREQTABSIZE,d0 		;Anzahl der Werte
		moveq	#0,d1					;Divisor init

; DIVISION 32bit / 16bit -> 32bit
		tst.b	has_68020
		bne.s	tabloop3
		bra.s	tabloop1				;Rein ins GewÅhl
tabloop:addq.l	#1,d1					;nÑchster Divisor
		move.l	d2,d3
		clr.w	d3
		swap	d3						;get highword
		divu	d1,d3					;hiword/divisor
		move.w	d3,d4
		swap	d4						;Resultat ins Highword
		move.w	d2,d3
		divu	d1,d3					; Rest*65536+LoW(dividend)	/  divisor
		move.w	d3,d4					;Resultat komplett
		move.l	d4,(a0)+
tabloop1:
		dbra   d0,tabloop			   ;loop until...
		bra.s	ftab_done

			mc68030

tabloop2:
		addq.l #1,d1
		move.l	d2,d4
		divu.l	d1,d4					;dc.w $4C41,$4804
		move.l	d4,(a0)+
tabloop3:
		dbra   d0,tabloop2

			mc68000

ftab_done:
		movem.l (sp)+,d3-d4
		rts



; -----------------------------------------------------------------------
; -----------------------------------------------------------------------
; die Emulationsroutine FöR SOFTDMA!
;
; Param:	a0: Zeiger auf AudioFrame -> achtung, 16 bit worte!
; Return:	void
;
; Global:	- nur interne Vars werden beeinfluût -
;			ALLE REGISTER WERDEN ZERSTôRT AUSSER a6 & a7
;
; -----------------------------------------------------------------------
; -----------------------------------------------------------------------

SoftPaula:
		move.l	a0,AudioFrame			; Ziel!
		moveq	#0,d7					; Clear d7-flags
; Zuerst die Basis-Audiovektoren berechnen:
		lea 	Audio_TT_interpol(pc),a5
		moveq	#16,d0					; Resultat wird 16 bit sein
		tst.w	p_interpolate			; Interpolation erlaubt?
		bne.s	savector 				; yep!
		lea 	Audio_ST_normal(pc),a5
		moveq	#10,d0					; Resultat wird 10 bit sein
		tst.b	has_68020				; 'real' CPU?
		beq.s	savector 				; no.
		lea 	Audio_TT_normal(pc),a5	; use TT routines
		moveq	#16,d0					; Resultat wird doch 16 bit sein
savector:
		move.l	a5,AudioVectors
		move.w	d0,-(sp)

*** CHANNEL 1:
		move.w	AudioFrameSize(pc),d7	;		FRAME-LÑnge
		lea 	AudioChannel1(pc),a0	;		 Registersatz
		movea.l	AudioFrame(pc),a1
		bsr		sound_machine

*** CHANNEL 2:
		move.w	AudioFrameSize(pc),d7
		lea 	AudioChannel2(pc),a0
		movea.l	AudioFrame(pc),a1
		bsr		sound_machine

*** CHANNEL 3:
		move.w	AudioFrameSize(pc),d7
		lea 	AudioChannel3(pc),a0
		movea.l	AudioFrame(pc),a1
		bsr		sound_machine

*** CHANNEL 4:
		move.w	AudioFrameSize(pc),d7
		lea 	AudioChannel4(pc),a0
		movea.l	AudioFrame(pc),a1
		bset	#LASTFLAG,d7
		bsr		sound_machine

*** Fertig! Return <bitsize> in d0:
		move.w	(sp)+,d0
		rts

; -----------------------------------------------------------------------
; -----------------------------------------------------------------------
; die Emulationsroutine...
;
; Param:	a0: Zeiger auf AudioFrame
; Return:	void
;
; Global:	- nur interne Vars werden beeinfluût -
;			ALLE REGISTER WERDEN ZERSTôRT AUSSER a6 & a7
;
; -----------------------------------------------------------------------
; -----------------------------------------------------------------------

Paula:
		move.l	a0,AudioFrame			;Ziel!
		moveq	#0,d7					;Clear d7-flags
; Zuerst die Basis-Audiovektoren berechnen:
		lea 	Audio_TT_interpol(pc),a5
		tst.w	p_interpolate			;Interpolation erlaubt?
		bne.s	avector 				;yep!
		lea 	Audio_ST_normal(pc),a5
		tst.b	has_68020				;'real' CPU?
		beq.s	avector 				;no.
		lea 	Audio_TT_normal(pc),a5	;use TT routines
avector:move.l	a5,AudioVectors

*** CHANNEL 1, LEFT:
		move.w	AudioFrameSize(pc),d7	;FRAME-LÑnge
		lea 	AudioChannel1(pc),a0	;Registersatz
		lea 	LeftBuffer(pc),a1
		bsr.s	sound_machine

*** CHANNEL 2, RIGHT:
		lsr.l	#1,d7					;R-CH Flags aktivieren
		move.w	AudioFrameSize(pc),d7	;FRAME-LÑnge
		lea 	AudioChannel2(pc),a0
		lea 	RightBuffer(pc),a1
		bsr.s	sound_machine

*** CHANNEL 3, RIGHT:
		move.w	AudioFrameSize(pc),d7	;FRAME-LÑnge
		lea 	AudioChannel3(pc),a0
		lea 	RightBuffer(pc),a1
		bset	#LASTFLAG,d7
		bsr.s	sound_machine

*** CHANNEL 4, LEFT:
		lsl.l	#1,d7					;L-CH Flags holen
		move.w	AudioFrameSize(pc),d7	;FRAME-LÑnge
		lea 	AudioChannel4(pc),a0
		lea 	LeftBuffer(pc),a1
		bset	#LASTFLAG,d7
		bsr.s	sound_machine

*** ZUSAMMENFASSEN:
		lea 	LeftBuffer(pc),a1		;kanÑle NICHT umdrehen...
		lea 	RightBuffer(pc),a2		;Amiga: LRRL, nicht RLLR !!!!!!!
		tst.w	p_swapchannel
		beq.s	.noswap
		exg		a1,a2
.noswap:
		movea.l AudioFrame(pc),a3		;Zielpuffer
		movea.l AudioVectors(pc),a5
		lea 	NORMALMAP(a5),a5
		move.w	AudioFrameSize(pc),d7	;FRAME-LÑnge
		move.w	p_boost(pc),d0			;Booster eingeschaltet?
		beq.s	map_ok
		addq.l	#(BOOSTMAP-NORMALMAP),a5 ;JA-> anderer Vektor
map_ok: movea.l (a5),a5
		jmp 	(a5)


*-----------------------------------------------------------------------
* SOUNDMACHINE: zuerst die nîtigen Werte berechnen
*-----------------------------------------------------------------------
* Param:  d7.w: FrameLength in DataWords
*		  d7.l: highword: Flags!
*		  a0:	&AudioChannel[i]
*		  a1:	AudioTempBuffer
*
sound_machine:
		movea.l AudioVectors(pc),a5
		move.w	AUD_STATE(a0),d0		;		  Zustand des Kanals
		bmi 	sound_stopped			; -1	  Stopped: NIL
		beq.s	sound_restart			;  0	  Reload registers
sound_running:							;  1
		movea.l AUD_END(a0),a2			;		  current sample base
		moveq	#-1,d3
		move.w	AUD_INT(a0),d3			;		  Die alten Werte Åbernehmen
		move.w	AUD_FRAC(a0),d2
		bra.s	select_audiomode		;		  das war's schon

sound_restart:
		addq.w	#1,AUD_STATE(a0)		;		  enter next State
		movea.l AUD_START(a0),a2		;		  StartAdresse
		move.l	a2,d2
		beq 	clearframeX 			;		  NULL -> kein Sample
		moveq	#0,d3
		move.w	AUD_LEN(a0),d3			;		  Sample Length
		add.w	d3,d3					;		  make bytes
		bcc.s	sound_spl_ok			;         alles OK?
		move.w	#$FFFE,d3				;         maximum spl length
sound_spl_ok:
		beq 	clearframeX 			;		  0 -> kein Sample
		adda.l	d3,a2
		move.l	a2,AUD_END(a0)
		neg.l	d3						;negativer startoffset!

		addq.w	#1,d3					;skip the first byte (anyhow it's 0 !)

		move.l	AUD_LSTART(a0),d1
		beq.s	no_loop
		moveq	#0,d0
		move.w	AUD_LLEN(a0),d0 		;		  'replen'
		add.w	d0,d0					;		  to bytes
		cmpi.w	#2,d0
		bls.s	no_loop 				;		  no repeat allowed!
		movea.l d1,a2
		adda.l	d0,a2
		move.l	a2,AUD_END(a0)			;		  This is the 'real' end of sample
		neg.l	d0
		move.w	d0,AUD_OFFSET(a0)		;		  'Real' repeat value
		move.l	d2,d3					;		  (start-loopend)
		sub.l	a2,d3					;		  recalc first int-value

		addq.w	#1,d3					;skip the first byte (anyhow it's 0 !)

		bra.s	is_loop

no_loop:clr.w	AUD_OFFSET(a0)			;		  Reload value
is_loop:moveq	#0,d2					;		  zero Lowword of (current) Offset

select_audiomode:
		btst	#VIRGIN,d7				;		  Kanal noch nicht benutzt?
		bne.s	add_sound
		addq.l	#FIRSTTIME,a5
add_sound:
		movea.l AudioFreqTabP(pc),a3	;		 FreqTab basis
		moveq	#0,d4
		move.w	AUD_PER(a0),d4			;		  AmigaPeriode
		beq.s	clearframeX 			;		  Nullperiode -> Abbruch
		lsl.l	#2,d4
		move.w	2(a3,d4.l),d0			;		  IncrementWert lowword!
		move.w	0(a3,d4.l),d1			;		  IncrementWert hi
		bne.s	no_fastcalc
		lea 	FASTCALC(a5),a5 		;		  Schnelle Routinen
no_fastcalc:
		move.w	AUD_VOL(a0),d4
		beq.s	zerovolume				;		  Sonderfall: NULL volume!!
		cmpi.w	#TOGGLEVOLUME,d4		;		  64=0 dB; 60=-0.56 dB
		bge.s	no_volume				;		  LautstÑrkeinfo benîtigt
		addq.l	#VOLUMES,a5
		movea.l voltabP(pc),a4			;		  ST: volume table
		move.w	d4,d5
		asl.w	#8,d5					;		  *256
		adda.w	d5,a4
no_volume:
		subq.w	#1,d7					;		  wegen DBcc!
		movea.l (a5),a5 				;		  Fetch Vector

;
; Register sind folgendermaûen belegt:
;
;  d1.w:d0.w == Increment-Wert 16+16 bit Fixkomma
;  d3.w:d2.w == 16+16 bit Fixkomma Offset zum SampleBase
;  d4.w 	 == Volume Info
;  d7		 == Frame byte counter
;  a0		 == AudioChannel N struct pointer
;  a1		 == Temp Buffer
;  a2		 == Sample Base
;! a4		 == Ptr _in_to the correct volume table (char voltab[256])
;  a6		 == reference pointer
;  d5,d6,a3,a4 ==  WorkRegs
;

		tst.w	AUD_OFFSET(a0)			; Gelooptes Sample?
		bne.s	framecalc_looped

framecalc_oneshot:
		jsr 	(a5)					; Do Frame...
		bcc.s	framefilled 			; Frame ist gefÅllt, fertig.
		bra.s	clearrestX				; sonst Rest des Samples lîschen!

framecalc_looped:
		jsr 	(a5)					; Do Frame...
		bcc.s	framefilled 			; Frame ist gefÅllt, fertig.
		add.w	AUD_OFFSET(a0),d3		; ansonsten Offset dazu!
		subq.w	#1,d7					; weil dbcc noch nicht dekrem. hat
		bpl.s	framecalc_looped

framefilled:
		move.w	d3,AUD_INT(a0)			; FÅr's nÑchste Mal
		move.w	d2,AUD_FRAC(a0)
		bset	#VIRGIN,d7				; AktivitÑt anzeigen!
		rts

*
* clear the remainder of the frame!
*
clearrestX:
		move.w	#STOPPED,AUD_STATE(a0)	; 'Stopped'-State
		bset	#VIRGIN,d7				;	 Falls schon belegt -> no op!
		beq.s	clrfrm					;	 andernfalls clear frame
		rts
*
* clear frame if needed & Stop Audiochannel
*
clearframeX:
		move.w	#STOPPED,AUD_STATE(a0)	; 'Stopped'-State
*
* clear only...
*
sound_stopped:
clearframe:
		btst	#LASTFLAG,d7			;Letzter Durchgang?
		beq.s	clrfrm3 				;nein -> nichts lîschen!
		btst	#VIRGIN,d7				;Schon Daten im Puffer?
		bne.s	clrfrm3 				;ja -> nichts lîschen!!
clrfrm: moveq	#0,d5
		lsr.w	#3,d7
clrfrm1:move.l	d5,(a1)+
		move.l	d5,(a1)+
		move.l	d5,(a1)+
		move.l	d5,(a1)+				;8 words
clrfrm2:dbra	d7,clrfrm1				;Rest des Frames Nullsetzen
clrfrm3:move.w	d3,AUD_INT(a0)			;FÅr's nÑchste Mal
		move.w	d2,AUD_FRAC(a0)
		rts

*
* if zero volume required:
*
* 1. looped sample: _stop_ sample temporarily & save CPU time
* 2. oneshot sample: continue offset count!
*
zerovolume:
		tst.w	AUD_OFFSET(a0)			;Loop mîglich?
		bne.s	clearframe				;ja -> sample kann gestoppt werden
		subq.w	#1,d7					;sample geht weiter (wegen DBcc)
		lea 	zerovolf(pc),a5
		btst	#VIRGIN,d7
		beq.s	framecalc_oneshot		;erstes Mal: dann lîsche Frame auch!
		lea 	zerovoln(pc),a5
		bra.s	framecalc_oneshot		;sonst nur Sample Increment

;-----------------------------------------------------------------------
; Zusammenfassen der 16 bit Werte (map/clip)
;
; Register:
;		  a1		left channel 16 bit data
;		  a2		right channel 16 bit data
;		  a3		interleaved L+R sampledata in ST-RAM
;		  d7		Audio Frame Size
;
;-----------------------------------------------------------------------
;
; Normales umrechnen 15 auf 8 bit, kein Clipping
;
map_15to8:
		lsr.w	#2,d7
map:	move.w	(a1)+,d1				;Left channel sample word
		add.w	d1,d1					;*2
		move.w	(a2)+,d2				;Right Channel sample word
		asr.w	#7,d2					;DIV 128
		move.b	d2,d1
		swap	d1
		move.w	(a1)+,d1				;Left
		add.w	d1,d1
		move.w	(a2)+,d2				;Right
		asr.w	#7,d2
		move.b	d2,d1
		move.l	d1,(a3)+
		move.w	(a1)+,d1				;Left channel sample word
		add.w	d1,d1					;*2
		move.w	(a2)+,d2				;Right Channel sample word
		asr.w	#7,d2					;DIV 128
		move.b	d2,d1
		swap	d1
		move.w	(a1)+,d1				;Left
		add.w	d1,d1
		move.w	(a2)+,d2				;Right
		asr.w	#7,d2
		move.b	d2,d1
		move.l	d1,(a3)+
		dbra	d7,map
		rts

;---------------------------------------------------------------------
; 15 to 9 bit, clip. This one uses tables....
;
map_15to9:
		lea 	maptable+256(pc),a0
		add.w	d7,d7
		lea 	0(a1,d7.w),a4			;End Address!
map1:	movem.w (a1)+,d0-d3 			;L-ch, 4 words
		movem.w (a2)+,d4-d7
		asr.w	#6,d0					;DIV 64
		move.b	0(a0,d0.w),(a3)+		;L
		asr.w	#6,d4
		move.b	0(a0,d4.w),(a3)+		;R
		asr.w	#6,d1
		move.b	0(a0,d1.w),(a3)+		;L
		asr.w	#6,d5
		move.b	0(a0,d5.w),(a3)+		;R
		asr.w	#6,d2
		move.b	0(a0,d2.w),(a3)+		;L
		asr.w	#6,d6
		move.b	0(a0,d6.w),(a3)+		;R
		asr.w	#6,d3
		move.b	0(a0,d3.w),(a3)+		;L
		asr.w	#6,d7
		move.b	0(a0,d7.w),(a3)+		;R
		cmpa.l	a1,a4
		bhi.s	map1
		rts


;---------------------------------------------------------------------
; 9 -> 8 bit, scaling..
;
map_9to8:add.w	d7,d7
		lea 	0(a1,d7.w),a4			;End Address!
map2:	movem.w (a1)+,d0-d3 			;L-ch, 4 words
		movem.w (a2)+,d4-d7 			;R-ch
		asr.w	#1,d0					;DIV 64
		move.b	d0,(a3)+				;L
		asr.w	#1,d4
		move.b	d4,(a3)+				;R
		asr.w	#1,d1
		move.b	d1,(a3)+				;L
		asr.w	#1,d5
		move.b	d5,(a3)+				;R
		asr.w	#1,d2
		move.b	d2,(a3)+				;L
		asr.w	#1,d6
		move.b	d6,(a3)+				;R
		asr.w	#1,d3
		move.b	d3,(a3)+				;L
		asr.w	#1,d7
		move.b	d7,(a3)+				;R
		cmpa.l	a1,a4
		bls.s	map4
map3:	movem.w (a1)+,d0-d3 			;L-ch, 4 words
		movem.w (a2)+,d4-d7 			;R-ch
		asr.w	#1,d0					;DIV 64
		move.b	d0,(a3)+				;L
		asr.w	#1,d4
		move.b	d4,(a3)+				;R
		asr.w	#1,d1
		move.b	d1,(a3)+				;L
		asr.w	#1,d5
		move.b	d5,(a3)+				;R
		asr.w	#1,d2
		move.b	d2,(a3)+				;L
		asr.w	#1,d6
		move.b	d6,(a3)+				;R
		asr.w	#1,d3
		move.b	d3,(a3)+				;L
		asr.w	#1,d7
		move.b	d7,(a3)+				;R
		cmpa.l	a1,a4
		bhi.s	map2
map4:	rts

;----------------------------------------------------------------------
; 9 to 9 bit, clip. This one uses tables....
;
map_9to9:
		lea 	maptable+256(pc),a0
		add.w	d7,d7
		lea 	0(a1,d7.w),a4			;End Address!
map5:	movem.w (a1)+,d0-d3 			;L-ch, 4 words
		movem.w (a2)+,d4-d7
		move.b	0(a0,d0.w),(a3)+		;L
		move.b	0(a0,d4.w),(a3)+		;R
		move.b	0(a0,d1.w),(a3)+		;L
		move.b	0(a0,d5.w),(a3)+		;R
		move.b	0(a0,d2.w),(a3)+		;L
		move.b	0(a0,d6.w),(a3)+		;R
		move.b	0(a0,d3.w),(a3)+		;L
		move.b	0(a0,d7.w),(a3)+		;R
		cmpa.l	a1,a4
		bls.s	map7
map6:	movem.w (a1)+,d0-d3 			;L-ch, 4 words
		movem.w (a2)+,d4-d7
		move.b	0(a0,d0.w),(a3)+		;L
		move.b	0(a0,d4.w),(a3)+		;R
		move.b	0(a0,d1.w),(a3)+		;L
		move.b	0(a0,d5.w),(a3)+		;R
		move.b	0(a0,d2.w),(a3)+		;L
		move.b	0(a0,d6.w),(a3)+		;R
		move.b	0(a0,d3.w),(a3)+		;L
		move.b	0(a0,d7.w),(a3)+		;R
		cmpa.l	a1,a4
		bhi.s	map5
map7:	rts


;-----------------------------------------------------------------------
; Vektoren:
;-----------------------------------------------------------------------
;
; ST NORMAL MODUS (tabellen)
;
Audio_ST_normal:
				dc.l s_stfn 			;Normal, fixed volume
				dc.l s_stff 			;Normal, fixed vol, first time
				dc.l s_stvn 			;Normal, volumes
				dc.l s_stvf 			;Normal, volumes, first time
				dc.l s_stfn 			;[fast], fixed volume
				dc.l s_stff 			;[fast], fixed vol, first time
				dc.l s_stvn 			;[fast], volumes
				dc.l s_stvf 			;[fast], volumes, first time

				dc.l map_9to8			;9 bit Resultate auf 8 bit mappen
				dc.l map_9to9			; id. auf pseudo-9 bit

;
; TT NORMAL MODUS
;
Audio_TT_normal:
				dc.l snormfn			;Normal, fixed volume
				dc.l snormff			;Normal, fixed vol, first time
				dc.l snormvn			;Normal, volumes
				dc.l snormvf			;Normal, volumes, first time
				dc.l snormfn			;[fast], fixed volume
				dc.l snormff			;[fast], fixed vol, first time
				dc.l snormvn			;[fast], volumes
				dc.l snormvf			;[fast], volumes, first time

				dc.l map_15to8
				dc.l map_15to9

;
; TT INTERPOLATION
;
Audio_TT_interpol:
				if FULLBLOWN_INTERPOLATION
				dc.l sintrpn			;no volumes
				dc.l sintrpf			;no vol, first time
				dc.l sintrpvn			;volumes
				dc.l sintrpvf			;vol + first time
				else
				dc.l snormfn			;Normal, fixed volume
				dc.l snormff			;Normal, fixed vol, first time
				dc.l snormvn			;Normal, volumes
				dc.l snormvf			;Normal, volumes, first time
				endc

				dc.l sintrpnf			;fast novol
				dc.l sintrpff			;fast novol first time
				dc.l sintrpvnf			;fast volume
				dc.l sintrpvff			;fast volume first time

				dc.l map_15to8
				dc.l map_15to9


;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
; Berechnen der Samplewerte   (precision scaling)
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------

*
* Dummy: Zero Volume (continuing sample, anyway!)
*
zerovolf:
		moveq	#0,d6
zervol1:move.w	d6,(a1)+				;Store Zerosample
		add.w	d0,d2
		addx.w	d1,d3
		dbcs	d7,zervol1
		rts

zerovoln:
		add.w	d0,d2					;other channels: increment only!
		addx.w	d1,d3
		dbcs	d7,zerovoln
		rts

;-----------------------------------------------------------------------
; ST NORMAL MODUS:
;
; * benîtigt in a4 Zeiger auf Volumetabelle.
; * produziert 8 bit output pro kanal
;-----------------------------------------------------------------------
*
* ST Normal mode, variable Volume, first channel
*
s_stvf: moveq	#0,d6
s_stvf1:move.b	0(a2,d3.l),d6			;get as unsigned char!
		move.b	0(a4,d6.w),d5
		ext.w	d5
		move.w	d5,(a1)+
		add.w	d0,d2
		addx.w	d1,d3
		dbcs	d7,s_stvf1
		rts
*
* ST Normal mode, variable Volume, add-on channel
*
s_stvn: moveq	#0,d6
s_stvn1:move.b	0(a2,d3.l),d6
		move.b	0(a4,d6.w),d5
		ext.w	d5
		add.w	d5,(a1)+				;add on...
		add.w	d0,d2					;Nachkomma zÑhler
		addx.w	d1,d3					;vorkomma-Teil
		dbcs	d7,s_stvn1				;SamplelÑnge in d7
		rts
*
* ST Normal mode, fixed volume, first channel
*
s_stff: move.b	0(a2,d3.l),d6
		ext.w	d6
		move.w	d6,(a1)+
		add.w	d0,d2
		addx.w	d1,d3
		dbcs	d7,s_stff
		rts
*
* ST Normal mode, fixed volume
*
s_stfn: move.b	0(a2,d3.l),d6
		ext.w	d6
		add.w	d6,(a1)+
		add.w	d0,d2
		addx.w	d1,d3
		dbcs	d7,s_stfn
		rts


;-----------------------------------------------------------------------
; TT NORMAL MODUS
;
; * produziert 14 bit output pro kanal
;-----------------------------------------------------------------------
*
* Normal mode, variable Volume, first channel
*
snormvf:move.b	0(a2,d3.l),d6
		ext.w	d6
		muls	d4,d6
		move.w	d6,(a1)+
		add.w	d0,d2
		addx.w	d1,d3
		dbcs	d7,snormvf
		rts
*
* Normal mode, variable Volume, add-on channel
*
snormvn:move.b	0(a2,d3.l),d6
		ext.w	d6
		muls	d4,d6
		add.w	d6,(a1)+				;add on...
		add.w	d0,d2					;Nachkomma zÑhler
		addx.w	d1,d3					;vorkomma-Teil
		dbcs	d7,snormvn				;SamplelÑnge in d7
		rts
*
* Normal mode, fixed volume, first channel
*
snormff:move.b	0(a2,d3.l),d6
		ext.w	d6
		lsl.w	#VOLBITS,d6
		move.w	d6,(a1)+
		add.w	d0,d2
		addx.w	d1,d3
		dbcs	d7,snormff
		rts
*
* Normal mode, fixed volume
*
snormfn:move.b	0(a2,d3.l),d6
		ext.w	d6
		lsl.w	#VOLBITS,d6
		add.w	d6,(a1)+
		add.w	d0,d2
		addx.w	d1,d3
		dbcs	d7,snormfn
		rts

;-----------------------------------------------------------------------
; TT INTERPOLATION MODUS
;
; * produziert 14 bit output
;-----------------------------------------------------------------------
				if FULLBLOWN_INTERPOLATION
*
* volume, interpol, first time
*
sintrpvf:lea	0(a2,d3.l),a3			;Sampledata
		move.b	(a3)+,d5				; Current Sample Word
		ext.w	d5
		muls	d4,d5					; * Volume!
		movea.l d5,a4					; -> this is the base value
		move.b	(a3),d5 				;Next sample word
		ext.w	d5
		muls	d4,d5					; * Volume!
		sub.w	a4,d5					;Difference
		move.w	d2,d6
		lsr.w	#1,d6					; intersample position / 2
		muls	d6,d5
		swap	d5						; /65536
		add.w	d5,d5					; * 2		  ---> /32768
		add.w	a4,d5					; + base -> interpolated value!
		move.w	d5,(a1)+				;outgoing Sampledata
		add.w	d0,d2					;(1/65536) Next Sample Position
		addx.w	d1,d3					;(1/1)
		dbcs	d7,sintrpvf
		rts
*
* volume, interpol
*
sintrpvn:lea	0(a2,d3.l),a3			;Sampledata
		move.b	(a3)+,d5				; Current Sample Word
		ext.w	d5
		muls	d4,d5					; * Volume!
		movea.l d5,a4					; -> this is the base value
		move.b	(a3),d5 				;Next sample word
		ext.w	d5
		muls	d4,d5					; * Volume!
		sub.w	a4,d5					;Difference
		move.w	d2,d6
		lsr.w	#1,d6					; intersample position / 2
		muls	d6,d5
		swap	d5						; /65536
		add.w	d5,d5					; * 2		  ---> /32768
		add.w	a4,d5					; + base -> interpolated value!
		add.w	d5,(a1)+				;outgoing Sampledata
		add.w	d0,d2					;(1/65536) Next Sample Position
		addx.w	d1,d3					;(1/1)
		dbcs	d7,sintrpvn
		rts
*
* no volume, interpol, first time
*
sintrpf:lea 	0(a2,d3.l),a3			;Sampledata
		move.b	(a3)+,d4				; Current Sample Word
		ext.w	d4
		asl.w	#VOLBITS,d4 			; * maxvol!
		move.b	(a3),d5 				;Next sample word
		ext.w	d5
		asl.w	#VOLBITS,d5 			; * maxvol!
		sub.w	d4,d5					;Difference
		move.w	d2,d6
		lsr.w	#1,d6					; intersample position / 2
		muls	d6,d5
		swap	d5						; /65536
		add.w	d5,d5					; * 2		  ---> /32768
		add.w	d4,d5					; + base -> interpolated value!
		move.w	d5,(a1)+				;outgoing Sampledata
		add.w	d0,d2					;(1/65536) Next Sample Position
		addx.w	d1,d3					;(1/1)
		dbcs	d7,sintrpf
		rts
*
* no volume, interpol
*
sintrpn:lea 	0(a2,d3.l),a3			;Sampledata
		move.b	(a3)+,d4				; Current Sample Word
		ext.w	d4
		asl.w	#VOLBITS,d4 			; * Volume!
		move.b	(a3),d5 				;Next sample word
		ext.w	d5
		asl.w	#VOLBITS,d5 			; * Volume!
		sub.w	d4,d5					;Difference
		move.w	d2,d6
		lsr.w	#1,d6					; intersample position / 2
		muls	d6,d5
		swap	d5						; /65536
		add.w	d5,d5					; * 2		  ---> /32768
		add.w	d4,d5					; + base -> interpolated value!
		add.w	d5,(a1)+				;outgoing Sampledata
		add.w	d0,d2					;(1/65536) Next Sample Position
		addx.w	d1,d3					;(1/1)
		dbcs	d7,sintrpn
		rts
				endc
*
* volume, interpolation, first time, fast algorithm
*
sintrpvff:								;interpolation start:
		lea 	0(a2,d3.l),a3			;Sample-Adresse holen: &s[ip]
		move.b	(a3)+,d5
		ext.w	d5
		muls	d4,d5					; s1 = s[ip++]*vol
		movea.l d5,a4					; s2 = s1
intrp:	move.l	a4,d5					; s1 = s2  (s1 == calcbase)
		move.b	(a3)+,d6
		ext.w	d6
		muls	d4,d6					; s2 = *s++ * vol
		movea.l d6,a4					; save s2 for next time
		sub.w	d5,d6					; delta = s2 - s1
		add.w	d6,d6					; * 2 to compensate /2 two lines later
intrp1: move.w	d2,d1					; d1: inc-val hi == 0 !! --> **unused**
		lsr.w	#1,d1					; intersample pos. / 2
		muls	d6,d1					; (delta*2)*(fp/2)
		swap	d1						; DIV 65536
		add.w	d5,d1					; + s1
		move.w	d1,(a1)+
		add.w	d0,d2					;fractional part on increment.
		dbcs	d7,intrp1
		bcc.s	intrp2
		addq.w	#1,d3					;NEXT step, never skip one!
		dbcs	d7,intrp
intrp2: rts

*
* volume, interpolation, fast algorithm
*
sintrpvnf:
		lea 	0(a2,d3.l),a3			;Sample-Adresse holen: &s[ip]
		move.b	(a3)+,d5
		ext.w	d5
		muls	d4,d5					; s1 = s[ip++]*vol
		movea.l d5,a4
intrp3: move.l	a4,d5					; s1 = s2  (s1 == calcbase)
		move.b	(a3)+,d6
		ext.w	d6
		muls	d4,d6					; s2 = *s++ * vol
		movea.l d6,a4					; save s2 for next time
		sub.w	d5,d6					; delta = s2 - s1
		add.w	d6,d6					; * 2 to compensate /2 two lines later
intrp4: move.w	d2,d1					; d1: inc-val hi == 0 !! --> **unused**
		lsr.w	#1,d1					; intersample pos. / 2
		muls	d6,d1					; (delta*2)*(fp/2)
		swap	d1						; DIV 65536
		add.w	d5,d1					; + s1
		add.w	d1,(a1)+
		add.w	d0,d2					;fractional part on increment.
		dbcs	d7,intrp4
		bcc.s	intrp5
		addq.w	#1,d3					;NEXT step, never skip one!
		dbcs	d7,intrp3
intrp5: rts

*
* no volume, interpolation, first time, fast algorithm
*
sintrpff:
		lea 	0(a2,d3.l),a3			;Sample-Adresse holen: &s[ip]
		move.b	(a3)+,d5
		ext.w	d5
		asl.w	#VOLBITS,d5 			; s1 = s[ip++]*vol
		movea.l d5,a4
intrp6: move.l	a4,d5					; s1 = s2  (s1 == calcbase)
		move.b	(a3)+,d6
		ext.w	d6
		asl.w	#VOLBITS,d6
		movea.l d6,a4					; save s2 for next time
		sub.w	d5,d6					; delta = s2 - s1
		add.w	d6,d6					; * 2 to compensate /2 two lines later
intrp7: move.w	d2,d1					; d1: inc-val hi == 0 !! --> **unused**
		lsr.w	#1,d1					; intersample pos. / 2
		muls	d6,d1					; (delta*2)*(fp/2)
		swap	d1						; DIV 65536
		add.w	d5,d1					; + s1
		move.w	d1,(a1)+
		add.w	d0,d2					;fractional part on increment.
		dbcs	d7,intrp7
		bcc.s	intrp8
		addq.w	#1,d3					;NEXT step, never skip one!
		dbcs	d7,intrp6
intrp8: rts

*
* no volume, interpolation, fast algorithm
*
sintrpnf:
		lea 	0(a2,d3.l),a3			;Sample-Adresse holen: &s[ip]
		move.b	(a3)+,d5
		ext.w	d5
		asl.w	#VOLBITS,d5 			; s1 = s[ip++]*vol
		movea.l d5,a4
intrp9: move.l	a4,d5					; s1 = s2  (s1 == calcbase)
		move.b	(a3)+,d6
		ext.w	d6
		asl.w	#VOLBITS,d6
		movea.l d6,a4					; save s2 for next time
		sub.w	d5,d6					; delta = s2 - s1
		add.w	d6,d6					; * 2 to compensate /2 two lines later
intrp10:move.w	d2,d1					; d1: inc-val hi == 0 !! --> **unused**
		lsr.w	#1,d1					; intersample pos. / 2
		muls	d6,d1					; (delta*2)*(fp/2)
		swap	d1						; DIV 65536
		add.w	d5,d1					; + s1
		add.w	d1,(a1)+
		add.w	d0,d2					;fractional part on increment.
		dbcs	d7,intrp10
		bcc.s	intrp11
		addq.w	#1,d3					;NEXT step, never skip one!
		dbcs	d7,intrp9
intrp11:rts



; -----------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------
				bss

*
* AudioChannel[4] - Die emulierten Register
*
AudioChannel1:		ds.b Sizeof_AUD 	; (LEFT CHANNEL I)
AudioChannel2:		ds.b Sizeof_AUD 	; (RIGHT CHANNEL I)
AudioChannel3:		ds.b Sizeof_AUD 	; (RIGHT CHANNEL II)
AudioChannel4:		ds.b Sizeof_AUD 	; (LEFT CHANNEL II)

*
* Platz fÅr die Freq.Conversion Table
*
freqtab:		ds.l FREQTABSIZE		;hierher kommt die ominîse Frequenztabelle
voltabP:		ds.l 1					;Zeiger auf Volume Table

last_freqtabcheck:
				ds.l 1

*
* Zwischenpuffer fÅr Sounddaten
*
LeftBuffer: 	ds.w MAXFRAMESIZE		;Achtung! immer 8 words freilassen!
RightBuffer:	ds.w MAXFRAMESIZE

; -----------------------------------------------------------------------
; Data
; -----------------------------------------------------------------------
				data

*
* Steuer-Register:
*
AudioFreqTabP:		dc.l freqtab		;ptr auf STe Frequenzen-Tabelle (wie gehabt)
AudioVectors:		dc.l 0				;Ptr to AudioVectors
AudioFrame: 		dc.l 0				;Ptr auf Zielpuffer
AudioFrameSize: 	dc.w 1				;LÑnge des Framebuffers
;AudioSampleFreq:	 dc.w 0 			 ;Samplingfrequenz bei der Ausgabe


; Constant Data
maptable:								;logarithmic 9 to 8 bit map table
				dc.b $80,$80,$80,$81,$81,$81,$81,$81
				dc.b $81,$81,$81,$81,$81,$81,$81,$81
				dc.b $81,$81,$82,$82,$82,$82,$82,$82
				dc.b $82,$82,$82,$82,$82,$83,$83,$83
				dc.b $83,$83,$83,$83,$83,$84,$84,$84
				dc.b $84,$84,$84,$84,$85,$85,$85,$85
				dc.b $85,$85,$86,$86,$86,$86,$86,$87
				dc.b $87,$87,$87,$88,$88,$88,$88,$89
				dc.b $89,$89,$89,$8A,$8A,$8A,$8A,$8B
				dc.b $8B,$8B,$8B,$8C,$8C,$8C,$8D,$8D
				dc.b $8D,$8D,$8E,$8E,$8E,$8F,$8F,$8F
				dc.b $90,$90,$90,$91,$91,$92,$92,$92
				dc.b $93,$93,$93,$94,$94,$95,$95,$95
				dc.b $96,$96,$97,$97,$97,$98,$98,$99
				dc.b $99,$99,$9A,$9A,$9B,$9B,$9C,$9C
				dc.b $9D,$9D,$9E,$9E,$9F,$9F,$A0,$A0
				dc.b $A0,$A1,$A1,$A2,$A3,$A3,$A4,$A4
				dc.b $A5,$A5,$A6,$A6,$A7,$A7,$A8,$A8
				dc.b $A9,$A9,$AA,$AB,$AB,$AC,$AC,$AD
				dc.b $AE,$AE,$AF,$AF,$B0,$B1,$B1,$B2
				dc.b $B2,$B3,$B4,$B4,$B5,$B6,$B6,$B7
				dc.b $B7,$B8,$B9,$B9,$BA,$BB,$BB,$BC
				dc.b $BD,$BD,$BE,$BF,$C0,$C0,$C1,$C2
				dc.b $C2,$C3,$C4,$C5,$C5,$C6,$C7,$C8
				dc.b $C8,$C9,$CA,$CB,$CB,$CC,$CD,$CE
				dc.b $CE,$CF,$D0,$D1,$D1,$D2,$D3,$D4
				dc.b $D5,$D5,$D6,$D7,$D8,$D9,$DA,$DA
				dc.b $DB,$DC,$DD,$DE,$DF,$E0,$E0,$E1
				dc.b $E2,$E3,$E4,$E5,$E6,$E7,$E7,$E8
				dc.b $E9,$EA,$EB,$EC,$ED,$EE,$EF,$F0
				dc.b $F1,$F1,$F2,$F3,$F4,$F5,$F6,$F7
				dc.b $F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF
				dc.b $00,$01,$02,$03,$04,$05,$06,$07
				dc.b $08,$09,$0A,$0B,$0C,$0D,$0E,$0F
				dc.b $0F,$10,$11,$12,$13,$14,$15,$16
				dc.b $17,$18,$19,$19,$1A,$1B,$1C,$1D
				dc.b $1E,$1F,$20,$20,$21,$22,$23,$24
				dc.b $25,$26,$26,$27,$28,$29,$2A,$2B
				dc.b $2B,$2C,$2D,$2E,$2F,$2F,$30,$31
				dc.b $32,$32,$33,$34,$35,$35,$36,$37
				dc.b $38,$38,$39,$3A,$3B,$3B,$3C,$3D
				dc.b $3E,$3E,$3F,$40,$40,$41,$42,$43
				dc.b $43,$44,$45,$45,$46,$47,$47,$48
				dc.b $49,$49,$4A,$4A,$4B,$4C,$4C,$4D
				dc.b $4E,$4E,$4F,$4F,$50,$51,$51,$52
				dc.b $52,$53,$54,$54,$55,$55,$56,$57
				dc.b $57,$58,$58,$59,$59,$5A,$5A,$5B
				dc.b $5B,$5C,$5C,$5D,$5D,$5E,$5F,$5F
				dc.b $60,$60,$60,$61,$61,$62,$62,$63
				dc.b $63,$64,$64,$65,$65,$66,$66,$67
				dc.b $67,$67,$68,$68,$69,$69,$69,$6A
				dc.b $6A,$6B,$6B,$6B,$6C,$6C,$6D,$6D
				dc.b $6D,$6E,$6E,$6E,$6F,$6F,$70,$70
				dc.b $70,$71,$71,$71,$72,$72,$72,$73
				dc.b $73,$73,$73,$74,$74,$74,$75,$75
				dc.b $75,$75,$76,$76,$76,$76,$77,$77
				dc.b $77,$77,$78,$78,$78,$78,$79,$79
				dc.b $79,$79,$7A,$7A,$7A,$7A,$7A,$7B
				dc.b $7B,$7B,$7B,$7B,$7B,$7C,$7C,$7C
				dc.b $7C,$7C,$7C,$7C,$7D,$7D,$7D,$7D
				dc.b $7D,$7D,$7D,$7D,$7E,$7E,$7E,$7E
				dc.b $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7F
				dc.b $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
				dc.b $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F


; -----------------------------------------------------------------------
; end of file
; -----------------------------------------------------------------------

