; ** Ett demo av Martin Kalms alias Jasper of Tranceaction/GRC 20/9 1991 **

letsgo		MOVE.L 4(SP),A5
		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4		; proggy size+basepage
		PEA (A4)
		PEA (A5)
		CLR -(SP)
		MOVE #$4A,-(SP)
		TRAP #1			; reserve some memory
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)	
		TRAP #1			; supervisor mode
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVE.L USP,A0
		MOVE.L A0,oldusp
		
		LEA my_stack,SP		; our own stack.
	
		move.w	#2,-(sp)			
		trap	#14
		addq.l	#2,sp
		move.l	d0,phys
		
		lea	pic+2,a0		
		lea	$ffff8240.w,a1	
		movem.l	(a0)+,d0-d7	
		movem.l	d0-d7,(a1)	
		
		lea 	pic+34,a0
		move.l	phys,a1		
		move.l	#7999,d0		
pic_loop1		move.l	(a0)+,(a1)+	
		dbra	d0,pic_loop1
		
		BSR Ste_Test
		BSR Init_Voltab		; initialise volume table.

		LEA mt_data,A0
		JSR mt_init		; initialise mod data.

		BSR init_ints		; and go!

.waitk		MOVE.B key(PC),D0
		CMP.B #$3B+$80,D0		; lower than F1?
		BLT.S .notfunk
		CMP.B #$41+$80,d0		; higher than f7?
		BGT.S .notfunk
		AND #$7F,D0
		SUB #$3B,D0		; normalise
		CMP.W Which_replay(PC),D0	
		BEQ.S .waitk		; same as already playing?
		BSR Select_PlayRout		; select new rout
		BRA.S .waitk
.notfunk		CMP.B #$39+$80,D0		; space exits.
		BNE.S .waitk

		BSR restore_ints		; restore gem..

exit	
		MOVE.L oldsp(PC),-(SP)
		MOVE #$20,-(SP)	
		TRAP #1			; user mode
		ADDQ.L #6,SP
		
		CLR.L -(SP)
		TRAP #1

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd		; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+	; Save mfp registers 
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA25.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $110.W,(A0)+		; save some vectors
		MOVE.L $118.W,(A0)+
		CLR.B $fffffa07.W
		MOVE.B #$50,$fffffa09.W
		CLR.B $fffffa13.W
		MOVE.B #$50,$fffffa15.W
		BCLR.B #3,$fffffa17.W	; software end of int.
		MOVE.B #0,$FFFFFA1D.W
		MOVE.B #37,$FFFFFA25.W
		MOVE.B #1,$FFFFFA1D.W
		LEA my_vbl(PC),A0
		MOVE.L A0,$70.W		; set our vbl
		LEA key_rout(PC),A0
		MOVE.L A0,$118.W		; and our keyrout.
		MOVE Which_replay(PC),D0
		BSR Select_PlayRout
		CLR key			
		LEA sndbuff1(PC),A1
		MOVE #$2300,SR
		MOVEQ #$11,D0		; resume sending
		BSR Writeikbd
		MOVEQ #$12,D0		; kill mouse
		BSR Writeikbd
		BSR flush
		RTS

; Restore mfp vectors and ints.

restore_ints	MOVE.L oldusp(PC),A0
		MOVE.L A0,USP
		MOVEQ #$13,D0		; pause keyboard
		BSR Writeikbd		; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$118.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		MOVEQ #$11,D0		; resume
		BSR Writeikbd		
		MOVEQ #$8,D0		; restore mouse.
		BSR Writeikbd
		BSR flush
		RTS

old_stuff:	DS.L 20
oldsp		DS.L 1
oldusp		DS.L 1

; Flush IKBD

flush		BTST.B #0,$FFFFFC00.W	; any waiting?
		BEQ.S .flok		; exit if none waiting.
		MOVE.B $FFFFFC02.W,D0	; get next in queue
		BRA.S flush		; and continue
.flok		RTS

; Write d0 to IKBD

Writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Writeikbd		; wait for ready
		MOVE.B D0,$FFFFFC02.W	; and send...
		RTS

; Keyboard handler interrupt routine...

key_rout	MOVE #$2500,SR			; ipl 5 for 'cleanness' 
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0		; int req?
		BEQ.S .end			
		BTST #0,D0			 
		BEQ.S .end
		MOVE.B $FFFFFC02.W,key	; store keypress
