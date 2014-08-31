;----------------------------------------------------------------------------
;File name:	TRACKER.S			Revision date:	1998.02.05
;Revised by:	Ulf Ronald Andersson		Revision start:	1997.02.12
;----------------------------------------------------------------------------
DSP_sample_fq			=	49169
;-----------------------------------------------------------------------------
;	Codes and other data for various DSP/APP interactions
;
Tk_Init_delay	=	131072	;Maximum loop count waiting for DSP Init
Tk_Track_delay	=	200	;Maximum loop count waiting for DSP Tracking
Tk_Ready_delay	=	200	;Maximum loop count waiting for DSP Tracking
Tk_Zap_delay	=	2000	;Maximum loop count waiting for DSP Reset
;
;	codes used without host command prefix
;
Tk_Init_s_c	=	'TkI'	;Initialization code from app to dsp
Tk_Error_s_c	=	'TkE'	;Error code from dsp at unexpected commands
Tk_Busy_s_c	=	'TkB'	;from dsp when interrupted before ready
Tk_Ready_s_c	=	'TkR'	;from dsp when ready after sending Busy
;
;
;	codes used with host_0 command prefix (Soundtracker refill)
;
Tk_Track_s_c	=	'TkT'	;Tracking code 0	;APP->DSP at work start
;
;
;	codes used with host_0 command prefix (General commands)
;
Tk_Zap_s_c	=	'TkZ'	;deactivation (Zap) code
;----------------------------------------------------------------------------
				RsReset
;
Amiga_Name			rs.b		22
Amiga_Length			rs.w		1	* Taille cod‚e en words
Amiga_Fine_Tune			rs.b		1	* de 0 … 15  =  0 … 7 et -8 … -1
Amiga_Volume			rs.b		1	* de 0 … 64
Amiga_Repeat_Start		rs.w		1
Amiga_Repeat_Length		rs.w		1
Amiga_Size			rs.b		1	* 30 octets
;----------------------------------------------------------------------------
				RsReset
;
Voice_Sample_Start		rs.l		1
Voice_Sample_Offset		rs.l		1
Voice_Sample_Position		rs.l		1
Voice_Sample_Length		rs.l		1
Voice_Sample_Repeat_Length	rs.l		1
Voice_Sample_Volume		rs.w		1
Voice_Sample_Period		rs.w		1
Voice_Sample_Fine_Tune		rs.w		1
;
Voice_Start			rs.l		1
Voice_Length			rs.l		1
Voice_Repeat_Length		rs.l		1
Voice_Volume			rs.w		1
Voice_Period			rs.w		1
Voice_Wanted_Period		rs.w		1
;
Voice_Note_Period		rs.w		1
Voice_Command			rs.b		1	;\/ Don't break these apart! They
Voice_Parameters		rs.b		1	;/\ are also accessed as one word
Voice_Old_Sample		rs.b		1
Voice_New_Sample		rs.b		1
;
Voice_Tone_Port_Direction	rs.b		1
Voice_Tone_Port_Speed		rs.b		1
Voice_Glissando_Control		rs.b		1
Voice_Vibrato_Command		rs.b		1
;
Voice_Vibrato_Position		rs.b		1
Voice_Vibrato_Control		rs.b		1
Voice_Tremolo_Command		rs.b		1
Voice_Tremolo_Position		rs.b		1
;
Voice_Tremolo_Control		rs.b		1
Voice_Special_f			rs.b		1
;
Voice_Funk_Speed		rs.b		1
Voice_Funk_Offset		rs.b		1
Voice_Funk_Position		rs.l		1
Voice_Funk_Start		rs.l		1
;
Voice_Slide_Note		rs.w		1	;logarithmic note of slide goal
;
Voice_Size			rs.b		1
;----------------------------------------------------------------------------
tx_DSP	MACRO	data
	move.l	\1,hw_dsp_long-hw_dsp_is(a6)
	ENDM	;tx_DSP
;
tx_CODE	MACRO	timeout,data
	IFNC	'd1','\2'
	move.l	\2,d1
	ENDC
	IFNC	'd0','\1'
	move.l	\1,d0
	ENDC
	bsr	transmit_DSP_code
	ENDM	;tx_CODE
;
rx_CODE	MACRO	timeout
	move.l	\1,d0
	bsr	receive_DSP_code
	ENDM	;rx_CODE
;----------------------------------------------------------------------------
	Section	TEXT
;----------------------------------------------------------------------------
receive_DSP_code:
.loop:
	btst	#0,(a6)
	bne.s	.receivable
	subq.l	#1,d0
	bne.s	.loop
	moveq	#-1,d0
	rts
;
.receivable:
	move.l	hw_dsp_long-hw_dsp_is(a6),d0
	and.l	#$00FFFFFF,d0			;mask to 3 bytes
	rts
;
;ends:	receive_DSP_code
;----------------------------------------------------------------------------
;
transmit_DSP_code:
.loop:
	btst	#1,(a6)
	bne.s	.transmittable
	subq.l	#1,d0
	bne.s	.loop
	moveq	#-1,d0				;flag failure MI
	rts
;
.transmittable:
	move.l	d1,d0
	move.l	d0,hw_dsp_long-hw_dsp_is(a6)
	and.l	#$00FFFFFF,d0			;flag success PL
	rts
;
;ends:	transmit_DSP_code
;----------------------------------------------------------------------------
;
Stop_Sound:
	move	sr,-(sp)
	or	#$0700,sr
	lea.l	(hw_dsp_is).w,a6		; a6 -> DSP status
.stop_DSP_loop:
	move.b	#$80+$28/2,(hw_dsp_cv).w	; Host User 1, vecteur $28
	btst	#1,(a6)
	tx_DSP	#Tk_Zap_s_c
	rx_CODE	#Tk_Zap_delay
	cmp.l	#Tk_Zap_s_c,d0
	beq.s	DSP_abort
	cmp.l	#Tk_Error_s_c,d0
	beq.s	.stop_DSP_loop
;
;NB: Falling through the test above means that DSP does not respond correctly!
;    Still, we have no choice but to continue below anyway, hoping it works.
;
DSP_abort:
	move.b	old_matr_ffff8937(pc),$ffff8937.w
	move	old_f30_xbar_dc(pc),(hw_F_xbar_dc).w
	move	old_f30_xbar_sc(pc),(hw_F_xbar_sc).w
	move.b	old_f30_dac_trk(pc),(hw_F_dac_trk).w
	move.b	old_sdma_cont(pc),(hw_sdma_cont).w
	move	(sp)+,sr
	xbios	Dsp_Reserve,!,!
	bsr	(dspfix_t+4)
	move.b	old_conterm(pc),(conterm).w
Iz_error_3:
	xbios	Dsp_Unlock
Iz_error_2:
	xbios	Snd_UnlockSnd
Iz_error_1:
	moveq.l	#-1,d0
	rts			;return E_ERROR to caller
;
;----------------------------------------------------------------------------
;Initialize sound system and DSP
;
Init_Sound:
	xbios	Snd_LockSnd
	tst.l	d0
	bmi	Iz_error_1
	xbios	Dsp_Lock
	ext.l	d0
	bmi	Iz_error_2
	xbios	Dsp_Available,dsp_xsize(pc),dsp_ysize(pc)
	cmp.l	#16000,dsp_xsize
	blt	Iz_error_3
	cmp.l	#16000,dsp_ysize
	blt	Iz_error_3
	xbios	Dsp_Reserve,#16000,#16000
	ext.l	d0
	bmi	Iz_error_3
;
	xbios	Snd_SetInterrupt,!,!		;disable rec/play interrupts
	xbios	Snd_SndStatus,#1		;reset A/D & D/A converters
;
	move.b	(conterm).w,old_conterm
	bclr	#0,(conterm).w
;
	cmp	#-1,DspT_cookie+DspT_DSP_ability
	bne.s	.have_ability
	xbios	Dsp_RequestUniqueAbility
	move	d0,DspT_cookie+DspT_DSP_ability
.have_ability:
	bsr	(dspfix_t+4)
	xbios	Dsp_ExecProg,DSP_Code(pc),#(DSP_End-DSP_Code)/3,DspT_cookie+DspT_DSP_ability(pc)
;
	move	sr,-(sp)
	or	#$0700,sr			;disable interrupt mask
;
; Stoppe la lecture DMA au cas o—...
;
	move.b	(hw_sdma_cont).w,old_sdma_cont
	clr.b	(hw_sdma_cont).w
;
; DAC sur piste 0 (quartet fort)
;
	move.b	(hw_F_dac_trk).w,old_f30_dac_trk
	move.b	#$0f,(hw_F_dac_trk).w
;
; Source DSP-Xmit sur Horloge Interne 25.175 MHz, DSP connect‚ (Enable)
; Source DMA-Play sur Horloge Interne 25.175 MHz
;
	move	(hw_F_xbar_sc).w,old_f30_xbar_sc
	move	#%10010001,(hw_F_xbar_sc).w
;
; Destinations DAC, DMA-Record and External OutPut
; connected to Source DSP-Xmit, Handshaking On
; Destination DSP-Rec connected to DMA-Play, DSP connect (Enable)
;
	move	(hw_F_xbar_dc).w,old_f30_xbar_dc
	move	#%0010001000010011,(hw_F_xbar_dc).w
;
	move.b	#1,$ffff8935.w			;DSP prescaler = 1 => datarate = clk_fq/512
;
	move.b	$ffff8937.w,old_matr_ffff8937
	or.b	#%10,$ffff8937.w		;connect sound
;
	lea.l	(hw_dsp_is).w,a6		; a6 -> DSP status
Connect:
	lea	Connect,a0
	move	#32000,d0
delay:
	tst.l	(a0)+				;This makes delay work despite cache !!!
	dbra	d0,delay
	btst	#1,(a6)
	tx_DSP	#Tk_Init_s_c			;Send verification code to DSP
	rx_CODE	#Tk_Init_delay
	cmp.l	#Tk_Init_s_c,d0			;Verification code correct ?
	beq.s	.done
	cmp.l	#Tk_Error_s_c,d0		;Error ?
	beq.s	Connect				;on Error, go try again
	bra	DSP_abort			;abort on unknown response
;
.done:
	sf	track_busy_f			;clear DSP busy flag
	clr.l	d0				;return E_OK to caller
	move	(sp)+,sr			;restore interrupt mask
	rts
;
;----------------------------------------------------------------------------
;void	calc_module(raw_mod *module_p)
;
calc_module:
	movem.l	d1-d7/a1-a6,-(sp)
	lea.l	20+31*30+2(a0),a1		;a1 -> default song start
	lea.l	4+128(a1),a2			;a2 -> default pattern start
	moveq.l	#31,d0				;d0 = default 31 instruments
	moveq.l	#64,d2				;d2 = default 64 divs per pattern
	move.l	$438(a0),d3			;d3 = default module type identifier
;
; Formats 4 voies
	moveq.l	#4,d1				;d1 = 4 voices
