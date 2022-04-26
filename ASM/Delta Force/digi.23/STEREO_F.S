;--------------------------------------------------------------------;
;		 Digisynth - SoundTracker V2.3 replay		     ;
;			  by Wiz 4. April '90			     ;
;--------------------------------------------------------------------;

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Supervisor mode on
	addq.w	#6,sp
	move.l	d0,-(sp)

	jsr	mt_init			; Initialize some music
	bsr	vol			; Ready some tables
	bsr	incrcal			; More tables
	bsr	INTon			; And off we go!

waitspc	cmp.b	#$b9,$fffffc02.w	; Waits for [space]
	bne	waitspc

	move.w	#-1,$ffff8240.w
	bsr	INToff			; Remove those interrupts

	move.w	#$20,-(sp)		; Supervisor mode off
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)			; Terminate
	move.w	#$4c,-(sp)
	trap	#1


handle	dc.w	0

;------------------- Interrupts on/off ------------------
INTon	move.w	#$2700,sr

	move.b	$fffffa07.w,s07		; Save MFP registers
	move.b	$fffffa09.w,s09
	move.b	$fffffa13.w,s13
	move.b	$fffffa15.w,s15

	move.b	#$20,$fffffa07.w	; Timer A on
	move.b	#$20,$fffffa13.w
	clr.b	$fffffa09.w
	clr.b	$fffffa15.w

	bclr	#3,$fffffa17.w		; Autovectors

	clr.b	$fffffa19.w
	move.b	#1,$fffffa1f.w
	move.b	#8,$fffffa19.w

	move.l	$134.w,oldTimA
	move.l	#SAMPit,$134.w

	move.l	#samples,d0
	move.b	d0,$ffff8907.w
	lsr.l	#8,d0
	move.b	d0,$ffff8905.w
	lsr.l	#8,d0
	move.b	d0,$ffff8903.w

	move.l	#samples+250*2,d0
	move.b	d0,$ffff8913.w
	lsr.l	#8,d0
	move.b	d0,$ffff8911.w
	lsr.l	#8,d0
	move.b	d0,$ffff890f.w

	move.w	#$7ff,$ffff8924.w
	move.w	#%10010001100,$ffff8922.w
mwwait	cmp.w	#$07ff,$ffff8924
	bne.s	mwwait
	move.w	#%10001000110,$ffff8922.w

	move.b	#%00000001,$ffff8921.w
	move.b	#%00000011,$ffff8901.w
	
	move.w	#$2400,sr
	rts

INToff	move.w	#$2700,sr
	move.l	oldTimA,$134.w
	move.b	s07,$fffffa07.w
	move.b	s09,$fffffa09.w
	move.b	s13,$fffffa13.w
	move.b	s15,$fffffa15.w
	bset	#3,$fffffa17.w		; Softvectors

	clr.b	$ffff8901.w

	move.w	#$2300,sr
	rts

s07	dc.b	0
s09	dc.b	0
s13	dc.b	0
s15	dc.b	0

oldTimA	dc.l	0

;----------------------- Volume table -----------------------
vol	move.w	#64,d0
	lea	vtabend(pc),a0

.oloop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#$80,d2			*<---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop

	dbra	d0,.oloop

	rts

vtab	ds.b	65*256
vtabend

;----------------------- Increment-table -----------------------
incrcal	lea	stab(pc),a0
	move.w	#$71,d1
	move.w	#$358-$71,d0
	move.l	#$011DF98A,d2	; 3579546/12517*65536,d1 ==> 12517=frequency

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	ds.l	$71
stab	ds.l	$359-$71

