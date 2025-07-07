; PROTRACKER 2.3F REPLAY CODE
; ORIGINAL CODE BY LANCE
; ORIGINALLY MODIFIED BY PAULO SIMOES
; AMIGA 2.3F REPLAY BY 8BITBUBSY
; MODIFIED BY INSANE/RABENAUGE^TSCC
; - split into paula+tracker.asm
; - simple soft bpm emulator added
; - merged with current pt2.3f replay
; - removed paula init from mt_init, DIY!
; - allows loop end detection
; - allows visualizer support
; - allows master volume
; - fixed invert loop (mt_FunkIt)
;   volume tables taken from ptplayer 6.0 by frank wille

;---- custom stuff ----
SMPMINREP=664			; minimal sample size for replay
MODBUFFERSIZE=31*SMPMINREP+2	; size after mod for the copied samples

MODVOLUME	macro
	and.w	#$ff,d0
	move.l	mt_MasterVolTab,a4
	move.b	(a4,d0.w),d0
	endm

;	mt_music	Protracker 3.0 handler
mt_music:
	movem.l	d0-d1/a0,-(sp)
	addq.w	#1,mt_Visualizer+0
	addq.w	#1,mt_Visualizer+2
	addq.w	#1,mt_Visualizer+4
	addq.w	#1,mt_Visualizer+6
	move.w	mt_DMACONtemp(PC),D0
	tst.b	mt_UpdateVis
	beq	.skipvis
	lea	mt_Visualizer+8,a0
	moveq	#4-1,d1
.vis:	subq.w	#2,a0
	btst	d1,d0
	beq.s	.noctr0
	cmp.w	#4,(a0)
	bmi	.skipclr
	move.w	#0,(a0)
.skipclr:
.noctr0:
	dbf	d1,.vis
.skipvis:
	move.w	mt_BPMcnt,d0
	sub.w	mt_Tempo,d0
	tst.w	d0
	bpl	.skipplay
	bsr	mt_IntMusic
	add.w	#125,d0	;50hz*2.5
	bpl	.skipplay
	bsr	mt_IntMusic
	add.w	#125,d0
.skipplay
	move.w	d0,mt_BPMcnt
	movem.l	(sp)+,d0-d1/a0
	rts

mt_setmastervol:
	move.w	d0,mt_MasterVol
	cmp.w	#$40,d0
	bls	.skipres
	move.w	#$40,d0
.skipres
	lea	MasterVolTab0(pc),a0
	add.w	d0,a0
	lsl.w	#6,d0
	add.w	d0,a0

	move.l	a0,mt_MasterVolTab
	rts

;	add the needed chip sample buffer size to d0
mt_addbuffersize:
	add.l	#MODBUFFERSIZE,d0		31 samples * 664 bytes, 2b for long shift
	rts

;---- Playroutine ----
n_note		equ 0  ; W (MUST be first!)
n_cmd		equ 2  ; W (MUST be second!)
n_cmdlo		equ 3  ; B (offset in n_cmd)
n_start		equ 4  ; L (aligned)
n_loopstart	equ 8  ; L
n_wavestart	equ 12 ; L
n_peroffset	equ 16 ; L (offset to finetuned period-LUT section)
n_length	equ 20 ; W (aligned)
n_replen	equ 22 ; W
n_period	equ 24 ; W
n_dmabit	equ 26 ; W
n_wantedperiod	equ 28 ; W
n_finetune	equ 30 ; B
n_volume	equ 31 ; B
n_toneportdirec	equ 32 ; B
n_toneportspeed	equ 33 ; B
n_vibratocmd	equ 34 ; B
n_vibratopos	equ 35 ; B
n_tremolocmd	equ 36 ; B
n_tremolopos	equ 37 ; B
n_wavecontrol	equ 38 ; B
n_glissfunk	equ 39 ; B
n_sampleoffset	equ 40 ; B
n_pattpos	equ 41 ; B
n_loopcount	equ 42 ; B
n_funkoffset	equ 43 ; B


;	mt_init		MOD preparation procedure
;			A0 should point to MOD and loop space should
;			have be added at the end (31 * 664 bytes)
mt_init
*	lea	mt_data,a0
	move.l	a0,mt_SongDataPtr

	sf	mt_EndMusicTrigger

	; set volume to max like ptplayer
	move.l	#MasterVolTab64,mt_MasterVolTab

	move.l	a0,a1
	lea	952(a1),a1		;points to pattern list
	moveq	#127,d0			;128 values
	moveq	#0,d1
mtloop
	move.l	d1,d2
	subq.w	#1,d0
mtloop2
	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mtloop
	dbra	d0,mtloop2
	addq.b	#1,d2		;get highest pattern

	lea	mt_SampleStarts,a1
	asl.l	#8,d2
	asl.l	#2,d2			;total patterns * 1024
	add.l	#1084,d2		;+ $43C offset
	add.l	a0,d2			;+ module start pointer
	move.l	d2,a2			;A2 points to first sample
	moveq	#31-1,d0
	moveq	#0,d2
	lea	42(a0),a0
mtloop3
	move.l	a2,d1
	add.l	d2,d1
	move.l	d1,(a1)+
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.w	#SMPMINREP,d2

	cmp.w	#1,6(a0)		;looplen = 1 ?
	bne.s	.mt_no_test		;yes / no
	clr	6(a0)			;looplen = 0

.mt_no_test
	add.l	#30,a0
	dbra	d0,mtloop3
	add.w	d2,a2
	lea	mt_ModuleEndPtr,a1
	move.l	a2,(a1)
;modify mod for lance paula
	lea	-31*SMPMINREP(a2),a1
	moveq	#30,d7
mt_init_loops
	sub.w	#30,a0
	lea	-SMPMINREP(a2),a2
	move.l	a2,a3
	move.w	(a0),d0
	beq.s	.mt_just_loop
	subq.w	#1,d0
.mt_copy_spl
	move.w	-(a1),-(a2)
	dbra	d0,.mt_copy_spl
.mt_just_loop
	moveq	#0,d0
	move.w	6(a0),d0		;loop length
	sne	d1
	andi.w	#$4,d1
	move.l	mt_loop_point(pc,d1.w),a4
	jsr	(a4)
	dbra	d7,mt_init_loops
	move.l	#$fefefefe,d2
	move.l	#$80808080,d3
	move.l	mt_SampleStarts,a0
	move.l	mt_ModuleEndPtr,a1
.mt_shift_down
	move.l	(a0),d0		;12
	move.l	d0,d1		;4
	and.l	d2,d0		;8
	and.l	d3,d1		;8
	asr.l	#1,d0		;12
	or.l	d1,d0		;8
	move.l	d0,(a0)+	;12=64/4=16
	cmp.l	a1,a0
	blo.s	.mt_shift_down

	move.b	#6,mt_Speed
	move.w	#125,mt_Tempo
	move.b	#6,mt_Counter
	clr.b	mt_SongPos
	clr.w	mt_PatternPos
	clr.b	mt_PattDelayTime
	clr.b	mt_PattDelayTime2
	bsr.w	mt_RestoreEffects
	sf	mt_Enable
	bsr	mt_TurnOffVoices

	rts

mt_loop_point
	dc.l	.mt_no_loop
	dc.l	.mt_yes_loop
.mt_no_loop
	move.w	#SMPMINREP/4-1,d0
.mt_clear_loop
	clr.l	(a3)+
	dbra	d0,.mt_clear_loop
	rts
