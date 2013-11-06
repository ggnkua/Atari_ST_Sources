***************************************************************************
*
* PROC: MT_MUSIC		version: 0.000		date:	19/04/2013
*
*==========================================================================
* FUNCTION:
*	Protracker 2.X handler for Hacking Lance
* FILES:
*	- PTHDLxxx.S	this file
*==========================================================================
* HISTORY:
*--------------------------------------------------------------------------
*	DATE		TIME	FORM	PCS	COMMENTS	
*--------------------------------------------------------------------------
*	19/04/2013	10:00	C00??	0.000	First version
***************************************************************************
mt_music:
*****	movem.l	d0-d4/a0-a6,-(sp)

*	addq.b	#1,mt_counter
*	move.b	mt_counter(pc),d0
	lea	mt_counter(pc),a4
	addq.b	#1,(a4)
	move.b	(a4),d0

	cmp.b	mt_speed(pc),d0
	bcs.s	mt_nonewnote

*	clr.b	mt_counter
	clr.b	(a4)

*	tst.b	mt_pattdeltime2
	lea	mt_pattdeltime2(pc),a4
	tst.b	(a4)
	
	beq.s	mt_getnewnote
	bsr.s	mt_nonewallchannels
	bra	mt_dskip

mt_nonewnote
	bsr.s	mt_nonewallchannels
	bra	mt_nonewposyet

mt_nonewallchannels
	lea	mt_channel_0(pc),a5
	lea	mt_chan1temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_1(pc),a5
	lea	mt_chan2temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_2(pc),a5
	lea	mt_chan3temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_3(pc),a5
	lea	mt_chan4temp(pc),a6
	bra	mt_checkefx

