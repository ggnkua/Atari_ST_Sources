/*  Copyright (c) 1988 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* IPFF.C */

#include "prelude.h"
#include "ipff.h"

static
char stpa[]=		/* translation and stop table */
{
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	'0','1','2','3','4','5','6','7','8','9',0,0,0,0,0,0,
	0,'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
	'P','Q','R','S','T','U','V','W','X','Y','Z',0,0,0,0,'_',
	0,'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
	'p','q','r','s','t','u','v','w','x','y','z',0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

static
char *ln="",				/* current line */
     *xln = "",				/* next line */
     *stp=stpa;				/* tabel */

static
short mc;						/* current   "     "  */
static
bool vul=false,				/* str aanvullen met ' ' */
	 snl=true;				/* \nl is white space */

global
char *ipff_line(long *l)
{
	char *t,*s;

	t = s = xln;

	if (*s eq 0)			/* eof */
		return 0;

	while (*s)
	{
		t = s;
		if (*s eq '\r' and *(s+1) eq '\n')
		{
			*s++=0;
			*s++=0;
			break;
		}
		elif (*s eq '\n')
		{
			*s++=0;
			break;
		}
		s++;
	}

	ln = xln;
	xln = s;
	if (l)
		*l = t - ln;
	return ln;
}

global
void ipff_trail(char *ln)		/* remove trailing spaces */
{
	if (*ln)
	{
		char *t = ln;
		while (*t ne 0)
			t++;
		t--;
		while (t >= ln and (*t eq ' ' or *t eq '\t') )
			*t = 0, t--;
	}
}

global
char *ipff_init(short m, bool nl, bool f, char *t,char *l,char **tt)
{
	if ( t >= 0 )				/* -1 dont change */
	{							/*  0 use default */
		if ( t ne nil ) stp=t;	/*  value, use that */
		else            stp=stpa;
	}

	if ( l > 0 )
		ln=l;

	if ( m >= 0 )
	{
		if ( m ne 0 ) mc=m;
		else          mc=IPFF_L;
	}
	vul=f;
	snl=nl;
	if (tt)
		*tt=stp;	/* give translation table (for instance default) */

	return ln;								/* give line */
}

global
void ipff_in(char *p)
{
	ipff_init(0,0,0,nil,p,nil);
}

global
char *ipff_getp(void)
{
	return ln;
}

global
void ipff_putp(char *s)
{
	ln = s;
}

global
short sk (void)		/* skip white space */
{
	short c;

	while ((c=*ln) eq ' '
	          or c eq '\t'
	          or c eq '\r'
	          or (!snl and c eq '\n')
	      ) ++ln;
	return c;		/* can be zero: end input */
}

global
short skc(void)		/* skip analysed character and following white space */
{
	if (*ln) ++ln;
	return sk();
}

global
short sk1(void)		/* skip only analysed character */
{
	if (*ln)
		return *(++ln);
	return 0;
}

global
short str(char *w)	/* give identifier */
{
	short i,c,vc;
	i=0;

	while  (i<mc)
	{
		if ( ( c=*ln)         eq 0 ) break;	/* einde input */
		if ( (vc=stp[c&0x7f]) eq 0 ) break;	/* stop ch     */
		*w++=vc;++ln;++i;
	}
	if (vul) {while (i++<mc) *w++=' ';}		/* vul aan met spatie */
	*w=0;
	return c;		/* return stop ch for analysis */
}

global
bool look(char *s, short l)
{
	char *p = ln;
	while (l)
	{
		if (*s ne *p) return false;
		if (*s eq 0 or *p eq 0) return false;
		--l, ++s, ++p;
	}
	return true;
}

global
void nstr(char *w)	/* give rest of line */
{
	short i, c;
	i = 0;

	while (i < mc)
	{
		c = *ln;
		if (   c eq 0
		    or c eq '\r'
		    or c eq '\n') break;	/* einde input */
		*w++ = c; ++ln; ++i;
	}

	*w = 0;
}

global
short fstr(char *w)		/* terminated by space or ( or ) or , */
{
	short i, c;
	i = 0;

	while (i < 128)
	{
		c = *ln;
		if (   c eq 0
		    or c eq ' '
		    or c eq '\t'
		    or c eq '\r'
		    or c eq '\n'
		    or c eq '('
		    or c eq ')'
		    or c eq ',' ) break;
		*w++ = c; ++ln; ++i;
	}

	*w = 0;
	return c;
}

#define xdec(a)\
	a n = 0; bool t = false;\
	if ( *ln eq '-')\
		ln++,\
		t = true;\
	while (*ln >= '0' and *ln <= '9')\
		n = 10*n+*ln++-'0';\
	if (t) return -n;\
	else   return  n;

global
short idec(void)
{
	short n = 0; bool t = false;
	if ( *ln eq '-')
		ln++,
		t = true;
	while (*ln >= '0' and *ln <= '9')
		n = 10*n+*ln++-'0';
	if (t) return -n;
	else   return  n;
}

global
long   dec(void) {xdec(long )}

global
long hex(void)
{
	long n = 0; short c; bool t = false;

	if ( *ln eq '-')
		ln++,
		t = true;

	while ( (c=*ln) ne 0)
	{
		if   ( c >= '0' and c <= '9')
			n=16*n+(c-'0');
		elif ( c >= 'A' and c <= 'F')
			n=16*n+(c-'A'+10);
		elif ( c >= 'a' and c <= 'f')
			n=16*n+(c-'a'+10);
		else
			break;
		ln++;
	}
	if (t) return -n;
	else   return  n;
}

global
long oct(void)
{
	long n = 0; bool t = false;

	if ( *ln eq '-')
		ln++,
		t = true;

	while (*ln >= '0' and *ln <= '7')
		n = 8*n+*ln++-'0';

	if (t) return -n;
	else   return  n;
}

global
short sknl(void)
{
	while (*ln and *ln ne '\n') ln++;
	return sk1();
}

