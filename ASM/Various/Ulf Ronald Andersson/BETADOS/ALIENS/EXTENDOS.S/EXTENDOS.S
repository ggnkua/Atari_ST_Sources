;----------------------------------------------------------------------------
;File name:	EXTENDOS.S			Revision date:	1998.08.27
;Revised by:	Ulf Ronald Andersson		Revision start:	1995.07.04
;----------------------------------------------------------------------------
	include	RA_STRUC.I
	include	RA_SYS.I
	include	RA_TOS.I
	include	RA_XB.I
;----------------------------------------------------------------------------
DOS_limit	=	26	;total number of DOS devices allowed
FCB_limit	=	100	;total number of MetaDos FCBs made available
E_999		=	-999
;----------------------------------------------------------------------------
	struct	FCB
	byte	FCB_free,32	;32 free FCB bytes in all MetaDOS
	byte	FCB_extfree,8	;8 free FCB bytes added for ExtenDOS
	long	FCB_owner	;-> basepage of owner process
	long	FCB_DOS_p	;-> DOS or -1 if unused
	d_end	FCB
;----------------------------------------------------------------------------
DOS_next	= 0
DOS_char	= 4
DOS_func_tp	= 6
DOS_path	= 14
DOS_LDB_p	= 270	;-> Logical Device Block
DOS_FSmode_bits	= 274	;.l but only low byte is used
DOS_title_s	= 286	;terminated name string <= 31 chars + term
sizeof_DOS	= 318
;----------------------------------------------------------------------------
BOS_next	= 0	;long -> next BOS_table
BOS_max_trace	= 4	;long = number of trace entries allowed
BOS_char	= 8	;word = physical drive letter
BOS_xCSI_LUN_ID	= 10	;word = ('A'/'S' for ACSI/SCSI)<<8 + LUN<<4 + ID
BOS_xCSI	= 10	;byte = 'A'/'S' for ACSI/SCSI
BOS_LUN_ID	= 11	;byte = LUN<<4 + ID
BOS_IF_2	= 12	;word = -1  (apparently always)
BOS_func_tp	= 14	;long -> table of Metados + FCTL function pointers
BOS_SCSI_ACSI	= 18	;byte = 0 for SCSI I/F or CDAR 504 on ACSI, else 1
BOS_title_s	= 28	;string = name and version of BOS driver
sizeof_BOS	= 60	;so string above is max 32 bytes long (incl NUL)
;----------------------------------------------------------------------------
	RSRESET
meta1_drivemap	rs.l	1	;1 bit per physical Metados drive
meta1_version	rs.l	1	;-> name and version of Metados
meta1_reserved	rs.l	1
meta1_metainfo2	rs.l	1	;-> other structure
;
	RSRESET
meta2_version	rs.l	1	;version of Metados >= $0230
meta2_magic	rs.l	1	;constant '_MET'
meta2_log2phys	rs.l	1	;-> drive translation bytes  gemdos => Meta
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
start:
	movea.l	SP,A5
	move.l	A5,initial_sp
	lea	init_stk_top,SP
	movea.l	4(A5),A5		;a5 -> basepage
	move.l	12(A5),D0
	add.l	$14(A5),D0
	add.l	$1C(A5),D0
	addi.l	#$100,D0
	move.l	D0,-(SP)		;push program size for future Ptermres
	gemdos	Mshrink|_ind,!,a5,d0,
;
	gemdos	Super,!			;Enter Super
	move.l	D0,-(SP)		;Push old SSP
	move.w	#$20,-(SP)		;Push Super
;
	gemdos	Cconws,D_1A76
	bsr	T_302
	bne.s	T_B2
	xbios	Metainit,init_buff_1
	tst.l	init_buff_1+4
	bne.s	abort_boot		;refuse booting if Metados active
	bsr	make_EPro_cookie
	tst.b	B_2793
	bne.s	T_8E
	bsr	test_basepage_usage
	tst.b	B_2793
	bne.s	T_8E
	bsr.s	fix_traps
	bsr	init_extendos
T_8E:
	gemdos	Cconws,extendos_cnf_ended_s
	bsr.s	T_C8
	trap	#1		;gemdos Super as previously prepared
	addq.l	#6,SP
	move.l	(SP)+,D7	;d7 = program size
	gemdos	Ptermres,d7,#0
	illegal
;
;
T_B2:
	moveq	#$ffFFff9B,D0
	bra.s	T_B8
;
abort_boot:
	moveq	#$ffFFff9A,D0
T_B8:
	bsr	show_error_message
	bsr.s	T_C8
	trap	#1
	addq.l	#6,SP
	clr.l	-(SP)
	trap	#1			;Pterm0
	illegal
;
;
T_C8:
	tst.b	B_2793
	beq.s	T_E6
	pea	D_1B70
	move.w	#9,-(SP)
	trap	#1			;Cconws
	addq.l	#6,SP
	move.w	#1,-(SP)
	trap	#1			;Cconin
	addq.l	#2,SP
T_E6:
	rts
;----------------------------------------------------------------------------
fix_traps:
	clr.l	B_5CF6
	movea.l	$4F2.w,A0		;_sysbase
	move.w	2(A0),D0
	cmpi.w	#$100,D0
	bne.s	T_108
	move.l	#$56EC,B_5CF6
	bra.s	T_118
;
T_108:
	cmpi.w	#$102,D0
	bne.s	T_118
	move.l	#$7E8E,B_5CF6
T_118:
	lea	xbios_save_p,A0
	move.l	A0,xbios_save_p
	bsr.s	T_19E
	move.l	D0,loc_currbp_p_p
	move.l	(ev_xbios).w,nu_xbios+8
	move.l	#nu_xbios+12,(ev_xbios).w
	lea	bios_save_p,A0
	move.l	A0,bios_save_p
	move.l	(ev_bios).w,nu_bios+8
	move.l	#nu_bios+12,(ev_bios).w
	move.w	(_bootdev).w,D0
	addi.w	#'A',D0
	move.b	D0,boot_letter
	move.w	#$63,D0
	lea	meta_FCB_t,A0
T_170:
	move.l	#-1,FCB_DOS_p(A0)
	adda.w	#sizeof_FCB,A0
	dbra	D0,T_170
	lea	gemdos_save_p,A0
	move.l	A0,gemdos_save_p
	move.l	(ev_gemdos).w,nu_gemdos+8
	move.l	#nu_gemdos+12,(ev_gemdos).w
	rts
;----------------------------------------------------------------------------
T_19E:
	link	A6,#-$4
	move.l	$4F2.w,-$4(A6)		;_sysbase
	movea.l	-$4(A6),A0
	move.l	8(A0),-$4(A6)
	movea.l	-$4(A6),A0
	cmpi.w	#$102,2(A0)
	bcc.s	T_1DE
	movea.l	-$4(A6),A0
	move.w	$1C(A0),D0
	lsr.w	#1,D0
	cmpi.w	#4,D0
	bne.s	T_1D6
	move.l	#-$78C4,D0
	bra.s	T_1E6
;
T_1D6:
	move.l	#$602C,D0
	bra.s	T_1E6
;
T_1DE:
	movea.l	-$4(A6),A0
	move.l	$28(A0),D0
T_1E6:
	unlk	A6
	rts
;----------------------------------------------------------------------------
test_basepage_usage:
	gemdos	Dgetdrv
	move.w	D0,D7
	gemdos	Dsetdrv,#15
	moveq	#0,D6
	cmpi.b	#15,$37(A5)		;NB: undefined basepage usage
	bne.s	.T_214
	addq.w	#1,D6
	move.b	#$37,bp_drive_index
.T_214:
	cmpi.b	#15,$39(A5)		;NB: undefined basepage usage
	bne.s	.T_226
	addq.w	#1,D6
	move.b	#$39,bp_drive_index
.T_226:
	gemdos	Dsetdrv,d7
	cmpi.w	#1,D6
	beq.s	.T_23C
	moveq	#$ffFFff8E,D0
	bsr	show_error_message
.T_23C:
	rts
;----------------------------------------------------------------------------
make_EPro_cookie:
	move.l	(_cookies).w,D0		;_p_cookies
	bne.s	T_292
	move.l	#$80,-(SP)
	move.w	#$48,-(SP)
	trap	#1			;Malloc
	addq.l	#6,SP
	tst.l	D0
	beq	T_2FA
	move.l	D0,(_cookies).w		;_p_cookies
	movea.l	D0,A0
	moveq	#15,D1
T_260:
	clr.l	(A0)+
	clr.l	(A0)+
	dbra	D1,T_260
	movea.l	D0,A0
	move.l	#$10,4(A0)
	move.l	(resvalid).w,old_resvalid		;resvalid
	move.l	(resvector).w,nu_resvector+8		;resvector
	move.l	#nu_resvector+12,(resvector).w		;resvector
	move.l	#$31415926,(resvalid).w	;resvalid
T_292:
	movea.l	(_cookies).w,A0		;_p_cookies
	moveq	#1,D1
T_298:
	move.l	(A0),D0
	beq.s	T_2A2
	addq.l	#8,A0
	addq.l	#1,D1
	bra.s	T_298
;
T_2A2:
	cmp.l	4(A0),D1	;is cookie jar full ?
	bne.s	T_2E0
	addi.l	#$10,D1
	lsl.l	#3,D1
	move.l	D1,-(SP)
	move.w	#$48,-(SP)
	trap	#1			;Malloc
	addq.l	#6,SP
	tst.l	D0
	beq.s	T_2FA
	movea.l	(_cookies).w,A1		;_p_cookies
	move.l	D0,(_cookies).w		;_p_cookies
	movea.l	D0,A0
T_2C8:
	move.l	4(A1),4(A0)
	move.l	(A1),(A0)
	beq.s	T_2D8
	addq.l	#8,A0
	addq.l	#8,A1
	bra.s	T_2C8
;
T_2D8:
	addi.l	#$10,4(A0)		
T_2E0:
	move.l	(A0),8(A0)		;move end mark cookie
	move.l	4(A0),12(A0)		;and its value
	move.l	#'EPro',(A0)		;insert new 'EPro' cookie
	move.l	#EPro_cookie_t,4(A0)	;and its pointer value
	rts
;----------------------------------------------------------------------------
T_2FA:
	moveq	#$ffFFff99,D0
	bsr	show_error_message
	rts
;----------------------------------------------------------------------------
T_302:
	move.l	(_cookies).w,D0		;_p_cookies
	beq.s	T_31C
	movea.l	D0,A0
T_30A:
	move.l	(A0),D0
	beq.s	T_31C
	cmpi.l	#'EPro',D0
	beq.s	T_31A
	addq.l	#8,A0
	bra.s	T_30A
