;-----------------------------------------------------------------------;
; JamCracker Replay (ST/STE)						;
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

LOADTUNE	EQU 1				; 

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
		MOVEQ #LOADTUNE,D0
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
		MOVE.W #$777,$FFFF8240.W
		BSR rotfile+4			; call sequencer
		MOVE.W #$200,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE


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
		BSR _pp_init
		BRA STspecific
.trigfadein	LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; ensure zero to start with!
		LEA fadeINflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		BSR _pp_init
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

; Macro to move parameter '\1' into the shadow dma register...
; (Remember - bit 15 of 'dmacon' determines clearing or setting of bits!)

move_dmacon	MACRO
.setdma\@	MOVE.W D4,-(sp)			; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dmacon		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dmacon		; not zero so set 'em
.dmacon_set\@	MOVE.W (SP)+,D4			; restore D4
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
		LEA.L Voice1Set(PC),A0		; Setup Chan 1
		LEA.L ch1s(PC),A5
		BSR SetupVoice		
		LEA.L Voice2Set(PC),A0		;      "     2
		LEA.L ch2s(PC),A5
		BSR SetupVoice		
		LEA.L Voice3Set(PC),A0  	;      "     3
		LEA.L ch3s(PC),A5
		BSR SetupVoice
		LEA.L Voice4Set(PC),A0  	;      "     4
		LEA.L ch4s(PC),A5
		BSR SetupVoice
		BSR Goforit
		BRA pp_play			; jump to sequencer
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
		MULU global_vol(PC),D2
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
		LEA nulsamp+2(PC),A6
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
		MOVEQ #0,D4
make12_stelp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A5
		MOVE.B (A5),D4
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A5
		ADD.B (A5),D4
		MOVE.B D4,(SP)+
		MOVEQ #0,D4
		ADD.L A2,D0
		ADDX D4,D0
		BGE.S lpvc1ste
contlp1ste	ADD.L A3,D1
		ADDX D4,D1
contlp2ste	DBGE D6,make12_stelp
		BGE.S lpvc2ste
		MOVE.L savesp12(PC),SP
		RTS
savesp12	DC.L 0

lpvc1ste	MOVE.L Voice1Set+Vlpfreq(PC),A2
		MOVE.L Voice1Set+Vlpaddr(PC),A0		; loop voice 1
		ADD.W  Voice1Set+Vlpoffy(PC),D0		
		BRA.S contlp1ste

lpvc2ste	MOVE.L Voice2Set+Vlpfreq(PC),A3
		MOVE.L Voice2Set+Vlpaddr(PC),A1		;      "     2
		ADD.W  Voice2Set+Vlpoffy(PC),D1		
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
		
		MOVEQ #0,D4
make34_stelp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A5
		MOVE.B (A5),D4
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A5
		ADD.B (A5),D4
		MOVE.B D4,(SP)+
		MOVEQ #0,D4
		ADD.L A2,D0
		ADDX D4,D0
		BGE.S lpvc3ste
contlp3ste	ADD.L A3,D1
		ADDX D4,D1
contlp4ste	DBGE D6,make34_stelp
		BGE.S lpvc4ste
		MOVE.L savesp34(PC),SP
		RTS
savesp34	DC.L 0
lpvc3ste	MOVE.L Voice3Set+Vlpfreq(PC),A2
		MOVE.L Voice3Set+Vlpaddr(PC),A0		; loop voice 3
		ADD.W  Voice3Set+Vlpoffy(PC),D0
		BRA.S contlp3ste

lpvc4ste	MOVE.L Voice4Set+Vlpfreq(PC),A3
		MOVE.L Voice4Set+Vlpaddr(PC),A1		;      "     4
		ADD.W  Voice4Set+Vlpoffy(PC),D1	
		BRA.S contlp4ste

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

Ste_Test	LEA ste_flag(PC),A6
		SF (A6)				; assume ST
		LEA $FFFF8205.W,A5
		MOVEQ #-54,D1
		MOVE.B (A5),D0
		MOVE.B D1,(A5)
		CMP.B (A5),D0
		BEQ .notSTE
		MOVE.B	D0,(a5)
.ste_found	ST (A6)				; well sorry its STE!
.notSTE		RTS

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
		DS.B 16640

                  ****************************************
                  *** JamCrackerPro V1.0a play-routine ***
                  ***   Originally coded by M. Gemmel  ***
                  ***           Code optimised         ***
                  ***         by Xag of Betrayal       ***
                  ***    See docs for important info   ***
                  ****************************************

	*** Relative offset definitions ***

		RSRESET		;Instrument info structure
