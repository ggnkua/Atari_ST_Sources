;----------------------------------------------------------------------------
; File name:	Skele_FS.S			Revision date:	1998.09.11
; Created by:	Ulf Ronald Andersson		Creation date:	1998.01.25
;----------------------------------------------------------------------------
; Purpose:
;	Skeleton file suitable for assembling MetaDos '.DOS' filesystem
;	drivers.
;
;	Edit filesystem specific details at each point marked ;---; below.
;----------------------------------------------------------------------------
; Credits:
;	Thanks go to Julian F. Reschke for producing earlier 'skeletons'
;	which enabled me to learn the principles involved.  Thanks !
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	output	.DOS
;----------------------------------------------------------------------------
MAX_Func	=	349
;----------------------------------------------------------------------------
;---;Edit FS_mode_bits to suit filesystem needs
;
FS_mode_bits	=	5	;b2=writable  b1=rel_paths  b0=sensecase
;----------------------------------------------------------------------------
;---;Edit the DEV_NAME and DEV_VERSION macros
;
DEV_NAME	MACRO
	dc.b	'Skeleton driver'
	ENDM
DEV_VERSION	MACRO
	dc.b	'1.00'
	ENDM
;----------------------------------------------------------------------------
;---;Edit the LDB structure definition below to suit the filesystem needs
;
	struct	LDB
	uint32	LDB_device_type
	uint16	LDB_DOS_char
	uint16	LDB_BOS_char
	uint16	LDB_DOS_parm
	uint16	LDB_DOS_drive
	uint16	LDB_DOS_bit
	d_end	LDB
;
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
;
;---;Add filesystem specific global init here
;
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
	movem.l	(sp)+,d0/d2/a2
	move.l	#FS_mode_bits,LDB_device_type(a3)
	move	d0,LDB_BOS_char(a3)
	move	d2,LDB_DOS_char(a3)
	move.l	a2,LDB_DOS_parm(a3)
	sub	#'A',d2
	move	d2,LDB_DOS_drive(a3)
	moveq	#1,d0
	lsl.l	d2,d1
	move.l	d1,LDB_DOS_bit
;
;---;Add filesystem specific init here, branching to .failure if abort needed
;
.done:
	addq	#4,sp			;drop device codes from stack
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
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	dfree_buf	;DISKINFO	*dfree_buf
	lv_arg.w	dfree_drive	;int		 dfree_drive
;
;---;Add Dfree code here
;
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
	lv_arg.l	Dcreate_path	;char	*Dcreate_path
;
;---;Add Dcreate code here
;
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
	lv_arg.l	Ddelete_path	;char	*Ddelete_path
;
;---;Add Ddelete code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Ddelete
;----------------------------------------------------------------------------
;Function:	ll_Dsetpath
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
ll_Dsetpath:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	Dsetpath_path	;char	*Dsetpath_path
;
;---;Add Dsetpath code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Dsetpath
;----------------------------------------------------------------------------
;Function:	ll_Fcreate
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fcreate:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	Fcreate_path	;char	*Fcreate_path
	lv_arg.w	Fcreate_mode	;int	Fcreate_mode
;
;---;Add Fcreate code here
;
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
	lv_arg.l	Fopen_path	;char	*Fopen_path
	lv_arg.w	Fopen_mode	;int	Fopen_mode
;
;---;Add Fopen code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Fopen
;----------------------------------------------------------------------------
;Function:	ll_Fclose
;Entry state:	a3:	LDB 	*ldb
;		a5:	FCB	*fcb
ll_Fclose:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	file_handle	;int	file_handle
;
;---;Add Fclose code here
;
	lv_exit	a6
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
	lv_arg.w	file_handle	;int	file_handle
	lv_arg.l	file_count	;long	file_count
	lv_arg.l	file_buffer	;char	*file_buffer
;
;---;Add Fread code here
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
	lv_arg.w	file_handle	;int	file_handle
	lv_arg.l	file_count	;long	file_count
	lv_arg.l	file_buffer	;char	*file_buffer
;
;---;Add Fwrite code here
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
	lv_arg.l	Fdelete_path	;char	*Fdelete_path
;
;---;Add Fdelete code here
;
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
	lv_arg.l	file_offset	;long	file_offset
	lv_arg.w	file_handle	;int	file_handle
	lv_arg.w	file_seekmode	;int	file_seekmode
;
;---;Add Fseek code here
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
	lv_arg.l	Fatt_path	;char	*Fatt_path
	lv_arg.w	Fatt_wflag	;int	Fatt_wflag
	lv_arg.w	Fatt_attr	;int	Fatt_attr
;
;---;Add Fattrib code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Fattrib
;----------------------------------------------------------------------------
;Function:	ll_Fsfirst
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	DTA	*dta
ll_Fsfirst:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	Fsfirst_path	;char	*Fsfirst_path
	lv_arg.w	Fsfirst_mode	;int	Fsfirst_mode
;
;---;Add Fsfirst code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Fsfirst
;----------------------------------------------------------------------------
;Function:	ll_Fsnext
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	DTA	*dta
ll_Fsnext:
	lv_init	a6
	lv_arg.w	DOS_opcode
