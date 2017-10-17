*************************************************************************
*
*  PTREPLAY.S
*  ----------
*
*  Protracker Replay Routine (Amiga)
*
*
*  bugfixes & extensions by P. Fellerich
*
*  last modified: 06-feb-1993
*
*************************************************************************

				include "pdefs.inc"

; -----------------------------------------------------------------------
; Globals:
; -----------------------------------------------------------------------
;
; exported Subroutines
;
				xdef mt_init			;Modfile initialization
				xdef mt_music			;VBL Sequencer
				xdef init_player		;reset player
;
; exported Variables:
;
				xdef mt_SongDataPtr
				xdef mt_SongEndPtr
				xdef mt_SongPos
				xdef mt_PatternPos
				xdef mt_SeqList
				xdef mt_ariadne
				xdef mt_ciaspeed
				
;
; imported Routines:
;
				xref exit_DMA_sound 	;from system.s
				xref p_set_ciaspeed
				
;
; imported Variables:
;
				xref p_compatibility	;from player.s
				xref p_repeat
				xref p_state
				xref AudioFrameSize
				xref AudioChannel1, AudioChannel2
				xref AudioChannel3, AudioChannel4


; -----------------------------------------------------------------------
; Internal Structure Definitions
; -----------------------------------------------------------------------

n_note			equ 0					; W
n_cmd			equ 2					; W
n_cmdlo 		equ 3					; B
n_start 		equ 4					; L
n_length		equ 8					; W
n_loopstart 	equ 10					; L
n_replen		equ 14					; W
n_period		equ 16					; W
n_finetune		equ 18					; B
n_volume		equ 19					; B
n_dmabit		equ 20					; W
n_toneportdirec equ 22					; B
n_toneportspeed equ 23					; B
n_wantedperiod	equ 24					; W
n_vibratocmd	equ 26					; B
n_vibratopos	equ 27					; B
n_tremolocmd	equ 28					; B
n_tremolopos	equ 29					; B
n_wavecontrol	equ 30					; B
n_glissfunk 	equ 31					; B
n_sampleoffset	equ 32					; B
n_pattpos		equ 33					; B
n_loopcount 	equ 34					; B
n_funkoffset	equ 35					; B
n_wavestart 	equ 36					; L
n_reallength	equ 40					; W
n_dmacontemp	equ 42					; B, padded to W
n_sizeof		equ 44



DEFVOL			equ 6

NOTECOUNT		equ 36			; 3 Oktaven


; -----------------------------------------------------------------------
; Code
; -----------------------------------------------------------------------
				text
;
; MOD-File ins richtige Format konvertieren:
;
mt_init:
		movem.l d3-d7/a3-a6,-(sp)
		move.l	mt_SongDataPtr(pc),d0
		beq.s	noinitmod
		movea.l d0,a0
		bsr.s	init_modfile
noinitmod:
		movem.l (sp)+,d3-d7/a3-a6
		rts
;
; Initialize the MODfile
; Param: a0: ptr to modfile
;
init_modfile:
		lea 	952(a0),a1				; sequencer list
		lea 	1084(a0),a2 			; Pattern Start
		sf		mt_15inst
		moveq	#31,d6
		cmpi.l	#'M.K.',1080(a0)		;Mahoney and Kaktus ?
		beq.s	mt_mkformat
		cmpi.l	#'FLT4',1080(a0)		;Fairlight 4 ??
		beq.s	mt_mkformat
;
; It's the old soundtracker format!
; compensate errors of old SoundTracker's:
;
; 1. Repeat-from value may be $78 (erroneous)
; 2. 'Repeat-start' value in sample-data struct is in bytes, not words.
; 3. set the 15inst mode variable
;
		st		mt_15inst
		lea 	472(a0),a1				;indicate offsets
		lea 	600(a0),a2
		moveq	#14,d0
		lea 	20(a0),a3
mt_st_err1:
		lsr.w	INS_REP(a3) 			;REP in bytes -> to words!
		lea 	30(a3),a3
		dbra	d0,mt_st_err1
		moveq	#15,d6
mt_mkformat:							;takeover the user def'd variable
		move.l	a1,mt_SeqList
		move.l	a2,mt_PatList
		move.b	-1(a1),d0				;Repeat From-value
		cmp.b	-2(a1),d0				;cmp to seqlen!
		blo.s	mt_st_err				;OK, repeat_from < seq_len
		clr.b	-1(a1)					;else repeat from 0
mt_st_err:
		moveq	#127,d0
		moveq	#0,d1
mt_loop:move.l	d1,d2
		subq.w	#1,d0
mt_loop1:
		move.b	(a1)+,d1				;find number of patterns
		cmp.b	d2,d1
		bgt.s	mt_loop
		dbra	d0,mt_loop1
		addq.b	#1,d2					;d2: number of patterns
;
; Set Samples:
;
		lea 	mt_SampleStarts(pc),a1
		asl.l	#8,d2
		asl.l	#2,d2					;patcount *1024
		lea 	0(a2,d2.l),a2			;First Sample Start Address

; check if this is still in range of the MOD, else we risk getting a
; memory violation error under MultiTOS
		cmpa.l	mt_SongEndPtr(pc),a2	;aužerhalb?
		bhi 	mt_error				;falls nicht -> ok!

		movea.l a1,a3
		moveq	#30,d0
mt_loop2:
		clr.l	(a3)+					;Clear all instrument pointers!
		dbra	d0,mt_loop2

		lea 	20(a0),a0				;Ptr to first instrument entry
		move.w	d6,d0					;Instrument Count
		subq.w	#1,d0
		bmi 	mt_error
mt_loop3:
;		clr.l	(a2)					;clear first long word of spl (why?)
		clr.b	1(a2)					;!!! Memory Violation if not checked !!!
		move.l	a2,(a1)+				;save sample start

		move.b	4(a2),d3				;re-interpolate bytes 1..3 !!
		ext.w	d3
		ext.l	d3						;this eliminates click noises!
		move.l	d3,d4
		divs	#3,d3
		move.b	d3,2(a2)
		add.l	d4,d4
		divs	#3,d4
		move.b	d4,3(a2)
		moveq	#0,d1
		move.w	INS_SLEN(a0),d1 		;Sample length in words
		move.w	INS_REP(a0),d2
		moveq	#0,d3
		move.w	d2,d3
		add.l	d3,d3					;to bytes...
		add.w	INS_REPLEN(a0),d2
		cmp.w	d2,d1
		bcc.s	mt_loop4
		move.w	d1,d2
		sub.w	INS_REP(a0),d2			;repeat value out of bounds
		bmi.s	mt_splerr
		move.w	d2,INS_REPLEN(a0)
		bra.s	mt_loop4
