#if COLDFIRE
static
short save_Icon(NP np)
{
	NP tp, zp = G.consave;

	if (np->token ne COLDCON)
	{
		CE_N(np, "not ICON");
		return -1;
	}

	np->token = ICON;

	while (zp)
	{
		if (zp->token eq np->token)
		{
			if (zp->val.i eq np->val.i)
			{
				np->token   = OLNAME;
				np->nflgs.f.nheap = 0;
				np->val.i   = 0;
				np->area_info = zp->area_info;

				return zp->lbl;
			}
		}
		zp = zp->left;
	}

	tp = copyone(np);
	np->token = OLNAME;
	tp->nflgs.f.nheap = np->nflgs.f.nheap;
	np->nflgs.f.nheap = 0;
	np->val.i = 0;
	tp->lbl = new_lbl();
	tp->nflgs.f.brk_l = 1;
	tp->eflgs.f.imm = 0;		/* for out_let 'A' */
#if NODESTATS
		G.ncnt[tp->nt]--;
		G.ncnt[GENODE]++;
#endif
	tp->nt = GENODE;
	addcode(tp, "L1:\n\t^YS\t\tA\n");
	putn_fifo(&G.consave, &G.conlast, tp);
	set_class(np, CON_class);
	np->area_info.disp = std_areas->ar[np->area_info.class].size;
	std_areas->ar[np->area_info.class].size += tp->size eq SIZE_C ? SIZE_S : SIZE_L;
	tp->area_info = np->area_info;

	return tp->lbl;
}

static
short save_Fcon(NP np)
{
	NP tp, zp = G.consave;

	if (np->token ne FCON)
	{
		CE_N(np, "not FCON");
		return -1;
	}

	np->token = FCON;

	while (zp)
	{
		if (zp->token eq np->token)
		{
			if (zp->val.f eq np->val.f)
			{
				np->token   = OLNAME;
				np->nflgs.f.nheap = 0;
				np->val.f   = 0;
				np->area_info = zp->area_info;

				return zp->lbl;
			}
		}
		zp = zp->left;
	}

	tp = copyone(np);
	np->token = OLNAME;
	tp->nflgs.f.nheap = np->nflgs.f.nheap;
	np->nflgs.f.nheap = 0;
	np->val.f = 0;
	tp->lbl = new_lbl();
	tp->nflgs.f.brk_l = 1;
	tp->eflgs.f.imm = 0;		/* for out_let 'A' */
#if NODESTATS
		G.ncnt[tp->nt]--;
		G.ncnt[GENODE]++;
#endif
	tp->nt = GENODE;
	addcode(tp, "L1:\n\t^YS\t\tA\n");
	putn_fifo(&G.consave, &G.conlast, tp);
	set_class(np, CON_class);
	np->area_info.disp = std_areas->ar[np->area_info.class].size;
	std_areas->ar[np->area_info.class].size += tp->size eq SIZE_C ? SIZE_S : SIZE_L;
	tp->area_info = np->area_info;

	return tp->lbl;
}
#endif

#if LL
static
short save_Lcon(NP np)
{
	NP tp, zp = G.consave;
	VP dp;

	if (np->token ne LCON or (np->token eq LCON and np->val.dbl eq nil))
	{
		CE_N(np, "not LCON");
		return -1;
	}
	while (zp)
	{
		VP zdp = zp->val.dbl,
		   ndp = np->val.dbl;

		if (zp->token eq np->token)
		{
			__ll l1 = zdp->llval,
			     l2 = ndp->llval;

			if (l1.hi eq l2.hi and l1.lo eq l2.lo)
			{
				np->token   = ONAME;
				np->nflgs.f.nheap = 0;
				freeVn(np->val.dbl);
				np->val.dbl = nil;
				np->area_info = zp->area_info;

				return zp->lbl;
			}
		}
		zp = zp->left;
	}

	dp = np->val.dbl;
	tp = copyone(np);		/* does not copy the LLNODE */
	np->token = ONAME;
	tp->nflgs.f.nheap = np->nflgs.f.nheap;
	np->nflgs.f.nheap = 0;
	tp->val.dbl = dp;
	np->val.dbl = nil;
	tp->lbl = new_lbl();
	tp->nflgs.f.brk_l = 1;
	tp->eflgs.f.imm = 0;		/* for out_let 'A' */
#if NODESTATS
		G.ncnt[tp->nt]--;
		G.ncnt[GENODE]++;
#endif
	tp->nt = GENODE;
	addcode(tp, "L1:\n\t^YS\t\tA\n");
	putn_fifo(&G.consave, &G.conlast, tp);
	set_class(np, CON_class);
	np->area_info.disp = std_areas->ar[np->area_info.class].size;
	std_areas->ar[np->area_info.class].size += DOT_LL;
	tp->area_info = np->area_info;

	return tp->lbl;
}
#endif
