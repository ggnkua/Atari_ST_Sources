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
; TFMX player.
;

;		OPT P+		; must be position independent

rotfile		BRA.W Init_PAL_or_NTSC
		BRA.W Vbl_play
		BRA.W Init_ST
		BRA.W stop_ints
		DC.L vol_bitflag-rotfile

		DC.B "ST/STE/TT Digi-Driver "
		DC.B "By Martin Griffiths(aka Griff of Inner Circle),"
		EVEN

speed		EQU 25    			; timer d (12.5KHZ)

; Select PAL/NTSC

Init_PAL_or_NTSC
		LEA basespeed(PC),A0
		BTST.B #1,$FFFF820A.W
		BEQ.S .sel_NTSC
.sel_PAL	MOVE.B #6,(A0)
		RTS
.sel_NTSC	MOVE.B #7,(A0)
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
		bsr ct_init

		BRA STspecific
.trigfadein	LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; ensure zero to start with!
		LEA fadeINflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		bsr ct_init
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
saved4		DS.W 1

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
		ADDI.W #$800,D0			; abs
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
		;SF.B audblockvc1	
		;SF.B audblockvc2	
		;SF.B audblockvc3	
		;SF.B audblockvc4	

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
		;BSR setaudblock	
		BRA ct_music			; jump to sequencer
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
		EXT.L D1
		BEQ.S .zero
		LSL.L #4,d1			; *16
		MOVE.L #speed*96,D3
		DIVU D1,D3
		SWAP D1
		MOVE D3,D1			; accr_divu
		SWAP D1			
		CLR.W D3
		DIVU D1,d3
		MOVE D3,D1			; int.w/frac.w
.zero
		LSL.W #8,D2			; offset into volume tab
		NEG.W D0			; negate sample offset
		MOVE.W shadow_dmacon(PC),D7
		BTST D4,D7
		BNE.S .vcon2
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
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

lpvc1ste	ST.B audblockvc1
		MOVE.L Voice1Set+Vlpfreq(PC),A2
		MOVE.L Voice1Set+Vlpaddr(PC),A0		; loop voice 1
		ADD.W  Voice1Set+Vlpoffy(PC),D0		
		BRA.W contlp1ste

lpvc2ste	ST.B audblockvc2
		MOVE.L Voice2Set+Vlpfreq(PC),A3
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
lpvc3ste	ST.B audblockvc3
		MOVE.L Voice3Set+Vlpfreq(PC),A2
		MOVE.L Voice3Set+Vlpaddr(PC),A0		; loop voice 3
		ADD.W  Voice3Set+Vlpoffy(PC),D0
		BRA.W contlp3ste

lpvc4ste	ST.B audblockvc4
		MOVE.L Voice4Set+Vlpfreq(PC),A3
		MOVE.L Voice4Set+Vlpaddr(PC),A1		;      "     4
		ADD.W  Voice4Set+Vlpoffy(PC),D1	
		BRA.W contlp4ste

audblockvc1	DS.B 1
audblockvc2	DS.B 1
audblockvc3	DS.B 1
audblockvc4	DS.B 1

setaudblock	TST.B audblockvc1
		BEQ.S .novc1
		;LEA L00B8,A5
		MOVE.W  shadow_dff09c(PC),D4
		AND.W   shadow_dff09a(PC),D4
		BTST #7,D4
		BeQ.S .novc1
		MOVE.B  #-1,(A5)
		move_dff09a 70(a5)
		move_dff09c 70(a5)
.novc1		TST.B audblockvc2
		BEQ.S .novc2
		;LEA L00B9,A5
		MOVE.W  shadow_dff09c(PC),D4
		AND.W   shadow_dff09a(PC),D4
		BTST #8,D4
		BeQ.S .novc2
		MOVE.B  #-1,(A5)
		move_dff09a 70(a5)
		move_dff09c 70(a5)
.novc2		TST.B audblockvc3
		BEQ.S .novc3
		;LEA L00BA,A5
		MOVE.W  shadow_dff09c(PC),D4
		AND.W   shadow_dff09a(PC),D4
		BTST #9,D4
		BeQ.S .novc3
	  	MOVE.B  #-1,(A5)
		move_dff09a 70(a5)
		move_dff09c 70(a5)
