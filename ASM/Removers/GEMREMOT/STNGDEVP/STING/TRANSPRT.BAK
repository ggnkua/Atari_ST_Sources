;----------------------------------------------------------------------------
; File name:	TRANSPRT.I			Revision date:	2000.06.14
; Author:	Ronald Andersson		Creation date:	1997.03.26
;----------------------------------------------------------------------------
; Purpose:	High level StinG client support
;		Header file included in assembly
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	STinG_TRANSPRT_defined
STinG_TRANSPRT_defined	set	1
;----------------------------------------------------------------------------
	include	RA_STRUC.I	;needed for C-style structure definitions
	include	RA_SYS.I	;needed for generic API-building macros
;----------------------------------------------------------------------------
;
;TRANSPORT_DRIVER	"TRANSPORT_TCPIP"
;TCP_DRIVER_VERSION	"01.00"
;
;----------------------------------------------------------------------------
;		Driver access structure / functions
;
;MAGIC	"STiKmagic"			; Magic for DRV_LIST.magic
;CJTAG	"STiK"
;
	struct	DRV_HDR			; Header part of TPL structure
	char_p	DRV_HDR_module		; Specific string that can be searched for
	char_p	DRV_HDR_author		; Any string
	char_p	DRV_HDR_version		; Format `00.00' Version:Revision
	d_end	DRV_HDR
;
	struct	DRV_LIST
	char	DRV_LIST_magic,10	; Magic string, def'd as "STiKmagic"
	func_p	DRV_LIST_get_dftab	;DRV_HDR * cdecl (*get_dftab) (char *);
	func_p	DRV_LIST_ETM_exec	;int16	cdecl (*ETM_exec) (char *);	; Execute a STinG module
	void_p	DRV_LIST_cfg		; Config structure
	void_p	DRV_LIST_sting_basepage	; STinG basepage address
	d_end	DRV_LIST
;----------------------------------------------------------------------------
;The access macros below assume that the STiK cookie value has been placed
;in a pointer named 'drivers' before they are called.  Doing so is up to
;the user program, and failure to do so inevitably causes bombs...
;----------------------------------------------------------------------------
get_dftab	MACRO	ch_p
		move.l	\1,-(sp)
		move.l	drivers,a0
		move.l	DRV_LIST_get_dftab(a0),a0
		jsr	(a0)
		addq	#4,sp
		ENDM	;get_dftab
;------------------------------------
ETM_exec	MACRO	ch_p
		move.l	\1,-(sp)
		move.l	drivers,a0
		move.l	DRV_LIST_ETM_exec(a0),a0
		jsr	(a0)
		addq	#4,sp
		ENDM	;ETM_exec
;----------------------------------------------------------------------------
;	TCP and UDP port escape flags
;
TCP_ACTIVE	=	$0000	; Initiate active connection
TCP_PASSIVE	=	$ffff	; Initiate passive connection
UDP_EXTEND	=	$0000	; Extended addressing scheme
;----------------------------------------------------------------------------
;	TCP miscellaneous flags.
;
TCP_URGENT	=	-1	; ((void *) -1)  Mark urgent position
TCP_HALFDUPLEX	=	-1	; TCP_close() half duplex
TCP_IMMEDIATE	=	0	; TCP_close() immediate
;----------------------------------------------------------------------------
;		TCP connection states
;
TCLOSED		=	0	; No connection.	Null, void, absent, ...
TLISTEN		=	1	; Wait for remote request
TSYN_SENT	=	2	; Connect request sent, await matching request
TSYN_RECV	=	3	; Wait for connection ack
TESTABLISH	=	4	; Connection established, handshake completed
TFIN_WAIT1	=	5	; Await termination request or ack
TFIN_WAIT2	=	6	; Await termination request
TCLOSE_WAIT	=	7	; Await termination request from local user
TCLOSING	=	8	; Await termination ack from remote TCP
TLAST_ACK	=	9	; Await ack of terminate request sent
TTIME_WAIT	=	10	; Delay, ensures remote has received term' ack
;----------------------------------------------------------------------------
;		TCP information block
;-------------------------------------
	struct	TCPIB
	uint32	TCPIB_request	;32 bit flags requesting various info
	uint16	TCPIB_state	;current TCP state
	uint32	TCPIB_unacked	;unacked outgoing sequence length (incl SYN/FIN)
	uint32	TCPIB_srtt	;smoothed round trip time of this connection
	d_end	TCPIB
;-------------------------------------
TCPI_state	=	1	;request current TCP state
TCPI_unacked	=	2	;request length of unacked sequence
TCPI_srtt	=	4	;request smoothed round trip time
TCPI_defer	=	8	;request switch to DEFER mode
;-------------------------------------
TCPI_bits	= 4
TCPI_mask	= (1<<TCPI_bits)-1
;----------------------------------------------------------------------------
;NB: A TCP_info request using undefined bits will result in E_PARAMETER.
;    else the return value will be TCPI_bits, so user knows what we have.
;    Future additions will use rising bits in sequence, and additions to
;    the TCPIB struct will always be made at its previous end.
;----------------------------------------------------------------------------
;!!! By calling TCP_info the connection is switched into 'DEFER' mode !!!
;    This means that all situations where internal looping would occur
;    will instead lead to exit to the caller with return value E_LOCKED.
;    Using this mode constitutes agreement to always check for that error
;    code, which is mainly used for connections using DEFER mode. It may
;    also be used in some other instances, where a function is blocked in
;    such a way that internal looping is not possible.
;----------------------------------------------------------------------------
;		UDP information block
;-------------------------------------
	struct	UDPIB
	uint32	UDPIB_request	;32 bit flags requesting various info
	uint16	UDPIB_state	;current UDP state
	uint32	UDPIB_unacked	;unacked outgoing sequence length (incl SYN/FIN)
	uint32	UDPIB_srtt	;smoothed round trip time of this connection
	d_end	UDPIB
;-------------------------------------
UDPI_state	=	1	;request current UDP state
UDPI_unacked	=	2	;request length of unacked sequence
UDPI_srtt	=	4	;request smoothed round trip time
UDPI_defer	=	8	;request switch to DEFER mode
;-------------------------------------
UDPI_bits	=	4
UDPI_mask	=	(1<<UDPI_bits)-1
;----------------------------------------------------------------------------
;NB: A UDP_info request using undefined bits will result in E_PARAMETER.
;    else the return value will be UDPI_bits, so user knows what we have.
;    Future additions will use rising bits in sequence, and additions to
;    the UDPIB struct will always be made at its previous end.
;----------------------------------------------------------------------------
;!!! By UDP_info with UDPI_defer, connection is switched to 'DEFER' mode.
;    This means that all situations where internal looping would occur
;    will instead lead to exit to the caller with return value E_LOCKED.
;    Using this mode constitutes agreement to always check for that error
;    code, which is mainly used for connections using DEFER mode. It may
;    also be used in some other instances, where a function is blocked in
;    such a way that internal looping is not possible.
;----------------------------------------------------------------------------
;		Port Name Transfer Area
;
	struct	PNTA		;Buffer for inquiring port names
	uint32	PNTA_opaque	;Kernel internal data
	int16	PNTA_name_len	;Length of name buffer
	char_p	PNTA_port_name	;Address of name buffer
	d_end	PNTA
;----------------------------------------------------------------------------
;		Command opcodes for cntrl_port().
;
CTL_KERN_FIRST_PORT	= ('K'<<8|'F')	;Kernel
CTL_KERN_NEXT_PORT	= ('K'<<8|'N')	;Kernel
CTL_KERN_FIND_PORT	= ('K'<<8|'G')	;Kernel
;------------------------------------
CTL_GENERIC_SET_IP	= ('G'<<8|'H')	;Kernel, all ports
CTL_GENERIC_GET_IP	= ('G'<<8|'I')	;Kernel, all ports
CTL_GENERIC_SET_MASK	= ('G'<<8|'L')	;Kernel, all ports
CTL_GENERIC_GET_MASK	= ('G'<<8|'M')	;Kernel, all ports
CTL_GENERIC_SET_MTU	= ('G'<<8|'N')	;Kernel, all ports
CTL_GENERIC_GET_MTU	= ('G'<<8|'O')	;Kernel, all ports
CTL_GENERIC_GET_MMTU	= ('G'<<8|'P')	;Kernel, all ports
CTL_GENERIC_GET_TYPE	= ('G'<<8|'T')	;Kernel, all ports
CTL_GENERIC_GET_STAT	= ('G'<<8|'S')	;Kernel, all ports
CTL_GENERIC_CLR_STAT	= ('G'<<8|'C')	;Kernel, all ports
;------------------------------------
CTL_SERIAL_SET_PRTCL	= ('S'<<8|'P')	;Serial Driver
CTL_SERIAL_GET_PRTCL	= ('S'<<8|'Q')	;Serial Driver
CTL_SERIAL_SET_LOGBUFF	= ('S'<<8|'L')	;Serial Driver
CTL_SERIAL_SET_LOGGING	= ('S'<<8|'F')	;SerialDriver
CTL_SERIAL_SET_AUTH	= ('S'<<8|'A')	;Serial Driver
CTL_SERIAL_SET_PAP	= ('S'<<8|'B')	;Serial Driver
CTL_SERIAL_INQ_STATE	= ('S'<<8|'S')	;Serial Driver
;------------------------------------
CTL_ETHER_SET_MAC	= ('E'<<8|'M')	;EtherNet
CTL_ETHER_GET_MAC	= ('E'<<8|'N')	;EtherNet
CTL_ETHER_INQ_SUPPTYPE	= ('E'<<8|'Q')	;EtherNet
CTL_ETHER_SET_TYPE	= ('E'<<8|'T')	;EtherNet
CTL_ETHER_GET_TYPE	= ('E'<<8|'U')	;EtherNet
;------------------------------------
CTL_MASQUE_SET_PORT	= ('M'<<8|'P')	;Masquerade
CTL_MASQUE_GET_PORT	= ('M'<<8|'Q')	;Masquerade
CTL_MASQUE_SET_MASKIP	= ('M'<<8|'M')	;Masquerade
CTL_MASQUE_GET_MASKIP	= ('M'<<8|'N')	;Masquerade
CTL_MASQUE_GET_REALIP	= ('M'<<8|'R')	;Masquerade
;----------------------------------------------------------------------------
;		Handler flag values.
;
HNDLR_SET	=	0		; Set new handler if space
HNDLR_FORCE	=	1		; Force new handler to be set
HNDLR_REMOVE	=	2		; Remove handler entry
HNDLR_QUERY	=	3		; Inquire about handler entry
;----------------------------------------------------------------------------
;		IP packet header.
;
	struct	IPHD
	d_field	IPHD_verlen_f,8		;bitfield
	d_bits	IPHD_f_version,4	; IP Version
	d_bits	IPHD_f_hd_len,4		; Internet Header Length/4
	uint8	IPHD_tos		; Type of Service
	uint16	IPHD_length		; Total of all header, options and data
	uint16	IPHD_ident		; Identification for fragmentation
	d_field	IPHD_frag_f,16		;bitfield
	d_bits	IPHD_f_reserved,1	; Reserved : Must be zero
	d_bits	IPHD_f_dont_frg,1	; Don't fragment flag
	d_bits	IPHD_f_more_frg,1	; More fragments flag
	d_bits	IPHD_f_frag_ofst,13	; Fragment offset
	uint8	IPHD_ttl		; Time to live
	uint8	IPHD_protocol		; Protocol
	uint16	IPHD_hdr_chksum		; Header checksum
	uint32	IPHD_ip_src		; Source IP address
	uint32	IPHD_ip_dest		; Destination IP address
	d_end	IPHD
;----------------------------------------------------------------------------
;		Internal IP packet representation.
;
	struct	IPDG
	char		IPDG_hdr,sizeof_IPHD	; Header of IP packet
	void_p		IPDG_options		; Options data block
	int16		IPDG_opt_length		; Length of options data block
	void_p		IPDG_pkt_data		; IP packet data block
	int16		IPDG_pkt_length		; Length of IP packet data block
	uint32		IPDG_timeout		; Timeout of packet life
	uint32		IPDG_ip_gateway		; Gateway for forwarding this packet
	void_p		IPDG_recvd		; Receiving port
	struct_p	IPDG_next		; Next IP packet in IP packet queue
	d_end	IPDG
;----------------------------------------------------------------------------
;		Values for protocol field of IP headers.
;
P_ICMP	=	1	; IP assigned number for ICMP
P_TCP	=	6	; IP assigned number for TCP
P_UDP	=	17	; IP assigned number for UDP
;----------------------------------------------------------------------------
;		Input queue structure
;
	struct	NDB			; Network Data Block.	For data delivery
	char_p		NDB_ptr		; Pointer to base of block. (For KRfree)
	char_p		NDB_ndata	; Pointer to next data to deliver
	uint16		NDB_len		; Length of remaining data
	struct_p	NDB_next	; Next NDB in chain or NULL
	d_end	NDB
;----------------------------------------------------------------------------
;		Connection address block
;
	struct	CAB
	uint16	CAB_lport	; TCP local  port     (ie: local machine)
	uint16	CAB_rport	; TCP remote port     (ie: remote machine)
	uint32	CAB_rhost	; TCP remote IP addr  (ie: remote machine)
	uint32	CAB_lhost	; TCP local  IP addr  (ie: local machine)
	d_end	CAB
;----------------------------------------------------------------------------
;		Connection information block
;
	struct	CIB		; Connection Information Block
	uint16	CIB_protocol	; TCP or UDP or ... 0 means CIB is not in use
	d_alias	CIB_address	; CAB structure (see above)
	uint16	CIB_lport	; TCP local	port	(ie: local machine)
	uint16	CIB_rport	; TCP remote port	(ie: remote machine)
	uint32	CIB_rhost	; TCP remote IP addr	(ie: remote machine)
	uint32	CIB_lhost	; TCP local	IP addr	(ie: local machine)
	uint16	CIB_status	; Net status. 0 means normal
	d_end	CIB
;
;NB: the d_alias above maintains compatibility between old and new methods
;----------------------------------------------------------------------------
;		Transport structure
;
	struct TPL
;-------
	char_p	TPL_module		; Specific string that can be searched for
	char_p	TPL_author		; Any string
	char_p	TPL_version		; Format `00.00' Version:Revision
