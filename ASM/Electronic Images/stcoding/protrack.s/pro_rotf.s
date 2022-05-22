;-----------------------------------------------------------------------;
;									;
;	              ProTracker Replay Rotfile				;
;	                 (ST/STE/TT driver)				;
;									;
; 	   Programmed By Martin Griffiths August 18th 1991		;
;									;
;  12.5khz Baserate Player with Ste DMA sound if available, it works!!	;
;-----------------------------------------------------------------------;
; This is THE Version use to USE! 
; - Handles 64k and uses STE dma stereo sound if available.
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

.out		MOVEQ #0,D0			; tell driver to 
		MOVEQ #3,D1			; fade down music
		BSR rotfile+8

		LEA rotfile(PC),A0 
	        ADD.L 16(A0),A0			; addr of fade variable
.wait     	BTST #0,(A0)			; has it faded down?
	        BNE.S .wait			; wait till it has!

		BSR rotfile+12			; stop those timer ints!

		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W		; and vbl..
		BSR flush
		MOVE.L #$00000666,$FFFF8240.W
		MOVE.L #$06660666,$FFFF8244.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

old_stuff	DS.L 2

; The vbl - calls sequencer and vbl filler

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVE.W #$700,$FFFF8240.W
		BSR rotfile+4			; call sequencer
		MOVE.W #$777,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE

;
; The Rotfile
;

		OPT P+		; must be position independent

rotfile		BRA.W Init_PAL_or_NTSC
		BRA.W Vbl_play
		BRA.W Init_ST
		BRA.W stop_ints
		DC.L vol_bitflag-rotfile

		DC.B "ST/STE/TT Pro-Tracker v1.1b Driver "
		DC.B "By Martin Griffiths(aka Griff of Inner Circle),"
		EVEN

speed		EQU 49    		; timer d (12.5KHZ)

freq_tab	DS.L 1			
		INCBIN d:\protrack.s\PLAYER.DAT\FREQ25.BIN	; frequency table

sndbuff1	ds.w $400		; buffer for voices 1+2
endbuff1	dc.w -1
sndbuff2	ds.w $400		; buffer for voices 3+4
endbuff2	dc.w -1
stebuff		ds.w $400		; ste buffer
endstebuff

; Vars...

vol_bitflag	DC.W 0
global_vol	DC.W 0
fadeOUTflag	DC.B 0
fadeOUTcurr	DC.B 0			; fade vars
fadeOUTspeed	DC.B 0
fadeINflag	DC.B 0
fadeINcurr	DC.B 0
fadeINspeed	DC.B 0
		DS.L 4			; (in case!!)
nulsamp		DS.L 4			; nul sample
buff_ptr 	DC.L 0			; last pos within ring buffer
music_on	DC.B 0			; music on flag
ste_flag	DC.B 0			; STE flag!
fillx1		DC.W 0			; circular buffer
fillx2		DC.W 0			; amounts(main and wrap amounts)
voltab_ptr	DC.L 0			; ptr to volume table
initialval	DC.L 0
basespeed	DC.W 0

; Paula emulation storage structure.

		RSRESET

sam_start	RS.L 1			; sample start
sam_length	RS.W 1			; sample length
sam_period	RS.W 1			; sample period(freq)
sam_vol		RS.W 1			; sample volume
sam_lpstart	RS.L 1			; sample loop start
sam_lplength	RS.W 1	 		; sample loop length
sam_frac	RS.W 1			; sample fraction(freq part)
sam_vcsize	RS.B 1			; structure size.

ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize		; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize

; Select PAL/NTSC

Init_PAL_or_NTSC
		LEA basespeed(PC),A0
;		BTST.B #1,$FFFF820A.W
;		BEQ.S .sel_NTSC
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

; Vbl player - This is THE  'Paula' Emulator.

Vbl_play:	MOVE.B music_on(PC),D0		; music on?
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
		MOVE.B ste_flag(PC),D0
		BEQ.S .STread
.STEread	BSR Set_DMA
		LEA $FFFF8909.W,A0
		MOVEP.L (A0),D0
		LSR.L #8,D0
		ADD.L #sndbuff1-stebuff,D0
		BRA.S .CONTread

.STread		MOVE.L USP,A0			; ST pos in buffer
		MOVE.L A0,D0			
.CONTread	LEA buff_ptr(PC),A1
		MOVE.L (A1),A4
		LEA endbuff1(PC),A0
		CMP.L A0,d0
		BNE.S .norm
		LEA sndbuff1(PC),A0
		MOVE.L A0,d0			; wooky case(at end of buf)