;
T_31A:
	moveq	#1,D0
T_31C:
	rts
;----------------------------------------------------------------------------
find_char_d0_DOS:
	tst.l	DOS_chain_p
	beq.s	T_33A
	movea.l	DOS_chain_p,A0
T_32C:
	cmp	DOS_char(A0),D0
	beq.s	T_33E
	movea.l	DOS_next(A0),A0
	cmpa	#0,A0
	bne.s	T_32C
T_33A:
	moveq	#$ffFFffFF,D0
	rts
;
T_33E:
	move.l	A0,found_DOS
	rts
;----------------------------------------------------------------------------
;Sub:	'find_BOS_link' is called only by xbios handler
;
find_BOS_link:
	tst.l	BOS_chain_p
	beq.s	T_37A
	tst.w	D0
	bmi.s	T_368
	movea.l	BOS_chain_p,A1
T_358:
	cmp.w	BOS_char(A1),D0
	beq.s	T_37E
	movea.l	BOS_next(A1),A1
	cmpa.w	#0,A1
	bne.s	T_358
	bra.s	T_37A
;
T_368:
	movea.l	BOS_chain_p,A1
T_36E:
	addq.w	#1,D0
	beq.s	T_37E
	movea.l	BOS_next(A1),A1
	cmpa.w	#0,A1
	bne.s	T_36E
T_37A:
	moveq	#$ffFFffF1,D0
	rts
;
;----------------------------------------------------------------------------
;
T_37E:
	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;XBRA:	'nu_resvector' for vector 'resvector'
;----------------------------------------------------------------------------
;
	XB_define	nu_resvector,'EPro'
	clr.l	(_cookies).w			;_p_cookies
	move.l	nu_resvector+8,(resvector).w	;resvector
	move.l	old_resvalid,(resvalid).w	;resvalid
	jmp	(A6)
;
;----------------------------------------------------------------------------
;XBRA:	'nu_xbios' for vector ev_xbios
;----------------------------------------------------------------------------
;NB:	These routines must be completely rewritten, since they slow down
;	the execution of all functions, even when CD-ROM is not used.
;	The 'Supexec' function must have TOP priority (as always).
;----------------------------------------------------------------------------
;
	XB_define	nu_xbios,'EPro'
	movea.l	xbios_save_p,A0
	move.l	SP,-(A0)
	move.w	#6,D0
	btst	#5,(SP)
	bne.s	T_3C8
	move	usp,SP
	clr.w	D0
	bra.s	T_3D0
;
T_3C8:
	tst.w	(_longframe).w			;_longframe
	beq.s	T_3D0
	addq.w	#2,D0
T_3D0:
	cmpi.w	#$30,0(SP,D0.w)
	blt	T_482
	cmpi.w	#$3F,0(SP,D0.w)
	bgt	T_482
	cmpi.w	#2,D0
	ble.s	T_3FC			;jump if usermode call
	move.w	(SP)+,-(A0)
	move.l	(SP)+,-(A0)
	tst.w	(_longframe).w			;_longframe
	beq.s	T_3F6
	move.w	(SP)+,-(A0)
T_3F6:
	move.w	#1,-(A0)
	bra.s	T_3FE
;
T_3FC:
	clr.w	-(A0)
T_3FE:
	cmpi.w	#$30,(SP)		;Metainit function opcode ?
	beq	nu_Metainit
	move.w	2(SP),D0		;D0 = drive letter
	bsr	find_BOS_link
	bmi.s	T_468
	move.w	(SP)+,D1		;d1 = function opcode  (pulled)
	move.w	D1,-(A0)
	move.w	(SP)+,D0		;d0 = drive letter  (pulled)
	move.w	D0,-(A0)
	movem.l	D3-D7/A3-A6,-(A0)
	move.l	A0,xbios_save_p
	movea.l	A1,A0			;a0 -> BOS_table
	movea.l	BOS_func_tp(A1),A1	;a1 -> Metados function table
	subi.w	#$30,D1			;d1 =  Metados function code $1..$F
	cmpi.w	#7,D1			;is d1 Metaioctl ?
	bne.s	T_452
nu_Metaioctl:
	cmpi.b	#$FF,(A1)
	beq.s	T_452
	cmpi.l	#'FCTL',(SP)
	bne.s	T_452
	move.b	5(SP),D1		;d1 = subfunction code
	cmp.b	(A1),D1			;is subfunction code too high ?
	blt.s	.use_FCTL_code		;go use legal FCTL subfunction
	move.w	#7,D1			;d1 = Metados code for Metaioctl
	bra.s	T_452			;go hope driver can handle it anyway
;
.use_FCTL_code:
	addi.w	#$10,D1			;step index past Metados functions
T_452:
;Here d0=drive_letter  d1=function_code  a0->BOS_table  sp->arguments after drive
	asl.w	#2,D1
	movea.l	0(A1,D1.w),A1
	jsr	(A1)
	movea.l	xbios_save_p,A0
	movem.l	(A0)+,D3-D7/A3-A6
	move.w	(A0)+,-(SP)
	move.w	(A0)+,-(SP)
T_468:
	tst.w	(A0)+
	beq.s	T_478
	tst.w	(_longframe).w			;_longframe
	beq.s	T_474
	move.w	(A0)+,-(SP)
T_474:
	move.l	(A0)+,-(SP)
	move.w	(A0)+,-(SP)
T_478:
	movea.l	(A0)+,SP
	move.l	A0,xbios_save_p
	rte
;
;----------------------------------------------------------------------------
;
T_482:
	movea.l	(A0)+,SP
	move.l	A0,xbios_save_p
	movea.l	nu_xbios+8,A0
	jmp	(A0)
;
nu_Metainit:
	movem.l	A0-A1,-(SP)
	movea.l	10(SP),A0
	lea	Metainfo_1,A1
	move.l	(A1)+,(A0)+	;drivemap
	move.l	(A1)+,(A0)+	;-> version
	move.l	(A1)+,(A0)+	;reserved
	move.l	(A1)+,(A0)+	;-> metainfo_2 structure
	movem.l	(SP)+,A0-A1
	bra.s	T_468
;
;----------------------------------------------------------------------------
;XBRA:	'nu_bios' for vector ev_bios
;----------------------------------------------------------------------------
	XB_define	nu_bios,'EPro'
	move	sr,-(SP)
	ori	#$700,sr
	move.w	(SP)+,bios_SR
	movea.l	bios_save_p,A0
	move.l	SP,-(A0)
	move.w	#6,D0
	btst	#5,(SP)
	bne.s	.T_4DE
	move	usp,SP
	clr.w	D0
	bra.s	.T_4E6
;
.T_4DE:
	tst.w	(_longframe).w			;_longframe
	beq.s	.T_4E6
	addq.w	#2,D0
.T_4E6:
	cmpi.w	#9,0(SP,D0.w)
	blt	.T_59C
	cmpi.w	#9,0(SP,D0.w)
	bgt	.T_59C
	cmpi.w	#2,D0
	ble.s	.T_512
	move.w	(SP)+,-(A0)
	move.l	(SP)+,-(A0)
	tst.w	(_longframe).w			;_longframe
	beq.s	.T_50C
	move.w	(SP)+,-(A0)
.T_50C:
	move.w	#1,-(A0)
	bra.s	.T_514
;
.T_512:
	clr.w	-(A0)
.T_514:
	movem.l	D1-D7/A1-A6,-(A0)
	move.l	A0,bios_save_p
	move	bios_SR,sr
	move.w	(SP),D1
	asl.w	#2,D1
	lea	bios_func_p_t,A1
	move.l	0(A1,D1.w),D0
	bmi.s	.T_576
	movea.l	D0,A1
	jsr	(A1)
	cmpi.l	#E_999,D0
	beq.s	.T_576
	move	sr,-(SP)
	ori	#$700,sr
	move.w	(SP)+,bios_SR
	movea.l	bios_save_p,A0
	movem.l	(A0)+,D1-D7/A1-A6
	tst.w	(A0)+
	beq.s	.T_566
	tst.w	(_longframe).w			;_longframe
	beq.s	.T_562
	move.w	(A0)+,-(SP)
.T_562:
	move.l	(A0)+,-(SP)
	move.w	(A0)+,-(SP)
.T_566:
	movea.l	(A0)+,SP
	move.l	A0,bios_save_p
	move	bios_SR,sr
	rte
;------------------------------------
.T_576:
	move	sr,-(SP)
	ori	#$700,sr
	move.w	(SP)+,bios_SR
	movea.l	bios_save_p,A0
	movem.l	(A0)+,D1-D7/A1-A6
	tst.w	(A0)+
	beq.s	.T_59C
	tst.w	(_longframe).w			;_longframe
	beq.s	.T_598
	move.w	(A0)+,-(SP)
.T_598:
	move.l	(A0)+,-(SP)
	move.w	(A0)+,-(SP)
.T_59C:
	movea.l	(A0)+,SP
	move.l	A0,bios_save_p
	move	bios_SR,sr
	movea.l	nu_bios+8,A0
	jmp	(A0)
;----------------------------------------------------------------------------
;XBRA:	'nu_gemdos' for vector ev_gemdos
;----------------------------------------------------------------------------
;NB:	These routines must be completely rewritten, since they slow down
;	the execution of all functions, even when CD-ROM is not used.
;	The 'Super' function must have TOP priority (as always).
;----------------------------------------------------------------------------
;
	XB_define	nu_gemdos,'EPro'
	movea.l	gemdos_save_p,A0	;a0 -> save area
	move.l	SP,-(A0)	;save SP
	move.w	#6,D0		;d0 = 6 = 68000 frame size
	btst	#5,(SP)		;super mode call ?
	bne.s	.super_call_1
	move	usp,SP		;SP = usp
	clr.w	D0		;d0 = 0 = distance from SP to args
	bra.s	.have_args
;
.super_call_1:
	tst.w	(_longframe).w			;_longframe
	beq.s	.have_args
	addq.w	#2,D0		;d0 += 2 = 68020+ frame size
.have_args:
;;;
;;; Original used inefficient test here, as follows:
;;;
;;;	cmpi.w	#0,0(SP,D0.w)	;this test was needed only because
;;;	blt	.use_old_gemdos	;next test used 'bgt', which would
;;;	cmpi.w	#$57,0(SP,D0.w)	;not work on negative codes.
;;;	bgt	.use_old_gemdos	;NB: such codes are not legal !!!
;;;
;;;	The same result is accomplished by 2 lines below, but these are
;;;	preceded by 2 new lines to improve speed of 'Super' function.
;;;
	cmpi.w	#Super&$ff,(SP,d0)	;;;new;;; test 'Super' opcode first
	beq	.use_old_gemdos		;;;new;;; this keeps 'Super' fast
	cmpi.w	#$57,(SP,d0)		;;;new;;; upper limit, since lower=0
	bhi	.use_old_gemdos 	;;;new;;; 'bhi' handles all cases
