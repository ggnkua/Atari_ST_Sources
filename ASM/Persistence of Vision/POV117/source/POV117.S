* POV 117
*

speed		EQU 40   			; timer d (pre-div 4)


***************
*	      *
* P.O.V. menu *
*	      *
***************

	OPT	o+,ow+,ow2-,ow3-,ow4-


	include	"SYSTEMEQ.S"



		SECTION	TEXT

*************
*	    *
* Main code *
*	    *
*************

start
	lea	clock,a0
.clear
	clr.w	(a0)+
	cmp.l	#finish,a0
	blt.s	.clear

	bsr	super_mode
	moveq	#$12,d0
	bsr	Writeikbd
	bsr	low_res
	movem.l	$ffff8240,d0-d7
	movem.l	d0-d7,old_pal
	bsr	black_palette
	bsr	set_screen
	bsr	show_pic

		BSR Init_Voltab			; initialise volume table.

		LEA mt_data,A0
		BSR mt_init			; initialise mod data.

		BSR init_ints			; and go!

	bsr	my_vsync
	bsr	flip_screens

.loop
	bsr	my_vsync

	bsr	flip_screens
	bsr	scroller

;	move.w	#$022,Palette0

	move.w	key,d0

;	cmp.w	#1,d0	;esc
;	beq	exit

	bsr	hertz_change

	cmp.w	#$c53,d0
	beq	reset
	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	.loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run
	move.l	d1,st

menu_done
		BSR restore_ints		; restore gem..
	move.l	st,d1
	lsr.w	#8,d1
	lsl.w	#2,d1
	lea	filenames,a0
	move.l	0(a0,d1.w),a0
	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

	bsr	black_palette
	bsr	low_res
	moveq	#$08,d0
	bsr	Writeikbd
	move.b	#2,SyncMode
	tst.w	hz_tog
	beq.s	.not_60hz
	clr.b	SyncMode
.not_60hz
	bsr	user_mode
.flush
	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	beq.s	.exit
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bra.s	.flush
.exit
	clr.w	-(sp)
	trap	#1


exit	BSR restore_ints		; restore gem..
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	moveq	#$08,d0
	bsr	Writeikbd
	bsr	user_mode
.flush	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	beq.s	.exit
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bra.s	.flush
.exit
	clr.w	-(sp)
	trap	#1

************
*	   *
* Routines *
*	   *
************

hertz_change
	tst.w	hz_delay
	beq.s	.go_ahead
	rts
.go_ahead
	cmp.w	#11,d0		;0 keyboard
	beq.s	change_hz

	cmp.w	#$70,d0		;0 keypad
	beq.s	change_hz
	rts

change_hz
	eor.l	#$0020002,aaa
	eor.w	#$002,hz_col
	not.w	hz_tog
	move.w	#8,hz_delay
	rts


my_vsync
	move.w	#-1,vsync_flag
.wait	tst.w	vsync_flag
	bne.s	.wait
	rts


border_isr
	or.w	#$700,sr
	clr.b	TBCR
	movem.l	d0/a0,-(sp)
.wait
	cmp.b	#$60,VidAddrLo
	blo.s	.wait
	dbt	d0,*
	dbt	d0,*
	lea	.nops(pc),a0
	moveq	#0,d0
	move.b	VidAddrLo,d0
	sub.b	#$60,d0
	add.w	d0,a0
	jmp	(a0)
.nops
	REPT	88
	nop
	ENDR
	dbt	d0,*
	dbt	d0,*
	clr.b	SyncMode
	nop
	movem.l	(sp)+,d0/a0
	move.b	#2,SyncMode
	move.l	a0,-(sp)
	lea	Palette0,a0
	move.w	hz_col,(a0)+

	move.l	aaa,(a0)+
	move.l	aaa,(a0)+
	move.l	aaa,(a0)+
	move.w	aaa,(a0)+


	move.l	cols,(a0)+
	move.l	cols+4,(a0)+
	move.l	cols+8,(a0)+
	move.l	cols+12,(a0)
	move.l	(sp)+,a0
	rte

cols	dc.l	$0300041
	dc.l	$0510062
	dc.l	$0730074
	dc.l	$0750276

