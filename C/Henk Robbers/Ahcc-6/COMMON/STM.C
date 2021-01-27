/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
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

/*   SToreManager library functions  */

#include <stdlib.h>
#include "aaaa_lib.h"
#include "hierarch.h"
#include "aaaa_ini.h"

#include "mallocs.h"
#include "ahcm.h"
#include "aaaa_win.h"			/* VOOR ahcc_stm & windows.h */
#include "stm.h"
#include "windows.h"

#define FREES 16		/* 1 for each possible window */

/* primitieve functies: */
STMC *allocfr(STMDEF *d,STBASE *fr,STMNR usersize,STMNR c_s);
STMC *get    (STBASE *b,STMACC acc,STMFMODE cyclic);
void  put    (STBASE *b,STMC *i,STMACC acc,STMFMODE cyclic);
short rem    (STBASE *b);
void  next   (STBASE *b);
void  prior  (STBASE *b);

#define nxpr(b,cu) cu=b->c;b->n=cu->nx;b->p=cu->pr

static
STBASE fbases[FREES], *frees[FREES]={0};

global
void stmfreeall(void)
{
	short i;
	XA_free_all(nil, AH_STM, -1);
	loop(i,FREES) frees[i] = nil;
}


/* You can have FREES different user cell length's initially allocated in
	up to FREES free bases that can be shared by any number of STMDEF bases
*/
global
STBASE *stminit(STMDEF *d,STBASE *freebase,STMFMODE cyclic,STMNR usersize,STMNR c_s, Cstr name)
{
	short i;

	loop(i,FREES)
		if (frees[i] eq nil or freebase eq frees[i])
			break;

	if ( i eq FREES )
		return nil;		/* New freebase and all possible FREES free bases occupied */

	d->us.c = 0;				/* empty */
	d->us.f = 0;
	d->us.l = 0;
	d->us.n = 0;
	d->us.p = 0;
	d->chunksize  = c_s;
	d->name       = name;		/* 05'13 for convenience */
	d->cyclic     = cyclic;

	if (!freebase)		/* default: give one */
		freebase=&fbases[i];

	if ( frees[i] eq 0 )		/* New freebase and room for */
	{
		frees[i]    = freebase;		/* Allocate free array's cells base */
		freebase->c = 0;
		freebase->f = 0;
		freebase->l = 0;
		freebase->n = 0;
		freebase->p = 0;
		freebase->chunks = 0;
		freebase->size = usersize;
		d->us.size = usersize;
		d->fr = freebase;

		return freebase;		/* return freebase for sharing */

	othw
		d->fr = freebase;			/* Share existing free base with new STBASE */
		d->us.size = d->fr->size;
		return freebase;
	}
}

/* Allocate a chain of c_s free cells */
static
STMC *allocfr(STMDEF *d, STBASE *fr, STMNR usersize, STMNR c_s)
{
	STMC *s;
	char *u;
	long i;
	STMNR nal = c_s*(sizeof(STMC) + usersize);

	if ( ( s = xmalloc(nal, AH_STM) ) eq 0 )
		return nil;

	fr->c = 0;
	fr->f = s;
	fr->l = &s[c_s-1];
	fr->n = s;
	fr->p = fr->l;
	fr->size = usersize;

	fr->chunks += 1;
	u = (char *)s;		/* furnish free base and cell's */

/* First a row of STMC structs, followed by a row of areas of size usersize */
	u+=c_s*sizeof(STMC);
	for (i=0; i<c_s; i++)
		s[i].xtx = (long)usersize ? (u+(i*usersize)) : nil;

	s[    0].pr=&s[c_s-1];		/* first->prior = last ?, yes, free chain is cyclic */
	s[c_s-1].nx=&s[    0];		/* last->next = first */

	for (i=1; i<c_s; i++)
		s[i  ].pr = &s[i-1],
		s[i-1].nx = &s[i  ];

	return s;
}

global
STMC *stmakecur(STMDEF *d,STMC *c)
{
	STBASE *b=&d->us;
	STMC *r,*mc=b->c;

	if (!c)
		return stmfifirst(d);

	while (b->c ne c)
	{
		if (!b->n)
			return nil;
		b->c=b->n;
		r=b->c;
		b->n=r->nx;
		b->p=r->pr;
		if (r eq mc)
			return nil;	/* roundabout: c not an address of a used cell */
	}
	return c;
}

global
STMC *stmfind(STMDEF *d,STMACC acc,STMFMODE cycl)		/* makes current */
{
	return get(&d->us,acc,cycl);
}

global
STMC *stmdelcur(STMDEF *d)
{
	STMC *r=d->us.c;
	if (r)
	{
		rem(&d->us);
		put(d->fr,r,LAST,CYCLIC);
	}
	return d->us.c;
}

global
void stmdelete(STMDEF *d,STMACC acc,STMFMODE cyclic)
{
	STMC *r;

	if ( ( r=get(&d->us,acc,cyclic) ) ne 0 )
	{
		rem(&d->us);
		put(d->fr,r,LAST,CYCLIC);
	}
}

