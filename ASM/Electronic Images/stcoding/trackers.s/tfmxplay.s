;-----------------------------------------------------------------------;
; TFMX Replay (ST/STE)							;
; (using paula emu v2.0!)						;
; by Griff of Electronic Images. 30/04/1992				;
;-----------------------------------------------------------------------;

; The Rot-file calls...

; Rotfile+0 - autoselect NTSC/PAL depending on $ff820a (50/60hz)
;
; Rotfile+4  
; Call this ONCE per vbl.(The Sequencer and ST bits)
;
; Rotfile+8   
; D0=Tune Number (if D0=0 then music is turned OFF.)
; D1=fadein/fadeout speed value(count) if D1=0 then no fade in or out!
; (note that all interrupts are now ON, so call that sequencer in you vbl!)

; Rotfile+12
; This turns off the ST interrupts and de-inits the soundchip.
; (you should call this after the music has faded out)

; Rotfile+16
; LongWord Value - offset from START off rotfile to Volume fade bit-flag.
; E.G      	LEA rotfile(PC),A0 
; 	        ADD.L 16(A0),A0		
;.wait  	BTST #0,(A0)			; has it faded down?
;          	BNE.S .wait			; wait till it has!

T2_Tune:	Equ	0   		; Start Tune Number [0-?]
T2_Mod:		Equ	7+1		; Number Of Tunes In Mod+1


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

		MOVE.L #init_tfmx1,rotfile+20	; setup for tfmx
		MOVE.L #Play_T2,rotfile+24	;
		BSR rotfile			; autoselect NTSC/PAL
		MOVEQ #0,D1
		BSR rotfile+8			; go!

waitk		BTST.B #0,$FFFFFC00.W
		BEQ.S waitk
		MOVE.B $fffffc02.w,D0
		CMP.B #$39+$80,D0		; wait for spacebar
		BNE.S waitk

;.out		MOVEQ #0,D0			; tell driver to 
;		MOVEQ #0,D1			; fade down music
;		BSR rotfile+8

;		LEA rotfile(PC),A0 
;	        ADD.L 16(A0),A0			; addr of fade variable
;.wait     	BTST #0,(A0)			; has it faded down?
;	        BNE.S .wait			; wait till it has!

		BSR rotfile+12			; stop those timer ints!

		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W		; and vbl..
		MOVE.L #$00000666,$FFFF8240.W
		MOVE.L #$06660666,$FFFF8244.W
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
		;MOVE.W #$300,$FFFF8240.W
		BSR rotfile+4			; call sequencer
		;MOVE.W #$000,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE

init_tfmx1	Lea T2_Song,a0
		Move.l	a0,d0
		Lea T2_Smpl,a0
		Move.l	a0,d1
		Bsr T2_Replay+$14
		Bsr T2_Replay+$8
		Moveq	#T2_Tune,d0		; Tune Number
		Bra T2_Replay+$c


;
; The Paula Emu v2.0
;

;		OPT P+		; must be position independent

rotfile		BRA.W Init_PAL_or_NTSC
		BRA.W Vbl_play
		BRA.W Init_ST
		BRA.W stop_ints
		DC.L vol_bitflag-rotfile
init_ptr	DC.L 0
play_ptr	DC.L 0

		DC.B "ST/STE/TT Digi-Driver "
		DC.B "By Martin Griffiths(aka Griff of Inner Circle),"
		EVEN

speed		EQU 38    			; timer d (17KHZ)

; Select PAL/NTSC

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
		MOVE.L init_ptr(PC),A0
		JSR (A0)

		BRA STspecific
.trigfadein	LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; ensure zero to start with!
		LEA fadeINflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		MOVE.L init_ptr(PC),A0
		JSR (A0)
		BRA STspecific

vol_bitflag	DC.W 0
global_vol	DC.W 0
fadeOUTflag	DC.B 0
fadeOUTcurr	DC.B 0
fadeOUTspeed	DC.B 0
fadeINflag	DC.B 0
fadeINcurr	DC.B 0
fadeINspeed	DC.B 0

		EVEN

; Paula emulation storage structure.

		RSRESET
sam_start	RS.L 1				; sample start
sam_length	RS.W 1				; sample length
sam_period	RS.W 1				; sample period(freq)
sam_vol		RS.W 1				; sample volume
sam_lpstart	RS.L 1				; sample loop start
sam_lplength	RS.W 1	 			; sample loop length
sam_vcsize	RS.B 1				; structure size.

basespeed	DC.W 0

ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize			; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize
shadow_dmacon	DS.W 1
shadow_dff09a	DS.W 1
shadow_dff09c	DS.W 1
saved4		DS.L 1
freqconst	DS.L 1

; Macro to move parameter '\1' into the shadow dma register...
; (Remember - bit 15 of 'dmacon' determines clearing or setting of bits!)

move_dmacon	MACRO
.setdma\@	MOVE.W D4,saved4		; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dmacon		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dmacon		; not zero so set 'em
.dmacon_set\@	MOVE.W saved4,D4		; restore D4
		ENDM

move_dff09a	MACRO
.setdma\@	MOVE.W D4,saved4			; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dff09a		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dff09a		; not zero so set 'em
.dmacon_set\@	MOVE.W saved4,D4			; restore D4
		ENDM

move_dff09c	MACRO
.setdma\@	MOVE.W D4,saved4		; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dff09c		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dff09c		; not zero so set 'em
.dmacon_set\@	MOVE.W saved4,D4			; restore D4
		ENDM

; Vbl player - This is THE  'Paula' Emulator.

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
		MOVE.L buff_ptr(PC),A4		; A4 points to place to fill
		LEA ste_flag(PC),A0
		TST.B (A0)
		BEQ.S .ST_read
.STE_read	BSR Set_DMA
		LEA $FFFF8909.W,A0
		MOVEP.L (A0),D0			; read frame count(ste)
		LSR.L #8,D0
		BRA.S .norm
.ST_read	MOVE.L USP,A0			; read frame count(st)
		MOVE.L A0,D0			; current pos in buffer
.norm		LEA endbuffer(PC),A0
		CMP.L A0,D0
		BNE.S .notwrap
		LEA buffer(PC),A0		; slight fuckup adjust
		MOVE.L A0,d0			; case(speed)
.notwrap	LEA buff_ptr(PC),A0
		MOVE.L D0,(A0)
		SUB.L A4,D0
		BEQ skipit
		BHI.S higher
		ADDI.W #$1000,D0		; abs
higher		LSR.W #1,D0
		LEA endbuffer(PC),A0
		MOVE.L A0,D1
		SUB.L A4,D1
		LSR.W #1,D1
		LEA fillx1(PC),A0
		CLR.W (A0)			; assume no buf overlap
		CMP.W D1,D0			; check for overlap
		BCS.S higher1
		MOVE.W D1,(A0)			; ok so there was overlap!!
higher1		SUB.W (A0),D0			; subtract any overlap
		MOVE.W D0,2(A0)			; and store main
		PEA (A4)
		MOVE.L play_ptr(PC),A0
		JSR (A0)
		MOVE.L (SP)+,A4

		LEA.L Voice1Set(PC),A0		; Setup Chan 1
		LEA.L ch1s(PC),A5
		MOVEQ #0,D4
		BSR SetupVoice		
		LEA.L Voice2Set(PC),A0		;      "     2
		LEA.L ch2s(PC),A5
		MOVEQ #1,D4
		BSR SetupVoice		
		LEA.L Voice3Set(PC),A0  	;      "     3
		LEA.L ch3s(PC),A5
		MOVEQ #2,D4
		BSR SetupVoice
		LEA.L Voice4Set(PC),A0  	;      "     4
		LEA.L ch4s(PC),A5
		MOVEQ #3,D4
		BSR SetupVoice
		BSR Goforit
skipit		RTS

		RSRESET
Vaddr		RS.L 1
Vfrac		RS.W 1
Voffy		RS.W 1
Vfreq		RS.L 1				; structure produced
Vvoltab		RS.W 1				; from 'paula' data
Vlpaddr		RS.L 1
Vlpoffy		RS.W 1
Vlpfreq		RS.L 1

; Routine to add/move one voice to buffer. The real Paula emulation part!!

SetupVoice	MOVE.L sam_start(A5),A2		; current sample end address(shadow amiga!)
		MOVEM.W sam_length(A5),D0/D1/D2	; offset/period/volume
		CMP.W #$40,D2
		BLS.S .ok
		MOVEQ #$40,D2
.ok		MULU global_vol(PC),D2
		LSR #6,D2			; /64
		LSL.W #8,D2			; offset into volume tab
		EXT.L D1
		BEQ.S .zero
		MOVE.L freqconst(PC),D5 
		SWAP D5
		MOVEQ #0,D3 
		MOVE.W D5,D3 
		DIVU D1,D3 
		MOVE.W D3,D6 
		SWAP D6
		SWAP D5
		MOVE.W D5,D3 
		DIVU D1,D3 
		MOVE.W D3,D6 
		MOVE.L D6,D1

