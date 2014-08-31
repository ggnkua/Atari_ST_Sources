;----------------------------------------------------------------------------
;File name:	xAFX.S			Revised:	1994.10.01
;Revised by:	Ulf Ronald Andersson	Revision date:	1992.08.19
;Copyright:	Thomas Quester		Revision code:	2.1.K
;File purpose:	Debugged source code for AFX real-time data unpacker
;----------------------------------------------------------------------------
;
	nolist
	include	URAn_SYS.S
	include	URAn_DOS.S
	include	URAn_XB.S
	nolist
;
;
debug_mode	=	1
final_mode	=	2
asm_mode	=	final_mode
;
pexec_levels	=	256
;
Kbyte		=	1024
;
def_FRUF_size	=	4*Kbyte
def_ir_size	=	20*Kbyte
dta_links	=	32
finfo_links	=	512
;
;----------------------------------------------------------------------------
;	finfo structure (file information: 1 block per handle)
;
		rsreset
fi_bfpos_p	rs.l	1	;00
fi_afx_handle	rs.w	1	;04
		rs.l	1	;06
		rs.w	1	;10
		rs.w	1	;12
		rs.w	1	;14
		rs.w	1	;16
		rs.w	1	;18
fi_bfsize	rs.l	1	;20
fi_FRUF_p	rs.l	1	;24
fi_CHEK_p	rs.l	1	;28
fi_filepos	rs.l	1	;32
		rs.l	1	;36
fi_orig_ftime	rs.l	1	;40
fi_orig_fsize	rs.l	1	;44
fi_nafx_handle	rs.w	1	;48
		rs.l	1	;52  only ref'd ???
		rs.b	12	;56..63  unused ???
fi_fspec_s	rs.b	1	;64  this string has varying size!
finfo_minsize	= __RS
;
;----------------------------------------------------------------------------
	text			;Start of program code
;----------------------------------------------------------------------------
;	Here follows resident start_up code
;	Which can be overlayed with data after boot
;
rz:	;relative zero for ref's
bp	=	rz-$100
start:
ir_base_p:				;ovl -> iram_base
	bsr	boot_test
intern_sp:				;ovl -> afx_gemdos stack
	bpl.w	perform_boot		;so use no short branch here !!!
gemdos_count:				;ovl .l counts afx_gemdos calls
	bsr	boot_err_disp
	gemdos	Pterm,?
;
perform_boot:
	bsr	boot_finish
	move.l	#(iram_base-data_base)/16-1,d6
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	lea	iram_base(pc),a0
	swap	d6
.clear_lp_1:
	swap	d6
.clear_lp_2:
	movem.l	d0-d3,-(a0)
	dbra	d6,.clear_lp_2
	swap	d6
	dbra	d6,.clear_lp_1
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	(_sysbase).w,a0
	move.l	os_selfbeg_p(a0),a0
	move	os_version(a0),d0
	move	d0,tos_version
	clr	new_tos_f
	cmp	#$0104,d0
	shs	new_tos_f
	move.l	os_currbp_p_p(a0),currbp_p_p
	gemdos	Super,()
	gemdos	Ptermres,a5,!
;
;	End of resident start_up code
;----------------------------------------------------------------------------
;	Here follow the XBRA_linked afx_GEMDOS entry/exit routines
;
	dc.l	ac_cookie_base-*
	XB_define	afx_gemdos_XB,<'AFX '>
	tst.b	ac_passive_f
	bne.s	go_next_dos
	addq.l	#1,gemdos_count
	move	USP,a0
	btst	#5,(sp)
	beq.s	.got_args
	move.l	sp,a0
	adda.l	st_frame_size(pc),a0
.got_args:
	move	(a0),d0		;d0  = gemdos command
	subq	#6,a0		;a0 -= 6
	cmp	#$31,d0		;lowest affected command
	blo.s	go_next_dos	;lower command uses old gemdos
	cmp	#$57,d0		;highest affected command
	bhi.s	go_next_dos	;higher command uses old gemdos
	sub	#$31,d0		;lowest command uses zero index
	move.l	(ev_gemdos).w,-(sp)		  ;\
	movem.l	d1-d7/a0-a6,-(sp)		  ;| This allows routines
	move.l	a0,a1				  ;| to call older gemdos
	move.l	afx_gemdos_XB+8(pc),(ev_gemdos).w ;/
	move.l	sp,a2
	move.l	intern_sp(pc),sp
	pea	(a2)
	move.l	sp,intern_sp
	add	d0,d0
	move	dos_tb(pc,d0),d0
	jmp	dz(pc,d0)
;
try_next_dos:
	cmp.l	intern_sp(pc),sp
	bne	stack_error_next
dz:	;relative zero for afxdos offsets
	move.l	(sp)+,sp
	addq.l	#4,intern_sp
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	(sp)+,(ev_gemdos).w
go_next_dos:
	XB_gonext_d	afx_gemdos_XB(pc)
;
dos_tb:
	dc.w	1*(afx_ptermres-dz),0,0,0,0,0,0			;31-37
	dc.w	0,0,1*(afx_ddelete-dz),0			;38-3B
	dc.w	1*(afx_fcreate-dz),1*(afx_fopen-dz)		;3C,3D
	dc.w	1*(afx_fclose-dz),1*(afx_fread-dz) 		;3E,3F
	dc.w	1*(afx_fwrite-dz),1*(afx_fdelete-dz)		;40,41
	dc.w	1*(afx_fseek-dz),0,0,0,0,0 			;42-47
	dc.w	0,0,0,1*(afx_pexec-dz),0,0			;48-4D
	dc.w	1*(afx_fsfirst-dz),1*(afx_fsnext-dz) 		;4E,4F
	dc.w	0,0,0,0,0,0					;50-55
	dc.w	1*(afx_frename-dz),1*(afx_fdatime-dz) 		;56,57
;
;
try_exit_dos:
	cmp.l	intern_sp(pc),sp
	bne.s	stack_error_exit
	move.l	(sp)+,sp
	addq.l	#4,intern_sp
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	(sp)+,(ev_gemdos).w
	rte
;
;
	dc.b	'Stack-error next',NUL
	even
stack_error_next:
	illegal
	move.l	intern_sp(pc),sp
	moveq	#-1,d0
	bra	try_next_dos
;
;
	dc.b	'Stack-error exit',NUL
	even
stack_error_exit:
	illegal
	move.l	intern_sp(pc),sp
	moveq	#-1,d0
	bra.s	try_exit_dos
;
;
st_frame_size:
	dc.l	0
;
;	End of afx_GEMDOS entry/exit routines
;----------------------------------------------------------------------------
;	Here follows the xAFX cookie parameter block
;	Extensions beyond AFX use negative offsets
;
ac_pseudo_drive:
	dc.w	'P'		;offs -6
ac_passive_f:			;offs -4
	dc.l	0		;top byte == 0 => active
ac_cookie_base:			;offs  0 =  Cookie base
	dc.l	'PARX'
	dc.l	6
	dc.l	200
ac_state:
	dc.l	3
ac_FRUF_size:
	dc.l	def_FRUF_size
ac_ir_size:
	dc.l	def_ir_size
ac_reserved_1:
	dc.l	0	;Unref
ac_L3D0:
	dc.l	$18A4	;Constant(iz)
ac_L3D4:
	dc.l	$0FD4	;Constant(iz)
ac_L3D8:
	dc.l	0	;Unref
ac_L3DC:
	dc.l	$27AA	;Unref Constant(iz) 
ac_instr_lim:
	dc.l	10	;Singleref loop Constant
ac_instr_tab:
	dcb.b	10*16,0	;Singleref table
	dc.w	1
;
;	End of xAFX cookie parameter block
;----------------------------------------------------------------------------
;	Here follow separate entry level afx_GEMDOS routines
;
afx_ptermres:
	move.l	currbp_p_p,a0	;a0 -> sysvar -> current bp
	move.l	(a0),a0		;a0 -> current bp
	move.l	a0,last_resident
	bra	try_next_dos
;
;
afx_pexec:
	tst	new_tos_f
	beq	try_next_dos		;afx programs need modern TOS
	move.l	a1,a6
	move	8(a6),d0		;d0=Pexec type
	beq.s	new_pexec_loadrun
	cmp	#3,d0
	bne	try_next_dos		;old tos for new/non_load modes
new_pexec_load:
	move.l	10(a6),d0
	ble	try_next_dos		;old tos for strange name pointer
	btst	#0,d0
	bne	try_next_dos		;old tos for strange name pointer
	bsr	pexec_load_sub		;load program
	bmi	try_next_dos		;on error (or non_afx), let old dos try
	bra	try_exit_dos		;exit if no error
;
new_pexec_loadrun:
	move.l	10(a6),d0
	ble	try_next_dos		;old dos for strange name pointer
	btst	#0,d0
	bne	try_next_dos		;old dos for strange name pointer
	bsr	pexec_load_sub		;load program
	tst.l	d0
	bmi	try_next_dos		;retry old dos after error
	move	#4,8(a6)		;force pexec run_only
	move.l	d0,14(a6)
	cmp.l	intern_sp(pc),sp
	bne	stack_error_pexec
pexec_exit:
	move.l	d0,a0
	move.l	bp_selfend_p(a0),a1
	move.l	a0,(a1)
	move.l	(sp)+,sp
	addq.l	#4,intern_sp
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	(sp)+,(ev_gemdos).w
	subq	#8,pexec_sp
	and	#(pexec_levels*8-1),pexec_sp
	lea	pexec_st(pc),a0
	add	pexec_sp(pc),a0
	move.l	d0,(a0)
	move.l	2(sp),4(a0)
	move.l	#post_pexec,2(sp)
	XB_gonext_d	afx_gemdos_XB(pc)
;
post_pexec:
	and	#(pexec_levels*8-1),pexec_sp
	lea	pexec_st(pc),a0
	add	pexec_sp(pc),a0
	move.l	4(a0),-(sp)
	move.l	d0,-(sp)
	move.l	(a0),d0
	addq	#8,pexec_sp
	cmp.l	last_resident(pc),d0
	beq.s	.keep_resident
	gemdos	Mfree|_ind,d0
.keep_resident:
	move.l	(sp)+,d0
	rts
;
;
	dc.b	'Stack-error Pexec',NUL
	even
stack_error_pexec:
	illegal
	move.l	intern_sp(pc),sp
	bra	pexec_exit
;
;
pexec_load_sub:
	gemdos	Fopen|_ind,10(a6),!
	tst.l	d0
	bmi	.exit
	move.l	d0,d3
	lea	pexec_chek(pc),a3
	gemdos	Fread,d3,#64,(a3)
	tst.l	d0
	bmi	.load_error
	move.l	a3,a0
	bsr	check_afx_head_a0
	bne	.load_error
	gemdos	Pexec|_ind,#5,!,14(a6),18(a6)
	tst.l	d0
	bmi.s	.load_error
	move.l	d0,a5
	move.l	bp_selfend_p(a5),d1
	sub.l	bp_selfbeg_p(a5),d1
	subq.l	#8,d1
	sub.l	#$2000,d1
	movep.w	14(a3),d0
	move.b	13(a3),d0
	swap	d0
	movep.w	12(a3),d0
	move.b	11(a3),d0
	cmp.l	d0,d1			;TPA sufficient
	ble.s	.pexec_error
	gemdos	Fseek,!,d3,#2
	move.l	d0,d4
	gemdos	Fseek,!,d3,!
	gemdos	Fread,d3,d4,$100(a5)
	gemdos	Fclose,d3
	move.l	a5,d0
	move.l	d4,d1
	bsr.s	APX_unpack
	move.l	a5,d0
.exit:
	rts
;
.pexec_error:
	gemdos	Mfree|_ind,a5
.load_error:
	gemdos	Fclose,d3
	moveq	#-1,d0
	rts
;
;
	include	APX_UNPK.S
;
;
afx_fopen:
	move.l	a1,-(sp)
	move.l	a1,a6
	gemdos	Fopen|_ind,8(a6),12(a6)	;open file using old gemdos
	move.l	d0,d7
	bmi	.open_exit_dos
	move.l	8(a6),a1		;a1 -> file spec
	move.l	a1,a0			;a0 -> file spec
	move.l	d0,d1
	bsr	release_finfo
	lea	unpack_handle(pc),a4
	move	d7,(a4)			;store handle
	move.l	ac_state(pc),d3
	btst	#0,d3
	beq	.open_fix_non_afx
	move.l	ac_FRUF_size(pc),d0
	add.l	#160,d0
	bsr	dual_malloc		;allocate a buffer
	dc.b	'FRUF'
	tst.l	d0
	ble	.open_fix_non_afx
	move.l	d0,a2			;a2 -> FRUF area
	clr.l	(a2)
	clr.l	4(a2)
	clr.l	8(a2)
	move.l	a2,a3
	adda.l	ac_FRUF_size(pc),a3	;a3 -> end of FRUF area
	moveq	#0,d3
	move.l	a2,a4
	adda.l	ac_FRUF_size(pc),a4	;a4 -> end of FRUF area
	moveq	#1,d6			;d6  = flag for WEIRD reader
	clr.l	d0			;prep d0 for header length byte
	bsr	read_afx_byte		;WEIRD read routine
