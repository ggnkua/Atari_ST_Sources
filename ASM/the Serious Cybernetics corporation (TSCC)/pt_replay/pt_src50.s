;----------------------------------------------------------
;
;
;
;
;
;
;                PROtracker replay routine
;                ÿÿÿÿÿÿÿÿÿÿ ÿÿÿÿÿÿ ÿÿÿÿÿÿÿ
;                        converted
;                           by:
;
;                        ¯ Lance ®
;
;
;
;
;
;
;----------------------------------------------------------
;  ....PROtracker was invented by Freelancers (Amiga)....
;----------------------------------------------------------
; This version includes the version 3 of my Paula emulators
; It's totally rewritten and by combining several tricks
; I'm manage to do a 50kHz(!!!) replay routine that only
; takes around 30% and I'm not using any cheats like over-
; sample. This version is indeed four times faster than my
; first replay routine and I hope all you hackers out there
; will like my routine and would like to contact me :
;---------------------------------------------------------- 
;	M†rten R†nge
;	Oxelv„gen 6
;	524 32 HERRLJUNGA
;	SWEDEN
;----------------------------------------------------------
; Or call:
;----------------------------------------------------------
;	+46-(0)513-10137
;    (Ask for M†rten , Maarten in english)
;----------------------------------------------------------
; This program is a CardWare program. Which means if you
; like it and use it regulary you are encouraged to send
; me a card or a letter(I prefer them without bombs(joke!))
; and tell me how much like my routine and that you think
; that I'm the greatest coder in the world etc. etc.
; This will encourage me to go on with my work on a UCDM -
; player and a Octalizer routine(XIA contacted me after he
; saw my version 0 of my Paula emulators and it's much
; thanks to him and to all others that have contacted me
; that version is made. So as you can see,contacting the
; programmer is very important.).
;----------------------------------------------------------
; Some Greets:
; ÿÿÿÿÿÿÿÿÿÿÿÿ
; OMEGA and Electra - (   The Best DemoCrews in Sweden    )
;    Delta Force    - (DiscMaggie has never looked better )
;     AGGRESSION    - ('BrainDamage' is really ultra-cool )
;-------------
;  NewCore - (What do you think about this replay , Blade?)
;  NoCrew  - (Should be named CoolCrew (they're very nice))
;   Chip   - (     Good friend (and also a Teadrinker)    )
;    XIA   - (It was nice to meet you at 'Motorola inside')
;    ICE   - (             Hi there,TECHWAVE              )
;-------------
; Special greet to AURA - I don't know you guys but it's
; thanks to you and your demo 'HiFi-dreams' that I realized
; that it's possible to make a 50kHz replay routine.
;-------------
; And to all members in IMPULSE (They paid me for this!)
;----------------------------------------------------------
; Some notes:
; Always call mt_Paula before mt_music ,this because
; mt_music sometimes takes more time and sometimes takes
; less. DON'T use Trap0 because I am using that to switch
; between Supervisor- and Usermode.
;----------------------------------------------------------
; P.S. This replay routine supports every PT2.2 command D.S
;----------------------------------------------------------
;      - Lance / M†rten R†nge      1993/08/22
;----------------------------------------------------------

machine		=	1	; 0=STE, 1=TT  (fix by ray//.tSCc. 2k3)

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
	rsreset
mt_sample_point	rs.l	1
mt_sample_end	rs.l	1
mt_loop_start	rs.l	1
mt_volume	rs.w	1
mt_period	rs.w	1
mt_add_iw	rs.w	1
mt_check_dummy	rs.w	1
	opt	a+,o-

	ifne	machine
		comment	HEAD=%011	; Fastram support for TT's
	endc

	section	text

mt_init
	ifne	machine
		pea.l	2*2000.w	; Reserve dma buffers in ST-Ram (TT only)
		move.w	#$48,-(sp)	; Make sure your main-program releases
		trap	#1		; unneeded memory using Mshrink() before
		addq.l	#6,sp

		lea.l	mt_physic_buf(pc),a0
		move.l	d0,(a0)+	; Store pointers to reserved space
		addi.l	#2*1000,d0
		move.l	d0,(a0)
	endc

	lea	mt_data,a0
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

	move.l	mt_samplestarts,a0
	move.l	mt_module_end,a1
.mt_shift_down	move.b	(a0),d0
	asr.b	#1,d0
	move.b	d0,(a0)+
	cmp.l	a0,a1
	bne.s	.mt_shift_down

	bra.w	mt_init_Paula


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
	move.w	d0,mt_volume(a5)	; set volume
	bra.s	mt_setregs

mt_noloop	move.l	n_start(a6),d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,mt_volume(a5)	; set volume

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
	cmp.w	#$0ed0,d0 ; notedelay
	beq	mt_checkmoreefx

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),mt_sample_point(a5)	; set start
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	mt_sample_point(a5),d0
	move.l	d0,mt_sample_end(a5)
	move.l	n_loopstart(a6),d0
	cmp.l	mt_sample_point(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	move.l	d0,mt_loop_start(a5)
	move.w	n_period(a6),d0
	move.w	d0,mt_period(a5)		; set period
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
setback	move.w	n_period(a6),mt_period(a5)
	cmp.b	#7,d0
	beq	mt_tremolo
	cmp.b	#$a,d0
	beq	mt_volumeslide
mt_return2
	rts

mt_pernop
	move.w	n_period(a6),mt_period(a5)
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
	mulu	#36*2,d1		; opt hint: replace this mulu.w by shifts&adds

	lea	mt_periodtable(pc),a0	; opt hint: use 030 addressing instead of
	add.l	d1,a0			; this adda.l here
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

mt_arpeggio4	move.w	d2,mt_period(a5)
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
	move.w	d0,mt_period(a5)
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
	move.w	d0,mt_period(a5)
	rts

mt_settoneporta
	move.l	a0,-(sp)
	move.w	(a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	mt_periodtable(pc),a0	; opt hint: use 030 addressing instead of
	add.l	d0,a0			; this adda.l here
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
	mulu	#36*2,d0		; same as above
	lea	mt_periodtable(pc),a0	;   "     "
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
	move.w	d2,mt_period(a5) ; set period
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
	move.w	d0,mt_period(a5)
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
	move.w	d0,mt_volume(a5)
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
	move.w	d0,mt_volume(a5)
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
	move.w	d0,mt_volume(a5)
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
	move.w	d0,mt_volume(a5)
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
	;;and.b	#$f0,d0		; unnecessary
	lsr.b	#4,d0
	beq.s	mt_filteronoff	; opt hint: use a jump table
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
mt_doretrig	move.l	n_start(a6),mt_sample_point(a5)	; set sampledata pointer
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	mt_sample_point(a5),d0
	move.l	d0,mt_sample_end(a5)

	move.l	n_loopstart(a6),d0
	cmp.l	mt_sample_point(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	move.l	d0,mt_loop_start(a5)

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
	move.w	#0,mt_volume(a5)
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

mt_init_Paula	
	bsr.s	mt_make_freq
	bsr	mt_make_tables
	bsr	mt_make_frame_f
	bsr	mt_make_voltab
	bsr	mt_make_divtab
	bsr	mt_make_mixcode

.mt_init_trap0	lea	mt_save_trap0,a0
	move.l	$80.w,(a0)
	lea	mt_return_Paula,a0
	move.l	a0,$80.w
	rts

mt_make_freq	move.l	mt_freq_list,a0
	moveq	#3,d0
.mt_maker	move.l	d0,d1
	swap	d1
	divu.w	#40,d1
	move.w	d1,d2
	swap	d1
	cmp.w	#20,d1
	blt.s	.mt_no_round
	addq.w	#1,d2
.mt_no_round
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#39,d7
.mt_make_freq	add.w	d2,d1
	negx.w	d4
	neg.w	d4
	move.w	d4,d5
	move.w	d1,d6
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d3,d5
	ble.s	.mt_set_zero
	move.w	d5,d3
	moveq	#1,d5
	move.w	d5,(a0)+
	dbra	d7,.mt_make_freq
	addq.w	#1,d0
	cmp.w	#26,d0
	bne.s	.mt_maker
	rts
.mt_set_zero	moveq	#0,d5
	move.w	d5,(a0)+
	dbra	d7,.mt_make_freq
	addq.w	#1,d0
	cmp.w	#26,d0
	bne.s	.mt_maker
	rts

mt_make_tables	move.l	mt_freq_table,a0
	moveq	#$72-1,d7
	move.l	#$02260000,d0
.mt_make_first	move.l	d0,(a0)+
	dbra	d7,.mt_make_first

	moveq	#$72,d0
.mt_maker	move.l	mt_amiga_freq,d1
	move.w	d0,d2
	add.w	d2,d2
	divu.w	d2,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	d1,d2
	swap	d1
	cmp.w	d0,d1
	blt.s	.mt_no_round
	addq.w	#1,d2
.mt_no_round	divu	#50,d2
	move.w	d2,d1
	clr.w	d2
	divu.w	#50,d2
	move.l	d2,d3
	swap	d3
	cmp.w	#50/2,d3
	blt.s	.mt_no_round1
	addq.w	#1,d2
.mt_no_round1	sub.w	#75,d1
	bpl.s	.mt_no_zero
	moveq	#0,d1
	moveq	#0,d2
.mt_no_zero	move.w	d1,(a0)+
	move.w	d2,(a0)+
	addq.w	#1,d0
	cmp.w	#$400,d0
	bne.s	.mt_maker
	rts
mt_make_frame_f	move.l	mt_frame_freq_t,a0
	move.l	mt_frame_freq_p,a1
	moveq	#75,d0
.mt_maker	move.l	d0,d1
	divu.w	#25,d1
	moveq	#0,d3
	move.w	d1,d2
	subq.w	#3,d2
	clr.w	d1
	divu.w	#25,d1
	move.w	d1,d3
	addq.w	#1,d3
.mt_no_round	move.l	a0,(a1)+
	moveq	#0,d4
	moveq	#24,d7
	moveq	#0,d1
.mt_make_it	moveq	#0,d1
	add.w	d3,d4
	addx.w	d2,d1
	move.w	d1,d5
	mulu.w	#23<<7,d5
	add.w	d1,d1
	add.w	d1,d1
	or.w	d1,d5
	move.w	d5,(a0)+
	dbra	d7,.mt_make_it
	addq.w	#1,d0
	cmp.w	#626,d0
	bne.s	.mt_maker
	rts
mt_make_voltab	lea	mt_volume_tab,a0
	move.l	(a0),d0
	andi.w	#$ff00,d0
	add.l	#$100,d0
	move.l	d0,(a0)
	move.l	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
.mt_clop0	move.w	d1,d2
	ext.w	d2
	muls.w	d0,d2
	asr.w	#6,d2
	move.b	d2,(a0)+
	addq.w	#1,d1
	cmp.w	#$40,d1
	bne.s	.mt_clop0
	lea	$80(a0),a0
	move.w	#$c0,d1
.mt_clop1	move.w	d1,d2
	ext.w	d2
	muls.w	d0,d2
	asr.w	#6,d2
	move.b	d2,(a0)+
	addq.w	#1,d1
	cmp.w	#$100,d1
	bne.s	.mt_clop1

	moveq	#0,d1
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	.mt_clop0
	rts
mt_make_divtab	moveq	#1,d0
	moveq	#1,d1
	move.l	mt_div_table,a0
.mt_init_div	move.l	d1,d2
	asl.w	#6,d2
	move.w	d0,d3
	divu.w	d0,d2
	lsr.w	#1,d3
	negx.w	d3
	neg.w	d3
	move.w	d2,d4
	swap	d2
	cmp.w	d3,d2
	blt.s	.mt_no_round
	addq.w	#1,d4
.mt_no_round	move.w	d4,(a0)+
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	.mt_init_div
	moveq	#1,d0
	addq.w	#1,d1
	cmp.w	#$41,d1
	bne.s	.mt_init_div
	rts

mt_make_mixcode	move.l	mt_mixcode_p,a0
	move.l	mt_mixer_chunk,a1
	move.l	mt_freq_list,a2
	lea	(a2),a4
	moveq	#22,d7
	moveq	#22,d6
.mt_maker	move.l	a1,(a0)+
	lea	(a2),a3
	moveq	#40-1,d5
.mt_make_it	move.w	.mt_copy,(a1)+
	move.w	(a3)+,d0
	move.w	(a4)+,d1
	add.w	d1,d1
	or.w	d1,d0
	dbne	d5,.mt_make_it
	tst.w	d5
	beq.s	.mt_end_ops
	bpl.s	.mt_no_exit
.mt_make_end	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6
	lea	80(a2),a2
	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts
.mt_no_exit
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move.w	d5,d4
	subq.w	#1,d4
.mt_analyse	move.w	(a3)+,d1
	move.w	(a4)+,d2
	add.w	d2,d2
	or.w	d2,d1
	add.w	d1,d1			; opt hint: use scaled 030 indexing
	add.w	d1,d1
	move.l	.mt_ana_code(pc,d1.w),a6
	jsr	(a6)
	dbra	d4,.mt_analyse
	move.l	(sp)+,a4
	move.l	(sp)+,a3
	tst.w	d1
	dbeq	d5,.mt_make_it
	bra.s	.mt_end_ops
.mt_ana_code	dc.l	.mt_ana_code0
	dc.l	.mt_ana_code1
	dc.l	.mt_ana_code2
	dc.l	.mt_ana_code3

.mt_end_ops	cmp.w	#3,d0
	beq.s	.mt_ana_code03
	cmp.w	#2,d0
	beq.s	.mt_ana_code02
.mt_ana_code01	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)
	move.w	.mt_ch0_fetch,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6
	lea	80(a2),a2
	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts
.mt_ana_code02	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)
	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6
	lea	80(a2),a2
	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts
.mt_ana_code03	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)
	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6
	lea	80(a2),a2
	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code0	rts
.mt_ana_code1	cmp.w	#3,d0
	beq.s	.mt_ana_code13
	cmp.w	#2,d0
	beq.s	.mt_ana_code12
.mt_ana_code11	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.w	.mt_ch0_fetch,(a1)+
	move.w	.mt_add10,(a1)+
	rts
.mt_ana_code12	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.w	.mt_add10,(a1)+
	rts
.mt_ana_code13	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add10,(a1)+
	rts
.mt_ana_code2	cmp.w	#3,d0
	beq.s	.mt_ana_code23
	cmp.w	#2,d0
	beq.s	.mt_ana_code22
.mt_ana_code21	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)
	move.w	.mt_ch0_fetch,(a1)+
	move.w	.mt_add01,(a1)+
	rts
.mt_ana_code22	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)
	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.w	.mt_add01,(a1)+
	rts
	rts
