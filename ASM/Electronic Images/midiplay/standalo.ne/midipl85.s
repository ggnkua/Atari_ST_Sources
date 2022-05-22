; 32 Voice .MID File player, (C) 1994 Martin Griffiths 
; V0.18 -> added control change (volume)!
; V0.19 -> added aftertouch/pitchbend
; V0.80 -> total rewrite.

		opt d+

; Various structures

;
; 'Modes' bit flags.

bits8_16_flag	EQU	0		; bit 0 = 8 or 16 bit wave data. 
signed___flag	EQU	1		; bit 1 = Signed - Unsigned data. 
looped___flag	EQU	2		; bit 2 = looping enabled-1. 
bilooped_flag	EQU	3		; bit 3 = Set is bidirectional looping. 
bwlooped_flag	EQU	4		; bit 4 = Set is looping backward. 
sustain__flag	EQU	5		; bit 5 = Turn sustaining on. (Env. pts. 3)
envelope_flag	EQU	6		; bit 6 = Enable envelopes - 1
fast_rel_flag	EQU	7


; 


read_midi_byte	macro	
		movem.l	d1-d3/a0-a3,-(sp)		
		move.w	#3,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp
		movem.l	(sp)+,d1-d3/a0-a3
		move.B	d0,\1
		endm

get_next_byte	macro
		tst.b	midi_record
		beq.s	.n1
		read_midi_byte \1
		bra.s	.n2
.n1:		MOVE.B	(a0)+,\1
.n2:
		endm


start:		CLR.L	-(SP)
		MOVE.W	#$20,-(SP)
		TRAP	#1
		ADDQ.L	#6,SP
		BSR 	dsp_init
		st PatchLIST+Ptch_UsedFlag
		
		LEA	music_data,A0
		BSR	init_midi

		BSR	print_tune_info

		BSR 	init_instruments
		BSR	Save_Sound
		BSR 	Start_music 

		move.w	#2,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp		

		BSR	Stop_music 
		BSR 	Restore_Sound

		CLR	-(SP)
		TRAP 	#1

init_midi:	bsr CheckInitMidiFile
		bsr ScanMidiFile
		BSR	reset_tracks
		move.l	#-1,voiceused_bitfield

		clr.l	age_counter
		rts


; Check and Initialise Standard Midi File.
; -> A0 midi file.

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
		BNE	wrongfiletype	
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
notMIDIfile:	MOVEM.L	(SP)+,D2-D7/A2-A6
		MOVEQ	#1,D0
		RTS
notMIDIfmt0_1:	MOVEM.L	(SP)+,D2-D7/A2-A6
		MOVEQ	#2,D0
		RTS

; 
; Scan Midi File


ScanMidiFile:	MOVEM.L	D2-D7/A2-A6,-(SP)
		BSR	resetmidichans
		LEA 	Mtrk_structs,A1
		LEA	channels_info,A2
		LEA	PatchLIST,A3
		CLR.W	no_patches
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
		ADDQ.L	#1,A0				; skip meta event type
		BSR	read_vari_len			; read meta event length
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
		MULU	#Ptch_structsize,D1
		TST.B	Ptch_UsedFlag(A3,D1.l)
		BNE.S	not_program_change
		ST.B	Ptch_UsedFlag(A3,D1.l)
		ADDQ	#1,no_patches
not_program_change:
		MOVE.W	D0,Mtrk_Running_st(A1)	
scan_event:	MOVE.W	Mtrk_Running_st(A1),D0
		MOVEQ	#$F,D1
		AND.B	D0,D1		; D1 = low nibble
		MULU	#channel_ss,d1
		ST.B	channel_used(A2,D1.L)		; set channel used.
		LSR.B	#4,D0
		AND.W	#$F,D0
		ADD	size(PC,D0*2),A0
scannext_event:	
		CMP.L	Mtrk_event_end(A1),A0
		BEQ.S	scannext_track
		BSR	read_vari_len		; read delta-time
		ADD.L	D0,D6
		BRA	scan_lp

scannext_track:	CLR.W	Mtrk_Running_st(A1)	
		LEA	Mtrk_structsize(A1),A1
		SUBQ	#1,D7
		BNE	scan_trackslp
		MOVEM.L	(SP)+,D2-D7/A2-A6
		RTS

