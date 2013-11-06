***************************************************************************
*
* PROC: MT_MUSIC		version: 0.004		date:	22/04/2013
*
*==========================================================================
* FUNCTION:
*	Protracker 2.X handler for Hacking Lance
* FILES:
*	- PTHDLxxx.S	this file
*==========================================================================
* HISTORY:
*--------------------------------------------------------------------------
*	DATE		TIME	FORM	PCS	COMMENTS	
*--------------------------------------------------------------------------
*	19/04/2013	10:00	C00??	0.000	First version
*	19/04/2013	16:00	C00??	0.001	Code improvements(New base)
*						Take out all (sp) saves
*						free all possible Ans/Dns
*						Give a job to each register
*						A0	pattern data(*)
*						A1	all purpose
*						A2	free
*						A3	(pc) addressing
*						A4	free
*						A5	DMA struct
*						A6	Voice data struct
*						D0	all purpose
*						D1	pattern offset(*)
*						D2-D3	all purpose
*						D4-D7	free
*						(*)	only when new note
*	20/04/2013	17:00	C00??	0.001	Add mt_PerNoteTab
*						to convert Period to Note
*						Impacts SetPer / Arpeggio
*						Tone Portamento / Gliss
*	20/04/2013	17:00	C00??	0.002	Add tables for Vibrato
*						and Tremolo
*	21/04/2013	10:00	C00??	0.003	Add mt_PT_data struct
*						addressed by (A4)
*						A2 and A3 are now free
*	21/04/2013	11:00	C00??	0.003	stop using D1 for pattern
*						data. Use on a0 => (a0)+
*						D1 can now be used anytime
*	21/04/2013	12:00	C00??	0.003	take out divu and divs from
*						Note Retriger and Arpeggio
*	21/04/2013	16:00	C00??	0.004	Split Playvoice effects
*						and NoNewAllvoices effects
*	21/04/2013	16:00	C00??	0.004	Take out AMIGA ONLY stuff
*						Filter + FunkIt
***************************************************************************
mt_music:
*****	movem.l	d0-d3/a0-a6,-(sp)

	lea	mt_PT_data(pc),a4
	move.b	bt_Arpeggioctr(a4),d0	Arpeggio counter
	addq.b	#1,d0
	cmp.b	#3,d0			modulated by 3
	sne	d3
	and.b	d3,d0
	move.b	d0,bt_Arpeggioctr(a4)	store new value
*	addq.b	#1,mt_counter		increment counter
	addq.b	#1,bt_counter(a4)	increment counter
*	move.b	mt_counter(pc),d0
	move.b	bt_counter(a4),d0
*	cmp.b	mt_speed(pc),d0		counter = speed ?
	cmp.b	bt_speed(a4),d0		counter = speed ?
	bcs	mt_NoNewNote		no / yes
*	clr.b	mt_counter		counter = 0
	clr.b	bt_counter(a4)		counter = 0
*	tst.b	mt_PattDelTime2		Pattern delay active ?
	tst.b	bt_PattDelTime2(a4)	Pattern delay active ?
	beq.s	mt_GetNewNote		yes / no
	bsr	mt_NoNewAllChannels	Only effects on all voices
	bra.s	mt_SetDMA

*******					Get new NOTE

mt_GetNewNote
	move.l	mt_SongDataPtr(pc),a0
	lea	$3B8(a0),a1			pattern index list
	lea	$43C(a0),a0			patterns
	moveq	#0,d0
	moveq	#0,d1
*	move.b	mt_SongPos(pc),d0		song position
	move.b	bt_SongPos(a4),d0		song position
	move.b	0(a1,d0),d1			pattern index
	add	d1,d1				x 2
	add	d1,d1				x 4
	lsl.l	#8,d1				x 1024
*	add	mt_PatternPos(pc),d1		0, 16, 32, 48 ...
	add	bt_PatternPos(a4),d1		0, 16, 32, 48 ...
	add.l	d1,a0				points to correct data

	lea	mt_channel_0(pc),a5
	lea	mt_chan1temp(pc),a6
	bsr	mt_PlayVoice
	lea	mt_channel_1(pc),a5
	lea	mt_chan2temp(pc),a6
	bsr	mt_PlayVoice
	lea	mt_channel_2(pc),a5
	lea	mt_chan3temp(pc),a6
	bsr	mt_PlayVoice
	lea	mt_channel_3(pc),a5
	lea	mt_chan4temp(pc),a6
	bsr	mt_PlayVoice

mt_SetDMA

mt_dskip

*	add	#16,mt_PatternPos	update internal pattern pointer
	add	#16,bt_PatternPos(a4)	update internal pattern pointer
*	move.b	mt_PattDelTime(pc),d0	Pattern delay set ?
	move.b	bt_PattDelTime(a4),d0	Pattern delay set ?
	beq.s	mt_dskc			yes / no
*	move.b	d0,mt_PattDelTime2	Set pattern delay counter
	move.b	d0,bt_PattDelTime2(a4)	Set pattern delay counter
*	clr.b	mt_PattDelTime		Reset input pattern delay data
	clr.b	bt_PattDelTime(a4)	Reset input pattern delay data
mt_dskc
*	tst.b	mt_PattDelTime2		Pattern delay counter = 0 ?
	tst.b	bt_PattDelTime2(a4)	Pattern delay counter = 0 ?
	beq.s	mt_dska			no / yes
*	subq.b	#1,mt_PattDelTime2	decrement counter
	subq.b	#1,bt_PattDelTime2(a4)	decrement counter
	beq.s	mt_dska			= 0 ? no / yes
*	sub	#16,mt_PatternPos	get back to previous pattern pointer
	sub	#16,bt_PatternPos(a4)	get back to previous pattern pointer