.novc3		TST.B audblockvc4
		BEQ.S .novc4
		;LEA L00BB,A5
		MOVE.W  shadow_dff09c(PC),D4
		AND.W   shadow_dff09a(PC),D4
		BTST #10,D4
		BeQ.S .novc4
		MOVE.B  #-1,(A5)
		move_dff09a 70(a5)
		move_dff09c 70(a5)
.novc4		RTS

; YM 2149 interrupt - fucking bastard shite ST chip(designer cunts)

player		MOVE.L D0,-(SP)
		PEA (A0)
		MOVE.L USP,A0
		MOVE.W (A0)+,D0
		BMI.S .reset
.cont		MOVE.L A0,USP
		LSL #3,D0
		LEA $FFFF8800.W,A0
		MOVE.L sndtab+4(PC,D0),(A0)
		MOVE.L sndtab(PC,D0),D0
		MOVEP.L D0,(A0)	
		MOVE.L (SP)+,A0
		MOVE.L (SP)+,D0
		RTE
.reset		LEA buffer(PC),A0
		MOVE.W (A0)+,D0
		BRA.S .cont
sndtab		INCBIN D:\TRACKERS.S\FUT_PLAY.INC\QUARFAST.TAB	

Voice1Set	DS.L 7
Voice2Set	DS.L 7		; voice data (setup from 'paula' data)
Voice3Set	DS.L 7
Voice4Set	DS.L 7

buffer		DS.W $400	; circular(ring) buffer
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
		ADD.W D0,D0
		MULS D0,D2
		LSR.W #1,D0 
		ASR.L #7,D2
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
		DIVS #$80,D2 
		MOVE.B D2,-(A0)
		DBF D1,.lp2
		DBF D0,.lp1
		RTS 


Init_Buffer	LEA buffer+$800(PC),A0
		MOVEQ.L #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,A1
		MOVEQ #($800/128)-1,D7
.lp		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,.lp
		RTS

vols		DS.B 256
		DS.B 16640

; *********************************************
; ** SUPER DUPER REPLAYER!!    (Optimized!!) **
; *********************************************

;* Matthew Simmonds' Music Routine coded by Krister Wombell.

sf_instr 	equ $16		;Song file offsets
sf_ident 	equ $3B8
sf_length 	equ $3BC
sf_restart 	equ $3BD
sf_parts	equ $3BE
sf_patterns 	equ $7C0
in_type		equ 0
in_length 	equ 22
in_spvol	equ 24
in_repeat 	equ 26
in_replen 	equ 28
in_size		equ 30

; Init patterns/music etc

ct_init		move.l ct_data_ptr,a0
		lea sf_patterns(a0),a1
		lea pattslook(pc),a2	; Make pattern look up table
		moveq #127,d0
.loop		move.l a1,(a2)+
		lea 256(a1),a1
		dbra d0,.loop
		lea sf_parts(a0),a1
		moveq #0,d0
		move.b sf_length(a0),d0
		add.w d0,d0
		add.w d0,d0
		subq.w #1,d0
		moveq #0,d1
.loop2		move.b (a1),d2
		cmp.b d1,d2
		bls.s .ok
		move.b d2,d1
.ok		addq.l #2,a1
		dbra d0,.loop2
		addq.w #1,d1
		mulu #256,d1		;256 bytes per pattern
		lea sf_patterns(a0),a1
		lea (a1,d1),a1
		lea sf_instr(a0),a2
		lea samplesinfo(pc),a3
		moveq #30,d0
.loop3		move.l a3,a4
		move.l a1,(a4)+		;Store address of sample
		moveq #0,d1		;Get length
		move.w in_length(a2),d1
		move.w d1,(a4)+		;Store length
		add.l d1,d1		;Length * 2
		move.l #nullsamp,(a4)+	;Default is no replen
		move.w in_replen(a2),(a4)+  ;Store replen
		move.w in_spvol(a2),(a4)+
		cmp.w #1,in_replen(a2)	;If repeat present
		beq.s .noreplen		;Then add to
		moveq #0,d2
		move.w in_repeat(a2),d2
		lea (a1,d2.l),a6	;Sample address
		move.l a6,-8(a4)	;And store
.noreplen	add.l d1,a1		;Add length*2 -> addr of next sample
.skip		lea in_size(a2),a2
		lea 16(a3),a3
		dbra d0,.loop3
		lea ct_vibtab+32,a1	;Point to next tab
		moveq #13,d0
		moveq #1,d2
