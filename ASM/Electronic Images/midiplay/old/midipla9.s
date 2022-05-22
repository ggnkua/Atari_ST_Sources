; 32 Voice .MID File player
; Martin Griffiths July 1994.

gm_offset	EQU	40

no_channels	EQU	32
MAX_TRACKS	EQU	32
midi_record	EQU 	1


		RSRESET
Mtrk_curr_ptr	RS.L	1
Mtrk_event_end	RS.L	1
Mtrk_delta_time	RS.L	1
Mtrk_Running_st	RS.L	1
Mtrk_finished	RS.L	1
Mtrk_structsize	RS.B	0	


		RSRESET
Ptch_UsedFlag	RS.B	1
Ptch_NoSamples	RS.B	1
Ptch_StereoOffy	RS.W	1
Ptch_address	RS.L	1
Ptch_structsize	RS.B	0


		RSRESET
trig_note_flag 	RS.B 1
assoc_chan_no	RS.B 1
cur_voice_used	RS.B 1
voice_used	RS.B 1
cur_trig_off	RS.B 1
cur_lpflag	RS.B 1
cur_pos		RS.L 1
cur_vol		RS.W 1
sam_vol		RS.W 1
cur_start	RS.L 1
cur_end		RS.L 1
cur_lpstart	RS.L 1
cur_lpend	RS.L 1
cur_period_int	RS.L 1
cur_period_frac	RS.L 1
sam_period	RS.W 1
Stereo_Offset	RS.W 1

sam_vcsize	RS.B 0			; structure size.


read_midi_byte	macro
		movem.l	d1-d3/a0-a3,-(sp)		
		move.w	#3,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp
		movem.l	(sp)+,d1-d3/a0-a3
		move.B	d0,\1
		endm



; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

		bra.s	start

convtab		dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

		OPT	D+
start		CLR.L	-(SP)
		MOVE.W	#$20,-(SP)
		TRAP	#1
		ADDQ.L	#6,SP
		MOVE 	#3,-(SP)
		TRAP 	#14
		ADDQ.L 	#2,SP
		MOVE.L 	D0,log_base		

		IFNE	midi_record
		BSR	flush_midi
i		set 	gm_offset
		rept	40
		ST.B	Ptch_UsedFlag+(PatchLIST+Ptch_structsize*i)	
i		set 	i+1
		endr
		ELSEIF

;		LEA	PatchLIST(PC),a5
;		LEA	convtab(PC),A6
;i		set 	0
;		rept	16
;		MOVEQ	#0,D0
;		MOVE.B	(a6)+,d0
;		MOVE.B	d0,channels_info+(i*2)+1
;		MULU	#Ptch_structsize,D0
;		ST.B	Ptch_UsedFlag(A5,d0)	
;i		set 	i+1
;		endr

		LEA	tune(PC),A0
		BSR	init_midi
		BSR	print_tune_info
		ENDC

		BSR 	init_instruments
		BSR	Save_Sound
		BSR 	Start_music 

		MOVE.W	#7,-(SP)
		TRAP	#1
		ADDQ.L 	#2,SP

		BSR	Stop_music 
		BSR 	Restore_Sound

		CLR	-(SP)
		TRAP 	#1

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
		CLR.L	Mtrk_Running_st(A1)
		SF.B	Mtrk_finished(A1)
		LEA 	Mtrk_structsize(A1),A1
		MOVE.L	A2,A0
		SUBQ	#1,D7
		BNE.S	.init_track_lp
		BSR	scan_midi
		LEA	ch1s(PC),A1
		MOVEQ 	#no_channels-1,D0
.ok		SF.B	cur_lpflag(a1)
		clr.l	cur_period_int(a1)
		clr.l	cur_period_frac(a1)
		move.w	#0,cur_vol(a1)
		DBF	D0,.ok
		RTS

.wrongfiletype	
.noMTrk		ILLEGAL

;--------------------------------

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
		CLR.L	Mtrk_Running_st(A1)	
		BRA.S	.next_event
