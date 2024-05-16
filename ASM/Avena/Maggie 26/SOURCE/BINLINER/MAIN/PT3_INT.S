*****************************************************************************
;Paula-Pseudoregister
	DATA 
DFF096:		dc.w $0000		;Amiga:DMA-Controlregister

track_1_data:
DFF0A0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 1 ®®
DFF0A4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0A6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0A8:		dc.w $0000		;Amiga:Lautst„rke
DFF0AA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0AE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge

track_2_data:
DFF0B0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 2 ®®
DFF0B4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0B6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0B8:		dc.w $0000		;Amiga:Lautst„rke
DFF0BA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0BE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge

track_3_data:
DFF0C0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 3 ®®
DFF0C4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0C6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0C8:		dc.w $0000		;Amiga:Lautst„rke
DFF0CA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0CE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge

track_4_data:
DFF0D0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 4 ®®
DFF0D4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0D6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0D8:		dc.w $0000		;Amiga:Lautst„rke
DFF0DA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0DE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge

; SAMPLE REPLAY DATA:
; These regs don't actually exist on Amoeba of course
;   and aren't interpreted by the interpreter routine

track_5_data:
DFF0E0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 4 ®®
DFF0E4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0E6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0E8:		dc.w $0000		;Amiga:Lautst„rke
DFF0EA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0EE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge











;------------------ Stereo Data -----------------
; Can be expanded if desired
; ---------------- ë¡9ŒÈÞØ €¦åì -----------------
DemoFlag	dc.w 0


track_1_tat:	dc.w $0000
		ds.l 3
track_2_tat:	dc.w $7fff
		ds.l 3
track_3_tat:	dc.w $6000
		ds.l 3
track_4_tat:	dc.w $2000
		ds.l 3
track_5_tat:	dc.w $4000		;Samples in middle
		ds.l 3


*****************************************************************************

		rsreset
SamAddress	RS.L 1		;0
SamLength	RS.W 1		;4
SamPeriod	RS.W 1		;6
SamVolume	RS.W 1		;8
PseudoAddr	RS.L 1		;10
PseudoLoop	RS.W 1		;14

		rsreset
TatStereo	RS.W 1
TatJump		RS.L 1
TatSent		RS.L 1
TatFreq		RS.L 1





*****************************************************************
*               »» Protracker 3.00B playroutine ««              *
* Written by Tom "Outland" Bech and Ivar "Heatseeker" J. Olsen. *
* Based upon Protracker 1.1A playroutine written by Lars Hamre. *
*          VBlank version. Not optimised in any way.            *
*****************************************************************
* Call pt_InitMusic before start. Then call pt_PlayMusic at VB. *
* To stop the music, call pt_StopMusic.                         *
* Please note that in this version, all SetTempo commands are   *
* ignored. This assembly language program has been tested with  *
* the Devpac 3.0, AsmOne 1.2, MCAsm 1.5 and a68k assemblers and *
* may have to be modified for other assemblers.                 *
*****************************************************************

; FileFormat offsets
sd_songname	EQU	0	;songname offset
sd_sampleinfo	EQU	20	;first sample starts here
sd_numofpatt	EQU	950	;number of patterns are stored here

sd_restartpatt	EQU	951	;restart pattern [TAT]

sd_pattpos	EQU	952	;pattern positions table is here
sd_mahokakt	EQU	1080	;"M.K." :)
sd_patterndata	EQU	1084	;first pattern starts at this position

; Song offsets. W/L/B means word/longword/byte length.
n_note		EQU	0  	;W
n_cmd		EQU	2  	;W
n_cmdlo		EQU	3  	;low B of cmd
n_start		EQU	4  	;L
n_length	EQU	8  	;W
n_loopstart	EQU	10 	;L
n_replen	EQU	14 	;W
n_period	EQU	16 	;W
n_finetune	EQU	18 	;B
n_volume	EQU	19 	;B
n_dmabit	EQU	20 	;W
n_toneportdirec	EQU	22 	;B
n_toneportspeed	EQU	23 	;B
n_wantedperiod	EQU	24 	;W
n_vibratocmd	EQU	26 	;B
n_vibratopos	EQU	27 	;B
n_tremolocmd	EQU	28 	;B
n_tremolopos	EQU	29 	;B
n_wavecontrol	EQU	30 	;B
n_glissfunk	EQU	31 	;B
n_sampleoffset	EQU	32 	;B
n_pattpos	EQU	33 	;B
n_loopcount	EQU	34 	;B
n_funkoffset	EQU	35 	;B
n_wavestart	EQU	36 	;L
n_reallength	EQU	40 	;W
n_trigger	EQU	42 	;B
n_samplenum	EQU	43 	;B