.norm		MOVE.L D0,(A1)
		SUB.L A4,D0
		BEQ skipit
		BHI.S .higher
		ADDI.W #$800,D0			; abs
.higher		LSR.W #1,D0
		LEA endbuff1(PC),A0
		MOVE.L A0,D1
		SUB.L A4,D1
		LSR.W #1,D1
		LEA fillx1(PC),A0
		CLR.W (A0)			; assume no buf overlap
		CMP.W D1,D0			; check for overlap
		BCS.S .higher1
		MOVE.W D1,(A0)			; ok so there was overlap!!
.higher1	SUB.W (A0),D0			; subtract any overlap
		MOVE.W D0,2(A0)			; A4 -> to place to fill

.voices_1_2	LEA freq_tab(PC),A3		; int.w/frac.w freq tab
		LEA sndbuff1(PC),A5
		LEA buffbase(PC),A6
		MOVE.L A5,(A6)
		LEA.L ch1s(PC),A5
		MOVEQ #0,D2
		BSR makevoice			; move voice 1
		LEA.L ch2s(PC),A5
		MOVEQ #-1,D2
		BSR makevoice			; add voice 2
.voices_3_4	LEA $802(A4),A4
		LEA sndbuff2(PC),A5
		LEA buffbase(PC),A6
		MOVE.L A5,(A6)		
		LEA.L ch3s(PC),A5	
		MOVEQ #0,D2
		BSR makevoice			; move voice 3	
		LEA.L ch4s(PC),A5	
		MOVEQ #-1,D2
		BSR makevoice			; add voice 4					; add voice 4

		MOVE.B ste_flag(PC),D0
		BEQ mt_music

.STEmake	LEA ste_tab(PC),A2
		LEA -$802(A4),A3
		LEA stebuff-sndbuff2(A4),A5
		MOVE.W fillx1(PC),D0
		BSR.S makeste			; 
		MOVE.W fillx2(PC),D0
		MOVE.W fillx1(PC),D2
		BEQ.S .nores
		LEA sndbuff1(PC),A3
		LEA sndbuff2(PC),A4
		LEA stebuff(PC),A5
.nores		BSR.S makeste
		BRA mt_music
skipit		RTS

makeste		MOVE.W D0,-(SP)
		LSR #3,D0
		SUBQ #1,D0
		BMI.S .missbig
.lp		REPT 8
		MOVE.W (A3)+,D3
		MOVE.W (A4)+,D4
		MOVE.B (A2,D3),(A5)+
		MOVE.B (A2,D4),(A5)+
		ENDR
		DBF D0,.lp
.missbig	MOVE.W (SP)+,D0
		AND #7,D0
		SUBQ #1,D0
		BMI.S .nonetodo
.lp2		MOVE.W (A3)+,D3
		MOVE.W (A4)+,D4
		MOVE.B (A2,D3),(A5)+
		MOVE.B (A2,D4),(A5)+
		DBF D0,.lp2
.nonetodo	RTS

ste_tab		dcb.b 128,$80
i		set -128
		rept 256
		dc.b i
i		set i+1
		endr
		dcb.b 128,$7f

; Routine to add/move one voice to buffer. The real Paula emulation part!!

makevoice	PEA (A4)			; save buff pos
		LEA addflag(PC),A6
		MOVE.W D2,(A6)
		MOVE.L sam_start(A5),A2		; current sample end address
		MOVEM.W sam_period(A5),D1/D2	; period/volume
		CMP.W #$40,D2
		BLE.S .ok
		MOVEQ #$40,D2
.ok		MULS global_vol(PC),D2
		LSR #6,D2			; /64
		ADD.W D1,D1
		ADD.W D1,D1			; *4 for lookup
		MOVEM.W 0(A3,D1),D1/D4		; get int.w/frac.w
		MOVE.L voltab_ptr(PC),A6	; base of volume table
		LSL.W #8,D2
		ADD.W D2,A6			; ptr to volume table
		MOVEQ #0,d5
		MOVE.W sam_length(A5),d5	; sample length
		LEA nulsamp+2(PC),A0
		CMP.L A0,A2
		BNE.S .vcon
		MOVEQ.L	#0,D4			; channel is off.
		MOVEQ.L	#0,D1			; clear all if off.
		MOVE.L voltab_ptr(PC),A6	; zero vol(safety!!)
