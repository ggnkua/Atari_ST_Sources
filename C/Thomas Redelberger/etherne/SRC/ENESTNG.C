/************************************************************************/
/*																		*/
/* STinG port driver for EtherNE NE2000 adapter							*/
/* Generic for ACSI and Cartridge Port interface hardware				*/
/* Copyright 2000-2002 Dr. Thomas Redelberger							*/
/* Use it under the terms of the GNU General Public License				*/
/* (See file COPYING.TXT)												*/
/*																		*/
/* Module to install and activate the port and to interface transmit 	*/
/* and receive to the STiNG kernel.										*/
/* Contains ARP code.													*/
/*																		*/
/* Credits:																*/
/* This is largely copied from code written by the "father" of STiNG	*/
/* Peter Rottengatter.													*/
/*																		*/
/* Tab size 4, developed with Turbo-C ST 2.0							*/
/************************************************************************/
/*
$Id: enestng.c 1.3 2002/06/08 16:07:50 Thomas Exp Thomas $
 */

#define	NULL ((void*) 0L)
#include <tos.h>

#include "transprt.h"
#include "port.h"

#include "ne.h"
#include "uti.h"
#include "devswit.h"


#define	hz200		(*(unsigned long*) 0x4BAL)

/* this is about a factor of six faster than memcpy(pd, ps, 6); */
#define	memcp6(pd, ps, dummy) \
	{int*d_ = (int*) pd; int *s_ = (int*) ps; \
		*d_++ = *s_++; *d_++ = *s_++; *d_++ = *s_++; }

#define	memse6(pd, val, dummy) \
	{int*d_ = (int*) pd; \
		*d_++ = (val<<8) + val; *d_++ = (val<<8) + val; *d_++ = (val<<8) + val; }



/*
 *   Ethernet packet header.
 */

typedef struct {
	 uint8	destination[6];		/* Destination hardware address */
	 uint8	source[6];			/* Source hardware address */
	 uint16	type;				/* Ethernet protocol type */
} ETH_HDR1;

#define  TYPE_IP	0x0800
#define  TYPE_ARP	0x0806
#define  TYPE_RARP	0x8035


/*
 *	ARP packet structure.
 */

typedef  struct arp_pkt {
	 uint16	hardware_space;		/* Hardware address space identifier */
	 uint16	protocol_space;		/* Protocol address space identifier */
	 uint8	hardware_len;		/* Length of hardware address */
	 uint8	protocol_len;		/* Length of protocol address */
	 uint16	op_code;			/* Operation Code */
	 uint8	src_ether[6];		/* Sender's hardware address */
	 uint32	src_ip;				/* Sender's protocol address */
	 uint8	dest_ether[6];		/* Target's hardware address */
	 uint32	dest_ip;			/* Target's protocol address */
 } ARP;

#define	ARP_HARD_ETHER	1
#define	ARP_OP_REQ		1
#define	ARP_OP_ANS		2




/**** forward declarations ****/

static void  cdecl	my_send (PORT *port);
static void  cdecl	my_receive (PORT *port);
static int16 cdecl	my_set_state (PORT *port, int16 state);
static int16 cdecl	my_cntrl (PORT *port, uint32 argument, int16 code);

static int			strcmp(const char* s, const char* t);		/* we do without stdlib */
static long			get_sting_cookie (void);
static void			install (BASPAG *);

static void			deplete_queue (IP_DGRAM **queue);

extern int			arpNentries;					/* linker to fill in myTable */

/* interface to Ethernet address caching */

static void			arp_init	(void);
static uint8*		arp_cache	(uint32 ip_addr);
static void			arp_enter	(uint32 ip_addr, uint8 ether[6]);


/**** start definitions ****/

/* access for netstat and arp to information via following table first in DATA segment */
struct {
	void*	(*pGetStats)(void);
	int*	pArp;
} myTable = {
	get_stats,
	&arpNentries
};


/* the following three are not static because the are accessed from NESTNG.S */