***************************************************************************
dff096_contr:
	move.w	d0,-(sp)
	move.w	4+2(sp),d0
	btst	#15,d0					;Bits setzen?
	bne.s	ap_bits_set
	not.w	d0
	and.w	d0,DFF096				;Bits l”schen
	bra.s	dff096_contr_end
ap_bits_set:
	or.w	d0,DFF096				;Bits setzen
dff096_contr_end:
	move.w	(sp)+,d0
	rts
*****************************************************************************

pt_InitMusic

*****************************************************************************

; This section by Chris and Aeon of Aura....
; ....but most of it was in the original player


	move.l	a6,pt_SongDataPtr	;Moduladr. speichern
	lea	sd_numofpatt(a6),a0	;songlength-adresse
	cmpm.b 	(a0)+,(a0)+		;repeat <= songlength
	bls.s 	ap_no_buggy		;dann alles ok
	clr.b 	-1(a0)			;sonst bug entfernen

;a0: sequenzer-adresse
ap_no_buggy:
	moveq 	#128-1,d0		;max.128 positions
	moveq 	#0,d1			;max-pattern = 0

ap_search_max:
	cmp.b 	(a0)+,d1		;pattern > d1
	bhi.s 	ap_searching		;sonst weitersuchen
	move.b 	-1(a0),d1		;max bernehmen
ap_searching:
	dbra 	d0,ap_search_max	;alle 128 positions durchsuchen
	addq.l 	#1,d1			;max-pattern +1
	moveq 	#10,d0			;10 mal shiften
	lsl.l 	d0,d1			;*1024 (1024 bytes pro pattern)

	lea	(a6),a0			;module-adresse
	lea	$0014+$0016(a0),a1	;zeiger aus l„nge sample 1
	lea	$043c(a0),a0		;offset zu den patterns
	adda.l 	d1,a0			;adresse sample 1
	lea	pt_SampleStarts(pc),a2	;sample-tabelle
	moveq 	#31-1,d0		;max.31 instumente
	moveq 	#0,d2			;anzahl intrumente = 0
			
ap_set_tabl:
	move.l 	a0,(a2)+		;adresse in tabelle eintragen
	moveq 	#0,d1			;d1.l l”schen
	move.w 	(a1),d1			;sample-length lesen
	beq.s 	ap_any_spl		;0:kein sample
	lea	(a0,d1.l*2),a0		;Adr. des n„chsten Samples
	addq.w 	#1,d2			;instrumenten-anzahl erh”hen
ap_any_spl:
	lea	$001e(a1),a1		;zeiger auf n„chste l„nge setzen
	dbra 	d0,ap_set_tabl		;alle 31 samples

;d2.l:anzahl der instrumente
;a1.l:ende sample-l„ngen + $1e
;a2.l:ende sample-tab +	4

*****************************************************************************
	MOVE.B	#6,pt_Speed		;default speed
	MOVE.W	#$7D,RealTempo		;TaT

*	OR.B	#2,$BFE001
	MOVEQ	#0,D0
	LEA	DFF0A0,A0
	MOVE.W	D0,$08(A0)
	MOVE.W	D0,$18(A0)
	MOVE.W	D0,$28(A0)
	MOVE.W	D0,$38(A0)

; Reset tune data:
	CLR.B	pt_SongPos
	CLR.B	pt_Counter
	CLR.W	pt_PattPos

	CLR.L	pt_Counter
	MOVE.L	#6,pt_CurrSpeed
	MOVE.W	#0,pt_DMACONtemp
	MOVE.W	#%1111,pt_ActiveChannels
	CLR.L	pt_SongPosition
	CLR.L	pt_PatternPtr
	CLR.L	pt_PatternPosition

	LEA	pt_audchan1temp(PC),A0
	BSR	pt_ClearChannel
	LEA	pt_audchan2temp(PC),A0
	BSR	pt_ClearChannel
	LEA	pt_audchan3temp(PC),A0
	BSR	pt_ClearChannel
	LEA	pt_audchan4temp(PC),A0
	BSR	pt_ClearChannel

	move.w	#$000f,-(sp)
	bsr	dff096_contr
	addq.w	#2,sp
	RTS

