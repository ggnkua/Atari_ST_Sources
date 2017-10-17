/*
 * Filename:     gs_stik.c
 * Project:      GlueSTiK
 * 
 * Note:         Please send suggestions, patches or bug reports to me
 *               or the MiNT mailing list <mint@fishpool.com>.
 * 
 * Copying:      Copyright 1999 Frank Naumann <fnaumann@cs.uni-magdeburg.de>
 * 
 * Portions copyright 1997, 1998, 1999 Scott Bigham <dsb@cs.duke.edu>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <string.h>
#include "config.h"
#include "sockets.h"
#include "gs_stik.h"
#include "gs_func.h"
#include "gs_mem.h"

#define VER_MAJOR "0"
#define VER_MINOR "30"

#ifdef NETWORK
#ifdef LWIP

/* STIK global configuration structure.
 * 
 * STinG's <transprt.h> doesn't
 * define this, so we define it here.
 */

typedef struct config CONFIG;
struct config
{
	uint32	client_ip;	/* IP address of client (local) machine */
	uint32	provider;	/* IP address of provider, or 0L */
	uint16	ttl;		/* Default TTL for normal packets */
	uint16	ping_ttl;	/* Default TTL for 'ping'ing */
	uint16	mtu;		/* Default MTU (Maximum Transmission Unit) */
	uint16	mss;		/* Default MSS (Maximum Segment Size) */
	uint16	df_bufsize; 	/* Size of defragmentation buffer to use */
	uint16	rcv_window; 	/* TCP receive window */
	uint16	def_rtt;	/* Initial RTT time in ms */
	int16 	time_wait_time;	/* How long to wait in 'TIME_WAIT' state */
	int16 	unreach_resp;	/* Response to unreachable local ports */
	int32 	cn_time;	/* Time connection was made */
	int16 	cd_valid;	/* Is Modem CD a valid signal ?? */
	int16 	line_protocol;	/* What type of connection is this */
	void	(*old_vec)(void);	/* Old vector address */
	struct	slip *slp;	/* Slip structure for happiness */
	char	*cv[101];	/* Space for extra config variables */
	int16 	reports;	/* Problem reports printed to screen ?? */
	int16 	max_num_ports;	/* Maximum number of ports supported */
	uint32	received_data;	/* Counter for data being received */
	uint32	sent_data;	/* Counter for data being sent */
};

static char *err_list [E_LASTERROR + 1] =
{
/* E_NORMAL       */	"No error occured",
/* E_OBUFFULL     */	"Output buffer is full",
/* E_NODATA       */	"No data available",
/* E_EOF          */	"EOF from remote",
/* E_RRESET       */	"Reset received from remote",
/* E_UA           */	"Unacceptable packet received, reset",
/* E_NOMEM        */	"Something failed due to lack of memory",
/* E_REFUSE       */	"Connection refused by remote",
/* E_BADSYN       */	"A SYN was received in the window",
/* E_BADHANDLE    */	"Bad connection handle used.",
/* E_LISTEN       */	"The connection is in LISTEN state",
/* E_NOCCB        */	"No free CCB's available",
/* E_NOCONNECTION */	"No connection matches this packet (TCP)",
/* E_CONNECTFAIL  */	"Failure to connect to remote port (TCP)",
/* E_BADCLOSE     */	"Invalid TCP_close() requested",
/* E_USERTIMEOUT  */	"A user function timed out",
/* E_CNTIMEOUT    */	"A connection timed out",
/* E_CANTRESOLVE  */	"Can't resolve the hostname",
/* E_BADDNAME     */	"Domain name or dotted dec. bad format",
/* E_LOSTCARRIER  */	"The modem disconnected",
/* E_NOHOSTNAME   */	"Hostname does not exist",
/* E_DNSWORKLIMIT */	"Resolver Work limit reached",
/* E_NONAMESERVER */	"No nameservers could be found for query",
/* E_DNSBADFORMAT */	"Bad format of DS query",
/* E_UNREACHABLE  */	"Destination unreachable",
/* E_DNSNOADDR    */	"No address records exist for host",
/* E_NOROUTINE    */	"Routine unavailable",
/* E_LOCKED       */	"Locked by another application",
/* E_FRAGMENT     */	"Error during fragmentation",
/* E_TTLEXCEED    */	"Time To Live of an IP packet exceeded",
/* E_PARAMETER    */	"Problem with a parameter",
/* E_BIGBUF       */	"Input buffer is too small for data"
};

