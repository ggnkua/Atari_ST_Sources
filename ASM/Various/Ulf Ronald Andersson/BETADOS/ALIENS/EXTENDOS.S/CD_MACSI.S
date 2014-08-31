;----------------------------------------------------------------------------
;File name:	CD_mACSI.S			Revision date:	1995.07.05
;Revised by:	Ulf ROnald Andersson		Revision start:	1995.07.04
;----------------------------------------------------------------------------
;Desert	Drain V1.41   68000er Disassembler  04.07.1995 03:56:10
;DATEI:	CD.BOS	 15904 Bytes
;TEXT:	10368	$02880
;DATA:	 4528	$011B0
;BSS:	 2594  $000A22
;----------------------------------------------------------------------------
;
	output	.BOS
;
;----------------------------------------------------------------------------
;
MAX_BOS_ENTRIES	= 8	;original value was 8
;
;----------------------------------------------------------------------------
;
	include	URAn_DOS.S
	include	Meta_Def.S
;
;----------------------------------------------------------------------------
;
;	 Step by step instructions for Atari ST DMA usage (non_FDC).
;	 -----------------------------------------------------------
;
;	 1: Normalize (hw_dmacont) for non_FDC use by setting it to $8A.
;
;	 2: Load DMA Base Address Registers  (low byte first, top byte last).
;
;	 3: Toggle Write/_Read using (hw_dmacont) bit_8 to clear status.
;
;	 4: Select DMA read or write (hw_dmacont) bit_8 = Wr/_Rd.
;
;	 5: Select DMA Sector Count Register (hw_dmacont) bit_4 = 1.
;
;	 6: Write the sector count byte to (hw_dmadata).
;
;	At this point system is ready for transfer, but this must be
;	controlled by external hardware, as a response to a command.
;
;	 7: Set external Register mode (hw_dmacont) bit_4 = 0,
;	    and command mode (hw_dmacont) bit_1 = 0.
;
;	 8: Write a command byte to (hw_dmadata) with ID in top 3 bits.
;
;	 9: Set data mode (hw_dmacont) bit_1 = 1.
;
;	10: Write eache parameter byte of the command to (hw_dmadata),
;	    after which it is up to the external drive to start the dma
;	    transfers by asserting DRQ. Timeout recovery is recommended !
;
;	11: After last command byte select controller (hw_dmacont).
;
;	12: DMA active until sector count is zero, do not poll (hw_dmastat)
;           during DMA active.  Instead poll bit 5 of (hw_gpip) until zero.
;
;	13: Check DMA error status (hw_dmastat) (nondestructive).
;
;	14: Check HDC status byte and if necessary perform ECC correction
;	    following a Verify Track or Read Sector command.
;
;----------------------------------------------------------------------------
;
	SECTION	TEXT
;
;----------------------------------------------------------------------------
;
start:
	movem.l	D2-D4/A4,-(SP)
	movea.l	D0,A4
	gemdos	Cconws,bos_name_ver_s
	gemdos	Cconws,copyright_s
	bsr	check_options
	bsr	check_cookies
	move.w	machine_type,D0
	cmpi.w	#4,D0			;Future machine ?
	ble.s	T_3C
	moveq	#$FFFFFFE1,D0
	bra	T_98
;
T_3C:	lea	machine_flags_t,A0
	move.b	0(A0,D0.w),machine_f
	move.l	max_trace,D0
	beq.s	T_88
	move.l	#$26,D1
	add.l	D_3A2C,D1
	mulu	D1,D0
	gemdos	Malloc,d0
	tst.l	D0
	bne.s	T_72
	moveq	#$FFFFFFD9,D0
	bra.s	T_98
;
T_72:	move.l	D0,D_3A20
	move.l	D0,D_3A24
	add.l	-$4(SP),D0
	move.l	D0,D_3A28
T_88:	move.l	#BOS_table_beg,BOS_table_p
	move.l	#BOS_init_p,D0
T_98:	movem.l	(SP)+,D2-D4/A4
	rts
;
;----------------------------------------------------------------------------
;
check_options:
	lea	$80(A4),A4
	moveq	#0,D4
	move.b	(A4)+,D4
	beq	T_178
T_AA:	cmpi.b	#'T',(A4)
	beq.s	T_C0
	cmpi.b	#'D',(A4)
	beq.s	T_F4
	cmpi.b	#'L',(A4)
	beq.s	T_124
	bra	T_170
;
T_C0:	move.l	#0,max_trace
	bsr	eval_option
	tst.l	D1
	bmi.s	T_EC
	cmpi.l	#0,D1
	blt.s	T_EC
	cmpi.l	#$400,D1
	bgt.s	T_EC
	move.l	D1,max_trace
	bra	T_170
;
T_EC:	pea	option_T_EQ_0_s
	bra.s	T_15A
;
T_F4:	move.l	#-1,D_3A18
	bsr.s	eval_option
	tst.l	D1
	bmi.s	T_11C
	cmpi.l	#0,D1
	blt.s	T_11C
	cmpi.l	#$FE,D1
	bgt.s	T_11C
	move.l	D1,D_3A18
	bra.s	T_170
;
T_11C:	pea	option_D_omitted_s
	bra.s	T_15A
;
T_124:	move.l	#$10,D_3A2C
	bsr.s	eval_option
	tst.l	D1
	bmi.s	T_154
	cmpi.l	#$10,D1
	blt.s	T_154
	cmpi.l	#$80,D1
	bgt.s	T_154
	addq.l	#1,D1
	andi.l	#-2,D1
	move.l	D1,D_3A2C
	bra.s	T_170
;
T_154:	pea	option_L_EQ_16_s
T_15A:	gemdos	Cconws,invalid_option_s
	gemdos	Cconws,()
T_170:	addq.l	#1,A4
	subq.w	#1,D4
	bpl	T_AA
T_178:	rts
;
;----------------------------------------------------------------------------
;
eval_option:
	cmpi.w	#3,D4
	blt.s	T_1B8
	cmpi.b	#$3D,1(A4)
	bne.s	T_1B8
	addq.l	#2,A4
	subq.w	#2,D4
	moveq	#0,D1
T_18E:	moveq	#0,D3
	move.b	(A4),D3
	cmpi.b	#$20,D3
	beq.s	T_1B6
	subi.b	#$30,D3
	bmi.s	T_1B8
	cmpi.b	#9,D3
	bgt.s	T_1B8
	move.l	D1,D2
	asl.l	#2,D2
	add.l	D1,D2
	asl.l	#1,D2
	add.l	D2,D3
	move.l	D3,D1
	addq.l	#1,A4
	subq.l	#1,D4
	bne.s	T_18E
T_1B6:	rts
;
;----------------------------------------------------------------------------
;
T_1B8:	moveq	#-1,D1
	rts
;
;----------------------------------------------------------------------------
;
check_cookies:
	clr.w	new_cpu_f
	clr.l	fastram_buf_p
	move.l	(_cookies).w,D0
	beq.s	T_218
	movea.l	D0,A0		;a0 -> cookie jar
T_1D0:	tst.l	(A0)		;finished ?
	beq.s	T_218
	cmpi.l	#'_CPU',(A0)
	bne.s	T_1F0
	cmpi.l	#20,4(A0)	;CPU older than 68020 ?
	blt.s	T_212
	move.w	#1,new_cpu_f
	bra.s	T_212
;
T_1F0:	cmpi.l	#'_FRB',(A0)
	bne.s	T_202
	move.l	4(A0),fastram_buf_p
	bra.s	T_212
;
T_202:	cmpi.l	#'_MCH',(A0)
	bne.s	T_212
	move.w	4(A0),machine_type
T_212:	adda.w	#8,A0
	bra.s	T_1D0
;
T_218:	rts
;
;----------------------------------------------------------------------------
;Sub:	'BOS_init' is called by EXTENDOS to init each drive
;Entry:	d1 low byte	=  (LUN<<4 + ID)  of the drive to init
;  "	d0 word		=  physical drive letter  (non_gemdos)
;Exit:	d0 -> drive control block, unless negative error code
;
BOS_init:
	tst.l	BOS_table_p
	beq.s	.T_230
	move.l	D0,-(SP)	;push physical drive letter
	bsr.s	BOS_init_sub
	move.l	(SP)+,D3	;d3 = physical drive letter, pulled
	tst.l	D0
	bmi.s	.T_22E
	bsr.s	BOS_init_sub_2
.T_22E:
	rts
;
.T_230:	moveq	#$FFFFFFE3,D0
	rts
;
;----------------------------------------------------------------------------
;
BOS_init_sub_2:
	movea.l	BOS_table_p,A1
	movea.l	A1,A0			;a0 = a1 -> BOS table structure
	moveq	#15-1,D4
T_23E:	clr.l	(A1)+			;clear 60 bytes
	dbra	D4,T_23E
	move.l	#max_trace,bos_max_trace(A0)
	move.w	D_3A1A,bos_IF_2(A0)	;always -1
	move.l	D0,bos_func_t_p(A0)
	move.w	D1,bos_xCSI_LUN_ID(a0)
	move.b	D2,bos_SCSI_ACSI(A0)	;1 for SCSI on ACSI, else 0
	move.w	D3,bos_drive(A0)	;store drive letter
	lea	bos_name_ver_s,A1
	lea	bos_title_s(A0),A2
T_26E:	move.b	(A1)+,(A2)+
	bne.s	T_26E
	addi.l	#60,BOS_table_p		;reserve 60 bytes per BOS table
	move.l	#BOS_table_end,D1
	cmp.l	BOS_table_p,D1
	bgt.s	T_290		;table area full ?
	clr.l	BOS_table_p	;clear ptr => error at next init_BOS_FUNC
T_290:	move.l	A0,D0
	rts
;
;----------------------------------------------------------------------------
;
BOS_init_sub:
	move.w	D1,-(SP)	;push LUN.ID  (both in low byte)
	btst	#7,D1		;LUN > 7 ?
	bne	T_358		;go return error if LUN > 7
	btst	#3,D1		;ID > 7 ?
	bne	T_326		;go use SCSI I/F if ID > 7
;Here the requested ID is for ACSI I/F
	btst	#2,machine_f	;is machine a Falcon ?
	bne	T_326		;if Falcon go use SCSI I/F
;NB: the next test is redundant, since only Falcon lacks ACSI interface
	btst	#0,machine_f	;has machine ACSI interface
	beq	T_35C		;if no ACSI go return error
	move.w	D1,D0		;d0 =  LUN.ID
	moveq	#$10,D1		;prep d1 for 16 byte Inquiry
	bsr	cmd_dma_Inquiry
	cmpi.b	#$FF,D0
	beq	T_360
	btst	#1,D0
	bne	T_360
	bsr	T_368
	tst.l	D0
	beq.s	..use_CDAR_504
	move.w	(SP),D0		;d0 byte = LUN.ID
	moveq	#$20,D1		;prep d1 for 32 byte Inquiry
	bsr	cmd_dma_Inquiry
	cmpi.b	#$FF,D0
	beq	T_360
	btst	#1,D0
	bne	T_360
	lea	B_3C5A,A0
	tst.l	(A0)
	beq.s	T_364
	bsr	show_bos_device
	bsr	find_cdtype	;=> d0 -> func_t of found cdtype
	moveq	#1,D2		;d2 = 1 for SCSI on ACSI I/F
	bra.s	.T_31E
;
..use_CDAR_504:
	lea	Atari_CDAR_504_s,A0
	bsr	show_bos_device
	move.l	#func_t_ATARI_CDAR_504,D0
	moveq	#0,D2		;d2 = 0 for non_SCSI on ACSI I/F
.T_31E:	move.b	#'A',(SP)	;ACSI
	move.w	(SP)+,D1	;d1 =('A' for ACSI I/F)<<8 + LUN<<4 + ID
	rts
;
;
T_326:	andi.w	#$FFF7,D1
	move.w	D1,(SP)
	btst	#1,machine_f
	beq.s	T_35C
	move.w	D1,D0
	move.w	#$20,D1
	bsr	T_1BA6
	tst.l	D0
	bmi.s	T_360
	lea	B_3C5A,A0
	bsr.s	show_bos_device
	bsr.s	find_cdtype
	moveq	#0,D2		;d2 = 0 for SCSI on SCSI I/F
	move.b	#'S',(SP)	;SCSI
T_354:	move.w	(SP)+,D1	;d1 =('S' for SCSI I/F)<<8 + LUN<<4 + ID
	rts
;
;
T_358:	moveq	#$FFFFFFE4,D0
	bra.s	T_354
;
T_35C:	moveq	#$FFFFFFE2,D0
	bra.s	T_354
;
T_360:	moveq	#-2,D0
	bra.s	T_354
;
T_364:	moveq	#$FFFFFFE5,D0
	bra.s	T_354
;
;----------------------------------------------------------------------------
;
T_368:
	lea	CD_ROM_s,A0
	lea	B_3C57,A1
	moveq	#5,D0
T_376:	cmpm.b	(A0)+,(A1)+
	bne.s	T_382
	dbra	D0,T_376
	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
T_382:	moveq	#-1,D0
	rts
;
;----------------------------------------------------------------------------
;
show_bos_device:
	moveq	#8-1,D0
	lea	drive_name_head_s,A1
T_38E:	move.b	(A0)+,(A1)+
	dbra	D0,T_38E
	moveq	#16-1,D0
	lea	drive_name_tail_s,A1
T_39C:	move.b	(A0)+,(A1)+
	dbra	D0,T_39C
	pea	device_is_s
	move.w	#9,-(SP)
	trap	#1			;Cconws
	addq.l	#6,SP
	rts
;
;----------------------------------------------------------------------------
;Sub:	'find_cdtype'
;Exit:	d0 -> func_t of found cdtype
;
find_cdtype:
	lea	cdtype_link_t,A0	;a0 -> link table
.link_loop:
	movea.l	0(A0),A1		;a1 -> name of current link
	lea	B_3C5A,A2
	cmpi.b	#$FF,(A1)		;is 1'st byte $FF ?  (strangetype 2)
	beq.s	.strangetype_2		;jump if strangetype 2
	move.l	D_3A18,D0
	bmi.s	.compare_name
	cmp.b	(A1),D0
	beq.s	.found_link
	bra.s	.link_next
;
.compare_name:
	addq.l	#1,A1
.compare_loop:
	move.b	(A1)+,D0
	beq.s	.found_link
	cmp.b	(A2)+,D0
	beq.s	.compare_loop
.link_next:
	lea	8(A0),A0
	bra.s	.link_loop
;
.strangetype_2:
	move.l	D_3A18,D0
	bpl.s	.found_link
	move.b	B_3C54,D0
	andi.b	#7,D0
	cmpi.b	#2,D0
	blt.s	.found_link
	move.l	#2,D_3A18
	bra.s	find_cdtype
;
.found_link:
	move.l	4(A0),D0	;d0 ->func_t_... for identified cdtype
	rts
