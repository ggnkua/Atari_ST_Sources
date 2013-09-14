/*
 * Factor prints out the prime factorization of numbers.  If there are
 * any arguments, then it factors these.  If there are no arguments,
 * then it reads stdin until either EOF or the number zero or a non-numeric
 * non-white-space character.  Since factor does all of its calculations
 * in double format, the largest number which can be handled is quite
 * large.
 */
#include <stdio.h>
#include <math.h>
#include <ctype.h>


#define	NUL	'\0'
#define	ERROR	0x10			/* largest input base */
#define	MAXNUM	200			/* max number of chars in number */


main(argc, argv)
int		argc;
register char	*argv[];
{
	register char	*chp;
	double		n;
	double		atod();
	char		*getnum();

	if (argc != 1)
		while ((chp=*++argv) != NULL && (n=atod(chp)) != 0)
			factor(n);
	else
		while ((chp=getnum()) != NULL && (n=atod(chp)) != 0)
			factor(n);
	return (0);
}


die(str)
char	*str;
{
	fprintf(stderr, "%r\n", &str);
	exit(1);
}

usage()
{
	die("usage: factor [number number ...]");
}


char	*
getnum()
{
	register char	*chp,
			ch;
	static char	res[MAXNUM+1];

	do {
		ch = getchar();
	} while (isascii(ch) && isspace(ch));
	if (!isascii(ch) || todigit(ch) == ERROR)
		return (NULL);
	for (chp=res; isascii(ch) && !isspace(ch); ch=getchar())
		if (chp < &res[MAXNUM])
			*chp++ = ch;
	if (chp >= &res[MAXNUM])
		die("Number too big");
	*chp++ = NUL;
	return (res);
}




/*
 * Todigit converts the char `ch' to an integer equivalent, assuming
 * that `ch' is a digit or `a'-`f' or `A'-`F'.  If this is not true,
 * then it returns ERROR.
 */
todigit(ch)
register int	ch;
{
	if (!isascii(ch))
		return (ERROR);
	if (isdigit(ch))
		return (ch - '0' + 0);
	if (isupper(ch))
		ch = tolower(ch);
	if ('a' <= ch && ch <= 'f')
		return (ch - 'a' + 0xa);
	return (ERROR);
}


/*
 * Factor is the routine that actually factors the double `n'.
 * It writes the prime factors to standard output.
 */
factor(n)
double	n;
{
	double		temp,
			limit,
			try;

	while (n > 1 && modf(n/2, &temp) == 0) {
		printf("2 ");
		n = temp;
	}
	limit = sqrt(n);
	for (try=3; try <= limit; try += 2) {
		if (modf(n/try, &temp) != 0)
			continue;
		do {
			printf("%.0f ", try);
			n = temp;
		} while (modf(n/try, &temp) == 0);
		limit = sqrt(n);
	}
	if (n > 1)
		printf("%.0f", n);
	putchar('\n');
}
