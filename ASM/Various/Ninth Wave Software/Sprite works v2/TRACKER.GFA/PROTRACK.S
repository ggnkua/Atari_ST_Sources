 
; Protracker code by Griff of Electronic Images(I.C.) - alias Martin Griffiths!	;
	OPT O+,OW-

; ~c:play_module%(speed,l:module)

	bra	pro_on
	bra	pro_off

pro_on	movem.l	d1-a6,-(a7)
	move	60(a7),d0
	lea	freq_speed(pc),a0
	move	d0,(a0)
	move.l	62(a7),d0
	lea	module(pc),a0
	move.l	d0,(a0)
	bsr	super
	
	bsr	Set_Speed
	bsr	Ste_Test
	bsr	Init_Voltab		; initialise volume table.

	move.l	module(pc),A0
	bsr	mt_init			; initialise mod data.
	bsr	init_ints		; and go!

	bsr	user
	lea	ch1s(pc),a0
	move.l	a0,d0
	movem.l	(a7)+,d1-a6
	rts

pro_off	movem.l	d1-a6,-(a7)
	bsr	super
.exit	bsr	restore_ints		; restore gem..
	bsr	user
	movem.l	(a7)+,d1-a6
	rts

.loop	cmp.b	#$39,$fffc02		; space exits.
	bne.s	.loop

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	old_sp(pc),a4
	move.l	d0,(a4)
	rts

user	lea	old_sp(pc),a4
	move.l	(a4),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

old_sp	ds.l	1

module	ds.l	1
	

Set_Speed
	lea	freq_speed(pc),a0
	moveq	#0,d2
	move	(a0),d2
	move.l	#6144000,d1
	bsr	ldiv
	move.l	d1,d2
	divu	#10,d1
	move.b	d1,(a0)	
	move.l	#1006633,d1
	bsr	ldiv
	move.l	d1,d2
	move.l	#586473,d1
	bsr	ldiv
	swap	d1
	clr	d1
	move.l	d1,d6
	
	lea	freqs+8(pc),a1
	moveq	#1,d7
.divlp	move.l	d6,d1
	move.l	d7,d2
	bsr	ldiv
	move.l	d1,(a1)+
	addq	#1,d7
	cmp	#857,d7
	blt.s	.divlp
	lea	freqs+8(pc),a1
	clr.l	(a1)
	rts

********************************************
** Long division - 32 bit by 32 bit D1/D2 **
********************************************

ldiv	tst.l	d2		; check denominator < 0
	bpl.s	div00		; no
	neg.l	d2		; make denominator positive
	bsr.s	div00		; do division as if positive
	neg.l	d1		; now negate the answer
	rts
	
div00	tst.l	d1		; check numerator < 0
	bpl.s	divu		; both operands positive
	neg.l	d1		; make numerator positive
	bsr.s	divu		; perform division
	neg.l	d1		; correct sign of quotient
	neg.l	d2		; correct sign of remainder
	rts
	
divu	cmpi.l	#$ffff,d2	; test if D2H is zero
	bls.s	divx		; D2 < 16 bits, use subroutine
	cmp.l	d1,d2		; check if D2 <= D1
	beq.s	div01		; D1 = D2, simple case
	bls.s	div02		; difficult case
* Here D1 < D2, so result is zero
	move.l	d1,d2		; get remainder correct
	moveq	#0,d1		; zero result
	rts
* Here D1 = D2, so remainder is 1
div01	moveq	#0,d2		; zero remainder
	moveq	#1,d1		; result is 1
	rts
	
div02	movem.l	d3-d5,-(a7)	; save work registers
	move.l	d2,d3		; save denominator
	clr.w	d3		; clear D3L
	swap	d3		; D3 = D2 / $10000
	addq.l	#1,d3		; D3 = 1 + (D2/$10000)
* Scale factor in D3, Scale numerator and denominator
	move.l	d1,d4		; D4 = numerator
	move.l	d2,d5		; D5 = denominator
	move.l	d3,d2		; scalefactor into D2 for divx
	bsr.s	divx		; D1 = D1 / Scalefactor
	move.l	d5,d2		; replace denominator
	divu	d3,d2		; D2L = D2 / Scalefactor
* D2 should now fit into 16 bits
	divu	d2,d1		; divide scaled item
	andi.l	#$ffff,D1	; D1H = 0
div03	move.l	d5,d2		; restore original denominator
	move.l	d5,d3		; into D3 as well
	swap	d3		; D3L = D2H
	mulu	d1,d2		; D2 = D1*D2L
	mulu	d1,d3		; D3 = D1*D2H, D3H is zero
	swap	d3		; move into high digit
	add.l	d3,d2		; get product, no carry possible
	sub.l	d4,d2		; subtract original numerator
	bhi.s	div04		; overshot, remainder negative
	neg.l	d2		; change sign
	cmp.l	d2,d5		; compare with original denominator
	bhi.s	div05		; ok, remainder is in range
	addq.l	#1,d1		; increment quotient
	bra.s	div03		; try again
div04	subq.l	#1,d1		; decrement quotient
	bra.s	div03		; try again
* Got it !
div05	movem.l	(a7)+,d3-d5	; restore registers
	rts
	
