******************************************
**	SOUNDMONITOR V2.0 PLAYROUTINE	**
******************************************

_sm_init:
BS_INIT:bsr resetit
	lea	BS_D17,a0
	move.l	BS_DATA_PTR,a1
	clr.b	BS_D12
	cmpi.w	#$562e,$001a(a1)
	bne.w	BS_int1
	cmpi.b	#$32,$001c(a1)
	bne.w	BS_int1
	move.b	$001d(a1),BS_D12
BS_int1:move.l	#$00000200,d0
	move.w	$001e(a1),d1
	move.l	#$00000001,d2
	mulu	#$0004,d1
	subq.w	#$1,d1
BS_int2:cmp.w	$00(a1,d0.l),d2
	bge.w	BS_int3
	move.w	$00(a1,d0.l),d2
BS_int3:addq.l	#$4,d0
	dbf	d1,BS_int2
	move.w	$001e(a1),d1
	mulu	#$0010,d1
	move.l	#$00000200,d0
	mulu	#$0030,d2
	add.l	d2,d0
	add.l	d1,d0
;	move.l	_adr_data,d1
;	add.l	d1,d0
	add.l	BS_DATA_PTR,d0
	move.l	d0,BS_D14
	clr.l	d1
	move.b	BS_D12,d1
	lsl.l	#$6,d1
	add.l	d1,d0
	move.l	#$0000000e,d1
	adda.l	#$00000020,a1
BS_int4:move.l	d0,(a0)+
	cmpi.b	#-$01,(a1)
	beq.w	BS_int5
	move.w	$0018(a1),d2
	mulu	#$0002,d2
	add.l	d2,d0
BS_int5:adda.l	#$00000020,a1
	dbf	d1,BS_int4
	rts	
_sm_music:

BS_Music
	;bsr.s	BS_MS2
	;moveq	#$00,d0
	;rts	

BS_MS2:	bsr.w	BS_MX7
	subq.b	#$1,BS_D10
	move.l	#$00000003,d0
	lea	BS_D3,a0
	LEA ch1s,a1
BS_MS3:	move.b	$000c(a0),d4
	ext.w	d4
	add.w	d4,(a0)
	tst.b	$001e(a0)
	bne.w	BS_MS4
	move.w	(a0),sam_period(a1)
BS_MS4:	move.l d0,-(sp)
	move.l	$0004(a0),sam_lpstart(a1)
	moveq #0,d0
	move.w	$0008(a0),d0
	add.l d0,d0
	move.w d0,sam_lplength(a1)
	add.l d0,sam_lpstart(a1)
	move.l (sp)+,d0
	tst.b	$000b(a0)
	bne.w	BS_MS5
	tst.b	$000d(a0)
	beq.w	BS_MS8
BS_MS5:	tst.b	BS_D10
	bne.w	BS_MS6
	move.b	$000b(a0),d3
	move.b	$000d(a0),d4
	andi.w	#$00f0,d4
	andi.w	#$00f0,d3
	lsr.w	#$4,d3
	lsr.w	#$4,d4
	add.w	d3,d4
	add.b	$000a(a0),d4
	bsr.w	BS_MX6
	bra.w	BS_MS8

BS_MS6:	cmpi.b	#$01,BS_D10
	bne.w	BS_MS7
	move.b	$000b(a0),d3
	move.b	$000d(a0),d4
	andi.w	#$000f,d3
	andi.w	#$000f,d4
	add.w	d3,d4
	add.b	$000a(a0),d4
	bsr.w	BS_MX6
	bra.w	BS_MS8

BS_MS7:	move.b	$000a(a0),d4
	bsr.w	BS_MX6
BS_MS8:	lea	sam_vcsize(a1),a1
	lea	$0020(a0),a0
	dbf	d0,BS_MS3
	tst.b	BS_D10
	bne.w	BS_MS9
	move.b	#$03,BS_D10
BS_MS9:	subq.b	#$1,BS_D8
	beq.w	BS_MT1
	rts	

BS_MT1:	move.b	BS_D9,BS_D8
	bsr.s	BS_MU1
	move.w	BS_D13,d0
	move_dmacon d0

	move.l	#$00000003,d0
	lea.l	ch1s,a1
	move.w	#$0001,d1
	lea	BS_D3,a2
	lea	BS_D15,a5
