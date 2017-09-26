#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ext.h>
#include <atarierr.h>
#include <sockerr.h>
#include <socket.h>
#include <sfcntl.h>
#include <in.h>

#include "network.h"
#include "resolver.h"

#include "stiplink.h"

/* undefine if not allowed: */
#define REKURS_QUERY

/* ms to wait between answer-pollings in res_send */
#define POLL_WAIT 50

/* Used by dn_* from Mint-Net */
#define INDIR_MASK 0xc0
#define MAXLABEL 63
static int dn_find(uchar *exp_dn, uchar *msg, uchar **dnptrs, uchar **lastdnptr);

/* Cache (only stores last request) */
#define RC_MAX_NAME	256		/* Max. len of hostname in request */
#define RC_MAX_ANSW	1024	/* Max. memory to store answer */

char	rc_last_name[RC_MAX_NAME];	/* Last hostname requested */
uchar	rc_last_answ[RC_MAX_ANSW];	/* Last answer from DNS */
int		rc_last_answ_len;						/* Used bytes in buffer */
int		rc_last_ok;									/* Last query was successfull */
int		resolver_initialized=0;			/* Execute only first init */

extern default_values defaults;


uint	idc=1; /* Init ID-Counter for queries */

uint res_get_id(void)
{
	return(idc++);
}

int check_name(char *src)
{/* Checks if <src> is a legal host-name:
		len is <= 255 octets
		First octet is a character <a-z> or <A-Z>
		all middle octets are a char, a digit, a hyphen or a dot
		last octet is a char or a digit
		returns E_OK or ERROR
	*/

	/* Check len */
	if(strlen(src) > 255)
		return(ERROR);
			
	/* Check first */
	if(*src==0) return(E_OK);
	
	if( ((*src < 'a')||(*src > 'z')) &&
			((*src < 'A')||(*src > 'Z'))
		)return(ERROR);
	
	/* Check middle*/
	++src;
	while(*src)
	{
		if( ((*src < 'a')||(*src > 'z')) &&
				((*src < 'A')||(*src > 'Z')) &&
				((*src < '0')||(*src > '9')) &&
				(*src != '-')&&(*src != '.')
			)return(ERROR);
		++src;
	}
	
	/* Check last */
	--src;
	if( ((*src < 'a')||(*src > 'z')) &&
			((*src < 'A')||(*src > 'Z')) &&
			((*src < '0')||(*src > '9'))
		)return(ERROR);
	
	return(E_OK);
}

void conv_name(char *dst, char *src)
{/* Converts a string of type "<label>.<label>...<0>"
    to "<len><label><len><label>...<0>"
    Note: Thus the <dst>-string must offer 1 octet more of memory!
  */
  char	*last=dst;
  char	c;
  
	do
	{
		++dst;
		c=0;
  	while((*src != '.') && (*src))
		{
			*dst++=*src++;
			++c;
		}
		if(*src) ++src; /* Ommit '.' */
		else	*dst=0;		/* Terminte <dst> */
		*last=c;
		last=dst;
	}while(*src);
}

void cdecl res_init(void)
{
	if(resolver_initialized) return;
	while(!set_flag(RES_CACHE));
	rc_last_name[0]=0;	/* Last hostname requested */
	rc_last_answ[0]=0;	/* Last answer from DNS */
	rc_last_answ_len=0;						/* Used bytes in buffer */
	rc_last_ok=0;									/* Last query was successfull */
	resolver_initialized=1;
	clear_flag(RES_CACHE);
	return;
}

int mac_resolve(char *dname, uchar *answer)
{
	dns_header	*dh;
	ulong				ip;
	
	if((ip=x_resolve(dname)) == INADDR_NONE) return(ERROR);

	/* Fake up an DNS-answer that can be processed by <get_hostent> */
	dh=(dns_header*)answer;
	dh->qdcount=0;
	dh->ancount=1;
	dh->records[0].r_class=C_IN;
	dh->records[0].r_type=T_A;
	dh->records[0].r_size=4;
	*(ulong*)(&(dh->records[0].r_data[0]))=ip;
	return(E_OK);
}