; => d0 == headlen   a4 = a2 +1 -> FRUF base +1
	lea	-1(a4),a0		;a0 -> FRUF base
	bsr	check_afx_head_a0
	bne	.open_non_afx
	movep.w	9(a4),d6		;\
	move.b	8(a4),d6		;|
	swap	d6			; > d6  = original timestamp
	movep.w	7(a4),d6		;|
	move.b	6(a4),d6		;/
	movep.w	13(a4),d5		;\
	move.b	12(a4),d5		;|
	swap	d5			; > d5  = original size
	movep.w	11(a4),d5		;|
	move.b	10(a4),d5		;/
	lea	1(a4,d0),a4		;a4 += header length +1
	move.l	#$1000+160,d0
	bsr	dual_malloc
	dc.b	'CHEK'
	tst.l	d0
	ble.s	.open_non_afx
	move.l	d0,a5			;a5 -> CHEK base
	move.l	a5,a0			;a0 -> CHEK base
	move	#$FEE/4-1,d0		;\
	move.l	#'    ',d1		;|
.blank_lp:				; > blank $FEE bytes to spaces
	move.l	d1,(a0)+		;|
	dbra	d0,.blank_lp		;|
	move	d1,(a0)+		;/
	bsr	allocate_finfo_a1_a6
	bmi.s	.open_bad_afx
	move.l	ac_FRUF_size(pc),fi_bfsize(a6)
	move.l	a2,fi_FRUF_p(a6)
	move.l	a5,fi_CHEK_p(a6)
	clr.l	fi_filepos(a6)
	move.l	d6,fi_orig_ftime(a6)
	move.l	d5,fi_orig_fsize(a6)
	move.l	a4,d0
	sub.l	a2,d0
	move.l	d0,36(a6)
	clr	fi_nafx_handle(a6)
	move	#$1FF,d2
	move	#$FEE,d3
	moveq	#0,d5
	moveq	#-1,d1
	clr	d4
	lea	finfo_linktb(pc),a0
	move.l	d7,d0
	add.l	d0,d0
	add.l	d0,d0		;d0 = handle * 4
	move.l	a6,0(a0,d0)	;link finfo of current file
	move.l	a4,(a6)+	;bfpos_p.L	= a4
	move	d7,(a6)+	;afx_handle.W 	= d7
	move.l	d6,(a6)+	;finfo[06].l	= d6
	move	d2,(a6)+	;finfo[10].w	= d2
	move	d5,(a6)+	;finfo[12].w	= d5
	move	d3,(a6)+	;finfo[14].w	= d3
	move	d1,(a6)+	;finfo[16].w	= d1
	move	d4,(a6)+	;finfo[18].w	= d4
.open_exit_d7:
	move.l	d7,d0		;d0 = handle
.open_exit_dos:
	move.l	(sp)+,a1
	bra	try_exit_dos
;
;
.open_bad_afx:			;can't know whether afx or not due to RAM lack
	move.l	a5,d0
	bsr	dual_mfree
.open_non_afx:
	gemdos	Fseek,!,d7,!
	move.l	a2,d0
	bsr	dual_mfree
.open_fix_non_afx:
	move.l	(sp),a1
	move.l	8(a1),a1
	bsr	allocate_finfo_a1_a6
	bmi.s	.open_exit_d7
	lea	finfo_linktb(pc),a0
	move	d7,fi_nafx_handle(a6)
	clr.l	fi_filepos(a6)
	move.l	d7,d0
	add.l	d0,d0
	add.l	d0,d0
	move.l	a6,0(a0,d0)		;link finfo of current file
	bra.s	.open_exit_d7
;
;
afx_fcreate:
	move.l	a1,a6			;a6 -> arguments
	gemdos	Fcreate|_ind,8(a6),12(a6)
	move.l	d0,d7			;d7  = handle
	bmi	try_exit_dos
	move.l	d0,d1
	bsr	release_finfo
	move.l	8(a6),a1		;a1 -> file spec
	bsr	allocate_finfo_a1_a6	;create finfo
	bmi.s	.fcreate_exit_d7
	lea	finfo_linktb(pc),a0
	move	d7,fi_nafx_handle(a6)	;finfo[48].w = handle
	clr.l	fi_filepos(a6)		;finfo[32].l = 0
	move.l	d7,d0			;d0  = handle  (return value)
	add.l	d0,d0
	add.l	d0,d0
	move.l	a6,0(a0,d0)		;link finfo of current file
	lea	fi_fspec_s(a6),a1
	bsr	read_fsizer_a1
	bmi.s	.no_fsizer
	move.l	fsizer_area_p(pc),a0
	lea	fi_fspec_s(a6),a2
	bsr	remove_match_sizer_a0_a2
	bne.s	.not_in_fsizer
	bsr	write_fsizer_a0
.not_in_fsizer:
	bsr	mfree_fsizer_area
.no_fsizer:
.fcreate_exit_d7:
	move.l	d7,d0			;d0  = handle  (return value)
	bra	try_exit_dos
;
;
afx_fread:
	moveq	#0,d0
	move	8(a1),d0	;d0 = handle
	bmi	try_next_dos
	move.l	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	lea	finfo_linktb(pc),a0
	move.l	0(a0,d1),d1
	beq	try_next_dos
	move.l	d1,a0		;a0 -> finfo[0] of current file
	tst	fi_nafx_handle(a0)		;afx => 0  non_afx => handle
	bne.s	.read_non_afx
	move.l	10(a1),d0	;d0 = read count
	beq	try_exit_dos
	move.l	14(a1),a0	;a0 -> read buffer
	move.l	d1,a1		;a1 -> finfo of current file
	bsr	read_afx_block
	bra	try_exit_dos
;
;
.read_non_afx:
	cmp	fi_nafx_handle(a0),d0	;normal => handle==d0
	beq	try_next_dos
	move.l	a0,-(sp)
	gemdos	Fread|_ind,d0,10(a1),14(a1)
	move.l	(sp)+,a0
	add.l	d0,fi_filepos(a0)	;finfo[32].l += read size
	bra	try_exit_dos
;
;
afx_fwrite:
	moveq	#0,d0
	move	8(a1),d0	;d0 = handle
	bmi	try_next_dos
	move.l	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	lea	finfo_linktb(pc),a0
	move.l	(a0,d1),d1
	beq	try_next_dos		;use old dos if no finfo
	move.l	d1,a0			;a0 -> finfo[0] of current file
	tst	fi_nafx_handle(a0)	;afx => 0  non_afx => handle
	beq.s	.write_old_afx		;jump if known afx
	move.l	a0,a6			;a6 -> finfo[0] of file
	move	fi_nafx_handle(a6),8(a1)	;change handle argument ???
	tst.l	fi_filepos(a6)		;finfo[32].l 
	bne.s	.write_non_afx		;jump (non_afx) if not at file start
	move.l	14(a1),a0		;a0 -> write buffer
	bsr	check_afx_head_a0
	bne.s	.write_non_afx		;jump if writing non_afx
	movem.l	d0/a0-a1,-(sp)
;here to write new afx file (but only at file start)
	lea	fi_fspec_s(a6),a0
	move.l	14(a1),a1		;a1 -> write buffer
	bsr	write_new_afx
	movem.l	(sp)+,d0/a0-a1
	bra	try_next_dos
;
.write_non_afx:
	gemdos	Fwrite|_ind,fi_nafx_handle(a6),10(a1),14(a1)
	add.l	d0,fi_filepos(a6)
	bra	try_exit_dos
;
;
;here to write to a known afx file
.write_old_afx:
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	d1,a6
	move.l	fi_filepos(a6),d5	;d5 = finfo.fi_filepos
	move	d0,d6
	move.l	a6,a0
	bsr	respool
	bmi.s	.wolafx_create_err
	movem.l	a1-a2,-(sp)		;save a1-a2
	lea	fi_fspec_s(a6),a0
	lea	wr_afx_fname_s(pc),a1
	move.l	a1,a2		;a2 -> poss name pos
.L8E0:
	move.b	(a0)+,d0
	beq.s	.L8FC
	move.b	d0,(a1)+	;move path (no term) to (a1)+
	cmp.b	#'\',d0
	beq.s	.L8F4
	cmp.b	#':',d0
	bne.s	.L8E0
.L8F4:
	move.l	a1,a2		;a2 -> poss name pos
	bra.s	.L8E0
;
.L8FC:				;a2 -> name pos after path
	lea	._afxtmp_s(pc),a0
.L900:
	move.b	(a0)+,(a2)+			;set name part (incl term)
	bne.s	.L900
	movem.l	(sp)+,a1-a2			;pull a1-a2
	gemdos	Fcreate,wr_afx_fname_s(pc),!	;Create temp file
	move.l	d0,d7				;d7 = temp handle
	bmi.s	.wolafx_create_err
	bsr	dual_alloc_huge			;allocate unpacking buffer
	move.l	d0,a2			;a2 = d0 -> buffer base
	move.l	d1,d4			;d4 = d1 =  buffer size
.wr_unpack_afx_lp:
	move.l	d4,d0			;d0 = d4 =  buffer size
	move.l	a2,a0			;a0 = a2 -> buffer base
	move.l	a6,a1			;a1 = a6 -> finfo
	bsr	read_afx_block		;read and unpack an afx block
	tst.l	d0			;unpacked size OK ?
	ble.s	.wr_unpack_afx_eof
	move.l	a2,a0			;a0 = a2-> unpacked block
	move	d7,d1			;d1 = d7 = temp handle
	bsr	safe_fwrite_d1_d0_a0	;write the block unpacked
	tst.l	d0
	bpl.s	.wr_unpack_afx_lp
.wolafx_write_err
	move.l	d0,d7			;d7 = last error code
	bsr	safe_fclose_d1
	gemdos	Fdelete,wr_afx_fname_s(pc)
	move.l	d7,d0			;d0 = last error code
.wolafx_create_err:
	movem.l	(sp)+,d1-d7/a0-a6
	bra try_exit_dos
;
;
.wr_unpack_afx_eof:
	move.l	a2,d0
	bsr	dual_mfree		;release temp block
	move	fi_afx_handle(a6),d1
	bsr	safe_fclose_d1		;close read file  (packed)
	move.l	d7,d1
	bsr	safe_fclose_d1		;close write file (unpacked)
	gemdos	Fdelete,fi_fspec_s(a6)	;delete old packed file
	gemdos	Frename,!,wr_afx_fname_s(pc),fi_fspec_s(a6)
	lea	fi_fspec_s(a6),a1
	bsr	read_fsizer_a1
	bmi.s	.no_fsizer
	move.l	fsizer_area_p(pc),a0
	lea	fi_fspec_s(a6),a2
	bsr	remove_match_sizer_a0_a2
	bne.s	.not_in_fsizer
	bsr	write_fsizer_a0
.not_in_fsizer:
	bsr	mfree_fsizer_area
.no_fsizer:
	lea	fi_fspec_s(a6),a0
	movem.l	d2/a0-a2,-(sp)
	gemdos	Fopen,(a0),#2
	move.l	d0,d1			;d1 = handle of reopened file
	movem.l	(sp)+,d2/a0-a2
	move	d1,fi_nafx_handle(a6)
	clr	fi_afx_handle(a6)
	move.l	fi_CHEK_p(a6),d0
	bsr	dual_mfree
	clr.l	fi_CHEK_p(a6)
	move.l	fi_FRUF_p(a6),d0
	bsr	dual_mfree
	clr.l	fi_FRUF_p(a6)
	move	d1,-(sp)
	gemdos	Fseek,d5,d1,!		;reseek old file position
	move	(sp)+,d1
	move.l	d1,d0
	movem.l	(sp)+,d1-d7/a0-a6
	move	d0,d1			;d1 = handle
	move.l	10(a1),d0		;d0 = write size
	move.l	14(a1),a0		;a0-> write base
	bsr	safe_fwrite_d1_d0_a0	;finally the requested data write
	bra	try_exit_dos
;
;
._afxtmp_s:
	dc.b	'_afxtmp_.$$$',NUL
	even
