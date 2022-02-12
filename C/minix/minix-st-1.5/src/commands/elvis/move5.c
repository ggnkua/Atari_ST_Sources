/* move5.c */

/* Author:
 *	Steve Kirkendall
 *	16820 SW Tallac Way
 *	Beaverton, OR 97006
 *	kirkenda@jove.cs.pdx.edu, or ...uunet!tektronix!psueea!jove!kirkenda
 */


/* This file contains the word-oriented movement functions */

#include <ctype.h>
#include "vi.h"

#ifndef isascii
# define isascii(c)	!((c) & ~0x7f)
#endif


MARK	movefword(m, cnt)
	MARK	m;	/* movement is relative to this mark */
	long	cnt;	/* a numeric argument */
{
	register long	l;
	register char	*text;
	register int	i;

	DEFAULT(1);

	l = markline(m);
	pfetch(l);
	text = ptext + markidx(m);
	while (cnt-- > 0) /* yes, ASSIGNMENT! */
	{
		i = *text++;
		/* if we hit the end of the line, continue with next line */
		if (!isascii(i) || isalnum(i) || i == '_')
		{
			/* include an alphanumeric word */
			while (i && (!isascii(i) || isalnum(i) || i == '_'))
			{
				i = *text++;
			}
		}
		else
		{
			/* include contiguous punctuation */
			while (i && isascii(i) && !isalnum(i) && !isspace(i))
			{
				i = *text++;
			}
		}

		/* include trailing whitespace */
		while (!i || isascii(i) && isspace(i))
		{
			/* did we hit the end of this line? */
			if (!i)
			{
				/* move to next line, if there is one */
				l++;
				if (l > nlines)
				{
					return MARK_UNSET;
				}
				pfetch(l);
				text = ptext;
			}

			i = *text++;
		}
		text--;
	}

	/* construct a MARK for this place */
	m = buildmark(text);
	return m;
}


MARK	movebword(m, cnt)
	MARK	m;	/* movement is relative to this mark */
	long	cnt;	/* a numeric argument */
{
	register long	l;
	register char	*text;

	DEFAULT(1);

	l = markline(m);
	pfetch(l);
	text = ptext + markidx(m);
	while (cnt-- > 0) /* yes, ASSIGNMENT! */
	{
		text--;

		/* include preceding whitespace */
		while (text < ptext || isascii(*text) && isspace(*text))
		{
			/* did we hit the end of this line? */
			if (text < ptext)
			{
				/* move to preceding line, if there is one */
				l--;
				if (l <= 0)
				{
					return MARK_UNSET;
				}
				pfetch(l);
				text = ptext + plen - 1;
			}
			else
			{
				text--;
			}
		}

		if (!isascii(*text) || isalnum(*text) || *text == '_')
		{
			/* include an alphanumeric word */
			while (text >= ptext && (!isascii(*text) || isalnum(*text) || *text == '_'))
			{
				text--;
			}
		}
		else
		{
			/* include contiguous punctuation */
			while (text >= ptext && isascii(*text) && !isalnum(*text) && !isspace(*text))
			{
				text--;
			}
		}
		text++;
	}

	/* construct a MARK for this place */
	m = buildmark(text);
	return m;
}

MARK	moveeword(m, cnt)
	MARK	m;	/* movement is relative to this mark */
	long	cnt;	/* a numeric argument */
{
	register long	l;
	register char	*text;
	register int	i;

	DEFAULT(1);

	l = markline(m);
	pfetch(l);
	text = ptext + markidx(m);
	while (cnt-- > 0) /* yes, ASSIGNMENT! */
	{
		text++;
		i = *text++;

		/* include preceding whitespace */
		while (!i || isascii(i) && isspace(i))
		{
			/* did we hit the end of this line? */
			if (!i)
			{
				/* move to next line, if there is one */
				l++;
				if (l > nlines)
				{
					return MARK_UNSET;
				}
				pfetch(l);
				text = ptext;
			}

			i = *text++;
		}

		if (!isascii(i) || isalnum(i) || i == '_')
		{
			/* include an alphanumeric word */
			while (i && (!isascii(i) || isalnum(i) || i == '_'))
			{
				i = *text++;
			}
		}
		else
		{
			/* include contiguous punctuation */
			while (i && isascii(i) && !isalnum(i) && !isspace(i))
			{
				i = *text++;
			}
		}
		text -= 2;
	}

	/* construct a MARK for this place */
	m = buildmark(text);
	return m;
}

MARK	movefWord(m, cnt)
	MARK	m;	/* movement is relative to this mark */
	long	cnt;	/* a numeric argument */
{
	register long	l;
	register char	*text;
	register int	i;

	DEFAULT(1);

	l = markline(m);
	pfetch(l);
	text = ptext + markidx(m);
	while (cnt-- > 0) /* yes, ASSIGNMENT! */
	{
		i = *text++;
		/* if we hit the end of the line, continue with next line */
		/* include contiguous non-space characters */
		while (i && !isspace(i))
		{
			i = *text++;
		}

		/* include trailing whitespace */
		while (!i || isascii(i) && isspace(i))
		{
			/* did we hit the end of this line? */
			if (!i)
			{
				/* move to next line, if there is one */
				l++;
				if (l > nlines)
				{
					return MARK_UNSET;
				}
				pfetch(l);
				text = ptext;
			}

			i = *text++;
		}
		text--;
	}

	/* construct a MARK for this place */
	m = buildmark(text);
	return m;
}


MARK	movebWord(m, cnt)
	MARK	m;	/* movement is relative to this mark */
	long	cnt;	/* a numeric argument */
{
	register long	l;
	register char	*text;

	DEFAULT(1);

	l = markline(m);
	pfetch(l);
	text = ptext + markidx(m);
	while (cnt-- > 0) /* yes, ASSIGNMENT! */
	{
		text--;

		/* include trailing whitespace */
		while (text < ptext || isascii(*text) && isspace(*text))
		{
			/* did we hit the end of this line? */
			if (text < ptext)
			{
				/* move to next line, if there is one */
				l--;
				if (l <= 0)
				{
					return MARK_UNSET;
				}
				pfetch(l);
				text = ptext + plen - 1;
			}
			else
			{
				text--;
			}
		}

		/* include contiguous non-whitespace */
		while (text >= ptext && (!isascii(*text) || !isspace(*text)))
		{
			text--;
		}
		text++;
	}

	/* construct a MARK for this place */
	m = buildmark(text);
	return m;
}

MARK	moveeWord(m, cnt)
	MARK	m;	/* movement is relative to this mark */
	long	cnt;	/* a numeric argument */
{
	register long	l;
	register char	*text;
	register int	i;

	DEFAULT(1);

	l = markline(m);
	pfetch(l);
	text = ptext + markidx(m);
	while (cnt-- > 0) /* yes, ASSIGNMENT! */
	{
		text++;
		i = *text++;

		/* include preceding whitespace */
		while (!i || isascii(i) && isspace(i))
		{
			/* did we hit the end of this line? */
			if (!i)
			{
				/* move to next line, if there is one */
				l++;
				if (l > nlines)
				{
					return MARK_UNSET;
				}
				pfetch(l);
				text = ptext;
			}

			i = *text++;
		}

		/* include contiguous non-whitespace */
		while (i && (!isascii(i) || !isspace(i)))
		{
			i = *text++;
		}
		text -= 2;
	}

	/* construct a MARK for this place */
	m = buildmark(text);
	return m;
}
