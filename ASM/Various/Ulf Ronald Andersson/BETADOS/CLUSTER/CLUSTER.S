;----------------------------------------------------------------------------
; File name:	Cluster.S			Revision date:	1999.12.27
; Created by:	Ulf Ronald Andersson		Creation date:	1998.03.13
;----------------------------------------------------------------------------
; Purpose:
;
;	Defines a 'cluster' of symbolic links to implement a 'unified'
;	drive similar in capabilities to that used under MagiC or MiNT.
;	This filesystem will also work under MagiC or MiNT, but is mainly
;	intended for singletasking TOS, or rather to make sure that such
;	a unified drive is available for all runtime environments.
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_FCNTL.I
	include	RA_RAM.I
;----------------------------------------------------------------------------
	output	.TOS
;----------------------------------------------------------------------------
MAX_Func	=	349
;----------------------------------------------------------------------------
;---;Edit FS_mode_bits to suit filesystem needs
;
FS_mode_bits	=	5	;b2=writable  b1=rel_paths  b0=sensecase
;----------------------------------------------------------------------------
dpc_LIMIT	=	8
opn_LIMIT	=	40
lnk_LIMIT	=	1
pth_LIMIT	=	128
fnm_LIMIT	=	32
wrt_LIMIT	=	1
abb_CODE	=	0
ccm_CODE	=	1
fsm_CODE	=	$01900000
xat_CODE	=	$0802
sln_LIMIT	=	1<<7
dta_LIMIT	=	1<<6
RAM_chunk	=	4096
;----------------------------------------------------------------------------
DEV_NAME	MACRO
	dc.b	'Cluster driver'
	ENDM
DEV_VERSION	MACRO
	dc.b	'3.07'
	ENDM
DEV_LABEL	MACRO
	dc.b	'Cluster Drive '
	ENDM
;----------------------------------------------------------------------------
	struct	sln
	struc_p	sln_next
	char_p	sln_name
	char_p	sln_path
	d_end	sln
;----------------------------------------------------------------------------
	struct	XDTA
	struc_p	XDTA_prev
	struc_p	XDTA_next
	d_s	XDTA_dta,sizeof_dta_struct
	d_end	XDTA
;----------------------------------------------------------------------------
	struct	LDB
	uint32	LDB_device_type
	uint16	LDB_DOS_char
	uint16	LDB_BOS_char
	uint16	LDB_DOS_parm
	uint16	LDB_DOS_drive
	uint32	LDB_DOS_bit
	uint32	LDB_blk_drives
	d_s	LDB_name,fnm_LIMIT+2
	d_s	LDB_drv_names,32<<1
	d_s	LDB_drv_paths,32<<2
	d_s	LDB_drv_pool,32*sizeof_sln
	word	LDB_drv_ix
	d_s	LDB_usr_pool,sln_LIMIT*sizeof_sln
	word	LDB_usr_ix
	struc_p	LDB_usr_chain
	struc_p	LDB_sln_chain
	word	LDB_sln_ix
	d_s	LDB_xdta_arr,dta_LIMIT*sizeof_XDTA
	struc_p	LDB_first_xdta
	struc_p	LDB_last_xdta
	uint32	LDB_tune_ix
	d_end	LDB
;----------------------------------------------------------------------------
	struct	my_FCB
	uint16	FCB_handle	;long internal handle for directory or file
	uint16	FCB_file_handle	;part of above, for gemdos file functions
	uint16	FCB_device	;gemdos	device
	uint16	FCB_tune	;tune_path index
	struc_p	FCB_dta_p	;->DTA struct for Dxxx simulation
	uint16	FCB_dirmode	;Dxxx compatibility mode flag
	uint32	FCB_dir_ix	;inode index
	d_end	my_FCB
;------------------------------------
	IFNE	(sizeof_my_FCB>(8*4))
	FAIL	"structure my_FCB is too large"
	ENDC
;----------------------------------------------------------------------------
	struct	xbios_TIME
	uint16	xbios_date
	uint16	xbios_time
	d_end	xbios_TIME
;----------------------------------------------------------------------------
	struct	DISKINFO
	uint32	DI_b_free		;free clusters
	uint32	DI_b_total		;total clusters
	uint32	DI_b_secsiz		;bytes per sector
	uint32	DI_b_clsiz		;sectors per cluster
	d_end	DISKINFO
;----------------------------------------------------------------------------
get_DTA	MACRO	areg
; Here all xdta structs existing are inside the queue, go for unused end
	move.l	LDB_first_xdta(a3),\1
	move.l	XDTA_next(\1),a1
	move.l	a1,LDB_first_xdta(a3)
	clr.l	XDTA_prev(a1)
	clr.l	XDTA_next(\1)
; Now the longest unused xdta is outside the queue, at (\1)
	move.l	LDB_last_xdta(a3),a1
	move.l	a1,XDTA_prev(\1)
	move.l	\1,XDTA_next(a1)
	move.l	\1,LDB_last_xdta(a3)
; Again all xdta structs are inside the queue, but the taken one is last
	ENDM	;get_DTA
;----------------------------------------------------------------------------
ref_DTA	MACRO	areg
; Here all xdta structs existing are inside the queue, we remove ours now
	move.l	XDTA_prev(\1),d0
	beq.s	.has_no_prev
	move.l	XDTA_next(\1),d1
	beq.s	.prev_but_no_next
	move.l	d0,a0
	move.l	d1,a1
	move.l	d1,XDTA_next(a0)
	move.l	d0,XDTA_prev(a1)
	bra.s	.unlinked
;
.prev_but_no_next:
	move.l	d0,a0
	clr.l	XDTA_next(a0)
	move.l	a0,LDB_last_xdta(a3)
	bra.s	.unlinked
;
.has_no_prev:
	move.l	XDTA_next(\1),a1
	clr.l	XDTA_prev(a1)
	move.l	a1,LDB_first_xdta(a3)
.unlinked:
; Here our xdta is outside the queue, so now we put it back in as LAST one
	clr.l	XDTA_next(\1)
	move.l	LDB_last_xdta(a3),a0
	move.l	a0,XDTA_prev(\1)
	move.l	\1,XDTA_next(a0)
	move.l	\1,LDB_last_xdta(a3)
; Again all xdta structs are inside the queue, but the taken one is last
	ENDM	;ref_DTA
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
	lea	DEV_NAME_s(pc),a0
	move.l	a0,d1			;d1 -> driver name string
	move.l	#FunctionTable+12,d0	;d0 -> FunctionTable+12
	rts
;
;End of:	ll_bootup
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
	movem.l	d2-d7/a0-a6,-(sp)	;push entry registers
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
	bra	.done
;
.have_mem:
	RAM_own	#1			;setup current bp as owner
	RAM_add	#RAM_chunk		;get more RAM for internal use
	ble	.failure
	movem.l	(sp),d0/d2/a2		;restore parameter copies
	move.l	#FS_mode_bits,LDB_device_type(a3)
	move	d0,LDB_BOS_char(a3)
	move	d2,LDB_DOS_char(a3)
	move.l	a2,LDB_DOS_parm(a3)
	sub	#'A',d2
	move	d2,LDB_DOS_drive(a3)
	moveq	#1,d1
	lsl.l	d2,d1
	move.l	d1,LDB_DOS_bit(a3)	;store 'own' drive bit
	or.l	#(1<<('U'-'A')),d1	;combine with 'U:' bit for disabling
	or.l	#3,d1			;also disable floppy bits
	move.l	d1,LDB_blk_drives(a3)	;store bits of drives not to be included
;
	lea	init_label_s(pc),a0
	lea	LDB_name(a3),a1
.strcpy_lp:
	move.b	(a0)+,(a1)+
	bne.s	.strcpy_lp
	move.b	LDB_DOS_char+1(a3),-1(a1)
	clr.b	(a1)
;
	clr	LDB_drv_ix(a3)
	clr	LDB_usr_ix(a3)
	clr	LDB_sln_ix(a3)
	clr.l	LDB_usr_chain(a3)
	clr.l	LDB_sln_chain(a3)
;
	bsr	rebuild_drive_chain
;
	lea	LDB_xdta_arr(a3),a2
	move.l	a2,LDB_first_xdta(a3)
	clr.l	d1
	move	#dta_LIMIT-1,d2
.loop:
	move.l	d1,XDTA_prev(a2)
	lea	sizeof_XDTA(a2),a1
	move.l	a1,XDTA_next(a2)
	move.l	a2,d1
	move.l	a1,a2
	dbra	d2,.loop
	move.l	d1,a0
	clr.l	XDTA_next(a0)
	move.l	a0,LDB_last_xdta(a3)
;
.done:
	add	#3*4,sp			;drop parameter copies from stack
	moveq	#FS_mode_bits,d1	;d1 = filesystem mode bits
	move.l	a3,d0			;d0 -> allocated LDB (or is error code)
	movem.l	(sp)+,d2-d7/a0-a6	;pull entry registers
	rts
;
;End of:	ll_initfun
;----------------------------------------------------------------------------
;Function:	ll_INVFN
;
ll_INVFN:
	moveq	#E_INVFN,d0
	rts