;
	cmp.l	#"M.K.",d3			;"M.K." ?
	beq.s	.Format_Ok
	cmp.l	#"M!K!",d3			;"M!K!" ?
	beq.s	.Format_Ok
	cmp.l	#"M&K&",d3			;"M&K&" ?
	beq.s	.Format_Ok
	cmp.l	#"FA04",d3			;"FA04" ?
	beq.s	.Format_Digital
	cmp.l	#"FLT4",d3			;"FLT4" ?
	beq.s	.Format_Ok
;
; Formats 6 voies
	moveq.l	#6,d1				;d1 = 6 voices
;
	cmp.l	#"FA06",d3			;"FA06" ?
	beq.s	.Format_Digital
	cmp.l	#"6CHN",d3			;"6CHN" ?
	beq.s	.Format_Ok
	cmp.l	#"FLT6",d3			;"FLT6" ?
	beq.s	.Format_Ok
;
; Formats 8 voies
	moveq.l	#8,d1				;d1 = 8 voices
;
	cmp.l	#"FA08",d3			;"FA08" ?
	beq.s	.Format_Digital
	cmp.l	#"8CHN",d3			;"8CHN" ?
	beq.s	.Format_Ok
	cmp.l	#"FLT8",d3			;"FLT8" ?
	beq.s	.Format_Ok
	cmp.l	#"OCTA",d3			;"OCTA" ?
	beq.s	.Format_Ok
;
;Just a good old 15 instrument module, without 'special' formats
;
	lea.l	20+15*30+2(a0),a1		;a1 -> old_fashioned song start
	lea.l	128(a1),a2			;a2 -> old_fashioned pattern start
	moveq.l	#15,d0				;d0 = 15 instruments
	moveq.l	#4,d1				;d1 = 4 voices
	bra.s	.Format_Ok
;
.Format_Digital:
	move	(a2)+,d2			;d2 = divs per pattern
	addq.l	#2,a2				;a2 -> FAxx module pattern start
;
.Format_Ok:
	move.l	a2,d7				;d7 -> patterns
	move	d0,d6				;d6 = instruments allowed
;
	lsl.w	#2,d1				;d1 = voices *4,  bytes per pattern 'line'
	mulu.w	d2,d1				;d1 = 'lines' per pattern * bytes per 'line'
	move	d1,d5				;d5 = bytes per pattern
;
	moveq	#128-1,d0			;test all possible song positions
	clr.l	d1				;preclear max code
.song_Loop:					;loop to find max pattern code
	move.b	(a1)+,d2			;d2 = next pattern code
	cmp.b	d1,d2				;larger than max ?
	blo.s	.keep_max_code			;else keep max
	move.b	d2,d1				;d1 = new max pattern code
.keep_max_code:
	dbra	d0,.song_Loop			;loop back for all possible song positions
	addq	#1,d1				;d1 = total pattern count
	mulu.w	d5,d1				;d1 = total bytes for all patterns
;
	move.l	d7,a1				;a1 -> start of patterns
	lea.l	(a1,d1.l),a1			;a1 -> start of samples
	move.l	a1,d0
	sub.l	a0,d0				;d0 = module room need below samples
;
	clr.l	d3				;preclear max sample size
	lea.l	20(a0),a2			;a2 -> sample headers
	move	d6,d5				;d5 = instruments allowed
	subq	#1,d5				;d5 = prep for dbra
.calc_room_loop:				;loop start to calculate total size
	clr.l	d1
	move	Amiga_Length(a2),d1		;d1 = sample count (word as long)
	beq.s	.next_sample			;skip empty samples
	add.l	d1,d1				;d1 = doubled for byte count
;
	cmp.l	d3,d1				;larger than max ?
	blo.s	.keep_max_size			;else keep max
	move.l	d1,d3				;d3 = new max sample size
.keep_max_size:
;
	add.l	d1,d0				;d0 += size of current sample
	clr.l	d2				;d2 = precleared sample loop size
	clr.l	d1
	move	Amiga_Repeat_Length(a2),d1	;d1 = sample repeat_length
	add.l	d1,d1				;d1 = doubled for byte count
	bne.s	.use_repeat
	move	#2800,d1			;d1 = silent pad room for 2800 bytes
	add.l	d1,d0				;d0 += silent pad room
	bra.s	.next_sample			;go try next sample
;
.use_repeat:
	add.l	d1,d2				;d2 += sample repeat_length
	cmp.l	#1400,d2			;sample loop large enough ?
	blo.s	.use_repeat
	add.l	#1400,d2			;d2 += sample loop pad size
	add.l	d2,d0				;d0 += room need for sample loop with pad
.next_sample:
	lea.l	Amiga_Size(a2),a2		;a2 -> next instrument
	dbra	d5,.calc_room_loop		;loop back to calculate total room
	add.l	d3,d0				;add max sample size as safety margin
;
	movem.l	(sp)+,d1-d7/a1-a6
	move.l	d0,a0
	rts
;
;ends	calc_module()
;----------------------------------------------------------------------------
;void	init_module(rawmod *module)
;
Init_Module:
	lea.l	20+31*30+2(a0),a1
	lea.l	4+128(a1),a2
	moveq.l	#31,d0				;31 instruments
	moveq.l	#64,d2				; 64 lignes par pattern
	sf	Simplet_Old_Module
	move	#125,beat_tempo			;Default Tempo
	move	#6,ticks_per_divs		;Default Speed
	move	#DSP_sample_fq/50+1,frame_norm	;Default normalized frame
;
	move.l	$438(a0),d3			; ModFile Chunk
;
; Formats 4 voices
	moveq.l	#4,d1
;
	cmp.l	#"M.K.",d3
	beq.s	.Format_Ok
	cmp.l	#"M!K!",d3
	beq.s	.Format_Ok
	cmp.l	#"M&K&",d3
	beq.s	.Format_Ok
	cmp.l	#"FA04",d3
	beq.s	.Format_Digital
	cmp.l	#"FLT4",d3
	beq.s	.Format_Ok
;
; Formats 6 voices
	moveq.l	#6,d1
;
	cmp.l	#"FA06",d3
	beq.s	.Format_Digital
	cmp.l	#"6CHN",d3
	beq.s	.Format_Ok
	cmp.l	#"FLT6",d3
	beq.s	.Format_Ok
;
; Formats 8 voices
	moveq.l	#8,d1
;
	cmp.l	#"FA08",d3
	beq.s	.Format_Digital
	cmp.l	#"8CHN",d3
	beq.s	.Format_Ok
	cmp.l	#"FLT8",d3
	beq.s	.Format_Ok
	cmp.l	#"OCTA",d3
	beq.s	.Format_Ok
;
;Just a good old 15 instrument module, without 'special' formats
;
	lea.l	20+15*30+2(a0),a1
	lea.l	128(a1),a2
	moveq.l	#15,d0
	moveq.l	#4,d1
	st	Simplet_Old_Module
	bra.s	.Format_Ok
;
.Format_Digital:
	move	(a2)+,d2
	addq.l	#2,a2
;
.Format_Ok:
	move.l	a1,Simplet_Sequence_Adr		;-> Song
	move.l	a2,Simplet_Patterns_Adr		;-> patterns
	move	d0,Simplet_Samples_Nb		;instruments allowed
	move	d1,Simplet_Voices_Nb		;voices used
	move	d2,Simplet_Pattern_Length	;'Lines' per pattern
;
	lsl.w	#2,d1
	move	d1,Simplet_Line_Size		;'Line' length
	mulu.w	d2,d1
	move	d1,Simplet_Pattern_Size		;pattern length
;
	move.b	-2(a1),d0
	move	d0,Simplet_Song_Length		;Song length
	move.b	-1(a1),d2
	cmp.b	d0,d2				;Song restart
	blo.s	.Restart_Ok			;sensible ?
	clr.l	d2				;else clear it
.Restart_Ok:
	move	d2,Simplet_Song_Restart
;
	moveq	#128-1,d0			;test all possible song positions
	clr.l	d1				;preclear max code
.Simplet_Sequence_Loop:				;loop to find max pattern code
	move.b	(a1)+,d2			;d2 = next pattern code
	cmp.b	d1,d2				;larger than max ?
	blo.s	.keep_Max			;else keep max
	move.b	d2,d1				;d1 = new max pattern code
.keep_Max:
	dbra	d0,.Simplet_Sequence_Loop	;loop back for all possible song positions
	addq	#1,d1				;d1 = pattern count
	mulu.w	Simplet_Pattern_Size(pc),d1	;d1 = total size for all patterns
;
	move.l	Simplet_Patterns_Adr(pc),a1	;a1 -> start of patterns
	lea.l	(a1,d1.l),a1			;a1 -> start of samples
;
	lea.l	20(a0),a2			; Pointe sur Sample 1
	clr.l	d2
	move	Simplet_Samples_Nb(pc),d0	;d0 = instruments allowed
	subq	#1,d0				;d0 = prep for dbra
.Simplet_Total_Length:				;loop start to calculate total size
	clr.l	d3
	move	Amiga_Length(a2),d3		;d3 = sample count (word as long)
	add.l	d3,d3				;and doubled for byte count
	add.l	d3,d2				;d2 += size of current sample
	lea.l	Amiga_Size(a2),a2		;a2 -> next instrument
	dbra	d0,.Simplet_Total_Length	;loop back to calculate total size
;
;copy the samples to the end of the temporary area  (workspace)
;
	move.l	workspace_p(pc),a2		;a2 -> workspace, temp samples end
	move.l	a1,a3				;a3 -> source samples start
	add.l	d2,a1				;a1 -> source samples end
	move.l	a2,a4				;a4 -> temp samples end
	sub.l	d2,a4				;a4 -> temp samples start
;
.Simplet_Move_Samples:
	move.l	-(a1),-(a2)			;\/ Copy 2 longwords from
	move.l	-(a1),-(a2)			;/\ source to temp area
	subq.l	#8,d2
	bpl.s	.Simplet_Move_Samples		;loop back for all sample data
;
	move.l	a4,a2				;a2 -> temp samples start
	lea.l	20(a0),a0			;a0 -> 1st sample header in module
	lea.l	Simplet_Samples_Adr(pc),a1	;a1 -> space for 1st sample in module
;
;The big loop below copies each sample from the temp workspace back into the sample
;area of the module, while converting/expanding them into playable format.
;This means that a sample loop is added to the end of each sample, which simplifies
;playtime tests for ending and looping.
;
	move	Simplet_Samples_Nb(pc),d0	;d0 = number of samples
	subq	#1,d0				;d0 = adjusted for dbra
.Simplet_Next_Sample:				;loop start to init each sample
	move.l	a3,(a1)+			;store sample base in pointer
;
	move	Amiga_Length(a0),d3		;Length zero ?
	beq	.NextSample			;If so go try next sample
;
	clr.l	d1
	move	Amiga_Repeat_Start(a0),d1	;d1 = Repeat_Start
	add.l	d1,d1				;d1 = Repeat_Start byte offset
	lea	(a3,d1.l),a4			;a4 -> src Repeat_Start in dest sample area
;
	move	d3,d1				;d1 = full sample word count
	subq	#1,d1				;d1 = adjusted for dbra
