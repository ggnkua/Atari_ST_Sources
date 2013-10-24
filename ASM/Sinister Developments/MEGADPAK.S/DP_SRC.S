***********************************************************************
* Depack code follows                                                 *
***********************************************************************

; Depack ATOM v3.5

ATOM_depack_v3.5
	move.l	4(a0),unpacked_length
	movem.l	d1-a6,-(a7)
	cmp.l	#$41544D35,(a0)
	bne	.exit
	lea	4(a0),a1
	move.l	4(a1),a2
	lea	8(a1,a2.L),a2
	move.l	a0,a3
.1	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	cmp.l	a1,a2
	bgt.s	.1
	link	a2,#-$1C
	move.l	(a0)+,d0
	lea	4(a0,d0.L),a5
	move.l	d0,-(a7)
	move.l	a5,a4
	lea	$1000(a4),a5
	subq.w	#8,a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	clr.w	-2(a2)
	move.b	.AT277(PC),d0
	bne.s	.AT145
	moveq	#0,d0
	move.b	-(a6),d0
	move.w	d0,-2(a2)
	lsl.w	#2,d0
	suba.w	d0,a4
.AT145	sf	.AT277
	pea	(a4)
	pea	(a5)
	move.b	-(a6),d7
	bra	.AT166
.AT146	move.w	d3,d5
.AT147	add.b	d7,d7
.AT148	dbcs	d5,.AT147
	beq.s	.AT14B
	bcc.s	.AT149
	sub.w	d3,d5
	neg.w	d5
	bra.s	.AT14E
.AT149	moveq	#3,d6
	bsr.s	.AT154
	beq.s	.AT14A
	bra.s	.AT14D
.AT14A	moveq	#7,d6
	bsr.s	.AT154
	beq.s	.AT14C
	add.w	#$F,d5
	bra.s	.AT14D
.AT14B	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.AT148
.AT14C	moveq	#$D,d6
	bsr.s	.AT154
	add.w	#$10E,d5
.AT14D	add.w	d3,d5
.AT14E	lea	.AT170(PC),a4
	move.w	d5,d2
	bne.s	.AT158
	add.b	d7,d7
	bne.s	.AT14F
	move.b	-(a6),d7
	addx.b	d7,d7
.AT14F	bcs.s	.AT150
	moveq	#1,d6
	bra.s	.AT159
.AT150	moveq	#3,d6
	bsr.s	.AT154
	tst.b	-$1C(a2)
	beq.s	.AT151
	move.b	-$12(a2,d5.W),-(a5)
	bra	.AT164
.AT151	move.b	(a5),d0
	btst	#3,d5
	bne.s	.AT152
	bra.s	.AT153
.AT152	add.b	#-$10,d5
.AT153	sub.b	d5,d0
	move.b	d0,-(a5)
	bra.s	.AT164
.AT154	clr.w	d5
.AT155	add.b	d7,d7
	beq.s	.AT157
.AT156	addx.w	d5,d5
	dbf	d6,.AT155
	tst.w	d5
	rts
.AT157	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.AT156
.AT158	moveq	#2,d6
.AT159	bsr.s	.AT154
	move.w	d5,d4
	move.b	$E(a4,d4.W),d6
	ext.w	d6
	tst.b	-$1B(a2)
	bne.s	.AT15A
	addq.w	#4,d6
	bra.s	.AT15E
.AT15A	bsr.s	.AT154
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	.AT154
	cmp.b	#7,d5
	blt.s	.AT15C
	moveq	#0,d6
	bsr.s	.AT154
	beq.s	.AT15B
	moveq	#2,d6
	bsr.s	.AT154
	add.w	d5,d5
	or.w	d1,d5
	bra.s	.AT15F
.AT15B	or.b	-$1A(a2),d1
	bra.s	.AT15D
.AT15C	or.b	-$19(a2,d5.W),d1
.AT15D	move.w	d1,d5
	bra.s	.AT15F
.AT15E	bsr.s	.AT154
.AT15F	add.w	d4,d4
	beq.s	.AT160
	add.w	-2(a4,d4.W),d5
.AT160	lea	1(a5,d5.W),a4
	move.b	-(a4),-(a5)
.AT161	move.b	-(a4),-(a5)
	dbf	d2,.AT161
	bra.s	.AT164
.AT162	add.b	d7,d7
	bne.s	.AT163
	move.b	-(a6),d7
	addx.b	d7,d7
.AT163	bcs.s	.AT16E
	move.b	-(a6),-(a5)
.AT164	cmp.l	a5,a3
.AT165	bne.s	.AT162
	cmp.l	a6,a0
	beq.s	.AT16F
.AT166	moveq	#0,d6
	bsr	.AT154
	beq.s	.AT169
	move.b	-(a6),d0
	lea	-$1A(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.AT167	cmp.b	d0,d1
	bne.s	.AT168
	addq.w	#2,d1
.AT168	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,.AT167
	st	-$1B(a2)
	bra.s	.AT16A
.AT169	sf	-$1B(a2)
.AT16A	moveq	#0,d6
	bsr	.AT154
	beq.s	.AT16C
	lea	-$12(a2),a1
	moveq	#$F,d0
.AT16B	move.b	-(a6),(a1)+
	dbf	d0,.AT16B
	st	-$1C(a2)
	bra.s	.AT16D
.AT16C	sf	-$1C(a2)
.AT16D	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	suba.w	d0,a3
	bra.s	.AT162
.AT16E	bra	.AT146
.AT16F	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	.AT171
	move.l	(a7)+,a2
	move.l	(a7)+,d1
	move.l	(a7)+,d0
	bsr.s	.AT177
	unlk	a2
	move.l	d1,d0
.exit	movem.l	(a7)+,d1-a6
	rts
.AT170	dc.b	$00,' ',$00,'`',$01,'`',$03,'`'
	dc.b	$07,'`',$0F,'`',$1F,'`',$00,$01
	dc.b	$03,$04,$05,$06,$07,$08
.AT171	move.w	-2(a2),d7
.AT172	dbf	d7,.AT173
	rts
.AT173	move.l	-(a0),d0
	lea	0(a5,d0.L),a1
	lea	$7d00(a1),a2
.AT174	moveq	#3,d6
.AT175	move.w	(a1)+,d0
	moveq	#3,d5
.AT176	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,.AT176
	dbf	d6,.AT175
	movem.w	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.AT174
	bra.s	.AT172
.AT177	lsr.l	#4,d0
	subq.w	#8,a6
	sub.l	a6,d1
.AT178	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbf	d0,.AT178
	rts
.AT277	dc.b	$00
	even

; Depack ATOM v3.3

DEC_MARGE	equ	16
RESTORE_M	equ	1
PIC_ALGO	equ	1
col_flash	equ	0

atom_3_3_depack
	move.l	4(a0),unpacked_length
	movem.l	d0-a6,-(a7)
	cmp.l	#"ATOM",(a0)+
	bne	no_crunched
	move.l	(a0)+,d0
	move.l	d0,-(a7)
	lea	DEC_MARGE(a0,d0.l),a5
	ifne	RESTORE_M
	move.l	a5,a4
	lea	buff_marg(pc),a3
	moveq	#DEC_MARGE+9,d0
.save_m	move.b	-(a4),(a3)+
	dbf	d0,.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.l	(a0)+,d0
	lea	0(a0,d0.l),a6
	move.b	-(a6),d7
	bra	make_jnk
tablus	lea	tablus_table(pc),a4
	moveq	#1,d6
	bsr.s	get_bit2
	bra.s	tablus2
decrunch	moveq	#6,d6
take_lenght
	add.b	d7,d7
	beq.s	.empty1
.cont_copy
	dbcc	d6,take_lenght
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1
	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy
.next_cod2
	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy	move	d5,-(a7)
	bne.s	bigger
	lea	decrun_table2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2
	cmp	#5,d5
	blt.s	contus
	addq	#2,a7
	subq	#6,d5
	bgt.s	tablus
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4	moveq	#1,d6
	bsr.s	get_bit2
tablus2	move.b	0(a4,d5.w),-(a5)
	bra.s	make_jnk
get_bit2	clr	d5
.get_bits	add.b	d7,d7
	beq.s	.empty
.cont	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger	lea	decrun_table(pc),a4
cont	moveq	#2,d6
	bsr.s	get_bit2
contus	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same
	move.b	-(a4),-(a5)
	dbf	d5,.copy_same
make_jnk	moveq	#11,d6
	moveq	#11,d5
take_jnk	add.b	d7,d7
	beq.s	empty
cont_jnk	dbcc	d6,take_jnk
	bcs.s	next_cod
	sub	d6,d5
	bra.s	copy_jnk1
next_cod	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1
.next_cod1
	moveq	#2,d6
	bsr.s	get_bit2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5
copy_jnk1	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk	move.b	-(a6),-(a5)

	dbf	d5,.copy_jnk

	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word	cmp.l	a6,a0
.decrunch	bne	decrunch
	cmp.b	#$80,d7
	bne.s	.decrunch
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	bsr.s	decod_picture
	endc
	ifne	RESTORE_M
	movem.l	(a7)+,a3-a4
	endc
	move.l	(a7)+,d0
	bsr	copy_decrun
	ifne	RESTORE_M
	moveq	#DEC_MARGE+9,d0
.restore_m
	move.b	-(a3),(a4)+
	dbf	d0,.restore_m
	endc
no_crunched
	movem.l	(a7)+,d0-a6
	rts
empty	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	cont_jnk
decrun_table
	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2
	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table
	dc.b	$60,$20,$10,$8
	ifne	PIC_ALGO
decod_picture
	move	-(a0),d7
	clr	(a0)
.next_picture
	dbf	d7,.decod_algo
	rts
.decod_algo
	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.l),a1
	lea	$7d00(a1),a2
.next_planes	moveq	#3,d6
.next_word
	move	(a1)+,d0
	moveq	#3,d5
.next_bits
	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
copy_decrun
	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun
	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts

	ifne	RESTORE_M
buff_marg	dcb.b	DEC_MARGE+10,0
	endc

; ATOM v3.1 depacker

atom_3_1_depack
	movem.l	a0-a6/D0-d7,-(a7)
	cmpi.l	#$41544F4D,(a0)+
	bne	.a311C
	move.l	(a0)+,d0
	move.l	d0,-(a7)
	lea	$10(a0,d0.L),a5
	movea.l	a5,a4
	lea	.a3128(PC),a3
	moveq	#$19,d0
.a3100	move.b	-(a4),(a3)+
	dbf	d0,.a3100
	movem.l	a3-a4,-(a7)
	pea	(a5)
	move.l	(a0)+,d0
	lea	0(a0,d0.L),a6
	bsr	.a3114
	bra.s	.a3111
.a3101	moveq	#6,d6
.a3102	add.w	d7,d7
	beq.s	.a3106
.a3103	dbcc	d6,.a3102
	bcs.s	.a3104
	moveq	#6,d5
	sub.w	d6,d5
	bra.s	.a3108
.a3104	moveq	#3,d6
	bsr.s	.a3109
	beq.s	.a3105
	addq.w	#6,d5
	bra.s	.a3108
.a3105	moveq	#7,d6
	bsr.s	.a3109
	beq.s	.a3107
	addi.w	#$15,d5
	bra.s	.a3108
.a3106	bsr.s	.a3114
	addx.w	d7,d7
	bra.s	.a3103
.a3107	moveq	#$D,d6
	bsr.s	.a3109
	addi.w	#$114,d5
.a3108	move.w	d5,-(a7)
	bne.s	.a310D
	lea	.a311F(PC),a4
	bra.s	.a310E
.a3109	clr.w	d5
.a310A	add.w	d7,d7
	beq.s	.a310C
.a310B	addx.w	d5,d5
	dbf	d6,.a310A
	tst.w	d5
	rts
.a310C	bsr.s	.a3114
	addx.w	d7,d7
	bra.s	.a310B
.a310D	lea	.a311E(PC),a4
.a310E	moveq	#2,d6
	bsr.s	.a3109
	move.w	d5,d4
	move.b	$E(a4,d4.W),d6
	ext.w	d6
	bsr.s	.a3109
	add.w	d4,d4
	beq.s	.a310F
	add.w	-2(a4,d4.W),d5
.a310F	lea	1(a5,d5.W),a4
	move.w	(a7)+,d5
	move.b	-(a4),-(a5)
.a3110	move.b	-(a4),-(a5)
	dbf	d5,.a3110
.a3111	moveq	#$B,d6
	moveq	#$B,d5
.a3112	add.w	d7,d7
	beq.s	.a311D
.a3113	dbcc	d6,.a3112
	bcs.s	.a3115
	sub.w	d6,d5
	bra.s	.a3117
.a3114	move.b	-(a6),-(a7)
	move.w	(a7)+,d7
	move.b	-(a6),d7
	rts
.a3115	moveq	#7,d6
	bsr.s	.a3109
	beq.s	.a3116
	addq.w	#8,d5
	addq.w	#3,d5
	bra.s	.a3117
.a3116	moveq	#2,d6
	bsr.s	.a3109
	swap	d5
	moveq	#$F,d6
	bsr.s	.a3109
	addq.l	#8,d5
	addq.l	#3,d5
.a3117	subq.w	#1,d5
	bmi.s	.a3119
	moveq	#1,d6
	swap	d6
.a3118	move.b	-(a6),-(a5)
	dbf	d5,.a3118
	sub.l	d6,d5
	bpl.s	.a3118
.a3119	cmpa.l	a6,a0
.a311A	bne	.a3101
	cmp.w	#-$8000,d7
	bne.s	.a311A
	movea.l	(a7)+,a0
	bsr.s	.a3120
	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	bsr	.a3126
	moveq	#$19,d0
.a311B	move.b	-(a3),(a4)+
	dbf	d0,.a311B
.a311C	movem.l	(a7)+,a0-a6/D0-d7
	rts
.a311D	bsr.s	.a3114
	addx.w	d7,d7
	bra.s	.a3113
.a311E	dc.b	$00,' ',$00,'`',$01,'`',$03,'`'
	dc.b	$07,'`',$0F,'`',$1F,'`',$04,$05
	dc.b	$07,$08,$09,$0A,$0B,$0C
.a311F	dc.b	$00,' ',$00,'`',$00,$E0,$01,$E0
	dc.b	$03,$E0,$05,$E0,$07,$E0,$04,$05
	dc.b	$06,$07,$08,$08,$08,$08
.a3120	move.w	-(a0),d7
	clr.w	(a0)
.a3121	dbf	d7,.a3122
	rts
.a3122	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.L),a1
	lea	$7D00(a1),a2
.a3123	moveq	#3,d6
.a3124	move.w	(a1)+,d0
	moveq	#3,d5
.a3125	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,.a3125
	dbf	d6,.a3124
	movem.w	d1-d4,-8(a1)
	cmpa.l	a1,a2
	bne.s	.a3123
	bra.s	.a3121
.a3126	lsr.l	#4,d0
	lea	-$C(a6),a6
.a3127	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbf	d0,.a3127
	rts
.a3128	dcb.w	14,0


FIRE1_depack
	movem.l	a0-a6/D0-d7,-(a7)
	lea	0(a0,d0.L),a5
	bsr.s	.fir149F
	cmp.l	#$46697265,d7
	bne.s	.fir149E
	movea.l	a1,a0
	bsr.s	.fir149F
	move.l	d7,(a7)
	lea	0(a0,d7.L),a6
	bsr.s	.fir149F
	lea	.fir14BC(PC),a4
	moveq	#1,d6
	swap	d6
	moveq	#0,d5