pt_ClearChannel:
	REPT	5
	CLR.L	(A0)+
	ENDR
	TST.L	(A0)+
	REPT	5
	CLR.L	(A0)+
	ENDR
	RTS


*pt_StopMusic
*	MOVEM.L	D0/A0,-(SP)
*	MOVEQ	#0,D0
*	LEA	DFF0A0,A0
*	MOVE.W	D0,$08(A0)
*	MOVE.W	D0,$18(A0)
*	MOVE.W	D0,$28(A0)
*	MOVE.W	D0,$38(A0)
*	MOVE.W	#$000F,DFF096		;stop AudioDMA activity
*	MOVEM.L	(SP)+,D0/A0
*	RTS

pt_PlayMusic
*	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	pt_SongDataPtr(PC),A0
	ADDQ.L	#1,pt_Counter
	MOVE.L	pt_Counter(PC),D0
	CMP.L	pt_CurrSpeed(PC),D0
	BLO.B	pt_NoNewNote
	CLR.L	pt_Counter
	TST.B	pt_PattDelayTime2
	BEQ.B	pt_GetNewNote
	BSR.B	pt_NoNewAllChannels
	BRA.W	pt_dskip

pt_NoNewNote
	BSR.B	pt_NoNewAllChannels
	BRA.W	pt_NoNewPositionYet

pt_NoNewAllChannels
	LEA	pt_audchan1temp(PC),A6
	LEA	DFF0A0,A5
	BSR.W	pt_CheckEffects
	LEA	pt_audchan2temp(PC),A6
	LEA	DFF0B0,A5
	BSR.W	pt_CheckEffects
	LEA	pt_audchan3temp(PC),A6
	LEA	DFF0C0,A5
	BSR.W	pt_CheckEffects
	LEA	pt_audchan4temp(PC),A6
	LEA	DFF0D0,A5
	BRA.W	pt_CheckEffects

pt_GetNewNote
	LEA	12(A0),A3
	LEA	sd_pattpos(A0),A2
	LEA	sd_patterndata(A0),A0
	MOVEQ	#0,D1
	MOVE.L	pt_SongPosition(PC),D0
	MOVE.B	0(a2,D0.W),D1
	ASL.L	#8,D1				;*1024
	ASL.L	#2,D1

	ADD.L	pt_PatternPosition(PC),D1
	MOVE.L	D1,pt_PatternPtr
	CLR.W	pt_DMACONtemp
	LEA	DFF0A0,A5
	LEA	pt_audchan1temp(PC),A6
	MOVEQ	#1,D2
	BSR.W	pt_PlayVoice
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	LEA	DFF0B0,A5
	LEA	pt_audchan2temp(PC),A6
	MOVEQ	#2,D2
	BSR.B	pt_PlayVoice
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	LEA	DFF0C0,A5
	LEA	pt_audchan3temp(PC),A6
	MOVEQ	#3,D2
	BSR.B	pt_PlayVoice
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	LEA	DFF0D0,A5
	LEA	pt_audchan4temp(PC),A6
	MOVEQ	#4,D2
	BSR.B	pt_PlayVoice
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	BRA.W	pt_SetDMA

pt_CheckMetronome
	CMP.B	pt_MetroChannel,D2
	BNE.W	pt_Return
	MOVE.B	pt_MetroSpeed,D2
	BEQ.W	pt_Return
	MOVE.L	pt_PatternPosition,D3
	LSR.L	#4,D3
	DIVU	D2,D3
	SWAP	D3
	TST.W	D3
	BNE.W	pt_Return
	AND.L	#$00000FFF,(A6)
	OR.L	#$10D6F000,(A6) 	;Play sample $1F at period $0D6 (214)
	RTS

pt_PlayVoice
	TST.L	(A6)
	BNE.B	pt_plvskip
	BSR.W	pt_PerNop
