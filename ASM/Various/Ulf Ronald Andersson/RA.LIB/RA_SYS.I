;----------------------------------------------------------------------------
;File name:	RA_SYS.I			Revision date:	1999.11.03
;Creator:	Ulf Ronald Andersson		Creation date:	1992.11.15
;(c)1992 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Main macro & symbol library for Atari systems
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_SYS_defined
RA_SYS_defined	set	1
;----------------------------------------------------------------------------
;	MACRO DEFINITIONS
;----------------------------------------------------------------------------
;	Macro to repeat inline code sequences
;
;	The 'repeat' macro can repeat an operation or macro call any number
;	of times, as specified by the 'count' argument.  It does not have the
;	nestling limit of the REPT directive, but since the operation must be
;	specified as a simple argument, you must use '<' and '>' around any
;	such argument containing spaces or commas.  Define extra macros for
;       the cases where multiline sequences are needed, and specify those
;	macro names as 'op' argument to the 'repeat' macro
;----------------------------------------------------------------------------
repeat	MACRO	count,op
repct__\@	set	\1
	IFNE	repct__\@&1
	\2
	ENDC
repct__\@	set	repct__\@>>1
	IFNE	repct__\@
	repeat	repct__\@,<\2>
	repeat	repct__\@,<\2>
	ENDC
	ENDM	;repeat
;----------------------------------------------------------------------------
;	2 Macros to implement C-like structure data initialization
;
;'iz_beg' and 'iz_end' are macros to allow C-like initialization of
;array and structure data, with size checking and default (zero) filling.
;They define some labels internally, so they will break local label scope,
;but that is no real problem, since they are intended for global structures.
;----------------------------------------------------------------------------
iz_beg	MACRO	total_size
	ifnd	iz__lev
iz__lev	set	0
	endc
iz__ref_\{iz__lev}	set	\@
iz__base_\@:
iz__size_\@	= \1
iz__lev	set	iz__lev+1
	ENDM	;iz_beg
;------------------------------------
iz_end	MACRO
	IFND	iz__lev
	FAIL	'iz_end' was used without 'iz_beg'
	MEXIT
	ENDC
	IFNE	(iz__lev<=0)
	FAIL	'iz_end' was used with no matching 'iz_beg'
	ENDC
iz__lev	set	iz__lev-1
iz__ref	set	iz__ref_\{iz__lev}
iz__end_\{iz__ref}:
iz__pos	set	iz__end_\{iz__ref}-iz__base_\{iz__ref}
iz__excess	set	iz__pos-iz__size_\{iz__ref}
	IFNE	(iz__excess>0)
	FAIL	'iz_beg' size was exceeded by \{iz__excess} bytes.
	MEXIT
	ENDC
iz__excess	set	-iz__excess
	IFNE	(iz__excess>0)
	repeat	iz__excess,<dc.b 0>
	ENDC
	ENDM	;iz_end
;----------------------------------------------------------------------------
;The following 7 Macros implement assembly time indirection
;and allow indexed assemblytime constant and variable arrays,
;as well as many other creative assemblytime 'tricks'.
;
;ev_isym	dest,prefix,suffix	=> dest SET prefixXXXX
;sv_isym	prefix,suffix,value	=> prefixXXXX SET value
;sc_isym	prefix,suffix,value	=> prefixXXXX =   value
;sl_isym	prefix,suffix		=> prefixXXXX: ;label defined
;op_isym	op,prefix,suffix	=> op prefixXXXX
;op_isym_21	op,prefix,suffix,arg2	=> op prefixXXXX,arg2
;op_isym_22	op,arg1,prefix,suffix	=> op arg1,prefixXXXX
;
;	Above "XXXX" represents whatever hex digits the 'suffix' parameter
;	produces as the expression is evaluated, thus modifying the symbol.
;----------------------------------------------------------------------------
ev_isym	MACRO	dest_sym,prefix,suffix
RA__tmp	SET	(\3)
\1	SET	\2\<$RA__tmp>
	ENDM
;------------------------------------
sv_isym	MACRO	prefix,suffix,value
RA__tmp	SET	(\2)
\1\<$RA__tmp>	SET	\3
	ENDM
;------------------------------------
sc_isym	MACRO	prefix,suffix,value
RA__tmp	SET	(\2)
\1\<$RA__tmp>	=	\3
	ENDM
;------------------------------------
sl_isym	MACRO	prefix,suffix
RA__tmp	SET	(\2)
\1\<$RA__tmp>:
	ENDM
;------------------------------------
op_isym	MACRO	op,prefix,suffix
RA__tmp	SET	(\3)
	\1	\2\<$RA__tmp>
	ENDM	;op_isym
;------------------------------------
op_isym_21	MACRO	op,prefix,suffix,arg2
RA__tmp	SET	(\3)
	\1	\2\<$RA__tmp>,\4
	ENDM	;op_isym_21
;------------------------------------
op_isym_22	MACRO	op,arg1,prefix,suffix
RA__tmp	SET	(\4)
	\1	\2,\3\<$RA__tmp>
	ENDM	;op_isym_22
;----------------------------------------------------------------------------
;Five Macros to ease porting of C functions to assembly code.
;These implement simple declaration of local arguments & variables.
;
;lv_init	areg		=> link areg to give variables scope
;lv_arg.size	name,count	=> define function argument
;lv_var.size	name,count	=> define local variable
;lv_exit	areg		=> unlk areg and end variable scope
;lv__def.size	name,count	This is an internal submacro
;
;if 'areg' is 'a7' or 'sp' indexing is via stack pointer, with no linking
;'size' must be replaced by one of 'b','w','l','B','W','L'
;'size' may however be omitted, causing it to default to 'W'
;'count' may be omitted.  When used it defines arrays.
;-------
;A new rule has been added, which applies to lv_init and lv_exit, as well
;as two new ones (below).  This rule demands that the word "vars" or the
;word "args" be added as a second macro argument, if the 'areg' argument
;specifies the stack pointer, as only one of the two indexing modes work
;for that register.  The new argument chooses which one to use.
;-------
;Two new macros have been added to the above:
;
;lv_reinit	areg		=> make new entry point, like last lv_init
;lv_end		areg		=> end variable scope, but generate no code
;
;lv_reinit should only be used between an lv_init call and the corresponding
;lv_exit call, and will then define a new entry point identical to the one
;created for the preceding lv_init, but without altering the variable scope.
;
;lv_end should only be used after a routine ends with a jump to another routine
;which will handle the register unlinking, and only if this jump is where the
;variable scope should end.  (Not if the next routine uses lv_reinit...!)
;do the unlinking of
;----------------------------------------------------------------------------
lv__grp	SET	0
;------------------------------------
lv_init	MACRO	areg
lv__reg	SET	'\1'
lv__grp	SET	lv__grp+1
	IFNC	'a7','\1'
	IFNC	'A7','\1'
	IFNC	'sp','\1'
	IFNC	'SP','\1'
	IFNC	'sP','\1'
	IFNC	'Sp','\1'
lv__top	SET	8	;link_arg ref
lv__bot	SET	0	;link_var ref
lv__mod	SET	0	;link mode == 0
	op_isym_22	link,\1,#lv__bot_,lv__grp
	MEXIT
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
lv__top	SET	4	;sp_arg ref
lv__bot	SET	0	;sp_var ref
	IFNC	'args','\2'
	IFNC	'ARGS','\2'
	IFNC	'vars','\2'
	IFNC	'VARS','\2'
	FAIL	lv_init \1 needs ",args" or ",vars"
	MEXIT
	ENDC
	ENDC
lv__mod	SET	1	;sp_var mode == 1
	op_isym_21	sub,#lv__bot_,lv__grp,sp
	MEXIT
	ENDC
	ENDC
lv__mod	SET	2	;sp_arg mode == 2
	ENDM	;lv_init
;------------------------------------
lv_exit	MACRO	areg
	IFNE	('\1'-lv__reg)
	FAIL	lv_exit \1 mismatch, (must match lv_init)
	ENDC