;;;
	cmpi.w	#2,D0		;user mode call ?
	ble.s	.user_call_1
	move.w	(SP)+,-(A0)		;move frame SR to save area
	move.l	(SP)+,-(A0)		;move frame retadr to save area
	tst.w	(_longframe).w		;new CPU ?
	beq.s	.T_604
	move.w	(SP)+,-(A0)		;move frame type to save area
.T_604:
	move.w	#1,-(A0)		;set super call flag in save area
	bra.s	.T_60C
;
.user_call_1:
	clr.w	-(A0)			;clr super call flag in save area
.T_60C:
	movem.l	D1-D7/A1-A6,-(A0)	;save all registers in save area
	move.l	A0,gemdos_save_p		;store save area pointer
.access_loop:
	move.w	(SP),D1			;d1 = gemdos opcode
	asl.w	#2,D1			;d1 = long index
	lea	gemdos_func_p_t,A1
	move.l	(a1,d1),D0
	bmi.s	.exit_to_old_gemdos
	movea.l	D0,A1
	jsr	(A1)
	tst.l	D0
	bpl.s	.function_completed
	cmpi.l	#E_999,D0
	beq.s	.exit_to_old_gemdos
	bsr.s	use_etv_critic
	cmpi.l	#$10000,D0
	beq.s	.access_loop
.function_completed:
	movea.l	gemdos_save_p,A0
	movem.l	(A0)+,D1-D7/A1-A6
	tst.w	(A0)+
	beq.s	.T_65A
	tst.w	(_longframe).w			;_longframe
	beq.s	.T_656
	move.w	(A0)+,-(SP)
.T_656:
	move.l	(A0)+,-(SP)
	move.w	(A0)+,-(SP)
.T_65A:
	movea.l	(A0)+,SP
	move.l	A0,gemdos_save_p
	rte
;
;----------------------------------------------------------------------------
;
.exit_to_old_gemdos:
	movea.l	gemdos_save_p,A0
	movem.l	(A0)+,D1-D7/A1-A6
	tst.w	(A0)+		;user mode call ?
	beq.s	.use_old_gemdos
	tst.w	(_longframe).w	;new CPU ?
	beq.s	.T_67A
	move.w	(A0)+,-(SP)	;restore entry frame type
.T_67A:
	move.l	(A0)+,-(SP)	;restore entry frame retadr
	move.w	(A0)+,-(SP)	;restore entry frame SR
.use_old_gemdos:
	movea.l	(A0)+,SP	;restore entry SP
	move.l	A0,gemdos_save_p
	movea.l	nu_gemdos+8,A0
	jmp	(A0)		;exit to older gemdos
;
use_etv_critic:
	cmpi.l	#-1,D0
	bgt.s	T_6CA
	cmpi.l	#-$11,D0
	blt.s	T_6CA
;
	move.l	D0,-(SP)
	bios	Setexc,#etvn_critic,?
	movea.l	D0,A0
	move.l	(SP)+,D0
;
	movea.l	found_DOS,A1
	move.w	4(A1),-(SP)
	subi.w	#'A',(SP)
	move.w	D0,-(SP)
	jsr	(A0)
	addq.l	#4,SP
T_6CA:
	rts
;
;----------------------------------------------------------------------------
call_old_gemdos:
	move.l	(SP)+,B_2898
	tst.w	(_longframe).w	;new CPU ?
	beq.s	T_6DE
	move.w	B_2790,-(SP)	;simulate frame type
T_6DE:
	pea	T_6EE		;simulate frame retadr
	move	sr,-(SP)	;simulate frame SR
	movea.l	nu_gemdos+8,A0
	jmp	(A0)
;
T_6EE:
	move.l	B_2898,-(SP)
	rts
;----------------------------------------------------------------------------
nu_Mediach:
	move.w	6(SP),D0
	move.l	(_drvbits).w,D1
	btst	D0,D1
	beq.s	T_72C
	addi.w	#$41,D0
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	move.l	#0,-(SP)
	movea.l	DOS_LDB_p(a0),A0
	move.w	2(A0),-(SP)
	move.w	#$36,-(SP)		;Metastatus
	trap	#14
	addq.l	#8,SP
	tst.l	D0
	beq.s	T_72A
	moveq	#2,D0
T_72A:
	rts
;------------------------------------
T_72C:
	moveq	#$ffFFffF1,D0
	rts
;----------------------------------------------------------------------------
nu_Pterm_fix:
	movea.l	(etv_term).w,A0		;etv_term
	jsr	(A0)
	movea.l	loc_currbp_p_p,A0
	move.l	(A0),D2			;d2 -> basepage
	lea	meta_FCB_t,A5
	movea.l	A5,A3
	adda.w	#$12C0,A3
T_74A:
	tst.l	FCB_DOS_p(A5)
	bmi.s	T_762
	cmp.l	FCB_owner(A5),D2		;does FCB_owner(a5) -> basepage ?
	bne.s	T_762
	move.l	#-1,FCB_DOS_p(A5)
	clr.l	FCB_owner(A5)
T_762:
	adda.w	#sizeof_FCB,A5
	cmpa.l	A3,A5
	bgt.s	T_76C
	bra.s	T_74A
;
T_76C:
	movea.w	#etv_term,A0
	move.l	(A0),B_5BB4
	move.l	#T_780,(A0)
	bra	E_999_sub
;-------------------------------------
T_780:
	movea.w	#etv_term,A0
	move.l	B_5BB4,(A0)
	rts
;----------------------------------------------------------------------------
nu_Dsetdrv:
	movea.l	loc_currbp_p_p,A0
	movea.l	(A0),A0
	moveq	#0,D0
	move.b	bp_drive_index,D0
	move.b	7(SP),0(A0,D0.w)
	move.l	(_drvbits).w,D0
	rts
;----------------------------------------------------------------------------
nu_Dgetdrv:
	movea.l	loc_currbp_p_p,A0
	movea.l	(A0),A0
	moveq	#0,D0
	move.b	bp_drive_index,D0
	move.b	0(A0,D0.w),D0
	rts
;----------------------------------------------------------------------------
nu_Dfree:
	move.w	10(SP),D0
	beq.s	T_7C8
	subq.w	#1,D0
	bra.s	T_7CA
;
T_7C8:
	bsr.s	nu_Dgetdrv
T_7CA:
	addi.w	#'A',D0
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	bsr	prepare_DOS_call
	bmi	error_E_ACCDN
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	rts
;----------------------------------------------------------------------------
nu_Dcreate_Ddelete:
	movea.l	6(SP),A0
	bsr	calc_pathdrive
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	movea.l	6(SP),A1
	bsr	T_C54
	bmi	error_E_PTHNF
	bsr	prepare_DOS_call
	bmi	error_E_ACCDN
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	rts
;----------------------------------------------------------------------------
nu_Dsetpath:
	movea.l	6(SP),A0
	bsr	calc_pathdrive
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	movea.l	6(SP),A1
T_836:
	move.b	(A1)+,D0
	beq.s	T_84C
	cmpi.b	#$2A,D0
	beq	error_E_PTHNF
	cmpi.b	#$3F,D0
	beq	error_E_PTHNF
	bra.s	T_836
;
T_84C:
	movea.l	6(SP),A1
	bsr	T_C54
	bmi	error_E_PTHNF
;
	bsr	prepare_DOS_call
	bmi.s	T_87C
	move.l	A0,current_DOS
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	tst.l	D0
	bmi.s	T_88C
	movea.l	current_DOS,A0
T_87C:
	lea	DOS_path(A0),A0
	lea	init_buff_1+2,A1
T_886:
	move.b	(A1)+,(A0)+
	bne.s	T_886
	moveq	#0,D0
T_88C:
	rts
;----------------------------------------------------------------------------
nu_Fcreate_Fopen:
	movea.l	6(SP),A0
	bsr	calc_pathdrive
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	movea.l	6(SP),A1
	bsr	T_C54
	bmi	error_E_PTHNF
	lea	meta_FCB_t,A5
	movea.l	A5,A3
	adda.w	#$12C0,A3
T_8B6:
	tst.l	FCB_DOS_p(A5)
	bmi.s	T_8C8
	adda.w	#sizeof_FCB,A5
	cmpa.l	A3,A5
	bgt.s	T_91C
	bra.s	T_8B6
;
T_8C8:
	movea.l	A5,A3
	move.w	#sizeof_FCB-1,D0
T_8CE:
	clr.b	(A3)+
	dbra	D0,T_8CE
	bsr	prepare_DOS_call
	bmi	error_E_ACCDN
	move.l	A5,current_DOS
	move.l	A0,FCB_DOS_p(A5)
	movea.l	loc_currbp_p_p,A0
	move.l	(A0),FCB_owner(A5)
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	movea.l	current_DOS,A0
	tst.l	D0
	bmi.s	T_920
	move.l	A0,D0
	subi.l	#meta_FCB_t,D0
	divu	#sizeof_FCB,D0
	addi.l	#100,D0
	rts
;
T_91C:
	moveq	#$ffFFffDD,D0
	rts
;
T_920:
	move.l	#-1,FCB_DOS_p(A0)
	rts
;----------------------------------------------------------------------------
nu_Fclose:
	move.w	6(SP),D0
	cmpi.w	#100,D0
	blt	E_999_sub
	cmpi.w	#100+FCB_limit-1,D0
	bgt	E_999_sub
	subi.l	#100,D0
	mulu	#sizeof_FCB,D0
	addi.l	#meta_FCB_t,D0
	movea.l	D0,A5
	move.l	FCB_DOS_p(A5),D0
	bmi	error_E_IHNDL
	move.l	A5,current_DOS
	movea.l	D0,A0
	bsr	prepare_DOS_call
	bmi.s	T_974
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
T_974:
	movea.l	current_DOS,A1
	move.l	#-1,FCB_DOS_p(A1)
	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;
