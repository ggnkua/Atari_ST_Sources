/*--------------------------------------------------------------------------*/
/*	File name:	TRANSPRT.H						Revision date:	2000.06.14	*/
/*	Revised by:	Ulf Ronald Andersson			Revision start:	1999.09.21	*/
/*	Created by:	Peter Rottengatter				Creation date:	1996.xx.xx	*/
/*--------------------------------------------------------------------------*/
/* Header file for all STinG related source files, except those of kernel.	*/
/*--------------------------------------------------------------------------*/

#ifndef STING_TRANSPRT_H
#define STING_TRANSPRT_H

/*--------------------------------------------------------------------------*/
/*	Data types used throughout STinG for portability. (here for Pure_C)		*/
/*--------------------------------------------------------------------------*/
typedef          char  int8;		/*   Signed  8 bit (char)			*/
typedef unsigned char uint8;		/* Unsigned  8 bit (byte, octet)	*/
typedef          int   int16;		/*   Signed 16 bit (int)			*/
typedef unsigned int  uint16;		/* Unsigned 16 bit (word)			*/
typedef          long  int32;		/*   Signed 32 bit					*/
typedef unsigned long uint32;		/* Unsigned 32 bit (longword)		*/
/*--------------------------------------------------------------------------*/
#ifndef	TRUE
#define	TRUE	1
#endif
#ifndef	FALSE
#define	FALSE	0
#endif

/*--------------------------------------------------------------------------*/
/*	Driver access structure / functions.									*/
/*--------------------------------------------------------------------------*/
#define	MAGIC	"STiKmagic"						/* Magic for DRV_LIST.magic	*/
#define	CJTAG	"STiK"

typedef struct drv_header
{							/* Header part of TPL structure				*/
	char *module;			/* Specific string that can be searched for	*/
	char *author;			/* Any string								*/
	char *version;			/* Format `00.00' Version:Revision			*/
}	DRV_HDR;

typedef struct drv_list
{
	char	magic[10];						/* Magic string, defd as MAGIC	*/
	DRV_HDR	*cdecl	(*get_dftab) (char *);	/* Get Driver Function Table	*/
	int16	cdecl	(*ETM_exec) (char *);	/* Execute a STinG module		*/
	void	*cfg;							/* Config structure				*/
	BASPAG	*sting_basepage;				/* STinG basepage address		*/
}	DRV_LIST;

extern DRV_LIST *drivers;

#define get_dftab(x)	(*drivers->get_dftab)(x)
#define ETM_exec(x)		(*drivers->ETM_exec)(x)

#define	TRANSPORT_DRIVER	"TRANSPORT_TCPIP"
#define	TCP_DRIVER_VERSION	"01.00"

/*----------------------------------*/
/*	TCP and UDP port escape flags.	*/
/*----------------------------------*/
#define	TCP_ACTIVE		0x0000	/* Initiate active connection	*/
#define	TCP_PASSIVE		0xffff	/* Initiate passive connection	*/
#define  UDP_EXTEND		0x0000	/* Extended addressing scheme	*/

/*----------------------------------*/
/*	TCP miscellaneous flags.		*/
/*----------------------------------*/
#define  TCP_URGENT			((void *) -1)	/* Mark urgent position		*/
#define  TCP_HALFDUPLEX		(-1)			/* TCP_close() half duplex	*/
#define  TCP_IMMEDIATE		(0)				/* TCP_close() immediate	*/