mt_splerr:
		clr.w	INS_REP(a0) 			;kein repeat!
		clr.w	INS_REPLEN(a0)
mt_loop4:
		asl.l	#1,d1					;words to bytes

		cmpi.w	#1,INS_REPLEN(a0)		;repeat allowed?
		bls.s	mt_loop5				;no ...
		move.b	0(a2,d3.l),0(a2,d1.l)	;copy byte @loop-point (interpol.)
mt_loop5:
		adda.l	d1,a2					;Ptr to next sample
		lea 	30(a0),a0				; (INST *)iptr++;
		cmpa.l	mt_SongEndPtr(pc),a2	; Sample noch in der Datei?
		dbhs	d0,mt_loop3
		bhi.s	mt_error				;alles OK
; Jetzt testen, ob wir am ENDE des Mods angekommen sind.
; Maximal tolerierte šberl„nge = 256 byte
		lea 	256(a2),a2
		cmpa.l	mt_SongEndPtr(pc),a2	;jetzt aužerhalb??
		blo.s	mt_error				;falls nicht -> Fehler!
		moveq	#E_OK,d0
		bra.s	init_player
mt_error:
		moveq	#E_MODFILE,d0
		rts

init_player:
		move.b	#DEFVOL,mt_speed		;* default speed
		move.w	#125,d0					;*
		move.w	d0,mt_ciaspeed			;*
		bsr		p_set_ciaspeed			;* program it!
		clr.w	mt_Counter				;* clear position indicators
		clr.b	mt_SongPos
		clr.w	mt_PatternPos
		lea 	mt_chan1temp(pc),a0
		bsr.s	mt_clearvoice
		lea 	mt_chan2temp(pc),a0
		bsr.s	mt_clearvoice
		lea 	mt_chan3temp(pc),a0
		bsr.s	mt_clearvoice
		lea 	mt_chan4temp(pc),a0
		bsr.s	mt_clearvoice

mt_end: clr.l	AudioChannel1
		clr.w	AudioChannel1+AUD_STATE
		clr.l	AudioChannel2
		clr.w	AudioChannel2+AUD_STATE
		clr.l	AudioChannel3
		clr.w	AudioChannel3+AUD_STATE
		clr.l	AudioChannel4
		clr.w	AudioChannel4+AUD_STATE
		lea 	mt_ariadne(pc),a0
		movea.l a0,a1
		moveq	#(128/4)-1,d0
mt_end1:clr.l	(a0)+					;noch nichts gespielt!
		dbra	d0,mt_end1
		st		(a1)					;...aužer Pattern 1
		moveq	#E_OK,d0				;alles paletti
		rts

mt_clearvoice:
		moveq	#(n_sizeof/2)-1,d1
mt_clrvloop:
		clr.w	(a0)+
		dbra	d1,mt_clrvloop
		rts


; Original Code:
;********************************************
;* ----- Protracker V1.1B Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1991	*
;* Bekkeliveien 10, N-2010 STRØMMEN, Norway *
;********************************************
; with modifications from:
;**************************************************
;*	  ----- Protracker V2.1A Playroutine -----	  *
;* Peter "CRAYON" Hanning / Mushroom Studios 1992 *
;*	  Vinterstigen 12, 14440 Ronninge, Sweden	  *
;**************************************************
; as well as BUGFIXES (!!!) by myself (marked by ;* )
;
; The 'VBL'-Sequencer
;
mt_music:
		move.b	p_compatibility+1(pc),mt_no_protracker ;* user option
		move.b	mt_15inst(pc),d0		;* is it a 15 instrument module?
		beq.s	.newformat				;* nope
		sf		mt_no_protracker		;* if yes -> never user protracker mode
.newformat:		
		move.l	a6,-(sp)
		addq.b	#1,mt_Counter
		move.b	mt_Counter(pc),d0
		cmp.b	mt_speed(pc),d0
		blo.s	mt_NoNewNote
		clr.b	mt_Counter
		tst.b	mt_PattDelTime2
		beq.s	mt_GetNewNote
		bsr.s	mt_NoNewAllChannels
		bra 	mt_dskip

mt_NoNewNote:
		bsr.s	mt_NoNewAllChannels
		bra 	mt_NoNewPosYet

mt_NoNewAllChannels:
		lea 	AudioChannel1(pc),a5
		lea 	mt_chan1temp(pc),a6
		bsr 	mt_CheckEfx
		lea 	AudioChannel2(pc),a5
		lea 	mt_chan2temp(pc),a6
		bsr 	mt_CheckEfx
		lea 	AudioChannel3(pc),a5
		lea 	mt_chan3temp(pc),a6
		bsr 	mt_CheckEfx
		lea 	AudioChannel4(pc),a5
		lea 	mt_chan4temp(pc),a6
		bra 	mt_CheckEfx

mt_GetNewNote:
		movea.l mt_SongDataPtr(pc),a0
		lea 	20(a0),a3				;first instrument entry
		movea.l mt_SeqList(pc),a2		;pattpos
		movea.l mt_PatList(pc),a0		;patterndata
		moveq	#0,d0
		moveq	#0,d1
		move.b	mt_SongPos(pc),d0
		move.b	0(a2,d0.w),d1			;get pattern index
		asl.l	#8,d1
		asl.l	#2,d1					;*1024
		add.w	mt_PatternPos(pc),d1	;Position im Pattern

		lea 	AudioChannel1(pc),a5	;Amiga Registers
		lea 	mt_chan1temp(pc),a6
		bsr.s	mt_MakeVoice
		lea 	AudioChannel2(pc),a5
		lea 	mt_chan2temp(pc),a6
		bsr.s	mt_MakeVoice
		lea 	AudioChannel3(pc),a5
		lea 	mt_chan3temp(pc),a6
		bsr.s	mt_MakeVoice
		lea 	AudioChannel4(pc),a5
		lea 	mt_chan4temp(pc),a6
		bsr.s	mt_MakeVoice
		bra 	mt_SetDMA

