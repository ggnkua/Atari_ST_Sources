;----------------------------------------------------------------------------
;File name:	BetaDOS.S			Revision date:	2000.07.02
;Created by:	Ulf Ronald Andersson		Creation start:	1998.01.27
;----------------------------------------------------------------------------
	include	RA_STRUC.I
	include	RA_SYS.I
	include	RA_TOS.I
	include	RA_FCNTL.I
	include	RA_JAR.I
	include	RA_XB.I
	include	BS_COMP\TRACER.I
;----------------------------------------------------------------------------
BetaDos_VERSION	MACRO
	dc.b	'3.10'
	ENDM
BetaDos_YEAR	MACRO
	dc.b	'2000'
	ENDM
BetaDos_DATE	MACRO
	BetaDos_YEAR
	dc.b	' Jul 02'
	ENDM
;----------------------------------------------------------------------------
REFUSE_AFTER_MINT	=	0	;0 allows booting after MiNT
DEBUG_TRACE_CACHE	=	0	;0 disables trace cache (normal)
DEBUG_etv_critic	=	0	;0 for normal version
DEBUG_FCB_count		=	0	;0 for normal version
DEBUG_drive_char	=	'V'	;DOS drive to be debugged
;----------------------------------------------------------------------------
trace_mode		set	0	;0 disables interactive tracing
;----------------------------------------------------------------------------
DOS_limit	= 26	;total number of DOS devices allowed
DTA_limit	= 100	;total number of MetaDos DTAs made available
FCB_limit	= 100	;total number of MetaDos FCBs made available
PATH_limit	= 220	;maximum length of expanded MetaDos paths
E_1001		= -1001	;internal error code for 'unimplemented' functions
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
BOS_title_s	= 28	;terminated name string <= 31 chars + term
sizeof_BOS	= 60	;so string above is max 32 bytes long (incl NUL)
;----------------------------------------------------------------------------
;	Patches for dual compatibility with ExtenDOS and MetaDOS
;
MetaDOS_FCB	=	42	;bytes used by MetaDOS per FCB
ExtenDOS_FCB	=	48	;bytes used by ExtenDOS per FCB
;
BetaDOS_FCB	=	ExtenDOS_FCB	;set FCB type here
;
	struct	FCB
	byte	FCB_free,32	;32 free FCB bytes for all MetaDOS DOS drivers
	IFNE	(BetaDOS_FCB>MetaDOS_FCB)
	byte	FCB_extfree,8	;8 free FCB bytes added for ExtenDOS DOS drivers
	ENDC
	long	FCB_owner		;-> basepage of owner process
	long	FCB_DOS_p		;-> DOS or -1 if unused
	word	FCB_dirflag		;$01 for dirs, $00 for files (MetaDOS ONLY)
	char	FCB_path,PATH_limit	;path buffer (BetaDOS ONLY)
	d_end	FCB
;
;NB: Fully compatible FCB adaption is not possible because the indexing of
;    ExtenDOS differs.  ExtenDOS offset $28 == MetaDOS offset $20, and the
;    FCB_dirflag does not exist in ExtenDOS.
;----------------------------------------------------------------------------
	struct	M_dta
	struc_p	M_dta_prev
	struc_p	M_dta_next
	struc_p	M_dta_DTA
	struc_p	M_dta_DOS
	d_s	M_dta_path,PATH_limit
	d_end	M_dta
;----------------------------------------------------------------------------
	struct	M_frame
	word	M_frame_sr
	long	M_frame_retadr
	long	M_frame_reent_retadr
	long	M_frame_reent_extra
	d_s	M_frame_regs,14*4	;for d1-d7/a1-a7
	d_end	M_frame
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
start:
	movea.l	sp,a5
	lea	init_stk_top,sp
	movea.l	4(a5),a5		;a5 -> basepage
	move.l	a5,basepage_p
	move.l	12(a5),d0
	add.l	$1c(a5),d0
	add.l	$14(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)		;push prog_size
	gemdos	Mshrink,#0,(a5),d0	;release RAM
;
	gemdos	Super,0.w		;Enter Super
	move.l	d0,-(sp)		;push old SSP
	move.w	#(Super&$ff),-(sp)	;push Super
;
	gemdos	Cconws,d_1fbc
	xbios	Metainit,init_buff_1
	tst.l	init_buff_1
	bne.s	test_reinstall		;test further if any Metados active
	IFNE	REFUSE_AFTER_MINT
	eval_cookie	#'MiNT'
	bpl.s	abort_after_MiNT	;refuse booting after MiNT
	ENDC
	bsr	test_basepage_usage_safely
	bsr	init_sub_0
	bsr	init_sub_1
	gemdos	Cconws,d_2037
	trap	#1			;leave Super
	addq.w	#6,sp
	move.l	(sp)+,d7		;d7 = prog_size
	gemdos	Ptermres,d7,#0
;----------------------------------------------------------------------------
test_reinstall:
	trace	'c'
	eval_cookie	#'MiNT'
;;;	bmi.s	abort_reinstall		;abort reinstall if MiNT absent
	trace	'C'
;-------
	trace	't'
	lea	(etv_term).w,a0
	move.l	#'_MET',d0
	bsr.s	retop_vector
	trace	'T'
;-------
	trace	'b'
	lea	(ev_bios).w,a0
	move.l	#'EPro',d0
	bsr.s	retop_vector
	trace	'B'
;-------
	trace	'x'
	lea	(ev_xbios).w,a0
	move.l	#'_MET',d0
	bsr.s	retop_vector
	trace	'X'
;-------
	trace	'g'
	lea	(ev_gemdos).w,a0
	move.l	#'_MET',d0
	bsr.s	retop_vector
	trace	'G'
	bmi.s	abort_reinstall
;-------
	move.l	-12(a1),a0		;a0 -> patch sub of found BetaDOS
	jsr	(a0)			;tell found BetaDOS to repatch
	move.l	#BDOS_repatched_s,d0
	bra.s	abort_common
;-------
abort_reinstall:
	move.l	#BDOS_already_installed_s,d0
	bra.s	abort_common
;----------------------------------------------------------------------------
	IFNE	REFUSE_AFTER_MINT
abort_after_MiNT:
	move.l	#MiNT_must_boot_later_s,d0
	ENDC
abort_common:
	gemdos	Cconws|_ind,d0
	trap	#1			;leave Super
	addq.w	#6,sp
	gemdos	Pterm,#2
;----------------------------------------------------------------------------
	illegal
	illegal
;----------------------------------------------------------------------------
retop_vector:
	move.l	a0,-(sp)	;push a0 -> vector
	trace	'i'
	XB_seek_name		;found id in vector chain ?
	bmi	retop_ERR	;else abort
	trace	'I'
	move.l	d0,a1		;a1 -> link to found ESR
	move.l	(a1),a1		;a1 -> xb_code of found ESR
	lea	-xb_code(a1),a1	;a1 -> XBRA struct of found ESR
	movem.l	-8(a1),d0/d1	;d0/d1 = 8 bytes preceding struct
	cmp.l	#'Beta',d0	;check first four bytes
	bne	retop_ERR	;abort if not matching "BetaDOS"
	trace	'1'
	cmp.l	#'DOS'<<8,d1	;check last four bytes
	bne	retop_ERR	;abort if not matching "BetaDOS"
	trace	'2'
	XB_kill_code		;remove the struct from vector chain
	bmi.s	retop_ERR	;abort if struct already gone
	trace	'K'
	move.l	(sp)+,a0	;pull a0 -> vector
	XB_init			;reinit struct as vector chain root
	moveq	#E_OK,d0
	rts
;-------
retop_ERR:
	trace	'E'
	move.l	(sp)+,a0	;pull a0 -> vector
	moveq	#E_ERROR,d0
	rts
;----------------------------------------------------------------------------
repatch_sub:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	test_basepage_usage_safely
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;----------------------------------------------------------------------------
test_MiNT:
	movea.l	(_cookies).w,a0
	cmpa.l	#0,a0
	bne.s	.test_cookie
	clr.w	d0
	rts
;-------
.test_cookie:
	tst.l	0(a0)
	bne.s	.have_cookie
	clr.w	d0
	rts
;-------
.have_cookie:
	cmpi.l	#'MiNT',0(a0)
	beq.s	.found
	addq.w	#8,a0
	bra	.test_cookie
;-------
.found:
	moveq	#1,d0
	rts
;----------------------------------------------------------------------------
init_sub_0:
	clr.l	TOS_patch_p
	movea.l	(_sysbase).w,a0
	move	os_version(a0),d0
	cmp	#$100,d0		;TOS 1.00 ?
	bne.s	t_110
	move.l	#$56ec,TOS_patch_p
	bra.s	t_120
;
t_110:
	cmp.w	#$102,d0		;TOS 1.02 ?
	bne.s	t_120
	move.l	#$7e8e,TOS_patch_p
t_120:
	bsr	find_os_currbp_p
	move.l	d0,loc_currbp_p_p
	tst.w	(_longframe).w
	beq.s	t_138
	move.w	#8,frame_size
	move	#2,frame_offset
t_138:
	move.l	(ev_xbios).w,MD_xbios_XB+xb_next
	move.l	#MD_xbios_XB+xb_code,(ev_xbios).w
	move.l	(ev_bios).w,MD_bios_XB+xb_next
	move.l	#MD_bios_XB+xb_code,(ev_bios).w
;
	lea	boot_bdconfig_sys_s(pc),a0
	move.w	(_bootdev).w,d0
	add.w	#$41,d0
	move.b	d0,(a0)
;
	move	#FCB_limit-1,d0
	lea	meta_FCB_t,a0
t_176:
	move.l	#-1,FCB_DOS_p(a0)
	adda	#sizeof_FCB,a0
	dbra	d0,t_176
	IFNE	DEBUG_FCB_count
	clr	FCB_count
	ENDC
;
	clr.b	init_buff_1
	clr.b	expanded_path
;
	moveq	#DTA_limit-1,d2
	lea	M_dta_t(pc),a0
	move.l	a0,M_dta_first		;init M_dta_first -> array base
	clr.l	d1			;d1 = NULL as initial -> prev
init_M_dta_t:
	move.l	a0,d0			;d0 = this
	lea	sizeof_M_dta(a0),a1	;a1 -> next
	move.l	d1,(a0)+		;link this to prev
	move.l	a1,(a0)+		;link this to next
	clr.l	(a0)+			;NULL -> DTA
	clr.l	(a0)+			;NULL -> DOS
	clr.b	(a0)			;NUL path string
	move.l	d0,d1			;prev = this
	move.l	a1,a0			;this = next
	dbra	d2,init_M_dta_t
	move.l	d1,a0			;a0 -> last entry
	clr.l	M_dta_next(a0)		;NULL -> next of last entry
	move.l	a0,M_dta_last		;init M_dta_last -> last entry
;
	lea	M_frame_sp(pc),a0
	move.l	a0,M_frame_sp
	move.l	(ev_gemdos).w,MD_gemdos_XB+xb_next
	move.l	#MD_gemdos_XB+xb_code,(ev_gemdos).w
	move.l	(etv_term).w,MD_etv_term_XB+xb_next
	move.l	#MD_etv_term_XB+xb_code,(etv_term).w
;
	make_cookie	#'EPro',#EPro_cookie_t
	IFNE		DEBUG_FCB_count
	make_cookie	#'MFCB',#MFCB_cookie_t
	ENDC
	rts
;----------------------------------------------------------------------------
test_basepage_usage_safely:
	gemdos	Dgetdrv
	move	d0,d5
	bsr.s	test_basepage_usage_simply
	move.l	d3,d4
	moveq	#15,d5
	bsr.s	test_basepage_usage_simply
	and.l	d3,d4
	moveq	#0,d5
	bsr.s	test_basepage_usage_simply
	and.l	d3,d4
	moveq	#2,d5
	bsr.s	test_basepage_usage_simply
	and.l	d3,d4
	beq.s	.error
;-------
	moveq	#9,d0		;test flag for offset $39
	btst	d0,d4
	bne.s	.set_index
	moveq	#7,d0		;test flag for offset $37
	btst	d0,d4
	bne.s	.set_index
;-------
	clr.l	d1
	clr.l	d2
	moveq	#32-1,d0
.loop:
	btst	d0,d4
	beq.s	.next
	move	d0,d1
	addq	#1,d2
.next:
	dbra	d0,.loop
	move	d1,d0
.set_index:
	add	#$30,d0
	move	d0,bp_drive_index
	rts
;-------
.error:
	move	#$7F,bp_drive_index
	clr.l	d0
	rts
;----------------------------------------------------------------------------
test_basepage_usage_simply:
	gemdos	Dgetdrv
	move.w	d0,-(sp)
	gemdos	Dsetdrv,d5
	clr.l	d3
	moveq	#32-1,d0		;test 32 basepage positions
.loop:
	cmp.b	$30(a5,d0.w),d5		;test position in range $30..$4F
	bne.s	.next
	bset	d0,d3
.next:
	dbra	d0,.loop
	gemdos	Dsetdrv,()
	move.l	d0,gemdos_drvbits
	rts	
;----------------------------------------------------------------------------
find_char_d0_DOS:
	cmp	#-1,d0
	beq.s	.exit
	movea.l	DOS_chain_p(pc),a0
	bra.s	.test_next
;
.loop:
	cmp	DOS_char(a0),d0
	beq.s	.found_it
	movea.l	DOS_next(a0),a0
.test_next:
	cmpa.l	#0,a0		;is a0 NULL ptr ?
	bne	.loop
	moveq	#E_UNDEV,d0
	rts
;
.found_it:
	move.l	a0,found_DOS
.exit:
	rts
;----------------------------------------------------------------------------
find_BOS_link:
	cmp	#-1,d0
	beq.s	.t_216
	movea.l	BOS_chain_p(pc),a1
	bra.s	.t_20c
;
.t_202:
	cmp	BOS_char(a1),d0
	beq.s	.t_216
	movea.l	BOS_next(a1),a1
.t_20c:
	cmpa.l	#0,a1
	bne.s	.t_202
	moveq	#E_UNDEV,d0
.t_216:
	rts
;----------------------------------------------------------------------------
;Start of:	XBRA linked etv_term code
;----------------------------------------------------------------------------
	dc.l	'Beta'
	dc.l	'DOS'<<8
	XB_define	MD_etv_term_XB,'_MET'
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	MD_etv_term_sub
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	MD_etv_term_XB+xb_next,-(sp)
	rts
;----------------------------------------------------------------------------
;End of:	XBRA linked etv_term code
;----------------------------------------------------------------------------
;Start of:	XBRA linked bios dispatcher
;----------------------------------------------------------------------------
	dc.l	'Beta'
	dc.l	'DOS'<<8
	XB_define	MD_bios_XB,'EPro'
	btst	#5,(sp)
	beq.s	.user_called
.super_called:
	lea	(sp),a0
	add	frame_size(pc),a0
	bra.s	.have_arg_p
;-------
.user_called:
	move	usp,a0
.have_arg_p:				;here a0 -> args at precall stack pos
	move	(a0),d0				;d0 = bios opcode
	cmp	#MD_bios_func_t_cnt,d0
	bhs.s	MD_goto_old_bios
	move.l	a0,-(sp)			;push a0
	asl	#2,d0				;scale d0 as ptr index
	lea	MD_bios_func_t(pc),a0		;a0 -> function table
	tst.b	(a0,d0.w)			;test top byte of pointer
	movea.l	(sp)+,a0			;pull a0, but keep test result
	bpl.s	MD_use_new_bios			;if positive, go try function
MD_goto_old_bios:
	movea.l	MD_bios_XB+xb_next(pc),a0
	jmp	(a0)
;------------------------------------
MD_use_new_bios:
	sub.l	#sizeof_M_frame,M_frame_sp	;reserve frame storage
	move.l	M_frame_sp(pc),d0		;d0 -> frame storage
	exg	a0,d0				;d0 -> func args  a0 -> frame storage
	move	(sp)+,(a0)+			;store frame sr
	move.l	(sp)+,(a0)+			;store frame retadr
	add	frame_offset(pc),sp		;sp -> pretrap SSP
	move.l	reent_retadr(pc),(a0)+		;store reentrant retadr
	move.l	reent_extra(pc),(a0)+		;store reentrant extra buffer
	movem.l	d1-d7/a1-a7,(a0)		;store entry registers except d0/a0
	move.l	d0,sp				;sp = pretrap SP -> func args
