;----------------------------------------------------------------------------
;File name:	NEWSTUFF.S			Revision date:	1999.10.03
;Revised by:	Ulf Ronald Andersson		Disassembled:	1995.07.29
;Revision:	1.5
;----------------------------------------------------------------------------
	output	.ACC
;----------------------------------------------------------------------------
	include	RA_SIM.I
	include	RA_JAR.I
	include	RA_XGEM.I
	include	RA_LA.I
;-------
	include	NEWSTUFF.I
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
rz:	;relative reference zero point
start:
	bra	new_init_1
;----------------------------------------------------------------------------
;Start of:	Revision data area
;----------------------------------------------------------------------------
no_cookie_f:	ds.w	1
autostuff_p:	ds.l	1
open_shifts:	dc.w	$0B
open_hotkey:	dc.l	-($0A0060)
cycle_time:	dc.l	500
hotkey_code:	dc.l	0
hotkey_flag:	dc.l	0
t_null_s:	dc.w	0
t_bootdev	ds.w	1
t_la_base_p:	ds.l	1
t_keytbl_ptp:	ds.l	1
t_kb_iorec_p:	ds.l	1
old_tail_ix:	ds.w	1
t_kbshift_p:	ds.l	1
t_basepage_p:	ds.l	1
t_currbp_p_p:	ds.l	1
new_currbp_p:	ds.l	1
old_currbp_p:	ds.l	1
temp_reg_1:	ds.l	1
framesize:	ds.w	1
longframe_f:	ds.w	1
ACC_flag:	ds.w	1
boot_flag:	dc.w	1	;NE until all ACCs booted, MI until each appl_init
registered_f:	dc.w	0
cmd_kb_f:	dc.w	0
cmd_timer_f:	ds.w	1
no_load_f:	ds.w	1
ACC_active_f:	ds.w	1
vector_err_f:	ds.l	1	;NB: LONG flag <0 == or'ed error incication
text_attribute:	ds.w	10	;cell width at offset 16, height at offset 18
about_size:	ds.w	2
stuff_size:	ds.w	2
boot_size:	ds.w	2
XGEM_linked_p:	dc.l	-1
XGEM_wanted_p:	dc.l	nu_XGEM
;
no_cookie_s:
	dc.b	CR,LF
	dc.b	CR,LF
	dc.b	'The "Stuf" cookie is missing...!',CR,LF
	dc.b	'Please install "AutoStuf.Prg" in',CR,LF
	dc.b	'your \AUTO folder and reboot.',CR,LF
	dc.b	CR,LF
	dc.b	NUL
	even
;
ACC_extras_al_s:
	dc.b	'[0]['
	dc.b	' "Reload" erases stuffed ACCs|'
	dc.b	' and then reloads  \STUFFER\.|'
	dc.b	' This works  with clean ACCs,|'
	dc.b	' may fail with  rulebreakers.|'
	dc.b	' "Erase" allows rez  changes.]'
	dc.b	'[ Reload | Cancel |  Erase  ]',NUL
	even
;
APP_extras_al_s:
	dc.b	'[0]['
	dc.b	' "Reload" erases stuffed ACCs|'
	dc.b	' and then reloads  \STUFFER\.|'
	dc.b	' This works  with clean ACCs,|'
	dc.b	' may fail with  rulebreakers.|'
	dc.b	' "Desktop" exits the program.]'
	dc.b	'[ Reload | Cancel | Desktop ]',NUL
	even
;
stuff_regs_t:
	ds.l	16
;
ACC_regs_t:
	ds.l	32*16
;
ACC_regs_tpt:
.trt:	= ACC_regs_t
	dc.l	.trt+00*16*4,.trt+01*16*4,.trt+02*16*4,.trt+03*16*4
	dc.l	.trt+04*16*4,.trt+05*16*4,.trt+06*16*4,.trt+07*16*4
	dc.l	.trt+08*16*4,.trt+09*16*4,.trt+10*16*4,.trt+11*16*4
	dc.l	.trt+12*16*4,.trt+13*16*4,.trt+14*16*4,.trt+15*16*4
	dc.l	.trt+16*16*4,.trt+17*16*4,.trt+18*16*4,.trt+19*16*4
	dc.l	.trt+20*16*4,.trt+21*16*4,.trt+22*16*4,.trt+23*16*4
	dc.l	.trt+24*16*4,.trt+25*16*4,.trt+26*16*4,.trt+27*16*4
	dc.l	.trt+28*16*4,.trt+29*16*4,.trt+30*16*4,.trt+31*16*4
;----------------------------------------------------------------------------
;End of:	Revision data area
;----------------------------------------------------------------------------
boot_ACC_count:		dc.w	-1
pexec_ACC_count:	dc.w	-1
;
stuff_null_s:	dc.b	NUL,NUL
position_ESC_s:	dc.b	ESC,'H',ESC,'Y-'
pos_esc_col_s:	dc.b	'>',NUL,NUL
stuff_path_s:	dc.b	'A:\STUFFER\'
stuff_name_s:	ds.b	15
	even
;----------------------------------------------------------------------------
t_clrblk_t:
	dc.l	t_clrblk_1,t_clrblk_1_end
	dc.l	r_clrblk_2,r_clrblk_2_end
	dc.l	r_clrblk_3,r_clrblk_3_end
	dc.l	r_clrblk_4,r_clrblk_4_end
	dc.l	t_clrblk_5,t_clrblk_5_end
	dc.l	NUL
;
t_clrblk_1:
ACC_index_1:		dc.w	0
ACC_event_flag:		dc.w	0
Stuffer_USP:		dc.l	0
ACC_iop_ai_t_p:		dc.l	0
ACC_vwk_f_p:		dc.l	0
ACC_event_flag_t_p:	dc.l	0
ACC_USP_t_p:		dc.l	0
ACC_timeout_t_p:	dc.l	0
ACC_loc_t_p:		dc.l	0
ACC_RAM_base_p:		dc.l	0
ACC_RAM_end_p:		dc.l	0
ACC_intin_p_t_p:	dc.l	0
open_wind_t_p:		dc.l	0
t_clrblk_1_end:
;
menu_reg_ACC_count:	dc.w	1
;----------------------------------------------------------------------------
;Start of:	Initialization routine
;----------------------------------------------------------------------------
new_init_1:
	move.l	a0,d0			;d0 -> basepage of ACC, or is NULL
	sne	ACC_flag		;ACC_flag = $FF(ACC), $00(non-ACC)
	bne.s	.have_basepage_p
	move.l	4(sp),d0		;d0 -> basepage of non-ACC
.have_basepage_p:
	move.l	d0,a5			;a5 ->basepage
	move.l	a5,t_basepage_p		;store basepage_p
	movea.l	bp_bss_beg_p(a5),a0	;a0 -> BSS base == Data limit
	movea.l	a0,a1
	adda.l	bp_bss_len(A5),A1	;A1 -> BSS limit
	move.l	bp_datalen(A5),D0
	subq.l	#1,D0
T_36:
	move.b	-(A0),-(A1)		;move data area to top of BSS
	dbra	D0,T_36
T_3C:
;
	movea.l bp_databeg_p(A5),A0
	move.l	bp_bss_len(A5),D0
	subq.l	#1,D0
T_46:
	clr.b	(A0)+			;erase bss_len bytes at former data base
	dbra	D0,T_46
;
;Here the original DATA and BSS areas have switched places
;Later a4 -> new data base, beyond new BSS, and will be used for most references
;using positive indexes for DATA constants and negative ones for stack & variables
;
	movea.l	bp_databeg_p(A5),A4
	adda.l	bp_bss_len(A5),A4	;a4 -> new data base, beyond new BSS
	move.l	A5,basepage_p(A4)	;store -> basepage in top of new BSS
	lea	basepage_p(A4),SP	;setup local stack below that
;
	tst	ACC_flag
	bne.s	.done_shrink
	movea.l	bp_bss_beg_p(A5),A1
	adda.l	bp_bss_len(A5),A1	;a1 -> old BSS limit == new DATA limit
	sub.l	t_basepage_p(pc),a1	;a1 == total RAM size
	gemdos	Mshrink,!,(a5),a1	;release unwanted RAM
.done_shrink:
;
	xbios	Supexec,eval_stuf_cookie
	move.l	autostuff_p(pc),d0
	bpl.s	.done_cookie
	gemdos	Cconws,no_cookie_s
	st	no_cookie_f
.done_cookie:
	movea.l	bp_textbeg_p(A5),A5	;a5 -> program, for pseudo-relative references
;
	xbios	Supexec,init_revision
;
	bsr	main			;this sub never returns !!!
	illegal
;
eval_stuf_cookie:
	eval_cookie	#'Stuf'
	move.l		d0,autostuff_p
	rts
;----------------------------------------------------------------------------
;End of:	Initialization routine
;----------------------------------------------------------------------------
T_200:	link	A6,#0
	movem.l	D6-D7/A3,-(SP)
	move.l	8(A6),D7
	move	12(A6),D6
	movea.l	14(A6),A3
	lea	2(A3),A0
	move.l	A0,-(SP)
	lea	(A3),A0
	move.l	A0,-(SP)
	move	D6,-(SP)
	move.l	D7,-(SP)
	jsr	objc_offset_sub(PC)
	adda	#14,SP
	move.l	D7,D0
	move	D6,D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D0
	add.l	#$14,D0
	movea.l	D0,A0
	move	(A0),D0
	move	D0,4(A3)
	move.l	D7,D0
	move	D6,D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D0
	add.l	#$16,D0
	movea.l	D0,A0
	move	(A0),D0
	move	D0,6(A3)
	movem.l	(SP)+,D6-D7/A3
	unlk	A6
	rts
;----------------------------------------------------------------------------
T_266:
	link	A6,#-$10
	movem.l	D4-D7,-(SP)
	move.l	8(A6),D7
	move	12(A6),D6
	pea	-$8(A6)
	clr	-(SP)
	move.l	D7,-(SP)
	jsr	T_200(PC)
	adda	#10,SP
	move.l	D7,D5
	move	D6,D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D5
	add.l	#10,D5
	movea.l	D5,A0
	move	(A0),D5
	move	D5,D4
	move	#1,D3
	eor	D3,D4
	move	#1,-(SP)
	move	D4,-(SP)
	move	-$2(A6),-(SP)
	move	-$4(A6),-(SP)
	move	-$6(A6),-(SP)
	move	-$8(A6),-(SP)
	clr	-(SP)
	move	D6,-(SP)
	move.l	D7,-(SP)
	jsr	objc_change_sub(PC)
	adda	#$14,SP
	movem.l	(SP)+,D4-D7
	unlk	A6
	rts
;----------------------------------------------------------------------------
T_2D0:
	link	A6,#0
	movem.l	D6-D7,-(SP)
	move.l	8(A6),D7
	move	12(A6),D6
	move.l	D7,D0
	move	D6,D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D0
	add.l	#10,D0
	movea.l	D0,A0
	move	(A0),D0
	and	#1,D0
	bne.s	.T_308
	move	D6,-(SP)
	move.l	D7,-(SP)
	jsr	T_266(PC)
	addq	#6,SP
.T_308:	movem.l	(SP)+,D6-D7
	unlk	A6
	rts
;----------------------------------------------------------------------------
T_310:
	link	A6,#0
	movem.l	D6-D7,-(SP)
	move.l	8(A6),D7	;d7 -> tree
	move	12(A6),D6	;d6 =  obj
	move.l	D7,D0		;d0 =  d7 -> tree
	move	D6,D1		;d1 =  d6 =  obj
	muls	#24,D1
	ext.l	D1
	add.l	D1,D0		;d0 -> obj base
	add.l	#10,D0		;d0 -> obj status
	movea.l	D0,A0		;A0 -> obj status
	move	(A0),D0		;d0 =  obj status
	and	#SELECTED,D0	;selected obj ?
	beq.s	.T_348
	move	D6,-(SP)
	move.l	D7,-(SP)
	jsr	T_266(PC)
	addq	#6,SP
.T_348:	movem.l	(SP)+,D6-D7
	unlk	A6
	rts
;----------------------------------------------------------------------------
T_350:	link	A6,#-$3E
	movem.l	D4-D7/A3,-(SP)
	move.l	8(A6),D7	;d7 -> tree
	clr	-10(A6)
	clr	-$2A(A6)
	movea.l	12(A6),A0
	move	(A0),D0
	move	D0,-$2E(A6)
	move	D0,-$30(A6)
	move	#0,D4
	move	D4,D5
T_5FC:
	pea	-6(A6)			;y
	pea	-8(A6)			;x
	pea	-10(A6)			;butt
	move	wk_handle(a4),-(SP)
	jsr	vq_mouse_sub(PC)
	adda	#14,SP
	move	-$6(A6),D0
	cmp	workscreen_y(A4),D0
	bge.s	.T_3AC
	move.l	D7,D0			;d0 = d7 -> tree
	move.l	stuff_tree_p(a4),D1
	cmp.l	D1,D0
	beq.s	.T_3B6
.T_3AC:	cmpi	#2,-$A(A6)		;right butt ?
	bne.s	.T_3CA
.T_3B6:	move	-$4(A6),-(SP)
	move.l	D7,-(SP)
	jsr	T_310(PC)
	addq	#6,SP
	move	#$5555,D0
	bra	.exit
;------------------------------------
.T_3CA:
	clr	-$2A(A6)
	cmpi	#1,-$A(A6)		;left butt ?
	bne.s	.T_3E2
	move	#2,-$2A(A6)
.T_3E2:	move	-6(A6),-(SP)		;y
	move	-8(A6),-(SP)		;x
	move	#8,-(SP)		;depth 8
	clr	-(SP)			;start 0
	move.l	D7,-(SP)		;same tree
	jsr	objc_find_sub(PC)
	adda	#12,SP
	move	D0,-$2(A6)
	cmpi	#-1,-$2(A6)		;hit any object ?
	bne.s	.T_440			;if so, go T_440
	clr	-2(A6)			;hit_obj = 0
	cmpi	#1,-$A(A6)		;left butt ?
	bne.s	.T_440			;if not, go T_440
	move.l	D7,D0			;d0 = d7 -> tree
	move.l	stuff_tree_p(a4),D1
	cmp.l	D1,D0
	bne.s	.T_42E
	move	#$5555,D0
	bra	.exit
;------------------------------------
.T_42E:
	sub_bios	Bconout,#2,#7	;BELL !!!
;
.T_440:
	move.l	D7,D6		;d6 = d7 -> tree
	move	-2(A6),D1
	muls	#24,D1		;d1 = hit obj * 24
	ext.l	D1
	add.l	D1,D6
	addq.l	#8,D6
	movea.l	D6,A0		;a0 -> flags of hit obj
	move	(A0),D6		;d6 =  flags of hit obj
	move	-4(A6),D0
	cmp	-2(A6),D0	;hit obj = d0 ?
	beq.s	.T_47E
	move	D4,D0
	beq.s	.T_472
	move	-4(A6),-(SP)
	move.l	D7,-(SP)
	jsr	T_310(PC)
	addq	#6,SP
.T_472:	move	-2(A6),-$4(A6)
	move	#0,D4
	move	D4,D5
.T_47E:	move	D6,D0
	and	#$80,D0
	bne	T_5FC
	move	D6,D0
	and	#1,D0
	bne.s	.T_4A6
	move	D6,D0
	and	#$40,D0
	bne.s	.T_4A6
	move	D6,D0
	and	#8,D0
	beq	T_5FC
.T_4A6:	move.l	D7,D0
	move	-$2(A6),D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D0
	add.l	#10,D0
	movea.l	D0,A0
	move	(A0),D0
	move	D0,-$C(A6)
	pea	-$3C(A6)
	clr	-(SP)
	move.l	D7,-(SP)
	jsr	T_200(PC)
	adda	#10,SP
	move	-$C(A6),D0
	and	#8,D0
	bne.s	.T_512
	move	D6,D0
	and	#8,D0
	bne.s	.T_512
	move	-$C(A6),D0
	and	#1,D0
	bne.s	.T_508
	move	-$2(A6),-(SP)
	move.l	D7,-(SP)
	jsr	T_2D0(PC)
	addq	#6,SP
	move	#1,D4
	bra.s	.T_512
;------------------------------------
.T_508:	move	D4,D0
	bne.s	.T_512
	move	#1,D5
.T_512:	move	-$2A(A6),D0
	and	#2,D0
	beq	T_5FC
	move	-$2(A6),D0
	beq	T_5FC
	move	-$6(A6),-(SP)
	move	-$8(A6),-(SP)
	move	#8,-(SP)
	clr	-(SP)
	move.l	D7,-(SP)
	jsr	objc_find_sub(PC)
	adda	#12,SP
	move	D0,-$2E(A6)
	cmpi	#-$1,-$2E(A6)
	bne.s	.T_568
	clr	-$2E(A6)
	move.l	D7,D0
	move.l	stuff_tree_p(a4),D1
	cmp.l	D1,D0
	bne.s	.T_5AA
	move	#$5555,D0
	bra	.exit
;------------------------------------
.T_568:	move.l	D7,D0
	move	-$2E(A6),D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D0
	add.l	#10,D0
	movea.l	D0,A0
	move	(A0),D0
	and	#8,D0
	beq.s	.T_58C
	clr	-$2E(A6)
.T_58C:	pea	-$2(A6)
	pea	-$2E(A6)
	move	-$28(A6),-(SP)
	move	-$2E(A6),-(SP)
	move.l	D7,-(SP)
	jsr	T_60C(PC)
	adda	#$10,SP
	move	D0,-$2C(A6)
.T_5AA:	move	-$2C(A6),D0
	bne	T_5FC
	move.l	D7,D0
	move	-$2(A6),D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D0
	add.l	#10,D0
	movea.l	D0,A0
	move	(A0),D0
	move	D0,-$C(A6)
	move	-$C(A6),D0
	and	#1,D0
	beq.s	.T_5EC
	move	D4,D0
	bne.s	.T_5EC
	move	-$2E(A6),-(SP)
	move.l	D7,-(SP)
	jsr	T_310(PC)
	addq	#6,SP
.T_5EC:	movea.l	12(A6),A0
	move	-$30(A6),(A0)
	move	-$2E(A6),D0
.exit:
	movem.l	(SP)+,D4-D7/A3
	unlk	A6
	rts
;----------------------------------------------------------------------------
T_60C:	link	A6,#-$10
	movem.l	D5-D7/A2-A3,-(SP)
	move.l	8(A6),D7
	move	12(A6),D6
	move	14(A6),D5
	movea.l	$10(A6),A3
	movea.l	$14(A6),A2
	move.l	D7,D0
	move	D6,D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D0
	addq.l	#8,D0
	movea.l	D0,A0
	move	(A0),D0
	move	D0,-$2(A6)
	move.l	D7,D0
	move	D6,D1
	muls	#$18,D1
	ext.l	D1
	add.l	D1,D0
	add.l	#10,D0
	movea.l	D0,A0
	move	(A0),D0
	move	D0,-$4(A6)
	move	-$2(A6),D0
	and	#$40,D0
	move	D0,-$6(A6)
	move	-$2(A6),D0
	and	#1,D0
	move	D0,-$8(A6)
	move	-$4(A6),D0
	and	#8,D0
	move	D0,-$A(A6)
	move	-$2(A6),D0
	and	#8,D0
	move	D0,-$C(A6)
	move	-$6(A6),D0
	bne.s	T_6B2
	move	-$8(A6),D0
	beq.s	T_6A0
	move	-$A(A6),D0
	beq.s	T_6B2
