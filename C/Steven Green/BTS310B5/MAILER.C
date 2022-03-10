/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*                 This module was written by Bob Hartman                   */
/*                                                                          */
/*                                                                          */
/*                   BinkleyTerm Mail Control Routines                      */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <dos.h>
#endif
#ifndef LATTICE
#include <process.h>
#endif
#ifdef LATTICE
#undef min
#else
#include <io.h>
#endif

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "com.h"
#include "vfossil.h"
#include "sched.h"
#include "keybd.h"
#include "zmodem.h"
#include "session.h"
#include "nodeproc.h"

/*
 * Data (used to be in data.c but it is only ever used in here!)
 */
 
static struct FILEINFO dta_str = { 0 };
static char next_one[64];

static ADDR next_addr;			/* Next address to call */



/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                    (C) Copyright 1990, Holger Schurig                    */
/*                                                                          */
/*                This module was written by Holger Schurig                 */
/*                                                                          */
/*                          Zoomed Outbound Window                          */
/*                                                                          */
/* Minor modifications for Atari ST by Steven Green                         */
/*--------------------------------------------------------------------------*/

static void zoom_window (REGIONP zoomwin, MAILP p)
{
	int i,n;
	long l;
	char out_str[50];
	char flagstr[7];

	/* clear the inside of zoomed outbound */
	zoomwin->sr0++;
	zoomwin->sr1--;
	zoomwin->sc0++;
	zoomwin->sc1--;
	sb_fillc (zoomwin, ' ');
	zoomwin->sr0--;
	zoomwin->sr1++;
	zoomwin->sc0--;
	zoomwin->sc1++;

	/* give it a header */
	sb_move (zoomwin, 1, 2);
	sb_puts (zoomwin,"Node            Domain          Files Bytes Age Calls Bad Status Errors");

	for(i = 2; i < (zoomwin->r1 - zoomwin->r0); i++)
	{
		if (p == NULL)
			break;

		sb_move (zoomwin, i, 2);
		sprintf (out_str, "%u:%u/%u",
			p->mail_addr.Zone,
			p->mail_addr.Net,
			p->mail_addr.Node);
		if(p->mail_addr.Point)
			sprintf(&out_str[strlen(out_str)], ".%u", p->mail_addr.Point);
		sb_puts (zoomwin, (unsigned char *) out_str);

		if (p->mail_addr.Domain != NULL)
		{
			sb_move (zoomwin, i, 18);
			sprintf (out_str, "%-15s", p->mail_addr.Domain);
			sb_puts (zoomwin, fancy_str(out_str));
		}
		sb_move (zoomwin, i, 34);

		n = 0;
		if (  p->mailtypes & MAIL_HOLD    ) flagstr[n++] = 'H';
		if (  p->mailtypes & MAIL_NORMAL  ) flagstr[n++] = 'N';
		if (  p->mailtypes & MAIL_CRASH   ) flagstr[n++] = 'C';
		if (  p->mailtypes & MAIL_DIRECT  ) flagstr[n++] = 'D';
		if (  p->mailtypes & MAIL_REQUEST ) flagstr[n++] = 'R';
		if (!(p->mailtypes & MAIL_WILLGO )) flagstr[n++] = '-';
		flagstr[n] = '\0';

		l = ((long) time (NULL)) - (p->oldest);
		n = (int) (l / 86400L);
		sprintf (out_str, "%-3u %7lu %3d %5u %3u %6s",
		p->files,
		p->size,
		(n > 999) ? 999 : n,
		p->calls,
		p->costcalls,
		flagstr);
		sb_puts (zoomwin, out_str);

		sb_move (zoomwin, i, 67);
		out_str[0] = '\0';
		if (p->mailtypes & MAIL_UNKNOWN)
			sprintf (out_str, "Unknwn");
		else
			if (p->mailtypes & MAIL_TOOBAD)
				sprintf (out_str, "NoConn");
			else
				if (p->mailtypes & MAIL_TRIED)
					sprintf (out_str, "Tried");
		sb_puts (zoomwin, out_str);

		p = p->next;
	}
	sb_show ();
}

static void extended_dodir(char *domain, int zone, REGIONP zoomwin)
{
	MAILP p;
	ADDR tmp;
	int i, j;
#ifdef ATARIST
	struct FILEINFO dta;
#else
	struct find_t dta;
#endif
	struct tm dt;
	time_t unixdt;
	struct stat statbuf;
#ifdef IOS
	int oat;
	int opt,oft,ort;
#endif
	int out, flo, req, bad;
	char *e1, *e2, *e3;
	FILE *fp;
	char fname[80];
	char *fnameptr;

	tmp.Zone = zone;
	tmp.Net = 
	tmp.Node = 
	tmp.Point = 0;
	tmp.Domain = domain;
	(void) sprintf (next_one, "%s*.*", HoldAreaNameMunge(&tmp));

#ifdef DEBUG
	status_line(">extended_dodir(%s %d) => %s", domain ? domain : "", zone, next_one);
#endif

#ifdef ATARIST
    j = dfind(&dta, next_one, 0);
    for (; !j; j = dnext (&dta))
#else
	j = _dos_findfirst (next_one, _A_ARCH | _A_NORMAL, &dta);
	for (; !j; j = _dos_findnext (&dta))
#endif
	{
		e1 = strchr(dta.name, '.');
		if(e1 != NULL)
		{
			e1 = e1+1;
			e2 = e1+1;
			e3 = e2+1;
			out = flo = req = bad = 0;
#ifdef IOS
			oat = 0;
			opt = oft = ort = 0;	
			if (                (*e2 == 'A') && (*e3 == 'T')) oat++;
			if (                (*e2 == 'P') && (*e3 == 'T')) opt++;
			if (                (*e2 == 'F') && (*e3 == 'T')) oft++;
			if (                (*e2 == 'R') && (*e3 == 'T')) ort++;
#endif
			if (                (*e2 == 'U') && (*e3 == 'T')) out++;
			if (                (*e2 == 'L') && (*e3 == 'O')) flo++;
			if ((*e1 == 'R') && (*e2 == 'E') && (*e3 == 'Q')) req++;
			if ((*e1 == '$') && (*e2 == '$')                ) bad++;

#ifdef IOS
			if (out || flo || req || bad || oat || opt || oft || ort)
#else
			if (out || flo || req || bad)
#endif
			{

				/* Decode the address */

#ifdef IOS
				if(oat || opt || oft || ort || (bad && iosmode))
					getaddress(dta.name, &tmp.Net, &tmp.Node, &tmp.Point);
				else
#endif
					if(get2daddress(dta.name, &tmp) == FALSE)
						continue;	/* Ignore invalid addresses */

				/* Display where we're at */

				{
					if (fullscreen)
					{
						char s[40];
					
						sprintf(s, "%-30s", Pretty_Addr_Str(&tmp));

						if(zoomwin)
						{
							sb_move(zoomwin, 2, 2);
							sb_puts(zoomwin, s);
						}
						else
						{
							sb_move(holdwin, 4, 2);
							sb_puts(holdwin, s);
						}
						sb_show();
					}
				}

				/* Adresse suchen */
				
				p = find_mail (&tmp);
				if (p == NULL)
					continue;
			}


			/*
			 * If its not a $$ file
			 * Find out more about it!
			 */

#ifdef IOS
#ifdef NEW
			if (out || flo || req || oat || opt || oft || ort)
#else
			if (out || flo || req || oat)
#endif
#else
			if (out || flo || req)
#endif
			{
				/* Filedatum setzen */
#ifdef ATARIST
				dt.tm_year = (int)(((dta.time >> 9) & 0x7f) + 80);
				dt.tm_mon  = (int)(((dta.time >> 5) & 0xf) - 1);												    /* 0..11 */
				dt.tm_mday = (int)(dta.time & 0x1f);												              /* 1..31 */
#else
				dt.tm_year = (dta.wr_date >> 9) + 80;
				dt.tm_mon  = ((dta.wr_date >> 5) & 0xf) - 1;												    /* 0..11 */
				dt.tm_mday = dta.wr_date &0x1f;												                 /* 1..31 */
#endif
				dt.tm_hour = dt.tm_min = dt.tm_sec = 0;
#if defined(__TURBOC__) && !defined(__TOS__)  /* JCE 09.10.90 */
				unixdt = time (&dt);
#else
				unixdt = mktime (&dt);
#endif
				p->oldest = min(unixdt, p->oldest);
			}

			/* NOT flow files */

#ifdef IOS
			if(out || req || oat || opt || ort)
#else
			if (out || req)
#endif
			{
				/* Filel„nge/Fileanzahl addieren */
				(p->files)++;
				(p->size) += dta.size;
			}

			/* Flow files */

#ifdef IOS
			if(flo || oft)
#else
			if(flo)
#endif
			{
				/* indirekte Filel„nge/Fileanzahl addieren */ ;
				sprintf (fname, "%s%s", HoldAreaNameMunge (&(p->mail_addr)), dta.name);

				fp = fopen (fname, "r");	/* was "rb" */
				if (fp != NULL)
				{
					while (!feof (fp))
					{
						fname[0] = 0;
						if (fgets (fname, 79, fp) != NULL)
						{
							fnameptr = fname;

							for (i = 0; fnameptr[i]; i++)
							{
								if (fnameptr[i] <= ' ')
								{
									fnameptr[i] = '\0';
								}
							}
							/* SWG: 22Aug91 Prevent error with ~:\ */
							if( !fnameptr[0] || (fnameptr[0] == ';') || (fnameptr[0] == '~'))
								continue;
							if ((fnameptr[0] == TRUNC_AFTER) || (fnameptr[0] == SHOW_DELETE_AFTER))
							{
								fnameptr++;
							}

							if (stat (fnameptr, &statbuf) == 0)
							{
								p->size += statbuf.st_size;
								p->files++;
							}
							/* bei MO?/WE? etc indirektes Filedatum ermitteln */ ;
						}
					}														 /* WHILE */
					fclose(fp);
				}												 /* ?LO-File found */
			}

			if (bad)
			{
				/* BadCalls hochz„hlen */ ;
				sprintf (fname, "%s%s", HoldAreaNameMunge (&(p->mail_addr)), dta.name);

				i = open (fname, O_BINARY|O_RDONLY);
				(void) read (i, &(p->calls), sizeof (p->calls));
				(void) close (i);

				p->costcalls += *e3-'0';
				p->calls += *e3-'0';
			}
		}
	}
}