;-------
	move.w	(sp),d1				;d1 = function opcode
	add.w	d1,d1				;\/ D1 = opcode * 4
	add.w	d1,d1				;/\ index to longs
	lea	MD_bios_func_t(pc),a1		;a1 -> function table
	move.l	0(a1,d1.w),d0			;d0 -> function code
	bmi.s	MD_use_old_bios			;use old bios if negative (should now never happen !)
	movea.l	d0,a1				;a1 -> function code
	jsr	(a1)				;call function code
	tst.l	d0
	bpl.s	.function_completed
	cmp.l	#E_1001,d0
	beq.s	MD_use_old_bios			;use old bios if internal function returns E_1001
.function_completed:
	movea.l	M_frame_sp(pc),a0			;a0 -> frame storage
	movem.l	M_frame_regs(a0),d1-d7/a1-a7		;restore entry registers, except d0/a0
	move.l	M_frame_reent_retadr(a0),reent_retadr	;restore reentrant retadr
	move.l	M_frame_reent_extra(a0),reent_extra	;restore reentrant extra buffer
	tst	(_longframe).w
	beq.s	.cpu_adapted
	clr	-(sp)					;repush frame type word for new CPUs
.cpu_adapted:
	move.l	M_frame_retadr(a0),-(sp)		;repush frame retadr
	move	M_frame_sr(a0),-(sp)			;repush	frame sr
	add.l	#sizeof_M_frame,M_frame_sp		;release frame storage
	rte
;------------------------------------
MD_use_old_bios:
	movea.l	M_frame_sp(pc),a0			;a0 -> frame storage
	movem.l	M_frame_regs(a0),d1-d7/a1-a7		;restore entry registers, except d0/a0
	move.l	M_frame_reent_retadr(a0),reent_retadr	;restore reentrant retadr
	move.l	M_frame_reent_extra(a0),reent_extra	;restore reentrant extra buffer
	tst	(_longframe).w
	beq.s	.cpu_adapted
	clr	-(sp)					;repush frame type word for new CPUs
.cpu_adapted:
	move.l	M_frame_retadr(a0),-(sp)		;repush frame retadr
	move	M_frame_sr(a0),-(sp)			;repush	frame sr
	add.l	#sizeof_M_frame,M_frame_sp	;release frame storage
	movea.l	MD_bios_XB+xb_next,a0
	jmp	(a0)
;----------------------------------------------------------------------------
;nu_Mediach below is similar to that used by Extendos, but is now disabled
;by not including its pointer in MD_bios_func_t.  It conflicts with usage of
;CORRECT.PRG of the KOBOLD package.  Patch MD_bios_func_t to reenable it.
;----------------------------------------------------------------------------
nu_Mediach:
	move.w	6(SP),d0		;d0 = DOS_drive
	cmp	#32,d0
	bhs	E_1001_sub		;leave illegal drives to other benders
	move.l	meta_drvbits(pc),d1
	btst	d0,d1
	beq	E_1001_sub		;leave unknown drives to other benders
	lea	dosdev2boschr_t(pc),a1
	move.b	(a1,d0),d0		;d0 = BOS_char
	bsr	find_BOS_link		;is there a BOS driver for it ?
	bmi.s	.exit_ok		;else assume constant medium
	xbios	Metastatus,d0,!		;Call Metastatus(BOS_char,NULL)
	tst.l	D0			;any kind of media change or error ?
	bpl.s	.exit_ok		;if not, go exit with d0 = 0
	btst	#15,d0			;error ?
	bne.s	.exit_error		;if so, go exit with -1 as error code
	btst	#2,d0			;medium changed ?
	beq.s	.exit_ok		;if not, go exit with 0
	moveq	#2,D0			;d0 = 2, to flag media changed
	rts
;
.exit_error:
	moveq	#-1,d0
	rts
;
.exit_ok:
	clr.l	d0
	rts
;----------------------------------------------------------------------------
;End of:	XBRA linked bios dispatcher
;----------------------------------------------------------------------------
;Start of:	XBRA linked xbios dispatcher
;----------------------------------------------------------------------------
	dc.l	'Beta'
	dc.l	'DOS'<<8
	XB_define	MD_xbios_XB,'_MET'
	btst	#5,(sp)
	beq.s	.user_called
.super_called:
	lea	(sp),a0
	add	frame_size(pc),a0
	bra.s	.have_arg_p
;
.user_called:
	move	usp,a0
.have_arg_p:
	move	(a0),d0				;d0 = function opcode
	cmp	#$30,d0
	blt.s	MD_goto_old_xbios
	cmp	#$3f,d0
	bls.s	MD_use_new_xbios
MD_goto_old_xbios:
	movea.l	MD_xbios_XB+xb_next(pc),a0
	jmp	(a0)
;------------------------------------
MD_use_new_xbios:
	cmpi	#$30,d0
	bne.s	.not_Metainit
.nu_Metainit:
	movea.l	2(a0),a0
	lea	Metainfo_1(pc),a1
	move.l	(a1)+,(a0)+	;drivemap
	move.l	(a1)+,(a0)+	;-> version
	move.l	(a1)+,(a0)+	;reserved
	move.l	(a1)+,(a0)	;-> metainfo_2 structure
	rte
;------------------------------------
.not_Metainit:
	sub.l	#sizeof_M_frame,M_frame_sp	;reserve frame storage
	move.l	M_frame_sp(pc),d0		;d0 -> frame storage
	exg	a0,d0				;d0 -> func args  a0 -> frame storage
	move	(sp)+,(a0)+			;store frame sr
	move.l	(sp)+,(a0)+			;store frame retadr
	add	frame_offset(pc),sp		;sp -> pretrap SSP
	move.l	reent_retadr(pc),(a0)+		;store reentrant retadr
	move.l	reent_extra(pc),(a0)+		;store reentrant extra buffer
	movem.l	d1-d7/a1-a7,(a0)		;store entry registers except d0/a0
	move.l	d0,sp				;sp = pretrap SP -> func args
;
	move	2(sp),d0		;d0 = BOS_char
	bsr	find_BOS_link
	bmi.s	MD_use_old_xbios
;
	movem	(sp)+,d1/d2		;d1/d2 = fun_code/BOS_char, pulled
	movem	d1/d2,reent_extra	;save these for later restoration
;
;Here sp -> args after BOS_char
;
	movea.l	a1,a0			;a0 -> BOS device structure
	movea.l	BOS_func_tp(a1),a1	;a1 -> BOS function table
	sub	#$30,d1
	cmp	#7,d1			;Metaioctl function ?
	bne.s	.use_normal_BOS
	cmpi.b	#$FF,(a1)		;extendos Metaioctl code legal ?  ($FF)
	beq.s	.use_normal_BOS		;else use normal driver
	cmpi.l	#'FCTL',(sp)		;first argument 'FCTL' ?
	bne.s	.use_normal_BOS		;else use normal driver
	move.b	5(sp),d1		;d1 = subfunction code
	cmp.b	(a1),d1			;is subfunction code in legal range ?
	blt.s	.use_FCTL_code		;if so, go use this function
	moveq	#7,d1			;restore original function code
	bra.s	.use_normal_BOS		;go use normal driver
;
.use_FCTL_code:
	add	#$10,D1			;step index past Metados functions
.use_normal_BOS:
	move	d2,d0			;d0 = BOS drive
	asl	#2,d1
	movea.l	(a1,d1),a1
	jsr	(a1)			;call function in BOS driver
	move.l	reent_extra(pc),-(sp)	;push fun_code.BOS_char, as saved earlier
;
;Here sp -> stack data in original pre_call state and location
;
.function_completed:
	movea.l	M_frame_sp(pc),a0			;a0 -> frame storage
	movem.l	M_frame_regs(a0),d1-d7/a1-a7		;restore entry registers, except d0/a0
	move.l	M_frame_reent_retadr(a0),reent_retadr	;restore reentrant retadr
	move.l	M_frame_reent_extra(a0),reent_extra	;restore reentrant extra buffer
	tst	(_longframe).w
	beq.s	.cpu_adapted
	clr	-(sp)					;repush frame type word for new CPUs
.cpu_adapted:
	move.l	M_frame_retadr(a0),-(sp)		;repush frame retadr
	move	M_frame_sr(a0),-(sp)			;repush	frame sr
	add.l	#sizeof_M_frame,M_frame_sp		;release frame storage
	rte
;------------------------------------
MD_use_old_xbios:
	movea.l	M_frame_sp(pc),a0			;a0 -> frame storage
	movem.l	M_frame_regs(a0),d1-d7/a1-a7		;restore entry registers, except d0/a0
	move.l	M_frame_reent_retadr(a0),reent_retadr	;restore reentrant retadr
	move.l	M_frame_reent_extra(a0),reent_extra	;restore reentrant extra buffer
	tst	(_longframe).w
	beq.s	.cpu_adapted
	clr	-(sp)					;repush frame type word for new CPUs
.cpu_adapted:
	move.l	M_frame_retadr(a0),-(sp)		;repush frame retadr
	move	M_frame_sr(a0),-(sp)			;repush	frame sr
	add.l	#sizeof_M_frame,M_frame_sp	;release frame storage
	movea.l	MD_xbios_XB+xb_next,a0
	jmp	(a0)
;----------------------------------------------------------------------------
;End of:	XBRA linked xbios dispatcher
;----------------------------------------------------------------------------
use_etv_critic:
	cmp.l	#-1,d0
	bgt.s	.exit
	cmp.l	#-$11,d0
	blt.s	.exit
	movea.l	found_DOS(pc),a1
	btst	#2,DOS_FSmode_bits+3(a1)	;0 => use etv_critic for EWRPRO
	beq.s	.done_WRPRO_fix
	cmp.l	#E_WRPRO,d0
	beq.s	.exit
.done_WRPRO_fix:
	move.l	d0,-(sp)
	bios	Setexc,#etvn_critic,?
	movea.l	d0,a0			;a0 -> etv_critic code
	move.l	(sp)+,d0
	movea.l	found_DOS(pc),a1	;a1 -> latest DOS structure used
	move	DOS_char(a1),-(sp)	;push DOS drive char as word
;-------
	IFNE	DEBUG_etv_critic
	cmp	#DEBUG_drive_char,(sp)
	bne.s	.done_break
	st	break_etv_critic_f
.done_break
	ENDC	;DEBUG_etv_critic
;-------
	sub	#'A',(sp)		;convert DOS drive char to drive code
	move	d0,-(sp)		;push error code word
	jsr	(a0)			;call etv_critic code with 2 word arguments
	addq.l	#4,sp			;clean stack after etv_critic call
.exit:
	rts
;----------------------------------------------------------------------------
;Start of:	XBRA linked gemdos dispatcher
;----------------------------------------------------------------------------
	dc.l	repatch_sub
	dc.l	'Beta'
	dc.l	'DOS'<<8
	XB_define	MD_gemdos_XB,'_MET'
	btst	#5,(sp)
	beq.s	.user_called
.super_called:
	lea	(sp),a0
	add	frame_size(pc),a0
	bra.s	.have_arg_p
;
.user_called:
	move	usp,a0
.have_arg_p:
	move	(a0),d0
	cmp	#MD_gemdos_func_t_cnt,d0
	bhs.s	MD_goto_old_gemdos
	move.b	MD_gemdos_func_f(pc,d0.w),d0
	bpl.s	MD_use_new_func_1
MD_goto_old_gemdos:
	movea.l	MD_gemdos_XB+xb_next(pc),a0
	jmp	(a0)
;	
MD_use_new_func_1:
	bra	MD_use_new_func_2
;----------------------------------------------------------------------------
;Start of:	MD_gemdos_func_f
;----------------------------------------------------------------------------
MD_gemdos_func_f:
	dc.b	00,-1,-1,-1,-1,-1,-1,-1		;Pterm0
	dc.b	-1,-1,-1,-1,-1,-1,00,-1		;Dsetdrv
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1		;Slbopen,Slbclose (only with OVL)
	dc.b	-1,00,-1,-1,-1,-1,-1,-1		;Dgetdrv
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,00,-1,-1,-1,-1,00,-1		;Ptermres,Dfree
	dc.b	-1,00,00,00,00,00,00,00		;Dcreate,Ddelete,Dsetpath,Fcreate,Fopen,Fclose,Fread
	dc.b	00,00,00,00,-1,-1,00,00		;Fwrite,Fdelete,Fseek,Fattrib,Fforce,Dgetpath
	dc.b	-1,-1,-1,00,00,-1,00,00		;Pexec,Pterm,Fsfirst,Fsnext
	dc.b	-1,-1,-1,-1,-1,-1,00,00		;Frename, Fdatime
	dcb.b	168,-1
	dc.b	-1,-1,-1,-1,00,-1,-1,-1		;260 Fcntl
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,00,-1,-1,-1		;292 Dpathconf
	dc.b	00,00,00,00,00,00,00,00		;296-303
	dc.b	00,-1,-1,-1,-1,-1,-1,-1		;304 Dcntl
	dc.b	-1,-1,-1,-1,00,-1,-1,-1		;316 Dgetcwd
	dc.b	-1,-1,00,-1,-1,-1,-1,-1		;322 Dxreaddir
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,00,00,-1,-1,-1,-1		;338,339 Dreadlabel,Dwritelabel
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
MD_gemdos_func_f_end:
MD_gemdos_func_f_cnt	=	(MD_gemdos_func_f_end-MD_gemdos_func_f)
Slbopen_f	=	MD_gemdos_func_f+(Slbopen&$fff)
;----------------------------------------------------------------------------
;End of:	MD_gemdos_func_f
;----------------------------------------------------------------------------
MD_use_new_func_2:
;-------
	IFNE	DEBUG_TRACE_CACHE
	move.l	($3EC).w,d0
	and.l	#$E,d0
	or.l	#$3F0,d0			;d0 -> trace storage
	move.l	d0,($3EC).w
	addq.l	#2,($3EC).w
	move	(a0),-(sp)			;push gemdos opcode
	exg	a0,d0				;d0 -> args  a0 -> trace storage
	move	(sp)+,(a0)			;pull gemdos opcode to storage
	exg	a0,d0				;a0 -> args again
	ENDC
;-------
	sub.l	#sizeof_M_frame,M_frame_sp	;reserve frame storage
	move.l	M_frame_sp(pc),d0		;d0 -> frame storage
	exg	a0,d0				;d0 -> func args  a0 -> frame storage
	move	(sp)+,(a0)+			;store frame sr
	move.l	(sp)+,(a0)+			;store frame retadr
	add	frame_offset(pc),sp		;sp -> pretrap SSP
	move.l	reent_retadr(pc),(a0)+		;store reentrant retadr
	move.l	reent_extra(pc),(a0)+		;store reentrant extra buffer
	movem.l	d1-d7/a1-a7,(a0)		;store entry registers except d0/a0
	move.l	d0,sp				;sp = pretrap SP -> func args
;
.access_loop:
	move	(sp),d1				;d1 = function opcode
	asl	#2,d1				;d1 = opcode * 4
	lea	MD_gemdos_func_t(pc),a1		;a1 -> function table
	move.l	0(a1,d1),d0			;d0 -> function code
	bmi.s	MD_use_old_gemdos		;use old gemdos if negative (should now never happen !)
	movea.l	d0,a1				;a1 -> function code
	jsr	(a1)				;call function code
	tst.l	d0
	bpl.s	.function_completed
	cmp.l	#E_1001,d0
	beq.s	MD_use_old_gemdos		;use old gemdos if internal function returns E_1001
	bsr	use_etv_critic
	cmp.l	#$10000,d0
	beq.s	.access_loop
.function_completed:
	movea.l	M_frame_sp(pc),a0			;a0 -> frame storage
	movem.l	M_frame_regs(a0),d1-d7/a1-a7		;restore entry registers, except d0/a0
	move.l	M_frame_reent_retadr(a0),reent_retadr	;restore reentrant retadr
	move.l	M_frame_reent_extra(a0),reent_extra	;restore reentrant extra buffer
	tst	(_longframe).w
	beq.s	.cpu_adapted
	clr	-(sp)					;repush frame type word for new CPUs
.cpu_adapted:
	move.l	M_frame_retadr(a0),-(sp)		;repush frame retadr
	move	M_frame_sr(a0),-(sp)			;repush	frame sr
	add.l	#sizeof_M_frame,M_frame_sp		;release frame storage
;-------
	IFNE	DEBUG_etv_critic
	tst.b	break_etv_critic_f
	beq.s	.done_break
	sf	break_etv_critic_f
	illegal
