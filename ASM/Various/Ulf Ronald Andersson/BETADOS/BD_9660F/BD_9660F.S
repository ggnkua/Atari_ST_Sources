;----------------------------------------------------------------------------
; File name:	BD_9660F.S			Revision date:	1998.09.11
; Created by:	Ulf Ronald Andersson		Creation date:	1998.03.01
;----------------------------------------------------------------------------
; Purpose:
;	Filesystem driver for ISO9660F CD-ROMs
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	output	.DOS
;----------------------------------------------------------------------------
MAX_Func	=	349
;----------------------------------------------------------------------------
FS_mode_bits	=	4	;b2=writable  b1=rel_paths  b0=sensecase
;----------------------------------------------------------------------------
DEV_NAME	MACRO
	dc.b	'BetaDos ISO9660F'
	ENDM
DEV_VERSION	MACRO
	dc.b	'1.00'
	ENDM
;----------------------------------------------------------------------------
	struct	LDB
	d_s	LDB_9660,$282A
	uint32	LDB_device_type
	uint16	LDB_DOS_char
	uint16	LDB_BOS_char
	uint16	LDB_DOS_parm
	uint16	LDB_DOS_drive
	uint16	LDB_DOS_bit
	d_end	LDB
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
;Function:	ll_bootup
;Entry state:	no arguments
;Exit state:
;	d1 -> driver name string
;	d0 -> FunctionTable+12
;
ll_bootup:
	bsr	Init_FunctionTable
	clr.l	b_f3c
	clr.l	b_f40
	lea	DEV_NAME_s(pc),a0
	move.l	a0,d1			;d1 -> driver name string
	move.l	#FunctionTable+12,d0	;d0 -> FunctionTable+12
	rts
;----------------------------------------------------------------------------
;Function:	ll_initfun
;Entry state:
;	a2  -> BOS device code, and any parameters that may follow it
;	d2.w = DOS device code
;	d0.w = BOS device code
;Exit state:
;	d1 = filesystem mode bits:
;		Bit 0: 0 = force upper case
;		Bit 1: 0 = expand paths
;		Bit 2: 0 = critical error handler reports EWRPRO
;	d0 -> logical device block  OR  d0 = error code
;
ll_initfun:
	movem.l	a0-a6/d2-d7,-(sp)	;push entry registers
	movem.l	d0/d2/a2,-(sp)		;push BOS/DOS chars & -> DOS_parm
	gemdos	Malloc,#sizeof_LDB	;allocate logical device block
	move.l	d0,a3			;a3 -> LDB or is an error code
	tst.l	d0			;error ?
	bgt.s	.have_mem
	moveq	#E_NSMEM,d0		;flag memory error
	move.l	d0,a3			;store error code in a3
.failure:
	move.l	d0,-(sp)		;push error code from d0
	move.l	a3,d0			;LDB ptr valid ?
	ble.s	.done_Mfree
	gemdos	Mfree,(a3)
.done_Mfree:
	move.l	(sp)+,a3		;pull error code to a3
	bra.s	.done
;
.have_mem:
	movea.l	d0,a0		;a0 = ldp -> logical device block
	move	2(sp),0(a0)	;store BOS drive letter
	movea.l	a0,a3		;a3 = ldp -> logical device block
	jsr	ll_init_device
	cmp.l	#E_UNDEV,d0
	beq	.failure
	cmp.l	#E_GENRL,d0
	beq	.failure
	movem.l	(sp),d0/d2/a2
	move.l	#FS_mode_bits,LDB_device_type(a3)
	move	d0,LDB_BOS_char(a3)
	move	d2,LDB_DOS_char(a3)
	move.l	a2,LDB_DOS_parm(a3)
	sub	#'A',d2
	move	d2,LDB_DOS_drive(a3)
	moveq	#1,d0
	lsl.l	d2,d1
	move.l	d1,LDB_DOS_bit
.done:
	add	#12,sp			;drop device codes & parm_p from stack
	moveq	#FS_mode_bits,d1	;d1 = filesystem mode bits
	move.l	a3,d0			;d0 -> allocated LDB (or is error code)
	movem.l	(sp)+,a0-a6/d2-d7	;pull entry registers
	rts
;----------------------------------------------------------------------------
ll_INVFN:
	moveq	#E_INVFN,d0
	rts
;----------------------------------------------------------------------------
;Start of:	ll_functions
;----------------------------------------------------------------------------
;Function:	ll_Dfree
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dfree:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	dfree_buf	;DISKINFO	*dfree_buf
	lv_arg.w	dfree_drive	;int		 dfree_drive
;
	jsr	check_status
	tst.l	d0
	bmi.s	t_510
	movea.l	dfree_buf(sp),a0
	move.l	#0,(a0)+
	move.l	2(a3),(a0)+
	move	#0,(a0)+
	move	6(a3),(a0)+
	move.l	#1,(a0)
	moveq	#0,d0
t_510:
	lv_exit		sp
	rts