; To save code...
mt_MakeVoice:
		sf		n_dmacontemp(a6)				;* 'DMA off'
		bsr.s	mt_PlayVoice					;the interpreter.
		move.l	n_loopstart(a6),AUD_LSTART(a5)	;* Set Loopstart
		move.w	n_replen(a6),AUD_LLEN(a5)		;* Set RepLen
		tst.b	n_dmacontemp(a6)				;* DMACONtemp 'bit' set?
		beq.s	mt_nolaunch						;* nope, no DMA
		bmi.s	mt_launch_only					;* NegFlag?
		move.l	n_start(a6),AUD_START(a5)		;* Set start
		move.w	n_length(a6),AUD_LEN(a5)		;* Set length
		move.w	n_period(a6),AUD_PER(a5)		;* Set period
mt_launch_only:
		clr.w	AUD_STATE(a5)					;* launch DMA
mt_nolaunch:									;*
		rts										;*

mt_PlayVoice:
		tst.l	(a6)					;empty command -> do nothing
		bne.s	mt_plvskip
		move.w	n_period(a6),AUD_PER(a5)
mt_plvskip:
		move.l	0(a0,d1.l),(a6)
		addq.l	#4,d1
		moveq	#0,d2
		move.b	n_cmd(a6),d2
		and.b	#$F0,d2
		lsr.b	#4,d2
		move.b	(a6),d0
		and.b	#$10,d0 				;and.b	   #$F0,d0
		or.b	d0,d2
		beq 	mt_SetRegs				;NO new instrument!
		moveq	#0,d3
		lea 	mt_SampleStarts(pc),a1
		subq.l	#1,d2
		move.w	d2,d4					;Instrument Number 0..30
		asl.l	#2,d2					;offset 0..120
		mulu	#30,d4					; * sizeof(INST)

;		move.l	0(a1,d2.l),n_start(a6)	;get new instrument data
		move.l	0(a1,d2.l),d0			;* get sample address
		cmp.l	n_start(a6),d0			;* same sample as currently running
		beq.s	mt_noemulreload			;*
		move.b	#1,n_dmacontemp(a6)		;* no -> EMUL must reload it!
mt_noemulreload:						;*
		move.l	d0,n_start(a6)			;* store it.

		move.w	22(a3,d4.l),n_length(a6)
		move.w	22(a3,d4.l),n_reallength(a6)
		move.b	24(a3,d4.l),n_finetune(a6)
		move.b	25(a3,d4.l),n_volume(a6)
		move.w	26(a3,d4.l),d3			; Get repeat
		beq.s	mt_NoLoop
		move.l	n_start(a6),d2			; Get start
		add.w	d3,d3
		add.l	d3,d2					; Add repeat
		move.l	d2,n_loopstart(a6)
		move.l	d2,n_wavestart(a6)
		move.w	26(a3,d4.l),d0			; Get repeat
		add.w	28(a3,d4.l),d0			; Add replen
		move.w	d0,n_length(a6)
		move.w	28(a3,d4.l),n_replen(a6) ; Save replen
		moveq	#0,d0
		move.b	n_volume(a6),d0
		move.w	d0,AUD_VOL(a5)			 ; Set volume
		bra.s	mt_SetRegs

mt_NoLoop:
		move.l	n_start(a6),d2
		add.l	d3,d2
		move.l	d2,n_loopstart(a6)
		move.l	d2,n_wavestart(a6)
		move.w	28(a3,d4.l),n_replen(a6) ; Save replen
		moveq	#0,d0
		move.b	n_volume(a6),d0
		move.w	d0,AUD_VOL(a5)			; Set volume
mt_SetRegs:
		move.w	(a6),d0
		and.w	#$0FFF,d0
		beq 	mt_CheckMoreEfx 		; If no note...
		move.w	2(a6),d0
		and.w	#$0FF0,d0
		cmp.w	#$0E50,d0
		beq.s	mt_DoSetFineTune
		move.b	2(a6),d0
		and.b	#$0F,d0
		cmp.b	#3,d0					; TonePortamento
		beq.s	mt_ChkTonePorta			
		cmp.b	#5,d0
		beq.s	mt_ChkTonePorta
		cmp.b	#9,d0
		bne.s	mt_SetPeriod			; reload
		bsr 	mt_CheckMoreEfx 		; Sample Offset?
		bra.s	mt_SetPeriod

mt_DoSetFineTune:
		bsr 	mt_SetFineTune
		bra.s	mt_SetPeriod

mt_ChkTonePorta:
		sf		n_dmacontemp(a6)		;no reload trigger....
		bsr 	mt_SetTonePorta
		bra 	mt_CheckMoreEfx

mt_SetPeriod:
;*--------------------------------------;* new finetuneloop routine 29/01/93
		movem.l d0-d1/a0-a1,-(sp)
		move.w	(a6),d1					; get note
		and.w	#$0FFF,d1				; isolate period value
		cmpi.w	#1024,d1				; max. period for Emulator
		blt.s	.skip1
		move.w	#1023,d1				; period=MIN(period,1023)
.skip1:	move.b	mt_no_protracker(pc),d0	; Protracker mode?
		beq.s	.exit					; Noisetracker -> no finetune
		tst.b	n_finetune(a6)			; Detuning active?
		beq.s	.exit					; no -> original period
		moveq	#NOTECOUNT-1,d7			; Note index
		lea 	mt_PeriodTable(pc),a1
.while:	cmp.w	(a1)+,d1				; Find period value
		beq.s	.found_period
		dbhi	d7,.while				; loop counter etc.
		bra.s	.exit					; nothing found -> use standard!
.found_period:
		moveq	#0,d1					; hole den 'detune' index
		move.b	n_finetune(a6),d1
		mulu	#NOTECOUNT*2,d1 		; 2 weil words!
		move.w	-2(a1,d1.w),d1
.exit:	move.w	d1,n_period(a6)			; period writeback
		movem.l (sp)+,d0-d1/a0-a1
