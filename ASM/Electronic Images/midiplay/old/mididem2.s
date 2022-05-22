; 32 Voice .MID File player, (C) 1994 Martin Griffiths 

		OPT	D+,O+,OW-

		OUTPUT	D:\MIDIPL15.TTP

MAX_TRACKS	EQU	32		; Maximum number of MIDI tracks
midi_record	EQU 	0
padding_size	EQU	16384		
timing		EQU	1
gm_offset	EQU	0
gm_no_insts	EQU	15

		IFNE	midi_record
no_channels	EQU	16		; No. of Voices
pre_div		EQU 	1			; pre divider(frequency)
TIMER_A_VAL	EQU	61
TICKS_PER_INT	EQU	(1000000*200)/(2457600/TIMER_A_VAL)
		ELSEIF
no_channels	EQU	24		; No. of Voices
pre_div		EQU 	3		; pre divider(frequency)
TIMER_A_VAL	EQU	61*2
TICKS_PER_INT	EQU	(1000000*200)/(2457600/TIMER_A_VAL)
		ENDC

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

; Various structures

; Patch data header.

		RSRESET
wavename	RS.B	7
fractions	RS.B	1
wave_size	RS.L	1
start_loop	RS.L	1
end_loop	RS.L	1
sample_rate	RS.W	1
low_freq	RS.L	1
high_freq	RS.L	1
root_freq	RS.L	1
tune		RS.W	1
balance		RS.B	1
env_rate	RS.B	6
env_offset	RS.B	6
tremolo		RS.B	3
vibrato		RS.B	3
modes		RS.B	1
scale_freq	RS.W	1
scale_factor	RS.W	1
pdata_reserverd	RS.B	36

; 'Modes' bit flags.

bits8_16_flag	EQU	0		; bit 0 = 8 or 16 bit wave data. 
signed___flag	EQU	1		; bit 1 = Signed - Unsigned data. 
looped___flag	EQU	2		; bit 2 = looping enabled-1. 
bilooped_flag	EQU	3		; bit 3 = Set is bidirectional looping. 
bwlooped_flag	EQU	4		; bit 4 = Set is looping backward. 
sustain__flag	EQU	5		; bit 5 = Turn sustaining on. (Env. pts. 3)
envelope_flag	EQU	6		; bit 6 = Enable envelopes - 1
fast_rel_flag	EQU	7

; Track sequencer structure.

		RSRESET
Mtrk_curr_ptr	RS.L	1
Mtrk_event_end	RS.L	1
Mtrk_delta_time	RS.L	1
Mtrk_finished	RS.L	1
Mtrk_Running_st	RS.W	1
Mtrk_structsize	RS.B	0	

; Patch information structure

		RSRESET
Ptch_UsedFlag	RS.B	1
Ptch_NoSamples	RS.B	1
Ptch_StereoOffy	RS.B	1
Ptch_has_loop	RS.B	1
Ptch_address	RS.L	1
Ptch_structsize	RS.B	0

; Voice Structure 


		RSRESET
assoc_age	RS.L 1
assoc_inst_no	RS.B 1
assoc_chan_no	RS.B 1
voice_used	RS.B 1
sustain_flag	RS.B 1
sample_rate_ratio RS.L 1
cur_patchstart	RS.L 1
cur_foundper	RS.L 1
cur_pos		RS.L 1
cur_ramp_vol	RS.L 1
cur_lpstart	RS.L 1
cur_lpend	RS.L 1
cur_intfrac	RS.L 1
cur_orgfrac	RS.L 1
cur_period	RS.W 1
cur_env_offset	RS.W 1
int		RS.W 1
frac		RS.W 1
note_vol	RS.W 1
sam_vcsize	RS.B 0			; structure size.

; Midi Channel structure

		RSRESET
channel_used	RS.B	1
channel_inst	RS.B	1
channel_bend	RS.W	1
channel_ss	RS.B	0

convert_word	macro
		move.W	\1,d0		
		ror.w	#8,d0
		move.w	d0,\1
		endm

convert_long	macro
		move.l	\1,d0		
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
		move.l	d0,\1
		endm

read_midi_byte	macro
		movem.l	d1-d3/a0-a3,-(sp)		
		move.w	#3,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp
		movem.l	(sp)+,d1-d3/a0-a3
		move.B	d0,\1
		endm


start		CLR.L	-(SP)
		MOVE.W	#$20,-(SP)
		TRAP	#1
		ADDQ.L	#6,SP
		MOVE 	#3,-(SP)
		TRAP 	#14
		ADDQ.L 	#2,SP
		MOVE.L 	D0,log_base		
		BSR 	dsp_init
		
		IFNE	midi_record
		BSR	flush_midi
i		set 	gm_offset
		rept	gm_no_insts
		ST.B	Ptch_UsedFlag+(PatchLIST+Ptch_structsize*i)	
i		set 	i+1
		endr
		ELSEIF

		LEA	PatchLIST(PC),a5
		LEA	convtab(PC),A6
i		set 	0
		rept	16
		MOVEQ	#0,D0
		MOVE.B	(a6)+,d0
		MOVE.B	d0,channels_info+(i*4)+channel_inst
		MULU	#Ptch_structsize,D0
		ST.B	Ptch_UsedFlag(A5,d0)	
i		set 	i+1
		endr

		LEA	music_data,A0
		BSR	init_midi
		BSR	print_tune_info
		ENDC

		BSR 	init_instruments
		BSR	Save_Sound
		BSR 	Start_music 

		move.w	#2,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp		

		BSR	Stop_music 
		BSR 	Restore_Sound

		BSR 	dsp_deinit
		CLR	-(SP)
		TRAP 	#1

convtab		dc.b	0,0,0,0
		dc.b	0,0,0,0
		dc.b	0,0,0,0
		dc.b	0,0,0,0

