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
		BSR INIT_MUSIC
		BRA STspecific
.trigfadein	LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; ensure zero to start with!
		LEA fadeINflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		BSR INIT_MUSIC
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
		SF.B audblockvc1	
		SF.B audblockvc2	
		SF.B audblockvc3	
		SF.B audblockvc4	

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
		BRA PLAY
skipit		RTS

		RSRESET
Vaddr		RS.L 1
Voffy		RS.L 1
Vfrac		RS.W 1
Vfreq		RS.L 1				; structure produced
Vvoltab		RS.W 1				; from 'paula' data
Vlpaddr		RS.L 1
Vlpoffy		RS.L 1
Vlpfreq		RS.L 1
Vstrucsize	RS.B 0

; Routine to add/move one voice to buffer. The real Paula emulation part!!

freqconst	EQU $8EFE3B

SetupVoice	MOVE.L sam_start(A5),A2		; current sample end address(shadow amiga!)
		MOVEM.W sam_length(A5),D0/D1/D2	; offset/period/volume
		AND.L #$FFFF,D0
		NEG.L D0

		CMP.W #$40,D2
		BLS.S .ok
		MOVEQ #$40,D2
.ok		MULU global_vol(PC),D2
		LSR #6,D2			; /64
		EXT.L D1
		BEQ.S .zero
		MOVE.L #freqconst,D5 
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
.zero		LSL.W #8,D2			; offset into volume tab
		MOVE.W shadow_dmacon(PC),D5
		BTST D4,D5
		BNE.S .vcon2
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon2		LEA nulsamp+2(PC),A6
		CMP.L A6,A2
		BNE.S .vcon
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon		MOVE.L sam_lpstart(a5),A6	; loop addr
		MOVEQ #0,D5
		MOVE.W sam_lplength(a5),D5	; loop length
		MOVE.L D1,D7			; freq on loop
		CMP.L #2,D5
		BNE.S isloop
.noloop		MOVEQ #0,D7			; no loop-no frequency
		LEA nulsamp+2(PC),A6		; no loop-point to nul
isloop		MOVE.L A2,(A0)+			; store address
		MOVE.L D0,(A0)+			; store offset
		ADDQ.W #2,A0
		MOVE.L D1,(A0)+			; store int.w/frac.w
		MOVE.W D2,(A0)+			; address of volume tab.
		MOVE.L A6,(A0)+			; store loop addr
		MOVE.L D5,(A0)+			; store loop offset.
		MOVE.L D7,(A0)+			; store loop freq int.w/frac.w
		RTS

Voice1Set	DS.B Vstrucsize
Voice2Set	DS.B Vstrucsize
Voice3Set	DS.B Vstrucsize
Voice4Set	DS.B Vstrucsize

; Make that buffer! (channels are paired together!)

Goforit		PEA (A4)			; save buff ptr
channels12	MOVE.L Voice1Set(PC),A0		; ptr to end of each sample!
		MOVE.L Voice2Set(PC),A1
		MOVE.L Voice1Set+Voffy(PC),D0	; curr int.w offset
		MOVE.W Voice1Set+Vfrac(PC),D6	; curr int.w offset
		MOVE.L Voice2Set+Voffy(PC),D1
		MOVE.W Voice2Set+Vfrac(PC),D4
		MOVEM.W Voice1Set+Vfreq(PC),D7/A2 ; int.w/frac.w freq
		MOVEM.W Voice2Set+Vfreq(PC),D5/A3	
		SWAP D6

		MOVE.W fillx1(PC),D6	
		BSR add12			; fill first bit
		MOVE.W fillx2(PC),D6
		MOVE.W fillx1(PC),D4
		BEQ.S .nores
		LEA.L buffer(pc),A4		; (overlap case)
.nores		BSR add12			; and do remaining
		LEA ch1s(PC),A5
		LEA Voice1Set(PC),A4
		NEG.L D0			; +ve offset(as original!)
		MOVE.L A0,sam_start(A5)		; store voice address
		MOVE.W D0,sam_length(A5)	; store offset for next time
		SWAP D6
		MOVE.W D6,Vfrac(A4)		; store frac part
		LEA ch2s(PC),A5
		LEA Voice2Set(PC),A4
		NEG.L D1		
		MOVE.L A1,sam_start(A5)		; same for chan 2
		MOVE.W D1,sam_length(A5)		
		MOVE.W D4,Vfrac(A4)
		MOVE.L (SP)+,A4