divx	movem.w	d1/d3,-(a7)	; save D1L and D3L
	clr.w	d1		; clear D1L
	swap	d1		; D1 = D1H
	divu	d2,d1		; D1L = D1H/D2
	move.w	d1,d3		; save partial result
	move.w	(a7)+,d1	; retrieve D1L
* D1H holds D1H rem D2, D1L as on entry
	divu	d2,d1		; D1L = (D1L+(D1H rem D2))/D2
	swap	d1		; D1L now holds remainder
	moveq	#0,d2		; clear D2
	move.w	d1,d2		; remainder into D2
	move.w	d3,d1		; D1L = high order quotient
	swap	d1		; swap to get 32-bit quotient
	move.w	(a7)+,d3
	rts

init_ints
	lea	sndbufpos(pc),a1	; write unrelocatable code
	lea	ym1+2(pc),a0
	move.l	a1,(a0)
	lea	ym2+2(pc),a0
	move.l	a1,(a0)
	lea	ym3+2(pc),a0
	move.l	a1,(a0)
	lea	ym4+2(pc),a0
	move.l	a1,(a0)
	moveq	#$13,d0			; pause keyboard
	bsr	Writeikbd		; (stop from sending)
	move	#$2700,sr
	lea	old_stuff+32(pc),a0
	move.b	$FFFFFA07.W,(a0)+
	move.b	$FFFFFA09.W,(a0)+
	move.b	$FFFFFA13.W,(a0)+
	move.b	$FFFFFA15.W,(a0)+	; Save mfp registers 
	move.b	$FFFFFA1D.W,(a0)+
	move.b	$FFFFFA25.W,(a0)+
	move.l	$70.W,(a0)+
	move.l	$110.W,(a0)+		; save some vectors
	clr.b	$FFFFFA07.W
	move.b	#$10,$FFFFFA09.W
	clr.b	$FFFFFA13.W
	move.b	#$10,$FFFFFA15.W
	bclr.b	#3,$FFFFFA17.W		; software end of int.
	move.b	#0,$FFFFFA1D.W
	lea	freq_speed(pc),a0
	move.b	(a0),$FFFFFA25.W
	move.b	#1,$FFFFFA1D.W
	lea	my_vbl(pc),a0
	move.l	A0,$70.W		; set our vbl
	move	Which_replay(pc),d0
	bsr	Select_PlayRout
	lea	sndbuff1(pc),a1
	lea	sndbufpos(pc),a2
	move.l	a1,(a2)
	move	#$2300,sr
	moveq	#$11,d0			; resume sending
	bsr	Writeikbd
	moveq	#$12,d0			; kill mouse
	bsr	Writeikbd
	bsr	flush
	rts

; Restore mfp vectors and ints.

restore_ints	
	moveq	#$13,d0			; pause keyboard
	bsr	Writeikbd		; (stop from sending)
	move	#$2700,sr
	lea	old_stuff+32(pc),a0
	move.b	(a0)+,$FFFFFA07.W
	move.b	(a0)+,$FFFFFA09.W
	move.b	(a0)+,$FFFFFA13.W
	move.b	(a0)+,$FFFFFA15.W	; restore mfp
	move.b	(a0)+,$FFFFFA1D.W
	move.b	(a0)+,$FFFFFA25.W
	move.l	(a0)+,$70.W
	move.l	(a0)+,$110.W
	bset.b	#3,$FFFFFA17.W
	move	#$2300,sr
	moveq	#$11,d0			; resume
	bsr	Writeikbd		
	moveq	#$8,d0			; restore mouse.
	bsr	Writeikbd
	bsr	flush
	rts

old_stuff:	DS.L 20
oldres		DS.W 1
oldsp		DS.L 1
oldusp		DS.L 1
sndbufpos	ds.l 1

; Flush IKBD

flush	btst.b	#0,$FFFFFC00.W		; any waiting?
	beq.s	.flok			; exit if none waiting.
	move.b	$FFFFFC02.W,d0		; get next in queue
	bra.s	flush			; and continue
.flok	rts

; Write d0 to IKBD

Writeikbd
	btst.b	#1,$FFFFFC00.W
	beq.s	Writeikbd			; wait for ready
	move.b	d0,$FFFFFC02.W		; and send...
	rts

; The vbl - calls sequencer and vbl filler.

my_vbl	movem.l	d0-a6,-(a7)
	bsr.s	Vbl_play
	bsr	mt_music	
	movem.l	(a7)+,d0-a6
	rte

; Vbl player - this is a kind of 'Paula' Emulator(!)

Vbl_play
	move.l	buff_ptr(pc),a4
	move.l	sndbufpos(pc),d0	; current pos in buffer
	lea	endbuff1(pc),a1
	cmp.l	a1,d0
	bne.s	.norm
	lea	sndbuff1(pc),a1
	move.l	a1,d0			; wooky case(at end of buf)
.norm	lea	buff_ptr(pc),a1
	move.l	d0,(a1)
	sub.l	a4,d0
	beq	skipit
	bhi.s	higher
	add	#$800,d0		; abs
