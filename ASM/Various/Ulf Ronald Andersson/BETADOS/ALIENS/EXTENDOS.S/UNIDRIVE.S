;----------------------------------------------------------------------------
;File name:	UNIDRIVE.S			Revision date:	1998.08.27
;Revised by:	Ulf Ronald Andersson		Revision start:	1995.07.04
;----------------------------------------------------------------------------
;Desert	Drain V1.41   68000er Disassembler  04.07.1995 04:05:36
;DATEI:	UNIDRIVE.DOS   4087 Bytes
;TEXT:	 3482	$00D9A
;DATA:	  512	$00200
;BSS:	  284  $00011C
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
start:
	movem.l	D2-D4/A4,-(SP)
	movea.l	D0,A4
	gemdos	Cconws,driver_name_s
	gemdos	Cconws,copyright_s
	move.l	#4,opt_Buffers
	move.l	#4,opt_Paths
	move.w	#0,opt_Read_only_f
	lea	$80(A4),A4
	moveq	#0,D4
	move.b	(A4)+,D4
	beq	T_F8
eval_option_loop:
	cmpi.b	#'B',(A4)
	beq.s	eval_option_B
	cmpi.b	#'P',(A4)
	beq.s	eval_option_P
	cmpi.b	#'R',(A4)
	beq.s	eval_option_R
	bra	T_F0
;
eval_option_B:
	bsr	eval_option
	tst.l	D1
	bmi.s	T_80
	cmpi.l	#2,D1
	blt.s	T_80
	cmpi.l	#$80,D1
	bgt.s	T_80
	move.l	D1,opt_Buffers
	bra.s	T_F0
;
T_80:
	pea	option_B_EQ_4_s
	bra.s	T_DA
;
eval_option_P:
	bsr	eval_option
	tst.l	D1
	bmi.s	T_A8
	cmpi.l	#2,D1
	blt.s	T_A8
	cmpi.l	#$20,D1
	bgt.s	T_A8
	move.l	D1,opt_Paths
	bra.s	T_F0
;
T_A8:
	pea	option_P_EQ_4_s
	bra.s	T_DA
;
eval_option_R:
	cmpi.w	#3,D4
	blt.s	T_D4
	addq.l	#1,A4
	cmpi.b	#'/',(A4)+
	bne.s	T_D4
	cmpi.b	#'W',(A4)
	beq.s	T_F0
	cmpi.b	#'O',(A4)
	bne.s	T_D4
	move.w	#1,opt_Read_only_f
	bra.s	T_F0
;
T_D4:
	pea	option_R_W_s
T_DA:
	gemdos	Cconws,invalid_option_s
	gemdos	Cconws,()
T_F0:
	addq.l	#1,A4
	subq.w	#1,D4
	bpl	eval_option_loop
T_F8:
	move.l	opt_Paths,D1
	asl.l	#8,D1
	asl.l	#3,D1		;d1 = (opt_Paths)*2048
	move.l	D1,paths_RAM_size
	move.l	#init_DOS_func_t_p,D0
	move.l	#driver_name_s,D1
	movem.l	(SP)+,D2-D4/A4
	rts
;----------------------------------------------------------------------------
eval_option:
	cmpi.w	#3,D4
	blt.s	.error
	cmpi.b	#'=',1(A4)
	bne.s	.error
	addq.l	#2,A4	;a4 += 2
	subq.w	#2,D4	;d4 -= 2
	moveq	#0,D1	;d1 = 0
.loop:
	moveq	#0,D3
	move.b	(A4),D3
	cmpi.b	#' ',D3
	beq.s	.exit
	subi.b	#$30,D3
	bmi.s	.error
	cmpi.b	#9,D3
	bgt.s	.error
	move.l	D1,D2	;d2 = d1
	asl.l	#2,D2	;d2 = d1*4
	add.l	D1,D2	;d2 = d1*1
	asl.l	#1,D2	;d2 = d1*10
	add.l	D2,D3	;d3 += d1*10
	move.l	D3,D1	;d1 = d3
	addq.l	#1,A4	;a4 += 1
	subq.l	#1,D4	;d4 -= 1
	bne.s	.loop
.exit:
	rts
;
.error:
	moveq	#$ffFFffFF,D1
	rts
;----------------------------------------------------------------------------
;Entry:	d0 =  BOS drive char
;
init_DOS_func:
	movem.l	D3-D4/A3,-(SP)
	move.l	D0,D3
	move.l	opt_Buffers,D0
	asl.l	#8,D0
	asl.l	#3,D0		;d0 = (opt_Buffers)*2048
	addi.l	#$E3A,D0
	add.l	paths_RAM_size,D0
	gemdos	Malloc,d0
	tst.l	D0
	bne.s	T_18A
	moveq	#$ffFFffD9,D0
	bra.s	T_1DC
;
T_18A:
	movea.l	D0,A3
	addi.l	#$E3A,D0
	add.l	paths_RAM_size,D0
	lea	$3A(A3),A0
	move.l	opt_Buffers,D1
	subq.l	#1,D1
