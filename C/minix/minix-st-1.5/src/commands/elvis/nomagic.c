/* nomagic.c */

/* This contains versions of the regcomp() and regexec() functions which
 * do not recognize any metacharacters except ^ $ and \.  They use the same
 * data structure Henry Spencer's package, so they can continue to use his
 * regsub() function.
 *
 * This file is meant to be #included in regexp.c; it should *NOT* be
 * compiled separately.  The regexp.c file will check to see if NO_MAGIC
 * is defined, and if so then this file is used; if not, then the real
 * regexp functions are used.
 */


regexp *regcomp(exp)
	char	*exp;
{
	char	*src;
	char	*dest;
	regexp	*re;
	int	i;
	char	*malloc();

	/* allocate a big enough regexp structure */
	re = (regexp *)malloc(strlen(exp) + 1 + sizeof(struct regexp));
	if (!re)
	{
		regerror("could not malloc a regexp structure");
		return (regexp *)0;
	}

	/* initialize all fields of the structure */
	for (i = 0; i < NSUBEXP; i++)
	{
		re->startp[i] = (char *)0;
		re->endp[i] = (char *)0;
	}
	re->regstart = 0;
	re->reganch = 0;
	re->regmust = &re->program[1];
	re->regmlen = 0;
	re->program[0] = MAGIC;

	/* copy the string into it, translating ^ and $ as needed */
	for (src = exp, dest = re->program + 1; *src; src++)
	{
		switch (*src)
		{
		  case '^':
			if (src == exp)
				re->regstart = 1;
			else
				*dest++ = '^';
			break;

		  case '$':
			if (!src[1])
				re->reganch = 1;
			else
				*dest++ = '$';
			break;

		  case '\\':
			if (src[1])
				*dest++ = *++src;
			else
			{
				regerror("extra \\ at end of regular expression");
			}
			break;

		  default:
			*dest++ = *src;
		}
	}
	*dest = '\0';
	re->regmlen = strlen(&re->program[1]);

	return re;
}


/* This "helper" function checks for a match at a given location.  It returns
 * 1 if it matches, 0 if it doesn't match here but might match later on in the
 * string, or -1 if it could not possibly match
 */
static int reghelp(prog, string, bolflag)
	struct regexp	*prog;
	char		*string;
	int		bolflag;
{
	char		*scan;
	char		*str;

	/* if ^, then require bolflag */
	if (prog->regstart && !bolflag)
	{
		return -1;
	}

	/* if it matches, then it will start here */
	prog->startp[0] = string;

	/* compare, possibly ignoring case */
	if (o_ignorecase)
	{
		for (scan = &prog->program[1]; *scan; scan++, string++)
			if (tolower(*scan) != tolower(*string))
				return *string ? 0 : -1;
	}
	else
	{
		for (scan = &prog->program[1]; *scan; scan++, string++)
			if (*scan != *string)
				return *string ? 0 : -1;
	}

	/* if $, then require string to end here, too */
	if (prog->reganch && *string)
	{
		return 0;
	}

	/* if we get to here, it matches */
	prog->endp[0] = string;
	return 1;
}



int regexec(prog, string, bolflag)
	struct regexp	*prog;
	char		*string;
	int		bolflag;
{
	int		rc;

	/* keep trying to match it */
	for (rc = reghelp(prog, string, bolflag); rc == 0; rc = reghelp(prog, string, 0))
	{
		string++;
	}

	/* did we match? */
	return rc == 1;
}