int cdecl res_query(char *dname, int class, int type, uchar *answer, int anslen)
{
	uchar	*buf;
	uint	tlen;
	int		ierr;
	dns_header	*dnsh;

	#ifdef iodebug
		Dftext("[Resolver incoming:"); 
		Dftext(dname); Dftext(","); Dfnumber(class); Dftext(",");
		Dfnumber(type); Dftext(","); Dfnumber(anslen); Dftext("]\r\n");
	#endif	

	if(defaults.using_mac_os)
		return(mac_resolve(dname, answer));
	
	if(check_name(dname) != E_OK) return(EINVAL);

	while(!set_flag(RES_CACHE));
	if(rc_last_ok)	/* Test for cache hit */
	{
		if(strcmp(dname, rc_last_name)) goto no_hit;
		tlen=rc_last_answ_len;
		if(tlen > anslen)	goto no_hit;
		while(tlen--)
			answer[tlen]=rc_last_answ[tlen];
		clear_flag(RES_CACHE);
		return(rc_last_answ_len);
	}
	
no_hit:	
	clear_flag(RES_CACHE);
	rc_last_ok=0;
	tlen=(uint)strlen(dname);
	if(tlen < RC_MAX_NAME)
		strcpy(rc_last_name, dname);
	tlen+=(uint)sizeof(dns_header);
	tlen+=2*(uint)sizeof(uint); /* QTYPE and QCLASS */
	tlen+=2; /* Leading len-octet for first label and trailing zero-octet */

	buf=tmalloc(tlen);
	if(buf==NULL)
		return(ENSMEM);

	#ifdef iodebug
		Dftext("[Resolver setting up query]\r\n");
	#endif

	ierr=res_mkquery(QUERY, dname, class, type, NULL, 0, NULL, (char*)buf, tlen);

	#ifdef iodebug
		Dftext("[Resolver query done]\r\n");
	#endif

	if(ierr < 0)
	{
		ifree(buf);
		return(ierr);
	}

	#ifdef iodebug
		Dftext("[Resolver goto send, buffer "); Dfnumber(anslen); Dftext("]\r\n");
	#endif	
	ierr=res_send((char*)buf, ierr, (char*)answer, anslen);
	if(ierr < 0)
		return(ierr);
	
	dnsh=(dns_header*)answer;
	if(dnsh->val1 & AA)
	{/* Authoriative answer without answer? */
		if(dnsh->ancount == 0)
		{
			return(NO_DATA);
		}
	}
	
	if((dnsh->val2 & RCODE) != NOERROR)
		switch(dnsh->val2 & RCODE)
		{
			case NXDOMAIN:
				return(HOST_NOT_FOUND);
			case SERVFAIL:
				return(TRY_AGAIN);
			default:
				return(NO_RECOVERY);
		}

	if(ierr < RC_MAX_ANSW)		/* Copy to cache */
	{
		while(!set_flag(RES_CACHE));
		rc_last_ok=1;
		rc_last_answ_len=tlen=ierr;
		while(tlen--)
			rc_last_answ[tlen]=answer[tlen];
		clear_flag(RES_CACHE);
	}
		
	return(ierr);
}

int cdecl res_search(char *dname, int class, int type, uchar *answer, int anslen)
{/* Should take care of options RES_DEFNAMES and RES_DNSRCH
		but for now, it doesn't */
	return(res_query(dname, class, type, answer, anslen));
}

int cdecl res_mkquery(int op, char *dname, int class, int type, char *data, int datalen, void *notused, char *buf, int buflen)
{/* <unused> is the newrr-struct */
	dns_header	dnsh;
	uchar				*src, *dst;
	char				*cname;
	uint				tlen, c;

	if(notused != NULL)
	{
		return(EOPNOTSUPP);
	}
	
	if(op==IQUERY)	/* data is used */
		tlen=datalen;
	else
	{
		if(check_name(dname) != E_OK)
			return(EINVAL);
		tlen=(int)strlen(dname);
	}

	tlen+=(int)sizeof(dns_header);
	tlen+=2*(int)sizeof(uint); /* QTYPE and QCLASS */
	tlen+=2; /* Leading len-octet for first label and trailing zero-octet */
	
	if(tlen > buflen)
		return(ERROR);
	
	cname=tmalloc(strlen(dname)+2);
	if(cname==NULL)
		return(ENSMEM);
#ifdef iodebug
	Dftext("[Resolver converting name]\r\n");
#endif
	conv_name(cname, dname);
#ifdef iodebug
	Dftext("[Resolver conversion done, making header]\r\n");
#endif
	
	/* Make Header */
	dnsh.id=res_get_id();
	dnsh.val1=op<<3;
#ifdef REKURS_QUERY
	dnsh.val1|=RD;
#endif
	dnsh.val2=0;
	dnsh.qdcount=1;
	dnsh.ancount=dnsh.nscount=dnsh.arcount=0;

#ifdef iodebug
	Dftext("[Resolver header done, copy data]\r\n");
#endif

	dst=(uchar*)buf;
	src=(uchar*)&dnsh;
	c=(int)sizeof(dns_header);
	while(c--)
		*dst++=*src++;
	
	/* Copy data */
	if(op==IQUERY)
	{
		c=datalen;
		src=(uchar*)data;
	}
	else
	{
		c=(int)strlen(cname);
		src=(uchar*)cname;
	}
	while(c--)
		*dst++=*src++;
	*dst++=0;
	ifree(cname);
	
#ifdef iodebug
	Dftext("[Resolver copy done, set QTYPE/QCLASS]\r\n");
#endif

	/* Set QTYPE and QCLASS */
	uset_int(dst, type);
	dst+=2;
	uset_int(dst, class);

	return(tlen);
}

