/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

#include <stdio.h>

/*
 * strsave(s) - copy s to dynamically allocated space
 */
char *
strsave(s)
register char	*s;
{
	char	*malloc(), *strcpy();

	return strcpy(malloc((unsigned) (strlen(s) + 1)), s);
}

/*
 * alloc() - malloc with error checking
 */
char *
alloc(n)
int	n;
{
	extern	char	*malloc();
	char	*p;

	if ((p = malloc(n)) == NULL) {
		fprintf(stderr, "top: out of memory\n");
		exit(1);
	}
	return p;
}

#if	MINIX || UNIX

remove(f)
char	*f;
{
	unlink(f);
}

rename(f1, f2)
char	*f1, *f2;
{
	unlink(f2);
	link(f1, f2);
	unlink(f1);
}

#endif