higher	lsr	#1,d0
	lea	endbuff1(pc),a1
	move.l	a1,d1
	sub.l	a4,d1
	lsr	#1,d1
	lea	fillx1(pc),a1
	clr	(a1)			; assume no buf overlap
	cmp	d1,d0			; check for overlap
	bcs.s	higher1
	move	d1,(a1)			; ok so there was overlap!!
higher1	sub	(a1),d0			; subtract any overlap
	move	d0,2(a1)		; and store main
; A4 points to place to fill
	lea	freqs(pc),a3		; int.w/frac.w freq tab

.voices_1_2
	lea	buffbase(pc),a5
	lea	sndbuff1(pc),a1
	move.l	a1,(a5)
	lea.l	ch1s(PC),A5
	move	amove(pc),d0
	bsr	add1			; move voice 1
	lea.l	ch2s(pc),a5
	move	aadd(pc),d0
	bsr	add1			; add voice 2

	lea	$802(a4),a4
.voices_3_4
	lea	buffbase(pc),a5
	lea	sndbuff2(pc),a1
	move.l	a1,(a5)
	lea.l	ch3s(pc),a5	
	move	amove(pc),d0
	bsr	add1			; move voice 3	
	lea.l	ch4s(pc),a5	
	move	aadd(pc),d0
	bsr	add1			; add voice 4					; add voice 4
	rts

; Routine to add/move one voice to buffer. The real Paula emulation part!!

add1	pea	(a4)			; save buff pos
	lea	moda(pc),a2
	move	d0,(a2)
	move	d0,modb-moda(a2)		; self modifying
	move	d0,modc-moda(a2)		; add/move code(see below)
	move	d0,modd-moda(a2)	
	move	d0,mode-moda(a2)	
	move.l	(a5),a2			; current sample end address
	movem	6(a5),d1/d2		; period/volume
	add	d1,d1
	add	d1,d1			; *4 for lookup
	movem	0(a3,d1),d1/d4		; get int.w/frac.w
	move.l	voltab_ptr(pc),a6	; base of volume table
	lsl	#8,d2
	add	d2,a6			; ptr to volume table
	moveq	#0,d5
	move	4(a5),d5			; sample length
	lea	nulsamp+2(pc),a1
	cmp.l	a1,a2
	bne.s	.vcon
	moveq	#0,D4			; channel is off.
	moveq	#0,D1			; clear all if off.
	move.l	voltab_ptr(pc),a6	; zero vol(safety!!)
	clr	16(a5)			; clear frac part
.vcon	neg.l	d5
	move.l	a6,d6			; vol ptr
	moveq	#0,d2			; clr top byte for sample
; Setup Loop stuff
	move.l	10(a5),a0		; loop addr
	moveq	#0,d3
	move	14(a5),d3		; loop length
	neg.l	d3
	lea	loopfreq(pc),a1
	movem	d1/d4,(a1)
	cmp.l	#-2,d3
	bne.s	isloop
;noloop	move.l	d2,(a1)			; no loop-no frequency
	lea	nulsamp+2(pc),a0 	; no loop-point to nul
isloop	move.l	d3,4(a1)
	move	16(a5),d3		; clear fraction part
	move	fillx1(pc),d0
	bsr.s	addit			; 
	move	fillx2(pc),d0
	lea	fillx1(pc),a1
	tst	(a1)
	beq.s	nores
	move.l	buffbase(pc),a4		; buffer base
nores	bsr.s	addit
	neg.l	d5			; +ve offset(as original!)
	move.l	a2,(a5)			; store voice address
	move	d5,4(a5)		; store offset for next time
	move	d3,16(a5)		; clear fraction part
skipit	move.l	(a7)+,a4
	rts
	
; Add D0 sample bytes to buffer

addit	lea	donemain+2(pc),a1
	move	d0,(a1)			; lets go!!
	lsr	#2,d0			; /4 for speed
	subq	#1,d0			; -1 (dbf)
	bmi.s	donemain		; none to do?
makelp	move.b	(a2,d5.l),d6		; fetch sample byte
	move.l	d6,a6
	move.b	(a6),d2			; lookup in vol tab
moda	add	d2,(a4)+		; add/move to buffer(self modified)
	add	d4,d3			; add frac part
	addx	d1,d5			; add ints.(carried thru)
	bcs.s	lpvoice1			; voice looped?
CONT1	move.b	(a2,d5.l),d6
	move.l	d6,a6
	move.b	(a6),d2
modb	add	d2,(a4)+
	add	d4,d3			; 
	addx	d1,d5
	bcs.s	lpvoice2
CONT2	move.b	(a2,d5.l),d6
	move.l	d6,a6
	move.b	(a6),d2
modc	add	d2,(a4)+
	add	d4,d3			;
	addx	d1,d5
	bcs	lpvoice3
CONT3	move.b	(a2,d5.l),d6
	move.l	d6,a6
	move.b	(a6),d2
modd	add	d2,(a4)+			;
	add	d4,d3
	addx	d1,d5
CONT4	dbcs	d0,makelp
	bcs	lpvoice4
donemain	
	move	#0,d0
	and	#3,d0			; remaining bytes.
	subq	#1,d0
	bmi.s	yeah
niblp	move.b	(a2,d5.l),d6
	move.l	d6,a6
	move.b	(a6),d2