it_name		RS.B	31
it_flags	RS.B	1
it_size		RS.L	1
it_address	RS.L	1
it_sizeof	RS.W	0

		RSRESET		;Pattern info structure
pt_size		RS.W	1
pt_address	RS.L	1
pt_sizeof	RS.W	0

		RSRESET		;Note info structure
nt_period	RS.B	1
nt_instr	RS.B	1
nt_speed	RS.B	1
nt_arpeggio	RS.B	1
nt_vibrato	RS.B	1
nt_phase	RS.B	1
nt_volume	RS.B	1
nt_porta	RS.B	1
nt_sizeof	RS.W	0

		RSRESET		;Voice info structure
pv_waveoffset	RS.W	1
pv_dmacon		RS.W	1
pv_custbase	RS.L	1
pv_inslen		RS.W	1
pv_insaddress	RS.L	1
pv_peraddress	RS.L	1
pv_pers		RS.W	3
pv_por		RS.W	1
pv_deltapor	RS.W	1
pv_porlevel	RS.W	1
pv_vib		RS.W	1
pv_deltavib	RS.W	1
pv_vol		RS.W	1
pv_deltavol	RS.W	1
pv_vollevel	RS.W	1
pv_phase		RS.W	1
pv_deltaphase	RS.W	1
pv_vibcnt		RS.B	1
pv_vibmax		RS.B	1
pv_flags		RS.B	1
pv_sizeof		RS.W	0

	*** Initialise routine ***

_pp_init:	movem.l d0-d7/a0-a6,-(sp)
;		move.l	_adr_data,a0
		lea mt_data,a0
		addq.w	#4,a0
		move.w	(a0)+,d0
		move.w	d0,d1
		move.l	a0,instable
		mulu	#it_sizeof,d0
		add.w	d0,a0

		move.w	(a0)+,d0
		move.w	d0,d2
		move.l	a0,patttable
		mulu	#pt_sizeof,d0
		add.w	d0,a0

		move.w	(a0)+,d0
		move.w	d0,songlen
		move.l	a0,songtable
		add.w	d0,d0
		add.w	d0,a0

		move.l	patttable(PC),a1
		move.w	d2,d0
		subq.w	#1,d0
.l0:		move.l	a0,pt_address(a1)
		move.w	(a1),d3		;pt_size
		mulu	#nt_sizeof*4,d3
		add.w	d3,a0
		addq.w	#pt_sizeof,a1
		dbra	d0,.l0

		move.l	instable(PC),a1
		move.w	d1,d0
		subq.w	#1,d0
.l1:		move.l	a0,it_address(a1)
		move.l	it_size(a1),d2
		add.l	d2,a0
		add.w	#it_sizeof,a1
		dbra	d0,.l1

		move.l	songtable(PC),pp_songptr
		move.w	songlen(PC),pp_songcnt
		move.l	pp_songptr(PC),a0
		move.w	(a0),d0
		mulu	#pt_sizeof,d0
		add.l	patttable(PC),d0
		move.l	d0,a0
		move.l	a0,pp_pattentry
		move.b	pt_size+1(a0),pp_notecnt
		move.l	pt_address(a0),pp_address
		move.b	#6,pp_wait
		move.b	#1,pp_waitcnt
		clr.w	pp_nullwave

		move.w	#$000F,shadow_dmacon

		lea	pp_variables(PC),a0
		lea	ch1s(pc),a1
		moveq	#1,d1
		move.w	#$80,d2
		moveq	#4-1,d0
.l2:		;move.w	#0,8(a1)
		move.w	d2,(a0)		;pv_waveoffset
		move.w	d1,pv_dmacon(a0)
		move.l	a1,pv_custbase(a0)
		move.l	#pp_periods,pv_peraddress(a0)
		move.w	#1019,pv_pers(a0)
		clr.w	pv_pers+2(a0)
		clr.w	pv_pers+4(a0)
		clr.l	pv_por(a0)
		clr.w	pv_porlevel(a0)
		clr.l	pv_vib(a0)
		clr.l	pv_vol(a0)
		move.w	#$40,pv_vollevel(a0)
		clr.l	pv_phase(a0)
		clr.w	pv_vibcnt(a0)
		clr.b	pv_flags(a0)
		add.w	#pv_sizeof,a0
		add.w	#sam_vcsize,a1
		add.w	d1,d1
		add.w	#$40,d2
		dbra	d0,.l2

		;bset	#1,$BFE001
		movem.l (sp)+,d0-d7/a0-a6
		rts

	*** Play routine ***