.fir149A	bsr.s	.fir14A3
	bcc.s	.fir149D
	moveq	#0,d1
	bsr.s	.fir14A3
	bcc.s	.fir149C
	movea.l	a4,a1
	moveq	#3,d3
.fir149B	move.l	-(a1),d0
	bsr.s	.fir14A6
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.fir149B
	add.l	$10(a1),d1
.fir149C	move.b	-(a5),-(a6)
	dbf	d1,.fir149C
.fir149D	cmpa.l	a0,a6
	bgt.s	.fir14A9
.fir149E	movem.l	(a7)+,a0-a6/D0-d7
	rts
.fir149F	moveq	#3,d0
.fir14A0	move.b	-(a5),d7
	ror.l	#8,d7
	dbf	d0,.fir14A0
	rts
.fir14A1	move.w	a5,d7
	btst	#0,d7
	bne.s	.fir14A2
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	.fir14A8
.fir14A2	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	.fir14A8
.fir14A3	add.l	d7,d7
	beq.s	.fir14A4
	rts
.fir14A4	move.w	a5,d7
	btst	#0,d7
	bne.s	.fir14A5
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
.fir14A5	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
.fir14A6	moveq	#0,d1
.fir14A7	add.l	d7,d7
	beq.s	.fir14A1
.fir14A8	addx.w	d1,d1
	dbf	d0,.fir14A7
	rts
.fir14A9	moveq	#1,d0
	bsr.s	.fir14A6
	subq.w	#1,d1
	bmi.s	.fir14AD
	beq.s	.fir14AF
	subq.w	#1,d1
	beq.s	.fir14B0
	bsr.s	.fir14A3
	bcc.s	.fir14AE
	bsr.s	.fir14A3
	bcc.s	.fir14B1
	bra.s	.fir14B2
.fir14AA	moveq	#1,d0
	bsr.s	.fir14A6
	subq.w	#1,d1
	bpl.s	.fir14AC
	moveq	#0,d0
	rts
.fir14AB	moveq	#1,d0
	bsr.s	.fir14A6
.fir14AC	add.w	d1,d1
	add.w	d1,d1
	movem.w	$10(a4,d1.W),d5/D0
	bsr.s	.fir14A6
	add.l	d5,d1
	rts
.fir14AD	moveq	#1,d0
	bsr.s	.fir14A6
	subq.w	#1,d1
	bmi.s	.fir14B6
	add.w	d1,d1
	add.w	d1,d1
	movem.w	$20(a4,d1.W),d2/D0
	bsr.s	.fir14A6
	add.w	d1,d2
	bsr.s	.fir14AB
	move.w	d2,d0
	bra.s	.fir14B8
.fir14AE	moveq	#2,d0
	bsr.s	.fir14A6
	moveq	#0,d0
	bset	d1,d0
	bra.s	.fir14B5
.fir14AF	moveq	#7,d0
	bsr.s	.fir14A6
	moveq	#0,d0
	bra.s	.fir14B9
.fir14B0	bsr.s	.fir14AA
	tst.w	d0
	beq.s	.fir14B5
	moveq	#1,d0
	bra.s	.fir14B9
.fir14B1	bsr.s	.fir14AA
	tst.w	d0
	beq.s	.fir14B4
	moveq	#2,d0
	bra.s	.fir14B9
.fir14B2	bsr.s	.fir14AA
	tst.w	d0
	beq.s	.fir14B3
	moveq	#3,d0
	bra.s	.fir14B9
.fir14B3	moveq	#-1,d0
	bra.s	.fir14B5
.fir14B4	move.b	(a6),d0
.fir14B5	move.b	d0,-(a6)
	bra.s	.fir14BB
.fir14B6	bsr.s	.fir14AB
	beq.s	.fir14BB
	move.b	(a6),d0
.fir14B7	move.b	d0,-(a6)
	dbf	d1,.fir14B7
	sub.l	d6,d1
	bmi.s	.fir14BB
	bra.s	.fir14B7
.fir14B8	subq.w	#2,d0
.fir14B9	lea	2(a6,d1.L),a1
	adda.w	d0,a1
	move.b	-(a1),-(a6)
.fir14BA	move.b	-(a1),-(a6)
	dbf	d0,.fir14BA
.fir14BB	bra	.fir149A
	dc.b	$03,$FF,$00,$09
	ori.b	#2,d7
	ori.b	#1,d3
	ori.b	#1,d3
.fir14BC	ori.b	#$E,d0
	ori.b	#7,d0
	ori.b	#4,d0
	ori.b	#1,d0
	ori.b	#0,d3
	ori.b	#$10,d7
	dc.b	$00,$0B
	btst	d0,(a0)
	dc.b	$00,$0F
	move.b	(a0),-(a0)
	ori.b	#5,d3
	ori.b	#$15,d5
	ori.b	#$55,d7
	dcb.w	2,0

; Depack FIRE v2

FIRE2_depack
	move.l	8(a0),unpacked_length
	link	a3,#-120
	movem.l	d0-a6,-(a7)
	lea	120(a0),a4
	move.l	a4,a6
	bsr.s	.getinfo
	cmp.l	#'FIRE',d0
	bne.s	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(a7)
	add.l	d0,a6
	move.l	a6,a1
	moveq	#119,d0
.save	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	lea	.tabellen(pc),a2
	moveq	#1,d6
	swap	d6
	moveq	#0,d5
.normal_bytes
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
;       lea.l   .direkt_tab+16-.tabellen(a2),a0
	move.l	a2,a0
	moveq	#3,d3
.nextgb	move.l	-(a0),d0
	bsr.s	.get_d0_bits
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more	add.l	16(a0),d1
.copy_direkt
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end
	cmp.l	a4,a6
	bgt.s	.strings
	movem.l	(a7),d0-a2/a5
.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a5),-(a3)
	dbf	d0,.rest
.not_packed
	movem.l	(a7)+,d0-a6
	unlk	a3
	rts
.getinfo
	moveq	#3,d1
.glw	rol.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.glw
	rts
.get_1_bit
	add.b	d7,d7
	beq.s	.no_bit_found
	rts
.no_bit_found
	move.b	-(a5),d7
	addx.b	d7,d7
	rts
.get_d0_bits
	moveq	#0,d1
.hole_bit_loop
	add.b	d7,d7
	beq.s	.not_found
.on_d0	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts
.not_found
	move.b	-(a5),d7
	addx.b	d7,d7
	bra.s	.on_d0
.strings
	moveq	#1,d0
	bsr.s	.get_d0_bits
	subq.w	#1,d1
	bmi.s	.gleich_morestring
	beq.s	.length_2
	subq.w	#1,d1
	beq.s	.length_3
	bsr.s	.get_1_bit
	bcc.s	.bitset
	bsr.s	.get_1_bit
	bcc.s	.length_4
	bra.s	.length_5

.get_short_offset
	moveq	#1,d0
	bsr.s	.get_d0_bits
	subq.w	#1,d1
	bpl.s	.contoffs
	moveq	#0,d0
	rts
.get_long_offset
	moveq	#1,d0
	bsr.s	.get_d0_bits
.contoffs	add.w	d1,d1
	add.w	d1,d1
	movem.w	.offset_table-.tabellen(a2,d1),d0/d5
	bsr.s	.get_d0_bits
	add.l	d5,d1
	rts
.gleich_morestring
	moveq	#1,d0
	bsr.s	.get_d0_bits
	subq.w	#1,d1
	bmi.s	.gleich_string
	add.w	d1,d1
	add.w	d1,d1
	movem.w	.more_table-.tabellen(a2,d1),d0/d2
	bsr.s	.get_d0_bits
	add.w	d1,d2
	bsr.s	.get_long_offset
	move.w	d2,d0
	bra.s	.copy_longstring
.bitset	moveq	#2,d0
	bsr.s	.get_d0_bits
	moveq	#0,d0
	bset	d1,d0
	bra.s	.put_d0
.length_2
	moveq	#7,d0
	bsr.s	.get_d0_bits
	moveq	#2-2,d0
	bra.s	.copy_string
.length_3
	bsr.s	.get_short_offset
	tst.w	d0
	beq.s	.put_d0
	moveq	#3-2,d0
	bra.s	.copy_string
.length_4
	bsr.s	.get_short_offset
	tst.w	d0
	beq.s	.vorgÑnger_kopieren
	moveq	#4-2,d0
	bra.s	.copy_string
.length_5
	bsr.s	.get_short_offset
	tst.w	d0
	beq.s	.put_ff
	moveq	#5-2,d0
	bra.s	.copy_string
.put_ff	moveq	#-1,d0
	bra.s	.put_d0
.vorgÑnger_kopieren
	move.b	(a6),d0
;       bra.s   .put_d0
.put_d0	move.b	d0,-(a6)
	bra.s	.backmain
.gleich_string
	bsr.s	.get_long_offset
	beq.s	.backmain
	move.b	(a6),d0
.copy_gl	move.b	d0,-(a6)
	dbf	d1,.copy_gl
	sub.l	d6,d1
	bmi.s	.backmain
	bra.s	.copy_gl
.copy_longstring
	subq.w	#2,d0
.copy_string
	lea.l	2(a6,d1.l),a0
	add.w	d0,a0
	move.b	-(a0),-(a6)
.dep_b	move.b	-(a0),-(a6)
	dbf	d0,.dep_b
.backmain	bra	.normal_bytes
.direkt_tab
	dc.l	$03ff0009,$00070002,$00030001,$00030001
.tabellen	dc.l	15-1,8-1,5-1,2-1
.offset_table
	dc.w	3,0,7,16+0,11,256+16+0,15,4096+256+16+0
.more_table
	dc.w	3,5,5,16+5,7,64+16+5

; Depack ICE v1.0
 
ice1_depack
	movem.l	d0-a6,-(a7)
	lea	0(a0,d0.l),a5
	bsr.s	.ice117
	cmpi.l	#'Ice!',d7
	bne.s	.ice112
	adda.w	#$78,a0
	bsr.s	.ice117
	move.l	d7,(a7)
	lea	0(a0,d7.l),a6
	movea.l	a6,a3
	movea.l	a6,a1
	lea	freespace+$78(pc),a2
	moveq	#$77,d0
.ice10f	move.b	-(a1),-(a2)
	dbra	d0,.ice10f
	bsr.s	.ice117
	bsr.s	.ice113
	move.l	(a7),d0
	lea	-120(a0),a1
.ice110	move.b	(a0)+,(a1)+
	dbra	d0,.ice110
	subi.l	#$010000,d0
	bpl.s	.ice110
	moveq	#$77,d0
	lea	freespace+$78(pc),a2
.ice111	move.b	-(a2),-(a3)
	dbra	d0,.ice111
.ice112	movem.l	(a7)+,d0-a6
	rts
.ice113	bsr.s	.ice11b
	bcc.s	.ice116
	moveq	#0,d1
	bsr.s	.ice11b
	bcc.s	.ice115
	lea	.ice128(pc),a1
	moveq	#3,d3
.ice114	move.l	-(a1),d0
	bsr.s	.ice11e
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.ice114
	add.l	16(a1),d1
.ice115	move.b	-(a5),-(a6)
	dbra	d1,.ice115
.ice116	cmpa.l	a0,a6
	bgt.s	.ice120
	rts
.ice117	moveq	#3,d0
.ice118	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,.ice118
	rts
.ice119	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice11a
	move.l	-(a5),d7
	addx.l	d7,d7
	addx.w	d1,d1
	dbra	d0,.ice11f
	rts
.ice11a	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	addx.w	d1,d1
	dbra	d0,.ice11f
	rts
.ice11b	add.l	d7,d7
	beq.s	.ice11c
	rts
.ice11c	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice11d
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
.ice11d	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
.ice11e	moveq	#0,d1
.ice11f	add.l	d7,d7
	beq.s	.ice119
	addx.w	d1,d1
	dbra	d0,.ice11f
	rts
.ice120	lea	.ice129(pc),a1
	moveq	#3,d2
.ice121	bsr.s	.ice11b
	dbcc	d2,.ice121
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.ice122
	bsr.s	.ice11e
.ice122	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.ice124
	lea	.ice12a(pc),a1
	moveq	#1,d2
.ice123	bsr.s	.ice11b
	dbcc	d2,.ice123
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.ice11e
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	.ice126
.ice124	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	.ice11b
	bcc.s	.ice125
	moveq	#8,d0
	moveq	#$40,d2
.ice125	bsr.s	.ice11e
	add.w	d2,d1
.ice126	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.ice127	move.b	-(a1),-(a6)
	dbra	d4,.ice127
	bra	.ice113

	dc.b	$03,$ff,$00,$09,$00,$07,$00,$02
	dc.b	$00,$03,$00,$01,$00,$03,$00,$01
.ice128	dc.b	$00,$00
	dc.b	$00,$0e,$00,$00,$00,$07,$00,$00
	dc.b	$00,$04,$00,$00,$00,$01
.ice129	dc.b	$09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b	$01,$00
.ice12a	dc.b	$0b,$04,$07,$00,$01,$20,$00,$00
	dc.b	$00,$20

; Depack ICE v2.0 

ice_2_0_depack
	movem.l d0-a6,-(sp)	; save registers
	cmpi.l	#'Ice!',(a0)+
	bne.s	.ice207
	move.l	(a0)+,d0
	lea	-8(a0,d0.l),a5
	move.l	(a0)+,(sp)
	lea	108(a0),a4
	movea.l a4,a6
	adda.l	(sp),a6
	movea.l a6,a3
	movea.l a6,a1
	lea	freespace+120(pc),a2
	moveq	#$77,d0
.ice200	move.b	-(a1),-(a2)
	dbra	d0,.ice200
	bsr	.ice20c
	bsr.s	.ice208
	bsr	.ice210
	bcc.s	.ice204
	movea.l a3,a1
	move.w	#$0f9f,d7
.ice201	moveq	#3,d6
.ice202	move.w	-(a1),d4
	moveq	#3,d5
.ice203	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice203
	dbra	d6,.ice202
	movem.w d0-d3,(a1)
	dbra	d7,.ice201
.ice204	move.l	(sp),d0
	lea	-120(a4),a1
.ice205	move.b	(a4)+,(a1)+
	dbra	d0,.ice205
	subi.l	#$010000,d0
	bpl.s	.ice205
	moveq	#$77,d0
	lea	freespace+120(pc),a2
.ice206	move.b	-(a2),-(a3)
	dbra	d0,.ice206
.ice207	movem.l (sp)+,d0-a6
	rts
.ice208	bsr.s	.ice210
	bcc.s	.ice20b
	moveq	#0,d1
	bsr.s	.ice210
	bcc.s	.ice20a
	lea	.ice21e(pc),a1
	moveq	#4,d3
.ice209	move.l	-(a1),d0
	bsr.s	.ice213
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.ice209
	add.l	20(a1),d1
.ice20a	move.b	-(a5),-(a6)
	dbra	d1,.ice20a
.ice20b	cmpa.l	a4,a6
	bgt.s	.ice216
	rts
.ice20c	moveq	#3,d0
.ice20d	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,.ice20d
	rts
.ice20e	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice20f
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	.ice215
.ice20f	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	.ice215
.ice210	add.l	d7,d7
	beq.s	.ice211
	rts
.ice211	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice212
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
.ice212	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
.ice213	moveq	#0,d1
.ice214	add.l	d7,d7
	beq.s	.ice20e
.ice215	addx.w	d1,d1
	dbra	d0,.ice214
	rts
.ice216	lea	.ice21f(pc),a1
	moveq	#3,d2
.ice217	bsr.s	.ice210
	dbcc	d2,.ice217
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.ice218
	bsr.s	.ice213
.ice218	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.ice21a
	lea	.ice220(pc),a1
	moveq	#1,d2