channels34	MOVE.L Voice3Set(PC),A0		; ptr to end of each sample!
		MOVE.L Voice4Set(PC),A1
		MOVE.L Voice3Set+Voffy(PC),D0	; curr int.w offset
		MOVE.W Voice3Set+Vfrac(PC),D6	; curr int.w offset
		MOVE.L Voice4Set+Voffy(PC),D1
		MOVE.W Voice4Set+Vfrac(PC),D4
		MOVEM.W Voice3Set+Vfreq(PC),D7/A2 ; int.w/frac.w freq
		MOVEM.W Voice4Set+Vfreq(PC),D5/A3	
		SWAP D6
		MOVE.W fillx1(PC),D6	
		BSR add34			; fill first bit
		MOVE.W fillx2(PC),D6
		MOVE.W fillx1(PC),D4
		BEQ.S .nores
		LEA.L buffer(pc),A4		; (overlap case)
.nores		BSR add34			; and do remaining
		LEA ch3s(PC),A5
		LEA Voice3Set(PC),A4
		NEG.L D0			
		MOVE.L A0,sam_start(A5)			
		MOVE.W D0,sam_length(A5)	; as above
		SWAP D6
		MOVE.W D6,Vfrac(A4)
		LEA ch4s(PC),A5
		LEA Voice4Set(PC),A4
		NEG.L D1		
		MOVE.L A1,sam_start(A5)			
		MOVE.W D1,sam_length(A5)		
		MOVE.W D4,Vfrac(A4)
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
make12_stelp	SWAP D6
		MOVE.B (A0,D0.L),D2
		MOVE.L D2,A5
		MOVE.B (A5),D2
		MOVE.B (A1,D1.L),D3
		MOVE.L D3,A5
		ADD.B (A5),D2
		MOVE.B D2,(SP)+
		ADD.W A2,D6
		ADDX D7,D0
		BCS.S lpvc1ste
contlp1ste	SWAP D6
		ADD.W A3,D4
		ADDX D5,D1
contlp2ste	DBCS D6,make12_stelp
		BCS lpvc2ste
		MOVE.L savesp12(PC),SP
		RTS
savesp12	DC.L 0

lpvc1ste	ST.B audblockvc1
		MOVEM.W Voice1Set+Vlpfreq(PC),D7/A2
		MOVE.L Voice1Set+Vlpaddr(PC),A0		; loop voice 1
		AND.L #$FFFF,D0
		SUB.L  Voice1Set+Vlpoffy(PC),D0		
		BRA.S contlp1ste

lpvc2ste	ST.B audblockvc2
		MOVEM.W Voice2Set+Vlpfreq(PC),D5/A3
		MOVE.L Voice2Set+Vlpaddr(PC),A1		;      "     2
		AND.L #$FFFF,D1
		SUB.L  Voice2Set+Vlpoffy(PC),D1		
		MOVE.W #0,CCR
		BRA.S contlp2ste

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
make34lp	MOVE.B (A0,D0.L),D2
		MOVE.L D2,A5
		MOVE.B (A5),D4
		MOVE.B (A1,D1.L),D3
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
		ADD.L  Voice3Set+Vlpoffy(PC),D0
		BRA.S contlp3

lpvc4		MOVE.L Voice4Set+Vlpfreq(PC),A3
		MOVE.L Voice4Set+Vlpaddr(PC),A1		;      "     4
		ADD.L  Voice4Set+Vlpoffy(PC),D1	
		BRA.S contlp4

make34_ste	MOVE.L SP,savesp34
		LEA 1(A4),SP		;A6/A4 free
make34_stelp	SWAP D6
		MOVE.B (A0,D0.L),D2
		MOVE.L D2,A5
		MOVE.B (A5),D2
		MOVE.B (A1,D1.L),D3
		MOVE.L D3,A5
		ADD.B (A5),D2
		MOVE.B D2,(SP)+
		ADD.W A2,D6
		ADDX D7,D0
		BCS.S lpvc3ste