.copy_main_loop:				;loop start to copy emtire sample
	move	(a2)+,(a3)+			;copy a sample word
	dbra	d1,.copy_main_loop		;loop back to copy entire sample
;
	move	Amiga_Repeat_Length(a0),d4
	cmp	#1,d4				;Repeat_Length > 1 ?
	bhi.s	.use_repeat			;If Repeat_Length > 1, go use it
	move	#1400-1,d2			;d2 = prep for 1400 dbra loops
.silent_pad_loop:
	clr	(a3)+				;zero a word in sample loop area
	dbra	d2,.silent_pad_loop			;loop back for entire sample loop area
;
	move	#1400/2,d1			;Set Repeat Length to 1400 bytes = 700 words
	bra.s	.sample_ok			;go complete handling of this sample
;
;
.use_repeat:
	move.l	a3,a5				;a5 -> destination sample loop start
	clr.l	d1				;d1 = 0 as loop copy counter
.loop_sample_loop_1:
	move.l	a4,a6				;a6 -> source sample loop start
	move	d4,d2				;d2 = Repeat_Length
	subq	#1,d2				;d2 = adjusted for dbra
.loop_sample_loop_2:
	move	(a6)+,(a3)+			;copy a sample loop word
	addq	#1,d1				;increment d1
	dbra	d2,.loop_sample_loop_2		;loop back for all sample loop words
	cmp	#1400/2,d1			;is it large enough ?
	blo.s	.loop_sample_loop_1		;if still too small, do it over
;
	move	#1400/2-1,d2
.loop_sample_pad_loop:				;loop start to pad sample loop
	move	(a5)+,(a3)+
	dbra	d2,.loop_sample_pad_loop	;loop back to pad sample loop
;
.sample_ok:
	move	d3,Amiga_Length(a0)
	move	d1,Amiga_Repeat_Length(a0)
	clr	Amiga_Repeat_Start(a0)
;
.NextSample:
	lea.l	Amiga_Size(a0),a0
	dbra	d0,.Simplet_Next_Sample
;
Reinit_Module:
	move	ticks_per_divs(pc),tick_counter	;ensure immediate divs & beat initialization
	move	#-1,Simplet_Pattern_Position	;ensure immediate pattern update
	clr	Simplet_Song_Position
	clr	Simplet_Pattern_Break_Position
	sf	Simplet_Pattern_Break_Flag
	sf	Simplet_Position_Jump_Flag
	sf	Simplet_Pattern_Loop_Flag
	clr.b	Simplet_Pattern_Delay_Time
	sf	song_looped_f
;
	move.l	workspace_p(pc),a0
	move.l	#1000,d1
	move.l	#500,d2
	move	#2345,d4
	clr.l	d5
;
	lea.l	Simplet_Voices(pc),a6
	moveq.l	#8-1,d7
Init_Voice_loop:
	clr.l	Voice_Sample_Offset(a6)
	clr.l	Voice_Sample_Position(a6)
	move.l	a0,Voice_Start(a6)
	move.l	a0,Voice_Sample_Start(a6)
	move.l	a0,Voice_Funk_Start(a6)
	move.l	d1,Voice_Length(a6)
	move.l	d1,Voice_Sample_Length(a6)
	move.l	d2,Voice_Repeat_Length(a6)
	move.l	d2,Voice_Sample_Repeat_Length(a6)
	move	d4,Voice_Note_Period(a6)
	move	d4,Voice_Period(a6)
	move	d4,Voice_Sample_Period(a6)
	move	d5,Voice_Volume(a6)
	move	d5,Voice_Sample_Volume(a6)
;
	clr	Voice_Wanted_Period(a6)
	clr.l	Voice_Tone_Port_Direction(a6)	;also Port_Speed,Glissando_Control,Vibrato_Command
	clr.l	Voice_Vibrato_Position(a6)	;also Vibrato_Control,Tremolo_Command,Tremolo_Position
	clr.b	Voice_Tremolo_Control(a6)
	clr	Voice_Funk_Speed(a6)		;also Funk_Offset
	clr.l	Voice_Funk_Position(a6)
;
	lea	Voice_Size(a6),a6
	dbra	d7,Init_Voice_loop
	bsr	play_norm_frame
	rts
;
;----------------------------------------------------------------------------
;
tracker_68K:
	move	tracker_sr(pc),-(sp)
	move	sr,tracker_sr
	movem.l	d0-d7/a0-a6,-(sp)	;Protect interrupted registers
	clr	frame_need		;start new track call
tracker_loop:
	lea.l	(hw_dsp_is).w,a6		;a6 -> DSP status register
	move.b	track_busy_f(pc),d0		;was DSP recently Busy ?
	beq.s	done_Ready_test			;if not, skip testing for Ready
	rx_CODE	#Tk_Ready_delay			;try to receive a Ready code
	cmp.l	#Tk_Ready_s_c,d0		;DSP ready now ?
	bne	end_tracking			;give up if reception dead
	sf	track_busy_f			;clear busy flag when ready
done_Ready_test:
	or	#$0700,sr			;disable interrupts
	move.b	#$80+$26/2,(hw_dsp_cv).w	;DSP Host User 0, vector $26
	tx_CODE	#Tk_Track_delay,#Tk_Track_s_c	;try to send Track code
	bmi	end_tracking			;give up if transmission is dead
	rx_CODE	#Tk_Track_delay			;try to receive a receipt
	bmi	end_tracking			;give up if reception is dead
	move	tracker_sr(pc),sr		;enable interrupts
	cmp.l	#Tk_Track_s_c,d0		;DSP receipt correct ?
	beq	track_frame			;go track if receipt correct
	cmp.l	#Tk_Error_s_c,d0		;Error code received ?
	beq.s	tracker_loop			;if so, then retry
	cmp.l	#Tk_Busy_s_c,d0			;Busy code received ?
	seq	track_busy_f			;set the busy flag accordingly
	beq	tracker_loop			;if DSP busy, go wait for it to get ready
;
;Future protocol cases can be inserted here
;
	bra	end_tracking			;skip tracking on protocol failure
;
;------------------------------------
;
track_frame:
	st	track_busy_f		;set busy flag when starting track work
	rx_CODE	#Tk_Track_delay		;try to get d0 = sample interval room for this frame
	bmi	end_tracking		;give up if reception is dead
	and.l	#$0000ffff,d0		;limit d0
	cmp	frame_norm(pc),d0	;too small frame ?
	bhs.s	.keep_request
	clr	d0			;to avoid miniature frames
	clr	frame_need		;we simulate zero request and
	bra.s	.send_size		;go tell DSP program about it
;
.keep_request:
	tst	frame_need
	bne.s	.keep_frame_need
	move	d0,frame_need		;store track need for this call
.keep_frame_need:
	move	frame_norm(pc),d0	;We will handle one frame now
.send_size:
	sub	d0,frame_need		;sub from track need for this call
	tx_CODE	#Tk_Track_delay,d0	;Tx(DSP) = frame size
	ble.s	end_tracking		;exit if size==0 or if transmission fails
;
	clr.l	d7
	move	Simplet_Voices_Nb(pc),d7
	subq	#2,d7
	lsr	d7			;d7 = number of (voices-2)/2
	tx_CODE	#Tk_Track_delay,d7	;Tx(DSP) = number of (voices-2)/2
;
;send the samples to DSP
;
	move.l	Voice_Order_p(pc),a4		;a4 -> table of ptrs to voices
	move	Simplet_Voices_Nb(pc),d7	;d7 = total number of voices  (4, 6 or 8)
	subq	#1,d7				;prep d7 for dbra
.send_all_voices:				;send left on odd, right on even passes
	move.l	(a4)+,a5
	bsr.s	send_voice_a5
	dbra	d7,.send_all_voices
;
	bsr	play_norm_frame		;play patterns for next frame
;
	move	frame_need(pc),d0	;d0 = frame_need
	bgt	tracker_loop		;loop back to cover tracking needs
end_tracking:
	movem.l	(sp)+,d0-d7/a0-a6
	move	tracker_sr(pc),sr
	move	(sp)+,tracker_sr
	rts
;
;----------------------------------------------------------------------------
;send_voice_a5: Sends one voice(a5) to the DSP per call
;
send_voice_a5:
	move	volume_boost,d0			;d0 = volume boost index
	and	#3,d0				;d0 = limited index
	lea	VolumeCoeff_tpt(pc),a0		;a0 -> volume coefficient table pointer table
	move.l	(a0,d0.w*4),a0			;a0 -> volume coefficient table
	clr.l	d1
	move	Simplet_Voices_Nb(pc),d1	;d1 = voices used
	and	#$F,d1				;d1 = limited index
	clr.l	d0
	move	Voice_Sample_Volume(a5),d0
;
	mulu.l	(a0,d1.w*4),d0			;d0 = DSP adapted volume
	bra.s	Send_Volume			;jump past table
;
Send_Volume:
	tx_CODE	#Tk_Track_delay,d0		;Tx(DSP) = Volume
	bmi	.send_voice_error
;
	move.l	#$800000/DSP_sample_fq*428*8363,d0
	clr.l	d1
	move	Voice_Sample_Period(a5),d1
	divu.l	d1,d0
	tx_CODE	#Tk_Track_delay,d0		;Tx(DSP) = frequency period
	bmi	.send_voice_error
;
; Explanation of above calculation
;
; $800000 is the DSP form of 1.0
; DSP_sample_fq Hz is the output sampling frequency
; 8363 Hz is the voice samling frequency of the reference note DO-2
; 428 is a reference value of Voice_Sample_Period for producing the note DO-2
; that period value is equal to 3579364/voice_sampling_frequency
;
; The final quotient is the DSP form of the amount of the voice sample period
; represented by each output sampling period, which is the same thing as the
; voice sample frequency divided by output sampling frequency.
;
; When this quotient is sent to the DSP program, it replies by sending the
; number of voice samples it needs for the current frame
;
	rx_CODE	#Tk_Track_delay		;try to get d0 = voice sample bytes needed
	bmi	.send_voice_error
	and.l	#$0000ffff,d0		;limit d0
;
	movea.l	Voice_Sample_Start(a5),a0	;a0 -> sample data start
	move.l	Voice_Sample_Position(a5),d2	;d2 = current sample position
	adda.l	d2,a0				;a0 -> current sample data
	add.l	d0,d2				;d2 = next sample position
;
	cmp.l	Voice_Sample_Length(a5),d2	;d2 at or past sample end ?
	blt.s	.skip_wrap				;If not, keep it
	sub.l	Voice_Sample_Repeat_Length(a5),d2	;else wrap it around limits
;NB:	a0/d0 are still unwrapped, requiring padded samples
.skip_wrap:
	move.l	d2,Voice_Sample_Position(a5)	;Store next position
;
	addq	#8,d0				;3 for extra samples + 5 for rounding
	divu	#6,d0				;d0 = (sample bytes needed)/6
	addq	#1,d0				;pad it
	move.l	d0,d2				;move it to d2
	tx_CODE	#Tk_Track_delay,d0		;Tx(DSP) = number of 6-byte packets (rounded up)
	bmi.s	.send_voice_error
