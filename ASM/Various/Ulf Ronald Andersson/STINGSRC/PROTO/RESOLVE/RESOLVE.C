/*----------------------------------------------------------------------------*/
/* File name:	RESOLVE.C						Revision date:	1998.01.07	  */
/* Authors:		Ronald Andersson				Creation date:	1997.01.13	  */
/*----------------------------------------------------------------------------*/
/* Purpose:		High level STinG protocol for an Internet DNS resolver		  */
/*----------------------------------------------------------------------------*/

#include	<tos.h>
#include	<ctype.h>
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include	<sting\transprt.h>
#include	<sting\layer.h>
#include	<sting\resolve.h>

/*----------------------------------------------------------------------------*/

/* Change these macros to reflect the compile date, version etc of the module.*/
/* M_YEAR is (year - 1980), M_MONTH is the month from 1 (Jan.) to 12 (Dec.),  */
/* and M_DAY is day of month (1 ... 31)                                       */

#define	M_TITLE		"Resolver"
#define	M_VERSION	"01.08"
#define	M_YEAR		18
#define	M_MONTH		1
#define	M_DAY		7
#define	M_AUTHOR	"Ronald Andersson"

/*----------------------------------------------------------------------------*/

void		_appl_yield (void);

char		*Ca_first_dom(void);
char		*Ca_next_dom(void);
char		*Ca_curr_dom(void);
uint32		Ca_curr_IP(void);

int16		load_cache (void);
int16		save_cache (void);
int16		query_name (char *name, char *real, uint32 *IP_list, int16 size);
int16		query_IP (uint32 addr, char *real, uint32 *IP_list, int16 size);
void		update_cache (char *name, uint32 addr, uint32 ttl, int16 type);

int16	do_query (char item[], uint32 dns, int16 type, DNS_HDR **hdr, uint8 **data,
				  uint8 **qs, uint8 **as, uint8 **ns, uint8 **ais);
int16	check_reply (uint8 *data, int16 rep, DNS_HDR *hdr, uint8 **qs,
					 uint8 **as, uint8 **ns, uint8 **ais);
int16	track_section (uint8 *data, int16 size, uint8 *section, int16 num, int16 a_flg);
int16	track_domain (uint8 *data, int16 size, uint8 *label, char domain[]);

long		get_stik_cookie (void);
int16		install (void);
int16  cdecl  	my_resolve (char *domain, char **real_domain, uint32 *IP_list, int16 size);


DRV_LIST	*stik_drivers;
TPL			*tpl;
STX			*stx;

/* Put your name and version number of this module in here. */
LAYER		my_layer =
{	M_TITLE,
	M_VERSION,
	0L,
	(M_YEAR << 9) | (M_MONTH << 5) | M_DAY, 
    M_AUTHOR,
    0,
    NULL,
    NULL
};

char	fault[] = "RESOLVE.STX : STinG extension module. Only to be started by STinG !\r\n";
char	*cache, *hosts;
char	*c_file;

/*----------------------------------------------------------------------------*/

void  main (argc, argv)

int   argc;
char  *argv[];

{
	if (argc != 2)
	{
		Cconws (fault);	return;
	}

	if (strcmp (argv[1], "STinG_Load") != 0) {
        Cconws (fault);   return;
      }

   stik_drivers = (DRV_LIST *) Supexec (get_stik_cookie);

   if (stik_drivers == 0L)   return;

   if (strcmp (stik_drivers->magic, MAGIC) != 0)
        return;

   tpl = (TPL *) (*stik_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*stik_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl != (TPL *) NULL && stx != (STX *) NULL) {
        if (install())
             Ptermres (_PgmSize, 0);
      }
 }	/* ends function main */

/*----------------------------------------------------------------------------*/

long  get_stik_cookie()
{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }	/* ends function get_stik_cookie */

/*----------------------------------------------------------------------------*/