; Initialise midi file stuff
; -> A0 midi file.

init_midi	LEA 	Mtrk_structs,A1
		MOVE.L	(A0)+,D0
		CMP.L	#'MThd',D0		; Chunk type
		BNE	.wrongfiletype
		MOVE.L	(A0)+,D0		; Chunk length (6)
		MOVE.W	(A0),D1			; FORMAT
		MOVE.W	D1,format
		MOVE.W	2(A0),D7		; NTRKS
		MOVE.W	D7,ntrks
		MOVE.W	4(A0),D1		; DIVISION
		MOVE.W	D1,division		; (specifies meaning of delta-times)
		BTST	#15,D1			
		BNE	.wrongfiletype	
		AND.L	#$7FFF,D1		; bits 0-14 represent 'ticks' per quarter note
		MOVE.L	D1,ticks_per_quarter_note
		ADD.L 	D0,A0
.init_track_lp	MOVE.L	(A0)+,D0		; Chunk type
		CMP.L	#'MTrk',D0
		BNE	.noMTrk
		MOVE.L	(A0)+,D0		; MTrk chunk length
		LEA.L	(A0,D0.L),A2
		BSR	read_vari_len		; read first delta-time
		MOVE.L	A0,Mtrk_curr_ptr(A1)
		MOVE.L	A2,Mtrk_event_end(A1)
		MULU.L	#192,D0
		MOVE.L	D0,Mtrk_delta_time(A1)
		CLR.W	Mtrk_Running_st(A1)
		SF.B	Mtrk_finished(A1)
		LEA 	Mtrk_structsize(A1),A1
		MOVE.L	A2,A0
		SUBQ	#1,D7
		BNE.S	.init_track_lp
		BSR	scan_midi
		LEA	ch1s(PC),A1
		MOVEQ 	#no_channels-1,D0
.ok		SF.B	voice_used(a1)
		lea	sam_vcsize(a1),a1
		DBF	D0,.ok
		clr.l	age_counter
		RTS

.wrongfiletype	
.noMTrk		ILLEGAL
age_counter	DC.L	0

;--------------------------------

; Scan midi data.

scan_midi	LEA 	Mtrk_structs(PC),A1
		LEA	channels_info(PC),A2
		LEA	PatchLIST(PC),A3
		MOVE.W	ntrks(PC),D7
.scan_trackslp	MOVE.L	Mtrk_curr_ptr(A1),A0
.scan_lp	MOVE.B 	(A0),D0
		BGE.S	.scan_event
		ADDQ.L	#1,A0
		CMP.B	#$F0,D0
		BEQ	.scan_sysex_event
		CMP.B	#$F7,D0
		BNE.S	.noscan_sysex_event
.scan_sysex_event
		BSR	read_vari_len		; read sysex event length
		ADD.L	D0,A0			; just skip it
		CLR.W	Mtrk_Running_st(A1)	
		BRA.S	.next_event
.noscan_sysex_event
		CMP.B	#$FF,D0
		BNE.S	.noscan_meta_event
.scan_meta_event
		ADDQ.L	#1,A0				; skip meta event type
		BSR	read_vari_len			; read meta event length
		ADD.L 	D0,A0
		CLR.W	Mtrk_Running_st(A1)	
		BRA.S	.next_event
.noscan_meta_event
		CMP.B	#$C0,D0
		BLT.S	.not_program_change
		CMP.B	#$CF,D0
		BGT.S	.not_program_change
		MOVEQ	#0,D1
		MOVE.B	(A0),D1
		MULU	#ptch_structsize,D1
		ST.B	ptch_UsedFlag(A3,D1)

.not_program_change
		
		MOVE.W	D0,Mtrk_Running_st(A1)	
.scan_event	MOVE.W	Mtrk_Running_st(A1),D0
		MOVEQ	#$F,D1
		AND.B	D0,D1		; D1 = low nibble
		ST.B	channel_used(A2,D1*4)	; set channel used.
		LSR.B	#4,D0
		AND.W	#$F,D0
		ADD	.size(PC,D0*2),A0
.next_event	BSR	read_vari_len			; read delta-time
		CMP.L	Mtrk_event_end(A1),A0
		BLT.S	.scan_lp
		CLR.W	Mtrk_Running_st(A1)	
		LEA	Mtrk_structsize(A1),A1
		SUBQ	#1,D7
		BNE.S	.scan_trackslp
.done		RTS

.size		DC.W	0,0,0,0,0,0,0,0,2,2,2,2,1,1,2,0		


;--------------------------------

;
; The sequencer!
;

Sequence_midi	ADDQ.L	#1,age_counter
		LEA	channels_info(PC),A3
		LEA	PatchLIST(PC),A4
		LEA 	Mtrk_structs(PC),A6

		IFEQ	midi_record

		MOVE.W	ntrks(PC),D7
		SUBQ	#1,D7
SEQ_TRACK_LP	TST.B	Mtrk_finished(A6)
		BNE.S	SKIPTRACK			
		SUB.L	#TICKS_PER_INT,Mtrk_delta_time(A6)
		BGT.S	SKIPTRACK			
		MOVE.L	Mtrk_curr_ptr(A6),A0
process_lp	MOVEQ	#0,D0
		MOVE.B 	(A0)+,D0
		BGE.S	MIDI_EVENT

		ELSEIF

		move.w	#3,-(sp)
		move.w	#1,-(sp)
		trap	#13
		addq.l	#4,sp
		tst.l	d0
		beq	done
		move.w	#3,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp
		AND.L	#$FF,D0
		TST.B	D0
		BMI	NEW_RUNNING_ST
		BRA	MIDI_EVENT

		ENDC

