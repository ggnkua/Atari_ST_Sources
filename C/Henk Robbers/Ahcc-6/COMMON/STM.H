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

/*   SToreManager definities   */

#ifndef STM_H
#define STM_H

typedef enum { CURR,FIRST,NEXT,LAST,PRIOR } STMACC;
typedef enum { SERIAL,CYCLIC } STMFMODE;

typedef long STMNR;

typedef struct
{
	STMNR	nr;		/* sequence number (allways first) */
	char	*text;	/* data pointer    (allways second) */
	STMNR	un,		/* old sequence number at UNDO point */
			l;		/* length of info excl terminators */
	uchar   ty,		/* type of data in s->user (not used yet) */
			rem,	/* remainder of cell left for ch insertion */
			flags;	/* misc flags pe, is_modified */
} XSTM;

typedef struct
{
	STMNR	nr;			/* sequence number (allways first) */
	void *	data;		/* data pointer    (allways second) */
} WSTM;

typedef struct stmcell
{
	struct stmcell *nx;
	struct stmcell *pr;
	union
	{
		XSTM	txt;
		WSTM    winfo;
	} user;
} STMC;

typedef struct stbase
{
	STMC *c;
	STMC *f;
	STMC *l;
	STMC *n;
	STMC *p;
	STMNR size;
	short chunks;
} STBASE;

typedef struct stmdef
{
	STBASE us;
	STBASE *fr;
	STMNR chunksize;
	STMFMODE
	    cyclic;
	Cstr name;
} STMDEF;

extern STMDEF *stmdefs[];

STBASE *stminit (STMDEF *d,STBASE *freebase,STMFMODE cyclic,STMNR usersize,STMNR c_s, Cstr name);

STMC *stmficur  (STMDEF *d);
STMNR stmrenum  (STMDEF *d,STMNR *num);
STMC *stmfinum  (STMDEF *d,STMNR zoek);
STMC *stmfi_un  (STMDEF *d,STMNR zoek);
STMC *stmfifirst(STMDEF *d);
STMC *stmfilast (STMDEF *d);
STMC *stmfinext (STMDEF *d);
STMC *stmfiprior(STMDEF *d);
STMC *stmdelcur (STMDEF *d);

STMC *stmfind   (STMDEF *d,STMACC acc,STMFMODE cyclic);
void  stmdelete (STMDEF *d,STMACC acc,STMFMODE cyclic);
STMC *stminsert (STMDEF *d,STMACC acc);
STMC *stmmove	(STMDEF *to, STMDEF *from,STMACC acc);
void  stmfreeall(void);
STMC *stmakecur (STMDEF *d,STMC *c);
void  stmclear  (STMDEF *d);

#define stmcur(d) ((d).us.c)
#define stmlast(d) ((d).us.l)
#define stmfirst(d) ((d).us.f)
#define stmnext(d) ((d).us.n)
#define stmprior(d) ((d).us.p)
#define stmget(d,acc) ((d).us.acc)

#define xn  user.txt.nr
#define xun user.txt.un
#define xty user.txt.ty
#define x_l user.txt.l
#define xrm user.txt.rem
#define xfg user.txt.flags
#define xtx user.txt.text
#define wit user.winfo.data


#endif