char err_unknown [] = "Unrecognized error";

static int flags [64];

static void *do_KRmalloc (struct KRmalloc_param p)
{
	return gs_mem_alloc (p.size);
}

static void do_KRfree (struct KRfree_param p)
{
	gs_mem_free (p.mem);
}

static int32 do_KRgetfree (struct KRgetfree_param p)
{
	return gs_mem_getfree (p.flag);
}

static void *do_KRrealloc (struct KRrealloc_param p)
{
	return gs_mem_realloc (p.mem, p.newsize);
}

char *do_get_err_text (struct get_err_text_param p)
{
	if (p.code < 0)
		p.code = -p.code;
	
	if (p.code > 2000)
		return err_unknown;
	
	if (p.code > 1000)
	{
		/* Encoded GEMDOS errors */
		return err_unknown;
//		return strerror (p.code - 1000);
	}
	
	if (p.code > E_LASTERROR)
		return err_unknown;
	
	return err_list [p.code];
}

static char *
do_getvstr (struct getvstr_param p)
{
	return NULL;
//	return gs_getvstr (p.var);
}

/* Incompatibility:  Does nothing.
 * We can't really support this well,
 * since MiNTnet transparently supports multiple modems, as well as
 * non-modem methods of connections, such as local networks
 */
static int16 do_carrier_detect (void)
{
	return 0;
}

static int16 do_TCP_open (struct TCP_open_param p)
{
	uint32 lhost; int16 lport;
	int fd;
	long ret;
	
	PRINT_DEBUG (("do_TCP_open: rhost = %lu, rport = %i", p.rhost, p.rport));
	
	if (p.rhost == 0)
	{
		p.rhost = 0;
		lhost = INADDR_ANY;
		lport = p.rport;
		p.rport = 0;
	}
	else if (p.rport == 0)
	{
		CIB *cib = (CIB *) p.rhost;
		
		p.rhost = cib->rhost;
		p.rport = cib->rport;
		lhost = cib->lhost;
		lport = cib->lport;
	}
	else
	{
	//	p.rhost = p.rhost;
	//	p.rport = p.rport;
		lhost = INADDR_ANY;
		lport = 0;
	}
	
	fd = gs_open ();
	if (fd < 0)
		return fd;
	
	/* The TCP_OPEN_CMD command transmogrifies this descriptor into an
	 * actual connection.
	 */
	ret = gs_connect (fd, p.rhost, p.rport, lhost, lport);
	if (ret < 0)
		return ret;
	
	PRINT_DEBUG (("do_TCP_open: fd = %i", fd));
	return fd;
}

static int16 do_TCP_close (struct TCP_close_param p)
{
	gs_close (p.fd);
	return 0;
}

static int16 do_TCP_send (struct TCP_send_param p)
{
	return gs_write (p.fd, p.buf, p.len);
}

static int16 do_TCP_wait_state (struct TCP_wait_state_param p)
{
	return gs_wait (p.fd, p.timeout);
}

/* Incompatibility:  Does nothing.
 * lwIP handles this internally.
 */
static int16 do_TCP_ack_wait (struct TCP_ack_wait_param p)
{
	return E_NORMAL;
}

static int16 do_UDP_open (struct UDP_open_param p)
{
	int fd;
	int ret;
	
	fd = gs_open ();
	if (fd < 0)
		return fd;
	
	/* The UDP_OPEN_CMD command transmogrifies this descriptor into an
	 * actual connection.
	 */
	ret = gs_udp_open (fd, p.rhost, p.rport);
	if (ret < 0)
		return ret;
	
	return fd;
}

static int16 do_UDP_close (struct UDP_close_param p)
{
	gs_close (p.fd);
	return 0;
}

static int16 do_UDP_send (struct UDP_send_param p)
{
	return gs_write (p.fd, p.buf, p.len);
}

/* Incompatibility:  Does nothing.
 * MiNTnet handles its own "kicking"
 */
static int16 do_CNkick (struct CNkick_param p)
{
	return E_NORMAL;
}

static int16 do_CNbyte_count (struct CNbyte_count_param p)
{
	return gs_canread (p.fd);
}