;
	move.l	-2(a0),d1			;d1 = initial packet 0
	cmp.l	Voice_Sample_Start(a5),a0	;at sample start ?
	bne.s	.keep_old_sample
	and.l	#$ffff,d1			;d1 = fixed for sample start
.keep_old_sample:
	tx_CODE	#Tk_Track_delay,d1		;send 1st initial packet DSP_word
	bmi.s	.send_voice_error
	tx_CODE	#Tk_Track_delay,1(a0)		;send 2nd initial packet DSP_word
	bmi.s	.send_voice_error
;
	addq	#4,a0				;adjust for DSP_words as longwords
	subq	#2,d2				;adjust for dbra and initial packet
.Send_Samples:
	tx_CODE	#Tk_Track_delay,(a0)		;Tx(DSP) = 1st packet DSP_word
	bmi.s	.send_voice_error
	tx_CODE	#Tk_Track_delay,3(a0)		;Tx(DSP) = 2nd packet DSP_word
	bmi.s	.send_voice_error
	addq.l	#6,a0				;a0 -> next packet
	dbra	d2,.Send_Samples		;loop back for more packets
	clr.l	d0
	rts
;
.send_voice_error:
	moveq	#-1,d0
	rts
;
;----------------------------------------------------------------------------
;
VolumeCoeff_tpt:
	dc.l	VolumeCoeff_0_t				;0: Soft
	dc.l	VolumeCoeff_1_t				;1: Normal
	dc.l	VolumeCoeff_2_t				;2: Boost
	dc.l	VolumeCoeff_3_t				;3: Super-boost
;
;----------------------------------------------------------------------------
;
VolumeCoeff_0_t:					;$0ffff/n  ==  (($7fffff/$40)/n)/2
	dc.l	$0ffff,$0ffff,$07fff,$05555		;0, 1, 2, 3  voices
	dc.l	$03fff,$03333,$01AAA,$02492		;4, 5, 6, 7  voices
	dc.l	$01fff,$01c71,$01999,$01745		;8, 9, a, b  voices
	dc.l	$01555,$013b1,$01249,$01111		;c, d, e, f  voices
;
;----------------------------------------------------------------------------
;
VolumeCoeff_1_t:					;$1ffff/n  ==  ($7fffff/$40)/n
	dc.l	$1ffff,$1ffff,$0ffff,$0aaaa		;0, 1, 2, 3  voices
	dc.l	$07fff,$06666,$05555,$04924		;4, 5, 6, 7  voices
	dc.l	$03fff,$038e3,$03333,$02E8b		;8, 9, a, b  voices
	dc.l	$02aaa,$02762,$02492,$02222		;c, d, e, f  voices
;
;----------------------------------------------------------------------------
;
VolumeCoeff_2_t:					;$3ffff/n  ==  (($7fffff/$40)/n)*2
	dc.l	$3ffff,$3ffff,$1ffff,$15555		;0, 1, 2, 3  voices
	dc.l	$0ffff,$0CCCC,$0AAAA,$09249		;4, 5, 6, 7  voices
	dc.l	$07fff,$071c7,$06666,$05d17		;8, 9, a, b  voices
	dc.l	$05555,$04ec4,$04924,$04444		;c, d, e, f  voices
;
;----------------------------------------------------------------------------
;
VolumeCoeff_3_t:					;$7ffff/n  ==  (($7fffff/$40)/n)*4
	dc.l	$7ffff,$7ffff,$3ffff,$2AAAA		;0, 1, 2, 3  voices
	dc.l	$1ffff,$19999,$15555,$12492		;4, 5, 6, 7  voices
	dc.l	$0ffff,$0e38e,$0cccc,$0ba2e		;8, 9, a, b  voices
	dc.l	$0aaaa,$09d89,$09249,$08888		;c, d, e, f  voices
;
;----------------------------------------------------------------------------
;	Module pattern player
;
play_norm_frame:
	addq	#1,tick_counter
	move	tick_counter(pc),d0
	cmp	ticks_per_divs(pc),d0
	blo	No_New_Note
	clr	tick_counter
;
	tst.b	Simplet_Pattern_Break_Flag(pc)
	bne.s	.New_Pattern
	tst.b	Simplet_Pattern_Delay_Time(pc)
	beq.s	.No_delay
;
	subq.b	#1,Simplet_Pattern_Delay_Time
	bra	No_New_Note
;
.No_delay:
	tst.b	Simplet_Pattern_Loop_Flag(pc)
	beq.s	.No_Pattern_Loop
;
	move	Simplet_Pattern_Loop_Position(pc),Simplet_Pattern_Position
	sf	Simplet_Pattern_Loop_Flag
	bra.s	Simplet_New_Notes
;
.No_Pattern_Loop:
	tst.b	Simplet_Position_Jump_Flag(pc)
	beq.s	.Simplet_New_Line
;
	move	Simplet_Position_Jump_Pos(pc),d0
	sf	Simplet_Position_Jump_Flag
	bra.s	.new_song_position
;
.Simplet_New_Line:
	addq	#1,Simplet_Pattern_Position
	move	Simplet_Pattern_Position(pc),d0
	cmp	Simplet_Pattern_Length(pc),d0
	blo.s	Simplet_New_Notes
;
.New_Pattern:
	move	Simplet_Song_Position(pc),d0
	addq	#1,d0
.new_song_position:
	move	Simplet_Pattern_Break_Position(pc),Simplet_Pattern_Position
	clr	Simplet_Pattern_Break_Position
	sf	Simplet_Pattern_Break_Flag
;
	cmp	Simplet_Song_Length(pc),d0
	blo.s	.use_song_position_d0
	st	song_looped_f
	move	Simplet_Song_Restart(pc),d0
	bne.s	.use_song_position_d0
	move	#125,beat_tempo		;reset to default tempo
	move	#6,ticks_per_divs		;reset to default speed
	move	#DSP_sample_fq/50+1,frame_norm	;reset to Default normalized frame
.use_song_position_d0:
	move	d0,Simplet_Song_Position
Simplet_New_Notes:
	movea.l	module_p(pc),a5
	lea	20(a5),a5			;a5 -> sample headers
	movea.l	Simplet_Sequence_Adr(pc),a0
	move	Simplet_Song_Position(pc),d1
	clr.l	d0
	move.b	(a0,d1.w),d0
	mulu.w	Simplet_Pattern_Size(pc),d0
	movea.l	Simplet_Patterns_Adr(pc),a4
	adda.l	d0,a4				;a4 -> Pattern
	move	Simplet_Pattern_Position(pc),d0
	mulu.w	Simplet_Line_Size(pc),d0
	adda.w	d0,a4				;a4 -> Pattern line
;
	lea.l	Simplet_Voices(pc),a6
	move	Simplet_Voices_Nb(pc),d7
	subq	#1,d7
.New_Notes_Loop:
	bsr.s	Play_Voice
;
	lea.l	Voice_Size(a6),a6
	dbra	d7,.New_Notes_Loop
	rts
;
No_New_Note:
	lea.l	Simplet_Voices(pc),a6
	move	Simplet_Voices_Nb(pc),d7
	subq	#1,d7
.No_New_Note_Loop:
	bsr	Check_Efx_2
	lea.l	Voice_Size(a6),a6
	dbra	d7,.No_New_Note_Loop
	rts
;
;ends:	play_norm_frame
;----------------------------------------------------------------------------
;
Play_Voice:
	move	(a4)+,d1
	move.b	(a4)+,d2
	move.b	(a4)+,Voice_Parameters(a6)
;
	move	d1,d0
	and	#$0fff,d0
	move	d0,Voice_Note_Period(a6)
	and	#$f000,d1
	lsr	#8,d1
	move.b	d2,d0
	lsr.b	#4,d0
	add.b	d1,d0			;d0 = sample code
	and.b	#$0f,d2
	move.b	d2,Voice_Command(a6)
;
	clr.b	Voice_New_Sample(a6)
	clr.l	d2
	move.b	d0,d2			;d2 = sample code
	beq	.done_all_sample_settings
	cmp.b	Voice_Old_Sample(a6),d2
	beq.s	.done_some_sample_settings
	move.b	d2,Voice_New_Sample(a6)
	move.b	d2,Voice_Old_Sample(a6)
;
.done_some_sample_settings:
	subq	#1,d2
	lea.l	Simplet_Samples_Adr(pc),a1
	move.l	(a1,d2.w*4),Voice_Start(a6)
	clr.l	Voice_Sample_Offset(a6)
	mulu.w	#Amiga_Size,d2		;d2 = sample header index
;
	move.b	Amiga_Fine_Tune(a5,d2.w),d0
	and	#$0f,d0
	move.b	.signybl_to_byte_t(pc,d0.w),d0
	ext	d0
	asr	d0
	scs	Voice_Special_f(a6)
	move	d0,Voice_Sample_Fine_Tune(a6)
	bra.s	.done_fine_tune
;
.signybl_to_byte_t:
	dc.b		0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1
;
.done_fine_tune:
	clr.l	d0
	move	Amiga_Length(a5,d2.w),d0
	add.l	d0,d0
	move.l	d0,Voice_Length(a6)
	clr.l	d0
	move	Amiga_Repeat_Length(a5,d2.w),d0
	add.l	d0,d0
	move.l	d0,Voice_Repeat_Length(a6)
	clr.l	d0
	move.b	Amiga_Volume(a5,d2.w),d0
	move	d0,Voice_Volume(a6)
	move	d0,Voice_Sample_Volume(a6)
;
	move	Amiga_Repeat_Start(a5,d2.w),d0
	add.l	Voice_Start(a6),d0
	move.l	d0,Voice_Funk_Start(a6)
;
.done_all_sample_settings:
	tst	Voice_Note_Period(a6)
	beq	Simplet_Check_Efx_1
;
	move	Voice_Command(a6),d0
	and	#$0ff0,d0
	cmp	#$0e50,d0			;command E5x ?
	beq.s	URAn_Set_Fine_Tune
;
	move.b	Voice_Command(a6),d0
	subq.b	#3,d0				; 3 = Tone Portamento,  slide to note
	beq	Simplet_Set_Tone_Portamento
	subq.b	#2,d0				; 5 = Tone Porta + Vol Slide
	beq	Simplet_Set_Tone_Portamento
	subq.b	#4,d0				; 9 = Sample Offset
	bne.s	Simplet_Set_Period
;
	bsr	Simplet_Sample_Offset
	bra.s	Simplet_Set_Period
;
URAn_Set_Fine_Tune:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	move.b	.signybl_to_byte_t(pc,d0.w),d0
	ext	d0
	asr	d0
	scs	Voice_Special_f(a6)
	move	d0,Voice_Sample_Fine_Tune(a6)
	bra.s	.done_fine_tune
;
.signybl_to_byte_t:
	dc.b		0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1