.ice219	bsr.s	.ice210
	dbcc	d2,.ice219
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.ice213
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	.ice21c
.ice21a	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	.ice210
	bcc.s	.ice21b
	moveq	#8,d0
	moveq	#$40,d2
.ice21b	bsr.s	.ice213
	add.w	d2,d1
.ice21c	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.ice21d	move.b	-(a1),-(a6)
	dbra	d4,.ice21d
	bra	.ice208
	dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
	dc.b $00,$07,$00,$02,$00,$03,$00,$01
	dc.b $00,$03,$00,$01
.ice21e	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
	dc.b $00,$00,$00,$07,$00,$00,$00,$04
	dc.b $00,$00,$00,$01
.ice21f	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b $01,$00
.ice220	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
	dc.b $00,$20

; Depack ICE v2.2 

ice_2_2_depack
	movem.l d0-a6,-(sp)
	bsr.s	.ice2_204
	cmpi.l	#'Ice!',d0	
	bne.s	.ice2_203
	bsr.s	.ice2_204
	lea	-8(a0,d0.l),a5
	bsr.s	.ice2_204
	move.l	d0,(sp)
	movea.l	a1,a4
	movea.l	a1,a6
	adda.l	d0,a6
	movea.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.ice2_206
	bsr.s	.ice2_20a
	bcc.s	.ice2_203
	move.w	#$0f9f,d7
.pic00	moveq	#3,d6	
.pic01	move.w	-(a3),d4	
	moveq	#3,d5
.pic02	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.pic02
	dbra	d6,.pic01
	movem.w	d0-d3,(a3)
	dbra	d7,.pic00
.ice2_203	movem.l	(sp)+,d0-a6
	rts
.ice2_204	moveq	#3,d1
.ice2_205	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,.ice2_205
	rts
.ice2_206	bsr.s	.ice2_20a
	bcc.s	.ice2_209
	moveq	#0,d1
	bsr.s	.ice2_20a
	bcc.s	.ice2_208
	lea	.ice2_217(pc),a1
	moveq	#4,d3
.ice2_207	move.l	-(a1),d0
	bsr.s	.ice2_20c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.ice2_207
	add.l	20(a1),d1
.ice2_208	move.b	-(a5),-(a6)
	dbra	d1,.ice2_208
.ice2_209	cmpa.l	a4,a6
	bgt.s	.ice2_20f
	rts
.ice2_20a	add.b	d7,d7
	bne.s	.ice2_20b
	move.b	-(a5),d7
	addx.b	d7,d7
.ice2_20b	rts
.ice2_20c	moveq	#0,d1
.ice2_20d	add.b	d7,d7
	bne.s	.ice2_20e
	move.b	-(a5),d7
	addx.b	d7,d7
.ice2_20e	addx.w	d1,d1
	dbra	d0,.ice2_20d
	rts
.ice2_20f	lea	.ice2_218(pc),a1
	moveq	#3,d2
.ice2_210	bsr.s	.ice2_20a
	dbcc	d2,.ice2_210
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.ice2_211
	bsr.s	.ice2_20c
.ice2_211	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.ice2_213
	lea	.ice2_219(pc),a1
	moveq	#1,d2
.ice2_212	bsr.s	.ice2_20a
	dbcc	d2,.ice2_212
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.ice2_20c
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.ice2_215
	sub.w	d4,d1
	bra.s	.ice2_215
.ice2_213	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	.ice2_20a
	bcc.s	.ice2_214
	moveq	#8,d0
	moveq	#$3f,d2
.ice2_214	bsr.s	.ice2_20c
	add.w	d2,d1
.ice2_215	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.ice2_216	move.b	-(a1),-(a6)
	dbra	d4,.ice2_216
	bra	.ice2_206
	DC.B	$7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B	$00,$07,$00,$02,$00,$03,$00,$01
	DC.B	$00,$03,$00,$01
.ice2_217	DC.B	$00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B	$00,$00,$00,$07,$00,$00,$00,$04
	DC.B	$00,$00,$00,$01
.ice2_218	DC.B	$09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B	$01,$00
.ice2_219	DC.B	$0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B	$00,$1f

; ICE depack v 2.3/2.4

ICE_depack_23_24
	move.l	8(a0),unpacked_length
	link	a3,#-120
	movem.l	d0-a6,-(a7)
	lea	120(a0),a4
	move.l	a4,a6
	bsr.s	.getinfo
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(a7)
	add.l	d0,a6
	move.l	a6,a1
	moveq	#119,d0
.save	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5
	bsr.s	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
.ICE_00	moveq	#3,d6
.ICE_01	move.w	-(a3),d4
	moveq	#3,d5
.ICE_02	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ICE_02
	dbra	d6,.ICE_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ICE_00
.no_picture
	movem.l	(a7),d0-a3
.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed
	movem.l	(a7)+,d0-a6
	unlk	a3
	rts
.getinfo	moveq	#3,d1
.getbytes	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts
.normal_bytes
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq	#4,d3
.nextgb	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more	add.l	20(a1),d1
.copy_direkt
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end
	cmp.l	a4,a6
	bgt.s	.strings
	rts
.get_1_bit
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound
	rts
.get_d0_bits
	moveq	#0,d1
.hole_bit_loop
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts
.strings	lea.l	.length_tab(pc),a1
	moveq	#3,d2
.get_length_bit
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_Åber
.get_Åber
	bsr.s	.get_d0_bits
.no_Åber	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2
	lea.l	.more_offset(pc),a1
	moveq	#1,d2
.getoffs	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes
.get_offset_2
	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq	#8,d0
	moveq	#$3f,d2
.less_40	bsr.s	.get_d0_bits
	add.w	d2,d1
.depack_bytes
	lea.l	2(a6,d4.w),a1
	add.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes
.direkt_tab
	dc.l	$7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l	270-1,15-1,8-1,5-1,2-1
.length_tab
	dc.b	9,1,0,-1,-1
	dc.b	8,4,2,1,0
.more_offset
	dc.b	11,4,7,0
	dc.w	$11f,-1,$1f

; depack LZH (jam3/4)

unpack_LZH	
	bra	.UNPACK
.RESET	movem.w	d0-d1/D3/D5,-(a7)
	move.l	a1,a2
	moveq	#$00,d2
	moveq	#-$02,d4
	moveq	#$00,d1
	move.w	#$0139,d5
.OUTER	addq.w	#2,d4
	cmp.w	(a2)+,d7
	bhi.s	.OUTER
	move.w	$00(a3,d4.W),d3
	addq.w	#1,d3
	lsr.w	#1,d3
	cmp.w	-$02(a3,d2.W),d3
	bls.s	.BIDDLE
	move.w	$00(a3,d1.W),d0
	add.w	$02(a3,d1.W),d0
	cmp.w	d0,d3
	bls.s	.BIDDLE
.BITH	move.w	d0,$00(a3,d2.W)
	move.w	d1,$00(a1,d2.W)
	move.w	d2,$00(a0,d1.W)
	move.w	d2,$02(a0,d1.W)
	addq.w	#2,d2
	addq.l	#4,d1
	move.w	$00(a3,d1.W),d0
	add.w	$02(a3,d1.W),d0
	cmp.w	d0,d3
	bhi.s	.BITH
.BIDDLE	move.w	d3,$00(a3,d2.W)
	move.w	$00(a1,d4.W),d0
	move.w	d0,$00(a1,d2.W)
	move.w	d2,$00(a0,d0.W)
	addq.w	#2,d2
	dbf	d5,.OUTER
.MAKETABLE2
	move.w	$00(a3,d1.W),d0
	add.w	$02(a3,d1.W),d0
	move.w	d0,$00(a3,d2.W)
	move.w	d1,$00(a1,d2.W)
	move.w	d2,$00(a0,d1.W)
	move.w	d2,$02(a0,d1.W)
	addq.w	#2,d2
	addq.l	#4,d1
	cmp.w	d7,d2
	bne.s	.MAKETABLE2
	movem.w	(a7)+,d0-d1/D3/D5
	rts
.CREATE	move.l	.TABLE7(PC),a0
	lea	.TDATA1(PC),a1
	moveq	#$00,d0
	moveq	#$1F,d1
	moveq	#$00,d2
.LOOP1	move.b	d0,(a0)+
	dbf	d1,.LOOP1
	dbf	d2,.EXIT1
	move.w	(a1)+,d3
	moveq	#$03,d2
.EXIT1	rol.w	#4,d3
	move.w	d3,d1
	andi.w	#$000F,d1
	addq.b	#4,d0
	bcc.s	.LOOP1
	move.l	.TABLE8(PC),a0
	lea	.TDATA2(PC),a1
	moveq	#$05,d0
	moveq	#$03,d1
.LOOP2	move.b	$00(a1,d0.W),d2
	ext.w	d2
.LOOP3	move.b	d1,(a0)+
	dbf	d2,.LOOP3
	addq.w	#1,d1
	dbf	d0,.LOOP2
	rts
.CREATE2	move.l	.TABLE1(PC),a0
	move.l	.TABLE5(PC),a1
	move.l	.TABLE4(PC),a2
	moveq	#$01,d1
	move.w	#$04E6,d2
	moveq	#$00,d4
	move.w	#$0139,d0
.CONTINUE
	move.w	d1,(a0)+
	move.w	d2,(a1)+
	move.w	d4,(a2)+
	addq.w	#2,d2
	addq.w	#2,d4
	dbf	d0,.CONTINUE
	move.l	.TABLE1(PC),a0
	move.l	.TABLE2(PC),a3
	move.l	.TABLE6(PC),a1
	move.l	.TABLE3(PC),a2
	move.w	#$0274,d2
	moveq	#$00,d4
	move.w	#$0138,d0
.DOMORE	move.w	(a0)+,d1
	add.w	(a0)+,d1
	move.w	d1,(a3)+
	move.w	d4,(a1)+
	move.w	d2,(a2)+
	move.w	d2,(a2)+
	addq.w	#4,d4
	addq.w	#2,d2
	dbf	d0,.DOMORE
	move.w	#$FFFF,(a3)
	clr.w	(a2)
	rts
.RESTORE	bsr	.RESET
	bra	.BACK
.TABLE1	dc.l	00
.TABLE2	dc.l	00
.TABLE3	dc.l	00
.TABLE4	dc.l	00
.TABLE5	dc.l	00
.TABLE6	dc.l	00
.TABLE7	dc.l	00
.TABLE8	dc.l	00
.EXIT	addq.l	#4,a7
	rts
.UNPACK	move.l	a0,a5
	move.l	a1,a6
	lea	.TABLE1(PC),a0
	move.l	#0,(a0)
	move.l	#$274,4(a0)
	move.l	#$4E8,8(a0)
	move.l	#$9CE,12(a0)
	move.l	#$C42,16(a0)
	move.l	#$EB6,20(a0)
	move.l	#$112A,24(a0)
	move.l	#$122A,28(a0)
	move.l	a7,d1
	sub.l	#$1500,d1
	move.w	#7,d0
.TABLOOP
	add.l	d1,(a0)+
	dbf	d0,.TABLOOP
	bsr	.CREATE
	bsr	.CREATE2
	move.l	.TABLE3(PC),a0
	move.l	.TABLE5(PC),a1
	move.l	.TABLE1(PC),a3
	move.l	a6,-(a7)
	add.l	4(a5),a6
	add.l	8(a5),a5
	add.l	#$0C,a5
	move.l	a6,a4
	move.w	#59,d0
.SPACES	move.b	#$20,(a4)+
	dbf	d0,.SPACES
	moveq	#$08,d6
	move.b	-(a5),d5
	move.w	#$04E6,d7
	move.l	.TABLE8(PC),a4
.TOP	cmp.l	(a7),a6
	ble	.EXIT
	move.w	$04E4(a1),d0
.MORE	dbf	d6,.NOTEMPTY
	moveq	#$07,d6
	move.b	-(a5),d5
.NOTEMPTY
	add.b	d5,d5
	bcc.s	.ZERO
	addq.w	#2,d0
.ZERO	move.w	$00(a1,d0.W),d0
	cmp.w	d7,d0
	blt.s	.MORE
	move.w	d0,d1
	sub.w	d7,d0
	move.w	$04E4(a3),d4
	bmi	.RESTORE
.BACK	move.w	$00(a0,d1.W),d1
.SCAN	lea	$00(a3,d1.W),a2
	addq.w	#1,(a2)
	cmpm.w	(a2)+,(a2)+
	bcs.s	.FRSTGTR
	move.w	$00(a0,d1.W),d1
	bne.s	.SCAN
	lsr.w	#1,d0
	cmp.w	#$0100,d0
	bge.s	.GTE256
.WRITE	move.b	d0,-(a6)
	bra.s	.TOP
.FRSTGTR	subq.w	#1,-$0004(a2)
	move.w	-$0004(a2),d4
.SAME	cmp.w	(a2)+,d4
	beq.s	.SAME
	subq.l	#4,a2
	addq.w	#1,(a2)
	suba.l	a3,a2
	move.w	$00(a1,d1.W),d4
	move.w	a2,$00(a0,d4.W)
	cmp.w	d7,d4
	bcc.s	.SKIP
	move.w	a2,$02(a0,d4.W)
.SKIP	move.w	$00(a1,a2.W),d2
	move.w	d4,$00(a1,a2.W)
	move.w	d1,$00(a0,d2.W)
	cmp.w	d7,d2
	bcc.s	.SKIP2
	move.w	d1,$02(a0,d2.W)
.SKIP2	move.w	d2,$00(a1,d1.W)
	move.w	$00(a0,a2.W),d1
	bne.s	.SCAN
	lsr.w	#1,d0
	cmp.w	#$0100,d0
	blt.s	.WRITE
.GTE256	move.b	-1(a5),d1
	moveq	#$00,d2
	lsr.b	d6,d1
	or.b	d5,d1
	move.b	$00(a4,d1.W),d2
	sub.w	d2,d6
	bpl.s	.POSITIVE
	move.b	-(a5),d5
	move.b	d5,d4
	addq.w	#2,d6
	bmi.s	.OVERFLOW
	beq.s	.MODD4
	lsr.b	#1,d4
	lsl.b	#7,d5
	bra.s	.MODD4
.READONE	move.b	-(a5),d5
	move.b	d5,d4
	lsl.b	#6,d5
	moveq	#$02,d6
	lsr.b	d6,d4
	bra.s	.DOCOPY
.POSITIVE
	beq.s	.READONE
	move.b	(a5),d5
	subq.w	#6,d6
.OVERFLOW
	neg.w	d6
	lsl.b	d6,d5
	move.b	d5,d4
	move.b	-(a5),d5
	move.b	d5,d2
	lsl.b	d6,d5
	subq.w	#8,d6
	neg.w	d6
	lsr.b	d6,d2
	or.b	d2,d4
.MODD4	andi.w	#$003F,d4
.DOCOPY	move.l	.TABLE7(PC),a0
	move.b	(a0,d1.W),d2
	lsl.w	#4,d2
	or.b	d4,d2
	lea	$01(a6,d2.W),a0
	subi.w	#$00FE,d0
	move.w	d0,d1
.COPY	move.b	-(a0),d0
	move.b	d0,-(a6)
	dbf	d1,.COPY
	move.l	.TABLE3(PC),a0
	bra	.TOP

.TDATA2	btst	d7,$2F3F(a7)
	move.l	(a7)+,-(a7)
.TDATA1
	dc.w	$FFF7
	dc.w	$7777
	dc.w	$7773
	dc.w	$3333
	dc.w	$3333
	dc.w	$3331
	move.b	(a1),-(a0)
	move.b	(a1),-(a0)
	move.b	(a1),-(a0)
	move.b	(a1),-(a0)
	move.b	(a1),-(a0)
	move.b	(a0),-(a0)
	ori.b	#$00,d0
	ori.b	#$00,d0