.loop4		lea ct_vibtab(pc),a0
		move.l a1,a2
		moveq #31,d1
.loop5		moveq #0,d3
		move.b (a0)+,d3
		mulu d2,d3
		lsr.w #8,d3
		move.b d3,(a2)+
		dbra d1,.loop5
		addq.w #1,d2
		lea 32(a1),a1
		dbra d0,.loop4
		lea ct_vibtab(pc),a0
		moveq #31,d0
.loop6		clr.b (a0)+
		dbra d0,.loop6
		lea ct_vars(pc),a5
		clr.l position(a5)
		clr.l ct_dma(a5)
		clr.l ct_count(a5)
		move.w #6,ct_speed(a5)
		move_dmacon #$f
		rts

; Vbl Sequencer..

ct_music	lea ct_vars(pc),a5
		addq.w #1,ct_count(a5)
		move.w ct_speed(a5),d0
		cmp.w ct_count(a5),d0
		beq ct_new
		lea ch1s(pc),a1
		lea current(pc),a2
		bsr.s ct_checkcom
		lea ch2s(pc),a1
		lea current+vi_size(pc),a2
		bsr.s ct_checkcom
		lea ch3s(pc),a1
		lea current+vi_size*2(pc),a2
		bsr.s ct_checkcom
		lea ch4s(pc),a1
		lea current+vi_size*3(pc),a2
		bsr.s ct_checkcom
.no_play	rts
ct_checkcom	moveq #0,d0
		move.b vi_command+2(a2),d0
		add.w d0,d0
		add.w d0,d0
		jmp comtab1(pc,d0.w)
comtab1		bra.w ct_arpeggio
		bra.w ct_portup
		bra.w ct_portdown
		bra.w ct_myport
		bra.w ct_vib
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_volslide
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
ct_arpeggio	tst.b vi_command+3(a2)
		bne.s .yep
		rts
.yep		move.w ct_count(a5),d0
		move.b ct_arplist(pc,d0.w),d0
		beq ct_rts
		cmp.b #2,d0
		beq.s .arp2
.arp1		move.b vi_command+3(a2),d0
		lsr.w #4,d0
		bra.s .arpdo
.arp2		move.b vi_command+3(a2),d0
		and.w #$F,d0
.arpdo		lea periods(pc),a0
		add.w d0,d0
		move.w vi_note(a2),d1
		add.w d0,d1
		move.w (a0,d1),d0
		move.w d0,sam_period(a1)
		move.w d0,vi_period(a2)
		rts
ct_arplist	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
ct_portup	moveq #0,d0
		move.b vi_command+3(a2),d0
		sub.w d0,vi_period(a2)
		move.w vi_period(a2),d0
		cmp.w #$71,d0
		bhs.s .ok
		move.w #$71,vi_period(a2)
		move.w #$71,d0
.ok		move.w d0,sam_period(a1)
		rts
ct_portdown	moveq #0,d0
		move.b vi_command+3(a2),d0
		add.w d0,vi_period(a2)
		move.w vi_period(a2),d0
		cmp.w #$358,d0
		bmi.s .ok
		and.w #$F000,vi_period(a2)
		or.w #$358,vi_period(a2)
.ok		move.w d0,sam_period(a1)
		rts
ct_myport	move.b vi_command+3(a2),d0
		beq.s .slide
		move.b d0,vi_tspeed(a2)
		clr.b vi_command+3(a2)
.slide		tst.w vi_tperiod(a2)
		beq.s .skip
		moveq #0,d0
		move.b vi_tspeed(a2),d0
		tst.b vi_tdir(a2)
		bne.s .minus
		add.w d0,vi_period(a2)
		move.w vi_tperiod(a2),d0
		cmp.w vi_period(a2),d0
		bgt.s .ok
		bra.s .done
.minus		sub.w d0,vi_period(a2)
		move.w vi_tperiod(a2),d0
		cmp.w vi_period(a2),d0
		blt.s .ok
.done		move.w vi_tperiod(a2),vi_period(a2)
		clr.w vi_tperiod(a2)
.ok		move.w vi_period(a2),sam_period(a1)
.skip		rts
ct_vib		move.b vi_command+3(a2),d0
		beq.s .vib2
		move.b d0,vi_vspeed(a2)