pp_play:	lea	ch1s(PC),a6
		subq.b	#1,pp_waitcnt
		bne.s	.l0
		bsr	pp_nwnt
		move.b	pp_wait(PC),pp_waitcnt

.l0:		lea	pp_variables(PC),a1
		bsr.s	pp_uvs
		lea	pp_variables+pv_sizeof(PC),a1
		bsr.s	pp_uvs
		lea	pp_variables+2*pv_sizeof(PC),a1
		bsr.s	pp_uvs
		lea	pp_variables+3*pv_sizeof(PC),a1

pp_uvs:		move.l	pv_custbase(a1),a0

.l0:		move.w	pv_pers(a1),d0
		bne.s	.l1
		bsr	pp_rot
		bra.s	.l0
.l1:		add.w	pv_por(a1),d0
		tst.w	pv_por(a1)
		beq.s	.l1c
		bpl.s	.l1a
		cmp.w	pv_porlevel(a1),d0
		bge.s	.l1c
		bra.s	.l1b
.l1a:		cmp.w	pv_porlevel(a1),d0
		ble.s	.l1c
.l1b:		move.w	pv_porlevel(a1),d0

.l1c:		add.w	pv_vib(a1),d0
		cmp.w	#135,d0
		bge.s	.l1d
		move.w	#135,d0
		bra.s	.l1e
.l1d:		cmp.w	#1019,d0
		ble.s	.l1e
		move.w	#1019,d0
.l1e:		move.w	d0,sam_period(a0)
		bsr	pp_rot

		move.w	pv_deltapor(a1),d0
		add.w	d0,pv_por(a1)
		cmp.w	#-1019,pv_por(a1)
		bge.s	.l3
		move.w	#-1019,pv_por(a1)
		bra.s	.l5
.l3:		cmp.w	#1019,pv_por(a1)
		ble.s	.l5
		move.w	#1019,pv_por(a1)

.l5:		tst.b	pv_vibcnt(a1)
		beq.s	.l7
		move.w	pv_deltavib(a1),d0
		add.w	d0,pv_vib(a1)
		subq.b	#1,pv_vibcnt(a1)
		bne.s	.l7
		neg.w	pv_deltavib(a1)
		move.b	pv_vibmax(a1),pv_vibcnt(a1)

.l7:		move.w	pv_dmacon(a1),d0
		move.w	pv_vol(a1),sam_vol(a0)
		move.w	pv_deltavol(a1),d0
		add.w	d0,pv_vol(a1)
		tst.w	pv_vol(a1)
		bpl.s	.l8
		clr.w	pv_vol(a1)
		bra.s	.la
.l8:		cmp.w	#$40,pv_vol(a1)
		ble.s	.la
		move.w	#$40,pv_vol(a1)

.la:		btst	#1,pv_flags(a1)
		beq.s	.l10
		tst.w	pv_deltaphase(a1)
		beq.s	.l10
		bpl.s	.sk
		clr.w	pv_deltaphase(a1)
.sk:		move.l	pv_insaddress(a1),a0
		move.w	(a1),d0		;pv_waveoffset
		neg.w	d0
		lea	(a0,d0.w),a2
		move.l	a2,a3
		move.w	pv_phase(a1),d0
		lsr.w	#2,d0
		add.w	d0,a3

		moveq	#$40-1,d0
.lb:		move.b	(a2)+,d1
		ext.w	d1
		move.b	(a3)+,d2
		ext.w	d2
		add.w	d1,d2
		asr.w	#1,d2
		move.b	d2,(a0)+
		dbra	d0,.lb

		move.w	pv_deltaphase(a1),d0
		add.w	d0,pv_phase(a1)
		cmp.w	#$100,pv_phase(a1)
		blt.s	.l10
		sub.w	#$100,pv_phase(a1)

.l10:		rts

pp_rot:		move.w	pv_pers(a1),d0
		move.w	pv_pers+2(a1),pv_pers(a1)
		move.w	pv_pers+4(a1),pv_pers+2(a1)
		move.w	d0,pv_pers+4(a1)
		rts

pp_nwnt:		move.l	pp_address(PC),a0
		add.l	#4*nt_sizeof,pp_address
		subq.b	#1,pp_notecnt
		bne.s	.l5

.l0:		addq.l	#2,pp_songptr
		subq.w	#1,pp_songcnt
		bne.s	.l1
		move.l	songtable(PC),pp_songptr
		move.w	songlen(PC),pp_songcnt
