int strrpl(string, ptrn, rpl, n)
	char *string, *ptrn;
	register char *rpl;
	register int n;
/*
 *	Replace at most <n> occurances of <ptrn> in <string> with <rpl>.
 *	If <n> is -1, replace all.  Return the number of replacments.
 */
	{
	register char *p, *q = string;
	register int d, rlen, nn = 0;
	char *strstr();

	rlen = strlen(rpl);
	d = rlen - strlen(ptrn);
	while(n && (p = strstr(q, ptrn)))
		{
		++nn;
		stradj(p, d);
		strncpy(p, rpl, rlen);
		q = p + rlen;
		if(n > 0)
			--n;
		}
	return(nn);
	}