int cdecl res_send(char *msg, int msglen, char *answer, int anslen)
{
	int					s, ierr, cont, rt_count, rt_timer;
	sockaddr_in	ad;
	dns_header	*dnsh=(dns_header*)answer;
	uint				id=((dns_header*)msg)->id;
	s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if(s < 0) /* Can't create socket */
	{
		return(s);
	}
	sfcntl(s, F_SETFL, O_NDELAY);
	
	ad.sin_port=NAMESERVER_PORT;
	ad.sin_addr=defaults.name_server_ip;
	ierr=connect(s, &ad, (int)sizeof(sockaddr_in));
	if(ierr < 0)
	{
		return(ierr);
	}

	rt_count=defaults.dns_retry;
	do
	{
		#ifdef iodebug
			Dftext("[Resolver sending query]\r\n");
		#endif
		ierr=send(s, msg, msglen, 0);
		if(ierr < 0)
		{
			return(ierr);
		}
	
		cont=1;
		
		rt_timer=defaults.dns_timeout*(1000/POLL_WAIT);
		do
		{
			#ifdef iodebug
				Dftext("[Resolver checking port, buffer "); Dfnumber(anslen);
			#endif
			ierr=(int)recv(s, answer, anslen, 0);
			#ifdef iodebug
				Dftext("result="); Dfnumber(ierr); Dftext("]\r\n");
			#endif
			if(ierr > 0)			/* Answer received */
			{
				if((dnsh->id == id) && (dnsh->val1 & QR))
					cont=0;
				else
				{
					#ifdef iodebug
						Dftext("[Resolver discarding, wrong id]\r\n");
					#endif
					ierr=0;	/* Discard message */
				}
			}
			if(ierr < 0)				 /* Error received */
			{
				shutdown(s,2);
				sclose(s);
				return(ierr);
			}
			if(ierr == 0)				/* Nothing received */
			{
				/* Sleep POLL_WAIT ms */
				iwait(POLL_WAIT);
				--rt_timer;
			}
			if(rt_timer <= 0) cont=0;
		}while(cont);
		/* Received message or retransmit? */
		if(ierr > 0)
		{
			cont=0; /* Message */
		}
		else
		{/* Retransmission timer timed out */
			--rt_count;
			if(rt_count > 0)
			{
				cont=1;
			}
			else
			{/* Out of retransmissions */
				shutdown(s,2);
				sclose(s);
				return(TRY_AGAIN);
			}
		}
	}while(cont);
	
	/* Received message */ 
	shutdown(s,2);
	sclose(s);
	return(ierr);
}


/* Taken from MiNT-Net */

/*
 * Expand compressed domain name 'comp_dn' to full domain name.
 * 'msg' is a pointer to the begining of the message,
 * 'eomorig' points to the first location after the message,
 * 'exp_dn' is a pointer to a buffer of size 'length' for the result.
 * Return size of compressed name or -1 if there was an error.
 */
int cdecl dn_expand(uchar *msg, uchar *eomorig, uchar *comp_dn, uchar *exp_dn, int length)
{
  register uchar *cp, *dn;
  register int n, c;
  uchar *eom;
  int len = -1, checked = 0;

  dn = exp_dn;
  cp = (uchar *)comp_dn;
  eom = exp_dn + length;
  /*
   * fetch next label in domain name
   */
  while ((n = *cp++)!=0) {
    /*
     * Check for indirection
     */
    switch (n & INDIR_MASK) {
    case 0:
      if (dn != exp_dn) {
        if (dn >= eom)
          return (-1);
        *dn++ = '.';
      }
      if (dn+n >= eom)
        return (-1);
      checked += n + 1;
      while (--n >= 0) {
        if ((c = *cp++) == '.') {
          if (dn + n + 2 >= eom)
            return (-1);
          *dn++ = '\\';
        }
        *dn++ = c;
        if (cp >= eomorig)  /* out of range */
          return(-1);
      }
      break;

    case INDIR_MASK:
      if (len < 0)
        len =(int)( cp - comp_dn + 1);
      cp = (uchar *)msg + (((n & 0x3f) << 8) | (*cp & 0xff));
      if (cp < msg || cp >= eomorig)  /* out of range */
        return(-1);
      checked += 2;
      /*
       * Check for loops in the compressed name;
       * if we've looked at the whole message,
       * there must be a loop.
       */
      if (checked >= eomorig - msg)
        return (-1);
      break;

    default:
      return (-1);      /* flag error */
    }
  }
  *dn = '\0';
  if (len < 0)
    len =(int)( cp - comp_dn);
  return (len);
}