.mt_yes_loop
	move.w	4(a0),d0		;repeat start
	add.l	d0,d0
	lea	0(a2,d0.l),a4
	lea	(a4),a5
	moveq	#0,d1
	move.w	4(a0),d1
	add.w	6(a0),d1
	move.w	d1,(a0)
	add.l	d1,d1
	lea	0(a2,d1.l),a3
	move.w	6(a0),d1
	move.w	#SMPMINREP/2-1,d2
.mt_loop_loop
	move.w	(a4)+,(a3)+
	subq.w	#1,d1
	bne.s	.mt_no_restart
	lea	(a5),a4
	move.w	6(a0),d1
.mt_no_restart
	dbra	d2,.mt_loop_loop
	rts

mt_end
	sf	mt_Enable
mt_TurnOffVoices
	moveq	#0,d0
	lea	paula_channel_0,a5
	bsr	mt_ClearVoice
	lea	paula_channel_1,a5
	bsr	mt_ClearVoice
	lea	paula_channel_2,a5
	bsr	mt_ClearVoice
	lea	paula_channel_3,a5
mt_ClearVoice
	move.l	d0,paula_sample_point(a5)
	move.l	d0,paula_sample_end(a5)
	move.l	d0,paula_loop_start(a5)
	move.w	d0,paula_volume(a5)
	move.w	d0,paula_period(a5)
	move.w	d0,paula_add_iw(a5)
	rts

mt_RestoreEffects
	lea	mt_audchan1temp(PC),A0
	bsr.b	reefsub
	lea	mt_audchan2temp(PC),A0
	bsr.b	reefsub
	lea	mt_audchan3temp(PC),A0
	bsr.b	reefsub
	lea	mt_audchan4temp(PC),A0
reefsub	clr.b	n_wavecontrol(A0)
	clr.b	n_glissfunk(A0)
	clr.b	n_finetune(A0)
	clr.b	n_loopcount(A0)
	rts

mt_IntMusic
	movem.l	d0-d4/a0-a6,-(sp)
	tst.b	mt_Enable
	beq.w	mt_exit
	addq.b	#1,mt_Counter
	move.b	mt_Counter,d0
	cmp.b	mt_Speed,d0
	blo.s	mt_NoNewNote
	clr.b	mt_Counter
	tst.b	mt_PattDelayTime2
	beq.s	mt_GetNewNote
	bsr.s	mt_NoNewAllChannels
	bra	mt_dskip

mt_NoNewNote
	bsr.s	mt_NoNewAllChannels
	bra	mt_NoNewPositionYet

mt_NoNewAllChannels
	lea	mt_audchan1temp,a6
	lea	paula_channel_0,a5
	bsr	mt_CheckEffects
	lea	mt_audchan2temp,a6
	lea	paula_channel_1,a5
	bsr	mt_CheckEffects
	lea	mt_audchan3temp,a6
	lea	paula_channel_2,a5
	bsr	mt_CheckEffects
	lea	mt_audchan4temp,a6
	lea	paula_channel_3,a5
	bra	mt_CheckEffects

mt_GetNewNote
	move.l	mt_SongDataPtr,a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	move.b	mt_SongPos,d0
	moveq	#0,d1
	move.b	(a2,d0.w),d1
	swap	d1
	lsr.l	#6,d1

	add.w	mt_PatternPos,d1
	clr.w	mt_DMACONtemp

	lea	paula_channel_0,a5
	lea	mt_audchan1temp,a6
	bsr	mt_PlayVoice
	MOVE.B	n_volume(A6),D0
	MODVOLUME
	move.w	d0,paula_volume(a5)

	lea	paula_channel_1,a5
	lea	mt_audchan2temp,a6
	bsr.s	mt_PlayVoice
	MOVE.B	n_volume(A6),D0
	MODVOLUME
	move.w	d0,paula_volume(a5)

	lea	paula_channel_2,a5
	lea	mt_audchan3temp,a6
	bsr.s	mt_PlayVoice
	MOVE.B	n_volume(A6),D0
	MODVOLUME
	move.w	d0,paula_volume(a5)

	lea	paula_channel_3,a5
	lea	mt_audchan4temp,a6
	bsr.s	mt_PlayVoice
	MOVE.B	n_volume(A6),D0
	MODVOLUME
	move.w	d0,paula_volume(a5)

	bra	mt_SetDMA

mt_PlayVoice
	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_PerNop
mt_plvskip
	move.l	(a0,d1.l),(a6)		;read note from pattern
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq	mt_SetRegisters

	moveq	#0,d3
	lea	mt_SampleStarts,a1
	move	d2,d4
	subq.l	#1,d2
	lsl.l	#2,d2
	mulu.w	#30,d4
	move.l	(a1,d2.l),n_start(a6)
	move.w	(a3,d4.l),n_length(a6)

	moveq	#0,d0
	move.b	2(a3,d4.l),D0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	; ----------------------------------
	lsl.b	#2,d0 ; update n_peroffset
	lea	mt_ftunePerTab(pc),a4
	move.l	(a4,d0.w),n_peroffset(a6)
	; ----------------------------------
	move.b	3(a3,d4.l),n_volume(a6)

	move.w	4(a3,d4.l),d3 		; get repeat
	tst.w	6(a3,d4.l)		; test replen
	beq.s	mt_NoLoop
	move.l	n_start(a6),d2		; get start
	add.l	d3,d3
	add.l	d3,d2			; add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	4(a3,d4.l),d0		; get repeat
	add.w	6(a3,d4.l),d0		; add replen
	move.w	d0,n_length(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen

	bra.s	mt_SetRegisters

mt_NoLoop
	move.l	n_start(a6),d2
	add.l	d3,d2			; add repeat start to start
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen

mt_SetRegisters
	move.w	(a6),d0
	and.w	#$0fff,d0
	beq	mt_CheckMoreEffects	; if no note
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0		;finetune
	beq.s	mt_DoSetFineTune
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0	; toneportamento
	beq.s	mt_ChkTonePorta
	cmp.b	#5,d0	; toneportamento + volslide
	beq.s	mt_ChkTonePorta
	cmp.b	#9,d0	; sample offset
	bne.s	mt_SetPeriod
	bsr	mt_CheckMoreEffects
	bra.s	mt_SetPeriod

mt_DoSetFineTune
	bsr	mt_SetFineTune
	bra.s	mt_SetPeriod

mt_ChkTonePorta
	bsr	mt_SetTonePorta
	bra	mt_CheckMoreEffects

mt_SetPeriod
	movem.l	d1/a0/a1,-(sp)
	move.w	(a6),d1
	and.w	#$0fff,d1
	lea	mt_PeriodTable(pc),a1
	moveq	#0,d0
	moveq	#$24,d7
mt_ftuloop
	cmp.w	(a1,d0.w),d1
	bhs.s	mt_ftufound
	addq.w	#2,d0
	dbra	d7,mt_ftuloop
mt_ftufound
	move.l	n_peroffset(a6),a1
	move.w	(a1,d0.w),n_period(a6)
	movem.l	(sp)+,d1/a0/a1

	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0 ; notedelay
	beq	mt_CheckMoreEffects

;	DMAUPDATE

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),paula_sample_point(a5)	; set start
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	paula_sample_point(a5),d0
	move.l	d0,paula_sample_end(a5)

	move.l	n_loopstart(a6),paula_loop_start(a5)
	move	n_replen(a6),d0
	bne.s	mt_sdmaskp
	moveq	#0,d0
	move.l	d0,paula_loop_start(a5)
mt_sdmaskp
	move.w	n_period(a6),d0
	move.w	d0,paula_period(a5)		; set period
	move.w	n_dmabit(a6),d0

	or.w	d0,mt_DMACONtemp