global
STMC *stminsert(STMDEF *d, STMACC acc)
{
	STBASE *free = d->fr;
										/* free allways cyclic */
	if (free->l eq nil)						/* no last: then empty */
		if (allocfr(d,free, d->us.size, d->chunksize) eq 0)	/* try to get new */
			return nil;

	free->c=free->f;			/* find first */

	{
		STMC *r=free->c;
		if (r)
		{
			free->n=r->nx;
			free->p=r->pr;

			rem(free);
			put(&d->us,r,acc,d->cyclic);
		}
		return r;
	}
}

/* move cell from one chain to another without free chain intervention */
global
STMC *stmmove(STMDEF *to, STMDEF *from,STMACC acc)
{
	STMC *r=nil;
	if ( to->fr eq from->fr )	/* must share the same freebase */
	{
		r=from->us.c;
		if (r)
		{
			rem(&from->us);
			put(&to  ->us,r,acc,to->cyclic);
		}
	}
	return r;
}

global
void stmclear(STMDEF *d)
{
	STMC *r;
	STBASE *b=&d->us;

	stmfifirst(d);
	while(b->c)
	{
		r=b->c;
		rem(b);
		put(d->fr,r,LAST,CYCLIC);
		next(b);
	}
}

global
STMC *stmficur(STMDEF *d)
{
	return d->us.c;
}

global
STMNR  stmrenum(STMDEF *d,STMNR *num)		/* does NOT affect currencies */
{
	STMNR i=0, t=0;
	STMC *cu,
	     *f = d->us.f;

	if ( (cu=f) ne 0)			/* find first */
	{
		if (!d->cyclic) f=nil;
		do
		{
			i++;
			cu->xn=i;
			t+=cu->x_l;
		}
		while ( (cu=cu->nx) ne f);	/* fast */
	}
	if (num)
		*num = i;
	return t;		/* total bytes for avarage */
}

global
STMC *stmfinum(STMDEF *d, STMNR z)		/* fast find number */
{
	STBASE *b = &d->us;
	STMC *cu=b->c,
		 *f=b->f,
		 *l=b->l;

	if (!f or !l)
		return nil;			/* empty chain */

	if (!cu)
		cu=b->n;

	if (!d->cyclic)			/* for detecting end */
	{
		if (!cu)
			cu=l;
		f=nil;
		l=nil;
	}

	if (cu)
	{	if (z ne cu->xn)
			if (z < cu->xn)
				while ( cu->xn > z) /* search priors */
				{	cu=cu->pr;
					if ( cu eq l)
					{	cu=b->f;
						break;
				}	}
			else
				while ( cu->xn < z ) /* search nexts */
				{	cu=cu->nx;
					if (cu eq f)
					{	cu=b->l;
						break;
				}	}
		b->c=cu;
		b->n=cu->nx;
		b->p=cu->pr;
	}
	return cu;
}

global
STMC *stmfi_un(STMDEF *d, STMNR z)		/* fast find undo num */
{
	STBASE *b = &d->us;
	STMC *cu=b->c,
		 *f=b->f,
		 *l=b->l;

	if (!f or !l)
		return nil;			/* empty chain */

	if (!cu)
		cu=b->n;

	if (!d->cyclic)			/* for detecting end */
	{
		if (!cu)
			cu=l;
		f=nil;
		l=nil;
	}

	if (cu)
	{	if (z ne cu->xun)
			if (z < cu->xun)
				while ( cu->xun > z) /* search priors */
				{	cu=cu->pr;
					if ( cu eq l)
					{	cu=b->f;
						break;
				}	}
			else
				while ( cu->xun < z ) /* search nexts */
				{	cu=cu->nx;
					if (cu eq f)
					{	cu=b->l;
						break;
				}	}
		b->c=cu;
		b->n=cu->nx;
		b->p=cu->pr;
	}
	return cu;
}

global
STMC *stmfifirst(STMDEF *d)
{
	STBASE *b = &d->us;
	STMC *cu;
	if (b->f eq 0 ) return 0;
	b->c=b->f;
	nxpr(b,cu);
	return cu;
}

global
STMC *stmfilast(STMDEF *d)
{
	STBASE *b = &d->us;
	STMC *cu;
	if (b->l eq 0 ) return 0;
	b->c=b->l;
	nxpr(b,cu);
	return cu;
}

global
STMC *stmfinext(STMDEF *d)			/* SERIAL */
{
	STBASE *b = &d->us;
	STMC *cu;
	if (d->cyclic and b->n eq b->f)	return 0;
	if (              b->n eq 0   )	return 0;
	b->c=b->n;
	nxpr(b,cu);
	return cu;
}

global
STMC *stmfiprior(STMDEF *d)			/* SERIAL */
{
	STBASE *b = &d->us;
	STMC *cu;
	if (d->cyclic and b->p eq b->l)	return 0;
	if (              b->p eq 0   )	return 0;
	b->c=b->p;
	nxpr(b,cu);
	return cu;
}

