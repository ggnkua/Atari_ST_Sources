/*
 * Focal, 1981.
 * A number of small routines that
 * don't go anywhere else.
 */
#include "focal.h"

/*
 * Put out the text line
 * pointed to by `lp' to the FILE
 * pointed to by `fp'.
 * Used any time a source line is
 * printed.
 */
void putline(lp, fp)
register struct line *lp;
FILE *fp;
{
	fprintf(fp, "%02d.%02d %s\n", lp->l_gno, lp->l_lno, lp->l_text);
}

/*
 * Get a line number.
 * The `c' argument is the first
 * character, and is assumed to be ok.
 * The line number, along with its general
 * shape, is packed into the structure
 * pointed to by `lnop'.
 */
void getlno(lnop, c)
register struct lno *lnop;
register c;
{
	register gn, ln;
	static char badlno[] = "Bad line or group number";

	if (c < 0)
		c = getnb();
	if (c=='\0' || c==';') {
		--ctp;
		lnop->ln_type = LN_NONE;
		return;
	}
	if (c=='A' || c=='a') {
		while (isalpha(*ctp))
			++ctp;
		lnop->ln_type = LN_ALL;
		return;
	}
	if (!isdigit(c))
		diag(badlno);
	if ((gn = getnum(c))<1 || gn>99)
		diag(badlno);
	if (*ctp != '.') {
		lnop->ln_gno = gn;
		lnop->ln_lno = 0;
		lnop->ln_type = LN_GRP;
		return;
	}
	++ctp;
	if ((ln=getnum(*ctp++)) == 0) {
		lnop->ln_gno = gn;
		lnop->ln_lno = 0;
		lnop->ln_type = LN_GRP;
		return;
	}
	if (ln<1 | ln>99)
		diag(badlno);
	lnop->ln_gno = gn;
	lnop->ln_lno = ln;
	lnop->ln_type = LN_LINE;
}

/*
 * Get a number. The argument
 * `c' is the first character of the
 * number, and is assumed to be valid.
 * Return the number read.
 */
int getnum(c)
register c;
{
	register n;

	n = 0;
	while (isdigit(c)) {
		n = 10*n + c - '0';
		c = *ctp++;
	}
	--ctp;
	return (n);
}

/*
 * Allocate a new line, with a
 * data array large enough to hold the
 * string pointed to by `cp'.
 * The line and group number fields are
 * not filled in.
 * Return a pointer to the line.
 */
struct line *
alocline(cp)
register char *cp;
{
	register struct line *lp = NULL;

	lp = (struct line *) malloc(sizeof(*lp)+strlen(cp)+1);
	if (lp == NULL)
		diag("Out of memory");
	return (lp);
}

/*
 * Print a diagnostic. The `s'
 * argument is an error message. The
 * offending line is displayed, with a flag
 * at the point where the scan failed.
 * This routine does not return; it just
 * does a non local goto back to the command
 * dispatcher.
 */
void diag(s)
char *s;
{
	register struct line *lp;
	register char *cp;

	printf("%s!\n", s);
	if ((lp=clp) != NULL) {
		putline(lp, stdout);
		printf("      ");
		cp = lp->l_text;
	} else {
		printf("*%s\n ", cbuf);
		cp = cbuf;
	}
	while (cp < ctp) {
		putchar(' ');
		++cp;
	}
	printf("^\n");
	while (control != NULL)
		popdo();
	longjmp(env, 0);
}

/*
 * Get the next non blank
 * character from the current source line.
 * Return it.
 */
int getnb()
{
	register c;

	while ((c = *ctp++)==' ' || c=='\t')
		;
	return (c);
}
/*
 * drand48
 *
 * return pseudo-random number in interval [0.0, 1.0)
 *
 */
double drand48()
{
	return (double) (rand() / 32768.0);
}
