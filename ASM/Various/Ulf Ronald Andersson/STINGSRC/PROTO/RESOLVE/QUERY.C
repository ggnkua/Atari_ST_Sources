/*----------------------------------------------------------------------------*/
/* File name:	QUERY.C							Revision date:	1997.09.24	  */
/* Authors:		Peter Rottengatter  &			Creation date:	1997.03.24	  */
/*				Ronald Andersson											  */
/*----------------------------------------------------------------------------*/
/* Purpose:		DNS Query functions											  */
/*----------------------------------------------------------------------------*/

#include	<tos.h>
#include	<stdio.h>
#include	<string.h>

#include	<sting\transprt.h>
#include	<sting\layer.h>
#include	<sting\resolve.h>

#define	DNS_TIMEOUT 10000L
#define	UDP_MAX_TRIES 3

void	_appl_yield (void);

int16	do_query (char item[], uint32 dns, int16 type, DNS_HDR **hdr_p_p, uint8 **data_p_p,
				  uint8 **qs, uint8 **as, uint8 **ns, uint8 **ais);
int16	check_reply (uint8 *data_p, int16 rep, DNS_HDR *hdr_p,
					 uint8 **qs, uint8 **as, uint8 **ns, uint8 **ais);
int16	track_section (uint8 *data_p, int16 size, uint8 *section, int16 num, int16 a_flg);
int16	track_domain (uint8 *data_p, int16 size, uint8 *label, char domain[]);

uint16	identifier = 0;


/*----------------------------------------------------------------------------*/
/* function do_query:                                                         */
/* Do a nameserver query, i.e. send a request and receive reply. item         */
/* points to domain name to resolve. dns is the nameserver IP address. type   */
/* is type of query, for normal domain name resolve (`A' query) this is 1.    */
/* rest will be filled in : hdr_p_p a ptr to dns struct header, data_p_p      */
/* a pointer to reply data section. qs, as, ns, ais are pointers into the     */
/* reply data, pointing to query section, to answer section, authority        */
/* section, and additional records section, respectively.                     */
/* Whatever the return value, the hdr and data blocks must be KRfreed         */
/* eventually                                                                 */
/*----------------------------------------------------------------------------*/
/* return:	length of data area or negative error code                        */
/*----------------------------------------------------------------------------*/


int16	do_query (item, dns, type, hdr_p_p, data_p_p, qs, as, ns, ais)

char	item[];
uint32	dns;
int16	type;
DNS_HDR	**hdr_p_p;
uint8	**data_p_p, **qs, **as, **ns, **ais;