BS_MT3:	btst	#$07,(a2)
	beq.w	BS_MT4
	bsr.w	BS_MW3
BS_MT4:	asl.w	#$1,d1
	lea	sam_vcsize(a1),a1
	lea	$0020(a2),a2
	lea	$0024(a5),a5
	dbf	d0,BS_MT3
	rts	

BS_MU1:	clr.w	BS_D13
;	move.l	_adr_data,a0
	MOVE.L	BS_DATA_PTR,a0
	lea.l	ch1s,a3
	move.l	#$00000003,d0
	move.w	#$0001,d7
	lea	BS_D3,a1
BS_MU2:	clr.l	d1
	move.w	BS_D4,d1
	lsl.w	#$4,d1
	move.l	d0,d2
	lsl.l	#$2,d2
	add.l	d2,d1
	addi.l	#$00000200,d1
	move.w	$00(a0,d1.l),d2
	move.b	$02(a0,d1.l),BS_D6
	move.b	$03(a0,d1.l),BS_D7
	subq.w	#$1,d2
	mulu	#$0030,d2
	clr.l	d3
	move.w	$001e(a0),d3
	lsl.w	#$4,d3
	add.l	d2,d3
	move.l	#$00000200,d4
	move.b	BS_D5,d4
	add.l	d3,d4
	move.l	d4,a2
	adda.l	a0,a2
	clr.l	d3
	move.b	(a2),d3
	tst.b	d3
	bne.w	BS_MU3
	bra.w	BS_MV0

BS_MU3:	clr.w	$000c(a1)
	move.b	$0001(a2),d4
	andi.b	#$0f,d4
	cmpi.b	#$0a,d4
	bne.w	BS_MU4
	move.b	$0002(a2),d4
	andi.b	#-$10,d4
	bne.w	BS_MU5
BS_MU4:	add.b	BS_D7,d3
	ext.w	d3
BS_MU5:	move.b	d3,$000a(a1)
	lea	BS_D16,a4
	lsl.w	#$1,d3
	move.w	-$02(a4,d3.w),(a1)
	bset	#$07,(a1)
	move.b	#-$01,$0002(a1)
	clr.w	d3
	move.b	$0001(a2),d3
	lsr.b	#$4,d3
	andi.b	#$0f,d3
	tst.b	d3
	bne.w	BS_MU6
	move.b	$0003(a1),d3
BS_MU6:	move.b	$0001(a2),d4
	andi.b	#$0f,d4
	cmpi.b	#$0a,d4
	bne.w	BS_MU7
	move.b	$0002(a2),d4
	andi.b	#$0f,d4
	bne.w	BS_MU8
BS_MU7:	add.b	BS_D6,d3
BS_MU8:	cmpi.w	#$0001,$0008(a1)
	beq.w	BS_MU9
	cmp.b	$0003(a1),d3
	beq.w	BS_MV0
BS_MU9:	move.b	d3,$0003(a1)
	or.w	d7,BS_D13
BS_MV0:	clr.l	d3
	clr.l	d4
	move.b	$0001(a2),d3
	andi.b	#$0f,d3
	move.b	$0002(a2),d4
	cmpi.b	#$00,d3
	bne.w	BS_MV1
	move.b	d4,$000b(a1)
BS_MV1:	cmpi.b	#$01,d3
	bne.w	BS_MV2
	move.w	d4,sam_vol(a3)
	move.b	d4,$0002(a1)
BS_MV2:	cmpi.b	#$02,d3
	bne.w	BS_MV3
	move.b	d4,BS_D8
	move.b	d4,BS_D9
BS_MV3:	cmpi.b	#$03,d3
	bne.w	BS_MV5
	tst.b	d4
	bne.w	BS_MV4
	;bset	#$01,$00bfe001
	bra.w	BS_MW1

BS_MV4:	;bclr	#$01,$00bfe001
BS_MV5:	cmpi.b	#$04,d3
	bne.w	BS_MV6
	sub.w	d4,(a1)
	clr.b	$000b(a1)
BS_MV6:	cmpi.b	#$05,d3
	bne.w	BS_MV7
	add.w	d4,(a1)
	clr.b	$000b(a1)
BS_MV7:	cmpi.b	#$06,d3
	bne.w	BS_MV8
	move.b	d4,BS_D11