.vib2		move.b vi_vframe(a2),d0
		lsr.w #2,d0
		and.w #$1F,d0
		move.b vi_vspeed(a2),d1
		and.w #$F,d1
		lsl.w #5,d1		;*32
		lea ct_vibtab(pc),a0
		add.w d1,a0		;Point to right tab
		moveq #0,d2
		move.b (a0,d0),d2
		add.w d2,d2
		move.w vi_period(a2),d0
		tst.b vi_vframe(a2)
		bmi.s .vibsub
		add.w d2,d0
		bra.s .vib3
.vibsub		sub.w d2,d0
.vib3		move.w d0,sam_period(a1)
		move.b vi_vspeed(a2),d0
		lsr.w #2,d0
		and.w #$3C,d0
		add.b d0,vi_vframe(a2)
		rts
ct_volslide	moveq #0,d0
		move.b vi_command+3(a2),d0
		cmp.b #16,d0
		bcs.s .down
		lsr.b #4,d0
		add.w vi_volume(a2),d0
		cmp.w #64,d0
		bmi.s .vol2
		moveq #64,d0
		bra.s .vol2
.down		and.b #$F,d0
		neg.w d0
		add.w vi_volume(a2),d0
		bpl.s .vol2
		moveq #0,d0
.vol2		move.w d0,vi_volume(a2)
		move.w d0,sam_vol(a1)
ct_rts		rts
ct_new		clr.w ct_count(a5)
		move.l ct_data_ptr,a3
		lea sf_parts(a3),a3
		move.w position(a5),d0
		lsl.w #3,d0
		lea (a3,d0),a3
		clr.w ct_dma(a5)
		lea ch1s(pc),a1
		lea current(pc),a2
		moveq #1,d7
		bsr ct_playnote
		lea ch2s(pc),a1
		lea current+vi_size(pc),a2
		moveq #2,d7
		bsr ct_playnote
		lea ch3s(pc),a1
		lea current+vi_size*2(pc),a2
		moveq #4,d7
		bsr ct_playnote
		lea ch4s(pc),a1
		lea current+vi_size*3(pc),a2
		moveq #8,d7
		bsr ct_playnote
		tst.w ct_break(a5)
		bne.s .newpat
		addq.w #4,patpos(a5)
		cmp.w #64*4,patpos(a5)
		bne.s .notend
.newpat		clr.w ct_break(a5)
		clr.w patpos(a5)
		addq.w #1,position(a5)
		move.l ct_data_ptr,a6
		move.b sf_length(a6),d0
		cmp.b position+1(a5),d0
		bne.s .notend
		move.l ct_data_ptr,a6
		move.b sf_restart(a6),position+1(a5)
.notend		or.w #$8200,ct_dma(a5)
		lea.l ch1s(PC),a1
		lea current(pc),a2
		rept 4
		moveq #0,d3
		move.l vi_repeat(a2),sam_lpstart(a1)
		move.w vi_replen(a2),d3
		add.l d3,d3
		add.l d3,sam_lpstart(a1)
		move.w d3,sam_lplength(a1)
		lea sam_vcsize(a1),a1
		lea vi_size(a2),a2
		endr
.setdma		move.w ct_vars+ct_dma(pc),d7
		move_dmacon d7
		rts

ct_playnote	moveq #0,d0
		move.b (a3),d0		;Get pat num
		add.w d0,d0
		add.w d0,d0
		lea pattslook(pc),a0
		move.l (a0,d0),a0
		add.w patpos(a5),a0
		move.l (a0),vi_command(a2)
		tst.b vi_command+1(a2)
		beq.s .setreg
		moveq #0,d0
		move.b vi_command+1(a2),d0	;Get samp num.
		lsl.w #4,d0		;*16
		lea samplesinfo-16,a0	;Add to samples info
		lea (a0,d0),a0
		move.l (a0)+,vi_addr(a2)
		move.w (a0)+,vi_length(a2)
		move.l (a0)+,vi_repeat(a2)
		move.w (a0)+,vi_replen(a2)
		move.w (a0),vi_volume(a2)
.setreg		move.w vi_volume(a2),sam_vol(a1)
		moveq #0,d0
		move.b vi_command(a2),d0 ;Get note
		cmp.b #168,d0		;Check for edges of table
		beq.s .com2
		lea periods(pc),a0
		move.b 1(a3),d1
		beq.s .notrans
		ext.w d1
		add.w d1,d1
		add.w d1,d0
