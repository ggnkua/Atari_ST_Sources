***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Track 1 - proc. odgrywajaca moduly przez Timer A (25 Khz) *
* autor      :  Lancy                                                     *
* inne uwagi :  Nie dziala na ST                                          *
***************************************************************************

		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

		bsr	mt_init
		bsr	init_inter
		move.l	#VBL,$70

T:		bra		T

END:
		bsr	stop_inter
		bsr	mt_end
		clr.w	-(sp)
		trap	#1
		rts

wait_sync	
		clr.w	sync
.wait_sync	
		tst.w	sync
		beq.s	.wait_sync
		rts

*-------------------------------------------------------------------------*

VBL:
		bsr	wait_sync
		cmp.b	#57,$fffc02
		beq		END
		rte

*-------------------------------------------------------------------------*

init_inter	
		lea	$fffffa00.w,a6
		move.w	#$2700,sr
		lea	save_eab,a0
		movep.w	$7(a6),d0
		move.w	d0,(a0)

		lea	save_mab,a0
		movep.w	$13(a6),d0
		move.w	d0,(a0)

		moveq	#$20,d0
		or.b	d0,$7(a6)
		or.b	d0,$13(a6)

		bclr.b	#5,$f(a6)

		lea	save_TimerA,a0
		move.l	$134.w,(a0)
		lea	TimerA,a0
		move.l	a0,$134.w

		lea	save_TADR,a0
		move.b	$1f(a6),(a0)
		lea	save_TACR,a0
		move.b	$19(a6),(a0)

		move.b	#1,$1f(a6)
		move.b	#8,$19(a6)

		move.l	$70,pam

		move.l	mt_physic_buf,d0
		lea	$ffff8900.w,a0
		movep.l	d0,$1(a0)
		add.l	mt_buf_length,d0
		movep.l	d0,$d(a0)
		move.w	mt_frequency,$20(a0)
		move.w	#1,(a0)
		move.w	#$2300,sr
		move.l	#VBL,$70
		rts

stop_inter	
		move.w	#$2700,sr
		move.l	pam,$70
		lea	$fffffa00.w,a6
	
		move.w	save_eab,d0	
		movep.w	d0,$7(a6)
 
		move.w	save_mab,d0
		movep.w	d0,$13(a6)

		move.l	save_TimerA,$134.w
		move.b	save_TADR,$1f(a6)
		move.b	save_TACR,$19(a6)
		move.w	#$2300,sr
		clr.w	$ffff8900.w
		rts

TimerA	
		movem.l	d0-d7/a0-a6,-(sp)
		lea	sync,a0
		move.w	#$ffff,(a0)
		bclr.b	#5,$fffffa0f.w
		bsr	mt_Paula
		bsr	mt_music
		movem.l	(sp)+,d0-d7/a0-a6
		rte

sync		dc.w	0
save_eab	dc.w	0
save_mab	dc.w	0
save_TACR	dc.w	0
save_TADR	dc.w	0
save_TimerA	dc.l	0
pam:		dc.l	1

n_note	equ	0  ; w
n_cmd	equ	2  ; w
n_cmdlo	equ	3  ; b
n_start	equ	4  ; l
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
	section	text
mt_init	lea	mt_data,a0
	move.l	a0,mt_songdataptr
	move.l	a0,a1
	lea	952(a1),a1
	moveq	#127,d0
	moveq	#0,d1
mtloop	move.l	d1,d2
	subq.w	#1,d0
mtloop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mtloop
	dbra	d0,mtloop2
	addq.b	#1,d2
	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#1084,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#30,d0
	moveq	#0,d2
	lea	42(a0),a0
mtloop3	clr.l	(a2)
	move.l	a2,d1
	add.l	d2,d1
	move.l	d1,(a1)+
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.w	#640,d2
	tst.w	4(a0)
	bne.s	.mt_no_test
	cmp.w	#1,6(a0)
	ble.s	.mt_no_test
	subq.w	#1,6(a0)
	move.w	#1,4(a0)
.mt_no_test	add.l	#30,a0
	dbra	d0,mtloop3
	add.w	d2,a2
	lea	mt_module_end,a1
	move.l	a2,(a1)
	move.b	#6,mt_speed
	move.b	#6,mt_counter
	clr.b	mt_songpos
	clr.w	mt_patternpos
	lea	-31*640(a2),a1
	moveq	#30,d7