mt_dska
*	tst.b	mt_PBreakFlag		Pattern break set ?
	tst.b	bt_PBreakFlag(a4)	Pattern break set ?
	beq.s	mt_nnpysk		yes / no
*	sf	mt_PBreakFlag
	sf	bt_PBreakFlag(a4)
	moveq	#0,d0
*	move.b	mt_PBreakPos(pc),d0	Pattern break position
	move.b	bt_PBreakPos(a4),d0	Pattern break position
*	clr.b	mt_PBreakPos		clear pattern break position
	clr.b	bt_PBreakPos(a4)	clear pattern break position
	lsl	#4,d0			* 16 bytes per position
*	move	d0,mt_PatternPos	update internal pattern pointer
	move	d0,bt_PatternPos(a4)	update internal pattern pointer
mt_nnpysk
*	cmp	#1024,mt_PatternPos	end of pattern reached ?
	cmp	#1024,bt_PatternPos(a4)	end of pattern reached ?
	bcs.s	mt_NoNewPosYet		yes / no
mt_NextPosition
	moveq	#0,d0
*	move.b	mt_PBreakPos(pc),d0	Pattern break position
	move.b	bt_PBreakPos(a4),d0	Pattern break position
	lsl	#4,d0			* 16 bytes per position
*	move	d0,mt_PatternPos	update internal pattern pointer
	move	d0,bt_PatternPos(a4)	update internal pattern pointer
*	clr.b	mt_PBreakPos		clear pattern break position
	clr.b	bt_PBreakPos(a4)	clear pattern break position
*	clr.b	mt_PosJumpFlag		clear position jump flag
	clr.b	bt_PosJumpFlag(a4)	clear position jump flag
*	addq.b	#1,mt_SongPos		next song position
	addq.b	#1,bt_SongPos(a4)	next song position
*	and.b	#$7F,mt_SongPos		within 128 possible
	and.b	#$7F,bt_SongPos(a4)	within 128 possible
*	move.b	mt_SongPos(pc),d1
	move.b	bt_SongPos(a4),d1
	move.l	mt_SongDataPtr(pc),a0
	cmp.b	$3B6(a0),d1		End position reached ?
	bcs.s	mt_NoNewPosYet		yes / no
*	clr.b	mt_SongPos		position = 0
*	clr.b	bt_SongPos(a4)		position = 0
	move.b	$3B7(a0),bt_SongPos(a4)	restart position

	bra.s	mt_NoNewPosYet


mt_NoNewNote
	bsr	mt_NoNewAllChannels
mt_NoNewPosYet	
*	tst.b	mt_PosJumpFlag		Position flag set ?
	tst.b	bt_PosJumpFlag(a4)	Position flag set ?
	bne.s	mt_NextPosition		no / yes
*****	movem.l	(sp)+,d0-d3/a0-a6
	rts



*******					PLAYVOICE (new note for voice)

mt_PlayVoice
	tst.l	(a6)				any previous command ?
	bne.s	mt_plvskip			no / yes
	move	n_period(a6),mt_period(a5)	copy old period to DMA
mt_plvskip
*	move.l	0(a0,d1.l),(a6)		long word with playing data
*	addq.l	#4,d1			next long word
	move.l	(a0)+,(a6)		long word with playing data
	moveq	#0,d2
	move.b	2(a6),d2		3rd byte
	move	#$00F0,d3		mask for byte high nibble
	and	d3,d2			top nibble = sample low nibble
	lsr.b	#4,d2			now $0 .. $F
	move.b	(a6),d0			1st byte
	and	d3,d0			isolate high nibble
	or.b	d0,d2			sample $00 -> $FF (valid up to $1F)
	beq.s	mt_SetRegs		= 0 ? no / yes => no sample info

***						Handle NEW SAMPLE DATA

	lea	mt_SampleStarts(pc),a1	sample pointers
	subq	#1,d2			sample number - 1
	add	d2,d2			x 2
	move	d2,d3
	lsl	#4,d3			x 32
	sub	d2,d3			x 30
	add	d2,d2			x 4
	move.l	0(a1,d2),d2		sample pointer
	move.l	d2,n_start(a6)
	move.l	mt_SongDataPtr(pc),a1
	lea	20+22(a1,d3),a1		A1 points to sample info
	move	(a1)+,d0
	move	d0,n_length(a6)
	move	d0,n_reallength(a6)
	move.b	(a1)+,n_finetune(a6)
	move.b	(a1)+,n_volume(a6)
	moveq	#0,d3
	move	(a1)+,d3		repeat start
	move	d3,d0			in words
	add.l	d3,d3			in bytes
	add.l	d3,d2			pointer to loop start
	move.l	d2,n_loopstart(a6)
*******	move.l	d2,n_wavestart(a6)	AMIGA ONLY
	move	(a1)+,d3
	move	d3,n_replen(a6)		loop length
	beq.s	mt_samplewnoloop
	add	d3,d0			new length in words
	move	d0,n_length(a6)
mt_samplewnoloop
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,mt_volume(a5)	set volume

mt_SetRegs
	move.b	2(a6),d2
	and.b	#$0F,d2
	cmp.b	#9,d2			command $9 = Sample Offset ?
	bne.s	mt_noSampleOffst
	bsr	mt_SampleOffset
mt_noSampleOffst
	move	2(a6),d2
	and	#$0FF0,d2
	cmp	#$0E50,d2		command $E5 = Set Fine Tune ?
	bne.s	mt_noSetFineTune	yes / no
	move.b	3(a6),d2
	and.b	#$0F,d2
	move.b	d2,n_finetune(a6)
mt_noSetFineTune
	move	(a6),d0
	and	#$03FF,d0
	beq	mt_CheckMoreEfx