T_1A4:
	move.l	D0,8(A0)
	addi.l	#$800,D0
	adda.w	#12,A0
	dbra	D1,T_1A4
	move.l	D3,(A3)
	bsr	T_60C
	cmpi.l	#-15,D0
	beq.s	T_1CC
	cmpi.l	#-12,D0
	bne.s	T_1D8
T_1CC:
	exg	A3,D0
	gemdos	Mfree|_ind,d0
T_1D8:
	move.l	A3,D0
	clr.l	D1
T_1DC:
	movem.l	(SP)+,D3-D4/A3
	rts
;----------------------------------------------------------------------------
dos_E_ACCDN:
	moveq	#E_ACCDN,D0
	rts
;----------------------------------------------------------------------------
dos_Dfree:
	bsr	T_CAE
	tst.l	D0
	bmi.s	T_20C
	movea.l	6(SP),A0
	move.l	#0,(A0)+
	move.l	4(A3),(A0)+
	move.w	#0,(A0)+
	move.w	8(A3),(A0)+
	move.l	#1,(A0)
	moveq	#0,D0
T_20C:
	rts
;----------------------------------------------------------------------------
dos_Dsetpath:
	bsr	T_CAE
	tst.l	D0
	bmi.s	T_23A
	lea	B_FB6,A0
T_21C:
	move.b	(A4)+,(A0)+
	bne.s	T_21C
	cmpi.b	#'\',-$2(A0)
	beq.s	T_230
	move.b	#'\',-$1(A0)
	clr.b	(A0)
T_230:
	lea	B_FB6,A4
	bsr	T_896
T_23A:
	rts
;----------------------------------------------------------------------------
dos_Fopen:
	bsr	T_CAE
	tst.l	D0
	bmi	T_2D6
	bsr	T_896
	tst.l	D0
	bmi	T_2D6
	bsr	T_A0C
	tst.l	D0
	bmi.s	T_2D6
	bsr	T_A6C
	tst.l	D0
	bmi.s	T_2D6
	lea	$19(A0),A1
	cmpi.b	#0,$31(A3)
	bne.s	T_270
	lea	$18(A0),A1
T_270:
	btst	#1,(A1)
	beq.s	T_27A
	moveq	#$ffFFffDF,D0
	bra.s	T_2D6
;
T_27A:
	move.l	6(A0),D0
	cmpi.b	#0,$22(A3)
	beq.s	T_290
	move.l	2(A0),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
T_290:
	cmpi.w	#$200,8(A3)
	beq.s	T_2A2
	cmpi.w	#$400,8(A3)
	beq.s	T_2A4
	bra.s	T_2A6
;
T_2A2:
	asr.l	#1,D0
T_2A4:
	asr.l	#1,D0
T_2A6:
	move.l	D0,(A5)
	move.l	14(A0),D0
	cmpi.b	#0,$22(A3)
	beq.s	T_2BE
	move.l	10(A0),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
T_2BE:
	move.l	D0,4(A5)
	move.l	#0,8(A5)
	lea	12(A5),A1
	bsr.s	T_2D8
	moveq	#0,D0
	move.b	1(A0),D0
T_2D6:
	rts
;----------------------------------------------------------------------------
T_2D8:
	move.b	$15(A0),D0
	andi.w	#$1F,D0
	move.b	$16(A0),D1
	andi.w	#$3F,D1
	move.b	$17(A0),D2
	asr.w	#1,D2
	andi.w	#$1F,D2
	ror.w	#5,D0
	asl.w	#5,D1
	or.w	D1,D0
	or.w	D2,D0
	move.w	D0,(A1)
	move.b	$12(A0),D0
	subi.b	#$50,D0
	andi.w	#$7F,D0
	move.b	$13(A0),D1
	andi.w	#15,D1
	move.b	$14(A0),D2
	andi.w	#$1F,D2
	ror.w	#7,D0
	asl.w	#5,D1
	or.w	D1,D0
	or.w	D2,D0
	move.w	D0,2(A1)
	rts
;----------------------------------------------------------------------------
dos_Fclose:
	bsr	T_CAE
	tst.l	D0
	bmi.s	T_33C
	moveq	#$ffFFffFF,D0
	move.l	D0,(A5)
	move.l	D0,4(A5)
	move.l	D0,8(A5)
	moveq	#0,D0
T_33C:
	rts
;----------------------------------------------------------------------------
dos_Fread:
	bsr	T_CAE
	tst.l	D0
	bmi	T_444
	andi.w	#8,D0
	beq.s	T_354
	moveq	#$ffFFffF2,D0
	bra	T_444
;
T_354:
	move.l	8(A5),D3
	move.w	#11,D0
	asr.l	D0,D3
	add.l	(A5),D3
	movea.l	12(SP),A4
	move.l	8(SP),D4
	move.l	4(A5),D0
	sub.l	8(A5),D0
	cmp.l	D0,D4
	ble.s	T_376
	move.l	D0,D4
T_376:
	tst.l	D4
	bne.s	T_380
	moveq	#0,D0
	bra	T_444
;
T_380:
	move.l	8(A5),D0
	andi.w	#$7FF,D0
	beq.s	T_3B6
	move.l	#$800,D5
	sub.w	D0,D5
	cmp.l	D5,D4
	bge.s	T_398
	move.l	D4,D5
