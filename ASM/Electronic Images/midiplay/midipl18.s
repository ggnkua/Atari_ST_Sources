; 32 Voice .MID File player, (C) 1994 Martin Griffiths 
; V0.18 -> added control change (volume)!
; V0.19 -> added aftertouch/pitchbend

				IMPORT FilterFlag

				SUPER	
				MC68030

				IMPORT Insts_Used_In_Song
				IMPORT Percs_Used_In_Song
				IMPORT def_channel_list,def_channel_type
				IMPORT master_vol,master_bal
				IMPORT channels_info
								
MAX_TRACKS		EQU	64		; Maximum number of MIDI tracks
timing			EQU	0
gm_offset		EQU	0
gm_no_insts		EQU	15

no_voices		EQU	14 		; No. of Voices
TIMER_A_VAL		EQU	140
TICKS_PER_INT	EQU	(1000000*140)/(2457600/TIMER_A_VAL)
bufsize			EQU 256

; Sample patch header.
	
				OFFSET
				
wave_size:		ds.l	1
start_loop:		ds.l	1
end_loop:		ds.l	1
tune:			ds.w	1
scale_frequency:ds.w	1
scale_factor:	ds.w 	1
sample_rate:	ds.w	1
envelope_rate:	ds.b	6
envelope_offset:ds.b	6
balance:		ds.b	1
modes:			ds.b	1
reserved:		ds.b	62

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

				OFFSET
Mtrk_start_ptr:	DS.L	1
Mtrk_event_end:	DS.L	1
Mtrk_curr_ptr:	DS.L	1
Mtrk_delta_time:DS.L	1
Mtrk_finished:	DS.W	1
Mtrk_Running_st:DS.W	1
Mtrk_curr_chan:	DS.W	1
		DS.W	1
Mtrk_structsize:DS.B	0	


; Patch information structure
	
				OFFSET
Ptch_address:	DS.L	2
Ptch_UsedFlag:	DS.B	1
Ptch_NoSamples:	DS.B	1
Ptch_StereoOffy:DS.B	1
Ptch_has_loop:	DS.B	1
Ptch_structsize:DS.B	0

; Voice Structure 

				OFFSET
cur_patchstart:	DS.L 1
cur_pos:		DS.L 1
cur_end:		DS.L 1
cur_ramp_vol:	DS.L 1
cur_lpstart:	DS.L 1
cur_lpend:		DS.L 1
cur_intfrac:	DS.L 1
cur_period:		DS.W 1
cur_env_offset:	DS.W 1
assoc_age:		DS.L 1
int:			DS.W 1
frac:			DS.W 1
note_vol:		DS.L 1
note_pan:		DS.W 1
assoc_chan:		DS.B 1
sustain_flag:	DS.B 1
has_lp_flag:	DS.B 1
cur_lpflag:		DS.B 1
sam_vcsize:		DS.B 0			; structure size.

; Midi Channel structure

					OFFSET
channel_noteflags:	DS.L	4
channel_note_vces:	DS.W	128
channel_volume:		DS.W	1
channel_bend:		DS.W	1
channel_pan:		DS.W	1
channel_used:		DS.B	1
channel_inst:		DS.B	1
channel_noteon_ef:	DS.B	1
channel_polypres_ef: DS.B	1
channel_controller_ef: DS.B	1
channel_progchange_ef: DS.B 1
channel_aftertouch_ef: DS.B	1
channel_pitchbend_ef:  DS.B	1
channel_ss:			DS.B	0

				TEXT

		macro	read_midi_byte	X
		movem.l	d1-d3/a0-a3,-(sp)		
		move.w	#3,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp
		movem.l	(sp)+,d1-d3/a0-a3
		move.B	d0,X
		endm

		macro	get_next_byte	X
		tst.b	midi_record
		beq.s	.n1
		read_midi_byte X
		bra.s	.n2
.n1:		MOVE.B	(a0)+,X
.n2:
		endm

; Check and Initialise Standard Midi File.
; -> A0 midi file.

			EXPORT CheckInitMidiFile