mt_init_loops	sub.w	#30,a0
	lea	-640(a2),a2
	lea	(a2),a3
	move.w	(a0),d0
	beq.s	.mt_just_loop
	subq.w	#1,d0
.mt_copy_spl	move.w	-(a1),-(a2)
	dbra	d0,.mt_copy_spl
.mt_just_loop	moveq	#0,d0
	move.w	4(a0),d0
	sne	d1
	andi.w	#$4,d1
	move.l	mt_loop_point(pc,d1.w),a4
	jsr	(a4)
	dbra	d7,mt_init_loops
	bsr	mt_init_Paula
	rts
mt_end	bsr	mt_stop_Paula
	rts
mt_loop_point	dc.l	.mt_no_loop
	dc.l	.mt_yes_loop
.mt_no_loop	move.w	#640/4-1,d0
.mt_clear_loop	clr.l	(a3)+
	dbra	d0,.mt_clear_loop
	rts
.mt_yes_loop	add.l	d0,d0
	lea	(a2,d0.l),a4
	lea	(a4),a5
	moveq	#0,d1
	move.w	4(a0),d1
	add.w	6(a0),d1
	move.w	d1,(a0)
	add.l	d1,d1
	lea	(a2,d1.l),a3
	move.w	6(a0),d1
	move.w	#320-1,d2
.mt_loop_loop	move.w	(a4)+,(a3)+
	subq.w	#1,d1
	bne.s	.mt_no_restart
	lea	(a5),a4
	move.w	6(a0),d1
.mt_no_restart	dbra	d2,.mt_loop_loop
	rts
mt_music	movem.l	d0-d4/a0-a6,-(sp)
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blo.s	mt_nonewnote
	clr.b	mt_counter
	tst.b	mt_pattdeltime2
	beq.s	mt_getnewnote
	bsr.s	mt_nonewallchannels
	bra	mt_dskip
mt_nonewnote
	bsr.s	mt_nonewallchannels
	bra	mt_nonewposyet
mt_nonewallchannels
	lea	mt_channel_0,a5
	lea	mt_chan1temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_1,a5
	lea	mt_chan2temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_2,a5
	lea	mt_chan3temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_3,a5
	lea	mt_chan4temp(pc),a6
	bra	mt_checkefx
mt_getnewnote
	move.l	mt_songdataptr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_patternpos(pc),d1
	clr.w	mt_dmacontemp
	lea	mt_channel_0,a5
	lea	mt_chan1temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_1,a5
	lea	mt_chan2temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_2,a5
	lea	mt_chan3temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_3,a5
	lea	mt_chan4temp(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma
mt_playvoice	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_pernop
mt_plvskip	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move	d2,d4
	subq.l	#1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l	(a1,d2.l),n_start(a6)
	move.w	(a3,d4.l),n_length(a6)
	move.w	(a3,d4.l),n_reallength(a6)
	move.b	2(a3,d4.l),n_finetune(a6)
	move.b	3(a3,d4.l),n_volume(a6)
	move.w	4(a3,d4.l),d3 ; get repeat
	tst.w	d3
	beq.s	mt_noloop
	move.l	n_start(a6),d2		; get start
	asl.w	#1,d3
	add.l	d3,d2		; add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	4(a3,d4.l),d0	; get repeat
	add.w	6(a3,d4.l),d0	; add replen
	move.w	d0,n_length(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)	; set volume
	bra.s	mt_setregs
mt_noloop	move.l	n_start(a6),d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)	; set volume
mt_setregs	move.w	(a6),d0
	and.w	#$0fff,d0
	beq	mt_checkmoreefx	; if no note
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0
	beq.s	mt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0	; toneportamento
	beq.s	mt_chktoneporta
	cmp.b	#5,d0
	beq.s	mt_chktoneporta
	cmp.b	#9,d0	; sample offset
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
	move.w	(a6),d1
	and.w	#$0fff,d1
	lea	mt_periodtable(pc),a1
	moveq	#0,d0
	moveq	#36,d7
mt_ftuloop	cmp.w	(a1,d0.w),d1
	bhs.s	mt_ftufound
	addq.l	#2,d0
	dbra	d7,mt_ftuloop