.done_break:
	ENDC	;DEBUG_etv_critic
;-------
	rte
;------------------------------------
	IFNE	DEBUG_etv_critic
break_etv_critic_f:	dc.w	0
	ENDC	;DEBUG_etv_critic
;------------------------------------
MD_use_old_gemdos:
	movea.l	M_frame_sp(pc),a0			;a0 -> frame storage
	movem.l	M_frame_regs(a0),d1-d7/a1-a7		;restore entry registers, except d0/a0
	move.l	M_frame_reent_retadr(a0),reent_retadr	;restore reentrant retadr
	move.l	M_frame_reent_extra(a0),reent_extra	;restore reentrant extra buffer
	tst	(_longframe).w
	beq.s	.cpu_adapted
	clr	-(sp)					;repush frame type word for new CPUs
.cpu_adapted:
	move.l	M_frame_retadr(a0),-(sp)		;repush frame retadr
	move	M_frame_sr(a0),-(sp)			;repush	frame sr
	add.l	#sizeof_M_frame,M_frame_sp	;release frame storage
	movea.l	MD_gemdos_XB+xb_next,a0
	jmp	(a0)
;----------------------------------------------------------------------------
;End of:	XBRA linked gemdos dispatcher
;----------------------------------------------------------------------------
;gemdos_sub below is used to call _old_ gemdos with the macro sub_gemdos
;----------------------------------------------------------------------------
gemdos_sub:
	move.l	(sp)+,reent_retadr	;pull reent_retadr -> retadr
	tst	(_longframe).w		;modern CPU ?
	beq.s	.cpu_adapted
	clr	-(sp)			;push frame type for modern CPUs
.cpu_adapted:
	pea	.post_old_gemdos(pc)		;push frame retadr
	move	sr,-(sp)			;push frame sr
	movea.l	MD_gemdos_XB+xb_next(pc),a0	;a0 -> old gemdos dispatcher
	jmp	(a0)				;goto old gemdos dispatcher
;
.post_old_gemdos:
	move.l	reent_retadr(pc),-(sp)	;push reent_retadr as retadr
	rts				;return to caller
;----------------------------------------------------------------------------
tstpop_meta_dhd:
	cmp.l	#100,d0
	blt.s	popret_E_1001	;if too low, go use old gemdos
	cmp.l	#100+FCB_limit-1,d0
	bgt.s	popret_E_1001	;if too high, go use old gemdos
	tst.l	d0
	rts
;
tstpop_meta_fhd:
	cmp	#100,d0
	blt.s	popret_E_1001	;if too low, go use old gemdos
	cmp	#100+FCB_limit-1,d0
	bgt.s	popret_E_1001	;if too high, go use old gemdos
	tst.l	d0
	rts
;
popret_E_1001:
	addq	#4,sp		;pop 1 return level off stack
	move.l	#E_1001,d0	;tell dispatcher to use old gemdos
	rts
;----------------------------------------------------------------------------
find_path_DOS:
	clr	d0
	move.b	(a0),d0			;d0 = drive letter
	beq.s	.default		;default if empty ?
	cmp.b	#':',1(a0)		;drive separator 2nd ?
	bne.s	.default		;default if unseparated
	and	#$df,d0			;d0 = forced uppercase
	bra	find_char_d0_DOS
;
.default:
	bsr	MD_func_Dgetdrv
	add		#'A',d0
	bra		find_char_d0_DOS
;----------------------------------------------------------------------------
find_file_FCB:
	sub	#100,d0
	mulu	#sizeof_FCB,d0
	add.l	#meta_FCB_t,d0
	movea.l	d0,a5
	tst	FCB_dirflag(a5)
	bne.s	E_ERROR_word_sub
	move.l	FCB_DOS_p(a5),d0
	rts				;return d0->DOS  a5->FCB
;----------------------------------------------------------------------------
find_dir_FCB:
	sub	#100,d0
	mulu	#sizeof_FCB,d0
	add.l	#meta_FCB_t,d0
	movea.l	d0,a5
	tst	FCB_dirflag(a5)
	beq.s	E_ERROR_word_sub
	move.l	FCB_DOS_p(a5),d0
	rts
;----------------------------------------------------------------------------
E_ERROR_word_sub:
	move.w	#-$1,d0
	rts
;----------------------------------------------------------------------------
release_M_dta_a0:
	subq	#1,M_dta_count
put_M_dta_a0_first:
	movem.l	M_dta_prev(a0),d0/d1	;d0 = this.prev, d1 = this.next
	tst.l	d0			;is this already first ?
	beq.s	.exit			;just exit if nothing to do
	move.l	d0,a1			;a1 -> this.prev
	move.l	d1,M_dta_next(a1)	;prev.next = this.next
	beq.s	.patch_last		;skip patching next when last
	move.l	d1,a1			;a1 -> this.next
	move.l	d0,M_dta_prev(a1)	;next.prev = this.prev
	bra.s	.patch_first
;
.patch_last:
	move.l	d0,M_dta_last		;last = this.prev
.patch_first:
	move.l	M_dta_first(pc),a1	;a1 -> old_first
	move.l	a0,M_dta_prev(a1)	;old_first.prev = this
	move.l	a1,M_dta_next(a0)	;this.next = old_first
	clr.l	M_dta_prev(a0)		;this.prev = NULL
	move.l	a0,M_dta_first		;first = this
.exit:
	rts
;----------------------------------------------------------------------------
reserve_new_M_dta:
	move.l	M_dta_first(pc),a0	;a0 -> free or least used entry
	cmp	#DTA_limit,M_dta_count	;are any entries still free ?
	bhs.s	put_M_dta_a0_last	;if not, just redefine the least used.
	addq	#1,M_dta_count		;increment count when taking free ones
put_M_dta_a0_last:
	movem.l	M_dta_prev(a0),d0/d1	;d0 = this.prev, d1 = this.next
	tst.l	d1			;is this already last ?
	beq.s	.exit			;just exit if nothing to do
	move.l	d1,a1			;a1 -> this.next
	move.l	d0,M_dta_prev(a1)	;next.prev = this.prev
	beq.s	.patch_first		;skip patching prev when first
	move.l	d0,a1			;a1 -> this.prev
	move.l	d1,M_dta_next(a1)	;prev.next = this.next
	bra.s	.patch_last
;
.patch_first:
	move.l	d1,M_dta_first		;first = this.next
.patch_last:
	move.l	M_dta_last(pc),a1	;a1 -> old_last
	move.l	a0,M_dta_next(a1)	;old_last.next = this
	move.l	a1,M_dta_prev(a0)	;this.prev = old_last
	clr.l	M_dta_next(a0)		;this.next = NULL
	move.l	a0,M_dta_last		;last = this
.exit:
	rts
;----------------------------------------------------------------------------
seek_dta_a0_in_M_dta:
	move	M_dta_count(pc),d1	;any active entries ?
	beq.s	.not_found		;if not, then we can't find any
	subq	#1,d1			;d1 = adapted for dbcc
	move.l	M_dta_last(pc),a1	;this = last
.seek_loop:				;loop start
	move.l	a1,d0			;d0 = this
	cmpa.l	M_dta_DTA(a1),a0	;has this the same dta as in a0 ?
	movea.l	M_dta_prev(a1),a1	;this = this.prev
	dbeq	d1,.seek_loop		;loop back until done
	bne.s	.not_found		;go handle failure if none found
.found:
	move.l	d0,a0			;a0 -> found entry
	tst.l	d0			;flag result in sr
	rts				;return to caller
;
.not_found:
	clr.l	d0			;d0 = NULL with sr flagging
	move.l	d0,a0			;a0 = NULL pointer
	rts				;return to caller
;----------------------------------------------------------------------------
;Start of:	MD_func_Slbopen
;----------------------------------------------------------------------------
MD_func_Slbopen:
	move.l	Slbopen_fun_p(pc),a0
	jsr	(a0)
	rts
;----------------------------------------------------------------------------
;End of:	MD_func_Slbopen
;----------------------------------------------------------------------------
;Start of:	MD_func_Slbclose
;----------------------------------------------------------------------------
MD_func_Slbclose:
	move.l	Slbclose_fun_p(pc),a0
	jsr	(a0)
	rts
;----------------------------------------------------------------------------
;End of:	MD_func_Slbclose
;----------------------------------------------------------------------------
;Start of:	Slb_Pterm_sub
;----------------------------------------------------------------------------
Slb_Pterm_sub:
	tst.b	Slbopen_f
	bmi.s	SLB_dummy_rts
	clr.l	-(sp)			;push NULL
	move	#(Slbclose&$fff),-(sp)
	jsr	MD_func_Slbclose
	addq	#6,sp
SLB_dummy_rts:
	rts
;----------------------------------------------------------------------------
;End of:	Slb_Pterm_sub
;----------------------------------------------------------------------------
;Start of:	MD_func_Fsnext
;----------------------------------------------------------------------------
MD_func_Fsnext:
	sub_gemdos	Fgetdta		;d0 = active dta
	move.l	d0,a0			;a0 -> active_dta
	bsr	seek_dta_a0_in_M_dta	;was this dta defined previously ?
	ble	E_1001_sub		;if not, tell dispatcher to use old gemdos
	bsr	put_M_dta_a0_last	;ensure long M_dta life after each ref
	move.l	M_dta_DTA(a0),a5	;a5 -> dta
	lea	M_dta_path(a0),a4	;a4 -> expanded path for this dta
	move.l	M_dta_DOS(a0),a0	;a0 -> DOS
	movea.l	DOS_LDB_p(a0),a3	;a3 -> LDB
	movea.l	DOS_func_tp(a0),a6	;a6 -> DOS functions
	move.l	4*(Fsnext&$ff)(a6),d1	;d1 -> device function
	bmi	E_INVFN_sub		;MetaDos uses E_UNCMD for this
	movea.l	d1,a2			;a2 -> device function
	move.l	(sp)+,reent_retadr	;pull reent_retadr -> retadr
	jsr	(a2)			;call device function
	move.l	reent_retadr(pc),-(sp)	;push reent_retadr as retadr
	tst.l	d0
	beq.s	.exit_fsnext
.func_failed:
	move.l	d0,-(sp)		;push error code
	sub_gemdos	Fgetdta		;d0 = active dta
	move.l	d0,a0			;a0 -> active_dta
	bsr	seek_dta_a0_in_M_dta	;was this dta defined previously ?
	ble.s	.done_release
	bsr	release_M_dta_a0	;release found M_dta entry
.done_release:
	move.l	(sp)+,d0		;pull error code to d0
.exit_fsnext:
	rts
;----------------------------------------------------------------------------
;End of:	MD_func_Fsnext
;----------------------------------------------------------------------------
;Start of:	MD_func_Fsfirst
;----------------------------------------------------------------------------
MD_func_Fsfirst:
	movea.l	6(sp),a0
	bsr	find_path_DOS		;a0 -> DOS
	bmi	release_non_M_dta
	move.l	a0,current_DOS
	movea.l	6(sp),a1
	bsr	expand_path
	bmi.s	release_PTHNF_M_dta
;
	sub_gemdos	Fgetdta		;d0 = active dta
	move.l		d0,current_DTA	;current_DTA = active dta
	move.l	d0,a0			;a0 -> active_dta
	bsr	seek_dta_a0_in_M_dta	;was this dta defined previously ?
	bgt.s	.update_M_dta		;if it was, just update it now
.dta_not_found:
	bsr	reserve_new_M_dta	;else get a new entry
	bra.s	.update_content		;go update the contents of the M_dta
;
.update_M_dta:
	bsr	put_M_dta_a0_last	;ensure long M_dta life after each ref
.update_content:
	move.l	current_DTA(pc),M_dta_DTA(a0)
	move.l	current_DOS(pc),M_dta_DOS(a0)
	lea	expanded_path(pc),a1
	lea	M_dta_path(a0),a0
	move	#PATH_limit-2,d0
.copy_path_loop:
	move.b	(a1)+,(a0)+
	dbeq	d0,.copy_path_loop
	clr.b	(a0)
;
	sub_gemdos	Fgetdta			;d0 = active dta
	movea.l		current_DTA(pc),a5	;a5 -> dta
	lea		expanded_path(pc),a4	;a4 -> expanded pathname
	movea.l		current_DOS(pc),a0
	movea.l		DOS_LDB_p(a0),a3	;a3 -> logical device block
;
	movea.l	DOS_func_tp(a0),a6			;a6 -> DOS functions
	move.l	4*(Fsfirst&$ff)(a6),d1	;d1 -> device function
	bmi.s	E_INVFN_sub			;MetaDos uses E_UNCMD for this
	movea.l	d1,a2				;a2 -> device function
;
	move.l	(sp)+,reent_retadr	;pull reent_retadr -> retadr
	jsr	(a2)			;call device function
	move.l	reent_retadr(pc),-(sp)	;push reent_retadr as retadr
	tst.l	d0
	bmi.s	release_M_dta_return_d0
.func_OK:
	clr.l	d0			;flag successful result
	rts
;
release_PTHNF_M_dta:
	moveq	#E_PTHNF,d0
	bra.s	release_M_dta_return_d0
;
release_non_M_dta:
	move.l	#E_1001,d0
release_M_dta_return_d0:
	move.l	d0,-(sp)
	sub_gemdos	Fgetdta		;d0 = active dta
	move.l	d0,current_DTA		;current_DTA = active dta
	move.l	d0,a0			;a0 -> active_dta
	bsr	seek_dta_a0_in_M_dta	;was this dta defined previously ?
	ble.s	.exit			;if not, exit
	bsr	release_M_dta_a0	;release found M_dta entry
.exit:
	move.l	(sp)+,d0
	rts
;----------------------------------------------------------------------------
;End of:	MD_func_Fsfirst
;----------------------------------------------------------------------------
E_1001_sub:
	move.l	#E_1001,d0		;tell dispatcher to use old gemdos
	rts
;----------------------------------------------------------------------------
E_BADRQ_sub:
	moveq	#E_BADRQ,d0
	rts
;----------------------------------------------------------------------------
E_INVFN_sub:
	moveq	#E_INVFN,d0
	rts
;----------------------------------------------------------------------------
E_UNDEV_sub:
	moveq	#E_UNDEV,d0
	rts
;----------------------------------------------------------------------------
E_UNCMD_sub:
	moveq	#E_UNCMD,d0
	rts
;----------------------------------------------------------------------------
E_IHNDL_sub:
	moveq	#E_IHNDL,d0
	rts
;----------------------------------------------------------------------------
E_PTHNF_sub:
	moveq	#E_PTHNF,d0
	rts
;----------------------------------------------------------------------------
E_ACCDN_sub:
	moveq	#E_ACCDN,d0
	rts
;----------------------------------------------------------------------------
E_INVFN_drop_FCB_a5:
	move.l	a5,a0
	moveq	#E_INVFN,d0
release_MetaFCB_a0:
	move.l	#-1,FCB_DOS_p(a0)
	IFNE	DEBUG_FCB_count
	subq	#1,FCB_count
	ENDC
	rts
;----------------------------------------------------------------------------
expand_path:
	movem.l	a0-a2,-(sp)
	lea	expanded_path(pc),a2
	btst	#1,DOS_FSmode_bits+3(a0)	;0 => expand paths
	beq.s	.do_expand_1
.no_expand_1:
	move.l	a1,d0			;arg2 == NULL ?
	bne	.insertions_done
.do_expand_use_old:
	lea	DOS_path(a0),a1		;a1 -> old path
	bra	.insertions_done
;
.do_expand_1:
	move.l	a1,d0			;arg2 == NULL ?
	beq.s	.fix_default_drive
	move.b	(a1),d0			;arg2[0] == drive_letter/terminator ?
	beq.s	.fix_default_drive
	cmpi.b	#':',1(a1)		;arg2[1] == drive separator ?
	bne.s	.fix_default_drive
	addq	#2,a1			;arg2 -> past drive separator
	bra.s	.fix_drive_d0
;
.fix_default_drive:
	move.w	4(a0),d0		;d0 = uppercase gemdos drive letter
	add.b	#('a'-'A'),d0		;d0 = lowercase gemdos drive letter
.fix_drive_d0:
	move.b	d0,(a2)+		;store gemdos drive letter
	move.b	#':',(a2)+		;store colon as separator
	move.l	a1,d0			;arg2 == NULL ?
	beq.s	.do_expand_use_old
	move.b	(a1),d0			;arg2[0] == path_char/terminator ?
	beq.s	.do_expand_use_old
	cmpi.b	#'\',d0			;arg2 == absolute path ?
	beq	.fix_absolute