;*--------------------------------------;*

		move.w	2(a6),d0				;commandword
		and.w	#$0FF0,d0
		cmp.w	#$0ED0,d0				; Notedelay?
		beq 	mt_CheckMoreEfx

		move.w	#STOPPED,AUD_STATE(a5)	;* original: clear DMACON-Channel
		btst	#2,n_wavecontrol(a6)
		bne.s	mt_vibnoc
		clr.b	n_vibratopos(a6)
mt_vibnoc:
		btst	#6,n_wavecontrol(a6)
		bne.s	mt_trenoc
		clr.b	n_tremolopos(a6)
mt_trenoc:
		move.l	n_start(a6),AUD_START(a5)		; Set start
		move.w	n_length(a6),AUD_LEN(a5)		; Set length
		move.w	n_period(a6),AUD_PER(a5)		; Set period
		st		n_dmacontemp(a6)				; DMACONtemp set
		bra 	mt_CheckMoreEfx

;
; Program the amiga soundchip:
;
mt_SetDMA:
;----- nothing to do. The Amiga chip is programmed here with the repeat values.
mt_dskip:
		addi.w	#16,mt_PatternPos
		move.b	mt_PattDelTime(pc),d0
		beq.s	mt_dskc
		move.b	d0,mt_PattDelTime2
		clr.b	mt_PattDelTime
mt_dskc:tst.b	mt_PattDelTime2
		beq.s	mt_dska
		subq.b	#1,mt_PattDelTime2
		beq.s	mt_dska
		subi.w	#16,mt_PatternPos
mt_dska:tst.b	mt_PBreakFlag
		beq.s	mt_nnpysk
		sf		mt_PBreakFlag
		moveq	#0,d0
		move.b	mt_PBreakPos(pc),d0
		clr.b	mt_PBreakPos
		lsl.w	#4,d0
		move.w	d0,mt_PatternPos
mt_nnpysk:
		cmpi.w	#1024,mt_PatternPos
		blo.s	mt_NoNewPosYet
mt_NextPosition:
		moveq	#0,d0
		move.b	mt_PBreakPos(pc),d0
		lsl.w	#4,d0
		move.w	d0,mt_PatternPos
		clr.b	mt_PBreakPos
		clr.b	mt_PosJumpFlag
		addq.b	#1,mt_SongPos
		andi.b	#$7F,mt_SongPos
		move.b	mt_SongPos(pc),d1

		move.w	p_repeat(pc),d0 		;* PAULA-Flag testen!
		bne.s	mt_notrap				;* don't catch repeat...
		lea 	mt_ariadne(pc),a0		;*
		ext.w	d1						;*
		tas.b	0(a0,d1.w)				;* schon dagewesen?
		bne.s	mt_halt 				;* ja -> break!
mt_notrap:								;*

		movea.l mt_SeqList(pc),a0
		cmp.b	-2(a0),d1				;seqlen: Ende der Liste erreicht?
		blo.s	mt_NoNewPosYet
****************************************
*
; hier repeat flag auswerten:
		tst.w	d0						;PAULArepeatFlag testen!
		bne.s	mt_dorepeat
; Anhalten - stop & Reset everything!:
mt_halt:
		clr.b	mt_SongPos
		bsr 	mt_end					;Reset Chip
; Stop - durch ein $F00-Kommando: 
mt_stop:
		move.w	#P_STOPPED,p_state		;state machine fr Tastenfeld
		bsr 	exit_DMA_sound			;Stop the Chip....
		bra.s	mt_goodbye
mt_dorepeat:
*
****************************************
;		   clr.b	 mt_SongPos 		; Fehler...
		move.b	-1(a0),mt_SongPos		;* so sollte es sein.
mt_NoNewPosYet:
		tst.b	mt_PosJumpFlag
		bne.s	mt_NextPosition
mt_goodbye:
		movea.l (sp)+,a6
		rts
mt_pause:
		move.w	#P_PAUSED,p_state		;state machine fr Tastenfeld
		bsr 	exit_DMA_sound			;Stop the Chip....
		bra.s	mt_goodbye
		
mt_CheckEfx:
		bsr 	mt_UpdateFunk
		move.w	n_cmd(a6),d0
		and.w	#$0FFF,d0
		beq.s	mt_PerNop
		move.b	n_cmd(a6),d0
		and.b	#$0F,d0
		beq.s	mt_Arpeggio
		cmp.b	#1,d0
		beq 	mt_PortaUp
		cmp.b	#2,d0
		beq 	mt_PortaDown
		cmp.b	#3,d0
		beq 	mt_TonePortamento
		cmp.b	#4,d0
		beq 	mt_Vibrato
		cmp.b	#5,d0
		beq 	mt_TonePlusVolSlide
		cmp.b	#6,d0
		beq 	mt_VibratoPlusVolSlide
		cmp.b	#$0E,d0
		beq 	mt_E_Commands
SetBack:move.w	n_period(a6),AUD_PER(a5)
		cmp.b	#7,d0
		beq 	mt_Tremolo
		cmp.b	#$0A,d0
		beq 	mt_VolumeSlide
mt_Return2:
		rts

mt_PerNop:
		move.w	n_period(a6),AUD_PER(a5)
		rts

mt_Arpeggio:
		moveq	#0,d0
		move.b	mt_Counter(pc),d0
		divs	#3,d0
		swap	d0
		cmp.w	#0,d0
		beq.s	mt_Arpeggio2
		cmp.w	#2,d0
		beq.s	mt_Arpeggio1
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		lsr.b	#4,d0
		bra.s	mt_Arpeggio3

mt_Arpeggio1:
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		and.b	#15,d0
		bra.s	mt_Arpeggio3

mt_Arpeggio2:
		move.w	n_period(a6),d2
		bra.s	mt_Arpeggio4

mt_Arpeggio3:
		add.w	d0,d0
		moveq	#0,d1
		move.b	n_finetune(a6),d1
		mulu	#NOTECOUNT*2,d1
		lea 	mt_PeriodTable(pc),a0
		adda.l	d1,a0
		moveq	#0,d1
		move.w	n_period(a6),d1
		moveq	#NOTECOUNT,d7
mt_arploop:
		move.w	0(a0,d0.w),d2
		cmp.w	(a0),d1
		bhs.s	mt_Arpeggio4
		addq.l	#2,a0
		dbra	d7,mt_arploop
		rts

mt_Arpeggio4:
		move.w	d2,AUD_PER(a5)
		rts

