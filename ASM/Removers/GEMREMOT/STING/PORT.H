/*--------------------------------------------------------------------------*/
/*	File name:	PORT.H							Revision date:	1999.12.03	*/
/*	Revised by:	Ulf Ronald Andersson			Revision start:	1999.09.21	*/
/*	Created by:	Peter Rottengatter				Creation date:	1996.xx.xx	*/
/*--------------------------------------------------------------------------*/
/* Header file for all STinG port driver C sources.							*/
/*--------------------------------------------------------------------------*/
#ifndef STING_PORT_H
#define STING_PORT_H
/*--------------------------------------------------------------------------*/
#ifndef MODULE_DRIVER
#define MODULE_DRIVER    "MODULE_LAYER"
#endif
/*--------------------------------------------------------------------------*/
/*	Internal port descriptor.												*/
/*--------------------------------------------------------------------------*/
typedef  struct port_desc
{	char		*name;				/* Name of port							*/
	int16		type;				/* Type of port							*/
	int16		active;				/* Flag for port active or not			*/
	uint32		flags;				/* Type dependent operational flags		*/
	uint32		ip_addr;			/* IP address of this network adapter	*/
	uint32		sub_mask;			/* Subnet mask of attached network		*/
	int16		mtu;				/* Maximum packet size to go through	*/
	int16		max_mtu;			/* Maximum allowed value for mtu		*/
	int32		stat_sd_data;		/* Statistics of sent data				*/
	IP_DGRAM	*send;				/* Link to first entry in send queue	*/
	int32		stat_rcv_data;		/* Statistics of received data			*/
	IP_DGRAM	*receive;			/* Link to first entry in receive queue	*/
	int16		stat_dropped;		/* Statistics of dropped datagrams		*/
	struct	drv_desc	*driver;	/* Driver program to handle this port	*/
	struct	port_desc	*next;		/* Next port in port chain				*/
}	PORT;
/*--------------------------------------------------------------------------*/
/*	Port driver descriptor.													*/
/*--------------------------------------------------------------------------*/
typedef  struct drv_desc
{	int16 cdecl	(* set_state) (PORT *, int16);		/* Setup and shutdown	*/
	int16 cdecl	(* cntrl) (PORT *, uint32, int16);	/* Control functions	*/
	void  cdecl	(* send) (PORT *);					/* Send packets			*/
	void  cdecl	(* receive) (PORT *);				/* Receive packets		*/
	char				*name;		/* Name of driver						*/
	char				*version;	/* Version of driver in "xx.yy" format	*/
	uint16				date;		/* Compile date in GEMDOS format		*/
	char				*author;	/* Name of programmer					*/
	struct	drv_desc	*next;		/* Next driver in driver chain			*/
	BASPAG				*basepage;	/* Basepage of this module				*/
}	DRIVER;
/*--------------------------------------------------------------------------*/
/*	Link Type Definitions													*/
/*--------------------------------------------------------------------------*/
#define	L_INTERNAL	0			/* Internal pseudo port					*/
#define	L_SER_PTP	1			/*   Serial point to point type link		*/
#define	L_PAR_PTP	2			/* Parallel point to point type link		*/
#define	L_SER_BUS	3			/*   Serial            bus type link		*/
#define	L_PAR_BUS	4			/* Parallel            bus type link		*/
#define	L_SER_RING	5			/*   Serial           ring type link		*/
#define	L_PAR_RING	6			/* Parallel           ring type link		*/
#define	L_MASQUE	7			/*   Masquerading pseudo port				*/
/*--------------------------------------------------------------------------*/
/*	Module driver structure / functions										*/
/*--------------------------------------------------------------------------*/
#ifndef MOD_DRIVER
#define MOD_DRIVER
/*--------------------------------------------------------------------------*/
typedef  struct stx
{	char *     module;      /* Specific string that can be searched for     */
	char *     author;      /* Any string                                   */
	char *     version;     /* Format `00.00' Version:Revision              */
	void       cdecl  (* set_dgram_ttl) (IP_DGRAM *);
	int16      cdecl  (* check_dgram_ttl) (IP_DGRAM *);
	int16      cdecl  (* load_routing_table) (void);
	int32      cdecl  (* set_sysvars) (int16, int16);
	void       cdecl  (* query_chains) (void **, void **, void **);
	int16      cdecl  (* IP_send) (uint32, uint32, uint8, uint16, uint8, uint8, uint16,
									void *, uint16, void *, uint16);
	IP_DGRAM * cdecl  (* IP_fetch) (int16);
	int16      cdecl  (* IP_handler) (int16, int16 cdecl (*) (IP_DGRAM *), int16);
	void       cdecl  (* IP_discard) (IP_DGRAM *, int16);
	int16      cdecl  (* PRTCL_announce) (int16);
	int16      cdecl  (* PRTCL_get_parameters) (uint32, uint32 *, int16 *, uint16 *);
	int16      cdecl  (* PRTCL_request) (void *, void *);
	void       cdecl  (* PRTCL_release) (int16);
	void *     cdecl  (* PRTCL_lookup) (int16, void *);
	int16      cdecl  (* TIMER_call) (void cdecl (*) (void), int16);
	int32      cdecl  (* TIMER_now) (void);
	int32      cdecl  (* TIMER_elapsed) (int32);
	int32      cdecl  (* protect_exec) (void *, int32 cdecl (*) (void *));
	int16      cdecl  (* get_route_entry) (int16, uint32 *, uint32 *, PORT **, uint32 *);
	int16      cdecl  (* set_route_entry) (int16, uint32, uint32, PORT *, uint32);
}	STX;
extern STX *stx;
/*--------------------------------------------------------------------------*/
/*	Definitions of module driver functions for direct use					*/
/*--------------------------------------------------------------------------*/
#define set_dgram_ttl(x)                 (*stx->set_dgram_ttl)(x)
#define check_dgram_ttl(x)               (*stx->check_dgram_ttl)(x)
#define load_routing_table()             (*stx->load_routing_table)()
#define set_sysvars(x,y)                 (*stx->set_sysvars)(x,y)
#define query_chains(x,y,z)              (*stx->query_chains)(x,y,z)
#define IP_send(a,b,c,d,e,f,g,h,i,j,k)   (*stx->IP_send)(a,b,c,d,e,f,g,h,i,j,k)
#define IP_fetch(x)                      (*stx->IP_fetch)(x)
#define IP_handler(x,y,z)                (*stx->IP_handler)(x,y,z)
#define IP_discard(x,y)                  (*stx->IP_discard)(x,y)
#define PRTCL_announce(x)                (*stx->PRTCL_announce)(x)
#define PRTCL_get_parameters(w,x,y,z)    (*stx->PRTCL_get_parameters)(w,x,y,z)
#define PRTCL_request(x,y)               (*stx->PRTCL_request)(x,y)
#define PRTCL_release(x)                 (*stx->PRTCL_release)(x)
#define PRTCL_lookup(x,y)                (*stx->PRTCL_lookup)(x,y)
#define TIMER_call(x,y)                  (*stx->TIMER_call)(x,y)
#define TIMER_now()                      (*stx->TIMER_now)()
#define TIMER_elapsed(x)                 (*stx->TIMER_elapsed)(x)
#define protect_exec(x,y)                (*stx->protect_exec)(x,y)
#define get_route_entry(a,b,c,d,e)       (*stx->get_route_entry)(a,b,c,d,e)
#define set_route_entry(a,b,c,d,e)       (*stx->set_route_entry)(a,b,c,d,e)
/*--------------------------------------------------------------------------*/
#endif	/* MOD_DRIVER */
/*--------------------------------------------------------------------------*/
#endif	/* STING_PORT_H */
/*--------------------------------------------------------------------------*/
/*	End of file:	PORT.H													*/
/*--------------------------------------------------------------------------*/