T_6A0:	move	-$C(A6),D0
	bne.s	T_6B2
	clr	(A3)
	move	#1,D0
	bra	T_750
;------------------------------------
T_6B2:	move	-$8(A6),D0
	beq.s	T_718
	move	-$A(A6),D0
	bne.s	T_718
	move	-$6(A6),D0
	bne.s	T_718
	move	D6,D0
	cmp	(A2),D0
	bne.s	T_6DA
	move	-$4(A6),D0
	bra.s	T_6E4
;------------------------------------
T_6DA:	move	-$4(A6),D0
	move	#1,D3
	eor	D3,D0
T_6E4:	move	D0,-$10(A6)
	move	-$10(A6),D0
	move	#1,D3
	eor	D3,D0
	move	D0,-(SP)
	move	-$10(A6),-(SP)
	move	D6,-(SP)
	move.l	D7,-(SP)
	jsr	graf_watchbox_sub(PC)
	adda	#10,SP
	tst	D0
	bne.s	T_718
	clr	(A3)
	move	#-$1,(A2)
	move	#1,D0
	bra.s	T_750
;------------------------------------
T_718:
	move	D6,D0
	cmp	(A2),D0
	bne.s	T_724
	move	#-$1,(A2)
T_724:
	move	-$2(A6),D0
	and	#4,D0
	beq.s	T_73E
	move	D6,(A3)
	move	#0,D0
	bra.s	T_750
;------------------------------------
	bra.s	T_748
;------------------------------------
T_73E:
	move	-$C(A6),D0
	bne.s	T_748
	clr	(A3)
T_748:
	move	#1,D0
	bra	T_750
;------------------------------------
T_750:	movem.l	(SP)+,D5-D7/A2-A3
	unlk	A6
	rts
;----------------------------------------------------------------------------
;Start of:	'task_handler' for stuffer ACCs
;----------------------------------------------------------------------------
task_handler:
	gemdos	Super,1.w
	tst	d0
	beq.s	.force_super
	move	sr,-(SP)
	bra.s	.T_782
;
.force_super:
	move.l	(sp)+,d0		;d0 = popped return address
	tst	longframe_f
	beq.s	.adapted_CPU_1
	clr	-(sp)			;reserve frame_type for new CPUs
.adapted_CPU_1:
	move.l	d0,-(sp)		;store d0 as frame return address
	subq	#2,sp			;reserve 2 bytes for frame SR
	move.l	sp,temp_reg_1		;store -> frame on 'user' stack
;
	gemdos	Super,!			;set 'super' state, get d0 = old_SSP
;
	move	sr,d1			;save interrupt mask
	ori	#$0700,sr		;disable interrupts
	move.l	d0,SP			;force SSP = old_SSP
	move.l	temp_reg_1(pc),a0	;a0 -> frame on 'user' stack
	move	d1,(a0)			;store old interrupt mask in frame SR
	bclr	#5,(a0)			;store old 'user' state in frame SR
	move.l	a0,usp			;force usp -> frame
	bra.s	.T_792
;Now return address at entry (USP) is replaced by similar trap frame at new (USP)
;------------------------------------
.T_782:
	move	sr,d1
	ori	#$700,sr
	move	usp,A0			;a0 = old USP
	tst	longframe_f		
	beq.s	.adapted_CPU_2
	clr	-(a0)			;reserve frame_type for new CPUs
.adapted_CPU_2:
	move.l	2(SP),-(A0)		;transfer frame return address
	move	(SP)+,-(A0)		;transfer (popping) frame SR
	addq	#4,SP			;pop return address from (SSP)
	move.l	a0,usp			;force usp -> frame
;Now return address at entry (SSP) is replaced by similar trap frame at new (USP)
.T_792:
;Here we have SUPER mode, with USP -> return frame, SSP = pre_call SSP
;Also, all interrupts are disabled, d1 = entry SR with SUPER bit forced set
;
	move	d1,sr		;restore interrupt mask
	move	sr,d2
	move	task_job(a4),D0
	cmpi	#3,D0
	beq	do_task_job_3	;job 3 => interactive ACC_jobs
	cmpi	#2,D0
	beq	do_task_job_2	;job 2 => mark boot completed
	cmpi	#1,D0
	beq	do_task_job_1	;job 1 => boot all stuffer ACCs
	cmpi	#4,D0
	beq	do_task_job_4	;job 4 => Not implemented (NOP)
	tst	d0
	beq	do_task_job_0	;job 0 => prepare for boot
;
;Here assume task_job 0 == prepare for boot
;
do_task_job_0:			;job 0 => prepare for boot
	lea	ACC_iop_ai_t(A4),A0
	lea	ACC_iop_ai_t_p(PC),A1
	move.l	A0,(A1)
	lea	ACC_USP_t(A4),A0
	lea	ACC_USP_t_p(PC),A1
	move.l	A0,(A1)
	lea	ACC_title_spt(PC),A0
	lea	next_ACC_title_spp(PC),A1
	move.l	A0,(A1)
	lea	ACC_vwk_f(A4),A0
	lea	ACC_vwk_f_p(PC),A1
	move.l	A0,(A1)
	lea	ACC_event_flag_t(A4),A0
	lea	ACC_event_flag_t_p(PC),A1
	move.l	A0,(A1)
	lea	ACC_timeout_t(A4),A0
	lea	ACC_timeout_t_p(PC),A1
	move.l	A0,(A1)
	lea	ACC_loc_t(a4),A0
	lea	ACC_loc_t_p(PC),A1
	move.l	A0,(A1)
	lea	ACC_intin_p_t(A4),A0
	lea	ACC_intin_p_t_p(PC),A1
	move.l	A0,(A1)
	lea	open_wind_t(A4),A0
	lea	open_wind_t_p(PC),A1
	move.l	A0,(A1)
	move	t_bootdev,D0
	add.b	#'A',d0
	move.b	d0,stuff_path_s
;
	xbios	Getrez
;
	tst	D0
	bne	task_handler_exit
	lea	pos_esc_col_s(PC),A0
	move.b	#$2A,(A0)		;adjust VT52 esc sequence positioning cursor
	bra	task_handler_exit
;------------------------------------
do_task_job_1:			;job 1 => boot all stuffer ACCs
	move	d2,sr
	lea	boot_ACC_count(PC),A0
	addq	#1,(A0)
.try_next_ACC:
	cmp	#2,registered_f
	bne.s	.T_884
	subq	#1,(A0)
	move	(A0),D0
	lsl	#3,D0
	lea	ACC_index_1(PC),A0
	subq	#1,(A0)
	movea.l	ACC_loc_t_p(PC),A0
;
	gemdos	Mfree|_ind,<(a0,d0)>
;
.T_884:
	clr	registered_f
	clr	ACC_event_flag
	lea	position_ESC_s(PC),A0
	bsr	copyshow_stuff_name
	lea	twelve_space_s(A4),A0
	bsr	copyshow_stuff_name
	lea	twelve_space_s(A4),A0
	bsr	copyshow_stuff_name
	lea	position_ESC_s(PC),A0
	bsr	copyshow_stuff_name
;
	gemdos	Malloc,?
;
	cmp.l	#$20000,D0
	bls	break_boot
;
	bsr	kbshift_plus
;
	btst	#0,D0
	bne	break_boot
	lea	pexec_ACC_count(PC),A0
	addq	#1,(A0)
	move	pexec_ACC_count(PC),D0
	cmp	ACC_count(A4),D0
	beq	break_boot
	lsl.w	#4,D0
	lea	ACC_name_t(A4),A0
	adda	D0,A0
	bsr	copyshow_stuff_name
	bsr	enter_system
	gemdos	Pexec,#3,stuff_path_s(pc),stuff_null_s(pc),!
	bsr	exit_system
	tst.l	D0
	bmi	.try_next_ACC
	movea.l	D0,A0			;a0 = d0 -> ACC basepage
	lea	$100.w,A1
	adda.l	bp_textlen(A0),A1
	adda.l	bp_datalen(A0),A1
	adda.l	bp_bss_len(A0),A1	;a1 = needed RAM size
	adda	#$200,a1		;reserve 512 bytes extra for initial stack
;
	movea.l	ACC_loc_t_p(PC),A0
	move	boot_ACC_count(PC),D1
	lsl.w	#3,D1
	adda	D1,A0
	move.l	D0,(A0)+		;table -> basepage
	move.l	A1,(A0)			;table RAM size
;
	move.l	d0,a0
	pea	(a0,a1.l)		;push -> RAM limit of ACC
	move.l	(sp)+,bp_selfend_p(a0)	;selfend_p -> RAM limit of ACC
;
	clr.l	bp_parent_p(a0)
;
	move.l	D0,-(sp)		;push -> ACC basepage
	bsr	enter_system
	gemdos	Mshrink|_ind,!,d0,a1	;shrink RAM to needed size
	bsr	exit_system
	move.l	(sp)+,D1		;d1 -> ACC basepage			Final D1
	tst.l	D0			;RAM shrunk ok ?
	bne	.try_next_ACC
;
	move	sr,D2			;d2 = interrupt mask
	ori	#$700,sr		;disable interrupts
	move	usp,A1				;a1 = USP
	move.l	A1,Stuffer_USP			;store stuffer USP
	movem.l	D2-D7/A2-A7,stuff_regs_t	;store stuffer regs (d2 == SR)
	andi	#$D8FF,D2		;d2 = sr for ACC start			FINAL D2
;
	movea.l	D1,A0			;a0 = d1 -> ACC basepage
	lea	$100(A0),A1		;a1 -> ACC text area			FINAL A1
	movea.l	bp_selfend_p(A0),A0	;a0 -> RAM limit (above ACC stack)
	move.l	D1,-(A0)		;push -> ACC basepage via a0
	clr.l	-(A0)			;push long zero
	move	A0,usp			;ACC usp = a0
;
	tst	longframe_f	;\
	beq.s	.CPU_adapted	; \
	clr	-(sp)		;  \/ Push an exception stack frame
.CPU_adapted:			;  /\ leading to ACC start with correct SR
	move.l	A1,-(SP)	; /		-> ACC start
	move	D2,-(SP)	;/		SR
;
; The space saved above is used here to fix A0 as modern standards require
;
	move.l	d1,a0			;a0 -> basepage  (original missed this !!!)
	st	boot_flag		;set top byte of boot_flag for new ACC start
	st	ACC_active_f
	rte				;exit to ACC !!!
;------------------------------------
break_boot:
	move	boot_ACC_count(PC),ACC_count(A4)
	bra.s	task_handler_exit
;------------------------------------
;During task_job 1, we are sent here by 'nu_XGEM'
;when each stuffer ACC calls the event handler.
;So we must then proceed to load the rest of the ACCs,
;or return to the caller when all are loaded.
;We also come here in similar fashion later when
;activated ACCs call the event handler, and we must
;then return to the main multi_task_loop.
;
task_reentry:
	sf	ACC_active_f
	movea.l	Stuffer_USP(PC),A0
	move	A0,usp				;restore stuffer USP
	movem.l	stuff_regs_t,D2-D7/A2-A7	;restore stuffer regs (d2 == SR)
	move	boot_flag(PC),D0
	bne	do_task_job_1
task_handler_exit:
	ori	#$700,sr
	move	usp,A1			;a1 -> return frame at stuffer USP
	tst	longframe_f
	beq.s	.CPU_adapted
	move	6(a1),-(sp)		;transfer frame type to -(SSP)
.CPU_adapted:
	move.l	2(a1),-(sp)		;transfer return address to -(SSP)
	move	(a1),-(sp)		;transfer frame SR to -(SSP)
	add	framesize(pc),a1	;a1 = stuffer USP after popping frame
	move	a1,usp			;activate popped stuffer USP
	rte				;exit to multi_tasker
;----------------------------------------------------------------------------
copyshow_stuff_name:
	move.l	A0,-(SP)
	lea	stuff_name_s(PC),A1
.T_9E2:	move.b	(A0)+,(A1)+
	bne	.T_9E2
	gemdos	Cconws,()
	rts
;----------------------------------------------------------------------------
do_task_job_2:				;mark boot completed
	clr	boot_flag		;clear boot flag
	bra	task_handler_exit
;------------------------------------
do_task_job_4:				;not yet implemented (NOP)
	movem.l	D3-D6/A6,-(SP)
;
;patch job here
;
	movem.l	(SP)+,D3-D6/A6
	bra	task_handler_exit
;------------------------------------
do_task_job_3:				;interactive ACC_jobs
	move	sr,d2			;d2 = super SR with needed interrupt mask
	ori	#$700,sr
	move	#1,registered_f
	move	ACC_current(a4),D0
	move	D0,ACC_index_1		;ACC_index_1 = ACC_current
	lsl	#1,D0
	movea.l	ACC_event_flag_t_p(PC),A0
	lea	ACC_event_flag(PC),A1
	move	(A0,D0),(A1)
	cmpi	#$50,(A1)		;timer event ?
	beq.s	T_A6C
	movea.l	ACC_iop_ai_t_p(PC),A0
	lsl	#2,D0
	adda	D0,A0
	movea.l	(A0)+,A1		;a1 -> intout of ACC
	move	event_flags_2(a4),(A1)+
	move	evm_xpos(A4),(A1)+
	move	evm_ypos(A4),(A1)+
	move	evm_butt(A4),(A1)+
	move	evm_kbsh(A4),(A1)+
	move	evm_key(A4),(A1)+
	move	evm_clct(A4),(A1)+
	movea.l	(A0),A1			;a1 = addrin[0] of ACC
	moveq	#(16/2)-1,D0
	lea	mesag_buf_2(a4),A0
.fix_mesag_loop:
	move	(A0)+,(A1)+		;copy message to buffer of ACC
	dbra	D0,.fix_mesag_loop
T_A6C:
	move	usp,A1
	move.l	A1,Stuffer_USP			;store stuffer USP
	movem.l	D2-D7/A2-A7,stuff_regs_t	;store stuffer regs (d2 == SR)
	move	ACC_index_1(pc),d0	;d0 = ACC_index
	lsl	#3,D0			;d0 = ACC_index * 8
	movea.l	ACC_loc_t_p(PC),A1
	adda	D0,A1
	move.l	(A1)+,D1		;d1 -> basepage of ACC
	move.l	D1,ACC_RAM_base_p
	add.l	(A1),D1			;d1 -> RAM limit of ACC
	move.l	D1,ACC_RAM_end_p
	lsr	#1,D0			;d0 = ACC_index * 4
	lea	ACC_regs_tpt(pc),a0	;new
	move.l	(a0,d0),a0		;new
	movem.l	(a0),d1-d7/a1-a7	;restore ACC registers except d0/a0
;
	movea.l	ACC_USP_t_p(pc),a0
	movea.l	(a0,d0),a0
	move	a0,usp			;a0 = USP of ACC -> RTE frame
;
	tst	longframe_f		;\
	beq.s	.CPU_adapted		; \
	move	6(a0),-(sp)		;  \/ transfer stack frame
.CPU_adapted:				;  /\ leading to ACC to super stack
	move.l	2(a0),-(sp)		; /
	move	(a0),-(SP)		;/
	add	framesize(pc),a0
	move	a0,usp			;restore USP of ACC after popping frame
;
	st	ACC_active_f		;flag ACC active
	rte				;exit to ACC !!!
;----------------------------------------------------------------------------
;End of:	'task_handler' for stuffer ACCs
;----------------------------------------------------------------------------
;Start of:	BIOS functions with XBRA
;----------------------------------------------------------------------------
	XGEM_BIOS_define	nu_BIOS,'Stuf'
	move.l	nu_BIOS+xb_next(pc),a0	;\/ use older bios dispatcher
	jmp	(a0)			;/\
;----------------------------------------------------------------------------
patch_XGEM_sub:				;uses d0/a0/a1
	XGEM_patch	XGEM_linked_p,XGEM_wanted_p
	rts
;----------------------------------------------------------------------------
;End of:	BIOS functions with XBRA
;----------------------------------------------------------------------------
;Start of:	GEMDOS functions with XBRA
;----------------------------------------------------------------------------
;
	XB_define	nu_gemdos,'Stuf'
	Pass_Frame	a0
;
	cmpi	#Mfree&$FF,(A0)
	bne.s	use_old_gemdos
	move.l	2(a0),d0
	cmp.l	t_basepage_p(pc),d0
	beq.s	nu_Mfree_stuffer
use_old_gemdos:
	move.l	nu_gemdos+xb_next(pc),a0
	jmp	(a0)
;-------------------------------------
nu_Mfree_stuffer:
	bsr	remove_vectors
	tst	r_ACC_count
	ble.s	use_old_gemdos
	movem.l	d0-d3/a0-a3,-(sp)
	move.l	ACC_loc_t_p(pc),a3
	move	r_ACC_count(pc),d3
	subq	#1,d3
.free_ACC_loop:
.free_environ:
	move.l	(a3),a0
	move.l	bp_environ_p(a0),d0
	beq.s	.done_environment
	move.l	d0,-(sp)		;push -> environment of the ACC to be removed
	move	#Mfree&$FF,-(sp)	;push gemdos opcode Mfree
	tst	(_longframe).w		;\
	beq.s	.CPU_adapted_1		; \
	clr	-(sp)			;  \/ Push a simulated
.CPU_adapted_1:				;  /\ exception stack frame
	pea	.post_environment	; /
	move	sr,-(sp)		;/
;
	bra.s	use_old_gemdos		;let old gemdos do its work
;
.post_environment:
	addq	#6,sp			;remove simulated arguments
.done_environment:
	move.l	(a3),-(sp)		;push -> basepage of the ACC to be removed
	move	#Mfree&$FF,-(sp)	;push gemdos opcode Mfree
	tst	(_longframe).w		;\
	beq.s	.CPU_adapted_2		; \
	clr	-(sp)			;  \/ Push a simulated
.CPU_adapted_2:				;  /\ exception stack frame
	pea	.post_basepage		; /
	move	sr,-(sp)		;/
;
	bra.s	use_old_gemdos		;let old gemdos do its work
;
;-------------------------------------
;
.post_basepage:
	addq	#6,sp			;remove simulated arguments
.done_basepage:
	addq	#8,a3			;a3 -> -> basepage of next ACC to remove
	dbra	d3,.free_ACC_loop
	movem.l	(sp)+,d0-d3/a0-a3
	bra.s	use_old_gemdos	;allow old gemdos to remove NewStuff