.end		MOVE (SP)+,D0
		RTE
key		DC.W 0

; The vbl - calls sequencer and vbl filler.

my_vbl		MOVEM.L D0-D6/A0/A2-A6,-(SP)
		BSR Vbl_play
		JSR mt_music	
		MOVEM.L (SP)+,D0-D6/A0/A2-A6
		RTE

; Vbl player - this is a kind of 'Paula' Emulator(!)

Vbl_play:	MOVEA.L	buff_ptr(PC),A4
		MOVE.L A1,D0		; current pos in buffer
		CMP.L #endbuff1,d0
		BNE.S .norm
		MOVE.L #sndbuff1,d0		; wooky case(at end of buf)
.norm		MOVE.L D0,buff_ptr
		SUB.L A4,D0
		BEQ skipit
		BHI.S higher
		ADDI.W #$800,D0		; abs
higher		LSR.W #1,D0
		MOVE.L #endbuff1,D1
		SUB.L A4,D1
		LSR.W #1,D1
		CLR.W fillx1		; assume no buf overlap
		CMP.W D1,D0			; check for overlap
		BCS.S higher1
		MOVE.W D1,fillx1		; ok so there was overlap!!
higher1		SUB.W fillx1(PC),D0		; subtract any overlap
		MOVE.W D0,fillx2		; and store main
; A4 points to place to fill
		LEA freqs(PC),A3		; int.w/frac.w freq tab

.voices_1_2	MOVE.L #sndbuff1,buffbase		
		LEA.L ch1s(PC),A5
		MOVE.W amove(pc),D0
		BSR add1			; move voice 1
		LEA.L ch2s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 2

		LEA $802(A4),A4
.voices_3_4	MOVE.L #sndbuff2,buffbase	
		LEA.L ch3s(PC),A5	
		MOVE.W amove(pc),D0
		BSR add1			; move voice 3	
		LEA.L ch4s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 4					; add voice 4
		RTS

; Routine to add/move one voice to buffer. The real Paula emulation part!!

add1		PEA (A4)			; save buff pos
		LEA moda(PC),A2
		MOVE.W D0,(A2)
		MOVE.W D0,modb-moda(A2)	; self modifying
		MOVE.W D0,modc-moda(A2)	; add/move code(see below)
		MOVE.W D0,modd-moda(A2)	
		MOVE.W D0,mode-moda(A2)	
		MOVE.L (A5),A2		; current sample end address
		MOVEM.W 6(A5),D1/D2		; period/volume
		ADD.W D1,D1
		ADD.W D1,D1		; *4 for lookup
		MOVEM.W 0(A3,D1),D1/D4	; get int.w/frac.w
		MOVE.L voltab_ptr(PC),A6	; base of volume table
		LSL.W #8,D2
		ADD.W D2,A6		; ptr to volume table
		MOVEQ #0,d5
		MOVE.W 4(A5),d5		; sample length
		CMP.L #nulsamp+2,A2
		BNE.S .vcon
		MOVEQ.L	#0,D4		; channel is off.
		MOVEQ.L	#0,D1		; clear all if off.
		MOVE.L voltab_ptr(PC),A6	; zero vol(safety!!)
		CLR.W 16(A5)		; clear frac part
.vcon		NEG.L d5
		MOVE.L A6,D6		; vol ptr
		MOVEQ.L	#0,D2		; clr top byte for sample
; Setup Loop stuff
		MOVE.L 10(a5),A0		; loop addr
		MOVEQ #0,D3
		MOVE.W 14(a5),D3		; loop length
		NEG.L D3
		MOVEM.W D1/D4,loopfreq
		CMP.L #-2,D3
		BNE.S isloop
noloop		MOVE.L D2,loopfreq		; no loop-no frequency
		LEA nulsamp+2(PC),A0	; no loop-point to nul
isloop		MOVE.L D3,looplength
		MOVE.W 16(A5),D3		; clear fraction part
		MOVE.W fillx1(PC),D0
		BSR.S addit		 
		MOVE.W fillx2(PC),D0
		TST.W fillx1
		BEQ.S nores
		MOVE.L buffbase(PC),A4	; buffer base