NEW_RUNNING_ST	MOVE.W	D0,Mtrk_Running_st(A6)	
		IFEQ	midi_record
		CMP.B	#$F0,D0
		BEQ	handle_sysex_event
		CMP.B	#$F7,D0
		BEQ	handle_sysex_event
		CMP.B	#$FF,D0			
		BEQ	handle_meta_event
		MOVEQ	#0,D0
		MOVE.B	(A0)+,D0
		ELSEIF
		MOVEQ	#0,D0
		read_midi_byte d0
		ENDC
MIDI_EVENT	MOVE.L	D0,D2
		
		MOVE.W	Mtrk_Running_st(A6),D0
		MOVEQ	#$F,D1
		AND.B	D0,D1		; D1 = low nibble
		LSR.B	#4,D0
		AND.W	#$F,D0
		MOVE	midi_event_tab(PC,D0*2),D3
		JSR	midi_event_tab(PC,D3)

NEXT_EVENT	
		IFEQ	midi_record
		BSR	read_vari_len		; read delta-time
		MOVE.L  A0,Mtrk_curr_ptr(A6)
		MULU.L	TEMPO(PC),D0
		ADD.L   D0,Mtrk_delta_time(A6)
		CMP.L	#TICKS_PER_INT,Mtrk_delta_time(A6)
		BLT	process_lp
SKIPTRACK	LEA	Mtrk_structsize(A6),A6
		DBF	D7,SEQ_TRACK_LP
		ENDC

done		RTS

midi_event_tab	DC.W	NULL-midi_event_tab		;0
		DC.W	NULL-midi_event_tab		;1
		DC.W	NULL-midi_event_tab		;2
		DC.W	NULL-midi_event_tab		;3
		DC.W	NULL-midi_event_tab		;4
		DC.W	NULL-midi_event_tab		;5
		DC.W	NULL-midi_event_tab		;6
		DC.W	NULL-midi_event_tab		;7
		DC.W	Note_Off-midi_event_tab		;8
		DC.W	Note_On-midi_event_tab		;9
		DC.W	Key_After_Touch-midi_event_tab	;10
		DC.W	Control_Change-midi_event_tab	;11
		DC.W	Program_Change-midi_event_tab	;12
		DC.W	Channel_After_Touch-midi_event_tab	;13
		DC.W	PitchBend-midi_event_tab	;14
		DC.W	NULL-midi_event_tab		;15

NULL		ADDQ.L	#1,A0	
		RTS

; $8 (Note Off)

Note_Off	MOVEQ	#0,D3
		IFEQ	midi_record
		MOVE.B	(a0)+,D3
		ELSEIF
		read_midi_byte d3
		ENDC
		MOVE.B	channel_inst(a3,D1*4),D6
		LEA	ch1s(pc),a5
		moveq	#(no_channels-1),d4
.find_lp1	tst.b	voice_used(a5)
		beq.s	.next
		cmp.b	assoc_inst_no(a5),d6
		bne.s	.next
		CMP.W 	cur_period(a5),D2
		BEQ.S	do_note_off
.next		LEA	sam_vcsize(A5),A5
		DBF	D4,.find_lp1
		RTS
do_note_off	SF.B	sustain_flag(a5)
		RTS

; $9 (Note ON)

env_max		EQU	5

Note_On		MOVEQ	#0,D3
		IFEQ	midi_record
		MOVE.B	(a0)+,D3
		ELSEIF
		read_midi_byte d3
		ENDC			; d2 = sam period d3 = sam volume
		CLR	D6
		MOVE.B	channel_inst(a3,D1*4),D6
		LEA	ch1s(pc),a5
		moveq	#(no_channels-1),d4
.find_lp1	tst.b	voice_used(a5)
		beq.s	.next
		cmp.b	assoc_inst_no(a5),d6
		bne.s	 .next
		CMP.W	cur_period(a5),d2
		BEQ	.justvol
.next		LEA	sam_vcsize(A5),A5
		DBF	D4,.find_lp1

.precheck	
		LEA	ch1s(pc),a5
		moveq	#(no_channels-1),d4
.lp2		tst.b	voice_used(a5)
		beq.s	.next2
		cmp.b	assoc_inst_no(a5),d6
		bne.s	 .next2
		cmp.w	#2,cur_env_offset(a5)
		blt.s	.next2
		cmp.l	#4000,cur_ramp_vol(a5)
		blt.s	.okfoundvoice
.next2		LEA	sam_vcsize(A5),A5
 		DBF	D4,.lp2
		
		
		move.w	curr_voice(pc),d5
		move.w	d5,d4
		addq	#1,d5
		cmp.w	#no_channels,d5
		bne.s	.ok1
		clr	d5
.ok1		move.w	d5,curr_voice
		LEA	ch1s(pc),a5
		mulu	#sam_vcsize,d4
		add.w	d4,a5
.okfoundvoice	st.b	voice_used(a5)
		move.b	d1,assoc_chan_no(a5)
		move.b	d6,assoc_inst_no(a5)
		cmp.b	#49,d6
		bne.s	.zap
		lsr.w	#2,d3
.zap
		MOVE	D2,cur_period(a5)
		MOVE	D3,note_vol(a5)
		MOVE.L	age_counter(PC),assoc_age(a5)
		mulu	#ptch_structsize,d6
		MOVE.B	Ptch_NoSamples(a4,D6),d5
		move.l	Ptch_address(a4,D6),a2
		move.W	scale_freq(a2),d4
		sub.w	d4,d2
		ext.l	d4
		asl.l	#8,d4
		asl.l	#2,d4
		muls	scale_factor(a2),d2
		ADD.L	D2,D4
		LEA	octave_table(PC),A1
		MOVE.L	(A1,d4.l*4),D3
		MOVE.L	A2,A1