; depack LZW file

dp_LZW	move.l	a0,a1
	lea	$100(a1),a1
.LZW0D	move.l	a0,a4
	move.l	a1,a6
	add.l	8(a0),a4
	add.l	4(a0),a6
	move.l	a6,a5
	move.l	4(a0),d4
	move.b	#$20,d3
	move.w	#$FED,d5
	move.l	a6,a3
	moveq	#0,d7
.LZW0E	dbf	d7,.LZW0F
	move.b	-(a4),d6
	moveq	#7,d7
.LZW0F	lsr.b	#1,d6
	bcc.s	.LZW10
	move.b	-(a4),-(a6)
	addq.w	#1,d5
	subq.l	#1,d4
	bgt.s	.LZW0E
	bra.s	.LZW13
.LZW10	move.b	-2(a4),d0
	lsl.w	#4,d0
	move.b	-(a4),d0
	sub.w	d5,d0
	neg.w	d0
	and.w	#$FFF,d0
	lea	1(a6,d0.W),a0
	moveq	#$F,d1
	and.b	-(a4),d1
	addq.w	#2,d1
	moveq	#1,d0
	add.w	d1,d0
	cmp.l	a5,a0
	bgt.s	.LZW14
.LZW11	move.b	-(a0),-(a6)
	dbf	d1,.LZW11
.LZW12	add.l	d0,d5
	sub.l	d0,d4
	bgt.s	.LZW0E
.LZW13	rts
.LZW14	cmp.l	a5,a0
	ble.s	.LZW11
	move.b	d3,-(a6)
	subq.l	#1,a0
	dbf	d1,.LZW14
	bra.s	.LZW12

; depack automation v 2.3r / 2.51

depack_aut_23r_251
	addq.l	#4,a0
	move.l	a0,a4
	move.l	(a0)+,d5
	add.l	d5,a1
	add.l	(a0),a0
	suba.l	#4,a0
	tst.w	-(a0)
	bpl.s	.AUT1
	subq.l	#1,a0
.AUT1	move.b	-(a0),d0
.AUT2	lsl.b	#1,d0
	bne.s	.AUT3
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT3	bcc.s	.AUT10
	clr.w	d1
	lsl.b	#1,d0
	bne.s	.AUT4
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT4	bcc.s	.AUT9
	lea	.nums(PC),a3
	moveq	#3,d3
.AUT5	clr.w	d1
	move.b	0(a3,d3.W),d2
	ext.w	d2
	moveq	#-1,d4
	lsl.w	d2,d4
	not.w	d4
	subq.w	#1,d2
.AUT6	lsl.b	#1,d0
	bne.s	.AUT7
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT7	roxl.w	#1,d1
	dbf	d2,.AUT6
	tst.w	d3
	beq.s	.AUT8
	cmp.w	d1,d4
	dbne	d3,.AUT5
.AUT8	move.b	4(a3,d3.W),d2
	ext.w	d2
	add.w	d2,d1
	bra.s	.AUT9

.nums	dc.b	$0A,$03,$02,$02,$0E,$07,$04,$01

.AUT9	move.b	-(a0),-(a1)
	dbf	d1,.AUT9
.AUT10	move.l	a4,a3
	addq.l	#$8,a3
	cmp.l	a3,a0
	ble	.BYENOW
	lea	.nums2(PC),a3
	moveq	#3,d2
.AUT11	lsl.b	#1,d0
	bne.s	.AUT12
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT12	bcc.s	.AUT13
	dbf	d2,.AUT11
.AUT13	clr.w	d1
	addq.w	#1,d2
	move.b	0(a3,d2.W),d3
	beq.s	.AUT16
	ext.w	d3
	subq.w	#1,d3
.AUT14	lsl.b	#1,d0
	bne.s	.AUT15
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT15	roxl.w	#1,d1
	dbf	d3,.AUT14
.AUT16	move.b	5(a3,d2.W),d3
	ext.w	d3
	add.w	d3,d1
	bra.s	.AUT161
.nums2	dc.b	$0A,$02,$01,$00,$00,$0A,$06,$04,$03,$02
.AUT161	cmp.w	#2,d1
	beq.s	.AUT22
	lea	.nums3(PC),a3
	moveq	#1,d3
.AUT17	lsl.b	#1,d0
	bne.s	.AUT18
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT18	bcc.s	.AUT19
	dbf	d3,.AUT17
.AUT19	addq.w	#1,d3
	clr.w	d2
	move.b	0(a3,d3.W),d4
	ext.w	d4
.AUT20	lsl.b	#1,d0
	bne.s	.AUT21
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT21	roxl.w	#1,d2
	dbf	d4,.AUT20
	lsl.w	#1,d3
	add.w	4(a3,d3.W),d2
	bra.s	.AUT26

.nums3	dc.b	$0B,$04,$07,$00,$01,$20,$00,$00
	dc.b	$00,$20,$00,$00

.AUT22	clr.w	d2
	moveq	#5,d3
	clr.w	d4
	lsl.b	#1,d0
	bne.s	.AUT23
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT23	bcc.s	.AUT24
	moveq	#8,d3
	moveq	#$40,d4
.AUT24	lsl.b	#1,d0
	bne.s	.AUT25
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT25	roxl.w	#1,d2
	dbf	d3,.AUT24
	add.w	d4,d2
.AUT26	lea	0(a1,d2.W),a2
	ext.l	d1
	add.l	d1,a2
	subq.w	#1,d1
.AUT27	move.b	-(a2),-(a1)
	dbf	d1,.AUT27
	bra	.AUT2
.BYENOW	rts

; LSD depacker

LSD_depack
	move.l	store_end(PC),a0
	move.l	save_add(PC),a1
	move.l	-(a0),a2
	lea	upk_l(PC),a3
	move.l	a2,(a3)
	add.l	a1,a2
	lea	upk_end(PC),a3
	move.l	a2,(a3)
	move.l	-(a0),d5
	move.l	-(a0),d0
	eor.l	d0,d5
.LSD0B	lsr.l	#1,d0
	bne.s	.LSD0C
	bsr.s	.LSD18
.LSD0C	bcs.s	.LSD13
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.s	.LSD0D
	bsr.s	.LSD18
.LSD0D	bcs.s	.LSD15
	moveq	#3,d1
	clr.w	d4
.LSD0E	bsr.s	.LSD19
	move.w	d2,d3
	add.w	d4,d3
.LSD0F	moveq	#7,d1
.LSD10	lsr.l	#1,d0
	bne.s	.LSD11
	bsr.s	.LSD18
.LSD11	roxl.l	#1,d2
	dbf	d1,.LSD10
	move.b	d2,-(a2)
	dbf	d3,.LSD0F
	bra.s	.LSD17
.LSD12	moveq	#8,d1
	moveq	#8,d4
	bra.s	.LSD0E
.LSD13	moveq	#2,d1
	bsr.s	.LSD19
	cmp.b	#2,d2
	blt.s	.LSD14
	cmp.b	#3,d2
	beq.s	.LSD12
	moveq	#8,d1
	bsr.s	.LSD19
	move.w	d2,d3
	move.w	#$C,d1
	bra.s	.LSD15
.LSD14	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
.LSD15	bsr.s	.LSD19
.LSD16	subq.w	#1,a2
	move.b	0(a2,d2.W),(a2)
	dbf	d3,.LSD16
.LSD17	cmp.l	a2,a1
	blt.s	.LSD0B
	rts
.LSD18	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
	rts
.LSD19	subq.w	#1,d1
	clr.w	d2
.LSD1A	lsr.l	#1,d0
	bne.s	.LSD1B
	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
.LSD1B	roxl.l	#1,d2
	dbf	d1,.LSD1A
	rts

store_end	dcb.w	2,0
save_add	dcb.w	2,0
upk_l	dcb.w	2,0
store_start
	dcb.w	2,0
upk_end	dcb.w	2,0

; Depacker for pompey pirates v1.5 packer

pp_1_5_depack
	move.l	a4,a0
	move.l	-(a0),d6	
	move.l	-(a0),d2
	sub.l	d2,a2
	move.l	a2,a4
	add.l	d6,a2
	moveq	#0,d0
.pp150	move.b	-(a0),d0
	beq.s	.pp150
.pp151	moveq	#0,d2
	cmpa.l	a2,a0
	bgt	.exit
	bsr.s	.pp1515
	bcs.s	.pp154
	move.b	-(a0),d2
.pp152	move.b	d2,-(a2)
	bra.s	.pp156
.pp153	moveq	#15,d4
	moveq	#2,d3
	bsr.s	.pp1518
	bne.s	.pp1513
	move.w	d4,d2
	bra.s	.pp152
.pp154	bsr.s	.pp1515
	bcc.s	.pp159
	bsr.s	.pp1515
	bcc.s	.pp153
	bsr.s	.pp1515
	bcs.s	.pp155
	moveq	#2,d1
	bsr.s	.pp1522
	exg	d1,d2
	addq.w	#1,d2
	bset	d1,d2
	bra.s	.pp152
.pp155	bsr.s	.pp1515
	bcs.s	.pp158
	moveq	#15,d4
	moveq.w	#3,d3
	bsr.s	.pp1518
	bne.s	.pp1513
	move.b	(a2),-(a2)
.pp156	cmpa.l	a2,a4
	blt.s	.pp151
.pp157	rts
.pp158	moveq	#4,d3
	bra.s	.pp1512
.pp159	bsr.s	.pp1515
	bcs.s	.pp1527
	moveq	#1,d1
.pp1510	lsr.b	#1,d0
	bne.s	.pp1511
	move.b	-(a0),d0
	roxr.b	#1,d0
.pp1511	addx.w	d2,d2
	dbf	d1,.pp1510
	move.w	d2,d1
	beq.s	.pp1526
	addq.w	#1,d1
	add.w	d1,d1
	subq.w	#1,d1
	bsr.s	.pp1522
	move.w	d2,d3
.pp1512	bsr.s	.pp1517
.pp1513	movea.l	a2,a1
	adda.l	d2,a1
.pp1514	move.b	-(a1),-(a2)
	dbf	d3,.pp1514
	bra.s	.pp156
.pp1515	lsr.b	#1,d0
	bne.s	.pp1516
	move.b	-(a0),d0
	roxr.b	#1,d0
.pp1516	rts
.pp1517	moveq	#0,d4
.pp1518	moveq	#1,d1
	moveq	#0,d2
.pp1519	lsr.b	#1,d0
	bne.s	.thanks_jpm
.pp1520	move.b	-(a0),d0
	roxr.b	#1,d0
.thanks_jpm
	addx.w	d2,d2
	dbf	d1,.pp1519
	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	eor.b	d1,d4
	bne.s	.pp1522
	rts
.pp1521	moveq	#7,d1
.pp1522	moveq	#0,d2
.pp1523	lsr.b	#1,d0
	bne.s	.pp1525
.pp1524	move.b	-(a0),d0
	roxr.b	#1,d0
.pp1525	addx.w	d2,d2
	dbf	d1,.pp1523
	rts
.pp1526	bsr.s	.pp1517
	move.w	d2,d3
	moveq	#1,d2
	bra.s	.pp1513
.pp1527	moveq	#1,d3
	move.b	-(a0),d2
	bra.s	.pp1513
.exit	rts


; DCsquish v1.0 depacker

DCsquish_1_0_unpack
	movea.l	a5,a2
	move.l	a5,d2
.sq118	movea.l	a2,a1
	lea	$200(a2),a4
	bra.s	.sq11F
.sq119	movea.l	a4,a2
	movea.l	a2,a1
	lea	$200(a4),a4
.sq11A	moveq	#0,d0
	move.b	(a3)+,d0
	bclr	#7,d0
	bne.s	.sq11C
	subq.w	#1,d0
	bmi.s	.sq11F
.sq11B	move.b	(a3)+,(a2)+
	dbf	d0,.sq11B
	bra.s	.sq11F
.sq11C	moveq	#0,d1
	move.b	(a3)+,d1
	lsr.b	#1,d0
	bcc.s	.sq11D
	addi.w	#$100,d1
.sq11D	lea	0(a1,d1.W),a0
	subq.w	#1,d0
	bmi.s	.sq11F
.sq11E	move.b	(a0)+,(a2)+
	dbf	d0,.sq11E
.sq11F	cmpa.l	d2,a3
	bcc.s	.exit
	cmpa.l	a4,a2
	blt.s	.sq11A
	bra.s	.sq119
.exit	rts

; depacker for pompey pirates v1.9 packer 

pp_1_9_depack
	bsr.s	.getone
	move.l	d0,d5
	bsr.s	.unpack
	rts

.getone	moveq	#0,d1
	subq.l	#4,a3
.loop	asl.l	#8,d0
	move.b	(a3,d1.w),d0
	addq.w	#1,d1
	cmpi.w	#4,d1
	bne.s	.loop
	rts
.unpack	bsr.s	.getone
	movea.l	a3,a0	
	add.l	#$c,a3
	sub.l	d0,a3	
	movea.l	a3,a2	
	add.l	d5,a2	

.empty	move.b	-(a0),d0	
	beq.s	.empty	
.umain	moveq	#0,d2
	bsr.s	.shifter
	bcs.s	.rep

	move.b	-(a0),d2
.output	move.b	d2,-(a2)
	bra.s	.ecxit

.rep3	moveq	#15,d4
	moveq	#2,d3
	bsr.s	.leader
	bne.s	.rloop
	move.w	d4,d2
	bra.s	.output

.rep	bsr.s	.shifter
	bcc.s	.repeat
	bsr.s	.shifter
	bcc.s	.rep3
	bsr.s	.shifter
	bcs.s	.rep4
.special	moveq	#2,d1
	bsr	.nibit
	exg	d1,d2
	addq.w	#1,d2
	bset	d1,d2
	bra.s	.output
	
.rep4	bsr.s	.shifter
	bcc.s	.rep5	
	moveq	#15,d4	
	move.w	#3,d3
	bsr.s	.leader
	bne.s	.rloop
	move.b	(a2),-(a2)

.ecxit	cmpa.l	a2,a3
	blt.s	.umain
	rts

.rep5	moveq	#4,d3
	bra.s	.reps
.repeat	bsr.s	.shifter
	bcs.s	.rep2
	moveq	#1,d1
.1	lsr.b	#1,d0
	bne.s	.2
	move.b	-(a0),d0
	roxr.b	#1,d0
.2	addx.w	d2,d2
	dbf	d1,.1
	
	move.w	d2,d1	
	beq.s	.runing	
	addq.w	#1,d1
	add.w	d1,d1
	subq.w	#1,d1
	bsr.s	.nibit
	move.w	d2,d3
.reps	bsr.s	.lead1	
.rloop	movea.l	a2,a1
	add.l	d2,a1	
.replp	move.b	-(a1),-(a2)
	dbf	d3,.replp
	bra.s	.ecxit

.shifter	lsr.b	#1,d0
	bne.s	.noz
	move.b	-(a0),d0
	roxr.b	#1,d0
.noz	rts
.lead1	moveq	#0,d4
.leader	moveq	#1,d1

	moveq	#0,d2
.n1	lsr.b	#1,d0
	bne.s	.n2
	move.b	-(a0),d0
	roxr.b	#1,d0
.n2	addx.w	d2,d2
	dbf	d1,.n1

	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	eor.b	d1,d4
	bne.s	.nibit
	rts	