;
;
afx_fseek:
	btst	#0,ac_state+3
	beq	try_next_dos
	move	12(a1),d0		;d0 = handle
	bmi	try_next_dos
	move	d0,d1
	add	d1,d1
	add	d1,d1
	lea	finfo_linktb(pc),a0
	move.l	0(a0,d1),d1		;d1-> finfo, or is null
	beq	try_next_dos
	move.l	d1,a0			;a0-> finfo
	tst	fi_nafx_handle(a0)
	bne.s	.fseek_non_afx
	move.l	8(a1),d0		;d0 = seek offset
	move	14(a1),d1		;d1 = seek base, 0=beg 1=pos 2=end
	bsr	fseek_afx
	bra	try_exit_dos
;
.fseek_non_afx:
	move.l	a6,-(sp)
	move.l	a0,a6
	gemdos	Fseek,8(a1),fi_nafx_handle(a6),14(a1)
	move.l	d0,fi_filepos(a6)
	move.l	(sp)+,a6
	bra	try_exit_dos
;
;
afx_fclose:
	move	8(a1),d0
	bsr	close_finfo
	bra	try_exit_dos
;
;
afx_fsnext:
	gemdos	Fsnext			;use old dos to fill dta preliminarily
	bsr	fs_hide_fsizer		;but also hide any filesizers
	move.l	d0,d5			;d5 = error code
	bmi.s	.fsnext_exit		;return as_is on errors
	move.l	ac_state(pc),d0
	btst	#1,d0
	beq.s	.fsnext_exit		;exit as_is if PACK or FAST mode
	bsr	safe_fgetdta		;d0 -> current dta
	cmp.l	fsizer_dta_p(pc),d0
	bne.s	.force_read		;force read if dta not same as in last fsfirst
	move.l	fsizer_area_p(pc),d1	;d1 -> current fsizer area
	bmi.s	.fsnext_exit		;exit if no fsizer file available
	beq.s	.force_read		;force read if no fsizer active
	move.l	fsizer_count(pc),d1
	cmp.l	fsizer_fs_id(pc),d1
	beq.s	.keep_read		;skip read if needed fsizer == current
.force_read:
	lea	fsizer_dta_p(pc),a0
	move.l	d0,(a0)			;register dta change
	suba.l	a0,a0			;a0 = 0 flags search for old dta link
	bsr	link_d0_dta_path_a0	;find the link cell for this dta
	ble.s	.fsnext_exit	
	move.l	d0,a1
	addq	#4,a1			;a1 -> full path for fsizer
	bsr	read_fsizer_a1		;read fsizer
	bmi.s	.fsnext_exit		;exit as_is if no fsizer available
	move.l	fsizer_count(pc),fsizer_fs_id	;make new fsizer current
.keep_read:
	gemdos	Fgetdta
	move.l	d0,a1
	lea	dta_fname(a1),a2
	move.l	fsizer_area_p(pc),a0
	bsr	match_sizer_a0_a2
	bne.s	.fsnext_exit
;;;patch	move.l	14(a0),d0
;;;patch	cmp.l	dta_ftime(a1),d0
;;;patch	bne.s	.fsnext_exit
	move.l	18(a0),dta_fsize(a1)
.fsnext_exit:
	move.l	d5,d0
	bra	try_exit_dos
;
;
fsizer_fs_id:
	dc.l	0
fsizer_count:
	dc.l	$AA553CC3
fsizer_area_p:
	dc.l	-1
fsizer_dta_p:
	dc.l	0
filesize_afx_s:
	dc.b	'FILESIZE.AFX',NUL,NUL
;
;
afx_fsfirst:
	bsr	mfree_fsizer_area
	clr.l	fsizer_area_p
	clr.l	fsizer_dta_p
	move.l	8(a1),a5		;a5 -> fspec
	gemdos	Fsfirst|_ind,a5,12(a1)
	bsr	fs_hide_fsizer
	move.l	d0,d5			;d5 = error code
	bmi	.fsfirst_unlink
.link_sizer:
	move.l	a5,a1			;a1 -> fspec
	bsr	complete_path_ia1_bf1
	move.l	d0,a1			;a1 -> name part of bf1
	clr.b	(a1)			;link pure path only
	lea	path_bf1(pc),a0		;prep link allocation
	move.l	ac_state,d0
	btst	#0,d0
	beq	.fsfirst_exit		;exit if PACK mode
	btst	#1,d0
	beq.s	.fast_sizer		;skip linking if FAST mode
.show_sizer:
	bsr	link_cur_dta_path_a0
.fast_sizer:
;Use original (unpacked) filesize for FAST or SHOW mode
	move.l	d0,a6
	addq	#4,a6			;a6 -> complete path in dta link
	move.l	#512,d0
	bsr	dual_malloc
	dc.b	'CHEK'
	tst.l	d0
	ble	.fsfirst_exit		;exit if no RAM
	move.l	d0,a3			;a3 -> CHEK area
	gemdos	Fgetdta
	move.l	d0,a0			;a0 -> current dta base
	lea	dta_fname(a0),a4	;a4 -> current dta fname
	lea	dta_fsize(a0),a5	;a5 -> current dta_fsize
	move.l	a6,a0			;a0 -> full path
	move.l	a3,a1			;a1 -> fname buffer == CHEK area
	moveq	#124-1,d0
.LBBE:
	move.b	(a0)+,(a1)+		;move full path into CHEK area
	dbeq	d0,.LBBE
	clr.b	-(a1)
	moveq	#14-1,d0
.LBD2:
	move.b	(a4)+,(a1)+		;move found name into fname part of CHEK area
	dbeq	d0,.LBD2
	clr.b	-(a1)
	gemdos	Fopen,(a3),!		;Open file
	move.l	d0,d3
	bmi.s	.fsfirst_mfree		;release RAM & exit on read error
	gemdos	Fread,d3,#512,(a3)	;Read header of file into CHEK area
	move.l	d0,d4
	gemdos	Fclose,d3		;Close file
	tst.l	d4
	bmi.s	.fsfirst_mfree		;release RAM & exit on read error
	move.l	a3,a0			;a0 -> base of CHEK area
	bsr	check_afx_head_a0
	bne.s	.fsfirst_mfree		;release RAM & exit if not AFX
	movep.w	14(a0),d1
	move.b	13(a0),d1
	swap	d1
	movep.w	12(a0),d1
	move.b	11(a0),d1
	move.l	d1,(a5)			;store unpacked file size in dta
.fsfirst_mfree:
	move.l	a3,d0			;d0 -> base of CHEK area
	bsr	dual_mfree
.fsfirst_exit:
	move.l	d5,d0			;d0 = return code
	bra	try_exit_dos
;
.fsfirst_unlink:
	move	#-1,a0			;prep link release for error case
	bsr	link_cur_dta_path_a0
	bra.s	.fsfirst_exit
;
;
afx_fdelete:
	move.l	8(a1),a0	;a0 -> fspec
	bsr.s	sub_fdelete_a0
	cmp.l	#'xAFX',d0
	beq	try_next_dos
	bra	try_exit_dos
;
;
	ifne	asm_mode=debug_mode
	dc.b	'SUB_FDELETE'
	even
	endc
;
sub_fdelete_a0:				;a0 -> fspec
	movem.l	d1-d7/a0-a6,-(sp)
	lea	rz,a6			;a6 -> relative zero
	move.l	a0,a5			;a5 -> fspec
	move.l	#'xAFX',d5		;d5  = unique internal error flag
	bsr	safe_fgetdta
	move.l	d0,a4			;a4 -> entry dta
	lea	locdta_base(pc),a0
	bsr	safe_fsetdta_a0
	move.l	a5,a1			;a1 -> fspec
	bsr	complete_path_ia1_bf3	;complete path 'upped' into bf3
	bne.s	.fdelete_exit		;exit if illegal fspec
	move.l	d0,d6			;d6 -> name part of fspec in bf3
	move.l	a5,a1			;a1 -> fspec
	bsr	read_fsizer_a1
	bmi.s	.fdelete_exit		;exit if no fsizer found
	gemdos	Fsfirst,(a5),#$2F	;find deleteables
	lea	locdta_base(pc),a0
	bsr	fs_rehide_fsizer_a0
	move.l	d0,d5
	bmi.s	.fdelete_exit		;exit if no file found
	moveq	#-1,d7			;indicate no filesize removals
.fdelete_wildloop:
	lea	locdta_fname(pc),a0	;a0 -> found name in locdta
	move.l	d6,a1			;a1 -> name pos in bf3
	moveq	#14-1,d0		;limit move to max 14 char's
.fdelete_setname:
	move.b	(a0)+,(a1)+
	dbeq	d0,.fdelete_setname	;loop back to set entire name
	clr.b	-1(a1)
	gemdos	Fdelete,path_bf3(pc)		;delete the actual file
	tst.l	d0			;remember any deletion errors
	bpl.s	.fdelete_remove
	move.l	d0,d5			;d5  = latest actual error
	bra.s	.fdelete_nextwild
;
.fdelete_remove:
	move.l	fsizer_area_p(pc),a0	;a0 -> fsizer structure
	move.l	d6,a2			;a2 -> fname to remove
	bsr	remove_match_sizer_a0_a2
	and	d0,d7			;indicate any removal success
.fdelete_nextwild:
	gemdos	Fsnext
	lea	locdta_base(pc),a0
	bsr	fs_rehide_fsizer_a0
	tst.l	d0
	bpl.s	.fdelete_wildloop
	tst	d7
	bmi.s	.fdelete_exit		;skip writing filesize if none removed
	move.l	fsizer_area_p(pc),a0
	bsr	write_fsizer_a0
.fdelete_exit:
	bsr	mfree_fsizer_area
	move.l	a4,a0			;a0 -> entry dta
	bsr	safe_fsetdta_a0
	move.l	d5,d0			;d0  = exit error code
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;
afx_ddelete:
	bsr	complete_path_ia1_bf2
	bne	try_next_dos
	lea	path_bf2(pc),a0
	move.l	8(a1),a5
.ddelete_1:
	tst.b	(a0)+
	bne.s	.ddelete_1
	subq	#1,a0
	move.b	#'\',(a0)+
	move.l	a0,a3			;a3 -> name part
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b	(a0)
	bsr	safe_fgetdta
	move.l	d0,a4			;a4 -> entry dta
	move.l	#'xAFX',d5		;d5 = unique internal error flag
	lea	locdta_base(pc),a0
	bsr	safe_fsetdta_a0
	lea	path_bf2(pc),a0
	moveq	#$2F,d0
	bsr	safe_fsfirst_a0_d0
	lea	locdta_base(pc),a0
	bsr	fs_rehide_fsizer_a0
	bne.s	.ddelete_exit		;exit if no fsizer
	tst.l	d0
	bpl.s	.ddelete_exit		;exit if other files
	lea	filesize_afx_s(pc),a0
.ddelete_setname:
	move.b	(a0)+,(a3)+
	bne.s	.ddelete_setname
	gemdos	Fdelete,path_bf2(pc)
	move.l	d0,d5
.ddelete_exit:
	move.l	a4,a0
	bsr	safe_fsetdta_a0
	move.l	d5,d0
	bpl	try_next_dos
	bra	try_exit_dos
;
;
afx_fdatime:
	moveq	#0,d0
	move	12(a1),d0
	move.l	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	lea	finfo_linktb(pc),a0
	move.l	0(a0,d1),d1
	beq	try_next_dos
	move.l	d1,a0
	move	fi_nafx_handle(a0),d0
	bne.s	.LDE0
	move	fi_afx_handle(a0),d0
.LDE0:
	tst	14(a1)
	beq	try_next_dos
	move.l	8(a1),a4
	lea	fi_fspec_s(a0),a1
	bsr	read_fsizer_a1
	bmi.s	.fdatime_exit
	move.l	a1,a2
	move.l	fsizer_area_p(pc),a0
	bsr	match_sizer_a0_a2
	bne.s	.LE0E
	move.l	(a4),14(a0)
	move.l	fsizer_area_p(pc),a0
	bsr	write_fsizer_a0
.LE0E:
	bsr	mfree_fsizer_area
.fdatime_exit:
	bra	try_next_dos
;
;
afxstate_afx_s:
	dc.b	'AFXSTATE.AFX',NUL
	even
afxparam_afx_s:
	dcb.b	14,NUL
