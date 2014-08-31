;----------------------------------------------------------------------------
;File name:	RA_DSPT.I			Revision date:	1999.09.18
;Created by:	Ulf Ronald Andersson		Creation date:	1997.02.13
;----------------------------------------------------------------------------
;This is an include file defining constants and macros for my DSP Tracker
;server (normally abbreviated DspT) and its various client programs.
;----------------------------------------------------------------------------
DspT_s_c	=	'DspT'	;This is the XBRA and cookie identifier used
DspT_own_c	=	$0105	;constant for current server version
DspT_int_c	=	$0105	;constant for current interface version
;----------------------------------------------------------------------------
;The make_DspT_cookie macro below is only to be invoked by the server source
;in order to create the master copy of the structure. It's useless to clients,
;because it refers to labels existing only in the server code.  It is useful
;to client writers, however, as a clear example of how the cookie is created.
;----------------------------------------------------------------------------
make_DspT_cookie	MACRO
DspT_cookie:
	dc.l	DspT_s_c
	dc.l	DspT_cookie_end-DspT_cookie
	dc.w	DspT_own_c	;own_vers
	dc.w	DspT_int_c	;int_vers
	dc.w	0		;Filled in at runtime with DSP ability code
	dc.l	DspT_s_disp	;-> super mode dispatcher table
	dc.l	DspT_u_disp	;-> user mode dispatcher table
DspT_cookie_end:
	ENDM	;make_DspT_cookie
;----------------------------------------------------------------------------
;Here is the symbolic structure defining the offsets useful to clients,
;but further macros below makes it unnecessary to study them in detail,
;as all is handled transparently by function macros.
;----------------------------------------------------------------------------
		rsreset
DspT_magic		rs.l	1	;Magic code must be "DspT"
DspT_cookie_size	rs.l	1	;total bytes in cookie struct
DspT_own_version	rs.w	1	;DspT version of current server
DspT_int_version	rs.w	1	;DspT version defining its interface
DspT_DSP_ability	rs.w	1	;DSP ability code assigned to DspT
DspT_s_dispatcher	rs.l	1	;-> super mode dispatcher table
DspT_u_dispatcher	rs.l	1	;-> user mode dispatcher table
DspT_end		rs.b	0	;currently the struct ends here
;----------------------------------------------------------------------------
;The dispatcher tables are 'branch tables' where each entry consists of four
;bytes forming a branch opcode, like for example  "bra.w   DspT_s_alloc".
;But user code should not branch directly there. Instead the macros that
;are provided below should be used, as they have extensive error checking.
;
;In fact two macros alone, are all that a client program needs to use.
;The others will be invoked as submacros automatically, as needed.
;
;Clients must init their cookie interface by either of two macros:
;
;	DspT_s_init	;for clients running in supervisor mode
;	DspT_u_init	;for clients running in user mode
;
;All actual use of the functions is handled through a single macro, although
;that has two distinct modes of usage:
;
;	DspT	u,function_name,argument_list	;for calls in user mode
;	DspT	s,function_name,argument_list	;for calls in super mode
;
;It is perfectly legal to use both the super and the user forms in the same
;client, and both of the initialization macros prepare for both forms of use.
;----------------------------------------------------------------------------
;	DspT dispatcher function numbers
;----------------------------------------------------------------------------
			rsreset