int16	install()
{
	LAYER  *layers;
	int16  path_len;

	if ((c_file = KRmalloc (256)) == NULL)
		return (FALSE);

	Dgetpath (c_file, 0);
	path_len = (int16) strlen (c_file);
	KRfree (c_file);

	if ((c_file = KRmalloc (path_len + 15)) == NULL)
		return (FALSE);

	c_file[0] = 'A' + Dgetdrv();   c_file[1] = ':';
	Dgetpath (& c_file[2], 0);
	strcat (c_file, "\\CACHE.DNS");

	if (load_cache() < 0)
	{	puts("\r\nDNS cache load failed !!!\r\n");
	}


	/* Fetch address of high level protocol layer chain. */

	query_chains (NULL, NULL, (void **) & layers);

	/* Find last entry of high protocol layer chain. */

	while (layers->next)
	layers = layers->next;

	/* Link our entry in high protocol layer chain. */

	my_layer.basepage = _BasPag;
	layers->next = & my_layer;

	/* Link our service (resolve) into TPL structure. */

	tpl->resolve = my_resolve;

	return (TRUE);
}	/* ends function install */

/*----------------------------------------------------------------------------*/

int16  cdecl  my_resolve (domain_p, real_domain_p_p, IP_list_p, size)

char	*domain_p,	**real_domain_p_p;
uint32	*IP_list_p;
int16	size;
{	DNS_HDR	*dns_hdr_p;
	uint32	host, main_dns, ttl;
	uint16	qtype, type, class, rd_len;
	int16	result = E_CANTRESOLVE;
	int16	data_size, i;
	uint8	*dns_data_p, *qd_p,*an_p,*ns_p,*ar_p;
	char	*scan, *work, *dom, *dom_name;
	char	ch, *server;

	if (real_domain_p_p)
		*real_domain_p_p = NULL;
	if ((size > 0)  &&  IP_list_p)
		*IP_list_p = 0;
	
	if ( (domain_p = is_unblank(domain_p)) == NULL )
		return (E_CANTRESOLVE);

	work = NULL;
	if (*domain_p == '[')
	{	for	( work = domain_p+1; isascii(*work) && isalpha(*work); work++)
			*work = toupper(*work);
		if		(strncmp (domain_p, "[LOAD]", 6) == 0)
		{	load_cache();
			goto rescurr_DNS;
		}
		if (strncmp (domain_p, "[SAVE]", 6) == 0)
		{	save_cache();
			goto rescurr_DNS;
		}
		if (strncmp (domain_p, "[FIRST]", 7) == 0)
		{	Ca_first_dom();
			goto rescurr_DNS;
		}
		if (strncmp (domain_p, "[NEXT]", 6) == 0)
		{	Ca_next_dom();
rescurr_DNS:	;
			if	( (work = Ca_curr_dom()) == NULL )
				return (E_CANTRESOLVE);
			goto resolve_DNS;
		}
		if (strncmp (domain_p, "[CNAME]", 7) == 0)
		{	type = DNS_A;
			goto	update_DNS;
		}
		if (strncmp (domain_p, "[ALIAS]", 7) == 0)
		{	type = DNS_CNAME;
update_DNS:		;
			if ( (server = strchr(domain_p, '=')) == NULL )
				return (E_CANTRESOLVE);
			*server++ = '\0';
			host = diptobip(server);
			dom =  domain_p;
			strcpy(dom, skip_space( strchr(dom, ']') + 1 ));
			if ( (work = strchr(dom, ' ')) != NULL )
				*work = '\0';
			else
				if	( (work = strchr(dom, '\t')) != NULL )
					*work = '\0';
			if	(is_domname(dom, strlen(dom)) == NULL
				||  host == 0
				||	strchr(dom,'.') == NULL
				)
				return (E_CANTRESOLVE);
			if ( (work = strchr(server, ':')) == NULL )
				ttl = 0x87654321L;	/* infinite */
			else
				ttl = atol(skip_space(work+1));
			update_cache(dom, host, ttl, type);
			work = NULL;
			goto resolve_DNS;
		}
		return (E_CANTRESOLVE);	/* error for all commands that can't resolve */
resolve_DNS:	;
	}	/* ends cache command parsing if clause */
	
	if ((dom_name = KRmalloc (256L)) == NULL)
		return (E_CANTRESOLVE);
	if ((dom = KRmalloc (256L)) == NULL)
	{	KRfree (dom_name);
		return (E_CANTRESOLVE);
	}

	if (is_dip (domain_p))				/* pure 4-group dotted IP ? */
	{	qtype = DNS_PTR;
		host = diptobip(domain_p);
		if ( size > 0 )					/* If there is room for another ip number */
			*IP_list_p = host;			/* store host in user's array/variable */
	}
	else
	{	qtype = DNS_A;
		if	(work == NULL)
			work = domain_p;
		strcpy (dom, work);
		if (strchr (dom, '.') == NULL)
		{	work = getvstr ("DOMAIN");
			if (work[0] && work[1])
			{	strcat (dom, ".");
				strcat (dom, work);
			}
		}
	}

	

	if (qtype == DNS_PTR)
		result = query_IP (host, dom_name, IP_list_p, size);
	else
		result = query_name (dom, dom_name, IP_list_p, size);

	if (result > 0)				/* result found in cache ? */
	{	if (real_domain_p_p)
			KRrealloc (*real_domain_p_p = dom_name, strlen (dom_name)+1);
		else
			KRfree (dom_name);
		KRfree (dom);
		return (result);		/* return with cache result */
	}

	for	( result = 0, ( server = getvstr("NAMESERVER") );
		  ( server && *server );
		  ( server = next_dip(server) )
		)
	{	main_dns = diptobip(server);
		if (qtype == DNS_PTR)
			strcat(biptodrip(host, dom),".IN-ADDR.ARPA");
		data_size = do_query(dom, main_dns, qtype, &dns_hdr_p, &dns_data_p, &qd_p,&an_p,&ns_p,&ar_p);
		if ( (data_size > 0)  &&  (an_p != NULL) )
		{	for (i=0, scan = an_p; (scan < dns_data_p+data_size) && (i++ < dns_hdr_p->AN_count); scan += rd_len)
			{	scan = pass_RRname(dns_data_p, scan, dom_name);
				type = (*scan++<<8) + *scan++;
				class = (*scan++<<8) + *scan++;
				ttl = ((((((uint32)*scan++<<8) + *scan++)<<8) + *scan++)<<8) + *scan++;
				rd_len = (*scan++<<8) + *scan++;
				if ( type != qtype  ||  class != 1 )
					continue;						/* search on */
/* Here we found something */
				work = scan;
				if ( (work < dns_data_p+data_size)  &&  (i <= dns_hdr_p->AN_count) )
				{	if (qtype == DNS_PTR)
						pass_RRname(dns_data_p, work, dom_name);
					else
						host = ((((((uint32)*work++<<8) + *work++)<<8) + *work++)<<8) + *work++;
					update_cache(dom_name, host, ttl, DNS_A);
					update_cache(dom, host, ttl, DNS_CNAME);
					if	( size > result )
						IP_list_p[result++] = host;
				}
			}	/* ends for-loop parsing for correct RRs */
		}
		if	(dns_hdr_p)		{	KRfree(dns_hdr_p);  dns_hdr_p = NULL;	}
		if	(dns_data_p)	{	KRfree(dns_data_p); dns_data_p = NULL;	}
		if	( result )
			break;
	}	/* ends for-loop to try each nameserver */

	if	( !result )
		if ( qtype == DNS_PTR )
		{	biptodip(host, dom_name);
			update_cache(dom_name, host, 3600, DNS_A);
			if	( size > result )
				IP_list_p[result++] = host;
		}
		else
			result = E_CANTRESOLVE;

	if (real_domain_p_p)
		KRrealloc (*real_domain_p_p = dom_name, strlen (dom_name)+1);
	else
		KRfree (dom_name);
	KRfree (dom);

	return (result);
}	/* ends function my_resolve */

/*----------------------------------------------------------------------------*/
/* End of file:		RESOLVE.C												  */
/*----------------------------------------------------------------------------*/
