;-----------------------------------------------------------------------;
; Premier music player.							;
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

		MOVE.L #np_init,rotfile+20	mx
		MOVE.L #np_play,rotfile+24	;
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
		MOVE.W #$300,$FFFF8240.W
		BSR rotfile+4			; call sequencer
		MOVE.W #$000,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE

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
sam_vcsize	RS.B 0				; structure size.

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


np_init	LEA	L121086(pc),A0
	MOVEQ	#$33,D7
L120B16	CLR.L	(A0)+
	DBF	D7,L120B16
	MOVEQ	#1,D0
	MOVEQ	#0,D1
	LEA	np_data,A4
	LEA	L121086(PC),A6
	MOVE.L	$78.W,(A6)+
	MOVE.W	D0,(A6)+
	MOVEA.L	A4,A3
	ADDA.W	(A4)+,A3
	MOVE.L	A3,(A6)+
	MOVE.W	D1,(A6)+
L120B3E	ADDA.W	(A4)+,A3
	MOVE.L	A3,(A6)+
	DBF	D0,L120B3E
	MOVE.W	(A4)+,D0
	ADDA.L	D0,A3
	MOVE.L	#$82000006,(A6)+
	MOVE.W	#$100,(A6)+
	MOVE.L	#L120E60,(A6)+
	MOVE.L	#L120E7E,(A6)+
	MOVE.L	#L120FA8,(A6)+
	MOVE.L	#L120F2A,(A6)+
	MOVE.L	#L120FB2,(A6)+
	MOVE.L	#L120F34,(A6)+
	MOVE.L	#L120F7A,(A6)+
	MOVE.L	#L120E9C,(A6)+
	MOVE.L	#L120DEC,(A6)+
	MOVE.L	#L120DDC,(A6)+
	MOVE.L	#L120DE4,(A6)+
	MOVE.L	#L120E02,(A6)+
	MOVE.L	#L120DFA,(A6)+
	MOVEQ	#0,D0
	MOVEA.L	A4,A6
	ADDA.W	-8(A4),A6
	SUBA.W	#$C,A6
L120BAE	MOVE.L	A3,2(A4)
	MOVEA.L	A3,A2
	MOVE.W	$E(A4),D0
	ADD.W	D0,D0
	ADDA.L	D0,A2
	MOVE.L	A2,8(A4)
	MOVE.W	6(A4),D0
	ADD.W	D0,D0
	ADDA.L	D0,A3
	ADDA.W	#$10,A4
	CMPA.L	A4,A6
	BNE.S	L120BAE
	move_dmacon #$F
	RTS

; vbl sequencer.

np_play	MOVEQ	#0,D6
	LEA	ch4s(PC),A4		; -> voice 4
	LEA	L12108A(PC),A6
	SUBQ.W	#1,(A6)+
	BHI	L120E32
	MOVEA.L	(A6)+,A1
	ADDA.W	(A6)+,A1
	MOVEA.L	(A6)+,A0
	ADDA.W	(A1),A0
	MOVE.L	(A6)+,D2
	LEA	np_data-8,A1
	LEA	L1210D6(PC),A2
	MOVEQ	#8,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D4
	MOVEQ	#0,D5
L120C8A	MOVE.W	(A0)+,D1
	TST.W	(A2)+
	BPL.S	L120C9C
	ADDQ.W	#1,-(A2)
	ADDA.W	#$20,A2
	ADDQ.W	#8,A4
	BRA	L120D82
L120C9C	MOVEA.L	D2,A3
	ADDA.L	D1,A3
	ADDA.W	(A2),A3
	MOVE.B	(A3)+,D1
	BPL.S	L120CBC
	EXT.W	D1
	ADDQ.W	#1,D1
	ADDQ.W	#1,(A2)
	MOVE.W	D1,-(A2)
	MOVE.W	D6,8(A2)
	ADDA.W	#$20,A2
	ADDQ.W	#8,A4
	BRA	L120D82
L120CBC	MOVE.B	(A3)+,D3
	MOVE.B	(A3)+,D4
	ADDQ.W	#3,(A2)+
	MOVEA.L	A1,A3
	MOVE.B	D1,D7
	LSL.W	#8,D7
	OR.B	D3,D7
	ANDI.W	#$1F0,D7
	BNE.S	L120CD8
	ADDA.W	(A2)+,A3
	ADDQ.W	#2,A2
	ADDQ.W	#2,A3
	BRA.S	L120CDE
L120CD8	MOVE.W	D7,(A2)+
	ADDA.W	D7,A3
	MOVE.W	(A3)+,(A2)+