;
;End of:	ll_INVFN
;----------------------------------------------------------------------------
;Function:	error_INVFN
;
error_INVFN:
	moveq	#E_INVFN,d0
	unlk	a6
	rts
;
;End of:	error_INVFN
;----------------------------------------------------------------------------
;Function:	error_PTHNF
;
error_PTHNF:
	moveq	#E_PTHNF,d0
	unlk	a6
	rts
;
;End of:	error_PTHNF
;----------------------------------------------------------------------------
;Function:	error_NMFIL
;
error_NMFIL:
	moveq	#E_NMFIL,d0
	unlk	a6
	rts
;
;End of:	error_NMFIL
;----------------------------------------------------------------------------
;Function:	error_FILNF
;
error_FILNF:
	moveq	#E_FILNF,d0
	unlk	a6
	rts
;
;End of:	error_FILNF
;----------------------------------------------------------------------------
;Function:	error_ACCDN
;
error_ACCDN:
	moveq	#E_ACCDN,d0
	unlk	a6
	rts
;
;End of:	error_ACCDN
;----------------------------------------------------------------------------
;Function:	error_BADRQ
;
error_BADRQ:
	moveq	#E_BADRQ,d0
	unlk	a6
	rts
;
;End of:	error_BADRQ
;----------------------------------------------------------------------------
;Function:	error_RANGE
;
error_RANGE:
	moveq	#E_RANGE,d0
	unlk	a6
	rts
;
;End of:	error_RANGE
;----------------------------------------------------------------------------
;Function:	error_IHNDL
;
error_IHNDL:
	moveq	#E_IHNDL,d0
	unlk	a6
	rts
;
;End of:	error_IHNDL
;----------------------------------------------------------------------------
;Function:	error_NSMEM
;
error_NSMEM:
	moveq	#E_NSMEM,d0
	unlk	a6
	rts
;
;End of:	error_NSMEM
;----------------------------------------------------------------------------
;Function:	error_NOSYM
;
error_NOSYM:
	moveq	#E_LOOP,d0
	unlk	a6
	rts
;
;End of:	error_NOSYM
;----------------------------------------------------------------------------
;Function:	return_OK
;
return_OK:
	moveq	#E_OK,d0
	unlk	a6
	rts
;
;End of:	return_OK
;----------------------------------------------------------------------------
;Start of:	ll_functions for gemdos function
;----------------------------------------------------------------------------
;Function:	ll_Dfree
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dfree:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	dfree_buf	;DISKINFO	*dfree_buf
	lv_arg.w	dfree_drive	;int		 dfree_drive
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
	tst	d0
	bmi	error_PTHNF
	cmp	#2,d0
	beq	error_PTHNF
	bhi.s	.physical
.got_cluster_root:
	move.l	dfree_buf(a6),a0	;a0 -> result buffer
	clr.l	DI_b_free(a0)		;store free clusters
	clr.l	DI_b_total(a0)		;store total clusters
	move.l	#2,DI_b_clsiz(a0)	;store sectors per cluster
	move.l	#512,DI_b_secsiz(a0)	;store bytes per sector
	moveq	#E_OK,d0
	bra.s	.exit
;-------
.physical:
	clr	d0
	move.b	int_path(a6),d0
	cmp.b	#'a',d0
	blo.s	.have_case
	cmp.b	#'z',d0
	bhi.s	.have_case
	add.b	#'A'-'a',d0
.have_case:
	add.b	#1-'A',d0
	gemdos	Dfree|_ind,dfree_buf(a6),d0	;call Dfree for real drive
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Dfree
;----------------------------------------------------------------------------
;Function:	ll_Dcreate
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dcreate:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;char	*pathname
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
	tst	d0
	bmi	error_PTHNF
	cmp	#6,d0
	bne	error_ACCDN
	gemdos	Dcreate,int_path(a6)
	lv_exit	a6
	rts
;
;End of:	ll_Dcreate
;----------------------------------------------------------------------------
;Function:	ll_Ddelete
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Ddelete:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;char	*pathname
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
	tst	d0
	bmi	error_PTHNF
	cmp	#6,d0
	beq	.physical
	cmp	#5,d0
	beq	error_ACCDN
	cmp	#3,d0
	blt	error_ACCDN
.symlink:
	move	LDB_tune_ix+2(a3),d0
	subq	#1,d0
	cmp	LDB_sln_ix(a3),d0
	bhs	error_ACCDN
	cmp	LDB_drv_ix(a3),d0
	bhs.s	.not_drive_sym
	lea	LDB_drv_pool(a3),a2
	bra.s	.index_fname
;
.not_drive_sym:
	sub	LDB_drv_ix(a3),d0
	lea	LDB_usr_pool(a3),a2
.index_fname:
	mulu	#sizeof_sln,d0
	lea	(a2,d0.w),a5		;a5 -> found sln
;
	lea	LDB_usr_pool(a3),a0
	cmp.l	a0,a5
	bhs.s	.user_link
.drive_link:
	clr	d0
	move.l	sln_name(a5),a0
	move.b	(a0),d0
	sub	#'A',d0
	moveq	#1,d1
	asl.l	d0,d1
	or.l	d1,LDB_blk_drives(a3)
	bsr	rebuild_drive_chain
	moveq	#E_OK,d0
	bra.s	.exit
;
.user_link:
	R_free.i	sln_name(a5)
	R_free.i	sln_path(a5)
	cmp	LDB_usr_chain(a3),a5
	bne.s	.fix_chain
	move.l	sln_next(a5),LDB_usr_chain(a3)
	beq.s	.done_chain
	move.l	a5,LDB_usr_chain(a3)
.fix_chain:
	move.l	sln_next(a5),d0
	beq.s	.end_chain
.fix_chain_lp:
	lea	sizeof_sln(a5),a0
	move.l	sln_name(a0),sln_name(a5)
	move.l	sln_path(a0),sln_path(a5)
	move.l	a0,sln_next(a5)
	move.l	a0,a5
	move.l	sln_next(a5),d0
	bne	.fix_chain_lp
.end_chain:
	clr.l	sln_next-sizeof_sln(a5)
.done_chain:
	subq	#1,LDB_usr_ix(a3)
	bsr	rebuild_drive_chain
	moveq	#E_OK,d0
	bra.s	.exit
;	
.physical:
	gemdos	Ddelete,int_path(a6)
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Ddelete
;----------------------------------------------------------------------------
;Function:	ll_Fcreate
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fcreate:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;char	*pathname
	lv_arg.w	mode		;int	mode
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
	tst	d0
	bmi	error_PTHNF
	cmp	#6,d0
	bne	error_ACCDN
	gemdos	Fcreate,int_path(a6),mode(a6)
	move.l	d0,FCB_handle(a5)
	bpl	return_OK
	lv_exit	a6
	rts
;
;End of:	ll_Fcreate
;----------------------------------------------------------------------------
;Function:	ll_Fopen
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fopen:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;char	*pathname
	lv_arg.w	mode		;int	mode
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
	tst	d0
	bmi	error_PTHNF
	cmp	#3,d0
	blt	error_ACCDN
.try_func:
	gemdos	Fopen,int_path(a6),mode(a6)
	move.l	d0,FCB_handle(a5)
	bmi.s	.exit
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Fopen
;----------------------------------------------------------------------------
;Function:	ll_Fclose
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fclose:
	move.l	FCB_handle(a5),d0
	bmi.s	.exit_ok
	gemdos	Fclose,d0
.exit_ok:
	moveq	#E_OK,d0
	rts
;
;End of:	ll_Fclose
;----------------------------------------------------------------------------
;Function:	ll_Fread
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fread:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	handle	;int	handle
	lv_arg.l	count	;long	count
	lv_arg.l	buffer	;char	*buffer
;
	gemdos	Fread|_ind,FCB_file_handle(a5),count(a6),buffer(a6)
;
	lv_exit	a6
	rts
;
;End of:	ll_Fread
;----------------------------------------------------------------------------
;Function:	ll_Fwrite
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fwrite:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	handle	;int	handle
	lv_arg.l	count	;long	count
	lv_arg.l	buffer	;char	*buffer
;
	gemdos	Fwrite|_ind,FCB_file_handle(a5),count(a6),buffer(a6)
;
	lv_exit	a6
	rts
;
;End of:	ll_Fwrite
;----------------------------------------------------------------------------
;Function:	ll_Fdelete
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Fdelete:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;char	*pathname
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
	tst	d0
	bmi	error_PTHNF
	cmp	#6,d0
	beq	.physical
	cmp	#5,d0
	beq	error_ACCDN
	cmp	#3,d0
	blt	error_ACCDN
.symlink:
	move	LDB_tune_ix+2(a3),d0
	subq	#1,d0
	cmp	LDB_sln_ix(a3),d0
	bhs	error_ACCDN
	cmp	LDB_drv_ix(a3),d0
	bhs.s	.not_drive_sym
	lea	LDB_drv_pool(a3),a2
	bra.s	.index_fname
