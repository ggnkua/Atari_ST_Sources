;-----------------------------------------------------------------------;
; Delta Replay (ST/STE)							;
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
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
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

		MOVE.L #init_delta,rotfile+20	; setup for tfmx
		MOVE.L #deltavb_play,rotfile+24	;
		MOVEQ #1,D0
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
		MOVE.W #$300,$FFFF8240.W
		BSR rotfile+4			; call sequencer
		MOVE.W #$000,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE

; The Paula Emu v2.0

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
shfilter	DS.W 1
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
sndtab		INCBIN D:\TRACKERS.S\PLAYER.DAT\2CHANSND.TAB	

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

init_delta	MOVEQ #1,D0
		MOVEQ #0,D1
		BRA.W delta_play
deltavb_play	MOVEQ #0,D0
		BRA.W delta_play

delta_play
  ANDI.B  #3,D0 
  TST.B   D0
  BEQ     L000E 
  CMPI.B  #1,D0 
  BEQ     L0007 
  CMPI.B  #2,D0 
  BEQ.S   L0000 
  CMPI.B  #3,D0 
  BEQ.S   L0001 
  MOVEQ   #0,D0 
  RTS 
L0000:LEA     L0046(PC),A0
  ANDI.B  #$3F,D1 
  MOVE.B  D1,46(A0) 
  RTS 
L0001:LEA     L0046(PC),A6
  ANDI.L  #$7F,D2 
  ANDI.W  #$7F,D3 
  ANDI.L  #$3F,D5 
  TST.B   D1
  BNE.S   L0002 
  MOVE.W  D4,50(A6) 
  LEA     L003D(PC),A0
  CLR.B   50(A0)
  LEA     L0041(PC),A0
  BRA.S   L0005 
L0002:CMPI.B  #1,D1 
  BNE.S   L0003 
  MOVE.W  D4,52(A6) 
  LEA     L003E(PC),A0
  CLR.B   50(A0)
  LEA     L0042(PC),A0
  BRA.S   L0005 
L0003:CMPI.B  #1,D1 
  BNE.S   L0004 
  MOVE.W  D4,54(A6) 
  LEA     L003F(PC),A0
  CLR.B   50(A0)
  LEA     L0043(PC),A0
  BRA.S   L0005 
L0004:MOVE.W  D4,56(A6) 
  LEA     L0040(PC),A0
  CLR.B   50(A0)
  LEA     L0044(PC),A0
L0005:MOVEA.L 0(A0),A1
  move_dmacon 4(A0)
  MOVE.B  D3,28(A0) 
  LEA     L0045(PC),A4
  ADD.W   D3,D3 
  MOVE.W  0(A4,D3.W),26(A0) 
  SUBQ.W  #1,D2 
  ADD.L   D2,D2 
  MOVEA.L 6(A6),A4
  ADDA.L  D2,A4 
  MOVEQ   #0,D2 
  MOVE.W  (A4),D2 
  ADD.L   2(A6),D2
  MOVE.L  D2,6(A0)
  MOVEA.L D2,A2 
  MOVE.B  38(A2),51(A0) 
  BPL.S   L0006 
  MOVEQ   #0,D0 
  MOVEA.L 38(A6),A4 
  MOVE.B  39(A2),D0 
  ANDI.B  #7,D0 
  ASL.L   #2,D0 
  ADDA.L  D0,A4 
  MOVEA.L (A4),A4 
  ADDA.L  34(A6),A4 
  MOVE.L  A4,sam_start(A1)
  MOVE.L  A4,sam_lpstart(A1)
  MOVEQ #0,D0
  MOVE.W  0(A2),D0
  ADD.L D0,D0
  ADD.L D0,sam_start(A1)
  ADD.L D0,sam_lpstart(A1)
  MOVE.W D0,sam_length(A1) 
  MOVE.W D0,sam_lplength(A1) 
  MOVE.W  4(A0),D0
  ORI.W   #$8000,D0		; -$8000?
  move_dmacon D0