TPL		*tpl;
STX		*stx;
PORT	my_port   = {
	"EtherNet", L_SER_BUS, FALSE, 0L, 0xffffffffUL, 0xffffffffUL,
	1500, 1500, 0L, NULL, 0L, NULL, 0, NULL, NULL
};
static DRIVER	my_driver = {
	my_set_state, my_cntrl, my_send, my_receive, "EtherNet", VersionStr(MajVersion,MinVersion),
	((M_YEAR-1980) << 9) | (M_MONTH << 5) | M_DAY, "Dr. Thomas Redelberger",
	NULL, NULL
};

/*
 *	Supported hardware variants. It says NE2000 but a NE1000 also works
 */
static char* suppHardware[] = {
	"No selection",
	"NE2000",
	NULL
};


#if 0
static unsigned long tmark;		/* start time for debugging */
#endif


/* 
 *	The Ethernet packet sent on ARP request or answer
 */

static struct {
	ETH_HDR1	eh;
	ARP			arp;
	uint8		padbytes[60-sizeof(ETH_HDR1)-sizeof(ARP)];
} arpEthPckt = {
	0,0,0,0,0,0,
	0,0,0,0,0,0,
	TYPE_ARP,
	ARP_HARD_ETHER,
	TYPE_IP,
	6,
	4,
	0,
	0,0,0,0,0,0,
	0L,
	0,0,0,0,0,0,
	0L
	/* pad bytes get zero any way */
};

static uint16	doTxArp = FALSE;	/* signals when we must tx an ARP request or answer */
static uint16	waitArp = 0;		/* if > 0 signals we wait for an ARP answer */


/*
 *	First portion of Ethernet packet sent for IP. Ethernet header, IP header
 *  and IP options of STinG IP datagrams get copied her one after the other.
 *	The IP data do not get copied but rather are transferred directly from
 *  the STinG datagram to the NE
 */

static struct {
	ETH_HDR1	eh;
	uint8		ed[sizeof(IP_HDR)+200];		/* assuming options <= 200 bytes */
} ipEthPckt;





/* Note that this program does NOT use the standard startup code
 * The function main below MUST be the first one in the text segment
 */

static void cdecl main (BASPAG *bp)
{
	static char	fault[] = "ENE??.STX: STinG extension module. To be started by STinG!\r\n";
	DRV_LIST *sting_drivers;
	/* calculate size of TPA */
	long PgmSize = (long) bp->p_bbase + bp->p_blen - (long) bp;


	/* CR in cmdline to '\0' */
	bp->p_cmdlin[1+bp->p_cmdlin[0]] = '\0';

	if (strcmp (bp->p_cmdlin+1, "STinG_Load") != 0) {
		prntStr (fault);
		goto errExit;
	}

	/* look for NE hardware */

	if ( Supexec(ei_probe1) != 0 )
		goto errExit;

	if ( (sting_drivers = (DRV_LIST*) Supexec(get_sting_cookie)) == NULL )
		goto errExit;

	if (strcmp (sting_drivers->magic, MAGIC) != 0)
		goto errExit;

	tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
	stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);
	
	if (tpl != NULL && stx != NULL) {
		install(bp);
		Ptermres (PgmSize, 0);
	}

errExit:
	Pterm(-1);
}


static int strcmp(const char* s, const char* t)
{
	for ( ; *s == *t; s++, t++)
		if (*s == '\0') return 0;

	return *s - *t;
}


static long get_sting_cookie (void)
{
	long  *p;

	for (p = * (long **) 0x5a0L; *p ; p += 2)
	if (*p == 'STiK')
		return *++p;

	return 0L;
}



static void install(BASPAG *BasPag)
{
	PORT    *ports;
	DRIVER  *driver;
	
	query_chains ((void **) & ports, (void **) & driver, NULL);
	
	(my_port.driver = & my_driver)->basepage = BasPag;
	
	while (ports->next)
		ports = ports->next;
	
	ports->next = & my_port;
	
	while (driver->next)
		driver = driver->next;
	
	driver->next = & my_driver;

}