T_398:
	sub.l	D5,D4
	subq.w	#1,D5
	lea	$63A(A3),A6
	adda.w	D0,A6
	move.l	D3,D0
	addq.l	#1,D3
	bsr	T_B94
	tst.l	D0
	bmi	T_444
T_3B0:
	move.b	(A6)+,(A4)+
	dbra	D5,T_3B0
T_3B6:
	move.l	A4,D0
	btst	#0,D0
	bne.s	T_3F8
T_3BE:
	move.l	D4,D0
	move.w	#11,D1
	asr.l	D1,D0
	beq.s	T_422
	cmpi.l	#$3F,D0
	ble.s	T_3D2
	moveq	#$3F,D0
T_3D2:
	move.w	D0,-(SP)
	move.l	D3,-(SP)
	add.l	D0,D3
	move.l	A4,-(SP)
	move.w	#11,D1
	asl.l	D1,D0
	adda.l	D0,A4
	sub.l	D0,D4
	move.w	2(A3),-(SP)
	move.w	#$33,-(SP)	;Metaread
	trap	#14
	lea	14(SP),SP
;
	tst.l	D0
	bmi.s	T_444
	bra.s	T_3BE
;
T_3F8:
	cmpi.l	#$800,D4
	blt.s	T_422
	subi.l	#$800,D4
	move.l	D3,D0
	addq.l	#1,D3
	bsr	T_B94
	tst.l	D0
	bmi.s	T_444
	lea	$63A(A3),A0
	move.w	#$7FF,D0
T_41A:
	move.b	(A0)+,(A4)+
	dbra	D0,T_41A
	bra.s	T_3F8
;
T_422:
	subq.w	#1,D4
	bmi.s	T_43A
	move.l	D3,D0
	bsr	T_B94
	tst.l	D0
	bmi.s	T_444
	lea	$63A(A3),A0
T_434:
	move.b	(A0)+,(A4)+
	dbra	D4,T_434
T_43A:
	move.l	A4,D0
	sub.l	12(SP),D0
	add.l	D0,8(A5)
T_444:
	rts
;----------------------------------------------------------------------------
dos_Fseek:
	bsr	T_CAE
	tst.l	D0
	bmi.s	T_47A
	move.l	6(SP),D0
	move.w	12(SP),D1
	bmi.s	T_47C
	beq.s	T_46C
	cmpi.w	#2,D1
	bgt.s	T_47C
	lea	4(A5),A0
	beq.s	T_46A
	lea	8(A5),A0
T_46A:
	add.l	(A0),D0
T_46C:
	cmp.l	4(A5),D0
	bgt.s	T_480
	tst.l	D0
	bmi.s	T_480
	move.l	D0,8(A5)
T_47A:
	rts
;------------------------------------
T_47C:
	moveq	#$ffFFffE0,D0
	rts
;------------------------------------
T_480:
	moveq	#$ffFFffC0,D0
	rts
;----------------------------------------------------------------------------
dos_Fattrib:
	bsr	T_CAE
	tst.l	D0
	bmi.s	T_4E0
	tst.w	10(SP)
	beq.s	T_496
	moveq	#$ffFFffDC,D0
	bra.s	T_4E0
;
T_496:
	bsr	T_896
	tst.l	D0
	bmi.s	T_4E0
	bsr	T_A0C
	tst.l	D0
	bmi.s	T_4E0
	tst.b	(A4)
	bne.s	T_4B0
	lea	$63A(A3),A0
	bra.s	T_4B8
;
T_4B0:
	bsr	T_A6C
	tst.l	D0
	bmi.s	T_4E0
T_4B8:
	move.w	opt_Read_only_f,D0
	lea	$19(A0),A1
	cmpi.b	#0,$31(A3)
	bne.s	T_4CE
	lea	$18(A0),A1
T_4CE:
	btst	#0,(A1)
	beq.s	T_4D8
	ori.w	#2,D0
T_4D8:
	btst	#1,(A1)
	beq.s	T_4E0
	moveq	#$ffFFffDF,D0
T_4E0:
	rts
;----------------------------------------------------------------------------
dos_Fsfirst:
	move.l	#-1,(A5)
	bsr	T_CAE	;!!! BUG !!! does not find mACSI drive
	tst.l	D0
	bmi.s	T_51A
	bsr	T_896
	tst.l	D0
	bmi.s	T_51A
	bsr	T_A0C
	tst.l	D0
	bmi.s	T_51A
	movea.l	A5,A0
	move.l	$24(A3),(A0)+
	move.w	$28(A3),(A0)+
	move.w	$2A(A3),(A0)+
T_50E:
	move.b	(A4)+,(A0)+
	bne.s	T_50E
	move.b	11(SP),$14(A5)
	bsr.s	T_534
T_51A:
	rts
;----------------------------------------------------------------------------
dos_Fsnext:
	bsr	T_CAE
	tst.l	D0
	bmi	T_532
	bsr.s	T_534
	cmpi.l	#-$21,D0
	bne.s	T_532
	moveq	#$ffFFffCF,D0
T_532:
	rts