static void extended_xmit_reset (REGIONP zoomwin)
{
	ADDR tmp;
	MAILP p;
	char *domain;
	int k, zone;

	p = mail_top;
	while (p != NULL)
	{
		p->calls     = 0;
		p->costcalls = 0;
		p->files     = 0;
		p->size      = 0L;
		p->oldest    = (long) time (NULL);
		p = p->next;
	}

	k = 0;
	domain = domain_name[0];

	do
	{
		ADDRESS *ad;
		int count, count1;
		int ourzone[ALIAS_CNT];	/* record of our own zones */
		int zonecnt;

		/*
		 * Do our own zones first
		 */
		
		ad = alias;
		count = num_addrs;
		zonecnt = 0;
		while(count--)
		{
			if(!domain || (ad->ad.Domain == domain))
			{
				/* Check we havnt already done it */
					
				count1 = zonecnt;
				while(count1--)
				{
					if(ourzone[count1] == ad->ad.Zone)
						break;
				}
				if(count1 < 0)
				{
					extended_dodir(domain, ad->ad.Zone, zoomwin);
					ourzone[zonecnt++] = ad->ad.Zone;
				}
			}
			ad++;
		}

		if(!no_zones)
		{
			do
			{
				tmp.Zone = -1;
				tmp.Domain = domain;
				tmp.Net = 
				tmp.Node = 
				tmp.Point = 0;
			
				zone = nodefind(&tmp, 0);
				if(zone > 0)
				{
					/* Check we havnt already done it */
					
					count = zonecnt;
					while(count--)
					{
						if(ourzone[count] == zone)
							break;
					}
					if(count < 0)
						extended_dodir(domain, zone, zoomwin);
				}
			} while(zone > 0);
		}

		domain = domain_name[++k];
	}
	while (domain != NULL);
}

int Overlay_Do_Zoom (SAVEP rp, int x)
{
	REGIONP zoomwin;
	MAILP p;
	long t_idle;
	int i,c;
	int height;

	/* is there something in the outbound ? */
	if (mail_top == NULL)
	{
		status_line (msgtxt[M_NOTHING_IN_OUTBOUND_STATUS]);
		return (0);
	}

	/* is there a window */
	if (rp != NULL)
	{
		zoomwin = rp->region;

		/* draw a box */
		sb_fill (zoomwin, ' ', colors.hold);
		sb_box (zoomwin, boxtype, (colors.borders ? colors.borders : colors.hold));

		/* give it a title */
		sb_move (zoomwin, 0, 1);
		if (colors.headers) sb_wa(zoomwin, colors.headers, 30);
		sb_puts (zoomwin, " Zoomed Pending Outbound Mail ");

		/* do we need info ? */
		if (!mail_top->files)
		{
			sb_move (zoomwin, 1, 2);
			sb_puts (zoomwin, "Please wait ...");
			sb_show ();
			extended_xmit_reset (zoomwin);
		}

		p = mail_top;
		zoom_window (zoomwin, p);
		height = zoomwin->r1 - zoomwin->r0;

		t_idle = timerset(6000);
		while (!timeup (t_idle) && (PEEKBYTE () == 0xffff))
		{
			if (KEYPRESS ())
			{
				t_idle = timerset(3000);
				c = (int) FOSSIL_CHAR ();

				if (c == PGUP)
				{
					for (i = 2; i < height; i++)
					{
						if (p->prev != NULL)
							p = p->prev;
					}
				}
				else
				if (c == PGDN)
				{
					for (i = 2; i < height; i++)
					{
						if (p->next != NULL)
							p = p->next;
					}
				}
				else
				if (c == UPAR)
				{
					if (p->prev != NULL)
					{
						p = p->prev;
					}
				}
				else
				if (c == DNAR)
				{
					if (p->next != NULL)
					{
						p = p->next;
					}
				}
				else
				if (c == HOME)
				{
					p = mail_top;
				}
				else
				if (c == END)
				{
					while (p->next != NULL)
						p = p->next;
					for (i = 2; i < height; i++)
					{
						if (p->prev != NULL)
							p = p->prev;
					}
				}
				else
				/* ALT-Z, Space, ESCape or Return terminates */
				if (c == ALTZ)
					return (x);

				c &= 0x00ff;

				if ((c == 0x20) || (c == 0x1b) || (c == 0x0d))
					return (x);

				if (!KEYPRESS ())
					zoom_window (zoomwin, p);

			}
		}
	}
	/* return value is never checked, just use x so lint and -w3 don't get mad */
	return (x);
}



/*
 * Find mail for an address in the MAILP list
 */

MAILP find_mail (ADDR *address)
{
	MAILP p;

	p = mail_top;
	while (p != NULL)
	{
		if ((no_zones || (p->mail_addr.Zone == address->Zone)) &&
			(p->mail_addr.Net == address->Net) &&
			(p->mail_addr.Node == address->Node) &&
			(p->mail_addr.Point == address->Point) &&
			((p->mail_addr.Domain == address->Domain) ||
			((p->mail_addr.Domain == alias[0].ad.Domain) &&
			(address->Domain == NULL))))
			break;
		p = p->next;
	}

	return (p);
}

/*
 * Fill in data into MAILP node
 *
 * uses dta_str, which is the DTA area for a recently found file
 *
 * returns 1 for an error or node already exists in list
 */

