/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
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

/*
 *	nodes.c
 *
 *	Node allocation, deallocation, searching
 *	and other node handling
 */

#define PROCESS_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <ctype.h>

#include "common/mallocs.h"
#include "common/amem.h"
#include "common/dict.h"
#include "common/pdb.h"
#include "param.h"
#include "tok.h"
#include "d2.h"

#define debugL (G.xflags['l'-'a'])
#define debugU (G.xflags['u'-'a'])

#define CHKFREE 0		/* set independent from C_DEBUG: check 'freeing free/bas node' */
#define CHKNODE 0		/* set independent from C_DEBUG: check node type */

#if 0
#define TURN 58
static short blad = 0;
global
void next_blad(void)
{
	if (blad++ eq TURN) console("?\n"), Cconin(), blad = 0;
}
#endif

global
void c_mods(void *to, void *fro)
{
	NP np = to, tp = fro;

	np->xflgs.f.pasc |= tp->xflgs.f.pasc;
	np->xflgs.f.cdec |= tp->xflgs.f.cdec;
}

global
short nodesmade = 0, nodesavail = 0;

#define zeroize(xp) *((long*)xp)++ = 0

#include "zernodes.h"

NODESPACE initspace[XXr] =
{
	{sizeof(XNODE), 100, true, 3, 2, zerXnode, "Preprocessor"},
	{sizeof(TNODE), 200, true, 3, 2, zerTnode, "Typelist    "},
	{sizeof( NODE),  75, true, 3, 2, zerEnode, "Expression  "},
	{sizeof(VNODE),  25, true, 3, 2, zerVnode, "Various     "},
	{sizeof(INODE), 100, true, 3, 2, zerInode, "Instruction "},
	{sizeof(BNODE),  25, true, 3, 2, zerBnode, "Block       "}
};

NODESPACE xspace[XXr];

#define BLKMAX (32768-blockprefix-unitprefix)

#if NODESTATS
void nodecnts(void)
{
	console("\nxnodes copied: %ld\n\n", G.xcopied);
	console("usage:\n");
	console("STNODES: %ld\n", G.ncnt[STNODE]);
	console("DFNODES: %ld\n", G.ncnt[DFNODE]);
	console("TLNODES: %ld\n", G.ncnt[TLNODE]);
	console("EXNODES: %ld\n", G.ncnt[EXNODE]);
	console("GENODES: %ld\n", G.ncnt[GENODE]);
	console("BLNODES: %ld\n", G.ncnt[BLNODE]);
	console("FLNODES: %ld\n", G.ncnt[FLNODE]);
	console("CSNODES: %ld\n", G.ncnt[CSNODE]);
	console("TPNODES: %ld\n", G.ncnt[TPNODE]);
	console("PRNODES: %ld\n", G.ncnt[PRNODE]);
	console("RLNODES: %ld\n", G.ncnt[RLNODE]);
	console("LLNODES: %ld\n", G.ncnt[LLNODE]);
	console("LBNODES: %ld\n", G.ncnt[LBNODE]);
	console("IFNODES: %ld\n", G.ncnt[IFNODE]);
	console("INNODES: %ld\n", G.ncnt[INNODE]);
	console("BKNODES: %ld\n", G.ncnt[BKNODE]);

	console("        -----\n");
	console("NODES  : %ld\n\n",
	         G.ncnt[0]
	        +G.ncnt[STNODE]
	        +G.ncnt[EXNODE]
			+G.ncnt[GENODE]+G.ncnt[LBNODE]
			+G.ncnt[BLNODE]+G.ncnt[FLNODE]
			+G.ncnt[CSNODE]+G.ncnt[TPNODE]
			+G.ncnt[PRNODE]+G.ncnt[RLNODE]+G.ncnt[LLNODE]
			+G.ncnt[IFNODE]+G.ncnt[INNODE]+G.ncnt[BKNODE]);
	console("match   ops: %ld\n", G.operators);
	console("id's       : %ld\n", dictionary_names);
	console("heap names : %ld\n", heap_names);
	console("symbols    : %ld\n", G.symbols);
	console("defines    : %ld\n", G.defs);
	console("strcode    : %ld\n", G.strcode);
	console("npcode     : %ld\n", G.npcode);
}
#endif

global
void may_nct(TP tp)
{
	if (tp->type)
		if (tp->type->tflgs.f.tm eq 0) /* AFLAGS */
			type_is_not_a_copy(tp);
}

/* for declarations only */
global
void d_to_dt(TP dt, TP d)		/* declaror to declarator */
{
	dt->type = d;

	if (d)
	{
#if FOR_A
		if (G.lang eq 'a')
			switch(d->token)	/* type_maker types */
			{
				case REFTO:
				case ROW:
				case T_PROC:
				return;
			}
#endif
		if (d->cflgs.f.q)
			return;
	}

	type_is_not_a_copy(dt);
}


global
void d_to_dt_C(TP dt, TP d)
{
	dt->type = d;

	if (d and d->cflgs.f.q eq 0)
		type_is_not_a_copy(dt);
}