;----------------------------------------------------------------------------
;End of:	GEMDOS functions with XBRA
;----------------------------------------------------------------------------
;Start of:	XGEM functions with XBRA
;----------------------------------------------------------------------------
	XGEM_define	nu_XGEM,'Stuf'
	cmpi	#$73,D0		;vdi call ?
	beq.s	nu_vdi_xgem
	tst	ACC_active_f
	beq.s	use_old_xgem
	cmpi	#$C8,D0		;aes call ?
	beq	nu_aes_xgem
use_old_xgem:
	move.l	nu_XGEM+xb_next(pc),a0
	jmp	(a0)
;
nu_vdi_xgem:
	move.l	d1,a0			;a0 -> vdipb
	move.l	(a0),a0			;a0 -> control
	cmp	#v_clswk&$FF,(a0)
	beq.s	nu_v_clswk
	tst	ACC_active_f
	beq.s	use_old_xgem
	tst	registered_f
	beq.s	use_old_xgem
	cmp	#v_clsvwk&$FF,(a0)	;opcode = v_clsvwk ?
	bne.s	use_old_xgem
nu_v_clsvwk:
	movea.l	ACC_vwk_f_p(pc),a0
	clr	(a0)
	move.l	nu_XGEM+xb_next(pc),a0
	jmp	(a0)
;----------------------------------------------------------------------------
nu_v_clswk:
	move.l	d1,a0			;a0 -> vdipb
	move.l	4(a0),a0		;a0 -> intin
	cmp	#10,(a0)		;device < 10 ? (2..4/5..9 == rez 0..2/3..7)
	bhs.s	use_old_xgem		;else go old GEM (probably GDOS)
	push_ex	.end_nu_clswk		;Push a simulated exception stack frame
	XB_gonext_a0	nu_XGEM(pc)
;----------------------------------------------------------------------------
.end_nu_clswk:
	bsr	erase_all_sub		;remove all stuffed ACCs
	bsr	remove_vectors
	rte
;----------------------------------------------------------------------------
nu_wind_close_delete:
	movem.l	(sp)+,a1-a2
	lea	T_C66(PC),A0
	move.l	2(SP),(A0)
	lea	.post_wind_close_delete(PC),A0
	move.l	A0,2(SP)
	bra	use_old_AES
;------------------------------------
.post_wind_close_delete:
	movem.l	D0/A1,-(SP)
	movea.l	D1,A1
	lea	8(A1),A1
	movea.l	(A1),A1
	move	(A1),D0
	moveq	#7,D1
	movea.l	open_wind_t_p(PC),A0
.loop:	cmp	2(A0),D0		;found correct window ?
	beq.s	.found
	addq	#4,A0
	dbra	D1,.loop
	bra.s	.exit
;
.found:
	clr.l	(A0)
.exit:
	movem.l	(SP)+,D0/A1
	movea.l	T_C66(PC),A0
	jmp	(A0)
;----------------------------------------------------------------------------
nu_wind_open:
	movem.l	(SP)+,A1-A2
	lea	T_C66(PC),A0
	move.l	2(SP),(A0)
	lea	.post_wind_open(PC),A0
	move.l	A0,2(SP)
	bra	use_old_AES
;------------------------------------
.post_wind_open:
	movem.l	d1/a1,-(sp)
	movea.l	D1,A1
	movea.l	12(A1),A1		;a1 -> intout
	tst	(A1)
	beq.s	.exit			;NB: was 'beq.s .T_BCA'
	movea.l	D1,A1
	move.l	8(A1),A1		;a1 -> intin
	moveq	#7,D1
	movea.l	open_wind_t_p(PC),A0
.loop:
	tst	2(A0)
	beq.s	.found_free
	addq	#4,A0
	dbra	D1,.loop
	bra.s	.exit
;
.found_free:
	move	ACC_index_1(PC),(A0)+
	move	(A1),(A0)
.exit:
	movem.l	(sp)+,d1/a1
	movea.l	T_C66(PC),A0
	jmp	(A0)
;;;
;;;.T_BCA:
;;;	movea.l	ACC_vwk_f_p(PC),A1	;;;BUG !!! ACC may have other windows,
;;;	clr	(A1)			;;;  -"-   that should not be affected
;;;	bra	.exit
;----------------------------------------------------------------------------
nu_aes_xgem:
	move.l	d1,a0			;a0 -> aespb
	move.l	(a0),a0			;a0 -> contrl
	move	(a0),d0			;d0 = AES opcode
	tst	boot_flag
	beq.s	.done_booting		;skip if done booting ACCs
	bpl.s	.done_nuboot		;skip if this ACC is not new
	cmp	#appl_init&$FF,d0	;appl_init ?
	beq.s	nu_appl_init		;if so, initialize new ACC application
	bra	use_old_AES		;else use old XGEM
;
.done_nuboot:
	move.l	d1,a0			;a0 -> aespb
	move.l	4(a0),a0		;a0 -> global
	cmp	#'St',6(a0)		;user word correct ?
	bne	use_old_AES		;skip if not identified
	tst	registered_f
	bne.s	.done_register		;skip if ACC already registered
	cmpi	#menu_register&$ff,d0	;menu_register ?
	beq	nu_menu_register
	cmpi	#rsrc_load&$ff,d0	;rsrc_load ?
	beq	nu_rsrc_load
	bra	use_old_AES
;
;
.done_booting:
	move.l	d1,a0			;a0 -> aespb
	move.l	4(a0),a0		;a0 -> global
	cmp	#'St',6(a0)		;user word correct ?
	bne	use_old_AES		;skip if not identified
.done_register:
;
	movem.l	a1-a2,-(sp)
	movea.l	D1,A0			;a0 -> aespb
	movea.l	(A0),A1			;a1 -> contrl
;
	cmpi	#wind_open&$ff,(A1)
	blt.s	T_CBE
	beq	nu_wind_open
	cmpi	#wind_delete&$ff,(A1)
	beq	nu_wind_close_delete
	cmpi	#wind_close&$ff,(A1)
	beq	nu_wind_close_delete
T_CBE:
	cmpi	#evnt_mesag&$ff,(A1)
	beq	nu_evnt_mesag
	cmpi	#evnt_multi&$ff,(A1)
	beq	nu_evnt_multi
	cmpi	#evnt_timer&$ff,(A1)
	beq	nu_evnt_timer
	bra	exit_to_old_AES
;----------------------------------------------------------------------------
nu_appl_init:
	move.l	d1,a0
	move.l	4(a0),.global_p
	move.l	12(a0),.intout_p
	tst	(_longframe).w		;\
	beq.s	.CPU_adapted_2		; \
	clr	-(sp)			;  \/ Push a simulated
.CPU_adapted_2:				;  /\ exception stack frame
	pea	.post_appl_init		; /
	move	sr,-(sp)		;/
	move.l	nu_XGEM+xb_next(pc),a0
	jmp	(a0)
;
.global_p:
	dc.l	0
.intout_p:
	dc.l	0
;
.post_appl_init:
	move	r_appl_id(pc),d0
	move.l	.intout_p(pc),a0
	tst	(a0)
	bge.s	.appl_ok
	move	d0,(a0)
	move.l	.global_p(pc),a0
	move.l	r_global(pc),(a0)
	move	r_global+4(pc),4(a0)
	clr.l	14(a0)
	clr.l	18(a0)
	clr.l	22(a0)
	clr.l	26(a0)
.appl_ok:
	move.l	.global_p(pc),a0
	move	#'St',6(a0)
	move	ACC_index_1(pc),8(a0)
	sf	boot_flag		;clear top byte of boot_flag
	rte
;----------------------------------------------------------------------------
nu_menu_register:
	movem.l	a1-a2,-(sp)
	movea.l	D1,A0		;a0 -> aespb
	movea.l	(A0),A1		;a1 -> contrl
	movea.l	12(A0),A1			;a1 -> intout
	lea	menu_reg_ACC_count(PC),A2
	move	(A2),(A1)
	addq	#1,(A2)
	movea.l	$10(A0),A1			;a1 -> addrin
	movea.l	next_ACC_title_spp(PC),A0	;a0 -> free ptr for next ACC title
	move.l	(A1),(A0)+			;store -> title of calling ACC
	lea	next_ACC_title_spp(PC),A1
	move.l	A0,(A1)				;store updated ptr for next ACC title
	move	#1,registered_f
	movem.l	(SP)+,A1-A2
	rte
;----------------------------------------------------------------------------
nu_rsrc_load:
	movem.l	a1-a2,-(sp)
	movea.l	D1,A0		;a0 -> aespb
	movea.l	(A0),A1		;a1 -> contrl
	movem.l	(SP)+,A1-A2
	lea	T_C66(PC),A0
	move.l	2(SP),(A0)
	lea	end_rsrc_load(PC),A0
	move.l	A0,2(SP)
	move.l	nu_XGEM+xb_next(pc),a0
	jmp	(a0)
;------------------------------------
end_rsrc_load:
	movea.l	D1,A0
	movea.l	12(A0),A0
	tst	(A0)
	bne.s	T_C60
	lea	rsc_error_s(PC),A0
	bsr	copyshow_stuff_name
	lea	registered_f(PC),A0
	cmpi	#1,(A0)
	beq.s	T_C60
	move	#2,(A0)
T_C60:
	movea.l	T_C66(PC),A0
	jmp	(A0)
;----------------------------------------------------------------------------
T_C66:	ds.l	1
;----------------------------------------------------------------------------
rsc_error_s:
	dc.b	' rsc error',$0,$0
;------------------------------------
nu_evnt_timer:
	moveq	#$50,D0
	bra.s	new_event
;------------------------------------
nu_evnt_multi:
	lea	ACC_event_flag(PC),A1
	cmpi	#$40,(A1)
	beq	exit_to_old_AES
	moveq	#0,D0
	bra.s	new_event
;
nu_evnt_mesag:
	moveq	#$40,D0
new_event:
	ori	#$700,sr		;disable interrupts
	lea	ACC_event_flag(PC),A1
	move	D0,(A1)
	movem.l	(SP)+,A1-A2
	move	usp,A0
;
	tst	longframe_f
	beq.s	.cpu_adapted
	move	6(sp),-(a0)		;repush frame type word on user stack
.cpu_adapted:
	move.l	2(SP),-(A0)		;repush frame retadr on user stack
	move	(SP),-(A0)		;repush frame sr on user stack
	add	framesize(pc),sp	;remove frame from super stack
;
	move	ACC_index_1(pc),D0
	lsl	#2,D0			;d0 = ACC_index_1 * 4
	addq	#1,ACC_index_1		;ACC_index_1 += 1
	movea.l	ACC_USP_t_p(PC),A1
	move.l	A0,(A1,D0)		;(*ACC_USP_t_p)[d0] = ACC USP
;
	lea	ACC_regs_tpt(pc),a0
	move.l	(a0,d0),a0
	movem.l	d1-d7/a1-a7,(a0)	;store ACC registers except d0/a0
;
	move	ACC_index_1(PC),D0	;d0 = ACC_index = ACC_ix + 1
	subq	#1,D0			;d0 = d0 - 1 == ACC_ix
	move	D0,-(SP)		;push d0 == ACC_ix
	lsl	#2,D0			;d0 = 4 * (ACC_index - 1)
	movea.l	ACC_intin_p_t_p(PC),A2
	adda	D0,A2
	lsl	#1,D0			;d0 = 8 * ACC_ix
	movea.l	ACC_iop_ai_t_p(PC),A0
	adda	D0,A0
	movea.l	D1,A1			;a1 -> aespb
	cmpi	#$50,ACC_event_flag	;timer event ?
	bne.s	.fix_evnt_multi
	movea.l	8(A1),A1		;a1 -> intin
	move.l	(A1),D0			;d0 = intin[0]<<16+intin[1]
	bra.s	.fix_evnt_timer
;------------------------------------
.fix_evnt_multi:
	move.l	12(A1),(A0)+		;long (*ACC_iop_ai_t_p)[ACC_ix*8+0] = &(intout[0])
	movea.l	16(A1),A1		;a1 -> addrin
	move.l	(A1),(A0)		;long (*ACC_iop_ai_t_p)[ACC_ix*8+4] = addrin[0]
	lea	ACC_event_flag(PC),A0
	tst	(A0)			;multi event ?
	bne.s	fix_evnt_mesag
	movea.l	D1,A1			;a1 -> aespb
	movea.l	8(A1),A1		;a1 -> intin
	move.l	A1,(A2)			;(*ACC_intin_p_t_p)[ACC_ix*4] = &(intin[0])
	move	(A1),(A0)		;ACC_event_flag = intin[0]
	move	(A0),D1
	btst	#b_MU_TIMER,D1
	beq.s	fix_evnt_mesag
	move.l	28(A1),D0		;d0 = intin[14]<<16+intin[15]
.fix_evnt_timer:
	swap	D0			;d0 = timeout
	movea.l	ACC_timeout_t_p(PC),A0		;
	move	(SP),D1			;d1 = ACC_ix
	lsl	#2,D1			;d1 = ACC_ix * 4
	move.l	D0,(A0,D1)		;(*ACC_timeout_t_p)[ACC_ix*4] = timeout
fix_evnt_mesag:
	move	(SP)+,D0		;d1 = ACC_ix
	lsl	#1,D0			;d1 = ACC_ix * 2
	movea.l	ACC_event_flag_t_p(PC),A0
	move	ACC_event_flag(PC),(A0,D0)	;word (*ACC_event_flag_t_p)[ACC_ix*2] = event flags or $40
	bra	task_reentry
;------------------------------------
exit_to_old_AES:
	movem.l	(SP)+,A1-A2
use_old_AES:
	move.l	#$C8,d0
	move.l	nu_XGEM+xb_next(pc),a0
	jmp	(a0)
;----------------------------------------------------------------------------
;End of:	XGEM functions with XBRA
;----------------------------------------------------------------------------
next_ACC_title_spp:	ds.l	1
ACC_title_spt:		ds.l	1	;but also overwrites 124 bytes further
;
t_clrblk_5:
	unlk	A6
	rts
;----------------------------------------------------------------------------
main:
	link	A6,#-$2
	jsr	appl_init_sub(PC)
;
	pea	-$1A32(A4)
	pea	-$1A30(A4)
	pea	-$1A2C(A4)
	pea	-$1A2E(A4)
	jsr	graf_handle_sub(PC)
	adda	#$10,SP
	move	D0,wk_handle(a4)
;
	jsr	open_main_vwk(PC)
;
	move	#1,main_ACC_id(a4)	;dummy id for non_ACC use
	tst	ACC_flag
	beq.s	.done_register
	pea	d_DC_STuffer_s(a4)
	move	appl_id(A4),-(SP)
	jsr	menu_register_sub(PC)
	addq	#6,SP
	move	D0,main_ACC_id(A4)	;real id for ACC use
	move.l	#2000,-(sp)
	jsr	evnt_timer_sub
	addq	#4,sp
.done_register
;
	bra.s	reload_loop			;;;patch!!!
.dummy:
	ds.b	124-(.dummy-t_clrblk_5)	;NB: This area is needed for 'ACC_title_spt'
t_clrblk_5_end:
;
reload_loop:	;-------------------- Time to load all stuffed ACCs --------------------
;
	lea	t_clrblk_t(pc),a3
init_clear_loop_1:
	move.l	(a3)+,d0
	beq.s	init_nonzero
	move.l	d0,a0
	move.l	(a3)+,d1
	sub.l	d0,d1
	subq	#1,d1
	blt.s	init_nonzero
init_clear_loop_2:
	clr.b	(a0)+
	dbra	d1,init_clear_loop_2
	bra.s	init_clear_loop_1
;
init_nonzero:
	move	#-1,boot_ACC_count
	move	#-1,pexec_ACC_count
	move	#1,menu_reg_ACC_count
	move	#1,boot_flag
	lea	ACC_title_spt(pc),a1
	lea	t_null_s(pc),a0
	moveq	#32-1,d0
init_spt_loop:
	move.l	a0,(a1)+
	dbra	d0,init_spt_loop
;
	bsr	init_main
;
	move	t_bootdev(pc),d0
	add.b	d0,stuffer_path_s(A4)
;
	pea	text_attribute(pc)
	move	vwk_handle(a4),-(sp)
	bsr	vqt_attributes_sub
	addq	#6,sp
;
	bsr	kick_screen
	bsr	kick_screen
	bsr	kick_screen
	bsr	kick_screen
;
	bsr	lock_mouse
	lea	stuff_tree+4*24+8(a4),A0	;a0 -> flags of first ACC object
	move	#20-1,d1			;d1 = dbra count for ACC objects
.T_E78:
	move	#HIDETREE,(A0)
	lea	24(a0),a0		;step a0 -> next ACC object flags
	dbra	d1,.T_E78
	lea	-24(a0),a0		;step a0 back -> last ACC object flags
	ori	#LASTOB,(a0)
;
	move.l	about_tree+20(a4),about_size
	move.l	stuff_tree+20(a4),stuff_size
	move.l	boot_tree+20(a4),boot_size
;
	moveq	#32-1,d0
	move	text_attribute+18(pc),d1
	add	d1,d0
	divu	d1,d0		;d0 = char's needed for icon height
	subq	#4,d0
	ble.s	.done_icon
	add	d0,about_size+2
	move	about_size+2,about_tree+22(a4)
.done_icon:
;
	move.l	d3,-(sp)
;
	moveq	#20-1,d3
.fix_about_loop:			;NB: fixes 'about'
	move	d3,-(sp)
	pea	about_tree(a4)
	bsr	rsrc_obfix_sub
	addq	#6,sp
	dbra	d3,.fix_about_loop
;
	moveq	#24-1,d3
.fix_stuff_loop:			;NB: fixes 'stuff'
	move	d3,-(sp)
	pea	stuff_tree(a4)
	bsr	rsrc_obfix_sub
	addq	#6,sp
	dbra	d3,.fix_stuff_loop
;
	moveq	#4-1,d3
.fix_boot_loop:				;NB: fixes 'boot'
	move	d3,-(sp)
	pea	boot_tree(a4)
	bsr	rsrc_obfix_sub
	addq	#6,sp
	dbra	d3,.fix_boot_loop
;
	move.l	(sp)+,d3
;
	pea	-$1A04(A4)
	move	#$100,-(SP)
	jsr	graf_mouse_sub(PC)
	addq	#6,SP
;
	pea	box_1_h(A4)
	pea	box_1_w(A4)
	pea	box_1_y(A4)
	pea	box_1_x(A4)
	move.l	boot_tree_p(a4),-(SP)
	jsr	form_center_sub(PC)
	adda	#$14,SP
;
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	jsr	form_dial_sub(PC)
	adda	#$12,SP
;
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	move	#3,-(SP)
	clr	-(SP)
	move.l	boot_tree_p(a4),-(SP)
	jsr	objc_draw_sub(PC)
	adda	#$10,SP