;
.done_fine_tune:
Simplet_Set_Period:
	lea	period_to_note_t(pc),a0
	move	Voice_Note_Period(a6),d0
	move.b	(a0,d0),d0			;d0 = logarithmic note
	ext	d0
	add	Voice_Sample_Fine_Tune(a6),d0	;d0 = finetuned logarithmic note
	lea	note_to_period_t(pc),a0
	move	(a0,d0.w*2),d1
	tst.b	Voice_Special_f(a6)
	beq.s	.have_fine_tune
	add	2(a0,d0.w*2),d1
	lsr	d1
.have_fine_tune:
	move	d1,Voice_Period(a6)	;set real voice period
;
	move	Voice_Command(a6),d0
	and	#$0ff0,d0
	cmp	#$0ed0,d0			;command EDx ?
	bne.s	Simplet_No_Note_Delay
	move.b	Voice_Parameters(a6),d0
	and.b	#$0f,d0
	beq.s	Simplet_No_Note_Delay
	rts
;
Simplet_No_Note_Delay:
	move	Voice_Period(a6),Voice_Sample_Period(a6)
	move.l	Voice_Start(a6),Voice_Sample_Start(a6)
	move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
	move.l	Voice_Length(a6),d0
	move.l	Voice_Repeat_Length(a6),d1
	add.l	d1,d0
	move.l	d0,Voice_Sample_Length(a6)
	move.l	d1,Voice_Sample_Repeat_Length(a6)
;
	btst.b	#2,Voice_Vibrato_Control(a6)
	bne.s	Simplet_Vibrato_No_Reset
	clr.b	Voice_Vibrato_Position(a6)
Simplet_Vibrato_No_Reset:
	btst.b	#2,Voice_Tremolo_Control(a6)
	bne.s	Simplet_Tremolo_No_Reset
	clr.b	Voice_Tremolo_Position(a6)
Simplet_Tremolo_No_Reset:
Simplet_Check_Efx_1:
	bsr	Funk_Update
	clr.l	d0
	move.b	Voice_Command(a6),d0
	jmp	([Jump_Table_1,d0.w*4])

Jump_Table_1:
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Period_Nop
	dc.l	Simplet_Position_Jump
	dc.l	Volume_Change
	dc.l	Simplet_Pattern_Break
	dc.l	Simplet_E_Commands_1
	dc.l	Simplet_Set_Speed
;
Simplet_E_Commands_1:
	move.b	Voice_Parameters(a6),d0
	and	#$f0,d0
	lsr	#4,d0
	jmp	([Jump_Table_E1,d0.w*4])
;
Jump_Table_E1:
	dc.l	Simplet_Return			;0	;Amiga filter on/off
	dc.l	Simplet_Fine_Portamento_Up	;1
	dc.l	Simplet_Fine_Portamento_Down	;2
	dc.l	Simplet_Set_Glissando_Control	;3
	dc.l	Simplet_Set_Vibrato_Control	;4
	dc.l	URAn_Set_Fine_Tune		;5	;Set finetune value of sample
	dc.l	Simplet_Pattern_Loop	;6
	dc.l	Simplet_Set_Tremolo_Control	;7
	dc.l	Simplet_Return		;8
	dc.l	Simplet_Retrig_Note	;9
	dc.l	Volume_Fine_Up		;a
	dc.l	Volume_Fine_Down	;b
	dc.l	Simplet_Note_Cut	;c
	dc.l	Simplet_Return		;d	;delay sample
	dc.l	Simplet_Pattern_Delay	;e
	dc.l	Simplet_Funk_It		;f
;
;----------------------------------------------------------------------------
;
Check_Efx_2:
	bsr	Funk_Update
	clr.l	d0
	move.b	Voice_Command(a6),d0
	jmp	([Jump_Table_2,d0.w*4])
;
Jump_Table_2:
	dc.l	Simplet_Arpeggio	;0	;play arpeggio with semitone offsets
	dc.l	Simplet_Portamento_Up	;1	;slide note up
	dc.l	Simplet_Portamento_Down	;2	;slide note down
	dc.l	Simplet_Tone_Portamento	;3	;slide to note
	dc.l	Mt_Vibrato	;4
	dc.l	Simplet_Tone_Portamento_Plus_Volume_Slide	;5
	dc.l	Simplet_Vibrato_Plus_Volume_Slide
	dc.l	Mt_Tremolo	;7
	dc.l	Simplet_Return	;8
	dc.l	Simplet_Return	;9	;set sample offset => jump to (x*4096+y*256)*2
	dc.l	Volume_Slide	;a
	dc.l	Simplet_Return	;b	;position jump => pattern jump to (x*16+y)*4
	dc.l	Simplet_Return	;c	;set sample volume => volume = x*16+y
	dc.l	Simplet_Return	;d	;pattern break => jump to (x*16+y)*4 of next pattern
	dc.l	Simplet_E_Commands_2	;extended commands, see separate jump table
	dc.l	Simplet_Return	;f	;set speed (complex...)
;
;----------------------------------------------------------------------------
;
Simplet_E_Commands_2:
	move.b	Voice_Parameters(a6),d0
	and	#$f0,d0
	lsr	#4,d0
	jmp	([Jump_Table_E2,d0.w*4])
;
Jump_Table_E2:
	dc.l	Simplet_Return	;0
	dc.l	Simplet_Return	;1
	dc.l	Simplet_Return	;2
	dc.l	Simplet_Return	;3
	dc.l	Simplet_Return	;4
	dc.l	Simplet_Return	;5
	dc.l	Simplet_Return	;6
	dc.l	Simplet_Return	;7
	dc.l	Simplet_Return	;8
	dc.l	Simplet_Retrig_Note	;9
	dc.l	Simplet_Return	;a
	dc.l	Simplet_Return	;b
	dc.l	Simplet_Note_Cut	;c
	dc.l	Simplet_Note_Delay	;d
	dc.l	Simplet_Return	;e
	dc.l	Simplet_Return	;f
;
;----------------------------------------------------------------------------
;
Simplet_Period_Nop:
	move	Voice_Period(a6),Voice_Sample_Period(a6)
Simplet_Return:
	rts
;
;----------------------------------------------------------------------------
;
Simplet_Arpeggio_Table:
	dc.b	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	dc.b	1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
;
Simplet_Arpeggio:
	move.b	Voice_Parameters(a6),d1
	beq.s	Simplet_Period_Nop
;
	clr.l	d0
	move	tick_counter(pc),d0
	move.b	Simplet_Arpeggio_Table(pc,d0.w),d0
	beq.s	Simplet_Period_Nop
	subq.b	#2,d0
	beq.s	Simplet_Arpeggio_2
;
Simplet_Arpeggio_1:
	lsr	#4,d1
Simplet_Arpeggio_2:
	and	#$0f,d1				;d1 = unsigned semitone offset nybble
	move.b	.nybl_to_byte_times_4_t(pc,d1.w),d1
	ext	d1
	bra.s	.URAn_Arpeggio
;
.nybl_to_byte_times_4_t:
	dc.b		0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60
;
.URAn_Arpeggio:
	move	Voice_Period(a6),d0		;look for old period (already finetuned!)
	lea	period_to_note_t(pc),a0
	move.b	(a0,d0),d0			;d0 = logarithmic note
	ext	d0
	add	d1,d0				;d0 = semitone adjusted logarithmic note
	lea	note_to_period_t(pc),a0
	move	(a0,d0.w*2),Voice_Sample_Period(a6)	;set sample voice period
	rts
;
;----------------------------------------------------------------------------
;
Simplet_Portamento_Up:				;command 1xy => period -= (x*16+y)
	clr.l	d0
	move.b	Voice_Parameters(a6),d0
;
Simplet_Portamento_Up2:
	sub.w	d0,Voice_Period(a6)
	move	Voice_Period(a6),d0
	cmp	min_fx_period(pc),d0
	bgt.s	Simplet_Portamento_Up_Ok
	move	min_fx_period(pc),Voice_Period(a6)
Simplet_Portamento_Up_Ok:
	move	Voice_Period(a6),Voice_Sample_Period(a6)
	rts
;
;----------------------------------------------------------------------------
;
Simplet_Portamento_Down:			;command 2xy => period += (x*16+y)
	clr.l	d0
	move.b	Voice_Parameters(a6),d0
Simplet_Portamento_Down2:
	add	d0,Voice_Period(a6)
	move	Voice_Period(a6),d0
	cmp	max_fx_period(pc),d0
	blo.s	Simplet_Portamento_Down_Ok
	move	max_fx_period(pc),Voice_Period(a6)
Simplet_Portamento_Down_Ok:
	move	Voice_Period(a6),Voice_Sample_Period(a6)
	rts
;
;----------------------------------------------------------------------------
;
Simplet_Set_Tone_Portamento:			;slide period to note
	lea	period_to_note_t(pc),a0
	move	Voice_Note_Period(a6),d0
	move.b	(a0,d0.w),d0			;d0 = logarithmic note
	ext	d0
	add	Voice_Sample_Fine_Tune(a6),d0	;d0 = finetuned logarithmic note
	move	d0,Voice_Slide_Note(a6)		;store goal note, for glissando case
;
	lea	note_to_period_t(pc),a0
	move	(a0,d0.w*2),d1
	tst.b	Voice_Special_f(a6)
	beq.s	.have_fine_tune
	add	2(a0,d0.w*2),d1
	lsr	d1
.have_fine_tune:
	move	d1,d0			;d0 = real voice period for slide
;
	move	d0,Voice_Wanted_Period(a6)
	move	Voice_Period(a6),d1
	sf	Voice_Tone_Port_Direction(a6)
	cmp	d1,d0
	beq.s	Simplet_Clear_Tone_Portamento
	bge	Simplet_Period_Nop
	st	Voice_Tone_Port_Direction(a6)
	rts
;
Simplet_Clear_Tone_Portamento:
	clr	Voice_Wanted_Period(a6)
	rts
;
Simplet_Tone_Portamento:			;command 3xy
	move.b	Voice_Parameters(a6),d0
	beq.s	Simplet_Tone_Portamento_No_Change
	move.b	d0,Voice_Tone_Port_Speed(a6)
	clr.b	Voice_Parameters(a6)
;
Simplet_Tone_Portamento_No_Change:
	tst	Voice_Wanted_Period(a6)		;still sliding ?
	beq	Simplet_Period_Nop		;jump if note slide completed
	clr.l	d0
	move.b	Voice_Tone_Port_Speed(a6),d0
	tst.b	Voice_Tone_Port_Direction(a6)
	bne.s	Simplet_Tone_Portamento_Up
;
Simplet_Tone_Portamento_Down:
	add	d0,Voice_Period(a6)
	move	Voice_Wanted_Period(a6),d0
	cmp	Voice_Period(a6),d0
	bgt.s	Simplet_Tone_Portamento_Set_Period
	move	Voice_Wanted_Period(a6),Voice_Period(a6)
	clr	Voice_Wanted_Period(a6)
	bra.s	Simplet_Tone_Portamento_Set_Period