.l1:		move.l	pp_songptr(PC),a1
		move.w	(a1),d0
		mulu	#pt_sizeof,d0
		add.l	patttable(PC),d0
		move.l	d0,a1
		move.b	pt_size+1(a1),pp_notecnt
		move.l	pt_address(a1),pp_address

.l5:		clr.w	pp_tmpdmacon
		lea	pp_variables(PC),a1
		bsr	pp_nnt
		addq.w	#nt_sizeof,a0
		lea	pp_variables+pv_sizeof(PC),a1
		bsr	pp_nnt
		addq.w	#nt_sizeof,a0
		lea	pp_variables+2*pv_sizeof(PC),a1
		bsr	pp_nnt
		addq.w	#nt_sizeof,a0
		lea	pp_variables+3*pv_sizeof(PC),a1
		bsr	pp_nnt

		move.w	pp_tmpdmacon(PC),d0
		move_dmacon d0


		lea	pp_variables(PC),a1
		bsr	pp_scr
		lea	pp_variables+pv_sizeof(PC),a1
		bsr	pp_scr
		lea	pp_variables+2*pv_sizeof(PC),a1
		bsr	pp_scr
		lea	pp_variables+3*pv_sizeof(PC),a1
		bsr	pp_scr

		bset	#7,pp_tmpdmacon
		move.w	pp_tmpdmacon(PC),d0
		move_dmacon d0


		movem.l d0/a0-a1,-(sp)
		lea pp_variables(pc),a0
		lea ch1s(pc),a1
		rept 4
		move.l	pv_insaddress(a0),sam_lpstart(a1)
		moveq #0,d0
		move.w	pv_inslen(a0),d0
		add.l d0,d0
		move.w d0,sam_lplength(a1)
		add.l d0,sam_lpstart(a1)
		lea pv_sizeof(a0),a0 
		lea sam_vcsize(a1),a1
		endr

		movem.l (sp)+,d0/a0-a1

		rts

pp_scr:		move.w	pp_tmpdmacon(PC),d0
		and.w	pv_dmacon(a1),d0
		beq.s	.l5

		move.l d0,-(sp)
		move.l	pv_custbase(a1),a0
		move.l	pv_insaddress(a1),sam_start(a0)
		moveq #0,d0
		move.w	pv_inslen(a1),d0
		add.l d0,d0
		move.w d0,sam_length(a0)
		add.l d0,sam_start(a0)
		move.l (sp)+,d0

		move.w	pv_pers(a1),sam_period(a0)
		btst	#0,pv_flags(a1)
		bne.s	.l5
		move.l	#pp_nullwave,pv_insaddress(a1)
		move.w	#1,pv_inslen(a1)

.l5:		rts

pp_nnt:		move.b	(a0),d1		;nt_period
		beq	.l5

		and.l	#$000000FF,d1
		add.w	d1,d1
		add.l	#pp_periods-2,d1
		move.l	d1,a2

		btst	#6,nt_speed(a0)
		beq.s	.l2
		move.w	(a2),pv_porlevel(a1)
		bra.s	.l5

.l2:		move.w	pv_dmacon(a1),d0
		or.w	d0,pp_tmpdmacon

		move.l	a2,pv_peraddress(a1)
		move.w	(a2),pv_pers(a1)
		move.w	(a2),pv_pers+2(a1)
		move.w	(a2),pv_pers+4(a1)

		clr.w	pv_por(a1)

		move.b	nt_instr(a0),d0
		ext.w	d0
		mulu	#it_sizeof,d0
		add.l	instable(PC),d0
		move.l	d0,a2
		tst.l	it_address(a2)
		bne.s	.l1
		move.l	#pp_nullwave,pv_insaddress(a1)
		move.w	#1,pv_inslen(a1)
		clr.b	pv_flags(a1)
		bra.s	.l5

.l1:		move.l	it_address(a2),a3
		btst	#1,it_flags(a2)
		bne.s	.l0a
		move.l	it_size(a2),d0
		lsr.l	#1,d0
		move.w	d0,pv_inslen(a1)
		bra.s	.l0
.l0a:		move.w	(a1),d0		;pv_waveoffset
		add.w	d0,a3
		move.w	#$20,pv_inslen(a1)
.l0:		move.l	a3,pv_insaddress(a1)
		move.b	it_flags(a2),pv_flags(a1)
		move.w	pv_vollevel(a1),pv_vol(a1)