mt_FinePortaUp:
		tst.b	mt_Counter
		bne.s	mt_Return2
		move.b	#$0F,mt_LowMask
mt_PortaUp:
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		and.b	mt_LowMask(pc),d0
		move.b	#$FF,mt_LowMask
		sub.w	d0,n_period(a6)
		move.w	n_period(a6),d0
		and.w	#$0FFF,d0
		cmp.w	#113,d0
		bpl.s	mt_PortaUskip
		andi.w	#$F000,n_period(a6)
		ori.w	#113,n_period(a6)
mt_PortaUskip:
		move.w	n_period(a6),d0
		and.w	#$0FFF,d0
		move.w	d0,AUD_PER(a5)
		rts

mt_FinePortaDown:
		tst.b	mt_Counter
		bne 	mt_Return2
		move.b	#$0F,mt_LowMask
mt_PortaDown:
		clr.w	d0
		move.b	n_cmdlo(a6),d0
		and.b	mt_LowMask(pc),d0
		move.b	#$FF,mt_LowMask
		add.w	d0,n_period(a6)
		move.w	n_period(a6),d0
		and.w	#$0FFF,d0
		cmp.w	#856,d0
		bmi.s	mt_PortaDskip
		andi.w	#$F000,n_period(a6)
		ori.w	#856,n_period(a6)
mt_PortaDskip:
		move.w	n_period(a6),d0
		and.w	#$0FFF,d0
		move.w	d0,AUD_PER(a5)
		rts

mt_SetTonePorta:
		move.l	a0,-(sp)
		move.w	(a6),d2
		and.w	#$0FFF,d2
		moveq	#0,d0
		move.b	n_finetune(a6),d0
		mulu	#(NOTECOUNT+1)*2,d0
		lea 	mt_PeriodTable(pc),a0
		adda.l	d0,a0
		moveq	#0,d0
mt_StpLoop:
		cmp.w	0(a0,d0.w),d2
		bhs.s	mt_StpFound
		addq.w	#2,d0
		cmp.w	#(NOTECOUNT+1)*2,d0
		blo.s	mt_StpLoop
		moveq	#(NOTECOUNT-1)*2,d0
mt_StpFound:
		move.b	n_finetune(a6),d2
		and.b	#8,d2
		beq.s	mt_StpGoss
		tst.w	d0
		beq.s	mt_StpGoss
		subq.w	#2,d0
mt_StpGoss:
		move.w	0(a0,d0.w),d2
		movea.l (sp)+,a0
		move.w	d2,n_wantedperiod(a6)
		move.w	n_period(a6),d0
		clr.b	n_toneportdirec(a6)
		cmp.w	d0,d2
		beq.s	mt_ClearTonePorta
		bge 	mt_Return2
		move.b	#1,n_toneportdirec(a6)
		rts

mt_ClearTonePorta:
		clr.w	n_wantedperiod(a6)
		rts

mt_TonePortamento:
		move.b	n_cmdlo(a6),d0
		beq.s	mt_TonePortNoChange
		move.b	d0,n_toneportspeed(a6)
		clr.b	n_cmdlo(a6)
mt_TonePortNoChange:
		tst.w	n_wantedperiod(a6)
		beq 	mt_Return2
		moveq	#0,d0
		move.b	n_toneportspeed(a6),d0
		tst.b	n_toneportdirec(a6)
		bne.s	mt_TonePortaUp
mt_TonePortaDown:
		add.w	d0,n_period(a6)
		move.w	n_wantedperiod(a6),d0
		cmp.w	n_period(a6),d0
		bgt.s	mt_TonePortaSetPer
		move.w	n_wantedperiod(a6),n_period(a6)
		clr.w	n_wantedperiod(a6)
		bra.s	mt_TonePortaSetPer

mt_TonePortaUp:
		sub.w	d0,n_period(a6)
		move.w	n_wantedperiod(a6),d0
		cmp.w	n_period(a6),d0
		blt.s	mt_TonePortaSetPer
		move.w	n_wantedperiod(a6),n_period(a6)
		clr.w	n_wantedperiod(a6)

mt_TonePortaSetPer:
		move.w	n_period(a6),d2
		move.b	n_glissfunk(a6),d0
		and.b	#$0F,d0
		beq.s	mt_GlissSkip
		moveq	#0,d0
		move.b	n_finetune(a6),d0
		mulu	#NOTECOUNT*2,d0
		lea 	mt_PeriodTable(pc),a0
		adda.l	d0,a0
		moveq	#0,d0
mt_GlissLoop:
		cmp.w	0(a0,d0.w),d2
		bhs.s	mt_GlissFound
		addq.w	#2,d0
		cmp.w	#NOTECOUNT*2,d0
		blo.s	mt_GlissLoop
		moveq	#(NOTECOUNT-1)*2,d0
mt_GlissFound:
		move.w	0(a0,d0.w),d2
mt_GlissSkip:
		move.w	d2,AUD_PER(a5)					; Set period
		rts

mt_Vibrato:
		move.b	n_cmdlo(a6),d0
		beq.s	mt_Vibrato2
		move.b	n_vibratocmd(a6),d2
		and.b	#$0F,d0
		beq.s	mt_vibskip
		and.b	#$F0,d2
		or.b	d0,d2
mt_vibskip:
		move.b	n_cmdlo(a6),d0
		and.b	#$F0,d0
		beq.s	mt_vibskip2
		and.b	#$0F,d2
		or.b	d0,d2
mt_vibskip2:
		move.b	d2,n_vibratocmd(a6)
mt_Vibrato2:
		move.b	n_vibratopos(a6),d0
		lea 	mt_VibratoTable(pc),a4
		lsr.w	#2,d0
		and.w	#$1F,d0
		moveq	#0,d2
		move.b	n_wavecontrol(a6),d2
		and.b	#$03,d2
		beq.s	mt_vib_sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	mt_vib_rampdown
		move.b	#255,d2
		bra.s	mt_vib_set
mt_vib_rampdown:
		tst.b	n_vibratopos(a6)
		bpl.s	mt_vib_rampdown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	mt_vib_set
mt_vib_rampdown2:
		move.b	d0,d2
		bra.s	mt_vib_set
mt_vib_sine:
		move.b	0(a4,d0.w),d2