global
void pick_qual(TP tp, short q)
{
	if (q)
	{
		tp->cflgs.f.qc = (q&CONST) ne 0;
		tp->cflgs.f.qv = (q&VOLAT) ne 0;
	}
}

global
short hash(Cstr key)
{
	Cstr s = key;
	short k = 0;

	while (*s)
		k = (((k << 1) + (k >> 14)) ^ (*s++)) & 0x3fff;

	return k % NHASH;
}

static
Cstr p_fl(void *vp)
{
	NP np = vp;
	static char s[256];
	if (np)
	{
		sprintf(s, "Found in %s L%ld", pdb_file_by_number(auto_dependencies, np->fl.n), np->fl.ln);
		return s;
	}
	return "Fn '~'";
}

#if DBGFR
static
bool bas_or_free_X(TP np)
{
	if (np->nflgs.f.free)
		pnode_1(np, "freeing free", 0), console("%s \n\n", p_fl(np));
	return np->nflgs.f.res ne 0 or np->nflgs.f.free ne 0;
}
#else
#define bas_or_free_X bas_or_free
#endif

static
bool bas_or_free(void *vp)
{
	NP np = vp;
	return np->nflgs.f.res ne 0 or np->nflgs.f.free ne 0;
}

global
void free_name(void *vp)			/* already made secure */
{
	NP np = vp;
	if (np->nflgs.f.nheap)
	{
		CC_xfree(np->name);
		np->name = "__freed__";
		np->nflgs.f.nheap = 0;
	}
}

global
void name_to_str(void *vp, Cstr s)
{
	NP np = vp;

	free_name(np);
	np->name = s;
}

static
void *noderow(NODESPACE *sp, void *np, short i)
{
	size_t s = sp->nodesize;
	char *xp = np;
	do
	{
		xp += s;					/* first node is used for space chain */
		((XP)xp)->nflgs.f.free = 1;
		(char *)(((XP)xp)->next) = xp+s;
	} while (--i);
	((XP)xp)->next = nil;
	return (char *)np+s;
}

VpI		waitexit;

static
void new_space(NODESPACE *sp, short ty)
{
	XP np;
	long size = sp->start;

#if C_DEBUG
	np = NS_xcalloc(1, size * sp->nodesize, AH_TEST_SPACE + ty, CC_ranout);
#else
	np = NS_xmalloc(   size * sp->nodesize, AH_TEST_SPACE + ty, CC_ranout);
#endif
	if (np)
	{
		np->val.i = size;

#if NODESTATS
		if (G.al_list_stats)
			console("new %s node space(%ld): %ldK\n", sp->name, sp->nodesize, (size*sp->nodesize+512)/1024);
#endif
		sp->start = sp->exponential ? (size*sp->tel)/sp->noem : size;
		if (sp->start*sp->nodesize >= BLKMAX)
			sp->start = BLKMAX/sp->nodesize;
		sp->made += size-1;
		sp->avail += size-1;
		np->next  = sp->space;		/* chain allocated blocks for later free() */
		sp->space = np;
		sp->list  = noderow(sp, np, size-1);
	}
}

#if C_DEBUG
static
bool wun(NP np, short ty, char *t1, char *t2, char *t3)
{
	/*             t1 t2tyt3    ptok   pntype np  */
	warnn(np, "CW: %s%c%s() on %s node '%s' %s%lx",
	               t1, ty, t2, t3, ptok(np->token), pntype(np->nt), np);
	return true;
}

static
bool check_node(void *vp, NODESPACE *sp, short ty)
{
	NP np = vp;
	long size;
	XP xp = sp->space;
	char *this = vp;
	VP my = vp;
	if (np->nflgs.f.res)
		return wun(np, ty, "free", "unit", "resident");
	if (np->nflgs.f.free)
		return wun(np, ty, "free", "unit", "free");
	while (xp)
	{
		char *check = (char *)xp;
		size = xp->val.i * sp->nodesize;
		if (this >= check and (this + sp->nodesize <= check + size))
			return false;	/* OK, node is in list */
		xp = xp->next;
	}
	message(0,0,"OE: '%s' %lx Node not in list %c", my->name ? my->name : "~~~", my->name, ty);
	return true;			/* error */
}

static
bool check_free(void *vp, short ty,
		short t1, short t2, short t3, short t4, short t5, short t6, short t7, short t8)
{
	NP np = vp;
	if (np->nflgs.f.res)
		return wun(np, ty, "free", "node", "resident");
	if (np->nflgs.f.free)
	{
#if BIP_CC
		warn("CW: freeing free %cnode, %lx %s", ty, np, ptok(np->token), p_fl(np));
#else
		warn("CW: freeing free %cnode, %lx %s fileno %d line %ld", ty,
			np, ptok(np->token), np->fl.n, np->fl.ln);
#endif
		if (    np->nt ne t1 and np->nt ne t2 and np->nt ne t3 and np->nt ne t4
		    and np->nt ne t5 and np->nt ne t6 and np->nt ne t7 and np->nt ne t8)
			warn("CE: no %cnode: node type: '%s'", ty, pntype(np->nt));
		return true;
	}
	if (    np->nt ne t1 and np->nt ne t2 and np->nt ne t3 and np->nt ne t4
	    and np->nt ne t5 and np->nt ne t6 and np->nt ne t7 and np->nt ne t8)
	{
#if BIP_CC
		warn("CW: free%cnode on no %cnode [%s]%d %s, %s", ty, ty,
			pntype(np->nt), np->nt, ptok(np->token), p_fl(np));
#else
		warn("CW: free%cnode on no %cnode [%s]%d %s, fileno %d line %ld", ty, ty,
			pntype(np->nt), np->nt, ptok(np->token), np->fl.n, np->fl.ln);
#endif
		if (np->token eq ID)	console("\t\t%s\n", np->name);
		return true;
	}

	return false;
}
#else
static
bool check_node(void *vp, NODESPACE *sp, short ty)
{
	if (bas_or_free(vp))
		return true;
	return false;
}