;-------
	func_p	TPL_KRmalloc		;void *	cdecl	(* KRmalloc) (int32);
	func_p	TPL_KRfree		;void	cdecl	(* KRfree) (void *);
	func_p	TPL_KRgetfree		;int32	cdecl	(* KRgetfree) (int16);
	func_p	TPL_KRrealloc		;void *	cdecl	(* KRrealloc) (void *, int32);
;-------
	func_p	TPL_get_err_text	;char *	cdecl	(* get_err_text) (int16);
	func_p	TPL_getvstr		;char *	cdecl	(* getvstr) (char *);
;-------
	func_p	TPL_carrier_detect	;int16	cdecl	(* carrier_detect) (void);
;-------
	func_p	TPL_TCP_open		;int16	cdecl	(* TCP_open) (uint32, int16, int16, uint16);
	func_p	TPL_TCP_close		;int16	cdecl	(* TCP_close) (int16, int16, int16 *);
	func_p	TPL_TCP_send		;int16	cdecl	(* TCP_send) (int16, void *, int16);
	func_p	TPL_TCP_wait_state	;int16	cdecl	(* TCP_wait_state) (int16, int16, int16);
	func_p	TPL_TCP_ack_wait	;int16	cdecl	(* TCP_ack_wait) (int16, int16);