;
.not_drive_sym:
	sub	LDB_drv_ix(a3),d0
	lea	LDB_usr_pool(a3),a2
.index_fname:
	mulu	#sizeof_sln,d0
	lea	(a2,d0.w),a5		;a5 -> found sln
;
	lea	LDB_usr_pool(a3),a0
	cmp.l	a0,a5
	bhs.s	.user_link
.drive_link:
	clr	d0
	move.l	sln_name(a5),a0
	move.b	(a0),d0
	sub	#'A',d0
	moveq	#1,d1
	asl.l	d0,d1
	or.l	d1,LDB_blk_drives(a3)
	bsr	rebuild_drive_chain
	moveq	#E_OK,d0
	bra.s	.exit
;
.user_link:
	R_free.i	sln_name(a5)
	R_free.i	sln_path(a5)
	cmp	LDB_usr_chain(a3),a5
	bne.s	.fix_chain
	move.l	sln_next(a5),LDB_usr_chain(a3)
	beq.s	.done_chain
	move.l	a5,LDB_usr_chain(a3)
.fix_chain:
	move.l	sln_next(a5),d0
	beq.s	.end_chain
.fix_chain_lp:
	lea	sizeof_sln(a5),a0
	move.l	sln_name(a0),sln_name(a5)
	move.l	sln_path(a0),sln_path(a5)
	move.l	a0,sln_next(a5)
	move.l	a0,a5
	move.l	sln_next(a5),d0
	bne	.fix_chain_lp
.end_chain:
	clr.l	sln_next-sizeof_sln(a5)
.done_chain:
	subq	#1,LDB_usr_ix(a3)
	bsr	rebuild_drive_chain
	moveq	#E_OK,d0
	bra.s	.exit
;	
.physical:
	gemdos	Fdelete,int_path(a6)
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Fdelete
;----------------------------------------------------------------------------
;Function:	ll_Fseek
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fseek:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	offset	;long	offset
	lv_arg.w	handle	;int	handle
	lv_arg.w	mode	;int	mode
;
	gemdos	Fseek,offset(a6),FCB_file_handle(a5),mode(a6)
;
	lv_exit	a6
	rts
;
;End of:	ll_Fseek
;----------------------------------------------------------------------------
;Function:	ll_Fattrib
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Fattrib:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;char	*pathname
	lv_arg.w	wflag		;int	wflag
	lv_arg.w	attr		;int	attr
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
	tst	d0
	bmi	error_PTHNF
	cmp	#6,d0
	beq.s	.physical
	tst	wflag(a6)
	bne	error_ACCDN
	cmp	#5,d0
	beq.s	.physical
	moveq	#$10,d0		;return FA_SUBDIR
	bra.s	.exit
;
.physical:
	gemdos	Fattrib,int_path(a6),wflag(a6),attr(a6)
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Fattrib
;----------------------------------------------------------------------------
;Function:	ll_Fforce
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fforce:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	std_handle
	lv_arg.w	nst_handle
;
	move.l	FCB_handle(a5),d0
	bmi.s	.exit
	gemdos	Fforce,std_handle(a6),d0
.exit:
	lv_exit a6
	rts
;
;End of:	ll_Fforce
;----------------------------------------------------------------------------
;Function:	ll_Fsfirst
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	DTA	*dta
ll_Fsfirst:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;char	*pathname
	lv_arg.w	attr		;int	attr
;
	lv_var.b	int_path,128
	lv_var.b	loc_dta,sizeof_dta_struct
	lv_var.l	old_dta_p
;
	bsr	rebuild_drive_chain
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	cmp	#5,d0
	bge.s	.got_physical
.not_physical:
	tst	d0
	bmi	error_PTHNF
	cmp	#2,d0
	blt	error_NMFIL
	bgt.s	.case_gt_2
.case_2:
	move	#1,dta_reserved+2(a5)
	bra.s	.break_cases
;
.case_gt_2:
	cmp	#4,d0
	beq	error_NMFIL
.case_3:
	move	#0,dta_reserved+2(a5)
	bra.s	.break_cases
;
.got_physical:
	move	#-1,dta_reserved+2(a5)
.break_cases:
	move	#$7F5A,dta_reserved+0(a5)
	move	#$55AA,dta_reserved+4(a5)
	tst	dta_reserved+2(a5)		;physical access needed ?
	bpl	.un_physical
	get_DTA	a2
	move.l	a2,dta_reserved+6(a5)
	gemdos	Fgetdta
	move.l	d0,old_dta_p(a6)
	move.l	dta_reserved+6(a5),a2
	gemdos	Fsetdta,XDTA_dta(a2)
	gemdos	Fsfirst,int_path(a6),attr(a6)
	move.l	d0,dta_reserved+10(a5)
	gemdos	Fsetdta|_ind,old_dta_p(a6)
;
	move.l	dta_reserved+6(a5),a2
	move.b	XDTA_dta+dta_fattr(a2),dta_fattr(a5)
	move	XDTA_dta+dta_ftime(a2),dta_ftime(a5)
	move	XDTA_dta+dta_fdate(a2),dta_fdate(a5)
	move.l	XDTA_dta+dta_fsize(a2),dta_fsize(a5)
;
	move.l	XDTA_dta+dta_fname+0(a2),dta_fname+0(a5)
	move.l	XDTA_dta+dta_fname+4(a2),dta_fname+4(a5)
	move.l	XDTA_dta+dta_fname+8(a2),dta_fname+8(a5)
	move.b	XDTA_dta+dta_fname+12(a2),dta_fname+12(a5)
	clr.b	dta_fname+13(a5)
;
	move.l	dta_reserved+10(a5),d0
	bra	.exit
;
.un_physical_loop:
	move	dta_reserved+2(a5),d0
	beq	error_NMFIL
	cmp	LDB_sln_ix(a3),d0
	bhs	error_NMFIL
	addq	#1,dta_reserved+2(a5)
	cmp	LDB_drv_ix(a3),d0
	bhs.s	.not_drive_sym
	lea	LDB_drv_pool(a3),a2
	bra.s	.index_fname
;
.un_physical:
	move	attr(a6),dta_reserved+6(a5)
	tst.b	dta_reserved+3(a5)
	ble.s	.simulate_unwild
.simulate_wild:
	move.l	LDB_sln_chain(a3),a4
	bra.s	.have_sln_in_a4
;
.simulate_unwild:
	move	LDB_tune_ix+2(a3),d0
	subq	#1,d0
	cmp	LDB_sln_ix(a3),d0
	bhs	error_NMFIL
	cmp	LDB_drv_ix(a3),d0
	bhs.s	.not_drive_sym
	lea	LDB_drv_pool(a3),a2
	bra.s	.index_fname
;
.not_drive_sym:
	sub	LDB_drv_ix(a3),d0
	lea	LDB_usr_pool(a3),a2
.index_fname:
	mulu	#sizeof_sln,d0
	lea	(a2,d0.w),a4		;a4 -> found sln
.have_sln_in_a4:			;from here on a4 -> sln
	move.l	a4,d0
	ble	error_NMFIL
	move.l	sln_path(a4),a0
	lea	int_path(a6),a1
.pass_lp:
	move.b	(a0)+,(a1)+
	bne.s	.pass_lp
	move.l	a0,d0
	sub.l	sln_path(a4),d0
	cmp.l	#4,d0
	ble.s	.sim_DIR
.ref_long:
	sf	d4
	cmp.b	#'\',-2(a1)
	bne.s	.done_unslash
	st	d4
	clr.b	-2(a1)
.done_unslash:
	gemdos	Fgetdta
	move.l	d0,old_dta_p(a6)
	gemdos	Fsetdta,loc_dta(a6)
	gemdos	Fsfirst,int_path(a6),dta_reserved+6(a5)
	move.l	d0,d3
	gemdos	Fsetdta|_ind,old_dta_p(a6)
	tst.l	d3
	bmi.s	.sim_TST
	move.b	dta_fattr+loc_dta(a6),dta_fattr(a5)
	move.l	dta_ftime+loc_dta(a6),dta_ftime(a5)
	move.b	dta_fsize+loc_dta(a6),dta_fsize(a5)
	bra.s	.ref_name
;
.sim_TST:
	tst.b	d4
	bne.s	.sim_DIR
	clr	dta_fattr(a5)
	bra.s	.sim_common
;
.sim_DIR:
	move.b	#$10,dta_fattr(a5)		;FA_SUBDIR
.sim_common:
	move.l	norm_time(pc),dta_ftime(a5)	;ftime & fdate
	clr.l	dta_fsize(a5)
.ref_name:
	move.l	sln_name(a4),a1
	move.l	0(a1),dta_fname+0(a5)
	move.l	4(a1),dta_fname+4(a5)
	move.l	8(a1),dta_fname+8(a5)
	move.b	12(a1),dta_fname+12(a5)
	clr.b	dta_fname+13(a5)
	btst	#4,dta_fattr(a5)	;FA_SUBDIR in result ?
	beq.s	.exit_OK
	btst	#4,dta_reserved+6+1(a5)	;FA_SUBDIR in argument 'attr' ?
	beq	.un_physical_loop	;loop back if DIR unacceptable