.l5:		move.b	nt_speed(a0),d0
		and.b	#$0F,d0
		beq.s	.l6
		move.b	d0,pp_wait

.l6:		move.l	pv_peraddress(a1),a2
		move.b	nt_arpeggio(a0),d0
		beq.s	.l9
		cmp.b	#$FF,d0
		bne.s	.l7
		move.w	(a2),pv_pers(a1)
		move.w	(a2),pv_pers+2(a1)
		move.w	(a2),pv_pers+4(a1)
		bra.s	.l9

.l7:		and.b	#$0F,d0
		add.b	d0,d0
		ext.w	d0
		move.w	(a2,d0.w),pv_pers+4(a1)
		move.b	nt_arpeggio(a0),d0
		lsr.b	#4,d0
		add.b	d0,d0
		ext.w	d0
		move.w	(a2,d0.w),pv_pers+2(a1)
		move.w	(a2),pv_pers(a1)

.l9:		move.b	nt_vibrato(a0),d0
		beq.s	.ld
		cmp.b	#$FF,d0
		bne.s	.la
		clr.l	pv_vib(a1)
		clr.b	pv_vibcnt(a1)
		bra.s	.ld
.la:		clr.w	pv_vib(a1)
		and.b	#$0F,d0
		ext.w	d0
		move.w	d0,pv_deltavib(a1)
		move.b	nt_vibrato(a0),d0
		lsr.b	#4,d0
		move.b	d0,pv_vibmax(a1)
		lsr.b	#1,d0
		move.b	d0,pv_vibcnt(a1)

.ld:		move.b	nt_phase(a0),d0
		beq.s	.l10
		cmp.b	#$FF,d0
		bne.s	.le
		clr.w	pv_phase(a1)
		move.w	#$FFFF,pv_deltaphase(a1)
		bra.s	.l10
.le:		and.b	#$0F,d0
		ext.w	d0
		move.w	d0,pv_deltaphase(a1)
		clr.w	pv_phase(a1)

.l10:		move.b	nt_volume(a0),d0
		bne.s	.l10a
		btst	#7,nt_speed(a0)
		beq.s	.l16
		bra.s	.l11a
.l10a:		cmp.b	#$FF,d0
		bne.s	.l11
		clr.w	pv_deltavol(a1)
		bra.s	.l16
.l11:		btst	#7,nt_speed(a0)
		beq.s	.l12
.l11a:		move.b	d0,pv_vol+1(a1)
		move.b	d0,pv_vollevel+1(a1)
		clr.w	pv_deltavol(a1)
		bra.s	.l16
.l12:		bclr	#7,d0
		beq.s	.l13
		neg.b	d0
.l13:		ext.w	d0
		move.w	d0,pv_deltavol(a1)

.l16:		move.b	nt_porta(a0),d0
		beq.s	.l1a
		cmp.b	#$FF,d0
		bne.s	.l17
		clr.l	pv_por(a1)
		bra.s	.l1a
.l17:		clr.w	pv_por(a1)
		btst	#6,nt_speed(a0)
		beq.s	.l17a
		move.w	pv_porlevel(a1),d1
		cmp.w	pv_pers(a1),d1
		bgt.s	.l17c
		neg.b	d0
		bra.s	.l17c

.l17a:		bclr	#7,d0
		bne.s	.l18
		neg.b	d0
		move.w	#135,pv_porlevel(a1)
		bra.s	.l17c

.l18:		move.w	#1019,pv_porlevel(a1)
.l17c:		ext.w	d0
.l18a:		move.w	d0,pv_deltapor(a1)

.l1a:		rts

	*** Data section ***

pp_periods:	DC.W	1019,962,908,857,809,763,720,680,642,606,572,540
		DC.W	509,481,454,428,404,381,360,340,321,303,286,270
		DC.W	254,240,227,214,202,190,180,170,160,151,143,135
		DC.W	135,135,135,135,135,135,135,135,135
		DC.W	135,135,135,135,135,135

songlen:	DS.W	1
songtable:	DS.L	1
instable:	DS.L	1
patttable:	DS.L	1

pp_wait:	DS.B	1
pp_waitcnt:	DS.B	1
pp_notecnt:	DS.B	1
pp_address:	DS.L	1
pp_songptr:	DS.L	1
pp_songcnt:	DS.W	1
pp_pattentry:	DS.L	1
pp_tmpdmacon:	DS.W	1
pp_variables:	DS.B	4*48

pp_nullwave:	DS.W	1
	even
mt_data:	incbin d:\trackers.s\jamcrack.mod\mentalre.mod