.mt_ana_code23	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)
	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add01,(a1)+
	rts
.mt_ana_code3	cmp.w	#3,d0
	beq.s	.mt_ana_code33
	cmp.w	#2,d0
	beq.s	.mt_ana_code32
.mt_ama_code31	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)
	move.w	.mt_ch0_fet_add,(a1)+
	rts
.mt_ana_code32	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.w	.mt_ch1_fet_add,(a1)+
	move.l	.mt_ch1_fet_add+2,(a1)+
	rts
.mt_ana_code33	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.l	.mt_ch01fetadd0,(a1)+
	move.l	.mt_ch01fetadd0+4,(a1)+
	rts
.mt_copy	move.b	d2,(sp)+
.mt_copy0	move.b	d0,(sp)+
.mt_copy1	move.b	d1,(sp)+
.mt_copy2	move.b	d2,(sp)+

.mt_ch0_fetch	move.b	(a0)+,d0
.mt_ch0_fet_add	add.b	(a0)+,d1
.mt_ch1_fetch	move.b	(a1)+,d1
	move.l	d1,a2
	move.b	(a2),d1
.mt_ch1_fet_add	move.b	(a1)+,d1
	move.l	d1,a2
	add.b	(a2),d0
.mt_ch01fetadd0	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	d1,a2
	add.b	(a2),d0