;
;End of:	ll_Dfree
;----------------------------------------------------------------------------
;Function:	ll_Dcreate
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dcreate:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Dcreate_path	;char	*Dcreate_path
;
	moveq	#E_WRPRO,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Dcreate
;----------------------------------------------------------------------------
;Function:	ll_Ddelete
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Ddelete:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Ddelete_path	;char	*Ddelete_path
;
	moveq	#E_WRPRO,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Ddelete
;----------------------------------------------------------------------------
;Function:	ll_Dsetpath
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dsetpath:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Dsetpath_path	;char	*Dsetpath_path
;
	bsr	check_status
	tst.l	d0
	bmi.s	.exit
	bsr	t_652
	tst.l	d0
	bmi.s	.exit
	moveq	#E_OK,d0
.exit:
	lv_exit		sp
	rts
;
;End of:	ll_Dsetpath
;----------------------------------------------------------------------------
;Function:	ll_Fcreate
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fcreate:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Fcreate_path	;char	*Fcreate_path
	lv_arg.w	Fcreate_mode	;int	Fcreate_mode
;
	moveq	#E_WRPRO,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Fcreate
;----------------------------------------------------------------------------
;Function:	ll_Fopen
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fopen:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Fopen_path	;char	*Fopen_path
	lv_arg.w	Fopen_mode	;int	Fopen_mode
;
	jsr	check_status
	tst.l	d0
	bmi.s	.exit
	jsr	t_652
	tst.l	d0
	bmi.s	.exit
	jsr	t_768
	tst.l	d0
	bmi.s	.exit
	jsr	t_7cc
	tst.l	d0
	bmi.s	.exit
	btst	#1,$19(a0)
	beq.s	.t_20e
	moveq	#-$21,d0
	bra.s	.exit
;
.t_20e:
	move.l	6(a0),d0
	cmpi	#$200,6(a3)
	beq.s	.t_22a
	cmpi	#$400,6(a3)
	beq.s	.t_22c
	bra.s	.t_22e
;
.t_22a:
	asr.l	#1,d0
.t_22c:
	asr.l	#1,d0
.t_22e:
	move.l	d0,0(a5)
	move.l	14(a0),4(a5)
	move.l	#0,8(a5)
	moveq	#0,d0
	move.b	1(a0),d0
.exit:
	lv_exit		sp
	rts
;
;End of:	ll_Fopen
;----------------------------------------------------------------------------
;Function:	ll_Fclose
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fclose:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	file_handle	;int	file_handle
;
	move.l	#-1,0(a5)
	move.l	#-1,4(a5)
	move.l	#-1,8(a5)
	moveq	#0,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Fclose
;----------------------------------------------------------------------------
;Function:	ll_Fread
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fread:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	file_handle	;int	file_handle
	lv_arg.l	file_count	;long	file_count
	lv_arg.l	file_buffer	;char	*file_buffer
;
	jsr	get_status
	tst.l	d0
	bmi	.exit
	and	#8,d0
	beq.s	.t_90
	moveq	#-14,d0
	bra	.exit
;
.t_90:
	move.l	8(a5),d3
	move	#11,d0
	asr.l	d0,d3
	add.l	0(a5),d3
	movea.l	12(sp),a4
	move.l	8(sp),d4
	move.l	4(a5),d0
	sub.l	8(a5),d0
	cmp.l	d0,d4
	ble.s	.t_b6
	move.l	d0,d4
.t_b6:
	tst.l	d4
	bne.s	.t_c2
	moveq	#0,d0
	bra	.exit
;
.t_c2:
	move.l	8(a5),d0
	and	#$7ff,d0
	beq.s	.t_fe
	move.l	#$800,d5
	sub	d0,d5
	cmp.l	d5,d4
	bge.s	.t_de
	move.l	d4,d5
.t_de:
	sub.l	d5,d4
	subq	#1,d5
	lea	$2a(a3),a6
	adda	d0,a6
	move.l	d3,d0
	addq.l	#1,d3
	jsr	t_8f6
	tst.l	d0
	bmi	.exit
.t_f8:
	move.b	(a6)+,(a4)+
	dbra	d5,.t_f8
.t_fe:
	move.l	a4,d0
	btst	#0,d0
	bne.s	.t_148
.t_108:
	move.l	d4,d0
	move	#11,d1
	asr.l	d1,d0
	beq.s	.t_178
	cmp.l	#$3f,d0
	ble.s	.t_120
	moveq	#$3f,d0
.t_120:
	move	d0,-(sp)
	move.l	d3,-(sp)
	add.l	d0,d3
	move.l	a4,-(sp)
	move	#11,d1
	asl.l	d1,d0
	adda.l	d0,a4
	sub.l	d0,d4
	move	0(a3),-(sp)
	move	#(Metaread&$ff),-(sp)	
	trap	#14
	lea	14(sp),sp
;
	tst.l	d0
	bmi.s	.exit
	bra	.t_108
;
.t_148:
	cmp.l	#$800,d4
	blt.s	.t_178
	sub.l	#$800,d4
	move.l	d3,d0
	addq.l	#1,d3
	jsr	t_8f6
	tst.l	d0
	bmi.s	.exit
	lea	$2a(a3),a0
	move	#$7ff,d0