L0006:LEA     L0047(PC),A4
  ASL.W   #4,D5 
  ADDA.L  D5,A4 
  MOVE.L  A4,44(A0) 
  CLR.B   22(A0)
  CLR.B   23(A0)
  CLR.W   32(A0)
  CLR.B   36(A0)
  CLR.W   34(A0)
  CLR.W   48(A0)
  CLR.B   38(A0)
  CLR.B   39(A0)
  CLR.W   40(A0)
  MOVE.B  22(A2),42(A0) 
  CLR.B   52(A0)
  MOVE.B  23(A2),53(A0) 
  RTS 
  DC.B   'THIS PIE' 
  DC.B   'CE OF MU' 
  DC.B   'SIC, WAS' 
  DC.B   ' CREATED' 
  DC.B   ' ON DELT' 
  DC.B   'A MUSIC ' 
  DC.B   'V2.0 ...' 
  DC.B   '  CODED ' 
  DC.B   'BY :  BE' 
  DC.B   'NT NIELS' 
  DC.B   'EN,   KY' 
  DC.B   'RADSERVE' 
  DC.B   'J 19 B, ' 
  DC.B   '  8700 H' 
  DC.B   'ORSENS, ' 
  DC.B   '  DENMAR' 
  DC.B   'K,   TLF' 
  DC.B   '. 75-601' 
  DC.B   '-868 ...' 
  DC.B   '.. COPYR' 
  DC.B   'IGHT 199' 
  DC.B   '0 ......' 
  DC.B   '.  ',$00
L0007:
  ;BSET    #1,$00BFE001
  LEA     L0048(PC),A0
  LEA     L0046(PC),A4
  CLR.L   50(A4)
  CLR.L   54(A4)
  MOVEA.L A0,A2 
  LEA     L000A(PC),A1
  MOVEQ   #$F,D7
L0008:MOVE.B  (A0)+,(A1)+ 
  DBF     D7,L0008
  MOVE.L  A0,10(A4) 
  MOVEQ   #0,D0 
  MOVE.W  2(A2),D0
  ADDA.L  D0,A0 
  MOVE.L  A0,14(A4) 
  MOVEQ   #0,D0 
  MOVE.W  6(A2),D0
  ADDA.L  D0,A0 
  MOVE.L  A0,18(A4) 
  MOVEQ   #0,D0 
  MOVE.W  10(A2),D0 
  ADDA.L  D0,A0 
  MOVE.L  A0,22(A4) 
  MOVEQ   #0,D0 
  MOVE.W  14(A2),D0 
  ADDA.L  D0,A0 
  MOVE.L  (A0)+,D0
  MOVE.L  A0,26(A4) 
  ADDA.L  D0,A0 
  MOVE.L  A0,6(A4)
  ADDA.L  #$FE,A0 
  MOVEQ   #0,D0 
  MOVE.W  (A0)+,D0
  MOVE.L  A0,2(A4)
  ADDA.L  D0,A0 
  MOVE.L  (A0)+,D0
  MOVE.L  A0,30(A4) 
  ADDA.L  D0,A0 
  MOVE.L  A0,38(A4) 
  ADDI.L  #$40,38(A4) 
  ADDA.L  #$60,A0 
  MOVE.L  A0,34(A4) 
  move_dmacon #$f
