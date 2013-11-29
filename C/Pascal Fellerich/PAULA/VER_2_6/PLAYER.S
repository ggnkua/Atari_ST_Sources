*************************************************************************
*
*  PLAYER.S
*  --------
*
*  High level assembler routines, interface between C and ASM part.
*
*
*
*  last modified: 25-Dec-1992
*
*************************************************************************

				include "pdefs.inc"

; -----------------------------------------------------------------------
; Globals:
; -----------------------------------------------------------------------
;
; exported Subroutines:
;
				xdef p_set_amigaclock	;chip clock freq (in Hz)
				xdef p_set_samplefreq	;set Atari sample freq
				xdef p_set_framefreq	;set replay speed in Hz (norm = 50)
				xdef p_set_ciaspeed		;set CIA replay speed (norm=125)
				xdef p_get_position 	;player display primitive
				xdef p_get_state		;id.
				xdef p_get_cpuload		;id.
				xdef p_get_name 		;id
				xdef p_fastforward		;player command primitives
				xdef p_rewind			;id...
				xdef p_load
				xdef p_free
				xdef p_play
				xdef p_pause
				xdef p_stop
				
				xdef free_module
				
;
; exported variables:
;
				xdef p_state, p_swapchannel
				xdef p_compatibility,p_interpolate,p_repeat
				xdef p_chipclock,p_samplefreq,p_framefreq
				xdef p_boost,p_cpuload,p_overload

				xdef paula_frequencies

;
; imported Routines:
;
				xref supexec			;from system.s
				xref init_DMA_sound, exit_DMA_sound
				xref alloc_fast_ram
				xref free_memory

				xref load_file			;from loadfile.s
				
				xref mt_init			;from ptreplay.s
				xref init_player

				xref calc_freqtab		;from synth.s
;
; imported Variables:
;
				xref mt_SongDataPtr 	;from ptreplay.s
				xref mt_SongEndPtr
				xref mt_SongPos
				xref mt_PatternPos
				xref mt_SeqList
				xref mt_ariadne
				xref mt_ciaspeed

				xref AudioFrameSize 	;from synth.s
				xref sdmabufadr1
				xref LeftBuffer, RightBuffer

				xref softdma_interface	;from system.s



; -----------------------------------------------------------------------
; internal defines:
; -----------------------------------------------------------------------

;
; Funktionsprimitiven des Players
; (siehe switch-table in 'state_machine')
;
X_NOP			equ 0					;endekennung
X_LOAD			equ 1					;datei laden & initialisieren
X_FREE			equ 2					;freigabe der datei
X_PLAY			equ 3					;abspielen starten
X_STOP			equ 4					;stop
X_RESET 		equ 5					;player reset
X_FF			equ 6
X_REW			equ 7

;
; Transition command numbers
;
T_LOAD			equ 0					;User commands
T_FREE			equ 1
T_PLAY			equ 2
T_PAUSE 		equ 3
T_STOP			equ 4
T_FASTFORWARD	equ 5
T_REWIND		equ 6
T_TEMPSTOP		equ 7					;internally used!



; -----------------------------------------------------------------------
; Code:
; -----------------------------------------------------------------------
				text

*
* detuning:
*
* Param:	d0.l - Amiga Chip Clock frequency
* Return:	void
* Global:	a new freq tab is calculated
*
p_set_amigaclock:
		move.l	a6,-(sp)
		move.l	d0,p_chipclock
		moveq	#0,d1
		move.w	realsamplefreq(pc),d1
		bsr 	calc_freqtab
psetclk1:
		movea.l (sp)+,a6
		rts

*
* Set other sample frequencies
*
* Param:	d0.w -	sample freq index for STE Sound-DMA Hardware
*					or -1 (no change)
* Return:	d0.w -	old samplefreq index
* Global:	a new freqtab is calculated;
*			the player is temporarily interrupted
*
p_set_samplefreq:
		move.l	a6,-(sp)
		move.w	d0,d1					;check & transfer index
		bmi.s	psetsf1
		cmpi.w	#3,d1					;maximum index
		bgt.s	psetsf1 				;>3 is illegal
		lea		p_samplefreq(pc),a0
		cmp.w	(a0),d1					;same as previously?
		beq.s	psetsf1
		move.w	d1,(a0)

		moveq	#T_TEMPSTOP,d0			;halt player if necessary
		bsr 	p_docmd

		bsr 	do_setfrequency

		moveq	#T_TEMPSTOP,d0			;restart player if n
		bsr 	p_docmd

