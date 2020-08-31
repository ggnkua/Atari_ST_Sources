;----------------------------------------------------------------------------
;File name:	NETD.I				Revision date:	1998.12.04
;Creator:	Ulf Ronald Andersson		Creation date:	1998.10.29
;(c)1998 by:	Ulf Ronald Andersson		All rights reserved
;Feedback to:	dlanor@oden.se			Released as FREEWARE
;----------------------------------------------------------------------------
; Purpose:	Header file included in assembly sources to define
;		data structures needed for NETD programs under STinG.
;----------------------------------------------------------------------------
	ifnd	NETD_defined
NETD_defined	set	1
;----------------------------------------------------------------------------
	include	RA_STRUC.I		;macros needed for structures
;----------------------------------------------------------------------------
ND_XB_ID	=	'NetD'		;global NetD struct identifier
REF_IF_VER	=	$0101		;Current NetD interface version
;----------------------------------------------------------------------------
;NB: The interface defined has its own version number, independent of the
;    version number of the NetD components (NetD STX, NetD APP, servers).
;    Components will only work together when they have the same interface
;    version, and that will usually not change with normal releases.
;    When (if) it does change, all components will need to be updated.
;----------------------------------------------------------------------------
;The NetD STX, the NetD APP (or ACC), and the separate NetD servers will
;each have a structure based at their own basepage and used by the other
;components in contacting it.  The structures used for this are these:
;
;NetD_STX	installed by NetD STX in cookie jar with cookie id ND_XB_ID
;		All cookie struct elements are controlled by the NetD STX,
;		although the other programs can affect some indirectly by using
;		the function pointers in the cookie struct to demand services.
;
;NetD_APP	used as argument when NetD APP calls NetD STX functions through
;		the ND_..._APP function pointers.  This is passed to servers
;		too when NetD STX calls ND_SRV_connect or ND_SRV_traffic
;		functions in the servers. (So all can use GEM, but carefully !)
;
;NetD_SRV	installed by each NetD server into a queue of the NetD STX
;		by calling the ND_init_SRV function via that pointer in
;		NetD_STX.  It can be removed again by a similar call via
;		pointer ND_exit_SRV.  Both functions need a pointer to the
;		NetD_SRV struct of the server as single argument. A server can
;		only have a single NetD_SRV struct, but since each can handle
;		multiple ports this does not limit services.
;----------------------------------------------------------------------------
	struct	NetD_STX	;base of NetD STX installed as cookie
	d_s	ND_base,sizeof_BasePage	;basepage of the NetD STX
	d_s	ND_jump,sizeof_LongJump	;jump op to NetD STX startup code
;-------
	uint32	ND_magic	;Must equal ND_XB_ID
	uint32	ND_xmagic	;Must equal '_STX'
	uint32	ND_if_ver	;NetD interface version of NetD STX = REF_IF_VER
	uint16	ND_date		;release date of NetD STX (TOS format)
	char_p	ND_version	;NetD STX version string in "xx.yy" format
	char_p	ND_author	;-> name of author of NetD STX
;-------
	func_p	ND_init_APP	;-> func used by NetD APP to log in to NetD STX
	func_p	ND_exit_APP	;-> func used by NetD APP to log out from NetD STX
	func_p	ND_exec_APP	;-> func used by NetD APP at GEM timer events
;-------
	func_p	ND_init_SRV	;-> func used by servers to log in to NetD STX
	func_p	ND_exit_SRV	;-> func used by servers to log out from NetD STX
;-------
	func_p	ND_init_CON	;-> func used by servers to reserve a CONN service
	func_p	ND_exit_CON	;-> func used by servers to release a CONN service
	func_p	ND_kill_CON	;-> func used by servers to kill an active CONN
	func_p	ND_send_CON	;-> func optionally used by servers to send data
;-------
	struc_p	ND_server_q	;-> queue of servers logged in
	d_end	NetD_STX
;----------------------------------------------------------------------------
	struct	NetD_APP	;base of NetD APP
	d_s	ND_APP_base,sizeof_BasePage	;basepage of the NetD APP
	d_s	ND_APP_jump,sizeof_LongJump	;jump op to NetD APP startup code
;-------
	uint32	ND_APP_magic	;Must equal ND_XB_ID
	uint32	ND_APP_xmagic	;Must equal '_APP
	uint32	ND_APP_if_ver	;NetD interface version of NetD APP = REF_IF_VER
	uint16	ND_APP_date	;release date of NetD APP (TOS format)
	char_p	ND_APP_version	;NetD APP version string in 'xx.yy' format
	char_p	ND_APP_author	;name of author of NetD APP
;-------
	struc_p	ND_APP_global	;-> AES 'global' array of NetD APP
	d_end	NetD_APP
;----------------------------------------------------------------------------
	struct	NetD_SRV	;base of each NetD server
	d_s	ND_SRV_base,sizeof_BasePage	;basepage of a NetD server program
	d_s	ND_SRV_jump,sizeof_LongJump	;jump op to server startup code