;----------------------------------------------------------------------------
T_534:
	move.b	$14(A5),D3
	cmpi.b	#8,D3
	bne.s	T_544
	moveq	#$ffFFffDF,D0
	bra	T_5F6
;
T_544:
	move.b	#0,$14(A5)
	movea.l	A5,A4
	move.l	(A4)+,$24(A3)
	move.w	(A4)+,$28(A3)
	move.w	(A4)+,$2A(A3)
T_558:
	bsr	T_A6C
	tst.l	D0
	bmi	T_5F6
	moveq	#0,D0
	lea	$19(A0),A1
	cmpi.b	#0,$31(A3)
	bne.s	T_574
	lea	$18(A0),A1
T_574:
	btst	#0,(A1)
	beq.s	T_57E
	ori.w	#2,D0
T_57E:
	btst	#1,(A1)
	beq.s	T_58C
	ori.w	#$10,D0
	moveq	#0,D1
	bra.s	T_5A8
;
T_58C:
	or.w	opt_Read_only_f,D0
	move.l	14(A0),D1
	cmpi.b	#0,$22(A3)
	beq.s	T_5A8
	move.l	10(A0),D1
	ror.w	#8,D1
	swap	D1
	ror.w	#8,D1
T_5A8:
	move.l	D1,$1A(A5)
	move.w	D0,D1
	andi.w	#-$2,D1
	beq.s	T_5BA
	move.w	D3,D1
	and.b	D0,D1
	beq.s	T_558
T_5BA:
	move.b	D3,$14(A5)
	move.b	D0,$15(A5)
	lea	$16(A5),A1
	bsr	T_2D8
	move.w	B_FB4,D0
	lea	B_FA8,A2
	subq.w	#1,D0
	lea	$1E(A5),A1
T_5DC:
	move.b	(A2)+,(A1)+
	dbra	D0,T_5DC
	move.b	#0,(A1)+
	movea.l	A5,A0
	move.l	$24(A3),(A0)+
	move.w	$28(A3),(A0)+
	move.w	$2A(A3),(A0)+
	moveq	#0,D0
T_5F6:
	rts
;----------------------------------------------------------------------------
dos_Fdatime:
	bsr	T_CAE
	tst.l	D0
	bmi.s	T_60A
	movea.l	6(SP),A1
	move.l	12(A5),(A1)
	moveq	#0,D0
T_60A:
	rts
;----------------------------------------------------------------------------
T_60C:
	movem.l	D3-D4,-(SP)
	bsr	T_BE2
	move.l	#-1,$2C(A3)
	move.b	#$FF,$30(A3)
	move.b	#$FF,$23(A3)
	bsr	T_D04
	tst.l	D0
	bmi	T_780
	move.l	D0,D4
	move.b	#1,$22(A3)
	moveq	#$10,D3
T_63C:
	move.l	D3,D0
	add.l	D4,D0
	bsr	T_B94
	tst.l	D0
	bmi	T_780
	lea	$63A(A3),A0
	cmpi.b	#1,(A0)
	beq.s	T_67E
	cmpi.b	#1,8(A0)
	beq	T_6F0
	cmpi.b	#$FF,(A0)
	beq	T_786
	cmpi.b	#$FF,8(A0)
	beq	T_786
T_670:
	addq.l	#1,D3
	cmpi.l	#$1E,D3
	bgt	T_786
	bra.s	T_63C
;
T_67E:
	lea	CD001_s,A0
	lea	$63B(A3),A1
	moveq	#5,D0
	bsr	T_D3C
	beq.s	T_670
	move.b	#1,$31(A3)
T_696:
	cmpi.b	#0,$22(A3)
	beq.s	T_6D6
	move.l	$68A(A3),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
	move.l	D0,4(A3)
	move.w	$6BA(A3),D0
	ror.w	#8,D0
	move.w	D0,8(A3)
	move.l	$6C6(A3),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
	move.l	D0,14(A3)
	move.l	$6BE(A3),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
	move.l	D0,10(A3)
	bra	T_760
;
T_6D6:
	move.l	$68E(A3),4(A3)
	move.w	$6BC(A3),8(A3)
	move.l	$6CE(A3),14(A3)
	move.l	$6C2(A3),10(A3)
	bra.s	T_760
;
T_6F0:
	lea	CDROM_s,A0
	lea	$643(A3),A1
	moveq	#5,D0
	bsr	T_D3C
	beq	T_670
	move.b	#0,$31(A3)
	cmpi.b	#0,$22(A3)
	beq.s	T_748
	move.l	$692(A3),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
	move.l	D0,4(A3)
	move.w	$6C2(A3),D0
	ror.w	#8,D0
	move.w	D0,8(A3)
	move.l	$6CE(A3),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
	move.l	D0,14(A3)
	move.l	$6C6(A3),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
	move.l	D0,10(A3)
	bra.s	T_760
;
T_748:
	move.l	$696(A3),4(A3)
	move.w	$6C4(A3),8(A3)
	move.l	$6DE(A3),14(A3)
	move.l	$6CA(A3),10(A3)