aaa	dc.l	$0000000
flip_screens
	move.l	first_scr,d0
	add.l	scr_add,d0
	move.l	d0,scr_now
	lsr.l	#8,d0
	lea	VidBaseHi,a0
	movep.w	d0,(a0)
	eor.l	#(160*248),scr_add
	rts


set_screen
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,first_scr
	move.l	d0,scr_now
	clr.l	scr_add
	rts


scroller
	lea	font,a5
	move.l	scr_now,a2
	lea	(160*201)+6(a2),a2
	move.l	text_ptr,a4
	move.l	a4,a3
	move.w	char_off,d6
	moveq	#0,d2
	moveq	#40-1,d1
.loop	move.w	(a3),d0
	bpl.s	.cont
	lea	text_start,a3
	move.w	(a3),d0
.cont	move.l	a5,a0
	add.w	d6,d0
	add.w	d0,a0
.column
OFF	set	0
	REPT	16
	move.b	(a0)+,OFF(a2)
OFF	set	OFF+160
	ENDR
	dbf	d1,.not_end
	add.w	#16,char_off
	and.w	#(16*3),char_off
	bne.s	.end
	addq.w	#2,a4
	tst.w	(a4)
	bpl.s	.end
	lea	text_start,a4
.end
	move.l	a4,text_ptr
	rts
.not_end
	addq.w	#1,a2
	tst.w	d2
	beq.s	.next
	addq.w	#6,a2
.next
	not.w	d2
	add.w	#16,d6
	and.w	#(16*3),d6
	bne.s	.column
	addq.w	#2,a3
	bra	.loop


show_pic
	lea	picture+34,a0
	move.l	first_scr,a1
	move.l	a1,a2
	add.l	#(160*248),a2
	move.w	#(160*200/4)-1,d0
.loop1
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop1
	lea	pattern,a0
	move.w	#(160*42)/4-1,d0
.loop2
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop2
	rts


reset	move.l	$4.w,a0
	jmp	(a0)


vsync	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts


low_res	clr.w	-(sp)
	move.l	$44e.w,-(sp)
	move.l	$44e.w,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts


black_palette
	lea	$ffff8240.w,a0
	REPT	8
	clr.l	(a0)+
	ENDR
	rts


super_mode
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk
	move.l	usp,a0
	move.l	a0,usp_bak
	rts

user_mode
	move.l	usp_bak,a0
	move.l	a0,usp
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	rts


new_kbd	move.l	d0,-(sp)
	move.b	KBD_DATA,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,ISRB
	move.l	(sp)+,d0
	rte


******************************
*			     *
* Griff's Module Replay Code *
*			     *
******************************

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
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
	move.l	TimerB_ISR,(a0)+
	move.b	#$01,IERA
		MOVE.B #$50,$fffffa09.W
	move.b	#$01,IMRA
		MOVE.B #$50,$fffffa15.W
		BCLR.B #3,$fffffa17.W		; software end of int.
	clr.b	TBCR
		MOVE.B #0,$FFFFFA1D.W
		MOVE.B #speed,$FFFFFA25.W
		MOVE.B #1,$FFFFFA1D.W
		LEA my_vbl(PC),A0
		MOVE.L A0,$70.W			; set our vbl
	lea	new_kbd(PC),A0
		MOVE.L A0,$118.W		; and our keyrout.
		BSR Select_PlayRout
		LEA sndbuff1(PC),A1
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume sending
		BSR Writeikbd
		MOVEQ #$12,D0			; kill mouse
		BSR Writeikbd
		BSR flush
		RTS

; Restore mfp vectors and ints.

restore_ints	MOVE.L oldusp(PC),A0
		MOVE.L A0,USP
		MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
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
	move.l	(a0)+,TimerB_ISR
		BSET.B #3,$FFFFFA17.W
	clr.b	TBCR
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume
		BSR.s Writeikbd		
		MOVEQ #$8,D0			; restore mouse.
		BSR.s Writeikbd
		BSR.s flush
		RTS


old_stuff:	DS.L 20+1
oldres		DS.W 1
oldsp		DS.L 1
oldusp		DS.L 1

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


; The vbl - calls sequencer and vbl filler.