;-------
	uint32	ND_SRV_magic	;Must equal ND_XB_ID
	uint32	ND_SRV_xmagic	;Must equal '_SRV'
	uint32	ND_SRV_if_ver	;NetD interface version of server = REF_IF_VER
	uint16	ND_SRV_date	;release date of server (TOS format)
	char_p	ND_SRV_version	;NetD SRV version string in "xx.yy" format
	char_p	ND_SRV_author	;name of author of server
;-------
	char_p	ND_SRV_name	;name of the server
;-------
	struc_p	ND_SRV_next	;-> next server struct or is NULL
	func_p	ND_SRV_connect	;-> server function used at connect
	func_p	ND_SRV_traffic	;-> server function for fluent traffic
	func_p	ND_SRV_warning	;-> server function used at NetD APP termination
	struc_p	ND_SRV_listen_q	;-> queue for listening connections
	struc_p ND_SRV_turnon_q	;-> queue for connections turning active
	struc_p	ND_SRV_active_q	;-> queue for active connections
	uint16	ND_SRV_flags	;bitmapped control flags (internal NetD use)
	d_end	NetD_SRV
;----------------------------------------------------------------------------
;The NetD_SRV structure (above) contains three connection queues.  These
;consist of chained elements, each of which is a NetD_CON structure, as
;shown below.
;----------------------------------------------------------------------------
	struct	NetD_CON	;substruct for connection queues
	struc_p	ND_CON_next	;-> next entry in queue or is NULL
	struc_p	ND_CON_server	;-> NetD_SRV struct of owning server
	d_alias	ND_CON_port_id	;alias for type<<16|port as one long
	d_alias	ND_CON_bsize	;alias for type == TCP buffer size
	uint16	ND_CON_type	;port type. 0==UDP,  non_zero==TCP
	d_alias	ND_CON_type_bsize	;another alias for the same
	uint16	ND_CON_port	;port number of connection
	int16	ND_CON_handle	;handle of connection
	struc_p	ND_CON_CIB_p	;-> CIB of connection
	d_s	ND_CON_pad,16	;16 bytes free for server usage
	d_end	NetD_CON
;-------
;NB:  The word element NetD_CON type, also accessible as the high word of
;     the long element ND_port_id, itself serves a dual purpose.  When
;     it is non-zero, to specify a TCP connection, then it will also be
;     used for the 'buffer size' argument of TCP_open.
;----------------------------------------------------------------------------
;	Definitions of NetD function macros for direct use follow
;
;	The user program must define the pointer 'NetD_STX_p' and init
;	its value via the NetD cookie before using these NetD functions.
;----------------------------------------------------------------------------
;	Submacros are used to make the interface flexible and powerful
;
;	sub_NetD is used to implement NetD functions, and uses submacros
;	defined in RA_SYS.I.  These give argument count check for all macros,
;	and allow indirection of pointers.
;----------------------------------------------------------------------------
sub_NetD	MACRO		function,arg_count,arg_flags,arg1,arg2,arg3
		CDECL_args.\0	\3,<\4>,<\5>,<\6>
		move.l		NetD_STX_p(pc),a0
		move.l		\1(a0),a0
		jsr		(a0)
		CDECL_cleanargs	\1,\2
		ENDM		;sub_NetD
;----------------------------------------------------------------------------
NetD_init_APP	MACRO		ND_APP_p
		sub_NetD.\0	ND_init_APP,1,3,<\1>
		ENDM
;------------------------------------
NetD_exit_APP	MACRO		ND_APP_p
		sub_NetD.\0	ND_exit_APP,1,3,<\1>
		ENDM
;------------------------------------
NetD_exec_APP	MACRO		ND_APP_p
		sub_NetD.\0	ND_exec_APP,1,3,<\1>
		ENDM
;----------------------------------------------------------------------------
NetD_init_SRV	MACRO		ND_SRV_p
		sub_NetD.\0	ND_init_SRV,1,3,<\1>
		ENDM
;------------------------------------
NetD_exit_SRV	MACRO		ND_SRV_p
		sub_NetD.\0	ND_exit_SRV,1,3,<\1>
		ENDM
;----------------------------------------------------------------------------
NetD_init_CON	MACRO		ND_SRV_p,type_bsz,port_num
		sub_NetD.\0	ND_init_CON,3,$17,<\1>,<\2>,<\3>
		ENDM
;------------------------------------
NetD_exit_CON	MACRO		ND_SRV_p,ND_CON_p
		sub_NetD.\0	ND_exit_CON,2,$0F,<\1>,<\2>
		ENDM
;------------------------------------
NetD_kill_CON	MACRO		ND_SRV_p,ND_CON_p
		sub_NetD.\0	ND_kill_CON,2,$0F,<\1>,<\2>
		ENDM
;------------------------------------
NetD_send_CON	MACRO		ND_CON_p,buff,len
		sub_NetD.\0	ND_send_CON,3,$1F,<\1>,<\2>,<\3>
		ENDM
;----------------------------------------------------------------------------
	endc	;NETD_defined
;----------------------------------------------------------------------------
;End of file:	NETD.I
;----------------------------------------------------------------------------