/* sorry, only one dgram per call in my_send because there is no more
room in the NEx000
*/

static void cdecl my_send (PORT *port)
{
	uint8*	cachedEther;
	uint32	network, ip_address;

#if 0
	tmark = hz200;
#endif

	/* see if an ARP answer is pending */
	if (doTxArp) {
		ei_start_xmit (arpEthPckt.eh.destination, (uint16) sizeof(arpEthPckt), NULL, 0);
		doTxArp = FALSE;
		return;		/* cannot do more at one function call */
	}
		
	/* do nothing if it is not for this port */
	if (port != &my_port || my_port.active == 0) return;


	/* all leading "old" packets get discarded */
	/* check_dgram_ttl will do a discard dgram if time is exceeded! */

	for (;;) {
		IP_DGRAM *next;
		if (my_port.send == NULL) return;	/* nothing to send */
		next = my_port.send->next;			/* need this if check_... discards */
		if ( check_dgram_ttl (my_port.send) == E_NORMAL ) break; 	/* found first good dgram */
		my_port.send = next;				/* got an old one, unlink it */
	}

	/* now have at least one good datagram */


	/* we check where the IP packet should go */
	network = my_port.ip_addr & my_port.sub_mask;


/* is the ip_address in my network ? */
	if ((my_port.send->hdr.ip_dest & my_port.sub_mask) == network) {
		ip_address = my_port.send->hdr.ip_dest;		/* yes */
	} else {
		/* no; is there a gateway in my network ? */
		if ((my_port.send->ip_gateway & my_port.sub_mask) == network) {
			ip_address = my_port.send->ip_gateway;		/* yes, send packet to the gateway */
		} else {
			IP_DGRAM *next = my_port.send->next;		/* no, throw packet away */
			IP_discard (my_port.send, TRUE);
			my_port.send = next;
			my_port.stat_dropped++;
			return;
		}
	}

	/* is this a broadcast address (hostpart all ones) ? */
	if ((my_port.send->hdr.ip_dest & ~my_port.sub_mask) == ~my_port.sub_mask) {
		memse6 (ipEthPckt.eh.destination, 0xff, 6);

	} else {

		/* if we find the ether address in the cache, we can send it */
		if ( (cachedEther = arp_cache (ip_address)) != NULL ) {
			memcp6 (ipEthPckt.eh.destination, cachedEther, 6);
		} else {

			/* ARP request outstanding ? */
			if (waitArp > 0) {
				--waitArp;
				return;		/* then do nothing */
			} 

			/* ip_address is not in cache, need to get the MAC address of it */
			memse6 (arpEthPckt.eh.destination, 0xff, 6);	/* broadcast */
			arpEthPckt.arp.op_code	= ARP_OP_REQ;			/* we send a request */
			arpEthPckt.arp.src_ip	= my_port.ip_addr;
			memse6 (arpEthPckt.arp.dest_ether, 0, 6);		/* 0=unknown */
			arpEthPckt.arp.dest_ip	= ip_address;
	
#if 0
{	static int k;
	if (k==0) {prntLong(ip_address); prntStr("\r\n"); k=1;}
}
Bconout(2, 7);	/* bellen */
#endif
			if (ei_start_xmit (arpEthPckt.eh.destination, 
				(uint16) sizeof(arpEthPckt), 
				NULL, 
				0) == 0) {
				/* the ARP packet is static and does not need to be dropped */
				my_port.stat_sd_data += sizeof(arpEthPckt);
				waitArp = 200;	/* wait at least 1 second (time slice of 5ms) for ARP reply */
				return ;
			}	/* if ei_start_xmit successful*/

		}	/* ip in cache? */


	}	/* broadcast address? */



	/* ethernet address is established we can send it */
	{	/* block */
		uint8 *work;
		int16 len1, len2;

		work = ipEthPckt.ed;
/* The following code assumes IP_HDR is 20 bytes! */
		{ uint32 *s = (uint32*) & (my_port.send->hdr);
			*((uint32*)work)++ = *s++;	*((uint32*)work)++ = *s++;
			*((uint32*)work)++ = *s++;	*((uint32*)work)++ = *s++;
			*((uint32*)work)++ = *s++; }

/* The following codes relies on option length being a multiple of 4 bytes */
		{ uint32 *s = (uint32*) & (my_port.send->options); int i;
			for (i= (my_port.send->opt_length)>>2; --i>=0; ) {
				*((uint32*)work)++ = *s++;
			}
		}

		/* if tx was sucessful we discard the dgram and unlink it */
		len1 = ( (int16) (sizeof(ETH_HDR1)+sizeof(IP_HDR)) ) + my_port.send->opt_length;
		len2 = my_port.send->pkt_length;
		if (len1+len2 <60) len2 = 60-len1;	/* pad to at least 60 bytes */
		if (ei_start_xmit (
				ipEthPckt.eh.destination,
				len1,
				my_port.send->pkt_data,
				len2
			) == 0) {
			IP_DGRAM *next = my_port.send->next;
			IP_discard (my_port.send, TRUE);
			my_port.send = next;
			my_port.stat_sd_data += len1+len2;
		}	/* if ei_start_xmit successful*/

	}	/* block */


}