.notrans	move.w d0,vi_note(a2)
		move.w (a0,d0),d0
		cmp.b #3,vi_command+2(a2)
		bne.s .setper
		move.w d0,vi_tperiod(a2)
		clr.b vi_tdir(a2)
		cmp.w vi_period(a2),d0
		beq.s .port1
		bge.s .com2
		addq.b #1,vi_tdir(a2)
		bra.s .com2
.port1		clr.w vi_tperiod(a2)
		bra.s .com2
.setper		;move_dmacon d7
		move.w d0,sam_period(a1)
		move.w d0,vi_period(a2)
		clr.b vi_vframe(a2)
		or.w d7,ct_dma(a5)
		move.l vi_addr(a2),sam_start(a1)
		moveq #0,d3
		move.w vi_length(a2),d3
		add.l d3,d3
		add.l d3,sam_start(a1)
		move.w d3,sam_length(a1)
.com2		bsr ct_checkcom2
.voiceoff	addq.l #2,a3
		rts

ct_checkcom2	moveq #0,d0
		move.b vi_command+2(a2),d0	;Command
		add.w d0,d0
		add.w d0,d0
		jmp comtab2(pc,d0)
comtab2		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_songjmp
		bra.w ct_setvol
		bra.w ct_pattbreak
		bra.w ct_filter
		bra.w ct_setspeed
ct_filter	;move.b vi_command+3(a2),d0
		;beq.s .off
		;bset #1,$BFE001
		rts

ct_songjmp	moveq #0,d0
		move.b vi_command+3(a2),d0
		subq.b #1,d0		;Posup rountine correction
		move.w d0,position(a5)
ct_pattbreak	move.w #1,ct_break(a5)
		clr.l vi_command(a2)
		rts
ct_setvol	moveq #0,d0
		move.b vi_command+3(a2),d0
		move.w d0,sam_vol(a1)
		move.w d0,vi_volume(a2)
		rts
ct_setspeed	move.b vi_command+3(a2),d0
		beq.s .nope
		move.w d0,ct_speed(a5)
.nope		rts

		*******************************
		*** Equates and data below! ***
		*******************************

		rsreset
vi_period	rs.w 1		;Period value
vi_volume	rs.w 1		;Default volume
vi_instr	rs.w 1		;Sample number
vi_addr		rs.l 1		;Start of sample
vi_length	rs.w 1		;Length of sample
vi_repeat	rs.l 1		;Repeat address
vi_replen 	rs.w 1		;Repeat length
vi_type		rs.w 1		;Synth=0  Sample=1
vi_command 	rs.l 1		;Period.b Sample.b command.n comval.b
vi_note		rs.w 1		;Period table offset
vi_tdir		rs.b 1		;Which way to slide period
vi_tspeed	rs.b 1		;Speed to slide period
vi_tperiod 	rs.w 1		;Period to slide to
vi_vspeed	rs.b 1		;Speed to warble
vi_vframe	rs.b 1		;Speed count
vi_free		rs.w 1		;Is voice free to use?
vi_size		rs.b 0
		rsreset
position	rs.w 1		;Song position
patpos		rs.w 1		;Which note
ct_count	rs.w 1		;Countdown
ct_speed	rs.w 1		;Speed
ct_dma		rs.w 1		;DMA value
ct_break	rs.w 1		;Pattern break
oldlev6		rs.l 1
chipsize	rs.w 0

periods		dc.w $1AC0,$1940,$17D0,$1680,$1530,$1400,$12E0,$11D0,$10D0,$0FE0,$0F00,$0E28
		dc.w $0D60,$0CA0,$0BE8,$0B40,$0A98,$0A00,$0970,$08E8,$0868,$07F0,$0780,$0714
		dc.w $06B0,$0650,$05F4,$05A0,$054C,$0500,$04B8,$0474,$0434,$03F8,$03C0,$038A
		dc.w $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0,$01C5
		dc.w $01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0,$00E2
		dc.w $00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097,$008F,$0087,$007F,$0078,$0071
		dc.w 0,0,0

pattslook	ds.l 128	;Pointers to patterns
samplesinfo 	ds.b 31*16	;Samplesinfo  addr,len,rep,replen,vol
ct_vibtab	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
		dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18
		ds.b 14*32
nullsamp	dc.l 0
current		ds.b vi_size*4
ct_vars		ds.b chipsize
ct_data_ptr	dc.l ct_data
ct_data		incbin d:\trackers.s\sonicprj.mod\thalamus.mod