T_760:
	move.b	#0,$30(A3)
	bsr.s	T_78A
	tst.l	D0
	bne.s	T_786
	bsr	T_824
	tst.l	D0
	beq.s	T_77E
	move.b	#0,$22(A3)
	bra	T_696
;
T_77E:
	moveq	#0,D0
T_780:
	movem.l	(SP)+,D3-D4
	rts
;------------------------------------
T_786:
	moveq	#$ffFFffF9,D0
	bra.s	T_780
;----------------------------------------------------------------------------
T_78A:
	tst.b	$30(A3)
	bne	T_820
	move.l	10(A3),D0
	cmpi.l	#$800,D0
	bge.s	T_7A4
	move.l	#$800,D0
T_7A4:
	cmp.l	paths_RAM_size,D0
	ble.s	T_7B2
	move.l	paths_RAM_size,D0
T_7B2:
	move.l	D0,$12(A3)
	bsr	T_882
	move.l	14(A3),D0
	cmpi.w	#$200,8(A3)
	beq.s	T_7D0
	cmpi.w	#$400,8(A3)
	beq.s	T_7D2
	bra.s	T_7D4
;
T_7D0:
	asr.l	#1,D0
T_7D2:
	asr.l	#1,D0
T_7D4:
	move.l	D0,$18(A3)
	move.w	$16(A3),-(SP)
	move.l	D0,-(SP)
	pea	$E3A(A3)
	move.w	2(A3),-(SP)
	move.w	#$33,-(SP)		;Metaread
	trap	#14
	lea	14(SP),SP
	tst.l	D0
	bne.s	T_820
	move.l	10(A3),D0
	addi.l	#$7FF,D0
	divu	#$800,D0
	sub.w	$16(A3),D0
	move.w	D0,$20(A3)
	move.l	$18(A3),D0
	add.w	$16(A3),D0
	move.l	D0,$1C(A3)
	move.b	#0,$23(A3)
	moveq	#0,D0
	rts
;------------------------------------
T_820:
	moveq	#$ffFFffFF,D0
	rts
;----------------------------------------------------------------------------
T_824:
	movem.l	D3-D4,-(SP)
	cmpi.b	#0,$22(A3)
	beq.s	T_872
	lea	$E3A(A3),A2
	moveq	#0,D2
	moveq	#1,D4
T_838:
	moveq	#0,D3
	move.b	0(A2,D2.l),D3
	cmpi.b	#0,$31(A3)
	bne.s	T_84A
	move.b	5(A2,D2.l),D3
T_84A:
	addq.w	#1,D3
	andi.w	#$FE,D3
	addq.w	#8,D3
	add.l	D2,D3
	cmp.l	$12(A3),D3
	bgt.s	T_872
	move.w	6(A2,D2.l),D0
	cmpi.b	#0,$22(A3)
	beq.s	T_868
	ror.w	#8,D0
T_868:
	cmp.w	D0,D4
	bcs.s	T_87A
	addq.w	#1,D4
	move.l	D3,D2
	bra.s	T_838
;
T_872:
	movem.l	(SP)+,D3-D4
	moveq	#0,D0
	rts
;------------------------------------
T_87A:
	movem.l	(SP)+,D3-D4
	moveq	#$ffFFffFF,D0
	rts
;----------------------------------------------------------------------------
;
T_882:
	move.l	$12(A3),D0
	addi.l	#$7FF,D0
	divu	#$800,D0
	move.w	D0,$16(A3)
	rts
;----------------------------------------------------------------------------
T_896:
	movem.l	D3-D6,-(SP)
	tst.b	$23(A3)
	beq.s	T_8AA
	bsr	T_78A
	tst.l	D0
	bmi	T_9FC
T_8AA:
	move.b	(A4)+,D0
	beq	T_9FC
	cmpi.b	#$3A,D0
	bne.s	T_8AA
	moveq	#0,D3
	lea	$E3A(A3),A2
	move.l	2(A2,D3.l),D5
	cmpi.b	#0,$31(A3)
	bne.s	T_8CC
	move.l	0(A2,D3.l),D5
T_8CC:
	cmpi.b	#0,$22(A3)
	beq.s	T_8DA
	ror.w	#8,D5
	swap	D5
	ror.w	#8,D5
T_8DA:
	moveq	#1,D2
	moveq	#1,D4
	cmpi.b	#$5C,(A4)
	bne	T_A04
	addq.l	#1,A4
	movea.l	A4,A0
T_8EA:
	move.b	(A0)+,D0
	beq	T_A04
	cmpi.b	#$5C,D0
	bne.s	T_8EA
T_8F6:
	moveq	#0,D6
	move.b	0(A2,D3.l),D6
	cmpi.b	#0,$31(A3)
	bne.s	T_908
	move.b	5(A2,D3.l),D6
T_908:
	addq.w	#1,D6
	andi.w	#$FE,D6
	addq.w	#8,D6
	add.l	D3,D6
	cmp.l	$12(A3),D6
	bgt	T_99E
	move.w	6(A2,D3.l),D0
	cmpi.b	#0,$22(A3)
	beq.s	T_928
	ror.w	#8,D0