;  LEA     ch1s(pc),A5
;  MOVE.W  #1*2,(sam_vcsize*0)+sam_length(A5)
;  MOVE.W  #1*2,(sam_vcsize*1)+sam_length(A5)
;  MOVE.W  #1*2,(sam_vcsize*2)+sam_length(A5)
;  MOVE.W  #1*2,(sam_vcsize*3)+sam_length(A5)
;  CLR.W   (sam_vcsize*0)+sam_vol(A5) 
;  CLR.W   (sam_vcsize*1)+sam_vol(A5) 
;  CLR.W   (sam_vcsize*2)+sam_vol(A5) 
;  CLR.W   (sam_vcsize*3)+sam_vol(A5) 
  LEA     L0046(PC),A4
  LEA     L003D(PC),A0
  MOVE.L  10(A4),10(A0) 
  MOVE.L  L000A(PC),54(A0)
  BSR     L0009 
  LEA     L003E(PC),A0
  MOVE.L  14(A4),10(A0) 
  MOVE.L  L000B(PC),54(A0)
  BSR     L0009 
  LEA     L003F(PC),A0
  MOVE.L  18(A4),10(A0) 
  MOVE.L  L000C(PC),54(A0)
  BSR     L0009 
  LEA     L0040(PC),A0
  MOVE.L  22(A4),10(A0) 
  MOVE.L  L000D(PC),54(A0)
  BSR     L0009 
  LEA     L0041(PC),A0
  MOVE.L  10(A4),10(A0) 
  MOVE.L  L000A(PC),54(A0)
  BSR     L0009 
  LEA     L0042(PC),A0
  MOVE.L  14(A4),10(A0) 
  MOVE.L  L000B(PC),54(A0)
  BSR     L0009 
  LEA     L0043(PC),A0
  MOVE.L  18(A4),10(A0) 
  MOVE.L  L000C(PC),54(A0)
  BSR     L0009 
  LEA     L0044(PC),A0
  MOVE.L  22(A4),10(A0) 
  MOVE.L  L000D(PC),54(A0)
  BSR     L0009 
  MOVE.B  #1,48(A4) 
  RTS 
L0009:CLR.W   20(A0)
  CLR.W   18(A0)
  MOVE.L  2(A4),6(A0) 
  CLR.B   51(A0)
  CLR.W   48(A0)
  LEA     L0047(PC),A3
  MOVE.L  A3,44(A0) 
  CLR.W   32(A0)
  CLR.W   34(A0)
  CLR.B   36(A0)
  CLR.B   37(A0)
  CLR.W   30(A0)
  MOVE.B  #$3F,29(A0) 
  MOVE.B  #1,50(A0) 
  RTS 
L000A:DCB.W    1,0 
  DC.B   $00,$08
L000B:DCB.W    1,0 
  DC.B   $00,$08
L000C:DCB.W    1,0 
  DC.B   $00,$08
L000D:DCB.W    1,0 
  DC.B   $00,$08

; Vbl seq.

L000E:MOVEM.L A0-A6/D0-D7,-(A7) 
  LEA     L0046(PC),A6
  CLR.B   1(A6) 
  MOVEA.L 30(A6),A3 
  MOVE.L  42(A6),D1 
  MOVEQ   #$F,D0
L000F:ROL.L   #7,D1 
  ADDI.L  #$6ECA756D,D1 
  EORI.L  #-$61A656D5,D1
  MOVE.L  D1,(A3)+
  DBF     D0,L000F
  MOVE.L  D1,42(A6) 
  SUBQ.B  #1,48(A6) 
  BPL.S   L0010 
  MOVE.B  47(A6),48(A6) 
L0010:CLR.B   49(A6)
  LEA     L003D(PC),A0
  BSR     L0019 
  LEA     L003E(PC),A0
  BSR     L0019 
  LEA     L003F(PC),A0
  BSR     L0019 
  LEA     L0040(PC),A0
  BSR     L0019 
  MOVE.B  #1,49(A6) 
  TST.W   50(A6)
  BEQ.S   L0011 
  SUBQ.W  #1,50(A6) 
  LEA     L0041(PC),A0
  BSR   L0019 
  BRA.S   L0012 
L0011:LEA     L003D(PC),A0
  MOVE.B  #1,50(A0) 
L0012:TST.W   52(A6)
  BEQ.S   L0013 
  SUBQ.W  #1,52(A6) 
  LEA     L0042(PC),A0
  BSR.S   L0019 
  BRA.S   L0014 
L0013:LEA     L003E(PC),A0
  MOVE.B  #1,50(A0) 
L0014:TST.W   54(A6)
  BEQ.S   L0015 
  SUBQ.W  #1,54(A6) 
  LEA     L0043(PC),A0
  BSR.S   L0019 
  BRA.S   L0016 
L0015:LEA     L003F(PC),A0
  MOVE.B  #1,50(A0) 
