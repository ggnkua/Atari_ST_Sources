/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [v24.c]
 */

#include "define.h"
#ifndef MWC
overlay "V.24"
#else
#define DEBUG
#endif

/* Auf s[0...c] warten. Bei ESC abbrechen und -1 zurueckgeben,
   bei Timeout c + 1 zurueckgeben. Timo in Sekunden. */

xpect(v,c,timo)
char *v[];
int c,timo;
{
	char s[LLEN + 10],s2[LLEN + 10],*p;
	int n;
	long t1;

	t1 = (timer() + (long)(timo * 250));

	for (n = 0; n < c; ++n)
	{
		send(v[n]);
		cr(1);
	}

	strmul('_',LLEN,s);

	while (timer() < t1)
	{
		if (xstat() != 0)
		{
			send("TTY income.");
			cr(1);
			p = s;
			++p;
			strcpy((char *)p,s2);
			strcpy(s2,s);

			send("xin()...");
			cr(1);

			str(xin(),s2);
			stradd(s2,s);
		}

		send("Comparing...");
		cr(1);

		
		for (n = 0; n < c; ++n)
		{
			send("Strcpys... ");
			strcpys(s,s2,LLEN - strlen(v[n]),9999);
			send("ok.");
			cr(1);

			sendd(n);
			send(". cmp: ");
			send(s2);
			send(",");
			send(v[n]);
			cr(1);

			if (strcmp(s2,v[n]) == TRUE)
				return(n + 1);
		}
	}

	if (timer() >= t1)
		return(c + 1);
}

xin()
{
	char c;
	long l;

#ifndef MWC
	long bios();
#endif

	l = bios(2,1);
	c = l & 255;
	return(c);
}

xout(c)
char c;
{
	int i;
	i = c;
	bios(3,1,i);
}

int xstat()
{
	return(bios(1,1));	/* Bconstat(AUX:) */
}

/* Broadcast null-determined string 's' */
bcast(s)
char *s;
{
	while (*s)
		xout(*s++);
}

stty(argv)		/* Rs232c konfigurieren */
int argv;
{
	int r;
	switch(argv)
	{
		case 50:
			r = 15;
			break;
		case 75:
			r = 14;
			break;
		case 110:
			r = 13;
			break;
		case 134:
			r = 12;
			break;
		case 150:
			r = 11;
			break;
		case 200:
			r = 10;
			break;
		case 300:
			r = 9;
			break;
		case 600:
			r = 8;
			break;
		case 1200:
			r = 7;
			break;
		case 1800:
			r = 6;
			break;
		case 2000:
			r = 5;
			break;
		case 2400:
			r = 4;
			break;
		case 3600:
			r = 3;
			break;
		case 4800:
			r = 2;
			break;
		case 9600:
			r = 1;
			break;
		case 19200:
			r = 0;
			break;
		default:
			r = -1;
			break;
	}
		
	if (r == -1)
		return(-1);
			
	xbios(15,r,-1,-1,-1,-1,-1);
}