static void cdecl my_receive (PORT  *port)
{
#if 0
	static i=100;
	static k=100;
	if (i==0) {
		prntStr("\0x1bYH1");
/*		prntLong(hz200 -tmark);
		prntSR();*/
		prntWord(k);
		i=100;
		k=100;
	} else {
		--i;
	}
#endif
	
	if (port != & my_port || my_port.active == 0) return;

	ei_interrupt();

}


static int16 cdecl my_set_state (PORT *port, int16 state)
{
	if (port != &my_port) return FALSE;

	if (state) {
		Supexec (ei_open);
		arp_init();

		/* put ethernet MAC address from ei_probe1 into IP  outgoing packets */
		memcp6 (ipEthPckt.eh.source,		DVS.dev_dev_addr, 6);
		ipEthPckt.eh.type = TYPE_IP;

		/* put ethernet MAC address from ei_probe1 into ARP outgoing packets */
		memcp6 (arpEthPckt.eh.source,		DVS.dev_dev_addr, 6);
		memcp6 (arpEthPckt.arp.src_ether,	DVS.dev_dev_addr, 6);

	} else {
		Supexec (ei_close);
		deplete_queue (&my_port.send);
		deplete_queue (&my_port.receive);
	}

	return TRUE;
}


/* need to communicate with Ronald */
#define	CTL_ETHER_GET_STAT	(('E' << 8) | 'S')   /* Ethernet, statistics */
#define	CTL_ETHER_GET_ARP	(('E' << 8) | 'A')   /* Ethernet, ARP */



static int16 cdecl my_cntrl (PORT *port, uint32 argument, int16 code)
{
	int16 result = E_NORMAL;
	static int16  type = -1;

	if (port != & my_port) return (E_PARAMETER);

	switch (code) {
/* we do not allow to change the MAC address
	case CTL_ETHER_SET_MAC :
		if (memory)
			memcpy (& ((VIRT_INIT *) memory)->addr[0], (uint8 *) argument, 6);
		break;
*/
	case CTL_ETHER_GET_MAC :
		memcp6 ((uint8 *) argument, DVS.dev_dev_addr, 6);
		break;

	case CTL_ETHER_INQ_SUPPTYPE :
		*((char ***) argument) = suppHardware;
		break;

	case CTL_ETHER_SET_TYPE :
		type = ((int16)argument) & 7;	/* the lowest 3 bits select from suppHardware */
		break;

	case CTL_ETHER_GET_TYPE :
		*((int16 *) argument) = type;
		break;

	case CTL_ETHER_GET_STAT :
		*((void **) argument) = get_stats();
		break;

	case CTL_ETHER_GET_ARP :
		*((int **) argument) = &arpNentries;
		break;

	default :
		result = E_FNAVAIL;
	}


	return result;
}


/* process_arp gets called from rtrvPckt (NESTNG.S) when an ARP packet was retrieved */