.vcon		NEG.L d5
		MOVE.L A6,D6			; vol ptr
		MOVE.L sam_lpstart(a5),A0	; loop addr
		MOVEQ #0,D7
		MOVE.W sam_lplength(a5),D7	; loop length
		NEG.L D7
		LEA loopfreq(PC),A6
		MOVEM.W D1/D4,(A6)
		CMP.L #-2,D7
		BNE.S .isloop
		CLR.L (A6)			; no loop-no frequency
		LEA nulsamp+2(PC),A0	 	; no loop-point to nul
.isloop		MOVE.W sam_frac(A5),D3		; fraction part
		MOVE.W fillx1(PC),D0
		BSR.S moveaddvoice		; 
		MOVE.W fillx2(PC),D0
		MOVE.W fillx1(PC),D2
		BEQ.S nores
		MOVE.L buffbase(PC),A4		; buffer base
nores		BSR.S moveaddvoice
		NEG.L d5			; +ve offset(as original!)
		MOVE.L A2,sam_start(A5)		; store voice address
		MOVE.W d5,sam_length(A5)	; store offset for next time
		MOVE.W D3,sam_frac(A5)		; clear fraction part
		MOVE.L (SP)+,A4
		RTS

buffbase	DS.L 1
addflag		DS.W 1
loopfreq	DS.W 2

lpvoice		MACRO
		MOVE.L A0,A2 
		ADD.W D7,D5			; fetch loop constants
		MOVEM.W loopfreq(PC),D1/D4	; (channel independent)
 		BRA.S \1
		ENDM

lpvoiceL	MACRO
		MOVE.L A0,A2 
		ADD.W D7,D5			; fetch loop constants
		MOVEM.W loopfreq(PC),D1/D4	; (channel independent)
		MOVE #0,CCR	
 		BRA \1
		ENDM

; MOVE/ADD a voice to the buffer with frequency shifting.
; D0 = no. of sample bytes to do.

moveaddvoice 	MOVE.W addflag(PC),D2
		BNE addit

; MOVE D0 sample bytes to buffer

moveit		MOVEQ #0,D2			
		MOVE.W D0,-(SP)			; lets go!!
		LSR #2,D0			; /4 for speed
		SUBQ #1,D0			; -1 (dbf)
		BMI.S .donemain			; none to do?
.makelp		MOVE.B (A2,d5.L),D6		; fetch sample byte
		MOVE.L D6,A6
		MOVE.B (A6),D2			; lookup in vol tab
		MOVE.W D2,(A4)+			; add/move to buffer(self modified)
		ADD.W D4,D3			; add frac part
		ADDX.W D1,d5			; add ints.(carried thru)
		BCS.S .lpvoice1			; voice looped?
.CONT1		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
		MOVE.W D2,(A4)+
		ADD.W D4,D3			; 
		ADDX.W D1,d5
		BCS.S .lpvoice2
.CONT2		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
		MOVE.W D2,(A4)+
		ADD.W D4,D3			;
		ADDX.W D1,d5
		BCS.S .lpvoice3
.CONT3		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
		MOVE.W D2,(A4)+			;
		ADD.W D4,D3
		ADDX.W D1,d5
.CONT4		DBCS D0,.makelp
		BCS.S .lpvoice4
.donemain	MOVE.W (SP)+,D0
		AND #3,D0			; remaining bytes.
		SUBQ #1,D0
		BMI.S .yeah
.niblp		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
		MOVE.W D2,(A4)+
		ADD.W D4,D3
		ADDX.W D1,d5
.CONT5		DBCS D0,.niblp
		BCS.S .lpvoicelast
.yeah		RTS

.lpvoice1:	lpvoice .CONT1			;
.lpvoice2:	lpvoice .CONT2			; loop routs
.lpvoice3:	lpvoice .CONT3			; (since code is repeated)
.lpvoice4:	lpvoiceL .CONT4			;
.lpvoicelast:	lpvoiceL .CONT5			;
	
; ADD D0 sample bytes to buffer

addit		MOVEQ #0,D2			
		MOVE.W D0,-(SP)			; lets go!!
		LSR #2,D0			; /4 for speed
		SUBQ #1,D0			; -1 (dbf)
		BMI.S .donemain			; none to do?
.makelp		MOVE.B (A2,d5.L),D6		; fetch sample byte
		MOVE.L D6,A6
		MOVE.B (A6),D2			; lookup in vol tab
		ADD.W D2,(A4)+			; add/move to buffer(self modified)
		ADD.W D4,D3			; add frac part
		ADDX.W D1,d5			; add ints.(carried thru)
		BCS.S .lpvoice1			; voice looped?