.exit_OK:
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Fsfirst
;----------------------------------------------------------------------------
;/* tune_path summary:       */
;/*--------------------------*/
;/* -2 <= illegal root ref	*/
;/* -1 <= illegal root path	*/
;/*  0 <= pure root drive	*/	/*	X:		*/
;/*  1 <= pure root path	*/	/*	X:\		*/
;/*  2 <= wild root link	*/	/*	X:\*		*/
;/*  3 <= root link		*/	/*	X:\dname	*/
;/*  4 <= pure link path	*/	/*	X:\dname\	*/
;/*  5 <= wild link path	*/	/*	X:\dname\*	*/
;/*  6 <= link long path	*/	/*	X:\dname\...	*/
;----------------------------------------------------------------------------
;Function:	ll_Fsnext
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	DTA	*dta
ll_Fsnext:
	lv_init	a6
	lv_arg.w	DOS_opcode
;
	lv_var.b	int_path,128
	lv_var.b	loc_dta,sizeof_dta_struct
	lv_var.l	old_dta_p
;
	cmp	#$7F5A,dta_reserved+0(a5)
	bne	error_NMFIL
	cmp	#$55AA,dta_reserved+4(a5)
	bne	error_NMFIL
	move	dta_reserved+2(a5),d0
	bpl	.un_physical_loop
.got_physical:
	move.l	dta_reserved+6(a5),a2		;a2 -> xdta
	ref_DTA	a2
	gemdos	Fgetdta
	move.l	d0,old_dta_p(a6)
	move.l	dta_reserved+6(a5),a2
	gemdos	Fsetdta,XDTA_dta(a2)
	gemdos	Fsnext
	move.l	d0,dta_reserved+10(a5)
	gemdos	Fsetdta|_ind,old_dta_p(a6)
;
	move.l	dta_reserved+6(a5),a2
	move.b	XDTA_dta+dta_fattr(a2),dta_fattr(a5)
	move	XDTA_dta+dta_ftime(a2),dta_ftime(a5)
	move	XDTA_dta+dta_fdate(a2),dta_fdate(a5)
	move.l	XDTA_dta+dta_fsize(a2),dta_fsize(a5)
;
	move.l	XDTA_dta+dta_fname+0(a2),dta_fname+0(a5)
	move.l	XDTA_dta+dta_fname+4(a2),dta_fname+4(a5)
	move.l	XDTA_dta+dta_fname+8(a2),dta_fname+8(a5)
	move.b	XDTA_dta+dta_fname+12(a2),dta_fname+12(a5)
	clr.b	dta_fname+13(a5)
;
	move.l	dta_reserved+10(a5),d0
	bra	.exit
;
.un_physical_loop:
	move	dta_reserved+2(a5),d0
	beq	error_NMFIL
	cmp	LDB_sln_ix(a3),d0
	bhs	error_NMFIL
	addq	#1,dta_reserved+2(a5)
	cmp	LDB_drv_ix(a3),d0
	bhs.s	.not_drive_sym
	lea	LDB_drv_pool(a3),a2
	bra.s	.index_fname
;
.not_drive_sym:
	sub	LDB_drv_ix(a3),d0
	lea	LDB_usr_pool(a3),a2
.index_fname:
	mulu	#sizeof_sln,d0
	lea	(a2,d0.w),a4		;a4 -> found sln
.have_sln_in_a4:			;from here on a4 -> sln
	move.l	a4,d0
	ble	error_NMFIL
	move.l	sln_path(a4),a0
	lea	int_path(a6),a1
.pass_lp:
	move.b	(a0)+,(a1)+
	bne.s	.pass_lp
	move.l	a0,d0
	sub.l	sln_path(a4),d0
	cmp.l	#4,d0
	ble.s	.sim_DIR
.ref_long:
	sf	d4
	cmp.b	#'\',-2(a1)
	bne.s	.done_unslash
	st	d4
	clr.b	-2(a1)
.done_unslash:
	gemdos	Fgetdta
	move.l	d0,old_dta_p(a6)
	gemdos	Fsetdta,loc_dta(a6)
	gemdos	Fsfirst,int_path(a6),dta_reserved+6(a5)
	move.l	d0,d3
	gemdos	Fsetdta|_ind,old_dta_p(a6)
	tst.l	d3
	bmi.s	.sim_TST
	move.b	dta_fattr+loc_dta(a6),dta_fattr(a5)
	move.l	dta_ftime+loc_dta(a6),dta_ftime(a5)
	move.b	dta_fsize+loc_dta(a6),dta_fsize(a5)
	bra.s	.ref_name
;
.sim_TST:
	tst.b	d4
	bne.s	.sim_DIR
	clr	dta_fattr(a5)
	bra.s	.sim_common
;
.sim_DIR:
	move.b	#$10,dta_fattr(a5)		;FA_SUBDIR
.sim_common:
	move.l	norm_time(pc),dta_ftime(a5)	;ftime & fdate
	clr.l	dta_fsize(a5)
.ref_name:
	move.l	sln_name(a4),a1
	move.l	0(a1),dta_fname+0(a5)
	move.l	4(a1),dta_fname+4(a5)
	move.l	8(a1),dta_fname+8(a5)
	move.b	12(a1),dta_fname+12(a5)
	clr.b	dta_fname+13(a5)
	btst	#4,dta_fattr(a5)	;FA_SUBDIR in result ?
	beq.s	.exit_OK
	btst	#4,dta_reserved+6+1(a5)	;FA_SUBDIR in argument ?
	beq	.un_physical_loop	;loop back if DIR unacceptable
.exit_OK:
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Fsnext
;----------------------------------------------------------------------------
;Function:	ll_Frename
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Frename:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	Fren_dummy	;int	Fren_dummy
	lv_arg.l	Fren_oldpath	;char	*Fren_oldpath
	lv_arg.l	Fren_newpath	;char	*Fren_newpath
;
	lv_var.b	int_path,128
	lv_var.b	int_newpath,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
	tst	d0
	bmi	error_PTHNF
;
	move	LDB_tune_ix+2(a3),-(sp)
	move	d0,-(sp)
	pea	int_newpath(a6)
	pea	(a5)
	bsr	tune_path
	addq	#8,sp
	movem	(sp)+,d1/d2
	cmp	#6,d0
	bne.s	.not_physical
	cmp	d0,d1
	bne.s	.not_physical
	gemdos	Frename,#0,int_path(a6),int_newpath(a6)
	bra	.exit
;
.not_physical:
	cmp	#-2,d0
	bne	error_ACCDN
	cmp	#3,d1
	bne	error_ACCDN
	subq	#1,d2
	move	d2,d0
;
	cmp	LDB_sln_ix(a3),d0
	bhs	error_ACCDN
	cmp	LDB_drv_ix(a3),d0
	bhs.s	.not_drive_sym
	lea	LDB_drv_pool(a3),a2
	bra.s	.index_fname
;
.not_drive_sym:
	sub	LDB_drv_ix(a3),d0
	lea	LDB_usr_pool(a3),a2
.index_fname:
	mulu	#sizeof_sln,d0
	lea	sln_name(a2,d0.w),a4	;a4 -> sln_name of found sln
	move.l	(a4),a1			;a1 = old_name_p
	cmp	LDB_drv_ix(a3),d2
	bhs.s	.release_user_name
.redefine_drive_entry:	
	clr	d3
	move.l	sln_path(a2,d0.w),a0	;a0 -> sln_path buffer
	move.b	(a0),d3			;d3.w = drive letter
	move	LDB_usr_ix(a3),d0	;d0 = unused user link index
	cmp	#sln_LIMIT,d0		;too high ?
	bhs	error_NOSYM
	R_alloc	#4			;d0/a0 -> new_buffer/error_code
	ble	error_NOSYM
	move.l	a0,d4			;d4 -> new path buffer
	move.b	d3,(a0)+		;\
	move.b	#':',(a0)+		; \ store path in buffer
	move.b	#'\',(a0)+		; /
	clr.b	(a0)			;/
	move	LDB_usr_ix(a3),d0	;d0 = free user link index
	mulu	#sizeof_sln,d0		;scale to free sln index
	lea	LDB_usr_pool(a3),a2
	lea	(a2,d0),a2			;a2 -> free sln
	move.l	d4,sln_path(a2)			;link to path buffer
	lea	LDB_usr_chain(a3),a0
	tst.l	(a0)				;any user links before ?
	beq.s	.link_it			;if not, link to chain
	lea	sln_next-sizeof_sln(a2),a0	;else link to previous
.link_it:
	move.l	a2,(a0)			;link new entry last in chain
	addq	#1,LDB_usr_ix(a3)	;increase user link index
	lea	sln_name(a2),a4		;a4 -> sln_name ptr
;
	move	d3,d1			;d1 = drive letter
	sub	#'A',d1
	moveq	#1,d0
	asl.l	d1,d0
	or.l	d0,LDB_blk_drives(a3)	;block this drive for auto links
	bra.s	.name_released
;
.release_user_name:
	R_free	(a1)			;Release old block