mode	add	d2,(a4)+
	add	d4,d3
	addx	d1,d5
CONT5	dbcs	d0,niblp
	bcs	lpvoicelast
yeah	rts

buffbase	DS.L 1
loopfreq	DS.W 2
looplength	DS.L 1
voltab_ptr	DS.L 1

lpvoice		MACRO
		move.l	a0,a2 
		ext.l	d5
		add.l	looplength(pc),d5	; fetch loop constants
		movem	loopfreq(pc),d1/d4	; (channel independent)
		moveq	#0,d2
		move	d2,ccr	
 		bra	\1
		ENDM

lpvoice1:	lpvoice CONT1			;
lpvoice2:	lpvoice CONT2			; loop routs
lpvoice3:	lpvoice CONT3			; (since code is repeated)
lpvoice4:	lpvoice CONT4			;
lpvoicelast:	lpvoice CONT5			;

aadd		add	d2,(a4)+
amove		move	d2,(a4)+

nulsamp		ds.l 2				; nul sample.
buff_ptr:	dc.l 0
sndbuff1:	ds.w $400			; buffer for voices 1+2
endbuff1:	dc.w -1
sndbuff2	ds.w $400			; buffer for voices 3+4
endbuff2	dc.w -1

fillx1:		dc.w 0
fillx2:		dc.w 0

; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.

ste_flg		dc.w 0
	
Ste_Test
	lea	$FFFF8205.W,a5
	moveq	#-1,d1
	move.b	(a5),d0
	move.b	d1,(a5)
	cmp.b	(a5),d0
	beq	.notSTE
	move.b	d0,(a5)
.ste_found
	st	ste_flg
	lea	Which_replay(pc),a0
	move	#1,(a0)
	lea.l	setsam_dat(pc),a6
	moveq	#3,d6
.mwwrx	move	#$7ff,$ffff8924.W
.mwwrx2	cmp	#$7ff,$ffff8924.W
	bne.s	.mwwrx2
	move	(a6)+,$ffff8922.W
	dbf	d6,.mwwrx
.notSTE	rts

temp		dc.l	0
setsam_dat	dc.w	%0000000011010100  	;mastervol
		dc.w	%0000010010000110  	;treble
		dc.w	%0000010001000110  	;bass
		dc.w	%0000000000000001  	;mixer

; Select The Playback Routine D0.W = 0 to 6

Select_PlayRout
	move	sr,-(a7)
	move	#$2700,sr
	lea	Which_replay(pc),a0
	move	d0,(a0)
	lsl	#2,d0				; *4 (longword lookup)
	move.l	Output_Routs(pc,d0),d1
	lea	Output_Routs(pc),a0
	add.l	d1,a0
	move.l	a0,$110.W
	jsr	rout_tab(pc,d0.w)		; jump to setup rout
	move	(a7)+,sr
	rts

rout_tab	bra.w YM2149_Setup
		bra.w Ste_Setup
		bra.w Internal_Off
		bra.w Internal_Off
		bra.w Internal_Off
		bra.w Internal_Off
		bra.w Internal_Off

Which_replay	dc.w 0				; 0 - 6 as below
Output_Routs	dc.l YM2149_Player-Output_Routs
		dc.l Ste_Stereo-Output_Routs
		dc.l Replay_Player-Output_Routs
		dc.l ReplayPro_Player-Output_Routs
		dc.l Replay_Stereo-Output_Routs
		dc.l MV16_Player-Output_Routs
		dc.l ProSound_Player-Output_Routs


; YM2149 Setup rout - turns off ste dma(if machine is st) and clears YM.

YM2149_Setup
	lea	ste_flg(pc),a0
	tst.b	(a0)
	beq.s	.notste 
	move	#0,$FFFF8900.W
.notste bsr	Initsoundchip		; init soundchip
	rts

; Ste Stereo Setup rout - turns off YM 2149 and setsup dma.

Ste_Setup
	lea	ste_flg(pc),a0
	tst.b	(a0)
	beq.s	.notste
	bsr	Killsoundchip
	move	#0,$FFFF8900.W
	move	#$8080,$D0.W		; prime with nul sample
	lea	temp(pc),a6
	move.l	#$D0,(a6)			
	move.b	1(a6),$ffff8903.W
	move.b	2(a6),$ffff8905.W	; set start of buffer
	move.b	3(a6),$ffff8907.W
	move.l	#$D2,(a6)
	move.b	1(a6),$ffff890f.W
	move.b	2(a6),$ffff8911.W	; and set end of buf
	move.b	3(a6),$ffff8913.W
	move	#%0000000000000011,$ffff8920.W
	move	#3,$FFFF8900.W		; dma go!
.notste	rts

; Setup rout for all other output routs - kills both dma and YM sound.

Internal_Off
	lea	ste_flg(pc),a0
	tst.b	(a0)
	beq.s	.notste 
	move	#0,$FFFF8900.W
.notste	bsr	Killsoundchip
 	rts

;--------- The 12 bit sample interrupt Routines. They Use D7/A1 ---------;
; YM2149 Soundchip, Replay Cartridge, Replay Professional, Stereo Playback,
; STE Stereo Output, Pro-Sound Designer Cartridge, MV16 Cartridge.

; YM2149 Soundchip output.