;-------
	func_p	TPL_UDP_open		;int16	cdecl	(* UDP_open) (uint32, int16);
	func_p	TPL_UDP_close		;int16	cdecl	(* UDP_close) (int16);
	func_p	TPL_UDP_send		;int16	cdecl	(* UDP_send) (int16, void *, int16);
;-------
	func_p	TPL_CNkick		;int16	cdecl	(* CNkick) (int16);
	func_p	TPL_CNbyte_count	;int16	cdecl	(* CNbyte_count) (int16);
	func_p	TPL_CNget_char		;int16	cdecl	(* CNget_char) (int16);
	func_p	TPL_CNget_NDB		;NDB *	cdecl	(* CNget_NDB) (int16);
	func_p	TPL_CNget_block		;int16	cdecl	(* CNget_block) (int16, void *, int16);
;-------
	func_p	TPL_housekeep		;void	cdecl	(* housekeep) (void);
	func_p	TPL_resolve		;int16	cdecl	(* resolve) (char *, char **, uint32 *, int16);
	func_p	TPL_ser_disable		;void	cdecl	(* ser_disable) (void);
	func_p	TPL_ser_enable		;void	cdecl	(* ser_enable) (void);
	func_p	TPL_set_flag		;int16	cdecl	(* set_flag) (int16);
	func_p	TPL_clear_flag		;void	cdecl	(* clear_flag) (int16);
	func_p	TPL_CNgetinfo		;CIB *	cdecl	(* CNgetinfo) (int16);