CheckInitMidiFile:	
			MOVEM.L	D2-D7/A2-A6,-(SP)
			LEA 	Mtrk_structs,A1
			MOVE.L	(A0)+,D0
			CMP.L	#'MThd',D0		; Chunk type
			BNE	notMIDIfile
			MOVE.L	(A0)+,D0		; Chunk length (6)
			MOVE.W	(A0),D1			; FORMAT
			CMP.W	#2,D1			; midi format 0 or 1?
			BHS	notMIDIfmt0_1		; if not exit with error
			MOVE.W	D1,format
			MOVE.W	2(A0),D7		; NTRKS
			MOVE.W	D7,ntrks
			MOVE.W	4(A0),D1		; DIVISION
			MOVE.W	D1,division		; (specifies meaning of delta-times)
			BTST	#15,D1			
			BNE		notMIDIfmt0_1
			AND.L	#$7FFF,D1		; bits 0-14 represent 'ticks' per quarter note
			MOVE.L	D1,ticks_per_quarter_note
			ADD.L 	D0,A0
init_track_lp:	MOVEM.L	(A0)+,D0/D1		; Chunk type/chunk length
			CMP.L	#'MTrk',D0
			BNE.S	notMIDIfile
			MOVE.L	A0,Mtrk_start_ptr(A1)
			ADD.L	D1,A0
			MOVE.L	A0,Mtrk_event_end(A1)
			LEA 	Mtrk_structsize(A1),A1
			SUBQ	#1,D7
			BNE.S	init_track_lp
			MOVEM.L	(SP)+,D2-D7/A2-A6
			MOVEQ	#0,D0
			RTS
notMIDIfile:MOVEM.L	(SP)+,D2-D7/A2-A6
			MOVEQ	#1,D0
			RTS
notMIDIfmt0_1:
			MOVEM.L	(SP)+,D2-D7/A2-A6
			MOVEQ	#2,D0
			RTS

; Reset the midi channels structure

			EXPORT resetmidichans

resetmidichans:	LEA	channels_info,A0
			MOVEQ	#16-1,D0
.lp:		SF.B	channel_used(A0)
			SF.B	channel_inst(A0)
			CLR.W	channel_bend(A0)
			MOVE.W	#100,channel_volume(a0)
			move.w	#64,channel_pan(a0)
			move.l	#128,d1
			bfclr	channel_noteflags(a0){0:d1}
			lea.l	channel_note_vces(a0),a1
.lp1:		move.w	#-1,(a1)+
			subq	#1,d1
			bne.s	.lp1
			LEA	channel_ss(a0),a0
			DBF	D0,.lp
			CLR.L	age_counter
			move.l	#-1,voiceused_bitfield
			RTS
		
			EXPORT no_patches

no_patches:	DC.W 	0



; Scan Midi File

			EXPORT ScanMidiFile
		
ScanMidiFile:
			MOVEM.L	D2-D7/A2-A6,-(SP)
			LEA	channel_first,A1
			REPT	16
			clr.b	(A1)+
			ENDM
			LEA Mtrk_structs,A1
			MOVE.W	ntrks(PC),D7
scan_trackslp:	MOVE.L	Mtrk_start_ptr(A1),A0
			MOVEQ	#0,D6
scan_lp:	MOVE.B 	(A0),D0
	
			BGE.S	scan_event
			ADDQ.L	#1,A0
			CMP.B	#$F0,D0
			BEQ	scan_sysex_event
			CMP.B	#$F7,D0
			BNE.S	noscan_sysex_event
scan_sysex_event:
			BSR	read_vari_len		; read sysex event length
			ADD.L	D0,A0			; just skip it
			CLR.W	Mtrk_Running_st(A1)	
			BRA.S	scannext_event
noscan_sysex_event:
			CMP.B	#$FF,D0
			BNE.S	noscan_meta_event
scan_meta_event:
			ADDQ.L	#1,A0			; skip meta event type
			BSR		read_vari_len	; read meta event length
			ADD.L 	D0,A0
			CLR.W	Mtrk_Running_st(A1)	
			BRA.S	scannext_event
noscan_meta_event:
			CMP.B	#$C0,D0
			BLO.S	not_program_change
			CMP.B	#$CF,D0
			BHI.S	not_program_change
			MOVEQ	#0,D1
			MOVE.B	(A0),D1
			ST.B	(Insts_Used_In_Song,D1.l)			; Patch used.
			;ST.B	(Percs_Used_In_Song,D1.l)
			MOVEQ	#$F,D2
			AND.B	D0,D2		
			TAS.B	(channel_first,d2.l)
			BNE.S	.notfirst
			move.b	d1,(def_channel_list,d2.l)
.notfirst:	MULU	#Ptch_structsize,D1
			ST.B	(PatchLIST+Ptch_UsedFlag,D1.l)
not_program_change:
			MOVE.W	D0,Mtrk_Running_st(A1)	