static
bool check_free(void *vp, short ty,
		short t1, short t2, short t3, short t4, short t5, short t6, short t7, short t8)
{
	NP np = vp;
	if (bas_or_free(np)) return true;
	if (    np->nt ne t1 and np->nt ne t2 and np->nt ne t3 and np->nt ne t4
	    and np->nt ne t5 and np->nt ne t6 and np->nt ne t7 and np->nt ne t8)
		return true;
	return false;
}
#endif

global
XP allocXn(bool clr)
{
	NODESPACE *sp = &xspace[XNr];
	XP np;

	if (!sp->list)
		new_space(sp, XNr);
	np = sp->list;			/* The allocation proper */
	sp->list = np->next;
	if (clr)
		(*sp->zer)(np);
	np->nt = STNODE;

	sp->avail--;
#if NODESTATS
	G.ncnt[STNODE]++;
#endif

	set_line_no(np);
	return np;
}

global
void freeXunit(XP np)
{
	NODESPACE *sp = &xspace[XNr];
#if CHKNODE
	if (check_node(np, sp, 'X'))
		return;
#elif CHKFREE
	if (bas_or_free(np))
		return;
#endif
	free_name(np);
	np->nflgs.f.free = 1;
	np->nt = 0;
	np->next = sp->list;
	sp->list = np;
	sp->avail++;
}

global
void freeVunit(VP np)
{
	NODESPACE *sp = &xspace[VNr];
#if CHKNODE
	if (check_node(np, sp, 'V'))
		return;
#elif CHKFREE
	if (bas_or_free(np))
		return;
#endif
	free_name(np);
	np->nflgs.f.free = 1;
	np->next = sp->list;
	sp->list = np;
#if NODESTATS
	sp->avail++;
#endif
}

global
void freeXn(XP np)
{
	while (np)
	{
		XP nxt;
#if CHKFREE
		if (check_free(np, 'X', STNODE, DFNODE, DFNODE, DFNODE, DFNODE, DFNODE, DFNODE, DFNODE))
			return;
#endif
		nxt = np->next;
		if (np->down)
			freeXn(np->down);
		if (np->tseq and !np->nflgs.f.n_ct)
			freeXn(np->tseq);
#if FLOAT
		if (np->token eq RCON)
			freeVunit(np->val.dbl);
#endif
#if LL
		if (np->token eq LCON)
			freeVunit(np->val.dbl);
#endif
		freeXunit(np);
		np = nxt;		/* every subnode recursive except left */
	}
}

static
void generic_copyone(void *ng)
{
	AP np = ng;

	set_line_no(np);
#if NODESTATS
	G.ncnt[0]--;
	G.ncnt[np->nt]++;
#endif
	np->right = nil;
	np->left = nil;
	if (np->nt ne GENODE and np->var.info)
		to_nct(np);
	np->nflgs.f.nheap = 0;
}

global
VP copyVone(VP op)
{
	VP np;

	if (op eq nil) return nil;
	np = allocVn(-1);
	*np = *op;
	generic_copyone(np);
	return np;
}

global
XP copyXone(XP np)
{
	XP nx = allocXn(0);		/* no clear */
	*nx = *np;
	nx->nflgs.f.nheap = 0;
	nx->down = nil; 	/* break down links */
#if FLOAT
	if (np->token eq RCON)
		nx->val.dbl = copyVone(np->val.dbl);
#endif
#if LL
	if (np->token eq LCON)
		nx->val.dbl = copyVone(np->val.dbl);
#endif
	set_line_no(nx);

	return nx;
}


global
TP allocTn(bool clr)
{
	NODESPACE *sp = &xspace[TLr];
	TP np;

	if (!sp->list)
		new_space(sp, TLr);
	np = sp->list;			/* The allocation proper */
	sp->list = np->next;
	if (clr)
		(*sp->zer)(np);
	np->nt = TLNODE;
	np->rno = -1;

	sp->avail--;
#if NODESTATS
	G.ncnt[TLNODE]++;
#endif
	set_line_no(np);
	return np;
}

global
void freeTunit(TP np)
{

	NODESPACE *sp = &xspace[TLr];
#if CHKNODE
	if (check_node(np, sp, 'T'))
		return;
#elif CHKFREE
	if (bas_or_free(np))
		return;

#endif
	free_name(np);
	np->nflgs.f.free = 1;
	np->next = sp->list;
	sp->list = np;
	sp->avail++;
}