T_928:
	cmp.w	D0,D2
	bhi.s	T_996
	bcs	T_9FC
	movea.l	A4,A0
	movea.l	A2,A1
	adda.l	D3,A1
	adda.w	#8,A1
	clr.w	D0
	move.b	0(A2,D3.l),D0
	cmpi.b	#0,$31(A3)
	bne.s	T_94C
	move.b	5(A2,D3.l),D0
T_94C:
	cmpi.w	#12,D0
	ble.s	T_954
	moveq	#12,D0
T_954:
	bsr	T_D3C
	beq.s	T_996
	move.w	D4,D2
	move.l	2(A2,D3.l),D5
	cmpi.b	#0,$31(A3)
	bne.s	T_96C
	move.l	0(A2,D3.l),D5
T_96C:
	cmpi.b	#0,$22(A3)
	beq.s	T_97A
	ror.w	#8,D5
	swap	D5
	ror.w	#8,D5
T_97A:
	move.b	(A4),D0
	beq	T_A04
	adda.w	#1,A4
	cmpi.b	#$5C,D0
	bne.s	T_97A
	movea.l	A4,A0
T_98C:
	move.b	(A0)+,D0
	beq.s	T_A04
	cmpi.b	#$5C,D0
	bne.s	T_98C
T_996:
	addq.w	#1,D4
	move.l	D6,D3
	bra	T_8F6
;------------------------------------
T_99E:
	tst.w	$20(A3)
	ble.s	T_9FC
	movea.l	A2,A0
T_9A6:
	cmp.l	$12(A3),D3
	bge.s	T_9B4
	move.w	0(A2,D3.l),(A0)+
	addq.l	#2,D3
	bra.s	T_9A6
;------------------------------------
T_9B4:
	move.b	#$FF,$23(A3)
	movem.l	D2/A2,-(SP)
	move.w	#1,-(SP)
	move.l	$1C(A3),-(SP)
	move.l	A0,-(SP)
	move.w	2(A3),-(SP)
	move.w	#$33,-(SP)		;Metaread
	suba.l	A2,A0
	adda.w	#$800,A0
	move.l	A0,$12(A3)
	trap	#14
	lea	14(SP),SP
	movem.l	(SP)+,D2/A2
	tst.l	D0
	bmi.s	T_9FC
	subi.w	#1,$20(A3)
	addi.l	#1,$1C(A3)
	clr.l	D3
	bra	T_8F6
;------------------------------------
T_9FC:
	moveq	#$ffFFffDE,D0
	movem.l	(SP)+,D3-D6
	rts
;------------------------------------
T_A04:
	move.l	D5,D0
	movem.l	(SP)+,D3-D6
	rts
;----------------------------------------------------------------------------
T_A0C:
	cmpi.w	#$200,8(A3)
	beq.s	T_A1E
	cmpi.w	#$400,8(A3)
	beq.s	T_A20
	bra.s	T_A22
;
T_A1E:
	asr.l	#1,D0
T_A20:
	asr.l	#1,D0
T_A22:
	move.l	D0,$24(A3)
	bsr	T_B94
	tst.l	D0
	bmi.s	T_A6A
	lea	$63A(A3),A0
	move.l	14(A0),D0
	cmpi.b	#0,$22(A3)
	beq.s	T_A48
	move.l	10(A0),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
T_A48:
	addi.l	#$7FF,D0
	divu	#$800,D0
	subq.w	#1,D0
	move.w	D0,$28(A3)
	moveq	#0,D0
	tst.b	(A4)
	beq.s	T_A64
	move.b	(A0),D0
	add.b	0(A0,D0.w),D0
T_A64:
	move.w	D0,$2A(A3)
	moveq	#0,D0
T_A6A:
	rts
;----------------------------------------------------------------------------
T_A6C:
	movem.l	D3-D4,-(SP)
	move.l	$24(A3),D0
	bsr	T_B94
	tst.l	D0
	bmi	T_B8E
	lea	$63A(A3),A2
	move.w	$2A(A3),D3
T_A86:
	cmpi.w	#$800,D3
	bge	T_B50
	tst.b	0(A2,D3.w)
	beq	T_B50
	clr.w	D1
	move.b	0(A2,D3.w),D1
	subi.w	#$21,D1
	bmi	T_B46
	clr.w	D0
	move.b	$20(A2,D3.w),D0
	beq	T_B46
	cmp.w	D1,D0
	bgt	T_B46
	cmpi.b	#0,$31(A3)
	beq.s	T_AC6
	btst	#2,$19(A2,D3.w)
	bne	T_B46
T_AC6:
	movea.l	A2,A1
	adda.w	D3,A1
	adda.w	#$21,A1
	lea	B_FA8,A0
	clr.l	D1
T_AD6:
	subi.w	#1,D0
	bmi.s	T_B30
	move.b	(A1)+,D2
	cmpi.b	#$3B,D2
	beq.s	T_B30
	cmpi.b	#$2E,D2
	beq.s	T_B08
	move.b	D2,(A0)+
	addq.w	#1,D1
	cmpi.w	#8,D1
	blt.s	T_AD6
T_AF4:
	subi.w	#1,D0
	bmi.s	T_B30
	move.b	(A1)+,D2
	cmpi.b	#$3B,D2
	beq.s	T_B30
	cmpi.b	#$2E,D2
	bne.s	T_AF4