;
Simplet_Tone_Portamento_Up:
	sub.w	d0,Voice_Period(a6)
	move	Voice_Wanted_Period(a6),d0
	cmp	Voice_Period(a6),d0
	blt.s	Simplet_Tone_Portamento_Set_Period
	move	Voice_Wanted_Period(a6),Voice_Period(a6)
	clr	Voice_Wanted_Period(a6)
;
Simplet_Tone_Portamento_Set_Period:
	move	Voice_Period(a6),d0		;period of raw slide pos (already fine_tuned)
	tst.b	Voice_Glissando_Control(a6)
	beq.s	.use_period			;jump if no glissando
;
	lea	period_to_note_t(pc),a0
	move.b	(a0,d0.w),d0
	ext	d0				;d0 = logarithmic note for raw slide pos
	move	Voice_Slide_Note(a6),d1		;d1 = logarithmic note for slide goal
	sub	d1,d0				;d0 = 48th octave steps of (pos_note-goal_note)
	addq	#4/2,d1
	and	#-4,d1				;d0 = steps from goal to semitone nearest pos_note
	add	d1,d0				;d0 = semitone nearest raw pos
	lea	note_to_period_t(pc),a0
	move	(a0,d0.w*2),d0			;d0 = semitone voice period for slide
.use_period:
	move	d0,Voice_Sample_Period(a6)	;use this period for sample
	rts
;
Mt_Vibrato:
	move.b	Voice_Parameters(a6),d0
	beq.s	Mt_Vibrato2
	move.b	Voice_Vibrato_Command(a6),d2
	and.b	#$0f,d0
	beq.s	Mt_VibSkip
	and.b	#$f0,d2
	or.b		d0,d2
Mt_VibSkip:
	move.b	Voice_Parameters(a6),d0
	and.b	#$f0,d0
	beq.s	Mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
Mt_vibskip2:
	move.b	d2,Voice_Vibrato_Command(a6)
Mt_Vibrato2:
	move.b	Voice_Vibrato_Position(a6),d0
	lea.l	Simplet_Sinus_Table(pc),a3
	lsr	#2,d0
	and	#$001f,d0
	clr.l	d2
	move.b	Voice_Vibrato_Control(a6),d2
	and.b	#$3,d2
	beq.s	Mt_Vib_Sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	Mt_Vib_RampDown
	move.b	#255,d2
	bra.s	Mt_Vib_Set
;
Mt_Vib_RampDown:
	tst.b	Voice_Vibrato_Position(a6)
	bpl.s	Mt_Vib_RampDown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	Mt_Vib_Set
;
Mt_Vib_RampDown2:
	move.b	d0,d2
	bra.s	Mt_Vib_Set
;
Mt_Vib_Sine:
	move.b	(a3,d0.w),d2
Mt_Vib_Set:
	move.b	Voice_Vibrato_Command(a6),d0
	and	#15,d0
	mulu.w	d0,d2
	lsr	#7,d2
	move	Voice_Period(a6),d0
	tst.b	Voice_Vibrato_Position(a6)
	bmi.s	Mt_VibratoNeg
	add	d2,d0
	bra.s	Mt_Vibrato3
;
Mt_VibratoNeg:
	sub.w	d2,d0
Mt_Vibrato3:
	move	d0,Voice_Sample_Period(a6)
	move.b	Voice_Vibrato_Command(a6),d0
	lsr	#2,d0
	and	#$003c,d0
	add.b	d0,Voice_Vibrato_Position(a6)
	rts
;
Simplet_Tone_Portamento_Plus_Volume_Slide:
	bsr	Simplet_Tone_Portamento_No_Change
	bra	Volume_Slide
;
Simplet_Vibrato_Plus_Volume_Slide
	bsr.s	Mt_Vibrato2
	bra	Volume_Slide
;
Mt_Tremolo
	move.b	Voice_Parameters(a6),d0
	beq.s	Mt_Tremolo2
	move.b	Voice_Tremolo_Command(a6),d2
	and.b	#$0f,d0
	beq.s	Mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
Mt_treskip
	move.b	Voice_Parameters(a6),d0
	and.b	#$f0,d0
	beq.s	Mt_treskip2
	and.b	#$0f,d2
	or.b		d0,d2
Mt_treskip2:
	move.b	d2,Voice_Tremolo_Command(a6)
Mt_Tremolo2:
	move.b	Voice_Tremolo_Position(a6),d0
	lea.l	Simplet_Sinus_Table(pc),a3
	lsr	#2,d0
	and	#$001f,d0
	clr.l	d2
	move.b	Voice_Tremolo_Control(a6),d2
	and.b	#$3,d2
	beq.s	Mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	Mt_tre_rampdown
	move.b	#255,d2
	bra.s	Mt_tre_set
;
Mt_tre_rampdown:
	tst.b	Voice_Tremolo_Position(a6)
	bpl.s	Mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	Mt_tre_set
;
Mt_tre_rampdown2:
	move.b	d0,d2
	bra.s	Mt_tre_set
;
Mt_tre_sine:
	move.b	(a3,d0.w),d2
Mt_tre_set:
	move.b	Voice_Tremolo_Command(a6),d0
	and	#15,d0
	mulu.w	d0,d2
	lsr	#6,d2
	clr.l	d0
	move	Voice_Volume(a6),d0
	tst.b	Voice_Tremolo_Position(a6)
	bmi.s	Mt_TremoloNeg
	add	d2,d0
	bra.s	Mt_Tremolo3
;
Mt_TremoloNeg:
	sub.w	d2,d0
Mt_Tremolo3:
	bpl.s	Mt_TremoloSkip
	clr	d0
Mt_TremoloSkip:
	cmp	#$40,d0
	bls.s	Mt_TremoloOk
	move	#$40,d0
Mt_TremoloOk:
	move	d0,Voice_Sample_Volume(a6)
	move.b	Voice_Tremolo_Command(a6),d0
	lsr	#2,d0
	and	#$003c,d0
	add.b	d0,Voice_Tremolo_Position(a6)
	bra		Simplet_Period_Nop
;
Simplet_Sample_Offset:
	move.l	Voice_Sample_Offset(a6),d1
	clr.l	d0
	move.b	Voice_Parameters(a6),d0
	beq.s	Simplet_Sample_Offset_No_New
;
	lsl.w	#8,d0
	move.l	d0,d1
Simplet_Sample_Offset_No_New:
;
	move.l	Voice_Sample_Offset(a6),d0
	add.l	d1,d0
	cmp.l	Voice_Length(a6),d0
	ble.s	Simplet_Sample_Offset_Ok
	move.l	Voice_Length(a6),d0
Simplet_Sample_Offset_Ok:
	move.l	d0,Voice_Sample_Offset(a6)
	move.l	d0,Voice_Sample_Position(a6)
	rts
;
Volume_Slide:
	clr.l	d0
	move.b	Voice_Parameters(a6),d0
	lsr	#4,d0
	beq.s	Volume_Slide_Down
	mulu	#5,d0
Volume_Slide_Up_d0:
	add	d0,Voice_Volume(a6)
	cmp	#$40,Voice_Volume(a6)
	ble.s	Volume_Slide_Up_Ok
	move	#$40,Voice_Volume(a6)
;
Volume_Slide_Up_Ok:
	move	Voice_Volume(a6),Voice_Sample_Volume(a6)
	bra	Simplet_Period_Nop
;
Volume_Slide_Down:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	mulu	#5,d0
Volume_Slide_Down_d0:
	sub.w	d0,Voice_Volume(a6)
	bpl.s	Volume_Slide_Down_Ok
	clr	Voice_Volume(a6)
;
Volume_Slide_Down_Ok:
	move	Voice_Volume(a6),Voice_Sample_Volume(a6)
	bra	Simplet_Period_Nop
;
Simplet_Position_Jump:
	clr.l	d0
	move.b	Voice_Parameters(a6),d0
;
	move	d0,Simplet_Position_Jump_Pos
	st	Simplet_Position_Jump_Flag
	rts
;
Volume_Change:
	clr.l	d0
	move.b	Voice_Parameters(a6),d0
	cmp.b	#$40,d0
	ble.s	Volume_Change_Ok
	moveq.l	#$40,d0
;
Volume_Change_Ok:
	move	d0,Voice_Volume(a6)
	move	d0,Voice_Sample_Volume(a6)
	rts
;
Simplet_Pattern_Break:
	clr.l	d0
;
	tst.b	Simplet_Old_Module(pc)
	bne.s	Simplet_Pattern_Break_Ok
;
	move.b	Voice_Parameters(a6),d0
;
	move	d0,d2			; Codage en BCD
	lsr	#4,d0			; premier chiffre
	mulu.w	#10,d0			; les dizaines
	and	#$0f,d2			; deuxiŠme chiffre
	add	d2,d0			; les unit‚s
;
	cmp	Simplet_Pattern_Length(pc),d0
	blo.s	Simplet_Pattern_Break_Ok
	clr.l	d0
;
Simplet_Pattern_Break_Ok:
	move	d0,Simplet_Pattern_Break_Position
	st	Simplet_Pattern_Break_Flag
	rts
;
Simplet_Set_Speed:
	clr.l	d0
	move.b	Voice_Parameters(a6),d0
	beq.s	.exit
	cmp	#32,d0
	bhi.s	.Set_Tempo
	move	d0,ticks_per_divs	;set ticks_per_divs [ticks/divs]
	move	d0,d1			;d1 = new_speed
	move	#6*125,d0		;d0 = default_tempo * default_speed
	divu	d1,d0			;d0 = default_tempo * default_speed / new_speed
	move	d0,beat_tempo		;set beat_tempo [beats/min == 4_divs/min == divs/15_sec]
	move	#DSP_sample_fq/50+1,frame_norm	;Default normalized frame
	rts
;
.Set_Tempo:
	move	d0,beat_tempo		;set beat_tempo [beats/min == 4_divs/min == divs/15_sec]
.fix_frame_norm:
	move	beat_tempo(pc),d1
	mulu	ticks_per_divs(pc),d1
	move.l	#DSP_sample_fq*15,d0
	divu	d1,d0
	move	d0,frame_norm
.exit:
	rts
;
Simplet_Fine_Portamento_Up:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	bra	Simplet_Portamento_Up2
;
Simplet_Fine_Portamento_Down:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	bra	Simplet_Portamento_Down2
;
Simplet_Set_Glissando_Control:
	move.b	Voice_Parameters(a6),Voice_Glissando_Control(a6)
	rts
;
Simplet_Set_Vibrato_Control:
	move.b	Voice_Parameters(a6),Voice_Vibrato_Control(a6)
	rts
;
;----------------------------------------------------------------------------
;
Simplet_Pattern_Loop:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	beq.s	Simplet_Set_Loop_Position
;
	tst	Simplet_Pattern_Loop_Counter(pc)
	beq.s	Simplet_Set_Loop_Counter
;
	subq	#1,Simplet_Pattern_Loop_Counter
	beq		Simplet_Return
;
Simplet_Do_Loop:
	st	Simplet_Pattern_Loop_Flag
	rts
;
Simplet_Set_Loop_Counter:
	move	d0,Simplet_Pattern_Loop_Counter
	bra.s	Simplet_Do_Loop