***						Handle NEW NOTE DATA

	move.b	2(a6),d0
	and.b	#$0F,d0
	cmp.b	#3,d0			command $3 = Tone Portamento ?
	beq	mt_ChkTonePorta		no / yes
	cmp.b	#5,d0			command $5 = Tone Portamento + Volume Slide ?
	beq.s	mt_ChkTonePorta		no / yes


*******					SET FREQUENCY

mt_SetPeriod
	move	(a6),d3
	and	#$03FF,d3		period from data
	lea	mt_PerNoteTab(pc),a1
	moveq	#0,d0
	move.b	0(a1,d3),d0		offset to correct note
	lea	mt_PeriodTable(pc),a1
	moveq	#0,d2
	move.b	n_finetune(a6),d2
	add	d2,d2			x 2
	add	d2,d2			x 4
	move	d2,d3
	lsl	#3,d2			x 32
	add	d3,d2			x 36
	add	d2,d2			x 36 x 2
	add	d2,d0			+ found note offset
	move	0(a1,d0),n_period(a6)	copy to n_period via finetune

	move	2(a6),d0
	and	#$0FF0,d0
	cmp	#$0ED0,d0		$ED Note Delay
	beq.s	mt_CheckMoreEfx		no / yes

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)		clear vibrato position
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)		clear tremolo position
mt_trenoc
*	move.l	n_start(a6),mt_sample_point(a5)
	move.l	n_start(a6),(a5)
	moveq	#0,d0
	move	n_length(a6),d0
	add.l	d0,d0
*	add.l	mt_sample_point(a5),d0
	add.l	(a5),d0
	move.l	d0,mt_sample_end(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
	add.l	d0,d0
	move.l	d0,mt_loop_size(a5)
	move	n_period(a6),d0
	move	d0,mt_period(a5)

	bra.s	mt_CheckMoreEfx


mt_ChkTonePorta
	bsr	mt_SetTonePorta
mt_CheckMoreEfx
*******	bsr	mt_UpdateFunk		AMIGA ONLY
	move.b	2(a6),d0
	and.b	#$0F,d0
	beq.s	mt_Arpeggio_PV
	cmp.b	#$4,d0
	beq.s	mt_Vibrato
	cmp.b	#$7,d0
	beq.s	mt_Tremolo
*	cmp.b	#$9,d0			Already done
*	beq.s	mt_SampleOffset		before analysing new period
	cmp.b	#$B,d0
	beq	mt_PositionJump
	cmp.b	#$D,d0
	beq	mt_PatternBreak
	cmp.b	#$E,d0
	beq	mt_E_Commands_PV
	cmp.b	#$F,d0
	beq	mt_Setspeed
	cmp.b	#$C,d0
	beq	mt_VolumeChange
*******					Copy frequency to DMA
mt_PerNop
	move	n_period(a6),mt_period(a5)
	rts

*-------------------------------	00XY Arpeggio
mt_Arpeggio_PV
	clr.b	bt_Arpeggioctr(a4)
	rts

*-------------------------------	04XY Vibrato
mt_Vibrato
	move.b	3(a6),d0			new command data
	beq.s	mt_Vibrato_e			= 0 ? no / yes => no change
	move.b	n_vibratocmd(a6),d2		old command data
	and.b	#$0F,d0				new low nibble = 0 ? (modulo)
	beq.s	mt_vibskip			no / yes => no change
	and.b	#$F0,d2				insert new data
	or.b	d0,d2
mt_vibskip
	move.b	3(a6),d0			new command data
	and.b	#$F0,d0				new high nibble = 0 ? (speed)
	beq.s	mt_vibskip2			no / yes => no change
	and.b	#$0F,d2				insert new data
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)		update command data
mt_Vibrato_e
	rts


*--------------------------------	07XY Tremolo
mt_Tremolo
	move.b	3(a6),d0			new command data
	beq.s	mt_Tremolo_e			= 0 ? no / yes => no change
	move.b	n_tremolocmd(a6),d2		old command data
	and.b	#$0F,d0				new low nibble = 0 ? (modulo)
	beq.s	mt_treskip			no / yes => no change
	and.b	#$F0,d2				insert new data
	or.b	d0,d2
mt_treskip
	move.b	3(a6),d0			new command data
	and.b	#$F0,d0				new high nibble = 0 ? (speed)
	beq.s	mt_treskip2			no / yes => no change
	and.b	#$0F,d2				insert new data
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)		update command data
mt_Tremolo_e
	rts


*--------------------------------	09XY Set Sample Offset
mt_SampleOffset
	moveq	#0,d0
	move.b	3(a6),d0		$xy = $00
	beq.s	mt_sononew		no / yes
	move.b	d0,n_sampleoffset(a6)	update value
mt_sononew
	move.b	n_sampleoffset(a6),d0	sample offset
	lsl	#7,d0			* 128
	cmp	n_length(a6),d0		> length
	bge.s	mt_sofskip		no / yes
	sub	d0,n_length(a6)		reduce lenght in words
	lsl	#1,d0
	add.l	d0,n_start(a6)		update start pointer in bytes
	add.l	n_loopstart(a6),d0
	cmp.l	n_start(a6),d0
	ble.s	l_mt_set_loop1
	move.l	n_loopstart(a6),d0
l_mt_set_loop1
	move.l	d0,n_loopstart(a6)
	rts
mt_sofskip
	move	#$0001,n_length(a6)	set to the end
	rts