mt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	add.l	d1,a1
	move.w	(a1,d0.w),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0
	beq	mt_checkmoreefx
	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),(a5)
	moveq	#0,d0
	move.w	n_length(a6),d0	
	add.l	d0,d0
	add.l	(a5),d0
	move.l	d0,8(a5)
	move.l	n_loopstart(a6),d0
	cmp.l	(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	move.l	d0,4(a5)
	move.w	n_period(a6),d0
	move.w	d0,14(a5)		
	move.w	n_dmabit(a6),d0
	or.w	d0,mt_dmacontemp
	bra	mt_checkmoreefx
mt_setdma
mt_dskip	add.w	#16,mt_patternpos
	move.b	mt_pattdeltime,d0
	beq.s	mt_dskc
	move.b	d0,mt_pattdeltime2
	clr.b	mt_pattdeltime
mt_dskc	tst.b	mt_pattdeltime2
	beq.s	mt_dska
	subq.b	#1,mt_pattdeltime2
	beq.s	mt_dska
	sub.w	#16,mt_patternpos
mt_dska	tst.b	mt_pbreakflag
	beq.s	mt_nnpysk
	sf	mt_pbreakflag
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	clr.b	mt_pbreakpos
	lsl.w	#4,d0
	move.w	d0,mt_patternpos
mt_nnpysk	cmp.w	#1024,mt_patternpos
	blo.s	mt_nonewposyet
mt_nextposition	
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	lsl.w	#4,d0
	move.w	d0,mt_patternpos
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos(pc),d1
	move.l	mt_songdataptr(pc),a0
	cmp.b	950(a0),d1
	blo.s	mt_nonewposyet
	clr.b	mt_songpos
mt_nonewposyet	
	tst.b	mt_posjumpflag
	bne.s	mt_nextposition
	movem.l	(sp)+,d0-d4/a0-a6
	rts
mt_checkefx
	bsr	mt_updatefunk
	move.w	n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.s	mt_pernop
	move.b	n_cmd(a6),d0
	and.b	#$0f,d0
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
	cmp.b	#$e,d0
	beq	mt_e_commands
setback	move.w	n_period(a6),14(a5)
	cmp.b	#7,d0
	beq	mt_tremolo
	cmp.b	#$a,d0
	beq	mt_volumeslide
mt_return2
	rts
mt_pernop
	move.w	n_period(a6),14(a5)
	rts
mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	mt_arpeggio2
	cmp.w	#2,d0
	beq.s	mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arpeggio3
mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	mt_arpeggio3
mt_arpeggio2
	move.w	n_period(a6),d2
	bra.s	mt_arpeggio4
mt_arpeggio3
	asl.w	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	lea	mt_periodtable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move.w	n_period(a6),d1
	moveq	#36,d7
mt_arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	mt_arpeggio4
	addq.l	#2,a0
	dbra	d7,mt_arploop
	rts
mt_arpeggio4	move.w	d2,14(a5)
	rts
mt_fineportaup
	tst.b	mt_counter
	bne.s	mt_return2
	move.b	#$0f,mt_lowmask
mt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	sub.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#113,d0
	bpl.s	mt_portauskip
	and.w	#$f000,n_period(a6)
	or.w	#113,n_period(a6)
mt_portauskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,14(a5)
	rts	
mt_fineportadown
	tst.b	mt_counter
	bne	mt_return2
	move.b	#$0f,mt_lowmask
mt_portadown
	clr.w	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	add.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#856,d0
	bmi.s	mt_portadskip
	and.w	#$f000,n_period(a6)
	or.w	#856,n_period(a6)
mt_portadskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,14(a5)
	rts
mt_settoneporta
	move.l	a0,-(sp)
	move.w	(a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_stpfound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_stpgoss
	tst.w	d0
	beq.s	mt_stpgoss
	subq.w	#2,d0
mt_stpgoss
	move.w	(a0,d0.w),d2
	move.l	(sp)+,a0
	move.w	d2,n_wantedperiod(a6)
	move.w	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.s	mt_cleartoneporta
	bge	mt_return2
	move.b	#1,n_toneportdirec(a6)
	rts
mt_cleartoneporta
	clr.w	n_wantedperiod(a6)
	rts
mt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.s	mt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_toneportnochange
	tst.w	n_wantedperiod(a6)
	beq	mt_return2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_toneportaup
mt_toneportadown
	add.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	mt_toneportasetper
mt_toneportaup
	sub.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
mt_toneportasetper
	move.w	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#36*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_glissfound
	addq.w	#2,d0
	cmp.w	#36*2,d0
	blo.s	mt_glissloop
	moveq	#35*2,d0
mt_glissfound
	move.w	(a0,d0.w),d2
mt_glissskip
	move.w	d2,14(a5) ; set period
	rts
mt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	mt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
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
	move.b	0(a4,d0.w),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_vibratoneg
	add.w	d2,d0
	bra.s	mt_vibrato3
mt_vibratoneg
	sub.w	d2,d0
mt_vibrato3
	move.w	d0,14(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_vibratopos(a6)
	rts
mt_toneplusvolslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide
mt_vibratoplusvolslide
	bsr.s	mt_vibrato2
	bra	mt_volumeslide
mt_tremolo
	move.b	n_cmdlo(a6),d0
	beq.s	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
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
	move.b	0(a4,d0.w),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_tremoloneg
	add.w	d2,d0
	bra.s	mt_tremolo3
mt_tremoloneg
	sub.w	d2,d0
mt_tremolo3
	bpl.s	mt_tremoloskip
	clr.w	d0
mt_tremoloskip
	cmp.w	#$40,d0
	bls.s	mt_tremolook
	move.w	#$40,d0
mt_tremolook
	move.w	d0,12(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	rts
mt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	add.l	n_loopstart(a6),d0
	cmp.l	n_start(a6),d0
	ble.s	.mt_set_loop
	move.l	n_loopstart(a6),d0
.mt_set_loop	move.l	d0,n_loopstart(a6)
	rts
mt_sofskip	move.w	#$0001,n_length(a6)
	rts
mt_volumeslide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
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
	move.w	d0,12(a5)
	rts
mt_volslidedown
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
mt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)
	rts
mt_positionjump
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
mt_pj2	clr.b	mt_pbreakpos
	st 	mt_posjumpflag
	rts
mt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move.w	d0,12(a5)
	rts
mt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b	d0,mt_pbreakpos
	st	mt_posjumpflag
	rts
mt_setspeed
	move.b	3(a6),d0
	beq	mt_return2
	clr.b	mt_counter
	move.b	d0,mt_speed
	rts
mt_checkmoreefx
	bsr	mt_updatefunk
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$9,d0
	beq	mt_sampleoffset
	cmp.b	#$b,d0
	beq	mt_positionjump
	cmp.b	#$d,d0
	beq.s	mt_patternbreak
	cmp.b	#$e,d0
	beq.s	mt_e_commands
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	cmp.b	#$c,d0
	beq	mt_volumechange
	bra	mt_pernop
mt_e_commands
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
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
	cmp.b	#$a,d0
	beq	mt_volumefineup
	cmp.b	#$b,d0
	beq	mt_volumefinedown
	cmp.b	#$c,d0
	beq	mt_notecut
	cmp.b	#$d,d0
	beq	mt_notedelay
	cmp.b	#$e,d0
	beq	mt_patterndelay
	cmp.b	#$f,d0
	beq	mt_funkit
	rts
mt_filteronoff	rts	
mt_setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts
mt_setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts
mt_setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	rts
mt_jumploop
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_setloop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_return2
mt_jmploop	move.b	n_pattpos(a6),mt_pbreakpos
	st	mt_pbreakflag
	rts
mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop
mt_setloop
	move.w	mt_patternpos(pc),d0
	lsr.w	#4,d0
	move.b	d0,n_pattpos(a6)
	rts
mt_settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts
mt_retrignote	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.s	mt_rtnskp
	move.w	(a6),d1
	and.w	#$0fff,d1
	bne.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
mt_rtnskp	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	mt_rtnend
mt_doretrig	move.l	n_start(a6),(a5)
	moveq	#0,d0
	move.w	n_length(a6),d0	
	add.l	d0,d0
	add.l	(a5),d0
	move.l	d0,8(a5)
	move.l	n_loopstart(a6),d0
	cmp.l	(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	move.l	d0,4(a5)
mt_rtnend	move.l	(sp)+,d1
	rts
mt_volumefineup
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	mt_volslideup
mt_volumefinedown
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_volslidedown2
mt_notecut
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	clr.b	n_volume(a6)
	move.w	#0,12(a5)
	rts
mt_notedelay
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne	mt_return2
	move.w	(a6),d0
	beq	mt_return2
	move.l	d1,-(sp)
	bra	mt_doretrig
mt_patterndelay
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	mt_pattdeltime2
	bne	mt_return2
	addq.b	#1,d0
	move.b	d0,mt_pattdeltime
	rts
mt_funkit
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
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
	move.b	(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
	clr.b	n_funkoffset(a6)
	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move.w	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.s	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
mt_funkend
	movem.l	(sp)+,a0/d1
	rts
SDMA_base	equ	$ffff8900
mt_init_Paula	bsr.s	mt_make_freq
	bsr	mt_make_tables
	bsr	mt_setup_voltab
	bsr	mt_make_zero
	rts
mt_make_freq	move.l	mt_freq_code_0,a0
	move.l	mt_freq_table0,a2
	moveq	#$f,d0
.mt_make_loop	move.l	a0,(a2)+
	move.l	d0,d1
	swap	d1
	divu.w	#100,d1
	move.w	#99,d7
	move.l	d1,d2
	swap	d2
	cmp.w	#50,d2
	blt.s	.mt_zero
	addq.w	#1,d1
.mt_zero	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.l	d4,a1
.mt_maker	moveq	#0,d5
	add.w	d1,d2
	addx.w	d5,d3
	move.w	d3,d5
	move.w	d2,d6
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d4,d5
	beq.s	.mt_put_op
	move.w	d5,d4
	move.w	d3,d5
	move.w	d2,d6
	add.w	d1,d6
	negx.w	d5
	neg.w	d5
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d4,d5
	beq.s	.mt_just_one_inc
	move.l	mt_one_inc10,(a0)+
	move.w	mt_one_inc10+4,(a0)+
	move.w	a1,(a0)+
	addq.w	#4,a1
	bra.s	.mt_go_on_loop
.mt_just_one_inc
	move.l	mt_one_inc00,(a0)+
	move.l	mt_one_inc00+4,(a0)+
	move.w	a1,(a0)+
	addq.w	#4,a1
	bra.s	.mt_go_on_loop
.mt_put_op	move.w	mt_copy0,(a0)+
	move.w	a1,(a0)+
	addq.w	#4,a1
.mt_go_on_loop	dbra	d7,.mt_maker
	move.w	#$4e75,(a0)+
	addq.l	#1,d0
	cmp.l	#100,d0
	bne	.mt_make_loop
mt_make_freq_2
.mt_make_loop	move.l	a0,(a2)+
	move.l	d0,d1
	subi.w	#100,d1
	swap	d1
	divu.w	#100,d1
	move.w	#99,d7
	move.l	d1,d2
	swap	d2
	cmp.w	#50,d2
	blt.s	.mt_zero
	addq.w	#1,d1
.mt_zero	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.l	d4,a1
.mt_maker	moveq	#0,d5
	add.w	d1,d2
	addx.w	d5,d3
	move.w	d3,d5
	move.w	d2,d6
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d4,d5
	beq.s	.mt_put_op
	move.w	d5,d4
	move.w	mt_adder,(a0)+
.mt_put_op	move.l	mt_one_inc10,(a0)+
	move.w	mt_one_inc10+4,(a0)+
	move.w	a1,(a0)+
	addq.w	#4,a1
.mt_go_on_loop	dbra	d7,.mt_maker
	move.w	#$4e75,(a0)+
	addq.l	#1,d0
	cmp.l	#126,d0
	bne	.mt_make_loop
	rts
mt_one_inc00	move.b	(a3)+,d0
	move.l	d0,a4
	move.b	(a4),d0
	move.b	d0,$7ffe(a6)
mt_one_inc10	move.b	(a3)+,d0
	move.l	d0,a4
	move.b	(a4),$7ffe(a6)
mt_copy0	move.b	d0,$7ffe(a6)
mt_adder	addq.w	#1,a3
mt_make_tables	move.l	mt_period_tab,a0
	move.w	#$72-1,d0
	moveq	#110,d1
.mt_copy_loop	move.l	d1,(a0)+
	dbra	d0,.mt_copy_loop
	move.w	#$72,d0
.mt_maker	move.l	mt_amiga_freq,d1
	divu.w	d0,d1
	move.w	d0,d3
	moveq	#0,d2
	asr.w	#1,d3
	addx.w	d2,d3
	move.l	d1,d2
	swap	d2
	cmp.w	d3,d2
	blt.s	.mt_no_add
	addq.w	#1,d1
.mt_no_add	andi.l	#$ffff,d1
	divu.w	#250,d1
	move.w	d1,d2
	clr.w	d1
	divu.w	#250,d1
	swap	d1
	moveq	#0,d3
	cmp.w	#125,d1
	blt.s	.mt_no_add1
	add.l	#$10000,d1
	addx.w	d3,d2
.mt_no_add1	move.w	d2,d1
	sub.w	#$f,d1
	bpl.s	.mt_no_dang
	moveq	#0,d1
.mt_no_dang	move.l	d1,(a0)+
	addq.w	#1,d0
	cmp.w	#$400,d0
	bne.s	.mt_maker
	rts
mt_setup_voltab
	lea	mt_volume_tab,a0
	move.l	(a0),d0
	andi.w	#$ff00,d0
	add.l	#$100,d0
	move.l	d0,(a0)
	move.l	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
.mt_clop	move.w	d1,d2
	ext.w	d2
	muls.w	d0,d2
	asr.w	#6,d2
	move.b	d2,(a0)+
	addq.w	#1,d1
	cmp.w	#$100,d1
	bne.s	.mt_clop
	moveq	#0,d1
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	.mt_clop	
	rts
mt_make_zero	move.l	mt_zero_code,a0
	move.w	.mt_zero_op,d0
	move.w	#500-1,d1
.mt_make_lop	move.w	d0,(a0)+
	dbra	d1,.mt_make_lop
	move.w	#$4e75,(a0)
	rts
.mt_zero_op	move.l	d0,(a0)+
mt_stop_Paula
	rts
;Paula(Ste) table
;dc.l	sample_start		+0
;dc.l	sample_loop_start	+4
;dc.l	sample_end		+8
;dc.w	volume		+12
;dc.w	period		+14
;dc.w	old_period		+16
;dc.w	float_add		+18
;
;Offset Paula table
	rsreset
mt_sample_start	rs.l	1
mt_sample_loop	rs.l	1
mt_sample_end	rs.l	1
mt_volume	rs.w	1
mt_period	rs.w	1
mt_oldperiod	rs.w	1
mt_add_iw	rs.w	1
mt_old_sample	rs.w	1
mt_channel	macro
	move.l	mt_sample_start(a0),d0
	beq	.mt_continue
.mt_no_reset	move.w	mt_period(a0),d0
	and.w	#$3ff,d0
	cmp.w	mt_oldperiod(a0),d0
	beq.s	.mt_noreset_add
	clr.w	mt_add_iw(a0)
	move.w	d0,mt_oldperiod(a0)
.mt_noreset_add	add.w	d0,d0
	add.w	d0,d0
	move.l	mt_period_tab,a4
	move.l	(a4,d0.w),d2
	move.w	d2,d4
	swap	d2
	move.w	mt_add_iw(a0),d3
	move.w	mt_volume(a0),d0
	andi.w	#$7f,d0
	asl.w	#8,d0
	move.l	mt_volume_tab,a4
	lea	(a4,d0.w),a4
	move.l	a4,d0
	move.l	mt_sample_start(a0),a3
	move.b	mt_old_sample(a0),d0
	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),a2
	jsr	(a2)
	lea	400(a6),a6
.mt_return_0	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),a2
	jsr	(a2)
	lea	400(a6),a6
.mt_return_1	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),a2
	jsr	(a2)
	lea	400(a6),a6
.mt_return_2	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),a2
	jsr	(a2)
	lea	400(a6),a6
.mt_return_3	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),a2
	jsr	(a2)
	lea	400(a6),a6