size:		DC.W	0,0,0,0,0,0,0,0
		DC.W	2,2,2,2,1,1,2,0		
age_counter:	DC.L	0
midi_record:	dc.w 	0 
TEMPO:		DC.L	192

reset_tracks:	LEA 	Mtrk_structs,A1
		MOVE.W	ntrks,D2
reset_track_lp:	MOVE.L	Mtrk_start_ptr(A1),A0
		BSR	read_vari_len
		MOVE.L	A0,Mtrk_curr_ptr(A1)
		MULU.L	TEMPO(PC),D0
		MOVE.L	D0,Mtrk_delta_time(A1)
		CLR.W	Mtrk_Running_st(A1)
		SF.B	Mtrk_finished(A1)
		LEA 	Mtrk_structsize(A1),A1
		SUBQ	#1,D2
		BNE.S	reset_track_lp
		RTS

wrongfiletype:	
noMTrk:		MOVEM.L	(SP)+,D1-D7/A0-A6
		MOVEQ	#1,D0
		RTS

	
;------------------------------------------------------------------------------------------

; The Player.


wait_flag	EQU 0			; wait for dsp to finish flag.
freq		EQU ((25175000)/(pre_div+1))/256


Start_music:	MOVE.B #0,$FFFFFA19.W
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
.sync1:		BTST.B #0,$FFFFA202.W
		BEQ.S .sync1
		MOVE.L $FFFFA204.W,d0		
.sync2:		BTST.B #0,$FFFFA202.W
		BEQ.S .sync2
		MOVE.L $FFFFA204.W,d1	
		MOVE.B #19,$FFFFA201.W		; host command 2
		MOVE.B #TIMER_A_VAL,$FFFFFA1F.W
		MOVE.B #7,$FFFFFA19.W		; timer a event mode.
		MOVE.B #TIMER_A_VAL,$FFFFFA1F.W
		RTS

Stop_music:	MOVE.W SR,D0
		ORI.W #$700,SR
		MOVE.B #0,$FFFFFA19.W		; STOP INT
		MOVE.W #0,$FFFF8900.W		; STOP DMA
		BCLR.B #5,$FFFFFA07.W		; iera
		BCLR.B #5,$FFFFFA13.W		; iera
		MOVE.W D0,SR
		RTS



; Reset DSP, and load boot.

dsp_init:	move	sr,-(a7)
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
.lp:		move.b (a0)+,$FFFFA205.w
		move.w (a0)+,$FFFFA206.w
		dbf d0,.lp
		move.b	#0,$FFFFA200.w
		rts

init_instruments:
		LEA	buffer,A5
		LEA	PatchLIST,A6
		MOVEQ	#0,d7
.lp:		TST.B	Ptch_UsedFlag(A6)
		BEQ	.not
		move.b	flag(pc),Ptch_StereoOffy(A6)
		eor.b	#1,flag
		LEA	Instrument_List(PC),A3
		MOVE.L	(A3,d7*4),A0
		LEA	filename(PC),A4
.cpy:		MOVE.B	(A0)+,D0
		MOVE.B	D0,(A4)+
		TST.B	D0
		BNE.S	.cpy
		SUBQ.L	#1,A4
		MOVE.L	#'.PAT',(A4)+
		CLR.B	(A4)+
		LEA	path(PC),A4
		BSR	open_file

		MOVE.L	#(260*4),D6
		BSR	read_file
		move.l	(a5),d4
		MOVE.B	D4,Ptch_NoSamples(A6)
		MOVE.L	A5,Ptch_address(A6)
		add.l	#260*4,a5
.sam_lp:	MOVEQ	#96,D6
		BSR	read_file
		move.l	wave_size(a5),d6
		lea	96(a5),a5
		bsr	read_file
		add.l	d6,a5
		subq.l	#1,d4
		bne.s	.sam_lp
		bsr	close_file
.not:		LEA	Ptch_structsize(A6),A6
		ADDQ	#1,d7
		CMP.W	#128,d7
		BNE	.lp
		rts

path:		DC.B	"D:\GM2.SET\"
filename:	DS.B	16
		EVEN


open_file:	movem.l d0-d3/a0-a3,-(sp)
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