;-------
	sc_isym	lv__top_,lv__grp,lv__top
	sc_isym	lv__bot_,lv__grp,lv__bot
	IFNC	'a7','\1'
	IFNC	'A7','\1'
	IFNC	'sp','\1'
	IFNC	'SP','\1'
	IFNC	'sP','\1'
	IFNC	'Sp','\1'
	IFNE	(lv__mod=0)
	unlk	\1
	ELSE
	FAIL	lv_exit \1 mismatch (lv_init uses stack pointer)
	ENDC
	MEXIT
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
;-------			;getting here means SP was used as 'areg'
	IFNE	(lv__mod>0)
	IFNE	(lv__mod=1)
	IFNE	(lv__bot)
	IFNE	((lv__bot)<9)
	addq	#lv__bot,sp
	ELSE
	lea	lv__bot(sp),sp
	ENDC
	ENDC
	IFNC	'vars','\2'
	IFNC	'VARS','\2'
	FAIL	lv_exit \1 needs ",vars"
	MEXIT
	ENDC
	ENDC
	ELSE	;lv__mod == 2
	IFNC	'args','\2'
	IFNC	'ARGS','\2'
	FAIL	lv_exit \1 needs ",args"
	MEXIT
	ENDC
	ENDC
	ENDC
	ELSE
	FAIL	lv_exit \1 mismatch (lv_init doesn't use stack pointer)
	ENDC
	ENDM	;lv_exit
;------------------------------------
lv_reinit	MACRO	areg
	IFNE	('\1'-lv__reg)
	FAIL	lv_reinit \1 mismatch, (must match lv_init)
	ENDC
;-------
	IFNC	'a7','\1'
	IFNC	'A7','\1'
	IFNC	'sp','\1'
	IFNC	'SP','\1'
	IFNC	'sP','\1'
	IFNC	'Sp','\1'
	IFNE	(lv__mod=0)
	op_isym_22	link,\1,#lv__bot_,lv__grp
	ELSE
	FAIL	lv_reinit \1 mismatch  (lv_init uses stack pointer)
	ENDC
	MEXIT
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
;-------			;getting here means SP was used as 'areg'
	IFNE	(lv__mod>0)
	IFNE	(lv__mod=1)
	op_isym_21	sub,#lv__bot_,lv__grp,sp
	IFNC	'vars','\2'
	IFNC	'VARS','\2'
	FAIL	lv_reinit \1 needs ",vars"
	MEXIT
	ENDC
	ENDC
	ELSE	;lv__mod == 2
	IFNC	'args','\2'
	IFNC	'ARGS','\2'
	FAIL	lv_reinit \1 needs ",args"
	MEXIT
	ENDC
	ENDC
	ENDC
	ELSE	;lv__mod == 0
	FAIL	lv_exit \1 mismatch  (lv_init doesn't use stack pointer)
	ENDC
	ENDM	;lv_reinit
;------------------------------------
lv_end	MACRO	areg
	IFNE	('\1'-lv__reg)
	FAIL	lv_end \1 mismatch, (must match lv_init)
	ENDC
;-------
	sc_isym	lv__top_,lv__grp,lv__top
	sc_isym	lv__bot_,lv__grp,lv__bot
	IFNC	'a7','\1'
	IFNC	'A7','\1'
	IFNC	'sp','\1'
	IFNC	'SP','\1'
	IFNC	'sP','\1'
	IFNC	'Sp','\1'
	IFNE	(lv__mod=0)
	ELSE
	FAIL	lv_end \1 mismatch (lv_init uses stack pointer)
	ENDC
	MEXIT
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
;-------			;getting here means SP was used as 'areg'
	IFNE	(lv__mod>0)
	IFNE	(lv__mod=1)
	IFNC	'vars','\2'
	IFNC	'VARS','\2'
	FAIL	lv_end \1 needs ",vars"
	MEXIT
	ENDC
	ENDC
	ELSE	;lv__mod == 2
	IFNC	'args','\2'
	IFNC	'ARGS','\2'
	FAIL	lv_end \1 needs ",args"
	MEXIT
	ENDC
	ENDC
	ENDC
	ELSE
	FAIL	lv_end \1 mismatch (lv_init doesn't use stack pointer)
	ENDC
	ENDM	;lv_end
;------------------------------------
lv_var	MACRO	name,count
	IFNE	(lv__mod=2)
	FAIL	lv_var.\0 \1,\2 illegal in mode "sp,args"
	MEXIT
	ENDC
	IFNE	(lv__mod=1)
\1	SET	lv__bot
	IFNC	'','\2'
	lv__def.\0	lv__bot,(\2)
	ELSEIF
	lv__def.\0	lv__bot,1
	ENDC
	MEXIT
	ENDC
	IFNC	'','\2'
	lv__def.\0	lv__bot,-(\2)
	ELSEIF
	lv__def.\0	lv__bot,-1
	ENDC
\1	SET	lv__bot
	ENDM	;lv_var
;------------------------------------
lv_arg	MACRO	name,count
	IFNE	(lv__mod=1)
	FAIL	lv_arg.\0 \1,\2 illegal in mode "sp,vars"
	MEXIT
	ENDC
\1	SET	lv__top
	IFNC	'','\2'
	lv__def.\0	lv__top,(\2)
	ELSEIF
	lv__def.\0	lv__top,1
	ENDC
	ENDM	;lv_arg
;------------------------------------
lv__def	MACRO	name,count
	IFNE	(NARG>2)
	FAIL	Extra arg in: lv__def.\0 \1,\2,\3
	MEXIT
	ENDC
	IFNE	(NARG<1)
	FAIL	Missing args in: lv__def.\0
	MEXIT
	ENDC
	IFNE	(NARG=1)
lv__cnt	SET	1
	ELSEIF
	IFC	'','\2'
lv__cnt	SET	1
	ELSEIF
lv__cnt	SET	\2
	ENDC
	ENDC
;
lv__typ	set	'\0'
	IFNE	(lv__typ>'Z')
lv__typ	set	lv__typ-32
	ENDC
	IFNE	(lv__typ='B')
lv__exp	set	0
	ELSEIF
	IFNE	(lv__typ='W')
lv__exp	set	1
	ELSEIF
	IFNE	(lv__typ='L')
lv__exp	set	2
	ELSEIF
	FAIL	Unknown type used in: lv__def.\0 \1,\2
	MEXIT
	ENDC
	ENDC
	ENDC
\1	SET	\1+lv__cnt<<lv__exp
	ENDM	;lv__def
;----------------------------------------------------------------------------
;Three macros to implement CDECL argument handling for submacro
;subroutine calls. Two are intended for use in unrelated macros.
;A maximum of 16 arguments can be handled.
;
CDECL_args	MACRO	arg_flags,v1,v2,v3,v4,v5,v6,v7,v8,v9,va,vb,vc,vd,ve,vf,vg
CDECL__size	SET	0
CDECL__count	SET	0
CDECL__flags	SET	\1
	IFNC	'','\2'	;v1
	IFNC	'','\3'	;v2
	IFNC	'','\4'	;v3
	IFNC	'','\5'	;v4
	IFNC	'','\6'	;v5
	IFNC	'','\7'	;v6
	IFNC	'','\8'	;v7
	IFNC	'','\9'	;v8
	IFNC	'','\a'	;v9
	IFNC	'','\b'	;va
	IFNC	'','\c'	;vb
	IFNC	'','\d'	;vc
	IFNC	'','\e'	;vd
	IFNC	'','\f'	;ve
	IFNC	'','\g'	;vf
	IFNC	'','\h'	;vg
	CDECL__arg.\0	CDECL__flags>>30,<\h>
	ENDC	;vg
	CDECL__arg.\0	CDECL__flags>>28,<\g>
	ENDC	;vf
	CDECL__arg.\0	CDECL__flags>>26,<\f>
	ENDC	;ve
	CDECL__arg.\0	CDECL__flags>>24,<\e>
	ENDC	;vd
	CDECL__arg.\0	CDECL__flags>>22,<\d>
	ENDC	;vc
	CDECL__arg.\0	CDECL__flags>>20,<\c>
	ENDC	;vb
	CDECL__arg.\0	CDECL__flags>>18,<\b>
	ENDC	;va
	CDECL__arg.\0	CDECL__flags>>16,<\a>
	ENDC	;v9
	CDECL__arg.\0	CDECL__flags>>14,<\9>
	ENDC	;v8
	CDECL__arg.\0	CDECL__flags>>12,<\8>
	ENDC	;v7
	CDECL__arg.\0	CDECL__flags>>10,<\7>
	ENDC	;v6
	CDECL__arg.\0	CDECL__flags>>8,<\6>
	ENDC	;v5
	CDECL__arg.\0	CDECL__flags>>6,<\5>
	ENDC	;v4
	CDECL__arg.\0	CDECL__flags>>4,<\4>
	ENDC	;v3
	CDECL__arg.\0	CDECL__flags>>2,<\3>
	ENDC	;v2
	CDECL__arg.\0	CDECL__flags,<\2>
	ENDC	;v1
	ENDM	;CDECL_arg
;-------------------------------------
CDECL_cleanargs	MACRO	function,arg_count
	IFNE	CDECL__size
	IFNE	CDECL__size>8
	add	#CDECL__size,sp
	ELSEIF
	addq	#CDECL__size,sp
	ENDC
	ENDC
	IFNE	CDECL__count-(\2)
	FAIL	Function \1 _had_ \<CDECL__count> arguments
CDECL__count	SET	(\2)
	FAIL	Function \1 needs \<CDECL__count> arguments
	ENDC
	ENDM	;CDECL_cleanargs
;-------------------------------------
CDECL__arg	MACRO	flags,arg
CDECL__count	SET	CDECL__count+1
	IFNE	(\1&3)=3	;pointer arg ?
CDECL__size	SET	CDECL__size+4
	IFC	'!','\2'
	clr.l	-(sp)
	MEXIT
	ENDC	;'!'
	IFC	'?','\2'
	pea	-1.w
	MEXIT
	ENDC	;'?'
	IFC	'()','\2'
	MEXIT
	ENDC	;'()'
	IFC	'\0','i'	;indirection mode ?
	move.l	\2,-(sp)
	ELSEIF	;not 'i' indirection
	IFC	'\0','I'	;indirection mode ?
	move.l	\2,-(sp)
	ELSEIF	;not 'I' indirection
	pea	\2
	ENDC	;'I' indirection
	ENDC	;'i' indirection
	MEXIT
	ENDC	;ptr
	IFNE	(\1&3)=2	;long arg ?
CDECL__size	SET	CDECL__size+4
	IFC	'!','\2'
	clr.l	-(sp)
	MEXIT
	ENDC	;'!'
	IFC	'?','\2'
	pea	-1.w
	MEXIT
	ENDC	;'?'
	IFC	'()','\2'
	MEXIT
	ENDC	;'()'
	move.l	\2,-(sp)
	MEXIT
	ENDC	;long
CDECL__size	SET	CDECL__size+2
	IFC	'!','\2'
	clr	-(sp)
	MEXIT
	ENDC	;'!'
	IFC	'?','\2'
	move	#-1.w,-(sp)
	MEXIT
	ENDC	;'?'
	IFC	'()','\2'
	MEXIT
	ENDC	;'()'
	IFNE	(\1&3)=1	;word arg ?
	move.w	\2,-(sp)
	ELSEIF	;not word arg, must be byte
	move.b	\2,-(sp)
	ENDC	;word
	ENDM	;CDECL__arg
;----------------------------------------------------------------------------
;Six macros to implement PureC argument handling for submacro
;subroutine calls. Two are intended for use in unrelated macros.
;A maximum of 16 arguments can be handled.
;
PUREC_args	MACRO	arg_flags,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16
PUREC__size	SET	0
PUREC__count	SET	0
PUREC__areg	SET	0
PUREC__dreg	SET	0
PUREC__flags	SET	\1
	IFNC	'','\2'	;v1
	PUREC__type	1,PUREC__flags
	IFNC	'','\3'	;v2
	PUREC__type	2,PUREC__flags>>2
	IFNC	'','\4'	;v3
	PUREC__type	3,PUREC__flags>>4
	IFNC	'','\5'	;v4
	PUREC__type	4,PUREC__flags>>6
	IFNC	'','\6'	;v5
	PUREC__type	5,PUREC__flags>>8
	IFNC	'','\7'	;v6
	PUREC__type	6,PUREC__flags>>10
	IFNC	'','\8'	;v7
	PUREC__type	7,PUREC__flags>>12
	IFNC	'','\9'	;v8
	PUREC__type	8,PUREC__flags>>14
	IFNC	'','\a'	;v9
	PUREC__type	9,PUREC__flags>>16
	IFNC	'','\b'	;v10
	PUREC__type	10,PUREC__flags>>18
	IFNC	'','\c'	;v11
	PUREC__type	11,PUREC__flags>>20
	IFNC	'','\d'	;v12
	PUREC__type	12,PUREC__flags>>22
	IFNC	'','\e'	;v13
	PUREC__type	13,PUREC__flags>>24
	IFNC	'','\f'	;v14
	PUREC__type	14,PUREC__flags>>26
	IFNC	'','\g'	;v15
	PUREC__type	15,PUREC__flags>>28
	IFNC	'','\h'	;v16
	PUREC__type	16,PUREC__flags>>30
	PUREC__arg.\0	16,<\h>
	ENDC	;v16
	PUREC__arg.\0	15,<\g>
	ENDC	;v15
	PUREC__arg.\0	14,<\f>
	ENDC	;v14
	PUREC__arg.\0	13,<\e>
	ENDC	;v13
	PUREC__arg.\0	12,<\d>
	ENDC	;v12
	PUREC__arg.\0	11,<\c>
	ENDC	;v11
	PUREC__arg.\0	10,<\b>
	ENDC	;v10
	PUREC__arg.\0	9,<\a>
	ENDC	;v9
	PUREC__arg.\0	8,<\9>
	ENDC	;v8
	PUREC__arg.\0	7,<\8>
	ENDC	;v7
	PUREC__arg.\0	6,<\7>
	ENDC	;v6
	PUREC__arg.\0	5,<\6>
	ENDC	;v5
	PUREC__arg.\0	4,<\5>
	ENDC	;v4
	PUREC__arg.\0	3,<\4>
	ENDC	;v3
	PUREC__arg.\0	2,<\3>
	ENDC	;v2
	PUREC__arg.\0	1,<\2>
	ENDC	;v1
	ENDM	;PUREC_args
;-------------------------------------
PUREC_cleanargs	MACRO	function,arg_count
	IFNE	PUREC__size
	IFNE	PUREC__size>8
	add	#PUREC__size,sp
	ELSEIF	;not size>8
	addq	#PUREC__size,sp
	ENDC	;size>8
	ENDC	;size
	IFNE	PUREC__count-(\2)
	FAIL	Function \1 _had_ \<PUREC__count> arguments
PUREC__count	SET	(\2)
	FAIL	Function \1 needs \<PUREC__count> arguments
	ENDC	;count
	ENDM	;PUREC_cleanargs
;-------------------------------------
PUREC__type	MACRO	index,flags
	IFNE	(\2&3)=3	;pointer arg ?
	IFNE	PUREC__areg<2
	IFNE	PUREC__areg<1
PUREC_type_\1	SET	$30
	ELSEIF
PUREC_type_\1	SET	$31
	ENDC
PUREC__areg	SET	PUREC__areg+1
	ELSEIF
PUREC_type_\1	SET	$3F
	ENDC
	ELSEIF	;not pointer
PUREC_type_\1	SET	(\2&3)<<4
	IFNE	PUREC__dreg<3
	IFNE	PUREC__dreg<2
	IFNE	PUREC__dreg<1
PUREC_type_\1	SET	0+PUREC_type_\1
	ELSEIF
PUREC_type_\1	SET	1+PUREC_type_\1
	ENDC
	ELSEIF
PUREC_type_\1	SET	2+PUREC_type_\1
	ENDC
PUREC__dreg	SET	PUREC__dreg+1
	ELSEIF
PUREC_type_\1	SET	$F+PUREC_type_\1
	ENDC
	ENDC
	ENDM	;PUREC__type
;-------------------------------------
PUREC__arg	MACRO	index,arg
PUREC__count	SET	PUREC__count+1
	IFNE	(PUREC_type_\1)>$2F	;pointer arg ?
	IFNE	(PUREC_type_\1&15)<2
	IFNE	(PUREC_type_\1&15)<1
	PUREC__ptr.\0	<\2>,a0,PURE
	ELSEIF
	PUREC__ptr.\0	<\2>,a1,PURE
	ENDC
	ELSEIF
PUREC__size	SET	PUREC__size+4
	PUREC__ptr.\0	<\2>,-(sp),CDEC
	ENDC
	ELSEIF
	IFNE	(PUREC_type_\1&15)<3
	IFNE	(PUREC_type_\1&15)<2
	IFNE	(PUREC_type_\1&15)<1
	PUREC__data.\0	(PUREC_type_\1>>4),<\2>,d0,PURE
	ELSEIF
	PUREC__data.\0	(PUREC_type_\1>>4),<\2>,d1,PURE
	ENDC
	ELSEIF
	PUREC__data.\0	(PUREC_type_\1>>4),<\2>,d2,PURE
	ENDC
	ELSEIF
	PUREC__data.\0	(PUREC_type_\1>>4),<\2>,-(sp),CDEC
PUREC__size	SET	PUREC__size+PUREC_inc_size
	ENDC
	ENDC
	ENDM	;PUREC__arg
;-------------------------------------
PUREC__data	MACRO	flags,arg,dest,method
	IFNE	(\1&3)=2	;long arg ?
PUREC_inc_size	SET	4
	IFC	'!','\2'
	clr.l	\3
	MEXIT
	ENDC	;'!'
	IFC	'?','\2'
	IFC	'CDEC','\4'	;stacking ?
	pea	-1.w
	ELSEIF	;not stacking
	moveq	#-1,\4
	ENDC	;stacking
	MEXIT
	ENDC	;'?'
	IFC	'()','\2'
	MEXIT
	ENDC	;'()'
	IFNC	'\2','\3'
	move.l	\2,\3
	ENDC
	ELSEIF	;not long arg
PUREC_inc_size	SET	2
	IFC	'!','\2'
	clr	\3
	MEXIT
	ENDC	;'!'
	IFC	'?','\2'
	move	#-1,\3
	MEXIT
	ENDC	;'?'
	IFC	'()','\2'
	MEXIT
	ENDC	;'()'
	IFNE	(\1&3)=1	;word arg ?
	IFNC	'\2','\3'
	move.w	\2,\3
	ENDC
	ELSEIF	;not word arg
	IFNC	'\2','\3'
	move.b	\2,\3
	ENDC
	ENDC	;word
	ENDC	;long
	ENDM	;PUREC__data
;-------------------------------------
PUREC__ptr	MACRO	arg,dest,method
	IFC	'!','\1'
	IFC	'CDEC','\3'	;stacking ?
	clr.l	-(sp)
	ELSEIF	;not stacking
	suba.l	\2,\2
	ENDC	;stacking
	MEXIT
	ENDC	;'!'
	IFC	'?','\1'
	IFC	'CDEC','\3'	;stacking ?
	pea	-1.w
	ELSEIF	;not stacking
	lea	-1.w,\2
	ENDC	;stacking
	MEXIT
	ENDC	;'?'
	IFC	'()','\1'
	MEXIT
	ENDC	;'()'
	IFC	'\0','i'	;'i' indirection mode ?
	IFNC	'\1','\2'
	move.l	\1,\2
	ENDC
	ELSEIF	;not 'i' indirection
	IFC	'\0','I'	;'I' indirection mode ?
	IFNC	'\1','\2'
	move.l	\1,\2
	ENDC
	ELSEIF	;not 'I' indirection
	IFC	'CDEC','\3'	;stacking ?
	pea	\1
	ELSEIF	;not stacking
	lea	\1,\2
	ENDC	;stacking
	ENDC	;'I' indirection
	ENDC	;'i' indirection
	ENDM	;PUREC__ptr
;----------------------------------------------------------------------------
;Four macros to call subroutines and library functions with arguments.
;These use macros defined above, and are useful to define API functions.
;
CDECL_sub	MACRO	sub,acnt,aflg,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16
	CDECL_args.\0	<\3>,<\4>,<\5>,<\6>,<\7>,<\8>,<\9>,<\a>,<\b>,<\c>,<\d>,<\e>,<\f>,<\g>,<\h>,<\i>,<\j>
	jsr	\1
	CDECL_cleanargs	\1,\2
	ENDM	;CDECL_sub
;-------------------------------------
PUREC_sub	MACRO	sub,acnt,aflg,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16
	PUREC_args.\0	<\3>,<\4>,<\5>,<\6>,<\7>,<\8>,<\9>,<\a>,<\b>,<\c>,<\d>,<\e>,<\f>,<\g>,<\h>,<\i>,<\j>
	jsr	\1
	PUREC_cleanargs	\1,\2
	ENDM	;PUREC_sub
;-------------------------------------
CDECL_func	MACRO	function,arg_count,arg_flags,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16
	CDECL_args.\0	<\3>,<\4>,<\5>,<\6>,<\7>,<\8>,<\9>,<\a>,<\b>,<\c>,<\d>,<\e>,<\f>,<\g>,<\h>,<\i>,<\j>
	_uniref	\1
	jsr	\1_code
	CDECL_cleanargs	\1,\2
	ENDM	;CDECL_func
;-------------------------------------
PUREC_func	MACRO	function,arg_count,arg_flags,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16
	PUREC_args.\0	<\3>,<\4>,<\5>,<\6>,<\7>,<\8>,<\9>,<\a>,<\b>,<\c>,<\d>,<\e>,<\f>,<\g>,<\h>,<\i>,<\j>
	_uniref	\1
	jsr	\1_code
	PUREC_cleanargs	\1,\2
	ENDM	;PUREC_func
;----------------------------------------------------------------------------
;	Macro to XDEF labels only at requested debugging levels
;
_debdef	MACRO	symbol,levlim
	IFD	_deblev
	IFNE	_deblev>=\2
	XDEF	\1
	ENDC
	ENDC
	ENDM
;-------------------------------------
	IFND	_deblev
_deblev	set	0
	ENDC
;----------------------------------------------------------------------------
;	The following three macros implement assembly-time module linking
;	on assembly source level of the code
;
_uniref		MACRO	sym
		IFND	_uni_ct\1
		IFD	_uni_rf\1
		IFND	_uni_ok\1
		FAIL	Missing \1 macro links, use 'make' or '_unidef'
		ENDC
		ENDC
_uni_ct\1	set	1
_uni_rf\1	=	1
		ELSEIF
_uni_ct\1	set	_uni_ct\1+1
		ENDC
		ENDM	;_uniref
;-------------------------------------
_unidef		MACRO	syms
		IFND	_uni_df\1
		IFD	_uni_ct\1
_uni_df\1	set	1
_uni_ok\1	=	1
_uni_flag	set	1
\1_code:
		\1_code		;actual code expanded here
		ENDC
		ENDC
		IFNC	'','\2'
		_unidef	\2,\3,\4,\5,\6,\7,\8,\9,\10
		ENDC
		ENDM	;_unidef
;-------------------------------------
make		MACRO	linkmacros
_uni_flag	set	0
		\1
		IFNE	_uni_flag
		make	\1
		ENDC
		IFNC	'','\2'
		make	\2,\3,\4,\5,\6,\7,\8,\9,\10
		ENDC
		ENDM	;make
;
;----------------------------------------------------------------------------
;	The following macro defines unique labels
;
_unilab		MACRO	symbol
		IFND	_uni_lb\1
_uni_lb\1	set	1
\1:
_uni_flag	set	1
		ELSEIF
_uni_flag	set	0
		ENDC
		ENDM
;----------------------------------------------------------------------------
;	The following macro defines unique symbols
;
_unisym		MACRO	symbol,value
		IFND	_uni_lb\1
_uni_lb\1	set	1
\1		= \2
_uni_flag	set	1
		ELSEIF
_uni_flag	set	0
		ENDC
		ENDM
;----------------------------------------------------------------------------
;	Macro to create an exception frame on supervisor stack
;
push_ex	MACRO	v1,v2
	tst	_longframe
	beq.s	.cpu_adapted_\@
	clr	-(sp)
.cpu_adapted_\@:
	IFNE	(NARG=1)
	IFC	'i','\0'
	move.l	\1,-(sp)
	ELSEIF
	IFC	'I','\0'
	move.l	\1,-(sp)
	ELSEIF
	pea	\1
	ENDC	;'I'
	ENDC	;'i'
	ELSEIF	;NARG=1
	IFNE	(NARG=2)
	IFNE	(_ind=\1)
	move.l	\2,-(sp)
	ELSEIF	;_ind
	FAIL	Strange 'push_ex' arguments: \1,\2
	ENDC	;_ind
	ELSEIF	;NARG=2
	FAIL	Strange 'push_ex' arguments: \1,\2
	ENDC	;NARG=2
	ENDC	;NARG=1
	move	sr,-(sp)
	ENDM	;push_ex
;----------------------------------------------------------------------------
;	Macro for good 32-bit random function (31-bit pseudorandomicity)
;NB:	d0 = result  d1 = smashed
;
rand_32	macro	;generates 32 new bits per go
	IFND	rand_32_defined
rand_32_defined	set	1
	bsr.s	rand_32_code
	bra.s	rand_32_code_end
;
rand_32_code:
	move.l	rand_32_seed(pc),d0	;seed = last value (bit 31 irrelevant)
	move.l	d0,d1	;copy to d1  (bit 31 will be lost later)
	lsr.l	#3,d1	;shift d1 by 3 bits for 31 bit pseudorandomicity
	eor.w	d1,d0	;generate 16 new pseudorandom top bits 
	swap	d0	;align 16 new bits correctly
	roxl.w	#1,d0	;align 15 old bits, orig bit 2 as bit 0, lose orig bit 31
	ror.l	#1,d0	;Adjust 31-bit pseudorandom shifter (bit 31=orig bit 2)
	move.l	d0,d1	;copy to d1  (dummy bit 31 will be lost later)
	lsr.l	#3,d1	;shift d1 by 3 bits for 31 bit pseudorandomicity
	eor.w	d1,d0	;generate 16 new pseudorandom top bits 
	swap	d0	;align 16 new bits correctly
	roxl.w	#1,d0	;align 15 old bits, get dummy bit 0, lose dummy bit 31
	ror.l	#1,d0	;Adjust 31-bit pseudorandom shifter (bit 31 = new dummy)
	move.l	d0,rand_32_seed		;store seed (bit 31 irrelevant)
	rts
;
;NB: In the above "irrelevant" means that bit 31 has no effect on future
;    results from the generator, although this bit too is pseudorandom.
;
rand_32_seed:	dc.l	'Rand'	;Arbitrary seed.  Avoid 0 and $80000000 (Don't work)
rand_32_code_end:
	ELSEIF
	jsr	rand_32_code
	ENDC
	ENDM	;rand_32
;----------------------------------------------------------------------------
;	Macro for good 32-bit hashing function (31-bit pseudorandomicity)
;NB:	d0 = result  d1 = smashed
;
hash_32	MACRO	;generates 32 new bits per go
	IFND	hash_32_defined
hash_32_defined	set	1
	bsr.s	hash_32_code
	bra.s	hash_32_code_end
;
hash_32_code:
	move.l	d0,d1	;copy to d1  (bit 31 will be lost later)
	lsr.l	#3,d1	;shift d1 by 3 bits for 31 bit pseudorandomicity
	eor.w	d1,d0	;generate 16 new pseudorandom top bits 
	swap	d0	;align 16 new bits correctly
	roxl.w	#1,d0	;align 15 old bits, orig bit 2 as bit 0, lose orig bit 31
	ror.l	#1,d0	;Adjust 31-bit pseudorandom shifter (bit 31=orig bit 2)
	move.l	d0,d1	;copy to d1  (dummy bit 31 will be lost later)
	lsr.l	#3,d1	;shift d1 by 3 bits for 31 bit pseudorandomicity
	eor.w	d1,d0	;generate 16 new pseudorandom top bits 
	swap	d0	;align 16 new bits correctly
	roxl.w	#1,d0	;align 15 old bits, get dummy bit 0, lose dummy bit 31
	ror.l	#1,d0	;Adjust 31-bit pseudorandom shifter (bit 31 = new dummy)
	rts
hash_32_code_end:
	ELSEIF
	jsr	hash_32_code
	ENDC
	ENDM	;hash_32
;----------------------------------------------------------------------------
;Macro for code size padding
;
sz_pad	MACRO	id,limit,pos
sz_pad__tmp	set	\2-\3
	IFNE	(sz_pad__tmp>0)
	dcb.b	sz_pad__tmp,0
;--Note--;	\1 was padded by $\<$sz_pad__tmp> bytes. OK!
	ELSE
	IFNE	(sz_pad__tmp<0)
sz_pad__tmp	set	-sz_pad__tmp
	FAIL	\1 was too large by $\<$sz_pad__tmp> bytes.
	ELSE
;--Note--;	\1 used $\<$sz_pad__tmp> bytes (no padding). OK!
	ENDC
	ENDC
	ENDM	;sz_pad
;----------------------------------------------------------------------------
;Three macros to copy memory    NB: 2 aregs & 1 dreg changed
;
;mem_copy_b.sz	s_areg,d_areg,len_dreg	=> copy as bytes
;mem_copy_w.sz	s_areg,d_areg,len_dreg	=> copy as words
;mem_copy_l.sz	s_areg,d_areg,len_dreg	=> copy as longs
;
;The copying does allow for overlap of source and destination,
;and the '.sz' specifier can be 'b','w','l','B','W','L' and
;specifies the size of the data length in 'len_dreg'.  These
;macros generate inline code, without any subroutine calls.
;----------------------------------------------------------------------------
mem_copy_b	MACRO	src_areg,dest_areg,len_dreg
	cmp.l	\1,\2
	bhi.s	.mem_copy_up_\@
	blo.s	.mem_copy_down_ct_,uni__v
	bra.s	.mem_copy_done_\@
.mem_copy_down_lp_\@:
	move.b	(\1)+,(\2)+
.mem_copy_down_ct_\@:
	subq.\0	#1,\3
	bcc.s	.mem_copy_down_lp_\@
	bra.s	.mem_copy_done_\@
.mem_copy_up_\@:
	add.l	\3,\1
	add.l	\3,\2
	bra.s	.mem_copy_up_ct_\@
.mem_copy_up_lp_\@:
	move.b	-(\1),-(\2)
.mem_copy_up_ct_\@:
	subq.\0	#1,\3
	bcc.s	.mem_copy_up_lp_\@
.mem_copy_done_\@:
	ENDM	;mem_copy_b
;-------------------------------------
mem_copy_w	MACRO	src_areg,dest_areg,len_dreg
	cmp.l	\1,\2
	bhi.s	.mem_copy_up_\@
	blo.s	.mem_copy_down_ct_,uni__v
	bra.s	.mem_copy_done_\@
.mem_copy_down_lp_\@:
	move.w	(\1)+,(\2)+
.mem_copy_down_ct_\@:
	subq.\0	#2,\3
	bcc.s	.mem_copy_down_lp_\@
	bra.s	.mem_copy_done_\@
.mem_copy_up_\@:
	add.l	\3,\1
	add.l	\3,\2
	bra.s	.mem_copy_up_ct_\@
.mem_copy_up_lp_\@:
	move.w	-(\1),-(\2)
.mem_copy_up_ct_\@:
	subq.\0	#2,\3
	bcc.s	.mem_copy_up_lp_\@
.mem_copy_done_\@:
	ENDM	;mem_copy_w
;-------------------------------------
mem_copy_l	MACRO	src_areg,dest_areg,len_dreg
	cmp.l	\1,\2
	bhi.s	.mem_copy_up_\@
	blo.s	.mem_copy_down_ct_,uni__v
	bra.s	.mem_copy_done_\@
.mem_copy_down_lp_\@:
	move.l	(\1)+,(\2)+
.mem_copy_down_ct_\@:
	subq.\0	#4,\3
	bcc.s	.mem_copy_down_lp_\@
	bra.s	.mem_copy_done_\@
.mem_copy_up_\@:
	add.l	\3,\1
	add.l	\3,\2
	bra.s	.mem_copy_up_ct_\@
.mem_copy_up_lp_\@:
	move.l	-(\1),-(\2)
.mem_copy_up_ct_\@:
	subq.\0	#4,\3
	bcc.s	.mem_copy_up_lp_\@
.mem_copy_done_\@:
	ENDM	;mem_copy_l
;----------------------------------------------------------------------------
;Three macros to copy buffers    NB: 2 aregs & 1 dreg changed
;
;buf_copy_b.sz	s_areg,d_areg,len_dreg	=> copy as bytes
;buf_copy_w.sz	s_areg,d_areg,len_dreg	=> copy as words
;buf_copy_l.sz	s_areg,d_areg,len_dreg	=> copy as longs
;
;The code does not allow for overlap of source and destination,
;and the '.sz' specifier can be 'b','w','l','B','W','L' and
;specifies the size of the data length in 'len_dreg'.  These
;macros generate inline code, without any subroutine calls.
;----------------------------------------------------------------------------
buf_copy_b	MACRO	src_areg,dest_areg,len_dreg
	bra.s	.buf_copy_ct_\@
.buf_copy_lp_\@:
	move.b	(\1)+,(\2)+
.buf_copy_ct_\@:
	subq.\0	#1,\3
	bcc.s	.buf_copy_lp_\@
	ENDM	;buf_copy_b
;-------------------------------------
buf_copy_w	MACRO	src_areg,dest_areg,len_dreg
	bra.s	.buf_copy_ct_\@
.buf_copy_lp_\@:
	move.w	(\1)+,(\2)+
.buf_copy_ct_\@:
	subq.\0	#2,\3
	bcc.s	.buf_copy_lp_\@
	ENDM	;buf_copy_w
;-------------------------------------
buf_copy_l	MACRO	src_areg,dest_areg,len_dreg
	bra.s	.buf_copy_ct_\@
.buf_copy_lp_\@:
	move.l	(\1)+,(\2)+
.buf_copy_ct_\@:
	subq.\0	#4,\3
	bcc.s	.buf_copy_lp_\@
	ENDM	;buf_copy_l
;----------------------------------------------------------------------------
;Macros to pass a string
;----------------------------------------------------------------------------
strpass	MACRO	p1
.strpass_\@:
	tst.b	(\1)+
	bne.s	.strpass_\@
	ENDM 
;-------------------------------------
str_pass	MACRO	p1
.strpass_\@:
	tst.b	(\1)+
	bne.s	.strpass_\@
	ENDM 
;----------------------------------------------------------------------------
;Macros to copy a string    NB: 2 adress regs are also changed
;----------------------------------------------------------------------------
strcpy	MACRO	p1,p2
.strcpy_\@:
	move.b	(\1)+,(\2)+
	bne.s	.strcpy_\@
	ENDM
;-------------------------------------
str_copy	MACRO	p1,p2
.strcpy_\@:
	move.b	(\1)+,(\2)+
	bne.s	.strcpy_\@
	ENDM
;----------------------------------------------------------------------------
;	Macro to concatenate strings    NB: 2 address regs changed
;
str_conc	MACRO	src_areg,dest_areg
	str_pass	\2
	subq		#1,\2
.str_conc_\@
	move.b	(\1)+,(\2)+
	bne.s	.str_conc_\@
	ENDM	;str_conc
;----------------------------------------------------------------------------
;	Macro to compare two strings	NB: 2 address regs changed
;
str_comp	MACRO	areg_1,areg_2
.str_comp_loop_\@:
	tst.b	(\1)
	beq.s	.str_comp_term_1_\@
	cmpm.b	(\1)+,(\2)+
	beq.s	.str_comp_loop_\@
	bra.s	.str_comp_done_\@
.str_comp_term_1_\@:
	tst.b	(\2)
.str_comp_done_\@:
	ENDM	;str_comp
;
;NB: After comparison areg_1 will never have stepped past its terminator,
;    but areg_2 may have done so.  This can be important in some code...
;    Also, if the strings are equal, both areg_1 and areg_2 will point
;    at their respective terminators on exit.
;----------------------------------------------------------------------------
;	CONSTANT DEFINITIONS
;----------------------------------------------------------------------------
;	Ascii constants
;
NUL	=	$00
BEL	=	$07
BS	=	$08
HT	=	$09
LF	=	$0A
VT	=	$0B
FF	=	$0C
CR	=	$0D
ESC	=	$1B
;----------------------------------------------------------------------------
;	Diverse constants
;
NULL		=	0
maxsbyte	=	$7F
maxubyte	=	$FF
maxsword	=	$7FFF
maxuword	=	$FFFF
maxslong	=	$7FFFFFFF
maxulong	=	$FFFFFFFF
;
Kd		=	1000
Md		=	Kd*Kd
Kb		=	1024
Mb		=	Kb*Kb
;
_ind	= 1<<30	;bit 30 is indirection flag for some macro libraries
_IND	= 1<<30	;bit 30 is indirection flag for some macro libraries
;----------------------------------------------------------------------------
;	System init vectors
;
ssp_init	=	$000
ev_reset	=	$004
;----------------------------------------------------------------------------
;	System exception vectors
;
ev_buserr	=	$008		;bus error
ev_adrerr	=	$00C		;address error
ev_illegal	=	$010		;illegal instruction
ev_divby0	=	$014		;divide by zero
ev_chk_ofl	=	$018		;CHK overflow
ev_trapv	=	$01C		;TRAPV for 68000
ev_trapcc	=	ev_trapv	;TRAPcc for68020/68030/etc.
ev_ftrapcc	=	ev_trapv	;FTRAPcc for FPU
ev_priverr	=	$020
ev_trace	=	$024
ev_a_line	=	$028
ev_f_line	=	$02C
;
ev_cp_protvio	=	$34		;coprocessor protocol violation
;
; vectors at $030..$03B are unassigned
; vector at $3C is dubiously specified, but can not be considered free
; vectors at $040..$05F are unassigned
;
ev_spurerr	=	$060
ev_level1	=	$064
ev_level2	=	$068
ev_level3	=	$06C
ev_level4	=	$070
ev_level5	=	$074
ev_level6	=	$078
ev_level7	=	$07C
; the odd vectors above are unavailable since IPL0 is tied high
ev_HBI		=	ev_level2
ev_VBI		=	ev_level4
ev_SCC		=	ev_level5
ev_MFP		=	ev_level6
;
ev_trap0	=	$080
ev_trap1	=	$084
ev_trap2	=	$088
ev_trap3	=	$08C
ev_trap4	=	$090
ev_trap5	=	$094
ev_trap6	=	$098
ev_trap7	=	$09C
ev_trap8	=	$0A0
ev_trap9	=	$0A4
ev_trap10	=	$0A8
ev_trap11	=	$0AC
ev_trap12	=	$0B0
ev_trap13	=	$0B4
ev_trap14	=	$0B8
ev_trap15	=	$0BC
;
ev_gemdos	=	ev_trap1
ev_xgemdos	=	ev_trap2
ev_xgem		=	ev_xgemdos
ev_bios		=	ev_trap13
ev_xbios	=	ev_trap14
;-------
ev_fpu_bsun	=	$0c0
ev_fpu_inexact	=	$0c4
ev_fpu_divby0	=	$0c8
ev_fpu_ufl	=	$0cc
ev_fpu_opererr	=	$0d0
ev_fpu_ofl	=	$0d4
ev_fpu_snan	=	$0d8
ev_fpu_undtype	=	$0dc		;only for 68040/60
;----------------------------------------------------------------------------
; vectors at $0E0..$0FF are unassigned
;----------------------------------------------------------------------------
; 	interrupt vectors for MFP interrupts
;
iv_cenbusy	=	$100 ;Centronics interface busy
iv_v24dcd	=	$104
iv_v24cts	=	$108
iv_blitter	=	$10C
iv_time_d	=	$110 ;Modem 1 baudrate timer
iv_time_c	=	$114 ;system timer, 200Hz
iv_kb_midi	=	$118 ;keyboard & midi are together since both use ACIA's
iv_disk		=	$11C ;floppy or hard disk
iv_time_b	=	$120 ;HBI counter/timer (often borrowed for sound samples)
iv_v24terr	=	$124
iv_v24treq	=	$128
iv_v24rerr	=	$12C
iv_v24rreq	=	$130
iv_time_a	=	$134 ;user timer (often borrowed by MOD players)
iv_v24ring	=	$138
iv_monodet	=	$13C ;Monochrome monitor detection
;
; alternative definitions for Falcon
;
iv_cenack	=	iv_v24dcd	;new centronics ACK signal
iv_midi		=	iv_v24cts	;new separate midi interrupt
iv_dsp		=	iv_blitter
iv_sample	=	iv_monodet
;
; new general purpose definitions
;
iv_M1_busy	=	$100
iv_M1_dcd_ack	=	$104
iv_M1_cts_midi	=	$108
iv_M1_blit_dsp	=	$10C
iv_M1_time_d	=	$110
iv_M1_time_c	=	$114
iv_M1_kb_midi	=	$118
iv_M1_disk	=	$11C
iv_M1_time_b	=	$120
iv_M1_terr	=	$124
iv_M1_treq	=	$128
iv_M1_rerr	=	$12C
iv_M1_rreq	=	$130
iv_M1_time_a	=	$134
iv_M1_ring	=	$138
iv_M1_mono_samp	=	$13C
;----------------------------------------------------------------------------
; 	interrupt vectors for secondary MFP interrupts
;
iv_M2_0		=	$140
iv_M2_1		=	$144
iv_M2_2		=	$148
iv_M2_3		=	$14C
iv_M2_4		=	$150
iv_M2_5		=	$154
iv_M2_6		=	$158
iv_M2_7		=	$15C
iv_M2_8		=	$160
iv_M2_9		=	$164
iv_M2_10	=	$168
iv_M2_11	=	$16C
iv_M2_12	=	$170
iv_M2_13	=	$174
iv_M2_14	=	$178
iv_M2_15	=	$17C
;----------------------------------------------------------------------------
; 	interrupt vectors for SCC interrupts
;
iv_SCC_0	=	$180
iv_SCC_1	=	$184
iv_SCC_2	=	$188
iv_SCC_3	=	$18C
iv_SCC_4	=	$190
iv_SCC_5	=	$194
iv_SCC_6	=	$198
iv_SCC_7	=	$19C
iv_SCC_8	=	$1A0
iv_SCC_9	=	$1A4
iv_SCC_10	=	$1A8
iv_SCC_11	=	$1AC
iv_SCC_12	=	$1B0
iv_SCC_13	=	$1B4
iv_SCC_14	=	$1B8
iv_SCC_15	=	$1BC
;----------------------------------------------------------------------------
; vectors at $1C0..$1FF are unassigned
; vectors at $200..$37F are reserved for OEM products
;----------------------------------------------------------------------------
; 	System bomb info for debug analysis
;
bombflag	= $380 ;flag = $12345678 when bomb info is valid
bomb_d0		= $384
bomb_d1		= $388
bomb_d2		= $38C
bomb_d3		= $390
bomb_d4		= $394
bomb_d5		= $398
bomb_d6		= $39C
bomb_d7		= $3A0
bomb_a0		= $3A4
bomb_a1		= $3A8
bomb_a2		= $3AC
bomb_a3		= $3B0
bomb_a4		= $3B4
bomb_a5		= $3B8
bomb_a6		= $3BC
bomb_a7		= $3C0
bombvector	= $3C4
bomb_usp	= $3C8
bomb_ssp	= bomb_a7
bombstack	= $3CC ;16W copy of the bomb_time stack top
;
;alternative definitions
;
proc_lives	= bombflag
proc_dregs	= bomb_d0
proc_aregs	= bomb_a0
proc_enum	= bombvector
proc_usp	= bomb_usp
proc_stk	= bombstack
;
; vector area at $3EC..$3FF is unassigned, but known to be used by
; some system support programs for non_vector purposes (eg. timesave)
;
;
;----------------------------------------------------------------------------
; 	System variables
;
etv_timer	=	$400	;.L -> div support code, called by system timing
etv_critic	=	$404	;.L -> BIOS error handler
etv_term	=	$408	;.L -> RTS or application termination code
etv_extra	=	$40C	;5.L
memvalid	=	$420	;.L == $752019F3 when 'memctrl' valid
memctrl		=	$424	;.W == ST/STE MMU code (hw_mapper) ib high byte
resvalid	=	$426	;.L == $31415926 when 'resvector' valid
resvector	=	$42A	;.L -> extra reset routine(s)
phystop		=	$42E	;.L -> end of RAM accessible to system
_membot		=	$432	;.L -> current start of free ram
_memtop		=	$436	;.L -> current end of free ram
memval2		=	$43A	;.L == $237698AA when the 3 above are valid
flock		=	$43E	;.W flag non_zero to shorten VBI work (for disk op's)
seekrate	=	$440	;.W = 0, 1, 2, 3 for 6, 12, 2, 3 ms
_timr_ms	=	$442	;.W = VBI timer interval in ms (norm 20)
_fverify	=	$444	;.W flag non_zero to verify disk writes (norm)
_bootdev	=	$446	;.W boot drive id number (norm 0=a:, or 2=c:)
_palmode	=	$448	;.W flag non_zero for 50Hz PAL (norm) else 60Hz NTSC
defshiftmd	=	$44A	;.B 0=ST_L 1=ST_M as future rez when leaving mono mode
sshiftmd	=	$44C	;.B current rez: 0=ST_L 1=ST_M 2=ST_H 4=TT_M 6=TT_H 7=TT_L
_v_bas_ad	=	$44E	;.L -> video screen (same as XBIOS Logbase)
_v_bas_2	=	$44F
_v_bas_1	=	$450
_v_bas_0	=	$451
vblsem		=	$452	;.W flag zero to disable most VBI work (not "_frclock")
nvbls		=	$454	;.W entry limit for _vblqueue (norm 8)
_vblqueue	=	$456	;.L -> list of vbl driven subroutines
colorptr	=	$45A	;.L NULL except when -> palette data for next VBI
screenpt	=	$45E	;.L NULL except when -> screena address for next VBI
_vbclock	=	$462	;.L counts VBIs when vblsem is non-zero
_frclock	=	$466	;.L counts all VBIs
hdv_init	=	$46A	;.L -> code for hard disk init
swv_vec		=	$46E	;.L -> monitor type change code (norm=reset vector)
hdv_bpb		=	$472	;.L -> code for BIOS Getbpb
hdv_rw		=	$476	;.L -> code for BIOS Rwabs
hdv_boot	=	$47A	;.L -> code for booting (?)
hdv_mediach	=	$47E	;.L -> code for BIOS Mediach
_cmdload	=	$482	;.W flag non_zero to load COMMAND.PRG after OS (obsolete method)
conterm		=	$484	;.B kb_attr b0=click b1=rpt b2=bell b3=Keycodes incl Kbshift (abnormal)
trp14ret	=	$486	;.L NULL except when -> ret adr for XBIOS functions
criticret	=	$48A	;.L NULL except when -> ret adr for etv_critic functions
themd		=	$48E	;4L MPB for BIOS Getmpb
_md		=	$49E	;2W reserved for memory descriptor work
savptr		=	$4A2	;.L -> pseudostack for TOS function dispatchers
_nflops		=	$4A6	;.W number of floppy drives attached (0..3)
constate	=	$4A8	;.L -> BIOS Bconout code for unit 2
save_row	=	$4AC	;.W cursor row temp for console handler
sav_contxt	=	$4AE	;.L NULL except when -> psudostack for exception handlers
_bufl		=	$4B2	;2L -> cache lists (BCBs) for data and dirs/FATs
_bufl_2		=	$4B6
_hz_200		=	$4BA	;.L counts all system interrupts (timer C, 200 Hz)
the_env		=	$4BE	;.L NULL except when -> special environment (abnormal)
_drvbits	=	$4C2	;.L bitmap for all GEMDOS drives (similar to BIOS Drvmap)
_dskbufp	=	$4C6	;.L -> 1K buffer for disk & graphic data used by TOS
_autopath	=	$4CA	;.L NULL except when -> auto exec path string (abnormal)
_vbl_list	=	$4CE	;8L NULL or -> VBL subroutines (some are always in use)
_prt_cnt	=	$4EE	;.W flag for screen dump (norm == $FFFF)
_prtabt		=	$4F0	;.W flag for screen dump termination (norm == 0)
_sysbase	=	$4F2	;.L -> TOS header (normally a copy of it, in RAM)
_shell_p	=	$4F6	;.L NULL except when -> special shell info
end_os		=	$4FA	;.L -> RAM end of TOS variables (norm same as _membot)
exec_os		=	$4FE	;.L -> code for desktop (re)init (bootup or rez change)
scr_dump	=	$502	;\
prv_lsto	=	$506	; \
prv_lst		=	$50A	;  \/ Diverse pointers for
prv_auxo	=	$50E	;  /\ printer operation
prv_aux		=	$512	; /
pun_ptr		=	$516	;/
memval3		=	$51A	;.L == $5555AAAA when ST RAM settings valid
dev_vecs	=	$51E	;8L per device per I/O function 
xconstat	=	$51E	;8L -> Bconstat of 8 devices
xconin		=	$53E	;8L -> Bconin of 8 devices
xcostat		=	$55E	;8L -> Bcostat of 8 devices
xconout		=	$57E	;8L -> Bconout of 8 devices
_longframe	=	$59E	;.W 0==68000_frame  non-zero==68020_frame (or later CPU frame)
_cookies	=	$5A0	;.L -> cookie jar (unless NULL, with old TOS versions)
ramtop		=	$5A4	;.L -> end of Alternate RAM (aka: Fast-RAM)
ramvalid	=	$5A8	;.L == $1357BD13 when 'ramtop' is valid
bell_hook	=	$5AC
kcl_hook	=	$5B0
;
TT_ramtop	=	ramtop
TT_ramvalid	=	ramvalid
;----------------------------------------------------------------------------
;	System vector numbers
;-------------------------------------
;		;vector $00 does not exist (SSP value for reset)
;-------------------------------------
evn_reset	=	$01
evn_buserr	=	$02
evn_adrerr	=	$03
evn_illegal	=	$04
evn_divby0	=	$05
evn_chk_ofl	=	$06
evn_trapv	=	$07
evn_priverr	=	$08
evn_trace	=	$09
evn_a_line	=	$0a
evn_f_line	=	$0b
;-------------------------------------
;		;vectors $0C..$0E are unassigned
;		;vector $0F is dubiously specified, but is not free
;		;vectors $10..$17 are unassigned
;-------------------------------------
evn_spurerr	=	$18
evn_level1	=	$19
evn_level2	=	$1a
evn_level3	=	$1b
evn_level4	=	$1c
evn_level5	=	$1d
evn_level6	=	$1e
evn_level7	=	$1f
; 		;odd vectors above are unavailable with IPL0 tied high
;-------------------------------------
evn_HBI		=	evn_level2
evn_VBI		=	evn_level4
evn_MFP		=	evn_level6
;-------------------------------------
evn_trap0	=	$20
evn_trap1	=	$21
evn_trap2	=	$22
evn_trap3	=	$23
evn_trap4	=	$24
evn_trap5	=	$25
evn_trap6	=	$26
evn_trap7	=	$27
evn_trap8	=	$28
evn_trap9	=	$29
evn_trap10	=	$2a
evn_trap11	=	$2b
evn_trap12	=	$2c
evn_trap13	=	$2d
evn_trap14	=	$2e
evn_trap15	=	$2f
;-------------------------------------
evn_gemdos	=	evn_trap1
evn_xgemdos	=	evn_trap2
evn_xgem	=	evn_trap2
evn_bios	=	evn_trap13
evn_xbios	=	evn_trap14
;-------------------------------------
;		;vectors $30..$3F are unassigned
;-------------------------------------
; 	MFP interrupt vector numbers
;-------------------------------------
ivn_cenbusy	=	$40
ivn_v24dcd	=	$41
ivn_v24cts	=	$42
ivn_blitter	=	$43
ivn_time_d	=	$44
ivn_time_c	=	$45
ivn_kb_midi	=	$46
ivn_disk	=	$47
ivn_time_b	=	$48
ivn_v24terr	=	$49
ivn_v24treq	=	$4a
ivn_v24rerr	=	$4b
ivn_v24rreq	=	$4c
ivn_time_a	=	$4d
ivn_v24ring	=	$4e
ivn_monodet	=	$4f
;-------------------------------------
;		;vectors $50..$7F are unassigned
;		;vectors $80..$DF are reserved for OEM products
;		;vectors $E0..$FA do not exist (bomb info area)
;		;vectors $FB..$FF may not exist (unassigned but often used!)
;-------------------------------------
; 	System variable vector numbers
;-------------------------------------
etvn_timer	=	$100
etvn_critic	=	$101
etvn_term	=	$102
;----------------------------------------------------------------------------
;	OS header offsets
;
os_codebra	= $00	;w $60xx
os_version	= $02	;w $0v0r
os_reset_p	= $04	;L
os_selfbeg_p	= $08	;L
os_varend_p	= $0c	;L
os_unknown_p	= $10	;L
os_gem_mpb_p	= $14	;L
os_date_bcd	= $18	;L
os_config	= $1c	;w
os_date_gem	= $1e	;w
;	next follows the part valid only for TOS 1.02 & later
os_pool_p	= $20
os_kbshift_p	= $24
os_currbp_p_p	= $28
os_run_p_p	= os_currbp_p_p
os_reserved	= $2c
;
TOS_100_kbshift	= $E1B
TOS_100_currbp_p= $602C
;-------------------------------------
;	Cartridge ROM definitions
;
rom_diag_id	= $fa52255f
rom_appl_id	= $abcdef42
rom_base	= $fa0000
rom_head	= $fa0004
;
rh_diagcode	= 0
rh_applnext_p	= 0
rh_applinit_p	= 4
rh_applcode_p	= 8
rh_appltime	= 12
rh_appldate	= 14
rh_applsize	= 16
rh_applname	= 20	;<=13b incl terminal NUL
;-------------------------------------
;	IOREC data structure
;
io_sel_serial	= 0
io_sel_keyboard	= 1
io_sel_midi	= 2
;
io_buffer_p	=  0	;L-> data buffer (NB: kbd uses 4 bytes/char)
io_size_ix	=  4	;w = total size of buffer, in bytes
io_head_ix	=  6	;w = indexes position of next write
io_tail_ix	=  8	;w = indexes position of next read
io_lo_fill	= 10	;w = flow reactivation limit
io_hi_fill	= 12	;w = flow deactivation limit
;
Rx_buffer_p	= $00
Rx_size_ix	= $04
Rx_head_ix	= $06
Rx_tail_ix	= $08
Rx_lo_fill	= $0A
Rx_hi_fill	= $0C
Tx_buffer_p	= $0E
Tx_size_ix	= $12
Tx_head_ix	= $14
Tx_tail_ix	= $16
Tx_lo_fill	= $18
Tx_hi_fill	= $1A
;
Io_shadow_0	= $1C	;.b HSM shadow for hardware register
Io_shadow_1	= $1D	;.b HSM shadow for hardware register
Rx_locked_f	= $1E	;.b HSM flag clr/set at sending Xon/Xoff
Tx_locked_f	= $1F	;.b HSM flag clr/set at received Xon/Xoff
Io_flow_ctr	= $20	;.b HSM flow control
Tx_softnext	= $21	;.b HSM extra buffer for Xon/Xoff (sent if NE)
Io_baudcode	= $22	;.b HSM baudrate code
Io_baudrate	= $24	;.l HSM baudrate value
;-------------------------------------
;	KBDVBASE data structure
;
kv_midi_input	= $00
kv_keybrd_err	= $04
kv_midi_err	= $08
kv_ikbd_stat	= $0C
kv_mouse_pack	= $10
kv_clock_pack	= $14
kv_joyst_pack	= $18
kv_midi_vec	= $1C
kv_ikbd_vec	= $20
;-------------------------------------
;	Virtual Screen cookie structure
;
vs_vs_magic	= $00	;l = 'VSCR' when screen driver is _active_ !!!
vs_driver_magic = $04	;l = XBRA/Cookie id of screen driver
vs_version	= $08	;w = version of VSCR protocol (for future exp)
vs_x		= $0A	;w = left edge \
vs_y		= $0C	;w = top edge   \/ of visible
vs_w		= $0E	;w = width      /\ rectangle
vs_h		= $10	;w = height    /
vs_size		= $12	;size of virtual screen structure
vs_rect		= vs_x
;-------------------------------------
;	structure for long jumps (etc)
;
LongJump	= $00
LongJump_op	= $00
LongJump_ad	= $02
sizeof_LongJump	= $06
LongJump_opcode	= $4EF9
;-------------------------------------
;	Font header offsets
;
;NB: Intel format is used in all words and longs, when fnt_flag bit 2 is zero.
;NB: Test this as 68000 word, however, for the first byte contains that flag
;NB: in Intel mode only, with the second byte zeroed so 68000 test will work.
;NB: In 68000 mode the first byte is always zero, so Intel test would fail.
;
fnt_id		= $00	;w 
fnt_pts		= $02	;w
fnt_name	= $04	;32b
fnt_lasc	= $24	;w
fnt_hasc	= $26	;w
fnt_dtop	= $28	;w
fnt_dasce	= $2A	;w
fnt_dhalf	= $2C	;w
fnt_ddesc	= $2E	;w
fnt_dbott	= $30	;w
fnt_charw	= $32	;w
fnt_cellw	= $34	;w
fnt_loff	= $36	;w
fnt_roff	= $38	;w
fnt_weight	= $3A	;w
fnt_ulheight	= $3C	;w
fnt_litemask	= $3E	;w
fnt_skewmask	= $40	;w
fnt_flag	= $42	;w
fnt_hor_tp	= $44	;l->horiz. offset table, or = fnt_chr_tp
fnt_chr_tp	= $48	;l->char. offset table, in files use $58 (fnt_next+4)
fnt_fbase	= $4C	;l->
fnt_fwidth	= $50	;w
fnt_fheight	= $52	;w
fnt_next	= $54	;l->next font in chain
;
;
;----------------------------------------------------------------------------
; 	fpu offsets (68881 or 68882)
;
fpu_base	=	$00
fpu_stat	=	$00	;W Rd
fpu_cont	=	$02	;W Wr
fpu_save	=	$04	;W Rd
fpu_rest	=	$06	;W R/W
fpu_comm	=	$0A	;W Wr
fpu_cond	=	$0E	;W Wr
fpu_oper	=	$10	;L R/W
fpu_rsel	=	$14	;W Rd
fpu_iadr	=	$18	;L Wr
fpu_opad	=	$1C	;L R/W (dummy in 68881 and 68882)
;
;
;----------------------------------------------------------------------------
; 	System hardware
;
hw_mapper	=	$ffff8001	;.B 4b ST/STE memory mapper
;
hw_F_mon_mem	=	$ffff8006	;b7.6 3-0==TV,VGA,PAL,SM  b5.4 3-0==na,16M,4M,1M
hw_F_comp_div	=	$ffff8007
;
F_comp_cpu_b	= 0			;1 => 16 MHz   0 => 8 MHz   CPU
F_comp_cpu_v	= 1<<0
F_comp_blit_b	= 2			;1 => 16 MHz   0 => 8 MHz   Blitter
F_comp_blit_v	= 1<<2
F_comp_bus_b	= 5			;1 => Falcon   0 => STE     Bus
F_comp_bus_v  = 1<<5
F_div_mon_b	= 6			;1 => On       0 => Off     Screen
F_div_mon_v	= 1<<6
;
hw_vbase2	=	$ffff8201	;.B video base MSB byte
hw_vbase1	=	$ffff8203	;.B video base mid byte
hw_vpos2	=	$ffff8205	;.B video pos MSB byte
hw_vpos1	=	$ffff8207	;.B video pos mid byte
hw_vpos0	=	$ffff8209	;.B video pos LSB byte
hw_syn		=	$ffff820A	;.B 2b RW b0=disable sync o/p's  b1=50Hz mode (b1 ignored on TT)
l_hw_syn	=	$00ff820A	;like hw_syn (by silly compilers :-)
;
hw_vbase0	=	$ffff820D	;video base LSB, non-ST only (STE/TT/Falcon)
hw_horextH	=	$ffff820E	;STE only (so never use it!)
hw_horext	=	$ffff820F	;STE only (so never use it!)
;
hw_vbase2_w	=	$ffff8200	;\
hw_vbase1_w	=	$ffff8202	; \
hw_vpos2_w	=	$ffff8204	;  \/ word access addresses
hw_vpos1_w	=	$ffff8206	;  /\ for some of above bytes
hw_vpos0_w	=	$ffff8208	; /
hw_vbase0_w	=	$ffff820C	;/
;
hw_pal		=	$ffff8240	;base address of ST palette
hw_pal_00	=	hw_pal+00
hw_pal_01	=	hw_pal+02
hw_pal_02	=	hw_pal+04
hw_pal_03	=	hw_pal+06
hw_pal_04	=	hw_pal+08
hw_pal_05	=	hw_pal+10
hw_pal_06	=	hw_pal+12
hw_pal_07	=	hw_pal+14
hw_pal_08	=	hw_pal+16
hw_pal_09	=	hw_pal+18
hw_pal_10	=	hw_pal+20
hw_pal_11	=	hw_pal+22
hw_pal_12	=	hw_pal+24
hw_pal_13	=	hw_pal+26
hw_pal_14	=	hw_pal+28
hw_pal_15	=	hw_pal+30
;
hw_rez		=	$ffff8260	;.B 2b RW 0=ST_L 1=ST_M 2=ST_H video rez
;note that hw_rez has 3 bits on a TT, with 4=TT_M 6=TT_H 7=TT_L
;
hw_rez_tt	=	$ffff8262	.W s--h-mmm.----bbbb s=sample_hold h=hyper_mono mmm=rez bbbb=ST palette bank
;
hw_ste_pixoffH	=	$ffff8264	;STE only (so never use it!)
hw_ste_pixoff	=	$ffff8265	;STE only (so never use it!)
;
hw_pal_tt:	=	$ffff8400	;base address of TT palette
;
hw_dmadata	=	$ffff8604	;.W 8b RW
hw_dmascnt	=	$ffff8604	;.W 8b RW
hw_dma_da_ct	=	$ffff8604
hw_dmastat	=	$ffff8606	;.W 3b RO
hw_dmacont	=	$ffff8606	;.W 9b WO
hw_dmamode	=	$ffff8606	;.W 9b WO
hw_dma_mode	=	$ffff8606
dma_srcmd	= $080
dma_srtrk	= $082
dma_srsec	= $084
dma_srdat	= $086
dma_srcnt	= $090
dma_wr_bit	= $100
dma_swcmd	= $180
dma_swtrk	= $182
dma_swsec	= $184
dma_swdat	= $186
dma_swcnt	= $190
hw_dmabase2	=	$ffff8609	;MSB
hw_dmabase1	=	$ffff860B
hw_dmabase0	=	$ffff860D	;LSB
hw_dma_base2	=	$ffff8609	;MSB
hw_dma_base1	=	$ffff860B
hw_dma_base0	=	$ffff860D	;LSB
;
hw_TT_scsi_dma3	=	$ffff8701	;MSB
hw_TT_scsi_dma2	=	$ffff8703
hw_TT_scsi_dma1	=	$ffff8705
hw_TT_scsi_dma0	=	$ffff8707	;LSB
hw_TT_scsi_cnt3	=	$ffff8709	;MSB
hw_TT_scsi_cnt2	=	$ffff870B
hw_TT_scsi_cnt1	=	$ffff870D
hw_TT_scsi_cnt0	=	$ffff870F	;LSB
hw_TT_scsi_drr	=	$ffff8710	;Long
hw_TT_scsi_cr	=	$ffff8715	;Byte
;
hw_scsi_data	=	$ffff8781
hw_scsi_icr	=	$ffff8783
hw_scsi_mode	=	$ffff8785
hw_scsi_tcr	=	$ffff8787
hw_scsi_idcr	=	$ffff8789
hw_scsi_stsr	=	$ffff878B
hw_scsi_trid	=	$ffff878D
hw_scsi_irrs	=	$ffff878F
;
hw_giselect	=	$ffff8800	;.B 4b WO
hw_psgsel	=	$ffff8800	;.B 4b WO
hw_psgrd	=	$ffff8800	;.B 8b RO
hw_psg_rd_sel	=	$ffff8800
l_hw_psg_rd_sel	=	$00ff8800
hw_giwrite	=	$ffff8802	;.B 8b WO
hw_psgwr	=	$ffff8802	;.B 8b WO
hw_psg_wr	=	$ffff8802
l_hw_psg_wr	=	$00ff8802
;
hw_sdma_cont_w	=	$ffff8900	;STE+
hw_sdma_cont	=	$ffff8901	;STE+
hw_sdma_beg2	=	$ffff8903	;STE+
hw_sdma_beg1	=	$ffff8905	;STE+
hw_sdma_beg0	=	$ffff8907	;STE+
hw_sdma_loop2	=	$ffff8909	;STE+
hw_sdma_loop1	=	$ffff890B	;STE+
hw_sdma_loop0	=	$ffff890D	;STE+
hw_sdma_end2	=	$ffff890F	;STE+
hw_sdma_end1	=	$ffff8911	;STE+
hw_sdma_end0	=	$ffff8913	;STE+
;
hw_F_dac_trk	=	$ffff8920	;F30
hw_sdma_mode	=	$ffff8921	;STE/TT/F30
;
hw_MW_data	=	$ffff8922	;STE/TT 16 bits
hw_MW_mask	=	$ffff8924	;STE/TT 16 bits
;
hw_F_xbar_sc	=	$ffff8930	;.W
hw_F_xbar_dc	=	$ffff8932	;.W
;		=	$ffff8935	;.B frequency
;		=	$ffff8937	;.B matrix
;
hw_TT_rtc_ar_w	=	$ffff8960	;.W
hw_TT_rtc_ar	=	$ffff8961	;.B
hw_TT_rtc_dr_w	=	$ffff8962	;.W
hw_TT_rtc_dr	=	$ffff8963	;.B
;
hw_BLIT_htone	=	$ffff8A00
;
hw_scc_dma3	=	$ffff8C01
hw_scc_dma2	=	$ffff8C03
hw_scc_dma1	=	$ffff8C05
hw_scc_dma0	=	$ffff8C07
hw_scc_cnt3	=	$ffff8C09
hw_scc_cnt2	=	$ffff8C0B
hw_scc_cnt1	=	$ffff8C0D
hw_scc_cnt0	=	$ffff8C0F
hw_scc_drr	=	$ffff8C10	;.L
hw_scc_cr_w	=	$ffff8C14
hw_scc_cr	=	$ffff8C15
;
hw_SCC_a_cr	=	$ffff8C81
hw_SCC_a_dr	=	$ffff8C83
hw_SCC_b_cr	=	$ffff8C85
hw_SCC_b_dr	=	$ffff8C87
;
hw_TT_sys_im	=	$ffff8E01
hw_TT_sys_is	=	$ffff8E03
hw_TT_sys_ig	=	$ffff8E05
hw_TT_vme_ig	=	$ffff8E07
hw_TT_scu_gpr1	=	$ffff8E09
hw_TT_scu_gpr2	=	$ffff8E0B
hw_TT_vme_im	=	$ffff8E0D
hw_TT_vme_is	=	$ffff8E0F
;
hw_switches	=	$ffff9200	;F30
hw_pad_fire	=	$ffff9201	;F30+STE 4 bits
hw_pad_direct	=	$ffff9202	;F30+STE 4*4bits
;
hw_pad_0_y	=	$ffff9211	;F30+STE
hw_pad_0_x	=	$ffff9213	;F30+STE
hw_pad_1_y	=	$ffff9215	;F30+STE
hw_pad_1_x	=	$ffff9217	;F30+STE
;
hw_light_x	=	$ffff9220	;F30+STE
hw_light_y	=	$ffff9222	;F30+STE
;
hw_F_pal	=	$ffff9800	;F30
;
hw_dsp_ic	=	$ffffa200	;F30
hw_dsp_cv	=	$ffffa201	;F30
hw_dsp_is	=	$ffffa202	;F30 DSP interface status
hw_dsp_iv	=	$ffffa203	;F30
;
hw_dsp_long	=	$ffffa204	;F30	top byte is ignored
hw_dsp_d2	=	$ffffa205	;F30
hw_dsp_d1	=	$ffffa206	;F30
hw_dsp_d0	=	$ffffa207	;F30
;
Tx_DSP_wait	MACRO
.Tx_delay_\@:				;loop start awaiting Tx permission
	btst.b	#1,(hw_dsp_is).w
	beq.s	.Tx_delay_\@		;loop back until data reg empty
	ENDM
;
Rx_DSP_wait	MACRO
.Rx_delay_\@:				;loop start awaiting data
	btst.b	#0,(hw_dsp_is).w
	beq.s	.Rx_delay_\@		;loop back until data here
	ENDM
;
hw_mfp		=	$ffffFA01
hw_gpip		=	$ffffFA01
hw_aer		=	$ffffFA03
hw_ddr		=	$ffffFA05
hw_iera		=	$ffffFA07
hw_ierb		=	$ffffFA09
hw_ipra		=	$ffffFA0B
hw_iprb		=	$ffffFA0D
hw_isra		=	$ffffFA0F
hw_isrb		=	$ffffFA11
hw_imra		=	$ffffFA13
hw_imrb		=	$ffffFA15
hw_vr		=	$ffffFA17
hw_tacr		=	$ffffFA19
hw_tbcr		=	$ffffFA1B
hw_tcdcr	=	$ffffFA1D
hw_tadr		=	$ffffFA1F
hw_tbdr		=	$ffffFA21
hw_tcdr		=	$ffffFA23
hw_tddr		=	$ffffFA25
hw_scr		=	$ffffFA27
hw_ucr		=	$ffffFA29
hw_rsr		=	$ffffFA2B
hw_tsr		=	$ffffFA2D
hw_udr		=	$ffffFA2F
;
;new alternative definitions for the above
;
hw_M1_gpip	=	$ffffFA01
hw_M1_aer	=	$ffffFA03
hw_M1_ddr	=	$ffffFA05
hw_M1_iera_w	=	$ffffFA06
hw_M1_iera	=	$ffffFA07
hw_M1_ierb_w	=	$ffffFA08
hw_M1_ierb	=	$ffffFA09
hw_M1_ipra_w	=	$ffffFA0A
hw_M1_ipra	=	$ffffFA0B
hw_M1_iprb_w	=	$ffffFA0C
hw_M1_iprb	=	$ffffFA0D
hw_M1_isra_w	=	$ffffFA0E
hw_M1_isra	=	$ffffFA0F
hw_M1_isrb_w	=	$ffffFA10
hw_M1_isrb	=	$ffffFA11
hw_M1_imra_w	=	$ffffFA12
hw_M1_imra	=	$ffffFA13
hw_M1_imrb_w	=	$ffffFA14
hw_M1_imrb	=	$ffffFA15
hw_M1_vr	=	$ffffFA17
hw_M1_tacr	=	$ffffFA19
hw_M1_tbcr	=	$ffffFA1B
hw_M1_tcdcr	=	$ffffFA1D
hw_M1_tadr	=	$ffffFA1F
hw_M1_tbdr	=	$ffffFA21
hw_M1_tcdr	=	$ffffFA23
hw_M1_tddr	=	$ffffFA25
hw_M1_scr	=	$ffffFA27
hw_M1_ucr	=	$ffffFA29
hw_M1_rsr	=	$ffffFA2B
hw_M1_tsr	=	$ffffFA2D
hw_M1_udr	=	$ffffFA2F
;
;'silly compiler' alternatives for the above
;
l_hw_M1_gpip	=	$00ffFA01
l_hw_M1_aer	=	$00ffFA03
l_hw_M1_ddr	=	$00ffFA05
l_hw_M1_iera_w	=	$00ffFA06
l_hw_M1_iera	=	$00ffFA07
l_hw_M1_ierb_w	=	$00ffFA08
l_hw_M1_ierb	=	$00ffFA09
l_hw_M1_ipra_w	=	$00ffFA0A
l_hw_M1_ipra	=	$00ffFA0B
l_hw_M1_iprb_w	=	$00ffFA0C
l_hw_M1_iprb	=	$00ffFA0D
l_hw_M1_isra_w	=	$00ffFA0E
l_hw_M1_isra	=	$00ffFA0F
l_hw_M1_isrb_w	=	$00ffFA10
l_hw_M1_isrb	=	$00ffFA11
l_hw_M1_imra_w	=	$00ffFA12
l_hw_M1_imra	=	$00ffFA13
l_hw_M1_imrb_w	=	$00ffFA14
l_hw_M1_imrb	=	$00ffFA15
l_hw_M1_vr	=	$00ffFA17
l_hw_M1_tacr	=	$00ffFA19
l_hw_M1_tbcr	=	$00ffFA1B
l_hw_M1_tcdcr	=	$00ffFA1D
l_hw_M1_tadr	=	$00ffFA1F
l_hw_M1_tbdr	=	$00ffFA21
l_hw_M1_tcdr	=	$00ffFA23
l_hw_M1_tddr	=	$00ffFA25
l_hw_M1_scr	=	$00ffFA27
l_hw_M1_ucr	=	$00ffFA29
l_hw_M1_rsr	=	$00ffFA2B
l_hw_M1_tsr	=	$00ffFA2D
l_hw_M1_udr	=	$00ffFA2F
;
hw_fpu_base	=	$ffffFA40	;SFP-004 with 68881 or 68882
hw_fpu_stat	=	$ffffFA40	;W Rd
hw_fpu_cont	=	$ffffFA42	;W Wr
hw_fpu_save	=	$ffffFA44	;W Rd
hw_fpu_rest	=	$ffffFA46	;W R/W
hw_fpu_comm	=	$ffffFA4A	;W Wr
hw_fpu_cond	=	$ffffFA4E	;W Wr
hw_fpu_oper	=	$ffffFA50	;L R/W
hw_fpu_rsel	=	$ffffFA54	;W Rd
hw_fpu_iadr	=	$ffffFA58	;L Wr
hw_fpu_opad	=	$ffffFA5C	;L R/W (dummy in 68881 and 68882)
;
hw_M2_gpip	=	$ffffFA81
hw_M2_aer	=	$ffffFA83
hw_M2_ddr	=	$ffffFA85
hw_M2_iera_w	=	$ffffFA86
hw_M2_iera	=	$ffffFA87
hw_M2_ierb_w	=	$ffffFA88
hw_M2_ierb	=	$ffffFA89
hw_M2_ipra_w	=	$ffffFA8A
hw_M2_ipra	=	$ffffFA8B
hw_M2_iprb_w	=	$ffffFA8C
hw_M2_iprb	=	$ffffFA8D
hw_M2_isra_w	=	$ffffFA8E
hw_M2_isra	=	$ffffFA8F
hw_M2_isrb_w	=	$ffffFA90
hw_M2_isrb	=	$ffffFA91
hw_M2_imra_w	=	$ffffFA92
hw_M2_imra	=	$ffffFA93
hw_M2_imrb_w	=	$ffffFA94
hw_M2_imrb	=	$ffffFA95
hw_M2_vr	=	$ffffFA97
hw_M2_tacr	=	$ffffFA99
hw_M2_tbcr	=	$ffffFA9B
hw_M2_tcdcr	=	$ffffFA9D
hw_M2_tadr	=	$ffffFA9F
hw_M2_tbdr	=	$ffffFAA1
hw_M2_tcdr	=	$ffffFAA3
hw_M2_tddr	=	$ffffFAA5
hw_M2_scr	=	$ffffFAA7
hw_M2_ucr	=	$ffffFAA9
hw_M2_rsr	=	$ffffFAAB
hw_M2_tsr	=	$ffffFAAD
hw_M2_udr	=	$ffffFAAF
;
;NB: use expressions like hw_tacr+(hw_mfp2-hw_mfp) to access TT_MFP registers
;
hw_KB_cont	=	$ffffFC00
hw_KB_data	=	$ffffFC02
l_hw_KB_cont	=	$00ffFC00
l_hw_KB_data	=	$00ffFC02
;
hw_MIDI_cont	=	$ffffFC04
hw_MIDI_data	=	$ffffFC06
l_hw_MIDI_cont	=	$00ffFC04
l_hw_MIDI_data	=	$00ffFC06
;
;----------------------------------------------------------------------------
	endc	;RA_SYS_defined
;----------------------------------------------------------------------------
;End of file:	RA_SYS.I
;----------------------------------------------------------------------------