.nibs	moveq	#7,d1
.nibit	moveq	#0,d2
.nlp	lsr.b	#1,d0
	bne.s	.nlp1
	move.b	-(a0),d0
	roxr.b	#1,d0
.nlp1	addx.w	d2,d2
	dbf	d1,.nlp
	rts
.runing	bsr.s	.lead1
	move.w	d2,d3
	moveq	#1,d2
	bra.s	.rloop
.rep2	moveq	#1,d3
	move.b	-(a0),d2
	bra.s	.rloop

; depacker for pompey pirates v2.6 packer 

pp_2_6_depack
	movea.l	a0,a3
	lea	-$C(a0),a0
	suba.l	(a0),a3
	movea.l	a3,a2
	adda.l	4(a0),a2
.pp2_620	move.b	-(a0),d0
	beq.s	.pp2_620
.pp2_621	moveq	#0,d2
	bsr.s	.pp2_62B
	bcs.s	.pp2_624
	move.b	-(a0),d2
.pp2_622	move.b	d2,-(a2)
	bra.s	.pp2_626
.pp2_623	moveq	#$F,d4
	moveq	#2,d3
	bsr.s	.pp2_62E
	bne.s	.pp2_62A
	move.w	d4,d2
	bra.s	.pp2_622
.pp2_624	bsr.s	.pp2_62B
	bcc.s	.pp2_628
	bsr.s	.pp2_62B
	bcc.s	.pp2_623
	bsr.s	.pp2_62B
	bcs.s	.pp2_625
	moveq	#2,d1
	bsr.s	.pp2_631
	exg	d2,d1
	addq.w	#1,d2
	bset	d1,d2
	bra.s	.pp2_622
.pp2_625	bsr.s	.pp2_62B
	bcs.s	.pp2_627
	moveq	#$F,d4
	moveq	#3,d3
	bsr.s	.pp2_62E
	bne.s	.pp2_62A
	move.b	(a2),-(a2)
.pp2_626	cmpa.l	a2,a3
	blt.s	.pp2_621
	bra.s	.exit
.pp2_627	moveq	#4,d3
	bra.s	.pp2_629
.pp2_628	bsr.s	.pp2_62B
	bcs.s	.pp2_635
	moveq	#1,d1
	bsr.s	.pp2_631
	move.w	d2,d1
	beq.s	.pp2_634
	addq.w	#1,d1
	add.w	d1,d1
	subq.w	#1,d1
	bsr.s	.pp2_631
	move.w	d2,d3
.pp2_629	bsr.s	.pp2_62D
.pp2_62A	move.b	0(a2,d2.W),-(a2)
	dbf	d3,.pp2_62A
	bra.s	.pp2_626
.pp2_62B	lsr.b	#1,d0
	bne.s	.pp2_62C
	move.b	-(a0),d0
	roxr.b	#1,d0
.pp2_62C	rts
.pp2_62D	moveq	#0,d4
.pp2_62E	moveq	#1,d1
	moveq	#0,d2
.pp2_62F	lsr.b	#1,d0
	bne.s	.pp2_630
	move.b	-(a0),d0
	roxr.b	#1,d0
.pp2_630	addx.w	d2,d2
	dbf	d1,.pp2_62F
	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	eor.b	d1,d4
	bne.s	.pp2_631
	rts
.pp2_631	moveq	#0,d2
.pp2_632	lsr.b	#1,d0
	bne.s	.pp2_633
	move.b	-(a0),d0
	roxr.b	#1,d0
.pp2_633	addx.w	d2,d2
	dbf	d1,.pp2_632
	rts

.pp2_634	bsr.s	.pp2_62D
	move.w	d2,d3
	moveq	#0,d2
	bra.s	.pp2_62A
.pp2_635	moveq	#1,d3
	move.b	-(a0),d2
	bra.s	.pp2_62A
.exit	rts

; DCSquish v1.2 depacker

DCsquish_1_2_unpack
	movea.l	a5,a2
.sq21A	move.w	#$16,d0
	beq.s	.sq21C
.sq21B	move.w	(a3)+,(a2)+
	dbf	d0,.sq21B
.sq21C	moveq	#7,d7
	moveq	#6,d4
	moveq	#5,d3
	moveq	#3,d2
.sq21D	moveq	#0,d0
	move.b	(a3)+,d0
	bmi.s	.sq220
	beq.s	.exit
	bclr	d4,d0
	beq.s	.sq21F
	move.w	d0,d1
	lsl.w	d2,d1
	bclr	d3,d0
	addq.w	#2,d0
	bra.s	.sq222
.sq21E	move.b	(a3)+,(a2)+
.sq21F	dbf	d0,.sq21E
	bra.s	.sq21D
.sq220	bclr	d7,d0
	move.w	d0,d1
	lsl.w	d3,d1
	and.b	d7,d0
	bne.s	.sq221
	move.b	(a3)+,d0
	addq.w	#8,d0
.sq221	addq.w	#1,d0
.sq222	move.b	(a3)+,d1
	movea.l	a2,a0
	suba.w	d1,a0
.sq223	move.b	(a0)+,(a2)+
	dbf	d0,.sq223
	bra.s	.sq21D
.exit	rts

; DCSquish v1.4 depacker

DCsquish_1_4_unpack
	move.l	a5,a2
	move.w	#0,d0
	beq.s	.sq41C
.sq41B	move.w	(a3)+,(a2)+
	dbf	d0,.sq41B
.sq41C	moveq	#3,d2
	moveq	#5,d3
	moveq	#6,d4
	moveq	#7,d7
.sq41D	moveq	#0,d0
	move.b	(a3)+,d0
	bmi.s	.sq420
	beq.s	.exit
	bclr	d4,d0
	beq.s	.sq41F
	move.w	d0,d1
	lsl.w	d2,d1
	bclr	d3,d0
	addq.w	#2,d0
	bra.s	.sq422
.sq41E	move.b	(a3)+,(a2)+
.sq41F	dbf	d0,.sq41E
	bra.s	.sq41D
.sq420	bclr	d7,d0
	move.w	d0,d1
	lsl.w	d3,d1
	and.b	d7,d0
	bne.s	.sq421
	move.b	(a3)+,d0
	addq.w	#8,d0
.sq421	addq.w	#1,d0
.sq422	move.b	(a3)+,d1
	move.l	a2,a0
	suba.w	d1,a0
.sq423	move.b	(a0)+,(a2)+
	dbf	d0,.sq423
	bra.s	.sq41D
.exit	rts

; 4pak depacker

_4pak_depack
	bra.s	._4p05
._4p02	moveq	#$1F,d1
	and.w	d0,d1
	lsl.w	#3,d0
	move.b	(a1)+,d0
	lea	-$800(a0),a2
	add.w	d0,a2
	move.b	(a2)+,(a0)+
	move.b	(a2)+,(a0)+
._4p03	move.b	(a2)+,(a0)+
	dbf	d1,._4p03
	bra.s	._4p05
._4p04	move.b	(a1)+,(a0)+
	dbf	d0,._4p04
._4p05	moveq	#0,d0
	move.b	(a1)+,d0
	blt.s	._4p02
	dbeq	d0,._4p04
	rts

; PFX depacker

pfx2_1_depack	
	movep.w	$E(a4),d4
	move.b	$D(a4),d4
	swap	d4
	movep.w	$C(a4),d4
	move.b	$B(a4),d4
	move.l	d4,unpacked_length
	moveq	#2,d0
	add.b	(a4),d0
	adda.w	d0,a4
	move.l	a6,save_here
	movea.l	a6,a3
	moveq	#0,d7
	move.l	a6,d5
	sub.l	#$FED,d5
	move.w	#$FFF,d3
	dbf	d7,.pfx08
.pfx07	move.b	(a4)+,d6
	moveq	#7,d7
.pfx08	lsr.b	#1,d6
	bcc.s	.pfx09
	move.b	(a4)+,(a6)+
	subq.l	#1,d4
	ble.s	.exit
	dbf	d7,.pfx08
	bra.s	.pfx07
.pfx09	movep.w	1(a4),d0
	lsr.w	#4,d0
	move.b	(a4)+,d0
	move.l	a6,d1
	sub.l	d5,d1
	and.w	d3,d1
	sub.w	d1,d0
	neg.w	d0
	and.w	d3,d0
	neg.w	d0
	lea	-1(a6,d0.W),a0
	moveq	#$F,d1
	and.b	(a4)+,d1
	addq.w	#2,d1
	moveq	#1,d0
	add.w	d1,d0
.pfx0A	move.b	(a0)+,(a6)+
	dbf	d1,.pfx0A
	sub.l	d0,d4
	ble.s	.exit
	dbf	d7,.pfx08
	bra.s	.pfx07
.exit	rts

get_bit	macro
	add.l	d6,d6		get bit
	bne.s	.gb\@		if empty then
	move.l	(a0)+,d6	get next long
	eor.l	d6,d7		update checksum
	move.b	#%10000,ccr	get bit and set marker
	addx.l	d6,d6
.gb\@
	endm

dp_qpak
	move.l	a1,a6
	lea	.head(pc),a2
	moveq	#4-1,d0
.valid	cmpm.l	(a0)+,(a2)+
	bne	.error1
	dbra	d0,.valid
	move.l	a1,a2		end of dest=dest+length of unpacked file
	add.l	(a0)+,a2
	move.l	(a0)+,d7	d7=checksum
	moveq	#0,d6		empty source
.loop	get_bit
	bcs	.com1xx
	get_bit
	bcs	.com01
.com00	moveq	#0,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
.com00_loop
	get_bit			command %00nnn, insert 1..8 bytes
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	move.b	d0,(a1)+
	dbra	d2,.com00_loop
	cmp.l	a2,a1
	bcs	.loop
	bra.s	.done
.com01	moveq	#8-1,d1		command %01aaaaaaaa, copy 2 bytes
	moveq	#2-1,d2
	bra.s	.copy
.com1xx	get_bit
	bcs.s	.com11x
	get_bit
	bcs.s	.com101
.com100	moveq	#9-1,d1		command %100a..a, copy 3 bytes
	moveq	#3-1,d2
	bra.s	.copy
.com101	moveq	#10-1,d1	command %101a..a, copy 4 bytes
	moveq	#4-1,d2
	bra.s	.copy
.com11x	get_bit
	bcs.s	.com111
.com110	bsr.s	.get_byte	command %110n..na..a, copy 3..258 bytes
	addq.w	#3-1,d2
	moveq	#12-1,d1
.copy	moveq	#0,d0
.copy2	get_bit
	addx.w	d0,d0
	dbra	d1,.copy2
	lea	-1(a1),a3
	sub.w	d0,a3			copy from dest-offset-1
.copy3	move.b	(a3)+,(a1)+
	dbra	d2,.copy3
	cmp.l	a2,a1
	bcs	.loop
	bra.s	.done
.com111	bsr.s	.get_byte		command %111n..n, insert 9..264 bytes
	addq.w	#9-1,d2
	bra	.com00_loop
.done	bne.s	.error3
	move.l	a6,a0			start
	move.l	a2,a1			end
	move.l	d7,d0
	bne.s	.error2
	rts
.error1	moveq	#1,d0
	rts
.error2	moveq	#2,d0
	rts
.error3	moveq	#3,d0
	rts

.get_byte
	moveq	#0,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	rts

.head	dc.b	'QPAC2-JMP(C)1989'
	even


; bytekiller depacker

bytekiller_depack
	move.l	a6,a0
	move.l	a5,a1
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d5
	move.l	a1,a2
	add.l	d0,a0
	add.l	d1,a2
	move.l	-(a0),d0
	eor.l	d0,d5
.BYT00	lsr.l	#1,d0
	bne.s	.BYT01
	bsr.s	.BYT0E
.BYT01	bcs.s	.BYT08
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.s	.BYT02
	bsr.s	.BYT0E
.BYT02	bcs.s	.BYT0A
	moveq	#3,d1
	clr.w	d4
.BYT03	bsr.s	.BYT0F
	move.w	d2,d3
	add.w	d4,d3
.BYT04	moveq	#7,d1
.BYT05	lsr.l	#1,d0
	bne.s	.BYT06
	bsr.s	.BYT0E
.BYT06	roxl.l	#1,d2
	dbf	d1,.BYT05
	move.b	d2,-(a2)
	dbf	d3,.BYT04
	bra.s	.BYT0C
.BYT07	moveq	#8,d1
	moveq	#8,d4
	bra.s	.BYT03
.BYT08	moveq	#2,d1
	bsr.s	.BYT0F
	cmp.b	#2,d2
	blt.s	.BYT09
	cmp.b	#3,d2
	beq.s	.BYT07
	moveq	#8,d1
	bsr.s	.BYT0F
	move.w	d2,d3
	move.w	#$C,d1
	bra.s	.BYT0A
.BYT09	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
.BYT0A	bsr.s	.BYT0F
.BYT0B	subq.w	#1,a2
	move.b	0(a2,d2.W),(a2)
	dbf	d3,.BYT0B
.BYT0C	cmp.l	a2,a1
	blt.s	.BYT00
	tst.l	d5
	beq.s	.BYT0D
	nop
.BYT0D	rts
.BYT0E	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
	rts
.BYT0F	subq.w	#1,d1
	clr.w	d2
.BYT10	lsr.l	#1,d0
	bne.s	.BYT11
	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
.BYT11	roxl.l	#1,d2
	dbf	d1,.BYT10
	rts

; Gollum depacker

gollum_depacker_huff
.GHF01	bra.s	.GHF05
.GHF03	dcb.w	2,0
.upl	dc.l	0
.GHF05	pea	.GHF01(PC)
	lea	698(a0),a1
	move.l	a1,save_here
	move.l	144(a0),unpacked_length
	move.l	144(a0),.upl
	move.l	file_length(pc),.GHF00
	lea	698(a0),a0
	move.l	a0,-(a7)
	move.l	.upl(PC),d0
	addq.l	#8,d0
	add.l	d0,a0
	move.l	a0,-(a7)
	add.l	d0,a0
	lea	.GHF03(PC),a1
	move.l	a0,(a1)
	move.l	4(a7),a4
	lea	$100(a4),a2
	lea	$300(a4),a0
	move.l	(a7),a1
	move.l	.GHF03(PC),a6
	moveq	#0,d0
	move.l	d0,d2
	move.l	d0,d1
.GHF06	move.w	(a2)+,d1
	moveq	#$10,d2
	sub.b	(a4)+,d2
	bmi.s	.GHF08
	moveq	#1,d3
	lsl.l	d2,d3
	lea	0(a6,d1.L),a5
.GHF07	move.b	d0,(a5)+
	subq.l	#1,d3
	bne.s	.GHF07
.GHF08	addq.w	#1,d0
	cmp.w	#$100,d0
	bne.s	.GHF06
	move.l	.GHF03(PC),a5
	move.l	4(a7),a4
	lea	$100(a4),a2
	move.l	(a7),a1
	lea	$300(a4),a0
	move.l	4(a7),a6
	move.l	.GHF00(PC),d0
	add.l	d0,a6
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	move.w	(a0),d0
.GHF09	move.b	0(a5,d0.L),d1
	move.b	d1,(a1)+
	add.b	0(a4,d1.W),d3
	cmp.w	#$10,d3
	bcs.s	.GHF0A
	addq.l	#2,a0
	sub.w	#$10,d3
.GHF0A	move.l	(a0),d0
	lsl.l	d3,d0
	clr.w	d0
	swap	d0
	cmp.l	a6,a0
	bcs.s	.GHF09
	move.l	4(a7),d0
	move.l	(a7),4(a7)
	move.l	d0,(a7)
	move.l	4(a7),a0
	move.l	(a7),a1
	lea	.GHF11(PC),a3
	move.l	a1,d2