;----------------- Sampleutrekningsklargjering ------------------
SAMPit	move.w	#$2400,sr
	movem.l	d0-d4/a0-a4,-(sp)

	addq.w	#1,$ffff9000.w

	lea	temp(pc),a0		*8
	lea	temp+500(pc),a1		*8
	lea	temp+750(pc),a2		*8
	lea	samples(pc),a3		*8

	moveq.l	#-4,d4			*4

	REPT	250
	move.b	250(a0),d1		*12
	move.b	(a0)+,d0		*8
	add.b	(a1)+,d1		*8
	add.b	(a2)+,d0		*8

	move.b	d0,(a3)+
	move.b	d1,(a3)+
	ENDR
	
	lea	itab(pc),a2		*8
	lea	temp(pc),a3		*8
	lea	vtab(pc),a4		*8

voice1	move.l	AUD1LC(pc),a0		*16

	move.w	aud1tmp(pc),d1		*12	integer
	move.w	aud1tmp+2(pc),d0	*12	desimal

	move.w	AUD1PER(pc),d4		*16
	and.w	#$fff,d4
	add.w	d4,d4			*4
	add.w	d4,d4			*4
	move.w	0(a2,d4.w),d3		*14	integer
	move.w	2(a2,d4.w),d2		*14	desimal

	move.w	AUD1VOL(pc),d4		*12
	lsl.w	#8,d4			*22
	lea	(a4,d4.w),a1		*12	= 146

	moveq	#0,d4

	REPT	250
		add.w	d2,d0			*4
		addx.w	d3,d1			*4
		dc.w	$6a08			*10
		move.w	AUD1LEN(pc),d1		*12
		clr.b	(a3)+			*12	Ta vekk desse to for
		dc.w	$6008			*10	skikkeleg emulering
		move.b	0(a0,d1.w),d4		*14
		move.b	0(a1,d4.w),(a3)+	*18	= 50
	ENDR

	move.w	d1,aud1tmp		*16	integer
	move.w	d0,aud1tmp+2		*16	desimal

voice2	move.l	AUD2LC(pc),a0		*16

	move.w	aud2tmp(pc),d1		*12	integer
	move.w	aud2tmp+2(pc),d0	*12	desimal

	move.w	AUD2PER(pc),d4		*16
	and.w	#$fff,d4
	add.w	d4,d4			*4
	add.w	d4,d4			*4
	move.w	0(a2,d4.w),d3		*14	integer
	move.w	2(a2,d4.w),d2		*14	desimal

	move.w	AUD2VOL(pc),d4		*12
	lsl.w	#8,d4			*22
	lea	(a4,d4.w),a1		*12	= 146

	moveq	#0,d4

	REPT	250
		add.w	d2,d0			*4
		addx.w	d3,d1			*4
		dc.w	$6a08			*10
		move.w	AUD2LEN(pc),d1		*12
		clr.b	(a3)+			*12
		dc.w	$6008			*10
		move.b	0(a0,d1.w),d4		*14
		move.b	0(a1,d4.w),(a3)+	*18	= 50
	ENDR

	move.w	d1,aud2tmp		*16	integer
	move.w	d0,aud2tmp+2		*16	desimal

voice3	move.l	AUD3LC(pc),a0		*16

	move.w	aud3tmp(pc),d1		*12	integer
	move.w	aud3tmp+2(pc),d0	*12	desimal

	move.w	AUD3PER(pc),d4		*16
	and.w	#$fff,d4
	add.w	d4,d4			*4
	add.w	d4,d4			*4
	move.w	0(a2,d4.w),d3		*14	integer
	move.w	2(a2,d4.w),d2		*14	desimal

	move.w	AUD3VOL(pc),d4		*12
	lsl.w	#8,d4			*22
	lea	(a4,d4.w),a1		*12	= 146

	moveq	#0,d4

	REPT	250
		add.w	d2,d0			*4
		addx.w	d3,d1			*4
		dc.w	$6a08			*10
		move.w	AUD3LEN(pc),d1		*12
		clr.b	(a3)+			*12
		dc.w	$6008			*10
		move.b	0(a0,d1.w),d4		*14
		move.b	0(a1,d4.w),(a3)+	*18	= 50
	ENDR

	move.w	d1,aud3tmp		*16	integer
	move.w	d0,aud3tmp+2		*16	desimal