static int xmit_install (MAILP p, int zone, char *domain)
{
	MAILP p1, p2;
	int rettype;
	ADDR tmp;
#ifdef IOS
	char *s;
#endif
	
#ifdef IBMC
	char tnet[5], tnode[5];
#endif


	/* Interpret the net/node from the filename */

	tmp.Zone = zone;		/* Set up defaults */
	tmp.Domain = domain;

#ifdef IOS
	s = strchr(dta_str.name, '.');
	
	if(s && (s[2] != 'U') && (s[3] == 'T'))
		getaddress(dta_str.name, &tmp.Net, &tmp.Node, &tmp.Point);
	else
#endif
		if(get2daddress(dta_str.name, &tmp) == FALSE)
			return 1;
     
	p2 = find_mail (&tmp);
	if (p2 == NULL)
	{
		/* We didn't find it in what we have already */
		p1 = p;
		p1->mail_addr.Zone = tmp.Zone;
		p1->mail_addr.Net = tmp.Net;
		p1->mail_addr.Node = tmp.Node;
		p1->mail_addr.Point = tmp.Point;
		p1->mail_addr.Domain = tmp.Domain;
		rettype = 0;
	}
	else
	{
		/* We found it, so we have to make sure the higher level routine knows */
		p1 = p2;
		rettype = 1;
	}

	switch (dta_str.name[9])
	{
	case 'C':		      /* Crash */
		p1->mailtypes |= MAIL_CRASH;
		break;

	case 'H':		      /* Hold */
		p1->mailtypes |= MAIL_HOLD;
		break;

	case 'F':		      /* Normal */
	case 'O':
		p1->mailtypes |= MAIL_NORMAL;
		break;

	case 'D':		      /* Direct */
		p1->mailtypes |= MAIL_DIRECT;
		break;

	case 'R':		      /* Request */
		p1->mailtypes |= MAIL_REQUEST;
		break;
	}
#ifdef IOS
	if(dta_str.name[10] == 'R')
		p1->mailtypes |= MAIL_REQUEST;
#endif

	/* SWG: 11Jul91 : Speed up reading */
	/* Avoid nodelist check if already processed this address! */

	if(p2)
	{
		if(p1->mailtypes & MAIL_UNKNOWN)
			return rettype;
	}
	else
	{
		if (!nodefind (&(p1->mail_addr), 0))
		{
			p1->mailtypes |= MAIL_UNKNOWN;
			return (rettype);
		}
		p1->realcost = newnodedes.RealCost;
		p1->nodeflags = newnodedes.NodeFlags;
	}


	/* REQUEST  03.08.1990 */
	/* Don't call for "HOLD" stuff. */
	if (dta_str.name[9] == 'H')
	{
		return (rettype);
	}

	/* Don't call for "REQ" stuff if not allowed */
#ifdef IOS
	if (!requests_ok && ((dta_str.name[9] == 'R') || (dta_str.name[10] == 'R')))
#else
	if ((dta_str.name[9] == 'R') && (!requests_ok))
#endif
	{
		return (rettype);
	}

	/* If there's no event, set mail to 'go' */

	if (cur_event < 0)
	{
		p1->mailtypes |= MAIL_WILLGO;
		return (rettype);
	}

	/* if mail is direct, set mail to 'go'	*/
	
	if (dta_str.name[9] == 'D')
	{
		p1->mailtypes |= MAIL_WILLGO;
		return (rettype);
	}
		
	/* REQUEST  22.08.1990 */
	/* If it is not supposed to be outbound requests, go on */
	if ((e_ptrs[cur_event]->behavior & MAT_NOOUTREQ) &&
#ifdef IOS
		((dta_str.name[10] == 'R') || (dta_str.name[9] == 'R')))
#else
		(dta_str.name[9] == 'R'))
#endif
	{
		return (rettype);
	}

	/* If it is a crash only event and this wasn't crash, return */
	if ((dta_str.name[9] != 'C') && (e_ptrs[cur_event]->behavior & MAT_CM))
	{
		return (rettype);
	}

	/*
	** Check for costs. If UseCallSlots is set, then take them instead
	*/
	
	if (usecallslots)
	{
		/*
		** check if slot exits, don't call for CRASH mail waiting
		** for other nodes if slot is not found
		*/
		
		s = strchr (e_ptrs[cur_event]->call_slot, (int)p1->realcost);
		if (!s || !*s)
		{
			/*
			** no slot for node!!
			** Did we have slots for this event ?
			** Then don't call if mail is crash
			**/
			
			if (e_ptrs[cur_event]->call_slot[0])
			{
				if (dta_str.name[9] != 'C') 
				{
					return (rettype);
				}
				else
				{
			    	if (!(e_ptrs[cur_event]->behavior & MAT_CM)) return (rettype);
				}
			}
		}
	}
	else
	{
		/* Is this a local only event? */
		if (e_ptrs[cur_event]->behavior & MAT_LOCAL)
		{
			/*
	        ** If this is supposed to be only local, then get out if it isn't 
			*/
			if (e_ptrs[cur_event]->node_cost >= 0)
			{
				if ((int) p1->realcost > e_ptrs[cur_event]->node_cost)
				{
					return (rettype);
				}
			}
			else
			{
				if ((int) p1->realcost < -e_ptrs[cur_event]->node_cost)
				{
					return (rettype);
				}
			}
		}
	}

	/* Is this a non-mail window event? */
#ifndef ATARIST
	if (newnodelist && (!(e_ptrs[cur_event]->behavior & MAT_NOMAIL24)))
#else
	if (!(e_ptrs[cur_event]->behavior & MAT_NOMAIL24))
#endif
	{
		/* If this guy can't handle crash, get out and try again */
		if (!(p1->nodeflags & B_CM) && (!s || !*s))
		{
			return (rettype);
		}
	}

	/* Is this a receive only event? */
	if (e_ptrs[cur_event]->behavior & MAT_NOOUT)
	{
		return (rettype);
	}

	/* Is this a non-CM event? */
#ifndef ATARIST
	if (newnodelist && (e_ptrs[cur_event]->behavior & MAT_NOCM) &&
		(p1->nodeflags & B_CM))
#else
	if((e_ptrs[cur_event]->behavior & MAT_NOCM) && (p1->nodeflags & B_CM))
#endif
	{
		return (rettype);
	}

	/* See if we spent too much calling him already */
	if (bad_call (&(p1->mail_addr), BAD_STATUS))
	{
		p1->mailtypes |= MAIL_TOOBAD;
		return (rettype);
	}

	p1->mailtypes |= MAIL_WILLGO;

	return (rettype);
}



void xmit_window (MAILP p1)
{
	MAILP p;
	int i;
	char node_str[16];	    	/* for zz:nnnnn:nnnnn */
	char domain_str[9];	   		/* for the domain or files/size/age */
	char flag_str[7];	     	/* for the flags */
	char size_str[6];	     	/* for Bytes, kBytes or MBytes */
	char *res_str;
	int n;	                	/* counter */
	char j1[40];

	if (!fullscreen)
		return;

	/*
	 * SWG: Default to mail_top and set next_mail
	 */
	
	if(p1 == NULL)
		p1 = mail_top;
#if 0
	if(next_mail == NULL)
		next_mail = p1;
#endif

	p = p1;

	sb_fillc (holdwin, ' ');

	if (p == NULL)
	{
		sb_move (holdwin, 3, 5);
		sb_puts (holdwin, (unsigned char *) msgtxt[M_NOTHING_IN_OUTBOUND]);
		return;
	}

	if (niceoutbound)
	{
		sb_move (holdwin, 1, 1);
		sb_puts (holdwin, "Node      Files Size Age Status");
	}
	else
	{
		sb_move (holdwin, 1, 2);
		sb_puts (holdwin, (unsigned char *) msgtxt[M_OUTBOUND_HEADER]);
	}

	for (i = 2; i < 6; i++)
	{
		if (p == NULL)
			break;

		sb_move (holdwin, i, 2);
		/* create formatted address */
		sprintf (node_str, "%u:%u/%u",
				p->mail_addr.Zone,
				p->mail_addr.Net,
				p->mail_addr.Node);

		if(p->mail_addr.Point)
			sprintf(&node_str[strlen(node_str)], ".%u", p->mail_addr.Point);

		/* create formatted flags */
		if (p->mailtypes & MAIL_UNKNOWN)
			sprintf (flag_str, "Unknwn");
		else
			if (p->mailtypes & MAIL_TOOBAD)
				sprintf (flag_str, "NoConn");
			else
				if (p->mailtypes & MAIL_TRIED)
					sprintf (flag_str, "Tried ");
				else
				{
					n = 0;
					if (  p->mailtypes & MAIL_HOLD    ) flag_str[n++] = 'H';
					if (  p->mailtypes & MAIL_NORMAL  ) flag_str[n++] = 'N';
					if (  p->mailtypes & MAIL_CRASH   ) flag_str[n++] = 'C';
					if (  p->mailtypes & MAIL_DIRECT  ) flag_str[n++] = 'D';
					if (  p->mailtypes & MAIL_REQUEST ) flag_str[n++] = 'R';
					if (!(p->mailtypes & MAIL_WILLGO )) flag_str[n++] = '-';
					flag_str[n] = '\0';
				}

		if (niceoutbound)
		{
			/* create extra info */
			if (p->size > 10238976L)
				sprintf (size_str, "%4ulM", (p->size+1048575L)/1048576L);
			else
				if (p->size > 9999)
					sprintf (size_str, "%4luk", (p->size+1023)/1024);
				else
					sprintf (size_str, "%4lu ",  p->size);
			n = (int) ( ((long)time(NULL) - p->oldest) / 86400L );
			sb_move (holdwin, i, 1);
			sprintf (j1, "%-12.12s%3u%6s%3u%7s",
				node_str, p->files, size_str, (n > 999) ? 999 : n, flag_str);
		}
		else
		{
			/* create formatted domain if any */
			if(p->mail_addr.Domain == NULL)
				strcpy (domain_str, "FidoNet");
			else
			{
				strncpy (domain_str, p->mail_addr.Domain, 8);
				res_str = strchr (domain_str, '.');
				if (res_str != NULL)
					*res_str = '\0';
				domain_str[8] = '\0';
			}
			sb_move (holdwin, i, 2);
			sprintf (j1, "%-15s%-8s%6s", node_str, domain_str, flag_str);
		}
		sb_puts (holdwin, (unsigned char *) j1);
		p = p->next;
	}

	sb_show ();
}

