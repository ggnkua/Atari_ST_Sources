;----------------------------------------------------------------------------
; File name:	ICGLOBAL.I			Revision date:	2000.08.13
; Author:	Ronald Andersson		Creation date:	2000.08.13
;----------------------------------------------------------------------------
; Purpose:	Define Draconis global data and structs for use in porting
;		Draconis based software to STinG assembly programs.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	STinG_ICGLOBAL_defined
STinG_ICGLOBAL_defined	set	1
;----------------------------------------------------------------------------
	include	RA_ERR.I
;----------------------------------------------------------------------------
	struct	TIME_VAL
	long	tv_sec		;seconds
	long	tv_usec		;microseconds
	d_end	TIME_VAL
;----------------------------------------------------------------------------
	struct	EM_sock
;-------
	struc_p	EMS_next	;-> next EM_sock in list
	struc_p	EMS_owner	;-> basepage of socket owner
	int16	EMS_sfd		;socket file descriptor
;-------
	d_alias	EMS_state_l	;uint32 alias for the four bytes below
	d_alias	EMS_state_w	;uint16 alias for the two bytes below
	int8	EMS_state0	;state0 flags for fast testing
	int8	EMS_state1	;state1 flags for fast testing
	d_alias	EMS_EM_state	;word alias for the two bytes below
	int8	EMS_state2	;state2 flags for fast testing
	int8	EMS_state3	;state3 flags for fast testing
;-------
	int16	EMS_conn	;STinG connection handle (NULL == unconnected)
	s_struc	EMS_CAB,CAB	;STinG CAB struct for opening connection
	struc_p	EMS_CIB_p	;-> STinG CIB struct of connection
	int16	EMS_last_err	;last STinG error code
;-------
	int16	EMS_domain	;\
	int16	EMS_type	; > Parameters from socket creation
	int16	EMS_proto	;/
;-------
	uint32	EMS_max_xfer	;maximum size per xx_send etc
	int16	EMS_max_buff	;maximum send per send_c
;-------
	d_alias	EMS_listener	;for accept sock: -> listen sock
	int16	EMS_back_max	;for listen sock: max backed accept socks
	int16	EMS_back_cnt	;for listen sock: backed accept socks now
	struc_p	EMS_backlist	;-> next backed accept sock
;-------
	d_end	EM_sock
;----------------------------------------------------------------------------
;	Flag bits for EMS_state0:
;-------------------------------------
SS0_b_opened	=	0	;STinG connection has been opened
;-------------------------------------
;	Flag bits for EMS_state1:
;-------------------------------------
SS1_b_connected	=	0	;connected by xx_connect or xx_accept
SS1_b_bound	=	1	;bound by xx_bind, xx_connect, or xx_accept
SS1_b_listening	=	2	;xx_listen has been used for this socket
SS1_b_unaccepted =	3	;this is an accept socket not yet accepted
SS1_b_maxlisten	=	4	;listener has max backed unaccepted sockets
;-------
;	byte values for EMS_state1
;-------
SS1_UNACCEPTED	=	%01011
SS1_ACCEPTED	=	%00011
;-------
;	word values for EMS_state0 and EMS_state1 as word EMS_state_w
;-------
SSW_NEWLISTEN	=	%00110
SSW_MAXLISTEN	=	%10110
;-------------------------------------
;	Flag bits for EMS_state2:
;-------------------------------------
SS2_b_NONBLOCK	=	3
;-------------------------------------
;	Flag bits for EMS_state3:
;-------------------------------------
;-------------------------------------
;	Flag words for EMS_EM_state
;-------------------------------------
SO_O_NONBLOCK	= (1<<(8+SS2_b_NONBLOCK))
;----------------------------------------------------------------------------
DRACONIS_ID	= 'ICIP'
ICONNECT_ID	= 'SLIP'
FREECOOKIE	= 'FREE'
;----------------------------------------------------------------------------
;	Extended Error values
;-------------------------------------
E_IC_NOTSOCK	= -300	;Not a valid socket
E_IC_INVSFD	= E_IC_NOTSOCK
E_IC_OPNOTSUPP	= -307	;Operation not supported
E_IC_ADDRINUSE	= -310	;address is already in use
E_IC_ISCONN	= -317	;socket is already connected
E_IC_NOTCONN	= -318	;socket is not connected
E_IC_ALREADY	= -324	;operation in progress
E_IC_INPROGRESS	= -325	;operation started
E_IC_AGAIN	= -326	;Do it again.  This is NOT an error.
E_IC_WOULDBLOCK	= E_IC_AGAIN
;-------------------------------------
E_IC_BADPARAM	= E_ERROR	;Some parameter was bad
E_IC_MANYSOCKS	= E_NHNDL	;too mamy sockets in use
E_IC_PROTO	= E_ERROR	;Protocol error
E_IC_NOBUFS	= E_NSMEM	;some buffer alloc failed
;-------------------------------------
E_IC_INTR		= -128	;System call was interrupted.  Not an error
E_IC_DESTADDRREQ	= -301	;Destination address required
E_IC_MSGSIZE		= -302	;Message too long
E_IC_PROTOTYPE		= -303	;wrong protocol for socket
E_IC_NOPROTOOPT		= -304	;protocol not available
E_IC_PROTONOSUPPORT	= -305	;protocol not suppoprted
E_IC_SOCKTNOSUPPORT	= -306	;socket type not supported
E_IC_PFNOSUPPORT	= -308	;protocol family not supported
E_IC_AFNOSUPPORT	= -309	;address family not supported
E_IC_ADDRNOTAVAIL	= -311	;cannot assign requested address
E_IC_NETDOWN		= -312	;Network is down
E_IC_NETUNREACH		= -313	;Network is unreachable
E_IC_NETRESET		= -314	;Network dropped conn due to reset
E_IC_CONNABORTED	= -315	;software caused connection abort
E_IC_CONNRESET		= -316	;connection reset by peer
E_IC_SHUTDOWN		= -319	;cannot send after shutdown
E_IC_TIMEDOUT		= -320	;connection timed out
E_IC_CONNREFUSED	= -321	;connection refused
E_IC_HOSTDOWN		= -322	;host is down
E_IC_HOSTUNREACH	= -323	;host is unreachable
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
	endc	;STinG_ICGLOBAL_defined
;----------------------------------------------------------------------------
; End of file:	ICGLOBAL.I
;----------------------------------------------------------------------------