L120CDE	ANDI.W	#$F,D3
	MOVE.W	D3,(A2)+
	MOVE.W	D4,(A2)+
	ANDI.W	#$FE,D1
	BEQ.S	L120D1A
	MOVE.W	L120D2E(PC,D1.W),D7
	SUBQ.W	#3,D3
	BEQ	L120E14
	SUBQ.W	#2,D3
	BEQ	L120E14
	OR.W	D0,D5
	MOVE.W	D7,(A2)+
	MOVE.W	D1,(A2)+
	MOVE.W	D6,(A2)+

	MOVE.L D7,-(SP)
	MOVE.L	(A3)+,(A4)+
	MOVEQ #0,D7
	MOVE.W (A3)+,D7
	ADD.L D7,D7
	ADD.L D7,-4(A4)
	MOVE.W D7,(A4)+
	MOVE.L (SP)+,D7

	MOVE.L	(A3)+,(A2)+
	MOVE.W	(A3)+,(A2)+
	SUBQ.W	#6,D3
	BMI.S	L120D78
	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVEA.L	$26(A6,D3.W),A3
	JMP	(A3)
L120D1A	ADDA.W	#$C,A2
	ADDQ.W	#6,A4
	SUBI.W	#$B,D3
	BMI.S	L120D78
	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVEA.L	$26(A6,D3.W),A3
L120D2E	JMP	(A3)
	DC.B	3,$58,3,$28,2,$FA,2,$D0
	DC.B	2,$A6,2,$80,2,$5C,2,$3A
	DC.B	2,$1A,1,$FC,1,$E0,1,$C5
	DC.B	1,$AC,1,$94,1,$7D,1,$68
	DC.B	1,$53,1,$40,1,$2E,1,$1D
	DC.B	1,$D,0,$FE,0,$F0,0,$E2
	DC.B	0,$D6,0,$CA,0,$BE,0,$B4
	DC.B	0,$AA,0,$A0,0,$97,0,$8F
	DC.B	0,$87,0,$7F,0,$78,0,$71
L120D78	MOVE.W	-$C(A2),(A4)+
L120D7C	MOVE.W	-$12(A2),(A4)
	ADDQ.W	#8,A2
L120D82	SUBA.W	#sam_vcsize+8,A4
	LSR.W	#1,D0
	BNE	L120C8A
	move_dmacon D5 
	;MOVE.W	D5,6(A4)
	OR.W	D5,(A6)+
	MOVE.W	(A6)+,-$14(A6)
	BSR set_lps
;	MOVE.L	#L121008,$78.W
;	MOVE.B	#$19,$BFDE00
	BSET	#0,(A6)+
	BEQ.S	L120DB4
	ADDQ.B	#1,(A6)
	CMPI.B	#$40,(A6)
	BNE.S	L120DDA
L120DB4	MOVE.B	D6,(A6)
	MOVE.L	D6,-$20(A2)
	MOVE.L	D6,-$40(A2)
	MOVE.L	D6,-$60(A2)
	MOVE.L	D6,-$80(A2)
	LEA	L12108C(PC),A6
	MOVEA.L	(A6)+,A0
	ADDQ.W	#2,(A6)
	MOVE.W	(A6),D0
	CMP.W	-4(A0),D0
	BNE.S	L120DDA
	MOVE.W	-2(A0),(A6)
L120DDA	RTS
L120DDC	MOVE.W	D4,-$12(A2)
	BRA	L120D78
L120DE4	MOVE.B	D6,4(A6)
	BRA	L120D78
L120DEC	MOVE.B	#$3F,5(A6)
	MOVE.B	D4,-9(A6)
	BRA	L120D78
L120DFA	MOVE.W	D4,2(A6)
	BRA	L120D78
L120E02	
;	ANDI.B	#$FD,$BFE001
;	OR.B	D4,$BFE001
	BRA	L120D78
L120E14	ADDA.W	#$C,A2
	ADDQ.W	#8,A4
	CMP.W	-$C(A2),D7
	SLT	(A2)
	BEQ.S	L120E2A
	MOVE.W	D7,2(A2)
	BRA	L120D7C
L120E2A	MOVE.W	D6,2(A2)
	BRA	L120D7C
L120E32	LEA	L1210D6(PC),A0
	MOVEQ	#3,D0
L120E38	MOVE.W	8(A0),D1
	BEQ	L120E52
	SUBQ.W	#8,D1
	BHI	L120E52
	ADDQ.W	#7,D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVEA.L	$14(A6,D1.W),A3
	JMP	(A3)
L120E52	ADDA.W	#$20,A0
	LEA -sam_vcsize(A4),A4
	DBF	D0,L120E38
	RTS
L120E60	MOVE.W	$A(A0),D2
	SUB.W	D2,$C(A0)
	CMPI.W	#$71,$C(A0)
	BPL.S	L120E76
	MOVE.W	#$71,$C(A0)
L120E76	MOVE.W	$C(A0),6(A4)
	BRA.S	L120E52
L120E7E	MOVE.W	$A(A0),D2
	ADD.W	D2,$C(A0)
	CMPI.W	#$358,$C(A0)
	BMI.S	L120E94
	MOVE.W	#$358,$C(A0)
L120E94	MOVE.W	$C(A0),6(A4)
	BRA.S	L120E52
