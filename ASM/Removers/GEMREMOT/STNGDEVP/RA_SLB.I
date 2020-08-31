;----------------------------------------------------------------------------
;File name:	RA_SLB.I			Revision date:	2000.06.14
;Authors:	Ulf Ronald Andersson		Creation date:	1998.09.14
;(c)1997 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sale forbidden)
;----------------------------------------------------------------------------
; Purpose:	Defines Shared LiBrary support macros and constants
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_SLB_defined
RA_SLB_defined	set	1
;----------------------------------------------------------------------------
	include	RA_STRUC.I
	include	RA_TOS.I
;----------------------------------------------------------------------------
;Library macros used to define an SLB library:
;
;SLB_hd_def	sl_name,version,funcs	;defines SLB header (use at TEXT start)
;SLB_fn_def	fn_name,fn_index	;defines SLB function (use at func start)
;SLB_patch	sl_name			;patch missing ptrs to NULL (use at TEXT end)
;----------------------------------------------------------------------------
;Library macros for use in SLB library clients (or header files)
;
;SLB_lib	sl_name				;defines SLB library  (for headers)
;SLB_fun	fn_name,arg_ct,arg_flags	;defines SLB function (for headers)
;
;SLB_beg	sl_name,path,minver		;opens SLB
;SLB_exe	fn_name,sl,fnix,parmlen,...	;Calls function in SLB
;SLB_end	sl_name				;closes SLB
;----------------------------------------------------------------------------
;We use the 128 bytes of command line space to store the SLB path
;this is followed by a magic constant at the start of the TEXT section:
;
SLB_MAGIC	=	$70004afc		;should contain this constant
;
;This magic constant corresponds to the opcodes "moveq #0,d0" plus "illegal"
;----------------------------------------------------------------------------
	struct	SL				;SL structure start
	d_alias	SL_hd				;This is the header of the SL
	char	SL_hd_bp,128			;128 bytes of basepage reserved for gemdos
	char	SL_hd_path,128			;command line string, for SLB load path
	d_alias	SL_hd_end			;SL header ends here
	long	SL_magic			;SLB_MAGIC number for safety checks
	char_p	SL_name				;-> library name
	long	SL_version			;library version
	long	SL_flags			;flags
	func_p	SL_slb_init			;void cdecl (*slb_init) (void);
	func_p	SL_slb_exit			;void cdecl (*slb_exit) (void);
	func_p	SL_slb_open			;void cdecl (*slb_open) (BASPAG *);
	func_p	SL_slb_close			;void cdecl (*slb_close) (BASPAG *);
	long	SL_slb_opt			;optional -> procedure names
	long	SL_res,8			;
	long	SL_fun_cnt			;number of functions in table
	long	SL_fun_table,123		;table of function pointers
	d_end	SL				;SL structure end
;----------------------------------------------------------------------------
SLB_hd_def	MACRO	sl_name,version,funcs
	TEXT
	moveq	#0,d0		;dc.w	$7000	;1st magic word
	illegal			;dc.w	$4afc	;2nd magic word
	dc.l	SLB__name	;name
	dc.l	\2		;version
	dc.l	0		;flags
	dc.l	slb_init
	dc.l	slb_exit
	dc.l	slb_open
	dc.l	slb_close
	IFNC	'','\4'
	dc.l	SLB__strtbl	;slb_opt, optional -> array of -> procedure name strings
	ELSE
	dc.l	0		;slb_opt, optional -> array of -> procedure name strings
	ENDC
	dc.l	0,0,0,0,0,0,0,0	;8 longs, reserved under MagiC
SLB__ft	=	\3
	dc.l	SLB__ft
SLB__fc	set	0
	repeat	SLB__ft,SLB__tbldef
SLB__name:
	dc.b	'\1.slb',0
	EVEN
	IFNC	'','\4'
	SECTION	DATA
	EVEN
SLB__strtbl:
SLB__fc	set	0
	repeat	SLB__ft,SLB__strdef
	SECTION TEXT
	ENDC
	ENDM	;SLB_hd_def
;------------------------------------
SLB__tbldef	MACRO
	dc.l	SLB__code_\<SLB__fc>
SLB__fc	set	SLB__fc+1
	ENDM	;SLB__tbldef
;------------------------------------
SLB__strdef	MACRO
	dc.l	SLB__nstr_\<SLB__fc>
