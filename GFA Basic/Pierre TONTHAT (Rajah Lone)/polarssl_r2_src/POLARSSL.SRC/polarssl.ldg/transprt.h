/*--------------------------------------------------------------------------*/
/*	File name:	TRANSPRT.H						Revision date:	2010.01.31	*/
/*	Revised by:	Miro Kropacek					Revision start:	2010.01.31	*/
/*	Revised by:	Ulf Ronald Andersson			Revision start:	1999.09.21	*/
/*	Created by:	Peter Rottengatter				Creation date:	1996.xx.xx	*/
/*--------------------------------------------------------------------------*/
/* Header file for all STinG related source files, except those of kernel.	*/
/*--------------------------------------------------------------------------*/
#ifndef STING_TRANSPRT_H
#define STING_TRANSPRT_H
/*--------------------------------------------------------------------------*/
/*	NB: For readability, use a tab size of 4 when viewing this file.		*/
/*--------------------------------------------------------------------------*/
/* Here follows a section where you can add tests for compiler type, and	*/
/* use this to read in any extra header files that may be needed to give	*/
/* STinG applications some useful system types.								*/
/*--------------------------------------------------------------------------*/
/* NB: Only use advanced compiler or preprocessor features in conditional	*/
/*     clauses, after identifying a compiler that supports those features.	*/
/*--------------------------------------------------------------------------*/
#if defined	__TURBOC__		/* NB: This is set both for TurboC and for PureC */
	#include	<TOS.H>
#elif defined __GNUC__
	#include	<mint/basepage.h>
	#include	<compiler.h>
	#define		BASPAG BASEPAGE
#elif defined LATTICE
	#include	<basepage.h>
	#define		BASPAG BASEPAGE
#endif
/*--------------------------------------------------------------------------*/
/*	Definitions of data types used throughout STinG for portability.		*/
/*--------------------------------------------------------------------------*/
typedef	  signed	char	 int8;		/*   Signed  8 bit */
typedef	unsigned	char	uint8;		/* Unsigned  8 bit */
typedef	  signed	short	 int16;		/*   Signed 16 bit */
typedef	unsigned	short	uint16;		/* Unsigned 16 bit */
typedef	  signed	long	 int32;		/*   Signed 32 bit */
typedef	unsigned	long	uint32;		/* Unsigned 32 bit */
/*--------------------------------------------------------------------------*/
/*	Definitions of data types useful when 'porting' network software.		*/
/*--------------------------------------------------------------------------*/
#ifndef	TRUE
#define	TRUE	1
#endif
#ifndef	FALSE
#define	FALSE	0
#endif
#ifndef	ntohs
#define	ntohs(x)	(x)
#endif
#ifndef	ntohl
#define	ntohl(x)	(x)
#endif
#ifndef	htons
#define	htons(x)	(x)
#endif
#ifndef	htonl
#define	htonl(x)	(x)
#endif
/*--------------------------------------------------------------------------*/
/* The last 4 may look silly, but are used a lot by lots of sources, so it	*/
/* easier to declare them this way than to edit them out of those sources.	*/
/*--------------------------------------------------------------------------*/
/* The following macro is to cater to compilers that like/dislike 'cdecl'.	*/
/* Add more tests for other compilers as and when needed.  The default is	*/
/* to make 'cdecl' transparent, to accomodate ANSI compatible compilers.	*/
/*--------------------------------------------------------------------------*/
#ifndef	cdecl
#if		defined(__PUREC__)
#elif	defined(__TURBOC__)
#elif	defined(LATTICE)
	#define	cdecl __stdargs
#elif	defined(__GNUC__)
	#define cdecl //__cdecl
#else
	#define	cdecl