contlp3ste	SWAP D6
		ADD.W A3,D4
		ADDX D5,D1
contlp4ste	DBCS D6,make34_stelp
		BCS lpvc4ste

		MOVE.L savesp34(PC),SP
		RTS
lpvc3ste	ST.B audblockvc3
		MOVEM.W Voice3Set+Vlpfreq(PC),D7/A2
		MOVE.L Voice3Set+Vlpaddr(PC),A0		; loop voice 3
		AND.L #$FFFF,D0
		SUB.L  Voice3Set+Vlpoffy(PC),D0
		BRA.S contlp3ste

lpvc4ste	ST.B audblockvc4
		MOVEM.W Voice4Set+Vlpfreq(PC),D5/A3
		MOVE.L Voice4Set+Vlpaddr(PC),A1		;      "     4
		AND.L #$FFFF,D1
		SUB.L  Voice4Set+Vlpoffy(PC),D1	
		MOVE.W #0,CCR
		BRA.S contlp4ste
savesp34	DC.L 0

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
		BeQ.S .ok1
		MOVE.B  #-1,(A5)
.ok1		move_dff09a 70(a5)
		move_dff09c 70(a5)
.novc1		TST.B audblockvc2
		BEQ.S .novc2
		;LEA L00B9,A5
		MOVE.W  shadow_dff09c(PC),D4
		AND.W   shadow_dff09a(PC),D4
		BTST #8,D4
		BEQ.S .ok2
		MOVE.B  #-1,(A5)
.ok2		move_dff09a 70(a5)
		move_dff09c 70(a5)
.novc2		TST.B audblockvc3
		BEQ.S .novc3
		;LEA L00BA,A5
		MOVE.W  shadow_dff09c(PC),D4
		AND.W   shadow_dff09a(PC),D4
		BTST #9,D4
		BeQ.S .ok3
	  	MOVE.B  #-1,(A5)
.ok3		move_dff09a 70(a5)
		move_dff09c 70(a5)
.novc3		TST.B audblockvc4
		BEQ.S .novc4
		;LEA L00BB,A5
		MOVE.W  shadow_dff09c(PC),D4
		AND.W   shadow_dff09a(PC),D4
		BTST #10,D4
		BeQ.S .ok4
		MOVE.B  #-1,(A5)
.ok4		move_dff09a 70(a5)
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

vols		DS.L 64
		INCBIN D:\TRACKERS.S\FUT_PLAY.INC\PT_VOLTA.DAT

*********************************************************
**  Amiga FUTURE COMPOSER  »» V1.4 ««  Replay routine  **
*********************************************************
;Doesn't work with V1.0 - V1.3 modules !!

END_MUSIC:
	clr.w onoff
	rts

INIT_MUSIC:
	move.w #1,onoff
	move.l fc_mod_ptr,a0
	lea 180(a0),a1
	move.l a1,SEQpoint
	move.l a0,a1
	add.l 8(a0),a1
	move.l a1,PATpoint
	move.l a0,a1
	add.l 16(a0),a1
	move.l a1,FRQpoint
	move.l a0,a1
	add.l 24(a0),a1
	move.l a1,VOLpoint
	move.l 4(a0),d0
	divu #13,d0

	lea 40(a0),a1
	lea SOUNDINFO+4(pc),a2
	moveq #10-1,d1
initloop:
	move.w (a1)+,(a2)+
	move.l (a1)+,(a2)+
	adda.w #10,a2
	dbf d1,initloop
	move.l a0,d1
	add.l 32(a0),d1
	lea SOUNDINFO(pc),a3
	move.l d1,(a3)+
	moveq #9-1,d3
	moveq #0,d2
initloop1:
	move.w (a3),d2
	add.l d2,d1
	add.l d2,d1
	addq.l #2,d1
	adda.w #12,a3
	move.l d1,(a3)+
	dbf d3,initloop1

	lea 100(a0),a1
	lea SOUNDINFO+(10*16)(pc),a2
	move.l a0,a3
	add.l 36(a0),a3

	moveq #80-1,d1
	moveq #0,d2