.GHF0B	clr.w	d0
	move.b	(a0)+,d0
	move.w	d0,d1
	subq.w	#1,d0
	bmi.s	.GHF0D
.GHF0C	move.b	(a0)+,(a1)+
	dbf	d0,.GHF0C
	cmp.w	#$FF,d1
	beq.s	.GHF0B
.GHF0D	moveq	#0,d0
	move.b	(a0)+,(a3)
	bmi.s	.GHF0F
	move.b	(a0)+,1(a3)
	move.w	(a3),d0
	lsr.w	#5,d0
	tst.w	d0
	beq.s	.EXIT
	move.l	a1,a4
	suba.w	d0,a4
	move.w	(a3),d0
	andi.w	#$1F,d0
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.GHF0E	move.b	(a4)+,(a1)+
	dbf	d0,.GHF0E
	bra.s	.GHF0B
.GHF0F	move.b	(a0)+,1(a3)
	move.w	(a3),d0
	andi.w	#$7FFF,d0
	move.l	a1,a4
	suba.w	d0,a4
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.GHF10	move.b	(a4)+,(a1)+
	dbf	d0,.GHF10
	bra.s	.GHF0B
.GHF11	dcb.w	2,0
.EXIT	lea	12(a7),a7
	rts
.GHF00	dc.l	0

; Gollum depacker

gollum_depacker
.GOL00	bra.s	.GOL04
.GOL02	dcb.w	2,0
.GOL03	dc.l	0

.GOL04	move.l	144(a0),.GOL03
	move.l	144(a0),unpacked_length
	lea	564(a0),a0
	pea	.GOL00(PC)
	move.l	a0,-(a7)
	move.l	.GOL03(PC),d0
	addq.l	#8,d0
	add.l	d0,a0
	move.l	a0,-(a7)
	add.l	d0,a0
	lea	.GOL02(PC),a1
	move.l	a0,(a1)
	move.l	4(a7),a0
	move.l	(a7),a1
	lea	.GOL0C(PC),a3
	move.l	a1,d2
.GOL05	clr.w	d0
	move.b	(a0)+,d0
	move.w	d0,d1
	subq.w	#1,d0
	bmi.s	.GOL07
.GOL06	move.b	(a0)+,(a1)+
	dbf	d0,.GOL06
	cmp.w	#$FF,d1
	beq.s	.GOL05
.GOL07	moveq	#0,d0
	move.b	(a0)+,(a3)
	bmi.s	.GOL09
	move.b	(a0)+,1(a3)
	move.w	(a3),d0
	lsr.w	#5,d0
	tst.w	d0
	beq.s	.exit
	move.l	a1,a4
	suba.w	d0,a4
	move.w	(a3),d0
	andi.w	#$1F,d0
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.GOL08	move.b	(a4)+,(a1)+
	dbf	d0,.GOL08
	bra.s	.GOL05
.GOL09	move.b	(a0)+,1(a3)
	move.w	(a3),d0
	andi.w	#$7FFF,d0
	move.l	a1,a4
	suba.w	d0,a4
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	(a4)+,(a1)+
.GOL0A	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.GOL0B	move.b	(a4)+,(a1)+
	dbf	d0,.GOL0B
	bra.s	.GOL05
.GOL0C	dcb.w	2,0
.exit	lea	12(a7),a7
	rts

; Happy depacker
; I hate this, it was pulling so many values
; from the basepage that in the end I just
; build a dummy basepage for it to use. Oh and
; each program packed has a slightly different
; depacker which is very annoying.

happy_depacker
	lea	$898(a0),a1
	move.l	a1,save_here

	movem.l	776(a0),d0-1
	movem.l	d0-1,.HAP19
	lea	1456(a0),a1
	lea	.HAP34,a2
	move.l	#400-1,d0
.1	move.b	(a1)+,(a2)+
	dbf	d0,.1
	move.l	1430(a0),.upl
	move.l	1430(a0),unpacked_length
	move.l	1434(a0),.pkl
	lea	$1c(a0),a1
	move.l	a1,.p_start
	move.l	2(a0),.p_size
	add.l	2(a0),a1
	move.l	a1,.d_start
	move.l	6(a0),.d_size
	add.l	6(a0),a1
	move.l	a1,.b_start
	move.l	10(a0),.b_size
	bra.s	.begin

.basepage	dc.l	.basepage
.b1	dc.l	0
.p_start	dc.l	0
.p_size	dc.l	0
.d_start	dc.l	0
.d_size	dc.l	0
.b_start	dc.l	0
.b_size	dc.l	0

.begin	move.l	a7,a6
	lea	.basepage(pc),a5
	move.l	$18(a5),d0
.HAP07	bsr	.HAP22
	add.l	$1C(a5),d0
	add.l	#$100,d0
	addq.l	#1,d0
.HAP08	move.l	d0,a3
	move.l	d0,d7
	move.l	$18(a5),a4
	move.l	$14(a5),d0
.HAP09	move.b	-(a4),-(a3)
	subq.l	#1,d0
	bne.s	.HAP09
	move.l	$10(a5),a4
	lea	.HAP19(PC),a2
.HAP0A	move.b	(a3),d0
	cmp.b	1(a2),d0
	beq.s	.HAP0C
	cmp.b	3(a2),d0
	beq.s	.HAP0E
	cmp.b	5(a2),d0
	beq.s	.HAP10
	move.b	(a3)+,(a4)+
.HAP0B	cmp.l	a3,d7
	bcs.s	.HAP13
	bra.s	.HAP0A
.HAP0C	addq.l	#1,a3
	clr.w	d1
	move.b	(a3)+,d2
	move.b	(a3)+,d1
	subq.w	#1,d1
.HAP0D	move.b	d2,(a4)+
	dbf	d1,.HAP0D
	bra.s	.HAP0B
.HAP0E	addq.l	#1,a3
	clr.w	d1
	move.b	(a3)+,d1
	move.b	7(a2),d2
	subq.w	#1,d1
.HAP0F	move.b	d2,(a4)+
	dbf	d1,.HAP0F
	bra.s	.HAP0B
.HAP10	addq.l	#1,a3
	moveq	#0,d6
	moveq	#0,d5
	move.b	1(a3),d6
	subq.b	#1,d6
.HAP11	clr.w	d5
	move.b	(a3),d5
	subq.b	#1,d5
	lea	2(a3),a1
.HAP12	move.b	(a1)+,(a4)+
	dbf	d5,.HAP12
	dbf	d6,.HAP11
	moveq	#0,d6
	move.b	(a3),d6
	lea	2(a3),a3
	add.l	d6,a3
	bra.s	.HAP0B
.HAP13	lea	.HAP2A(PC),a0
.exit	rts

.HAP19	dc.b	$00,$0F,$00,$13,$00,$17,$00,$00

.HAP22	movem.l	a0-a6/D0-d7,-(a7)
	lea	.HAP2B(PC),a6
	move.l	d0,(a6)
	lea	.HAP2C(PC),a6
	lea	.HAP42(PC),a6
	move.l	a5,(a6)
	lea	.HAP2F(PC),a0
	move.l	a7,(a0)
	move.l	$18(a5),a0
	lea	.HAP31(PC),a6
	move.l	$14(a5),(a6)
	add.l	$1C(a5),a0
	lea	$2000(a0),a0
	lea	-$1388(a7),a7
	lea	.HAP32(PC),a6
	move.l	a7,(a6)
	lea	-$A(a7),a7
.HAP23	moveq	#7,d7
	lea	.HAP34(PC),a5
	move.w	#0,-(a7)
	lea	.HAP33(PC),a6
	clr.w	(a6)
	bsr	.HAP37
	addq.l	#2,a7
	bsr	.HAP40
	lea	.HAP30(PC),a6
	move.l	a2,(a6)
	move.l	a2,d0
	lea	.HAP31(PC),a6
	add.l	d0,(a6)
	addq.l	#2,(a6)
	moveq	#7,d7
	move.l	a2,a5
	move.l	.HAP32(PC),a2
	move.l	load_here(pc),a4
	lea	$898(a4),a4
	lea	.HAP31(PC),a6
	move.l	(a6),a3
.HAP24	cmp.l	a5,a3
	bls.s	.HAP29
	move.l	a2,a0
.HAP25	cmp.w	#0,(a0)
	beq.s	.HAP28
	bsr	.HAP3C
	tst.w	d0
	beq.s	.HAP26
	move.w	4(a0),d1
	bra.s	.HAP27
.HAP26	move.w	2(a0),d1
.HAP27	and.l	#$FFFF,d1
	lsl.l	#3,d1
	move.l	a2,a0
	add.l	d1,a0
	bra.s	.HAP25
.HAP28	move.b	7(a0),(a4)+
	bra.s	.HAP24
.HAP29	lea	.HAP2C(PC),a6
	lea	.HAP2B(PC),a6
	lea	.HAP42(PC),a1
	move.l	(a1),a0
	move.l	$10(a0),d0
	lea	.pkl(PC),a6
	move.l	(a6),$14(a0)
	add.l	$14(a0),d0
	move.l	d0,$18(a0)
	lea	.HAP2F(PC),a6
	move.l	(a6),a7
	movem.l	(a7)+,a0-a6/D0-d7
	move.l	$18(a5),d0
	rts

.HAP2A	dc.b	$00,$00
.HAP2B	dcb.w	2,0
.HAP2C	dc.b	$00,$00
.upl	dc.b	$00,$00,$09,$C5
.pkl	dc.b	$00,$00,$08,$B4
.HAP2F	dcb.w	2,0
.HAP30	dcb.w	2,0
.HAP31	dcb.w	2,0
.HAP32	dcb.w	2,0
.HAP33	dc.b	$00,$00

.HAP34	ds.b	400

.HAP37	bsr.s	.HAP3C
	tst.b	d0
	beq.s	.HAP38
	lea	.HAP32(PC),a6
	move.l	(a6),a0
	move.w	4(a7),d0
	and.l	#$FFFF,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.w	#-1,(a0)
	lea	.HAP33(PC),a6
	addq.w	#1,(a6)
	move.w	(a6),2(a0)
	move.l	a0,-(a7)
	move.w	2(a0),-(a7)
	bsr.s	.HAP37
	addq.l	#2,a7
	move.l	(a7)+,a0
	lea	.HAP33(PC),a6
	addq.w	#1,(a6)
	move.w	(a6),4(a0)
	move.w	4(a0),-(a7)
	bsr.s	.HAP37
	addq.l	#2,a7
	rts
.HAP38	lea	.HAP32(PC),a6
	move.l	(a6),a0
	move.w	4(a7),d0
	and.l	#$FFFF,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.w	#0,(a0)
	moveq	#7,d1
	clr.w	d2
.HAP39	bsr.s	.HAP3C
	tst.w	d0
	beq.s	.HAP3A
	bset	d1,d2
	bra.s	.HAP3B
.HAP3A	bclr	d1,d2
.HAP3B	subq.w	#1,d1
	cmp.w	#-1,d1
	bne.s	.HAP39
	move.w	d2,6(a0)
	rts
.HAP3C	btst	d7,(a5)
	beq.s	.HAP3D
	move.w	#-1,d0
	bra.s	.HAP3E
.HAP3D	clr.w	d0
.HAP3E	subq.w	#1,d7
	cmp.w	#-1,d7
	beq.s	.HAP3F
	rts

.HAP3F	moveq	#7,d7
	addq.l	#1,a5
	rts

.HAP40	lea	.HAP42(PC),a0
	move.l	(a0),a1
	move.l	a1,a0
	move.l	$10(a0),a1
	move.l	a1,a2
	add.l	$14(a0),a1
	move.l	$14(a0),d0
	lea	.upl(PC),a0
	add.l	(a0),a2
	move.l	(a0),d1
	lsr.l	#3,d1
	add.l	d1,a2
	addq.l	#1,a2
	addq.l	#1,a1
	addq.l	#1,d0
.HAP41	move.b	-(a1),-(a2)
	subq.l	#1,d0
	bne.s	.HAP41
	rts

.HAP42	dcb.w	2,0

; Thunder v2 depacker

thunder_depack
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	a2,a0
	add.l	8(a0),a0
	add.l	#12,a2	
	sub.l	-(a0),a0
	movea.l	a0,a3	
	moveq	#0,d7
	bset	#15,d7
.m1	moveq	#0,d1
	bsr.s	.u3
	bcc.s	.u7
	bsr.s	.u3
	bcs.s	.r23
	bra.s	.u9
.u7	move.b	(a0)+,(a4)+
.u30	cmpa.l	a3,a2
	ble.s	.m1
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.u8	move.b	d1,(a4)+
	bra.s	.u30
.u9	moveq.w	#2,d2
.u1	bsr.s	.u3
	roxl.b	#1,d1
	dbf	d2,.u1
	cmpi.w	#1,d1
	beq.s	.u21
	ble.s	.u8
	bsr.s	.u14
.u20	move.w	d2,d0
	bsr.s	.u4
.u18	movea.l	a4,a1	
	sub.l	d2,a1
.mlp	move.b	(a1)+,(a4)+
	dbf	d0,.mlp
	bra.s	.u30
.u21	move.w	#9,d0
.u22	move.b	(a0)+,(a4)+
	dbf	d0,.u22
	bra.s	.u30
.u3	lsl.w	#1,d7
	bne.s	.u10
	move.w	(a2)+,d7
	lsl.w	#1,d7
	bset	#0,d7
.u10	rts
.r23	bsr.s	.u3
	bcc.s	.u19
	moveq	#1,d0
	moveq	#0,d2
	move.b	(a0)+,d2
	bra.s	.u18
.u19	moveq.w	#3,d2
.u11	bsr.s	.u3
	roxl.b	d1
	dbf	d2,.u11
	cmpi.w	#1,d1
	beq.s	.u17
	blt.s	.u12
	bsr.s	.u14
	moveq	#2,d0
	bra.s	.u18
.u17	move.b	(a0,d2.w),(a4)+
	bra.s	.u30
.u16	bsr.s	.u4
	bra.s	.u20
.u12	bsr.s	.u4
	move.w	d2,d0
	beq.s	.u16
	bsr.s	.u3
	bcc.s	.u2
	moveq	#0,d2
	bra.s	.u15
.u2	move.b	(a0)+,d2
.u15	move.b	d2,(a4)+
	dbf	d0,.u15
	bra	.u30
.u4	moveq	#3,d2
.u5	bsr.s	.u3
	roxl.b	d1
	dbf	d2,.u5
.u14	moveq	#0,d2
	move.b	d1,d1
	beq.s	.u6
	subq.w	#1,d1
.u13	lsl.w	#1,d7
	bne.s	.u77
	move.w	(a2)+,d7
	lsl.w	#1,d7
	bset	#0,d7
.u77	roxl.w	d2
	dbf	d1,.u13
	moveq	#0,d1
.u6	rts

; Speed packer v2 depacker

speed2_depack
	movem.l	d1-a6,-(sp)
	clr.l	-(sp)
	cmp.l	#'SP20',(a0)+
	bne.s	.sp2_05
	tst.w	(a0)
	bne.s	.sp2_05
	move.l	a0,a5
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d1,(sp)
.sp2_01:	lea	64(a0),a1
	move.l	a1,a2
	add.l	d0,a0
	add.l	d1,a1
	move.l	a1,a3
	move.l	sp,a6
	moveq	#79,d0
.sp2_02:	move.b	-(a3),-(a6)
	dbf	d0,.sp2_02
	exg.l	a6,sp
	bsr.s	.sp2_06
	lea	-80(a1),a3
	move.l	(a6),d0