.name_released:
	lea	(a5),a0			;a0 -> newpath
.strlen_lp:
	tst.b	(a0)+
	bne	.strlen_lp
	sub.l	a5,a0			;a0 = strlen+1
	move.l	a0,d3
	R_alloc	d3
	bgt.s	.have_mem
	RAM_add	#RAM_chunk
	R_alloc	d3
	ble	error_NSMEM
.have_mem:
	lea	3(a5),a1		;a1 -> newpath+3
	move.l	a0,(a4)			;store new sln_name ptr
.strcpy_lp:			;copy newpath to new buffer with forced case
	move.b	(a1)+,d0
	cmp.b	#'a',d0
	blo.s	.keep_path_case
	cmp.b	#'z',d0
	bhi.s	.keep_path_case
	sub.b	#'a'-'A',d0
.keep_path_case:
	move.b	d0,(a0)+
	bne	.strcpy_lp
	bsr	rebuild_drive_chain
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Frename
;----------------------------------------------------------------------------
;Function:	ll_Fdatime
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fdatime:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	time_p	;DOSTIME	*time_p
	lv_arg.w	handle	;int		handle
	lv_arg.w	wflag	;int		wflag
;
	gemdos	Fdatime|_ind,time_p(a6),FCB_file_handle(a5),wflag(a6)
;
	lv_exit	a6
	rts
;
;End of:	ll_Fdatime
;----------------------------------------------------------------------------
;Function:	ll_Fcntl
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path	(valid for BetaDOS)
;		a5:	FCB	*fcb
ll_Fcntl:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	Fcntl_handle	;int	Fcntl_handle
	lv_arg.l	Fcntl_arg_p	;void	*Fcntl_arg_p
	lv_arg.w	Fcntl_cmd	;int	Fcntl_cmd
;
	gemdos	Fcntl|_ind,FCB_file_handle(a5),Fcntl_arg_p(a6),Fcntl_cmd(a6)
	cmp.l	#E_INVFN,d0
	bne.s	ll_Fcntl_exit
	move	Fcntl_cmd(a6),d0
	cmp	#FIONREAD,d0
	beq.s	.got_FION_RW
	cmp	#FIONWRITE,d0
	bne.s	.not_FION_RW
.got_FION_RW:
	move.l	Fcntl_arg_p(a6),a0
	move.l	#16384,(a0)
	moveq	#E_OK,d0
	bra.s	ll_Fcntl_exit
;
.not_FION_RW:
;
;---;Add more Fcntl simulation code here
;
	moveq	#E_INVFN,d0
ll_Fcntl_exit:
	lv_exit	a6
	rts
;
;End of:	ll_Fcntl
;----------------------------------------------------------------------------
;Function:	ll_Dpathconf
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dpathconf:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;void	*pathname
	lv_arg.w	cmd		;int	cmd
;
	lv_var.b	int_path,128
;
	bsr	rebuild_drive_chain
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	cmp	#3,d0
	blt.s	.not_physical
	gemdos	Dpathconf,int_path(a6),cmd(a6)
	bra.s	.exit
;
.not_physical:
	tst	d0
	blt	error_PTHNF
	move	cmd(a6),d1
	cmp	#-1,d1
	blt	error_INVFN
	bgt.s	.pos_cmd
	moveq	#dpc_LIMIT,d0
	bra.s	.exit
;
.pos_cmd:
	cmp	#dpc_LIMIT,d1
	bhi	error_INVFN
	lsl	#2,d1
	move.l	.dpc_t(pc,d1.w),d0
	bra.s	.exit
;
.dpc_t:
	dc.l	opn_LIMIT
	dc.l	lnk_LIMIT
	dc.l	pth_LIMIT
	dc.l	fnm_LIMIT
	dc.l	wrt_LIMIT
	dc.l	abb_CODE
	dc.l	ccm_CODE
	dc.l	fsm_CODE
	dc.l	xat_CODE
.dpc_t_end:
;
	IFNE	((.dpc_t_end-.dpc_t)/4-(dpc_LIMIT+1))
	FAIL	"Dpathconf table error"
	ENDC
;
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Dpathconf
;----------------------------------------------------------------------------
;Function:	ll_Dopendir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Dopendir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	pathname	;void	*pathname
	lv_arg.w	mode		;int	mode
;
	lv_var.b	int_path,128
	lv_var.l	old_dta_p
;
	bsr	rebuild_drive_chain
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	move	d0,FCB_tune(a5)
	bmi	error_PTHNF
	move.l	#-1,FCB_handle(a5)
	cmp	#3,d0
	blt.s	.not_physical
	gemdos	Dopendir,int_path(a6),mode(a6)
	move.l	d0,FCB_handle(a5)
	cmp.l	#$FF000000,d0
	blo	return_OK
	bra.s	.exit
;
.not_physical:
	move	LDB_DOS_drive(a3),FCB_device(a5)
	move	mode(a6),FCB_dirmode(a5)	
	move.l	#$10000,FCB_dir_ix(a5)
	clr.l	FCB_dta_p(a5)
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Dopendir
;----------------------------------------------------------------------------
;Function:	ll_Dxreaddir
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Dxreaddir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	len	;int	len
	lv_arg.l	handle	;long	handle
	lv_arg.l	buf	;long	*buf
	lv_arg.l	xap	;XATTR	*xap
	lv_arg.l	xret	;long	*xret
;
	addq	#1,FCB_dir_ix+2(a5)
	cmp.b	#-1,FCB_handle(a5)
	beq.s	.not_physical
	gemdos	Dxreaddir|_ind,len(a6),FCB_handle(a5),buf(a6),xap(a6),xret(a6)
	bra	.exit
;
.not_physical:
	clr	d3
	move	#S_IFLNK|$1FF,d2
	move.l	xap(a6),a2			;a2 -> XATTR buf
	lea	(a2),a0				;a0 -> XATTR buf
	moveq	#sizeof_XATTR/2-1,d0		;d0 XATTR wordcount - 1
.clear_lp:					;loop to preclear XATTR buf
	clr	(a0)+				;clear one word
	dbra	d0,.clear_lp			;loop back to clear all
	move	d2,XATTR_mode(a2)		;xap->mode = d2
	move	d3,XATTR_attr(a2)		;xap->attr = d3
	move.l	norm_time(pc),d0
	move.l	d0,XATTR_mtime(a2)		;xap->mtime = norm_time, xap->mdate = norm_date
	move.l	d0,XATTR_ctime(a2)		;xap->ctime = norm_time, xap->cdate = norm_date
	move.l	d0,XATTR_atime(a2)		;xap->atime = norm_time, xap->adate = norm_date
	move	FCB_device(a5),XATTR_dev(a2)	;xap->dev = fcb_p->device
	move.l	#1024,XATTR_size(a2)
	move.l	#1024,XATTR_blksize(a2)
	move.l	#1,XATTR_nblocks(a2)
.fix_common:
	move.l	FCB_dir_ix(a5),d0
	move.l	d0,XATTR_index(a2)		;xap->index = fcb_p->dir_ix
	subq	#1,d0
	cmp	LDB_sln_ix(a3),d0
	bhs	error_NMFIL
	cmp	LDB_drv_ix(a3),d0
	bhs.s	.not_drive_sym
	lea	LDB_drv_pool(a3),a1
	bra.s	.index_fname
;
.not_drive_sym:
	sub	LDB_drv_ix(a3),d0
	lea	LDB_usr_pool(a3),a1
.index_fname:
	mulu	#sizeof_sln,d0
	lea	(a1,d0.w),a4		;a4 -> found sln
	move.l	sln_path(a4),a0
	lea	(a0),a1
.calc_size_lp:
	tst.b	(a0)+
	bne	.calc_size_lp
	sub.l	a1,a0
	move.l	a0,d5
	addq	#2,d5
	btst	#0,d5
	beq.s	.done_calc_size
	addq	#1,d5
.done_calc_size:
	move.l	d5,XATTR_size(a2)
	move.l	sln_name(a4),a0
.fix_name_a0:
	move	len(a6),d0
	cmp	#5,d0
	blo	error_RANGE
	move.l	buf(a6),a2
	tst	FCB_dirmode(a5)
	bne.s	.done_index
	move.l	FCB_dir_ix(a5),(a2)+
	subq	#4,d0
.done_index:
	lea	(a2),a1
	subq	#1,d0
.copy_lp:
	move.b	(a0)+,(a1)+
	dbeq	d0,.copy_lp
	tst	d0
	bmi	error_RANGE
	tst	FCB_dirmode(a5)
	beq.s	.keepcase
	lea	(a2),a0
.ucase_lp:
	move.b	(a0),d0
	cmp.b	#'a',d0
	blo.s	.nextcase
	cmp.b	#'z',d0
	bhi.s	.nextcase
	sub.b	#('a'-'A'),d0
.nextcase:
	move.b	d0,(a0)+
	bne	.ucase_lp