mt_getnewnote
	move.l	mt_songdataptr(pc),a0
	lea	20-8(a0),a3
	lea	$3B8(a0),a2			pattern index list
	lea	$43C(a0),a0			patterns
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	0(a2,d0),d1
	lsl.l	#8,d1
	lsl.l	#2,d1
	add	mt_patternpos(pc),d1

	lea	mt_channel_0(pc),a5
	lea	mt_chan1temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_1(pc),a5
	lea	mt_chan2temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_2(pc),a5
	lea	mt_chan3temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_3(pc),a5
	lea	mt_chan4temp(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice
	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_pernop
mt_plvskip
	move.l	0(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move	d2,d4
	subq.l	#1,d2
	lsl.l	#2,d2
	mulu	#30,d4
	move.l	0(a1,d2.l),n_start(a6)
	move	0(a3,d4.l),n_length(a6)
	move	0(a3,d4.l),n_reallength(a6)
	move.b	2(a3,d4.l),n_finetune(a6)
	move.b	3(a3,d4.l),n_volume(a6)

**	move	4(a3,d4.l),d3 ; get repeat
	move	6(a3,d4.l),d3 ; get replen

	tst	d3
	beq.s	mt_noloop

	move	4(a3,d4.l),d3 ; get repeat

	move.l	n_start(a6),d2		; get start
	lsl	#1,d3
	add.l	d3,d2		; add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move	4(a3,d4.l),d0	; get repeat
	add	6(a3,d4.l),d0	; add replen
	move	d0,n_length(a6)
	move	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,mt_volume(a5)	; set volume
	bra.s	mt_setregs

mt_noloop
	move.l	n_start(a6),d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,mt_volume(a5)	; set volume

mt_setregs
	move	(a6),d0
	and	#$0FFF,d0
	beq	mt_checkmoreefx		if no note
	move	2(a6),d0
	and	#$0FF0,d0
	cmp	#$0E50,d0
	beq.s	mt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$0F,d0
	cmp.b	#3,d0			toneportamento
	beq.s	mt_chktoneporta
	cmp.b	#5,d0			toneportamento
	beq.s	mt_chktoneporta
	cmp.b	#9,d0			sample offset
	bne.s	mt_setperiod
	bsr	mt_checkmoreefx
	bra.s	mt_setperiod

mt_dosetfinetune
	bsr	mt_setfinetune
	bra.s	mt_setperiod

mt_chktoneporta
	bsr	mt_settoneporta
	bra	mt_checkmoreefx

mt_setperiod
	movem.l	d0-d1/a0-a1,-(sp)
	move	(a6),d1
	and	#$0FFF,d1
	lea	mt_periodtable(pc),a1
	moveq	#0,d0
	moveq	#36,d7
mt_ftuloop
	cmp	0(a1,d0),d1
	bcc.s	mt_ftufound
	addq.l	#2,d0
	dbf	d7,mt_ftuloop
mt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	add.l	d1,a1
	move	0(a1,d0),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move	2(a6),d0
	and	#$0FF0,d0
	cmp	#$0ed0,d0 ; notedelay
	beq	mt_checkmoreefx

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
*	move.l	n_start(a6),mt_sample_point(a5)	; set start
	move.l	n_start(a6),(a5)		; set start
	moveq	#0,d0
	move	n_length(a6),d0		; set length
	add.l	d0,d0
*	add.l	mt_sample_point(a5),d0
	add.l	(a5),d0
	move.l	d0,mt_sample_end(a5)

**	move.l	n_loopstart(a6),d0
**	cmp.l	mt_sample_point(a5),d0
**	bne.s	l_mt_set_loop0
**	moveq	#0,d0
**l_mt_set_loop0
**	move.l	d0,mt_loop_start(a5)

	moveq	#0,d0
	move	n_replen(a6),d0
	add.l	d0,d0
	move.l	d0,mt_loop_start(a5)

	move	n_period(a6),d0
	move	d0,mt_period(a5)		; set period

	bra	mt_checkmoreefx
 
mt_setdma
mt_dskip

*	add	#16,mt_patternpos
	lea	mt_patternpos(pc),a4
	add	#16,(a4)

	move.b	mt_pattdeltime(pc),d0
	beq.s	mt_dskc

*	move.b	d0,mt_pattdeltime2
	lea	mt_pattdeltime2(pc),a4
	move.b	d0,(a4)

*	clr.b	mt_pattdeltime
	lea	mt_pattdeltime(pc),a4
	clr.b	(a4)

mt_dskc

*	tst.b	mt_pattdeltime2
	lea	mt_pattdeltime2(pc),a4
	tst.b	(a4)

	beq.s	mt_dska

*	subq.b	#1,mt_pattdeltime2
	subq.b	#1,(a4)

	beq.s	mt_dska

*	sub	#16,mt_patternpos
	lea	mt_patternpos(pc),a4
	sub	#16,(a4)

mt_dska

*	tst.b	mt_pbreakflag
	lea	mt_pbreakflag(pc),a4
	tst.b	(a4)

	beq.s	mt_nnpysk

*	sf	mt_pbreakflag
	lea	mt_pbreakflag(pc),a4
	sf	(a4)

	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0

*	clr.b	mt_pbreakpos
	lea	mt_pbreakpos(pc),a4
	clr.b	(a4)

	lsl	#4,d0

*	move	d0,mt_patternpos
	lea	mt_patternpos(pc),a4
	move	d0,(a4)

mt_nnpysk

*	cmp	#1024,mt_patternpos
	lea	mt_patternpos(pc),a4
	cmp	#1024,(a4)

	bcs.s	mt_nonewposyet
mt_nextposition
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	lsl	#4,d0

*	move	d0,mt_patternpos
	lea	mt_patternpos(pc),a4
	move	d0,(a4)

*	clr.b	mt_pbreakpos
	lea	mt_pbreakpos(pc),a4
	clr.b	(a4)

*	clr.b	mt_posjumpflag
	lea	mt_posjumpflag(pc),a4
	clr.b	(a4)

*	addq.b	#1,mt_songpos
*	and.b	#$7f,mt_songpos
	lea	mt_songpos(pc),a4
	addq.b	#1,(a4)
	and.b	#$7f,(a4)

	move.b	mt_songpos(pc),d1
	move.l	mt_songdataptr(pc),a0
	cmp.b	$3B6(a0),d1
	bcs.s	mt_nonewposyet

*	clr.b	mt_songpos
	clr.b	(a4)

mt_nonewposyet

*	tst.b	mt_posjumpflag
	lea	mt_posjumpflag(pc),a4
	tst.b	(a4)

	bne.s	mt_nextposition
*****	movem.l	(sp)+,d0-d4/a0-a6
	rts

mt_checkefx
	bsr	mt_updatefunk
	move	2(a6),d0
	and	#$0FFF,d0
	beq.s	mt_pernop
	move.b	2(a6),d0
	and.b	#$0F,d0
	beq.s	mt_arpeggio
	cmp.b	#1,d0
	beq	mt_portaup
	cmp.b	#2,d0
	beq	mt_portadown
	cmp.b	#3,d0
	beq	mt_toneportamento
	cmp.b	#4,d0
	beq	mt_vibrato
	cmp.b	#5,d0
	beq	mt_toneplusvolslide
	cmp.b	#6,d0
	beq	mt_vibratoplusvolslide
	cmp.b	#$E,d0
	beq	mt_E_commands
setback
	move	n_period(a6),mt_period(a5)
	cmp.b	#7,d0
	beq	mt_tremolo
	cmp.b	#$A,d0
	beq	mt_volumeslide
mt_return2
	rts

mt_pernop
	move	n_period(a6),mt_period(a5)
	rts

mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp	#0,d0
	beq.s	mt_arpeggio2
	cmp	#2,d0
	beq.s	mt_arpeggio1
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arpeggio3

mt_arpeggio1
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#15,d0
	bra.s	mt_arpeggio3

mt_arpeggio2
	move	n_period(a6),d2
	bra.s	mt_arpeggio4

mt_arpeggio3
	lsl	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	lea	mt_periodtable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move	n_period(a6),d1
	moveq	#36,d7
mt_arploop
	move	0(a0,d0),d2
	cmp	(a0),d1
	bcc.s	mt_arpeggio4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts

mt_arpeggio4
	move	d2,mt_period(a5)
	rts

mt_fineportaup
*	tst.b	mt_counter
	lea	mt_counter(pc),a4
	tst.b	(a4)

	bne.s	mt_return2
*	move.b	#$0F,mt_lowmask
	lea	mt_lowmask(pc),a4
	move.b	#$0F,(a4)

mt_portaup
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	mt_lowmask(pc),d0

*	move.b	#$FF,mt_lowmask
	lea	mt_lowmask(pc),a4
	move.b	#$FF,(a4)

	sub	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$0FFF,d0
	cmp	#$0071,d0
	bpl.s	mt_portauskip
	and	#$F000,n_period(a6)
	or	#$0071,n_period(a6)
mt_portauskip
	move	n_period(a6),d0
	and	#$0FFF,d0
	move	d0,mt_period(a5)
	rts
 
mt_fineportadown
*	tst.b	mt_counter
	lea	mt_counter(pc),a4
	tst.b	(a4)

	bne	mt_return2

*	move.b	#$0F,mt_lowmask
	lea	mt_lowmask(pc),a4
	move.b	#$0F,(a4)

mt_portadown
	clr	d0
	move.b	3(a6),d0
	and.b	mt_lowmask(pc),d0

*	move.b	#$FF,mt_lowmask
	lea	mt_lowmask(pc),a4
	move.b	#$FF,(a4)

	add	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$0FFF,d0
	cmp	#$0358,d0
	bmi.s	mt_portadskip
	and	#$F000,n_period(a6)
	or	#$0358,n_period(a6)
mt_portadskip
	move	n_period(a6),d0
	and	#$0FFF,d0
	move	d0,mt_period(a5)
	rts

mt_settoneporta
	move.l	a0,-(sp)
	move	(a6),d2
	and	#$0FFF,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
**	mulu	#37*2,d0
	mulu	#36*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp	0(a0,d0),d2
	bcc.s	mt_stpfound
	addq	#2,d0
**	cmp	#37*2,d0
	cmp	#36*2,d0
	bcs.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_stpgoss
	tst	d0
	beq.s	mt_stpgoss
	subq	#2,d0
mt_stpgoss
	move	0(a0,d0),d2
	move.l	(sp)+,a0
	move	d2,n_wantedperiod(a6)
	move	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp	d0,d2
	beq.s	mt_cleartoneporta
	bge	mt_return2
	move.b	#1,n_toneportdirec(a6)
	rts

mt_cleartoneporta
	clr	n_wantedperiod(a6)
	rts

mt_toneportamento
	move.b	3(a6),d0
	beq.s	mt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	3(a6)
mt_toneportnochange
	tst	n_wantedperiod(a6)
	beq	mt_return2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_toneportaup
mt_toneportadown
	add	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	bgt.s	mt_toneportasetper
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)
	bra.s	mt_toneportasetper

mt_toneportaup
	sub	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	blt.s	mt_toneportasetper
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)