psetsf1:
		move.w	p_samplefreq(pc),d0 	;return current sample freq index
		movea.l (sp)+,a6
		rts

do_setfrequency:
		moveq	#0,d1
		move.w	p_samplefreq(pc),d1
		add.w	d1,d1					;*2 (index to offset)
		move.w	paula_frequencies(pc,d1.w),d1		;get sampling frequency
		move.w	d1,realsamplefreq
		move.l	d1,d2
		move.w	p_framefreq(pc),d0
		bsr		p_set_framefreq
		move.l	d2,d1
		move.l	p_chipclock(pc),d0		;Get Amiga Clock Freq
		bra 	calc_freqtab			;Do the table!

paula_frequencies:
		dc.w 6258,12517,25033,50066; (ste - default!!!)

;STE mit 8.0106 MHz:
;		dc.w 6258,12517,25033,50066; (ste)
;TT mit 32.215905 MHz:
;		dc.w 6292,12584,25167,50337 ;(tt)
;Falcon030 mit neuem Soundsubsystem 25.175 MHz:
;		dc.w 6146,12292,24585,49170
*
* Set other frame speed - normal = 50 Hz
*
* param:	d0 - userspeed in Hz
* return:	d0 - current speed
*
* -> fframe = (fsample*125)/(ciaspeeed*userspeed)
*
p_set_framefreq:
		move.w	d0,d1
		bmi.s	psetfrm1
		move.w	d1,p_framefreq
		move.w	realsamplefreq(pc),d0	;Atari Sample Frequency
		mulu	#125,d0					;*125 (CIA Constant)
		mulu	mt_ciaspeed(pc),d1		;
		beq.s	.zerodiv
		divu	d1,d0					;fsample/fframe = framesize
.zerodiv:
		addq.w	#1,d0
		cmpi.w	#MAXFRAMESIZE-8,d0
		bls.s	.frame_ok
		move.w	#MAXFRAMESIZE-8,d0
.frame_ok:
		andi	#$fffe,d0				;DMAsound needs even length...
		move.w	d0,AudioFrameSize		;store for Sound Synthesizer
psetfrm1:
		move.w	p_framefreq(pc),d0
		rts

*
* Set other CIA speed -> normal = 125
*
* param:	d0 - ciaspeed in BPM
* return:	none
*
* -> fframe = (fsample*125)/(ciaspeeed*userspeed)
* Note: only reg d0 and the var AudioFrameSize is affected!
*
p_set_ciaspeed:
		move.l	d1,-(sp)
		move.w	realsamplefreq(pc),d1	;Atari Sample Frequency
		mulu	#125,d1					;*125 (CIA Constant)
		mulu	p_framefreq(pc),d0		;
		beq.s	.zerodiv
		divu	d0,d1					;fsample/fframe = framesize
.zerodiv:
		addq.w	#1,d1
		cmpi.w	#MAXFRAMESIZE-8,d1
		bls.s	.frame_ok
		move.w	#MAXFRAMESIZE-8,d1
.frame_ok:
		andi	#$fffe,d1				;DMAsound needs even length...
		move.w	d1,AudioFrameSize		;store for Sound Synthesizer
		move.l	(sp)+,d1
		rts


*
* intern, ermittelt Position im Modfile
*
p_get_position:
		move.b	mt_SongPos(pc),d0		;Song Position
		lsl.w	#8,d0
		move.w	mt_PatternPos(pc),d1	;Position im Pattern 0..1024 (BYTE OFFSET!)
		lsr.w	#4,d1
		andi.w	#$FF,d1
		or.w	d1,d0
		rts

*
* Intern, ermittelt Current State
*
p_get_state:
		move.w	p_state(pc),d0
		rts

*
* Intern, ermittelt CPU Belastung in Promille
*
p_get_cpuload:
		lea 	p_cpuload(pc),a0
		move.w	p_state(pc),d0
		cmpi.w	#P_PLAYING,d0
		beq.s	.p_getc
		clr.w	(a0)