;
afx_frename:
	move.l	a1,a3
	move.l	10(a3),a1		;a1 -> ol_fspec
	bsr	complete_path_ia1_bf3	;ol_fspec completed uppercase in bf3
	move.l	d0,d4			;d4 -> name part of ol_fspec
	move.l	14(a3),a1		;a1 -> nu_fspec
	bsr	complete_path_ia1_bf1	;nu_spec completed uppercase in bf1
	move.l	d0,d5			;d5 -> name part of nu_fspec
	move.l	d4,a0			;a0 -> name in nu_fspec
	lea	afxstate_afx_s(pc),a1
.state_tst_1:
	move.b	(a0)+,d0
	beq.s	.state_tst_2
	cmp.b	(a1)+,d0
	beq.s	.state_tst_1
	subq	#1,a1
.state_tst_2:
	cmp.b	(a1)+,d0
	bne.s	.normal_rename		;normal rename if ol_fspec is wrong
	move.l	d5,a0			;a0 -> name in ol_fspec
	lea	afxparam_afx_s(pc),a1	;a1 -> test_buffer
	moveq	#12-1,d0
.state_tst_3:
	move.b	(a0)+,(a1)+		;copy name to test_buffer
	dbeq	d0,.state_tst_3
	beq.s	.normal_rename		;normal rename if nu_fspec too short
	tst.b	(a1)
	bne.s	.normal_rename		;normal rename if nu_fspec too long
	lea	afxparam_afx_s(pc),a1	;a1 -> test_buffer
	move.l	(a1)+,d0
	move.l	(a1)+,d1
	move.l	(a1)+,d2
	cmp.l	#'AFX_',d0
	bne.s	.normal_rename
	clr.l	d0			;pre_clear return value
	cmp.l	#'.AFX',d2
	beq	.state_command
.normal_rename:
	move.l	10(a3),a1		;a1 -> ol_fspec
	bsr	read_fsizer_a1
	bmi	try_next_dos		;use old dos if no fsizer
	lea	path_bf1(pc),a0		;a0 -> full path of nu_fspec
	gemdos	Fsfirst,(a0),#$3F
	tst.l	d0
	bpl	try_next_dos		;let old dos report name conflict
	lea	path_bf3,a0		;a0 -> ol_fspec
	lea	path_bf1,a1		;a1 -> nu_fspec
	cmpm.w	(a0)+,(a1)+		;drive specifier 'x:' must be same
	bne	try_next_dos		let old dos report drive conflict
.path_cmp:
	cmp.l	a0,d4
	beq.s	.ol_cmpend
	cmp.l	a1,d5
	beq.s	.pathdiff
	cmpm.b	(a0)+,(a1)+
	beq.s	.path_cmp
	bra.s	.pathdiff
;
.ol_cmpend:
	cmp.l	a1,d5
	bne.s	.pathdiff
	move.l	fsizer_area_p(pc),a0
	move.l	d4,a2			;a2 -> name part of ol_fspec
	bsr	match_sizer_a0_a2
	bne.s	.no_match
	move.l	d5,a1			;a1 -> name part of nu_fspec
.LE54:
	move.b	(a1)+,(a0)+		;replace name in fsizer
	bne.s	.LE54
	move.l	fsizer_area_p(pc),a0
	bsr	write_fsizer_a0
.no_match:
	bsr	mfree_fsizer_area
	bra	try_next_dos
;
;
.pathdiff:
	move.l	fsizer_area_p(pc),a0
	move.l	d4,a2			;a2 -> name part of ol_fspec
	bsr	match_sizer_a0_a2
	bne.s	.no_match
	move.l	d5,a1			;a1 -> name part of nu_fspec
	lea	filesize_recbf(pc),a3	;a3 -> record buffer
	moveq	#14-1,d0
.new_rec_1:
	move.b	(a1)+,(a3)+
	dbra	d0,.new_rec_1
	lea	14(a0),a1		;a1 -> data of ol_fspec record
	moveq	#8-1,d0
.new_rec_2:
	move.b	(a1)+,(a3)+
	dbra	d0,.new_rec_2
	bsr	remove_match_sizer_a0_a2
	move.l	fsizer_area_p(pc),a0
	bsr	write_fsizer_a0
	bsr	mfree_fsizer_area
	lea	path_bf1(pc),a1	;a1 -> nu_fspec
	bsr	read_fsizer_a1
	bpl.s	.LED0
	lea	filesize_recbf(pc),a0
	bsr	write_fsizer_a0
	bsr	mfree_fsizer_area
	bra	try_next_dos
;
.LED0:
	bsr	fcreate_bf2_d1
	move.l	fsizer_area_p(pc),a0
	move.l	d5,a2			;a2 -> name part of nu_fspec
	bsr	match_sizer_a0_a2
	movem.l	22(a0),d3		;d3  = part of next entry w/o flags
	beq.s	.keep_it
	clr.l	d3			;d3  = final (NULL) entry
.keep_it:
	lea	filesize_recbf(pc),a1	;\
	moveq	#22-1,d0		;|
.move_it:					; > loop to move record to fsizer area
	move.b	(a1)+,(a0)+		;|
	dbra	d0,.move_it		;/
	move.l	d3,(a0)			;fix next entry  (end mark at appends)
	move.l	fsizer_area_p(pc),a0
	bsr	write_fsizer_a0
	bsr	mfree_fsizer_area
	bra	try_next_dos
;
.state_command:
	cmp.l	#'SHOW',d1
	beq.s	command_SHOW
	cmp.l	#'FAST',d1
	beq.s	command_SHOW
	cmp.l	#'PACK',d1
	beq.s	command_PACK
	cmp.l	#'PASS',d1
	beq.s	command_PASS
;;;patch new command tests here
	bra	try_exit_dos
;
command_PASS:
	st	ac_passive_f
	move.l	#3,ac_state
	bra	try_exit_dos
;
command_PACK:
	sf	ac_passive_f
	move.l	#0,ac_state
	bra	try_exit_dos
;
command_FAST:
	sf	ac_passive_f
	move.l	#1,ac_state
	bra	try_exit_dos
;
command_SHOW:
	sf	ac_passive_f
	move.l	#3,ac_state
	bra	try_exit_dos
;
;	End of entry level afx_GEMDOS routines
;----------------------------------------------------------------------------
;	Here follow general subroutines
;
fs_hide_fsizer:	;d0 = err_code of previous fsfirst or fsnext
	movem.l	d1-d2/a0-a2,-(sp)
	clr.l	d1
	bra.s	fs_hide_common
;
fs_rehide_fsizer_a0:			;d0 = previous err_code  a0 -> dta
	movem.l	d1-d2/a0-a2,-(sp)
	moveq	#-1,d1
fs_hide_common:
	tst.l	d0
	bmi.s	.hide_exit
	tst.l	d1
	bmi.s	.fs_rehide
	bsr	safe_fgetdta
	move.l	d0,a0
.fs_rehide:
	lea	dta_fname(a0),a0	;a0 -> fname
	lea	filesize_afx_s(pc),a1	;a1 -> "FILESIZE.AFX"
	clr.l	d0
.strcmp_loop:
	tst.b	(a1)
	beq.s	.strcmp_test
	cmpm.b	(a1)+,(a0)+
	beq.s	.strcmp_loop
	bra.s	.strcmp_exit
;
.strcmp_test
	tst.b	(a0)
.strcmp_exit:
	bne.s	.hide_exit
	gemdos	Fsnext
	cmp	d0,d0			;eq flags hide operation
.hide_exit:
	movem.l	(sp)+,d1-d2/a0-a2
	rts	;eq == hide  ne == nohide  d0 == error code
;
;
fcreate_bf2_d1:
	movem.l	d0/d2/a0-a2,-(sp)
	gemdos	Fcreate,path_bf2(pc),!
	move.l	d0,d1
	movem.l	(sp)+,d0/d2/a0-a2
	rts
;
;
read_fsizer_a1:
	movem.l	d1-d3/a0-a2,-(sp)
	addq	#1,fsizer_count
	bsr	mfree_fsizer_area
	bsr	fsizer_spec_ia1_bf2
	gemdos	Fopen,path_bf2(pc),!
	move.l	d0,d1			;d1 = handle
	move.l	d0,d3			;d3 = handle/errcode
	bmi.s	.rd_fs_open_err
	moveq	#2,d0
	moveq	#-1,d2
	bsr	safe_fseek_d2_d1_d0
	move.l	d0,d3
	bmi.s	.rd_fs_seek_err
	move.l	d0,a0			;a0 = file size -1
	clr.l	d0
	clr.l	d2
	bsr	safe_fseek_d2_d1_d0
	move.l	d0,d3
	bmi.s	.rd_fs_seek_err
	move.l	a0,d2			;d2 = file size -1
	addq.l	#1,d2			;d2 = file size
	move.l	d2,d0
	add.l	#26,d0			;d0 = file size + sizeof(record+endmark)
	bsr	dual_malloc
	dc.b	'XDIR'
	move.l	d0,d3
	ble.s	.rd_fs_seek_err
	move.l	d0,a1
	move.l	a1,a0
	move.l	d2,d0
	bsr	safe_fread_d1_d0_a0
	move.l	d0,d3
	bmi.s	.rd_fs_seek_err
	move.l	a1,d3
.rd_fs_seek_err:
	bsr	safe_fclose_d1
.rd_fs_open_err:
	move.l	d3,fsizer_area_p
	move.l	d3,d0
	movem.l	(sp)+,d1-d3/a0-a2
	rts
;
;
block_fsizer_area:
	movem.l	d0/a0,-(sp)
	lea	fsizer_area_p(pc),a0
	move.l	(a0),d0
	ble.s	.can_block
	bsr	dual_mfree
.can_block:
	move.l	#-1,(a0)
	movem.l	(sp)+,d0/a0
	rts
;
;
mfree_fsizer_area:
	movem.l	d0/a0,-(sp)
	lea	fsizer_area_p(pc),a0
	move.l	(a0),d0
	ble.s	.is_free
	clr.l	(a0)
	bsr	dual_mfree
.is_free:
	movem.l	(sp)+,d0/a0
	rts
;
;
remove_match_sizer_a0_a2:
	movem.l	a0-a1,-(sp)
	bsr.s	match_sizer_a0_a2
	bne.s	.L111A
	tst.l	(a0)
	beq.s	.L111A		;exit if no records
.L10FC:
	lea	22(a0),a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move	(a1)+,(a0)+
	tst.l	(a0)
	bne.s	.L10FC
.L111A:
	movem.l	(sp)+,a0-a1
	rts			;flag ne == no match,  eq = match removed
;
;
match_sizer_a0_a2:	;a0 -> area /<2  a0 -> file_x structure[22]  a2 -> path_y
	movem.l	a3-a5,-(sp)		;protect a3/a4
	moveq	#-1,d0
	cmp.l	#0,a0
	ble.s	.matcher_exit
	tst.l	(a0)
	beq.s	.matcher_exit
	move.l	a2,a3
	exg	a0,a3
	bsr.s	cut_path_name_a0
	exg	a0,a3			;a3 -> file_y
	move.l	a3,a5			;a5 -> file_y
.matcher_lp1:				;loop 1
	move.l	a5,a3			;a3 -> file_y
	move.l	a0,a4			;a4 -> file_x
.matcher_lp2:				;loop 2
	tst.b	(a3)
	beq.s	.matcher_test		;exit loop at string_y end
	tst.b	(a4)
	beq.s	.matcher_test		;exit loop at string_x end
	cmpm.b	(a3)+,(a4)+
	beq.s	.matcher_lp2		;loop 2 back until strings diff or end
;here a3/a4 -> at string terminator (poss diff), or beyond string diff
.matcher_next:
	lea	22(a0),a0		;a0 -> next entry in structure
	tst.l	(a0)
	bne.s	.matcher_lp1		;loop 1 back until a0 structure ends
	bra.s	.matcher_exit		;go exit ne on mismatch
;
.matcher_test:
	tst.b	(a3)
	bne.s	.matcher_next
	tst.b	(a4)
	bne.s	.matcher_next
	clr.l	d0		;flag eq to return found match in a0
.matcher_exit:
	tst.l	d0
	movem.l	(sp)+,a3-a5
	rts		;return eq,pl,a0->match  or  ne,mi,a0->end_mark
;
;
cut_path_name_a0:
	movem.l	d0/a2,-(sp)
	move.l	a0,a2
L10D8:
	move.b	(a0)+,d0
	beq.s	L10EC
	cmp.b	#':',d0
	beq.s	L10E8
	cmp.b	#'\',d0
	bne.s	L10D8
L10E8:
	move.l	a0,a2
	bra.s	L10D8
;
L10EC:
	move.l	a2,a0
	movem.l	(sp)+,d0/a2
	rts