scan_event:	MOVE.W	Mtrk_Running_st(A1),D0
			moveq	#$f,d2
			and.b	d0,d2
			mulu	#channel_ss,d2
			ST.B	(channels_info+channel_used,D2.l)		; set channel used.
			LSR.B	#4,D0
			AND.W	#$F,D0
			ADD.L	size(PC,D0*4),A0
scannext_event:	
			CMP.L	Mtrk_event_end(A1),A0
			BEQ.S	scannext_track
			BSR	read_vari_len		; read delta-time
			ADD.L	D0,D6
			BRA		scan_lp

scannext_track:	
			CLR.W	Mtrk_Running_st(A1)	
			LEA	Mtrk_structsize(A1),A1
			SUBQ	#1,D7
			BNE	scan_trackslp
			MOVEM.L	(SP)+,D2-D7/A2-A6
			RTS
channel_first:
			DS.B	16
			
size:		DC.L	0,0,0,0,0,0,0,0
			DC.L	2,2,2,2,1,1,2,0		
age_counter:DC.L	0
midi_record:dc.w 	0 

TEMPO:		DC.L	192

			export ResetMidiTracks

ResetMidiTracks:
			movem.l	d2-d7/a2-a6,-(sp)
			LEA 	Mtrk_structs,A1
			MOVE.W	ntrks,D2
reset_track_lp:	
			MOVE.L	Mtrk_start_ptr(A1),A0
			BSR	read_vari_len
			MOVE.L	A0,Mtrk_curr_ptr(A1)
			MULU.L	TEMPO(PC),D0
			MOVE.L	D0,Mtrk_delta_time(A1)
			CLR.W	Mtrk_Running_st(A1)
			SF.B	Mtrk_finished(A1)
			LEA 	Mtrk_structsize(A1),A1
			SUBQ	#1,D2
			BNE.S	reset_track_lp
			movem.l	(sp)+,d2-d7/a2-a6
			RTS

				
; The sequencer!

Sequence_midi:
		LEA	PatchLIST,A4
		LEA 	Mtrk_structs,A6
		TST.B	midi_record
		BNE	Get_Next_MidiByte
		MOVE.W	ntrks(PC),D7
SEQ_TRACK_LP:	MOVE.L	Mtrk_curr_ptr(A6),A0
		TST.B	Mtrk_finished(A6)
		BNE.S	SKIPTRACK			
		SUB.L	#TICKS_PER_INT,Mtrk_delta_time(A6)
		BGT.S	SKIPTRACK			
		
process_lp:	MOVEQ	#0,D0
		MOVE.B 	(A0)+,D0
		BGE.S	MIDI_EVENT
NEW_RUNNING_ST:	MOVE.W	D0,Mtrk_Running_st(A6)	
		CMP.B	#$F0,D0
		BEQ	handle_sysex_event
		CMP.B	#$F7,D0
		BEQ	handle_sysex_event
		CMP.B	#$FF,D0			
		BEQ	handle_meta_event
		MOVEQ	#0,D0
		MOVE.B	(A0)+,D0
MIDI_EVENT:	MOVE.L	D0,D2
		MOVE.W	Mtrk_Running_st(A6),D0
		MOVEQ	#$F,D1
		AND.B	D0,D1		; D1 = low nibble (channel)
		MOVE.W	D1,Mtrk_curr_chan(A6)
		mulu	#channel_ss,d1
		LEA	(channels_info,d1.l),A3

		LSR.B	#4,D0
		AND.W	#$F,D0
		MOVE	midi_event_tab(PC,D0*2),D3
		JSR	midi_event_tab(PC,D3)
NEXT_EVENT:	TST.B	midi_record
		BNE	Get_Next_MidiByte
		BSR	read_vari_len		; read delta-time
		MULU.L	TEMPO(PC),D0
		ADD.L	D0,Mtrk_delta_time(A6)
		CMP.L	#TICKS_PER_INT,Mtrk_delta_time(A6)
		BLT	process_lp
SKIPTRACK:	
		MOVE.L  A0,Mtrk_curr_ptr(A6)
		LEA	Mtrk_structsize(A6),A6
		SUBQ	#1,D7
		BNE	SEQ_TRACK_LP

done:		RTS

midi_event_tab:	DC.W	NULL-midi_event_tab		;0
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

NULL:		ADDQ.L	#1,A0	
		RTS

Get_Next_MidiByte:
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
		AND.W	#$FF,D0
		TST.B	D0
		BGE	MIDI_EVENT
		MOVE.W	D0,Mtrk_Running_st(A6)	
		MOVEQ	#0,D0
		read_midi_byte d0

		BRA	MIDI_EVENT