.t_170:
	move.b	(a0)+,(a4)+
	dbra	d0,.t_170
	bra	.t_148
;
.t_178:
	subq	#1,d4
	bmi.s	.t_196
	move.l	d3,d0
	jsr	t_8f6
	tst.l	d0
	bmi.s	.exit
	lea	$2a(a3),a0
.t_190:
	move.b	(a0)+,(a4)+
	dbra	d4,.t_190
.t_196:
	move.l	a4,d0
	sub.l	12(sp),d0
	add.l	d0,8(a5)
.exit:
	lv_exit		sp
	rts
;
;End of:	ll_Fread
;----------------------------------------------------------------------------
;Function:	ll_Fwrite
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fwrite:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	file_handle	;int	file_handle
	lv_arg.l	file_count	;long	file_count
	lv_arg.l	file_buffer	;char	*file_buffer
;
	moveq	#E_WRPRO,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Fwrite
;----------------------------------------------------------------------------
;Function:	ll_Fdelete
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Fdelete:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Fdelete_path	;char	*Fdelete_path
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Fdelete
;----------------------------------------------------------------------------
;Function:	ll_Fseek
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fseek:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	file_offset	;long	file_offset
	lv_arg.w	file_handle	;int	file_handle
	lv_arg.w	file_seekmode	;int	file_seekmode
;
	move.l	6(sp),d0
	cmpi	#1,12(sp)
	blt.s	.t_1ba
	bgt.s	.t_1b6
	add.l	8(a5),d0
	bra.s	.t_1ba
;
.t_1b6:
	add.l	4(a5),d0
.t_1ba:
	tst.l	d0
	blt.s	.t_1ca
	cmp.l	4(a5),d0
	bgt.s	.t_1ca
	move.l	d0,8(a5)
	rts
;
.t_1ca:
	moveq	#-$40,d0
	lv_exit		sp
	rts
;
;End of:	ll_Fseek
;----------------------------------------------------------------------------
;Function:	ll_Fattrib
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Fattrib:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Fatt_path	;char	*Fatt_path
	lv_arg.w	Fatt_wflag	;int	Fatt_wflag
	lv_arg.w	Fatt_attr	;int	Fatt_attr
;
	jsr	check_status
	tst.l	d0
	bmi.s	t_4ba
	tst	10(sp)
	beq.s	t_46a
	moveq	#-5,d0
	bra.s	t_4ba
;
t_46a:
	jsr	t_652
	tst.l	d0
	bmi.s	t_4ba
	jsr	t_768
	tst.l	d0
	bmi.s	t_4ba
	tst.b	(a4)
	bne.s	t_490
	lea	$2a(a3),a0
	bra.s	t_49c
;
t_490:
	jsr	t_7cc
	tst.l	d0
	bmi.s	t_4ba
t_49c:
	moveq	#1,d0
	btst	#0,$19(a0)
	beq.s	t_4ac
	or	#2,d0
t_4ac:
	btst	#1,$19(a0)
	beq.s	t_4ba
	or	#$10,d0
t_4ba:
;
	lv_exit		sp
	rts
;
;End of:	ll_Fattrib
;----------------------------------------------------------------------------
;Function:	ll_Fsfirst
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	DTA	*dta
ll_Fsfirst:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Fsfirst_path	;char	*Fsfirst_path
	lv_arg.w	Fsfirst_mode	;int	Fsfirst_mode
;
	move.l	#-1,(a5)
	jsr	check_status
	tst.l	d0
	bmi.s	t_2d4
	jsr	t_652
	tst.l	d0
	bmi.s	t_2d4
	jsr	t_768
	tst.l	d0
	bmi.s	t_2d4
	movea.l	a5,a0
	move.l	$1e(a3),(a0)+
	move	$22(a3),(a0)+
	move	$24(a3),(a0)+
	cmpi.b	#'*',(a4)
	bne.s	t_2c6
	cmpi.b	#'.',1(a4)
	bne.s	t_2c6
	cmpi.b	#'*',2(a4)
	bne.s	t_2c6
	tst.b	3(a4)
	bne.s	t_2c6
	move.b	#0,1(a4)
t_2c6:
	move.b	(a4)+,(a0)+
	bne	t_2c6
	move.b	11(sp),$14(a5)
	bra.s	ll_Fsnext
;
t_2d4:
;
	lv_exit		sp
	rts
;
;End of:	ll_Fsfirst
;----------------------------------------------------------------------------
;Function:	ll_Fsnext
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	DTA	*dta
ll_Fsnext:
	lv_init		sp
	lv_arg.w	DOS_opcode
;
	move.b	$14(a5),d3
	cmp.b	#8,d3
	bne.s	t_2e8
	moveq	#-$21,d0
	bra	t_3be
;
t_2e8:
	move.b	#0,$14(a5)
	movea.l	a5,a4
	move.l	(a4)+,$1e(a3)
	move	(a4)+,$22(a3)
	move	(a4)+,$24(a3)