initloop2:
	move.l a3,(a2)+
	move.b (a1)+,d2
	move.w d2,(a2)+
	clr.w (a2)+
	move.w d2,(a2)+
	addq.w #6,a2
	add.w d2,a3
	add.w d2,a3
	dbf d1,initloop2

	move.l SEQpoint(pc),a0
	moveq #0,d2
	move.b 12(a0),d2		;Get replay speed
	bne.s speedok
	move.b #3,d2			;Set default speed
speedok:
	move.w d2,respcnt		;Init repspeed counter
	move.w d2,repspd
INIT2:
	clr.w audtemp
	move.w #$0,shadow_dmacon
	moveq #0,d7
	mulu #13,d0
	moveq #4-1,d6			;Number of soundchannels-1
	lea V1data(pc),a0		;Point to 1st voice data area
	lea silent(pc),a1
	lea Chandata(pc),a2
initloop3:
	move.l a1,10(a0)
	move.l a1,18(a0)
	clr.w 4(a0)
	move.w #$000d,6(a0)
	clr.w 8(a0)
	clr.l 14(a0)
	move.b #$01,23(a0)
	move.b #$01,24(a0)
	clr.b 25(a0)
	clr.l 26(a0)
	clr.w 30(a0)
	clr.l 38(a0)
	clr.w 42(a0)
	clr.l 44(a0)
	clr.l 48(a0)
	clr.w 56(a0)
	moveq #$00,d3
	move.w (a2)+,d1
	move.w (a2),d3
	divu #$0003,d3
	moveq #0,d4
	bset d3,d4
	move.w d4,32(a0)
	move.w (a2)+,d3
	andi.l #$00ff,d3
	andi.l #$00ff,d1
	lea ch1s(pc),a6
	add.w d1,a6
	move.l a6,60(a0)
	move.l SEQpoint(pc),(a0)
	move.l SEQpoint(pc),52(a0)
	add.l d0,52(a0)
	add.l d3,52(a0)
	add.l d7,(a0)
	add.l d3,(a0)
	move.l (a0),a3
	move.b (a3),d1
	andi.l #$00ff,d1
	lsl.w #6,d1
	move.l PATpoint(pc),a4
	adda.w d1,a4
	move.l a4,34(a0)
	move.b 1(a3),44(a0)
	move.b 2(a3),22(a0)
	lea $4a(a0),a0		;Point to next voice's data area
	dbf d6,initloop3
	rts


PLAY:
	lea audtemp(pc),a5
	tst.w 8(a5)
	bne.s music_ison
	rts
music_ison:
	subq.w #1,4(a5)			;Decrease replayspeed counter
	bne.s nonewnote
	move.w 6(a5),4(a5)		;Restore replayspeed counter
	moveq #0,d5
	moveq #6,d6
	lea V1data(pc),a0		;Point to voice1 data area
	bsr.w new_note
	lea V2data(pc),a0		;Point to voice2 data area
	bsr.w new_note
	lea V3data(pc),a0		;Point to voice3 data area
	bsr.w new_note
	lea V4data(pc),a0		;Point to voice4 data area
	bsr.w new_note
nonewnote:
	clr.w (a5)
	lea ch1s(pc),a6
	lea V1data(pc),a0
	bsr.w effects
	move.l d0,sam_period(a6)
	lea V2data(pc),a0
	bsr.w effects
	move.l d0,(sam_vcsize*1)+sam_period(a6)
	lea V3data(pc),a0
	bsr.w effects
	move.l d0,(sam_vcsize*2)+sam_period(a6)
	lea V4data(pc),a0
	bsr.w effects
	move.l d0,(sam_vcsize*3)+sam_period(a6)
	lea V1data(pc),a0
	move.l 68+(0*74)(a0),a1		;Get samplepointer
	adda.w 64+(0*74)(a0),a1		;add repeat_start
	move.l 68+(1*74)(a0),a2
	adda.w 64+(1*74)(a0),a2
	move.l 68+(2*74)(a0),a3
	adda.w 64+(2*74)(a0),a3
	move.l 68+(3*74)(a0),a4
	adda.w 64+(3*74)(a0),a4
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	moveq #0,d4
	move.w 66+(0*74)(a0),d1		;Get repeat_length
	move.w 66+(1*74)(a0),d2
	move.w 66+(2*74)(a0),d3
	move.w 66+(3*74)(a0),d4
	add.w d1,d1
	add.w d2,d2
	add.w d3,d3
	add.w d4,d4

	moveq #2,d0
	moveq #0,d5
	move.w (a5),d7
	ori.w #$8000,d7			;Set/clr bit = 1
	move_dmacon d7