.p_getc:
		move.l	softdma_interface(pc),d0	;soft dma installiert?
		bne.s	.p_getc3	
		move.w	p_overload(pc),d0		;öberlastung?
		cmpi.w	#OVERTRIGGER,d0
		bhi.s	.p_getc1
		move.w	(a0),d0
		mulu	#500,d0 				;in Promille
		move.w	AudioFrameSize(pc),d1
		beq.s	.p_getc4
		divu	d1,d0					;hier:Words (nicht bytes)
		cmpi.w	#1000,d0
		bls.s	.p_getc2
.p_getc1:
		move.w	#1000,d0
.p_getc2:
		rts
.p_getc3:								;SoftDMA macht's!
		movea.l	d0,a0
		movea.l	SDMA_CPULOAD(a0),a0		;Addr
		jmp		(a0)					;jsr/rts!
.p_getc4:
		moveq	#0,d0					;zero load.
		rts

*
* Intern, ermittelt MODfile name!
*
p_get_name:
		move.l	mt_SongDataPtr(pc),d0
		beq.s	.p_getn2
		movea.l d0,a1
		moveq	#19,d0
.p_getn1:
		move.b	(a1)+,(a0)+
		dbeq	d0,.p_getn1
.p_getn2:
		clr.b	(a0)+
		rts

*
* FF Taste
*
p_fastforward:
		moveq	#T_FASTFORWARD,d0
		bra.s	p_docmd

*
* REW Taste
*
p_rewind:
		moveq	#T_REWIND,d0
		bra.s	p_docmd

*
* OPEN/CLOSE Taste
*
p_load: move.l	a0,modfile_name
		moveq	#T_LOAD,d0
		bra.s	p_docmd

*
* Intern: schmeiût MODfie raus
*
p_free: moveq	#T_FREE,d0
		bra.s	p_docmd

*
* STOP Taste
*
p_stop: moveq	#T_STOP,d0
		bra.s	p_docmd

*
* PLAY Taste
*
p_play: moveq	#T_PLAY,d0
		bra.s	p_docmd

*
* PAUSE Taste
*
p_pause:
		moveq  #T_PAUSE,d0
p_docmd:
		movem.l d3-d7/a2-a6,-(sp)
		bsr.s	state_machine
		movem.l (sp)+,d3-d7/a2-a6
		rts


;
; State Machine = transition data interpreter
;
; Parameter: d0.w = Transition command
;
state_machine:
		move.w	p_state(pc),d3
		cmpi.w	#P_HISTATE,d3
		bhi.s	sm_error
		lea 	transitiondata(pc),a3
		bra.s	sm_lp1
sm_lp:	tst.b	(a3)+
		bpl.s	sm_lp					;ganzen Block Åberlesen
sm_lp1: dbra	d3,sm_lp
; in a3 jetzt Zeiger auf die richtige State Transition Table
		bra.s	sm_lp3
sm_lp2: tst.b	(a3)+
		bne.s	sm_lp2					;Instruktionen Åberlesen
sm_lp3: move.b	(a3)+,d7				;NextState der folgenden Instr.Kette
		ext.w	d7						;auswerten
		bmi.s	sm_error				;Fehler -> Abbruch!
		dbra	d0,sm_lp2				;Suche weiter!
sm_nextinst:
		move.b	(a3)+,d0				;Instruktion holen
		ext.w	d0
		cmpi.w	#7,d0					;7 = rewind = maximum
		bhi.s	sm_error
		pea 	sm_return(pc)
		add.w	d0,d0					;*2 -> index to offset
		move.w	sm_switchtab(pc,d0.w),d0
		jmp		sm_switchtab(pc,d0.w)

sm_switchtab:
		dc.w sm_finish-sm_switchtab		;	   0
		dc.w load_module-sm_switchtab	; 	   1
		dc.w free_module-sm_switchtab	; 	   2
		dc.w play_module-sm_switchtab	; 	   3
		dc.w stop_module-sm_switchtab	; 	   4
		dc.w reset_module-sm_switchtab	;	   5
		dc.w fastforward_module-sm_switchtab ; 6
		dc.w rewind_module-sm_switchtab ;	   7

sm_finish:
		move.w	d7,p_state				;merken
		addq.w	#4,sp
		moveq	#E_OK,d0
		rts 							;bye bye