.keepcase:
	move.l	xret(a6),a0
	moveq	#E_OK,d0
	move.l	d0,(a0)
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Dxreaddir
;----------------------------------------------------------------------------
;Function:	ll_Dreaddir
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Dreaddir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	len	;int	len
	lv_arg.l	handle	;long	handle
	lv_arg.l	buf	;long	*buf
;
	lv_var.l	old_dta_p
;
	addq	#1,FCB_dir_ix+2(a5)
	cmp.b	#-1,FCB_handle(a5)
	beq.s	.not_physical
	gemdos	Dreaddir|_ind,len(a6),FCB_handle(a5),buf(a6)
	bra.s	.exit
;
.not_physical:
	move.l	FCB_dir_ix(a5),d0
	subq	#1,d0
	cmp	LDB_sln_ix(a3),d0
	bhs	error_NMFIL
	cmp	LDB_drv_ix(a3),d0
	bhs.s	.not_drive_sym
	lea	LDB_drv_pool(a3),a2
	bra.s	.index_fname
;
.not_drive_sym:
	sub	LDB_drv_ix(a3),d0
	lea	LDB_usr_pool(a3),a2
.index_fname:
	mulu	#sizeof_sln,d0
	move.l	sln_name(a2,d0.w),a0

.fix_name_a0:
	move	len(a6),d0
	cmp	#5,d0
	blo	error_RANGE
	move.l	buf(a6),a2
	tst	FCB_dirmode(a5)
	bne.s	.done_index
	move.l	FCB_dir_ix(a5),(a2)+
	subq	#4,d0
.done_index:
	lea	(a2),a1
	subq	#1,d0
.copy_lp:
	move.b	(a0)+,(a1)+
	dbeq	d0,.copy_lp
	tst	d0
	bmi	error_RANGE
	tst	FCB_dirmode(a5)
	beq.s	.keepcase
	lea	(a2),a0
.ucase_lp:
	move.b	(a0),d0
	cmp.b	#'a',d0
	blo.s	.nextcase
	cmp.b	#'z',d0
	bhi.s	.nextcase
	sub	#('a'-'A'),d0
.nextcase:
	move.b	d0,(a0)+
	bne	.ucase_lp
.keepcase:
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Dreaddir
;----------------------------------------------------------------------------
;Function:	ll_Drewinddir
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Drewinddir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	handle	;long	handle
;
	cmp.b	#-1,FCB_handle(a5)
	beq.s	.not_physical
	gemdos	Drewinddir|_ind,FCB_handle(a5)
	bra.s	.exit
;
.not_physical:
	move.l	#$10000,FCB_dir_ix(a5)
	clr.l	FCB_dta_p(a5)
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Drewinddir
;----------------------------------------------------------------------------
;Function:	ll_Dclosedir
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Dclosedir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	handle	;long	handle
;
	cmp.b	#-1,FCB_handle(a5)
	beq.s	.not_physical
	gemdos	Dclosedir,FCB_handle(a5)
	bra.s	.exit
;
.not_physical:
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Dclosedir
;----------------------------------------------------------------------------
;Function:	ll_Fxattr
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Fxattr:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	mode		;int	mode
	lv_arg.l	pathname	;char	*pathname
	lv_arg.l	xap		;XATTR	*xap
;
	lv_var.b	int_path,128
	lv_var.b	loc_dta,sizeof_dta_struct
	lv_var.l	old_dta_p
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	move.l	xap(a6),a5
	cmp	#4,d0
	blt.s	.not_physical
	gemdos	Fxattr,mode(a6),int_path(a6),(a5)
	bra	.exit
;
.not_physical:
	tst	d0
	blt	error_PTHNF
	cmp	#3,d0
	blt	.sim_DIR
	tst	mode(a6)
	bne	.sim_LNK
	lea	int_path(a6),a0
.pass_lp:
	tst.b	(a0)+
	bne.s	.pass_lp
	move.l	a0,d0
	lea	int_path(a6),a1
	sub.l	a1,d0
	cmp.l	#4,d0
	bgt.s	.ref_long
	blt	error_PTHNF
	cmp.b	#'\',-2(a0)
	bne	error_PTHNF
	cmp.b	#':',-3(a0)
	bne	error_PTHNF
	bra	.sim_DIR
;
.ref_long:
	sf	d4
	cmp.b	#'\',-2(a0)
	bne.s	.done_unslash
	clr.b	-2(a0)
	st	d4
.done_unslash:
	gemdos	Fxattr,mode(a6),int_path(a6),(a5)
	tst.l	d0
	bpl	.exit
	gemdos	Fgetdta
	move.l	d0,old_dta_p(a6)
	gemdos	Fsetdta,loc_dta(a6)
	gemdos	Fsfirst,int_path(a6),#$3F
	move.l	d0,d3
	gemdos	Fsetdta|_ind,old_dta_p(a6)
	tst.l	d3
	bmi.s	.sim_TST
	clr	d3
	move.b	dta_fattr+loc_dta(a6),d3
	move	#S_IFDIR|$1FF,d2
	btst	#4,d3
	bne.s	.keep_mode
	move	#S_IFREG|$1FF,d2
.keep_mode:
	move.l	dta_ftime+loc_dta(a6),d4
	move.l	dta_fsize+loc_dta(a6),d5
	lea	int_path(a6),a4
	bra.s	.ref_common
;
.sim_TST:
	tst.b	d4
	bne.s	.sim_DIR
	clr	d3
	move	#S_IFREG|$1FF,d2
	clr.l	d5
	bra.s	.sim_common
;
.sim_DIR:
	move	#FA_DIR,d3
	move	#S_IFDIR|$1FF,d2
	clr.l	d5
	bra.s	.sim_common
;
.sim_LNK:
	clr	d3
	move	#S_IFLNK|$1FF,d2
	lea	int_path(a6),a0
	lea	(a0),a1
.calc_size_lp:
	tst.b	(a0)+
	bne	.calc_size_lp
	sub.l	a1,a0
	move.l	a0,d5
	addq	#2,d5
	btst	#0,d5
	beq.s	.done_calc_size
	addq	#1,d5
.done_calc_size:
.sim_common:
	move.l	norm_time(pc),d4
.ref_common:
	move.l	xap(a6),a2
	lea	(a2),a0
	moveq	#sizeof_XATTR/2-1,d0
.clear_lp:
	clr	(a0)+			;clear each word of XATTR struct
	dbra	d0,.clear_lp
	move	d2,XATTR_mode(a2)
	move	d3,XATTR_attr(a2)
	move.l	d4,XATTR_mtime(a2)
	move.l	d4,XATTR_atime(a2)
	move.l	d4,XATTR_ctime(a2)
	move.l	d5,XATTR_size(a2)
	clr	d0
	move.b	(a4),d0
	cmp	#'a',d0
	blo.s	.keepcase
	cmp	#'z',d0
	bhi.s	.keepcase
	sub	#('a'-'A'),d0
.keepcase:
	sub	#'A',d0
	move	d0,XATTR_dev(a2)
	move.l	LDB_tune_ix(a3),XATTR_index(a2)
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Fxattr
;----------------------------------------------------------------------------
;Function:	ll_Flink
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path	(of 'newpath')
ll_Flink:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	oldpath	;char	*oldpath
	lv_arg.l	newpath	;char	*newpath
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	move.l	oldpath(a6),a5
	cmp	#6,d0
	bne.s	.not_physical
	gemdos	Flink,(a5),int_path(a6)
	bra.s	.exit
;
.not_physical:
	moveq	#E_INVFN,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Flink
;----------------------------------------------------------------------------
;Function:	ll_Fsymlink
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path	(of 'newpath')
ll_Fsymlink:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	oldpath	;char	*oldpath
	lv_arg.l	newpath	;char	*newpath
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	move.l	oldpath(a6),a5
	cmp	#6,d0
	bne.s	.not_physical_new
	gemdos	Fsymlink,(a5),int_path(a6)
	bra	.exit
;
.not_physical_new:
	cmp	#-1,d0
	bgt	error_ACCDN
	beq	error_PTHNF
	move	LDB_usr_ix(a3),d0
	cmp	#sln_LIMIT,d0
	bhs	error_NOSYM
	mulu	#sizeof_sln,d0
	lea	LDB_usr_pool(a3),a5
	lea	(a5,d0),a5		;a5 -> free sln
;
	moveq	#33-1,d0
	lea	int_path(a6),a1
	lea	3(a4),a0	;a0->drivename in path
.copy_lp_1:
	move.b	(a0)+,(a1)+
	dbeq	d0,.copy_lp_1
	clr.b	(a1)
	lea	int_path(a6),a0
.seek_lp_1:
	move.b	(a0)+,d0
	beq.s	.exit_seek_1
	cmp.b	#'z',d0
	bhi	.seek_lp_1
	cmp.b	#'a',d0
	blo.s	.seek_slash_1
	sub.b	#'a'-'A',d0
	move.b	d0,-1(a0)
	bra	.seek_lp_1
;
.seek_slash_1:
	cmp.b	#'\',d0
	bne.s	.seek_lp_1
	clr.b	-1(a0)