chan1:
	lea V1data+72(pc),a0
	move.w (a0),d7
	beq.s chan2
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan2
	move.w d5,(a0)
	move.l a1,sam_lpstart(a6)	;Set samplestart
	add.l d1,sam_lpstart(a6)
	move.w d1,sam_lplength(a6)	;Set samplelength

chan2:	lea sam_vcsize(a6),a6
	lea V2data+72(pc),a0
	move.w (a0),d7
	beq.s chan3
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan3
	move.w d5,(a0)
	move.l a2,sam_lpstart(a6)
	add.l d2,sam_lpstart(a6)
	move.w d2,sam_lplength(a6)

chan3:	lea sam_vcsize(a6),a6
	lea V3data+72(pc),a0
	move.w (a0),d7
	beq.s chan4
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan4
	move.w d5,(a0)
	move.l a3,sam_lpstart(a6)
	add.l d3,sam_lpstart(a6)
	move.w d3,sam_lplength(a6)
chan4:	lea sam_vcsize(a6),a6
	lea V4data+72(pc),a0
	move.w (a0),d7
	beq.s endplay
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s endplay
	move.w d5,(a0)
	move.l a4,sam_lpstart(a6)
	add.l d4,sam_lpstart(a6)
	move.w d4,sam_lplength(a6)
endplay:
	rts

NEW_NOTE:
	move.l 34(a0),a1
	adda.w 40(a0),a1
	cmp.b #$49,(a1)		;Check "END" mark in pattern
	beq.s patend
	cmp.w #64,40(a0)	;Have all the notes been played?
	bne.w samepat
patend:
	move.w d5,40(a0)
	move.l (a0),a2
	adda.w 6(a0),a2		;Point to next sequence row
	cmpa.l 52(a0),a2	;Is it the end?
	bne.s notend
	move.w d5,6(a0)		;yes!
	move.l (a0),a2		;Point to first sequence
notend:
	lea spdtemp(pc),a3
	moveq #1,d1
	addq.b #1,(a3)
	cmpi.b #5,(a3)
	bne.s nonewspd
	move.b d1,(a3)
	move.b 12(a2),d1	;Get new replay speed
	beq.s nonewspd
	move.w d1,2(a3)		;store in counter
	move.w d1,4(a3)
nonewspd:
	move.b (a2)+,d1		;Pattern to play
	move.b (a2)+,44(a0)	;Transpose value
	move.b (a2)+,22(a0)	;Soundtranspose value
	lsl.w d6,d1
	move.l PATpoint(pc),a1	;Get pattern pointer
	add.w d1,a1
	move.l a1,34(a0)
	addi.w #$000d,6(a0)
samepat:
	move.b 1(a1),d1		;Get info byte
	move.b (a1)+,d0		;Get note
	bne.s ww1
	andi.w #%11000000,d1
	beq.s noport
	bra.s ww11
ww1:
	move.w d5,56(a0)
ww11:
	move.b d5,47(a0)
	btst #7,d1
	beq.s noport
	move.b 2(a1),47(a0)	
noport:
	andi.w #$007f,d0
	beq.w nextnote
	move.b d0,8(a0)
	move.b (a1),d1
	move.b d1,9(a0)
	move.w 32(a0),d3
	or.w d3,(a5)
	move_dmacon d3
	andi.w #$003f,d1	;Max 64 instruments
	add.b 22(a0),d1		;add Soundtranspose
	move.l VOLpoint(pc),a2
	lsl.w d6,d1
	adda.w d1,a2
	move.w d5,16(a0)
	move.b (a2),23(a0)
	move.b (a2)+,24(a0)
	moveq #0,d1
	move.b (a2)+,d1
	move.b (a2)+,27(a0)
	move.b #$40,46(a0)
	move.b (a2),28(a0)
	move.b (a2)+,29(a0)
	move.b (a2)+,30(a0)
	move.l a2,10(a0)
	move.l FRQpoint(pc),a2
	lsl.w d6,d1
	adda.w d1,a2
	move.l a2,18(a0)
	move.w d5,50(a0)
	move.b d5,25(a0)
	move.b d5,26(a0)
