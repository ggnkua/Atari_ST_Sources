/* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

long fpltof(l)
	long l;
	{
	int s;
	long m, fputof();

	if (l < 0)
		{
		s = 0x80;
		l = -l;
		}
	else
		s = 0;

	m = fputof(l) | s;
	return m;
	}

long fputof(l)
	long l;
	{
	register int e;
	register long m;

	m = l;
	if (m == 0)
		return 0;

	e = 0x40 + 32;
	while (m > 0)
		{
		m <<= 1;
		e--;
		}

	return (m & ~0xff) | e;
	}

#define MIN_L	0x80000000
#define MAX_L	0x7fffffff
#define MAX_U	0xffffffff

long fpftol(f)
	register long f;
	{
	long m, fpftou();

	if (f & 0x80)
		{
		f ^= 0x80;
		m = fpftou(f);
		if (m < 0)
			return MIN_L;
		return -m;
		}
	else
		{
		m = fpftou(f);
		if (m < 0)
			return MAX_L;
		return m;
		}
	}

long fpftou(f)
	long f;
	{
	register unsigned long m;
	register e;

	m = f & ~0xff;
	e = f & 0x7f;
	if (e < 0x40 || m == 0)		/* underflow */
		return 0;

	if (e > 0x40 + 32)		/* overflow */
		return MAX_U;

	e -= 0x40;

	m >>= 32 - e;
	return m;
	}