YM2149_Player
	move.l	a1,-(a7)
	move.l	d7,-(a7)
	move.l	sndbufpos(pc),a1
	move.w	(a1)+,d7
	bmi.s	ymloop
ym1	addq.l	#2,sndbufpos
	add.w	$800(a1),d7
	lsl	#3,d7
	lea	$ffff8800.w,a1		; output
	move.l	sound_look+4(pc,d7.w),(a1)
	move.l	sound_look(pc,d7.w),d7	; using quartet table.
	movep.l d7,(a1)
	move.l	(a7)+,d7
	move.l	(a7)+,a1
	rte
ymloop	lea	sndbuff1(pc),a1
ym2	move.l	a1,sndbufpos
	move.w	(a1)+,d7
	bra.w	ym1

	
sound_look	incbin c:\language\68k\sound\quarfast.tab

; Ste Stereo sound output with volume boost.

Ste_Stereo
	movem.l	d6-7/a1,-(a7)
	move.l	sndbufpos(pc),a1
	move.w	(a1)+,d7
	bmi.s	ymloop2
ym3	addq.l	#2,sndbufpos
	move	$800(a1),d6
	add	d6,d6
	add	d7,d7
	move	stetab(pc,d6),d6
	move.b	stetab(pc,d7),d6
	move	d6,$d0.w
	movem.l	(a7)+,d6-7/a1
	rte
ymloop2	lea	sndbuff1(pc),a1
ym4	move.l	a1,sndbufpos
	move.w	(a1)+,d7
	bra.w	ym3

stetab	dcb.w 128,$8000
i	set -128
	rept 256
	dc.b i,0
i	set i+1
	endr
	dcb.w 128,$7f00

; Replay Catridge Output

Replay_Player:	move.w (a1)+,d7
		bmi.s .loopit
.contsnd	move.l a0,usp
		add.w $800(a1),d7
		add.w d7,d7
		move.w replaytab(pc,d7),d7	; give the replay
		lea $fa0000,a0			; output a vol boost!!
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

stereotab:	ds.w	128			; bottom clip
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
		move.b d7,(a0)			; output
		move.l usp,a0	
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

; ST specific initialisation routines - sets up shadow amiga registers.

STspecific
	lea	nulsamp+2(pc),a2
	moveq	#0,d0
	lea	ch1s(pc),a0
	bsr	initvoice
	lea	ch2s(pc),a0
	bsr	initvoice			;init shadow regs
	lea	ch3s(pc),a0
	bsr	initvoice
	lea	ch4s(pc),a0
	bsr	initvoice
	lea	sndbuff1(pc),a0
	lea	buff_ptr(pc),a1
	move.l	a0,(a1)
	lea	sndbuff2(pc),a1
	moveq	#0,d1
	moveq	#$7F,d0
.setbuf1	
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+		; clear 2 ring buffers
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	dbf	d0,.setbuf1
	rts
initvoice
	move.l	a2,(a0)		; point voice to nul sample
	move	#2,4(a0)	
	move	d0,6(a0)	; period=0
	move	d0,8(a0)	; volume=0
	move.l	a2,10(a0)	; and loop point to nul sample
	move	#2,14(a0)
	move	d0,16(a0)	; clear fraction part.
	rts

; Initialise Soundchip

Initsoundchip
	lea	$FFFF8800.W,a0
	move.b	#7,(a0)			; turn on sound
	move.b	#$c0,d0
	and.b	(a0),d0
	or.b	#$38,d0
	move.b	d0,2(a0)
	move	#$0500,d0		; clear out ym2149
.inilp	movep.w	d0,(a0)
	sub	#$0100,d0
	bpl.s	.inilp
	rts

; Reset sound chip

Killsoundchip
	move	d0,-(a7)
	move.b	#7,$ffff8800.W		
	move.b	#7,d0
	or.b	$ffff8800.W,d0
	move.b	d0,$ffff8802.W
	move	(a7)+,d0
	rts

; Make sure Volume lookup table is on a 256 byte boundary.

Init_Voltab
	lea	vols+256(pc),a0
	move.l	a0,d0
	clr.b	d0
	lea	voltab_ptr(pc),a1
	tst.l	(a1)
	bne.s	.alreadyinited
	move.l	d0,(a1)
	move.l	d0,a1
	move	#(16640/16)-1,d0
.lp	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.lp
.alreadyinited	
	rts


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

mt_init	lea	mt_SongDataPtr(pc),a4
	move.l	a0,(a4)
	lea	mt_mulu(pc),a1
	move.l	a0,d0
	add.l	#12,d0
	moveq	#$1F,d1
	moveq	#$1E,d3
mt_lop4	move.l	d0,(a1)+
	add.l	d3,d0
	dbra	d1,mt_lop4
	lea	$3B8(a0),a1
	moveq	#127,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2 move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop	dbra	d0,mt_lop2
	addq	#1,d2
	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_SampleStarts(pc),a1
	add	#$2A,a0
	moveq	#$1E,d0
mt_lop3 clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(A0)
	move	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbra	d0,mt_lop3
	lea	mt_speed(pc),a1
	move.b	#6,(a1)
	moveq	#0,d0
	move.b	d0,mt_SongPos-mt_speed(a1)
	move.b	d0,mt_counter-mt_speed(a1)
	move	d0,mt_PattPos-mt_speed(a1)
	bra	STspecific

