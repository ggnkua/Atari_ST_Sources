void swab(src, dst, n)
	register char *src;
	register char *dst;
	register int n;
/*
 *	Note the backward order of the <src> and <dst> parameters.  Don't
 *	blame me... this is how Microsoft specifies it.
 */
	{
	register int i, j;
	register char c;

	n >>= 1;		/* convert to a word count */
	while(n--)
		{
		c = *dst++;
		*dst++ = *src++;
		*src++ = c;
		}
	}