.mt_return_4	move.w	d3,mt_add_iw(a0)
	move.b	d0,mt_old_sample(a0)
	move.l	a3,mt_sample_start(a0)
	move.l	mt_sample_end(a0),d1
	cmp.l	d1,a3
	blt.s	.mt_continue
	move.l	mt_sample_loop(a0),d0
	beq.s	.mt_no_loop
	move.l	d0,mt_sample_start(a0)
	sub.l	d1,d0
	neg.l	d0
	neg.l	d1
	add.l	a3,d1
	cmp.l	d0,d1
	ble.s	.mt_no_div
	divu.w	d0,d1
	clr.w	d1
	swap	d1
.mt_no_div	add.l	d1,mt_sample_start(a0)
	bra.s	.mt_continue
.mt_no_loop	lea	mt_dummy_spl_tab,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
.mt_continue
	endm
mt_Paula	lea	SDMA_base,a0
	clr.w	(a0)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a0)
	add.l	mt_buf_length,d0
	movep.l	d0,$d(a0)
	move.w	mt_frequency,$20(a0)
	move.w	#1,(a0)
	bsr	mt_emulate
	lea	mt_physic_buf,a0
	lea	mt_logic_buf,a1
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	rts
mt_emulate	move.l	mt_channel_0,d0
	seq	d1
	move.l	mt_channel_1,d0
	seq	d0
	or.b	d0,d1
	move.l	mt_channel_2,d0
	seq	d0
	or.b	d0,d1
	move.l	mt_channel_3,d0
	seq	d0
	or.b	d0,d1
	beq.s	mt_no_clear_buf
	moveq	#0,d0
	move.l	mt_logic_buf,a0
	move.l	mt_zero_code,a1
	lea	mt_no_clear_buf,a2
	jsr	(a1)
