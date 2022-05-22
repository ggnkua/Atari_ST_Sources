;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; TFMX Pro 2.0 Replay Routine (STE Version)				;
;									;
;     Paula emulator							;
;     Developed : 13/02/1991.     This Version updated : 23/06/1991	;	
;     8-voice added: 21/12/1992.					;
;									;
;------------------   A few notes about this driver   ------------------;
; - TFMX was a creation of Chris Hšlsbeck from who knows when		;
; - Emulator adapted to be more Paula-like by Marx Marvelous/TPPI	;
; - TFMX player adapted by Marx Marvelous/TPPI				;
; - Everything else by Griff/Electronic Images				;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

dmamask			EQU %00000010
BUFSIZE 		=	2000

		OPT O-,OW-

letsgo		CLR.L -(SP)
		MOVE #$20,-(SP)	
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVE.L USP,A0
		MOVE.L A0,oldusp
		
		LEA my_stack,SP			; our own stack.
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_stuff		; save palette
		BSR Init_Voltab			; initialise volume table.
		BSR tables_init2

		MOVE.L #mt_data,tmp1adr
		MOVE.L #mt_smps,tmp2adr

		BSR Test_for_8_vs

		bsr STspecific

		BSR init_ints			start ints

		BSR tfmx_base+0			init the player
		MOVE.L tmp1adr,d0
		MOVE.L tmp2adr,d1
		BSR tfmx_base+20		init the module

		move.w #$1E,songnum		load last song into ctr
		bsr tfmx_base+12		and use rt arw to search
		move.b #$CD,key			for first valid tune

.waitk
		tst.b ciatempochg
		beq.s .brian
		sf ciatempochg
.brian
		MOVE.B key(PC),D0

		CMP.B #$4B+$80,D0
		BNE.S .notleft
		clr.b key
.lfbad
		subq.w #1,songnum
		and.w #$1F,songnum
		move.w songnum,d0
		cmp.b #$1F,d0
		beq.s .lfbad
		move.l tmp1adr,a0
		add.w d0,a0
		add.w d0,a0
		tst.w $140(A0)
		ble.s .lfbad
		bsr tfmx_base+12
		BRA .waitk
.notleft	CMP.B #$4D+$80,D0
		BNE.S .notright
		clr.b key
.rtbad
		addq.w #1,songnum
		and.w #$1F,songnum
		move.w songnum,d0
		cmp.b #$1F,d0
		beq.s .rtbad
		move.l tmp1adr,a0
		add.w d0,a0
		add.w d0,a0
		tst.w $140(A0)
		ble.s .rtbad
		bsr tfmx_base+12
		BRA .waitk
.notright
		CMP.B #$50+$80,D0
		bne.s .notdn
		subq.w #1,ciatempo
		cmp.w #31,ciatempo
		bne .clopd
		move.w #32,ciatempo
		clr key
		bra .waitk
.clopd		move.w ciatempo,RealTempo
		sf key
		bra .waitk
.notdn
		CMP.B #$48+$80,D0
		bne.s .notup
		addq.w #1,ciatempo
		cmp.w #256,ciatempo
		bne .clopu
		move.w #255,ciatempo
		clr key
		bra .waitk
.clopu
		move.w ciatempo,RealTempo
		sf key
		bra .waitk
.notup
		CMP.B #$47+$80,D0
		bne.s .not60h
		move.w #150,ciatempo
		move.w ciatempo,RealTempo
		bra .waitk
.not60h
		CMP.B #$52+$80,D0
		bne.s .not50h
		move.w #125,ciatempo
		move.w ciatempo,RealTempo
		sf key
		bra .waitk
.not50h
		CMP.B #$39+$80,D0		; space exits.
		BNE .waitk
		moveq.l #15,d0
		swap.w d0
		bsr tfmx_base+40
		bsr tfmx_base+44
.waitfade
		tst.w (a0)
		bne.s .waitfade

		BSR stop_music
		BSR restore_ints		; restore gem..

exit		MOVEM.L old_stuff(PC),D0-D7	; restore palette
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.L oldsp(PC),-(SP)
		MOVE #$20,-(SP)	
		TRAP #1				; user mode
		ADDQ.L #6,SP
		CLR.W -(SP)			; Get dir.
		CLR -(SP)
		TRAP #1

songnum		dc.w	0
ciatempo	dc.w	125
ciatempochg	dc.w	0
voices		dc.w	0

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.L $118.W,(A0)+		; save some vectors
		MOVE.L $134.W,(A0)+		; save some vectors
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B #$00,$FFFFFA07.W
		MOVE.B #$40,$FFFFFA09.W
		MOVE.B #$00,$FFFFFA13.W
		MOVE.B #$40,$FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W		; software end of int.
		LEA key_rout(PC),A0
		MOVE.L A0,$118.W		; and our keyrout.
		CLR key
		BSR  start_music			
		MOVE #$2500,SR
		MOVEQ #$11,D0			; resume sending
		BSR Writeikbd
		MOVEQ #$12,D0			; kill mouse
		BSR Writeikbd
		BSR flush
		RTS
.rte		RTE

; Restore mfp vectors and ints.

restore_ints	MOVE.L oldusp(PC),A0
		MOVE.L A0,USP
		MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.L (a0)+,$118.W	; save some vectors
		MOVE.L (a0)+,$134.W	; save some vectors
		MOVE.B (a0)+,$FFFFFA07.W
		MOVE.B (a0)+,$FFFFFA09.W
		MOVE.B (a0)+,$FFFFFA13.W
		MOVE.B (a0)+,$FFFFFA15.W
		MOVE.B (a0)+,$FFFFFA17.W
		MOVE.B (a0)+,$FFFFFA19.W
		MOVE.B (a0)+,$FFFFFA1F.W
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume
		BSR Writeikbd		
		MOVEQ #$8,D0			; restore mouse.
		BSR Writeikbd
		BSR flush
		RTS

old_stuff:	DS.L 22
oldres		DS.W 1
oldsp		DS.L 1
oldusp		DS.L 1
tmp1adr		DS.L 1
tmp2adr		DS.L 1

; Flush IKBD

flush		BTST.B #0,$FFFFFC00.W		; any waiting?
		BEQ.S .flok			; exit if none waiting.
		MOVE.B $FFFFFC02.W,D0		; get next in queue
		BRA.S flush			; and continue
.flok		RTS

; Write d0 to IKBD

Writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Writeikbd			; wait for ready
		MOVE.B D0,$FFFFFC02.W		; and send...
		RTS

; Keyboard handler interrupt routine...

key_rout	MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0			; int req?
		BEQ.S .end			
		BTST #0,D0			; 
		BEQ.S .end
		MOVE.B $FFFFFC02.W,key		; store keypress
.end		MOVE (SP)+,D0
		RTE
key		DC.W 0

; This routine goes through the mod and looks for voice numbers greater
; than 3.  If there are any the search aborts and voices is set to 2.  If
; not, voices is set to 0.

Test_for_8_vs	st voices
		move.l	tmp1adr,a0
		move.l	$1D4(a0),a1
		move.l	$1D8(a0),a2
		add.l	a0,a1
		add.l	a0,a2
.lp1		cmp.l	a1,a2
		beq.s	.abort0srch
		move.l	(a1)+,a3
		add.l	a0,a3
.lp2		move.l	(a3)+,d1
		rol.l	#8,d1
		cmp.b	#$F0,d1
		beq.s	.lp1
		cmp.b	#$C0,d1
		bge.s	.lp2
		swap.w	d1
		and.b	#$F,d1
		cmp.b	#3,d1
		bls.s	.lp2
		rts
.abort0srch	sf	voices
		rts

pd		dc.w	25

; generate the Ami frequency conversion table and lookup table for note
; values (for finetune purposes)

tables_init2
	movem.l	d0-d7/a0-a6,-(a7)
	lea	freqs+8192,a0
	move.l	#2047,d0
	move.l	#$5D37A,d6		the constant!!!
	move.l	d6,d7
	mulu.w	pd,d6
	swap.w	d7
	mulu.w	pd,d7
	swap.w	d7
	add.l	d6,d7
.no0_lp
	move.l	d7,d1
	move.l	d1,d2
	clr.w	d1
	swap.w	d1
	cmp.w	d1,d0
	bgt.s	.no1
	swap.w	d2
	clr.w	d2
	swap.w	d2
	divu.w	d0,d1		d'h=b/a
	move.l	d1,d3
	clr.w	d3
	add.l	d3,d2
	divu.w	d0,d2
	swap.w	d2
	clr.w	d2
	add.l	d2,d1
	swap.w	d1
	bra.s	.no2
.no1
	divu.w	d0,d2
	moveq	#0,d1
	move.w	d2,d1
.no2
	move.l	d1,-(a0)
	subq.w	#1,d0
	bne.s	.no0_lp
	clr.l	-(a0)
	movem.l	(a7)+,d0-d7/a0-a6
	rts

; TFMX equates

* Referenced from tfmx_parms (64 bytes)
p1_mdatbase	=	$0	l
p1_smplbase	=	$4	l
p1_chanstop	=	$8	w
p1_chanstart	=	$A	w
p1_subsong2	=	$C	b
p1_kmastervol	=	$D	b
;4
p1_cmd0		=	$12	l
p1_cmd1		=	$13
p1_cmd2		=	$14
p1_cmd3		=	$15
p1_cntdown	=	$16	w
p1_playflag	=	$18	b
p1_overagain	=	$19
;4
p1_ciatempo	=	$1E	w
;6
p1_subsong	=	$26	w
p1_nmastervol	=	$28	b	new
p1_tmastervol	=	$29	b	target
p1_cmastervol	=	$2A	b	count
p1_rmastervol	=	$2B	b	reset-count
p1_onflag	=	$2C
p1_nonflag	=	$2D
p1_songrept	=	$2E
p1_plstbase	=	$30
p1_patsbase	=	$34
p1_instbase	=	$38
;4