my_vbl	clr.w	vsync_flag
	clr.b	TBCR
	move.b	#199,TBDR
	move.b	#8,TBCR
	move.l	#border_isr,TimerB_ISR
	movem.l	d0-d6/a0/a2-a6,-(sp)

	lea	Palette0,a2		;$ffff8240
	move.l	pal_position,a0

	subq.w	#1,pal_counter
	beq.s	set_new

	REPT	8
	move.l	(a0)+,(a2)+
	ENDR

onward		BSR.s	Vbl_play
		BSR	mt_music	
		MOVEM.L (SP)+,D0-D6/A0/A2-A6
	tst.w	hz_delay
	bne.s	.dec
		RTE
.dec	subq.w	#1,hz_delay
	rte

set_new	cmp.l	#pal_end,a0
	bne.s	.no_reset

	lea	pals,a0
	REPT	8
	move.l	(a0)+,(a2)+
	ENDR
	move.w	(a0)+,d0
	move.w	#100,pal_counter
	move.l	a0,pal_position
	bra.s	onward

.no_reset
	REPT	8
	move.l	(a0)+,(a2)+
	ENDR
	move.w	(a0)+,pal_counter
	move.l	a0,pal_position
	bra.s	onward


; Vbl player - this is a kind of 'Paula' Emulator(!)

Vbl_play	MOVEA.L	buff_ptr(PC),A4
		MOVE.L A1,D0			; current pos in buffer
		CMP.L #endbuff1,d0
		BNE.S .norm
		MOVE.L #sndbuff1,d0		; wooky case(at end of buf)
.norm		MOVE.L D0,buff_ptr
		SUB.L A4,D0
		BEQ skipit
		BHI.S higher
		ADDI.W #$800,D0			; abs
higher		LSR.W #1,D0
		MOVE.L #endbuff1,D1
		SUB.L A4,D1
		LSR.W #1,D1
		CLR.W fillx1			; assume no buf overlap
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
		BSR.s add1			; move voice 1
		LEA.L ch2s(PC),A5
		MOVE.W aadd(pc),D0
		BSR.s add1			; add voice 2

		LEA $802(A4),A4
.voices_3_4	MOVE.L #sndbuff2,buffbase	
		LEA.L ch3s(PC),A5	
		MOVE.W amove(pc),D0
		BSR.s add1			; move voice 3	
		LEA.L ch4s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR.s add1			; add voice 4					; add voice 4
		RTS

; Routine to add/move one voice to buffer. The real Paula emulation part!!

add1		PEA (A4)			; save buff pos
		LEA moda(PC),A2
		MOVE.W D0,(A2)
		MOVE.W D0,modb-moda(A2)		; self modifying
		MOVE.W D0,modc-moda(A2)		; add/move code(see below)
		MOVE.W D0,modd-moda(A2)	
		MOVE.W D0,mode-moda(A2)	
		MOVE.L (A5),A2			; current sample end address
		MOVEM.W 6(A5),D1/D2		; period/volume
		ADD.W D1,D1
		ADD.W D1,D1			; *4 for lookup
		MOVEM.W 0(A3,D1),D1/D4		; get int.w/frac.w
		MOVE.L voltab_ptr(PC),A6	; base of volume table
		LSL.W #8,D2
		ADD.W D2,A6			; ptr to volume table
		MOVEQ #0,d5
		MOVE.W 4(A5),d5			; sample length
		CMP.L #nulsamp+2,A2
		BNE.S .vcon
		MOVEQ.L	#0,D4			; channel is off.
		MOVEQ.L	#0,D1			; clear all if off.
		MOVE.L voltab_ptr(PC),A6	; zero vol(safety!!)
		CLR.W 16(A5)			; clear frac part
.vcon		NEG.L d5
		MOVE.L A6,D6			; vol ptr
		MOVEQ.L	#0,D2			; clr top byte for sample
; Setup Loop stuff
		MOVE.L 10(a5),A0		; loop addr
		MOVEQ #0,D3
		MOVE.W 14(a5),D3		; loop length
		NEG.L D3
		MOVEM.W D1/D4,loopfreq
		CMP.L #-2,D3
		BNE.S isloop
noloop		MOVE.L D2,loopfreq		; no loop-no frequency
		LEA nulsamp+2(PC),A0	 	; no loop-point to nul
isloop		MOVE.L D3,looplength
		MOVE.W 16(A5),D3		; clear fraction part
		MOVE.W fillx1(PC),D0
		BSR.S addit			; 
		MOVE.W fillx2(PC),D0
		TST.W fillx1
		BEQ.S nores
		MOVE.L buffbase(PC),A4		; buffer base
