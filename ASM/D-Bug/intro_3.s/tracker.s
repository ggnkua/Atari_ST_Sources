; Slightly changed tcb tracker replay routine
; (c) 1991 Andy the Arfling productions
; Original takes 33.1% CPU time and d6,d7,a2,a3,a4,a5,a6,usp
; Takes 35.4% CPU time and d7,a5,a6
; Takes 37.0% CPU time and a5,a6,usp
; Easy ridered 20/1/91
; This version 1/3/91

save_d7	equ	1		Set to 1 to save d7 to usp

	bra init_tcb
	bra stop_tcb
	bra vbl_tcb

init_tcb moveq	#-1,d0		Use in built sample table
	 lea	module,a0
	 bsr	init_music
	 bsr	trak_07
	 bsr	trak_08
	 rts

stop_tcb bsr	trak_0a
	 rts

vbl_tcb  st	vbl_done
         rts

old_usp	dc.l	0
old_sp	dc.l	0
vbl_done	dc.w	0

trak_07	move.b  -$5f9.w,trak_0b
	move.b  -$5f7.w,trak_0c
	move.b  -$5ed.w,trak_0d
	move.b  -$5eb.w,trak_0e
	move.b  -$5e7.w,trak_0f
	move.b  -$5e1.w,trak_10
	move.l  $134.w,trak_11
	move.l  $70.w,trak_12
	rts

trak_08	clr.b   -$5f7.w
	clr.b   -$5eb.w
	lea	module,a0
	move.w  144(a0),d0
	lea     trak_09,a0
	move.b  0(a0,d0.w),-$5e1.w
	move.b  #2,-$5e7.w
	move.b  #$20,-$5f9.w
	move.b  #$20,-$5ed.w
	bclr    #3,-$5e9.w
	move.l  #timer_a,$134.w
	rts

trak_09	dc.b    $18,$1d

trak_0a	move.b  trak_0b,-$5f9.w
	move.b  trak_0c,-$5f7.w
	move.b  trak_0d,-$5ed.w
	move.b  trak_0e,-$5eb.w
	move.b  trak_0f,-$5e7.w
	move.b  trak_10,-$5e1.w
	move.l  trak_11,$134.w
	move.l  trak_12,$70.w
	rts

trak_0b	dc.b   $00
trak_0c	dc.b   $00
trak_0d	dc.b   $00
trak_0e	dc.b   $00
trak_0f	dc.b   $00
trak_10	dc.b   $00
trak_11	dcb.w    2,0
trak_12	dcb.w    2,0

init_music
	tst.l   d0
	beq     trak_18
	lea     trak_af,a2
	lea     trak_b4,a1
	move.w  #$7ff,d0
trak_17	move.b  (a2)+,(a1)+
	dbf     d0,trak_17
trak_18	moveq   #0,d0
	move.l  8(a0),d0
	mulu    #$200,d0
	addi.l  #$132,d0
	add.l   a0,d0
	move.l  d0,trak_2f
	addq.l  #4,d0
	move.l  d0,trak_31
	addi.l  #$40,d0
	move.l  d0,trak_30
	move.b  14(a0),trak_35
	move.l  a0,trak_37
	bsr     trak_19
	bsr     trak_1d
	bsr     trak_2a
	bsr     trak_24
	bsr     trak_28
	move.b  #$3d,trak_33
	clr.b   trak_32
	move.w  #1,trak_9c
	move.w  #1,trak_9d
	move.w  #1,trak_9e
	move.w  #1,trak_9f
	movea.l #trak_af,a2
	lea     trak_ad(pc),a3
	move.l  a3,trak_a9
	lea     trak_ad(pc),a4
	move.l  a4,trak_aa
	lea     trak_ad(pc),a5
	move.l  a5,trak_ab
	lea     trak_ad(pc),a6
	move.l  a6,trak_ac
	bra     trak_3b

trak_19
	moveq	#$f,d2
.1	move.l	d2,d3
	lsl.l	#3,d3
	move.l	trak_30,a1
	move.l	0(a1,d3.w),a0
	add.l	trak_2f,a0
	move.l	a0,d4
	add.l	4(a1,d3.w),d4
	move.l	trak_31,a1
	move.l	d2,d3
	lsl.l	#2,d3
	moveq	#0,d0
	move.b	0(a1,d3.w),d0
	move.l	d4,a1
	bsr.s	trak_1b
	dbf	d2,.1
	rts

trak_1b
	moveq	#0,d3
	move.b	d0,d3
	not.b	d3
	and.b	#$7f,d3
.1	moveq	#0,d1
	move.b	(a0),d1
	mulu	d0,d1
	asr.w	#7,d1
	add.b	d3,d1
	move.b	d1,(a0)+
	cmp.l	a1,a0
	bne.s	.1
	rts

trak_1d
	moveq	#$f,d7
.1	bsr.s	trak_1f
	dbf	d7,.1
	rts

trak_1f
	moveq	#0,d1
	move.b	d7,d1
	lsl.w	#3,d1
	move.l	trak_30,a0
	move.l	0(a0,d1.w),a1
	add.l	4(a0,d1.w),a1
	sub.l	#$2bc,a1
	cmp.l	#-1,a1
	ble.s	.done
	add.l	trak_2f,a1
	move.l	a1,a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	d7,d0
	lsl.l	#2,d0
	move.l	trak_31,a1
	move.w	2(a1,d0.w),d1
	beq.s	.2
	move.l	a0,a1
	sub.l	d1,a1
	move.w	#$2bb,d0
.1	move.b	(a1)+,(a0)+
	dbf	d0,.1
	bra.s	.done
.2	move.w	#$2bb,d0
.3	move.b	#$7f,(a0)+
	dbf	d0,.3
.done	rts

trak_24
	move.w	#$24,d0
	lea	trak_27(pc),a0
	lea	trak_af(pc),a1
	lea	trak_ae(pc),a2
.1	move.l	(a0)+,d1
	move.l	a1,(a2)+
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	#$18f,d7
.2	add.l	d1,d2
	move.l	d2,d3
	lsr.l	#8,d3
	lsr.l	#8,d3
	sub.w	d3,d4
	neg.w	d4
	move.w	d4,(a1)+
	move.w	d3,d4
	dbf	d7,.2
	dbf	d0,.1
	rts

	dc.l	$2000,$21e7,$23eb,$260d,$2851,$2ab7,$2d41,$2ff2
	dc.l	$32cb,$35d1,$3904,$3c68,$4000,$43ce,$47d6,$4c1b
	dc.l	$50a2,$556e,$5a82,$5fe4,$6597,$6ba2,$7208,$78d0