;
;
write_fsizer_a0:				;a0 -> filesize record
	movem.l	d0-d2/a0-a2,-(sp)
	cmp.l	#1,a0
	ble.s	.L1158		;exit if no record present
	move.l	a0,a1
	tst.l	(a1)
	beq.s	.L115E		;just fdelete(path_bf2) if first record NULL
.L1132:				;loop start to pass all records
	lea	22(a1),a1		;a1 -> next record
	tst.l	(a1)			;final record (NULL) ?
	bne.s	.L1132		;loop back to pass all records
	move.l	a1,d2		;d2 -> final (NULL) record
	sub.l	a0,d2		;d2  = total size of records
	move.l	a0,a2		;a2 -> first record
	bsr	fcreate_bf2_d1
	tst.l	d1
	bmi.s	.L1158		;exit on error
	move.l	a2,a0		;a0 -> first record
	move.l	d2,d0		;d0 = total size of records
	addq.l	#4,d0		;d0 = total size including end mark
	bsr	safe_fwrite_d1_d0_a0
	bsr	safe_fclose_d1
.L1158:
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
.L115E:
	gemdos	Fdelete,path_bf2(pc)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;
write_new_afx:
	movem.l	d0/a0-a4,-(sp)
	move.l	a1,a3
	move.l	a0,a1
	bsr	read_fsizer_a1
	bpl.s	.match_it
	lea	filesize_recbf(pc),a0
	move.l	a0,a4
	bra.s	.append_it
;
.match_it:
	move.l	fsizer_area_p(pc),a0
	move.l	a0,a4
	move.l	a1,a2
	bsr	match_sizer_a0_a2
	beq.s	.keep_it			;go replace found match
.append_it:
	clr.l	22(a0)			;make new end mark
.keep_it:
	bsr	safe_fgetdta
	move.l	d0,-(sp)		;save -> entry dta
	move.l	a0,-(sp)		;save -> found match or end marker
	lea	locdta_base(pc),a0
	bsr	safe_fsetdta_a0
	move.l	a1,a0
	moveq	#$3F,d0
	bsr	safe_fsfirst_a0_d0
	lea	locdta_fname(pc),a1
	move.l	(sp)+,a0		;pull a0 -> found match or end marker
	move.l	(a1)+,(a0)+	;\
	move.l	(a1)+,(a0)+	; \ copy 14 char's fname
	move.l	(a1)+,(a0)+	; /
	move	(a1)+,(a0)+	;/
	movep.w	14(a3),d0		;\
	move.b	13(a3),d0		;|
	swap	d0			; > d0 = original size
	movep.w	12(a3),d0		;|
	move.b	11(a3),d0		;/
	move.l	locdta_ftime(pc),(a0)+	;copy 4 bytes date & time
	move.l	d0,(a0)+		;store 4 bytes fsize
	move.l	a4,a0
	bsr	write_fsizer_a0
	bsr	mfree_fsizer_area
	move.l	(sp)+,a0		;pull a0 -> entry dta
	bsr	safe_fsetdta_a0
	movem.l	(sp)+,d0/a0-a4
	rts
;
;
fsizer_spec_ia1_bf2:		;a1 -> fspec
	movem.l	d0/a1-a2,-(sp)
	bsr.s	complete_path_ia1_bf2
	move.l	d0,a2
	lea	filesize_afx_s(pc),a1
.fill_name:
	move.b	(a1)+,(a2)+
	bne.s	.fill_name
	movem.l	(sp)+,d0/a1-a2
	rts
;
;
complete_path_ia1_ia0:		;a1 -> fspec  =>  a0 -> full pathname
	movem.l	d1-d3/a0-a2,-(sp)
	bra.s	complete_path_common
;
complete_path_ia1_bf1:		;a1 -> fspec
	movem.l	d1-d3/a0-a2,-(sp)
	lea	path_bf1(pc),a0
	bra.s	complete_path_common
;
complete_path_ia1_bf2:		;a1 -> fspec
	movem.l	d1-d3/a0-a2,-(sp)
	lea	path_bf2(pc),a0
	bra.s	complete_path_common
;
complete_path_ia1_bf3:		;a1 -> fspec
	movem.l	d1-d3/a0-a2,-(sp)
	lea	path_bf3(pc),a0
complete_path_common:
	clr	d0
	clr	d2
	clr	d3
	move.l	a1,a2
	move.b	(a2)+,d0
	beq.s	.no_nothing
	cmp.b	#'\',d0
	beq.s	.no_drive_has_root
	move.b	(a2)+,d1
	beq.s	.no_nothing
	cmp.b	#':',d1
	bne.s	.no_drive_no_root
	bclr	#5,d0
	addq	#2,a1
	move.b	(a2)+,d2
	bra.s	.has_drive
;
.no_drive_no_root:
	cmp.b	#'\',d1
	beq.s	.no_nothing
	move.b	(a2)+,d2
	beq.s	.no_nothing
	cmp.b	#'\',d2
	beq.s	.no_nothing
	cmp.b	#':',(a2)
	seq	d3
	beq.s	.has_device
.no_nothing:
.no_drive_has_root:
	move	d0,d2
	movem.l	d2/a0-a1,-(sp)
	gemdos	Dgetdrv
	movem.l	(sp)+,d2/a0-a1
	add.b	#'A',d0
	moveq	#':',d1
.has_drive:
	move.b	d0,(a0)+
	move.b	d1,(a0)+
	cmp.b	#'\',d2
	beq.s	.has_drive_has_root
	movem.l	a0-a1,-(sp)
	sub.b	#'@',d0
	gemdos	Dgetpath,(a0),d0
	movem.l	(sp)+,a0-a1
.pass_path:
	tst.b	(a0)+
	bne.s	.pass_path
	move.b	#'\',-1(a0)
.has_drive_has_root:
.has_device:
	move	#256-3,d1
.poss_name:
	move.l	a0,a2
.fill_path:
	move.b	(a1)+,d0
	cmp.b	#'a',d0
	blt.s	.upped
	cmp.b	#'z',d0
	bgt.s	.upped
	bclr	#5,d0
.upped:
	move.b	d0,(a0)+
	beq.s	.path_full
	cmp.b	#'\',d0
	beq.s	.poss_name
	cmp.b	#':',d0
	beq.s	.poss_name
	dbra	d1,.fill_path
.path_full:
	clr.b	-(a0)
	move.l	a2,d0
	tst	d3
	movem.l	(sp)+,d1-d3/a0-a2
	rts		;return  ne(device)  eq(file) with d0 -> name part
;
;
allocate_finfo_a1_a6:
	moveq	#finfo_minsize+2,d0
	move.l	a1,a0
.finfo_lentest:
	tst.b	(a0)+
	bne.s	.finfo_lentest
	add.l	a0,d0
	sub.l	a1,d0
	addq.l	#1,d0
	and.l	#-2,d0
	bsr	dual_malloc
	dc.b	'FILE'
	move.l	d0,a6
	tst.l	d0
	ble.s	.allocate_finfo_exit
	move.l	a6,a0
	moveq	#fi_fspec_s-1,d0
.L1314:				;loop to clear finfo[0..63]
	clr.b	(a0)+
	dbra	d0,.L1314	;loop back for each byte
	move.l	a2,-(sp)
	lea	fi_fspec_s(a6),a2
	move.l	a1,a0
.L1324:				;loop to fill finfo[64..] with fname_s
	move.b	(a0)+,d0
	beq.s	.L1330
	cmp.b	#'a',d0
	blt.s	.upped
	cmp.b	#'z',d0
	bgt.s	.upped
	bclr	#5,d0
.upped:
	move.b	d0,(a2)+
	bra.s	.L1324
;
.L1330:
	clr.b	(a2)
.allocate_finfo_exit:
	move.l	(sp)+,a2
	rts
;
;
;link_cur_dta_path_a0 performs three different tasks depending on a0
;a0 = -1	=> old dta link released
;a0 =  0	=> old dta link found and returned in d0  (-1 if absent)
;a0 -> path	=> new dta link defined  (after releasing old)
;		these operations relate to the current dta
;link_d0_dta_path_a0  performs similarily for arbitrary dta's: d0 -> dta
;
link_cur_dta_path_a0:			;a0 -> path of dta  or  0  or  -1
	bsr	safe_fgetdta		;d0 -> dta
link_d0_dta_path_a0:			;a0 -> path of dta  or  0  or  -1
	movem.l	d1-d3/a0-a2,-(sp)
	lea	dta_linktb(pc),a1
	move	dta_bref_broot(pc),d2
	asl	#6,d2
	lea	(a1,d2),a2
	move.l	a2,d2			;d2 -> least used dta_link
	move.l	d0,d3			;d3 -> dta
	lea	dta_linkend(pc),a2
	bra.s	.dta_link_start
;
.dta_link_loop:
	lea	128(a1),a1		;step a1 128 bytes
.dta_link_start:
	cmp.l	a2,a1
	bhs.s	.dta_link_test
	move.l	(a1),d1
	cmp.l	d1,d3
	bne.s	.dta_link_loop
.dta_link_found:
	move.l	a1,d2
	move.l	a0,d0
	beq.s	.dta_link_end
	bra.s	.free_dta_link
;
.dta_link_test:
	move.l	d2,a1
	moveq	#-1,d2
	move.l	a0,d0
	ble.s	.dta_link_end
	tst.l	(a1)
	beq.s	.dta_link_free
.free_dta_link:
	clr.l	(a1)
	bsr.s	link_ref_tail_a1
	subq	#1,dta_link_count
.dta_link_free:
	move.l	a1,d2
	move.l	a0,d0
	ble.s	.dta_link_end
	clr.b	4(a1)
.dta_lentest:
	tst.b	(a0)+
	bne.s	.dta_lentest
	sub.l	d0,a0
	move.l	a0,d1		;d1  = string size
	moveq	#-1,d2
	cmp.l	#124,d1
	bgt.s	.dta_link_end
	move.l	a1,d2
	move.l	d0,a0		;a0 -> path
	move.l	d3,(a1)+
.dta_link_copy:
	move.b	(a0)+,(a1)+
	bne.s	.dta_link_copy
	move.l	d2,a1
	bsr.s	link_ref_head_a1	;;;patch
	addq	#1,dta_link_count
.dta_link_end:
	move.l	d2,d0
	movem.l	(sp)+,d1-d3/a0-a2
	rts
;
;
	ifne	asm_mode=debug_mode
	dc.b	'link_ref'
	even
	endc
;
link_ref_head_a1:
	movem.l	d0-d3/a1-a2,-(sp)
	move	dta_fref_froot(pc),d3	;prep to relink at pos 0
	move	d3,d2
	bra.s	link_ref_common
;
link_ref_tail_a1:
	movem.l	d0-d3/a1-a2,-(sp)
	move	#2*dta_links,d3			;prep to relink at pos 100
	move	dta_bref_broot(pc),d2
link_ref_common:
	sub.l	#dta_linktb,a1
	move.l	a1,d0
	lsr	#6,d0
	cmp	d2,d0		;old_pos - new_pos == 0 ?
	beq.s	.link_ref_end
	lea	dta_b_reftb(pc),a1
	lea	dta_f_reftb(pc),a2
	move	(a1,d0),d1	;\
	move	(a2,d0),d2	; \ unlink entry d0
	move	d1,(a1,d2)	; /
	move	d2,(a2,d1)	;/
	move	(a1,d3),d1		;d1  = predecessor of entry d3
	move	d1,(a1,d0)	;\
	move	d3,(a2,d0)	; \ relink entry d0 before entry d2
	move	d0,(a1,d3)	; /
	move	d0,(a2,d1)	;/
.link_ref_end:
	movem.l	(sp)+,d0-d3/a1-a2
	rts
;
;
check_afx_head_a0:	;affects no reg except flags eq==afx  ne==normal
	movem.l	d0-d2/a0,-(sp)
	cmpi.b	#'-',2(a0)	;possible header '-' ?
	bne.s	.no_header
	cmpi.b	#'a',3(a0)	;possible header 'a' ?
	bne.s	.no_header
	cmpi.b	#'f',4(a0)	;possible header 'f' ?
	bne.s	.no_header
	cmpi.b	#'x',5(a0)	;possible header 'x' ?
	bne.s	.no_header
	cmpi.b	#'-',6(a0)	;possible header '-' ?
	bne.s	.no_header
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a0)+,d0	;d0=header length byte
	move.b	(a0)+,d1	;d1=header checksum byte
	subq	#1,d0
	moveq	#0,d2
.L14E2:
	add.b	(a0)+,d2	;d2=calculated header checksum byte
	dbra	d0,.L14E2
	cmp	d2,d1		;check checksum
.no_header:
	movem.l	(sp)+,d0-d2/a0
	rts