nu_Fread_Fwrite:
	move.w	6(SP),D0
	cmpi.w	#100,D0
	blt	E_999_sub
	cmpi.w	#100+FCB_limit-1,D0
	bgt	E_999_sub
	subi.l	#100,D0
	mulu	#sizeof_FCB,D0
	addi.l	#meta_FCB_t,D0
	movea.l	D0,A5
	move.l	FCB_DOS_p(A5),D0
	bmi	error_E_IHNDL
	movea.l	D0,A0
	bsr	prepare_DOS_call
	bmi	error_E_ACCDN
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	rts
;
;----------------------------------------------------------------------------
;
nu_Fdelete_Fattrib:
	movea.l	6(SP),A0
	bsr	calc_pathdrive
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	movea.l	6(SP),A1
	bsr	T_C54
	bmi	error_E_PTHNF
	bsr	prepare_DOS_call
	bmi	error_E_ACCDN
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	rts
;
;----------------------------------------------------------------------------
;
nu_Fseek_Fdatime:
	move.w	10(SP),D0
	cmpi.w	#100,D0
	blt	E_999_sub
	cmpi.w	#100+FCB_limit-1,D0
	bgt	E_999_sub
	subi.l	#100,D0
	mulu	#sizeof_FCB,D0
	addi.l	#meta_FCB_t,D0
	movea.l	D0,A5
	move.l	FCB_DOS_p(A5),D0
	bmi	error_E_IHNDL
	movea.l	D0,A0
	bsr	prepare_DOS_call
	bmi	error_E_ACCDN
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	rts
;
;----------------------------------------------------------------------------
;
nu_Dgetpath:
	move.w	10(SP),D0
	beq.s	T_A54
	subq.w	#1,D0
	bra.s	T_A58
;
T_A54:
	bsr	nu_Dgetdrv
T_A58:
	move.l	(_drvbits).w,D1
	btst	D0,D1
	beq.s	T_A84
	addi.w	#$41,D0
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	movea.l	6(SP),A1
	lea	DOS_path(A0),A0
	tst.b	1(A0)
	bne.s	T_A7C
	addq.l	#1,A0
T_A7C:
	move.b	(A0)+,(A1)+
	bne.s	T_A7C
	moveq	#0,D0
	rts
;
;
T_A84:
	moveq	#$ffFFffD2,D0
	rts
;
;----------------------------------------------------------------------------
;
nu_Pexec:
	tst.w	6(SP)
	beq.s	T_A98
	cmpi.w	#3,6(SP)
	bne	E_999_sub
T_A98:
	movea.l	8(SP),A0
	bsr	calc_pathdrive
	move.w	D0,B_5CF0
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	movea.l	8(SP),A0
	move.w	#0,-(SP)
	move.l	A0,-(SP)
	move.w	#$3D,-(SP)
	bsr	nu_Fcreate_Fopen
	addq.l	#8,SP
	tst.l	D0
	bmi.s	T_AEE
	move.w	D0,B_5CEA
	move.l	12(SP),D0
	move.l	$10(SP),D1
	move.l	D1,-(SP)
	move.l	D0,-(SP)
	clr.l	-(SP)
	move.w	#5,-(SP)
	move.w	#Pexec&$ff,-(SP)
	bsr	call_old_gemdos
	lea	$10(SP),SP
	tst.l	D0
	bpl.s	T_AF0
T_AEE:
	rts
;
;
T_AF0:
	move.l	D0,B_5CE6
	bsr	T_E20
	move.l	D0,D3
	move.w	B_5CEA,-(SP)
	move.w	#$3E,-(SP)
	bsr	nu_Fclose
	addq.l	#4,SP
	move.l	D3,D0
	bpl.s	T_B2C
	move.l	D0,B_5CC6
	bsr	use_etv_critic
	lea	T_B78,A0
	movea.l	B_5CE6,A1
	move.l	A0,8(A1)
	bra.s	T_B42
;
T_B2C:
	tst.w	6(SP)
	beq.s	T_B3C
	move.l	B_5CE6,D0
	rts
;
;
T_B3C:
	clr.l	B_5CC6
T_B42:
	tst.l	B_5CF6
	beq.s	T_B4E
	bsr	T_DF0
T_B4E:
	clr.l	$10(SP)
	move.l	B_5CE6,12(SP)
	clr.l	8(SP)
	move.w	#4,6(SP)
	tst.l	B_5CF6
	bne	E_999_sub
	move.w	#6,6(SP)
	bra	E_999_sub
;
T_B78:
	move.w	B_5CC8,-(SP)
	move.w	#$4C,-(SP)
	trap	#1			;Pterm
	illegal
;
;----------------------------------------------------------------------------
;
nu_Fsfirst:
	movea.l	6(SP),A0
	bsr	calc_pathdrive
	move.w	D0,B_5CF0
	bsr	call_old_Fgetdta
	movea.l	D0,A5
	clr.b	dta_size-1(A5)		;enforce string termination
	move.w	B_5CF0,D0
	bsr	find_char_d0_DOS
	bmi	E_999_sub
	movea.l	6(SP),A1
	bsr	T_C54
	bmi	error_E_PTHNF
	bsr	prepare_DOS_call
	bmi.s	error_E_ACCDN
	move.b	B_5CF1,dta_size-1(A5)	;NB: this seems strange !!!
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	rts
;
;----------------------------------------------------------------------------
;
nu_Fsnext:
	bsr	call_old_Fgetdta
	movea.l	D0,A5
	moveq	#0,D0
	move.b	$2B(A5),D0
	bsr	find_char_d0_DOS
	bmi.s	E_999_sub
	movea.w	#0,A1
	bsr.s	T_C54
	bmi.s	error_E_PTHNF
	bsr	prepare_DOS_call
	bmi.s	error_E_ACCDN
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	rts
;
;----------------------------------------------------------------------------
;
nu_Frename:
	movea.l	8(SP),A0
	bsr	calc_pathdrive
	bsr	find_char_d0_DOS
	bmi.s	E_999_sub
	movea.l	8(SP),A1
	bsr.s	T_C54
	bmi.s	error_E_PTHNF
	bsr	prepare_DOS_call
	bmi.s	error_E_ACCDN
	move.l	(SP)+,B_5BB0
	jsr	(A2)
	move.l	B_5BB0,-(SP)
	rts
;
;----------------------------------------------------------------------------
;
E_999_sub:
	move.l	#E_999,D0
	rts
;
;----------------------------------------------------------------------------
;
error_E_ACCDN:
	moveq	#$ffFFffDC,D0
	rts
;
;----------------------------------------------------------------------------
;
error_E_IHNDL:
	moveq	#$ffFFffDB,D0
	rts
;
;----------------------------------------------------------------------------
;
error_E_PTHNF:
	moveq	#$ffFFffDE,D0
	rts
;
;----------------------------------------------------------------------------
;
T_C54:
	movem.l	A0-A2,-(SP)
	clr.w	D0
	lea	init_buff_1,A2
	btst	#1,DOS_FSmode_bits+3(a0)
	beq.s	T_C9A
	cmpa.w	#0,A1
	bne.s	T_C76
	lea	DOS_path(A0),A1
	bra	T_D96
;
T_C76:
	btst	#0,DOS_FSmode_bits+3(a0)
	bne	T_D96
T_C80:
	move.b	(A1)+,D0
	cmpi.b	#'a',D0
	blt.s	T_C92
	cmpi.b	#'z',D0
	bgt.s	T_C92
	subi.b	#$20,D0
T_C92:
	move.b	D0,(A2)+
	bne.s	T_C80
	bra	T_D9A
;
T_C9A:
	cmpa.w	#0,A1
	beq.s	T_CB2
	tst.b	(A1)
	beq.s	T_CB2
	cmpi.b	#':',1(A1)
	bne.s	T_CB2
	move.b	(A1),D0
	addq.l	#2,A1
	bra.s	T_CB6
;
T_CB2:
	move.w	4(A0),D0
T_CB6:
	btst	#0,DOS_FSmode_bits+3(a0)
	bne.s	T_CCE
	cmpi.b	#'a',D0
	blt.s	T_CCE
	cmpi.b	#'z',D0
	bgt.s	T_CCE
	subi.b	#$20,D0
T_CCE:
	move.b	D0,(A2)+
	move.b	#':',(A2)+
	cmpa.w	#0,A1
	bne.s	T_CE2
	lea	DOS_path(A0),A1
	bra	T_D96
;
T_CE2:
	cmpi.b	#'\',(A1)
	beq.s	T_D06
	move.l	A0,-(SP)
	lea	DOS_path(A0),A0
T_CEE:
	move.b	(A0)+,(A2)+
	bne.s	T_CEE
	movea.l	(SP)+,A0
	subq.l	#1,A2
	cmpi.b	#'\',-$1(A2)
	beq.s	T_D06
	tst.b	(A1)
	beq.s	T_D06
	move.b	#'\',(A2)+
T_D06:
	moveq	#0,D1
T_D08:
	move.b	(A1)+,D0
	tst.l	D1
	bne.s	T_D3E
	cmpi.b	#'.',D0
	bne.s	T_D3E
	cmpi.b	#'.',(A1)
	bne.s	T_D30
	move.b	1(A1),D0
	beq.s	T_D28
	cmpi.b	#'\',D0
	bne.s	T_D3E
	addq.l	#1,A1
T_D28:
	addq.l	#1,A1
	bsr.s	T_DA2
	bra.s	T_D08
;
T_D30:
	move.b	(A1),D0
	beq.s	T_D08
	cmpi.b	#'\',D0
	bne.s	T_D3E
	addq.l	#1,A1
	bra.s	T_D08
;
T_D3E:
	btst	#0,DOS_FSmode_bits+3(a0)
	bne.s	T_D56
	cmpi.b	#'a',D0
	blt.s	T_D56
	cmpi.b	#'z',D0
	bgt.s	T_D56
	subi.b	#$20,D0
T_D56:
	addq.l	#1,D1
	cmpi.b	#'\',D0
	bne.s	T_D60
	moveq	#0,D1
T_D60:
	move.b	D0,(A2)+
	bne.s	T_D08
	cmpi.b	#'\',-$2(A2)
	bne.s	T_D78
	cmpi.b	#':',-$3(A2)
	beq.s	T_D78
	clr.b	-$2(A2)
T_D78:
	cmpi.b	#'\',-(A2)
	bne.s	T_D78
T_D7E:
	move.b	-(A2),D0
	cmpi.b	#':',D0
	beq.s	T_D9A
	cmpi.b	#'?',D0
	beq.s	T_D92
	cmpi.b	#'*',D0
	bne.s	T_D7E
T_D92:
	moveq	#$ffFFffFF,D0
	bra.s	T_D9C
;
T_D96:
	move.b	(A1)+,(A2)+
	bne.s	T_D96
T_D9A:
	moveq	#0,D0
T_D9C:
	movem.l	(SP)+,A0-A2
	rts
;
;----------------------------------------------------------------------------
;
T_DA2:
	move.l	A0,-(SP)
	lea	init_buff_1,A0
	addq.l	#3,A0
	subq.l	#2,A2
T_DAE:
	cmpa.l	A0,A2
	ble.s	T_DBA
	cmpi.b	#'\',-(A2)
	bne.s	T_DAE
	bra.s	T_DBC