;
	sub_gemdos	Dsetdrv,t_bootdev(pc)
	sub_gemdos	Dsetpath,stuffer_path_s(a4)
;
	clr	ACC_count(A4)
	lea	ACC_title_spt(PC),A0
	move.l	A0,ACC_title_spt_p(A4)
;
	cmpi	#0,D0
	blt	.done_load_ACC
;
	tst	no_load_f
	bne.s	.done_ACC_note
	sub_gemdos	Fsetdta,loc_dta(a4)
	sub_gemdos	Fsfirst,d_Fsearch_s(a4),!
;
	move	D0,temp_word_1(A4)
	bra.s	.ACC_load_test
;------------------------------------
.ACC_note_loop:
	pea	dta_fname+loc_dta(A4)	;push -> name of found ACC for future copy
	move	ACC_count(A4),D0
	muls	#$10,D0			;scale index d0 for 16 byte strings (incl term)
	lea	ACC_name_t(A4),A0	;a0 -> ACC name string table
	adda	D0,A0			;a0 -> room for current ACC name in table
	lea	(A0),A0
	move.l	A0,-(SP)		;push -> destination for ACC name
	bsr	strcpy		;copy ACC name into table (incl term)
	addq	#8,SP			;clean stack
;
	sub_gemdos	Fsetdta,loc_dta(a4)
	sub_gemdos	Fsnext
;
	move	D0,temp_word_1(A4)
	addq	#1,ACC_count(A4)
.ACC_load_test:
	move	temp_word_1(A4),D0		;was file found ?
	bne.s	.done_ACC_note
	cmpi	#32,ACC_count(A4)		;NB: Test if 32 ACC limit reached
	blt	.ACC_note_loop
;
.done_ACC_note:
	cmpi	#0,ACC_count(A4)
	ble.s	.done_load_ACC
;
	move	vwk_handle(a4),-(SP)
	jsr	v_clsvwk_sub(PC)
	addq	#2,SP
;
	clr	task_job(a4)
	jsr	task_handler(PC)	;task_job 0 => prepare for boot
	move	#1,task_job(a4)
	jsr	task_handler(PC)	;task_job 1 => boot and start all stuffer ACCs
	move	#2,task_job(a4)
	jsr	task_handler(PC)	;task_job 2 => mark boot completed
	cmpi	#0,ACC_count(A4)
	ble.s	.done_load_ACC
;
	pea	-$1A32(A4)
	pea	-$1A30(A4)
	pea	-$1A2C(A4)
	pea	-$1A2E(A4)
	jsr	graf_handle_sub(PC)
	adda	#$10,SP
	move	D0,wk_handle(a4)
	jsr	open_main_vwk(PC)
;
.done_load_ACC:
;
	jsr	fix_titles(PC)
;
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	move	#3,-(SP)		;\/ release
	jsr	form_dial_sub(PC)	;/\ screen
	adda	#$12,SP
;
	pea	workscreen_h(A4)
	pea	workscreen_w(A4)
	pea	workscreen_y(A4)
	pea	workscreen_x(A4)
	move	#4,-(SP)
	clr	-(SP)
	jsr	wind_get_sub(PC)
	adda	#$14,SP
;
	moveq	#1,d0			;about_line is always present
	addq	#1,d0			;add dash_line as separator
	move	ACC_count(a4),d1
	ble.s	.have_fullheight
	cmp	#20,d1
	ble.s	.have_ACC_height	;<21 ACCs have only ACC_lines below dash_line
	moveq	#20,d1			;else there are 18 ACC_lines and 2 scroll_lines
.have_ACC_height:
	add	d1,d0			:d0 += ACC_lines and scroll_lines => total lines
.have_fullheight:
	movea.l	stuff_tree_p(a4),A0
	move	d0,22(a0)		;store height in characters for stuff_tree
	move	stuff_size(pc),20(a0)	;restore original stuff tree width (characters)
;
	move	#0,-(SP)		;refix object 0 of stuff_tree
	pea	stuff_tree(a4)
	jsr	rsrc_obfix_sub(PC)
	addq	#6,SP
;
	bsr	release_mouse
	move	workscreen_h(A4),-(SP)
	move	workscreen_w(A4),-(SP)
	move	workscreen_y(A4),-(SP)
	move	workscreen_x(A4),-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	move	#3,-(SP)
	jsr	form_dial_sub(PC)
	adda	#$12,SP
;
	pea	-$1A04(A4)
	move	#$101,-(SP)
	jsr	graf_mouse_sub(PC)
	addq	#6,SP
;
	pea	-$1A04(A4)
	clr	-(SP)
	jsr	graf_mouse_sub(PC)
	addq	#6,SP
;
	pea	box_2_h(A4)
	pea	box_2_w(A4)
	pea	box_2_y(A4)
	pea	box_2_x(A4)
	move.l	about_tree_p(a4),-(SP)
	jsr	form_center_sub(PC)
	adda	#$14,SP
;
	pea	box_1_h(A4)
	pea	box_1_w(A4)
	pea	box_1_y(A4)
	pea	box_1_x(A4)
	move.l	stuff_tree_p(a4),-(SP)
	jsr	form_center_sub(PC)
	adda	#$14,SP
;
	lea	stuff_tree+1*24+16(a4),a0	;a0 -> second object's coordinates
	moveq	#24-1-1,d0			;d0 = dbra, skipping object 0
.indent_loop:
	addq	#1,(a0)			;indent each title by 1 pixel
	lea	24(a0),a0		;step a0 to coordinates of next object
	dbra	d0,.indent_loop
;
	movea.l	stuff_tree_p(a4),A0
	addq	#2,$14(A0)		;add 2 pixels to stuff_tree form width
	addq	#1,$16(A0)		;add 1 pixel to stuff_tree form height
;
	addq	#2,box_1_w(A4)
	addq	#1,box_1_h(A4)
;
	move	workscreen_x(A4),D0
	add.w	#15,D0
	move	D0,box_1_x(A4)
	movea.l	stuff_tree_p(a4),A0
	move	D0,$10(A0)
	move	workscreen_y(A4),D0
	move	D0,box_1_y(A4)
	movea.l	stuff_tree_p(a4),A0
	move	D0,$12(A0)
;
	move	vwk_handle(a4),-(SP)
	jsr	v_clsvwk_sub(PC)
	addq	#2,SP
	bsr.s	multi_tasker
;
;Before revision multi_tasker had an eternal loop, so this point was never reached
;After revision a return here means it is time to reload all stuffed ACC's
;
	bsr	erase_all_sub
	bra	reload_loop
;----------------------------------------------------------------------------
;Start of:	ETERNAL LOOP ROUTINE
;----------------------------------------------------------------------------
multi_tasker:
	link	A6,#-2
	movem.l	D4-D7,-(SP)
	clr	D5
	bra.s	.T_11A8
;------------------------------------
.T_119E:
	lea	ACC_ewait_f_t(A4),A0
	sf	(a0,d5)				;mark one ACC as not awaiting events
	addq	#1,D5
.T_11A8:
	move	D5,D0
	cmp	ACC_count(A4),D0		;d0 in legal range as stuffed ACC index ?
	blt	.T_119E				;if so, loop back to mark more ACCs
	move	#3,task_job(a4)			;task_job 3 => await events for stuffed ACCs
multi_task_loop:
	move	#MU_MESAG,event_flags_1(A4)
	move.l	cycle_time(pc),D7
	clr	D5
	bra.s	fix_event_flags_1
;------------------------------------
fix_event_flags_1_lp:
	lea	ACC_ewait_f_t(A4),A0
	tst.b	(a0,d5)
	beq.s	.next_event_flags_1
	move	D5,D0
	asl.l	#1,D0
	lea	ACC_event_flag_t(A4),A0
	adda	D0,A0
	move	(A0),temp_word_1(A4)
	cmpi	#$40,temp_word_1(A4)
	beq.s	.next_event_flags_1
	cmpi	#$50,temp_word_1(A4)
	bne.s	.done_timer
	move	#MU_TIMER,temp_word_1(A4)
.done_timer:
	move	temp_word_1(A4),D0
	or	D0,event_flags_1(A4)
.next_event_flags_1:
	addq	#1,D5
fix_event_flags_1:
	move	D5,D0
	cmp	ACC_count(A4),D0
	blt	fix_event_flags_1_lp		;loop back to fix flags of all ACCs
	cmpi	#-$1,-$1A08(A4)
	beq.s	.T_129A
	move	-$1A08(A4),D6
	asl.l	#2,D6
	lea	ACC_timeout_t(A4),A0
	adda	D6,A0
	move.l	(A0),D6
	cmpi.l	#0,D6
	ble.s	.T_1248
	move.l	D6,D0
	cmp.l	D7,D0
	bge.s	.T_1248
	move.l	D6,D7
.T_1248:
	move	-$1A08(A4),D0
	asl.l	#1,D0
	lea	ACC_event_flag_t(A4),A0
	adda	D0,A0
	move	(A0),D0
	and	#14,D0
	beq.s	.T_1292
	move	-$1A08(A4),D6
	asl.l	#2,D6
	lea	ACC_intin_p_t(A4),A0
	adda	D6,A0
	move.l	(A0),D6
	move	#1,D5
	bra.s	.T_1286
;------------------------------------
.T_1274:
	movea.l	D6,A0
	lea	-$1FB6(A4),A1
	move	D5,D0
	lsl.w	#1,D0
	move	0(A0,D0.w),0(A1,D0.w)
	addq	#1,D5
.T_1286:
	cmpi	#14,D5
	blt	.T_1274
	bra.s	.T_129E
;------------------------------------
.T_1292:
	jsr	T_1D02(PC)
	bra.s	.T_129E
;------------------------------------
.T_129A:
	jsr	T_1D02(PC)
.T_129E:
;;;	btst	#5,1+event_flags_1(A4)
;;;	beq.s	.done_timer
	move.l	D7,D0
	move	D0,-$19F4(A4)
	swap	d0
	move	D0,-$19F6(A4)
.done_timer:
;
evnt_multi_loop:
	pea	evm_clct(A4)
	pea	evm_key(A4)
	pea	evm_kbsh(A4)
	pea	evm_butt(A4)
	pea	evm_ypos(A4)
	pea	evm_xpos(A4)
	move	-$19F6(A4),-(SP)
	move	-$19F4(A4),-(SP)
	pea	mesag_buf_1(a4)
	move	-$1F9C(A4),-(SP)
	move	-$1F9E(A4),-(SP)
	move	-$1FA0(A4),-(SP)
	move	-$1FA2(A4),-(SP)
	move	-$1FA4(A4),-(SP)
	move	-$1FA6(A4),-(SP)
	move	-$1FA8(A4),-(SP)
	move	-$1FAA(A4),-(SP)
	move	-$1FAC(A4),-(SP)
	move	-$1FAE(A4),-(SP)
	move	-$1FB0(A4),-(SP)
	move	-$1FB2(A4),-(SP)
	move	-$1FB4(A4),-(SP)
	move	event_flags_1(A4),-(SP)
;
	tst	open_hotkey
	beq.s	.done_kb_setup
	bset	#0,1(sp)		;enforce keyboard events
	seq	cmd_kb_f
.done_kb_setup:
	bset	#5,1(sp)		;enforce timer events
	seq	cmd_timer_f
	bne.s	.use_multi
	move	#200,32(sp)
	clr	34(sp)
;
.use_multi:
	jsr	evnt_multi_sub(PC)	;Await events for either main ACC or stuffer ACCs
	adda	#$3C,SP
	move	D0,event_flags_2(a4)
;
	btst	#0,d0
	beq.s	.done_evkb_cmd
	tst	cmd_kb_f
	beq.s	.done_evkb_cmd
	bclr	#0,1+event_flags_2(a4)
	bra.s	.try_specials
;
.done_evkb_cmd:
	bclr	#5,d0			;did a timer event occur
	beq.s	.done_key_cmd		;if not, skip hotkey command handling
	tst	cmd_timer_f		;was the timer event purely for hotkey
	beq.s	.keep_timer_event	;if not, keep the flag for other purposes
	move	D0,event_flags_2(a4)	;hide the timer event flag, if purely for hotkey
.keep_timer_event:
	btst	#4,d0			;did a message event occur
	bne.s	.done_key_cmd		;if so, abort hotkey command handling
.try_specials:
	bsr	kbshift_plus
	and	#$6F,d0
	cmp	#3,open_shifts
	ble.s	.try_hotkey
	cmp	open_shifts(pc),d0	
	beq.s	.simulate_AC_OPEN
.try_hotkey:
	move	evm_key(a4),d2
	move.l	open_hotkey(pc),d1
	beq.s	.done_key_cmd
	bpl.s	.hot_cmp
	neg.l	d1
	lsr	#8,d2
.hot_cmp:
	cmp.b	d2,d1
	bne.s	.done_key_cmd
	swap	d1
	cmp	d0,d1
	bne.s	.done_key_cmd
.simulate_AC_OPEN:
	clr	evm_kbsh(a4)
	lea	mesag_buf_1(a4),A0
	move.s	#AC_OPEN,(a0)+
	clr	(a0)+
	clr	(a0)+
	clr	(a0)+
	move	main_ACC_id(a4),(a0)
	bset	#4,event_flags_2+1(a4)
.done_key_cmd:
	tst	event_flags_2(a4)
	beq	evnt_multi_loop
;
	lea	mesag_buf_1(a4),A0
	lea	mesag_buf_2(a4),A1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
;
	move	mesag_buf_1(a4),D5	;d5 = latest received message type code
	move	event_flags_2(a4),D0
	and	#MU_MESAG,D0		;was there a new message ?
	beq	.T_1880			;if not, skip to .T_1880
	cmp	#AC_OPEN,D5		;was it AC_OPEN ?
	beq.s	.mesag_event_AC_OPEN
	cmp	#AC_CLOSE,D5		;was it AC_CLOSE
	bne	.T_1880			;if not, skip to .T_1880
	bra	.mesag_event_AC_CLOSE
;------------------------------------
.mesag_event_AC_OPEN:
	move	mesag_buf_1+08(a4),D0
	cmp	main_ACC_id(A4),D0
	bne	multi_task_loop
	pea	-$1A32(A4)
	pea	-$1A30(A4)
	pea	-$1A2C(A4)
	pea	-$1A2E(A4)
	jsr	graf_handle_sub(PC)
	adda	#$10,SP
	move	D0,wk_handle(a4)
	jsr	open_main_vwk(PC)
	bsr	lock_mouse
	move	#1,D4
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	jsr	form_dial_sub(PC)
	adda	#$12,SP
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	move	#3,-(SP)
	clr	-(SP)
	move.l	stuff_tree_p(a4),-(SP)
	jsr	objc_draw_sub(PC)
	adda	#$10,SP
	bra	.T_1848
;------------------------------------
.main_dialog_loop:
	pea	-$1A02(A4)
	move.l	stuff_tree_p(a4),-(SP)
	jsr	T_350(PC)
	addq	#8,SP
	and	#$7FFF,D0
	move	D0,scan_object(a4)

	cmpi	#$5555,scan_object(a4)
	bne.s	.scan_command
.T_141E:
	pea	-$1A04(A4)
	pea	-$1A04(A4)
	pea	-$2(A6)
	move	wk_handle(a4),-(SP)
	jsr	vq_mouse_sub(PC)
	adda	#14,SP
	cmpi	#1,-$2(A6)		;left butt ?
	bne.s	.T_1464			;if not, go .T_1464
	pea	-$1A04(A4)
	pea	-$1A04(A4)
	pea	-$1A04(A4)
	pea	-$1A04(A4)
	move	#1,-(SP)
	move	#1,-(SP)
	move	#1,-(SP)
	jsr	evnt_button_sub(PC)
	adda	#$16,SP
.T_1464:
	move	-$2(A6),D0		;any butt ?
	bne	.T_141E			;if so, go .T_141E
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	move	#3,-(SP)
	jsr	form_dial_sub(PC)
	adda	#$12,SP
	bsr	release_mouse
	clr	D4
	move	vwk_handle(a4),-(SP)
	jsr	v_clsvwk_sub(PC)
	addq	#2,SP
.scan_command:
	cmp	#4,scan_object(a4)
	blt	.scan_non_ACC_cmd
	beq.s	.scan_ACC_scrolls
	cmp	#23,scan_object(a4)
	bgt	.scan_non_ACC_cmd
	blt.s	.scan_stuff_ACC
.scan_ACC_scrolls:			;user clicked min or max ACC row in stuff_tree
	cmp	#20,ACC_count(a4)	;are there more than 20 ACC's
	bhi	.scan_non_ACC_cmd	;if so, go treat click as scroll arrow
.scan_stuff_ACC:			;Here we know user clicked an ACC row
	pea	-$1A04(A4)
	pea	-$1A04(A4)
	pea	-$2(A6)
	move	wk_handle(a4),-(SP)
	jsr	vq_mouse_sub(PC)
	adda	#14,SP
	cmpi	#1,-$2(A6)		;left butt ?
	bne.s	.T_1528			;if not, go T_1528
	pea	-$1A04(A4)
	pea	-$1A04(A4)
	pea	-$1A04(A4)
	pea	-$1A04(A4)
	move	#1,-(SP)
	move	#1,-(SP)
	move	#1,-(SP)
	jsr	evnt_button_sub(PC)
	adda	#$16,SP
.T_1528:
	move	-$2(A6),D0		;any butt ?
	bne	.scan_stuff_ACC		;if so, go .scan_stuff_ACC
;
	bsr	norm_stuff_obj
	bsr	give_stuff_screen
;
	bsr	release_mouse
	bsr	kick_screen
	bsr	kick_screen
	clr	D4
	move	scan_object(a4),D0		;d0 = object_num of ACC from stuffer dialog
	subq	#4,d0				;convert d0 from object num to ACC_list_num
	cmpi	#21,ACC_count(A4)
	blt.s	.have_rel_stuff_num
	subq	#1,d0				;correct d0 ACC_list_num for scroll_object
.have_rel_stuff_num:				;d0 = index of ACC rel to 1st visible
	add	ACC_offset(a4),D0		;d0 = absolute stuffer index of ACC
	move	D0,ACC_current(a4)
	move	ACC_current(a4),-$1A08(A4)
	move	#AC_OPEN,mesag_buf_2(a4)
	move	ACC_current(a4),D0
	addq	#1,D0
	move	D0,mesag_buf_2+08(a4)
	move	ACC_current(a4),D0
	asl.l	#1,D0
	lea	ACC_event_flag_t(A4),A0
	adda	D0,A0
	move	(A0),temp_word_1(A4)
	cmpi	#0,temp_word_1(A4)
	beq	.T_1848
	move	vwk_handle(a4),-(SP)		;vwk_handle
	jsr	v_clsvwk_sub(PC)
	addq	#2,SP
	move	#1,ACC_vwk_f(A4)
	jsr	task_handler(PC)
	lea	ACC_ewait_f_t(A4),A0
	adda	ACC_current(a4),A0
	st	(A0)
	cmpi	#0,ACC_vwk_f(A4)
	bne.s	.T_1618
	jsr	has_ACC_wind(PC)
	tst	D0
	beq.s	.T_162C