.CONT1		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
		ADD.W D2,(A4)+
		ADD.W D4,D3			; 
		ADDX.W D1,d5
		BCS.S .lpvoice2
.CONT2		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
		ADD.W D2,(A4)+
		ADD.W D4,D3			;
		ADDX.W D1,d5
		BCS.S .lpvoice3
.CONT3		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
		ADD.W D2,(A4)+			;
		ADD.W D4,D3
		ADDX.W D1,d5
.CONT4		DBCS D0,.makelp
		BCS.S .lpvoice4
.donemain	MOVE.W (SP)+,D0
		AND #3,D0			; remaining bytes.
		SUBQ #1,D0
		BMI.S .yeah
.niblp		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
		ADD.W D2,(A4)+
		ADD.W D4,D3
		ADDX.W D1,d5
.CONT5		DBCS D0,.niblp
		BCS.S .lpvoicelast
.yeah		RTS

.lpvoice1:	lpvoice .CONT1			;
.lpvoice2:	lpvoice .CONT2			; loop routs
.lpvoice3:	lpvoice .CONT3			; (since code is repeated)
.lpvoice4:	lpvoiceL .CONT4			;
.lpvoicelast:	lpvoiceL .CONT5			;

; YM 2149 interrupt - fucking bastard shite ST chip(designer cunts)

player		MOVE.L D0,-(SP)
		PEA (A0)
		MOVE.L USP,A0
		MOVE.W (A0)+,D0
		BMI.S .reset
.cont		ADD.W $800(A0),D0
		MOVE.L A0,USP
		LSL #3,D0
		LEA $FFFF8800.W,A0
		MOVE.L sndtab+4(PC,D0),(A0)
		MOVE.L sndtab(PC,D0),D0
		MOVEP.L D0,(A0)	
		MOVE.L (SP)+,A0
		MOVE.L (SP)+,D0
		RTE
.reset		LEA sndbuff1(PC),A0
		MOVE.W (A0)+,D0
		BRA.S .cont
sndtab		INCBIN d:\protrack.s\PLAYER.DAT\QUARFAST.TAB	

; ST specific initialise - sets up shadow amiga registers etc

STspecific:	BSR Ste_Test
		;lea ste_flag(PC),A0
		;clr.b (A0)
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
		MOVE.W	D0,sam_frac(A0)	    ; clear fraction part
		RTS

; Save mfp vects that are used and install our interrupts.

start_ints	MOVE SR,-(SP)
		MOVE #$2700,SR
		LEA sndbuff1(PC),A1
		LEA buff_ptr(PC),A0
		MOVE.L A1,(A0)
		LEA ste_flag(PC),A0
		TST.B (A0)
		BEQ.S Setup_YM2149
.Ste_Setup	LEA.L setsam_dat(PC),A6
		MOVE.W #$7ff,$ffff8924
		MOVEQ #3,D6
.mwwritx	CMP.W #$7ff,$ffff8924
		BNE.S .mwwritx			; setup the PCM chip
		MOVE.W (A6)+,$ffff8922
		DBF D6,.mwwritx
		CLR.B $FFFF8901.W
		BSR Set_DMA
		MOVE.B #%00000010,$FFFF8921.W 	; 12.5khz
		MOVE.B #3,$FFFF8901.W	  	; start STE dma.
.exitste	MOVE.W (SP)+,SR
		RTS

Set_DMA		LEA temp(PC),A6			
		LEA stebuff(PC),A0		
		MOVE.L A0,(A6)			
		MOVE.B 1(A6),$ffff8903.W
		MOVE.B 2(A6),$ffff8905.W	; set start of buffer
		MOVE.B 3(A6),$ffff8907.W
		LEA endstebuff(PC),A0
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
		LEA sndbuff1(PC),A1
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
		MOVEQ #-2,D1
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

Init_Voltab	LEA vols+256(PC),A0
		MOVE.L A0,D0
		CLR.B D0
		LEA voltab_ptr(PC),A1
		TST.L (A1)
		BNE.S .alreadyinited
		MOVE.L D0,(A1)
		MOVE.L D0,A1
		MOVE.W #(16640/32)-1,D0
.lp		REPT 8
		MOVE.L (A0)+,(A1)+
		ENDR
		DBF D0,.lp
