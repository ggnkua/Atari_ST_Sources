;----------------------------------------------------------------------------
; File name:	IN.I				Revision date:	2000.07.23
; Author:	Ronald Andersson		Creation date:	2000.07.17
;----------------------------------------------------------------------------
; Purpose:	Define socket 'ioctl' data and structs for use in porting
;		socket based software to STinG assembly programs.
;----------------------------------------------------------------------------
; Credits:	Based largely on info (not code) in in.h for various Unices.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	STinG_IN_defined
STinG_IN_defined	set	1
;----------------------------------------------------------------------------
;	Constants and structures defined by the internet system,
;	Per RFC 790, September 1981.
;----------------------------------------------------------------------------
;	Protocols used in 'proto' parm of socket creation call etc
;-------------------------------------
IPPROTO_IP	=	0		;dummy for IP
IPPROTO_ICMP	=	1		;control message protocol
IPPROTO_GGP	=	3		;gateway^2 (deprecated)
IPPROTO_TCP	=	6		;tcp
IPPROTO_EGP	=	8		;exterior gateway protocol
IPPROTO_PUP	=	12		;pup
IPPROTO_UDP	=	17		;user datagram protocol
IPPROTO_IDP	=	22		;xns idp
IPPROTO_TP	=	29 		;tp-4 w/ class negotiation
IPPROTO_EON	=	80		;ISO cnlp
;-------------------------------------
IPPROTO_RAW	=	255		;raw IP packet
IPPROTO_MAX	=	256
;----------------------------------------------------------------------------
;	Local port number conventions:
;	Ports < IPPORT_RESERVED are reserved for
;	privileged processes (e.g. root).
;	Ports > IPPORT_USERRESERVED are reserved
;	for servers, not necessarily privileged.
;-------------------------------------
IPPORT_RESERVED		= 1024
IPPORT_USERRESERVED	= 5000
;----------------------------------------------------------------------------
;	Internet address (a structure for historical reasons)
;-------------------------------------
	struct	in_addr
	uint32	s_addr;
	d_end	in_addr
;----------------------------------------------------------------------------
;	Definitions of bits in internet address integers.
;	On subnets, the decomposition of addresses to host and net parts
;	is done according to subnet mask, not the masks here.
;-------------------------------------
;;;IN_CLASSA(i)		(((long)(i) & $80000000) == 0)
IN_CLASSA_NET		= $ff000000
IN_CLASSA_NSHIFT	= 24
IN_CLASSA_HOST		= $00ffffff
IN_CLASSA_MAX		= 128
;-------------------------------------
;;;IN_CLASSB(i)		(((long)(i) & $c0000000) == $80000000)
IN_CLASSB_NET		= $ffff0000
IN_CLASSB_NSHIFT	= 16
IN_CLASSB_HOST		= $0000ffff
IN_CLASSB_MAX		= 65536
;-------------------------------------
;;;IN_CLASSC(i)		(((long)(i) & $e0000000) == $c0000000)
IN_CLASSC_NET		= $ffffff00
IN_CLASSC_NSHIFT	= 8
IN_CLASSC_HOST		= $000000ff
;-------------------------------------
;;;IN_CLASSD(i)		(((long)(i) & $f0000000) == $e0000000)
;;;IN_MULTICAST(i)		IN_CLASSD(i)
;-------------------------------------
;;;IN_EXPERIMENTAL(i)	(((long)(i) & $e0000000) == $e0000000)
;;;IN_BADCLASS(i)		(((long)(i) & $f0000000) == $f0000000)
;-------------------------------------
INADDR_ANY		= $00000000
INADDR_BROADCAST	= $ffffffff	;must be masked
INADDR_NONE		= $ffffffff	;-1 return
INADDR_LOOPBACK		= $7f000001
;-------------------------------------
IN_LOOPBACKNET		= 127		;official!
;----------------------------------------------------------------------------
;	Socket address, internet style.
;-------------------------------------
	struct	sockaddr_in
	int16	sin_family
	uint16	sin_port
	s_struc	sin_addr,in_addr	;really just the IP as an uint32
	char	sin_zero,8
	d_end	sockaddr_in
;----------------------------------------------------------------------------
;	Structure used to describe IP options.
;	Used to store options internally, to pass them to a process,
;	or to restore options retrieved earlier.
;	The ip_dst is used for the first-hop gateway when using a source route
;	(this gets put into the header proper).
;-------------------------------------
	struct	ip_opts
	s_struc	ipo_ip_dst,in_addr	;first hop, 0 w/o src rt
	char	ipo_ip_opts,40		;actually variable in size
	d_end	ip_opts
;----------------------------------------------------------------------------
;	Options for use with ,[gs]etsockopt at the IP level.
;	First word of comment is data type; bool is stored in int.
;-------------------------------------
IP_OPTIONS	= 1	;buf/ip_opts; set/get IP per-packet options
IP_HDRINCL	= 2	;int; header is included with data (raw)
IP_TOS		= 3	;int; IP type of service and precedence
IP_TTL		= 4	;int; IP time to live
IP_RECVOPTS	= 5	;bool; receive all IP options w/datagram
IP_RECVRETOPTS	= 6	;bool; receive IP options for response
IP_RECVDSTADDR	= 7	;bool; receive IP dst addr w/datagram
IP_RETOPTS	= 8	;ip_opts; set/get IP per-packet options
;----------------------------------------------------------------------------
	endc	;STinG_IN_defined
;----------------------------------------------------------------------------
; End of file:	IN.I
;----------------------------------------------------------------------------