.find_lp	CMP.L	high_freq(A1),D3
		BHI.S	.notquite
		CMP.L	low_freq(A1),D3
		BLO.S	.notquite
		MOVE.L	A1,A2
.notquite	SUBQ.B	#1,D5
		BEQ.S	.done
		MOVE.L	wave_size(a1),d0	; sample length
		LEA.L	(padding_size+96,A1,D0.L),A1
		BRA.S	.find_lp

.done		MOVE.L	D3,cur_foundper(a5)
		MOVE.L	A2,cur_patchstart(A5)
		move.l	start_loop(a2),d0
		LEA.L	96(A2,D0.L),A1
		MOVE.L	A1,cur_lpstart(A5)
		move.l	end_loop(a2),d0
		LEA.L	96(A2,D0.L),A1
		MOVE.L	A1,cur_lpend(A5)
		LEA	96(a2),a1
		MOVE.L	A1,cur_pos(A5)

		moveq	#0,d3
		move.w	sample_rate(a2),d3
		swap	d3
		divu.l	#freq,d3
		lsl.l	#8,d3
		move.l	d3,sample_rate_ratio(a5)
		CLR.W	cur_env_offset(a5)
		btst.b	#sustain__flag,modes(a2)
		sne.b	sustain_flag(a5)
.doneit		RTS

.justvol	TST.W	D3
		BNE	.okfoundvoice		; zero vol?
		bra	do_note_off
		IFNE	midi_record
tabby		DC.W	512*18,64*18,8*18,1*18
		ELSEIF
tabby		DC.W	512*18*2,64*18*2,8*18*2,1*18*2
		ENDC

curr_voice	dc.w	0