;
;
read_FRUF_a2:
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Fread,unpack_handle(pc),ac_FRUF_size(pc),(a2)
	movem.l	(sp)+,d0-d2/a0-a2
	move.l	a2,a4
	rts
;
;
;Subroutine read_afx_byte:
;	fetches a byte from (a4)+ to d0, but if (a4 >= a3) it first refills the buffer
;	at (a2) by reading a FRUF-sized block using unpack_handle and sets a4=a2.
;	After fetching the byte d6 is decremented, and when it becomes negative a
;	special termination routine is used via afx_terminator_p.
;Thus:
;	a2 -> buffer base
;	a3 -> buffer position
;	a4 -> buffer end
;	d6 =  requested size before special termination
;==>:
;	d0 =  data byte
;
read_afx_byte:
	cmp.l	a3,a4
	blt.s	.L1516
	bsr.s	read_FRUF_a2
.L1516:
	move.b	(a4)+,d0
	subq.l	#1,d6
	bmi.s	.L151E
	rts
;
.L151E:
	addq.l	#4,sp
	move.l	afx_terminator_p(pc),a0
	jmp	(a0)
;
;
safe_fseek_d2_d1_d0:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Fseek,d2,d1,d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
safe_fread_d1_d0_a0:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Fread,d1,d0,(a0)
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
safe_fwrite_d1_d0_a0:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Fwrite,d1,d0,(a0)
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
safe_fclose_d1:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Fclose,d1
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
safe_fgetdta:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Fgetdta
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
safe_fsetdta_a0:
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Fsetdta,(a0)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;
safe_fsfirst_a0_d0:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Fsfirst,(a0),d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
safe_fsnext:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Fsnext
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
close_finfo:				;d0 = close_handle
	moveq	#-1,d1
release_finfo:			;d0 = close_handle  d1 = no_close_handle
	movem.l	d1-d5/a0-a3,-(sp)
	move	d0,d3			;d3 = close_handle
	move	d1,d4			;d4 = no_close_handle
	clr.l	d5			;d5 = preclear return value
	move	d3,d0
	bmi.s	.finfo_released
	add	d0,d0
	add	d0,d0			;d2 = handle * 4
	lea	finfo_linktb(pc),a0
	lea	0(a0,d0),a0		;a0 ->-> finfo
	move.l	(a0),a3			;a3 -> finfo, or is zero
	move.l	a3,d0
	bne.s	.make_release
	cmp	d3,d4
	beq.s	.finfo_released
	gemdos	Fclose,d3
	move.l	d0,d5
	bra.s	.finfo_released
;
.make_release:
	clr.l	(a0)			;ensure single release
	move	fi_afx_handle(a3),d0
	beq.s	.L1712
	cmp	d0,d4
	beq.s	.L1712
	gemdos	Fclose,d0		;close afx_handle if existing
	move.l	d0,d5			;d5 = return err_code
.L1712:
	move	fi_nafx_handle(a3),d0
	beq.s	.L1724
	cmp	d0,d4
	beq.s	.L1724
	gemdos	Fclose,d0		;close nafx_handle if existing
	tst	d0
	bpl.s	.L1724
	move.l	d0,d5			;d5 = return err_code
.L1724:
	move.l	fi_FRUF_p(a3),a1
	move.l	fi_CHEK_p(a3),a2
	move.l	a3,d0
	bsr	dual_mfree		;release finfo area
	move.l	a2,d0
	bsr	dual_mfree		;release CHEK area
	move.l	a1,d0
	bsr	dual_mfree		;release FRUF area
.finfo_released:
	move.l	d5,d0
	movem.l	(sp)+,d1-d5/a0-a3
	rts
;
;
fseek_afx:
	move.l	d2,-(sp)
	move.l	fi_filepos(a0),d2
	tst	d1
	beq.s	.fseek_afx_baseoff
	cmp	#1,d1
	beq.s	.fseek_afx_reloff
	cmp	#2,d1
	beq.s	.fseek_afx_endoff
.fseek_err:
	moveq	#-1,d0
	move.l	(sp)+,d2
	rts
;
.fseek_afx_reloff:
	add.l	d2,d0
	bra.s	.fseek_afx_baseoff
;
.fseek_afx_endoff:
	add.l	fi_orig_fsize(a0),d0
.fseek_afx_baseoff:
	cmp.l	fi_orig_fsize(a0),d0
	bhs.s	.L1A28
	cmp.l	d0,d2
	blt.s	.L1A1A
	bsr.s	respool
	bmi.s	.fseek_err
	clr.l	d2
.L1A1A:
	sub.l	d2,d0
	beq.s	.L1A20
	bsr.s	spool_forward
.L1A20:
	move.l	(sp)+,d2
	move.l	fi_filepos(a0),d0
	rts
;
.L1A28:
	move.l	fi_orig_fsize(a0),d0
	move.l	d0,fi_filepos(a0)
	move.l	(sp)+,d2
	rts
;
;
respool:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a0,a1
	move.l	fi_FRUF_p(a1),a0
	adda.l	fi_bfsize(a1),a0
	move.l	a0,fi_bfpos_p(a1)
	move.l	fi_orig_ftime(a1),6(a1)
	clr.l	fi_filepos(a1)
	move.l	fi_CHEK_p(a1),a0
	move	#$FEE/4-1,d0	;\
	move.l	#'    ',d1	;|
.blank_lp:			; > blank $FEE bytes to spaces
	move.l	d1,(a0)+	;|
	dbra	d0,.blank_lp	;|
	move	d1,(a0)+	;/
	move	#$1FF,10(a1)
	move	#$FEE,14(a1)
	clr	12(a1)
	move	#$FFFF,16(a1)
	clr	18(a1)
	move.l	36(a1),d0
	gemdos	Fseek,d0,fi_afx_handle(a1),!
	tst.l	d0
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;
spool_forward:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	terminate_spool(pc),a2
	lea	afx_terminator_p(pc),a3
	move.l	a2,(a3)
	move.l	a0,a1
	move.l	a1,-(sp)
	suba.l	a0,a0
	move.l	a0,-(sp)
	lea	0(a0,d0.l),a6		;a6 = file position
	lea	unpack_handle(pc),a5
	move.l	(a1)+,a4		;a4 = fi_bfpos_p
	move	(a1)+,(a5)		;(a5) = fi_afx_handle
	move.l	(a1)+,d6
	move	(a1)+,d2
	move	(a1)+,d5
	move	(a1)+,d3
	move	(a1)+,d1
	move	(a1)+,d4
	move.l	(a1)+,d0		;d0 = fi_bfsize
	move.l	(a1)+,a2		;a2 = fi_FRUF_p
	move.l	(a1)+,a5		;a5 = fi_CHEK_p
	move.l	a0,a1			;a1 = a0 -> buffer base
	lea	0(a2,d0.l),a3
	tst	d1
	bpl.s	.L1AD0
.L1A72:
	dbra	d5,.L1A7E
	bsr	read_afx_byte
	move	d0,d2
	moveq	#7,d5
.L1A7E:
	lsr.w	#1,d2
	bcc.s	.L1A98
	bsr	read_afx_byte
	move.b	d0,0(a5,d3.w)
	addq	#1,d3
	and	#$FFF,d3
	addq.l	#1,a1
	cmp.l	a6,a1
	bge.s	terminate_spool
	bra.s	.L1A72
;
.L1A98:
	moveq	#0,d0
	bsr	read_afx_byte
	move	d0,d4
	bsr	read_afx_byte
	move	d0,d1
	and.b	#$F0,d0
	lsl.w	#4,d0
	or	d0,d4
	and	#$F,d1
	add	#2,d1
.L1AB6:
	move.b	0(a5,d4.w),d0
	addq.l	#1,a1
	addq	#1,d4
	and	#$FFF,d4
	move.b	d0,0(a5,d3.w)
	addq	#1,d3
	and	#$FFF,d3
	cmp.l	a6,a1
	bge.s	terminate_spool
.L1AD0:
	dbra	d1,.L1AB6
	bra.s	.L1A72
;
terminate_spool:
	move.l	a1,d0
	sub.l	(sp)+,d0
	move.l	(sp)+,a6
	move	unpack_handle(pc),d7
	bra	mL6c6
;
;	End of general subroutines
;----------------------------------------------------------------------------
;	Here follow afx_unpacker routines
;
;d0 = buffer size,  a0-> buffer base,  a1-> finfo
read_afx_block:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	terminate_read(pc),a2
	lea	afx_terminator_p(pc),a3
	move.l	a2,(a3)
	move.l	a1,-(sp)		;push finfo ptr
	move.l	a0,-(sp)		;push buffer base ptr
	lea	0(a0,d0.l),a6		;a6 -> buffer end
	move.l	d0,d7			;d7 = d0 = buffer size
	lea	unpack_handle(pc),a5
	move.l	(a1)+,a4		;a4 = fi_bfpos_p
	move	(a1)+,(a5)		;unpack_handle = fi_afx_handle
	move.l	(a1)+,d6
	move	(a1)+,d2
	move	(a1)+,d5
	move	(a1)+,d3
	move	(a1)+,d1
	move	(a1)+,d4
	move.l	(a1)+,d0		;d0 = fi_bfsize
	move.l	(a1)+,a2		;a2 = fi_FRUF_p
	move.l	(a1)+,a5		;a5 = fi_CHEK_p
	move.l	a0,a1			;a1 = a0 -> buffer base
	lea	0(a2,d0.l),a3
	cmp.l	#10000,d7		
	blt.s	.L1796
	cmp.l	#10000,d6
	bge.s	L184C
.L1796:
	bsr	L17A4
	sub.l	(sp)+,d0		;pop => d0 = x - buffer base
	move.l	(sp)+,a6		;pop a6 -> finfo
	move	unpack_handle(pc),d7
	bra	mL6c6
;
L184C:
	move.l	d7,-(sp)
	move.l	a0,a6
	adda.l	#$1000,a6
	bsr	L17A4
	move.l	(sp)+,d7
	sub.l	#$1000,d7
	lea	-100(a1,d7.l),a6
	move.l	a6,-(sp)
	move.l	a5,-(sp)
	move	d4,d7
	sub	d3,d7
	neg	d7
	and	#$FFF,d7
	neg	d7
	lea	0(a1,d7.w),a5
	move.l	a1,d7
	and.l	#$FFF,d3
	sub.l	d3,d7
	move.l	a3,d3
	sub.l	a4,d3
	bsr	L1844
	add.l	a4,d6
	sub.l	a2,d6
	move.l	a3,-(sp)
	move	d1,d4
	bpl	L1924
	dbra	d5,L18A6
L189A:
	dbra	d3,L18A0
	bsr	L182E
L18A0:
	moveq	#0,d2
	move.b	(a4)+,d2
	moveq	#7,d5
L18A6:
	lsr.w	#1,d2
	bcc.s	L18BE
	dbra	d3,L18B2
	bsr	L182E
L18B2:
	move.b	(a4)+,(a1)+
	cmp.l	a6,a1
	bcc.s	L192E
	dbra	d5,L18A6
	bra.s	L189A
;
L18BE:
	dbra	d3,L18C6
	bsr	L182E
L18C6:
	move.b	(a4)+,d0
	moveq	#0,d4
	dbra	d3,L18D2
	bsr	L182E
L18D2:
	move.b	(a4)+,d4
	moveq	#15,d1
	and	d4,d1
	lsl.w	#4,d4
	move.b	d0,d4
	add.l	d7,d4
	sub.l	a1,d4
	neg	d4
	and	#$FFF,d4
	neg	d4
	lea	0(a1,d4.w),a5
	add	d1,d1
	neg	d1
	jmp	L1912(pc,d1.w)
;
;
L18F4:
	rept	15
	move.b	(a5)+,(a1)+
	endr
L1912:
	rept	3
	move.b	(a5)+,(a1)+
	endr
L1918:
	cmp.l	a6,a1
	bcc.s	L192E
	dbra	d5,L18A6
	bra	L189A
;
L1924:
	add	d1,d1
	neg	d1
	jmp	L1918(pc,d1.w)
;
;
L192C:
	addq.l	#4,sp
L192E:
	add.l	a2,d6
	sub.l	a4,d6
	move.l	(sp)+,a3
	move.l	(sp),a5
	move.l	a1,d3
	sub.l	d7,d3
	and	#$FFF,d3
	move	d3,d0
	neg	d0
	lea	0(a1,d0.w),a0
	neg	d0
	subq	#1,d0
	bmi.s	.L1952
.L194C:
	move.b	(a0)+,(a5)+
	dbra	d0,.L194C
.L1952:
	lea	-$1000(a1),a0
	move	#$1001,d0
	sub	d3,d0
