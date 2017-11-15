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
 *    Do the actual making for make
 */

#include <stdio.h>

#include "astat.h"
#include "h.h"

/*
 *    Exec a shell that returns exit status correctly (/bin/esh).
 *    The standard EON shell returns the process number of the last
 *    async command, used by the debugger (ugg).
 *    [exec on eon is like a fork+exec on unix]
 */
int
dosh(string, shell)
char	*string;
char	*shell;
{
	int	number;

	return system(string);
}


/*
 *    Do commands to make a target
 */
void
docmds1(np, lp)
struct name *       np;
struct line *       lp;
{
	bool	ssilent;
	bool	signore;
	int	estat;
	register char	*q;
	register char	*p;
	char	*shell;
	register struct cmd *cp;

	if (*(shell = getmacro("SHELL")) == '\0')
		;

	for (cp = lp->l_cmd; cp; cp = cp->c_next) {
		strcpy(str1, cp->c_cmd);
		expand(str1);
		q = str1;
		ssilent = silent;
		signore = ignore;
		while ((*q == '@') || (*q == '-')) {
			if (*q == '@')       /*  Specific silent  */
				ssilent = TRUE;
			else /*  Specific ignore  */
				signore = TRUE;
			q++;           /*  Not part of the command  */
		}

		if (!domake)
			ssilent = 0;

		if (!ssilent)
			fputs("    ", stdout);

		for (p = q; *p; p++) {
			if (*p == '\n' && p[1] != '\0') {
				*p = ' ';
				if (!ssilent)
					fputs("\\\n", stdout);
			} else if (!ssilent)
				putchar(*p);
		}
		if (!ssilent)
			putchar('\n');

		if (domake) {            /*  Get the shell to execute it  */
			if ((estat = dosh(q, shell)) != 0) {
				if (estat == -1)
					fatal("Couldn't execute %s", q);
				else {
					printf("%s: Error code %d", myname, estat);
					if (signore)
						fputs(" (Ignored)\n", stdout);
					else {
						putchar('\n');
						if (!(np->n_flag & N_PREC))
							if (unlink(np->n_name) == 0)
								printf("%s: '%s' removed.\n", myname,
									np->n_name);
						exit(estat);
					}
				}
			}
		}
	}
}


docmds(np)
struct name *np;
{
	register struct line *lp;


	for (lp = np->n_line; lp; lp = lp->l_next)
		docmds1(np, lp);
}


/*
 *    Get the current time in the internal format
 */
time(tp)
time_t *tp;
{
	if (tp)
		*tp = Gettime();

	return 0;
}


/*
 *    Get the modification time of a file.  If the first
 *    doesn't exist, it's modtime is set to 0.
 */
void
modtime(np)
struct name *np;
{
	struct stat info;
	extern int	getstat();		/*  in ststuff.c  */
	extern void		FlipWords();		/*  in ststuff.c  */

	if (getstat(np->n_name, &info) < 0)
		np->n_time = 0L;
	else {
		FlipWords(&info.st_mod);
		np->n_time = info.st_mod;
	}
}


/*
 *    Update the mod time of a file to now.
 */
void
touch(np)
struct name *np;
{
	char	c;
	int	fd;


	if (!domake || !silent)
		printf("    touch(%s)\n", np->n_name);

	if (domake) {
		if ((fd = Fopen(np->n_name, 0)) < 0)
			printf("%s: '%s' not touched - non-existant\n",
			    myname, np->n_name);
		else {
			long	tim;

			tim = Gettime();
			FlipWords(&tim);
			if (Fdatime( &tim, fd, 1) < 0)
				printf("%s: '%s' not touched - disk protected ?\n",
				    myname, np->n_name);
			Fclose(fd);
		}
	}
}


/*
 *    Recursive routine to make a target.
 */
int
make(np, level)
struct name *	np;
int	level;
{
	register struct depend *dp;
	register struct line *lp;
	register struct depend *qdp;
	time_t	dtime = 1;
	bool	didsomething = 0;


	if (np->n_flag & N_DONE)
		return 0;

	if (!np->n_time)
		modtime(np);	/*  Gets modtime of this file  */

	if (rules) {
		for (lp = np->n_line; lp; lp = lp->l_next)
			if (lp->l_cmd)
				break;
		if (!lp)
			dyndep(np);
	}

	if (!(np->n_flag & N_TARG) && np->n_time == 0L)
		fatal("Don't know how to make %s", np->n_name);

	for (qdp = (struct depend *)0, lp = np->n_line; lp; lp = lp->l_next) {
		for (dp = lp->l_dep; dp; dp = dp->d_next) {
			make(dp->d_name, level + 1);
			if (np->n_time < dp->d_name->n_time)
				qdp = newdep(dp->d_name, qdp);
			dtime = max(dtime, dp->d_name->n_time);
		}
		if (!quest && (np->n_flag & N_DOUBLE) && (np->n_time < dtime)) {
			make1(np, lp, qdp);		/* free()'s qdp */
			dtime = 1;
			qdp = (struct depend *)0;
			didsomething++;
		}
	}

	np->n_flag |= N_DONE;

	if (quest) {
		long	t;

		t = np->n_time;
		time(&np->n_time);
		return t < dtime;
	} else if (np->n_time < dtime && !(np->n_flag & N_DOUBLE)) {
		make1(np, (struct line *)0, qdp);	/* free()'s qdp */
		time(&np->n_time);
	} else if (level == 0 && !didsomething)
		printf("%s: '%s' is up to date\n", myname, np->n_name);
	return 0;
}


make1(np, lp, qdp)
register struct depend *qdp;
struct line *lp;
struct name *np;
{
	register struct depend *dp;


	if (dotouch)
		touch(np);
	else {
		strcpy(str1, "");
		for (dp = qdp; dp; dp = qdp) {
			if (strlen(str1))
				strcat(str1, " ");
			strcat(str1, dp->d_name->n_name);
			qdp = dp->d_next;
			free(dp);
		}
		setmacro("?", str1);
		setmacro("@", np->n_name);
		if (lp)			/* lp set if doing a :: rule */
			docmds1(np, lp);
		else
			docmds(np);
	}
}