BS_MV8:	cmpi.b	#$07,d3
	bne.w	BS_MV9
	subq.b	#$1,BS_D11
	beq.w	BS_MV9
	move.w	d4,BS_D4
BS_MV9:	cmpi.b	#$08,d3
	bne.w	BS_MW0
	move.b	d4,$000c(a1)
BS_MW0:	cmpi.b	#$09,d3
	bne.w	BS_MW1
	move.b	d4,$000d(a1)
BS_MW1:	lea	sam_vcsize(a3),a3
	lea	$0020(a1),a1
	asl.w	#$1,d7
	dbf	d0,BS_MU2
	addq.b	#$3,BS_D5
	cmpi.b	#$30,BS_D5
	bne.w	BS_MW2
	move.b	#$00,BS_D5
	addq.w	#$1,BS_D4
;	move.l	_adr_data,a0
	MOVE.L	BS_DATA_PTR,a0
	move.w	$001e(a0),d1
	cmp.w	BS_D4,d1
	bne.w	BS_MW2
	move.w	#$0000,BS_D4
BS_MW2:	rts	

BS_MW3:	bclr	#$07,(a2)
	tst.l	(a5)
	beq.w	BS_MW5
	clr.w	d3
	move.l	(a5),a4
	moveq	#$07,d7
BS_MW4:	move.l	$04(a5,d3.w),(a4)+
	addq.w	#$4,d3
	dbf	d7,BS_MW4
BS_MW5:	move.w	(a2),sam_period(a1)
	clr.l	d7
	move.b	$0003(a2),d7
	move.l	d7,d6
	lsl.l	#$5,d7
;	move.l	_adr_data,a3
	MOVE.L	BS_DATA_PTR,a3
	cmpi.b	#-$01,$00(a3,d7.w)
	beq.w	BS_MX0
	clr.l	(a5)
	clr.b	$001a(a2)
	clr.w	$001e(a2)
	addi.l	#$00000018,d7
	lsl.l	#$2,d6
	lea	BS_D17,a4
	move.l	-$04(a4,d6.l),d4
	beq.w	BS_MW7

	move.l d0,-(Sp)
	move.l	d4,sam_start(a1)
	moveq #0,d0
	move.w	$00(a3,d7.l),d0
	add.l d0,d0
	add.l d0,sam_start(a1)
	move.w d0,sam_length(a1)
	move.l (sp)+,d0

	move.b	$0002(a2),sam_vol+1(a1)
	cmpi.b	#-$01,$0002(a2)
	bne.w	BS_MW6
	move.w	$06(a3,d7.l),sam_vol(a1)
BS_MW6:	move.w	$04(a3,d7.l),$0008(a2)
	clr.l	d6
	move.w	$02(a3,d7.l),d6
	add.l	d6,d4
	move.l	d4,$0004(a2)
	cmpi.w	#$0001,$0008(a2)
	bne.w	BS_MW8
BS_MW7:	move.l	#BS_D2,$0004(a2)
	bra.w	BS_MW9

BS_MW8:	move.l d0,-(sp)
	moveq #0,d0
	move.l	$0004(a2),sam_start(a1)
	move.w	$0008(a2),d0
	add.l d0,d0
	move.w d0,sam_length(a1)
	add.l d0,sam_start(a1)
	move.l (sp)+,d0

BS_MW9:	addi.w	#-$8000,d1
	;move.w	d1,$00dff096
	move_dmacon d1
	rts	

BS_MX0:	move.b	#$01,$001a(a2)
	clr.w	$000e(a2)
	clr.w	$0010(a2)
	clr.w	$0012(a2)
	move.w	$16(a3,d7.w),$0014(a2)
	addq.w	#$1,$0014(a2)
	move.w	$0e(a3,d7.w),$0016(a2)
	addq.w	#$1,$0016(a2)
	move.w	#$0001,$0018(a2)
	move.b	$11(a3,d7.w),$001d(a2)
	move.b	$09(a3,d7.w),$001e(a2)
	move.b	$04(a3,d7.w),$001f(a2)
	move.b	$13(a3,d7.w),$001c(a2)
	move.l	BS_D14,a4
	clr.l	d3
	move.b	$01(a3,d7.w),d3
	lsl.l	#$6,d3
	adda.l	d3,a4
	move.l	a4,(a1)
	move.l	a4,$0004(a2)
	move.w	$02(a3,d7.w),$0004(a1)
	move.w	$02(a3,d7.w),$0008(a2)
	tst.b	$04(a3,d7.w)
	beq.w	BS_MX2
	move.l	BS_D14,a4
	clr.l	d3
	move.b	$05(a3,d7.w),d3
	lsl.l	#$6,d3
	adda.l	d3,a4
	clr.w	d3
	move.b	(a4),d3
	addi.b	#-$80,d3
	lsr.w	#$2,d3
	cmpi.b	#-$01,$0002(a2)
	bne.w	BS_MX1
	move.b	$19(a3,d7.w),$0002(a2)