.exit_seek_1:
	lea	int_path(a6),a1
	sub.l	a1,a0
	R_alloc	a0
	bgt.s	.have_mem_1
	move.l	a0,d3
	RAM_add	#RAM_chunk
	ble	error_NSMEM
	R_alloc	d3
	ble	error_NSMEM
.have_mem_1:
	move.l	a0,sln_name(a5)
	lea	int_path(a6),a1
.copy_lp_2:
	move.b	(a1)+,(a0)+
	bne	.copy_lp_2
;
	pea	int_path(a6)
	move.l	oldpath(a6),-(sp)
	bsr	tune_path
	addq	#8,sp
;
	move.l	oldpath(a6),a4		;a4 -> oldpath
	cmp	#6,d0
	bne.s	.keep_oldpath
	lea	int_path(a6),a4		;a4 -> oldpath expanded link
.keep_oldpath:
;
	move.l	a4,a0			;a0 -> fixed old path
.strlen_lp_2:
	tst.b	(a0)+
	bne.s	.strlen_lp_2
	sub.l	a4,a0
	R_alloc	a0
	bgt.s	.have_mem_2
	move.l	a0,d3
	RAM_add	#RAM_chunk
	ble.s	.ouch_NSMEM
	R_alloc	d3
	bgt.s	.have_mem_2
.ouch_NSMEM:
	R_free.i	sln_name(a5)
	bra		error_NSMEM
;
.have_mem_2:
	move.l	d0,a0
	move.l	a0,sln_path(a5)
	move.l	a4,a1
.copy_lp_3:
	move.b	(a1)+,(a0)+
	bne	.copy_lp_3
;
	move	LDB_usr_ix(a3),d0
	beq.s	.first_link
.more_link:
	move.l	a5,-sizeof_sln+sln_next(a5)
	bra.s	.done_linkup
;
.first_link:
	move.l	a5,LDB_usr_chain(a3)
.done_linkup:
	clr.l	sln_next(a5)
	addq	#1,LDB_usr_ix(a3)
	bsr	rebuild_drive_chain
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Fsymlink
;----------------------------------------------------------------------------
;Function:	ll_Freadlink
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path	(of 'newpath')
ll_Freadlink:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	bufsz		;int	bufsz
	lv_arg.l	buf		;char	*buf
	lv_arg.l	pathname	;char	*pathname
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	move.l	buf(a6),a5
	cmp	#6,d0
	bne.s	.not_physical
	gemdos	Freadlink,bufsz(a6),(a5),int_path(a6)
	bra.s	.exit
;
.not_physical:
	cmp	#3,d0
	beq.s	.legal_link
	cmp	#-1,d0
	blt	error_FILNF
	beq	error_PTHNF
	bra	error_ACCDN
;
.legal_link:
	lea	int_path(a6),a0
	lea	(a0),a1
.strlen_lp:
	tst.b	(a1)+
	bne.s	.strlen_lp
	sub.l	a0,a1
	move.l	a1,d0
	cmp	bufsz(a6),d0
	bhi	error_RANGE
	move.l	buf(a6),a1
.strcpy_lp:
	move.b	(a0)+,(a1)+
	bne.s	.strcpy_lp
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Freadlink
;----------------------------------------------------------------------------
;Function:	ll_Dcntl
;Entry state:	a3:	LDB	*ldb
;		a4:	char	*expanded_path
;
ll_Dcntl:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	Dc_cmd	;int	Dc_cmd
	lv_arg.l	Dc_path	;char	*Dc_path
	lv_arg.l	Dc_arg	;long	Dc_arg
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	cmp	#3,d0
	blt.s	.not_physical
	gemdos	Dcntl,Dc_cmd(a6),int_path(a6),Dc_arg(a6)
	bra.s	.exit
;
.not_physical:
	moveq	#E_INVFN,d0
.exit:
	lv_exit	a6
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
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	move.l	name(a6),a5
	cmp	#3,d0
	blt.s	.not_physical
	gemdos	Dreadlabel,int_path(a6),(a5),size(a6)
	bra.s	.exit
;
.not_physical:
	lea	LDB_name(a3),a0
	move.l	a0,a1
.strlen_lp:
	tst.b	(a1)+
	bne	.strlen_lp
	sub.l	a0,a1
	cmp	size(a6),a1
	bhi	error_RANGE
	move.l	name(a6),a1
.strcpy_lp:
	move.b	(A0)+,(a1)+
	bne	.strcpy_lp
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Dreadlabel
;----------------------------------------------------------------------------
;Function:	ll_Dwritelabel
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dwritelabel:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	path	;char	*path
	lv_arg.l	name	;char	*name
;
	lv_var.b	int_path,128
;
	pea	int_path(a6)
	pea	(a4)
	bsr	tune_path
	addq	#8,sp
;
	move.l	name(a6),a5
	cmp	#3,d0
	blt.s	.not_physical
	gemdos	Dwritelabel,int_path(a6),(a5)
	bra.s	.exit
;
.not_physical:
	move.l	a5,a1
.strlen_lp:
	tst.b	(a1)+
	bne	.strlen_lp
	sub.l	a5,a1
	cmp	#fnm_LIMIT+1,a0
	bhi	error_RANGE
	move.l	a5,a0
	lea	LDB_name(a3),a1
.strcpy_lp:
	move.b	(A0)+,(a1)+
	bne	.strcpy_lp
	moveq	#E_OK,d0
.exit:
	lv_exit	a6
	rts
;
;End of:	ll_Dwritelabel
;----------------------------------------------------------------------------
;End of:	ll_functions	low level functions wrapping high level ones
;----------------------------------------------------------------------------
;Start of:	Function table init routine
;----------------------------------------------------------------------------
Init_FunctionTable:
	lea	InitTable(pc),a0
	lea	FunctionTable(pc),a1
	move.l	a1,a2
	move	#(MAX_Func+5)-1,d0
	move.l	#E_INVFN,d1
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
	bne.s	.loop_2			;loop back unless empty block (end mark)
	rts
;----------------------------------------------------------------------------
;End of:	Function table init routine
;----------------------------------------------------------------------------
;Start of:	General Subroutines
;----------------------------------------------------------------------------
;static int ll_Bconws (char *str)
;
ll_Bconws:
	movem.l	a2-a3,-(sp)
	move.l	a0,a3
	move.l	a0,d0
	beq.s	.exit
	bra.s	.loop_entry
;
.loop:
	bios	Bconout,#2,#CR
.loop_entry:
	move.b	(a3)+,d0
	bne.s	.loop
	subq	#1,a3
.exit:
	move.l	a3,d0
	sub.l	a0,d0
	movem.l	(sp)+,a2-a3
	rts
;----------------------------------------------------------------------------
mulu_long:
	movem.l	d2-d3,-(sp)
	move.l	d1,d3
	move.l	d0,d2
	swap	d2
	swap	d3
	mulu	d1,d2
	mulu	d0,d3
	add.l	d2,d3
	swap	d3
	clr	d3
	mulu	d1,d0
	add.l	d3,d0
	movem.l	(sp)+,d2-d3
	rts
;----------------------------------------------------------------------------
divu_long:
	movem.l	d2-d3,-(sp)
	move.l	d1,d3
	clr	d3
	swap	d3
	divu	d0,d3
	swap	d3
	move	d3,d2
	clr	d3
	swap	d2
	move	d1,d2
	divu	d0,d2
	clr.l	d1
	move	d2,d1
	add.l	d3,d1
	movem.l	(sp)+,d2-d3
	rts
;----------------------------------------------------------------------------
;Function:	rebuild_drive_chain
;Entry state:	a3:	LDB	*ldb
;
rebuild_drive_chain:
	lv_init	a6
	lv_var.l	wanted_bits
	lv_var.w	drive_id
	lv_var.l	last_drv_sln_p
;
	move.l	LDB_blk_drives(a3),d0
	not.l	d0
	and.l	(_drvbits).w,d0
	move.l	d0,wanted_bits(a6)
	clr.l	last_drv_sln_p(a6)
	clr	drive_id(a6)
	clr	LDB_drv_ix(a3)
	tst.l	wanted_bits(a6)
	beq.s	.exit_loop_1
.loop_1:
	btst	#0,wanted_bits+3(a6)
	beq.s	.next_loop_1
	move	LDB_drv_ix(a3),d0
	addq	#1,LDB_drv_ix(a3)
	move	d0,d1
	mulu	#sizeof_sln,d1
	lea	LDB_drv_pool(a3),a1
	lea	(a1,d1.w),a1
	clr.l	sln_next(a1)
	add	d0,d0
	lea	LDB_drv_names(a3,d0.w),a0
	move.l	a0,sln_name(a1)
	moveq	#'A',d1
	add	drive_id(a6),d1
	move.b	d1,(a0)+
	clr.b	(a0)
	add	d0,d0
	lea	LDB_drv_paths(a3,d0.w),a0
	move.l	a0,sln_path(a1)
	move.b	d1,(a0)+
	move.b	#':',(a0)+
	move.b	#'\',(a0)+
	clr.b	(a0)
	move.l	last_drv_sln_p(a6),d0
	beq.s	.set_last
	move.l	d0,a0
	move.l	a1,(a0)