; Vbl Sequencer

ot_SongDataPtr=0
ot_speed=4
ot_counter=5
ot_SongPos=6
ot_PBreakPos=7
ot_PosJumpFlag=8
ot_PBreakFlag=9
ot_LowMask=10
ot_PattDelTime=11
ot_PattDelTime2=12
ot_PattPos=14
ot_mulu=16

mt_music
	lea	mt_SongDataPtr(pc),a1
	addq.b	#1,ot_counter(a1)
	move.b	ot_counter(a1),D0
	cmp.b	ot_speed(a1),D0
	blo.s	mt_NoNewNote
	clr.b	ot_counter(a1)
	tst.b	ot_PattDelTime2(a1)
	beq.s	mt_GetNewNote
	bsr.s	mt_NoNewAllChannels
	bra	mt_dskip

mt_NoNewNote
	bsr.s	mt_NoNewAllChannels
	bra	mt_NoNewPosYet

mt_NoNewAllChannels
	lea	ch1s(pc),a5
	lea	mt_chan1temp(pc),a6
	bsr	mt_CheckEfx
	lea	ch2s(pc),a5
	lea	mt_chan2temp(pc),a6
	bsr	mt_CheckEfx
	lea	ch3s(pc),a5
	lea	mt_chan3temp(pc),a6
	bsr	mt_CheckEfx
	lea	ch4s(pc),a5
	lea	mt_chan4temp(pc),a6
	bra	mt_CheckEfx

mt_GetNewNote
	move.l	mt_SongDataPtr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	ot_SongPos(a1),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add	ot_PattPos(a1),d1

	lea	ch1s(pc),a5
	lea	mt_chan1temp(pc),a6
	bsr.s	mt_PlayVoice
	lea	ch2s(pc),a5
	lea	mt_chan2temp(pc),a6
	bsr.s	mt_PlayVoice
	lea	ch3s(pc),a5
	lea	mt_chan3temp(pc),a6
	bsr.s	mt_PlayVoice
	lea	ch4s(pc),a5
	lea	mt_chan4temp(pc),a6
	bsr.s	mt_PlayVoice
	bra	mt_SetDMA

mt_PlayVoice
	tst.l	(a6)
	bne.s	mt_plvskip
	move	n_period(a6),6(a5)
mt_plvskip
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$F0,d0
	or.b	d0,d2
	beq	mt_SetRegs
	moveq	#0,d3
	move	d2,d4
	subq.l	#1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l	mt_SampleStarts(pc,d2.l),n_start(a6)
	move	(a3,d4.l),n_length(a6)
	move	(a3,d4.L),n_reallength(a6)
	move.b	2(a3,d4.L),n_finetune(a6)
	move.b	3(a3,d4.L),n_volume(a6)
	move	4(a3,d4.L),d3 		; Get repeat
	tst	d3
	beq	mt_NoLoop
	move.l	n_start(a6),d2		; Get start
	asl	#1,d3
	add.l	d3,d2			; Add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move	4(a3,d4.l),d0		; Get repeat
	add	6(a3,d4.l),d0		; Add replen
	move	d0,n_length(a6)
	move	6(a3,d4.l),n_replen(a6)	; Save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,8(a5)		; Set volume
	bra	mt_SetRegs
mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_NoLoop
	move.l	n_start(a6),d2
	add.l	d3,d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move	6(a3,d4.l),n_replen(a6)	; Save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,8(a5)		; Set volume
mt_SetRegs
	move	(a6),d0
	and	#$0FFF,d0
	beq	mt_CheckMoreEfx		; If no note
	move	2(a6),d0
	and	#$0FF0,d0
	cmp	#$0E50,d0
	beq.s	mt_DoSetFineTune
	move.b	2(a6),d0
	and.b	#$0F,d0
	cmp.b	#3,d0			; TonePortamento
	beq.s	mt_ChkTonePorta
	cmp.b	#5,d0
	beq.s	mt_ChkTonePorta
	cmp.b	#9,d0			; Sample Offset
	bne.s	mt_SetPeriod
	bsr	mt_CheckMoreEfx
	bra.s	mt_SetPeriod

mt_DoSetFineTune
	bsr	mt_SetFineTune
	bra.s	mt_SetPeriod

mt_ChkTonePorta
	bsr	mt_SetTonePorta
	bra	mt_CheckMoreEfx

mt_SetPeriod
	movem.l	d1-d2/a2,-(a7)
	move	(a6),d1
	and	#$0FFF,d1
	lea	mt_PeriodTable(pc),a2
	moveq	#36,d2
mt_ftuloop
	cmp	(a2)+,d1
	dbhs	d2,mt_ftuloop
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	move	-2(a2,d1.l),n_period(a6)
	movem.l	(a7)+,d1-d2/a2

	move	2(a6),d0
	and	#$0FF0,d0
	cmp	#$0ED0,d0 			; Notedelay
	beq	mt_CheckMoreEfx

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),(a5)		; Set start
	moveq	#0,d0
	move	n_length(a6),d0
	add.l	d0,d0
	add.l	d0,(a5)				; point to end of sample
	move	d0,4(a5)			; Set length
	move	n_period(a6),6(a5)		; Set period
	bra	mt_CheckMoreEfx
 