;-------
	func_p	TPL_on_port		;int16	cdecl	(* on_port) (char *);
	func_p	TPL_off_port		;void	cdecl	(* off_port) (char *);
	func_p	TPL_setvstr		;int16	cdecl	(* setvstr) (char *, char *);
	func_p	TPL_query_port		;int16	cdecl	(* query_port) (char *);
	func_p	TPL_CNgets		;int16	cdecl	(* CNgets) (int16, char *, int16, char);
;------- STinG ICMP functions ----------
	func_p	TPL_ICMP_send		;int16	cdecl	(* ICMP_send) (uint32, uint8, uint8, void *, uint16);
	func_p	TPL_ICMP_handler	;int16	cdecl	(* ICMP_handler) (int16 cdecl (*) (IP_DGRAM *), int16);
	func_p	TPL_ICMP_discard	;void	cdecl	(* ICMP_discard) (IP_DGRAM *);
;------- STinG extensions mid-1998 -----
	func_p	TPL_TCP_info		;int16	cdecl	(* TCP_info) (int16, TCPIB *);
	func_p	TPL_cntrl_port		;int16	cdecl	(* cntrl_port) (char *, uint32, int16);
;------- STinG extension 1999.10.01 ----
	func_p	TPL_UDP_info		;int16	cdecl	(* UDP_info) (int16, UDPIB *);
