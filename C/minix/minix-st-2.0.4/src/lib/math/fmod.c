/*
 * (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 *
 * Author: Hans van Eck
 */
/* $Header: fmod.c,v 1.1 89/12/18 15:41:53 eck Exp $ */

#include	<math.h>
#include	<errno.h>

double
fmod(double x, double y)
{
	long	i;
	double val;
	double frac;

	if (y == 0) {
		errno = EDOM;
		return 0;
	}
	frac = modf( x / y, &val);

	return frac * y;

/*
	val = x / y;
	if (val > LONG_MIN && val < LONG_MAX) {
		i = val;
		return x - i * y;
	}
*/
}
