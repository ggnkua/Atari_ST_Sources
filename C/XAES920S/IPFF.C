/* IPFF (c) 1988 H. Robbers
 * Input Parameters in Free Format
 * Unnecessitates the use of stream IO for all these kinds
 *  of small parameter files.
 */

#include "prelude.h"
#include <fcntl.h>
#include <osbind.h>
#include <stdlib.h>
#include <string.h>
#include "ctype.h"			/* We use the version without macros!! */
#include "xmemory\xa_mem.h"

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

/* The above table can be replaced in case of non UK;
   see ipff_init.
 */

static
char *ln="",				/* current line */
	 *xln = "",				/* next line */
     *stp=stpa;				/* tabel */
#define max 15				/* default string max */
#define pax 128				/* default path   max */
static
int mc,						/* current  string  max */
    mp;						/* current  path    max  */
static
bool vul=false;				/* str aanvullen met ' ' */

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
	char *t = ln;
	while (*t ne 0)
		t++;
	while (*t eq ' ' and t >= ln)
		*t-- = 0;
}

global
char *ipff_init(int m, int p, int f, char *t,char *l,char **tt)
{
	if ( t >= 0 )				/* -1 dont change */
	{							/*  0 use default */
		if ( t ne nil ) stp=t;	/*  value, use that */
		else            stp=stpa;
	}

	if ( l > 0 )
		ln=l;

	if ( p >= 0 )
	{
		if ( p ne 0 ) mp=p;
		else          mp=pax;
	}
	if ( m >= 0 )
	{
		if ( m ne 0 ) mc=m;
		else          mc=max;
	}

	vul=f;

	if (tt)
		*tt=stp;	/* give translation table (for instance default) */
	xln = ln;
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
int sk (void)		/* skip white space */
{
	int c;

	while ((c=*ln) eq ' ' 
	          or c eq '\t' 
	          or c eq '\r' 
	          or c eq '\n'
	      ) ++ln;
	return c;		/* can be zero: end input */
}

global
int skc(void)		/* skip analysed character and following white space */
{
	if (*ln) ++ln;
	return sk();
}

global
int sk1(void)		/* skip only analysed character */
{
	if (*ln)
		return *(++ln);
	return 0;
}

global
int lstr(char *w, unsigned long lim)	/* give delimited string */
{
	int i=0,c,vc;
	char *s = (char *)&lim;

	while  (i<mc)
	{
		if ((c=*ln) eq 0) break;	/* einde input */
		if (c eq *(s+3)) break;
		if (c eq *(s+2)) break;
		if (c eq *(s+1)) break;
		if (c eq * s   ) break;
		*w++=c;++ln;++i;
	}
	if (vul) {while (i++<mc) *w++=' ';}		/* vul aan met spatie */
	*w=0;
	return c;		/* return stop ch for analysis */
}

global
int str(char *w)	/* give string */
{
	int i,c,vc;
	i=0;

	while  (i<mc)
	{
		if ( ( c=*ln)    eq 0 ) break;	/* einde input */
		if ( (vc=stp[c]) eq 0 ) break;	/* stop ch     */
		*w++=vc;++ln;++i;
	}
	if (vul) {while (i++<mc) *w++=' ';}		/* vul aan met spatie */
	*w=0;
	return c;		/* return stop ch for analysis */
}

global
int fstr(char *p,int cas)	/* give a path regarding '' "" or () */
{					/* p must be large enough (see ipff_init) */
	char *b = p;
	int t = ' ';
	bool apo = *ln eq '\'' or *ln eq '\"' or *ln eq '(';
	if (apo)
		t = *ln++;
	if (t eq '(') t = ')';
	while (*ln and *ln ne t and p-b < mp-1)
		*p++ = cas ? cas > 0 ? toupper(*ln++) : tolower(*ln++) : *ln++;
	*p = 0;
	if (apo and *ln eq t) ln++;
	return *ln;
}

global
void nstr(char *w)	/* give rest of line */
{
	int i,c,vc;
	i=0;

	while  (i<mc)
	{
		c = *ln;
		if (   c eq 0 
		    or c eq '\r'
		    or c eq '\n') break;	/* einde input */
		*w++=c;++ln;++i;
	}
	*w=0;
}

global
int idec(void)		/* just there to avoid long mul */
{
	int n = 0; bool t = false;

	if ( *ln eq '-')
		ln++,
		t = true;

	while (*ln >= '0' and *ln <= '9')
		n = 10*n+*ln++-'0';

	if (t) return -n;
	else   return  n;
}

global
long dec(void)
{
	long n = 0; bool t = false;

	if ( *ln eq '-')
		ln++,
		t = true;

	while (*ln >= '0' and *ln <= '9')
		n = 10*n+*ln++-'0';

	if (t) return -n;
	else   return  n;
}

global
long hex(void)
{
	long n = 0; int c; bool t = false;

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
long bin(void)
{
	long n = 0; bool t = false;

	if ( *ln eq '-')
		ln++,
		t = true;

	while (*ln >= '0' and *ln <= '1')
		n = 2*n+*ln++-'0';

	if (t) return -n;
	else   return  n;
}

global
bool truth(void)
{
	char v[128];
	if (*ln >= '0' and *ln <= '9')
		return idec() != 0;
	str(v);
	if (strcmp(v, "true") eq 0)
		return true;
	return false;
}

global
char *Fload(const char *name, int *fh, long *l)
{
	long pl,fl;
	char *bitmap=0L;

	*l  =0;
	fl  =*fh;		/* if already opened, *fh is handle */
	if (name)		/* if not already or want to open */
		fl = Fopen(name,O_RDONLY);
	if (fl > 0)
	{
		fl&=0xffff;
		pl=Fseek(0L,fl,2);		/* seek end */
		Fseek(0L,fl,0);			/* seek start */
		bitmap=xmalloc(pl+1, 200);
		if (bitmap)
		{
			Fread(fl,pl,bitmap);
			Fclose(fl);
			*l=pl;
			*(bitmap+pl)=0;		/* make it a C string */
		}
	}
	*fh=fl;
	return bitmap;
}