.T_1618:
	cmpi	#$40,temp_word_1(A4)
	beq.s	.T_162C
	cmpi	#$50,temp_word_1(A4)
	bne	.T_1848
.T_162C:
	jsr	T_1C98(PC)
	bra	.T_1848
;------------------------------------
;Here user has clicked a non-ACC command object in main dialog (stuff_tree)
;Possibilities are: 1 = 'about'  2 = 'reload'  4 = up_arrow  23 = down_arrow
;
.scan_non_ACC_cmd:
	cmpi	#4,scan_object(a4)	;was the object up_arrow
	bne.s	.T_1672
;
	bsr	norm_stuff_obj
;
	subq.w	#1,ACC_offset(a4)
	jsr	redraw_scroll_stuff_tree(PC)
	bra	.T_1848
;------------------------------------
.T_1672:
	cmpi	#23,scan_object(a4)	;was the object down_arrow
	bne.s	.try_menu_about
;
	bsr	norm_stuff_obj
;
	addq	#1,ACC_offset(a4)
	jsr	redraw_scroll_stuff_tree(PC)
	bra	.T_1848
;------------------------------------
.try_menu_about:
	cmpi	#1,scan_object(a4)	;was the object 'about'
	bne	.try_menu_reload
;
	bsr	norm_stuff_obj
	bsr	give_stuff_screen
;
	bsr	kick_screen
	bsr	kick_screen
	move	box_2_h(A4),-(SP)
	move	box_2_w(A4),-(SP)
	move	box_2_y(A4),-(SP)
	move	box_2_x(A4),-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	jsr	form_dial_sub(PC)
	adda	#$12,SP
	move	box_2_h(A4),-(SP)
	move	box_2_w(A4),-(SP)
	move	box_2_y(A4),-(SP)
	move	box_2_x(A4),-(SP)
	move	#3,-(SP)
	clr	-(SP)
	move.l	about_tree_p(a4),-(SP)
	jsr	objc_draw_sub(PC)
	adda	#$10,SP
	pea	-$1A02(A4)
	move.l	about_tree_p(a4),-(SP)
	jsr	T_350(PC)
	addq	#8,SP
	move	#1,-(SP)
	clr	-(SP)
	move	box_2_h(A4),-(SP)
	move	box_2_w(A4),-(SP)
	move	box_2_y(A4),-(SP)
	move	box_2_x(A4),-(SP)
	clr	-(SP)
	move	#10,-(SP)
	move.l	about_tree_p(a4),-(SP)
	jsr	objc_change_sub(PC)
	adda	#$14,SP
	move	box_2_h(A4),-(SP)
	move	box_2_w(A4),-(SP)
	move	box_2_y(A4),-(SP)
	move	box_2_x(A4),-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	move	#3,-(SP)
	jsr	form_dial_sub(PC)
	adda	#$12,SP
	bsr	release_mouse
	move	vwk_handle(a4),-(SP)
	jsr	v_clsvwk_sub(PC)
	addq	#2,SP
	clr	D4
	bra.s	.T_1848
;------------------------------------
.try_menu_reload:
	cmpi	#2,scan_object(a4)	;was the object 'reload'
	bne.s	.T_1848
;
	bsr	norm_stuff_obj
	bsr	give_stuff_screen
	bsr	kick_screen
	bsr	kick_screen
	bsr	release_mouse
;
;new code implements 'Reload' command
;
	lea	ACC_extras_al_s(pc),a0
	tst	ACC_flag
	bne.s	.do_extras
	lea	APP_extras_al_s(pc),a0
.do_extras:
	pea	(a0)
	move	#2,-(SP)
	jsr	form_alert_sub(PC)
	addq	#6,SP
	cmp	#2,d0
	sgt	no_load_f
	bgt.s	.exit_prog
	beq.s	.skip_reload
.exit_routine:
	jsr	AC_CLOSE_all_sub(PC)		;close all stuffed ACC's
	unlk	a6
	rts				;return to caller for actual reload
;
.skip_reload:
	move	vwk_handle(a4),-(SP)
	jsr	v_clsvwk_sub(PC)
	addq	#2,SP
	clr	D4
.T_1848:
	cmpi	#1,D4
	beq	.main_dialog_loop
	bra	multi_task_loop
;
.exit_prog:
	tst	ACC_flag			;running as ACC ?
	bne.s	.exit_routine			;do not Pterm as ACC, just go exit routine
	move	vwk_handle(a4),-(SP)
	jsr	v_clsvwk_sub(PC)		;close virtual workstation
	addq	#2,SP
	jsr	AC_CLOSE_all_sub(PC)		;close all stuffed ACCs
	bsr	erase_all_sub			;erase all stuffed ACCs
	jsr	appl_exit_sub			;exit application from AES
	xbios	Supexec,remove_vectors(pc)	;remove XBRA links
	gemdos	Pterm0				;terminate program
;------------------------------------
.mesag_event_AC_CLOSE:
	move	mesag_buf_1+06(a4),D0
	cmp	main_ACC_id(A4),D0
	bne	multi_task_loop
	jsr	AC_CLOSE_all_sub(PC)		;close all stuffed ACC's
	bra	multi_task_loop
;------------------------------------
.T_1880:
	move	D5,temp_word_1(A4)	;temp_word_1(a4) = latest message code
	move	event_flags_2(a4),D0	;d0 = latest event code
	and	#MU_MESAG,D0		;was it a message event ?
	beq.s	.T_191A			;if not, skip to .T_191A
	cmpi	#20,temp_word_1(A4)	;was it a non_window message < 20
	blt.s	.T_191A			;if so, skip to .T_191A
	cmpi	#37,temp_word_1(A4)	;was it a non_window message > 37
	bgt.s	.T_191A			;if so, skip to .T_191A
	clr	D5			;clear index for two words of 1st window
	lea	open_wind_t(A4),A0
.T_18AA:
	move	2(a0,d5),D0		;d0 = window id from table
	cmp	mesag_buf_1+06(a4),D0	;found correct window id ?
	bne.s	.next_window
	move	(a0,d5),ACC_current(a4)	;set current ACC to be the window owner
	cmpi	#$15,temp_word_1(A4)	;WM_TOPPED ?
	beq.s	.T_18E0
	cmpi	#$1D,temp_word_1(A4)	;WM_NEWTOP ?
	bne.s	.T_18E6
.T_18E0:
	move	ACC_current(a4),-$1A08(A4)
.T_18E6:
	move	#1,ACC_vwk_f(A4)
	jsr	task_handler(PC)
	cmpi	#0,ACC_vwk_f(A4)
	bne	multi_task_loop
	jsr	has_ACC_wind(PC)
	tst	D0
	bne	multi_task_loop
	jsr	T_1C98(PC)
	bra	multi_task_loop
;
.next_window:
	addq	#4,D5		;step index to two words of next window
	cmpi	#8*2,D5		;checked 8 windows yet ?
	blt	.T_18AA
	bra	multi_task_loop
;------------------------------------
.T_191A:
	clr	D5
	bra.s	.T_1994
;------------------------------------
.T_1920:
	lea	ACC_ewait_f_t(A4),A0
	tst.b	(a0,d5)
	beq.s	.T_1992
	move	D5,D0
	asl.l	#1,D0
	lea	ACC_event_flag_t(A4),A0
	move	(a0,d0),temp_word_1(A4)
	cmpi	#$40,temp_word_1(A4)
	bne.s	.T_1954
	move	#$10,temp_word_1(A4)
	bra.s	.T_1964
;------------------------------------
.T_1954:
	cmpi	#$50,temp_word_1(A4)
	bne.s	.T_1964
	move	#$20,temp_word_1(A4)
.T_1964:
	move	event_flags_2(a4),D0
	and	D0,temp_word_1(A4)
	cmpi	#0,temp_word_1(A4)
	beq.s	.T_1992
	move	D5,ACC_current(a4)
	move	#1,ACC_vwk_f(A4)
	jsr	task_handler(PC)
	cmpi	#0,ACC_vwk_f(A4)
	bne.s	.T_1992
	jsr	T_1C98(PC)
.T_1992:
	addq	#1,D5
.T_1994:
	move	D5,D0
	cmp	ACC_count(A4),D0
	blt	.T_1920
	bra	multi_task_loop
;----------------------------------------------------------------------------
;End of:	ETERNAL LOOP ROUTINE
;----------------------------------------------------------------------------
;Start of:	Subroutine 'redraw_scroll_stuff_tree'
;----------------------------------------------------------------------------
redraw_scroll_stuff_tree:
	link	A6,#-$4
	movem.l	D5-D7/A2-A3,-(SP)
	move.l	stuff_tree_p(a4),D6
	move.l	ACC_title_spt_p(A4),D0
	movea.l	D0,A3			;a3 -> ACC_title_spt
	lea	string_p_t(a4),A2
	move	#$14,D5
	move	#5,-$4(A6)
	move	ACC_offset(a4),D0
	add.w	#$12,D0
	move	D0,-$2(A6)
	move	#1,-(SP)
	clr	-(SP)
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	move	#4,-(SP)
	move.l	D6,-(SP)
	jsr	objc_change_sub(PC)
	adda	#$14,SP
	move	#1,-(SP)
	clr	-(SP)
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	move	#$17,-(SP)
	move.l	D6,-(SP)
	jsr	objc_change_sub(PC)
	adda	#$14,SP
	cmpi	#0,ACC_offset(a4)
	bne.s	.T_1A5A
	move	#1,-(SP)
	move	#8,-(SP)
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	move	#4,-(SP)
	move.l	D6,-(SP)
	jsr	objc_change_sub(PC)
	adda	#$14,SP
.T_1A5A:
	move	-$2(A6),D0
	cmp	ACC_count(A4),D0
	bne.s	.T_1A8E
	move	#1,-(SP)
	move	#8,-(SP)
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	move	#$17,-(SP)
	move.l	D6,-(SP)
	jsr	objc_change_sub(PC)
	adda	#$14,SP
.T_1A8E:
	move	ACC_offset(a4),D7
	bra.s	.T_1AD2
;
.T_1A96:
	move	D7,D0
	asl.l	#2,D0
	movea.l	A3,A0
	adda	D0,A0
	move.l	(A0),-(SP)
	move	D5,D0
	addq	#1,D5
	asl.l	#2,D0
	movea.l	A2,A0
	adda	D0,A0
	move.l	(A0),-(SP)
	bsr	strcpy
	addq	#8,SP
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	move	-$4(A6),D0
	addq	#1,-$4(A6)
	move	D0,-(SP)
	move.l	D6,-(SP)
	jsr	objc_draw_sub(PC)
	adda	#$10,SP
	addq	#1,D7
.T_1AD2:
	move	D7,D0
	cmp	-$2(A6),D0
	blt	.T_1A96
	movem.l	(SP)+,D5-D7/A2-A3
	unlk	A6
	rts
;----------------------------------------------------------------------------
fix_titles:
	link	A6,#-$2
	movem.l	D6-D7/A3,-(SP)
	move.l	ACC_title_spt_p(A4),a3	;a3 -> ACC_title_spt
	clr	D7			;d7 = 0 as ACC title src index
	move	#20,d6			;d6 = 20 as string_p_t destination index
	move	#20+5,-2(a6)		;temp = 25 as object index for loop further below
