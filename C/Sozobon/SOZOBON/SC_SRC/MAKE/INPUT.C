/***************************************************************\
 *								*
 *  PDMAKE, Atari ST version					*
 *								*
 *  Adapted from mod.sources Vol 7 Issue 71, 1986-12-03.	*
 *								*
 *  This port makes extensive use of the original net.sources	*
 *  port by Jwahar Bammi.					*
 *								*
 *      Ton van Overbeek					*
 *      Email: TPC862@ESTEC.BITNET				*
 *             TPC862%ESTEC.BITNET@WISCVM.WISC.EDU    (ARPA)	*
 *             ...!mcvax!tpc862%estec.bitnet   (UUCP Europe)	*
 *             ...!ucbvax!tpc862%estec.bitnet  (UUCP U.S.A.)	*
 *             71450,3537  (CompuServe)				*
 *								*
 \***************************************************************/

/*
 *    Parse a makefile
 */


#include <stdio.h>
#include <ctype.h>
#include "h.h"


struct name namehead;
struct name *	firstname;

char	str1[LZ];		/*  General store  */
char	str2[LZ];


/*
 *    Intern a name.  Return a pointer to the name struct
 */
struct name *
newname(name)
char	*name;
{
	register struct name *rp;
	register struct name *rrp;
	register char	*cp;

	for (
	    rp = namehead.n_next, rrp = &namehead; 
	    rp; 
	    rp = rp->n_next, rrp = rrp->n_next
	    ) {
		if (strcmp(name, rp->n_name) == 0)
			return rp;
	}

	if ((rp = (struct name *)malloc(sizeof (struct name )))
	     == (struct name *)0)
		fatal("No memory for name");
	rrp->n_next = rp;
	rp->n_next = (struct name *)0;
	if ((cp = malloc(strlen(name) + 1)) == (char *)0)
		fatal("No memory for name");
	strcpy(cp, name);
	rp->n_name = cp;
	rp->n_line = (struct line *)0;
	rp->n_time = (time_t)0;
	rp->n_flag = 0;

	return rp;
}


/*
 *    Add a dependent to the end of the supplied list of dependents.
 *    Return the new head pointer for that list.
 */
struct depend *
newdep(np, dp)
struct name *np;
struct depend *dp;
{
	register struct depend *rp;
	register struct depend *rrp;


	if ((rp = (struct depend *)malloc(sizeof (struct depend )))
	     == (struct depend *)0)
		fatal("No memory for dependant");
	rp->d_next = (struct depend *)0;
	rp->d_name = np;

	if (dp == (struct depend *)0)
		return rp;

	for (rrp = dp; rrp->d_next; rrp = rrp->d_next)
		;

	rrp->d_next = rp;

	return dp;
}


/*
 *    Add a command to the end of the supplied list of commands.
 *    Return the new head pointer for that list.
 */
struct cmd *
newcmd(str, cp)
char	*str;
struct cmd *cp;
{
	register struct cmd *rp;
	register struct cmd *rrp;
	register char	*rcp;

	if (rcp = strrchr(str, '\n'))
		*rcp = '\0';		/*  Lose newline  */

	while (isspace(*str))
		str++;

	if (*str == '\0')		/*  If nothing left, then exit  */
		return;

	if ((rp = (struct cmd *)malloc(sizeof (struct cmd )))
	     == (struct cmd *)0)
		fatal("No memory for command");
	rp->c_next = (struct cmd *)0;
	if ((rcp = malloc(strlen(str) + 1)) == (char *)0)
		fatal("No memory for command");
	strcpy(rcp, str);
	rp->c_cmd = rcp;

	if (cp == (struct cmd *)0)
		return rp;

	for (rrp = cp; rrp->c_next; rrp = rrp->c_next)
		;

	rrp->c_next = rp;

	return cp;
}


/*
 *    Add a new 'line' of stuff to a target.  This check to see
 *    if commands already exist for the target.  If flag is set,
 *    the line is a double colon target.
 *
 *    Kludges:
 *    i)  If the new name begins with a '.', and there are no dependents,
 *        then the target must cease to be a target.  This is for .SUFFIXES.
 *    ii) If the new name begins with a '.', with no dependents and has
 *        commands, then replace the current commands.  This is for
 *        redefining commands for a default rule.
 *    Neither of these free the space used by dependents or commands,
 *    since they could be used by another target.
 */