BS_MX1:	clr.w	d4
	move.b	$0002(a2),d4
	mulu	d4,d3
	lsr.w	#$6,d3
	move.w	d3,$0008(a1)
	bra.w	BS_MX3

BS_MX2:	move.b	$0002(a2),$0009(a1)
	cmpi.b	#-$01,$0002(a2)
	bne.w	BS_MX3
	move.b	$19(a3,d7.w),$0009(a1)
BS_MX3:	move.l	$0004(a2),a4
	move.l	a4,(a5)
	clr.w	d3
	moveq	#$07,d4
BS_MX4:	move.l	$00(a4,d3.w),$04(a5,d3.w)
	addq.w	#$4,d3
	dbf	d4,BS_MX4
	tst.b	$11(a3,d7.w)
	beq.w	BS_MW9
	tst.b	$13(a3,d7.w)
	beq.w	BS_MW9
	clr.l	d3
	move.b	$13(a3,d7.w),d3
	lsr.l	#$3,d3
	move.b	d3,$001c(a2)
	subq.l	#$1,d3
BS_MX5:	neg.b	(a4)+
	dbf	d3,BS_MX5
	bra.w	BS_MW9

BS_MX6:	lea	BS_D16,a4
	ext.w	d4
	asl.w	#$1,d4
	move.w	-$02(a4,d4.w),$0006(a1)
	rts	

BS_MX7:	move.l	#$00000003,d0
	lea	BS_D3,a2
	lea	ch1s,a1
;	move.l	_adr_data,a3
	MOVE.L	BS_DATA_PTR,a3
	lea	BS_D15,a5
BS_MX8:	tst.b	$001a(a2)
	beq.w	BS_MX9
	bsr.s	BS_MY0
BS_MX9:	lea	$0024(a5),a5
	lea	$0020(a2),a2
	lea	sam_vcsize(a1),a1
	dbf	d0,BS_MX8
	rts	

BS_MY0:	clr.w	d7
	move.b	$0003(a2),d7
	lsl.w	#$5,d7
	tst.b	$001f(a2)
	beq.w	BS_MY1
	subq.w	#$1,$0018(a2)
	bne.w	BS_MY1
	clr.l	d3
	move.b	$08(a3,d7.w),d3
	move.w	d3,$0018(a2)
	move.l	BS_D14,a4
	move.b	$05(a3,d7.w),d3
	lsl.l	#$6,d3
	adda.l	d3,a4
	move.w	$0012(a2),d3
	clr.w	d4
	move.b	$00(a4,d3.w),d4
	addi.b	#-$80,d4
	lsr.w	#$2,d4
	clr.w	d3
	move.b	$0002(a2),d3
	mulu	d3,d4
	lsr.w	#$6,d4
	move.w	d4,sam_vol(a1)
	addq.w	#$1,$0012(a2)
	move.w	$06(a3,d7.w),d4
	cmp.w	$0012(a2),d4
	bne.w	BS_MY1
	clr.w	$0012(a2)
	cmpi.b	#$01,$001f(a2)
	bne.w	BS_MY1
	clr.b	$001f(a2)
BS_MY1:	tst.b	$001e(a2)
	beq.w	BS_MY3
	subq.w	#$1,$0016(a2)
	bne.w	BS_MY3
	clr.l	d3
	move.b	$10(a3,d7.w),d3
	move.w	d3,$0016(a2)
	move.l	BS_D14,a4
	move.b	$0a(a3,d7.w),d3
	lsl.l	#$6,d3
	adda.l	d3,a4
	move.w	$0010(a2),d3
	clr.l	d4
	move.b	$00(a4,d3.w),d4
	ext.w	d4
	ext.l	d4
	clr.l	d5
	move.b	$0b(a3,d7.w),d5
	tst.b	d5
	beq.w	BS_MY2
	divs	d5,d4