;
T_DBA:
	movea.l	A0,A2
T_DBC:
	movea.l	(SP)+,A0
	rts
;
;----------------------------------------------------------------------------
;
calc_pathdrive:
	clr.w	D0
	move.b	(A0),D0
	beq.s	T_DDA
	cmpi.b	#':',1(A0)
	bne.s	T_DDA
	cmpi.b	#'a',D0
	blt.s	T_DE2
	subi.b	#$20,D0
	bra.s	T_DE2
;
T_DDA:
	bsr	nu_Dgetdrv
	addi.w	#'A',D0
T_DE2:
	rts
;
;----------------------------------------------------------------------------
;
call_old_Fgetdta:
	move.w	#Fgetdta&$ff,-(SP)
	bsr	call_old_gemdos
	addq.l	#2,SP
	rts
;
;----------------------------------------------------------------------------
;
T_DF0:
	movea.l	B_5CF6,A2
	movea.l	4(A2),A3
	movea.l	B_5CE6,A2
	movea.l	$2C(A2),A4
T_E04:
	cmpa.w	#0,A3
	beq.s	T_E1E
	movea.l	4(A3),A0
	cmpa.l	A2,A0
	beq.s	T_E16
	cmpa.l	A4,A0
	bne.s	T_E1A
T_E16:
	move.l	A2,12(A3)
T_E1A:
	movea.l	(A3),A3
	bra.s	T_E04
;
T_E1E:
	rts
;
;----------------------------------------------------------------------------
;
T_E20:
	pea	B_5CCA
	move.l	#$1C,-(SP)
	move.w	B_5CEA,-(SP)
	move.w	#$3F,-(SP)
	bsr	nu_Fread_Fwrite
	lea	12(SP),SP
	bsr.s	test_prog_header
	bmi.s	T_E74
	move.l	D0,B_5CF2
	movea.l	B_5CE6,A1
	move.l	4(A1),D0
	sub.l	(A1),D0
	cmp.l	B_5CF2,D0
	bmi.s	T_E78
	bsr.s	T_EAA
	bsr	T_EE6
	bmi.s	T_E74
	bsr	T_F6C
	bsr	T_FA2
	move.l	B_5CE6,D0
	rts
;
;----------------------------------------------------------------------------
;
T_E74:
	moveq	#$ffFFffBE,D0
	rts
;
;----------------------------------------------------------------------------
;
T_E78:
	moveq	#$ffFFffD9,D0
	rts
;
;----------------------------------------------------------------------------
;Sub:	'test_prog_header'
;Exit:	d0 = error code or runtime tpa size incl basepage and BSS section
;
test_prog_header:
	lea	B_5CCA,A0
	cmpi.l	#$1C,D0
	bne.s	T_EA6
	cmpi.w	#$601A,(A0)
	bne.s	T_EA6
	move.l	#$100,D0
	add.l	2(A0),D0
	add.l	6(A0),D0
	add.l	10(A0),D0
	beq.s	T_EA6
	rts
;
;----------------------------------------------------------------------------
;
T_EA6:
	moveq	#E_ERROR,D0
	rts
;
;----------------------------------------------------------------------------
;
T_EAA:
	movea.l	B_5CE6,A0
	lea	B_5CCA,A2
	move.l	A0,D0
	addi.l	#$100,D0
	move.l	D0,8(A0)
	move.l	2(A2),12(A0)
	add.l	12(A0),D0
	move.l	D0,$10(A0)
	move.l	6(A2),$14(A0)
	add.l	$14(A0),D0
	move.l	D0,$18(A0)
	move.l	10(A2),$1C(A0)
	rts
;
;----------------------------------------------------------------------------
;
T_EE6:
	movea.l	B_5CE6,A3
	lea	B_5CCA,A5
	move.l	2(A5),D3
	add.l	6(A5),D3
	move.l	D3,-(SP)
	move.l	8(A3),-(SP)
	move.l	D3,-(SP)
	move.w	B_5CEA,-(SP)
	move.w	#$3F,-(SP)
	bsr	nu_Fread_Fwrite
	lea	12(SP),SP
	move.l	(SP)+,D3
	cmp.l	D0,D3
	bne.s	T_F68
	lea	B_5CCA,A5
	move.l	14(A5),D0
	move.w	#1,-(SP)
	move.w	B_5CEA,-(SP)
	move.l	D0,-(SP)
	move.w	#$42,-(SP)
	bsr	nu_Fseek_Fdatime
	lea	10(SP),SP
	movea.l	B_5CE6,A3
	movea.l	$18(A3),A0
	move.l	A0,-(SP)
	move.l	#$7FFFFFFF,-(SP)
	move.w	B_5CEA,-(SP)
	move.w	#$3F,-(SP)
	bsr	nu_Fread_Fwrite
	lea	12(SP),SP
	cmpi.l	#4,D0
	bge.s	T_F6A
T_F68:
	moveq	#$ffFFffFF,D0
T_F6A:
	rts
;
;----------------------------------------------------------------------------
;
T_F6C:
	tst.l	D0
	beq.s	T_FA0
	movea.l	B_5CE6,A0
	movea.l	8(A0),A3
	movea.l	$18(A0),A4
	move.l	A3,D3
	movea.l	(A4)+,A0
	beq.s	T_FA0
	adda.l	A0,A3
	add.l	D3,(A3)
	clr.w	D0
T_F8A:
	move.b	(A4)+,D0
	beq.s	T_FA0
	cmpi.b	#1,D0
	bne.s	T_F9A
	adda.w	#$FE,A3
	bra.s	T_F8A
;
T_F9A:
	adda.l	D0,A3
	add.l	D3,(A3)
	bra.s	T_F8A
;
T_FA0:
	rts
;
;----------------------------------------------------------------------------
;
T_FA2:
	movem.l	D3-D7/A3,-(SP)
	movea.l	B_5CE6,A0
	movea.l	$18(A0),A1
	move.l	$1C(A0),D0
	movea.l	A1,A0
	adda.l	D0,A1
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
	moveq	#0,D4
	moveq	#0,D5
	moveq	#0,D6
	moveq	#0,D7
	movea.w	D7,A3
	move.l	A0,D0
	btst	#0,D0
	beq.s	T_FD2
	move.b	D1,(A0)+
T_FD2:
	move.l	A1,D0
	sub.l	A0,D0
	andi.l	#-$100,D0
	beq.s	T_100A
	lea	0(A0,D0.l),A0
	movea.l	A0,A2
	lsr.l	#8,D0
T_FE6:
	movem.l	D1-D7/A3,-(A2)
	movem.l	D1-D7/A3,-(A2)
	movem.l	D1-D7/A3,-(A2)
	movem.l	D1-D7/A3,-(A2)
	movem.l	D1-D7/A3,-(A2)
	movem.l	D1-D7/A3,-(A2)
	movem.l	D1-D7/A3,-(A2)
	movem.l	D1-D7/A3,-(A2)
	subq.l	#1,D0
	bne.s	T_FE6
T_100A:
	cmpa.l	A0,A1
	beq.s	T_1012
	move.b	D1,(A0)+
	bra.s	T_100A
;
T_1012:
	movem.l	(SP)+,D3-D7/A3
	rts
;
;----------------------------------------------------------------------------
;
prepare_DOS_call:
	move	8(SP),D0		;d0 = function opcode
	asl	#2,D0			;d0 = 4 * opcode
	movea.l	6(A0),A2		;a2 -> DOS vectors
	movea.l	0(A2,D0),A2		;a2 -> DOS function
	movea.l	DOS_LDB_p(a0),A3	;a3 -> LDB
	lea	init_buff_1,A4		;a4 -> path
	move.l	A2,D0
	rts
;
;----------------------------------------------------------------------------
;
init_extendos:
	bsr.s	open_extendos_cnf
	bpl.s	T_1080
	move.l	D0,-(SP)
	moveq	#$ffFFff94,D0
	bsr	show_error_message
	lea	extendos_cnf_spt,A3
T_1046:
	move.l	(A3)+,D0
	beq.s	T_105A
	gemdos	Cconws|_ind,d0
	bsr	crlf_sub
	bra.s	T_1046
;
T_105A:
	move.l	(SP)+,D0
	rts
;
T_105E:
	lea	B_5C38,A3
	cmpi.b	#'*',(A3)
	bne.s	T_1074
	bsr	boot_BOS_or_DOS
	bsr	crlf_sub
	bra.s	T_1080
;
T_1074:
	movem.l	D7,-(SP)
	bsr	T_15F4
	movem.l	(SP)+,D7
T_1080:
	bsr.s	T_10B6
	bpl.s	T_105E
	moveq	#0,D0
	rts
;
;----------------------------------------------------------------------------
;Sub:	'open_extendos_cnf'
;Exit:	d0 =  error code
;  "	d7 =  handle  (when error code is zero)
;
open_extendos_cnf:
	lea	extendos_cnf_spt,A3
T_108E:
	movea.l	(A3)+,A0
	move.l	A0,D0
	beq.s	T_10B2
	move.b	boot_letter,(A0)
	gemdos	Fopen|_ind,a0,#0
	tst.l	D0
	bmi.s	T_108E
	move.w	D0,D7
	moveq	#0,D0
	rts
;
T_10B2:
	moveq	#E_ERROR,d0
	rts
;
;----------------------------------------------------------------------------
;
T_10B6:
	lea	B_5C38,A3
	move.l	A3,-(SP)
	move.l	#1,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)
	trap	#1			;Fread
	lea	12(SP),SP
	tst.l	D0
	beq	T_1166
	cmpi.b	#';',(A3)
	beq.s	T_1142
	cmpi.b	#LF,(A3)
	beq.s	T_10B6
	cmpi.b	#CR,(A3)
	beq.s	T_10B6
	cmpi.b	#' ',(A3)
	beq.s	T_10B6
	cmpi.b	#HT,(A3)
	beq.s	T_10B6
T_10F4:
	addq.l	#1,A3
	move.l	A3,-(SP)
	move.l	#1,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)
	trap	#1			;Fread
	lea	12(SP),SP
	tst.l	D0
	beq.s	T_1168
	cmpi.b	#LF,(A3)
	beq.s	T_1168
	cmpi.b	#';',(A3)
	bne.s	T_10F4
	move.b	#10,(A3)
T_111E:
	movea.l	A3,A2
	addq.l	#1,A2
	move.l	A2,-(SP)
	move.l	#1,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)
	trap	#1			;Fread
	lea	12(SP),SP
	tst.l	D0
	beq.s	T_1168
	cmpi.b	#10,(A2)
	beq.s	T_1168
	bra.s	T_111E