nextnote:
	addq.w #2,40(a0)
	rts

EFFECTS:
	moveq #0,d7
testsustain:
	tst.b 26(a0)		;Is sustain counter = 0
	beq.s sustzero
	subq.b #1,26(a0)	;if no, decrease counter
	bra.w VOLUfx
sustzero:			;Next part of effect sequence
	move.l 18(a0),a1	;can be executed now.
	adda.w 50(a0),a1
testeffects:
	cmpi.b #$e1,(a1)	;E1 = end of FREQseq sequence
	beq.w VOLUfx
	move.b (a1),d0
	cmpi.b #$e0,d0		;E0 = loop to other part of sequence
	bne.s testnewsound
	move.b 1(a1),d1		;loop to start of sequence + 1(a1)
	andi.w #$003f,d1
	move.w d1,50(a0)
	move.l 18(a0),a1
	adda.w d1,a1
	move.b (a1),d0
testnewsound:
	cmpi.b #$e2,d0		;E2 = set waveform
	bne testE4
	move.w 32(a0),d1
	or.w d1,(a5)
	move_dmacon d1
	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO(pc),a4
	lsl.w #4,d0
	adda.w d0,a4
	move.l 60(a0),a3
	move.l (a4)+,d1
	move.l d1,sam_start(a3)
	move.l d1,sam_lpstart(a3)

	move.l d1,-(sp)
	moveq #0,d1
	move.w (a4)+,d1
	add.w d1,d1
	add.l d1,sam_start(a3)
	add.l d1,sam_lpstart(a3)
	move.w d1,sam_length(a3)
	move.w d1,sam_lplength(a3)
	move.l (sp)+,d1

	move.l d1,68(a0)
	move.l (a4),64(a0)
	move.w #$0003,72(a0)
	move.w d7,16(a0)
	move.b #$01,23(a0)
	addq.w #2,50(a0)
	bra.w 	transpose
testE4:
	cmpi.b #$e4,d0
	bne.s testE9
	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO(pc),a4
	lsl.w #4,d0
	adda.w d0,a4
	move.l 60(a0),a3
	move.l (a4)+,d1
	move.l d1,sam_start(a3)
	move.l d1,sam_lpstart(a3)
	move.l d1,-(sp)
	moveq #0,d1
	move.w (a4)+,d1
	add.w d1,d1
	add.l d1,sam_start(a3)
	add.l d1,sam_lpstart(a3)
	move.w d1,sam_length(a3)
	move.w d1,sam_lplength(a3)
	move.l (sp)+,d1

	move.l d1,68(a0)
	move.l (a4),64(a0)
	move.w #$0003,72(a0)
	addq.w #2,50(a0)
	bra.w transpose
testE9:
	cmpi.b #$e9,d0
	bne testpatjmp
	move.w 32(a0),d1
	or.w d1,(a5)
	move_dmacon d1
	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO(pc),a4
	lsl.w #4,d0
	adda.w d0,a4
	move.l (a4),a2
	cmpi.l #"SSMP",(a2)+
	bne.s nossmp
	lea 320(a2),a4
	moveq #0,d1
	move.b 2(a1),d1
	lsl.w #4,d1
	add.w d1,a2
	add.l (a2),a4
	move.l 60(a0),a3
	move.l a4,sam_start(a3)
	move.l a4,sam_lpstart(a3)

	move.l d1,-(sp)
	moveq #0,d1
	move.w 4(a2),d1
	add.w d1,d1
	add.l d1,sam_start(a3)
	add.l d1,sam_lpstart(a3)
	move.w d1,sam_length(a3)
	move.w d1,sam_lplength(a3)
	move.l (sp)+,d1

	move.w 6(a2),sam_period(a3)
	move.l a4,68(a0)
	move.l 6(a2),64(a0)
	move.w d7,16(a0)
	move.b #1,23(a0)
	move.w #3,72(a0)