.noscan_sysex_event
		CMP.B	#$FF,D0
		BNE.S	.noscan_meta_event
.scan_meta_event
		ADDQ.L	#1,A0				; skip meta event type
		BSR	read_vari_len			; read meta event length
		ADD.L 	D0,A0
		CLR.L	Mtrk_Running_st(A1)	
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
		
		MOVE.L	D0,Mtrk_Running_st(A1)	
.scan_event	MOVE.L	Mtrk_Running_st(A1),D0
		MOVEQ	#$F,D1
		AND.B	D0,D1		; D1 = low nibble
		ST.B	(A2,D1*2)	; set channel used.
		LSR.B	#4,D0
		AND.W	#$F,D0
		ADD	.size(PC,D0*2),A0
.next_event	BSR	read_vari_len			; read delta-time
		CMP.L	Mtrk_event_end(A1),A0
		BLT.S	.scan_lp
		CLR.L	Mtrk_Running_st(A1)	
		LEA	Mtrk_structsize(A1),A1
		SUBQ	#1,D7
		BNE.S	.scan_trackslp
.done		RTS

.size		DC.W	0,0,0,0,0,0,0,0,2,2,2,2,1,1,2,0		


;--------------------------------


; Heres the sequencer!

Sequence_midi	LEA	channels_info(PC),A3
		LEA 	Mtrk_structs(PC),A6

		IFEQ	midi_record

		MOVE.W	ntrks(PC),D7
		SUBQ	#1,D7
SEQ_TRACK_LP	TST.B	Mtrk_finished(A6)
		BNE	SKIPTRACK			
		SUB.L	#10000,Mtrk_delta_time(A6)
		BGT	SKIPTRACK			
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
		beq	SETUP
		move.w	#3,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp
		AND.L	#$FF,D0
		TST.B	D0
		BMI	NEW_RUNNING_ST
		BRA	MIDI_EVENT

		ENDC

NEW_RUNNING_ST	MOVE.L	D0,Mtrk_Running_st(A6)	
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
		
		MOVE.L	Mtrk_Running_st(A6),D0
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
		MULU.L	TEMPO,D0
		ADD.L   D0,Mtrk_delta_time(A6)
		CMP.L	#10000,Mtrk_delta_time(A6)
		BLT	process_lp

SKIPTRACK	LEA	Mtrk_structsize(A6),A6
		DBF	D7,SEQ_TRACK_LP

		ENDC

		BRA 	SETUP

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

SETUP		LEA	PatchLIST(PC),A3
		LEA	channels_info(PC),A4
		LEA 	ch1s(PC),A5
		LEA	octave_table(PC),A6
		MOVEQ	#no_channels-1,D7

.lp1		TST.B	trig_note_flag(A5)
		BEQ	.notrig
		SF.B	cur_trig_off(a5)
		SF.B	trig_note_flag(A5)
		SF.B	cur_lpflag(A5)
		MOVEQ	#0,D1
		MOVE.B	assoc_chan_no(A5),D1
		MOVE.B	1(A4,D1*2),D1
		move.l	ptch_address(a3,d1*8),a2
		move.w	Ptch_StereoOffy(a3,d1*8),Stereo_Offset(a5)	
		MOVEQ	#0,D5
		MOVE.B	Ptch_NoSamples(a3,d1*8),d5
		MOVE 	sam_period(A5),D3
		MOVEQ	#0,D4
		MOVE.L	(A6,D3*4),D3
		CMP.L	22(A2),D3
		BGT.S	.find_lp
.toolow		MOVE.L	22(A2),D3
		BRA.S	.foundit

.find_lp	CMP.L	26(A2),D3
		BLE.S	.foundit
		SUBQ.B	#1,D5
		BEQ.S	.toohigh
		MOVE.L	8(a2),d0		; sample length
		LEA.L	96(A2,D0.L),A2
		BRA.S	.find_lp