static int16 do_CNget_char (struct CNget_char_param p)
{
	char c;
	long ret;
	
	ret = gs_read (p.fd, &c, 1L);
	if (ret < 0)
		return ret;
	
	if (ret == 0)
		return E_NODATA;
	
	return c;
}

static NDB *do_CNget_NDB (struct CNget_NDB_param p)
{
	return gs_readndb (p.fd);
}

static int16 do_CNget_block (struct CNget_block_param p)
{
	return gs_read (p.fd, p.buf, p.len);
}

static void do_housekeep (void)
{
	/* does nothing */
}

static int16 do_resolve (struct resolve_param p)
{
	return gs_resolve (p.dn, p.rdn, p.alist, p.lsize);
}

static void do_ser_disable (void)
{
	/* does nothing */
}

static void do_ser_enable (void)
{
	/* does nothing */
}

static int16 do_set_flag (struct set_flag_param p)
{
	int flg_val;

	if (p.flag < 0 || p.flag >= 64)
		return E_PARAMETER;
		
	flg_val = flags [p.flag];
	flags [p.flag] = 1;

	return flg_val;
}

static void do_clear_flag (struct clear_flag_param p)
{
	if (p.flag < 0 || p.flag >= 64)
		return;
	
	flags [p.flag] = 0;
}

static CIB *do_CNgetinfo (struct CNgetinfo_param p)
{
	GS *gs = gs_get (p.fd);
	
	if (!gs)
		return (CIB *) E_BADHANDLE;
	
	return &(gs->cib);
}

/* Incompatibility: None of the *_port() commands do anything.
 * Don't use a STiK dialer with GlueSTiK, gods know what will happen!
 */
static int16 do_on_port (struct on_port_param p)
{
	return E_NOROUTINE;
}

static void do_off_port (struct off_port_param p)
{
}

static int16 do_setvstr (struct setvstr_param p)
{
	return 0;
//	return gs_setvstr (p.vs, p.value);
}

static int16 do_query_port (struct query_port_param p)
{
	return E_NOROUTINE;
}

static int16 do_CNgets (struct CNgets_param p)
{
	return gs_read_delim (p.fd, p.buf, p.len, p.delim);
}

static TPL trampoline =
{
	TRANSPORT_DRIVER,
	"Scott Bigham, Frank Naumann (GlueSTiK\277 v" VER_MAJOR "." VER_MINOR ")",
	"01.13",
	do_KRmalloc,
	do_KRfree,
	do_KRgetfree,
	do_KRrealloc,
	do_get_err_text,
	do_getvstr,
	do_carrier_detect,
	do_TCP_open,
	do_TCP_close,
	do_TCP_send,
	do_TCP_wait_state,
	do_TCP_ack_wait,
	do_UDP_open,
	do_UDP_close,
	do_UDP_send,
	do_CNkick,
	do_CNbyte_count,
	do_CNget_char,
	do_CNget_NDB,
	do_CNget_block,
	do_housekeep,
	do_resolve,
	do_ser_disable,
	do_ser_enable,
	do_set_flag,
	do_clear_flag,
	do_CNgetinfo,
	do_on_port,
	do_off_port,
	do_setvstr,
	do_query_port,
	do_CNgets,
	NULL /* (int16 (*)(uint32, uint8, uint8, void *, uint16)) */,
	NULL /* (int16 (*)(int16 (*)(IP_DGRAM *), int16)) */,
	NULL /* (void (*)(IP_DGRAM *)) */
};

static DRV_HDR *do_get_dftab (char *tpl_name)
{
	/* we only have the one, so this is pretty easy... ;)
	 */
	if (strcmp (tpl_name, trampoline.module) != 0)
		return 0;
	
	return (DRV_HDR *) &trampoline;
}

static int16 do_ETM_exec (char *tpl_name)
{
	/* even easier... ;) */
	return 0;
}

static CONFIG stik_cfg;
DRV_LIST stik_driver =
{
	MAGIC,
	do_get_dftab,
	do_ETM_exec,
	&stik_cfg,
	NULL
};

int gs_init_stik_if (void)
{
	memset(flags, 0, sizeof(flags));
	memset(&stik_cfg, 0, sizeof(CONFIG));
	stik_cfg.client_ip = INADDR_LOOPBACK;
	return 1;
}

void gs_cleanup_stik_if (void)
{
}

#endif /* LWIP */
#endif /* NETWORK */