mt_no_clear_buf	move.l	mt_logic_buf,a6
	lea	mt_channel_0,a0
	move.l	mt_freq_table0,a1
mt_left0	mt_channel
	move.l	mt_logic_buf,a6
	lea	1(a6),a6
	lea	mt_channel_1,a0
	move.l	mt_freq_table0,a1
mt_right0	mt_channel
	move.l	mt_logic_buf,a6
	lea	2(a6),a6
	lea	mt_channel_3,a0
	move.l	mt_freq_table0,a1
mt_left1	mt_channel
	move.l	mt_logic_buf,a6
	lea	3(a6),a6
	lea	mt_channel_2,a0
	move.l	mt_freq_table0,a1
mt_right1	mt_channel
	rts
	section	data
mt_funktable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
mt_vibratotable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24
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
	dc.w	$416E,$6F74,$6865,$7220
	dc.w	$6772,$6561,$7420,$636F
	dc.w	$6465,$2062,$793A,$204C
	dc.w	$616E,$6365,$2000
mt_chan1temp	dc.l	0,0,0,0,$3ff0000,$00010000,0,0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,$3ff0000,$00020000,0,0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,$3ff0000,$00040000,0,0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,$3ff0000,$00080000,0,0,0,0,0
mt_samplestarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
				dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