; hier geht's immer weiter
sm_return:
		tst.w	d0						;Errorcode testen
		bmi.s	sm_nop					;Abbruch durch Fehler
		bra.s	sm_nextinst
sm_error:
		moveq  #E_ERROR,d0			   ;general error!
sm_nop: rts



;
; Funktionsprimitiven des Players:
; - direkte, nicht-abgesicherte Primitiven.
;

;* load_module: Modul laden und initialisieren
;* Parms:	a0: *filename
;* return:	d0: Errorcode
load_module:
		movea.l modfile_name(pc),a0
		bsr		load_file				;Datei dynamisch laden!
		tst.w	d0
		bne.s	not_loaded				;Datei nicht geladen!
		bsr 	test_modfile
		bne.s	mod_corrupted
		bsr 	mt_init
		tst.w	d0
		bne.s	mod_corrupted
not_loaded:
		rts
mod_corrupted:
		bsr 	free_module
		moveq	#E_MODFILE,d0
		rts


;* free_module: Modfile freigeben
;* Parameter:  keine
;* Return:	   Errorcode
free_module:
		move.l	mt_SongDataPtr(pc),d0
		bsr 	free_memory 			;Speicher freigeben!
		clr.l	mt_SongDataPtr
		move.w	#P_IDLE,p_state
		moveq	#E_OK,d0
		rts

;* play_module: Modfile abspielen.
;* Parameter: keine
;* return:	  Errorcode
play_module:
		bsr 	do_setfrequency 		;Samplefrequenz programmieren
; Framebuffer 1 lîschen (das reicht)
		movea.l sdmabufadr1(pc),a0		;Startadresse
		move.l	a0,d0					;test...
		bne.s	.splay3
		lea		LeftBuffer(pc),a0
.splay3:
		moveq	#0,d0
		move.w	AudioFrameSize(pc),d0
		add.l	d0,d0					;stereo words
		add.l	a0,d0					;Endadresse
.clearbuf:
		clr.l	(a0)+					;go ahead!
		cmpa.l	d0,a0
		ble.s	.clearbuf

; Zuerst wird Frame 1 (zerodata) gespielt!
		lea 	init_DMA_sound(pc),a0	;DMA Sound starten
supexret:
		bsr 	supexec
		moveq	#E_OK,d0
		rts




;* stop_module: Abspielen anhalten
;* parms:	keine
;* return:	Errorcode
stop_module:
		lea 	exit_DMA_sound(pc),a0	;Nur DMA Stop!
		bra.s	supexret


;* reset_module: Modulplayer re-initialisieren
;* parms:	keine
;* return:	Errorcode
reset_module:
		bra 	init_player

;* fastforward: inkrementiert den PositionszÑhler
;*
fastforward_module:
		lea 	mt_SongPos(pc),a1
		movea.l mt_SeqList(pc),a0
		move.b	(a1),d0
		addq.b	#1,d0
		cmp.b	-2(a0),d0
		bhs.s	.p_ff1
		move.b	d0,(a1)
		clr.w	mt_PatternPos
.p_ff1:	moveq	#E_OK,d0
		rts

;* rewind: dekrementiert den PositionszÑhler
;*
rewind_module:
		lea 	mt_SongPos(pc),a0
		lea 	mt_ariadne(pc),a1
		moveq	#0,d0
		move.b	(a0),d0 				;SongPos lesen
		sf		0(a1,d0.w)				;unbekannt :-)
		cmpi.w	#256,mt_PatternPos		;Åber 1/4tel?
		bgt.s	.p_rew					;
		subq.b	#1,d0
		bmi.s	.p_rew1
		move.b	d0,(a0)
.p_rew:	clr.w	mt_PatternPos
.p_rew1:moveq	#E_OK,d0
		rts


**********************************************************************
* Modfile testen (Format ?) und Name Åbertragen
* Weitere Tests werden in init_modfile gemacht.
test_modfile:
		movea.l mt_SongDataPtr(pc),a0
		moveq	#19,d1
.test1:	move.b	(a0)+,d0
		beq.s	.noascii
		bsr.s	.isascii
		tst.b	d0
		dbeq	d1,.test1				;bis 22 Zeichen maximal
		bne.s	.noascii
;Fehler -> keine Modfile
		moveq	#E_MODFILE,d0			;ERROR
		rts