/*
 * Sort the outbound mail
 */

static void xmit_sort (void)
{
	MAILP p, p1, p2;

	do_ready ("Sorting");

	p1 = mail_top;
	while (p1 != NULL)
	{
		p2 = p1->next;
		while (p2 != NULL)
		{
			if(      (p2->mail_addr.Zone  < p1->mail_addr.Zone )
			    || ( (p2->mail_addr.Zone == p1->mail_addr.Zone ) &&
				   ( (p2->mail_addr.Net   < p1->mail_addr.Net  )
			    || ( (p2->mail_addr.Net  == p1->mail_addr.Net  ) &&
			       ( (p2->mail_addr.Node  < p1->mail_addr.Node )
			    || ( (p2->mail_addr.Node == p1->mail_addr.Node ) &&
			         (p2->mail_addr.Point < p1->mail_addr.Point) ))))))
			{

				/* p2 ausklinken */
				p2->prev->next = p2->next;
				if (p2->next != NULL) p2->next->prev = p2->prev;

				/* p2 vor p1 einklinken */
				p2->prev = p1->prev;
				if (p2->prev != NULL) p2->prev->next = p2;
				p2->next = p1;
				p1->prev = p2;

				/* korrigieren */
				if (p1 == mail_top) mail_top = p2;
				p = p2;
				p2 = p1;
				p1 = p;
			}
			p2 = p2->next;
		}
		p1 = p1->next;
	}
	p = mail_top;

	/* Find the first that is sendable */
	while (p != NULL)
	{
		if ((p->mailtypes & MAIL_WILLGO) &&
			(!(p->mailtypes & MAIL_TOOBAD)) &&
			(!(p->mailtypes & MAIL_UNKNOWN)))
			break;
		p = p->next;
	}

	if (p == NULL)
		return;

	/* Put the first sendable one on top */
	if (p != mail_top)
	{
		p->prev->next = p->next;
		if (p->next != NULL)
			p->next->prev = p->prev;
		p->prev = NULL;
		p->next = mail_top;
		mail_top->prev = p;
		mail_top = p;
	}

	p1 = p;
	p = p1->next;
	while (p != NULL)
	{
		if ((p->mailtypes & MAIL_WILLGO) &&
			(!(p->mailtypes & MAIL_TOOBAD)) &&
			(!(p->mailtypes & MAIL_UNKNOWN)))
		{
			if (p->prev == p1)
			{
				p1 = p;
				p = p->next;
				continue;
			}
			p2 = p->next;
			p->prev->next = p->next;
			if (p->next != NULL)
				p->next->prev = p->prev;
			p->next = p1->next;
			if (p1->next != NULL)
				p1->next->prev = p;
			p->prev = p1;
			p1->next = p;
			p1 = p;
			p = p2;
		}
		else
		{
			p = p->next;
		}
	}
}

/*
 * Read mail from a directory
 */

static void do_dir(char *domain, int zone, MAILP *pp)
{
	ADDR tmp;
	MAILP p = *pp;
#if (!defined(OS_2) && !defined(LATTICE))
	int j;
#endif
	char *holdpath;
#ifdef NEW
	struct stat buffer;
#endif


#ifdef NEW
	if(fullscreen)
	{
		char s[16];

		sb_fillc (holdwin, ' ');
		if(domain)
		{
			sb_move(holdwin, 2, 4);
			sb_puts(holdwin, "Domain: ");
			sb_puts(holdwin, domain);
		}
		sb_move(holdwin, 3, 6);
		sb_puts(holdwin, "Zone: ");
		sprintf(s, "%d", zone);
		sb_puts(holdwin, s);
		sb_show();
	}
#endif

	tmp.Zone = zone;
	tmp.Net = 
	tmp.Node = 
	tmp.Point = 0;
	tmp.Domain = domain;
	holdpath = HoldAreaNameMunge(&tmp);
#ifdef NEW

	/* Check if folder exists and create if neccessary */

	strcpy(next_one, holdpath);
	next_one[strlen(next_one) -1] = 0;
	if(stat(next_one, &buffer))
	{
		if(mkdir(next_one) == 0)
			status_line(msgtxt[M_CREATED_DIR], next_one);
		else
		{
			status_line(msgtxt[M_BAD_DIR], next_one);
			status_line(msgtxt[M_NO_CREATE_DIR]);
			return;
		}
	}
		
#endif
	sprintf (next_one, "%s*.*", holdpath);


#if (!defined(OS_2) && !defined(LATTICE))
	j = 0;
#endif

#if defined(OS_2)
		if(!dir_findfirsta(next_one, _A_NORMAL, &dta_str))
#else
		if(!dfind(&dta_str, next_one, 0))
#endif
		do
		{
		  char *ext = strchr(dta_str.name, '.');
		  if(ext)
		  {
			ext++;

#ifdef IOS
			if( ext[0] && ext[1] && ext[2] &&
			   ((            strchr("APFRU", ext[1]) && (ext[2] == 'T') ) ||
                (                    (ext[1] == 'L') && (ext[2] == 'O') ) ||
				( (ext[0] == 'R') && (ext[1] == 'E') && (ext[2] == 'Q') ) ) )
#else
			if( (                    (ext[1] == 'U') && (ext[2] == 'T') ) ||
                (                    (ext[1] == 'L') && (ext[2] == 'O') ) ||
				( (ext[0] == 'R') && (ext[1] == 'E') && (ext[2] == 'Q') ) )
#endif
			{
				/* We found a name, remember it */
				if (p == NULL)
					p = mail_top = (MAILP) calloc (sizeof (MAIL), 1);
				else
				{
					p->next = (MAILP) calloc (sizeof (MAIL), 1);
					p->next->prev = p;
					p = p->next;
				}

				if (xmit_install (p, zone, domain))
				{
					/* No good */
					if (p->prev != NULL)
					{
						p = p->prev;
						free (p->next);
						p->next = NULL;
					}
					else
					{
						free (p);
						p = mail_top = NULL;
					}
				}
			}
	  	  }

#if (!defined(OS_2) && !defined(LATTICE))
			++j;
#endif
		}
#if defined(OS_2)
		while(!dir_findnexta(&dta_str));
#elif defined(LATTICE)
		while(!dnext(&dta_str));						/* got one */
#else
		while(!dfind(&dta_str, next_one, j));
#endif

	*pp = p;
}


/*
 * Reset the outbound mail structures
 */

void xmit_reset ()
{
	MAILP p;
	int k, zone;
	char *domain;
	ADDR tmp;

	readhold_ctr = readhold_time;

	do_ready ("Reading");

	/* First get rid of all the old junk */

	p = mail_top;
	if (p != NULL)
	{
		while (p->next != NULL)				/* Get to end of list */
			p = p->next;
		while (p->prev != NULL)				/* Work back through list freeing memory */
		{
			p = p->prev;
			free (p->next);
		}
		if (p != NULL)
			free (p);
	}

	p = mail_top = NULL;

	k = 0;
	domain = domain_name[0];

	/* For each Domain */

	do
	{
		/* For each Zone */

		ADDRESS *ad;
		int count, count1;
		int ourzone[ALIAS_CNT];	/* record of our own zones */
		int zonecnt;

		lock_nodelist(TRUE);		/* Keep nodelist file open */

		/*
		 * Do our own zones first
		 */
		
		ad = alias;
		count = num_addrs;
		zonecnt = 0;
		while(count--)
		{
			if(!domain || (ad->ad.Domain == domain))
			{
				/* Check we havnt already done it */
					
				count1 = zonecnt;
				while(count1--)
				{
					if(ourzone[count1] == ad->ad.Zone)
						break;
				}
				if(count1 < 0)
				{
					do_dir(domain, ad->ad.Zone, &p);
					ourzone[zonecnt++] = ad->ad.Zone;
				}
			}
			ad++;
		}

		if(!no_zones)
		{
			do
			{
				tmp.Zone = -1;
				tmp.Domain = domain;
				tmp.Net = 
				tmp.Node = 
				tmp.Point = 0;
			
				zone = nodefind(&tmp, 0);
				if(zone > 0)
				{
					/* Check we havnt already done it */
					
					count = zonecnt;
					while(count--)
					{
						if(ourzone[count] == zone)
							break;
					}
					if(count < 0)
						do_dir(domain, zone, &p);
				}
			} while(zone > 0);
		}

		lock_nodelist(FALSE);		/* Unlock nodelist */

		domain = domain_name[++k];

	} 
	while (domain != NULL);

	next_mail = NULL;

	xmit_sort ();

	if (niceoutbound)
		extended_xmit_reset (NULL);

	xmit_window (mail_top);

	do_ready (msgtxt[M_READY_WAITING]);
}