trak_27	dcb.w	1,0
	dc.b	$80,$00,$00,$00,$87,$9c,$00,$00
	dc.b	$8f,$ac,$00,$00,$98,$37,$00,$00
	dc.b	$a1,$45,$00,$00,$aa,$dc,$00,$00
	dc.b	$b5,$04,$00,$00,$bf,$c8,$00,$00
	dc.b	$cb,$2f,$00,$00,$d7,$44,$00,$00
	dc.b	$e4,$11,$00,$00,$f1,$a1,$00,$01
	dcb.w	1,0
	dc.b	$00,$01,$0f,$38,$00,$01,$1f,$59
	dc.b	$00,$01,$30,$6f,$00,$01,$42,$8a
	dc.b	$00,$01,$55,$b8,$00,$01,$6a,$09
	dc.b	$00,$01,$7f,$91,$00,$01,$96,$5f
	dc.b	$00,$01,$ae,$89,$00,$01,$c8,$23
	dc.b	$00,$01,$e3,$43,$00,$02,$00,$00
	dc.b	$00,$02,$1e,$71,$00,$02,$3e,$b3
	dc.b	$00,$02,$60,$df,$00,$02,$85,$14
	dc.b	$00,$02,$ab,$70,$00,$02,$d4,$13
	dc.b	$00,$02,$ff,$22,$00,$03,$2c,$bf
	dc.b	$00,$03,$5d,$13,$00,$03,$90,$47
	dc.b	$00,$03,$c6,$86,$00,$04,$00,$00
	dc.b	$00,$04,$3c,$e3,$00,$04,$7d,$66
	dc.b	$00,$04,$c1,$bf,$00,$05,$0a,$28
	dc.b	$00,$05,$56,$e0,$00,$05,$a8,$27
	dc.b	$00,$05,$fe,$44,$00,$06,$59,$7f
	dc.b	$00,$06,$ba,$27,$00,$07,$20,$8f
	dc.b	$00,$07,$8d,$0d,$00,$08,$00,$00

trak_28
	moveq	#$a,d0
.1	move.b	d0,$ffff8800.w
	clr.b	$ffff8802.w
	dbf	d0,.1
	move.b	#7,$ffff8800.w
	move.b	#-1,$ffff8802.w
	rts

trak_2a
	move.w	#$ff,d7
	lea	trak_b5,a0
.1	move.b	(a0),d0
	move.b	1(a0),d1
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	move.b	d1,(a0)+
	move.b	d1,(a0)+
	addq.l	#4,a0
	dbf	d7,.1

	lea	trak_b4,a0
	lea	3072(a0),a1
	move.w	#$ff,d0
.2	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.2

	lea	trak_b4,a0
	move.w	#$17f,d0
	move.l	(a0),d1
	move.l	4(a0),d2
.3	move.l	d1,(a0)+
	move.l	d2,(a0)+
	dbf	d0,.3

	move.w	#$17f,d0
	move.l	-8(a1),d1
	move.l	-4(a1),d2
.4	move.l	d1,(a1)+
	move.l	d2,(a1)+
	dbf	d0,.4
	rts

trak_2f	dc.l	0
trak_30	dc.l	0
trak_31	dc.l	0
trak_32	dc.w	0
trak_33	dc.w	0
trak_34	dc.w	0
trak_35	dc.w	0
trak_36	dc.l	0,0
trak_37	dc.l	0

music
	move	#$2700,sr
	move.l	a6,buf_ptr
	movem.l	a_reggies,a2-a6
	bsr	trak_88		Repeat samples if necessary
	addq.b	#1,trak_32
	move.l	trak_37(pc),a0
	move.b	12(a0),d0
	subq.b	#1,d0
	and.b	#$f,d0
	eor.b	#$f,d0
	cmp.b	trak_32(pc),d0
	bne	calc_1v
	clr.b	trak_32
	addq.b	#1,trak_33
	move.b	trak_33(pc),d0
	and.b	#$3f,d0
	move.b	d0,trak_33
	addq.b	#3,d0
	and.b	#$3f,d0
	bne.s	trak_3b
trak_3a
	bsr	trak_3d
	move.b	trak_34(pc),d0
	move.l	trak_37(pc),a0
	cmp.b	142(a0),d0
	bcs.s	trak_3b
	move.w	#1,trak_9c
	move.w	#1,trak_9d
	move.w	#1,trak_9e
	move.w	#1,trak_9f
	lea	trak_ad(pc),a3
	move.l	a3,trak_a9
	lea	trak_ad(pc),a4
	move.l	a4,trak_aa
	lea	trak_ad(pc),a5
	move.l	a5,trak_ab
	lea	trak_ad(pc),a6
	move.l	a6,trak_ac
	move.b	#-1,trak_34
	bsr	trak_3d
trak_3b
	bsr	trak_3c
calc_1v
	move.l	a2,d2
	move.l	a5,a2
	move.l	a6,a1
	lea	buffer,a6
	move.l	a6,a0
	move.w	#169,d0
	move.l	buf_ptr,a5
	move.w	(a5)+,(a0)+	Always copy at least 1
.copy	cmp.l	#buffer+342,a5	Maybe another?
	bge.s	.copied
	move.w	(a5)+,(a0)+
	subq.w	#1,d0
	bra.s	.copy
.copied	lea	$ffff8800.w,a5
	move	#$2300,sr
	moveq	#0,d6
loop_1v	
	moveq	#0,d1
	move.b	(a1),d1
	move.b	(a2),d6
	add.w	d6,d1
	move.b	(a4),d6
	add.w	d6,d1
	move.b	(a3),d6
	add.w	d6,d1
	asl.w	#3,d1

	move.w	d1,(a0)+
	exg.l	a0,d2
trak_b1	add.w	0(a0),a4
trak_b2	add.w	0(a0),a2
trak_b3	add.w	0(a0),a1
	add.w	(a0)+,a3
	exg.l	a0,d2
	dbf	d0,loop_1v

	lea	a_reggies(pc),a0
	move.l	d2,(a0)+
	move.l	a3,(a0)+
	move.l	a4,(a0)+
	move.l	a2,(a0)+
	move.l	a1,(a0)+
	rts

a_reggies	ds.l	5
buf_ptr	dc.l	buffer+342
buffer	ds.w	171

trak_3c
	moveq	#0,d0
	moveq	#0,d1
	move.b	trak_33(pc),d3
	addq.b	#3,d3
	and.b	#$3f,d3
	move.l	trak_37,a0
	lea	306(a0),a0
	move.b	trak_35(pc),d0
	lsl.w	#8,d0
	add.l	d0,d0
	move.b	d3,d1
	lsl.w	#3,d1
	add.l	d1,d0
	add.l	d0,a0
	lea	trak_36(pc),a1
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	bsr	trak_3e
	rts