.mt_ch01fetadd1	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	d1,a2
	move.b	(a2),d1
.mt_add01	add.b	d0,d1
.mt_add10	add.b	d1,d0
.mt_add012	move.b	d0,d2
	add.b	d1,d2

mt_stop_Paula	move.l	mt_save_trap0,$80.w

	move.w	mt_LCM_mask,d0
	move.w	mt_LCM_left,d1
	or.w	#20,d1
	bsr.s	.mt_set_LCM
	move.w	mt_LCM_right,d1
	or.w	#20,d1

mt_end	=	mt_stop_Paula


.mt_set_LCM	lea	$ffff8900.w,a6
	move.w	d0,$24(a6)
	move.w	d1,$22(a6)
	rept	16
	nop
	endr
.mt_LCM_loop	cmp.w	$24(a6),d0
	bne.s	.mt_LCM_loop
	rts

mt_Paula	lea	$ffff8900.w,a6
	move.l	mt_LCM_set,a0
	ifeq	machine		; TT030 fix by ray//.tSCc. 2k3
		jmp	(a0)
	else
		move.l	sp,mt_save_SP
		jsr	(a0)
	endc

mt_return_Paula
	lea	mt_physic_buf,a0
	lea	mt_logic_buf,a1
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)

	ifeq	machine
		move.l	mt_save_SSP(pc),sp
	else
		move.l	mt_save_SP(pc),sp
	endc
	rts


	rsreset