T_B08:
	moveq	#$ffFFffFF,D4
	cmpi.w	#3,D0
	ble.s	T_B12
	moveq	#3,D0
T_B12:
	subq.w	#1,D0
	bmi.s	T_B30
	move.b	(A1)+,D2
	cmpi.b	#$3B,D2
	beq.s	T_B30
	tst.w	D4
	beq.s	T_B2A
	move.b	#$2E,(A0)+
	addq.w	#1,D1
	moveq	#0,D4
T_B2A:
	move.b	D2,(A0)+
	addq.w	#1,D1
	bra.s	T_B12
;
T_B30:
	move.w	D1,D0
	move.w	D1,B_FB4
	lea	B_FA8,A1
	movea.l	A4,A0
	bsr	T_D3C
	bne.s	T_B7C
T_B46:
	move.b	0(A2,D3.w),D0
	add.w	D0,D3
	bra	T_A86
;
T_B50:
	subi.w	#1,$28(A3)
	bmi.s	T_B78
	addi.l	#1,$24(A3)
	move.l	$24(A3),D0
	lea	$63A(A3),A0
	bsr.s	T_B94
	tst.l	D0
	bmi.s	T_B8E
	lea	$63A(A3),A2
	moveq	#0,D3
	bra	T_A86
;
T_B78:
	moveq	#$ffFFffDF,D0
	bra.s	T_B8E
;
T_B7C:
	movea.l	A2,A0
	adda.w	D3,A0
	moveq	#0,D0
	move.b	0(A2,D3.w),D0
	add.w	D0,D3
	move.w	D3,$2A(A3)
	moveq	#0,D0
T_B8E:
	movem.l	(SP)+,D3-D4
	rts
;----------------------------------------------------------------------------
T_B94:
	move.l	D3,-(SP)
	bsr	T_C06
	cmp.l	$2C(A3),D0
	beq.s	T_BDC
	move.l	D0,$2C(A3)
	moveq	#3,D3
	move.w	#1,-(SP)
	move.l	D0,-(SP)
	pea	$63A(A3)
	move.w	2(A3),-(SP)
	move.w	#$33,-(SP)		;Metaread
T_BB8:
	trap	#14
	tst.l	D0
	bpl.s	T_BD0
	dbra	D3,T_BB8
	move.l	#-1,$2C(A3)
	lea	14(SP),SP
	bra.s	T_BDE
;
T_BD0:
	lea	14(SP),SP
	move.l	$2C(A3),D0
	bsr	T_C58
T_BDC:
	moveq	#0,D0
T_BDE:
	move.l	(SP)+,D3
	rts
;----------------------------------------------------------------------------
T_BE2:
	lea	$3A(A3),A0
	move.l	opt_Buffers,D1
	subq.l	#1,D1
T_BEE:
	move.l	#-1,(A0)
	move.l	#0,4(A0)
	adda.w	#12,A0
	dbra	D1,T_BEE
	rts
;----------------------------------------------------------------------------
T_C06:
	lea	$3A(A3),A0
	move.l	opt_Buffers,D1
	subq.l	#1,D1
T_C12:
	addq.l	#1,4(A0)
	adda.w	#12,A0
	dbra	D1,T_C12
	move.l	(A3),D2
	lea	$3A(A3),A0
	move.l	opt_Buffers,D1
	subq.l	#1,D1
T_C2C:
	cmp.l	(A0),D0
	beq.s	T_C3A
	adda.w	#12,A0
	dbra	D1,T_C2C
	bra.s	T_C56
;
T_C3A:
	clr.l	4(A0)
	movea.l	8(A0),A0
	lea	$63A(A3),A1
	move.l	#$1FF,D1
T_C4C:
	move.l	(A0)+,(A1)+
	dbra	D1,T_C4C
	move.l	D0,$2C(A3)
T_C56:
	rts
;----------------------------------------------------------------------------
T_C58:
	lea	$3A(A3),A1
	move.l	opt_Buffers,D1
	subq.l	#1,D1
T_C64:
	tst.l	(A1)
	bmi.s	T_C92
	adda.w	#12,A1
	dbra	D1,T_C64
	lea	$3A(A3),A0
	move.l	opt_Buffers,D1
	subq.l	#1,D1
	bra.s	T_C84
;
T_C7E:
	cmp.l	4(A0),D2
	bgt.s	T_C8A
T_C84:
	movea.l	A0,A1
	move.l	4(A0),D2
T_C8A:
	adda.w	#12,A0
	dbra	D1,T_C7E
T_C92:
	move.l	D0,(A1)
	clr.l	4(A1)
	movea.l	8(A1),A0
	lea	$63A(A3),A1
	move.l	#$1FF,D1
T_CA6:
	move.l	(A1)+,(A0)+
	dbra	D1,T_CA6
	rts
;----------------------------------------------------------------------------
T_CAE:
	moveq	#8,D0
	tst.b	$30(A3)
	bne.s	T_CDA
	move.l	$32(A3),D0
	cmp.l	(_hz_200).w,D0
	blo.s	T_CC6
	move.l	$36(A3),D0
	rts