;
Simplet_Set_Loop_Position:
	move	Simplet_Pattern_Position(pc),Simplet_Pattern_Loop_Position
	rts
;
Simplet_Set_Tremolo_Control:
	move.b	Voice_Parameters(a6),Voice_Tremolo_Control(a6)
	rts
;
Simplet_Retrig_Note:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	beq.s	Simplet_No_Retrig_Note
;
	clr.l	d1
	move	tick_counter(pc),d1
	bne.s	Simplet_Retrig_Note_Skip
;
	tst	Voice_Note_Period(a6)
	bne.s	Simplet_No_Retrig_Note
;
Simplet_Retrig_Note_Skip:
	divu.w	d0,d1
	swap	d1
	tst	d1
	bne.s	Simplet_No_Retrig_Note
;
	move	Voice_Period(a6),Voice_Sample_Period(a6)
	move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
;
Simplet_No_Retrig_Note:
	rts
;
Volume_Fine_Up:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	bra	Volume_Slide_Up_d0
;
Volume_Fine_Down:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	bra	Volume_Slide_Down_d0
;
Simplet_Note_Cut:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	cmp	tick_counter(pc),d0
	bhi.s	.exit
	clr	Voice_Volume(a6)
	clr	Voice_Sample_Volume(a6)
.exit:
	rts
;
Simplet_Note_Delay:
	move.b	Voice_Parameters(a6),d0
	and	#$0f,d0
	cmp	tick_counter(pc),d0
	bhi.s	.exit
	tst	Voice_Note_Period(a6)
	beq	Simplet_Return
;
	move	Voice_Period(a6),Voice_Sample_Period(a6)
	move.l	Voice_Start(a6),Voice_Sample_Start(a6)
	move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
	move.l	Voice_Length(a6),d0
	move.l	Voice_Repeat_Length(a6),d1
	add.l	d1,d0
	move.l	d0,Voice_Sample_Length(a6)
	move.l	d1,Voice_Sample_Repeat_Length(a6)
.exit:
	rts
;
Simplet_Pattern_Delay:
	tst.b	Simplet_Pattern_Delay_Time(pc)
	bne	Simplet_Return
	move.b	Voice_Parameters(a6),d0
	and.b	#$0f,d0
	move.b	d0,Simplet_Pattern_Delay_Time
	rts
;
Simplet_Funk_It:
	move.b	Voice_Parameters(a6),d0
	and.b	#$0f,d0
	move.b	d0,Voice_Funk_Speed(a6)
	beq	Simplet_Return
;
Funk_Update:
	clr.l	d0
	move.b	Voice_Funk_Speed(a6),d0
	beq	Simplet_Return
;
	lea.l	Simplet_Funk_Table(pc),a0
	move.b	(a0,d0.w),d0
	add.b	d0,Voice_Funk_Offset(a6)
	btst.b	#7,Voice_Funk_Offset(a6)
	beq	Simplet_Return
;
	clr.b	Voice_Funk_Offset(a6)
;
	movea.l	Voice_Funk_Position(a6),a0
	addq	#1,a0
	cmpa.l	Voice_Repeat_Length(a6),a0
	blo.s	Simplet_Funk_Ok
	movea.w	#0,a0
Simplet_Funk_Ok:
	move.l	a0,Voice_Funk_Position(a6)
	add.l	Voice_Funk_Start(a6),a0
	moveq.l	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
	rts		
;
;----------------------------------------------------------------------------
Simplet_Sinus_Table:
	dc.b	0,24,49,74,97,120,141,161,180,197,212,224
	dc.b	235,244,250,253,255,253,250,244,235,224
	dc.b	212,197,180,161,141,120,97,74,49,24
;----------------------------------------------------------------------------
Simplet_Funk_Table:
	dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
;----------------------------------------------------------------------------
; Variables de gestion
;
				ds.b	1
Simplet_Old_Module		ds.b	1
Simplet_Sequence_Adr		ds.l	1
Simplet_Patterns_Adr		ds.l	1
Simplet_Line_Size		ds.w	1
Simplet_Pattern_Size		ds.w	1
Simplet_Samples_Adr		ds.l	31
;
Simplet_Voices_Nb		ds.w	1
Simplet_Samples_Nb		ds.w	1
;
Simplet_Song_Position		ds.w	1
Simplet_Song_Length		ds.w	1
Simplet_Song_Restart		ds.w	1
;
Simplet_Pattern_Position	ds.w	1
Simplet_Pattern_Length		ds.w	1
;
Simplet_Pattern_Loop_Counter	ds.w	1
Simplet_Pattern_Loop_Position	ds.w	1
Simplet_Pattern_Break_Position	ds.w	1
Simplet_Position_Jump_Pos	ds.w	1
Simplet_Pattern_Loop_Flag	ds.b	1
Simplet_Pattern_Break_Flag	ds.b	1
Simplet_Position_Jump_Flag	ds.b	1
Simplet_Pattern_Delay_Time	ds.b	1
;
beat_tempo			dc.w	125	;beats/min def=125
ticks_per_divs			dc.w	6	;ticks/divs def=6
tick_counter			dc.w	0	;ticks passed in current div <= speed
;
;NB: divs/beat == 4, so 4*beat_tempo == divs/min  def = 500
;    4 * beat_tempo * ticks_per_divs == ticks/min  def = 3000
;    so ticktime == 60 / (4 * beat_tempo * ticks_per_divs) in seconds with def = 1/50
;    now frame_norm = DSP_sample_fq * ticktime where DSP_sample_fq is 49169 Hz
;    thus frame_norm == DSP_sample_fq * 15 / (beat_tempo * ticks_per_divs) with def = 983.38
;
;
frame_norm:			dc.w	DSP_sample_fq/50+1	;samples/20ms
frame_need:			ds.w	1	;DSP frame room at tracker entry
;
sample_order:			dc.w	0
;
volume_boost:			dc.w	1	;0:/2,  1:normal,  2:*2,  3:*4
endmode_f:			dc.w	1	;0\1 => loop\stop
song_looped_f:			dc.w	0	;0 = unlooped,  $FF00 = looped
;
Simplet_Voices:			ds.b	8*Voice_Size
;
;----------------------------------------------------------------------------
Voice_Order_p:
	dc.l	Amiga_LR_t
;
Voice_Order_tpt:
	dc.l	Amiga_LR_t
	dc.l	Amiga_RL_t
	dc.l	Simple_LR_t
	dc.l	Simple_RL_t
;------------------------------------
;for Amiga sequence of  LRRLLRRL
;
Amiga_LR_t:
	dc.l	Simplet_Voices+0*Voice_Size,Simplet_Voices+1*Voice_Size
	dc.l	Simplet_Voices+3*Voice_Size,Simplet_Voices+2*Voice_Size
	dc.l	Simplet_Voices+4*Voice_Size,Simplet_Voices+5*Voice_Size
	dc.l	Simplet_Voices+7*Voice_Size,Simplet_Voices+6*Voice_Size
;------------------------------------
;for Amiga sequence of  RLLRRLLR
;
Amiga_RL_t:
	dc.l	Simplet_Voices+1*Voice_Size,Simplet_Voices+0*Voice_Size
	dc.l	Simplet_Voices+2*Voice_Size,Simplet_Voices+3*Voice_Size
	dc.l	Simplet_Voices+5*Voice_Size,Simplet_Voices+4*Voice_Size
	dc.l	Simplet_Voices+6*Voice_Size,Simplet_Voices+7*Voice_Size
;
;------------------------------------
;for simple sequence of  LRLRLRLR
;
Simple_LR_t:
	dc.l	Simplet_Voices+0*Voice_Size,Simplet_Voices+1*Voice_Size
	dc.l	Simplet_Voices+2*Voice_Size,Simplet_Voices+3*Voice_Size
	dc.l	Simplet_Voices+4*Voice_Size,Simplet_Voices+5*Voice_Size
	dc.l	Simplet_Voices+6*Voice_Size,Simplet_Voices+7*Voice_Size
;
;------------------------------------
;for simple sequence of  RLRLRLRL
;
Simple_RL_t:
	dc.l	Simplet_Voices+1*Voice_Size,Simplet_Voices+0*Voice_Size
	dc.l	Simplet_Voices+3*Voice_Size,Simplet_Voices+2*Voice_Size
	dc.l	Simplet_Voices+5*Voice_Size,Simplet_Voices+4*Voice_Size
	dc.l	Simplet_Voices+7*Voice_Size,Simplet_Voices+6*Voice_Size
;----------------------------------------------------------------------------
old_sdma_cont:		ds.b	1
old_f30_dac_trk:	ds.b	1
old_f30_xbar_sc:	ds.w	1
old_f30_xbar_dc:	ds.w	1
old_matr_ffff8937:	ds.b	1
old_conterm:		dc.w	0
dsp_xsize:		dc.l	0
dsp_ysize:		dc.l	0
;
track_busy_f:		dc.w	0
tracker_sr:		dc.w	0
;----------------------------------------------------------------------------
;The table "note_to_period" below is indexed by bipolar offsets relative
;to the central label.  signed byte indexes can be expanded to words to
;give compact capacity for five and a third octaves, with a resolution
;of a third of a seminote (a 48th of an octave).
;
;Padding tables at each end allow an additional 3rd of an octave to be reached
;by using special effects (finetune etc), to vary the voice pitch. Thus the
;full range is actually six full octaves.
;
	dc.w		3520,3470,3420,3371,3322,3275,3228,3182	;$ff70..$ff77
	dc.w		3136,3091,3047,3003,2960,2918,2876,2834	;$ff78..$ff7f
;
max_fx_period:	;The first word is also max limit for voice periods
	dc.w		2794,2754,2714,2675,2637,2599,2562,2525	;$80..$87 octave -3
	dc.w		2489,2453,2418,2383,2349,2316,2282,2250	;$88..$8f (incomplete)
	dc.w		2217,2186,2154,2123,2093,2063,2033,2004	;$90..$97
	dc.w		1976,1947,1919,1892,1865,1838,1812,1786	;$98..$9f
;
	dc.w		1760,1735,1710,1685,1661,1637,1614,1591	;$a0..$a7 octave -2
	dc.w		1568,1546,1523,1502,1480,1459,1438,1417	;$a8..$af
	dc.w		1397,1377,1357,1338,1319,1300,1281,1263	;$b0..$b7
	dc.w		1245,1227,1210,1192,1175,1158,1141,1125	;$b8..$bf
	dc.w		1109,1093,1077,1062,1047,1031,1017,1002	;$c0..$c7
	dc.w		0988,0974,0960,0946,0932,0919,0906,0893	;$c8..$cf
;
	dc.w		0880,0867,0855,0843,0831,0819,0807,0795	;$d0..$d7 octave -1
	dc.w		0784,0773,0762,0751,0740,0729,0719,0709	;$d8..$df
	dc.w		0698,0688,0679,0669,0659,0650,0640,0631	;$e0..$e7
	dc.w		0622,0613,0605,0596,0587,0579,0571,0562	;$e8..$ef
	dc.w		0554,0546,0539,0531,0523,0516,0508,0501	;$f0..$f7
	dc.w		0494,0487,0480,0473,0466,0459,0453,0446	;$f8..$ff
