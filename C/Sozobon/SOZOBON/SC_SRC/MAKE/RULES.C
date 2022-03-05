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
 *    Control of the implicit suffix rules
 */


#include "h.h"


/*
 *    Return a pointer to the suffix of a name
 */
char	*
suffix(name)
char	*name;
{
	return strrchr(name, '.');
}


/*
 *    Dynamic dependency.  This routine applies the suffix rules
 *    to try and find a source and a set of rules for a missing
 *    target.  If found, np is made into a target with the implicit
 *    source name, and rules.  Returns TRUE if np was made into
 *    a target.
 */
bool
dyndep(np)
struct name *	np;
{
	register char	*p;
	register char	*q;
	register char	*suff;		/*  Old suffix  */
	register char	*basename;	/*  Name without suffix  */
	struct name *op;		/*  New dependent  */
	struct name *sp;		/*  Suffix  */
	struct line *lp;
	struct depend *dp;
	char	*newsuff;


	p = str1;
	q = np->n_name;
	if (!(suff = suffix(q)))
		return FALSE;			/* No suffix */
	while (q < suff)
		*p++ = *q++;
	*p = '\0';
	basename = setmacro("*", str1)->m_val;

	if (!((sp = newname(".SUFFIXES"))->n_flag & N_TARG))
		return FALSE;

	for (lp = sp->n_line; lp; lp = lp->l_next)
		for (dp = lp->l_dep; dp; dp = dp->d_next) {
			newsuff = dp->d_name->n_name;
			if (strlen(suff) + strlen(newsuff) + 1 >= LZ)
				fatal("Suffix rule too long");
			p = str1;
			q = newsuff;
			while (*p++ = *q++)
				;
			p--;
			q = suff;
			while (*p++ = *q++)
				;
			sp = newname(str1);
			if (sp->n_flag & N_TARG) {
				p = str1;
				q = basename;
				if (strlen(basename)+strlen(newsuff) + 1 >= LZ)
					fatal("Implicit name too long");
				while (*p++ = *q++)
					;
				p--;
				q = newsuff;
				while (*p++ = *q++)
					;
				op = newname(str1);
				if (!op->n_time)
					modtime(op);
				if (op->n_time) {
					dp = newdep(op, (struct depend *) 0);
					newline(np, dp, sp->n_line->l_cmd, 0);
					setmacro("<", op->n_name);
					return TRUE;
				}
			}
		}
	return FALSE;
}


/*
 *    Make the default rules
 */
void
makerules()
{
	struct cmd *	cp;
	struct name *	np;
	struct depend *	dp;


	/* Atari special internal (to make) commands */
	setmacro("RM", "%r");	/* Remove, any number of args, Wildcards OK */
	setmacro("CP", "%c");	/* Copy file to file only     */
	setmacro("ECHO", "%e");	/* Echo Argument          */

	/* Sozobon C Compiler rules */

	/*
	 * PATH is the path used by make if none is given in the
	 * environment or in the makefile. This macro is used to
	 * locate anything to be executed by make, so having a
	 * reasonable default allows make to be used directly
	 * from GEM much more easily.
	 */
	setmacro("PATH", "\\bin,\\sozobon\\bin");

	/* Compiler driver program */
	setmacro("CC", "cc");

	/* Compiler options */
	setmacro("CFLAGS", "");

	/* Now make up the command lines */
	cp = newcmd("$(CC) -c $(CFLAGS) $<", (struct cmd *) 0);
	np = newname(".c.o");
	newline(np, (struct depend *) 0, cp, 0);

	cp = newcmd("$(CC) -c $(CFLAGS) $<", (struct cmd *) 0);
	np = newname(".s.o");
	newline(np, (struct depend *) 0, cp, 0);

	cp = newcmd("$(CC) -S $(CFLAGS) $<", (struct cmd *) 0);
	np = newname(".c.s");
	newline(np, (struct depend *) 0, cp, 0);

	cp = newcmd("$(CC) $(CFLAGS) $< -o $*.prg", (struct cmd *) 0);
	np = newname(".c.prg");
	newline(np, (struct depend *) 0, cp, 0);

	cp = newcmd("$(CC) $(CFLAGS) $< -o $*.tos", (struct cmd *) 0);
	np = newname(".c.tos");
	newline(np, (struct depend *) 0, cp, 0);

	cp = newcmd("$(CC) $(CFLAGS) $< -o $*.ttp", (struct cmd *) 0);
	np = newname(".c.ttp");
	newline(np, (struct depend *) 0, cp, 0);

	/* Predefined suffixes */
	np = newname(".prg");
	dp = newdep(np, NULL);
	np = newname(".tos");
	dp = newdep(np, dp);
	np = newname(".ttp");
	dp = newdep(np, dp);
	np = newname(".o");
	dp = newdep(np, dp);
	np = newname(".bin");
	dp = newdep(np, dp);
	np = newname(".s");
	dp = newdep(np, dp);
	np = newname(".c");
	dp = newdep(np, dp);
	np = newname(".pas");
	dp = newdep(np, dp);
	np = newname(".SUFFIXES");
	newline(np, dp, (struct cmd *) 0, 0);
}