.fix_relative:
	move.l	a0,-(sp)		;push a0
	lea	DOS_path(a0),a0		;a0 -> old path
.copy_loop_1:
	move.b	(a0)+,(a2)+		;copy old path
	bne	.copy_loop_1
	movea.l	(sp)+,a0		;pull a0
;
	subq.l	#1,a2			;a2 -> terminator of old path copy
;
	tst.b	(a1)			;char to add == terminator ?
	beq.s	.def_path_done		;then leave all as-is
	cmpi.b	#'\',-$1(a2)		;final char == path separator ?
	beq.s	.def_path_done		;then leave it as-is
	move.b	#'\',(a2)+		;store extra path separator ?
.def_path_done:
.fix_subpath_lp:
	cmp.b	#'\',(a1)		;duplicate separator
	beq.s	.ignore_1_char
	cmp.b	#'.',(a1)		;dot_xxx path ?
	bne.s	.take_path_char
	tst.b	1(a1)			;final dot path ?
	beq.s	.ignore_1_char
	cmp.b	#'\',1(a1)		;dot_slash path ?
	beq.s	.ignore_2_char
	cmp.b	#'.',1(a1)		;dot_dot_xxx ?
	bne.s	.take_path_char		;if not, weird !!!
	tst.b	2(a1)			;final dot_dot ?
	beq.s	.back_path
	cmp.b	#'\',2(a1)		;dot_dot_slash ?
	bne.s	.take_path_char		;if not, weird !!!
.back_path:
	move.b	-(a2),d0		;d0 = dest char at backed pos
	cmp.b	#'\',d0			;path separator ?
	beq.s	.back_path_lp
	addq	#1,a2			;unback dest ptr
	bra.s	.done_back
;
.back_path_lp:
	move.b	-(a2),d0		;d0 = dest char at backed pos
	cmp.b	#':',d0			;drive separator ?
	bne.s	.back_next
	addq	#1,a2			;unback dest ptr
	move.b	#'\',d0			;root path separator
	bra.s	.take_d0_char		;go store it
;
.back_next:
	cmp.b	#'\',d0			;path separator ?
	bne.s	.back_path_lp		;loop until separated
	addq	#1,a2			;unback dest ptr
.done_back:
	tst.b	2(a1)			;dot_dot_term or dot_dot_slash ?
	beq.s	.ignore_2_char
.ignore_3_char:
	addq	#1,a1			;pass 1 source char
.ignore_2_char:
	addq	#1,a1			;pass 1 source char
.ignore_1_char:
	addq	#1,a1			;pass 1 source char
	bra.s	.fix_subpath_lp		;loop for another subpath/name
;
.fix_absolute:
.take_path_char:
	move.b	(a1)+,d0		;get source char
.take_d0_char:
	move.b	d0,(a2)+		;store dest char
	beq.s	.expanded
	cmp.b	#'\',d0			;path separator ?
	bne.s	.take_path_char		;else take next char without further tests ?
	bra.s	.fix_subpath_lp
;
.expanded:
	btst	#0,DOS_FSmode_bits+3(a0)	;0 => forced case
	bne.s	.keep_case_1
	lea	expanded_path(pc),a2
.force_case_loop_1:
	move.b	(a2),d0
	cmp.b	#'a',d0
	blt.s	.char_cased_1
	cmp.b	#'z',d0
	bgt.s	.char_cased_1
	sub.b	#'a'-'A',d0
.char_cased_1:
	move.b	d0,(a2)+
	bne.s	.force_case_loop_1
.keep_case_1:
.find_last_slash:
	cmpi.b	#'\',-(a2)
	bne.s	.find_last_slash
	tst.b	1(a2)
	bne.s	.unwild_loop
	cmp.b	#':',-1(a2)
	beq.s	.unwild_ok
	clr.b	(a2)
	bra.s	.find_last_slash
;
.unwild_loop:
	move.b	-(a2),d0
	cmp.b	#':',d0			;back at drive spec ?
	beq.s	.unwild_ok
	cmp.b	#'?',d0
	beq.s	.unwild_err
	cmp.b	#'*',d0
	bne.s	.unwild_loop
.unwild_err:
	moveq	#-1,d0
	movem.l	(sp)+,a0-a2
	rts
;
.unwild_ok:
	clr.l	d0
	movem.l	(sp)+,a0-a2
	rts
;
.insertions_done:
.copy_loop_2:
	move.b	(a1)+,(a2)+
	bne.s	.copy_loop_2
	btst	#0,DOS_FSmode_bits+3(a0)	;0 => forced char case
	bne.s	keep_case_2
	lea	expanded_path(pc),a2
.force_case_loop_2:
	move.b	(a2),d0
	cmp.b	#'a',d0
	blt.s	.char_cased_2
	cmp.b	#'z',d0
	bgt.s	.char_cased_2
	sub.b	#'a'-'A',d0
.char_cased_2:
	move.b	d0,(a2)+
	bne.s	.force_case_loop_2
keep_case_2:
	clr.l	d0
	movem.l	(sp)+,a0-a2
	rts
;----------------------------------------------------------------------------
MD_func_Dsetdrv:
	move		6(sp),d0
	move.l		meta_drvbits(pc),d1
	btst		d0,d1
	bne.s		.set_meta_drive
.non_meta_drive:
	sub_gemdos	Dsetdrv,d0
	move.l		d0,gemdos_drvbits
	bra.s		.finish_Dsetdrv
;-------
.set_meta_drive:
	move.l		gemdos_drvbits(pc),d0
.finish_Dsetdrv:
	or.l		meta_drvbits(pc),d0
	movea.l		loc_currbp_p_p(pc),a0
	movea.l		(a0),a0
	move		bp_drive_index,d1
	move.b		7(sp),0(a0,d1.w)
	rts
;----------------------------------------------------------------------------
MD_func_Dgetdrv:
	movea.l		loc_currbp_p_p(pc),a0
	movea.l		(a0),a0
	move		bp_drive_index(pc),d1
	clr.l		d0
	move.b		0(a0,d1),d0
	bne.s		.exit
	pea		0(a0,d1)
	sub_gemdos	Dgetdrv
	move.l		(sp)+,a0
	move.b		d0,(a0)
.exit:
	rts
;----------------------------------------------------------------------------
MD_func_Dgetcwd:
	move	12(sp),d0
	bra.s	get_lim_path
;
MD_func_Dgetpath:
	move	#128,d0
get_lim_path:
	move	d0,d6			;d6 = max string length
	move	10(sp),d0		;d0 = drive_number+1
	subq	#1,d0			;d0 = drive_number
	bge.s	.use_drive
	bsr	MD_func_Dgetdrv
.use_drive:
	move.l	meta_drvbits(pc),d1
	btst	d0,d1
	beq	E_1001_sub		;use old gemdos for non-meta drives
	add	#'A',d0			;convert drive code to drive letter
	bsr	find_char_d0_DOS	;find DOS driver
	bmi	E_1001_sub		;try old gemdos on failing DOS driver
	subq	#1,d6			;prep char buffer length for dbra
	ble.s	E_RANGE_sub		;return E_RANGE on bad length
	movea.l	6(sp),a1		;a1 -> buffer for path
	lea	DOS_path(a0),a0		;a0 -> path in DOS
	tst.b	(a0)
	beq.s	.copy_loop		;go copy path if empty  :-)
	cmp.b	#':',1(a0)		;check for drive spec (error)
	bne.s	.copy_loop		;go copy absolute pure path
	addq	#2,a0			;skip drive spec when present
.copy_loop:
	move.b	(a0)+,(a1)+
	dbeq	d6,.copy_loop
	moveq	#E_OK,d0
	rts
;----------------------------------------------------------------------------
E_DRIVE_sub:
	moveq	#E_DRIVE,d0
	rts
;----------------------------------------------------------------------------
E_RANGE_sub:
	moveq	#E_RANGE,d0
	rts
;----------------------------------------------------------------------------
MD_func_Dsetpath:
	movea.l	6(sp),a0		;a0 -> arg path string
	bsr	find_path_DOS		;a0 -> DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	move.l	a0,current_DOS
	movea.l	6(sp),a0		;a0 -> arg path string
.loop_1:
	move.b	(a0)+,d0		;string end ?
	beq.s	.un_wild
	cmpi.b	#'*',d0			;'*' wildcard ?
	beq	E_PTHNF_sub
	cmpi.b	#'?',d0			;'?' wildcard ?
	bne	.loop_1
	bra	E_PTHNF_sub
;
.un_wild:
	move.l	current_DOS(pc),a0
	movea.l	6(sp),a1		;a1 -> arg path string
	bsr	expand_path
	bmi	E_PTHNF_sub
;
	movea.l	DOS_func_tp(a0),a6
	move.l	4*(Dsetpath&$ff)(a6),d0	;d0 -> DOS function
	ble.s	.done_DOS_call		;skip call if unimplemented in DOS
	movea.l	d0,a2			;a2 -> DOS function
;
	lea	expanded_path(pc),a4
	movea.l	DOS_LDB_p(a0),a3
	move.l	(sp)+,reent_retadr
	jsr	(a2)			;call DOS Dsetpath
	move.l	reent_retadr(pc),-(sp)
	tst.l	d0
	bmi.s	.exit			;exit on error from DOS
	movea.l	current_DOS(pc),a0
.done_DOS_call:
	lea	DOS_path(a0),a0
	lea	expanded_path+2(pc),a1
.copy_loop:
	move.b	(a1)+,(a0)+
	bne.s	.copy_loop
	clr.l	d0
.exit:
	rts