BS_MY2:	move.w	(a2),d5
	add.w	d4,d5
	move.w	d5,sam_period(a1)
	addq.w	#$1,$0010(a2)
	move.w	$0c(a3,d7.w),d3
	cmp.w	$0010(a2),d3
	bne.w	BS_MY3
	clr.w	$0010(a2)
	cmpi.b	#$01,$001e(a2)
	bne.w	BS_MY3
	clr.b	$001e(a2)
BS_MY3:	tst.b	$001d(a2)
	beq.w	BS_MY8
	subq.w	#$1,$0014(a2)
	bne.w	BS_MY8
	tst.l	(a5)
	beq.w	BS_MY8
	clr.l	d3
	move.b	$18(a3,d7.w),d3
	move.w	d3,$0014(a2)
	move.l	BS_D14,a4
	move.b	$12(a3,d7.w),d3
	lsl.l	#$6,d3
	adda.l	d3,a4
	move.w	$000e(a2),d3
	clr.l	d4
	move.b	$00(a4,d3.w),d4
	move.l	(a5),a4
	addi.b	#-$80,d4
	lsr.l	#$3,d4
	clr.l	d3
	move.b	$001c(a2),d3
	move.b	d4,$001c(a2)
	adda.l	d3,a4
	move.l	a5,a6
	adda.l	d3,a6
	addq.l	#$4,a6
	cmp.b	d3,d4
	beq.w	BS_MY7
	bgt.w	BS_MY5
	sub.l	d4,d3
	subq.l	#$1,d3
BS_MY4:	move.b	-(a6),d4
	move.b	d4,-(a4)
	dbf	d3,BS_MY4
	bra.w	BS_MY7

BS_MY5:	sub.l	d3,d4
	subq.l	#$1,d4
BS_MY6:	move.b	(a6)+,d3
	neg.b	d3
	move.b	d3,(a4)+
	dbf	d4,BS_MY6
BS_MY7:	addq.w	#$1,$000e(a2)
	move.w	$14(a3,d7.w),d3
	cmp.w	$000e(a2),d3
	bne.w	BS_MY8
	clr.w	$000e(a2)
	cmpi.b	#$01,$001d(a2)
	bne.w	BS_MY8
	clr.b	$001d(a2)
BS_MY8:	rts	

BS_D1:	dcb.b	8,$00
	dc.b	$02,$7f
	dcb.b	8,$00
	dc.l	BS_Music
BS_D2:	dcb.b	2,$00
BS_D3:	dcb.b	4,$00
	dc.l	BS_D2
	dc.b	$00,$01
	dcb.b	26,$00
	dc.l	BS_D2
	dc.b	$00,$01
	dcb.b	26,$00
	dc.l	BS_D2
	dc.b	$00,$01
	dcb.b	26,$00
	dc.l	BS_D2
	dc.b	$00,$01
	dcb.b	22,$00
BS_D4:	dcb.b	2,$00
BS_D5:	dcb.b	1,$00
BS_D6:	dcb.b	1,$00
BS_D7:	dcb.b	1,$00
BS_D8:	dc.b	$01
BS_D9:	dc.b	$06
BS_D10:	dc.b	$01
BS_D11:	dc.b	$01
BS_D12:	dcb.b	1,$00
BS_D13:	dcb.b	2,$00
BS_D14:	dcb.b	4,$00
BS_D15:	dcb.b	144,$00
	dc.b	$1a,$c0,$19,$40,$17,$c0
	dc.b	$16,$80,$15,$40,$14,$00
	dc.b	$12,$e0,$11,$e0,$10,$e0
	dc.b	$0f,$e0,$0f,$00,$0e,$20
	dc.b	$0d,$60,$0c,$a0,$0b,$e0
	dc.b	$0b,$40,$0a,$a0,$0a,$00
	dc.b	$09,$70,$08,$f0,$08,$70
	dc.b	$07,$f0,$07,$80,$07,$10
	dc.b	$06,$b0,$06,$50,$05,$f0
	dc.b	$05,$a0,$05,$50,$05,$00
	dc.b	$04,$b8,$04,$78,$04,$38
	dc.b	$03,$f8,$03,$c0,$03,$88
