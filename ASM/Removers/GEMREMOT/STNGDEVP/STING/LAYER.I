;----------------------------------------------------------------------------
; File name:	LAYER.I				Revision date:	1998.09.08
; Author:	Ronald Andersson		Creation date:	1997.03.26
;----------------------------------------------------------------------------
; Purpose:	High level StinG protocol interfacing
;		Header file included in assembly
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	STinG_LAYER_defined
STinG_LAYER_defined	set	1
;----------------------------------------------------------------------------
	include	RA_STRUC.I	;needed for C-style structure definitions
	include	RA_SYS.I	;needed for generic API-building macros
;----------------------------------------------------------------------------
MAX_HANDLE	=	64	;Number of handles assigned by PRTCL_request
;----------------------------------------------------------------------------
;	High level protocol module descriptor.
;
	struct 	LAYER
	char_p		LAYER_name		; Name of layer
	char_p		LAYER_version		; Version of layer in xx.yy format
	uint32		LAYER_flags		; Private data
	uint16		LAYER_date		; Compile date in GEMDOS format
	char_p		LAYER_author		; Name of programmer
	int16		LAYER_stat_dropped	; Statistics of dropped data units
	struct_p	LAYER_next		; Next layer in driver chain
	struct_p	LAYER_basepage		; Basepage of defining module (or kernel)
	d_end	LAYER
;----------------------------------------------------------------------------
;	CN functions structure for TCP and UDP
;
	struct	CN_FUNCS
	func_p	CNkick		;int16	cdecl	(* CNkick) (void *);
	func_p	CNbyte_count	;int16	cdecl	(* CNbyte_count) (void *);
	func_p	CNget_char	;int16	cdecl	(* CNget_char) (void *);
	func_p	CNget_NDB	;NDB	cdecl	(* CNget_NDB) (void *);
	func_p	CNget_block	;int16	cdecl	(* CNget_block) (void *, void *, int16);
	func_p	CNgetinfo	;CIB;	cdecl	(* CNgetinfo) (void *);
	func_p	CNgets		;int16	cdecl	(* CNgets) (void *, char *, int16, char);
	d_end	CN_FUNCS