nores		BSR.S addit
		NEG.L d5			; +ve offset(as original!)
		MOVE.L A2,(A5)		; store voice address
		MOVE.W d5,4(A5)		; store offset for next time
		MOVE.W D3,16(A5)		; clear fraction part
skipit		MOVE.L (SP)+,A4
		RTS
	
; Add D0 sample bytes to buffer

addit		MOVE.W D0,donemain+2	; lets go!!
		LSR #2,D0			; /4 for speed
		SUBQ #1,D0		; -1 (dbf)
		BMI.S donemain		; none to do?
makelp		MOVE.B (A2,d5.L),D6		; fetch sample byte
		MOVE.L D6,A6
		MOVE.B (A6),D2		; lookup in vol tab
moda		ADD.W D2,(A4)+		; add/move to buffer(self modified)
		ADD.W D4,D3		; add frac part
		ADDX.W D1,d5		; add ints.(carried thru)
		BCS.S lpvoice1		; voice looped?
CONT1		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modb		ADD.W D2,(A4)+
		ADD.W D4,D3			 
		ADDX.W D1,d5
		BCS.S lpvoice2
CONT2		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modc		ADD.W D2,(A4)+
		ADD.W D4,D3			
		ADDX.W D1,d5
		BCS lpvoice3
CONT3		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modd		ADD.W D2,(A4)+			
		ADD.W D4,D3
		ADDX.W D1,d5
CONT4		DBCS  D0,makelp
		BCS lpvoice4
donemain	MOVE.W #0,D0
		AND #3,D0			; remaining bytes.
		SUBQ #1,D0
		BMI.S yeah
niblp		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
mode		ADD.W D2,(A4)+
		ADD.W D4,D3
		ADDX.W D1,d5
CONT5		DBCS D0,niblp
		BCS lpvoicelast
yeah		RTS

buffbase	DS.L 1
loopfreq:	DS.W 2
looplength:	DS.L 1
voltab_ptr	DS.L 1

lpvoice		MACRO
		MOVE.L A0,A2 
		EXT.L D5
		ADD.L looplength(PC),D5	; fetch loop constants
		MOVEM.W loopfreq(PC),D1/D4	; (channel independent)
		MOVEQ #0,D2
		MOVE D2,CCR	
 		BRA \1
		ENDM

lpvoice1:	lpvoice CONT1			;
lpvoice2:	lpvoice CONT2			; loop routs
lpvoice3:	lpvoice CONT3			; (since code is repeated)
lpvoice4:	lpvoice CONT4			;
lpvoicelast:	lpvoice CONT5			

aadd		ADD.W D2,(A4)+
amove		MOVE.W D2,(A4)+

nulsamp		ds.l 2			; nul sample.
buff_ptr:	dc.l 0
sndbuff1:	ds.w $400				; buffer for voices 1+2
endbuff1:	dc.w -1
sndbuff2	ds.w $400				; buffer for voices 3+4
endbuff2	dc.w -1

fillx1:		DC.W 0
fillx2:		DC.W 0

; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.

ste_flg		DC.W 0
	
Ste_Test	LEA $FFFF8205.W,A5
		MOVEQ #-1,D1
		MOVE.B (A5),D0
		MOVE.B D1,(A5)
		CMP.B (A5),D0
		BEQ .notSTE
		MOVE.B	D0,(a5)
.ste_found	ST ste_flg
		MOVE.W #1,Which_replay
		LEA.L setsam_dat(PC),A6
		MOVEQ #3,D6
.mwwritx	MOVE.W #$7ff,$ffff8924.W
.mwwritx2	CMP.W #$7ff,$ffff8924.W
		BNE.S .mwwritx2
		MOVE.W (A6)+,$ffff8922.W
		DBF D6,.mwwritx
.notSTE		RTS

temp:		dc.l	0
setsam_dat:	dc.w	%0000000011010100  	;mastervol
		dc.w	%0000010010000110  	;treble
		dc.w	%0000010001000110  	;bass
		dc.w	%0000000000000001  	;mixer

; Select The Playback Routine D0.W = 0 to 6

Select_PlayRout:MOVE.W SR,-(SP)
		MOVE #$2700,SR
		MOVE.W D0,Which_replay
		ADD.W D0,D0
		ADD.W D0,D0		; *4 (longword lookup)
		MOVE.L Output_Routs(PC,D0),$110.W
		JSR rout_tab(PC,D0.W)	; jump to setup rout
		MOVE.W (SP)+,SR
		RTS