BS_D16:	dc.b	$03,$58,$03,$28,$02,$f8
	dc.b	$02,$d0,$02,$a8,$02,$80
	dc.b	$02,$5c,$02,$3c,$02,$1c
	dc.b	$01,$fc,$01,$e0,$01,$c4
	dc.b	$01,$ac,$01,$94,$01,$7c
	dc.b	$01,$68,$01,$54,$01,$40
	dc.b	$01,$2e,$01,$1e,$01,$0e
	dc.b	$00,$fe,$00,$f0,$00,$e2
	dc.b	$00,$d6,$00,$ca,$00,$be
	dc.b	$00,$b4,$00,$aa,$00,$a0
	dc.b	$00,$97,$00,$8f,$00,$87
	dc.b	$00,$7f,$00,$78,$00,$71
	dc.b	$00,$6b,$00,$65,$00,$5f
	dc.b	$00,$5a,$00,$55,$00,$50
	dc.b	$00,$4c,$00,$48,$00,$44
	dc.b	$00,$40,$00,$3c,$00,$39
BS_D17:	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
BS_DATAEND:
	dc.b	$c8,$ca,$cd,$cf,$cf,$d6

BS_DATA_PTR	DC.L 0
resetit
	LEA res,A0
	LEA BS_D1,A1
	MOVE.L #endres-res,D0
.lp	MOVE.B (A0)+,(A1)+
	SUBQ.L #1,D0
	BNE.S .lp
	RTS
	
res
	dcb.b	8,$00
	dc.b	$02,$7f
	dcb.b	8,$00
	dc.l	BS_Music
	dcb.b	2,$00
	dcb.b	4,$00
	dc.l	BS_D2
	dc.b	$00,$01
	dcb.b	26,$00
	dc.l	BS_D2
	dc.b	$00,$01
	dcb.b	26,$00
	dc.l	BS_D2
	dc.b	$00,$01
	dcb.b	26,$00
	dc.l	BS_D2
	dc.b	$00,$01
	dcb.b	22,$00
	dcb.b	2,$00
	dcb.b	1,$00
	dcb.b	1,$00
	dcb.b	1,$00
	dc.b	$01
	dc.b	$06
	dc.b	$01
	dc.b	$01
	dcb.b	1,$00
	dcb.b	2,$00
	dcb.b	4,$00
	dcb.b	144,$00
	dc.b	$1a,$c0,$19,$40,$17,$c0
	dc.b	$16,$80,$15,$40,$14,$00
	dc.b	$12,$e0,$11,$e0,$10,$e0
	dc.b	$0f,$e0,$0f,$00,$0e,$20
	dc.b	$0d,$60,$0c,$a0,$0b,$e0
	dc.b	$0b,$40,$0a,$a0,$0a,$00
	dc.b	$09,$70,$08,$f0,$08,$70
	dc.b	$07,$f0,$07,$80,$07,$10
	dc.b	$06,$b0,$06,$50,$05,$f0
	dc.b	$05,$a0,$05,$50,$05,$00
	dc.b	$04,$b8,$04,$78,$04,$38
	dc.b	$03,$f8,$03,$c0,$03,$88
	dc.b	$03,$58,$03,$28,$02,$f8
	dc.b	$02,$d0,$02,$a8,$02,$80
	dc.b	$02,$5c,$02,$3c,$02,$1c
	dc.b	$01,$fc,$01,$e0,$01,$c4
	dc.b	$01,$ac,$01,$94,$01,$7c
	dc.b	$01,$68,$01,$54,$01,$40
	dc.b	$01,$2e,$01,$1e,$01,$0e
	dc.b	$00,$fe,$00,$f0,$00,$e2
	dc.b	$00,$d6,$00,$ca,$00,$be
	dc.b	$00,$b4,$00,$aa,$00,$a0
	dc.b	$00,$97,$00,$8f,$00,$87
	dc.b	$00,$7f,$00,$78,$00,$71
	dc.b	$00,$6b,$00,$65,$00,$5f
	dc.b	$00,$5a,$00,$55,$00,$50
	dc.b	$00,$4c,$00,$48,$00,$44
	dc.b	$00,$40,$00,$3c,$00,$39
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.l	BS_DATAEND
	dc.b	$c8,$ca,$cd,$cf,$cf,$d6
endres	
	EVEN