/*
 * Compress domain name 'exp_dn' into 'comp_dn'.
 * Return the size of the compressed name or -1.
 * 'length' is the size of the array pointed to by 'comp_dn'.
 * 'dnptrs' is a list of pointers to previous compressed names. dnptrs[0]
 * is a pointer to the beginning of the message. The list ends with NULL.
 * 'lastdnptr' is a pointer to the end of the arrary pointed to
 * by 'dnptrs'. Side effect is to update the list of pointers for
 * labels inserted into the message as we compress the name.
 * If 'dnptr' is NULL, we don't try to compress names. If 'lastdnptr'
 * is NULL, we don't update the list.
 */
int cdecl dn_comp(uchar *exp_dn, uchar *comp_dn, uchar **dnptrs, uchar **lastdnptr, int length)
{
  register uchar *cp, *dn;
  register int c, l;
  uchar **cpp, **lpp, *sp, *eob;
  uchar *msg;

  dn = (uchar *)exp_dn;
  cp = comp_dn;
  eob = cp + length;
  if (dnptrs != NULL) {
    if ((msg = *dnptrs++) != NULL) {
      for (cpp = dnptrs; *cpp != NULL; cpp++)
        ;
      lpp = cpp;  /* end of list to search */
    }
  } else
    msg = NULL;
  for (c = *dn++; c != '\0'; ) {
    /* look to see if we can use pointers */
    if (msg != NULL) {
      if ((l = dn_find(dn-1, msg, dnptrs, lpp)) >= 0) {
        if (cp+1 >= eob)
          return (-1);
        *cp++ = (l >> 8) | INDIR_MASK;
        *cp++ = l % 256;
        return ((int)(cp - comp_dn));
      }
      /* not found, save it */
      if (lastdnptr != NULL && cpp < lastdnptr-1) {
        *cpp++ = cp;
        *cpp = NULL;
      }
    }
    sp = cp++;  /* save ptr to length byte */
    do {
      if (c == '.') {
        c = *dn++;
        break;
      }
      if (c == '\\') {
        if ((c = *dn++) == '\0')
          break;
      }
      if (cp >= eob) {
        if (msg != NULL)
          *lpp = NULL;
        return (-1);
      }
      *cp++ = c;
    } while ((c = *dn++) != '\0');
    /* catch trailing '.'s but not '..' */
    if ((l =(int)( cp - sp - 1)) == 0 && c == '\0') {
      cp--;
      break;
    }
    if (l <= 0 || l > MAXLABEL) {
      if (msg != NULL)
        *lpp = NULL;
      return (-1);
    }
    *sp = l;
  }
  if (cp >= eob) {
    if (msg != NULL)
      *lpp = NULL;
    return (-1);
  }
  *cp++ = '\0';
  return ((int)(cp - comp_dn));
}

/*
 * Search for expanded name from a list of previously compressed names.
 * Return the offset from msg if found or -1.
 * dnptrs is the pointer to the first name on the list,
 * not the pointer to the start of the message.
 */
static int
dn_find(uchar *exp_dn, uchar *msg, uchar **dnptrs, uchar **lastdnptr)
{
  register uchar *dn, *cp, **cpp;
  register int n;
  uchar *sp;

  for (cpp = dnptrs; cpp < lastdnptr; cpp++) {
    dn = exp_dn;
    sp = cp = *cpp;
    while ((n = *cp++)!=0) {
      /*
       * check for indirection
       */
      switch (n & INDIR_MASK) {
      case 0:   /* normal case, n == len */
        while (--n >= 0) {
          if (*dn == '.')
            goto next;
          if (*dn == '\\')
            dn++;
          if (*dn++ != *cp++)
            goto next;
        }
        if ((n = *dn++) == '\0' && *cp == '\0')
          return ((int)(sp - msg));
        if (n == '.')
          continue;
        goto next;

      default:  /* illegal type */
        return (-1);

      case INDIR_MASK:  /* indirection */
        cp = msg + (((n & 0x3f) << 8) | *cp);
      }
    }
    if (*dn == '\0')
      return ((int)(sp - msg));
  next: ;
  }
  return (-1);
}