.zero		NEG.W D0			; negate sample offset
		MOVE.W shadow_dmacon(PC),D7
		BTST D4,D7
		BNE.S .vcon2
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2

.vcon2		LEA nulsamp+2(PC),A6
		CMP.L A6,A2
		BNE.S .vcon
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon		MOVE.L sam_lpstart(a5),A6	; loop addr
		MOVE.W sam_lplength(a5),D5	; loop length
		NEG.W D5			; negate it.
		MOVE.L D1,D7			; freq on loop
		CMP.W #-2,D5
		BNE.S isloop
.noloop		MOVEQ #0,D7			; no loop-no frequency
		LEA nulsamp+2(PC),A6		; no loop-point to nul
isloop		SWAP D1
		SWAP D7
		MOVE.L A2,(A0)+			; store address
		ADDQ.W #2,A0
		MOVE.W D0,(A0)+			; store offset
		MOVE.L D1,(A0)+			; store int.w/frac.w
		MOVE.W D2,(A0)+			; address of volume tab.
		MOVE.L A6,(A0)+			; store loop addr
		MOVE.W D5,(A0)+			; store loop offset.
		MOVE.L D7,(A0)+			; store loop freq int.w/frac.w
		RTS

; Make that buffer! (channels are paired together!)

Goforit		PEA (A4)			; save buff ptr
channels12	MOVE.L Voice1Set(PC),A0		; ptr to end of each sample!
		MOVE.L Voice2Set(PC),A1
		MOVE.L Voice1Set+Vfrac(PC),D0	; frac.w/int.w offset
		MOVE.L Voice2Set+Vfrac(PC),D1
		MOVE.L Voice1Set+Vfreq(PC),A2	; frac.w/int.w freq
		MOVE.L Voice2Set+Vfreq(PC),A3	
		MOVE.W fillx1(PC),D6	
		BSR add12			; fill first bit
		MOVE.W fillx2(PC),D6
		MOVE.W fillx1(PC),D4
		BEQ.S .nores
		LEA.L buffer(pc),A4		; (overlap case)
.nores		BSR add12			; and do remaining
		LEA ch1s(PC),A5
		LEA Voice1Set(PC),A4
		NEG.W D0			; +ve offset(as original!)
		MOVE.L A0,sam_start(A5)		; store voice address
		MOVE.W D0,sam_length(A5)	; store offset for next time
		SWAP D0
		MOVE.W D0,Vfrac(A4)		; store frac part
		LEA ch2s(PC),A5
		LEA Voice2Set(PC),A4
		NEG.W D1		
		MOVE.L A1,sam_start(A5)		; same for chan 2
		MOVE.W D1,sam_length(A5)		
		SWAP D1
		MOVE.W D1,Vfrac(A4)
		MOVE.L (SP)+,A4

channels34	MOVE.L Voice3Set(PC),A0		; ptr to end of each sample!
		MOVE.L Voice4Set(PC),A1
		MOVE.L Voice3Set+Vfrac(PC),D0	; frac.w/int.w offset
		MOVE.L Voice4Set+Vfrac(PC),D1
		MOVE.L Voice3Set+Vfreq(PC),A2
		MOVE.L Voice4Set+Vfreq(PC),A3	; frac.w/int.w freq
		MOVE.W fillx1(PC),D6	
		BSR add34			; fill first bit
		MOVE.W fillx2(PC),D6
		MOVE.W fillx1(PC),D4
		BEQ.S .nores
		LEA.L buffer(pc),A4		; (overlap case)
.nores		BSR add34			; and do remaining
		LEA ch3s(PC),A5
		LEA Voice3Set(PC),A4
		NEG.W D0			
		MOVE.L A0,sam_start(A5)			
		MOVE.W D0,sam_length(A5)	; as above
		SWAP D0
		MOVE.W D0,Vfrac(A4)
		LEA ch4s(PC),A5
		LEA Voice4Set(PC),A4
		NEG.W D1		
		MOVE.L A1,sam_start(A5)			
		MOVE.W D1,sam_length(A5)		
		SWAP D1
		MOVE.W D1,Vfrac(A4)
		RTS

; Move channels 1 and 2 to the buffer.

add12		SUBQ #1,D6			; -1 (dbf)
		BMI exitadd12			; none to do!?
.make_chans1_2	MOVEQ #0,D4
		MOVE.L voltab_ptr(PC),D2
		MOVE.W Voice1Set+Vvoltab(PC),D4
		ADD.L D4,D2			; volume tab chan 1
		MOVE.L voltab_ptr(PC),D3
		MOVE.W Voice2Set+Vvoltab(PC),D4
		ADD.L D4,D3			; volume tab chan 2
		MOVEQ #0,D4
		MOVEQ #0,D5
		LEA ste_flag(PC),A6
		TST.B (A6)
		BNE.S make12_ste
make12lp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A5
		MOVE.B (A5),D4
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A5
		MOVE.B (A5),D5
		ADD.W D5,D4
		MOVE.W D4,(A4)+
		MOVEQ #0,D4
		ADD.L A2,D0
		ADDX D4,D0
		BGE.S lpvc1
contlp1		ADD.L A3,D1
		ADDX D4,D1
contlp2		DBGE D6,make12lp
		BGE.S lpvc2
exitadd12	RTS

lpvc1		MOVE.L Voice1Set+Vlpfreq(PC),A2
		MOVE.L Voice1Set+Vlpaddr(PC),A0		; loop voice 1
		ADD.W  Voice1Set+Vlpoffy(PC),D0		
		BRA.S contlp1

lpvc2		MOVE.L Voice2Set+Vlpfreq(PC),A3
		MOVE.L Voice2Set+Vlpaddr(PC),A1		;      "     2
		ADD.W  Voice2Set+Vlpoffy(PC),D1		
		BRA.S contlp2

make12_ste	MOVE.L SP,savesp12
		LEA (A4),SP
		MOVEQ #0,D7
make12_stelp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A5
		MOVE.B (A5),D4
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A5
		ADD.B (A5),D4
		MOVE.B D4,(SP)+
		ADD.L A2,D0
		ADDX D7,D0
		BGE.S lpvc1ste
contlp1ste	ADD.L A3,D1
		ADDX D7,D1
contlp2ste	DBGE D6,make12_stelp
		BGE lpvc2ste
		MOVE.L savesp12(PC),SP
		RTS
savesp12	DC.L 0

lpvc1ste	MOVE.L Voice1Set+Vlpfreq(PC),A2
		MOVE.L Voice1Set+Vlpaddr(PC),A0		; loop voice 1
		ADD.W  Voice1Set+Vlpoffy(PC),D0		
		BRA.W contlp1ste

lpvc2ste	MOVE.L Voice2Set+Vlpfreq(PC),A3
		MOVE.L Voice2Set+Vlpaddr(PC),A1		;      "     2
		ADD.W  Voice2Set+Vlpoffy(PC),D1		
		BRA.W contlp2ste

; Add channels 3 and 4 channels 1+2 and create soundchip buffer play.

add34		SUBQ #1,D6			; -1(dbf)
		BMI exitadd34			; none to do?
.make_chans3_4	MOVEQ #0,D4
		MOVE.L voltab_ptr(PC),D2
		MOVE.W Voice3Set+Vvoltab(PC),D4
		ADD.L D4,D2			; volume tab chan 3
		MOVE.L voltab_ptr(PC),D3
		MOVE.W Voice4Set+Vvoltab(PC),D4
		ADD.L D4,D3			; volume tab chan 4
		MOVEQ #0,D4
		MOVEQ #0,D5
		LEA ste_flag(PC),A6
		TST.B (A6)
		BNE.S make34_ste
make34lp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A5
		MOVE.B (A5),D4
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A5
		MOVE.B (A5),D5
		ADD.W D5,D4
		ADD.W D4,(A4)+
		MOVEQ #0,D4
		ADD.L A2,D0
		ADDX D4,D0
		BGE.S lpvc3
contlp3		ADD.L A3,D1
		ADDX D4,D1
contlp4		DBGE D6,make34lp
		BGE.S lpvc4
exitadd34	RTS

lpvc3		MOVE.L Voice3Set+Vlpfreq(PC),A2
		MOVE.L Voice3Set+Vlpaddr(PC),A0		; loop voice 3
		ADD.W  Voice3Set+Vlpoffy(PC),D0
		BRA.S contlp3

lpvc4		MOVE.L Voice4Set+Vlpfreq(PC),A3
		MOVE.L Voice4Set+Vlpaddr(PC),A1		;      "     4
		ADD.W  Voice4Set+Vlpoffy(PC),D1	
		BRA.S contlp4

make34_ste	MOVE.L SP,savesp34
		LEA 1(A4),SP		;A6/A4 free
		
		MOVEQ #0,D7
make34_stelp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A5
		MOVE.B (A5),D4
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A5
		ADD.B (A5),D4
		MOVE.B D4,(SP)+
		ADD.L A2,D0
		ADDX D7,D0
		BGE.S lpvc3ste