DspT_fn_calc		rs.b	1	;long	DspT_calc(rawmod *module_p)
DspT_fn_alloc		rs.b	1	;mod	*DspT_alloc(long size)
DspT_fn_free		rs.b	1	;long	DspT_free(mod *module_p)
;-------
DspT_fn_copy_start	rs.b	1	;mod	*DspT_copy_start(long size, rawmod *mod_p, void (*dumpfunc_p)())
;-------
DspT_fn_load		rs.b	1	;mod	*DspT_load(char *filepath_p)
;-------
DspT_fn_start		rs.b	1	;mod	*DspT_start(mod *module_p, void (*dumpfunc_p)())
DspT_fn_restart		rs.b	1	;mod	*DspT_restart()
;-------
DspT_fn_play		rs.b	1	;mod	*DspT_play()
DspT_fn_stop		rs.b	1	;void	DspT_stop()
DspT_fn_dump		rs.b	1	;void	DspT_dump()
;-------
DspT_fn_test_end	rs.b	1	;long	DspT_test_end()
;-------
DspT_fn_set_timer	rs.b	1	;long	DspT_set_timer(short new_timer_f)
DspT_fn_set_boost	rs.b	1	;short	DspT_set_boost(short new_boost)
DspT_fn_set_stop	rs.b	1	;short	DspT_set_stop(short new_mode_f)
DspT_fn_set_order	rs.b	1	;short	DspT_set_order(short new_order)
;-------
DspT_fn_get_funcp	rs.b	1	;func	*DspT_get_funcp(short mode, short opcode)
DspT_fn_get_mod_path	rs.b	1	;short	DspT_get_mod_path(char **path)
;-------
DspT_opcode_limit	rs.b	0	;this is a limit, not a function
;----------------------------------------------------------------------------
;DspT_opcode_limit above will always be last in the struct, to mark the limit
;----------------------------------------------------------------------------
;	DspT dispatcher function arg counts
;----------------------------------------------------------------------------
DspT_ac_calc		=	1	;long	DspT_calc(rawmod *module_p)
DspT_ac_alloc		=	1	;mod	*DspT_alloc(long size)
DspT_ac_free		=	1	;long	DspT_free(mod *module_p)
;-------
DspT_ac_copy_start	=	3	;mod	*DspT_copy_start(long size, rawmod *mod_p, void (*dumpfunc_p)())
;-------
DspT_ac_load		=	1	;mod	*DspT_load(char *filepath_p)
;-------
DspT_ac_start		=	2	;mod	*DspT_start(mod *module_p, void (*dumpfunc_p)())
DspT_ac_restart		=	0	;mod	*DspT_restart()
;-------
DspT_ac_play		=	0	;mod	*DspT_play()
DspT_ac_stop		=	0	;void	DspT_stop()
DspT_ac_dump		=	0	;void	DspT_dump()
;-------
DspT_ac_test_end	=	0	;long	DspT_test_end()
;-------
DspT_ac_set_timer	=	1	;long	DspT_set_timer(short new_timer_f)
DspT_ac_set_boost	=	1	;short	DspT_set_boost(short new_boost)
DspT_ac_set_stop	=	1	;short	DspT_set_stop(short new_mode_f)
DspT_ac_set_order	=	1	;short	DspT_set_order(short new_order)
;-------
DspT_ac_get_funcp	=	2	;func	*DspT_get_funcp(short mode, short opcode)
DspT_ac_get_mod_path	=	1	;short	DspT_get_mod_path(char **path)
;----------------------------------------------------------------------------
;	DspT dispatcher function arg flags
;----------------------------------------------------------------------------
DspT_af_calc		=	$03	;long	DspT_calc(rawmod *module_p)
DspT_af_alloc		=	$02	;mod	*DspT_alloc(long size)
DspT_af_free		=	$03	;long	DspT_free(mod *module_p)
;-------
DspT_af_copy_start	=	$3E	;mod	*DspT_copy_start(long size, rawmod *mod_p, void (*dumpfunc_p)())
;-------
DspT_af_load		=	$03	;mod	*DspT_load(char *filepath_p)
;-------
DspT_af_start		=	$0F	;mod	*DspT_start(mod *module_p, void (*dumpfunc_p)())
DspT_af_restart		=	$00	;mod	*DspT_restart()
;-------
DspT_af_play		=	$00	;mod	*DspT_play()
DspT_af_stop		=	$00	;void	DspT_stop()
DspT_af_dump		=	$00	;void	DspT_dump()
;-------
DspT_af_test_end	=	$00	;long	DspT_test_end()
;-------
DspT_af_set_timer	=	$01	;long	DspT_set_timer(short new_timer_f)
DspT_af_set_boost	=	$01	;short	DspT_set_boost(short new_boost)
DspT_af_set_stop	=	$01	;short	DspT_set_stop(short new_mode_f)
DspT_af_set_order	=	$01	;short	DspT_set_order(short new_order)
;-------
DspT_af_get_funcp	=	$05	;func	*DspT_get_funcp(short mode, short opcode)
DspT_af_get_mod_path	=	$03	;short	DspT_get_mod_path(char **path)
;----------------------------------------------------------------------------
DspT_s_init	MACRO
		IFND	DspT__data_defv
		bsr.s	DspT_s_init
		DspT_x_init
		ELSE
		bsr	DspT_s_init
		ENDC
		ENDM