* Referenced from voice records (one for each channel, 84 bytes per record)
pv_running	=	$0
pv_setup	=	$1
;1
pv_csampmod	=	$3
pv_lastnote	=	$4
pv_thisnote	=	$5
pv_loopctr	=	$6
pv_nybvolume	=	$8
pv_notetune	=	$A
pv_instptr	=	$C
pv_instidx	=	$10
pv_cntdown	=	$12
pv_setdma	=	$14
pv_clrdma	=	$16
pv_nvolume	=	$18	b
pv_ovolume	=	$19	b
pv_reptctr	=	$1A
pv_rsampmod	=	$1B
pv_rvslide	=	$1C
pv_cvslide	=	$1D
pv_tvslide	=	$1E
pv_svslide	=	$1F
pv_kvibrato	=	$20
pv_vibrflag	=	$21
pv_rporta	=	$22
pv_cporta	=	$23
pv_nvibrato	=	$24	w
pv_rvibrato	=	$26
pv_cvibrato	=	$27
pv_per		=	$28
;2
pv_sampstart	=	$2C
pv_kporta	=	$30
pv_tporta	=	$32
pv_samplgth	=	$34
pv_envcycle	=	$36
pv_instisv	=	$38
pv_instpsv	=	$3A
;2
pv_setint	=	$40
pv_clrint	=	$42
;4
pv_audioptr	=	$48
pv_ksampmod	=	$4C
;2
pv_finalper	=	$50	w
pv_freqset	=	$52	b

* Referenced from tfmx_parms2 (200 bytes)
p2_songrst	=	$0
p2_songend	=	$2
p2_songptr	=	$4
p2_speed	=	$6
p2_lpattidx	=	$8	w
p2_lpattctr	=	$A	w
p2_pattptr	=	$28	l
p2_pattidx	=	$48	w
p2_pattrep	=	$4A	b
p2_pattctr	=	$68	w
p2_pattcdn	=	$6A	b
p2_pattpsv	=	$88
p2_pattcsv	=	$A8

; The vbl - calls sequencer and vbl filler.

; NOTE: VERY BADLY OPTIMIZED!  Could be trillions of times better!

do_music	move.w #$2500,sr
		;BSR Set_DMA
		MOVEM.L D0-D7/A0-A6,-(SP)
		;move.w #$303,$FFFF8240.w
		;BSR Vbl_play
		;move.w #$030,$FFFF8240.w
		;BSR calcnextdmaptrs
		;BSR tfmx_irqhdl	
		;move.w #$000,$FFFF8240.w
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE

; Vbl player - this is a kind of 'Paula' Emulator(!)

Vbl_play:	LEA ciaem_tab(PC),A4
		MOVE.W CurrTempo(PC),D6
		ADD.W D6,D6
		MOVE.W (A4,D6),fillx1

		tst.b voices
		bne.s .voices_1_4

; 4 voices.

.voices_1_2	LEA sndbuff1(PC),A4
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch1s(PC),A5
		MOVE.W amove(pc),D0
		BSR add1			; move voice 1
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch4s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 2
.voices_3_4	LEA sndbuff2(PC),A4
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch3s(PC),A5	
		MOVE.W amove(pc),D0
		BSR add1			; move voice 3	
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch2s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 4					; add voice 4
		MOVEQ #1,D5
		BRA conv_voices	

; 8 voices.

.voices_1_4	LEA sndbuff1(PC),a4
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch1s(PC),A5
		MOVE.W amove(pc),D0
		BSR add1			; move voice 1
		LEA freqs(PC),A3
		LEA.L ch5s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 4
		LEA freqs(PC),A3
		LEA.L ch6s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 3
		LEA freqs(PC),A3
		LEA.L ch7s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 2
.voices_5_8	LEA sndbuff2(PC),a4
		LEA freqs(PC),A3
		LEA.L ch2s(PC),A5	
		MOVE.W amove(pc),D0
		BSR add1			; move voice 5	
		LEA freqs(PC),A3
		LEA.L ch3s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 6
		LEA freqs(PC),A3
		LEA.L ch4s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 7
		LEA freqs(PC),A3
		LEA.L ch8s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 8
		MOVEQ #2,D5
;(fall thru)

conv_voices	LEA sndbuff1(PC),A0
		LEA sndbuff2(PC),A1
		MOVE.L stebuf_ptrs(pc),a4
		MOVE.W #$80,D3
		MOVE.W fillx1(PC),D2
		MOVEQ #3,D4
		AND.W D2,D4
		LSR.W #2,D2
		LSL.W #4,D4
		NEG D4
		JMP .next(PC,D4)
.lp		
		rept 4
		MOVE.W (A0)+,D0
		MOVE.W (A1)+,D1
		ASR.W D5,D0
		EOR.B D3,D0
		ASR.W D5,D1
		EOR.B D3,D1
		MOVE.B D0,(A4)+
		MOVE.B D1,(A4)+
		endr
.next		DBF D2,.lp
		RTS

aud_amadr	=	0
aud_amlgt	=	4
aud_amper	=	6
aud_amvol	=	8
aud_amload	=	10
aud_amdma	=	11
aud_adr		=	12
aud_iofs	=	16
aud_fofs	=	18
aud_full	=	20
aud_amint	=	22

; Routine to add/move one voice to buffer. The real Paula emulation part!!

add1		PEA (A4)
		MOVE.L #CLEAR_INST_CACHE+ENABLE_CACHE+ENABLE_DATA_CACHE,D0
		MOVEC.L D0,CACR

		LEA moda(PC),A2
		MOVE.W D0,(A2)
		MOVE.W D0,modb-moda(A2)		; self modifying
		MOVE.W D0,modc-moda(A2)		; add/move code(see below)
		MOVE.W D0,modd-moda(A2)	
		MOVE.W D0,mode-moda(A2)	
		MOVE.W D0,.blech
		tst.b aud_amdma(A5)
		beq .bloch
		tst.w aud_amper(A5)
		beq .bloch
		tst.b aud_amload(A5)
		beq.s .noload
		bsr pau_load
		clr.w aud_fofs(a5)
.noload
		MOVE.L aud_adr(A5),A2		; current sample end address
		MOVE.W aud_amvol(A5),D2		; volume
		cmp.w #$40,d2
		ble.s .rats
		moveq #$40,d2
.rats
		MOVE.W aud_amper(A5),D1		; period
		cmp.w #$7FF,d1
		ble.s .star
		move.w #$7FF,d1
.star
		ADD.W D1,D1
		ADD.W D1,D1			; *4 for lookup
		MOVEM.W 0(A3,D1),D1/D4		; get int.w/frac.w
		MOVE.L voltab_ptr(PC),A6	; base of volume table
		LSL.W #8,D2
		ADD.W D2,A6			; ptr to volume table
		MOVEQ #0,d5
		MOVE.W aud_iofs(A5),d5		; sample length
		CMP.w #8,aud_full(a5)
		BHS.S .vcon
		MOVEQ.L	#0,D4			; channel is off.
		MOVEQ.L	#0,D1			; clear all if off.
		MOVE.L voltab_ptr(PC),A6	; zero vol(safety!!)
		CLR.W aud_fofs(A5)		; clear frac part
.vcon		NEG.L d5
		MOVE.L A6,D6			; vol ptr
		MOVEQ.L	#0,D2			; clr top byte for sample
; Setup Loop stuff
		st loopdma
		move.l aud_amadr(a5),a0
		moveq #0,d3
		move.w aud_amlgt(a5),d3
		add.w d3,d3
		add.l d3,a0
		NEG.L D3
		MOVEM.W D1/D4,loopfreq
		CMP.L #-8,D3
		Blo.S .isloop
.noloop
		sf loopdma
		MOVE.L D2,loopfreq		; no loop-no frequency
		LEA nulsamp+2(PC),A0	 	; no loop-point to nul
.isloop		MOVE.L D3,looplength
		MOVE.W aud_fofs(A5),D3		; fraction part
		MOVE.W aud_amint(A5),loopvoice
		MOVE.W fillx1(PC),D0
		BSR addit			; 
		NEG.L d5			; +ve offset(as original!)
		MOVE.L A2,aud_adr(A5)		; store voice address
		MOVE.W d5,aud_iofs(A5)		; store offset for next time
		MOVE.W D3,aud_fofs(A5)		; fraction part
.skipit		MOVE.L (SP)+,A4
		RTS

.bloch		move.w #$80,d2
		MOVE.W fillx1(PC),D0
		ble.s .no1
		subq.w #1,d0
.blech		move.w d2,(a4)+
		dbf d0,.blech
.no1		BRA.S .skipit

pau_load	sf aud_amload(a5)
		tst.l aud_amadr(a5)
		beq.s .blop
		move.l aud_amadr(a5),a2
		moveq #0,d5
		move.w aud_amlgt(a5),d5
		add.w d5,d5
		bra.s .loaded
.blop
		move.l #nulsamp+2,a5  ; ?? a2
		moveq #2,d5
.loaded
		move.w d5,aud_iofs(a5)
		move.w d5,aud_full(a5)
		add.l d5,a2
		move.l a2,aud_adr(a5)
		neg.l d5
		rts

pau_load2	move.l aud_amadr(a5),a2
		moveq #0,d7
		move.w aud_amlgt(a5),d7
		add.w d7,d7
		add.l d7,a2
		move.l a2,aud_adr(a5)
		rts
	
; Add D0 sample bytes to buffer

addit		MOVE.W D0,donemain+2		; lets go!!
		LSR #2,D0			; /4 for speed
		SUBQ #1,D0			; -1 (dbf)
		BMI.S donemain			; none to do?
makelp
		MOVE.B (A2,d5.L),D6		; fetch sample byte
		MOVE.L D6,A6
		MOVE.B (A6),D2			; lookup in vol tab
moda		ADD.W D2,(A4)+			; add/move to buffer(self modified)
		ADD.W D4,D3			; add frac part
		ADDX.W D1,d5			; add ints.(carried thru)
		BCS.S lpvoice1			; voice looped?