;------- STinG extension 2000.06.14 ----    /* STiK2 compatibility funcs */
	func_p	RAW_open		;int16	cdecl	(* RAW_open)(uint32);
	func_p	RAW_close		;int16	cdecl	(* RAW_close)(int16);
	func_p	RAW_out			;int16	cdecl	(* RAW_out)(int16, void *, int16, uint32);
	func_p	CN_setopt		;int16 	cdecl	(* CN_setopt)(int16, int16, const void *, int16);
	func_p	CN_getopt		;int16 	cdecl	(* CN_getopt)(int16, int16, void *, int16 *);
	func_p	CNfree_NDB		;void	cdecl	(* CNfree_NDB)(int16, NDB *);
	d_end	TPL
;----------------------------------------------------------------------------
;	Definitions of transport function macros for direct use follow
;
;	The user program must define the pointer 'tpl' and initialize
;	its value via the STiK cookie before using any TPL functions.
;----------------------------------------------------------------------------
;	Submacros are used to make the interface flexible and powerful
;
;	sub_tpl is used to implement TPL functions, and uses submacro
;	sub_sub_tpl as well as some of RA_SYS.I.  It gives argument
;	count check for all macros, and allows indirection of pointers.
;----------------------------------------------------------------------------
sub_tpl		MACRO		function,arg_count,arg_flags,arg1,arg2,arg3,arg4,arg5
		CDECL_args.\0	\3,<\4>,<\5>,<\6>,<\7>,<\8>
		sub_sub_tpl	TPL_\1
		CDECL_cleanargs	\1,\2
		ENDM		;sub_tpl
;------------------------------------
sub_sub_tpl	MACRO		tpl_function
		move.l		tpl,a0
		move.l		\1(a0),a0
		jsr		(a0)
		ENDM		;sub_sub_tpl
;----------------------------------------------------------------------------
KRmalloc	MACRO		size
		sub_tpl		KRmalloc,1,2,<\1>
		ENDM
;------------------------------------
KRfree		MACRO		block_p
		sub_tpl.\0	KRfree,1,3,<\1>
		ENDM
;------------------------------------
KRgetfree	MACRO		mode_f
		sub_tpl		KRgetfree,1,1,<\1>
		ENDM
;------------------------------------
KRrealloc	MACRO		block_p,size
		sub_tpl.\0	KRrealloc,2,$B,<\1>,<\2>
		ENDM
;------------------------------------
get_err_text	MACRO		err_code
		sub_tpl		get_err_text,1,1,<\1>
		ENDM
;------------------------------------
getvstr		MACRO		varname_p
		sub_tpl.\0	getvstr,1,3,<\1>
		ENDM
;------------------------------------
carrier_detect	MACRO	
		sub_tpl		carrier_detect,0,0
		ENDM