.isascii:
		cmpi.b	#32,d0
		blt.s	.noascii
		rts
.noascii:
		moveq	#0,d0
		rts


; -----------------------------------------------------------------------
; Data:
; -----------------------------------------------------------------------
				data
;
; transitiondatas.
; first entry = next state if no operation failed
; next entries until 0 = actions to take
; last entry = 0 = end of commands
; final entry = -1 = end of state instruction block
;
transitiondata:
; 1. from state 0 - IDLE:
				dc.b P_STOPPED,X_LOAD,0 ;do load
				dc.b P_IDLE,0			;do free -> NOTHING!
				dc.b P_IDLE,0			;do play -> NOTHING!
				dc.b P_IDLE,0			;do pause-> NOTHING!
				dc.b P_IDLE,0			;do stop -> NOTHING!
				dc.b -1
; 2. from state 1 - STOPPED:
				dc.b P_STOPPED,X_FREE,X_LOAD,0 ;do load
				dc.b P_IDLE,X_FREE,0	;do free
				dc.b P_PLAYING,X_PLAY,0 ;do play
				dc.b P_PAUSED,0 		;do pause
				dc.b P_STOPPED,0		;do stop
				dc.b -1
; 3. from state 2 - PLAYING:
				dc.b P_PLAYING,X_STOP,X_FREE,X_LOAD,X_PLAY,0 ;do load
				dc.b P_IDLE,X_STOP,X_FREE,0 ;do free
				dc.b P_PLAYING,0		;do play
				dc.b P_PAUSED,X_STOP,0	;do pause
				dc.b P_STOPPED,X_STOP,X_RESET,0 ;do stop
				dc.b P_PLAYING,X_FF,0	;fast forward
				dc.b P_PLAYING,X_REW,0	;rewind
				dc.b P_INTERRUPTED,X_STOP,0  ;temp-stop for changing sfreq!
				dc.b -1
; 4. from state 3 - PAUSED:
				dc.b P_STOPPED,X_FREE,X_LOAD,0 ;do load
				dc.b P_IDLE,X_STOP,X_FREE,0 ;do free
				dc.b P_PLAYING,X_PLAY,0 ;do play
				dc.b P_PLAYING,X_PLAY,0 ;do pause
				dc.b P_STOPPED,X_RESET,0 ;do stop
				dc.b P_PAUSED,X_FF,0	;fast forward
				dc.b P_PAUSED,X_REW,0	;rewind
				dc.b -1
; 5. from state 4 - INTERRUPTED:
				dc.b P_INTERRUPTED,0	;load -> nope
				dc.b P_INTERRUPTED,0	;free -> nope
				dc.b P_INTERRUPTED,0	;play -> nope
				dc.b P_INTERRUPTED,0	;pause-> nope
				dc.b P_INTERRUPTED,0	;stop -> nope
				dc.b P_INTERRUPTED,0	;ff   -> nope
				dc.b P_INTERRUPTED,0	;rew  -> nope
				dc.b P_PLAYING,X_PLAY,0 ;unlock player
				dc.b -1
				even


; player state machine variables
p_state:			dc.w 0				;R-O

; replay-routine variables:
p_compatibility:	dc.w 1				;R/W 1 = Protracker mode
p_interpolate:		dc.w 0				;R/W !0=interpolate
p_repeat:			dc.w 0				;R/W Flag fÅr's Autorepeat
p_swapchannel:		dc.w 0				;R/W 0: LRRL, 1: RLLR

; chip emulator variables
p_chipclock:		dc.l AMIGACLOCK 	;R-O Amiga Chip Clock Frequency
p_samplefreq:		dc.w 2				;R-O Atari DMA Sound Frequency
p_framefreq:		dc.w 50 			;	 Frame Play Frequency
p_boost:			dc.w 0				;R/W Audio Boost?
p_cpuload:			dc.w 0				;R-O Rechenzeitverbrauch
p_overload: 		dc.w 0				;R-O öberlastung


; -----------------------------------------------------------------------
; noninitialized variables:
; -----------------------------------------------------------------------
					bss

modfile_name:		ds.l 1				;Zeiger auf Modfilenamen
realsamplefreq: 	ds.w 1				;sf in Hertz

; -----------------------------------------------------------------------
; end of file:
; -----------------------------------------------------------------------