;
;
T_CC6:
	move.l	(_hz_200).w,$32(A3)
	addi.l	#400,$32(A3)
	bsr.s	T_CE6
	tst.l	D0
	bmi.s	T_CE4
T_CDA:
	btst	#3,D0
	beq.s	T_CE4
	bsr	T_60C
T_CE4:
	rts
;----------------------------------------------------------------------------
T_CE6:
	xbios	Metastatus|_ind,2(a3),#0
	tst.l	D0
	bpl.s	T_CFE
	moveq	#$ffFFffFE,D0
T_CFE:
	move.l	D0,$36(A3)
	rts
;----------------------------------------------------------------------------
;This routine fails to find mACSI drive (seemed to accept ICD though)
;
T_D04:
	move.l	D3,-(SP)
	moveq	#3,D3
T_D08:
	move.l	#0,-(SP)
	move.w	2(A3),-(SP)
	move.w	#$38,-(SP)	;Metafunc 8 is undocumented !!!
	trap	#14
	addq.l	#8,SP
	tst.l	D0
	bpl.s	T_D38
	cmpi.l	#-15,D0
	beq.s	T_D38
	cmpi.l	#-3,D0
	beq.s	T_D36
	dbra	D3,T_D08
	moveq	#$ffFFffFE,D0
	bra.s	T_D38
;
T_D36:
	moveq	#0,D0
T_D38:
	move.l	(SP)+,D3
	rts
;----------------------------------------------------------------------------
T_D3C:
	subq.w	#1,D0
	bmi.s	T_D72
	move.b	(A0),D1
	beq.s	T_D96
	cmpi.b	#$5C,D1
	beq.s	T_D96
	cmpi.b	#$2A,D1
	bne.s	T_D62
	addq.l	#1,A1
	cmpi.b	#$2E,(A1)
	bne.s	T_D3C
	cmpi.w	#1,D0
	ble.s	T_D3C
	addq.l	#1,A0
	bra.s	T_D3C
;
T_D62:
	cmpi.b	#$3F,D1
	beq.s	T_D6C
	cmp.b	(A1),D1
	bne.s	T_D96
T_D6C:
	addq.l	#1,A0
	addq.l	#1,A1
	bra.s	T_D3C
;
T_D72:
	move.b	(A0),D1
	beq.s	T_D92
	cmpi.b	#$5C,D1
	beq.s	T_D92
	cmpi.b	#$2A,D1
	beq.s	T_D8E
	cmpi.b	#$3F,D1
	beq.s	T_D8E
	cmpi.b	#$2E,D1
	bne.s	T_D96
T_D8E:
	addq.l	#1,A0
	bra.s	T_D72
;
T_D92:
	moveq	#$ffFFffFF,D0
	rts
;----------------------------------------------------------------------------
T_D96:
	moveq	#0,D0
	rts
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
init_DOS_func_t_p:
	dc.l	init_DOS_func
;
	dcb.l	54,-1	;00..35
	dc.l	dos_Dfree		;36 Dfree
	dcb.l	2,-1	;37..38
	dc.l	dos_E_ACCDN		;39 Dcreate
	dc.l	dos_E_ACCDN		;3A Ddelete
	dc.l	dos_Dsetpath		;3B Dsetpath
	dc.l	dos_E_ACCDN		;3C Fcreate
	dc.l	dos_Fopen		;3D Fopen
	dc.l	dos_Fclose		;3E Fclose
	dc.l	dos_Fread		;3F Fread
	dc.l	dos_E_ACCDN		;40 Fwrite
	dc.l	dos_E_ACCDN		;41 Fdelete
	dc.l	dos_Fseek		;42 Fseek
	dc.l	dos_Fattrib		;43 Fattrib
	dcb.l	10,-1	;44..4D
	dc.l	dos_Fsfirst		;4E Fsfirst
	dc.l	dos_Fsnext		;4F Fsnext
	dcb.l	6,-1	;50..55
	dc.l	dos_E_ACCDN		;56 Frename
	dc.l	dos_Fdatime		;57 Fdatime
;
CD001_s:
	dc.b	'CD001',NUL
CDROM_s:
	dc.b	'CDROM',NUL
driver_name_s:
	dc.b	'ISO9660/High Sierra Driver v2.1',NUL,NUL
copyright_s:
	dc.b	CR,LF
	dc.b	'Copyright ½ 1993-1995 Roger Burrows',CR,LF
	dc.b	'All rights reserved.',CR,LF,NUL
invalid_option_s:
	dc.b	'Invalid option: using default ',NUL
option_B_EQ_4_s:
	dc.b	'B=4',CR,LF,NUL
option_P_EQ_4_s:
	dc.b	'P=4',CR,LF,NUL
option_R_W_s:
	dc.b	'R/W',CR,LF,NUL
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
opt_Paths:		ds.l	1
paths_RAM_size:		ds.l	1
opt_Buffers:		ds.l	1
opt_Read_only_f:	ds.w	1
B_FA8:	ds.l	3
B_FB4:	ds.w	1
B_FB6:	ds.l	64			;=256
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	UNIDRIVE.S
;----------------------------------------------------------------------------