t_2fc:
	jsr	t_7cc
	tst.l	d0
	bmi	t_3be
	moveq	#0,d0
	btst	#0,$19(a0)
	beq.s	t_318
	or	#2,d0
t_318:
	btst	#1,$19(a0)
	beq.s	t_326
	or	#$10,d0
t_326:
	tst.b	d0
	beq.s	t_332
	move	d3,d1
	and.b	d0,d1
	beq	t_2fc
t_332:
	move.b	d3,$14(a5)
	move.b	d0,$15(a5)
	move.b	$12(a0),d0
	sub.b	#$50,d0
	and	#$7f,d0
	move.b	$13(a0),d1
	and	#15,d1
	move.b	$14(a0),d2
	and	#$1f,d2
	ror	#7,d0
	asl	#5,d1
	or	d1,d0
	or	d2,d0
	move	d0,$18(a5)
	move.b	$15(a0),d0
	and	#$1f,d0
	move.b	$16(a0),d1
	and	#$3f,d1
	move.b	$17(a0),d2
	asr	#1,d2
	and	#$1f,d2
	ror	#5,d0
	asl	#5,d1
	or	d1,d0
	or	d2,d0
	move	d0,$16(a5)
	move.l	14(a0),$1a(a5)
	move	b_f50(pc),d0
	lea	b_f44(pc),a2
	lea	$1e(a5),a1
	tst	d0
	beq.s	t_3aa
	subq	#1,d0
t_3a4:
	move.b	(a2)+,(a1)+
	dbra	d0,t_3a4
t_3aa:
	move.b	#0,(a1)+
	movea.l	a5,a0
	move.l	$1e(a3),(a0)+
	move	$22(a3),(a0)+
	move	$24(a3),(a0)+
	moveq	#0,d0
t_3be:
;
	lv_exit		sp
	rts
;
;End of:	ll_Fsnext
;----------------------------------------------------------------------------
;Function:	ll_Frename
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Frename:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	Fren_dummy	;int	Fren_dummy
	lv_arg.l	Fren_oldpath	;char	*Fren_oldpath
	lv_arg.l	Fren_newpath	;char	*Fren_newpath
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Frename
;----------------------------------------------------------------------------
;Function:	ll_Fdatime
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fdatime:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Fdat_time_p	;DOSTIME	*Fdat_time_p
	lv_arg.w	Fdat_handle	;int		Fdat_handle
	lv_arg.w	Fdat_wflag	;int		Fdat_wflag
;
	jsr	check_status
	tst.l	d0
	bmi.s	.exit
	tst	12(sp)
	beq.s	.t_3da
	moveq	#-5,d0
	bra.s	.exit
;
.t_3da:
	jsr	t_652
	tst.l	d0
	bmi.s	.exit
	jsr	t_768
	tst.l	d0
	bmi.s	.exit
	jsr	t_7cc
	tst.l	d0
	bmi.s	.exit
	movea.l	6(sp),a1
	move.b	$15(a0),d0
	and	#$1f,d0
	move.b	$16(a0),d1
	and	#$3f,d1
	move.b	$17(a0),d2
	asr	#1,d2
	and	#$1f,d2
	ror	#5,d0
	asl	#5,d1
	or	d1,d0
	or	d2,d0
	move	d0,(a1)+
	move.b	$12(a0),d0
	sub.b	#$50,d0
	and	#$7f,d0
	move.b	$13(a0),d1
	and	#15,d1
	move.b	$14(a0),d2
	and	#$1f,d2
	ror	#7,d0
	asl	#5,d1
	or	d1,d0
	or	d2,d0
	move	d0,(a1)+
	moveq	#0,d0
.exit:
	lv_exit		sp
	rts