.L195C:
	move.b	(a0)+,(a5)+
	dbra	d0,.L195C
	move.l	(sp)+,a5
	move.l	(sp)+,a6
	lea	100(a6),a6
	and	#$FFF,d3
	bsr.s	L17A4
	move.l	a1,d0
	sub.l	(sp)+,d0
	move.l	(sp)+,a6		;a6 -> finfo
	move	unpack_handle(pc),d7	;d7 = unpack_handle
mL6c6:
	add.l	d0,fi_filepos(a6)
	move.l	a4,(a6)+		;fi_bfpos_p = a4
	move	d7,(a6)+		;fi_afx_handle = d7
	move.l	d6,(a6)+
	move	d2,(a6)+
	move	d5,(a6)+
	move	d3,(a6)+
	move	d1,(a6)+
	move	d4,(a6)+
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;
L17A4:
	move	#$FFF,d7
	tst	d1
	bpl.s	.L1824
.L17AC:
	dbra	d5,.L17C2
	cmp.l	a3,a4
	blt.s	.L17B8
	bsr	read_FRUF_a2
.L17B8:
	moveq	#0,d2
	move.b	(a4)+,d2
	subq.l	#1,d6
	bmi.s	terminate_read
	moveq	#7,d5
.L17C2:
	lsr.w	#1,d2
	bcc.s	.L17E4
	cmp.l	a3,a4
	blt.s	.L17CE
	bsr	read_FRUF_a2
.L17CE:
	move.b	(a4)+,d0
	subq.l	#1,d6
	bmi.s	terminate_read
	move.b	d0,0(a5,d3.w)
	addq	#1,d3
	and	d7,d3
	move.b	d0,(a1)+
	cmp.l	a6,a1
	bhs.s	terminate_read
	bra.s	.L17AC
;
.L17E4:
	moveq	#0,d0
	cmp.l	a3,a4
	blt.s	.L17EE
	bsr	read_FRUF_a2
.L17EE:
	move.b	(a4)+,d0
	move	d0,d4
	cmp.l	a3,a4
	blt.s	.L17FA
	bsr	read_FRUF_a2
.L17FA:
	move.b	(a4)+,d0
	subq.l	#2,d6
	bmi.s	terminate_read
	moveq	#15,d1
	and	d0,d1
	and.b	#240,d0
	lsl.w	#4,d0
	or	d0,d4
	addq	#2,d1
.L180E:
	move.b	0(a5,d4.w),d0
	move.b	d0,(a1)+
	addq	#1,d4
	and	d7,d4
	move.b	d0,0(a5,d3.w)
	addq	#1,d3
	and	d7,d3
	cmp.l	a6,a1
	bcc.s	terminate_read
.L1824:
	dbra	d1,.L180E
	bra.s	.L17AC
;
terminate_read:
	move.l	a1,d0
	rts
;
;
L182E:
	add.l	a2,d6
	sub.l	a4,d6
	beq	L192C
	bmi	L192C
	bsr	read_FRUF_a2
	move.l	ac_FRUF_size(pc),d3
	subq.l	#1,d3
L1844:
	cmp.l	d3,d6
	bge.s	.L184A
	move.l	d6,d3
.L184A:
	rts
;
;
;	End of afx_unpacker routines
;----------------------------------------------------------------------------
;	Here follow memory allocation routines
;
dual_malloc:
	move.l	d0,-(sp)	;push size request = d0
	bsr	ir_malloc
	tst.l	d0
	ble.s	use_dos_malloc
	addq.l	#4,sp		;pull remove size request
mark_common:
	movem.l	a0-a1,-(sp)
	move.l	8(sp),a0	;a0 -> datamark at old retadr
	move.l	d0,a1
	move.l	(a0)+,-8(a1)	;move datamark and let a0 -> beyond it
	move.l	a0,8(sp)	;store a0 as new retadr
	movem.l	(sp)+,a0-a1
	rts
;
use_dos_malloc:
	move.l	(sp)+,d0	;pull d0 = size request
	addq.l	#4,(sp)		;skip datamark
safe_malloc:
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	d0,-(sp)
	gemdos	Malloc,d0
	tst.l	(sp)+		;clean stack & test for size query
	bpl.s	.malloc_ok	;OK to exit if no query
	sub.l	#$1000,d0	;reserve at least 4K for system use
	bpl.s	.malloc_ok
	moveq	#-1,d0		;flag error if too little room
.malloc_ok:
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
dual_mfree:
	cmp.l	#1,d0
	ble.s	.L15D2
	move.l	d0,-(sp)
	bsr	ir_mfree
	tst.l	d0
	ble.s	.dual_mfree_extern
	addq.l	#4,sp
	rts
;
.dual_mfree_extern:
	move.l	(sp)+,d0
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Mfree|_ind,d0
	tst.l	d0
	movem.l	(sp)+,d1-d2/a0-a2
.L15D2:
	rts
;
;
dual_alloc_huge:
	moveq	#-1,d0
	bsr.s	safe_malloc
	move.l	d0,d1		;d1 = max block size in external RAM
	moveq	#-1,d0
	bsr.s	ir_malloc	;d0 = max block size in internal RAM
	tst.l	d0
	ble.s	.dual_alloc_extern
	cmp.l	d1,d0
	bge.s	.dual_alloc_intern
.dual_alloc_extern:
	move.l	d1,d0		;d0 = d1 = requested block size
	ble.s	.no_room
	bra	safe_malloc	;go get d0-> RAM block
;
.dual_alloc_intern:		;here d0 = max block size in internal RAM
	sub.l	#$400,d0	;reserve 1 KByte for other use
	ble.s	.no_room	;use dummy buffer if out of room
	move.l	d0,d1		;d1 = d0 = requested block size
	bra.s	ir_malloc	;go get d0-> RAM block
;
.no_room:
	move.l	#256,d1		;d1 = size of path_bf3
	move.l	a0,-(sp)
	lea	path_bf3(pc),a0
	move.l	a0,d0		;d0-> path_bf3
	move.l	(sp)+,a0
	rts
;
;
ir_malloc:			;d0  = requested size
	movem.l	d1-d5/a0-a1,-(sp)
	moveq	#-1,d5		;d5  = -1  (no largest block size yet)
	move.l	d0,d1		;d1  = requested size
	bmi.s	.L1C82
	add.l	#12+3,d1	;\ d1 = rounded up to longword alignment
	ble	.not_room	;too high size means error
	andi.b	#$FC,d1		;/ which is the needed storage size
.L1C82:
	move.l	ir_base_p(pc),a0	;a0 -> ir_base
.malloc_lp_1:
	move.l	(a0),d2		;d2  = size of this block
	ble.s	.malloc_limit	;exit at end of blocks
	bclr	#0,d2		;d2 forced even
	bne.s	.L1C96		;test block if free (odd)
	adda.l	d2,a0		;a0 -> next block
	bra.s	.malloc_lp_1
;
.L1C96:
	move.l	a0,d3		;d3 -> this block
.malloc_lp_2:
	adda.l	d2,a0		;a0 -> next block
	move.l	(a0),d2		;d2  = size of next block
	ble.s	.enough_tst	;exit if next block is limit
	bclr	#0,d2		;d2 forced even
	bne.s	.malloc_lp_2	;loop to pass free (odd) blocks
.enough_tst:
	move.l	a0,d2		;d2 -> unfree block
	sub.l	d3,d2		;d2  = free block size
	cmp.l	d2,d5
	bge.s	.keep_large
	move.l	d2,d5		;d5  = largest free block size as yet
.keep_large:
	bset	#0,d2		;d2 forced odd  (free marker)
	move.l	d3,a1		;d3 -> free block
	move.l	d2,(a1)		;store concatenated free block size
	move.l	#'MEMS',4(a1)	;store block type
	bclr	#0,d2		;d2 forced even
	tst.l	d1
	bmi.s	.malloc_lp_1	;loop back  if checking max size
	sub.l	d1,d2
	blt.s	.malloc_lp_1	;loop back  if size did not fit
	cmp.l	#16,d2
	blt.s	.take_block	;take whole block if new cut too small
	suba.l	d2,a0		;a0 -> new free block after cut
	bset	#0,d2		;d2 forced odd  (free marker)
	move.l	d2,(a0)		;store cut free block size
	move.l	#'MEMS',4(a0)	;store block type
	bra.s	.cut_block
;
.take_block:
	add.l	d2,d1
.cut_block
	move.l	d3,a0
	move.l	d1,(a0)+	;store allocated block size
	move.l	#'MEMS',(a0)+	;store block type
	move.l	gemdos_count(pc),(a0)+
	move.l	a0,d0		;d0 -> data area
	bra.s	.got_room		;go exit
;
.malloc_limit:
	cmp.l	#-1,d1		;checking for maximum size ?
	bne.s	.not_room	;error exit  if not checking size
	move.l	d5,d0		;d0  = maximum size
	bra.s	.got_room		;go exit
;
.not_room:
	moveq	#-1,d0
.got_room:
	movem.l	(sp)+,d1-d5/a0-a1
	rts
;
;
ir_mfree:			;d0 -> area, possibly allocated by ir_malloc
	movem.l	d1-d3/a0-a1,-(sp)
	sub.l	#12,d0
	move.l	ir_base_p(pc),a0	;a0 -> start of ir area
	clr.l	d2			;d2  = zero block offset
.L1D26:
	adda.l	d2,a0
	move.l	(a0),d2		;d2  = offs to next block
	ble.s	.L1D4C		;error_exit at end of blocks
	bclr	#0,d2		;force offs even
	bne.s	.L1D26		;ignore odd_sized (free) blocks
	cmp.l	d0,a0		;is a0 -> sought block ?
	bne.s	.L1D26		;if not, try next block
.L1D38:
	bset	#0,3(a0)	;force block size odd (mark free)
	movem.l	(sp)+,d1-d3/a0-a1
	rts
;
.L1D4C:
	moveq	#-1,d0
	movem.l	(sp)+,d1-d3/a0-a1
	rts
;
;	End of memory allocation routines
;----------------------------------------------------------------------------
;	Here follow the dta priority ordering tables
;
dta_link_count:
	dc.w	0
;
	ifne	asm_mode=debug_mode
	dc.b	'back_ref        '
	even
	endc
;
seqwtab	macro	count,start,step
seq_cnt	set	\1
seq_val set	\2
seq_stp	set	\3
	rept	\1
	dc.w	seq_val
seq_val	set	seq_val+seq_stp
	endr
	endm
;
dta_bref_froot:
	dc.w	-2
dta_b_reftb:
	seqwtab	dta_links,-2,2
dta_bref_broot:
	dc.w	2*dta_links-2
;
	ifne	asm_mode=debug_mode
	dc.b	'forw_ref        '
	even
	endc
;
dta_fref_froot:
	dc.w	00
dta_f_reftb:
	seqwtab	dta_links,2,2
dta_fref_broot:
	dc.w	2*dta_links
;
;	End of dta priority ordering tables
;----------------------------------------------------------------------------
;	Here is the XBRA_linked reset routine to remove altered cookie jar,
;	with the necessary variables
;
_cookies_save:		dc.l	0
resvalid_save:		dc.l	0
			dc.l	'XBRA','ck01'
resvector_save:		dc.l	0
uncookie_reset:
	move.l	_cookies_save(pc),(_cookies).w
	move.l	resvector_save(pc),(resvector).w
	move.l	resvalid_save(pc),(resvalid).w
	jmp	(a6)	;NB:reset routine must not use standard linking
;
;	End of reset routine to remove altered cookie jar
;----------------------------------------------------------------------------
;	This is the end of all permanently resident code
;	Everything beyond this will be cleared for data use
data_base:
;
;----------------------------------------------------------------------------
;	Here are variable definitions overlapping boot routines
;
ovl	macro	amount,name
\2:	=	data_base+__RS
	rs.\0	\1
	endm
;
	rsreset
;
	ovl.b	 64,pexec_chek
	ovl.w	  1,pexec_sp
	ovl.b	pexec_levels*8,pexec_st
	ovl.w	  1,tos_version
	ovl.w	  1,new_tos_f
	ovl.l	  1,currbp_p_p
	ovl.l	  1,last_resident
	ovl.b	 22,filesize_recbf
	ovl.l	  1,filesize_recend
	ovl.b	256,path_bf1
	ovl.b	256,path_bf2
	ovl.b	256,path_bf3
	ovl.b	 22,locdta_base
	ovl.b	  8,locdta_ftime
	ovl.b	 14,locdta_fname
	ovl.b	128*dta_links,dta_linktb
	ovl.l	  1,dta_linkend
	ovl.b	256,wr_afx_fname_s
	ovl.l	  1,afx_terminator_p
	ovl.w	  1,unpack_handle
	ovl.l	finfo_links,finfo_linktb
	ovl.l	256,loc_stack_beg
	ovl.l	 16,loc_stack_end
	ovl.b	  0,iram_base