;
T_1142:
	move.l	A3,-(SP)
	move.l	#1,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)
	trap	#1			;Fread
	lea	12(SP),SP
	tst.l	D0
	beq	T_10B6
	cmpi.b	#LF,(A3)
	beq	T_10B6
	bra.s	T_1142
;
T_1166:
	moveq	#$ffFFffFF,D0
T_1168:
	move.l	D0,D0
	rts
;
;----------------------------------------------------------------------------
;
boot_BOS_or_DOS:
	lea	B_5C38,A3
	cmpi.b	#'*',(A3)+
	bne.s	T_1194
	cmpi.b	#'O',1(A3)
	bne.s	T_1194
	cmpi.b	#'S',2(A3)
	bne.s	T_1194
	cmpi.b	#'B',(A3)
	beq.s	T_1196		;*BOS
	cmpi.b	#'D',(A3)
	beq.s	T_11A4		;*DOS
T_1194:
	rts
;
T_1196:
	bsr	init_run_module
	tst.l	D0
	bmi.s	T_11B0
	bsr	boot_BOS
	rts
;
T_11A4:
	bsr	init_run_module
	tst.l	D0
	bmi.s	T_11B0
	bsr.s	boot_DOS
	rts
;
T_11B0:
	cmpi.l	#-$6E,D0
	beq.s	T_11CA
	move.l	D0,-(SP)
	move.l	A0,-(SP)
	move.w	#9,-(SP)
	trap	#1			;Cconws
	addq.l	#6,SP
	bsr	crlf_sub
	move.l	(SP)+,D0
T_11CA:
	bsr	show_error_message
	rts
;----------------------------------------------------------------------------
boot_DOS:
	movem.l	A0-A2,-(SP)
	movea.w	#$100,A2
	adda.l	D0,A2
	jsr	(A2)
	move.l	D0,BOS_DOS_init_d0
	move.l	D1,DOS_init_d1
	movem.l	(SP)+,A0-A2
	tst.l	D0
	bpl.s	T_11F6
	bsr	show_error_message
	rts
;------------------------------------
T_11F6:
	tst.l	DOS_chain_p
	beq.s	T_1214
	lea	meta_DOS_t,A3
	adda.w	#(DOS_limit-1)*sizeof_DOS,A3
	cmpa.l	next_DOS_p,A3
	ble	T_1306
	bra.s	T_121E
;
T_1214:
	move.l	#meta_DOS_t,next_DOS_p
T_121E:
	addq.l	#1,A2
	move.b	(A2),D0
	beq	T_130C
	cmpi.b	#LF,D0
	beq	T_130C
	cmpi.b	#',',D0
	beq.s	T_121E
	cmpi.b	#' ',D0
	beq.s	T_121E
	cmpi.b	#HT,D0
	beq.s	T_121E
	cmpi.b	#CR,D0
	beq.s	T_121E
	clr.w	D2
	move.b	(A2)+,D2		;d2 = DOS drive char
	move.w	D2,D1
	subi.w	#'A',D1			;d1 = DOS device code
	cmpi.b	#':',(A2)+
	bne	T_130C
	move.l	(_drvbits).w,D0
	btst	D1,D0
	beq.s	T_1270
	move.w	D1,D0			;d0 = DOS device code
	addi.w	#'A',D0			;d0 = DOS drive char
	move.b	D0,D_1D34
	moveq	#$ffFFff98,D0
	bra.s	T_128A
;
T_1270:
	clr.l	D0			;clear high bits of d0
	move.b	(A2),D0			;d0 = BOS drive char
	movem.l	D2/A0-A2,-(SP)
	movea.l	BOS_DOS_init_d0,A0
	movea.l	(A0),A0
	jsr	(A0)
	movem.l	(SP)+,D2/A0-A2
	tst.l	D0
	bpl.s	T_1292
T_128A:
	bsr	show_error_message
	bra	T_11F6
;
T_1292:
	movea.l	next_DOS_p,A1
	tst.l	DOS_chain_p
	beq.s	T_12B0
	movea.l	A1,A3
	lea	sizeof_DOS(A3),A3
	move.l	A3,(A1)
	movea.l	A3,A1
	move.l	A1,next_DOS_p
T_12B0:
	move.l	D0,DOS_LDB_p(a1)
	move.l	D1,DOS_FSmode_bits(a1)
	clr.l	DOS_next(A1)
	move.w	D2,DOS_char(A1)
	lea	DOS_title_s(A1),A3
	movea.l	DOS_init_d1,A4
T_12C8:
	move.b	(A4)+,(A3)+		;copy title to DOS struct
	bne.s	T_12C8
	move.l	BOS_DOS_init_d0,D0
	addq.l	#4,D0
	move.l	D0,DOS_func_tp(A1)
	move.l	(_drvbits).w,D0
	move	DOS_char(A1),D1
	sub	#'A',D1
	bset	D1,D0
	move.l	D0,(_drvbits).w
	movea.l	next_DOS_p,A0
	tst.l	DOS_chain_p
	bne.s	T_12FE
	move.l	A0,DOS_chain_p
T_12FE:
	bsr	T_14D6
	bra	T_11F6
;
T_1306:
	moveq	#$ffFFff93,D0
	bsr.s	show_error_message
	rts
;------------------------------------
T_130C:
	moveq	#0,D0
	rts
;----------------------------------------------------------------------------
show_error_message:
	movem.l	D0-D2/A0-A2,-(SP)
	move.l	D0,-(SP)
	gemdos	Cconws|_ind,star_error_star_s
	move.l	(SP)+,D0
	lea	error_message_link_t,A0
T_132C:
	move.l	(A0),D1
	beq.s	T_1338
	cmp.l	D0,D1
	beq.s	T_1348
	addq.l	#8,A0
	bra.s	T_132C
;
T_1338:
	lea	D_1F0D,A0
	bsr.s	T_1362
	lea	D_1EF5,A0
	bra.s	T_134C
;
T_1348:
	movea.l	4(A0),A0
T_134C:
	gemdos	Cconws|_ind,a0
	st	B_2793
	movem.l	(SP)+,D0-D2/A0-A2
	rts
;----------------------------------------------------------------------------
T_1362:
	moveq	#7,D2
T_1364:
	rol.l	#4,D0
	move.b	D0,D1
	andi.b	#15,D1
	addi.b	#$30,D1
	cmpi.b	#$39,D1
	ble.s	T_137A
	addi.b	#7,D1
T_137A:
	move.b	D1,(A0)
	addq.l	#1,A0
	dbra	D2,T_1364
	rts
;----------------------------------------------------------------------------
boot_BOS:
	movem.l	A0-A2,-(SP)
	movea.w	#$100,A2
	adda.l	D0,A2
	jsr	(A2)		;call primary init sub of BOS
	move.l	D0,BOS_DOS_init_d0
	movem.l	(SP)+,A0-A2
	tst.l	D0
	bmi	T_1496
init_BOS_loop:
	addq.l	#1,A2
	move.b	(A2),D0
	beq	T_147A
	cmpi.b	#LF,D0
	beq	T_147A
	cmpi.b	#',',D0
	beq.s	init_BOS_loop
	cmpi.b	#' ',D0
	beq.s	init_BOS_loop
	cmpi.b	#HT,D0
	beq.s	init_BOS_loop
	cmpi.b	#CR,D0
	beq.s	init_BOS_loop
	clr.w	D3
	move.b	(A2)+,D3	;d3 =  physical drive letter
	move.w	D3,D0
	cmpi.b	#'A',D0
	blt	T_147C
	cmpi.b	#'Z',D0
	bgt	T_147C
	subi.b	#'A',D0		;d0 =  physical drive number
	move.l	Metainfo_1+meta1_drivemap,D1
	btst	D0,D1		;is it already taken ?
	bne	T_1486
	cmpi.b	#':',(A2)+
	bne	T_1490
	bsr	parse_number
	bmi	T_1494
	cmpi.b	#'.',(A2)
	bne.s	T_1412
	ror.w	#4,D1
	addq.l	#1,A2
	bsr	parse_number
	bmi	T_1494
	rol.w	#4,D1		;d1 low byte = LUN.ID of drive
T_1412:
	move.w	D3,D0		;d0 = physical drive letter
	movem.l	D0-D1/A0-A2,-(SP)
	movea.l	BOS_DOS_init_d0,A0
	movea.l	(A0),A0
	jsr	(A0)		;call secondary init sub of BOS
	move.l	D0,D3
	movem.l	(SP)+,D0-D1/A0-A2
	tst.l	D3
	bpl.s	T_1436
	move.l	D3,D0
	bsr	show_error_message
	bra	init_BOS_loop	;loop back for more drives
;
T_1436:
	movea.l	D3,A0
	tst.l	BOS_chain_p
	beq.s	T_1458
	movea.l	BOS_chain_p,A0
T_1446:
	movea.l	BOS_next(A0),A1
	cmpa.w	#0,A1
	beq.s	T_1452
	move.l	a1,a0		;NB: changed from misleading 'EXG'
	bra.s	T_1446
;
T_1452:
	move.l	D3,BOS_next(A0)
	movea.l	D3,A0
	bra.s	T_145E
;
T_1458:
	move.l	A0,BOS_chain_p		;initialize BOS_chain_p  (only when list empty)
T_145E:
	lea	Metainfo_1,A1
	move.l	meta1_drivemap(A1),D3	;d3 = drivemap
	move.w	BOS_char(A0),D0		;d0 = drive letter
	subi.w	#'A',D0			;d0 = drive number
	bset	D0,D3			;set new bit in d3
	move.l	D3,(A1)			;store altered drivemap
	bsr	T_14FA
	bra	init_BOS_loop	;loop back for more drives
;
T_147A:
	rts
;
;----------------------------------------------------------------------------
;
T_147C:
	move.b	D3,D_1D57
	moveq	#$ffFFff96,D0
	bra.s	T_1496
;
T_1486:
	move.b	D3,D_1D76
	moveq	#$ffFFff97,D0
	bra.s	T_1496
;
T_1490:
	moveq	#$ffFFff95,D0
	bra.s	T_1496
;
T_1494:
	moveq	#$ffFFffE4,D0
T_1496:
	bsr	show_error_message
	rts
;
;----------------------------------------------------------------------------
parse_number:
	bsr.s	parse_digit
	bmi.s	.exit_error
.loop:
	move.b	D1,D2
	bsr.s	parse_digit
	bmi.s	.exit_ok
	move.b	D2,D0
	add.b	D2,D2
	add.b	D2,D2
	add.b	D0,D2
	add.b	D2,D2
	add.b	D2,D1
	bra.s	.loop
;------------------------------------
.exit_ok:
	moveq	#0,D0
	rts
;------------------------------------
.exit_error:
	moveq	#$ffFFffFF,D0
	rts