.alreadyinited	RTS

Init_Buffer	LEA sndbuff1(PC),A0
		LEA sndbuff2(PC),A1
		MOVEQ.L #0,D0
		MOVEQ #($800/16)-1,D7
.lp		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A1)+
		MOVE.L D0,(A1)+
		MOVE.L D0,(A1)+
		MOVE.L D0,(A1)+
		DBF D7,.lp
		RTS

vols		DS.L 64
		INCBIN d:\protrack.s\PLAYER.DAT\PT_VOLTA.DAT

;********************************************
;* ----- Protracker V1.1A Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1990  *
;* Bekkeliveien 10, N-2010 STRØMMEN, Norway *
;********************************************

; Structure for each voice.

n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; low B of n_cmd
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

; Pro-Tracker main Variables.

		rsreset
mt_SongDataPtr	rs.l 1
mt_speed	rs.b 1
mt_counter	rs.b 1
mt_SongPos	rs.b 1
mt_PBreakPos	rs.b 1
mt_PosJumpFlag	rs.b 1
mt_PBreakFlag	rs.b 1
mt_LowMask	rs.b 1
mt_PattDelTime	rs.b 1
mt_PattDelTime2	rs.b 1
		rs.b 1
mt_PattPos	rs.w 1
mt_vars_size	rs.b 1

; Initialise module

mt_init	LEA mt_data(PC),A0
	LEA mt_vars(PC),A6
	MOVE.L	A0,mt_SongDataPtr(A6)
	LEA	mt_mulu(PC),A1
	MOVE.L	A0,D0
	ADD.L	#12,D0
	MOVEQ	#$1F,D1
	MOVEQ	#$1E,D3
mt_lop4	MOVE.L	D0,(A1)+
	ADD.L	D3,D0
	DBRA	D1,mt_lop4
	LEA	$3B8(A0),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
mt_lop2 MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BLE.S	mt_lop
	MOVE.L	D1,D2
mt_lop	DBRA	D0,mt_lop2
	ADDQ.W	#1,d2
	ASL.L	#8,D2
	ASL.L	#2,D2
	LEA	4(A1,D2.L),A2
	LEA	mt_SampleStarts(PC),A1
	ADD.W	#$2A,A0
	MOVEQ	#$1E,D0