mt_songdataptr	dc.l	0
mt_module_end	dc.l	0
mt_speed		dc.b	6
mt_counter		dc.b	0
mt_songpos		dc.b	0
mt_pbreakpos	dc.b	0
mt_posjumpflag	dc.b	0
mt_pbreakflag	dc.b	0
mt_lowmask		dc.b	0
mt_pattdeltime	dc.b	0
mt_pattdeltime2	dc.b	0,0
mt_patternpos	dc.w	0
mt_dmacontemp	dc.w	0
mt_amiga_freq	dc.l	3545000
mt_physic_buf	dc.l	mt_physic_base
mt_logic_buf	dc.l	mt_logic_base
mt_buf_length	dc.l	2000
mt_volume_tab	dc.l	mt_volume_data
mt_zero_code	dc.l	mt_zero_data
mt_freq_code_0	dc.l	mt_freq_0
mt_freq_table0	dc.l	mt_freq_points0
mt_period_tab	dc.l	mt_period_count
mt_frequency	dc.w	$0003
mt_channel_0	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_1	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_2	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_3	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_dummy_spl_tab
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0

*-------------------------------------------------------------------------*

mt_data	incbin	"A:ASEMBLER.S\DANE.DAT\*.MOD"
		ds.w	31*640/2	;These zeroes are necessary!

*-------------------------------------------------------------------------*

	section	bss
mt_freq_points0	ds.l	111
mt_period_count	ds.l	1024
mt_physic_base	ds.w	1000+2
mt_logic_base	ds.w	1000+2
mt_volume_data	ds.w	128+$41*128
mt_zero_data	ds.w	501
mt_freq_0	ds.w	39921