global
void freeTn(TP np)
{
	while (np)
	{
		TP nxt;
		if (bas_or_free_X(np)) return;
#if CHKFREE
		if (check_free(np, 'T', TLNODE, TLNODE, TLNODE, TLNODE, TLNODE, TLNODE, TLNODE, TLNODE))
			return;
#endif
		nxt = np->next;
		if (np->list)
			freeTn(np->list);
		if (np->type and is_ct(np))
			freeTn(np->type);
		freeTunit(np);
		np = nxt;		/* every subnode recursive except left */
	}
}

global
BP allocBn(void)
{
	NODESPACE *sp = &xspace[BKr];
	BP np;

	if (!sp->list)
		new_space(sp, BKr);
	np = sp->list;			/* The allocation proper */
	sp->list = np->next;
	(*sp->zer)(np);
	np->nt = BKNODE;

	sp->avail--;
#if NODESTATS
	G.ncnt[BKNODE]++;
#endif
	return np;
}

global
void freeBunit(BP np)
{
	NODESPACE *sp = &xspace[BKr];
#if CHKNODE
	if (check_node(np, sp, 'B'))
		return;
#elif CHKFREE
	if (bas_or_free(np))
		return;
#endif
	free_name(np);
	np->nflgs.f.free = 1;
	np->next = sp->list;
	sp->list = np;
	sp->avail++;
}

global
void freeBn(BP np)
{
	while (np)
	{
		BP nxt;
#if CHKFREE
		if (check_free(np, 'B', BLNODE, BLNODE, BLNODE, BLNODE, BLNODE, BLNODE, BLNODE, BLNODE))
			return;
#endif
		nxt = np->next;
		if (np->chain)
			freeBn(np->chain);
		if (np->symbol and !np->nflgs.f.n_ct)
			freeBn(np->symbol);
		freeBunit(np);
		np = nxt;		/* every subnode recursive except left */
	}
}

global
IP allocIn(void)
{
	NODESPACE *sp = &xspace[INr];
	IP np;

	if (!sp->list)
		new_space(sp, INr);	/* N.B !! INr only used in console msg */
	np = sp->list;			/* The allocation proper */
	sp->list = np->next;
	(*sp->zer)(np);
	np->nt = INNODE;		/* 03'11 HR: back in again; needed for debugging */

	sp->avail--;
#if NODESTATS
	G.ncnt[INNODE]++;
#endif

#if C_DEBUG
	np->name = "no name";
#endif
	return np;
}

global
void freeIunit(IP np)
{
	NODESPACE *sp = &xspace[INr];
#if CHKNODE
	if (check_node(np, sp, 'I'))
		return;
#elif CHKFREE
	if (bas_or_free(np))
		return;
#endif
	free_name(np);
	np->arg = nil;
	np->nflgs.f.free = 1;
	np->next = sp->list;
	sp->list = np;
	sp->avail++;
}

global
void freeIn(IP np)
{
	while (np)
	{
		IP nxt;
#if CHKFREE
		if (check_free(np, 'I', INNODE, INNODE, INNODE, INNODE, INNODE, INNODE, INNODE, INNODE))
			return;
#endif
		nxt = np->next;
#if OPTBUG
		if (np->bugstr)
			CC_xfree(np->bugstr);
#endif
		freeIunit(np);
		np = nxt;		/* every subnode recursive except left */
	}
}

#if LOST_NODES
static
void lost_xnodes(void)
{
	if debugU
	{
		long i;
		NODESPACE *sp = &xspace[XNr];
		XP xp = sp->space;
		while(xp)
		{
			XP nx = xp->next;
			long s = xp->val.i;
			for (i = 1; i<s; i++)
				if (xp[i].nflgs.f.free eq 0)
				{
					XP np = &xp[i];
					np->down = 0;
					if (np->token eq REFTO and np->next)
						np->next->next = 0;
					else
						np->next = 0;
					np->tseq = 0;
					console("**** lost Xnode %s ****\n", ptok(np->token));
				}
			xp = nx;
		}
	}
}

static
void lost_vnodes(void)
{
	if debugU
	{
		long i;
		NODESPACE *sp = &xspace[VNr];
		VP xp = sp->space;
		while(xp)
		{
			VP nx = xp->next;
			long s = xp->vval;
			for (i = 1; i<s; i++)
				if (xp[i].nflgs.f.free eq 0)
				{
					VP np = &xp[i];
					np->inner = 0;
					if (np->token eq REFTO and np->next)
						np->next->next = 0;
					else
						np->next = 0;
					np->codep = 0;
					console("**** lost Vnode %s ****\n", ptok(np->token));
				}
			xp = nx;
		}
	}
}