#endif
#endif
/*--------------------------------------------------------------------------*/
/*	STiK/STinG driver access structure / functions.							*/
/*--------------------------------------------------------------------------*/
#define	MAGIC	"STiKmagic"				/* Magic for DRV_LIST.magic	*/
#define	CJTAG	"STiK"					/* Cookie Jar tag			*/

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
/*	Definitions of internal submacros needed for macros further below.		*/
/*--------------------------------------------------------------------------*/
#ifndef	__GNUC__
/*--------------------------------------------------------------------------*/
/* The macros in this clause are for Pure_C and other normal compilers that	*/
/* are aware of the Atari standard of passing arguments in fitting sizes on */
/* stack, so a short int will use a single 16 bit word, even if the default */
/* 'int' size for that compiler is set to 32-bit length.					*/
/* Those are different things, and should be separately controlled options.	*/
/*--------------------------------------------------------------------------*/
#define	STinG_vf_v(func)				((func)())
#define	STinG_wf_v(func)				((func)())
#define	STinG_vf_p(func, x)				((func)(x))
#define	STinG_vf_s(func, x)				((func)(x))
#define	STinG_vf_D(func, x)				((func)(x))
#define	STinG_wf_w(func, x)				((func)(x))
#define	STinG_wf_L(func, x)				((func)(x))
#define	STinG_Cf_w(func, x)				((func)(x))
#define	STinG_Nf_w(func, x)				((func)(x))
#define	STinG_wf_s(func, x)				((func)(x))
#define	STinG_lf_w(func, x)				((func)(x))
#define	STinG_sf_w(func, x)				((func)(x))
#define	STinG_sf_s(func, x)				((func)(x))
#define	STinG_pf_l(func, x)				((func)(x))
#define	STinG_vf_wN(func, x1,x2)		((func)((x1),(x2)))
#define	STinG_wf_ww(func, x1,x2)		((func)((x1),(x2)))
#define	STinG_wf_wy(func, x1,x2)		((func)((x1),(x2)))
#define	STinG_wf_wz(func, x1,x2)		((func)((x1),(x2)))
#define	STinG_wf_xw(func, x1,x2)		((func)((x1),(x2)))
#define	STinG_wf_LW(func, x1,x2)		((func)((x1),(x2)))
#define	STinG_wf_ss(func, x1,x2)		((func)((x1),(x2)))
#define	STinG_pf_pl(func, x1, x2)		((func)((x1),(x2)))
#define	STinG_wf_www(func, x1,x2,x3)	((func)((x1),(x2),(x3)))
#define	STinG_wf_wwP(func, x1,x2,x3)	((func)((x1),(x2),(x3)))
#define	STinG_wf_wpw(func, x1,x2,x3)	((func)((x1),(x2),(x3)))
#define	STinG_wf_sLw(func, x1,x2,x3)	((func)((x1),(x2),(x3)))
#define	STinG_wf_LWWW(func, x1,x2,x3,x4)	((func)((x1),(x2),(x3),(x4)))
#define	STinG_wf_wswb(func, x1,x2,x3,x4)	((func)((x1),(x2),(x3),(x4)))
#define	STinG_wf_sSRw(func, x1,x2,x3,x4)	((func)((x1),(x2),(x3),(x4)))
#define	STinG_wf_wwpw(func, x1,x2,x3,x4)	((func)((x1),(x2),(x3),(x4)))
#define	STinG_wf_wwpW(func, x1,x2,x3,x4)	((func)((x1),(x2),(x3),(x4)))
#define	STinG_wf_wpwl(func, x1,x2,x3,x4)	((func)((x1),(x2),(x3),(x4)))
#define	STinG_wf_LBBpW(func, x1,x2,x3,x4,x5)	((func)((x1),(x2),(x3),(x4),(x5)))
/*--------------------------------------------------------------------------*/
#else	/* else __GNUC__ is defined */
/*--------------------------------------------------------------------------*/
/* The macros below allow Gnu C to function with STinG API regardless of	*/
/* whether default 'int' size is 16 or 32 bits, despite the fact that the	*/
/* latter setting normally causes Gnu C to pass short arguments wrongly.	*/
/* (As defined by the standards set by Atari for TOS compatible systems.)	*/
/*--------------------------------------------------------------------------*/
#ifndef	AND_MEMORY		/* because 'osbind.h' uses similar methods... */
#if		((__GNUC__ > 2) && (__GNUC_MINOR__ > 5))
#define	AND_MEMORY , "memory"
#else						/* else for ancient compiler versions */
#define	AND_MEMORY
#define	__extension__
#endif
#endif
/*--------------------------------------------------------------------------*/
/* The macros below allow Gnu C to function with STinG API regardless of	*/
/* whether default 'int' size is 16 or 32 bits, despite the fact that the	*/
/* latter setting normally causes Gnu C to pass short arguments wrongly.	*/
/* (As defined by the standards set by Atari for TOS compatible systems.)	*/
/*--------------------------------------------------------------------------*/
#define	STinG_vf_v(func)				\
__extension__							\
({	__asm__ volatile					\
	(									\
		"movl	%0,a0\n\t"				\
		"jsr	a0@"					\
		/* end of code */				\
	:	/* no outputs */				\
	:	"g"		(func)					\
	:	"d0","d1","d2","a0","a1"		\
	AND_MEMORY							\
	);									\
	;	/* This makes value 'void' */	\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_v(func)				\
__extension__							\
({	register int16 retv __asm__("d0");	\
	__asm__ volatile					\
	(									\
		"movl	%1,a0\n\t"				\
		"jsr	a0@"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_vf_p(func, arg1)			\
__extension__							\
({	void *_arg1 = (void *)(arg1);		\
	__asm__ volatile					\
	(									\
		"movl	%1,sp@-\n\t"			\
		"movl	%0,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#4,sp"					\
		/* end of code */				\
	:	/* no outputs */				\
	:	"g"		(func)					\
	,	"r"		(_arg1)					\
	:	"d0","d1","d2","a0","a1"		\
	AND_MEMORY							\
	);									\
	;	/* This makes value 'void' */	\
})
/*--------------------------------------------------------------------------*/
#define	STinG_vf_s(func, arg1)			\
__extension__							\
({	char *_arg1 = (char *)(arg1);		\
	__asm__ volatile					\
	(									\
		"movl	%1,sp@-\n\t"			\
		"movl	%0,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#4,sp"					\
		/* end of code */				\
	:	/* no outputs */				\
	:	"g"		(func)					\
	,	"r"		(_arg1)					\
	:	"d0","d1","d2","a0","a1"		\
	AND_MEMORY							\
	);									\
	;	/* This makes value 'void' */	\
})
/*--------------------------------------------------------------------------*/
#define	STinG_vf_D(func, arg1)			\
__extension__							\
({	IP_DGRAM *_arg1 = (IP_DGRAM *)(arg1);	\
	__asm__ volatile					\
	(									\
		"movl	%1,sp@-\n\t"			\
		"movl	%0,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#4,sp"					\
		/* end of code */				\
	:	/* no outputs */				\
	:	"g"		(func)					\
	,	"r"		(_arg1)					\
	:	"d0","d1","d2","a0","a1"		\
	AND_MEMORY							\
	);									\
	;	/* This makes value 'void' */	\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_w(func, arg1)			\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	__asm__ volatile					\
	(									\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#2,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_L(func, arg1)			\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int32 _arg1 = (int32)(arg1);		\
	__asm__ volatile					\
	(									\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#4,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_Cf_w(func, arg1)			\
__extension__							\
({	register CIB *retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	__asm__ volatile					\
	(									\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#2,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_Nf_w(func, arg1)			\
__extension__							\
({	register NDB *retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	__asm__ volatile					\
	(									\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#2,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_s(func, arg1)			\
__extension__							\
({	register int16 retv __asm__("d0");	\
	char *_arg1 = (char *)(arg1);		\
	__asm__ volatile					\
	(									\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#4,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_lf_w(func, arg1)			\
__extension__							\
({	register int32 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	__asm__ volatile					\
	(									\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#2,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_sf_w(func, arg1)			\
__extension__							\
({	register char *retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	__asm__ volatile					\
	(									\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#2,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_sf_s(func, arg1)			\
__extension__							\
({	register char *retv __asm__("d0");	\
	char *_arg1 = (char *)(arg1);		\
	__asm__ volatile					\
	(									\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#4,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_pf_l(func, arg1)			\
__extension__							\
({	register void* retv __asm__("d0");	\
	int32 _arg1 = (int32)(arg1);		\
	__asm__ volatile					\
	(									\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#4,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_vf_wN(func, arg1,arg2)	\
__extension__							\
({	int16 _arg1 = (int16)(arg1);		\
	NDB  *_arg2 = (NDB *)(arg2);		\
	__asm__ volatile					\
	(									\
		"movl	%2,sp@-\n\t"			\
		"movw	%1,sp@-\n\t"			\
		"movl	%0,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#6,sp"					\
		/* end of code */				\
	:	/* no outputs */				\
	:	"g"		(func)					\
	,	"r"		(_arg1)					\
	,	"r"		(_arg2)					\
	:	"d0","d1","d2","a0","a1"		\
	AND_MEMORY							\
	);									\
	;	/* This makes value 'void' */	\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_ww(func, arg1,arg2)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	int16 _arg2 = (int16)(arg2);		\
	__asm__ volatile					\
	(									\
		"movw	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#4,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_wy(func, arg1,arg2)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	TCPIB *_arg2 = (TCPIB *)(arg2);		\
	__asm__ volatile					\
	(									\
		"movl	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#6,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_wz(func, arg1,arg2)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	UDPIB *_arg2 = (UDPIB *)(arg2);		\
	__asm__ volatile					\
	(									\
		"movl	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#6,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_xw(func, arg1,arg2)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 cdecl (*) (IP_DGRAM *) _arg1 = (int16 cdecl (*) (IP_DGRAM *))(arg1);		\
	int16 _arg2 = (int16)(arg2);		\
	__asm__ volatile					\
	(									\
		"movw	%3,sp@-\n\t"			\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#6,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_LW(func, arg1,arg2)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	uint32 _arg1 = (uint32)(arg1);		\
	uint16 _arg2 = (uint16)(arg2);		\
	__asm__ volatile					\
	(									\
		"movw	%3,sp@-\n\t"			\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#6,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_ss(func, arg1,arg2)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	char *_arg1 = (char *)(arg1);		\
	char *_arg2 = (char *)(arg2);		\
	__asm__ volatile					\
	(									\
		"movl	%3,sp@-\n\t"			\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#8,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_pf_pl(func, arg1, arg2)	\
__extension__							\
({	register void* retv __asm__("d0");	\
	void *_arg1 = (void *)(arg1);		\
	int32 _arg2 = (int32)(arg2);		\
	__asm__ volatile					\
	(									\
		"movl	%3,sp@-\n\t"			\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#8,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_www(func, arg1,arg2,arg3)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	int16 _arg2 = (int16)(arg2);		\
	int16 _arg3 = (int16)(arg3);		\
	__asm__ volatile					\
	(									\
		"movw	%4,sp@-\n\t"			\
		"movw	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#6,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_wwP(func, arg1,arg2,arg3)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	int16 _arg2 = (int16)(arg2);		\
	int16 *_arg3 = (int16 *)(arg3);		\
	__asm__ volatile					\
	(									\
		"movl	%4,sp@-\n\t"			\
		"movw	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#8,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_wpw(func, arg1,arg2,arg3)	\
__extension__							\
({										\
	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	void *_arg2 = (void *)(arg2);		\
	int16 _arg3 = (int16)(arg3);		\
	__asm__ volatile					\
	(									\
		"movw	%4,sp@-\n\t"			\
		"movl	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"addql	#8,sp"					\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_sLw(func, arg1,arg2,arg3)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	char *_arg1 = (char *)(arg1);		\
	uint32 _arg2 = (uint32)(arg2);		\
	int16 _arg3 = (int16)(arg3);		\
	__asm__ volatile					\
	(									\
		"movw	%4,sp@-\n\t"			\
		"movl	%3,sp@-\n\t"			\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"lea	sp@(10),sp"				\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_LWWW(func, arg1,arg2,arg3,arg4)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	uint32 _arg1 = (uint32)(arg1);		\
	uint16 _arg2 = (uint16)(arg2);		\
	uint16 _arg3 = (uint16)(arg3);		\
	uint16 _arg4 = (uint16)(arg4);		\
	__asm__ volatile					\
	(									\
		"movw	%5,sp@-\n\t" 			\
		"movw	%4,sp@-\n\t" 			\
		"movw	%3,sp@-\n\t" 			\
		"movl	%2,sp@-\n\t" 			\
		"movl	%1,a0\n\t" 				\
		"jsr	a0@\n\t" 				\
		"lea	sp@(10),sp"				\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	,	"r"		(_arg4)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_wswb(func, arg1,arg2,arg3,arg4)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	char *_arg2 = (char *)(arg2);		\
	int16 _arg3 = (int16)(arg3);		\
	char _arg4 = (char)(arg4);			\
	__asm__ volatile					\
	(									\
		"movb	%5,sp@-\n\t"			\
		"movw	%4,sp@-\n\t"			\
		"movl	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"lea	sp@(10),sp"				\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	,	"r"		(_arg4)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_sSRw(func, arg1,arg2,arg3,arg4)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	char *_arg1 = (char *)(arg1);		\
	char **_arg2 = (char **)(arg2);		\
	uint32 *_arg3 = (uint32 *)(arg3);	\
	int16 _arg4 = (int16)(arg4);		\
	__asm__ volatile					\
	(									\
		"movw	%5,sp@-\n\t" 			\
		"movl	%4,sp@-\n\t" 			\
		"movl	%3,sp@-\n\t" 			\
		"movl	%2,sp@-\n\t" 			\
		"movl	%1,a0\n\t" 				\
		"jsr	a0@\n\t" 				\
		"lea	sp@(14),sp"				\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	,	"r"		(_arg4)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_wwpw(func, arg1,arg2,arg3,arg4)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	int16 _arg2 = (int16)(arg2);		\
	void *_arg3 = (void *)(arg3);		\
	int16 _arg4 = (int16)(arg4);		\
	__asm__ volatile					\
	(									\
		"movw	%5,sp@-\n\t"			\
		"movl	%4,sp@-\n\t"			\
		"movw	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"lea	sp@(10),sp"				\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	,	"r"		(_arg4)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_wwpW(func, arg1,arg2,arg3,arg4)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	int16 _arg2 = (int16)(arg2);		\
	void *_arg3 = (void *)(arg3);		\
	int16 *_arg4 = (int16 *)(arg4);		\
	__asm__ volatile					\
	(									\
		"movl	%5,sp@-\n\t"			\
		"movl	%4,sp@-\n\t"			\
		"movw	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"lea	sp@(12),sp"				\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	,	"r"		(_arg4)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_wpwl(func, arg1,arg2,arg3,arg4)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	int16 _arg1 = (int16)(arg1);		\
	void * _arg2 = (void *)(arg2);		\
	int16 _arg3 = (int16)(arg3);		\
	int32 _arg4 = (int32)(arg4);		\
	__asm__ volatile					\
	(									\
		"movl	%5,sp@-\n\t"			\
		"movw	%4,sp@-\n\t"			\
		"movl	%3,sp@-\n\t"			\
		"movw	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"lea	sp@(12),sp"				\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	,	"r"		(_arg4)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#define	STinG_wf_LBBpW(func, arg1,arg2,arg3,arg4,arg5)	\
__extension__							\
({	register int16 retv __asm__("d0");	\
	uint32 _arg1 = (uint32)(arg1);		\
	uint8 _arg2 = (uint8)(arg2);		\
	uint8 _arg3 = (uint8)(arg3);		\
	void *_arg4 = (void *)(arg4);		\
	uint16 _arg5 = (uint16)(arg5);		\
	__asm__ volatile					\
	(									\
		"movw	%6,sp@-\n\t"			\
		"movl	%5,sp@-\n\t"			\
		"movb	%4,sp@-\n\t"			\
		"movb	%3,sp@-\n\t"			\
		"movl	%2,sp@-\n\t"			\
		"movl	%1,a0\n\t"				\
		"jsr	a0@\n\t"				\
		"lea	sp@(14),sp"				\
		/* end of code */				\
	:	"=r"	(retv)		/* out */	\
	:	"g"		(func)		/* in */	\
	,	"r"		(_arg1)		/* in */	\
	,	"r"		(_arg2)		/* in */	\
	,	"r"		(_arg3)		/* in */	\
	,	"r"		(_arg4)		/* in */	\
	,	"r"		(_arg5)		/* in */	\
	:	__CLOBBER_RETURN("d0") "d1","d2","a0","a1"	\
	AND_MEMORY							\
	);									\
	retv;								\
})
/*--------------------------------------------------------------------------*/
#endif	/* __GNUC__ */
/*--------------------------------------------------------------------------*/
/*	Definitions of transport macros for direct use.							*/
/*--------------------------------------------------------------------------*/
#define KRmalloc(x)				STinG_pf_l(tpl->KRmalloc, (x))
#define KRfree(x)				STinG_vf_p(tpl->KRfree, (x))
#define KRgetfree(x)			STinG_lf_w(tpl->KRgetfree, (x))
#define KRrealloc(x,y)			STinG_pf_pl(tpl->KRrealloc, (x), (y))
#define get_err_text(x)			STinG_sf_w(tpl->get_err_text, (x))
#define getvstr(x)				STinG_sf_s(tpl->getvstr, (x))
#define carrier_detect()		STinG_wf_v(tpl->carrier_detect, (x))
#define TCP_open(w,x,y,z)		STinG_wf_LWWW(tpl->TCP_open, (w),(x),(y),(z))
#define TCP_close(x,y,z)		STinG_wf_wwP(tpl->TCP_close, (x),(y),(z))
#define TCP_send(x,y,z)			STinG_wf_wpw(tpl->TCP_send, (x),(y),(z))
#define TCP_wait_state(x,y,z)	STinG_wf_www(tpl->TCP_wait_state, (x),(y),(z))
#define TCP_ack_wait(x,y)		STinG_wf_ww(tpl->TCP_ack_wait, (x),(y))
#define UDP_open(x,y)			STinG_wf_LW(tpl->UDP_open, (x),(y))
#define UDP_close(x)			STinG_wf_w(tpl->UDP_close, (x))
#define UDP_send(x,y,z)			STinG_wf_wpw(tpl->UDP_send, (x),(y),(z))
#define CNkick(x)				STinG_wf_w(tpl->CNkick, (x))
#define	CNbyte_count(x)			STinG_wf_w(tpl->CNbyte_count, (x))
#define CNget_char(x)			STinG_wf_w(tpl->CNget_char, (x))
#define CNget_NDB(x)			STinG_Nf_w(tpl->CNget_NDB, (x))
#define CNget_block(x,y,z)		STinG_wf_wpw(tpl->CNget_block, (x),(y),(z))
#define housekeep()				STinG_vf_v(tpl->housekeep)
#define resolve(w,x,y,z)		STinG_wf_sSRw(tpl->resolve, (w),(x),(y),(z))
#define ser_disable()			STinG_vf_v(tpl->ser_disable)
#define ser_enable()			STinG_vf_v(tpl->ser_enable)
#define set_flag(x)				STinG_wf_w(tpl->set_flag, (x))
#define clear_flag(x)			STinG_wf_w(tpl->clear_flag, (x))
#define CNgetinfo(x)			STinG_Cf_w(tpl->CNgetinfo, (x))
#define on_port(x)				STinG_wf_s(tpl->on_port, (x))
#define off_port(x)				STinG_vf_s(tpl->off_port, (x))
#define setvstr(x,y)			STinG_wf_ss(tpl->setvstr, (x),(y))
#define query_port(x)			STinG_wf_s(tpl->query_port, (x))
#define CNgets(w,x,y,z)			STinG_wf_wswb(tpl->CNgets, (x))
#define ICMP_send(v,w,x,y,z)	STinG_wf_LBBpW(tpl->ICMP_send, (v),(w),(x),(y),(z))
#define ICMP_handler(x,y)		STinG_wf_xw(tpl->ICMP_handler, (x),(y))
#define ICMP_discard(x)			STinG_vf_D(tpl->ICMP_discard, (x))
#define TCP_info(x,y)			STinG_wf_wy(tpl->TCP_info, (x),(y))
#define cntrl_port(x,y,z)		STinG_wf_sLw(tpl->cntrl_port, (x),(y),(z))
#define UDP_info(x,y)			STinG_wf_wx(tpl->UDP_info, (x),(y))
#define RAW_open(x)				STinG_wf_L(tpl->RAW_open, (x))
#define RAW_close(x)			STinG_wf_w(tpl->RAW_close, (x))
#define	RAW_out(w,x,y,z)		STinG_wf_wpwl(tpl->RAW_out,(w),(x),(y),(z))
#define	CN_setopt(w,x,y,z)		STinG_wf_wwpw(tpl->CN_setopt,(w),(x),(y),(z))
#define	CN_getopt(w,x,y,z)		STinG_wf_wwpW(tpl->CN_getopt,(w),(x),(y),(z))
#define	CNfree_NDB(x,y)			STinG_vf_wN(tpl->CNfree_NDB,(x),(y))
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