CONT1		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modb		ADD.W D2,(A4)+
		ADD.W D4,D3			; 
		ADDX.W D1,d5
		BCS lpvoice2
CONT2		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modc		ADD.W D2,(A4)+
		ADD.W D4,D3			;
		ADDX.W D1,d5
		BCS lpvoice3
CONT3		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modd		ADD.W D2,(A4)+			;
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

loopfreq:	DS.W 2
looplength:	DS.L 1
loopvoice:	DS.W 1
loopdma:	DS.W 1
voltab_ptr	DS.L 1

lpvoice		MACRO
		MOVE.L A0,A2 
		EXT.L D5
		ADD.L looplength(PC),D5		; fetch loop constants
		MOVEM.W loopfreq(PC),D1/D4	; (channel independent)
		MOVE.B loopdma(PC),aud_amdma(A5)
		bsr pau_load2
; Maybe someday...
		MOVE.W loopvoice,D2
		BPL.S v\1
		JSR tfmx_virqhdl	
v\1
		MOVEQ #0,D2
		MOVE D2,CCR
 		BRA \1
		ENDM

lpvoice1:	lpvoice CONT1			;
lpvoice2:	lpvoice CONT2			; loop routs
lpvoice3:	lpvoice CONT3			; (since code is repeated)
lpvoice4:	lpvoice CONT4			;
lpvoicelast:	lpvoice CONT5			;

aadd		ADD.W D2,(A4)+
amove		MOVE.W D2,(A4)+

nulsamp		ds.l 2				; nul sample.
sndbuff1:	ds.w BUFSIZE			; buffer for voices LEFT
sndbuff2	ds.w BUFSIZE			; buffer for voices RIGHT

stebuf1:	DS.W BUFSIZE	 		; buffers must be this big to handle
stebuf2:	DS.W BUFSIZE			

fillx1:		DC.W 0

temp:		dc.l	0

; Start up music.

start_music	CLR.B $FFFF8901.W
		BSR calcnextdmaptrs
		BSR Set_DMA
		BSET.B #5,$FFFFFA07.W		;iera
		BSET.B #5,$FFFFFA13.W		;imra
		CLR.B $FFFFFA19.W
		MOVE.B #1,$FFFFFA1F.W
		MOVE.B #8,$FFFFFA19.W		;timer a event mode.
		MOVE.L #do_music,$134.W
		BSR Start_DMA
		RTS

; Set DMA to play buffer(buffer len based on TEMPO)

Set_DMA		MOVE.L D0,-(SP)
		MOVE.L thisframe+4(PC),-(SP)
		MOVE.L thisframe(PC),-(SP)
setptrs		BCLR.B #7,$FFFF8901.W
		CLR.W D0
		MOVE.B 3(a7),d0			;9
		MOVE.W d0,$FFFF8906.W
		MOVE.B 2(a7),d0			;8
		MOVE.W d0,$FFFF8904.W
		MOVE.B 1(a7),d0			;7
		MOVE.W d0,$FFFF8902.W	
		MOVE.B 7(a7),d0			;D
		MOVE.W d0,$FFFF8912.W
		MOVE.B 6(a7),d0			;C
		MOVE.W d0,$FFFF8910.W
		MOVE.B 5(a7),d0			;B
		MOVE.W d0,$FFFF890E.W
		ADDQ.L #8,SP
		MOVE.L stebuf_ptrs(PC),D0
		MOVE.L stebuf_ptrs+4(PC),stebuf_ptrs
		MOVE.L D0,stebuf_ptrs+4
		MOVE.L (SP)+,D0
		RTS

thisframe	DC.L 0,0
CurrTempo	DC.W 125
RealTempo	dc.w 125

Start_DMA	MOVE.B #dmamask,$FFFF8921.W 	; set khz
		MOVE.B #3,$FFFF8901.W	  	; start STE dma.
		RTS
stebuf_ptrs	DC.L stebuf1,stebuf2

stop_music:	CLR.B $FFFF8901.W	  	; stop STE dma.
		MOVE.W SR,D0
		OR.W #$700,SR
		BCLR.B #5,$FFFFFA07.W		; iera
		BCLR.B #5,$FFFFFA13.W		; imra
		MOVE.W D0,SR
		RTS 

calcnextdmaptrs	MOVE.W RealTempo(PC),CurrTempo
		MOVE.L stebuf_ptrs+4(PC),A0
		LEA ciaem_tab(PC),A1
		MOVE.W CurrTempo(PC),D0
		ADD.W D0,D0
		MOVE.W (A1,D0),D0
		ADD.W D0,D0
		MOVE.L A0,a1
		ADD.W D0,A1
		MOVEM.L A0/A1,thisframe
		RTS

ciaem_tab	INCBIN CIA_EMU.TAB

; ST specific initialisation routines - sets up shadow amiga registers.