#define	EARPOK		0
#define	EARPJUNK	-20

long  process_arp (ARP * arp, int16 length)
{
	uint8*	cachedEther;
	int16	update = TRUE;

	/* ignore funny ARP packets */
	if (arp->hardware_space	!= ARP_HARD_ETHER
	 || arp->hardware_len	!= 6
	 || arp->protocol_space	!= TYPE_IP
	 || arp->protocol_len	!= 4) return EARPJUNK;

	/* this signals success to the outside */
	my_port.stat_rcv_data += length;

	/* check if this ether source is in the cache */
	if ( (cachedEther = arp_cache (arp->src_ip)) != NULL ) {
		update = FALSE;
		memcp6 (cachedEther, arp->src_ether, 6);
	}

	/* but if we were not the IP destination that is all we do */
	if (arp->dest_ip != my_port.ip_addr) return EARPOK;

	/* if it was not in the chache, enter it */
	if (update)
		arp_enter (arp->src_ip, arp->src_ether);

	/* if the sender answered then we do not */
	if (arp->op_code == ARP_OP_ANS) {
		waitArp = 0;
		return EARPOK;
	}

	/* now we are going to answer */
	memcp6 (arpEthPckt.eh.destination, arp->src_ether, 6);
	arpEthPckt.arp.op_code			 = ARP_OP_ANS;
	arpEthPckt.arp.src_ip			 = my_port.ip_addr;
	memcp6 (arpEthPckt.arp.dest_ether, arp->src_ether, 6);
	arpEthPckt.arp.dest_ip			 = arp->src_ip;

	/* flag that an ARP answer is pending for the next tx */
	doTxArp = TRUE;
	return EARPOK;
}



static void  deplete_queue (queue)

IP_DGRAM  **queue;

{
   IP_DGRAM  *walk, *next;

   for (walk = *queue; walk; walk = next) {
        next = walk->next;
        IP_discard (walk, TRUE);
      }

   *queue = NULL;
 }



/******** functions only to do with arp caching *********************/
/* too small to warrant a separate module							*/
/********************************************************************/

/*
 *	ARP cache entry.
 */

typedef  struct arp_entry {
	uint32	ip_addr;			/* IP address */
	uint8	ether[6];			/* EtherNet station address */
	uint16	used;				/* flag to signal in use */
 } ARP_ENTRY;


#define	ARP_NUM		32			/* # of ARP cache entries */

       int			arpNentries = ARP_NUM;	/* not static because linker must know it */
static int			filler = 0;				/* force next 3 vars. to DATA segment ...*/
static ARP_ENTRY*	arpRecnt = NULL;
static ARP_ENTRY	arpEntries[ARP_NUM] = {0L};	/* .. to have them adjacent */



static void  arp_init ()
{
	ARP_ENTRY  *walk;
	int i;

/* clear ARP cache */
	for (i = ARP_NUM, walk=arpEntries; --i>=0; walk++) {
		walk->ip_addr = 0;
		memse6(walk->ether, 0, 6);
		walk->used = 0;
	}

	arpRecnt = arpEntries;
}


static uint8* arp_cache (uint32 ip_addr)
{
	ARP_ENTRY  *walk;
	int i;

	/* go over all entries, start from recent entry */
	for (i = ARP_NUM, walk=arpRecnt; --i>=0; ) {
		if (walk->used && walk->ip_addr == ip_addr) {
			arpRecnt = walk;					/* likely we need that next time again */
			return walk->ether;
		}	

		if (--walk < arpEntries) walk = arpEntries+ARP_NUM-1;		/* wrap around */
	}

	return NULL;
}


static void  arp_enter (uint32 ip_addr, uint8 ether_addr[6])
{
	if (++arpRecnt >= arpEntries+ARP_NUM) arpRecnt = arpEntries;		/* wrap around */

	arpRecnt->ip_addr = ip_addr;
	memcp6 (arpRecnt->ether, ether_addr, 6);
	arpRecnt->used = 1;
}

/**** end of ethernea.c ****/
