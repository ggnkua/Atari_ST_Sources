/*  resolve.c                (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *	There are two parts to the resolver.  One part is a local
 *	cache of Resource Records in local format.  The other part
 *	is the actual query of nameservers.  The two parts interact
 *	in a simple way.  If a record is available in the local
 *	cache, it is used.  If not available, steps are taken to
 *	add it to the local cache.  Then local cache is queried
 *	again.
 *
 *	Local cache is a tree of label nodes in reverse order
 *	of domain name specification. (ie: netinfo.com.au becomes
 *	.->au->com->netinfo).  The tree is queried by reversing
 *	the order of the domain name, then each label is matched
 *	going down the tree.  If a label node (RCNODE) has an
 *	address associated with it, then the chain up to that
 *	point specifies a fully qualified domain name with that
 *	address.
 *
 *	Label names are kept consecutively in a single allocated
 *	string space.  This allows the possibility of `compression'
 *	by multiple use of the same label.  It also means searching
 *	the entire label space each time a new entry is added...
 *
 *	Three blocks of memory are allocated.  One is for an array
 *	of RCNODES, one is for an array of NSLIST, and the third is
 *	for label storage.  I need to do some investigation before
 *	deciding on an appropriate allocation for each (relative to
 *	each other).
 *
 *	Only Resource Records of type A, NS, CNAME will be cached.
 *	All other RR's will be discarded.  (Maybe store MX's later).
 *
 *	See below for comments regarding the NameServer queries
 */
#include "lattice.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <aes.h>
#include <tos.h>
#include <ext.h>			/* for delay() - temp */

#include "globdefs.h"
#include "globdecl.h"
#include "resolve.h"
#include "krmalloc.h"
#include "display.h"

#define QT_A		1
#define QT_NS		2
#define QT_CNAME	5
#define QT_SOA		6
#define QT_PTR		12
#define QC_IN		1


/* Macros for alignment problems on 68000 */

/* bigendian */

#define SETINT16(v,p)		(v) = ( ( *(p) << 8 ) & 0xff00 ) + \
								  ( *((p)+1) & 0x00ff );
#define SETINCINT16(p,v)	*(p)++ = (v << 8) & 0xff; \
							*(p)++ = (v) & 0xff;
#define VALUINT16(p)		( ( (*(p) << 8 ) & 0xff00 ) + \
							  ( *((p)+1) & 0x00ff ) )
#define SETUINT32(v,p)		(v) = ( ( (uint32)*(p) << 24 ) & 0xff000000L ) + \
								  ( ( (uint32)*((p)+1) << 16 ) & 0x00ff0000L ) + \
								  ( ( (uint32)*((p)+2) << 8 ) & 0x0000ff00L ) + \
								  ( ( (uint32)*((p)+3) & 0x000000ffL ) );
								  
/* Resolver data types	*/

uint32	mmns;


typedef union {
    uint32  ipa;    /* A 32 bit address         */
    uint8   ddf[4]; /* dotted decimal fields    */
} IPA;


int16 resolveinit(void)
{
	char *p;

	/* expand for more nameservers in future */

	p = getvstr("NAMESERVER");

	if (strcmp(p, "0") == 0)
	{
		setvstr("NAMESERVER","127.0.0.1");
		p = getvstr("NAMESERVER");
	}
	
	mmns = dd_to_ip(p);
	return 0;
}

int16 cdecl
Set_DNS(char *dns)
{
	/* expand for more nameservers in future */

	setvstr("NAMESERVER",dns);
	
	mmns = dd_to_ip(dns);

	return 0;
}


/* RR_HDR fields in the RR header
 */

typedef struct rr_hdr {
	uint16	id;
	unsigned qr : 1;
	unsigned opcode : 4;
	unsigned aa : 1;
	unsigned tc : 1;
	unsigned rd : 1;
	unsigned ra : 1;
	unsigned z  : 3;
	unsigned rcode : 4;
	uint16	qdcount;
	uint16	ancount;
	uint16	nscount;
	uint16	arcount;
} DNSMSGHDR;

typedef DNSMSGHDR RR_HDR;			/* compatibility only */


/*  dd_to_ip(dn)    If dn is valid dotted decimal, return an IP address
 *                  otherwise 0L.  dd field may may quoted with [ and ]
 *                  The dn string is assumed to have NO leading or
 *                  trailing whitespace, or any other garbage.
 */

uint32 dd_to_ip(char *dn)
{
    char *s = dn;
    int16 len = 0, x = 0, i;
    IPA a;

    while (*s) {
        if (*s == '[' && len != 0)
            return ((uint32)0L);    /* Invalid dn AND dd    */

        if (*s == ']' && s[1] != '\0')
            return ((uint32)0L);    /* Invalid dn AND dd    */

        else if (*s == '.')
            x += 1;

        else if (!isdigit(*s))		/* Not dotted decimal, but	*/
        	return ((uint32)0L);    /* Might be a valid domain name */

        len += 1;
        s += 1;
    }

    if (x != 3)
        return ((uint32)0L);        /* dd has exactly 3 .'s     */

    if (dn[0] == '[' ) {
        len -= 1;
        if (dn[len] != ']')
            return ((uint32)0L);
        s = &dn[1];
    }
    else {
        s = dn;
    }

    for (i = 0; i < 4; ++i) {
        len = (int16)strcspn(s, ".");
        if (len == 0)
            return ((uint32)0L);

        x = atoi(s);
        if (x > 255)
            return ((uint32)0L);
        a.ddf[i] = x;

        s = &s[len+1];
    }
    return (a.ipa);
}