int xmit_next (ADDR *xaddr)
{
	/* Set up the proper pointer */
	if ((next_mail == NULL) || (next_mail->next == NULL))
		next_mail = mail_top;
	else
		next_mail = next_mail->next;

	/* Loop through till we find something we can send */
	while (next_mail != NULL)
	{
		if ((next_mail->mailtypes & MAIL_WILLGO) &&
			(!(next_mail->mailtypes & MAIL_UNKNOWN)) &&
			(!(next_mail->mailtypes & MAIL_TOOBAD)))
		{
			if (bad_call (&(next_mail->mail_addr), BAD_STATUS))
			{
				next_mail->mailtypes |= MAIL_TOOBAD;
			}
			else
			{
				xaddr->Zone = next_mail->mail_addr.Zone;
				xaddr->Net = next_mail->mail_addr.Net;
				xaddr->Node = next_mail->mail_addr.Node;
				xaddr->Point = next_mail->mail_addr.Point;
				xaddr->Domain = next_mail->mail_addr.Domain;
				xmit_window (next_mail);
				return (1);
			}
		}
		next_mail = next_mail->next;
	}

	/* Read the disk again since we reached the end of the list */
#ifdef OS_2
	xmit_reset ();
#endif

	next_mail = mail_top;

	/* Try the new list and see what happens */
	while (next_mail != NULL)
		{
		if ((next_mail->mailtypes & MAIL_WILLGO) &&
			(!(next_mail->mailtypes & MAIL_UNKNOWN)) &&
			(!(next_mail->mailtypes & MAIL_TOOBAD)))
			{
			if (bad_call (&(next_mail->mail_addr), BAD_STATUS))
				{
				next_mail->mailtypes |= MAIL_TOOBAD;
			}
			else
			{
				xaddr->Zone = next_mail->mail_addr.Zone;
				xaddr->Net = next_mail->mail_addr.Net;
				xaddr->Node = next_mail->mail_addr.Node;
				xaddr->Point = next_mail->mail_addr.Point;
				xaddr->Domain = next_mail->mail_addr.Domain;
				xmit_window (next_mail);
				return (1);
			}
		}
		next_mail = next_mail->next;
	}

	/* Oh well, we tried */
	xmit_window (mail_top);
	return (0);
}


/*
 * Handle Bad call files (*.$$?)
 *
 * baddr : Address
 *   rwd : a flag:
 *		0 = BAD_STATUS    = Get status for address (0=OK to call, 1=made too many calls)
 *		1 = BAD_CARRIER   = Mark bad call with carrier
 *		2 = BAD_NOCARRIER = Mark bad call without carrier
 *      3 = BAD_STOPCALL  = Mark as uncallable
 *	  -ve = BAD_REMOVE    = Remove old bad files
 */

int bad_call (ADDR *baddr, int rwd)
{
	int res;
	int i, j;
	struct FILEINFO bad_dta;
	FILE *bad_wazoo;
	char *p;
	char *HoldName;
	char fname[80];
	char fname1[80];

#ifdef DEBUG
	status_line(">update_$$?(%s,%d)", Pretty_Addr_Str(baddr), rwd);
#endif

	HoldName = HoldAreaNameMunge(baddr);
#ifdef IOS
	if(iosmode)
		sprintf (fname, "%s%s.$$?", HoldName, Addr36(baddr));
	else
#endif
		sprintf (fname, "%s%s.$$?", HoldName, Hex_Addr_Str (baddr));
	j = (int) strlen (fname) - 1;	                       /* Point at ?          */
	res = -1;	                                     /* Initialize to fail  */

	i = 0;	                                        /* This says findfirst */
#ifdef LATTICE
	while( i ? !dnext(&bad_dta) : !dfind(&bad_dta, fname, 0))
#else
	while (!dfind (&bad_dta, fname, i))		           /* as long as we match */
#endif
	{
		if (isdigit (bad_dta.name[11]))			            /* is there a digit?   */
		{
			fname[j] = bad_dta.name[11];			            /* Yes, copy to fname  */
			res = fname[j] - '0';			                   /* Save it for testing */
			break;			                                  /* Get out of while    */
		}
		else i = 1;		                                /* Else use findnext   */
	}

	if (res == -1)		                                /* Successful search?  */
	{
		fname[j] = '0';		                            /* No, base digit = 0  */
	}

	if (rwd > 0)
	{
		/* Writing a bad call  */

		/* First create a filename that is one higher than what we've got */

		(void) strcpy (fname1, fname);
		fname1[j]++;
		if (fname1[j] > '9')
			fname1[j] = '9';

		if(res == 3)		/* Mark as uncallable */
			fname1[j] = '9';

		if (res == -1)		                           /* Did we have a file? */
		{		                                       /* No, make one.       */
			if (rwd == BAD_NOCARRIER)                  /* No carrier */
				res = open (fname, O_CREAT|O_WRONLY|O_BINARY, DEFAULT_MODE);
			else 			/* With carrier */
				res = open (fname1, O_CREAT|O_WRONLY|O_BINARY, DEFAULT_MODE);
			i = rwd - 1;			                    /* zero-based count    */
			write (res, &i, sizeof (int));				/* write it out        */
			close (res);			                    /* close the file      */
		}
		else
		{		                                       	/* There was a file    */

			/*
          	 * 2 = Unsuccessful, No carrier. Update contents of the file.
			 */

			if (rwd == BAD_NOCARRIER)
			{
				i = open (fname, O_RDONLY|O_BINARY);
				(void) read (i, (char *) &res, sizeof (int));
				(void) close (i);

				++res;

				i = open (fname, O_CREAT|O_WRONLY|O_BINARY, DEFAULT_MODE);
				(void) write (i, (char *) &res, sizeof (int));
				(void) close (i);
			}

			/*
         	 * 1 or 3 = Unsuccessful, Carrier. Update file name to reflect the
         	 * failure.
			 */

			else
			{
				(void) rename (fname, fname1);
			}
		}
	}
	else if (rwd == BAD_STATUS)
	{

		/*
      	 * 0 = We are reading a bad call status
		 */

		/* Is it automatically ok (no .$$ file there) ? */
		if (res == -1)
			return (0);

		/* Were there too many connects with carrier? */
		if (res >= max_connects)
			return (1);

		/* Ok, check for connects without carrier */
		res = 0;
		i = open (fname, O_RDONLY|O_BINARY);
		(void) read (i, (char *) &res, sizeof (int));
		(void) close (i);
		return (res >= max_noconnects);
	}
	else
	{

		/*
      	 * -1 = Cleanup of bad call status. This happens in two steps:
      	 * a) delete 'netnode.$$?' in hold area;
      	 * b) if a 'netnode.Z' file exists in hold area,
      	 *    1) delete all BADWAZOO.xxx files listed in the .Z file;
      	 *    2) delete the 'netnode.z' file.
		 */

		if (res != -1)
		{
			(void) unlink (fname);
		}

		if (!mail_finished)
			return (0);

#ifdef IOS
		if(iosmode)
			sprintf (fname, "%s%s.Z", HoldName, Addr36(baddr));
		else
#endif
			sprintf (fname, "%s%s.Z", HoldName, Hex_Addr_Str (baddr));
		if (dexists (fname))
		{
			if ((bad_wazoo = fopen (fname, read_ascii)) == NULL)
			{
				(void) got_error (msgtxt[M_OPEN_MSG], fname);
			}
			else
			{
				while (!feof (bad_wazoo))
				{
					e_input[0] = '\0';
					if (!fgets (e_input, 64, bad_wazoo))
						break;
					/* Point to BADWAZOO.xxx */
					p = strchr (e_input, ' ') + 1;
					/* Then just past it and terminate */
					p = strchr (p, ' ');
					*p = '\0';
					/* Back to where we were */
					p = strchr (e_input, ' ') + 1;

					/* Build file name and delete file */
					(void) strcpy (fname1, CurrentNetFiles);
					(void) strcat (fname1, p);
					(void) unlink (fname1);
				}
				(void) fclose (bad_wazoo);
			}
			(void) unlink (fname);
		}
	}
	return (0);
}

/*
 * Kill all BAD $$ files
 *
 * Return number of files killed
 */

