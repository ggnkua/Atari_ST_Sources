; LANCE PAULA CODE
; ORIGINAL CODE BY LANCE
; ORIGINALLY MODIFIED BY PAULO SIMOES
;
; MODIFIED BY INSANE/RABENAUGE^TSCC
; -> removed qmalloc
; -> moved init code from main to paula
; -> removed trash buffers
; -> removed hard bpm (seemed to use trash+timer)
; -> simple soft bpm emulator added
; -> LMC modified (bugged sometimes on my STE,volume got suddenly louder)

paula_LMC_mask	=	$07ff
paula_LMC_left	=	$540
paula_LMC_right	=	$500

; PROC: INIT_CODE
;	Prepares the code depending of the replay frequency
;	d0:1=12.5khz, 2=25khz, 3=50khz
paula_init_smc_code:
	cmp	#$0001,d0		12.5 KHz ?
	bne.s	l_inicod25		yes / no
	lea	paula_frequency,a0
	move	d0,(a0)
	lea	paula_replay_len,a0
	move.l	#500,(a0)
	lea	ll_paula_makefreq2(pc),a0
	move.l	lc_paula_makefreq2(pc),(a0)
	lea	ll_paula_makefreq3(pc),a0
	move.l	lc_paula_makefreq3(pc),(a0)
	lea	ll_paula_make_freq(pc),a0
	move	lc_paula_make_freq(pc),-2(a0)
	lea	ll_paula_makefreq4(pc),a0
	move.l	lc_paula_makefreq4(pc),(a0)
	lea	ll_paula_makefreq5(pc),a0
	move.l	lc_paula_makefreq5(pc),(a0)
	lea	ll_paula_make_it1(pc),a0
	move	lc_paula_make_it1(pc),-2(a0)
	lea	ll_paula_mixcode2(pc),a0
	move.l	lc_paula_mixcode2(pc),(a0)
	bra	l_inicodok_e
l_inicod25
	cmp	#$0002,d0		25 KHz ?
	bne.s	l_inicod50		yes / no
	lea	paula_frequency,a0
	move	d0,(a0)
	lea	paula_replay_len,a0
	move.l	#1000,(a0)
	lea	ll_paula_makefreq2(pc),a0
	move.l	4+lc_paula_makefreq2(pc),(a0)
	lea	ll_paula_makefreq3(pc),a0
	move.l	4+lc_paula_makefreq3(pc),(a0)
	lea	ll_paula_make_freq(pc),a0
	move	2+lc_paula_make_freq(pc),-2(a0)
	lea	ll_paula_makefreq4(pc),a0
	move.l	4+lc_paula_makefreq4(pc),(a0)
	lea	ll_paula_makefreq5(pc),a0
	move.l	4+lc_paula_makefreq5(pc),(a0)
	lea	ll_paula_make_it1(pc),a0
	move	2+lc_paula_make_it1(pc),-2(a0)
	lea	ll_paula_mixcode2(pc),a0
	move.l	4+lc_paula_mixcode2(pc),(a0)
	bra.s	l_inicodok_e
l_inicod50
	lea	paula_frequency,a0
	move	d0,(a0)
	lea	paula_replay_len,a0
	move.l	#2000,(a0)
	lea	ll_paula_makefreq2(pc),a0
	move.l	8+lc_paula_makefreq2(pc),(a0)
	lea	ll_paula_makefreq3(pc),a0
	move.l	8+lc_paula_makefreq3(pc),(a0)
	lea	ll_paula_make_freq(pc),a0
	move	4+lc_paula_make_freq(pc),-2(a0)
	lea	ll_paula_makefreq4(pc),a0
	move.l	8+lc_paula_makefreq4(pc),(a0)
	lea	ll_paula_makefreq5(pc),a0
	move.l	8+lc_paula_makefreq5(pc),(a0)
	lea	ll_paula_make_it1(pc),a0
	move	4+lc_paula_make_it1(pc),-2(a0)
	lea	ll_paula_mixcode2(pc),a0
	move.l	8+lc_paula_mixcode2(pc),(a0)
l_inicodok_e
	rts

lc_paula_makefreq2
	divu.w	#10,d1				12.5 KHz => only 10 updates
	divu.w	#20,d1				25 KHz => only 20 updates
	divu.w	#40,d1				50 KHz
lc_paula_makefreq3
	cmp.w	#5,d1				12.5 KHz => only 10 updates
	cmp.w	#10,d1				25 KHz => only 20 updates
	cmp.w	#20,d1				50 KHz
lc_paula_make_freq
	moveq	#10-1,d7			12.5 KHz => only 10 updates
	moveq	#20-1,d7			25 KHz => only 20 updates
	moveq	#40-1,d7			50 KHz
lc_paula_makefreq4
	cmp	#10,d1				12.5 KHz => only 10 updates
	cmp	#20,d1				25 KHz => only 20 updates
	cmp	#40,d1				50 KHz
lc_paula_makefreq5
	sub	#10,d1				12.5 KHz => only 10 updates
	sub	#20,d1				25 KHz => only 20 updates
	sub	#40,d1				50 KHz
lc_paula_make_it1
	moveq	#10-1,d5			12.5 KHz => only 10 updates
	moveq	#20-1,d5			25 KHz => only 20 updates
	moveq	#40-1,d5			50 KHz
lc_paula_mixcode2
	lea	20(a2),a2			12.5 KHz
	lea	40(a2),a2			25 KHz
	lea	80(a2),a2			50 KHz

paula_clear_buffer:
	lea	buf_paula_replay,a0
	move.l	a0,a1
	moveq	#0,d0
	move.l	paula_replay_len,d2
	lsr.l	#2,d2
	subq	#1,d2
.clr
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d2,.clr
	rts

;	paula_init	tables and routines generation required by Lance
;	d0:1=12.5khz, 2=25khz, 3=50khz
paula_init:
	bsr	paula_init_smc_code			;modify paula for 12.5 & 25khz
	bsr	paula_init_lmc

	bsr	paula_make_freq
	bsr	paula_make_tables
	bsr	paula_make_frame_f
	bsr	paula_make_voltab
	bsr	paula_make_divtab
	bsr	paula_make_mixcode

	lea	buf_paula_replay,a0

	lea	paula_buffer_str,a1
	moveq	#0,d0
	moveq	#2-1,d1			;2 buffers
.paula_init_trash0
	move.l	a0,(a1)+		;digi buffer pointer
	move.l	d0,(a1)+		;LMC volume updates
	move.l	paula_replay_len,d2
	lsr.l	#2,d2
	subq	#1,d2