trak_3d
	move.b	trak_34(pc),d1
	addq.b	#1,d1
	and.b	#$7f,d1
	move.b	d1,trak_34
	moveq	#0,d0
	move.b	trak_34(pc),d0
	move.l	trak_37,a0
	lea	14(a0),a0
	add.l	d0,a0
	move.b	(a0),d1
	move.b	d1,trak_35
	rts

trak_3e
	lea	trak_36(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	tst.b	d0
	beq	trak_40
	lea	trak_a0(pc),a1
	move.b	0(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	trak_ae(pc),a1
	move.l	0(a1,d0.w),trak_a1
	move.w	d1,d2
	and.w	#-$10,d2
	lsr.w	#1,d2
	move.l	trak_30(pc),a1
	move.l	0(a1,d2.w),a3
	add.l	trak_2f(pc),a3
	move.l	4(a1,d2.w),trak_a9
	move.l	a3,d0
	add.l	d0,trak_a9
	sub.l	#$2bc,trak_a9
	moveq	#0,d0
	move.l	trak_31(pc),a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	beq.s	trak_3f
	move.l	trak_a9(pc),trak_94
	move.l	trak_a9(pc),trak_98
	sub.l	d0,trak_94
	clr.w	trak_9c
	bra.s	trak_40
trak_3f	move.w	#1,trak_9c
	move.l	#trak_ad,trak_94
	move.l	#trak_ad,trak_98
trak_40	and.w	#$f,d1
	move.w	d1,trak_a5
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	tst.b	d0
	beq	trak_42
	lea	trak_a0(pc),a1
	move.b	0(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	trak_ae(pc),a1
	move.l	0(a1,d0.w),trak_a2
	move.w	d1,d2
	and.w	#-$10,d2
	lsr.w	#1,d2
	move.l	trak_30(pc),a1
	move.l	0(a1,d2.w),a4
	add.l	trak_2f(pc),a4
	move.l	4(a1,d2.w),trak_aa
	move.l	a4,d0
	add.l	d0,trak_aa
	sub.l	#$2bc,trak_aa
	moveq	#0,d0
	move.l	trak_31(pc),a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	beq.s	trak_41
	move.l	trak_aa(pc),trak_95
	move.l	trak_aa(pc),trak_99
	sub.l	d0,trak_95
	clr.w	trak_9d
	bra.s	trak_42
trak_41	move.w	#1,trak_9d
	move.l	#trak_ad,trak_95
	move.l	#trak_ad,trak_99
trak_42	and.w	#$f,d1
	move.w	d1,trak_a6
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	tst.b	d0
	beq	trak_44
	lea	trak_a0(pc),a1
	move.b	0(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	trak_ae(pc),a1
	move.l	0(a1,d0.w),trak_a3
	move.w	d1,d2
	and.w	#-$10,d2
	lsr.w	#1,d2
	move.l	trak_30(pc),a1
	move.l	0(a1,d2.w),a5
	add.l	trak_2f(pc),a5
	move.l	4(a1,d2.w),trak_ab
	move.l	a5,d0
	add.l	d0,trak_ab
	sub.l	#$2bc,trak_ab
	moveq	#0,d0
	move.l	trak_31(pc),a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	beq.s	trak_43
	move.l	trak_ab(pc),trak_96
	move.l	trak_ab(pc),trak_9a
	sub.l	d0,trak_96
	clr.w	trak_9e
	bra.s	trak_44
trak_43	move.w	#1,trak_9e
	move.l	#trak_ad,trak_96
	move.l	#trak_ad,trak_9a
trak_44	and.w	#$f,d1
	move.w	d1,trak_a7
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	tst.b	d0
	beq	trak_46
	lea	trak_a0(pc),a1
	move.b	0(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	trak_ae(pc),a1
	move.l	0(a1,d0.w),trak_a4
	move.w	d1,d2
	and.w	#-$10,d2
	lsr.w	#1,d2
	move.l	trak_30(pc),a1
	move.l	0(a1,d2.w),a6
	add.l	trak_2f(pc),a6
	move.l	4(a1,d2.w),trak_ac
	move.l	a6,d0
	add.l	d0,trak_ac
	sub.l	#$2bc,trak_ac
	moveq	#0,d0
	move.l	trak_31(pc),a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	beq.s	trak_45
	move.l	trak_ac(pc),trak_97
	move.l	trak_ac(pc),trak_9b
	sub.l	d0,trak_97
	clr.w	trak_9f
	bra.s	trak_46
trak_45	move.w	#1,trak_9f
	move.l	#trak_ad,trak_97
	move.l	#trak_ad,trak_9b
trak_46	and.w	#$f,d1
	move.w	d1,trak_a8
	move.l	trak_a2(pc),d0
	sub.l	trak_a1(pc),d0
	move.l	trak_a3(pc),d1
	sub.l	trak_a1(pc),d1
	move.l	trak_a4(pc),d2
	sub.l	trak_a1(pc),d2
	move.l	trak_91(pc),a0
	move.w	d0,2(a0)
	move.l	trak_92(pc),a0
	move.w	d1,2(a0)
	move.l	trak_93(pc),a0
	move.w	d2,2(a0)
	move.l	trak_a1(pc),a2
	rts

trak_47	move.w  276(a1),d2
	jmp     (a0)
trak_48	move.w  278(a1),d2
	jmp     (a0)
trak_49	move.w  280(a1),d2
	jmp     (a0)
trak_4a	move.w  282(a1),d2
	jmp     (a0)
trak_4b	move.w  284(a1),d2
	jmp     (a0)
trak_4c	move.w  286(a1),d2
	jmp     (a0)
trak_4d	move.w  288(a1),d2
	jmp     (a0)
trak_4e	move.w  290(a1),d2
	jmp     (a0)
trak_4f	move.w  292(a1),d2
	jmp     (a0)
trak_50	move.w  294(a1),d2
	jmp     (a0)
trak_51	ext.l   d2
	move.l  trak_a1(pc),d1
	sub.l   d2,d1
	cmp.l   #trak_af,d1
	bcs.s   trak_53
	cmp.l   #trak_68,d1
	bge     trak_54
trak_52	move.l  d1,trak_a1
	jsr     trak_61(pc)
	bra     trak_84
trak_53	move.l  #trak_af,d1
	bra.s   trak_52
trak_54	move.l  #trak_68,d1
	bra.s   trak_52
trak_55	ext.l   d2
	move.l  trak_a2(pc),d1
	sub.l   d2,d1
	cmp.l   #trak_af,d1
	bcs.s   trak_57
	cmp.l   #trak_68,d1
	bge.s   trak_58
trak_56	move.l  d1,trak_a2
	jsr     trak_61(pc)
	bra     trak_85
trak_57	move.l  #trak_af,d1
	bra.s   trak_56
trak_58	move.l  #trak_68,d1
	bra.s   trak_56
trak_59	ext.l   d2
	move.l  trak_a3(pc),d1
	sub.l   d2,d1
	cmp.l   #trak_af,d1
	bcs.s   trak_5b
	cmp.l   #trak_68,d1
	bge.s   trak_5c
trak_5a	move.l  d1,trak_a3
	jsr     trak_61(pc)
	bra     trak_86
trak_5b	move.l  #trak_af,d1
	bra.s   trak_5a
trak_5c	move.l  #trak_68,d1
	bra.s   trak_5a
trak_5d	ext.l   d2
	move.l  trak_a4(pc),d1
	sub.l   d2,d1
	cmp.l   #trak_af,d1
	bcs.s   trak_5f
	cmp.l   #trak_68,d1
	bge.s   trak_60
trak_5e	move.l  d1,trak_a4
	jsr     trak_61(pc)
	bra     trak_87
trak_5f	move.l  #trak_af,d1
	bra.s   trak_5e
trak_60	move.l  #trak_68,d1
	bra.s   trak_5e
trak_61	move.l  trak_a2(pc),d0
	sub.l   trak_a1(pc),d0
	move.l  trak_a3(pc),d1
	sub.l   trak_a1(pc),d1
	move.l  trak_a4(pc),d2
	sub.l   trak_a1(pc),d2
	movea.l trak_91(pc),a0
	move.w  d0,2(a0)
	movea.l trak_92(pc),a0
	move.w  d1,2(a0)
	movea.l trak_93(pc),a0
	move.w  d2,2(a0)
	rts

trak_62	move.l  a3,trak_6b
	move.l  trak_a9(pc),trak_6c
	move.l  trak_94(pc),trak_6d
	move.l  trak_98(pc),trak_6e
	move.w  trak_9c(pc),trak_6f
	movea.l trak_37(pc),a0
	cmpi.w  #2,296(a0)
	beq     trak_84
	lea     trak_ad(pc),a3
	move.l  #trak_ad,trak_a9
	move.w  #1,trak_9c
	clr.w   trak_a5
	bra     trak_84
trak_63	tst.l   trak_6b
	beq     trak_84
	movea.l trak_6b(pc),a3
	move.l  trak_6c(pc),trak_a9
	move.l  trak_6d(pc),trak_94
	move.l  trak_6e(pc),trak_98
	move.w  trak_6f(pc),trak_9c
	clr.w   trak_a5
	jsr     trak_61(pc)
	bra     trak_84
trak_64	move.l  a4,trak_70
	move.l  trak_aa(pc),trak_71
	move.l  trak_95(pc),trak_72
	move.l  trak_99(pc),trak_73
	move.w  trak_9d(pc),trak_74
	movea.l trak_37(pc),a0
	cmpi.w  #2,296(a0)
	beq     trak_85
	lea     trak_ad(pc),a4
	move.l  #trak_ad,trak_aa
	move.w  #1,trak_9d
	clr.w   trak_a6
	bra     trak_85
trak_65	tst.l   trak_70
	beq     trak_85
	movea.l trak_70(pc),a4
	move.l  trak_71(pc),trak_aa
	move.l  trak_72(pc),trak_95
	move.l  trak_73(pc),trak_99
	move.w  trak_74(pc),trak_9d
	clr.w   trak_a6
	jsr     trak_61(pc)
	bra     trak_85
trak_66	move.l  a5,trak_75
	move.l  trak_ab(pc),trak_76
	move.l  trak_96(pc),trak_77
	move.l  trak_9a(pc),trak_78
	move.w  trak_9e(pc),trak_79
	movea.l trak_37(pc),a0
	cmpi.w  #2,296(a0)
	beq     trak_86
	lea     trak_ad(pc),a5
	move.l  #trak_ad,trak_ab
	move.w  #1,trak_9e
	clr.w   trak_a7
	bra     trak_86
trak_67	tst.l   trak_75
	beq     trak_86
	movea.l trak_75(pc),a5
trak_68	move.l  trak_76(pc),trak_ab
	move.l  trak_77(pc),trak_96
	move.l  trak_78(pc),trak_9a
	move.w  trak_79(pc),trak_9e
	clr.w   trak_a7
	jsr     trak_61(pc)
	bra     trak_86
trak_69	move.l  a6,trak_7a
	move.l  trak_ac(pc),trak_7b
	move.l  trak_97(pc),trak_7c
	move.l  trak_9b(pc),trak_7d
	move.w  trak_9f(pc),trak_7e
	movea.l trak_37(pc),a0
	cmpi.w  #2,296(a0)
	beq     trak_87
	lea     trak_ad(pc),a6
	move.l  #trak_ad,trak_ac
	move.w  #1,trak_9f
	clr.w   trak_a8
	bra     trak_87
trak_6a	tst.l   trak_7a
	beq     trak_87
	movea.l trak_7a(pc),a6
	move.l  trak_7b(pc),trak_ac
	move.l  trak_7c(pc),trak_97
	move.l  trak_7d(pc),trak_9b
	move.w  trak_7e(pc),trak_9f
	clr.w   trak_a8
	jsr     trak_61(pc)
	bra     trak_87

trak_6b	dc.l	0
trak_6c	dc.l	0
trak_6d	dc.l	0
trak_6e	dc.l	0
trak_6f	dc.l	0
trak_70	dc.l	0
trak_71	dc.l	0
trak_72	dc.l	0
trak_73	dc.l	0
trak_74	dc.l	0
trak_75	dc.l	0
trak_76	dc.l	0
trak_77	dc.l	0
trak_78	dc.l	0
trak_79	dc.l	0
trak_7a	dc.l	0
trak_7b	dc.l	0
trak_7c	dc.l	0
trak_7d	dc.l	0
trak_7e	dc.l	0

trak_7f	move.b  #$3c,trak_33
	clr.w   trak_a5
	bra     trak_84
trak_80	move.b  #$3c,trak_33
	clr.w   trak_a6
	bra     trak_85
trak_81	move.b  #$3c,trak_33
	clr.w   trak_a7
	bra     trak_86
trak_82	move.b  #$3c,trak_33
	clr.w   trak_a8
	bra     trak_87
trak_83	movea.l trak_37(pc),a1
	tst.w   trak_a5
	beq     trak_84
	lea     trak_51(pc),a0
	move.w  trak_a5(pc),d0
	cmp.w   #1,d0
	beq     trak_47
	cmp.w   #2,d0
	beq     trak_48
	cmp.w   #3,d0
	beq     trak_49
	cmp.w   #4,d0
	beq     trak_4a
	cmp.w   #5,d0
	beq     trak_4b
	cmp.w   #6,d0
	beq     trak_4c
	cmp.w   #7,d0
	beq     trak_4d
	cmp.w   #8,d0
	beq     trak_4e
	cmp.w   #9,d0
	beq     trak_4f
	cmp.w   #$a,d0
	beq     trak_50
	cmp.w   #$b,d0
	beq     trak_62
	cmp.w   #$c,d0
	beq     trak_63
	cmp.w   #$d,d0
	beq     trak_7f
trak_84	movea.l trak_37(pc),a1
	tst.w   trak_a6
	beq     trak_85
	lea     trak_55(pc),a0
	move.w  trak_a6(pc),d0
	cmp.w   #1,d0
	beq     trak_47
	cmp.w   #2,d0
	beq     trak_48
	cmp.w   #3,d0
	beq     trak_49
	cmp.w   #4,d0
	beq     trak_4a
	cmp.w   #5,d0
	beq     trak_4b
	cmp.w   #6,d0
	beq     trak_4c
	cmp.w   #7,d0
	beq     trak_4d
	cmp.w   #8,d0
	beq     trak_4e
	cmp.w   #9,d0
	beq     trak_4f
	cmp.w   #$a,d0
	beq     trak_50
	cmp.w   #$b,d0
	beq     trak_64
	cmp.w   #$c,d0
	beq     trak_65
	cmp.w   #$d,d0
	beq     trak_80
trak_85	movea.l trak_37(pc),a1
	tst.w   trak_a7
	beq     trak_86
	lea     trak_59(pc),a0
	move.w  trak_a7(pc),d0
	cmp.w   #1,d0
	beq     trak_47
	cmp.w   #2,d0
	beq     trak_48
	cmp.w   #3,d0
	beq     trak_49
	cmp.w   #4,d0
	beq     trak_4a
	cmp.w   #5,d0
	beq     trak_4b
	cmp.w   #6,d0
	beq     trak_4c
	cmp.w   #7,d0
	beq     trak_4d
	cmp.w   #8,d0
	beq     trak_4e
	cmp.w   #9,d0
	beq     trak_4f
	cmp.w   #$a,d0
	beq     trak_50
	cmp.w   #$b,d0
	beq     trak_66
	cmp.w   #$c,d0
	beq     trak_67
	cmp.w   #$d,d0
	beq     trak_81
trak_86	movea.l trak_37(pc),a1
	tst.w   trak_a8
	beq     trak_87
	lea     trak_5d(pc),a0
	move.w  trak_a8(pc),d0
	cmp.w   #1,d0
	beq     trak_47
	cmp.w   #2,d0
	beq     trak_48
	cmp.w   #3,d0
	beq     trak_49
	cmp.w   #4,d0
	beq     trak_4a
	cmp.w   #5,d0
	beq     trak_4b
	cmp.w   #6,d0
	beq     trak_4c
	cmp.w   #7,d0
	beq     trak_4d
	cmp.w   #8,d0
	beq     trak_4e
	cmp.w   #9,d0
	beq     trak_4f
	cmp.w   #$a,d0
	beq     trak_50
	cmp.w   #$b,d0
	beq     trak_69
	cmp.w   #$c,d0
	beq     trak_6a
	cmp.w   #$d,d0
	beq     trak_82
trak_87	rts

trak_88	jsr     trak_83
	movea.l trak_a1(pc),a2
	cmpa.l  trak_a9(pc),a3
	blt.s   trak_8a
	cmpi.w  #1,trak_9c
	beq.s   trak_89
	suba.l  trak_a9(pc),a3
	adda.l  trak_94(pc),a3
	move.l  trak_98(pc),trak_a9
	bra.s   trak_8a
trak_89	lea     trak_ad(pc),a3
	move.l  a3,trak_a9
trak_8a	cmpa.l  trak_aa(pc),a4
	blt.s   trak_8c
	cmpi.w  #1,trak_9d
	beq.s   trak_8b
	suba.l  trak_aa(pc),a4
	adda.l  trak_95(pc),a4
	move.l  trak_99(pc),trak_aa
	bra.s   trak_8c
trak_8b	lea     trak_ad(pc),a4
	move.l  a4,trak_aa
trak_8c	cmpa.l  trak_ab(pc),a5
	blt.s   trak_8e
	cmpi.w  #1,trak_9e
	beq.s   trak_8d
	suba.l  trak_ab(pc),a5
	adda.l  trak_96(pc),a5
	move.l  trak_9a(pc),trak_ab
	bra.s   trak_8e
trak_8d	lea     trak_ad(pc),a5
	move.l  a5,trak_ab
trak_8e	cmpa.l  trak_ac(pc),a6
	blt.s   trak_90
	cmpi.w  #1,trak_9f
	beq.s   trak_8f
	suba.l  trak_ac(pc),a6
	adda.l  trak_97(pc),a6
	move.l  trak_9b(pc),trak_ac
	bra.s   trak_90
trak_8f	lea     trak_ad(pc),a6
	move.l  a6,trak_ac
trak_90	rts

trak_91	dc.l    trak_b1
trak_92	dc.l    trak_b2
trak_93	dc.l    trak_b3
trak_94	dc.l    trak_ad
trak_95	dc.l    trak_ad
trak_96	dc.l    trak_ad
trak_97	dc.l    trak_ad
trak_98	dc.l    trak_ad
trak_99	dc.l    trak_ad
trak_9a	dc.l    trak_ad
trak_9b	dc.l    trak_ad
trak_9c	dc.b   $00,$01
trak_9d	dc.b   $00,$01
trak_9e	dc.b   $00,$01
trak_9f	dc.b   $00,$01
trak_a0	dcb.w    8,0
	dc.b   $00,$01,$02,$03,$04,$05,$06,$07
	dc.b   $08,$09,$0a,$0b,$00,$00,$00,$00
	dc.b   $0c,$0d,$0e,$0f,$10,$11,$12,$13
	dc.b   $14,$15,$16,$17,$00,$00,$00,$00
	dc.b   $18,$19,$1a,$1b,$1c,$1d,$1e,$1f
	dc.b   $20,$21,$22,$23,$00,$00,$00,$00
trak_a1	dc.l    trak_af
trak_a2	dc.l    trak_af
trak_a3	dc.l    trak_af
trak_a4	dc.l    trak_af
	dc.l    trak_af
trak_a5	dcb.w    1,0
trak_a6	dcb.w    1,0
trak_a7	dcb.w    1,0
trak_a8	dcb.w    1,0
trak_a9	dc.l    trak_ad
trak_aa	dc.l    trak_ad
trak_ab	dc.l    trak_ad
trak_ac	dc.l    trak_ad
trak_ad	dcb.l   250,$80808080
trak_ae	dcb.w    74,0
trak_af	dc.b   $08,$01,$09,$00,$0a,$00,$00,$00
	dc.b   $08,$01,$09,$00,$0a,$00,$00,$00
	dc.b   $08,$01,$09,$01,$0a,$00,$00,$00
	dc.b   $08,$01,$09,$01,$0a,$00,$00,$00
	dc.b   $08,$01,$09,$01,$0a,$01,$00,$00
	dc.b   $08,$01,$09,$01,$0a,$01,$00,$00
	dc.b   $08,$01,$09,$01,$0a,$02,$00,$00
	dc.b   $08,$01,$09,$01,$0a,$02,$00,$00
	dc.b   $08,$01,$09,$02,$0a,$02,$00,$00
	dc.b   $08,$01,$09,$02,$0a,$02,$00,$00
	dc.b   $08,$02,$09,$02,$0a,$02,$00,$00
	dc.b   $08,$02,$09,$02,$0a,$02,$00,$00
	dc.b   $08,$01,$09,$03,$0a,$03,$00,$00
	dc.b   $08,$01,$09,$03,$0a,$03,$00,$00
	dc.b   $08,$02,$09,$03,$0a,$03,$00,$00
	dc.b   $08,$02,$09,$03,$0a,$03,$00,$00
	dc.b   $08,$03,$09,$03,$0a,$03,$00,$00
	dc.b   $08,$03,$09,$03,$0a,$03,$00,$00
	dc.b   $08,$02,$09,$03,$0a,$04,$00,$00
	dc.b   $08,$02,$09,$03,$0a,$04,$00,$00
	dc.b   $08,$03,$09,$03,$0a,$04,$00,$00
	dc.b   $08,$03,$09,$03,$0a,$04,$00,$00
	dc.b   $08,$02,$09,$04,$0a,$04,$00,$00
	dc.b   $08,$02,$09,$04,$0a,$04,$00,$00
	dc.b   $08,$03,$09,$04,$0a,$04,$00,$00
	dc.b   $08,$03,$09,$04,$0a,$04,$00,$00
	dc.b   $08,$02,$09,$04,$0a,$05,$00,$00
	dc.b   $08,$02,$09,$04,$0a,$05,$00,$00
	dc.b   $08,$03,$09,$04,$0a,$05,$00,$00
	dc.b   $08,$03,$09,$04,$0a,$05,$00,$00
	dc.b   $08,$02,$09,$05,$0a,$05,$00,$00
	dc.b   $08,$02,$09,$05,$0a,$05,$00,$00
	dc.b   $08,$03,$09,$05,$0a,$05,$00,$00
	dc.b   $08,$03,$09,$05,$0a,$05,$00,$00
	dc.b   $08,$01,$09,$05,$0a,$06,$00,$00
	dc.b   $08,$01,$09,$05,$0a,$06,$00,$00
	dc.b   $08,$02,$09,$05,$0a,$06,$00,$00
	dc.b   $08,$02,$09,$05,$0a,$06,$00,$00
	dc.b   $08,$03,$09,$05,$0a,$06,$00,$00
	dc.b   $08,$03,$09,$05,$0a,$06,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$06,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$06,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$06,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$06,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$06,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$06,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$07,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$07,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$07,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$07,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$07,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$07,$00,$00
	dc.b   $08,$00,$09,$07,$0a,$07,$00,$00
	dc.b   $08,$00,$09,$07,$0a,$07,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$07,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$07,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$07,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$07,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$07,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$07,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$08,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$08,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$08,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$08,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$08,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$08,$00,$00
	dc.b   $08,$00,$09,$07,$0a,$08,$00,$00
	dc.b   $08,$00,$09,$07,$0a,$08,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$08,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$08,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$08,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$08,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$08,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$08,$00,$00
	dc.b   $08,$00,$09,$06,$0a,$09,$00,$00
	dc.b   $08,$00,$09,$06,$0a,$09,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$09,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$09,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$09,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$09,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$09,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$09,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$09,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$09,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$09,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$09,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$09,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$09,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$09,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$09,$00,$00
	dc.b   $08,$00,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$00,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$09,$00,$00
	dc.b   $08,$00,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$00,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$0a,$00,$00
	dc.b   $08,$00,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$00,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$0a,$00,$00
	dc.b   $08,$00,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$00,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$04,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$04,$09,$06,$0a,$0b,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$0b,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$0b,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$0b,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$0b,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$0b,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$0b,$00,$00
	dc.b   $08,$00,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$00,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$0b,$00,$00
	dc.b   $08,$01,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$01,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$02,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$02,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$03,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$03,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$04,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$04,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$05,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$05,$09,$0a,$0a,$0a,$00,$00
	dc.b   $08,$04,$09,$09,$0a,$0b,$00,$00
	dc.b   $08,$04,$09,$09,$0a,$0b,$00,$00
	dc.b   $08,$05,$09,$09,$0a,$0b,$00,$00
	dc.b   $08,$05,$09,$09,$0a,$0b,$00,$00
	dc.b   $08,$00,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$00,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$04,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$05,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$05,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$05,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$05,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$07,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$08,$0a,$0c,$00,$00
	dc.b   $08,$00,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$00,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$09,$0a,$0c,$00,$00
	dc.b   $08,$06,$09,$0b,$0a,$0b,$00,$00
	dc.b   $08,$06,$09,$0b,$0a,$0b,$00,$00
	dc.b   $08,$07,$09,$0b,$0a,$0b,$00,$00
	dc.b   $08,$07,$09,$0b,$0a,$0b,$00,$00
	dc.b   $08,$00,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$00,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$02,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$03,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$04,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$05,$09,$0a,$0a,$0c,$00,$00
	dc.b   $08,$01,$09,$05,$0a,$0d,$00,$00
	dc.b   $08,$02,$09,$05,$0a,$0d,$00,$00
	dc.b   $08,$03,$09,$05,$0a,$0d,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$01,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$02,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$03,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$04,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$04,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$05,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$05,$09,$06,$0a,$0d,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$0d,$00,$00
	dc.b   $08,$04,$09,$07,$0a,$0d,$00,$00
	dc.b   $08,$05,$09,$07,$0a,$0d,$00,$00
	dc.b   $08,$05,$09,$07,$0a,$0d,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$01,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$02,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$03,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$04,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$05,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$05,$09,$08,$0a,$0d,$00,$00
	dc.b   $08,$00,$09,$09,$0a,$0d,$00,$00
	dc.b   $08,$00,$09,$09,$0a,$0d,$00,$00
	dc.b   $08,$01,$09,$09,$0a,$0d,$00,$00
	dc.b   $08,$01,$09,$09,$0a,$0d,$00,$00
	dc.b   $08,$02,$09,$09,$0a,$0d,$00,$00
	dc.b   $08,$02,$09,$09,$0a,$0d,$00,$00
	dc.b   $08,$03,$09,$09,$0a,$0d,$00,$00
	dc.b   $08,$03,$09,$09,$0a,$0d,$00,$00
	dcb.w    13776,0

timer_a
	ifne	save_d7
	move.l	a0,usp
	move.l	d7,a0
	endc
	move.w	(a6)+,d7
	move.l	trak_b5(pc,d7.w),(a5)
	move.l	trak_b4(pc,d7.w),d7
	movep.l	d7,0(a5)
	ifne	save_d7
	move.l	a0,d7
	move.l	usp,a0
	endc
	rte

trak_b4	dc.b   $08,$0e,$09,$0d
trak_b5	dc.b   $0a,$0c,$00,$00,$08,$0f,$09,$03
	dc.b   $0a,$00,$00,$00,$08,$0f,$09,$03
	dc.b   $0a,$00,$00,$00,$08,$0f,$09,$03
	dc.b   $0a,$00,$00,$00,$08,$0f,$09,$03
	dc.b   $0a,$00,$00,$00,$08,$0f,$09,$03
	dc.b   $0a,$00,$00,$00,$08,$0f,$09,$03
	dc.b   $0a,$00,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0c,$00,$00,$08,$0e,$09,$0d
	dc.b   $0a,$00,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0d,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0d,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0d,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0d,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0d,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0d,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0c,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0c,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$09,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$09,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$05,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$00,$00,$00,$08,$0e,$09,$0c
	dc.b   $0a,$00,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$09,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$09,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$0c
	dc.b   $0a,$0c,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$07,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$00,$00,$00,$08,$0e,$09,$0b
	dc.b   $0a,$00,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$09,$00,$00,$08,$0e,$09,$0a
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$08,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$07,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$04,$00,$00,$08,$0d,$09,$0d
	dc.b   $0a,$00,$00,$00,$08,$0e,$09,$0a
	dc.b   $0a,$04,$00,$00,$08,$0e,$09,$09
	dc.b   $0a,$09,$00,$00,$08,$0e,$09,$09
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$09
	dc.b   $0a,$08,$00,$00,$08,$0e,$09,$09
	dc.b   $0a,$08,$00,$00,$08,$0e,$09,$09
	dc.b   $0a,$07,$00,$00,$08,$0e,$09,$08
	dc.b   $0a,$08,$00,$00,$08,$0e,$09,$09
	dc.b   $0a,$01,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$0c,$00,$00,$08,$0d,$09,$0c
	dc.b   $0a,$0a,$00,$00,$08,$0e,$09,$08
	dc.b   $0a,$06,$00,$00,$08,$0e,$09,$07
	dc.b   $0a,$07,$00,$00,$08,$0e,$09,$08
	dc.b   $0a,$00,$00,$00,$08,$0e,$09,$07
	dc.b   $0a,$05,$00,$00,$08,$0e,$09,$06
	dc.b   $0a,$06,$00,$00,$08,$0d,$09,$0c
	dc.b   $0a,$09,$00,$00,$08,$0e,$09,$05
	dc.b   $0a,$05,$00,$00,$08,$0e,$09,$04
	dc.b   $0a,$04,$00,$00,$08,$0d,$09,$0c
	dc.b   $0a,$08,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$0b,$00,$00,$08,$0e,$09,$00
	dc.b   $0a,$00,$00,$00,$08,$0d,$09,$0c
	dc.b   $0a,$06,$00,$00,$08,$0d,$09,$0c
	dc.b   $0a,$05,$00,$00,$08,$0d,$09,$0c
	dc.b   $0a,$02,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$0b,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$0a,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$0a,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$0a
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0a
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0a
	dc.b   $0a,$0a,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$09,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$09,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$06,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$0b,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$08,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$00,$00,$00,$08,$0d,$09,$0b
	dc.b   $0a,$00,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$07,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$06,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$05,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$03,$00,$00,$08,$0c,$09,$0c
	dc.b   $0a,$01,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0d,$09,$0a
	dc.b   $0a,$05,$00,$00,$08,$0d,$09,$0a
	dc.b   $0a,$04,$00,$00,$08,$0d,$09,$0a
	dc.b   $0a,$02,$00,$00,$08,$0d,$09,$09
	dc.b   $0a,$08,$00,$00,$08,$0d,$09,$09
	dc.b   $0a,$08,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$09,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$08
	dc.b   $0a,$08,$00,$00,$08,$0b,$09,$0b
	dc.b   $0a,$0b,$00,$00,$08,$0d,$09,$09
	dc.b   $0a,$05,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$08,$00,$00,$08,$0d,$09,$09
	dc.b   $0a,$02,$00,$00,$08,$0d,$09,$08
	dc.b   $0a,$06,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$07,$00,$00,$08,$0d,$09,$07
	dc.b   $0a,$07,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$06,$00,$00,$08,$0c,$09,$0a
	dc.b   $0a,$09,$00,$00,$08,$0b,$09,$0b
	dc.b   $0a,$0a,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$02,$00,$00,$08,$0c,$09,$0b
	dc.b   $0a,$00,$00,$00,$08,$0c,$09,$0a
	dc.b   $0a,$08,$00,$00,$08,$0d,$09,$06
	dc.b   $0a,$04,$00,$00,$08,$0d,$09,$05
	dc.b   $0a,$05,$00,$00,$08,$0d,$09,$05
	dc.b   $0a,$04,$00,$00,$08,$0c,$09,$09
	dc.b   $0a,$09,$00,$00,$08,$0d,$09,$04
	dc.b   $0a,$03,$00,$00,$08,$0b,$09,$0b
	dc.b   $0a,$09,$00,$00,$08,$0c,$09,$0a
	dc.b   $0a,$05,$00,$00,$08,$0b,$09,$0a
	dc.b   $0a,$0a,$00,$00,$08,$0c,$09,$09
	dc.b   $0a,$08,$00,$00,$08,$0b,$09,$0b
	dc.b   $0a,$08,$00,$00,$08,$0c,$09,$0a
	dc.b   $0a,$00,$00,$00,$08,$0c,$09,$0a
	dc.b   $0a,$00,$00,$00,$08,$0c,$09,$09
	dc.b   $0a,$07,$00,$00,$08,$0b,$09,$0b
	dc.b   $0a,$07,$00,$00,$08,$0c,$09,$09
	dc.b   $0a,$06,$00,$00,$08,$0b,$09,$0b
	dc.b   $0a,$06,$00,$00,$08,$0b,$09,$0a
	dc.b   $0a,$09,$00,$00,$08,$0b,$09,$0b
	dc.b   $0a,$05,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$0a,$00,$00,$08,$0b,$09,$0b
	dc.b   $0a,$02,$00,$00,$08,$0b,$09,$0a
	dc.b   $0a,$08,$00,$00,$08,$0c,$09,$07
	dc.b   $0a,$07,$00,$00,$08,$0c,$09,$08
	dc.b   $0a,$04,$00,$00,$08,$0c,$09,$07
	dc.b   $0a,$06,$00,$00,$08,$0b,$09,$09
	dc.b   $0a,$09,$00,$00,$08,$0c,$09,$06
	dc.b   $0a,$06,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$09,$00,$00,$08,$0c,$09,$07
	dc.b   $0a,$03,$00,$00,$08,$0b,$09,$0a
	dc.b   $0a,$05,$00,$00,$08,$0b,$09,$09
	dc.b   $0a,$08,$00,$00,$08,$0b,$09,$0a
	dc.b   $0a,$03,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$08,$00,$00,$08,$0b,$09,$0a
	dc.b   $0a,$00,$00,$00,$08,$0b,$09,$09
	dc.b   $0a,$07,$00,$00,$08,$0b,$09,$08
	dc.b   $0a,$08,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$07,$00,$00,$08,$0a,$09,$09
	dc.b   $0a,$09,$00,$00,$08,$0c,$09,$01
	dc.b   $0a,$01,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$06,$00,$00,$08,$0b,$09,$08
	dc.b   $0a,$07,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$05,$00,$00,$08,$0a,$09,$09
	dc.b   $0a,$08,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$02,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$01,$00,$00,$08,$0a,$09,$0a
	dc.b   $0a,$00,$00,$00,$08,$09,$09,$09
	dc.b   $0a,$09,$00,$00,$08,$0a,$09,$08
	dc.b   $0a,$08,$00,$00,$08,$0b,$09,$08
	dc.b   $0a,$01,$00,$00,$08,$0a,$09,$09
	dc.b   $0a,$06,$00,$00,$08,$0b,$09,$07
	dc.b   $0a,$04,$00,$00,$08,$0a,$09,$09
	dc.b   $0a,$05,$00,$00,$08,$09,$09,$09
	dc.b   $0a,$08,$00,$00,$08,$0a,$09,$09
	dc.b   $0a,$03,$00,$00,$08,$0a,$09,$08
	dc.b   $0a,$06,$00,$00,$08,$0a,$09,$09
	dc.b   $0a,$00,$00,$00,$08,$09,$09,$09
	dc.b   $0a,$07,$00,$00,$08,$09,$09,$08
	dc.b   $0a,$08,$00,$00,$08,$0a,$09,$08
	dc.b   $0a,$04,$00,$00,$08,$09,$09,$09
	dc.b   $0a,$06,$00,$00,$08,$0a,$09,$08
	dc.b   $0a,$01,$00,$00,$08,$09,$09,$09
	dc.b   $0a,$05,$00,$00,$08,$09,$09,$08
	dc.b   $0a,$07,$00,$00,$08,$08,$09,$08
	dc.b   $0a,$08,$00,$00,$08,$09,$09,$09
	dc.b   $0a,$02,$00,$00,$08,$09,$09,$08
	dc.b   $0a,$06,$00,$00,$08,$09,$09,$09
	dc.b   $0a,$00,$00,$00,$08,$09,$09,$07
	dc.b   $0a,$07,$00,$00,$08,$08,$09,$08
	dc.b   $0a,$07,$00,$00,$08,$09,$09,$07
	dc.b   $0a,$06,$00,$00,$08,$09,$09,$08
	dc.b   $0a,$02,$00,$00,$08,$08,$09,$08
	dc.b   $0a,$06,$00,$00,$08,$09,$09,$06
	dc.b   $0a,$06,$00,$00,$08,$08,$09,$07
	dc.b   $0a,$07,$00,$00,$08,$08,$09,$08
	dc.b   $0a,$04,$00,$00,$08,$08,$09,$07
	dc.b   $0a,$06,$00,$00,$08,$08,$09,$08
	dc.b   $0a,$02,$00,$00,$08,$07,$09,$07
	dc.b   $0a,$07,$00,$00,$08,$08,$09,$06
	dc.b   $0a,$06,$00,$00,$08,$08,$09,$07
	dc.b   $0a,$04,$00,$00,$08,$07,$09,$07
	dc.b   $0a,$06,$00,$00,$08,$08,$09,$06
	dc.b   $0a,$05,$00,$00,$08,$08,$09,$06
	dc.b   $0a,$04,$00,$00,$08,$07,$09,$06
	dc.b   $0a,$06,$00,$00,$08,$07,$09,$07
	dc.b   $0a,$04,$00,$00,$08,$08,$09,$05
	dc.b   $0a,$04,$00,$00,$08,$06,$09,$06
	dc.b   $0a,$06,$00,$00,$08,$07,$09,$06
	dc.b   $0a,$04,$00,$00,$08,$07,$09,$05
	dc.b   $0a,$05,$00,$00,$08,$06,$09,$06
	dc.b   $0a,$05,$00,$00,$08,$06,$09,$06
	dc.b   $0a,$04,$00,$00,$08,$06,$09,$05
	dc.b   $0a,$05,$00,$00,$08,$06,$09,$06
	dc.b   $0a,$02,$00,$00,$08,$06,$09,$05
	dc.b   $0a,$04,$00,$00,$08,$05,$09,$05
	dc.b   $0a,$05,$00,$00,$08,$06,$09,$05
	dc.b   $0a,$02,$00,$00,$08,$05,$09,$05
	dc.b   $0a,$04,$00,$00,$08,$05,$09,$04
	dc.b   $0a,$04,$00,$00,$08,$05,$09,$05
	dc.b   $0a,$02,$00,$00,$08,$04,$09,$04
	dc.b   $0a,$04,$00,$00,$08,$04,$09,$04
	dc.b   $0a,$03,$00,$00,$08,$04,$09,$04
	dc.b   $0a,$02,$00,$00,$08,$04,$09,$03
	dc.b   $0a,$03,$00,$00,$08,$03,$09,$03
	dc.b   $0a,$03,$00,$00,$08,$03,$09,$03
	dc.b   $0a,$02,$00,$00,$08,$03,$09,$02
	dc.b   $0a,$02,$00,$00,$08,$02,$09,$02
	dc.b   $0a,$02,$00,$00,$08,$02,$09,$02
	dc.b   $0a,$01,$00,$00,$08,$01,$09,$01
	dc.b   $0a,$01,$00,$00,$08,$02,$09,$01
	dc.b   $0a,$00,$00,$00,$08,$01,$09,$01
	dc.b   $0a,$00,$00,$00,$08,$01,$09,$00
	dc.b   $0a,$00,$00,$00,$08,$00,$09,$00
	dc.b   $0a,$00,$00,$00,$00,$00,$00,$00
	dcb.w    3070,0