/*----------------------------------*/
/*	TCP connection states.			*/
/*----------------------------------*/
#define	TCLOSED		0	/* No connection.  Null, void, absent, ...		*/
#define	TLISTEN		1	/* Wait for remote request						*/
#define	TSYN_SENT	2	/* Connect request sent, await matching request	*/
#define	TSYN_RECV	3	/* Wait for connection ack						*/
#define	TESTABLISH	4	/* Connection established, handshake completed	*/
#define	TFIN_WAIT1	5	/* Await termination request or ack				*/
#define	TFIN_WAIT2	6	/* Await termination request					*/
#define	TCLOSE_WAIT	7	/* Await termination request from local user	*/
#define	TCLOSING	8	/* Await termination ack from remote TCP		*/
#define	TLAST_ACK	9	/* Await ack of terminate request sent			*/
#define	TTIME_WAIT	10	/* Delay, ensures remote has received term' ack	*/
/*----------------------------------*/
/*	UDP connection pseudo states.	*/
/*----------------------------------*/
#define	UCLOSED		0	/* No connection.  Null, void, absent, ...		*/
#define	ULISTEN		1	/* Wait for remote request						*/
#define	UESTABLISH	4	/* Connection established, packet received/sent	*/
/*--------------------------------------------------------------------------*/
/*	TCP information block.													*/
/*--------------------------------------------------------------------------*/
typedef struct tcpib
{	uint32	request;	/* 32 bit flags requesting various info (following)	*/
	uint16	state;		/* current TCP state 								*/
	uint32	unacked;	/* unacked outgoing sequence length (incl SYN/FIN)	*/
	uint32	srtt;		/* smoothed round trip time of this connection		*/
}	TCPIB;

#define	TCPI_state		0x00000001L	/* request current TCP state			*/
#define	TCPI_unacked	0x00000002L	/* request length of unacked sequence	*/
#define	TCPI_srtt		0x00000004L	/* request smoothed round trip time		*/
#define	TCPI_defer		0x00000008L	/* request switch to DEFER mode			*/

#define TCPI_bits		4			/* The number of bits which are defined	*/
#define	TCPI_mask		0x0000000FL	/* current sum of defined request bits	*/
/*--------------------------------------------------------------------------*/
/* NB: A TCP_info request using undefined bits will result in E_PARAMETER.	*/
/*     else the return value will be TCPI_bits, so user knows what we have.	*/
/*     Future additions will use rising bits in sequence, and additions to	*/
/*     the TCPIB struct will always be made at its previous end.			*/
/*--------------------------------------------------------------------------*/
/* !!! By TCP_info with TCPI_defer, connection is switched to 'DEFER' mode.	*/
/*     This means that all situations where internal looping would occur	*/
/*     will instead lead to exit to the caller with return value E_LOCKED.	*/
/*     Using this mode constitutes agreement to always check for that error	*/
/*     code, which is mainly used for connections using DEFER mode. It may	*/
/*     also be used in some other instances, where a function is blocked in	*/
/*     such a way that internal looping is not possible.					*/
/*--------------------------------------------------------------------------*/
/*	UDP information block.													*/
/*--------------------------------------------------------------------------*/
typedef struct udpib
{	uint32	request;	/* 32 bit flags requesting various info (following)	*/
	uint16	state;		/* current UDP pseudo state 						*/
	uint32	reserve1;	/* reserved */
	uint32	reserve2;	/* reserved */
}	UDPIB;

#define	UDPI_state		0x00000001L	/* request current UDP pseudo state		*/
#define	UDPI_reserve1	0x00000002L	/* reserved	*/
#define	UDPI_reserve2	0x00000004L	/* reserved */
#define	UDPI_defer		0x00000008L	/* request switch to DEFER mode			*/

#define UDPI_bits		4			/* The number of bits which are defined	*/
#define	UDPI_mask		0x0000000FL	/* current sum of defined request bits	*/
/*--------------------------------------------------------------------------*/
/* NB: A UDP_info request using undefined bits will result in E_PARAMETER.	*/
/*     else the return value will be UDPI_bits, so user knows what we have.	*/
/*     Future additions will use rising bits in sequence, and additions to	*/
/*     the UDPIB struct will always be made at its previous end.			*/
/*--------------------------------------------------------------------------*/
/* !!! By UDP_info with UDPI_defer, connection is switched to 'DEFER' mode.	*/
/*     This means that all situations where internal looping would occur	*/
/*     will instead lead to exit to the caller with return value E_LOCKED.	*/
/*     Using this mode constitutes agreement to always check for that error	*/
/*     code, which is mainly used for connections using DEFER mode.	It may	*/
/*     also be used in some other instances, where a function is blocked in	*/
/*     such a way that internal looping is not possible.					*/
/*--------------------------------------------------------------------------*/
/*	Buffer for inquiring port names.										*/
/*--------------------------------------------------------------------------*/
typedef	struct	pnta
{	uint32	opaque;			/* Kernel internal data			*/
	int16	name_len;		/* Length of port name buffer	*/
	char	*port_name;		/* Buffer address				*/
}	PNTA;
/*--------------------------------------------------------------------------*/
/*	Command opcodes for cntrl_port().										*/
/*--------------------------------------------------------------------------*/
#define	CTL_KERN_FIRST_PORT		(('K' << 8) | 'F')   /* Kernel            */
#define	CTL_KERN_NEXT_PORT		(('K' << 8) | 'N')   /* Kernel            */
#define	CTL_KERN_FIND_PORT		(('K' << 8) | 'G')   /* Kernel            */