.toohigh	MOVE.L	26(A2),D3
.foundit	MOVE.L	D5,D0
		BSR	num_print
		move.w	20(a2),d5
		swap	d5
		clr	d5
		divu.l	#freq,d5
		mulu.l	d5,d4:d3
		divu.l	30(a2),d4:d3

		move.l	8+8(a2),d0		; sample length
		LEA	96(a2),a2
		LEA.L	(A2,D0.L),A1		; a1-> sample end
		MOVE.L	A2,cur_start(A5)
		MOVE.L	A2,cur_pos(A5)
		MOVE.L	A1,cur_end(A5)
		btst.b	#2,55-96(a2)
		Beq.S	.noloop
		move.l	12-96(a2),d0
		LEA.L	(A2,D0.L),A1
		MOVE.L	A1,cur_lpstart(A5)
		move.l	16-96(a2),d0
		LEA.L	(A2,D0.L),A1
		MOVE.L	A1,cur_lpend(A5)
		BRA.S	.cont
.noloop		CLR.L	cur_lpstart(A5)
		CLR.L	cur_lpend(A5)
.cont		move.l	d3,d4	
		clr.w	d4
		swap	d4
		MOVE.L	D4,cur_period_int(a5)
		lsl.l	#8,d3
		and.l	#$ffffff,d3
		move.l	d3,cur_period_frac(a5)
		MOVE	sam_vol(A5),cur_vol(a5)
.notrig		
		TST.B	cur_trig_off(a5)
		BEQ.S	.eq
		moveq	#0,d0
		MOVE.W	cur_vol(A5),D0
		TST.W	D0
		BEQ.S	.eq1
		SUBQ	#2,D0	
		Bgt.S	.eq1
		clr	d0
		SF.B	voice_used(A5)
.eq1		MOVE.W	D0,cur_vol(A5)		
.eq		

		MOVE.B	voice_used(A5),cur_voice_used(A5)

		LEA	sam_vcsize(A5),A5
		DBF	D7,.lp1
done		RTS
 

NULL		ADDQ.L	#1,A0	
		RTS

; $8 (Note Off)

Note_Off	MOVE.B	D1,D6
		MOVEQ	#0,D3
		IFEQ	midi_record
		MOVE.B	(a0)+,D3
		ELSEIF
		read_midi_byte d3
		ENDC
		LEA	ch1s(pc),a4
		move	#(no_channels-1)*sam_vcsize,d4
.searchoff	cmp.b	assoc_chan_no(a4,d4),d6
		bne.s	.next
		CMP.W 	sam_period(A4,d4),D2
		BEQ.S	.foundit
.next		SUB	#sam_vcsize,D4
		BGE.S	.searchoff
		RTS
.foundit	
		ST.B	cur_trig_off(a4,d4)
		;SF.B	voice_used(a4,d4)

.doneit		RTS

; $9 (Note ON)

Note_On		MOVEQ	#0,D3
		IFEQ	midi_record
		MOVE.B	(a0)+,D3
		ELSEIF
		read_midi_byte d3
		ENDC
		LEA	ch1s(pc),a4
		move.b	d1,d6
		move	#(no_channels-1)*sam_vcsize,d4
.find_lp1	cmp.b	assoc_chan_no(a4,d4),d6
		bne.s	 .next
		CMP.W	sam_period(A4,D4),d2
		BEQ.S	.justvol
.next		SUB	#sam_vcsize,D4
		BGE.S	.find_lp1
		move	#(no_channels-1)*sam_vcsize,d4
.find_lp2	tst.b	voice_used(a4,d4)
		Beq.S	.okfoundvoice
		SUB	#sam_vcsize,D4
		BGE.S	.find_lp2
		RTS
.okfoundvoice	move.b	d6,assoc_chan_no(a4,d4)
		st.b	trig_note_flag(a4,d4)
		st.b	voice_used(a4,d4)
		MOVE.W 	D2,sam_period(A4,D4)
		MOVE.W	D3,sam_vol(A4,D4)	; store volume
.doneit		RTS

.justvol	TST.W	D3
		BNE.S	.okfoundvoice		; zero vol?
		ST.B	cur_trig_off(a4,d4)
		RTS


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

