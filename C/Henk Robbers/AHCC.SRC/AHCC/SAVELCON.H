#if LONGLONG
static short save_Lcon(NP np)
{
	NP tp, zp = G.consave;
	VP dp;

	D_(G, "save_Lcon");

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
				np->nflags.f.nheap = NCOPY;
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
	tp->nflags.f.nheap = np->nflags.f.nheap;
	np->nflags.f.nheap = NCOPY;
	tp->val.dbl = dp;
	np->val.dbl = nil;
	tp->lbl = new_lbl();
	tp->nflags |= N_BRKPR;
	tp->eflgs &= ~IMMEDID;		/* for out_let 'A' */
#if NODESTATS
		G.ncnt[tp->nt]--;
		G.ncnt[GENODE]++;
#endif
	tp->nt = GENODE;
	addcode(tp, "L1:\n\t^YS\t\tA\n");
	put_fifo(&G.consave, &G.conlast, tp);
	set_class(np, CON_class);
	np->area_info.disp = std_areas->ar[np->area_info.class].size;
	std_areas->ar[np->area_info.class].size += DOT_LL;
	tp->area_info = np->area_info;

	return tp->lbl;
}
#endif