*--------------------------------	03XY 05XY Tone Portamento init
mt_SetTonePorta
	move	(a6),d2
	and	#$03FF,d2		destination period from data
	moveq	#0,d0
	move.b	n_finetune(a6),d0	finetune value
	add	d0,d0			x 2
	add	d0,d0			x 4
	move	d0,d3
	lsl	#3,d0			x 32
	add	d0,d3			x 36
	add	d3,d3			x 36 x 2
	lea	mt_PerNoteTab(pc),a1
	move.b	0(a1,d2),d0		offset to correct note +- 2
	beq.s	mt_SetTonePorta0	= 0 ?
	subq	#2,d0			go to previous note (finetune)
mt_SetTonePorta0
	lea	mt_PeriodTable(pc),a1
	add	d3,a1			A1 points to correct table
	moveq	#2,d3			only 3 values - 1 (dbf)
mt_StpLoop
	cmp	0(a1,d0),d2		data period >= table value
	bcc.s	mt_StpFound		no / yes
	addq	#2,d0			next table value
	dbf	d3,mt_StpLoop
	subq	#2,d0			points to last possible value
mt_StpFound
	move.b	n_finetune(a6),d2
	and.b	#%00001000,d2		negative finetune ?
	beq.s	mt_StpGoss		yes / no
	tst	d0			offset = 0?
	beq.s	mt_StpGoss		no / yes
	subq	#2,d0			go to previous note
mt_StpGoss
	move	0(a1,d0),d2		d2 = corrected destination freq
	move	d2,n_wantedperiod(a6)	=> wantedperiod
	move	n_period(a6),d0		current period
	clr.b	n_toneportdirec(a6)	clr direction
	cmp	d0,d2			periods equal
	beq.s	mt_ClearTonePorta	no / yes then we are there 
	bge	mt_Return		correct direction already set
	move.b	#1,n_toneportdirec(a6)	opposite direction to be set
	rts

mt_ClearTonePorta
	clr	n_wantedperiod(a6)	wantedperiod = 0 we are there
	rts


*--------------------------------	0BXY Position Jump
mt_PositionJump
	move.b	3(a6),d0
	subq.b	#1,d0
*	move.b	d0,mt_SongPos
	move.b	d0,bt_SongPos(a4)
mt_pj2
*	clr.b	mt_PBreakPos
	clr.b	bt_PBreakPos(a4)
*	st 	mt_PosJumpFlag
	st 	bt_PosJumpFlag(a4)
	rts