Program_Change	ADD.B	#gm_offset,D2
		MOVE.B	D2,1(A3,D1*2)		; store patch no. in channel info.
		RTS

; $D (PROGRAM (Patch) Change)

Channel_After_Touch	
		RTS


; $E (Pitchbend)

PitchBend	
		IFEQ	midi_record
		ADDQ.L	#1,A0
		ELSEIF
		read_midi_byte	d0
		ENDC
		RTS
		

handle_sysex_event
		BSR	read_vari_len		; read sysex event length
		ADD.L	D0,A0			; just skip it
		CLR.L	Mtrk_Running_st(A6)	
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
		CLR.L	Mtrk_Running_st(A6)	
		BRA	NEXT_EVENT


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

linewidth	equ	832/8

* Routine to print an unsigned word in decimal.D0.L contains the no.to be printed.
* D0-D1/A0-A1 smashed!

num_print	MOVEM.L	D0-D7/A0-A6,-(SP)
		MOVE.L log_base(PC),A0
		DIVU #10000,D0	   	no. of 10,000s
		BSR.S	digi_prin
		ADDQ.L #1,A0		next screen column
		CLR D0			prepare for divide
		SWAP D0			look at remainder
		DIVU #1000,D0 	   	no. of 1,000s
		BSR.S	digi_prin
		ADDQ.L #1,A0		next screen column
		CLR D0			prepare for divide
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
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

* Print a single digit at A0
* D1/A1 smashed.

digi_prin	MOVE D0,D1
		LSL #3,D1
		LEA font_data(PC,D1),A1
i		set 8
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
;------------------------------------------------------------------------------------------
; The Player.


wait_flag	EQU 1			; wait for dsp to finish flag.
pre_div		EQU 2			; pre divider(frequency)
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
		BSR dsp_boot
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
		MOVE.B #1,$FFFFFA1F.W
		MOVE.B #8,$FFFFFA19.W		; timer a event mode.
		BCLR #7,$FFFF8901.w  		; select playback register
		BSR Set_DMA
		MOVE #1024+3,$FFFF8900.W	; DMA ON,timer a int
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
		BSR Set_DMA
		TAS.B player_sem
		BNE .out
		BSET.B	#7,$ffffa201.w
		NOT.L $ffff9800.w
.waitdspexcp	BTST #7,$FFFFA201.w
		BNE.S .waitdspexcp		
		MOVE.W #$2500,SR
		MOVEM.L	D0-D7/A0-A6,-(A7)
		move.l	#ENABLE_CACHE,d0
		movec.l	d0,CACR
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

.SEND		LEA 	ch1s,A1
		MOVEQ 	#0,D7
		MOVEQ	#no_channels-1,D1
.lp2		BSR 	send_voice
		LEA	sam_vcsize(A1),A1
		DBF	D1,.lp2

		IFNE wait_flag
.waitsem2	MOVE.B	-4(a6),d0
		AND.B	#$18,d0
		BNE.S	.waitsem2
		ENDC
		BSR	Sequence_midi	
		MOVEM.L	(A7)+,D0-D7/A0-A6
		SF player_sem
		NOT.L	$ffff9800.w
.out		RTE

RTS


; Send 1 voice to the dsp.

send_voice	
.waitf		BTST #1,-4(A6)			;;;
		BEQ.S .waitf			; send 
		TST.B	cur_voice_used(A1)
		bne.s	.ison
		MOVE.L #0,-2(A6)		 
		rts
.ison		MOVE.L #1,-2(A6)	
			 
		MOVEQ #0,D0
		move.w	Stereo_Offset(a1),d0	
.waits		BTST #1,-4(A6)			;;;
		BEQ.S .waits			; send 
		MOVE.L D0,-2(a6)	;;;

		MOVEQ #0,D0
		MOVE.W cur_vol(A1),d0
		SWAP D0
		LSR.L	#2,D0
		MOVEM.L cur_period_int(A1),D3/D4	;;;