void
newline(np, dp, cp, flag)
struct name *np;
struct depend *dp;
struct cmd *cp;
{
	bool	hascmds = FALSE; /*  Target has commands  */
	register struct line *rp;
	register struct line *rrp;


	/* Handle the .SUFFIXES case */
	if (np->n_name[0] == '.' && !dp && !cp) {
		for (rp = np->n_line; rp; rp = rrp) {
			rrp = rp->l_next;
			free(rp);
		}
		np->n_line = (struct line *)0;
		np->n_flag &= ~N_TARG;
		return;
	}

	/* This loop must happen since rrp is used later. */
	for (
	    rp = np->n_line, rrp = (struct line *)0; 
	    rp; 
	    rrp = rp, rp = rp->l_next
	    )
	if (rp->l_cmd)
		hascmds = TRUE;

	if (hascmds && cp && !(np->n_flag & N_DOUBLE))
		/* Handle the implicit rules redefinition case */
		if (np->n_name[0] == '.' && dp == (struct depend *)0) {
			np->n_line->l_cmd = cp;
			return;
		} else
			error("Commands defined twice for target %s", np->n_name);
	if (np->n_flag & N_TARG)
		if (!(np->n_flag & N_DOUBLE) != !flag)        /* like xor */
			error("Inconsistent rules for target %s", np->n_name);

	if ((rp = (struct line *)malloc(sizeof (struct line )))
	     == (struct line *)0)
		fatal("No memory for line");
	rp->l_next = (struct line *)0;
	rp->l_dep = dp;
	rp->l_cmd = cp;

	if (rrp)
		rrp->l_next = rp;
	else
		np->n_line = rp;

	np->n_flag |= N_TARG;
	if (flag)
		np->n_flag |= N_DOUBLE;
}


/*
 *    Parse input from the makefile, and construct a tree structure
 *    of it.
 */
void
input(fd)
FILE *	fd;
{
	char	*p;        /*  General  */
	char	*q;
	struct name *np;
	struct depend *dp;
	struct cmd *cp;
	bool	dbl;


	if (getline(str1, fd))		/*  Read the first line  */
		return;

	for (;;) {
		if (*str1 == '\t')		/*  Rules without targets  */
			error("Rules not allowed here");

		p = str1;

		while (isspace(*p))		/*  Find first target  */
			p++;

		while (((q = strchr(p, '=')) != (char *)0) && 
		    (p != q) && (q[-1] == '\\'))	/*  Find value */ {
			register char	*       a;

			a = q - 1;	/*  Del \ chr; move rest back  */
			p = q;
			while (*a++ = *q++)
				;
		}

		if (q != (char *)0) {
			register char	*	a;

			*q++ = '\0';		/*  Separate name and val  */
			while (isspace(*q))
				q++;
			if (p = strrchr(q, '\n'))
				*p = '\0';

			p = str1;
			if ((a = gettok(&p)) == (char *)0)
				error("No macro name");

			setmacro(a, q);

			if (getline(str1, fd))
				return;
			continue;
		}

		expand(str1);
		p = str1;

		while (((q = strchr(p, ':')) != (char *)0) && 
		    (p != q) && (q[-1] == '\\')) {	/*  Find dependents  */
			register char	*       a;

			a = q - 1;	/*  Del \ chr; move rest back  */
			p = q;
			while (*a++ = *q++)
				;
		}

		if (q == (char *)0)
			error("No targets provided");

		*q++ = '\0';		/*  Separate targets and dependents  */

		if (*q == ':') {		/*  Double colon */
			dbl = 1;
			q++;
		} else
			dbl = 0;

		/* get list of dep's */
		for (dp=(struct depend *)0; ((p = gettok(&q)) != (char *)0); ) {
			np = newname(p);		/*  Intern name  */
			dp = newdep(np, dp);		/*  Add to dep list */
		}

		*((q = str1) + strlen(str1) + 1) = '\0';
		/*  Need two nulls for gettok (Remember separation)  */

		cp = (struct cmd *)0;
		if (getline(str2, fd) == FALSE)		/*  Get commands  */ {
			while (*str2 == '\t') {
				cp = newcmd(&str2[0], cp);
				if (getline(str2, fd))
					break;
			}
		}

		/* Get list targ's */
		while ((p = gettok(&q)) != (char *)0) {
			np = newname(p);		/*  Intern name  */
			newline(np, dp, cp, dbl);
			if (!firstname && p[0] != '.')
				firstname = np;
		}

		if (feof(fd))				/*  EOF?  */
			return;

		strcpy(str1, str2);
	}
}