mt_temp_regs	rs.l	2
mt_temp_old_sam	rs.w	2
mt_channel	macro
	move.l	(a3),d0
	bne.s	.mt_v0_active
	lea	mt_dummy_tab,a3
.mt_v0_active	move.l	(a4),d0
	bne.s	.mt_v1_active
	lea	mt_dummy_tab,a4
.mt_v1_active	move.w	mt_volume(a3),d0
	cmp.w	mt_volume(a4),d0
	bge.s	.mt_no_swap
	exg	a3,a4
.mt_no_swap	move.w	mt_volume(a3),d0
	moveq	#0,d1
	move.w	d0,(a1)
	beq.s	.mt_set_zero
	move.w	mt_volume(a4),d1
	beq.s	.mt_set_zero
	subq.w	#1,d0
	subq.w	#1,d1
	andi.w	#$3f,d0
	andi.w	#$3f,d1
	asl.w	#6,d1
	or.w	d0,d1
	add.w	d1,d1			; opt hint: use the scaled 030 addressing mode
	move.l	mt_div_table,a1		; here instead
	move.w	(a1,d1.w),d1
.mt_set_zero	move.l	mt_volume_tab,a1
	asl.w	#8,d1
	add.l	a1,d1
	move.l	mt_sample_point(a3),a0
	move.l	mt_sample_point(a4),a1
	lea	mt_temp_old_sam(a6),a2
	move.b	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2

	move.w	mt_period(a3),d3
	move.l	mt_freq_table,a2
	add.w	d3,d3			; same here
	add.w	d3,d3
	move.l	(a2,d3.w),d3
	move.w	d3,d4
	swap	d3
	add.w	mt_add_iw(a3),d4
	negx.w	d3
	neg.w	d3
	move.w	d4,mt_add_iw(a3)

	move.w	mt_period(a4),d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a2,d4.w),d4
	move.w	d4,d5
	swap	d4
	add.w	mt_add_iw(a4),d5
	negx.w	d4
	neg.w	d4
	move.w	d5,mt_add_iw(a4)

	move.l	mt_frame_freq_p,a2
	add.w	d3,d3			; same here
	add.w	d3,d3
	move.l	(a2,d3.w),d3
	add.w	d4,d4			; same here
	add.w	d4,d4
	move.l	(a2,d4.w),d4

	move.l	a3,(a6)+
	move.l	a4,(a6)+
	move.l	d3,a3
	move.l	d4,a4
	move.l	mt_mixcode_p,a5
	moveq	#$1f<<2,d5
	move.w	#$1ff<<7,d6
	move.l	a6,d7

	lea	.mt_return,a6
	move.w	(a3)+,d3
	move.w	(a4)+,d4
	and.w	d5,d4
	and.w	d6,d3
	lsr.w	#5,d3
	add.w	d3,d4
	move.l	(a5,d4.w),a2
	jmp	(a2)