static int kill_badzone(ADDR *ad)
{
	int flag = 0;
	char *folder = HoldAreaNameMunge(ad);


	sprintf (next_one, "%s*.$$?", folder);

#ifdef DEBUG
	status_line(">Deleting %s", next_one);
#endif

	if(!dfind(&dta_str, next_one, 0))
	{
		do
		{
			char s[FMSIZE];
		
			sprintf(s, "%s%s", folder, dta_str.name);
#ifdef DEBUG
			status_line(">Killing %s", s);
#endif
			unlink(s);
			flag++;
		}
		while(!dnext(&dta_str));
	}
	return flag;
}

void kill_bad(void)
{
	char *domain = domain_name[0];
	int k = 0;
	int counter = 0;

	status_line(msgtxt[M_KILLING]);

	/* for each domain */

	do
	{
		/* for each zone */

		ADDRESS *ad;
		int count, count1;
		int ourzone[ALIAS_CNT];	/* record of our own zones */
		int zonecnt;

		lock_nodelist(TRUE);		/* keep nodelist file open */

		/*
		 * do our own zones first
		 */
		
		ad = alias;
		count = num_addrs;
		zonecnt = 0;
		while(count--)
		{
			if(!domain || (ad->ad.Domain == domain))
			{
				/* check we havnt already done it */
					
				count1 = zonecnt;
				while(count1--)
				{
					if(ourzone[count1] == ad->ad.Zone)
						break;
				}
				if(count1 < 0)
				{
					counter += kill_badzone(&ad->ad);
					ourzone[zonecnt++] = ad->ad.Zone;
				}
			}
			ad++;
		}

		if(!no_zones)
		{
			int zone;
			
			do
			{
				ADDR tmp;

				tmp.Zone = -1;
				tmp.Domain = domain;
				tmp.Net = 
				tmp.Node = 
				tmp.Point = 0;
			
				zone = nodefind(&tmp, 0);
				if(zone > 0)
				{
					/* check we havnt already done it */
					
					count = zonecnt;
					while(count--)
					{
						if(ourzone[count] == zone)
							break;
					}
					if(count < 0)
					{
						tmp.Zone = zone;
						counter += kill_badzone(&tmp);
					}
				}
			} while(zone > 0);
		}

		lock_nodelist(FALSE);		/* unlock nodelist */

		domain = domain_name[++k];

	} 
	while (domain != NULL);

#ifdef DEBUG
	status_line(">%d $$ files deleted", counter);
#endif

	if(counter)
		set_up_outbound();
}

void set_up_outbound ()
{
	MAILP mp;

	xmit_reset ();

	/* and remember where we left off */
	if (hist.next_net != 0)
	{
		next_addr.Zone = hist.next_zone;
		next_addr.Net = hist.next_net;
		next_addr.Node = hist.next_node;
		next_addr.Point = hist.next_point;
		if(hist.next_Domain[0])
			next_addr.Domain = find_domain(hist.next_Domain);
		else
			next_addr.Domain = NULL;
		mp = find_mail (&next_addr);
		if ((mp == NULL) || (mp->prev == NULL))
		{
			next_mail = NULL;
			xmit_window (mail_top);
		}
		else
		{
			next_mail = mp->prev;
			xmit_window (mail_top);
		}
	}
	else
	{
		next_addr.Zone = 
		next_addr.Net = 
		next_addr.Node = 
		next_addr.Point = 0;
		next_addr.Domain = NULL;
		xmit_window (mail_top);
	}
}

/*
 * functions
 */

static void minute (void);
void minute ()
{
	if (! (--reinit_ctr))
	{
		reinit_ctr = reinit_time;
		set_prior (4);
		mdm_init (modem_init);
		set_prior (2);
		screen_blank = 1;
		if (fullscreen)
			sb_show ();
	}

	if (! (--readhold_ctr))
	{
		readhold_ctr = readhold_time;
		set_up_outbound ();
		more_mail = 1;
	}

	put_up_time ();
	list_next_event ();
}

/*
 * Pick a time between now and x seconds
 */

long random_time (int x)
{
	int i;

	if (x == 0)
	{
		return (0L);
	}

	/* Number of seconds to delay is random based on x +/- 50% */
	i = (rand () % (x + 1)) + (x / 2);

	return (timerset ((long)i * 100));
}

/*-------------------------------------------------------------------
 * The main unattended mailer function
 */