static
void lost_tnodes(void)
{
/*	if debugU
*/	{
		long i;
		NODESPACE *sp = &xspace[TLr];
		TP xp = sp->space;
		while(xp)
		{
			TP nx = xp->next;
			long s = xp->offset;
			for (i = 1; i<s; i++)
				if (xp[i].nflgs.f.free eq 0)
				{
					TP np = &xp[i];
					np->list = 0;
					if (np->token eq REFTO and np->next)
						np->next->next = 0;
					else
						np->next = 0;
					np->type = 0;
#if 1
					console("Warning in %s L%ld  lost Tnode %s %lx '%s'\n",
						pdb_file_by_number(auto_dependencies, np->fl.n),
						np->fl.ln,
						ptok(np->token),
						np,
						sss(np->name));
#else
					console("**** lost Tnode %s ****\n", ptok(np->token));
#endif
				}
			xp = nx;
		}
	}
}

static
void lost_nodes(void)
{
	if debugU
	{
		long i;
		NODESPACE *sp = &xspace[EXr];
		NP xp = sp->space;
		while(xp)
		{
			NP nx = xp->left;
			long s = xp->val.i;
			for (i = 1; i<s; i++)
				if (xp[i].nflgs.f.free eq 0)
				{
					NP np = &xp[i];
					np->right = 0;
					if (np->token eq REFTO and np->left)
						np->left->left = 0;
					else
						np->left = 0;
					np->type = 0;
					console("**** lost G/E node %s ****\n", ptok(np->token));
				}
			xp = nx;
		}
	}
}
#endif

global
void freenodespace(short ty)
{
	NODESPACE *sp = &xspace[ty];
#if DBGLN || LOST_NODES || NODESTATS
	short n = sp->made - sp->avail;
#endif
#if  DBGLN
	if (n)
		console("lost %d %s node%s(%ld)!!!\n", n, sp->name, pluralis(abs(n)), sp->nodesize);
#endif

#if LOST_NODES
		if (n > 0)
		{
			if   (ty eq XNr) lost_xnodes();
			elif (ty eq TLr) lost_tnodes();
			elif (ty eq VNr) lost_vnodes();
			elif (ty eq EXr) lost_nodes();
		}
#endif

#if NODESTATS
	if (G.al_list_stats)
		console("%s node space (%ld) = %ldK\n", sp->name,
				sp->nodesize, (((long)sp->avail*sp->nodesize)+1023)/1024);
	if (n)
	{
		if (G.al_list_stats)
			console("made : %d, available: %d\n", sp->made, sp->avail);
	}
#endif

	while(sp->space)
	{
		XP xp = sp->space;
		xp = xp->next;
		NS_xfree(sp->space);
		sp->space = xp;
	}
	sp->list = nil;
}

global
NP allocnode(short nt)
{
	NODESPACE *sp = &xspace[EXr];
	NP np;

	if (!sp->list)
		new_space(sp, EXr);

	np = sp->list;			/* The allocation proper */
	sp->list = np->left;
	if (nt >= 0)			/* -1 if contents are copied anyway */
	{
		(*sp->zer)(np);
		np->nt = nt;
		np->rno = -1;
	}

#if NODESTATS
	sp->avail--;
	if (nt < 0)
		nt = 0;
	G.ncnt[nt]++;
#endif
	set_line_no(np);
	return np;
}

global
TP make_type(short tok1, short tok2, Cstr name, Cstr str)
{
	void to_type(TP, short);
	TP tp = allocTn(1);
	if (tp)
	{
		if (tok1>=0)
			tp->token = tok1;
		if (tok2>=0)
			to_type(tp, tok2);
		if (name)
			tp->name = name;
		if (str)
			name_to_str(tp, str);
	}

	return tp;
}

global
NP make_node(short tok, short tt, long val, Cstr name)
{
	NP np = allocnode(EXNODE);

 	if (np)
	{
		np->token = tok;
		np->tt = tt;
		np->val.i = val;

		if (is_C(tok))
		{
			if (name)
				new_name(np, name);
			else
				name_to_str(np, OP_N(tok));
			kw_tok((XP)np);
		}
		else
		switch (tok)
		{
			case ICON:
			case ZERO:
				if (name)
					new_name(np, name);
				else
					new_name(np, "%ld", val);
			break;

			default:
				if (name)
					new_name(np, name);
		}
	}

	return np;
}

/*
global
NP make_lbin(short tok, Cstr name, NP lp, NP rp)
{
	NP xp = make_node(tok, E_BIN, 0, name);
	if (xp)
	{
		xp->left = lp;
		xp->right = rp;
		xp->type = lp->type;
		to_nct(lp);
	}

	return xp;
}

global
NP make_rbin(short tok, Cstr name, NP lp, NP rp)
{
	NP xp = make_node(tok, E_BIN, 0, name);
	if (xp)
	{
		xp->left = lp;
		xp->right = rp;
		xp->type = rp->type;
		to_nct(rp);
	}

	return xp;
}
*/
global
NP gx_node(void)
{
	NP gp = allocnode(GENODE);
	return gp;
}

global
void freeunit(NP np)
{
	NODESPACE *sp = &xspace[EXr];
#if CHKNODE
	if (check_node(np, sp, ' '))
		return;
#elif CHKFREE
	if (bas_or_free(np))
		return;
#endif
	free_name(np);
	np->nflgs.f.free = 1;
	np->left = sp->list;
	sp->list = np;
#if NODESTATS
	sp->avail++;
#endif
}