mt_vib_set:
		move.b	n_vibratocmd(a6),d0
		and.w	#15,d0
		mulu	d0,d2
		lsr.w	#7,d2
		move.w	n_period(a6),d0
		tst.b	n_vibratopos(a6)
		bmi.s	mt_VibratoNeg
		add.w	d2,d0
		bra.s	mt_Vibrato3
mt_VibratoNeg:
		sub.w	d2,d0
mt_Vibrato3:
		move.w	d0,AUD_PER(a5)
		move.b	n_vibratocmd(a6),d0
		lsr.w	#2,d0
		and.w	#$3C,d0
		add.b	d0,n_vibratopos(a6)
		rts

mt_TonePlusVolSlide:
		bsr 	mt_TonePortNoChange
		bra 	mt_VolumeSlide

mt_VibratoPlusVolSlide:
		bsr.s	mt_Vibrato2
		bra 	mt_VolumeSlide

mt_Tremolo:
		move.b	n_cmdlo(a6),d0
		beq.s	mt_Tremolo2
		move.b	n_tremolocmd(a6),d2
		and.b	#$0F,d0
		beq.s	mt_treskip
		and.b	#$F0,d2
		or.b	d0,d2
mt_treskip:
		move.b	n_cmdlo(a6),d0
		and.b	#$F0,d0
		beq.s	mt_treskip2
		and.b	#$0F,d2
		or.b	d0,d2
mt_treskip2:
		move.b	d2,n_tremolocmd(a6)
mt_Tremolo2:
		move.b	n_tremolopos(a6),d0
		lea 	mt_VibratoTable(pc),a4
		lsr.w	#2,d0
		and.w	#$1F,d0
		moveq	#0,d2
		move.b	n_wavecontrol(a6),d2
		lsr.b	#4,d2
		and.b	#$03,d2
		beq.s	mt_tre_sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	mt_tre_rampdown
		move.b	#255,d2
		bra.s	mt_tre_set
mt_tre_rampdown:
		tst.b	n_vibratopos(a6)
		bpl.s	mt_tre_rampdown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	mt_tre_set
mt_tre_rampdown2:
		move.b	d0,d2
		bra.s	mt_tre_set
mt_tre_sine:
		move.b	0(a4,d0.w),d2
mt_tre_set:
		move.b	n_tremolocmd(a6),d0
		and.w	#15,d0
		mulu	d0,d2
		lsr.w	#6,d2
		moveq	#0,d0
		move.b	n_volume(a6),d0
		tst.b	n_tremolopos(a6)
		bmi.s	mt_TremoloNeg
		add.w	d2,d0
		bra.s	mt_Tremolo3
mt_TremoloNeg:
		sub.w	d2,d0
mt_Tremolo3:
		bpl.s	mt_TremoloSkip
		clr.w	d0
mt_TremoloSkip:
		cmp.w	#$40,d0
		bls.s	mt_TremoloOk
		move.w	#$40,d0
mt_TremoloOk:
		move.w	d0,AUD_VOL(a5)
		move.b	n_tremolocmd(a6),d0
		lsr.w	#2,d0
		and.w	#$3C,d0
		add.b	d0,n_tremolopos(a6)
		rts

mt_SampleOffset:
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		beq.s	mt_sononew
		move.b	d0,n_sampleoffset(a6)
mt_sononew:
		move.b	n_sampleoffset(a6),d0
		lsl.w	#7,d0
		cmp.w	n_length(a6),d0
		bge.s	mt_sofskip
		sub.w	d0,n_length(a6)
		add.w	d0,d0
		add.l	d0,n_start(a6)
		rts
mt_sofskip:
		move.w	#$01,n_length(a6)
		rts

mt_VolumeSlide:
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		lsr.b	#4,d0
		tst.b	d0
		beq.s	mt_VolSlideDown
mt_VolSlideUp:
		add.b	d0,n_volume(a6)
		cmpi.b	#$40,n_volume(a6)
		bmi.s	mt_vsuskip
		move.b	#$40,n_volume(a6)
mt_vsuskip:
		move.b	n_volume(a6),d0
		move.w	d0,AUD_VOL(a5)
		rts

mt_VolSlideDown:
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
mt_VolSlideDown2:
		sub.b	d0,n_volume(a6)
		bpl.s	mt_vsdskip
		clr.b	n_volume(a6)
mt_vsdskip:
		move.b	n_volume(a6),d0
		move.w	d0,AUD_VOL(a5)
		rts

mt_PositionJump:
		move.b	n_cmdlo(a6),d0
		subq.b	#1,d0
		move.b	d0,mt_SongPos
mt_pj2: clr.b	mt_PBreakPos
		st		mt_PosJumpFlag
		rts

mt_VolumeChange:
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		cmp.b	#$40,d0
		bls.s	mt_VolumeOk
		moveq	#$40,d0
mt_VolumeOk:
		move.b	d0,n_volume(a6)
		move.w	d0,AUD_VOL(a5)
		rts

mt_PatternBreak:
		moveq	#0,d0
		tst.b	mt_no_protracker 		;* new
		beq.s	mt_oldPatBreak			;* new
		move.b	n_cmdlo(a6),d0
mt_oldPatBreak: 						;* new
		move.l	d0,d2
		lsr.b	#4,d0
		mulu	#10,d0
		and.b	#$0F,d2
		add.b	d2,d0
		cmp.b	#63,d0
		bhi.s	mt_pj2
		move.b	d0,mt_PBreakPos
		st		mt_PosJumpFlag
		rts


mt_CheckMoreEfx:
		bsr 	mt_UpdateFunk
		move.b	2(a6),d0
		and.b	#$0F,d0
		cmp.b	#$09,d0
		beq 	mt_SampleOffset
		cmp.b	#$0B,d0
		beq.s	mt_PositionJump
		cmp.b	#$0D,d0
		beq.s	mt_PatternBreak
		cmp.b	#$0E,d0
		beq.s	mt_E_Commands
		cmp.b	#$0F,d0
		beq.s	mt_SetSpeed
		cmp.b	#$0C,d0
		beq.s	mt_VolumeChange
		bra 	mt_PerNop