mt_lop3 CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.B	D1,2(A0)
	MOVE.W	(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	D3,A0
	DBRA	D0,mt_lop3
	MOVE.B	basespeed(PC),mt_speed(A6)
	MOVEQ	#0,D0
	MOVE.B	D0,mt_SongPos(A6)
	MOVE.B	D0,mt_counter(A6)
	MOVE.W	D0,mt_PattPos(A6)
	RTS

; Vbl Sequencer

mt_music
	LEA mt_vars(PC),A1
	ADDQ.B	#1,mt_counter(A1)
	MOVE.B	mt_counter(A1),D0
	CMP.B	mt_speed(A1),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter(A1)
	TST.B	mt_PattDelTime2(A1)
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	ch1s(pc),A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch2s(pc),A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch3s(pc),A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch4s(pc),A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(A1),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(A1),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PattPos(A1),D1

	LEA	ch1s(pc),A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch2s(pc),A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch3s(pc),A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch4s(pc),A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	MOVE.W	n_period(A6),sam_period(A5)
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	mt_SampleStarts(PC,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ	mt_NoLoop
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
	MOVE.W	D0,sam_vol(A5)	; Set volume
	BRA	mt_SetRegs
mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)	; Set volume
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
	MOVEM.L	D1-D2/A2,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A2
	MOVEQ	#36,D2
mt_ftuloop
	CMP.W	(A2)+,D1
	DBHS	D2,mt_ftuloop
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	MOVE.W	-2(A2,D1.L),n_period(A6)
	MOVEM.L	(SP)+,D1-D2/A2

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 			; Notedelay
	BEQ	mt_CheckMoreEfx

	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),sam_start(A5)	; Set start
	MOVEQ.l	 #0,D0
	MOVE.W	n_length(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,sam_start(A5)		; point to end of sample
	MOVE.W	D0,sam_length(A5)		; Set length
	MOVE.W	n_period(A6),sam_period(A5)	; Set period
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.L	D0,-(SP)
	MOVEQ.L	#0,D0
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	MOVE.L	n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,sam_lpstart(A5)
	MOVE.W	D0,sam_lplength(A5)

	MOVEQ.L	#0,D0
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,sam_lplength(A5)

	MOVEQ.L	#0,D0
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,sam_lplength(A5)

	MOVEQ.L	#0,D0
	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,sam_lplength(A5)

	MOVE.L	(SP)+,D0

mt_dskip
	ADD.W	#16,mt_PattPos(A1)
	MOVE.B	mt_PattDelTime(A1),D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2(A1)
	CLR.B	mt_PattDelTime(A1)
mt_dskc	TST.B	mt_PattDelTime2(A1)
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2(A1)
	BEQ.S	mt_dska
	SUB.W	#16,mt_PattPos(A1)
mt_dska	TST.B	mt_PBreakFlag(A1)
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag(A1)
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(A1),D0
	CLR.B	mt_PBreakPos(A1)
	LSL.W	#4,D0
	MOVE.W	D0,mt_PattPos(A1)
mt_nnpysk
	CMP.W	#1024,mt_PattPos(A1)
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(A1),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PattPos(A1)
	CLR.B	mt_PBreakPos(A1)
	CLR.B	mt_PosJumpFlag(A1)
	ADDQ.B	#1,mt_SongPos(A1)
	AND.B	#$7F,mt_SongPos(A1)
	MOVE.B	mt_SongPos(A1),D1
	MOVE.L	mt_SongDataPtr(A1),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos(A1)
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag(A1)
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
SetBack	MOVE.W	n_period(A6),sam_period(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return2
	RTS

mt_PerNop
	MOVE.W	n_period(A6),sam_period(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(A1),D0
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
	MOVE.L D3,-(SP)
	MOVEQ	#36,D3
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0)+,D1
	BHS.S	.arp4
	DBF	D3,mt_arploop
	MOVE.L (SP)+,D3
	RTS
.arp4	MOVE.W	D2,sam_period(A5)
	MOVE.L (SP)+,D3
	RTS

mt_Arpeggio4
	MOVE.W	D2,sam_period(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter(A1)
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask(A1)
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(A1),D0
	MOVE.B	#$FF,mt_LowMask(A1)
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
	MOVE.W	D0,sam_period(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter(A1)
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask(A1)
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(A1),D0
	MOVE.B	#$FF,mt_LowMask(A1)
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
	MOVE.W	D0,sam_period(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
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
	ADD.L	D0,A0
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
	MOVE.W	D2,sam_period(A5) 		; Set period
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
	MOVE.W	D0,sam_vol(A5)
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
	MOVE.W	D0,sam_vol(A5)
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
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos(A1)
mt_pj2	CLR.B	mt_PBreakPos(A1)
	ST 	mt_PosJumpFlag(A1)
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,sam_vol(A5)
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
	MOVE.B	D0,mt_PBreakPos(A1)
	ST	mt_PosJumpFlag(A1)
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ	mt_Return2
	CLR.B	mt_counter(A1)
	MOVE.B	D0,mt_speed(A1)
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
	RTS	

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
	TST.B	mt_counter(A1)
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return2
mt_jmploop	
	MOVE.B	n_pattpos(A6),mt_PBreakPos(A1)
	ST	mt_PBreakFlag(A1)
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PattPos(A1),D0
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
	MOVE.B	mt_counter(A1),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(A1),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	MOVE.L D0,-(SP)
	MOVEQ #0,D0
	MOVE.L	n_start(A6),(A5)		; Set sampledata pointer
	MOVE.W	n_length(A6),D0
	ADD.L D0,D0
	ADD.L D0,(A5)
	MOVE.W D0,4(A5)				; Set length
	MOVEQ #0,D0
	MOVE.L	n_loopstart(A6),10(A5)		; loop sample ptr
	MOVE.L	n_replen(A6),D0
	ADD.L D0,D0
	ADD.L D0,10(A5)
	MOVE.W D0,14(A5)
	MOVE.L (SP)+,D0
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter(A1)
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter(a1)
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(A1),D0
	BNE	mt_Return2
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(A1),D0
	BNE	mt_Return2
	MOVE.W	(A6),D0
	BEQ	mt_Return2
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter(A1)
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2(A1)
	BNE	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime(A1)
	RTS

mt_FunkIt
	TST.B	mt_counter(A1)
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return2
mt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
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
	MOVEM.L	(SP)+,A0/D1
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

mt_vars		ds.b mt_vars_size
		even


mt_mulu		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
endrotfile
		SECTION DATA

mt_data		INCBIN e:\mods\axelf.MOD