contlp3ste	ADD.L A3,D1
		ADDX D7,D1
contlp4ste	DBGE D6,make34_stelp
		BGE lpvc4ste
		MOVE.L savesp34(PC),SP
		RTS
savesp34	DC.L 0
lpvc3ste	MOVE.L Voice3Set+Vlpfreq(PC),A2
		MOVE.L Voice3Set+Vlpaddr(PC),A0		; loop voice 3
		ADD.W  Voice3Set+Vlpoffy(PC),D0
		BRA.W contlp3ste

lpvc4ste	MOVE.L Voice4Set+Vlpfreq(PC),A3
		MOVE.L Voice4Set+Vlpaddr(PC),A1		;      "     4
		ADD.W  Voice4Set+Vlpoffy(PC),D1	
		BRA.W contlp4ste

; YM 2149 interrupt - fucking bastard shite ST chip(designer cunts)

player		MOVE.L D0,-(SP)
		PEA (A0)
		MOVE.L USP,A0
		MOVE.W (A0)+,D0
		BMI.S .reset
.cont		MOVE.L A0,USP
		ADD.W D0,D0
		ADD.W D0,D0
		LEA $FFFF8800.W,A0
		MOVE.L sndtab(PC,D0),D0
		MOVEP.L D0,(A0)	
		MOVE.L (SP)+,A0
		MOVE.L (SP)+,D0
		RTE
.reset		LEA buffer(PC),A0
		MOVE.W (A0)+,D0
		BRA.S .cont
sndtab		INCBIN PLAYER.DAT\2CHANSND.TAB	

Voice1Set	DS.L 8
Voice2Set	DS.L 8		; voice data (setup from 'paula' data)
Voice3Set	DS.L 8
Voice4Set	DS.L 8

buffer		DS.L $400	; circular(ring) buffer
endbuffer	DC.L -1
		DS.L 4		; (in case!!)
nulsamp		DS.L 4		; nul sample
buff_ptr 	DC.L 0		; last pos within ring buffer
music_on	DC.B 0		; music on flag
ste_flag	DC.B 0		; STE flag!
fillx1		DC.W 0		; circular buffer
fillx2		DC.W 0		; amounts(main and wrap amounts)
voltab_ptr	DC.L 0		; ptr to volume table
initialval	DC.L 0
                   
; ST specific initialise - sets up shadow amiga registers etc

STspecific:	BSR Ste_Test
		;CLR.B ste_flag

.setfreq	MOVE.L #$8EFE3B,d0
		MOVE.B ste_flag(PC),D0
		BNE.S .okisste
		MOVE.L #$8EFE3B*25/16,D0