voice4	move.l	AUD4LC(pc),a0		*16

	move.w	aud4tmp(pc),d1		*12	integer
	move.w	aud4tmp+2(pc),d0	*12	desimal

	move.w	AUD4PER(pc),d4		*16
	and.w	#$fff,d4
	add.w	d4,d4			*4
	add.w	d4,d4			*4
	move.w	0(a2,d4.w),d3		*14	integer
	move.w	2(a2,d4.w),d2		*14	desimal

	move.w	AUD4VOL(pc),d4		*12
	lsl.w	#8,d4			*22
	lea	(a4,d4.w),a1		*12	= 146

	moveq	#0,d4

	REPT	250
		add.w	d2,d0			*4
		addx.w	d3,d1			*4
		dc.w	$6a08			*10
		move.w	AUD4LEN(pc),d1		*12
		clr.b	(a3)+			*12
		dc.w	$6008			*10
		move.b	0(a0,d1.w),d4		*14
		move.b	0(a1,d4.w),(a3)+	*18	= 50
	ENDR

	move.w	d1,aud4tmp		*16	integer
	move.w	d0,aud4tmp+2		*16	desimal

finish	jsr	mt_music

	movem.l	(sp)+,d0-d4/a0-a4

	rte


;-------------------- Hardware-registers & data ----------------
aud1tmp	dc.l	0
HARDWARE
AUD1LC	dc.l	filter
AUD1LEN	dc.w	$8000
AUD1PER	dc.w	0
AUD1VOL	dc.w	0
	dc.w	0

aud2tmp	dc.l	0
AUD2LC	dc.l	filter
AUD2LEN	dc.w	$8000
AUD2PER	dc.w	0
AUD2VOL	dc.w	0
	dc.w	0

aud3tmp	dc.l	0
AUD3LC	dc.l	filter
AUD3LEN	dc.w	$8000
AUD3PER	dc.w	0
AUD3VOL	dc.w	0
	dc.w	0

aud4tmp	dc.l	0
AUD4LC	dc.l	filter
AUD4LEN	dc.w	$8000
AUD4PER	dc.w	0
AUD4VOL	dc.w	0
	dc.w	0

FILTER	dc.w	0
DMActrl	dc.w	0

samples	ds.b	256*2
temp	ds.b	256*4

;============================== EMULATOR END ==============================

;нннннннннннннннннннннннннннннннннннннн
;н   NoisetrackerV1.0 replayroutine   н
;н Mahoney & Kaktus - HALLONSOFT 1989 н
;нннннннннннннннннннннннннннннннннннннн

mt_init	lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop	move.l	d1,d2
	subq.w	#1,d0
mt_lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0

mt_lop3	clr.l	(a2)
	move.l	a2,(a1)
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1

	move.w	48(a0),d3		;
	add.w	d3,d3			;
	move.l	#$8000,d4		;
	sub.w	d3,d4			;
	move.w	d4,48(a0)		;

	tst.w	46(a0)			;
	beq.s	.no			;

	sub.l	d4,(a1)+		;
	bra.s	.ok			;

.no	move.l	#$8000,d4		;
	sub.w	d1,d4			;
	move.w	d4,42(a0)		;
	sub.l	d4,(a1)+		;
	move.w	#$8000,48(a0)		;	Tvilsom

.ok	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,FILTER
	move.b	#$6,mt_speed
	clr.w	AUD1VOL
	clr.w	AUD2VOL
	clr.w	AUD3VOL
	clr.w	AUD4VOL
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end	clr.w	AUD1VOL
	clr.w	AUD2VOL
	clr.w	AUD3VOL
	clr.w	AUD4VOL
	move.w	#$000f,DMActrl
	rts