;
;End of:	ll_Fdatime
;----------------------------------------------------------------------------
;Function:	ll_Fcntl
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fcntl:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	Fcntl_handle	;int	Fcntl_handle
	lv_arg.l	Fcntl_arg_p	;void	*Fcntl_arg_p
	lv_arg.w	Fcntl_cmd	;int	Fcntl_cmd
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Fcntl
;----------------------------------------------------------------------------
;Function:	ll_Dpathconf
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dpathconf:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Dpathconf_path	;void	*Dpathconf_path
	lv_arg.w	Dpathconf_cmd	;int	Dpathconf_cmd
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Dpathconf
;----------------------------------------------------------------------------
;Function:	ll_Dopendir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Dopendir:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Dopendir_path	;void	*Dopendir_path
	lv_arg.w	Dopendir_mode	;int	Dopendir_mode
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Dopendir
;----------------------------------------------------------------------------
;Function:	ll_Dxreaddir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Dxreaddir:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	Dxread_len	;int	Dxread_len
	lv_arg.l	Dxread_handle	;long	Dxread_handle
	lv_arg.l	Dxread_buf	;long	*Dxread_buf
	lv_arg.l	Dxread_xap	;XATTR	*Dxread_xap
	lv_arg.l	Dxread_xret	;long	*Dxread_xret
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Dxreaddir
;----------------------------------------------------------------------------
;Function:	ll_Dreaddir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Dreaddir:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	Dread_len	;int	Dread_len
	lv_arg.l	Dread_handle	;long	Dread_handle
	lv_arg.l	Dread_buf	;long	*Dread_buf
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Dreaddir
;----------------------------------------------------------------------------
;Function:	ll_Drewinddir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Drewinddir:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Drew_handle	;long	Drew_handle
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Drewinddir
;----------------------------------------------------------------------------
;Function:	ll_Dclosedir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Dclosedir:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Dclose_handle	;long	Dclose_handle
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Dclosedir
;----------------------------------------------------------------------------
;Function:	ll_Fxattr
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Fxattr:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	Fxatt_mode	;int	Fxatt_mode
	lv_arg.l	Fxatt_path	;char	*Fxatt_path
	lv_arg.l	Fxatt_xap	;XATTR	*Fxatt_xap
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Fxattr
;----------------------------------------------------------------------------
;Function:	ll_Flink
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path	(of 'newpath')
ll_Flink:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Flink_oldpath	;char	*Flink_oldpath
	lv_arg.l	Flink_newpath	;char	*Flink_newpath
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Flink
;----------------------------------------------------------------------------
;Function:	ll_Fsymlink
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path	(of 'newpath')
ll_Fsymlink:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	Flink_oldpath	;char	*Flink_oldpath
	lv_arg.l	Flink_newpath	;char	*Flink_newpath
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Fsymlink
;----------------------------------------------------------------------------
;Function:	ll_Freadlink
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path	(of 'newpath')
ll_Freadlink:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	Frdlk_size	;int	Frdlk_size
	lv_arg.l	Frdlk_buff	;char	*Frdlk_buff
	lv_arg.l	Frdlk_path	;char	*Frdlk_path
;
	moveq	#E_INVFN,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Freadlink
;----------------------------------------------------------------------------
;Function:	ll_Dcntl
;Entry state:	a3:	LDB	*ldb
;		a4:	char	*expanded_path
;
ll_Dcntl:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.w	Dcntl_cmd	;int	Dcntl_cmd
	lv_arg.l	Dcntl_path	;char	*Dcntl_path
	lv_arg.l	Dcntl_arg	;long	Dcntl_arg
;
	jsr	check_status
	tst.l	d0
	bmi.s	.exit
	xbios	Metaioctl|_ind,(a3),#'FCTL',10(sp),12(sp)
.exit:
;
	lv_exit		sp
	rts
;
;End of:	ll_Dcntl
;----------------------------------------------------------------------------
;Function:	ll_Dreadlabel
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dreadlabel:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	path	;char	*path
	lv_arg.l	name	;char	*name
	lv_arg.w	size	;int	size
	lv_arg.b	dta,sizeof_dta_struct
	lv_arg.l	old_dta_p
;
	gemdos	Fgetdta
	move.l	d0,old_dta_p(a6)
	gemdos	Fsetdta,dta(a6)
	gemdos	Fsfirst|_ind,path(a6),FA_LABEL
.test_loop:
	tst.l	d0
	bmi.s	.fail_find
	btst	#b_FA_LABEL,dta_fattr+dta(a6)
	bne.s	.found_label
	gemdos	Fsnext
	bra	.test_loop
;
.found_label:
	lea	dta_fname+dta(a6),a0
	move.l	a0,a1
.strlen_lp:
	tst.b	(a1)+
	bne	.strlen_lp
	sub.l	a0,a1
	cmp	size(a6),a0
	bhi.s	.error_RANGE
	move.l	name(a6),a1
.strcpy_lp:
	move.b	(A0)+,(a1)+
	bne	.strcpy_lp
	moveq	#E_OK,d3
	bra.s	.exit_d3
;
.error_RANGE:
	moveq	#E_RANGE,d3
	bra.s	.exit_d3
;
.fail_find:
	moveq	#E_FILNF,d3
.exit_d3:
	gemdos	Fsetdta|_ind,old_dta_p(a6)
	move.l	d3,d0
	lv_exit	a6
	rts
;
;End of:	ll_Dreadlabel
;----------------------------------------------------------------------------
;Function:	ll_Dwritelabel
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dwritelabel:
	lv_init		sp
	lv_arg.w	DOS_opcode
	lv_arg.l	path	;char	*path
	lv_arg.l	name	;char	*name
;
	moveq	#E_WRPRO,d0
;
	lv_exit		sp
	rts
;
;End of:	ll_Dwritelabel
;----------------------------------------------------------------------------
;End of:	ll_functions	low level functions wrapping high level ones
;----------------------------------------------------------------------------
;Start of:	General Subroutines
;----------------------------------------------------------------------------
ll_init_device:
	move.l	#-1,$26(a3)
	move.l	d3,-(sp)
	bsr.s	t_512
	add.l	#$10,d0
	move.l	d0,d3
t_54e:
	move.l	d3,d0
	jsr	t_8f6
	tst.l	d0
	bmi.s	t_5bc
	lea	$2a(a3),a0
	cmpi.b	#1,0(a0)
	beq.s	t_588
	cmpi.b	#-1,0(a0)
	beq.s	t_582
	cmpi.b	#3,0(a0)
	bgt.s	t_582
	addq.l	#1,d3
	bra	t_54e