;	DMAUPDATE

	bra	mt_CheckMoreEffects
 
mt_SetDMA
	; pt2.3f sets loopstart+replen here

mt_dskip
	add.w	#16,mt_PatternPos
	move.b	mt_PattDelayTime,d0
	beq.s	mt_dskpc
	move.b	d0,mt_PattDelayTime2
	clr.b	mt_PattDelayTime
mt_dskpc
	tst.b	mt_PattDelayTime2
	beq.s	mt_dskpa
	subq.b	#1,mt_PattDelayTime2
	beq.s	mt_dskpa
	sub.w	#16,mt_PatternPos
mt_dskpa
	tst.b	mt_PBreakFlag
	beq.s	mt_nnpysk
	sf	mt_PBreakFlag
	moveq	#0,d0
	move.b	mt_PBreakPos,d0
	lsl.w	#4,d0
	move.w	d0,mt_PatternPos
	clr.b	mt_PBreakPos
mt_nnpysk
	cmp.w	#1024,mt_PatternPos
	blo.s	mt_NoNewPositionYet
mt_NextPosition
	moveq	#0,d0
	move.b	mt_PBreakPos,d0
	lsl.w	#4,d0
	move.w	d0,mt_PatternPos
	clr.b	mt_PBreakPos
	clr.b	mt_PosJumpFlag
	addq.b	#1,mt_SongPos
	and.b	#$7f,mt_SongPos
	move.b	mt_SongPos,d1
	move.l	mt_SongDataPtr,a0
	cmp.b	950(a0),d1
	blo.s	mt_NoNewPositionYet
	clr.b	mt_SongPos
	st	mt_EndMusicTrigger	
mt_NoNewPositionYet
	tst.b	mt_PosJumpFlag
	bne.s	mt_NextPosition
mt_exit
	movem.l	(sp)+,d0-d4/a0-a6
	rts

mt_CheckEffects
	bsr.b	mt_chkefx2
	moveq	#0,D0
	move.b	n_volume(A6),d0
	MODVOLUME
	move.w	d0,paula_volume(A5)	; AUDxVOL
	rts
	
	cnop 0,4
mt_JumpList1
	dc.l mt_Arpeggio		; 0xy (Arpeggio)
	dc.l mt_PortaUp			; 1xx (Portamento Up)
	dc.l mt_PortaDown		; 2xx (Portamento Down)
	dc.l mt_TonePortamento		; 3xx (Tone Portamento)
	dc.l mt_Vibrato			; 4xy (Vibrato)
	dc.l mt_TonePlusVolSlide	; 5xy (Tone Portamento + Volume Slide)
	dc.l mt_VibratoPlusVolSlide	; 6xy (Vibrato + Volume Slide)
	dc.l SetBack			; 7 - not used here
	dc.l SetBack			; 8 - unused!
	dc.l SetBack			; 9 - not used here
	dc.l SetBack			; A - not used here
	dc.l SetBack			; B - not used here
	dc.l SetBack			; C - not used here
	dc.l SetBack			; D - not used here
	dc.l mt_E_Commands		; Exy (Extended Commands)
	dc.l SetBack			; F - not used here

mt_chkefx2
	bsr.w	mt_UpdateFunk
	move.w	n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.b	mt_Return3
	moveq	#0,d0
	move.b	n_cmd(A6),d0
	and.b	#$0F,d0
	move.w	d0,d1
	lsl.b	#2,d1
	move.l	mt_JumpList1(pc,d1.W),a4
	jmp	(a4) ; every efx has RTS at the end, this is safe

SetBack
	move.w	n_period(a6),paula_period(a5)
	cmp.b	#7,d0
	beq	mt_Tremolo
	cmp.b	#$a,d0
	beq	mt_VolumeSlide
mt_Return3
	rts

mt_PerNop
	move.w	n_period(a6),paula_period(a5)
	rts

	; DIV -> LUT optimization. DIVU is 140+ cycles on a 68000.
mt_ArpTab
	dc.b 0,1,2,0,1,2,0,1
	dc.b 2,0,1,2,0,1,2,0
	dc.b 1,2,0,1,2,0,1,2
	dc.b 0,1,2,0,1,2,0,1

mt_Arpeggio
	moveq	#0,d0
	move.b	mt_Counter,d0
	and.b	#$1F,D0			; just in case
	move.b	mt_ArpTab(pc,d0.w),d0
	cmp.b	#1,D0
	beq.b	mt_Arpeggio1
	cmp.b	#2,D0
	beq.b	mt_Arpeggio2
mt_Arpeggio0
	move.w	n_period(a6),d2
	bra.s	mt_ArpeggioSet
mt_Arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_ArpeggioFind
mt_Arpeggio2
	moveq	#0,d0
	move.b	n_cmdlo(A6),d0
	and.b	#15,d0
mt_ArpeggioFind
	add.w	d0,d0
	move.l	n_peroffset(a6),a0
	moveq	#0,d1
	move.w	n_period(a6),d1
	moveq	#$24,d3
mt_arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.b	mt_ArpeggioSet
	addq.l	#2,a0
	dbra	D3,mt_arploop
	rts

mt_ArpeggioSet
	move.w	d2,paula_period(a5)
	rts

mt_FinePortaUp
	tst.b	mt_Counter
	bne.w	mt_Return3
	move.b	#$0f,mt_LowMask
mt_PortaUp
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_LowMask,d0
	move.b	#$ff,mt_LowMask
	sub.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#$0071,d0
	bpl.s	mt_PortaUskip
	and.w	#$f000,n_period(a6)
	or.w	#$0071,n_period(a6)
mt_PortaUskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,paula_period(a5)
	rts
 
mt_FinePortaDown
	tst.b	mt_Counter
	bne.w	mt_Return3
	move.b	#$0f,mt_LowMask
mt_PortaDown
	clr.w	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_LowMask,d0
	move.b	#$ff,mt_LowMask
	add.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#$0358,d0
	bmi.s	mt_PortaDskip
	and.w	#$f000,n_period(a6)
	or.w	#$0358,n_period(a6)
mt_PortaDskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,paula_period(a5)
	rts

mt_SetTonePorta
	move.w	(a6),d2
	and.w	#$0fff,d2
	move.l	n_peroffset(a6),a4
	moveq	#0,d0
mt_StpLoop
	cmp.w	(a4,d0.w),d2
	bhs.b	mt_StpFound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.b	mt_StpLoop
	moveq	#35*2,d0
mt_StpFound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.b	mt_StpGoss
	tst.w	d0
	beq.b	mt_StpGoss
	subq.w	#2,d0
mt_StpGoss
	move.w	(a4,d0.w),d2
	move.w	d2,n_wantedperiod(a6)
	move.w	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.b	mt_ClearTonePorta
	bge.w	mt_Return3
	move.b	#1,n_toneportdirec(a6)
	rts

mt_ClearTonePorta
	clr.w	n_wantedperiod(a6)
	rts

mt_TonePortamento
	move.b	n_cmdlo(a6),d0
	beq.s	mt_TonePortNoChange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_TonePortNoChange
	tst.w	n_wantedperiod(a6)
	beq	mt_Return3
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_TonePortaUp
mt_TonePortaDown
	add.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	mt_TonePortaSetPer
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	mt_TonePortaSetPer

mt_TonePortaUp
	sub.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	mt_TonePortaSetPer
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

mt_TonePortaSetPer
	move.w	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	mt_GlissSkip
	move.l	n_peroffset(a6),a0	
	moveq	#0,d0