mt_music
	lea	mt_data,a0
	addq.b	#1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew
	lea	mt_voice1(pc),a4
	lea	AUD1LC,a3
	bsr	mt_checkcom
	lea	mt_voice2(pc),a4
	lea	AUD2LC,a3
	bsr	mt_checkcom
	lea	mt_voice3(pc),a4
	lea	AUD3LC,a3
	bsr	mt_checkcom
	lea	mt_voice4(pc),a4
	lea	AUD4LC,a3
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a4),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1	moveq	#0,d0
	move.b	$3(a4),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2	move.w	$10(a4),d2
	bra.s	mt_arp4
mt_arp3	asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d4
mt_arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d4,mt_arploop
	rts

mt_arp4	move.w	d2,$6(a3)
	rts

mt_getnew
	lea	mt_data,a0
	lea	$3b8(a0),a1
	lea	$00c(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	AUD1LC,a3
	lea	mt_voice1(pc),a4
	bsr.s	mt_playvoice
	lea	AUD2LC,a3
	lea	mt_voice2(pc),a4
	bsr.s	mt_playvoice
	lea	AUD3LC,a3
	lea	mt_voice3(pc),a4
	bsr.s	mt_playvoice
	lea	AUD4LC,a3
	lea	mt_voice4(pc),a4
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice
	move.l	(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a4),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a4)
	move.w	(a2,d4.l),$8(a4)
	move.w	$2(a2,d4.l),$12(a4)
	move.w	$4(a2,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a4),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a4)
	move.w	$4(a2,d4.l),d0
	add.w	$6(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$6(a2,d4.l),$e(a4)
	move.w	$12(a4),$8(a3)
	bra.s	mt_setregs

mt_noloop
	move.l	$4(a4),d2
	add.l	d3,d2
	move.l	d2,$a(a4)
	move.w	$6(a2,d4.l),$e(a4)
	move.w	$12(a4),$8(a3)
mt_setregs
	move.w	(a4),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a4),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2

mt_setperiod
	move.w	(a4),$10(a4)
	and.w	#$0fff,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,DMActrl
	clr.b	$1b(a4)

	move.l	$4(a4),(a3)
	move.w	$8(a4),$4(a3)
	move.w	$10(a4),d0
	and.w	#$0fff,d0
	move.w	d0,$6(a3)
	move.w	$14(a4),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma
;	move.w	#$012c,d0
;mt_wait	dbf	d0,mt_wait
;	move.w	mt_dmacon,d0
;	or.w	#$8000,d0
;	move.w	d0,DMActrl
;	move.w	#$12c,d0
;mt_wai2	dbf	d0,mt_wai2

	move.w	mt_dmacon,d0		;
	lea	AUD1LC(pc),a0		;
	btst	#0,d0			;
	beq.s	no1			;
	move.w	$4(a0),-$4(a0)		;
	clr.w	-2(a0)			;
no1	btst	#1,d0			;
	beq.s	no2			;
	move.w	$14(a0),$C(a0)		;
	clr.w	$E(a0)			;
no2	btst	#2,d0			;
	beq.s	no3			;
	move.w	$24(a0),$1C(a0)		;
	clr.w	$1E(a0)			;
no3	btst	#3,d0			;
	beq.s	no4			;
	move.w	$34(a0),$2C(a0)		;
	clr.w	$2E(a0)			;
no4

	lea	HARDWARE-$a0,a3
	lea	mt_voice4(pc),a4
	move.l	$a(a4),$d0(a3)
	move.w	$e(a4),$d4(a3)
	lea	mt_voice3(pc),a4
	move.l	$a(a4),$c0(a3)
	move.w	$e(a4),$c4(a3)
	lea	mt_voice2(pc),a4
	move.l	$a(a4),$b0(a3)
	move.w	$e(a4),$b4(a3)
	lea	mt_voice1(pc),a4
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	move.b	mt_data+$3b7,mt_songpos
mt_endr	tst.b	mt_break
	bne.s	mt_nex

	rts				*	-----> EXIT <-----