#define	CTL_GENERIC_SET_IP		(('G' << 8) | 'H')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_IP		(('G' << 8) | 'I')   /* Kernel, all ports */
#define	CTL_GENERIC_SET_MASK	(('G' << 8) | 'L')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_MASK	(('G' << 8) | 'M')   /* Kernel, all ports */
#define	CTL_GENERIC_SET_MTU		(('G' << 8) | 'N')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_MTU		(('G' << 8) | 'O')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_MMTU	(('G' << 8) | 'P')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_TYPE	(('G' << 8) | 'T')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_STAT	(('G' << 8) | 'S')   /* Kernel, all ports */
#define	CTL_GENERIC_CLR_STAT	(('G' << 8) | 'C')   /* Kernel, all ports */

#define	CTL_SERIAL_SET_PRTCL	(('S' << 8) | 'P')   /* Serial Driver     */
#define	CTL_SERIAL_GET_PRTCL	(('S' << 8) | 'Q')   /* Serial Driver     */
#define	CTL_SERIAL_SET_LOGBUFF	('S' << 8 | 'L')     /* Serial Driver     */
#define	CTL_SERIAL_SET_LOGGING	('S' << 8 | 'F')     /* Serial Driver     */
#define	CTL_SERIAL_SET_AUTH		(('S' << 8) | 'A')   /* Serial Driver     */
#define	CTL_SERIAL_SET_PAP		(('S' << 8) | 'B')   /* Serial Driver     */
#define	CTL_SERIAL_INQ_STATE	(('S' << 8) | 'S')   /* Serial Driver     */

#define	CTL_ETHER_SET_MAC		(('E' << 8) | 'M')   /* EtherNet          */
#define	CTL_ETHER_GET_MAC		(('E' << 8) | 'N')   /* EtherNet          */
#define	CTL_ETHER_INQ_SUPPTYPE	(('E' << 8) | 'Q')   /* EtherNet          */
#define	CTL_ETHER_SET_TYPE		(('E' << 8) | 'T')   /* EtherNet          */
#define	CTL_ETHER_GET_TYPE		(('E' << 8) | 'U')   /* EtherNet          */