;
;----------------------------------------------------------------------------
;
gen_Metaopen:
	movea.l	4(SP),A1
	lea	bos_title_s(A0),A0
	move.l	A0,(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	move.l	#max_trace,(A1)
	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
gen_Metaclose:
	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
gen_Metaread:
	btst	#3,$13(A0)
	bne.s	T_472
	move.l	A0,B_3C46
	tst.b	bos_SCSI_ACSI(A0)
	bne.s	T_446
	bsr	T_1BEA
	bra.s	T_44A
;
T_446:	bsr	T_1CC8
T_44A:	cmpi.b	#$FF,D0
	beq.s	T_46E
	btst	#3,D0
	bne.s	T_46E
	btst	#1,D0
	beq.s	T_47A
	movea.l	B_3C46,A0
	bsr	T_1AFE
	cmpi.l	#-$12,D0
	bne.s	T_47A
T_46E:	moveq	#-2,D0
	bra.s	T_47A
;
T_472:	bclr	#3,$13(A0)
	moveq	#-$0E,D0
T_47A:	rts
;
;----------------------------------------------------------------------------
;
CDAR_Metaread:
	btst	#3,$13(A0)
	bne.s	T_4A8
	move.l	A0,B_3C46
	bsr	T_24FC
	cmpi.b	#$FF,D0
	beq.s	T_4A2
	btst	#1,D0
	bne.s	T_4A2
	btst	#2,D0
	bne.s	T_4A2
	rts
;
;----------------------------------------------------------------------------
;
T_4A2:	bsr	T_2480
	rts
;
;----------------------------------------------------------------------------
;
T_4A8:	bclr	#3,$13(A0)
	moveq	#-14,D0
	rts
;
;----------------------------------------------------------------------------
;
gen_Metafunc_5:
	btst	#3,$13(A0)
	bne.s	T_500
	move.l	A0,B_3C46
	tst.b	bos_SCSI_ACSI(A0)
	bne.s	T_4CC
	bsr	T_1C7E
	bra.s	T_4D0
;
T_4CC:	bsr	T_1DA6
T_4D0:	cmpi.b	#$FF,D0
	beq.s	T_4F4
	btst	#3,D0
	bne.s	T_4F8
	btst	#1,D0
	beq.s	T_508
	movea.l	B_3C46,A0
	bsr	T_1AFE
	cmpi.l	#-$12,D0
	bne.s	T_508
T_4F4:	moveq	#-2,D0
	bra.s	T_508
;
T_4F8:	move.l	#-$7FFC,D0
	bra.s	T_508
;
T_500:	bclr	#3,$13(A0)
	moveq	#-14,D0
T_508:	rts
;
;----------------------------------------------------------------------------
;
gen_Metastatus:
	move.l	A0,B_3C46
	tst.b	bos_SCSI_ACSI(A0)
	bne.s	T_51C
	bsr	T_1BC6
	bra.s	T_520
;
T_51C:	bsr	T_1CA6
T_520:	cmpi.b	#$FF,D0
	beq.s	T_53C
	andi.l	#15,D0
	beq.s	T_562
	btst	#3,D0
	bne.s	T_544
	btst	#1,D0
	bne.s	T_554
	bra.s	T_54C
;
T_53C:	move.l	#-$7F80,D0
	rts
;
;----------------------------------------------------------------------------
;
T_544:	move.l	#-$7FFC,D0
	bra.s	T_564
;
T_54C:	move.l	#-$7FFE,D0
	bra.s	T_564
;
T_554:	movea.l	B_3C46,A0
	bsr	T_1AFE
	bsr	T_2792
T_562:	moveq	#0,D0
T_564:	movea.l	B_3C46,A0
	or.b	$13(A0),D0
	rts
;
;----------------------------------------------------------------------------
;
CDAR_Metastatus:
	move.l	A0,B_3C46
	bsr	T_24DA
	cmpi.b	#$FF,D0
	beq.s	T_5B4
	andi.l	#15,D0
	beq.s	T_5A8
	btst	#1,D0
	bne.s	T_5A2
	btst	#2,D0
	bne.s	T_5A2
	btst	#3,D0
	beq.s	T_5A8
	bsr	T_2792
	moveq	#0,D0
	bra.s	T_5A8
;
T_5A2:	ori.l	#-$8000,D0
T_5A8:	movea.l	B_3C46,A0
	or.b	$13(A0),D0
	rts
;
;----------------------------------------------------------------------------
;
T_5B4:	move.l	#-$7F80,D0
	rts
;
;----------------------------------------------------------------------------
;
gen_E_INVFN_1:
	moveq	#E_INVFN,D0
	rts
;
;----------------------------------------------------------------------------
;Start of:	SCSI functions
;----------------------------------------------------------------------------
;
fctl_Pause:
	bsr	prepare_SCSI
	move.b	#$4B,(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
NEC_div_Pause:
	bsr	prepare_SCSI
	move.b	#$DA,(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_Pause:
	bsr	prepare_SCSI
	move.b	#$CA,(A1)
	move.b	#$10,1(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
XM_3201_Pause:
	bsr	prepare_SCSI
	move.b	#$C2,(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
fctl_Resume:
	bsr	prepare_SCSI
	move.b	#$4B,(A1)
	move.b	#1,8(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
NEC_div_Resume:
	bsr	prepare_SCSI
	move.b	#$D9,(A1)
	move.b	#4,1(A1)
	move.b	#$C0,9(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_Resume:
	bsr	prepare_SCSI
	move.b	#$CA,(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
XM_3201_Resume:
	bsr	prepare_SCSI
	move.b	#$C1,(A1)
	move.b	#4,1(A1)
	move.b	#$C0,9(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
fctl_PlayMSF:
	bsr	prepare_SCSI
	move.b	#$47,(A1)
	movea.l	10(SP),A2
	lea	3(A1),A3
	moveq	#5,D2
T_676:	move.b	(A2)+,(A3)+
	dbra	D2,T_676
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
NEC_g1_PlayMSF:
	bsr	prepare_SCSI
	move.b	#$47,(A1)
	movea.l	10(SP),A2
	lea	3(A1),A3
	moveq	#5,D2
T_696:	move.b	(A2)+,(A3)+
	dbra	D2,T_696
	subq.b	#1,-(A3)	;This 'subq' masks bug in NEC group 1
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
NEC_div_PlayMSF:
	bsr	prepare_SCSI
	move.b	#$D8,(A1)
	movea.l	10(SP),A2
	move.l	(A2),D0
	lsr.l	#8,D0
	bsr	T_19E2
	subi.l	#$96,D0
	move.l	D0,2(A1)
	moveq	#10,D2
	bsr	T_1586
	tst.l	D0
	bmi.s	T_700
	bsr	reprep_SCSI
	move.b	#$D9,(A1)
	move.b	#3,1(A1)
	movea.l	10(SP),A2
	move.l	2(A2),D0
	andi.l	#$FFFFFF,D0
	bsr	T_19E2
	subi.l	#$97,D0
	move.l	D0,2(A1)
	moveq	#10,D2
	bsr	T_1586
T_700:	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_PlayMSF:
	bsr	prepare_SCSI
	move.b	#$C9,(A1)
	move.b	#$19,1(A1)
	movea.l	10(SP),A2
	move.l	2(A2),D0
	andi.l	#$FFFFFF,D0
	bsr	T_1A14
	move.l	D0,2(A1)
	move.b	#$40,9(A1)
	moveq	#10,D2
	bsr	T_1586
	tst.l	D0
	bmi.s	T_760
	bsr	reprep_SCSI
	move.b	#$C8,(A1)
	move.b	#$19,1(A1)
	movea.l	10(SP),A2
	move.l	(A2),D0
	lsr.l	#8,D0
	bsr	T_1A14
	move.l	D0,2(A1)
	move.b	#$40,9(A1)
	moveq	#10,D2
	bsr	T_1586
T_760:	rts
;
;----------------------------------------------------------------------------
;
XM_3201_PlayMSF:
	bsr	prepare_SCSI
	move.b	#$C0,(A1)
	movea.l	10(SP),A2
	move.l	(A2),D0
	lsr.l	#8,D0
	bsr	T_19E2
	subi.l	#$96,D0
	move.l	D0,2(A1)
	moveq	#10,D2
	bsr	T_1586
	tst.l	D0
	bmi.s	T_7BA
	bsr	reprep_SCSI
	move.b	#$C1,(A1)
	move.b	#3,1(A1)
	movea.l	10(SP),A2
	move.l	2(A2),D0
	andi.l	#$FFFFFF,D0
	bsr	T_19E2
	subi.l	#$96,D0
	move.l	D0,2(A1)
	moveq	#10,D2
	bsr	T_1586
T_7BA:	rts
;
;----------------------------------------------------------------------------
;
fctl_PlayTrkInd:
	bsr	prepare_SCSI
	move.b	#$48,(A1)
	movea.l	10(SP),A2
	move.b	(A2)+,4(A1)
	move.b	(A2)+,5(A1)
	move.b	(A2)+,7(A1)
	move.b	(A2),8(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
CHINON_PlayTrkInd:
	bsr	prepare_SCSI
	move.b	#$48,(A1)
	movea.l	10(SP),A2
	move.b	(A2)+,D0
	bsr	T_1AE0
	move.b	D0,4(A1)
	move.b	(A2)+,D0
	bsr	T_1AE0
	move.b	D0,5(A1)
	move.b	(A2)+,D0
	bsr	T_1AE0
	move.b	D0,7(A1)
	move.b	(A2),D0
	bsr	T_1AE0
	move.b	D0,8(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
NEC_g1_PlayTrkInd:
	bsr	prepare_SCSI
	move.b	#$48,(A1)
	movea.l	10(SP),A2
	move.b	(A2),4(A1)
	move.b	#1,5(A1)
	move.b	2(A2),7(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
NEC_div_PlayTrkInd:
	bsr	prepare_SCSI
	move.b	#$DE,(A1)
	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_8B6
	moveq	#0,D6
	move.b	B_3C53,D6
	bsr	reprep_SCSI
	move.b	#$D8,(A1)
	movea.l	10(SP),A2
	move.b	(A2),D0
	bsr	T_1AE0
	move.b	D0,2(A1)
	move.b	#$80,9(A1)
	moveq	#10,D2
	bsr	T_1586
	tst.l	D0
	bmi.s	T_8B6
	bsr	reprep_SCSI
	move.b	#$D9,(A1)
	move.b	#3,1(A1)
	movea.l	10(SP),A2
	move.b	2(A2),D0
	addi.b	#1,D0
	bsr	T_1AE0
	cmp.w	D6,D0
	ble.s	T_8A6
	moveq	#0,D0
T_8A6:	move.b	D0,2(A1)
	move.b	#$80,9(A1)
	moveq	#10,D2
	bsr	T_1586
T_8B6:	rts
;
;----------------------------------------------------------------------------
;
SONY_PlayTrkInd:
	bsr	prepare_SCSI
	move.b	#$48,(A1)
	movea.l	10(SP),A2
	move.b	(A2),4(A1)
	move.b	#1,5(A1)	;force index0 to 1
	move.b	2(A2),7(A1)
	move.b	#1,8(A1)	;force indexN to 1
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_PlayTrkInd:
	move.b	#$48,(A1)
	movea.l	10(SP),A2
	move.b	(A2)+,D0
	bsr	T_1AE0
	move.b	D0,4(A1)
	move.b	(A2)+,D0
	bsr	T_1AE0
	move.b	D0,5(A1)
	move.b	(A2)+,D0
	bsr	T_1AE0
	move.b	D0,7(A1)
	move.b	(A2),D0
	bsr	T_1AE0
	move.b	D0,8(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
XM_3201_PlayTrkInd:
	bsr	prepare_SCSI
	move.b	#$C7,(A1)
	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_990
	moveq	#0,D6
	move.b	B_3C53,D6
	bsr	reprep_SCSI
	move.b	#$C0,(A1)
	movea.l	10(SP),A2
	move.b	(A2),D0
	bsr	T_1AE0
	move.b	D0,2(A1)
	move.b	#$80,9(A1)
	moveq	#10,D2
	bsr	T_1586
	tst.l	D0
	bmi.s	T_990
	bsr	reprep_SCSI
	move.b	#$C1,(A1)
	move.b	#3,1(A1)
	movea.l	10(SP),A2
	move.b	2(A2),D0
	addi.b	#1,D0
	bsr	T_1AE0
	cmp.w	D6,D0
	ble.s	T_980
	moveq	#0,D0
T_980:	move.b	D0,2(A1)
	move.b	#$80,9(A1)
	moveq	#10,D2
	bsr	T_1586
T_990:	rts
;
;----------------------------------------------------------------------------
;
fctl_ReadTocHdr:
	bsr	prepare_SCSI
	move.b	#$43,(A1)
	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_9BC
	movea.l	10(SP),A2
	lea	B_3C54,A3
	move.b	(A3)+,(A2)+
	move.b	(A3),(A2)
	moveq	#0,D0
T_9BC:	rts
;
;----------------------------------------------------------------------------
;
CDS_535_ReadTocHdr:
	bsr	prepare_SCSI
	move.b	#$43,(A1)
	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_9F4
	movea.l	10(SP),A2
	lea	B_3C54,A3
	move.b	(A3)+,D0
	bsr	T_1AB8
	move.b	D0,(A2)+
	move.b	(A3),D0
	bsr	T_1AB8
	move.b	D0,(A2)
	moveq	#0,D0
T_9F4:	rts
;
;----------------------------------------------------------------------------
;
CDS_435_ReadTocHdr:
	bsr	prepare_SCSI
	move.b	#$43,(A1)
	move.b	#2,1(A1)
	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_A32
	movea.l	10(SP),A2
	lea	B_3C54,A3
	move.b	(A3)+,D0
	bsr	T_1AB8
	move.b	D0,(A2)+
	move.b	(A3),D0
	bsr	T_1AB8
	move.b	D0,(A2)
	moveq	#0,D0
T_A32:	rts
;
;----------------------------------------------------------------------------
;
NEC_div_ReadTocHdr:
	bsr	prepare_SCSI
	move.b	#$DE,(A1)
	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_A94
	cmpi.w	#$199,CD_sector_buf
	bne.s	T_A78
	bsr	reprep_SCSI
	move.b	#$DE,(A1)
	move.b	#1,1(A1)
	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_A94
	move.l	CD_sector_buf,D0
	bne.s	T_A78
	moveq	#-2,D0
	bra.s	T_A94
;
T_A78:	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	(A3)+,D0
	bsr	T_1AB8
	move.b	D0,(A2)+
	move.b	(A3),D0
	bsr	T_1AB8
	move.b	D0,(A2)
	moveq	#0,D0
T_A94:	rts
;
;----------------------------------------------------------------------------
;
div_1_ReadTocHdr:
	bsr	prepare_SCSI
	move.b	#$43,(A1)
	move.b	#$AA,6(A1)
	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_AC6
	movea.l	10(SP),A2
	lea	B_3C54,A3
	move.b	(A3)+,(A2)+
	move.b	(A3),(A2)
	moveq	#0,D0
T_AC6:	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_ReadTocHdr:
	bsr	prepare_SCSI
	move.b	#$C1,(A1)
	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_AFE
	movea.l	10(SP),A2
	lea	B_3C54,A3
	move.b	(A3)+,D0
	bsr	T_1AB8
	move.b	D0,(A2)+
	move.b	(A3),D0
	bsr	T_1AB8
	move.b	D0,(A2)
	moveq	#0,D0
T_AFE:	rts
;
;----------------------------------------------------------------------------
;
XM_3201_ReadTocHdr:
	bsr	prepare_SCSI
	move.b	#$C7,(A1)
	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_B30
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	(A3)+,D0
	bsr	T_1AB8
	move.b	D0,(A2)+
	move.b	(A3),D0
	bsr	T_1AB8
	move.b	D0,(A2)
	moveq	#0,D0
T_B30:	rts
;
;----------------------------------------------------------------------------
;
fctl_ReadTocEntry:
	bsr	prepare_SCSI
	move.b	#$43,(A1)
	movea.l	10(SP),A2
	move.b	(A2),6(A1)
	cmpi.b	#1,1(A2)
	beq.s	T_B50
	move.b	#2,1(A1)
T_B50:	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_B80
	movea.l	10(SP),A2
	lea	B_3C56,A3
	move.b	1(A3),2(A2)
	move.b	#0,3(A2)
	move.l	4(A3),4(A2)
	moveq	#0,D0
T_B80:	rts
;
;----------------------------------------------------------------------------
;
CDS_535_ReadTocEntry:
	bsr	prepare_SCSI
	move.b	#$43,(A1)
	movea.l	10(SP),A2
	move.b	(A2),D0
	cmpi.b	#$AA,D0
	beq.s	T_B9A
	bsr	T_1AE0
T_B9A:	move.b	D0,6(A1)
	cmpi.b	#1,1(A2)
	beq.s	T_BAC
	move.b	#2,1(A1)
T_BAC:	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_BDC
	movea.l	10(SP),A2
	lea	B_3C56,A3
	move.b	1(A3),2(A2)
	move.b	#0,3(A2)
	move.l	4(A3),4(A2)
	moveq	#0,D0
T_BDC:	rts
;
;----------------------------------------------------------------------------
;
CDS_435_ReadTocEntry:
	bsr	prepare_SCSI
	move.b	#$43,(A1)
	movea.l	10(SP),A2
	move.b	(A2),D0
	cmpi.b	#$AA,D0
	beq.s	T_BF6
	bsr	T_1AE0
T_BF6:	move.b	D0,6(A1)
	move.b	#2,1(A1)
	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_C3E
	movea.l	10(SP),A2
	lea	B_3C56,A3
	move.b	1(A3),2(A2)
	move.b	#0,3(A2)
	move.l	4(A3),D0
	cmpi.b	#1,1(A2)
	bne.s	T_C38
	bsr	T_19E2
T_C38:	move.l	D0,4(A2)
	moveq	#0,D0
T_C3E:	rts
;
;----------------------------------------------------------------------------
;
NEC_div_ReadTocEntry:
	bsr	prepare_SCSI
	move.b	#$DE,(A1)
	movea.l	10(SP),A2
	move.b	#1,1(A1)
	cmpi.b	#$AA,(A2)
	beq.s	T_C68
	move.b	#2,1(A1)
	move.b	(A2),D0
	bsr	T_1AE0
	move.b	D0,2(A1)
T_C68:	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_C9C
	movea.l	10(SP),A2
	move.w	#0,2(A2)
	move.l	CD_sector_buf,D0
	lsr.l	#8,D0
	bsr	T_1A60
	cmpi.b	#1,1(A2)
	bne.s	T_C96
	bsr	T_19E2
T_C96:	move.l	D0,4(A2)
	moveq	#0,D0
T_C9C:	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_ReadTocEntry:
	bsr	prepare_SCSI
	move.b	#$C1,(A1)
	move.b	#$40,9(A1)
	movea.l	10(SP),A2
	move.b	(A2),D0
	cmpi.b	#$AA,D0
	beq.s	T_CC6
	move.b	#$80,9(A1)
	bsr	T_1AE0
	move.b	D0,5(A1)
T_CC6:	move.b	#4,8(A1)
	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_D16
	movea.l	10(SP),A2
	move.w	#0,2(A2)
	move.l	CD_sector_buf,D0
	cmpi.b	#$AA,(A2)
	bne.s	T_CF2
	lsr.l	#8,D0
	bra.s	T_D00
;
T_CF2:	move.b	CD_sector_buf,2(A2)
	andi.l	#$FFFFFF,D0
T_D00:	bsr	T_1A60
	cmpi.b	#1,1(A2)
	bne.s	T_D10
	bsr	T_19E2
T_D10:	move.l	D0,4(A2)
	moveq	#0,D0
T_D16:	rts
;
;----------------------------------------------------------------------------
;
XM_3201_ReadTocEntry:
	bsr	prepare_SCSI
	move.b	#$C7,(A1)
	movea.l	10(SP),A2
	move.b	#1,1(A1)
	cmpi.b	#$AA,(A2)
	beq.s	T_D40
	move.b	#2,1(A1)
	move.b	(A2),D0
	bsr	T_1AE0
	move.b	D0,2(A1)
T_D40:	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_D74
	movea.l	10(SP),A2
	move.w	#0,2(A2)
	move.l	CD_sector_buf,D0
	lsr.l	#8,D0
	bsr	T_1A60
	cmpi.b	#1,1(A2)
	bne.s	T_D6E
	bsr	T_19E2
T_D6E:	move.l	D0,4(A2)
	moveq	#0,D0
T_D74:	rts
;
;----------------------------------------------------------------------------
;
fctl_CDRomStop:
	bsr	prepare_SCSI
	move.b	#$1B,(A1)
	move.b	#1,1(A1)
	moveq	#6,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
CDS_435_CDRomStop:
	bsr	prepare_SCSI
	move.b	#$C6,(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
fctl_CDRomStart:
	bsr	prepare_SCSI
	move.b	#$1B,(A1)
	move.b	#1,1(A1)
	move.b	#1,4(A1)
	moveq	#6,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
fctl_CDRomEject:
	bsr	prepare_SCSI
	move.b	#$1B,(A1)
	move.b	#1,1(A1)
	move.b	#2,4(A1)
	moveq	#6,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
CDS_435_CDRomEject:
	bsr	prepare_SCSI
	move.b	#$C0,(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
NEC_div_CDRomEject:
	bsr	prepare_SCSI
	move.b	#$DC,(A1)
	move.b	#1,1(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
XM_3201_CDRomEject:
	bsr	prepare_SCSI
	move.b	#$C4,(A1)
	move.b	#1,1(A1)
	moveq	#10,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
fctl_VolCtrl:
	bsr	prepare_SCSI
	move.b	#$15,(A1)
	move.b	#$10,1(A1)
	move.b	#$14,4(A1)
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.l	#0,(A3)+
	move.l	#$E0E0400,(A3)+
	move.l	#0,(A3)+
	move.b	#1,(A3)+
	move.b	(A2)+,(A3)+
	move.b	#2,(A3)+
	move.b	(A2),(A3)+
	move.l	#0,(A3)
	moveq	#$14,D1
	moveq	#6,D2
	bsr	T_1650
	rts
;
;----------------------------------------------------------------------------
;
fctl_E_OK_1:
	moveq	#E_OK,D0
	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_VolCtrl:
	bsr	prepare_SCSI
	move.b	#$15,(A1)
	move.b	#$14,4(A1)
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.l	#0,(A3)+
	move.l	#$90E0400,(A3)+
	move.l	#0,(A3)+
	move.b	#1,(A3)+
	move.b	(A2)+,(A3)+
	move.b	#2,(A3)+
	move.b	(A2),(A3)+
	move.l	#0,(A3)
	moveq	#$14,D1
	moveq	#6,D2
	bsr	T_1650
	rts
;
;----------------------------------------------------------------------------
;
fctl_SubChnl:
	bsr	prepare_SCSI
	move.b	#$42,(A1)
	movea.l	10(SP),A2
	cmpi.b	#1,(A2)
	beq.s	T_EBE
	move.b	#2,1(A1)
T_EBE:	move.b	#$40,2(A1)
	move.b	#1,3(A1)
	move.b	#$10,8(A1)
	moveq	#$10,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_EFA
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	1(A3),1(A2)
	addq.l	#5,A3
	addq.l	#3,A2
	move.b	(A3)+,(A2)+
	move.w	(A3)+,(A2)+
	move.l	(A3)+,(A2)+
	move.l	(A3),(A2)
	moveq	#0,D0
T_EFA:	rts
;
;----------------------------------------------------------------------------
;
CHINON_SubChnl:
	bsr	prepare_SCSI
	move.b	#$42,(A1)
	movea.l	10(SP),A2
	cmpi.b	#1,(A2)
	beq.s	T_F14
	move.b	#2,1(A1)
T_F14:	move.b	#$40,2(A1)
	move.b	#$30,8(A1)
	moveq	#$30,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_F4A
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	1(A3),1(A2)
	addq.l	#5,A3
	addq.l	#3,A2
	move.b	(A3)+,(A2)+
	move.w	(A3)+,(A2)+
	move.l	(A3)+,(A2)+
	move.l	(A3),(A2)
	moveq	#0,D0
T_F4A:	rts
;
;----------------------------------------------------------------------------
;
CDS_535_SubChnl:
	bsr	prepare_SCSI
	move.b	#$42,(A1)
	movea.l	10(SP),A2
	cmpi.b	#1,(A2)
	beq.s	T_F64
	move.b	#2,1(A1)
T_F64:	move.b	#$40,2(A1)
	move.b	#$30,8(A1)
	moveq	#$30,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_FA2
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	1(A3),1(A2)
	addq.l	#5,A3
	addq.l	#3,A2
	move.b	(A3)+,(A2)+
	moveq	#0,D0
	move.w	(A3)+,D0
	bsr	T_1A60
	move.w	D0,(A2)+
	move.l	(A3)+,(A2)+
	move.l	(A3),(A2)
	moveq	#0,D0
T_FA2:	rts
;
;----------------------------------------------------------------------------
;
CDS_435_SubChnl:
	bsr	prepare_SCSI
	move.b	#$42,(A1)
	move.b	#2,1(A1)
	move.b	#$40,2(A1)
	move.b	#$30,8(A1)
	moveq	#$30,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_100A
	movea.l	10(SP),A2
	move.b	(A2),D1
	lea	CD_sector_buf,A3
	move.b	1(A3),1(A2)
	addq.l	#5,A3
	addq.l	#3,A2
	move.b	(A3)+,(A2)+
	moveq	#0,D0
	move.w	(A3)+,D0
	bsr	T_1A60
	move.w	D0,(A2)+
	move.l	(A3)+,D0
	cmpi.b	#1,D1
	bne.s	T_FF8
	bsr	T_19E2
T_FF8:	move.l	D0,(A2)+
	move.l	(A3),D0
	cmpi.b	#1,D1
	bne.s	T_1006
	bsr	T_19E2
T_1006:	move.l	D0,(A2)
	moveq	#0,D0
T_100A:	rts
;
;----------------------------------------------------------------------------
;
NEC_div_SubChnl:
	bsr	prepare_SCSI
	move.b	#$DD,(A1)
	move.b	#10,1(A1)
	moveq	#10,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi	T_10AC
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	lea	D_39C6,A0
	moveq	#0,D0
	move.l	D0,2(A2)
	move.l	D0,6(A2)
	move.l	D0,10(A2)
	move.b	(A3),D0
	andi.b	#3,D0
	move.b	0(A0,D0.w),1(A2)
	cmpi.b	#3,D0
	beq.s	T_10AA
	move.b	1(A3),3(A2)
	move.b	2(A3),D0
	bsr	T_1AB8
	move.b	D0,4(A2)
	move.b	3(A3),D0
	bsr	T_1AB8
	move.b	D0,5(A2)
	move.l	4(A3),D0
	lsr.l	#8,D0
	bsr	T_1A60
	cmpi.b	#1,(A2)
	bne.s	T_108A
	bsr	T_19E2
T_108A:	move.l	D0,10(A2)
	move.l	6(A3),D0
	andi.l	#$FFFFFF,D0
	bsr	T_1A60
	cmpi.b	#1,(A2)
	bne.s	T_10A6
	bsr	T_19E2
T_10A6:	move.l	D0,6(A2)
T_10AA:	moveq	#0,D0
T_10AC:	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_SubChnl:
	bsr	prepare_SCSI
	bsr.s	T_1112
	tst.l	D0
	bmi.s	T_1110
	move.b	D0,1(A2)
	bsr	reprep_SCSI
	move.b	#$C2,(A1)
	move.b	#12,8(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_1110
	movea.l	10(SP),A2
	addq.l	#4,A2
	lea	B_3C53,A3
	move.b	(A3)+,D0
	bsr	T_1AB8
	move.b	D0,(A2)+
	move.b	(A3),D0
	bsr	T_1AB8
	move.b	D0,(A2)+
	move.l	(A3),D0
	andi.l	#$FFFFFF,D0
	bsr	T_1A60
	move.l	D0,4(A2)
	move.l	4(A3),D0
	lsr.l	#8,D0
	bsr	T_1A60
	move.l	D0,(A2)
	moveq	#0,D0
T_1110:	rts
;
;----------------------------------------------------------------------------
;
T_1112:	move.b	#$CC,(A1)
	move.b	#6,8(A1)
	moveq	#6,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_1140
	lea	CD_sector_buf,A3
	lea	D_39CA,A0
	moveq	#0,D0
	move.b	(A3),D0
	andi.b	#7,D0
	move.b	0(A0,D0.w),D0
T_1140:	rts
;
;----------------------------------------------------------------------------
;
XM_3201_SubChnl:
	bsr	prepare_SCSI
	move.b	#$C6,(A1)
	move.b	#10,1(A1)
	moveq	#10,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi	T_11E2
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	lea	D_39C6,A0
	moveq	#0,D0
	move.l	D0,2(A2)
	move.l	D0,6(A2)
	move.l	D0,10(A2)
	move.b	(A3),D0
	andi.b	#3,D0
	move.b	0(A0,D0.w),1(A2)
	cmpi.b	#3,D0
	beq.s	T_11E0
	move.b	1(A3),3(A2)
	move.b	2(A3),D0
	bsr	T_1AB8
	move.b	D0,4(A2)
	move.b	3(A3),D0
	bsr	T_1AB8
	move.b	D0,5(A2)
	move.l	4(A3),D0
	lsr.l	#8,D0
	bsr	T_1A60
	cmpi.b	#1,(A2)
	bne.s	T_11C0
	bsr	T_19E2
T_11C0:	move.l	D0,10(A2)
	move.l	6(A3),D0
	andi.l	#$FFFFFF,D0
	bsr	T_1A60
	cmpi.b	#1,(A2)
	bne.s	T_11DC
	bsr	T_19E2
T_11DC:	move.l	D0,6(A2)
T_11E0:	moveq	#0,D0
T_11E2:	rts
;
;----------------------------------------------------------------------------
;
fctl_PreventRemoval:
	bsr	prepare_SCSI
	move.b	#$1E,(A1)
	move.b	#1,4(A1)
	moveq	#6,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
fctl_AllowRemoval:
	bsr	prepare_SCSI
	move.b	#$1E,(A1)
	moveq	#6,D2
	bsr	T_1586
	rts
;
;----------------------------------------------------------------------------
;
fctl_AudioCtrl:
	bsr	prepare_SCSI
	movea.l	10(SP),A2
	tst.w	(A2)
	bne.s	T_1246
	move.b	#$1A,(A1)
	move.b	#14,2(A1)
	move.b	#$1C,4(A1)
	moveq	#$1C,D1
	moveq	#6,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_1244
	movea.l	10(SP),A2
	addq.l	#2,A2
	lea	B_3C66,A3
	move.l	(A3)+,(A2)+
	move.l	(A3),(A2)
	moveq	#0,D0
T_1244:	rts
;
;----------------------------------------------------------------------------
;
T_1246:	move.b	#$15,(A1)
	move.b	#$10,1(A1)
	move.b	#$14,4(A1)
	addq.l	#2,A2
	lea	CD_sector_buf,A3
	move.l	#0,(A3)+
	move.l	#$E0E0400,(A3)+
	move.l	#0,(A3)+
	move.l	(A2)+,(A3)+
	move.l	(A2),(A3)
	moveq	#$14,D1
	moveq	#6,D2
	bsr	T_1650
	rts
;
;----------------------------------------------------------------------------
;
NEC_div_AudioCtrl:
	movea.l	10(SP),A2
	tst.w	(A2)
	bne.s	T_1296
	move.l	#$1FF02FF,2(A2)
	move.l	#0,6(A2)
T_1296:	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_AudioCtrl:
	bsr	prepare_SCSI
	movea.l	10(SP),A2
	tst.w	(A2)
	bne.s	T_12D6
	move.b	#$1A,(A1)
	move.b	#9,2(A1)
	move.b	#$1C,4(A1)
	moveq	#$1C,D1
	moveq	#6,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_12D4
	movea.l	10(SP),A2
	addq.l	#2,A2
	lea	B_3C66,A3
	move.l	(A3)+,(A2)+
	move.l	(A3),(A2)
	moveq	#0,D0
T_12D4:	rts
;
;----------------------------------------------------------------------------
;
T_12D6:	move.b	#$15,(A1)
	move.b	#$14,4(A1)
	addq.l	#2,A2
	lea	CD_sector_buf,A3
	move.l	#0,(A3)+
	move.l	#$90E0400,(A3)+
	move.l	#0,(A3)+
	move.l	(A2)+,(A3)+
	move.l	(A2),(A3)
	moveq	#$14,D1
	moveq	#6,D2
	bsr	T_1650
	rts
;
;----------------------------------------------------------------------------
;
fctl_GetMcn:
	bsr	prepare_SCSI
	move.b	#$42,(A1)
	move.b	#$40,2(A1)
	move.b	#2,3(A1)
	move.b	#$18,8(A1)
	moveq	#$18,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_134A
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	1(A3),(A2)+
	lea	9(A3),A3
	moveq	#14,D2
T_1342:	move.b	(A3)+,(A2)+
	dbra	D2,T_1342
	moveq	#0,D0
T_134A:	rts
;
;----------------------------------------------------------------------------
;
CHINON_GetMcn:
	bsr	prepare_SCSI
	move.b	#$42,(A1)
	move.b	#2,1(A1)
	move.b	#$40,2(A1)
	move.b	#$30,8(A1)
	moveq	#$30,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_138E
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	1(A3),(A2)+
	lea	$11(A3),A3
	moveq	#14,D2
T_1386:	move.b	(A3)+,(A2)+
	dbra	D2,T_1386
	moveq	#0,D0
T_138E:	rts
;
;----------------------------------------------------------------------------
;
NEC_div_GetMcn:
	bsr	prepare_SCSI
	move.b	#$DD,(A1)
	move.b	#10,1(A1)
	moveq	#10,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_13D2
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	lea	D_39C6,A0
	moveq	#0,D0
	move.b	(A3),D0
	andi.b	#3,D0
	move.b	0(A0,D0.w),(A2)+
	moveq	#14,D2
T_13C8:	move.b	#0,(A2)+
	dbra	D2,T_13C8
	moveq	#0,D0
T_13D2:	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_GetMcn:
	bsr	prepare_SCSI
	bsr	T_1112
	tst.l	D0
	bmi.s	T_13F2
	movea.l	10(SP),A2
	move.b	D0,(A2)+
	moveq	#14,D2
T_13E8:	move.b	#0,(A2)+
	dbra	D2,T_13E8
	moveq	#0,D0
T_13F2:	rts
;
;----------------------------------------------------------------------------
;
XM_3201_GetMcn:
	bsr	prepare_SCSI
	move.b	#$C6,(A1)
	move.b	#10,1(A1)
	moveq	#10,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_1436
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	lea	D_39C6,A0
	moveq	#0,D0
	move.b	(A3),D0
	andi.b	#3,D0
	move.b	0(A0,D0.w),(A2)+
	moveq	#14,D2
T_142C:	move.b	#0,(A2)+
	dbra	D2,T_142C
	moveq	#0,D0
T_1436:	rts
;
;----------------------------------------------------------------------------
;
fctl_GetTisrc:
	bsr	prepare_SCSI
	move.b	#$42,(A1)
	move.b	#$40,2(A1)
	move.b	#3,3(A1)
	movea.l	10(SP),A2
	move.b	(A2),6(A1)
	move.b	#$18,8(A1)
	moveq	#$18,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_1486
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	1(A3),1(A2)
	lea	9(A3),A3
	addq.l	#2,A2
	moveq	#14,D2
T_147E:	move.b	(A3)+,(A2)+
	dbra	D2,T_147E
	moveq	#0,D0
T_1486:	rts
;
;----------------------------------------------------------------------------
;
CHINON_GetTisrc:
	bsr	prepare_SCSI
	move.b	#$42,(A1)
	move.b	#2,1(A1)
	move.b	#$40,2(A1)
	move.b	#$30,8(A1)
	moveq	#$30,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_14CE
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	move.b	1(A3),1(A2)
	lea	$21(A3),A3
	addq.l	#2,A2
	moveq	#14,D2
T_14C6:	move.b	(A3)+,(A2)+
	dbra	D2,T_14C6
	moveq	#0,D0
T_14CE:	rts
;
;----------------------------------------------------------------------------
;
NEC_div_GetTisrc:
	bsr	prepare_SCSI
	move.b	#$DD,(A1)
	move.b	#10,1(A1)
	moveq	#10,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_1516
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	lea	D_39C6,A0
	moveq	#0,D0
	move.b	(A3),D0
	andi.b	#3,D0
	move.b	0(A0,D0.w),1(A2)
	addq.l	#2,A2
	moveq	#14,D2
T_150C:	move.b	#0,(A2)+
	dbra	D2,T_150C
	moveq	#0,D0
T_1516:	rts
;
;----------------------------------------------------------------------------
;
CDU_8002_GetTisrc:
	bsr	prepare_SCSI
	bsr	T_1112
	tst.l	D0
	bmi.s	T_1538
	movea.l	10(SP),A2
	move.b	D0,(A2)+
	addq.l	#2,A2
	moveq	#14,D2
T_152E:	move.b	#0,(A2)+
	dbra	D2,T_152E
	moveq	#0,D0
T_1538:	rts
;
;----------------------------------------------------------------------------
;
XM_3201_GetTisrc:
	bsr	prepare_SCSI
	move.b	#$C6,(A1)
	move.b	#10,1(A1)
	moveq	#10,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_1580
	movea.l	10(SP),A2
	lea	CD_sector_buf,A3
	lea	D_39C6,A0
	moveq	#0,D0
	move.b	(A3),D0
	andi.b	#3,D0
	move.b	0(A0,D0.w),1(A2)
	addq.l	#2,A2
	moveq	#14,D2
T_1576:	move.b	#0,(A2)+
	dbra	D2,T_1576
	moveq	#0,D0
T_1580:	rts
;
;----------------------------------------------------------------------------
;
fctl_E_INVFN_1:
	moveq	#E_INVFN,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1586:	lea	CD_sector_buf,A2
	move.l	#2001,D3		;set future timeouts to 10s
	swap	D3
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#0,D1
	tst.b	bos_SCSI_ACSI(A0)	;1 for SCSI drive on ACSI I/F, else 0
	bne.s	.use_SCSI_on_ACSI
	bsr	T_1DCC
	bra.s	T_15AA
;
.use_SCSI_on_ACSI:
	bsr	cmd_dma_Read_Write
T_15AA:	cmpi.b	#$FF,D0
	beq.s	T_15DC
	btst	#3,D0
	bne.s	T_15D4
	btst	#1,D0
	beq.s	T_15D2
	movea.l	B_3C46,A0
	bsr	T_1AFE
	cmpi.l	#-14,D0
	bne.s	T_15D2
	bsr	T_2792
T_15D2:	rts
;
T_15D4:	move.l	#-$7FFC,D0
	rts
;
T_15DC:	moveq	#-2,D0
	rts
;
;----------------------------------------------------------------------------
;
T_15E0:	lea	CD_sector_buf,A2
	move.l	#$7D1,D3
	swap	D3
	move.w	bos_xCSI_LUN_ID(a0),D0
	tst.b	bos_SCSI_ACSI(A0)
	bne.s	T_15FE
	bsr	T_1E20
	bra.s	T_161A
;
T_15FE:	move.w	D1,D3
	andi.w	#15,D3
	beq.s	T_1616
	move.w	#$100,D3
	cmpi.l	#8,D1
	bge.s	T_1616
	move.w	#$300,D3
T_1616:	bsr	cmd_dma_Read_Write
T_161A:	cmpi.b	#$FF,D0
	beq.s	T_164C
	btst	#3,D0
	bne.s	T_1644
	btst	#1,D0
	beq.s	T_1642
	movea.l	B_3C46,A0
	bsr	T_1AFE
	cmpi.l	#-14,D0
	bne.s	T_1642
	bsr	T_2792
T_1642:	rts
;
;----------------------------------------------------------------------------
;
T_1644:	move.l	#-$7FFC,D0
	rts
;
;----------------------------------------------------------------------------
;
T_164C:	moveq	#-2,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1650:	lea	CD_sector_buf,A2
	move.l	#$7D1,D3
	swap	D3
	move.w	#1,D3
	move.w	bos_xCSI_LUN_ID(a0),D0
	tst.b	bos_SCSI_ACSI(A0)
	bne.s	T_1672
	bsr	T_1E20
	bra.s	T_1676
;
T_1672:	bsr	cmd_dma_Read_Write
T_1676:	cmpi.b	#$FF,D0
	beq.s	T_16A8
	btst	#3,D0
	bne.s	T_16A0
	btst	#1,D0
	beq.s	T_169E
	movea.l	B_3C46,A0
	bsr	T_1AFE
	cmpi.l	#-14,D0
	bne.s	T_169E
	bsr	T_2792
T_169E:	rts
;
;----------------------------------------------------------------------------
;
T_16A0:	move.l	#-$7FFC,D0
	rts
;
;----------------------------------------------------------------------------
;
T_16A8:	moveq	#-2,D0
	rts
;
;----------------------------------------------------------------------------
;
prepare_SCSI:	move.l	A0,B_3C46
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	rts
;
;----------------------------------------------------------------------------
;
reprep_SCSI:	movea.l	B_3C46,A0
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	rts
;
;----------------------------------------------------------------------------
;
fctl_E_INVFN_2:
	moveq	#E_INVFN,D0
	rts
;
;----------------------------------------------------------------------------
;
gen_E_OK_1:
	moveq	#E_OK,D0
	rts
;
;----------------------------------------------------------------------------
;
dummy_Metafunc_8:
	clr.l	d0
	rts
;
;----------------------------------------------------------------------------
;
CHINON_Metafunc_8:
	move.l	A0,B_3C46
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$26,(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_16FE
	move.l	CD_sector_buf,D0
T_16FE:	rts
;
;----------------------------------------------------------------------------
;
NEC_Metafunc_8:
	move.l	A0,B_3C46
	bsr.s	T_174A
	tst.l	D0
	bmi.s	T_1718
	cmpi.b	#$20,D0
	beq.s	T_1716
	moveq	#0,D0
	rts
;
;
T_1716:	bsr.s	T_1780
T_1718:	rts
;
;----------------------------------------------------------------------------
;
NEC_g2_Metafunc_8:
	move.l	A0,B_3C46
	bsr.s	T_174A
	tst.l	D0
	bmi.s	T_1748
	cmpi.b	#$20,D0
	beq.s	T_173A
	moveq	#0,D0
	bsr	T_17BE
	tst.l	D0
	bmi.s	T_1748
	moveq	#0,D0
	rts
;
;
T_173A:	move.l	#-$40000000,D0
	bsr.s	T_17BE
	tst.l	D0
	bmi.s	T_1748
	bsr.s	T_1780
T_1748:	rts
;
;----------------------------------------------------------------------------
;
T_174A:	movea.l	B_3C46,A0
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$DE,(A1)
	move.b	#3,1(A1)
	move.b	#$A0,2(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_177E
	moveq	#0,D0
	move.b	B_3C5C,D0
T_177E:	rts
;
;----------------------------------------------------------------------------
;
T_1780:	movea.l	B_3C46,A0
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$DE,(A1)
	move.b	#3,1(A1)
	move.b	#$B0,2(A1)
	moveq	#$16,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_17BC
	move.l	B_3C60,D0
	beq.s	T_17BC
	bsr	T_1A60
	bsr	T_19E2
T_17BC:	rts
;
;----------------------------------------------------------------------------
;
T_17BE:	movea.l	B_3C46,A0
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$15,(A1)
	move.b	#10,4(A1)
	lea	CD_sector_buf,A2
	move.l	#0,(A2)
	move.l	D0,4(A2)
	move.w	#15,8(A2)
	moveq	#10,D1
	moveq	#6,D2
	bsr	T_1650
	rts
;
;----------------------------------------------------------------------------
;
COMMON_Metafunc_8:
	move.l	A0,B_3C46
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$43,(A1)
	move.b	#12,8(A1)
	move.b	#$40,9(A1)
	moveq	#12,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_182A
	move.l	B_3C5A,D0
T_182A:	rts
;
;----------------------------------------------------------------------------
;
TOSHIBA_g1_Metafunc_8:
	move.l	A0,B_3C46
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$15,(A1)
	move.b	#12,4(A1)
	lea	CD_sector_buf,A2
	move.l	#8,(A2)
	move.l	#-$7D000000,4(A2)
	move.l	#$800,8(A2)
	moveq	#12,D1
	moveq	#6,D2
	bsr	T_1650
	tst.l	D0
	bmi.s	T_18BA
	movea.l	B_3C46,A0
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$C7,(A1)
	move.b	#3,1(A1)
	moveq	#4,D1
	moveq	#10,D2
	bsr	T_15E0
	tst.l	D0
	bmi.s	T_18BA
	moveq	#0,D0
	lea	CD_sector_buf,A2
	cmpi.b	#$20,(A2)
	bne.s	T_18BA
	move.l	(A2),D0
	andi.l	#$FFFFFF,D0
	beq.s	T_18BA
	bsr	T_1A60
	bsr	T_19E2
	subi.l	#$96,D0
T_18BA:	rts
;
;----------------------------------------------------------------------------
;
XM_3301_Metafunc_8:
	move.l	A0,B_3C46
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$15,(A1)
	move.b	#12,4(A1)
	lea	CD_sector_buf,A2
	move.l	#8,(A2)
	move.l	#-$7D000000,4(A2)
	move.l	#$800,8(A2)
	moveq	#12,D1
	moveq	#6,D2
	bsr	T_1650
	tst.l	D0
	bmi.s	T_1900
	moveq	#0,D0
T_1900:	rts
;
;----------------------------------------------------------------------------
;
CDAR_E_OK_1:
	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
gen_Metafunc_9:
	bclr	#3,$13(A0)
	move.l	A0,B_3C46
	move.w	bos_xCSI_LUN_ID(a0),D0
	move.l	4(SP),D3
	move.l	8(SP),D2
	movea.l	12(SP),A1
	move.l	$10(SP),D1
	movea.l	$14(SP),A2
	tst.b	bos_SCSI_ACSI(A0)
	bne.s	T_1940
	tst.l	D1
	beq.s	T_193A
	bsr	T_1E20
	bra.s	T_1944
;
T_193A:	bsr	T_1DCC
	bra.s	T_1944
;
T_1940:	bsr	cmd_dma_Read_Write
T_1944:	cmpi.b	#$FF,D0
	beq.s	T_1960
	andi.l	#15,D0
	beq.s	T_197E
	btst	#3,D0
	bne.s	T_1970
	btst	#1,D0
	bne.s	T_1968
	bra.s	T_1978
;
T_1960:	move.l	#-$7F80,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1968:	move.l	#-$7FF0,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1970:	move.l	#-$7FFC,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1978:	move.l	#-$7FFE,D0
T_197E:	rts
;
;----------------------------------------------------------------------------
;
CDAR_Metafunc_9:
	bclr	#3,$13(A0)
	move.l	A0,B_3C46
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#0,D3
	move.l	4(SP),D3
	move.l	8(SP),D2
	movea.l	12(SP),A1
	move.l	$10(SP),D1
	movea.l	$14(SP),A2
	bsr	cmd_dma_Read_Write
	cmpi.b	#$FF,D0
	beq.s	T_19C6
	andi.l	#15,D0
	beq.s	T_19D6
	btst	#1,D0
	bne.s	T_19CE
	btst	#2,D0
	bne.s	T_19CE
	bra.s	T_19D6
;
T_19C6:	move.l	#-$7F80,D0
	rts
;
;----------------------------------------------------------------------------
;
T_19CE:	move.l	#-$7FF0,D0
	rts
;
;----------------------------------------------------------------------------
;
T_19D6:	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
gen_E_UNCMD_1:
	moveq	#E_UNCMD,D0
	rts
;
;----------------------------------------------------------------------------
;
gen_E_UNCMD_2:
	moveq	#E_UNCMD,D0
	rts
;
;----------------------------------------------------------------------------
;NB:	in remarks below, entry values are referred to as e_d0,e_d1 etc...
;
T_19E2:
	move.l	D1,-(SP)
	move.l	D0,-(SP)
	moveq	#0,D0
	move.b	1(SP),D0	;d0 = byte 2 of e_d0
	move.l	D0,D1		;d1 = byte 2 of e_d0
	asl.l	#4,D0
	sub.l	D1,D0
	asl.l	#2,D0		;d0 = (byte 2 of e_d0)*60
	move.b	2(SP),D1	;d1 = byte 1 of e_d0 
	add.l	D1,D0
	move.l	D0,D1		;d1 = d0 = byte_2*60+byte_1
	asl.l	#2,D0
	add.l	D1,D0
	move.l	D0,D1		;d1 = d0 = (byte_2*60+byte_1)*5
	asl.l	#4,D0
	sub.l	D1,D0		;d0 = (byte_2*60+byte_1)*75
	moveq	#0,D1
	move.b	3(SP),D1	;d0 = (byte_2*60+byte_1)*75+byte_0
	add.l	D1,D0
	addq.w	#4,SP
	move.l	(SP)+,D1
	rts
;
;----------------------------------------------------------------------------
;
T_1A14:	move.l	D1,-(SP)
	move.l	D0,-(SP)
	moveq	#0,D0
	move.b	1(SP),D0
	divu	#10,D0
	move.b	D0,D1
	asl.b	#4,D1
	swap	D0
	or.b	D0,D1
	move.b	D1,1(SP)
	moveq	#0,D0
	move.b	2(SP),D0
	divu	#10,D0
	move.b	D0,D1
	asl.b	#4,D1
	swap	D0
	or.b	D0,D1
	move.b	D1,2(SP)
	moveq	#0,D0
	move.b	3(SP),D0
	divu	#10,D0
	move.b	D0,D1
	asl.b	#4,D1
	swap	D0
	or.b	D0,D1
	move.b	D1,3(SP)
	move.l	(SP)+,D0
	move.l	(SP)+,D1
	rts
;
;----------------------------------------------------------------------------
;NB:	in remarks below, entry values are referred to as e_d0,e_d1 etc...
;
T_1A60:	movem.l	D1-D3,-(SP)
	move.l	D0,D2
	swap	D0
	swap	D2		;d2 = d0 = high word of e_d0
	andi.b	#$F0,D0
	lsr.b	#1,D0
	move.w	D0,D1		;d1 = d0 = ((byte 2 of e_d0) & 0xF0)/2
	lsr.b	#2,D0		;d0 = ((byte 2 of e_d0) & 0xF0)/8
	add.b	D1,D0		;d0 = 5*((byte 2 of e_d0) & 0xF0)/8
	andi.b	#$0F,D2		;d2 = (byte 2 of e_d0) & 0x0F
	add.b	D2,D0
	swap	D0
	swap	D2
	andi.b	#$F0,D0
	lsr.b	#1,D0
	move.w	D0,D1
	lsr.b	#2,D0
	add.b	D1,D0
	andi.b	#$0F,D2
	add.b	D2,D0
	lsr.w	#8,D2		;d2 = byte 3 of e_d0
	move.b	D2,D3
	andi.b	#$0F,D3
	andi.b	#$F0,D2
	lsr.b	#1,D2
	move.b	D2,D1
	lsr.b	#2,D2
	add.b	D2,D1
	add.b	D3,D1
	lsl.w	#8,D1
	andi.l	#$FF00FF,D0
	or.w	D1,D0
	movem.l	(SP)+,D1-D3
	rts
;
;----------------------------------------------------------------------------
;
T_1AB8:	move.l	D1,-(SP)
	andi.l	#$FF,D0
	move.l	D0,D1
	swap	D1
	move.w	D0,D1
	andi.b	#$F0,D1
	lsr.b	#1,D1
	andi.b	#$F0,D0
	lsr.b	#3,D0
	add.b	D1,D0
	swap	D1
	andi.b	#15,D1
	add.b	D1,D0
	move.l	(SP)+,D1
	rts
;
;----------------------------------------------------------------------------
;
T_1AE0:	move.l	D1,-(SP)
	andi.l	#$FF,D0
	divu	#10,D0
	move.w	D0,D1
	asl.w	#4,D1
	swap	D0
	or.w	D1,D0
	andi.l	#$FFFF,D0
	move.l	(SP)+,D1
	rts
;
;----------------------------------------------------------------------------
;
T_1AFE:	tst.b	bos_SCSI_ACSI(A0)
	bne.s	T_1B0A
	bsr	T_1C56
	bra.s	T_1B0E
;
T_1B0A:	bsr	T_1D78
T_1B0E:	cmpi.b	#$FF,D0
	beq.s	T_1B8E
	lea	CD_sector_buf,A2
	move.b	(A2),D0
	andi.b	#$7E,D0
	cmpi.b	#$70,D0
	bne.s	T_1B9E
	move.b	2(A2),D0
	cmpi.b	#2,D0
	beq.s	T_1B8E
	cmpi.b	#3,D0
	beq.s	T_1B8E
	cmpi.b	#4,D0
	beq.s	T_1B9A
	cmpi.b	#5,D0
	beq.s	T_1B92
	cmpi.b	#6,D0
	beq.s	T_1B9E
	move.b	12(A2),D0
	beq.s	T_1B9E
	cmpi.b	#4,D0
	beq.s	T_1B8E
	cmpi.b	#$3A,D0
	beq.s	T_1BA2
	cmpi.b	#9,D0
	beq.s	T_1B9A
	cmpi.b	#$47,D0
	beq.s	T_1B9A
	cmpi.b	#$26,D0
	beq.s	T_1B92
	cmpi.b	#$2A,D0
	beq.s	T_1B92
	cmpi.b	#$28,D0
	beq.s	T_1B9E
	cmpi.b	#$29,D0
	beq.s	T_1B9E
	cmpi.b	#$20,D0
	beq.s	T_1B96
	cmpi.b	#$64,D0
	beq.s	T_1B96
	moveq	#-1,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1B8E:	moveq	#-2,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1B92:	moveq	#-5,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1B96:	moveq	#-7,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1B9A:	moveq	#-12,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1B9E:	moveq	#-14,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1BA2:	moveq	#-18,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1BA6:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$12,(A1)
	move.b	D1,4(A1)
	moveq	#6,D2
	lea	CD_sector_buf,A2
	bsr	T_1E1A
	rts
;
;----------------------------------------------------------------------------
;
T_1BC6:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#0,(A1)
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#0,D1
	moveq	#6,D2
	moveq	#0,D3
	lea	CD_sector_buf,A2
	bsr	T_1DCC
	rts
;
;----------------------------------------------------------------------------
;
T_1BEA:	link	A6,#-$C
	move.l	12(A6),-$4(A6)
	move.l	$10(A6),-$8(A6)
	move.w	$14(A6),-$A(A6)
	move.w	10(A0),-$C(A6)
T_1C06:	moveq	#0,D0
	moveq	#0,D1
	move.w	-$A(A6),D1
	beq.s	T_1C52
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.l	-$8(A6),(A1)
	move.b	#8,(A1)
	move.w	#$3F,D0
	cmp.w	D0,D1
	bls.s	T_1C2C
	move.w	D0,D1
T_1C2C:	move.b	D1,4(A1)
	movea.l	-$4(A6),A2
	add.l	D1,-$8(A6)
	sub.w	D1,-$A(A6)
	moveq	#11,D0
	asl.l	D0,D1
	add.l	D1,-$4(A6)
	move.w	-$C(A6),D0
	moveq	#6,D2
	bsr	T_1E1A
	tst.l	D0
	beq.s	T_1C06
T_1C52:	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
T_1C56:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#3,(A1)
	move.b	#$20,4(A1)
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#$20,D1
	moveq	#6,D2
	lea	CD_sector_buf,A2
	bsr	T_1E1A
	rts
;
;----------------------------------------------------------------------------
;
T_1C7E:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.l	8(SP),(A1)
	move.b	#11,D0
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#0,D1
	moveq	#6,D2
	moveq	#0,D3
	lea	CD_sector_buf,A2
	bsr	T_1DCC
	rts
;
;----------------------------------------------------------------------------
;
T_1CA6:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#0,(A1)
	lea	CD_sector_buf,A2
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#0,D1
	moveq	#6,D2
	bsr	cmd_dma_Read
	rts
;
;----------------------------------------------------------------------------
;
T_1CC8:	link	A6,#-$C
	move.l	12(A6),-$4(A6)
	move.l	$10(A6),-$8(A6)
	move.w	$14(A6),-$A(A6)
	move.w	bos_xCSI_LUN_ID(a0),-$C(A6)
T_1CE4:	moveq	#0,D0
	moveq	#0,D1
	move.w	-$A(A6),D1
	beq	T_1D74
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.l	-$8(A6),(A1)
	move.b	#8,(A1)
	clr.l	B_3A3E
	movea.l	-$4(A6),A2
	moveq	#$3F,D0
	move.l	A2,D3
	andi.l	#$FF000000,D3
	beq.s	T_1D26
	move.l	A2,B_3A3E
	movea.l	fastram_buf_p,A2
	moveq	#$1F,D0
T_1D26:	cmp.w	D0,D1
	bls.s	T_1D2C
	move.w	D0,D1
T_1D2C:	move.b	D1,4(A1)
	add.l	D1,-$8(A6)
	sub.w	D1,-$A(A6)
	moveq	#11,D0
	asl.l	D0,D1
	add.l	D1,-$4(A6)
	move.w	-$C(A6),D0
	moveq	#6,D2
	move.l	D1,-(SP)
	bsr	cmd_dma_Read
	move.l	(SP)+,D1
	tst.l	D0
	bne.s	T_1D74
	tst.l	B_3A3E
	beq.s	T_1CE4
	movea.l	fastram_buf_p,A1
	movea.l	B_3A3E,A2
	move.l	D1,D0
	asr.l	#4,D0
	subq.w	#1,D0
	bsr	move_16_times_d0p1
	bra	T_1CE4
;
T_1D74:	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
T_1D78:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#3,(A1)
	move.b	#$20,4(A1)
	lea	CD_sector_buf,A2
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#$20,D1
	moveq	#6,D2
	move.l	#$100,D3		;Wr
	bsr	cmd_dma_Read_Write
	rts
;
;----------------------------------------------------------------------------
;
T_1DA6:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.l	8(SP),(A1)
	move.b	#11,(A1)
	lea	CD_sector_buf,A2
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#0,D1
	moveq	#6,D2
	bsr	cmd_dma_Read
	rts
;
;----------------------------------------------------------------------------
;
T_1DCC:	bsr	delay_until_B_3C4E
	st	(flock).w			;flock
	bsr	combine_LUN_LBAH
	moveq	#'S',D4
	bsr	trace_sub_1
	move.l	D3,-(SP)
	moveq	#0,D3
	bsr	T_1ECC
	bmi.s	T_1DFE
	move.l	#$7D1,D1
	add.w	(SP),D1
	add.l	(_hz_200).w,D1		;_hz_200
	bsr	T_225E
	bmi.s	T_1DFE
	bsr	T_21C0
T_1DFE:	addq.l	#4,SP
	bsr	T_245E
	clr.w	(flock).w			;flock
	move.l	(_hz_200).w,D1		;_hz_200
	addq.l	#2,D1
	move.l	D1,B_3C4E
	bsr	trace_sub_2
	rts
;
;----------------------------------------------------------------------------
;
T_1E1A:	moveq	#0,D3
	bra.s	T_1E20
;
	moveq	#1,D3
T_1E20:	bsr	delay_until_B_3C4E
	st	(flock).w			;flock
	bsr	combine_LUN_LBAH
	moveq	#$53,D4
	bsr	trace_sub_1
	move.l	D3,D4
	swap	D4
	andi.l	#1,D3
	movem.l	D1-D2,-(SP)
	bsr	T_1ECC
	movem.l	(SP)+,D1-D2
	tst.l	D0
	bmi.s	T_1E9E
	bsr	T_233C
	asr.l	#8,D1
	asr.l	#1,D1
	addi.l	#$7D1,D1
	add.w	D4,D1
	add.l	(_hz_200).w,D1		;_hz_200
	tst.l	D0
	beq.s	T_1E88
T_1E64:	bsr	T_225E
	bmi.s	T_1E9E
	bsr	T_231A
	beq.s	T_1E90
	tst.l	D3
	beq.s	T_1E7C
	move.b	(A2)+,D0
	bsr	T_207E
	bra.s	T_1E82
;
T_1E7C:	bsr	T_220E
	move.b	D0,(A2)+
T_1E82:	bsr	T_229E
	bra.s	T_1E64
;
T_1E88:	bsr	T_209A
	tst.l	D0
	bne.s	T_1E9E
T_1E90:	bsr	T_21C0
	tst.l	D0
	bne.s	T_1E9E
	bsr	T_2426
	moveq	#0,D0
T_1E9E:	bsr	T_245E
	clr.w	(flock).w			;flock
	move.l	(_hz_200).w,D1		;_hz_200
	addq.l	#2,D1
	move.l	D1,B_3C4E
	bsr	trace_sub_2
	rts
;
;----------------------------------------------------------------------------
;
combine_LUN_LBAH:
	move.b	D0,D4		;d4 = SCSI (LUN<<4 | ID)
	andi.b	#$70,D4		;LUN masked to 3 bits
	add.b	D4,D4		;and shifted to top 3 bits
	andi.b	#$1F,1(A1)	;LBAH masked to 5 bits
	or.b	D4,1(A1)	;LUN combined with LBAH
	rts
;
;----------------------------------------------------------------------------
;
T_1ECC:	move.l	D1,-(SP)
	andi.b	#7,D0		;d0 = ID
	move.w	D0,-(SP)	;push ID
	bsr.s	T_1F02
	addq.l	#2,SP
	move.l	(SP)+,D1
	tst.l	D0
	bmi.s	T_1F00
	bsr	T_2024
	move.l	#$C9,D1
	add.l	(_hz_200).w,D1		;_hz_200
	subq.w	#1,D2
T_1EEE:	moveq	#0,D0
	move.b	(A1)+,D0
	bsr	T_206C
	tst.l	D0
	bmi.s	T_1F00
	dbra	D2,T_1EEE
	moveq	#0,D0
T_1F00:	rts
;
;----------------------------------------------------------------------------
;
T_1F02:	move.l	#$C9,D1
	add.l	(_hz_200).w,D1		;_hz_200
T_1F0C:	bsr	T_2002
	btst	#6,D0
	beq.s	T_1F24
	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_1F0C
	move.l	#-$E01,D1
	bra.s	T_1F52
;
T_1F24:	bsr.s	T_1F5C
	move.w	4(SP),D1
	bsr	T_1FA0
	move.l	#$C9,D1
	add.l	(_hz_200).w,D1		;_hz_200
T_1F38:	bsr	T_2002
	btst	#6,D0
	bne.s	T_1F50
	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_1F38
	move.l	#-$D01,D1
	bra.s	T_1F52
;
T_1F50:	moveq	#0,D1
T_1F52:	moveq	#0,D0
	bsr	T_21A4
	move.l	D1,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1F5C:	btst	#2,machine_f
	bne.s	T_1F7A
	move.b	#0,$FFFF8787.w		;s_tcr
	move.b	#0,$FFFF8789.w		;s_idstat
	move.b	#12,$FFFF8783.w		;s_icr
	rts
;
;
T_1F7A:	move.w	#$8B,(hw_dmacont).w
	move.w	#0,(hw_dmadata).w
	move.w	#$8C,(hw_dmacont).w
	move.w	#0,(hw_dmadata).w
	move.w	#$89,(hw_dmacont).w
	move.w	#12,(hw_dmadata).w
	rts
;
;----------------------------------------------------------------------------
;
T_1FA0:	moveq	#0,D0
	bset	D1,D0
	btst	#2,machine_f
	bne.s	T_1FC6
	move.b	D0,$FFFF8781.w		;s_data
	move.b	#13,$FFFF8783.w		;s_icr
	andi.b	#$FE,$FFFF8785.w	;s_mode
	andi.b	#$F7,$FFFF8783.w	;s_icr
	rts
;
;
T_1FC6:	move.w	#$88,(hw_dmacont).w
	move.w	D0,(hw_dmadata).w
	move.w	#$89,(hw_dmacont).w
	move.w	#5,(hw_dmadata).w
	move.w	#$8A,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	andi.b	#$FE,D0
	move.w	D0,(hw_dmadata).w
	move.w	#$89,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	andi.b	#$F7,D0
	move.w	D0,(hw_dmadata).w
	rts
;
;----------------------------------------------------------------------------
;
T_2002:	moveq	#0,D0
	btst	#2,machine_f
	bne.s	T_2014
	move.b	$FFFF8789.w,D0		;s_idstat
	rts
;
;
T_2014:	move.w	#$8C,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	andi.w	#$FF,D0
	rts
;
;----------------------------------------------------------------------------
;
T_2024:	btst	#2,machine_f
	bne.s	T_2052
	tst.l	D3
	bne.s	T_2044
	move.l	A2,D0
	movea.w	#-$78FF,A0
	movep.l	D0,0(A0)
	movea.w	#-$78F7,A0
	movep.l	D1,0(A0)
T_2044:	move.b	#2,$FFFF8787.w		;s_tcr
	move.b	#1,$FFFF8783.w		;s_icr
	rts
;
;
T_2052:	move.w	#$8B,(hw_dmacont).w
	move.w	#2,(hw_dmadata).w
	move.w	#$89,(hw_dmacont).w
	move.w	#1,(hw_dmadata).w
	rts
;
;----------------------------------------------------------------------------
;
T_206C:	move.w	D0,-(SP)
	bsr	T_225E
	bmi.s	T_207C
	move.w	(SP)+,D0
	bsr.s	T_207E
	bsr	T_229E
T_207C:	rts
;
;----------------------------------------------------------------------------
;
T_207E:	btst	#2,machine_f
	bne.s	T_208E
	move.b	D0,$FFFF8781.w		;s_data
	rts
;
;
T_208E:	move.w	#$88,(hw_dmacont).w
	move.w	D0,(hw_dmadata).w
	rts
;
;----------------------------------------------------------------------------
;
T_209A:	btst	#2,machine_f
	bne.s	T_20F2
T_20A4:	btst	#7,$FFFFFA81.w		;gpip_tt
	bne.s	T_20D8
	btst	#5,$FFFFFA81.w		;gpip_tt
	beq.s	T_20C4
	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_20A4
T_20BA:	bsr.s	T_2138
	move.l	#-$C01,D0
	rts
;
T_20C4:	move.w	$FFFF8714.w,D0		;tt_dmactl
	andi.l	#$80,D0
	beq.s	T_20A4
	move.l	D0,-(SP)
	bsr.s	T_2138
	move.l	(SP)+,D0
	rts
;
T_20D8:	move.b	$FFFF878F.w,D1		;s_inircv
	move.w	#0,$FFFF8714.w		;tt_dmactl
	move.b	#0,$FFFF8785.w		;s_mode
	move.b	#0,$FFFF8783.w		;s_icr
	moveq	#0,D0
	rts
;
;
T_20F2:	btst	#5,$FFFFFA01.w		;gpip
	beq.s	T_2102
	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_20F2
	bra.s	T_20BA
;
T_2102:	move.w	#$8F,(hw_dmacont).w
	move.w	(hw_dmadata).w,D1
	move.w	#$8A,(hw_dmacont).w
	move.w	#0,(hw_dmadata).w
	move.w	#$89,(hw_dmacont).w
	move.w	#0,(hw_dmadata).w
	tst.w	new_cpu_f
	beq.s	T_2134
	tst.l	D3
	bne.s	T_2134
	bsr	T_2868
T_2134:	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
T_2138:	btst	#2,machine_f
	beq.s	T_2156
T_2142:	btst	#3,$FFFF860F.w
	bne.s	T_2142
	movem.l	D3/A0,-(SP)
	lsl.l	#8,D3
	bsr.s	prepare_dma_a0
	movem.l	(SP)+,D3/A0
T_2156:	move.w	#$80,D0
	bsr.s	T_21A4
	move.l	#$C9,D1
	add.l	(_hz_200).w,D1		;_hz_200
T_2166:	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_2166
	moveq	#0,D0
	bsr.s	T_21A4
	move.l	#$3E9,D1
	add.l	(_hz_200).w,D1		;_hz_200
T_217A:	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_217A
	rts
;
;----------------------------------------------------------------------------
;Sub:	'prepare_dma'
;Entry:	d3 =  Write_bit<<8
;Exit:	a0 -> (hw_dmadata)
;
;	prepares (hw_dmacont) for command, toggling Rd/Wr so that the
;	final setting = bit 8 of d3, the direction of future dma flow
;	Also sets bit 4, so that (hw_dmadata) can access sector count
;
prepare_dma_a0:
	lea	(hw_dmadata).w,A0
	move.w	#$190,D0		;Wr,Reg,SCR,hdcmd
	eor.w	D3,D0
	move.w	D0,2(A0)		;(hw_dmacont) = d0
	bsr	four_tst_delays
	move.w	#$90,D0			;Rd,Reg,SCR,hdcmd
	eor.w	D3,D0
	move.w	D0,2(A0)		;(hw_dmacont) = d0
	bsr	four_tst_delays
	rts
;
;----------------------------------------------------------------------------
;
T_21A4:	btst	#2,machine_f
	bne.s	T_21B4
	move.b	D0,$FFFF8783.w		;s_icr
	rts
;
;
T_21B4:	move.w	#$89,(hw_dmacont).w
	move.w	D0,(hw_dmadata).w
	rts
;
;----------------------------------------------------------------------------
;
T_21C0:	move.l	#$C9,D1
	add.l	(_hz_200).w,D1		;_hz_200
	bsr.s	T_2230
	bsr	T_225E
	bmi.s	T_2208
	bsr.s	T_220E
	move.l	D0,-(SP)
	move.l	#$C9,D1
	add.l	(_hz_200).w,D1		;_hz_200
	bsr	T_229E
	tst.l	D0
	bne.s	T_220A
	move.l	#$C9,D1
	add.l	(_hz_200).w,D1		;_hz_200
	bsr	T_225E
	bmi.s	T_220A
	bsr.s	T_220E
	move.b	D0,2(SP)
	bsr	T_229E
	tst.l	D0
	bmi.s	T_220A
	move.l	(SP)+,D0
T_2208:	rts
;
;----------------------------------------------------------------------------
;
T_220A:	addq.l	#4,SP
	rts
;
;----------------------------------------------------------------------------
;
T_220E:	moveq	#0,D0
	btst	#2,machine_f
	bne.s	T_2220
	move.b	$FFFF8781.w,D0
	rts
;
;----------------------------------------------------------------------------
;
T_2220:	move.w	#$88,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	andi.w	#$FF,D0
	rts
;
;----------------------------------------------------------------------------
;
T_2230:	btst	#2,machine_f
	bne.s	T_2246
	move.b	#3,$FFFF8787.w		;s_tcr
	move.b	$FFFF878F.w,D0		;s_inircv
	rts
;
;
T_2246:	move.w	#$8B,(hw_dmacont).w
	move.w	#3,(hw_dmadata).w
	move.w	#$8F,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	rts
;
;----------------------------------------------------------------------------
;
T_225E:	btst	#2,machine_f
	bne.s	T_2278
T_2268:	btst	#5,$FFFF8789.w		;s_idstat
	bne.s	T_229A
	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_2268
	bra.s	T_228E
;
;
T_2278:	move.w	#$8C,(hw_dmacont).w
T_227E:	move.w	(hw_dmadata).w,D0
	btst	#5,D0
	bne.s	T_229A
	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_227E
T_228E:	bsr	T_2138
	move.l	#-$B01,D0
	rts
;
;----------------------------------------------------------------------------
;
T_229A:	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
T_229E:	btst	#2,machine_f
	bne.s	T_22CE
	ori.b	#$11,$FFFF8783.w	;s_icr
T_22AE:	btst	#5,$FFFF8789.w		;s_idstat
	beq.s	T_22C4
	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_22AE
	move.l	#-$A01,D0
	bra.s	T_22C6
;
T_22C4:	moveq	#0,D0
T_22C6:	andi.b	#$EF,$FFFF8783.w	;s_icr
	rts
;
;----------------------------------------------------------------------------
;
T_22CE:	move.w	#$89,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	ori.b	#$11,D0
	move.w	D0,(hw_dmadata).w
	move.w	#$8C,(hw_dmacont).w
T_22E6:	move.w	(hw_dmadata).w,D0
	btst	#5,D0
	beq.s	T_22FE
	cmp.l	(_hz_200).w,D1		;_hz_200
	bhi.s	T_22E6
	move.l	#-$901,-(SP)
	bra.s	T_2304
;
T_22FE:	move.l	#0,-(SP)
T_2304:	move.w	#$89,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	andi.b	#$EF,D0
	move.w	D0,(hw_dmadata).w
	move.l	(SP)+,D0
	rts
;
;----------------------------------------------------------------------------
;
T_231A:	btst	#2,machine_f
	bne.s	T_232C
	btst	#3,$FFFF878B.w		;s_dmastat
	rts
;
T_232C:	move.w	#$8D,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	btst	#3,D0
	rts
;
;----------------------------------------------------------------------------
;
T_233C:	btst	#2,machine_f
	bne.s	T_237C
	move.b	#0,$FFFF8783.w		;s_icr
	moveq	#1,D0
	eor.b	D3,D0
	move.b	D0,$FFFF8787.w		;s_tcr
	move.b	$FFFF878F.w,D0		;s_inircv
	tst.l	D3
	bne.s	T_2378
	move.b	#2,$FFFF8785.w		;s_mode
	move.b	#0,$FFFF878F.w		;s_inircv
	move.w	#0,$FFFF8714.w		;tt_dmactl
	move.w	#2,$FFFF8714.w		;tt_dmactl
	moveq	#0,D0
	rts
;
;
T_2378:	moveq	#1,D0
	rts
;
;
T_237C:	move.w	#$89,(hw_dmacont).w
	move.w	#0,(hw_dmadata).w
	moveq	#1,D0
	eor.b	D3,D0
	move.w	#$8B,(hw_dmacont).w
	move.w	D0,(hw_dmadata).w
	move.w	#$8F,(hw_dmacont).w
	move.w	(hw_dmadata).w,D0
	cmpi.l	#$200,D1
	bcs.s	T_2378
	move.l	D1,D0
	andi.l	#15,D0
	bne.s	T_2378
	move.w	#$8A,(hw_dmacont).w
	move.w	#2,(hw_dmadata).w
	move.l	A2,-(SP)
	move.b	3(SP),(hw_dmabase0).w
	move.b	2(SP),(hw_dmabase1).w
	move.b	1(SP),(hw_dmabase2).w
	adda.w	#4,SP
	move.l	D3,-(SP)
	lsl.l	#8,D3
	bsr	prepare_dma_a0
	move.l	(SP)+,D3
	move.l	D1,-(SP)
	addi.l	#$1FF,D1
	asr.l	#8,D1
	asr.l	#1,D1
	move.w	D1,(A0)
	move.l	(SP)+,D1
T_23F0:	btst	#3,$FFFF860F.w
	bne.s	T_23F0
	tst.l	D3
	beq.s	T_2410
	move.w	#$18D,(hw_dmacont).w	;Wr,Reg,HDcmd
	move.w	#0,(hw_dmadata).w
	move.w	#$100,2(A0)
	bra.s	T_2422
;
T_2410:	move.w	#$8F,(hw_dmacont).w
	move.w	#0,(hw_dmadata).w
	move.w	#0,2(A0)
T_2422:	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
T_2426:	btst	#2,machine_f
	bne.s	T_245C
	move.b	$FFFF8707.w,D0		;tt_dmabas+6
	andi.w	#3,D0
	beq.s	T_245C
	movea.w	#-$78FF,A1
	movep.l	0(A1),D0
	move.l	D0,D1
	andi.w	#3,D0
	andi.w	#-$4,D1
	movea.l	D1,A0
	move.l	$FFFF8710.w,D1		;tt_marsd
	subq.w	#1,D0
T_2454:	rol.l	#8,D1
	move.b	D1,(A0)+
	dbra	D0,T_2454
T_245C:	rts
;
;----------------------------------------------------------------------------
;
T_245E:	btst	#2,machine_f
	bne.s	T_246E
	move.b	$FFFF878F.w,D1		;s_inircv
	rts
;
T_246E:	move.w	#$8F,(hw_dmacont).w
	move.w	(hw_dmadata).w,D1
	move.w	#$80,(hw_dmacont).w
	rts
;
;----------------------------------------------------------------------------
;
T_2480:	cmpi.b	#$FF,D0
	beq.s	T_24B6
	movea.l	B_3C46,A0
	bsr	T_25C0
	cmpi.b	#$FF,D0
	beq.s	T_24B6
	lea	CD_sector_buf,A2
	move.b	2(A2),D1
	andi.w	#7,D1
	ext.w	D1
	asl.w	#1,D1
	lea	D_39B6,A0
	move.w	0(A0,D1.w),D0
	ext.l	D0
	rts
;
;----------------------------------------------------------------------------
;
T_24B6:	moveq	#-19,D0
	rts
;
;----------------------------------------------------------------------------
;
cmd_dma_Inquiry:
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$12,(A1)
	move.b	D1,4(A1)
	moveq	#6,D2
	lea	CD_sector_buf,A2
	bsr	cmd_dma_Read
	rts
;
;----------------------------------------------------------------------------
;
T_24DA:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#0,(A1)
	lea	CD_sector_buf,A2
	move.w	bos_xCSI_LUN_ID(a0),D0
	moveq	#0,D1
	moveq	#6,D2
	bsr	cmd_dma_Read
	rts
;
;----------------------------------------------------------------------------
;
T_24FC:	link	A6,#-$C
	move.l	12(A6),-$4(A6)
	move.l	$10(A6),-$8(A6)
	move.w	$14(A6),-$A(A6)
	move.w	bos_xCSI_LUN_ID(a0),-$C(A6)
T_2518:	moveq	#0,D0
	moveq	#0,D1
	move.w	-$A(A6),D1
	beq	T_25BC
	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#$18,(A1)		;SCSI_copy
	move.l	-$8(A6),D1
	addi.l	#$96,D1
	andi.l	#$1FFFFF,D1
	move.l	D1,2(A1)		;store LBA
	clr.l	B_3A3E
	movea.l	-$4(A6),A2
	moveq	#$3F,D0
	move.l	A2,D3
	andi.l	#-$1000000,D3
	beq.s	T_256A
	move.l	A2,B_3A3E
	movea.l	fastram_buf_p,A2
	moveq	#$1F,D0
T_256A:	move.w	-$A(A6),D1
	cmp.w	D0,D1
	bls.s	T_2574
	move.w	D0,D1
T_2574:	move.b	D1,8(A1)
	add.l	D1,-$8(A6)
	sub.w	D1,-$A(A6)
	moveq	#11,D0
	asl.l	D0,D1
	add.l	D1,-$4(A6)
	move.w	-$C(A6),D0
	moveq	#10,D2
	move.l	D1,-(SP)
	bsr.s	cmd_dma_Read
	move.l	(SP)+,D1
	tst.l	D0
	bne.s	T_25BC
	tst.l	B_3A3E
	beq	T_2518
	movea.l	fastram_buf_p,A1
	movea.l	B_3A3E,A2
	move.l	D1,D0
	asr.l	#4,D0
	subq.w	#1,D0
	bsr	move_16_times_d0p1
	bra	T_2518
;
T_25BC:	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
T_25C0:	bsr	clr_SCSI_cmd_a2
	lea	SCSI_cmdbuf_1,A1
	move.b	#3,(A1)
	lea	CD_sector_buf,A2
	move.w	bos_xCSI_LUN_ID(a0),D0
	move.l	#$100,D1
	moveq	#6,D2
	bsr.s	cmd_dma_Read
	rts
;
;----------------------------------------------------------------------------
;Sub:	'cmd_dma_Read'
;Entry:
;Exit:
;
cmd_dma_Read:
	moveq	#0,D3
	bra.s	cmd_dma_Read_Write
;
;----------------------------------------------------------------------------
;Sub:	'cmd_dma_Read_Write'
;Entry:	d0=LUN<<4+ID  d1=data length  d3=timeout<<16+Wr/_Rd<<8
;  "	a1->SCSI_cmdbuf_1
;Exit:
;
	moveq	#1,D3		;NB: Unref'd instruction
cmd_dma_Read_Write:
	move.b	D0,D4		;d4 = SCSI/ACSI (LUN<<4 | ID)
	andi.b	#$70,D4		;LUN masked to 3 bits
	add.b	D4,D4		;and shifted to top 3 bits
	move.b	1(A1),D5	;D5 = LBAH
	andi.b	#$1F,D5		;LBAH masked to 5 bits
	or.b	D4,D5		;LBAH combined with LUN
	move.b	D5,1(A1)	;store LUN_LBAH
;
	move.l	D1,-(SP)	;push data length
	bsr	delay_until_B_3C4A
	st	(flock).w
	cmpi.b	#$1E,(A1)	;opcode > $1E ?
	bls.s	.ICD_sel_done	;if not, skip special ICD select
	lea	SCSI_cmdbuf_2,A0
;
	btst	#2,d0		;;;new;;; is this a modified ACSI board
	bne.s	.mACSI_fix_1	;;;new;;; skip prefix for mACSI
	move.b	#$1F,(A0)+	;prep special ICD select command prefix
.mACSI_fix_1:
	move.l	D2,D4		;d4 = command length
	subq.w	#1,D4		;d4 adjusted for dbra
.T_261E:
	move.b	(A1)+,(A0)+	;place SCSI command behind prefix
	dbra	D4,.T_261E
	lea	SCSI_cmdbuf_2,A1	;a1 -> second buffer
	btst	#2,d0		;;;new;;; is this a modified ACSI board
	bne.s	.mACSI_fix_2	;;;new;;; skip prefix increment for mACSI
	addq.w	#1,D2		;increase ICD command length by 1 byte
.mACSI_fix_2:
;
.ICD_sel_done:
	moveq	#'A',D4
	bsr	trace_sub_1
	move.l	D3,D5		;d5 = d3
	lsr.w	#8,D5
	andi.l	#1,D3
	beq.s	.T_2644
	move.l	#$100,D3
.T_2644:
	lsl.b	#5,D0		;d0 byte = ID bits shifted to top 3 bits
	or.b	D0,(A1)		;ID combined into opcode
	move.l	A2,-(SP)
	move.b	3(SP),(hw_dmabase0).w	;\
	move.b	2(SP),(hw_dmabase1).w	; X Set dma base address
	move.b	1(SP),(hw_dmabase2).w	;/
	adda.w	#4,SP
	bsr	prepare_dma_a0		;a0 -> hw_dmadata with clear status
	addi.l	#$1FF,D1
	asr.l	#8,D1
	asr.l	#1,D1		;d1 = dma blocks needed for complete data
	move.w	D1,(A0)		;SCR = d1
.repeat_cmd_loop:
	bsr	delay_until_B_3C4A
	movea.l	A1,A3		;a3 -> ACSI/ICD command
	move.l	D2,D4
	moveq	#0,D1		;d1   =  _RD
	move.b	#$88,D1		;d1.b = _Reg|_extR|_cmd
	or.w	D3,D1		;Adjust Wr/_Rd for actual direction
	move.w	D1,2(A0)	;(hw_dmacont) = d1
	move.b	#$8A,D1		;d1.b = _Reg|_extR|data  
	subq.w	#2,D4		;d4 = command length -2
;
.T_268A:			;loop to write command excluding last byte
	swap	D1
	move.b	(A3)+,D1	;d1 = next command byte
	swap	D1
	move.l	D1,(A0)		;write to (hw_dmadata) and (hw_dmacont)
	move.l	#201,D0		;1s timeout
	bsr	T_275A		;delay until ready or timeout
	bmi.s	T_271C		;exit on error
	dbra	D4,.T_268A	;loop back for more bytes
	move.w	D1,2(A0)
	move.b	#0,D1		;d1.b = dma mode control (with old Wr/_Rd)
	swap	D1
	move.b	(A3),D1		;d1 = final command byte
	swap	D1
	move.l	D1,(A0)		;write to (hw_dmadata) and (hw_dmacont)
;
;DMA transfer will start here
;
	move.l	(SP),D0		;d0 = data length  (remains on stack)
	addi.l	#$1FF,D0
	asr.l	#8,D0
	asr.l	#1,D0		;d0 = sectors needed for data length
	addi.l	#2001,D0	;10s timeout
	swap	D5
	add.w	D5,D0
	swap	D5
	bsr	T_275A		;delay until ready or timeout
	move.l	(_hz_200).w,D4		;_hz_200
	addq.l	#2,D4
	move.l	D4,B_3C4A
	tst.l	D0
	bmi.s	T_2724
	tst.w	new_cpu_f
	beq.s	.T_26EA
	bsr	T_2868		;this sub is not called for 68000
.T_26EA:
	move.b	#$8A,D1		;Rd,Reg,extR,data
	move.w	D1,2(A0)
	move.w	(A0),D0		;d0 = (hw_dmastat)
	andi.l	#$FF,D0
	dbne	D5,.repeat_cmd_loop
T_26FE:	move.w	#$80,2(A0)	;Rd,Reg,extR,cmd
	clr.w	(flock).w			;flock
	addq.w	#4,SP
	bsr	trace_sub_2
	move.l	(_hz_200).w,D4		;_hz_200
	addq.l	#2,D4
	move.l	D4,B_3C4A
	rts
;
T_271C:	move.l	#-$801,D0
	bra.s	T_26FE
;
T_2724:	move.l	#-$701,D0
	bra.s	T_26FE
;
;----------------------------------------------------------------------------
;
delay_until_B_3C4A:
	move.l	D0,-(SP)
	move.l	B_3C4A,D0
	bra.s	T_273E
;
delay_until_B_3C4E:
	move.l	D0,-(SP)
	move.l	B_3C4E,D0
T_273E:
	cmp.l	(_hz_200).w,D0
	bhs.s	T_273E
	move.l	(SP)+,D0
	rts
;
;----------------------------------------------------------------------------
;
four_tst_delays:
	tst.b	$FFFFFA01.w		;gpip
	tst.b	$FFFFFA01.w		;gpip
	tst.b	$FFFFFA01.w		;gpip
	tst.b	$FFFFFA01.w		;gpip
	rts
;
;----------------------------------------------------------------------------
;
T_275A:	add.l	(_hz_200).w,D0
T_275E:	cmp.l	(_hz_200).w,D0
	bcs.s	T_2770
	btst	#5,$FFFFFA01.w		;gpip
	bne.s	T_275E
	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
T_2770:	moveq	#-1,D0
	rts
;
;----------------------------------------------------------------------------
;
clr_SCSI_cmd_a2:
	lea	SCSI_cmdbuf_1,A2
	clr.l	(A2)+
	clr.l	(A2)+
	clr.l	(A2)+
	clr.l	(A2)
	rts
;
;----------------------------------------------------------------------------
;
move_16_times_d0p1:
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+
	dbra	D0,move_16_times_d0p1
	rts
;
;----------------------------------------------------------------------------
;
T_2792:	movea.l	B_3C46,A0
	move.b	#8,$13(A0)
	rts
;
;----------------------------------------------------------------------------
;
trace_sub_1:
	move.l	#0,B_3A3A
	tst.l	max_trace
	beq.s	T_2804
	movem.l	D1-D2/A0-A1/A6,-(SP)
	movea.l	D_3A20,A6
	swap	D4
	move.w	#$25,D4
	add.w	D_3A2E,D4
	movea.l	A6,A0
T_27CA:	clr.b	(A0)+
	dbra	D4,T_27CA
	swap	D4
	move.l	(_hz_200).w,0(A6)		;_hz_200
	move.w	D3,8(A6)
	move.b	D4,10(A6)
	move.b	D0,11(A6)
	move.b	D2,12(A6)
	lea	13(A6),A0
	subq.w	#1,D2
T_27EE:	move.b	(A1)+,(A0)+
	dbra	D2,T_27EE
	move.l	D3,$1E(A6)
	move.l	D1,$22(A6)
	move.l	A2,$26(A6)
	movem.l	(SP)+,D1-D2/A0-A1/A6
T_2804:	rts
;
;----------------------------------------------------------------------------
;
trace_sub_2:
	tst.l	max_trace
	beq.s	T_2866
	movem.l	D1-D2/A0-A1/A6,-(SP)
	movea.l	D_3A20,A6
	move.l	(_hz_200).w,4(A6)		;_hz_200
	move.l	D0,$1A(A6)
	move.l	$22(A6),D2
	move.l	D_3A2C,D1
	cmp.l	D1,D2
	bcs.s	T_2832
	move.l	D1,D2
T_2832:	movea.l	$26(A6),A1
	lea	$26(A6),A0
	bra.s	T_283E
;
T_283C:	move.b	(A1)+,(A0)+
T_283E:	dbra	D2,T_283C
	adda.l	#$26,A6
	adda.l	D_3A2C,A6
	cmpa.l	D_3A28,A6
	blt.s	T_285C
	movea.l	D_3A24,A6
T_285C:	move.l	A6,D_3A20
	movem.l	(SP)+,D1-D2/A0-A1/A6
T_2866:	rts
;
;----------------------------------------------------------------------------
;
T_2868:	move	sr,-(SP)
	ori	#$700,sr
	dc.w	$4E7A			;Nz
	ori.b	#$80,D2
	dc.w	$0000			;
	dc.w	$0808			;
	dc.w	$4E7B			;N{
	dc.w	$0002			;
	move	(SP)+,sr
	rts
;
;----------------------------------------------------------------------------
;
	SECTION	DATA
;
;----------------------------------------------------------------------------
;
bos_name_ver_s:	dc.b	'CD ACSI/SCSI BOS Driver v2.1',$0,$0
copyright_s:	dc.b	CR,LF
		dc.b	'Copyright ½ 1993-1995 Roger Burrows',CR,LF
		dc.b	'All rights reserved.',CR,LF,$0
device_is_s:	dc.b	'Device is '
drive_name_head_s:
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,' '
drive_name_tail_s:
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,CR,LF,$0
Atari_CDAR_504_s:
		dc.b	'Atari   CDAR-504        '
BOS_init_p:
		dc.l	BOS_init
;
;----------------------------------------------------------------------------
;
cdtype_link_t:
	dc.l	cdtype_TOSHIBA_XM_5201_s
	dc.l	func_t_TOSHIBA_group_1
;
	dc.l	cdtype_TOSHIBA_XM_4101_s
	dc.l	func_t_TOSHIBA_group_1
;
	dc.l	cdtype_TOSHIBA_XM_3501_s
	dc.l	func_t_TOSHIBA_group_1
;
	dc.l	cdtype_TOSHIBA_XM_3401_s
	dc.l	func_t_TOSHIBA_group_1
;
	dc.l	cdtype_TOSHIBA_XM_3301_s
	dc.l	func_t_TOSHIBA_XM_3301
;
	dc.l	cdtype_TOSHIBA_XM_3201_s
	dc.l	func_t_TOSHIBA_XM_3201
;
	dc.l	cdtype_TOSHIBA_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_NEC_DRIVE_50_s
	dc.l	func_t_NEC_group_1
;
	dc.l	cdtype_NEC_DRIVE_51_s
	dc.l	func_t_NEC_group_1
;
	dc.l	cdtype_NEC_DRIVE_40_s
	dc.l	func_t_NEC_group_1
;
	dc.l	cdtype_NEC_DRIVE_41_s
	dc.l	func_t_NEC_group_1
;
	dc.l	cdtype_NEC_DRIVE_841_s
	dc.l	func_t_NEC_group_1
;
	dc.l	cdtype_NEC_DRIVE_38_s
	dc.l	func_t_NEC_group_1
;
	dc.l	cdtype_NEC_DRIVE_210_s
	dc.l	func_t_NEC_DRIVE_210
;
	dc.l	cdtype_NEC_DRIVE_84_s
	dc.l	func_t_NEC_group_2
;
	dc.l	cdtype_NEC_DRIVE_37_s
	dc.l	func_t_NEC_group_2
;
	dc.l	cdtype_NEC_DRIVE_other_s
	dc.l	func_t_NEC_group_3
;
	dc.l	cdtype_NEC_2_DRIVE_other_s
	dc.l	func_t_NEC_group_3
;
	dc.l	cdtype_NEC_DRIVE_25_s
	dc.l	func_t_NEC_group_3
;
	dc.l	cdtype_NEC_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_SONY_CDU_55S_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_SONY_CDU_561_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_SONY_CDU_8003A_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_SONY_CDU_561_SUNMSCD_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_SONY_CDU_541_s
	dc.l	func_t_SONY_group_2
;
	dc.l	cdtype_SONY_CDU_6211_s
	dc.l	func_t_SONY_group_2
;
	dc.l	cdtype_SONY_CDU_8022_s
	dc.l	func_t_SONY_group_2
;
	dc.l	cdtype_SONY_CDU_8002_s
	dc.l	func_t_SONY_CDU_8002
;
	dc.l	cdtype_SONY_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_TEXEL_DM_XX28_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_TEXEL_DM_XX24_s
	dc.l	func_t_COMMON_DM_XX24
;
	dc.l	cdtype_TEXEL_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_CHINON_CDS_525_s
	dc.l	func_t_CHINON_group_1
;
	dc.l	cdtype_CHINON_CDS_535_S_s
	dc.l	func_t_CHINON_group_1
;
	dc.l	cdtype_CHINON_CDS_535_R_s
	dc.l	func_t_CHINON_group_1
;
	dc.l	cdtype_CHINON_CDS_535_s
	dc.l	func_t_CHINON_CDS_535
;
	dc.l	cdtype_CHINON_CDS_435_s
	dc.l	func_t_CHINON_CDS_435
;
	dc.l	cdtype_CHINON_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_PHILIPS_CDF080_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_PHILIPS_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_MATSHITA_CR_8004_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_MATSHITA_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_PLEXTOR_DM_XX28_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_PLEXTOR_DM_XX24_s
	dc.l	func_t_COMMON_DM_XX24
;
	dc.l	cdtype_PLEXTOR_PX_4XCH_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_PLEXTOR_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_MEDIAVIS_RENO_X2A_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_MEDIAVIS_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_PIONEER_DRM_602X_s
	dc.l	func_t_PIONEER_group_1
;
	dc.l	cdtype_PIONEER_DRM_604X_2401_s
	dc.l	func_t_strangetype_1
;
	dc.l	cdtype_PIONEER_DRM_604X_s
	dc.l	func_t_PIONEER_group_1
;
	dc.l	cdtype_PIONEER_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_COMPAQ_CDU_561_s
	dc.l	func_t_COMMON_group_1
;
	dc.l	cdtype_COMPAQ_other_s
	dc.l	func_t_DEFAULT
;
	dc.l	cdtype_strangetype_1_s
	dc.l	func_t_strangetype_1
;
	dc.l	cdtype_strangetype_2_s
	dc.l	func_t_DEFAULT
;
;----------------------------------------------------------------------------
;
cdtype_TOSHIBA_XM_5201_s:	dc.b	$A,'TOSHIBA CD-ROM XM-5201',$0
cdtype_TOSHIBA_XM_4101_s:	dc.b	$A,'TOSHIBA CD-ROM XM-4101',$0
cdtype_TOSHIBA_XM_3501_s:	dc.b	$A,'TOSHIBA CD-ROM XM-3501',$0
cdtype_TOSHIBA_XM_3401_s:	dc.b	$A,'TOSHIBA CD-ROM XM-3401',$0
cdtype_TOSHIBA_XM_3301_s:	dc.b	$B,'TOSHIBA CD-ROM XM-3301',$0
cdtype_TOSHIBA_XM_3201_s:	dc.b	$C,'TOSHIBA CD-ROM XM-3201',$0
cdtype_TOSHIBA_other_s:		dc.b	$13,'TOSHIBA ',$0
;
cdtype_NEC_DRIVE_50_s:		dc.b	$14,'NEC     CD-ROM DRIVE:50',$0
cdtype_NEC_DRIVE_51_s:		dc.b	$14,'NEC     CD-ROM DRIVE:51',$0
cdtype_NEC_DRIVE_40_s:		dc.b	$14,'NEC     CD-ROM DRIVE:40',$0
cdtype_NEC_DRIVE_41_s:		dc.b	$14,'NEC     CD-ROM DRIVE:41',$0
cdtype_NEC_DRIVE_841_s:		dc.b	$14,'NEC     CD-ROM DRIVE:841',$0
cdtype_NEC_DRIVE_38_s:		dc.b	$14,'NEC     CD-ROM DRIVE:38 ',$0
cdtype_NEC_DRIVE_210_s:		dc.b	$15,'NEC     CD-ROM DRIVE:210',$0
cdtype_NEC_DRIVE_84_s:		dc.b	$16,'NEC     CD-ROM DRIVE:84 ',$0
cdtype_NEC_DRIVE_37_s:		dc.b	$16,'NEC     CD-ROM DRIVE:37 ',$0
cdtype_NEC_DRIVE_other_s:	dc.b	$17,'NEC     CD-ROM DRIVE    ',$0
cdtype_NEC_2_DRIVE_other_s:	dc.b	$17,'NEC     CD-ROM2 DRIVE  ',$0
cdtype_NEC_DRIVE_25_s:		dc.b	$17,'NEC     CD-ROM DRIVE:25 ',$0
cdtype_NEC_other_s:		dc.b	$1D,'NEC     ',$0
;
cdtype_SONY_CDU_55S_s:		dc.b	$1E,'SONY    CD-ROM CDU-55S  ',$0
cdtype_SONY_CDU_561_s:		dc.b	$1E,'SONY    CD-ROM CDU-561  ',$0
cdtype_SONY_CDU_8003A_s:	dc.b	$1E,'SONY    CD-ROM CDU-8003A',$0
cdtype_SONY_CDU_561_SUNMSCD_s:	dc.b	$1E,'SONY    CDU 561  SUNMSCD',$0
cdtype_SONY_CDU_541_s:		dc.b	$1F,'SONY    CD-ROM CDU-541  ',$0
cdtype_SONY_CDU_6211_s:		dc.b	$1F,'SONY    CD-ROM CDU-6211 ',$0
cdtype_SONY_CDU_8022_s:		dc.b	$1F,'SONY    CD-ROM CDU-8022 ',$0
cdtype_SONY_CDU_8002_s:		dc.b	' SONY    CD-ROM CDU-8002 ',$0
cdtype_SONY_other_s:		dc.b	$27,'SONY    ',$0
;
cdtype_TEXEL_DM_XX28_s:		dc.b	'(TEXEL   CD-ROM DM-XX28  ',$0
cdtype_TEXEL_DM_XX24_s:		dc.b	')TEXEL   CD-ROM DM-XX24  ',$0
cdtype_TEXEL_other_s:		dc.b	'1TEXEL   ',$0
;
cdtype_CHINON_CDS_525_s:	dc.b	'4CHINON  CD-ROM CDS-525  ',$0
cdtype_CHINON_CDS_535_S_s:	dc.b	'4CHINON  CD-ROM CDS-535  S',$0
cdtype_CHINON_CDS_535_R_s:	dc.b	'4CHINON  CD-ROM CDS-535  R',$0
cdtype_CHINON_CDS_535_s:	dc.b	'2CHINON  CD-ROM CDS-535  ',$0
cdtype_CHINON_CDS_435_s:	dc.b	'3CHINON  CD-ROM CDS-435  ',$0
cdtype_CHINON_other_s:		dc.b	';CHINON  ',$0
;
cdtype_PHILIPS_CDF080_s:	dc.b	'<PHILIPS CDF080          ',$0
cdtype_PHILIPS_other_s:		dc.b	'EPHILIPS ',$0
;
cdtype_MATSHITA_CR_8004_s:	dc.b	'FMATSHITACD-ROM CR-8004  ',$0
cdtype_MATSHITA_other_s:	dc.b	'OMATSHITA',$0
;
cdtype_PLEXTOR_DM_XX28_s:	dc.b	'PPLEXTOR CD-ROM DM-XX28  ',$0
cdtype_PLEXTOR_DM_XX24_s:	dc.b	'QPLEXTOR CD-ROM DM-XX24  ',$0
cdtype_PLEXTOR_PX_4XCH_s:	dc.b	'RPLEXTOR CD-ROM PX-4XCH  ',$0
cdtype_PLEXTOR_other_s:		dc.b	'YPLEXTOR ',$0
;
cdtype_MEDIAVIS_RENO_X2A_s:	dc.b	'ZMEDIAVISRENO CD-ROMX2A',$0
cdtype_MEDIAVIS_other_s:	dc.b	'cMEDIAVIS',$0
;
cdtype_PIONEER_DRM_602X_s:	dc.b	'dPIONEER CD-ROM DRM-602X ',$0
cdtype_PIONEER_DRM_604X_2401_s:	dc.b	'ePIONEER CD-ROM DRM-604X 2401',$0
cdtype_PIONEER_DRM_604X_s:	dc.b	'fPIONEER CD-ROM DRM-604X ',$0
cdtype_PIONEER_other_s:		dc.b	'mPIONEER ',$0
;
cdtype_COMPAQ_CDU_561_s:	dc.b	'nCOMPAQ  CD-ROM CDU-561  ',$0
cdtype_COMPAQ_other_s:		dc.b	'wCOMPAQ  ',$0
;
cdtype_strangetype_1_s:		dc.b	$2,$0
cdtype_strangetype_2_s:		dc.b	-1,$0,$0
;
;----------------------------------------------------------------------------
;
func_t_DEFAULT:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	gen_E_OK_1
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
;
;----------------------------------------------------------------------------
;
func_t_strangetype_1:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	gen_E_OK_1
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	fctl_PlayTrkInd
	dc.l	fctl_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	fctl_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_GetMcn
	dc.l	fctl_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_CHINON_group_1:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	CHINON_Metafunc_8
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	fctl_PlayTrkInd
	dc.l	div_1_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	CHINON_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	CHINON_GetMcn
	dc.l	CHINON_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_CHINON_CDS_535:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	CHINON_Metafunc_8
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	CHINON_PlayTrkInd
	dc.l	CDS_535_ReadTocHdr
	dc.l	CDS_535_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	CDS_535_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	CHINON_GetMcn
	dc.l	CHINON_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_CHINON_CDS_435:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	gen_E_OK_1
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	CHINON_PlayTrkInd
	dc.l	CDS_435_ReadTocHdr
	dc.l	CDS_435_ReadTocEntry
	dc.l	CDS_435_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	CDS_435_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	CDS_435_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	CHINON_GetMcn
	dc.l	CHINON_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_NEC_group_1:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
;
;;;	dc.l	NEC_Metafunc_8	;NB: code $DE is not available on mACSI
	dc.l	dummy_Metafunc_8	;test this instead
;
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	NEC_g1_PlayMSF
	dc.l	NEC_g1_PlayTrkInd
	dc.l	fctl_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	fctl_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_GetMcn
	dc.l	fctl_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_NEC_DRIVE_210:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	NEC_Metafunc_8
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_2
	dc.l	NEC_div_Pause
	dc.l	NEC_div_Resume
	dc.l	NEC_div_PlayMSF
	dc.l	NEC_div_PlayTrkInd
	dc.l	NEC_div_ReadTocHdr
	dc.l	NEC_div_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	NEC_div_CDRomEject
	dc.l	fctl_E_OK_1
	dc.l	NEC_div_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	NEC_div_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	NEC_div_GetMcn
	dc.l	NEC_div_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_NEC_group_2:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	NEC_g2_Metafunc_8
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_2
	dc.l	NEC_div_Pause
	dc.l	NEC_div_Resume
	dc.l	NEC_div_PlayMSF
	dc.l	NEC_div_PlayTrkInd
	dc.l	NEC_div_ReadTocHdr
	dc.l	NEC_div_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	NEC_div_CDRomEject
	dc.l	fctl_E_OK_1
	dc.l	NEC_div_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	NEC_div_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	NEC_div_GetMcn
	dc.l	NEC_div_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_NEC_group_3:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	gen_E_OK_1
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_2
	dc.l	NEC_div_Pause
	dc.l	NEC_div_Resume
	dc.l	NEC_div_PlayMSF
	dc.l	NEC_div_PlayTrkInd
	dc.l	NEC_div_ReadTocHdr
	dc.l	NEC_div_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	NEC_div_CDRomEject
	dc.l	fctl_E_OK_1
	dc.l	NEC_div_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	NEC_div_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	NEC_div_GetMcn
	dc.l	NEC_div_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_PIONEER_group_1:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	COMMON_Metafunc_8
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	fctl_PlayTrkInd
	dc.l	fctl_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	fctl_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_GetMcn
	dc.l	fctl_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_SONY_group_2:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	gen_E_OK_1
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	SONY_PlayTrkInd
	dc.l	div_1_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	fctl_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_GetMcn
	dc.l	fctl_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_SONY_CDU_8002:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	gen_E_OK_1
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	CDU_8002_Pause
	dc.l	CDU_8002_Resume
	dc.l	CDU_8002_PlayMSF
	dc.l	CDU_8002_PlayTrkInd
	dc.l	CDU_8002_ReadTocHdr
	dc.l	CDU_8002_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	CDU_8002_VolCtrl
	dc.l	CDU_8002_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	CDU_8002_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	CDU_8002_GetMcn
	dc.l	CDU_8002_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_COMMON_group_1:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	COMMON_Metafunc_8
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	SONY_PlayTrkInd
	dc.l	fctl_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	fctl_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_GetMcn
	dc.l	fctl_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_COMMON_DM_XX24:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	gen_E_OK_1
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	SONY_PlayTrkInd
	dc.l	fctl_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	fctl_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_GetMcn
	dc.l	fctl_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_TOSHIBA_group_1:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	TOSHIBA_g1_Metafunc_8
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	fctl_PlayTrkInd
	dc.l	fctl_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	fctl_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_GetMcn
	dc.l	fctl_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_TOSHIBA_XM_3301:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	XM_3301_Metafunc_8
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	fctl_Pause
	dc.l	fctl_Resume
	dc.l	fctl_PlayMSF
	dc.l	fctl_PlayTrkInd
	dc.l	fctl_ReadTocHdr
	dc.l	fctl_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	fctl_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	fctl_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_GetMcn
	dc.l	fctl_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_TOSHIBA_XM_3201:
	dc.l	$15FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	gen_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_Metafunc_5
	dc.l	gen_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	gen_E_OK_1
	dc.l	gen_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	fctl_CDRomStop
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
	dc.l	fctl_E_INVFN_1
	dc.l	XM_3201_Pause
	dc.l	XM_3201_Resume
	dc.l	XM_3201_PlayMSF
	dc.l	XM_3201_PlayTrkInd
	dc.l	XM_3201_ReadTocHdr
	dc.l	XM_3201_ReadTocEntry
	dc.l	fctl_CDRomStop
	dc.l	fctl_CDRomStart
	dc.l	XM_3201_CDRomEject
	dc.l	fctl_VolCtrl
	dc.l	XM_3201_SubChnl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_PreventRemoval
	dc.l	fctl_AllowRemoval
	dc.l	fctl_AudioCtrl
	dc.l	fctl_E_INVFN_2
	dc.l	fctl_E_INVFN_2
	dc.l	XM_3201_GetMcn
	dc.l	XM_3201_GetTisrc
;
;----------------------------------------------------------------------------
;
func_t_ATARI_CDAR_504:
	dc.l	$00FFFFFF
	dc.l	gen_Metaopen
	dc.l	gen_Metaclose
	dc.l	CDAR_Metaread
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	CDAR_Metastatus
	dc.l	gen_E_INVFN_1
	dc.l	CDAR_E_OK_1
	dc.l	CDAR_Metafunc_9
	dc.l	gen_E_UNCMD_1
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
	dc.l	gen_E_UNCMD_2
;
;----------------------------------------------------------------------------
;
D_39B6:	dc.b	$0,$0,$0,$0,'ÿþÿüÿôÿûÿþÿù'
D_39C6:	dc.b	$11,$12,$12,$13
D_39CA:	dc.b	$11,$12,$11,$13,$14,$15,$0,$0
;
CD_ROM_s:		dc.b	'CD-ROM',$0
machine_flags_t:	dc.b	$1,$1,$3,$6	;flags	ST,STE,TT,Falcon
invalid_option_s:	dc.b	'Invalid option: using default ',NUL
option_T_EQ_0_s:	dc.b	'T=0',CR,LF,NUL
option_D_omitted_s:	dc.b	'D= (omitted)',CR,LF,NUL
option_L_EQ_16_s:	dc.b	'L=16',CR,LF,NUL
;
D_3A18:	dc.w	-1
D_3A1A:	dc.w	-1
max_trace:		dc.l	0
D_3A20:	dc.l	-1
D_3A24:	dc.l	-1
D_3A28:	dc.l	-1
D_3A2C:	dc.w	0
D_3A2E:	dc.w	0
;
;----------------------------------------------------------------------------
;
	SECTION	BSS
;
;----------------------------------------------------------------------------
;
machine_f:	ds.w	1	;highbyte flags:  ST/STE=>1  TT=>3  Falcon=>6
machine_type:	ds.w	1	;
new_cpu_f:	ds.w	1	;
fastram_buf_p:	ds.l	1	;
B_3A3A:	ds.l	1			;=4
B_3A3E:	ds.l	1			;=4
;
BOS_table_p:	ds.l	1
BOS_table_beg:	ds.b	MAX_BOS_ENTRIES*bos_table_size
BOS_table_end:
;
SCSI_cmdbuf_1:	ds.b	16
SCSI_cmdbuf_2:	ds.b	16
B_3C46:	ds.l	1			;=4
B_3C4A:	ds.l	1			;=4
B_3C4E:	ds.l	1			;=4
;
CD_sector_buf:	ds.b	1	;start of standard 2048 byte CD sector
B_3C53:		ds.b	1
B_3C54:		ds.w	1
B_3C56:		ds.b	1
B_3C57:		ds.b	3
B_3C5A:		ds.w	1
B_3C5C:		ds.l	1
B_3C60:		ds.w	3
B_3C66:		ds.b	2028			;=2028
extra_buf:	ds.b	512	;extra space for non-standard sectors
;
;----------------------------------------------------------------------------
;
	END
;
;----------------------------------------------------------------------------
;End of file:	CD_mACSI.S
;----------------------------------------------------------------------------