L0016:TST.W   56(A6)
  BEQ.S   L0017 
  SUBQ.W  #1,56(A6) 
  LEA     L0044(PC),A0
  BSR.S   L0019 
  BRA.S   L0018 
L0017:LEA     L003F(PC),A0
  MOVE.B  #1,50(A0) 
L0018:move_dmacon 0(A6)
  MOVEM.L (A7)+,A0-A6/D0-D7 
  RTS 
L0019:MOVEA.L 0(A0),A1
  MOVEA.L 6(A0),A2
  TST.B   51(A0)
  BPL.S   L001B 
  CLR.B   51(A0)
  MOVEQ   #0,D0 
  MOVEA.L 38(A6),A3 
  MOVE.B  39(A2),D0 
  ANDI.B  #7,D0 
  ASL.L   #2,D0 
  ADDA.L  D0,A3 
  MOVEA.L (A3),A4 
  ADDA.L  34(A6),A4 
  MOVEQ   #0,D0 
  TST.B   50(A0)
  BEQ.S   L001A 
  MOVE.W  4(A2),D0
  ADD.L D0,D0
  MOVE.W D0,sam_lplength(A1) 
L001A:
  MOVEQ #0,D0
  MOVE.W  2(A2),D0
  CLR.W   (A4)
  ADDA.L  D0,A4 
  TST.B   50(A0)
  BEQ.S   L001B 
  ADD.W sam_lplength(A1),A4
  MOVE.L  A4,sam_lpstart(A1)
  SUB.W sam_lplength(A1),A4
L001B:TST.B   49(A6)
  BNE     L0021 
  TST.B   48(A6)
  BNE     L0021 
  TST.W   20(A0)
  BNE.S   L001C 
  MOVEQ   #0,D0 
  MOVEA.L 10(A0),A3 
  MOVE.W  18(A0),D1 
  MOVE.B  0(A3,D1.W),D0 
  MOVE.B  1(A3,D1.W),43(A0) 
  ASL.L   #6,D0 
  ADD.L   26(A6),D0 
  MOVE.L  D0,14(A0) 
  ADDQ.W  #2,D1 
  MOVE.W  D1,18(A0) 
  CMP.W   56(A0),D1 
  BMI.S   L001C 
  MOVE.W  54(A0),18(A0) 
L001C:MOVEQ   #0,D0 
  MOVEA.L 14(A0),A3 
  MOVE.W  20(A0),D0 
  ADDA.L  D0,A3 
  MOVEQ   #0,D0 
  MOVE.B  (A3),D0 
  BEQ     L001F 
  TST.B   50(A0)
  BEQ.S   L001D 
  move_dmacon 4(A0)
L001D:MOVE.B  D0,28(A0) 
  LEA     L0045(PC),A4
  ADD.B   43(A0),D0 
  ADD.W   D0,D0 
  MOVE.W  0(A4,D0.W),26(A0) 
  MOVEQ   #0,D1 
  MOVE.B  1(A3),D1
  ADD.L   D1,D1 
  SUBQ.W  #2,D1 
  MOVEA.L 6(A6),A4
  ADDA.L  D1,A4 
  MOVEQ   #0,D2 
  MOVE.W  (A4),D2 
  ADD.L   2(A6),D2
  MOVE.L  D2,6(A0)
  MOVEA.L D2,A2 
  MOVE.B  38(A2),51(A0) 
  BPL.S   L001E 
  TST.B   50(A0)
  BEQ.S   L001E 
  MOVEQ   #0,D0 
  MOVEA.L 38(A6),A4 
  MOVE.B  39(A2),D0 
  ANDI.B  #7,D0 
  ASL.L   #2,D0 
  ADDA.L  D0,A4 
  MOVEA.L (A4),A4 
  ADDA.L  34(A6),A4 

  MOVE.L  A4,sam_start(A1)
  ;MOVE.L  A4,sam_lpstart(A1)
  MOVEQ #0,D0
  MOVE.W  0(A2),D0
  ADD.L D0,D0
  ADD.L D0,sam_start(A1)
  ;ADD.L D0,sam_lpstart(A1)
  MOVE.W D0,sam_length(A1) 
  ;MOVE.W D0,sam_lplength(A1) 

