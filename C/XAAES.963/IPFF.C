/* IPFF (c) 1988-2003 by H. Robbers @ Amsterdam
 * Input Parameters in Free Format
 * Unnecessitates the use of stream IO for all these kinds
 *  of small parameter files.
 */

/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <prelude.h>
#include <fcntl.h>
#include <osbind.h>
#include <string.h>
#include <ctype.h>		/* We use the version without macros!! */
#include "ipff.h"
#include "display.h"

#include MEMORY_HNAME

#include "xalloc.h"

global
/* SYMBOL *(*outer_sym)(char *) = nil; */
GetSym *outer_sym;

static
char stpa[]=		/* translation and stop table for identifiers  */
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
char fstpa[256];		/* translation and stop table for fstr */


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
bool vul=false;				/* ide aanvullen met ' ' */

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
	while (--t >= ln and (*t eq ' ' or *t eq '\t') )
		*t = 0;
}

global
char *ipff_init(int m, int p, int f, char *t,char *l,char **tt)
{
	int i;
	for (i=0;i<256;i++)	/* every character is allowed */
		fstpa[i] = i;
	fstpa[' ']=0;		/* except these real hard separators */
	fstpa['\t']=0;
	fstpa['\r']=0;
	fstpa['\n']=0;
	fstpa[',']=0;
	fstpa['|']=0;
	
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
		*tt=stp;	/* give identifier translation table (for instance default) */
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
	return c ;		/* can be zero: end input */
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
	int i=0,c;
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
int ide(char *w)	/* give string */
{
	int i,c,vc;
	i=0;

	while  (i<mc)
	{
		if ( ( c=*ln)    eq 0 ) break;	/* einde input */
		if ( (vc=stp[c&0xff]) eq 0 ) break;	/* stop ch     */
		*w++=vc;++ln;++i;
	}
	if (vul) {while (i++<mc) *w++=' ';}		/* vul aan met spatie */
	*w=0;
	return c;		/* return stop ch for analysis */
}

static
int brace(void)
{
	switch (*ln)
	{
		case '\'':
		case '"':
			return *ln++;
	}

	return 0;
}

global
bool infix(void)
{
	int c = sk();
	return c eq ',' or c eq '|';
}

global
int idec(void)		/* only there to avoid long mul */
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

extern long fl;


/* 0 = true, anything else is false */
global
bool truth(void)
{
	bool rev = 0, t = 1;
	SYMBOL *s;
	char v[128];
	sk();
	if (*ln == '!')
		rev = 1, skc();
	if (*ln >= '0' and *ln <= '9')
		t = (idec() ? 0 : 1);
	else
	{
		ide(v);
		if (*v)
		{
			if (strcmp(v, "not") eq 0)
				return truth() eq 0 ? 1 : 0;
			if (strcmp(v, "true") eq 0)
				t = 0;
			elif (strcmp(v, "false") eq 0)
				t = 1;
			elif (strcmp(v, "yes") eq 0)
				t = 0;
			elif (strcmp(v, "no") eq 0)
				t = 1;
			else
			{
				s = find_sym(v, outer_sym);
				if (s)
				{
					if (s->mode == Bit)
						t = s->val;
					elif (s->mode == String)
						t = s->s ? 0 : 1;
					else
						t = s->val ? 0 : 1;
				}
			}
		}
	}
	return rev == 0 ? t : (t == 0 ? 1 : 0);
}

global
bool is_ide(char *s)	/* Check if the string conforms to the
                           character set for identifiers. */
{
	while (*s)
		if (stpa[*s&0xff] eq 0)		/* same table as for ide() */
			return false;
		else
			s++;
	return true;
}

global
SYMBOL *fstr(char *p, int cas, int lval)	/* give a path regarding delimiters */
{					/* p must be large enough (see ipff_init) */
	char *start = p;
	SYMBOL *s;

	while (*ln and p-start < mp-1)
	{
		int c = sk();
		bool tostr = c eq '#';

		if (tostr)
			c = skc();

		if (c >= '0' and c <= '9')
		{
			if (tostr)
				*p++ = dec();
			else
				p += sdisplay(p, "%ld", dec());
		othw
			char *first = p;
			int apo = brace();
			while (*ln and *ln ne apo and p-start < mp-1)
			{
				int c = *ln;
				if (!apo)
					if ((c = fstpa[c&0xff]) eq 0)
						break;
				*p++ = cas ? cas > 0 ? toupper(c) : tolower(c) : c;
				ln++;
			}
	
			if (apo and *ln eq apo)
				ln++;
			else
			{
				*p = 0;
				if (    !lval
				    and is_ide(first)
				    and (s = find_sym(first, outer_sym)) ne nil
				   )
				{
					if (s->mode eq String)
					{
						strcpy(first, s->s);
						p = first + strlen(first);
					}
					else if (s->mode eq Bit)
					{
						first += sdisplay(first, "%s", s->val ? "false" : "true");
						p = first;
					}
					else if (s->mode eq Number)
					{
						if (tostr)
						{
							*first = s->val;
							p = first + 1;
						othw
							first += sdisplay(first, "%ld", s->val);
							p = first;
						}
					}
				}
			}
		}

		if (sk() ne '+')
			break;
		skc();
	}

	*p = 0;

/*	display("fstr: '%s'\n", start);
*/
	if (lval and is_ide(start))
		return find_sym(start, outer_sym);

	return nil;
}

global
void nstr(char *w)	/* give rest of line */
{
	int i,c;
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

static
SYMBOL *symbol_table = nil;

SYMBOL *new_sym(char *name, int atype, MODE mode, char *s, long v)
{
	SYMBOL *new = nil;
	char *vs, *n = xmalloc(strlen(name) + 1, 201);

	if (n)
	{
		strcpy(n, name);
		new = xcalloc(1, sizeof(*new), 202);
		if (new)
		{
			new->assigntype = atype;
			new->name = n;
			if (mode ne String)
			{
				new->val = v;
				new->mode = mode;
			othw
				vs = xmalloc(strlen(s) + 1, 203);
				if (vs)
				{
					new->s = vs;
					new->mode = mode;
					strcpy(vs, s);
				othw
					free(n);
					return nil;
				}
			}
			new->next = symbol_table;
			symbol_table = new;
		}
	}
	return new;
}

void free_sym(void)
{
	SYMBOL *t = symbol_table;
	while(t)
	{
		SYMBOL *next = t->next;
		if (t->name)
			free(t->name);
		if (t->s)
			free(t->s);
		free(t);
		t = next;
	}
}

void list_sym(void)
{
	SYMBOL *t = symbol_table;
	while (t)
	{
		display("ty=%d, ide='%s' s='%s', %ld\n",
		           t->mode, t->name, t->s ? t->s : "", t->val);
		t = t->next;
	}
}

SYMBOL *find_sym(char *name, GetSym *outer_sym)
{
	SYMBOL *t = symbol_table;
	while (t)
	{
/*		display("'%s' :: '%s'\n", t->name, name);
*/		if (strcmp(t->name, name) == 0)
			break;
		t = t->next;
	}
	
	if (outer_sym and t == nil)
	{
		t = outer_sym(name);
	}
	return t;
}

int assign(void)
{
	char *p = ipff_getp();
	int c = sk();
	if (c eq 'i')
	{
		if (sk1() eq 's' and sk1() eq ' ')
			return 0;		/* constant */
	}
	elif (c eq ':')
	{
		if (sk1() eq '=')
			return 1;
	}
	ipff_putp(p);
	return -1;
}