L120E9C	MOVE.W	-2(A6),D2
	SUB.W	$10(A6),D2
	NEG.W	D2
	MOVE.B	L120EEA(PC,D2.W),D2
	BEQ.S	L120EE0
	SUBQ.W	#2,D2
	BEQ.S	L120EBC
	MOVE.W	$A(A0),D2
	LSR.W	#3,D2
	ANDI.W	#$E,D2
	BRA.S	L120EC6
L120EBC	MOVE.W	$A(A0),D2
	ANDI.W	#$F,D2
	ADD.W	D2,D2
L120EC6	ADD.W	$E(A0),D2
	CMPI.W	#$48,D2
	BLS.S	L120ED2
	MOVEQ	#$48,D2
L120ED2	LEA	L120D2E(PC),A3
	MOVE.W	0(A3,D2.W),6(A4)
	BRA	L120E52
L120EE0	MOVE.W	$C(A0),6(A4)
	BRA	L120E52
L120EEA	DC.B	0,1,2,0,1,2,0,1
	DC.B	2,0,1,2,0,1,2,0
	DC.B	1,2,0,1,2,0,1,2
	DC.B	0,1,2,0,1,2,0,1
L120F0A	DC.B	0,$18,$31,$4A,$61,$78,$8D,$A1
	DC.B	$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B	$FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5
	DC.B	$B4,$A1,$8D,$78,$61,$4A,$31,$18
L120F2A	MOVE.W	$A(A0),D3
	BEQ.S	L120F34
	MOVE.W	D3,$1E(A0)
L120F34	MOVE.W	$10(A0),D3
	LSR.W	#2,D3
	ANDI.W	#$1F,D3
	MOVEQ	#0,D2
	MOVE.B	L120F0A(PC,D3.W),D2
	MOVE.W	$1E(A0),D3
	ANDI.W	#$F,D3
	MULU	D3,D2
	LSR.W	#7,D2
	MOVE.W	$C(A0),D3
	TST.B	$11(A0)
	BMI.S	L120F5E
	ADD.W	D2,D3
	BRA.S	L120F60
L120F5E	SUB.W	D2,D3
L120F60	MOVE.W	D3,6(A4)
	MOVE.W	$1E(A0),D3
	LSR.W	#2,D3
	ANDI.W	#$3C,D3
	ADD.B	D3,$11(A0)
	CMPI.B	#$14,D1
	BNE	L120E52
L120F7A	MOVE.W	$A(A0),D2
	ADD.B	D2,7(A0)
	BMI.S	L120F9C
	CMPI.W	#$40,6(A0)
	BMI.S	L120F92
	MOVE.W	#$40,6(A0)
L120F92	MOVE.W	6(A0),8(A4)
	BRA	L120E52
L120F9C	MOVE.W	D6,6(A0)
	MOVE.W	D6,8(A4)
	BRA	L120E52
L120FA8	MOVE.W	$A(A0),D2
	BEQ.S	L120FB2
	MOVE.W	D2,$1C(A0)
L120FB2	MOVE.W	$1A(A0),D2
	BEQ.S	L120FDA
	MOVE.W	$1C(A0),D3
	TST.W	$18(A0)
	BNE.S	L120FE4
	ADD.W	D3,$C(A0)
	CMP.W	$C(A0),D2
	BGT.S	L120FD4
	MOVE.W	D2,$C(A0)
	MOVE.W	D6,$1A(A0)
L120FD4	MOVE.W	$C(A0),6(A4)
L120FDA	CMPI.B	#$10,D1
	BEQ.S	L120F7A
	BRA	L120E52
L120FE4	SUB.W	D3,$C(A0)
	CMP.W	$C(A0),D2
	BLT.S	L120FD4
	MOVE.W	D2,$C(A0)
	MOVE.W	D6,$1A(A0)
	MOVE.W	$C(A0),6(A4)
	CMPI.B	#$10,D1
	BEQ	L120F7A
	BRA	L120E52

set_lps	MOVEM.L D0/A0-A1,-(SP)
	LEA ch4s(PC),A0
	LEA L1210E8(PC),A1
	REPT 4
	MOVE.L (A1),sam_lpstart(A0)
	MOVEQ #0,D0
	MOVE.W 4(A1),D0
	ADD.L D0,D0
	ADD.L D0,sam_lpstart(A0)
	MOVE.W D0,sam_lplength(A0)
	LEA -sam_vcsize(A0),A0
	LEA $20(A1),A1
	ENDR
	move_dmacon L12109A(PC)
	MOVEM.L (SP)+,D0/A0-A1
	RTS

L121086	DC.L 0
L12108A	DC.W 0
L12108C	DC.W 0
L12108E	DS.B 12
L12109A	DC.W 0
L12109C	DS.B 58

L1210D6	DS.B 18
L1210E8	DS.B 16*8

	dC.l 0,0

np_data	incbin d:\premiere\premmus1.np1