int unattended ()
{
	MAILP mp;
	int i, m, j, tmp;
		long t, t1;	                       /* used for the timeouts  */
	int done = 1;                                 /* if we exit with this, get
	                                                  * out of BT */
	FILE *tfile;
	char jbuf[60];

	un_attended = 1;

#if 0
	clear_statusline ();
#endif

	comm_bits = BITS_8;
	parity = NO_PARITY;
	stop_bits = STOP_1;
	set_prior(4);	                                 /* Always High */
	MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
	set_prior(2);	                                 /* Regular  */

	if (fullscreen)
	{
		screen_clear ();
		sb_dirty ();
	}

	opening_banner ();

	if (fullscreen)
	{
		mailer_banner ();
	}

	if ((tfile = fopen ("BINKLEY.BAN", read_binary)) != NULL)
	{
		(void) fread (BBSwelcome, 1, 1000, tfile);
		(void) fclose (tfile);
	}
	else
	{
		BBSwelcome[0] = '\0';
	}

	/* Initialize the random number generator */
	i = (int) time (NULL);
	srand ((unsigned int) i);

#ifdef ATARIST
	status_line ("+%s, %s [%s], %s %ld",
		msgtxt[M_BEGIN], xfer_id, compile_date, msgtxt[M_FREEMEM], Malloc(-1L));
#else
	status_line ("+%s, %s", msgtxt[M_BEGIN], xfer_id);
#endif
	/*set_xy ("");*/
	set_prior(4);	                                 /* Always High */
	XON_DISABLE ();
	set_prior(2);	                                 /* Regular  */

	/* Turn off forced events */
	if (noforce)
	{
		find_event ();
		noforce = 0;
	}
	if (redo_dynam)
	{
		for (i = 0; i < num_events; i++)
		{
			e_ptrs[i]->behavior &= ~MAT_SKIP;
		}
		redo_dynam = 0;
	}

	/*
     * See if we should exit before initializing the modem (and therefore
     * possibly letting a call sneak through)
	 */
	find_event ();
	do_ready (msgtxt[M_READY_INIT]);

	/* Make sure we have all necessary parameters and that the nodelist
     * index gets read in. If not, then we must exit right now.
	 */

	next_addr = alias[0].ad;	/* Does our node exist (or our boss if we're a point */
	next_addr.Point = 0;

	if(!net_params || !nodefind(&next_addr, 0))
		if(alias[0].ad.Net != -1)
		{
			status_line (msgtxt[M_MISCONFIGURED]);
			errl_exit (254);
		}

	/* Set up outbound mail */
	list_next_event ();
	set_up_outbound ();

	if (!CARRIER)
	{
		set_prior(4);		                              /* Always High */
		mdm_init (modem_init);		                     /* Reinitialize the modem  */
		set_prior(2);		                              /* Regular  */
	}

	t1 = timerset ((long)next_minute ());	                         /* Set a 1 minute timer  */


top_of_mail:
	un_attended = 1;
	i = 0;
	m = 1;

	/* As long as we don't press a key */
bad_char:
	more_mail = 1;
	while (!(KEYPRESS () || ctrlc_ctr))
	{
		find_event ();

		/* Show that we are ready */
		if (m)
		{
			if (fullscreen)
			{
				do_ready (msgtxt[M_READY_WAITING]);
				list_next_event ();
			}
			else
			{
				status_line (msgtxt[M_EVENT_WAITING], cur_event + 1);
			}
			t1 = timerset ((long)next_minute ());			              /* Set a 1 minute timer */
		}

		if (timeup (t1))
		{
			minute ();
			t1 = timerset ((long)next_minute ());			                   /* Set a 1 minute timer */
		}

		m = 0;

		if (cur_event >= 0)
		{
			i = (e_ptrs[cur_event]->behavior & MAT_OUTONLY);
			t = random_time (e_ptrs[cur_event]->wait_time);
		}
		else
		{
			i = 1;
			t = random_time (5);
		}

	 /*  variable 'i' will be TRUE if we are either manually dialing out
      *  or if we are in an event where we do not want incoming stuff.
	  */

		while ((!timeup (t)) && (!KEYPRESS ()) && (m == 0) && !ctrlc_ctr)
		{

			find_event ();

			time_release ();

			if (timeup (t1))
			{
				minute ();
				t1 = timerset ((long)next_minute ());				             /* Set a 1 minute timer */
			}

			/* If we want inbound, see if there is any. If we send
			            anything, clean up afterwards ...       */

			if (!i)
			{
				m = handle_inbound_mail ();
				if (m)
					set_up_outbound ();
			}
		}

		if ((m) && (fullscreen))
		{
			do_ready (msgtxt[M_READY_WAITING]);
			list_next_event ();
		}

immed_call:

		find_event ();

		/* If we are not in an event, loop again */
		if (cur_event < 0)
		{
			time_release ();
			continue;
		}

		/* If we have pressed a key, get out */
		if (KEYPRESS () || ctrlc_ctr)
			break;

		/* See if we are supposed to do any mail */
		if (cur_event >= 0)
			if (e_ptrs[cur_event]->behavior & MAT_NOOUT)
			{
				continue;
			}

		if (more_mail)
		{
			more_mail = xmit_next (&next_addr);
			if (more_mail)
			{
				/* save the next call in the list in case we exit */

				if ((next_mail == NULL) || (next_mail->next == NULL))
					mp = mail_top;
				else
					mp = next_mail->next;

				hist.next_zone = mp->mail_addr.Zone;
				hist.next_net = mp->mail_addr.Net;
				hist.next_node = mp->mail_addr.Node;
				hist.next_point = mp->mail_addr.Point;
				memset(hist.next_Domain, 0, sizeof(hist.next_Domain));
				if(mp->mail_addr.Domain)
					strcpy(hist.next_Domain, mp->mail_addr.Domain);

				set_prior(4);				                        /* Always High */
				m = do_mail (&next_addr, 0);
				set_prior(2);				                        /* Regular */

				if(m == 1)		/* Connected with carrier */
				{
					if (!sent_mail)
					{
						/* We connected but the transfer didn't work */
						bad_call (&next_addr, BAD_CARRIER);
						xmit_window (next_mail);
					}
					else
					{
						set_up_outbound();
					}
				}

				else if (m == 2)					                     /* Nothing happened */
				{
					bad_call (&next_addr, BAD_NOCARRIER);
				}

				else if (m == -1)
				{
					status_line (msgtxt[M_INCOMING_CALL]);
				}
			}
		}

		if (!more_mail)
		{
			/* No more mail to do, was it dynamic? */
			if (cur_event >= 0)
				if (e_ptrs[cur_event]->behavior & MAT_DYNAM)
				{
					if (!blank_on_key)
						screen_blank = 0;
					e_ptrs[cur_event]->behavior |= MAT_SKIP;
					status_line (":%s %s %d", msgtxt[M_END_OF], msgtxt[M_DYNAMIC_EVENT], cur_event + 1);
					goto top_of_mail;
				}
		}
	}

	/*-----------------------------------------------------------------
	 * We get to here if a key is pressed
	 *
	 * If the code was laid out better and the labels and goto's were
	 * converted into looping constructs this would be much easier to read.
	 */


	/* any key to unblank, SWG 24th June 1991 */
	if(screen_blank && do_screen_blank)
	{
		if(KEYPRESS())						/* Clear the key */
			FOSSIL_CHAR();
		screen_blank = 0;				/* Unblank the screen */
		if(fullscreen)						/* Redisplay the screen */
			sb_show();
		goto bad_char;
	}

	/* No key press should not exit! SWG 24th June 1991 */
	if(ctrlc_ctr)
	{

 	  	/*
         * Be serious, there had to be a key pressed or we wouldn't be here I
         * know it sounds silly, but ^C will sometimes do crap like this
	     */
		status_line (msgtxt[M_EXIT_REQUEST]);
	}
	else
	{
			/* No keypress available then continue, SWG 24th June 1991 */
			if(!KEYPRESS())
				goto bad_char;				/* May as well be using Basic with all these goto's!!! */
			i = (int) FOSSIL_CHAR ();
#ifndef ATARIST
			if ((i & 0xff) == 0)
			{
#endif
				switch (i)
				{
				case PF1:
				case PF2:
				case PF3:
				case PF4:
				case PF5:
				case PF6:
				case PF7:
				case PF8:
				case PF9:
				case PF10:
				
					j = (int) (((unsigned) i) >> 8);
					status_line (msgtxt[M_FUNCTION_KEY], (j - 0x3a) * 10);
					errl_exit ((j - 0x3a) * 10);
					break;

				/* ANSWER  24.05.1990 */
				case ALTA:
					CLEAR_INBOUND ();
					mdm_cmd_string (ans_str, 0);					  /* transmit the answer */
					m = handle_inbound_mail ();
					if (m)
					{
						/* If we sent out anything, make sure we reset stuff */
						set_up_outbound ();
					}
					goto bad_char;

				case ALTB:
					screen_blank = 1;
					if (fullscreen)
						sb_show ();
					goto bad_char;

				case ALTC:
					tmp = hist.which_day;
					(void) memset (&hist, 0, sizeof (HISTORY));
					hist.which_day = tmp;
					if (fullscreen)
					{
						do_today ();
						sb_show ();
					}
					goto bad_char;

				case ALTE:
				case CTRLM:		/* Control M for ACS compatibility */
					if (BBSreader != NULL)
					{
						vfossil_cursor (1);
						status_line (msgtxt[M_DISABLE_MODEM]);
						set_prior(4);						                  /* Always High */
						mdm_init (modem_busy);
						exit_DTR ();
						set_prior(2);						                  /* Regular */
						status_line (msgtxt[M_BEGIN_MESSAGE_READER]);
						vfossil_close ();
						b_spawn (BBSreader);
						vfossil_init ();
						if (fullscreen)
						{
							screen_clear ();
							sb_dirty ();
							opening_banner ();
							mailer_banner ();
						}
						status_line (msgtxt[M_END_MESSAGE_READER]);
						set_up_outbound ();
						m = 1;
						more_mail = 1;
						status_line (msgtxt[M_ENABLE_MODEM]);
						set_prior(4);						                  /* Always High */
						DTR_ON ();
						mdm_init (modem_init);
						set_prior(2);						                  /* Regular */
						goto top_of_mail;
					}
					else
					{
						set_xy (NULL);
						status_line (msgtxt[M_NO_MESSAGE_READER]);
						set_xy (NULL);
						m = 1;
						goto bad_char;
					}

				/* NICEOUTBOUND  09.09.1990 */
				case ALTF:
					niceoutbound = 1-niceoutbound;
					if (niceoutbound)
					{
						xmit_reset ();
					}
					else
					{
#if 0
						next_mail = mail_top;
#endif
						xmit_window (next_mail);
					}
					goto bad_char;

				/* Roland's flavour changer */

				case CTRLC:
				case CTRLF:
					if (sb_popup (10, 10, 6, 60, Do_Change, 0))
						status_line (msgtxt[M_NO_CHANGE]);
					else
					{
						set_up_outbound ();
						m = 1;
						more_mail = 1;
					}
					goto bad_char;

				case ALTG:
					/* ONEMORE  01.09.1990 */
					if (sb_popup (10, 10, 6, 60, Do_Get, 0))
					{
						status_line (msgtxt[M_NO_GET]);
					}
					else
					{
						set_up_outbound ();
						m = 1;
						more_mail = 1;
					}
					goto bad_char;

				case ALTI:
					/* FASTMODEM, REINIT  18.07.1990 */
					mdm_hangup ();
					reinit_ctr = reinit_time;
					m = 1;
					goto bad_char;
				case ALTJ:
					status_line (msgtxt[M_SHELLING]);
					/* EXEC  18.07.1990 */
					set_prior(4);
					mdm_init (modem_busy);
					exit_DTR ();
					set_prior(2);
					if (fullscreen) screen_clear ();
					vfossil_cursor (1);
					(void) cputs (msgtxt[M_TYPE_EXIT]);
					close_up ();
					change_prompt ();
					b_spawn (NULL);
					come_back ();
					m = 1;
					set_up_outbound ();
					set_prior(4);					                     /* Always High */
					DTR_ON ();
					mdm_init (modem_init);
					reinit_ctr = reinit_time;
					status_line (msgtxt[M_BINKLEY_BACK]);
					set_prior(2);					                     /* Regular */
					goto bad_char;

				case ALTK:
					if (sb_popup (10, 5, 4, 70, Do_Kill, 0))
					{
						status_line (msgtxt[M_NO_KILL]);
					}
					else
					{
						set_up_outbound ();
						m = 1;
						more_mail = 1;
					}
					goto bad_char;

				case ALTY:
					next_addr = alias[0].ad;	/* Poll ourself */
					next_addr.Point = 0;		/* Remove the point to get boss */
					goto polling;

				/* ZOOM  27.08.1990 */
				case ALTZ:
					if (sb_popup (1, 1, SB_ROWS-2, 78, Overlay_Do_Zoom, 0))
					{
					}
					goto bad_char;

				case ALTM:
					status_line (msgtxt[M_POLL_MODE]);
					if (fullscreen)
						gotoxy (0, SB_ROWS - 2);
					vfossil_cursor (1);
					scr_printf ("\r\n");
					clear_eol ();
					scr_printf (msgtxt[M_ENTER_NET_NODE]);
					m = get_number (jbuf);
					if (m)
					{
						m = find_address (jbuf, &next_addr);
					}
					if (fullscreen)
					{
						gotoxy (0, SB_ROWS - 1);
						clear_eol ();
						bottom_line ();
						vfossil_cursor (0);
						sb_show ();
					}
					if (m >= 1 && nodefind (&next_addr, 1))
					{
						if (!next_addr.Zone)
							next_addr.Zone = found_zone;

						/* Warn user that it is not CM */

						if ( (cur_event < 0 || (e_ptrs[cur_event]->behavior & MAT_NOCM))
							&& (!(newnodedes.NodeFlags & B_CM)))
						{
							int c;

							if (fullscreen)
								gotoxy (0, SB_ROWS - 2);
							vfossil_cursor (1);
							scr_printf ("\r\n");
							clear_eol ();
							scr_printf ("WARNING: ");
							scr_printf(Pretty_Addr_Str(&next_addr));
							scr_printf(" is not 24 Hours... poll anyway(Y/N)?");
							while (!KEYPRESS ())
								time_release ();
							c = FOSSIL_CHAR ();
							if (fullscreen)
							{
								gotoxy (0, SB_ROWS - 1);
								clear_eol ();
								bottom_line ();
								vfossil_cursor (0);
								sb_show ();
							}
							if(toupper(c) != 'Y')
							{
								status_line("#Poll aborted");
								goto bad_char;
							}
						}
polling:
						doing_poll = 1;
						if (fullscreen)
						{
							sb_move (filewin, 1, 2);
							sb_puts (filewin, (unsigned char *) msgtxt[M_CURRENTLY_POLLING]);
							sb_puts (filewin, (unsigned char *) Pretty_Addr_Str (&next_addr));
						}
						set_prior(4);						/* Always High */
						if (do_mail (&next_addr, 1) == 1)
						{
							if(sent_mail)
								set_up_outbound();
							else
								xmit_window (next_mail);
						}
							
						set_prior(2);						/* Regular */
						doing_poll = 0;
					}
					status_line (msgtxt[M_POLL_COMPLETED]);
					if (fullscreen)
					{
						clear_filetransfer ();
					}
					set_prior(4);					        /* Always High */
					DTR_ON ();
					mdm_init (modem_init);
					set_prior(2);					        /* Regular */
					m = 1;
					goto bad_char;

				/* OUTBOUND  23.10.1989 */
				case ALTO:
					set_up_outbound ();
					m = 1;
					more_mail = 1;
					goto bad_char;

				case ALTQ:
					if (cur_event >= 0)
						e_ptrs[cur_event]->behavior |= MAT_SKIP;
					goto top_of_mail;

				case ALTR:
					for (j = 0; j < num_events; j++)
					{
						/* Don't redo forced events */
						if (!(e_ptrs[j]->behavior & MAT_FORCED))
						{
							e_ptrs[j]->last_ran = -1;
							e_ptrs[j]->behavior &= ~MAT_SKIP;
						}
					}
					goto top_of_mail;

				case ALTS:
					if (sb_popup (10, 5, 6, 70, Do_Send, 0))
					{
						status_line (msgtxt[M_NO_SEND]);
					}
					else
					{
						set_up_outbound ();
						m = 1;
						more_mail = 1;
					}
					goto bad_char;

				case ALTT:
#ifdef ATARIST
				case UNDO:
#endif            
					status_line (msgtxt[M_ENTER_TERMINAL_MODE]);
					b_init ();
					done = 0;					                         /* We won't exit now */
					goto mail_done;

				case ALTW:
					if (fullscreen)
					{
						screen_clear ();
						sb_dirty ();
						sb_show ();
					}
					goto bad_char;
					
#if N_SHELLS < 10
				case ALTF10:
#endif            
#ifdef ATARIST
				case HELP:
#endif			            
					mailer_help ();
					if (fullscreen)
					{
						screen_clear ();
						sb_dirty ();
						opening_banner ();
						mailer_banner ();
					}
					m = 1;
					goto bad_char;

				case ALTX:
				case CTRLQ:		/* ^Q for ACS compatibility */
					status_line (msgtxt[M_EXIT_REQUEST]);
					goto mail_done;

				case ALTF1:
				case ALTF2:
				case ALTF3:
				case ALTF4:
				case ALTF5:
				case ALTF6:
				case ALTF7:
				case ALTF8:
				case ALTF9:
#if N_SHELLS >= 10
				case ALTF10:
#endif
					j = (int) (((unsigned) i) >> 8) - ((unsigned)ALTF1>>8);
					if (shells[j] != NULL)
					{
						/* GENERALEXEC  24.09.1989 */
						exec_shell (++j);
						m = 1;
						goto top_of_mail;
					}

					status_line (msgtxt[M_NO_KEYBOARD_SHELL], j + 1);
					goto bad_char;

				case PGUP:
					if (next_mail == NULL)
						next_mail = mail_top;

					if (next_mail != NULL)
					{
						for (j = 0; j < 4; j++)
						{
							if (next_mail->prev != NULL)
								next_mail = next_mail->prev;
						}
						xmit_window (next_mail);
					}
					goto bad_char;

				case PGDN:
					if (next_mail == NULL)
					{
						next_mail = mail_top;
					}

					if (next_mail != NULL)
					{
						for (j = 0; j < 4; j++)
						{
							if (next_mail->next != NULL)
								next_mail = next_mail->next;
						}
						xmit_window (next_mail);
					}
					goto bad_char;

				case UPAR:
					if (next_mail == NULL)
					{
						next_mail = mail_top;
					}

					if (next_mail != NULL)
					{
						if (next_mail->prev != NULL)
							next_mail = next_mail->prev;
						xmit_window (next_mail);
					}
					goto bad_char;

				case DNAR:
					if (next_mail == NULL)
					{
						next_mail = mail_top;
					}

					if (next_mail != NULL)
					{
						if (next_mail->next != NULL)
							next_mail = next_mail->next;
						xmit_window (next_mail);
					}
					goto bad_char;

				case HOME:
					next_mail = mail_top;
					xmit_window (next_mail);
					goto bad_char;

				case END:
					if (next_mail == NULL)
					{
						next_mail = mail_top;
					}

					if (next_mail != NULL)
					{
						while (next_mail->next != NULL)
						{
							next_mail = next_mail->next;
						}
					}

					for (j = 0; j < 3; j++)
					{
						if (next_mail->prev != NULL)
							next_mail = next_mail->prev;
					}
					xmit_window (next_mail);
					goto bad_char;

#ifndef ATARIST
				default:
					status_line (msgtxt[M_JUNK_CHARACTER]);
					m = 1;
					goto bad_char;
				}
			}
			else
			{
				switch (i & 0xff)
				{
#endif
				case ESC:
					m = sb_popup(10,2, 3,74, do_shell, 0);
					goto bad_char;

				case 'C':
				case 'c':
					if (cur_event >= 0)
						if (e_ptrs[cur_event]->behavior & MAT_NOOUT)
						{
							status_line (msgtxt[M_NO_CALLS_NOW]);
							goto immed_call;
						}

					status_line (msgtxt[M_IMMEDIATE_CALL]);
					m = 0;
					more_mail = 1;
					goto immed_call;

				case '$':
					kill_bad();
					goto bad_char;

#ifndef ATARIST		/* Put in same place as Alt-X */
				case 3:
					status_line (msgtxt[M_EXIT_REQUEST]);
					goto mail_done;
#endif

				case 0x20:
					m = 1;
					goto bad_char;

				default:
					status_line (msgtxt[M_JUNK_CHARACTER]);
					m = 1;
					goto bad_char;
				}
#ifndef ATARIST
			}
#endif
		}

mail_done:
	write_sched ();
	status_line ("+%s, %s", msgtxt[M_END], xfer_id);
	un_attended = 0;
	if (fullscreen)
	{
		gotoxy (0, SB_ROWS);
	}
	set_prior(4);	                                 /* Always High */
	XON_ENABLE ();
	set_prior(2);	                                 /* Regular */
	return (done);
}