global
void new_gp(NP ex, short tok)
{
	gpbase = gp = gx_node();
	gp->token = tok;
	gp->right = ex;
	gp->tt = NO_EV;
}

/*
global
void expr_gp(NP ex, short tok)
{
	gp->left = gx_node();
	gp = gp->left;
	gp->token = tok;
	gp->right = ex;
	gp->tt = NO_EV;
}
*/
global
void next_gp(NP np)
{
	gp->left = np ? np : gx_node();
	gp->tt = E_UNARY;			/* 04'14 v5.1 */
	gp = gp->left;
}

/* 04'14 v5.1 */
global
void prev_gp(NP np)
{
	NP xp = np ? np : gx_node(), prev = nil, last = gpbase;
	if (xp)
	{
		if (last)
			while(last->left)
			{
				prev = last;
				last = last->left;
			}

		if (prev)
			prev->left = xp,
			prev->tt = E_UNARY;
		else
			gpbase = xp;

		xp->left = last;
		if (last)
			xp->tt = E_UNARY;
	}
}

/*
global
void prev_expr_gp(NP np, short tok)
{
	NP fp = gx_node();
	prev_gp(fp);
	fp->right = np;
	fp->token = tok;
	fp->tt = NO_EV;
}
*/

global
void save_name(void *vp, long l, Cstr s)
{
	NP np = vp;

	np->nflgs.f.nheap = 0;

	if (np->token eq ID)
		np->name = to_dictionary(s);
	else
		np->name = to_name_heap(l, s);
}

global
short new_name(void *vp, Cstr text, ... )
{
	NP np = vp;
	char tus[256]; short l;
	va_list argpoint;

	free_name(np);

	va_start(argpoint, text);
	l = vsprintf(tus, text, argpoint);
	va_end(argpoint);

	save_name(np, l, tus);
	return l;
}

global
void freeVn(VP np)
{
	while (np)
	{
		VP nxt;
#if CHKFREE
		if (check_free(np, 'V', FLNODE, CSNODE, TPNODE, PRNODE, RLNODE, LLNODE, IFNODE, LBNODE))
			return;
#endif
		nxt = np->next;
		if (np->inner)
			freeVn(np->inner);
		if (np->codep and !np->nflgs.f.n_ct)
			if (np->nt eq TPNODE)
				freeVn(np->codep);
			else
				freeTn((TP)np->codep);
		if (np->nt eq FLNODE)
			freeVn(np->F.out);
		freeVunit(np);
		np = nxt;		/* every subnode recursive except left */
	}
}

global
void freenode(NP np)
{
	while (np)
	{
		NP nxt;
#if CHKFREE
		if (check_free(np, ' ', EXNODE, GENODE, GENODE, GENODE, GENODE, GENODE, GENODE, GENODE))
			return;
#endif
		nxt = np->left;
		if (np->right)
			freenode(np->right);
		if (np->type and is_ct(np))
			if (np->nt eq GENODE or np->nt eq TPNODE)
				freeVn((VP)np->type);
			else
				freeTn(np->type);
		if (np->nt eq GENODE)
			if (np->betw)
				freeVn(np->betw);
#if FLOAT
		if (np->token eq RCON)
			freeVn(np->val.dbl);
#endif
#if LL
		if (np->token eq LCON)
			freeVn(np->val.dbl);
#endif
		freeunit(np);
		np = nxt;		/* every subnode recursive except left */
	}
}

global
VP allocVn(short nt)
{
	NODESPACE *sp = &xspace[VNr];
	VP np;

	if (!sp->list)
		new_space(sp, VNr);

	np = sp->list;			/* The allocation proper */
	sp->list = np->next;
	if (nt >= 0)			/* -1 if contents are copied anyway */
	{
		(*sp->zer)(np);
		np->nt = nt;
	}

#if NODESTATS
	sp->avail--;
	if (nt < 0)
		nt = 0;
	G.ncnt[nt]++;
#endif
	set_line_no(np);
	return np;
}

global
NP childname(NP np)
{
	if (np->nt eq GENODE)
		while (np->eflgs.f.lname or np->eflgs.f.rname)
		{
			NP cp = (np->eflgs.f.lname) ? np->left : np->right;
			if (cp eq nil)
				break;
			np = cp;
		}
	return np;
}

global
void send_name(void *vp)
{										/* NB: name may contain '%' */
	NP np = vp;
	if (np)
		if (np->name)
			console("%s", np->name);
		else
			console("~~3");
}

global
void putn_fifo(NP *first, NP *last, NP np)
{
	if (*last)
		(*last)->left = np;
	else
		*first = np;
	*last = np;
}

global
void putt_fifo(TP *first, TP *last, TP tp)
{
	if (*last)
		(*last)->type = tp;
	else
		*first = tp;
	*last = tp;
}

global
void putt_lifo(TP *head, TP np)
{
	if (*head)
		np->next = *head;
	*head = np;
}