;------------------------------------
TCP_open	MACRO		remote_IP,protoport,tos,obuff_size
		sub_tpl		TCP_open,4,$56,<\1>,<\2>,<\3>,<\4>
		ENDM
;------------------------------------
TCP_close	MACRO		cn_handle,timeout_sec_mode,result_p
		sub_tpl.\0	TCP_close,3,$35,<\1>,<\2>,<\3>
		ENDM
;------------------------------------
TCP_send	MACRO		cn_handle,data_p,datalen
		sub_tpl.\0	TCP_send,3,$1D,<\1>,<\2>,<\3>
		ENDM
;------------------------------------
TCP_wait_state	MACRO		cn_handle,state,timeout_sec
		sub_tpl		TCP_wait_state,3,$15,<\1>,<\2>,<\3>
		ENDM
;------------------------------------
TCP_ack_wait	MACRO		cn_handle,timeout_ms
		sub_tpl		TCP_ack_wait,2,$5,<\1>,<\2>
		ENDM
;------------------------------------
UDP_open	MACRO		remote_IP,remote_port
		sub_tpl		UDP_open,2,$6,<\1>,<\2>
		ENDM
;------------------------------------
UDP_close	MACRO		cn_handle
		sub_tpl		UDP_close,1,1,<\1>
		ENDM
;------------------------------------
UDP_send	MACRO		cn_handle,data_p,datalen
		sub_tpl.\0	UDP_send,3,$1D,<\1>,<\2>,<\3>
		ENDM
;------------------------------------
CNkick		MACRO		cn_handle
		sub_tpl		CNkick,1,1,<\1>
		ENDM
;------------------------------------
CNbyte_count	MACRO		cn_handle
		sub_tpl		CNbyte_count,1,1,<\1>
		ENDM
;------------------------------------
CNget_char	MACRO		cn_handle
		sub_tpl		CNget_char,1,1,<\1>
		ENDM
;------------------------------------
CNget_NDB	MACRO		cn_handle
		sub_tpl		CNget_NDB,1,1,<\1>
		ENDM
;------------------------------------
CNget_block	MACRO		cn_handle,buff_p,bufflen
		sub_tpl.\0	CNget_block,3,$1D,<\1>,<\2>,<\3>
		ENDM
;------------------------------------
CNgetinfo	MACRO		cn_handle
		sub_tpl		CNgetinfo,1,1,<\1>
		ENDM
;------------------------------------
CNgets		MACRO		cn_handle,buff_p,bufflen,delim_ch
		sub_tpl.\0	CNgets,4,$1D,<\1>,<\2>,<\3>,<\4>
		ENDM
;------------------------------------
housekeep	MACRO
		sub_tpl	housekeep,0,0
		ENDM
;------------------------------------
resolve		MACRO		search_p,real_p_p,IP_list_p,list_len
		sub_tpl.\0	resolve,4,$7F,<\1>,<\2>,<\3>,<\4>
		ENDM
;------------------------------------
ser_disable	MACRO
		sub_tpl		ser_disable,0,0
		ENDM
;------------------------------------
ser_enable	MACRO
		sub_tpl		ser_enable,0,0
		ENDM
;------------------------------------
set_flag	MACRO		flag_index
		sub_tpl		set_flag,1,1,<\1>
		ENDM
;------------------------------------
clear_flag	MACRO	flag_index
		sub_tpl	clear_flag,1,1,<\1>
		ENDM
;------------------------------------
on_port		MACRO		char_p
		sub_tpl.\0	on_port,1,3,<\1>
		ENDM
;------------------------------------
off_port	MACRO		char_p
		sub_tpl.\0	off_port,1,3,<\1>
		ENDM
;------------------------------------
setvstr		MACRO		varname_p,valuestring_p
		sub_tpl.\0	setvstr,2,$F,<\1>,<\2>
		ENDM
;------------------------------------
query_port	MACRO		char_p
		sub_tpl.\0	query_port,1,3,<\1>
		ENDM
;------------------------------------
ICMP_send	MACRO		remote_IP,type,code,data_p,datalen
		sub_tpl.\0	ICMP_send,5,$182,<\1>,<\2>,<\3>,<\4>,<\5>
		ENDM
;------------------------------------
ICMP_handler	MACRO		handler_p,install_code
		sub_tpl.\0	ICMP_handler,2,7,<\1>,<\2>
		ENDM