;----------------------------------------------------------------------------
;	Module driver structure / functions
;
	struct	STX_head
	char_p	STX_module		; Specific string that can be searched for
	char_p	STX_author		; Any string
	char_p	STX_version		; Format `00.00' Version:Revision
	func_p	STX_set_dgram_ttl	;void	cdecl	(* set_dgram_ttl) (IP_DGRAM *);
	func_p	STX_check_dgram_ttl	;int16	cdecl	(* check_dgram_ttl) (IP_DGRAM *);
	func_p	STX_load_routing_table	;int16	cdecl	(* load_routing_table) (void);
	func_p	STX_set_sysvars		;int32	cdecl	(* set_sysvars) (int16, int16);
	func_p	STX_query_chains	;void	cdecl	(* query_chains) (void **, void **, void **);
	func_p	STX_IP_send		;int16	cdecl	(* IP_send) (uint32, uint32, uint8, uint16, uint8, uint8, uint16, void *, uint16, void *, uint16);
	func_p	STX_IP_fetch		;IP_DGRAM * cdecl	(* IP_fetch) (int16);
	func_p	STX_IP_handler		;int16	cdecl	(* IP_handler) (int16, int16 cdecl (*) (IP_DGRAM *), int16);
	func_p	STX_IP_discard		;void	cdecl	(* IP_discard) (IP_DGRAM *, int16);
	func_p	STX_PRTCL_announce	;int16	cdecl	(* PRTCL_announce) (int16);
	func_p	STX_PRTCL_get_parameters ;int16	cdecl	(* PRTCL_get_parameters) (uint32, uint32 *, int16 *, uint16 *);
	func_p	STX_PRTCL_request	;int16	cdecl	(* PRTCL_request) (void *, CN_FUNCS *);
	func_p	STX_PRTCL_release	;void	cdecl	(* PRTCL_release) (int16);
	func_p	STX_PRTCL_lookup	;void;	cdecl	(* PRTCL_lookup) (int16, CN_FUNCS *);
	func_p	STX_TIMER_call		;int16	cdecl	(* TIMER_call) (void cdecl (*) (void), int16);
	func_p	STX_TIMER_now		;int32	cdecl	(* TIMER_now) (void);
	func_p	STX_TIMER_elapsed	;int32	cdecl	(* TIMER_elapsed) (int32);
	func_p	STX_protect_exec	;int32	cdecl	(* protect_exec) (void *, int32 cdecl (*) (void *));
	func_p	STX_get_route_entry	;int16	cdecl  (* get_route_entry) (int16, uint32 *, uint32 *, void **, uint32 *);
	func_p	STX_set_route_entry	;int16	cdecl  (* set_route_entry) (int16, uint32, uint32, void *, uint32);
	d_end	STX_head
;----------------------------------------------------------------------------
;	Definitions of module driver function macros for direct use
;----------------------------------------------------------------------------
;	Submacros are used to make the interface flexible and powerful
;
;sub_stx	is used to implement all STX functions, and uses submacros
;		sub_sub_stx as well as some of URAn_SYS.SH.  It gives argument
;		count check for all macros, and allows indirection of pointers.
;----------------------------------------------------------------------------
sub_stx		MACRO		function,arg_count,arg_flags,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11
		CDECL_args.\0	\3,<\4>,<\5>,<\6>,<\7>,<\8>,<\9>,<\a>,<\b>,<\c>,<\d>,<\e>
		sub_sub_stx	STX_\1
		CDECL_cleanargs	\1,\2
		ENDM		;sub_stx
;-------------------------------------
sub_sub_stx	MACRO		stx_function
		move.l		stx,a0
		move.l		\1(a0),a0
		jsr		(a0)
		ENDM		;sub_sub_stx
;----------------------------------------------------------------------------
set_dgram_ttl	MACRO		dgram_p
		sub_stx.\0	set_dgram_ttl,1,3,<\1>
		ENDM
;-------------------------------------
check_dgram_ttl	MACRO		dgram_p
		sub_stx.\0	check_dgram_ttl,1,3,<\1>
		ENDM
;-------------------------------------
load_routing_table	MACRO
		sub_stx	load_routing_table,0,0
		ENDM
;-------------------------------------
set_sysvars	MACRO		active_f,count_5ms
		sub_stx		set_sysvars,2,5,<\1>,<\2>
		ENDM
;-------------------------------------
query_chains	MACRO		port_p,driver_p,layer_p
		sub_stx.\0	query_chains,3,$3F,<\1>,<\2>,<\3>
		ENDM
;-------------------------------------
IP_send		MACRO		s_IP,d_IP,tos,unfrag,ttl,proto,id,data_p,datalen,opt_p,optlen
		sub_stx.\0	IP_send,11,$1DD04A,<\1>,<\2>,<\3>,<\4>,<\5>,<\6>,<\7>,<\8>,<\9>,<\a>,<\b>
		ENDM
;-------------------------------------
IP_fetch	MACRO		protocol
		sub_stx		IP_fetch,1,1,<\1>
		ENDM
;-------------------------------------
IP_handler	MACRO		protocol,handler_p,install_code
		sub_stx.\0	IP_handler,3,$1D,<\1>,<\2>,<\3>
		ENDM
;-------------------------------------
IP_discard	MACRO		dgram_p,all_f
		sub_stx.\0	IP_discard,2,7,<\1>,<\2>
		ENDM
;-------------------------------------
PRTCL_announce	MACRO		protocol
		sub_stx	PRTCL_announce,1,1,<\1>
		ENDM
;-------------------------------------
PRTCL_get_parameters	MACRO	remote_IP,local_IP_p,ttl_p,mtu_p
		sub_stx.\0	PRTCL_get_parameters,4,$FE,<\1>,<\2>,<\3>,<\4>
		ENDM
;-------------------------------------
PRTCL_request	MACRO		cn_data_p,cn_funcs_p
		sub_stx.\0	PRTCL_request,2,$F,<\1>,<\2>
		ENDM
;-------------------------------------
PRTCL_release	MACRO		cn_handle
		sub_stx		PRTCL_release,1,1,<\1>
		ENDM
;-------------------------------------
PRTCL_lookup	MACRO		cn_handle,cn_funcs_p
		sub_stx.\0	PRTCL_lookup,2,$D,<\1>,<\2>
		ENDM
;-------------------------------------
TIMER_call	MACRO		handler_p,install_code
		sub_stx.\0	TIMER_call,2,7,<\1>,<\2>
		ENDM
;-------------------------------------
TIMER_now	MACRO
		sub_stx	TIMER_now,0,0
		ENDM
;-------------------------------------
TIMER_elapsed	MACRO		old_time
		sub_stx	TIMER_elapsed,1,2,<\1>
		ENDM
;-------------------------------------
protect_exec	MACRO		arg_p,fun_p
		sub_stx.\0	protect_exec,2,$F,<\1>,<\2>
		ENDM
;-------------------------------------
get_route_entry	MACRO		w1,l2_p,l3_p,v4_p_p,l5_p
		sub_stx.\0	get_route_entry,5,$3FD,<\1>,<\2>,<\3>,<\4>,<\5>
		ENDM
;-------------------------------------
set_route_entry	MACRO		w1,l2,l3,v4_p,l5
		sub_stx.\0	set_route_entry,5,$2E9,<\1>,<\2>,<\3>,<\4>,<\5>
		ENDM
;----------------------------------------------------------------------------
	endc	;STinG_LAYER_defined
;----------------------------------------------------------------------------
; End of file:	LAYER.I
;----------------------------------------------------------------------------