.sp2_03:	move.b	(a1)+,(a3)+
	subq.l	#1,d0
	bne.s	.sp2_03
	exg.l	a6,sp
	moveq	#79,d0
.sp2_04:	move.b	(a6)+,(a3)+
	dbf	d0,.sp2_04
.sp2_05:	movem.l	(sp)+,d0-a6
	rts	
.sp2_06:	moveq	#0,d6
	moveq	#1,d7
	lea	.sp2_38(pc),a3
	jsr	(a3)
	roxr.l	d7,d0
.sp2_07:	add.l	d0,d0
	bne.s	.sp2_08
	jsr	(a3)
.sp2_08:	bcs.s	.sp2_24
	move.b	-(a0),d1
	bra.s	.sp2_13
.sp2_09:	moveq	#2,d2
	bsr.s	.sp2_16
	move.l	d6,d1
	bset	d2,d1
	bra.s	.sp2_13
.sp2_10:	add.l	d0,d0
	bne.s	.sp2_11
	jsr	(a3)
.sp2_11:	bcs	.sp2_33
	moveq	#3,d2
	bsr.s	.sp2_16
	add.w	d7,d2
	lsr.w	d7,d2
	bcc.s	.sp2_12
	not.w	d2
.sp2_12:	move.b	(a1),d1
	add.w	d2,d1
.sp2_13:	move.b	d1,-(a1)
	clr.w	(a5)
.sp2_14: cmp.l	a1,a2
	bne.s	.sp2_07
	swap	d5
	move.w	d5,(a5)
	rts
.sp2_15:	move.l	d7,d2
.sp2_16:	move.l	d6,d1
.sp2_17:	add.l	d0,d0
	bne.s	.sp2_18
	jsr	(a3)
.sp2_18:	addx	d1,d1
	dbf	d2,.sp2_17
.sp2_19:	move.l	d1,d2
	rts
.sp2_20:	bsr.s	.sp2_15
.sp2_21:	beq.s	.sp2_22
	move.b	-(a0),d1
	subq.w	#2,d2
	bcs.s	.sp2_19
.sp2_22:	add.w	d7,d2
	add.w	d2,d2
.sp2_23:	add.w	d2,d2
	sub.w	d7,d2
	bra.s	.sp2_17
.sp2_24:	add.l	d0,d0
	bne.s	.sp2_25
	jsr	(a3)
.sp2_25:	bcs.s	.sp2_27
	add.l	d0,d0
	bne.s	.sp2_26
	jsr	(a3)
.sp2_26:	bcs.s	.sp2_10
	move.l	d6,d1
	move.b	-(a0),d1
	moveq	#0,d3
	bra.s	.sp2_36
.sp2_27:	add.l	d0,d0
	bne.s	.sp2_28
	jsr	(a3)
.sp2_28:	bcs.s	.sp2_29
	bsr.s	.sp2_15
	beq.s	.sp2_13
	moveq	#1,d3
	bra.s	.sp2_35
.sp2_29:	add.l	d0,d0
	bne.s	.sp2_30
	jsr	(a3)
.sp2_30:	bcs	.sp2_09
	add.l	d0,d0
	bne.s	.sp2_31
	jsr	(a3)
.sp2_31:	bcs.s	.sp2_32
	bsr.s	.sp2_15
	beq.s	.sp2_12
	moveq	#2,d3
	bra.s	.sp2_35
.sp2_32:	moveq	#3,d3
	bsr.s	.sp2_20
	bra.s	.sp2_36
.sp2_33:	bsr.s	.sp2_15
	beq.s	.sp2_34
	move.l	d6,d1
	add.w	d7,d2
	bsr.s	.sp2_23
	move.l	d2,d3
	bsr.s	.sp2_20
	bra.s	.sp2_36
.sp2_34:	bsr.s	.sp2_20
	not.l	d1
	move.l	d2,d3
	bra.s	.sp2_36
.sp2_35:	move.l	d6,d1
	sub.w	d7,d2
	bsr.s	.sp2_21
.sp2_36:	move.l	a1,a4
	addq.l	#2,a4
	add.l	d1,a4
	add.l	d3,a4
	move.b	-(a4),-(a1)
.sp2_37:	move.b	-(a4),-(a1)
	dbf	d3,.sp2_37
	move.w	d5,(a5)
	bra	.sp2_14
.sp2_38:	move.w	a0,d4
	btst	d6,d4
	bne.s	.sp2_39
	move.l	-(a0),d0
	addx.l	d0,d0
	rts
.sp2_39:	move.l	-5(a0),d0
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	add.l	d0,d0
	bset	d6,d0
	rts

; speed packer 3 depacker

speed3_depack
	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	.sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	.sp3_02
	tst.w	(a1)
	bne.s	.sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	.sp3_58-.sp3_53(a6),a3
	moveq	#128-1,d0
.sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,.sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	.sp3_03
	bsr	.sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	.sp3_58-.sp3_53(a6),a2
	bsr	.sp3_22
	bsr	.sp3_15
.sp3_02:	movem.l	(sp)+,d0-a6
	rts
.sp3_03:
;	move.w	SR,d1
;	andi.w	#$2000,d1
;	beq.s	.sp3_04
;	move.w	$FFFF8240.W,2(a6)
;	btst	#1,$FFFF8260.W
;	bne.s	.sp3_04
;	swap	d5
.sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	.sp3_54-.sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
.sp3_05:	cmp.b	d6,d3
	bne.s	.sp3_06
	addq.w	#2,d3
.sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,.sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	.sp3_57-.sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
.sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,.sp3_07
	move.b	-(a0),-(a3)
	beq.s	.sp3_08
	suba.w	d4,a0
.sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
.sp3_09:	bsr.s	.sp3_10
	bsr.s	.sp3_10
	dbf	d2,.sp3_09
	rts
.sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	.sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
.sp3_11:	bcs.s	.sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
.sp3_12:	moveq	#2,d1
	bsr	.sp3_44
	add.w	d0,d0
	beq.s	.sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	.sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
.sp3_13:	moveq	#2,d1
	bsr	.sp3_44
	move.w	.sp3_55-.sp3_53(a6),d1
	add.w	d0,d0
	beq.s	.sp3_14
	move.w	.sp3_55+2-.sp3_53(a6),d1
.sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
.sp3_15:
;	move.w	SR,d1
;	andi.w	#$2000,d1
;	beq.s	.sp3_16
;	move.w	2(a6),$FFFF8240.W
.sp3_16:	tst.w	d6
	bpl.s	.sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
.sp3_17:	moveq	#3,d6
.sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
.sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,.sp3_19
	dbf	d6,.sp3_18
	cmpa.l	a2,a3
	blt.s	.sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	.sp3_17
.sp3_20:	rts
.sp3_21:	move.b	-(a0),-(a1)
.sp3_22:	swap	d5
;	beq.s	.sp3_23
;	move.w	d5,$FFFF8240.W
.sp3_23:	lea	.sp3_56+2-.sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	.sp3_25
	rts
.sp3_24:	adda.w	d3,a3
.sp3_25:	add.b	d7,d7
	bcc.s	.sp3_28
	beq.s	.sp3_27
.sp3_26:	move.w	(a3),d3
	bmi.s	.sp3_24
	bra.s	.sp3_29
.sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	.sp3_26
.sp3_28:	move.w	-(a3),d3
	bmi.s	.sp3_24
.sp3_29:	ext.w	d3
	jmp	.sp3_30(pc,d3.w)
.sp3_30:	bra.s	.sp3_30
	bra.s	.sp3_41
	bra.s	.sp3_41
	bra.s	.sp3_41
	bra.s	.sp3_41
	bra.s	.sp3_41
	bra.s	.sp3_37
	bra.s	.sp3_36
	bra.s	.sp3_32
	bra.s	.sp3_33
	bra.s	.sp3_31
	bra.s	.sp3_34
	bra.s	.sp3_21
.sp3_31:	move.b	(a5),-(a1)
	bra.s	.sp3_22
.sp3_32:	bsr.s	.sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	.sp3_22
.sp3_33:	bsr.s	.sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	.sp3_22
.sp3_34:	moveq	#3,d1
	bsr.s	.sp3_44
	lsr.w	#1,d0
	bcc.s	.sp3_35
	not.w	d0
.sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	.sp3_22
.sp3_36:	lea	.sp3_52-2-.sp3_53(a6),a4
	bsr.s	.sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	.sp3_22
.sp3_37:	moveq	#3,d1
	bsr.s	.sp3_44
	tst.w	d0
	beq.s	.sp3_38
	addq.w	#5,d0
	bra.s	.sp3_40
.sp3_38:	move.b	-(a0),d0
	beq.s	.sp3_39
	addi.w	#20,d0
	bra.s	.sp3_40
.sp3_39:	moveq	#13,d1
	bsr.s	.sp3_44
	addi.w	#276,d0
.sp3_40:	move.w	d0,d3
	add.w	d3,d3
.sp3_41:	lea	.sp3_52-.sp3_53(a6),a4
	bsr.s	.sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
.sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,.sp3_42
	bra	.sp3_22
.sp3_43:	moveq	#0,d1
	move.b	(a3),d1
.sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	.sp3_47
.sp3_45:	add.b	d7,d7
	beq.s	.sp3_46
	addx.w	d0,d0
	dbf	d1,.sp3_45
	rts
.sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,.sp3_45
	rts
.sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	.sp3_45
	rts
.sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	.sp3_44
	tst.b	d6
	beq.s	.sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	.sp3_50
	lsr.w	#1,d0
	beq.s	.sp3_49
	roxr.b	#1,d7
	bcc.s	.sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	.sp3_50
.sp3_49:	moveq	#2,d1
	bsr.s	.sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	.sp3_51
.sp3_50:	lea	.sp3_54-.sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
.sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
.sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

.sp3_53:	DS.L	1
.sp3_54:	DS.B	8
.sp3_55:	DS.W	2*64
.sp3_56:	DS.W	2
	DS.B	1
.sp3_57:	DS.B	1
	DS.B	2*64
.sp3_58:	DS.B	512



; spectrum 512 picture depacker

spec_depack
	move.l	load_here(pc),a0
	lea	12(a0),a0
	move.l	a0,a1
	add.l	file_length(pc),a1
	lea	2000(a1),a1
	move.l	a1,d0
	clr.b	d0
	move.l	d0,a1
	move.l	a1,save_here
	move.l	#51104,unpacked_length
	move.l	a1,a5
	move.w	#1,d1
	move.w	#7,d7
	lea	$7D00(a1),a2
	lea	8(a2),a3
.spec00	lea	-$7C60(a2),a1
.spec01	move.b	(a0)+,d6
	ext.w	d6
	bmi.s	.spec03
.spec02	move.b	(a0)+,(a1)
	adda.w	d1,a1
	exg	d7,d1
	dbf	d6,.spec02
	bra.s	.spec05
.spec03	neg.w	d6
	addq.w	#1,d6
	move.b	(a0)+,d0
.spec04	move.b	d0,(a1)
	adda.w	d1,a1
	exg	d7,d1
	dbf	d6,.spec04
.spec05	cmpa.l	a2,a1
	bcs.s	.spec01
	bne.s	.exit
	addq.l	#2,a2
	cmpa.l	a3,a2
	bcs.s	.spec00

	move.l	load_here(pc),a0
	lea	12(a0),a0
	add.l	-8(a0),a0
	move.l	a5,a1
	lea	32000(a1),a1
	move.w	#$254,d7
	clr.w	d0
.spec06	move.w	#$D,d6
	move.w	(a0)+,d1
	lsr.w	#1,d1
	move.w	d0,(a1)+
.spec07	lsr.w	#1,d1
	bcc.s	.spec08
	move.w	(a0)+,(a1)+
	dbf	d6,.spec07
	bra.s	.spec09
.spec08	move.w	d0,(a1)+
	dbf	d6,.spec07
.spec09	move.w	d0,(a1)+
	dbf	d7,.spec06
.exit	rts

; degas unpacker

degas_depack
	move.w	(a0),d0
	and.w	#$00ff,d0
	move.w	d0,res
	lea	34(a0),a1		; start of file
	add.l	file_length(pc),a0
	lea	320(a0),a4
	move.l	a4,d0
	clr.b	d0
	move.l	d0,a4		; depack to here
	move.l	a4,-(a7)
	bsr.s	.dp_degas
	moveq	#21,d0
.1	move.b	(a1)+,(a4)+	; copy colour cycle info
	dbf	d0,.1
	move.l	(a7)+,a4
	move.l	#32066,unpacked_length
	move.l	load_here(pc),a0
	lea	34(a0),a1
	moveq	#16,d0
.copy	move.w	-(a1),-(a4)	; copy in pallete
	dbf	d0,.copy
	clr.b	(a4)		; set up header
	move.l	a4,save_here
	rts

.dp_degas	move.l	#399,d1
	cmp.w	#2,res
	beq.s	.loop
	move.l	#199,d1		; 200 scanlines

.loop	lea	buffer(pc),a0
	moveq	#-$80,d5
	cmp.w	#2,res
	bge.s	.dep00
	move.w	#$A0,d4
	bra.s	.dep01
.dep00	moveq	#$50,d4
.dep01	bra.s	.dep06
.dep02	move.b	(a1)+,d7
	tst.b	d7
	blt.s	.dep04
	addq.b	#1,d7
.dep03	move.b	(a1)+,(a0)+
	subq.w	#1,d4
	subq.b	#1,d7
	bne.s	.dep03
	bra.s	.dep06
.dep04	move.b	d7,d0
	ext.w	d0
	cmp.w	d5,d0
	beq.s	.dep06
	move.b	d7,d0
	ext.w	d0
	neg.w	d0
	move.b	d0,d6
	addq.b	#1,d6
	move.b	(a1)+,d7
.dep05	move.b	d7,(a0)+
	subq.w	#1,d4
	subq.b	#1,d6
	bne.s	.dep05
.dep06	tst.w	d4
	bgt.s	.dep02
	movem.l	a0-a1,-(a7)
	bsr.s	biddle
	movem.l	(a7)+,a0-a1
	dbf	d1,.loop
	rts

biddle	lea	buffer(pc),a6	; rearrange a scanline
	tst.w	res
	bne.s	.rear02
	move.l	a6,b_a_store
	lea	$28(a6),a2
	lea	$50(a6),a3
	lea	$78(a6),a5
	moveq	#0,d7
	bra.s	.rear01
.rear00	move.l	a4,a0
	move.l	b_a_store(pc),a1
	move.w	(a1),(a0)
	addq.l	#2,b_a_store
	addq.l	#2,a4
	move.l	a4,a0
	move.l	a2,a1
	move.w	(a1),(a0)
	addq.l	#2,a2
	addq.l	#2,a4
	move.l	a4,a0
	move.l	a3,a1
	move.w	(a1),(a0)
	addq.l	#2,a3
	addq.l	#2,a4
	move.l	a4,a0
	move.l	a5,a1
	move.w	(a1),(a0)
	addq.l	#2,a5
	addq.l	#2,a4
	addq.w	#1,d7
.rear01	cmp.w	#$14,d7
	blt.s	.rear00
	bra.s	.exit
.rear02	cmp.w	#1,res
	bne.s	.rear05
	move.l	a6,b_a_store
	lea	$50(a6),a2
	clr.w	d7
	bra.s	.rear04
.rear03	move.l	a4,a0
	move.l	b_a_store(pc),a1
	move.w	(a1),(a0)
	addq.l	#2,b_a_store
	addq.l	#2,a4
	move.l	a4,a0
	move.l	a2,a1
	move.w	(a1),(a0)
	addq.l	#2,a2
	addq.l	#2,a4
	addq.w	#1,d7
.rear04	cmp.w	#$28,d7
	blt.s	.rear03
	bra.s	.exit
