/***************************************************************\
*								*
*  PDMAKE, Atari ST version					*
*								*
*  Adapted from mod.sources Vol 7 Issue 71, 1986-12-03.		*
*								*
*  This port makes extensive use of the original net.sources	*
*  port by Jwahar Bammi.					*
*								*
*      Ton van Overbeek						*
*      Email: TPC862@ESTEC.BITNET				*
*             TPC862%ESTEC.BITNET@WISCVM.WISC.EDU    (ARPA)	*
*             ...!mcvax!tpc862%estec.bitnet   (UUCP Europe)	*
*             ...!ucbvax!tpc862%estec.bitnet  (UUCP U.S.A.)	*
*             71450,3537  (CompuServe)				*
*								*
\***************************************************************/

/*
 *    Macro control for make
 */

#include "h.h"

struct macro *macrohead;

struct macro *
getmp(name)
char	*name;
{
	register struct macro *rp;

	for (rp = macrohead; rp; rp = rp->m_next)
		if (strcmp(name, rp->m_name) == 0)
			return rp;
	return (struct macro *)0;
}


char	*
getmacro(name)
char	*name;
{
	struct macro *mp;

	if (mp = getmp(name))
		return mp->m_val;
	else
		return "";
}


struct macro *
setmacro(name, val)
char	*name;
char	*val;
{
	register struct macro *rp;
	register char	*cp;


	/*  Replace macro definition if it exists  */
	for (rp = macrohead; rp; rp = rp->m_next)
		if (strcmp(name, rp->m_name) == 0) {
			free(rp->m_val);	/*  Free space from old  */
			break;
		}

	if (!rp) {	/*  If not defined, allocate space for new  */
		if ((rp = (struct macro *)malloc(sizeof (struct macro )))
		     == (struct macro *)0)
			fatal("No memory for macro");

		rp->m_next = macrohead;
		macrohead = rp;
		rp->m_flag = FALSE;

		if ((cp = malloc(strlen(name) + 1)) == (char *)0)
			fatal("No memory for macro");
		strcpy(cp, name);
		rp->m_name = cp;
	}

	if ((cp = malloc(strlen(val) + 1)) == (char *)0)
		fatal("No memory for macro");
	strcpy(cp, val);			/*  Copy in new value  */
	rp->m_val = cp;

	return rp;
}


/*
 *    Do the dirty work for expand
 */
void
doexp(to, from, len, buf)
char	**	to;
char	*	from;
int	*	len;
char	*	buf;
{
	register char	*rp;
	register char	*p;
	register char	*q;
	register struct macro *mp;


	rp = from;
	p = *to;
	while (*rp) {
		if (*rp != '$') {
			*p++ = *rp++;
			(*len)--;
		} else {
			q = buf;
			if (*++rp == '{')
				while (*++rp && *rp != '}')
					*q++ = *rp;
			else if (*rp == '(')
				while (*++rp && *rp != ')')
					*q++ = *rp;
			else if (!*rp) {
				*p++ = '$';
				break;
			} else
				*q++ = *rp;
			*q = '\0';
			if (*rp)
				rp++;
			if (!(mp = getmp(buf)))
				mp = setmacro(buf, "");
			if (mp->m_flag)
				fatal("Infinitely recursive macro %s", mp->m_name);
			mp->m_flag = TRUE;
			*to = p;
			doexp(to, mp->m_val, len, buf);
			p = *to;
			mp->m_flag = FALSE;
		}
		if (*len <= 0)
			error("Expanded line too line");
	}
	*p = '\0';
	*to = p;
}


/*
 *    Expand any macros in str.
 */
void
expand(str)
char	*str;
{
	static char	a[LZ];
	static char	b[LZ];
	char	*p = str;
	int	len = LZ-1;

	strcpy(a, str);
	doexp(&p, a, &len, b);
}