;----------------------------------------------------------------------------
DspT_u_init	MACRO
		IFND	DspT__data_defv
		DspT_x_init
		bsr.s	DspT_u_init
		ELSE
		bsr	DspT_u_init
		ENDC
		ENDM
;----------------------------------------------------------------------------
DspT_x_init	MACRO
		IFND	DspT__data_defv
DspT__data_defv	set	1
DspT__data_defl:
		bra	DspT_x_init_end
;-------
DspT_s_init:
		movem.l		d1-d3/a1-a2,-(sp)
		eval_cookie	#DspT_s_c
		move.l		d0,DspT_cookie_p
		ble.s		.done_cookie
		move.l		d0,a0
		cmp		#DspT_int_c,DspT_int_version(a0)
		beq.s		.version_ok
		moveq		#-2,d0
		move.l		d0,a0
		move.l		a0,DspT_cookie_p
		move.l		a0,DspT_s_disp_p
		move.l		a0,DspT_u_disp_p
		bra.s		.done_cookie
;-------
.version_ok:
		move.l		DspT_s_dispatcher(a0),DspT_s_disp_p
		move.l		DspT_u_dispatcher(a0),DspT_u_disp_p
.done_cookie:
		movem.l	(sp)+,d1-d3/a1-a2
		rts
;-------
DspT_cookie_p:	dc.l	-1
DspT_s_disp_p:	dc.l	-1
DspT_u_disp_p:	dc.l	-1
;-------
goto__DspT:	;d0 -> dispatcher table  sp -> needed_d0, dispatch offset, return adress
		add.l	d0,4(sp)	;sp -> needed d0, ->dispatch code, return address
		move.l	(sp)+,d0	;d0 = needed_d0  sp -> dispatch code, return address
		tst	(sp)		;is dispatcher ptr on stack valid ?
		bgt.s	.exit		;if so, go exit to that address
		addq	#4,sp		;else remove invalid dispatcher ptr
		moveq	#E_ERROR,d0	;and flag error to caller
.exit:
		rts	;goto DspT routine, or back to caller (DspT unfound)
;-------
DspT_u_init:
		movem.l	d1-d2/a1-a2,-(sp)
		xbios	Supexec,DspT_s_init(pc)
		movem.l	(sp)+,d1-d2/a1-a2
		move.l	DspT_cookie_p(pc),a0
		move.l	a0,d0
		rts
;-------
DspT_x_init_end:
		ENDC
		ENDM	;Dspt_x_init
;----------------------------------------------------------------------------
DspT		MACRO		mode,function,arg1,arg2,arg3
		IFD	DspT__data_refl
		IFND	DspT__data_defl
		FAIL	'missing DspT_s_init or DspT_u_init macro call'
		ENDC
		ENDC
		IFND	DspT__data_refv
DspT__data_refv	set	1
DspT__data_refl:
		ENDC
		IFND	DspT_fn_\2
		FAIL	'Undefined DspT function "\2"'
		MEXIT
		ENDC
		IFC	's','\1'
DspT__mode_f	set	1
		ELSE
		IFC	'u','\1'
DspT__mode_f	set	0
		ELSE
		FAIL	'incorrect mode spec in "DspT.\0 \1,\2,\3,\4,\5"
		FAIL	'allowed mode specs are only "u" and "s"'
		MEXIT
		ENDC
		ENDC
		PUREC_args.\0	DspT_af_\2,\3,\4,\5
		pea	retadr\@(pc)
		move.l	#DspT_fn_\2<<2,-(sp)
		move.l	d0,-(sp)
		IFNE	DspT__mode_f
		move.l	DspT_s_disp_p(pc),d0
		ELSE
		move.l	DspT_u_disp_p(pc),d0
		ENDC
		bra	goto__DspT	;goto a DspT server routine or error handler
retadr\@:		;returning here afterwards
		PUREC_cleanargs	DspT_fn_\2,DspT_ac_\2
		ENDM
;----------------------------------------------------------------------------
;End of file:	MOD_COOK.I
;----------------------------------------------------------------------------
