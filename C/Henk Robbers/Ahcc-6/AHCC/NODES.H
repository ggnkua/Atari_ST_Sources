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
 *	nodes.h
 */

#define set_line_no(x) (x)->fl.ln = line_no, (x)->fl.n = G.inctab->p.fileno;

NpI		allocnode;
VpN 	freenode;
VpN		freeunit;
XP		allocXn		(bool clr);
void	freeXn		(XP);
void	freeXunit	(XP);
XP 		copyXone	(XP np);
TP		allocTn		(bool clr);
VpT 	freeTn;
void	freeTunit(TP);
VP		allocVn		(short);
void	freeVunit	(VP vp),
    	freeVn		(VP vp);
VP		copyVone	(VP vp);
BP		allocBn		(void);
void	freeBunit	(BP bp),
    	freeBn		(BP bp);
IP		allocIn		(void);
void	freeIunit	(IP ip),
    	freeIn		(IP ip);
VpT 	un_q, may_nct;
void	free_name	(void *ap);
NpT		t_copy_e,
		t_copyone_e,
		t_to_e;
TpN		e_copyone_t;
NpV		gx_node;
TpT		copyTnode,
		copyTone;
NpN		childname,
		copynode,
		copyone,				/* for warping new */
		for_old_copyone;		/*  "    "     old */
VpV		nodecnts;
VpTI	pick_qual;
void	send_name(void *vp);
VpI		freenodespace;
VpN		next_gp,
		prev_gp;
VpNI	new_gp,
		expr_gp,
		prev_expr_gp;
VpNN	copyinto, adoptnode;
short 	hash(Cstr);
NpNI	nthnode,
		rthnode;
VpTT	d_to_dt, d_to_dt_A, d_to_dt_C;
void *	tlook		(void *vt, void *nv);
void	putn_lifo	(NP *head, NP np),
		putv_lifo	(VP *head, VP np),
		putx_lifo	(XP *head, XP np),
		putt_lifo	(TP *head, TP np),
		putn_fifo	(NP *first, NP *last, NP np),
		putt_fifo	(TP *first, TP *last, TP tp),
		put_hlist	(TP *list, TP np),
		put_xlist	(XP *list, XP np),
	    name_to_str	(void *vp, Cstr s),
		save_name	(void *vp, long l, Cstr s),
		c_mods		(void *, void *),
		init_xlist	(XP np[]),
		init_hlist	(TP np[]);
void *	init_symtab	(short key);
short 	new_name	(void *vp, Cstr text, ... );
TP 		qualify_type(TP, short);
NP  	make_node	(short, short, long, Cstr);
NP 		make_lbin	(short tok, Cstr name, NP lp, NP rp);
NP 		make_rbin	(short tok, Cstr name, NP lp, NP rp);
TP  	make_type	(short, short, Cstr, Cstr);
NP  	make_tree	(Cstr *t);

#if FLOAT
void	new_rnode	(NP np, double x);
double	getrcon		(NP np);
#endif
#if LL
void	new_lnode	(NP np, __ll l);
__ll	getlcon		(NP np);
#endif