nores		BSR.S addit
		NEG.L d5			; +ve offset(as original!)
		MOVE.L A2,(A5)			; store voice address
		MOVE.W d5,4(A5)			; store offset for next time
		MOVE.W D3,16(A5)		; clear fraction part
skipit		MOVE.L (SP)+,A4
		RTS
	
; Add D0 sample bytes to buffer

addit		MOVE.W D0,donemain+2		; lets go!!
		LSR #2,D0			; /4 for speed
		SUBQ #1,D0			; -1 (dbf)
		BMI.S donemain			; none to do?
makelp		MOVE.B (A2,d5.L),D6		; fetch sample byte
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
		BCS.S lpvoice2
CONT2		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modc		ADD.W D2,(A4)+
		ADD.W D4,D3			;
		ADDX.W D1,d5
		BCS.s lpvoice3
CONT3		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modd		ADD.W D2,(A4)+			;
		ADD.W D4,D3
		ADDX.W D1,d5
CONT4		DBCS  D0,makelp
		BCS.s lpvoice4
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
		BCS.s lpvoicelast
yeah		RTS

buffbase	DS.L 1
loopfreq:	DS.W 2
looplength:	DS.L 1
voltab_ptr	DS.L 1

lpvoice		MACRO
		MOVE.L A0,A2 
		EXT.L D5
		ADD.L looplength(PC),D5		; fetch loop constants
		MOVEM.W loopfreq(PC),D1/D4	; (channel independent)
		MOVEQ #0,D2
		MOVE D2,CCR	
 		BRA \1
		ENDM

lpvoice1	lpvoice CONT1			;
lpvoice2	lpvoice CONT2			; loop routs
lpvoice3	lpvoice CONT3			; (since code is repeated)
lpvoice4	lpvoice CONT4			;
lpvoicelast	lpvoice CONT5			;

aadd		ADD.W D2,(A4)+
amove		MOVE.W D2,(A4)+

nulsamp		ds.l 2				; nul sample.
buff_ptr:	dc.l 0
sndbuff1:	ds.w $400			; buffer for voices 1+2
endbuff1:	dc.w -1
sndbuff2	ds.w $400			; buffer for voices 3+4
endbuff2	dc.w -1

fillx1:		DC.W 0
fillx2:		DC.W 0

; Select The Playback Routine D0.W = 0 to 6

Select_PlayRout:MOVE.W SR,-(SP)
		MOVE #$2700,SR
	move.l	#YM2149_Player,TimerD_ISR
	bsr.s	YM2149_Setup
		MOVE.W (SP)+,SR
		RTS

; YM2149 Setup rout - turns off ste dma(if machine is st) and clears YM.

YM2149_Setup:
		BSR Initsoundchip		; init soundchip
		RTS

; Setup rout for all other output routs - kills both dma and YM sound.

Internal_Off:
		BSR Killsoundchip
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

; ST specific initialisation routines - sets up shadow amiga registers.