;
t_582:
	moveq	#-7,d0
	bra.s	t_5bc
;
t_588:
	lea	d_f22,a0
	lea	$2b(a3),a1
	moveq	#5,d0
	jsr	t_99c
	beq	t_54e
	move.l	$7e(a3),2(a3)
	move	$ac(a3),6(a3)
	move.l	$be(a3),12(a3)
	move.l	$b2(a3),8(a3)
	move	#-$1,$1c(a3)
	moveq	#0,d0
t_5bc:
	move.l	(sp)+,d3
	rts
;
;End of:	ll_init_device
;----------------------------------------------------------------------------
t_512:
	movem.l	d1-d7/a0-a6,-(sp)
	clr.l	-(sp)
	xbios	Metaioctl|_ind,(a3),#'FCTL',#$4300,sp
	move.l	(sp)+,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;End of:	t_512
;----------------------------------------------------------------------------
t_652:
	movem.l	d3-d6,-(sp)
	tst	$1c(a3)
	beq.s	t_664
	jsr	t_5c0
t_664:
	move.b	(a4)+,d0
	beq	t_758
	cmp.b	#':',d0
	bne	t_664
	moveq	#0,d3
	lea	$82a(a3),a2
	move.l	2(a2,d3.w),d5
	moveq	#1,d2
	moveq	#1,d4
	cmpi.b	#'\',(a4)
	bne	t_760
	addq.l	#1,a4
t_688:
	movea.l	a4,a0
t_68a:
	move.b	(a0)+,d0
	beq	t_760
	cmp.b	#'\',d0
	bne	t_68a
	move.b	0(a2,d3.w),d6
	addq	#1,d6
	and	#$fe,d6
	addq	#8,d6
	add	d3,d6
	cmp	$10(a3),d6
	bgt.s	t_6f8
	cmp	6(a2,d3.w),d2
	bhi.s	t_6f2
	bcs	t_758
	movea.l	a4,a0
	movea.l	a2,a1
	adda	d3,a1
	adda	#8,a1
	clr	d0
	move.b	0(a2,d3.w),d0
	cmpi	#12,d0
	ble.s	t_6d2
	moveq	#12,d0
t_6d2:
	jsr	t_99c
	beq.s	t_6f2
	move	d4,d2
	move.l	2(a2,d3.w),d5
t_6e2:
	move.b	(a4),d0
	beq.s	t_760
	adda	#1,a4
	cmp.b	#'\',d0
	bne	t_6e2
t_6f2:
	addq	#1,d4
	move	d6,d3
	bra	t_688
;
t_6f8:
	tst	$1a(a3)
	ble.s	t_758
	movea.l	a2,a0
t_702:
	cmp	$10(a3),d3
	bge.s	t_712
	move	0(a2,d3.w),(a0)+
	addq	#2,d3
	bra	t_702
;
t_712:
	move	#-$1,$1c(a3)
	movem.l	d2/a2,-(sp)
	move	#1,-(sp)
	move.l	$16(a3),-(sp)
	move.l	a0,-(sp)
	move	0(a3),-(sp)
	move	#(Metaread&$ff),-(sp)
	suba.l	a2,a0
	adda	#$800,a0
	move	a0,$10(a3)
	trap	#14
	lea	14(sp),sp
	movem.l	(sp)+,d2/a2
	tst.l	d0
	bmi.s	t_758
	subi	#1,$1a(a3)
	addq.l	#1,$16(a3)
	clr	d3
	bra	t_688
;
t_758:
	moveq	#-$22,d0
	movem.l	(sp)+,d3-d6
	rts
;
t_760:
	move.l	d5,d0
	movem.l	(sp)+,d3-d6
	rts
;
;End of:	t_652
;----------------------------------------------------------------------------
t_5c0:
	move.l	8(a3),d0
	cmp.l	#$800,d0
	bge.s	.t_5d4
	move.l	#$800,d0
.t_5d4:
	cmp.l	#$2000,d0
	ble.s	.t_5e4
	move.l	#$2000,d0
.t_5e4:
	move	d0,$10(a3)
	move.l	12(a3),d0
	cmpi	#$200,6(a3)
	beq.s	.t_604
	cmpi	#$400,6(a3)
	beq.s	.t_606
	bra.s	.t_608
;
.t_604:
	asr.l	#1,d0
.t_606:
	asr.l	#1,d0
.t_608:
	move.l	d0,$12(a3)
	xbios	Metaread,(a3),$82a(a3),d0,#4
	move.l	8(a3),d0
	divu	#$800,d0
	move.l	d0,d1
	and.l	#-$10000,d1
	beq.s	.t_63a
	addq	#1,d0
.t_63a:
	subq	#4,d0
	move	d0,$1a(a3)
	move.l	$12(a3),d0
	addq.l	#4,d0
	move.l	d0,$16(a3)
	move	#0,$1c(a3)
	rts