;
	cmpi	#20,ACC_count(a4)	;more than 20 ACCs ?
	bgt.s	.T_1B32			;if so, go copy arrows
	move	D7,D0
	asl.l	#2,D0			;d0 = d7 * 4
	addq	#1,D7			;d7 += 1
	move	#20,-(SP)		;push 20 as strncpy maxlen
	move.l	(A3,d0),-(SP)		;push -> ACC00 title as strncpy src
	move.l	spt_38_visACC_00_uparw(A4),-(SP)	;push -> strncpy destination
	jsr	strncpy(PC)		;copy string (max 20 char's)
	adda	#10,SP			;clean stack
	move	#20+4,-(SP)		;push first ACC object number of stuff_tree
	bsr	normalize_object
	addq	#2,SP
	bra.s	.T_1BB6
;
.T_1B32:
	pea	d_up_arrow_s(a4)	;push -> d_up_arrow_s as strcpy src
	move.l	spt_38_visACC_00_uparw(A4),-(SP)	;push -> strcpy destination
	bsr	strcpy
	addq	#8,SP
	pea	d_down_arrow_s(a4)
	move.l	spt_39_visACC_19_downarw(A4),-(SP)
	bsr	strcpy
	addq	#8,SP
	move	#20+23,-(SP)		;d0 = last object number of stuff_tree
	bsr.s	normalize_object
	addq	#2,SP
	move	#20+4,-(SP)		;d0 = first object number of stuff_tree
	bsr.s	normalize_object
	addq	#2,SP
	move	#DISABLED,stuff_tree+4*24+10
	bra.s	.T_1BB6
;------------------------------------
.fix_titles_loop:
	move	D7,D0
	asl.l	#2,D0			;d0 = d7 * 4
	move	#20,-(SP)		;push 20 as strncpy maxlen
	move.l	(A3,d0),-(SP)		;push ACC(d7) title as strncpy src
	move	D6,D0			;d0 = d6 as string index
	cmpi	#20+18,D6		;d0 index for string 20+18 ?
	bne.s	.T_1B8A			;if not, keep d0 = d6 as index
	move	#20+19,D0		;else replace it with d0 = 20+19
.T_1B8A:
	asl	#2,D0			;d0 *= 4
	lea	string_p_t(a4),a0	;a0 -> string_p_t
	move.l	(a0,d0),-(SP)		;push -> string as strncpy destination
	bsr	strncpy			;copy ACC title to string
	adda	#10,SP			;clean stack
	move	-2(a6),-(sp)		;push temp as object index
	bsr.s	normalize_object
	addq	#2,SP			;clean stack
	addq	#1,-2(a6)		;step temp to next object index
	addq	#1,D7			;step d7 to next ACC index
	addq	#1,D6			;step d6 to next string_p_t index
.T_1BB6:
	move	ACC_count(a4),d1
	cmpi	#20,d1			;more than 20 ACCs ?
	ble.s	.T_1BCE
	move	#18,D1			;18 visible if more than 20 ACCS
.T_1BCE:
	cmp	D1,d7			;D7 < visible ACCs
	blt.s	.fix_titles_loop
	movem.l	(SP)+,D6-D7/A3
	unlk	A6
	rts
;----------------------------------------------------------------------------
normalize_object:
	link	a6,#0
	move	8(a6),d0			;d0 = object number
	muls	#$18,d0				;d0 = object offset
	lea	about_tree(a4),a0		;a0 -> about_tree object 0
	adda	d0,a0				;a0 -> chosen object
	move	#TOUCHEXIT|EXIT|SELECTABLE,8(A0)
	move	#NORMAL,10(A0)
	cmpi	#20+23,8(A6)			;last object of stuff_tree ?
	bne.s	.T_1C1E
	ori	#LASTOB,8(A0)
.T_1C1E:
	unlk	A6
	rts
;----------------------------------------------------------------------------
	link	a6,#0
	move	8(a6),d0			;d0 = object number
	muls	#$18,d0				;d0 = object offset
	lea	about_tree(a4),a0		;a0 -> about_tree object 0
	adda	d0,a0				;a0 -> chosen object
	move	#HIDETREE,8(A0)
	move	#DISABLED,10(A0)
	cmpi	#20+23,8(A6)			;last object of stuff_tree ?
	bne	.T_1C1E
	ori	#LASTOB,8(A0)
.T_1C66:
	unlk	A6
	rts
;----------------------------------------------------------------------------
kick_screen:
	jsr	lock_screen
release_screen:
	clr	-(SP)
	jsr	wind_update_sub(PC)
	addq	#2,SP
	rts
;----------------------------------------------------------------------------
lock_screen:
	move	#1,-(SP)
	jsr	wind_update_sub(PC)
	addq	#2,SP
	rts
;----------------------------------------------------------------------------
release_mouse:
	move	#2,-(SP)
	jsr	wind_update_sub(PC)
	addq	#2,SP
	rts
;----------------------------------------------------------------------------
lock_mouse:
	move	#3,-(SP)
	jsr	wind_update_sub(PC)
	addq	#2,SP
	rts
;----------------------------------------------------------------------------
T_1C98:
	lea	ACC_ewait_f_t(A4),A0
	adda	ACC_current(a4),A0
	sf	(A0)
	move	#-$1,-$1A08(A4)
	rts
;----------------------------------------------------------------------------
has_ACC_wind:
	link	A6,#0
	move	D7,-(SP)
	lea	open_wind_t(A4),A0
	clr	D7
.loop:
	move	D7,D0
	cmpi	#0,2(a0,d0)		;is this window active ?
	ble.s	.next_window
	move	(a0,d0),D0
	cmp	ACC_current(a4),D0	;does current ACC own this window ?
	bne.s	.next_window
	move	#1,D0		;return 1, ==  current ACC owns some window
	bra.s	.exit
;
.next_window:
	addq	#4,D7
	cmpi	#8*4,D7			;checked 8 windows yet ?
	blt.s	.loop
	move	#0,D0		;return 0, ==  current ACC owns no windows
.exit:
	move	(SP)+,D7
	unlk	A6
	rts
;----------------------------------------------------------------------------
T_1D02:	link	A6,#0
	move	D7,-(SP)
	move	#1,-$1FB4(A4)
	move	#3,-$1FB2(A4)
	move	#1,-$1FB0(A4)
	move	#4,D7
	bra.s	T_1D30
;------------------------------------
T_1D22:	move	D7,D0
	addq	#1,D7
	asl.l	#1,D0
	lea	-$1FB6(A4),A0
	adda	D0,A0
	clr	(A0)
T_1D30:	cmpi	#14,D7
	blt	T_1D22
	move	(SP)+,D7
	unlk	A6
	rts
;----------------------------------------------------------------------------
;This sub closes all stuffed ACC's by calling the task_handler for each ACC
;
AC_CLOSE_all_sub:
	link	A6,#0
	move	D7,-(SP)
	move	#-1,-$1A08(A4)
	lea	open_wind_t(A4),A0
	moveq	#8-1,d7
.loop_1:
	clr.l	(A0)+
	dbra	d7,.loop_1
	clr	D7
	bra.s	.T_1D9E
;
.loop_2:
	move	D7,D0
	asl.l	#1,D0
	lea	ACC_event_flag_t(A4),A0
	cmpi	#0,(A0,d0)
	beq.s	.next_ACC
	move	D7,ACC_current(a4)
	move	#AC_CLOSE,mesag_buf_2(a4)
	move	D7,D0
	addq	#1,D0				;d0 = ACC_id = index + 1
	move	D0,mesag_buf_2+06(a4)
	jsr	task_handler(PC)
	lea	ACC_ewait_f_t(A4),A0
	sf	(a0,d7)
.next_ACC:
	addq	#1,D7
.T_1D9E:
	move	D7,D0
	cmp	ACC_count(A4),D0
	blt.s	.loop_2
	move	(SP)+,D7
	unlk	A6
	rts
;----------------------------------------------------------------------------
;This sub erases all stuffed ACC's by calling mfree for each ACC
;
erase_all_sub:
	movem.l	d0-d3/a0-a3,-(SP)
	move.l	ACC_loc_t_p(pc),a3
	move	ACC_count(A4),D3
	ble.s	.exit
	subq	#1,d3
.erase_loop:
	move.l	(a3),a0
	move.l	bp_environ_p(a0),d0
	beq.s	.done_environment
	gemdos	Mfree|_ind,d0
.done_environment:
	gemdos	Mfree|_ind,<(a3)>
	addq	#8,a3
	dbra	d3,.erase_loop
.exit:
	movem.l	(SP)+,D0-d3/a0-a3
	rts
;----------------------------------------------------------------------------
open_main_vwk:
	link	A6,#0
;
	lea	work_in+11*2(a4),a0
	moveq	#1,d0
	moveq	#11-1,d1
.init_work_in:
	move	d0,-(a0)
	move	d0,vdi_intin-work_in(a0)
	dbra	d1,.init_work_in
;
	move	#2,D0
	move	D0,-$1A38(A4)
	move	D0,-$1BD6(A4)
;
	move	wk_handle(a4),vwk_handle(a4)
	pea	work_out(a4)
	pea	vwk_handle(a4)
	pea	work_in(a4)
	jsr	v_opnvwk_sub(PC)
	adda	#12,SP
;
	unlk	A6
	rts
;----------------------------------------------------------------------------
aes_call:
	move.l	A1,-$2686(A4)
	move.l	A2,-$268A(A4)
	move.l	4(SP),D1
	move	#$C8,D0
	trap	#2			;aes
	movea.l	-$2686(A4),A1
	movea.l	-$268A(A4),A2
	rts
;----------------------------------------------------------------------------
T_1E28:
	dc.b	$0,$1,$0	;10
	dc.b	$2,$1,$1	;11
	dc.b	$2,$1,$1	;12
	dc.b	$0,$1,$1	;13
	dc.b	$2,$1,$1	;14
	dc.b	$1,$1,$1	;15
	dc.b	$0,$0,$0	;16
	dc.b	$0,$0,$0	;17
	dc.b	$0,$0,$0	;18
	dc.b	$0,$1,$0	;19
	dc.b	$0,$1,$0	;20 evnt_keybd
	dc.b	$3,$5,$0	;21 evnt_button
	dc.b	$5,$5,$0	;22 evnt_mouse
	dc.b	$0,$1,$1	;23 evnt_mesag
	dc.b	$2,$1,$0	;24 evnt_timer
	dc.b	$10,$7,$1	;25 evnt_multi
	dc.b	$2,$1,$0	;26
	dc.b	$0,$0,$0	;27
	dc.b	$0,$0,$0	;28
	dc.b	$0,$0,$0	;29
	dc.b	$1,$1,$1,$2,$1,$1,$2,$1,$1,$2,$1,$1,$1,$1,$2
	dc.b	$1,$1,$1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$2,$1,$1,$1,$1,$1,$6,$1,$1,$4,$1,$1,$1,$3,$1
	dc.b	$2,$1,$1,$4,$2,$1,$8,$1,$1,$0,$0,$0,$0,$0,$0
	dc.b	$1,$1,$1,$9,$1,$1,$1,$1,$1,$1,$1,$0,$0,$5,$1
	dc.b	$3,$3,$1,$2,$2,$1,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$4,$3,$0,$8,$3,$0,$6,$1,$0,$8,$1,$0,$8,$1,$0
	dc.b	$4,$1,$1,$3,$1,$1,$0,$5,$0,$1,$1,$1,$0,$5,$0
	dc.b	$0,$1,$1,$0,$1,$1,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$2,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$5,$1,$0,$5,$1,$0,$1,$1,$0,$1,$1,$0,$2,$5,$0
	dc.b	$6,$1,$0,$2,$1,$0,$1,$1,$0,$6,$5,$0,$0,$0,$0
	dc.b	$0,$1,$1,$0,$1,$0,$2,$1,$0,$2,$1,$1,$1,$1,$1
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$1,$2,$3,$1,$2,$1,$1,$1,$1,$1,$1,$0,$1,$1
	dc.b	$0,$1,$2
;------------------------------------
aes_sub:
	link	A6,#-$6
	move	8(A6),contrl(A4)
	move	8(A6),D0
	sub	#10,D0
	muls	#3,D0
	lea	T_1E28(PC),A0
	adda	D0,A0
	move.l	A0,-$6(A6)
	move	#1,-$2(A6)
	bra.s	.T_1FD0
;------------------------------------
.T_1FB2:
	movea.l	-$6(A6),A0
	addq.l	#1,-$6(A6)
	move.b	(A0),D0
	move	-$2(A6),D1
	asl.l	#1,D1
	lea	contrl(A4),A0
	adda	D1,A0
	ext.w	D0
	move	D0,(A0)
	addq	#1,-$2(A6)
.T_1FD0:
	cmpi	#4,-$2(A6)
	blt.s	.T_1FB2
	move.l	aespb_p(A4),-(SP)
	jsr	aes_call(PC)
	addq	#4,SP
	move	aes_intout(A4),D0
	unlk	A6
	rts
;----------------------------------------------------------------------------
appl_init_sub:
	link	A6,#-$2
	lea	contrl(A4),A0
	move.l	A0,aespb(A4)
	lea	global(A4),A0
	move.l	A0,aespb+4(A4)
	lea	aes_intin(A4),A0
	move.l	A0,aespb+8(A4)
	lea	aes_intout(A4),A0
	move.l	A0,aespb+12(A4)
	lea	addrin(A4),A0
	move.l	A0,aespb+16(A4)
	lea	addrout(A4),A0
	move.l	A0,aespb+20(A4)
	lea	aespb(A4),A0
	move.l	A0,aespb_p(A4)
	move	#appl_init&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	move	aes_intout(A4),appl_id(A4)
	move	#1,D0
	unlk	A6
	rts
;----------------------------------------------------------------------------
appl_exit_sub:
	move	#appl_exit&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	rts
;----------------------------------------------------------------------------
kbshift_plus:
	move.l	t_la_base_p(pc),a0
	move	la_mouse_bt(a0),d1
	and	#3,d1
	move.b	mouse_bt_t(pc,d1),d1
	move.l	t_kbshift_p(pc),a0
	move.b	(a0),d0
	and	#$1F,d0
	or.b	d1,d0
	rts
;
mouse_bt_t:
	dc.b	$00,$40,$20,$60
;----------------------------------------------------------------------------
evnt_button_sub:
	link	A6,#0
	move	8(A6),aes_intin(A4)
	move	10(A6),aes_intin+2(A4)
	move	12(A6),aes_intin+4(A4)
	move	#evnt_button&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	movea.l	14(A6),A0
	move	aes_intout+2(A4),(A0)
	movea.l	$12(A6),A0
	move	aes_intout+4(A4),(A0)
	movea.l	$16(A6),A0
	move	aes_intout+6(A4),(A0)
	movea.l	$1A(A6),A0
	move	aes_intout+8(A4),(A0)
	move	aes_intout(A4),D0
	unlk	A6
	rts
;----------------------------------------------------------------------------
evnt_multi_sub:
	link	A6,#0
	move	8(A6),aes_intin(A4)
	move	10(A6),aes_intin+2(A4)
	move	12(A6),aes_intin+4(A4)
	move	14(A6),aes_intin+6(A4)
	move	$10(A6),aes_intin+8(A4)
	move	$12(A6),aes_intin+10(A4)
	move	$14(A6),aes_intin+12(A4)
	move	$16(A6),aes_intin+14(A4)
	move	$18(A6),aes_intin+16(A4)
	move	$1A(A6),aes_intin+18(A4)
	move	$1C(A6),aes_intin+20(A4)
	move	$1E(A6),aes_intin+22(A4)
	move	$20(A6),aes_intin+24(A4)
	move	$22(A6),aes_intin+26(A4)
	move.l	$24(A6),addrin(A4)
	move	$28(A6),aes_intin+28(A4)
	move	$2A(A6),aes_intin+30(A4)
	move	#evnt_multi&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	movea.l	$2C(A6),A0
	move	aes_intout+2(A4),(A0)
	movea.l	$30(A6),A0
	move	aes_intout+4(A4),(A0)
	movea.l	$34(A6),A0
	move	aes_intout+6(A4),(A0)
	movea.l	$38(A6),A0
	move	aes_intout+8(A4),(A0)
	movea.l	$3C(A6),A0
	move	aes_intout+10(A4),(A0)
	movea.l	$40(A6),A0
	move	aes_intout+12(A4),(A0)
	move	aes_intout(A4),D0
	unlk	A6
	rts
;----------------------------------------------------------------------------
evnt_timer_sub:
	link	A6,#0
	move.l	8(a6),d0
	swap	d0
	move.l	d0,aes_intin(A4)
	move	#evnt_timer&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
menu_register_sub:
	link	A6,#0
	move	8(A6),aes_intin(A4)
	move.l	10(A6),addrin(A4)
	move	#menu_register&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
objc_draw_sub:
	link	A6,#0
	move.l	8(A6),addrin(A4)
	move	12(A6),aes_intin(A4)
	move	14(A6),aes_intin+2(A4)
	move	$10(A6),aes_intin+4(A4)
	move	$12(A6),aes_intin+6(A4)
	move	$14(A6),aes_intin+8(A4)
	move	$16(A6),aes_intin+10(A4)
	move	#objc_draw&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;int	objc_find_sub(tree_p, startobj, depth, x, y)
;
objc_find_sub:
	link	A6,#0
	move.l	8(A6),addrin(A4)
	move	12(A6),aes_intin(A4)
	move	14(A6),aes_intin+2(A4)
	move	$10(A6),aes_intin+4(A4)
	move	$12(A6),aes_intin+6(A4)
	move	#objc_find&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
objc_offset_sub:
	link	A6,#0
	move.l	8(A6),addrin(A4)
	move	12(A6),aes_intin(A4)
	move	#objc_offset&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	movea.l	14(A6),A0
	move	aes_intout+2(A4),(A0)
	movea.l	$12(A6),A0
	move	aes_intout+4(A4),(A0)
	move	aes_intout(A4),D0
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
objc_change_sub:
	link	A6,#0
	move.l	8(A6),addrin(A4)
	move	12(A6),aes_intin(A4)
	move	14(A6),aes_intin+2(A4)
	move	$10(A6),aes_intin+4(A4)
	move	$12(A6),aes_intin+6(A4)
	move	$14(A6),aes_intin+8(A4)
	move	$16(A6),aes_intin+10(A4)
	move	$18(A6),aes_intin+12(A4)
	move	$1A(A6),aes_intin+14(A4)
	move	#objc_change&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
form_dial_sub:
	link	A6,#0
	move	8(A6),aes_intin(A4)
	move	10(A6),aes_intin+2(A4)
	move	12(A6),aes_intin+4(A4)
	move	14(A6),aes_intin+6(A4)
	move	$10(A6),aes_intin+8(A4)
	move	$12(A6),aes_intin+10(A4)
	move	$14(A6),aes_intin+12(A4)
	move	$16(A6),aes_intin+14(A4)
	move	$18(A6),aes_intin+16(A4)
	move	#form_dial&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
form_alert_sub:
	link	A6,#0
	move	8(A6),aes_intin(A4)
	move.l	10(A6),addrin(A4)
	move	#form_alert&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
form_center_sub:
	link	A6,#0
	move.l	8(A6),addrin(A4)
	move	#form_center&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	movea.l	12(A6),A0
	move	aes_intout+2(A4),(A0)
	movea.l	$10(A6),A0
	move	aes_intout+4(A4),(A0)
	movea.l	$14(A6),A0
	move	aes_intout+6(A4),(A0)
	movea.l	$18(A6),A0
	move	aes_intout+8(A4),(A0)
	move	aes_intout(A4),D0
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
graf_watchbox_sub:
	link	A6,#0
	move.l	8(A6),addrin(A4)
	move	12(A6),aes_intin+2(A4)
	move	14(A6),aes_intin+4(A4)
	move	$10(A6),aes_intin+6(A4)
	move	#graf_watchbox&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
graf_handle_sub:
	link	A6,#0
	move	#graf_handle&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	movea.l	8(A6),A0
	move	aes_intout+2(A4),(A0)
	movea.l	12(A6),A0
	move	aes_intout+4(A4),(A0)
	movea.l	$10(A6),A0
	move	aes_intout+6(A4),(A0)
	movea.l	$14(A6),A0
	move	aes_intout+8(A4),(A0)
	move	aes_intout(A4),D0
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
graf_mouse_sub:
	link	A6,#0
	move	8(A6),aes_intin(A4)
	move.l	10(A6),addrin(A4)
	move	#graf_mouse&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
wind_get_sub:
	link	A6,#0
	move	8(A6),aes_intin(A4)
	move	10(A6),aes_intin+2(A4)
	move	#wind_get&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	movea.l	12(A6),A0
	move	aes_intout+2(A4),(A0)
	movea.l	$10(A6),A0
	move	aes_intout+4(A4),(A0)
	movea.l	$14(A6),A0
	move	aes_intout+6(A4),(A0)
	movea.l	$18(A6),A0
	move	aes_intout+8(A4),(A0)
	move	aes_intout(A4),D0
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
wind_update_sub:
	link	A6,#0
	move	8(A6),aes_intin(A4)
	move	#wind_update&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
rsrc_obfix_sub:
	link	A6,#0
	move.l	8(A6),addrin(A4)
	move	12(A6),aes_intin(A4)
	move	#rsrc_obfix&$ff,-(SP)
	jsr	aes_sub(PC)
	addq	#2,SP
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
bios_sub:
	move.l	A1,-$2686(A4)
	move.l	A2,-$268A(A4)
	move.l	(SP)+,-$268E(A4)
	trap	#13
	movea.l	-$2686(A4),A1
	movea.l	-$268A(A4),A2
	move.l	-$268E(A4),-(SP)
	rts
;
;----------------------------------------------------------------------------
;
xbios_sub:
	move.l	A1,-$2686(A4)
	move.l	A2,-$268A(A4)
	move.l	(SP)+,-$268E(A4)
	trap	#14
	movea.l	-$2686(A4),A1
	movea.l	-$268A(A4),A2
	move.l	-$268E(A4),-(SP)
	rts
;
;----------------------------------------------------------------------------
;
gemdos_sub:
	move.l	A1,-$2686(A4)
	move.l	A2,-$268A(A4)
	move.l	(SP)+,-$268E(A4)
	trap	#1
	movea.l	-$2686(A4),A1
	movea.l	-$268A(A4),A2
	move.l	-$268E(A4),-(SP)
	rts
;
;----------------------------------------------------------------------------
;
strcpy:
	link	A6,#0
	movea.l	8(A6),A0
	move.l	A0,D0
	movea.l	12(A6),A1
T_2430:	move.b	(A1)+,(A0)+
	bne.s	T_2430
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
strncpy:
	link	A6,#-$4
	movem.l	D7/A2-A3,-(SP)
	movea.l	8(A6),A3
	movea.l	12(A6),A2
	move	$10(A6),D7
	move.l	A3,-$4(A6)
.T_2450:
	move	D7,D0
	subq	#1,D7
	tst	D0
	beq.s	.T_2460
	move.b	(A2)+,D0
	move.b	D0,(A3)+
	bne.s	.T_2450
.T_2460:
	move.l	-$4(A6),D0
	movem.l	(SP)+,D7/A2-A3
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
vdi_call:
	move.l	A1,-$2686(A4)
	move.l	A2,-$268A(A4)
	lea	control(A4),a0
	move.l	a0,vdipb(A4)
	lea	vdipb(A4),a0
	move.l	a0,d1
	move.l	#$73,D0
	trap	#2			;vdi
	movea.l	-$2686(A4),A1
	movea.l	-$268A(A4),A2
	rts
;
;----------------------------------------------------------------------------
;
v_opnvwk_sub:
	link	A6,#0
	move.l	8(A6),vdipb+4(A4)		;use 'workin[0..]' for 'intin'
	move.l	16(A6),vdipb+12(A4)		;use 'workout[0..]' for 'intout'
	move.l	16(A6),D0
	add.l	#45*2,D0
	move.l	D0,vdipb+16(A4)			;use 'workout[45..]' for 'ptsout'
	move	#v_opnvwk&$ff,control(A4)
	clr	control+2(A4)			;there are no points in 'ptsin'
	move	#11,control+6(A4)		;there are 11 words in 'intin'
	movea.l	12(A6),A0
	move	(A0),control+12(A4)		;set physical wk_handle
	jsr	vdi_call(PC)
	movea.l	12(A6),A0
	move	control+12(A4),(A0)		;get logical vwk_handle to caller
	lea	vdi_intin(A4),A0
	move.l	A0,vdipb+4(A4)
	lea	vdi_intout(A4),A0
	move.l	A0,vdipb+12(A4)
	lea	ptsout(A4),A0
	move.l	A0,vdipb+16(A4)
	lea	ptsin(A4),A0
	move.l	A0,vdipb+8(A4)
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
v_clsvwk_sub:
	link	A6,#0
	move	#v_clsvwk&$ff,control(A4)
	clr	control+2(A4)
	clr	control+6(A4)
	move	8(A6),control+12(A4)
	jsr	vdi_call(PC)
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;void	vq_mouse(vwk, butt_p, x_p, y_p)
;
vq_mouse_sub:
	link	A6,#0
	move	#vq_mouse&$ff,control(A4)
	clr	control+2(A4)
	clr	control+6(A4)
	move	8(A6),control+12(A4)
	jsr	vdi_call(PC)
	movea.l	10(A6),A0
	move	vdi_intout(A4),(A0)
	movea.l	14(A6),A0
	move	ptsout(A4),(A0)
	movea.l	$12(A6),A0
	move	ptsout+2(A4),(A0)
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
vqt_attributes_sub:
	link	A6,#0
	move	#vqt_attributes&$ff,control(A4)
	clr	control+2(A4)
	clr	control+6(A4)
	move	8(A6),control+12(A4)
	move.l	10(a6),a0
	move.l	a0,vdipb+12(a4)
	lea	12(a0),a0
	move.l	a0,vdipb+16(a4)
	jsr	vdi_call(PC)
	lea	vdi_intout(A4),A0
	move.l	A0,vdipb+12(A4)
	lea	ptsout(A4),A0
	move.l	A0,vdipb+16(A4)
	unlk	A6
	rts
;
;----------------------------------------------------------------------------
;
init_main:
	lea	string_p_t(a4),A1
	lea	d_null_1_s(A4),A0	;spt 00
	move.l	A0,(A1)+
	lea	d_NewStuffer_s(a4),A0	;spt 01
	move.l	A0,(A1)+
	lea	d_copyright_s(a4),A0	;spt 02
	move.l	A0,(A1)+
	lea	d_shareware_s(a4),A0	;spt 03
	move.l	A0,(A1)+
	lea	d_product_s(a4),A0	;spt 04
	move.l	A0,(A1)+
	lea	d_dclick_s(a4),A0	;spt 05
	move.l	A0,(A1)+
	lea	d_URAn_rev_s(a4),A0	;spt 06
	move.l	A0,(A1)+
	lea	d_for_docs_s(a4),A0	;spt 07
	move.l	A0,(A1)+
	lea	d_donation_s(a4),A0	;spt 08
	move.l	A0,(A1)+
	lea	d_program_by_s(a4),A0	;spt 09
	move.l	A0,(A1)+
	lea	d_GEM_by_s(a4),A0	;spt 10
	move.l	A0,(A1)+
	lea	d_Gerdes_s(a4),A0	;spt 11
	move.l	A0,(A1)+
	lea	d_Vederman_s(a4),A0	;spt 12
	move.l	A0,(A1)+
	lea	d_dcstuff_2_s(a4),A0	;spt 13
	move.l	A0,(A1)+
	lea	d_dclick_2_s(a4),A0	;spt 14
	move.l	A0,(A1)+
	lea	d_p_o_box_s(a4),A0	;spt 15
	move.l	A0,(A1)+
	lea	d_null_2_s(a4),A0	;spt 16
	move.l	A0,(A1)+
	lea	d_houston_s(a4),A0	;spt 17
	move.l	A0,(A1)+
	lea	d_about_s(a4),A0	;spt 18
	move.l	A0,(A1)+
	lea	d_dashline_s(a4),A0	;spt 19
	move.l	A0,(A1)+
	lea	d_visACC_01_s(A4),A0	;spt 20
	move.l	A0,(A1)+
	lea	d_visACC_02_s(A4),A0	;spt 21
	move.l	A0,(A1)+
	lea	d_visACC_03_s(A4),A0	;spt 22
	move.l	A0,(A1)+
	lea	d_visACC_04_s(A4),A0	;spt 23
	move.l	A0,(A1)+
	lea	d_visACC_05_s(A4),A0	;spt 24
	move.l	A0,(A1)+
	lea	d_visACC_06_s(A4),A0	;spt 25
	move.l	A0,(A1)+
	lea	d_visACC_07_s(A4),A0	;spt 26
	move.l	A0,(A1)+
	lea	d_visACC_08_s(A4),A0	;spt 27
	move.l	A0,(A1)+
	lea	d_visACC_09_s(A4),A0	;spt 28
	move.l	A0,(A1)+
	lea	d_visACC_10_s(A4),A0	;spt 29
	move.l	A0,(A1)+
	lea	d_visACC_11_s(A4),A0	;spt 30
	move.l	A0,(A1)+
	lea	d_visACC_12_s(A4),A0	;spt 31
	move.l	A0,(A1)+
	lea	d_visACC_13_s(A4),A0	;spt 32
	move.l	A0,(A1)+
	lea	d_visACC_14_s(A4),A0	;spt 33
	move.l	A0,(A1)+
	lea	d_visACC_15_s(A4),A0	;spt 34
	move.l	A0,(A1)+
	lea	d_visACC_16_s(A4),A0	;spt 35
	move.l	A0,(A1)+
	lea	d_visACC_17_s(A4),A0	;spt 36
	move.l	A0,(A1)+
	lea	d_visACC_18_s(A4),A0	;spt 37
	move.l	A0,(A1)+
	lea	d_visACC_00_s(A4),A0	;spt 38
	move.l	A0,(A1)+
	lea	d_visACC_19_s(A4),A0	;spt 39
	move.l	A0,(A1)+
	lea	d_now_loading_s(a4),A0	;spt 40
	move.l	A0,(A1)+
	lea	d_copyright_2_s(a4),A0	;spt 41
	move.l	A0,(A1)+
	lea	d_right_shift_s(a4),A0	;spt 42
	move.l	A0,(A1)+
	lea	d_extras_s(a4),A0	;spt 43
	move.l	A0,(A1)+
;
	lea	b_t1_10_image(A4),A1
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$7FF,(A1)+
	move	#-$20,(A1)+
	move	#$600,(A1)+
	move	#$60,(A1)+
	move	#$600,(A1)+
	move	#$60,(A1)+
	move	#$7FF,(A1)+
	move	#-$20,(A1)+
	move	#$600,(A1)+
	move	#$60,(A1)+
	move	#$67E,(A1)+
	move	#$60,(A1)+
	move	#$666,(A1)+
	move	#$60,(A1)+
	move	#$67E,(A1)+
	move	#$60,(A1)+
	move	#$666,(A1)+
	move	#$60,(A1)+
	move	#$607,(A1)+
	move	#-$1FA0,(A1)+
	move	#$606,(A1)+
	move	#$60,(A1)+
	move	#$606,(A1)+
	move	#$60,(A1)+
	move	#$607,(A1)+
	move	#-$1FA0,(A1)+
	move	#$600,(A1)+
	move	#$7E60,(A1)+
	move	#$600,(A1)+
	move	#$6060,(A1)+
	move	#$600,(A1)+
	move	#$6060,(A1)+
	move	#$600,(A1)+
	move	#$7E60,(A1)+
	move	#$600,(A1)+
	move	#$60,(A1)+
	move	#$7FF,(A1)+
	move	#-$20,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
;
	lea	b_t1_10_bitblk(A4),A1
	lea	b_t1_10_image(A4),A0
	move.l	A0,(A1)+
	move	#4,(A1)+
	move	#$1A,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#1,(A1)+
;
	lea	b_t1_01_ti(A4),A1
;b_t1_01_ti
	move.l	spt_01_NewStuffer(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#2,(A1)+
	move	#$1071,(A1)+
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#$1A,(A1)+
	move	#1,(A1)+
;b_t1_02_ti
	move.l	spt_02_copyright(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#5,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1000,(A1)+
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#15,(A1)+
	move	#1,(A1)+
;b_t1_06_ti
	move.l	spt_05_dclick(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1280,(A1)+
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#$18,(A1)+
	move	#1,(A1)+
;b_t1_11_ti
	move.l	spt_09_program_by(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#5,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#1,(A1)+
	move	#11,(A1)+
	move	#1,(A1)+
;b_t1_12_ti
	move.l	spt_10_GEM_by(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#5,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#1,(A1)+
	move	#7,(A1)+
	move	#1,(A1)+
;b_t1_13_ti
	move.l	spt_11_Gerdes(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#5,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#13,(A1)+
	move	#1,(A1)+
;b_t1_14_ti
	move.l	spt_12_Vederman(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#5,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#14,(A1)+
	move	#1,(A1)+
;b_t2_01_ti
	move.l	spt_18_about(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#11,(A1)+
	move	#1,(A1)+
;b_t2_03_ti
	move.l	spt_19_dashline(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_04_ti
	move.l	spt_38_visACC_00_uparw(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_05_ti
	move.l	spt_20_visACC_01(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_06_ti
	move.l	spt_21_visACC_02(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_07_ti
	move.l	spt_22_visACC_03(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_08_ti
	move.l	spt_23_visACC_04(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_09_ti
	move.l	spt_24_visACC_05(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_10_ti
	move.l	spt_25_visACC_06(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_11_ti
	move.l	spt_26_visACC_07(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_12_ti
	move.l	spt_27_visACC_08(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_13_ti
	move.l	spt_28_visACC_09(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_14_ti
	move.l	spt_29_visACC_10(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_15_ti
	move.l	spt_30_visACC_11(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_16_ti
	move.l	spt_31_visACC_12(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_17_ti
	move.l	spt_32_visACC_13(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_18_ti
	move.l	spt_33_visACC_14(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_19_ti
	move.l	spt_34_visACC_15(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_20_ti
	move.l	spt_35_visACC_16(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_21_ti
	move.l	spt_36_visACC_17(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_22_ti
	move.l	spt_37_visACC_18(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t2_23_ti
	move.l	spt_39_visACC_19_downarw(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;b_t3_01_ti
	move.l	spt_40_now_loading(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#2,(A1)+
	move	#$1072,(A1)+
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#$1B,(A1)+
	move	#1,(A1)+
;b_t3_02_ti
	move.l	spt_41_copyright_2(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#5,(A1)+
	move	#6,(A1)+
	move	#2,(A1)+
	move	#$1180,(A1)+
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#$25,(A1)+
	move	#1,(A1)+
;b_t3_03_ti
	move.l	spt_42_right_shift(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#5,(A1)+
	move	#6,(A1)+
	move	#2,(A1)+
	move	#$1180,(A1)+
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#$25,(A1)+
	move	#1,(A1)+
;b_t2_02_ti
	move.l	spt_43_extras(A4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move.l	spt_00_null_1(a4),(A1)+
	move	#3,(A1)+
	move	#6,(A1)+
	move	#0,(A1)+
	move	#$1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#11,(A1)+
	move	#1,(A1)+
;
	lea	about_tree(a4),A1
;about_obj 0
	move	#-$1,(A1)+
	move	#1,(A1)+
	move	#19,(A1)+
	move	#G_BOX,(A1)+
	move	#NONE,(A1)+
	move	#OUTLINED,(A1)+
	move.l	#$FD1101,(A1)+
	move	#3,(A1)+
	move	#1,(A1)+
	move	#$1D,(A1)+
	move	#$15,(A1)+
;about_obj 1
	move	#3,(A1)+
	move	#2,(A1)+
	move	#2,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t1_01_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$1D,(A1)+
	move	#3,(A1)+
;about_obj 2
	move	#1,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t1_02_ti(A4),A0
	move.l	A0,(A1)+
	move	#9,(A1)+
	move	#2,(A1)+
	move	#$40A,(A1)+
	move	#$600,(A1)+
;about_obj 3
	move	#4,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_03_shareware(A4),(A1)+
	move	#2,(A1)+
	move	#4,(A1)+
	move	#$19,(A1)+
	move	#1,(A1)+
;about_obj 4
	move	#5,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_04_product(A4),(A1)+
	move	#2,(A1)+
	move	#5,(A1)+
	move	#$19,(A1)+
	move	#1,(A1)+
;about_obj 5
	move	#7,(A1)+
	move	#6,(A1)+
	move	#6,(A1)+
	move	#G_BOX,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	#$1123,(A1)+
	move	#0,(A1)+
	move	#7,(A1)+
	move	#$1D,(A1)+
	move	#1,(A1)+
;about_obj 6
	move	#5,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t1_06_ti(A4),A0
	move.l	A0,(A1)+
	move	#3,(A1)+
	move	#0,(A1)+
	move	#$17,(A1)+
	move	#1,(A1)+
;about_obj 7
	move	#8,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_06_URAn_rev(A4),(A1)+
	move	#2,(A1)+
	move	#9,(A1)+
	move	#$18,(A1)+
	move	#1,(A1)+
;about_obj 8
	move	#9,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_07_for_docs(A4),(A1)+
	move	#2,(A1)+
	move	#10,(A1)+
	move	#$18,(A1)+
	move	#1,(A1)+
;about_obj 9
	move	#10,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_08_donation(A4),(A1)+
	move	#2,(A1)+
	move	#11,(A1)+
	move	#$1A,(A1)+
	move	#1,(A1)+
;about_obj 10
	move	#11,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_IMAGE,(A1)+
	move	#SELECTABLE|DEFAULT|EXIT,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t1_10_bitblk(A4),A0
	move.l	A0,(A1)+
	move	#12,(A1)+
	move	#$12,(A1)+
	move	#4,(A1)+
	move	#3,(A1)+
;about_obj 11
	move	#12,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t1_11_ti(A4),A0
	move.l	A0,(A1)+
	move	#1,(A1)+
	move	#$13,(A1)+
	move	#9,(A1)+
	move	#1,(A1)+
;about_obj 12
	move	#13,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t1_12_ti(A4),A0
	move.l	A0,(A1)+
	move	#$12,(A1)+
	move	#$13,(A1)+
	move	#9,(A1)+
	move	#1,(A1)+
;about_obj 13
	move	#14,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t1_13_ti(A4),A0
	move.l	A0,(A1)+
	move	#1,(A1)+
	move	#$14,(A1)+
	move	#9,(A1)+
	move	#1,(A1)+
;about_obj 14
	move	#15,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t1_14_ti(A4),A0
	move.l	A0,(A1)+
	move	#$12,(A1)+
	move	#$14,(A1)+
	move	#10,(A1)+
	move	#1,(A1)+
;about_obj 15
	move	#$10,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_13_dcstuff_2(A4),(A1)+
	move	#10,(A1)+
	move	#13,(A1)+
	move	#10,(A1)+
	move	#1,(A1)+
;about_obj 16
	move	#$11,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_14_dclick_2(A4),(A1)+
	move	#4,(A1)+
	move	#14,(A1)+
	move	#$15,(A1)+
	move	#1,(A1)+
;about_obj 17
	move	#$12,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_15_p_o_box(A4),(A1)+
	move	#6,(A1)+
	move	#15,(A1)+
	move	#$11,(A1)+
	move	#1,(A1)+
;about_obj 18
	move	#$13,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_16_null_2(A4),(A1)+
	move	#9,(A1)+
	move	#$10,(A1)+
	move	#11,(A1)+
	move	#1,(A1)+
;about_obj 19
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_STRING,(A1)+
	move	#LASTOB,(A1)+
	move	#NORMAL,(A1)+
	move.l	spt_17_houston(A4),(A1)+
	move	#5,(A1)+
	move	#$11,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 0
	move	#-$1,(A1)+
	move	#1,(A1)+
	move	#$17,(A1)+
	move	#G_IBOX,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	move.l	#$FC1100,(A1)+
	move	#1,(A1)+
	move	#1,(A1)+
	move	#$14,(A1)+
	move	#$16,(A1)+
;stuff_obj 1
	move	#2,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|DEFAULT|EXIT,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t2_01_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#10,(A1)+
	move	#1,(A1)+
;stuff_obj 2
	move	#3,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t2_02_ti(A4),A0
	move.l	A0,(A1)+
	move	#10,(A1)+
	move	#0,(A1)+
	move	#10,(A1)+
	move	#1,(A1)+
;stuff_obj 3
	move	#4,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#NONE,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_03_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#1,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 4
	move	#5,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT|TOUCHEXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_04_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#2,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 5
	move	#6,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_05_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#3,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 6
	move	#7,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_06_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#4,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 7
	move	#8,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_07_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#5,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 8
	move	#9,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_08_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#6,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 9
	move	#10,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_09_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#7,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 10
	move	#11,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_10_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#8,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 11
	move	#12,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_11_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#9,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 12
	move	#13,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_12_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#10,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 13
	move	#14,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_13_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#11,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 14
	move	#15,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_14_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#12,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 15
	move	#$10,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_15_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#13,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 16
	move	#$11,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_16_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#14,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 17
	move	#$12,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_17_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#15,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 18
	move	#$13,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_18_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#$10,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 19
	move	#$14,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_19_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#$11,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 20
	move	#$15,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_20_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#$12,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 21
	move	#$16,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_21_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#$13,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 22
	move	#$17,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#SELECTABLE|EXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_22_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#$14,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;stuff_obj 23
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#SELECTABLE|EXIT|LASTOB|TOUCHEXIT,(A1)+
	move	#DISABLED,(A1)+
	lea	b_t2_23_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#$15,(A1)+
	move	#$14,(A1)+
	move	#1,(A1)+
;boot_obj 0
	move	#-$1,(A1)+
	move	#1,(A1)+
	move	#3,(A1)+
	move	#G_BOX,(A1)+
	move	#NONE,(A1)+
	move	#OUTLINED,(A1)+
	move.l	#$FE1100,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$20,(A1)+
	move	#7,(A1)+
;boot_obj 1
	move	#2,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_BOXTEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t3_01_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#0,(A1)+
	move	#$20,(A1)+
	move	#2,(A1)+
;boot_obj 2
	move	#3,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#NONE,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t3_02_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#6,(A1)+
	move	#$20,(A1)+
	move	#1,(A1)+
;boot_obj 3
	move	#0,(A1)+
	move	#-$1,(A1)+
	move	#-$1,(A1)+
	move	#G_TEXT,(A1)+
	move	#LASTOB,(A1)+
	move	#NORMAL,(A1)+
	lea	b_t3_03_ti(A4),A0
	move.l	A0,(A1)+
	move	#0,(A1)+
	move	#5,(A1)+
	move	#$41F,(A1)+
	move	#$600,(A1)+
;
	lea	about_tree_p(a4),A1
	lea	about_tree(a4),A0
	move.l	A0,(A1)+		;store about_tree_p
	lea	stuff_tree(a4),A0
	move.l	A0,(A1)+		;store stuff_tree_p
	lea	boot_tree(a4),A0
	move.l	A0,(A1)+		;store boot_tree_p
;
	move	#0,temp_word_1(A4)
	move	#0,-$1A00(A4)
	move	#0,-$1A02(A4)
	move	#-$1,-$1A08(A4)
;
	lea	twelve_space_s(A4),A1
	lea	t_twelve_space_s(pc),a0
	bsr.s	strcpy_ia1_ia0_i
;
	lea	stuffer_path_s(A4),A1
	lea	t_stuffer_path_s(pc),a0
	bsr.s	strcpy_ia1_ia0_i
;
	move	#0,ACC_count(A4)
	move	#0,ACC_offset(a4)
	rts
;
t_twelve_space_s:
	dc.b	'            ',NUL
t_stuffer_path_s:
	dc.b	'A:\STUFFER\',NUL
	even
;
strcpy_ia1_ia0_i:
	move.b	(a0)+,(a1)+
	bne.s	strcpy_ia1_ia0_i
	rts
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'install_vectors'
;----------------------------------------------------------------------------
install_vectors:
	movem.l	d0/a0-a1,-(sp)
;
	lea	(ev_xgem).w,a0
	lea	nu_XGEM(pc),a1
	XB_init
	or.l	d0,vector_err_f
;
	lea	(ev_gemdos).w,a0
	lea	nu_gemdos(pc),a1
	XB_init
	or.l	d0,vector_err_f
;
	lea	(ev_bios).w,a0
	lea	nu_BIOS(pc),a1
	XB_init
	or.l	d0,vector_err_f
;
	movem.l	(sp)+,d0/a0-a1
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'install_vectors'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'remove_vectors'
;----------------------------------------------------------------------------
remove_vectors:
	movem.l	d0/a0-a1,-(sp)
;
	lea	(ev_bios).w,a0
	lea	nu_BIOS(pc),a1
	XB_kill_code
	or.l	d0,vector_err_f
;
	lea	(ev_gemdos).w,a0
	lea	nu_gemdos(pc),a1
	XB_kill_code
	or.l	d0,vector_err_f
;
	lea	(ev_xgem).w,a0
	lea	nu_XGEM(pc),a1
	XB_kill_code
	or.l	d0,vector_err_f
	st	XGEM_linked_p
;
	movem.l	(sp)+,d0/a0-a1
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'remove_vectors'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutines that patch basepage system for ACCs
;----------------------------------------------------------------------------
;
enter_system:
	move.l	autostuff_p(pc),new_currbp_p
	tst	no_cookie_f
	beq.s	.have_stuff
	move.l	t_basepage_p(pc),new_currbp_p
.have_stuff:
	bra.s	patch_system
;
exit_system:
	move.l	old_currbp_p(pc),new_currbp_p
patch_system:
	movem.l	a0-a2,-(sp)
;
	movea.l	t_currbp_p_p(pc),A0	;a0 -> system currbp_p -> current basepage
	movea.l	new_currbp_p(pc),A1
	movea.l	(A0),A2			;a2 -> current basepage
	move.l	A2,old_currbp_p		;store it for future restore
;
	move.l	bp_dta_p(A2),bp_dta_p(A1)
	move.l	$40(A2),$40(A1)
	move.l	$44(A2),$44(A1)
	move.l	$48(A2),$48(A1)
	move.l	$4C(A2),$4C(A1)
;
	move.l	A1,(A0)			;force system currbp_p = new_currbp_p
;
	movem.l	(sp)+,a0-a2
	rts
;
;----------------------------------------------------------------------------
;End of:	Supexec subroutines that patch basepage system for ACCs
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'init_revision'
;----------------------------------------------------------------------------
;
init_revision:
;
	move	(_bootdev).w,t_bootdev
;
	_a_init
	move.l	d0,t_la_base_p
;
	xbios	Iorec,#1
	move.l	d0,t_kb_iorec_p
	move.l	#$602C,t_currbp_p_p	;Some old TOS had this (but maybe not all)
	xbios	Keytbl,?,?,?
	move.l	d0,t_keytbl_ptp
	move.l	d0,a0
	lea	-1(a0),a0	;NB: this assumes Kbshift stored at Keytbl-1
	move.l	a0,t_kbshift_p	;NB: So all early TOS have Kbshift data at Keytbl-1 !!!
	move.l	(_sysbase).w,a1
	move.l	os_selfbeg_p(a1),a0
	move	os_version(a0),d0
	cmp	#$102,d0
	blo.s	.done_sys_fix
	move.l	os_kbshift_p(a0),t_kbshift_p
	move.l	os_currbp_p_p(a0),t_currbp_p_p
.done_sys_fix:
;
	move	sr,d0				;save interrupt mask
	or	#$0700,sr			;disable interrupts
	move.l	(ev_trap5).w,a0			;save trap 5 handler
	move.l	#frame_test,(ev_trap5).w	;patch new trap 5 handler
	move.l	sp,a1				;a1 = 'old_SP'
	trap	#5				;execute trap 5
	illegal		;if we ever come here, the CPU is very sick !!!
;
frame_test:
	move.l	a0,(ev_trap5).w		;restore original trap 5 handler
	sub.l	sp,a1			;a1 = old_SSP - new_SSP  == framesize
	add.l	a1,sp			;sp = old_SSP
	move	a1,framesize		;init 'framesize'
	cmp	#6,a1
	sgt	longframe_f		;init 'longframe_f'
	move	d0,sr			;restore interrupt mask
	bsr	install_vectors
	rts				;exit to caller
;
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'init_revision'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'hotkey_test'
;----------------------------------------------------------------------------
;
hotkey_test:
	movem.l	d0-d4/a0-a3,-(sp)
	clr.l	d4
	move.l	hotkey_code(pc),d3		;d3 = hotkey argument
	move.l	t_keytbl_ptp,a3		;a3 -> -> Unshifted key table
	move	SR,-(sp)		;save status register (interrupt mask)
	move.l	t_kb_iorec_p(pc),a0	;a0 = address of iorec structure
	move	io_tail_ix(a0),d1	;tail index
	or	#$0700,SR		;disable interrupts
	move	io_tail_ix(a0),d1	;tail index
	move	d1,old_tail_ix		;save tail index at old_tail_ix
	cmp	io_head_ix(a0),d1
	beq.s	.return
	move.l	t_kbshift_p(pc),a1	;a1 = address of TOS kbshift variable
	move.b	(a1),d2			;get kbshifts (** TOS independent **)
	and	#$1F,d2			;d2 = masked special keys
	move.l	io_buffer_p(a0),a2	;a2 = address of io-buffer
	move.l	(a2,d1),d0		;get 1'st word for this key = key code.ascii
	and	#$7F,d0			;d0 = masked key code
	tst.l	d3
	bpl.s	.test_it		;use ascii test if d3 >= 0
	neg.l	d3
	swap	d0			;prep for key code test
.test_it:
	cmp	d3,d0			;compare either ascii or key code values
	bne.s	.return
	swap	d3
	and	#$0F,d3
	and	#$0F,d2
	cmp	d3,d2
	seq	d4			;set d4 if specials also equal
.return:
	ext	d4
	ext.l	d4
	beq.s	.exit			;leave buffer as-is if hotkey not found
	subq	#4,d1
	bge.s	.tail_shrunk
	move	io_size_ix(a0),d1
	subq	#4,d1
.tail_shrunk:
	move	d1,io_tail_ix(a0)
	move	d1,old_tail_ix
;
.exit:
	move	(sp)+,sr		;restore interrupt mask
	move.l	d4,hotkey_flag
	movem.l	(sp)+,d0-d4/a0-a3
	rts
;
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'hotkey_test'
;----------------------------------------------------------------------------
;Start of:	subroutine		'give_stuff_screen'
;----------------------------------------------------------------------------
;
give_stuff_screen:
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	clr	-(SP)
	move	#3,-(SP)
	jsr	form_dial_sub(PC)
	adda	#$12,SP
	rts
;
;----------------------------------------------------------------------------
;End of:	subroutine		'give_stuff_screen'
;----------------------------------------------------------------------------
;Start of:	subroutine		'norm_stuff_obj'
;----------------------------------------------------------------------------
;
norm_stuff_obj:
	move	#1,-(SP)
	clr	-(SP)
	move	box_1_h(A4),-(SP)
	move	box_1_w(A4),-(SP)
	move	box_1_y(A4),-(SP)
	move	box_1_x(A4),-(SP)
	clr	-(SP)
	move	scan_object(a4),-(SP)
	move.l	stuff_tree_p(a4),-(SP)
	jsr	objc_change_sub(PC)
	adda	#20,SP
	rts
;
;----------------------------------------------------------------------------
;End of:	subroutine		'norm_stuff_obj'
;----------------------------------------------------------------------------
;Start of:	library routines
;----------------------------------------------------------------------------
;
	make	JAR_links
;
;----------------------------------------------------------------------------
;End of:	library routines
;----------------------------------------------------------------------------
;
	SECTION	DATA
;
;----------------------------------------------------------------------------
;
dz:	;relative zero for data constants
;
d_null_1_s	= *-dz	;$00
	dc.b	NUL
	dc.b	NUL
d_NewStuffer_s	= *-dz	;$02
	dc.b	'NewStuffer Accessory v1.0',NUL
d_copyright_s	= *-dz	;$1C
	dc.b	'Copyright 1988',NUL
	dc.b	NUL
d_shareware_s	= *-dz	;$2C
	dc.b	'DC Stuffer is a SHAREWARE',NUL
d_product_s	= *-dz	;$46
	dc.b	'product brought to you by',NUL
d_dclick_s	= *-dz	;$60
	dc.b	' Double Click Software ',NUL
d_URAn_rev_s	= *-dz	;$78
	dc.b	'URAn rev: 1.5  1999.10.03 ',NUL
	dc.b	NUL
d_for_docs_s	= *-dz	;$94
	dc.b	'For version 1.0 and docs, ',NUL
	dc.b	NUL
d_donation_s	= *-dz	;$B0
	dc.b	'please send a donation to:',NUL
	dc.b	NUL
d_program_by_s	= *-dz	;$CC
	dc.b	'Program by',NUL
	dc.b	NUL
d_GEM_by_s	= *-dz	;$D8
	dc.b	'GEM by',NUL
	dc.b	NUL
d_Gerdes_s	= *-dz	;$E0
	dc.b	'Keith Gerdes',NUL
	dc.b	NUL
d_Vederman_s	= *-dz	;$EE
	dc.b	'Mike Vederman',NUL
d_dcstuff_2_s	= *-dz	;$FC
	dc.b	'DC Stuffer',NUL
	dc.b	NUL
d_dclick_2_s	= *-dz	;$108
	dc.b	'Double Click Software',NUL
d_p_o_box_s	= *-dz	;$11E
	dc.b	'P.O. Box 741206',NUL
	dc.b	't',NUL
d_null_2_s	= *-dz	;$130
	dc.b	NUL
	dc.b	'uite #1181',NUL
d_houston_s	= *-dz	;$13C
	dc.b	'Houston, Texas 77236',NUL
	dc.b	NUL
d_about_s	= *-dz	;$152
	dc.b	'  About...',NUL
	dc.b	NUL
d_dashline_s	= *-dz	;$15E
	dc.b	'--------------------',NUL
	dc.b	NUL
d_clrblk_2	= *-dz
d_nulled_s_t	= *-dz	;$174
	dcb.b	20*22,0
d_visACC_01_s	= d_nulled_s_t+$000	;$174
d_visACC_02_s	= d_nulled_s_t+$016	;$18A
d_visACC_03_s	= d_nulled_s_t+$02C	;$1A0
d_visACC_04_s	= d_nulled_s_t+$042	;$1B6
d_visACC_05_s	= d_nulled_s_t+$058	;$1CC
d_visACC_06_s	= d_nulled_s_t+$06E	;$1E2
d_visACC_07_s	= d_nulled_s_t+$084	;$1F8
d_visACC_08_s	= d_nulled_s_t+$09A	;$20E
d_visACC_09_s	= d_nulled_s_t+$0B0	;$224
d_visACC_10_s	= d_nulled_s_t+$0C6	;$23A
d_visACC_11_s	= d_nulled_s_t+$0DC	;$250
d_visACC_12_s	= d_nulled_s_t+$0F2	;$266
d_visACC_13_s	= d_nulled_s_t+$108	;$27C
d_visACC_14_s	= d_nulled_s_t+$11E	;$292
d_visACC_15_s	= d_nulled_s_t+$134	;$2A8
d_visACC_16_s	= d_nulled_s_t+$14A	;$2BE
d_visACC_17_s	= d_nulled_s_t+$160	;$2D4
d_visACC_18_s	= d_nulled_s_t+$176	;$2EA
d_visACC_00_s	= d_nulled_s_t+$18C	;$300
d_visACC_19_s	= d_nulled_s_t+$1A2	;$316
d_clrblk_2_end	= *-dz  ;$32C
;
d_now_loading_s	= *-dz	;orig $32C
	dc.b	'NewStuffer    Now Loading:',$0,$0
d_copyright_2_s	= *-dz	;orig $348
	dc.b	'Copyright 1988 Double Click Software',$0,$0
d_right_shift_s	= *-dz	;orig $36E
	dc.b	' Press the RIGHT SHIFT key to abort ',$0,$0
;
d_extras_s	= *-dz	;orig $394
	dc.b	'  Extras  ',$0,$0
d_DC_STuffer_s	= *-dz	;orig $3A0
	dc.b	'  DC Stuffer',$0,$0
;
d_Fsearch_s	= *-dz	;orig $3AE
	dc.b	'*.acc',$0
;
d_extras_al_s	= *-dz	;orig $3B4
	dc.b	'[1]['
	dc.b	' This feature is only |'
	dc.b	' available in v1.0! |'
	dc.b	' |'
	dc.b	' Send a contribution! |'
	dc.b	']'
	dc.b	"[ I'll send... ]",$0,$0
;
d_up_arrow_s	= *-dz	;orig $410
	dc.b	'        ',$1,'  ',$1,'        ',$0,$0
d_down_arrow_s	= *-dz	;orig $426
	dc.b	'        ',$2,'  ',$2,'        ',$0,$0
;
datasize = *-dz
;
;----------------------------------------------------------------------------
;
	SECTION	BSS
;
;----------------------------------------------------------------------------
;
	ds.w	4945			;=9890
;
rdz	= *-datasize	;runtime position of data reference point
;
;----------------------------------------------------------------------------
r_null_1_s	= rdz+d_null_1_s
r_NewStuffer_s	= rdz+d_NewStuffer_s
r_copyright_s	= rdz+d_copyright_s
r_shareware_s	= rdz+d_shareware_s
r_product_s	= rdz+d_product_s
r_dclick_s	= rdz+d_dclick_s
r_URAn_rev_s	= rdz+d_URAn_rev_s
r_for_docs_s	= rdz+d_for_docs_s
r_donation_s	= rdz+d_donation_s
r_program_by_s	= rdz+d_program_by_s
r_GEM_by_s	= rdz+d_GEM_by_s
r_Gerdes_s	= rdz+d_Gerdes_s
r_Vederman_s	= rdz+d_Vederman_s
r_dcstuff_2_s	= rdz+d_dcstuff_2_s
r_dclick_2_s	= rdz+d_dclick_s
r_p_o_box_s	= rdz+d_p_o_box_s
r_null_2_s	= rdz+d_null_2_s
r_houston_s	= rdz+d_houston_s
r_about_s	= rdz+d_about_s
r_dashline_s	= rdz+d_dashline_s
r_nulled_s_t	= rdz+d_nulled_s_t
r_visACC_01_s	= rdz+d_visACC_01_s
r_visACC_02_s	= rdz+d_visACC_02_s
r_visACC_03_s	= rdz+d_visACC_03_s
r_visACC_04_s	= rdz+d_visACC_04_s
r_visACC_05_s	= rdz+d_visACC_05_s
r_visACC_06_s	= rdz+d_visACC_06_s
r_visACC_07_s	= rdz+d_visACC_07_s
r_visACC_08_s	= rdz+d_visACC_08_s
r_visACC_09_s	= rdz+d_visACC_09_s
r_visACC_10_s	= rdz+d_visACC_10_s
r_visACC_11_s	= rdz+d_visACC_11_s
r_visACC_12_s	= rdz+d_visACC_12_s
r_visACC_13_s	= rdz+d_visACC_13_s
r_visACC_14_s	= rdz+d_visACC_14_s
r_visACC_15_s	= rdz+d_visACC_15_s
r_visACC_16_s	= rdz+d_visACC_16_s
r_visACC_17_s	= rdz+d_visACC_17_s
r_visACC_18_s	= rdz+d_visACC_18_s
r_visACC_00_s	= rdz+d_visACC_00_s
r_visACC_19_s	= rdz+d_visACC_19_s
r_clrblk_2	= rdz+d_clrblk_2
r_clrblk_2_end	= rdz+d_clrblk_2_end
r_now_loading_s	= rdz+d_now_loading_s
r_copyright_2_s	= rdz+d_copyright_2_s
r_right_shift_s	= rdz+d_right_shift_s
r_extras_s	= rdz+d_extras_s
r_DC_STuffer_s	= rdz+d_DC_STuffer_s
r_Fsearch_s	= rdz+d_Fsearch_s
r_extras_al_s	= rdz+d_extras_al_s
r_up_arrow_s	= rdz+d_up_arrow_s
r_down_arrow_s	= rdz+d_down_arrow_s
;----------------------------------------------------------------------------
r_vdipb		= rdz+vdipb
r_appl_id	= rdz+appl_id
r_aespb_p	= rdz+aespb_p
r_aespb		= rdz+aespb
r_addrout	= rdz+addrout
r_addrin	= rdz+addrin
r_aes_intout	= rdz+aes_intout
r_aes_intin	= rdz+aes_intin
r_global	= rdz+global
r_contrl	= rdz+contrl
r_ACC_tit_spt_p	= rdz+ACC_title_spt_p
r_ACC_name_t	= rdz+ACC_name_t
r_ACC_loc_t	= rdz+ACC_loc_t
r_ACC_offset	= rdz+ACC_offset
r_ACC_count	= rdz+ACC_count
r_stuffer_path_s= rdz+stuffer_path_s
r_twelve_space_s= rdz+twelve_space_s
r_mesag_buf_2	= rdz+mesag_buf_2
r_mesag_buf_1	= rdz+mesag_buf_1
r_event_flags_2	= rdz+event_flags_2
r_ptsout	= rdz+ptsout
r_vdi_intout	= rdz+vdi_intout
r_ptsin		= rdz+ptsin
r_vdi_intin	= rdz+vdi_intin
r_control	= rdz+control
r_clrblk_3	= rdz+b_clrblk_3
r_clrblk_3_end	= rdz+b_clrblk_3_end
r_work_out	= rdz+work_out
r_work_in	= rdz+work_in
r_vwk_handle	= rdz+vwk_handle
r_wk_handle	= rdz+wk_handle
r_main_ACC_id	= rdz+main_ACC_id
r_loc_bootdev	= rdz+loc_bootdev
r_workscreen_h	= rdz+workscreen_h
r_workscreen_w	= rdz+workscreen_w
r_workscreen_y	= rdz+workscreen_y
r_workscreen_x	= rdz+workscreen_x
r_event_flags_1	= rdz+event_flags_1
r_ACC_current	= rdz+ACC_current
r_task_job	= rdz+task_job
r_temp_word_1	= rdz+temp_word_1
r_scan_object	= rdz+scan_object
r_box_1_h	= rdz+box_1_h
r_box_1_w	= rdz+box_1_w
r_box_1_y	= rdz+box_1_y
r_box_1_x	= rdz+box_1_x
r_box_2_h	= rdz+box_2_h
r_box_2_w	= rdz+box_2_w
r_box_2_y	= rdz+box_2_y
r_box_2_x	= rdz+box_2_x
r_loc_dta	= rdz+loc_dta
r_about_tree_p	= rdz+about_tree_p
r_stuff_tree_p	= rdz+stuff_tree_p
r_boot_tree_p	= rdz+boot_tree_p
r_about_tree	= rdz+about_tree
r_stuff_tree	= rdz+stuff_tree
r_boot_tree	= rdz+boot_tree
r_t1_01_ti	= rdz+b_t1_01_ti
r_t1_02_ti	= rdz+b_t1_02_ti
r_string_p_t	= rdz+string_p_t
r_spt_38_visACC_00_uparw	= rdz+spt_38_visACC_00_uparw
r_spt_39_visACC_19_downarw	= rdz+spt_39_visACC_19_downarw
r_clrblk_4	= rdz+b_clrblk_4
r_clrblk_4_end	= rdz+b_clrblk_4_end
r_basepage_p	= rdz+basepage_p
;----------------------------------------------------------------------------
	End
;----------------------------------------------------------------------------
;End of file:	NEWSTUFF.S
;----------------------------------------------------------------------------