pt_plvskip
	MOVE.L	0(a0,D1.L),(A6)		;Read one track from pattern
	BSR.B	pt_CheckMetronome
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2		;Get lower 4 bits of instrument
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0			;Get higher 4 bits of instrument
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ.B	pt_SetRegisters		;Instrument was zero
	MOVEQ	#0,D3
	LEA	pt_SampleStarts(PC),A1
	MOVE	D2,D4
	MOVE.B	D2,n_samplenum(A6)
	SUBQ.L	#1,D2
	LSL.L	#2,D2
	MULU	#30,D4
	MOVE.L	0(a1,D2.L),n_start(A6)
	MOVE.W	0(a3,D4.L),n_length(A6)
	MOVE.W	0(a3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 		;Get repeat
	TST.W	D3
	BEQ.B	pt_NoLoop
	MOVE.L	n_start(A6),D2		;Get start
	ASL.W	#1,D3
	ADD.L	D3,D2			;Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0		;Get repeat
	ADD.W	6(A3,D4.L),D0		;Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	;Save replen
	BRA.B	pt_SetRegisters

pt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	;Save replen
pt_SetRegisters
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	pt_CheckMoreEffects	;If no note ->
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0 		;finetune?
	BEQ.B	pt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0			;TonePortamento?
	BEQ.B	pt_ChkTonePorta
	CMP.B	#5,D0			;TonePortamento + VolSlide?
	BEQ.B	pt_ChkTonePorta
	CMP.B	#9,D0			;Sample Offset?
	BNE.B	pt_SetPeriod
	BSR.W	pt_CheckMoreEffects
	BRA.B	pt_SetPeriod

pt_DoSetFineTune
	BSR.W	pt_SetFineTune
	BRA.B	pt_SetPeriod

pt_ChkTonePorta
	BSR.W	pt_SetTonePorta
	BRA.W	pt_CheckMoreEffects

pt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	pt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#$24,D7
pt_ftuloop
	CMP.W	0(a1,D0.W),D1
	BHS.B	pt_ftufound
	ADDQ.L	#2,D0
	DBRA	D7,pt_ftuloop
pt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#37*2,D1
	ADD.L	D1,A1
	MOVE.W	0(a1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0
	BEQ.W	pt_CheckMoreEffects

*	MOVE.W	n_dmabit(A6),DFF096
	move.w	n_dmabit(a6),-(sp)
	bsr	dff096_contr
	addq.w	#2,sp
	BTST	#2,n_wavecontrol(A6)
	BNE.B	pt_vibnoc
	CLR.B	n_vibratopos(A6)
pt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.B	pt_trenoc
	CLR.B	n_tremolopos(A6)
pt_trenoc
	MOVE.W	n_length(A6),4(A5)	;Set length
	MOVE.L	n_start(A6),(A5)	;Set start
	BNE.B	pt_sdmaskp
	CLR.L	n_loopstart(A6)
	MOVEQ	#1,D0
	MOVE.W	D0,4(A5)
	MOVE.W	D0,n_replen(A6)
pt_sdmaskp
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		;Set period
	ST	n_trigger(A6)
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,pt_DMACONtemp
	BRA.W	pt_CheckMoreEffects
 
pt_SetDMA
*	move.b	pt_timeout,$bfe701	;TimerB HI
*	move.b	pt_timeout+1,$bfe601	;TimerB LO
*	move.b	#%000011001,$bfef01	;set commandbits: OneShot & CLK & Start
*pt_timerwait1
*	btst	#0,$bfef01		;timeout on timerB? (ICR TimerB)
*	bne.s	pt_timerwait1		;nope...
	MOVE.W	pt_DMACONtemp,D0
	AND.W	pt_ActiveChannels,D0	;mask out inactive channels
	OR.W	#$8000,D0
*	MOVE.W	D0,DFF096
	move.w	d0,-(sp)
	bsr	dff096_contr
	addq.w	#2,sp
*	move.b	pt_timeout,$bfe701	;TimerB HI
*	move.b	pt_timeout+1,$bfe601	;TimerB LO
*	move.b	#%000011001,$bfef01	;set commandbits: OneShot & CLK & Start
*pt_timerwait2
*	btst	#0,$bfef01		;timeout on timerB? (ICR TimerB)
*	bne.s	pt_timerwait2		;nope...
	LEA	DFF0A0,A5
	LEA	pt_audchan4temp(PC),A6
	MOVE.L	n_loopstart(A6),$D0-$a0+10(A5)
	MOVE.W	n_replen(A6),$D4-$a0+10(A5)
	LEA	pt_audchan3temp(PC),A6
	MOVE.L	n_loopstart(A6),$C0-$a0+10(A5)
	MOVE.W	n_replen(A6),$C4-$a0+10(A5)
	LEA	pt_audchan2temp(PC),A6
	MOVE.L	n_loopstart(A6),$B0-$a0+10(A5)
	MOVE.W	n_replen(A6),$B4-$a0+10(A5)
	LEA	pt_audchan1temp(PC),A6
	MOVE.L	n_loopstart(A6),$A0-$a0+10(A5)
	MOVE.W	n_replen(A6),$A4-$a0+10(A5)

pt_dskip
	ADD.L	#16,pt_PatternPosition
	MOVE.B	pt_PattDelayTime,D0
	BEQ.B	pt_dskpc
	MOVE.B	D0,pt_PattDelayTime2
	CLR.B	pt_PattDelayTime
pt_dskpc
	TST.B	pt_PattDelayTime2
	BEQ.B	pt_dskpa
	SUBQ.B	#1,pt_PattDelayTime2
	BEQ.B	pt_dskpa
	SUB.L	#16,pt_PatternPosition
pt_dskpa
	TST.B	pt_PBreakFlag
	BEQ.B	pt_nnpysk
	SF	pt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	pt_PBreakPosition(PC),D0
	LSL.W	#4,D0
	MOVE.L	D0,pt_PatternPosition
	CLR.B	pt_PBreakPosition
pt_nnpysk
	CMP.L	#1024,pt_PatternPosition
	BNE.B	pt_NoNewPositionYet
pt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	pt_PBreakPosition(PC),D0
	LSL.W	#4,D0
	MOVE.L	D0,pt_PatternPosition
	CLR.B	pt_PBreakPosition
	CLR.B	pt_PosJumpAssert
	ADDQ.L	#1,pt_SongPosition
	AND.L	#$7F,pt_SongPosition
	MOVE.L	pt_SongPosition(PC),D1
	MOVE.L	pt_SongDataPtr(PC),A0
	CMP.B	sd_numofpatt(A0),D1
	BLO.B	pt_NoNewPositionYet

; Restart the tune:

	;CLR.L	pt_SongPosition
	MOVEQ	#0,D1
	MOVE.B	sd_restartpatt(A0),D1		;TAT
	MOVE.L	D1,pt_SongPosition

pt_NoNewPositionYet
	TST.B	pt_PosJumpAssert
	BNE.B	pt_NextPosition
*	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

pt_CheckEffects
	BSR.B	pt_chkefx2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

pt_chkefx2
	BSR.W	pt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.B	pt_Return
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	TST.B	D0
	BEQ.B	pt_Arpeggio
	CMP.B	#1,D0
	BEQ.W	pt_PortaUp
	CMP.B	#2,D0
	BEQ.W	pt_PortaDown
	CMP.B	#3,D0
	BEQ.W	pt_TonePortamento
	CMP.B	#4,D0
	BEQ.W	pt_Vibrato
	CMP.B	#5,D0
	BEQ.W	pt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ.W	pt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ.W	pt_ECommands
pt_SetBack
	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ.W	pt_Tremolo
	CMP.B	#$A,D0
	BEQ.W	pt_VolumeSlide
pt_Return
	RTS

pt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

pt_Arpeggio
	MOVEQ	#0,D0
	MOVE.L	pt_Counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#1,D0
	BEQ.B	pt_Arpeggio1
	CMP.W	#2,D0
	BEQ.B	pt_Arpeggio2
pt_Arpeggio0
	MOVE.W	n_period(A6),D2
	BRA.B	pt_ArpeggioSet

pt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.B	pt_ArpeggioFind

pt_Arpeggio2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
pt_ArpeggioFind
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#37*2,D1
	LEA	pt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#$24,D7
pt_arploop
	MOVE.W	0(a0,D0.W),D2
	CMP.W	(A0),D1
	BHS.B	pt_ArpeggioSet
	ADDQ.L	#2,A0
	DBRA	D7,pt_arploop
	RTS

pt_ArpeggioSet
	MOVE.W	D2,6(A5)
	RTS

pt_FinePortaUp
	TST.L	pt_Counter
	BNE.B	pt_Return
	MOVE.B	#$0F,pt_LowMask
pt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	pt_LowMask,D0
	MOVE.B	#$FF,pt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#$0071,D0
	BPL.B	pt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#$0071,n_period(A6)
pt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

pt_FinePortaDown
	TST.L	pt_Counter
	BNE.W	pt_Return
	MOVE.B	#$0F,pt_LowMask
pt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	pt_LowMask,D0
	MOVE.B	#$FF,pt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#$0358,D0
	BMI.B	pt_Portadskip
	AND.W	#$F000,n_period(A6)
	OR.W	#$0358,n_period(A6)
pt_Portadskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

pt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	pt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
pt_StpLoop
	CMP.W	0(a0,D0.W),D2
	BHS.B	pt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.B	pt_StpLoop
	MOVEQ	#35*2,D0
pt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.B	pt_StpGoss
	TST.W	D0
	BEQ.B	pt_StpGoss
	SUBQ.W	#2,D0
pt_StpGoss
	MOVE.W	0(a0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.B	pt_ClearTonePorta
	BGE.W	pt_Return
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

pt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS	
 
pt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	pt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
pt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ.W	pt_Return
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.B	pt_TonePortaUp
pt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.B	pt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.B	pt_TonePortaSetPer

pt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.B	pt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

pt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.B	pt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	pt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
pt_GlissLoop
	CMP.W	0(a0,D0.W),D2
	BHS.B	pt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.B	pt_GlissLoop
	MOVEQ	#35*2,D0
pt_GlissFound
	MOVE.W	0(a0,D0.W),D2
pt_GlissSkip
	MOVE.W	D2,6(A5) 		;Set period
	RTS

pt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	pt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.B	pt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
pt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.B	pt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
pt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
pt_Vibrato2
	MOVE.L	A4,-(SP)
	MOVE.B	n_vibratopos(A6),D0
	LEA	pt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.B	pt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.B	pt_vib_rampdown
	MOVE.B	#255,D2
	BRA.B	pt_vib_set
pt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.B	pt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.B	pt_vib_set
pt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.B	pt_vib_set
pt_vib_sine
	MOVE.B	0(A4,D0.W),D2
pt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.B	pt_VibratoNeg
	ADD.W	D2,D0
	BRA.B	pt_Vibrato3
pt_VibratoNeg
	SUB.W	D2,D0
pt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	MOVE.L	(SP)+,A4
	RTS

pt_TonePlusVolSlide
	BSR.W	pt_TonePortNoChange
	BRA.W	pt_VolumeSlide

pt_VibratoPlusVolSlide
	BSR.B	pt_Vibrato2
	BRA.W	pt_VolumeSlide

pt_Tremolo
	MOVE.L	A4,-(SP)
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	pt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.B	pt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
pt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.B	pt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
pt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
pt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	pt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.B	pt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.B	pt_tre_rampdown
	MOVE.B	#255,D2
	BRA.B	pt_tre_set
pt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.B	pt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.B	pt_tre_set
pt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.B	pt_tre_set
pt_tre_sine
	MOVE.B	0(A4,D0.W),D2
pt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.B	pt_TremoloNeg
	ADD.W	D2,D0
	BRA.B	pt_Tremolo3
pt_TremoloNeg
	SUB.W	D2,D0
pt_Tremolo3
	BPL.B	pt_TremoloSkip
	CLR.W	D0
pt_TremoloSkip
	CMP.W	#$40,D0
	BLS.B	pt_TremoloOk
	MOVE.W	#$40,D0
pt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	MOVE.L	(SP)+,A4
	ADDQ.L	#4,SP
	RTS

pt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	pt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
pt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	;SL.W	#8,D0
	CMP.W	n_length(A6),D0
	BGE.B	pt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
pt_sofskip
	MOVE.W	#1,n_length(A6)
	RTS

pt_DemoFlag
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.B	pt_sononew
	MOVE.W	D0,DemoFlag
	RTS

pt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.B	pt_VolSlideDown
pt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.B	pt_vsuskip
	MOVE.B	#$40,n_volume(A6)
pt_vsuskip
	MOVE.B	n_volume(A6),D0
	RTS

pt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
pt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.B	pt_vsdskip
	CLR.B	n_volume(A6)
pt_vsdskip
	MOVE.B	n_volume(A6),D0
	RTS

pt_PositionJump
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.L	D0,pt_SongPosition
pt_pj2	CLR.B	pt_PBreakPosition
	ST 	pt_PosJumpAssert
	RTS

pt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.B	pt_VolumeOk
	MOVEQ	#$40,D0
pt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	RTS

pt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.B	pt_pj2
	MOVE.B	D0,pt_PBreakPosition
	ST	pt_PosJumpAssert
	RTS

pt_SetSpeed
	MOVE.B	3(A6),D0
	AND.W	#$FF,D0
	BEQ.B	pt_SpeedNull
	CMP.W	#32,D0			;change this for lev6/CIA users
	BLO.B	pt_normspd		;it updates the countervalues (Tempo)
	MOVE.W	D0,RealTempo		;for the BPM timer

	;MOVEM.L	D0-D7/A0-A6,-(SP)
	;ST	UpdateTempo
	;JSR	SetTempo
	;MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
pt_normspd
	CLR.L	pt_Counter
	MOVE.W	D0,pt_CurrSpeed+2
	RTS
pt_SpeedNull
	RTS

pt_CheckMoreEffects
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$8,D0
	BEQ.W	pt_DemoFlag
	CMP.B	#$9,D0
	BEQ.W	pt_SampleOffset
	CMP.B	#$B,D0
	BEQ.W	pt_PositionJump
	CMP.B	#$D,D0
	BEQ.B	pt_PatternBreak
	CMP.B	#$E,D0
	BEQ.B	pt_ECommands
	CMP.B	#$F,D0
	BEQ.B	pt_SetSpeed
	CMP.B	#$C,D0
	BEQ.W	pt_VolumeChange
	BRA.W	pt_PerNop

pt_ECommands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.B	pt_FilterOnOff
	CMP.B	#1,D0
	BEQ.W	pt_FinePortaUp
	CMP.B	#2,D0
	BEQ.W	pt_FinePortaDown
	CMP.B	#3,D0
	BEQ.B	pt_SetGlissControl
	CMP.B	#4,D0
	BEQ.W	pt_SetVibratoControl
	CMP.B	#5,D0
	BEQ.W	pt_SetFineTune
	CMP.B	#6,D0
	BEQ.W	pt_JumpLoop
	CMP.B	#7,D0
	BEQ.W	pt_SetTremoloControl
	CMP.B	#8,D0
	BEQ.W	pt_KarplusStrong
	CMP.B	#$E,D0
	BEQ.W	pt_PatternDelay
	CMP.B	#9,D0
	BEQ.W	pt_RetrigNote
	CMP.B	#$A,D0
	BEQ.W	pt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ.W	pt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ.W	pt_NoteCut
	CMP.B	#$D,D0
	BEQ.W	pt_NoteDelay
	CMP.B	#$F,D0
	BEQ.W	pt_FunkIt
	RTS

pt_FilterOnOff
*	MOVE.B	n_cmdlo(A6),D0
*	AND.B	#1,D0
*	ASL.B	#1,D0
*	AND.B	#$FD,$BFE001
*	OR.B	D0,$BFE001
	RTS	

pt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

pt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

pt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

pt_JumpLoop
	TST.L	pt_Counter
	BNE.W	pt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.B	pt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.B	pt_jumpcnt
	SUB.B	#1,n_loopcount(A6)
	BEQ.W	pt_Return
pt_jmploop
	MOVE.B	n_pattpos(A6),pt_PBreakPosition
	ST	pt_PBreakFlag
	RTS

pt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.B	pt_jmploop

pt_SetLoop
	MOVE.L	pt_PatternPosition,D0
	LSR.L	#4,D0
	AND.B	#63,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

pt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

pt_KarplusStrong
	MOVEM.L	D1-D2/A0-A1,-(SP)
	MOVE.L	n_loopstart(A6),A0
	MOVE.L	A0,A1
	MOVE.W	n_replen(A6),D0
	ADD.W	D0,D0
	SUBQ.W	#2,D0
pt_karplop
	MOVE.B	(A0),D1
	EXT.W	D1
	MOVE.B	1(A0),D2
	EXT.W	D2
	ADD.W	D1,D2
	ASR.W	#1,D2
	MOVE.B	D2,(A0)+
	DBRA	D0,pt_karplop
	MOVE.B	(A0),D1
	EXT.W	D1
	MOVE.B	(A1),D2
	EXT.W	D2
	ADD.W	D1,D2
	ASR.W	#1,D2
	MOVE.B	D2,(A0)
	MOVEM.L	(SP)+,D1-D2/A0-A1
	RTS

pt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.W	pt_rtnend
	MOVE.L	pt_Counter,D1
	BNE.B	pt_rtnskp
	MOVE.W	n_note(A6),D1
	AND.W	#$0FFF,D1
	BNE.W	pt_rtnend
	MOVE.L	pt_Counter,D1
pt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.W	pt_rtnend
pt_DoRetrg
*	MOVE.W	n_dmabit(A6),DFF096	;Audio DMA off
*	move.w	n_dmabit(a6),-(sp)
*	bsr	dff096_contr
*	addq.w	#2,sp
	MOVE.L	n_start(A6),(A5)	;Set sampledata pointer
	MOVE.W	n_length(A6),4(A5)	;Set length
	MOVE.W	n_period(A6),6(A5)
*	MOVEQ	#0,D0
*	MOVE.B	n_volume(A6),D0

*	move.b	pt_timeout,$bfe701	;TimerB HI
*	move.b	pt_timeout+1,$bfe601	;TimerB LO
*	move.b	#%000011001,$bfef01	;set commandbits: OneShot & CLK & Start
*pt_timerwait3
*	btst	#0,$bfef01		;timeout on timerB? (ICR TimerB)
*	bne.s	pt_timerwait3		;nope...

*	MOVE.W	n_dmabit(A6),D0
*	BSET	#15,D0
*	MOVE.W	D0,DFF096
*	move.w	d0,-(sp)
*	bsr	dff096_contr
*	addq.w	#2,sp
*	move.b	pt_timeout,$bfe701	;TimerB HI
*	move.b	pt_timeout+1,$bfe601	;TimerB LO
*	move.b	#%000011001,$bfef01	;set commandbits: OneShot & CLK & Start
*pt_timerwait4
*	btst	#0,$bfef01		;timeout on timerB? (ICR TimerB)
*	bne.s	pt_timerwait4		;nope...

	MOVE.L	n_loopstart(A6),0+10(A5)
	MOVE.w	n_replen(A6),4+10(A5)	;war .l
pt_rtnend
	MOVE.L	(SP)+,D1
	RTS

pt_VolumeFineUp
	TST.L	pt_Counter
	BNE.W	pt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA.W	pt_VolSlideUp

pt_VolumeFineDown
	TST.L	pt_Counter
	BNE.W	pt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA.W	pt_VolSlideDown2

pt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.L	pt_Counter,D0
	BNE.W	pt_Return
	CLR.B	n_volume(A6)
	RTS

pt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.L	pt_Counter,D0
	BNE.W	pt_Return
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	pt_Return
	MOVE.L	D1,-(SP)
	BRA.W	pt_DoRetrg

pt_PatternDelay
	TST.L	pt_Counter
	BNE.W	pt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	pt_PattDelayTime2
	BNE.W	pt_Return
	ADDQ.B	#1,D0
	MOVE.B	D0,pt_PattDelayTime
	RTS

pt_FunkIt
	TST.L	pt_Counter
	BNE.W	pt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ.W	pt_Return
pt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.B	pt_funkend
	LEA	pt_FunkTable(PC),A0
	MOVE.B	0(a0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.B	pt_funkend
	CLR.B	n_funkoffset(A6)
	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.B	pt_funkok
	MOVE.L	n_loopstart(A6),A0
pt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
pt_funkend
	MOVEM.L	(SP)+,A0/D1
	RTS

pt_FunkTable
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

pt_VibratoTable	
	dc.b 0,24,49,74,97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120,97,74,49,24

pt_PeriodTable
; -> Tuning 0
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113,0
; -> Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113,0
; -> Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112,0
; -> Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111,0
; -> Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110,0
; -> Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109,0
; -> Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109,0
; -> Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108,0
; -> Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120,0
; -> Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119,0
; -> Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118,0
; -> Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118,0
; -> Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117,0
; -> Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116,0
; -> Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115,0
; -> Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114,0

pt_audchan1temp	dc.l	0,0,0,0,0,$00010000,0,0,0,0,0
pt_audchan2temp	dc.l	0,0,0,0,0,$00020000,0,0,0,0,0
pt_audchan3temp	dc.l	0,0,0,0,0,$00040000,0,0,0,0,0
pt_audchan4temp	dc.l	0,0,0,0,0,$00080000,0,0,0,0,0

pt_SampleStarts	dcb.l	31,0

*pt_timeout	dc.w	330		;CIA-B timeout-value

pt_Counter	dc.l	0
pt_CurrSpeed	dc.l	6
pt_PattPos	dc.w	0
pt_DMACONtemp	dc.w	0
pt_ActiveChannels
		dc.w	%00001111
pt_PatternPtr	dc.l	0
pt_PatternPosition
		dc.l	0
pt_SongPosition	dc.l	0	
pt_SongDataPtr	dc.l	0
pt_MetroSpeed	dc.b	0
pt_MetroChannel	dc.b	0
pt_Speed	dc.b	6
pt_SongPos	dc.b	0
pt_PBreakPosition
		dc.b	0
pt_PosJumpAssert
		dc.b	0
pt_PBreakFlag	dc.b	0
pt_LowMask	dc.b	0
pt_PattDelayTime
		dc.b	0
pt_PattDelayTime2
		dc.b	0
RealTempo	dc.w	$7d

		even