SLB__fc	set	SLB__fc+1
	ENDM	;SLB__strdef
;----------------------------------------------------------------------------
SLB_fn_def	MACRO	fn_name,fn_index,name_string
SLB__ix	set	\2
	IFD	SLB__flag_\<SLB__ix>
	FAIL	Function number \<SLB__ix> is not free for function '\1'
	MEXIT
	ENDC
SLB__flag_\<SLB__ix>	set	1
SLB__code_\<SLB__ix>:
SLB__func_\1:
SLB__fnix_\1	=	SLB__ix
	IFNC	'','\3'
SLB__sflg_\<SLB__ix>	set	1
	SECTION	DATA
SLB__nstr_\<SLB__ix>:
	dc.b	'\3',NUL
	SECTION	TEXT
	ENDC
	ENDM
;----------------------------------------------------------------------------
SLB_patch	MACRO	sl_name
SLB__fc	set	0
	repeat	SLB__ft,SLB__ptcdef
	ENDM	;patch
;------------------------------------
SLB__ptcdef	MACRO
	IFND	SLB__flag_\<SLB__fc>
SLB__code_\<SLB__fc>	=	NULL
	ENDC
	IFND	SLB__sflg_\<SLB__fc>
SLB__nstr_\<SLB__fc>	=	NULL
	ENDC
SLB__fc	set	SLB__fc+1
	ENDM	;SLB__ptcdef
;----------------------------------------------------------------------------
;
;----------------------------------------------------------------------------
SLB_lib		MACRO	lib_name
SLB__li		set	SLB__lc
SLB__lc		set	SLB__lc+1
SLB__fc		set	0
SLB__lib_\1	=	SLB__li
		ENDM
;------------------------------------
SLB__lc	set	0
;----------------------------------------------------------------------------
SLB_fun	MACRO	fun_name,arg_count,arg_flags
SLB__fi		set	SLB__fc
SLB__fc		set	SLB__fc+1
SLB__li_\1	=	SLB__li
SLB__fi_\1	=	SLB__fi
SLB__ac_\<SLB__li>_\<SLB__fi>	=	\2
SLB__af_\<SLB__li>_\<SLB__fi>	=	\3
	ENDM
;----------------------------------------------------------------------------
SLB_beg	MACRO	sl_name,path,minver
SLB__li	set	SLB__lib_\1
	IFND	SLB__iz_\<SLB__li>
SLB__iz_\<SLB__li>	set	1
	bra.s	SLB__beg_code_\1
SLB__sl_\<SLB__li>:
	dc.l	0
SLB__ex_\<SLB__li>:
	dc.l	0
SLB__nm_\<SLB__li>:
	dc.b	'\1.slb',NUL
	EVEN
SLB__jmp_\<SLB__li>:
	move.l	SLB__ex_\<SLB__li>(pc),-(sp)
	rts
SLB__beg_code_\1:
	ENDC
	gemdos	Slbopen,SLB__nm_\<SLB__li>,\2,\3,SLB__sl_\<SLB__li>,SLB__ex_\<SLB__li>
	ENDM
;----------------------------------------------------------------------------
SLB_exe	MACRO	fun_name,parmlen,par1,par2,par3,par4,par5,par6
SLB__li	set	SLB__li_\1
SLB__fi	set	SLB__fi_\1
SLB__ex	set	('\0'|$20)
SLB__af	set	((SLB__af_\<SLB__li>_\<SLB__fi>&$ffFFffF0)|$A)
	CDECL_args.\0	SLB__af,SLB__sl_\<SLB__li>,#SLB__fi,<\2>,<\3>,<\4>,<\5>,<\6>,<\7>,<\8>
	jsr	SLB__jmp_\<SLB__li>
	CDECL_cleanargs	<SLB_exe \1,\2>,SLB__ac_\<SLB__li>_\<SLB__fi>
	ENDM
;----------------------------------------------------------------------------
SLB_end	MACRO	sl_name
SLB__li	set	SLB__lib_\1
	gemdos	Slbclose|_ind,SLB__sl_\<SLB__li>
	ENDM
;----------------------------------------------------------------------------
	endc	;RA_SLB_defined
;----------------------------------------------------------------------------
; End of file:	RA_SLB.I
;----------------------------------------------------------------------------
