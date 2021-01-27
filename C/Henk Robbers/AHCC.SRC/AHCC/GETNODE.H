

static
XP getnode(void)
{
	XP rv, dp;
	rv = hi_node();			/* pick up expanded text */

	if (rv eq nil)
		rv = to_endof();
	elif (G.in_if_X and strcmp(rv->name, "defined") eq 0)	/* ANSI 'defined' is treated as unary operator. */
	{
		G.skip_id = true;		/* do not expand very next identifier */
		rv->token = DEFINED;
	}
	elif (G.in_if_X and strcmp(rv->name, "declared") eq 0)
	{
		G.skip_id = true;		/* do not expand very next identifier */
		rv->token = DECLARED;
	}
	elif (rv->token eq ID)
	{
		if (G.skip_id)		/* expand inhibited na 'defined' */
			G.skip_id = false;
		elif (!(G.lang eq 's' and G.skip_X))
		{
			if (rv->nflgs.f.nexp eq 0 )		/* quick recursion fix */
			{
				if ((dp = tlook(deflist[hash(rv->name)], rv)) ne nil)
					if (expand(dp, &G.holdtok, G.lang eq 's'))
					{
						freeXn(rv);
						rv = getnode();
					}
			}
	
			if (! (  (    rv->name[0] eq '_'
			          and rv->name[1] eq '_'
			          and builtin(rv)
			         )
			       or rv->cflgs.f.ided
			      )
			   )
				kw_tok(rv);
		}
	}

	return rv;
}
