;----------------------------------------------------------------------------
; File name:	SOCKET.I			Revision date:	2000.07.17
; Author:	Ronald Andersson		Creation date:	2000.07.17
;----------------------------------------------------------------------------
; Purpose:	Define socket related data and structs for use in porting
;		socket based software to STinG assembly programs.
;----------------------------------------------------------------------------
; Credits:	Based largely on info in socket.h by Kay Roemer.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;-------------------------------------
	ifnd	STinG_SOCKET_defined
STinG_SOCKET_defined	set	1
;----------------------------------------------------------------------------
;	Address families
;-------------------------------------
AF_UNSPEC	= 0
AF_UNIX		= 1
AF_INET		= 2
AF_APPLETALK	= 5
AF_LINK		= 200
;----------------------------------------------------------------------------
;	Socket types
;-------------------------------------
SOCK_STREAM	= 1
SOCK_DGRAM	= 2
SOCK_RAW	= 3
SOCK_RDM	= 4
SOCK_SEQPACKET	= 5
;----------------------------------------------------------------------------
;	Protocol families
;-------------------------------------
PF_UNSPEC	= 0
PF_UNIX		= 1
PF_INET		= 2
PF_APPLETALK	= 5
;----------------------------------------------------------------------------
;	Flags for send/recv
;-------------------------------------
MSG_OOB		= $0001
MSG_PEEK	= $0002
MSG_DONTROUTE	= $0004
;----------------------------------------------------------------------------
;	Levels for [s|g]etsockopt
;-------------------------------------
SOL_SOCKET	= $ffff
;----------------------------------------------------------------------------
;	Options for [s|g]etsockopt
;-------------------------------------
SO_DEBUG	= 1
SO_REUSEADDR	= 2
SO_TYPE		= 3
SO_ERROR	= 4
SO_DONTROUTE	= 5
SO_BROADCAST	= 6
SO_SNDBUF	= 7
SO_RCVBUF	= 8
SO_KEEPALIVE	= 9
SO_OOBINLINE	= 10
SO_LINGER	= 11
SO_CHKSUM	= 40
SO_DROPCONN	= 41
;----------------------------------------------------------------------------
;	Structure used for SO_LINGER
;-------------------------------------
	struct linger
	int32		l_onoff
	int32		l_linger
	d_end	linger
;----------------------------------------------------------------------------
;	Generic socket address
;-------------------------------------
	struct sockaddr
	int16		sa_family
	char		sa_data,14
	d_end	sockaddr
;----------------------------------------------------------------------------
;	Structure for scatter/gather io
;-------------------------------------
	struct iovec
	void_p		iov_base
	uint32		iov_len
	d_end	iovec
;----------------------------------------------------------------------------
;	Structure describing a message used with sendmsg/recvmsg
;-------------------------------------
	struct msghdr
	void_p		msg_name
	uint32		msg_namelen
	struc_p		msg_iov			;-> iovec struct
	uint32		msg_iovlen
	void_p		msg_accrights
	uint32		msg_accrightslen
	d_end	msghdr
;----------------------------------------------------------------------------
;	stucture used for DNS results
;-------------------------------------
	struct	hostent
	char_p	h_name
	char_pp	h_aliases
	int16	h_addrtype
	int16	h_length
	char_pp	h_addr_list
	d_end	hostent
;----------------------------------------------------------------------------
;	socket io functions of MintNet
;-------------------------------------
;__EXTERN int	socket		__PROTO((int, int, int));
;__EXTERN int	socketpair	__PROTO((int, int, int, int[2]));
;__EXTERN int	bind		__PROTO((int, struct sockaddr *, _SIZE_T));
;__EXTERN int	listen		__PROTO((int, int));
;__EXTERN int	accept		__PROTO((int, struct sockaddr *, _SIZE_T *)); 
;__EXTERN int	connect		__PROTO((int, struct sockaddr *, _SIZE_T));
;__EXTERN int	getsockname	__PROTO((int, struct sockaddr *, _SIZE_T *));
;__EXTERN int	getpeername	__PROTO((int, struct sockaddr *, _SIZE_T *));
;__EXTERN int	send		__PROTO((int, void *, _SIZE_T, int));
;__EXTERN int	sendto		__PROTO((int, void *, _SIZE_T, int,
;					struct sockaddr *, _SIZE_T));
;__EXTERN int	recv		__PROTO((int, void *, _SIZE_T, int));
;__EXTERN int	recvfrom	__PROTO((int, void *, _SIZE_T, int,
;					struct sockaddr *, _SIZE_T *));
;__EXTERN int	setsockopt	__PROTO((int, int, int, void *, _SIZE_T));
;__EXTERN int	getsockopt	__PROTO((int, int, int, void *, _SIZE_T *));
;__EXTERN int	shutdown	__PROTO((int, int));
;__EXTERN int	sendmsg		__PROTO((int, struct msghdr *, int));
;__EXTERN int	recvmsg		__PROTO((int, struct msghdr *, int));
;----------------------------------------------------------------------------
	endc	;STinG_SOCKET_defined
;----------------------------------------------------------------------------
; End of file:	SOCKET.I
;----------------------------------------------------------------------------