;
;End of:	t_5c0
;----------------------------------------------------------------------------
t_768:
	cmpi	#$200,6(a3)
	beq.s	t_780
	cmpi	#$400,6(a3)
	beq.s	t_782
	bra.s	t_784
;
t_780:
	asr.l	#1,d0
t_782:
	asr.l	#1,d0
t_784:
	move.l	d0,$1e(a3)
	jsr	t_8f6
	tst.l	d0
	bmi.s	t_7ca
	lea	$2a(a3),a0
	move.l	14(a0),d0
	divu	#$800,d0
	move.l	d0,d1
	and.l	#-$10000,d1
	beq.s	t_7ae
	addq	#1,d0
t_7ae:
	subq	#1,d0
	move	d0,$22(a3)
	moveq	#0,d0
	tst.b	(a4)
	beq.s	t_7c4
	move.b	0(a0),d0
	add.b	0(a0,d0.w),d0
t_7c4:
	move	d0,$24(a3)
	moveq	#0,d0
t_7ca:
	rts
;
;End of:	t_768
;----------------------------------------------------------------------------
t_7cc:
	movem.l	d3/d4,-(sp)
	move.l	$1e(a3),d0
	jsr	t_8f6
	tst.l	d0
	bmi	t_8f0
	lea	$2a(a3),a2
	move	$24(a3),d3
	tst.b	(a4)
	beq	t_8de
t_7ee:
	cmp	#$800,d3
	bge	t_8a8
	tst.b	0(a2,d3.w)
	beq	t_8a8
	clr	d0
	move.b	$20(a2,d3.w),d0
	movea.l	a2,a1
	adda	d3,a1
	adda	#$21,a1
	lea	b_f44(pc),a0
	clr.l	d1
t_814:
	subi	#1,d0
	bmi.s	t_880
	move.b	(a1)+,d2
	cmpi.b	#$3b,d2
	beq.s	t_880
	cmpi.b	#$2e,d2
	beq.s	t_850
	move.b	d2,(a0)+
	addq	#1,d1
	cmpi	#8,d1
	blt	t_814
t_838:
	subi	#1,d0
	bmi.s	t_880
	move.b	(a1)+,d2
	cmpi.b	#$3b,d2
	beq.s	t_880
	cmpi.b	#$2e,d2
	bne	t_838
t_850:
	moveq	#-1,d4
	cmpi	#3,d0
	ble.s	t_85c
	moveq	#3,d0
t_85c:
	subq	#1,d0
	bmi.s	t_880
	move.b	(a1)+,d2
	cmp.b	#$3b,d2
	beq.s	t_880
	tst	d4
	beq.s	t_87a
	move.b	#$2e,(a0)+
	addq	#1,d1
	moveq	#0,d4
t_87a:
	move.b	d2,(a0)+
	addq	#1,d1
	bra	t_85c
;
t_880:
	move	d1,d0
	move	d1,b_f50
	lea	b_f44(pc),a1
	movea.l	a4,a0
	jsr	t_99c
	bne.s	t_8de
	move.b	0(a2,d3.w),d0
	beq.s	t_8d8
	add	d0,d3
	bra	t_7ee
;
t_8a8:
	subi	#1,$22(a3)
	bmi.s	t_8d8
	addi.l	#1,$1e(a3)
	move.l	$1e(a3),d0
	lea	$2a(a3),a0
	jsr	t_8f6
	tst.l	d0
	bmi.s	t_8f0
	lea	$2a(a3),a2
	moveq	#0,d3
	bra	t_7ee
;
t_8d8:
	moveq	#-$21,d0
	bra.s	t_8f0
;
t_8de:
	movea.l	a2,a0
	adda	d3,a0
	moveq	#0,d0
	move.b	0(a2,d3.w),d0
	add	d0,d3
	move	d3,$24(a3)
	moveq	#0,d0
t_8f0:
	movem.l	(sp)+,d3/d4
	rts
;
;End of:	t_7cc
;----------------------------------------------------------------------------
t_8f6:
	cmp.l	$26(a3),d0
	beq.s	t_934
	move.l	d0,$26(a3)
	move.l	d3,-(sp)
	move	#3,d3
	move	#1,-(sp)
	move.l	d0,-(sp)
	pea	$2a(a3)
	move	0(a3),-(sp)
	move	#(Metaread&$ff),-(sp)
t_91a:
	trap	#14
	tst.l	d0
	bpl.s	t_92e
	dbra	d3,t_91a
	move.l	#-1,$26(a3)
t_92e:
	lea	14(sp),sp
	move.l	(sp)+,d3
t_934:
	rts
;
;End of:	t_8f6
;----------------------------------------------------------------------------
check_status:
	move.l	b_f3c(pc),d0
	cmp.l	(_hz_200).w,d0
	bcs.s	t_94c
	move.l	b_f40(pc),d0
	rts
;
t_94c:
	move.l	(_hz_200).w,b_f3c
	addi.l	#400,b_f3c
	jsr	get_status
	tst.l	d0
	bmi.s	.exit
	and	#8,d0
	beq.s	.exit
	jsr	ll_init_device