;------------------------------------
ICMP_discard	MACRO		dgram_p
		sub_tpl.\0	ICMP_discard,1,3,<\1>
		ENDM
;------------------------------------
TCP_info	MACRO		cn_handle,TCPIB_p
		sub_tpl.\0	TCP_info,2,$D,<\1>,<\2>
		ENDM
;------------------------------------
cntrl_port	MACRO		portname_p,long_arg,opcode
		sub_tpl.\0	cntrl_port,3,$1B,<\1>,<\2>,<\3>
		ENDM
;------------------------------------
UDP_info	MACRO		cn_handle,UDPIB_p
		sub_tpl.\0	UDP_info,2,$D,<\1>,<\2>
		ENDM
;------------------------------------
RAW_open	MACRO		rhost
		sub_tpl		RAW_open,1,$2,<\1>
		ENDM
;------------------------------------
RAW_close	MACRO		cn_handle
		sub_tpl		RAW_close,1,$1,cn_handle
		ENDM
;------------------------------------
RAW_out		MACRO		cn_handle,dptr,dlen,dest
		sub_tpl.\0	RAW_out,4,$9D,<\1>,<\2>,<\3>,<\4>
		ENDM
;------------------------------------
CN_setopt	MACRO		cn_handle,opt_id,optval_p,optlen
		sub_tpl.\0	CN_setopt,4,$75,<\1>,<\2>,<\3>,<\4>
		ENDM
;------------------------------------
CN_getopt.mode	MACRO		cn_handle,opt_id,optval_p,optlen_p
		sub_tpl.\0	CN_getopt,4,$F5,<\1>,<\2>,<\3>,<\4>
		ENDM
;------------------------------------
CNfree_NDB	MACRO		cn_handle,NDB_p
		sub_tpl.\0	CNfree_NDB,2,$D,<\1>,<\2>
		ENDM
;----------------------------------------------------------------------------
;		Error return values
;
E_NORMAL	=	0	; No error occured ...
E_OBUFFULL	=	-1	; Output buffer is full
E_NODATA	=	-2	; No data available
E_EOF		=	-3	; EOF from remote
E_RRESET	=	-4	; Reset received from remote
E_UA		=	-5	; Unacceptable packet received, reset
E_NOMEM		=	-6	; Something failed due to lack of memory
E_REFUSE	=	-7	; Connection refused by remote
E_BADSYN	=	-8	; A SYN was received in the window
E_BADHANDLE	=	-9	; Bad connection handle used.
E_LISTEN	=	-10	; The connection is in LISTEN state
E_NOCCB		=	-11	; No free CCB's available
E_NOCONNECTION	=	-12	; No connection matches this packet (TCP)
E_CONNECTFAIL	=	-13	; Failure to connect to remote port (TCP)
E_BADCLOSE	=	-14	; Invalid TCP_close() requested
E_USERTIMEOUT	=	-15	; A user function timed out
E_CNTIMEOUT	=	-16	; A connection timed out
E_CANTRESOLVE	=	-17	; Can't resolve the hostname
E_BADDNAME	=	-18	; Domain name or dotted dec. bad format
E_LOSTCARRIER	=	-19	; The modem disconnected
E_NOHOSTNAME	=	-20	; Hostname does not exist
E_DNSWORKLIMIT	=	-21	; Resolver Work limit reached
E_NONAMESERVER	=	-22	; No nameservers could be found for query
E_DNSBADFORMAT	=	-23	; Bad format of DS query
E_UNREACHABLE	=	-24	; Destination unreachable
E_DNSNOADDR	=	-25	; No address records exist for host
E_NOROUTINE	=	-26	; Routine unavailable
E_LOCKED	=	-27	; Locked by another application
E_FRAGMENT	=	-28	; Error during fragmentation
E_TTLEXCEED	=	-29	; Time To Live of an IP packet exceeded
E_PARAMETER	=	-30	; Problem with a parameter
E_BIGBUF	=	-31	; Input buffer is too small for data
E_FNAVAIL	=	-32	; Function not available
E_LASTERROR	=	32	; ABS of last error code in this list
;----------------------------------------------------------------------------
	endc	;STinG_TRANSPRT_defined
;----------------------------------------------------------------------------
; End of file:	TRANSPRT.I
;----------------------------------------------------------------------------
