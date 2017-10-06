int strirpl(string, ptrn, rpl, n)
	char *string, *ptrn;
	register char *rpl;
	register int n;
	{
	register char *p, *q = string;
	register int d, rlen, nn = 0;
	char *stristr();

	rlen = strlen(rpl);
	d = rlen - strlen(ptrn);
	while(n && (p = stristr(q, ptrn)))
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