STspecific:	LEA  nulsamp+2(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		BSR.s initvoice
		LEA ch2s(pc),A0
		BSR.s initvoice			;init shadow regs
		LEA ch3s(pc),A0
		BSR.s initvoice
		LEA ch4s(pc),A0
		BSR.s initvoice
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
		MOVE.L A2,10(A0)	; and loop point to nul sample
		MOVE.W #2,14(A0)
		MOVE.W D0,16(A0)	; clear fraction part.
		RTS

; Initialise Soundchip

Initsoundchip:	LEA $FFFF8800.W,A0
		MOVE.B #7,(A0)			; turn on sound
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

;********************************************
;* ----- Protracker V1.1A Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1990  *
;* Bekkeliveien 10, N-2010 STRØMMEN, Norway *
;********************************************

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

; Initialise module

mt_init	MOVE.L	A0,mt_SongDataPtr
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
	LEA	mt_speed(PC),A1
	MOVE.B	#6,(A1)
	MOVEQ	#0,D0
	MOVE.B	D0,mt_SongPos-mt_speed(A1)
	MOVE.B	D0,mt_counter-mt_speed(A1)
	MOVE.W	D0,mt_PattPos-mt_speed(A1)
	BRA STspecific

; Vbl Sequencer

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
	ADD.W	mt_PattPos(PC),D1

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
	MOVE.W	n_period(A6),6(A5)
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
	MOVE.W	D0,8(A5)	; Set volume
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
	MOVE.L	n_start(A6),(A5)		; Set start
	MOVEQ.l	 #0,D0
	MOVE.W	n_length(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,(A5)				; point to end of sample
	MOVE.W	D0,4(A5)			; Set length
	MOVE.W	n_period(A6),6(A5)		; Set period
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.L	D0,-(SP)
	MOVEQ.L	#0,D0
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVEQ.L	#0,D0
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVEQ.L	#0,D0
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVEQ.L	#0,D0
	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVE.L	(SP)+,D0

mt_dskip
	ADD.W	#16,mt_PattPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16,mt_PattPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PattPos
mt_nnpysk
	CMP.W	#1024,mt_PattPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PattPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
; Restart position fixed by Boris of P.O.V. on 2/2/92
	move.b	951(a0),mt_SongPos
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
	MOVE.L D3,-(SP)
	MOVEQ	#36,D3
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0)+,D1
	BHS.S	.arp4
	DBF	D3,mt_arploop
	MOVE.L (SP)+,D3
	RTS
.arp4	MOVE.W	D2,6(A5)
	MOVE.L (SP)+,D3
	RTS

mt_Arpeggio4
	MOVE.W	D2,6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.s	mt_Return2
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
	MOVE.W	D2,6(A5) 			; Set period
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
	BEQ.s	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ.s	mt_SetFineTune
	CMP.B	#6,D0
	BEQ.s	mt_JumpLoop
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
	MOVE.W	mt_PattPos(PC),D0
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
	MOVE.L D0,-(SP)
	MOVEQ #0,D0
	MOVE.L	n_start(A6),(A5)		; Set sampledata pointer
	MOVE.W	n_length(A6),D0
	ADD D0,D0
	ADD.L D0,(A5)
	MOVE.W D0,4(A5)				; Set length
	MOVEQ #0,D0
	MOVE.L	n_loopstart(A6),10(A5)		; loop sample ptr
	MOVE.L	n_replen(A6),D0
	ADD D0,D0
	ADD.L D0,10(A5)
	MOVE.W D0,14(A5)
	MOVE.L (SP)+,D0
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


********************
*		   *
* Initialised data *
*		   *
********************

	SECTION	DATA

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

mt_SongDataPtr	dc.l 0

mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0
		dc.b 0

mt_PattPos	dc.w 0

mt_mulu		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

freqs		ds.l 2
		incbin boris.bin		; frequency table. int.w/frac.w
		even

vols		ds.l 64
		incbin pt_volta.dat		; 65 ,256 byte lookups.
		even

mt_data		incbin	"servitor.MOD"

picture		incbin	"goths2.PI1"
pattern		incbin	"PATTERN.DAT"

font		incbin	"BORIS.FNT"

char_off	dc.w	0
text_ptr	dc.l	text_start
text_start	incbin	"SCROLLER.TXT"

demo_keys
	dc.b	0, $02
	dc.b	1, $03
	dc.b	2, $04
	dc.b	3, $05
	dc.b	4, $06
;	dc.b	5, $07
;	dc.b	6, $08
;	dc.b	7, $09

	dc.b	0, $6d
	dc.b	1, $6e
	dc.b	2, $6f
	dc.b	3, $6a
	dc.b	4, $6b
;	dc.b	5, $6c
;	dc.b	6, $67
;	dc.b	7, $68

	dc.b	-1, -1

filenames	dc.l	exec1,exec2,exec3,exec4,exec5	;,exec6,exec7,exec8
exec1	dc.b	"SONIC.EI",0
	even
exec2	dc.b	"CEBIT_92",0
	even
exec3	dc.b	"HMD",0
	even
exec4	dc.b	"JMP_7",0
	even
exec5	dc.b	"COPIER.POV",0
	even
;exec6	dc.b	"CAR_TOON",0
;	even
;exec7	dc.b	"FF",0
;	even
;exec8	dc.b	"COPIER.POV",0
;	even

pal_counter	dc.w	3000
pal_position	dc.l	pals
pals
 dc.w	$000,$000,$110,$210,$220,$320,$430,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$000,$110,$210,$220,$320,$430,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$110,$220,$320,$330,$430,$440,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$210,$320,$430,$440,$440,$450,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$310,$420,$530,$540,$450,$460,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$410,$520,$530,$540,$450,$460,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$510,$620,$530,$540,$450,$460,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$610,$620,$530,$540,$450,$460,$001,$002,$112,$210,$432,$543,$654,$327,$765,400
 dc.w	$000,$710,$620,$530,$540,$450,$460,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

 dc.w	$000,$610,$520,$430,$440,$350,$360,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$510,$420,$330,$340,$250,$260,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$410,$320,$230,$240,$150,$160,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$310,$220,$130,$140,$050,$060,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$210,$120,$030,$040,$050,$060,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$110,$020,$030,$040,$050,$060,$001,$002,$112,$210,$432,$543,$654,$327,$765,600
 dc.w	$000,$010,$020,$030,$040,$050,$060,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

 dc.w	$000,$001,$011,$021,$031,$041,$051,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$002,$002,$012,$022,$032,$042,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$002,$003,$003,$013,$023,$033,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$002,$003,$004,$004,$014,$024,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$002,$003,$004,$005,$005,$015,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$002,$003,$004,$005,$006,$006,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$002,$003,$004,$005,$006,$107,$001,$002,$112,$210,$432,$543,$654,$327,$765,600
 dc.w	$000,$002,$003,$004,$005,$006,$207,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

 dc.w	$000,$101,$102,$103,$104,$105,$306,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$101,$202,$203,$204,$205,$406,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$101,$202,$303,$304,$305,$506,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$101,$202,$303,$404,$405,$606,$001,$002,$112,$210,$432,$543,$654,$327,$765,600
 dc.w	$000,$101,$202,$303,$404,$505,$606,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

 dc.w	$000,$000,$101,$202,$303,$404,$505,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$000,$000,$101,$202,$303,$404,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$000,$000,$000,$101,$202,$303,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$000,$000,$000,$000,$101,$202,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$000,$000,$000,$000,$000,$101,$001,$002,$112,$210,$432,$543,$654,$327,$765,10
 dc.w	$000,$000,$000,$000,$000,$000,$000,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

 dc.w	$000,$111,$111,$111,$111,$111,$111,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$222,$222,$222,$222,$222,$222,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$333,$333,$333,$333,$333,$333,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$444,$444,$444,$444,$444,$444,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$555,$555,$555,$555,$555,$555,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$666,$666,$666,$666,$666,$666,$001,$002,$112,$210,$432,$543,$654,$327,$765,100
 dc.w	$000,$777,$777,$777,$777,$777,$777,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

 dc.w	$000,$666,$666,$666,$666,$666,$666,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$555,$555,$555,$555,$555,$556,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$444,$444,$444,$444,$445,$546,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$333,$333,$333,$334,$435,$536,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$222,$222,$223,$324,$425,$526,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$111,$112,$213,$314,$415,$516,$001,$002,$112,$210,$432,$543,$654,$327,$765,400
 dc.w	$000,$001,$102,$203,$304,$405,$506,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

 dc.w	$000,$110,$211,$312,$313,$414,$415,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$110,$220,$321,$322,$423,$424,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$110,$220,$320,$321,$432,$433,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$110,$220,$320,$330,$431,$442,$001,$002,$112,$210,$432,$543,$654,$327,$765,4
 dc.w	$000,$110,$220,$320,$330,$430,$441,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

 dc.w	$000,$110,$220,$320,$330,$430,$440,$001,$002,$112,$210,$432,$543,$654,$327,$765,2000

pal_end
 dc.w	$000,$000,$110,$210,$220,$320,$430,$001,$002,$112,$210,$432,$543,$654,$327,$765,4

**********************
*		     *
* Uninitialised data *
*		     *
**********************

	SECTION	BSS

clock		ds.w	1

old_pal		ds.w	16

key		ds.w	1

vsync_flag	ds.w	1

hz_delay	ds.w	1

hz_tog		ds.w	1

hz_col		ds.w	1

save_stk	ds.l	1
usp_bak		ds.l	1

first_scr	ds.l	1
scr_now		ds.l	1
scr_add		ds.l	1
st		ds.l	1

		ds.b	256
screens		ds.b	(160*248*2)

finish	even