STspecific:	LEA  nulsamp(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		move.w #$01,aud_amint(A0)
		BSR initvoice
		LEA ch2s(pc),A0
		move.w #$02,aud_amint(A0)
		BSR initvoice			;init shadow regs
		LEA ch3s(pc),A0
		move.w #$04,aud_amint(A0)
		BSR initvoice
		LEA ch4s(pc),A0
		move.w #$08,aud_amint(A0)
		BSR initvoice
		LEA ch5s(pc),A0
		move.w #$10,aud_amint(A0)
		BSR initvoice
		LEA ch6s(pc),A0
		move.w #$20,aud_amint(A0)
		BSR initvoice
		LEA ch7s(pc),A0
		move.w #$40,aud_amint(A0)
		BSR initvoice
		LEA ch8s(pc),A0
		move.w #$80,aud_amint(A0)
		BSR initvoice
		LEA sndbuff1(PC),A0
		LEA sndbuff2(PC),A1
		MOVEQ.L	#0,D1
		MOVE #(BUFSIZE/8)-1,D0
.setbuf1	MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+		; clear 2 ring buffers
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		DBF D0,.setbuf1
		RTS
initvoice:	MOVE.L A2,aud_amadr(A0)	; point voice to nul sample
		MOVE.W #1,aud_amlgt(A0)	
		MOVE.W D0,aud_amper(A0)	; period=0
		MOVE.W D0,aud_amvol(A0)	; volume=0
		ST aud_amload(A0)
		SF aud_amdma(A0)
		move.l #nulsamp+2,aud_adr(A0)
		move.w #2,aud_iofs(a0)
		MOVE.W D0,aud_fofs(A0)	; clear fraction part.
		MOVE.W D0,aud_full(A0)	; period=0
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
	
ch1s		DS.W 12
ch2s		DS.W 12
ch3s		DS.W 12
ch4s		DS.W 12
ch5s		DS.W 12
ch6s		DS.W 12
ch7s		DS.W 12
ch8s		DS.W 12

* TFMX-Professional v2.0 player
* Original Ami version by Chris Huelsbeck?, adapted for the ST by
* Marx Marvelous/TPPI

tfmx_base
	bra	tfmx_initplyr		0
	bra	tfmx_player
	bra	tfmx_initplyr
	bra	tfmx_startsong
	bra	tfmx_donote		16
	bra	tfmx_initmodl
	bra	tfmx_initplyr
	bra	tfmx_installplyr
	bra	tfmx_stopnote		32
	bra	tfmx_startsong
	bra	tfmx_makefade		40
	bra	tfmx_cuedataadr
	bra	tfmx_initplyr		48
	bra	tfmx_initplyr
	bra	tfmx_initplyr		56
	bra	tfmx_initplyr
	bra	tfmx_startsong		64	was holdsong
	bra	tfmx_initplyr
	bra	tfmx_initplyr
	bra	tfmx_initplyr
	bra	tfmx_initplyr		80
	bra	tfmx_setupframerate
	bra	tfmx_initplyr
	bra	tfmx_initplyr
	bra	tfmx_initplyr

stopvs	macro	voice
	btst	#\1-1,d0
	beq.s	.not\1
	move.l	tfmx_vrecs+(\1*4)-4,a0
	move.l	pv_audioptr(a0),a0
	sf	aud_amdma(a0)
.not\1
	endm

startvs	macro	voice
	btst	#\1-1,d0
	beq.s	.not\1s
	move.l	tfmx_vrecs+(\1*4)-4,a0
	move.l	pv_audioptr(a0),a0
	st	aud_amload(a0)
	st	aud_amdma(a0)
.not\1s
	endm

setper	macro	voice
	move.l	tfmx_vrecs+(\1*4)-4,a0
	move.w	pv_finalper(a0),d0
	move.l	pv_audioptr(a0),a0
	move.w	d0,aud_amper(a0)
	endm

tfmx_player	movem.l	d0-d7/a0-a6,-(sp)
	lea	tfmx_parms(pc),a6
	move.l	p1_cmd0(a6),-(sp)
	move.w	p1_chanstop(a6),d0
	beq	.nostops
	clr.w	p1_chanstop(a6)
	stopvs	1
	stopvs	2
	stopvs	3
	stopvs	4
	tst.b	voices
	beq.s	.nostops
	stopvs	5
	stopvs	6
	stopvs	7
	stopvs	8
.nostops
	tst.b	p1_playflag(a6)
	beq	.restore
	bsr	tf_doinsts		check efx
	tst.b	p1_subsong2(a6)
	bmi.s	.noplay
	bsr	tf_getnew
.noplay
	setper	1
	setper	2
	setper	3
	setper	4
	tst.b	voices
	beq.s	.nosets
	setper	5
	setper	6
	setper	7
	setper	8
.nosets
	move.w	p1_chanstart(a6),d0
	beq	.nostarts
	clr.w	p1_chanstart(a6)
	startvs	1
	startvs	2
	startvs	3
	startvs	4
	tst.b	voices
	beq.s	.nostarts
	startvs	5
	startvs	6
	startvs	7
	startvs	8
.nostarts
.restore
	move.l	(sp)+,p1_cmd0(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; get new note

tf_getnew
	lea	tfmx_parms2(pc),a5
	move.l	p1_mdatbase(a6),a4
	subq.w	#1,p1_cntdown(a6)
	bpl.s	.rts
	move.w	p2_speed(a5),p1_cntdown(a6)
.again
	move.l	a5,a0
	clr.b	p1_overagain(a6)
	bsr.s	tf_dotrack+2		1
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		2
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		3
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		4
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		5
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		6
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		7
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		8
	tst.b	p1_overagain(a6)
	bne.s	.again
.rts
	rts

tf_dotrack
	addq.l	#4,a0
	cmp.b	#$90,p2_pattidx(a0)
	bcs.s	.legal
	cmp.b	#$FE,p2_pattidx(a0)
	bne.s	.rts
	st 	p2_pattidx(a0)
	move.b	p2_pattidx+1(a0),d0
	bra	tfmx_stopnote
.legal
	lea	tf_cuedata(pc),a1
	st 	$15(a1)
	tst.b	p2_pattcdn(a0)
	beq.s	tf_fetchcmd1
	subq.b	#1,p2_pattcdn(a0)
.rts
	rts

tf_fetchcmd1
	move.w	p2_pattctr(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	p2_pattptr(a0),a1
	move.l	(a1,d0.w),p1_cmd0(a6)
	move.b	p1_cmd0(a6),d0
	cmp.b	#$F0,d0
	bcc.s	.f_cmds
	move.b	d0,d7
	cmp.b	#$C0,d0
	bcc.s	.notnote
	cmp.b	#$7F,d0
	bcs.s	.notnote
	move.b	p1_cmd3(a6),p2_pattcdn(a0)
	clr.b	p1_cmd3(a6)
.notnote
	move.b	p2_pattidx+1(a0),d1
	add.b	d1,d0
	cmp.b	#$C0,d7
	bcc.s	.notnote2
	and.b	#$3F,d0
.notnote2
	move.b	d0,p1_cmd0(a6)
	move.l	p1_cmd0(a6),d0
	bsr	tfmx_donote		play the note
	cmp.b	#$C0,d7
	bcc.s	.tf_fend
	cmp.b	#$7F,d7
	bcs.s	.tf_fend
	addq.w	#1,p2_pattctr(a0)
	rts

; F commands

.f_cmds
	and.w	#15,d0
	add.w	d0,d0
	add.w	d0,d0
	jmp	.f_table(pc,d0.w)
.f_table
	bra	tf_f0		0	end pattern
	bra	tf_f1		1	repeat block
	bra	tf_f2		2	pattern jump
	bra	tf_f3		3	rest
	bra	tf_f4		4	disable track
	bra	tf_f5		5	start release
	bra	tf_f5		6	vibrato
	bra	tf_f5		7	vol slide
	bra	tf_f8		8	call
	bra	tf_f9		9	return
	bra	tf_fa		A	fade master volume
	bra	tf_fb		B	jump other track w/transpose
	bra	tf_f5		C	portamento
	bra	tf_fd		D	cue
	bra	tf_f4		E	disable trk

; FF, other illegal notes
.tf_fend
	addq.w	#1,p2_pattctr(a0)
	bra	tf_fetchcmd1
tf_fend	=	.tf_fend

; F0 = finish ptn

tf_f0
	st 	p2_pattidx(a0)
	move.w	p2_songptr(a5),d0
	cmp.w	p2_songend(a5),d0
	bne.s	.next
	move.w	p2_songrst(a5),p2_songptr(a5)
	bra.s	.get
.next
	addq.w	#1,p2_songptr(a5)
.get
	bsr	tf_getnewptn
	st 	p1_overagain(a6)
	rts

; F1 = repeat section from (x) (y-1) number of times

tf_f1
	tst.b	p2_pattrep(a0)
	beq.s	.zero
	cmp.b	#$FF,p2_pattrep(a0)
	beq.s	.ff
	subq.b	#1,p2_pattrep(a0)
	bra.s	.rept
.zero
	st 	p2_pattrep(a0)
	bra.s	tf_fend
.ff
	move.b	p1_cmd1(a6),d0
	subq.b	#1,d0
	move.b	d0,p2_pattrep(a0)
.rept
	move.w	p1_cmd2(a6),p2_pattctr(a0)
	bra	tf_fetchcmd1

; F2 = pattern jump

tf_f2
	move.b	p1_cmd1(a6),d0
	move.b	d0,p2_pattidx(a0)
	add.w	d0,d0
	add.w	d0,d0
	move.l	p1_patsbase(a6),a1
	move.l	(a1,d0.w),d0
	add.l	a4,d0
	move.l	d0,p2_pattptr(a0)
	move.w	p1_cmd2(a6),p2_pattctr(a0)
	bra	tf_fetchcmd1

; F3 = rest

tf_f3
	move.b	p1_cmd1(a6),p2_pattcdn(a0)
	addq.w	#1,p2_pattctr(a0)
	rts

; F4,FE = kill track

tf_f4
	st 	p2_pattidx(a0)
	rts

; F5,F6,F7,FC = miscellaneous efx

tf_f5
	move.l	p1_cmd0(a6),d0
	bsr	tfmx_donote
	bra	tf_fend

; F8 = call fill

tf_f8
	move.l	p2_pattptr(a0),p2_pattpsv(a0)
	move.w	p2_pattctr(a0),p2_pattcsv(a0)
	move.b	p1_cmd1(a6),d0
	move.b	d0,p2_pattidx(a0)
	add.w	d0,d0
	add.w	d0,d0
	move.l	p1_patsbase(a6),a1
	move.l	(a1,d0.w),d0
	add.l	a4,d0
	move.l	d0,p2_pattptr(a0)
	move.w	p1_cmd2(a6),p2_pattctr(a0)
	bra	tf_fetchcmd1

; F9 = return from fill

tf_f9
	move.l	p2_pattpsv(a5),p2_pattptr(a5)
	move.w	p2_pattcsv(a5),p2_pattctr(a5)
	bra	tf_fend

; FA = fade master volume

tf_fa
	lea	tf_cuedata(pc),a1
	tst.w	0(a1)
	bne	tf_fend
	move.w	#1,0(a1)
	move.b	p1_cmd3(a6),p1_tmastervol(a6)
	move.b	p1_cmd1(a6),p1_cmastervol(a6)
	move.b	p1_cmd1(a6),p1_rmastervol(a6)
	beq.s	.there
	move.b	#1,p1_kmastervol(a6)
	move.b	p1_nmastervol(a6),d0
	cmp.b	p1_tmastervol(a6),d0
	beq.s	.none
	bcs	tf_fend
	neg.b	p1_kmastervol(a6)
	bra	tf_fend
.there
	move.b	p1_tmastervol(a6),p1_nmastervol(a6)
.none
	clr.b	p1_kmastervol(a6)
	clr.w	0(a1)
	bra	tf_fend

; FB = make other track jump with transpose

tf_fb
	MOVE.B	p1_cmd2(A6),D1
	ANDI.W	#7,D1 
	ADD.W	D1,D1 
	ADD.W	D1,D1 
	MOVE.B	p1_cmd1(A6),D0
	MOVE.B	D0,p2_pattidx(A5,D1.W) 
	MOVE.B	p1_cmd3(A6),p2_pattidx+1(A5,D1.W)
	ANDI.W	#$7F,D0 
	ADD.W	D0,D0 
	ADD.W	D0,D0 
	MOVEA.L	p1_patsbase(A6),A1
	MOVE.L	(A1,D0.W),D0 
	ADD.L	A4,D0 
	MOVE.L	D0,p2_pattptr(A5,D1.W) 
	CLR.L	p2_pattctr(A5,D1.W)
	ST	p2_pattrep(A5,D1.W)
	bra	tf_fend

; FD = cueing

tf_fd
	lea	tf_cuedata(pc),a1
	move.b	p1_cmd1(a6),d0
	and.w	#3,d0
	add.w	d0,d0
	move.w	p1_cmd2(a6),$1E(a1,d0.w)
	bra	tf_fend

; read from the plst

tf_getnewptn
	movem.l	a0/a1,-(sp)
tf_getnxtlin
	move.w	p2_songptr(a5),d0
	lsl.w	#4,d0
	move.l	p1_plstbase(a6),a0
	add.w	d0,a0
	move.l	p1_patsbase(a6),a1
	move.w	(a0)+,d0
	cmp.w	#$EFFE,d0
	bne.s	.readem
	move.w	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	jmp	.effetbl(pc,d0.w)
.effetbl
	bra	tf_effestop
	bra	tf_efferepeat
	bra	tf_effetempochg
	bra	tf_effefade
	bra	tf_effefade

; read pattern from the plst and point all 8 tracks to it

.readem
	move.w	d0,p2_pattidx(a5)
	bmi.s	.no1		play nothing
	clr.b	d0
	lsr.w	#6,d0
	move.l	(a1,d0.w),d0
	add.l	a4,d0
	move.l	d0,p2_pattptr(a5)
	clr.l	p2_pattctr(a5)
	st 	p2_pattrep(a5)
.no1
	movem.w	(a0)+,d0-d6
	move.w	d0,$4C(a5)
	bmi.s	.no2
	clr.b	d0
	lsr.w	#6,d0
	move.l	(a1,d0.w),d0
	add.l	a4,d0
	move.l	d0,$2C(a5)
	clr.l	$6C(a5)
	st 	$4E(a5)
.no2
	move.w	d1,$50(a5)
	bmi.s	.no3
	clr.b	d1
	lsr.w	#6,d1
	move.l	(a1,d1.w),d0
	add.l	a4,d0
	move.l	d0,$30(a5)
	clr.l	$70(a5)
	st 	$52(a5)
.no3
	move.w	d2,$54(a5)
	bmi.s	.no4
	clr.b	d2
	lsr.w	#6,d2
	move.l	(a1,d2.w),d0
	add.l	a4,d0
	move.l	d0,$34(a5)
	clr.l	$74(a5)
	st 	$56(a5)
.no4
	move.w	d3,$58(a5)
	bmi.s	.no5
	clr.b	d3
	lsr.w	#6,d3
	move.l	(a1,d3.w),d0
	add.l	a4,d0
	move.l	d0,$38(a5)
	clr.l	$78(a5)
	st 	$5A(a5)
.no5
	move.w	d4,$5C(a5)
	bmi.s	.no6
	clr.b	d4
	lsr.w	#6,d4
	move.l	(a1,d4.w),d0
	add.l	a4,d0
	move.l	d0,$3C(a5)
	clr.l	$7C(a5)
	st 	$5E(a5)
.no6
	move.w	d5,$60(a5)
	bmi.s	.no7
	clr.b	d5
	lsr.w	#6,d5
	move.l	(a1,d5.w),d0
	add.l	a4,d0
	move.l	d0,$40(a5)
	clr.l	$80(a5)
	st 	$62(a5)
.no7
	move.w	d6,$64(a5)
	bmi.s	.no8
	clr.b	d6
	lsr.w	#6,d6
	move.l	(a1,d6.w),d0
	add.l	a4,d0
	move.l	d0,$44(a5)
	clr.l	$84(a5)
	st 	$66(a5)
.no8
	movem.l	(sp)+,a0/a1
	rts

; EFFE0000 = stop

tf_effestop
	clr.b	p1_playflag(a6)
	movem.l	(sp)+,a0/a1
	rts

; EFFE0001 = repeat blocks

tf_efferepeat
	tst.w	p1_songrept(a6)
	beq.s	.zero
	bmi.s	.minus
	subq.w	#1,p1_songrept(a6)
	bra.s	.cont
.zero
	move.w	#$FFFF,p1_songrept(a6)
	addq.w	#1,p2_songptr(a5)
	bra	tf_getnxtlin
.minus
	move.w	2(a0),d0
	subq.w	#1,d0
	move.w	d0,p1_songrept(a6)
.cont
	move.w	(a0),p2_songptr(a5)
	bra	tf_getnxtlin

; EFFE0002 = tempo change

tf_effetempochg
	move.w	(a0),p2_speed(a5)
	move.w	(a0),p1_cntdown(a6)
	move.w	2(a0),d0
	bmi.s	.dontdoit
	and.w	#$1FF,d0
	tst.w	d0
	beq.s	.dontdoit
	move.l	#$1B51F8,d1
	divu	d0,d1
	move.w	d1,p1_ciatempo(a6)
.dontdoit
	addq.w	#1,p2_songptr(a5)
	bra	tf_getnxtlin

; EFFE0003 = fade

tf_effefade
	addq.w	#1,p2_songptr(a5)
	lea	tf_cuedata(pc),a1
	tst.w	0(a1)
	bne	tf_getnxtlin
	move.w	#1,0(a1)
	move.b	3(a0),p1_tmastervol(a6)
	move.b	1(a0),p1_cmastervol(a6)
	move.b	1(a0),p1_rmastervol(a6)
	beq.s	.there
	move.b	#1,p1_kmastervol(a6)
	move.b	p1_nmastervol(a6),d0
	cmp.b	p1_tmastervol(a6),d0
	beq.s	.none
	bcs	tf_getnxtlin
	neg.b	p1_kmastervol(a6)
	bra	tf_getnxtlin
.there
	move.b	p1_tmastervol(a6),p1_nmastervol(a6)
.none
	move.b	#0,p1_kmastervol(a6)
	clr.w	0(a1)
	bra	tf_getnxtlin

tf_doinsts
	lea	v1_parms(pc),a5
	bsr.s	.doinsts
	lea	v2_parms(pc),a5
	bsr.s	.doinsts
	lea	v3_parms(pc),a5
	bsr.s	.doinsts
	lea	v4_parms(pc),a5
	bsr.s	.doinsts
	lea	v5_parms(pc),a5
	bsr.s	.doinsts
	lea	v6_parms(pc),a5
	bsr.s	.doinsts
	lea	v7_parms(pc),a5
	bsr.s	.doinsts
	lea	v8_parms(pc),a5
.doinsts	move.l	pv_audioptr(a5),a4
	tst.b	pv_running(a5)
	beq	tf_endproc
	tst.w	pv_cntdown(a5)			time to next step
	beq.s	tf_vgetnew
	subq.w	#1,pv_cntdown(a5)
	bra	tf_endproc

; get the next note

tf_vgetnew	move.l	pv_instptr(a5),a0
	move.w	pv_instidx(a5),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),p1_cmd0(a6)
	moveq	#0,d0
	move.b	p1_cmd0(a6),d0
	cmp.b	#$2A,d0
	bls.s	.tit
	sf	pv_running(a5)
	bra	tf_endproc
.tit
	cmp.b	#$21,d0
	bhs	tf_vnext
	clr.b	p1_cmd0(a6)
	add.w	d0,d0
	add.w	d0,d0
	jmp	.xjmp(pc,d0.w)
.xjmp
	bra	tf_00		0 = stop efx and dma
	bra	tf_01		1 = start voice
	bra	tf_02		2 = address long
	bra	tf_03		3 = set length
	bra	tf_04		4 = wait
	bra	tf_05		5 = repeat section
	bra	tf_06		6 = jmp
	bra	tf_07		7 = end instrument
	bra	tf_08		8 = set freq
	bra	tf_09		9 = set freq, direct
	bra	tf_0a		A = clear all effects
	bra	tf_0b		B = portamento
	bra	tf_0c		C = vibrato
	bra	tf_0d		D = set fine volume
	bra	tf_0e		E = set volume
	bra	tf_0f		F = vol slide
	bra	tf_10		10 = repeat x times or until release
	bra	tf_11		11 = pointer slide
	bra	tf_12		12 = relative loop lgth
	bra	tf_13		13 = stop dma
	bra	tf_14		14 = wait x cycles or until release
	bra	tf_15		15 = jsr
	bra	tf_16		16 = rts
	bra	tf_17		17 = absolute period
	bra	tf_18		18 = set loop start
	bra	tf_19		19 = setup null sample
	bra	tf_1a		1A = repeat sample
	bra	tf_05		1B \
	bra	tf_05		1C /_ repeat section
	bra	tf_05		1D \
	bra	tf_05		1E /
	bra	tf_1f		1F = set freq, last note relative
	bra	tf_20		20 = cueing
	bra	tf_21		21 = retrig
	bra	tf_vnext		22
	bra	tf_vnext		23
	bra	tf_vnext		24
	bra	tf_vnext		25
	bra	tf_vnext		26
	bra	tf_vnext		27
	bra	tf_vnext		28
	bra	tf_vnext		29

; finish

tf_finish
	tst.b	pv_freqset(a5)
	beq.s	.noadv
	addq.w	#1,pv_instidx(a5)
	bra	tf_endproc
.noadv
	st 	pv_freqset(a5)
tf_vnext
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_00
	clr.b	pv_rvslide(a5)
	clr.b	pv_rvibrato(a5)
	clr.w	pv_kporta(a5)
tf_13
	addq.w	#1,pv_instidx(a5)
	tst.b	p1_cmd1(a6)
	bne.s	.bop
	sf	aud_amdma(a4)
	bra	tf_vgetnew
.bop
	move.w	pv_clrdma(a5),d0
	or.w	d0,p1_chanstop(a6)
	clr.b	pv_freqset(a5)
	bra	tf_endproc

tf_01
	move.b	p1_cmd1(a6),pv_setup(a5)
	move.w	pv_setdma(a5),d0
	or.w	d0,p1_chanstart(a6)
	st	aud_amdma(a4)
	sf	aud_amint(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_02
	clr.b	pv_csampmod(a5)
	move.l	p1_cmd0(a6),d0
	add.l	p1_smplbase(a6),d0		sample base
	move.l	d0,pv_sampstart(a5)
	move.l	d0,(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_11
	move.b	p1_cmd1(a6),pv_csampmod(a5)
	move.b	p1_cmd1(a6),pv_rsampmod(a5)
	move.w	p1_cmd2(a6),d1
	ext.l	d1
	move.l	d1,pv_ksampmod(a5)
	move.l	pv_sampstart(a5),d0
	add.l	d1,d0
	move.l	d0,pv_sampstart(a5)
	move.l	d0,(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_12
	move.w	p1_cmd2(a6),d0
	move.w	pv_samplgth(a5),d1
	add.w	d0,d1
	move.w	d1,pv_samplgth(a5)
	move.w	d1,4(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_03
	move.w	p1_cmd2(a6),pv_samplgth(a5)
	move.w	p1_cmd2(a6),4(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_04
	move.w	p1_cmd2(a6),pv_cntdown(a5)
	bra	tf_finish

tf_1a
	move.w	p1_cmd2(a6),pv_loopctr(a5)
	clr.b	pv_running(a5)
	move.l	pv_audioptr(a5),a1
	st	aud_amint(A1)
	bra	tf_finish

; end-of-voice interrupt for $1A

tfmx_virqhdl
	movem.l	d0/a5,-(sp)
	lea	v1_parms(pc),a5
	btst	#0,d0
	bne.s	.found
	lea	v2_parms(pc),a5
	btst	#1,d0
	bne.s	.found
	lea	v3_parms(pc),a5
	btst	#2,d0
	bne.s	.found
	lea	v4_parms(pc),a5
	btst	#3,d0
	bne.s	.found
	lea	v5_parms(pc),a5
	btst	#4,d0
	bne.s	.found
	lea	v6_parms(pc),a5
	btst	#5,d0
	bne.s	.found
	lea	v7_parms(pc),a5
	btst	#6,d0
	bne.s	.found
	lea	v8_parms(pc),a5
.found
	subq.w	#1,pv_loopctr(a5)
	bpl.s	.pop
	move.b	#$FF,pv_running(a5)
	move.l	pv_audioptr(a5),a5
	sf	aud_amint(A5)
*	sf	aud_amdma(a5)
.pop
	movem.l	(sp)+,d0/a5
	rts

; 1B-1E,5

tf_05
	tst.b	pv_reptctr(a5)
	beq.s	.zero
	cmp.b	#$FF,pv_reptctr(a5)
	beq.s	.ff
	subq.b	#1,pv_reptctr(a5)
	bra.s	.finish
.zero
	st 	pv_reptctr(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew
.ff
	move.b	p1_cmd1(a6),d0
	subq.b	#1,d0
	move.b	d0,pv_reptctr(a5)
.finish
	move.w	p1_cmd2(a6),pv_instidx(a5)
	bra	tf_vgetnew

tf_10
	tst.b	pv_envcycle(a5)
	bne.s	tf_05
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_07
	clr.b	pv_running(a5)
	bra	tf_endproc

tf_0d
	move.w	pv_nybvolume(a5),d0
	add.w	d0,d0
	add.w	pv_nybvolume(a5),d0
	add.w	p1_cmd2(a6),d0
	move.b	d0,pv_nvolume(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_0e
	move.b	p1_cmd3(a6),pv_nvolume(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_21
	move.b	pv_thisnote(a5),p1_cmd0(a6)
	move.b	pv_nybvolume+1(a5),d0
	lsl.b	#4,d0
	or.b	d0,p1_cmd2(a6)
	move.l	p1_cmd0(a6),d0
	bsr	tfmx_donote
	bra	tf_vnext

tf_1f
	move.b	pv_lastnote(a5),d2
	lea	tf_finish(pc),a1
	bra.s	.bob
.tf_09
	moveq	#0,d2
	lea	tf_finish(pc),a1
	bra.s	.bob
.tf_08
	move.b	pv_thisnote(a5),d2
	lea	tf_finish(pc),a1
.bob
	moveq	#0,d0
	move.b	p1_cmd1(a6),d0
	add.b	d2,d0
	and.b	#$3F,d0
	add.w	d0,d0
	lea	tfmx_notevals(pc),a0
	move.w	(a0,d0.w),d0
	move.w	pv_notetune(a5),d1
	add.w	p1_cmd2(a6),d1
	beq.s	.nochg
	add.w	#$100,d1
	mulu	d1,d0
	lsr.l	#8,d0
.nochg
	move.w	d0,pv_per(a5)
	tst.w	pv_kporta(a5)
	bne.s	.jmp
	move.w	d0,pv_finalper(a5)
.jmp
	jmp	(a1)

tf_08	=	.tf_08
tf_09	=	.tf_09

tf_17
	move.w	p1_cmd2(a6),pv_per(a5)
	tst.w	pv_kporta(a5)
	bne	tf_vnext
	move.w	p1_cmd2(a6),pv_finalper(a5)
	bra	tf_vnext

tf_0b
	move.b	p1_cmd1(a6),pv_rporta(a5)
	move.b	#1,pv_cporta(a5)
	tst.w	pv_kporta(a5)
	bne.s	.noset
	move.w	pv_per(a5),pv_tporta(a5)
.noset
	move.w	p1_cmd2(a6),pv_kporta(a5)
	bra	tf_vnext

tf_0c
	move.b	p1_cmd1(a6),d0
	move.b	d0,pv_rvibrato(a5)
	lsr.b	#1,d0
	move.b	d0,pv_cvibrato(a5)
	move.b	p1_cmd3(a6),pv_kvibrato(a5)
	move.b	#1,pv_vibrflag(a5)
	tst.w	pv_kporta(a5)
	bne	tf_vnext
	move.w	pv_per(a5),pv_finalper(a5)
	clr.w	pv_nvibrato(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_0f
	move.b	p1_cmd2(a6),pv_rvslide(a5)
	move.b	p1_cmd1(a6),pv_svslide(a5)
	move.b	p1_cmd2(a6),pv_cvslide(a5)
	move.b	p1_cmd3(a6),pv_tvslide(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_0a
	clr.b	pv_csampmod(a5)
	clr.b	pv_rvslide(a5)
	clr.b	pv_rvibrato(a5)
	clr.w	pv_kporta(a5)
	bra	tf_vnext


tf_14
	tst.b	pv_envcycle(a5)
	beq	tf_vnext
	tst.b	pv_reptctr(a5)
	beq.s	.zero
	cmp.b	#$FF,pv_reptctr(a5)
	beq.s	.ff
	subq.b	#1,pv_reptctr(a5)
	bra.s	.finish
.zero
	st 	pv_reptctr(a5)
	bra	tf_vnext
.ff
	move.b	p1_cmd3(a6),d0
	subq.b	#1,d0
	move.b	d0,pv_reptctr(a5)
.finish
	bra	tf_endproc

tf_15
	move.l	pv_instptr(a5),pv_instpsv(a5)
	move.w	pv_instidx(a5),pv_instisv(a5)
tf_06
	moveq	#0,d0
	move.b	p1_cmd1(a6),d0
	chk	#$80,d0
	and.l	#$7F,d0
	move.l	p1_instbase(a6),a0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a0
	move.l	(a0),d0
	add.l	p1_mdatbase(a6),d0
	move.l	d0,pv_instptr(a5)
	bne.s	*+4
	illegal
	move.w	p1_cmd2(a6),pv_instidx(a5)
	st 	pv_reptctr(a5)
	bra	tf_vgetnew

tf_16
	move.l	pv_instpsv(a5),pv_instptr(a5)
	move.w	pv_instisv(a5),pv_instidx(a5)
	bra	tf_vnext

tf_18
	move.l	p1_cmd0(a6),d0
	add.l	d0,pv_sampstart(a5)
	move.l	pv_sampstart(a5),(a4)
	lsr.w	#1,d0
	sub.w	d0,pv_samplgth(a5)
	move.w	pv_samplgth(a5),4(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_19
	clr.b	pv_csampmod(a5)
	move.l	p1_smplbase(a6),pv_sampstart(a5)
	move.l	p1_smplbase(a6),(a4)
	move.w	#1,pv_samplgth(a5)
	move.w	#1,4(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_20
	move.b	p1_cmd1(a6),d0
	and.w	#3,d0
	add.w	d0,d0
	lea	tf_cuedata(pc),a0
	move.w	p1_cmd2(a6),$1E(a0,d0.w)
	bra	tf_vnext



tf_endproc
	tst.b	pv_setup(a5)
	bmi.s	.skipefx
	bne.s	.dosampmod
	move.b	#1,pv_setup(a5)
.skipefx
	bra	.domasterfade		skip all efx

; sample modulation

.dosampmod
	tst.b	pv_csampmod(a5)
	beq.s	.dovibrato
	move.l	pv_sampstart(a5),d0
	add.l	pv_ksampmod(a5),d0
	move.l	d0,pv_sampstart(a5)
	move.l	d0,(a4)
	sub.b	#1,pv_csampmod(a5)
	bne.s	.dovibrato
	move.b	pv_rsampmod(a5),pv_csampmod(a5)
	neg.l	pv_ksampmod(a5)

; vibrato engine

.dovibrato
	tst.b	pv_rvibrato(a5)
	beq.s	.doporta
	move.b	pv_kvibrato(a5),d0
	ext.w	d0
	add.w	d0,pv_nvibrato(a5)
	move.w	pv_per(a5),d0
	move.w	pv_nvibrato(a5),d1
	beq.s	.nomult
	and.l	#$FFFF,d0
	add.w	#$800,d1
	mulu	d1,d0
	lsl.l	#5,d0
	swap	d0
.nomult
	tst.w	pv_kporta(a5)
	bne.s	.vnoporta
	move.w	d0,pv_finalper(a5)
.vnoporta
	subq.b	#1,pv_cvibrato(a5)
	bne.s	.doporta
	move.b	pv_rvibrato(a5),pv_cvibrato(a5)
	neg.b	pv_kvibrato(a5)

; portamento

.doporta	tst.w	pv_kporta(a5)
	beq.s	.dovslide
	subq.b	#1,pv_cporta(a5)
	bne.s	.dovslide
	move.b	pv_rporta(a5),pv_cporta(a5)
	move.w	pv_per(a5),d1
	moveq	#0,d0
	move.w	pv_tporta(a5),d0
	cmp.w	d1,d0
	beq.s	.endporta
	bcs.s	.porta2
	move.w	#$100,d2
	sub.w	pv_kporta(a5),d2
	mulu	d2,d0
	lsr.l	#8,d0
	cmp.w	d1,d0
	beq.s	.endporta
	bcc.s	.psetper
.endporta
	clr.w	pv_kporta(a5)
	move.w	pv_per(a5),d0
.psetper
	and.w	#$7FF,d0
	move.w	d0,pv_tporta(a5)
	move.w	d0,pv_finalper(a5)
	bra.s	.dovslide
.porta2
	move.w	pv_kporta(a5),d2
	add.w	#$100,d2
	mulu	d2,d0
	lsr.l	#8,d0
	cmp.w	d1,d0
	beq.s	.endporta
	bcc.s	.endporta
	bra.s	.psetper

; volume slide engine

.dovslide
	tst.b	pv_rvslide(a5)
	beq.s	.dotempo
	tst.b	pv_cvslide(a5)
	beq.s	.dovs
	subq.b	#1,pv_cvslide(a5)
	bra.s	.dotempo
.dovs
	move.b	pv_rvslide(a5),pv_cvslide(a5)
	move.b	pv_tvslide(a5),d0
	cmp.b	pv_nvolume(a5),d0
	bgt.s	.sbig
	move.b	pv_svslide(a5),d1
	sub.b	d1,pv_nvolume(a5)
	bmi.s	.stopslide
	cmp.b	pv_nvolume(a5),d0
	bge.s	.stopslide
	bra.s	.dotempo
.stopslide
	move.b	pv_tvslide(a5),pv_nvolume(a5)
	clr.b	pv_rvslide(a5)
	bra.s	.dotempo
.sbig
	move.b	pv_svslide(a5),d1
	add.b	d1,pv_nvolume(a5)
	cmp.b	pv_nvolume(a5),d0
	ble.s	.stopslide

; tempo control

.dotempo
	tst.w	p1_ciatempo(a6)
	beq.s	.domasterfade
	move.w	p1_ciatempo(a6),-(a7)
	bsr	tf_settempo
	addq.l	#2,a7
	clr.w	p1_ciatempo(a6)

; master fade

.domasterfade
	tst.b	p1_kmastervol(a6)
	beq.s	.nomasf
	subq.b	#1,p1_cmastervol(a6)
	bne.s	.nomasf
	move.b	p1_rmastervol(a6),p1_cmastervol(a6)
	move.b	p1_kmastervol(a6),d0
	add.b	d0,p1_nmastervol(a6)
	move.b	p1_tmastervol(a6),d0
	cmp.b	p1_nmastervol(a6),d0
	bne.s	.nomasf
	clr.b	p1_kmastervol(a6)
	lea	tf_cuedata(pc),a0
	clr.w	0(a0)
.nomasf
	moveq	#0,d1
	move.b	p1_nmastervol(a6),d1
	moveq	#0,d0
	move.b	pv_nvolume(a5),d0
	btst	#6,d1
	bne.s	.setvol
	add.w	d0,d0
	add.w	d0,d0
	mulu	d1,d0
	lsr.w	#8,d0

; set volume reg if necessary, then finish

.setvol
	cmp.b	pv_ovolume(a5),d0
	beq.s	.rts
	move.b	pv_nvolume(a5),pv_ovolume(a5)
	move.w	d0,aud_amvol(a4)
.rts
	cmp.w	#$6C,pv_finalper(a5)
	bge.s	.blahblah
	move.w	#$6C,pv_finalper(a5)
.blahblah
	rts

; play a note or other fx

tfmx_donote
	movem.l	d0/a4-a6,-(sp)
	lea	tfmx_parms(pc),a6
	move.l	p1_cmd0(a6),-(sp)		save old cmd
	lea	tfmx_vrecs(pc),a5
	move.l	d0,p1_cmd0(a6)		store mod'd cmd
	move.b	p1_cmd2(a6),d0		likely, channel #
	and.w	#15,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a5,d0.w),a5		get chan rec
	move.b	p1_cmd0(a6),d0
	tst.b	d0
	bpl	.is_note

	cmp.b	#$F7,d0
	bne.s	.not_f7
	move.b	p1_cmd1(a6),pv_svslide(a5)
	move.b	p1_cmd2(a6),d0
	lsr.b	#4,d0
	addq.b	#1,d0
	move.b	d0,pv_cvslide(a5)
	move.b	d0,pv_rvslide(a5)
	move.b	p1_cmd3(a6),pv_tvslide(a5)
	bra	.return

.not_f7
	cmp.b	#$F6,d0
	bne.s	.not_f6
	move.b	p1_cmd1(a6),d0
	and.b	#$FE,d0
	move.b	d0,pv_rvibrato(a5)
	lsr.b	#1,d0
	move.b	d0,pv_cvibrato(a5)
	move.b	p1_cmd3(a6),pv_kvibrato(a5)
	move.b	#1,pv_vibrflag(a5)
	clr.w	pv_nvibrato(a5)
	bra.s	.return

.not_f6
	cmp.b	#$F5,d0
	bne.s	.not_f5
	clr.b	pv_envcycle(a5)
	bra.s	.return

.not_f5
	cmp.b	#$BF,d0
	bcc.s	.is_port
; start a note
.is_note
	move.b	p1_cmd3(a6),d0
	ext.w	d0
	move.w	d0,pv_notetune(a5)
	move.b	p1_cmd2(a6),d0
	lsr.b	#4,d0
	move.b	d0,pv_nybvolume+1(a5)
	move.b	p1_cmd1(a6),d0
	move.b	pv_thisnote(a5),pv_lastnote(a5)
	move.b	p1_cmd0(a6),pv_thisnote(a5)
	move.l	p1_instbase(a6),a4
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a4
	move.l	(a4),a4
	add.l	p1_mdatbase(a6),a4
	cmp.l	p1_patsbase(a6),a4
	blo.s	*+4
	illegal
	move.l	a4,pv_instptr(a5)
	clr.w	pv_instidx(a5)
	clr.w	pv_cntdown(a5)
	clr.b	pv_setup(a5)
	st 	pv_reptctr(a5)
	st 	pv_running(a5)
	clr.w	pv_loopctr(a5)
	move.l	pv_audioptr(a5),a1
	sf	aud_amint(A1)
	move.b	#1,pv_envcycle(a5)
.return
	move.l	(sp)+,p1_cmd0(a6)
	movem.l	(sp)+,d0/a4-a6
	rts

.is_port
	move.b	p1_cmd1(a6),pv_rporta(a5)
	move.b	#1,pv_cporta(a5)
	tst.w	pv_kporta(a5)
	bne.s	.noset
	move.w	pv_per(a5),pv_tporta(a5)
.noset
	clr.w	pv_kporta(a5)
	move.b	p1_cmd3(a6),pv_kporta+1(a5)
	move.b	p1_cmd0(a6),d0
	and.w	#$3F,d0
	move.b	d0,pv_thisnote(a5)
	add.w	d0,d0
	lea	tfmx_notevals(pc),a4
	move.w	(a4,d0.w),pv_per(a5)
	bra.s	.return

; stop a voice

tfmx_stopnote
	movem.l	a1/a5,-(sp)
	lea	tfmx_vrecs(pc),a5
	and.w	#15,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a5,d0.w),a5
	move.l	pv_audioptr(a5),a1
	sf	aud_amint(A1)
	move.l	#nulsamp,aud_amadr(a1)
	move.w	#1,aud_amlgt(a1)
	sf	aud_amload(a1)
	sf	aud_amdma(a1)
	clr.b	pv_running(a5)
	movem.l	(sp)+,a1/a5
	rts

tfmx_makefade
	movem.l	a5/a6,-(sp)
	lea	tfmx_parms(pc),a6
	lea	tf_cuedata(pc),a5
	move.w	#1,0(a5)
	move.b	d0,p1_tmastervol(a6)
	swap	d0
	move.b	d0,p1_cmastervol(a6)
	move.b	d0,p1_rmastervol(a6)
	beq.s	.match
	move.b	p1_nmastervol(a6),d0
	move.b	#1,p1_kmastervol(a6)
	cmp.b	p1_tmastervol(a6),d0
	beq.s	.stop
	bcs.s	.end
	neg.b	p1_kmastervol(a6)
	bra.s	.end
.match
	move.b	p1_tmastervol(a6),p1_nmastervol(a6)
.stop
	clr.b	p1_kmastervol(a6)
	clr.w	0(a5)
.end
	movem.l	(sp)+,a5/a6
	rts

tfmx_cuedataadr
	lea	tf_cuedata(pc),a0
	rts

; reset

tfmx_initplyr
	move.l	a6,-(sp)
	lea	tfmx_parms(pc),a6
	clr.b	p1_playflag(a6)
	clr.w	p1_chanstart(a6)
	lea	v1_parms(pc),a6
	bsr.s	.clrv
	lea	v2_parms(pc),a6
	bsr.s	.clrv
	lea	v3_parms(pc),a6
	bsr.s	.clrv
	lea	v4_parms(pc),a6
	bsr.s	.clrv
	lea	v5_parms(pc),a6
	bsr.s	.clrv
	lea	v6_parms(pc),a6
	bsr.s	.clrv
	lea	v7_parms(pc),a6
	bsr.s	.clrv
	lea	v8_parms(pc),a6
	bsr.s	.clrv
	lea	tf_cuedata(pc),a6
	clr.b	$15(a6)
	move.l	(sp)+,a6
	rts
.clrv
	st	pv_setup(a6)
	clr.b	pv_running(a6)
	clr.b	pv_ovolume(a6)
	move.l	#nulinst,pv_instptr(a6)
	clr.w	pv_instidx(a6)
	move.l	pv_audioptr(a6),a6
	move.l	#nulsamp,(a6)+
	move.w	#1,(a6)+
	clr.l	(a6)+
	sf	(a6)+
	sf	(a6)+
	rts

nulinst
	dc.l	$07000000
	dc.l	$07000000


; start a new subsong

tfmx_startsong
	movem.l	d1-d7/a0-a6,-(sp)
	lea	tfmx_parms(pc),a6
	move.b	d0,p1_subsong+1(a6)
	bsr	tfmx_initplyr
	clr.b	p1_playflag(a6)
	move.l	p1_mdatbase(a6),a4		mdat_base
	move.b	p1_subsong+1(a6),d0
	and.w	#$1F,d0
	add.w	d0,d0
	add.w	d0,a4
	bsr	tfmx_setupframerate
	lea	tfmx_parms2(pc),a5
	move.w	$100(a4),p2_songptr(a5)
	move.w	$100(a4),p2_songrst(a5)
	move.w	$140(a4),p2_songend(a5)
	move.w	$180(a4),d2
	cmp.w	#15,d2
	bls.s	.nocia
	move.w	d2,d0
	move.l	#$1B51F8,d1
	divu	d0,d1
	move.w	d1,p1_ciatempo(a6)
	move.w	d1,-(a7)
	bsr	tf_settempo
	addq.l	#2,a7
	move.b	#1,p1_onflag(a6)
	moveq	#0,d2
.nocia
	move.w	d2,p2_speed(a5)
	moveq	#$1C,d1
	lea	tfmx_dummypat(pc),a4
.vcslp
	move.l	a4,p2_pattptr(a5,d1.w)
	move.w	#$FF00,p2_pattidx(a5,d1.w)
	clr.l	p2_pattctr(a5,d1.w)
	subq.w	#4,d1
	bpl.s	.vcslp
	move.l	p1_mdatbase(a6),a4
	bsr	tf_getnewptn
	clr.b	p1_overagain(a6)
	clr.w	p1_cntdown(a6)
	st 	p1_songrept(a6)
	move.b	p1_subsong+1(a6),p1_subsong2(a6)
	clr.b	p1_subsong(a6)
	clr.w	p1_chanstart(a6)
	lea	tf_cuedata(pc),a4
	clr.w	0(a4)
	clr.b	$15(a4)
	move.b	#1,p1_playflag(a6)
	movem.l	(sp)+,d1-d7/a0-a6
	rts

; start a new subsong saving return address

; oh my god!  can it be init code?!?!?  (d0=mdat d1=smpl)

tfmx_initmodl
	movem.l	a2-a6,-(sp)
	lea	tfmx_parms(pc),a6
	move.l	#$40400000,p1_nmastervol(a6)
	clr.b	p1_kmastervol(a6)
	move.l	d0,p1_mdatbase(a6)
	move.l	d1,p1_smplbase(a6)
	move.l	d1,a4
	clr.l	(a4)
	move.l	d0,a4
	move.l	$1D0(a4),d1
	add.l	d0,d1
	move.l	d1,p1_plstbase(a6)
	move.l	$1D4(a4),d1
	add.l	d0,d1
	move.l	d1,p1_patsbase(a6)
	move.l	$1D8(a4),d1
	add.l	d0,d1
	move.l	d1,p1_instbase(a6)
	lea	tfmx_virqhdl(pc),a4
	lea	tfmx_parms2(pc),a5
	move.w	#5,p2_songrst(a5)
	lea	tf_songcont(pc),a6
	move.w	#$1F,d0
.lp
	move.w	#5,$40(a6)
	clr.w	$80(a6)
	clr.w	(a6)+
	dbra	d0,.lp

	lea	tfmx_parms(pc),a6
	lea	tfmx_vrecs(pc),a4
	lea	v1_parms(pc),a5
	move.l	a5,(a4)+
	lea	v2_parms(pc),a5
	move.l	a5,(a4)+
	lea	v3_parms(pc),a5
	move.l	a5,(a4)+
	lea	v4_parms(pc),a5
	move.l	a5,(a4)+

	tst.b	voices
	bne.s	.no8

	lea	v1_parms(pc),a5
	move.l	a5,(a4)+
	lea	v2_parms(pc),a5
	move.l	a5,(a4)+
	lea	v3_parms(pc),a5
	move.l	a5,(a4)+
	lea	v4_parms(pc),a5
	move.l	a5,(a4)+
	bra.s	.got4

.no8
	lea	v5_parms(pc),a5
	move.l	a5,(a4)+
	lea	v6_parms(pc),a5
	move.l	a5,(a4)+
	lea	v7_parms(pc),a5
	move.l	a5,(a4)+
	lea	v8_parms(pc),a5
	move.l	a5,(a4)+

.got4
	moveq	#7,d0
.lp2
	move.l	-$20(a4),(a4)+
	dbra	d0,.lp2

	movem.l	(sp)+,a2-a6
	rts

tfmx_setupframerate
	movem.l	a5/a6,-(sp)
	lea	tfmx_parms(pc),a6
	clr.b	p1_nonflag(a6)
	clr.w	p1_ciatempo(a6)
	move.l	p1_mdatbase(a6),a5
	btst	#1,11(a5)
	bne.s	.leave
; NTSC (/14318)
	move.b	#1,p1_nonflag(a6)
	move.w	#$37EE,-(a7)
	bsr	tf_settempo
	addq.l	#2,a7
	move.w	#$37EE,p1_ciatempo(a6)
.leave
	movem.l	(sp)+,a5/a6
	rts

; the magical, Mystical tempo rout

tf_settempo
	movem.l	d0/d1/a0,-(a7)
	moveq	#0,d0
	move.w	16(a7),d0
	cmp.w	#700,d0			ridiculous tempo filter
	blo	.ex
	move.w	d0,.oldtempo
	move.l	#$1B51F8,d1
	divu.w	d0,d1
	move.w	d1,ciatempo
	move.w	d1,RealTempo
	st	ciatempochg

;	lea	.brax(PC),a0
;.lp1
;	tst.w	(a0)
;	beq	.sk2
;	addq.w	#2,a0
;	cmp.w	(a0)+,d0
;	bhs.s	.lp1
;.sk2
;	lsl.l	#8,d0
;	divu	-(a0),d0
;	move.b	-1(a0),do_music+9
;	move.w	(a0),d1
;	asr.w	#1,d1
;	swap.w	d0
;	cmp.w	d0,d1
;	swap.w	d0
;	blt.s	.sk1
;	addq.w	#1,d0
;.sk1
;	cmp.w	#256,d0
;	blt.s	.blah
;	move.w	#256,d0
;.blah
;	cmp.w	#80,d0
;	bgt.s	.blah2
;	move.w	#80,d0
;.blah2
;	move.w	sr,-(a7)
;	move.w	#$2700,sr
;	move.b	#$40,(mfp_ierb).w
;	move.b	#$40,(mfp_imrb).w
;	move.b	#0,(mfp_tcdcr).w
;.lp
;	move.b	d0,(mfp_tddr).w
;	cmp.b	(mfp_tddr).w,d0
;	bne.s	.lp
;	and.b	#$40,(mfp_iprb).w
;	and.b	#$40,(mfp_isrb).w
;	move.b	#$50,(mfp_ierb).w
;	move.b	-2(a0),d0
;.lpp
;	move.b	d0,(mfp_tcdcr).w
;	cmp.b	(mfp_tcdcr).w,d0
;	bne.s	.lp
;	move.b	#$50,(mfp_imrb).w
;	move.w	(a7)+,sr
.ex
	movem.l	(a7)+,d0/d1/a0
	rts
;.brax
;	dc.w	$0500,4773
;	dc.w	$0600,7458
;	dc.w	$0700,14914
;	dc.w	$0503,19091
;	dc.w	$0603,29829
;	dc.w	$0703,59659
;	dc.l	0

.oldtempo
	dc.w	0
.tf_settempo2
	move.w	.oldtempo,-(a7)
	beq.s	.bibi
	bsr	tf_settempo
.bibi
	addq.l	#2,a7
	rts
tf_settempo2 = .tf_settempo2

tfmx_irqhdl
	move.l	a6,-(sp)
	lea	tfmx_parms(pc),a6
	bsr	tfmx_player
	move.l	(sp)+,a6
	rts

tfmx_installplyr
	move.l	a6,-(sp)
	lea	tfmx_parms(pc),a6
	bsr	tfmx_initplyr
	lea	tfmx_parms(pc),a6
	move.l	(sp)+,a6
	rts

tfmx_parms
	dc.l	0,0,0,0
	dc.l	0,0,0,$7FFF
	dc.l	0,0,$40400000,$FFFF
	dc.l	0,0,0,0
tfmx_vrecs
	dcb.l	16,0
v1_parms
	dc.l	0,0,0,0
	dc.l	0,$82010001,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$80800080,$FFFFFF04,ch1s,0
	dc.l	$FF00
v2_parms
	dc.l	0,0,0,0
	dc.l	0,$82020002,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$81000100,$FFFFFF04,ch2s,0
	dc.l	$FF00
v3_parms
	dc.l	0,0,0,0
	dc.l	0,$82040004,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$82000200,$FFFFFF04,ch3s,0
	dc.l	$FF00
v4_parms
	dc.l	0,0,0,0
	dc.l	0,$82080008,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$84000400,$FFFFFF04,ch4s,0
	dc.l	$FF00
v5_parms
	dc.l	0,0,0,0
	dc.l	0,$82100010,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$88000800,$FFFFFF04,ch5s,0
	dc.l	$FF00
v6_parms
	dc.l	0,0,0,0
	dc.l	0,$82200020,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$90001000,$FFFFFF04,ch6s,0
	dc.l	$FF00
v7_parms
	dc.l	0,0,0,0
	dc.l	0,$82400040,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$A0002000,$FFFFFF04,ch7s,0
	dc.l	$FF00
v8_parms
	dc.l	0,0,0,0
	dc.l	0,$82800080,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$C0004000,$FFFFFF04,ch8s,0
	dc.l	$FF00
tfmx_parms2
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0
tf_songcont
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
tf_cuedata
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0

tfmx_dummypat
	dc.l	$F4000000
	dc.l	$F0000000

; 4 octave range.... impressive!
tfmx_notevals
	dc.w	$6AE,$64E,$5F4,$59E,$54D,$501,$4B9,$475,$435,$3F9,$3C0,$38C
	dc.w	$358,$32A,$2FC,$2D0,$2A8,$282,$25E,$23B,$21B,$1FD,$1E0,$1C6
	dc.w	$1AC,$194,$17D,$168,$154,$140,$12F,$11E,$10E,$0FE,$0F0,$0E3
	dc.w	$0D6,$0CA,$0BF,$0B4,$0AA,$0A0,$097,$08F,$087,$07F,$078,$071
	dc.w	$0D6,$0CA,$0BF,$0B4,$0AA,$0A0,$097,$08F,$087,$07F,$078,$071
	dc.w	$0D6,$0CA,$0BF,$0B4


freqs		ds.l 2048
		even

vols		ds.l 64
		incbin pt_volta.dat
				; 65 ,256 byte lookups.
		even


;mt_data	incbin t2musicm.son
;mt_smps	incbin t2musicm.smp

;mt_data	incbin clcmusm.son
;mt_smps	incbin clcmusm.smp

;mt_data		incbin q&smusg.son
;mt_smps		incbin q&smusg.smp

mt_data		incbin d:\tfmxmods\mdat.ath
mt_smps		incbin d:\tfmxmods\smpl.ath

;mt_data	incbin t2music1.son
;mt_smps	incbin t2speech
;		incbin t2music1.smp
		even

		DS.L 512
my_stack	DS.L 4