; $8 (Note Off)
; D2 = period

Note_Off:	MOVEQ	#0,D3
		get_next_byte	D3
donoteoff:	bfclr	channel_noteflags(a3){d2:1}
		move.w	channel_note_vces(a3,d2.w*2),d1
		bmi.s	.hmmm
		move.w	#-1,(a3,d2.w*2)		
		mulu	#sam_vcsize,d1
		SF.B	(ch1s+sustain_flag,d1.l)
.hmmm:	rts

; $9 (Note ON)

env_max		EQU	5

Note_On:	moveq	#0,D3
			get_next_byte	D3		; d2 = sam period d3 = sam volume
			tst.b	channel_noteon_ef(a3)
			bne		.nono
			move.w	Mtrk_curr_chan(A6),D5
			tst.w	(FilterFlag,D5*2)
			bne		.nono
			bftst	channel_noteflags(a3){d2:1}
			beq.s	.nonoteon
			TST.W	D3
			BEQ	donoteoff	; zero vol?
			BNE	.justvol
.nonoteon:	move.w	channel_note_vces(a3,d2.w*2),d4
			bge.s	.start_sound

			bfset	channel_noteflags(a3){d2:1}
			bfffo	(voiceused_bitfield){0:no_voices},d4
			cmp.w	#no_voices,d4
			bne.s	.start_sound

			LEA	ch1s,a5
			move.l	age_counter(pc),d6
			MOVEQ	#0,D5
.lp1:		cmp.l	assoc_age(a5),d6
			blo.s	.nah1
			move.w	d5,d4
			move.l	assoc_age(a5),d6
.nah1:		LEA	sam_vcsize(a5),a5
			ADDQ	#1,D5
			CMP.W	#no_voices,D5
			BNE.S	.lp1

.start_sound:
			bfclr	(voiceused_bitfield){d4:1}
			move.w	d4,channel_note_vces(a3,d2.w*2)
			mulu	#sam_vcsize,d4
			LEA	(ch1s,d4.l),a5
			MOVE	D2,cur_period(a5)
			MOVE.B	D5,assoc_chan(a5)
			MOVE.L	age_counter(PC),assoc_age(a5)
			MOVEQ	#0,D6
			MOVE.B	channel_inst(a3),D6
			mulu	#Ptch_structsize,d6
			move.l	Ptch_address(a4,D6.l),a2
			lea	(a2,d2*4),a1
			add.l	16(a1),a2
			move.l	512+16(a1),cur_intfrac(a5)
			SF.B	cur_lpflag(a5)
			btst.b	#looped___flag,modes(a2)
			sne.b	has_lp_flag(a5)
			btst.b	#sustain__flag,modes(a2)
			sne.b	sustain_flag(a5)

			MOVE.L	A2,cur_patchstart(A5)
			move.l	start_loop(a2),d0
			LEA.L	96(A2,D0.L),A1
			MOVE.L	A1,cur_lpstart(A5)
			move.l	end_loop(a2),d0
			LEA.L	96(A2,D0.L),A1
			MOVE.L	A1,cur_lpend(A5)
			LEA	96(a2),a1
			MOVE.L	A1,cur_pos(A5)
			add.l	wave_size(a2),a1
			move.l	a1,cur_end(a5)

			CLR.W	cur_env_offset(a5)
.justvol:	mulu	channel_volume(a3),d3
			move.w	channel_pan(a3),note_pan(a5)
			MOVE.l	D3,note_vol(a5)
.nono:		RTS

tabby:		DC.W	512*9*2,64*9*2,8*9*2,1*9*2

curr_voice:	dc.w	0
voiceused_bitfield:
			dc.l	-1