rout_tab	BRA.W YM2149_Setup
		BRA.W Ste_Setup
		BRA.W Internal_Off
		BRA.W Internal_Off
		BRA.W Internal_Off
		BRA.W Internal_Off
		BRA.W Internal_Off

Which_replay	DC.W 0			; 0 - 6 as below
Output_Routs	DC.L YM2149_Player
		DC.L Ste_Stereo
		DC.L Replay_Player
		DC.L ReplayPro_Player
		DC.L Replay_Stereo
		DC.L MV16_Player
		DC.L ProSound_Player


; YM2149 Setup rout - turns off ste dma(if machine is st) and clears YM.

YM2149_Setup:	TST.B ste_flg
		BEQ.S .not_ste 
		MOVE.W #0,$FFFF8900.W
.not_ste	BSR Initsoundchip			; init soundchip
		RTS

; Ste Stereo Setup rout - turns off YM 2149 and setsup dma.

Ste_Setup:	TST.B ste_flg
		BEQ.S .not_ste
		BSR Killsoundchip
		MOVE.W #0,$FFFF8900.W
		MOVE.W #$8080,$D0.W		; prime with nul sample
		LEA temp(PC),A6
		MOVE.L #$D0,(A6)			
		MOVE.B 1(A6),$ffff8903.W
		MOVE.B 2(A6),$ffff8905.W	; set start of buffer
		MOVE.B 3(A6),$ffff8907.W
		MOVE.L #$D2,(A6)
		MOVE.B 1(A6),$ffff890f.W
		MOVE.B 2(A6),$ffff8911.W	; and set end of buf
		MOVE.B 3(A6),$ffff8913.W
		MOVE.W #%0000000000000011,$ffff8920.W
		MOVE.W #3,$FFFF8900.W	; dma go!
.not_ste	RTS

; Setup rout for all other output routs - kills both dma and YM sound.

Internal_Off:	TST.B ste_flg
		BEQ.S .not_ste 
		MOVE.W #0,$FFFF8900.W
.not_ste	BSR Killsoundchip
 		RTS

;--------- The 12 bit sample interrupt Routines. They Use D7/A1 ---------;
; YM2149 Soundchip, Replay Cartridge, Replay Professional, Stereo Playback,
; STE Stereo Output, Pro-Sound Designer Cartridge, MV16 Cartridge.

; YM2149 Soundchip output.

YM2149_Player:	move.w (a1)+,d7
		bmi.s .loopit
.contsnd	add.w $800(a1),d7
		lsl #3,d7
		move.l a1,usp
		lea $ffff8800.w,a1		; output
		move.l sound_look+4(pc,d7.w),(a1)
		move.l sound_look(pc,d7.w),d7	; using quartet table.
		movep.l d7,(a1)
		move.l usp,a1
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd
sound_look:	incbin quarfast.tab

; Ste Stereo sound output with volume boost.

Ste_Stereo:	move.w d6,-(sp)
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd	move.w $800(a1),d6
		add.w d6,d6
		add.w d7,d7
		move.w stetab(pc,d6),d6
		move.b stetab(pc,d7),d6
		move.w d6,$d0.w
		move.w (sp)+,d6
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

stetab		dcb.w 128,$8000
i		set -128
		rept 256
		dc.b i,0
i		set i+1
		endr
		dcb.w 128,$7f00

; Replay Catridge Output

Replay_Player:	move.w (a1)+,d7
		bmi.s .loopit
.contsnd	move.l a0,usp
		add.w $800(a1),d7
		add.w d7,d7
		move.w replaytab(pc,d7),d7	; give the replay
		lea $fa0000,a0		; output a vol boost!!
		move.b (a0,d7.w),d7
		move.l usp,a0
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

replaytab	ds.w	384
i		set 0
		rept	64
		dc.w i,i+2,i+4,i+6
i		set i+8
		endr
		dcb.w 	384,$1fe

; Replay Professional Cartridge Output.

ReplayPro_Player:
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd	move.l a0,usp
		add.w $800(a1),d7
		add.w d7,d7
		add.w d7,d7
		lea $fa0000,a0			
		move.b (a0,d7.w),d7		; output (by input!!)
		move.l usp,a0
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

