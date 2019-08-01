;----------------------------------------------------------------------------
; File name:	DRGLOBAL.I			Revision date:	2000.07.17
; Author:	Ronald Andersson		Creation date:	2000.07.17
;----------------------------------------------------------------------------
; Purpose:	Define Draconis global data and structs for use in porting
;		Draconis based software to STinG assembly programs.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	STinG_DRGLOBAL_defined
STinG_DRGLOBAL_defined	set	1
;----------------------------------------------------------------------------
	include	ra_tos.i
	include	ra_jar.i
;-------
	include	sting\transprt.i
	include	sting\layer.i
	include	sting\port.i
	include	sting\domain.i
	include	sting\bsd\socket.i
	include	sting\bsd\in.i
	include sting\drac\dracopts.i
;----------------------------------------------------------------------------
	struct	TIME_VAL
	long	tv_sec		;seconds
	long	tv_usec		;microseconds
	d_end	TIME_VAL
;----------------------------------------------------------------------------
	struct	DR_sock
;-------
	struc_p	DRS_next	;-> next DR_sock in list
	struc_p	DRS_owner	;-> basepage of socket owner
	int16	DRS_sfd		;socket file descriptor
;-------
	d_alias	DRS_state_l	;uint32 alias for the four bytes below
	d_alias	DRS_state_w	;uint16 alias for the two bytes below
	int8	DRS_state0	;state0 flags for fast testing
	int8	DRS_state1	;state1 flags for fast testing
	d_alias	DRS_DR_state	;word alias for the two bytes below
	int8	DRS_state2	;state2 flags for fast testing
	int8	DRS_state3	;state3 flags for fast testing
;-------
	int16	DRS_conn	;STinG connection handle (NULL == unconnected)
	s_struc	DRS_CAB,CAB	;STinG CAB struct for opening connection
	struc_p	DRS_CIB_p	;-> STinG CIB struct of connection
	int16	DRS_last_err	;last STinG error code
;-------
	int16	DRS_domain	;\
	int16	DRS_type	; > Parameters from socket creation
	int16	DRS_proto	;/
;-------
	uint32	DRS_max_xfer	;maximum size per DR_send etc
	int16	DRS_max_buff	;maximum send per send_c
;-------
	d_alias	DRS_listener	;for accept sock: -> listen sock
	int16	DRS_back_max	;for listen sock: max backed accept socks
	int16	DRS_back_cnt	;for listen sock: backed accept socks now
	struc_p	DRS_backlist	;-> next backed accept sock
;-------
	d_end	DR_sock
;----------------------------------------------------------------------------
;	Flag bits for DRS_state0:
;-------------------------------------
SS0_b_opened	=	0	;STinG connection has been opened
;-------------------------------------
;	Flag bits for DRS_state1:
;-------------------------------------
SS1_b_connected	=	0	;connected by DR_connect or DR_accept
SS1_b_bound	=	1	;bound by DR_bind, DR_connect, or DR_accept
SS1_b_listening	=	2	;DR_listen has been used for this socket
SS1_b_unaccepted =	3	;this is an accept socket not yet accepted
SS1_b_maxlisten	=	4	;listener has max backed unaccepted sockets
;-------
;	byte values for DRS_state1
;-------
SS1_UNACCEPTED	=	%01011
SS1_ACCEPTED	=	%00011
;-------
;	word values for DRS_state0 and DRS_state1 as word DRS_state_w
;-------
SSW_NEWLISTEN	=	%00110
SSW_MAXLISTEN	=	%10110
;-------------------------------------
;	Flag bits for DRS_state2:
;-------------------------------------
SS2_b_NONBLOCK	=	3
;-------------------------------------
;	Flag bits for DRS_state3:
;-------------------------------------
;-------------------------------------
;	Flag words for DRS_DR_state
;-------------------------------------
SO_O_NONBLOCK	= (1<<(8+SS2_b_NONBLOCK))
;----------------------------------------------------------------------------
DRACONIS_ID	= 'ICIP'
FREECOOKIE	= 'FREE'
;----------------------------------------------------------------------------
;	Extended Error values
;-------------------------------------
;	some codes in this range are used undocumented
;-------
;-------------------------------------
E_DR_INVSFD	= -9	;Invalid socket file descriptor
E_DR_AGAIN	= -11	;Do it again
;-------------------------------------
;	some codes in this range are used undocumented
;-------
E_DR_BADPARAM	= -22	;
E_DR_MANYSOCKS	= -23	;Too many sockets are already active
;-------------------------------------
E_DR_PROTO	= -71	;Protocol error
E_DR_NOTSOCK	= -88	;Not a valid socket
E_DR_OPNOTSUPP	= -95	;Operation not supported
E_DR_ADDRINUSE	= -98	;address is already in use
E_DR_NOBUFS	= -105	;some buffer alloc failed
E_DR_ISCONN	= -106	;socket is already connected
E_DR_NOTCONN	= -107	;socket is not connected
E_DR_ALREADY	= -114	;operation in progress
E_DR_INPROGRESS	= -115	;operation started
;----------------------------------------------------------------------------
	endc	;STinG_DRGLOBAL_defined
;----------------------------------------------------------------------------
; End of file:	DRGLOBAL.I
;----------------------------------------------------------------------------