nossmp:
	addq.w #3,50(a0)
	bra.s transpose
testpatjmp:
	cmpi.b #$e7,d0
	bne.s testpitchbend
	moveq #0,d0
	move.b 1(a1),d0
	lsl.w d6,d0
	move.l FRQpoint(pc),a1
	adda.w d0,a1
	move.l a1,18(a0)
	move.w d7,50(a0)
	bra.w testeffects
testpitchbend:
	cmpi.b #$ea,d0
	bne.s testnewsustain
	move.b 1(a1),4(a0)
	move.b 2(a1),5(a0)
	addq.w #3,50(a0)
	bra.s transpose
testnewsustain:
	cmpi.b #$e8,d0
	bne.s testnewvib
	move.b 1(a1),26(a0)
	addq.w #2,50(a0)
	bra.w testsustain
testnewvib:
	cmpi.b #$e3,(a1)+
	bne.s transpose
	addq.w #3,50(a0)
	move.b (a1)+,27(a0)
	move.b (a1),28(a0)
transpose:
	move.l 18(a0),a1
	adda.w 50(a0),a1
	move.b (a1),43(a0)
	addq.w #1,50(a0)

VOLUfx:
	tst.b 25(a0)
	beq.s volsustzero
	subq.b #1,25(a0)
	bra.w calcperiod
volsustzero:
	tst.b 15(a0)
	bne.s do_VOLbend
	subq.b #1,23(a0)
	bne.s calcperiod
	move.b 24(a0),23(a0)
volu_cmd:
	move.l 10(a0),a1
	adda.w 16(a0),a1
	move.b (a1),d0
testvoluend:
	cmpi.b #$e1,d0
	beq.s calcperiod
	cmpi.b #$ea,d0
	bne.s testVOLsustain
	move.b 1(a1),14(a0)
	move.b 2(a1),15(a0)
	addq.w #3,16(a0)
	bra.s do_VOLbend
testVOLsustain:
	cmpi.b #$e8,d0
	bne.s testVOLloop
	addq.w #2,16(a0)
	move.b 1(a1),25(a0)
	bra.s calcperiod
testVOLloop:
	cmpi.b #$e0,d0
	bne.s setvolume
	move.b 1(a1),d0
	andi.w #$003f,d0
	subq.b #5,d0
	move.w d0,16(a0)
	bra.s volu_cmd
do_VOLbend:
	not.b 38(a0)
	beq.s calcperiod
	subq.b #1,15(a0)
	move.b 14(a0),d1
	add.b d1,45(a0)
	bpl.s calcperiod
	moveq #0,d1
	move.b d1,15(a0)
	move.b d1,45(a0)
	bra.s calcperiod
setvolume:
	move.b (a1),45(a0)
	addq.w #1,16(a0)
calcperiod:
	move.b 43(a0),d0
	bmi.s lockednote
	add.b 8(a0),d0
	add.b 44(a0),d0
lockednote:
	moveq #$7f,d1
	and.l d1,d0
	lea PERIODS(pc),a1
	add.w d0,d0
	move.w d0,d1
	adda.w d0,a1
	move.w (a1),d0

	move.b 46(a0),d7
	tst.b 30(a0)		;Vibrato_delay = zero ?
	beq.s vibrator
	subq.b #1,30(a0)
	bra.s novibrato
vibrator:
	moveq #5,d2
	move.b d1,d5
	move.b 28(a0),d4
	add.b d4,d4
	move.b 29(a0),d1
	tst.b d7
	bpl.s vib1
	btst #0,d7
	bne.s vib4
vib1:
	btst d2,d7
	bne.s vib2
	sub.b 27(a0),d1
	bcc.s vib3
	bset d2,d7
	moveq #0,d1
	bra.s vib3
vib2:
	add.b 27(a0),d1
	cmp.b d4,d1
	bcs.s vib3
	bclr d2,d7
	move.b d4,d1
vib3:
	move.b d1,29(a0)