; $A ((Key After Touch)

Key_After_Touch:
			get_next_byte	d0
			tst.b	channel_aftertouch_ef(a3)
			bne.s	.noat

.noat:		RTS

; $B Control		

Control_Change:	
			MOVEQ	#0,D3
			get_next_byte	d3
			tst.b	channel_controller_ef(a3)
			bne.s	.nocont
			CMP.B	#7,D2
			BNE.S	.nocont
			MOVE.W	D3,channel_volume(A3)	
.nocont:	RTS
		

; $C (PROGRAM (Patch) Change)

Program_Change:	
			tst.b	channel_progchange_ef(a3)
			bne.s	.nopchange
			MOVE.B	D2,channel_inst(A3); store patch no. in channel info.
.nopchange:	RTS

; $D (PROGRAM (Patch) Change)

Channel_After_Touch:
			tst.b channel_polypres_ef(a3)
			bne.s	.nopp

			;MOVE.B	D2,channel_inst(A3); store patch no. in channel info.
.nopp:			RTS

; $E (Pitchbend)

PitchBend:	get_next_byte	d0
			tst.b	channel_pitchbend_ef(a3)
			bne.s 	.nopb
			AND.W	#$ff,d0
			LSL.W	#7,D0
			OR.W	D0,D2
			MOVE.W	D2,channel_bend(A3)	
.nopb:		RTS
		

handle_sysex_event:
		BSR	read_vari_len		; read sysex event length
		ADD.L	D0,A0			; just skip it
		CLR.W	Mtrk_Running_st(A6)	
		BRA	NEXT_EVENT
				
handle_meta_event:
		MOVE.B	(A0)+,D0		; meta event type
		cmp.b   #$51,d0
		bne     .nosettempo
.set_tempo:	MOVE.L	(A0),D1
		and.l	#$ffffff,d1	 		; (24-bit tempo - microseconds/quarternote)
		DIVU.L	ticks_per_quarter_note(PC),D1
		move.L  D1,TEMPO			; (d1 = clocks.10^-4/tick)
		BRA.S	.cont
.nosettempo:	CMP.B	#$2F,D0
		BNE.S	.not_track_end
		ST.B	Mtrk_finished(A6)
.not_track_end:
.cont:		BSR	read_vari_len			; read meta event length
		ADD.L 	D0,A0
		CLR.W	Mtrk_Running_st(A6)	
		BRA	NEXT_EVENT

; Read a variable length number.
; -> A0.
; returns number in d0.

read_vari_len:	MOVEQ	#0,D0
.vloop:  	lsl.l   #7,d0
		move.b  (a0)+,d1
		and.b   #$7f,d1
		add.b   d1,d0
		btst.b  #7,-1(a0)
		bne.s    .vloop
		rts

format:		DC.W 0
ntrks:		DC.W 0
division:	DC.W 0
ticks_per_quarter_note:
		DC.L 0	
	
	
;------------------------------------------------------------------------------------------

; The Player.

Save_Sound:	LEA old_stuff(PC),A0
		MOVE.W SR,D0
		ORI.W #$700,SR
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
		MOVE.W D0,SR
		RTS

Restore_Sound:	LEA old_stuff(PC),A0
		MOVE.W SR,D0
		ORI.W #$700,SR
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
		MOVE.W D0,SR
		RTS
old_stuff:	ds.l 	16
		
			EXPORT	DSP_Initial_Sync

DSP_Initial_Sync:
.sync1:		BTST.B #0,$FFFFA202.W
			BEQ.S .sync1
			MOVE.L $FFFFA204.W,d0		
.sync2:		BTST.B #0,$FFFFA202.W
			BEQ.S .sync2
			MOVE.L $FFFFA204.W,d1
			RTS

			EXPORT	Sound_Interrupt_ON

Sound_Interrupt_ON:	
			movem.l d0-d7/a0-a6,-(sp)
			BSR	Set_DMA
			moveq #6,d0
			moveq #2,d0
			bsr soundcom
			moveq #1,d0
			bsr setmode
			moveq #0,d0
			moveq #0,d1
			bsr settracks
			moveq #0,d0
			bsr setmontracks
			moveq #0,d0
			moveq #1,d1
			bsr setinterrupt
			moveq #3,d0
			bsr setbufptr
			MOVE.W SR,d0
			ORI.W #$0700,SR
			MOVE.B #0,$FFFFFA19.W
			BSET.B #5,$FFFFFA07.W		;iera
			BSET.B #5,$FFFFFA13.W		;imra
			MOVE.L #music_int,$134.W
			MOVE.B #1,$FFFFFA1F.W
			MOVE.B #8,$FFFFFA19.W		; timer a event mode.
			MOVE.W d0,SR
			movem.l (sp)+,d0-d7/a0-a6
			RTS

soundcom:	move.w d1,-(sp)
		move.w d0,-(sp)
		move.w #130,-(sp)
		trap #14
		addq.l #6,sp
		rts
setmode:		move.w d0,-(sp)
		move.w #132,-(sp)
		trap #14
		addq.l #4,sp
		rts
settracks:	move.w d1,-(sp)
		move.w d0,-(sp)
		move.w #133,-(sp)
		trap #14
		addq.l #6,sp
		rts
setmontracks:	move.w d0,-(sp)
		move.w #134,-(sp)
		trap #14
		addq.l #4,sp
		rts
setinterrupt:	move.w d1,-(sp)
		move.w d0,-(sp)
		move.w #135,-(sp)
		trap #14
		addq.l #6,sp
		rts

setbufptr:	
		move.w d0,-(sp)
		move.w #136,-(sp)
		trap #14
		addq.l #4,sp
		rts

; Set DMA to play buffer(buffer len based on TEMPO)

Set_DMA:MOVE.L D0,-(SP)
		MOVE.L stebuf_ptrs+4(PC),D0
		ADD.L	#bufsize*4,d0
		MOVE.L	D0,-(SP)
		MOVE.L stebuf_ptrs+4(PC),-(SP)
		BCLR.B #7,$FFFF8901.W
		MOVE.B 3(a7),d0			;9
		MOVE.W d0,$FFFF8906.W
		MOVE.B 2(a7),d0			;8
		MOVE.W d0,$FFFF8904.W
		MOVE.B 1(a7),d0			;7
		MOVE.W d0,$FFFF8902.W	
		MOVE.B 7(a7),d0			;D
		MOVE.W d0,$FFFF8912.W
		MOVE.B 6(a7),d0			;C
		MOVE.W d0,$FFFF8910.W
		MOVE.B 5(a7),d0			;B
		MOVE.W d0,$FFFF890E.W
		ADDQ.L #8,SP
		MOVE.L stebuf_ptrs(PC),D0
		MOVE.L stebuf_ptrs+4(PC),stebuf_ptrs
		MOVE.L D0,stebuf_ptrs+4
		MOVE.L (SP)+,D0
		RTS

stebuf_ptrs:DC.L stebuf1,stebuf2
stebuf1:	DS.l bufsize	 	
stebuf2:	DS.l bufsize		
			EXPORT	Sound_Interrupt_OFF

Sound_Interrupt_OFF:
			movem.l	d0-d7/a0-a6,-(sp)
			moveq #0,d0
			bsr setbufptr
			MOVE.W SR,D0
			ORI.W #$700,SR
			MOVE.B #0,$FFFFFA19.W		; STOP INT
			BCLR.B #5,$FFFFFA07.W		; iera
			BCLR.B #5,$FFFFFA13.W		; iera
			MOVE.W D0,SR
			movem.l	(sp)+,d0-d7/a0-a6
			RTS
			
wait_next_seq:
			move.l	d0,-(sp)
			move.l	age_counter(pc),d0
.wait:		cmp.l	age_counter(pc),d0
			beq.s	.wait
			move.l	(sp)+,d0
			rts
			
			EXPORT DOPLAY
			
DOPLAY:		
			move.w	#0,midi_record
			ST.B	seq_flag
			RTS
			EXPORT DOSTOP

DOSTOP:		movem.l	d2-d7/a2-a6,-(sp)
			move.l	master_vol,d7
			bsr		ramp_off
			move.w	#0,midi_record
			SF.B	seq_flag	
			move.l	#-1,voiceused_bitfield
			move.l	d7,master_vol
			movem.l	(sp)+,d2-d7/a2-a6
			RTS

ramp_off:	move.l	master_vol,d6
.lp:		sub.w	#16,d6
			bmi.s	.ok
			move.l	d6,master_vol
			move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
			bra.s	.lp
.ok:		clr.l	master_vol
			bsr		wait_next_seq
			rts
			
ramp_on:	moveq	#0,d5
.lp:		move.l	d5,master_vol
			bsr		wait_next_seq
			add.w	#16,d5
			cmp.w	d5,d6
			bge.s	.lp
			move.l	d6,master_vol
			bsr		wait_next_seq
			rts			
			EXPORT DOMIDIIN

DOMIDIIN:	
			movem.l	d2-d7/a2-a6,-(sp)
			SF.B	seq_flag
			move.l	#-1,voiceused_bitfield
			move.w	#-1,midi_record
			move.w	#7,-(sp)
			trap	#1
			addq.l	#2,sp
			move.w	#0,midi_record
			movem.l	(sp)+,d2-d7/a2-a6
			rts
			EXPORT DOPAUSE

DOPAUSE:	movem.l	d2-d7/a2-a6,-(sp)
			move.w	#0,midi_record
			TST.B	seq_flag
			BNE.S	.is_on
.is_off:	
			move.l	save_vbf(pc),voiceused_bitfield
			move.l	save_vol(pc),d6
			ST.B	seq_flag
			BSR		ramp_on
			movem.l	(sp)+,d2-d7/a2-a6
			RTS			
.is_on:		move.l	master_vol,save_vol
			BSR		ramp_off
			SF.B	seq_flag
			move.l	voiceused_bitfield(pc),save_vbf
			move.l	#-1,voiceused_bitfield
			movem.l	(sp)+,d2-d7/a2-a6
			RTS
save_vol:		dc.l 	0			
save_vbf:		dc.l	0
seq_flag:		dc.w	0
player_sem:		DC.W 	0
interpolate_flag:DC.L 	0

music_inint:
			;SF.B	seq_flag	
			;move.l	#-1,voiceused_bitfield
			BCLR #5,$fffffa0f.w
			RTE
			
			EXPORT 	tmr_count
			
tmr_strt:	dc.l 	0				
tmr_count:	dc.l	0
music_int:	
			BSR Set_DMA
			TAS.B player_sem
			BNE.S 	music_inint
			ADDQ.L	#1,age_counter
			BCLR #5,$fffffa0f.w
		
			MOVE.B #$80+19,$FFFFA201.W		; host command 2
			IFNE	timing
			NOT.L $ffff9800.w
			ENDC
			MOVEM.L	D0-D7/A0-A6,-(A7)
			LEA $ffffa206.w,a6
.waitsem2:	MOVE.B	-4(a6),d0
			AND.B	#$18,d0
			CMP.B	#$18,d0		; wait for host flag bits to be set.
			BNE.S	.waitsem2
			MOVE.W #$2500,SR
			MOVE.L	$4ba.w,tmr_strt
			BSR 	send_voices

.waitsem21:	MOVE.B	-4(a6),d0
			AND.B	#$18,d0
			BNE.S	.waitsem21
			
			MOVE.L stebuf_ptrs(pc),a5
			move.w	#bufsize/8-1,d7
.lp:
			rept	8
			move.w	(a6),(a5)+
			move.w	(a6),(a5)+
			endm
			dbf	d7,.lp		

		
		TST.B	seq_flag
		BEQ.S	.nah
		BSR	Sequence_midi	
.nah:
		MOVE.L	$4ba.w,D0
		SUB.L	tmr_strt(pc),d0
		ADD.L	d0,tmr_count
		MOVEM.L	(A7)+,D0-D7/A0-A6
		IFNE	timing
		NOT.L	$ffff9800.w
		ENDC

fuckit:	MOVE	#$2700,sr
		SF player_sem
		RTE

; Send voices to the dsp.

alloff:		
.waitf1:	BTST #1,-4(A6)		
			BEQ.S .waitf1		
			CLR.L	-2(A6)		 
			ADDQ	#1,D7
			CMP.W	#no_voices,D7
			BNE.S		alloff
			RTS

send_voices:LEA 	ch1s,A1
			MOVEQ	#0,D7
.wait8:		BTST.B #1,-4(A6)
			BEQ.S .wait8
			MOVE.L #no_voices,$FFFFA204.W
			btst.b	#7,$ffff8a3c.w
			bne.s	alloff
			tst.b	seq_flag
			beq.s	alloff

send_lp:	bftst	(voiceused_bitfield){d7:1}
			beq.s	.ison
.isoff:
.waitf1:	BTST #1,-4(A6)			;;;
			BEQ.S .waitf1			; send 
			CLR.L	-2(A6)		 
			LEA	sam_vcsize(A1),A1
			ADDQ	#1,D7
			CMP.W	#no_voices,D7
			BNE.S	send_lp
			RTS
			
.ison:		moveq	#0,d0
			move.b	assoc_chan(a1),d0
			tst.w	(FilterFlag,d0*2)
			bne.s	.isoff
			MOVE.L	cur_patchstart(A1),a2
			MOVE.L	cur_ramp_vol(A1),D0
			MOVE.W	cur_env_offset(A1),D2
			TST.B	sustain_flag(a1)
			BEQ.S	.no_suss
			CMP	#3,D2
			beq.s	.nah
.no_suss:	MOVE.B	envelope_rate(A2,d2),D4
		MOVEQ	#0,D3
		MOVE.B	envelope_offset(A2,D2),D3
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
.down:		CMP.L	D6,D4
		BHS.S	.do_check
		SUB.L	D4,D0
		BRA.S	.nah
.up:		NEG.L	D6
		CMP.L	D6,D4
		BHS.S	.do_check
		ADD.L	D4,D0
		BRA.S	.nah
.do_check:	MOVE.L	D3,D0

			CMP	#5,D2
			bne.s	.nxt
			bfset	(voiceused_bitfield){d7:1}
			moveq	#0,d0
			move.b	assoc_chan(a1),D0
			mulu	#channel_ss,d0
			lea	channels_info,a0
			lea	channel_note_vces(a0,d0.l),a0
			move.w	cur_period(a1),d0
			move.w	#-1,(a0,d0.w*2)

.nxt:		ADDQ	#1,d2
.nah:		MOVE.W	D2,cur_env_offset(A1)
			MOVE.L	D0,cur_ramp_vol(A1)

.waitf2:	BTST #1,-4(A6)			;;;
			BEQ.S .waitf2			; send 
			MOVE.L #1,-2(A6)	
			moveq	#0,d1
			move.w	note_pan(a1),d1
			sub.w	#64,d1
			add.l  master_bal,d1
			
			swap	d1
			tst.l	d1
			bge.s	.noclip1
			moveq	#0,d1
.noclip1:	cmp.l	#$7fffff,D1
			ble.s	.noclip2
			move.l	#$7fffff,d1
.noclip2:			
.waits:		BTST #1,-4(A6)			;;;
			BEQ.S .waits			; send 
			MOVE.L d1,-2(a6)	;;;
			lsr.w	#4,d0
			move.l	vol_conv_tab_ptr,a3
			move.l	(a3,d0*4),d0
			mulu.l	master_vol,d0
			lsr.l	#7,d0
			MULU.l	note_vol(A1),d0	; 0..128
			lsr.l	#8,d0	
.wait1:		BTST #1,-4(A6)			;;;
			BEQ.S .wait1			; send 
			MOVE.L cur_intfrac(a1),-2(a6)	;;;
.wait2:		BTST #1,-4(A6)			;;;
			BEQ.S .wait2		; send volume 
			MOVE.L D0,-2(A6)		;;; 
.wait3:		BTST #0,-4(A6)			; 
			BEQ.S .wait3			; 
			MOVE.W (A6),D5			; get no. of samples
.wait4:		BTST #1,-4(A6)			; 
			BEQ.S .wait4			; 
			move.b #0,-1(a6)		; clear top 8 msbits

		MOVE.L cur_pos(A1),A0		; current voice address
		MOVE.L cur_end(A1),A2
		MOVE.L cur_lpend(A1),A3
		MOVE.L cur_lpstart(A1),A5
		MOVE.B cur_lpflag(A1),D3	; sample looping?
		BNE.S in_loop
		BRA.S	vc_main_cont

vc_main_lp:	
				MOVE.W (A0)+,(A6)
vc_main_cont:	CMP.L A0,A2
		DBEQ D5,vc_main_lp
		BNE.S vce_done
hit_looppoint:	ST D3
		MOVE.L A5,A0
in_loop:		TST.B	has_lp_flag(a1)
		BEQ.S	vce_isoffcont
		CMP.L A5,A3
		BLE.S vce_isoffcont
		BRA.S	vclp_cont

vc_loop_lp:	
		MOVE.W (A0)+,(A6)
vclp_cont:	CMP.L A3,A0
		DBEQ D5,vc_loop_lp
		BNE.S vce_done
		MOVE.L A5,A0
		DBF D5,vc_loop_lp
vce_done:	MOVE.B D3,cur_lpflag(A1)
		MOVE.L A0,cur_pos(A1)	; store new address
.wait:		BTST.B #1,-4(A6)
			BEQ.S .wait
		MOVE.W (A0),(A6)
exit_send:	
			LEA	sam_vcsize(A1),A1
			ADDQ	#1,D7
			CMP.W	#no_voices,D7
			BNE	send_lp
			RTS
			
vce_isoff:	
.wait:		BTST.B #1,-4(A6)
			BEQ.S .wait
			CLR.W (A6)
vce_isoffcont:
			DBF D5,vce_isoff
.wait:		BTST.B #1,-4(A6)
			BEQ.S .wait
			CLR.W (A6)
			bfset	(voiceused_bitfield){d7:1}	
			bra	exit_send

				EXPORT channels_info
				EXPORT PatchLIST
				EXPORT vol_conv_tab_ptr
				
vol_conv_tab_ptr:
				dc.l	0
			
				BSS

ch1s:			DS.B 	sam_vcsize*no_voices
Mtrk_structs:	DS.B	MAX_TRACKS*Mtrk_structsize
PatchLIST:		DS.B	Ptch_structsize*256


				END
		