note_to_period_t:
	dc.w		0440,0434,0427,0421,0415,0409,0403,0398	;$00..$07 000..007 octave 0
	dc.w		0392,0386,0381,0375,0370,0365,0359,0354	;$08..$0f 008..015
	dc.w		0349,0344,0339,0334,0330,0325,0320,0316	;$10..$17 016..023
	dc.w		0311,0307,0302,0298,0294,0289,0285,0281	;$18..$1f 024..031
	dc.w		0277,0273,0269,0265,0262,0258,0254,0251	;$20..$27 032..039
	dc.w		0247,0243,0240,0236,0233,0230,0226,0223	;$28..$2F 040..047
;
	dc.w		0220,0217,0214,0211,0208,0205,0202,0199	;$30..$37 048..055 octave +1
	dc.w		0196,0193,0190,0188,0185,0182,0180,0177	;$38..$3f 056..063
	dc.w		0175,0172,0170,0167,0165,0162,0160,0158	;$40..$47 064..071
	dc.w		0156,0153,0151,0149,0147,0145,0143,0141	;$48..$4f 072..079
	dc.w		0139,0137,0135,0133,0131,0129,0127,0125	;$50..$57 080..087
	dc.w		0123,0122,0120,0118,0117,0115,0113,0112	;$58..$5f 088..095
;
	dc.w		0110,0108,0107,0105,0104,0102,0101,0099	;$60..$67 096..103 octave+2
	dc.w		0098,0097,0095,0094,0092,0091,0090,0089	;$68..$6f 104..111 (incomplete)
	dc.w		0087,0086,0085,0084,0082,0081,0080,0079	;$70..$77 112..119
	dc.w		0078,0077,0076,0074,0073,0072,0071	;$78..$7e 120..126
min_fx_period:	;The first word is also max limit for voice periods
	dc.w		0070					;$7f      127
;
	dc.w		0069,0068,0067,0066,0065,0064,0064,0063	;$0080..$0087
	dc.w		0062,0061,0060,0059,0058,0057,0057,0056	;$0088..$008f
;
;----------------------------------------------------------------------------
;The table "period_to_note" below is indexed by unsigned words <$1000, so
;they are best masked by $FFF.  The table values are signed bytes giving the
;note value in 48ths of semitones suitable for indexing the "note_to_period"
;table (above).
;
period_to_note_t:
	dcb.b		70,127					;0000..0069 limited
;
	dc.b		127,126,125,124,123,123,122,121,120,119	;0070..0079
	dc.b		118,117,116,116,115,114,113,112,111,111	;0080..0089
	dc.b		110,109,108,108,107,106,105,105,104,103	;0090..0099
	dc.b		103,102,101,101,100,099,099,098,097,097	;0100..0109
	dc.b		096,095,095,094,094,093,092,092,091,091	;0110..0119
	dc.b		090,089,089,088,088,087,087,086,086,085	;0120..0129
	dc.b		084,084,083,083,082,082,081,081,080,080	;0130..0139
	dc.b		079,079,078,078,077,077,076,076,075,075	;0140..0149
	dc.b		075,074,074,073,073,072,072,071,071,070	;0150..0159
	dc.b		070,070,069,069,068,068,068,067,067,066	;0160..0169
	dc.b		066,065,065,065,064,064,063,063,063,062	;0170..0179
	dc.b		062,062,061,061,060,060,060,059,059,059	;0180..0189
	dc.b		058,058,057,057,057,056,056,056,055,055	;0190..0199
	dc.b		055,054,054,054,053,053,053,052,052,052	;0200..0209
	dc.b		051,051,051,050,050,050,049,049,049,048	;0210..0219
	dc.b		048,048,047,047,047,046,046,046,046,045	;0220..0229
	dc.b		045,045,044,044,044,043,043,043,043,042	;0230..0239
	dc.b		042,042,041,041,041,041,040,040,040,039	;0240..0249
	dc.b		039,039,039,038,038,038,038,037,037,037	;0250..0259
	dc.b		036,036,036,036,035,035,035,035,034,034	;0260..0269
	dc.b		034,034,033,033,033,033,032,032,032,032	;0270..0279
	dc.b		031,031,031,031,030,030,030,030,029,029	;0280..0289
	dc.b		029,029,028,028,028,028,027,027,027,027	;0290..0299
	dc.b		027,026,026,026,026,025,025,025,025,024	;0300..0309
	dc.b		024,024,024,024,023,023,023,023,022,022	;0310..0319
	dc.b		022,022,022,021,021,021,021,021,020,020	;0320..0329
	dc.b		020,020,020,019,019,019,019,018,018,018	;0330..0339
	dc.b		018,018,017,017,017,017,017,016,016,016	;0340..0349
	dc.b		016,016,015,015,015,015,015,014,014,014	;0350..0359
	dc.b		014,014,014,013,013,013,013,013		;0360..0367
;
	dcb.b		5,12	;368..372
	dcb.b		6,11	;373..378
	dcb.b		5,10	;379..383
	dcb.b		6,9	;384..389
	dcb.b		5,8	;390..394
	dcb.b		6,7	;395..400
	dcb.b		6,6	;401..406
	dcb.b		6,5	;407..412
	dcb.b		6,4	;413..418
	dcb.b		6,3	;419..424
	dcb.b		6,2	;425..430
	dcb.b		6,1	;431..436
	dcb.b		7,0	;437..443
;
	dcb.b		6,-1	;444
	dcb.b		7,-2	;450
	dcb.b		6,-3	;457
	dcb.b		7,-4	;463
	dcb.b		7,-5	;470
	dcb.b		7,-6	;477
	dcb.b		7,-7	;484
	dcb.b		7,-8	;491
;
	dcb.b		7,-9	;498
	dcb.b		8,-10	;505
	dcb.b		7,-11	;513
	dcb.b		8,-12	;520
	dcb.b		7,-13	;527
	dcb.b		8,-14	;535
	dcb.b		8,-15	;543
	dcb.b		8,-16	;551
;
	dcb.b		8,-17	;559
	dcb.b		8,-18	;567
	dcb.b		9,-19	;575
	dcb.b		8,-20	;584
	dcb.b		9,-21	;592
	dcb.b		8,-22	;601
	dcb.b		9,-23	;609
	dcb.b		9,-24	;618
;
	dcb.b		9,-25	;627
	dcb.b		10,-26	;636
	dcb.b		9,-27	;646
	dcb.b		10,-28	;655
	dcb.b		9,-29	;665
	dcb.b		10,-30	;674
	dcb.b		10,-31	;684
	dcb.b		10,-32	;694
;
	dcb.b		10,-33	;704
	dcb.b		11,-34	;714
	dcb.b		10,-35	;725
	dcb.b		11,-36	;735
	dcb.b		11,-37	;746
	dcb.b		11,-38	;757
	dcb.b		11,-39	;768
	dcb.b		11,-40	;779
;
	dcb.b		12,-41	;790
	dcb.b		11,-42	;802
	dcb.b		12,-43	;813
	dcb.b		12,-44	;825
	dcb.b		12,-45	;837
	dcb.b		13,-46	;849
	dcb.b		12,-47	;862
	dcb.b		13,-48	;874..887
;
	dcb.b		13,-49	;887
	dcb.b		13,-50	;900
	dcb.b		13,-51	;913
	dcb.b		14,-52	;926
	dcb.b		13,-53	;940
	dcb.b		14,-54	;953
	dcb.b		14,-55	;967
	dcb.b		14,-56	;981
;
	dcb.b		15,-57	;995
	dcb.b		15,-58	;1010
	dcb.b		14,-59	;1025
	dcb.b		16,-60	;1039
	dcb.b		15,-61	;1055
	dcb.b		15,-62	;1070
	dcb.b		16,-63	;1085
	dcb.b		16,-64	;1101
;
	dcb.b		17,-65	;1117
	dcb.b		16,-66	;1134
	dcb.b		17,-67	;1150
	dcb.b		17,-68	;1167
	dcb.b		17,-69	;1184
	dcb.b		17,-70	;1201
	dcb.b		18,-71	;1218
	dcb.b		18,-72	;1236
;
	dcb.b		18,-73	;1254
	dcb.b		19,-74	;1272
	dcb.b		19,-75	;1291
	dcb.b		19,-76	;1310
	dcb.b		19,-77	;1329
	dcb.b		19,-78	;1348
	dcb.b		20,-79	;1367
	dcb.b		21,-80	;1387
;
	dcb.b		20,-81	;1408
	dcb.b		21,-82	;1428
	dcb.b		21,-83	;1449
	dcb.b		21,-84	;1470
	dcb.b		22,-85	;1491
	dcb.b		22,-86	;1513
	dcb.b		22,-87	;1535
	dcb.b		23,-88	;1557
;
	dcb.b		23,-89	;1580
	dcb.b		23,-90	;1603
	dcb.b		24,-91	;1626
	dcb.b		24,-92	;1650
	dcb.b		24,-93	;1674
	dcb.b		25,-94	;1698
	dcb.b		25,-95	;1723
	dcb.b		25,-96	;1748..1772
;
	dcb.b		26,-97	;1773
	dcb.b		26,-98	;1799
	dcb.b		27,-99	;1825
	dcb.b		27,-100	;1852
	dcb.b		27,-101	;1879
	dcb.b		28,-102	;1906
	dcb.b		28,-103	;1934
	dcb.b		28,-104	;1962
;
	dcb.b		29,-105	;1990
	dcb.b		30,-106	;2019
	dcb.b		29,-107	;2049
	dcb.b		31,-108	;2078
	dcb.b		30,-109	;2109
	dcb.b		31,-110	;2139
	dcb.b		32,-111	;2170
	dcb.b		32,-112	;2202
;
	dcb.b		33,-113	;2234
	dcb.b		32,-114	;2267
	dcb.b		34,-115	;2299
	dcb.b		34,-116	;2333
	dcb.b		34,-117	;2367
	dcb.b		35,-118	;2401
	dcb.b		36,-119	;2436
	dcb.b		36,-120	;2472
;
	dcb.b		36,-121	;2508
	dcb.b		37,-122	;2544
	dcb.b		38,-123	;2581
	dcb.b		38,-124	;2619
	dcb.b		38,-125	;2657
	dcb.b		39,-126	;2695
	dcb.b		40,-127	;2734..2773
	dcb.b		41,-128	;2774..2815
.period_to_note_limit:
	dcb.b		4096-(.period_to_note_limit-period_to_note_t),-127
;----------------------------------------------------------------------------
;include separately assembled 'dspfix' utility routines
;-------------------------------------
dspfix_t:
	incbin	'dspfix\dspfix.bin'
;----------------------------------------------------------------------------
;	Include separately assembled DSP program
;-------------------------------------
DSP_Code:
	IncBin	'TRACKER.P56'
DSP_End:
	Even
;----------------------------------------------------------------------------
;End of file:	TRACKER.S
;----------------------------------------------------------------------------