mt_toneportasetper
	move	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0F,d0
	beq.s	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#36*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp	0(a0,d0),d2
	bcc.s	mt_glissfound
	addq	#2,d0
	cmp	#36*2,d0
	bcs.s	mt_glissloop
	moveq	#35*2,d0
mt_glissfound
	move	0(a0,d0),d2
mt_glissskip
	move	d2,mt_period(a5) ; set period
	rts

mt_vibrato
	move.b	3(a6),d0
	beq.s	mt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0F,d0
	beq.s	mt_vibskip
	and.b	#$F0,d2
	or.b	d0,d2
mt_vibskip
	move.b	3(a6),d0
	and.b	#$F0,d0
	beq.s	mt_vibskip2
	and.b	#$0F,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr	#2,d0
	and	#$001F,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.s	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_vib_rampdown
	move.b	#255,d2
	bra.s	mt_vib_set
mt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_vib_set
mt_vib_rampdown2
	move.b	d0,d2
	bra.s	mt_vib_set
mt_vib_sine
	move.b	0(a4,d0),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and	#15,d0
	mulu	d0,d2
	lsr	#7,d2
	move	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_vibratoneg
	add	d2,d0
	bra.s	mt_vibrato3
mt_vibratoneg
	sub	d2,d0
mt_vibrato3
	move	d0,mt_period(a5)
	move.b	n_vibratocmd(a6),d0
	lsr	#2,d0
	and	#$003C,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_toneplusvolslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide

mt_vibratoplusvolslide
	bsr.s	mt_vibrato2
	bra	mt_volumeslide

mt_tremolo
	move.b	3(a6),d0
	beq.s	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0F,d0
	beq.s	mt_treskip
	and.b	#$F0,d2
	or.b	d0,d2
mt_treskip
	move.b	3(a6),d0
	and.b	#$F0,d0
	beq.s	mt_treskip2
	and.b	#$0F,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr	#2,d0
	and	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b	#255,d2
	bra.s	mt_tre_set
mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.s	mt_tre_set
mt_tre_sine
	move.b	0(a4,d0),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and	#$000F,d0
	mulu	d0,d2
	lsr	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_tremoloneg
	add	d2,d0
	bra.s	mt_tremolo3
mt_tremoloneg
	sub	d2,d0
mt_tremolo3
	bpl.s	mt_tremoloskip
	clr	d0
mt_tremoloskip
	cmp	#$40,d0
	bls.s	mt_tremolook
	move	#$40,d0
mt_tremolook
	move	d0,mt_volume(a5)
	move.b	n_tremolocmd(a6),d0
	lsr	#2,d0
	and	#$003C,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_sampleoffset
	moveq	#0,d0
	move.b	3(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl	#7,d0
	cmp	n_length(a6),d0
	bge.s	mt_sofskip
	sub	d0,n_length(a6)
	lsl	#1,d0
	add.l	d0,n_start(a6)
	add.l	n_loopstart(a6),d0
	cmp.l	n_start(a6),d0
	ble.s	l_mt_set_loop1
	move.l	n_loopstart(a6),d0
l_mt_set_loop1
	move.l	d0,n_loopstart(a6)
	rts
mt_sofskip
	move	#$0001,n_length(a6)
	rts

mt_volumeslide
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_volslidedown
mt_volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move	d0,mt_volume(a5)
	rts

mt_volslidedown
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
mt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move	d0,mt_volume(a5)
	rts

mt_positionjump
	move.b	3(a6),d0
	subq.b	#1,d0

*	move.b	d0,mt_songpos
	lea	mt_songpos(pc),a4
	move.b	d0,(a4)

mt_pj2

*	clr.b	mt_pbreakpos
	lea	mt_pbreakpos(pc),a4
	clr.b	(a4)

*	st 	mt_posjumpflag
	lea	mt_posjumpflag(pc),a4
	st	(a4)

	rts

mt_volumechange
	moveq	#0,d0
	move.b	3(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move	d0,mt_volume(a5)
	rts

mt_patternbreak
	moveq	#0,d0
	move.b	3(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0F,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2

*	move.b	d0,mt_pbreakpos
	lea	mt_pbreakpos(pc),a4
	move.b	d0,(a4)

*	st	mt_posjumpflag
	lea	mt_posjumpflag(pc),a4
	st	(a4)

	rts

mt_setspeed
	move.b	3(a6),d0
	beq	mt_return2

*	clr.b	mt_counter
	lea	mt_counter(pc),a4
	clr.b	(a4)

*	move.b	d0,mt_speed
	lea	mt_speed(pc),a4
	move.b	d0,(a4)	

	rts

mt_checkmoreefx
	bsr	mt_updatefunk
	move.b	2(a6),d0
	and.b	#$0F,d0
	cmp.b	#$9,d0
	beq	mt_sampleoffset
	cmp.b	#$B,d0
	beq	mt_positionjump
	cmp.b	#$D,d0
	beq.s	mt_patternbreak
	cmp.b	#$E,d0
	beq.s	mt_E_commands
	cmp.b	#$F,d0
	beq.s	mt_setspeed
	cmp.b	#$C,d0
	beq	mt_volumechange
	bra	mt_pernop

mt_E_commands
	move.b	3(a6),d0
	and.b	#$F0,d0
	lsr.b	#4,d0
	beq.s	mt_filteronoff
	cmp.b	#1,d0
	beq	mt_fineportaup
	cmp.b	#2,d0
	beq	mt_fineportadown
	cmp.b	#3,d0
	beq.s	mt_setglisscontrol
	cmp.b	#4,d0
	beq.s	mt_setvibratocontrol
	cmp.b	#5,d0
	beq.s	mt_setfinetune
	cmp.b	#6,d0
	beq.s	mt_jumploop
	cmp.b	#7,d0
	beq	mt_settremolocontrol
	cmp.b	#9,d0
	beq	mt_retrignote
	cmp.b	#$A,d0
	beq	mt_volumefineup
	cmp.b	#$B,d0
	beq	mt_volumefinedown
	cmp.b	#$C,d0
	beq	mt_notecut
	cmp.b	#$D,d0
	beq	mt_notedelay
	cmp.b	#$E,d0
	beq	mt_patterndelay
	cmp.b	#$F,d0
	beq	mt_funkit
	rts

mt_filteronoff
	rts

mt_setglisscontrol
	move.b	3(a6),d0
	and.b	#$0F,d0
	and.b	#$F0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_setvibratocontrol
	move.b	3(a6),d0
	and.b	#$0F,d0
	and.b	#$F0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_setfinetune
	move.b	3(a6),d0
	and.b	#$0F,d0
	move.b	d0,n_finetune(a6)
	rts

mt_jumploop
*	tst.b	mt_counter
	lea	mt_counter(pc),a4
	tst.b	(a4)

	bne	mt_return2
	move.b	3(a6),d0
	and.b	#$0F,d0
	beq.s	mt_setloop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_return2
mt_jmploop

*	move.b	n_pattpos(a6),mt_pbreakpos
	lea	mt_pbreakpos(pc),a4
	move.b	n_pattpos(a6),(a4)

*	st	mt_pbreakflag
	lea	mt_pbreakflag(pc),a4
	st	(a4)

	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_setloop
	move	mt_patternpos(pc),d0
	lsr	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_settremolocontrol
	move.b	3(a6),d0
	and.b	#$0F,d0
	lsl.b	#4,d0
	and.b	#$0F,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_retrignote
	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
	beq.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.s	mt_rtnskp
	move	(a6),d1
	and	#$0FFF,d1
	bne.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
mt_rtnskp
	divu	d0,d1
	swap	d1
	tst	d1
	bne.s	mt_rtnend
mt_doretrig
*	move.l	n_start(a6),mt_sample_point(a5)	; set sampledata pointer
	move.l	n_start(a6),(a5)		; set sampledata pointer
	moveq	#0,d0
	move	n_length(a6),d0		; set length
	add.l	d0,d0
*	add.l	mt_sample_point(a5),d0
	add.l	(a5),d0
	move.l	d0,mt_sample_end(a5)

**	move.l	n_loopstart(a6),d0
**	cmp.l	mt_sample_point(a5),d0
**	bne.s	l_mt_set_loop2
**	moveq	#0,d0
**l_mt_set_loop2
**	move.l	d0,mt_loop_start(a5)

	moveq	#0,d0
	move	n_replen(a6),d0
	add.l	d0,d0
	move.l	d0,mt_loop_start(a5)

mt_rtnend
	move.l	(sp)+,d1
	rts

mt_volumefineup
*	tst.b	mt_counter
	lea	mt_counter(pc),a4
	tst.b	(a4)

	bne	mt_return2
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
	bra	mt_volslideup

mt_volumefinedown
*	tst.b	mt_counter
	lea	mt_counter(pc),a4
	tst.b	(a4)

	bne	mt_return2
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
	bra	mt_volslidedown2

mt_notecut
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	clr.b	n_volume(a6)
	move	#0,mt_volume(a5)
	rts

mt_notedelay
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	move	(a6),d0
	beq	mt_return2
	move.l	d1,-(sp)
	bra	mt_doretrig

mt_patterndelay
*	tst.b	mt_counter
	lea	mt_counter(pc),a4
	tst.b	(a4)

	bne	mt_return2
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0F,d0

*	tst.b	mt_pattdeltime2
	lea	mt_pattdeltime2(pc),a4
	tst.b	(a4)

	bne	mt_return2
	addq.b	#1,d0

*	move.b	d0,mt_pattdeltime
	lea	mt_pattdeltime(pc),a4
	move.b	d0,(a4)

	rts

mt_funkit
*	tst.b	mt_counter
	lea	mt_counter(pc),a4
	tst.b	(a4)

	bne	mt_return2
	move.b	3(a6),d0
	and.b	#$0F,d0
	lsl.b	#4,d0
	and.b	#$0F,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_return2
mt_updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_funkend
	lea	mt_funktable(pc),a0
	move.b	0(a0,d0),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
	clr.b	n_funkoffset(a6)

	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	bcs.s	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
mt_funkend
	movem.l	(sp)+,a0/d1
	rts

mt_funktable
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_vibratotable
	dc.b 0,24,49,74,97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120,97,74,49,24

mt_periodtable
; tuning 0, normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,$3ff0000,$00010000,0,0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,$3ff0000,$00020000,0,0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,$3ff0000,$00040000,0,0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,$3ff0000,$00080000,0,0,0,0,0

mt_samplestarts
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_songdataptr	dc.l	0
mt_module_end	dc.l	0

mt_speed	dc.b	6
mt_counter	dc.b	0
mt_songpos	dc.b	0
mt_pbreakpos	dc.b	0
mt_posjumpflag	dc.b	0
mt_pbreakflag	dc.b	0
mt_lowmask	dc.b	0
mt_pattdeltime	dc.b	0
mt_pattdeltime2	dc.b	0,0

mt_patternpos	dc.w	0

n_note		equ	0  ; w
n_cmd		equ	2  ; w
n_cmdlo		equ	3  ; b
n_start		equ	4  ; l
n_length	equ	8  ; w
n_loopstart	equ	10 ; l
n_replen	equ	14 ; w
n_period	equ	16 ; w
n_finetune	equ	18 ; b
n_volume	equ	19 ; b
n_dmabit	equ	20 ; w
n_toneportdirec	equ	22 ; b
n_toneportspeed	equ	23 ; b
n_wantedperiod	equ	24 ; w
n_vibratocmd	equ	26 ; b
n_vibratopos	equ	27 ; b
n_tremolocmd	equ	28 ; b
n_tremolopos	equ	29 ; b
n_wavecontrol	equ	30 ; b
n_glissfunk	equ	31 ; b
n_sampleoffset	equ	32 ; b
n_pattpos	equ	33 ; b
n_loopcount	equ	34 ; b
n_funkoffset	equ	35 ; b
n_wavestart	equ	36 ; l
n_reallength	equ	40 ; w

***************************************************************************