.mt_return
	rept	24
	lea	$16(a6),a6
	move.w	(a3)+,d3
	move.w	(a4)+,d4
	and.w	d5,d4
	and.w	d6,d3
	lsr.w	#5,d3
	add.w	d3,d4
	move.l	(a5,d4.w),a2
	jmp	(a2)
	endr

	move.l	d7,a6
	move.l	-(a6),a4
	move.l	-(a6),a3
	lea	mt_temp_old_sam(a6),a2
	move.b	d0,(a2)+
	move.b	d1,(a2)+
	move.b	d2,(a2)+

	move.l	a0,mt_sample_point(a3)
	cmp.l	mt_sample_end(a3),a0
	blt.s	.mt_no_end_v0
	move.l	mt_loop_start(a3),d0
	beq.s	.mt_no_loop_v0
	move.l	a0,d1
	sub.l	mt_sample_end(a3),d1
	neg.l	d0
	add.l	mt_sample_end(a3),d0
	divu	d0,d1
	clr.w	d1
	swap	d1
	add.l	mt_loop_start(a3),d1
	move.l	d1,mt_sample_point(a3)
	bra.s	.mt_no_end_v0
.mt_no_loop_v0	move.w	mt_check_dummy(a3),d2
	bne.s	.mt_no_end_v0
	moveq	#0,d2
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
.mt_no_end_v0
	move.l	a1,mt_sample_point(a4)
	cmp.l	mt_sample_end(a4),a1
	blt.s	.mt_no_end_v1
	move.l	mt_loop_start(a4),d0
	beq.s	.mt_no_loop_v1
	move.l	a1,d1
	sub.l	mt_sample_end(a4),d1
	neg.l	d0
	add.l	mt_sample_end(a4),d0
	divu	d0,d1
	clr.w	d1
	swap	d1
	add.l	mt_loop_start(a4),d1
	move.l	d1,mt_sample_point(a4)
	bra.s	.mt_no_end_v1