mt_SetDMA
	move.l	d0,-(a7)
	moveq	#0,d0
	lea	ch4s(pc),a5
	lea	mt_chan4temp(pc),a6
	move.l	n_loopstart(a6),10(a5)
	move	n_replen(a6),d0
	add.l	d0,d0
	add.l	d0,10(a5)
	move	d0,14(a5)

	moveq	#0,d0
	lea	ch3s(pc),a5
	lea	mt_chan3temp(pc),a6
	move.l	n_loopstart(a6),10(a5)
	move	n_replen(a6),d0
	add.l	d0,d0
	add.l	d0,10(a5)
	move	d0,14(a5)

	moveq	#0,d0
	lea	ch2s(pc),a5
	lea	mt_chan2temp(pc),a6
	move.l	n_loopstart(a6),10(a5)
	move	n_replen(A6),d0
	add.l	d0,d0
	add.l	d0,10(a5)
	MOVE.W	d0,14(a5)

	moveq	#0,d0
	lea	ch1s(pc),a5
	lea	mt_chan1temp(pc),a6
	move.l	n_loopstart(a6),10(a5)
	move	n_replen(a6),d0
	add.l	d0,d0
	add.l	d0,10(a5)
	move	D0,14(a5)

	move.l	(a7)+,d0

mt_dskip
	add	#16,ot_PattPos(a1)
	move.b	ot_PattDelTime(a1),d0
	beq.s	mt_dskc
	move.b	d0,ot_PattDelTime2(a1)
	clr.b	ot_PattDelTime(a1)
mt_dskc	tst.b	ot_PattDelTime2(a1)
	beq.s	mt_dska
	subq.b	#1,ot_PattDelTime2(a1)
	beq.s	mt_dska
	sub	#16,ot_PattPos(a1)
mt_dska	tst.b	ot_PBreakFlag(a1)
	beq.s	mt_nnpysk
	sf	ot_PBreakFlag(a1)
	moveq	#0,d0
	move.b	ot_PBreakPos(a1),d0
	clr.b	ot_PBreakPos(a1)
	lsl	#4,d0
	move	d0,ot_PattPos(a1)
mt_nnpysk
	cmp	#1024,ot_PattPos(a1)
	blo.s	mt_NoNewPosYet
mt_NextPosition	
	moveq	#0,d0
	move.b	ot_PBreakPos(a1),d0
	lsl	#4,d0
	move	d0,ot_PattPos(a1)
	clr.b	ot_PBreakPos(a1)
	clr.b	ot_PosJumpFlag(a1)
	addq.b	#1,ot_SongPos(a1)
	and.b	#$7F,ot_SongPos(a1)
	move.b	ot_SongPos(a1),d1
	move.l	ot_SongDataPtr(a1),a0
	cmp.b	950(a0),d1
	blo.s	mt_NoNewPosYet
	clr.b	ot_SongPos(a1)
mt_NoNewPosYet	
	tst.b	ot_PosJumpFlag(a1)
	bne.s	mt_NextPosition
	rts

mt_CheckEfx
	bsr	mt_UpdateFunk
	move	n_cmd(a6),d0
	and	#$0FFF,d0
	beq.s	mt_PerNop
	move.b	n_cmd(a6),d0
	and.b	#$0F,d0
	beq.s	mt_Arpeggio
	cmp.b	#1,d0
	beq	mt_PortaUp
	cmp.b	#2,d0
	beq	mt_PortaDown
	cmp.b	#3,d0
	beq	mt_TonePortamento
	cmp.b	#4,d0
	beq	mt_Vibrato
	cmp.b	#5,d0
	beq	mt_TonePlusVolSlide
	cmp.b	#6,d0
	beq	mt_VibratoPlusVolSlide
	cmp.b	#$E,d0
	beq	mt_E_Commands
SetBack	move	n_period(a6),6(a5)
	cmp.b	#7,d0
	beq	mt_Tremolo
	cmp.b	#$A,d0
	beq	mt_VolumeSlide
mt_Return2
	rts

mt_PerNop
	move	n_period(a6),6(a5)
	rts

mt_Arpeggio
	moveq	#0,d0
	move.b	ot_counter(a1),d0
	divs	#3,d0
	swap	d0
	cmp	#0,d0
	beq.s	mt_Arpeggio2
	cmp	#2,d0
	beq.s	mt_Arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_Arpeggio3

mt_Arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	mt_Arpeggio3

mt_Arpeggio2
	move	n_period(a6),d2
	bra.s	mt_Arpeggio4

mt_Arpeggio3
	asl	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	lea	mt_PeriodTable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move	n_period(a6),d1
	move.l	d3,-(a7)
	moveq	#36,d3
mt_arploop
	move	(a0,d0.w),d2
	cmp	(a0)+,d1
	bhs.s	.arp4
	dbf	d3,mt_arploop
	move.l	(a7)+,d3
	rts
.arp4	move	d2,6(a5)
	move.l	(a7)+,d3
	rts