;----------------------------------------------------------------------------
MD_func_Fcreate_Fopen:
	movea.l	6(sp),a0
	bsr	find_path_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	movea.l	6(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
	bsr	defpop_FCB_a5		;a5 -> new FCB
	move.w	4(sp),d1
	asl.w	#2,d1
	movea.l	DOS_func_tp(a0),a6
	move.l	0(a6,d1.w),d0		;d0 -> DOS function
	ble	E_INVFN_drop_FCB_a5	;invalid pointer => E_INVFN
	movea.l	d0,a2			;a2 -> DOS function
	move.l	a5,reent_extra		;reent_extra -> FCB
	lea	expanded_path(pc),a4	;a4 -> expanded path
	movea.l	DOS_LDB_p(a0),a3
	move.l	a0,FCB_DOS_p(a5)	;link FCB to DOS driver
	IFNE	DEBUG_FCB_count
	addq	#1,FCB_count
	ENDC
	movea.l	loc_currbp_p_p(pc),a0	;a0 -> -> active basepage
	move.l	(a0),FCB_owner(a5)
	clr.w	FCB_dirflag(a5)
	move.l	a4,a0			;a0 -> expanded path
	lea	FCB_path(a5),a1		;a1 -> path buffer in FCB
	move	#PATH_limit-2,d0	;d0 = PATH_limit-2 for dbeq
.pathcopy_lp:
	move.b	(a0)+,(a1)+		;copy path string
	dbeq	d0,.pathcopy_lp		;loop until terminator, or 127 bytes
	clr.b	(a1)			;force terminator at string end
	move.l	(sp)+,reent_retadr
	jsr	(a2)			;call DOS function
	move.l	reent_retadr(pc),-(sp)
	movea.l	reent_extra(pc),a0	;a0 = reent_extra -> FCB
	tst.l	d0
	bmi	release_MetaFCB_a0
	move.l	a0,d0
	sub.l	#meta_FCB_t,d0
	divu	#sizeof_FCB,d0
	add.l	#100,d0
.exit:
	rts
;----------------------------------------------------------------------------
MD_func_Fclose:
	move.w	6(sp),d0
	bsr	tstpop_meta_fhd
	bsr	find_file_FCB
	bmi	E_IHNDL_sub
	move.l	a5,reent_extra		;reent_extra -> FCB
	movea.l	d0,a0
	movea.l	DOS_func_tp(a0),a6
	move.w	4(sp),d1
	asl.w	#2,d1
	move.l	0(a6,d1.w),d0		;d0 -> DOS function
	ble	E_INVFN_drop_FCB_a5	;invalid pointer => E_INVFN
	movea.l	d0,a2			;a2 -> DOS function
	movea.l	DOS_LDB_p(a0),a3
	move.l	(sp)+,reent_retadr
	jsr	(a2)			;call DOS function
	move.l	reent_retadr(pc),-(sp)
	movea.l	reent_extra(pc),a1	;a1 = reent_extra -> FCB
	move.l	#-1,FCB_DOS_p(a1)	;release FCB from DOS usage
	IFNE	DEBUG_FCB_count
	subq	#1,FCB_count
	ENDC
	clr.l	d0
.exit:
	rts
;----------------------------------------------------------------------------
MD_func_Fforce:
	move.w	8(sp),d0
	bsr	tstpop_meta_fhd
	bsr	find_file_FCB
	bmi	E_IHNDL_sub
	move.l	a5,reent_extra		;reent_extra -> FCB
	movea.l	d0,a0
	movea.l	DOS_func_tp(a0),a6
	move.w	4(sp),d1
	asl.w	#2,d1
	move.l	0(a6,d1.w),d0		;d0 -> DOS function
	bmi	E_1001_sub		;if none, leave it to older DOS code
	movea.l	d0,a2			;a2 -> DOS function
	movea.l	DOS_LDB_p(a0),a3
	move.l	(sp)+,reent_retadr
	jsr	(a2)			;call DOS function
	move.l	reent_retadr(pc),-(sp)
	movea.l	reent_extra(pc),a1	;a1 = reent_extra -> FCB
	rts
;----------------------------------------------------------------------------
MD_func_Dfree:				;Dfree(DISKINFO *buf_p, int16 drivep1)
	move.w	10(sp),d0
	subq	#1,d0
	bhs.s	.got_drv
	bsr	MD_func_Dgetdrv		;d0 = drive number
.got_drv:
	add.w	#'A',d0
	bsr	find_char_d0_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	suba.l	a1,a1			;a1 = NULL path
	bsr	expand_path
	bra	MD_func_without_a5
;----------------------------------------------------------------------------
MD_func_Frename:
	movea.l	8(sp),a0
	bsr	find_path_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	move.l	12(sp),a0
	bsr	find_path_DOS
	bmi	E_ACCDN_sub
	movea.l	12(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
	lea	extra_path(pc),a2
	lea	expanded_path(pc),a1
	move.l	#PATH_limit-2,d0
.loop:
	move.b	(a1)+,(a2)+
	dbeq	d0,.loop
	clr.b	(a2)+
	movea.l	8(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
	lea	extra_path(pc),a5
	bra.s	MD_func_without_a5
;----------------------------------------------------------------------------
MD_func_Flink:
MD_func_Fsymlink:
	movea.l	10(sp),a0
	bsr	find_path_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	movea.l	10(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
	bra.s	MD_func_without_a5
;----------------------------------------------------------------------------
MD_func_Freadlink:
	movea.l	12(sp),a0
	bsr	find_path_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	movea.l	12(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
	bra.s	MD_func_without_a5
;----------------------------------------------------------------------------
MD_func_DF_diverse:
	movea.l	6(sp),a0
	bsr	find_path_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	movea.l	6(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
	bra.s	MD_func_without_a5
;----------------------------------------------------------------------------
	move.w	8(sp),d0
	bsr	tstpop_meta_fhd
	bra.s	t_b8e
;----------------------------------------------------------------------------
MD_func_Fseek_Fdatime:
	move.w	10(sp),d0
	bsr	tstpop_meta_fhd
	bra.s	t_b8e
;----------------------------------------------------------------------------
MD_func_Fread_Fwrite:
	move.w	6(sp),d0
	bsr	tstpop_meta_fhd
t_b8e:
	bsr	find_file_FCB		;a5 -> FCB,  d0 -> DOS
	bmi	E_IHNDL_sub
	movea.l	d0,a0			;a0 -> DOS
MD_func_without_a5:
	movea.l	DOS_func_tp(a0),a6	;a6 -> DOS vectors
	move.w	4(sp),d1
	asl.w	#2,d1
	move.l	0(a6,d1),d0		;d0 -> DOS function
	ble	E_INVFN_sub		;invalid pointer => E_INVFN
	movea.l	d0,a2			;a2 -> DOS function
	lea	expanded_path(pc),a4	;a4 -> path
	movea.l	DOS_LDB_p(a0),a3	;a3 -> LDB
	move.l	(sp)+,reent_retadr
	jsr	(a2)			;Call DOS function
	move.l	reent_retadr(pc),-(sp)
.exit:
	rts
;----------------------------------------------------------------------------
MD_func_Dopendir:
	movea.l	6(sp),a0
	bsr	find_path_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	movea.l	6(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
	bsr	defpop_dir_FCB_a5	;Find a free FCB
	move.w	4(sp),d1		;d1 = Dopendir_opcode
	movea.l	DOS_func_tp(a0),a6
	cmpi.l	#'MAGI',-$10(a6)
	bne	E_INVFN_drop_FCB_a5
	cmpi.l	#'CMET',-$c(a6)
	bne	E_INVFN_drop_FCB_a5
	cmp.w	-$6(a6),d1		;cmp Max_opcode,Dopendir_opcode
	bgt	E_INVFN_drop_FCB_a5
	asl.w	#2,d1
	move.l	0(a6,d1.w),d0		;d0 -> DOS Dopendir function
	ble	E_INVFN_drop_FCB_a5	;invalid pointer => E_INVFN
	movea.l	d0,a2			;a2 -> DOS Dopendir function
	move.l	a5,reent_extra		;reent_extra -> FCB
	lea	expanded_path(pc),a4
	movea.l	DOS_LDB_p(a0),a3
	move.l	a0,FCB_DOS_p(a5)	;link FCB to DOS driver
	IFNE	DEBUG_FCB_count
	addq	#1,FCB_count
	ENDC
	movea.l	loc_currbp_p_p,a0	;a0 -> -> active basepage
	move.l	(a0),FCB_owner(a5)
	move.w	#1,FCB_dirflag(a5)
	move.l	(sp)+,reent_retadr
	jsr	(a2)			;call DOS Dopendir function
	move.l	reent_retadr(pc),-(sp)
	move.l	reent_extra(pc),a0	;a0 = reent_extra -> FCB
	tst.l	d0
	bmi	release_MetaFCB_a0
	move.l	a0,d0
	sub.l	#meta_FCB_t,d0
	divu	#sizeof_FCB,d0
	add.l	#100,d0
.exit:
	rts
;----------------------------------------------------------------------------
MD_func_Dclosedir:
	move.l	6(sp),d0
	bsr	tstpop_meta_dhd
	bsr	find_dir_FCB
	bmi	E_IHNDL_sub
	move.l	a5,reent_extra		;reent_extra -> FCB
	movea.l	d0,a0
	move.w	4(sp),d1
	movea.l	DOS_func_tp(a0),a6
	cmpi.l	#'MAGI',-$10(a6)
	bne	E_INVFN_drop_FCB_a5
	cmpi.l	#'CMET',-$c(a6)
	bne	E_INVFN_drop_FCB_a5
	cmp.w	-$6(a6),d1
	bgt	E_INVFN_drop_FCB_a5
	asl.w	#2,d1
	move.l	0(a6,d1.w),d0		;d0 -> Dclosedir function
	ble	E_INVFN_drop_FCB_a5	;invalid pointer => E_INVFN
	movea.l	d0,a2			;a2 -> Dclosedir function
	movea.l	DOS_LDB_p(a0),a3
	move.l	(sp)+,reent_retadr
	jsr	(a2)
	move.l	reent_retadr(pc),-(sp)
	movea.l	reent_extra(pc),a1	;a1 = reent_extra -> FCB
	move.l	#-1,FCB_DOS_p(a1)	;release FCB from DOS usage
	IFNE	DEBUG_FCB_count
	subq	#1,FCB_count
	ENDC
	clr.l	d0
.exit:
	rts
;----------------------------------------------------------------------------
MD_func_Fcntl:			;Fcntl(int16 fh, void *arg_p, int16 cmd)
	move.w	6(sp),d0
	bsr	tstpop_meta_fhd
	bsr	find_file_FCB		;d0 -> DOS  a5 -> FCB,  unless d0 < 0
	bmi	E_IHNDL_sub
	movea.l	d0,a0			;a0 -> DOS
	move.w	4(sp),d1		;d1 = Fcntl opcode
	movea.l	DOS_func_tp(a0),a6
	cmpi.l	#'MAGI',-$10(a6)
	bne.s	.sim_Fcntl
	cmpi.l	#'CMET',-$c(a6)
	bne.s	.sim_Fcntl
	cmp.w	-$6(a6),d1
	bgt.s	.sim_Fcntl
	asl.w	#2,d1
	move.l	0(a6,d1.w),d0		;d0 -> DOS function
	ble.s	.sim_Fcntl		;invalid pointer => E_INVFN
	movea.l	d0,a2			;a2 -> DOS function
	lea	FCB_path(a5),a4		;a4 -> expanded path
	movea.l	DOS_LDB_p(a0),a3	;a3 -> LDB
	move.l	(sp)+,reent_retadr	;protect return address
	jsr	(a2)			;call DOS function
	move.l	reent_retadr(pc),-(sp)	;restore return address
	cmp.l	#E_INVFN,d0
	bne.s	.exit
.sim_Fcntl:
	move	12(sp),d0
	cmp	#FIONREAD,d0
	beq.s	.got_FION_RW
	cmp	#FIONWRITE,d0
	bne.s	.not_FION_RW
.got_FION_RW:
	move.l	8(sp),a0		;a0 = arg_p
	move.l	#8192,(a0)		;arg_p[0] = 8192L
	moveq	#E_OK,d0
	rts				;exit to caller
;-------
.not_FION_RW:
	cmp	#FSTAT,d0
	bne.s	.not_FSTAT
	move.w	6(sp),d0
	bsr	find_file_FCB		;d0 -> DOS  a5 -> FCB
;
	move.l	8(sp),-(sp)		;push -> XATTR struct
	pea	FCB_path(a5)		;push -> expanded path
	clr	-(sp)			;push zero flag
	move	#Fxattr&$fff,-(sp)	;push Fxattr opcode
	jsr	MD_func_Fxattr		;use Fxattr routine
	add	#12,sp			;clean stack
	rts				;exit to caller
;-------
.not_FSTAT:
.sim_failed:
	moveq	#E_INVFN,d0
.exit:
	rts				;exit to caller
;----------------------------------------------------------------------------
MD_func_Fxattr:				;Fxattr(int16 flag,char *pn,XATTR *xap)
	movea.l	8(sp),a0		;a0 = pn
	bsr	find_path_DOS		;a0 -> DOS, unless flagged MI
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	movea.l	8(sp),a1		;a1 = pn
	bsr	expand_path
	bmi	E_PTHNF_sub
	move.w	4(sp),d1		;d1 = Fxattr opcode
	movea.l	DOS_func_tp(a0),a6
	cmpi.l	#'MAGI',-$10(a6)
	bne.s	.sim_Fxattr
	cmpi.l	#'CMET',-$c(a6)
	bne.s	.sim_Fxattr
	cmp.w	-$6(a6),d1
	bgt.s	.sim_Fxattr		;undefined function => simulation
	asl.w	#2,d1
	move.l	0(a6,d1.w),d0		;d0 -> DOS function
	ble.s	.sim_Fxattr		;invalid pointer => simulation
	movea.l	d0,a2			;a2 -> DOS function
	lea	expanded_path(pc),a4	;a4 -> expanded path
	movea.l	DOS_LDB_p(a0),a3	;a3 -> LDB
	move.l	(sp)+,reent_retadr	;protect return address
	jsr	(a2)			;call DOS function
	move.l	reent_retadr(pc),-(sp)	;restore return address
	cmp.l	#E_INVFN,d0
	bne	.exit
.sim_Fxattr:
	move.l	12(sp),a5		;a5 = xap
	move.l	a5,a0			;a0 = xap
	moveq	#sizeof_XATTR/2-1,d0
.clear_lp:
	clr	(a0)+			;clear each word of XATTR struct
	dbra	d0,.clear_lp
	movea.l	8(sp),a0		;a0 = pn
	bsr	find_path_DOS		;a0 -> DOS, unless flagged MI
	movea.l	8(sp),a1		;a1 = pn
	bsr	expand_path
	lea	expanded_path(pc),a4	;a4 -> expanded path
	clr	d0
	move.b	(a4),d0
	cmp	#'a',d0
	blo.s	.keepcase
	cmp	#'z',d0
	bhi.s	.keepcase
	sub	#('a'-'A'),d0
.keepcase:
	sub	#'A',d0
	move	d0,XATTR_dev(a5)
;
	sub_gemdos	Fgetdta
	move.l		d0,-(sp)
	lea		-dta_size(sp),sp
;-------
	sub_gemdos.i	Fsetdta,sp
	lea		dta_size+8(sp),a0	;a0 = pn
	sub_gemdos.i	Fsfirst,(a0),#$3F
	move.l		d0,d6
	sub_gemdos.i	Fsetdta,dta_size(sp)
;
	clr	d3
	move.b	dta_fattr(sp),d3
	move	#S_IFDIR|$1FF,d2
	btst	#4,d3
	bne.s	.keep_mode
	move	#S_IFREG|$1FF,d2
.keep_mode:
	move.l	dta_ftime(sp),d4
	move.l	dta_fsize(sp),d5
	move	d2,XATTR_mode(a5)
	move	d3,XATTR_attr(a5)
	move.l	d4,XATTR_mtime(a5)
	move.l	d4,XATTR_atime(a5)
	move.l	d4,XATTR_ctime(a5)
	move.l	d5,XATTR_size(a5)
	move.l	16(sp),XATTR_index(a5)
;-------
	lea	dta_size+4(sp),sp
	tst.l	d6
	bmi.s	.sim_failed
	moveq	#E_OK,d0
	rts
;
.sim_failed:
	moveq	#E_INVFN,d0
.exit:
	rts				;exit to caller
;----------------------------------------------------------------------------
MD_func_Drewinddir:
	move.l	6(sp),d0
	bsr	tstpop_meta_dhd
	bra.s	t_cfe
;----------------------------------------------------------------------------
MD_func_Dreaddir_Dxreaddir:
	move.l	8(sp),d0
	bsr	tstpop_meta_dhd
t_cfe:
	bsr	find_dir_FCB
	bmi	E_IHNDL_sub
	movea.l	d0,a0
	bra.s	MD_nu_func_without_a5
;----------------------------------------------------------------------------
MD_func_Dcntl:
	movea.l	8(sp),a0
	bsr	find_path_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	movea.l	8(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
MD_nu_func_without_a5:
	move.w	4(sp),d1
	movea.l	DOS_func_tp(a0),a6
	cmpi.l	#'MAGI',-$10(a6)
	bne	E_INVFN_sub
	cmpi.l	#'CMET',-$c(a6)
	bne	E_INVFN_sub
	cmp.w	-$6(a6),d1
	bgt	E_INVFN_sub
	asl.w	#2,d1
	move.l	0(a6,d1.w),d0		;d0 -> DOS function
	ble	E_INVFN_sub		;invalid pointer => E_INVFN
	movea.l	d0,a2			;a2 -> DOS function
	lea	expanded_path(pc),a4	;a4 -> expanded path
	movea.l	DOS_LDB_p(a0),a3	;a3 -> LDB
	move.l	(sp)+,reent_retadr	;protect return address
	jsr	(a2)			;call DOS function
	move.l	reent_retadr(pc),-(sp)	;restore return address
.exit:
	rts				;exit to caller
;----------------------------------------------------------------------------
MD_func_Dpathconf_D_x_label:
	movea.l	6(sp),a0
	bsr	find_path_DOS
	bmi	E_1001_sub		;tell dispatcher to use old gemdos
	movea.l	6(sp),a1
	bsr	expand_path
	bmi	E_PTHNF_sub
	bra	MD_nu_func_without_a5
;----------------------------------------------------------------------------
init_sub_1:
	bsr.s	init_sub_2
	bpl.s	.t_dae
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1			 ;cconws
	addq.w	#6,sp
	lea	d_220e(pc),a0
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1			 ;cconws
	addq.w	#6,sp
	move.l	(sp)+,d0
	bra.s	.t_dd4
;
.t_dae:
	lea	b_6241(pc),a3
	cmpi.b	#'*',(a3)
	bne.s	.t_dc0
	bsr	try_boot_module
	bra.s	.t_dcc
;
.t_dc0:
	movem.l	d7,-(sp)
	bsr	t_1380
	movem.l	(sp)+,d7
.t_dcc:
	bsr.s	t_df8
	bmi.s	.t_dd2
	bra	.t_dae
;
.t_dd2:
	moveq	#0,d0
.t_dd4:
	rts
;----------------------------------------------------------------------------
init_sub_2:
	move.w	#0,-(sp)
	pea	boot_bdconfig_sys_s(pc)
	move.w	#$3d,-(sp)
	trap	#1			 ;fopen
	addq.w	#8,sp
	tst.w	d0
	bmi.s	t_df4
	move.w	d0,d7
	bsr.s	t_df8
	clr.l	d0
	bra.s	t_df6
;----------------------------------------------------------------------------
t_df4:
	moveq	#-1,d0
t_df6:
	rts
;----------------------------------------------------------------------------
t_df8:
	lea	b_6241(pc),a3
	move.l	a3,-(sp)
	move.l	#1,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1			 ;fread
	adda.w	#12,sp
	tst.l	d0
	beq	t_eac
	cmpi.b	#$3b,(a3)
	beq.s	t_e88
	cmpi.b	#10,(a3)
	beq.s	t_df8
	cmpi.b	#13,(a3)
	beq.s	t_df8
	cmpi.b	#$20,(a3)
	beq.s	t_df8
	cmpi.b	#9,(a3)
	beq.s	t_df8
t_e36:
	addq.l	#1,a3
	move.l	a3,-(sp)
	move.l	#1,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1			 ;fread
	lea	12(sp),sp
	tst.l	d0
	beq.s	t_eb0
	cmpi.b	#10,(a3)
	beq.s	t_eb0
	cmpi.b	#$3b,(a3)
	bne.s	t_e36
	move.b	#10,(a3)
t_e60:
	movea.l	a3,a2
	addq.l	#1,a2
	move.l	a2,-(sp)
	move.l	a2,-(sp)
	move.l	#1,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1			 ;fread
	adda.w	#12,sp
	movea.l	(sp)+,a2
	tst.l	d0
	beq.s	t_eb0
	cmpi.b	#10,(a2)
	beq.s	t_eb0
	bra	t_e60
;----------------------------------------------------------------------------
t_e88:
	move.l	a3,-(sp)
	move.l	#1,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1			 ;fread
	adda.w	#12,sp
	tst.l	d0
	beq	t_df8
	cmpi.b	#10,(a3)
	beq	t_df8
	bra	t_e88
;----------------------------------------------------------------------------
t_eac:
	move.w	#-$1,d0
t_eb0:
	move.w	d0,d0
	rts
;----------------------------------------------------------------------------
try_boot_module:
	lea	b_6241(pc),a3
	move.b	(a3)+,d0
	lsl.l	#8,d0
	move.b	(a3),d0
	lsl.l	#8,d0
	move.b	1(a3),d0
	lsl.l	#8,d0
	move.b	2(a3),d0
	cmp.l	#'*BOS',d0
	beq.s	.have_BOS_command
	cmp.l	#'*DOS',d0
	beq.s	.have_DOS_command
	cmp.l	#'*SLB',d0
	beq.s	.have_SLB_command
	rts
;-------
.have_BOS_command:
	bsr	init_tst_module
	tst.l	d0
	bmi.s	show_module_error
	bsr	boot_BOS
	rts
;-------
.have_DOS_command:
	bsr	init_tst_module
	tst.l	d0
	bmi.s	show_module_error
	bsr	boot_DOS
	rts
;-------
.have_SLB_command:
	bsr	init_tst_module
	tst.l	d0
	bmi.s	show_module_error
	bsr.s	boot_SLB
	rts
;-------
show_module_error:
	move.l	d0,-(sp)
	gemdos	Cconws,(A0)
	move.l	(sp)+,d0
	lea	file_not_found_error_s(pc),a0
	cmp.l	#-1,d0
	bne.s	.check_nomem_error
	lea	bad_file_error_s(pc),a0
	bra.s	.show_string_a0
;-------
.check_nomem_error:
	cmp.l	#-2,d0
	bne.s	.show_string_a0
	lea	no_mem_to_load_file_s(pc),a0
.show_string_a0:
	gemdos	Cconws,(a0)
	rts
;----------------------------------------------------------------------------
boot_SLB:
	movem.l	d0/a0-a2,-(sp)
	move.l	loc_currbp_p_p(pc),-(sp)	;pass p_run address to SLB loader
	movea.l	#$100,a2
	adda.l	d0,a2
	jsr	(a2)				;call DOS ll_bootup function
	addq	#4,sp				;clean stack
	move.l	d0,module_init_d0		;store -> SLB FunctionTable
	bmi.s	.done_SLB_OVL
	move.l	d0,a0
	move.l	(a0)+,Slbopen_fun_p
	move.l	(a0)+,Slbclose_fun_p
	lea	MD_gemdos_func_t+4*(Slbopen&$fff)(pc),a1
	lea	MD_func_Slbopen(pc),a0
	move.l	a0,(a1)+	;
	lea	MD_func_Slbclose(pc),a0
	move.l	a0,(a1)+
	lea	MD_gemdos_func_f+1*(Slbopen&$fff)(pc),a1
	sf	(a1)+				;stop blocking Slbopen
	sf	(a1)+				;stop blocking Slbclose
.done_SLB_OVL:	
	movem.l	(sp)+,d0/a0-a2
	rts
;
;long cdecl Slbopen (long rts, int opcode, const char *name, const char *path,
;		     long min_ver, SL **slp, void **fn, long param)
;long cdecl Slbclose_fun (long fun_rts, int fun_opcode, SL *fun_SL_p)
;----------------------------------------------------------------------------
boot_DOS:
	movem.l	d0/a0-a2,-(sp)
	movea.l	#$100,a2
	adda.l	d0,a2
	jsr	(a2)			;call DOS ll_bootup function
	move.l	d0,module_init_d0	;store -> DOS FunctionTable+12
	move.l	d1,DOS_init_d1		;store -> DOS device name
	movem.l	(sp)+,d0/a0-a2
	tst.l	module_init_d0		;DOS initialization error ?
	bmi	t_10b2
t_f6c:
	tst.l	DOS_chain_p
	beq.s	t_f8c
	lea	meta_DOS_t,a3		;a3 -> DOS table base
	adda.l	#(DOS_limit-1)*sizeof_DOS,a3	;a3 -> DOS table end
	cmpa.l	next_DOS_p(pc),a3
	ble	t_10b4
	bra.s	t_f96
;
t_f8c:
	move.l	#meta_DOS_t,next_DOS_p
t_f96:
	addq.l	#1,a2
	tst.b	(a2)
	beq	t_10b2
	cmpi.b	#LF,(a2)
	beq	t_10b2
	cmpi.b	#',',(a2)
	beq.s	t_f96
	cmpi.b	#' ',(a2)
	beq.s	t_f96
	cmpi.b	#HT,(a2)
	beq.s	t_f96
	cmpi.b	#CR,(a2)
	beq.s	t_f96
	clr.w	d2
	move.b	(a2)+,d2		;d2 = DOS drive char	(ExtenDOS & MetaDOS, but undocumented)
	cmpi.b	#':',(a2)+
	bne	t_10b2
	move	D2,D1
	sub	#'A',D1			;d1 = DOS device code	(ExtenDOS usage, not MetaDOS)
	clr.w	d0
	move.b	(a2),d0			;d0 = BOS drive char	(definite standard)
	move.b	d0,BOS_char_for_DOS
	movem.l	d2/a0-a2,-(sp)
	movea.l	module_init_d0(pc),a0
	movea.l	(a0),a0
	jsr	(a0)			;call DOS ll_initfun function
	movem.l	(sp)+,d2/a0-a2
	tst.l	d0			;is d0 valid as -> LDB, or is it an error code ?
	bpl.s	t_100a
	movea.l	DOS_init_d1(pc),a0
	movem.l	d2/a2,-(sp)
	gemdos	Cconws,(a0)		;display error message
	movem.l	(sp)+,d2/a2
	bsr	show_error_message
	bra	t_f6c
;
t_100a:
	movem.l	d0-d2/a0,-(sp)
	sub	#'A',d2			;d2 = DOS device code
	blt.s	t_1028
	cmp	#32,d2
	bhs.s	t_1028			;skip if gemdos device code too high (illegal)
	lea	dosdev2boschr_t(pc),a0
	move.b	BOS_char_for_DOS(pc),0(a0,d2.w)
t_1028:
	movem.l	(sp)+,d0-d2/a0
	movea.l	next_DOS_p(pc),a1
	tst.l	DOS_chain_p
	beq.s	t_104c
	movea.l	a1,a3
	lea	sizeof_DOS(a3),a3
	move.l	a3,DOS_next(a1)
	movea.l	a3,a1
	move.l	a1,next_DOS_p
t_104c:
	clr.b	DOS_path(a1)
	move.l	d0,DOS_LDB_p(a1)
	move.l	d1,DOS_FSmode_bits(a1)
	clr.l	DOS_next(a1)
	move.w	d2,DOS_char(a1)
	lea	DOS_title_s(a1),a3
	movea.l	DOS_init_d1,a4
t_1066:
	move.b	(a4)+,(a3)+		;copy title to DOS struct
	bne.s	t_1066
	move.l	module_init_d0(pc),d0
	addq.l	#4,d0
	move.l	d0,DOS_func_tp(a1)
	move	DOS_char(a1),d1
	sub	#'A',d1
	move.l	(_drvbits).w,d0
	bset	d1,d0
	move.l	d0,(_drvbits).w
	move.l	meta_drvbits(pc),d0
	bset	d1,d0
	move.l	d0,meta_drvbits
	movea.l	next_DOS_p(pc),a0
	tst.l	DOS_chain_p
	bne.s	t_10aa
	move.l	a0,DOS_chain_p
t_10aa:
	bsr	t_122c
	bra	t_f6c
;
t_10b2:
	rts
;
t_10b4:
	gemdos	Cconws,out_of_DOS_space_s(pc)
	rts
;----------------------------------------------------------------------------
show_error_message:
	movem.l	d0-d2/a0-a2,-(sp)
	cmp.l	#-$27,d0
	bne.s	t_10d8
	lea	d_20f4(pc),a0
	bra.s	t_110e
;------------------------------------
t_10d8:
	cmp.l	#-5,d0
	bne.s	t_10e8
	lea	d_218c(pc),a0
	bra.s	t_110e
;------------------------------------
t_10e8:
	cmp.l	#-12,d0
	bne.s	t_10f8
	lea	d_21b0(pc),a0
	bra.s	t_110e
;------------------------------------
t_10f8:
	cmp.l	#-4,d0
	bne.s	t_1108
	lea	d_21d6(pc),a0
	bra.s	t_110e
;------------------------------------
t_1108:
	lea	d_2166(pc),a0
t_110e:
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1			 ;cconws
	addq.w	#6,sp
	lea	d_21ee(pc),a0
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1			 ;cconws
	addq.w	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;----------------------------------------------------------------------------
boot_BOS:
	movem.l	d0/a0-a2,-(sp)
	movea.l	#$100,a2
	adda.l	d0,a2
	jsr	(a2)		;call primary init sub of BOS
	move.l	d0,module_init_d0
	movem.l	(sp)+,d0/a0-a2
	tst.l	module_init_d0
	bmi	t_122a
init_BOS_loop:
	addq.l	#1,a2
	tst.b	(a2)
	beq	t_122a
	cmpi.b	#LF,(a2)
	beq	t_122a
	cmpi.b	#',',(a2)
	beq.s	init_BOS_loop
	cmpi.b	#' ',(a2)
	beq.s	init_BOS_loop
	cmpi.b	#HT,(a2)
	beq.s	init_BOS_loop
	cmpi.b	#CR,(a2)
	beq.s	init_BOS_loop
	clr.w	d0
	move.b	(a2)+,d0		;d0 =  physical drive letter
	clr	d1			;d1 = 0 as default ACSI/SCSI id
	cmpi.b	#':',(a2)+
	bne.s	.done_drive_id
	bsr	parse_number_to_d1
	bmi.s	.done_drive_id
	cmpi.b	#'.',(A2)		;'.' at char[a2] ?
	bne.s	.not_ExtenDOS_id
.ExtenDOS_LUN_spec:
	ror.l	#4,D1			;preserve drive ID in top bits of d1.hi
	addq	#1,A2			;step to next char
	bsr	parse_number_to_d1	;d1.lo = LUN
	rol.l	#4,D1			;d1.lo = LUN<<4 + ID
	bra.s	.done_drive_id
;
.not_ExtenDOS_id:
	cmpi.b	#'\',(a2)
	bne.s	.done_drive_id
.SPIN_LUN_spec:
	ror.l	#8,d1			;preserve drive ID in top byte of d1.hi
	addq	#1,A2			;step to next char
	bsr	parse_number_to_d1	;d1.lo = LUN
	rol	#5,d1			;d1.lo = LUN<<5
	rol.l	#8,d1			;d1.lo = LUN<<13 + ID
.done_drive_id:
	movem.l	d0/a2,-(sp)
	movea.l	module_init_d0(pc),a0
	movea.l	(a0),a0
	jsr	(a0)		;call BOS_Init_fun
	move.l	d0,d1
	tst.l	d1
	bpl.s	.t_11de
	bsr	show_error_message
	movem.l	(sp)+,d0/a2
	bra	init_BOS_loop
;------------------------------------
.t_11de:
	movem.l	(sp)+,d0/a2
	movea.l	d1,a0
	tst.l	BOS_chain_p
	beq.s	t_120a
	movea.l	BOS_chain_p(pc),a0
t_11f2:
	movea.l	BOS_next(a0),a1
	cmpa.l	#0,a1
	beq.s	t_1202
	move.l	a1,a0
	bra	t_11f2
;------------------------------------
t_1202:
	move.l	d1,BOS_next(a0)
	movea.l	d1,a0
	bra.s	t_1210
;------------------------------------
t_120a:
	move.l	a0,BOS_chain_p
t_1210:
	lea	Metainfo_1(pc),a1
	move.l	(a1),d1			;d1 = drivemap
	move	BOS_char(a0),d0		;d0 = drive letter
	sub	#'A',d0			;d0 = drive number
	bset	d0,d1			;set new bit in d1
	move.l	d1,(a1)			;store altered drivemap
	bsr.s	t_1268
	bra	init_BOS_loop
;------------------------------------
t_122a:
	rts
;----------------------------------------------------------------------------
t_122c:
	move.l	a0,a3
	lea	DOS_title_s(a3),a1
	gemdos	Cconws,(a1)
	move	DOS_char(a3),d0
	beq.s	t_1256
	lea	DOS_installed_s(pc),a1
	move.b	d0,DOS_drive_letter_s-DOS_installed_s(a1)
	gemdos	Cconws,(a1)
t_1256:
	gemdos	Cconws,point_crlf_s(pc)
	move.l	a3,a0
	rts
;----------------------------------------------------------------------------
t_1268:
	move.l	a0,a3
	gemdos	Cconws,BOS_title_s(a3)
	gemdos	Cconws,BOS_installed_s(pc)
	move.w	BOS_char(a3),d0
	beq.s	t_12a0
	lea	as_x_colon_s(pc),a1
	move.b	d0,BOS_char_letter_s-as_x_colon_s(a1)
	gemdos	Cconws,(a1)
t_12a0:
	move	BOS_xCSI_LUN_ID(a3),d0
	move	d0,d1
	move	d0,d2
	and	#$1F,d0		;d0 = preliminary ID
	lsr	#4,d1
	and	#7,d1		;d1 = ExtenDOS-style LUN
	lsr	#8,d2		;d2 = Extendos-style I/F
	beq.s	.no_xCSI_letter
	cmp	#'A',d2
	beq.s	.good_xCSI_letter
	cmp	#'S',d2
	beq.s	.good_xCSI_letter
	cmp	#'I',d2
	beq.s	.good_xCSI_letter
	and	#$70,d2
	beq.s	.no_xCSI_letter
	move	d2,d1
	lsr	#5,d1		;d1 = SPIN-style LUN
.no_xCSI_letter:
	clr	d2
	bra.s	.done_xCSI_letter
;
.good_xCSI_letter:
	and	#$0F,d0		;d0 = ExtenDOS-style ID
.done_xCSI_letter:
	cmp.w	#$12,d0
	bhs.s	t_12f8
	tst	d2
	bne.s	.have_xCSI_letter
	cmp	#$10,d0
	blo.s	.done_IDE_letter
	moveq	#'I',d2
	clr	d1		;clear LUN for IDE
	bra.s	.have_xCSI_letter
;
.done_IDE_letter:
	cmp	#8,d0
	blo.s	.done_SCSI_letter
	moveq	#'S',d2
	bra.s	.have_xCSI_letter
;
.done_SCSI_letter:
	moveq	#'A',d2
.have_xCSI_letter:
	and	#7,d0		;d0 = pure drive ID
	add	#'0',d0		;d0 = drive ID digit
	move.b	d0,drive_id_digit_s
	and	#7,d1		;d1 = pure drive LUN
	add	#'0',d1		;d1 = drive LUN digit
	move.b	d1,drive_lun_digit_s
	lea	on_IDE_s(pc),a1
	cmp	#'I',d2		;IDE ?
	beq.s	.show_drive_info
	lea	on_ACSI_s(pc),a1
	blo.s	.show_drive_info
	lea	on_SCSI_s(pc),a1
.show_drive_info:
	gemdos	Cconws,(a1)
	gemdos	Cconws,drive_ID_dot_LUN_s(pc)
t_12f8:
	gemdos	Cconws,point_crlf_s(pc)
	exg	a0,a3
	rts
;----------------------------------------------------------------------------
parse_number_to_d1:
	clr	d1		;d1.lo = 0
	bsr.s	parse_digit_to_d2
	bmi.s	parse_error
.loop:				;loop start for each digit
	swap	d2		;d2.hi = new_digit, d2.lo = free for use
	move	d1,d2		;d2.lo = old_number
	asl	#2,d1		;d1.lo =  4 * old_number
	add	d2,d1		;d1.lo =  5 * old_number
	add	d1,d1		;d1.lo = 10 * old_number
	swap	d2		;d2.lo = new_digit
	add	d2,d1		;d1.lo = new_number
	bsr.s	parse_digit_to_d2
	bpl.s	.loop		;loop back for each digit
	cmp	d1,d1		;flag PL
	rts			;exit, flagging PL
;----------------------------------------------------------------------------
parse_digit_to_d2:
	cmpi.b	#'0',(a2)
	blt.s	parse_error
	cmpi.b	#'9',(a2)
	bgt.s	parse_error
	move.b	(A2)+,d2
	and	#15,D2		;make digit binary and flag PL
	rts			;exit, flagging PL
;------------------------------------
parse_error:
	moveq	#-1,D2		;flag MI
	rts			;exit, flagging MI
;----------------------------------------------------------------------------
init_tst_module:
	cmpi.b	#',',(a3)+
	bne.s	init_tst_module
t_1310:
	cmpi.b	#' ',(a3)+
	bne.s	t_1310
	movea.l	a3,a0
	lea	b_61c1(pc),a1
	clr.b	(a1)+
	clr.b	(a1)
	clr.w	d0
t_1324:
	cmpi.b	#CR,(a3)
	beq.s	t_1340
	cmpi.b	#',',(a3)
	beq.s	t_1340
	cmpi.b	#' ',(a3)
	beq.s	t_1344
	cmpi.b	#HT,(a3)
	beq.s	t_1344
	addq.l	#1,a3
	bra	t_1324
;
t_1340:
	movea.l	a3,a2
	bra.s	t_1370
;
t_1344:
	movea.l	a3,a2
t_1346:
	cmpi.b	#' ',(a2)
	bne.s	t_1350
	addq.l	#1,a2
	beq.s	t_1346
t_1350:
	cmpi.b	#CR,(a2)
	beq.s	t_1368
	cmpi.b	#';',(a2)
	beq.s	t_1368
	cmpi.b	#',',(a2)
	beq.s	t_1368
	move.b	(a2)+,(a1)+
	addq.w	#1,d0
	bra	t_1350
;
t_1368:
	clr.b	(a1)+
	move.b	d0,b_61c1
t_1370:
	clr.b	(a3)+
	movem.l	a0/a2,-(sp)
	bsr	t_1404
	movem.l	(sp)+,a0/a2
	rts
;----------------------------------------------------------------------------
t_1380:
	lea	b_6241(pc),a3
t_1386:
	cmpi.b	#$20,(a3)
	bne.s	t_1396
	cmpi.b	#9,(a3)
	bne.s	t_1396
	addq.l	#1,a3
	bra	t_1386
;
t_1396:
	movea.l	a3,a0
	lea	b_61c1(pc),a1
	clr.b	(a1)+
	clr.b	(a1)
	clr.w	d0
t_13a4:
	cmpi.b	#10,(a3)
	beq.s	t_13ba
	cmpi.b	#$20,(a3)
	beq.s	t_13be
	cmpi.b	#9,(a3)
	beq.s	t_13be
	addq.l	#1,a3
	bra	t_13a4
;
t_13ba:
	movea.l	a3,a2
	bra.s	t_13e4
;
t_13be:
	movea.l	a3,a2
t_13c0:
	cmpi.b	#$20,(a2)
	bne.s	t_13ca
	addq.l	#1,a2
	beq.s	t_13c0
t_13ca:
	cmpi.b	#10,(a2)
	beq.s	t_13dc
	cmpi.b	#$3b,(a2)
	beq.s	t_13dc
	move.b	(a2)+,(a1)+
	addq.w	#1,d0
	bra	t_13ca
;
t_13dc:
	clr.b	(a1)+
	move.b	d0,b_61c1
t_13e4:
	clr.b	(a3)+
	move.l	#0,-(sp)
	pea	b_61c1(pc)
	move.l	a0,-(sp)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1			 ;pexec
	adda.w	#$10,sp
	rts
;----------------------------------------------------------------------------
t_1404:
	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1			 ;fopen
	addq.w	#8,sp
	tst.w	d0
	bmi	init_err_file_not_found
	move.w	d0,init_mod_handle
	suba.l	#ph_size,sp
	move.l	sp,b_62ec
	bsr.s	t_1446
	adda.l	#ph_size,sp
	move.l	d0,d3
	move.w	init_mod_handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1			 ;fclose
	addq.w	#4,sp
	move.l	d3,d0
	rts
;----------------------------------------------------------------------------
t_1446:
	move.w	#2,-(sp)
	move.w	init_mod_handle(pc),-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1			 ;fseek
	adda.w	#10,sp
	move.l	d0,init_mod_file_len
	move.w	#0,-(sp)
	move.w	init_mod_handle(pc),-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1			 ;fseek
	adda.w	#10,sp
	move.l	b_62ec(pc),-(sp)
	move.l	#ph_size,-(sp)
	move.w	init_mod_handle(pc),-(sp)
	move.w	#$3f,-(sp)
	trap	#1			 ;fread
	adda.w	#12,sp
	cmpi.l	#ph_size,d0
	bne.s	init_err_bad_file
	movea.l	b_62ec(pc),a0
	cmpi.w	#$601a,0(a0)
	bne.s	init_err_bad_file
	move.l	init_mod_file_len(pc),d0
	sub.l	#ph_size,d0
	add.l	#$100,d0
	add.l	10(a0),d0
	sub.l	14(a0),d0
	beq.s	init_err_bad_file
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1			 ;malloc
	addq.w	#6,sp
	move.l	d0,b_62f4
	beq.s	init_err_no_mem_to_load_file
	bsr	t_15be
	bsr.s	t_1544
	bmi.s	init_err_mfree_bad_file
	bsr.s	t_1512
	bmi.s	init_err_mfree_bad_file
	bsr	t_1638
	move.l	b_62f4(pc),d0
	rts
;----------------------------------------------------------------------------
init_err_mfree_bad_file:
	move.l	b_62f4(pc),-(sp)
	move.w	#$49,-(sp)
	trap	#1			 ;mfree
	addq.w	#6,sp
init_err_bad_file:
	moveq	#-1,d0
	rts
;----------------------------------------------------------------------------
init_err_file_not_found:
	moveq	#-3,d0
	rts
;----------------------------------------------------------------------------
init_err_no_mem_to_load_file:
	moveq	#-2,d0
	rts
;----------------------------------------------------------------------------
t_1512:
	movea.l	b_62f4(pc),a0
	movea.l	8(a0),a3
	movea.l	$18(a0),a4
	move.l	a3,d3
	move.l	(a4)+,d0
	beq.s	t_1542
	adda.l	d0,a3
	add.l	d3,(a3)
	clr.w	d0
t_152c:
	move.b	(a4)+,d0
	beq.s	t_1542
	cmp.b	#1,d0
	bne.s	t_153c
	adda.w	#$fe,a3
	bra	t_152c
;----------------------------------------------------------------------------
t_153c:
	adda.l	d0,a3
	add.l	d3,(a3)
	bra	t_152c
;----------------------------------------------------------------------------
t_1542:
	rts
;----------------------------------------------------------------------------
t_1544:
	movea.l	b_62f4(pc),a3
	movea.l	8(a0),a4
	movea.l	b_62ec(pc),a5
	move.l	2(a5),d3
	add.l	6(a5),d3
	move.l	a4,-(sp)
	move.l	d3,-(sp)
	move.w	init_mod_handle(pc),-(sp)
	move.w	#$3f,-(sp)
	trap	#1			 ;fread
	adda.w	#12,sp
	cmp.l	d0,d3
	bne.s	init_err_bad_file
	move.l	14(a5),d0
	move.w	#1,-(sp)
	move.w	init_mod_handle(pc),-(sp)
	move.l	d0,-(sp)
	move.w	#$42,-(sp)
	trap	#1			 ;fseek
	adda.w	#10,sp
	movea.l	$18(a3),a0
	clr.l	d0
	move.l	d0,0(a0)
	tst.w	$1a(a5)
	bne.s	t_15bc
	move.l	a0,-(sp)
	move.l	#$7fffffff,-(sp)
	move.w	init_mod_handle(pc),-(sp)
	move.w	#$3f,-(sp)
	trap	#1			 ;fread
	adda.w	#12,sp
	tst.l	d0
	beq	init_err_bad_file
t_15bc:
	rts
;----------------------------------------------------------------------------
t_15be:
	movea.l	b_62f4(pc),a0
	movea.l	basepage_p(pc),a1
	movea.l	b_62ec(pc),a2
	move.l	a0,0(a0)
	move.l	#$100,d0
	add.l	2(a2),d0
	add.l	6(a2),d0
	add.l	10(a2),d0
	move.l	d0,4(a0)
	move.l	a0,d0
	add.l	#$100,d0
	move.l	d0,8(a0)
	move.l	2(a2),12(a0)
	add.l	12(a0),d0
	move.l	d0,$10(a0)
	move.l	6(a2),$14(a0)
	add.l	$14(a0),d0
	move.l	d0,$18(a0)
	move.l	10(a2),$1c(a0)
	move.l	$24(a1),$24(a0)
	move.l	$2c(a1),$2c(a0)
	lea	$80(a0),a1
	move.l	a1,$20(a0)
	lea	b_61c1(pc),a2
t_1632:
	move.b	(a2)+,(a1)+
	bne.s	t_1632
	rts
;----------------------------------------------------------------------------
t_1638:
	movem.l	d3-d7/a3,-(sp)
	movea.l	b_62f4(pc),a0
	movea.l	$18(a0),a1
	move.l	$1c(a0),d0
	movea.l	a1,a0
	adda.l	d0,a1
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movea.w	d7,a3
	move.l	a0,d0
	btst	#0,d0
	beq.s	t_1668
	move.b	d1,(a0)+
t_1668:
	move.l	a1,d0
	sub.l	a0,d0
	and.l	#-$100,d0
	beq.s	t_16a0
	lea	0(a0,d0.l),a0
	movea.l	a0,a2
	lsr.l	#8,d0
t_167c:
	movem.l	d1-d7/a3,-(a2)
	movem.l	d1-d7/a3,-(a2)
	movem.l	d1-d7/a3,-(a2)
	movem.l	d1-d7/a3,-(a2)
	movem.l	d1-d7/a3,-(a2)
	movem.l	d1-d7/a3,-(a2)
	movem.l	d1-d7/a3,-(a2)
	movem.l	d1-d7/a3,-(a2)
	subq.l	#1,d0
	bne.s	t_167c
t_16a0:
	cmpa.l	a0,a1
	beq.s	t_16a8
	move.b	d1,(a0)+
	bra	t_16a0
;----------------------------------------------------------------------------
t_16a8:
	movem.l	(sp)+,d3-d7/a3
	rts
;----------------------------------------------------------------------------
MD_func_Pexec:
	move	6(sp),d0	;test Pexec subop,  Load'n'go ?
	beq.s	.some_load
	cmp	#3,d0		;test again,  load ?
	beq.s	.some_load
	cmp	#100,d0		;test again,  Asynch Load'n'go ?
	bne	E_1001_sub	;use old gemdos for nonloading Pexec opcodes
.some_load:			;The above means 'Overlay' mode is unsupported
	movea.l	8(sp),a0
	cmpi.b	#':',1(a0)
	bne.s	t_16da
	clr.w	d0
	move.b	(a0),d0
	cmp.b	#'a',d0
	blt.s	t_16e4
	sub.b	#$20,d0
	bra.s	t_16e4
;
t_16da:
	bsr	MD_func_Dgetdrv		;d0 = drive number
	add		#'A',d0
t_16e4:
	move.w	d0,b_6360
	bsr	find_char_d0_DOS
	bmi	E_1001_sub		;use old gemdos for non-Metados drives
	clr.l	Pexec_basepage_p
	move.l	a0,found_DOS
;
	move.w	#0,-(sp)
	move.l	10(sp),-(sp)
	move.w	#$3d,-(sp)		;push Fopen opcode
	jsr	MD_func_Fcreate_Fopen
	addq.l	#8,sp
;
	tst.l	d0
	bmi	Pexec_rts_1		;exit on Fopen error
	move.w	d0,Pexec_handle
;
	pea	Pexec_ph_buf(pc)
	move.l	#ph_size,-(sp)
	move.w	d0,-(sp)		;push file handle
	move.w	#$3f,-(sp)		;push Fread opcode
	bsr	MD_func_Fread_Fwrite
	lea	12(sp),sp
;
	cmp.l	#ph_size,d0
	bne.s	Pexec_E_PLFMT
	lea	Pexec_ph_buf(pc),a0
	cmpi.w	#$601a,0(a0)
	bne.s	Pexec_E_PLFMT
;-------
	sub_gemdos.i	Pexec,#7,22(a0),16(sp),16(sp)	;NB: stack trick
	cmp.l		#E_INVFN,d0
	bne.s		.basepage_created
	sub_gemdos.i	Pexec,#5,#0,16(sp),16(sp)	;NB: stack trick
.basepage_created:
	tst.l	d0
	bmi.s	.basepage_done
	move.l	d0,Pexec_basepage_p
	bsr.s	Pexec_load_sub
.basepage_done:
	move.l	d0,d3
	bsr.s	Pexec_close
	move.l	d3,d0
	bmi.s	Pexec_abort
	tst.w	6(sp)		;subop Load_and_go ?
	beq	Pexec_Go
	cmp	#100,6(sp)	;subop Asynch Load_and_go ?
	beq	Pexec_Go
Pexec_rts_1:
	rts
;----------------------------------------------------------------------------
Pexec_E_PLFMT:
	bsr.s	Pexec_close
	moveq	#E_PLFMT,d0
	rts
;----------------------------------------------------------------------------
Pexec_close:
	move.w	Pexec_handle(pc),-(sp)
	move.w	#$3e,-(sp)		;push Fclose opcode
	bsr	MD_func_Fclose
	addq.l	#4,sp
;
	rts
;----------------------------------------------------------------------------
Pexec_load_sub:
	lea	Pexec_ph_buf(pc),a0
	move.l	#$100,d0
	add.l	2(a0),d0
	add.l	6(a0),d0
	add.l	10(a0),d0
	move.l	d0,b_6362
	movea.l	Pexec_basepage_p(pc),a1
	move.l	4(a1),d0
	sub.l	0(a1),d0
	cmp.l	b_6362(pc),d0
	bmi.s	E_NSMEM_sub
	bsr	t_198a
	bsr	t_18f8
	bmi.s	E_NSMEM_sub
	bsr	t_18a2
	bsr	t_18d4
	move.l	Pexec_basepage_p,d0
	rts
;----------------------------------------------------------------------------
E_NSMEM_sub:
	moveq	#E_NSMEM,d0
t_1820:
	rts
;----------------------------------------------------------------------------
Pexec_abort:
	move.l	d0,-(sp)
	tst.l	Pexec_basepage_p
	beq.s	t_1850
	movea.l	Pexec_basepage_p(pc),a1
	move.l	$2c(a1),-(sp)
	move.w	#(Mfree&$ff),-(sp)
	bsr	gemdos_sub		;release RAM
	addq.l	#6,sp
	move.l	Pexec_basepage_p(pc),-(sp)
	move.w	#(Mfree&$ff),-(sp)
	bsr	gemdos_sub		;release RAM
	addq.l	#6,sp
t_1850:
	move.l	(sp)+,d0
	rts
;----------------------------------------------------------------------------
Pexec_Go:
	clr.l	b_62fe
	tst.l	TOS_patch_p
	beq.s	t_1866
	bsr	t_19c6
t_1866:
	clr.l	16(sp)
	move.l	Pexec_basepage_p,12(sp)
	clr.l	8(sp)
	clr	d0			;Preclear future Pexec subop in d0
	cmp	#100,6(sp)		;retest Pexec subop, Asynch type ?
	blo.s	.have_Pexec_type
	moveq	#100,d0			;offset future Pexec subop by 100
.have_Pexec_type:
	tst.l	TOS_patch_p
	bne.s	.very_old_TOS
	add	#6,d0			;d0 += go_then_free subop
	move	d0,6(sp)		;patch Pexec subop on stack
	bra	E_1001_sub		;tell dispatcher to use old gemdos
;-------
.very_old_TOS:	
	add	#4,d0			;d0 += go_then_free subop
	move	d0,6(sp)		;patch Pexec subop on stack
	bra	E_1001_sub		;tell dispatcher to use old gemdos
;----------------------------------------------------------------------------
t_18a2:
	movea.l	Pexec_basepage_p(pc),a0
	movea.l	8(a0),a3
	movea.l	$18(a0),a4
	move.l	a3,d3
	move.l	(a4)+,d0
	beq.s	t_18d2
	adda.l	d0,a3
	add.l	d3,(a3)
	clr.l	d0
t_18bc:
	move.b	(a4)+,d0
	beq.s	t_18d2
	cmp.b	#1,d0
	bne.s	t_18cc
	adda.w	#$fe,a3
	bra	t_18bc
;
t_18cc:
	adda.l	d0,a3
	add.l	d3,(a3)
	bra	t_18bc
;
t_18d2:
	rts
;----------------------------------------------------------------------------
t_18d4:
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d1
	movea.l	Pexec_basepage_p(pc),a0
	move.l	$1c(a0),d0
	asr.l	#2,d0
	addq.w	#1,d0
	movea.l	$18(a0),a0
t_18ec:
	move.l	d1,(a0)+
	subq.w	#1,d0
	bne.s	t_18ec
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;----------------------------------------------------------------------------
t_18f8:
	movea.l	Pexec_basepage_p(pc),a3
	lea	Pexec_ph_buf(pc),a5
	move.l	2(a5),d3
	add.l	6(a5),d3
	move.l	d3,-(sp)
;
	move.l	8(a3),-(sp)
	move.l	d3,-(sp)
	move.w	Pexec_handle(pc),-(sp)
	move.w	#$3f,-(sp)
	jsr	MD_func_Fread_Fwrite
	lea	12(sp),sp
;
	move.l	(sp)+,d3
	cmp.l	d0,d3
	bne	E_NSMEM_sub
	lea	Pexec_ph_buf(pc),a5
	move.l	14(a5),d0
;
	move.w	#1,-(sp)
	move.w	Pexec_handle(pc),-(sp)
	move.l	d0,-(sp)
	move.w	#$42,-(sp)
	bsr	MD_func_Fseek_Fdatime
	lea	10(sp),sp
;
	movea.l	Pexec_basepage_p(pc),a3
	movea.l	$18(a3),a0
	clr.l	d0
	move.l	d0,0(a0)
	tst.w	$1a(a5)
	bne.s	t_1982
;
	move.l	a0,-(sp)
	move.l	#$7fffffff,-(sp)
	move.w	Pexec_handle(pc),-(sp)
	move.w	#$3f,-(sp)
	bsr	MD_func_Fread_Fwrite
	lea	12(sp),sp
;
t_1982:
	tst.l	d0
	bmi	E_NSMEM_sub
	rts
;----------------------------------------------------------------------------
t_198a:
	movea.l	Pexec_basepage_p(pc),a0
	lea	Pexec_ph_buf(pc),a2
	move.l	a0,d0
	add.l	#$100,d0
	move.l	d0,8(a0)
	move.l	2(a2),12(a0)
	add.l	12(a0),d0
	move.l	d0,$10(a0)
	move.l	6(a2),$14(a0)
	add.l	$14(a0),d0
	move.l	d0,$18(a0)
	move.l	10(a2),$1c(a0)
	rts
;----------------------------------------------------------------------------
t_19c6:				;NB: only called for TOS 1.00 or 1.02
	movea.l	TOS_patch_p(pc),a2
	movea.l	4(a2),a3
	movea.l	Pexec_basepage_p(pc),a2
	movea.l	$2c(a2),a4
t_19da:
	cmpa.l	#0,a3
	beq.s	t_19f8
	movea.l	4(a3),a0
	cmpa.l	a2,a0
	beq.s	t_19ee
	cmpa.l	a4,a0
	bne.s	t_19f2
t_19ee:
	move.l	a2,12(a3)
t_19f2:
	movea.l	0(a3),a3
	bra	t_19da
;----------------------------------------------------------------------------
t_19f8:
	rts
;----------------------------------------------------------------------------
find_os_currbp_p:
	movea.l	(_sysbase).w,a0
	movea.l	os_selfbeg_p(a0),a0
	cmpi.w	#$102,os_version(a0)	;TOS 1.02 ?
	bhs.s	.modern_TOS
	move.w	os_config(a0),d0
	lsr.w	#1,d0
	subq.w	#4,d0
	bne.s	.old_TOS_2
.old_TOS_1:
	move.l	#$873c,d0
	rts
;
.old_TOS_2:
	move.l	#$602c,d0
	rts
;
.modern_TOS:
	move.l	os_currbp_p_p(a0),d0
	rts
;----------------------------------------------------------------------------
defpop_FCB_a5:
	lea	meta_FCB_t(pc),a5
	movea.l	a5,a3
	adda.l	#FCB_limit*sizeof_FCB,a3
.seek_free_FCB:
	tst.l	FCB_DOS_p(a5)
	bmi.s	.have_free_FCB
	adda.l	#sizeof_FCB,a5
	cmpa.l	a3,a5
	bgt.s	.pop_NOMEM
	bra	.seek_free_FCB
;
.pop_NOMEM:
	addq	#4,sp		;pop 1 return level off stack
	moveq	#E_NSMEM,d0
	rts
;
.have_free_FCB:
	movea.l	a5,a3
	move	#sizeof_FCB/2-1,d0
.clr_loop:
	clr	(a3)+
	dbra	d0,.clr_loop
	rts
;----------------------------------------------------------------------------
defpop_dir_FCB_a5:
	lea	meta_FCB_t(pc),a5
	movea.l	a5,a3
	adda.l	#FCB_limit*sizeof_FCB,a3
.seek_free_FCB:
	tst.l	FCB_DOS_p(a5)
	bmi.s	.have_free_FCB
	adda.l	#sizeof_FCB,a5
	cmpa.l	a3,a5
	bgt.s	.pop_NHNDL
	bra	.seek_free_FCB
;
.pop_NHNDL:
	addq	#4,sp		;pop 1 return level off stack
	moveq	#E_NHNDL,d0
	rts
;
.have_free_FCB:
	movea.l	a5,a3
	move	#sizeof_FCB/2-1,d0
.clr_loop:
	clr	(a3)+
	dbra	d0,.clr_loop
	rts
;----------------------------------------------------------------------------
MD_etv_term_sub:
	movea.l	loc_currbp_p_p(pc),a0	;a0 -> -> active basepage
	move.l	(a0),d2			;d2 -> active basepage
	lea	meta_FCB_t(pc),a5
	movea.l	a5,a3
	adda.l	#FCB_limit*sizeof_FCB,a3
.seek_FCB_loop:
	cmp.l	FCB_owner(a5),d2		;does FCB_owner(a5) -> basepage ?
	bne.s	.next_FCB
	tst.l	FCB_DOS_p(a5)
	bpl.s	.found_FCB
.next_FCB:
	adda.l	#sizeof_FCB,a5
	cmpa.l	a3,a5
	ble.s	.seek_FCB_loop
	rts
;
.found_FCB:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a5,d0
	sub.l	#meta_FCB_t,d0
	lsr.l	#2,d0
	add	#100,d0
	tst	FCB_dirflag(a5)
	beq.s	.etv_term_file_FCB
.etv_term_dir_FCB:
	move.l	d0,-(sp)
	move	#(Dclosedir&$fff),-(sp)
	bsr	MD_func_Dclosedir
	addq	#6,sp
;
	bra.s	.etv_term_FCB_common
;
.etv_term_file_FCB:
	move	d0,-(sp)
	move	#(Fclose&$ff),-(sp)
	bsr	MD_func_Fclose
	addq	#4,sp
.etv_term_FCB_common:
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	#-1,FCB_DOS_p(a5)
	clr.l	FCB_owner(a5)
	IFNE	DEBUG_FCB_count
	subq	#1,FCB_count
	ENDC
	bra	.next_FCB
;----------------------------------------------------------------------------
MD_func_Pterm_x:
	jsr	Slb_Pterm_sub		;tell SLBs about termination
	movea.l	(etv_term).w,a0
	jsr	(a0)
	bsr.s	MD_etv_term_sub
	lea	(etv_term).w,a0
	move.l	(a0),saved_etv_term
	move.l	#post_Pterm_etv_term,(a0)
	bra	E_1001_sub		;tell dispatcher to use old gemdos
;
post_Pterm_etv_term:
	move.l	saved_etv_term,(etv_term).w	;etv_term
	rts
;----------------------------------------------------------------------------
	trace_CODE
;----------------------------------------------------------------------------
	make	JAR_links
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
;Start of:	Extendos compatibility cookie
;----------------------------------------------------------------------------
EPro_cookie_t:
	dc.l	$0301			;Extendos Interface version
	dc.l	MD_gemdos_func_t
	dc.l	MD_bios_func_t
	dc.l	0,100,100,0
	dc.l	meta_FCB_t
DOS_chain_p:
	dc.l	0
BOS_chain_p:
	dc.l	0
	dc.l	weird_cook_p
;-------
	dc.l	$100/4			;safety margin
;----------------------------------------------------------------------------
;End of:	Extendos compatibility cookie
;----------------------------------------------------------------------------
;Start of:	MD_gemdos_func_t
;----------------------------------------------------------------------------
MD_gemdos_func_t:
	dc.l	MD_func_Pterm_x,-1,-1,-1,-1,-1,-1,-1			;Pterm0
	dc.l	-1,-1,-1,-1,-1,-1,MD_func_Dsetdrv,-1			;Dsetdrv
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1			;Slbopen,Slbclose (with OVL)
	dc.l	-1,MD_func_Dgetdrv,-1,-1,-1,-1,-1,-1			;Dgetdrv
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1
	dc.l	-1,MD_func_Pterm_x,-1,-1,-1,-1,MD_func_Dfree,-1		;Dfree
	dc.l	-1,MD_func_DF_diverse,MD_func_DF_diverse,MD_func_Dsetpath
	dc.l	MD_func_Fcreate_Fopen,MD_func_Fcreate_Fopen,MD_func_Fclose,MD_func_Fread_Fwrite
	dc.l	MD_func_Fread_Fwrite,MD_func_DF_diverse,MD_func_Fseek_Fdatime,MD_func_DF_diverse
	dc.l	-1,-1,MD_func_Fforce,MD_func_Dgetpath
	dc.l	-1,-1,-1,MD_func_Pexec,MD_func_Pterm_x,-1,MD_func_Fsfirst,MD_func_Fsnext
	dc.l	-1,-1,-1,-1,-1,-1,MD_func_Frename,MD_func_Fseek_Fdatime		;Frename, Fdatime
	dcb.l	168,-1
	dc.l	-1,-1,-1,-1,MD_func_Fcntl,-1,-1,-1	;260 Fcntl
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1
	dc.l	-1,-1,-1,-1,MD_func_Dpathconf_D_x_label,-1,-1,-1	;292 Dpathconf
	dc.l	MD_func_Dopendir,MD_func_Dreaddir_Dxreaddir,MD_func_Drewinddir,MD_func_Dclosedir
	dc.l	MD_func_Fxattr,MD_func_Flink,MD_func_Fsymlink,MD_func_Freadlink
	dc.l	MD_func_Dcntl,-1,-1,-1
	dc.l	-1,-1,-1,-1
	dc.l	-1,-1,-1,-1,MD_func_Dgetcwd,-1,-1,-1
	dc.l	-1,-1,MD_func_Dreaddir_Dxreaddir,-1,-1,-1,-1,-1
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1
	dc.l	-1,-1,MD_func_Dpathconf_D_x_label,MD_func_Dpathconf_D_x_label,-1,-1,-1,-1
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1
MD_gemdos_func_t_end:
MD_gemdos_func_t_cnt	=	(MD_gemdos_func_t_end-MD_gemdos_func_t)/4
	IFNE	(MD_gemdos_func_f_cnt-MD_gemdos_func_t_cnt)
	FAIL	"Error in gemdos function tables"
	ENDC
;----------------------------------------------------------------------------
;End of:	MD_gemdos_func_t
;----------------------------------------------------------------------------
;Start of:	MD_bios_func_t
;----------------------------------------------------------------------------
MD_bios_func_t:
	dcb.l	9,-1
	dc.l	-1		;09 Mediach implemented in Extendos
	dcb.l	2,-1
MD_bios_func_t_end:
MD_bios_func_t_cnt	=	(MD_bios_func_t_end-MD_bios_func_t)/4
;----------------------------------------------------------------------------
;End of:	MD_bios_func_t
;----------------------------------------------------------------------------
weird_cook_p:
	dc.l	0		;Extendos has this directly before 'Metainfo_1'!
Metainfo_1:
	dc.l	0
	dc.l	Metainfo_name_s
	dc.l	0
	dc.l	Metainfo_2
;----------------------------------------------------------------------------
Metainfo_2:
	dc.w	$0263
	dc.l	'_MET'
	dc.l	dosdev2boschr_t
;----------------------------------------------------------------------------
frame_size:
	dc.w	6
frame_offset:
	dc.w	0
meta_drvbits:
	dc.l	0
;----------------------------------------------------------------------------
gemdos_drvbits:
	dc.l	0
;----------------------------------------------------------------------------
	IFNE	DEBUG_FCB_count
MFCB_cookie_t:
	dc.l	'MFCB','_cnt'
FCB_count:
	dc.w	0
	ENDC
;----------------------------------------------------------------------------
Slbopen_fun_p:	dc.l	E_INVFN_sub
Slbclose_fun_p:	dc.l	E_INVFN_sub
;----------------------------------------------------------------------------
d_1fbc:
	dc.b	CR,LF,ESC,'p'
	dc.b	' URAn  BetaDOS'
	dc.b		      $bf
	dc.b		       '        ('
	BetaDos_DATE			;yyyy mmm dd
	dc.b				           ') '
	dc.b	ESC,'q',CR,LF
	dc.b	' Version '
	BetaDos_VERSION  ;X.YY
	dc.b	             '                   beta',CR,LF
	dc.b	' Copyright Ulf Ronald Andersson 2000',CR,LF
d_2037:
	dc.b	CR,LF,CR,NUL
	even
;-------
	dc.b	'@(#)'
Metainfo_name_s:
	dc.b	'URAn BetaDOS',$bf,' v'
	BetaDos_VERSION
	dc.b	NUL
	even
;-------
BDOS_repatched_s:
	dc.b	'URAn BetaDOS was already installed,',CR,LF
	dc.b	'but its vectors were now repatched',CR,LF
	dc.b	'to improve compatibility with MiNT',CR,LF,NUL
;-------
BDOS_already_installed_s:
	dc.b	BEL,'URAn BetaDOS',$bf,' already installed!',CR,LF,NUL
;-------
	IFNE	REFUSE_AFTER_MINT
MiNT_must_boot_later_s:
	dc.b	BEL
	dc.b	'MiNT (if used) must boot after BetaDOS !',CR,LF,NUL
	ENDC
;-------
	even
;
boot_bdconfig_sys_s:
	dc.b	'C:\AUTO\BDCONFIG.SYS',NUL
	even
;
no_mem_to_load_file_s:
	dc.b	' no memory to load file.',CR,LF,NUL
	even
d_20f4:
	dc.b	' out of memory to install DOS.',CR,LF,NUL
	even
bad_file_error_s:
	dc.b	' BAD file error.',CR,LF,NUL
	even
file_not_found_error_s:
	dc.b	' file not found error.',CR,LF,NUL
	even
out_of_DOS_space_s:
	dc.b	'Out of logical device headers.',CR,LF,NUL
	even
d_2166:
	dc.b	' BOS error: device not responding.',CR,LF,NUL
	even
d_218c:
	dc.b	' indicates unknown command error.',CR,LF,NUL
	even
d_21b0:
	dc.b	' indicates general hardware error.',CR,LF,NUL
	even
d_21d6:
	dc.b	' indicates CRC error.',CR,LF,NUL
	even
d_21ee:
	dc.b	'This driver is not installed.',CR,LF,NUL
	even
d_220e:
	dc.b	'BDCONFIG.SYS not found in AUTO folder.',CR,LF,NUL
	even
BOS_installed_s:
	dc.b	CR,LF,' installed',NUL
as_x_colon_s:
	dc.b	' BOS drive '
BOS_char_letter_s:
	dc.b	'x:',NUL
on_ACSI_s:
	dc.b	' using ACSI ',NUL
on_SCSI_s:
	dc.b	' using SCSI ',NUL
on_IDE_s:
	dc.b	' using IDE ',NUL
drive_ID_dot_LUN_s:
drive_id_digit_s:
	dc.b	'x.'
drive_lun_digit_s:
	dc.b	'y',NUL
point_crlf_s:
	dc.b	' .',CR,LF,NUL
	even
DOS_installed_s:
	dc.b	CR,LF,' installed DOS drive '
DOS_drive_letter_s:
	dc.b	'x:',NUL
	even
;
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
;
init_stack:		ds.l	512			;\/ after boot these
init_stk_top:		ds.l	1			;/\ add 31 M_frames
init_buff_1:		ds.b	256			;'' and this 15
M_frame_stack:		ds.b	16*sizeof_M_frame	;'' to these 16
M_frame_sp:		ds.l	1
loc_currbp_p_p:		ds.l	1
bp_drive_index:		ds.w	1
found_DOS:		ds.l	1
extra_path:		ds.b	PATH_limit
expanded_path:		ds.b	PATH_limit
;
module_init_d0:		ds.l	1
current_DOS:		ds.l	1
;
current_DTA:		ds.l	1
reent_retadr:		ds.l	1
reent_extra:		ds.l	1
saved_etv_term:		ds.l	1
b_61c1:			ds.b	130
b_6241:			ds.b	130
next_DOS_p:		ds.l	1
DOS_init_d1:		ds.l	1
dosdev2boschr_t:	ds.b	32
BOS_char_for_DOS:	ds.w	1			 ;=2
b_62ec:			ds.l	1			 ;=4
basepage_p:		ds.l	1			 ;=4
b_62f4:			ds.l	1			 ;=4
init_mod_handle:	ds.w	1			 ;=2
init_mod_file_len:	ds.l	1			 ;=4
b_62fe:			ds.l	8			 ;=32
Pexec_ph_buf:		ds.l	15			 ;=60
Pexec_basepage_p:	ds.l	1			 ;=4
Pexec_handle:		ds.w	1			 ;=2
b_6360:			ds.w	1			 ;=2
b_6362:			ds.l	1			 ;=4
TOS_patch_p:		ds.l	1			 ;=4
;
M_dta_count:		ds.w	1			 ;=2
M_dta_first:		ds.l	1
M_dta_last:		ds.l	1
M_dta_t:		ds.b	DTA_limit*sizeof_M_dta
;
meta_FCB_t:		ds.b	FCB_limit*sizeof_FCB
meta_DOS_t:		ds.b	DOS_limit*sizeof_DOS
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	BetaDOS.S
;----------------------------------------------------------------------------