*--------------------------------	0DXY Pattern Break
mt_PatternBreak
	moveq	#0,d0
	move.b	3(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	add	d0,d0		x 2
	move	d0,d3
	add	d0,d0		x 4
	add	d0,d0		x 8
	add	d3,d0		x 10
	and.b	#$0F,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
*	move.b	d0,mt_PBreakPos
	move.b	d0,bt_PBreakPos(a4)
*	st	mt_PosJumpFlag
	st	bt_PosJumpFlag(a4)
	rts

*--------------------------------	0FXY Set Tempo
mt_Setspeed
	moveq	#0,d0
	move.b	3(a6),d0
	beq	mt_Return
*	move.b	d0,mt_speed
	move.b	d0,bt_speed(a4)
	rts


*--------------------------------	0CXY Volume Set
mt_VolumeChange
	moveq	#0,d0
	move.b	3(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_VolumeOk
	moveq	#$40,d0
mt_VolumeOk
	move.b	d0,n_volume(a6)
	move	d0,mt_volume(a5)
	rts

mt_E_Commands_PV
	move.b	3(a6),d0
	and.b	#$F0,d0
	lsr.b	#4,d0
*******	beq	mt_FilterOnOff		AMIGA ONLY
	cmp.b	#1,d0
	beq	mt_FinePortaUp
	cmp.b	#2,d0
	beq	mt_FinePortaDown
	cmp.b	#3,d0
	beq	mt_SetGlissControl
	cmp.b	#4,d0
	beq	mt_SetVibratoControl
*	cmp.b	#5,d0				Already done
*	beq	mt_SetFineTune			before analysing new period
	cmp.b	#6,d0
	beq	mt_JumpLoop
	cmp.b	#7,d0
	beq	mt_SetTremoloControl
	cmp.b	#9,d0
	beq	mt_RetrigNote
	cmp.b	#$A,d0
	beq	mt_VolumeFineUp
	cmp.b	#$B,d0
	beq	mt_VolumeFineDown
	cmp.b	#$C,d0
	beq	mt_NoteCut
	cmp.b	#$E,d0
	beq	mt_PatternDelay
*******	cmp.b	#$F,d0			AMIGA ONLY
*******	beq	mt_FunkIt		AMIGA ONLY
	rts

mt_E_Commands_NN
	move.b	3(a6),d0
	and.b	#$F0,d0
	lsr.b	#4,d0
	cmp.b	#1,d0
	beq	mt_FinePortaUp			Pattern Delay case
	cmp.b	#2,d0
	beq	mt_FinePortaDown		Pattern Delay case
	cmp.b	#9,d0
	beq	mt_RetrigNote
	cmp.b	#$A,d0
	beq	mt_VolumeFineUp			Pattern Delay case
	cmp.b	#$B,d0
	beq	mt_VolumeFineDown		Pattern Delay case
	cmp.b	#$C,d0
	beq	mt_NoteCut
	cmp.b	#$D,d0
	beq	mt_NoteDelay
*******	cmp.b	#$F,d0				AMIGA ONLY
*******	beq	mt_FunkIt			Pattern Delay case
	rts

mt_FilterOnOff
	rts

*--------------------------------	0E3Y Set Glissando
mt_SetGlissControl
	move.b	3(a6),d0
	and.b	#$0F,d0
	and.b	#$F0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

*--------------------------------	0E4Y Set Vibrato Control
mt_SetVibratoControl
	move.b	3(a6),d0
	and.b	#$0F,d0
	and.b	#$F0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

*--------------------------------	0E6Y Loop
mt_JumpLoop
	move.b	3(a6),d0
	and.b	#$0F,d0
	beq.s	mt_SetLoop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_Return
mt_jmploop
*	move.b	n_pattpos(a6),mt_PBreakPos
	move.b	n_pattpos(a6),bt_PBreakPos(a4)
*	st	mt_PBreakFlag
	st	bt_PBreakFlag(a4)
	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_SetLoop
*	move	mt_PatternPos(pc),d0
	move	bt_PatternPos(a4),d0
	lsr	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

*--------------------------------	0E7Y Set Tremolo Control
mt_SetTremoloControl
	move.b	3(a6),d0
	and.b	#$0F,d0
	lsl.b	#4,d0
	and.b	#$0F,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

*--------------------------------	0E9Y Retrigger Note
mt_RetrigNote
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0			nibble data
	beq.s	mt_rtnend		= 0 ? no / yes => do nothing
	moveq	#0,d3
*	move.b	mt_counter(pc),d3	tick counter
	move.b	bt_counter(a4),d3	tick counter
	bne.s	mt_rtnskp
	clr.b	n_Retrigctr(a6)		Note Retrigger counter = 0
	move	(a6),d3
	and	#$03FF,d3		note from data
	bne.s	mt_rtnend		= 0 ? yes / no => do nothing
	bra.s	mt_Doretrig
mt_rtnskp
	move.b	n_Retrigctr(a6),d3	Note Retrigger counter
	addq.b	#1,d3
	cmp.b	d0,d3			= modulo ?
	sne	d2			set D2 if true or false
	and.b	d2,d3			new counter value
	move.b	d3,n_Retrigctr(a6)	store it
	bne.s	mt_rtnend		= 0 yes / no => do nothing
mt_Doretrig
*	move.l	n_start(a6),mt_sample_point(a5)
	move.l	n_start(a6),(a5)
	moveq	#0,d0
	move	n_length(a6),d0
	add.l	d0,d0
*	add.l	mt_sample_point(a5),d0
	add.l	(a5),d0
	move.l	d0,mt_sample_end(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
	add.l	d0,d0
	move.l	d0,mt_loop_size(a5)
mt_rtnend
	rts

*--------------------------------	0EAY Volume Fine Slide Up
mt_VolumeFineUp
*	tst.b	mt_counter
	tst.b	bt_counter(a4)
	bne	mt_Return
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
	bra	mt_VolslideUp

*--------------------------------	0EBY Volume Fine Slide Down
mt_VolumeFineDown
*	tst.b	mt_counter
	tst.b	bt_counter(a4)
	bne	mt_Return
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
	bra	mt_VolslideDown2

*--------------------------------	0ECY Note Cut
mt_NoteCut
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
*	cmp.b	mt_counter(pc),d0
	cmp.b	bt_counter(a4),d0
	bne	mt_Return
	clr.b	n_volume(a6)
	move	#0,mt_volume(a5)
	rts

*--------------------------------	0EDY Note Delay
mt_NoteDelay
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
*	cmp.b	mt_counter(pc),d0
	cmp.b	bt_counter(a4),d0
	bne	mt_Return
	move	(a6),d0
	beq	mt_Return
	bra	mt_Doretrig

*--------------------------------	0EEY Pattern Delay
mt_PatternDelay
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
*	tst.b	mt_PattDelTime2
	tst.b	bt_PattDelTime2(a4)
	bne	mt_Return
	addq.b	#1,d0
*	move.b	d0,mt_PattDelTime
	move.b	d0,bt_PattDelTime(a4)
	rts

*--------------------------------	0EFY Funk It / Update Funk
mt_FunkIt
*	tst.b	mt_counter		counter = 0 ?
	tst.b	bt_counter(a4)		counter = 0 ?
	bne	mt_Return		yes / no
	move.b	3(a6),d0		get command data
	and.b	#$0F,d0
	lsl.b	#4,d0
	and.b	#$0F,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_Return
mt_UpdateFunk
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0			commanda data = 0 ?
	beq.s	mt_funkend		no / yes
	lea	mt_FunkTable(pc),a1
	move.b	0(a1,d0),d0		get table value
	add.b	d0,n_funkoffset(a6)	add to current byte offset
	btst	#7,n_funkoffset(a6)	offset negative ?
	beq.s	mt_funkend		yes / no => do nothing
	clr.b	n_funkoffset(a6)	set offset to 0
	move.l	n_loopstart(a6),d0	loop start
	moveq	#0,d3
	move	n_replen(a6),d3
	add.l	d3,d0
	add.l	d3,d0			+ looplen = end loop
	move.l	n_wavestart(a6),a1
	addq	#1,a1
	cmp.l	d0,a1			wave start + 1 < end loop
	bcs.s	mt_funkok		no / yes
	move.l	n_loopstart(a6),a1	set to loop start
mt_funkok
	move.l	a1,n_wavestart(a6)	update wave start
	moveq	#-1,d0			same as not.b (a1)
	sub.b	(a1),d0
	move.b	d0,(a1)
mt_funkend
	rts


*******					Check effects when no new note

mt_NoNewAllChannels
	lea	mt_channel_0(pc),a5
	lea	mt_chan1temp(pc),a6
	bsr.s	mt_CheckEfx
	lea	mt_channel_1(pc),a5
	lea	mt_chan2temp(pc),a6
	bsr.s	mt_CheckEfx
	lea	mt_channel_2(pc),a5
	lea	mt_chan3temp(pc),a6
	bsr.s	mt_CheckEfx
	lea	mt_channel_3(pc),a5
	lea	mt_chan4temp(pc),a6
*	bra.s	mt_CheckEfx

mt_CheckEfx
*******	bsr	mt_UpdateFunk		AMIGA ONLY
	move	2(a6),d0
	and	#$03FF,d0
	beq	mt_PerNop
	move.b	2(a6),d0
	and.b	#$0F,d0
	beq.s	mt_Arpeggio
	cmp.b	#1,d0
	beq	mt_PortaUp
	cmp.b	#2,d0
	beq	mt_PortaDown
	cmp.b	#3,d0
	beq	mt_TonePortamento
	cmp.b	#4,d0
	beq	mt_Vibrato2
	cmp.b	#5,d0
	beq	mt_TonePlusVolslide
	cmp.b	#6,d0
	beq	mt_VibratoPlusVolslide
	cmp.b	#$E,d0
	beq	mt_E_Commands_NN
	move	n_period(a6),mt_period(a5)
	cmp.b	#7,d0
	beq	mt_Tremolo2
	cmp.b	#$A,d0
	beq	mt_VolumeSlide
mt_Return
	rts


*-------------------------------	00XY Arpeggio (Real start)
mt_Arpeggio
	move.b	bt_Arpeggioctr(a4),d0	Arpeggio counter
	beq.s	mt_Arpeggio_0		no / yes => copy base period
	cmp	#2,d0			2 case ?
	beq.s	mt_Arpeggio_2		no / yes => get low nibble data
	moveq	#0,d0			1 case
	move.b	3(a6),d0
	lsr.b	#4,d0			get high nibble data
	bra.s	mt_Arpeggio_3
mt_Arpeggio_2
	move.b	3(a6),d0
	and	#$000F,d0		get low nibble data
mt_Arpeggio_3
*					D0 arrives with note index to add
	add	d0,d0			x 2  = offset
	moveq	#0,d2
	move.b	n_finetune(a6),d2	finetune
	add	d2,d2			x 2
	add	d2,d2			x 4
	move	d2,d3
	lsl	#3,d2			x 32
	add	d2,d3			x 36
	add	d3,d3			x 36 x 2
	move	n_period(a6),d1
	lea	mt_PerNoteTab(pc),a1
	moveq	#0,d2
	move.b	0(a1,d1),d2		offset to current note +- 2
	beq.s	mt_Arpeggio_4		= 0 ?
	subq.b	#2,d2			go to previous note (finetune)
mt_Arpeggio_4
	lea	mt_PeriodTable(pc),a1
	add	d3,a1			A1 points to correct table
	moveq	#2,d3			only 3 values - 1 (dbf)
mt_Arpeggio_5
	cmp	0(a1,d2),d1		current period >= table value
	bcc.s	mt_Arpeggio_6		no / yes
	addq	#2,d2			next table value
	dbf	d3,mt_Arpeggio_5
	subq	#2,d2			points to last possible value
mt_Arpeggio_6
	add	d0,d2			adds Arpeggio
	cmp	#2*36,d2		>  maximum offset
	bcc.s	mt_Arpeggio_0		no / yes
	move	0(a1,d2),mt_period(a5)	get new period
	rts
mt_Arpeggio_0
	move	n_period(a6),mt_period(a5)	keep base period
	rts

*-------------------------------	01XY Portamento Up
*-------------------------------	0E1Y Fine Portamento Up
mt_FinePortaUp
*	tst.b	mt_counter
	tst.b	bt_counter(a4)
	bne.s	mt_Return
*	move.b	#$0F,mt_LowMask
	move.b	#$0F,bt_LowMask(a4)

mt_PortaUp
	moveq	#0,d0
	move.b	3(a6),d0
*	and.b	mt_LowMask(pc),d0
	and.b	bt_LowMask(a4),d0
*	move.b	#$FF,mt_LowMask
	move.b	#$FF,bt_LowMask(a4)
	sub	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$03FF,d0
	cmp	#$0071,d0
	bpl.s	mt_PortaUskip
	and	#$F000,n_period(a6)
	or	#$0071,n_period(a6)
mt_PortaUskip
	move	n_period(a6),d0
	and	#$03FF,d0
	move	d0,mt_period(a5)
	rts
 
*-------------------------------	02XY Portamento Down
*-------------------------------	0E2Y Fine Portamento Down
mt_FinePortaDown
*	tst.b	mt_counter
	tst.b	bt_counter(a4)
	bne	mt_Return
*	move.b	#$0F,mt_LowMask
	move.b	#$0F,bt_LowMask(a4)

mt_PortaDown
	clr	d0
	move.b	3(a6),d0
*	and.b	mt_LowMask(pc),d0
	and.b	bt_LowMask(a4),d0
*	move.b	#$FF,mt_LowMask
	move.b	#$FF,bt_LowMask(a4)
	add	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$03FF,d0
	cmp	#$0358,d0
	bmi.s	mt_PortaDskip
	and	#$F000,n_period(a6)
	or	#$0358,n_period(a6)
mt_PortaDskip
	move	n_period(a6),d0
	and	#$03FF,d0
	move	d0,mt_period(a5)
	rts

*-------------------------------	03XY Tone Portamento
mt_TonePortamento
	move.b	3(a6),d0
	beq.s	mt_TonePortNoChange
	move.b	d0,n_toneportspeed(a6)
	clr.b	3(a6)
mt_TonePortNoChange
	tst	n_wantedperiod(a6)
	beq	mt_Return
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_TonePortaUp
mt_TonePortaDown
	add	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	bgt.s	mt_TonePortaSetPer
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)
	bra.s	mt_TonePortaSetPer

mt_TonePortaUp
	sub	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	blt.s	mt_TonePortaSetPer
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)

mt_TonePortaSetPer
	move	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0F,d0
	beq.s	mt_GlissSkip
	moveq	#0,d0
	move.b	n_finetune(a6),d0	finetune
	add	d0,d0			x 2
	add	d0,d0			x 4
	move	d0,d3
	lsl	#3,d0			x 32
	add	d0,d3			x 36
	add	d3,d3			x 36 x 2
	lea	mt_PerNoteTab(pc),a1
	moveq	#0,d0
	move.b	0(a1,d2),d0		offset to correct note +-2
	beq.s	mt_GlissLoop0		= 0 ?
	subq	#2,d0			go to previous note (finetune)
mt_GlissLoop0
	lea	mt_PeriodTable(pc),a1
	add	d3,a1			A1 points to correct table
	moveq	#2,d3			only 3 values - 1 (dbf)
mt_GlissLoop
	cmp	0(a1,d0),d2		period >= table value
	bcc.s	mt_GlissFound		no / yes
	addq	#2,d0			next table value
	dbf	d3,mt_GlissLoop
	subq	#2,d0			points to last possible value
mt_GlissFound
	move	0(a1,d0),d2
mt_GlissSkip
	move	d2,mt_period(a5)
	rts

*-------------------------------	04XY Vibrato
mt_Vibrato2
	moveq	#0,d0
	move.b	n_vibratopos(a6),d0		vibrato position limited to 0..63
	moveq	#0,d1
	move.b	n_vibratocmd(a6),d1
	and	#$000F,d1			vibrato modulo
	beq.s	mt_Vibrato3			= 0 ? no / yes
	subq	#1,d1
mt_Vibrato3
	lsl	#6,d1				64 positions per modulo
	add	d0,d1				+ current position
	lea	zVibratoTabPtrs(pc),a1
	moveq	#0,d0
	move.b	n_wavecontrol(a6),d0
	and	#$03,d0				vibrato wave
	add	d0,d0				x 2
	add	d0,d0				x 4
	move.l	0(a1,d0),a1			pointer to correct table
	move.b	0(a1,d1),d0
	ext	d0				value to correct the period
	move	#108,d2				minimum period
	add	n_period(a6),d0
	bpl.s	mt_Vibrato4
	move	d2,d0
mt_Vibrato4
	cmp	d2,d0
	bcc.s	mt_Vibrato5
	move	d2,d0
mt_Vibrato5
	move	#907,d2				maximum period
	cmp	d2,d0
	bls.s	mt_Vibrato6
	move	d2,d0
mt_Vibrato6
	move	d0,mt_period(a5)
	move.b	n_vibratocmd(a6),d0
	lsr	#4,d0				vibrato speed
	add.b	n_vibratopos(a6),d0		add current position
	and.b	#$3F,d0				limit to  0..63
	add.b	d0,n_vibratopos(a6)		update position
	rts

*--------------------------------	05XY Tone Portamento + Volume Slide
mt_TonePlusVolslide
	bsr	mt_TonePortNoChange
	bra.s	mt_VolumeSlide

*--------------------------------	06XY Vibrato + Volume Slide
mt_VibratoPlusVolslide
	bsr.s	mt_Vibrato2
	bra.s	mt_VolumeSlide

*--------------------------------	07XY Tremolo
mt_Tremolo2
	move.b	n_tremolopos(a6),d0		tremolo position limited to 0..63
	moveq	#0,d1
	move.b	n_tremolocmd(a6),d1
	and	#$000F,d1			tremolo modulo
	beq.s	mt_Tremolo3			= 0 ? no / yes
	subq	#1,d1
mt_Tremolo3
	lsl	#6,d1				64 positions per modulo
	add	d0,d1				+ current position
	lea	zTremoloTabPtrs(pc),a1
	moveq	#0,d0
	move.b	n_wavecontrol(a6),d0
	lsr.b	#4,d2
	and	#$03,d0				tremolo wave
	add	d0,d0				x 2
	add	d0,d0				x 4
	move.l	0(a1,d0),a1			pointer to correct table
	move.b	0(a1,d1),d0			value to correct the volume
	add.b	n_volume(a6),d0
	bpl.s	mt_Tremolo4
	moveq	#0,d0
mt_Tremolo4
	moveq	#$40,d2
	cmp.b	d2,d0
	bls.s	mt_Tremolo5
	move.b	d1,d0
mt_Tremolo5
	move	d0,mt_volume(a5)
	move.b	n_tremolocmd(a6),d0
	lsr	#4,d0				tremolo speed
	add.b	n_tremolopos(a6),d0		add current position
	and.b	#$3F,d0				limit to  0..63
	add.b	d0,n_tremolopos(a6)		update position
	rts

*--------------------------------	0AXY Volume Slide
mt_VolumeSlide
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_VolslideDown
mt_VolslideUp
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move	d0,mt_volume(a5)
	rts

mt_VolslideDown
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
mt_VolslideDown2
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move	d0,mt_volume(a5)
	rts


mt_FunkTable
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b 0,24,49,74,97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120,97,74,49,24

mt_PeriodTable
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

mt_chan1temp	dc.l	0,0,0,0,$3ff0000,$00010000,0,0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,$3ff0000,$00020000,0,0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,$3ff0000,$00040000,0,0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,$3ff0000,$00080000,0,0,0,0,0

mt_SampleStarts
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_PT_data	ds.w	7

	rsreset
bt_Enable	rs.b	1
bt_speed	rs.b	1
bt_counter	rs.b	1
bt_SongPos	rs.b	1
bt_PatternPos	rs.w	1
bt_PBreakPos	rs.b	1
bt_PosJumpFlag	rs.b	1
bt_PBreakFlag	rs.b	1
bt_LowMask	rs.b	1
bt_PattDelTime	rs.b	1
bt_PattDelTime2	rs.b	1
bt_Arpeggioctr	rs.b	1

mt_SongDataPtr	dc.l	0
*mt_speed	dc.b	6
*mt_counter	dc.b	0
*mt_SongPos	dc.b	0
*mt_PBreakPos	dc.b	0
*mt_PosJumpFlag	dc.b	0
*mt_PBreakFlag	dc.b	0
*mt_LowMask	dc.b	0
*mt_PattDelTime	dc.b	0
*mt_PattDelTime2	dc.b	0
*mt_Enable	dc.b	0
*mt_PatternPos	dc.w	0
mt_module_end	dc.l	0

n_note		equ	0  ; w
n_cmd		equ	2  ; w
n_cmdlo		equ	3  ; b
n_start		equ	4  ; l
n_length	equ	8  ; w
n_loopstart	equ	10 ; l
n_replen	equ	14 ; w
n_period	equ	16 ; w
n_finetune	equ	18 ; b
n_volume	equ	19 ; b
n_dmabit	equ	20 ; w
n_toneportdirec	equ	22 ; b
n_toneportspeed	equ	23 ; b
n_wantedperiod	equ	24 ; w
n_vibratocmd	equ	26 ; b
n_vibratopos	equ	27 ; b
n_tremolocmd	equ	28 ; b
n_tremolopos	equ	29 ; b
n_wavecontrol	equ	30 ; b
n_glissfunk	equ	31 ; b
n_sampleoffset	equ	32 ; b
n_pattpos	equ	33 ; b
n_loopcount	equ	34 ; b
n_funkoffset	equ	35 ; b
n_wavestart	equ	36 ; l
n_reallength	equ	40 ; w
n_Retrigctr	equ	42 ; b

***************************************************************************
***************************************************************************
* PROC: QGENPERTAB
*	Generates a table that converts Period to Note index
***************************************************************************
qgenpertab:
	lea	mt_PeriodTable(pc),a0
	lea	mt_PerNoteTab(pc),a1
	moveq	#0,d0			first offset
	move	(a0)+,d1		1st table period
	move	#$3FF,d2		1024 - 1 periods
lgenpertab0
	cmp	d1,d2			current preiod > = ref period ?
	bcc.s	lgenpertab1		no / yes
	cmp.b	#2*35,d0		offset = maximum ?
	beq.s	lgenpertab1		no / yes
	move	(a0)+,d1		next table period
	addq.b	#2,d0			next offset
lgenpertab1
	move.b	d0,0(a1,d2)		store index * 2 = offset
	dbf	d2,lgenpertab0
	rts

mt_PerNoteTab	ds.b	$400


***************************************************************************
* PROC: QGENVIBTREM
*	/128 (Vibrato) /64 (Tremolo)
***************************************************************************
qgenvibtrem:
	move.l	#5760,d0
	bsr	qmalloc
	scs	d1
	bcs	lgenvibtrem_e
	lea	zVibratoTabPtrs(pc),a1
	move.l	a0,(a1)
	move.l	a0,12(a1)
	lea	960(a0),a0
	move.l	a0,4(a1)
	lea	960(a0),a0
	move.l	a0,8(a1)
	lea	960(a0),a0
	lea	zTremoloTabPtrs(pc),a1
	move.l	a0,(a1)
	move.l	a0,12(a1)
	lea	960(a0),a0
	move.l	a0,4(a1)
	lea	960(a0),a0
	move.l	a0,8(a1)
	lea	mt_VibratoTable(pc),a0
	move.l	zTremoloTabPtrs+8(pc),a6
	move.l	zVibratoTabPtrs+8(pc),a5
	move.l	zTremoloTabPtrs+4(pc),a4
	move.l	zVibratoTabPtrs+4(pc),a3
	move.l	zTremoloTabPtrs(pc),a2
	move.l	zVibratoTabPtrs(pc),a1
	moveq	#15,d7
lgenvibtrem_0
	moveq	#15,d6
	sub	d7,d6			D6 0..15
	beq.s	lgenvibtrem_3
	moveq	#63,d5			D6 1..15 modulo
lgenvibtrem_1
	moveq	#63,d4
	sub	d5,d4			D4 0..63 position
	move	d4,d3
	and	#$1F,d3			D3 0..31
	moveq	#0,d0
	move.b	0(a0,d3),d0		D0 0..255
	move	d3,d1
	lsl	#3,d1			ramp
	move	#255,d2			square wave
	cmp.b	#32,d4
	bmi.s	lgenvibtrem_2		0..31 positive 32..63 negative
	neg	d0
	sub	#255,d1
	neg	d2
lgenvibtrem_2
	muls	d6,d0			D0 -255..255 * D6 1..15
	asr	#6,d0			D0 (-255*15..15*255)/64
	move.b	d0,(a2)+		D0 -60..60
	asr	#1,d0			D0 -30..30
	move.b	d0,(a1)+
	muls	d6,d1			D1 -255..248 * D6 1..15
	asr	#6,d1			D1 (-255*15..15*248)/64
	move.b	d1,(a2)+		D1 -60..60
	asr	#1,d1			D1 -30..30
	move.b	d1,(a1)+
	muls	d6,d2			D2 -255..255 * D6 1..15
	asr	#6,d2			D2 (-255*15..15*255)/64
	move.b	d2,(a2)+		D2 -60..60
	asr	#1,d2			D2 -30..30
	move.b	d2,(a1)+
	dbf	d5,lgenvibtrem_1
lgenvibtrem_3
	dbf	d7,lgenvibtrem_0
	moveq	#0,d1
lgenvibtrem_e
	rts

zTremoloTabPtrs	ds.l	4
zVibratoTabPtrs	ds.l	4