L001E:CLR.B   22(A0)
  CLR.B   23(A0)
  CLR.W   32(A0)
  CLR.B   36(A0)
  CLR.W   34(A0)
  CLR.W   48(A0)
  CLR.B   38(A0)
  CLR.B   39(A0)
  CLR.W   40(A0)
  MOVE.B  22(A2),42(A0) 
  CLR.B   52(A0)
  MOVE.B  23(A2),53(A0) 
L001F:MOVE.B  2(A3),D0
  SUBQ.B  #1,D0 
  BMI.S   L0020 
  MOVE.B  3(A3),D1
  LEA     L003B(PC),A3
  LEA     L003A(PC),A4
  ANDI.L  #7,D0 
  ASL.L   #2,D0 
  ADDA.L  0(A4,D0.W),A3 
  JSR     (A3)
L0020:ADDQ.W  #4,20(A0) 
  ANDI.W  #$3F,20(A0) 
L0021:TST.B   38(A2)
  BMI.S   L0026 
  TST.B   22(A0)
  BEQ.S   L0022 
  SUBQ.B  #1,22(A0) 
  BRA.S   L0026 
L0022:MOVE.B  39(A2),22(A0) 
  MOVEQ   #0,D0 
  MOVEQ   #0,D2 
  LEA     40(A2),A3 
  MOVE.B  23(A0),D0 
L0023:MOVE.B  D0,D1 
  MOVE.B  0(A3,D0.W),D2 
  CMPI.B  #-1,D2
  BNE.S   L0024 
  MOVE.B  1(A3,D0.W),D0 
  MOVE.B  0(A3,D0.W),D2 
  CMPI.B  #-1,D2
  BNE.S   L0023 
  BRA.S   L0026 
L0024:ASL.L   #8,D2 
  ADD.L   30(A6),D2 
  TST.B   50(A0)
  BEQ.S   L0025 
  MOVE.L  D2,sam_start(A1)	; start
  MOVE.L  D2,sam_lpstart(A1)	; start
  MOVEQ #0,D0
  MOVE.W  0(A2),D0
  ADD.L D0,D0
  ADD.L D0,sam_start(A1)
  ADD.L D0,sam_lpstart(A1)
  MOVE.W D0,sam_length(A1) 
  MOVE.W D0,sam_lplength(A1) 
L0025:ADDQ.B  #1,D1 
  ANDI.B  #$3F,D1 
  MOVE.B  D1,23(A0) 
L0026:MOVEQ   #0,D0 
  LEA     21(A2),A3 
  MOVE.B  52(A0),D0 
  ADDA.L  D0,A3 
  MOVE.B  0(A3),D0
  TST.B   39(A0)
  BNE.S   L0027 
  ADD.W   D0,40(A0) 
  BRA.S   L0028 
L0027:SUB.W   D0,40(A0) 
L0028:SUBQ.B  #1,42(A0) 
  BNE.S   L0029 
  MOVE.B  1(A3),42(A0)
  NOT.B   39(A0)
L0029:TST.B   53(A0)
  BEQ.S   L002A 
  SUBQ.B  #1,53(A0) 
  BRA.S   L002C 
L002A:ADDQ.B  #3,52(A0) 
  CMPI.B  #$F,52(A0)
  BNE.S   L002B 
  MOVE.B  #$C,52(A0)
L002B:MOVE.B  5(A3),53(A0)
L002C:TST.B   36(A0)
  BEQ.S   L002D 
  SUBQ.B  #1,36(A0) 
  BRA.S   L0030 
L002D:MOVEQ   #0,D0 
  MOVEQ   #0,D1 
  MOVE.W  34(A0),D0 
  LEA     6(A2),A3
  ADDA.L  D0,A3 
  MOVE.B  (A3),D0 
  MOVE.B  1(A3),D1
  CMP.W   32(A0),D1 
  BPL.S   L002E 
  SUB.W   D0,32(A0) 
  CMP.W   32(A0),D1 
  BMI.S   L0030 
  MOVE.W  D1,32(A0) 
  ADDQ.W  #3,34(A0) 
  MOVE.B  2(A3),36(A0)
  BRA.S   L0030 