;
;---;Add Fsnext code here
;
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
;---;Add Frename code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Frename
;----------------------------------------------------------------------------
;Function:	ll_Fdatime
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fdatime:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	Fdat_time_p	;DOSTIME	*Fdat_time_p
	lv_arg.w	Fdat_handle	;int		Fdat_handle
	lv_arg.w	Fdat_wflag	;int		Fdat_wflag
;
;---;Add Fdatime code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Fdatime
;----------------------------------------------------------------------------
;Function:	ll_Fcntl
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Fcntl:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	Fcntl_handle	;int	Fcntl_handle
	lv_arg.l	Fcntl_arg_p	;void	*Fcntl_arg_p
	lv_arg.w	Fcntl_cmd	;int	Fcntl_cmd
;
;---;Add Fcntl code here
;
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
	lv_arg.l	Dpathconf_path	;void	*Dpathconf_path
	lv_arg.w	Dpathconf_cmd	;int	Dpathconf_cmd
;
;---;Add Dpathconf code here
;
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
	lv_arg.l	Dopendir_path	;void	*Dopendir_path
	lv_arg.w	Dopendir_mode	;int	Dopendir_mode
;
;---;Add Dopendir code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Dopendir
;----------------------------------------------------------------------------
;Function:	ll_Dxreaddir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Dxreaddir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	Dxread_len	;int	Dxread_len
	lv_arg.l	Dxread_handle	;long	Dxread_handle
	lv_arg.l	Dxread_buf	;long	*Dxread_buf
	lv_arg.l	Dxread_xap	;XATTR	*Dxread_xap
	lv_arg.l	Dxread_xret	;long	*Dxread_xret
;
;---;Add Dxreaddir code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Dxreaddir
;----------------------------------------------------------------------------
;Function:	ll_Dreaddir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Dreaddir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.w	Dread_len	;int	Dread_len
	lv_arg.l	Dread_handle	;long	Dread_handle
	lv_arg.l	Dread_buf	;long	*Dread_buf
;
;---;Add Dreaddir code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Dreaddir
;----------------------------------------------------------------------------
;Function:	ll_Drewinddir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Drewinddir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	Drew_handle	;long	Drew_handle
;
;---;Add Drewinddir code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Drewinddir
;----------------------------------------------------------------------------
;Function:	ll_Dclosedir
;Entry state:	a3:	LDB 	*ldb
;	 	a4:	char	*expanded_path
;		a5:	FCB	*fcb
ll_Dclosedir:
	lv_init	a6
	lv_arg.w	DOS_opcode
	lv_arg.l	Dclose_handle	;long	Dclose_handle
;
;---;Add Dclosedir code here
;
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
	lv_arg.w	Fxatt_mode	;int	Fxatt_mode
	lv_arg.l	Fxatt_path	;char	*Fxatt_path
	lv_arg.l	Fxatt_xap	;XATTR	*Fxatt_xap
;
;---;Add Fxattr code here
;
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
	lv_arg.l	Flink_oldpath	;char	*Flink_oldpath
	lv_arg.l	Flink_newpath	;char	*Flink_newpath
;
;---;Add Flink code here
;
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
	lv_arg.l	Flink_oldpath	;char	*Flink_oldpath
	lv_arg.l	Flink_newpath	;char	*Flink_newpath
;
;---;Add Fsymlink code here
;
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
	lv_arg.w	Frdlk_size	;int	Frdlk_size
	lv_arg.l	Frdlk_buff	;char	*Frdlk_buff
	lv_arg.l	Frdlk_path	;char	*Frdlk_path
;
;---;Add Freadlink code here
;
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
	lv_arg.w	Dcntl_cmd	;int	Dcntl_cmd
	lv_arg.l	Dcntl_path	;char	*Dcntl_path
	lv_arg.l	Dcntl_arg	;long	Dcntl_arg
;
;---;Add Dreadlabel code here
;
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
	lv_arg.l	Dlab_path	;char	*Dlab_path
	lv_arg.l	Dlab_name	;char	*Dlab_name
	lv_arg.w	Dlab_size	;int	Dlab_size
;
;---;Add Dreadlabel code here
;
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
	lv_arg.l	Dlab_path	;char	*Dlab_path
	lv_arg.l	Dlab_name	;char	*Dlab_name
;
;---;Add Dwritelabel code here
;
	lv_exit	a6
	rts
;
;End of:	ll_Dwritelabel
;----------------------------------------------------------------------------
;End of:	ll_functions	low level functions wrapping high level ones
;----------------------------------------------------------------------------
;Start of:	General Subroutines
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
	bne.s	.loop_2			;loop back unless empty block (end mark)
	rts
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
DEV_NAME_s:
	DEV_NAME
	dc.b		' v'
	DEV_VERSION
	dc.b		NUL
	even
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
FunctionTable:	ds.l	MAX_Func+5
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
; End of file:	Skele_FS.S
;----------------------------------------------------------------------------