;----------------------------------------------------------------------------
parse_digit:
	cmpi.b	#'0',(A2)
	blt.s	.exit_error
	cmpi.b	#'9',(A2)
	bgt.s	.exit_error
	move.b	(A2)+,D1
	andi.b	#15,D1
	moveq	#0,D0
	rts
;------------------------------------
.exit_error:
	moveq	#$ffFFffFF,D0
	rts
;----------------------------------------------------------------------------
;
T_14D6:
	exg	A3,A0
	move.w	4(A3),D0
	beq.s	T_14F2
	lea	logical_device_x_s,A1
	move.b	D0,$23(A1)
	move.l	A1,-(SP)
	move.w	#9,-(SP)
	trap	#1			;Cconws
	addq.l	#6,SP
T_14F2:
	bsr	crlf_sub
	exg	A3,A0
	rts
;
;----------------------------------------------------------------------------
T_14FA:
	movea.l	A0,A3
	pea	driver_installed_s
	move.w	#9,-(SP)
	trap	#1			;Cconws
	addq.l	#6,SP
	move.w	BOS_char(A3),D0
	beq.s	T_1524
	lea	as_x_drive_s,A1
	move.b	D0,4(A1)
	move.l	A1,-(SP)
	move.w	#9,-(SP)
	trap	#1			;Cconws
	addq.l	#6,SP
T_1524:
	lea	on_xCSI_x_LUN_x_s,A1
	move	BOS_xCSI_LUN_ID(A3),D0
	move	D0,D1
	andi.b	#15,D0
	addi.b	#$30,D0
	move.b	D0,9(A1)
	lsr.b	#4,D1
	addi.b	#$30,D1
	move.b	D1,15(A1)
	lsr.w	#8,D0
	beq.s	T_154E
	move.b	D0,4(A1)
T_154E:
	move.l	A1,-(SP)
	move.w	#9,-(SP)
	trap	#1			;Cconws
	addq.l	#6,SP
	movea.l	A3,A0
	rts
;----------------------------------------------------------------------------
;Sub:	'init_run_module'
;Entry:	a3 -> command line
;Exit:	d0 -> basepage unless it is a negative error code
;
init_run_module:			;loop start to find argument separator
	move.b	(A3)+,D0		;d0 = next char,  terminator ?
	beq	T_15F0
	cmpi.b	#',',D0			;',' (argument separator) ?
	bne.s	init_run_module		;loop back until ',' or line end found
T_1568:					;loop start to skip leading arg spaces
	move.b	(A3),D0			;d0 = next char,  line terminator ?
	beq	T_15F0
	cmpi.b	#' ',D0			;space ?
	bne.s	T_1578
	addq.l	#1,A3
	bra.s	T_1568			;loop back to skip leading arg spaces
;
T_1578:
	movea.l	A3,A0
	lea	B_5BB8,A1		;a1 -> destination for separated argument string
	clr.b	(A1)+			;clear string length byte
	clr.b	(A1)			;terminate empty string
	clr.w	D0			;clear byte counter
T_1586:					;loop start
	move.b	(A3),D1			;d1 = char[a3],  terminator ?
	beq.s	T_15AC
	cmpi.b	#13,D1			;CR ?
	beq.s	T_15AC
	cmpi.b	#',',D1			;',' ?
	beq.s	T_15AC
	cmpi.b	#';',D1			;';' ?
	beq.s	T_15AC
	cmpi.b	#' ',D1			;space ?
	beq.s	T_15B0
	cmpi.b	#HT,D1			;Tab ?
	beq.s	T_15B0
	addq.l	#1,A3
	bra.s	T_1586			;loop back
;
T_15AC:
	movea.l	A3,A2
	bra.s	T_15E0
;
T_15B0:
	movea.l	A3,A2
T_15B2:					;loop start
	cmpi.b	#' ',(A2)
	bne.s	T_15BC
	addq.l	#1,A2
	beq.s	T_15B2			;loop back
T_15BC:					;loop start
	move.b	(A2),D1			;d1 = char[a2]
	beq.s	T_15D8
	cmpi.b	#CR,D1			;CR ?
	beq.s	T_15D8
	cmpi.b	#';',D1			;';' ?
	beq.s	T_15D8
	cmpi.b	#',',D1			;',' ?
	beq.s	T_15D8
	move.b	(A2)+,(A1)+		;copy char[a2++] to char[a1++]
	addq.w	#1,D0			;increment byte counter
	bra.s	T_15BC			;loop back
;
T_15D8:
	clr.b	(A1)+			;terminate argument string
	move.b	D0,B_5BB8		;store string length byte
T_15E0:
	clr.b	(A3)+			;reterminate command line
	movem.l	A0/A2,-(SP)
	bsr	T_1690
	movem.l	(SP)+,A0/A2
	rts
;
;----------------------------------------------------------------------------
;
T_15F0:
	moveq	#$ffFFff92,D0
	rts
;
;----------------------------------------------------------------------------
;
T_15F4:
	lea	B_5C38,A3
T_15FA:
	cmpi.b	#$20,(A3)
	beq.s	T_1606
	cmpi.b	#9,(A3)
	bne.s	T_160A
T_1606:
	addq.l	#1,A3
	bra.s	T_15FA
;
T_160A:
	movea.l	A3,A0
	lea	B_5BB8,A1
	clr.b	(A1)+
	clr.b	(A1)
	clr.w	D0
T_1618:
	move.b	(A3),D1
	beq.s	T_1632
	cmpi.b	#13,D1
	beq.s	T_1632
	cmpi.b	#$20,D1
	beq.s	T_1636
	cmpi.b	#9,D1
	beq.s	T_1636
	addq.l	#1,A3
	bra.s	T_1618
;
T_1632:
	movea.l	A3,A2
	bra.s	T_1660
;
T_1636:
	movea.l	A3,A2
T_1638:
	cmpi.b	#$20,(A2)
	bne.s	T_1642
	addq.l	#1,A2
	beq.s	T_1638
T_1642:
	move.b	(A2),D1
	beq.s	T_1658
	cmpi.b	#13,D1
	beq.s	T_1658
	cmpi.b	#$3B,D1
	beq.s	T_1658
	move.b	(A2)+,(A1)+
	addq.w	#1,D0
	bra.s	T_1642
;
T_1658:
	clr.b	(A1)+
	move.b	D0,B_5BB8
T_1660:
	clr.b	(A3)+
	move.l	#0,-(SP)
	pea	B_5BB8
	move.l	A0,-(SP)
	move.w	#0,-(SP)
	move.w	#$4B,-(SP)
	trap	#1			;Pexec
	lea	$10(SP),SP
	rts
;
;----------------------------------------------------------------------------
;
crlf_sub:
	pea	crlf_s
	move.w	#9,-(SP)
	trap	#1			;Cconws
	addq.l	#6,SP
	rts
;
;----------------------------------------------------------------------------
;
T_1690:
	move.w	#0,-(SP)
	move.l	A0,-(SP)
	move.w	#$3D,-(SP)
	trap	#1			;Fopen
	addq.l	#8,SP
	tst.l	D0
	bmi.s	T_16BE
	move.w	D0,B_5CEA
	bsr.s	T_16C2
	move.l	D0,D3
	move.w	B_5CEA,-(SP)
	move.w	#$3E,-(SP)
	trap	#1			;Fclose
	addq.l	#4,SP
	move.l	D3,D0
	rts
;
;----------------------------------------------------------------------------
;
T_16BE:
	moveq	#$ffFFff91,D0
	rts
;
;----------------------------------------------------------------------------
;
T_16C2:
	pea	B_5CCA
	move.l	#$1C,-(SP)
	move.w	B_5CEA,-(SP)
	move.w	#$3F,-(SP)
	trap	#1			;Fread
	lea	12(SP),SP
	bsr	test_prog_header	;d0 = runtime size
	bmi.s	T_171C
	move.l	D0,-(SP)
	move.w	#$48,-(SP)
	trap	#1			;Malloc RAM for program
	addq.l	#6,SP
	move.l	D0,B_5CE6
	beq.s	T_1720
	bsr	T_1794
	bsr.s	T_1724
	bmi.s	T_170E
	bsr	T_F6C
	bsr	T_FA2
	move.l	B_5CE6,D0
	rts
;
;----------------------------------------------------------------------------
;
T_170E:
	move.l	B_5CE6,-(SP)
	move.w	#$49,-(SP)
	trap	#1			;Mfree
	addq.l	#6,SP
T_171C:
	moveq	#$ffFFff90,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1720:
	moveq	#$ffFFff8F,D0
	rts
;
;----------------------------------------------------------------------------
;
T_1724:
	movea.l	B_5CE6,A3
	lea	B_5CCA,A5
	move.l	2(A5),D3
	add.l	6(A5),D3
	move.l	8(A3),-(SP)
	move.l	D3,-(SP)
	move.w	B_5CEA,-(SP)
	move.w	#$3F,-(SP)
	trap	#1			;Fread
	lea	12(SP),SP
	cmp.l	D0,D3
	bne.s	T_1790
	move.l	14(A5),D0
	move.w	#1,-(SP)
	move.w	B_5CEA,-(SP)
	move.l	D0,-(SP)
	move.w	#$42,-(SP)
	trap	#1			;Fseek
	lea	10(SP),SP
	movea.l	$18(A3),A0
	move.l	A0,-(SP)
	move.l	#$7FFFFFFF,-(SP)
	move.w	B_5CEA,-(SP)
	move.w	#$3F,-(SP)
	trap	#1			;Fread
	lea	12(SP),SP
	cmpi.l	#4,D0
	bge.s	T_1792
T_1790:
	moveq	#$ffFFffFF,D0
T_1792:
	rts
;----------------------------------------------------------------------------
T_1794:
	bsr	T_EAA
	movea.l	B_5CE6,A0
	lea	B_5CCA,A2
	move.l	A0,(A0)
	move.l	#$100,D0
	add.l	2(A2),D0
	add.l	6(A2),D0
	add.l	10(A2),D0
	move.l	D0,4(A0)
	movea.l	initial_sp,A1
	move.l	$24(A1),$24(A0)
	move.l	$2C(A1),$2C(A0)
	lea	$80(A0),A1
	move.l	A1,$20(A0)
	lea	B_5BB8,A2
T_17DC:
	move.b	(A2)+,(A1)+
	bne.s	T_17DC
	rts
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
EPro_cookie_t:
	dc.b	$0,$2,$0,$1
	dc.l	gemdos_func_p_t
	dc.l	bios_func_p_t
	dc.b	$0,$0,$0,$0,$0,$0,$0,'d',$0,$0,$0,'d',$0,$0
	dc.b	$0,'0'
	dc.l	meta_FCB_t