L002E:ADD.W   D0,32(A0) 
  CMP.W   32(A0),D1 
  BPL.S   L0030 
  MOVE.W  D1,32(A0) 
  ADDQ.W  #3,34(A0) 
  CMPI.W  #$F,34(A0)
  BNE.S   L002F 
  MOVE.W  #$C,34(A0)
L002F:MOVE.B  2(A3),36(A0)
L0030:MOVEQ   #0,D0 
  MOVE.B  37(A0),D0 
  BEQ.S   L0032 
  MOVE.W  26(A0),D1 
  CMP.W   24(A0),D1 
  BPL.S   L0031 
  SUB.W   D0,24(A0) 
  CMP.W   24(A0),D1 
  BMI.S   L0032 
  MOVE.W  D1,24(A0) 
  BRA.S   L0032 
L0031:ADD.W   D0,24(A0) 
  CMP.W   24(A0),D1 
  BPL.S   L0032 
  MOVE.W  D1,24(A0) 
L0032:MOVEQ   #0,D0 
  MOVEA.L 44(A0),A3 
  MOVE.W  48(A0),D1 
  MOVE.B  0(A3,D1.W),D0 
  TST.B   D1
  BEQ.S   L0033 
  CMPI.B  #-$80,D0
  BNE.S   L0033 
  CLR.W   48(A0)
  BRA.S   L0032 
L0033:ADDQ.W  #1,48(A0) 
  ANDI.W  #$F,48(A0)
  TST.B   37(A0)
  BEQ.S   L0034 
  MOVE.W  24(A0),D0 
  BRA.S   L0035 
L0034:LEA     L0045(PC),A3
  ADD.B   28(A0),D0 
  ADD.B   43(A0),D0 
  ADD.W   D0,D0 
  MOVE.W  0(A3,D0.W),D0 
  MOVE.W  D0,24(A0) 
L0035:MOVE.W  36(A2),D1 
  SUB.W   30(A0),D1 
  SUB.W   D1,40(A0) 
  ADD.W   40(A0),D0 
  TST.B   50(A0)
  BEQ.S   L0036 
  MOVE.W  D0,sam_period(A1)
L0036:MOVE.W  32(A0),D0 
  ROR.W   #2,D0 
  ANDI.W  #$3F,D0 
  CMP.B   29(A0),D0 
  BMI.S   L0037 
  MOVE.B  29(A0),D0 
L0037:CMP.B   46(A6),D0 
  BMI.S   L0038 
  MOVE.B  46(A6),D0 
L0038:TST.B   50(A0)
  BEQ.S   L0039
   
  MOVE.b  D0,sam_vol+1(A1)
  MOVE.B  5(A0),D0
  OR.B    D0,1(A6)
L0039:RTS 
L003A:	DC.W    0,0,0
  DC.B   $00,$0A,$00,$00,$00,'"',$00,$00
  DC.B   $00,'.',$00,$00,$00,'8',$00,$00
  DC.B   $00,'>',$00,$00,$00,'H',$00,$00
  DC.B   $00,'R'

L003B:DC.B   $02,$01,$00,$0F
  MOVE.B  D1,47(A6) 
  RTS 
  TST.B   D1
  BNE.S   L003C 
  BSET    #1,shfilter
  RTS 
L003C:
  BCLR    #1,shfilter
  RTS 
  ANDI.W  #$FF,D1 
  NEG.W   D1
  MOVE.W  D1,30(A0) 
  RTS 
  ANDI.W  #$FF,D1 
  MOVE.W  D1,30(A0) 
  RTS 
  MOVE.B  D1,37(A0) 
  RTS 
  ANDI.B  #$3F,D1 
  MOVE.B  D1,29(A0) 
  RTS 
  ANDI.B  #$3F,D1 
  MOVE.B  D1,46(A6) 
  RTS 
  ANDI.L  #$3F,D1 
  ASL.L   #4,D1 
  LEA     L0047(PC),A4
  ADDA.L  D1,A4 
  MOVE.L  A4,44(A0) 
  RTS 
