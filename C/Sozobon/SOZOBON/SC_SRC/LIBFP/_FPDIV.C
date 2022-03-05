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

long
fpdiv(a,b)
long a,b;
{
	long binv, adj;
	long fpinv(), fpmul(), fpsub();

	binv = fpinv(b);
	adj = fpmul(b,binv);
	adj = fpsub(2.0,adj);
	return fpmul(fpmul(a,binv),adj);
}

fpinv(x)
register long x;	/* d4 */
{
	int exp, sign;

	exp = x & 0x7f;
	sign = x & 0x80;

	exp = 0x81 - exp;
	if (exp > 0x7f)
		return 0xffffff7f|sign;

	asm( "swap d4"			);
	asm( "move.l #$7fffffff,d0"	);
	asm( "divu d4,d0"		);
	asm( "move.l d0,d4"		);
	asm( "swap d4"			);
	asm( "clr.w d4"			);

	return x|sign|exp;
}