;
; adapted to new CIA timing 25/01/1993
;
mt_SetSpeed:
		moveq	#0,d0
		tst.b	mt_no_protracker		;* Protracker mode ??
		beq.s	.oldspeed 				;*
		move.b	3(a6),d0				; get infobyte
		beq		mt_pause
		cmp.b	#32,d0					;Ticks oder BPM?
		bhs.s	mt_set_tempo
		clr.b	mt_Counter
		move.b	d0,mt_speed
		rts
.oldspeed:								;* no CIA timing!
		move.b	3(a6),d0				; get infobyte
		beq.s	.do_nothing				; null -> ignorieren
		move.w	#125,mt_ciaspeed
		clr.b	mt_Counter
		cmpi.b	#32,d0
		bls.s	.keep_it
		move.b	#32,d0
.keep_it:
		move.b	d0,mt_speed				; set speed using...
.do_nothing:
		moveq	#125,d0					; ...p_set_ciaspeed(speed)
		bra		p_set_ciaspeed
;		rts

mt_set_tempo:
		move.w	d0,mt_ciaspeed
		bra		p_set_ciaspeed
;		rts

;_____

mt_E_Commands:
		tst.b	mt_no_protracker 				;* Abschaltbar!
		beq		mt_PerNop						;* neu!
		move.b	n_cmdlo(a6),d0
		and.w	#$F0,d0
		lsr.b	#4-1,d0 						;* optimierte Version,
		lea 	mt_E_jump1(pc),a2				;* weniger Speicher,
		adda.w	(a2,d0),a2						;* schneller
		jmp 	(a2)							;*
mt_E_jump1: 									;*
		dc.w	mt_FilterOnOff-mt_E_jump1		;* E0
		dc.w	mt_FinePortaUp-mt_E_jump1		;* E1
		dc.w	mt_FinePortaDown-mt_E_jump1 	;* E2
		dc.w	mt_SetGlissControl-mt_E_jump1	;* E3
		dc.w	mt_SetVibratoControl-mt_E_jump1 ;* E4
		dc.w	mt_SetFineTune-mt_E_jump1		;* E5
		dc.w	mt_JumpLoop-mt_E_jump1			;* E6
		dc.w	mt_SetTremoloControl-mt_E_jump1 ;* E7
		dc.w	mt_NoOp-mt_E_jump1				;* E8
		dc.w	mt_RetrigNote-mt_E_jump1		;* E9
		dc.w	mt_VolumeFineUp-mt_E_jump1		;* EA
		dc.w	mt_VolumeFineDown-mt_E_jump1	;* EB
		dc.w	mt_NoteCut-mt_E_jump1			;* EC
		dc.w	mt_NoteDelay-mt_E_jump1 		;* ED
		dc.w	mt_PatternDelay-mt_E_jump1		;* EE
		dc.w	mt_FunkIt-mt_E_jump1			;* EF
mt_FilterOnOff:
		;* this could possibly be used to enable/disable the interpolation flag
mt_NoOp:
		rts


mt_SetGlissControl:
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		andi.b	#$F0,n_glissfunk(a6)
		or.b	d0,n_glissfunk(a6)
		rts

mt_SetVibratoControl:
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		andi.b	#$F0,n_wavecontrol(a6)
		or.b	d0,n_wavecontrol(a6)
		rts

mt_SetFineTune:
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		move.b	d0,n_finetune(a6)
		rts

mt_JumpLoop:
		tst.b	mt_Counter
		bne 	mt_Return2
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		beq.s	mt_SetLoop
		tst.b	n_loopcount(a6)
		beq.s	mt_jumpcnt
		subq.b	#1,n_loopcount(a6)
		beq 	mt_Return2
mt_jmploop:
		move.b	n_pattpos(a6),mt_PBreakPos
		st		mt_PBreakFlag
		rts

mt_jumpcnt:
		move.b	d0,n_loopcount(a6)
		bra.s	mt_jmploop

mt_SetLoop:
		move.w	mt_PatternPos(pc),d0
		lsr.w	#4,d0
		move.b	d0,n_pattpos(a6)
		rts

mt_SetTremoloControl:
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		lsl.b	#4,d0
		andi.b	#$0F,n_wavecontrol(a6)
		or.b	d0,n_wavecontrol(a6)
		rts

mt_RetrigNote:
		move.l	d1,-(sp)
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		beq.s	mt_rtnend
		moveq	#0,d1
		move.b	mt_Counter(pc),d1
		bne.s	mt_rtnskp
		move.w	(a6),d1
		and.w	#$0FFF,d1
		bne.s	mt_rtnend
		moveq	#0,d1
		move.b	mt_Counter(pc),d1
mt_rtnskp:
		divu	d0,d1
		swap	d1
		tst.w	d1
		bne.s	mt_rtnend
mt_DoRetrig:
		move.l	n_start(a6),AUD_START(a5)		; Set sampledata pointer
		move.w	n_length(a6),AUD_LEN(a5)		; Set length
		move.w	n_period(a6),AUD_PER(a5)		; Set period
		move.l	n_loopstart(a6),AUD_LSTART(a5)	; Set Loopstart
		move.w	n_replen(a6),AUD_LLEN(a5)		; Set LoopLength
		clr.w	AUD_STATE(a5)					; trigger Reload!
mt_rtnend:
		move.l	(sp)+,d1
		rts

mt_VolumeFineUp:
		tst.b	mt_Counter
		bne 	mt_Return2
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		bra 	mt_VolSlideUp

mt_VolumeFineDown:
		tst.b	mt_Counter
		bne 	mt_Return2
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		bra 	mt_VolSlideDown2

mt_NoteCut:
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		cmp.b	mt_Counter(pc),d0
		bne 	mt_Return2
		clr.b	n_volume(a6)
		move.w	#0,AUD_VOL(a5)
		rts