read_file:	movem.l d0-d3/a0-a3,-(sp)
		MOVE.L A5,-(SP)			; address
		MOVE.L D6,-(SP)			; length
		MOVE handle(PC),-(SP)		; handle
		MOVE #$3F,-(SP)
		TRAP #1				; read da file
		LEA 12(SP),SP
		TST.L	D0
		BMI.S	loaderror
		CMP.L	D0,D6
		BNE.S	loaderror
		movem.l (sp)+,d0-d3/a0-a3
		RTS

close_file:	movem.l d0-d3/a0-a3,-(sp)
		MOVE handle(PC),-(SP)
		MOVE #$3E,-(SP)
		TRAP #1				; close da file!
		ADDQ.L #4,SP
		movem.l (sp)+,d0-d3/a0-a3
		RTS
handle:		DC.W	0

loaderror:	ILLEGAL


;----------------------------------------------------------------

print_tune_info:
		LEA	start_txt(PC),A0
		BSR	print
		MOVE.W	ntrks(PC),D0
		BSR	print_2digs
		BSR	print_newline
		LEA	chans_txt(PC),A0
		BSR	print
PRINT_CHANS_USED:	
		LEA	channels_info,A6
		MOVEQ	#0,D6
		MOVEQ	#0,D7
.lp:		TST.B	(A6)
		BEQ.S	.not
		MOVE.L	D6,D0
		BSR	print_2digs
		ADDQ	#1,D7
.not:		ADDQ.L	#2,A6
		ADDQ	#1,D6
		CMP.W	#16,D6
		BNE.S	.lp
		BSR	print_newline
PRINT_INSTS_USED:	
		LEA	insts_txt(PC),A0
		BSR	print
		LEA	PatchLIST,A6
		MOVEQ	#0,D6
.lp:		TST.B	Ptch_UsedFlag(A6)
		BEQ.S	.not
		MOVE.L	D6,D0
		BSR	print_3digs
.not:		LEA	Ptch_structsize(A6),A6
		ADDQ	#1,D6
		CMP.W	#128,D6
		BNE.S	.lp
		BSR	print_newline
		RTS


print_3digs:	LEA	digit3(PC),A0
		MOVE.L	A0,A1
		DIVU	#100,D0
		MOVE.B	D0,D1
		ADD.B	#'0',D1
		MOVE.B	D1,(A1)+
		CLR	D0
		SWAP	D0
		BRA.S	cont_p2

print_2digs:	LEA	digit(PC),A0
		MOVE.L	A0,A1
cont_p2:	DIVU	#10,D0
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

start_txt:	DC.B	27,"E"
		DC.B	"DSP Digital Sound Module Driver  v0.80",$a,$d
		DC.B	"-------------------------------",$a,$d
		DC.B  	"(C) October 1994 Martin Griffiths.",$a,$d,$a,$d 
		DC.B	"MIDI Tracks   : ",0
chans_txt:	DC.B	"Channels Used : ",0
insts_txt:	DC.B	"Patches Used  : ",0
digit:		DC.B	0,0,' ',0
digit3:		DC.B	0,0,0,' ',0
		EVEN
print_newline:	LEA	newline(pc),a0

; Print Rout -> Text address in A0...  Uses TXPOS and TYPOS (.B)
; (not fast or anything but works nicely thank you!)

print:		pea (a0)
		move.w #9,-(sp)
		trap #1
		addq.l #6,sp
		rts
newline:	dc.b	$a,$d,0,0

flush_midi:	
.fl:		move.w	#3,-(sp)
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
.done:		rts

flag:		dc.b	0
		even

DspProg:	incbin	midi_eng.bin
		even
		
		include instlist.s
		
		even

old_stuff:	DS.L 10
player_sem:	DC.W 	0
interpolate_flag: DC.L 	0

vol_conv_tab:	incbin	vol_conv.dat
;music_data:	incbin	f:\music.mid\op20no1.mid
music_data:	incbin	f:\dilast1b.mid
;music_data:	incbin	f:\music.mid\tocatta.mid
;music_data:	incbin	f:\music.mid\ordinary.mid
;music_data:	incbin	f:\music.mid\jazz07.mid
;music_data:	incbin	f:\music.mid\opus1.mid

		even

		section bss
channels_info:	DS.B	channel_ss*16
PatchLIST:	DS.B	Ptch_structsize*256
ch1s:		DS.B 	sam_vcsize*no_voices
Mtrk_structs:	DS.B	MAX_TRACKS*Mtrk_structsize
		
buffer:		ds.b	1500000