; Playback Stereo Catridge Output

Replay_Stereo:	move.l a0,usp
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd	lea $fA0000,a0	
		add.w d7,d7
		move.w stereotab(pc,d7),d7
		move.b (a0,d7.w),d7		; output chans 1,2
		move.w $800(a1),d7
		add.w d7,d7
		move.w stereotab(pc,d7),d7	
		add #$200,d7
		move.b (a0,d7.w),d7		;    "      "  3,4
		move.l usp,a0
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

stereotab:	ds.w	128		; bottom clip
i		set	0
		rept	64
		dc.w	i,i+2,i+4,i+6
i		set	i+8
		endr
		dcb.w	128,$1FE		; top clip

; MV16 Catridge Output

MV16_Player:	move.l a0,usp
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd	add.w $800(a1),d7
		lsl #3,d7
		lea $fa0000,a0		
		move.b (a0,d7.w),d7		; output (by input!!)
		move.l usp,a0
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

; Pro-Sound Designer Cartridge

ProSound_Player:move.l a0,usp
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd	add.w $800(a1),d7
		lsr #2,d7			; (make 8 bits)
		lea $ffff8848.w,a0
		move.w #$f00,(a0)+
		move.b d7,(a0)		; output
		move.l usp,a0	
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

; ST specific initialisation routines - sets up shadow amiga registers.

STspecific:	LEA  nulsamp+2(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		BSR initvoice
		LEA ch2s(pc),A0
		BSR initvoice		; init shadow regs
		LEA ch3s(pc),A0
		BSR initvoice
		LEA ch4s(pc),A0
		BSR initvoice
		LEA sndbuff1(PC),A0
		MOVE.L A0,buff_ptr
		LEA sndbuff2(PC),A1
		MOVEQ.L	#0,D1
		MOVEQ #$7F,D0
.setbuf1	MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+		; clear 2 ring buffers
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		DBF D0,.setbuf1
		RTS
initvoice:	MOVE.L A2,(A0)		; point voice to nul sample
		MOVE.W #2,4(A0)	
		MOVE.W D0,6(A0)		; period=0
		MOVE.W D0,8(A0)		; volume=0
		MOVE.L A2,10(A0)		; and loop point to nul sample
		MOVE.W #2,14(A0)
		MOVE.W D0,16(A0)		; clear fraction part.
		RTS

; Initialise Soundchip

Initsoundchip:	LEA $FFFF8800.W,A0
		MOVE.B #7,(A0)		; turn on sound
		MOVE.B #$c0,D0
		AND.B (a0),D0
		OR.B #$38,D0
		MOVE.B d0,2(a0)
		MOVE.W #$0500,d0		; clear out ym2149
.initslp	MOVEP.W	d0,(a0)
		SUB.W #$0100,d0
		BPL.S .initslp
		RTS

; Reset sound chip

Killsoundchip	MOVE.W D0,-(SP)
		MOVE.B #7,$ffff8800.W		
		MOVE.B #7,D0
		OR.B $ffff8800.W,D0
		MOVE.B D0,$ffff8802.W
		MOVE.W (SP)+,D0
		RTS

; Make sure Volume lookup table is on a 256 byte boundary.

Init_Voltab	LEA vols+256(PC),A0
		MOVE.L A0,D0
		CLR.B D0
		LEA voltab_ptr(PC),A1
		TST.L (A1)
		BNE.S .alreadyinited
		MOVE.L D0,(A1)
		MOVE.L D0,A1
		MOVE.W #(16640/16)-1,D0
.lp		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D0,.lp
.alreadyinited	RTS


; Shadow Amiga Registers.
	
ch1s		DS.W 9
ch2s		DS.W 9
ch3s		DS.W 9
ch4s		DS.W 9

mt_mulu		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

next		dc.b "tranceact.rsc",0		

freqs		ds.l 2
		incbin freq37.bin		; frequency table. int.w/frac.w
		even

vols		ds.l 64
		incbin pt_volta.dat		; 65 ,256 byte lookups.
		even
zapper		include zap.s
		even
mt_data		incbin push.mod
		even
pic		incbin korridor.pi1
		even				

		SECTION BSS
		DS.L 399
phys	ds.l 1
env	ds.l 0		
my_stack	DS.L 4
		