#define	CTL_MASQUE_SET_PORT		(('M' << 8) | 'P')   /* Masquerade        */
#define	CTL_MASQUE_GET_PORT		(('M' << 8) | 'Q')   /* Masquerade        */
#define	CTL_MASQUE_SET_MASKIP	(('M' << 8) | 'M')   /* Masquerade        */
#define	CTL_MASQUE_GET_MASKIP	(('M' << 8) | 'N')   /* Masquerade        */
#define	CTL_MASQUE_GET_REALIP	(('M' << 8) | 'R')   /* Masquerade        */
/*--------------------------------------------------------------------------*/
/*	Handler flag values.													*/
/*--------------------------------------------------------------------------*/
#define  HNDLR_SET        0         /* Set new handler if space		*/
#define  HNDLR_FORCE      1         /* Force new handler to be set	*/
#define  HNDLR_REMOVE     2         /* Remove handler entry			*/
#define  HNDLR_QUERY      3         /* Inquire about handler entry	*/
/*--------------------------------------------------------------------------*/
/*	IP packet header.														*/
/*--------------------------------------------------------------------------*/
typedef  struct ip_header
{	unsigned	version   : 4;	/* IP Version								*/
	unsigned	hd_len    : 4;	/* Internet Header Length					*/
	unsigned	tos       : 8;	/* Type of Service							*/
	uint16		length;			/* Total of all header, options and data	*/
	uint16		ident;			/* Identification for fragmentation			*/
	unsigned	reserved  : 1;	/* Reserved : Must be zero					*/
	unsigned	dont_frg  : 1;	/* Don't fragment flag						*/
	unsigned	more_frg  : 1;	/* More fragments flag						*/
	unsigned	frag_ofst : 13;	/* Fragment offset							*/
	uint8		ttl;			/* Time to live								*/
	uint8		protocol;		/* Protocol									*/
	uint16		hdr_chksum;		/* Header checksum							*/
	uint32		ip_src;			/* Source IP address						*/
	uint32		ip_dest;		/* Destination IP address					*/
}	IP_HDR;
/*--------------------------------------------------------------------------*/
/*	Internal IP packet representation.										*/
/*--------------------------------------------------------------------------*/
typedef  struct ip_packet
{	IP_HDR	hdr;				/* Header of IP packet						*/
	void	*options;			/* Options data block						*/
	int16	opt_length;			/* Length of options data block				*/
	void	*pkt_data;			/* IP packet data block						*/
	int16	pkt_length;			/* Length of IP packet data block			*/
	uint32	timeout;			/* Timeout of packet life					*/
	uint32	ip_gateway;			/* Gateway for forwarding this packet		*/
	void	*recvd;				/* Receiving port							*/
	struct	ip_packet	*next;	/* Next IP packet in IP packet queue		*/
}	IP_DGRAM;
/*--------------------------------------------------------------------------*/
/*	Values for protocol field in IP headers									*/
/*--------------------------------------------------------------------------*/
#define	P_ICMP	1				/* IP assigned number for ICMP	*/
#define	P_TCP	6				/* IP assigned number for TCP	*/
#define	P_UDP	17				/* IP assigned number for UDP	*/
/*--------------------------------------------------------------------------*/
/*	Input queue structure.													*/
/*--------------------------------------------------------------------------*/
typedef struct ndb			/* Network Data Block.  For data delivery		*/
{	char		*ptr;		/* Pointer to base of block. (For KRfree();)	*/
	char		*ndata;		/* Pointer to next data to deliver				*/
	uint16		len;		/* Length of remaining data						*/
	struct	ndb	*next;		/* Next NDB in chain or NULL					*/
}	NDB;
/*--------------------------------------------------------------------------*/
/*	Addressing information block.											*/
/*--------------------------------------------------------------------------*/
typedef  struct cab
{	uint16		lport;		/* TCP local  port     (ie: local machine)		*/
	uint16		rport;		/* TCP remote port     (ie: remote machine)		*/
	uint32		rhost;		/* TCP remote IP addr  (ie: remote machine)		*/
	uint32		lhost;		/* TCP local  IP addr  (ie: local machine)		*/
}	CAB;
/*--------------------------------------------------------------------------*/
/*	Connection information block.											*/
/*--------------------------------------------------------------------------*/
typedef struct cib			/* Connection Information Block					*/
{	uint16		protocol;	/* TCP or UDP or ... 0 means CIB is not in use	*/
	CAB			address;	/* Adress information							*/
	uint16		status;		/* Net status. 0 means normal					*/
}	CIB;
/*--------------------------------------------------------------------------*/
/*	Transport structure / functions.										*/
/*--------------------------------------------------------------------------*/
typedef  struct tpl
{	char *	module;		/* Specific string that can be searched for		*/
	char *	author;		/* Any string									*/
	char *	version;	/* Format `00.00' Version:Revision				*/
	void *	cdecl	(* KRmalloc) (int32);
	void	cdecl	(* KRfree) (void *);
	int32	cdecl	(* KRgetfree) (int16);
	void *	cdecl	(* KRrealloc) (void *, int32);
	char *	cdecl	(* get_err_text) (int16);
	char *	cdecl	(* getvstr) (char *);
	int16	cdecl	(* carrier_detect) (void);
	int16	cdecl	(* TCP_open) (uint32, uint16, uint16, uint16);
	int16	cdecl	(* TCP_close) (int16, int16, int16 *);
	int16	cdecl	(* TCP_send) (int16, void *, int16);
	int16	cdecl	(* TCP_wait_state) (int16, int16, int16);
	int16	cdecl	(* TCP_ack_wait) (int16, int16);
	int16	cdecl	(* UDP_open) (uint32, uint16);
	int16	cdecl	(* UDP_close) (int16);
	int16	cdecl	(* UDP_send) (int16, void *, int16);
	int16	cdecl	(* CNkick) (int16);
	int16	cdecl	(* CNbyte_count) (int16);
	int16	cdecl	(* CNget_char) (int16);
	NDB *	cdecl	(* CNget_NDB) (int16);
	int16	cdecl	(* CNget_block) (int16, void *, int16);
	void	cdecl	(* housekeep) (void);
	int16	cdecl	(* resolve) (char *, char **, uint32 *, int16);
	void	cdecl	(* ser_disable) (void);
	void	cdecl	(* ser_enable) (void);
	int16	cdecl	(* set_flag) (int16);
	void	cdecl	(* clear_flag) (int16);
	CIB *	cdecl	(* CNgetinfo) (int16);
	int16	cdecl	(* on_port) (char *);
	void	cdecl	(* off_port) (char *);
	int16	cdecl	(* setvstr) (char *, char *);
	int16	cdecl	(* query_port) (char *);
	int16	cdecl	(* CNgets) (int16, char *, int16, char);
	int16	cdecl	(* ICMP_send) (uint32, uint8, uint8, void *, uint16);
	int16	cdecl	(* ICMP_handler) (int16 cdecl (*) (IP_DGRAM *), int16);
	void	cdecl	(* ICMP_discard) (IP_DGRAM *);
	int16	cdecl	(* TCP_info) (int16, TCPIB *);
	int16	cdecl	(* cntrl_port) (char *, uint32, int16);
	int16	cdecl	(* UDP_info) (int16, UDPIB *);
	int16	cdecl	(* RAW_open)(uint32);
	int16	cdecl	(* RAW_close)(int16);
	int16	cdecl	(* RAW_out)(int16, void *, int16, uint32);
	int16 	cdecl	(* CN_setopt)(int16, int16, const void *, int16);
	int16 	cdecl	(* CN_getopt)(int16, int16, void *, int16 *);
	void	cdecl	(* CNfree_NDB)(int16, NDB *);
}	TPL;