.mt_no_loop_v1	move.w	mt_check_dummy(a4),d2
	bne.s	.mt_no_end_v1
	moveq	#0,d2
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
.mt_no_end_v1	lea	mt_dummy_tab,a3
	move.l	4(a3),(a3)
	endm

mt_emulate	lea	mt_save_USP,a0
	move.l	sp,(a0)

	lea	mt_channel_p,a0
	lea	mt_left_volume,a1
	lea	mt_left_temp,a6
	move.l	mt_logic_buf,sp
	move.l	0(a0),a3
	move.l	$c(a0),a4
mt_channel03	mt_channel

	lea	mt_channel_p,a0
	lea	mt_right_volume,a1
	lea	mt_right_temp,a6
	move.l	mt_logic_buf,sp
	lea	1(sp),sp
	move.l	4(a0),a3
	move.l	8(a0),a4

mt_channel12	mt_channel

mt_check_vols	lea	mt_left_volume,a0
	lea	mt_left_volold,a1
	move.w	(a0)+,d0
	cmp.w	(a1),d0
	sne	d1
	andi.w	#$4,d1
	move.w	d0,(a1)+
	move.w	(a0)+,d0
	cmp.w	(a1),d0
	sne	d2
	andi.w	#$8,d2
	or.w	d2,d1
	move.w	d0,(a1)+
	lea	mt_LCM_set,a0
	move.l	mt_LCM_set_conf(pc,d1.w),(a0)

	move.l	mt_save_USP,sp
	trap	#0

mt_LCM_set_conf	dc.l	mt_set_left	;for timing only
	dc.l	mt_set_left
	dc.l	mt_set_right
	dc.l	mt_set_all

mt_set_left	move.w	mt_LCM_mask,$24(a6)
	move.w	mt_left_volume,d0
	add.w	d0,d0			; opt hint: use scaled 030 indexing
	move.w	.mt_LCM_vol_tab(pc,d0.w),d0
	or.w	mt_LCM_left,d0
	move.w	d0,$22(a6)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a6)
	add.l	mt_replay_len,d0
	movep.l	d0,$d(a6)
	move.w	mt_frequency,$20(a6)
	move.w	mt_start,(a6)

	lea	mt_save_SSP,a0
	move.l	sp,(a0)
	pea	mt_emulate
	move.w	sr,d0
	andi.w	#$fff,d0
	move.w	d0,-(sp)
	rte
.mt_LCM_vol_tab	dc.w	0
	dc.w	2,5,7,8,9,10,10,11,11,12,12,13,13,13,14,14
	dc.w	14,14,15,15,15,15,16,16,16,16,16,16,17,17,17,17
	dc.w	17,17,17,18,18,18,18,18,18,18,18,18,18,19,19,19
	dc.w	19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20

mt_set_right	move.w	mt_LCM_mask,$24(a6)
	move.w	mt_right_volume,d0
	add.w	d0,d0			; opt hint: use scaled 030 indexing
	move.w	.mt_LCM_vol_tab(pc,d0.w),d0
	or.w	mt_LCM_right,d0
	move.w	d0,$22(a6)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a6)
	add.l	mt_replay_len,d0
	movep.l	d0,$d(a6)
	move.w	mt_frequency,$20(a6)
	move.w	mt_start,(a6)

	lea	mt_save_SSP,a0
	move.l	sp,(a0)
	pea	mt_emulate
	move.w	sr,d0
	andi.w	#$fff,d0
	move.w	d0,-(sp)
	rte