vib4:
	lsr.b #1,d4
	sub.b d4,d1
	bcc.s vib5
	subi.w #$0100,d1
vib5:
	addi.b #$a0,d5
	bcs.s vib7
vib6:
	add.w d1,d1
	addi.b #$18,d5
	bcc.s vib6
vib7:
	add.w d1,d0
novibrato:
	eori.b #$01,d7
	move.b d7,46(a0)

; DO THE PORTAMENTO THING
	not.b 39(a0)
	beq.s pitchbend
	moveq #0,d1
	move.b 47(a0),d1	;get portavalue
	beq.s pitchbend		;0=no portamento
	cmpi.b #$1f,d1
	bls.s portaup
portadown: 
	andi.w #$1f,d1
	neg.w d1
portaup:
	sub.w d1,56(a0)
pitchbend:
	not.b 42(a0)
	beq.s addporta
	tst.b 5(a0)
	beq.s addporta
	subq.b #1,5(a0)
	moveq #0,d1
	move.b 4(a0),d1
	bpl.s pitchup
	ext.w d1
pitchup:
	sub.w d1,56(a0)
addporta:
	add.w 56(a0),d0
	cmpi.w #$0070,d0
	bhi.s nn1
	move.w #$0071,d0
nn1:
	cmpi.w #$0d60,d0
	bls.s nn2
	move.w #$0d60,d0
nn2:
	swap d0
	move.b 45(a0),d0
	rts


V1data:  dcb.b 64,0	;Voice 1 data area
offset1: dcb.b 02,0	;Is added to start of sound
ssize1:  dcb.b 02,0	;Length of sound
start1:  dcb.b 06,0	;Start of sound

V2data:  dcb.b 64,0	;Voice 2 data area
offset2: dcb.b 02,0
ssize2:  dcb.b 02,0
start2:  dcb.b 06,0

V3data:  dcb.b 64,0	;Voice 3 data area
offset3: dcb.b 02,0
ssize3:  dcb.b 02,0
start3:  dcb.b 06,0

V4data:  dcb.b 64,0	;Voice 4 data area
offset4: dcb.b 02,0
ssize4:  dcb.b 02,0
start4:  dcb.b 06,0

audtemp: dc.w 0		;DMACON
spdtemp: dc.w 0
respcnt: dc.w 0		;Replay speed counter 
repspd:  dc.w 0		;Replay speed counter temp
onoff:   dc.w 0		;Music on/off flag.

Chandata: dc.l $00000000,$00100003,$00200006,$00300009
SEQpoint: dc.l 0
PATpoint: dc.l 0
FRQpoint: dc.l 0
VOLpoint: dc.l 0


SILENT: dc.w $0100,$0000,$0000,$00e1

PERIODS:dc.w $06b0,$0650,$05f4,$05a0,$054c,$0500,$04b8,$0474
	dc.w $0434,$03f8,$03c0,$038a,$0358,$0328,$02fa,$02d0
	dc.w $02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
	dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d
	dc.w $010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4
	dc.w $00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071
	dc.w $0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w $0071,$0071,$0071,$0071,$0d60,$0ca0,$0be8,$0b40
	dc.w $0a98,$0a00,$0970,$08e8,$0868,$07f0,$0780,$0714
	dc.w $1ac0,$1940,$17d0,$1680,$1530,$1400,$12e0,$11d0
	dc.w $10d0,$0fe0,$0f00,$0e28,$06b0,$0650,$05f4,$05a0
	dc.w $054c,$0500,$04b8,$0474,$0434,$03f8,$03c0,$038a
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a
	dc.w $021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d,$0168
	dc.w $0153,$0140,$012e,$011d,$010d,$00fe,$00f0,$00e2
	dc.w $00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f
	dc.w $0087,$007f,$0078,$0071

SOUNDINFO:
;Start.l , Length.w , Repeat start.w , Repeat-length.w , blk.b 6,0 

	dcb.b 10*16,0	;Reserved for samples
	dcb.b 80*16,0	;Reserved for waveforms
		even
fc_mod_ptr	DC.L MODULE

MODULE		INCBIN d:\trackers.s\future.mod\shaolin2.fut