/* valid_dn()   This function is called AFTER dd_to_ip() has done
 *              some tests.  I believe that the rules have softened
 *              somewhat, allowing labels to begin with digits.
 *              So, digits must not pre or postfix labels, dots
 *              must not be adjacent.  Each label must contain
 *              at least one letter.
 */

static int16 valid_dn(char *s)
{
    int16 let_cnt = 0, new_lab = TRUE;

    while (*s) {
        if (isalpha(*s)) {
            let_cnt = 1;
        }
        else if (*s == '.') {
            if (new_lab) {      /* dn starts with dot, or dots adjacent */
                return (FALSE);
            }
            else if (let_cnt == 0) {    /* No letters in prev label     */
                return (FALSE);
            }

            new_lab = TRUE;
            let_cnt = 0;
            s += 1;
            continue;
        }
        else if (*s == '-') {
            if (new_lab || s[1] == '-' || s[1] == '\0')
                return (FALSE);
        }
        else if (!isdigit(*s)) {
            return (FALSE);
        }
        new_lab = FALSE;
        s += 1;
    }

    return (TRUE);
}



void compressname( char *c, const char *dn )
{
	char *p = (char *) dn;
	char *cnt = c;
	uint8	i=0;
	
	do
	{
		c++;
		while( (*p != '.') && (*p !='\0') )
		{
			*c++ = *p++;
			i++;
		}
		*cnt = i;
		i = 0;
		cnt = c;
	} while (*p++ != '\0');
	*c = '\0';
}

char *
decodedomain( const char *head, char **dom )
{
	char	name[MAXDOMAINLEN];
	char	*p = (char *) &name[0];
	char	*d = *dom;
	int		len;
	uint8	len2;
	int		comp=0;

	while ( *d != '\0' )
	{
		SETINT16(len,d)
		/*len = *(int *)d;*/
		len2 = *d;
		d++;
		if ( comp == 0 )
		{
			(*dom)++;
		}
		
		if (( len & 0xC000 ) == 0xC000 )
		{
			d = (char *) head + ( len & 0x2FFF );
			comp = 1;
		}
		else
		{
			strncpy(p, d, len2);
			p += len2;
			d += len2;
			if (comp == 0)
			{
				*dom += len2;
			}
			*p++ = '.';
		}
	}

	*--p = '\0';

	(*dom)++;

	if ( ( p = STiKmalloc( strlen(name) + 1 ) ) == NULL )
		return NULL;

	strcpy(p,name);

	return p;
}

void
do_resolve(void)
{
	if (set_flag(FL_do_resolve))	/* Avoid recursion	*/
		return;


	clear_flag(FL_do_resolve);
}