;
;	End of overlay definitions, valid after boot
;----------------------------------------------------------------------------
;	Here are cookie routines not needed after initial part of boot
;
seek_cookie_d0:
	movem.l	d6-d7/a0,-(sp)
	move.l	d0,d7
	moveq	#-34,d0		;prep 'path not found' error
	move.l	(_cookies).w,d6
	beq.s	.seek_cookie_exit
	move.l	d6,a0
	moveq	#-33,d0		;prep 'file not found' error
.seek_cookie_loop:
	tst.l	(a0)
	beq.s	.seek_cookie_exit
	cmp.l	(a0),d7
	beq.s	.seek_cookie_found
	addq.l	#8,a0
	bra.s	.seek_cookie_loop
;
.seek_cookie_found:
	move.l	a0,d0
.seek_cookie_exit:
	tst.l	d0
	movem.l	(sp)+,d6-d7/a0
	rts
;
;
eval_cookie_d0:
	move.l	a1,-(sp)
	bsr.s	seek_cookie_d0
	bmi.s	.eval_cookie_exit
	move.l	d0,a1
	movem.l	4(a1),d0	;d0  = cookie value (unflagged)
.eval_cookie_exit:
	move.l	(sp)+,a1
	rts		;return  pl,d0==cookie_value  or  mi,d0==err_code
;
;
make_cookie_d0_d1:
	movem.l	d2-d3/a0,-(sp)
	move.l	d0,d2
	bsr.s	seek_cookie_d0
	bmi.s	.make_cookie_new
	moveq	#-36,d0		;prep 'access illegal'
	bra.s	.make_cookie_exit
;
.make_cookie_new:
	bsr.s	get_cookie_jar_size
	move	d0,d3
	bsr.s	get_cookie_jar_used
	sub	d0,d3
	bgt.s	.have_room
	moveq	#32,d0
	bsr.s	extend_cookie_jar
	bmi.s	.make_cookie_exit
	bsr.s	get_cookie_jar_used
.have_room:
	subq	#1,d0
	lsl.w	#3,d0
	move.l	(_cookies).w,a0
	adda	d0,a0
	clr.l	8(a0)
	move.l	4(a0),12(a0)
	move.l	d2,(a0)
	move.l	d1,4(a0)
	move.l	a0,d0
.make_cookie_exit:
	tst.l	d0
	movem.l	(sp)+,d2-d3/a0
	rts	;return  pl,d0->cookie  or  mi,d0==err_code
;
get_cookie_jar_used:
	move.l	a0,-(sp)
	move.l	(_cookies).w,d0
	beq.s	.L1D70
	move.l	d0,a0
	clr	d0
.L1D66:
	addq	#1,d0
	tst.l	(a0)
	beq.s	.L1D70
	addq.l	#8,a0
	bra.s	.L1D66
;
.L1D70:
	move.l	(sp)+,a0
	rts
;
;
get_cookie_jar_size:
	move.l	a0,-(sp)
	move.l	(_cookies).w,d0
	beq.s	.L1D8A
	move.l	d0,a0
.L1D7E:
	tst.l	(a0)
	beq.s	.L1D86
	addq.l	#8,a0
	bra.s	.L1D7E
;
.L1D86:
	move.l	4(a0),d0
.L1D8A:
	move.l	(sp)+,a0
	rts
;
;
extend_cookie_jar:
	movem.l	d1-d7/a0-a6,-(sp)
	andi.l	#$FFFF,d0
	move.l	d0,d7			;d7 = size of jar extension
	bsr.s	get_cookie_jar_size	;d0 = size of old jar (in entries)
	add.l	d7,d0			;d0 = size of new jar (in entries)
	move.l	d0,d7			;d7 = size of new jar (in entries)
	lsl.w	#3,d0
	gemdos	Malloc,d0
	tst.l	d0
	bmi.s	.extend_cookie_exit
	move.l	d0,a2			;a2 -> new_jar
	move.l	d0,a0			;a0 -> new_jar
	move.l	(_cookies).w,a1		;a1 -> old_jar
	bsr.s	get_cookie_jar_used	;d0 = used size of jar
	subq	#1,d0			;prep for dbra
	bmi.s	.set_limit		;skip move if no jar
	bra.s	.move_next		;do move excluding limit_mark
;
.move_loop:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
.move_next:
	dbra	d0,.move_loop
.set_limit:
	clr.l	(a0)+
	move.l	d7,(a0)
	move.l	a2,d0
	bsr.s	set_new_cookie_jar_d0
.extend_cookie_exit:
	tst.l	d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts		;return  pl,d0->cookie_jar  or  mi,d0==err_code
;
;
set_new_cookie_jar_d0:
	move.l	(_cookies).w,_cookies_save
	move.l	(resvalid).w,resvalid_save
	move.l	(resvector).w,resvector_save
	move.l	#uncookie_reset,(resvector).w
	move.l	#$31415926,(resvalid).w
	move.l	d0,(_cookies).w		;activate new_jar
	rts
;
;	End of cookie routines, not needed after boot
;----------------------------------------------------------------------------
;	Here are boot routines, not needed after boot
;
boot_test:
	moveq	#-47,d7			;prep 'illegal operation' error
	move.l	a0,d0
	bne	boot_tested		;refuse to boot as ACC
	pea	s_myself_auto(pc)
	pea	(bp+$80)(pc)
	pea	s_myself(pc)
	bsr	calc_nnn
	add	#12,sp
	move	d0,nnn_word
	bpl.s	.set_size
	move	#(def_ir_size/Kbyte),d0
	move	d0,nnn_word
.set_size:
	mulu	#Kbyte,d0
	move.l	d0,ac_ir_size
	move.l	8(sp),a0		;a0->basepage
	lea	iram_base(pc),a5
	suba.l	a0,a5			;a5 = size before iram area
	adda.l	ac_ir_size(pc),a5	;reserve iram area
	move.l	(sp)+,d0		;d0 = return address from entry stack
	lea	-16(a0,a5.l),sp		;use free iram space as boot stack
	move.l	d0,-(sp)		;move return address to boot stack
	addq	#8,a5			;reserve iram end mark
	gemdos	Mshrink,!,(a0),a5	;return unneeded RAM
	move.l	d0,d7
	bmi.s	boot_tested
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	#'AFX',d0
	bsr	seek_cookie_d0
	bmi.s	.test_xafx
	moveq	#-37,d0			;prep 'invalid handle' error
	bra.s	.done_cookie
;
.test_xafx:
	move.l	#'xAFX',d0
	lea	ac_cookie_base(pc),a0
	move.l	a0,d1
	bsr	make_cookie_d0_d1
.done_cookie:
	move.l	d0,d7
	gemdos	Super,()
	tst.l	d7
	bmi.s	boot_tested
	gemdos	Cconws,tit_1_s(pc)
	gemdos	Cconws,size_1_s(pc)
	move	nnn_word(pc),-(sp)
	bsr	show_nnn
	addq	#2,sp
	gemdos	Cconws,size_2_s(pc)
boot_tested:
	tst.l	d7
	rts
;
;
boot_err_disp:
	lea	old_afx_err_s(pc),a0
	cmp	#-37,d7
	beq.s	.show_error
	lea	new_afx_err_s(pc),a0
	cmp	#-36,d7
	beq.s	.show_error
	lea	gen_afx_err_s(pc),a0
.show_error:
	gemdos	Cconws,(a0)
	gemdos	Cconws,crlfcrlf_s(pc)
	move	#5*50,d0
	bsr.s	safe_vsyncs
	rts
;
;
boot_finish:
	lea	rz(pc),a6
	move.l	#$18A4,ac_L3D0-rz(a6)
	move.l	#$0FD4,ac_L3D4-rz(a6)
	move.l	#$27AA,ac_L3DC-rz(a6)
	lea	loc_stack_end(pc),a0
	move.l	a0,intern_sp-rz(a6)
	move.l	#4*Kbyte,d3
	move.l	ac_FRUF_size(pc),d2
	cmp.l	d3,d2
	bge.s	.accept_FRUF_size
	move.l	d3,d2
	move.l	d2,ac_FRUF_size
.accept_FRUF_size:
	move.l	ac_ir_size(pc),d2
	cmp.l	d3,d2
	bge.s	.accept_ir_size
	move.l	d3,d2
	move.l	d2,ac_ir_size
.accept_ir_size:
	lea	iram_base(pc),a0
	move.l	d2,d0
	addq.l	#1,d0
	move.l	d0,(a0)			;(#iram_base+0) = ac_ir_size+1  (free block)
	clr.l	0(a0,d2.l)		;(#iram_base+ac_ir_size+0) -> 0 (end block)
	move.l	#'MEMS',4(a0,d2.l)	;(#iram_base+ac_ir_size+4) = 'MEMS'
	move.l	a0,ir_base_p-rz(a6)	;ir_base_p -> iram_base
	bsr.s	frame_test
	bsr.s	set_afx_gemdos_XB
	gemdos	Cconws,tit_2_s(pc)
	rts
;
;
safe_vsyncs:
	movem.l	d0-d2/a0-a2,-(sp)
	xbios	Vsync
	movem.l	(sp)+,d0-d2/a0-a2
	dbra	d0,safe_vsyncs
	rts
;
;
frame_test:
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Super,!
	move.l	d0,-(sp)		;save old SSP on stack
	moveq	#8,d1
	tst	(_longframe).w
	bne.s	.frame_tested		;avoids messing TT's traps
	move.l	sp,d1
	move.l	(ev_trap3).w,d2
	lea	test_trap(pc),a0
	move.l	a0,(ev_trap3).w
	trap	#3
	move.l	d2,(ev_trap3).w
.frame_tested:
	lea	st_frame_size(pc),a0
	move.l	d1,(a0)
	gemdos	Super,()
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;
test_trap:
	sub.l	sp,d1
	rte
;
;
set_afx_gemdos_XB:
	bios	Setexc,#ev_gemdos/4,afx_gemdos_XB+12(pc)
	lea	afx_gemdos_XB+8(pc),a0
	move.l	d0,(a0)
	rts
;
;
;	End of boot routines, not needed after boot
;----------------------------------------------------------------------------
;
	INCLUDE	PROG_NNN.S
;
;----------------------------------------------------------------------------
;
s_myself_auto:	dc.b	'\AUTO\'
s_myself:	dc.b	'XAFX_?*.PRG',NUL
;
;----------------------------------------------------------------------------
;	Here is boot data, not needed after boot
;
nnn_word:	dc.w	(def_ir_size/Kbyte)
;
;
tit_1_s:
	dc.b	CR,LF,' ',ESC,'p'
	dc.b	 "  xAFX  Version 2.1  Revision: K       Updated: 1'st of October 1994  ",CR,LF
	dc.b	ESC,'q',CR,LF
	dc.b	' AFX version 2.1, debugged and extended by Ulf Ronald Andersson.',CR,LF
	dc.b	' All debug copyright released to Thomas Quester who created AFX.',CR,LF
	dc.b	CR,LF
	dc.b	' AFX is Shareware, with a free test period of one month.',CR,LF
	dc.b	CR,LF,NUL
size_1_s:
	dc.b	' xAFX will use ',NUL
size_2_s:
	dc.b	' Kbytes of buffer RAM this session.',CR,LF
	dc.b	CR,LF
	dc.b	NUL
tit_2_s:
	dc.b	' For AFX registration send 20 DM to:',CR,LF
	dc.b	CR,LF
	dc.b	'   Thomas Quester,   Lampenland 9,   2050 Hamburg 80.',CR,LF
	dc.b	'   Telefon (040) 720 54 31',CR,LF
	dc.b	'   Maus: Thomas Quester @ HH2',CR,LF
	dc.b	'   Zerberus: T.Quester@data-hh',CR,LF
	dc.b	'   Telefon (040) 720 54 31',CR,LF
	dc.b	'   BTX: 0407205431'
crlfcrlf_s:
	dc.b	CR,LF,CR,LF
	dc.b	NUL
old_afx_err_s:
	dc.b	'xAFX can not run with old AFX booted !',NUL
new_afx_err_s:
	dc.b	'xAFX was already installed !',NUL
gen_afx_err_s:
	dc.b	'xAFX installation failed !',NUL
	even
;
;	End of boot data, not needed after boot
;----------------------------------------------------------------------------
;End of file:	xAFX.S
;----------------------------------------------------------------------------