/* Internal function: so cyclic need not checked.
(It does NOT come from outside)
basic get: also used for free chain              */
static
STMC *get(STBASE *b,STMACC acc,STMFMODE cyclic)
{										/* makes current */
	if ( b->f eq 0 and b->l eq 0 )		/* empty         */
		return nil;
	switch (acc)
	{
		case CURR:
			return b->c;
		case FIRST:
			b->c=b->f;
		break;
		case NEXT:
			if ( !cyclic and b->n eq b->f)		/* serial access and cyclic storage */
				return nil;
			b->c=b->n;
		break;
		case LAST:
			b->c=b->l;
		break;
		case PRIOR:
			if ( !cyclic and b->p eq b->l)		/* serial access and cyclic storage */
				return nil;
			b->c=b->p;
		break;
		default:
			return nil;
	}
	b->n=b->c->nx;
	b->p=b->c->pr;
	return b->c;
}

/* Internal function: so cyclic need not checked.
(It does NOT come from outside);
basic put: also used for free chain					*/
static
void put(STBASE *b,STMC *i,STMACC acc,STMFMODE cyclic)
{
	bool empty = b->f eq 0 and b->l eq 0;
	if (cyclic)
	{
		if (empty)
		{
			b->f =i;
			b->l =i;
			b->n =i;
			b->p =i;
			b->c =i;
			i->nx=i;
			i->pr=i;
		othw
			if ( acc eq FIRST or acc eq LAST )
			{
				b->f->pr=i;
				b->l->nx=i;
				i->pr   =b->l;
				i->nx   =b->f;
				b->n    =b->f;
				b->p    =b->l;
				if ( acc eq FIRST)
					b->f=i;
				else
					b->l=i;
			othw
				if ( acc eq NEXT )
				{
					i->nx   =b->n;
					b->n->pr=i;
					if (b->c ne 0)
					{
						i->pr   =b->c;
						b->c->nx=i;
						b->p    =b->c;
						if ( b->l eq b->c ) b->l=i;
					othw
						i->pr   =b->p;
						b->p->nx=i;
						if ( b->l eq b->f ) b->l=i;
					}
				othw		/* PRIOR */
					i->pr   =b->p;
					b->p->nx=i;
					if ( b->c ne 0 )
					{
						i->nx   =b->c;
						b->c->pr=i;
						b->n    =b->c;
						if ( b->f eq b->c ) b->f=i;
					othw
						i->nx   =b->n;
						b->n->pr=i;
						if ( b->f eq b->l ) b->f=i;
					}
				}
			}
		}
	othw
	/* SERIAL: next = 0 if last cq prior = 0 if first */
		if (empty)
		{
			b->l =i;
			b->f =i;
			b->c =i;
			i->nx=0;
			i->pr=0;
			b->n =0;
			b->p =0;
		othw

			if (acc eq NEXT and b->n eq 0)
				acc = LAST;
			if (acc eq PRIOR and b->p eq 0)
				acc = FIRST;

			switch (acc)
			{
			case FIRST:
				b->f->pr=i;
				i->pr   =0;
				i->nx   =b->f;
				b->n    =b->f;
				b->p    =0;
				b->f=i;
			break;
			case LAST:
				b->l->nx=i;
				i->pr   =b->l;
				i->nx   =0;
				b->n    =0;
				b->p    =b->l;
				b->l=i;
			break;
			case NEXT:
				i->nx   =b->n;
				b->n->pr=i;		/* !b->n: acc changed to LAST */
				if (b->c)
				{
					i->pr   =b->c;
					b->c->nx=i;
					b->p    =b->c;
				othw
					i->pr   =b->p;
					if (b->p)
						b->p->nx=i;
					else
						b->f=i;
				}
			break;
			case PRIOR:
				i->pr   =b->p;
				b->p->nx=i;		/* !b->p: acc changed to FIRST */
				if (b->c)
				{
					i->nx   =b->c;
					b->c->pr=i;
					b->n    =b->c;
				othw
					i->nx   =b->n;
					if (b->n)
						b->n->pr=i;
					else
						b->l=i;
				}
			break;
			}
		}
	}
	b->c=i;
}

/* basic remove (also used for free chains */
static
short rem(STBASE *b)
{
	STMC *cu=b->c;

	if ( cu eq 0 ) return false;	/* mostly checked beforehand */

	if (b->f eq b->l)		/* just 1 left */
	{
		b->p=0;				/* make empty  */
		b->n=0;
		b->l=0;
		b->f=0;
	othw
		if (cu->nx)
			cu->nx->pr=cu->pr;
		if (cu->pr)
			cu->pr->nx=cu->nx;
		if ( cu eq b->l ) b->l=b->p;
		if ( cu eq b->f ) b->f=b->n;
	}
	b->c=0;
	return true;
}

static
void next(STBASE *b)
{
	STMC *cu;
	if ( (b->c=b->n) ne nil)
		nxpr(b,cu);
}

static
void prior(STBASE *b)
{
	STMC *cu;
	if ( (b->c=b->p) ne nil)
		nxpr(b,cu);
}