uint32 doquery( const char *dn )
{
	char *msg;
	NDB	*resp;
	DNSMSGHDR	*hdr;
	char *qp;			/* pointer to question */
	char *ap;			/* pointer to answer */
	int16	msglen = (int16)(sizeof(DNSMSGHDR) + (strlen(dn) + 2) + 4);
	int16	dnscon;
	uint16	msgid;
	uint32	ans;
	
	msg = STiKmalloc( msglen );

	hdr = (DNSMSGHDR *) msg;
	qp = msg + sizeof(DNSMSGHDR);

	/* Complete message header */

	hdr->id = msgid = (uint16)(clock() & 0xffff);	/* change to Sclock for int */
	hdr->qr = 0;							/* query */
	hdr->opcode = 0;						/* standard query */
	hdr->aa = 0;							/* authoritative bit */
	hdr->tc = 0;							/* message truncated bit */
	hdr->rd = 1;							/* recursion desired bit */
	hdr->ra = 0;							/* recursion avail */
	hdr->z = 0;								/* reserved */
	hdr->rcode = 0;							/* response type */
	hdr->qdcount = 1;						/* num of questions */
	hdr->ancount = 0;
	hdr->nscount = 0;
	hdr->arcount = 0;

	compressname(qp,dn);
	qp += strlen(dn) + 2;

	SETINCINT16(qp,QT_A)
	SETINCINT16(qp,QC_IN)

	/* send the query */
	
	if ((dnscon = UDP_open( mmns, 53 )) < 0) /* No connection possible */
   	    return (E_LOSTCARRIER);

repeat:
	resp = CNget_NDB( dnscon );

	while ( resp == NULL )
	{
		clock_t retrans;
	
		(void) UDP_send( dnscon, msg, msglen );

		retrans = Sclock() + (CLK_TCK * 2);

		while ( ( retrans > Sclock() ) && ( resp == NULL ) )
		{
			resp = CNget_NDB( dnscon );
			(*yield)();
		}
	}
	
	hdr = (DNSMSGHDR *) resp->ndata;

	if (hdr->id != msgid)
	{
		intfree_NDB( resp );
		goto repeat;
	}

	while(STiKfree(msg) == E_LOCKED)
		;
	
	if (hdr->ra == 0)
		disp_info("STiKresolver: no recursion available");

	if (hdr->rcode!=0)
	{
		switch (hdr->rcode)
		{
			case 3:
			{
				intfree_NDB(resp);
				(void) UDP_close( dnscon );
				return E_NOHOSTNAME;
			}
			case 1:
			{
				intfree_NDB(resp);
				(void) UDP_close( dnscon );
				return E_DNSBADFORMAT;
			}
			default:
				break;
		}
	}
	else
	{
		int	answercnt = hdr->ancount;
		char *dn;
		
		ap = (char *)hdr+ sizeof(DNSMSGHDR);
		
		dn = decodedomain((char *)hdr, &ap);

		while(STiKfree(dn) == E_LOCKED)
			;
		
		/* Skip type/class */

		ap += 4;
		
		/* answer processing */
		
		while (answercnt-- != 0)
		{
		
		/* Get the domain name	*/

		dn = decodedomain((char *)hdr, &ap);

		while(STiKfree(dn) == E_LOCKED)
			;

		switch (VALUINT16(ap))
		{
			case QT_A:
				ap += 10;
				SETUINT32(ans,ap)
				ap += 4;
				break;

			case QT_CNAME:
				ap += 10;
				dn = decodedomain((char *)hdr, &ap);
						
				while(STiKfree(dn) == E_LOCKED)
					;
							
				break;

			default:	
				disp_info("STiKresolve: type not A, type %d.",*(uint16 *)ap);
		} /* switch */
		} /* while answercnt */
	}

	intfree_NDB(resp);
	
	(void) UDP_close( dnscon );
	
	return ans;
}

int16 cdecl resolve(char *dn, char **rdn, uint32 *adr_list, int16 lsize)
{
	uint32	a;
	
	/*disp_info("resolve dn %s rdn %p",dn,rdn);*/

	if ( rdn != (char **) NULL)
	{
		*rdn = NULL;
	}

	if ( lsize <= 0 )		/* meant for reverse in-addr.arpa lookups */
	{
		return 0;
	}

	a = dd_to_ip(dn);

	if (a)
	{
		adr_list[0] = a;
		goto copy_rdn;		
	}

	/* Check for localhost */
	if (strcmp(dn, "localhost") == 0)
	{
		adr_list[0] = config.localhost;
		goto copy_rdn;
    }	

	/* Check local cache */
	
	/* Not found.. add query */
	
	a=doquery(dn);

	if (a == E_NOHOSTNAME)			/* HACK until I fix this */
		return (int16) a;
	
	adr_list[0] = a;

copy_rdn:

	if ( rdn != (char **) NULL )
	{
		*rdn = STiKmalloc((unsigned long)strlen(dn)+1);
		strcpy(*rdn,dn);
	}

	/*disp_info("resolve after doquery returned %lx",a);*/

	return 1;	
}


/* int_DNS
 * 
 * This will simulate an internal DNS server
 * eventually it should search some cache or routing table
 * I think ;)
 */
int16
int_DNS(NDB *pkt,UDP_HDR *udphd, uint32 d_ip)
{
   GPKT *p;
	DNSMSGHDR	*hdr;
    PH psh;
    uint16 sum = 0;
    UDP_HDR *udph;
    IP_HDR *iph;
    struct ip_options opts;

	hdr = (DNSMSGHDR *) pkt->ndata;

	hdr->rcode = 3;

	hdr->ra = 1;
	
    p = mkpacket(d_ip, pkt->len + (int16)sizeof(UDP_HDR), (int16)P_UDP);
    if (p == (GPKT *)NULL)
        return (E_NOMEM);

	p->mlen = pkt->len + (int16)sizeof(UDP_HDR);

    iph = (IP_HDR *)p->pip;
    udph = (UDP_HDR *)p->mp;

    udph->sport = udphd->dport;
    udph->dport = udphd->sport;
    udph->length = p->mlen;
    udph->sum = 0;

    p->data = (char *)&udph[1];
    memcpy(p->data, pkt->ndata, pkt->len);

    psh.s_ip = iph->s_ip;
    psh.d_ip = iph->d_ip;
    psh.ptcl = iph->ptcl;
    psh.len = p->mlen;

    sum = oc_sum((char *)&psh, (uint16)sizeof(PH));
    sum = calc_sum((char *)p->mp, sum, p->mlen);
    if (sum == 0)
        sum = 0xffff;

    udph->sum = sum;

	/* Get connection's tos and ttl from CCB */
	
	opts.tos = 0;
	opts.ttl = config.ttl;

    ip_send(p, &opts, FLAG_LF);

	intfree_NDB(pkt);
	
	return(E_NORMAL);
}