{
	uint16	*tcp_query_msg;
	DNS_HDR	*udp_query_msg;
	uint8	*query, num;
	int16	length, handle, reply, len, udp_try;
	int32	timeout, wait_time;
	char	*walk, *ptr;
	CIB		*dns_CIB_p = NULL;
	uint16	icmp_error = 0;

/* Prepare return pointers */

	*hdr_p_p  = NULL;
	*data_p_p = *qs = *as = *ns = *ais = NULL;

/* A domain name is never longer than 256 Chars, plus the header and some query */
/* data restricts the query packet size to 270 characters.                      */

	if ((tcp_query_msg = (uint16 *) (query = KRmalloc (272L))) == NULL)
	{
		return (-1);
	}
	udp_query_msg = (DNS_HDR *)(tcp_query_msg+1);  /* same message, excluding length word */

/* Fill in header data */

	udp_query_msg->ident    = identifier++;               /* Unique identifier  */
	udp_query_msg->qr_flg   = 0;   udp_query_msg->op_code  = 0;    /* Query flag, op_code */
	udp_query_msg->aa_flg   = 0;   udp_query_msg->tc_flg   = 0;    /* Authoritative reply flag, truncation flag */
	udp_query_msg->rd_flg   = 1;   udp_query_msg->ra_flg   = 0;    /* Recursive flag, recursive answer flag*/
	udp_query_msg->zero     = 0;   udp_query_msg->reply    = 0;    /* reserved, return (error) code */

	udp_query_msg->QD_count = 1;   udp_query_msg->AN_count = 0;    /* one query entry, no answer entry for now */
	udp_query_msg->NS_count = 0;   udp_query_msg->AR_count = 0;    /* none in other sections either */

/* Fill in query section (straight after header) */
	query = (uint8 *) (udp_query_msg + 1);
	walk = item;

/* Construct DNS representation of a domain name, and put in packet */
	while ((ptr = strchr (walk, '.')) != NULL)
	{
		/* length of label */
		num = (uint8) (ptr - walk);
		/* Save it, then the label itself. */
		*query++ = num;   strncpy (query, walk, num);   query += num;
		/* Next label from domain name */
		walk += num + 1;
	}

/*Put in the rest (last label) of domain name */
	if (*walk != '\0')
	{
		num = (uint8) strlen (walk);
		*query++ = num;   strcpy (query, walk);   query += num;
	}
/*Fill in domain name 'root' (teminator) */
	*query++ = '\0';

/* Fill in query data : type (type `A' query is 1), and class ('IN' for internet) */
	*query++ = (uint8) (type >> 8); *query++ = (uint8) type;
	*query++ = 0; *query++ = 1;

/* Length of complete packet */
	length = (int16) (query - (uint8 *) udp_query_msg);
	*tcp_query_msg = length;

/* Get space for reply packet header */
	if ((*hdr_p_p = (DNS_HDR *) KRmalloc (sizeof (DNS_HDR))) == NULL)
	{
		KRfree (tcp_query_msg);
		return (-1);
	}

/* Open UDP channel to DNS port (53) */
	if ((handle = UDP_open (dns, 53)) < 0)
	{
		KRfree (tcp_query_msg);
		return (-2);
	}

	for(udp_try = 0; udp_try++ < UDP_MAX_TRIES;)
	{
		UDP_send (handle, udp_query_msg, length);
		timeout = TIMER_now();
		wait_time = 0;

		while (CNbyte_count (handle) < sizeof (DNS_HDR))
		{	/* While not enough data yet, yield CPU to other apps */
			_appl_yield();
			if	( (uint32) (dns_CIB_p = CNgetinfo(handle)) > 0)
				icmp_error = dns_CIB_p->status;
			if	(icmp_error || (wait_time = TIMER_elapsed(timeout)) > DNS_TIMEOUT)
				break;			/* exit waiting loop on timeout or on error */
		}
		if	(icmp_error || wait_time <= DNS_TIMEOUT)
			break;				/* exit retry loop if no timeout or if error */
	}							/* loop back to retry until max tries reached */
	if	(icmp_error || udp_try >= UDP_MAX_TRIES)
	{
		KRfree (tcp_query_msg);
		UDP_close (handle);
		return (-3);
	}

/* Read reply header */
	if (CNget_block (handle, *hdr_p_p, sizeof (DNS_HDR)) != sizeof (DNS_HDR))
	{
		KRfree (tcp_query_msg);
		UDP_close (handle);
		return (-2);
	}

/* With UDP, either all or nothing is there. Since the header is there, */
/* the rest must be there too. This is how much.         */
	reply = CNbyte_count (handle);

/* Get space for the rest */
	if ((*data_p_p = (uint8 *) KRmalloc (reply)) == NULL)
	{
		KRfree (tcp_query_msg);
		UDP_close (handle);
		return (-1);
	}

/* Fetch reply rest */
	if (CNget_block (handle, *data_p_p, reply) != reply)
	{
		KRfree (tcp_query_msg);
		UDP_close (handle);
		return (-2);
	}
/* That's all */
	UDP_close (handle);

/* Check : Has it been truncated ? If not, we're ready */
/* we also accept truncated response if answer section is complete */
/* except if that section happens to be empty */
	if	( (check_reply (*data_p_p, reply, *hdr_p_p, qs, as, ns, ais) == 0)
		||  ( (*as != NULL)  &&  (*hdr_p_p)->QD_count )
		)
	{
		KRfree (tcp_query_msg);
		return (reply);
	}

/* Truncated, so throw away, and start all over again, this time with TCP */
	KRfree (*data_p_p);   *data_p_p = NULL;

/* Open channel */
	if ((handle = TCP_open (dns, 53, 0, 1000)) < 0) {
		KRfree (tcp_query_msg);
		return (-2);
      }
/* Send query */
	TCP_send (handle, tcp_query_msg, length);
/* Won't need the query data anymore */
	KRfree (tcp_query_msg);

	timeout = TIMER_now();

	while (CNbyte_count (handle) < sizeof (DNS_HDR))
	{
		_appl_yield();
		if (TIMER_elapsed(timeout) > DNS_TIMEOUT)
		{
			TCP_close (handle, 0);
			return (-3);
		}
	}

	if (CNget_block (handle, *hdr_p_p, sizeof (DNS_HDR)) != sizeof (DNS_HDR))
	{
		TCP_close (handle, 0);
		return (-2);
	}
/* Got the header now.*/

/* Get space for rest. Assuming that it won't be more than 10k. This is somewhat */
/* arbitrary, but sensible, I guess */

	if ((ptr = *data_p_p = (uint8 *) KRmalloc ((long) (length = 10000))) == NULL)
	{
		TCP_close (handle, 0);
		return (-1);
	}

	while ((len = CNbyte_count (handle)) >= EOF)
	{
		if (len > length)
		{
			/* Received more than 10k. Can't handle. return */
			TCP_close (handle, 0);
			return (-4);
		}

		/* Fetch piece by piece, until complete */
		if (CNget_block (handle, ptr, len) != len)
		{
			TCP_close (handle, 0);
			return (-2);
		}
		length -= len;	/* length = remaining unused room */
		ptr += len;		/* ptr  --> remaining unused room */

		/* timeout 15 secs for all (including header) */
		if ((int32) Supexec (sys_timer_supx) - timeout > 3000L)
		{
			TCP_close (handle, 0);
			return (-3);
		}
		_appl_yield();

	}	/* ends while-loop to get all blocks until EOF */

	TCP_close (handle, 0);
/* Got the data, we're happy */

	ptr = *data_p_p;
	reply = 10000 - length;		/* reply = total_room - free_room */

/* Attempt to release unused part of block. Just realised there is the      */
/* core function KRrealloc doing just this. If I don't know, who else ? ;-) */
	if ((*data_p_p = (uint8 *) KRmalloc (reply)) == NULL)
		*data_p_p = ptr;
	else
	{
		memcpy (*data_p_p, ptr, reply);
		KRfree (ptr);
	}

/* Check : everything there ? */
	if (check_reply (*data_p_p, reply, *hdr_p_p, qs, as, ns, ais) == 0)
	{
		return (reply);
	}

	return (-5);
}	/* ends function do_query */