.paula_init_digibuf
	move.l	d0,(a0)+		;init with middle value: 00
	dbf	d2,.paula_init_digibuf
	dbf	d1,.paula_init_trash0
	moveq	#-1,d1
	lea	paula_buffer_status,a0
	move.l	d1,(a0)+		;all buffers ready-for-read FF
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	lea	paula_buffer_rd_idx,a0
	move	#1,(a0)			;read index set to 0 (VBL -> 1)
	lea	paula_buffer_wt_idx,a0
	move	d0,(a0)			;write index set to 0


	lea	paula_channel_p,a1
	lea	paula_channel_0,a0
	move.l	a0,(a1)+
	lea	paula_channel_1,a0
	move.l	a0,(a1)+
	lea	paula_channel_2,a0
	move.l	a0,(a1)+
	lea	paula_channel_3,a0
	move.l	a0,(a1)+

	lea	paula_dummy_tab,a1
	lea	paula_dummy_spl,a0
	move.l	a0,(a1)+
	move.l	a0,(a1)+

l_paula_init_trap0
	lea	paula_save_trap0,a0
	move.l	$80.w,(a0)
	lea	paula_return_svr(pc),a0
	move.l	a0,$80.w
	rts

;	paula_make_freq	generates table with reads required per DMA buffer
paula_make_freq
	move.l	paula_freq_list,a0

	moveq	#3,d0
l_paula_maker0
	move.l	d0,d1

	moveq	#0,d2
ll_paula_makefreq4
	cmp	#40,d1
	bcs.s	freq_lab1
	addq	#1,d2
ll_paula_makefreq5
	sub	#40,d1
	bne.s	ll_paula_makefreq4
freq_lab1
	swap	d2

	swap	d1

ll_paula_makefreq2
	divu.w	#40,d1

	move.w	d1,d2
	swap	d1

ll_paula_makefreq3
	cmp.w	#20,d1

	blt.s	l_paula_no_round0
	addq.w	#1,d2
l_paula_no_round0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5

	moveq	#40-1,d7

ll_paula_make_freq
l_paula_make_freq
	add.w	d2,d1
	negx.w	d4
	neg.w	d4
	move.w	d4,d5
	move.w	d1,d6
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d3,d5
	ble.s	l_paula_set_zero0
	move.w	d5,d3
	moveq	#1,d5

	swap	d2				;25 KHz => add integer part
	add	d2,d5				;of division result to D5
	swap	d2

	move.w	d5,(a0)+
	bra.s	l_paula_set_zero00
l_paula_set_zero0
	moveq	#0,d5

	swap	d2				;25 KHz => add integer part
	add	d2,d5				;of division result to D5
	swap	d2

	move.w	d5,(a0)+
l_paula_set_zero00
	dbra	d7,l_paula_make_freq
	addq.w	#1,d0
	cmp.w	#28,d0
	bne.s	l_paula_maker0
	rts

;	paula_make_tables	generates long read steps per Amiga divider
paula_make_tables
	move.l	paula_freq_table,a0

l_paula_make_first
	moveq	#0,d0
l_paula_maker1
	move	d0,-(sp)

	move	#108,d2
	cmp	d2,d0
	bcc.s	l_paula_maker1a
	move	d2,d0
l_paula_maker1a
	move	#907,d2
	cmp	d2,d0
	bls.s	l_paula_maker1b
	move	d2,d0
l_paula_maker1b
	move.l	paula_amiga_freq,d1
	move.w	d0,d2
	add.w	d2,d2
	divu.w	d2,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	d1,d2
	swap	d1
	cmp.w	d0,d1
	blt.s	l_paula_no_round1
	addq.w	#1,d2
l_paula_no_round1
	divu	#50,d2
	move.w	d2,d1
	clr.w	d2
	divu.w	#50,d2
	move.l	d2,d3
	swap	d3
	cmp.w	#50/2,d3
	blt.s	l_paula_no_round2
	addq.w	#1,d2
l_paula_no_round2
	sub.w	#78,d1
	bpl.s	l_paula_no_zero
	moveq	#0,d1
	moveq	#0,d2
l_paula_no_zero
	move.w	d1,(a0)+
	move.w	d2,(a0)+

	move	(sp)+,d0

	addq.w	#1,d0
	cmp.w	#$400,d0
	bne.s	l_paula_maker1
	rts

;	paula_make_frame_f	generates number of reads per VBL sub block
paula_make_frame_f
	move.l	paula_frame_freq_t,a0
	move.l	paula_frame_freq_p,a1

	moveq	#78,d0
l_paula_maker2
	move.l	d0,d1
	divu.w	#25,d1
	moveq	#0,d3
	move.w	d1,d2
	subq.w	#3,d2
	clr.w	d1
	divu.w	#25,d1
	move.w	d1,d3
	addq.w	#1,d3
l_paula_no_round
	move.l	a0,(a1)+
	moveq	#0,d4
	moveq	#24,d7
	moveq	#0,d1
l_paula_make_it0
	moveq	#0,d1
	add.w	d3,d4
	addx.w	d2,d1
	move.w	d1,d5
	mulu.w	#25<<6,d5
	add.w	d1,d1
	or.w	d1,d5
	move.w	d5,(a0)+
	dbra	d7,l_paula_make_it0
	addq.w	#1,d0
	cmp.w	#664,d0
	bne.s	l_paula_maker2
	rts

;	paula_make_voltab	generates the volume table
paula_make_voltab
	lea	buf_paula_volume_tab,a0
	move.l	a0,d0			;get the A0 pointer to D0
	add.l	#254,d0			;add.l 254 to pointer value
	clr.b	d0			;and clr the byte to have a 256 bytes
	move.l	d0,a0			;boundary and send the pointer to A0
	lea	paula_volume_tab,a1
	move.l	a0,(a1)

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
l_paula_clop0
	move.w	d1,d2
	ext.w	d2
	muls.w	d0,d2
	asr.w	#6,d2
	move.b	d2,(a0)+
	addq.w	#1,d1
	cmp.w	#$40,d1
	bne.s	l_paula_clop0
	lea	$80(a0),a0
	move.w	#$c0,d1
l_paula_clop1
	move.w	d1,d2
	ext.w	d2
	muls.w	d0,d2
	asr.w	#6,d2
	move.b	d2,(a0)+
	addq.w	#1,d1
	cmp.w	#$100,d1
	bne.s	l_paula_clop1

	moveq	#0,d1
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	l_paula_clop0
	rts

;	paula_make_divtab	generates the volume division table
paula_make_divtab
	move.l	paula_div_table,a0
	moveq	#1,d0
	moveq	#1,d1