.okisste	MOVE.L D0,freqconst

		LEA nulsamp+2(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		BSR initvoice
		LEA ch2s(pc),A0
		BSR initvoice
		LEA ch3s(pc),A0
		BSR initvoice
		LEA ch4s(pc),A0
		BSR initvoice
		BSR Init_Voltab
		BSR Init_Buffer
		BSR start_ints
		LEA music_on(PC),A0
		ST (A0)
.nostartdma	RTS

; A0-> voice data (paula voice) to initialise.

initvoice:	MOVE.L	A2,sam_start(A0)    ; point voice to nul sample
		MOVE.W	#2,sam_length(A0)		
		MOVE.W	D0,sam_period(A0)   ; period=0
		MOVE.W	D0,sam_vol(A0)	    ; volume=0
		MOVE.L	A2,sam_lpstart(A0)  ; and loop point to nul sample
		MOVE.W	#2,sam_lplength(A0)
		RTS

; Save mfp vects that are used and install our interrupts.

start_ints	MOVE SR,-(SP)
		MOVE #$2700,SR
		LEA buffer(PC),A1
		LEA buff_ptr(PC),A0
		MOVE.L A1,(A0)
		LEA ste_flag(PC),A0
		TST.B (A0)
		BEQ.S Setup_YM2149
.Ste_Setup	LEA.L setsam_dat(PC),A6
		MOVE.W #$7ff,$ffff8924
		MOVEQ #3,D6
.mwwritx	
.mwwritx2	CMP.W #$7ff,$ffff8924
		BNE.S .mwwritx2			; setup the PCM chip
		MOVE.W (A6)+,$ffff8922
		DBF D6,.mwwritx
		CLR.B $FFFF8901.W
		BSR Set_DMA
		MOVE.B #%00000010,$FFFF8921.W 	; 12.5khz
		MOVE.B #3,$FFFF8901.W	  	; start STE dma.
.exitste	MOVE.W (SP)+,SR
		RTS

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
		
; Setup for ST (YM2149 replay via interrupts)

Setup_YM2149	LEA save_stuff(PC),A0		
		MOVE.L $110.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+	; save mfp we change
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA25.W,(A0)+
		BCLR.B #3,$fffffa17.W		; soft end of int
		BSET.B #4,$fffffa09.W		; enable timer d
		BSET.B #4,$fffffa15.W
		MOVE.B #0,$fffffa1d.W
		MOVE.B #speed,$fffffa25.W	; timer d speed
		MOVE.B #1,$fffffa1d.W
		LEA player(PC),A0
		MOVE.L A0,$110.W
		MOVE #$8800,A0
		MOVE.B #7,(A0)
		MOVE.B #$C0,D0
		AND.B (A0),D0
		OR.B #$38,D0			; init ym2149
		MOVE.B D0,2(A0)
		MOVE #$600,D0
.setup		MOVEP.W D0,(A0)
		SUB #$100,D0
		BPL.S .setup
		
		LEA buffer(PC),A1
		MOVE.L A1,USP
		MOVE.W (SP)+,SR
		RTS

; Turn off the music i.e restore old interrupts and clear soundchip.

stop_ints	LEA music_on(PC),A0		
		SF (A0)				; signal music off.
		MOVE SR,-(SP)
		MOVE #$2700,SR
		LEA ste_flag(PC),A0
		TST.B (A0)			; ST or STE turn off?
		BEQ.S killYM2149		; ST?
		MOVE.B #0,$FFFF8901.W		; nop kill STE dma.
		MOVE.W (SP)+,SR
		RTS
killYM2149	LEA save_stuff(PC),A0
		MOVE.L (A0)+,$110.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA15.W	; restore some shite
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE.W (SP)+,SR
		RTS

save_stuff	DS.L 4

; The STE test rout...

Ste_Test	MOVE.L 8.W,-(SP)		; save bus error vect
		BSR Do_Test			; do the test
		MOVE.L (SP)+,8.W		; restore bus error vect 
		RTS
Do_Test		LEA ste_flag(PC),A4
		ST (A4)				; assume STE
		LEA .stfound(PC),A0
		MOVE.L A0,8.W
		MOVE.B #0,$FFFF8901.W		; causes bus error on STs!
		MOVE.W #0,$FFFF8900.W		; causes bus error on STs!
		RTS
.stfound	PEA (A4)
		LEA ste_flag(PC),A4
		SF (A4)				; assume STE
		MOVE.L (SP)+,A4
		RTE

temp:		dc.l	0
setsam_dat:	dc.w	%0000000011010100  	;mastervol
		dc.w	%0000010010000110  	;treble
		dc.w	%0000010001000110  	;bass
		dc.w	%0000000000000001  	;mixer

; Make sure Volume lookup table is on a 256 byte boundary.

Init_Voltab	MOVE.L #vols+256,D0
		CLR.B D0
		MOVE.L D0,A0
		MOVE.L A0,voltab_ptr
		LEA 16640(A0),A0
		MOVE.B ste_flag(PC),D0
		BNE stevoltab
YMvoltab	MOVEQ #$40,D0 
.lp1		MOVE.W #$FF,D1 
.lp2		MOVE.W D1,D2 
		EXT.W D2
		MULS D0,D2
		ASR.L #6,D2
		EOR.B #$80,D2
		MOVE.B D2,-(A0)
		DBF D1,.lp2
		DBF D0,.lp1
		RTS 
stevoltab	MOVEQ #$40,D0 
.lp1		MOVE.W #$FF,D1 
.lp2		MOVE.W D1,D2 
		EXT.W D2
		MULS D0,D2 
		ASR.L #7,D2		;/$80 giving a 7 bit sample
		MOVE.B D2,-(A0)
		DBF D1,.lp2
		DBF D0,.lp1
		RTS 


Init_Buffer	LEA buffer+$1000(PC),A0
		MOVEQ.L #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,A1
		MOVEQ #($1000/128)-1,D7
.lp		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,.lp
		RTS

vols		DS.B 256
		DS.B 16640

; The player

Play_T2:	
Replay_T2:	Bsr.s	T2_Replay+$4
		Rts

	opt c-,o-

T2_Replay:	
  BRA     L00AA 
  BRA     L0000 
  BRA     L00AA 
  BRA     L00AB 
  BRA     L0095 
  BRA     L00B2 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L009E 
  BRA     L00AB 
  BRA     L00A0 
  BRA     L00A4 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
  RTS 
  DC.B   $0E,$EE
  BRA     L00AC 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
L0000:MOVEM.L A0-A6/D0-D7,-(A7) 
  LEA     L00B6(PC),A6
  MOVE.L  16(A6),-(A7)
  MOVE.W  56(A6),D0 
  BEQ.S   L0005 
;  move_dmacon d0 
  MOVEQ   #9,D1 
  BTST    #0,D0 
  BEQ.S   L0001 
  MOVE.W  D1,ch1s+sam_period
L0001:BTST    #1,D0 
  BEQ.S   L0002 
  MOVE.W  D1,ch2s+sam_period
L0002:BTST    #2,D0 
  BEQ.S   L0003 
  MOVE.W  D1,ch3s+sam_period
L0003:BTST    #3,D0 
  BEQ.S   L0004 
  MOVE.W  D1,ch4s+sam_period
L0004:CLR.W   56(A6)
L0005:TST.B   22(A6)
  BNE.S   L0006 
  BRA     L0008 
L0006:BSR     L0038 
  TST.B   14(A6)
  BMI.S   L0007 
  BSR   L000A 
L0007:LEA     L00B8(PC),A5
  MOVE.W  128(A5),ch1s+sam_period
  LEA     L00B9(PC),A5
  MOVE.W  128(A5),ch2s+sam_period
  LEA     L00BA(PC),A5
  MOVE.W  128(A5),ch3s+sam_period
  LEA     L00BB(PC),A5
  MOVE.W  128(A5),ch4s+sam_period
  TST.W   54(A6)
  BEQ.S   L0008 
;  move_dmacon 54(a6)
  CLR.W   54(A6)
L0008:MOVE.L  (A7)+,16(A6)
  MOVEM.L (A7)+,A0-A6/D0-D7 
L0009:RTS 
L000A:LEA     L00BC(PC),A5
  MOVEA.L 0(A6),A4
  SUBQ.W  #1,20(A6) 
  BPL.S   L0009 
  MOVE.W  6(A5),20(A6)
L000B:MOVEA.L A5,A0 
  CLR.B   13(A6)
  BSR.S   L000D 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  RTS 
L000C:ADDQ.L  #4,A0 
L000D:CMPI.B  #-$70,72(A0)
  BCS.S   L000E 
  CMPI.B  #-2,72(A0)
  BNE.S   L000F 
  ST      72(A0)
  MOVE.B  73(A0),D0 
  BRA     L009E 
L000E:LEA     L00BE(PC),A1
  ST      21(A1)
  TST.B   106(A0) 
  BEQ.S   L0010 
  SUBQ.B  #1,106(A0)
L000F:RTS 
L0010:MOVE.W  104(A0),D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 40(A0),A1 
  MOVE.L  0(A1,D0.W),16(A6) 
  MOVE.B  16(A6),D0 
  CMP.B   #-$10,D0
  BCC.S   L0013 
  MOVE.B  D0,D7 
  CMP.B   #-$40,D0
  BCC.S   L0011 
  CMP.B   #$7F,D0 
  BCS.S   L0011 
  MOVE.B  19(A6),106(A0)
  CLR.B   19(A6)
L0011:MOVE.B  73(A0),D1 
  ADD.B   D1,D0 
  CMP.B   #-$40,D7
  BCC.S   L0012 
  ANDI.B  #$3F,D0 
L0012:MOVE.B  D0,16(A6) 
  MOVE.L  16(A6),D0 
  BSR     L0095 
  CMP.B   #-$40,D7
  BCC.S   L0015 
  CMP.B   #$7F,D7 
  BCS.S   L0015 
  BRA     L001F 
L0013:ANDI.W  #$F,D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  JMP     L0014(PC,D0.W)
L0014:BRA     L0016 
  BRA     L0019 
  BRA     L001D 
  BRA     L001E 
  BRA     L0020 
  BRA     L0021 
  BRA     L0021 
  BRA     L0021 
  BRA     L0022 
  BRA     L0023 
  BRA     L0015 
  BRA     L0024 
  BRA     L0021 
  BRA     L0015 
  BRA     L0020 
L0015:ADDQ.W  #1,104(A0)
  BRA     L0010 
L0016:ST      72(A0)
  MOVE.W  4(A5),D0
  CMP.W   2(A5),D0
  BNE.S   L0017 
  MOVE.W  0(A5),4(A5) 
  BRA.S   L0018 
L0017:ADDQ.W  #1,4(A5)
L0018:BSR     L0025 
  ST      13(A6)
  RTS 
L0019:TST.B   74(A0)
  BEQ.S   L001A 
  CMPI.B  #-1,74(A0)
  BEQ.S   L001B 
  SUBQ.B  #1,74(A0) 
  BRA.S   L001C 
L001A:ST      74(A0)
  BRA.S   L0015 
L001B:MOVE.B  17(A6),D0 
  SUBQ.B  #1,D0 
  MOVE.B  D0,74(A0) 
L001C:MOVE.W  18(A6),104(A0)
  BRA     L0010 
L001D:MOVE.B  17(A6),D0 
  MOVE.B  D0,72(A0) 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 42(A6),A1 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,40(A0) 
  MOVE.W  18(A6),104(A0)
  BRA     L0010 
L001E:MOVE.B  17(A6),106(A0)
L001F:ADDQ.W  #1,104(A0)
  RTS 
L0020:ST      72(A0)
  RTS 
L0021:MOVE.L  16(A6),D0 
  BSR     L0095 
  BRA     L0015 
L0022:MOVE.L  40(A0),136(A0)
  MOVE.W  104(A0),168(A0) 
  MOVE.B  17(A6),D0 
  MOVE.B  D0,72(A0) 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 42(A6),A1 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,40(A0) 
  MOVE.W  18(A6),104(A0)
  BRA     L0010 
L0023:MOVE.L  136(A5),40(A5)
  MOVE.W  168(A5),104(A5) 
  BRA     L0015 
L0024:MOVE.B  18(A6),D1 
  ANDI.W  #7,D1 
  ADD.W   D1,D1 
  ADD.W   D1,D1 
  MOVE.B  17(A6),D0 
  MOVE.B  D0,72(A5,D1.W)
  MOVE.B  19(A6),73(A5,D1.W)
  ANDI.W  #$7F,D0 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 42(A6),A1 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,40(A5,D1.W)
  CLR.L   104(A5,D1.W)
  ST      74(A5,D1.W) 
  BRA     L0015 
L0025:MOVEM.L A0-A1,-(A7) 
L0026:MOVE.W  4(A5),D0
  LSL.W   #4,D0 
  MOVEA.L 38(A6),A0 
  ADDA.W  D0,A0 
  MOVEA.L 42(A6),A1 
  MOVE.W  (A0)+,D0
  CMP.W   #-$1002,D0
  BNE.S   L0028 
  MOVE.W  (A0)+,D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  JMP     L0027(PC,D0.W)
L0027:BRA     L002F 
  BRA     L0030 
  BRA     L0034 
  BRA     L002F 
  BRA     L0035 
L0028:MOVE.W  D0,72(A5) 
  BMI.S   L0029 
  CLR.B   D0
  LSR.W   #6,D0 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,40(A5) 
  CLR.L   104(A5) 
  ST      74(A5)
L0029:MOVEM.W (A0)+,D0-D6 
  MOVE.W  D0,76(A5) 
  BMI.S   L002A 
  CLR.B   D0
  LSR.W   #6,D0 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,44(A5) 
  CLR.L   108(A5) 
  ST      78(A5)
L002A:MOVE.W  D1,80(A5) 
  BMI.S   L002B 
  CLR.B   D1
  LSR.W   #6,D1 
  MOVE.L  0(A1,D1.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,48(A5) 
  CLR.L   112(A5) 
  ST      82(A5)
L002B:MOVE.W  D2,84(A5) 
  BMI.S   L002C 
  CLR.B   D2
  LSR.W   #6,D2 
  MOVE.L  0(A1,D2.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,52(A5) 
  CLR.L   116(A5) 
  ST      86(A5)
L002C:MOVE.W  D3,88(A5) 
  BMI.S   L002D 
  CLR.B   D3
  LSR.W   #6,D3 
  MOVE.L  0(A1,D3.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,56(A5) 
  CLR.L   120(A5) 
  ST      90(A5)
L002D:MOVE.W  D4,92(A5) 
  BMI.S   L002E 
  CLR.B   D4
  LSR.W   #6,D4 
  MOVE.L  0(A1,D4.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,60(A5) 
  CLR.L   124(A5) 
  ST      94(A5)
L002E:MOVEM.L (A7)+,A0-A1 
  RTS 
L002F:CLR.B   22(A6)
  MOVEM.L (A7)+,A0-A1 
  RTS 
L0030:TST.W   36(A6)
  BEQ.S   L0031 
  BMI.S   L0032 
  SUBQ.W  #1,36(A6) 
  BRA.S   L0033 
L0031:MOVE.W  #-1,36(A6)
  ADDQ.W  #1,4(A5)
  BRA     L0026 
L0032:MOVE.W  2(A0),D0
  SUBQ.W  #1,D0 
  MOVE.W  D0,36(A6) 
L0033:MOVE.W  (A0),4(A5)
  BRA     L0026 
L0034:MOVE.W  (A0),6(A5)
  MOVE.W  (A0),20(A6) 
  ADDQ.W  #1,4(A5)
  BRA     L0026 
L0035:ADDQ.W  #1,4(A5)
  LEA     L00BE(PC),A1
  TST.W   0(A1) 
  BNE     L0026 
  MOVE.W  #1,0(A1)
  MOVE.B  3(A0),31(A6)
  MOVE.B  1(A0),32(A6)
  MOVE.B  1(A0),33(A6)
  BEQ.S   L0036 
  MOVE.B  #1,15(A6) 
  MOVE.B  30(A6),D0 
  CMP.B   31(A6),D0 
  BEQ.S   L0037 
  BCS     L0026 
  NEG.B   15(A6)
  BRA     L0026 
L0036:MOVE.B  31(A6),30(A6) 
L0037:MOVE.B  #0,15(A6) 
  CLR.W   0(A1) 
  BRA     L0026 
L0038:LEA     L00B8(PC),A5
  BSR.S   L0039 
  LEA     L00B9(PC),A5
  BSR.S   L0039 
  LEA     L00BA(PC),A5
  BSR.S   L0039 
  LEA     L00BB(PC),A5
L0039:MOVEA.L 76(A5),A4 
  TST.B   0(A5) 
  BEQ.S   L003A 
  BPL     L0057 
L003A:TST.W   62(A5)
  BMI.S   L003B 
  SUBQ.W  #1,62(A5) 
  BRA.S   L003C 
L003B:CLR.B   60(A5)
  CLR.B   61(A5)
L003C:MOVE.L  124(A5),D0
  BEQ.S   L003D 
  CLR.L   124(A5) 
  CLR.B   60(A5)
  BSR     L0095 
  MOVE.B  61(A5),60(A5) 
L003D:TST.B   3(A5) 
  BEQ.S   L0040 
  MOVE.L  44(A5),D0 
  ADD.L   80(A5),D0 
  MOVE.L  D0,44(A5) 
  TST.W   94(A5)
  BEQ.S   L003E 
  MOVE.L  D0,88(A5) 
  BRA.S   L003F 

L003E:
  MOVE.L  D0,sam_start(A4) 
  MOVE.L  D0,sam_lpstart(A4) 

L003F:SUBI.B  #1,3(A5)
  BNE.S   L0040 
  MOVE.B  27(A5),3(A5)
  NEG.L   80(A5)
L0040:TST.W   94(A5)
  BEQ     L0049 
  MOVEA.L 88(A5),A0 
  MOVE.L  96(A5),D4 
  MOVE.L  108(A5),D5
  MOVEA.L 84(A5),A1 
  ADDA.L  8(A6),A1
  MOVE.W  94(A5),D7 
  MOVE.W  92(A5),D6 
  MOVE.B  106(A5),D3
  MOVEQ   #0,D0 
  MOVE.B  $00000043.L,D1
L0041:ADD.L   D5,D4 
  SWAP    D0
  ADD.L   D4,D0 
  SWAP    D0
  AND.W   D6,D0 
  MOVE.B  0(A0,D0.W),D2 
  TST.B   D3
  BEQ.S   L0045 
  CMP.B   D1,D2 
  BEQ.S   L0044 
  BGT.S   L0043 
  SUBX.B  D3,D1 
  BVS.S   L0044 
  CMP.B   D1,D2 
  BGE.S   L0044 
L0042:MOVE.B  D1,(A1)+
  DBF     D7,L0041
  BRA.S   L0046 
L0043:ADDX.B  D3,D1 
  BVS.S   L0044 
  CMP.B   D1,D2 
  BGT.S   L0042 
L0044:MOVE.B  D2,D1 
L0045:MOVE.B  D2,(A1)+
  DBF     D7,L0041
L0046:MOVE.B  D1,67(A5) 
  TST.B   D3
  BEQ.S   L0047 
  MOVE.W  116(A5),D0
  ADD.W   D0,106(A5)
  SUBQ.W  #1,112(A5)
  BNE.S   L0047 
  MOVE.W  114(A5),112(A5) 
  NEG.W   116(A5) 
L0047:MOVE.W  104(A5),D0
  EXT.L   D0
  ADD.L   D0,96(A5) 
  SUBQ.W  #1,100(A5)
  BNE.S   L0048 
  MOVE.W  102(A5),100(A5) 
  BEQ.S   L0048 
  NEG.W   104(A5) 
L0048:MOVE.W  118(A5),D0
  EXT.L   D0
  ADD.L   D0,108(A5)
  SUBQ.W  #1,120(A5)
  BNE.S   L0049 
  MOVE.W  122(A5),120(A5) 
  BEQ.S   L0049 
  NEG.W   118(A5) 
L0049:TST.B   38(A5)
  BEQ.S   L004C 
  MOVE.B  32(A5),D0 
  EXT.W   D0
  ADD.W   D0,36(A5) 
  MOVE.W  40(A5),D0 
  MOVE.W  36(A5),D1 
  BEQ.S   L004A 
  ANDI.L  #$FFFF,D0 
  ADDI.W  #$800,D1
  MULU    D1,D0 
  LSL.L   #5,D0 
  SWAP    D0
L004A:TST.W   48(A5)
  BNE.S   L004B 
  MOVE.W  D0,128(A5)
L004B:SUBQ.B  #1,39(A5) 
  BNE.S   L004C 
  MOVE.B  38(A5),39(A5) 
  EORI.B  #-1,32(A5)
  ADDQ.B  #1,32(A5) 
L004C:TST.W   48(A5)
  BEQ.S   L0050 
  SUBQ.B  #1,35(A5) 
  BNE.S   L0050 
  MOVE.B  34(A5),35(A5) 
  MOVE.W  40(A5),D1 
  MOVEQ   #0,D0 
  MOVE.W  50(A5),D0 
  CMP.W   D1,D0 
  BEQ.S   L004D 
  BCS.S   L004F 
  MOVE.W  #$100,D2
  SUB.W   48(A5),D2 
  MULU    D2,D0 
  LSR.L   #8,D0 
  CMP.W   D1,D0 
  BEQ.S   L004D 
  BCC.S   L004E 
L004D:CLR.W   48(A5)
  MOVE.W  40(A5),D0 
L004E:ANDI.W  #$7FF,D0
  MOVE.W  D0,50(A5) 
  MOVE.W  D0,128(A5)
  BRA.S   L0050 
L004F:MOVE.W  48(A5),D2 
  ADDI.W  #$100,D2
  MULU    D2,D0 
  LSR.L   #8,D0 
  CMP.W   D1,D0 
  BEQ.S   L004D 
  BCC.S   L004D 
  BRA.S   L004E 
L0050:TST.B   28(A5)
  BEQ.S   L0054 
  TST.B   29(A5)
  BEQ.S   L0051 
  SUBQ.B  #1,29(A5) 
  BRA.S   L0054 
L0051:MOVE.B  28(A5),29(A5) 
  MOVE.B  30(A5),D0 
  CMP.B   24(A5),D0 
  BGT.S   L0053 
  MOVE.B  31(A5),D1 
  SUB.B   D1,24(A5) 
  BMI.S   L0052 
  CMP.B   24(A5),D0 
  BGE.S   L0052 
  BRA.S   L0054 
L0052:MOVE.B  30(A5),24(A5) 
  CLR.B   28(A5)
  BRA.S   L0054 
L0053:MOVE.B  31(A5),D1 
  ADD.B   D1,24(A5) 
  CMP.B   24(A5),D0 
  BLE.S   L0052 
L0054:TST.B   15(A6)
  BEQ.S   L0055 
  SUBQ.B  #1,32(A6) 
  BNE.S   L0055 
  MOVE.B  33(A6),32(A6) 
  MOVE.B  15(A6),D0 
  ADD.B   D0,30(A6) 
  MOVE.B  31(A6),D0 
  CMP.B   30(A6),D0 
  BNE.S   L0055 
  CLR.B   15(A6)
  LEA     L00BE(PC),A0
  CLR.W   0(A0) 
L0055:MOVEQ   #0,D1 
  MOVE.B  30(A6),D1 
  MOVEQ   #0,D0 
  MOVE.B  24(A5),D0 
  BTST    #6,D1 
  BNE.S   L0056 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MULU    D1,D0 
  LSR.W   #8,D0 
L0056:MOVE.W  D0,sam_vol(A4)
L0057:TST.B   0(A5) 
  BEQ.S   L0058 
  BPL.S   L0059 
  TST.W   18(A5)
  BEQ.S   L005A 
  SUBQ.W  #1,18(A5) 
L0058:RTS 
L0059:CLR.W   16(A5)
  CLR.W   18(A5)
  ST      0(A5) 
  ST      26(A5)
  ST      1(A5) 
  move_dff09a 70(a5)
  move_dff09c 70(a5)
L005A:MOVEA.L 12(A5),A0 
  MOVE.W  16(A5),D0 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVE.L  0(A0,D0.W),16(A6) 
  MOVEQ   #0,D0 
  MOVE.B  16(A6),D0 
  CLR.B   16(A6)
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  JMP     L005B(PC,D0.W)
L005B:BRA     L005E 
  BRA     L0061 
  BRA     L0063 
  BRA     L0068 
  BRA     L0069 
  BRA     L006F 
  BRA     L0074 
  BRA     L0075 
  BRA     L007A 
  BRA     L0079 
  BRA     L0083 
  BRA     L007F 
  BRA     L0081 
  BRA     L0076 
  BRA     L0077 
  BRA     L0082 
  BRA     L0073 
  BRA     L0065 
  BRA     L0066 
  BRA     L005F 
  BRA     L0084 
  BRA     L0088 
  BRA     L0089 
  BRA     L007E 
  BRA     L008A 
  BRA     L008B 
  BRA     L006A 
  BRA     L006F 
  BRA     L006D 
  BRA     L006E 
  BRA     L006F 
  BRA     L0078 
  BRA     L005D 
  BRA     L005D 
  BRA     L008C 
  BRA     L008D 
  BRA     L008F 
  BRA     L0091 
  BRA     L0090 
  BRA     L0092 
  BRA     L0093 
  BRA     L0094 
L005C:ADDQ.W  #1,16(A5) 
  TST.B   1(A5) 
  ST      1(A5) 
  BPL     L005A 
  RTS 

L005D:ADDQ.W  #1,16(A5) 
  BRA     L005A 
L005E:CLR.B   28(A5)
  CLR.B   38(A5)
  CLR.W   48(A5)
  CLR.W   94(A5)
L005F:ADDQ.W  #1,16(A5) 
  MOVE.B  17(A6),1(A5)
  BNE.S   L0060 
  ST      1(A5) 
;  move_dmacon 22(a5) 
  BRA     L005A 
L0060:SUBQ.B  #1,1(A5)
  MOVE.W  22(A5),D0 
  OR.W    D0,56(A6) 
  RTS 

L0061:
  move_dff09a 70(a5)
  move_dff09c 70(a5)
  MOVE.W  16(A6),18(A5) 
  BEQ.S   L0062 
  BSR     L003D 


L0062:ADDQ.W  #1,16(A5) 
  MOVE.W  20(A5),D0 
  OR.W    D0,54(A6) 
  BRA     L005A 

L0063:CLR.B   3(A5) 
  MOVE.L  16(A6),D0 
  ADD.L   4(A6),D0
L0064:MOVE.L  D0,44(A5) 
  MOVE.L  D0,sam_start(A4) 
  MOVE.L  D0,sam_lpstart(A4) 

  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0065:MOVE.B  17(A6),3(A5)
  MOVE.B  17(A6),27(A5) 
  MOVE.W  18(A6),D1 
  EXT.L   D1
  MOVE.L  D1,80(A5) 
  MOVE.L  44(A5),D0 
  ADD.L   D1,D0 
  TST.W   94(A5)
  BEQ.S   L0064 
  MOVE.L  D0,44(A5) 
  MOVE.L  D0,88(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0066:MOVE.W  18(A6),D0 
  MOVE.W  52(A5),D1 
  ADD.W   D0,D1 
  MOVE.W  D1,52(A5) 
  TST.W   94(A5)
  BEQ.S   L0067 
  MOVE.W  D1,92(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0067:
  AND.L #$FFFF,D1
  ADD.L D1,D1
  MOVE.W D1,sam_length(A4)
  ADD.L D1,sam_start(A4)
  MOVE.W D1,sam_lplength(A4)
  ADD.L D1,sam_lpstart(A4)

  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0068:MOVE.W  18(A6),52(A5) 
  MOVEQ #0,D1
  MOVE.W  18(A6),D1
  ADD.L D1,D1
  MOVE.W D1,sam_length(A4)
  ADD.L D1,sam_start(A4)
  MOVE.W D1,sam_lplength(A4)
  ADD.L D1,sam_lpstart(A4)


  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0069:MOVE.W  18(A6),18(A5) 
  BRA     L005C 
L006A:
  ;CLR.B   0(A5) 
  move_dff09a 68(A5)
  MOVE.B #-1,0(A5)

  BRA     L005C 


L006D:MOVE.B  17(A6),D0 
  CMP.B   5(A5),D0
  BCC     L005D 
  MOVE.W  18(A6),16(A5) 
  BRA     L005A 
L006E:MOVE.B  17(A6),D0 
  CMP.B   24(A5),D0 
  BCC     L005D 
  MOVE.W  18(A6),16(A5) 
  BRA     L005A 
L006F:TST.B   26(A5)
  BEQ.S   L0070 
  CMPI.B  #-1,26(A5)
  BEQ.S   L0071 
  SUBQ.B  #1,26(A5) 
  BRA.S   L0072 
L0070:ST      26(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0071:MOVE.B  17(A6),D0 
  SUBQ.B  #1,D0 
  MOVE.B  D0,26(A5) 
L0072:MOVE.W  18(A6),16(A5) 
  BRA     L005A 
L0073:TST.B   54(A5)
  BNE.S   L006F 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0074:MOVE.B  17(A6),D0 
  ANDI.L  #$7F,D0 
  MOVEA.L 46(A6),A0 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  ADDA.W  D0,A0 
  MOVE.L  (A0),D0 
  ADD.L   0(A6),D0
  MOVE.L  D0,12(A5) 
  MOVE.W  18(A6),16(A5) 
  ST      26(A5)
  BRA     L0057 
L0075:CLR.B   0(A5) 
  RTS 
L0076:MOVE.W  8(A5),D0
  ADD.W   D0,D0 
  ADD.W   8(A5),D0
  ADD.W   18(A6),D0 
  MOVE.B  D0,24(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0077:MOVE.B  19(A6),24(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0078:MOVE.B  4(A5),D2
  LEA     L005C(PC),A1
  BRA.S   L007B 
L0079:MOVEQ   #0,D2 
  LEA     L005C(PC),A1
  BRA.S   L007B 
L007A:MOVE.B  5(A5),D2
  LEA     L005C(PC),A1
L007B:MOVE.B  17(A6),D0 
  ADD.B   D2,D0 
  ANDI.B  #$3F,D0 
  EXT.W   D0
  ADD.W   D0,D0 
  LEA     L00C0(PC),A0
  MOVE.W  0(A0,D0.W),D0 
  MOVE.W  10(A5),D1 
  ADD.W   18(A6),D1 
  BEQ.S   L007C 
  ADDI.W  #$100,D1
  MULU    D1,D0 
  LSR.L   #8,D0 
L007C:MOVE.W  D0,40(A5) 
  TST.W   48(A5)
  BNE.S   L007D 
  MOVE.W  D0,128(A5)
L007D:JMP     (A1)
L007E:MOVE.W  18(A6),40(A5) 
  TST.W   48(A5)
  BNE     L005D 
  MOVE.W  18(A6),128(A5)
  BRA     L005D 
L007F:MOVE.B  17(A6),34(A5) 
  MOVE.B  #1,35(A5) 
  TST.W   48(A5)
  BNE.S   L0080 
  MOVE.W  40(A5),50(A5) 
L0080:MOVE.W  18(A6),48(A5) 
  BRA     L005D 
L0081:MOVE.B  17(A6),D0 
  MOVE.B  D0,38(A5) 
  LSR.B   #1,D0 
  MOVE.B  D0,39(A5) 
  MOVE.B  19(A6),32(A5) 
  MOVE.B  #1,33(A5) 
  TST.W   48(A5)
  BNE     L005D 
  MOVE.W  40(A5),128(A5)
  CLR.W   36(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0082:MOVE.B  18(A6),28(A5) 
  MOVE.B  17(A6),31(A5) 
  MOVE.B  18(A6),29(A5) 
  MOVE.B  19(A6),30(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0083:CLR.B   28(A5)
  CLR.B   38(A5)
  CLR.W   48(A5)
  CLR.W   94(A5)
  CLR.B   3(A5) 
  BRA     L005D 
L0084:TST.B   54(A5)
  BEQ     L005D 
  TST.B   26(A5)
  BEQ.S   L0085 
  CMPI.B  #-1,26(A5)
  BEQ.S   L0086 
  SUBQ.B  #1,26(A5) 
  BRA.S   L0087 
L0085:ST      26(A5)
  BRA     L005D 
L0086:MOVE.B  19(A6),D0 
  SUBQ.B  #1,D0 
  MOVE.B  D0,26(A5) 
L0087:RTS 


L0088:MOVE.L  12(A5),56(A5) 
  MOVE.W  16(A5),64(A5) 
  MOVE.B  17(A6),D0 
  ANDI.L  #$7F,D0 
  MOVEA.L 46(A6),A0 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  ADDA.W  D0,A0 
  MOVE.L  (A0),D0 
  ADD.L   0(A6),D0
  MOVE.L  D0,12(A5) 
  MOVE.W  18(A6),16(A5) 
  BRA     L0057 
L0089:MOVE.L  56(A5),12(A5) 
  MOVE.W  64(A5),16(A5) 
  BRA     L005D 

L008A:MOVE.L  16(A6),D0 
  ADD.L   D0,44(A5) 
  MOVE.L  44(A5),sam_lpstart(A4) 
  LSR.W   #1,D0 
  SUB.W   D0,52(A5) 
  MOVEQ #0,D1
  MOVE.W  52(A5),D1
  ADD.L D1,D1
  MOVE.W  D1,sam_lplength(A4)
  ADD.L D1,sam_lpstart(A4)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L008B:CLR.B   3(A5) 
  MOVE.L  4(A6),44(A5)
  MOVE.L  4(A6),sam_lpstart(A4)
  MOVE.W  #1,52(A5) 
  MOVE.W  #1*2,sam_lplength(A4)
  ADD.L   #1*2,sam_lpstart(A4)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L008C:CLR.B   3(A5) 
  MOVE.L  16(A6),D0 
  ADD.L   4(A6),D0
  MOVE.L  D0,88(A5) 
  MOVE.L  D0,44(A5) 
  MOVE.L  4(A6),D0
  ADD.L   84(A5),D0 
  MOVE.L  D0,sam_lpstart(A4) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L008D:
  MOVE.W  16(A6),D0 
  BNE.S   L008E 
  MOVE.W  #$100,D0
L008E:
  EXT.L D0
  MOVE.W D0,sam_lplength(A4)
  ADD.L D0,sam_lpstart(A4)  
  MOVE.W  16(A6),D0 
  SUBQ.W  #1,D0 
  ANDI.W  #$FF,D0 
  MOVE.W  D0,94(A5) 
  MOVE.W  18(A6),92(A5) 
  MOVE.W  18(A6),52(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L008F:MOVE.L  16(A6),D0 
  LSL.L   #8,D0 
  MOVE.L  D0,96(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0090:MOVE.L  16(A6),108(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0091:MOVE.W  16(A6),100(A5)
  MOVE.W  16(A6),102(A5)
  MOVE.W  18(A6),104(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0092:MOVE.W  16(A6),120(A5)
  MOVE.W  16(A6),122(A5)
  MOVE.W  18(A6),118(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0093:MOVE.B  19(A6),106(A5)
  MOVE.B  18(A6),D0 
  EXT.W   D0
  LSL.W   #4,D0 
  MOVE.W  D0,116(A5)
  MOVE.W  16(A6),112(A5)
  MOVE.W  16(A6),114(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0094:ADDQ.W  #1,16(A5) 
  CLR.W   94(A5)
  TST.B   17(A6)
  BEQ     L005A 
  CLR.L   96(A5)
  CLR.W   100(A5) 
  CLR.W   102(A5) 
  CLR.W   104(A5) 
  CLR.L   108(A5) 
  CLR.W   120(A5) 
  CLR.W   122(A5) 
  CLR.W   118(A5) 
  CLR.B   106(A5) 
  CLR.W   116(A5) 
  CLR.W   112(A5) 
  CLR.W   114(A5) 
  BRA     L005A 

L0095:MOVEM.L A4-A6/D0,-(A7)
  LEA     L00B6(PC),A6
  MOVE.L  16(A6),-(A7)
  LEA     L00B7(PC),A5
  MOVE.L  D0,16(A6) 
  MOVE.B  18(A6),D0 
  ANDI.W  #$F,D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 0(A5,D0.W),A5 
  MOVE.B  16(A6),D0 
  CMP.B   #-4,D0
  BNE.S   L0096 
  MOVE.B  17(A6),60(A5) 
  MOVE.B  19(A6),D0 
  MOVE.W  D0,62(A5) 
  BRA     L009B 
L0096:TST.B   60(A5)
  BNE     L009B 
  TST.B   D0
  BPL     L009A 
  CMP.B   #-9,D0
  BNE.S   L0097 
  MOVE.B  17(A6),31(A5) 
  MOVE.B  18(A6),D0 
  LSR.B   #4,D0 
  ADDQ.B  #1,D0 
  MOVE.B  D0,29(A5) 
  MOVE.B  D0,28(A5) 
  MOVE.B  19(A6),30(A5) 
  BRA     L009B 
L0097:CMP.B   #-$A,D0 
  BNE.S   L0098 
  MOVE.B  17(A6),D0 
  ANDI.B  #-2,D0
  MOVE.B  D0,38(A5) 
  LSR.B   #1,D0 
  MOVE.B  D0,39(A5) 
  MOVE.B  19(A6),32(A5) 
  MOVE.B  #1,33(A5) 
  CLR.W   36(A5)
  BRA.S   L009B 
L0098:CMP.B   #-$B,D0 
  BNE.S   L0099 
  CLR.B   54(A5)
  BRA.S   L009B 
L0099:CMP.B   #-$41,D0
  BCC.S   L009C 
L009A:MOVE.B  19(A6),D0 
  EXT.W   D0
  MOVE.W  D0,10(A5) 
  MOVE.B  18(A6),D0 
  LSR.B   #4,D0 
  ANDI.W  #$F,D0
  MOVE.B  D0,9(A5)
  MOVE.B  17(A6),D0 
  MOVE.B  D0,7(A5)
  MOVE.B  5(A5),4(A5) 
  MOVE.B  16(A6),5(A5)
  MOVEA.L 46(A6),A4 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  ADDA.W  D0,A4 
  MOVEA.L (A4),A4 
  ADDA.L  0(A6),A4
  MOVE.L  A4,12(A5) 
  MOVE.B  #1,0(A5)
  MOVE.B  #1,54(A5) 
L009B:MOVE.L  (A7)+,16(A6)
  MOVEM.L (A7)+,A4-A6/D0
  RTS 
L009C:MOVE.B  17(A6),34(A5) 
  MOVE.B  #1,35(A5) 
  TST.W   48(A5)
  BNE.S   L009D 
  MOVE.W  40(A5),50(A5) 
L009D:CLR.W   48(A5)
  MOVE.B  19(A6),49(A5) 
  MOVE.B  16(A6),D0 
  ANDI.W  #$3F,D0 
  MOVE.B  D0,5(A5)
  ADD.W   D0,D0 
  LEA     L00C0(PC),A4
  MOVE.W  0(A4,D0.W),40(A5) 
  BRA.S   L009B 
L009E:MOVE.L  A5,-(A7)
  LEA     L00B7(PC),A5
  ANDI.W  #$F,D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 0(A5,D0.W),A5 
  TST.B   60(A5)
  BNE.S   L009F 
  move_dff09a 70(A5)
;  move_dmacon 22(a5)
  CLR.B   0(A5) 

  CLR.W   94(A5)
L009F:MOVEA.L (A7)+,A5
  RTS 
L00A0:MOVEM.L A5-A6,-(A7) 
  LEA     L00B6(PC),A6
  LEA     L00BE(PC),A5
  MOVE.W  #1,0(A5)
  MOVE.B  D0,31(A6) 
  SWAP    D0
  MOVE.B  D0,32(A6) 
  MOVE.B  D0,33(A6) 
  BEQ.S   L00A1 
  MOVE.B  30(A6),D0 
  MOVE.B  #1,15(A6) 
  CMP.B   31(A6),D0 
  BEQ.S   L00A2 
  BCS.S   L00A3 
  NEG.B   15(A6)
  BRA.S   L00A3 
L00A1:MOVE.B  31(A6),30(A6) 
L00A2:CLR.B   15(A6)
  CLR.W   0(A5) 
L00A3:MOVEM.L (A7)+,A5-A6 
  RTS 
L00A4:LEA     L00BE(PC),A0
  RTS 
  MOVEM.L A4-A6/D1-D3,-(A7) 
  LEA     L00B6(PC),A6
  LEA     L00B7(PC),A4
  MOVE.W  D0,D2 
  MOVEA.L 50(A6),A5 
  LSL.W   #3,D2 
  MOVE.B  2(A5,D2.W),D3 
  TST.B   14(A6)
  BPL.S   L00A5 
  MOVE.B  4(A5,D2.W),D3 
L00A5:ANDI.W  #$F,D3
  ADD.W   D3,D3 
  ADD.W   D3,D3 
  MOVEA.L 0(A4,D3.W),A4 
  LSL.W   #6,D3 
  MOVE.B  5(A5,D2.W),D1 
  BCLR    #7,D1 
  CMP.B   61(A4),D1 
  BCC.S   L00A6 
  TST.W   62(A4)
  BPL.S   L00A8 
L00A6:CMP.B   66(A4),D2 
  BNE.S   L00A7 
  TST.W   62(A4)
  BMI.S   L00A7 
  BTST    #7,5(A5,D2.W) 
  BNE.S   L00A8 
L00A7:MOVE.L  0(A5,D2.W),D0 
  ANDI.L  #-$F01,D0 
  OR.W    D3,D0 
  MOVE.L  D0,124(A4)
  MOVE.B  D1,61(A4) 
  MOVE.W  6(A5,D2.W),62(A4) 
  MOVE.B  D2,66(A4) 
L00A8:MOVEM.L (A7)+,A4-A6/D1-D3 
  RTS 
L00A9:CLR.B   0(A6) 
  CLR.L   60(A6)
  CLR.W   94(A6)
  RTS 

L00AA:MOVE.L  A6,-(A7)
  LEA     L00B6(PC),A6
  CLR.B   22(A6)
  CLR.W   54(A6)
  LEA     L00B8(PC),A6
  BSR.S   L00A9 
  LEA     L00B9(PC),A6
  BSR.S   L00A9 
  LEA     L00BA(PC),A6
  BSR.S   L00A9 
  LEA     L00BB(PC),A6
  BSR.S   L00A9 
  move_dmacon #$800f
  LEA     L00BE(PC),A6
  CLR.B   21(A6)
  MOVEA.L (A7)+,A6
  RTS 
L00AB:MOVEM.L A0-A6/D1-D7,-(A7) 
  LEA     L00B6(PC),A6
  MOVE.B  D0,29(A6) 
  BSR.S   L00AD 
  MOVEM.L (A7)+,A0-A6/D1-D7 
  RTS 
L00AC:MOVEM.L A0-A6/D1-D7,-(A7) 
  LEA     L00B6(PC),A6
  ORI.W   #$100,D0
  MOVE.W  D0,28(A6) 
  BSR.S   L00AD 
  MOVEM.L (A7)+,A0-A6/D1-D7 
  RTS 
L00AD:BSR     L00AA 
  CLR.B   22(A6)
  MOVEA.L 0(A6),A4
  MOVE.B  29(A6),D0 
  ANDI.W  #$1F,D0 
  ADD.W   D0,D0 
  ADDA.W  D0,A4 
  LEA     L00BC(PC),A5
  MOVE.B  14(A6),D1 
  BMI     L00AE 
  ANDI.W  #$1F,D1 
  ADD.W   D1,D1 
  LEA     L00BD(PC),A0
  ADDA.W  D1,A0 
  MOVE.W  4(A5),(A0)
  MOVE.B  7(A5),65(A0)
L00AE:MOVE.W  256(A4),4(A5) 
  MOVE.W  256(A4),0(A5) 
  MOVE.W  320(A4),2(A5) 
  MOVE.W  384(A4),D2
  BTST    #0,28(A6) 
  BEQ.S   L00AF 
  LEA     L00BD(PC),A0
  ADDA.W  D0,A0 
  MOVE.W  (A0),4(A5)
  MOVEQ   #0,D2 
  MOVE.B  65(A0),D2 
L00AF:MOVE.W  #$1C,D1 
  LEA     L00BF(PC),A4
L00B0:MOVE.L  A4,40(A5,D1.W)
  MOVE.W  #-$100,72(A5,D1.W)
  CLR.L   104(A5,D1.W)
  SUBQ.W  #4,D1 
  BPL.S   L00B0 
  MOVE.W  D2,6(A5)
  TST.B   29(A6)
  BMI.S   L00B1 
  MOVEA.L 0(A6),A4
  BSR     L0025 
L00B1:CLR.B   13(A6)
  CLR.W   20(A6)
  ST      36(A6)
  MOVE.B  29(A6),14(A6) 
  CLR.B   28(A6)
  CLR.W   54(A6)
  LEA     L00BE(PC),A4
  CLR.W   0(A4) 
  CLR.B   21(A4)
  MOVE.B  #1,22(A6) 
  RTS 
L00B2:MOVEM.L A4-A6,-(A7) 
  LEA     L00B6(PC),A6
  MOVE.L  #$40400000,30(A6) 
  CLR.B   15(A6)
  MOVE.L  D0,0(A6)
  MOVE.L  D1,4(A6)
  MOVEA.L D1,A4 
  CLR.L   (A4)
  MOVE.L  D1,8(A6)
  MOVEA.L D0,A4 
  MOVE.L  464(A4),D1
  ADD.L   D0,D1 
  MOVE.L  D1,38(A6) 
  MOVE.L  468(A4),D1
  ADD.L   D0,D1 
  MOVE.L  D1,42(A6) 
  MOVE.L  472(A4),D1
  ADD.L   D0,D1 
  MOVE.L  D1,46(A6) 
  ADDI.L  #$200,D0
  MOVE.L  D0,50(A6) 
  TST.L   24(A6)
  BNE     L00B3 
  MOVE.L  $00000070.L,24(A6)
L00B3:
  LEA     L00BC(PC),A5
  MOVE.W  #5,6(A5)
  LEA     L00BD(PC),A6
  MOVE.W  #$1F,D0 
L00B4:MOVE.W  #5,64(A6) 
  CLR.W   128(A6) 
  CLR.W   (A6)+ 
  DBF     D0,L00B4
  LEA     L00B7(PC),A4
  LEA     L00B8(PC),A5
  MOVE.L  A5,(A4)+
  LEA     L00B9(PC),A5
  MOVE.L  A5,(A4)+
  LEA     L00BA(PC),A5
  MOVE.L  A5,(A4)+
  LEA     L00BB(PC),A5
  MOVE.L  A5,(A4)+
  MOVEQ   #$B,D0
L00B5:MOVE.L  -16(A4),(A4)+ 
  DBF     D0,L00B5
  MOVEM.L (A7)+,A4-A6 
  RTS 
L00B6:DS.W    15
  DC.B   '@@',$00,$00,$00,$00,$FF,$FF 
  DS.W    10
L00B7:DS.W    32
L00B8:DS.W    10
  DC.B   $82,$01,$00,$01,$00,$00,$00,$00
  DS.W    20
  DC.B   $80,$80,$00,$80,$00,$00,$00,$82
  DC.L   ch1s,0
  DS.W    1 
  DC.B   $00,$04,$00,$00,$00,$00,$00,$00
  DS.W    18
L00B9:DS.W    10
  DC.B   $82,$02,$00,$02,$00,$00,$00,$00
  DS.W    20
  DC.B   $81,$00,$01,$00,$00,$00,$00,$82
  DC.L   ch2s,0
  DS.W    1 
  DC.B   $01,$04,$00,$00,$00,$00,$00,$00
  DS.W    18
L00BA:DS.W    10
  DC.B   $82,$04,$00,$04,$00,$00,$00,$00
  DS.W    20
  DC.B   $82,$00,$02,$00,$00,$00,$00,$82
  DC.L   ch3s,0
  DS.W    1 
  DC.B   $02,$04,$00,$00,$00,$00,$00,$00
  DS.W    18
L00BB:DS.W    10
  DC.B   $82,$08,$00,$08,$00,$00,$00,$00
  DS.W    20
  DC.B   $84,$00,$04,$00,$FF,$FF,$FE,'z'
  DC.L   ch4s,0
  DS.W    1 
  DC.B   $03,$04,$00,$00,$00,$00,$00,$00
  DS.W    18
L00BC:DS.W    3 
  DC.B   $00,$06,$00,$00,$00,$00,$00,$00
  DS.W    93
L00BD:DS.W    96
L00BE:DS.W    19
L00BF:DC.B   $F4,$00,$00,$00,$F0,$00,$00,$00

L00C0:DC.B   $06,$AE,$06,'N',$05,$F4,$05,$9E
  DC.B   $05,'M',$05,$01,$04,$B9,$04,'u'
  DC.B   $04,'5',$03,$F9,$03,$C0,$03,$8C
  DC.B   $03,'X',$03,'*',$02,$FC,$02,$D0
  DC.B   $02,$A8,$02,$82,$02,'^',$02,';'
  DC.B   $02,$1B,$01,$FD,$01,$E0,$01,$C6
  DC.B   $01,$AC,$01,$94,$01,'}',$01,'h'
  DC.B   $01,'T',$01,'@',$01,'/',$01,$1E
  DC.B   $01,$0E,$00,$FE,$00,$F0,$00,$E3
  DC.B   $00,$D6,$00,$CA,$00,$BF,$00,$B4
  DC.B   $00,$AA,$00,$A0,$00,$97,$00,$8F
  DC.B   $00,$87,$00,'',$00,'x',$00,'q'
  DC.B   $00,$D6,$00,$CA,$00,$BF,$00,$B4
  DC.B   $00,$AA,$00,$A0,$00,$97,$00,$8F
  DC.B   $00,$87,$00,'',$00,'x',$00,'q'
  DC.B   $00,$D6,$00,$CA,$00,$BF,$00,$B4
	opt o+

T2_Song:	incbin	tfmx.mod\t2music3.Sng
		even
T2_Smpl:	dcb.b	22272,0			; NOTE: To play Apidya mods
		incbin	tfmx.mod\t2music3.Smp