extern	TPL	*tpl;

/*--------------------------------------------------------------------------*/
/*	Definitions of transport functions for direct use.						*/
/*--------------------------------------------------------------------------*/
#define KRmalloc(x)				(*tpl->KRmalloc)(x)
#define KRfree(x)				(*tpl->KRfree)(x)
#define KRgetfree(x)			(*tpl->KRgetfree)(x)
#define KRrealloc(x,y)			(*tpl->KRrealloc)(x,y)
#define get_err_text(x)			(*tpl->get_err_text)(x)
#define getvstr(x)				(*tpl->getvstr)(x)
#define carrier_detect()		(*tpl->carrier_detect)()
#define TCP_open(w,x,y,z)		(*tpl->TCP_open)(w,x,y,z)
#define TCP_close(x,y,z)		(*tpl->TCP_close)(x,y,z)
#define TCP_send(x,y,z)			(*tpl->TCP_send)(x,y,z)
#define TCP_wait_state(x,y,z)	(*tpl->TCP_wait_state)(x,y,z)
#define TCP_ack_wait(x,y)		(*tpl->TCP_ack_wait)(x,y)
#define UDP_open(x,y)			(*tpl->UDP_open)(x,y)
#define UDP_close(x)			(*tpl->UDP_close)(x)
#define UDP_send(x,y,z)			(*tpl->UDP_send)(x,y,z)
#define CNkick(x)				(*tpl->CNkick)(x)
#define CNbyte_count(x)			(*tpl->CNbyte_count)(x)
#define CNget_char(x)			(*tpl->CNget_char)(x)
#define CNget_NDB(x)			(*tpl->CNget_NDB)(x)
#define CNget_block(x,y,z)		(*tpl->CNget_block)(x,y,z)
#define CNgetinfo(x)			(*tpl->CNgetinfo)(x)
#define CNgets(w,x,y,z)			(*tpl->CNgets)(w,x,y,z)
#define housekeep()				(*tpl->housekeep)()
#define resolve(w,x,y,z)		(*tpl->resolve)(w,x,y,z)
#define ser_disable()			(*tpl->ser_disable)()
#define ser_enable()			(*tpl->ser_enable)()
#define set_flag(x)				(*tpl->set_flag)(x)
#define clear_flag(x)			(*tpl->clear_flag)(x)
#define on_port(x)				(*tpl->on_port)(x)
#define off_port(x)				(*tpl->off_port)(x)
#define setvstr(x,y)			(*tpl->setvstr)(x,y)
#define query_port(x)			(*tpl->query_port)(x)
#define ICMP_send(v,w,x,y,z)	(*tpl->ICMP_send)(v,w,x,y,z)
#define ICMP_handler(x,y)		(*tpl->ICMP_handler)(x,y)
#define ICMP_discard(x)			(*tpl->ICMP_discard)(x)
#define TCP_info(x,y)			(*tpl->TCP_info)(x,y)
#define cntrl_port(x,y,z)		(*tpl->cntrl_port)(x,y,z)
#define UDP_info(x,y)			(*tpl->UDP_info)(x,y)
#define RAW_open(x)				(*tpl->RAW_open)(x)
#define RAW_close(x)			(*tpl->RAW_close)(x)
#define RAW_out(w,x,y,z)		(*tpl->RAW_out)(w,x,y,z)
#define CN_setopt(w,x,y,z)		(*tpl->CN_setopt)(w,x,y,z)
#define CN_getopt(w,x,y,z)		(*tpl->CN_getopt)(w,x,y,z)
#define CNfree_NDB(x,y)			(*tpl->CNfree_NDB)(x,y)
/*--------------------------------------------------------------------------*/
/*	Error return values.													*/
/*--------------------------------------------------------------------------*/
#define	E_NORMAL		0		/* No error occured ...						*/
#define	E_OBUFFULL		-1		/* Output buffer is full					*/
#define	E_NODATA		-2		/* No data available						*/
#define	E_EOF			-3		/* EOF from remote							*/
#define	E_RRESET		-4		/* Reset received from remote				*/
#define	E_UA			-5		/* Unacceptable packet received, reset		*/
#define	E_NOMEM			-6		/* Something failed due to lack of memory	*/
#define	E_REFUSE		-7		/* Connection refused by remote				*/
#define	E_BADSYN		-8		/* A SYN was received in the window			*/
#define	E_BADHANDLE		-9		/* Bad connection handle used.				*/
#define	E_LISTEN		-10		/* The connection is in LISTEN state		*/
#define	E_NOCCB			-11		/* No free CCB's available					*/
#define	E_NOCONNECTION	-12		/* No connection matches this packet (TCP)	*/
#define	E_CONNECTFAIL	-13		/* Failure to connect to remote port (TCP)	*/
#define	E_BADCLOSE		-14		/* Invalid TCP_close() requested			*/
#define	E_USERTIMEOUT	-15		/* A user function timed out				*/
#define	E_CNTIMEOUT		-16		/* A connection timed out					*/
#define	E_CANTRESOLVE	-17		/* Can't resolve the hostname				*/
#define	E_BADDNAME		-18		/* Domain name or dotted dec. bad format	*/
#define	E_LOSTCARRIER	-19		/* The modem disconnected					*/
#define	E_NOHOSTNAME	-20		/* Hostname does not exist					*/
#define	E_DNSWORKLIMIT	-21		/* Resolver Work limit reached				*/
#define	E_NONAMESERVER	-22		/* No nameservers could be found for query	*/
#define	E_DNSBADFORMAT	-23		/* Bad format of DNS query					*/
#define	E_UNREACHABLE	-24		/* Destination unreachable					*/
#define	E_DNSNOADDR		-25		/* No address records exist for host		*/
#define	E_NOROUTINE		-26		/* Routine unavailable						*/
#define	E_LOCKED		-27		/* Locked by another application			*/
#define	E_FRAGMENT		-28		/* Error during fragmentation				*/
#define	E_TTLEXCEED		-29		/* Time To Live of an IP packet exceeded	*/
#define	E_PARAMETER		-30		/* Problem with a parameter					*/
#define	E_BIGBUF		-31		/* Input buffer is too small for data		*/
#define	E_FNAVAIL		-32		/* Function not available					*/
#define	E_LASTERROR		32		/* ABS of last error code in this list		*/
/*--------------------------------------------------------------------------*/
#endif /* STING_TRANSPRT_H */
/*--------------------------------------------------------------------------*/
/*	End of file:	TRANSPRT.H												*/
/*--------------------------------------------------------------------------*/