/*----------------------------------------------------------------------------*/

/* Check for completeness. Fill is pointers */
/* data_p and reply is pointer and size of data, rest see do_query() */
/* for incomplete sections the pointer returned (poked) will be NULL */

int16	check_reply (data_p, reply, hdr_p, qs, as, ns, ais)

DNS_HDR	*hdr_p;
uint8	*data_p;
int16	reply;
uint8	**qs, **as, **ns, **ais;

{
	int16	len;
	uint8	*tmp_p;

	if (hdr_p->tc_flg)   return (-1);

	*qs = *as = *ns = *ais = NULL;

	tmp_p = data_p;
/* Check if query section is complete */
	if ((len = track_section (data_p, reply, tmp_p,  hdr_p->QD_count, 0)) < 0)
		return (-1);	/* exit if query section incomplete */
	*qs = tmp_p;

	tmp_p = *qs + len;
/* Check if answer section is complete */
	if ((len = track_section (data_p, reply, tmp_p,  hdr_p->AN_count, 1)) < 0)
		return (-1);	/* exit if answer section incomplete */
	*as = tmp_p;

	tmp_p = *as + len;
/* Check if authority section is complete */
	if ((len = track_section (data_p, reply, tmp_p,  hdr_p->NS_count, 1)) < 0)
		return (-1);	/* exit if NS-authority section incomplete */
	*ns = tmp_p;

	tmp_p = *ns + len;
/* Check if additional records section is complete */
	if ((len = track_section (data_p, reply, tmp_p, hdr_p->AR_count, 1)) < 0)
		return (-1);	/* exit if additional info section incomplete */
	*ais = tmp_p;

	return (0);
}

/*----------------------------------------------------------------------------*/

/* Checks a section. data_p and size is the data block (address and size) */
/* section is a pointer to the section to check, num_entry is number of entries */
/* in that section. a_flg tells if the section contains additonal information */
/* that is available only in reply sections.        */


int16  track_section (data_p, size, section, num_entry, a_flg)

uint8  *data_p, *section;
int16  size, num_entry, a_flg;

{
	int16  count, len;

	for (count = 0; num_entry > 0; --num_entry)
	{
		if (a_flg)
		{
			if ((len = track_domain (data_p, size, section, NULL)) < 0)
				return (-1);
			len += 8;							/* pass RR type,class,ttl */
			if (section + len >= data_p + size)
				return (-1);
			len += 2 + (*(section + len)<<8) + *(section + len + 1);
			/* past RR RDlength & data */
		}
		else
		{
			if ((len = track_domain (data_p, size, section, NULL)) < 0)
				return (-1);
			len += 4;						/* pass Qtype, Qclass */
		}
		if (section + len > data_p + size)
			return (-1);
		count += len;
		section += len;
	}
	return (count);

}	/* ends function track_section */

/*----------------------------------------------------------------------------*/

/* Track a domain name in DNS format. Follow compression links, but do no */
/* count those when returning the size of the data */
/* data_p and size see track_section(), label is a pointer to domain name data */
/* domain is pointer to a string into which the mnemonic version of the domain */
/* name is copied into.  */

int16	track_domain (data_p, size, label, domain)

uint8	*data_p, *label;
int16	size;
char	domain[];

{
	int16 len = pass_RRname (data_p, label, domain) - label;

	return ( (label+len > data_p+size) ? -1 : len );
}	/* ends function track_domain */

/*----------------------------------------------------------------------------*/
/* End of file:	QUERY.C														  */
/*----------------------------------------------------------------------------*/
