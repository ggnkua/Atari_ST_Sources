;-----------------------------------------------------------------------;
; ProTracker Replay (Falcon030)						;
; by Griff of Electronic Images. 	2				;
;-----------------------------------------------------------------------;

; The Rot-file calls...

; Rotfile+0 - autoselect NTSC/PAL depending on $ff820a (50/60hz)
;
; Rotfile+4 - autoselect ste/ym2149 soundchip and setup appropriate chip.
;
; Rotfile+8  
; Call this ONCE per vbl.(The Sequencer and ST bits)
;
; Rotfile+12   
; D0=Tune Number (if D0=0 then music is turned OFF.(just volume off)
; D1=fadein/fadeout speed value(count) if D1=0 then no fade in or out!
; (note that all interrupts are now ON, so call that sequencer in you vbl!)

; Rotfile+16
; Turns off the ST interrupts or STE dma. I.E stops the music completely.
; (you should call this after the music has faded out)

; Rotfile+20
; LongWord Value - offset from START off rotfile to Volume fade bit-flag.
; E.G      	LEA rotfile(PC),A0 
; 	        ADD.L 20(A0),A0		
;.wait  	BTST #0,(A0)			; has it faded down?
;          	BNE.S .wait			; wait till it has!

		output d:\coding\vm\mayhem.mus

assemble_rot	EQU 1

cbufsize	EQU $1800

		IFEQ assemble_rot

lets_test_it	CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		MOVE #$2700,SR
		LEA old_stuff(PC),A0									;
		MOVE.B $FFFFFA07.W,(A0)+	
		MOVE.B $FFFFFA09.W,(A0)+	; Save mfp registers 
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+ 	
		MOVE.L $70.W,(A0)+
		CLR.B $fffffa07.W
		CLR.B $fffffa09.W		
		CLR.B $fffffa13.W		; kill it
		CLR.B $fffffa15.W
		LEA my_vbl(PC),A0
		MOVE.L A0,$70.W			; our own little vbl.
		BSR flush
		MOVE #$2300,SR
		BSR rotfile			; autoselect NTSC/PAL
		BSR rotfile+4			; autoselect soundchip
		MOVEQ #3,D0			; 
		MOVEQ #0,D1			; no fade in
		BSR rotfile+12			; go!

waitk		BTST.B #0,$FFFFFC00.W
		BEQ.S waitk
		MOVE.B $fffffc02.w,D0
		CMP.B #$39+$80,D0		; wait for spacebar
		BNE.S waitk

;.out		MOVEQ #0,D0			; tell driver to 
;		MOVEQ #0,D1			; fade down music
;		BSR rotfile+12

;		LEA rotfile(PC),A0 
;	        ADD.L 20(A0),A0			; addr of fade variable
;.wait     	BTST #0,(A0)			; has it faded down?
;	        BNE.S .wait			; wait till it has!

		BSR rotfile+16			; stop those timer ints!

		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W		; and vbl..
		BSR flush
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1
OLDRES		DC.W 0

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

old_stuff	DS.L 2

; The vbl - calls sequencer and vbl filler

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		NOT.L $FFFF9800.W
		NOT.W $FFFF8240.W
		BSR rotfile+8			; call sequencer
		NOT.W $FFFF8240.W
		NOT.L $FFFF9800.W
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE
	
		ENDC

;
; Protracker player.
;

;		OPT P+		; must be position independent

rotfile		BRA.W Init_PAL_or_NTSC		;0
		BRA.W SetUpSoundChip		;4	
		BRA.W Vbl_play			;8
		BRA.W Init_ST			;12
		BRA.W stop_ints			;16
		DC.L vol_bitflag-rotfile	;20
ste_override	DC.W 0

Init_PAL_or_NTSC
		RTS

; Initialise Music Sequencer and ST Specific bits (e.g interrupts etc.)
; D0=0 then turn music OFF. D1=0 straight off else d1=fadeOUT speed.
; D0=1 then turn music ON.  D1=0 straight on else d1=fadeIN speed.

Init_ST		LEA vol_bitflag(PC),A0	
		BSET #0,(A0)		; still fading.
		LEA fadeINflag(PC),A0
		SF (A0)			; reset fade IN flag 
		LEA fadeOUTflag(PC),A0
		SF (A0)			; reset fade OUT flag
		TST.B D0		
		BNE.S .init_music

; Deinitialise music - turn off/fade out.

.deinit_music	TST.B D1		; any fade down?
		BNE.S .trigfadedown
		LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; turn off music
		RTS
.trigfadedown	LEA fadeOUTflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		RTS

; Initialise music - turn on/fade in.

.init_music	TST.B D1
		BNE.S .trigfadein
		LEA global_vol(PC),A0
		MOVE.W #$40,(A0) 	; assume no fade in.
		BSR mt_init
		BRA STspecific
.trigfadein	LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; ensure zero to start with!
		LEA fadeINflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		BSR mt_init
		BRA STspecific

SetUpSoundChip	BRA Init_Voltab

; ST specific initialise. 

STspecific:	LEA music_on(PC),A0
		SF (A0)
		BSR makefrqtab
		BSR Init_Buffer
		LEA dummy(PC),A1
		LEA buffer(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		BSR initvoice
		LEA ch2s(pc),A0
		BSR initvoice
		LEA ch3s(pc),A0
		BSR initvoice
		LEA ch4s(pc),A0
		BSR initvoice
		BSR start_ints
		LEA dma_go(PC),A0
		ST (A0)
		LEA music_on(PC),A0
		ST (A0)
.nostartdma	RTS

; Create the Frequency lookup table.

makefrqtab:	LEA freqtabs(PC),A0
		MOVEQ #$30,D1 
		MOVE.W #$36F,D0
.lp		MOVE.L freqconst(pc),D2 
		DIVU.L D1,D2
		MOVE.L D2,(A0)+
		ADDQ.W #1,D1 
		DBF D0,.lp
		RTS 
freqtab		DS.W 96
freqtabs	DS.W 1760

; Make sure Volume lookup table is on a 256 byte boundary.

Init_Voltab	LEA vols+16640,A0
		MOVEQ #$40,D0 
.lp1		MOVE.W #$FF,D1 
.lp2		MOVE.W D1,D2 
		EXT.W D2
		MULS D0,D2 
		ASR.L #7,D2
		MOVE.B D2,-(A0)
		DBF D1,.lp2
		DBF D0,.lp1
		RTS 

; Clear play buffer

Init_Buffer	LEA buffer+cbufsize(PC),A0
		MOVEQ.L #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,A1
		MOVE #(cbufsize/128)-1,D7
.lp		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,.lp
		RTS

; A0-> voice data (paula voice) to initialise.

initvoice:	MOVE.L A2,vcaddr(A0)
		MOVE.L D0,endoffy(A0)
		MOVE.W D0,suboffy(A0)
		MOVE.W D0,curoffywhole(A0)
		MOVE.W D0,curoffy_frac(A0)
		MOVE.L A1,aud_addr(A0)
		MOVE.W D0,aud_len(A0)
		MOVE.W D0,aud_per(A0)
		MOVE.W D0,aud_vol(A0)
		RTS

; Save mfp vects that are used and trigger our interrupts.

start_ints	LEA buffer(PC),A1
		LEA buff_ptr(PC),A0
		MOVE.L A1,(A0)
.ste		RTS
		
; Turn off the music i.e restore old interrupts and clear soundchip.

stop_ints	LEA music_on(PC),A0		
		SF (A0)				; signal music off.
		MOVE.B #0,$FFFF8901.W		; nop kill STE dma.
		RTS

; Set STE dma to start and end of circular buffer.

Set_DMA		LEA temp(PC),A6			
		LEA buffer(PC),A0		
		MOVE.L A0,(A6)			
		MOVE.B 1(A6),$ffff8903.W
		MOVE.B 2(A6),$ffff8905.W	; set start of buffer
		MOVE.B 3(A6),$ffff8907.W
		LEA endbuffer(PC),A0
		MOVE.L A0,(A6)
		MOVE.B 1(A6),$ffff890f.W
		MOVE.B 2(A6),$ffff8911.W	; set end of buffer
		MOVE.B 3(A6),$ffff8913.W
		RTS
temp		DC.L 0

; Various variables.

vol_bitflag	DC.W 0
global_vol	DC.W 0
fadeOUTflag	DC.B 0
fadeOUTcurr	DC.B 0
fadeOUTspeed	DC.B 0
fadeINflag	DC.B 0
fadeINcurr	DC.B 0
fadeINspeed	DC.B 0
saved4		DS.L 1
dma_go		DS.W 1
buffer		DS.B cbufsize	; circular(ring) buffer
endbuffer	DC.L -1
buff_ptr 	DC.L 0		; last pos within ring buffer
lastwrt_ptr	DC.L 0
music_on	DC.B 0		; music on flag
		EVEN
freqconst	DC.L 0

		RSRESET
vcaddr		RS.L 1
endoffy		RS.L 1
suboffy		RS.W 1
curoffywhole	RS.W 1
curoffy_frac	RS.W 1
aud_addr	RS.L 1
aud_len		RS.W 1
aud_per		RS.W 1
aud_vol		RS.W 1

ch1s
wiz1lc		DC.L buffer
wiz1len		DC.L 0
wiz1rpt		DC.W 0
wiz1pos		DC.W 0
wiz1frc		DC.W 0
ch1t
aud1lc		DC.L dummy
aud1len		DC.W 0
aud1per		DC.W 0
aud1vol		DC.W 0
		DS.W 3

ch2s
wiz2lc		DC.L buffer
wiz2len		DC.L 0
wiz2rpt		DC.W 0
wiz2pos		DC.W 0
wiz2frc		DC.W 0
ch2t
aud2lc		DC.L dummy
aud2len		DC.W 0
aud2per		DC.W 0
aud2vol		DC.W 0
		DS.W 3

ch3s
wiz3lc		DC.L buffer
wiz3len		DC.L 0
wiz3rpt		DC.W 0
wiz3pos		DC.W 0
wiz3frc		DC.W 0
ch3t
aud3lc		DC.L dummy
aud3len		DC.W 0
aud3per		DC.W 0
aud3vol		DC.W 0
		DS.W 3

ch4s
wiz4lc		DC.L buffer
wiz4len		DC.L 0
wiz4rpt		DC.W 0
wiz4pos		DC.W 0
wiz4frc		DC.W 0
ch4t
aud4lc		DC.L dummy
aud4len		DC.W 0
aud4per		DC.W 0
aud4vol		DC.W 0
		DS.W 3

shfilter	DC.W 0
dmactrl		DC.W 0
dummy		DC.L 0,0,0,0


;-------------------------------------------------------------------------
;                            Vbl player
;-------------------------------------------------------------------------

dmamask		DC.W 0
Vbl_play:	LEA music_on(PC),A0
		TST.B (A0)			; music on?
		BEQ skipit			; if not skip all!
.do_fadein	LEA fadeINflag(PC),A0
		TST.B (A0)			; are we fadeing down?
		BEQ.S .nofadein
		SUBQ.B #1,1(A0)			; curr count-1
		BNE.S .nofadein
		MOVE.B 2(A0),1(A0)		; reset count
		LEA global_vol(PC),A1
		CMP #$40,(A1)			; reached max?
		BLT.S .notinyet
		SF (A0)				; global vol=$40!
		LEA vol_bitflag(PC),A1
		BCLR #0,(A1)			; signal fade done
		BRA.S .nofadein
.notinyet	ADDQ #1,(A1)			; global vol+1
.nofadein
.do_fadedown	LEA fadeOUTflag(PC),A0
		TST.B (A0)			; are we fadeing down?
		BEQ.S .nofadedown
		SUBQ.B #1,1(A0)			; curr count-1
		BNE.S .nofadedown
		MOVE.B 2(A0),1(A0)		; reset count
		LEA global_vol(PC),A1
		TST.W (A1)
		BNE.S .notdownyet
		SF (A0)				; global vol=0!
		LEA vol_bitflag(PC),A1
		BCLR #0,(A1)			; signal fade done
		BRA.S .nofadedown
.notdownyet	SUBQ #1,(A1)			; global vol-1
.nofadedown	

; STE playback main section

STE_read	MOVE.B dma_go(PC),D0
		TST.B D0
		BEQ.S .ok
		MOVE.B #0,$FFFF8901.W
.ok		BSR Set_DMA
		MOVE.B dma_go(PC),D0
		TST.B D0
		BEQ.S STEitson
		MOVE.B dmamask(PC),$FFFF8921.W
		MOVE.B #3,$FFFF8901.W	  	; start STE dma.
		LEA dma_go(PC),A0
		SF (A0)
STEitson	LEA $FFFF8909.W,A0
.read		MOVEP.L 0(A0),D0		; major design flaw in ste
		DCB.W 15,$4E71			; h/ware we must read the
		MOVEP.L 0(A0),D1		; frame address twice
		LSR.L #8,D0			; since it can change
		LSR.L #8,D1			; midway thru a read!
		CMP.L D0,D1			; so we read twice and
		BNE.S .read			; check the reads are the same
.notwrap	MOVE.L buff_ptr(PC),A4
		MOVE.L A4,lastwrt_ptr
		MOVE.L D0,buff_ptr
		CMP.L D0,A4
		BEQ skipit
.dovoices13	LEA ch1s(PC),A0
		LEA ch3s(PC),A2
		MOVE.W #0,bufoff
		BSR Dotwochans
.dovoices24	LEA ch2s(PC),A0
		LEA ch4s(PC),A2
		MOVE.W #1,bufoff
		BSR Dotwochans
.skipit		BSR mt_music
skipit		RTS

tune_table	DC.L mt_data1
		DC.L $8EFE3B*25/8
		DC.L $8EFE3B/2
		DC.B 76
		DC.B %00000011
		DC.W 0
.tune2		DC.L mt_data2
		DC.L $8EFE3B*25/8
		DC.L $8EFE3B/2
		DC.B 76
		DC.B %00000011
		DC.W 0
.tune3		DC.L mt_data3
		DC.L $8EFE3B*25/13
		DC.L $8EFE3B/2
		DC.B 47
		DC.B %00000011
		DC.W 0
.tune4		DC.L mt_data4
		DC.L $8EFE3B*25/12
		DC.L $8EFE3B/2
		DC.B 51
		DC.B %00000011
		DC.W 0


;********************************************  ; 100% FIXED VERSION
;* ----- Protracker V1.1B Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1991  *
;* Bekkeliveien 10, N-2010 STRØMMEN, Norway *
;********************************************

n_note		EQU	0  ; W
n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; B
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

; Initialise music.
; D0 = tune no.

mt_init	LEA freqconst(PC),A2
	LEA tune_table(PC),A3
	SUBQ #1,D0			; tune no.-1
	LSL.W #4,D0			; *16
	MOVE.L (A3,D0.W),A0		; fetch module ptr
.is_ste	MOVE.L 8(A3,D0.W),(A2)		; freqconst ste
	MOVE.B 13(A3,D0.W),dmamask
.go	MOVE.L	A0,mt_SongDataPtr
	LEA mt_SampleStarts(PC),A1
	MOVE.L A0,A3
	MOVEQ #31-1,D0
mtloop3	MOVE.L $26(A0),A2		; get sample offset
	ADD.L A3,A2			; add base of module
	MOVE.L	A2,(A1)+		; store sample address
	LEA 30(A0),A0
	DBRA D0,mtloop3
	MOVEQ #0,D0
	MOVE.B #6,mt_speed
	MOVE.B D0,mt_counter
	MOVE.B D0,mt_SongPos
	MOVE.B D0,mt_PBreakPos	
	MOVE.B D0,mt_PosJumpFlag	
	MOVE.B D0,mt_PBreakFlag	
	MOVE.B D0,mt_LowMask	
	MOVE.B D0,mt_PattDelTime	
	MOVE.B D0,mt_PattDelTime2	
	MOVE.B D0,mt_PattDelTime2+1
	MOVE.W D0,mt_DMACONtemp	
	MOVE.W D0,mt_PatternPos
	MOVE.W D0,dmactrl
	RTS

mt_music
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	ch1t(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch2t(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch3t(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch4t(PC),A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PatternPos(PC),D1
	CLR.W	mt_DMACONtemp

	LEA	ch1t(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch2t(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch3t(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch4t(PC),A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR	mt_PerNop
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ.S	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
	BRA.S	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D7
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.S	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D7,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	MOVE.W	n_dmabit(A6),dmactrl
	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),(A5)	; Set start
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		; Set period
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.W	mt_DMACONtemp(PC),D0
	movem.l d1/d2,-(Sp)

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	mt_chan1temp+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	mt_chan2temp+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	mt_chan3temp+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	mt_chan4temp+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4
	movem.l (sp)+,d1/d2

mt_dskip
	ADD.W	#16,mt_PatternPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16,mt_PatternPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
mt_nnpysk
	CMP.W	#1024,mt_PatternPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE.S	mt_NextPosition
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return2
	RTS

mt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D7
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS.S	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D7,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return2
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.W	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound			
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	0(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	0(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,8(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ.S	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ.S	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	BRA	mt_PerNop

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ASL.B	#1,D0
	AND.B	#$FD,shfilter
	OR.B	D0,shfilter
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return2
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	NOP
;	MOVE.W	n_dmabit(A6),dmactrl	; Channel DMA off
;	MOVE.L	n_start(A6),(A5)	; Set sampledata pointer
;	MOVE.W	n_length(A6),4(A5)	; Set length
;	MOVE.W	n_dmabit(A6),D0
;	BSET	#15,D0
;	MOVE.W	D0,dmactrl
;
;	MOVE.L	n_loopstart(A6),(A5)
;	MOVE.L	n_replen(A6),4(A5)

mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return2
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter,D0
	BNE	mt_Return2
	MOVE.W	(A6),D0
	BEQ	mt_Return2
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return2
mt_UpdateFunk
	MOVEM.L	D1/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,D1/A0
	RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

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

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr	dc.l 0

mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0,0
mt_PatternPos	dc.w 0
mt_DMACONtemp	dc.w 0

; Generate two channels - in ring buffer.

Dotwochans	MOVE.L lastwrt_ptr(PC),A4
		MOVE.L buff_ptr(PC),D0
		SUB.L A4,D0		
		BGT.S .cse1
.cse2		MOVE.L #endbuffer,D0		
		SUB.L A4,D0
		BSR gen2channels
		MOVE.L buff_ptr(PC),D0
		LEA buffer(PC),A4
		SUB.L A4,D0
.cse1		BSR gen2channels
		RTS

bufoff		DC.W 0

; Create two channels of data. (d0 contains no. of bytes to make.)

gen2channels	ADD.W bufoff(PC),A4
		LSR.W #1,D0
		MOVE.W D0,D5
		SUBQ #1,D5
		BMI .done
		SWAP D5
		LEA freqtab(PC),A3
		MOVEM.L A0/A2,-(SP)
.vc2		MOVEQ #0,D4
		MOVE.W curoffywhole(A2),D4
		MOVE.W curoffy_frac(A2),D5
		MOVE.L vcaddr(A2),A6
		MOVEM.W aud_per(A2),D6/D7	; freq(amiga period)/vol
		ADD.W D6,D6
		ADD.W D6,D6
		MOVEM.W 0(A3,D6.W),D6/A2    	; freq whole.w/freq frac.w
		MULU global_vol,D7
		LSR #6,D7
		EXT.L D7
		ASL.W #8,D7
		ADD.L #vols,D7			; -> volumetable 
		MOVE.L D7,A5
.vc1		MOVEQ #0,D0
		MOVE.W curoffywhole(A0),D0
		MOVE.W curoffy_frac(A0),D1
		MOVE.L vcaddr(A0),A1
		MOVEM.W aud_per(A0),D2/D3	; freq(amiga period)/vol
		ADD.W D2,D2
		ADD.W D2,D2
		MOVEM.W 0(A3,D2.W),D2/A3    	; freq whole.w/freq frac.w
		MULU global_vol,D3
		LSR #6,D3
		EXT.L D3
		ASL.W #8,D3
		ADD.L #vols,D3			; -> volumetable 
		LEA (A4),A0
		MOVE.L D3,A4
		MOVEQ #0,D3
		SWAP D5
.lp		SWAP D5	
		ADD.W A3,D1
		ADDX.W D2,D0
		ADD.W A2,D5			; shift freq	
		ADDX.W D6,D4	
		MOVE.B (A1,D0.L),D3
		MOVE.B (A4,D3.W),D7		; first byte(volume converted)
		MOVE.B (A6,D4.L),D3
		ADD.B (A5,D3.W),D7		; +second byte(volume converted) 
		SWAP D5
		MOVE.B D7,(A0)+			; store
		ADDQ.W #1,A0
		DBF D5,.lp
.jmphere	MOVEM.L (SP)+,A0/A2
		CMP.L endoffy(A0),D0
		BLT.S .ok1
		SUB.W suboffy(A0),D0
.ok1		MOVE.W D0,curoffywhole(A0)
		MOVE.W D1,curoffy_frac(A0)
		CMP.L endoffy(A2),D4
		BLT.S .ok2
		SUB.W suboffy(A2),D4
.ok2		MOVE.W D4,curoffywhole(A2)
		MOVE.W D5,curoffy_frac(A2)
.done		RTS

vols		DS.B 16640

		section data

mt_data1	incbin	ingame.moP
mt_data2	incbin	HEAVHELL.MOP
mt_data3	incbin	sympathy.mop
mt_data4	incbin	fullyan.moP