L003D:	DC.L ch1s
	DC.B   $00,$01,$00,$00
	DCB.W    10,0
	DC.B   $00,'?',$00,$00,$00,$00,$00,$00
	DCB.W    7,0 
	DC.B   $01,$00,$00,$00,$00,$00,$00,$00
	DCB.W    1,0 
L003E:	DC.L ch2s
	DC.B   $00,$02,$00,$00
	DCB.W    5,0 
	DC.B   $01,$00,$00,$00,$00,$00,$00,$00
	DCB.W    27,0
L003F:	DC.L ch3s
	DC.B   $00,$04,$00,$00
	DCB.W    5,0 
	DC.B   $01,$00,$00,$00,$00,$00,$00,$00
	DCB.W    27,0
L0040:	DC.L ch4s
	DC.B   $00,$08,$00,$00
	DCB.W    5,0 
	DC.B   $01,$00,$00,$00,$00,$00,$00,$00
  	DCB.W    27,0

L0041	DC.L ch1s
	DC.B   $00,$01,$00,$00
	DCB.W    5,0 
	DC.B   $01,$00,$00,$00,$00,$00,$00,$00
	DCB.W    27,0
L0042:	DC.L ch2s
	DC.B   $00,$02,$00,$00
	DCB.W    5,0 
	DC.B   $01,$00,$00,$00,$00,$00,$00,$00
	DCB.W    27,0
L0043:	DC.L ch3s
	DC.B   $00,$04,$00,$00
	DCB.W    5,0 
	DC.B   $01,$00,$00,$00,$00,$00,$00,$00
	DCB.W    27,0
L0044:  DC.L ch4s
	DC.B $00,$08,$00,$00
	DCB.W    5,0 
	DC.B   $01,$00,$00,$00,$00,$00,$00,$00
	DCB.W    26,0

L0045:DCB.W    1,0 
  DC.B   $1A,$C0,$19,'@',$17,$D0,$16,$80
  DC.B   $15,'0',$14,$00,$12,$E0,$11,$D0
  DC.B   $10,$D0,$0F,$E0,$0F,$00,$0E,' '
  DC.B   $0D,'`',$0C,$A0,$0B,$E8,$0B,'@'
  DC.B   $0A,$98,$0A,$00,$09,'p',$08,$E8
  DC.B   $08,'h',$07,$F0,$07,$80,$07,$10
  DC.B   $06,$B0,$06,'P',$05,$F4,$05,$A0
  DC.B   $05,'L',$05,$00,$04,$B8,$04,'t'
  DC.B   $04,'4',$03,$F8,$03,$C0,$03,$88
  DC.B   $03,'X',$03,'(',$02,$FA,$02,$D0
  DC.B   $02,$A6,$02,$80,$02,'\',$02,':'
  DC.B   $02,$1A,$01,$FC,$01,$E0,$01,$C4
  DC.B   $01,$AC,$01,$94,$01,'}',$01,'h'
  DC.B   $01,'S',$01,'@',$01,'.',$01,$1D
  DC.B   $01,$0D,$00,$FE,$00,$F0,$00,$E2
  DC.B   $00,$D6,$00,$CA,$00,$BE,$00,$B4
  DC.B   $00,$AA,$00,$A0,$00,$97,$00,$8F
  DC.B   $00,$87,$00,'',$00,'x',$00,'q'
  DC.B   $00,'q',$00,'q',$00,'q',$00,'q'
  DC.B   $00,'q',$00,'q',$00,'q',$00,'q'
  DC.B   $00,'q',$00,'q',$00,'q',$00,'q'

L0046:	INCBIN D:\TRACKERS.S\DELTA.MOD\NEBY2_7.DAT
L0047	EQU L0046+62
L0048	EQU L0047+1024