.exit:
	rts
;
;End of:	check_status
;----------------------------------------------------------------------------
get_status:
	xbios	Metastatus,(a3),0.w
	tst.l	d0
	bpl.s	.exit
	moveq	#E_DEVNRSP,d0
.exit:
	move.l	d0,b_f40
	rts
;
;End of:	get_status
;----------------------------------------------------------------------------
t_99c:
	subq	#1,d0
	bmi.s	t_9fc
t_9a2:
	move.b	(a0),d1
	beq.s	t_a0e
	cmp.b	#'\',d1
	beq.s	t_a0e
	cmp.b	#'*',d1
	beq.s	t_9d0
	cmp.b	#'?',d1
	beq.s	t_9f4
	cmp.b	(a1)+,d1
	bne.s	t_a0e
	addq.l	#1,a0
	dbra	d0,t_9a2
	bra.s	t_9fc
;
t_9d0:
	addq.l	#1,a0
	move.b	(a0),d1
	beq.s	t_a0a
	cmp.b	#'\',d1
	beq.s	t_a0a
	cmp.b	#'*',d1
	beq	t_9d0
t_9e6:
	cmp.b	(a1),d1
	beq	t_9a2
	addq.l	#1,a1
	dbra	d0,t_9e6
	bra.s	t_9fc
;
t_9f4:
	addq.l	#1,a0
	addq.l	#1,a1
	dbra	d0,t_9a2
t_9fc:
	move.b	(a0),d1
	beq.s	t_a0a
	cmp.b	#'\',d1
	bne.s	t_a0e
t_a0a:
	moveq	#-1,d0
	rts
;
t_a0e:
	moveq	#0,d0
	rts
;
;End of:	T_99c
;----------------------------------------------------------------------------
Init_FunctionTable:
	lea	InitTable(pc),a0
	lea	FunctionTable(pc),a1
	move.l	a1,a2
	move	#(MAX_Func+5)-1,d0
	move.l	#ll_INVFN,d1
.loop_1:				;loop back for primary init
	move.l	d1,(a2)+		;mark function as invalid
	dbra	d0,.loop_1		;loop back for primary init completion
;
	move	(a0)+,d0		;d0 = longs of first block
.loop_2:				;loop start for each block
	subq	#1,d0			;d0 = adapted for dbra
	move	(a0)+,d1		;d1 = index relative to function 0
	addq	#4,d1			;d1 = index relative to table base
	asl	#2,d1			;d1 = offset relative to table base
	lea	(a1,d1.w),a2		;a2 -> current destination block
.loop_3:				;loop start for block copy
	move.l	(a0)+,(a2)+		;copy one long of block
	dbra	d0,.loop_3		;loop back for entire block
	move	(a0)+,d0		;d0 = longs of next block
	bne	.loop_2			;loop back unless empty block (end mark)
	rts
;
;End of:	Init_FunctionTable
;----------------------------------------------------------------------------
;End of:	General Subroutines
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
InitTable:
	dc.w	4,-4
	dc.l		'MAGI','CMET',MAX_Func,ll_initfun
	dc.w	1,(Dfree&$ff)
	dc.l		ll_Dfree
	dc.w	3,(Dcreate&$ff)
	dc.l		ll_Dcreate,ll_Ddelete,ll_Dsetpath
	dc.w	8,(Fcreate&$ff)
	dc.l		ll_Fcreate,ll_Fopen,ll_Fclose,ll_Fread
	dc.l		ll_Fwrite,ll_Fdelete,ll_Fseek,ll_Fattrib
	dc.w	2,(Fsfirst&$ff)
	dc.l		ll_Fsfirst,ll_Fsnext
	dc.w	1,(Frename&$ff)
	dc.l		ll_Frename
	dc.w	1,(Fdatime&$ff)
	dc.l		ll_Fdatime
	dc.w	1,260
	dc.l		ll_Fcntl
	dc.w	1,292
	dc.l		ll_Dpathconf
	dc.w	9,296
	dc.l		ll_Dopendir,ll_Dreaddir,ll_Drewinddir,ll_Dclosedir
	dc.l		ll_Fxattr,ll_Flink,ll_Fsymlink,ll_Freadlink
	dc.l		ll_Dcntl
	dc.w	1,322
	dc.l		ll_Dxreaddir
	dc.w	1,338
	dc.l		ll_Dreadlabel
	dc.w	1,339
	dc.l		ll_Dwritelabel
	dc.w	0	
;----------------------------------------------------------------------------
d_f22:
	dc.b	'CD001',0,'@(#)'
DEV_NAME_s:
	DEV_NAME
	dc.b		' v'
	DEV_VERSION
	dc.b		NUL
	even
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
FunctionTable:
	ds.l	MAX_Func+5
;----------------------------------------------------------------------------
b_f3c:
	ds.l	1
b_f40:
	ds.l	1
b_f44:
	ds.l	3
b_f50:
	ds.w	1
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
; End of file:	Skele_FS.S
;----------------------------------------------------------------------------