global
void putn_lifo(NP *head, NP np)
{
	if (*head)
		np->left = *head;
	*head = np;
}

global
void putv_lifo(VP *head, VP np)
{
	if (*head)
		np->next = *head;
	*head = np;
}

global
void putx_lifo(XP *head, XP np)
{
	if (*head)
		np->next = *head;
	*head = np;
}

global
void * init_symtab(short key)
{
	void * al = CC_xcalloc(1, sizeof(void *) * numhash, key, CC_ranout);
	if (al eq nil)
		error("Ran out of memory");
	return al;
}

global
void init_hlist(TP list[])
{
	short i;

	for (i = 0; i < numhash; i++)
		list[i] = nil;
}

global
void init_xlist(XP list[])
{
	short i;

	for (i = 0; i < numhash; i++)
		list[i] = nil;
}


global
void put_hlist(TP *list, TP np)	/* put after *list */
{
	if (*list)
		np->next = *list;
	*list = np;
}

global
void put_xlist(XP *list, XP np)	/* put after *list */
{
	if (*list)
		np->next = *list;
	*list = np;
#if NODESTATS
	G.defs++;
#endif
}

global
void * tlook(void *vt, void *nv)
{
	AP pt = vt, np = nv;
	while (pt)
	{
		if (pt->name eq np->name)
			return pt;
		pt = pt->left;
	}
	return nil;
}

global
void un_q(TP tp)
{
	while (tp)
	{
		tp->cflgs.f.q  = 0;
		tp->tflgs.f.qd = 0;

		if (    tp->nflgs.f.brk_l eq 0
		    and tp->tflgs.f.lpr   eq 0)
		{
			tp->tflgs.f.lpr = 1;
			un_q(tp->next);
			tp->tflgs.f.lpr = 0;
		}
		if (tp->tflgs.f.rpr eq 0)
		{
			tp->tflgs.f.rpr = 1;
			un_q(tp->list);
			tp->tflgs.f.rpr = 0;
		}

		tp = tp->type;
	}
}

bool same_q(TP tp, short q)
{
	short nq = 0;
	if (tp->cflgs.f.qc) nq|=CONST;
	if (tp->cflgs.f.qv) nq|=VOLAT;
	return  q eq nq;
}

TP qualify(TP op)
{
	TP tp = allocTn(0);
	if (tp)
	{
		*tp = *op;			/* do the copy */
		tp->nflgs.f.res   = 0;
		tp->nflgs.f.nheap = 0;
		tp->cflgs.f.q     = 1;
		op->tflgs.f.qd    = 1;
		#if NODESTATS
			G.ncnt[TLNODE]++;
		#endif
		set_line_no(tp);
	}
	return tp;
}

global
TP qualify_type(TP op , short q)	/* Designed for qualification of types */
{

	TP np = nil, last = nil, tp;

	while (op)
	{
		if (op->tflgs.f.qd)	return np;

		/* make the copy */
		tp = qualify(op);								/* equiv tdata */

		if (tp->nflgs.f.brk_l)
			tp->next = nil;		/* Disconnect from (symbol) tables */

		tp->next = qualify_type(tp->next, q);
		tp->list = qualify_type(tp->list, q);

		pick_qual(tp, q);
		putt_fifo(&np, &last, tp);
		op = op->type; 													/* equiv tprint */
	}

	return np;
}

global
NP copynode(NP op)
{
	NP np;

	if (op eq nil) return nil;

	if (op->nflgs.f.res)
		return op;

	np = allocnode(-1);

	*np = *op;

	set_line_no(np);

#if NODESTATS
	G.ncnt[0]--;
	G.ncnt[np->nt]++;
#endif
	np->right = copynode(np->right);
	np->left  = copynode(np->left );
#if FLOAT
	if (np->token eq RCON)
		np->val.dbl = copyVone(np->val.dbl);
#endif
#if LL
	if (np->token eq LCON)
		np->val.dbl = copyVone(np->val.dbl);
#endif
	if (np->type)
		to_nct(np);
	np->nflgs.f.nheap = 0;
	return np;
}

global
TP e_copyone_t(NP op)
{
	TP np = allocTn(0);
	*np = *(TP)op;
	set_line_no(np);
	np->nt = TLNODE;
	if (np->type)
		to_nct(np);
	np->nflgs.f.nheap = 0;
	return np;
}

global
NP t_copyone_e(TP op)
{
	NP np = allocnode(EXNODE);
	*(TP)np = *op;
	set_line_no(np);
	np->nt = EXNODE;
	np->right = nil;
	np->left = nil;
	if (np->type)
		to_nct(np);
	np->nflgs.f.nheap = 0;
	return np;
}

global
NP t_copy_e(TP op)		/* complete copy */
{
	NP np;

	if (op eq nil) return nil;

	np = allocnode(EXNODE);
	*(TP)np = *op;		/* enodes are larger */
	np->nt = EXNODE;
	set_line_no(np);
	if (op->list)
		np->right = t_copy_e(op->list);
	if (op->next)
		np->left = t_copy_e(op->next);
	if (np->type)
		to_nct(np);
	np->nflgs.f.nheap = 0;
	return np;
}

