char *stradj(string, dir)
	register char *string;
	register int dir;
/*
 *	Adjust <string> by adding space if <dir> is positive, or removing
 *	space if <dir> is negative.  The magnitude of <dir> is the number
 *	of character positions to add or remove.  Characters are added or
 *	removed at the beginning of <string>.  A pointer to the modified
 *	<string> is returned.
 */
	{
	register char *p = string, *q;

	if(dir == 0)
		return(string);
	if(dir > 0)			/* add space */
		{
		while(*p)			/* find end */
			++p;
		q = p + dir;			/* set gap */
		while(p >= string)		/* copy data */
			*q-- = *p--;
		while(q >= string)		/* replace <nul>s */
			{
			if(*q == '\0')
				*q = ' ';
			--q;
			}
		}
	else				/* remove space */
		{
		dir = -dir;
		q = p + dir;			/* set gap */
		while(*p++ = *q++)		/* copy data */
			;
		}
	return(string);
	}