.rear05	clr.w	d7
	bra.s	.rear07
.rear06	move.l	a4,a0
	move.l	a6,a1
	move.w	(a1),(a0)
	addq.l	#2,a6
	addq.l	#2,a4
	addq.w	#1,d7
.rear07	cmp.w	#$28,d7
	blt.s	.rear06
.exit	rts

; Unpacker for files packed with a packer whose name I dont know
; but was used to pack concerto on stf issue 37 

un1dp	move.l	load_here(pc),a2
	lea	600(a2),a0
	move.l	(a0),unpacked_length
	lea	1624(a2),a1
	moveq	#4,d4
	moveq	#7,d5
	moveq	#1,d6
	movea.l	a1,a2
	adda.l	(a0)+,a1
	adda.l	(a0)+,a0
	lea	.un111(PC),a5
	lea	.un11F(PC),a6
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
	bcs.s	.un10D
.un109	jsr	(a5)
	move.w	d0,d2
.un10A	jsr	(a6)
	move.b	d0,-(a1)
	sub.w	d6,d2
	bne.s	.un10A
	cmpa.l	a2,a1
	ble.s	.un110
.un10B	add.l	d7,d7
	bne.s	.un10C
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un10C	bcc.s	.un109
.un10D	jsr	(a5)
	move.l	d0,d2
	jsr	(a5)
	move.w	d0,d3
	lsr.w	#3,d3
	and.w	d5,d0
	add.w	d0,d0
	add.w	d0,d0
	neg.w	d0
	jmp	.un10F(PC,d0.W)
.un10E	move.b	-1(a1,d2.L),-(a1)
	move.b	-1(a1,d2.L),-(a1)
	move.b	-1(a1,d2.L),-(a1)
	move.b	-1(a1,d2.L),-(a1)
	move.b	-1(a1,d2.L),-(a1)
	move.b	-1(a1,d2.L),-(a1)
	move.b	-1(a1,d2.L),-(a1)
	move.b	-1(a1,d2.L),-(a1)
.un10F	dbf	d3,.un10E
	cmpa.l	a2,a1
	bgt.s	.un10B
.un110	rts
.un111	add.l	d7,d7
	bne.s	.un112
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un112	bcs.s	.un11B
	add.l	d7,d7
	bne.s	.un113
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un113	bcc.s	.un116
	moveq	#0,d0
	moveq	#$B,d1
.un114	add.l	d7,d7
	bne.s	.un115
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un115	roxr.w	d6,d0
	dbf	d1,.un114
	lsr.w	d4,d0
	rts
.un116	moveq	#0,d0
	add.l	d7,d7
	bne.s	.un117
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un117	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un118
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un118	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un119
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un119	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un11A
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un11A	roxr.b	d6,d0
	lsr.b	d4,d0
	rts
.un11B	add.l	d7,d7
	bne.s	.un11C
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un11C	bcc.s	.un11F
	moveq	#0,d0
	moveq	#$F,d1
.un11D	add.l	d7,d7
	bne.s	.un11E
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un11E	roxr.w	d6,d0
	dbf	d1,.un11D
	rts
.un11F	moveq	#0,d0
	add.l	d7,d7
	bne.s	.un120
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un120	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un121
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un121	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un122
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un122	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un123
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un123	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un124
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un124	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un125
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un125	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un126
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un126	roxr.b	d6,d0
	add.l	d7,d7
	bne.s	.un127
	move.l	-(a0),d7
	ori.b	#$10,CCR
	addx.l	d7,d7
.un127	roxr.b	d6,d0
	rts

; Depack STOS packed programs

stos_dp	lea	402(a0),a2
	move.l	42(a0),d3
.stdp02	movea.l	a2,a0
	movea.l	a2,a1
	lea	-$192(a1),a1
	movea.l	a1,a2
	movea.l	a2,a3
	adda.l	d3,a3
.stdp03	move.b	(a0)+,(a1)+
	subq.l	#1,d3
	bpl.s	.stdp03

	movea.l	a3,a0
	movea.l	a2,a1
	movea.l	-(a0),a2
	move.l	a2,unpacked_length
	adda.l	a1,a2
	move.l	-(a0),d5
	move.l	-(a0),d0
	eor.l	d0,d5
.stdp09	lsr.l	#1,d0
	bne.s	.stdp0A
	bsr.s	.stdp16
.stdp0A	bcs.s	.stdp11
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.s	.stdp0B
	bsr.s	.stdp16
.stdp0B	bcs.s	.stdp13
	moveq	#3,d1
	clr.w	d4
.stdp0C	bsr.s	.stdp17
	move.w	d2,d3
	add.w	d4,d3
.stdp0D	moveq	#7,d1
.stdp0E	lsr.l	#1,d0
	bne.s	.stdp0F
	bsr.s	.stdp16
.stdp0F	roxl.l	#1,d2
	dbf	d1,.stdp0E
	move.b	d2,-(a2)
	dbf	d3,.stdp0D
	bra.s	.stdp15
.stdp10	moveq	#8,d1
	moveq	#8,d4
	bra.s	.stdp0C
.stdp11	moveq	#2,d1
	bsr.s	.stdp17
	cmp.b	#2,d2
	blt.s	.stdp12
	cmp.b	#3,d2
	beq.s	.stdp10
	moveq	#8,d1
	bsr.s	.stdp17
	move.w	d2,d3
	move.w	#$C,d1
	bra.s	.stdp13
.stdp12	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
.stdp13	bsr.s	.stdp17
.stdp14	subq.w	#1,a2
	move.b	(a2,d2.W),(a2)
	dbf	d3,.stdp14
.stdp15	cmpa.l	a2,a1
	blt.s	.stdp09
	move.l	a0,save_here
	rts
.stdp16	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
	rts
.stdp17	subq.w	#1,d1
	clr.w	d2
.stdp18	lsr.l	#1,d0
	bne.s	.stdp19
	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
.stdp19	roxl.l	#1,d2
	dbf	d1,.stdp18
	rts

; Depacker for Ivory dragon 

depack_ivd
	movea.l	a1,a2
	move.l	-(a0),d0
	move.l	d0,unpacked_length
	adda.l	d0,a2
	lea	.ivd0F(PC),a4
	move.l	-(a0),d0
	move.l	-(a0),d4
.ivd01	bsr	.ivd0D
	bcs.s	.ivd02
	moveq	#7,d1
	bsr	.ivd0A
	move.b	d2,-(a2)
	cmpa.l	a2,a1
	blt.s	.ivd01
	rts
.ivd02	bsr	.ivd0D
	bcs.s	.ivd06
	bsr	.ivd0D
	bcs.s	.ivd04
	moveq	#3,d1
	bsr	.ivd0A
	movea.l	a2,a3
	adda.w	d2,a3
	adda.w	#1,a3
	move.b	-(a3),-(a2)
	cmpa.l	a2,a1
	blt.s	.ivd01
	rts
.ivd03	moveq	#8,d1
	bsr	.ivd0A
	movea.l	a2,a3
	adda.w	d2,a3
	move.b	-(a3),-(a2)
	move.b	-(a3),-(a2)
	cmpa.l	a2,a1
	blt.s	.ivd01
	rts
.ivd04	moveq	#2,d1
	bsr	.ivd0A
	beq.s	.ivd03
	move.w	d2,d3
	addi.w	#1,d3
	moveq	#1,d1
	bsr	.ivd0A
	move.w	d2,d7
	lsl.w	#1,d7
	move.w	0(a4,d7.W),d1
	bsr	.ivd0A
	movea.l	a2,a3
	adda.w	d2,a3
	adda.w	8(a4,d7.W),a3
.ivd05	move.b	-(a3),-(a2)
	dbf	d3,.ivd05
	cmpa.l	a2,a1
	blt.s	.ivd01
	rts
.ivd06	bsr	.ivd0D
	bcs.s	.ivd08
	moveq	#1,d1
	bsr.s	.ivd0A
	move.w	d2,d1
	lsl.w	#1,d1
	move.w	d1,d7
	addi.w	#1,d1
	bsr.s	.ivd0A
	add.w	$10(a4,d7.W),d2
	move.w	d2,d3
	addi.w	#9,d3
	moveq	#1,d1
	bsr.s	.ivd0A
	move.w	d2,d7
	lsl.w	#1,d7
	move.w	0(a4,d7.W),d1
	bsr.s	.ivd0A
	movea.l	a2,a3
	adda.w	d2,a3
	adda.w	8(a4,d7.W),a3
.ivd07	move.b	-(a3),-(a2)
	dbf	d3,.ivd07
	cmpa.l	a2,a1
	blt	.ivd01
	rts
.ivd08	moveq	#1,d1
	bsr.s	.ivd0A
	move.w	d2,d1
	lsl.w	#1,d1
	move.w	d1,d7
	addi.w	#1,d1
	bsr.s	.ivd0A
	add.w	$10(a4,d7.W),d2
	move.w	d2,d3
	addi.w	#7,d3
.ivd09	moveq	#7,d1
	bsr.s	.ivd0A
	move.b	d2,-(a2)
	dbf	d3,.ivd09
	cmpa.l	a2,a1
	blt	.ivd01
	rts
.ivd0A	clr.w	d2
.ivd0B	lsr.l	#1,d0
	bne.s	.ivd0C
	move.l	d4,d0
	move.l	-(a0),d4
	move	#$10,CCR
	roxr.l	#1,d0
.ivd0C	roxl.l	#1,d2
	dbf	d1,.ivd0B
	rts
.ivd0D	lsr.l	#1,d0
	bne.s	.ivd0E
	move.l	d4,d0
	move.l	-(a0),d4
	move	#$10,CCR
	roxr.l	#1,d0
.ivd0E	rts
.ivd0F	dc.b	$00,$07,$00,$09,$00,$0B,$00,$0C
	dc.b	$00,$00,$01,$00,$05,$00,$15,$00
	dc.b	$00,$00,$00,$03,$00,$12,$00,'Q'

.ivd1F	dc.b	'&',$00
.ivd20	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00
	dcb.w	14,0
	dc.b	$00
.ivd21	dc.b	'&',$00
.ivd22	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00
	dcb.w	17,0
;
; depack vic2/california games 2
;
depack_v2	lea	(a0),a6
	lea	(a6),a3
	lea	(a3),a1
	cmpi.l	#"Vic2",(a0)+
	bne	.xff
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	lea	buf00(pc),a2
	moveq	#(1024/8)-1,d7
.x00	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbf	d7,.x00
	subi.l	#1024,d4
	adda.l	d4,a0
	bclr	#0,d3
	adda.l	d3,a1
	lea	16(a1),a1
	lsr.l	#2,d4
	subq.l	#1,d4
.x01	move.l	-(a0),d0
	swap	d0
	move.l	d0,-(a1)
	dbf	d4,.x01
	lea	(a1),a4
	lea	buf00(pc),a6
	lea	512(a6),a5
	move	510(a6),d4
	lea	512(a5),a0
	lea	256(a0),a1
	moveq	#0,d0
	moveq	#9,d1
.x02	move	d0,d6
	moveq	#0,d7
	move	d4,d5
.x03	addq	#1,d7
	cmp	d1,d7
	beq.s	.x06
	lsr.b	#1,d6
	bcc.s	.x04
	move	0(a5,d5.w),d5
	bpl.s	.x03
	bra.s	.x05
.x04	move	0(a6,d5.w),d5
	bpl.s	.x03
.x05	move.b	d5,(a1)+
	move.b	d7,(a0)+
	bra.s	.x07
.x06	lsr	#1,d5
	move.b	d5,(a1)+
	st	(a0)+
.x07	addq.b	#1,d0
	bne.s	.x02
	lea	512(a5),a2
	lea	256(a2),a1
	move.l	(a4)+,d6
	swap	d6
	moveq	#16,d7
	moveq	#0,d0
	moveq	#0,d4
	move.b	d6,d0
	move.b	0(a2,d0.w),d4
	bmi.s	.x09
	move.b	0(a1,d0.w),d0
	cmp	d4,d7
	bcs.s	.x08
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x10
.x08	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x10
.x09	moveq	#8,d4
	cmp	d4,d7
	bcs.s	.x0a	
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x0b
.x0a	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
.x0b	moveq	#0,d5
	move.b	0(a1,d0.w),d5
	add	d5,d5
.x0c	dbf	d7,.x0d
	moveq	#15,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
.x0d	lsr.l	#1,d6
	bcc.s	.x0e
	move	0(a5,d5.w),d5
	bpl.s	.x0c
	bra.s	.x0f
.x0e	move	0(a6,d5.w),d5
	bpl.s	.x0c
.x0f	move.b	d5,d0
.x10	move	d0,d2
.x11	move.b	d6,d0
	move.b	0(a2,d0.w),d4
	bmi.s	.x13
	move.b	0(a1,d0.w),d0
	cmp	d4,d7
	bcs.s	.x12
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x1a
.x12	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x1a
.x13	moveq	#8,d4
	cmp	d4,d7
	bcs.s	.x14
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x15
.x14	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
.x15	moveq	#0,d5
	move.b	0(a1,d0.w),d5
	add	d5,d5
.x16	dbf	d7,.x17
	moveq	#15,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
.x17	lsr.l	#1,d6
	bcc.s	.x18
	move	0(a5,d5.w),d5
	bpl.s	.x16
	bra.s	.x19
.x18	move	0(a6,d5.w),d5
	bpl.s	.x16
.x19	move.b	d5,d0
.x1a	cmp.b	d0,d2
	beq.s	.x1c
	move.b	d0,(a3)+
	addq.l	#1,buf01
.x1b	subq.l	#1,d3
	bne.s	.x11
.xff	rts
.x1c	move.b	d6,d0
	move.b	0(a2,d0.w),d4
	bmi.s	.x1e
	move.b	0(a1,d0.w),d0
	cmp	d4,d7
	bcs.s	.x1d
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x25
.x1d	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x25
.x1e	moveq	#8,d4
	cmp	d4,d7
	bcs.s	.x1f
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x20
.x1f	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
.x20	moveq	#0,d5
	move.b	0(a1,d0.w),d5
	add	d5,d5
.x21	dbf	d7,.x22
	moveq	#15,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
.x22	lsr.l	#1,d6
	bcc.s	.x23
	move	0(a5,d5.w),d5
	bpl.s	.x21
	bra.s	.x24
.x23	move	0(a6,d5.w),d5
	bpl.s	.x21
.x24	move.b	d5,d0
.x25	tst.b	d0
	beq	.x2f
	move	d0,d1
	addq	#2,d1
	move.b	d6,d0
	move.b	0(a2,d0.w),d4
	bmi.s	.x27
	move.b	0(a1,d0.w),d0
	cmp	d4,d7
	bcs.s	.x26
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x2e
.x26	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x2e
.x27	moveq	#8,d4
	cmp	d4,d7
	bcs.s	.x28
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x29
.x28	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
.x29	moveq	#0,d5
	move.b	0(a1,d0.w),d5
	add	d5,d5
.x2a	dbf	d7,.x2b
	moveq	#15,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
.x2b	lsr.l	#1,d6
	bcc.s	.x2c
	move	0(a5,d5.w),d5
	bpl.s	.x2a
	bra.s	.x2d
.x2c	move	0(a6,d5.w),d5
	bpl.s	.x2a
.x2d	move.b	d5,d0
.x2e	move.b	d0,(a3)+
	addq.l	#1,buf01
	subq.l	#1,d3
	dbeq	d1,.x2e
	bne	.x11
	bra	.xff
.x2f	move.b	d2,(a3)+
	addq.l	#1,buf01
	bra	.x1b


**********************************************************************
