
;----------------------------------------------------
;-------   Soundtracker V2.4 - playroutine    -------
;-------   Coded by CHECKSUM from EQUINOX!    -------
;----------------------------------------------------

; call mt_init to initialize the playroutine.
; call mt_music in each vbl to play the music.
; WARNING !! You have only 4 registers to work
; in your program. they are d0,d1,a0,a1. Have fun !

	lea	deb,a0
	lea	fin,a1

deb
	bra	mt_init
	bra	mt_music
	bra	mt_end
level1	ds.w	1
level2	ds.w	1
level3	ds.w	1
level4	ds.w	1

mt_gfa
	move.l	4(sp),a0
	lea	mt_adrsave(pc),a1
	move.l	a0,(a1)
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	mt_adrsave(pc),a1
	move.l	(a1),a0
	move.l	d0,(a1)
	clr.b	$fffa09
	bsr	mt_init	
	move.l	$70.w,-(sp)
	lea	newvbl(pc),a0
	move.l	a0,$70.w
att	cmp.b	#$39,$fffc02
	bne	att
	move.w	#$2700,sr
	move.l	(sp)+,$70.w
	bsr	mt_end
	move.b	#$64,$fffa09
	move.w	#$2300,sr
	move.w	#4000,d0
wait68901
	nop
	dbra	d0,wait68901
	move.l	mt_adrsave(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
newvbl
	bsr	mt_music
	rte

mt_init
	lea	mt_data(pc),a1
	move.l	a0,(a1)
	move.l	#472,d0
	move.l	#600,d1
	cmp.l	#$4d2e4b2e,1080(a0)
	bne.s	mt_oldversion
	move.l	#$3b8,d0
	move.l	#$43c,d1
mt_oldversion
	lea	mt_nbr1(pc),a1
	move.l	d0,2(a1)
	lea	mt_nbr2(pc),a1
	move.l	d1,2(a1)
	lea	mt_nbr3(pc),a1
	move.l	d0,2(a1)
	lea	mt_nbr4(pc),a1
	move.l	d1,2(a1)
	add.l	d0,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1
	move.l	d1,d2
	subq.w	#1,d0
mt_init2
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbra	d0,mt_init2
	addq.b	#1,d2

mt_init3
	move.l	mt_data(pc),a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
mt_nbr4	add.l	#0,d2
	add.l	a0,d2
	moveq	#30,d0
mt_init4
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#30,a0
	dbra	d0,mt_init4
	move.l	d2,a1
	move.l	mt_sample1(pc),a0
mt_init5
	eor.b	#128,(a0)
	tst.b	(a0)
	bne.s	mt_init6
	addq.b	#1,(a0)
mt_init6
	addq.l	#1,a0
	cmp.l	a0,a1
	bgt.s	mt_init5
	lea	mt_sample1(pc),a0
	moveq	#4,d0
mt_clear
	move.l	(a0,d0.w),a1
	clr.l	-4(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	mt_clear
	move.w	#$2700,sr
	lea	$ffff8800.w,a0
	moveq	#10,d0
mt_yamahaclear
	move.b	d0,(a0)
	clr.b	2(a0)
	dbra	d0,mt_yamahaclear
	clr.b	(a0)
	clr.b	2(a0)
	move.b	#7,(a0)
	move.b	#$ff,2(a0)
	move.b	#$02,$fffa19
	move.b	#14,$fffa1f
	bclr	#3,$fffa17
	bset	#5,$fffa07
	bset	#5,$fffa13
	lea	denise(pc),a0
	move.l	a0,$134.w
	lea	mt_partnrplay(pc),a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	(a0)
	lea	mt_cool(pc),a0
	move.w	#6,2(a0)
	move.l	mt_data(pc),a0
mt_nbr3	add.l	#$3b8,a0
	lea	mt_maxpart(pc),a1
	move.b	-2(a0),1(a1)
	lea	mt_cool(pc),a0
	move.b	#6,3(a0)
	move.b	$fb0001,d7
	lea	no_noise(pc),a2
	lea	voice1(pc),a3
	lea	voice2(pc),a4
	lea	voice3(pc),a5
	lea	voice4(pc),a6
	move.l	a2,16(a3)
	move.l	a2,16(a4)
	move.l	a2,16(a5)
	move.l	a2,16(a6)
	move.l	a2,a3
	move.l	a3,a4
	move.l	a4,a5
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	lea	$fa0000,a6
	lea	mt_selection(pc),a0
	moveq	#0,d6
	move.b	d7,d6
	and.b	#$f0,d6
	cmp.b	#$70,d6
	bne.s	mt_testbat
	move.w	#$601a,(a0)	
	move.w	#$2300,sr
	rts
mt_testbat
	cmp.b	#$ff,d7
	beq.s	mt_monitor_outpout
	move.w	#$6024,(a0)
	move.w	#$2300,sr
	rts
mt_monitor_outpout
	move.w	#$0246,(a0)
	move.w	#$2300,sr
	rts

mt_end
	bset	#3,$fffa17
	and.b	#$df,$fffa07
	and.b	#$df,$fffa13
	rts

; now the playroutine ! call it every vbl.

mt_music
	movem.l	d0/d1/a0/a1,-(sp)
	lea	mt_counter(pc),a0
	addq.w	#1,(a0)
mt_cool
	cmp.w	#6,(a0)
	bne.s	mt_notsix
	clr.w	(a0)
	bra	mt_rout2

mt_notsix
	lea	mt_aud1temp(pc),a1
	tst.b	3(a1)
	beq.s	mt_arp1
	lea	voice1(pc),a0
	bsr.s	mt_arprout
mt_arp1
	lea	mt_aud2temp(pc),a1
	tst.b	3(a1)
	beq.s	mt_arp2
	lea	voice2(pc),a0
	bsr.s	mt_arprout
mt_arp2
	lea	mt_aud3temp(pc),a1
	tst.b	3(a1)
	beq.s	mt_arp3
	lea	voice3(pc),a0
	bsr.s	mt_arprout	
mt_arp3
	lea	mt_aud4temp(pc),a1
	tst.b	3(a1)
	beq.s	mt_arp4
	lea	voice4(pc),a0
	bsr.s	mt_arprout
mt_arp4
	movem.l	(sp)+,d0/d1/a0/a1
	rts


mt_arprout
	move.b	2(a1),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpegrt
	cmp.b	#1,d0
	beq	mt_portup
	cmp.B	#2,d0
	beq	mt_portdown
	rts


mt_portup
	moveq	#0,d0
	move.b	3(a1),d0
	sub.w	d0,22(a1)
	cmp.w	#$71,22(a1)
	bpl.s	mt_ok1
	move.w	#$71,22(a1)
mt_ok1	move.w	22(a1),d0
	lea	mt_frequences(pc),a1
	asl.l	#2,d0
	move.l	(a1,d0.w),2(a0)
	rts

mt_portdown
	moveq	#0,d0
	move.b	3(a1),d0
	add.w	d0,22(a1)
	cmp.w	#$358,22(a1)
	bmi.s	mt_ok2
	move.w	#$358,22(a1)
mt_ok2	bra	mt_ok1


mt_arpegrt
	move.w	mt_counter(pc),d0
	cmp.w	#1,d0
	beq.s	mt_loop2
	cmp.w	#2,d0
	beq.s	mt_loop3
	cmp.w	#3,d0
	beq.s	mt_loop4
	cmp.w	#4,d0
	beq.s	mt_loop2
	cmp.w	#5,d0
	beq.s	mt_loop3
	rts

mt_loop2
	moveq	#0,d0
	move.b	3(a1),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3
	moveq	#0,d0
	move.b	3(a1),d0
	and.b	#$f,d0
	bra.s	mt_cont
mt_loop4
	moveq	#0,d1
	move.w	16(a1),d1
	bra.s	mt_endpart
mt_cont
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a1),d1
	and.w	#$fff,d1
	lea	mt_arpeggio(pc),a1
mt_loop5
	cmp.w	(a1),d1
	beq.s	loop5_exit
	addq.l	#2,a1
	bra.s	mt_loop5
loop5_exit
	move.w	(a1,d0.w),d1
mt_endpart
	lea	mt_frequences(pc),a1
	asl.l	#2,d1
	move.l	(a1,d1.w),2(a0)
	rts

mt_rout2
	move.l	mt_data(pc),a0
	lea	mt_soundpref(pc),a1
	move.l	a0,(a1)
	add.l	#42,(a1)
	move.l	a0,a1
mt_nbr1	add.l	#0,a1
mt_nbr2	add.l	#0,a0
	move.l	a1,-(sp)
	lea	mt_firstpattern(pc),a1
	move.l	a0,(a1)
	move.l	(sp)+,a1
	moveq	#0,d1
	move.l	mt_partnrplay(pc),d0
	move.b	(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	mt_partnote(pc),d1
	lea	mt_aud1temp(pc),a1
	bsr	mt_playit
	lea	mt_aud2temp(pc),a1
	move.l	mt_currentpos(pc),d1
	bsr	mt_playit
	lea	mt_aud3temp(pc),a1
	move.l	mt_currentpos(pc),d1
	bsr	mt_playit
	lea	mt_aud4temp(pc),a1
	move.l	mt_currentpos(pc),d1
	bsr	mt_playit
	move.w	#$2700,sr
mt_voice1
	lea	voice1(pc),a0
	lea	mt_aud1temp(pc),a1
	tst.w	(a1)
	beq.s	mt_voice2
; here is for equa inf
	move.l	a0,-(sp)
	lea	level1(pc),a0
	move.w	18(a1),(a0)
	move.l	(sp)+,a0
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#$fff,d0
	move.w	d0,16(a1)
	move.W	d0,22(a1)
	move.l	4(a1),a2
	moveq	#0,d2
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#$fff,d0
	asl.l	#2,d0
	move.l	a1,-(sp)
	lea	mt_frequences(pc),a1
	move.l	(a1,d0.w),2(a0)
	move.l	(sp)+,a1
	tst.w	14(a1)
	beq.s	mt_norepeat1
	move.l	10(a1),16(a0)
	bra.s	mt_voice2
mt_norepeat1
	lea	no_noise(pc),a1
	move.l	a1,16(a0)
mt_voice2
	lea	voice2(pc),a0
	lea	mt_aud2temp(pc),a1
	tst.w	(a1)
	beq.s	mt_voice3
; here is for equa inf
	move.l	a0,-(sp)
	lea	level2(pc),a0
	move.w	18(a1),(a0)
	move.l	(sp)+,a0
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#$fff,d0
	move.w	d0,16(a1)
	move.W	d0,22(a1)
	move.l	4(a1),a3
	moveq	#0,d3
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#$fff,d0
	asl.l	#2,d0
	move.l	a1,-(sp)
	lea	mt_frequences(pc),a1
	move.l	(a1,d0.w),2(a0)
	move.l	(sp)+,a1
	tst.w	14(a1)
	beq.s	mt_norepeat2
	move.l	10(a1),16(a0)
	bra.s	mt_voice3
mt_norepeat2
	lea	no_noise(pc),a1
	move.l	a1,16(a0)
mt_voice3
	lea	voice3(pc),a0
	lea	mt_aud3temp(pc),a1
	tst.w	(a1)
	beq.s	mt_voice4
; here is for equa inf
	move.l	a0,-(sp)
	lea	level3(pc),a0
	move.w	18(a1),(a0)
	move.l	(sp)+,a0
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#$fff,d0
	move.w	d0,16(a1)
	move.W	d0,22(a1)
	move.l	4(a1),a4
	moveq	#0,d4
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#$fff,d0
	asl.l	#2,d0
	move.l	a1,-(sp)
	lea	mt_frequences(pc),a1
	move.l	(a1,d0.w),2(a0)
	move.l	(sp)+,a1
	tst.w	14(a1)
	beq.s	mt_norepeat3
	move.l	10(a1),16(a0)
	bra.s	mt_voice4
mt_norepeat3
	lea	no_noise(pc),a1
	move.l	a1,16(a0)
mt_voice4
	lea	voice4(pc),a0
	lea	mt_aud4temp(pc),a1
	tst.w	(a1)
	beq.s	mt_voice0
; here is for equa inf
	move.l	a0,-(sp)
	lea	level4(pc),a0
	move.w	18(a1),(a0)
	move.l	(sp)+,a0
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#$fff,d0
	move.w	d0,16(a1)
	move.W	d0,22(a1)
	move.l	4(a1),a5
	moveq	#0,d5
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#$fff,d0
	asl.l	#2,d0
	move.l	a1,-(sp)
	lea	mt_frequences(pc),a1
	move.l	(a1,d0.w),2(a0)
	move.l	(sp)+,a1
	tst.w	14(a1)
	beq.s	mt_norepeat4
	move.l	10(a1),16(a0)
	bra.s	mt_voice0
mt_norepeat4
	lea	no_noise(pc),a1
	move.l	a1,16(a0)
mt_voice0
	move.w	#$2300,sr
	lea	mt_partnote(pc),a0
	add.l	#16,(a0)
	cmp.l	#64*16,(a0)
	bne	mt_nonewpat
mt_higher
	clr.l	(a0)
	lea	mt_partnrplay(pc),a0
	addq.l	#1,(a0)
	moveq	#0,d0
	move.w	mt_maxpart(pc),d0
	move.l	(a0),d1
	cmp.l	d0,d1
	bne.s	mt_nonewpat
	clr.l	(a0)
mt_nonewpat
	lea	mt_status(pc),a0
	tst.w	(a0)
	beq.s	mt_stop
	clr.w	(a0)
	lea	mt_partnote(pc),a0
	bra.s	mt_higher
mt_stop
	movem.l	(sp)+,d0/d1/a0/a1
	rts


mt_playit
	move.l	mt_firstpattern(pc),a0
	move.l	(a0,d1.l),(a1)
	addq.l	#4,d1
	lea	mt_currentpos(pc),a0
	move.l	d1,(a0)
	moveq	#0,d1
	move.b	2(a1),d1
	lsr.b	#4,d1
	moveq	#0,d0
	move.b	(a1),d0
	and.b	#$f0,d0
	or.b	d0,d1
	tst.b	d1
	beq	mt_nosamplechange
	move.l	d1,d0
	asl.l	#2,d1
	subq.b	#1,d0
	mulu	#30,d0
	lea	mt_samples(pc),a0
	move.l	(a0,d1.l),4(a1)
	move.l	mt_soundpref(pc),a0
	move.w	(a0,d0.l),8(a1)
	tst.w	8(a1)
	bne.s	mt_sample_exist
	move.l	a0,-(sp)
	lea	no_noise(pc),a0
	move.l	a0,4(a1)
	move.l	(sp)+,a0
mt_sample_exist
	moveq	#0,d1
	move.w	4(a0,d0.l),d1
	add.l	4(a1),d1
	move.l	d1,10(a1)
	move.w	6(a0,d0.l),14(a1)
	move.w	2(a0,d0.l),18(a1)
	cmp.w	#1,14(a1)
	bne	mt_nosamplechange
	clr.w	14(a1)
mt_nosamplechange
	moveq	#0,d0
	move.b	2(a1),d0
	and.w	#$f,d0
	cmp.b	#$0b,d0
	beq.s	mt_posjmp
	cmp.b	#$0c,d0
	beq.s	mt_setvol
	cmp.b	#$0d,d0
	beq.s	mt_break
	cmp.b	#$0e,d0
	beq.s	mt_setfil
	cmp.b	#$0f,d0
	beq.s	mt_setspeed
	rts

mt_posjmp
	lea	mt_status(pc),a0
	not.w	(a0)
	moveq	#0,d0
	move.b	3(a1),d0
	subq.b	#1,d0
	lea	mt_partnrplay(pc),a0
	move.l	d0,(a0)
	rts

mt_setvol
	; perhaps another time
	moveq	#0,d0
	move.b	3(a1),d0
	tst.b	d0
	bne	mt_back
	lea	no_noise(pc),a0
	move.l	a0,4(a1)
	move.w	#1,(a1)
	rts

mt_break
	lea	mt_status(pc),a0
	not.w	(a0)
	rts
mt_setfil
	; a filter ?? i would like have it !!!!
	rts
mt_setspeed
	move.b	3(a1),d0
	and.b	#$f,d0
	beq.s	mt_back
	lea	mt_counter(pc),a0
	clr.w	(a0)
	lea	mt_cool(pc),a0
	move.b	d0,3(a0)
mt_back	rts



;this is the emulation of amiga sound processor !

denise
	moveq	#0,d7
	moveq	#0,d6
voice1	add.l	#0,d2
	swap	d2
	move.b	(a2,d2.w),d7
	bne.s	no_ini1
	lea	$0,a2
	moveq	#0,d2
	moveq	#$7f,d7
no_ini1	add.w	d7,d6
voice2	add.l	#0,d3
	swap	d3
	move.b	(a3,d3.w),d7
	bne.s	no_ini2
	lea	$0,a3
	moveq	#0,d3
	moveq	#$7f,d7
no_ini2	add.w	d7,d6
voice3	add.l	#0,d4
	swap	d4
	move.b	(a4,d4.w),d7
	bne.s	no_ini3
	lea	$0,a4
	moveq	#0,d4
	moveq	#$7f,d7
no_ini3	add.w	d7,d6
voice4	add.l	#0,d5
	swap	d5
	move.b	(a5,d5.w),d7
	bne.s	no_ini4
	lea	$0,a5
	moveq	#0,d5
	moveq	#$7f,d7
no_ini4	add.w	d7,d6
	swap	d2
	swap	d3
	swap	d4
	swap	d5
mt_selection
	and.w	#$fffc,d6
	add.w	d6,d6
	lea	digitab(pc,d6.w),a6
	move.l	(a6)+,d6
	move.w	(a6)+,d7
	lea	$ffff8800.w,a6
	movep.l	d6,(a6)
	movep.w	d7,(a6)
	rte

st_replay
	lsr.w	#1,d6
	move.b	(a6,d6.w),d6
	rte
bat
	add.w	d6,d6
	add.w	d6,d6
	move.b	(a6,d6.w),d6
	rte





digitab		incbin	digitab.bin
	even
mt_aud1temp	ds.b	24
mt_aud2temp	ds.b	24
mt_aud3temp	ds.b	24
mt_aud4temp	ds.b	24
mt_partnrplay	ds.l	1
mt_partnote	ds.l	1
mt_firstpattern	ds.l	1
mt_counter	ds.w	1
mt_samples	ds.l	1
mt_sample1	ds.l	31
mt_maxpart	ds.w	1
mt_status	ds.w	1
mt_register	ds.l	1
mt_currentpos	ds.l	1
mt_soundpref	ds.l	1
mt_debpat	ds.l	1
mt_data		ds.l	1
mt_adrsave	ds.l	1
mt_arpeggio	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
		dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
		dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
		dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
		dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000
no_noise
	rept	512
	dc.l	$7f7f7f7f
	endr
	dc.l	0
mt_frequences
	dc.l	0
	incbin	freq.bin
fin