.set_last:
	move.l	a1,last_drv_sln_p(a6)
.next_loop_1:
	addq	#1,drive_id(a6)
	move.l	wanted_bits(a6),d0
	lsr.l	#1,d0
	move.l	d0,wanted_bits(a6)
	bne	.loop_1
.exit_loop_1:
	move.l	last_drv_sln_p(a6),d0
	beq.s	.no_drives
	move.l	d0,a0
	move.l	LDB_usr_chain(a3),sln_next(a0)
	lea	LDB_drv_pool(a3),a0
	move.l	a0,LDB_sln_chain(a3)
	bra.s	.set_sln_ix
;
.no_drives:
	move.l	LDB_usr_chain(a3),LDB_sln_chain(a3)
.set_sln_ix:
	move	LDB_drv_ix(a3),d0
	add	LDB_usr_ix(a3),d0
	move	d0,LDB_sln_ix(a3)
;
	lv_exit	a6
	rts
;
;End of:	rebuild_drive_chain
;----------------------------------------------------------------------------
;Function:	tune_path(ext_path, int_path)
;Entry state:	a3:	LDB	*ldb
;
tune_path:
	lv_init	a6
	lv_arg.l	ext_path
	lv_arg.l	int_path
;
	lv_var.w	flag
	lv_var.w	cnt
	lv_var.b	temp_s,34
	lv_var.l	pos_p
	lv_var.l	res_path
	lv_var.l	work_sym
;
	movem.l	d3/a2-a3,-(sp)
;
	move.l	#1,LDB_tune_ix(a3)
	move.l	int_path(a6),a0		;a0 -> int_path
	clr.b	(a0)			;*int_path = 0
	moveq	#-1,d0
	move.l	ext_path(a6),d1		;ext_path == NULL ?
	ble	.exit
	move.l	d1,a0			;a0 -> ext_path
	tst.b	(a0)			;ext_path -> NUL ?
	beq	.exit
	cmp.b	#':',1(a0)		;ext_path[1] == ':' ?
	bne	.exit
	clr.l	d0
	cmp.b	#'\',2(a0)		;ext_path[2] == '\' ?
	bne	.exit
	addq.l	#3,ext_path(a6)		;we're done with 1st 3 chars
.weird_lp:
	move.l	ext_path(a6),a0
	moveq	#1,d0
	move.b	(a0),d1			;d1 = next char == NUL ?
	beq	.exit
	cmp.b	#'.',d1			;d1 == '.' ?
	bne.s	.try_rootroot
	moveq	#-2,d0
	cmp.b	#'\',1(a0)		;next char == '\' ?
	bne	.exit
	addq.l	#2,ext_path(a6)		;we're done with 2 more chars
	bra	.weird_lp
;
.try_rootroot:
	cmp.b	#'\',d1
	bne.s	.try_wildroot
	addq.l	#1,ext_path(a6)		;we're done with this char
	bra	.weird_lp
;
.try_wildroot:
	moveq	#2,d0
	cmp.b	#'*',d1			;1st rel path char == '*' ?
	beq	.exit
	lea	temp_s(a6),a1		;a1 -> temp_s
	moveq	#32-1,d0		;\
.copy_lp_1:				; \ strncpy(temp_s, ext_path, 32)
	move.b	(a0)+,(a1)+		; /
	dbeq	d0,.copy_lp_1		;/
	clr.b	(a1)			;force termination
	lea	temp_s(a6),a0		;a0 -> temp_s
.seek_lp_1:
	move.b	(a0)+,d0
	beq.s	.err_seek_1
	cmp.b	#'z',d0
	bhi	.seek_lp_1
	cmp.b	#'a',d0
	blo.s	.seek_slash_1
	sub.b	#'a'-'A',d0
	move.b	d0,-1(a0)
	bra	.seek_lp_1
;
.seek_slash_1:
	cmp.b	#'\',d0
	bne	.seek_lp_1
	clr.b	-(a0)			;terminate at first '\' in temp_s
	move.l	ext_path(a6),a0
.seek_lp_2:
	move.b	(a0)+,d0
	cmp.b	#'\',d0
	bne	.seek_lp_2
	bra.s	.set_pos_p
;
.err_seek_1:
	suba.l	a0,a0
.set_pos_p:
	move.l	a0,pos_p(a6)		;pos_p -> past '\' in rel path, or is NULL if no '\'
	clr.l	res_path(a6)
	move.l	LDB_sln_chain(a3),a2
	clr	d1
	move.l	a2,d0
	beq.s	.exit_loop_3
.loop_3:
	addq	#1,d1
	move.l	sln_name(a2),a1
	lea	temp_s(a6),a0
.loop_4:
	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bne.s	.next_loop_3
	tst.b	d0
	bne	.loop_4
;matching symbolic link is found
	move	#1,LDB_tune_ix(a3)
	move	d1,LDB_tune_ix+2(a3)
	move.l	sln_path(a2),res_path(a6)
	bra.s	.exit_loop_3
;
.next_loop_3:
	move.l	sln_next(a2),a2
	move.l	a2,d0
	bne	.loop_3
.exit_loop_3:
	moveq	#-2,d0
	move.l	res_path(a6),d1		;matching link found ?
	beq.s	.exit			;if not, exit
	move.l	d1,a1			;\
	move.l	int_path(a6),a0		; \
.loop_5:				;  > strcpy(int_path, res_path)
	move.b	(a1)+,(a0)+		; /
	bne	.loop_5			;/
	moveq	#3,d0
	move.l	pos_p(a6),a1		;a1 -> tail part of ext_path
	move.l	a1,d1
	beq.s	.exit
	subq	#1,a0			;a0 -> terminator of int_path
	cmp.b	#'\',-1(a0)		;was last char a '\'
	beq.s	.loop_6			;if so, don't pad tail with '\'
	move.b	#'\',(a0)+		;pad tail with preceding '\'
.loop_6:
	move.b	(a1)+,(a0)+
	bne	.loop_6
;
	move.l	pos_p(a6),a0
	moveq	#4,d0
	move.b	(a0)+,d1
	beq.s	.exit
	moveq	#5,d0
	cmp.b	#'*',d1
	beq.s	.exit
	moveq	#6,d0
.exit:
	movem.l	(sp)+,d3/a2-a3
	lv_exit	a6
	rts
;
;/*--------------------------*/
;/* -2 <= illegal root ref	*/	/*	X:\garbage	*/
;/* -1 <= illegal root path	*/	/*	garbage		*/
;/*  0 <= pure root drive	*/	/*	X:		*/
;/*  1 <= pure root path	*/	/*	X:\		*/
;/*  2 <= wild root link	*/	/*	X:\*		*/
;/*  3 <= root link		*/	/*	X:\dname	*/
;/*  4 <= pure link path	*/	/*	X:\dname\	*/
;/*  5 <= wild link path	*/	/*	X:\dname\*	*/
;/*  6 <= link long path	*/	/*	X:\dname\...	*/
;
;End of:	tune_path
;----------------------------------------------------------------------------
	make	RAM_links
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
	dc.w	2,(Dcreate&$ff)
	dc.l		ll_Dcreate,ll_Ddelete
	dc.w	8,(Fcreate&$ff)
	dc.l		ll_Fcreate,ll_Fopen,ll_Fclose,ll_Fread
	dc.l		ll_Fwrite,ll_Fdelete,ll_Fseek,ll_Fattrib
	dc.w	1,(Fforce&$ff)
	dc.l		ll_Fforce
	dc.w	2,(Fsfirst&$ff)
	dc.l		ll_Fsfirst,ll_Fsnext
	dc.w	1,(Frename&$ff)
	dc.l		ll_Frename
	dc.w	1,(Fdatime&$ff)
	dc.l		ll_Fdatime
	dc.w	1,(Fcntl&$fff)
	dc.l		ll_Fcntl
	dc.w	1,(Dpathconf&$fff)
	dc.l		ll_Dpathconf
	dc.w	9,(Dopendir&$fff)
	dc.l		ll_Dopendir,ll_Dreaddir,ll_Drewinddir,ll_Dclosedir
	dc.l		ll_Fxattr,ll_Flink,ll_Fsymlink,ll_Freadlink
	dc.l		ll_Dcntl
	dc.w	1,(Dxreaddir&$fff)
	dc.l		ll_Dxreaddir
	dc.w	2,(Dreadlabel&$fff)
	dc.l		ll_Dreadlabel,ll_Dwritelabel
	dc.w	0	
;----------------------------------------------------------------------------
norm_time:
	dc.w	0	;dc.w	$1106
norm_date:
	dc.w	0	;dc.w	$2359
;----------------------------------------------------------------------------
DEV_NAME_s:
	DEV_NAME
	dc.b		' v'
	DEV_VERSION
	dc.b		NUL
	even
;----------------------------------------------------------------------------
init_label_s:
	DEV_LABEL
	dc.b		NUL
	even
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
FunctionTable:	ds.l	MAX_Func+5
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
; End of file:	Cluster.S
;----------------------------------------------------------------------------