; $A ((Key After Touch)

Key_After_Touch
		IFEQ	midi_record
		ADDQ.L	#1,A0
		ELSEIF
		read_midi_byte	d0
		ENDC
		RTS

; $B Control		

Control_Change
		IFEQ	midi_record
		ADDQ.L	#1,A0
		ELSEIF
		read_midi_byte	d0
		ENDC
		RTS
		

; $C (PROGRAM (Patch) Change)

Program_Change	
		IFNE	midi_record		
		ADD.B	#gm_offset,D2
		ENDC
		MOVE.B	D2,channel_inst(A3,D1*4)	; store patch no. in channel info.
		RTS

; $D (PROGRAM (Patch) Change)

Channel_After_Touch	
		RTS


; $E (Pitchbend)

PitchBend	;CLR	D0
		IFEQ	midi_record
		MOVE.B	(A0)+,D0
		ELSEIF
		read_midi_byte	d0
		ENDC
		;and.w	#$ff,d0
		;LSL.W	#7,D2
		;OR.W	D0,D2
		;MOVE.W	D2,channel_bend(A3,D1*4)	
		;move.w	d2,d0
		;bsr	num_print

		RTS
		

handle_sysex_event
		BSR	read_vari_len		; read sysex event length
		ADD.L	D0,A0			; just skip it
		CLR.W	Mtrk_Running_st(A6)	
		BRA	NEXT_EVENT
				
handle_meta_event
		MOVE.B	(A0)+,D0		; meta event type
		cmp.b   #$51,d0
		bne     .nosettempo
.set_tempo	MOVE.L	(A0),D1
		and.l	#$ffffff,d1	 		; (24-bit tempo - microseconds/quarternote)
		DIVU.L	ticks_per_quarter_note(PC),D1
		move.L  D1,TEMPO			; (d1 = clocks.10^-4/tick)
		BRA.S	.cont
.nosettempo	CMP.B	#$2F,D0
		BNE.S	.not_track_end
		ST.B	Mtrk_finished(A6)
.not_track_end
.cont		BSR	read_vari_len			; read meta event length
		ADD.L 	D0,A0
		CLR.W	Mtrk_Running_st(A6)	
		BRA	NEXT_EVENT


q_vari_read	macro
		MOVEQ	#0,D0
	  	move.b  (a0)+,d0
		bge.s	.out\@
.lp\@		move.b	(a0)+,d1
		bge.s	.out\@
		and.b   #$7f,d1
		lsl.l	#7,d0
		or.b	d1,d0
		bra.s	.lp\@
.out\@
		endm


; Read a variable length number.
; -> A0.
; returns number in d0.

read_vari_len:	MOVEQ	#0,D0
.vloop  	lsl.l   #7,d0
		move.b  (a0)+,d1
		and.b   #$7f,d1
		add.b   d1,d0
		btst.b  #7,-1(a0)
		bne     .vloop
		rts


format		DC.W 0
ntrks		DC.W 0
division	DC.W 0
ticks_per_quarter_note
		DC.L 0
	
;------------------------------------------------------------------------------------------

; The Player.


wait_flag	EQU 0			; wait for dsp to finish flag.
freq		EQU ((25175000)/(pre_div+1))/256

Save_Sound	LEA old_stuff(PC),A0
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.L $134.W,(a0)+
		MOVE.W $ffff8900.W,(A0)+
		MOVE.W $ffff8920.W,(A0)+
		MOVE.L $ffff8930.W,(A0)+
		MOVE.W $ffff8934.W,(A0)+
		MOVE.W $ffff8936.W,(A0)+
		MOVE.W $ffff8938.W,(A0)+
		MOVE.W $ffff893A.W,(A0)+
		MOVE.B $fffffa19.W,(A0)+
		MOVE.B $fffffa1f.W,(A0)+
		MOVE.W (SP)+,SR
		RTS

Restore_Sound	LEA old_stuff(PC),A0
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.L (a0)+,$134.W
		MOVE.W (a0)+,$ffff8900.W
		MOVE.W (a0)+,$ffff8920.W
		MOVE.L (a0)+,$ffff8930.W
		MOVE.W (a0)+,$ffff8934.W
		MOVE.W (a0)+,$ffff8936.W
		MOVE.W (a0)+,$ffff8938.W
		MOVE.W (a0)+,$ffff893A.W
		MOVE.B (a0)+,$fffffa19.W
		MOVE.B (a0)+,$fffffa1f.W
		MOVE.W (SP)+,SR
		RTS

Start_music	
		MOVE.B #0,$FFFFFA19.W
                MOVE #%1000000110011001,$FFFF8930.w	; dma output 25mhz clock,no handshake
                MOVE #%1011100100011101,$FFFF8932.w	; dsp out -> dac
                MOVE #64,$FFFF8920.w 		; 16 bit stereo,50khz,play 1 track,dac to track 1
		move.b  #pre_div,$FFFF8935.w  	;49.2khz
                move.b  #2,$FFFF8937.w		;CODEC <- Multiplexor
                move.b  #3,$FFFF8938.w		;L+R <- Soundchip(NOT ADC!)
		MOVE.W SR,d7
		ori.w #$700,SR
		MOVE.L #music_int,$134.W
		BSET.B #5,$FFFFFA07.W		;iera
		BSET.B #5,$FFFFFA13.W		;imra
		MOVE.W d7,SR
.sync1		BTST.B #0,$FFFFA202.W
		BEQ.S .sync1
		MOVE.L $FFFFA204.W,d0		
.sync2		BTST.B #0,$FFFFA202.W
		BEQ.S .sync2
		MOVE.L $FFFFA204.W,d1	
		MOVE.B #19,$FFFFA201.W		; host command 2
		MOVE.B #TIMER_A_VAL,$FFFFFA1F.W
		MOVE.B #7,$FFFFFA19.W		; timer a event mode.
		MOVE.B #TIMER_A_VAL,$FFFFFA1F.W
		RTS

Stop_music	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.B #0,$FFFFFA19.W		; STOP INT
		MOVE.W #0,$FFFF8900.W		; STOP DMA
		BCLR.B #5,$FFFFFA07.W		; iera
		BCLR.B #5,$FFFFFA13.W		; iera
		MOVE.W (SP)+,SR
		RTS


music_int	BCLR #5,$fffffa0f.w		
		TAS.B player_sem
		BNE .out
		BSET.B	#7,$ffffa201.w
		IFNE	timing
		NOT.L $ffff9800.w
		ENDC
		MOVE.W #$2500,SR
		MOVEM.L	D0-D7/A0-A6,-(A7)
.waitdspexcp	BTST #7,$FFFFA201.w
		BNE.S .waitdspexcp		
		;move.l	#ENABLE_CACHE,d0
		;movec.l	d0,CACR
		LEA $ffffa206.w,a6
.waitsem1	MOVE.B	-4(a6),d0
		AND.B	#$18,d0
		CMP.B	#$18,d0		; wait for host flag bits to be set.
		BNE.S	.waitsem1
.wait7		BTST.B #1,-4(A6)
		BEQ.S .wait7
		MOVE.L interpolate_flag(pc),$FFFFA204.W	; signal dsp to go!
.wait8		BTST.B #1,-4(A6)
		BEQ.S .wait8
		MOVE.L #no_channels,$FFFFA204.W


		LEA	ch1s(pc),a1
		moveq	#0,d6
		moveq	#(no_channels-1),d7
.find_lp1	tst.b	voice_used(a1)
		beq.s	.next
		MOVE.L	cur_patchstart(A1),a2
		move.l	cur_foundper(A1),d5
		mulu.l	sample_rate_ratio(A1),d4:d5
		divu.l	root_freq(a2),d4:d5
		move.l	d5,cur_intfrac(a1)		
		move.l	d5,cur_orgfrac(a1)
		lsr.l	#8,d5
		add.l	d5,d6
		move.l	#$10000,int(a1)
.next		LEA	sam_vcsize(A1),A1
		DBF	D7,.find_lp1
		cmp.l	#$80000,d6
		blo	.SEND
		move.l	d6,d0

		LEA	ch1s(pc),a1
		moveq	#(no_channels-1),d7
		moveq	#0,d1
.fix_lp		tst.b	voice_used(a1)
		beq.s	.next3
		move.l	cur_intfrac(a1),d2
		lsr.l	#8,d2
		sub.l	d6,d2
		neg.l	d2
		move.l	d6,d4
		mulu.l	#$10000,d3:d4
		divu.l	d2,d3:d4
		move.l	d4,int(a1)
		move.l	cur_intfrac(a1),d3
		mulu.l	#$10000,d5:d3
		divu.l	d4,d5:d3
		move.l	d3,cur_intfrac(a1)
		lsr.l	#8,d3
		add.l	d3,d1
.next3		LEA	sam_vcsize(A1),A1
		DBF	D7,.fix_lp
		mulu.l	#$10000,d0:d1
		divu.l	#$80000,d0:d1
		LEA	ch1s(pc),a1
		moveq	#(no_channels-1),d7
.fix_lp2	tst.b	voice_used(a1)
		beq.s	.next4
		move.l	int(a1),d3
		mulu.l	d1,d2:d3
		divu.l	#$10000,d2:d3
		cmp.w	#$8000,d3
		bls.s	.zapo
		add.l	#$10000,d3
.zapo		clr.w	d3
		move.l	d3,int(a1)

		move.l	cur_orgfrac(a1),d4
		mulu.l 	#$10000,d5:d4
		divu.l	d3,d5:d4
		move.l	d4,cur_intfrac(a1)
.next4		LEA	sam_vcsize(A1),A1
		DBF	D7,.fix_lp2


.SEND		LEA 	ch1s(PC),A1
		lea	vol_conv_tab,a5
		MOVEQ	#no_channels-1,D7
.lp2		BSR.S 	send_voice
		LEA	sam_vcsize(A1),A1
		DBF	D7,.lp2

		IFNE wait_flag
.waitsem2	MOVE.B	-4(a6),d0
		AND.B	#$18,d0
		BNE.S	.waitsem2
		ENDC
		BSR	Sequence_midi	
		MOVEM.L	(A7)+,D0-D7/A0-A6
		IFNE	timing
		NOT.L	$ffff9800.w
		ENDC
		SF player_sem
.out		RTE

RTS


; Send 1 voice to the dsp.

send_voice	
		TST.B	voice_used(A1)
		bne.s	ison
.waitf		BTST #1,-4(A6)			;;;
		BEQ.S .waitf			; send 
		MOVE.L #0,-2(A6)		 
		RTS
ison		MOVE.L	cur_patchstart(A1),a2
		MOVE.L	cur_ramp_vol(A1),D0
		MOVE.W	cur_env_offset(A1),D2
		TST.B	sustain_flag(a1)
		BEQ.S	.no_suss
		CMP	#3,D2
		beq.s	.nah
.no_suss
		MOVE.B	env_rate(A2,d2),D4
		MOVEQ	#0,D3
		MOVE.B	env_offset(A2,D2),D3
		LSL.W	#8,D3

		MOVE.B	D4,D5
		AND.W	#%00111111,D4
		AND.W	#%11000000,D5
		LSR.W	#6,d5
		LEA.L	tabby(PC),A3
		MULU	(A3,D5*2),D4
		MOVE.L	D0,D6
		SUB.L	D3,D6
		BMI.S	.up
.down		CMP.L	D6,D4
		BHS.S	.do_check
		SUB.L	D4,D0
		BRA.S	.nah
.up		NEG.L	D6
		CMP.L	D6,D4
		BHS.S	.do_check
		ADD.L	D4,D0
		BRA.S	.nah
.do_check	MOVE.L	D3,D0
		CMP	#5,D2
		SNE.B	voice_used(A1)
		ADDQ	#1,d2
.nah		MOVE.W	D2,cur_env_offset(A1)
		MOVE.L	D0,cur_ramp_vol(A1)

.waitf		BTST #1,-4(A6)			;;;
		BEQ.S .waitf			; send 
		MOVE.L #1,-2(A6)	
		MOVEQ #1,D5
		AND.B	assoc_chan_no(a1),d5
.waits		BTST #1,-4(A6)			;;;
		BEQ.S .waits			; send 
		MOVE.L D5,-2(a6)	;;;
		lsr.w	#4,d0
		move.l	(a5,d0*4),d0
		MULU	note_vol(A1),D0		; 0..128
		LSR.L	#1,D0			;
		move.l	cur_intfrac(a1),d5	
		move.l	d5,d3
		rol.l	#8,d5
		and.l	#$ff,d5
		and.l	#$ffffff,d3

.wait0		BTST #1,-4(A6)			;;;
		BEQ.S .wait0			; send 
		MOVE.L D5,-2(a6)	;;;
.wait1		BTST #1,-4(A6)			;;;
		BEQ.S .wait1			; send 
		MOVE.L D3,-2(a6)	;;;
.wait2		BTST #1,-4(A6)			;;;
		BEQ.S .wait2		; send volume 
		MOVE.L D0,-2(A6)		;;; 
.wait3		BTST #0,-4(A6)			; 
		BEQ.S .wait3			; 
		MOVE.W (A6),D6			; get no. of samples
.wait4		BTST #1,-4(A6)			; 
		BEQ.S .wait4			; 
		move.b #0,-1(a6)		; clear top 8 msbits
		MOVE.L cur_pos(A1),A0		; current voice address
do_vce		
		moveq	#15,d5
		and.w	D6,d5
		neg	d5
		lsr.w	#4,D6
		MOVE.w	int(a1),D3
		add.w	d3,d3
		subq	#2,d3
		JMP	.madecont(pc,d5*4)
.madeuploop	
		REPT	16
		MOVE.W (A0)+,(A6)
		add.w	d3,a0
		ENDR
.madecont	DBF D6,.madeuploop
		MOVE.L cur_lpend(A1),D2
		MOVE.W (A0),(A6)

		CMP.L D2,A0
		BLT.S .notover
		SUB.L D2,A0			; over-run
		MOVE.L	A0,D0
		SUB.L cur_lpstart(A1),D2	; size of loop
		CMP.L	D2,D0
		BLE.S	.sing
		DIVUL.L	D2,D3:D0
		MOVE.L	D3,D0	
.sing		MOVE.L	cur_lpstart(A1),A0
		ADD.L	D0,A0
.notover	MOVE.L A0,cur_pos(A1)	; store new address
		RTS

; Reset DSP, and load boot.

dsp_init	move	sr,-(a7)
		move.w	#$2700,sr
		move.b	#$E,$FFFF8800.w
		move.b	$FFFF8800.w,d0
		or.b	#$10,d0
		move.b	d0,$FFFF8802.w
		rept 8
		nop
		endr
		and.b	#$EF,d0
		move.b	d0,$FFFF8802.w
		move.w	(a7)+,sr
		LEA DspProg(PC),A0
		move.w #512-1,d0
.lp		move.b (a0)+,$FFFFA205.w
		move.w (a0)+,$FFFFA206.w
		dbf d0,.lp
		move.b	#0,$FFFFA200.w
		rts

dsp_deinit	
		;move.w	#105,-(sp)
		;trap	#14
		;addq.l	#2,sp
		rts


init_instruments:
		LEA	buffer,A5
		LEA	PatchLIST(PC),A6
		MOVEQ	#0,d7
.lp		TST.B	Ptch_UsedFlag(A6)
		BEQ	.not
		move.b	flag(pc),Ptch_StereoOffy(A6)
		eor.b	#1,flag
		LEA	Instrument_List(PC),A3
		MOVE.L	(A3,d7*4),A0
		LEA	filename(PC),A4
.cpy		MOVE.B	(A0)+,D0
		MOVE.B	D0,(A4)+
		TST.B	D0
		BNE.S	.cpy
		SUBQ.L	#1,A4
		MOVE.L	#'.PAT',(A4)+
		CLR.B	(A4)+
		LEA	path(PC),A0
		BSR	print
		BSR	print_newline
		LEA	path(PC),A4
		BSR	open_file
		PEA	(A5)
		LEA	headerbuf,A5
		MOVE.L	#239,D6
		BSR	read_file
		MOVE.L	(SP)+,A5
		move.b	headerbuf+198,d4
		MOVE.B	D4,Ptch_NoSamples(A6)
		MOVE.L	A5,Ptch_address(A6)
.sam_lp		MOVEQ	#96,D6
		BSR	read_file
		convert_word	scale_freq(a5)
		convert_word	scale_factor(a5)
		convert_word	sample_rate(a5)
		convert_long	low_freq(a5)
		convert_long	high_freq(a5)
		convert_long	root_freq(a5)
		convert_long	start_loop(a5)
		convert_long	end_loop(a5)
		convert_long	wave_size(a5)
		move.b	modes(a5),d3
		move.l	start_loop(a5),a1
		move.l	end_loop(a5),a2
		move.l	a2,wave_size(a5)
		lea	96(a5),a5
		add.l	a5,a1
		add.l	a5,a2
		move.l	d0,D6
		bsr	read_file
		move.l	wave_size-96(a5),d0
.signlp		move.w	(a5),d1
		ror.w	#8,d1
		eor.w	#$8000,d1
		move.w	d1,(a5)+
		subq.l	#2,D0
		bne.s	.signlp
		move.l	#padding_size,d0
		btst	#looped___flag,d3
		beq.s	.no_loop

		move.l	a1,a3
.lp1		move.w	(a3)+,(a5)+
		cmp.l	a2,a3
		bne.s	.nl
		move.l	a1,a3
.nl		subq.l	#2,D0
		bne.s	.lp1
		
		bra.s	.cont

.no_loop 	
.lp2		move.w	#$0000,(a5)+
		subq.l	#2,D0
		bne.s	.lp2
.cont		
		;btst	#1,d1
		;beq	loaderror
		;btst	#0,d1
		;beq	loaderror
		subq.b	#1,d4
		bne	.sam_lp
		move.l	a5,d5
		add.l	#16,d5
		and.b	#$f0,d5
		move.l	d5,a5	
		bsr	close_file
.not		LEA	Ptch_structsize(A6),A6
		ADDQ	#1,d7
		CMP.W	#128,d7
		BNE	.lp
		rts

path		DC.B	"D:\GM1.SET\"
filename	DS.B	16
		EVEN


open_file	movem.l d0-d3/a0-a3,-(sp)
		MOVE #2,-(SP)
		MOVE.L A4,-(SP)
		MOVE #$3D,-(SP)
		TRAP #1				; open da file
		ADDQ.L #8,SP
		MOVE.W	D0,handle
		TST.W	D0
		BMI.S	loaderror
		movem.l (sp)+,d0-d3/a0-a3
		RTS

read_file	movem.l d0-d3/a0-a3,-(sp)
		MOVE.L A5,-(SP)			; address
		MOVE.L D6,-(SP)			; length
		MOVE handle(PC),-(SP)			' handle
		MOVE #$3F,-(SP)
		TRAP #1				; read da file
		LEA 12(SP),SP
		TST.L	D0
		BMI.S	loaderror
		CMP.L	D0,D6
		BNE.S	loaderror
		movem.l (sp)+,d0-d3/a0-a3
		RTS

close_file	movem.l d0-d3/a0-a3,-(sp)
		MOVE handle(PC),-(SP)
		MOVE #$3E,-(SP)
		TRAP #1				; close da file!
		ADDQ.L #4,SP
		movem.l (sp)+,d0-d3/a0-a3
		RTS
handle		DC.W	0

loaderror	ILLEGAL








;----------------------------------------------------------------

print_tune_info
		LEA	start_txt(PC),A0
		BSR	print
		MOVE.W	ntrks(PC),D0
		BSR	print_2digs
		BSR	print_newline
		LEA	chans_txt(PC),A0
		BSR	print
PRINT_CHANS_USED	
		LEA	channels_info(PC),A6
		MOVEQ	#0,D6
		MOVEQ	#0,D7
.lp		TST.B	(A6)
		BEQ.S	.not
		MOVE.L	D6,D0
		BSR	print_2digs
		ADDQ	#1,D7
.not		ADDQ.L	#2,A6
		ADDQ	#1,D6
		CMP.W	#16,D6
		BNE.S	.lp
		BSR	print_newline
PRINT_INSTS_USED	
		LEA	insts_txt(PC),A0
		BSR	print
		LEA	PatchLIST(PC),A6
		MOVEQ	#0,D6
.lp		TST.B	Ptch_UsedFlag(A6)
		BEQ.S	.not
		MOVE.L	D6,D0
		BSR	print_3digs
.not		LEA	Ptch_structsize(A6),A6
		ADDQ	#1,D6
		CMP.W	#128,D6
		BNE.S	.lp
		BSR	print_newline
		RTS


print_3digs	LEA	digit3(PC),A0
		MOVE.L	A0,A1
		DIVU	#100,D0
		MOVE.B	D0,D1
		ADD.B	#'0',D1
		MOVE.B	D1,(A1)+
		CLR	D0
		SWAP	D0
		BRA.S	cont_p2

print_2digs	LEA	digit(PC),A0
		MOVE.L	A0,A1
cont_p2		DIVU	#10,D0
		MOVE.B	D0,D1
		ADD.B	#'0',D1
		MOVE.B	D1,(A1)+
		SWAP 	D0
		ADD.B	#'0',D0
		MOVE.B	D0,(A1)+
		BRA	print

		DIVU	#10,D0
		MOVE.B	D0,D1
		ADD.B	#'0',D1
		MOVE.B	D1,(A1)+
		SWAP 	D0
		ADD.B	#'0',D0
		MOVE.B	D0,(A1)+
		BRA	print

start_txt	DC.B	27,"E"
		DC.B	"Midi Player v0.15",$a,$d
		DC.B	"-----------------",$a,$d
		DC.B  	"(C) July 1994 Martin Griffiths.",$a,$d,$a,$d 
		DC.B	"MIDI Tracks   : ",0
chans_txt	DC.B	"Channels Used : ",0
insts_txt	DC.B	"Patches Used  : ",0
digit		DC.B	0,0,' ',0
digit3		DC.B	0,0,0,' ',0
		EVEN
print_newline	LEA	newline(pc),a0

; Print Rout -> Text address in A0...  Uses TXPOS and TYPOS (.B)
; (not fast or anything but works nicely thank you!)

print:		pea (a0)
		move.w #9,-(sp)
		trap #1
		addq.l #6,sp
		rts
newline		dc.b	$a,$d,0,0

flush_midi	
.fl		move.w	#3,-(sp)
		move.w	#1,-(sp)
		trap	#13
		addq.l	#4,sp
		tst.l	d0
		beq	.done
		move.w	#3,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp
		bra.s	.fl
.done		rts

flag		dc.b	0
		even

;------------------------------------------------------------------------------------------

linewidth	equ	832/8

; Routine to print an unsigned word in decimal.D0.L contains the no.to be printed.

num_print	MOVEM.L	D0-D1/A0-A1,-(SP)
		MOVE.L log_base(PC),A0
		DIVUL.L #100000000,D1:D0
		BSR	digi_prin
		ADDQ.L #1,A0		
		MOVE.L	D1,D0
		DIVUL.L #10000000,D1:D0
		BSR	digi_prin
		ADDQ.L #1,A0		
		MOVE.L	D1,D0
		DIVUL.L #1000000,D1:D0
		BSR	digi_prin
		ADDQ.L #1,A0		
		MOVE.L	D1,D0
		DIVUL.L #100000,D1:D0
		BSR	digi_prin
		ADDQ.L #1,A0		
		MOVE.L	D1,D0
		DIVU.W	#10000,D0	 
		BSR.S	digi_prin
		ADDQ.L #1,A0		
		CLR D0			
		SWAP D0			
		DIVU #1000,D0 	   	
		BSR.S	digi_prin
		ADDQ.L #1,A0		
		CLR D0			
		SWAP D0			look at remainder
		DIVU #100,D0 	    	number of 100s
		BSR.S	digi_prin
		ADDQ.L #1,A0		next screen column
		CLR D0			prepare for divide
		SWAP D0			look at remainder
		DIVU #10,D0			number of 10s
		BSR.S	digi_prin
		ADDQ.L #1,A0		next screen column
		CLR D0	 		prepare for divide
		SWAP D0			always print units
		BSR.S	digi_prin
		MOVEM.L	(SP)+,D0-D1/A0-A1
		RTS

* Print a single digit at A0

digi_prin	LEA font_data(PC,D0*8),A1
i		set 4
		REPT 8	
		MOVE.B (A1)+,linewidth*i(A0)
i		SET i+1
		ENDR
		RTS

font_data	DC.B $7C,$C6,$C6,$00,$C6,$C6,$7C,$00	"O"
		DC.B $18,$18,$18,$00,$18,$18,$18,$00	"1"
		DC.B $7C,$06,$06,$7C,$C0,$C0,$7C,$00	"2"
		DC.B $7C,$06,$06,$7C,$06,$06,$7C,$00	"3"
		DC.B $C6,$C6,$C6,$7C,$06,$06,$06,$00	"4"
		DC.B $7C,$C0,$C0,$7C,$06,$06,$7C,$00	"5"
		DC.B $7C,$C0,$C0,$7C,$C6,$C6,$7C,$00	"6"
		DC.B $7C,$06,$06,$00,$06,$06,$06,$00	"7"
		DC.B $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	"8"
		DC.B $7C,$C6,$C6,$7C,$06,$06,$7C,$00	"9"

log_base	DS.L	1


		SECTION	DATA
DspProg		incbin	midi_eng.bin
		even
		INCLUDE instlist.s

old_stuff	DS.L 10
player_sem	DC.W 	0
interpolate_flag: DC.L 	1
TEMPO		DS.L	1
channels_info	DS.B	channel_ss*16
ch1s		DS.B 	sam_vcsize*no_channels
Mtrk_structs	DS.B	MAX_TRACKS*Mtrk_structsize
PatchLIST	DS.B	Ptch_structsize*128	

vol_conv_tab	incbin	data.inc\vol_conv.dat
octave_table	incbin	data.inc\octave.dat
		
music_data	
		IFEQ	midi_record
		INCBIN D:\MUSIC.MID\cavatina.MID
		;INCBIN D:\MUSIC.MID\OP20NO1.MID
		;INCBIN	D:\MUSIC.MID\fantasia.MID
		;incbin	d:\music.mid\bridge.mid
		;INCBIN	D:\MUSIC.MID\midipc_1.MID
		;INCBIN	D:\MUSIC.MID\JAzz07.MID
		;INCBIN D:\MUSIC.MID\tinytoon.MID
		ENDC
		EVEN

		SECTION	BSS
headerbuf	DS.B	240
buffer		DS.B	1000000