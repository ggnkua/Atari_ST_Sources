;----------------------------------------------------------------------------
; File name:	MINTSOCK.I			Revision date:	2000.07.17
; Author:	Ronald Andersson		Creation date:	2000.07.17
;----------------------------------------------------------------------------
; Purpose:	Define socket 'ioctl' data and structs for use in porting
;		socket based software to STinG assembly programs.
;----------------------------------------------------------------------------
; Credits:	Based largely on info in mintsock.h by Kay Roemer.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	STinG_MINTSOCK_defined
STinG_MINTSOCK_defined	set	1
;----------------------------------------------------------------------------
SOCKETCALL	= (('S'<<8)|100)
;----------------------------------------------------------------------------
;	socket cmd names, passed in the `cmd' field of *_cmd structs
;-------------------------------------
	d_start	so_cmd,0	;simulated 'enum' starting at 0
	byte	SOCKET_CMD
	byte	SOCKETPAIR_CMD
	byte	BIND_CMD
	byte	LISTEN_CMD
	byte	ACCEPT_CMD
	byte	CONNECT_CMD
	byte	GETSOCKNAME_CMD
	byte	GETPEERNAME_CMD
	byte	SEND_CMD
	byte	SENDTO_CMD
	byte	RECV_CMD
	byte	RECVFROM_CMD
	byte	SETSOCKOPT_CMD
	byte	GETSOCKOPT_CMD
	byte	SHUTDOWN_CMD
	byte	SENDMSG_CMD
	byte	RECVMSG_CMD
	d_end	so_cmd
;----------------------------------------------------------------------------
;	used to extract the `cmd' field from the *_cmd structs
;-------------------------------------
	struct generic_cmd
	short	scmd_cmd;
	char	scmd_data,10;
	d_end	generic_cmd
;----------------------------------------------------------------------------
;	structures passed to the SOCKETCALL ioctl() as an argument
;-------------------------------------
	struct	socket_cmd
	d_phase	scmd_data
	int16	scmd_domain;
	int16	scmd_type;
	int16	scmd_protocol;
	d_end	socket_cmd
;-------------------------------------
	struct	socketpair_cmd
	d_phase	sizeof_socket_cmd
	d_end	socketpair_cmd
;-------------------------------------
	struct	bind_cmd
	d_phase	scmd_data
	void_p	scmd_addr;
	int16	scmd_addrlen;
	d_end	bind_cmd
;-------------------------------------
	struct	listen_cmd
	d_phase	scmd_data
	int16	scmd_backlog;
	d_end	listen_cmd
;-------------------------------------
	struct	accept_cmd
	d_phase	sizeof_bind_cmd
	d_end	accept_cmd
;-------------------------------------
	struct	connect_cmd
	d_phase	sizeof_bind_cmd
	d_end	connect_cmd
;-------------------------------------
	struct	getsockname_cmd
	d_phase	sizeof_bind_cmd
	d_end	getsockname_cmd
;-------------------------------------
	struct	getpeername_cmd
	d_phase	sizeof_bind_cmd
	d_end	getpeername_cmd
;-------------------------------------
	struct	send_cmd
	d_phase	scmd_data
	char_p	scmd_buf;
	int32	scmd_buflen;
	int16	scmd_flags;
	d_end	send_cmd
;-------------------------------------
	struct	sendto_cmd
	d_phase	sizeof_send_cmd
	void_p	scmd_rem_addr;
	int16	scmd_rem_addrlen;
	d_end	sendto_cmd
;-------------------------------------
	struct	recv_cmd
	d_phase	sizeof_send_cmd
	d_end	recv_cmd
;-------------------------------------
	struct	recvfrom_cmd
	d_phase	sizeof_sendto_cmd
	d_end	recvfrom_cmd
;-------------------------------------
	struct	setsockopt_cmd
	d_phase	scmd_data
	int16	scmd_level;
	int16	scmd_optname;
	void_p	scmd_optval;
	int32	scmd_setoptlen;
	d_end	setsockopt_cmd
;-------------------------------------
	struct	getsockopt_cmd
	d_phase	scmd_setoptlen
	int32_p	scmd_getoptlen;
	d_end	getsockopt_cmd
;-------------------------------------
	struct	shutdown_cmd
	d_phase	scmd_data
	int16	scmd_how;
	d_end	shutdown_cmd
;-------------------------------------
	struct	sendmsg_cmd
	d_phase	scmd_data
	void_p	scmd_msg;
	int16	scmd_flags;
	d_end	sendmsg_cmd
;-------------------------------------
	struct	recvmsg_cmd
	d_phase	sizeof_sendmsg_cmd
	d_end	recvmsg_cmd
;----------------------------------------------------------------------------
	endc	;STinG_MINTSOCK_defined
;----------------------------------------------------------------------------
; End of file:	MINTSOCK.I
;----------------------------------------------------------------------------