.wait0		BTST #1,-4(A6)			;;;
		BEQ.S .wait0			; send 
		MOVE.L D3,-2(a6)	;;;
.wait1		BTST #1,-4(A6)			;;;
		BEQ.S .wait1			; send 
		MOVE.L D4,-2(a6)	;;;
.wait2		BTST #1,-4(A6)			;;;
		BEQ.S .wait2		; send volume 
		MOVE.L D0,-2(A6)		;;; 
.wait3		BTST #0,-4(A6)			; 
		BEQ.S .wait3			; 
		MOVE.W (A6),D5			; get no. of samples
.wait4		BTST #1,-4(A6)			; 
		BEQ.S .wait4			; 
		move.b #0,-1(a6)		; clear top 8 msbits
		MOVE.L cur_pos(A1),A0		; current voice address
		MOVE.L cur_end(A1),A2
		MOVE.L cur_lpend(A1),A3
		MOVE.L cur_lpstart(A1),A5
do_vce		MOVE.B cur_lpflag(A1),D3	; sample looping?
		BNE.S in_loop
in_main		
		LEA.L (A0,D5.W*2),A4
		CMP.L	A4,A2
		BLT.S	vc_main_cont
		move.w	d5,d4
		and.w	#15,d4
		neg	d4
		lsr.w	#4,d5
		JMP	.madecont(pc,d4*2)
.madeuploop	
		REPT	16
		MOVE.W (A0)+,(A6)
		ENDR
.madecont	DBF D5,.madeuploop
		BRA.S	vce_done

vc_main_lp	MOVE.W (A0)+,(A6)
vc_main_cont	CMP.L A0,A2
		DBEQ D5,vc_main_lp
		BNE.S vce_done
hit_looppoint	ST D3
		MOVE.L A5,A0
in_loop		CMP.L A5,A3
		BLE.S vce_isoffcont

		LEA.L (A0,D5.W*2),A4
		CMP.L	A4,A3
		BLT.S	vclp_cont
		move.w	d5,d4
		and.w	#15,d4
		neg	d4
		lsr.w	#4,d5
		JMP	.madecont(pc,d4*2)
.madeuploop	
		REPT	16
		MOVE.W (A0)+,(A6)
		ENDR
.madecont	DBF D5,.madeuploop
		BRA.S	vce_done
vc_loop_lp	MOVE.W (A0)+,(A6)
vclp_cont	CMP.L A3,A0
		DBEQ D5,vc_loop_lp
		BNE.S vce_done
		MOVE.L A5,A0
		DBF D5,vc_loop_lp
vce_done	MOVE.B D3,cur_lpflag(A1)
		MOVE.L A0,cur_pos(A1)	; store new address
		MOVE.W (A0),(A6)
exit_send	RTS

vce_isoff	
.wait		BTST.B #1,-4(A6)
		BEQ.S .wait
		MOVE.W D7,(A6)
vce_isoffcont	DBF D5,vce_isoff
.wait		BTST.B #1,-4(A6)
		BEQ.S .wait
		MOVE.W D7,(A6)
		RTS

; Set DMA to buffer(buffer len based on TEMPO)
dummy
Set_DMA		MOVEM.L D0/D1,-(SP)
		MOVE.L #dummy,d0
		MOVE.L	#(freq/100)*4,D1
		ADD.L D0,D1
setptrs		MOVE.B d0,$FFFF8907.W
		LSR.L #8,D0
		MOVE.B d0,$FFFF8905.W
		LSR.L #8,D0
		MOVE.B d0,$FFFF8903.W	
		MOVE.B d1,$FFFF8913.W
		LSR.L #8,D1
		MOVE.B d1,$FFFF8911.W
		LSR.L #8,D1
		MOVE.B d1,$FFFF890f.W
		MOVEM.L (SP)+,D0/D1
		RTS

; Reset DSP, and load boot.