l_paula_init_div
	move.l	d1,d2
	asl.w	#6,d2
	move.w	d0,d3
	divu.w	d0,d2
	lsr.w	#1,d3
	negx.w	d3
	neg.w	d3
	move.w	d2,d4
	swap	d2
	cmp.w	d3,d2
	blt.s	l_paula_no_round3
	addq.w	#1,d4
l_paula_no_round3
	move.w	d4,(a0)+
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	l_paula_init_div
	moveq	#1,d0
	addq.w	#1,d1
	cmp.w	#$41,d1
	bne.s	l_paula_init_div
	rts

;	paula_make_mixcode	generates the mixer code
paula_make_mixcode
	lea	l_paula_ana_code(pc),a1
	lea	l_paula_ana_code0(pc),a0		;0 0
	move.l	a0,(a1)+
	lea	l_paula_ana_code1(pc),a0		;0 1
	move.l	a0,(a1)+
	lea	l_paula_ana_code1(pc),a0		;0 2
	move.l	a0,(a1)+
	lea	l_paula_ana_code1(pc),a0		;0 3
	move.l	a0,(a1)+
	lea	l_paula_ana_code2(pc),a0		;1 0
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;1 1
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;1 2
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;1 3
	move.l	a0,(a1)+
	lea	l_paula_ana_code2(pc),a0		;2 0
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;2 1
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;2 2
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;2 3
	move.l	a0,(a1)+
	lea	l_paula_ana_code2(pc),a0		;3 0
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;3 1
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;3 2
	move.l	a0,(a1)+
	lea	l_paula_ana_code3(pc),a0		;3 3
	move.l	a0,(a1)+

	lea	l_paula_ana_codej0(pc),a1
	lea	l_paula_ana_code000(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code001(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code002(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code003(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code010(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code011(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code012(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code013(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code020(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code021(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code022(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code023(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code030(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code031(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code032(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code033(pc),a0
	move.l	a0,(a1)+

	lea	l_paula_ana_codej1(pc),a1
	lea	l_paula_ana_code100(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code101(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code102(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code103(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code110(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code111(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code112(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code113(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code120(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code121(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code122(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code123(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code130(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code131(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code132(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code133(pc),a0
	move.l	a0,(a1)+

	lea	l_paula_ana_codej2(pc),a1
	lea	l_paula_ana_code200(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code201(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code202(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code203(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code210(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code211(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code212(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code213(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code220(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code221(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code222(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code223(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code230(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code231(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code232(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code233(pc),a0
	move.l	a0,(a1)+

	lea	l_paula_ana_codej3(pc),a1
	lea	l_paula_ana_code300(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code301(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code302(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code303(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code310(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code311(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code312(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code313(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code320(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code321(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code322(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code323(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code330(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code331(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code332(pc),a0
	move.l	a0,(a1)+
	lea	l_paula_ana_code333(pc),a0
	move.l	a0,(a1)+

	lea	buf_paula_mixer_chunk,a1
	move.l	paula_mixcode_p,a0

	move.l	paula_freq_list,a2
	lea	(a2),a4
	moveq	#24,d7
	moveq	#24,d6
l_paula_maker3
	move.l	a1,(a0)+
	lea	(a2),a3

	moveq	#40-1,d5

ll_paula_make_it1
l_paula_make_it1
	move.w	l_paula_copy(pc),(a1)+
	move.w	(a3)+,d0
	move.w	(a4)+,d1

	add.w	d1,d1
	add.w	d1,d1				;2 bits instead of 1 to handle 0, 1 and 2

	or.w	d1,d0
	dbne	d5,l_paula_make_it1
	tst.w	d5
	beq	l_paula_end_ops
	bpl	l_paula_no_exit
l_paula_make_end
	move.w	#$4ED6,(a1)+			;JMP (A6)

	move	paula_frequency,d0
	cmp	#1,d0
	bne.s	l_paula_no_lea_cor0

	cmp	#12,d6				;insert space for LEA correction
	bcc.s	l_paula_make_end0			;@ 12.5 KHz (speeds above 15)
	move	d6,d0				;NOT to be executed @ 25 KHz or 50 KHz
	subq	#7,d0				;addqs not inserted
	bpl.s	l_paula_make_end2
	moveq	#0,d0				;speed 16/11:4 17/10:3 18/9:2 19/8:1 OTH:0
l_paula_make_end2
	add	d0,d0
	addq	#2,d0				;+ LEA - last addq = extra space required
	add	d0,a1
l_paula_make_end0
	cmp	#12,d7
	bcc.s	l_paula_make_end1
	move	d7,d0
	subq	#7,d0				;addqs not inserted
	bpl.s	l_paula_make_end3
	moveq	#0,d0				;speed 16/11:4 17/10:3 18/9:2 19/8:1 OTH:0
l_paula_make_end3
	add	d0,d0
	addq	#2,d0				;+ LEA - last addq = extra space required
	add	d0,a1
l_paula_make_end1

l_paula_no_lea_cor0

	dbra	d6,l_paula_maker3
	moveq	#24,d6

ll_paula_mixcode2
	lea	80(a2),a2			;new table size

	move.l	paula_freq_list,a4
	dbra	d7,l_paula_maker3

	move	paula_frequency,d0
	cmp	#1,d0
	bne.s	l_paula_no_lea_cor1

	bsr	paula_lea_correct			;LEA correction @ 12.5 KHz

l_paula_no_lea_cor1

	rts

l_paula_end_ops

	add.w	d0,d0
	add.w	d0,d0
	move.l	l_paula_ana_codej0(pc,d0.w),a6
	jmp	(a6)

l_paula_ana_codej0	ds.l	16

l_paula_ana_code000
	rts

l_paula_ana_code001
	lea	l_paula_copy(pc),a6		;0 1	l_mt_ana_code01
	move.w	l_paula_copy2(pc),(a6)
	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code002
	lea	l_paula_copy(pc),a6		;0 2
	move.w	l_paula_copy2(pc),(a6)

	move.w	l_paula_addq0(pc),(a1)+

	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code003
	lea	l_paula_copy(pc),a6		;0 3
	move.w	l_paula_copy2(pc),(a6)

	move.w	l_paula_addq20(pc),(a1)+

	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code010
	lea	l_paula_copy(pc),a6		;1 0	l_mt_ana_code02
	move.w	l_paula_copy2(pc),(a6)
	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code020
	lea	l_paula_copy(pc),a6		;2 0
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq1(pc),(a1)+

	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code030
	lea	l_paula_copy(pc),a6		;3 0
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq21(pc),(a1)+

	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code011
	lea	l_paula_copy(pc),a6		;1 1	l_mt_ana_code03
	move.w	l_paula_copy2(pc),(a6)
	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code012
	lea	l_paula_copy(pc),a6		;1 2
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq0(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code013
	lea	l_paula_copy(pc),a6		;1 3
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq20(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code021
	lea	l_paula_copy(pc),a6		;2 1
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code031
	lea	l_paula_copy(pc),a6		;3 1
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end

l_paula_ana_code022
	lea	l_paula_copy(pc),a6		;2 2
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq0(pc),(a1)+
	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end


l_paula_ana_code023
	lea	l_paula_copy(pc),a6		;2 3
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq20(pc),(a1)+
	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end


l_paula_ana_code032
	lea	l_paula_copy(pc),a6		;3 2
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq0(pc),(a1)+
	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end


l_paula_ana_code033
	lea	l_paula_copy(pc),a6		;3 3
	move.w	l_paula_copy2(pc),(a6)

	move	l_paula_addq20(pc),(a1)+
	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.l	l_paula_add012(pc),(a1)+
	dbra	d5,l_paula_make_it1
	bra	l_paula_make_end


l_paula_no_exit
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move.w	d5,d4
	subq.w	#1,d4

l_paula_analyse
	move.w	(a3)+,d1
	move.w	(a4)+,d2

	add.w	d2,d2
	add.w	d2,d2				;2 bits instead of 1 to handle 0, 1 and 2

	or.w	d2,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	l_paula_ana_code(pc,d1.w),a6
	jsr	(a6)
	dbra	d4,l_paula_analyse
	move.l	(sp)+,a4
	move.l	(sp)+,a3
	tst.w	d1
	dbeq	d5,l_paula_make_it1
	bra	l_paula_end_ops
l_paula_ana_code
	ds.l	16

l_paula_ana_code0
	rts

l_paula_ana_code1
	add.w	d0,d0
	add.w	d0,d0
	move.l	l_paula_ana_codej1(pc,d0.w),a6
	jmp	(a6)

l_paula_ana_codej1	ds.l	16

l_paula_ana_code100
	rts

l_paula_ana_code101
	moveq	#0,d4				;0 1	l_paula_ana_code11
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)
	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code102
	moveq	#0,d4				;0 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq0(pc),(a1)+

	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code103
	moveq	#0,d4				;0 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq20(pc),(a1)+

	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code110
	moveq	#0,d4				;1 0	l_paula_ana_code12
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)
	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code120
	moveq	#0,d4				;2 0
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq1(pc),(a1)+

	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code130
	moveq	#0,d4				;3 0
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq21(pc),(a1)+

	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code111
	moveq	#0,d4				;1 1	l_paula_ana_code13
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)
	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code112
	moveq	#0,d4				;1 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq0(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code113
	moveq	#0,d4				;1 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq20(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code121
	moveq	#0,d4				;2 1
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code131
	moveq	#0,d4				;3 1
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code122
	moveq	#0,d4				;2 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq0(pc),(a1)+
	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code123
	moveq	#0,d4				;2 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq20(pc),(a1)+
	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code132
	moveq	#0,d4				;3 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq0(pc),(a1)+
	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts

l_paula_ana_code133
	moveq	#0,d4				;3 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq20(pc),(a1)+
	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add10(pc),(a1)+
	rts


l_paula_ana_code2
	add.w	d0,d0
	add.w	d0,d0
	move.l	l_paula_ana_codej2(pc,d0.w),a6
	jmp	(a6)

l_paula_ana_codej2	ds.l	16

l_paula_ana_code200
	rts

l_paula_ana_code201
	moveq	#0,d4				;0 1	l_paula_ana_code21
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)
	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code202
	moveq	#0,d4				;0 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq0(pc),(a1)+

	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code203
	moveq	#0,d4				;0 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq20(pc),(a1)+

	move.w	l_paula_ch0_fetch(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code210
	moveq	#0,d4				;1 0	l_paula_ana_code22
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)
	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code220
	moveq	#0,d4				;2 0
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq1(pc),(a1)+

	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code230
	moveq	#0,d4				;3 0
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq21(pc),(a1)+

	move.w	l_paula_ch1_fetch(pc),(a1)+
	move.l	l_paula_ch1_fetch+2(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code211
	moveq	#0,d4				;1 1	l_paula_ana_code23
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)
	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code212
	moveq	#0,d4				;1 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq0(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code213
	moveq	#0,d4				;1 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq20(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code221
	moveq	#0,d4				;2 1
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code231
	moveq	#0,d4				;3 1
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code222
	moveq	#0,d4				;2 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq0(pc),(a1)+
	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code223
	moveq	#0,d4				;2 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq20(pc),(a1)+
	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code232
	moveq	#0,d4				;3 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq0(pc),(a1)+
	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts

l_paula_ana_code233
	moveq	#0,d4				;3 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq20(pc),(a1)+
	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd1(pc),(a1)+
	move.l	l_paula_ch01fetadd1+4(pc),(a1)+
	move.w	l_paula_add01(pc),(a1)+
	rts


l_paula_ana_code3
	add.w	d0,d0
	add.w	d0,d0
	move.l	l_paula_ana_codej3(pc,d0.w),a6
	jmp	(a6)

l_paula_ana_codej3	ds.l	16

l_paula_ana_code300
	rts

l_paula_ana_code301
	moveq	#0,d4				;0 1	l_paula_ana_code31
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)
	move.w	l_paula_ch0_fet_add(pc),(a1)+
	rts

l_paula_ana_code302
	moveq	#0,d4				;0 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq0(pc),(a1)+

	move.w	l_paula_ch0_fet_add(pc),(a1)+
	rts

l_paula_ana_code303
	moveq	#0,d4				;0 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy1(pc),(a6)

	move	l_paula_addq20(pc),(a1)+

	move.w	l_paula_ch0_fet_add(pc),(a1)+
	rts

l_paula_ana_code310
	moveq	#0,d4				;1 0	l_paula_ana_code32
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)
	move.w	l_paula_ch1_fet_add(pc),(a1)+
	move.l	l_paula_ch1_fet_add+2(pc),(a1)+
	rts

l_paula_ana_code320
	moveq	#0,d4				;2 0
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq1(pc),(a1)+

	move.w	l_paula_ch1_fet_add(pc),(a1)+
	move.l	l_paula_ch1_fet_add+2(pc),(a1)+
	rts

l_paula_ana_code330
	moveq	#0,d4				;3 0
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq21(pc),(a1)+

	move.w	l_paula_ch1_fet_add(pc),(a1)+
	move.l	l_paula_ch1_fet_add+2(pc),(a1)+
	rts

l_paula_ana_code311
	moveq	#0,d4				;1 1	l_paula_ana_code33
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)
	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts

l_paula_ana_code312
	moveq	#0,d4				;1 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq0(pc),(a1)+

	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts

l_paula_ana_code313
	moveq	#0,d4				;1 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq20(pc),(a1)+

	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts

l_paula_ana_code321
	moveq	#0,d4				;2 1
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts

l_paula_ana_code331
	moveq	#0,d4				;3 1
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts

l_paula_ana_code322
	moveq	#0,d4				;2 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq0(pc),(a1)+
	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts

l_paula_ana_code323
	moveq	#0,d4				;2 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq20(pc),(a1)+
	move	l_paula_addq1(pc),(a1)+

	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts

l_paula_ana_code332
	moveq	#0,d4				;3 2
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq0(pc),(a1)+
	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts

l_paula_ana_code333
	moveq	#0,d4				;3 3
	moveq	#1,d1
	lea	l_paula_copy(pc),a6
	move.w	l_paula_copy0(pc),(a6)

	move	l_paula_addq20(pc),(a1)+
	move	l_paula_addq21(pc),(a1)+

	move.l	l_paula_ch01fetadd0(pc),(a1)+
	move.l	l_paula_ch01fetadd0+4(pc),(a1)+
	rts


paula_lea_correct
	move.l	paula_mixcode_p,a1	;LEA correction @ 12.5 KHz only
	moveq	#24,d7
l_paula_lea_corr0
	moveq	#24,d6
l_paula_lea_corr1
	move.l	(a1)+,a0
	cmp	#12,d7
	scs	d5			;set if below 12 (speeds 16-27)
	cmp	#12,d6
	scs	d4			;set if below 12 (speeds 16-27)
	move.b	d4,d0
	or.b	d5,d0			;any speed in 16..25 range ?
	beq	l_paula_lea_corr9		;yes / no => do nothing
	lea	l_paula_code_buf(pc),a2
	lea	(a0),a3
	moveq	#90,d0
l_paula_lea_corr2
	move	(a3)+,(a2)+		;copy code to local buffer
	dbf	d0,l_paula_lea_corr2
	moveq	#0,d3			;LEA offset 0
	moveq	#0,d2			;LEA offset 1
	lea	l_paula_code_buf(pc),a2

	moveq	#0,d1			;no updates
l_paula_lea_corr3
	cmp.b	#$4E,(a2)		;JMP ?
	beq	l_paula_lea_corr5		;no / yes => job ended
	cmp.b	#$48,1(a2)		;ADDQ #xx,A0
	beq.s	l_paula_lea_addq0
	cmp.b	#$49,1(a2)		;ADDQ #xx,A1
	beq.s	l_paula_lea_addq1
	cmp	#$1018,(a2)		;MOVE.B (A0)+,D0
	beq.s	l_paula_lea_mova0
	cmp	#$1219,(a2)		;MOVE.B (A1)+,D1
	beq.s	l_paula_lea_mova1
	cmp	#$D218,(a2)		;ADD.B (A0)+,D1
	beq.s	l_paula_lea_adda0
	cmp	#$D019,(a2)		;ADD.B (A1)+,D0
	beq	l_paula_lea_adda1
	cmp.b	#$1E,(a2)		;update ?
	bne.s	l_paula_lea_corr4		;yes / no
	addq	#1,d1
l_paula_lea_corr4
	move	(a2)+,d0
l_paula_lea_copy
	move	d0,(a0)+		;copy as it is
	bra.s	l_paula_lea_corr3

l_paula_lea_addq0
	moveq	#0,d0
	move.b	(a2),d0
	sub.b	#$50,d0
	lsr	#1,d0
	add	d0,d3			;correct offset
	move	(a2)+,d0
	tst.b	d5			;correct this one ?
	bne.s	l_paula_lea_corr3		;no / yes
	bra.s	l_paula_lea_copy
l_paula_lea_addq1
	moveq	#0,d0
	move.b	(a2),d0
	sub.b	#$50,d0
	lsr	#1,d0
	add	d0,d2			;correct offset
	move	(a2)+,d0
	tst.b	d4			;correct this one ?
	bne.s	l_paula_lea_corr3		;no / yes
	bra.s	l_paula_lea_copy
l_paula_lea_mova0
	move	(a2)+,d0
	tst.b	d5
	beq.s	l_paula_lea_copy
	cmp	#10,d1			;last update ?
	beq.s	l_paula_insleacp0
	move	#$1028,(a0)+		;MOVE.B $xxxx(A0),D0
	move	d3,(a0)+		;$xxxx
	addq	#1,d3			;old ( )+ update
	bra.s	l_paula_lea_corr3
l_paula_insleacp0
	move	#$41E8,(a0)+		;LEA $xxxx(A0),A0
	move	d3,(a0)+		;$xxxx
	bra.s	l_paula_lea_copy
l_paula_lea_mova1
	move	(a2)+,d0
	tst.b	d4
	beq.s	l_paula_lea_copy
	cmp	#10,d1			;last update ?
	beq.s	l_paula_insleacp1
	move	#$1229,(a0)+		;MOVE.B $xxxx(A1),D1
	move	d2,(a0)+		;$xxxx
	addq	#1,d2			;old ( )+ update
	bra	l_paula_lea_corr3
l_paula_insleacp1
	move	#$43E9,(a0)+		;LEA $xxxx(A1),A1
	move	d2,(a0)+		;$xxxx
	bra.s	l_paula_lea_copy
l_paula_lea_adda0
	move	(a2)+,d0
	tst.b	d5
	beq.s	l_paula_lea_copy
	cmp	#10,d1			;last update ?
	beq.s	l_paula_insleacp0
	move	#$D228,(a0)+		;ADD.B $xxxx(A0),D1
	move	d3,(a0)+		;$xxxx
	addq	#1,d3			;old ( )+ update
	bra	l_paula_lea_corr3
l_paula_lea_adda1
	move	(a2)+,d0
	tst.b	d4
	beq	l_paula_lea_copy
	cmp	#10,d1			;last update ?
	beq.s	l_paula_insleacp1
	move	#$D029,(a0)+		;ADD.B $xxxx(A1),D0
	move	d2,(a0)+		;$xxxx
	addq	#1,d2			;old ( )+ update
	bra	l_paula_lea_corr3

l_paula_lea_corr5
	move	(a2)+,(a0)+		;copy JMP

l_paula_lea_corr9
	dbf	d6,l_paula_lea_corr1
	dbf	d7,l_paula_lea_corr0
	rts

l_paula_code_buf	ds.w	91	;Max = JMP(1W) + 10x(1UPD + 2ADDQ + 1RDA0 + 3RDA1 + 2MOVADD)


l_paula_copy
	move.b	d2,(sp)+
l_paula_copy0
	move.b	d0,(sp)+
l_paula_copy1
	move.b	d1,(sp)+
l_paula_copy2
	move.b	d2,(sp)+

l_paula_ch0_fetch
	move.b	(a0)+,d0
l_paula_ch0_fet_add
	add.b	(a0)+,d1
l_paula_ch1_fetch
	move.b	(a1)+,d1
	move.l	d1,a2
	move.b	(a2),d1
l_paula_ch1_fet_add
	move.b	(a1)+,d1
	move.l	d1,a2
	add.b	(a2),d0
l_paula_ch1_fet_ad2
	add.b	(a1)+,d0
l_paula_ch01fetadd0
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	d1,a2
	add.b	(a2),d0
l_paula_ch01fetadd2
	move.b	(a0)+,d0
	add.b	(a1)+,d0
l_paula_ch01fetadd1
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	d1,a2
	move.b	(a2),d1
l_paula_add01
	add.b	d0,d1
l_paula_add10
	add.b	d1,d0
l_paula_add012
	move.b	d0,d2
	add.b	d1,d2
l_paula_addq0
	addq	#1,a0				;new 25 KHz
l_paula_addq1
	addq	#1,a1				;new 25 KHz
l_paula_addq20
	addq	#2,a0				;new 12.5 KHz
l_paula_addq21
	addq	#2,a1				;new 12.5 KHz

paula_init_lmc
	bsr	paula_done_lmc	;init pan
	move.w	#paula_LMC_mask,d1
	bsr	paula_set_LMC
	move.w	#%0000010010000100,d0	; treble 4 -2db
	bsr	paula_set_LMC
	move.w	#%0000010001000111,d0	; bass   7 +1db
	bsr	paula_set_LMC
	rts

paula_done
	move.l	paula_save_trap0,$80.w
paula_done_lmc
	move.w	#paula_LMC_mask,d1
	move.w	#paula_LMC_left,d0
	or.w	#20,d0
	bsr	paula_set_LMC
	move.w	#paula_LMC_right,d0
	or.w	#20,d0
	bsr	paula_set_LMC
	move.w	#%0000010010000110,d0	; treble 6 -norm
	bsr	paula_set_LMC
	move.w	#%0000010001000110,d0	; bass   6 -norm
	bsr	paula_set_LMC
	rts

paula_set_LMC
	lea	$ffff8900.w,a1
paula_set_LMC_a1	;d1=mask, d0=data $ddmm
.waitempty0
	tst.w	$22(a1)
	bne	.waitempty0
	move.w	d1,$24(a1)	;mask
.paula_LMC_loop0
	cmp.w	$24(a1),d1
	bne.s	.paula_LMC_loop0
	move.w	d0,$22(a1)	;data
.waitempty1
	tst.w	$22(a1)
	bne	.waitempty1
.paula_LMC_loop1
	cmp.w	$24(a1),d1
	bne.s	.paula_LMC_loop1
	move.w	d0,$22(a1)	;data
	rts

; VBL paula routine
paula_calc:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	$FFFF8900.w,a1
	lea	paula_buffer_str,a0
	move	paula_buffer_rd_idx,d0
	lsl	#3,d0
	add	d0,a0
	move.l	(a0)+,d2		;digi buffer pointer
	move	(a0)+,d0		;left volume
	bmi.s	.paula_set_pointer	;if < 0 => no change
	move.w	#paula_LMC_mask,d1	;mask
	add.w	d0,d0
	move.w	lpaula_LMC_vol_tab0(pc,d0.w),d0
	or.w	#paula_LMC_left,d0
	bsr	paula_set_LMC_a1
.paula_set_pointer
	move	(a0)+,d0		;right volume
	bmi.s	.paula_no_right		;if < 0 => no change
	move.w	#paula_LMC_mask,d1
	add.w	d0,d0
	move.w	lpaula_LMC_vol_tab0(pc,d0.w),d0
	or.w	#paula_LMC_right,d0
	bsr	paula_set_LMC_a1
.paula_no_right
	movep.l	d2,$1(a1)		;stop dma, set buffer
	add.l	paula_replay_len,d2
	movep.l	d2,$d(a1)
	move.w	paula_frequency,$20(a1)
	move.w	#1,(a1)			;start dma

	bsr	paula_mixer
	eor.l	#$00010001,paula_buffer_rd_idx
	movem.l	(sp)+,d0-d7/a0-a6
	rts

lpaula_LMC_vol_tab0
	dc.w	0
	dc.w	2,5,7,8,9,10,10,11,11,12,12,13,13,13,14,14
	dc.w	14,14,15,15,15,15,16,16,16,16,16,16,17,17,17,17
	dc.w	17,17,17,18,18,18,18,18,18,18,18,18,18,19,19,19
	dc.w	19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20


;	paula_mixer	new procedure just to call mt_emulate
paula_mixer
	lea	paula_save_SSP,a0
	move.l	sp,(a0)			;Save Supervisor Stack Pointer
	pea	paula_emulate(pc)		;mt_emulate for return address
	move.w	sr,d0
	andi.w	#$0FFF,d0		;Status Register with User mode set
	move.w	d0,-(sp)		;new Status Register for next code
	rte				;Load new SR and paula_emulate as PC
					;So from here we go to paula_emulate
					;in User mode to allow interrupts

;	paula_emulate	main VBL handler
paula_emulate
	lea	paula_save_USP,a0
	move.l	sp,(a0)

	lea	paula_channel_p,a0
	lea	paula_left_volume,a1
	lea	paula_left_temp,a6

	lea	paula_buffer_str,a3
	move	paula_buffer_wt_idx,d0
	lsl	#3,d0
	move.l	0(a3,d0),sp

	move.l	0(a0),a3
	move.l	$c(a0),a4

	move.l	(a3),d0
	bne.s	l_paula_v0_active
	lea	paula_dummy_tab,a3
l_paula_v0_active
	move.l	(a4),d0
	bne.s	l_paula_v3_active
	lea	paula_dummy_tab,a4
l_paula_v3_active
	move.w	paula_volume(a3),d0
	cmp.w	paula_volume(a4),d0
	bge.s	l_paula_no_swap03
	exg	a3,a4
l_paula_no_swap03
	move.w	paula_volume(a3),d0
	moveq	#0,d1
	move.w	d0,(a1)
	beq.s	l_paula_set_zero10
	move.w	paula_volume(a4),d1
	beq.s	l_paula_set_zero10
	subq.w	#1,d0
	subq.w	#1,d1
	andi.w	#$3f,d0
	andi.w	#$3f,d1
	asl.w	#6,d1
	or.w	d0,d1
	add.w	d1,d1
	move.l	paula_div_table,a1
	move.w	0(a1,d1.w),d1
l_paula_set_zero10
	move.l	paula_volume_tab,a1
	asl.w	#8,d1
	add.l	a1,d1
	move.l	paula_sample_point(a3),a0
	move.l	paula_sample_point(a4),a1
	lea	paula_temp_old_sam(a6),a2
	move.b	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2

	move.w	paula_period(a3),d3
	move.l	paula_freq_table,a2
	add.w	d3,d3
	add.w	d3,d3
	move.l	0(a2,d3.w),d3
	move.w	d3,d4
	swap	d3
	add.w	paula_add_iw(a3),d4
	negx.w	d3
	neg.w	d3
	move.w	d4,paula_add_iw(a3)

	move.w	paula_period(a4),d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	0(a2,d4.w),d4
	move.w	d4,d5
	swap	d4
	add.w	paula_add_iw(a4),d5
	negx.w	d4
	neg.w	d4
	move.w	d5,paula_add_iw(a4)

	move.l	paula_frame_freq_p,a2
	add.w	d3,d3
	add.w	d3,d3
	move.l	0(a2,d3.w),d3
	add.w	d4,d4
	add.w	d4,d4
	move.l	0(a2,d4.w),d4

	move.l	a3,(a6)+
	move.l	a4,(a6)+
	move.l	d3,a3
	move.l	d4,a4
	move.l	paula_mixcode_p,a5
	moveq	#$1f<<1,d5
	move.w	#$3ff<<6,d6
	move.l	a6,d7

	lea	l_paula_return0(pc),a6			;frame 00
	move.w	(a3)+,d3
	move.w	(a4)+,d4
	and.w	d5,d4
	and.w	d6,d3
	lsr	#4,d3
	add	d4,d4
	add.w	d3,d4
	move.l	0(a5,d4.w),a2
	jmp	(a2)
l_paula_return0
	rept	24
	lea	$18(a6),a6		;08
	move.w	(a3)+,d3		;08
	move.w	(a4)+,d4		;08
	and.w	d5,d4			;04
	and.w	d6,d3			;04
	lsr	#4,d3			;16
	add	d4,d4			;04
	add.w	d3,d4			;04
	move.l	0(a5,d4.w),a2		;20
	jmp	(a2)			;08=84
	endr

	move.l	d7,a6
	move.l	-(a6),a4
	move.l	-(a6),a3
	lea	paula_temp_old_sam(a6),a2
	move.b	d0,(a2)+
	move.b	d1,(a2)+
	move.b	d2,(a2)+

	move.l	a0,paula_sample_point(a3)
	cmp.l	paula_sample_end(a3),a0
	blt.s	l_paula_no_end_v00
	move.l	paula_loop_start(a3),d0
	beq.s	l_paula_no_loop_v00
	move.l	a0,d1
	sub.l	paula_sample_end(a3),d1
	neg.l	d0
	add.l	paula_sample_end(a3),d0
	divu	d0,d1
	clr.w	d1
	swap	d1
	add.l	paula_loop_start(a3),d1
	move.l	d1,paula_sample_point(a3)
	bra.s	l_paula_no_end_v00
l_paula_no_loop_v00
	move.w	paula_check_dummy(a3),d2
	bne.s	l_paula_no_end_v00
	moveq	#0,d2
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
l_paula_no_end_v00
	move.l	a1,paula_sample_point(a4)
	cmp.l	paula_sample_end(a4),a1
	blt.s	l_paula_no_end_v10
	move.l	paula_loop_start(a4),d0
	beq.s	l_paula_no_loop_v10
	move.l	a1,d1
	sub.l	paula_sample_end(a4),d1
	neg.l	d0
	add.l	paula_sample_end(a4),d0
	divu	d0,d1
	clr.w	d1
	swap	d1
	add.l	paula_loop_start(a4),d1
	move.l	d1,paula_sample_point(a4)
	bra.s	l_paula_no_end_v10
l_paula_no_loop_v10
	move.w	paula_check_dummy(a4),d2
	bne.s	l_paula_no_end_v10
	moveq	#0,d2
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
l_paula_no_end_v10
	lea	paula_dummy_tab,a3
	move.l	4(a3),(a3)
	lea	paula_channel_p,a0
	lea	paula_right_volume,a1
	lea	paula_right_temp,a6
	lea	paula_buffer_str,a3
	move	paula_buffer_wt_idx,d0
	lsl	#3,d0
	move.l	0(a3,d0),sp

	lea	1(sp),sp
	move.l	4(a0),a3
	move.l	8(a0),a4

	move.l	(a3),d0
	bne.s	l_paula_v1_active
	lea	paula_dummy_tab,a3
l_paula_v1_active
	move.l	(a4),d0
	bne.s	l_paula_v2_active
	lea	paula_dummy_tab,a4
l_paula_v2_active
	move.w	paula_volume(a3),d0
	cmp.w	paula_volume(a4),d0
	bge.s	l_paula_no_swap12
	exg	a3,a4
l_paula_no_swap12
	move.w	paula_volume(a3),d0
	moveq	#0,d1
	move.w	d0,(a1)
	beq.s	l_paula_set_zero11
	move.w	paula_volume(a4),d1
	beq.s	l_paula_set_zero11
	subq.w	#1,d0
	subq.w	#1,d1
	andi.w	#$3f,d0
	andi.w	#$3f,d1
	asl.w	#6,d1
	or.w	d0,d1
	add.w	d1,d1
	move.l	paula_div_table,a1
	move.w	0(a1,d1.w),d1
l_paula_set_zero11
	move.l	paula_volume_tab,a1
	asl.w	#8,d1
	add.l	a1,d1
	move.l	paula_sample_point(a3),a0
	move.l	paula_sample_point(a4),a1
	lea	paula_temp_old_sam(a6),a2
	move.b	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2

	move.w	paula_period(a3),d3
	move.l	paula_freq_table,a2
	add.w	d3,d3
	add.w	d3,d3
	move.l	0(a2,d3.w),d3
	move.w	d3,d4
	swap	d3
	add.w	paula_add_iw(a3),d4
	negx.w	d3
	neg.w	d3
	move.w	d4,paula_add_iw(a3)

	move.w	paula_period(a4),d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	0(a2,d4.w),d4
	move.w	d4,d5
	swap	d4
	add.w	paula_add_iw(a4),d5
	negx.w	d4
	neg.w	d4
	move.w	d5,paula_add_iw(a4)

	move.l	paula_frame_freq_p,a2
	add.w	d3,d3
	add.w	d3,d3
	move.l	0(a2,d3.w),d3
	add.w	d4,d4
	add.w	d4,d4
	move.l	0(a2,d4.w),d4

	move.l	a3,(a6)+
	move.l	a4,(a6)+
	move.l	d3,a3
	move.l	d4,a4
	move.l	paula_mixcode_p,a5
**	moveq	#$1f<<2,d5
**	move.w	#$1ff<<7,d6
	moveq	#$1f<<1,d5
	move.w	#$3ff<<6,d6
	move.l	a6,d7

	lea	l_paula_return1(pc),a6			frame 00
	move.w	(a3)+,d3
	move.w	(a4)+,d4
	and.w	d5,d4
	and.w	d6,d3
**	lsr.w	#5,d3
	lsr	#4,d3
	add	d4,d4
	add.w	d3,d4
	move.l	0(a5,d4.w),a2
	jmp	(a2)
l_paula_return1
	rept	24
	lea	$18(a6),a6
	move.w	(a3)+,d3
	move.w	(a4)+,d4
	and.w	d5,d4
	and.w	d6,d3
	lsr	#4,d3
	add	d4,d4
	add.w	d3,d4
	move.l	0(a5,d4.w),a2
	jmp	(a2)
	endr

	move.l	d7,a6
	move.l	-(a6),a4
	move.l	-(a6),a3
	lea	paula_temp_old_sam(a6),a2
	move.b	d0,(a2)+
	move.b	d1,(a2)+
	move.b	d2,(a2)+

	move.l	a0,paula_sample_point(a3)
	cmp.l	paula_sample_end(a3),a0
	blt.s	l_paula_no_end_v01
	move.l	paula_loop_start(a3),d0
	beq.s	l_paula_no_loop_v01
	move.l	a0,d1
	sub.l	paula_sample_end(a3),d1
	neg.l	d0
	add.l	paula_sample_end(a3),d0
	divu	d0,d1
	clr.w	d1
	swap	d1
	add.l	paula_loop_start(a3),d1
	move.l	d1,paula_sample_point(a3)
	bra.s	l_paula_no_end_v01
l_paula_no_loop_v01
	move.w	paula_check_dummy(a3),d2
	bne.s	l_paula_no_end_v01
	moveq	#0,d2
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
l_paula_no_end_v01
	move.l	a1,paula_sample_point(a4)
	cmp.l	paula_sample_end(a4),a1
	blt.s	l_paula_no_end_v11
	move.l	paula_loop_start(a4),d0
	beq.s	l_paula_no_loop_v11
	move.l	a1,d1
	sub.l	paula_sample_end(a4),d1
	neg.l	d0
	add.l	paula_sample_end(a4),d0
	divu	d0,d1
	clr.w	d1
	swap	d1
	add.l	paula_loop_start(a4),d1
	move.l	d1,paula_sample_point(a4)
	bra.s	l_paula_no_end_v11
l_paula_no_loop_v11
	move.w	paula_check_dummy(a4),d2
	bne.s	l_paula_no_end_v11
	moveq	#0,d2
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
l_paula_no_end_v11
	lea	paula_dummy_tab,a3
	move.l	4(a3),(a3)


paula_check_vols
	lea	paula_left_volume,a0

	lea	paula_buffer_str,a3
	move	paula_buffer_wt_idx,d0
	lsl	#3,d0
	add	d0,a3

	lea	paula_left_volold,a1
	move.w	(a0)+,d0
	cmp.w	(a1),d0

	seq	4(a3)
	beq.s	paula_check_vols1
	move	d0,4(a3)
paula_check_vols1
	move.w	d0,(a1)+
	move.w	(a0)+,d0
	cmp.w	(a1),d0

	seq	6(a3)
	beq.s	paula_check_vols2
	move	d0,6(a3)
paula_check_vols2

	move.w	d0,(a1)+
	move.l	paula_save_USP,sp
	trap	#0

;	paula_return_svr		This is the trap #0 handler
paula_return_svr
	move.l	paula_save_SSP,sp	set Supervisor SP
	rts				go back in Supervisor (no rte done)

paula_amiga_freq	dc.l	7093790	;values 7093790 PAL	7159090 NTSC
paula_replay_len	dc.l	2000
paula_save_SSP		dc.l	0
paula_save_USP		dc.l	0
paula_save_trap0	dc.l	0
paula_frequency		dc.w	$0003
paula_left_volume	dc.w	0
paula_right_volume	dc.w	0
paula_left_volold	dc.w	0
paula_right_volold	dc.w	0
paula_freq_list		dc.l	buf_paula_freq_list
paula_freq_table	dc.l	buf_paula_freq_table
paula_frame_freq_t	dc.l	buf_paula_frame_freq_t
paula_frame_freq_p	dc.l	buf_paula_frame_freq_p
paula_div_table		dc.l	buf_paula_div_table
paula_mixcode_p		dc.l	buf_paula_mixcode_p

paula_left_temp		dc.l	0,0,0
paula_right_temp	dc.l	0,0,0
	rsreset
paula_temp_regs		rs.l	2
paula_temp_old_sam	rs.w	2


;	Interface_structs	paula_channel_x
paula_channel_0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	0
paula_channel_1
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	0
paula_channel_2
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	0
paula_channel_3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	0
paula_dummy_tab
	ds.l	1
	ds.l	1
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	0
	dc.w	-1
	rsreset
paula_sample_point	rs.l	1
paula_sample_end	rs.l	1
paula_loop_start	rs.l	1
paula_volume		rs.w	1
paula_period		rs.w	1
paula_add_iw		rs.w	1
paula_check_dummy	rs.w	1

	section	bss
paula_dummy_spl		ds.w	332
paula_volume_tab	ds.l	1
paula_channel_p		ds.l	4
paula_buffer_str	ds.l	64
paula_buffer_status	ds.b	32
paula_buffer_rd_idx	ds.w	1
paula_buffer_wt_idx	ds.w	1
			even

buf_paula_replay	ds.b	4000
buf_paula_freq_list	ds.b	25*40*2
buf_paula_freq_table	ds.b	$400*4
buf_paula_frame_freq_t	ds.b	$586*25*2
buf_paula_frame_freq_p	ds.b	$586*4
buf_paula_volume_tab	ds.b	16894
buf_paula_div_table	ds.b	64*64*2
buf_paula_mixcode_p	ds.b	625*4
buf_paula_mixer_chunk	ds.b	75557*2

	section	code