.mt_LCM_vol_tab	dc.w	0
	dc.w	2,5,7,8,9,10,10,11,11,12,12,13,13,13,14,14
	dc.w	14,14,15,15,15,15,16,16,16,16,16,16,17,17,17,17
	dc.w	17,17,17,18,18,18,18,18,18,18,18,18,18,19,19,19
	dc.w	19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20

mt_set_all	move.w	mt_LCM_mask,$24(a6)
	move.w	mt_left_volume,d0
	add.w	d0,d0			; opt hint: use scaled 030 indexing
	move.w	.mt_LCM_vol_tab(pc,d0.w),d0
	or.w	mt_LCM_left,d0
	move.w	d0,$22(a6)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a6)
	add.l	mt_replay_len,d0
	movep.l	d0,$d(a6)
	move.w	mt_frequency,$20(a6)
	move.w	mt_start,(a6)
	move.w	mt_LCM_mask,d1
	move.w	mt_right_volume,d0
	add.w	d0,d0
	move.w	.mt_LCM_vol_tab(pc,d0.w),d0
	or.w	mt_LCM_right,d0
.mt_test_LCM	cmp.w	$24(a6),d1
	bne.s	.mt_test_LCM
	move.w	d0,$22(a6)

	lea	mt_save_SSP,a0
	move.l	sp,(a0)
	pea	mt_emulate
	move.w	sr,d0
	andi.w	#$fff,d0
	move.w	d0,-(sp)
	rte
.mt_LCM_vol_tab	dc.w	0
	dc.w	2,5,7,8,9,10,10,11,11,12,12,13,13,13,14,14
	dc.w	14,14,15,15,15,15,16,16,16,16,16,16,17,17,17,17
	dc.w	17,17,17,18,18,18,18,18,18,18,18,18,18,19,19,19
	dc.w	19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20

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
mt_dmacontemp	dc.w	0

mt_amiga_freq	dc.l	7090000
mt_freq_list	dc.l	mt_freqer_list
mt_freq_table	dc.l	mt_freq_tab
mt_volume_tab	dc.l	mt_vol_tab
mt_div_table	dc.l	mt_div_tab
mt_frame_freq_t	dc.l	mt_frame_freq
mt_frame_freq_p	dc.l	mt_frame_freqp
mt_mixcode_p	dc.l	mt_mixcodes
mt_mixer_chunk	dc.l	mt_mix_chunk
mt_channel_p	dc.l	mt_channel_0
		dc.l	mt_channel_1
		dc.l	mt_channel_2
		dc.l	mt_channel_3

	ifeq	machine		; Ensure dma buffers -> ST-Ram
		mt_physic_buf:	dc.l	mt_replay_buf0
		mt_logic_buf:	dc.l	mt_replay_buf1
	else
		mt_physic_buf:	ds.l	1
		mt_logic_buf:	ds.l	1
	endc
mt_replay_len	dc.l	2000
mt_save_SSP	dc.l	0
mt_save_USP	dc.l	0
mt_save_SP	dc.l	0
mt_save_trap0	dc.l	0
mt_LCM_set	dc.l	mt_set_all
mt_start	dc.w	$0001
mt_frequency	dc.w	$0003
mt_left_volume	dc.w	0
mt_right_volume	dc.w	0
mt_left_volold	dc.w	0
mt_right_volold	dc.w	0
mt_LCM_mask	dc.w	$07ff
mt_LCM_left	dc.w	$540
mt_LCM_right	dc.w	$500
mt_left_temp	dc.l	0,0,0
mt_right_temp	dc.l	0,0,0

mt_channel_0	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	0
mt_channel_1	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	0
mt_channel_2	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	0
mt_channel_3	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	0

mt_dummy_tab	dc.l	mt_dummy_spl
	dc.l	mt_dummy_spl
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	-1

mt_data	incbin	"nomore.mod" ;"s'n'h.mod"
	ds.w	31*640/2	;These zeroes are necessary!

	section	bss
mt_freqer_list	ds.w	23*40
mt_freq_tab	ds.l	$400
mt_vol_tab	ds.w	$4200/2
mt_div_tab	ds.w	$1000
mt_dummy_spl	ds.w	320
mt_frame_freqp	ds.l	551
mt_mixcodes	ds.l	529

	ifeq	machine		; ensure dma buffers -> ST-Ram
		mt_replay_buf0:	ds.w	1000
		mt_replay_buf1:	ds.w	1000
	endc

mt_frame_freq	ds.w	27500
mt_mix_chunk	ds.w	60877