DOS_chain_p:
	dc.l	0
BOS_chain_p:
	dc.l	0
	dc.l	weird_cook_p
;End of cookie structure
;----------------------------------------------------------------------------
gemdos_func_p_t:
	dc.l	nu_Pterm_fix		;00 Pterm0
	dcb.l	13,-1	;01..0D
	dc.l	nu_Dsetdrv		;0E Dsetdrv
	dcb.l	10,-1	;0F..18
	dc.l	nu_Dgetdrv		;19 Dgetdrv
	dcb.l	23,-1	;1A..30
	dc.l	nu_Pterm_fix		;31 Ptermres
	dcb.l	4,-1	;32..35
	dc.l	nu_Dfree		;36 Dfree
	dcb.l	2,-1	;37..38
	dc.l	nu_Dcreate_Ddelete	;39 Dcreate
	dc.l	nu_Dcreate_Ddelete	;3A Ddelete
	dc.l	nu_Dsetpath		;3B Dsetpath
	dc.l	nu_Fcreate_Fopen	;3C Fcreate
	dc.l	nu_Fcreate_Fopen	;3D Fopen
	dc.l	nu_Fclose		;3E Fclose
	dc.l	nu_Fread_Fwrite		;3F Fread
	dc.l	nu_Fread_Fwrite		;40 Fwrite
	dc.l	nu_Fdelete_Fattrib	;41 Fdelete
	dc.l	nu_Fseek_Fdatime	;42 Fseek
	dc.l	nu_Fdelete_Fattrib	;43 Fattrib
	dcb.l	3,-1	;44..46
	dc.l	nu_Dgetpath		;47 Dgetpath
	dcb.l	3,-1	;48..4A
	dc.l	nu_Pexec		;4B Pexec
	dc.l	nu_Pterm_fix		;4C Pterm
	dc.l	-1	;4D
	dc.l	nu_Fsfirst		;4E Fsfirst
	dc.l	nu_Fsnext		;4F Fsnext
	dcb.l	6,-1	;50..55
	dc.l	nu_Frename		;56 Frename
	dc.l	nu_Fseek_Fdatime	;57 Fdatime
;----------------------------------------------------------------------------
bios_func_p_t:
	dcb.l	9,-1
	dc.l	nu_Mediach	;09 Mediach
	dcb.l	2,-1
;----------------------------------------------------------------------------
weird_cook_p:
	dc.l	0
Metainfo_1:
	dc.l	0
	dc.l	D_1BB7
	dc.l	0
	dc.l	0
;
error_message_link_t:
	dc.b	'ˇˇˇŸ'
	dc.l	D_1BD3
	dc.b	'ˇˇˇ˚'
	dc.l	D_1BF4
	dc.b	'ˇˇˇÙ'
	dc.l	D_1C11
	dc.b	'ˇˇˇ¸'
	dc.l	D_1C2C
	dc.b	'ˇˇˇÒ'
	dc.l	D_1C38
	dc.b	'ˇˇˇÂ'
	dc.l	D_1C49
	dc.b	'ˇˇˇ‰'
	dc.l	D_1C8D
	dc.b	'ˇˇˇ„'
	dc.l	D_1CA6
	dc.b	'ˇˇˇ‚'
	dc.l	D_1CC2
	dc.b	'ˇˇˇ·'
	dc.l	D_1D05
	dc.b	'ˇˇˇò'
	dc.l	D_1D26
	dc.b	'ˇˇˇñ'
	dc.l	D_1D47
	dc.b	'ˇˇˇó'
	dc.l	D_1D66
	dc.b	'ˇˇˇï'
	dc.l	D_1D89
	dc.b	'ˇˇˇõ'
	dc.l	D_1DA5
	dc.b	'ˇˇˇö'
	dc.l	D_1DC9
	dc.b	'ˇˇˇô'
	dc.l	D_1DED
	dc.b	'ˇˇˇî'
	dc.l	D_1E08
	dc.b	'ˇˇˇì'
	dc.l	D_1E2A
	dc.b	'ˇˇˇí'
	dc.l	D_1E45
	dc.b	'ˇˇˇë'
	dc.l	D_1E65
	dc.b	'ˇˇˇê'
	dc.l	D_1E7D
	dc.b	'ˇˇˇè'
	dc.l	D_1E93
	dc.b	'ˇˇˇé'
	dc.l	D_1EAE
	dc.b	$0,$0,$0,$0
D_1A76:
	dc.b	CR,LF,$1B,'p'
	dc.b	'                                     ',CR,LF
	dc.b	'      ExtenDOS Pro version 2.1       ',CR,LF
	dc.b	' Copyright Ω 1993-1995 Roger Burrows ',CR,LF
	dc.b	'         All rights reserved         ',CR,LF
	dc.b	'                                     ',CR,LF
	dc.b	$1B,'q',CR,LF
	dc.b	$0
;
extendos_cnf_ended_s:
	dc.b	CR,LF,$1B,'p'
	dc.b	'    End of EXTENDOS.CNF processing   ',$1B,'q',CR,LF,$0
D_1B70:
	dc.b	'Pausing because of above error(s)',CR,LF,' '
	dc.b	'   ... press any key to continue',CR,LF,$0
D_1BB7:
	dc.b	'ExtenDOS Pro v2.1 ',$0
star_error_star_s:
	dc.b	'*ERROR* ',$0
D_1BD3:
	dc.b	'No memory to initialise driver',CR,LF,$0
D_1BF4:
	dc.b	'Bad command sent to device',CR,LF,$0
D_1C11:
	dc.b	'General hardware failure',CR,LF,$0
D_1C2C:
	dc.b	'CRC error',CR,LF,$0
D_1C38:
	dc.b	'Unknown device',CR,LF,$0
D_1C49:
	dc.b	'Bad data returned from Inquiry:',CR,LF,'  '
	dc.b	' possible host adapter problem',CR,LF,$0
D_1C8D:
	dc.b	'Invalid device address',CR,LF,$0
D_1CA6:
	dc.b	'Too many physical devices',CR,LF,$0
D_1CC2:
	dc.b	'Bad address: valid numbers are',CR,LF,'   '
	dc.b	'0-7 (ACSI) and/or 8-15 (SCSI)',CR,LF,$0
D_1D05:
	dc.b	'Unknown machine in _MCH cookie',CR,LF,$0
D_1D26:
	dc.b	'Logical drive '
D_1D34:
	dc.b	'X already exists',CR,LF,$0
D_1D47:
	dc.b	'Physical device '
D_1D57:
	dc.b	'X is invalid',CR,LF,$0
D_1D66:
	dc.b	'Physical device '
D_1D76:
	dc.b	'X already exists',CR,LF,$0
D_1D89:
	dc.b	'Expected colon is missing',CR,LF,$0
D_1DA5:
	dc.b	'ExtenDOS Pro is already installed',CR,LF,$0
D_1DC9:
	dc.b	'DOS extender is already installed',CR,LF,$0
D_1DED:
	dc.b	'No memory for cookie jar',CR,LF,$0
D_1E08:
	dc.b	'Can',$27,'t find configuration files:',CR,LF
	dc.b	$0
D_1E2A:
	dc.b	'Too many logical devices',CR,LF,$0
D_1E45:
	dc.b	'No filename in *BOS/*DOS line',CR,LF,$0
D_1E65:
	dc.b	'Driver file not found',CR,LF,$0
D_1E7D:
	dc.b	'Invalid driver file',CR,LF,$0
D_1E93:
	dc.b	'No memory to load driver',CR,LF,$0
D_1EAE:
	dc.b	'Can',$27,'t find default drive offset:',CR,LF
	dc.b	'   please contact Anodyne Software',CR,LF
	dc.b	$0
D_1EF5:
	dc.b	'Device not responding',CR,LF,$0
D_1F0D:
	dc.b	'xxxxxxxx',CR,LF,$0
;
extendos_cnf_spt:
	dc.l	boot_extendos_cnf_s
	dc.l	boot_auto_extendos_cnf_s
	dc.l	boot_extendos_extendos_cnf_s
	dc.l	0
;
boot_extendos_cnf_s:
	dc.b	'Z:\EXTENDOS.CNF',$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
boot_auto_extendos_cnf_s:
	dc.b	'Z:\AUTO\EXTENDOS.CNF',$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
boot_extendos_extendos_cnf_s:
	dc.b	'Z:\EXTENDOS\EXTENDOS.CNF',$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
;
driver_installed_s:
	dc.b	'Driver installed',$0
as_x_drive_s:
	dc.b	' as x:',$0
on_xCSI_x_LUN_x_s:
	dc.b	' on xCSI x LUN x'
crlf_s:
	dc.b	CR,LF,$0
logical_device_x_s:
	dc.b	'Driver installed as logical device x:',$0,$0
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
		ds.l	192			;=768
init_stk_top:	ds.l	1			;=4
		ds.l	96			;=384
gemdos_save_p:	ds.l	1			;=4
		ds.l	96			;=384
bios_save_p:	ds.l	1			;=4
		ds.l	96			;=384
xbios_save_p:	ds.l	1			;=4
;
old_resvalid:
	ds.l	1			;=4
bios_SR:
	ds.w	1			;=2
loc_currbp_p_p:
	ds.l	1			;=4
bp_drive_index:
	ds.w	1			;=2
B_2790:
	ds.w	1			;=2
boot_letter:
	ds.b	1			;=1
B_2793:
	ds.b	1			;=1
found_DOS:
	ds.l	1			;=4
init_buff_1:
	ds.l	64
B_2898:
	ds.l	1			;=4
;
meta_FCB_t:		ds.b	FCB_limit*sizeof_FCB
meta_DOS_t:		ds.b	DOS_limit*sizeof_DOS
BOS_DOS_init_d0:	ds.l	1			;=4
current_DOS:		ds.l	1			;=4
;
B_5BB0:
	ds.l	1			;=4
B_5BB4:
	ds.l	1			;=4
B_5BB8:
	ds.l	32			;=128
B_5C38:
	ds.w	65			;=130
next_DOS_p:
	ds.l	1			;=4
DOS_init_d1:
	ds.l	1			;=4
initial_sp:
	ds.l	1			;=4
B_5CC6:
	ds.w	1			;=2
B_5CC8:
	ds.w	1			;=2
B_5CCA:
	ds.l	7			;=28
B_5CE6:
	ds.l	1			;=4
B_5CEA:
	ds.w	3			;=6
B_5CF0:
	ds.b	1			;=1
B_5CF1:
	ds.b	1			;=1
B_5CF2:
	ds.l	1			;=4
B_5CF6:
	ds.l	1			;=4
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	EXTENDOS.S
;----------------------------------------------------------------------------