dsp_boot	move	sr,d7
		ori.w	#$700,sr
		move.b	#0,$ffffa200.w
		move.b	#$E,$FFFF8800.w
		move.b	$FFFF8800.w,d0
		or.b	#$10,d0
		move.b	d0,$FFFF8802.w
		and.b	#$EF,d0
		nop
		nop
		nop
		nop
		move.b	d0,$FFFF8802.w
		move.w	d7,sr
		LEA DspProg(PC),A0
		move.b	#0,$ffffa200.w
		move.w #512-1,d1
.lp		move.b (a0)+,$FFFFA205.w
		move.w (a0)+,$FFFFA206.w
		dbf d1,.lp
		rts

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
		BSR	print_2digs
.not		LEA	Ptch_structsize(A6),A6
		ADDQ	#1,D6
		CMP.W	#128,D6
		BNE.S	.lp
		BSR	print_newline
		RTS

print_2digs	LEA	digit(PC),A0
		MOVE.L	A0,A1
		DIVU	#10,D0
		MOVE.B	D0,D1
		ADD.B	#'0',D1
		MOVE.B	D1,(A1)+
		SWAP 	D0
		ADD.B	#'0',D0
		MOVE.B	D0,(A1)+
		BRA.S	print

start_txt	DC.B	27,"E"
		DC.B	"DSP Midi Player",$a,$d
		DC.B	"---------------",$a,$d
		DC.B	"MIDI Tracks   : ",0
chans_txt	DC.B	"Channels Used : ",0
insts_txt	DC.B	"Patches Used  : ",0
digit		DC.B	0,0,' ',0
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

flag		dc.w	0
init_instruments:
		LEA	buffer,A5
		LEA	PatchLIST(PC),A6
		MOVEQ	#0,d7
.lp		TST.B	Ptch_UsedFlag(A6)
		BEQ	.not
		move.w	flag(pc),Ptch_StereoOffy(A6)
		eor.w	#1,flag
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
		
		move.W	20(a5),d0		; rate
		ror.w	#8,d0
		move.w	d0,20(a5)
		move.L	22(a5),d0		; low
		ROR.W	#8,D0
		SWAP	D0
		ROR.W	#8,D0
		move.L	d0,22(a5)		; high
		move.L	26(a5),d0
		ROR.W	#8,D0
		SWAP	D0
		ROR.W	#8,D0
		move.L	d0,26(a5)		
		move.L	30(a5),d0
		ROR.W	#8,D0
		SWAP	D0
		ROR.W	#8,D0
		move.L	d0,30(a5)

		move.l	16(a5),d0
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
		move.l	d0,16(a5)
		move.l	12(a5),d0
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
		move.l	d0,12(a5)
		move.l	8(a5),d0
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
		move.l	d0,8(a5)
		move.b	55(a5),d1
		;btst	#1,d1
		;beq	loaderror
		;btst	#0,d1
		;beq	loaderror
		
		lea	96(a5),a5
		move.l	d0,D6
		bsr	read_file
.signlp		move.w	(a5),d1
		ror.w	#8,d1
		eor.w	#$8000,d1
		move.w	d1,(a5)+
		subq.l	#2,D0
		bgt.s	.signlp
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

path		DC.B	"D:\CODING.S\MIDIPLAY\GM1.SET\"
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


		SECTION	DATA
octave_table	INCLUDE	octave.s
		INCLUDE instlist.s

; Dsp Code

DspProg		incbin dspaula.bin
DspProgEnd	DS.B (3*512)-(*-DspProg)
		EVEN

old_stuff	DS.L 10
player_sem	DC.W 	0

interpolate_flag: DC.L 	0

TEMPO		DS.L	1
channels_info	DS.W	16
ch1s		DS.B 	sam_vcsize*32
PatchLIST	DS.B	Ptch_structsize*128	
Mtrk_structs	DS.B	MAX_TRACKS*Mtrk_structsize
		
tune		;INCBIN D:\MUSIC.MID\JARRE8.MID
		;INCBIN D:\MUSIC.MID\PINKPANT.MID
		INCBIN D:\MUSIC.MID\midipc_1.MID
		EVEN

		SECTION	BSS
headerbuf	DS.B	256
buffer		DS.B	1000000