mt_NoteDelay:
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0			;how many ticks to delay...
		and.b	#$0F,d0 				;up to 16!
		cmp.b	mt_Counter(pc),d0		;tick counter
		bne 	mt_Return2
		move.w	(a6),d0 				;Note!
		beq 	mt_Return2				;no note :-(
		move.l	d1,-(sp)
		bra 	mt_DoRetrig

mt_PatternDelay:
		tst.b	mt_Counter
		bne 	mt_Return2
		moveq	#0,d0
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		tst.b	mt_PattDelTime2
		bne 	mt_Return2
		addq.b	#1,d0
		move.b	d0,mt_PattDelTime
		rts

mt_FunkIt:
		tst.b	mt_Counter
		bne 	mt_Return2
		move.b	n_cmdlo(a6),d0
		and.b	#$0F,d0
		lsl.b	#4,d0
		andi.b	#$0F,n_glissfunk(a6)
		or.b	d0,n_glissfunk(a6)
		tst.b	d0
		beq 	mt_Return2
mt_UpdateFunk:
		movem.l d1/a0,-(sp)
		moveq	#0,d0
		move.b	n_glissfunk(a6),d0
		lsr.b	#4,d0
		beq.s	mt_funkend
		lea 	mt_FunkTable(pc),a0
		move.b	0(a0,d0.w),d0
		add.b	d0,n_funkoffset(a6)
		btst	#7,n_funkoffset(a6)
		beq.s	mt_funkend
		clr.b	n_funkoffset(a6)

		move.l	n_loopstart(a6),d0
		moveq	#0,d1
		move.w	n_replen(a6),d1
		add.l	d1,d0
		add.l	d1,d0
		movea.l n_wavestart(a6),a0
		addq.l	#1,a0
		cmpa.l	d0,a0
		blo.s	mt_funkok
		movea.l n_loopstart(a6),a0
mt_funkok:
		move.l	a0,n_wavestart(a6)
		moveq	#-1,d0
		sub.b	(a0),d0
		move.b	d0,(a0)
mt_funkend:
		movem.l (sp)+,d1/a0
		rts




; -----------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------
				bss

mt_SampleStarts:	ds.l 31

mt_SongDataPtr: 	ds.l 1				;Modfile Start
mt_SongEndPtr:		ds.l 1				;* Modfile End
mt_SeqList: 		ds.l 1
mt_PatList: 		ds.l 1
mt_PatternPos:		ds.w 1				;Position im Pattern 0..1024 (BYTE OFFSET!)
mt_speed:			ds.w 1				;Tick Counter
mt_ciaspeed:		ds.w 1				;BPM!
mt_Counter: 		ds.w 1				;internal Counter
mt_SongPos: 		ds.b 1				;Song Position
mt_PBreakPos:		ds.b 1
mt_PosJumpFlag: 	ds.b 1
mt_PBreakFlag:		ds.b 1
mt_LowMask: 		ds.b 1
mt_PattDelTime: 	ds.b 1
mt_PattDelTime2:	ds.b 1
mt_no_protracker:	ds.b 1				;* Protracker mode!?
mt_15inst:			ds.b 2				;* old 15 int module...

mt_ariadne: 		ds.b 128			;* Repeat trap table!

					even

; -----------------------------------------------------------------------
; Initialized Data
; -----------------------------------------------------------------------
				data

mt_chan1temp:	dc.l 0,0,0,0,0,$010000,0,0,0,0,0
mt_chan2temp:	dc.l 0,0,0,0,0,$020000,0,0,0,0,0
mt_chan3temp:	dc.l 0,0,0,0,0,$040000,0,0,0,0,0
mt_chan4temp:	dc.l 0,0,0,0,0,$080000,0,0,0,0,0

mt_FunkTable:	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable:
				dc.b 0,24,49,74,97,120,141,161
				dc.b 180,197,212,224,235,244,250,253
				dc.b 255,253,250,244,235,224,212,197
				dc.b 180,161,141,120,97,74,49,24
;
; period-Table: 3 Oktaven -> 36 Halbt”ne
;
mt_PeriodTable:
; Tuning 0, Normal
				dc.w 856,808,762,720,678,640,604,570,538,508,480,453
				dc.w 428,404,381,360,339,320,302,285,269,254,240,226
				dc.w 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
				dc.w 850,802,757,715,674,637,601,567,535,505,477,450
				dc.w 425,401,379,357,337,318,300,284,268,253,239,225
				dc.w 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
				dc.w 844,796,752,709,670,632,597,563,532,502,474,447
				dc.w 422,398,376,355,335,316,298,282,266,251,237,224
				dc.w 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
				dc.w 838,791,746,704,665,628,592,559,528,498,470,444
				dc.w 419,395,373,352,332,314,296,280,264,249,235,222
				dc.w 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
				dc.w 832,785,741,699,660,623,588,555,524,495,467,441
				dc.w 416,392,370,350,330,312,294,278,262,247,233,220
				dc.w 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
				dc.w 826,779,736,694,655,619,584,551,520,491,463,437
				dc.w 413,390,368,347,328,309,292,276,260,245,232,219
				dc.w 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
				dc.w 820,774,730,689,651,614,580,547,516,487,460,434
				dc.w 410,387,365,345,325,307,290,274,258,244,230,217
				dc.w 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
				dc.w 814,768,725,684,646,610,575,543,513,484,457,431
				dc.w 407,384,363,342,323,305,288,272,256,242,228,216
				dc.w 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
				dc.w 907,856,808,762,720,678,640,604,570,538,508,480
				dc.w 453,428,404,381,360,339,320,302,285,269,254,240
				dc.w 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
				dc.w 900,850,802,757,715,675,636,601,567,535,505,477
				dc.w 450,425,401,379,357,337,318,300,284,268,253,238
				dc.w 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
				dc.w 894,844,796,752,709,670,632,597,563,532,502,474
				dc.w 447,422,398,376,355,335,316,298,282,266,251,237
				dc.w 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
				dc.w 887,838,791,746,704,665,628,592,559,528,498,470
				dc.w 444,419,395,373,352,332,314,296,280,264,249,235
				dc.w 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
				dc.w 881,832,785,741,699,660,623,588,555,524,494,467
				dc.w 441,416,392,370,350,330,312,294,278,262,247,233
				dc.w 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
				dc.w 875,826,779,736,694,655,619,584,551,520,491,463
				dc.w 437,413,390,368,347,328,309,292,276,260,245,232
				dc.w 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
				dc.w 868,820,774,730,689,651,614,580,547,516,487,460
				dc.w 434,410,387,365,345,325,307,290,274,258,244,230
				dc.w 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
				dc.w 862,814,768,725,684,646,610,575,543,513,484,457
				dc.w 431,407,384,363,342,323,305,288,272,256,242,228
				dc.w 216,203,192,181,171,161,152,144,136,128,121,114


; -----------------------------------------------------------------------
; end of file
; -----------------------------------------------------------------------