mt_setmyport
	move.w	(a4),d2
	and.w	#$0fff,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a4)
	rts

mt_clrport
	clr.w	$18(a4)
mt_rt	rts

mt_myport
	move.b	$3(a4),d0
	beq.s	mt_myslide
	move.b	d0,$17(a4)
	clr.b	$3(a4)
mt_myslide
	tst.w	$18(a4)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mt_mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
mt_myok	move.w	$10(a4),$6(a3)
	rts

mt_mysub
	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$6(a3)
	rts

mt_vib	move.b	$3(a4),d0
	beq.s	mt_vi
	move.b	d0,$1a(a4)

mt_vi	move.b	$1b(a4),d0
	lea	mt_sin(pc),a1
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a1,d0.w),d2
	move.b	$1a(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a4),d0
	tst.b	$1b(a4)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2

mt_vibmin
	sub.w	d2,d0
mt_vib2	move.w	d0,$6(a3)
	move.b	$1a(a4),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a4)
	rts

mt_nop	move.w	$10(a4),$6(a3)
	rts

mt_checkcom
	move.w	$2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a4),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a4),$6(a3)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide
	moveq	#0,d0
	move.b	$3(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a4)
	cmp.w	#$40,$12(a4)
	bmi.s	mt_vol2
	move.w	#$40,$12(a4)
mt_vol2	move.w	$12(a4),$8(a3)
	rts

mt_voldown
	moveq	#0,d0
	move.b	$3(a4),d0
	and.b	#$f,d0
	sub.w	d0,$12(a4)
	bpl.s	mt_vol3
	clr.w	$12(a4)
mt_vol3	move.w	$12(a4),$8(a3)
	rts

mt_portup
	moveq	#0,d0
	move.b	$3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a4)
	or.w	#$71,$10(a4)
mt_por2	move.w	$10(a4),d0
	and.w	#$0fff,d0
	move.w	d0,$6(a3)
	rts

mt_portdown
	clr.w	d0
	move.b	$3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a4)
	or.w	#$358,$10(a4)
mt_por3	move.w	$10(a4),d0
	and.w	#$0fff,d0
	move.w	d0,$6(a3)
	rts

mt_checkcom2
	move.b	$2(a4),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt
	move.b	$3(a4),d0
	and.b	#$1,d0
	asl.b	#$1,d0
	and.b	#$fd,FILTER
	or.b	d0,FILTER
	rts

mt_pattbreak
	move.b	#-1,mt_break
	rts

mt_posjmp
	move.b	$3(a4),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	move.b	#-1,mt_break
	rts

mt_setvol
	cmp.b	#$40,$3(a4)
	ble.s	mt_vol4
	move.b	#$40,$3(a4)
mt_vol4	move.b	$3(a4),$9(a3)
	move.b	$3(a4),$13(a4)
	rts

mt_setspeed
	cmp.b	#$1f,$3(a4)
	ble.s	mt_sets
	move.b	#$1f,$3(a4)
mt_sets	move.b	$3(a4),d0
	beq.s	mt_rts2
	move.b	d0,mt_speed
	clr.b	mt_counter
mt_rts2	rts

mt_sin	dc.b	$00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b	$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods	
	dc.w	$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w	$01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w	$00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w	$007f,$0078,$0071,$0000,$0000

mt_speed	dc.b	$6
mt_songpos	dc.b	0
mt_pattpos	dc.w	0
mt_counter	dc.b	0

mt_break	dc.b	0
mt_dmacon	dc.w	0
mt_samplestarts	ds.l	$1f
mt_voice1	ds.w	10
		dc.w	$1
		ds.w	3
mt_voice2	ds.w	10
		dc.w	$2
		ds.w	3
mt_voice3	ds.w	10
		dc.w	$4
		ds.w	3
mt_voice4	ds.w	10
		dc.w	$8
		ds.w	3

mt_data		incbin st*.mod