mt_Arpeggio4
	move	d2,6(a5)
	rts

mt_FinePortaUp
	tst.b	ot_counter(a1)
	bne	mt_Return2
	move.b	#$0F,ot_LowMask(a1)
mt_PortaUp
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	ot_LowMask(a1),d0
	move.b	#$FF,ot_LowMask(a1)
	sub	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$0FFF,d0
	cmp	#113,d0
	bpl.s	mt_PortaUskip
	and	#$F000,n_period(a6)
	or	#113,n_period(a6)
mt_PortaUskip
	move	n_period(a6),d0
	and	#$0FFF,d0
	move	d0,6(a5)
	rts
 
mt_FinePortaDown
	tst.b	ot_counter(a1)
	bne	mt_Return2
	move.b	#$0F,ot_LowMask(a1)
mt_PortaDown
	clr	d0
	move.b	n_cmdlo(a6),d0
	and.b	ot_LowMask(a1),d0
	move.b	#$FF,ot_LowMask(a1)
	add	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$0FFF,d0
	cmp	#856,d0
	bmi.s	mt_PortaDskip
	and	#$F000,n_period(a6)
	or	#856,n_period(a6)
mt_PortaDskip
	move	n_period(a6),d0
	and	#$0FFF,d0
	move	D0,6(a5)
	rts

mt_SetTonePorta
	move.l	a0,-(a7)
	move	(a6),d2
	and	#$0FFF,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	mt_PeriodTable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_StpLoop
	cmp	(a0,d0.w),d2
	bhs.s	mt_StpFound
	addq.w	#2,d0
	cmp	#37*2,d0
	blo.s	mt_StpLoop
	moveq	#35*2,d0
mt_StpFound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_StpGoss
	tst	d0
	beq.s	mt_StpGoss
	subq.w	#2,d0
mt_StpGoss
	move	(a0,d0.w),d2
	move.l	(a7)+,a0
	move	d2,n_wantedperiod(a6)
	move	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp	d0,d2
	beq.s	mt_ClearTonePorta
	bge	mt_Return2
	move.b	#1,n_toneportdirec(a6)
	rts

mt_ClearTonePorta
	clr	n_wantedperiod(a6)
	rts

mt_TonePortamento
	move.b	n_cmdlo(a6),d0
	beq.s	mt_TonePortNoChange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_TonePortNoChange
	tst	n_wantedperiod(a6)
	beq	mt_Return2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_TonePortaUp
mt_TonePortaDown
	add	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	bgt.s	mt_TonePortaSetPer
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)
	bra.s	mt_TonePortaSetPer

mt_TonePortaUp
	sub	d0,n_period(A6)
	move	n_wantedperiod(A6),d0
	cmp	n_period(A6),d0
	blt.s	mt_TonePortaSetPer
	move	n_wantedperiod(A6),n_period(A6)
	clr	n_wantedperiod(A6)

mt_TonePortaSetPer
	move	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0F,d0
	beq.s	mt_GlissSkip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#36*2,d0
	lea	mt_PeriodTable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_GlissLoop
	cmp	(a0,d0.w),d2
	bhs.s	mt_GlissFound
	addq.w	#2,d0
	cmp	#36*2,d0
	blo.s	mt_GlissLoop
	moveq	#35*2,d0
mt_GlissFound
	move	(a0,d0.w),d2
mt_GlissSkip
	move	d2,6(a5) 			; Set period
	rts

mt_Vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	mt_Vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0F,d0
	beq.s	mt_vibskip
	and.b	#$F0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$F0,d0
	beq.s	mt_vibskip2
	and.b	#$0F,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
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
	move.b	d0,ot_SongPos(a1)
mt_pj2	clr.b	ot_PBreakPos(a1)
	st 	ot_PosJumpFlag(a1)
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
	move.b	d0,ot_PBreakPos(a1)
	st	ot_PosJumpFlag(a1)
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ	mt_Return2
	clr.b	ot_counter(a1)
	move.b	d0,ot_speed(a1)
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
	tst.b	ot_counter(a1)
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return2
mt_jmploop	
	move.b	n_pattpos(a6),ot_PBreakPos(a1)
	st	ot_PBreakFlag(a1)
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	move	ot_PattPos(a1),d0
	lsr	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

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
	move.b	ot_counter(a1),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	move.b	ot_counter(a1),d1
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
	tst.b	ot_counter(a1)
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	tst.b	ot_counter(a1)
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	cmp.b	ot_counter(a1),d0
	BNE	mt_Return2
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	cmp.b	ot_counter(a1),D0
	BNE	mt_Return2
	MOVE.W	(A6),D0
	BEQ	mt_Return2
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	tst.b	ot_counter(a1)
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	tst.b	ot_PattDelTime2(a1)
	BNE	mt_Return2
	ADDQ.B	#1,D0
	move.b	d0,ot_PattDelTime(a1)
	rts

mt_FunkIt
	tst.b	ot_counter(a1)
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

freq_speed	ds.w 1
freqs		ds.l 2
		incbin  c:\language\68k\sound\freq82.bin		; frequency table. int.w/frac.w
		even

vols		ds.l 64
		incbin  c:\language\68k\sound\pt_volta.dat		; 65 ,256 byte lookups.
		even