mt_GlissLoop
	cmp.w	(a0,d0.w),d2
	bhs.b	mt_GlissFound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.b	mt_GlissLoop
	moveq	#35*2,d0
mt_GlissFound
	move.w	(a0,d0.w),d2
mt_GlissSkip
	move.w	d2,paula_period(a5) ; set period
	rts

mt_Vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	mt_Vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_Vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_VibratoTable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#3,d2
	beq.s	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_vib_rampdown
	move.b	#255,d2
	bra.s	mt_vib_set
mt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.b	mt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_vib_set
mt_vib_rampdown2
	move.b	d0,d2
	bra.s	mt_vib_set
mt_vib_sine
	move.b	(a4,d0.w),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu.w	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_VibratoNeg
	add.w	d2,d0
	bra.s	mt_Vibrato3
mt_VibratoNeg
	sub.w	d2,d0
mt_Vibrato3
	move.w	d0,paula_period(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_TonePlusVolSlide
	bsr	mt_TonePortNoChange
	bra	mt_VolumeSlide

mt_VibratoPlusVolSlide
	bsr.s	mt_Vibrato2
	bra	mt_VolumeSlide

mt_Tremolo
	move.b	n_cmdlo(a6),d0
	beq.b	mt_Tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_Tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_VibratoTable,a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#3,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b	#255,d2
	bra.s	mt_tre_set
mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.s	mt_tre_set
mt_tre_sine
	move.b	(a4,d0.w),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu.w	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_TremoloNeg
	add.w	d2,d0
	bra.s	mt_Tremolo3
mt_TremoloNeg
	sub.w	d2,d0
mt_Tremolo3
	bpl.s	mt_TremoloSkip
	clr.w	d0
mt_TremoloSkip
	cmp.w	#$40,d0
	bls.s	mt_TremoloOk
	move.w	#$40,d0
mt_TremoloOk
	MODVOLUME
	move.w	d0,paula_volume(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	addq.l	#4,sp			; hack to not set volume in mt_checkeffects
	rts

mt_SampleOffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	add.w	d0,d0
	add.l	d0,n_start(a6)
	add.l	n_loopstart(a6),d0
	cmp.l	n_start(a6),d0
	ble.s	.mt_set_loop
	move.l	n_loopstart(a6),d0
.mt_set_loop
	move.l	d0,n_loopstart(a6)
	rts
mt_sofskip
; fixes sample offset > sample len, but pt2.3f doesn't do tihs
	move	n_length(a6),d0		;lenght in words
	subq	#1,d0			;- 1 (new length)
	add.l	d0,d0			;offset in bytes
	add.l	d0,n_start(a6)		;new start ptr
	move.w	#$0001,n_length(a6)
	rts

mt_VolumeSlide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_VolSlideDown
mt_VolSlideUp
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	rts

mt_VolSlideDown
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
mt_VolSlideDown2
	sub.b	d0,n_volume(a6)
	bpl.b	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	rts

mt_PositionJump
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_SongPos
mt_pj2
	clr.b	mt_PBreakPos
	st 	mt_PosJumpFlag
	st	mt_EndMusicTrigger
	rts

mt_VolumeChange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_VolumeOk
	moveq	#$40,d0
mt_VolumeOk
	move.b	d0,n_volume(a6)
	rts

mt_PatternBreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu.w	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b	d0,mt_PBreakPos
	st	mt_PosJumpFlag
	rts

mt_SetSpeed
	move.b	3(a6),d0
	beq	mt_end
	cmp.b	#32,d0
	bcc.s	mt_SetBPM
	clr.b	mt_Counter
	move.b	d0,mt_Speed
	rts

mt_SetBPM
	and.w	#$ff,d0
	move.w	d0,mt_Tempo
	rts

	CNOP 0,4
mt_JumpList2
	dc.l mt_PerNop		; 0 - not used
	dc.l mt_PerNop		; 1 - not used
	dc.l mt_PerNop		; 2 - not used
	dc.l mt_PerNop		; 3 - not used
	dc.l mt_PerNop		; 4 - not used
	dc.l mt_PerNop		; 5 - not used
	dc.l mt_PerNop		; 6 - not used
	dc.l mt_PerNop		; 7 - not used
	dc.l mt_PerNop		; 8 - not used
	dc.l mt_SampleOffset	; 9xx (Set Sample Offset)
	dc.l mt_PerNop		; A - not used
	dc.l mt_PositionJump	; Bxx (Position Jump)
	dc.l mt_VolumeChange	; Cxx (Set Volume)
	dc.l mt_PatternBreak	; Dxx (Pattern Break)
	dc.l mt_E_Commands	; Exy (Extended Commands)
	dc.l mt_SetSpeed	; Fxx (Set Speed)
		
mt_CheckMoreEffects
	moveq	#0,d0
	move.b	2(a6),d0
	and.b	#$0f,d0
	lsl.b	#2,d0
	move.l	mt_JumpList2(pc,d0.w),a4
	jmp	(a4) ; every efx has RTS at the end, this is safe
	
	cnop 0,4
mt_E_JumpList
	dc.l mt_FilterOnOff		; E0x (Set LED Filter)
	dc.l mt_FinePortaUp		; E1x (Fine Portamento Up)
	dc.l mt_FinePortaDown		; E2x (Fine Portamento Down)
	dc.l mt_SetGlissControl		; E3x (Glissando/Funk Control)
	dc.l mt_SetVibratoControl	; E4x (Vibrato Control)
	dc.l mt_SetFineTune		; E5x (Set Finetune)
	dc.l mt_JumpLoop		; E6x (Pattern Loop)
	dc.l mt_SetTremoloControl	; E7x (Tremolo Control)
	dc.l mt_KarplusStrong		; E8x (Karplus-Strong)
	dc.l mt_RetrigNote		; E9x (Retrig Note)
	dc.l mt_VolumeFineUp		; EAx (Fine Volume-Slide Up)
	dc.l mt_VolumeFineDown		; EBx (Fine Volume-Slide Down)
	dc.l mt_NoteCut			; ECx (Note Cut)
	dc.l mt_NoteDelay		; EDx (Note Delay)
	dc.l mt_PatternDelay		; EEx (Pattern Delay)
	dc.l mt_FunkIt			; EFx (Invert Loop)
	
mt_E_Commands
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4-2,d0
	move.l	mt_E_JumpList(pc,d0.w),a4
	jmp	(a4) ; every E-efx has RTS at the end, this is safe
	
mt_FilterOnOff
	rts

mt_SetGlissControl
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_SetVibratoControl
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_SetFineTune
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	; ----------------------------------
	lsl.b	#2,d0	; update n_peroffset
	lea	mt_ftunePerTab(pc),a4
	move.l	(a4,d0.w),n_peroffset(a6)
	; ----------------------------------
	rts

mt_JumpLoop
	tst.b	mt_Counter
	bne	mt_Return3
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_SetLoop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_Return3
mt_jmploop
	move.b	n_pattpos(a6),mt_PBreakPos
	st	mt_PBreakFlag
	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_SetLoop
	move.w	mt_PatternPos,d0
	lsr.w	#4,d0
	and.b	#63,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_SetTremoloControl
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_KarplusStrong	;untested
	movem.l	d1/d2/a0/a1,-(sp)
	move.l	n_loopstart(a6),a0
	cmp.w	#0,a0
	beq.b	karplend
	move.l	a0,a1
	move.w	n_replen(a6),d0
	add.w	d0,d0
	subq.w	#2,d0
karplop	move.b	(a0),d1
	ext.w	d1
	move.b	1(a0),d2
	ext.w	d2
	add.w	d1,d2
	asr.w	#1,d2
	move.b	d2,(a0)+
	dbra	d0,karplop
	move.b	(a0),d1
	ext.w	d1
	move.b	(a1),d2
	ext.w	d2
	add.w	d1,d2
	asr.w	#1,d2
	move.b	d2,(a0)
karplend	
	movem.l	(sp)+,d1/d2/a0/a1
	RTS

mt_RetrigNote
	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_Counter,d1
	bne.s	mt_rtnskp
	move.w	(a6),d1
	and.w	#$0fff,d1
	bne.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_Counter,d1
mt_rtnskp
	and.b	#$1f,d1	; just in case
	lsl.w	#5,d0
	add.w	d0,d1
	move.b	mt_RetrigTab(pc,d1.w),d0
	bne.b	mt_rtnend
mt_DoRetrig
;	DMAUPDATE
	move.l	n_start(a6),paula_sample_point(a5)	; set sampledata pointer
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	paula_sample_point(a5),d0
	move.l	d0,paula_sample_end(a5)

	move.l	n_loopstart(a6),paula_loop_start(a5)
	move.w	n_replen(a6),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
	move.l	d0,paula_loop_start(a5)
.mt_set_loop

mt_rtnend
	move.l	(sp)+,d1
	rts
	
	; DIV -> LUT optimization. Maybe a bit extreme, but DIVU is 140+
	; cycles on a 68000.
mt_RetrigTab
	dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b 0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
	dc.b 0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1
	dc.b 0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1
	dc.b 0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1
	dc.b 0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1
	dc.b 0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1
	dc.b 0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1
	dc.b 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1

mt_VolumeFineUp
	tst.b	mt_Counter
	bne	mt_Return3
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	mt_VolSlideUp

mt_VolumeFineDown
	tst.b	mt_Counter
	bne	mt_Return3
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_VolSlideDown2

mt_NoteCut
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_Counter,d0
	bne	mt_Return3
	clr.b	n_volume(a6)
	rts

mt_NoteDelay
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_Counter,d0
	bne	mt_Return3
	move.w	(a6),d0
	and.w	#$0fff,d0
	bne	mt_Return3
	move.l	d1,-(sp)
	move	n_period(a6),paula_period(a5)
	bra	mt_DoRetrig

mt_PatternDelay
	tst.b	mt_Counter
	bne	mt_Return3
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	mt_PattDelayTime2
	bne	mt_Return3
	addq.b	#1,d0
	move.b	d0,mt_PattDelayTime
	rts

mt_FunkIt
	tst.b	mt_Counter
	bne	mt_Return3
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_Return3
mt_UpdateFunk
	movem.l	a0-a1/d1-d2,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_funkend
	lea	mt_FunkTable(pc),a0
	move.b	(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
	clr.b	n_funkoffset(a6)

	; --PT2.3D bug fix: EFx null pointer--
	move.l	n_wavestart(a6),a0
	cmp.l	#0,a0
	beq.b	mt_funkend
	; --END OF FIX------------------------

	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move.w	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.s	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok	;d1=replen
	move.l	a0,n_wavestart(a6)
	lea	SMPMINREP(a0),a1
	add.l	d1,d1
.lp:
	neg.b	(a0)
	cmp.l	#SMPMINREP,d1
	bhi.s	.skip	;abort when repeat len>SMPMINREP
	add.l	d1,a0
	cmp.l	a1,a0	;loop until all shadow copies have been modified
	blo.s	.lp
.skip:
mt_funkend
	movem.l	(sp)+,a0-a1/d1-d2
	rts

	; do NOT put this in the data section - crashes ahoy!

	CNOP 0,4
mt_FunkTable
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	even

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24
	
	; this LUT prevents MULU for getting correct period section
	CNOP 0,4
mt_ftunePerTab
	dc.l mt_ftune0,mt_ftune1,mt_ftune2,mt_ftune3
	dc.l mt_ftune4,mt_ftune5,mt_ftune6,mt_ftune7
	dc.l mt_ftune8,mt_ftune9,mt_ftuneA,mt_ftuneB
	dc.l mt_ftuneC,mt_ftuneD,mt_ftuneE,mt_ftuneF

mt_PeriodTable
; Tuning 0, Normal
mt_ftune0
	dc.w 856,808,762,720,678,640,604,570,538,508,480,453
	dc.w 428,404,381,360,339,320,302,285,269,254,240,226
	dc.w 214,202,190,180,170,160,151,143,135,127,120,113,0
; Tuning 1
mt_ftune1
	dc.w 850,802,757,715,674,637,601,567,535,505,477,450
	dc.w 425,401,379,357,337,318,300,284,268,253,239,225
	dc.w 213,201,189,179,169,159,150,142,134,126,119,113,0
; Tuning 2
mt_ftune2
	dc.w 844,796,752,709,670,632,597,563,532,502,474,447
	dc.w 422,398,376,355,335,316,298,282,266,251,237,224
	dc.w 211,199,188,177,167,158,149,141,133,125,118,112,0
; Tuning 3
mt_ftune3
	dc.w 838,791,746,704,665,628,592,559,528,498,470,444
	dc.w 419,395,373,352,332,314,296,280,264,249,235,222
	dc.w 209,198,187,176,166,157,148,140,132,125,118,111,0
; Tuning 4
mt_ftune4
	dc.w 832,785,741,699,660,623,588,555,524,495,467,441
	dc.w 416,392,370,350,330,312,294,278,262,247,233,220
	dc.w 208,196,185,175,165,156,147,139,131,124,117,110,0
; Tuning 5
mt_ftune5
	dc.w 826,779,736,694,655,619,584,551,520,491,463,437
	dc.w 413,390,368,347,328,309,292,276,260,245,232,219
	dc.w 206,195,184,174,164,155,146,138,130,123,116,109,0
; Tuning 6
mt_ftune6
	dc.w 820,774,730,689,651,614,580,547,516,487,460,434
	dc.w 410,387,365,345,325,307,290,274,258,244,230,217
	dc.w 205,193,183,172,163,154,145,137,129,122,115,109,0
; Tuning 7
mt_ftune7
	dc.w 814,768,725,684,646,610,575,543,513,484,457,431
	dc.w 407,384,363,342,323,305,288,272,256,242,228,216
	dc.w 204,192,181,171,161,152,144,136,128,121,114,108,0
; Tuning -8
mt_ftune8
	dc.w 907,856,808,762,720,678,640,604,570,538,508,480
	dc.w 453,428,404,381,360,339,320,302,285,269,254,240
	dc.w 226,214,202,190,180,170,160,151,143,135,127,120,0
; Tuning -7
mt_ftune9
	dc.w 900,850,802,757,715,675,636,601,567,535,505,477
	dc.w 450,425,401,379,357,337,318,300,284,268,253,238
	dc.w 225,212,200,189,179,169,159,150,142,134,126,119,0
; Tuning -6
mt_ftuneA
	dc.w 894,844,796,752,709,670,632,597,563,532,502,474
	dc.w 447,422,398,376,355,335,316,298,282,266,251,237
	dc.w 223,211,199,188,177,167,158,149,141,133,125,118,0
; Tuning -5
mt_ftuneB
	dc.w 887,838,791,746,704,665,628,592,559,528,498,470
	dc.w 444,419,395,373,352,332,314,296,280,264,249,235
	dc.w 222,209,198,187,176,166,157,148,140,132,125,118,0
; Tuning -4
mt_ftuneC
	dc.w 881,832,785,741,699,660,623,588,555,524,494,467
	dc.w 441,416,392,370,350,330,312,294,278,262,247,233
	dc.w 220,208,196,185,175,165,156,147,139,131,123,117,0
; Tuning -3
mt_ftuneD
	dc.w 875,826,779,736,694,655,619,584,551,520,491,463
	dc.w 437,413,390,368,347,328,309,292,276,260,245,232
	dc.w 219,206,195,184,174,164,155,146,138,130,123,116,0
; Tuning -2
mt_ftuneE
	dc.w 868,820,774,730,689,651,614,580,547,516,487,460
	dc.w 434,410,387,365,345,325,307,290,274,258,244,230
	dc.w 217,205,193,183,172,163,154,145,137,129,122,115,0
; Tuning -1
mt_ftuneF
	dc.w 862,814,768,725,684,646,610,575,543,513,484,457
	dc.w 431,407,384,363,342,323,305,288,272,256,242,228
	dc.w 216,203,192,181,171,161,152,144,136,128,121,114,0


MasterVolTab0:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0
MasterVolTab1:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1
MasterVolTab2:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	2
MasterVolTab3:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	3
MasterVolTab4:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
	dc.b	4
MasterVolTab5:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2
	dc.b	2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3
	dc.b	3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4
	dc.b	5
MasterVolTab6:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1
	dc.b	1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2
	dc.b	3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4
	dc.b	4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5
	dc.b	6
MasterVolTab7:
	dc.b	0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
	dc.b	1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3
	dc.b	3,3,3,3,3,4,4,4,4,4,4,4,4,4,5,5
	dc.b	5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6
	dc.b	7
MasterVolTab8:
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
	dc.b	2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3
	dc.b	4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5
	dc.b	6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7
	dc.b	8
MasterVolTab9:
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2
	dc.b	2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4
	dc.b	4,4,4,4,5,5,5,5,5,5,5,6,6,6,6,6
	dc.b	6,6,7,7,7,7,7,7,7,8,8,8,8,8,8,8
	dc.b	9
MasterVolTab10:
	dc.b	0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2
	dc.b	2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4
	dc.b	5,5,5,5,5,5,5,6,6,6,6,6,6,7,7,7
	dc.b	7,7,7,7,8,8,8,8,8,8,9,9,9,9,9,9
	dc.b	10
MasterVolTab11:
	dc.b	0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2
	dc.b	2,2,3,3,3,3,3,3,4,4,4,4,4,4,5,5
	dc.b	5,5,5,6,6,6,6,6,6,7,7,7,7,7,7,8
	dc.b	8,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10
	dc.b	11
MasterVolTab12:
	dc.b	0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,2
	dc.b	3,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5
	dc.b	6,6,6,6,6,6,7,7,7,7,7,8,8,8,8,8
	dc.b	9,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11
	dc.b	12
MasterVolTab13:
	dc.b	0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,3
	dc.b	3,3,3,3,4,4,4,4,4,5,5,5,5,5,6,6
	dc.b	6,6,6,7,7,7,7,7,8,8,8,8,8,9,9,9
	dc.b	9,9,10,10,10,10,10,11,11,11,11,11,12,12,12,12
	dc.b	13
MasterVolTab14:
	dc.b	0,0,0,0,0,1,1,1,1,1,2,2,2,2,3,3
	dc.b	3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6
	dc.b	7,7,7,7,7,8,8,8,8,8,9,9,9,9,10,10
	dc.b	10,10,10,11,11,11,11,12,12,12,12,12,13,13,13,13
	dc.b	14
MasterVolTab15:
	dc.b	0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3
	dc.b	3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7
	dc.b	7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11
	dc.b	11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14
	dc.b	15
MasterVolTab16:
	dc.b	0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3
	dc.b	4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7
	dc.b	8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11
	dc.b	12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15
	dc.b	16
MasterVolTab17:
	dc.b	0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3
	dc.b	4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8
	dc.b	8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12
	dc.b	12,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16
	dc.b	17
MasterVolTab18:
	dc.b	0,0,0,0,1,1,1,1,2,2,2,3,3,3,3,4
	dc.b	4,4,5,5,5,5,6,6,6,7,7,7,7,8,8,8
	dc.b	9,9,9,9,10,10,10,10,11,11,11,12,12,12,12,13
	dc.b	13,13,14,14,14,14,15,15,15,16,16,16,16,17,17,17
	dc.b	18
MasterVolTab19:
	dc.b	0,0,0,0,1,1,1,2,2,2,2,3,3,3,4,4
	dc.b	4,5,5,5,5,6,6,6,7,7,7,8,8,8,8,9
	dc.b	9,9,10,10,10,10,11,11,11,12,12,12,13,13,13,13
	dc.b	14,14,14,15,15,15,16,16,16,16,17,17,17,18,18,18
	dc.b	19
MasterVolTab20:
	dc.b	0,0,0,0,1,1,1,2,2,2,3,3,3,4,4,4
	dc.b	5,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9
	dc.b	10,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14
	dc.b	15,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19
	dc.b	20
MasterVolTab21:
	dc.b	0,0,0,0,1,1,1,2,2,2,3,3,3,4,4,4
	dc.b	5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10
	dc.b	10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15
	dc.b	15,16,16,16,17,17,17,18,18,18,19,19,19,20,20,20
	dc.b	21
MasterVolTab22:
	dc.b	0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5
	dc.b	5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10
	dc.b	11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16
	dc.b	16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21
	dc.b	22
MasterVolTab23:
	dc.b	0,0,0,1,1,1,2,2,2,3,3,3,4,4,5,5
	dc.b	5,6,6,6,7,7,7,8,8,8,9,9,10,10,10,11
	dc.b	11,11,12,12,12,13,13,14,14,14,15,15,15,16,16,16
	dc.b	17,17,17,18,18,19,19,19,20,20,20,21,21,21,22,22
	dc.b	23
MasterVolTab24:
	dc.b	0,0,0,1,1,1,2,2,3,3,3,4,4,4,5,5
	dc.b	6,6,6,7,7,7,8,8,9,9,9,10,10,10,11,11
	dc.b	12,12,12,13,13,13,14,14,15,15,15,16,16,16,17,17
	dc.b	18,18,18,19,19,19,20,20,21,21,21,22,22,22,23,23
	dc.b	24
MasterVolTab25:
	dc.b	0,0,0,1,1,1,2,2,3,3,3,4,4,5,5,5
	dc.b	6,6,7,7,7,8,8,8,9,9,10,10,10,11,11,12
	dc.b	12,12,13,13,14,14,14,15,15,16,16,16,17,17,17,18
	dc.b	18,19,19,19,20,20,21,21,21,22,22,23,23,23,24,24
	dc.b	25
MasterVolTab26:
	dc.b	0,0,0,1,1,2,2,2,3,3,4,4,4,5,5,6
	dc.b	6,6,7,7,8,8,8,9,9,10,10,10,11,11,12,12
	dc.b	13,13,13,14,14,15,15,15,16,16,17,17,17,18,18,19
	dc.b	19,19,20,20,21,21,21,22,22,23,23,23,24,24,25,25
	dc.b	26
MasterVolTab27:
	dc.b	0,0,0,1,1,2,2,2,3,3,4,4,5,5,5,6
	dc.b	6,7,7,8,8,8,9,9,10,10,10,11,11,12,12,13
	dc.b	13,13,14,14,15,15,16,16,16,17,17,18,18,18,19,19
	dc.b	20,20,21,21,21,22,22,23,23,24,24,24,25,25,26,26
	dc.b	27
MasterVolTab28:
	dc.b	0,0,0,1,1,2,2,3,3,3,4,4,5,5,6,6
	dc.b	7,7,7,8,8,9,9,10,10,10,11,11,12,12,13,13
	dc.b	14,14,14,15,15,16,16,17,17,17,18,18,19,19,20,20
	dc.b	21,21,21,22,22,23,23,24,24,24,25,25,26,26,27,27
	dc.b	28
MasterVolTab29:
	dc.b	0,0,0,1,1,2,2,3,3,4,4,4,5,5,6,6
	dc.b	7,7,8,8,9,9,9,10,10,11,11,12,12,13,13,14
	dc.b	14,14,15,15,16,16,17,17,18,18,19,19,19,20,20,21
	dc.b	21,22,22,23,23,24,24,24,25,25,26,26,27,27,28,28
	dc.b	29
MasterVolTab30:
	dc.b	0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7
	dc.b	7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14
	dc.b	15,15,15,16,16,17,17,18,18,19,19,20,20,21,21,22
	dc.b	22,22,23,23,24,24,25,25,26,26,27,27,28,28,29,29
	dc.b	30
MasterVolTab31:
	dc.b	0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7
	dc.b	7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15
	dc.b	15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22
	dc.b	23,23,24,24,25,25,26,26,27,27,28,28,29,29,30,30
	dc.b	31
MasterVolTab32:
	dc.b	0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
	dc.b	8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
	dc.b	16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23
	dc.b	24,24,25,25,26,26,27,27,28,28,29,29,30,30,31,31
	dc.b	32
MasterVolTab33:
	dc.b	0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
	dc.b	8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
	dc.b	16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,24
	dc.b	24,25,25,26,26,27,27,28,28,29,29,30,30,31,31,32
	dc.b	33
MasterVolTab34:
	dc.b	0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
	dc.b	8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16
	dc.b	17,17,18,18,19,19,20,20,21,21,22,22,23,23,24,24
	dc.b	25,26,26,27,27,28,28,29,29,30,30,31,31,32,32,33
	dc.b	34
MasterVolTab35:
	dc.b	0,0,1,1,2,2,3,3,4,4,5,6,6,7,7,8
	dc.b	8,9,9,10,10,11,12,12,13,13,14,14,15,15,16,16
	dc.b	17,18,18,19,19,20,20,21,21,22,22,23,24,24,25,25
	dc.b	26,26,27,27,28,28,29,30,30,31,31,32,32,33,33,34
	dc.b	35
MasterVolTab36:
	dc.b	0,0,1,1,2,2,3,3,4,5,5,6,6,7,7,8
	dc.b	9,9,10,10,11,11,12,12,13,14,14,15,15,16,16,17
	dc.b	18,18,19,19,20,20,21,21,22,23,23,24,24,25,25,26
	dc.b	27,27,28,28,29,29,30,30,31,32,32,33,33,34,34,35
	dc.b	36
MasterVolTab37:
	dc.b	0,0,1,1,2,2,3,4,4,5,5,6,6,7,8,8
	dc.b	9,9,10,10,11,12,12,13,13,14,15,15,16,16,17,17
	dc.b	18,19,19,20,20,21,21,22,23,23,24,24,25,26,26,27
	dc.b	27,28,28,29,30,30,31,31,32,32,33,34,34,35,35,36
	dc.b	37
MasterVolTab38:
	dc.b	0,0,1,1,2,2,3,4,4,5,5,6,7,7,8,8
	dc.b	9,10,10,11,11,12,13,13,14,14,15,16,16,17,17,18
	dc.b	19,19,20,20,21,21,22,23,23,24,24,25,26,26,27,27
	dc.b	28,29,29,30,30,31,32,32,33,33,34,35,35,36,36,37
	dc.b	38
MasterVolTab39:
	dc.b	0,0,1,1,2,3,3,4,4,5,6,6,7,7,8,9
	dc.b	9,10,10,11,12,12,13,14,14,15,15,16,17,17,18,18
	dc.b	19,20,20,21,21,22,23,23,24,24,25,26,26,27,28,28
	dc.b	29,29,30,31,31,32,32,33,34,34,35,35,36,37,37,38
	dc.b	39
MasterVolTab40:
	dc.b	0,0,1,1,2,3,3,4,5,5,6,6,7,8,8,9
	dc.b	10,10,11,11,12,13,13,14,15,15,16,16,17,18,18,19
	dc.b	20,20,21,21,22,23,23,24,25,25,26,26,27,28,28,29
	dc.b	30,30,31,31,32,33,33,34,35,35,36,36,37,38,38,39
	dc.b	40
MasterVolTab41:
	dc.b	0,0,1,1,2,3,3,4,5,5,6,7,7,8,8,9
	dc.b	10,10,11,12,12,13,14,14,15,16,16,17,17,18,19,19
	dc.b	20,21,21,22,23,23,24,24,25,26,26,27,28,28,29,30
	dc.b	30,31,32,32,33,33,34,35,35,36,37,37,38,39,39,40
	dc.b	41
MasterVolTab42:
	dc.b	0,0,1,1,2,3,3,4,5,5,6,7,7,8,9,9
	dc.b	10,11,11,12,13,13,14,15,15,16,17,17,18,19,19,20
	dc.b	21,21,22,22,23,24,24,25,26,26,27,28,28,29,30,30
	dc.b	31,32,32,33,34,34,35,36,36,37,38,38,39,40,40,41
	dc.b	42
MasterVolTab43:
	dc.b	0,0,1,2,2,3,4,4,5,6,6,7,8,8,9,10
	dc.b	10,11,12,12,13,14,14,15,16,16,17,18,18,19,20,20
	dc.b	21,22,22,23,24,24,25,26,26,27,28,28,29,30,30,31
	dc.b	32,32,33,34,34,35,36,36,37,38,38,39,40,40,41,42
	dc.b	43
MasterVolTab44:
	dc.b	0,0,1,2,2,3,4,4,5,6,6,7,8,8,9,10
	dc.b	11,11,12,13,13,14,15,15,16,17,17,18,19,19,20,21
	dc.b	22,22,23,24,24,25,26,26,27,28,28,29,30,30,31,32
	dc.b	33,33,34,35,35,36,37,37,38,39,39,40,41,41,42,43
	dc.b	44
MasterVolTab45:
	dc.b	0,0,1,2,2,3,4,4,5,6,7,7,8,9,9,10
	dc.b	11,11,12,13,14,14,15,16,16,17,18,18,19,20,21,21
	dc.b	22,23,23,24,25,26,26,27,28,28,29,30,30,31,32,33
	dc.b	33,34,35,35,36,37,37,38,39,40,40,41,42,42,43,44
	dc.b	45
MasterVolTab46:
	dc.b	0,0,1,2,2,3,4,5,5,6,7,7,8,9,10,10
	dc.b	11,12,12,13,14,15,15,16,17,17,18,19,20,20,21,22
	dc.b	23,23,24,25,25,26,27,28,28,29,30,30,31,32,33,33
	dc.b	34,35,35,36,37,38,38,39,40,40,41,42,43,43,44,45
	dc.b	46
MasterVolTab47:
	dc.b	0,0,1,2,2,3,4,5,5,6,7,8,8,9,10,11
	dc.b	11,12,13,13,14,15,16,16,17,18,19,19,20,21,22,22
	dc.b	23,24,24,25,26,27,27,28,29,30,30,31,32,33,33,34
	dc.b	35,35,36,37,38,38,39,40,41,41,42,43,44,44,45,46
	dc.b	47
MasterVolTab48:
	dc.b	0,0,1,2,3,3,4,5,6,6,7,8,9,9,10,11
	dc.b	12,12,13,14,15,15,16,17,18,18,19,20,21,21,22,23
	dc.b	24,24,25,26,27,27,28,29,30,30,31,32,33,33,34,35
	dc.b	36,36,37,38,39,39,40,41,42,42,43,44,45,45,46,47
	dc.b	48
MasterVolTab49:
	dc.b	0,0,1,2,3,3,4,5,6,6,7,8,9,9,10,11
	dc.b	12,13,13,14,15,16,16,17,18,19,19,20,21,22,22,23
	dc.b	24,25,26,26,27,28,29,29,30,31,32,32,33,34,35,35
	dc.b	36,37,38,39,39,40,41,42,42,43,44,45,45,46,47,48
	dc.b	49
MasterVolTab50:
	dc.b	0,0,1,2,3,3,4,5,6,7,7,8,9,10,10,11
	dc.b	12,13,14,14,15,16,17,17,18,19,20,21,21,22,23,24
	dc.b	25,25,26,27,28,28,29,30,31,32,32,33,34,35,35,36
	dc.b	37,38,39,39,40,41,42,42,43,44,45,46,46,47,48,49
	dc.b	50
MasterVolTab51:
	dc.b	0,0,1,2,3,3,4,5,6,7,7,8,9,10,11,11
	dc.b	12,13,14,15,15,16,17,18,19,19,20,21,22,23,23,24
	dc.b	25,26,27,27,28,29,30,31,31,32,33,34,35,35,36,37
	dc.b	38,39,39,40,41,42,43,43,44,45,46,47,47,48,49,50
	dc.b	51
MasterVolTab52:
	dc.b	0,0,1,2,3,4,4,5,6,7,8,8,9,10,11,12
	dc.b	13,13,14,15,16,17,17,18,19,20,21,21,22,23,24,25
	dc.b	26,26,27,28,29,30,30,31,32,33,34,34,35,36,37,38
	dc.b	39,39,40,41,42,43,43,44,45,46,47,47,48,49,50,51
	dc.b	52
MasterVolTab53:
	dc.b	0,0,1,2,3,4,4,5,6,7,8,9,9,10,11,12
	dc.b	13,14,14,15,16,17,18,19,19,20,21,22,23,24,24,25
	dc.b	26,27,28,28,29,30,31,32,33,33,34,35,36,37,38,38
	dc.b	39,40,41,42,43,43,44,45,46,47,48,48,49,50,51,52
	dc.b	53
MasterVolTab54:
	dc.b	0,0,1,2,3,4,5,5,6,7,8,9,10,10,11,12
	dc.b	13,14,15,16,16,17,18,19,20,21,21,22,23,24,25,26
	dc.b	27,27,28,29,30,31,32,32,33,34,35,36,37,37,38,39
	dc.b	40,41,42,43,43,44,45,46,47,48,48,49,50,51,52,53
	dc.b	54
MasterVolTab55:
	dc.b	0,0,1,2,3,4,5,6,6,7,8,9,10,11,12,12
	dc.b	13,14,15,16,17,18,18,19,20,21,22,23,24,24,25,26
	dc.b	27,28,29,30,30,31,32,33,34,35,36,36,37,38,39,40
	dc.b	41,42,42,43,44,45,46,47,48,48,49,50,51,52,53,54
	dc.b	55
MasterVolTab56:
	dc.b	0,0,1,2,3,4,5,6,7,7,8,9,10,11,12,13
	dc.b	14,14,15,16,17,18,19,20,21,21,22,23,24,25,26,27
	dc.b	28,28,29,30,31,32,33,34,35,35,36,37,38,39,40,41
	dc.b	42,42,43,44,45,46,47,48,49,49,50,51,52,53,54,55
	dc.b	56
MasterVolTab57:
	dc.b	0,0,1,2,3,4,5,6,7,8,8,9,10,11,12,13
	dc.b	14,15,16,16,17,18,19,20,21,22,23,24,24,25,26,27
	dc.b	28,29,30,31,32,32,33,34,35,36,37,38,39,40,40,41
	dc.b	42,43,44,45,46,47,48,48,49,50,51,52,53,54,55,56
	dc.b	57
MasterVolTab58:
	dc.b	0,0,1,2,3,4,5,6,7,8,9,9,10,11,12,13
	dc.b	14,15,16,17,18,19,19,20,21,22,23,24,25,26,27,28
	dc.b	29,29,30,31,32,33,34,35,36,37,38,38,39,40,41,42
	dc.b	43,44,45,46,47,48,48,49,50,51,52,53,54,55,56,57
	dc.b	58
MasterVolTab59:
	dc.b	0,0,1,2,3,4,5,6,7,8,9,10,11,11,12,13
	dc.b	14,15,16,17,18,19,20,21,22,23,23,24,25,26,27,28
	dc.b	29,30,31,32,33,34,35,35,36,37,38,39,40,41,42,43
	dc.b	44,45,46,47,47,48,49,50,51,52,53,54,55,56,57,58
	dc.b	59
MasterVolTab60:
	dc.b	0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29
	dc.b	30,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44
	dc.b	45,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59
	dc.b	60
MasterVolTab61:
	dc.b	0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,16,17,18,19,20,20,21,22,23,24,25,26,27,28,29
	dc.b	30,31,32,33,34,35,36,37,38,39,40,40,41,42,43,44
	dc.b	45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60
	dc.b	61
MasterVolTab62:
	dc.b	0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
	dc.b	31,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45
	dc.b	46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61
	dc.b	62
MasterVolTab63:
	dc.b	0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
	dc.b	31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46
	dc.b	47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62
	dc.b	63
MasterVolTab64:
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	dc.b	32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
	dc.b	48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
	dc.b	64
	even
	CNOP 0,4
mt_audchan1temp	dcb.b	26
		dc.w	$0001	; voice #1 DMA bit
		dcb.b	16
	CNOP 0,4
mt_audchan2temp	dcb.b	26
		dc.w	$0002	; voice #2 DMA bit
		dcb.b	16
	CNOP 0,4
mt_audchan3temp	dcb.b	26
		dc.w	$0004	; voice #3 DMA bit
		dcb.b	16
	CNOP 0,4
mt_audchan4temp	dcb.b	26
		dc.w	$0008	; voice #4 DMA bit
		dcb.b	16
	CNOP 0,4
mt_SampleStarts
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr		dc.l	0
mt_PatternPos		dc.w	0
mt_DMACONtemp		dc.w	0
mt_Speed		dc.b	6
mt_Counter		dc.b	0
mt_SongPos		dc.b	0
mt_PBreakPos		dc.b	0
mt_PosJumpFlag		dc.b	0
mt_PBreakFlag		dc.b	0
mt_LowMask		dc.b	0
mt_PattDelayTime	dc.b	0
mt_PattDelayTime2	dc.b	0
mt_Enable		dc.b	0
	even
mt_ModuleEndPtr		dc.l	0
mt_Tempo		dc.w	0
mt_BPMcnt		dc.w	0
mt_MasterVolTab		ds.l	1
mt_MasterVol		dc.w	0

mt_EndMusicTrigger	dc.b 	0
mt_UpdateVis		dc.b	1
mt_Visualizer 		dc.w	$4000
			dc.w	$4000
			dc.w	$4000
			dc.w	$4000
	even