global
NP t_to_e(TP tp)
{
	NP np = allocnode(-1);
	*(TP)np = *tp;
	np->nt = EXNODE;
	set_line_no(np);
	#if NODESTATS
		G.ncnt[0]--;
		G.ncnt[np->nt]++;
	#endif
	freeTunit(tp);
	return np;
}

global
TP copyTnode(TP op)
{
	TP np;

	if (op eq nil) return nil;

	if (op->nflgs.f.res)
		return op;

	np = allocTn(0);

	*np = *op;
	set_line_no(np);

	if (np->list)
		np->list = copyTnode(np->list);
	if (np->next)
		np->next = copyTnode(np->next);
	if (np->type)
		to_nct(np);
	np->nflgs.f.nheap = 0;
	return np;
}

global
void copyinto(NP ip, NP np)	/* left & right of ip must have been catered for */
{
	if (ip->type and is_ct(ip))
		freeTn(ip->type);
	free_name(ip);
#if NODESTATS
	G.ncnt[ip->nt]--;
	G.ncnt[np->nt]++;
#endif
	*ip = *np;
	set_line_no(ip);
}

/*
global
void adoptnode(NP ip, NP np)	/* 04'14 HR as copyinto but adopting all subordinates */
{
	if (ip and np)
	{
		*ip = *np;
		set_line_no(ip);
		np->nflgs.f.nheap = 0;
		if (np->type)
			to_nct(np);
		freeunit(np);
	}
}
*/

global
NP copyone(NP op)
{
	NP np;

	if (op eq nil) return nil;
	np = allocnode(-1);
	*np = *op;
	generic_copyone(np);
	np->betw = nil;				/* 04'14 v5.1 */
#if FLOAT
	if (np->token eq RCON)
		np->val.dbl = nil;
#endif
#if LL
	if (np->token eq LCON)
		np->val.dbl = nil;
#endif
	return np;
}

global
TP copyTone(TP op)
{
	TP np;

	if (op eq nil) return nil;
	np = allocTn(0);
	*np = *op;
	generic_copyone(np);

	if (np->nflgs.f.res)
		np->nflgs.f.res = 0;

	return np;
}

global
NP for_old_copyone(NP np)
{
	NP newp;

	if (np eq nil) return nil;
	newp = allocnode(-1);
	*newp = *np;
#if NODESTATS
	G.ncnt[0]--;
	G.ncnt[newp->nt]++;
#endif
	np->right = nil;
	np->left = nil;
#if FLOAT
	if (np->token eq RCON)
		np->val.dbl = nil;
#endif
#if LL
	if (np->token eq LCON)
		np->val.dbl = nil;
#endif
	set_line_no(newp);
	np->nflgs.f.nheap = 0;
	return newp;
}

/*
global
NP nthnode(NP np, short n)			/* not used yet */
{
	while (n--)
		if (np eq nil)
			return nil;
		else
			np = np->left;
	return np;
}
*/

global
NP rthnode(NP np, short n)			/* only used in pre.c */
{
	while (n--)
		if (np eq nil)
			return nil;
		else
			np = np->right;
	return np;
}

#if FLOAT
global
void new_rnode(NP np, double x)
{
	VP dp = np->val.dbl;
	if (np->token ne RCON)
		dp = allocVn(RLNODE);
	np->token = RCON;
	dp->rval = x;
	np->val.dbl = dp;
}

global
double getrcon(NP np)
{
	VP dp = np->val.dbl;
	if (np->token eq RCON)
		if (dp)
			return dp->rval;
		else
			CE_("RCON no val.dbl");
	else
		CE_("no rnode");
	return 0;
}
#endif

#if LL
global
void new_lnode(NP np, __ll x)
{
	VP dp = np->val.dbl;
	if (np->token ne LCON)
		dp = allocVn(LLNODE);
	np->token = LCON;
	dp->llval = x;
	np->val.dbl = dp;
}

global
__ll getlcon(NP np)
{
	__ll ll_0 = {0,0};
	VP dp = np->val.dbl;
	if (np->token eq LCON)
		if (dp)
			return dp->llval;
		else
			CE_("LCON no val.ll");
	else
		CE_("no lnode");

	return ll_0;
}
#endif

#if MTREE
global
NP make_tree(Cstr *t)	/* t is template */
{
	NP np = nil;

	if (t)
	{
		Cstr s = *t;
		if (s)
		{
			short tok = 0;

			while(isdigit(*s))
				tok = tok*10+(*s-'0'), s++;

			np = make_node(tok, E_LEAF, 1, nil);

			if (np)
			{
				if (*s)
				{
					bool par = is_open(*s);
/* if there is a left, the node is at least unary. */
					if (par)
					{
						np->tt = E_UNARY;
						s++;
						np->left = make_tree(&s);
/* if there is a right, the node can only be binary, there must be a left! */
						if (*s eq ',')
						{
							np->tt = E_BIN;
							s++;
							np->right = make_tree(&s);
						}

						if (is_close(*s)) s++;
					}
				}
			}
		}
		*t = s;
	}
	return np;
}
#endif
